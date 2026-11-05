@echo off
setlocal
set "GODOT_EXE=%GODOT4%"
if not defined GODOT_EXE set "GODOT_EXE=%USERPROFILE%\Documents\Godot_v4.7.2-stable_mono_win64\Godot_v4.7.2-stable_mono_win64.exe"
if not exist "%GODOT_EXE%" (
	echo Godot 4 executable not found: "%GODOT_EXE%"
	echo Set GODOT4 to the path of your Godot 4 executable and try again.
	pause
	exit /b 1
)
start "" "%GODOT_EXE%" --path "%~dp0"
