@echo off
title startup script
nircmd win hide title "startup script"
komorebic start

:wait_komorebi
komorebic state >nul 2>&1 || goto wait_komorebi

:: Configure the invisible border dimensions
komorebic.exe invisible-borders 7 0 14 7

:: Enable focus follows mouse
komorebic.exe focus-follows-mouse disable

:: Ensure there are 5 workspaces created on monitor 0
komorebic.exe ensure-workspaces 0 5

:: Ensure there are 5 workspaces created on monitor 1
komorebic.exe ensure-workspaces 1 5
komorebic.exe workspace-layout 1 0 rows
komorebic.exe workspace-layout 1 1 rows
komorebic.exe workspace-layout 1 2 rows
komorebic.exe workspace-layout 1 3 rows
komorebic.exe workspace-layout 1 4 rows

:: Always float matching on title
komorebic.exe float-rule title "Control Panel"
komorebic.exe float-rule class TaskManagerWindow
komorebic.exe float-rule class ffxiv_dx11.exe
komorebic.exe float-rule class ffxiv.exe
komorebic.exe float-rule class XIVLauncher.exe
komorebic.exe float-rule class Advanced Combat Tracker.exe
komorebic.exe float-rule exe MonsterHunterRise.exe

:: Always manage forcibly these applications that don't automatically get picked up by komorebi
komorebic.exe manage-rule exe TIM.exe
komorebic.exe manage-rule exe rider64.exe


:: Identify applications that close to the tray
komorebic.exe identify-tray-application exe Discord.exe
komorebic.exe identify-border-overflow exe Discord.exe
komorebic.exe identify-tray-application exe steam.exe
komorebic.exe identify-border-overflow exe steam.exe

pythonw C:\Users\Paul_\yasb\src\main.py