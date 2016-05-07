unit Forald_u;

interface

uses WinTypes, WinProcs, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, barn_u;

type
  TfMDIForalder = class(TForm)
    MainMenu1: TMainMenu;
    Panel1: TPanel;
    StatusLine: TPanel;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    Panel2: TPanel;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    SpeedPanel: TPanel;
    OpenBtn: TSpeedButton;
    SaveBtn: TSpeedButton;
    CutBtn: TSpeedButton;
    CopyBtn: TSpeedButton;
    PasteBtn: TSpeedButton;
    ExitBtn: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FileNewItemClick(Sender: TObject);
    procedure WindowCascadeItemClick(Sender: TObject);
    procedure UpdateMenuItems(Sender: TObject);
    procedure WindowTileItemClick(Sender: TObject);
    procedure WindowArrangeItemClick(Sender: TObject);
    procedure FileCloseItemClick(Sender: TObject);
    procedure FileOpenItemClick(Sender: TObject);
    procedure FileExitItemClick(Sender: TObject);
    procedure FileSaveItemClick(Sender: TObject);
    procedure FileSaveAsItemClick(Sender: TObject);
    procedure CutItemClick(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure PasteItemClick(Sender: TObject);
    procedure WindowMinimizeItemClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure CreateMDIChild(const Name: string);
    procedure ShowHint(Sender: TObject);
  public
    { Public declarations }
  end;

var
  fMDIForalder: TfMDIForalder;

implementation

{$R *.DFM}


procedure TfMDIForalder.FormCreate(Sender: TObject);
begin
  Application.OnHint := ShowHint;
  Screen.OnActiveFormChange := UpdateMenuItems;
end;

procedure TfMDIForalder.ShowHint(Sender: TObject);
begin
  StatusLine.Caption := Application.Hint;
end;

procedure TfMDIForalder.CreateMDIChild(const Name: string);
var
  fBitMap: TfBitMap;
begin
  { create a new MDI child window }
  fBitMap := TfBitMap.Create(Application);
  fBitMap.Caption := Name;
end;

procedure TfMDIForalder.FileNewItemClick(Sender: TObject);
begin
  CreateMDIChild('Bitmap' + IntToStr(MDIChildCount + 1));
end;

procedure TfMDIForalder.FileOpenItemClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    CreateMDIChild(OpenDialog.FileName);
end;

procedure TfMDIForalder.FileCloseItemClick(Sender: TObject);
begin
  if ActiveMDIChild <> nil then
    ActiveMDIChild.Close;
end;

procedure TfMDIForalder.FileSaveItemClick(Sender: TObject);
begin
  { save current file (ActiveMDIChild points to the window) }
end;

procedure TfMDIForalder.FileSaveAsItemClick(Sender: TObject);
begin
  { save current file under new name }
end;

procedure TfMDIForalder.FileExitItemClick(Sender: TObject);
begin
  Close;
end;

procedure TfMDIForalder.CutItemClick(Sender: TObject);
begin
  {cut selection to clipboard}
end;

procedure TfMDIForalder.CopyItemClick(Sender: TObject);
begin
  {copy selection to clipboard}
end;

procedure TfMDIForalder.PasteItemClick(Sender: TObject);
begin
  {paste from clipboard}
end;

procedure TfMDIForalder.WindowCascadeItemClick(Sender: TObject);
begin
  Cascade;
end;

procedure TfMDIForalder.WindowTileItemClick(Sender: TObject);
begin
  Tile;
end;

procedure TfMDIForalder.WindowArrangeItemClick(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TfMDIForalder.WindowMinimizeItemClick(Sender: TObject);
var
  I: Integer;
begin
  { Must be done backwards through the MDIChildren array }
  for I := MDIChildCount - 1 downto 0 do
    MDIChildren[I].WindowState := wsMinimized;
end;

procedure TfMDIForalder.UpdateMenuItems(Sender: TObject);
begin
  FileCloseItem.Enabled := MDIChildCount > 0;
  FileSaveItem.Enabled := MDIChildCount > 0;
  FileSaveAsItem.Enabled := MDIChildCount > 0;
  CutItem.Enabled := MDIChildCount > 0;
  CopyItem.Enabled := MDIChildCount > 0;
  PasteItem.Enabled := MDIChildCount > 0;
  SaveBtn.Enabled := MDIChildCount > 0;
  CutBtn.Enabled := MDIChildCount > 0;
  CopyBtn.Enabled := MDIChildCount > 0;
  PasteBtn.Enabled := MDIChildCount > 0;
  WindowCascadeItem.Enabled := MDIChildCount > 0;
  WindowTileItem.Enabled := MDIChildCount > 0;
  WindowArrangeItem.Enabled := MDIChildCount > 0;
  WindowMinimizeItem.Enabled := MDIChildCount > 0;
end;

procedure TfMDIForalder.FormDestroy(Sender: TObject);
begin
  Screen.OnActiveFormChange := nil;
end;

end.
