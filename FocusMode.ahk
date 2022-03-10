; TODO Close Browser Tabs by content ;Browsers=Chrome, Firefox, Opera
; TODO Differentiate between closing and minimizing

#Persistent
SetTitleMatchMode, RegEx
Menu, Tray, Icon, icon.ico
; "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"

AppName := "Focus Mode"

; MinimizeNames := [".ahk", "YouTube", "Twitter", "GIMP", "Discord", "Spotify"]

Terminate() {
    MsgBox, 0, %AppName%, FocusMode will be closed now.
    ExitApp
}

global MinimizeContent
global CloseContent
global FocusMessageEnabled
global FocusMessageContent
global CloseAndStopAudio

ReadIni() {
    IniRead, MinimizeContent, Settings.ini, Settings, MinimizeContent
    if (MinimizeContent = "ERROR" || MinimizeContent = "" || MinimizeContent = " ")
        throw
    IniRead, CloseContent, Settings.ini, Settings, CloseContent
    if (CloseContent = "ERROR" || CloseContent = "" || CloseContent = " ")
        throw
    IniRead, FocusMessageEnabledIni, Settings.ini, Setup, FocusMessageEnabled
    FocusMessageEnabled := FocusMessageEnabledIni = "true"
    IniRead, FocusMessageContent, Settings.ini, Costumization, FocusMessageContent
}

try {
    ReadIni()
} catch e {
    MsgBox, 0, %AppName%, Please provide a valid Settings.ini file in the location of the .exe or follow reinstallation instructions.
    Terminate()
}

global MinimizeNames := StrSplit(MinimizeContent, ",", " `t")
global CloseNames := StrSplit(CloseContent, ",", " `t")

MsgBox % AppName " is now active. You can disable it by going into Windows System Tray, rightclicking on the FocusMode Script Icon and clicking on Exit. `nWindows Containing '" Concat(MinimizeNames) "' will be kept in the taskbar. `nWindows containing '" Concat(CloseNames) "' will be closed."

SetTimer, Timer, 2000
return

Timer:
;MsgBox % "Timer running."
; Try to see if current window matches something every few seconds
CheckWindow()
return

CheckWindow() {
    WinGet, NewID, ID, A
    ; If the window didn't change don't waste resources
    if (NewID != CurrID) {
        CurrID := NewID
        ; If window name is in close names array
        if (CanMatchWindow(CloseNames, CurrID)) {
            WinClose, ahk_id %CurrID%
            ; MsgBox, 0, Ahk, %CurrID%
            MsgBox, 0, %AppName%, Application close rule.
            MsgBox % FocusMessageEnabled
            if (FocusMessageEnabled)
                MsgBox % FocusMessageContent
        ; If window name is in minimize names array
        } else if (CanMatchWindow(MinimizeNames, CurrID)) {
            WinMinimize, ahk_id %CurrID%
            if (FocusMessageEnabled)
                MsgBox % FocusMessageContent
        }
    }
    return
}

CanMatchWindow(NamesArray, WindowID) {
    ; loop over names array
    for index, element in NamesArray {
        ; if current window contains title return true
        WinGetTitle, this_title, ahk_id %WindowID%
        If RegExMatch(this_title, element) {
            MsgBox % element
            ; MsgBox % WindowID "/" this_title "/" element "/" index "/" W
            return true
        }
    }
    return false
}


Concat(Array) {
    Concat := ""
    For Each, Element In Array {
        If (Concat <> "") ; Concat is not empty, so add a line feed
            Concat .= ", "
        Concat .= Element
    }
    return Concat
}