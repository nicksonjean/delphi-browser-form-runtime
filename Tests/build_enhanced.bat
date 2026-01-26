@echo off
setlocal enabledelayedexpansion
set BUILD_VERSION=3.0

REM ================================================================
REM Script de Build Avançado para WVBrowser Tests - Versao: %BUILD_VERSION%
REM Versão: %BUILD_VERSION%
REM Autor: Nickson Jeanmerson
REM ================================================================

set PROJECT_NAME=TestBrowserForm
set PROJECT_FILE=%PROJECT_NAME%.dpr
set OUTPUT_DIR=Output
set SOURCE_DIR=..\Source
set DEPENDENCIES_DIR=%SOURCE_DIR%\Dependencies

REM Cores para output
set COLOR_SUCCESS=2
set COLOR_ERROR=4
set COLOR_WARNING=6
set COLOR_INFO=3

echo.
echo ================================================================
echo            WVBrowser Tests - Build Script Versao: %BUILD_VERSION%
echo ================================================================
echo.

REM Verificar se arquivo do projeto existe
if not exist %PROJECT_FILE% (
    color %COLOR_ERROR%
    echo ERRO: Arquivo do projeto %PROJECT_FILE% nao encontrado!
    echo Certifique-se de estar no diretorio correto: Tests
    color
    pause
    exit /b 1
)

echo [1/5] Procurando instalacao do Delphi...

REM Definir possiveis localizacoes do Delphi
set "DELPHI_PATHS="
set "DELPHI_PATHS=%DELPHI_PATHS%;C:\Program Files (x86)\Embarcadero\Studio\23.0\bin"
set "DELPHI_PATHS=%DELPHI_PATHS%;C:\Program Files (x86)\Embarcadero\Studio\22.0\bin"
set "DELPHI_PATHS=%DELPHI_PATHS%;C:\Program Files (x86)\Embarcadero\Studio\21.0\bin"
set "DELPHI_PATHS=%DELPHI_PATHS%;C:\Program Files (x86)\Embarcadero\Studio\20.0\bin"
set "DELPHI_PATHS=%DELPHI_PATHS%;C:\Program Files (x86)\Embarcadero\Studio\19.0\bin"
set "DELPHI_PATHS=%DELPHI_PATHS%;C:\Program Files\Embarcadero\Studio\23.0\bin"
set "DELPHI_PATHS=%DELPHI_PATHS%;C:\Program Files\Embarcadero\Studio\22.0\bin"
set "DELPHI_PATHS=%DELPHI_PATHS%;C:\Program Files\Embarcadero\Studio\21.0\bin"

REM Primeiro verificar se dcc32 ja esta no PATH
where dcc32.exe >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo Delphi encontrado no PATH do sistema
    set "DCC32_PATH=dcc32.exe"
    goto delphi_found
)

REM Procurar nas localizacoes conhecidas
set "DCC32_PATH="
for %%p in (%DELPHI_PATHS%) do (
    if exist "%%~p\dcc32.exe" (
        echo Delphi encontrado em: %%~p
        set "DCC32_PATH=%%~p\dcc32.exe"
        set "PATH=%%~p;!PATH!"
        goto delphi_found
    )
)

REM Se nao encontrou mostrar erro
color %COLOR_ERROR%
echo ERRO: dcc32.exe nao encontrado!
echo.
echo Locais verificados:
for %%p in (%DELPHI_PATHS%) do (
    echo   - %%~p
)
echo.
echo Solucoes:
echo 1. Instalar RAD Studio/Delphi
echo 2. Verificar se a instalacao esta completa
echo 3. Executar a partir do Command Prompt do Delphi
echo 4. Adicionar manualmente ao PATH
color
pause
exit /b 1

:delphi_found
echo [2/5] Preparando ambiente... e Limpando build anterior...

if not exist %OUTPUT_DIR% (
    mkdir %OUTPUT_DIR%
    echo Criado: %OUTPUT_DIR%
)

if exist %OUTPUT_DIR%\*.exe (
    del /Q %OUTPUT_DIR%\*.exe
    echo Removidos: executaveis antigos
)

echo [3/5] Verificando dependencias...

if not exist %SOURCE_DIR% (
    color %COLOR_ERROR%
    echo ERRO: Diretorio source %SOURCE_DIR% nao encontrado!
    echo.
    echo Estrutura esperada:
    echo   Tests\           - diretorio atual
    echo   Source\          - codigo fonte
    echo     Context\
    echo     Strategy\
    echo     Generic\
    echo     Example\
    echo     Dependencies\
    echo.
    color
    pause
    exit /b 1
)

echo Diretorio source encontrado: %SOURCE_DIR%

