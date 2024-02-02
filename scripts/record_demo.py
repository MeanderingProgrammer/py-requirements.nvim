import os
import time

import pyautogui


def main() -> None:
    # Open new tmux window
    pyautogui.hotkey("`", "c")
    time.sleep(1.0)

    # Zoom in
    for _ in range(30):
        pyautogui.hotkey("command", "=")

    # Start recording demo file
    file_path = "scripts/demo-requirements.txt"
    pyautogui.typewrite(f"asciinema rec -c 'nvim {file_path}' demo.cast")
    pyautogui.press("enter")
    time.sleep(1.0)

    # Start typing in new module
    pyautogui.press("o")
    pyautogui.typewrite("Pillow==10.", interval=0.1)
    time.sleep(1.0)

    # Select third version
    for _ in range(3):
        pyautogui.hotkey("ctrl", "n")
        time.sleep(0.5)
    pyautogui.press("enter")

    # Enter normal mode
    pyautogui.press("esc")
    time.sleep(1.0)

    # Change version to earlier one
    pyautogui.press("a")
    pyautogui.press("backspace", presses=3, interval=0.1)
    pyautogui.typewrite("1.0", interval=0.1)
    pyautogui.press("esc")
    time.sleep(1.0)

    # Change version to non-existant one
    pyautogui.press("a")
    pyautogui.press("backspace", presses=3, interval=0.1)
    pyautogui.typewrite("3.0", interval=0.1)
    pyautogui.press("esc")
    time.sleep(1.0)

    # Close demo file
    pyautogui.typewrite(":q!")
    pyautogui.press("enter")
    time.sleep(0.5)

    # Zoom out
    pyautogui.hotkey("command", "0")

    # Transform recording to gif
    os.system("agg --font-family 'Hack Nerd Font Mono' demo.cast demo.gif")

    # Close tmux window
    pyautogui.typewrite("exit")
    pyautogui.press("enter")


if __name__ == "__main__":
    main()
