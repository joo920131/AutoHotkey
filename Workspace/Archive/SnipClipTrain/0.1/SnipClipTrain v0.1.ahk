#SingleInstance FORCE
#InstallKeybdHook
SetKeyDelay,0,0

Version = 0.1

/*Description
SnipClipTrain is created for pasting multiple screenshots using Windows 10 feature of Snipping Tool clip function  (via using Shift + Windows + S).
For more detail of SnipClip, refer to below link:
https://www.howtogeek.com/352290/using-windows-10s-new-screenshot-tool-clips-and-annotations/
https://www.howtogeek.com/351978/using-windows-10s-new-clipboard-history-and-cloud-sync/

You can also launch it via running the following command in CMD.exe
> snippingtool.exe /clip

Main usage is:
-	Windows + S: Launch Snipping Clip feature of Windows 10 for taking screen shot (via using Shift + Windows + S)
-	Windows + V: Paste all copied contents
-	Windows + X: Reset clipboard histories
*/

/* Release Notes
0.1	JaeJ
- Created as per the description
*/

;======================================
;Defaults
;~ ClipArray := []		;Future work - to replace pseudo-array "ca"
c   := 0
;======================================

return
/*
#S# MAIN
*/

;===================================================
;Windows10 only - launch snip clip
;===================================================
#s::
;~ Send, +#s	; Replaced by launching snippingtool.exe /clip via CMD.exe
;~ ClipWait,3,1
DetectHiddenWindows On
; Launch snipping tool in clip mode (Shift Windows S)
Run, %ComSpec% /c snippingtool.exe /clip,,hide,cmdpid_SnippingToolClip
WinWait,ahk_pid %cmdpid_SnippingToolClip%,,3

; Wait until the launched snippingtool.exe does not exist (user could take a screenshot, or not)
; Previously, ClipboardChange function was used.
clipWaitChangeMessage := SnippingToolClipWait(cmdpid_SnippingToolClip)
;~ ToolTip,%clipWaitChangeMessage%
;~ ClipArray.Push(ClipboardAll)

; Increase counter for pseudo array
c++
ca%c% := ClipboardAll
return

;===================================================
;Paste all
;===================================================
#v::
tooltipTxt := "Pasting (" . c . ") contents..."
ToolTip,%tooltipTxt%
SetTimer,RemoveTooltips,-5000
tempClip := ClipboardAll
Loop, %c%
{
	temp := ca%A_Index%
	ClipPaste(temp)
}
Clipboard := tempClip
return
;===================================================
; Reset clipboard history
;===================================================
#x::

tooltipTxt := "Snip clip histories are cleared."
ToolTip,%tooltipTxt%
SetTimer,RemoveTooltips,-5000

Loop, %c%
{
	ca%A_Index% :=
}
c := 0
return

;===========================================================
;#S# Subroutines
;===========================================================

;===========================================================
;	Subroutines: Timers
;===========================================================

RemoveTooltips:
ToolTip
return

;===========================================================
;~ #S# Functions
;===========================================================

;===========================================================
;	Functions: Clipboard Copy, Paste, Wait
;===========================================================
/*
Copied functions from the below AHK thread
https://autohotkey.com/board/topic/111817-robust-copy-and-paste-routine-function/

Slightly modified to work with image files
======================================
Challenges using Clipboard:
the real issue i've found is when a program actually stores the "clipboard" contents elsewhere in memory.
i have a program in which i thought i could use ahk to store clipboards for later retrieval. it indeed does store some information in the clipboard, but apparently it stores crucial info elsewhere. merely storing the clipboard info retrieved the standard way, and then moving it back to the clipboard at a later time and sending [ctrl+v], does not work.
i wonder if anyone ever tried some memory hacking to get around this issue.
i suppose most software does not behave this way so it may not have become an issue to many users...
======================================
*/

