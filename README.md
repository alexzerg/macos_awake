# macos_awake

Manual + scheduled control of **macOS sleep prevention** and **MDM screensaver bypass**, wrapped in a single command.

```bash
awake on            # ☕ stay awake
awake off           # 😴 normal sleep behavior
awake disable       # weekend mode (off + blocked at login)
awake schedule      # Fri 23:59 off / Mon 07:00 on, automatically
```

## Why

On a corporate Mac with MDM-enforced screensaver/lock policies, `caffeinate` alone is not enough — the MDM idle timer still locks your screen. This combines:

- **`caffeinate -disu`** — prevents macOS sleep + display sleep on AC
- **`hid-nudge.sh`** — periodically nudges keyboard/mouse via AppleScript so the HID idle timer never fires

Both run as `launchd` LaunchAgents with `KeepAlive=true`, so they survive crashes and respawn automatically. `awake` is the friendly control surface.

## Install

```bash
git clone https://github.com/alexzerg/macos_awake.git
cd macos_awake
make install        # copies scripts to ~/bin, writes LaunchAgent plists
awake on            # start right now
awake schedule      # optional: enable Fri/Mon auto-toggle
```

## Usage

| Command | Effect |
|---------|--------|
| `awake on` | Start caffeinate + hid-nudge **now** |
| `awake off` | Stop **now** (returns at login if enabled) |
| `awake enable` | Permit auto-start at login |
| `awake disable` | Block auto-start at login (also stops if running) |
| `awake schedule` | Install Fri 23:59 off / Mon 07:00 on auto-toggle |
| `awake schedule 18 0 7 30` | Custom: Fri 18:00 off, Mon 07:30 on |
| `awake unschedule` | Remove auto-toggle |
| `awake status` | Show what is loaded, running, scheduled |
| `awake uninstall` | Full removal |

## Makefile targets

| Target | Does |
|--------|------|
| `make install` | Copy scripts to `~/bin`, write plists, ready to use |
| `make uninstall` | Stop agents, remove plists, remove `~/bin/awake` |
| `make on` / `make off` | Start / stop now |
| `make schedule` | Install weekend auto-toggle |
| `make status` | Show current state |

## How it works

`awake` manages four LaunchAgent labels under a configurable namespace
(default `com.awake`, override with `export AWAKE_NS=com.yourname`):

| Label | Type | Purpose |
|-------|------|---------|
| `${NS}.nosleep` | `RunAtLoad` + `KeepAlive` | runs `caffeinate -disu` |
| `${NS}.hidnudge` | `RunAtLoad` + `KeepAlive` | runs `hid-nudge.sh` |
| `${NS}.friday` | `StartCalendarInterval` | Fri triggers `awake disable` |
| `${NS}.monday` | `StartCalendarInterval` | Mon triggers `awake enable && on` |

Plists live in `~/Library/LaunchAgents/`. State and logs in `~/.awake/`.

If the Mac is asleep at the trigger time, launchd fires the job on next wake — so Monday 07:00 triggers when you open the lid, not at the exact time if you were off.

## Customization

**Choosing a namespace:** The default `com.awake` is safe for most users. To verify it's free on your system:

```bash
launchctl print-disabled gui/$(id -u) | grep com.awake
```

No output means you're good. If it's taken, override before `make install`:

```bash
export AWAKE_NS=com.yourdomain.awake
make install
```

Add it permanently to `~/.zshrc` if you want it to persist across sessions:

```bash
echo 'export AWAKE_NS=com.yourdomain.awake' >> ~/.zshrc
```

---

```bash
# Different namespace (to coexist with another install)
export AWAKE_NS=com.yourname

# Custom hid-nudge location
export AWAKE_HID=/path/to/my-nudge.sh

# Custom schedule: Fri 18:00 off, Mon 07:30 on
awake schedule 18 0 7 30

# Inspect what fired
tail -f ~/.awake/scheduled.log
```

## Uninstall

```bash
make uninstall
rm -rf ~/.awake   # optional: remove logs
```

## Requirements

- macOS 10.11+ (launchctl bootstrap/bootout)
- bash, awk (built-in)
- `/usr/bin/caffeinate` (built-in)
- `osascript` for `hid-nudge.sh` (built-in)

## License

MIT — see [LICENSE](LICENSE).
