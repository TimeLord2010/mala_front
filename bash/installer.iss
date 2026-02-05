; Inno Setup Script for Mala
; https://jrsoftware.org/isinfo.php

#define MyAppName "Mala"
#define MyAppVersion "1.4.1"
#define MyAppPublisher "VIT"
#define MyAppExeName "mala_front.exe"

[Setup]
; App identification
AppId={{8F3B4D2E-9A1C-4B5E-8D2F-7C6A9B4E1F3D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf64}\{#MyAppName}
DefaultGroupName={#MyAppName}
; 64-bit mode
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
; Output settings
OutputDir=.
OutputBaseFilename=Mala-Setup-{#MyAppVersion}
; Compression
Compression=lzma2
SolidCompression=yes
; UI settings
WizardStyle=modern
; Privileges
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
; Uninstall
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent
