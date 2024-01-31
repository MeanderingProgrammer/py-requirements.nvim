import time

import pyautogui


def main() -> None:
    # Open new tmux window
    pyautogui.hotkey("`", "c")
    time.sleep(1.0)

    # Open demo file
    file_path = "scripts/demo-requirements.txt"
    pyautogui.typewrite(f"nvim {file_path}")
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

    # Cleanup
    pyautogui.press("d", presses=2)
    pyautogui.typewrite(":q!")
    pyautogui.press("enter")
    time.sleep(0.5)
    pyautogui.typewrite("exit")
    pyautogui.press("enter")


if __name__ == "__main__":
    main()
