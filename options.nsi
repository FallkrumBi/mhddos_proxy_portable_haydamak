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
  !define PRODUCT "haydamaks_installer"
  !define PRODUCT_VERSION "1.0.0"
  !define UNINSTALLER_NAME "uninstall"
  
  BrandingText "${PRODUCT} ${PRODUCT_VERSION}"
  
  !define MHDDOS_PROXY_SRC "https://github.com/porthole-ascend-cinnamon/mhddos_proxy.git"
  
  !define MHDDOS_PROXY_DIR "$INSTDIR\mhddos_proxy"
  
  !define MHDDOS_PROXY_BETA_DIR "$INSTDIR\mhddos_proxy_beta"
  
  !define MHDDOS_PROXY_ENV "$APPDATA\mhddos_proxy_env"
  
  !define PYTHON_DIR "${MHDDOS_PROXY_ENV}\python"
  
  !define GIT_DIR "${MHDDOS_PROXY_ENV}\git\git"
  
  !define haydamaks_tcp_target "-c http://goals.ddosukraine.com.ua/haydamaky/targets_tcp.txt"
  !define haydamaks_udp_target "-c http://goals.ddosukraine.com.ua/haydamaky/targets_udp.txt"
  
  !define proxy_finder_src "https://github.com/porthole-ascend-cinnamon/proxy_finder.git"
  !define proxy_finder_dir "$INSTDIR\proxy_finder"



  ;Installer Version Information
  VIAddVersionKey "ProductName" "${PRODUCT}"
  VIAddVersionKey "CompanyName" "Haydamaks"
  VIAddVersionKey "LegalCopyright" "Copyright ©2022 Haydamaks Installer"
  VIAddVersionKey "FileDescription" "Haydamaks Installer"
  VIAddVersionKey "FileVersion" "${PRODUCT_VERSION}"
  VIProductVersion "${PRODUCT_VERSION}.0"

  ;Define the main name of the installer
  Name "${PRODUCT}"

  ;Define the directory where the installer should be saved
  OutFile "${PRODUCT}.exe"



  # set to default here, override in .onInit if on 64bit
  InstallDir "$APPDATA\${PRODUCT}"


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
  !define MUI_ICON "resources\haydamaks.ico" # for the Installer
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
  
  Page Custom win7_info
  
  !insertmacro MUI_PAGE_LICENSE "LICENSE" # link to an ANSI encoded license file
  !insertmacro MUI_PAGE_COMPONENTS # remove if you don't want to list components
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  ;For the uninstaller
  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH