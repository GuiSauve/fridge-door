# E-ink display (optional)

Show the family calendar and the latest digest side by side on an always-on
e-ink screen, e.g. in the hallway. It uses [TRMNL](https://trmnl.com): their
own device, or "bring your own device" hardware running TRMNL's software.

```
Daily digest (18:00, step 9b) ──┐  digest + next 7 days
Telegram intake (06:xx, step 0) ─┼─ webhook ──► private plugin ──► screen
   …and after calendar changes ─┘  next 7 days + today       (checks hourly)
```

```
Today · Friday 13 Nov          │ 📋 Digest · Thu 12 Nov, 18:08
Nothing planned                │
                               │ New from school:
Saturday 14 Nov                │ • Poll: extra parents' evening?
09:00  ⚽ Mia – Tournament     │
Monday 16 Nov                  │ Due soon:
🧸 Leo – Kita closed           │ • Mia: bring signed form (Mon)
```

## Pick a screen

| Option | Notes |
|---|---|
| TRMNL device (~$140) | Easiest. Get the Developer add-on (or "Clarity Kit"): private plugins need it. |
| Seeed reTerminal E1001/E1002, Inkplate, … | Ready-made e-ink panels supported by TRMNL's BYOD licence. |
| Old Android tablet / iPad | No hacking, but a lit screen that must stay plugged in. |
| Old Kindle | Possible, but needs a jailbreak — **at your own risk**: it voids Amazon support and can brick the device. Follow [TRMNL's Kindle guide](https://github.com/usetrmnl/trmnl-kindle) and the [Kindle Modding Wiki](https://kindlemodding.org/jailbreak-wizard.html); this kit doesn't cover it. |

## Setup

1. **TRMNL account + device.** Register your screen and set the right device
   model (resolution matters). Recommended under *Battery & Sleep*: refresh
   every 60 min, *Wait for the next update* on, sleep mode overnight with the
   sleep screen **off** (the last screen stays visible).
2. **Plugin.** Plugins → Private Plugin → strategy **Webhook**. Paste
   [`display.liquid`](display.liquid) as the *Full* markup. Copy its webhook URL
   into `{{TRMNL_WEBHOOK_URL}}` in both prompts and keep the optional display
   steps (daily digest 9b + WEEK DATA RULES; intake 2b, 7d + DISPLAY PUSH).
3. **Playlist.** Keep only this plugin visible (hide the welcome screen).
4. **Cloud environment.** Add `trmnl.com` to the allowlist next to
   `api.telegram.org`.
5. **Language.** The dates are written by the routines (English by default);
   change the label format in the prompts if you prefer another language.

## What the layout does

- Left: today (always, even if empty: "Nothing planned"), then the next days
  with events or to-dos. To-dos come from the tracker's Open Action Items and
  are marked 📝 (they never go on the calendar). Dates bold, entries regular,
  times in 24 h.
- Right: the condensed digest, headed "📋 Digest · <when it was sent>";
  lines ending with ":" become bold section titles.
- Under the digest: an optional quote of the day (`quote`, `quote_by`).
- Bottom bar: battery level (`trmnl.device.percent_charged`, as of the last
  render).
- Text starts at 125% and each column shrinks itself (down to 85%) only when
  its content wouldn't fit, so busy weeks don't get cut off.

## Tips

- After changing the markup, use the playlist item's ⋮ → **Refresh now**;
  otherwise the screen keeps the old cached image until the next data push.
- Plain CSS `font-weight` does nothing with TRMNL's font; the layout uses
  TRMNL's `title title--small` class for bold.
- Keep calendar titles short (the prompts already ask for ~25 characters);
  details belong in the event description.
