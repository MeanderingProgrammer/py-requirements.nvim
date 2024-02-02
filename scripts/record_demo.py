import time
from argparse import ArgumentParser

import pyautogui


def main(file: str, cast: str) -> None:
    # Open new tmux window
    pyautogui.hotkey("`", "c")
    time.sleep(1.0)

    # Zoom in
    for _ in range(30):
        pyautogui.hotkey("command", "=")

    # Start recording demo file
    # https://docs.asciinema.org/manual/cli/usage/
    pyautogui.write(f"asciinema rec -c 'nvim {file}' {cast}")
    pyautogui.press("enter")
    time.sleep(1.0)

    # Start typing in new module
    pyautogui.press("o")
    pyautogui.write("Pillow==10.", interval=0.1)
    time.sleep(0.5)

    # Select third version
    for _ in range(3):
        pyautogui.hotkey("ctrl", "n")
        time.sleep(0.2)
    pyautogui.press("enter")

    # Enter normal mode
    pyautogui.press("esc")
    time.sleep(0.5)

    # Non-existant version
    change_version("3.0")

    # Earlier version
    change_version("1.0")

    # Show description of next module
    pyautogui.press("enter")
    pyautogui.write(" rd", interval=0.1)
    time.sleep(2.0)

    # Close description
    pyautogui.press("enter")

    # Close demo file
    pyautogui.write(":q!")
    pyautogui.press("enter")
    time.sleep(0.5)

    # Zoom out
    pyautogui.hotkey("command", "0")

    # Close tmux window
    pyautogui.write("exit")
    pyautogui.press("enter")


def change_version(version: str) -> None:
    pyautogui.press("a")
    pyautogui.press("backspace", presses=3, interval=0.1)
    pyautogui.write(version, interval=0.1)
    pyautogui.press("esc")
    time.sleep(1.0)


if __name__ == "__main__":
    parser = ArgumentParser(description="Generate a demo recording using asciinema")
    parser.add_argument("--file", type=str, required=True)
    parser.add_argument("--cast", type=str, required=True)
    args = parser.parse_args()
    main(args.file, args.cast)
