{
 *  Copyright © Kemka Andrey aka Andru
 *  mail: dr.andru@gmail.com
 *  site: http://andru-kun.inf.ua
 *
 *  This file is part of ZenGL.
 *
 *  ZenGL is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as
 *  published by the Free Software Foundation, either version 3 of
 *  the License, or (at your option) any later version.
 *
 *  ZenGL is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with ZenGL. If not, see http://www.gnu.org/licenses/
}
unit zgl_textures;

{$I zgl_config.cfg}

interface

uses
  zgl_direct3d,
  zgl_direct3d_all,
  zgl_memory;

const
  TEX_MIPMAP            = $000001;
  TEX_CLAMP             = $000002;
  TEX_REPEAT            = $000004;
  TEX_COMPRESS          = $000008;
  TEX_CONVERT_TO_POT    = $000010;

  TEX_GRAYSCALE         = $000020;
  TEX_INVERT            = $000040;

  TEX_FILTER_NEAREST    = $000080;
  TEX_FILTER_LINEAR     = $000100;
  TEX_FILTER_BILINEAR   = $000200;
  TEX_FILTER_TRILINEAR  = $000400;
  TEX_FILTER_ANISOTROPY = $000800;

  TEX_RGB               = $001000;
  TEX_CALCULATE_ALPHA   = $002000;

  TEX_QUALITY_LOW       = $400000;
  TEX_QUALITY_MEDIUM    = $800000;

  TEX_DEFAULT_2D        = TEX_CLAMP or TEX_FILTER_LINEAR or TEX_CONVERT_TO_POT or TEX_CALCULATE_ALPHA;

type
  zglPTexture = ^zglTTexture;
  zglTTexture = record
    ID            : LongWord;
    Width, Height : Word;
    U, V          : Single;
    FramesX       : Word;
    FramesY       : Word;
    Flags         : LongWord;

    prev, next    : zglPTexture;
end;

type
  zglPTextureFormat = ^zglTTextureFormat;
  zglTTextureFormat = record
    Extension  : String;
    FileLoader : procedure( const FileName : String; var pData : Pointer; var W, H : Word );
    MemLoader  : procedure( const Memory : zglTMemory; var pData : Pointer; var W, H : Word );
end;

type
  zglPTextureManager = ^zglTTextureManager;
  zglTTextureManager = record
    Count   : record
      Items   : LongWord;
      Formats : LongWord;
              end;
    First   : zglTTexture;
    Formats : array of zglTTextureFormat;
end;

function  tex_Add : zglPTexture;
procedure tex_Del( var Texture : zglPTexture );

procedure tex_Create( var Texture : zglTTexture; var pData : Pointer );
function  tex_CreateZero( const Width, Height : Word; const Color, Flags : LongWord ) : zglPTexture;
function  tex_LoadFromFile( const FileName : String; const TransparentColor, Flags : LongWord ) : zglPTexture;
function  tex_LoadFromMemory( const Memory : zglTMemory; const Extension : String; const TransparentColor, Flags : LongWord ) : zglPTexture;
procedure tex_SetFrameSize( var Texture : zglPTexture; FrameWidth, FrameHeight : Word );
function  tex_SetMask( var Texture : zglPTexture; const Mask : zglPTexture ) : zglPTexture;

procedure tex_Filter( Texture : zglPTexture; const Flags : LongWord );
procedure tex_SetAnisotropy( const Level : Byte );

procedure tex_CalcPOT( var pData : Pointer; var Width, Height : Word; var U, V : Single );
procedure tex_CalcGrayScale( var pData : Pointer; const Width, Height : Word );
procedure tex_CalcInvert( var pData : Pointer; const Width, Height : Word );
procedure tex_CalcRGB( var pData : Pointer; const Width, Height : Word );
procedure tex_CalcTransparent( var pData : Pointer; const TransparentColor : LongWord; const Width, Height : Word );

procedure tex_GetData( const Texture : zglPTexture; var pData : Pointer; var pSize : Integer );

var
  managerTexture : zglTTextureManager;
  zeroTexture    : zglPTexture;

implementation
uses
  zgl_types,
  zgl_main,
  zgl_screen,
  zgl_render_2d,
  zgl_file,
  zgl_log,
  zgl_utils;

