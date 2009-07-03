{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru-kun.ru
 *
 * This file is part of ZenGL
 *
 * ZenGL is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * ZenGL is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
}
unit zgl_direct3d8_all;

{$I zgl_config.cfg}

interface
uses
  DirectXGraphics;

const
  GL_FALSE                          = 0;
  GL_TRUE                           = 1;
  GL_ZERO                           = 0;
  GL_ONE                            = 1;

  // DataType
  GL_UNSIGNED_BYTE                  = $1401;
  GL_UNSIGNED_SHORT                 = $1403;
  GL_UNSIGNED_INT                   = $1405;
  GL_FLOAT                          = $1406;

  // PixelFormat
  GL_RGB                            = $1907;
  GL_RGBA                           = $1908;

  // Alpha Function
  GL_NEVER                          = $0200;
  GL_LESS                           = $0201;
  GL_EQUAL                          = $0202;
  GL_LEQUAL                         = $0203;
  GL_GREATER                        = $0204;
  GL_NOTEQUAL                       = $0205;
  GL_GEQUAL                         = $0206;
  GL_ALWAYS                         = $0207;

  // Blend
  GL_BLEND                          = $0BE2;
  // Blending Factor Dest
  GL_SRC_COLOR                      = $0300;
  GL_ONE_MINUS_SRC_COLOR            = $0301;
  GL_SRC_ALPHA                      = $0302;
  GL_ONE_MINUS_SRC_ALPHA            = $0303;
  GL_DST_ALPHA                      = $0304;
  GL_ONE_MINUS_DST_ALPHA            = $0305;
  // Blending Factor Src
  GL_DST_COLOR                      = $0306;
  GL_ONE_MINUS_DST_COLOR            = $0307;
  GL_SRC_ALPHA_SATURATE             = $0308;

  // Buffer Bit
  GL_DEPTH_BUFFER_BIT               = $00000100;
  GL_STENCIL_BUFFER_BIT             = $00000400;
  GL_COLOR_BUFFER_BIT               = $00004000;

  // Enable
  GL_LINE_SMOOTH                    = $0B20;
  GL_POLYGON_SMOOTH                 = $0B41;

  // glBegin/glEnd
  GL_POINTS                         = $0000;
  GL_LINES                          = $0001;
  GL_TRIANGLES                      = $0004;
  GL_TRIANGLE_STRIP                 = $0005;
  GL_QUADS                          = $0007;

  // Texture
  GL_TEXTURE_2D                     = $0DE1;
  GL_TEXTURE0_ARB                   = $84C0;
  GL_MAX_TEXTURE_SIZE               = $0D33;
  GL_MAX_TEXTURE_UNITS_ARB          = $84E2;
  GL_TEXTURE_MAX_ANISOTROPY_EXT     = $84FE;
  GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT = $84FF;
  // Texture Wrap Mode
  GL_CLAMP_TO_EDGE                  = $812F;
  GL_REPEAT                         = $2901;
  // Texture Format
  GL_RGB16                          = $8054;
  GL_RGBA16                         = $805B;
  GL_COMPRESSED_RGB_ARB             = $84ED;
  GL_COMPRESSED_RGBA_ARB            = $84EE;
  // Texture Env Mode
  GL_MODULATE                       = $2100;
  GL_DECAL                          = $2101;
  // Texture Env Parameter
  GL_TEXTURE_ENV_MODE               = $2200;
  GL_TEXTURE_ENV_COLOR              = $2201;
  // Texture Env Target
  GL_TEXTURE_ENV                    = $2300;
  // Texture Mag Filter
  GL_NEAREST                        = $2600;
  GL_LINEAR                         = $2601;
  // Texture Min Filter
  GL_NEAREST_MIPMAP_NEAREST         = $2700;
  GL_LINEAR_MIPMAP_NEAREST          = $2701;
  GL_NEAREST_MIPMAP_LINEAR          = $2702;
  GL_LINEAR_MIPMAP_LINEAR           = $2703;
  // Texture Parameter Name
  GL_TEXTURE_MAG_FILTER             = $2800;
  GL_TEXTURE_MIN_FILTER             = $2801;
  GL_TEXTURE_WRAP_S                 = $2802;
  GL_TEXTURE_WRAP_T                 = $2803;

  // d3d8_Matrices
  GL_MODELVIEW_MATRIX               = $0BA6;
  GL_PROJECTION_MATRIX              = $0BA7;

  // Matrix Mode
  GL_MODELVIEW                      = $1700;
  GL_PROJECTION                     = $1701;
  GL_TEXTURE                        = $1702;

  // Test
  GL_DEPTH_TEST                     = $0B71;
  GL_STENCIL_TEST                   = $0B90;
  GL_ALPHA_TEST                     = $0BC0;
  GL_SCISSOR_TEST                   = $0C11;

