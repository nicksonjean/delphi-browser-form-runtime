# WVBrowser Test Suite

Sistema de testes unitários para o projeto WVBrowser Form Runtime, utilizando DUnitX e integração com WebView4Delphi.

## 📋 Visão Geral

Este sistema de testes foi configurado para validar a funcionalidade dos componentes de browser WebView2, incluindo:

- **Testes de Construção**: Validação de construtores e inicialização
- **Testes de Propriedades**: Verificação de getters/setters
- **Testes de Interface Fluente**: Method chaining e fluent interface
- **Testes de Configuração**: Resizable, movable, etc.
- **Testes de Cookies**: Manipulação de cookies
- **Testes MDI**: Suporte a MDI (Multiple Document Interface)
- **Testes de Factory**: Métodos factory para criação de instâncias
- **Testes de Interface**: Compatibilidade com interfaces
- **Testes de Conteúdo**: HTML content e navegação
- **Testes de Exibição**: Métodos Show/ShowModal

## 🏗️ Estrutura do Projeto

```
Tests/
├── TestBrowserForm.dpr          # Programa principal de testes
├── TestUnitBrowserForm.pas      # Unit com os testes
├── build_enhanced.bat           # Script de build avançado
├── run_enhanced.bat             # Script de execução de testes
├── cleanup.bat                  # Script de limpeza
├── Output/                      # Executáveis compilados
│   └── DCU/                     # Arquivos DCU
└── Results/                     # Relatórios gerados
    ├── TestReport_*.xml         # Relatório NUnit XML
    └── TestReport_*_simple.txt  # Relatório simples em texto
```

## 🚀 Como Usar

### 1. Compilar e Executar Testes

```bash
# Compilar e executar todos os testes
build_enhanced.bat

# Apenas executar testes (se já compilado)
run_enhanced.bat
```

### 2. Opções de Execução

```bash
# Executar apenas no console
run_enhanced.bat console

# Executar com relatório XML
run_enhanced.bat xml

# Executar com relatório HTML
run_enhanced.bat html

# Executar com relatório JSON
run_enhanced.bat json

# Executar apenas uma categoria específica
run_enhanced.bat category Constructor

# Executar em modo silencioso
run_enhanced.bat quiet

# Limpar relatórios anteriores
run_enhanced.bat clean

# Mostrar ajuda
run_enhanced.bat help
```

### 3. Limpeza do Ambiente

```bash
# Limpar todos os arquivos temporários
cleanup.bat
```

## 📊 Interpretando Resultados

### Status dos Testes

- **✅ Passed**: Teste executado com sucesso
- **❌ Failed**: Teste falhou (assertion não passou)
- **⚠️ Error**: Erro de execução (exceção, ponteiro inválido, etc.)
- **⏭️ Skipped**: Teste ignorado

### Relatórios Gerados

1. **Console**: Saída colorida no terminal
2. **XML (NUnit)**: Compatível com CI/CD e ferramentas de análise
3. **Simple TXT**: Relatório básico em texto

### Exemplo de Saída

```
================================================================
                    WVBrowser Test Suite (Enhanced)
================================================================

Tests Found   : 18
Tests Ignored : 0
Tests Passed  : 10
Tests Leaked  : 0
Tests Failed  : 0
Tests Errored : 8

Success Rate: 55.6%
```

## 🔧 Dependências

### Obrigatórias
- **Delphi/RAD Studio**: Compilador dcc32.exe
- **WebView4Delphi**: Componentes WebView2
- **DUnitX**: Framework de testes

### Estrutura de Dependências
```
Source/Dependencies/
├── WebView4Delphi/              # Componentes WebView2
├── DUnitX/                      # Framework de testes
└── DelphiCodeCoverage/          # Cobertura de código (opcional)
```

## 🐛 Troubleshooting

### Erros Comuns

1. **"dcc32.exe not found"**
   - Verifique se o Delphi está instalado
   - Adicione o caminho do Delphi ao PATH

2. **"WebView4Delphi not found"**
   - Verifique se a pasta `Source/Dependencies/WebView4Delphi` existe
   - Clone o repositório se necessário

3. **"DUnitX not found"**
   - Verifique se a pasta `Source/Dependencies/DUnitX` existe
   - Clone o repositório se necessário

4. **"Invalid pointer operation"**
   - Erro comum em testes que dependem de componentes WebView2
   - Alguns testes podem falhar em ambiente sem WebView2 Runtime

### Logs e Debug

- Execute `build_enhanced.bat` sem o parâmetro `-Q` para ver detalhes de compilação
- Verifique os relatórios em `Results/` para detalhes dos erros
- Use `run_enhanced.bat console` para saída detalhada no console

## 📈 Categorias de Teste

### Constructor
- `TestCreate_Default_ShouldSetDefaultValues`
- `TestCreate_WithURL_ShouldSetURL`

### Properties
- `TestSetWidth_ShouldUpdateProperty`
- `TestSetHeight_ShouldUpdateProperty`
- `TestSetCaption_ShouldUpdateCaption`
- `TestSetURL_ShouldUpdateURL`

### FluentInterface
- `TestChainableMethods_ShouldReturnSelf`
- `TestComplexChaining_ShouldWorkCorrectly`

### Configuration
- `TestSetResizable_ShouldWork`
- `TestSetMovable_ShouldWork`

### Cookies
- `TestSetCookie_ShouldSetProperties`

### MDI
- `TestSetMaxInstances_ShouldUpdateProperty`
- `TestCheckMDILimits_ShouldReturnTrue`

### State
- `TestIsPopup_InitialState_ShouldBeFalse`

### Factory
- `TestNewBrowser_ShouldCreateWithDefaults`

### Interface
- `TestInterfaceCompatibility_ShouldWork`

### Content
- `TestSetHTMLContent_ShouldReturnSelf`

### ShowMethods
- `TestShow_ShouldNotRaiseUnexpectedExceptions`

## 🔄 CI/CD Integration

### Exemplo para GitHub Actions

```yaml
- name: Run Tests
  run: |
    cd Tests
    build_enhanced.bat
    if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
```

### Exemplo para Jenkins

```groovy
stage('Test') {
    steps {
        bat '''
            cd Tests
            build_enhanced.bat
        '''
    }
    post {
        always {
            publishTestResults testResultsPattern: 'Tests/Results/*.xml'
        }
    }
}
```

## 📝 Contribuindo

1. Adicione novos testes em `TestUnitBrowserForm.pas`
2. Use as categorias existentes ou crie novas
3. Execute `build_enhanced.bat` para validar
4. Verifique se todos os testes passam
5. Atualize esta documentação se necessário

## 📞 Suporte

Para problemas ou dúvidas:
1. Verifique os logs de erro
2. Execute `run_enhanced.bat help` para opções
3. Consulte a documentação do DUnitX
4. Verifique se todas as dependências estão instaladas

---

**Versão**: 3.0  
**Última atualização**: Junho 2025  
**Autor**: Nickson Jeanmerson 