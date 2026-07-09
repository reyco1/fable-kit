---
name: stack-verification
description: TEMPLATE - concrete verification recipes for this team's real integration surfaces (workflow engines, CRMs, webhooks, queues, data warehouses). Use whenever work touches an external system integration and "self-validate everything" needs to become runnable steps - before declaring any integration change done, when testing workflow executions, CRM writebacks, webhook handling, or before running potentially expensive warehouse queries. Each team must fill in its own recipes; placeholder recipes below show the required shape.
---

# Stack Verification (Template)

Generic self-review says "run it." This skill says exactly HOW to run it for THIS team's stack. It ships as a template: replace the placeholder recipes with your real systems, commands, and fixtures. A recipe that can't be executed verbatim is not finished.

## Recipe format (every entry follows this shape)
```markdown
### <Surface>: <verification name>
When: <which changes require this check>
Preconditions: <env, credentials location (by reference, never inline), fixtures>
Steps: <exact commands / API calls / UI-free procedure>
Expected: <observable pass condition>
On failure: <first diagnostic to run; link to known gotchas in the wiki>
Cost/safety notes: <rate limits, spend, side effects, cleanup>
```

## Placeholder recipes (replace with your stack)

### Workflow engine: end-to-end run with sample payload
When: any change to a workflow, trigger, or node configuration.
Preconditions: staging/test workflow environment; fixture payloads in `fixtures/` (sanitized - no real customer data).
Steps: trigger the workflow's test execution with `fixtures/<case>.json`; watch the run to completion.
Expected: run completes without error; each branch taken matches the fixture's intent; downstream side effects appear (see CRM recipe).
On failure: pull the failing node's input/output; diff against the fixture's expected shape.
Cost/safety: ensure test mode - no messages to real recipients.

### CRM: writeback verification
When: any change that creates or updates CRM records.
Preconditions: sandbox/test CRM object or clearly marked test record; API credentials by reference.
Steps: execute the change against the test record; fetch the record back via API.
Expected: fields updated with correct values AND types; timeline/activity entry present if the integration writes one; no duplicate records created.
On failure: check property name/type mapping first - it is the most common cause.
Cost/safety: never verify against real customer records; clean up created test records.

### Webhook / queue: replay and idempotency
When: any change to webhook handlers or queue consumers.
Preconditions: captured sample events in `fixtures/events/`; local or staging consumer.
Steps: replay the sample event; then replay the SAME event a second time.
Expected: first delivery processes correctly; second delivery is handled idempotently (no duplicate side effects); malformed-event fixture is rejected without crashing the consumer.
On failure: check signature verification and dedup key logic before business logic.
Cost/safety: replays must target non-production consumers.

### Data warehouse: cost guard before large queries
When: any new or modified query against large tables.
Steps: dry-run / EXPLAIN the query to get scan estimate BEFORE executing; compare against the team's scan budget per query.
Expected: estimated scan within budget; partitions/clustering actually pruning (estimate far below full-table size).
On failure: add partition filters; select needed columns only; consider a pre-aggregated table.
Cost/safety: never run an unestimated query against production-scale tables.

## Team customization checklist
- [ ] Replace each placeholder with real system names, commands, credential references, and fixture paths.
- [ ] Add recipes for surfaces not covered here (payments, telephony, EHR/domain APIs, file transfer, auth provider...).
- [ ] Source known gotchas from the knowledge wiki; link recipes to the relevant concept articles.
- [ ] Store fixtures sanitized - no secrets, no real personal data, ever.
- [ ] Re-run this checklist whenever a new integration enters the stack.

## Relationship to self-review
self-review step 1 is "run it." When the change touches an integration surface, "run it" means executing the matching recipe here. If no recipe exists for a surface you're touching, writing one IS part of the task - append it to this skill.
