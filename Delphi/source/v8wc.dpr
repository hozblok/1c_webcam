library v8wc;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  v8napi,
  Windows,
  Graphics,
  Classes,
  EncdDecd,
  Forms,
  Dialogs,
  frmCapture in 'frmCapture.pas' {Form1},
  frmSetings in 'frmSetings.pas' {Form2};

type
  TMyClass = class(TV8UserObject)
  private
    Form1: TForm1;
    Form2: TForm2;
    FPropetyBMP: String;
    FBMP : TBitmap;

  public

    function GetBMP(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): boolean;
    function ShowSetings(RetValue: PV8Variant; Params: PV8ParamArray; const ParamCount: integer; var v8:TV8AddInDefBase): boolean;

    function PropetyBMPGetSet(propValue: PV8Variant; Get: boolean; var v8:TV8AddInDefBase): boolean;

    constructor Create; override;
  end;


{$R *.res}

{ TMyClass }

constructor TMyClass.Create;
begin
  inherited;

end;

function TMyClass.GetBMP(RetValue: PV8Variant; Params: PV8ParamArray;
  const ParamCount: integer; var v8: TV8AddInDefBase): boolean;
  var
  n: integer;
begin
   n:= V8AsInt(@Params[1]);
   Form1 := TForm1.Create(Application);
   frmCapture.PForm1 := @Form1;
   Form1.ShowModal;
   if Length(frmCapture.BString) > 0 Then
   V8SetString(RetValue, frmCapture.BString);

   Form1.Free;
   Result:= True;
end;

function TMyClass.PropetyBMPGetSet(propValue: PV8Variant; Get: boolean;
  var v8: TV8AddInDefBase): boolean;
begin

end;


function TMyClass.ShowSetings(RetValue: PV8Variant; Params: PV8ParamArray;
  const ParamCount: integer; var v8: TV8AddInDefBase): boolean;
begin
  //ничего не делаем, временно отключаем функционал
   //Form2 := TForm2.Create(Application);
   //Form2.ShowModal;
   //Form1.Free;
   //Result:= True;
end;

begin
  with ClassRegList.RegisterClass(TMyClass, 'ExecExtention', 'TMyClass') do
  begin
    AddFunc('GetBMP', 'ПолучитьБМП', @TMyClass.GetBMP, 1);
    AddFunc('ShowSet', 'ПоказатьНастройки', @TMyClass.ShowSetings, 1);

    AddProp('BMP','БМП',True,True, @TMyClass.PropetyBMPGetSet);

  end;
end.
