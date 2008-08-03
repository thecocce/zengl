{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru.2x4.ru
 *
 * This library is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
}
unit zgl_math;

{$I define.inc}

interface
uses
  zgl_const,
  zgl_types;
  
function m_Round( value : Single ) : Integer; extdecl;

procedure InitCosSinTables;
function m_Cos( Angle : Integer ) : Single; extdecl;
function m_Sin( Angle : Integer ) : Single; extdecl;

function m_Distance( x1, y1, x2, y2 : Single ) : Single; extdecl;
function m_FDistance( x1, y1, x2, y2 : Single ) : Single; extdecl;

{------------------------------------------------------------------------------}
{--------------------------------- Vectors ------------------------------------}
{------------------------------------------------------------------------------}
function vector_Get( x, y, z : Single ) : zglTPoint3D; //assembler;

function vector_Add( Vector1, Vector2 : zglTPoint3D ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_Sub( Vector1, Vector2 : zglTPoint3D ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_Mul( Vector1, Vector2 : zglTPoint3D ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_Div( Vector1, Vector2 : zglTPoint3D ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}

function vector_AddV( Vector : zglTPoint3D; Value : Single ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_SubV( Vector : zglTPoint3D; Value : Single ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_MulV( Vector : zglTPoint3D; Value : Single ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_DivV( Vector : zglTPoint3D; Value : Single ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}

function vector_MulM3f( Vector : zglTPoint3D; Matrix : zglPMatrix3f ) : zglTPoint3D;

function vector_Negate( Vector : zglTPoint3D ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_Normalize( Vector : zglTPoint3D ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_Angle( Vector1, Vector2 : zglTPoint3D ) : Single;
function vector_Cross( Vector1, Vector2 : zglTPoint3D ) : zglTPoint3D; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_Dot( Vector1, Vector2 : zglTPoint3D ) : Single; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_Distance( Vector1, Vector2 : zglTPoint3D ) : Single; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_FDistance( Vector1, Vector2 : zglTPoint3D ) : Single; {$IFDEF USE_ASM} assembler; {$ENDIF}
function vector_Length( Vector : zglTPoint3D ) : Single; {$IFDEF USE_ASM} assembler; {$ENDIF}

{------------------------------------------------------------------------------}
{--------------------------------- Matrix3f -----------------------------------}
{------------------------------------------------------------------------------}
function matrix3f_Get( v1, v2, v3 : zglTPoint3D ) : zglTMatrix3f;

procedure matrix3f_Identity( Matrix : zglPMatrix3f );
procedure matrix3f_OrthoNormalize( Matrix : zglPMatrix3f );
procedure matrix3f_Transpose( Matrix : zglPMatrix3f );
procedure matrix3f_RotateRad( Matrix : zglPMatrix3f; aX, aY, aZ : Single );
procedure matrix3f_RotateDeg( Matrix : zglPMatrix3f; aX, aY, aZ : Single );

procedure matrix3f_Add( Matrix1, Matrix2 : zglPMatrix3f );
procedure matrix3f_Mul( Matrix1, Matrix2 : zglPMatrix3f );

function line3d_ClosestPoint( A, B, Point : zglTPoint3D ) : zglTPoint3D;

function plane_Get( A, B, C : zglTPoint3D ) : zglTPlane;
function plane_Distance( Plane : zglPPlane; Point : zglTPoint3D ) : Single;

function tri_GetNormal( A, B, C : zglPPoint3D ) : zglTPoint3D;

function ArcTan2( X, Y : Single ) : Single; assembler;
function ArcCos( Value : Single ) : Single;

var
  CosTable : array[ 0..360 ] of Single;
  SinTable : array[ 0..360 ] of Single;

implementation

function m_Round;
{$IFNDEF USE_ASM}
begin
  Result := Round( value );
{$ELSE}
asm
  FLD   value
  FISTP DWORD PTR [ value ]
  MOV   EAX,      [ value ]
{$ENDIF}
end;

procedure InitCosSinTables;
  var
    i         : Integer;
    rad_angle : Single;
begin
  for i := 0 to 360 do
    begin
      rad_angle := i * ( cv_pi / 180 );
      CosTable[ i ] := cos( rad_angle );
      SinTable[ i ] := sin( rad_angle );
    end;
end;

function m_Cos;
begin
  while Angle > 360 do Angle := Angle - 360;
  while Angle < 0   do Angle := Angle + 360;
  if Angle > 0 Then
    Result := CosTable[ Angle ]
  else
    Result := CosTable[ 360 - Angle ]
end;

function m_Sin;
begin
  while Angle > 360 do Angle := Angle - 360;
  while Angle < 0   do Angle := Angle + 360;
  if Angle > 0 Then
    Result := SinTable[ Angle ]
  else
    Result := SinTable[ 360 - Angle ]
end;

function m_Distance;
begin
  Result := Sqrt( ( X1 - X2 ) * ( X1 - X2 ) + ( Y1 - Y2 ) * ( Y1 - Y2 ) );
end;

function m_FDistance;
begin
  Result := ( X1 - X2 ) * ( X1 - X2 ) + ( Y1 - Y2 ) * ( Y1 - Y2 );
end;

function ArcTan2;
asm
  FLD    X
  FLD    Y
  FPATAN
  FWAIT
end;

function ArcCos;
begin
  if 1 - sqr( Value ) <= 0 Then
    Result := -1
  else
    Result := ArcTan2( sqrt( 1 - sqr( Value ) ), Value );
end;

{------------------------------------------------------------------------------}
{--------------------------------- Vectors ------------------------------------}
{------------------------------------------------------------------------------}
function vector_Get;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

function vector_Add;
{$IFNDEF USE_ASM}
begin
  Result.X := Vector1.X + Vector2.X;
  Result.Y := Vector1.Y + Vector2.Y;
  Result.Z := Vector1.Z + Vector2.Z;
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ]
  FADD DWORD PTR [ EDX     ]
  FSTP DWORD PTR [ ECX     ]

  FLD  DWORD PTR [ EAX + 4 ]
  FADD DWORD PTR [ EDX + 4 ]
  FSTP DWORD PTR [ ECX + 4 ]

  FLD  DWORD PTR [ EAX + 8 ]
  FADD DWORD PTR [ EDX + 8 ]
  FSTP DWORD PTR [ ECX + 8 ]
{$ENDIF}
end;


function vector_Sub;
{$IFNDEF USE_ASM}
begin
  Result.X := Vector1.X - Vector2.X;
  Result.Y := Vector1.Y - Vector2.Y;
  Result.Z := Vector1.Z - Vector2.Z;
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ]
  FSUB DWORD PTR [ EDX     ]
  FSTP DWORD PTR [ ECX     ]

  FLD  DWORD PTR [ EAX + 4 ]
  FSUB DWORD PTR [ EDX + 4 ]
  FSTP DWORD PTR [ ECX + 4 ]

  FLD  DWORD PTR [ EAX + 8 ]
  FSUB DWORD PTR [ EDX + 8 ]
  FSTP DWORD PTR [ ECX + 8 ]
{$ENDIF}
end;

function vector_Mul;
{$IFNDEF USE_ASM}
begin
  Result.X := Vector1.X * Vector2.X;
  Result.Y := Vector1.Y * Vector2.Y;
  Result.Z := Vector1.Z * Vector2.Z;
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ]
  FMUL DWORD PTR [ EDX     ]
  FSTP DWORD PTR [ ECX     ]

  FLD  DWORD PTR [ EAX + 4 ]
  FMUL DWORD PTR [ EDX + 4 ]
  FSTP DWORD PTR [ ECX + 4 ]

  FLD  DWORD PTR [ EAX + 8 ]
  FMUL DWORD PTR [ EDX + 8 ]
  FSTP DWORD PTR [ ECX + 8 ]
{$ENDIF}
end;

function vector_Div;
{$IFNDEF USE_ASM}
begin
  Result.X := Vector1.X / Vector2.X;
  Result.Y := Vector1.Y / Vector2.Y;
  Result.Z := Vector1.Z / Vector2.Z;
{$ELSE}
asm
  mov [ EAX     ], 0
  mov [ EAX + 4 ], 0
  mov [ EAX + 8 ], 0
  
@@1:
  cmp [ EDX     ], 0
  jz  @@2
  
  FLD  DWORD PTR [ EAX     ]
  FDIV DWORD PTR [ EDX     ]
  FSTP DWORD PTR [ ECX     ]
  
@@2:
  cmp [ EDX + 4 ], 0
  jz  @@3
  
  FLD  DWORD PTR [ EAX + 4 ]
  FDIV DWORD PTR [ EDX + 4 ]
  FSTP DWORD PTR [ ECX + 4 ]
  
@@3:
  cmp [ EDX + 8 ], 0
  jz  @@4
  
  FLD  DWORD PTR [ EAX + 8 ]
  FDIV DWORD PTR [ EDX + 8 ]
  FSTP DWORD PTR [ ECX + 8 ]
  
@@4:
{$ENDIF}
end;

function vector_AddV;
{$IFNDEF USE_ASM}
begin
  Result.X := Vector.X + Value;
  Result.Y := Vector.Y + Value;
  Result.Z := Vector.Z + Value;
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ]
  FADD DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX     ]

  FLD  DWORD PTR [ EAX + 4 ]
  FADD DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX + 4 ]

  FLD  DWORD PTR [ EAX + 8 ]
  FADD DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX + 8 ]
{$ENDIF}
end;

function vector_SubV;
{$IFNDEF USE_ASM}
begin
  Result.X := Vector.X - Value;
  Result.Y := Vector.Y - Value;
  Result.Z := Vector.Z - Value;
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ]
  FSUB DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX     ]

  FLD  DWORD PTR [ EAX + 4 ]
  FSUB DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX + 4 ]

  FLD  DWORD PTR [ EAX + 8 ]
  FSUB DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX + 8 ]
{$ENDIF}
end;