function tex_Add;
begin
  Result := @managerTexture.First;
  while Assigned( Result.next ) do
    Result := Result.next;

  zgl_GetMem( Pointer( Result.next ), SizeOf( zglTTexture ) );
  Result.next.prev := Result;
  Result.next.next := nil;
  Result := Result.next;
  INC( managerTexture.Count.Items );
end;

procedure tex_Del;
begin
  if not Assigned( Texture ) Then exit;

  glDeleteTextures( 1, @Texture.ID );
  if Assigned( Texture.prev ) Then
    Texture.prev.next := Texture.next;
  if Assigned( Texture.next ) Then
    Texture.next.prev := Texture.prev;
  FreeMemory( Texture );
  Texture := nil;

  DEC( managerTexture.Count.Items );
end;

procedure tex_Create;
  var
    format, iformat, cformat : LongWord;
begin
  if Texture.Flags and TEX_GRAYSCALE > 0 Then
    tex_CalcGrayScale( pData, Texture.Width, Texture.Height );
  if Texture.Flags and TEX_INVERT > 0 Then
    tex_CalcInvert( pData, Texture.Width, Texture.Height );
  if Texture.Flags and TEX_CONVERT_TO_POT > 0 Then
    tex_CalcPOT( pData, Texture.Width, Texture.Height, Texture.U, Texture.V );
  if Texture.Flags and TEX_RGB > 0 Then
    tex_CalcRGB( pData, Texture.Width, Texture.Height );

  if Texture.Flags and TEX_COMPRESS >= 1 Then
    if not ogl_CanCompress Then
      Texture.Flags := Texture.Flags xor TEX_COMPRESS;

  glEnable( GL_TEXTURE_2D );
  glGenTextures( 1, @Texture.ID );

  tex_Filter( @Texture, Texture.Flags );
  glBindTexture( GL_TEXTURE_2D, Texture.ID );

  if Texture.Flags and TEX_RGB > 0 Then
    begin
      format  := GL_RGB;
      iformat := GL_RGB;
      cformat := GL_COMPRESSED_RGB_ARB;
    end else
      begin
        format  := GL_RGBA;
        iformat := GL_RGBA;
        cformat := GL_COMPRESSED_RGBA_ARB;
      end;

  glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );

  if Texture.Flags and TEX_MIPMAP = 0 Then
    begin
      if Texture.Flags and TEX_COMPRESS = 0 Then
        glTexImage2D( GL_TEXTURE_2D, 0, iformat, Texture.Width, Texture.Height, 0, format, GL_UNSIGNED_BYTE, pData )
      else
        glTexImage2D( GL_TEXTURE_2D, 0, cformat, Texture.Width, Texture.Height, 0, format, GL_UNSIGNED_BYTE, pData );
    end else
      begin
        if Texture.Flags and TEX_COMPRESS = 0 Then
          gluBuild2DMipmaps( GL_TEXTURE_2D, iformat, Texture.Width, Texture.Height, format, GL_UNSIGNED_BYTE, pData )
        else
          gluBuild2DMipmaps( GL_TEXTURE_2D, cformat, Texture.Width, Texture.Height, format, GL_UNSIGNED_BYTE, pData )
      end;

  glDisable( GL_TEXTURE_2D );

  if Texture.Flags and TEX_CONVERT_TO_POT > 0 Then
    begin
      Texture.Width  := Round( Texture.Width * Texture.U );
      Texture.Height := Round( Texture.Height * Texture.V );
    end;
end;

function tex_CreateZero;
  var
    i       : LongWord;
    pData   : Pointer;
begin
  GetMem( pData, Width * Height * 4 );
  for i := 0 to Width * Height - 1 do
    Move( Color, Pointer( Ptr( pData ) + i * 4 )^, 4 );

  Result         := tex_Add();
  Result.Width   := Width;
  Result.Height  := Height;
  Result.U       := 1;
  Result.V       := 1;
  Result.FramesX := 1;
  Result.FramesY := 1;
  Result.Flags   := Flags;
  tex_Create( Result^, pData );

  FreeMemory( pData );
end;

function tex_LoadFromFile;
  var
    i      : Integer;
    pData  : Pointer;
    w, h   : Word;
    ext    : String;
