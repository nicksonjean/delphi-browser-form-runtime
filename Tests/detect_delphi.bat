@echo off
echo Detector de Instalacoes do Delphi
echo ================================================================
echo.

set "PF86=C:\Program Files (x86)"
set "PF64=C:\Program Files"

set "CAMINHO_ENCONTRADO="
set "VERSAO_ENCONTRADA="

echo Verificando RAD Studio 12 Athens (x86)...
if exist "%PF86%\Embarcadero\Studio\23.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 12 Athens
    set "CAMINHO_ENCONTRADO=%PF86%\Embarcadero\Studio\23.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 12 Athens"
    goto :resultado
)

echo Verificando RAD Studio 11 Alexandria (x86)...
if exist "%PF86%\Embarcadero\Studio\22.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 11 Alexandria
    set "CAMINHO_ENCONTRADO=%PF86%\Embarcadero\Studio\22.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 11 Alexandria"
    goto :resultado
)

echo Verificando RAD Studio 10.4 Sydney (x86)...
if exist "%PF86%\Embarcadero\Studio\21.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 10.4 Sydney
    set "CAMINHO_ENCONTRADO=%PF86%\Embarcadero\Studio\21.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 10.4 Sydney"
    goto :resultado
)

echo Verificando RAD Studio 10.3 Rio (x86)...
if exist "%PF86%\Embarcadero\Studio\20.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 10.3 Rio
    set "CAMINHO_ENCONTRADO=%PF86%\Embarcadero\Studio\20.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 10.3 Rio"
    goto :resultado
)

echo Verificando RAD Studio 10.2 Tokyo (x86)...
if exist "%PF86%\Embarcadero\Studio\19.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 10.2 Tokyo
    set "CAMINHO_ENCONTRADO=%PF86%\Embarcadero\Studio\19.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 10.2 Tokyo"
    goto :resultado
)

echo Verificando RAD Studio 12 Athens (64-bit)...
if exist "%PF64%\Embarcadero\Studio\23.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 12 Athens (64-bit)
    set "CAMINHO_ENCONTRADO=%PF64%\Embarcadero\Studio\23.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 12 Athens (64-bit)"
    goto :resultado
)

echo Verificando RAD Studio 11 Alexandria (64-bit)...
if exist "%PF64%\Embarcadero\Studio\22.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 11 Alexandria (64-bit)
    set "CAMINHO_ENCONTRADO=%PF64%\Embarcadero\Studio\22.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 11 Alexandria (64-bit)"
    goto :resultado
)

echo Verificando RAD Studio 10.4 Sydney (64-bit)...
if exist "%PF64%\Embarcadero\Studio\21.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 10.4 Sydney (64-bit)
    set "CAMINHO_ENCONTRADO=%PF64%\Embarcadero\Studio\21.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 10.4 Sydney (64-bit)"
    goto :resultado
)

echo Verificando CodeGear RAD Studio 2009...
if exist "%PF86%\CodeGear\RAD Studio\9.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 2009 (CodeGear)
    set "CAMINHO_ENCONTRADO=%PF86%\CodeGear\RAD Studio\9.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 2009 (CodeGear)"
    goto :resultado
)

echo Verificando CodeGear RAD Studio 2008...
if exist "%PF86%\CodeGear\RAD Studio\8.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 2008 (CodeGear)
    set "CAMINHO_ENCONTRADO=%PF86%\CodeGear\RAD Studio\8.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 2008 (CodeGear)"
    goto :resultado
)

echo Verificando CodeGear RAD Studio 2007...
if exist "%PF86%\CodeGear\RAD Studio\7.0\bin\dcc32.exe" (
    echo ENCONTRADO: RAD Studio 2007 (CodeGear)
    set "CAMINHO_ENCONTRADO=%PF86%\CodeGear\RAD Studio\7.0\bin"
    set "VERSAO_ENCONTRADA=RAD Studio 2007 (CodeGear)"
    goto :resultado
)

echo Verificando Borland Delphi 7...
if exist "%PF86%\Borland\Delphi7\bin\dcc32.exe" (
    echo ENCONTRADO: Delphi 7 (Borland)
    set "CAMINHO_ENCONTRADO=%PF86%\Borland\Delphi7\bin"
    set "VERSAO_ENCONTRADA=Delphi 7 (Borland)"
    goto :resultado
)

echo Verificando Borland Delphi 6...
if exist "%PF86%\Borland\Delphi6\bin\dcc32.exe" (
    echo ENCONTRADO: Delphi 6 (Borland)
    set "CAMINHO_ENCONTRADO=%PF86%\Borland\Delphi6\bin"
    set "VERSAO_ENCONTRADA=Delphi 6 (Borland)"
    goto :resultado
)

echo Verificando Borland Delphi 5...
if exist "%PF86%\Borland\Delphi5\bin\dcc32.exe" (
    echo ENCONTRADO: Delphi 5 (Borland)
    set "CAMINHO_ENCONTRADO=%PF86%\Borland\Delphi5\bin"
    set "VERSAO_ENCONTRADA=Delphi 5 (Borland)"
    goto :resultado
)

echo.
echo NENHUMA INSTALACAO DO DELPHI ENCONTRADA
echo.
echo Verificando PATH do sistema...
where dcc32.exe >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo dcc32.exe JA ESTA NO PATH DO SISTEMA
) else (
    echo dcc32.exe NAO ESTA NO PATH DO SISTEMA
)
echo.
echo CAMINHO_DELPHI=NAO_ENCONTRADO
goto :fim

:resultado
echo.
echo ================================================================
echo DELPHI ENCONTRADO
echo ================================================================
echo Versao: %VERSAO_ENCONTRADA%
echo.
echo CAMINHO_DELPHI=%CAMINHO_ENCONTRADO%
echo.
echo Verificando PATH do sistema...
where dcc32.exe >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo dcc32.exe JA ESTA NO PATH DO SISTEMA
) else (
    echo dcc32.exe NAO ESTA NO PATH DO SISTEMA
)

:fim
echo.
pause 