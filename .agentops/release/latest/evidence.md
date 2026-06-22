# AgentOps Release Evidence

**Production readiness:** ⚠️ `ready_with_warnings`

- **Generated:** 2026-06-22T11:32:09.031427+00:00
- **Workspace:** `/home/ayoola/agentops`
- **Target:** `travel-agent:2`

## Warnings

- ⚠️ No baseline comparison was found; capture a known-good results.json before promoting production releases.
- ⚠️ No AgentOps PR gate workflow was found.
- ⚠️ No AgentOps deploy workflow was found for dev/qa/prod promotion.
- ⚠️ Doctor reported warnings that should be reviewed before production.
- ⚠️ Foundry control-plane is reachable, but no enabled continuous evaluation rule was detected.
- ⚠️ Application Insights / Azure Monitor readiness is unknown; production traces and runtime metrics may not be available.
- ⚠️ Foundry observability evidence is incomplete: intelligent trace sampling, trace replay link
- ⚠️ No production trace regression dataset was found yet; harvest reviewed traces to turn production issues into regression tests.

## Ready signals

- ✅ Latest evaluation passed configured thresholds.
- ✅ Explicit production thresholds are declared in agentops.yaml.
- ✅ Foundry control-plane source is reachable.
- ✅ Configured governance artifacts are present and evidence-ready.

## Doctor finding summary

**Findings:** 8 (6 warning · 2 info)

1. **warning** [operational excellence] `observability.trace_sampling_missing` - Intelligent trace sampling is not evidence-ready
2. **warning** [operational excellence] `opex.max_tokens_undefined` - Output token limit is not set on model / evaluator configuration
3. **warning** [operational excellence] `opex.release.no_continuous_eval` - No enabled Foundry continuous evaluation rule is attached
4. **warning** [reliability] `errors.no_runtime_telemetry` - Production telemetry is not wired to the agent
5. **warning** [responsible ai] `responsible_ai.llm.dataset_bias_signals` - [LLM-judged] Evaluation dataset shows distribution skew
6. **warning** [responsible ai] `safety.config.continuous_eval_missing` - No continuous evaluation rules configured
7. **info** [operational excellence] `observability.trace_replay_missing` - Trace replay link is not captured in release evidence
8. **info** [operational excellence] `opex.release.no_trace_regression_dataset` - Production traces are not feeding a regression dataset yet

## Readiness checks

| Check | Status | Summary |
|---|---|---|
| Latest eval gate | ✅ `ready` | Latest evaluation passed configured thresholds. |
| Threshold policy | ✅ `ready` | Explicit production thresholds are declared in agentops.yaml. |
| Regression baseline | ⚠️ `warning` | No baseline comparison was found; capture a known-good results.json before promoting production releases. |
| PR gate | ⚠️ `warning` | No AgentOps PR gate workflow was found. |
| Deploy workflows | ⚠️ `warning` | No AgentOps deploy workflow was found for dev/qa/prod promotion. |
| Doctor readiness | ⚠️ `warning` | Doctor reported warnings that should be reviewed before production. |
| Foundry continuous evaluation | ⚠️ `warning` | Foundry control-plane is reachable, but no enabled continuous evaluation rule was detected. |
| Runtime monitoring | ⚠️ `warning` | Application Insights / Azure Monitor readiness is unknown; production traces and runtime metrics may not be available. |
| Foundry observability | ⚠️ `warning` | Foundry observability evidence is incomplete: intelligent trace sampling, trace replay link |
| Trace-to-dataset flywheel | ⚠️ `warning` | No production trace regression dataset was found yet; harvest reviewed traces to turn production issues into regression tests. |
| AI Landing Zone readiness | ❔ `unknown` | No AI Landing Zone signals were detected for this workspace. |
| Governance artifacts | ✅ `ready` | Configured governance artifacts are present and evidence-ready. |
