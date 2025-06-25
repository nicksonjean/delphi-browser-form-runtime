unit EdgeDeferral;

interface

uses
  Vcl.ExtCtrls,
  Vcl.Edge,
  System.SysUtils;

type
  TEdgeDeferralCallback = reference to procedure;

  TEdgeDeferral = class
  private
    FCallback: TEdgeDeferralCallback;
    FCompleted: Boolean;
    FTimer: TTimer;
    FOwnsTimer: Boolean;
    FDestroying: Boolean;

    procedure OnTimerEvent(Sender: TObject);
    procedure CleanupTimer;
    procedure SafeExecuteCallback;
  public
    constructor Create(ACallback: TEdgeDeferralCallback);
    destructor Destroy; override;

    procedure Complete;
    procedure CompleteAfter(ADelayMS: Integer);

    property IsCompleted: Boolean read FCompleted;
  end;

implementation

constructor TEdgeDeferral.Create(ACallback: TEdgeDeferralCallback);
begin
  inherited Create;
  FCallback := ACallback;
  FCompleted := False;
  FTimer := nil;
  FOwnsTimer := False;
  FDestroying := False;
end;

destructor TEdgeDeferral.Destroy;
begin
  FDestroying := True;
  if not FCompleted then
  begin
    try
      Complete;
    except
    end;
  end;

  CleanupTimer;
  FCallback := nil;

  inherited;
end;

procedure TEdgeDeferral.CleanupTimer;
begin
  if Assigned(FTimer) and FOwnsTimer then
  begin
    try
      FTimer.Enabled := False;
      FTimer.OnTimer := nil;
      FreeAndNil(FTimer);
    except
      FTimer := nil;
    end;
    FOwnsTimer := False;
  end;
end;

procedure TEdgeDeferral.SafeExecuteCallback;
begin
  if Assigned(FCallback) and not FDestroying then
  begin
    try
      FCallback();
    except

    end;
  end;
end;

procedure TEdgeDeferral.Complete;
begin
  if not FCompleted and not FDestroying then
  begin
    FCompleted := True;
    CleanupTimer;
    SafeExecuteCallback;
    FCallback := nil;
  end;
end;

procedure TEdgeDeferral.OnTimerEvent(Sender: TObject);
begin
  if not FDestroying then
    Complete;
end;

procedure TEdgeDeferral.CompleteAfter(ADelayMS: Integer);
begin
  if not FCompleted and not FDestroying then
  begin
    CleanupTimer;

    try
      FTimer := TTimer.Create(nil);
      FTimer.Enabled := False;
      FTimer.OnTimer := OnTimerEvent;
      FTimer.Interval := ADelayMS;
      FOwnsTimer := True;
      FTimer.Enabled := True;
    except
      on E: Exception do
      begin
        CleanupTimer;
        Complete;
      end;
    end;
  end;
end;

end.
