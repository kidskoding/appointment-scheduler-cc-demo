---
description: Builds the full appointment scheduling Rails app using parallel subagents
allowed-tools: Read, Bash, Task
---

Read SPEC.md and CLAUDE.md first.

Then kick off all four subagents in parallel using the Task tool:

1. Use the `scaffolder` agent to scaffold the Rails app, models, and migrations
2. Use the `agent-builder` agent to build the AI agent loop and tool definitions
3. Use the `api-integrator` agent to build controllers, views, and routes
4. Use the `test-writer` agent to write RSpec tests

Once all agents report back:
- Run `bundle exec rspec` to verify tests pass
- Run `rails s` to start the server
- Report a summary of everything that was built