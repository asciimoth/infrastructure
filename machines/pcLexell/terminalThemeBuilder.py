from sys import argv
import json
import re


# args: b16_theme_file colorstep

def get_default(l, i, d):
    if i < len(l):
        return l[i]
    return d

def read(path):
    with open(path) as f:
        return f.read()

def write(path, text):
    with open(path, "w") as f:
        f.write(text)

def parse_theme(txt):
    ret = {}
    parsed = json.loads(txt)
    if "palette" in parsed:
        parsed = parsed["palette"]
    for key in parsed:
        value = parsed[key]
        if key.startswith("base"):
            ret[key] = "#"+str(value) 
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

# For each baseXX theme creates
# 1. baseXX-hex with same value
# 2. baseXX-hex-r with only red componenet
# 3. baseXX-hex-g with only green componenet
# 4. baseXX-hex-b with only blue componenet
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

def brighter(color, step):
    if isinstance(color, int):
        return increase(color, step)
    else:
        return "#"+hex(increase(int(color[1:].lower(), 16), step))[2:]

def brighter_compare(basics, step):
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

def main():
    b16_theme_file = argv[1]
    colorstep = int(get_default(argv, 2, "0x05"), 16)
    output_file = get_default(argv, 4, None)
    mustache_template = get_default(argv, 3, None)
    theme = parse_theme(read(b16_theme_file))
    theme = extend_theme(theme)
    basic   = [
        theme["base00"],
        theme["base08"],
        theme["base0B"],
        theme["base0A"],
        theme["base0D"],
        theme["base0E"],
        theme["base0C"],
        theme["base05"]
    ]
    brights = [
        theme["base03"],
        theme["base08"],
        theme["base0B"],
        theme["base0A"],
        theme["base0D"],
        theme["base0E"],
        theme["base0C"],
        theme["base07"]
    ]
    comp = brighter_compare(basic, colorstep)
    brights = list(map(comp, brights))
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
        "background": theme["base00"],
        "cursor_bg": theme["base05"],
        "cursor_fg": theme["base00"],
        "compose_cursor": theme["base06"],
        "foreground": theme["base05"],
        "scrollbar_thumb": theme["base01"],
        "selection_bg": theme["base05"],
        "selection_fg": theme["base00"],
        "split": theme["base03"],
        "visual_bell": theme["base09"],
        "tab_bar": {
            "background": theme["base01"],
            "inactive_tab_edge": theme["base01"],
            "active_tab": {
              "bg_color": theme["base03"],
              "fg_color": theme["base05"],
            },
            "inactive_tab": {
              "bg_color": theme["base00"],
              "fg_color": theme["base05"],
            },
            "inactive_tab_hover": {
              "bg_color": theme["base05"],
              "fg_color": theme["base00"],
            },
            "new_tab": {
              "bg_color": theme["base00"],
              "fg_color": theme["base05"],
            },
            "new_tab_hover": {
              "bg_color": theme["base05"],
              "fg_color": theme["base00"],
            },
        }
    }}
    print(json.dumps(outTheme))
    write(output_file, mustache(read(mustache_template), theme))


if __name__ == "__main__":
    main()
