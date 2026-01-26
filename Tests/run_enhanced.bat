@echo off
setlocal enabledelayedexpansion
set SCRIPT_VERSION=3.0

REM ================================================================
REM Script Avançado para Execução de Testes Unitários WVBrowser
REM Versão: %SCRIPT_VERSION%
REM Autor: Nickson Jeanmerson
REM ================================================================

set TEST_EXE=Output\TestBrowserForm.exe
set TEST_ENHANCED_EXE=Output\TestBrowserForm_Enhanced.exe
set OUTPUT_DIR=Output
set RESULTS_DIR=Output\Results
set COVERAGE_DIR=Output\Coverage

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
if not exist %TEST_EXE% (
    color %COLOR_ERROR%
    echo ERRO: %TEST_EXE% nao encontrado!
    echo Compile o projeto primeiro usando build_enhanced.bat
    echo.
    color
    pause
    exit /b 1
)

REM Criar diretório de resultados se não existir
if not exist %RESULTS_DIR% (
    mkdir %RESULTS_DIR%
    echo Criado diretorio: %RESULTS_DIR%
)

REM Criar diretório de cobertura se não existir
if not exist %COVERAGE_DIR% (
    mkdir %COVERAGE_DIR%
    echo Criado diretorio: %COVERAGE_DIR%
)

REM Limpar arquivos de resultado anteriores (opcional)
if "%1"=="clean" (
    if exist %RESULTS_DIR%\*.html del /Q %RESULTS_DIR%\*.html
    if exist %RESULTS_DIR%\*.json del /Q %RESULTS_DIR%\*.json
    if exist %RESULTS_DIR%\*.xml del /Q %RESULTS_DIR%\*.xml
    if exist %RESULTS_DIR%\*.txt del /Q %RESULTS_DIR%\*.txt
    if exist %COVERAGE_DIR%\*.html del /Q %COVERAGE_DIR%\*.html
    echo Limpeza de resultados anteriores concluida
    echo.
)

echo Executando testes...
echo.

REM Executar testes com diferentes opções
if "%1"=="console" goto console
if "%1"=="xml" goto xml
if "%1"=="quiet" goto quiet
if "%1"=="category" goto category
if "%1"=="html" goto html
if "%1"=="json" goto json
if "%1"=="all" goto all
if "%1"=="help" goto help
if "%1"=="clean" goto clean
if "%1"=="coverage" goto coverage

REM Execução padrão (todos os relatórios)
:default
echo Executando testes com relatorios completos...
%TEST_EXE%
goto end

REM Apenas console
:console
echo Executando testes apenas no console...
%TEST_EXE% --console
goto end

REM Apenas XML
:xml
echo Executando testes com saida XML...
%TEST_EXE% --xml
goto end

REM Modo silencioso
:quiet
echo Executando testes em modo silencioso...
%TEST_EXE% --quiet
goto end

REM Executar categoria específica
:category
if "%2"=="" (
    color %COLOR_ERROR%
    echo ERRO: Especifique uma categoria!
    echo Exemplo: run_enhanced.bat category Constructor
    echo.
    echo Categorias disponíveis:
    echo - Constructor
    echo - Properties  
    echo - FluentInterface
    echo - Configuration
    echo - Cookies
    echo - MDI
    echo - State
    echo - Factory
    echo - Interface
    echo - Content
    echo - ShowMethods
    color
    goto end
)
echo Executando categoria: %2
%TEST_EXE% --category %2
goto end

REM Apenas HTML
:html
echo Executando testes com relatorio HTML...
%TEST_EXE% --html
goto end

REM Apenas JSON
:json
echo Executando testes com relatorio JSON...
%TEST_EXE% --json
goto end

REM Todos os relatórios
:all
echo Executando testes com todos os relatorios...
%TEST_EXE% --all
goto end

REM Cobertura de código
:coverage
echo Executando testes com cobertura de codigo...
if exist %TEST_ENHANCED_EXE% (
    %TEST_ENHANCED_EXE%
) else (
    color %COLOR_WARNING%
    echo AVISO: Executavel com cobertura nao encontrado. Usando versao basica.
    color
    %TEST_EXE%
)
goto end

REM Limpar resultados
:clean
echo Limpeza concluida.
goto end

REM Ajuda
:help
echo.
echo Uso: run_enhanced.bat [opcao] [parametro]
echo.
echo Opcoes:
echo   console    - Executar apenas com saida no console
echo   xml        - Executar com saida XML
echo   html       - Executar com relatorio HTML
echo   json       - Executar com relatorio JSON
echo   all        - Executar com todos os relatorios
echo   coverage   - Executar com cobertura de codigo
echo   quiet      - Executar em modo silencioso
echo   category   - Executar apenas categoria especifica
echo   clean      - Limpar relatorios anteriores
echo   help       - Mostrar esta ajuda
echo.
echo Exemplos:
echo   run_enhanced.bat                    - Execucao padrao (todos os relatorios)
echo   run_enhanced.bat console            - Apenas console
echo   run_enhanced.bat xml                - Gerar arquivo XML
echo   run_enhanced.bat html               - Gerar relatorio HTML
echo   run_enhanced.bat json               - Gerar relatorio JSON
echo   run_enhanced.bat coverage           - Executar com cobertura de codigo
echo   run_enhanced.bat category Constructor - Apenas testes de construtor
echo   run_enhanced.bat clean              - Limpar relatorios anteriores
echo.
echo Categorias de teste:
echo   Constructor, Properties, FluentInterface, Configuration,
echo   Cookies, MDI, State, Factory, Interface, Content, ShowMethods
echo.
echo Relatorios gerados em:
echo   - %RESULTS_DIR% (Resultados de teste)
echo   - %COVERAGE_DIR% (Relatorios de cobertura)
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
    color %COLOR_SUCCESS%
    echo ================================================================
    echo                  TODOS OS TESTES PASSARAM!
    echo ================================================================
) else if %ERRORLEVEL% equ 1 (
    color %COLOR_WARNING%
    echo ================================================================
    echo                   ALGUNS TESTES FALHARAM!
    echo ================================================================
) else (
    color %COLOR_ERROR%
    echo ================================================================
    echo                   ERRO FATAL NA EXECUCAO!
    echo ================================================================
)

color
echo.
echo Relatorios disponiveis em: %RESULTS_DIR%
echo.
echo Para visualizar o relatorio HTML:
echo   start %RESULTS_DIR%\TestReport_*.html
echo.
pause