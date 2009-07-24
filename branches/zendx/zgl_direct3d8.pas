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
unit zgl_direct3d8;

{$I zgl_config.cfg}

interface
uses
  Windows,
  DirectXGraphics;

function  d3d8_Create : Boolean;
procedure d3d8_Destroy;
function  d3d8_Restore : Boolean;
procedure d3d8_ResetState;
function  d3d8_GetFormatID( Format : DWORD ) : DWORD;

function  d3d8_BeginScene : Boolean;
procedure d3d8_EndScene;

procedure Set2DMode;
procedure Set3DMode( const FOVY : Single = 45 );
procedure SetCurrentMode;

procedure zbuffer_SetDepth( const zNear, zFar : Single );
procedure zbuffer_Clear;

procedure scissor_Begin( X, Y, Width, Height : Integer );
procedure scissor_End;

var
  d3d8          : IDirect3D8;
  d3d8_Device   : IDirect3DDevice8;
  d3d8_Surface  : IDirect3DSurface8;
  d3d8_Stencil  : IDirect3DSurface8;
  d3d8_Viewport : TD3DViewport8;
  d3d8_Caps     : TD3DCaps8;
  d3d8_Adapter  : TD3DAdapterIdentifier8;
  d3d8_Mode     : TD3DDisplayMode;
  d3d8_Format   : TD3DFormat = D3DFMT_UNKNOWN;

  d3d8_Params   : TD3DPresentParameters;
  d3d8_ParamsW  : TD3DPresentParameters;
  d3d8_ParamsF  : TD3DPresentParameters;

  d3d8_CanDraw : Boolean;

  ogl_zDepth     : Byte;
  ogl_Stencil    : Byte;
  ogl_FSAA       : Byte;
  ogl_Anisotropy : Byte;
  ogl_FOVY       : Single = 45;
  ogl_zNear      : Single = 0.1;
  ogl_zFar       : Single = 100;
  ogl_MTexActive : array[ 0..8 ] of Boolean;
  ogl_MTexture   : array[ 0..8 ] of DWORD;

  ogl_Mode : WORD = 3; // 2D/3D Modes

  ogl_Width  : Integer;
  ogl_Height : Integer;
  ogl_CropX  : Integer;
  ogl_CropY  : Integer;
  ogl_CropW  : Integer;
  ogl_CropH  : Integer;

  ogl_CanCompress   : Boolean;
  ogl_MaxTexSize    : Integer;
  ogl_MaxAnisotropy : Integer;

implementation
uses
  zgl_const,
  zgl_direct3d8_all,
  zgl_application,
  zgl_screen,
  zgl_window,
  zgl_camera_2d,
  zgl_render_2d,
  zgl_textures,
  zgl_render_target,
  zgl_log,
  zgl_utils;

var
  tSCount  : Integer;
  tScissor : array of array[ 0..3 ] of Integer;

function d3d8_Create;
  var
    i, modeCount : Integer;
