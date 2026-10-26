# Followthrough

A practitioner writes a short supplement care plan and needs to see whether the patient is keeping up. Followthrough is a small Rails app for that: sign in, add a patient, record a few supplements, and check the last seven days of adherence.

This is a portfolio demo with fictional data. It is not a medical product, it does not store real patient information, and it is not affiliated with Fullscript.

## Run it

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Open http://localhost:3000 and sign in as `practitioner@example.com` / `password`, or create your own account. `db:prepare` creates the database and, on a new database, loads the fictional patients. Run `bin/rails db:seed` any time you want that demo data back.

On Windows PowerShell, if `bin/rails` is not recognized, prefix the commands with Ruby: `ruby bin/rails db:prepare`, `ruby bin/rails db:seed`, and `ruby bin/rails server`.

This demo uses SQLite. Production-shaped apps in this space often use MySQL or PostgreSQL.

## Adherence

Adherence is doses taken divided by doses expected over the last 7 days, including today.

Expected doses are `times_per_day` multiplied by the number of days the plan was active in that window, summed across the supplements on the plan. Days before the start date do not count. A supplement taken once a day has a morning slot. A supplement taken twice a day has a morning slot and an evening slot. Only a slot marked taken counts as one dose. A missing or unmarked slot counts as zero.

The practitioner plan page shows the percentage, the dose counts, and a private check-in link (`/check-in/:token`). That page needs no login. It lists today's supplements for that plan only. Each dose recorded there updates the same adherence numbers.

`FollowUpJob` is a Solid Queue job. It sets `needs_follow_up` when that percentage is under 50%. The dashboard button runs the job immediately. To enqueue it instead:

```bash
bin/rails followthrough:enqueue_follow_ups
bin/jobs
```

In development, `bin/rails server` also starts the Solid Queue supervisor, so an enqueued job is picked up without a second terminal.

## Tests

```bash
bin/rails test
```

## Resume bullet

- Built Followthrough, a Ruby on Rails app where a practitioner writes a supplement care plan, a patient records each dose from a private link, and a Solid Queue job flags plans under 50% 7-day adherence.
