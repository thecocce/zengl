{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru-kun.inf.ua
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
unit zgl_direct3d_all;

{$I zgl_config.cfg}

interface
uses
  {$IFDEF USE_DIRECT3D8}
  DirectXGraphics
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  Direct3D9
  {$ENDIF}
  ;

const
  libGLU = 'glu32.dll';

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
  GL_TRIANGLE_FAN                   = $0006;
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

  GL_COMBINE_ARB                    = $8570;
  GL_COMBINE_RGB_ARB                = $8571;
  GL_COMBINE_ALPHA_ARB              = $8572;
  GL_SOURCE0_RGB_ARB                = $8580;
  GL_SOURCE1_RGB_ARB                = $8581;
  GL_SOURCE2_RGB_ARB                = $8582;
  GL_SOURCE0_ALPHA_ARB              = $8588;
  GL_SOURCE1_ALPHA_ARB              = $8589;
  GL_SOURCE2_ALPHA_ARB              = $858A;
  GL_OPERAND0_RGB_ARB               = $8590;
  GL_OPERAND1_RGB_ARB               = $8591;
  GL_OPERAND2_RGB_ARB               = $8592;
  GL_OPERAND0_ALPHA_ARB             = $8598;
  GL_OPERAND1_ALPHA_ARB             = $8599;
  GL_OPERAND2_ALPHA_ARB             = $859A;
  GL_RGB_SCALE_ARB                  = $8573;
  GL_ADD_SIGNED_ARB                 = $8574;
  GL_INTERPOLATE_ARB                = $8575;
  GL_SUBTRACT_ARB                   = $84E7;
  GL_CONSTANT_ARB                   = $8576;
  GL_PRIMARY_COLOR_ARB              = $8577;
  GL_PREVIOUS_ARB                   = $8578;

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

  // StencilOp
  GL_KEEP                           = $1E00;
  GL_REPLACE                        = $1E01;
  GL_INCR                           = $1E02;
  GL_DECR                           = $1E03;

  // Triangulation
  GLU_TESS_BEGIN                    = $18704;
  GLU_TESS_VERTEX                   = $18705;
  GLU_TESS_END                      = $18706;
  GLU_TESS_ERROR                    = $18707;
  GLU_TESS_EDGE_FLAG                = $18708;
  GLU_TESS_COMBINE                  = $18709;
  GLU_TESS_BEGIN_DATA               = $1870A;
  GLU_TESS_VERTEX_DATA              = $1870B;
  GLU_TESS_END_DATA                 = $1870C;
  GLU_TESS_ERROR_DATA               = $1870D;
  GLU_TESS_EDGE_FLAG_DATA           = $1870E;
  GLU_TESS_COMBINE_DATA             = $1870F;

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
  zglD3DTexture = record
    Texture    : {$IFDEF USE_DIRECT3D8} IDirect3DTexture8 {$ENDIF}
                 {$IFDEF USE_DIRECT3D9} IDirect3DTexture9 {$ENDIF};
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
procedure glColor4ub(red, green, blue, alpha: GLubyte); {$IFDEF USE_INLINE} inline; {$ENDIF}
procedure glColor4ubv(v: PGLubyte); {$IFDEF USE_INLINE} inline; {$ENDIF}
procedure glColor4f(red, green, blue, alpha: GLfloat); {$IFDEF USE_INLINE} inline; {$ENDIF}
procedure glColorMask(red, green, blue, alpha: GLboolean); {$IFDEF USE_INLINE} inline; {$ENDIF}
// Alpha
procedure glAlphaFunc(func: GLenum; ref: GLclampf);
procedure glBlendFunc(sfactor, dfactor: GLenum);
// Matrix
procedure glPushMatrix;
procedure glPopMatrix;
procedure glMatrixMode(mode: GLenum);
procedure glLoadIdentity;
procedure gluPerspective(fovy, aspect, zNear, zFar: GLdouble);
procedure glFrustum(left, right, bottom, top, zNear, zFar: GLdouble);
procedure glRotatef(angle, x, y, z: GLfloat);
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
// Triangulation
procedure gluDeleteTess(tess: Integer); stdcall external libGLU;
function  gluErrorString(error: Integer): PChar; stdcall external libGLU;
function  gluNewTess: Integer; stdcall external libGLU;
procedure gluTessBeginContour(tess: Integer); stdcall external libGLU;
procedure gluTessBeginPolygon(tess: Integer; data: Pointer); stdcall external libGLU;
procedure gluTessCallback(tess: Integer; which: Integer; fn: Pointer); stdcall external libGLU;
procedure gluTessEndContour(tess: Integer); stdcall external libGLU;
procedure gluTessEndPolygon(tess: Integer); stdcall external libGLU;
procedure gluTessVertex(tess: Integer; vertex: PDouble; data: Pointer); stdcall external libGLU;

var
  gl_TexCoord2f   : procedure( U, V : Single );
  gl_TexCoord2fv  : procedure( Coord : PSingle );
  gl_Vertex2f     : procedure( X, Y : Single );
  gl_Vertex2fv    : procedure( v : PSingle );
  d3d_texCount    : Integer;
  d3d_texArray    : array of zglD3DTexture;
  {$IFDEF USE_DIRECT3D8}
  d3d_resArray    : array of IDirect3DTexture8;
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  d3d_resArray    : array of IDirect3DSurface9;
  {$ENDIF}
  d3d_Matrices    : array[ 0..23 ] of TD3DMatrix;
  d3d_MatrixMode  : {$IFDEF USE_DIRECT3D8} LongWord {$ENDIF}
                    {$IFDEF USE_DIRECT3D9} TD3DTransformStateType {$ENDIF};

implementation
uses
  zgl_direct3d,
  zgl_application,
  zgl_main,
  zgl_screen,
  zgl_window,
  zgl_render_target,
  zgl_textures,
  zgl_log,
  zgl_math_2d,
  zgl_types,
  math;

var
  RenderMode     : TD3DPrimitiveType;
  {RenderQuad     : Boolean;}
  RenderTextured : Boolean;
  RenderTexID    : Integer;
  // Matrices
  popMatrices : array of array[ 0..23 ] of TD3DMatrix;
  pushCount   : Integer;
  // Textures
  lMagFilter  : LongWord;
  lMinFilter  : LongWord;
  lMipFilter  : LongWord;
  lWrap       : LongWord;
  // Buffers
  {newTriangle  : Boolean;
  newTriangleC : Integer;}
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
    d3d_Device.Clear( 0, nil, D3DCLEAR_ZBUFFER, D3DCOLOR_XRGB( 0, 0, 0 ), 1, 0 );
  if mask and GL_STENCIL_BUFFER_BIT > 0 Then
    d3d_Device.Clear( 0, nil, D3DCLEAR_STENCIL, D3DCOLOR_XRGB( 0, 0, 0 ), 1, 0 );
  if mask and GL_COLOR_BUFFER_BIT > 0 Then
    d3d_Device.Clear( 0, nil, D3DCLEAR_TARGET, D3DCOLOR_ARGB( 0, 0, 0, 0 ), 1, 0 );
  SetCurrentMode;
end;

procedure glBegin;
begin
  bTVCount := 0;
  bPVCount := 0;
  {RenderQuad := FALSE;
  newTriangle := FALSE;
  newTriangleC := 0;}

  case Mode of
    GL_POINTS: RenderMode := D3DPT_POINTLIST;
    GL_LINES: RenderMode := D3DPT_LINELIST;
    GL_TRIANGLES: RenderMode := D3DPT_TRIANGLELIST;
    GL_TRIANGLE_STRIP: RenderMode := D3DPT_TRIANGLESTRIP;
    {GL_QUADS:
      begin
        RenderQuad := TRUE;
        RenderMode := D3DPT_TRIANGLELIST;
      end;}
  end;
end;

procedure glEnd;
  var
    Count : Integer;
begin
  {if RenderQuad Then
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
    end;}

  if RenderTextured Then
    Count := bTVCount
  else
    Count := bPVCount;

  if Count = 0 Then exit;

  case RenderMode of
    D3DPT_POINTLIST:;
    D3DPT_LINELIST: Count := Count div 2;
    D3DPT_TRIANGLELIST: Count := Count div 3;
    D3DPT_TRIANGLESTRIP:;
    D3DPT_TRIANGLEFAN:;
  end;

  {$IFDEF USE_DIRECT3D8}
  if RenderTextured Then
    begin
      d3d_Device.SetVertexShader( D3DFVF_XYZCT );
      d3d_Device.DrawPrimitiveUP( RenderMode, Count, @bTVertices[ 0 ], s_D3DFVF_XYZCT );
    end else
      begin
        d3d_Device.SetVertexShader( D3DFVF_XYZC );
        d3d_Device.DrawPrimitiveUP( RenderMode, Count, @bPVertices[ 0 ], s_D3DFVF_XYZC );
      end;
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  if RenderTextured Then
    begin
      d3d_Device.SetFVF( D3DFVF_XYZCT );
      d3d_Device.DrawPrimitiveUP( RenderMode, Count, bTVertices[ 0 ], s_D3DFVF_XYZCT );
    end else
      begin
        d3d_Device.SetFVF( D3DFVF_XYZC );
        d3d_Device.DrawPrimitiveUP( RenderMode, Count, bPVertices[ 0 ], s_D3DFVF_XYZC );
      end;
  {$ENDIF}
end;

procedure glEnable;
begin
  case cap of
    GL_TEXTURE_2D: RenderTextured := TRUE;
    GL_BLEND: d3d_Device.SetRenderState( D3DRS_ALPHABLENDENABLE, iTRUE );
    GL_ALPHA_TEST: d3d_Device.SetRenderState( D3DRS_ALPHATESTENABLE, iTRUE );
    GL_DEPTH_TEST: d3d_Device.SetRenderState( D3DRS_ZENABLE, D3DZB_TRUE );
    GL_SCISSOR_TEST: ScissorEnabled := TRUE;
    {$IFDEF USE_DIRECT3D8}
    // MS sucks again! :)
    GL_LINE_SMOOTH, GL_POLYGON_SMOOTH:;// d3d_Device.SetRenderState( D3DRS_EDGEANTIALIAS, iTRUE );
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    GL_LINE_SMOOTH, GL_POLYGON_SMOOTH:;// d3d_Device.SetRenderState( D3DRS_ANTIALIASEDLINEENABLE, iTRUE );
    {$ENDIF}
  end;
end;

procedure glDisable;
begin
  case cap of
    GL_TEXTURE_2D:
      begin
        RenderTexID    := -1;
        RenderTextured := FALSE;
        d3d_Device.SetTexture( 0, nil );
      end;
    GL_BLEND: d3d_Device.SetRenderState( D3DRS_ALPHABLENDENABLE, iFALSE );
    GL_ALPHA_TEST: d3d_Device.SetRenderState( D3DRS_ALPHATESTENABLE, iFALSE );
    GL_DEPTH_TEST: d3d_Device.SetRenderState( D3DRS_ZENABLE, D3DZB_FALSE );
    GL_SCISSOR_TEST:
      begin
        ScissorEnabled := FALSE;
        SetCurrentMode;
      end;
    {$IFDEF USE_DIRECT3D8}
    GL_LINE_SMOOTH, GL_POLYGON_SMOOTH:;// d3d_Device.SetRenderState( D3DRS_EDGEANTIALIAS, iFALSE );
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    GL_LINE_SMOOTH, GL_POLYGON_SMOOTH:;// d3d_Device.SetRenderState( D3DRS_ANTIALIASEDLINEENABLE, iFALSE );
    {$ENDIF}
  end;
end;

procedure glViewport;
begin
  if not ScissorEnabled Then
    begin
      d3d_Viewport.X      := X;
      d3d_Viewport.Y      := Y;
      d3d_Viewport.Width  := Width;
      d3d_Viewport.Height := Height;
      if ogl_Mode = 2 Then
        begin
          d3d_Viewport.MinZ := -1;
          d3d_Viewport.MaxZ := 1;
        end else
          begin
            d3d_Viewport.MinZ := ogl_zNear;
            d3d_Viewport.MaxZ := ogl_zFar;
          end;
      d3d_Device.SetViewport( d3d_Viewport );
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
  d3d_Device.SetTransform( d3d_MatrixMode, d3d_Matrices[ DWORD( d3d_MatrixMode ) ] );
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

  if ScissorX >= ScissorX + ScissorW Then exit;
  if ScissorY >= ScissorY + ScissorH Then exit;

  glViewPort( 0, 0, 0, 0 );
end;

procedure glColor4ub;
begin
  bColor := D3DCOLOR_ARGB( alpha, red, green, blue );
end;

procedure glColor4ubv;
begin
  bColor := D3DCOLOR_ARGB( PByte( v + 3 )^, PByte( v + 0 )^, PByte( v + 1 )^, PByte( v + 2 )^ );
end;

procedure glColor4f;
begin
  bColor := D3DCOLOR_ARGB( Round( alpha * 255 ), Round( red * 255 ), Round( green * 255 ), Round( blue * 255 ) );
end;

procedure glColorMask;
begin
  d3d_Device.SetRenderState( D3DRS_COLORWRITEENABLE, D3DCOLORWRITEENABLE_RED   * red or
                                                     D3DCOLORWRITEENABLE_GREEN * green or
                                                     D3DCOLORWRITEENABLE_BLUE  * blue or
                                                     D3DCOLORWRITEENABLE_ALPHA * alpha );
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

  d3d_Device.SetRenderState( D3DRS_ALPHAREF,  Trunc( ref * 255 ) );
  d3d_Device.SetRenderState( D3DRS_ALPHAFUNC, value );
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

  d3d_Device.SetRenderState( D3DRS_SRCBLEND,  src );
  d3d_Device.SetRenderState( D3DRS_DESTBLEND, dest );
end;

procedure glPushMatrix;
begin
  INC( pushCount );
  if pushCount > length( popMatrices ) Then
    SetLength( popMatrices, length( popMatrices ) + 16 );

  popMatrices[ pushCount - 1, DWORD( d3d_MatrixMode ) ] := d3d_Matrices[ DWORD( d3d_MatrixMode ) ];
end;

procedure glPopMatrix;
begin
  if pushCount < 1 Then exit;
  d3d_Matrices[ DWORD( d3d_MatrixMode ) ] := popMatrices[ pushCount - 1, DWORD( d3d_MatrixMode ) ];
  d3d_Device.SetTransform( d3d_MatrixMode, d3d_Matrices[ DWORD( d3d_MatrixMode ) ] );
  DEC( pushCount );
end;

procedure glMatrixMode;
begin
  case mode of
    GL_MODELVIEW:  d3d_MatrixMode := D3DTS_VIEW;
    GL_PROJECTION: d3d_MatrixMode := D3DTS_PROJECTION;
    GL_TEXTURE:    d3d_MatrixMode := D3DTS_TEXTURE0;
  end;
end;

procedure glLoadIdentity;
begin
  with d3d_Matrices[ DWORD( d3d_MatrixMode ) ] do
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
  d3d_Device.SetTransform( d3d_MatrixMode, d3d_Matrices[ DWORD( d3d_MatrixMode ) ] );
end;

procedure gluPerspective(fovy, aspect, zNear, zFar: GLdouble);
  var
    xmax, ymax : Single;
begin
  ymax := zNear * tan( FOVY * pi / 360 );
  xmax := ymax * aspect;

  glFrustum( -xmax, xmax, -ymax, ymax, zNear, zFar );
  d3d_Device.SetTransform( d3d_MatrixMode, d3d_Matrices[ DWORD( d3d_MatrixMode ) ] );
end;

procedure glFrustum;
begin
  with d3d_Matrices[ DWORD( d3d_MatrixMode ) ] do
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

procedure glRotatef;
  var
    sa, ca : Single;
    m      : TD3DMatrix;
  function matrix4f_Mul( const m1, m2 : TD3DMatrix ) : TD3DMatrix;
  begin
    Result._11 := m1._11 * m2._11 + m1._12 * m2._21 + m1._13 * m2._31 + m1._14 * m2._41;
    Result._12 := m1._11 * m2._12 + m1._12 * m2._22 + m1._13 * m2._32 + m1._14 * m2._42;
    Result._13 := m1._11 * m2._13 + m1._12 * m2._23 + m1._13 * m2._33 + m1._14 * m2._43;
    Result._14 := m1._11 * m2._14 + m1._12 * m2._24 + m1._13 * m2._34 + m1._14 * m2._44;
    Result._21 := m1._21 * m2._11 + m1._22 * m2._21 + m1._23 * m2._31 + m1._24 * m2._41;
    Result._22 := m1._21 * m2._12 + m1._22 * m2._22 + m1._23 * m2._32 + m1._24 * m2._42;
    Result._23 := m1._21 * m2._13 + m1._22 * m2._23 + m1._23 * m2._33 + m1._24 * m2._43;
    Result._24 := m1._21 * m2._14 + m1._22 * m2._24 + m1._23 * m2._34 + m1._24 * m2._44;
    Result._31 := m1._31 * m2._11 + m1._32 * m2._21 + m1._33 * m2._31 + m1._34 * m2._41;
    Result._32 := m1._31 * m2._12 + m1._32 * m2._22 + m1._33 * m2._32 + m1._34 * m2._42;
    Result._33 := m1._31 * m2._13 + m1._32 * m2._23 + m1._33 * m2._33 + m1._34 * m2._43;
    Result._34 := m1._31 * m2._14 + m1._32 * m2._24 + m1._33 * m2._34 + m1._34 * m2._44;
    Result._41 := m1._41 * m2._11 + m1._42 * m2._21 + m1._43 * m2._31 + m1._44 * m2._41;
    Result._42 := m1._41 * m2._12 + m1._42 * m2._22 + m1._43 * m2._32 + m1._44 * m2._42;
    Result._43 := m1._41 * m2._13 + m1._42 * m2._23 + m1._43 * m2._33 + m1._44 * m2._43;
    Result._44 := m1._41 * m2._14 + m1._42 * m2._24 + m1._43 * m2._34 + m1._44 * m2._44;
  end;
begin
  sa := sin( angle * deg2rad );
  ca := cos( angle * deg2rad );

  with m do
    begin
      _11 := ca + ( 1 - ca ) * x * x;
      _12 := ( 1 - ca ) * x * z + z * sa;
      _13 := ( 1 - ca ) * x * z - y * sa;
      _14 := 0;

      _21 := ( 1 - ca ) * x * y - z * sa;
      _22 := ca + ( 1 - ca ) * y * y;
      _23 := ( 1 - ca ) * y * z + x * sa;
      _24 := 0;

      _31 := ( 1 - ca ) * x * z + y * sa;
      _32 := ( 1 - ca ) * y * z - x * sa;
      _33 := ca + ( 1 - ca ) * z * z;
      _34 := 0;

      _41 := 0;
      _42 := 0;
      _43 := 0;
      _44 := 1;
    end;
  d3d_Matrices[ DWORD( d3d_MatrixMode ) ] := matrix4f_Mul( m, d3d_Matrices[ DWORD( d3d_MatrixMode ) ] );
  d3d_Device.SetTransform( d3d_MatrixMode, d3d_Matrices[ DWORD( d3d_MatrixMode ) ] );
end;

procedure glScalef;
begin
  with d3d_Matrices[ DWORD( d3d_MatrixMode ) ] do
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
  d3d_Device.SetTransform( d3d_MatrixMode, d3d_Matrices[ DWORD( d3d_MatrixMode ) ] );
end;

procedure glTranslatef;
begin
  with d3d_Matrices[ DWORD( d3d_MatrixMode ) ] do
    begin
      _41 := _11 * x + _21 * y + _31 * z + _41;
      _42 := _12 * x + _22 * y + _32 * z + _42;
      _43 := _13 * x + _23 * y + _33 * z + _43;
      _44 := _14 * x + _24 * y + _34 * z + _44;
    end;
  d3d_Device.SetTransform( d3d_MatrixMode, d3d_Matrices[ DWORD( d3d_MatrixMode ) ] );
end;

procedure glVertex2f;
begin
  if RenderTextured Then
    begin
      bTVertices[ bTVCount - 1 ].z := -1;
      bTVertices[ bTVCount - 1 ].c := bColor;
      bTVertices[ bTVCount - 1 ].x := x;
      bTVertices[ bTVCount - 1 ].y := y;
      {if RenderQuad Then
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
        end;}
    end else
      begin
        if bPVCount + 1 > length( bPVertices ) Then SetLength( bPVertices, bPVCount + 1 );
        bPVertices[ bPVCount ].z := -1;
        bPVertices[ bPVCount ].c := bColor;
        bPVertices[ bPVCount ].x := x;
        bPVertices[ bPVCount ].y := y;
        INC( bPVCount );
        {if RenderQuad Then
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
          end;}
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
      {if RenderQuad Then
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
        end;}
    end else
      begin
        if bPVCount + 1 > length( bPVertices ) Then SetLength( bPVertices, bPVCount + 1 );
        bPVertices[ bPVCount ].z := -1;
        bPVertices[ bPVCount ].c := bColor;
        bPVertices[ bPVCount ].x := zglPPoint2D( v ).X;
        bPVertices[ bPVCount ].y := zglPPoint2D( v ).Y;
        INC( bPVCount );
        {if RenderQuad Then
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
          end;}
      end;
end;

procedure glBindTexture;
begin
  if texture >= d3d_texCount Then
    begin
      d3d_Device.SetTexture( 0, nil );
      exit;
    end;

  {$IFDEF USE_DIRECT3D8}
  if d3d_texArray[ texture ].MagFilter > 0 Then
    d3d_Device.SetTextureStageState( 0, D3DTSS_MAGFILTER, d3d_texArray[ texture ].MagFilter );
  if d3d_texArray[ texture ].MinFilter > 0 Then
    d3d_Device.SetTextureStageState( 0, D3DTSS_MINFILTER, d3d_texArray[ texture ].MinFilter );
  if d3d_texArray[ texture ].MipFilter > 0 Then
    d3d_Device.SetTextureStageState( 0, D3DTSS_MIPFILTER, d3d_texArray[ texture ].MipFilter );
  if ogl_Anisotropy > 0 Then
    d3d_Device.SetTextureStageState( 0, D3DTSS_MAXANISOTROPY, ogl_Anisotropy );
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  if d3d_texArray[ texture ].MagFilter > 0 Then
    d3d_Device.SetSamplerState( 0, D3DSAMP_MAGFILTER, d3d_texArray[ texture ].MagFilter );
  if d3d_texArray[ texture ].MinFilter > 0 Then
    d3d_Device.SetSamplerState( 0, D3DSAMP_MINFILTER, d3d_texArray[ texture ].MinFilter );
  if d3d_texArray[ texture ].MipFilter > 0 Then
    d3d_Device.SetSamplerState( 0, D3DSAMP_MIPFILTER, d3d_texArray[ texture ].MipFilter );
  if ogl_Anisotropy > 0 Then
    d3d_Device.SetSamplerState( 0, D3DSAMP_MAXANISOTROPY, ogl_Anisotropy );
  {$ENDIF}

  case  d3d_texArray[ texture ].Wrap of
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
  d3d_Device.SetTexture( 0, d3d_texArray[ texture ].Texture );
end;

procedure glGenTextures;
  var
    i : Integer;
begin
  RenderTexID := -1;
  for i := 0 to d3d_texCount - 1 do
    if d3d_texArray[ i ].Texture = nil Then
      begin
        RenderTexID := i;
        break;
      end;

  if RenderTexID = -1 Then
    begin
      INC( d3d_texCount );
      SetLength( d3d_texArray, d3d_texCount );
      SetLength( d3d_resArray, d3d_texCount );
      RenderTexID := d3d_texCount - 1;
    end else RenderTexID := RenderTexID;
  textures^ := RenderTexID;
end;

procedure glDeleteTextures;
begin
  if textures^ >= d3d_texCount Then exit;

  if Assigned( d3d_texArray[ textures^ ].Texture ) Then
    d3d_texArray[ textures^ ].Texture := nil;

  textures^ := 0;
end;

procedure glTexParameterf;
  label _exit;
  var
    {$IFDEF USE_DIRECT3D8}
    _type : TD3DTextureStageStateType;
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    _type : TD3DSamplerStateType;
    {$ENDIF}
    value : LongWord;
begin
  if pname = GL_TEXTURE_MAX_ANISOTROPY_EXT Then
    begin
      {$IFDEF USE_DIRECT3D8}
      d3d_Device.SetTextureStageState( 0, D3DTSS_MAGFILTER, D3DTEXF_ANISOTROPIC );
      d3d_Device.SetTextureStageState( 0, D3DTSS_MINFILTER, D3DTEXF_ANISOTROPIC );
      d3d_Device.SetTextureStageState( 0, D3DTSS_MIPFILTER, D3DTEXF_ANISOTROPIC );
      d3d_Device.SetTextureStageState( 0, D3DTSS_MAXANISOTROPY, ogl_Anisotropy );
      {$ENDIF}
      {$IFDEF USE_DIRECT3D9}
      d3d_Device.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_ANISOTROPIC );
      d3d_Device.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_ANISOTROPIC );
      d3d_Device.SetSamplerState( 0, D3DSAMP_MIPFILTER, D3DTEXF_ANISOTROPIC );
      d3d_Device.SetSamplerState( 0, D3DSAMP_MAXANISOTROPY, ogl_Anisotropy );
      {$ENDIF}
      lMinFilter  := D3DTEXF_ANISOTROPIC;
      lMagFilter  := D3DTEXF_ANISOTROPIC;
      lMipFilter  := D3DTEXF_ANISOTROPIC;
      goto _exit;
    end;

  case pname of
    {$IFDEF USE_DIRECT3D8}
    GL_TEXTURE_MIN_FILTER: _type := D3DTSS_MINFILTER;
    GL_TEXTURE_MAG_FILTER: _type := D3DTSS_MAGFILTER;
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    GL_TEXTURE_MIN_FILTER: _type := D3DSAMP_MINFILTER;
    GL_TEXTURE_MAG_FILTER: _type := D3DSAMP_MAGFILTER;
    {$ENDIF}
  end;

  case Round( param ) of
    GL_NEAREST: value := D3DTEXF_POINT;
    GL_LINEAR: value := D3DTEXF_LINEAR;
    {$IFDEF USE_DIRECT3D8}
    GL_LINEAR_MIPMAP_NEAREST: value := D3DTEXF_FLATCUBIC;
    GL_LINEAR_MIPMAP_LINEAR:  value := D3DTEXF_GAUSSIANCUBIC;
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    // FIXME:
    GL_LINEAR_MIPMAP_NEAREST: value := D3DTEXF_PYRAMIDALQUAD;
    GL_LINEAR_MIPMAP_LINEAR:  value := D3DTEXF_GAUSSIANQUAD;
    {$ENDIF}
  end;

  case pname of
    GL_TEXTURE_MIN_FILTER: lMinFilter := value;
    GL_TEXTURE_MAG_FILTER: lMagFilter := value;
  end;

  {$IFDEF USE_DIRECT3D8}
  d3d_Device.SetTextureStageState( 0, _type, value );
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  d3d_Device.SetSamplerState( 0, _type, value );
  {$ENDIF}

