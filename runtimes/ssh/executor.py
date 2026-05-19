import asyncio
from dataclasses import dataclass
from typing import Optional

import asyncssh


@dataclass
class SSHResult:
    host: str
    command: str
    exit_code: int
    stdout: str
    stderr: str

    @property
    def ok(self) -> bool:
        return self.exit_code == 0

    def to_dict(self) -> dict:
        return {
            "host": self.host,
            "command": self.command,
            "exit_code": self.exit_code,
            "stdout": self.stdout,
            "stderr": self.stderr,
            "ok": self.ok,
        }


class SSHExecutor:
    def __init__(
        self,
        host: str,
        user: str = "root",
        port: int = 22,
        client_keys: Optional[list[str]] = None,
        known_hosts: Optional[str] = None,
        connect_timeout: int = 20,
        command_timeout: int = 600,
    ) -> None:
        self.host = host
        self.user = user
        self.port = port
        self.client_keys = client_keys
        self.known_hosts = known_hosts
        self.connect_timeout = connect_timeout
        self.command_timeout = command_timeout

    async def run(self, command: str) -> SSHResult:
        async with asyncssh.connect(
            self.host,
            username=self.user,
            port=self.port,
            client_keys=self.client_keys,
            known_hosts=self.known_hosts,
            connect_timeout=self.connect_timeout,
        ) as conn:
            result = await asyncio.wait_for(
                conn.run(command, check=False),
                timeout=self.command_timeout,
            )

            return SSHResult(
                host=self.host,
                command=command,
                exit_code=result.exit_status,
                stdout=result.stdout,
                stderr=result.stderr,
            )

    async def run_script(self, script: str) -> SSHResult:
        escaped = script.replace("'", "'\\''")
        return await self.run(f"bash -lc '{escaped}'")