begin
  Result := FALSE;

  d3d8 := Direct3DCreate8( D3D_SDK_VERSION );
  if not Assigned( d3d8 ) Then
    begin
      u_Error( 'Direct3DCreate8 Error' );
      exit;
    end else log_Add( 'Direct3DCreate8' );

  d3d8.GetAdapterIdentifier( D3DADAPTER_DEFAULT, D3DENUM_NO_WHQL_LEVEL, d3d8_Adapter );
  log_Add( 'D3D8_RENDERER: ' + d3d8_Adapter.Description );

  d3d8.GetDeviceCaps( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, d3d8_Caps );
  ogl_MaxTexSize    := d3d8_Caps.MaxTextureWidth;
  ogl_MaxAnisotropy := d3d8_Caps.MaxAnisotropy;
  log_Add( 'D3D8_MAX_TEXTURE_SIZE: ' + u_IntToStr( ogl_MaxTexSize ) );
  log_Add( 'D3D8_MAX_TEXTURE_ANISOTROPY: ' + u_IntToStr( ogl_MaxAnisotropy ) );

  // Windowed
  if ( d3d8.GetAdapterDisplayMode( D3DADAPTER_DEFAULT, d3d8_Mode ) <> D3D_OK ) or ( d3d8_Mode.Format = D3DFMT_UNKNOWN ) Then
    begin
      u_Warning( 'GetAdapterDisplayMode = D3DFMT_UNKNOWN' );
      if not wnd_FullScreen Then exit;
    end;

  // FullScreen
  modeCount := d3d8.GetAdapterModeCount( D3DADAPTER_DEFAULT );

  for i := 0 to modeCount - 1 do
    begin
      d3d8.EnumAdapterModes( D3DADAPTER_DEFAULT, i, d3d8_Mode );
      if ( d3d8_Mode.Width <> scr_Width ) or ( d3d8_Mode.Height <> scr_Height) Then continue;
      if ( scr_BPP = 16 ) and ( d3d8_GetFormatID( d3d8_Mode.Format ) > d3d8_GetFormatID( D3DFMT_A1R5G5B5 ) ) Then continue;
      if ( d3d8_GetFormatID( d3d8_Mode.Format ) > d3d8_GetFormatID( d3d8_Format ) ) Then d3d8_Format := d3d8_Mode.Format;
    end;

  if ( d3d8_Format = D3DFMT_UNKNOWN ) and wnd_FullScreen Then
    begin
      u_Warning( 'Cannot set fullscreen mode' );
      wnd_FullScreen := FALSE;
      exit;
    end;

  while d3d8.CheckDeviceMultiSampleType( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, d3d8_Format, not wnd_FullScreen, TD3DMultiSampleType( ogl_FSAA ) ) <> D3D_OK do
    DEC( ogl_FSAA );

  FillChar( d3d8_ParamsW, SizeOf( TD3DPresentParameters ), 0 );
  with d3d8_ParamsW do
    begin
      BackBufferWidth  := wnd_Width;
      BackBufferHeight := wnd_Height;
      BackBufferFormat := d3d8_Mode.Format;
      BackBufferCount  := 1;
      MultiSampleType  := TD3DMultiSampleType( ogl_FSAA );
      hDeviceWindow    := wnd_Handle;
      Windowed         := TRUE;
      if scr_VSync Then
        SwapEffect := D3DSWAPEFFECT_COPY_VSYNC
      else
        SwapEffect := D3DSWAPEFFECT_COPY;
      EnableAutoDepthStencil := TRUE;
      AutoDepthStencilFormat := D3DFMT_D16;
    end;

  FillChar( d3d8_ParamsF, SizeOf( TD3DPresentParameters ), 0 );
  with d3d8_ParamsF do
    begin
      BackBufferWidth  := scr_Width;
      BackBufferHeight := scr_Height;
      BackBufferFormat := d3d8_Format;
      BackBufferCount  := 1;
      MultiSampleType  := TD3DMultiSampleType( ogl_FSAA );
      hDeviceWindow    := wnd_Handle;
      Windowed         := FALSE;
      SwapEffect       := D3DSWAPEFFECT_FLIP;
      FullScreen_RefreshRateInHz := D3DPRESENT_RATE_DEFAULT;
      if scr_VSync Then
        FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_ONE
      else
        FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
      EnableAutoDepthStencil := TRUE;
      AutoDepthStencilFormat := D3DFMT_D16;
    end;

  if wnd_FullScreen Then
    d3d8_Params := d3d8_ParamsF
  else
    d3d8_Params := d3d8_ParamsW;

  if d3d8_GetFormatID( d3d8_Params.BackBufferFormat ) < 4 Then
    scr_BPP := 16
  else
    scr_BPP := 32;

  // D3D Device
  // D3DCREATE_HARDWARE_VERTEXPROCESSING
  if d3d8.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, wnd_Handle, $40 or D3DCREATE_FPU_PRESERVE, d3d8_Params, d3d8_Device ) <> D3D_OK Then
    begin
      //D3DCREATE_SOFTWARE_VERTEXPROCESSING
      if d3d8.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, wnd_Handle, $20 or D3DCREATE_FPU_PRESERVE, d3d8_Params, d3d8_Device ) <> D3D_OK Then
        begin
          //D3DCREATE_PUREDEVICE
          if d3d8.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, wnd_Handle, $10 or D3DCREATE_FPU_PRESERVE, d3d8_Params, d3d8_Device ) <> D3D_OK Then
            begin
              u_Error( 'Can''t create D3D8 device' );
              exit;
            end else log_Add( 'D3DCREATE_PUREDEVICE' );
        end else log_Add( 'D3DCREATE_SOFTWARE_VERTEXPROCESSING' );
    end else log_Add( 'D3DCREATE_HARDWARE_VERTEXPROCESSING' );

  //
  gl_Vertex2f    := @glVertex2f;
  gl_Vertex2fv   := @glVertex2fv;
  gl_TexCoord2f  := @glTexCoord2f;
  gl_TexCoord2fv := @glTexCoord2fv;

  d3d8_ResetState;

  Result := TRUE;
end;

procedure d3d8_Destroy;
begin
  d3d8_Device._Release;
  d3d8_Device := nil;
  d3d8._Release;
  d3d8        := nil;

  d3d8_texCount := 0;
  SetLength( d3d8_texArray, 0 );
