# Delphi Browser Framework

Este projeto em Delphi implementa um framework de abstração para navegadores ou formulários baseados em visualização Web, utilizando o padrão de projeto **Strategy** com suporte a **interfaces fluentes** e **encapsulamento de propriedades comuns**.

## ✨ Objetivo

Oferecer uma arquitetura extensível e reutilizável para formulários de navegador (`IBrowser` e `IBrowserForm`), com foco em:

- Configuração fluente (`method chaining`)
- Separação clara de responsabilidades
- Uso de interfaces para abstração e desacoplamento
- Propriedades e comportamentos reutilizáveis via interface base (`IBrowserGeneric`)

## 📦 Estrutura de Interfaces

### 🔹 IBrowserGeneric

Interface base com os métodos e propriedades comuns:

- `Width`, `Height`, `Caption`, `CaptionPosition`
- `ActionButtons`, `Resizable`, `Movable`

```pascal
type
  IBrowserGeneric = interface
    ...
  end;
````

### 🔹 IBrowser

Interface principal para navegadores personalizados.

```pascal
type
  IBrowser = interface(IBrowserGeneric)
    ...
  end;
```

### 🔹 IBrowserForm

Versão especializada da interface para integração com formulários Delphi.

```pascal
type
  IBrowserForm = interface(IBrowserGeneric)
    ...
  end;
```

## 🧩 Como usar

1. Implemente a interface `IBrowserForm` ou `IBrowser` em uma classe Delphi.
2. Use os métodos fluentes para configurar as propriedades antes de exibir o formulário:

```pascal
BrowserForm
  .SetWidth(800)
  .SetHeight(600)
  .SetCaption('Exemplo de Navegador')
  .SetResizable(True)
  .ShowModal;
```

## 📁 Organização do Projeto

```
/Source
  ├── Context
  │   ├── BrowserFormInterface.pas      // Interface IBrowserForm
  │   ├── WebBrowserFormClass.pas       // Implementação com TWebBrowser
  │   └── WVBrowserFormClass.pas        // Implementação com WebView2
  │
  ├── Generic
  │   ├── BrowserGenericInterface.pas   // Interface IBrowserSettings (genérica)
  │   └── BrowserTypes.pas              // Tipos auxiliares (TPositionCaption, TOpenType etc.)
  │
  └── Strategy
      ├── BrowserClass.pas              // Implementação da lógica de navegador
      └── BrowserInterface.pas          // Interface IBrowser
```

## 📁 Diagrama Mermaid

### 📁 Mermaid Graph TD

```mermaid
graph TD

  subgraph Source
    subgraph Context
      A1[BrowserFormInterface.pas]
      A2[WebBrowserFormClass.pas]
      A3[WVBrowserFormClass.pas]
    end

    subgraph Generic
      B1[BrowserGenericInterface.pas]
      B2[BrowserTypes.pas]
    end

    subgraph Strategy
      C1[BrowserClass.pas]
      C2[BrowserInterface.pas]
    end
  end

  %% Relações entre as unidades (exemplo genérico)
  C2 --> B1
  C1 --> C2
  A1 --> B1
  A2 --> A1
  A3 --> A1
```

### 📁 Mermaid Flowchart TB

```mermaid
flowchart TB
    subgraph Source
        subgraph Context
            A1[BrowserFormInterface.pas]
            A2[WebBrowserFormClass.pas]
            A3[WVBrowserFormClass.pas]
        end

        subgraph Generic
            B1[BrowserGenericInterface.pas]
            B2[BrowserTypes.pas]
        end

        subgraph Strategy
            C1[BrowserClass.pas]
            C2[BrowserInterface.pas]
        end
    end

    %% Relações de uso (exemplos de dependências)
    A2 --> A1
    A3 --> A1
    C1 --> C2
    A2 --> C2
    A3 --> C2
    A1 --> B1
    B1 --> B2
    C2 --> B1
```

## 🔧 Requisitos

* Delphi 10.4+ (recomendado)
* VCL com suporte a `TBorderIcons`, `TPosition`, etc.

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

Feito com 💻 por \[Nickson Jeanmerson]