type
  GLenum     = Cardinal;      PGLenum     = ^GLenum;
  GLboolean  = Byte;          PGLboolean  = ^GLboolean;
  GLbitfield = Cardinal;      PGLbitfield = ^GLbitfield;
  GLbyte     = ShortInt;      PGLbyte     = ^GLbyte;
  GLshort    = SmallInt;      PGLshort    = ^GLshort;
  GLint      = Integer;       PGLint      = ^GLint;
  GLsizei    = Integer;       PGLsizei    = ^GLsizei;
  GLubyte    = Byte;          PGLubyte    = ^GLubyte;
  GLushort   = Word;          PGLushort   = ^GLushort;
  GLuint     = Cardinal;      PGLuint     = ^GLuint;
  GLfloat    = Single;        PGLfloat    = ^GLfloat;
  GLclampf   = Single;        PGLclampf   = ^GLclampf;
  GLdouble   = Double;        PGLdouble   = ^GLdouble;
  GLclampd   = Double;        PGLclampd   = ^GLclampd;
{ GLvoid     = void; }        PGLvoid     = Pointer;
                              PPGLvoid    = ^PGLvoid;

// D3DFVF_XYZC
const
  D3DFVF_XYZC = D3DFVF_XYZ or D3DFVF_DIFFUSE;
type
  TXYZCVertex = record
    x, y, z : Single;
    c       : LongWord;
end;
const
  s_D3DFVF_XYZC = SizeOf( TXYZCVertex );

// D3DFVF_XYZCT
const
  D3DFVF_XYZCT = D3DFVF_XYZ or D3DFVF_DIFFUSE or D3DFVF_TEX1;
type
  TXYZCTVertex = record
    x, y, z : Single;
    c       : LongWord;
    u, v    : Single;
end;
const
  s_D3DFVF_XYZCT = SizeOf( TXYZCTVertex );

type
  zglD3D8Texture = record
    Texture    : IDirect3DTexture8;
    MagFilter  : LongWord;
    MinFilter  : LongWord;
    MipFilter  : LongWord;
    Wrap       : LongWord;
end;

// Clear
procedure glClear(mask: GLbitfield);
// State
procedure glBegin(mode: GLenum);
procedure glEnd;
procedure glEnable(cap: GLenum);
procedure glDisable(cap: GLenum);
// Viewport
procedure glViewport(x, y: GLint; width, height: GLsizei);
procedure glOrtho(left, right, bottom, top, zNear, zFar: GLdouble);
procedure glScissor(x, y: GLint; width, height: GLsizei);
// Color
procedure glColor4ub(red, green, blue, alpha: GLubyte);
procedure glColor4f(red, green, blue, alpha: GLfloat);
// Alpha
procedure glAlphaFunc(func: GLenum; ref: GLclampf);
procedure glBlendFunc(sfactor, dfactor: GLenum);
// Matrix
procedure glMatrixMode(mode: GLenum);
procedure glLoadIdentity;
procedure gluPerspective(fovy, aspect, zNear, zFar: GLdouble);
procedure glFrustum(left, right, bottom, top, zNear, zFar: GLdouble);
procedure glScalef(x, y, z: GLfloat);
procedure glTranslatef(x, y, z: GLfloat);
// Vertex
procedure glVertex2f(x, y: GLfloat);
procedure glVertex2fv(v: PGLfloat);
// Texture
procedure glBindTexture(target: GLenum; texture: GLuint);
procedure glGenTextures(n: GLsizei; textures: PGLuint);
procedure glDeleteTextures(n: GLsizei; const textures: PGLuint);
procedure glTexParameterf(target: GLenum; pname: GLenum; param: GLfloat);
procedure glTexParameteri(target: GLenum; pname: GLenum; param: GLint);
procedure glTexImage2D(target: GLenum; level, internalformat: GLint; width, height: GLsizei; border: GLint; format, atype: GLenum; const pixels: Pointer);
procedure glGetTexImage(target: GLenum; level: GLint; format: GLenum; atype: GLenum; pixels: Pointer);
procedure glCopyTexSubImage2D(target: GLenum; level, xoffset, yoffset, x, y: GLint; width, height: GLsizei);
procedure glTexEnvi(target: GLenum; pname: GLenum; param: GLint);
function  gluBuild2DMipmaps(target: GLenum; components, width, height: GLint; format, atype: GLenum; const data: Pointer): Integer;
// TexCoords
procedure glTexCoord2f(s, t: GLfloat);
procedure glTexCoord2fv(v: PGLfloat);

var
  gl_TexCoord2f   : procedure( U, V : Single );
  gl_TexCoord2fv  : procedure( Coord : PSingle );
  gl_Vertex2f     : procedure( X, Y : Single );
  gl_Vertex2fv    : procedure( v : PSingle );
  d3d8_texCount   : Integer;
  d3d8_texArray   : array of zglD3D8Texture;
  d3d8_Matrices   : array[ 0..23 ] of TD3DMatrix;
  d3d8_MatrixMode : LongWord;

implementation
uses
  zgl_direct3d8,
  zgl_const,
  zgl_application,
  zgl_screen,
  zgl_window,
  zgl_textures,
  zgl_log,
  zgl_math_2d,
  zgl_types,
  math;

