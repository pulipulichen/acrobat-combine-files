#include <File.au3>
#include <MsgBoxConstants.au3>


; ---------------------

; ���ո��
If $CmdLine[0] = 0 Then
   $CmdLine[0] = 2
   _ArrayAdd($CmdLine, "D:\Desktop\20161122-pudding-bigdata1\20161122-pudding-bigdata1-0001_result_result.jpg")
   _ArrayAdd($CmdLine, "D:\Desktop\20161122-pudding-bigdata1\20161122-pudding-bigdata1-0002_result_result.jpg")

EndIf

Local $debugDisableCreateTempFolder = 0
Local $langBrowseForFolder = "Browse For Folder"
;Local $langCombineFiles = "Combine Files"

; ---------------------

; Ū���]�w��
Local $acrobat= IniRead ( @ScriptDir & "\config.ini", "config", "acrobat", "C:\Program Files (x86)\Adobe\Acrobat DC\Acrobat\Acrobat.exe" )

; �إߤ@�ӼȦs��Ƨ�
; https://www.autoitscript.com/autoit3/docs/libfunctions/_TempFile.htm
Local $sTempFolder = _TempFile()
If $debugDisableCreateTempFolder <> 1 Then
	DirCreate($sTempFolder)
EndIf

   ; ���լݬ�
   ;ConsoleWrite($sTempFolder)
   ;Exit;

; �N�ɮ׽ƻs���Ƨ���
; https://www.autoitscript.com/autoit3/docs/functions/FileCopy.htm
For $i = 1 To $CmdLine[0]
   Local $file = $CmdLine[$i]
   If $debugDisableCreateTempFolder <> 1 Then
		FileCopy($file, $sTempFolder);
   EndIf
Next

Func openAcrobat()

   Local $pdfOpened = WinExists("[CLASS:AcrobatSDIWindow]");

	; �}��Acrobat Pro
	Run($acrobat)
	Local $pdfWin = WinWait("[CLASS:AcrobatSDIWindow]", "", 5)

	If $pdfOpened = False Then
	   ConsoleWrite("Not Opened, open again");
	   Sleep(3000)
	   openAcrobat()
	   Return
	EndIf

	; ���ݵ{���}��
	While 1
	   If $pdfWin <> 0 Then
		  ExitLoop
	   EndIf
	   Run($acrobat)
	   Sleep(5000)
	   $pdfWin = WinWait("[CLASS:AcrobatSDIWindow]", "", 5)
	WEnd

	; �}��Combine��ܵ���
	Sleep(100)
	WinActivate("[CLASS:AcrobatSDIWindow]")
	Send("{ALTDOWN}frm{ALTUP}")

	Local $hWnd = WinWait("[CLASS:AVL_AVWindow]", "", 1)
	While 1
	 If WinExists("[CLASS:AcrobatSDIWindow]") = False Then
		openAcrobat()
		Return
	 EndIf
	 If $hWnd <> 0 Then
		ExitLoop
	 EndIf
	 WinActivate("[CLASS:AcrobatSDIWindow]")
	 Sleep(100)
	 Send("{ALTDOWN}frm{ALTUP}")
	 $hWnd = WinWait("[CLASS:AVL_AVWindow]", "", 3)
	WEnd

    Sleep(100)
	WinActivate($hWnd)

	;ConsoleWrite("WinActivate($hWnd)")


	; �}�Ҹ�Ƨ�����
	; https://www.autoitscript.com/autoit3/docs/functions/ControlCommand.htm
	Sleep(100)
	ControlCommand($hWnd, "", "[CLASS:AVL_AVView; INSTANCE: 26]", "Check");

	WinActivate($hWnd)
	ControlSend($hWnd, "", "", "{DOWN}{DOWN}{ENTER}")

	;ConsoleWrite("ControlCommand")


	; �]�w��Ƨ�
	; "[CLASS:#32770]"
	; Edit1
	Local $winBrowseFolder = WinWait($langBrowseForFolder, "", 1)
	While WinExists($langBrowseForFolder) = False
	   ;ConsoleWrite(WinExists($hWnd))

	   WinActivate($hWnd)
	   ControlCommand($hWnd, "", "[CLASS:AVL_AVView; INSTANCE: 26]", "Check");
	   ControlSend($hWnd, "", "", "{DOWN}{DOWN}{ENTER}")

	   $winBrowseFolder = WinWait($langBrowseForFolder, "", 1)
	WEnd

	;ConsoleWrite("$winBrowseFolder " & $winBrowseFolder)

	ControlSetText($winBrowseFolder, "", "Edit1", $sTempFolder & "\" )
	ControlCommand($winBrowseFolder, "", "Button2", "Check");

    Sleep(100)

	; �T�w
    ControlCommand($hWnd, "", "Button2", "Check");

	; �}�l�X��
	Sleep(3000)
	While 1
	   If WinActive($hWnd) = False Then
		  ExitLoop
	   Else
		  WinActivate($hWnd)
	   EndIf
	   ;ConsoleWrite(WinExists("[CLASS:AVL_AVWindow]"))
	   ;ConsoleWrite(WinExists($langCombineFiles))
	   ;ConsoleWrite(WinExists($hWnd))
	   ;ConsoleWrite(WinActive($hWnd))
	   ;ConsoleWrite(WinExists("[CLASS:AcrobatSDIWindow]"))

	   Sleep(1000)
	WEnd

EndFunc ;Func openAcrobat()

If $CmdLine[0] > 0 Then
	openAcrobat()
EndIf

; ----------------------------------

; ���ݧ����A�R���Ȧs�ɮ�
FileDelete($sTempFolder)

Local $remove_after_finish = IniRead ( @ScriptDir & "\config.ini", "config", "remove_after_finish", "0" )
If $remove_after_finish <> "0" Then
   For $i = 1 To $CmdLine[0]
	  Local $file = $CmdLine[$i]
	  FileRecycle($file);
   Next
EndIf
