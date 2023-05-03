unit IntensiveWizard.MainMenu;

interface

uses
  System.SysUtils,
  System.Classes,
  ToolsAPI,
  Vcl.Menus,
  Vcl.Dialogs,
  ShellAPI,
  WinAPI.Windows;

type
  TIntensiveWizardMainMenu = class(TNotifierObject, IOTAWizard)
  private
    FMainMenu: TMainMenu;
    FMenuItem: TMenuItem;
    procedure ProjetoAtivoOnClick(Sender: TObject);
    procedure AddSubMenus(const AName, ACaption: String; AClick: TNotifyEvent);
    procedure GrupoAtivoOnClick(Sender: TObject);
    procedure UnitAtualOnClick(Sender: TObject);
    procedure DocWikiClick(Sender: TObject);
    procedure BuildClick(Sender: TObject);
  protected
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
  public
    constructor Create;
    destructor Destroy; override;
  end;

procedure register;

implementation

procedure register;
begin
   (BorlandIDEServices as IOTAWizardServices).AddWizard(TIntensiveWizardMainMenu.Create);
end;

constructor TIntensiveWizardMainMenu.Create;
begin
   FMainMenu := (BorlandIDEServices as INTAServices).MainMenu;

   FMenuItem         := TMenuItem.Create(FMainMenu);
   FMenuItem.Name    := 'IntensiveWizardMenu1';
   FMenuItem.Caption := 'Intensive Delphi';
   FMainMenu.Items.Add(FMenuItem);

   Self.AddSubMenus('GrupoAtivo', 'Grupo Ativo', GrupoAtivoOnClick);
   Self.AddSubMenus('ProjetoAtivo', 'Projeto Ativo', ProjetoAtivoOnClick);
   Self.AddSubMenus('UnitAtual', 'Unit atual', UnitAtualOnClick);

   Self.AddSubMenus('DocWiki', 'DocWiki', DocWikiClick);

   Self.AddSubMenus('Build', 'Build projeto ativo', BuildClick);
end;

procedure TIntensiveWizardMainMenu.AddSubMenus(const AName, ACaption: String; AClick: TNotifyEvent);
var
 LMenuItem: TMenuItem;
begin
   LMenuItem         := TMenuItem.Create(FMenuItem);
   LMenuItem.Caption := ACaption;
   LMenuItem.Name    := 'IntensiveWizard' + AName;
   LMenuItem.OnClick := AClick;
   FMenuItem.Add(LMenuItem);
end;

procedure TIntensiveWizardMainMenu.GrupoAtivoOnClick(Sender: TObject);
begin
   ShowMessage((BorlandIDEServices as IOTAModuleServices).MainProjectGroup.FileName);
end;

procedure TIntensiveWizardMainMenu.ProjetoAtivoOnClick(Sender: TObject);
begin
   ShowMessage(GetActiveProject.FileName);
end;

procedure TIntensiveWizardMainMenu.UnitAtualOnClick(Sender: TObject);
begin
   ShowMessage((BorlandIDEServices as IOTAModuleServices).CurrentModule.FileName);
end;

procedure TIntensiveWizardMainMenu.DocWikiClick(Sender: TObject);
var
 LLink: String;
begin
   LLink := 'https://docwiki.embarcadero.com/RADStudio/Alexandria/e/index.php?search=' +
            (BorlandIDEServices as IOTAEditorServices).TopView.GetBlock.Text;

   ShowMessage('Texto selecionado: ' + sLineBreak + (BorlandIDEServices as IOTAEditorServices).TopView.GetBlock.Text);

   ShellExecute(0, nil, PChar(LLink), '', '', SW_ShowNormal);
end;

procedure TIntensiveWizardMainMenu.BuildClick(Sender: TObject);
begin
   GetActiveProject.ProjectBuilder.BuildProject(cmOTABuild, True, True);
end;

destructor TIntensiveWizardMainMenu.Destroy;
begin
   if(Assigned(FMenuItem))then
     FreeAndNil(FMenuItem);

   inherited;
end;

procedure TIntensiveWizardMainMenu.Execute;
begin

end;

function TIntensiveWizardMainMenu.GetIDString: string;
begin
   Result := Self.ClassName;
end;

function TIntensiveWizardMainMenu.GetName: string;
begin
   Result := Self.ClassName;
end;

function TIntensiveWizardMainMenu.GetState: TWizardState;
begin
   Result := [wsEnabled];
end;

end.
