unit frmSetings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Spin;

type
  TForm2 = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    SpinEdit1: TSpinEdit;
    Bevel1: TBevel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure GetDevice;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

function capGetDriverDescriptionA(
    wDriverIndex        : UINT;
    lpszName            : LPSTR;
    cbName              : Integer;
    lpszVer             : LPSTR;
    cbVer               : Integer): BOOL;
    stdcall; external 'AVICAP32.DLL';
{$R *.dfm}

procedure TForm2.GetDevice;
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
   ComboBox1.Items.Add(pchar(@name));
   except
   end;
  end;
end;


procedure TForm2.FormCreate(Sender: TObject);
begin
GetDevice;
end;

end.
