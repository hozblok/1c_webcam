unit frmCapture;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ImgList, ToolWin, Menus, ExtCtrls, ShellAPI, Clipbrd,
  EncdDecd, XPMan, jpeg, StdCtrls;

type
  TForm1 = class(TForm)
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    Timer1: TTimer;
    XPManifest1: TXPManifest;
    cbb: TComboBox;
    lbl1: TLabel;
    N3: TMenuItem;
    procedure GetDevice;
    procedure FormCreate(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure cbbChange(Sender: TObject);
  private

  public
    procedure CreateHWND();

    { Public declarations }
  end;

var
  Form1: TForm1;
  PForm1 : ^TForm1;
  BString : String;

implementation

const
WM_CAP_START = WM_USER;
WM_CAP_STOP = WM_CAP_START + 68;
WM_CAP_DRIVER_CONNECT = WM_CAP_START + 10;
WM_CAP_DRIVER_DISCONNECT = WM_CAP_START + 11;
WM_CAP_SAVEDIB = WM_CAP_START + 25;
WM_CAP_GRAB_FRAME = WM_CAP_START + 60;
WM_CAP_SEQUENCE = WM_CAP_START + 62;
WM_CAP_FILE_SET_CAPTURE_FILEA = WM_CAP_START + 20;
WM_CAP_EDIT_COPY              = WM_CAP_START + 30;

WM_CAP_DLG_VIDEOFORMAT = WM_CAP_START + 41;
WM_CAP_DLG_VIDEOSOURCE = WM_CAP_START + 42;
WM_CAP_DLG_VIDEODISPLAY = WM_CAP_START + 43;

WM_CAP_GET_VIDEOFORMAT      = WM_CAP_START+ 44;
WM_CAP_SET_VIDEOFORMAT = WM_CAP_START + 45;
WM_CAP_SET_SCALE = WM_CAP_START + 53;
WM_CAP_SET_PREVIEW = WM_CAP_START + 50;
WM_CAP_SET_PREVIEWRATE = WM_CAP_START + 52;

function capGetDriverDescriptionA(
    wDriverIndex        : UINT;
    lpszName            : LPSTR;
    cbName              : Integer;
    lpszVer             : LPSTR;
    cbVer               : Integer): BOOL;
    stdcall; external 'AVICAP32.DLL';

function capCreateCaptureWindowA(lpszWindowName : PCHAR;
dwStyle : longint;
x : integer;
y : integer;
nWidth : integer;
nHeight : integer;
ParentWin : HWND;
nId : integer): HWND;
stdcall external 'AVICAP32.DLL';

var hWndC : THandle;
    B:TBitmap;
    Bt: BITMAPINFO;

{$R *.dfm}

procedure TForm1.GetDevice;
var
 index:UINT;
 SizeOfName, i:Integer;
 Name : ShortString;
 Ver  : ShortString;
 SizeOfVer:Integer;
begin
 for i:=0 to 9 do
  begin
   try
   if (capGetDriverDescriptionA(i, @name, SizeOf(name), @ver, SizeOf(ver)) = true) then
       cbb.Items.Add(pchar(@name));
   except
   end;
  end;
end;

procedure TForm1.CreateHWND;
var
  index : Integer;
begin
  index := cbb.ItemIndex;
  if(cbb.ItemIndex = -1) then
  begin
    index := 0;
  end;

  PForm1.Caption := 'Подключение веб камеры. Пожалуйста, подождите.';
  PForm1.Cursor := crHourGlass;
  hWndC := capCreateCaptureWindowA('My Own Capture Window',
  WS_CHILD or WS_VISIBLE ,
  0,
  22,
  Pform1^.Width,
  Pform1^.Height,
  Pform1^.Handle,
  index); //создаем область для вывода получаемых в будущем картинок =)

  if hWndC <> 0 then //если при создании области ошибок не возникло, то сопкойно начинаем забирать данный с веб-камеры
    begin
      SendMessage(hWndC, WM_CAP_DRIVER_CONNECT, 0, 0);  //забираем картинку с вебкамеры
      SendMessage(hWndC, WM_CAP_SET_SCALE, 1, 0);
      SendMessage(hWndC, WM_CAP_SET_PREVIEWRATE, 60, 0);
      SendMessage(hWndC, WM_CAP_SET_PREVIEW, 1, 0);
    end;
  PForm1.Cursor := crDefault;
  PForm1.Caption := 'Работа с веб камерой';
end;

procedure TForm1.N2Click(Sender: TObject);
begin
 if hWndC <> 0 then
  begin
    SendMessage(hWndC, WM_CAP_DRIVER_DISCONNECT, 0, 0);  //"отключаемся" от веб-камеры
    hWndC := 0;
  end;
PForm1.Close;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled :=False;
  CreateHWND;
end;

procedure TForm1.N1Click(Sender: TObject);
var
  B:TBitmap;
  J:TJPEGImage;
  Ss : TStringStream;
begin
  if hWndC <> 0 then begin
    if (SendMessage(hWndC, WM_CAP_EDIT_COPY, 0, 0) = 1) and (Clipboard.HasFormat(CF_BITMAP)) then
    begin
      B := TBitmap.Create;
      J := TJPEGImage.Create;
      B.Width := Pform1^.Width;
      B.Height := Pform1^.Height;
      B.PixelFormat := pf32bit;
      B.Assign(Clipboard);
      Ss := TStringStream.Create('');
      //B.SaveToStream(Ss);
      J.Assign(B);
      J.SaveToStream(SS);
      B.Free;
      Ss.Position := 0;
      BString := EncodeString(Ss.ReadString(Ss.Size));
      FreeAndNil(Ss);
    end;
    PForm1.Close;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GetDevice;
end;

procedure TForm1.cbbChange(Sender: TObject);
begin
  if hWndC <> 0 then
  begin
    SendMessage(hWndC, WM_CAP_DRIVER_DISCONNECT, 0, 0);  //"отключаемся" от веб-камеры
    hWndC := 0;
  end;

  CreateHWND; //подключаемся

  //SendMessage(hWndC, WM_CAP_DLG_VIDEOFORMAT, 0, 0);
  SendMessage(hWndC, WM_CAP_DLG_VIDEOSOURCE, 0, 0); //запрашиваем настройки
  //SendMessage(hWndC, WM_CAP_DLG_VIDEODISPLAY, 0, 0);
end;

end.
