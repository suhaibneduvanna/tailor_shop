[Setup]
AppName=Libasu Thaqva
AppVersion=1.0.0
AppVerName=Libasu Thaqva 1.0.0
AppPublisher=Libasu Thaqva
AppPublisherURL=https://yourwebsite.com
AppSupportURL=https://yourwebsite.com/support
AppUpdatesURL=https://yourwebsite.com/updates
DefaultDirName={autopf}\Libasu Thaqva
DefaultGroupName=Libasu Thaqva
AllowNoIcons=yes
LicenseFile=
OutputDir=installer
OutputBaseFilename=LibasuThaqva_Setup
SetupIconFile=assets\icons\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\Libasu Thaqva"; Filename: "{app}\libasu_thaqva.exe"
Name: "{group}\{cm:UninstallProgram,Libasu Thaqva}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Libasu Thaqva"; Filename: "{app}\libasu_thaqva.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\Libasu Thaqva"; Filename: "{app}\libasu_thaqva.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\libasu_thaqva.exe"; Description: "{cm:LaunchProgram,Libasu Thaqva}"; Flags: nowait postinstall skipifsilent

[Code]
function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
Begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
End;

function IsUpgrade(): Boolean;
Begin
  Result := (GetUninstallString() <> '');
End;

function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
Begin
  Result := 0;
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
End;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade()) then
    begin
      UnInstallOldVersion();
    end;
  end;
end;
