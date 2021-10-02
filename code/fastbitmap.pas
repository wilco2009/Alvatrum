unit fastbitmap;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
 TFastBitmapPixel = Integer;
 PFastBitmapPixel = ^TFastBitmapPixel;
  TFastBitmap = class
  private
    FPixelsData: PByte;
    FSize: TPoint;
    function GetPixel(X, Y: Integer): TFastBitmapPixel; inline;
    procedure SetPixel(X, Y: Integer; const AValue: TFastBitmapPixel); inline;
    procedure SetSize(const AValue: TPoint);
  public
    constructor Create;
    destructor Destroy; override;
    property Size: TPoint read FSize write SetSize;
    property Pixels[X, Y: Integer]: TFastBitmapPixel read GetPixel write SetPixel;
  end;

implementation

{ TFastBitmap }

function TFastBitmap.GetPixel(X, Y: Integer): TFastBitmapPixel;
begin
  Result := PFastBitmapPixel(FPixelsData + (Y * FSize.X + X) * SizeOf(TFastBitmapPixel))^;
end;

procedure TFastBitmap.SetPixel(X, Y: Integer; const AValue: TFastBitmapPixel);
begin
  PFastBitmapPixel(FPixelsData + (Y * FSize.X + X) * SizeOf(TFastBitmapPixel))^ := AValue;
end;

procedure TFastBitmap.SetSize(const AValue: TPoint);
begin
  if (FSize.X = AValue.X) and (FSize.Y = AValue.X) then
    Exit;
  FSize := AValue;
  FPixelsData := ReAllocMem(FPixelsData, FSize.X * FSize.Y * SizeOf(TFastBitmapPixel));
end;

constructor TFastBitmap.Create;
begin
  Size := Point(0, 0);
end;

destructor TFastBitmap.Destroy;
begin
  FreeMem(FPixelsData);
  inherited Destroy;
end;

end.

