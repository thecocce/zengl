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
unit zgl_direct3d;

{$I zgl_config.cfg}

interface
uses
  Windows,
  {$IFDEF USE_DIRECT3D8}
  DirectXGraphics
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  Direct3D9
  {$ENDIF}
  ;

function  d3d_Create : Boolean;
procedure d3d_Destroy;
function  d3d_Restore : Boolean;
procedure d3d_ResetState;
{$IFDEF USE_DIRECT3D8}
function  d3d_GetFormatID( Format : DWORD ) : DWORD;
{$ENDIF}
{$IFDEF USE_DIRECT3D9}
function  d3d_GetFormatID( Format : TD3DFormat ) : DWORD;
{$ENDIF}
function  d3d_CheckFSAA : TD3DMultiSampleType;

function  d3d_BeginScene : Boolean;
procedure d3d_EndScene;

procedure Set2DMode;
procedure Set3DMode( const FOVY : Single = 45 );
procedure SetCurrentMode;

procedure zbuffer_SetDepth( const zNear, zFar : Single );
procedure zbuffer_Clear;

procedure scissor_Begin( X, Y, Width, Height : Integer );
procedure scissor_End;

var
  {$IFDEF USE_DIRECT3D8}
  d3d          : IDirect3D8;
  d3d_Device   : IDirect3DDevice8;
  d3d_Surface  : IDirect3DSurface8;
  d3d_Stencil  : IDirect3DSurface8;
  d3d_Viewport : TD3DViewport8;
  d3d_Caps     : TD3DCaps8;
  d3d_Adapter  : TD3DAdapterIdentifier8;
  d3d_Mode     : TD3DDisplayMode;
  d3d_Format   : TD3DFormat = D3DFMT_UNKNOWN;
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  d3d          : IDirect3D9;
  d3d_Device   : IDirect3DDevice9;
  d3d_Surface  : IDirect3DSurface9;
  d3d_Stencil  : IDirect3DSurface9;
  d3d_Viewport : TD3DViewport9;
  d3d_Caps     : TD3DCaps9;
  d3d_Adapter  : TD3DAdapterIdentifier9;
  d3d_Mode     : TD3DDisplayMode;
  d3d_Format   : TD3DFormat = D3DFMT_UNKNOWN;
  {$ENDIF}

  d3d_Params   : TD3DPresentParameters;
  d3d_ParamsW  : TD3DPresentParameters;
  d3d_ParamsF  : TD3DPresentParameters;

  d3d_CanDraw : Boolean;

  ogl_zDepth     : Byte;
  ogl_Stencil    : Byte;
  ogl_FSAA       : Byte;
  ogl_Anisotropy : Byte;
  ogl_FOVY       : Single = 45;
  ogl_zNear      : Single = 0.1;
  ogl_zFar       : Single = 100;
  ogl_MTexActive : array[ 0..8 ] of Boolean;
  ogl_MTexture   : array[ 0..8 ] of DWORD;
  ogl_Separate   : Boolean;

  ogl_Mode : WORD = 3; // 2D/3D Modes

  ogl_Width  : Integer;
  ogl_Height : Integer;
  ogl_CropX  : Integer;
  ogl_CropY  : Integer;
  ogl_CropW  : Integer;
  ogl_CropH  : Integer;
  ogl_CropR  : Integer;

  ogl_CanCompress   : Boolean;
  ogl_MaxTexSize    : Integer;
  ogl_MaxAnisotropy : Integer;

implementation
uses
  zgl_direct3d_all,
  zgl_application,
  zgl_main,
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

function d3d_Create;
  var
    i, modeCount : Integer;