REM Verificar se WebView4Delphi esta disponivel
set "WEBVIEW4DELPHI_PATH=%DEPENDENCIES_DIR%\WebView4Delphi\source"
if not exist "%WEBVIEW4DELPHI_PATH%" (
    color %COLOR_ERROR%
    echo ERRO: WebView4Delphi nao encontrado em: %WEBVIEW4DELPHI_PATH%
    echo.
    echo O projeto precisa do WebView4Delphi para compilar.
    echo Verifique se:
    echo 1. O WebView4Delphi esta na pasta Dependencies
    echo 2. O caminho esta correto
    echo 3. As units estao disponiveis
    echo.
    color
    pause
    exit /b 1
)

echo WebView4Delphi encontrado em: %WEBVIEW4DELPHI_PATH%

REM Verificar se DUnitX esta disponivel
set "DUNITX_PATH=%DEPENDENCIES_DIR%\DUnitX\Source"
if not exist "%DUNITX_PATH%" (
    color %COLOR_ERROR%
    echo ERRO: DUnitX nao encontrado em: %DUNITX_PATH%
    echo.
    echo O projeto precisa do DUnitX para testes.
    echo Verifique se:
    echo 1. O DUnitX esta na pasta Dependencies
    echo 2. O caminho esta correto
    echo 3. As units estao disponiveis
    echo.
    color
    pause
    exit /b 1
)

echo DUnitX encontrado em: %DUNITX_PATH%

REM Verificar se DelphiCodeCoverage esta disponivel
set "COVERAGE_PATH=%DEPENDENCIES_DIR%\DelphiCodeCoverage\Source"
if not exist "%COVERAGE_PATH%" (
    color %COLOR_WARNING%
    echo AVISO: DelphiCodeCoverage nao encontrado em: %COVERAGE_PATH%
    echo Os testes funcionarao sem cobertura de codigo.
    echo.
    color
) else (
    echo DelphiCodeCoverage encontrado em: %COVERAGE_PATH%
)

echo [4/5] Compilando projeto...

REM Construir paths de units
set "UNIT_PATHS=-U%SOURCE_DIR%;%SOURCE_DIR%\Context;%SOURCE_DIR%\Strategy;%SOURCE_DIR%\Generic;%SOURCE_DIR%\Example;%WEBVIEW4DELPHI_PATH%;%DUNITX_PATH%;%COVERAGE_PATH%"

REM Parâmetros de compilação
set "COMPILER_PARAMS=-B -Q"
set "OUTPUT_PARAMS=-E%OUTPUT_DIR%"
set "DEBUG_PARAMS=-$D+ -$L+ -$Y+ -$C+ -$Q+ -$R+ -$W+"
set "NAMESPACE_PARAMS=-NSSystem;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell"

REM Comando de compilação
set "BUILD_CMD="%DCC32_PATH%" %COMPILER_PARAMS% %UNIT_PATHS% %OUTPUT_PARAMS% %DEBUG_PARAMS% %NAMESPACE_PARAMS% %PROJECT_FILE%"

echo Executando: %BUILD_CMD%
echo.
echo Paths de units incluidos:
echo   - Source: %SOURCE_DIR%
echo   - Context: %SOURCE_DIR%\Context
echo   - Strategy: %SOURCE_DIR%\Strategy
echo   - Generic: %SOURCE_DIR%\Generic
echo   - Example: %SOURCE_DIR%\Example
echo   - WebView4Delphi: %WEBVIEW4DELPHI_PATH%
echo   - DUnitX: %DUNITX_PATH%
echo   - DelphiCodeCoverage: %COVERAGE_PATH%
echo.

call %BUILD_CMD%

set BUILD_RESULT=%ERRORLEVEL%

echo.
echo ================================================================

if %BUILD_RESULT% equ 0 (
    color %COLOR_SUCCESS%
    echo.
    echo BUILD CONCLUIDO COM SUCESSO!
    echo.
    
    if exist %OUTPUT_DIR%\%PROJECT_NAME%.exe (
        for %%i in (%OUTPUT_DIR%\%PROJECT_NAME%.exe) do (
            echo Executavel: %OUTPUT_DIR%\%PROJECT_NAME%.exe
            echo Tamanho: %%~zi bytes
            echo Data: %%~ti
        )

        echo.
        echo ================================================================
        echo Compilador: %DCC32_PATH%
        echo Tempo: %time%
        echo ================================================================

        echo.
        echo ================================================================
        echo                    EXECUTANDO TESTES
        echo ================================================================

        
        
    ) else (
        color %COLOR_WARNING%
        echo AVISO: Compilacao relatou sucesso mas executavel nao encontrado!
    )
    
) else (
    color %COLOR_ERROR%
    echo.
    echo BUILD FALHOU!
    echo.
    echo Codigo de erro: %BUILD_RESULT%
    echo.
    echo Para diagnosticar:
    echo 1. Execute o build novamente sem -Q para ver detalhes
    echo 2. Abra o projeto no Delphi IDE
    echo 3. Verifique se todas as units estao acessiveis
    echo 4. Verifique se as dependencias estao na pasta Dependencies
)