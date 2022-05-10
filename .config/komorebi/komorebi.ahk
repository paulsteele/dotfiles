#SingleInstance Force

; Enable hot reloading of changes to this file
Run, komorebic.exe watch-configuration enable, , Hide

; Configure the invisible border dimensions
Run, komorebic.exe invisible-borders 7 0 14 7, , Hide

; Enable focus follows mouse
Run, komorebic.exe focus-follows-mouse enable, , Hide

; Ensure there are 5 workspaces created on monitor 0
Run, komorebic.exe ensure-workspaces 0 5, , Hide

; Ensure there are 5 workspaces created on monitor 1
Run, komorebic.exe ensure-workspaces 1 5, , Hide

; Always float IntelliJ popups, matching on class
Run, komorebic.exe float-rule class SunAwtDialog, , Hide
; Always float Control Panel, matching on title
Run, komorebic.exe float-rule title "Control Panel", , Hide
; Always float Task Manager, matching on class
Run, komorebic.exe float-rule class TaskManagerWindow, , Hide

; Always manage forcibly these applications that don't automatically get picked up by komorebi
Run, komorebic.exe manage-rule exe TIM.exe, , Hide

; Identify applications that close to the tray
Run, komorebic.exe identify-tray-application exe Discord.exe, , Hide

; Identify applications that have overflowing borders
Run, komorebic.exe identify-border-overflow exe Discord.exe, , Hide

; Change the focused window, Alt + Vim direction keys
!l::
Run, komorebic.exe focus left, , Hide
return

!j::
Run, komorebic.exe focus down, , Hide
return

!k::
Run, komorebic.exe focus up, , Hide
return

!;::
Run, komorebic.exe focus right, , Hide
return

; Move the focused window in a given direction, Alt + Shift + Vim direction keys
!+l::
Run, komorebic.exe move left, , Hide
return

!+j::
Run, komorebic.exe move down, , Hide
return

!+k::
Run, komorebic.exe move up, , Hide
return

!+;::
Run, komorebic.exe move right, , Hide
return

; Flip horizontally, Alt + X
!x::
Run, komorebic.exe flip-layout horizontal, , Hide
return

; Flip vertically, Alt + Y
!y::
Run, komorebic.exe flip-layout vertical, , Hide
return

; Force a retile if things get janky, Alt + Shift + R
!+r::
Run, komorebic.exe retile, , Hide
return

; Float the focused window, Alt + T
!t::
Run, komorebic.exe toggle-float, , Hide
return

; Reload ~/komorebi.ahk, Alt + O
!o::
Run, komorebic.exe reload-configuration, , Hide
return

; Switch to workspace
!1::
Send !
Run, komorebic.exe focus-monitor-workspace 0 0, , Hide
return

!2::
Send !
Run, komorebic.exe focus-monitor-workspace 0 1, , Hide
return

!3::
Send !
Run, komorebic.exe focus-monitor-workspace 0 2, , Hide
return

!4::
Send !
Run, komorebic.exe focus-monitor-workspace 0 3, , Hide
return

!5::
Send !
Run, komorebic.exe focus-monitor-workspace 0 4, , Hide
return

!6::
Send !
Run, komorebic.exe focus-monitor-workspace 1 0, , Hide
return

!7::
Send !
Run, komorebic.exe focus-monitor-workspace 1 1, , Hide
return

!8::
Send !
Run, komorebic.exe focus-monitor-workspace 1 2, , Hide
return

!9::
Send !
Run, komorebic.exe focus-monitor-workspace 1 3, , Hide
return

!0::
Send !
Run, komorebic.exe focus-monitor-workspace 1 4, , Hide
return

; Move window to workspace
!+1::
; Run, komorebic.exe send-to-monitor-workspace 0 0, , Hide
Run, komorebic.exe send-to-workspace 0, , Hide
return

!+2::
; Run, komorebic.exe send-to-monitor-workspace 0 1, , Hide
Run, komorebic.exe send-to-workspace 1, , Hide
return

!+3::
; Run, komorebic.exe send-to-monitor-workspace 0 2, , Hide
Run, komorebic.exe send-to-workspace 2, , Hide
return

!+4::
; Run, komorebic.exe send-to-monitor-workspace 0 3, , Hide
Run, komorebic.exe send-to-workspace 3, , Hide
return

!+5::
;Run, komorebic.exe send-to-monitor-workspace 0 4, , Hide
Run, komorebic.exe send-to-workspace 4, , Hide
return

!+6::
;Run, komorebic.exe send-to-monitor-workspace 1 0, , Hide
Run, komorebic.exe send-to-workspace 0, , Hide
return

!+7::
;Run, komorebic.exe send-to-monitor-workspace 1 1, , Hide
Run, komorebic.exe send-to-workspace 1, , Hide
return

!+8::
;Run, komorebic.exe send-to-monitor-workspace 1 2, , Hide
Run, komorebic.exe send-to-workspace 2, , Hide
return

!+9::
;Run, komorebic.exe send-to-monitor-workspace 1 3, , Hide
Run, komorebic.exe send-to-workspace 3, , Hide
return

!+0::
;Run, komorebic.exe send-to-monitor-workspace 1 4, , Hide
Run, komorebic.exe send-to-workspace 4, , Hide
return