begin
  Result := FALSE;

  {$IFDEF USE_DIRECT3D8}
  d3d := Direct3DCreate8( D3D_SDK_VERSION );
  if not Assigned( d3d ) Then
    begin
      u_Error( 'Direct3DCreate8 Error' );
      exit;
    end else log_Add( 'Direct3DCreate8' );

  d3d.GetAdapterIdentifier( D3DADAPTER_DEFAULT, D3DENUM_NO_WHQL_LEVEL, d3d_Adapter );
  log_Add( 'D3D8_RENDERER: ' + d3d_Adapter.Description );
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  d3d := Direct3DCreate9( D3D_SDK_VERSION );
  if not Assigned( d3d ) Then
    begin
      u_Error( 'Direct3DCreate9 Error' );
      exit;
    end else log_Add( 'Direct3DCreate9' );

  d3d.GetAdapterIdentifier( D3DADAPTER_DEFAULT, 0, d3d_Adapter );
  log_Add( 'D3D9_RENDERER: ' + d3d_Adapter.Description );
  {$ENDIF}

  d3d.GetDeviceCaps( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, d3d_Caps );
  ogl_MaxTexSize    := d3d_Caps.MaxTextureWidth;
  ogl_MaxAnisotropy := d3d_Caps.MaxAnisotropy;
  {$IFDEF USE_DIRECT3D8}
  log_Add( 'D3D8_MAX_TEXTURE_SIZE: ' + u_IntToStr( ogl_MaxTexSize ) );
  log_Add( 'D3D8_MAX_TEXTURE_ANISOTROPY: ' + u_IntToStr( ogl_MaxAnisotropy ) );
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  log_Add( 'D3D9_MAX_TEXTURE_SIZE: ' + u_IntToStr( ogl_MaxTexSize ) );
  log_Add( 'D3D9_MAX_TEXTURE_ANISOTROPY: ' + u_IntToStr( ogl_MaxAnisotropy ) );
  {$ENDIF}

  {$IFDEF USE_DIRECT3D8}
  ogl_Separate := FALSE;
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  ogl_Separate := d3d_Caps.PrimitiveMiscCaps and D3DPMISCCAPS_SEPARATEALPHABLEND > 0;
  log_Add( 'D3DPMISCCAPS_SEPARATEALPHABLEND: ' + u_BoolToStr( ogl_Separate ) );
  {$ENDIF}

  // Windowed
  if ( d3d.GetAdapterDisplayMode( D3DADAPTER_DEFAULT, d3d_Mode ) <> D3D_OK ) or ( d3d_Mode.Format = D3DFMT_UNKNOWN ) Then
    begin
      u_Warning( 'GetAdapterDisplayMode = D3DFMT_UNKNOWN' );
      if not wnd_FullScreen Then exit;
    end;

  FillChar( d3d_ParamsW, SizeOf( TD3DPresentParameters ), 0 );
  with d3d_ParamsW do
    begin
      BackBufferWidth  := wnd_Width;
      BackBufferHeight := wnd_Height;
      BackBufferFormat := d3d_Mode.Format;
      BackBufferCount  := 1;
      MultiSampleType  := D3DMULTISAMPLE_NONE;
      hDeviceWindow    := wnd_Handle;
      Windowed         := TRUE;
      {$IFDEF USE_DIRECT3D8}
      if scr_VSync Then
        SwapEffect := D3DSWAPEFFECT_COPY_VSYNC
      else
        SwapEffect := D3DSWAPEFFECT_COPY;
      {$ENDIF}
      {$IFDEF USE_DIRECT3D9}
      SwapEffect := D3DSWAPEFFECT_COPY;
      if scr_VSync Then
        PresentationInterval := D3DPRESENT_INTERVAL_ONE
      else
        PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
      {$ENDIF}
      EnableAutoDepthStencil := TRUE;
      AutoDepthStencilFormat := D3DFMT_D16;
    end;

  // FullScreen
  {$IFDEF USE_DIRECT3D8}
  modeCount := d3d.GetAdapterModeCount( D3DADAPTER_DEFAULT );
  for i := 0 to modeCount - 1 do
    begin
      d3d.EnumAdapterModes( D3DADAPTER_DEFAULT, i, d3d_Mode );
      if ( d3d_Mode.Width <> scr_Width ) or ( d3d_Mode.Height <> scr_Height) Then continue;
      if ( scr_BPP = 16 ) and ( d3d_GetFormatID( d3d_Mode.Format ) > d3d_GetFormatID( D3DFMT_A1R5G5B5 ) ) Then continue;
      if ( d3d_GetFormatID( d3d_Mode.Format ) > d3d_GetFormatID( d3d_Format ) ) Then d3d_Format := d3d_Mode.Format;
    end;
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  d3d.GetAdapterDisplayMode( D3DADAPTER_DEFAULT, d3d_Mode );
  d3d_Format := d3d_Mode.Format;
  modeCount := d3d.GetAdapterModeCount( D3DADAPTER_DEFAULT, d3d_Format );
  for i := 0 to modeCount - 1 do
    begin
      d3d.EnumAdapterModes( D3DADAPTER_DEFAULT, d3d_Format, i, d3d_Mode );
      if ( d3d_Mode.Width <> scr_Width ) or ( d3d_Mode.Height <> scr_Height) Then continue;
      if ( scr_BPP = 16 ) and ( d3d_GetFormatID( d3d_Mode.Format ) > d3d_GetFormatID( D3DFMT_A1R5G5B5 ) ) Then continue;
      if ( d3d_GetFormatID( d3d_Mode.Format ) > d3d_GetFormatID( d3d_Format ) ) Then d3d_Format := d3d_Mode.Format;
    end;
  {$ENDIF}

  if ( d3d_Format = D3DFMT_UNKNOWN ) and wnd_FullScreen Then
    begin
      u_Warning( 'Cannot set fullscreen mode' );
      wnd_FullScreen := FALSE;
      exit;
    end;

  FillChar( d3d_ParamsF, SizeOf( TD3DPresentParameters ), 0 );
  with d3d_ParamsF do
    begin
      BackBufferWidth  := scr_Width;
      BackBufferHeight := scr_Height;
      BackBufferFormat := d3d_Format;
      BackBufferCount  := 1;
      MultiSampleType  := d3d_CheckFSAA;
      hDeviceWindow    := wnd_Handle;
      Windowed         := FALSE;
      SwapEffect       := D3DSWAPEFFECT_DISCARD;
      {$IFDEF USE_DIRECT3D8}
      FullScreen_RefreshRateInHz := D3DPRESENT_RATE_DEFAULT;
      if scr_VSync Then
        FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_ONE
      else
        FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
      {$ENDIF}
      {$IFDEF USE_DIRECT3D9}
      SwapEffect := D3DSWAPEFFECT_COPY;
      if scr_VSync Then
        PresentationInterval := D3DPRESENT_INTERVAL_ONE
      else
        PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
      {$ENDIF}
      EnableAutoDepthStencil := TRUE;
      AutoDepthStencilFormat := D3DFMT_D16;
    end;

  if wnd_FullScreen Then
    d3d_Params := d3d_ParamsF
  else
    d3d_Params := d3d_ParamsW;

  if d3d_GetFormatID( d3d_Params.BackBufferFormat ) < 4 Then
    scr_BPP := 16
  else
    scr_BPP := 32;

  // D3D Device
  // D3DCREATE_HARDWARE_VERTEXPROCESSING
  if d3d.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, wnd_Handle, $40 or D3DCREATE_FPU_PRESERVE, d3d_Params, d3d_Device ) <> D3D_OK Then
    begin
      //D3DCREATE_SOFTWARE_VERTEXPROCESSING
      if d3d.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, wnd_Handle, $20 or D3DCREATE_FPU_PRESERVE, d3d_Params, d3d_Device ) <> D3D_OK Then
        begin
          //D3DCREATE_PUREDEVICE
          if d3d.CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, wnd_Handle, $10 or D3DCREATE_FPU_PRESERVE, d3d_Params, d3d_Device ) <> D3D_OK Then
            begin
              u_Error( 'Can''t create d3d device' );
              exit;
            end else log_Add( 'D3DCREATE_PUREDEVICE' );
        end else log_Add( 'D3DCREATE_SOFTWARE_VERTEXPROCESSING' );
    end else log_Add( 'D3DCREATE_HARDWARE_VERTEXPROCESSING' );

  //
  gl_Vertex2f    := @glVertex2f;
  gl_Vertex2fv   := @glVertex2fv;
  gl_TexCoord2f  := @glTexCoord2f;
  gl_TexCoord2fv := @glTexCoord2fv;

  d3d_ResetState;

  Result := TRUE;