var
  RenderMode     : TD3DPrimitiveType;
  RenderQuad     : Boolean;
  RenderTextured : Boolean;
  RenderTexID    : Integer;
  // Textures
  lMagFilter  : LongWord;
  lMinFilter  : LongWord;
  lMipFilter  : LongWord;
  lWrap       : LongWord;
  // Buffers
  newTriangle  : Boolean;
  newTriangleC : Integer;
  bColor       : TD3DColor;
  bTVertices   : array of TXYZCTVertex; // Textured
  bTVCount     : Integer;
  bPVertices   : array of TXYZCVertex;  // Primitives
  bPVCount     : Integer;
  // Scissor
  ScissorEnabled : Boolean;
  ScissorX : Integer;
  ScissorY : Integer;
  ScissorW : Integer;
  ScissorH : Integer;

procedure glClear;
begin
  glViewPort( 0, 0, wnd_Width, wnd_Height );
  if mask and GL_DEPTH_BUFFER_BIT > 0 Then
    d3d8_Device.Clear( 0, nil, D3DCLEAR_ZBUFFER, D3DCOLOR_XRGB( 0, 0, 0 ), 1, 0 );
  if mask and GL_STENCIL_BUFFER_BIT > 0 Then
    d3d8_Device.Clear( 0, nil, D3DCLEAR_STENCIL, D3DCOLOR_XRGB( 0, 0, 0 ), 1, 0 );
  if mask and GL_COLOR_BUFFER_BIT > 0 Then
    d3d8_Device.Clear( 0, nil, D3DCLEAR_TARGET, D3DCOLOR_XRGB( 0, 0, 0 ), 1, 0 );
  SetCurrentMode;
end;

procedure glBegin;
begin
  case Mode of
    GL_POINTS: RenderMode := D3DPT_POINTLIST;
    GL_LINES: RenderMode := D3DPT_LINELIST;
    GL_TRIANGLES: RenderMode := D3DPT_TRIANGLELIST;
    GL_TRIANGLE_STRIP: RenderMode := D3DPT_TRIANGLESTRIP;
    GL_QUADS:
      begin
        RenderQuad := TRUE;
        RenderMode := D3DPT_TRIANGLELIST;
      end;
  end;
end;

procedure glEnd;
  label _end;
  var
    i, Count : Integer;
begin
  if RenderQuad Then
    begin
      if RenderTextured Then
      begin
        INC( bTVCount );
        if bTVCount + 1 > length( bTVertices ) Then SetLength( bTVertices, bTVCount + 1 );
        bTVertices[ bTVCount - 1 ] := bTVertices[ 0 ];
      end else
        begin
          INC( bPVCount );
          if bPVCount + 1 > length( bPVertices ) Then SetLength( bPVertices, bPVCount + 1 );
          bPVertices[ bPVCount - 1 ] := bPVertices[ 0 ];
        end;
    end;

  if RenderTextured Then
    Count := bTVCount
  else
    Count := bPVCount;

  if Count = 0 Then goto _end;

  case RenderMode of
    D3DPT_POINTLIST:;
    D3DPT_LINELIST: Count := Count div 2;
    D3DPT_TRIANGLELIST: Count := Count div 3;
    D3DPT_TRIANGLESTRIP:;
    D3DPT_TRIANGLEFAN:;
  end;

  if RenderTextured Then
    begin
      d3d8_Device.SetVertexShader( D3DFVF_XYZCT );
      d3d8_Device.DrawPrimitiveUP( RenderMode, Count, @bTVertices[ 0 ], s_D3DFVF_XYZCT );
    end else
      begin
        d3d8_Device.SetVertexShader( D3DFVF_XYZC );
        d3d8_Device.DrawPrimitiveUP( RenderMode, Count, @bPVertices[ 0 ], s_D3DFVF_XYZC );
      end;

_end:
  bTVCount := 0;
  bPVCount := 0;
  RenderQuad := FALSE;
  newTriangle := FALSE;
  newTriangleC := 0;
end;

procedure glEnable;
begin
  case cap of
    GL_TEXTURE_2D: RenderTextured := TRUE;
    GL_BLEND: d3d8_Device.SetRenderState( D3DRS_ALPHABLENDENABLE, iTRUE );
    GL_ALPHA_TEST: d3d8_Device.SetRenderState( D3DRS_ALPHATESTENABLE, iTRUE );
    GL_DEPTH_TEST: d3d8_Device.SetRenderState( D3DRS_ZENABLE, D3DZB_TRUE );
    GL_SCISSOR_TEST: ScissorEnabled := TRUE;
    GL_LINE_SMOOTH, GL_POLYGON_SMOOTH: d3d8_Device.SetRenderState( D3DRS_EDGEANTIALIAS, iTRUE );
  end;
end;

