# Themes and Fonts

## Shell font size

**File:** `omarchy/shell.toml` → `~/.config/omarchy/shell.toml`

```toml
[font]
base-size = 14
```

Raise/lower `base-size`, then `omarchy restart shell` if needed.

## Theme template override

**File:** `omarchy/themed/shell.toml.tpl` → `~/.config/omarchy/themed/shell.toml.tpl`

Applied when Omarchy themes regenerate shell chrome. Edit carefully — it is a full template (hundreds of lines). Prefer stock theme commands first; use the tpl only when you need persistent overrides across theme switches.

## Omarchy theme CLI

```bash
omarchy theme list
omarchy theme current
omarchy theme set "Catppuccin"
omarchy theme bg next
```

Wallpaper slideshow is also driven from the [Wallpaper Widget](Wallpaper-Widget).

## Default AI agent

**File:** `omarchy/defaults/agent` → `~/.config/omarchy/defaults/agent`

Shipped value: `cursor-agent`

Change to whatever `omarchy-default-agent` accepts on your build, or delete the file to get Omarchy’s setup invitation again.

## Terminal fonts

- **Alacritty:** [Terminal (Alacritty)](Terminal-Alacritty) — JetBrainsMono Nerd Font size **11**, theme imported from Omarchy current theme  
- **Kitty / foot / Ghostty:** often theme-managed by Omarchy; tweak via theme or each app’s own config under `~/.config/`  

## hy3 tab font

Set in [Look and Feel](Look-and-Feel): `plugin.hy3.tabs.text_font` (shipped: `JetBrainsMono Nerd Font`).