end;

procedure d3d_Destroy;
  var
    i : Integer;
begin
  for i := 0 to d3d_texCount - 1 do
    d3d_texArray[ i ].Texture := nil;
  SetLength( d3d_texArray, 0 );

  //d3d_Device._Release;
  d3d_Device := nil;
  //d3d._Release;
  d3d        := nil;
end;

function d3d_Restore;
  var
    r   : zglPRenderTarget;
    t   : zglPTexture;
    d   : TD3DSurface_Desc;
    fmt : TD3DFormat;
begin
  Result := FALSE;
  if not Assigned( d3d_Device ) Then exit;

  r := managerRTarget.First.Next;
  while Assigned( r ) do
    begin
      r.Handle.Depth := nil;
      r := r.Next;
    end;
  t := managerTexture.First.Next;
  while Assigned( t ) do
    begin
      d3d_texArray[ t.ID ].Texture.GetLevelDesc( 0, d );
      if d.Pool = D3DPOOL_DEFAULT Then
        d3d_texArray[ t.ID ].Texture := nil;
      t := t.Next;
    end;

  d3d_ParamsW.BackBufferWidth  := wnd_Width;
  d3d_ParamsW.BackBufferHeight := wnd_Height;
  d3d_ParamsF.BackBufferWidth  := scr_Width;
  d3d_ParamsF.BackBufferHeight := scr_Height;
  d3d_ParamsF.MultiSampleType  := d3d_CheckFSAA;
  {$IFDEF USE_DIRECT3D8}
  if scr_VSync Then
    begin
      d3d_ParamsW.SwapEffect := D3DSWAPEFFECT_COPY_VSYNC;
      d3d_ParamsF.FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_ONE
    end else
      begin
        d3d_ParamsW.SwapEffect := D3DSWAPEFFECT_COPY;
        d3d_ParamsF.FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
      end;
  {$ENDIF}
  {$IFDEF USE_DIRECT3D9}
  if scr_VSync Then
    begin
      d3d_ParamsW.PresentationInterval := D3DPRESENT_INTERVAL_ONE;
      d3d_ParamsF.PresentationInterval := D3DPRESENT_INTERVAL_ONE;
    end else
      begin
        d3d_ParamsW.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
        d3d_ParamsF.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
      end;
  {$ENDIF}

  if wnd_FullScreen Then
    d3d_Params := d3d_ParamsF
  else
    d3d_Params := d3d_ParamsW;

  if d3d_GetFormatID( d3d_Params.BackBufferFormat ) < 4 Then
    scr_BPP := 16
  else
    scr_BPP := 32;

  d3d_Device.Reset( d3d_Params );
  d3d_ResetState;

  r := managerRTarget.First.Next;
  while Assigned( r ) do
    begin
      {$IFDEF USE_DIRECT3D8}
      d3d_Device.CreateDepthStencilSurface( Round( r.Surface.Width / r.Surface.U ), Round( r.Surface.Height / r.Surface.V ), d3d_Params.AutoDepthStencilFormat,
                                            D3DMULTISAMPLE_NONE, r.Handle.Depth );
      {$ENDIF}
      {$IFDEF USE_DIRECT3D9}
      d3d_Device.CreateDepthStencilSurface( Round( r.Surface.Width / r.Surface.U ), Round( r.Surface.Height / r.Surface.V ), d3d_Params.AutoDepthStencilFormat,
                                            D3DMULTISAMPLE_NONE, 0, TRUE, r.Handle.Depth, nil );
      {$ENDIF}
      r := r.Next;
    end;
  t := managerTexture.First.Next;
  while Assigned( t ) do
    begin
      if t.Flags and TEX_RGB > 0 Then
        fmt := D3DFMT_X8R8G8B8
      else
        fmt := D3DFMT_A8R8G8B8;
      if not Assigned( d3d_texArray[ t.ID ].Texture ) Then
        begin
          {$IFDEF USE_DIRECT3D8}
          d3d_Device.CreateTexture( Round( t.Width / t.U ), Round( t.Height / t.V ), 1, D3DUSAGE_RENDERTARGET, fmt, D3DPOOL_DEFAULT,
                                    d3d_texArray[ t.ID ].Texture );
          {$ENDIF}
          {$IFDEF USE_DIRECT3D9}
          d3d_Device.CreateTexture( Round( t.Width / t.U ), Round( t.Height / t.V ), 1, D3DUSAGE_RENDERTARGET, fmt, D3DPOOL_DEFAULT,
                                    d3d_texArray[ t.ID ].Texture, nil );
          {$ENDIF}
          rtarget_Restore( t );
        end;
      t := t.Next;
    end;

  Result := TRUE;