_exit:
  if RenderTexID <> -1 Then
    begin
      d3d_texArray[ RenderTexID ].MinFilter := lMinFilter;
      d3d_texArray[ RenderTexID ].MagFilter := lMagFilter;
      d3d_texArray[ RenderTexID ].MipFilter := lMipFilter;
    end;
end;

procedure glTexParameteri;
  var
    {$IFDEF USE_DIRECT3D8}
    _type : TD3DTextureStageStateType;
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    _type : TD3DSamplerStateType;
    {$ENDIF}
    value : LongWord;
begin
  case pname of
    {$IFDEF USE_DIRECT3D8}
    GL_TEXTURE_WRAP_S: _type := D3DTSS_ADDRESSU;
    GL_TEXTURE_WRAP_T: _type := D3DTSS_ADDRESSV;
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    GL_TEXTURE_WRAP_S: _type := D3DSAMP_ADDRESSU;
    GL_TEXTURE_WRAP_T: _type := D3DSAMP_ADDRESSV;
    {$ENDIF}
  end;

  case param of
    GL_CLAMP_TO_EDGE: value := D3DTADDRESS_CLAMP;
    GL_REPEAT: value := D3DTADDRESS_WRAP;
  end;

  lWrap := param;
  {$IFDEF USE_DIRECT3D8}
  d3d_Device.SetTextureStageState( 0, _type, value );
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  d3d_Device.SetSamplerState( 0, _type, value );
  {$ENDIF}

  if RenderTexID <> -1 Then
    d3d_texArray[ RenderTexID ].Wrap := lWrap;
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
      d3d_texArray[ RenderTexID ].MagFilter  := lMagFilter;
      d3d_texArray[ RenderTexID ].MinFilter  := lMinFilter;
      d3d_texArray[ RenderTexID ].MipFilter  := lMipFilter;
      d3d_texArray[ RenderTexID ].Wrap       := lWrap;
      {$IFDEF USE_DIRECT3D8}
      if d3d_Device.CreateTexture( width, height, 1, 0, fmt, D3DPOOL_MANAGED, d3d_texArray[ RenderTexID ].Texture ) <> D3D_OK Then
      {$ENDIF}
      {$IFDEF USE_DIRECT3D9}
      if d3d_Device.CreateTexture( width, height, 1, 0, fmt, D3DPOOL_MANAGED, d3d_texArray[ RenderTexID ].Texture, nil ) <> D3D_OK Then
      {$ENDIF}
        begin
          log_Add( 'Can''t CreateTexture' );
          exit;
        end;
      d3d_texArray[ RenderTexID ].Texture.LockRect( 0, r, nil, D3DLOCK_DISCARD );
      FillTexture( pixels, r.pBits, width, height, size );
      d3d_texArray[ RenderTexID ].Texture.UnlockRect( 0 );
    end;
