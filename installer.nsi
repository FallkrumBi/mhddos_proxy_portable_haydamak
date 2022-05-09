Var uninstallerPath

Section "-hidden"

    ;Search if mhddos_proxy_portable is already installed.
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

;Installer Section

Section ;Visual C++ Redistributable 2015-2022
	SetOutPath ${VCREDIST_DIR}
	
	${If} ${IsWin7} ; patch for windows 7
		${If} ${RunningX64}
			File /r "requirements\vc_redist\vc_redist.x64.exe"
		${Else}
			File /r "requirements\vc_redist\vc_redist.x86.exe"
		${EndIf}

		${If} ${RunningX64}
			ExecWait 'vc_redist.x64.exe /q /norestart' $0
			DetailPrint "-- vc_redist.x64.exe runtime exit code = '$0'"
		${Else}
			ExecWait 'vc_redist.x86.exe /q /norestart' $0
			DetailPrint "-- vc_redist.x86.exe runtime exit code = '$0'"
		${EndIf}
	${EndIf}
SectionEnd

Section
  SectionIn RO # Just means if in component mode this is locked

  ;Set output path to the installation directory.
  SetOutPath $INSTDIR

  ;Store installation folder in registry
  WriteRegStr HKLM "Software\${PRODUCT}" "" $INSTDIR

  ;Registry information for add/remove programs
  
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "DisplayName" "${PRODUCT}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "UninstallString" '"$INSTDIR\${UNINSTALLER_NAME}.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "DisplayIcon" '"$INSTDIR\itarmy.ico",0'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "Publisher" "MHDDoS Proxy Portable"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "URLInfoAbout" "https://github.com/OleksandrBlack/mhddos_proxy_portable"
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
  FileWrite $9 ":RUN_MHDDOS_PROXY$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-itarmy' goto ITARMY)$\r$\n"
  FileWrite $9 ":RUN_MHDDOS_PROXY_BETA$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-itarmy_beta' goto ITARMY_BETA)$\r$\n"
  FileWrite $9 ":RUN_CLONE_MHDDOS_PROXY$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-clone_mhddos_proxy' goto CLONE_MHDDOS_PROXY)$\r$\n"
  FileWrite $9 ":RUN_CLONE_MHDDOS_PROXY_BETA$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-clone_mhddos_proxy_beta' goto CLONE_MHDDOS_PROXY_BETA)$\r$\n"
  FileWrite $9 ":RUN_UNINSTALL$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-uninstall' goto UNINSTALL)$\r$\n"
  
  FileWrite $9 ":run_clone_proxy_finder$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-clone_proxy_finder' goto clone_proxy_finder)$\r$\n"
  FileWrite $9 ":run_proxy_finder$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-proxy_finder' goto proxy_finder)$\r$\n"
  
  FileWrite $9 ":run_haydamaks_tcp$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-haydamaks_tcp' goto haydamaks_tcp)$\r$\n"
  FileWrite $9 ":run_haydamaks_udp$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-haydamaks_udp' goto haydamaks_udp)$\r$\n"
  FileWrite $9 ":run_haydamaks_tcp_beta$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-haydamaks_tcp_beta' goto haydamaks_tcp_beta)$\r$\n"
  FileWrite $9 ":run_haydamaks_udp_beta$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-haydamaks_udp_beta' goto haydamaks_udp_beta)$\r$\n"
  
  FileWrite $9 ":MAIN_INFO$\r$\n"
  FileWrite $9 "ECHO.$\r$\n"
  FileWrite $9 "ECHO 1. Run ItArmy Attack$\r$\n"
  FileWrite $9 "ECHO 2. Run ItArmy Attack BETA$\r$\n"
  FileWrite $9 "set /p choice=Enter a number to start the action:$\r$\n"
  FileWrite $9 "if '%choice%'=='' ECHO '%choice%'  is not a valid option, please try again$\r$\n"
  FileWrite $9 "if '%choice%'=='1' goto ITARMY$\r$\n"
  FileWrite $9 "if '%choice%'=='2' goto ITARMY_BETA$\r$\n"
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
  
  FileWrite $9 ":CLONE_MHDDOS_PROXY_BETA$\r$\n"
  FileWrite $9 "CD $INSTDIR$\r$\n"
  FileWrite $9 "git clone -b feature-async ${MHDDOS_PROXY_SRC} ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":ITARMY$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Attack ItArmy Target$\r$\n"
  FileWrite $9 "python runner.py --itarmy --debug$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":ITARMY_BETA$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Attack ItArmy Target BETA$\r$\n"
  FileWrite $9 "python runner.py --itarmy --debug$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
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
  FileWrite $9 "ECHO Start Proxy Finder (ItArmy)$\r$\n"
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
  FileWrite $9 "python runner.py ${haydamaks_tcp_target} --debug$\r$\n"
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
  FileWrite $9 "python runner.py ${haydamaks_udp_target} --debug$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":haydamaks_tcp_beta$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Attack Haydamaks TCP Target BETA$\r$\n"
  FileWrite $9 "python runner.py ${haydamaks_tcp_target} --debug$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":haydamaks_udp_beta$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Attack Haydamaks UDP Target BETA$\r$\n"
  FileWrite $9 "python runner.py ${haydamaks_udp_target} --debug$\r$\n"
  FileWrite $9 "goto END$\r$\n"

  FileWrite $9 ":END$\r$\n"
  FileWrite $9 "EXIT$\r$\n"
  FileClose $9
