#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetCapsLockState, AlwaysOff

CapsLock & w::
If GetKeyState("LAlt", "P")
 Send #{Tab}
Else
 Send {Up}
return

CapsLock & a::
If GetKeyState("LAlt", "P")
 Send #^{Left}
Else
 Send {Left}
return

CapsLock & s::
If GetKeyState("LAlt", "P")
 Send #{Tab}
Else
 Send {Down}
return

CapsLock & d::
If GetKeyState("LAlt", "P")
 Send #^{Right}
Else
 Send {Right}
return

Capslock & XButton1::Send #^{Left}
Capslock & XButton2::Send #^{Right}
Capslock & F11::Send #{Tab}

Capslock::return

Pause::
    SetCapsLockState, % (GetKeyState("CapsLock", "T") ? "Off" : "On")
return