function vector_MulV;
{$IFNDEF USE_ASM}
begin
  Result.X := Vector.X * Value;
  Result.Y := Vector.Y * Value;
  Result.Z := Vector.Z * Value;
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ]
  FMUL DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX     ]

  FLD  DWORD PTR [ EAX + 4 ]
  FMUL DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX + 4 ]

  FLD  DWORD PTR [ EAX + 8 ]
  FMUL DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX + 8 ]
{$ENDIF}
end;

function vector_DivV;
{$IFNDEF USE_ASM}
begin
  Value := 1 / Value;
  Result.X := Vector.X * Value;
  Result.Y := Vector.Y * Value;
  Result.Z := Vector.Z * Value;
{$ELSE}
asm
  mov [ EDX     ], 0
  mov [ EDX + 4 ], 0
  mov [ EDX + 8 ], 0

  cmp [ EBP + 8 ], 0
  jz  @@1

  FLD  DWORD PTR [ EAX     ]
  FDIV DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX     ]

  FLD  DWORD PTR [ EAX + 4 ]
  FDIV DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX + 4 ]

  FLD  DWORD PTR [ EAX + 8 ]
  FDIV DWORD PTR [ EBP + 8 ]
  FSTP DWORD PTR [ EDX + 8 ]

@@1:
{$ENDIF}
end;

