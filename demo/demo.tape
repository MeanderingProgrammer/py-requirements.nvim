Output demo/demo.mp4

Set FontSize 16
Set FontFamily "JetBrainsMono Nerd Font"
Set Width 900
Set Height 800
Set Padding 0
Set Framerate 60
Set TypingSpeed 0.1

# Setup
Hide
Type "nvim demo/requirements.txt" Enter
Show

Sleep 1.5s

# Start typing in new module
Type "o"
Type "Pillow==10."
Sleep 1s

# Select third version
Ctrl+n
Sleep 0.5s
Ctrl+n
Sleep 0.5s
Ctrl+n
Sleep 0.5s
Enter

# Enter normal mode
Escape Sleep 1s

# Non-existant version
Type "a"
Backspace 3
Type "9.0"
Escape Sleep 2s

# Earlier version
Type "a"
Backspace 3
Type "1.0"
Escape Sleep 2s

# Show description of next module
Enter
Type " rd"
Sleep 5s

# Close description
Enter

# Close without editing
Type ":q!"
Hide
Enter
Sleep 100ms
