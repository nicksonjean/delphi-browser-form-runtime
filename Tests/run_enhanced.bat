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

REM Verificar argumentos
if "%1"=="help" goto show_help
if "%1"=="-h" goto show_help
if "%1"=="/?" goto show_help

REM Verificar se executável existe
if not exist %TEST_EXE% (
    color %COLOR_ERROR%
    echo ERRO: %TEST_EXE% nao encontrado!
    echo.
    echo Execute primeiro: build.bat
    color
    pause
    exit /b 1
)

REM Criar diretório de resultados
if not exist %RESULTS_DIR% mkdir %RESULTS_DIR%

REM Limpar resultados anteriores
if exist %RESULTS_DIR%\*.* del /Q %RESULTS_DIR%\*.*
if exist TestResults.* del /Q TestResults.*

REM Obter timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%"
set "Min=%dt:~10,2%"
set "Sec=%dt:~12,2%"
set "timestamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

echo Data/Hora: %DD%/%MM%/%YYYY% %HH%:%Min%:%Sec%
echo Executavel: %TEST_EXE%
echo.

REM Processar argumentos
set "RUN_MODE=default"
set "CATEGORY="
set "QUIET_MODE=false"
set "REPORT_MODE=all"
set "FILTER="

:parse_args
if "%1"=="" goto execute_tests

if "%1"=="console" (
    set "REPORT_MODE=console"
    shift
    goto parse_args
)

if "%1"=="xml" (
    set "REPORT_MODE=xml"
    shift
    goto parse_args
)

if "%1"=="quiet" (
    set "QUIET_MODE=true"
    shift
    goto parse_args
)

if "%1"=="category" (
    if "%2"=="" (
        echo ERRO: Categoria nao especificada!
        goto show_categories
    )
    set "CATEGORY=%2"
    shift
    shift
    goto parse_args
)

if "%1"=="filter" (
    if "%2"=="" (
        echo ERRO: Filtro nao especificado!
        echo Exemplo: run_enhanced.bat filter "*Width*"
        goto end
    )
    set "FILTER=%2"
    shift
    shift
    goto parse_args
)

if "%1"=="list" (
    goto list_tests
)

if "%1"=="benchmark" (
    goto run_benchmark
)

if "%1"=="coverage" (
    goto run_coverage
)

REM Argumento desconhecido
echo AVISO: Argumento desconhecido: %1
shift
goto parse_args

:execute_tests
echo Iniciando execucao dos testes...
echo.

REM Construir linha de comando
set "CMD_LINE=%TEST_EXE%"

REM Adicionar reporters baseado no modo
if "%REPORT_MODE%"=="console" (
    set "CMD_LINE=!CMD_LINE!"
) else if "%REPORT_MODE%"=="xml" (
    set "CMD_LINE=!CMD_LINE! -xml TestResults.xml"
) else (
    set "CMD_LINE=!CMD_LINE! -xml TestResults.xml"
)

REM Adicionar modo quiet (removido - não suportado)
REM if "%QUIET_MODE%"=="true" (
REM     set "CMD_LINE=!CMD_LINE! --quiet"
REM )

REM Adicionar categoria
if not "%CATEGORY%"=="" (
    set "CMD_LINE=!CMD_LINE! -i %CATEGORY%"
    echo Executando apenas categoria: %CATEGORY%
    echo.
)

REM Adicionar filtro (removido - não suportado nesta versão)
REM if not "%FILTER%"=="" (
REM     set "CMD_LINE=!CMD_LINE! --filter:%FILTER%"
REM     echo Aplicando filtro: %FILTER%
REM     echo.
REM )

REM Executar testes
echo Comando: !CMD_LINE!
echo.
echo ================================================================
echo                        EXECUTANDO TESTES
echo ================================================================
echo.

!CMD_LINE!

set TEST_RESULT=%ERRORLEVEL%

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

REM Mostrar sumário se arquivo de texto existir
if exist %RESULTS_DIR%\TestResults_%timestamp%.txt (
    echo.
    echo ================================================================
    echo                          SUMARIO
    echo ================================================================
    
    for /f "tokens=*" %%i in ('findstr /C:"Total Tests:" %RESULTS_DIR%\TestResults_%timestamp%.txt') do echo %%i
    for /f "tokens=*" %%i in ('findstr /C:"Passed:" %RESULTS_DIR%\TestResults_%timestamp%.txt') do echo %%i
    for /f "tokens=*" %%i in ('findstr /C:"Failed:" %RESULTS_DIR%\TestResults_%timestamp%.txt') do echo %%i
    for /f "tokens=*" %%i in ('findstr /C:"Errors:" %RESULTS_DIR%\TestResults_%timestamp%.txt') do echo %%i
    for /f "tokens=*" %%i in ('findstr /C:"Memory Leaks:" %RESULTS_DIR%\TestResults_%timestamp%.txt') do echo %%i
)

