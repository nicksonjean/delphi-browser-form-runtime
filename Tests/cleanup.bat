@echo off
setlocal enabledelayedexpansion
set CLEANUP_VERSION=3.0

REM ================================================================
REM Script de Limpeza Avançado para WVBrowser Tests - Versao: %CLEANUP_VERSION%
REM Versão: %CLEANUP_VERSION%
REM Autor: Nickson Jeanmerson
REM ================================================================

set OUTPUT_DIR=Output
set RESULTS_DIR=Output\Results
set COVERAGE_DIR=Output\Coverage

REM Cores para output
set COLOR_SUCCESS=2
set COLOR_ERROR=4
set COLOR_WARNING=6
set COLOR_INFO=3

echo.
echo ================================================================
echo            WVBrowser Tests - Cleanup Script Versao: %CLEANUP_VERSION%
echo ================================================================
echo.

echo [1/4] Limpando arquivos de build...

REM Limpar executáveis
if exist %OUTPUT_DIR%\*.exe (
    del /Q %OUTPUT_DIR%\*.exe
    echo Removidos: executaveis em %OUTPUT_DIR%
) else (
    echo Nenhum executavel encontrado em %OUTPUT_DIR%
)

echo [2/4] Limpando relatorios de teste...

REM Limpar relatórios de teste
if exist %RESULTS_DIR%\*.html (
    del /Q %RESULTS_DIR%\*.html
    echo Removidos: relatorios HTML em %RESULTS_DIR%
) else (
    echo Nenhum relatorio HTML encontrado em %RESULTS_DIR%
)

if exist %RESULTS_DIR%\*.xml (
    del /Q %RESULTS_DIR%\*.xml
    echo Removidos: relatorios XML em %RESULTS_DIR%
) else (
    echo Nenhum relatorio XML encontrado em %RESULTS_DIR%
)

if exist %RESULTS_DIR%\*.json (
    del /Q %RESULTS_DIR%\*.json
    echo Removidos: relatorios JSON em %RESULTS_DIR%
) else (
    echo Nenhum relatorio JSON encontrado em %RESULTS_DIR%
)

if exist %RESULTS_DIR%\*.txt (
    del /Q %RESULTS_DIR%\*.txt
    echo Removidos: relatorios TXT em %RESULTS_DIR%
) else (
    echo Nenhum relatorio TXT encontrado em %RESULTS_DIR%
)

echo [3/4] Limpando relatorios de cobertura...

REM Limpar relatórios de cobertura
if exist %COVERAGE_DIR%\*.html (
    del /Q %COVERAGE_DIR%\*.html
    echo Removidos: relatorios de cobertura HTML em %COVERAGE_DIR%
) else (
    echo Nenhum relatorio de cobertura encontrado em %COVERAGE_DIR%
)

if exist %COVERAGE_DIR%\*.xml (
    del /Q %COVERAGE_DIR%\*.xml
    echo Removidos: relatorios de cobertura XML em %COVERAGE_DIR%
) else (
    echo Nenhum relatorio de cobertura XML encontrado em %COVERAGE_DIR%
)

echo [4/4] Limpando arquivos temporarios...

REM Limpar arquivos temporários
if exist *.tmp del /Q *.tmp
if exist *.log del /Q *.log
if exist *.bak del /Q *.bak

REM Limpar pasta Results antiga (se existir fora de Output)
if exist Results (
    rmdir /S /Q Results
    echo Removida: pasta Results antiga (fora de Output)
)

echo.
echo ================================================================
echo                    LIMPEZA CONCLUIDA!
echo ================================================================
echo.

color %COLOR_SUCCESS%
echo Todos os arquivos temporarios e de build foram removidos.
echo.
echo Diretorios limpos:
echo   - %OUTPUT_DIR% (executaveis)
echo   - %RESULTS_DIR% (relatorios de teste)
echo   - %COVERAGE_DIR% (relatorios de cobertura)
echo   - Diretorio atual (temporarios)
echo.

color %COLOR_INFO%
echo Para executar novamente:
echo   1. build.bat    - Compilar o projeto
echo   2. run.bat      - Executar os testes
echo   3. cleanup.bat  - Limpar novamente (este script)
echo.

color
pause 