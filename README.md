# fridge-door

The notes on your fridge door, handled for you. A starter kit for a small assistant that keeps two parents on top of school / kita (daycare) /
after-school care / sports-club logistics. No server and no code to deploy.
It runs as two scheduled Claude Code **routines** (cloud agents), and you talk
to it through a Telegram bot.

What it does once set up:

- **Daily digest (evening).** Scans Gmail for school/kita/club mail, summarizes
  what's new, tracks deadlines in a shared tracker doc, labels relevant mail,
  and posts one short message to a Telegram group shared by both parents.
- **Telegram intake (hourly).** Picks up reminders ("remind us to pay the club
  fee by Friday"), forwarded WhatsApp messages (clubs that only use WhatsApp),
  and screenshots of a shift roster, and files each in the right place.
- **Shared Google Calendar.** Key dates only (closures, early pickups,
  events, matches), never to-dos. Rules for what goes in are in
  [DESIGN.md](DESIGN.md#calendar-rules).
- **Shift-work clash hints (optional).** If one parent works shifts, a
  screenshot of their roster becomes calendar events, and the digest warns
  about clashes like "evening shift vs. training at 16:00: who takes them?".

See [DESIGN.md](DESIGN.md) for why it's built this way.

## Easiest way to set it up

Open [Claude Code](https://claude.com/claude-code) in this folder and say:

> Help me set up this starter kit for my family. Walk me through the
> checklist in README.md step by step and fill the placeholders in a
> private copy.

It can create the routines for you (via `/schedule`), read your tracker doc to
find its IDs, and test the Telegram bot. The manual checklist is below if you
prefer to do it yourself.

## What you need

- A Claude plan with Claude Code routines, and these connectors enabled at
  claude.ai → Settings → Connectors: **Gmail**, **Google Calendar**,
  **Claude Docs**.
- A Telegram account (both parents).
- About an hour.

## Setup checklist

Keep your filled-in prompts in `private/`, which is git-ignored. Don't edit
the templates in `routines/` directly if you plan to share your fork.

1. **Telegram bot.** In Telegram, message `@BotFather` → `/newbot` → copy the
   token (`{{BOT_TOKEN}}`). Then `/setprivacy` → your bot → **Disable**, so the
   bot sees plain messages in groups, not just `/commands`.
2. **Chats.** Create a group with your co-parent and add the bot
   (`{{GROUP_NAME}}`). Also open a private chat with the bot and send `/start`;
   that DM is where you forward WhatsApp messages and roster screenshots
   without cluttering the group. Send one message in each, then open
   `https://api.telegram.org/bot<token>/getUpdates` in a browser and note the
   two `chat.id` values: the group (negative number, `{{GROUP_CHAT_ID}}`) and
   the DM (`{{DM_CHAT_ID}}`).
3. **Google Calendar.** Create a calendar (e.g. "Family Org"), share it with
   your co-parent ("Make changes to events"), and copy its ID from Settings →
   *Integrate calendar* (`{{CALENDAR_ID}}`, ends in
   `@group.calendar.google.com`).
4. **Tracker doc.** Create a Claude Doc from
   [tracker-doc-template.md](tracker-doc-template.md). Ask Claude Code to read
   it and tell you its container ID (`{{TRACKER_DOC_ID}}`) and tab node ID
   (`{{TRACKER_TAB_ID}}`).
5. **Gmail label.** Create a label called `FamilyOrg`.
6. **Cloud environment.** At claude.ai/code, create an environment with
   *custom* network access that allowlists only `api.telegram.org`. The
   routines need nothing else from the open internet.
7. **Fill the placeholders.** Copy both files from `routines/` into `private/`
   and replace every `{{…}}` (table below). Delete sections you don't need,
   such as the soccer block or the shift-roster rules.
8. **Create the routines** (claude.ai/code/routines, or `/schedule` in Claude
   Code). Cron expressions are in **UTC**.

   | Routine | Schedule | Tools | Connectors |
   |---|---|---|---|
   | Daily digest | once a day, e.g. `0 17 * * *` (19:00 in Berlin during summer time) | Bash | Claude Docs, Gmail, Google Calendar |
   | Telegram intake | hourly, e.g. `17 * * * *` | Bash, Read | Claude Docs, Google Calendar |

   Both use the environment from step 6. **Read** lets the intake routine view
   roster screenshots.
9. **First run.** Run the intake routine once by hand. Because the tracker doc
   says `uninitialized`, it only records where the chat history starts and
   stays silent. After that, send "remind us to test this tomorrow" to the
   group, run it again, and you should get a confirmation.

## Placeholders

| Placeholder | What it is | Example |
|---|---|---|
| `{{PARENT_1}}`, `{{PARENT_2}}` | Parent first names; `PARENT_2` is the one with the shift roster | Alex, Sam |
| `{{CHILD_1}}`, `{{CHILD_2}}` | Kids' first names (`CHILD_1` has school + after-school care, `CHILD_2` has kita) | Mia, Leo |
| `{{CHILD_1_TRAINING}}`, `{{CHILD_2_TRAINING}}` | Regular training slot | Tue 16:00 |
| `{{SCHOOL_NAME}}`, `{{SCHOOL_DOMAIN}}` | School name and its email domain | Lindenschule, lindenschule.de |
| `{{TEACHER_EMAIL}}` | Part of the teacher's address to match on | m.schmidt |
| `{{AFTERCARE_DOMAIN}}`, `{{AFTERCARE_PORTAL}}`, `{{AFTERCARE_PORTAL_DOMAIN}}` | After-school care provider and its parent portal | — |
| `{{KITA_NAME}}`, `{{KITA_APP}}` | Kita name and the app it sends notices from | — |
| `{{GROUP_NAME}}`, `{{GROUP_CHAT_ID}}`, `{{DM_CHAT_ID}}` | From step 2 | -100…, 12345… |
| `{{BOT_TOKEN}}` | From step 1. **Secret.** | — |
| `{{CALENDAR_ID}}` | From step 3 | …@group.calendar.google.com |
| `{{TRACKER_DOC_ID}}`, `{{TRACKER_TAB_ID}}` | From step 4 | — |
| `{{TIMEZONE}}` | IANA timezone | Europe/Berlin |

The shift codes and times in the intake prompt (Day 05:00–14:00, Eve
12:30–22:00, Nig 21:00–06:00) are examples. Change them to your partner's
real shifts. The prompt is written for screenshots of the MyDuty app, but
other roster apps work too if you describe their screenshot layout.

## Security notes

- Routines have no secrets store, so the bot token sits in the routine prompt.
  It only controls this one bot, not any personal account. Never commit a
  filled prompt; keep it in `private/`.
- The cloud environment only allowlists `api.telegram.org`, so a routine can't
  reach arbitrary sites.
- Before sharing your fork, run `scripts/sanitize-check.sh path/to/denylist`,
  where the denylist is a private file with your family's names, IDs and
  domains, one per line. It also flags anything shaped like a bot token,
  calendar ID or email address.
