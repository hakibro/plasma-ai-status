# AI Status — KDE Plasma 6 widget for 9router

A Plasma 6 panel widget that shows live AI activity and usage from a local [9router](https://github.com/decolua/9router) instance: which model is running right now, tokens, cost, requests, and provider health.

Pure QML plasmoid — no Python, no extra dependencies, no build step.

## Features

- **Panel (compact) view** — pick what shows: running `model · provider`, total tokens, cost, request count, active providers, or icon only. Status dot pulses while a request is in flight.
- **Click-to-expand dashboard** with 4 tabs:
  - **Overview** — active requests, totals (requests / input / output / cached tokens / cost), last-10-minutes sparkline
  - **Providers** — connection list with status, last used, per-provider usage and errors
  - **Recent** — last 20 requests with time, model, provider, tokens, status
  - **Breakdown** — usage by model or by provider, sorted by cost
- **Period selector** — today / 24h / 7d / 30d / 60d
- **CLI-token auth** — authenticates the same way the official 9router CLI does (no dashboard password stored, no login lockout risk)
- Configurable host, port, and poll interval (default 30 s)
- Context menu: Refresh, Open 9router Dashboard

## Requirements

- KDE Plasma 6 (`plasmashell` 6.x, `kpackagetool6`, Kirigami — all standard on Plasma 6 distros)
- [9router](https://github.com/decolua/9router) running (default `http://localhost:20128`) with at least one completed request
- `python3` (only for the token helper and packaging)

## Install

```bash
git clone https://github.com/hakibro/plasma-ai-status.git
cd plasma-ai-status
./install.sh install
```

This installs the plasmoid **and** the `9r-token` helper to `~/.local/bin`, and prints your CLI token.

Then:

1. Right-click your panel → **Add Widgets** → search **AI Status (9router)** → add it.
   (If it doesn't appear: `kquitapp6 plasmashell && kstart6 plasmashell`)
2. Right-click the widget → **Configure** → paste your CLI token → OK.

### Getting the CLI token

```bash
9r-token
```

The token is `sha256(machine-id + "9r-cli-auth" + cli-secret)[:16]`, computed from `~/.9router/machine-id` and `~/.9router/auth/cli-secret` — the exact scheme the official 9router CLI uses (`x-9r-cli-token` header). It is only needed when your 9router dashboard is password-protected; otherwise leave the field empty.

## Configuration

| Option | Default | Description |
|---|---|---|
| Host | `localhost` | 9router host |
| Port | `20128` | 9router port |
| CLI token | *(empty)* | Output of `9r-token` |
| Refresh every | `30` s | Poll interval (5–3600) |
| Panel shows | Activity | Compact view metric |
| Default period | `24h` | Stats aggregation window |

## Usage notes

- The widget polls `GET /api/usage/stats?period=…` and `GET /api/providers` each interval, plus once when the popup opens.
- "Active now" comes from `activeRequests` in the stats payload — it reflects requests currently in flight through 9router.
- Cost figures are 9router's own estimates (for reference; 9router itself bills nothing).

## Development

```
package/
├── metadata.json                  # plasmoid metadata (Id: com.wonocraft.aistatus)
└── contents/
    ├── config/main.xml            # KConfigXT schema
    ├── config/config.qml          # config dialog model
    └── ui/
        ├── main.qml               # PlasmoidItem: state, polling, actions
        ├── CompactRepresentation.qml
        ├── FullRepresentation.qml  # header + tabs
        ├── configGeneral.qml
        ├── js/api.js              # XHR client + formatters
        └── tabs/                  # Overview / Providers / Recent / Breakdown
```

Useful commands:

```bash
./install.sh install    # (re)install plasmoid + helper
./install.sh package    # build plasma-ai-status.plasmoid for distribution
./install.sh token      # print CLI token
./install.sh remove     # uninstall
```

Lint QML before committing:

```bash
qmllint -I /usr/lib/qt6/qml package/contents/ui/*.qml package/contents/ui/tabs/*.qml
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| Widget shows `—` / "Unauthorized" | Paste the token from `9r-token` into config |
| "Cannot reach 9router" | Check host/port; is 9router running? (`curl http://localhost:20128/api/health`) |
| Widget not in Add Widgets | Restart shell: `kquitapp6 plasmashell && kstart6 plasmashell` |
| Stale config UI after update | Close and reopen the Configure dialog |

## License

LGPL-2.1-or-later
