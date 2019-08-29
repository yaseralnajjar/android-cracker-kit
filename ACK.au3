#RequireAdmin
#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=inc\icon_small.ico
#AutoIt3Wrapper_Outfile=ACK.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;*****************************************
;ACK.au3 by ZR
;Created with ISN AutoIt Studio v. 0.97 BETA
;You have to edit this in form1.isf after using ISN :
;$comTab = GUICtrlCreateTabItem("Commands")
;GUICtrlCreatePic fix it into: @HomeDrive & "\" & "acktools\incl\ack.jpg"
;*****************************************

Global $ack_dir, $file, $ini, $pid

FileInstall("inc\ack.jpg", @HomeDrive & "\" & "acktools\incl\ack.jpg", 8)
Opt("GUIResizeMode", 802) ; $GUI_DOCKALL
#include <FileConstants.au3>
#include <Constants.au3>
;#include <GDIPlus.au3>
#include "Forms\form1.isf"

GUISetBkColor(0xf0f0f0, $form1)

Init()
GUISetState(@SW_SHOW)

#cs
	_GDIPlus_Startup()
	$hImage   = _GDIPlus_ImageLoadFromFile($ack_dir &  "incl\ack.png")
	; Draw PNG image
	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($form1)
	;_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, 0, 0)
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage,0,0,509,89)
#ce

GUIRegisterMsg(0x233, "On_WM_DROPFILES")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			If GUICtrlRead($GoIDA_btn) = "Stop IDA" Then IDAGo()
			#cs
				_GDIPlus_GraphicsDispose($hGraphic)
				_GDIPlus_ImageDispose($hImage)
				_GDIPlus_ShutDown()
			#ce
			GUIDelete($form1)
			Exit
		Case $browse_J1_btn
			$file = FileOpenDialog("Choose a java decompiler", $ack_dir, "Exe file (*.exe)|Java app (*.jar)", $FD_FILEMUSTEXIST + $FD_PATHMUSTEXIST, Default, $form1)
			If $file <> "" Then
				IniWrite($ini, "config", "J1", $file)
				GUICtrlSetData($PrefJ1, $file)
			EndIf

		Case $browse_J2_btn
			$file = FileOpenDialog("Choose a java decompiler", $ack_dir, "Exe file (*.exe)|Java app (*.jar)", $FD_FILEMUSTEXIST + $FD_PATHMUSTEXIST, Default, $form1)
			If $file <> "" Then
				IniWrite($ini, "config", "J2", $file)
				GUICtrlSetData($PrefJ2, $file)
			EndIf

		Case $Browse_apktool_btn
			$file = FileOpenDialog("Choose ApkTool file", $ack_dir, "Java app (*.jar)", $FD_FILEMUSTEXIST + $FD_PATHMUSTEXIST, Default, $form1)
			If $file <> "" Then GUICtrlSetData($apktool_input, $file)

		Case $Browse_adb_btn
			$file = FileOpenDialog("Choose adb file", $ack_dir, "Exe file (*.exe)", $FD_FILEMUSTEXIST + $FD_PATHMUSTEXIST, Default, $form1)
			If $file <> "" Then GUICtrlSetData($ADB_input, $file)

		Case $InstallADB_btn
			InstallADB()
		Case $InstallApkTool_btn
			InstallApkTool()

		Case $AutoGen_chk
			If GUICtrlRead($AutoGen_chk) = 1 Then IniWrite($ini, "config", "AutoNG", "1")
			If GUICtrlRead($AutoGen_chk) = 4 Then IniWrite($ini, "config", "AutoNG", "0")
		Case $Shell_chk
			If GUICtrlRead($Shell_chk) = 1 Then
				IniWrite($ini, "config", "Shell", "1")
				RegWrite("HKEY_CLASSES_ROOT\.apk\shell\--> Android Cracker Kit <--\command", "", "REG_SZ", '"' & @ScriptFullPath & '" "%1"')
			EndIf
			If GUICtrlRead($Shell_chk) = 4 Then
				IniWrite($ini, "config", "Shell", "0")
				RegDelete("HKEY_CLASSES_ROOT\.apk\shell\--> Android Cracker Kit <--")
			EndIf

		Case $Browse_apk_btn
			$file = FileOpenDialog("Choose apk file", $ack_dir, "Android apps (*.apk)", $FD_FILEMUSTEXIST + $FD_PATHMUSTEXIST, Default, $form1)
			ApkChangeInput()
			GUICtrlSetState($comTab, 16)
		Case $Explore_btn
			If FileExists(GUICtrlRead($OutDir_input)) Then ShellExecute(GUICtrlRead($OutDir_input))

		Case $smali_de_btn
			SmaliDecompile()
		Case $Ext_dex_btn
			ExtractDex()
		Case $Dex2Jar_btn
			Dex2Jar()
		Case $Java_Src_Ext_btn
			SourceExtract()
		Case $OpenJ1_btn
			OpenJ(1)
		Case $OpenJ2_btn
			OpenJ(2)
		Case $OpnManifest_btn
			OpenManifest()
		Case $Build_btn
			Build()
		Case $Open_build_dir_btn
			OpenBuildDir()
		Case $SignAPK_btn
			SignApk()
		Case $Zip_align_btn
			ZipAlign()
		Case $Pass_arg_btn
			PassArgs()
		Case $do_it_all_btn
			DoItAll()
		Case $recompile_all_btn
			Recompile()
		Case $install_apk_btn
			InstallApkIntoDevice()
		Case $GoIDA_btn
			IDAGo()
		Case $Connect_btn
			ADBConnect()
		Case $devices_btn
			ADBDevices()
		Case $adbshell_btn
			ADBShell()
		Case $andrserver_copy_btn
			CopyAndrServer()
		Case $adb_forward_btn
			ADBForward()
		Case $run_andrserver_btn
			RunAndrServer()
		Case $run_gdb_btn
			RunGdbServer()
		Case $adb_shell_stop_btn
			ADBShell_stop()
		Case $pass_ida_btn
			PassIDA()
	EndSwitch
	Select
		Case $Apk_input Or $OutDir_input Or $apktool_input Or $ADB_input
			EnDis()
	EndSelect