function vector_MulM3f;
begin
  Result.X := Matrix[ 0 ].X * Vector.X + Matrix[ 1 ].X * Vector.Y + Matrix[ 2 ].X * Vector.Z;
  Result.Y := Matrix[ 0 ].Y * Vector.X + Matrix[ 1 ].Y * Vector.Y + Matrix[ 2 ].Y * Vector.Z;
  Result.Z := Matrix[ 0 ].Z * Vector.X + Matrix[ 1 ].Z * Vector.Y + Matrix[ 2 ].Z * Vector.Z;
end;

function vector_Negate;
{$IFNDEF USE_ASM}
begin
  Result.X := -Result.X;
  Result.Y := -Result.Y;
  Result.Z := -Result.Z
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ]
  FCHS
  FSTP DWORD PTR [ EDX     ]

  FLD  DWORD PTR [ EAX + 4 ]
  FCHS
  FSTP DWORD PTR [ EDX + 4 ]

  FLD  DWORD PTR [ EAX + 8 ]
  FCHS
  FSTP DWORD PTR [ EDX + 8 ]
{$ENDIF}
end;

function vector_Normalize;
{$IFNDEF USE_ASM}
  var
    len : Single;
begin
  len := 1 / Sqrt( sqr( Vector.X ) + sqr( Vector.Y ) + sqr( Vector.Z ) );
  Result.X := Vector.X * len;
  Result.Y := Vector.Y * len;
  Result.Z := Vector.Z * len;
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ]
  FMUL ST, ST
  FLD  DWORD PTR [ EAX + 4 ]
  
  FMUL ST, ST
  FADD
  FLD  DWORD PTR [ EAX + 8 ]
  
  FMUL ST, ST
  FADD
  
  FSQRT
  FLD1
  FDIVR

  FLD  ST
  FMUL DWORD PTR [ EAX     ]
  FSTP DWORD PTR [ EDX     ]
  
  FLD  ST
  FMUL DWORD PTR [ EAX + 4 ]
  FSTP DWORD PTR [ EDX + 4 ]

  FMUL DWORD PTR [ EAX + 8 ]
  FSTP DWORD PTR [ EDX + 8 ]
{$ENDIF}
end;

