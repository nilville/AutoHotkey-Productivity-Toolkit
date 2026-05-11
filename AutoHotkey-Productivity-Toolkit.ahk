	    #NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
OnMessage(0x0138, "WM_CTLCOLORSTATIC")

; ^ = CTRL, # = Win, ! = Alt, + = Shift

;----------------------------------------------------------------------------

;minimize maximize (windowsLogo and downArrow or upArrow)

#Down::WinMinimize, A
return

#Up::WinMaximize, A
return

;----------------------------------------------------------------------------

;Always on top, (Alt and t)

!t::WinSet, AlwaysOnTop, Toggle, A
return

;----------------------------------------------------------------------------

;Open Windows Terminal with Ctrl+Alt+T

!c::
Run, wt
return

;----------------------------------------------------------------------------

;remap alt and F4 with (alt and q)

!q::!F4

;----------------------------------------------------------------------------

;Navigation with IJKL (Alt + I/J/K/L)

!i::Send {Up}
!j::Send {Left}
!k::Send {Down}
!l::Send {Right}

;----------------------------------------------------------------------------

;Volume control, Alt+Scroll wheel (and Mbutton)

Alt & WheelUp::Volume_Up
Alt & WheelDown::Volume_Down
Alt & MButton::Volume_Mute

;----------------------------------------------------------------------------

;Suspend hotkeys with (alt and s)

!s::
suspend, toggle
return

;---------------------------------------------------------------------------

;Search selection with (alt and right mouse button)

!RButton::
{
clipboard=
Send, ^c
Sleep 0025
Run, http://www.google.com/search?q=%clipboard%
Return
}

;---------------------------------------------------------------------------

;Open Gemini website with (Alt + g)

!g::
Run, https://gemini.google.com/
return

;---------------------------------------------------------------------------

; search youtube with (F3) and google/duckduckgo with (F1)

customSearch(service := 1)
{
    global vQuery, Query, _csHwndEdit, _csHwndBtn1, _csHwndBtn2
    static urls := { 0: ""
                 , 1: "https://www.google.com/search?q="
                 , 2: "https://www.youtube.com/results?search_query=" }

    global _csSearchUrl := urls[service]

    Gui, New, +LabelcsDlg +AlwaysOnTop, Search
    Gui, Color, 1e1e1e, 2d2d2d
    Gui, Font, cWhite s12
    Gui, Add, Edit, vQuery w400 hwnd_csHwndEdit r1 -E0x200 +Border
    Gui, Font, cWhite s9
    Gui, Add, Text, g_csSubmit Center 0x200 hwnd_csHwndBtn1 w80 h24, &Search
    Gui, Add, Text, g_csCancel Center 0x200 hwnd_csHwndBtn2 x+8 wp h24, Cancel
    Gui, Add, Button, Default +Hidden g_csSubmit, OK
    Gui, Show, AutoSize Center
    return

    _csSubmit:
    Gui, Submit
    Gui, Destroy
    if (Query != "")
        Run, % _csSearchUrl . UrlEncode(Query)
    return

    csDlgClose:
    csDlgEscape:
    _csCancel:
    Gui, Destroy
    return
}

UrlEncode(str) {
    f := A_FormatInteger
    SetFormat, Integer, Hex
    If RegExMatch(str, "^\w+:/{0,2}", pr)
        StringTrimLeft, str, str, StrLen(pr)

    bufSize := StrPut(str, "UTF-8")
    VarSetCapacity(buf, bufSize)
    StrPut(str, &buf, bufSize, "UTF-8")

    result := ""
    Loop % bufSize - 1
    {
        b := NumGet(&buf, A_Index - 1, "UChar")
        if (b = 0x25)
            result .= "%25"
        else if (b = 0x20)
            result .= "+"
        else if (b >= 0x41 && b <= 0x5A) || (b >= 0x61 && b <= 0x7A) || (b >= 0x30 && b <= 0x39) || b = 0x2D || b = 0x2E || b = 0x5F || b = 0x7E || b = 0x2F || b = 0x3A
            result .= Chr(b)
        else
        {
            h := b | 0x100
            StringRight, hx, h, 2
            result .= "%" . hx
        }
    }

    SetFormat, Integer, %f%
    Return pr . result
}

WM_CTLCOLORSTATIC(wParam, lParam) {
    global _csHwndBtn1, _csHwndBtn2, _csBtnBrush
    if (lParam = _csHwndBtn1 || lParam = _csHwndBtn2) {
        DllCall("SetTextColor", "ptr", wParam, "uint", 0xFFFFFF)
        DllCall("SetBkColor", "ptr", wParam, "uint", 0x003C3C3C)
        if !_csBtnBrush
            _csBtnBrush := DllCall("CreateSolidBrush", "uint", 0x003C3C3C, "ptr")
        return _csBtnBrush
    }
    return 0
}

F1::customSearch(1) ;
F3::customSearch(2) ;

;---------------------------------------------------------------------------

;fast alt tab with (CapsLock)

CapsLock::
send {Alt Down}
sleep 050 ; Add a small delay to prevent crash
send {Tab}
sleep 050 ; Add a small delay to prevent crash
Send {Alt Up}
return

;---------------------------------------------------------------------------
