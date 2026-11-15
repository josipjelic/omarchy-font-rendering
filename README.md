# Font Rendering for Omarchy

A bar widget for the [Omarchy](https://omarchy.org/) shell that controls font
rendering through fontconfig, with a live pixel-level preview.

- Antialiasing and hinting toggles
- Hint style: none, slight, medium, full
- Subpixel order: gray, RGB, BGR, VRGB, VBGR
- LCD filter: off, light, default
- Side-by-side preview of unsmoothed pixels vs. your current settings

Changes are written to `~/.config/fontconfig/fonts.conf` and `fc-cache -f` is
run. Restart apps to pick up the new settings.

**Your existing config is preserved.** The plugin only writes when you change a
setting in the popup. If `fonts.conf` was not created by this plugin, it is
first copied once to `~/.config/fontconfig/fonts.conf.bak-font-rendering`.
After that the file is managed by the plugin, so hand edits to it are
overwritten on the next change. Settings other than the five above are not
kept in that file.

## Requirements

- Omarchy with the shell plugin system
- `python3` and `fontconfig` (`fc-cache`), both standard on Omarchy
- No network access, no other dependencies

## Install

```bash
omarchy plugin add https://github.com/josipjelic/omarchy-font-rendering --enable
```

## Remove

```bash
omarchy plugin remove kontekst.font-rendering
```

Removing the plugin leaves `fonts.conf` in place. To go back to your previous
setup, restore the backup (if present) or delete the file:

```bash
mv ~/.config/fontconfig/fonts.conf.bak-font-rendering ~/.config/fontconfig/fonts.conf
fc-cache -f
```

## License

MIT
