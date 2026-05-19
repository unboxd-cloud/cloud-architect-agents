-- SurrealDB schema for cloud-architect-agents
-- Memory, inventory, identity bindings, workflows, actions, and audit logs.

DEFINE NAMESPACE IF NOT EXISTS unboxd;
DEFINE DATABASE IF NOT EXISTS cloud_architect;

USE NS unboxd DB cloud_architect;

DEFINE TABLE server SCHEMAFULL;
DEFINE FIELD provider ON server TYPE string;
DEFINE FIELD service_name ON server TYPE string;
DEFINE FIELD hostname ON server TYPE string;
DEFINE FIELD ipv4 ON server TYPE option<string>;
DEFINE FIELD ipv6 ON server TYPE option<string>;
DEFINE FIELD status ON server TYPE string;
DEFINE FIELD os ON server TYPE option<string>;
DEFINE FIELD role ON server TYPE string;
DEFINE FIELD tags ON server TYPE array<string>;
DEFINE FIELD created_at ON server TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON server TYPE datetime DEFAULT time::now();

DEFINE TABLE cluster SCHEMAFULL;
DEFINE FIELD name ON cluster TYPE string;
DEFINE FIELD distro ON cluster TYPE string;
DEFINE FIELD version ON cluster TYPE option<string>;
DEFINE FIELD endpoint ON cluster TYPE option<string>;
DEFINE FIELD status ON cluster TYPE string;
DEFINE FIELD created_at ON cluster TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON cluster TYPE datetime DEFAULT time::now();

DEFINE TABLE agent SCHEMAFULL;
DEFINE FIELD name ON agent TYPE string;
DEFINE FIELD kind ON agent TYPE string;
DEFINE FIELD did ON agent TYPE option<string>;
DEFINE FIELD status ON agent TYPE string;
DEFINE FIELD capabilities ON agent TYPE array<string>;
DEFINE FIELD created_at ON agent TYPE datetime DEFAULT time::now();

DEFINE TABLE identity_binding SCHEMAFULL;
DEFINE FIELD subject_did ON identity_binding TYPE string;
DEFINE FIELD subject_type ON identity_binding TYPE string;
DEFINE FIELD permissions ON identity_binding TYPE array<string>;
DEFINE FIELD issuer_did ON identity_binding TYPE option<string>;
DEFINE FIELD credential_id ON identity_binding TYPE option<string>;
DEFINE FIELD valid_from ON identity_binding TYPE option<datetime>;
DEFINE FIELD valid_until ON identity_binding TYPE option<datetime>;
DEFINE FIELD created_at ON identity_binding TYPE datetime DEFAULT time::now();

DEFINE TABLE agent_action SCHEMAFULL;
DEFINE FIELD actor_did ON agent_action TYPE string;
DEFINE FIELD agent_id ON agent_action TYPE string;
DEFINE FIELD action ON agent_action TYPE string;
DEFINE FIELD target ON agent_action TYPE string;
DEFINE FIELD status ON agent_action TYPE string DEFAULT "pending";
DEFINE FIELD priority ON agent_action TYPE int DEFAULT 100;
DEFINE FIELD approval_required ON agent_action TYPE bool DEFAULT false;
DEFINE FIELD approved ON agent_action TYPE bool DEFAULT false;
DEFINE FIELD claimed_by ON agent_action TYPE option<string>;
DEFINE FIELD claimed_at ON agent_action TYPE option<datetime>;
DEFINE FIELD input ON agent_action TYPE object DEFAULT {};
DEFINE FIELD output ON agent_action TYPE object DEFAULT {};
DEFINE FIELD error ON agent_action TYPE option<string>;
DEFINE FIELD created_at ON agent_action TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON agent_action TYPE datetime DEFAULT time::now();
DEFINE INDEX agent_action_status_idx ON agent_action FIELDS status;
DEFINE INDEX agent_action_agent_idx ON agent_action FIELDS agent_id;

DEFINE TABLE agent_memory SCHEMAFULL;
DEFINE FIELD agent_id ON agent_memory TYPE string;
DEFINE FIELD kind ON agent_memory TYPE string;
DEFINE FIELD content ON agent_memory TYPE object;
DEFINE FIELD created_at ON agent_memory TYPE datetime DEFAULT time::now();

DEFINE TABLE action_log SCHEMAFULL;
DEFINE FIELD actor_did ON action_log TYPE string;
DEFINE FIELD agent_id ON action_log TYPE string;
DEFINE FIELD action ON action_log TYPE string;
DEFINE FIELD target ON action_log TYPE string;
DEFINE FIELD approval_required ON action_log TYPE bool DEFAULT false;
DEFINE FIELD approved ON action_log TYPE bool DEFAULT false;
DEFINE FIELD status ON action_log TYPE string;
DEFINE FIELD input ON action_log TYPE object;
DEFINE FIELD output ON action_log TYPE object;
DEFINE FIELD error ON action_log TYPE option<string>;
DEFINE FIELD created_at ON action_log TYPE datetime DEFAULT time::now();

DEFINE TABLE workflow_run SCHEMAFULL;
DEFINE FIELD workflow_id ON workflow_run TYPE string;
DEFINE FIELD actor_did ON workflow_run TYPE string;
DEFINE FIELD target ON workflow_run TYPE string;
DEFINE FIELD status ON workflow_run TYPE string;
DEFINE FIELD steps ON workflow_run TYPE array<object>;
DEFINE FIELD created_at ON workflow_run TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON workflow_run TYPE datetime DEFAULT time::now();

DEFINE TABLE infra_relation SCHEMAFULL;
DEFINE FIELD from_ref ON infra_relation TYPE string;
DEFINE FIELD to_ref ON infra_relation TYPE string;
DEFINE FIELD relation ON infra_relation TYPE string;
DEFINE FIELD metadata ON infra_relation TYPE object DEFAULT {};
DEFINE FIELD created_at ON infra_relation TYPE datetime DEFAULT time::now();

-- Seed core agents
CREATE agent:k8smicro SET
  name = "k8smicro",
  kind = "kubernetes-baremetal-operator",
  status = "planned",
  capabilities = ["linux.harden", "k3s.install", "k8s.apply", "k8s.healthcheck"];

CREATE agent:memory SET
  name = "memory",
  kind = "surrealdb-memory-agent",
  status = "planned",
  capabilities = ["state.read", "state.write", "audit.write"];

CREATE agent:identity SET
  name = "identity",
  kind = "waltid-identity-agent",
  status = "planned",
  capabilities = ["vc.verify", "did.resolve", "approval.verify"];