WEnd
Func EnDis()
	If GUICtrlRead($Apk_input) = "" Or GUICtrlRead($OutDir_input) = "" Then
		If GUICtrlGetState($do_it_all_btn) = 80 Then GUICtrlSetState($do_it_all_btn, 144)
		If GUICtrlGetState($recompile_all_btn) = 80 Then GUICtrlSetState($recompile_all_btn, 144)
		If GUICtrlGetState($Java_Src_Ext_btn) = 80 Then GUICtrlSetState($Java_Src_Ext_btn, 144)
		If GUICtrlGetState($OpnManifest_btn) = 80 Then GUICtrlSetState($OpnManifest_btn, 144)
		If GUICtrlGetState($Pass_arg_btn) = 80 Then GUICtrlSetState($Pass_arg_btn, 144)
		If GUICtrlGetState($OpenJ1_btn) = 80 Then GUICtrlSetState($OpenJ1_btn, 144)
		If GUICtrlGetState($OpenJ2_btn) = 80 Then GUICtrlSetState($OpenJ2_btn, 144)
		If GUICtrlGetState($SignAPK_btn) = 80 Then GUICtrlSetState($SignAPK_btn, 144)
		If GUICtrlGetState($Zip_align_btn) = 80 Then GUICtrlSetState($Zip_align_btn, 144)
		If GUICtrlGetState($Open_build_dir_btn) = 80 Then GUICtrlSetState($Open_build_dir_btn, 144)
		If GUICtrlGetState($install_apk_btn) = 80 Then GUICtrlSetState($install_apk_btn, 144)
		If GUICtrlGetState($Dex2Jar_btn) = 80 Then GUICtrlSetState($Dex2Jar_btn, 144)
		If GUICtrlGetState($Build_btn) = 80 Then GUICtrlSetState($Build_btn, 144)
		If GUICtrlGetState($smali_de_btn) = 80 Then GUICtrlSetState($smali_de_btn, 144)
		If GUICtrlGetState($Ext_dex_btn) = 80 Then GUICtrlSetState($Ext_dex_btn, 144)
	EndIf

	If GUICtrlRead($Apk_input) <> "" And GUICtrlRead($OutDir_input) <> "" Then
		If GUICtrlGetState($do_it_all_btn) = 144 Then GUICtrlSetState($do_it_all_btn, 80)
		If GUICtrlGetState($recompile_all_btn) = 144 Then GUICtrlSetState($recompile_all_btn, 80)
		If GUICtrlGetState($Java_Src_Ext_btn) = 144 Then GUICtrlSetState($Java_Src_Ext_btn, 80)
		If GUICtrlGetState($OpnManifest_btn) = 144 Then GUICtrlSetState($OpnManifest_btn, 80)
		If GUICtrlGetState($Pass_arg_btn) = 144 Then GUICtrlSetState($Pass_arg_btn, 80)
		If GUICtrlGetState($OpenJ1_btn) = 144 Then GUICtrlSetState($OpenJ1_btn, 80)
		If GUICtrlGetState($OpenJ2_btn) = 144 Then GUICtrlSetState($OpenJ2_btn, 80)
		If GUICtrlGetState($SignAPK_btn) = 144 Then GUICtrlSetState($SignAPK_btn, 80)
		If GUICtrlGetState($Zip_align_btn) = 144 Then GUICtrlSetState($Zip_align_btn, 80)
		If GUICtrlGetState($Open_build_dir_btn) = 144 Then GUICtrlSetState($Open_build_dir_btn, 80)
		If GUICtrlGetState($install_apk_btn) = 144 Then GUICtrlSetState($install_apk_btn, 80)
		If GUICtrlGetState($Dex2Jar_btn) = 144 Then GUICtrlSetState($Dex2Jar_btn, 80)
		If GUICtrlGetState($Build_btn) = 144 Then GUICtrlSetState($Build_btn, 80)
		If GUICtrlGetState($smali_de_btn) = 144 Then GUICtrlSetState($smali_de_btn, 80)
		If GUICtrlGetState($Ext_dex_btn) = 144 Then GUICtrlSetState($Ext_dex_btn, 80)
	EndIf

	If GUICtrlRead($GoIDA_btn) = "Stop IDA" Then
		If Not ProcessExists($pid) Then
			IDAGo()
		Else
			If GUICtrlRead($IDA_input) = "" Then
				If GUICtrlGetState($pass_ida_btn) = 80 Then GUICtrlSetState($pass_ida_btn, 144)
			EndIf
			If GUICtrlRead($IDA_input) <> "" Then
				If GUICtrlGetState($pass_ida_btn) = 144 Then GUICtrlSetState($pass_ida_btn, 80)
			EndIf
		EndIf
	EndIf

	If GUICtrlRead($ADB_input) = "" Then
		If GUICtrlGetState($InstallADB_btn) = 80 Then GUICtrlSetState($InstallADB_btn, 144)
	EndIf
	If GUICtrlRead($ADB_input) <> "" Then
		If GUICtrlGetState($InstallADB_btn) = 144 Then GUICtrlSetState($InstallADB_btn, 80)
	EndIf
	If GUICtrlRead($apktool_input) = "" Then
		If GUICtrlGetState($InstallApkTool_btn) = 80 Then GUICtrlSetState($InstallApkTool_btn, 144)
	EndIf
	If GUICtrlRead($apktool_input) <> "" Then
		If GUICtrlGetState($InstallApkTool_btn) = 144 Then GUICtrlSetState($InstallApkTool_btn, 80)
	EndIf
