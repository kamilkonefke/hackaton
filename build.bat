@echo off

if "%~1"=="-exe" (
    odin build src/ -out:game.exe -debug
) else (
    odin run src/ -out:game.exe -debug
)