end;

function d3d8_Restore;
  var
    r : zglPRenderTarget;
    fmt : TD3DFormat;
begin
  r := managerRTarget.First.Next;
  while Assigned( r ) do
    begin
      glDeleteTextures( 1, @r.Handle.ID );
      r := r.Next;
    end;

  Result := FALSE;
  if not Assigned( d3d8_Device ) Then exit;

  while d3d8.CheckDeviceMultiSampleType( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, d3d8_Format, not wnd_FullScreen, TD3DMultiSampleType( ogl_FSAA ) ) <> D3D_OK do
    DEC( ogl_FSAA );

  d3d8_ParamsW.BackBufferWidth  := wnd_Width;
  d3d8_ParamsW.BackBufferHeight := wnd_Height;
  d3d8_ParamsF.BackBufferWidth  := scr_Width;
  d3d8_ParamsF.BackBufferHeight := scr_Height;
  d3d8_ParamsW.MultiSampleType  := TD3DMultiSampleType( ogl_FSAA );
  d3d8_ParamsF.MultiSampleType  := TD3DMultiSampleType( ogl_FSAA );
  if scr_VSync Then
    begin
      d3d8_ParamsW.SwapEffect := D3DSWAPEFFECT_COPY_VSYNC;
      d3d8_ParamsF.FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_ONE
    end else
      begin
        d3d8_ParamsW.SwapEffect := D3DSWAPEFFECT_COPY;
        d3d8_ParamsF.FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
      end;

  if wnd_FullScreen Then
    d3d8_Params := d3d8_ParamsF
  else
    d3d8_Params := d3d8_ParamsW;

  if d3d8_GetFormatID( d3d8_Params.BackBufferFormat ) < 4 Then
    scr_BPP := 16
  else
    scr_BPP := 32;

  d3d8_Device.Reset( d3d8_Params );

  r := managerRTarget.First.Next;
  while Assigned( r ) do
    begin
      if r.Surface.Flags and TEX_RGB > 0 Then
        fmt := D3DFMT_X8R8G8B8
      else
        fmt := D3DFMT_A8R8G8B8;
      glGenTextures( 1, @r.Handle.ID );
      r.Handle.Flags := r.Handle.Flags or TEX_RESTORE;
      d3d8_Device.CreateTexture( r.Surface.Width, r.Surface.Height, 1,
                                 D3DUSAGE_RENDERTARGET, fmt, D3DPOOL_DEFAULT,
                                 d3d8_texArray[ r.Handle.ID ].Texture );
      r := r.Next;
    end;

  d3d8_ResetState;

  Result := TRUE;
end;

procedure d3d8_ResetState;
begin
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
  glAlphaFunc( GL_GREATER, 0 );

  glDisable( GL_BLEND );
  glDisable( GL_ALPHA_TEST );
  glDisable( GL_DEPTH_TEST );
  glDisable( GL_TEXTURE_2D );

  glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );

  d3d8_Device.SetRenderState( D3DRS_CULLMODE, D3DCULL_NONE );
  d3d8_Device.SetRenderState( D3DRS_LIGHTING, iFALSE );
end;

function d3d8_GetFormatID;
begin
  case Format of
    D3DFMT_R5G6B5:   Result := 1;
    D3DFMT_X1R5G5B5: Result := 2;
    D3DFMT_A1R5G5B5: Result := 3;
    D3DFMT_X8R8G8B8: Result := 4;
    D3DFMT_A8R8G8B8: Result := 5;
  else
    Result := 0;
  end;
end;

function d3d8_BeginScene;
  var
    hr : HRESULT;
begin
  Result := FALSE;

  hr := d3d8_Device.TestCooperativeLevel;
  case hr of
    D3DERR_DEVICELOST: exit;
    D3DERR_DEVICENOTRESET:
      begin
        if not wnd_FullScreen Then
          begin
            if ( d3d8.GetAdapterDisplayMode( D3DADAPTER_DEFAULT, d3d8_Mode ) <> D3D_OK ) or ( d3d8_Mode.Format = D3DFMT_UNKNOWN ) Then
              begin
                u_Warning( 'GetAdapterDisplayMode = D3DFMT_UNKNOWN' );
                exit;
              end;

            d3d8_ParamsW.BackBufferFormat := d3d8_Mode.Format;
          end;

        if not d3d8_Restore Then exit;
      end;
  end;

  if d3d8_Device.BeginScene <> D3D_OK Then exit;

  d3d8_CanDraw := TRUE;

  Result := TRUE;
