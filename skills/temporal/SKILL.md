---
name: temporal
description: Manage Temporal workflows, schedules, and development server via the `temporal` CLI. Use when the user wants to list, describe, start, signal, cancel, or terminate workflows, manage schedules, inspect task queues, or run a local dev server.
---

# Temporal CLI

Manage Temporal workflows, schedules, and development server via the `temporal` command line tool.

## Installation Check

**IMPORTANT**: Before using any `temporal` commands, verify the CLI is installed:

```bash
temporal --version
```

If not installed, guide the user to install:

```bash
brew install temporal
```

## Quick Reference

```bash
# List workflows
temporal workflow list

# Describe a workflow
temporal workflow describe -w <workflow-id>

# Start a workflow
temporal workflow start --task-queue <queue> --type <WorkflowType>

# Execute a workflow (start + wait for result)
temporal workflow execute --task-queue <queue> --type <WorkflowType>

# Signal a workflow
temporal workflow signal -w <workflow-id> --name <signal-name>

# Query a workflow
temporal workflow query -w <workflow-id> --name <query-name>

# Cancel a workflow
temporal workflow cancel -w <workflow-id>

# Terminate a workflow
temporal workflow terminate -w <workflow-id>

# Show event history
temporal workflow show -w <workflow-id>

# Trace workflow execution live
temporal workflow trace -w <workflow-id>
```

## Workflows

### Listing

```bash
# List all workflows
temporal workflow list

# Filter with a visibility query
temporal workflow list --query 'WorkflowType="MyWorkflow" AND ExecutionStatus="Running"'

# Limit results
temporal workflow list --limit 10

# JSON output for parsing
temporal workflow list -o json
```

### Starting

```bash
# Start a workflow
temporal workflow start \
  --task-queue my-queue \
  --type MyWorkflow \
  --workflow-id my-unique-id

# With input (JSON)
temporal workflow start \
  --task-queue my-queue \
  --type MyWorkflow \
  --input '{"key": "value"}'

# Execute and wait for result
temporal workflow execute \
  --task-queue my-queue \
  --type MyWorkflow
```

### Inspecting

```bash
# Describe workflow details
temporal workflow describe -w <workflow-id>

# Show auto-reset points
temporal workflow describe -w <workflow-id> --reset-points true

# Show full event history
temporal workflow show -w <workflow-id>

# Get workflow result (waits if still running)
temporal workflow result -w <workflow-id>

# Live execution trace
temporal workflow trace -w <workflow-id>

# Query workflow state
temporal workflow query -w <workflow-id> --name <query-name>

# Get workflow stack trace
temporal workflow stack -w <workflow-id>
```

### Controlling

```bash
# Signal a running workflow
temporal workflow signal -w <workflow-id> --name <signal-name> --input '{"key": "value"}'

# Cancel (graceful)
temporal workflow cancel -w <workflow-id>

# Terminate (forceful)
temporal workflow terminate -w <workflow-id> --reason "reason"

# Reset to a previous point
temporal workflow reset -w <workflow-id> --event-id <id>

# Pause/unpause (experimental)
temporal workflow pause -w <workflow-id>
temporal workflow unpause -w <workflow-id>
```

## Schedules

```bash
# List schedules
temporal schedule list

# Describe a schedule
temporal schedule describe --schedule-id <id>

# Create a schedule
temporal schedule create \
  --schedule-id my-schedule \
  --workflow-type MyWorkflow \
  --task-queue my-queue \
  --interval '1h'

# Pause/unpause
temporal schedule toggle --schedule-id <id> --pause --reason "maintenance"
temporal schedule toggle --schedule-id <id> --unpause

# Trigger immediately
temporal schedule trigger --schedule-id <id>

# Delete
temporal schedule delete --schedule-id <id>
```

## Activities

```bash
# Complete an activity manually
temporal activity complete \
  --activity-id <id> \
  --workflow-id <wf-id> \
  --result '{"key": "value"}'

# Fail an activity
temporal activity fail \
  --activity-id <id> \
  --workflow-id <wf-id> \
  --reason "reason"

# Pause/unpause
temporal activity pause --activity-id <id> --workflow-id <wf-id>
temporal activity unpause --activity-id <id> --workflow-id <wf-id>
```

## Task Queues

```bash
# Describe a task queue (shows pollers, backlog, rates)
temporal task-queue describe --task-queue <name>

# JSON output to see poller identities and stats
temporal task-queue describe --task-queue <name> -o json

# Get reachability info
temporal task-queue get-build-id-reachability --task-queue <name>
```