end;

procedure glGetTexImage;
  var
    r : TD3DLockedRect;
    d : TD3DSurface_Desc;
    {$IFDEF USE_DIRECT3D8}
    src, dst : IDirect3DSurface8;
    {$ENDIF}
    {$IFDEF USE_DIRECT3D9}
    src, dst : IDirect3DSurface9;
    {$ENDIF}
begin
  if ( RenderTexID > d3d_texCount ) or
     ( not Assigned( d3d_texArray[ RenderTexID ].Texture ) ) Then exit;

  d3d_texArray[ RenderTexID ].Texture.GetLevelDesc( 0, d );
  if d.Pool = D3DPOOL_MANAGED Then
    begin
      d3d_texArray[ RenderTexID ].Texture.LockRect( 0, r, nil, D3DLOCK_READONLY or D3DLOCK_DISCARD );
      Move( r.pBits^, pixels^, d.Width * d.Height * 4 );
      d3d_texArray[ RenderTexID ].Texture.UnlockRect( 0 );
    end else
      if d.Pool = D3DPOOL_DEFAULT Then
        begin
          d3d_texArray[ RenderTexID ].Texture.GetSurfaceLevel( 0, src );
          {$IFDEF USE_DIRECT3D8}
          d3d_Device.CreateImageSurface( d.Width, d.Height, d.Format, dst );
          d3d_Device.CopyRects( src, nil, 0, dst, nil );
          {$ENDIF}
          {$IFDEF USE_DIRECT3D9}
          d3d_Device.CreateOffscreenPlainSurface( d.Width, d.Height, d.Format, D3DPOOL_SYSTEMMEM, dst, 0 );
          d3d_Device.GetRenderTargetData( src, dst );
          {$ENDIF}

          dst.LockRect( r, nil, D3DLOCK_READONLY );
          Move( r.pBits^, pixels^, d.Width * d.Height * 4 );
          dst.UnlockRect;

          dst := nil;
          src := nil;
        end;