end;

procedure d3d8_EndScene;
begin
  d3d8_CanDraw := FALSE;
  d3d8_Device.EndScene;
  d3d8_Device.Present( nil, nil, 0, nil );
end;

procedure Set2DMode;
begin
  if ogl_Mode <> 1 Then ogl_Mode := 2;

  glDisable( GL_DEPTH_TEST );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity;
  if app_Flags and CORRECT_RESOLUTION > 0 Then
    glOrtho( 0, ogl_Width - scr_AddCX * 2 / scr_ResCX, ogl_Height - scr_AddCY * 2 / scr_ResCY, 0, -1, 1 )
  else
    glOrtho( 0, wnd_Width, wnd_Height, 0, -1, 1 );
  glMatrixMode( GL_MODELVIEW );
  glLoadIdentity;

  if ogl_Mode = 1 Then
    begin
      glScalef( rt_ScaleW, -rt_ScaleH, 1 );
      glTranslatef( 0, scr_ResH, 0 );
    end;

  scr_SetViewPort;
end;

procedure Set3DMode;
begin
  if ogl_Mode <> 1 Then ogl_Mode := 3;
  ogl_FOVY := FOVY;

  glColor4ub( 255, 255, 255, 255 );

  glEnable( GL_DEPTH_TEST );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity;
  gluPerspective( ogl_FOVY, ogl_Width / ogl_Height, ogl_zNear, ogl_zFar );
  glMatrixMode( GL_MODELVIEW );
  glLoadIdentity;

  if ogl_Mode = 1 Then
    begin
      glScalef( rt_ScaleW, -rt_ScaleH, 1 );
      glTranslatef( 0, scr_ResH, 0 );
    end;

  scr_SetViewPort;
end;

procedure SetCurrentMode;
begin
  if ogl_Mode = 2 Then
    Set2DMode
  else
    Set3DMode( ogl_FOVY );
end;

procedure zbuffer_SetDepth;
begin
  ogl_zNear := zNear;
  ogl_zFar  := zFar;
end;

procedure zbuffer_Clear;
begin
  glClear( GL_DEPTH_BUFFER_BIT );
end;

procedure scissor_Begin;
begin
  if b2d_Started Then
    batch2d_Flush;
  if ( Width < 0 ) or ( Height < 0 ) Then
    exit;
  if cam2DGlobal <> @constCamera2D Then
    begin
      X      := Trunc( ( X - cam2dGlobal.X ) * cam2dGlobal.Zoom.X + ( ( ogl_Width  / 2 ) - ( ogl_Width  / 2 ) * cam2dGlobal.Zoom.X ) );
      Y      := Trunc( ( Y - cam2dGlobal.Y ) * cam2dGlobal.Zoom.Y + ( ( ogl_Height / 2 ) - ( ogl_Height / 2 ) * cam2dGlobal.Zoom.Y ) );
      Width  := Trunc( Width  * cam2DGlobal.Zoom.X );
      Height := Trunc( Height * cam2DGlobal.Zoom.Y );
    end;
  if app_Flags and CORRECT_RESOLUTION > 0 Then
    begin
      X      := Round( X * scr_ResCX + scr_AddCX );
      Y      := Round( Y * scr_ResCY + scr_AddCY );
      Width  := Round( Width * scr_ResCX );
      Height := Round( Height * scr_ResCY );
    end;
  glEnable( GL_SCISSOR_TEST );
  glScissor( X, wnd_Height - Y - Height, Width, Height );

  INC( tSCount );
  SetLength( tScissor, tSCount );
  tScissor[ tSCount - 1 ][ 0 ] := ogl_CropX;
  tScissor[ tSCount - 1 ][ 1 ] := ogl_CropY;
  tScissor[ tSCount - 1 ][ 2 ] := ogl_CropW;
  tScissor[ tSCount - 1 ][ 3 ] := ogl_CropH;

  ogl_CropX := X;
  ogl_CropY := Y;
  ogl_CropW := Width;
  ogl_CropH := Height;
end;

procedure scissor_End;
begin
  if b2d_Started Then
    batch2d_Flush;
  glDisable( GL_SCISSOR_TEST );
  if tSCount - 1 < 0 Then
    exit;
  DEC( tSCount );
  ogl_CropX := tScissor[ tSCount ][ 0 ];
  ogl_CropY := tScissor[ tSCount ][ 1 ];
  ogl_CropW := tScissor[ tSCount ][ 2 ];
  ogl_CropH := tScissor[ tSCount ][ 3 ];
  SetLength( tScissor, tSCount );
end;

end.