color
goto end

:list_tests
echo ================================================================
echo                    LISTAGEM DE TESTES
echo ================================================================
%TEST_EXE% -h
goto end

:run_benchmark
echo ================================================================
echo                   EXECUTANDO BENCHMARK
echo ================================================================
echo Executando testes de performance...

REM Executar categoria Performance 3 vezes e calcular média
set /a "total_time=0"
set /a "runs=3"

for /l %%i in (1,1,%runs%) do (
    echo.
    echo Execucao %%i de %runs%...
    
    set "start_time=!time!"
    %TEST_EXE% -i Performance
    set "end_time=!time!"
    
    REM Calcular tempo (simplificado)
    echo Tempo execucao %%i: !start_time! - !end_time!
)

echo.
echo Benchmark concluido!
goto end

:run_coverage
echo ================================================================
echo                 EXECUTANDO COM COBERTURA
echo ================================================================

REM Verificar se CodeCoverage está disponível
where CodeCoverage.exe >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo CodeCoverage.exe nao encontrado no PATH
    echo Download: https://github.com/DelphiCodeCoverage/DelphiCodeCoverage
    goto end
)

echo Executando testes com analise de cobertura...

REM Executar com cobertura
CodeCoverage.exe -e %TEST_EXE% -m "*.pas" -uf ..\Source\WVBrowserFormClass.pas -html -od Coverage

if %ERRORLEVEL% equ 0 (
    echo.
    echo Relatorio de cobertura gerado em: Coverage\index.html
    
    REM Abrir relatório se possível
    if exist Coverage\index.html (
        echo Abrindo relatorio...
        start Coverage\index.html
    )
) else (
    echo Erro ao gerar relatorio de cobertura
)

goto end

:show_categories
echo.
echo ================================================================
echo                   CATEGORIAS DISPONIVEIS
echo ================================================================
echo.
echo Constructor      - Testes de construcao e inicializacao
echo Properties       - Testes de propriedades e getters/setters  
echo FluentInterface  - Testes da interface fluente (method chaining)
echo Configuration    - Testes de configuracao de janela
echo Cookies          - Testes de manipulacao de cookies
echo MDI              - Testes especificos para MDI
echo Validation       - Testes de validacao de dados
echo State            - Testes de estado interno do objeto
echo Factory          - Testes dos metodos factory
echo Messages         - Testes de sistema de mensagens
echo Content          - Testes de conteudo HTML
echo ShowMethods      - Testes dos metodos Show/ShowModal
echo Interface        - Testes da interface IBrowserForm
echo EdgeCases        - Testes de casos extremos
echo Relationships    - Testes de relacionamentos Parent/Child
echo Events           - Testes de eventos
echo Performance      - Testes de performance
echo.
echo Exemplo: run_enhanced.bat category Properties
echo.
goto end

:show_help
echo.
echo ================================================================
echo                    AJUDA - Test Runner v%SCRIPT_VERSION%
echo ================================================================
echo.
echo USO:
echo   run_enhanced.bat [opcao] [parametro]
echo.
echo OPCOES BASICAS:
echo   console          - Executar apenas com saida no console
echo   xml              - Executar apenas com saida XML
echo   quiet            - Executar em modo silencioso
echo   category [nome]  - Executar apenas categoria especifica
echo   filter [pattern] - Filtrar testes por padrao (nao implementado)
echo.
echo OPCOES AVANCADAS:
echo   list             - Listar informacoes dos testes
echo   benchmark        - Executar testes de performance
echo   coverage         - Executar com analise de cobertura
echo   help             - Mostrar esta ajuda
echo.
echo EXEMPLOS:
echo   run_enhanced.bat
echo   run_enhanced.bat console
echo   run_enhanced.bat category Constructor
echo   run_enhanced.bat xml
echo   run_enhanced.bat benchmark
echo   run_enhanced.bat coverage
echo.
echo ARQUIVOS GERADOS:
echo   Results\TestResults_[timestamp].xml - Formato NUnit
echo   Results\TestResults_[timestamp].txt - Relatorio detalhado
echo   Coverage\index.html                 - Relatorio de cobertura
echo.
goto end

:end
echo.
if exist TEST_RESULT (
    if %TEST_RESULT% neq 0 (
        echo Codigo de saida: %TEST_RESULT%
        echo Para mais informacoes, execute: run_enhanced.bat help
    )
)
echo.

REM Pause apenas se não estiver em modo quiet
if "%QUIET_MODE%" neq "true" (
    if not defined CI (
        pause
    )
)

if defined TEST_RESULT (
    exit /b %TEST_RESULT%
) else (
    exit /b 0
)