function vector_Angle;
begin
  Result := ArcCos( vector_Dot( vector_Normalize( Vector1 ), vector_Normalize( Vector2 ) ) );
end;

function vector_Cross;
{$IFNDEF USE_ASM}
begin
  Result.X := Vector1.Y * Vector2.Z - Vector1.Z * Vector2.Y;
  Result.Y := Vector1.Z * Vector2.X - Vector1.X * Vector2.Z;
  Result.Z := Vector1.X * Vector2.Y - Vector1.Y * Vector2.X;
{$ELSE}
asm
  FLD DWORD PTR [ EDX + 8 ] // Vector2.Z
  FLD DWORD PTR [ EDX + 4 ] // Vector2.Y
  FLD DWORD PTR [ EDX     ] // Vector2.X
  FLD DWORD PTR [ EAX + 8 ] // Vector1.Z
  FLD DWORD PTR [ EAX + 4 ] // Vector1.Y
  FLD DWORD PTR [ EAX     ] // Vector1.X

  FLD   ST(1)               // ST(0)    := Vector1.Y
  FMUL  ST, ST(6)           // ST(0)    := Vector1.Y * Vector2.Z

  FLD   ST(3)               // ST(0)    := Vector1.Z
  FMUL  ST, ST(6)           // ST(0)    := Vector1.Z * Vector2.Y
  
  FSUBP ST(1), ST           // ST(0)    := ST(1) - ST(0)
  
  FSTP  DWORD [ ECX     ]   // Result.X := ST(0)

  FLD   ST(2)               // ST(0)    := Vector1.Z
  FMUL  ST, ST(4)           // ST(0)    := Vector1.Z * Vector2.X
  
  FLD   ST(1)               // ST(0)    := Vector1.X
  FMUL  ST, ST(7)           // ST(0)    := Vector1.X * Vector2.Z
  
  FSUBP ST(1), ST           // ST(0)    := ST(1) - ST(0)

  FSTP  DWORD [ ECX + 4 ]   // Result.Y := ST(0)

  FLD   ST                  // ST(0)    := Vector1.X
  FMUL  ST, ST(5)           // ST(0)    := Vector1.X * Vector2.Y
  
  FLD   ST(2)               // ST(0)    := Vector1.Y
  FMUL  ST, ST(5)           // ST(0)    := Vector1.Y * Vector2.X
  
  FSUBP ST(1), ST           // ST(0)    := ST(1) - ST(0)
  
  FSTP  DWORD [ ECX + 8 ]   // Result.Z := ST(0)

  // очистка fpu-стека
  FSTP ST(0)
  FSTP ST(0)
  FSTP ST(0)
  FSTP ST(0)
  FSTP ST(0)
  FSTP ST(0)
{$ENDIF}
end;

