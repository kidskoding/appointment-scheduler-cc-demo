# Appointment Scheduling Agent

## Project Overview
A Ruby on Rails app with an AI agent that schedules appointments via natural language.
The user types something like "Schedule a 30 min meeting with John next week" and the agent
autonomously checks calendar availability, finds a slot, and sends an invite.

## Tech Stack
- Ruby on Rails 7
- PostgreSQL
- Claude API (claude-sonnet-4-20250514) for the agent loop
- Google Calendar API for reading/writing events
- Gmail API for sending invites
- Hotwire/Turbo for live UI updates

## Agent Architecture
The core agent loop lives in `app/services/scheduling_agent.rb`.
It uses tool use to call Google Calendar and Gmail autonomously.
Tools are defined in `app/services/tools/`.

## Conventions
- Services go in `app/services/`
- Agent tools go in `app/services/tools/`
- Keep controllers thin — all logic in services
- Use environment variables for all API keys (never hardcode)
- Write RSpec tests for all agent logic

## Authentication
Google Calendar access uses a **service account**. The JSON key file is provided by the workshop instructor.
Gmail invites are mocked in this demo — no real email is sent.

## Environment Variables Required
- ANTHROPIC_API_KEY
- GOOGLE_CREDENTIALS_PATH — path to the service account JSON key file
- GOOGLE_CALENDAR_ID — the calendar to read/write events on

## Commands
- `rails s` — start server
- `bundle exec rspec` — run tests
- `rails db:migrate` — run migrations

## Parallel Subagent Rules

When executing tasks from `docs/TASKS.md`, always analyze dependencies before starting and dispatch independent tasks as parallel subagents using the Agent tool.

**Rules:**
- If 2+ tasks have no shared files and no sequential dependency, dispatch them as parallel Agent tool calls in a single message
- If a task depends on another (e.g. needs a migration to exist, or a service to be built first), run the dependency first, then parallelize what remains
- Always pass full context to each subagent: working directory, Ruby version (`RBENV_VERSION=3.3.8`), what already exists, and exactly what to build
- Each subagent must verify its own work (run tests or a rails runner check) before returning

**Agent routing — always use the matching custom agent:**
- `scaffolder` → Tasks 1.1, 1.2, 2.1 (models, migrations, routes, controller/view stubs)
- `test-writer` → Tasks 1.3, 2.2, 3.4, 4.2, 5.2 (all RSpec tests)
- `agent-builder` → Tasks 3.1, 3.2, 3.3, 4.1 (tools and agent loop in app/services/)
- `api-integrator` → Task 5.1 (controller logic, views, Hotwire integration)

**Dependency map for this project:**
- 1.1 → must be first
- 1.2 → requires 1.1
- 1.3, 2.1 → can run in parallel after 1.2
- 2.2 → requires 2.1
- 3.1, 3.2, 3.3 → fully independent, always run in parallel
- 3.4 → requires 3.1, 3.2, 3.3
- 4.1 → requires 3.1, 3.2, 3.3
- 4.2 → requires 4.1
- 5.1 → requires 4.1 and 2.1
- 5.2 → requires 5.1