end;

procedure glCopyTexSubImage2D;
begin
end;

procedure glTexEnvi;
  var
    _type : TD3DTextureStageStateType;
    value : LongWord;
begin
  if target <> GL_TEXTURE_ENV Then exit;

  if ( pname = GL_TEXTURE_ENV_MODE ) and ( param = GL_MODULATE ) Then
    begin
      d3d_Device.SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
      d3d_Device.SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
      d3d_Device.SetTextureStageState( 0, D3DTSS_COLORARG2, D3DTA_DIFFUSE );

      d3d_Device.SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_MODULATE );
      d3d_Device.SetTextureStageState( 0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE );
      d3d_Device.SetTextureStageState( 0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE );

      exit;
    end;
  if ( pname = GL_TEXTURE_ENV_MODE ) and ( param = GL_COMBINE_ARB ) Then exit;

  case pname of
    GL_COMBINE_RGB_ARB:   _type := D3DTSS_COLOROP;
    GL_SOURCE0_RGB_ARB:   _type := D3DTSS_COLORARG0;
    GL_SOURCE1_RGB_ARB:   _type := D3DTSS_COLORARG1;
    GL_SOURCE2_RGB_ARB:   _type := D3DTSS_COLORARG2;
    GL_COMBINE_ALPHA_ARB: _type := D3DTSS_ALPHAOP;
    GL_SOURCE0_ALPHA_ARB: _type := D3DTSS_ALPHAARG0;
    GL_SOURCE1_ALPHA_ARB: _type := D3DTSS_ALPHAARG1;
    GL_SOURCE2_ALPHA_ARB: _type := D3DTSS_ALPHAARG2;
  end;

  case param of
    GL_REPLACE:           value := 25; // Хммм...
    GL_MODULATE:          value := D3DTOP_MODULATE;
    GL_TEXTURE:           value := D3DTA_TEXTURE;
    GL_PRIMARY_COLOR_ARB: value := D3DTA_DIFFUSE;
  end;

  d3d_Device.SetTextureStageState( 0, _type, value );
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
      d3d_texArray[ d3d_texCount - 1 ].MagFilter  := lMagFilter;
      d3d_texArray[ d3d_texCount - 1 ].MinFilter  := lMinFilter;
      d3d_texArray[ d3d_texCount - 1 ].MipFilter  := lMipFilter;
      d3d_texArray[ d3d_texCount - 1 ].Wrap       := lWrap;
      {$IFDEF USE_DIRECT3D8}
      d3d_Device.CreateTexture( width, height, 0, 0, fmt, D3DPOOL_MANAGED, d3d_texArray[ d3d_texCount - 1 ].Texture );
      {$ENDIF}
      {$IFDEF USE_DIRECT3D9}
      d3d_Device.CreateTexture( width, height, 0, 0, fmt, D3DPOOL_MANAGED, d3d_texArray[ d3d_texCount - 1 ].Texture, nil );
      {$ENDIF}
      d3d_texArray[ d3d_texCount - 1 ].Texture.LockRect( 0, r, nil, D3DLOCK_DISCARD );
      FillTexture( data, r.pBits, width, height, size );
      d3d_texArray[ d3d_texCount - 1 ].Texture.UnlockRect( 0 );
    end;
end;

procedure glTexCoord2f;
begin
  if bTVCount + 1 > length( bTVertices ) Then SetLength( bTVertices, bTVCount + 1 );
  bTVertices[ bTVCount ].u := s;
  bTVertices[ bTVCount ].v := t;
  INC( bTVCount );
  {INC( newTriangleC );

  if newTriangleC = 3 then
    newTriangle := TRUE;}
end;

procedure glTexCoord2fv;
begin
  if bTVCount + 1 > length( bTVertices ) Then SetLength( bTVertices, bTVCount + 1 );
  bTVertices[ bTVCount ].u := zglPPoint2D( v ).X;
  bTVertices[ bTVCount ].v := zglPPoint2D( v ).Y;
  INC( bTVCount );
  {INC( newTriangleC );

  if newTriangleC = 3 then
    newTriangle := TRUE;}
end;

end.
