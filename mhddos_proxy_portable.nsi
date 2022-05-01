;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"
  !include "x64.nsh"
  !include "LogicLib.nsh"


;--------------------------------
;General

  ;Properly display all languages
  Unicode true
  
  SetCompressor /SOLID lzma
  SetCompressorDictSize 64
  SetDatablockOptimize ON

  ;Define name of the product
  !define PRODUCT "mhddos_proxy_portable"
  !define PRODUCT_VERSION "1.0.3"
  !define UNINSTALLER_NAME "uninstall"
  
  !define MHDDOS_PROXY_SRC "https://github.com/porthole-ascend-cinnamon/mhddos_proxy.git"
  
  !define MHDDOS_PROXY_BETA_SRC "https://github.com/0xffiber/mhddos_proxy.git"
  
  !define MHDDOS_PROXY_DIR "$INSTDIR\mhddos_proxy"
  
  !define MHDDOS_PROXY_BETA_DIR "$INSTDIR\mhddos_proxy_beta"
  
  !define PYTHON_DIR "$INSTDIR\python"
  
  !define GIT_DIR "$INSTDIR\git"
  
  !define VCREDIST_DIR "$INSTDIR\vc_redist"

  ;Define the main name of the installer
  Name "${PRODUCT}_${PRODUCT_VERSION}"

  ;Define the directory where the installer should be saved
  OutFile "output\${PRODUCT}_${PRODUCT_VERSION}.exe"



  # set to default here, override in .onInit if on 64bit
  InstallDir "$APPDATA\${PRODUCT}"

  ;Function .onInit

  ;FunctionEnd


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
  
  !define MUI_FINISHPAGE_RUN "$INSTDIR\runer.bat"
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

Section ;Visual C++ Redistributable for Visual Studio 2015
	SetOutPath ${VCREDIST_DIR}

	${If} ${RunningX64}
		File /r "requirements\vc_redist\vc_redist.x64.exe"
	${Else}
		File /r "requirements\vc_redist\vc_redist.x86.exe"
	${EndIf}  

	${If} ${RunningX64}
		ExecWait 'vc_redist.x64.exe /q /norestart' $0
		DetailPrint "-- VC_redist.x64.exe runtime exit code = '$0'"
	${Else}
		ExecWait 'vc_redist.x86.exe /q /norestart' $0
		DetailPrint "-- VC_redist.x86.exe runtime exit code = '$0'"
	${EndIf}
SectionEnd

Section "mhddos_proxy"
  SectionIn RO # Just means if in component mode this is locked

  ;Set output path to the installation directory.
  SetOutPath $INSTDIR

  ;Store installation folder in registry
  WriteRegStr HKLM "Software\${PRODUCT}" "" $INSTDIR

  ;Registry information for add/remove programs
  
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "DisplayName" "${PRODUCT}_${PRODUCT_VERSION}"
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
  CreateShortCut "$SMPROGRAMS\${PRODUCT}\ItArmy Attack.lnk" "$INSTDIR\runer.bat" "" "$INSTDIR\itarmy.ico" 0
  CreateShortCut "$SMPROGRAMS\${PRODUCT}\Uninstall ${PRODUCT}.lnk" "$INSTDIR\${UNINSTALLER_NAME}.exe" "" "$INSTDIR\${UNINSTALLER_NAME}.exe" 0

  ;Create uninstaller
  WriteUninstaller "${UNINSTALLER_NAME}.exe"

  FileOpen $9 uninstall_requirements.bat w
  FileWrite $9 "SET PATH=${PYTHON_DIR};${PYTHON_DIR}\Scripts;${GIT_DIR}\git;%PATH%$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "${PYTHON_DIR}\python.exe -m pip uninstall --yes -r requirements.txt$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "${PYTHON_DIR}\python.exe -m pip uninstall --yes -r requirements.txt$\r$\n"
  FileClose $9

SectionEnd

Section "git (portable)"
  SectionIn RO
  ; Save something else optional to the installation directory.
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

  ;File /r "requirements\python"

SectionEnd



	;ShortCut
