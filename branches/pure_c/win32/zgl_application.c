/*
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
 */

#include "zgl_application.h"

int winkey_to_scancode( int WinKey )
{
  switch ( WinKey ) {
    case 0x26: return K_UP;
    case 0x28: return K_DOWN;
    case 0x25: return K_LEFT;
    case 0x27: return K_RIGHT;

    case 0x2D: return K_INSERT;
    case 0x2E: return K_DELETE;
    case 0x24: return K_HOME;
    case 0x23: return K_END;
    case 0x21: return K_PAGEUP;
    case 0x22: return K_PAGEDOWN;
  default: return MapVirtualKey( WinKey, 0 );
  }
}

LRESULT CALLBACK app_WndProc( HWND hWnd, uint Msg, WPARAM wParam, LPARAM lParam )
{
  int i, key;

  switch ( Msg ) {
    case WM_CLOSE:
    case WM_DESTROY:
    case WM_QUIT: {
      app_Work = 0;
      return 0;
    }

    case WM_PAINT: {
      if ( app_Work ) {
        app_Draw();
        ValidateRect( wnd_Handle, 0 );
      }
      return 0;
    }
    case WM_DISPLAYCHANGE: {
      wnd_Update();
      return 0;
    }
    case WM_KILLFOCUS: {
      if ( app_Work ) {
        app_Focus = 0;
        if ( app_AutoPause ) app_Pause = 1;
        if ( ( wnd_FullScreen ) && ( !wnd_First ) ) {
          scr_Reset();
          wnd_Update();
        }
      }
      return 0;
    }
    case WM_SETFOCUS: {
      app_Focus = 1;
      app_Pause = 0;
      memset( mDown, 0, 3 );
      mouse_ClearState();
      memset( kDown, 0, 256 );
      key_ClearState();
      if ( ( wnd_FullScreen ) && ( !wnd_First ) ) scr_SetOptions( scr_Width, scr_Height, scr_BPP, scr_Refresh, wnd_FullScreen, scr_VSync );
      return 0;
    }
    case WM_NCHITTEST: {
      i = DefWindowProc( hWnd, Msg, wParam, lParam );
      if ( ( !app_Focus ) && ( i == HTCAPTION ) ) return HTCLIENT;
      return i;
    }
    case WM_MOVING: {
      LPRECT lp = (LPRECT)lParam;
      wnd_X = lp->left;
      wnd_Y = lp->top;
      return 0;
    }
    case WM_SETCURSOR: {
      if ( ( !app_Pause ) && ( LOWORD( lParam ) == HTCLIENT ) && ( !app_ShowCursor ) )
        SetCursor( 0 );
      else
        SetCursor( LoadCursor( 0, IDC_ARROW ) );
      return 0;
    }

    case WM_LBUTTONDOWN:
    case WM_LBUTTONDBLCLK: {
      mDown[ M_BLEFT ]  = 1;
      if ( mCanClick[ M_BLEFT ] ) {
        mClick   [ M_BLEFT ] = 1;
        mCanClick[ M_BLEFT ] = 0;
      }
      return 0;
    }
    case WM_MBUTTONDOWN:
    case WM_MBUTTONDBLCLK: {
      mDown[ M_BMIDLE ] = 1;
      if ( mCanClick[ M_BMIDLE ] ) {
        mClick   [ M_BMIDLE ] = 1;
        mCanClick[ M_BMIDLE ] = 0;
      }
      return 0;
    }
    case WM_RBUTTONDOWN:
    case WM_RBUTTONDBLCLK: {
      mDown[ M_BRIGHT ] = 1;
      if ( mCanClick[ M_BRIGHT ] ) {
        mClick   [ M_BRIGHT ] = 1;
        mCanClick[ M_BRIGHT ] = 0;
      }
      return 0;
    }
    case WM_LBUTTONUP: {
      mDown    [ M_BLEFT ] = 0;
      mUp      [ M_BLEFT ] = 1;
      mCanClick[ M_BLEFT ] = 1;
      return 0;
    }
    case WM_MBUTTONUP: {
      mDown    [ M_BMIDLE ] = 0;
      mUp      [ M_BMIDLE ] = 1;
      mCanClick[ M_BMIDLE ] = 1;
      return 0;
    }
    case WM_RBUTTONUP: {
      mDown    [ M_BRIGHT ] = 0;
      mUp      [ M_BRIGHT ] = 1;
      mCanClick[ M_BRIGHT ] = 1;
      return 0;
    }
    case WM_MOUSEWHEEL: {
      if ( wParam > 0 ) {
        mWheel[ M_WUP   ] = 1;
        mWheel[ M_WDOWN ] = 0;
      } else {
          mWheel[ M_WUP   ] = 0;
          mWheel[ M_WDOWN ] = 1;
        }
      return 0;
    }

    case WM_KEYDOWN:
    case WM_SYSKEYDOWN: {
      key = winkey_to_scancode( wParam );
      kDown[ key ]     = 1;
      kUp  [ key ]     = 0;
      kLast[ KA_DOWN ] = key;
      DoKeyPress( key );

      key = SCA( key );
      kDown[ key ] = 1;
      kUp  [ key ] = 0;
      DoKeyPress( key );

      if ( ( Msg == WM_SYSKEYDOWN ) && ( key == K_F4 ) ) app_Work = 0;
      return 0;
    }
    case WM_KEYUP:
    case WM_SYSKEYUP: {
      key = winkey_to_scancode( wParam );
      kDown[ key ]   = 0;
      kUp  [ key ]   = 1;
      kLast[ KA_UP ] = key;

      key = SCA( key );
      kDown[ key ] = 0;
      kUp  [ key ] = 1;
      return 0;
    }
    case WM_CHAR: {
      switch ( winkey_to_scancode( wParam ) ) {
        case K_BACKSPACE: return 0; /* u_Backspace( keysText ); */
        case K_TAB:       return 0; /* key_InputText( '  ' ); */
      default: return 0;
        /*key_InputText( AnsiToUtf8( Char( wParam ) ) );
        key_InputText( Char( wParam ) );*/
      }
    }
  default: return DefWindowProc( hWnd, Msg, wParam, lParam );
  }
}

void app_Proc(void)
{
  MSG Mess;
  while ( PeekMessage( &Mess, 0/*wnd_Handle*/, 0, 0, PM_REMOVE ) ) {
    TranslateMessage( &Mess );
    DispatchMessage( &Mess );
  };
}
