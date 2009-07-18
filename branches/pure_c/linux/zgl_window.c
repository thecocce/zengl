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

#include "zgl_window.h"

char* wnd_Caption;

int  wnd_X;
int  wnd_Y;
int  wnd_Width;
int  wnd_Height;
bool wnd_FullScreen;

Window               wnd_Handle;
Window               wnd_Root;
XClassHint           wnd_Class;
XSetWindowAttributes wnd_Attr;
uint                 wnd_ValueMask;
Atom                 wnd_DestroyAtom;
Atom                 wnd_Protocols;
Cursor               wnd_Cursor;

bool wnd_Create( int Width, int Height )
{
  wnd_Width  = Width;
  wnd_Height = Height;

  if ( app_Flags && WND_USE_AUTOCENTER ) {
    wnd_X = ( desktop_Width - wnd_Width ) / 2;
    wnd_Y = ( desktop_Height - wnd_Height ) / 2;
  }

  memset( &wnd_Attr, 0, sizeof( wnd_Attr ) );
  wnd_Attr.colormap   = XCreateColormap( scr_Display, wnd_Root, ogl_VisualInfo->visual, AllocNone );
  wnd_Attr.event_mask = ExposureMask |
                        FocusChangeMask |
                        ButtonPressMask |
                        ButtonReleaseMask |
                        PointerMotionMask |
                        KeyPressMask |
                        KeyReleaseMask;

  if ( wnd_FullScreen ) {
    wnd_X = 0;
    wnd_Y = 0;
    wnd_Attr.override_redirect = 1;
  } else wnd_Attr.override_redirect = 0;
  wnd_ValueMask = CWColormap | CWEventMask | CWOverrideRedirect | CWBorderPixel | CWBackPixel;

  wnd_Handle = XCreateWindow( scr_Display,
                              wnd_Root,
                              wnd_X, wnd_Y,
                              wnd_Width, wnd_Height,
                              0,
                              ogl_VisualInfo->depth,
                              InputOutput,
                              ogl_VisualInfo->visual,
                              wnd_ValueMask,
                              &wnd_Attr );

  if ( !wnd_Handle ) {
    u_Error( "Cannot create window" );
    return 0;
  }

  XSizeHints sizehints;
  sizehints.flags      = PPosition | PSize | PMinSize | PMaxSize;
  sizehints.x          = wnd_X;
  sizehints.y          = wnd_Y;
  sizehints.width      = wnd_Width;
  sizehints.height     = wnd_Height;
  sizehints.min_width  = wnd_Width;
  sizehints.max_width  = wnd_Width;
  sizehints.min_height = wnd_Height;
  sizehints.max_height = wnd_Height;
  XSetWMNormalHints( scr_Display, wnd_Handle, &sizehints );

  wnd_Class.res_name  = strdup( "ZenGL" );
  wnd_Class.res_class = strdup( "ZenGL Class" );
  XSetClassHint( scr_Display, wnd_Handle, &wnd_Class );

  wnd_DestroyAtom = XInternAtom( scr_Display, "WM_DELETE_WINDOW", 1 );
  wnd_Protocols   = XInternAtom( scr_Display, "WM_PROTOCOLS", 1 );
  XSetWMProtocols( scr_Display, wnd_Handle, &wnd_DestroyAtom, 1 );

  XMapWindow( scr_Display, wnd_Handle );
  glXWaitX();

  if ( wnd_FullScreen ) {
    XGrabKeyboard( scr_Display, wnd_Handle, True, GrabModeAsync, GrabModeAsync, CurrentTime );
    XGrabPointer( scr_Display, wnd_Handle, True, ButtonPressMask, GrabModeAsync, GrabModeAsync, wnd_Handle, None, CurrentTime );
  } else {
      XUngrabKeyboard( scr_Display, CurrentTime );
      XUngrabPointer( scr_Display, CurrentTime );
    }

  if ( !app_Work && !wnd_Caption ) wnd_Caption = strdup( "ZenGL" );
  wnd_SetCaption( wnd_Caption );
  wnd_ShowCursor( app_ShowCursor );

  return 1;
}

void wnd_Destroy(void)
{
  XDestroyWindow( scr_Display, wnd_Handle );
  glXWaitX();
}

void wnd_Update(void)
{
  wnd_Destroy();
  wnd_Create( wnd_Width, wnd_Height );
  glXMakeCurrent( scr_Display, wnd_Handle, ogl_Context );

  app_Work = 1;
}

void wnd_SetCaption( const char* Caption )
{
  wnd_Caption = (char*)Caption;
  if ( wnd_Handle ) XStoreName( scr_Display, wnd_Handle, wnd_Caption );
}

void wnd_SetPos( int X, int Y )
{
  if ( !wnd_Handle ) return;

  if ( !wnd_FullScreen ) {
    wnd_X = X;
    wnd_Y = Y;
    XMoveWindow( scr_Display, wnd_Handle, X, Y );
  } else {
      wnd_X = 0;
      wnd_Y = 0;
      XMoveWindow( scr_Display, wnd_Handle, 0, 0 );
    }
}

void wnd_SetSize( int Width, int Height )
{
  if ( !wnd_Handle ) return;

  wnd_Width  = Width;
  wnd_Height = Height;

  XResizeWindow( scr_Display, wnd_Handle, Width, Height );
  gl_SetCurrentMode();
}

void wnd_ShowCursor( bool Show )
{
  Pixmap mask;
  XColor xcolor;

  app_ShowCursor = Show;
  if ( !wnd_Handle ) return;

  if ( Show ) {
    if ( wnd_Cursor != None ) {
      XFreeCursor( scr_Display, wnd_Cursor );
      wnd_Cursor = None;
      XDefineCursor( scr_Display, wnd_Handle, wnd_Cursor );
    }
  } else {
      mask = XCreatePixmap( scr_Display, wnd_Handle, 1, 1, 1 );
      memset( &xcolor, 0, sizeof( xcolor ) );
      wnd_Cursor = XCreatePixmapCursor( scr_Display, mask, mask, &xcolor, &xcolor, 0, 0 );
      XDefineCursor( scr_Display, wnd_Handle, wnd_Cursor );
    }
}