end;

procedure d3d_ResetState;
begin
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
  glAlphaFunc( GL_GREATER, 0 );

  {$IFDEF USE_DIRECT3D9}
  if ogl_Separate Then
    begin
      d3d_Device.SetRenderState( D3DRS_SEPARATEALPHABLENDENABLE, iTRUE );
      d3d_Device.SetRenderState( D3DRS_BLENDOP,        D3DBLENDOP_ADD );
      d3d_Device.SetRenderState( D3DRS_BLENDOPALPHA,   D3DBLENDOP_ADD );
      d3d_Device.SetRenderState( D3DRS_SRCBLENDALPHA,  D3DBLEND_ONE );
      d3d_Device.SetRenderState( D3DRS_DESTBLENDALPHA, D3DBLEND_INVSRCALPHA);
    end;
  {$ENDIF}

  glDisable( GL_BLEND );
  glDisable( GL_ALPHA_TEST );
  glDisable( GL_DEPTH_TEST );
  glDisable( GL_TEXTURE_2D );

  glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );

  d3d_Device.SetRenderState( D3DRS_CULLMODE, D3DCULL_NONE );
  d3d_Device.SetRenderState( D3DRS_LIGHTING, iFALSE );
end;

function d3d_GetFormatID;
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

function d3d_CheckFSAA;
  var
    fsaa : Integer;
