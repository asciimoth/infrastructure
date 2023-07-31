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

home = os.getenv("HOME")
b16yml = readfile(home .. "/.b16theme.yaml")
file = io.open(home .. "/.aws", "w")
file:write(b16yml)
file:close()

