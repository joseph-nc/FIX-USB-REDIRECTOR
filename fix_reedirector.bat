@Echo OFF
set /a _Debug=0
::==========================================
:: Get Administrator Rights
set _Args=%*
if "%~1" NEQ "" (
  set _Args=%_Args:"=%
)
fltmc 1>nul 2>nul || (
  cd /d "%~dp0"
  cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~dp0"" && ""%~dpnx0"" ""%_Args%""", "", "runas", 1 > "%temp%\GetAdmin.vbs"
  "%temp%\GetAdmin.vbs"
  Del /f /q "%temp%\GetAdmin.vbs" 1>nul 2>nul
  Exit
)
::==========================================
CLS
Echo OFF
Color 07
Title USB Redirector Technician Edition Launcher
setlocal enableextensions
cd /d "%~dp0"

Echo.
powershell write-host 'FIX REDIRECTOR' -fore '"Red"'
powershell write-host '.::' -fore '"Red"' -NoNewline; write-host ' Processing...' -fore '"White"' -NoNewline; write-host ' Please wait' -fore '"Green"' -NoNewline; write-host ' !' -fore '"White"' -NoNewline; write-host ' ::.' -fore '"Red"'

::
::CALLScript
CALL :STOPSERVICE
CALL :DELETEREG
CALL :STARTSERVICE
CALL :STARTUR

goto :eof

::
:STOPSERVICE
Echo.
NET STOP "usbredirectortechssrv"

Exit /b

::
:DELETEREG
Echo.
set "nul=1>nul 2>nul"
setlocal EnableDelayedExpansion

for %%# in (
"HKLM\SYSTEM\CurrentControlSet\Enum\SIMPLYCORE\{8F2104AB-755A-4111-9D12-0A4CEE1E7B7F}"
"HKLM\SYSTEM\ControlSet001\Enum\SIMPLYCORE\{8F2104AB-755A-4111-9D12-0A4CEE1E7B7F}"
"HKLM\SYSTEM\ControlSet002\Enum\SIMPLYCORE\{8F2104AB-755A-4111-9D12-0A4CEE1E7B7F}"
) do for /f "tokens=* delims=" %%A in ("%%#") do (
set "reg=%%#" &CALL :DELETE
)

Exit /b


:DELETE

REG DELETE %reg% /f %nul%

if [%errorlevel%]==[0] (
set "status=powershell write-host 'Deleted ' -fore '"Green"' -NoNewline; write-host '""%reg%""' -fore '"White"'"
) else (
set "status=echo Not found %reg%"
)

reg query %reg% %nul%

if [%errorlevel%]==[0] (
set "status=powershell write-host 'Deleted by taking ownership ' -fore '"Yellow"' -NoNewline; write-host '""%reg%""' -fore '"White"'"

IF EXIST "%PROGRAMW6432%" (
%nul% CALL ".\SetACLx64\SetACL.exe" -on %reg% -ot reg -actn setowner -ownr "n:Administrators" -rec Yes
%nul% CALL ".\SetACLx64\SetACL.exe" -on %reg% -ot reg -actn ace -ace "n:Administrators;p:full" -rec Yes
) else (
%nul% CALL ".\SetACLx86\SetACL.exe" -on %reg% -ot reg -actn setowner -ownr "n:Administrators" -rec Yes
%nul% CALL ".\SetACLx86\SetACL.exe" -on %reg% -ot reg -actn ace -ace "n:Administrators;p:full" -rec Yes
)
REG DELETE %reg% /f %nul%
)

reg query %reg% %nul%

if [%errorlevel%]==[0] (
powershell write-host 'Failed to delete ' -fore '"Red"' -NoNewline; write-host '""%reg%""' -fore '"White"'
) else (
%status%
)

Exit /b

::
:STARTSERVICE
Echo.
NET START /WAIT "usbredirectortechssrv" --start

Exit /b

::
:STARTUR
Echo.
IF EXIST "usbredirector-technician.exe" (
Start "" "usbredirector-technician.exe"
)

echo.
powershell write-host 'LISTO' -fore '"GREEN"'
echo.
pause

exit
@Exit

