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
unit zgl_screen;

{$I zgl_config.cfg}

interface
uses
  Windows,
  zgl_direct3d,
  zgl_direct3d_all;

const
  REFRESH_MAXIMUM = 0;
  REFRESH_DEFAULT = 1;

procedure scr_Init;
function  scr_Create : Boolean;
procedure scr_GetResList;
procedure scr_Destroy;
procedure scr_Reset;
procedure scr_Clear;
procedure scr_Flush;

procedure scr_SetOptions( Width, Height, Refresh : Word; FullScreen, VSync : Boolean );
procedure scr_CorrectResolution( Width, Height : Word );
procedure scr_SetViewPort;
procedure scr_SetVSync( VSync : Boolean );
procedure scr_SetFSAA( FSAA : Byte );
procedure scr_ReadPixels( var pData : Pointer; X, Y, Width, Height : Word );

type
  zglPResolutionList = ^zglTResolutionList;
  zglTResolutionList = record
    Count  : Integer;
    Width  : array of Integer;
    Height : array of Integer;
end;

var
  scr_Width   : Integer = 800;
  scr_Height  : Integer = 600;
  scr_Refresh : Integer;
  scr_VSync   : Boolean;
  scr_ResList : zglTResolutionList;
  scr_Initialized : Boolean;
  scr_Changing : Boolean;

  // Resolution Correct
  scr_ResW  : Integer;
  scr_ResH  : Integer;
  scr_ResCX : Single  = 1;
  scr_ResCY : Single  = 1;
  scr_AddCX : Integer = 0;
  scr_AddCY : Integer = 0;
  scr_SubCX : Integer = 0;
  scr_SubCY : Integer = 0;

  scr_Settings : DEVMODE;
  scr_Desktop  : DEVMODE;

implementation
uses
  zgl_types,
  zgl_main,
  zgl_application,
  zgl_window,
  zgl_render_2d,
  zgl_camera_2d,
  zgl_log,
  zgl_utils;

function GetDisplayColors : Integer;
  var
    tHDC: hdc;
begin
  tHDC := GetDC( 0 );
  Result := GetDeviceCaps( tHDC, BITSPIXEL ) * GetDeviceCaps( tHDC, PLANES );
  ReleaseDC( 0, tHDC );
end;

function GetDisplayRefresh : Integer;
  var
    tHDC: hdc;
begin
  tHDC := GetDC( 0 );
  Result := GetDeviceCaps( tHDC, VREFRESH );
  ReleaseDC( 0, tHDC );
end;

procedure scr_Init;
begin
  scr_Initialized := TRUE;
  with scr_Desktop do
    begin
      dmSize             := SizeOf( DEVMODE );
      dmPelsWidth        := GetSystemMetrics( SM_CXSCREEN );
      dmPelsHeight       := GetSystemMetrics( SM_CYSCREEN );
      dmBitsPerPel       := GetDisplayColors();
      dmDisplayFrequency := GetDisplayRefresh();
      dmFields           := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL or DM_DISPLAYFREQUENCY;
    end;
end;

function scr_Create : Boolean;
  var
    settings : DEVMODE;
begin
  Result := FALSE;
  scr_Init();
  if scr_Desktop.dmBitsPerPel <> 32 Then
    begin
      settings              := scr_Desktop;
      settings.dmBitsPerPel := 32;

      if ChangeDisplaySettings( settings, CDS_TEST or CDS_FULLSCREEN ) <> DISP_CHANGE_SUCCESSFUL Then
        begin
          u_Error( 'Desktop doesn''t support 32-bit color mode.' );
          zgl_Exit;
        end else
          ChangeDisplaySettings( settings, CDS_FULLSCREEN );
    end;
  log_Add( 'Current mode: ' + u_IntToStr( zgl_Get( DESKTOP_WIDTH ) ) + ' x ' + u_IntToStr( zgl_Get( DESKTOP_HEIGHT ) ) );
  scr_GetResList();
  Result := TRUE;
end;

procedure scr_GetResList;
  var
    i : Integer;
    tmp_Settings : DEVMODE;
  function Already( Width, Height : Integer ) : Boolean;
    var
      j : Integer;
  begin
    Result := FALSE;
    for j := 0 to scr_ResList.Count - 1 do
      if ( scr_ResList.Width[ j ] = Width ) and ( scr_ResList.Height[ j ] = Height ) Then Result := TRUE;
  end;
begin
  i := 0;
  while EnumDisplaySettings( nil, i, tmp_Settings ) <> FALSE do
    begin
      if not Already( tmp_Settings.dmPelsWidth, tmp_Settings.dmPelsHeight ) Then
        begin
          INC( scr_ResList.Count );
          SetLength( scr_ResList.Width, scr_ResList.Count );
          SetLength( scr_ResList.Height, scr_ResList.Count );
          scr_ResList.Width[ scr_ResList.Count - 1 ]  := tmp_Settings.dmPelsWidth;
          scr_ResList.Height[ scr_ResList.Count - 1 ] := tmp_Settings.dmPelsHeight;
        end;
      INC( i );
    end;
end;

procedure scr_Destroy;
begin
  scr_Reset();
end;

procedure scr_Reset;
begin
end;

procedure scr_Clear;
begin
  batch2d_Flush();
  glClear( GL_COLOR_BUFFER_BIT * Byte( app_Flags and COLOR_BUFFER_CLEAR > 0 ) or GL_DEPTH_BUFFER_BIT * Byte( app_Flags and DEPTH_BUFFER_CLEAR > 0 ) or
           GL_STENCIL_BUFFER_BIT * Byte( app_Flags and STENCIL_BUFFER_CLEAR > 0 ) );
