# AgentKube integration

AgentKube is the Kubernetes operations layer for AGenNext infrastructure agents.

Within `cloud-architect-agents`, AgentKube should be treated as a Kubernetes adapter/operator capability used by `k8smicro`, not as a replacement for `k8smicro`.

## Relationship

```txt
k8smicro
  ├── runtime identity
  ├── AgentGraph execution model
  ├── SurrealDB control data
  ├── walt.id identity/trust
  ├── SSH adapter
  └── AgentKube Kubernetes operations layer
```

## Clear boundary

| Component | Responsibility |
|---|---|
| k8smicro | Autonomous infrastructure runtime |
| AgentGraph | Graph contract and workflow execution model |
| AgentKube | Kubernetes adapter/operator layer |
| SurrealDB | State, memory, graph, events, action queue, audit |
| walt.id | DID, VC, approvals, signed actions |
| k3s | Kubernetes distribution/substrate |
| OVH/Kimsufi | Bare metal provider |

## Layer position

```txt
OVH/Kimsufi bare metal
  ↓
Linux
  ↓
k3s
  ↓
k8smicro runtime
  ├── AgentGraph workflow model
  ├── AgentKube Kubernetes operations
  ├── SSH node operations
  ├── SurrealDB state/events
  └── walt.id trust layer
```

## AgentKube responsibilities

AgentKube should own Kubernetes-native actions:

- apply manifests
- create namespaces
- manage deployments
- inspect pods
- read logs
- rollout status
- manage services
- manage ingress
- manage secrets/configmaps
- run jobs
- install platform workloads
- report cluster health

AgentKube should not own:

- provider lifecycle
- OVH/Kimsufi billing or reinstall flows
- SurrealDB schema authority
- identity issuance
- global workflow planning

Those remain owned by k8smicro and its related agents.

## Example action mapping

| k8smicro action | AgentKube operation |
|---|---|
| `surrealdb.deploy` | apply SurrealDB manifests |
| `worker.deploy` | apply worker deployment |
| `k8s.healthcheck` | inspect nodes and pods |
| `ingress.install` | deploy ingress controller |
| `certmanager.install` | deploy cert-manager |
| `workload.rollout` | wait for deployment rollout |

## Execution flow

```txt
AgentGraph node becomes ready
  ↓
k8smicro worker claims action from SurrealDB
  ↓
worker routes Kubernetes action to AgentKube
  ↓
AgentKube applies/inspects Kubernetes resources
  ↓
result is written back to SurrealDB
  ↓
AgentGraph advances dependent nodes
```

## Recommended implementation

In this repository, keep the first implementation as:

```txt
runtimes/kubernetes/client.py
```

Later, once AgentKube has its own repo implementation, replace or wrap that client with the AgentKube SDK/operator.