procedure glDisable;
begin
  case cap of
    GL_TEXTURE_2D:
      begin
        RenderTextured := FALSE;
        d3d8_Device.SetTexture( 0, nil );
      end;
    GL_BLEND: d3d8_Device.SetRenderState( D3DRS_ALPHABLENDENABLE, iFALSE );
    GL_ALPHA_TEST: d3d8_Device.SetRenderState( D3DRS_ALPHATESTENABLE, iFALSE );
    GL_DEPTH_TEST: d3d8_Device.SetRenderState( D3DRS_ZENABLE, D3DZB_FALSE );
    GL_SCISSOR_TEST:
      begin
        ScissorEnabled := FALSE;
        SetCurrentMode;
      end;
    GL_LINE_SMOOTH, GL_POLYGON_SMOOTH: d3d8_Device.SetRenderState( D3DRS_EDGEANTIALIAS, iFALSE );
  end;
end;

procedure glViewport;
begin
  if not ScissorEnabled Then
    begin
      d3d8_Viewport.X      := X;
      d3d8_Viewport.Y      := Y;
      d3d8_Viewport.Width  := Width;
      d3d8_Viewport.Height := Height;
      if ogl_Mode = 2 Then
        begin
          d3d8_Viewport.MinZ := -1;
          d3d8_Viewport.MaxZ := 1;
        end else
          begin
            d3d8_Viewport.MinZ := ogl_zNear;
            d3d8_Viewport.MaxZ := ogl_zFar;
          end;
      d3d8_Device.SetViewport( d3d8_Viewport );
    end else
      begin
        glDisable( GL_DEPTH_TEST );
        glMatrixMode( GL_PROJECTION );
        glLoadIdentity;
        glOrtho( ScissorX, ScissorX + ScissorW, ScissorY + ScissorH, ScissorY, -1, 1 );
        glMatrixMode( GL_MODELVIEW );
        glLoadIdentity;
        if app_Flags and CORRECT_RESOLUTION > 0 Then
          begin
            glTranslatef( scr_AddCX, scr_AddCY, 0 );
            glScalef( scr_ResCX, scr_ResCY, 1 );
          end;

        ScissorEnabled := FALSE;
        glViewPort( ScissorX, ScissorY, ScissorW, ScissorH );
        ScissorEnabled := TRUE;
      end;
end;

procedure glOrtho;
begin
  glFrustum( -left - 0.5, -right - 0.5, -bottom - 0.5, -top - 0.5, zNear, zFar );
  d3d8_Device.SetTransform( d3d8_MatrixMode, d3d8_Matrices[ d3d8_MatrixMode ] );
end;

procedure glScissor;
begin
  ScissorX := x;
  ScissorY := -( y + height - wnd_Height );
  if ScissorX < scr_AddCX Then
    begin
      ScissorW := ScissorX + width - scr_AddCX;
      ScissorX := scr_AddCX;
    end else ScissorW := width;
  if ScissorY < scr_AddCY Then
    begin
      ScissorH := ScissorY + height - scr_AddCY;
      ScissorY := scr_AddCY;
    end else ScissorH := height;

  if ScissorX + ScissorW > wnd_Width - scr_AddCX Then
    ScissorW := wnd_Width - ScissorX - scr_AddCX;
  if ScissorY + ScissorH > wnd_Height - scr_AddCY Then
    ScissorH := wnd_Height - ScissorY - scr_AddCY; 

  if ScissorX >= ScissorW Then exit;
  if ScissorY >= ScissorH Then exit;

  glViewPort( 0, 0, 0, 0 );
end;

procedure glColor4ub;
begin
  bColor := D3DCOLOR_ARGB( alpha, red, green, blue );
end;

procedure glColor4f;
begin
  bColor := D3DCOLOR_ARGB( Round( alpha * 255 ), Round( red * 255 ), Round( green * 255 ), Round( blue * 255 ) );
end;

procedure glAlphaFunc;
  var
    value : LongWord;
begin
  case func of
    GL_NEVER:    value := D3DCMP_NEVER;
    GL_LESS:     value := D3DCMP_LESS;
    GL_EQUAL:    value := D3DCMP_EQUAL;
    GL_LEQUAL:   value := D3DCMP_LESSEQUAL;
    GL_GREATER:  value := D3DCMP_GREATER;
    GL_NOTEQUAL: value := D3DCMP_NOTEQUAL;
    GL_GEQUAL:   value := D3DCMP_GREATEREQUAL;
    GL_ALWAYS:   value := D3DCMP_ALWAYS;
  end;

  d3d8_Device.SetRenderState( D3DRS_ALPHAREF,  Trunc( ref * 255 ) );
  d3d8_Device.SetRenderState( D3DRS_ALPHAFUNC, value );
end;

procedure glBlendFunc;
  var
    src, dest : LongWord;