end;

procedure scr_Flush;
begin
  batch2d_Flush();
end;

procedure scr_SetOptions( Width, Height, Refresh : Word; FullScreen, VSync : Boolean );
begin
  scr_Changing   := TRUE;
  ogl_Width      := Width;
  ogl_Height     := Height;
  wnd_Width      := Width;
  wnd_Height     := Height;
  wnd_FullScreen := FullScreen;
  scr_Vsync      := VSync;

  if Height >= zgl_Get( DESKTOP_HEIGHT ) Then
    wnd_FullScreen := TRUE;
  if wnd_FullScreen Then
    begin
      scr_Width  := Width;
      scr_Height := Height;
    end else
      begin
        scr_Width   := zgl_Get( DESKTOP_WIDTH );
        scr_Height  := zgl_Get( DESKTOP_HEIGHT );
        scr_Refresh := GetDisplayRefresh;
      end;

  if not app_Initialized Then exit;
  scr_SetVSync( scr_VSync );

  if Assigned( d3d_Device ) Then
    glClear( GL_COLOR_BUFFER_BIT );

  if wnd_FullScreen Then
    log_Add( 'Screen options changed to: ' + u_IntToStr( scr_Width ) + ' x ' + u_IntToStr( scr_Height ) + ' fullscreen' )
  else
    log_Add( 'Screen options changed to: ' + u_IntToStr( wnd_Width ) + ' x ' + u_IntToStr( wnd_Height ) + ' windowed' );
  if app_Work Then
    wnd_Update();
end;

procedure scr_CorrectResolution( Width, Height : Word );
begin
  scr_ResW  := Width;
  scr_ResH  := Height;
  scr_ResCX := wnd_Width  / Width;
  scr_ResCY := wnd_Height / Height;

  if scr_ResCX < scr_ResCY Then
    begin
      scr_AddCX := 0;
      scr_AddCY := Round( ( wnd_Height - Height * scr_ResCX ) / 2 );
      scr_ResCY := scr_ResCX;
    end else
      begin
        scr_AddCX := Round( ( wnd_Width - Width * scr_ResCY ) / 2 );
        scr_AddCY := 0;
        scr_ResCX := scr_ResCY;
      end;

  if app_Flags and CORRECT_HEIGHT = 0 Then
    begin
      scr_ResCY := wnd_Height / Height;
      scr_AddCY := 0;
    end;
  if app_Flags and CORRECT_WIDTH = 0 Then
    begin
      scr_ResCX := wnd_Width / Width;
      scr_AddCX := 0;
    end;

  ogl_Width  := Round( wnd_Width / scr_ResCX );
  ogl_Height := Round( wnd_Height / scr_ResCY );
  scr_SubCX  := ogl_Width - Width;
  scr_SubCY  := ogl_Height - Height;
  SetCurrentMode();

  cam2dZoomX := cam2dGlobal.Zoom.X;
  cam2dZoomY := cam2dGlobal.Zoom.Y;
  ogl_ClipR  := Round( sqrt( sqr( ogl_ClipW / scr_ResCX / cam2dZoomX ) + sqr( ogl_ClipH / scr_ResCY / cam2dZoomY ) ) ) div 2;
end;

procedure scr_SetViewPort;
begin
  if ogl_Target = TARGET_SCREEN Then
    begin
      cam2dSX := Round( -ogl_Width / 2 + scr_AddCX / scr_ResCX );
      cam2dSY := Round( -ogl_Height / 2 + scr_AddCY / scr_ResCY );

      if ( app_Flags and CORRECT_RESOLUTION > 0 ) and ( ogl_Mode = 2 ) Then
        begin
          ogl_ClipX := 0;
          ogl_ClipY := 0;
          ogl_ClipW := wnd_Width - scr_AddCX * 2;
          ogl_ClipH := wnd_Height - scr_AddCY * 2;
          glViewPort( scr_AddCX, scr_AddCY, ogl_ClipW, ogl_ClipH );
        end else
          begin
            ogl_ClipX := 0;
            ogl_ClipY := 0;
            ogl_ClipW := wnd_Width;
            ogl_ClipH := wnd_Height;
            glViewPort( 0, 0, ogl_ClipW, ogl_ClipH );
          end;
    end else
      begin
        cam2dSX   := Round( -ogl_Width / 2 );
        cam2dSY   := Round( -ogl_Height / 2 );
        ogl_ClipX := 0;
        ogl_ClipY := 0;
        ogl_ClipW := ogl_Width;
        ogl_ClipH := ogl_Height;
        glViewPort( 0, 0, ogl_ClipW, ogl_ClipH );
      end;
end;

procedure scr_SetVSync( VSync : Boolean );
begin
  scr_VSync := VSync;
  if wnd_Handle <> 0 Then
    wnd_Update();
end;

procedure scr_SetFSAA( FSAA : Byte );
begin
  if ogl_FSAA = FSAA Then exit;
  ogl_FSAA := FSAA;

  if ogl_FSAA <> 0 Then
    log_Add( 'FSAA changed to: ' + u_IntToStr( ogl_FSAA ) + 'x' )
  else
    log_Add( 'FSAA changed to: off' );

  if wnd_Handle <> 0 Then
    wnd_Update();
end;

procedure scr_ReadPixels( var pData : Pointer; X, Y, Width, Height : Word );
begin
  batch2d_Flush();
  GetMem( pData, Width * Height * 4 );
  glReadPixels( X, ogl_ClipH - Height - Y, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, pData );
end;

end.
