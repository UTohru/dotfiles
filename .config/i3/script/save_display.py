
# save current display layout

import os
import sys
import subprocess
import json

W_CONFIG_PATH = os.path.join(os.getenv("HOME"), ".config/sway/enable/local.conf")
X_CONFIG_PATH = os.path.join(os.getenv("HOME"), ".config/i3/enable/local.conf")

def wayland_save_config(data: dict):
    """parse and save config
    Args:
        data (dict): one of `swaymsg -t get_outputs` results
    """
    is_active = bool(data["active"])
    if is_active:
        name = data["name"]
        x = data["rect"]["x"]
        y = data["rect"]["y"]
        transform = data["transform"]

        w = data["modes"][0]["width"]
        h = data["modes"][0]["height"]
        ref_rate = data["modes"][0]["refresh"]
        ref_rate = int(ref_rate) / 1000

        with open(W_CONFIG_PATH, "a") as fw:
            fw.write("output {} resolution {}x{}@{}hz pos {} {} transform {}\n".format(
                name, w, h, ref_rate,
                x, y, transform
                ))

def x11_parse_config(line: str):
    """parse and save config
    Args:
        line (str): xrandr result
    """
    name, is_connect, others = line.split(" ", 2)
    if is_connect == "connected":
        args = others.split(" ")
        idx = 0 if args[0] != "primary" else 1

        whxy = args[idx]
        rotate = args[idx+1]
        wh, x, y = whxy.split("+")
        if not rotate in {"left", "right", "normal", "inverted"}:
            rotate = "normal"

        if rotate == "right" or rotate == "left":
            wh = "x".join(reversed(wh.split("x")))
        return " --output {} --mode {} --pos {}x{} --rotate {}".format(name, wh, x, y, rotate)
    return ""


def main():
    session_type = os.getenv("XDG_SESSION_TYPE")
    if session_type is None:
        sys.exit("Error: $XDG_SESSION_TYPE is not set.")

    if session_type == "wayland":
        res = subprocess.run(["swaymsg", "-t", "get_outputs"], capture_output=True)
        res_json = json.loads(res.stdout.decode())

        if type(res_json) is list:
            for params in res_json:
                wayland_save_config(params)
        else:
            wayland_save_config(params)
    elif session_type == "x11":
        res = subprocess.run(["xrandr"], capture_output=True).stdout.decode()
        args = ""
        for l in res.split("\n"):
            if l and not l.startswith(" "):
                args += x11_parse_config(l)
        if args:
            with open(X_CONFIG_PATH, "a") as fw:
                fw.write("exec --no-startup-id xrandr{}\n".format(args))
    else:
        raise NotImplementedError()
    

if __name__ == '__main__':
    main()
