# AgentGraph integration

`k8smicro` uses AgentGraph as its graph contract and execution model.

AgentGraph is not a separate runtime layer in this repository. The runtime is `k8smicro`.

## Relationship

```txt
k8smicro
  ├── uses AgentGraph for graph contracts and workflow topology
  ├── uses SurrealDB for graph/state/action persistence
  ├── uses workers for execution
  ├── uses SSH adapters for node operations
  ├── uses Kubernetes adapters for workload operations
  └── uses walt.id for identity and approval verification
```

## Layer position

```txt
OVH/Kimsufi bare metal
  ↓
Linux
  ↓
k3s
  ↓
k8smicro autonomous infrastructure runtime
  ├── AgentGraph execution model
  ├── SurrealDB-native control data
  ├── walt.id identity/trust
  ├── SSH adapter
  └── Kubernetes adapter
```

## AgentGraph responsibilities inside k8smicro

AgentGraph defines:

- workflow nodes
- dependency edges
- execution topology
- graph validation
- step state
- retry policy
- rollback relationships
- audit relationships
- decision tracking

AgentGraph does not directly provision infrastructure. k8smicro workers execute infrastructure actions using adapters.

## Example graph

```yaml
id: bootstrap_kimsufi_k3s
nodes:
  - id: verify_identity
    action: identity.verify

  - id: harden_node
    action: linux.harden

  - id: install_k3s
    action: k3s.install

  - id: deploy_surrealdb
    action: surrealdb.deploy

  - id: deploy_worker
    action: k8smicro.worker.deploy

edges:
  - from: verify_identity
    to: harden_node

  - from: harden_node
    to: install_k3s

  - from: install_k3s
    to: deploy_surrealdb

  - from: deploy_surrealdb
    to: deploy_worker
```

## SurrealDB mapping

AgentGraph concepts map to SurrealDB tables:

| AgentGraph concept | SurrealDB table |
|---|---|
| Graph run | `workflow_run` |
| Node action | `agent_action` |
| Edge/dependency | `infra_relation` |
| Runtime memory | `agent_memory` |
| Audit event | `action_log` |
| Target infrastructure | `server`, `cluster` |

## Execution flow

```txt
User requests workflow
  ↓
k8smicro writes AgentGraph run to SurrealDB
  ↓
SurrealDB stores graph nodes and edges
  ↓
k8smicro workers claim ready nodes
  ↓
workers execute actions through adapters
  ↓
workers write results back to SurrealDB
  ↓
AgentGraph advances dependent nodes
```

## Integration source

AGenNext Agent-Graph provides the broader SurrealDB-native graph contract and backend-first platform direction. k8smicro applies that model specifically to autonomous infrastructure operations on lightweight Kubernetes micro-clouds.