begin
  Result := nil;
  pData  := nil;

  if not Assigned( zeroTexture ) Then
    zeroTexture := tex_CreateZero( 4, 4, $FFFFFFFF, TEX_DEFAULT_2D );
  Result := zeroTexture;

  if not file_Exists( FileName ) Then
    begin
      log_Add( 'Cannot read ' + FileName );
      exit;
    end;

  for i := managerTexture.Count.Formats - 1 downto 0 do
    begin
      file_GetExtension( FileName, ext );
      if u_StrUp( ext ) = managerTexture.Formats[ i ].Extension Then
        managerTexture.Formats[ i ].FileLoader( FileName, pData, w, h );
    end;

  if not Assigned( pData ) Then
    begin
      log_Add( 'Unable to load texture: "' + FileName + '"' );
      exit;
    end;

  Result         := tex_Add;
  Result.Width   := w;
  Result.Height  := h;
  Result.U       := 1;
  Result.V       := 1;
  Result.FramesX := 1;
  Result.FramesY := 1;
  Result.Flags   := Flags;
  if ( Flags and TEX_RGB > 0 ) and ( Flags and TEX_CALCULATE_ALPHA > 0 ) Then
    Result.Flags := Flags xor TEX_CALCULATE_ALPHA;
  if ( Result.Flags and TEX_RGB = 0 ) and ( Result.Flags and TEX_CALCULATE_ALPHA > 0 ) Then
    tex_CalcTransparent( pData, TransparentColor, w, h );
  tex_Create( Result^, pData );

  log_Add( 'Successful loading of texture: "' + FileName + '"' );

  FreeMemory( pData );
end;

function tex_LoadFromMemory;
  var
    i      : Integer;
    pData  : Pointer;
    w, h   : Word;
begin
  Result := nil;
  pData  := nil;

  if not Assigned( zeroTexture ) Then
    zeroTexture := tex_CreateZero( 4, 4, $FFFFFFFF, TEX_DEFAULT_2D );
  Result := zeroTexture;

  for i := managerTexture.Count.Formats - 1 downto 0 do
    if u_StrUp( Extension ) = managerTexture.Formats[ i ].Extension Then
      managerTexture.Formats[ i ].MemLoader( Memory, pData, w, h );

  if not Assigned( pData ) Then
    begin
      log_Add( 'Unable to load texture: From Memory' );
      exit;
    end;

  Result         := tex_Add();
  Result.Width   := w;
  Result.Height  := h;
  Result.U       := 1;
  Result.V       := 1;
  Result.FramesX := 1;
  Result.FramesY := 1;
  Result.Flags   := Flags;
  if ( Flags and TEX_RGB > 0 ) and ( Flags and TEX_CALCULATE_ALPHA > 0 ) Then
    Result.Flags := Flags xor TEX_CALCULATE_ALPHA;
  if ( Result.Flags and TEX_RGB = 0 ) and ( Result.Flags and TEX_CALCULATE_ALPHA > 0 ) Then
    tex_CalcTransparent( pData, TransparentColor, w, h );
  tex_Create( Result^, pData );

  FreeMemory( pData );
end;

procedure tex_SetFrameSize;
begin
  if not Assigned( Texture ) Then exit;

  if Texture.Flags and TEX_QUALITY_MEDIUM > 0 Then
    begin
      FrameWidth := FrameWidth div 2;
      FrameHeight := FrameHeight div 2;
    end else
      if Texture.Flags and TEX_QUALITY_LOW > 0 Then
        begin
          FrameWidth := FrameWidth div 4;
          FrameHeight := FrameHeight div 4;
        end;

  Texture.FramesX := Round( Texture.Width ) div FrameWidth;
  Texture.FramesY := Round( Texture.Height ) div FrameHeight;
end;

function tex_SetMask;
  var
    i, j         : Integer;
    tSize, mSize : Integer;
    tData, mData : Pointer;
    pData        : Pointer;
    rW, mW       : Integer;
