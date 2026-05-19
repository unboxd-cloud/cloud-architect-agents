import asyncio
import json
from datetime import datetime

from surrealdb import Surreal


SURREALDB_URL = "ws://localhost:8000/rpc"
SURREALDB_NAMESPACE = "unboxd"
SURREALDB_DATABASE = "cloud_architect"
SURREALDB_USER = "root"
SURREALDB_PASS = "root"

AGENT_ID = "k8smicro"


class K8sMicroWorker:
    def __init__(self) -> None:
        self.db = Surreal(SURREALDB_URL)

    async def connect(self) -> None:
        await self.db.connect()
        await self.db.signin(
            {
                "user": SURREALDB_USER,
                "pass": SURREALDB_PASS,
            }
        )
        await self.db.use(SURREALDB_NAMESPACE, SURREALDB_DATABASE)

    async def claim_action(self, action_id: str) -> None:
        query = """
        UPDATE type::thing('agent_action', $action_id)
        SET
          status = 'running',
          claimed_by = $agent_id,
          claimed_at = time::now(),
          updated_at = time::now();
        """

        await self.db.query(
            query,
            {
                "action_id": action_id,
                "agent_id": AGENT_ID,
            },
        )

    async def complete_action(self, action_id: str, output: dict) -> None:
        query = """
        UPDATE type::thing('agent_action', $action_id)
        SET
          status = 'completed',
          output = $output,
          updated_at = time::now();
        """

        await self.db.query(
            query,
            {
                "action_id": action_id,
                "output": output,
            },
        )

    async def fail_action(self, action_id: str, error: str) -> None:
        query = """
        UPDATE type::thing('agent_action', $action_id)
        SET
          status = 'failed',
          error = $error,
          updated_at = time::now();
        """

        await self.db.query(
            query,
            {
                "action_id": action_id,
                "error": error,
            },
        )

    async def execute(self, action: dict) -> dict:
        action_name = action.get("action")

        print(f"[k8smicro] Executing action: {action_name}")

        # TODO:
        # - integrate SSH runtime
        # - integrate Kubernetes runtime
        # - execute workflows
        # - verify approvals

        await asyncio.sleep(2)

        return {
            "agent": AGENT_ID,
            "action": action_name,
            "executed_at": datetime.utcnow().isoformat(),
            "status": "ok",
        }

    async def handle_action(self, action: dict) -> None:
        action_id = action["id"]

        try:
            await self.claim_action(action_id)
            result = await self.execute(action)
            await self.complete_action(action_id, result)

        except Exception as exc:
            await self.fail_action(action_id, str(exc))

    async def subscribe(self) -> None:
        query = f"""
        LIVE SELECT *
        FROM agent_action
        WHERE status = 'pending'
          AND agent_id = '{AGENT_ID}';
        """

        print("[k8smicro] Subscribing to pending actions...")

        await self.db.query(query)

        while True:
            response = await self.db.recv()

            if not response:
                continue

            payload = response.get("result")

            if not payload:
                continue

            action = payload.get("result")

            if not action:
                continue

            print("[k8smicro] Received action:")
            print(json.dumps(action, indent=2))

            await self.handle_action(action)


async def main() -> None:
    worker = K8sMicroWorker()
    await worker.connect()
    await worker.subscribe()


if __name__ == "__main__":
    asyncio.run(main())
