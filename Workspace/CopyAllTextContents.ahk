#SingleInstance FORCE
#InstallKeybdHook

Version = 0.1

Gui, 1:New,,%A_ScriptName% %Version%
Gui, 1:Add, Text, , Specify Extension Type to copy
Gui, 1:Add, Edit, vExtensionType w150, txt
Gui, 1:Add, Text, , 1. Navigate to the folder location you wish to copy text contents from
Gui, 1:Add, Text, , 2. Change the edit box to the file extension you wish to copy from
Gui, 1:Add, Text, , 3. Press Ctrl+Alt+Windows+C
Gui, 1:Add, Text, , 4. Press Ok or Cancel button

Gui, 1:Show, AutoSize Center

return

GuiClose:
ExitApp
return

^!#C::
	;Initialise
	Gui, 1:Submit, NoHide
	;ReadExtensionType
	;ExtensionType stores the extension specified
	
	;Check that the currently active window is of Windows Explorer type
	if (!ValidateCurrentActiveWindowClassName("CabinetWClass"))
		return
	
	;Retrieve list of files recursively that fits the Extension Type
	RetrieveListOfFiles(ExtensionType)
	
	;Special case - exit execution if no matching extension types are found
	
	;Confirm with user if they wish to proceed
	
	;Replace clipboard with the copied contents
return

q:: ;process - get path
WinGet, vPID, PID, A
oWMI := ComObjGet("winmgmts:")
oQueryEnum := oWMI.ExecQuery("Select * from Win32_Process where ProcessId=" vPID)._NewEnum()
if oQueryEnum[oProcess]
	vPPath := oProcess.ExecutablePath
oWMI := oQueryEnum := oProcess := ""
MsgBox, % vPPath
return

ReadExtensionType()
{
	
	return ExtensionName
}

ValidateCurrentActiveWindowClassName(expected)
{
	WinGetClass,temp,A
	if (expected = temp)
		return true
	return false
}

RetrieveListOfFiles(extensionType,isrecursive:=false)
{
	if (isrecursive)
		isrecursive := 1
	else
		isrecursive := 0
	WinGet, currentPath, ProcessPath, A
	Loop,%currentPath%,0,%isrecursive%
	{
		if (A_LoopFileExt = extensionType)
		{
			MsgBox hello
		}
	}
}