begin
  if ( not Assigned( Texture ) ) or ( not Assigned( Mask ) ) Then exit;

  rW := Round( Texture.Width / Texture.U );
  mW := Round( Mask.Width / Mask.U );

  tex_GetData( Texture, tData, tSize );
  tex_GetData( Mask, mData, mSize );
  GetMem( pData, Texture.Width * Texture.Height * 4 );

  for i := 0 to Texture.Width - 1 do
    for j := 0 to Texture.Height - 1 do
      begin
        PByte( Ptr( pData ) + i * 4 + j * Texture.Width * 4 + 0 )^ := PByte( Ptr( tData ) + i * tSize + j * rW * tSize + 2 )^;
        PByte( Ptr( pData ) + i * 4 + j * Texture.Width * 4 + 1 )^ := PByte( Ptr( tData ) + i * tSize + j * rW * tSize + 1 )^;
        PByte( Ptr( pData ) + i * 4 + j * Texture.Width * 4 + 2 )^ := PByte( Ptr( tData ) + i * tSize + j * rW * tSize + 0 )^;
        PByte( Ptr( pData ) + i * 4 + j * Texture.Width * 4 + 3 )^ := PByte( Ptr( mData ) + i * mSize + j * mW * mSize + 0 )^;
      end;

  Result         := tex_Add();
  Result.Width   := Texture.Width;
  Result.Height  := Texture.Height;
  Result.U       := 1;
  Result.V       := 1;
  Result.FramesX := 1;
  Result.FramesY := 1;
  Result.Flags   := Texture.Flags xor TEX_GRAYSCALE * Byte( Texture.Flags and TEX_GRAYSCALE > 0 ) xor TEX_INVERT * Byte( Texture.Flags and TEX_INVERT > 0 );
  tex_Create( Result^, pData );
  tex_Del( Texture );

  FreeMem( pData );
  FreeMem( tData );
  FreeMem( mData );
end;

procedure tex_Filter;
begin
  Texture.Flags := Flags;
  glBindTexture( GL_TEXTURE_2D, Texture.ID );

  if Flags and TEX_CLAMP > 0 Then
    begin
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    end;
  if Flags and TEX_REPEAT > 0 Then
    begin
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
    end;
  if Flags and TEX_MIPMAP > 0 Then
    begin
      if Flags and TEX_FILTER_NEAREST > 0 Then
        begin
          glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
          glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
        end else
          if Flags and TEX_FILTER_LINEAR > 0 Then
            begin
              glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
              glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
            end else
              if Flags and TEX_FILTER_BILINEAR > 0 Then
                begin
                  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST );
                  glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
                end else
                  if Flags and TEX_FILTER_TRILINEAR > 0 Then
                    begin
                      glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
                      glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
                    end else
                      if Flags and TEX_FILTER_ANISOTROPY > 0 Then
                        begin
                          glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
                          glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
                          glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, ogl_Anisotropy );
                        end;
    end else
      begin
        if ( Flags and TEX_FILTER_NEAREST > 0 ) or ( ( Flags and TEX_FILTER_LINEAR = 0 ) and ( Flags and TEX_FILTER_BILINEAR = 0 ) and
           ( Flags and TEX_FILTER_TRILINEAR = 0 ) and ( Flags and TEX_FILTER_ANISOTROPY = 0 ) ) Then
          begin
            glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
            glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
          end else
            begin
              glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
              glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
            end;
      end;
end;

procedure tex_SetAnisotropy;
begin
  if Level > ogl_MaxAnisotropy Then
    ogl_Anisotropy := ogl_MaxAnisotropy
  else
    ogl_Anisotropy := Level;
end;

procedure tex_CalcPOT;
  var
    i, j : LongWord;
    w, h : Word;
    data : array of Byte;
begin
  w := u_GetPOT( Width );
  h := u_GetPOT( Height );
  if ( w = Width ) and ( h = Height ) Then
    begin
      U := 1;
      V := 1;
      exit;
    end;
  U := Width  / w;
  V := Height / h;

  SetLength( data, Width * Height * 4 );
  Move( pData^, Pointer( data )^, Width * Height * 4 );
  FreeMem( pData );
  GetMem( pData, w * h * 4 );

  for i := 0 to Height - 1 do
    Move( data[ i * Width * 4 ], PLongWord( Ptr( pData ) + i * w * 4 )^, Width * 4 );

  for i := Height to h - 1 do
    Move( PByte( Ptr( pData ) + ( Height - 1 ) * w * 4 )^, PByte( Ptr( pData ) + i * w * 4 )^, Width * 4 );
  for i := 0 to h - 1 do
    for j := Width to w - 1 do
      PLongWord( Ptr( pData ) + j * 4 + i * w * 4 )^ := PLongWord( Ptr( pData ) + ( Width - 1 ) * 4 + i * w * 4 )^;

  Width  := w;
  Height := h;
  SetLength( data, 0 );
end;

procedure tex_CalcGrayScale;
  var
    i    : Integer;
    p    : Ptr;
    gray : Byte;
