@echo off
setlocal enabledelayedexpansion
set SCRIPT_VERSION=2.0

REM ================================================================
REM Script Avançado para Execução de Testes Unitários WVBrowser
REM Versão: %SCRIPT_VERSION%
REM Autor: Nickson Jeanmerson
REM ================================================================

set TEST_EXE=Output\WVBrowserTests.exe
set OUTPUT_DIR=Output
set RESULTS_DIR=Results

REM Cores para output (se suportado)
set COLOR_SUCCESS=2
set COLOR_ERROR=4
set COLOR_WARNING=6
set COLOR_INFO=3

echo.
echo ================================================================
echo           WVBrowser Unit Tests Runner Versao: %SCRIPT_VERSION%
echo ================================================================
echo.

REM Verificar se o executável existe
if not exist Output\WVBrowserTests.exe (
    echo ERRO Output\WVBrowserTests.exe nao encontrado!
    echo Compile o projeto primeiro usando build.bat
    echo.
    pause
    exit /b 1
)

REM Limpar arquivos de resultado anteriores
if exist TestResults.txt del TestResults.txt
if exist TestResults.xml del TestResults.xml

echo Executando testes...
echo.

REM Executar testes com diferentes opções
if "%1"=="console" goto console
if "%1"=="xml" goto xml
if "%1"=="quiet" goto quiet
if "%1"=="category" goto category
if "%1"=="help" goto help

REM Execução padrão (console + xml)
:default
Output\WVBrowserTests.exe
goto end

REM Apenas console
:console
Output\WVBrowserTests.exe
goto end

REM Apenas XML
:xml
Output\WVBrowserTests.exe -xml TestResults.xml
goto end

REM Modo silencioso
:quiet
Output\WVBrowserTests.exe
goto end

REM Executar categoria específica
:category
if "%2"=="" (
    echo ERRO Especifique uma categoria!
    echo Exemplo run.bat category Constructor
    echo.
    echo Categorias disponíveis
    echo - Constructor
    echo - Properties  
    echo - FluentInterface
    echo - Configuration
    echo - Cookies
    echo - MDI
    echo - Validation
    echo - State
    echo - Factory
    echo - Messages
    echo - Content
    goto end
)
Output\WVBrowserTests.exe -i %2
goto end

REM Ajuda
:help
echo.
echo Uso run.bat [opcao] [parametro]
echo.
echo Opcoes
echo   console    - Executar apenas com saida no console
echo   xml        - Executar com saida XML (TestResults.xml)
echo   quiet      - Executar em modo silencioso
echo   category   - Executar apenas categoria especifica
echo   help       - Mostrar esta ajuda
echo.
echo Exemplos
echo   run.bat                    - Execucao padrao (console verbose)
echo   run.bat console            - Apenas console
echo   run.bat xml                - Gerar arquivo XML
echo   run.bat category Constructor - Apenas testes de construtor
echo.
echo Categorias de teste
echo   Constructor, Properties, FluentInterface, Configuration,
echo   Cookies, MDI, Validation, State, Factory, Messages, Content
echo.
goto end

:end
echo.
echo ================================================================
echo                            RESULTADO
echo ================================================================
echo.

REM Verificar código de saída
if %ERRORLEVEL% equ 0 (
    echo ================================================================
    echo                  TODOS OS TESTES PASSARAM!
    echo ================================================================
) else if %ERRORLEVEL% equ 1 (
    echo ================================================================
    echo                   ALGUNS TESTES FALHARAM!
    echo ================================================================
) else (
    echo ================================================================
    echo                   ERRO FATAL NA EXECUCAO!
    echo ================================================================
)

REM Mover resultados para diretório com timestamp
if exist TestResults.xml (
    move TestResults.xml %RESULTS_DIR%\TestResults_%timestamp%.xml >nul
    echo Resultado XML: %RESULTS_DIR%\TestResults_%timestamp%.xml
)

if exist TestResults.txt (
    move TestResults.txt %RESULTS_DIR%\TestResults_%timestamp%.txt >nul
    echo Resultado TXT: %RESULTS_DIR%\TestResults_%timestamp%.txt
)

echo.
pause