begin
  case sfactor of
    GL_ZERO:                src := D3DBLEND_ZERO;
    GL_ONE:                 src := D3DBLEND_ONE;
    GL_SRC_COLOR:           src := D3DBLEND_SRCCOLOR;
    GL_ONE_MINUS_SRC_COLOR: src := D3DBLEND_INVSRCCOLOR;
    GL_SRC_ALPHA:           src := D3DBLEND_SRCALPHA;
    GL_ONE_MINUS_SRC_ALPHA: src := D3DBLEND_INVSRCALPHA;
    GL_DST_ALPHA:           src := D3DBLEND_DESTALPHA;
    GL_ONE_MINUS_DST_ALPHA: src := D3DBLEND_INVDESTALPHA;
    GL_DST_COLOR:           src := D3DBLEND_DESTCOLOR;
    GL_ONE_MINUS_DST_COLOR: src := D3DBLEND_INVDESTCOLOR;
    GL_SRC_ALPHA_SATURATE:  src := D3DBLEND_SRCALPHASAT;
  end;

  case dfactor of
    GL_ZERO:                dest := D3DBLEND_ZERO;
    GL_ONE:                 dest := D3DBLEND_ONE;
    GL_SRC_COLOR:           dest := D3DBLEND_SRCCOLOR;
    GL_ONE_MINUS_SRC_COLOR: dest := D3DBLEND_INVSRCCOLOR;
    GL_SRC_ALPHA:           dest := D3DBLEND_SRCALPHA;
    GL_ONE_MINUS_SRC_ALPHA: dest := D3DBLEND_INVSRCALPHA;
    GL_DST_ALPHA:           dest := D3DBLEND_DESTALPHA;
    GL_ONE_MINUS_DST_ALPHA: dest := D3DBLEND_INVDESTALPHA;
    GL_DST_COLOR:           dest := D3DBLEND_DESTCOLOR;
    GL_ONE_MINUS_DST_COLOR: dest := D3DBLEND_INVDESTCOLOR;
    GL_SRC_ALPHA_SATURATE:  dest := D3DBLEND_SRCALPHASAT;
  end;

  d3d8_Device.SetRenderState( D3DRS_SRCBLEND,  src );
  d3d8_Device.SetRenderState( D3DRS_DESTBLEND, dest );
end;

procedure glMatrixMode;
begin  case mode of
    GL_MODELVIEW:  d3d8_MatrixMode := D3DTS_VIEW;
    GL_PROJECTION: d3d8_MatrixMode := D3DTS_PROJECTION;
    GL_TEXTURE:    d3d8_MatrixMode := D3DTS_TEXTURE0;
  end;
end;

procedure glLoadIdentity;
begin
  with d3d8_Matrices[ d3d8_MatrixMode ] do
    begin
      _11 := 1;
      _12 := 0;
      _13 := 0;
      _14 := 0;

      _21 := 0;
      _22 := 1;
      _23 := 0;
      _24 := 0;

      _31 := 0;
      _32 := 0;
      _33 := 1;
      _34 := 0;

      _41 := 0;
      _42 := 0;
      _43 := 0;
      _44 := 1;
    end;
  d3d8_Device.SetTransform( d3d8_MatrixMode, d3d8_Matrices[ d3d8_MatrixMode ] );
end;

procedure gluPerspective(fovy, aspect, zNear, zFar: GLdouble);
  var
    xmax, ymax : Single;
begin
  ymax := zNear * tan( FOVY * pi / 360 );
  xmax := ymax * aspect;

  glFrustum( -xmax, xmax, -ymax, ymax, zNear, zFar );
  d3d8_Device.SetTransform( d3d8_MatrixMode, d3d8_Matrices[ d3d8_MatrixMode ] );
end;

procedure glFrustum;
begin
  with d3d8_Matrices[ d3d8_MatrixMode ] do
    begin
      _11 := ( zNear * 2 ) / ( Right - Left );
      _12 := 0;
      _13 := 0;
      _14 := 0;

      _21 := 0;
      _22 := ( zNear * 2 ) / ( Top - Bottom );
      _23 := 0;
      _24 := 0;

      _31 := ( Right + Left ) / ( Right - Left );
      _32 := ( Top + Bottom ) / ( Top - Bottom );
      _33 := -( zFar + zNear ) / ( zFar - zNear );
      _34 := -1;

      _41 := 0;
      _42 := 0;
      _43 := -( zFar * zNear * 2 ) / ( zFar - zNear );
      _44 := 0;
    end;
end;

procedure glScalef;
begin
  with d3d8_Matrices[ d3d8_MatrixMode ] do
    begin
      _11 := x * _11;
      _12 := x * _12;
      _13 := x * _13;
      _14 := x * _14;

      _21 := y * _21;
      _22 := y * _22;
      _23 := y * _23;
      _24 := y * _24;

      _31 := z * _31;
      _32 := z * _32;
      _33 := z * _33;
      _34 := z * _34;
    end;
  d3d8_Device.SetTransform( d3d8_MatrixMode, d3d8_Matrices[ d3d8_MatrixMode ] );
end;

procedure glTranslatef;
begin
  with d3d8_Matrices[ d3d8_MatrixMode ] do
    begin
      _41 := x;
      _42 := y;
      _43 := z;
      _44 := 1;
    end;
  d3d8_Device.SetTransform( d3d8_MatrixMode, d3d8_Matrices[ d3d8_MatrixMode ] );
end;