begin
  for i := 0 to Width * Height - 1 do
    begin
      p := Ptr( pData ) + i * 4;
      gray := Round( PByte( p + 0 )^ * 0.299 + PByte( p + 1 )^ * 0.587 + PByte( p + 2 )^ * 0.114 );

      PByte( p + 0 )^ := gray;
      PByte( p + 1 )^ := gray;
      PByte( p + 2 )^ := gray;
    end;
end;

procedure tex_CalcInvert;
  var
    i : Integer;
    p : Ptr;
begin
  for i := 0 to Width * Height - 1 do
    begin
      p := Ptr( pData ) + i * 4;
      PByte( p + 0 )^ := 255 - PByte( p + 0 )^;
      PByte( p + 1 )^ := 255 - PByte( p + 1 )^;
      PByte( p + 2 )^ := 255 - PByte( p + 2 )^;
    end;
end;

procedure tex_CalcRGB;
  var
    i : LongWord;
begin
  for i := 0 to Width * Height - 1 do
    begin
      PByte( Ptr( pData ) + i * 3 + 0 )^ := PByte( Ptr( pData ) + i * 4 + 0 )^;
      PByte( Ptr( pData ) + i * 3 + 1 )^ := PByte( Ptr( pData ) + i * 4 + 1 )^;
      PByte( Ptr( pData ) + i * 3 + 2 )^ := PByte( Ptr( pData ) + i * 4 + 2 )^;
    end;
  ReallocMem( pData, Width * Height * 3 );
end;

procedure tex_CalcTransparent;
  var
    i       : Integer;
    r, g, b : Byte;
    procedure Fill; {$IFDEF USE_INLINE} inline; {$ENDIF}
    begin
      PByte( Ptr( pData ) + 0 + i * 4 )^ := 0;
      PByte( Ptr( pData ) + 1 + i * 4 )^ := 0;
      PByte( Ptr( pData ) + 2 + i * 4 )^ := 0;
      PByte( Ptr( pData ) + 3 + i * 4 )^ := 0;

      if i + Width <= Width * Height - 1 Then
        if PByte( Ptr( pData ) + ( i + Width ) * 4 + 3 )^ > 0 Then
          begin
            PByte( Ptr( pData ) + 0 + i * 4 )^ := PByte( Ptr( pData ) + ( i + Width ) * 4 + 0 )^;
            PByte( Ptr( pData ) + 1 + i * 4 )^ := PByte( Ptr( pData ) + ( i + Width ) * 4 + 1 )^;
            PByte( Ptr( pData ) + 2 + i * 4 )^ := PByte( Ptr( pData ) + ( i + Width ) * 4 + 2 )^;
          end;

      if i + 1 <= Width * Height - 1 Then
        if PByte( Ptr( pData ) + ( i + 1 ) * 4 + 3 )^ > 0 Then
          begin
            PByte( Ptr( pData ) + 0 + i * 4 )^ := PByte( Ptr( pData ) + ( i + 1 ) * 4 + 0 )^;
            PByte( Ptr( pData ) + 1 + i * 4 )^ := PByte( Ptr( pData ) + ( i + 1 ) * 4 + 1 )^;
            PByte( Ptr( pData ) + 2 + i * 4 )^ := PByte( Ptr( pData ) + ( i + 1 ) * 4 + 2 )^;
          end;

      if i - 1 > 0 Then
        if PByte( Ptr( pData ) + ( i - 1 ) * 4 + 3 )^ > 0 Then
          begin
            PByte( Ptr( pData ) + 0 + i * 4 )^ := PByte( Ptr( pData ) + ( i - 1 ) * 4 + 0 )^;
            PByte( Ptr( pData ) + 1 + i * 4 )^ := PByte( Ptr( pData ) + ( i - 1 ) * 4 + 1 )^;
            PByte( Ptr( pData ) + 2 + i * 4 )^ := PByte( Ptr( pData ) + ( i - 1 ) * 4 + 2 )^;
          end;

      if i - Width > 0 Then
        if PByte( Ptr( pData ) + ( i - Width ) * 4 + 3 )^ > 0 Then
          begin
            PByte( Ptr( pData ) + 0 + i * 4 )^ := PByte( Ptr( pData ) + ( i - Width ) * 4 + 0 )^;
            PByte( Ptr( pData ) + 1 + i * 4 )^ := PByte( Ptr( pData ) + ( i - Width ) * 4 + 1 )^;
            PByte( Ptr( pData ) + 2 + i * 4 )^ := PByte( Ptr( pData ) + ( i - Width ) * 4 + 2 )^;
          end;

      if ( i - 1 > 0 ) and ( i - Width > 0 ) Then
        if PByte( Ptr( pData ) + ( i - Width - 1 ) * 4 + 3 )^ > 0 Then
          begin
            PByte( Ptr( pData ) + 0 + i * 4 )^ := PByte( Ptr( pData ) + ( i - Width - 1 ) * 4 + 0 )^;
            PByte( Ptr( pData ) + 1 + i * 4 )^ := PByte( Ptr( pData ) + ( i - Width - 1 ) * 4 + 1 )^;
            PByte( Ptr( pData ) + 2 + i * 4 )^ := PByte( Ptr( pData ) + ( i - Width - 1 ) * 4 + 2 )^;
          end;

      if ( i + 1 <= Width * Height - 1 ) and ( i - Width > 0 ) Then
        if PByte( Ptr( pData ) + ( i - Width + 1 ) * 4 + 3 )^ > 0 Then
          begin
            PByte( Ptr( pData ) + 0 + i * 4 )^ := PByte( Ptr( pData ) + ( i - Width + 1 ) * 4 + 0 )^;
            PByte( Ptr( pData ) + 1 + i * 4 )^ := PByte( Ptr( pData ) + ( i - Width + 1 ) * 4 + 1 )^;
            PByte( Ptr( pData ) + 2 + i * 4 )^ := PByte( Ptr( pData ) + ( i - Width + 1 ) * 4 + 2 )^;
          end;

      if ( i - 1 > 0 ) and ( i + Width <= Width * Height - 1 ) Then
        if PByte( Ptr( pData ) + ( i + Width - 1 ) * 4 + 3 )^ > 0 Then
          begin
            PByte( Ptr( pData ) + 0 + i * 4 )^ := PByte( Ptr( pData ) + ( i + Width - 1 ) * 4 + 0 )^;
            PByte( Ptr( pData ) + 1 + i * 4 )^ := PByte( Ptr( pData ) + ( i + Width - 1 ) * 4 + 1 )^;
            PByte( Ptr( pData ) + 2 + i * 4 )^ := PByte( Ptr( pData ) + ( i + Width - 1 ) * 4 + 2 )^;
          end;

      if ( i + 1 <= Width * Height - 1 ) and ( i + Width <= Width * Height - 1 ) Then
        if PByte( Ptr( pData ) + ( i + Width + 1 ) * 4 + 3 )^ > 0 Then
          begin
            PByte( Ptr( pData ) + 0 + i * 4 )^ := PByte( Ptr( pData ) + ( i + Width + 1 ) * 4 + 0 )^;
            PByte( Ptr( pData ) + 1 + i * 4 )^ := PByte( Ptr( pData ) + ( i + Width + 1 ) * 4 + 1 )^;
            PByte( Ptr( pData ) + 2 + i * 4 )^ := PByte( Ptr( pData ) + ( i + Width + 1 ) * 4 + 2 )^;
          end;
    end;
