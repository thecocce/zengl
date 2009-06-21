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

#include "zgl_application.h"

XIM app_XIM;
XIC app_XIC;

int kRepeat;

int xkey_to_scancode( int XKey, int KeyCode )
{
  switch ( XKey ) {
    /*case XK_Sys_Req:      return K_SYSRQ;*/
    case XK_Pause:         return K_PAUSE;
    /*case XK_Escape:       return K_ESCAPE;
    case XK_Return:       return K_ENTER;
    case XK_KP_Enter:     return K_KP_ENTER;*/

    case XK_Up:           return K_UP;
    case XK_Down:         return K_DOWN;
    case XK_Left:         return K_LEFT;
    case XK_Right:        return K_RIGHT;

    /*case XK_BackSpace:    return K_BACKSPACE;
    case XK_Space:        return K_SPACE;
    case XK_Tab:          return K_TAB;
    case XK_Grave:        return K_TILDA;*/

    case XK_Insert:       return K_INSERT;
    case XK_Delete:       return K_DELETE;
    case XK_Home:         return K_HOME;
    case XK_End:          return K_END;
    case XK_Page_Up:      return K_PAGEUP;
    case XK_Page_Down:    return K_PAGEDOWN;

    /*case XK_Control_L:    return K_CTRL_L;*/
    case XK_Control_R:    return K_CTRL_R;
    /*case XK_Alt_L:        return K_ALT_L;*/
    case XK_Alt_R:        return K_ALT_R;
    /*case XK_Shift_L:      return K_SHIFT_L;
    case XK_Shift_R:      return K_SHIFT_R;*/
    case XK_Super_L:      return K_SUPER_L;
    case XK_Super_R:      return K_SUPER_R;
    case XK_Menu:         return K_APP_MENU;

    /*case XK_Caps_Lock:    return K_CAPSLOCK;
    case XK_Num_Lock:     return K_NUMLOCK;
    case XK_Scroll_Lock:  return K_SCROLL;

    case XK_BracketLeft:  return K_BRACKET_L;
    case XK_BracketRight: return K_BRACKET_R;
    case XK_BackSlash:    return K_BACKSLASH;
    case XK_Slash:        return K_SLASH;
    case XK_Comma:        return K_COMMA;
    case XK_Period:       return K_DECIMAL;
    case XK_Semicolon:    return K_SEMICOLON;
    case XK_Apostrophe:   return K_APOSTROPHE;

    case XK_Minus:        return K_MINUS;
    case XK_Equal:        return K_EQUALS;

    case XK_KP_Insert,
    case XK_KP_0:         return K_KP_0;
    case XK_KP_End,
    case XK_KP_1:         return K_KP_1;
    case XK_KP_Down,
    case XK_KP_2:         return K_KP_2;
    case XK_KP_Page_Down,
    case XK_KP_3:         return K_KP_3;
    case XK_KP_Left,
    case XK_KP_4:         return K_KP_4;
    case XK_KP_5:         return K_KP_5;
    case XK_KP_Right,
    case XK_KP_6:         return K_KP_6;
    case XK_KP_Home,
    case XK_KP_7:         return K_KP_7;
    case XK_KP_Up,
    case XK_KP_8:         return K_KP_8;
    case XK_KP_Page_Up,
    case XK_KP_9:         return K_KP_9;

    case XK_KP_Subtract:  return K_KP_SUB;
    case XK_KP_Add:       return K_KP_ADD;
    case XK_KP_Multiply:  return K_KP_MUL;*/
    case XK_KP_Divide:    return K_KP_DIV;
    /*case XK_KP_Delete,
    case XK_KP_Decimal:   return K_KP_DECIMAL;*/
  default: return ( ( KeyCode - 8 ) & 0xFF );
  }
}