ClipCopy(piMode := 0)
{
    clpBackup := ClipboardAll

    Clipboard=

    if (piMode == 1)
        sCopyKey := "vk58sc02D" ; Cut
    else
        sCopyKey := "vk43sc02E" ; Copy

    SendInput, {Shift Down}{Shift Up}{Ctrl Down}{%sCopyKey% Down}
    ClipWait, 0.25
    SendInput, {%sCopyKey% Up}{Ctrl Up}

    sRet := Clipboard

    Clipboard := clpBackup

    return sRet
}

ClipPaste(ByRef psClipboardContent)
{

	clpBackup := ClipboardAll

	sPasteKey := "vk56sc02F" ; Paste

	Clipboard := psClipboardContent

	SendInput, {Shift Down}{Shift Up}{Ctrl Down}{%sPasteKey% Down}

	; wait for clipboard is ready
	iStartTime := A_TickCount
	Sleep, % 100
	while (DllCall("GetOpenClipboardWindow") && (A_TickCount-iStartTime<1400)) ; timeout = 1400ms
		Sleep, % 100
	
	SendInput, {%sPasteKey% Up}{Ctrl Up}

	Clipboard := clpBackup
}


;===========================================================
/*
Copied from the below thread
https://autohotkey.com/board/topic/56555-waiting-for-clipboard-change-even-when-empty-text-is-copied/

Commented out now as it is not in use...
*/
;===========================================================
;~ ClipWaitChange(p_timeout_ms="", p_waitfor="", p_returnnum="", pid_snip="") {
	;~ waiting=1
	;~ ts_begin:=A_TickCount
	;~ Loop {
		;~ if (ClipboardType!="" && (p_waitfor="" || p_waitfor=ClipboardType  || p_waitfor=ClipboardTypeStr)) {
			;~ ;//Tooltip, %A_ThisFunc% done (%ClipboardType%), 519, 519, 2
			;~ return (!p_returnnum) ? ClipboardTypeStr:ClipboardType
		;~ }
		;~ Sleep, 19
		;~ ms_waited:=A_TickCount-ts_begin
		;~ if (ms_waited>=p_timeout_ms) {
			;~ return (!p_returnnum) ? "timeout (" ms_waited ")":-ms_waited
		;~ }
		;~ if (pid_snip!="" && !SnippingToolClipExists(p_pidwait))
		;~ {
			;~ return "snippingtool.exe closed"
		;~ }
	;~ }
	;~ return

	;~ OnClipboardChange:
	;~ if (!waiting) {
		;~ ;//Tooltip, return !waiting OnClipboardChange(%A_EventInfo%), 519, 519, 2
		;~ return
	;~ }
	;~ ClipboardType:=A_EventInfo
	;~ ClipboardTypeStr:=(ClipboardType=0)
		;~ ? "empty":(ClipboardType=1)
		;~ ? "text":(ClipboardType=2)
		;~ ? "binary":"unknown(" ClipboardType ")"
	;~ return
;~ }


;===========================================================
;	Functions: Snipping Tool PID check, wait
;===========================================================
;===========================================================
/*
https://autohotkey.com/board/topic/36888-display-pid-list/

GetPIDList is no longer used but left here as a reference
*/
;===========================================================
GetPIDList()
{
	DetectHiddenWindows, On 
	exe_list = 
	WinGet, id_lsit, List 

	Loop %id_lsit% 
	{
	WinGet, PID, PID, % "ahk_id " . id_lsit%A_Index%
	IfNotInString, PID_list, %PID%`n
	PID_list := PID_list . PID . "`n"
	}
	return PID_list
}

SnippingToolClipExists(pid_snip)
{
	Process,Exist,%pid_snip%
	if (ErrorLevel = 0)
		return false
	return true
}
SnippingToolClipWait(pid_snip, p_timeout_ms:=10000)
{
	if (pid_snip != "")
	{
		ts_begin:=A_TickCount
		Loop {
		if (!SnippingToolClipExists(pid_snip)) {
			return "snippingtool.exe closed"
		}
		
		ms_waited:=A_TickCount-ts_begin
		if (ms_waited>=p_timeout_ms) {
			return "timeout (" ms_waited ")"
		}
		Sleep, 19
		}
	}
}