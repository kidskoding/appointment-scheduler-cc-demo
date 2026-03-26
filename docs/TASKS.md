# TASKS.md

This file defines the incremental implementation tasks for the Appointment Scheduling Agent.

Claude should only complete **one task at a time** and should not attempt to implement future tasks unless required for scaffolding.

Each task should leave the application in a **runnable state**.

---

# Phase 1 — Rails Foundation

## Task 1.1 — Scaffold the Rails app

Create the base Rails application with PostgreSQL and install required gems.

Requirements:

- Run `rails new appointment-agent --database=postgresql --skip-test`
- Add gems to Gemfile: `anthropic`, `google-apis-calendar_v3`, `dotenv-rails`
- Run `bundle install`
- Run `rails db:create`

Expected outcomes:

- `rails s` starts without errors
- App is accessible at `http://localhost:3000`

---

## Task 1.2 — Create the Appointment model and migration

Generate the Appointment model with all fields from the spec.

Requirements:

- Generate migration with fields: `request:string`, `status:string`, `summary:text`, `scheduled_at:datetime`, `attendee_email:string`
- Set default status to `pending` in the migration
- Run `rails db:migrate`

Expected outcomes:

- `rails db:migrate` runs cleanly
- `Appointment.new` works in `rails console`
- `Appointment.column_names` includes all fields

---

# Phase 2 — Basic UI

## Task 2.1 — Wire up routes, controller, and index page

Create the appointments controller and a basic homepage with a form.

Requirements:

- Set `appointments#index` as root route
- Add `POST /appointments` route mapped to `appointments#create`
- Create `app/controllers/appointments_controller.rb` with `index` and `create` actions
- `index` loads all appointments ordered by `created_at desc`
- `create` creates an Appointment record with status `pending` and redirects to root
- Create `app/views/appointments/index.html.erb` with a text input form and a list of past appointments
- Create `app/views/appointments/_appointment.html.erb` partial for a single appointment card showing request, status, scheduled_at, and summary

Expected outcomes:

- Visiting `http://localhost:3000` renders the form
- Submitting the form creates an Appointment record and redirects back
- Past appointments appear below the form

---

# Phase 3 — Agent Tools

## Task 3.1 — Build the check_availability tool

Create the service that queries Google Calendar for free slots.

Requirements:

- Create `app/services/tools/check_availability.rb`
- Authenticate using service account credentials from `ENV['GOOGLE_CREDENTIALS_PATH']`
- Accept `date_range_start` and `date_range_end` as inputs (ISO8601 strings)
- Query `ENV['GOOGLE_CALENDAR_ID']` for existing events in that range
- Return a list of free 30-minute slots as an array of `{ start:, end: }` hashes
- Handle API errors gracefully — return an empty array on failure

Expected outcomes:

- Calling `Tools::CheckAvailability.call(date_range_start:, date_range_end:)` returns an array
- Does not raise on missing credentials — returns empty array with logged error

---

## Task 3.2 — Build the create_event tool

Create the service that books a Google Calendar event.

Requirements:

- Create `app/services/tools/create_event.rb`
- Accept `title`, `start_time`, `end_time`, `attendee_email` as inputs
- Create a Google Calendar event on `ENV['GOOGLE_CALENDAR_ID']`
- Return the created event ID on success
- Handle API errors gracefully — return nil on failure

Expected outcomes:

- Calling `Tools::CreateEvent.call(...)` returns a non-nil event ID when credentials are valid
- A new event appears on the calendar

---

## Task 3.3 — Build the send_invite tool (mocked)

Create a mocked send_invite tool that logs instead of sending real email.

Requirements:

- Create `app/services/tools/send_invite.rb`
- Accept `attendee_email`, `event_title`, `start_time` as inputs
- Log the invite details to Rails logger (do not send real email)
- Return `{ success: true, message: "Invite sent to #{attendee_email}" }`

Expected outcomes:

- Calling `Tools::SendInvite.call(...)` returns a success hash
- Rails log shows the invite details

---

# Phase 4 — Agent Loop

## Task 4.1 — Build the scheduling agent

Create the main agent loop using the Anthropic Ruby SDK with tool use.

Requirements:

- Create `app/services/scheduling_agent.rb`
- Accept a plain English `request` string as input
- Use `claude-sonnet-4-20250514` with tool use via the `anthropic` gem
- Define all three tools (`check_availability`, `create_event`, `send_invite`) with proper input schemas
- Loop until the agent returns a final text response or an error occurs
- Dispatch tool calls to the corresponding service classes in `app/services/tools/`
- Return a plain English confirmation or error message string

Expected outcomes:

- `SchedulingAgent.new(request: "Schedule a 30 min meeting with alice@example.com next week").run` returns a string
- Agent calls tools in the correct order
- No unhandled exceptions on API errors

---

# Phase 5 — Full Integration

## Task 5.1 — Wire the agent into the controller with live status updates

Connect the agent to the create action and show live status in the UI.

Requirements:

- Update `appointments#create` to call `SchedulingAgent.new(request:).run` after creating the Appointment record
- Update the Appointment record with `status: "scheduled"`, `summary:`, and `scheduled_at:` from the agent response
- On failure, set `status: "failed"` and store the error in `summary`
- Update `app/views/appointments/index.html.erb` to show the agent's summary and the scheduled time on each appointment card
- Show status as a badge: pending (grey), scheduled (green), failed (red)

Expected outcomes:

- Submitting a request runs the full agent loop
- The appointment record is updated with the result
- The UI shows the correct status and summary after redirect
- A calendar event exists on Google Calendar after a successful booking

---
