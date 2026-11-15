# Font Rendering for Omarchy

A bar widget for the [Omarchy](https://omarchy.org/) shell that controls font
rendering through fontconfig, with a live pixel-level preview.

- Antialiasing and hinting toggles
- Hint style: none, slight, medium, full
- Subpixel order: gray, RGB, BGR, VRGB, VBGR
- LCD filter: off, light, default
- Side-by-side preview of unsmoothed pixels vs. your current settings

Changes are written to `~/.config/fontconfig/fonts.conf` (the file is managed
by the plugin and overwritten on each change) and `fc-cache -f` is run.
Restart apps to pick up the new settings.

## Install

```bash
omarchy plugin add https://github.com/josipjelic/omarchy-font-rendering --enable
```

## Remove

```bash
omarchy plugin remove josip.font-rendering
```

## License

MIT