function vector_Dot;
{$IFNDEF USE_ASM}
begin
  Result := Vector1.X * Vector2.X + Vector1.Y + Vector2.Y + Vector1.Z * Vector2.Z;
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ] // Vector1.X
  FMUL DWORD PTR [ EDX     ] // Vector1.X * Vector2.X
  
  FLD  DWORD PTR [ EAX + 4 ] // Vector1.Y
  FMUL DWORD PTR [ EDX + 4 ] // Vector1.X * Vector2.X
  
  FADDP                      // Result := Vector1.X * Vector2.X + Vector1.X * Vector2.X
  
  FLD  DWORD PTR [ EAX + 8 ] // Vector1.Z
  FMUL DWORD PTR [ EDX + 8 ] // Vector1.Z * Vector2.Z
  
  FADDP                      // Result := Result + Vector1.Z * Vector2.Z
{$ENDIF}
end;

function vector_Distance;
{$IFNDEF USE_ASM}
begin
  Result := sqrt( sqr( Vector2.X - Vector1.X ) +
                  sqr( Vector2.Y - Vector1.Y ) +
                  sqr( Vector2.Z - Vector1.Z ) );
{$ELSE}
asm
  FLD  DWORD PTR [ EDX     ] // Vector1.X
  FSUB DWORD PTR [ EAX     ] // Vector2.X - Vector1.X
  FMUL ST, ST                // sqr( Vector2.X - Vector1.X )
  
  FLD  DWORD PTR [ EDX + 4 ] // Vector2.Y
  FSUB DWORD PTR [ EAX + 4 ] // Vector2.Y - Vector1.Y
  FMUL ST, ST                // sqr( Vector2.Y - Vector1.Y )
  
  FADDP                      // Result := sqr( Vector2.X - Vector1.X ) + sqr( Vector2.Y - Vector1.Y )
  
  FLD  DWORD PTR [ EDX + 8 ] // Vector2.Z
  FSUB DWORD PTR [ EAX + 8 ] // Vector2.Z - Vector1.Z
  FMUL ST, ST                // sqr( Vector2.Z - Vector1.Z )
  
  FADDP                      // Result := Result + sqr( Vector2.Z - Vector1.Z )
  
  FSQRT                      // Result := sqrt( Result )
{$ENDIF}
end;

function vector_FDistance;
{$IFNDEF USE_ASM}
begin
  Result := sqr( Vector2.X - Vector1.X ) +
            sqr( Vector2.Y - Vector1.Y ) +
            sqr( Vector2.Z - Vector1.Z );
{$ELSE}
asm
  FLD  DWORD PTR [ EDX     ] // Vector1.X
  FSUB DWORD PTR [ EAX     ] // Vector2.X - Vector1.X
  FMUL ST, ST                // sqr( Vector2.X - Vector1.X )

  FLD  DWORD PTR [ EDX + 4 ] // Vector2.Y
  FSUB DWORD PTR [ EAX + 4 ] // Vector2.Y - Vector1.Y
  FMUL ST, ST                // sqr( Vector2.Y - Vector1.Y )

  FADDP                      // Result := sqr( Vector2.X - Vector1.X ) + sqr( Vector2.Y - Vector1.Y )

  FLD  DWORD PTR [ EDX + 8 ] // Vector2.Z
  FSUB DWORD PTR [ EAX + 8 ] // Vector2.Z - Vector1.Z
  FMUL ST, ST                // sqr( Vector2.Z - Vector1.Z )

  FADDP                      // Result := Result + sqr( Vector2.Z - Vector1.Z )
{$ENDIF}
end;

