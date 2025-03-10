program wmf2png;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Windows, Interfaces, Classes, Graphics, SysUtils, fpvectorial,
  wmfvectorialreader, fpvectorialpkg, fpvtocanvas;

const PROG = 'wmf2png';
      VERSION = '1.0';

function Convert(InName, OutName: String): Integer;
var Img: TGraphic;
    Ext: String;
    Bmp: TBitmap;
    Vec: TvVectorialDocument;
begin
  Result := 0;

  try
    Vec := TvVectorialDocument.Create;
    Vec.ReadFromFile(InName, vfWindowsMetafileWMF);

    Bmp := TBitmap.Create;
    Bmp.SetSize(Round(Vec.Width), Round(Vec.Height));
    Bmp.PixelFormat := pf32bit;
    DrawFPVectorialToCanvas(Vec.GetPageAsVectorial(0), Bmp.Canvas, 0,0, 1, 1);
    Vec.Free;

  except
    Writeln('Conversion error');
    Exit(1);
  end;

  Ext := LowerCase(ExtractFileExt(OutName));

  if Ext = '.bmp' then Img := TBitmap.Create
  else if Ext = '.jpg' then Img := TJPEGImage.Create
  else if Ext = '.ppm' then Img := TPortableAnyMapGraphic.Create
  else if Ext = '.png' then Img := TPortableNetworkGraphic.Create;

  Img.Assign(Bmp);
  Bmp.Free;

  Img.SaveToFile(OutName);
  Img.Free;
end;

begin
  if (ParamCount <> 2) then begin
    Writeln('===================================================');
    Writeln('  ', PROG, ' - .WMF to .PNG image converter');
    Writeln('  github.com/Xelitan/', PROG);
    Writeln('  version: ', VERSION);
    Writeln('  license: MIT');
    Writeln('===================================================');
    Writeln('  Usage: ', PROG, ' INPUT OUTPUT');
    Writeln('  Output format is guessed from extension.');
    Writeln('  Supported: bmp,jpg,png,ppm');
    ExitCode := 0;
    Exit;
  end;

  ExitCode := Convert(ParamStr(1), ParamStr(2));
end.



