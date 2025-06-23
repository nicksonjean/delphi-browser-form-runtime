unit TimerHelper;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, Vcl.ExtCtrls;

type
  TTimerHelper = class helper for TTimer
  private
    procedure SetOnInlineTimer(const AProc: TProc<TObject>);
    function GetOnInlineTimer: TProc<TObject>;
  public
    property OnInlineTimer: TProc<TObject> read GetOnInlineTimer write SetOnInlineTimer;
  end;

implementation

type
  TTimerEventProxy = class
  strict private
    class var FMap: TDictionary<TTimer, TProc<TObject>>;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure Assign(Timer: TTimer; Proc: TProc<TObject>);
    class function Get(Timer: TTimer): TProc<TObject>;
    class procedure Handler(Sender: TObject);
  end;

{ TTimerEventProxy }

class constructor TTimerEventProxy.Create;
begin
  FMap := TDictionary<TTimer, TProc<TObject>>.Create;
end;

class destructor TTimerEventProxy.Destroy;
begin
  FMap.Free;
end;

class procedure TTimerEventProxy.Assign(Timer: TTimer; Proc: TProc<TObject>);
begin
  FMap.Remove(Timer);
  if Assigned(Proc) then
  begin
    FMap.Add(Timer, Proc);
    Timer.OnTimer := Handler;
  end
  else
    Timer.OnTimer := nil;
end;

class function TTimerEventProxy.Get(Timer: TTimer): TProc<TObject>;
begin
  if not FMap.TryGetValue(Timer, Result) then
    Result := nil;
end;

class procedure TTimerEventProxy.Handler(Sender: TObject);
var
  Proc: TProc<TObject>;
begin
  if Sender is TTimer then
  begin
    Proc := Get(TTimer(Sender));
    if Assigned(Proc) then
      Proc(Sender);
  end;
end;

{ TTimerHelper }

function TTimerHelper.GetOnInlineTimer: TProc<TObject>;
begin
  Result := TTimerEventProxy.Get(Self);
end;

procedure TTimerHelper.SetOnInlineTimer(const AProc: TProc<TObject>);
begin
  TTimerEventProxy.Assign(Self, AProc);
end;

end.
