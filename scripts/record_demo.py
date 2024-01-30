import time

import pyautogui


# WIP
def main() -> None:
    open_tmux_window()
    pyautogui.typewrite("Hello world!\n")


def open_tmux_window() -> None:
    pyautogui.hotkey("`", "c")
    time.sleep(1.0)


if __name__ == "__main__":
    main()
