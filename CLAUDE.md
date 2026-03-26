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

## Environment Variables Required
- ANTHROPIC_API_KEY
- GOOGLE_CLIENT_ID
- GOOGLE_CLIENT_SECRET
- GOOGLE_REFRESH_TOKEN

## Commands
- `rails s` — start server
- `bundle exec rspec` — run tests
- `rails db:migrate` — run migrations