function vector_Length;
{$IFNDEF USE_ASM}
begin
  Result := sqrt( sqr( Vector.X ) + sqr( Vector.Y ) + sqr( Vector.Z ) );
{$ELSE}
asm
  FLD  DWORD PTR [ EAX     ] // Vector.X
  FMUL ST, ST                // sqr( Vector.X )

  FLD  DWORD PTR [ EAX + 4 ] // Vector.Y
  FMUL ST, ST                // sqr( Vector.Y )

  FADDP                      // Result := sqr( Vector.X ) + sqr( Vector.Y )

  FLD  DWORD PTR [ EAX + 8 ] // Vector.Z
  FMUL ST, ST                // sqr( Vector.Z )

  FADDP                      // Result := Result + sqr( Vector.Z )

  FSQRT                      // Result := sqrt( Result )
{$ENDIF}
end;

{------------------------------------------------------------------------------}
{--------------------------------- Matrix3f -----------------------------------}
{------------------------------------------------------------------------------}
function matrix3f_Get;
begin
  Result[ 0 ] := v1;
  Result[ 1 ] := v2;
  Result[ 2 ] := v3;
end;

procedure matrix3f_Identity;
begin
  Matrix[ 0 ] := vector_Get( 1, 0, 0 );
  Matrix[ 1 ] := vector_Get( 0, 1, 0 );
  Matrix[ 2 ] := vector_Get( 0, 0, 1 );
end;

procedure matrix3f_OrthoNormalize;
begin
  Matrix[ 0 ] := vector_Normalize( Matrix[ 0 ] );
  Matrix[ 2 ] := vector_Normalize( vector_Cross( Matrix[ 0 ], Matrix[ 1 ] ) );
  Matrix[ 1 ] := vector_Normalize( vector_Cross( Matrix[ 2 ], Matrix[ 0 ] ) );
end;

procedure matrix3f_Transpose;
begin
  Matrix[ 0 ] := vector_Get( Matrix[ 0 ].x, Matrix[ 1 ].x, Matrix[ 2 ].x );
  Matrix[ 1 ] := vector_Get( Matrix[ 0 ].y, Matrix[ 1 ].y, Matrix[ 2 ].y );
  Matrix[ 2 ] := vector_Get( Matrix[ 0 ].z, Matrix[ 1 ].z, Matrix[ 2 ].z );
end;

procedure matrix3f_RotateRad;
  var
    tMatrix : zglTMatrix3f;
begin
  tMatrix[ 0 ] := vector_Get(   0, -aZ,  aY );
  tMatrix[ 1 ] := vector_Get(  aZ,   0, -aX );
  tMatrix[ 2 ] := vector_Get( -aY,  aX,   0 );
  matrix3f_Mul( @tMatrix, @Matrix );
  matrix3f_Add( @Matrix, @tMatrix );
  matrix3f_OrthoNormalize( @Matrix );
end;

procedure matrix3f_RotateDeg;
  var
    tMatrix : zglTMatrix3f;
begin
  tMatrix[ 0 ] := vector_Get(              0, -aZ * cv_pi180,  aY * cv_pi180 );
  tMatrix[ 1 ] := vector_Get(  aZ * cv_pi180,              0, -aX * cv_pi180 );
  tMatrix[ 2 ] := vector_Get( -aY * cv_pi180,  aX * cv_pi180,              0 );
  matrix3f_Mul( @tMatrix, @Matrix );
  matrix3f_Add( @Matrix, @tMatrix );
  matrix3f_OrthoNormalize( @Matrix );
end;

procedure matrix3f_Add;
begin
  Matrix1[ 0 ] := vector_Add( Matrix1[ 0 ], Matrix2[ 0 ] );
  Matrix1[ 1 ] := vector_Add( Matrix1[ 1 ], Matrix2[ 1 ] );
  Matrix1[ 2 ] := vector_Add( Matrix1[ 2 ], Matrix2[ 2 ] );
end;

