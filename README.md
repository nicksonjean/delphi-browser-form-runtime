# Delphi Browser Framework

Este projeto em Delphi implementa um framework de abstração para navegadores ou formulários baseados em visualização Web, utilizando o padrão de projeto **Strategy** com suporte a **interfaces fluentes** e **encapsulamento de propriedades comuns**.

## ✨ Objetivo

Oferecer uma arquitetura extensível e reutilizável para formulários de navegador (`IBrowserForm`), com foco em:

- Configuração fluente (`method chaining`)
- Separação clara de responsabilidades
- Uso de interfaces para abstração e desacoplamento
- Suporte a múltiplos tipos de navegador (Edge e WebView2)
- Gerenciamento de instâncias MDI e popup

## 📦 Estrutura de Interfaces

### 🔹 IBrowserForm

Interface principal para formulários de navegador com propriedades e métodos comuns:

```pascal
type
  IBrowserForm = interface
    // Propriedades básicas
    property Width: Integer;
    property Height: Integer;
    property Caption: string;
    property CaptionPosition: TPositionCaption;
    property ActionButtons: TBorderIcons;
    property Resizable: Boolean;
    property Movable: Boolean;
    property TitleBar: Boolean;
    
    // Propriedades de cookie
    property CookieName: String;
    property CookieValue: String;
    property CookieDomain: String;
    property CookiePath: String;
    
    // Propriedades de controle
    property Alpha: Boolean;
    property URL: String;
    property ParentForm: TForm;
    property ParentBrowser: TComponent;
    property UniqueIdentifier: String;
    property MaxInstances: Integer;
    property LegacyForm: Boolean;
    
    // Eventos
    property OnMessageReceiver: TMessageReceiverCallback;
    property OnMessageSender: String;
    property OnWindowOpened: TNotifyEvent;
    property OnWindowClosed: TNotifyEvent;
    
    // Métodos de exibição
    procedure Show(const AType: TOpenType = TOpenType.Default);
    procedure ShowModal(const AType: TOpenType = TOpenType.Modal);
    procedure ShowAsModal(AParentForm: TForm = nil);
    procedure ShowAsMDICustom(AutoShow: Boolean = True);
    procedure ShowAsMDISimple(AutoShow: Boolean; SingleInstance: Boolean; MaximizeOnShow: Boolean = True);
    procedure ShowAsMDIAdvanced(AutoShow: Boolean = True; SingleInstance: Boolean = True; MaximizeOnShow: Boolean = True; BringToFrontIfExists: Boolean = True; const UniqueIdentifier: String = ''; MaxInstances: Integer = 1);
  end;
```

### 🔹 IBrowserFormFactory

Interface para criação de navegadores usando o padrão Factory:

```pascal
type
  IBrowserFormFactory = interface
    function CreateBrowser(const AURL: String = ''): IBrowserForm;
    function CreatePopup(AParentBrowser: TComponent; const AURL: String = ''): IBrowserForm;
    function CreateMDI(AParentForm: TForm; const AURL: String = ''; ALegacyForm: Boolean = false): IBrowserForm;
    function GetBrowserType: TBrowserType;
    function GetBrowserTypeName: String;
  end;
```

## 🧩 Como usar

### 1. Configuração básica

```pascal
// Usar WebView2 (padrão)
TBrowserStrategy.SetBrowserType(WebView2);

// Criar um navegador básico
var Browser := TBrowserStrategy.CreateBrowser('https://www.google.com');
Browser
  .SetWidth(800)
  .SetHeight(600)
  .SetCaption('Meu Navegador')
  .SetResizable(True)
  .Show;
```

### 2. Criar popup

```pascal
var Popup := TBrowserStrategy.CreatePopup(ParentBrowser, 'https://www.example.com');
Popup
  .SetWidth(400)
  .SetHeight(300)
  .SetCaption('Popup')
  .ShowAsModal;
```

### 3. Criar MDI

```pascal
var MDIBrowser := TBrowserStrategy.CreateMDI(ParentForm, 'https://www.example.com');
MDIBrowser
  .SetCaption('MDI Browser')
  .ShowAsMDIAdvanced(True, True, True, True, 'unique-id', 1);
```

## 📁 Organização do Projeto

```
/Source
  ├── Context/                           # Implementações específicas
  │   ├── IBrowserFormBase.pas          # Interface IBrowserForm
  │   ├── BrowserTypes.pas              # Tipos e enums comuns
  │   ├── EdgeWebBrowserForm.pas        # Implementação Edge
  │   ├── WebViewBrowserForm.pas        # Implementação WebView2
  │   ├── Edge/                         # Componentes específicos do Edge
  │   │   ├── Interfaces/
  │   │   │   ├── IEdgeWebBrowserForm.pas
  │   │   │   └── IEdgeWebBrowserFormBase.pas
  │   │   └── Component/
  │   │       ├── EdgeBrowserHelper.pas
  │   │       ├── EdgeCookie.pas
  │   │       ├── EdgeDeferral.pas
  │   │       ├── EdgeNewWindowRequestedEventArgs.pas
  │   │       └── EdgeWindowFeatures.pas
  │   └── WebView/                      # Componentes específicos do WebView
  │       ├── Interfaces/
  │       │   ├── IWebViewBrowserForm.pas
  │       │   └── IWebViewBrowserFormBase.pas
  │       └── Component/
  │
  ├── Strategy/                         # Padrão Strategy
  │   └── BrowserFactory.pas            # Factory e Strategy para criação
  │
  ├── Generic/                          # Utilitários genéricos
  │   ├── TimerHelper.pas               # Helper para timers
  │   └── UtilsLib.pas                  # Utilitários gerais
  │
  └── Example/                          # Exemplos de uso
      ├── EdgeWebAdvancedPopupExample.pas
      └── WebViewAdvancedPopupExample.pas
```

## 🔧 Tipos e Enums

### TBrowserType
```pascal
type
  TBrowserType = (EdgeBrowser, WebView2);
```

### TOpenType
```pascal
type
  TOpenType = (Default, Modal);
```

### TPositionCaption
```pascal
type
  TPositionCaption = (Before, After, Replaced, Between, None);
```

### TMDIOptions
```pascal
type
  TMDIOptions = record
    AutoShow: Boolean;
    SingleInstance: Boolean;
    MaximizeOnShow: Boolean;
    BringToFrontIfExists: Boolean;
    UniqueIdentifier: String;
    MaxInstances: Integer;
  end;
```

## 🔧 Requisitos

* Delphi 10.4+ (recomendado)
* VCL com suporte a `TBorderIcons`, `TPosition`, etc.
* WebView2 Runtime (para WebView2)
* Microsoft Edge WebView2 (para Edge)

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

Feito com 💻 por [Nickson Jeanmerson]