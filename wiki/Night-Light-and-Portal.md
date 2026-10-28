# Night Light and Portal

## Night light — `hyprsunset.conf`

**Repo:** `hypr/hyprsunset.conf`  
**Live:** `~/.config/hypr/hyprsunset.conf`

Shipped profile keeps the display **untinted** by default (identity at 07:00). Without a config, hyprsunset may apply an unwanted tint.

```conf
profile {
    time = 07:00
    identity = true
}
```

### Enable automatic night light

1. Uncomment / add an evening profile in the conf:

```conf
profile {
    time = 20:00
    temperature = 4000
}
```

2. Start the daemon from [Autostart](Autostart):

```lua
o.launch_on_start("hyprsunset")
```

3. Apply:

```bash
omarchy restart hyprsunset
# or restart session
```

Tune `time` and `temperature` to taste. Multiple `profile { }` blocks are allowed.

---

## Desktop portal — `xdph.conf`

**Repo:** `hypr/xdph.conf`  
**Live:** `~/.config/hypr/xdph.conf`

XDG Desktop Portal (Hyprland) screencopy settings:

```conf
screencopy {
    allow_token_by_default = true
    custom_picker_binary = hyprland-preview-share-picker
}
```

| Setting | Meaning |
|---------|---------|
| `allow_token_by_default` | Fewer repeated share prompts for screencast tokens |
| `custom_picker_binary` | UI used when picking what to share |

Applies after portal restart or next login. If screen sharing breaks after edits, revert and restart `xdg-desktop-portal-hyprland` / session.
