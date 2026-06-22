# AgentOps Doctor Report

_Generated: 2026-06-22 11:32:08 UTC_

## Verdict: ⚠️ Warnings found

## Summary

| Severity | Count |
|---|---|
| 🚨 Critical | 0 |
| ⚠️  Warning  | 6 |
| ℹ️  Info     | 2 |

| Category | Count |
|---|---|
| Quality | 0 |
| Performance Efficiency | 0 |
| Reliability | 1 |
| Operational Excellence | 5 |
| Security | 0 |
| Responsible AI | 2 |

## Sources

| Source | Status | Detail |
|---|---|---|
| `results_history` | `ok` | 6 |
| `azure_monitor` | `skipped` | neither app_insights_resource_id nor log_analytics_workspace_id is configured, and no App Insights ApplicationId could be discovered from the connection string or Foundry project |
| `foundry_control` | `ok` |  |
| `azure_resources` | `skipped` | Azure resources source could not determine subscription_id from `.agentops/agent.yaml`, `.azure/<env>/.env`, or `AZURE_SUBSCRIPTION_ID`. Configure one of those values so Doctor can inspect the deployed Azure resources. |
| `source_timings_seconds` | `unknown` |  |

## Findings

### Reliability

| Severity | ID | Title | Source |
|---|---|---|---|
| ⚠️ `warning` | `errors.no_runtime_telemetry` | Production telemetry is not wired to the agent | `azure_monitor` |

#### ⚠️ `errors.no_runtime_telemetry` - Production telemetry is not wired to the agent

