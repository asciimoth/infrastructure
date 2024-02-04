import os
import subprocess

# /h/m -> /h/m/ ; /h/m/ -> /h/m/
HOME = os.getenv("HOME").removesuffix("/")+"/"


HISTORY_FILE = HOME+".cache/ide_script/history"
HISTORY_SIZE = 8


def dedup(arr):
    ret = []
    for e in arr:
        if e not in ret:
            ret.append(e)
    return ret


def read_history():
    try:
        history = []
        with open(HISTORY_FILE, 'r') as f:
            raw_history = [x.strip() for x in f.readlines()]
        for elem in raw_history:
            if elem == "":
                continue
            if elem[0] != "/":
                continue
            elem = os.path.normpath(elem)
            if os.path.exists(elem):
                history.append(elem)
        history = dedup(history)
        return history[:HISTORY_SIZE+1]
    except Exception as e:
        print(e)
        return []


def write_history(history):
    os.makedirs(os.path.dirname(HISTORY_FILE), exist_ok=True)
    with open(HISTORY_FILE, "w") as f:
        f.write("\n".join(history))


def prettyfi_path(path):
    elems = os.path.normpath(path).split("/")
    path = "/"
    for i in range(len(elems)-1):
        if elems[i] == "":
            continue
        path += elems[i][0] + "/"
    path += elems[-1]
    return path


def select(variants, msg="", prompt=""):
    cmd = ["rofi", "-dmenu", "-i", "-no-custom"]
    if msg != "":
        cmd += ["-mesg", msg]
    if prompt != "":
        cmd += ["-p", prompt]
    inp = "\n".join(variants).encode('utf-8')
    result = subprocess.run(cmd, stdout=subprocess.PIPE, input=inp)
    return result.stdout.decode('utf-8')


def pick(is_dir=False):
    cmd = ["pick", "--choosedir" if is_dir else "--choosefile"]
    result = subprocess.run(cmd, stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8')


history = read_history()

prtf = list(map(lambda p: prettyfi_path(p), history))

mapping = {}

for i in range(len(history)):
    mapping[prtf[i]] = history[i]

selected = select(
    prtf+["open dir", "open file", "clear"],
    prompt="ide:"
).removesuffix("\n")

if selected in mapping:
    selected = mapping[selected]

match selected:
    case "open dir":
        selected = pick(True)
    case "open file":
        selected = pick()
    case "clear":
        write_history([])
        exit(0)

if selected == "":
    exit(0)

history = dedup([selected]+history)

write_history(history)

subprocess.run(["codium", "-wn", selected])
