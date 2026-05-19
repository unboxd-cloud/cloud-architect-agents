# Cloud Architect Agent Blueprint

The Cloud Architect Agent is a domain blueprint for planning, operating, and governing cloud and bare-metal infrastructure.

This repository owns the cloud/domain agent blueprint. Runtime responsibilities remain in `AGenNext/Agent-Runtime`.

## Role

The Cloud Architect Agent converts user intent into governed infrastructure workflows.

It understands:

- providers
- servers
- networks
- Kubernetes clusters
- deployment topology
- cost and capacity constraints
- security posture
- recovery paths
- runtime profiles such as `k8smicro`

## Boundary

| Layer | Repository |
|---|---|
| Runtime engine and profiles | `AGenNext/Agent-Runtime` |
| k8smicro runtime profile | `AGenNext/Agent-Runtime/profiles/k8smicro` |
| Graph contracts | `AGenNext/Agent-Graph` |
| Kubernetes operations | `AGenNext/AgentKube` |
| Cloud architect blueprint | `unboxd-cloud/cloud-architect-agents` |

## Responsibilities

The Cloud Architect Agent owns:

- infrastructure planning
- provider-specific reasoning
- OVH/Kimsufi topology planning
- target architecture generation
- workflow selection
- risk classification
- cost/capacity recommendations
- disaster-recovery planning
- policy-aware execution planning

It does not own:

- runtime worker loops
- Kubernetes client implementation
- AgentGraph core schema
- identity issuance
- SurrealDB runtime internals

## Execution relationship

```txt
User intent
  ↓
Cloud Architect Agent Blueprint
  ↓
AgentGraph workflow plan
  ↓
Agent-Runtime / k8smicro profile
  ↓
AgentKube + SSH adapters
  ↓
OVH/Kimsufi infrastructure
```

## Example: Kimsufi micro-cloud plan

```yaml
id: kimsufi_microcloud_architecture
intent: deploy governed micro-cloud on Kimsufi Eco
runtime_profile: k8smicro
provider: ovh
substrate: k3s
state: surrealdb
identity: waltid

plan:
  - inspect_server
  - harden_node
  - install_k3s
  - deploy_surrealdb
  - deploy_k8smicro_workers
  - register_cluster
  - run_healthcheck
```

## Agent output contract

The Cloud Architect Agent should output an AgentGraph-compatible plan:

```yaml
graph:
  id: bootstrap_kimsufi_microcloud
  runtime_profile: k8smicro
  nodes:
    - id: verify_identity
      action: identity.verify
    - id: harden_node
      action: linux.harden
    - id: install_k3s
      action: k3s.install
    - id: deploy_surrealdb
      action: surrealdb.deploy
  edges:
    - from: verify_identity
      to: harden_node
    - from: harden_node
      to: install_k3s
    - from: install_k3s
      to: deploy_surrealdb
```

## First target

The first target architecture is:

```txt
OVH/Kimsufi Eco bare metal
  ↓
Debian/Ubuntu
  ↓
k3s
  ↓
Agent-Runtime profile: k8smicro
  ↓
SurrealDB + AgentGraph + AgentKube
```
