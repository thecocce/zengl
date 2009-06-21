/*
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
 */

#include "zgl_window.h"

char* wnd_Caption;

int  wnd_X;
int  wnd_Y;
int  wnd_Width;
int  wnd_Height;
bool wnd_FullScreen;

bool       wnd_First = 1; // Microsoft Sucks! :)
HWND       wnd_Handle;
HDC        wnd_DC;
HINSTANCE  wnd_INST;
WNDCLASSEX wnd_Class;
char*      wnd_ClassName = "ZenGL";
uint       wnd_Style;
int        wnd_CpnSize;
int        wnd_BrdSizeX;
int        wnd_BrdSizeY;

bool wnd_Create( int Width, int Height )
{
  wnd_INST   = GetModuleHandle( NULL );
  wnd_Width  = Width;
  wnd_Height = Height;

  if ( app_Flags && WND_USE_AUTOCENTER ) {
    wnd_X = ( desktop_Width - wnd_Width ) / 2;
    wnd_Y = ( desktop_Height - wnd_Height ) / 2;
  }

  wnd_CpnSize  = GetSystemMetrics( SM_CYCAPTION  );
  wnd_BrdSizeX = GetSystemMetrics( SM_CXDLGFRAME );
  wnd_BrdSizeY = GetSystemMetrics( SM_CYDLGFRAME );

  wnd_Class.cbSize        = sizeof( WNDCLASSEX );
  wnd_Class.style         = CS_DBLCLKS || CS_OWNDC;
  wnd_Class.lpfnWndProc   = app_WndProc;
  wnd_Class.cbClsExtra    = 0;
  wnd_Class.cbWndExtra    = 0;
  wnd_Class.hInstance     = wnd_INST;
  wnd_Class.hIcon         = LoadIcon  ( wnd_INST, MAKEINTRESOURCE( "MAINICON" ) );
  wnd_Class.hIconSm       = LoadIcon  ( wnd_INST, MAKEINTRESOURCE( "MAINICON" ) );
  wnd_Class.hCursor       = LoadCursor( wnd_INST, IDC_ARROW );
  wnd_Class.lpszMenuName  = NULL;
  wnd_Class.hbrBackground = (HBRUSH)GetStockObject( BLACK_BRUSH );
  wnd_Class.lpszClassName = wnd_ClassName;

  if ( !RegisterClassEx( &wnd_Class ) ) {
    u_Error( "Cannot register window class" );
    return 0;
  }

  if ( wnd_FullScreen ) {
    wnd_X     = 0;
    wnd_Y     = 0;
    wnd_Style = WS_POPUP | WS_VISIBLE;
  } else wnd_Style = WS_CAPTION | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE;

  if ( ogl_Format == 0 )
    wnd_Handle = CreateWindowEx( WS_EX_TOOLWINDOW, wnd_ClassName, wnd_Caption, WS_POPUP, 0, 0, 0, 0, 0, 0, 0, NULL );
  else
    wnd_Handle = CreateWindowEx( WS_EX_APPWINDOW,
                                 wnd_ClassName,
                                 wnd_Caption,
                                 wnd_Style,
                                 wnd_X, wnd_Y,
                                 wnd_Width  + ( wnd_BrdSizeX * 2 ) * ( !wnd_FullScreen ),
                                 wnd_Height + ( wnd_BrdSizeY * 2 + wnd_CpnSize ) * ( !wnd_FullScreen ),
                                 0,
                                 0,
                                 wnd_INST,
                                 NULL );

  if ( !wnd_Handle ) {
    u_Error( "Cannot create window" );
    return 0;
  }

  wnd_DC = GetDC( wnd_Handle );
  if ( !wnd_DC ) {
    u_Error( "Cannot get device context" );
    return 0;
  }
  wnd_Select();

  if ( !wnd_First ) {
    if ( !app_Work && !wnd_Caption ) wnd_Caption = strdup( "ZenGL" );
    wnd_SetCaption( wnd_Caption );
    wnd_SetSize( wnd_Width, wnd_Height );
  } else app_Work = 1;

  return 1;
}

void wnd_Destroy(void)
{
  if ( ( wnd_DC > 0 ) && ( !ReleaseDC( wnd_Handle, wnd_DC ) ) ) {
    u_Error( "Cannot release device context" );
    wnd_DC = 0;
  }

  if ( ( wnd_Handle ) && ( !DestroyWindow( wnd_Handle ) ) ) {
    u_Error( "Cannot destroy window" );
    wnd_Handle = 0;
  }

  if ( !UnregisterClass( wnd_ClassName, wnd_INST ) ) {
    u_Error( "Cannot unregister window class" );
    wnd_INST = 0;
  }
}

void wnd_Update(void)
{
  bool fs;
  if ( app_Focus )
    fs = wnd_FullScreen;
  else
    fs = 0;

  if ( app_Flags && WND_USE_AUTOCENTER ) {
    wnd_X = ( desktop_Width - wnd_Width ) / 2;
    wnd_Y = ( desktop_Height - wnd_Height ) / 2;
  }

  if ( fs ) {
    wnd_X     = 0;
    wnd_Y     = 0;
    wnd_Style = WS_VISIBLE;
  } else wnd_Style = WS_CAPTION | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE;

  SetWindowLong( wnd_Handle, GWL_STYLE, wnd_Style );
  SetWindowLong( wnd_Handle, GWL_EXSTYLE, WS_EX_APPWINDOW | ( WS_EX_TOPMOST * fs ) );

  wnd_SetSize( wnd_Width, wnd_Height );
  app_Work = 1;
}

void wnd_SetCaption( const char* Caption )
{
  wnd_Caption = (char*)Caption;
  if ( wnd_Handle ) SetWindowText( wnd_Handle, wnd_Caption );
}

void wnd_SetPos( int X, int Y )
{
  if ( !wnd_Handle ) return;

  if ( ( !wnd_FullScreen ) || ( !app_Focus ) ) {
    wnd_X = X;
    wnd_Y = Y;
    SetWindowPos( wnd_Handle, 0, wnd_X, wnd_Y - ( wnd_BrdSizeY * 2 + wnd_CpnSize ), wnd_Width + ( wnd_BrdSizeX * 2 ), wnd_Height + ( wnd_BrdSizeY * 2 + wnd_CpnSize ), SWP_NOACTIVATE );
  } else {
      wnd_X = 0;
      wnd_Y = 0;
      SetWindowPos( wnd_Handle, 0, 0, 0, wnd_Width, wnd_Height, SWP_NOACTIVATE );
    }
}

void wnd_SetSize( int Width, int Height )
{
  if ( !wnd_Handle ) return;

  wnd_Width  = Width;
  wnd_Height = Height;

  wnd_SetPos( wnd_X, wnd_Y );
  gl_SetCurrentMode();
}

void wnd_ShowCursor( bool Show )
{
  app_ShowCursor = Show;
}

void wnd_Select(void)
{
  ShowWindow( wnd_Handle, SW_NORMAL );
  BringWindowToTop( wnd_Handle );
}
