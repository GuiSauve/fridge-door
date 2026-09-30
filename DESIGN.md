# Design notes

The interesting decisions here are mostly about scoping and about what an
assistant should do unattended, not about code.

## Architecture

```
Gmail ───────────────┐
                     ▼
            Daily digest (routine, 1×/day) ──► Telegram group
                     │  ▲                       ▲
                     ▼  │                       │ confirmations
     Tracker doc (Claude Doc)   Shared Google Calendar
                     ▲  │                       ▲
                     │  ▼                       │
            Telegram intake (routine, hourly) ◄── Telegram group + DM
                (reminders, WhatsApp forwards, roster screenshots)
```

- **No server.** Each routine starts a fresh cloud session, does its job and
  exits. Routines keep no state between runs, so the tracker doc holds all
  durable state, including the last Telegram `update_id` processed.
- **Two routines, not one.** Email only needs checking once a day, but a
  reminder typed into the group should be picked up within the hour.

## Choices worth copying

- **Start narrow.** v1 only read Gmail. WhatsApp has no API for reading groups
  you don't run, and school portals mean handling passwords, which this
  deliberately never automates. Shipping the easy source first gave something
  useful on day one.
- **Telegram, not the WhatsApp Business API.** Telegram's bot API is free and
  official and takes two minutes to set up. WhatsApp Business needs Meta
  approval and costs money.
- **WhatsApp content by forwarding.** For a club that only uses WhatsApp,
  forward its messages to the bot's private DM. The routine judges them by
  content, so there's no command syntax to remember.
- **Precision over recall.** The Gmail label is visible in the inbox, so it
  only goes on mail judged genuinely relevant. When unsure, the routines skip
  the item: a missed item can be re-sent, while a wrong one is noise.
- **Silent unless something changed.** The hourly routine never posts
  "nothing new". An hourly no-op ping would get the bot muted.
- **Replies stay where the message came from.** Something forwarded in the DM
  gets its confirmation in the DM, never in the group.
- **Safe first run.** The first intake run only records where the chat
  history starts, so old test messages aren't treated as reminders.
- **Humans keep the irreversible steps.** No logins, no payments, no replying
  to schools. The assistant tracks and reminds; parents act.

## Calendar rules

The calendar answers one question: **when does the normal week change, or
when does someone have to be somewhere?** It is not a to-do list.

| Add to calendar | Keep out (Open Action Items only, or nowhere) |
|---|---|
| Closures: Studientag, school holidays, strikes | Deadlines: pay, sign, RSVP, bring X |
| Changed hours: early finish, different pickup | The regular weekly training |
| Events someone attends: parents' evening, trips, matches | Anything without a concrete date |
| Exceptions: training moved or cancelled | Anything the routine is unsure about |

- **Mixed messages.** "Trip on the 10th, pay €15 by the 3rd" becomes a
  calendar event on the 10th and an action item for the payment.
- **Emoji + kid in titles.** `🏫 Mia – School closed`, `⚽ Leo – Match`, so
  the calendar can be scanned on a phone.
- **No duplicates.** Before creating an event, the routine checks that date.
  Cancellations delete the event.
- **Explicit override.** "add to calendar: …" in Telegram always goes in.

## Shift rosters and clash hints

Many shift-planning apps (MyDuty, for example) have no API and no calendar
export. A screenshot of the month grid works well instead: the layout is fixed
and there are only five codes, so reading it is reliable.

- **Reconcile, don't append.** For the dates visible in a new screenshot, the
  routine updates changed shifts and deletes shifts that became days off.
  Re-sending a roster is always safe.
- **Read-back reply.** The bot answers with what it read ("Day 2–4 · Eve 7–9
  · Night 23–24"), so a misread is caught straight away.
- **Clash hints.** The daily digest compares the next 3 days of shifts with
  training times and calendar events: "⚠️ Tue – evening shift vs. training
  16:00: who takes them?" It only flags what it actually knows about. Plain
  school days aren't on the calendar, so they aren't guessed at.

## Known limits

- Parent portals that only email "you have a new message" can be flagged but
  not summarized. Their content sits behind a login.
- Screenshot reading can misread a cell. That's why the read-back exists.
- Cron runs in UTC, so a fixed evening time shifts by an hour when the clocks
  change unless you adjust it.
