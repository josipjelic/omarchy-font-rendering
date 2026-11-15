#!/usr/bin/env python3
"""Read/write ~/.config/fontconfig/fonts.conf rendering settings."""
import json, os, re, subprocess, sys

CONF = os.path.expanduser("~/.config/fontconfig/fonts.conf")
DEFAULTS = {"antialias": True, "hinting": True, "hintstyle": "hintslight",
            "rgba": "none", "lcdfilter": "lcddefault"}
ALLOWED = {"hintstyle": {"hintnone", "hintslight", "hintmedium", "hintfull"},
           "rgba": {"none", "rgb", "bgr", "vrgb", "vbgr"},
           "lcdfilter": {"lcdnone", "lcddefault", "lcdlight", "lcdlegacy"}}

def read():
    s = dict(DEFAULTS)
    try:
        t = open(CONF).read()
    except OSError:
        return s
    for k in ("antialias", "hinting"):
        m = re.search(r'name="%s"[^>]*><bool>(true|false)</bool>' % k, t)
        if m: s[k] = m.group(1) == "true"
    for k in ("hintstyle", "rgba", "lcdfilter"):
        m = re.search(r'name="%s"[^>]*><const>(\w+)</const>' % k, t)
        if m: s[k] = m.group(1)
    return s

def write(s):
    os.makedirs(os.path.dirname(CONF), exist_ok=True)
    b = lambda v: "true" if v else "false"
    xml = f'''<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <!-- Managed by the font-rendering Omarchy plugin -->
  <match target="font">
    <edit name="antialias" mode="assign"><bool>{b(s["antialias"])}</bool></edit>
    <edit name="hinting"   mode="assign"><bool>{b(s["hinting"])}</bool></edit>
    <edit name="hintstyle" mode="assign"><const>{s["hintstyle"]}</const></edit>
    <edit name="rgba"      mode="assign"><const>{s["rgba"]}</const></edit>
    <edit name="lcdfilter" mode="assign"><const>{s["lcdfilter"]}</const></edit>
  </match>
</fontconfig>
'''
    tmp = CONF + ".tmp"
    open(tmp, "w").write(xml)
    os.replace(tmp, CONF)
    subprocess.run(["fc-cache", "-f"], check=False)

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    s = read()
    if cmd == "apply":
        new = json.loads(sys.argv[2])
        for k, v in new.items():
            if k in ("antialias", "hinting") and isinstance(v, bool): s[k] = v
            elif k in ALLOWED and v in ALLOWED[k]: s[k] = v
        write(s)
    elif cmd == "reset":
        s = dict(DEFAULTS); write(s)
    print(json.dumps(s))

main()
