unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxTextEdit, cxMemo, IdHTTP, IdComponent, System.Generics.Collections, IdBaseComponent, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

type
  TMainFrm = class(TForm)
    Button1: TButton;
    Log: TcxMemo;
    ProgressBar1: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FListUrlDownload: TList<TPair<string, string>>;
    FListExec: TStringList;
    FFilePath: string;

    procedure DownloadFiles;
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);

    procedure ExecuteFiles;
    procedure DownloadFile(const URL, FileName: string);
  public
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;

implementation

uses
  System.IOUtils, Winapi.ShellAPI;

{$R *.dfm}

procedure TMainFrm.Button1Click(Sender: TObject);
begin
  Log.Lines.Add('Start process');
  DownloadFiles;
  Sleep(1000);
  ExecuteFiles;
  Log.Lines.Add('End process');
end;

procedure TMainFrm.IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  ProgressBar1.Max := AWorkCountMax;
  ProgressBar1.Position := 0;
end;

procedure TMainFrm.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  ProgressBar1.Position := AWorkCount;
end;

procedure TMainFrm.DownloadFiles;
var
  IdHTTP1: TIdHTTP;
  Stream: TMemoryStream;
  Url, FileName: String;
begin
  for var I := 0 to FListUrlDownload.Count - 1 do
  begin
    Log.Lines.Add('Downloading the ' + FListUrlDownload.Items[I].Key);
    Url := FListUrlDownload.Items[I].Value;
    FileName := FFilePath + FListUrlDownload.Items[I].Key;
    DownloadFile(Url, FileName);
    Log.Lines.Add('Downloaded the ' + FListUrlDownload.Items[I].Key);
  end;
end;

procedure TMainFrm.DownloadFile(const URL, FileName: string);
var
  HTTP: TIdHTTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  Stream: TMemoryStream;
  Redirect: Boolean;
  NewUrl: string;
begin
  if FileExists(FileName) then
    DeleteFile(FileName);

  NewUrl := URL;
  HTTP := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  Stream := TMemoryStream.Create;
  try
    // Configurar o manipulador SSL
    HTTP.IOHandler := SSLHandler;
    HTTP.OnWorkBegin := IdHTTPWorkBegin;
    HTTP.OnWork := IdHTTPWork;
    HTTP.ProtocolVersion := pv1_1;
    SSLHandler.SSLOptions.Method := sslvTLSv1_2;
    SSLHandler.SSLOptions.Mode := sslmClient;

    // Baixar o arquivo
    while Redirect do
    begin
      Redirect := False;

      try
        HTTP.Get(NewUrl, Stream);
      except
        on E: EIdHTTPProtocolException do
        begin
          if E.ErrorCode = 302 then
          begin
            Redirect := True;
            NewUrl := E.ErrorMessage;
          end
          else
            raise;
        end;
      end;
    end;

    Stream.SaveToFile(FileName);
  finally
    SSLHandler.Free;
    HTTP.Free;
    Stream.Free;
  end;
end;

procedure TMainFrm.ExecuteFiles;
begin
  for var I := 0 to FListExec.Count - 1 do
  begin
    Log.Lines.Add('Running the ' + FListExec[I]);
    ShellExecute(0, 'open', PWideChar(FFilePath + FListExec[I]), nil, nil, SW_SHOWNORMAL) ;
  end;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  FListUrlDownload := TList<TPair<string, string>>.Create;
  FListExec := TStringList.Create;

  //Path where save the file
  FFilePath := 'C:\TMP\teste\';
  if not System.IOUtils.TDirectory.Exists(FFilePath) then
    System.IOUtils.TDirectory.CreateDirectory(FFilePath);

  //List Url Download
  FListUrlDownload.Add(TPair<string, string>.Create('teste.exe', 'https://www.upload.ee/download/15269503/4bebf9233fea1cf6291d/HWMonitor_x64.exe'));

  //List exec
  FListExec.Add('teste.exe');
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  FListUrlDownload.Free;
  FListExec.Free;
end;

end.
