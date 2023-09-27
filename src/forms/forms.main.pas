unit Forms.Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, Menus, ActnList,
  ExtCtrls, ComCtrls, StdActns, StdCtrls, DBGrids, Buttons, RxDBGrid, rxmemds
;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actAccountsAddData: TAction;
    actAccountsClearData: TAction;
    actAccountsFilterClear: TAction;
    alMain: TActionList;
    actFileExit: TFileExit;
    btnAccaountsAddData: TButton;
    btnAccountsClearData: TButton;
    dsAccounts: TDataSource;
    edtAccountsFilterByAlias: TEdit;
    gbFilter: TGroupBox;
    gbInfo: TGroupBox;
    ilMain: TImageList;
    imgAccountsFilterClear: TImage;
    lblAccountsFilterByAlias: TLabel;
    mnuFile: TMenuItem;
    mnuFileExit: TMenuItem;
    mmMain: TMainMenu;
    panButtons: TPanel;
    rdgAccounts: TRxDBGrid;
    rmdAccounts: TRxMemoryData;
    rmdAccountsAlias: TStringField;
    rmdAccountsBalance: TCurrencyField;
    rmdAccountsHASH: TStringField;
    rmdAccountsLabel: TStringField;
    rmdAccountsPending: TCurrencyField;
    sbMain: TStatusBar;
    lblInfoColumns: TStaticText;
    lblInfoCopyCell: TStaticText;
    procedure actAccountsAddDataExecute(Sender: TObject);
    procedure actAccountsClearDataExecute(Sender: TObject);
    procedure actAccountsFilterClearExecute(Sender: TObject);
    procedure alMainUpdate(AAction: TBasicAction; var Handled: Boolean);
    procedure edtAccountsFilterByAliasChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rmdAccountsFilterRecord(DataSet: TDataSet; var Accept: Boolean);
  private
    procedure DisplayHint(Sender: TObject);
    procedure InitShortcuts;
  public

  end;

var
  frmMain: TfrmMain;

implementation

uses
  LCLType
;

const
  cVersion = '0.1.0';

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Caption:= Format('%s v%s', [ Application.Title, cVersion ]);
  Application.OnHint:= @DisplayHint;
  InitShortcuts;
  imgAccountsFilterClear.ImageIndex:= 0;
  rmdAccounts.Open;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  rmdAccounts.Close;
end;

procedure TfrmMain.DisplayHint(Sender: TObject);
begin
 sbMain.SimpleText:= GetShortHint(Application.Hint);
end;

procedure TfrmMain.InitShortcuts;
begin
{$IFDEF UNIX}
  actFileExit.ShortCut := KeyToShortCut(VK_Q, [ssCtrl]);
{$ENDIF}
{$IFDEF WINDOWS}
  actFileExit.ShortCut := KeyToShortCut(VK_X, [ssAlt]);
{$ENDIF}
end;

procedure TfrmMain.alMainUpdate(AAction: TBasicAction; var Handled: Boolean);
begin
  // Clear Data
  actAccountsClearData.Enabled:= rmdAccounts.RecordCount > 0;
  // Filter Clear
  edtAccountsFilterByAlias.Enabled := rmdAccounts.RecordCount > 0;
  actAccountsFilterClear.Enabled:= (Length(edtAccountsFilterByAlias.Text) > 0)
                               and (rmdAccounts.RecordCount > 0);
  imgAccountsFilterClear.Enabled:= actAccountsFilterClear.Enabled;
  case actAccountsFilterClear.Enabled of
    False: imgAccountsFilterClear.ImageIndex:= 0;
    True: imgAccountsFilterClear.ImageIndex:= 1;
  end;
  Handled:= True;
end;

procedure TfrmMain.actAccountsAddDataExecute(Sender: TObject);
begin
  actAccountsAddData.Enabled:= False;
  Application.ProcessMessages;

  rdgAccounts.BeginUpdate;

  rmdAccounts.Append;
  rmdAccounts.FieldByName('HASH').AsString:= 'N17231726371643';
  rmdAccounts.FieldByName('Alias').AsString:= 'Alias 1';
  rmdAccounts.FieldByName('Label').AsString:= 'Label 1';
  rmdAccounts.FieldByName('Pending').AsCurrency:= 0.036;
  rmdAccounts.FieldByName('Balance').AsCurrency:= 70000.158;
  rmdAccounts.Post;

  rmdAccounts.Append;
  rmdAccounts.FieldByName('HASH').AsString:= 'N69231726371643';
  rmdAccounts.FieldByName('Alias').AsString:= 'Alias 2';
  rmdAccounts.FieldByName('Label').AsString:= 'Label 2';
  rmdAccounts.FieldByName('Pending').AsCurrency:= 0.0;
  rmdAccounts.FieldByName('Balance').AsCurrency:= 1000.801;
  rmdAccounts.Post;

  rmdAccounts.Append;
  rmdAccounts.FieldByName('HASH').AsString:= 'N17231726371669';
  rmdAccounts.FieldByName('Alias').AsString:= 'Alias 3';
  rmdAccounts.FieldByName('Label').AsString:= 'Label 3';
  rmdAccounts.FieldByName('Pending').AsCurrency:= 10.0;
  rmdAccounts.FieldByName('Balance').AsCurrency:= 10.3215801;
  rmdAccounts.Post;

  rdgAccounts.AutoAdjustColumns;
  rdgAccounts.EndUpdate(True);

  Application.ProcessMessages;
  actAccountsAddData.Enabled:= True;
end;

procedure TfrmMain.actAccountsClearDataExecute(Sender: TObject);
begin
  actAccountsClearData.Enabled:= False;
  Application.ProcessMessages;

  rdgAccounts.BeginUpdate;

  rmdAccounts.CloseOpen;

  rdgAccounts.AutoAdjustColumns;
  rdgAccounts.EndUpdate(True);

  Application.ProcessMessages;
  actAccountsClearData.Enabled:= True;
end;

procedure TfrmMain.actAccountsFilterClearExecute(Sender: TObject);
begin
  if Length(edtAccountsFilterByAlias.Text) = 0 then exit;

  actAccountsFilterClear.Enabled:= False;
  Application.ProcessMessages;

  edtAccountsFilterByAlias.Clear;
  edtAccountsFilterByAlias.SetFocus;

  Application.ProcessMessages;
  actAccountsFilterClear.Enabled:= True;
end;

procedure TfrmMain.rmdAccountsFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  // This does the actual filtering by the Field below
  Accept := Pos(UpperCase(edtAccountsFilterByAlias.Text),
                UpperCase(DataSet.FieldByName('Alias').AsString)) > 0;
end;

procedure TfrmMain.edtAccountsFilterByAliasChange(Sender: TObject);
begin
  if rmdAccounts.RecordCount < 1 then exit;

  rdgAccounts.BeginUpdate;

  if Length(Trim(edtAccountsFilterByAlias.Text)) > 0 then
  begin
    rmdAccounts.FilterOptions:= [foCaseInsensitive];
    // Just need to provide the filter value
    rmdAccounts.Filter:= Format('Alias="*%s*"', [
      Trim(edtAccountsFilterByAlias.Text)
    ]);
    rmdAccounts.Filtered:= True;
  end
  else
  begin
    rmdAccounts.Filtered:= False;
  end;

  rdgAccounts.AutoAdjustColumns;
  rdgAccounts.EndUpdate(True);
end;

end.