- **Severity:** `warning`
- **Category:** `reliability`
- **Source:** `azure_monitor`
- **WAF:** `Reliability` / `Telemetry` - [ai_lz.AI.115](https://learn.microsoft.com/azure/well-architected/ai/reliability)

The `azure_monitor` source is not configured (neither app_insights_resource_id nor log_analytics_workspace_id is configured, and no App Insights ApplicationId could be discovered from the connection string or Foundry project). Without App Insights wired up, Doctor has no production observability, so latency, errors, runtime safety, and telemetry-based reliability checks all stay grey.

**Recommendation:** Configure `sources.azure_monitor.app_insights_resource_id` or set `APPLICATIONINSIGHTS_CONNECTION_STRING` with an `ApplicationId`, install the `[agent]` extra, and connect Azure Monitor OpenTelemetry on the agent runtime (call `configure_azure_monitor()` on startup). See `docs/tutorial-end-to-end.md` -> 'Wire observability'.

**Evidence:**

```json
{
  "monitor_status": "skipped",
  "reason": "neither app_insights_resource_id nor log_analytics_workspace_id is configured, and no App Insights ApplicationId could be discovered from the connection string or Foundry project",
  "mode": "not_configured"
}
```

### Operational Excellence

| Severity | ID | Title | Source |
|---|---|---|---|
| ⚠️ `warning` | `observability.trace_sampling_missing` | Intelligent trace sampling is not evidence-ready | `observability` |
| ⚠️ `warning` | `opex.max_tokens_undefined` | Output token limit is not set on model / evaluator configuration | `opex_workspace` |
| ⚠️ `warning` | `opex.release.no_continuous_eval` | No enabled Foundry continuous evaluation rule is attached | `release_readiness` |
| ℹ️ `info` | `observability.trace_replay_missing` | Trace replay link is not captured in release evidence | `observability` |
| ℹ️ `info` | `opex.release.no_trace_regression_dataset` | Production traces are not feeding a regression dataset yet | `release_readiness` |

#### ⚠️ `observability.trace_sampling_missing` - Intelligent trace sampling is not evidence-ready

- **Severity:** `warning`
- **Category:** `operational_excellence`
- **Source:** `observability`

Foundry intelligent trace sampling evaluates the most signal-rich production traces without scoring every request. AgentOps did not find `observability.trace_sampling.enabled: true` or sampling metadata in the trace-regression manifest.

**Recommendation:** Enable Foundry trace sampling or document the sampling policy in `observability.trace_sampling`, then regenerate trace-derived dataset candidates so release evidence includes the lineage.

#### ⚠️ `opex.max_tokens_undefined` - Output token limit is not set on model / evaluator configuration

- **Severity:** `warning`
- **Category:** `operational_excellence`
- **Source:** `opex_workspace`
- **WAF:** `Cost` / `TokenLimits` - [ai_lz.AI.26](https://learn.microsoft.com/azure/well-architected/ai/cost-optimization)

Found model / evaluator YAML files that do not declare a `max_tokens:` or `max_completion_tokens:` ceiling. Without an upper bound a single runaway completion or a malicious prompt can drive token spend arbitrarily high.

**Recommendation:** Add a `max_tokens:` field for chat models, or `max_completion_tokens:` for reasoning models such as `gpt-5` and `o` series deployments. Pick a value just above your longest legitimate response so legitimate traffic isn't truncated.

**Evidence:**

```json
{
  "files_without_token_limit": [
    "agentops.yaml"
  ],
  "files_with_token_limit": []
}
```

#### ⚠️ `opex.release.no_continuous_eval` - No enabled Foundry continuous evaluation rule is attached

- **Severity:** `warning`
- **Category:** `operational_excellence`
- **Source:** `release_readiness`

The Foundry control plane was reachable, but AgentOps did not detect an enabled continuous evaluation rule. Production responses may not be sampled and scored after deployment.

**Recommendation:** Enable Foundry continuous evaluation for the production agent and include at least one safety or quality evaluator so runtime traffic keeps producing quality evidence.

**Evidence:**

```json
{
  "evaluation_rules_count": 0,
  "agents": [
    "travel-agent"
  ]
}
```

#### ℹ️ `observability.trace_replay_missing` - Trace replay link is not captured in release evidence

- **Severity:** `info`
- **Category:** `operational_excellence`
- **Source:** `observability`

Foundry trace replay and visualization make incident review faster by linking each failure to the exact prompts, decisions, tool calls, and outputs. AgentOps did not find a replay URL in agentops.yaml or the trace-regression manifest.

**Recommendation:** After selecting representative traces in Foundry, keep the replay link in `observability.trace_replay_url` or include it in trace exports before running `agentops eval promote-traces --apply`.

#### ℹ️ `opex.release.no_trace_regression_dataset` - Production traces are not feeding a regression dataset yet

- **Severity:** `info`
- **Category:** `operational_excellence`
- **Source:** `release_readiness`

No trace-regression manifest was found under `.agentops/data/`. This is acceptable for early exploration, but production incidents and high-value conversations should become reviewed regression rows over time.

**Recommendation:** Export relevant App Insights / Foundry traces and run `agentops eval promote-traces --source <traces.jsonl> --apply` to create a reviewed production-derived regression dataset.

**Evidence:**

```json
{
  "manifest": "/home/ayoola/agentops/.agentops/data/trace-regression-manifest.json"
}
```

### Responsible AI

| Severity | ID | Title | Source |
|---|---|---|---|
| ⚠️ `warning` | `responsible_ai.llm.dataset_bias_signals` | [LLM-judged] Evaluation dataset shows distribution skew | `llm_judge` |
| ⚠️ `warning` | `safety.config.continuous_eval_missing` | No continuous evaluation rules configured | `foundry_control` |

#### ⚠️ `responsible_ai.llm.dataset_bias_signals` - [LLM-judged] Evaluation dataset shows distribution skew

- **Severity:** `warning`
- **Category:** `responsible_ai`
- **Source:** `llm_judge`
- **WAF:** `ResponsibleAI` / `Fairness` - [waf.rai.dataset_bias_signals](https://learn.microsoft.com/azure/well-architected/ai/responsible-ai)

The judge model identified distribution skew in the dataset sample (risk=medium): The dataset shows a skew towards travel planning scenarios, primarily focusing on popular tourist destinations like Paris, Rome, and Tokyo, which may not represent a diverse range of geographical locations or cultural contexts. Additionally, the majority of examples involve family or couple dynamics, potentially overlooking solo travelers or other demographics.

**Recommendation:** Diversify the dataset along the flagged axes (gender, age, domain, tone, geography, happy/sad paths). The Microsoft Responsible AI Standard's Fairness principle asks for representative test data; uniform samples underestimate the agent's real-world failure rate.

**Concrete fixes the judge model suggested for this specific case:**
- Include examples from a wider range of geographical locations and cultures.
- Add scenarios that involve different types of travelers, such as solo travelers or groups with diverse needs.
- Incorporate edge cases or less common travel situations to balance the dataset.

**Evidence:**

```json
{
  "confidence": 0.7,
  "reasoning": "The dataset shows a skew towards travel planning scenarios, primarily focusing on popular tourist destinations like Paris, Rome, and Tokyo, which may not represent a diverse range of geographical locations or cultural contexts. Additionally, the majority of examples involve family or couple dynamics, potentially overlooking solo travelers or other demographics.",
  "model_deployment": "gpt-4o-mini",
  "cache_hit": true,
  "risk": "medium",
  "suggestions": [
    "Include examples from a wider range of geographical locations and cultures.",
    "Add scenarios that involve different types of travelers, such as solo travelers or groups with diverse needs.",
    "Incorporate edge cases or less common travel situations to balance the dataset."
  ],
  "skew_axes": [
    "geography",
    "domain",
    "other"
  ]
}
```

#### ⚠️ `safety.config.continuous_eval_missing` - No continuous evaluation rules configured

- **Severity:** `warning`
- **Category:** `responsible_ai`
- **Source:** `foundry_control`
- **WAF:** `ResponsibleAI` / `ContinuousEval` - [waf.rai.continuous_eval_missing](https://learn.microsoft.com/azure/ai-foundry/how-to/online-evaluation)

Foundry project lists 1 agent(s) but no continuous-evaluation rules. Production responses are not being scored on quality / safety after deployment.

**Recommendation:** Attach continuous evaluation rules to your agents in Foundry (Operate -> Evaluations) so deployed responses are scored against safety and quality metrics in production.

**Evidence:**

```json
{
  "layer": "config",
  "agents": [
    "travel-agent"
  ]
}
```

## Recent runs

| Run ID | Timestamp | Items pass | Run pass |
|---|---|---|---|
| `evalrun_c85d8f9b5d774b4a9a0cbd88d7bb7244` | 2026-06-22 05:27 | 8/8 | ✅ |
| `2026-06-22T05-27-19Z` | 2026-06-22 05:28 | 1/1 | ✅ |
| `evalrun_4926c4921f384f709755fe72f794ab2a` | 2026-06-22 08:26 | 6/6 | ✅ |
| `2026-06-22T08-26-44Z` | 2026-06-22 08:27 | 1/1 | ✅ |
| `evalrun_f165eb04402a45999c21f8bb0a2d9b32` | 2026-06-22 08:31 | 6/6 | ✅ |
| `2026-06-22T08-31-06Z` | 2026-06-22 08:32 | 1/1 | ✅ |
