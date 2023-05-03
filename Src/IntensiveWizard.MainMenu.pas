{**********************************************************************************}
{ Criador: César Cardoso - Code4Delphi                                             }
{ Projeto criado durante palestra no Intensive Delphi 2023                         }
{ Tema: Criação de Wizards e Experts para o Delphi utilizando a OTA Open Tools API }
{                                                                                  }
{ https://github.com/Code4Delphi                                                   }
{ contato@code4delphi.com.br                                                       }
{ https://www.youtube.com/@code4delphi                                             }
{**********************************************************************************}

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

   if(FMainMenu = nil)then
     Exit;

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
var
 LIOTAProjectGroup: IOTAProjectGroup;
begin
   LIOTAProjectGroup := (BorlandIDEServices as IOTAModuleServices).MainProjectGroup;
   if(LIOTAProjectGroup = nil)then
     raise Exception.Create('Nenhum project group selecionado no momento');

   ShowMessage(LIOTAProjectGroup.FileName);
end;

procedure TIntensiveWizardMainMenu.ProjetoAtivoOnClick(Sender: TObject);
var
 LIOTAProject: IOTAProject;
begin
   LIOTAProject := GetActiveProject;
   if(LIOTAProject = nil)then
     raise Exception.Create('Nenhum projeto selecionado no momento');

   ShowMessage(LIOTAProject.FileName);
end;

procedure TIntensiveWizardMainMenu.UnitAtualOnClick(Sender: TObject);
var
 LIOTAModule: IOTAModule;
begin
   LIOTAModule := (BorlandIDEServices as IOTAModuleServices).CurrentModule;
   if(LIOTAModule = nil)then
     raise Exception.Create('Nenhuma unit selecionada no momento');

   ShowMessage(LIOTAModule.FileName);
end;

procedure TIntensiveWizardMainMenu.DocWikiClick(Sender: TObject);
const
 C_LINK = 'https://docwiki.embarcadero.com/RADStudio/Alexandria/e/index.php?search=';
var
 LTextoSelecionado: String;
 LIOTAEditView: IOTAEditView;
begin
   LIOTAEditView := (BorlandIDEServices as IOTAEditorServices).TopView;
   if(LIOTAEditView = nil)then
     raise Exception.Create('Não foi possível acessar o recurso para captura do texto selecionado');

   LTextoSelecionado := LIOTAEditView.GetBlock.Text;
   ShowMessage('Texto selecionado: ' + sLineBreak + LIOTAEditView.GetBlock.Text);
   ShellExecute(0, nil, PChar(C_LINK + LTextoSelecionado), '', '', SW_ShowNormal);
end;

procedure TIntensiveWizardMainMenu.BuildClick(Sender: TObject);
const
 C_NOME_PROJETO_WIZARD = 'IntensiveWizard';
var
 LIOTAProject: IOTAProject;
begin
   LIOTAProject := GetActiveProject;
   if(LIOTAProject = nil)then
     raise Exception.Create('Nenhum projeto selecionado no momento');

   if(ChangeFileExt(ExtractFileName(LIOTAProject.FileName), EmptyStr) = C_NOME_PROJETO_WIZARD)then
     raise Exception.Create('Não é possível realizar o build neste projeto: ' + C_NOME_PROJETO_WIZARD);

   LIOTAProject.ProjectBuilder.BuildProject(cmOTABuild, True, True);
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
