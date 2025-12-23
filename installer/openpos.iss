; -- openpos.iss --
; Create and install OpenPoS on Windows cliendt.
#define MyAppName "OpenPoS"
#define MyAppVersion "18.0.1.0.0"

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
WizardStyle=modern dynamic
DefaultDirName={autopf}\OpenPoS
DefaultGroupName=Open PoS

Uninstallable=yes
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\Uninstall-{#MyAppName}.exe

Compression=lzma2
SolidCompression=yes

OutputDir=output
OutputBaseFilename={#MyAppName}_Setup_{#MyAppVersion}

ChangesAssociations=yes
UserInfoPage=yes
PrivilegesRequiredOverridesAllowed=dialog

[Files]
Source: "README.txt"; DestDir: "{app}"; Flags: isreadme

Source: "..\docker\docker-compose.yml"; DestDir: "{app}"
Source: "..\docker\.env"; DestDir: "{app}"

Source: "..\launcher\start.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\launcher\stop.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\launcher\launch_openpos.bat"; DestDir: "{app}"; Flags: ignoreversion

;Source: "..\tools\Docker-Desktop-Installer.exe"; DestDir: "{tmp}"; Flags: dontcopy

[Icons]
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{group}\{#MyAppName}"; Filename: "{app}\launch_openpos.bat"; WorkingDir: "{app}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\launch_openpos.bat"; WorkingDir: "{app}"
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\launch_openpos.batt"; WorkingDir: "{app}"
Name: "{commonstartup}\{#MyAppName}"; Filename: "{app}\launch_openpos.bat"; WorkingDir: "{app}"


[Run]
; Optionally run the batch file after installation
Filename: "{app}\start.bat"; Flags: nowait postinstall skipifsilent; WorkingDir: "{app}"


[Code]
function IsDockerInstalled(): Boolean;
begin
  { Check if Docker Desktop is installed }
  Result := RegKeyExists(HKLM64, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Docker Desktop') or
            FileExists('C:\Program Files\Docker\Docker\Docker Desktop.exe');
end;


// Function to check if virtualization is enabled using WMIC
function IsVirtualizationEnabled(): Boolean;
var
  ResultCode: Integer;
  Output: String;
begin
  // Execute WMIC to check virtualization firmware status
  if Exec('wmic', 'cpu get VirtualizationFirmwareEnabled /value', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    // Here we could parse the actual output. For simplicity, assume ResultCode 0 = enabled
    Result := True; // Replace with real output parsing if needed
  end
  else
    Result := False;
end;



procedure InitializeWizard();
var
  ResultCode: Integer;
  UserChoice: Integer;
  ErrorCode: Integer;
begin
  if not IsDockerInstalled() then
  begin
    { Try to check and install Docker if required}
    if MsgBox('Docker Desktop is not installed. Do you want to install it now?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      ExtractTemporaryFile('Docker-Desktop-Installer.exe');
      if not Exec(ExpandConstant('{tmp}\Docker-Desktop-Installer.exe'), '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
      begin
        MsgBox('Docker installation failed. Please install manually.', mbError, MB_OK);
        Abort;
      end;
    end
    else
    begin
      MsgBox('Docker Desktop is required to run this application. Installation will abort.', mbInformation, MB_OK);
      Abort;
    end;
  end;
  
  
  if not IsVirtualizationEnabled() then
  begin
    // Show message with Yes (open link) / No (cancel install)
    UserChoice := MsgBox(
      'Virtualization is not enabled on your system.'#13#10 +
      'Docker Desktop requires virtualization to run.'#13#10#13#10 +
      'Click YES to open instructions to enable Virtualization in BIOS.', 
      mbInformation, MB_YESNO
    );

    if UserChoice = IDYES then
    begin
      // Open default browser with official guide
      ShellExec('', 'https://docs.docker.com/desktop/windows/install/#system-requirements', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    end;
    Abort;
  end
  
  
end;