Section
  SetOutPath $INSTDIR
  
  FileOpen $9 runer.bat w
  FileWrite $9 "@echo off$\r$\n"
  FileWrite $9 "SET PATH=${PYTHON_DIR};${PYTHON_DIR}\Scripts;${GIT_DIR}\git;%PATH%$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "color 0A$\r$\n"
  FileWrite $9 "echo	Cheack Update mhddos_proxy$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "echo	"OK"$\r$\n"
  FileWrite $9 "echo	Cheack requirements$\r$\n"
  FileWrite $9 "${PYTHON_DIR}\python.exe -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "echo	"OK"$\r$\n"
  FileWrite $9 "echo	Start Attak ItArmy Target$\r$\n"
  FileWrite $9 "${PYTHON_DIR}\python.exe runner.py --itarmy --debug$\r$\n"
  FileClose $9


  File "resources\itarmy.ico"
  
  CreateShortCut "$DESKTOP\ItArmy Attack.lnk" "$INSTDIR\runer.bat" "" "$INSTDIR\itarmy.ico" 0
 
  
SectionEnd



Section	;Clone mhddos_proxy repo and install requirements

  SetOutPath $INSTDIR

  FileOpen $9 clone_from_source.bat w
  FileWrite $9 "SET PATH=${PYTHON_DIR};${PYTHON_DIR}\Scripts;${GIT_DIR}\git;%PATH%$\r$\n"
  FileWrite $9 "CD $INSTDIR$\r$\n"
  FileWrite $9 "START /W ${GIT_DIR}\git\git.exe clone ${MHDDOS_PROXY_SRC} ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_DIR}$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "START /W ${PYTHON_DIR}\python.exe -m pip install --upgrade pip$\r$\n"
  FileWrite $9 "START /W ${PYTHON_DIR}\python.exe -m pip install -r requirements.txt$\r$\n"
  FileClose $9
 
  nsExec::Exec 'cmd /c "$INSTDIR\clone_from_source.bat"'

  Delete $INSTDIR\clone_from_source.bat

SectionEnd


Section	"mhddos_proxy_beta (feature-async)";Clone mhddos_proxy repo and install requirements

  SetOutPath $INSTDIR

  FileOpen $9 clone_beta_from_source.bat w
  FileWrite $9 "SET PATH=${PYTHON_DIR};${PYTHON_DIR}\Scripts;${GIT_DIR}\git;%PATH%$\r$\n"
  FileWrite $9 "CD $INSTDIR$\r$\n"
  FileWrite $9 "START /W ${GIT_DIR}\git\git.exe clone -b feature-async ${MHDDOS_PROXY_BETA_SRC} ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "START /W ${PYTHON_DIR}\python.exe -m pip install --upgrade pip$\r$\n"
  FileWrite $9 "START /W ${PYTHON_DIR}\python.exe -m pip install -r requirements.txt$\r$\n"
  FileClose $9
 
  nsExec::Exec 'cmd /c "$INSTDIR\clone_beta_from_source.bat"'

  Delete $INSTDIR\clone_beta_from_source.bat.bat


  FileOpen $9 runer_beta.bat w
  FileWrite $9 "@echo off$\r$\n"
  FileWrite $9 "SET PATH=${PYTHON_DIR};${PYTHON_DIR}\Scripts;${GIT_DIR}\git;%PATH%$\r$\n"
  FileWrite $9 "CD ${MHDDOS_PROXY_BETA_DIR}$\r$\n"
  FileWrite $9 "color 0A$\r$\n"
  FileWrite $9 "echo	Cheack Update mhddos_proxy_beta$\r$\n"
  FileWrite $9 "git pull$\r$\n"
  FileWrite $9 "echo	"OK"$\r$\n"
  FileWrite $9 "echo	Cheack requirements$\r$\n"
  FileWrite $9 "${PYTHON_DIR}\python.exe -m pip install -r requirements.txt$\r$\n"
  FileWrite $9 "echo	"OK"$\r$\n"
  FileWrite $9 "echo	Start Attak ItArmy Target (BETA)$\r$\n"
  FileWrite $9 "${PYTHON_DIR}\python.exe runer_beta.py --itarmy --debug$\r$\n"
  FileClose $9
  
  CreateShortCut "$DESKTOP\ItArmy Attack BETA.lnk" "$INSTDIR\runer_beta.bat" "" "$INSTDIR\itarmy_beta.ico" 0

SectionEnd



;Uninstaller Section

Section "Uninstall"

  nsExec::ExecToStack  'cmd /c "$INSTDIR\uninstall_requirements.bat"'
  
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
  


SectionEnd


;--------------------------------
;After Installation Function

Function .onInstSuccess

  ;Open 'Thank you for installing' site or something else
  ;ExecShell "open" "microsoft-edge:${AFTER_INSTALLATION_URL}"
  ExecShell "opennew" "https://t.me/itarmyofukraine2022"

FunctionEnd