procedure matrix3f_Mul;
begin
  Matrix1[ 0 ].X := Matrix1[ 0 ].X * Matrix2[ 0 ].X + Matrix1[ 0 ].Y * Matrix2[ 1 ].X + Matrix1[ 0 ].Z * Matrix2[ 2 ].X;
  Matrix1[ 0 ].Y := Matrix1[ 0 ].X * Matrix2[ 0 ].Y + Matrix1[ 0 ].Y * Matrix2[ 1 ].Y + Matrix1[ 0 ].Z * Matrix2[ 2 ].Y;
  Matrix1[ 0 ].Z := Matrix1[ 0 ].X * Matrix2[ 0 ].Z + Matrix1[ 0 ].Y * Matrix2[ 1 ].Z + Matrix1[ 0 ].Z * Matrix2[ 2 ].Z;
  Matrix1[ 1 ].X := Matrix1[ 1 ].X * Matrix2[ 0 ].X + Matrix1[ 1 ].Y * Matrix2[ 1 ].X + Matrix1[ 1 ].Z * Matrix2[ 2 ].X;
  Matrix1[ 1 ].Y := Matrix1[ 1 ].X * Matrix2[ 0 ].Y + Matrix1[ 1 ].Y * Matrix2[ 1 ].Y + Matrix1[ 1 ].Z * Matrix2[ 2 ].Y;
  Matrix1[ 1 ].Z := Matrix1[ 1 ].X * Matrix2[ 0 ].Z + Matrix1[ 1 ].Y * Matrix2[ 1 ].Z + Matrix1[ 1 ].Z * Matrix2[ 2 ].Z;
  Matrix1[ 2 ].X := Matrix1[ 2 ].X * Matrix2[ 0 ].X + Matrix1[ 2 ].Y * Matrix2[ 1 ].X + Matrix1[ 2 ].Z * Matrix2[ 2 ].X;
  Matrix1[ 2 ].Y := Matrix1[ 2 ].X * Matrix2[ 0 ].Y + Matrix1[ 2 ].Y * Matrix2[ 1 ].Y + Matrix1[ 2 ].Z * Matrix2[ 2 ].Y;
  Matrix1[ 2 ].Z := Matrix1[ 2 ].X * Matrix2[ 0 ].Z + Matrix1[ 2 ].Y * Matrix2[ 1 ].Z + Matrix1[ 2 ].Z * Matrix2[ 2 ].Z;
end;

function line3d_ClosestPoint;
  var
    v1, v2 : zglTPoint3D;
    d, t   : Single;
begin
	v1 := vector_Sub( Point, A );
  v2 := vector_Normalize( vector_Sub( B, A ) );
  d  := vector_FDistance( A, B );
  t  := vector_Dot( v2, v1 );

  if  t <= 0 Then
    begin
      Result := A;
		  exit;
  	end;

  if sqr( t ) >= d Then
    begin
	  	Result := B;
		  exit;
  	end;

  Result := vector_Add( A, vector_MulV( v2, t ) );
end;

{------------------------------------------------------------------------------}
{----------------------------------- Plane ------------------------------------}
{------------------------------------------------------------------------------}
function plane_Get;
begin
  Result.Points[ 0 ] := A;
  Result.Points[ 1 ] := B;
  Result.Points[ 2 ] := C;
  Result.Normal      := tri_GetNormal( @A, @B, @C );
  Result.D           := -( Result.Normal.X * Result.Points[ 0 ].X + Result.Normal.Y * Result.Points[ 0 ].Y + Result.Normal.Z * Result.Points[ 0 ].Z );
end;

function plane_Distance;
begin
	Result := Plane.Normal.X * Point.X + Plane.Normal.Y * Point.Y + Plane.Normal.Z * Point.Z + Plane.D;
end;

function tri_GetNormal;
  var
    s1, s2, p : zglTPoint3D;
    uvector   : Single;
begin
  s1 := vector_Sub( A^, B^ );
  s2 := vector_Sub( B^, C^ );
  // вектор перпендикулярен центру треугольника
  p := vector_Cross( s1, s2 );
  // получаем унитарный вектор единичной длины
  uvector := sqrt( sqr( p.X ) + sqr( p.Y ) + sqr( p.Z ) );
  if uvector = 0 Then uvector := 1;

  Result := vector_DivV( p, uvector );
end;

end.
