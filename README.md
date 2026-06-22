# Travel Agent — AgentOps release-gated Foundry prompt agent

A small travel-planning assistant built as an Azure AI Foundry **prompt agent**,
with [AgentOps](https://azure.github.io/agentops/) wired in for release-readiness
gating on every change.

## What this repo ships

- **Prompt agent** — the source-controlled prompt in
  [`.agentops/prompts/travel-agent.prompt.md`](.agentops/prompts/travel-agent.prompt.md)
  is the shippable artifact. CI stages it as an ephemeral Foundry version,
  evaluates it, and only known-good versions get recorded as deployed.
- **Evaluation suite** — [`src/travel-agent/eval.yaml`](src/travel-agent/eval.yaml)
  scores coherence, fluency, and a custom `smoke-core` rubric against the
  datasets in [`.agentops/data/`](.agentops/data).
- **Governance gates** — ASSERT behavioral checks
  ([`assert/eval_config.yaml`](assert/eval_config.yaml)) and a Red Team scan,
  surfaced through `agentops doctor`.

## Release gates

| Trigger | Workflow | Foundry project | What runs |
| --- | --- | --- | --- |
| PR to `main` | [`agentops-pr.yml`](.github/workflows/agentops-pr.yml) | `travel-agent-sandbox` | stage candidate → eval → ASSERT / Red Team → Doctor |
| Push to `main` | [`agentops-deploy-dev.yml`](.github/workflows/agentops-deploy-dev.yml) | `travel-agent-dev` | stage → eval gate → record deployed |

Both workflows authenticate to Azure with keyless **OIDC** (federated
credentials scoped per GitHub environment).

## Local development

```bash
source .venv/bin/activate
agentops eval run        # run the evaluation suite
agentops doctor          # release-readiness summary
agentops cockpit         # local dashboard at http://127.0.0.1:8090
```

See the [AgentOps prompt-agent tutorial](https://azure.github.io/agentops/tutorial-prompt-agent/)
for the end-to-end walkthrough this project follows.
