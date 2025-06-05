unit UnitFilho;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormFilho = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormFilho: TFormFilho;

implementation

{$R *.dfm}

procedure TFormFilho.FormCreate(Sender: TObject);
begin
  // Configura o form como MDI Child
  FormStyle := fsMDIChild;
  
  // Atualiza o label com informações do formulário
  Label1.Caption := 'Esta é uma janela filha MDI - ' + Self.Caption;
  
  // Adiciona texto inicial no memo
  Memo1.Lines.Clear;
  Memo1.Lines.Add('Esta é uma janela filha MDI.');
  Memo1.Lines.Add('Você pode digitar texto aqui...');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Use o menu Janela para organizar as janelas abertas.');
end;

procedure TFormFilho.Button1Click(Sender: TObject);
begin
  // Adiciona uma linha com data/hora atual
  Memo1.Lines.Add('Botão clicado em: ' + DateTimeToStr(Now));
end;

procedure TFormFilho.Button2Click(Sender: TObject);
begin
  // Limpa o conteúdo do memo
  Memo1.Lines.Clear;
  Memo1.Lines.Add('Memo limpo em: ' + DateTimeToStr(Now));
end;

end.