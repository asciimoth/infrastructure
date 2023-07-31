-------------------------------
--         My theme         --
--       By ASCIIMoth       --
-- based on "Zenburn" theme --
--    By Adrian C. (anrxc)  --
-------------------------------


local function readfile(filename)
    local file = io.open(filename)
    if not file then return nil end
    local text = file:read('*all')
    file:close()
    return text
end

local function read_alt(filename, alt_text)
    return readfile(filename) or alt_text
end

local function parseb16(text)
    b16 = {}
    for line in text:gmatch("([^\n]*)\n?") do
        if line:find("^base%x%x") ~= nil then
            f, t = line:find('"%x%x%x%x%x%x"')
            code = "#" .. line:sub(f+1, t-1)
            f, t = line:find("base%x%x")
            name = line:sub(f+4, t)
            b16[name] = code
        end
    end
    return b16
end

local function loadb16(filename, fallback)
    text = read_alt(filename, fallback)
    return parseb16(text)
end

local themes_path = require("gears.filesystem").get_themes_dir()
local dpi = require("beautiful.xresources").apply_dpi
local theme = {}

theme.tasklist_disable_icon = true;

theme.font      = "sans 8"

theme.useless_gap   = dpi(0)
theme.border_width  = dpi(2)


theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)


theme.taglist_squares_sel   = themes_path .. "mytheme/taglist/squarefz.png"
theme.taglist_squares_unsel = themes_path .. "mytheme/taglist/squarez.png"


theme.awesome_icon           = themes_path .. "mytheme/awesome-icon.png"
theme.menu_submenu_icon      = themes_path .. "mytheme/submenu.png"


theme.layout_tile       = themes_path .. "mytheme/layouts/tile.png"
theme.layout_tileleft   = themes_path .. "mytheme/layouts/tileleft.png"
theme.layout_tilebottom = themes_path .. "mytheme/layouts/tilebottom.png"
theme.layout_tiletop    = themes_path .. "mytheme/layouts/tiletop.png"
theme.layout_fairv      = themes_path .. "mytheme/layouts/fairv.png"
theme.layout_fairh      = themes_path .. "mytheme/layouts/fairh.png"
theme.layout_spiral     = themes_path .. "mytheme/layouts/spiral.png"
theme.layout_dwindle    = themes_path .. "mytheme/layouts/dwindle.png"
theme.layout_max        = themes_path .. "mytheme/layouts/max.png"
theme.layout_fullscreen = themes_path .. "mytheme/layouts/fullscreen.png"
theme.layout_magnifier  = themes_path .. "mytheme/layouts/magnifier.png"
theme.layout_floating   = themes_path .. "mytheme/layouts/floating.png"
theme.layout_cornernw   = themes_path .. "mytheme/layouts/cornernw.png"
theme.layout_cornerne   = themes_path .. "mytheme/layouts/cornerne.png"
theme.layout_cornersw   = themes_path .. "mytheme/layouts/cornersw.png"
theme.layout_cornerse   = themes_path .. "mytheme/layouts/cornerse.png"


theme.titlebar_close_button_focus  = themes_path .. "mytheme/titlebar/close_focus.png"
theme.titlebar_close_button_normal = themes_path .. "mytheme/titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = themes_path .. "mytheme/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path .. "mytheme/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active  = themes_path .. "mytheme/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = themes_path .. "mytheme/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path .. "mytheme/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = themes_path .. "mytheme/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = themes_path .. "mytheme/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = themes_path .. "mytheme/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path .. "mytheme/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = themes_path .. "mytheme/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = themes_path .. "mytheme/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = themes_path .. "mytheme/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = themes_path .. "mytheme/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = themes_path .. "mytheme/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = themes_path .. "mytheme/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = themes_path .. "mytheme/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path .. "mytheme/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = themes_path .. "mytheme/titlebar/maximized_normal_inactive.png"

-- {{{ Trying to load b16 theme
home = os.getenv("HOME")
fallback = [[
scheme: "Catppuccin"
author: "Pocco81 (https://github.com/pocco81)"
base00: "1E1E28"
base01: "1A1826"
base02: "302D41"
base03: "575268"
base04: "6E6C7C"
base05: "D7DAE0"
base06: "F5E0DC"
base07: "C9CBFF"
base08: "F28FAD"
base09: "F8BD96"
base0A: "FAE3B0"
base0B: "ABE9B3"
base0C: "B5E8E0"
base0D: "96CDFB"
base0E: "DDB6F2"
base0F: "F2CDCD"
]]

base = loadb16(home .. "/.b16theme.yaml", fallback)

theme.fg_normal     = base["05"]
theme.fg_focus      = base["09"]
theme.fg_urgent     = base["08"]
theme.fg_minimize   = base["03"]
theme.bg_normal     = base["00"]
theme.bg_focus      = base["01"]
theme.bg_urgent     = base["08"]
theme.bg_minimize   = base["02"]

theme.border_normal = theme.bg_normal
theme.border_focus  = theme.bg_focus
theme.border_marked = theme.bg_urgent

theme.titlebar_bg_focus  = theme.bg_focus
theme.titlebar_bg_normal = theme.bg_normal

theme.menu_fg_normal = theme.fg_normal
theme.menu_fg_focus = theme.fg_focus
theme.menu_bg_normal = theme.bg_normal
theme.menu_bg_focus = theme.bg_focus
theme.menu_border_color = theme.bg_focus
-- }}}


return theme
