;#############################################################################################
; IMPORANT WARNING!!!!!
; This software is written for a highly specific use case, and exist in github
; only because i'm too lazy to put it elsewhere.
; I suggest you use it only if you fully understand what it is doing ;)
;#############################################################################################


#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiIPAddress.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <Date.au3>

Opt("GUICloseOnESC",0)
#Region ### START Koda GUI section ### Form=c:\users\tzerber\desktop\georgi.kxf
$hGUI = GUICreate("Dobri's weird program", 337, 165, 192, 124)
$sTargetIp = _GUICtrlIpAddress_Create($hGUI, 80, 8, 130, 21)
_GUICtrlIpAddress_Set($sTargetIp, "0.0.0.0")
$sTargetPort = GUICtrlCreateInput("22", 264, 8, 41, 21,BitOR($GUI_SS_DEFAULT_INPUT,$ES_NUMBER))
$sTargetUser = GUICtrlCreateInput("", 80, 40, 129, 21)
$sTargetPassword = GUICtrlCreateInput("", 80, 64, 129, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$hWorkbookFile = GUICtrlCreateInput("", 80, 96, 129, 21)
$iBrowseButton = GUICtrlCreateButton("Browse", 232, 96, 75, 21)
$HostLabel = GUICtrlCreateLabel("Host:", 8, 8, 35, 20, $SS_CENTER)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
$PortLabel = GUICtrlCreateLabel("Port:", 232, 8, 31, 20)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
$UserLabel = GUICtrlCreateLabel("User:", 8, 40, 36, 20)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
$iStartButton = GUICtrlCreateButton("Start", 16, 128, 75, 25)
$iExitButton = GUICtrlCreateButton("Exit", 120, 128, 75, 25)
$PasswordLabel = GUICtrlCreateLabel("Password:", 8, 64, 67, 20)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
$WorkbookLabel = GUICtrlCreateLabel("Workbook:", 8, 96, 70, 20)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

#Region Variables
Global $hLogfile = FileOpen(@ScriptDir & "\dobri.log", $FO_APPEND)
#EndRegion

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Exit()
		Case $iExitButton
			_Exit()

		Case $iBrowseButton
			$hWorkbook=FileOpenDialog("Select Workbook", @WorkingDir ,"All files (*)")
			GUICtrlSetData($hPlaybookInput,$hWorkbook)
		Case $iStartButton
			;MsgBox(64,"StartButtonDummy","Button Pressed")
			 _SanityCheck()
	EndSwitch
WEnd

Func _ShowSoftwareLoadInstallable ()
EndFunc

Func _SanityCheck($iMaxHostLatency = 250, $iMinPortRange = 20 , $iMaxPortRange = 49151 )
	#Region Check host
	If Ping(_GUICtrlIpAddress_Get($sTargetIp), $iMaxHostLatency) > 0 Then
		_FileWriteLog($hLogfile,"Host " & _GUICtrlIpAddress_Get($sTargetIp) & " found!")
	Else
		If @error Then
			_FileWriteLog($hLogfile,"Host " & _GUICtrlIpAddress_Get($sTargetIp) & " not found or unreachable!")
			MsgBox($MB_ICONERROR,"Host Error","Host is unreachable/down/laggy, check connection!")
			Return False
		EndIf
	EndIf
	#EndRegion

	#Region Check port
	If GUICtrlRead($sTargetPort) < $iMinPortRange Or GUICtrlRead($sTargetPort)  > $iMaxPortRange Then ; 20-49151 is the reasonable TCP port range for ssh. #rfc6056
		_FileWriteLog($hLogfile,"Port " & GUICtrlRead($sTargetPort) & " is not a valid ssh port!")
		MsgBox($MB_ICONERROR,"Port Error","Port appears invalid!")
		Return False
	EndIf
	#EndRegion

	#Region Check username
	If StringInstr(GUICtrlRead($sTargetUser)," ") Then
		_FileWriteLog($hLogfile,"Username " & GUICtrlRead($sTargetUser) & " contain spaces!")
		MsgBox($MB_ICONERROR,"Username Error","Username contain spaces!")
		Return False
	ElseIf StringLen(GUICtrlRead($sTargetUser)) = 0 Then
		_FileWriteLog($hLogfile,"No Username provided!")
		MsgBox($MB_ICONERROR,"Username Error","No Username provided!")
		Return False
	EndIf

	If IsArray(StringRegExp( GUICtrlRead($sTargetUser), "([^\w\h\v]+)", $STR_REGEXPARRAYGLOBALMATCH )) Then
		_FileWriteLog($hLogfile,"Username " & GUICtrlRead($sTargetUser) & " contain special chars or it is not a single word")
		MsgBox($MB_ICONERROR,"Username Error","Username contain special chars or it is not a single word!")
		Return False
	EndIf
	#EndRegion

    #Region Check password
	If StringLen(GUICtrlRead($sTargetPassword)) < 1 Then
		_FileWriteLog($hLogfile,"Password field empty or invalid!")
		MsgBox($MB_ICONERROR,"Password Error", "Password field empty or invalid!")
		Return False
	ElseIf StringLen(GUICtrlRead($sTargetPassword)) < 4 Then
		_FileWriteLog($hLogfile,"Pasword " & GUICtrlRead($sTargetUser) & " appears too short!")
		MsgBox($MB_ICONERROR,"Password Error","Password Appear too short")
		Return False
	EndIf
	#EndRegion

	#Region Check Workbook
	If StringLen(GUICtrlRead($hWorkbookFile)) < 4 Then
		_FileWriteLog($hLogfile,"Workbook field empty or invalid!")
		MsgBox($MB_ICONERROR,"Workbook Error", "Workbook field empty or invalid!")
		Return False
	ElseIf Not FileExists(GUICtrlRead($hWorkbookFile) Then
		_FileWriteLog($hLogfile,"Workbook file missing!")
		MsgBox($MB_ICONERROR,"Workbook Error", "Workbook file is missing!")
		Return False
	EndIf
	#EndRegion

	Return True
EndFunc

Func _ValidateWorkbook()
	;TODO this
	Return True
EndFunc

Func _ExecuteRemoteCommand()
	Local $hPlink = @ScriptDir & "\plink.exe " & "-ssh -batch -4 -noagent -sanitise-stdout "
EndFunc

Func _Exit()
	FileClose($hLogfile)
	Exit
EndFunc