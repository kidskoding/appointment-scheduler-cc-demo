# Appointment Scheduling Agent — Workshop Demo

A live-coded workshop demo showing how to use **Claude Code** to build a full-stack AI agent app using **parallel subagents**. You will prompt Claude Code to build a Ruby on Rails app that lets users type a natural language scheduling request and have an AI agent autonomously book it on Google Calendar and send an email invite

---

## What You'll Build

A web app where a user types:

> "Schedule a 30 min meeting with john@email.com next week"

...and an AI agent:
1. Reads your Google Calendar to find availability
2. Picks the best open slot
3. Creates a calendar event
4. Sends an email invite to the other person
5. Shows a live status feed of every step in the browser

---

## The Key Concept: Parallel Subagents

The centerpiece of this workshop is the `/build` command in `.claude/commands/build.md`. Instead of building sequentially, it spins up **four specialized agents in parallel**:

| Agent | What it builds |
|---|---|
| `scaffolder` | Rails app, models, migrations, Gemfile |
| `agent-builder` | AI agent loop + Google Calendar/Gmail tools |
| `api-integrator` | Controllers, views, Hotwire live UI |
| `test-writer` | RSpec tests for everything |

Each agent has its own system prompt in `.claude/agents/` with scoped responsibilities and tool permissions. Running them in parallel cuts build time dramatically and demonstrates how Claude Code can orchestrate complex multi-part tasks.

---

## Project Structure

```
.
├── docs/
│   ├── SPEC.md          # What to build — the source of truth for all agents
│   └── BUILD.md         # How the parallel build orchestration works
├── .claude/
│   ├── commands/
│   │   └── build.md     # /build slash command — kicks off parallel agents
│   └── agents/
│       ├── scaffolder.md
│       ├── agent-builder.md
│       ├── api-integrator.md
│       └── test-writer.md
└── README.md
```

---

## Prerequisites

- [Claude Code](https://claude.ai/code) installed (`npm install -g @anthropic-ai/claude-code`)
- Ruby 3.2+ and Rails 8+
- PostgreSQL running locally
- An Anthropic API key (`ANTHROPIC_API_KEY`)
- Google Cloud project with Calendar and Gmail APIs enabled (service account credentials)

---

## Follow Along

### Step 1 — Clone this repo

```bash
git clone <repo-url>
cd appointment-scheduler-cc-demo
```

### Step 2 — Open Claude Code

```bash
claude
```

### Step 3 — Read the spec

Before running anything, open `docs/SPEC.md` and read it. This is the single source of truth that all four agents will work from. Understanding it helps you follow what the agents are doing.

### Step 4 — Run the build command

In the Claude Code prompt, type:

```
/build
```

This triggers `.claude/commands/build.md`, which reads the spec and dispatches four subagents in parallel. Watch the output — you'll see all four agents working simultaneously.

### Step 5 — Set your environment variables

Once the app is scaffolded, create a `.env` file:

```
ANTHROPIC_API_KEY=your_key_here
GOOGLE_CALENDAR_ID=your_calendar_id
GOOGLE_CREDENTIALS_PATH=path/to/service_account.json
GMAIL_FROM=you@example.com
```

### Step 6 — Start the server

```bash
cd appointment-agent
bundle exec rails db:create db:migrate
bundle exec rails server
```

Visit `http://localhost:3000` and try a request like:

> "Schedule a 1 hour meeting with alice@example.com on Friday afternoon"

---

## How the Agent Works

The agent loop lives in `app/services/scheduling_agent.rb` and uses the Anthropic Ruby SDK with tool use:

1. **Parse** the natural language request (attendee, duration, time range)
2. **`check_availability`** — queries Google Calendar for free slots
3. **Pick** the best slot
4. **`create_event`** — books the Google Calendar event
5. **`send_invite`** — sends an email via Gmail API
6. **Return** a plain English confirmation summary

The loop runs until the task is complete or an error occurs, streaming status updates to the UI via Turbo Frames.

---

## Key Files to Explore

After the build runs, explore these files to understand how everything connects:

- `app/services/scheduling_agent.rb` — the main agent loop
- `app/services/tools/` — the three tool definitions
- `app/controllers/appointments_controller.rb` — wires requests to the agent
- `app/views/appointments/index.html.erb` — the live UI with Turbo Frames
- `spec/` — RSpec tests with mocked external APIs

---

## Workshop Takeaways

- **Agents are just Claude with tools** — the loop is simple: call Claude, handle tool calls, repeat
- **Parallel subagents** are a powerful pattern for building complex things fast
- **Scoped agent prompts** keep each agent focused and prevent conflicts
- **The spec is the contract** — every agent reads from the same `SPEC.md`

---

## What We Are NOT Building (Scope)

- OAuth login flow (service account is pre-configured)
- Recurring meetings
- Meeting cancellation or rescheduling
