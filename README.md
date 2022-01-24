# ScriptEditor
A super simple in-game WoW 1.12 script editor and interpreter.

show the UI with the slash command /sed

Other addons can use the output window for logging by using the globally accessible table ScriptEditor.

## ScriptEditor global object
### ScriptEditor:Log
log text/tables to the OUTPUT tab in SED
### ScriptEditor:Clear
clear the output log

## GUI Buttons
### Exec
Runs the script in the EDIT window after clearing and opening the OUTPUT window.
### Edit
Opens the editor window. Text here will be saved between sessions.
The built-in function print() will print text (and tables) to the OUTPUT window during runtime.

CTRL+Mousewheel scrolls faster.
### Output
Opens the output window

CTRL+Mousewheel scrolls faster.
### Close
Closes the Script Editor