The describe output includes active pollers (worker identities), task types (workflow/activity), backlog counts, and dispatch rates.

## Batch Operations

Run commands against multiple workflows matching a query:

```bash
# Cancel all running workflows of a type
temporal workflow cancel \
  --query 'ExecutionStatus="Running" AND WorkflowType="MyWorkflow"' \
  --reason "Batch cancel"

# Terminate matching workflows
temporal workflow terminate \
  --query 'ExecutionStatus="Running" AND TaskQueue="my-queue"' \
  --reason "Cleanup"

# List batch jobs
temporal batch list

# Describe a batch job
temporal batch describe --job-id <id>

# Terminate a batch job
temporal batch terminate --job-id <id> --reason "reason"
```

## Operator Commands

### Cluster

```bash
# Describe cluster (server version, supported clients)
temporal operator cluster describe

# Health check
temporal operator cluster health
```

### Namespaces

```bash
# List namespaces
temporal operator namespace list

# Describe a namespace
temporal operator namespace describe -n <name>

# Create a namespace
temporal operator namespace create <name>
```

### Search Attributes

```bash
# List all search attributes and their types
temporal operator search-attribute list

# Add a custom search attribute
temporal operator search-attribute create --name MyAttr --type Keyword
```

Available types: `Bool`, `Datetime`, `Double`, `Int`, `Keyword`, `KeywordList`, `Text`.

## Workers

```bash
# List workers (experimental)
temporal worker list

# Describe a specific worker (experimental)
temporal worker describe --task-queue <name> --build-id <id>

# Worker deployments
temporal worker deployment list
```

## Environments

Environments store connection settings for different Temporal clusters:

```bash
# List environments
temporal env list

# Set a property
temporal env set <env-name>.<property> <value>

# Example: configure a cloud environment
temporal env set prod.address <namespace>.tmprl.cloud:7233
temporal env set prod.namespace <namespace>
temporal env set prod.tls-cert-path /path/to/cert.pem
temporal env set prod.tls-key-path /path/to/key.pem

# Use an environment
temporal workflow list --env prod
```

## Development Server

Start a local Temporal server for development:

```bash
# Start dev server (default: gRPC on 7233, UI on 8233)
temporal server start-dev

# With persistence
temporal server start-dev --db-filename temporal.db

# Custom ports
temporal server start-dev --port 7234 --ui-port 8234
```

Web UI is available at http://localhost:8233 by default.

## Common Options

Most commands accept these flags:

- `--address` — Temporal server endpoint (default: `localhost:7233`)
- `--namespace` / `-n` — Namespace (default: `default`)
- `--env` — Named environment to use
- `--output` / `-o` — Output format: `text`, `json`, `jsonl`, `none`
- `--tls` — Enable TLS
- `--api-key` — API key for Temporal Cloud

## Visibility Queries

Filter workflows with SQL-like queries using `--query` / `-q`:

```bash
# By type
temporal workflow list -q 'WorkflowType="MyWorkflow"'

# By status
temporal workflow list -q 'ExecutionStatus="Running"'
temporal workflow list -q 'ExecutionStatus="Failed"'
temporal workflow list -q 'ExecutionStatus="Terminated"'

# By task queue
temporal workflow list -q 'TaskQueue="my-queue"'

# Combined
temporal workflow list -q 'WorkflowType="MyWorkflow" AND ExecutionStatus="Running" AND StartTime > "2024-01-01"'

# Count matching workflows
temporal workflow count -q 'ExecutionStatus="Running"'

# Count all workflows
temporal workflow count
```

**Query syntax**: `=`, `!=`, `>`, `>=`, `<`, `<=`, `IN (values)`, `BETWEEN x AND y`, `STARTS_WITH`, `IS NULL`, `IS NOT NULL`, `AND`, `OR`, `( )`.

**Common fields**: `WorkflowId`, `WorkflowType`, `ExecutionStatus`, `StartTime`, `CloseTime`, `ExecutionTime`, `TaskQueue`, `RunId`, `HistoryLength`, `ExecutionDuration`, `BuildIds`.

**ExecutionStatus values**: `Running`, `Completed`, `Failed`, `Canceled`, `Terminated`, `ContinuedAsNew`, `TimedOut`.

Use `temporal operator search-attribute list` to see all available fields.