SectionEnd

Section	"mhddos_proxy";INSTALL MHDDOS_PROXY
  SectionIn RO
  SetOutPath $INSTDIR
 
  nsExec::Exec 'cmd /c "$INSTDIR\runner.bat -clone_mhddos_proxy"'

SectionEnd

Section	"mhddos_proxy_beta (feature-async)";INSTALL MHDDOS_PROXY_BETA
  SectionIn RO
  SetOutPath $INSTDIR
 
  nsExec::Exec 'cmd /c "$INSTDIR\runner.bat -clone_mhddos_proxy_beta"'
  
SectionEnd

;Proxy Finder
Section	$(inst_pf_req)

  SetOutPath $INSTDIR
  
  File "resources\itarmy_proxy.ico"
  
  nsExec::Exec 'cmd /c "$INSTDIR\runner.bat -clone_proxy_finder"'
  
  CreateShortCut "$DESKTOP\$(inst_pf_req).lnk" "$INSTDIR\runner.bat" "-proxy_finder" "$INSTDIR\itarmy_proxy.ico" 0

SectionEnd

;ItArmy
Section	$(inst_itarmy_req) ;"ItArm y of Ukraine Attack"

  SetOutPath $INSTDIR
  
  File "resources\itarmy.ico"
  
  CreateShortCut "$DESKTOP\$(inst_itarmy_req).lnk" "$INSTDIR\runner.bat" "-itarmy" "$INSTDIR\itarmy.ico" 0

SectionEnd

;ItArmy BETA
Section	$(inst_itarmy_beta_req) ;"ItArmy of Ukraine Attack BETA"

  SetOutPath $INSTDIR
  
  File "resources\itarmy_beta.ico"
  
  CreateShortCut "$DESKTOP\$(inst_itarmy_beta_req).lnk" "$INSTDIR\runner.bat" "-itarmy_beta" "$INSTDIR\itarmy_beta.ico" 0

SectionEnd

;Haydamaks
Section	$(inst_haydamaks_req)

  SetOutPath $INSTDIR
  
  File "resources\haydamaks.ico"
  
  CreateShortCut "$DESKTOP\TCP $(inst_haydamaks_req).lnk" "$INSTDIR\runner.bat" "-haydamaks_tcp" "$INSTDIR\haydamaks.ico" 0
  CreateShortCut "$DESKTOP\UDP $(inst_haydamaks_req).lnk" "$INSTDIR\runner.bat" "-haydamaks_udp" "$INSTDIR\haydamaks.ico" 0

SectionEnd

;Haydamaks BETA
Section	$(inst_haydamaks_beta_req)

  SetOutPath $INSTDIR
  
  File "resources\haydamaks_beta.ico"
  
  CreateShortCut "$DESKTOP\TCP $(inst_haydamaks_beta_req).lnk" "$INSTDIR\runner.bat" "-haydamaks_tcp_beta" "$INSTDIR\haydamaks_beta.ico" 0
  CreateShortCut "$DESKTOP\UDP $(inst_haydamaks_beta_req).lnk" "$INSTDIR\runner.bat" "-haydamaks_udp_beta" "$INSTDIR\haydamaks_beta.ico" 0

SectionEnd


Function .onInit

  !insertmacro MUI_LANGDLL_DISPLAY


  ;Search if mhddos_proxy_portable is already installed.
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