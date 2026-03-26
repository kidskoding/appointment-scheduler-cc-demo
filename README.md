# Appointment Scheduling Agent — Workshop Demo

A live-coded workshop demo showing how to use **Claude Code** to build a full-stack AI agent app checkpoint by checkpoint. You will prompt Claude Code to build a Ruby on Rails app that lets users type a natural language scheduling request and have an AI agent autonomously book it on Google Calendar.

---

## What You'll Build

A web app where a user types:

> "Schedule a 30 min meeting with john@email.com next week"

...and an AI agent:
1. Reads your Google Calendar to find availability
2. Picks the best open slot
3. Creates a calendar event
4. Shows a live status feed of every step in the browser
5. Confirms the booking with a summary

---

## How the Workshop Works

The build is broken into **5 phases**, each leaving the app in a runnable state. You use the `/scaffold` command to build one checkpoint at a time — Claude reads `docs/TASKS.md`, implements the next task, verifies it works, and stops.

| Phase | Checkpoint | What you can test |
|---|---|---|
| 1 | Rails foundation | App boots at `localhost:3000` *(pre-built)* |
| 2 | Basic UI | Form works, appointments save to DB *(pre-built)* |
| 3 | Agent tools | Calendar availability + event creation |
| 4 | Agent loop | Full agent runs end-to-end |
| 5 | Integration | Form → agent → calendar → UI |

Phases 1 and 2 are pre-built so you can jump straight into the AI parts.

---

## Project Structure

```
.
├── docs/
│   ├── SPEC.md          # What to build — the source of truth
│   ├── TASKS.md         # Incremental checkpoint plan
│   └── BUILD.md         # How the orchestration works
├── .claude/
│   ├── commands/
│   │   └── build.md     # /build slash command
│   └── agents/
│       ├── scaffolder.md
│       ├── agent-builder.md
│       ├── api-integrator.md
│       └── test-writer.md
├── .env.example         # Copy to .env and fill in your credentials
├── docker-compose.yml   # Dev environment
└── Dockerfile.dev       # Dev container
```

---

## Prerequisites

- [Claude Code](https://claude.ai/code) installed (`npm install -g @anthropic-ai/claude-code`)
- Docker and Docker Compose
- `.env` file provided by the workshop instructor

---

## Getting Started

### Step 1 — Clone this repo

```bash
git clone <repo-url>
cd appointment-scheduler-cc-demo
```

### Step 2 — Set up credentials

Copy `.env.example` to `.env` and fill in the values provided by the instructor:

```bash
cp .env.example .env
```

```
ANTHROPIC_API_KEY=...
GOOGLE_CREDENTIALS_PATH=path/to/service_account.json
GOOGLE_CALENDAR_ID=...
```

### Step 3 — Start the app

```bash
docker-compose up
```

First run will take a minute to build the image. Once it's up, run migrations:

```bash
docker-compose run --rm web rails db:create db:migrate
```

Visit `http://localhost:3000` — you should see the scheduling form.

### Step 4 — Open Claude Code

In a new terminal, from the repo root:

```bash
claude
```

### Step 5 — Read the spec

Before building anything, read `docs/SPEC.md`. It's the single source of truth that drives the entire build.

### Step 6 — Build checkpoint by checkpoint

In the Claude Code prompt, type:

```
/scaffold
```

Claude will find the next incomplete task in `docs/TASKS.md`, implement it, verify the app still runs, and stop. Repeat after each checkpoint:

```
/scaffold   ← Phase 3: Calendar tools (built in parallel)
/scaffold   ← Phase 4: agent loop
/scaffold   ← Phase 5: full end-to-end
```

### Step 7 — Try it

After Phase 5, submit a request at `http://localhost:3000`:

> "Schedule a 1 hour meeting with alice@example.com on Friday afternoon"

---

## Running Tests

```bash
docker-compose run --rm web bundle exec rspec
```

---

## How the Agent Works

The agent loop lives in `app/services/scheduling_agent.rb` and uses the Anthropic Ruby SDK with tool use:

1. **Parse** the natural language request (attendee, duration, time range)
2. **`check_availability`** — queries Google Calendar for free slots
3. **Pick** the best slot
4. **`create_event`** — books the Google Calendar event
5. **`send_invite`** — logs the invite (mocked, no real email sent)
6. **Return** a plain English confirmation summary

The loop runs until the task is complete or an error occurs.

---

## Key Files to Explore

After the build is complete:

- `app/services/scheduling_agent.rb` — the main agent loop
- `app/services/tools/` — the three tool definitions
- `app/controllers/appointments_controller.rb` — wires requests to the agent
- `app/views/appointments/index.html.erb` — the UI

---

## Workshop Takeaways

- **Agents are just Claude with tools** — the loop is simple: call Claude, handle tool calls, repeat
- **Checkpoint-based building** keeps the app runnable at every step
- **Parallel subagents** — Phase 3 tools are built simultaneously, not sequentially
- **The spec is the contract** — every agent reads from the same `docs/SPEC.md`

---

## What We Are NOT Building (Scope)

- OAuth login flow (service account is pre-configured)
- Real email sending (invite tool is mocked)
- Recurring meetings
- Meeting cancellation or rescheduling