procedure glVertex2f;
begin
  if RenderTextured Then
    begin
      bTVertices[ bTVCount - 1 ].z := -1;
      bTVertices[ bTVCount - 1 ].c := bColor;
      bTVertices[ bTVCount - 1 ].x := x;
      bTVertices[ bTVCount - 1 ].y := y;
      if RenderQuad Then
        begin
          if newTriangle Then
            begin
              INC( bTVCount );
              if bTVCount + 1 > length( bTVertices ) Then SetLength(  bTVertices, bTVCount + 1 );
              bTVertices[ bTVCount - 1 ] :=  bTVertices[ bTVCount - 2 ];
              newTriangle := FALSE;
            end;
          if newTriangleC = 4 Then
            begin
              newTriangleC := 0;
              INC( bTVCount );
              if bTVCount + 1 > length( bTVertices ) Then SetLength( bTVertices, bTVCount + 1 );
              bTVertices[ bTVCount - 1 ] := bTVertices[ bTVCount - 6 ];
            end;
        end;
    end else
      begin
        if bPVCount + 1 > length( bPVertices ) Then SetLength( bPVertices, bPVCount + 1 );
        bPVertices[ bPVCount ].z := -1;
        bPVertices[ bPVCount ].c := bColor;
        bPVertices[ bPVCount ].x := x;
        bPVertices[ bPVCount ].y := y;
        INC( bPVCount );
        if RenderQuad Then
          begin
            INC( newTriangleC );
            if newTriangleC = 3 Then newTriangle := TRUE;
            if newTriangle Then
              begin
                INC( bPVCount );
                if bPVCount + 1 > length( bPVertices ) Then SetLength(  bPVertices, bPVCount + 1 );
                bPVertices[ bPVCount - 1 ] :=  bPVertices[ bPVCount - 2 ];
                newTriangle := FALSE;
              end;
            if newTriangleC = 4 Then
              begin
                newTriangleC := 0;
                INC( bPVCount );
                if bPVCount + 1 > length( bPVertices ) Then SetLength( bPVertices, bPVCount + 1 );
                bPVertices[ bPVCount - 1 ] := bPVertices[ bPVCount - 6 ];
              end;
          end;
      end;
end;

procedure glVertex2fv;
begin
  if RenderTextured Then
    begin
      bTVertices[ bTVCount - 1 ].z := -1;
      bTVertices[ bTVCount - 1 ].c := bColor;
      bTVertices[ bTVCount - 1 ].x := zglPPoint2D( v ).X;
      bTVertices[ bTVCount - 1 ].y := zglPPoint2D( v ).Y;
      if RenderQuad Then
        begin
          if newTriangle Then
            begin
              INC( bTVCount );
              if bTVCount + 1 > length( bTVertices ) Then SetLength(  bTVertices, bTVCount + 1 );
              bTVertices[ bTVCount - 1 ] :=  bTVertices[ bTVCount - 2 ];
              newTriangle := FALSE;
            end;
          if newTriangleC = 4 Then
            begin
              newTriangleC := 0;
              INC( bTVCount );
              if bTVCount + 1 > length( bTVertices ) Then SetLength( bTVertices, bTVCount + 1 );
              bTVertices[ bTVCount - 1 ] := bTVertices[ bTVCount - 6 ];
            end;
        end;
    end else
      begin
        if bPVCount + 1 > length( bPVertices ) Then SetLength( bPVertices, bPVCount + 1 );
        bPVertices[ bPVCount ].z := -1;
        bPVertices[ bPVCount ].c := bColor;
        bPVertices[ bPVCount ].x := zglPPoint2D( v ).X;
        bPVertices[ bPVCount ].y := zglPPoint2D( v ).Y;
        INC( bPVCount );
        if RenderQuad Then
          begin
            INC( newTriangleC );
            if newTriangleC = 3 Then newTriangle := TRUE;
            if newTriangle Then
              begin
                INC( bPVCount );
                if bPVCount + 1 > length( bPVertices ) Then SetLength(  bPVertices, bPVCount + 1 );
                bPVertices[ bPVCount - 1 ] :=  bPVertices[ bPVCount - 2 ];
                newTriangle := FALSE;
              end;
            if newTriangleC = 4 Then
              begin
                newTriangleC := 0;
                INC( bPVCount );
                if bPVCount + 1 > length( bPVertices ) Then SetLength( bPVertices, bPVCount + 1 );
                bPVertices[ bPVCount - 1 ] := bPVertices[ bPVCount - 6 ];
              end;
          end;
      end;
end;

