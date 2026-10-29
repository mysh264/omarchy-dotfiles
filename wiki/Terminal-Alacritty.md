# Terminals (and the Alacritty override)

This rice uses several terminals, each for one job. Only Alacritty's config is in the repo, and it changes one thing from Omarchy's stock file.

## Which terminal does what

| How you open it | Terminal | Defined in |
|-----------------|----------|------------|
| **Super+Return** | Konsole | `hypr/bindings.lua`: `o.bind("SUPER + RETURN", "Terminal", { launch = "konsole" })` |
| **Super+Shift+Return** | Kitty | `hypr/bindings.lua`: `o.bind("SUPER + SHIFT + RETURN", "Terminal (kitty)", { launch = "kitty" })` |
| **F1**, `XF86Favorites`, keypad Delete (`code:91`), mouse forward (`mouse:276`) | [TildaZ](https://github.com/ensky0/tildaz) by ensky0 (Quake-style dropdown) | F1 is TildaZ's own global hotkey in `~/.config/tildaz/config_0.toml`; the other three are `tildaz --toggle` binds in `hypr/bindings.lua`. See [Dropdown Terminal](Dropdown-Terminal). |
| Anything Omarchy opens for you: `omarchy launch terminal`, TUIs such as btop from the [hw-stats](Hardware-Stats) click, the agent | Omarchy's **default terminal** (via `xdg-terminal-exec`) | `~/.config/xdg-terminals.list`. On the owner's machine this is `foot.desktop`. |

In i3 you had `bindsym $mod+Return exec i3-sensible-terminal`. Here the Return binds name a terminal directly, and Omarchy's "sensible terminal" is `xdg-terminal-exec`. Change that one the Omarchy way:

```bash
omarchy default terminal            # print the current one (foot here)
omarchy default terminal alacritty  # set it: alacritty | foot | ghostty | kitty
```

That does not change Super+Return; edit `hypr/bindings.lua` for that.

Konsole, Kitty and foot configs are **not** in this repo. Kitty, foot and Alacritty get their colors from the Omarchy theme (they import from `~/.local/state/omarchy/current/theme/`). Konsole is a Qt app and follows GTK through `QT_QPA_PLATFORMTHEME=gtk3`; it has no Omarchy theme file.

## The Alacritty override

**Repo:** `alacritty/alacritty.toml`  
**Live:** `~/.config/alacritty/alacritty.toml` (`install.sh` copies it)  
**Stock (read-only):** `/usr/share/omarchy/config/alacritty/alacritty.toml`

It is Omarchy's stock file with **one change**: font size **11** instead of **9**.

```toml
[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
size = 11
```

Everything else is stock:

| Setting | Value |
|---------|-------|
| `general.import` | `~/.local/state/omarchy/current/theme/alacritty.toml` (colors from the active theme) |
| `env.TERM` | `xterm-256color` |
| `terminal.osc52` | `CopyPaste` (apps over SSH can use your clipboard) |
| Window | `padding.x = 14`, `padding.y = 14`, `decorations = "None"` |
| Shift+Insert / Ctrl+Insert | Paste / Copy |
| Shift+Return | Sends CSI-u `\u001B[13;2u`, so TUIs can tell it apart from Return |
| Alt+Shift+Return | Sends CSI-u `\u001B[13;4u`, so tmux can match `M-S-Enter` |

> Alacritty is **not installed** on the owner's machine right now, so this file is dormant there. It is kept so Alacritty looks right the moment you install it or make it the default terminal.

### How to edit

```bash
$EDITOR ~/.config/alacritty/alacritty.toml
```

Alacritty reloads its config on save for most settings. Change `size = 11` for bigger or smaller text. Keep the `general.import` line, or theme switches stop recoloring the terminal.

### Check it worked

```bash
diff /usr/share/omarchy/config/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
# expect only: size = 9  →  size = 11
cat ~/.config/xdg-terminals.list    # which terminal Omarchy launches
```

## Pitfalls

- **Font size changed by itself.** `omarchy display text size <px>` rewrites the `size =` line in `alacritty.toml` (and Kitty's, Ghostty's and foot's). `omarchy font set` rewrites every `family = "…"` line. Both are Omarchy commands doing their job; set the value back if you did not mean it.
- **Colors stopped following the theme.** The `general.import` line was removed or the path is wrong.
- **Looking for the Kitty dropdown?** It is gone. The dropdown is TildaZ now, see [Dropdown Terminal](Dropdown-Terminal).
