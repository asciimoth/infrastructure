import subprocess
import os
import argparse


URG_LOW = "low"
URG_NORM = "normal"
URG_CRIT = "critical"

D_BEGIN, D_BODY, D_END = "", "-#", ""
D_BEGIN = os.environ.get('ND_BAR_BEGIN') or D_BEGIN
D_BODY = os.environ.get('ND_BAR_BODY') or D_BODY
D_END = os.environ.get('ND_BAR_END') or D_END
SPINNER = r"|/-\-/"
SPINNER = os.environ.get('ND_SPINNER') or SPINNER

DB_PATH = "/tmp/notify-desktop-py/"


def removech(string, ls):
    for e in ls:
        string = string.replace(e, "")
    return string


def resolve_name(name):
    if name is None:
        return None
    os.makedirs(DB_PATH, exist_ok=True)
    try:
        with open(DB_PATH+name, 'r') as f:
            return f.read().strip()
    except Exception as e:
        e = e
        return None


def save_name(name, code):
    if name is None or code is None:
        return
    os.makedirs(DB_PATH, exist_ok=True)
    with open(DB_PATH+name, "w") as f:
        f.write(str(code))


def get(col, i):
    if len(col) < i+1:
        return None
    return col[i]


def tokenise_msg(text, fmt):
    op = fmt[0]
    cl = fmt[1]
    tokens = []
    cmd = []
    terminator = ""
    token = ""
    state = "txt"
    i = 0
    while i < len(text):
        match state:
            case "txt":
                if text[i] != op:
                    token += text[i]
                else:
                    terminator += cl
                    state = "open"
            case "open":
                if text[i] == op:
                    terminator += cl
                else:
                    if terminator in text[i:]:
                        tokens.append(token)
                        token = text[i]
                        state = "cmd"
                    else:
                        token += terminator.replace(cl, op)
                        state = "txt"
            case "cmd":
                if text[i] == cl and text[i:i+len(terminator)] == terminator:
                    cmd.append(token)
                    tokens.append(cmd)
                    cmd = []
                    token = ""
                    i += len(terminator)
                    terminator = ""
                    state = "txt"
                    continue
                else:
                    if text[i] != " " and text[i-1] == " ":
                        cmd.append(token[:-1])
                        token = text[i]
                    else:
                        token += text[i]
        i += 1
    if token != "":
        tokens.append(token)
    return tokens


def is_float(value):
    try:
        float(value)
        return True
    except Exception as e:
        e = e
        return False


def parse_fullness(f):
    if f is None:
        return None
    percent = "%" in f
    f = f.replace("%", "")
    try:
        f = float(f)
        if not percent:
            f *= 100
        return max(min(int(f), 100), 0), 100
    except Exception as e:
        e = e
    try:
        f = f.split("/")
        return int(f[0]), int(f[1])
    except Exception as e:
        e = e
        return None


def parse_length(col):
    if col is None:
        return None
    return int(col)


def fmt_msg(text, fmt):
    tokens = tokenise_msg(text, fmt)
    text = ""
    for token in tokens:
        if isinstance(token, str):
            text += token
        else:
            cmd = str(get(token, 0)).strip()
            if "bar".startswith(cmd):
                typ = get(token, 1)
                fullness, length = [50, 100], 10
                begin, body, end = D_BEGIN, D_BODY, D_END
                if typ == "FIRA":
                    fullness = parse_fullness(get(token, 2)) or fullness
                    length = parse_length(get(token, 3)) or length
                    begin, body, end = "", "", ""
                else:
                    n = 1
                    while True:
                        match get(token, n):
                            case "begin":
                                begin = get(token, n+1) or begin
                            case "body":
                                body = get(token, n+1) or body
                            case "end":
                                end = get(token, n+1) or end
                            case _:
                                break
                        n += 2
                    fullness = parse_fullness(get(token, n)) or fullness
                    length = parse_length(get(token, n+1)) or length
                fullness = list(fullness)
                if fullness[0] == fullness[1] == 0:
                    fullness = [1, 1]
                body = body if len(body) > 1 else "-="
                length = max(2, length) - min(1, len(begin)) - min(1, len(end))
                divs = length*len(body) + len(begin) + len(end)
                fullness[0] = min(int(divs / fullness[1] * fullness[0]), divs)
                fullness[1] = divs
                prefix, bar, postfix = "", "", ""
                if len(begin) == 1:
                    prefix = begin
                elif len(begin) > 1:
                    prefix = begin[min(len(begin)-1, fullness[0])]
                    fullness[0] = max(0, fullness[0]-len(begin))
                    fullness[1] = max(0, fullness[1]-len(begin))
                if len(end) == 1:
                    postfix = end
                elif len(end) > 1:
                    postfix = end[max(0, len(end)-1-(fullness[1]-fullness[0]))]
                    fullness[1] = max(0, fullness[1]-len(end))
                fullness[0] = max(0, min(fullness[0], fullness[1]))
                bar += body[-1] * min(length, (fullness[0] // len(body)))
                bar += body[min(
                    len(body)-1, fullness[0]-fullness[0]//len(body) * len(body)
                )] * min(1, max(0, length-len(bar)))
                bar += body[0]*(length-len(bar))
                text += prefix + bar + postfix
            if "spiner".startswith(cmd):
                spiner = get(token, 2) or SPINNER
                if spiner == "FIRA":
                    spiner = ""
                text += spiner[int(float(token[1])) % len(spiner)]
    return text


def send_raw(
    text, urgency=None, code=None,
    expire=None, app=None, icon=None, category=None
):
    text = " " if text == "" else text
    cmd = ["notify-desktop"]
    if urgency:
        cmd += ["-u", f"{urgency}"]
    if code:
        cmd += ["-r", f"{code}"]
    if expire:
        cmd += ["-t", f"{expire}"]
    if app:
        cmd += ["-a", f"{app}"]
    if icon:
        cmd += ["-i", f"{icon}"]
    if category:
        cmd += ["-c", f"{category}"]
    cmd.append(text)
    result = subprocess.run(cmd, stdout=subprocess.PIPE)
    result = result.stdout.decode('utf-8').strip()
    try:
        return int(result)
    except Exception as e:
        e = e
        print(result)
        os.exit(1)


def send(
    text, fmt=None, urgency=None, name=None, code=None,
    expire=None, app=None, icon=None, category=None
):
    if name:
        name = removech(name, "\\/ \t\r\n")
        if code is None:
            code = resolve_name(name)
    if fmt:
        text = fmt_msg(text, fmt)
    code = send_raw(text, urgency, code, expire, app, icon, category)
    save_name(name, code)
    return code


def main():
    parser = argparse.ArgumentParser(
        prog='notify-desktop-py',
        description='QoL wrapper for notify-desktop'
    )
    parser.add_argument("text")
    parser.add_argument("-n", "--name")
    parser.add_argument(
            "-u", "--urgency",
            choices=[URG_LOW, URG_NORM, URG_CRIT]
    )
    parser.add_argument("-f", "--fmt")
    parser.add_argument("-t", "--time")
    parser.add_argument("-a", "--app")
    parser.add_argument("-i", "--icon")
    parser.add_argument("-c", "--category")
    parser.add_argument("--notify-id")
    args = parser.parse_args()
    print(send(
        args.text,
        args.fmt,
        args.urgency,
        args.name,
        args.notify_id,
        args.time,
        args.app,
        args.icon,
        args.category
    ))


if __name__ == "__main__":
    main()
