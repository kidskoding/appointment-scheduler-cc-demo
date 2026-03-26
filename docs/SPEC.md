# Appointment Scheduling Agent — Spec

## What It Does
A web app where a user types a natural language scheduling request and an AI agent
autonomously handles the entire booking process.

## User Flow
1. User visits the homepage
2. User types a request: "Schedule a 30 min meeting with john@email.com next week"
3. Agent autonomously:
   - Reads the user's Google Calendar to find availability
   - Identifies the best open slot
   - Creates a calendar event
   - Sends an email invite to the other person
4. UI shows a live status feed of what the agent is doing
5. Agent confirms the booking with a summary

## Pages
- `/` — home page with a text input and live agent status feed
- `/appointments` — list of all scheduled appointments

## Data Model
### Appointment
- id
- request (string) — the original natural language request
- status (string) — pending, scheduled, failed
- summary (string) — agent's confirmation message
- scheduled_at (datetime)
- attendee_email (string)
- created_at / updated_at

## Agent Tools
1. `check_availability` — queries Google Calendar for free slots in a date range
2. `create_event` — creates a Google Calendar event
3. `send_invite` — sends an email invite via Gmail API

## Agent Loop
1. Parse the user's request to extract: attendee, duration, preferred time range
2. Call `check_availability` to find open slots
3. Pick the best slot
4. Call `create_event` to book it
5. Call `send_invite` to notify the attendee
6. Return a confirmation summary

## Error Handling
- If no availability found: return "No slots available, please try a different time range"
- If API fails: return a clear error message, do not crash

## What We Are NOT Building
- OAuth login flow (use a pre-configured service account)
- Recurring meetings
- Meeting cancellation