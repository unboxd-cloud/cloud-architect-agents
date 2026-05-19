# cloud-architect-agents

Cloud Architect Agents for governed bare-metal and cloud automation.

## First runtime: k8smicro

`k8smicro` is the Unboxd agent runtime for lightweight Kubernetes micro-clouds.

It turns an OVH/Kimsufi bare metal server into a governed, agent-managed Kubernetes environment.

## Naming

- `k8smicro` is the agent runtime.
- `k3s` is the default Kubernetes distribution used by the runtime.
- SurrealDB is the native memory, state, graph, event, and control-plane database.
- walt.id provides decentralized identity and verifiable credentials.

So the stack is:

```txt
Kimsufi Eco bare metal
    ↓
k3s Kubernetes distribution
    ↓
k8smicro agent runtime
    ↓
SurrealDB-native infrastructure control plane
```

Default target stack:

- OVH / Kimsufi Eco bare metal
- Debian 12 or Ubuntu 24.04
- k3s single-node Kubernetes
- k8smicro agent runtime
- SurrealDB as native memory, state, graph, event, and control plane
- walt.id for decentralized identity and verifiable credentials
- SSH runtime for node operations
- Kubernetes runtime for workload operations

## Architecture

```txt
User / CLI / SurrealDB SDK
    ↓
walt.id identity verification
    ↓
SurrealDB-native control plane
    ↓
agent_action / workflow_run / action_log tables
    ↓
k8smicro runtime workers
    ↓
SSH + Kubernetes runtime adapters
    ↓
Kimsufi Eco bare metal running k3s
    ↓
SurrealDB + agent workloads
```

## Why SurrealDB-native

The control plane should not start as a separate FastAPI service. SurrealDB already provides the core primitives needed by the agent runtime:

- document state
- graph relations
- live queries
- permissions
- events/changefeeds
- SQL-like workflows
- direct SDK access
- audit log persistence
- infrastructure memory

FastAPI can be added later only as an optional compatibility gateway for REST clients.

## Core principles

- k8smicro is the agent runtime
- SurrealDB is the source of truth
- Plan before execute
- Approve dangerous actions
- Audit every action
- Store infrastructure state and graph in SurrealDB
- Use walt.id identities for users, agents, and services
- Prefer lightweight Kubernetes for low-cost bare metal
- Keep workers stateless; persist state in SurrealDB

## Repository layout

```txt
agents/         Runtime workers and agent modules
identity/       walt.id identity adapter
memory/         SurrealDB schema, events, and queries
providers/      OVH/Kimsufi provider adapters
runtimes/       SSH and Kubernetes execution adapters
workflows/      Declarative infrastructure workflows
manifests/      Kubernetes manifests
scripts/        Bootstrap and healthcheck scripts
```

## MVP workflow

1. Verify actor identity with walt.id
2. Write requested action to SurrealDB
3. Register Kimsufi target server in SurrealDB
4. k8smicro worker claims pending action
5. Harden Linux node
6. Install k3s
7. Install ingress and cert-manager
8. Deploy SurrealDB workloads
9. Write audit logs for every action
10. Update workflow state in SurrealDB
