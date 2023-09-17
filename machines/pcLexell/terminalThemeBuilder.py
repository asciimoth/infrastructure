import json
import sys
import re

STEP = 0x05

def read(path):
    with open(path) as f:
        return f.read()

def write(path, text):
    with open(path, "w") as f:
        f.write(text)

def read_theme(file):
    ret = {}
    parsed = json.loads(read(file))
    for key in parsed:
        value = parsed[key]
        if key.startswith("base"):
            ret[key] = "#"+str(value) 
    return ret

def extend_theme(theme):
    ret = theme.copy()
    for key in theme:
        value = theme[key]
        if key.startswith("base"):
            code = value[1:]
            red = code[0:2] 
            green = code[2:4]
            blue = code[4:6]
            ret[key+"-hex-r"] = red
            ret[key+"-hex-g"] = green
            ret[key+"-hex-b"] = blue
            ret[key+"-hex"] = code
    return ret

def mustache(template, subs):
    i = 0
    mutches = []
    while i < len(template):
        mtch = re.search(r'{{.*?}}', template[i:])
        if mtch is None:
            break
        span = (mtch.span()[0]+i, mtch.span()[1]+i)
        i = span[1]
        mutches = [span]+mutches
    for mtch in mutches:
        key = template[mtch[0]+2:mtch[1]-2]
        value = "<<<ERROR: NO KEY '{}'>>>".format(key)
        if key in subs:
            value = subs[key]
        template = template[:mtch[0]] + value + template[mtch[1]:]
    return template

def increase(color, step):
    red = (color & 0xff0000) >> 0x10
    green = (color & 0x00ff00) >> 0x8
    blue = (color & 0x0000ff)
    #
    red = min(0xff, red+step)
    green = min(0xff, green+step)
    blue = min(0xff, blue+step)
    #
    color = red << 0x10
    color = color | (green << 0x8)
    color = color | blue
    return color

def brighter(color, step = STEP):
    if isinstance(color, int):
        return increase(color, step)
    else:
        return "#"+hex(increase(int(color[1:].lower(), 16), step))[2:]

def brighter_compare(basics, step = STEP):
    nom = 0
    def next(color):
        nonlocal nom
        basic = basics[nom]
        ret = color
        if color == basic:
            ret = brighter(color, step)
        nom += 1
        return ret
    return next


theme = read_theme(sys.argv[1])
theme = extend_theme(theme)
locals().update(theme)

basic   = [base00, base08, base0B, base0A, base0D, base0E, base0C, base05]
brights = [base03, base08, base0B, base0A, base0D, base0E, base0C, base07]
brights = list(map(brighter_compare(basic), brights))

theme = {**theme, **extend_theme({
    "base-bright0": brights[0],
    "base-bright1": brights[1],
    "base-bright2": brights[2],
    "base-bright3": brights[3],
    "base-bright4": brights[4],
    "base-bright5": brights[5],
    "base-bright6": brights[6],
    "base-bright7": brights[7],
})}

outTheme = {"colors": {
    "ansi": basic,
    "brights": brights,
    "background": base00,
    "cursor_bg": base05,
    "cursor_fg": base05,
    "compose_cursor": base06,
    "foreground": base05,
    "scrollbar_thumb": base01,
    "selection_bg": base05,
    "selection_fg": base00,
    "split": base03,
    "visual_bell": base09,
    "tab_bar": {
        "background": base01,
        "inactive_tab_edge": base01,
        "active_tab": {
          "bg_color": base03,
          "fg_color": base05,
        },
        "inactive_tab": {
          "bg_color": base00,
          "fg_color": base05,
        },
        "inactive_tab_hover": {
          "bg_color": base05,
          "fg_color": base00,
        },
        "new_tab": {
          "bg_color": base00,
          "fg_color": base05,
        },
        "new_tab_hover": {
          "bg_color": base05,
          "fg_color": base00,
        },
    }
}}

print(json.dumps(outTheme))

write(sys.argv[3], mustache(read(sys.argv[2]), theme))