procedure glBindTexture;
begin
  if texture >= d3d8_texCount Then
    begin
      d3d8_Device.SetTexture( 0, nil );
      exit;
    end;

  if d3d8_texArray[ texture ].MagFilter > 0 Then
    d3d8_Device.SetTextureStageState( 0, D3DTSS_MAGFILTER, d3d8_texArray[ texture ].MagFilter );
  if d3d8_texArray[ texture ].MinFilter > 0 Then
    d3d8_Device.SetTextureStageState( 0, D3DTSS_MINFILTER, d3d8_texArray[ texture ].MinFilter );
  if d3d8_texArray[ texture ].MipFilter > 0 Then
    d3d8_Device.SetTextureStageState( 0, D3DTSS_MIPFILTER, d3d8_texArray[ texture ].MipFilter );
  if ogl_Anisotropy > 0 Then
    d3d8_Device.SetTextureStageState( 0, D3DTSS_MAXANISOTROPY, ogl_Anisotropy );
  case  d3d8_texArray[ texture ].Wrap of
    GL_CLAMP_TO_EDGE:
      begin
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
      end;
    GL_REPEAT:
      begin
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
      end;
  end;

  RenderTexID := texture;
  d3d8_Device.SetTexture( 0, d3d8_texArray[ texture ].Texture );
end;

procedure glGenTextures;
  var
    i : Integer;
begin
  RenderTexID := -1;
  for i := 0 to d3d8_texCount - 1 do
    if d3d8_texArray[ i ].Texture = nil Then
      begin
        RenderTexID := i;
        break;
      end;

  if RenderTexID = -1 Then
    begin
      INC( d3d8_texCount );
      SetLength( d3d8_texArray, d3d8_texCount );
      RenderTexID := d3d8_texCount - 1;
    end else RenderTexID := RenderTexID;
  textures^ := RenderTexID;
end;

procedure glDeleteTextures;
begin
  if textures^ >= d3d8_texCount Then exit;

  if Assigned( d3d8_texArray[ textures^ ].Texture ) Then
    d3d8_texArray[ textures^ ].Texture := nil;

  textures^ := 0;
end;

procedure glTexParameterf;
  var
    _type : TD3DTextureStageStateType;
    value : LongWord;
begin
  if pname = GL_TEXTURE_MAX_ANISOTROPY_EXT Then
    begin
      d3d8_Device.SetTextureStageState( 0, D3DTSS_MAGFILTER, D3DTEXF_ANISOTROPIC );
      d3d8_Device.SetTextureStageState( 0, D3DTSS_MINFILTER, D3DTEXF_ANISOTROPIC );
      d3d8_Device.SetTextureStageState( 0, D3DTSS_MIPFILTER, D3DTEXF_ANISOTROPIC );
      d3d8_Device.SetTextureStageState( 0, D3DTSS_MAXANISOTROPY, ogl_Anisotropy );
      lMinFilter  := D3DTEXF_ANISOTROPIC;
      lMagFilter  := D3DTEXF_ANISOTROPIC;
      lMipFilter  := D3DTEXF_ANISOTROPIC;
      exit;
    end;

  case pname of
    GL_TEXTURE_MIN_FILTER: _type := D3DTSS_MINFILTER;
    GL_TEXTURE_MAG_FILTER: _type := D3DTSS_MAGFILTER;
  end;

  case Round( param ) of
    GL_NEAREST: value := D3DTEXF_POINT;
    GL_LINEAR: value := D3DTEXF_LINEAR;
    GL_LINEAR_MIPMAP_NEAREST: value := D3DTEXF_FLATCUBIC;
    GL_LINEAR_MIPMAP_LINEAR: value := D3DTEXF_GAUSSIANCUBIC;
  end;

  case pname of
    GL_TEXTURE_MIN_FILTER: lMinFilter := value;
    GL_TEXTURE_MAG_FILTER: lMagFilter := value;
  end;

  d3d8_Device.SetTextureStageState( 0, _type, value );
end;

procedure glTexParameteri;
  var
    _type : TD3DTextureStageStateType;
    value : LongWord;
begin
  case pname of
    GL_TEXTURE_WRAP_S: _type := D3DTSS_ADDRESSU;
    GL_TEXTURE_WRAP_T: _type := D3DTSS_ADDRESSV;
  end;

  case param of
    GL_CLAMP_TO_EDGE: value := D3DTADDRESS_CLAMP;
    GL_REPEAT: value := D3DTADDRESS_WRAP;
  end;

  lWrap := param;
  d3d8_Device.SetTextureStageState( 0, _type, value );
end;

procedure FillTexture( Src, Dest : Pointer; W, H, P : Integer );
  var
    i : Integer;
    D, S : LongWord;
begin
  D := Ptr( Dest );
  S := Ptr( Src );
  if P = 3 Then
    begin
      for i := 0 to W * H - 1 do
        begin
          PByte( D + 2 )^ :=  PByte( S + 0 )^;
          PByte( D + 1 )^ :=  PByte( S + 1 )^;
          PByte( D + 0 )^ :=  PByte( S + 2 )^;
          PByte( D + 3 )^ :=  255;
          INC( D, 4{P} );
          INC( S, P );
        end;
    end else
      for i := 0 to W * H - 1 do
        begin
          PByte( D + 2 )^ :=  PByte( S + 0 )^;
          PByte( D + 1 )^ :=  PByte( S + 1 )^;
          PByte( D + 0 )^ :=  PByte( S + 2 )^;
          PByte( D + 3 )^ :=  PByte( S + 3 )^;
          INC( D, P );
          INC( S, P );
        end;