EndFunc   ;==>EnDis
Func Init()
	Global $file = ""
	Global $ack_dir = @HomeDrive & "\" & "acktools\"
	Global $ack_out = $ack_dir
	Global $ini = @ScriptDir & "\" & "config.ini"
	Global $J1_path = IniRead($ini, "config", "J1", "")
	Global $J2_path = IniRead($ini, "config", "J2", "")
	Global $Auto_cfg = IniRead($ini, "config", "AutoNG", "")
	Global $Shell_cfg = IniRead($ini, "config", "Shell", "")
	Global $IDA_shell = 0
	Global $IDA_server = 0
	Global $IDA_output_sh = ""

	If Not FileExists($J1_path) Then
		GUICtrlSetData($PrefJ1, "")
		IniWrite($ini, "config", "J1", "")
	Else
		GUICtrlSetData($PrefJ1, $J1_path)
	EndIf

	If Not FileExists($J2_path) Then
		GUICtrlSetData($PrefJ2, "")
		IniWrite($ini, "config", "J2", "")
	Else
		GUICtrlSetData($PrefJ2, $J2_path)
	EndIf

	$J1_path = IniRead($ini, "config", "J1", "")
	$J2_path = IniRead($ini, "config", "J2", "")

	If $J1_path = "" Then IniWrite($ini, "config", "J1", @ScriptDir & "\incl\jd-gui.exe")
	If $J2_path = "" Then IniWrite($ini, "config", "J2", @ScriptDir & "\incl\luyten-0.4.3.exe")

	If $Auto_cfg = 1 Then GUICtrlSetState($AutoGen_chk, 1)
	If $Shell_cfg = 1 Then GUICtrlSetState($Shell_chk, 1)

	If Not FileExists($ack_dir) Then
		If DirCreate($ack_dir) = 0 Then
			WriteLog("Can't create %homedrive%\acktools directory")
		Else
			WriteLog('"' & $ack_dir & '"' & " was created successfully")
		EndIf
	EndIf

	If Not FileExists($ack_dir & "incl\") Then
		If DirCreate($ack_dir & "incl\") = 0 Then
			WriteLog("Can't create %homedrive%\acktools\incl\ directory")
		Else
			WriteLog('"' & $ack_dir & 'incl\"' & " was created successfully")
		EndIf
	EndIf

	If CheckJava() <> 1 Then WriteLog("JRE is not installed >> JRE 7 is recommended")
	If CheckApkTool() <> 1 Then WriteLog("ApkTool is not installed >> go to config to install it")
	If CheckADB(1) <> 1 Then WriteLog("ADB is not installed >> go to config to install it")

	If $CmdLine[0] = 1 Then
		GUICtrlSetState($Apk_input, $CmdLine[1])
		$file = $CmdLine[1]
		ApkChangeInput()
		GUICtrlSetState($comTab, 16)
	EndIf

	FileInstall("inc\7z.exe", $ack_dir & "\incl\7z.exe", 0)
	FileInstall("inc\7z.dll", $ack_dir & "\incl\7z.dll", 0)
	FileInstall("inc\incl.zip", $ack_dir & "\incl\incl.zip", 0)
	FileInstall("inc\jd.jar", $ack_dir & "\incl\jd.jar", 0)

	If Not FileExists($ack_dir & "\incl\7z.exe") Then WriteLog("Cannot copy 7z.exe >> try fix this is, otherwise this tool won't work properly !" & @CRLF & '>> Check admin authentication or disable UAC to fix this')
	If Not FileExists($ack_dir & "\incl\7z.dll") Then WriteLog("Cannot copy 7z.dll >> try fix this is, otherwise this tool won't work properly !" & @CRLF & '>> Check admin authentication or disable UAC to fix this')
	If Not FileExists($ack_dir & "\incl\jd.jar") Then WriteLog("Cannot copy jd.jar >> try fix this is, otherwise this tool won't work properly !" & @CRLF & '>> Check admin authentication or disable UAC to fix this')
	If Not FileExists($ack_dir & "\incl\incl.zip") Then WriteLog("Cannot copy required included files >> try fix this is, otherwise this tool won't work properly !" & @CRLF & '>> Check admin authentication or disable UAC to fix this')
	If FileExists($ack_dir & "\incl\incl.zip") Then
		If Not FileExists($ack_dir & "\incl\android_server") Or Not FileExists($ack_dir & "\incl\gdbserver") Or Not FileExists($ack_dir & "\incl\d2j\") Or Not FileExists($ack_dir & "\incl\za.exe") Or Not FileExists($ack_dir & "\incl\sa\") Then
			Run($ack_dir & "\incl\7z.exe x incl.zip -aos", $ack_dir & "\incl\", @SW_HIDE)
			WriteLog("All files extracted successfully")
		EndIf
	EndIf

EndFunc   ;==>Init

Func CheckJava()
	Local $x = _RunCmd("java -version")
	If StringLeft($x, 8) = "java ver" Then Return 1
	Return 0
EndFunc   ;==>CheckJava

Func CheckApkTool()
	Local $x = _RunCmd("apktool")
	If StringMid($x, 1, 27) = "'apktool' is not recognized" Or StringMid($x, 1, 27) = "Error: Unable to access jar" Then Return 0
	Return 1
EndFunc   ;==>CheckApkTool

Func CheckADB($deter)
	;local $x = _RunCmd("adb")
	;MsgBox(64, "", $x)
	;if StringMid($x, 1, 23) = "'adb' is not recognized" then Return 0
	Local $path_env = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "PATH")
	Local $x = StringSplit($path_env, ";")
	For $i = 1 To $x[0]
		If FileExists($x[$i] & "\adb.exe") Then Return 1
	Next
	Return 0
EndFunc   ;==>CheckADB

Func InstallApkTool()
	Local $x = 1
	If CheckApkTool() = 1 Then
		$x = MsgBox(64 + 4, "ApkTool is existed", "It's already installed" & @CRLF & "Do you want to reinstall it ? ")
		If $x = 6 Then $x = 1
	EndIf
	If $x = 1 Then
		Local $apktool_path = GUICtrlRead($apktool_input)
		If FileExists($apktool_path) Then
			$x = FileCopy($apktool_path, @WindowsDir & "\" & "apktool.jar", 1)
			If $x = 1 Then
				FileDelete(@WindowsDir & "\" & "apktool.bat")
				FileWrite(@WindowsDir & "\" & "apktool.bat", "set PATH=%CD%;%PATH%;" & @CRLF & 'java -jar -Duser.language=en "%~dp0\apktool.jar" %1 %2 %3 %4 %5 %6 %7 %8 %9')
				ShellExecute(@WindowsDir & "\" & "apktool.bat")
				MsgBox(64, "Success", "Apktool was installed successfully" & @CRLF & 'It is recommended to check in cmd by writing "apktool" command')
			Else
				MsgBox(16, "Error", "Cannot copy apktool.jar into Windows folder !" & @CRLF & "Check whether it is used in memory")
			EndIf
		Else
			MsgBox(16, "Error", "The chosen apktool you selected is not existed !")
		EndIf
	EndIf
	$apktool_path = GUICtrlRead($apktool_input)
EndFunc   ;==>InstallApkTool

Func InstallADB()
	Local $path_env = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "PATH")
	Local $x = StringSplit($path_env, ";")
	Local $y = 0
	For $i = 1 To $x[0]
		If FileExists($x[$i] & "\adb.exe") Then $y = 1
	Next
	If $y = 0 Then
		Local $adb_path = GUICtrlRead($ADB_input)
		Local $adb_path_dir = StringReverse($adb_path)
		$adb_path_dir = StringMid($adb_path_dir, StringInStr($adb_path_dir, "\") + 1)
		$adb_path_dir = StringReverse($adb_path_dir)
		If FileExists($adb_path) Then
			RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "PATH", "REG_SZ", $path_env & ";" & $adb_path_dir)
			EnvUpdate()
			MsgBox(64, "Success", "ADB was installed successfully" & @CRLF & 'It is recommended to check in cmd by writing "adb" command')
		Else
			MsgBox(16, "Error", "The adb file you have chosen doesn't exist")
		EndIf
	Else
		MsgBox(64, "Error", "It's already installed in this dir:" & @CRLF & $x[$i - 1] & "\adb.exe")
	EndIf
EndFunc   ;==>InstallADB

Func ApkChangeInput()

	If $file <> "" And GUICtrlRead($AutoGen_chk) = 1 Then
		GUICtrlSetData($Apk_input, $file)
		$x = 1
		While 1
			If FileExists($ack_out & $x) Then
				$x += 1
			Else
				GUICtrlSetData($OutDir_input, $ack_out & "prjs\" & $x & "\")
				ExitLoop
			EndIf
		WEnd
	ElseIf $file <> "" Then
		GUICtrlSetData($Apk_input, $file)
		$x = StringReverse($file)
		$x = StringMid($x, 5, StringInStr($x, "\") - 5)
		$x = StringReverse($x)
		GUICtrlSetData($OutDir_input, $ack_out & "prjs\" & $x & "\")
	EndIf
EndFunc   ;==>ApkChangeInput

Func WriteLog($str)
	Local $read = GUICtrlRead($log)
	$read = $read & @CRLF & $str
	GUICtrlSetData($log, $read)
EndFunc   ;==>WriteLog

Func _RunCmd($sCommand)
	If StringLeft($sCommand, 1) = " " Then $sCommand = " " & $sCommand

	Local $nPid = Run(@ComSpec & " /c" & $sCommand, "", @SW_HIDE, 8), $sRet = ""
	If @error Then Return "ERROR:" & @error
	ProcessWait($nPid)
	While 1
		$sRet &= StdoutRead($nPid)
		If @error Or (Not ProcessExists($nPid)) Then ExitLoop
	WEnd
	Return $sRet
EndFunc   ;==>_RunCmd

Func SmaliDecompile()
	Local $file = GUICtrlRead($Apk_input)
	Local $out = GUICtrlRead($OutDir_input)
	Local $x = 1
	Local $y
	If Not FileExists($file) Then
		MsgBox(16, "Error", "The chosen apk file doesn't exist")
	Else
		If FileExists($out) Then
			$x = MsgBox(64 + 4, "Overwrite ?", "The output dir is already existed" & @CRLF & "Do you want to overwrite it ?")
			If $x = 6 Then $x = 1
		EndIf

		If $x = 1 Then
			$y = FileCopy($file, $out & "1.apk", 8 + 1)
			If $y = 0 Then MsgBox(16, "Error", "Cannot copy apk to the destination folder")
			If $y = 1 Then
				;local $CMD = "cd " & '"' & $out & '" && ' & _
				Local $CMD = 'apktool d -f 1.apk && ' & _
						'pause && ' & _
						'exit'
				Run('"' & @ComSpec & '" /k ' & $CMD, $out, @SW_SHOW)
				;Run('"' & @ComSpec & '" /k ' & $CMD, @SystemDir)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>SmaliDecompile

Func ExtractDex()
	Local $file = GUICtrlRead($Apk_input)
	Local $out = GUICtrlRead($OutDir_input)
	Local $x = 1

	If Not FileExists($out & "1.apk") Then FileCopy($file, $out & "1.apk", 8 + 1)

	If FileExists($out & "classes.dex") Then
		$x = MsgBox(64 + 4, "Overwrite ?", "classes.dex is already existed" & @CRLF & "Do you want to overwrite it ?")
		If $x = 6 Then
			$x = 1
			FileDelete($out & "classes.dex")
		EndIf
	EndIf

	If FileExists($out & "1.apk") And $x = 1 Then
		RunWait($ack_dir & "\incl\7z.exe x 1.apk classes.dex", $out, @SW_HIDE)
		If FileExists($out & "classes.dex") Then WriteLog("classes.dex has been extracted successfully")
	EndIf
EndFunc   ;==>ExtractDex

Func Dex2Jar()
	Local $out = GUICtrlRead($OutDir_input)

	If Not FileExists($out & "classes.dex") Then
		MsgBox(16, "Error", "You have to extract dex file at first !")
	Else
		RunWait(@ComSpec & " /c " & $ack_dir & "\incl\d2j\dex2jar classes.dex", $out, @SW_HIDE)
		If FileExists($out & "classes_dex2jar.jar") Then WriteLog("classes.dex has been converted into jar file successfully")
	EndIf
EndFunc   ;==>Dex2Jar

Func SourceExtract()
	Local $out = GUICtrlRead($OutDir_input)
	Local $cmd1 = "java -jar " & $ack_dir & "\incl\jd.jar " & "classes_dex2jar.jar " & $out & "source"
	Local $x = 1

	If FileExists($out & "source\") Then
		$x = MsgBox(64 + 4, "Overwrite ?", "Source directory is already existed" & @CRLF & "Do you want to overwrite it ?")
		If $x = 6 Then
			$x = 1
			DirRemove($out & "source\")
		EndIf
	EndIf

	If $x = 1 Then
		If Not FileExists($out & "classes_dex2jar.jar") Then
			MsgBox(16, "Error", "You have to convert the dex file into a jar file at first !")
		Else
			RunWait(@ComSpec & " /c " & $cmd1, $out, @SW_HIDE)
			If FileExists($out & "source\") Then WriteLog("Sources has been extracted successfully")
		EndIf
	EndIf
EndFunc   ;==>SourceExtract

Func OpenJ($x)
	Local $out = GUICtrlRead($OutDir_input)
	Local $j = ""
	If $x = 1 Then
		$j = GUICtrlRead($PrefJ1)
	Else
		$j = GUICtrlRead($PrefJ2)
	EndIf

	If $j = "" Then
		MsgBox(16, "Error", "Please config your java decompiler at first !")
		Return
	EndIf

	If Not FileExists($j) Then
		MsgBox(16, "Error", "The java decompiler you have chosen doesn't exist !")
	Else
		Local $fileJ = StringRight($j, 3)
		If $fileJ = "jar" Then
			Run("java -jar " & $j & " " & $out & "classes_dex2jar.jar")
		ElseIf $fileJ = "exe" Then
			Run($j & " " & $out & "classes_dex2jar.jar")
		Else
			MsgBox(16, "Error", "The java decompiler's extension you have chosen is unknown !")
		EndIf
	EndIf
EndFunc   ;==>OpenJ

Func OpenManifest()
	Local $out = GUICtrlRead($OutDir_input)
	Local $np = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Notepad++", "")
	Local $x = 7 ;No button in msgbox

	If Not FileExists($out & "1\AndroidManifest.xml") Then
		MsgBox(16, "Error", "AndroidManifest.xml is not existed !" & @CRLF & "You have to use smali decompilation at first")
		Return
	EndIf

	If $np <> "" Then
		$x = MsgBox(64 + 3, "Notepad++ detected", "Notepad++ is installed" & @CRLF & "Do you want to open manifest.xml in Notepad++ ?")
	EndIf

	If $x = 7 Then ShellExecute($out & "1\AndroidManifest.xml")
	If $x = 6 Then Run($np & "\notepad++.exe " & $out & "1\AndroidManifest.xml")
EndFunc   ;==>OpenManifest

Func OpenBuildDir()
	Local $out = GUICtrlRead($OutDir_input)
	If Not FileExists($out & "1\dist\") Then
		MsgBox(16, "Error", "You have to build it first !")
	Else
		ShellExecute($out & "1\dist\")
	EndIf
EndFunc   ;==>OpenBuildDir

Func Build()
	Local $out = GUICtrlRead($OutDir_input)
	FileDelete($out & "1\dist\1.apk")
	Local $CMD = 'apktool b 1 && ' & _
			'pause && ' & _
			'exit'
	RunWait('"' & @ComSpec & '" /k ' & $CMD, $out, @SW_SHOW)
	If FileExists($out & "1\dist\1.apk") Then WriteLog("apk file was built successfully into 1.apk")
EndFunc   ;==>Build

Func SignApk()
	Local $out = GUICtrlRead($OutDir_input)
	FileDelete($out & "1\dist\2_signed.apk")
	If Not FileExists($out & "1\dist\1.apk") Then
		MsgBox(16, "Error", "You have to build it first !")
	Else
		Local $CMD = 'java -jar ' & $ack_dir & 'incl\sa\signapk.jar certificate.pem key.pk8 1.apk 2_signed.apk && ' & _
				'pause && ' & _
				'exit'
		FileCopy($ack_dir & 'incl\sa\certificate.pem', $out & "1\dist\certificate.pem", 0)
		FileCopy($ack_dir & 'incl\sa\key.pk8', $out & "1\dist\key.pk8", 0)
		RunWait('"' & @ComSpec & '" /k ' & $CMD, $out & "1\dist\", @SW_SHOW)
	EndIf
	If FileExists($out & "1\dist\2_signed.apk") Then WriteLog("1.apk was signed successfully into 2_signed.apk")
EndFunc   ;==>SignApk

Func ZipAlign()
	Local $out = GUICtrlRead($OutDir_input)
	FileDelete($out & "1\dist\3_zipAligned.apk")
	If Not FileExists($out & "1\dist\2_signed.apk") Then
		MsgBox(16, "Error", "You have to sign it first !")
	Else
		Local $CMD = $ack_dir & 'incl\za.exe -f -v 4 2_signed.apk 3_zipAligned.apk && ' & _
				'pause && ' & _
				'exit'
		RunWait('"' & @ComSpec & '" /k ' & $CMD, $out & "1\dist\", @SW_SHOW)
	EndIf
	If Not FileExists($out & "1\dist\3_zipAligned.apk") Then WriteLog("2_signed.apk was zip aligned successfully into 3_zipAligned.apk")
EndFunc   ;==>ZipAlign

Func PassArgs()
	Local $file = GUICtrlRead($Apk_input)
	Local $out = GUICtrlRead($OutDir_input)
	Local $x
	If Not FileExists($file) Then
		MsgBox(16, "Error", "The chosen apk file doesn't exist")
	Else
		$x = FileCopy($file, $out & "1.apk", 8)
		If FileExists($out & "1.apk") Then $x = 1
		If $x = 0 Then MsgBox(16, "Error", "Cannot copy apk to the destination folder")
		If $x = 1 Then
			Local $CMD = 'apktool ' & GUICtrlRead($args_input) & ' 1.apk && ' & _
					'pause && ' & _
					'exit'
			Run('"' & @ComSpec & '" /k ' & $CMD, $out, @SW_SHOW)
		EndIf
	EndIf
EndFunc   ;==>PassArgs

Func DoItAll()
	SmaliDecompile()
	ExtractDex()
	Dex2Jar()
	SourceExtract()
EndFunc   ;==>DoItAll

Func Recompile()
	Build()
	SignApk()
	ZipAlign()
EndFunc   ;==>Recompile

Func InstallApkIntoDevice()
	Local $out = GUICtrlRead($OutDir_input)
	If Not FileExists($out & "1\dist\3_zipAligned.apk") Then
		MsgBox(16, "Error", "You have to zip align it first !")
	Else
		Local $CMD = 'adb devices && ' & _
				'adb install 3_zipAligned.apk && ' & _
				'pause && ' & _
				'exit'
		Run('"' & @ComSpec & '" /k ' & $CMD, $out & "1\dist\", @SW_SHOW)
	EndIf
EndFunc   ;==>InstallApkIntoDevice

Func IDAGo()
	If GUICtrlRead($GoIDA_btn) = "Stop IDA" Then
		GUICtrlSetData($GoIDA_btn, "Go IDA !")
		WinMove($form1, Default, Default, Default, 509, Default)
		AdlibUnRegister("IDALog")
		$y = _ProcessGetChildren($pid)
		If IsArray($y) Then
			If $y[0][0] > 1 Then
				Local $x = MsgBox(64 + 4, "Kill tree ?", "Myabe there are other processes created by these command" & @CRLF & "Do you want to kill the process tree ?")
				If $x = 6 Then
					For $x = 2 To $y[0][0]
						ProcessClose($y[$x][0])
					Next
				EndIf
			EndIf
		EndIf
		ProcessClose($pid)
		Return
	EndIf
	WinMove($form1, Default, Default, Default, 712, Default)
	If GUICtrlRead($GoIDA_btn) = "Go IDA !" Then GUICtrlSetData($GoIDA_btn, "Stop IDA")
	Global $pid = Run("C:\Windows\system32\cmd.exe", $ack_dir & "incl\", @SW_SHOW, $STDIN_CHILD + $STDOUT_CHILD)
	WinWaitActive("C:\Windows\system32\cmd.exe")
	StdinWrite($pid, "title IDA_Debug_Helper")
	StdinWrite($pid, @CRLF)
	AdlibRegister("IDALog", 1000)
	WriteLog("=======================================================")
	;WriteLog("You will be given updates every 3 seconds")
EndFunc   ;==>IDAGo

Func ADBConnect()
	Local $inputC = InputBox("Enter IP", "Please enter the Android VM IP address", "192.168.208.131")
	If @error = 1 Then Return
	StdinWrite($pid, "adb connect " & $inputC)
	GUICtrlSetData($IDA_input, "adb connect " & $inputC)
	StdinWrite($pid, @CRLF)
EndFunc   ;==>ADBConnect

Func ADBDevices()
	StdinWrite($pid, "adb devices")
	GUICtrlSetData($IDA_input, "adb devices")
	StdinWrite($pid, @CRLF)
EndFunc   ;==>ADBDevices

Func ADBShell()
	If $IDA_shell = 0 Then
		StdinWrite($pid, "adb shell")
		GUICtrlSetData($IDA_input, "adb shell")
		StdinWrite($pid, @CRLF)
		WriteLog("You are in the shell now")
		$IDA_shell = 1
	ElseIf $IDA_shell = 1 Then
		WriteLog("It seems to be that shell is already executed")
	EndIf
EndFunc   ;==>ADBShell

Func CopyAndrServer()
	StdinWrite($pid, "adb push android_server /data/local/tmp/")
	;GUICtrlSetData($IDA_input, "adb push android_server /data/local/tmp/")
	StdinWrite($pid, @CRLF)
	StdinWrite($pid, "adb push gdbserver /data/local/tmp/")
	GUICtrlSetData($IDA_input, "adb push android_server /data/local/tmp/")
	StdinWrite($pid, @CRLF)
EndFunc   ;==>CopyAndrServer

Func ADBForward()
	RunWait("adb forward tcp:23946 tcp:23946", @SystemDir, @SW_HIDE)
	GUICtrlSetData($IDA_input, "adb forward tcp:23946 tcp:23946")
EndFunc

#cs
Func CopyGdbServer()
	StdinWrite($pid, "adb push gdbserver /data/local/tmp/")
	GUICtrlSetData($IDA_input, "adb push gdbserver /data/local/tmp/")
	StdinWrite($pid, @CRLF)
EndFunc   ;==>CopyGdbServer
#ce

Func RunAndrServer()
	StdinWrite($pid, "su")
	StdinWrite($pid, @CRLF)
	StdinWrite($pid, "cd /data/local/tmp/")
	StdinWrite($pid, @CRLF)
	StdinWrite($pid, "chmod 755 android_server")
	StdinWrite($pid, @CRLF)
	StdinWrite($pid, "./android_server")
	StdinWrite($pid, @CRLF)
	GUICtrlSetData($IDA_input, "./android_server")
	$IDA_server = 1
EndFunc   ;==>RunAndrServer

Func RunGdbServer()
	StdinWrite($pid, "su")
	StdinWrite($pid, @CRLF)
	StdinWrite($pid, "cd /data/local/tmp/")
	StdinWrite($pid, @CRLF)
	StdinWrite($pid, "chmod 755 gdbserver")
	StdinWrite($pid, @CRLF)
	StdinWrite($pid, "./gdbserver")
	StdinWrite($pid, @CRLF)
	GUICtrlSetData($IDA_input, "./gdbserver")
	$IDA_server = 1
EndFunc   ;==>RunGdbServer

Func ADBShell_stop()
	If $IDA_server = 1 Then
		StdinWrite($pid, "exit")
		GUICtrlSetData($IDA_input, "exit")
		StdinWrite($pid, @CRLF)
		WriteLog("Server has been stopped")
		$IDA_server = 2
		$IDA_shell = 1
		Return
	EndIf

	If $IDA_shell = 1 Then
		StdinWrite($pid, "exit")
		GUICtrlSetData($IDA_input, "exit")
		StdinWrite($pid, @CRLF)
		WriteLog("Shell has been stopped")
		$IDA_shell = 0
	Else
		WriteLog("It seems to be that shell has not been executed / has been stopped")
	EndIf
EndFunc   ;==>ADBShell_stop

Func PassIDA()
	Local $inputC = GUICtrlRead($IDA_input)
	StdinWrite($pid, $inputC)
	StdinWrite($pid, @CRLF)
EndFunc   ;==>PassIDA

Func IDALog()
	Local $IDA_output_sh = StdoutRead($pid)
	ConsoleWrite($IDA_output_sh)
	If $IDA_output_sh <> "" Then
		WriteLog($IDA_output_sh)
	EndIf
EndFunc   ;==>IDALog

Func _ProcessGetChildren($i_pid) ; First level children processes only
	Local Const $TH32CS_SNAPPROCESS = 0x00000002

	Local $a_tool_help = DllCall("Kernel32.dll", "long", "CreateToolhelp32Snapshot", "int", $TH32CS_SNAPPROCESS, "int", 0)
	If IsArray($a_tool_help) = 0 Or $a_tool_help[0] = -1 Then Return SetError(1, 0, $i_pid)

	Local $tagPROCESSENTRY32 = _
			DllStructCreate _
			( _
			"dword dwsize;" & _
			"dword cntUsage;" & _
			"dword th32ProcessID;" & _
			"uint th32DefaultHeapID;" & _
			"dword th32ModuleID;" & _
			"dword cntThreads;" & _
			"dword th32ParentProcessID;" & _
			"long pcPriClassBase;" & _
			"dword dwFlags;" & _
			"char szExeFile[260]" _
			)
	DllStructSetData($tagPROCESSENTRY32, 1, DllStructGetSize($tagPROCESSENTRY32))

	Local $p_PROCESSENTRY32 = DllStructGetPtr($tagPROCESSENTRY32)

	Local $a_pfirst = DllCall("Kernel32.dll", "int", "Process32First", "long", $a_tool_help[0], "ptr", $p_PROCESSENTRY32)
	If IsArray($a_pfirst) = 0 Then Return SetError(2, 0, $i_pid)

	Local $a_pnext, $a_children[11][2] = [[10]], $i_child_pid, $i_parent_pid, $i_add = 0
	$i_child_pid = DllStructGetData($tagPROCESSENTRY32, "th32ProcessID")
	If $i_child_pid <> $i_pid Then
		$i_parent_pid = DllStructGetData($tagPROCESSENTRY32, "th32ParentProcessID")
		If $i_parent_pid = $i_pid Then
			$i_add += 1
			$a_children[$i_add][0] = $i_child_pid
			$a_children[$i_add][1] = DllStructGetData($tagPROCESSENTRY32, "szExeFile")
		EndIf
	EndIf

	While 1
		$a_pnext = DllCall("Kernel32.dll", "int", "Process32Next", "long", $a_tool_help[0], "ptr", $p_PROCESSENTRY32)
		If IsArray($a_pnext) And $a_pnext[0] = 0 Then ExitLoop
		$i_child_pid = DllStructGetData($tagPROCESSENTRY32, "th32ProcessID")
		If $i_child_pid <> $i_pid Then
			$i_parent_pid = DllStructGetData($tagPROCESSENTRY32, "th32ParentProcessID")
			If $i_parent_pid = $i_pid Then
				If $i_add = $a_children[0][0] Then
					ReDim $a_children[$a_children[0][0] + 11][2]
					$a_children[0][0] = $a_children[0][0] + 10
				EndIf
				$i_add += 1
				$a_children[$i_add][0] = $i_child_pid
				$a_children[$i_add][1] = DllStructGetData($tagPROCESSENTRY32, "szExeFile")
			EndIf
		EndIf
	WEnd

	If $i_add <> 0 Then
		ReDim $a_children[$i_add + 1][2]
		$a_children[0][0] = $i_add
	EndIf

	DllCall("Kernel32.dll", "int", "CloseHandle", "long", $a_tool_help[0])
	If $i_add Then Return $a_children
	Return SetError(3, 0, 0)
EndFunc   ;==>_ProcessGetChildren

Func On_WM_DROPFILES($hWnd, $Msg, $wParam, $lParam)
	Local $tDrop, $aRet, $iCount
	;string buffer for file path
	$tDrop = DllStructCreate("char[260]")
	;get file count
	$aRet = DllCall("shell32.dll", "int", "DragQueryFile", _
			"hwnd", $wParam, _
			"uint", -1, _
			"ptr", DllStructGetPtr($tDrop), _
			"int", DllStructGetSize($tDrop) _
			)
	$iCount = $aRet[0]
	;get file paths
	For $i = 0 To $iCount - 1
		$aRet = DllCall("shell32.dll", "int", "DragQueryFile", _
				"hwnd", $wParam, _
				"uint", $i, _
				"ptr", DllStructGetPtr($tDrop), _
				"int", DllStructGetSize($tDrop) _
				)

		$file = DllStructGetData($tDrop, 1)
		ApkChangeInput()
	Next
	;finalize
	DllCall("shell32.dll", "int", "DragFinish", "hwnd", $wParam)
	Return
EndFunc   ;==>On_WM_DROPFILES