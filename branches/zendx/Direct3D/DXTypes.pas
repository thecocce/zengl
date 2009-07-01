unit DXTypes;

interface

uses Windows;

type
  // TD3DValue is the fundamental Direct3D fractional data type
  D3DVALUE = Single;
  TD3DValue = D3DVALUE;
  PD3DValue = ^TD3DValue;

  D3DCOLOR = {$IFDEF TYPE_IDENTITY}type {$ENDIF}DWord;
  TD3DColor = D3DCOLOR;
  PD3DColor = ^TD3DColor;
  {$NODEFINE D3DCOLOR}
  {$NODEFINE TD3DColor}
  {$NODEFINE PD3DColor}

  _D3DVECTOR = packed record
    x: Single;
    y: Single;
    z: Single;
  end {_D3DVECTOR};
  D3DVECTOR = _D3DVECTOR;
  TD3DVector = _D3DVECTOR;
  PD3DVector = ^TD3DVector;
  {$NODEFINE _D3DVECTOR}
  {$NODEFINE D3DVECTOR}
  {$NODEFINE TD3DVector}
  {$NODEFINE PD3DVector}

implementation

end.

