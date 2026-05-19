# cloud-architect-agents

Cloud Architect Agents for governed bare-metal and cloud automation.

## First agent: k8smicro

`k8smicro` turns an OVH/Kimsufi bare metal server into a lightweight Kubernetes micro-cloud.

Default target stack:

- OVH / Kimsufi Eco bare metal
- Debian 12 or Ubuntu 24.04
- k3s single-node Kubernetes
- SurrealDB for memory and state
- walt.id for decentralized identity and verifiable credentials
- SSH runtime for node operations
- Kubernetes runtime for workload operations

## Architecture

```txt
User / CLI / API
    ↓
walt.id identity gateway
    ↓
OVH Cloud Architect Agent
    ↓
k8smicro agent
    ↓
SSH + Kubernetes runtime
    ↓
Kimsufi Eco bare metal running k3s
    ↓
SurrealDB + agent workloads
```

## Core principles

- Plan before execute
- Approve dangerous actions
- Audit every action
- Store infrastructure state in SurrealDB
- Use walt.id identities for users, agents, and services
- Prefer lightweight Kubernetes for low-cost bare metal

## Repository layout

```txt
agents/         Agent modules
identity/       walt.id identity adapter
memory/         SurrealDB schema and repository layer
providers/      OVH/Kimsufi provider adapters
runtimes/       SSH and Kubernetes execution runtimes
workflows/      Declarative infrastructure workflows
manifests/      Kubernetes manifests
scripts/        Bootstrap and healthcheck scripts
```

## MVP workflow

1. Verify actor identity with walt.id
2. Register Kimsufi target server in SurrealDB
3. Harden Linux node
4. Install k3s
5. Install ingress and cert-manager
6. Deploy SurrealDB
7. Deploy the agent control plane
8. Write audit logs for every action