void app_Proc(void)
{
  XEvent event;
  uint   key;

  while ( XPending( scr_Display ) ) {
    XNextEvent( scr_Display, &event );

    switch ( event.type ) {
      case ClientMessage: {
        if ( ( event.xclient.message_type == wnd_Protocols ) && ( event.xclient.data.l[ 0 ] == wnd_DestroyAtom ) ) app_Work = 0;
        break;
      }

      case Expose: {
        app_Draw();
        break;
      }
      case FocusIn: {
        app_Focus = 1;
        app_Pause = 0;
        memset( mDown, 0, 3 );
        mouse_ClearState();
        memset( kDown, 0, 256 );
        key_ClearState();
        break;
      }
      case FocusOut: {
        app_Focus = 0;
        if ( app_AutoPause ) app_Pause = 1;
        break;
      }

      case MotionNotify: {
        if ( !mLock ) {
          mX = event.xmotion.x;
          mY = event.xmotion.y;
        } else {
            mX = event.xmotion.x - wnd_Width  / 2;
            mY = event.xmotion.y - wnd_Height / 2;
          }
        break;
      }
      case ButtonPress: {
        switch ( event.xbutton.button ) {
          case 1: { /* Left */
            mDown[ MB_LEFT ] = 1;
            if ( mCanClick[ MB_LEFT ] ) {
              mClick   [ MB_LEFT ] = 1;
              mCanClick[ MB_LEFT ] = 0;
            }
            break;
          }
          case 2: { /* Midle */
            mDown[ MB_MIDLE ] = 1;
            if ( mCanClick[ MB_MIDLE ] ) {
              mClick   [ MB_MIDLE ] = 1;
              mCanClick[ MB_MIDLE ] = 0;
            }
            break;
          }
          case 3: { /* Right */
            mDown[ MB_RIGHT ] = 1;
            if ( mCanClick[ MB_RIGHT ] ) {
              mClick   [ MB_RIGHT ] = 1;
              mCanClick[ MB_RIGHT ] = 0;
            }
            break;
          }
        }
        break;
      }
      case ButtonRelease: {
        switch ( event.xbutton.button ) {
          case 1: { /* Left */
            mDown    [ MB_LEFT ] = 0;
            mUp      [ MB_LEFT ] = 1;
            mCanClick[ MB_LEFT ] = 1;
            break;
          }
          case 2: { /* Midle */
            mDown    [ MB_MIDLE ] = 0;
            mUp      [ MB_MIDLE ] = 1;
            mCanClick[ MB_MIDLE ] = 1;
            break;
          }
          case 3: { /* Right */
            mDown    [ MB_RIGHT ] = 0;
            mUp      [ MB_RIGHT ] = 1;
            mCanClick[ MB_RIGHT ] = 1;
            break;
          }
          case 4: { /* Up Wheel */
            mWheel[ MW_UP ] = 1;
            break;
          }
          case 5: { /* Down Wheel */
            mWheel[ MW_DOWN ] = 1;
            break;
          }
        }
        break;
      }

      case KeyPress: {
        kRepeat++;
        key = xkey_to_scancode( XLookupKeysym( &event.xkey, 0 ), event.xkey.keycode );
        kDown[ key ]     = 1;
        kUp  [ key ]     = 0;
        kLast[ KA_DOWN ] = key;
        if ( kRepeat < 2 ) DoKeyPress( key );

        key = SCA( key );
        kDown[ key ] = 1;
        kUp  [ key ] = 0;
        if ( kRepeat < 2 ) DoKeyPress( key );

        switch ( key ) {
          case K_SYSRQ:
          case K_PAUSE:
          case K_ESCAPE:
          case K_ENTER:
          case K_KP_ENTER:
          case K_UP:
          case K_DOWN:
          case K_LEFT:
          case K_RIGHT:
          case K_INSERT:
          case K_DELETE:
          case K_HOME:
          case K_END:
          case K_PAGEUP:
          case K_PAGEDOWN:
          case K_CTRL_L:
          case K_CTRL_R:
          case K_ALT_L:
          case K_ALT_R:
          case K_SHIFT_L:
          case K_SHIFT_R:
          case K_SUPER_L:
          case K_SUPER_R:
          case K_APP_MENU:
          case K_CAPSLOCK:
          case K_NUMLOCK:
          case K_SCROLL: return;
          case K_BACKSPACE: return; /* u_Backspace( keysText ); */
          case K_TAB:       return; /* key_InputText( '  ' ); */
          default: {
              /*len := Xutf8LookupString( app_XIC, @Event, @c[ 0 ], 6, @Keysym, @Status );
              str := '';
              for i := 0 to len - 1 do
                str := str + c[ i ];
              if str <> '' Then
                key_InputText( str );*/
            }
        }
        break;
      }
      case KeyRelease: {
        kRepeat++;
        key = xkey_to_scancode( XLookupKeysym( &event.xkey, 0 ), event.xkey.keycode );
        kDown[ key ]   = 0;
        kUp  [ key ]   = 1;
        kLast[ KA_UP ] = key;

        key = SCA( key );
        kDown[ key ] = 0;
        kUp  [ key ] = 1;
        break;
      }
    }
  }

  if ( mLock ) {
    XWarpPointer( scr_Display, None, wnd_Handle, 0, 0, 0, 0, wnd_Width / 2, wnd_Height / 2 );
    mLock = 0;
  }
  kRepeat = 0;
}
