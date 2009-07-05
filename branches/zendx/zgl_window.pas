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
unit zgl_window;

{$I zgl_config.cfg}

interface
uses
  Windows,
  zgl_const,
  zgl_direct3d8,
  zgl_direct3d8_all;

function  wnd_Create( const Width, Height : Integer ) : Boolean;
procedure wnd_Destroy;
procedure wnd_Update;

procedure wnd_SetCaption( const NewCaption : String );
procedure wnd_SetSize( const Width, Height : Integer );
procedure wnd_SetPos( const X, Y : Integer );
procedure wnd_ShowCursor( const Show : Boolean );
procedure wnd_Select;

var
  wnd_X          : Integer;
  wnd_Y          : Integer;
  wnd_Width      : Integer = defWidth;
  wnd_Height     : Integer = defHeight;
  wnd_FullScreen : Boolean;
  wnd_Caption    : String = cs_ZenGL;

  wnd_Handle    : HWND;
  wnd_DC        : HDC;
  wnd_INST      : HINST;
  wnd_Class     : TWndClassEx;
  wnd_ClassName : PChar = 'ZenGL';
  wnd_Style     : DWORD;
  wnd_CpnSize   : Integer;
  wnd_BrdSizeX  : Integer;
  wnd_BrdSizeY  : Integer;

implementation
uses
  zgl_main,
  zgl_application,
  zgl_screen,
  zgl_utils;

function wnd_Create;
begin
  Result     := FALSE;
  wnd_Width  := Width;
  wnd_Height := Height;

  if app_Flags and WND_USE_AUTOCENTER > 0 Then
    begin
      wnd_X := ( zgl_Get( DESKTOP_WIDTH ) - wnd_Width ) div 2;
      wnd_Y := ( zgl_Get( DESKTOP_HEIGHT ) - wnd_Height ) div 2;
    end;

  wnd_CpnSize  := GetSystemMetrics( SM_CYCAPTION  );
  wnd_BrdSizeX := GetSystemMetrics( SM_CXDLGFRAME );
  wnd_BrdSizeY := GetSystemMetrics( SM_CYDLGFRAME );

  with wnd_Class do
    begin
      cbSize        := SizeOf( TWndClassEx );
      style         := CS_DBLCLKS or CS_OWNDC;
      lpfnWndProc   := @app_ProcessMessages;
      cbClsExtra    := 0;
      cbWndExtra    := 0;
      hInstance     := wnd_INST;
      hIcon         := LoadIcon  ( wnd_INST, MakeIntResource( 'MAINICON' ) );
      hIconSm       := LoadIcon  ( wnd_INST, MakeIntResource( 'MAINICON' ) );
      hCursor       := LoadCursor( wnd_INST, IDC_ARROW );
      lpszMenuName  := nil;
      hbrBackGround := GetStockObject( BLACK_BRUSH );
      lpszClassName := wnd_ClassName;
    end;

  if RegisterClassEx( wnd_Class ) = 0 Then
    begin
      u_Error( 'Cannot register window class' );
      exit;
    end;

  if wnd_FullScreen Then
    begin
      wnd_X     := 0;
      wnd_Y     := 0;
      wnd_Style := WS_POPUP or WS_VISIBLE;
    end else
      wnd_Style := WS_CAPTION or WS_MINIMIZEBOX or WS_SYSMENU or WS_VISIBLE;
    wnd_Handle := CreateWindowEx( WS_EX_APPWINDOW or WS_EX_TOPMOST * Byte( wnd_FullScreen ),
                                  wnd_ClassName,
                                  PChar( wnd_Caption ),
                                  wnd_Style,
                                  wnd_X, wnd_Y,
                                  wnd_Width  + ( wnd_BrdSizeX * 2 ) * Byte( not wnd_FullScreen ),
                                  wnd_Height + ( wnd_BrdSizeY * 2 + wnd_CpnSize ) * Byte( not wnd_FullScreen ),
                                  0,
                                  0,
                                  wnd_INST,
                                  nil );

  if wnd_Handle = 0 Then
    begin
      u_Error( 'Cannot create window' );
      exit;
    end;

  wnd_DC := GetDC( wnd_Handle );
  if wnd_DC = 0 Then
    begin
      u_Error( 'Cannot get device context' );
      exit;
    end;
  wnd_Select;

  Result := TRUE;
end;

procedure wnd_Destroy;
begin
  if ( wnd_DC > 0 ) and ( ReleaseDC( wnd_Handle, wnd_DC ) = 0 ) Then
    begin
      u_Error( 'Cannot release device context' );
      wnd_DC := 0;
    end;

  if ( wnd_Handle <> 0 ) and ( not DestroyWindow( wnd_Handle ) ) Then
    begin
      u_Error( 'Cannot destroy window' );
      wnd_Handle := 0;
    end;

  if not UnRegisterClass( wnd_ClassName, wnd_INST ) Then
    begin
      u_Error( 'Cannot unregister window class' );
      wnd_INST := 0;
    end;
end;

procedure wnd_Update;
  var
    FullScreen : Boolean;
begin
  if app_Focus Then
    FullScreen := wnd_FullScreen
  else
    FullScreen := FALSE;

  if FullScreen Then
    wnd_Style := WS_VISIBLE
  else
    wnd_Style := WS_CAPTION or WS_MINIMIZEBOX or WS_SYSMENU or WS_VISIBLE;

  SetWindowLong( wnd_Handle, GWL_STYLE, wnd_Style );
  SetWindowLong( wnd_Handle, GWL_EXSTYLE, WS_EX_APPWINDOW or WS_EX_TOPMOST * Byte( FullScreen ) );

  app_Work := TRUE;
  wnd_SetCaption( wnd_Caption );
  wnd_SetSize( wnd_Width, wnd_Height );

  if app_Flags and WND_USE_AUTOCENTER > 0 Then
    wnd_SetPos( ( zgl_Get( DESKTOP_WIDTH ) - wnd_Width ) div 2, ( zgl_Get( DESKTOP_HEIGHT ) - wnd_Height ) div 2 );
end;

procedure wnd_SetCaption;
begin
  wnd_Caption := NewCaption;

  if wnd_Handle <> 0 Then
    SetWindowText( wnd_Handle, PChar( wnd_Caption ) );
end;

procedure wnd_SetSize;
begin
  wnd_Width  := Width;
  wnd_Height := Height;

  if not app_InitToHandle Then
    wnd_SetPos( wnd_X, wnd_Y );

  d3d8_Restore;

  ogl_Width  := Width;
  ogl_Height := Height;
  if app_Flags and CORRECT_RESOLUTION > 0 Then
    scr_CorrectResolution( scr_ResW, scr_ResH )
  else
    SetCurrentMode;
end;

procedure wnd_SetPos;
begin
  wnd_X := X;
  wnd_Y := Y;

  if wnd_Handle <> 0 Then
    if ( not wnd_FullScreen ) or ( not app_Focus ) Then
      SetWindowPos( wnd_Handle, HWND_NOTOPMOST, wnd_X, wnd_Y, wnd_Width + ( wnd_BrdSizeX * 2 ), wnd_Height + ( wnd_BrdSizeY * 2 + wnd_CpnSize ), SWP_NOACTIVATE )
    else
      SetWindowPos( wnd_Handle, HWND_TOPMOST, 0, 0, wnd_Width, wnd_Height, SWP_NOACTIVATE );
end;

procedure wnd_ShowCursor;
begin
  app_ShowCursor := Show;
end;

procedure wnd_Select;
begin
  BringWindowToTop( wnd_Handle );
end;

end.