begin
  if TransparentColor = $FF000000 Then
    begin
      for i := 0 to Width * Height - 1 do
        if ( PByte( Ptr( pData ) + 3 + i * 4 )^ = 0 ) Then Fill;
    end else
      begin
        r := ( TransparentColor and $FF0000 ) shr 16;
        g := ( TransparentColor and $FF00   ) shr 8;
        b := ( TransparentColor and $FF     );
        for i := 0 to Width * Height - 1 do
          if ( PByte( Ptr( pData ) + 0 + i * 4 )^ = r ) and ( PByte( Ptr( pData ) + 1 + i * 4 )^ = g ) and ( PByte( Ptr( pData ) + 2 + i * 4 )^ = b ) Then Fill;
      end;
end;

procedure tex_GetData;
begin
  if b2d_Started Then
    begin
      batch2d_Flush();
      b2d_New := TRUE;
    end;

  pSize := 4;
  GetMem( pData, Round( Texture.Width / Texture.U ) * Round( Texture.Height / Texture.V ) * pSize );

  glEnable( GL_TEXTURE_2D );
  glBindTexture( GL_TEXTURE_2D, Texture.ID );
  if Texture.Flags and TEX_RGB > 0 Then
    glGetTexImage( GL_TEXTURE_2D, 0, GL_RGB, GL_UNSIGNED_BYTE, pData )
  else
    glGetTexImage( GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, pData );
  glDisable( GL_TEXTURE_2D );
end;

end.