begin
  fsaa := ogl_FSAA;
  if ( fsaa = 0 ) or ( fsaa = 1 ) Then
    Result := D3DMULTISAMPLE_NONE;
  if fsaa > 16 Then
    fsaa := 16;
  if wnd_FullScreen Then
    begin
      {$IFDEF USE_DIRECT3D8}
      while d3d.CheckDeviceMultiSampleType( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, d3d_Format, FALSE, TD3DMultiSampleType( fsaa ) ) <> D3D_OK do
      {$ENDIF}
      {$IFDEF USE_DIRECT3D9}
      while d3d.CheckDeviceMultiSampleType( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, d3d_Format, FALSE, TD3DMultiSampleType( fsaa ), nil ) <> D3D_OK do
      {$ENDIF}
        begin
          if fsaa = 1 Then break;
          DEC( fsaa );
        end;
    end else
      {$IFDEF USE_DIRECT3D8}
      while d3d.CheckDeviceMultiSampleType( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, d3d_Mode.Format, TRUE, TD3DMultiSampleType( fsaa ) ) <> D3D_OK do
      {$ENDIF}
      {$IFDEF USE_DIRECT3D9}
      while d3d.CheckDeviceMultiSampleType( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, d3d_Mode.Format, TRUE, TD3DMultiSampleType( fsaa ), nil ) <> D3D_OK do
      {$ENDIF}
        begin
          if fsaa = 1 Then break;
          DEC( fsaa );
        end;

  Result := TD3DMultiSampleType( fsaa );