end;

procedure glTexImage2D;
  var
    fmt  : TD3DFormat;
    size : Integer;
    r    : TD3DLockedRect;
begin
  case format of
    GL_RGB:
      begin
        fmt  := D3DFMT_X8R8G8B8;
        size := 3;
      end;
    GL_RGBA:
      begin
        fmt  := D3DFMT_A8R8G8B8;
        size := 4;
      end;
  end;

  if target = GL_TEXTURE_2D Then
    begin
      d3d8_texArray[ RenderTexID ].MagFilter  := lMagFilter;
      d3d8_texArray[ RenderTexID ].MinFilter  := lMinFilter;
      d3d8_texArray[ RenderTexID ].MipFilter  := lMipFilter;
      d3d8_texArray[ RenderTexID ].Wrap       := lWrap;
      if d3d8_Device.CreateTexture( width, height, 1, 0, fmt, D3DPOOL_MANAGED, d3d8_texArray[ RenderTexID ].Texture ) <> D3D_OK Then
        begin
          log_Add( 'Can''t CreateTexture' );
          exit;
        end;
      d3d8_texArray[ RenderTexID ].Texture.LockRect( 0, r, nil, D3DLOCK_DISCARD );
      FillTexture( pixels, r.pBits, width, height, size );
      d3d8_texArray[ RenderTexID ].Texture.UnlockRect( 0 );
    end;
end;

procedure glGetTexImage;
  var
    r : TD3DLockedRect;
    d : TD3DSurface_Desc;
begin
  if ( RenderTexID > d3d8_texCount ) or
     ( not Assigned( d3d8_texArray[ RenderTexID ].Texture ) ) Then exit;

  d3d8_texArray[ RenderTexID ].Texture.GetLevelDesc( 0, d );
  d3d8_texArray[ RenderTexID ].Texture.LockRect( 0, r, nil, D3DLOCK_READONLY or D3DLOCK_DISCARD );
  Move( r.pBits^, pixels^, d.Width * d.Height * 4 );
  d3d8_texArray[ RenderTexID ].Texture.UnlockRect( 0 );
end;

procedure glCopyTexSubImage2D;
begin
end;

procedure glTexEnvi;
begin
  if ( target = GL_TEXTURE_ENV ) and
     ( pname = GL_TEXTURE_ENV_MODE ) and
     ( param = GL_MODULATE ) Then
    begin
      d3d8_Device.SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
      d3d8_Device.SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
      d3d8_Device.SetTextureStageState( 0, D3DTSS_COLORARG2, D3DTA_DIFFUSE );

      d3d8_Device.SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
      d3d8_Device.SetTextureStageState( 0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE );
      d3d8_Device.SetTextureStageState( 0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE );
    end;
end;

function gluBuild2DMipmaps;
  var
    fmt  : TD3DFormat;
    size : Integer;
    r    : TD3DLockedRect;
begin
  case format of
    GL_RGB:
      begin
        fmt  := D3DFMT_X8R8G8B8;
        size := 3;
      end;
    GL_RGBA:
      begin
        fmt  := D3DFMT_A8R8G8B8;
        size := 4;
      end;
  end;

  if target = GL_TEXTURE_2D Then
    begin
      d3d8_texArray[ d3d8_texCount - 1 ].MagFilter  := lMagFilter;
      d3d8_texArray[ d3d8_texCount - 1 ].MinFilter  := lMinFilter;
      d3d8_texArray[ d3d8_texCount - 1 ].MipFilter  := lMipFilter;
      d3d8_texArray[ d3d8_texCount - 1 ].Wrap       := lWrap;
      d3d8_Device.CreateTexture( width, height, 0, 0, fmt, D3DPOOL_MANAGED, d3d8_texArray[ d3d8_texCount - 1 ].Texture );
      d3d8_texArray[ d3d8_texCount - 1 ].Texture.LockRect( 0, r, nil, D3DLOCK_DISCARD );
      FillTexture( data, r.pBits, width, height, size );
      d3d8_texArray[ d3d8_texCount - 1 ].Texture.UnlockRect( 0 );
    end;
end;

procedure glTexCoord2f;
begin
  if bTVCount + 1 > length( bTVertices ) Then SetLength( bTVertices, bTVCount + 1 );
  bTVertices[ bTVCount ].u := s;
  bTVertices[ bTVCount ].v := t;
  INC( bTVCount );
  INC( newTriangleC );

  if newTriangleC = 3 then
    newTriangle := TRUE;
end;

procedure glTexCoord2fv;
begin
  if bTVCount + 1 > length( bTVertices ) Then SetLength( bTVertices, bTVCount + 1 );
  bTVertices[ bTVCount ].u := zglPPoint2D( v ).X;
  bTVertices[ bTVCount ].v := zglPPoint2D( v ).Y;
  INC( bTVCount );
  INC( newTriangleC );

  if newTriangleC = 3 then
    newTriangle := TRUE;
end;

end.
