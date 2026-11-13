# E-ink display (optional)

Show the family calendar and the latest digest side by side on an always-on
e-ink screen, e.g. in the hallway. It uses [TRMNL](https://trmnl.com): their
own device, or "bring your own device" hardware running TRMNL's software.

```
Google Calendar ──► TRMNL Google Calendar plugin ─┐
                                                   ├─► mashup "Two columns" ──► screen
Daily digest (step 9b) ──webhook──► private plugin ┘        (refreshes every 15 min)
```

## Pick a screen

| Option | Notes |
|---|---|
| TRMNL device (~$140) | Easiest. Get the Developer add-on (or "Clarity Kit"): private plugins need it. |
| Seeed reTerminal E1001/E1002, Inkplate, … | Ready-made e-ink panels supported by TRMNL's BYOD licence. |
| Old Android tablet / iPad | No hacking, but a lit screen that must stay plugged in. |
| Old Kindle | Possible, but needs a jailbreak — **at your own risk**: it voids Amazon support and can brick the device. Follow [TRMNL's Kindle guide](https://github.com/usetrmnl/trmnl-kindle) and the [Kindle Modding Wiki](https://kindlemodding.org/jailbreak-wizard.html); this kit doesn't cover it. |

## Setup

1. **TRMNL account + device.** Register your screen, set the right device
   model (resolution matters), and adjust *UI Scale* if text is too small.
2. **Calendar.** Plugins → Google Calendar → connect, pick the family calendar.
   Recommended: vertical alignment *top*, descriptions *off*, event times *on*,
   a date format with the weekday (custom `%A %-d %b` → "Saturday 14 Nov").
   The account language decides the language of the dates.
3. **Digest plugin.** Plugins → Private Plugin → strategy **Webhook**. Paste
   [`digest-full.liquid`](digest-full.liquid) as *Full* and
   [`digest-half-vertical.liquid`](digest-half-vertical.liquid) as
   *Half vertical*. Copy its webhook URL into `{{TRMNL_WEBHOOK_URL}}` and keep
   step 9b in the daily digest prompt.
4. **Mashup.** Playlist → Add Plugin → *Two columns*: calendar left, digest
   right. Hide the other playlist items so only the mashup shows.
5. **Cloud environment.** Add `trmnl.com` to the allowlist next to
   `api.telegram.org`.

## Tips

- After changing a plugin's settings or markup, use the mashup's ⋮ →
  **Refresh now**, otherwise the screen keeps showing the old cached image.
- Plain CSS `font-weight` does nothing with TRMNL's font; the layout uses
  TRMNL's `title title--small` class for bold section titles.
- Lines ending with ":" are rendered as section titles, so keep that
  convention in the condensed digest.
