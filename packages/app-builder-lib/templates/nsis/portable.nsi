!include "common.nsh"
!include "extractAppPackage.nsh"

# https://github.com/electron-userland/electron-builder/issues/3972#issuecomment-505171582
CRCCheck off
WindowIcon Off
AutoCloseWindow True
RequestExecutionLevel ${REQUEST_EXECUTION_LEVEL}

SilentInstall silent

Function .onInit
  !insertmacro check64BitAndSetRegView
FunctionEnd

Section
  StrCpy $INSTDIR "$TEMP\${UNPACK_DIR_NAME}"
  RMDir /r $INSTDIR
	SetOutPath $INSTDIR

	!ifdef APP_DIR_64
    !ifdef APP_DIR_32
      ${if} ${RunningX64}
        File /r "${APP_DIR_64}\*.*"
      ${else}
        File /r "${APP_DIR_32}\*.*"
      ${endIf}
    !else
      File /r "${APP_DIR_64}\*.*"
    !endif
  !else
    !ifdef APP_DIR_32
      File /r "${APP_DIR_32}\*.*"
    !else
      !insertmacro extractEmbeddedAppPackage
    !endif
  !endif

  System::Call 'Kernel32::SetEnvironmentVariable(t, t)i ("PORTABLE_EXECUTABLE_DIR", "$EXEDIR").r0'
  System::Call 'Kernel32::SetEnvironmentVariable(t, t)i ("PORTABLE_EXECUTABLE_FILE", "$EXEPATH").r0'
  System::Call 'Kernel32::SetEnvironmentVariable(t, t)i ("PORTABLE_EXECUTABLE_APP_FILENAME", "${APP_FILENAME}").r0'
  ${StdUtils.GetAllParameters} $R0 0
	ExecWait "$INSTDIR\${APP_EXECUTABLE_FILENAME} $R0" $0
  SetErrorLevel $0

  SetOutPath $PLUGINSDIR
	RMDir /r $INSTDIR
SectionEnd