end;

function d3d_BeginScene;
  var
    hr : HRESULT;
begin
  if d3d_CanDraw Then
    begin
      Result := TRUE;
      exit;
    end else
      Result := FALSE;

  hr := d3d_Device.TestCooperativeLevel;
  case hr of
    D3DERR_DEVICELOST: exit;
    D3DERR_DEVICENOTRESET:
      begin
        if not wnd_FullScreen Then
          begin
            if ( d3d.GetAdapterDisplayMode( D3DADAPTER_DEFAULT, d3d_Mode ) <> D3D_OK ) or ( d3d_Mode.Format = D3DFMT_UNKNOWN ) Then
              begin
                u_Warning( 'GetAdapterDisplayMode = D3DFMT_UNKNOWN' );
                exit;
              end;

            d3d_ParamsW.BackBufferFormat := d3d_Mode.Format;
          end;

        d3d_Restore;
        exit;
      end;
  end;

  if d3d_Device.BeginScene <> D3D_OK Then exit;
  d3d_CanDraw := TRUE;

  Result := TRUE;
end;

procedure d3d_EndScene;
begin
  d3d_CanDraw := FALSE;
  d3d_Device.EndScene;
  d3d_Device.Present( nil, nil, 0, nil );
end;

procedure Set2DMode;
begin
  if cam2dApply Then cam2d_Apply( nil );
  if ogl_Mode <> 1 Then ogl_Mode := 2;

  glDisable( GL_DEPTH_TEST );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity;
  if ogl_Mode = 2 Then
    begin
      if app_Flags and CORRECT_RESOLUTION > 0 Then
        glOrtho( 0, Round( ogl_Width - scr_AddCX * 2 / scr_ResCX ), Round( ogl_Height - scr_AddCY * 2 / scr_ResCY ), 0, -1, 1 )
      else
        glOrtho( 0, wnd_Width, wnd_Height, 0, -1, 1 );
    end else
      glOrtho( 0, rtWidth, rtHeight, 0, -1, 1 );
  glMatrixMode( GL_MODELVIEW );
  glLoadIdentity;
  scr_SetViewPort;
end;

procedure Set3DMode;
begin
  if cam2dApply Then cam2d_Apply( nil );
  if ogl_Mode <> 1 Then ogl_Mode := 3;
  ogl_FOVY := FOVY;

  glColor4ub( 255, 255, 255, 255 );

  glEnable( GL_DEPTH_TEST );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity;
  gluPerspective( ogl_FOVY, ogl_Width / ogl_Height, ogl_zNear, ogl_zFar );
  glMatrixMode( GL_MODELVIEW );
  glLoadIdentity;
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
  if tSCount - 1 < 0 Then
    exit;
  DEC( tSCount );
  ogl_CropX := tScissor[ tSCount ][ 0 ];
  ogl_CropY := tScissor[ tSCount ][ 1 ];
  ogl_CropW := tScissor[ tSCount ][ 2 ];
  ogl_CropH := tScissor[ tSCount ][ 3 ];
  SetLength( tScissor, tSCount );

  if tSCount > 0 Then
    begin
      glEnable( GL_SCISSOR_TEST );
      glScissor( ogl_CropX, wnd_Height - ogl_CropY - ogl_CropH, ogl_CropW, ogl_CropH );
    end else
      glDisable( GL_SCISSOR_TEST );
end;

end.
