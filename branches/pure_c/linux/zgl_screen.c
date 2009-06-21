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

#include "zgl_screen.h"

int               scr_Width;
int               scr_Height;
int               scr_BPP;
int               scr_Refresh;
bool              scr_VSync;
zglResolutionList scr_ResList;
int               desktop_Width;
int               desktop_Height;

Display             *scr_Display;
int                 scr_Default;
XF86VidModeModeInfo scr_Settings;
XF86VidModeModeInfo scr_Desktop;
int                 scr_ModeCount;
XF86VidModeModeInfo **scr_ModeList;

bool scr_ResIsInList( int Width, int Height )
{
  int i;
  for ( i = 0; i < scr_ResList.Count; i++ )
    if ( ( scr_ResList.Width[ i ] == Width ) && ( scr_ResList.Height[ i ] == Height ) ) return 1;
  return 0;
}

void scr_GetResList()
{
  int i;
  XF86VidModeModeInfo tmp_Settings;

  for ( i = 0; i < scr_ModeCount; i++ ) {
    tmp_Settings = *scr_ModeList[ i ];
    if ( !scr_ResIsInList( tmp_Settings.hdisplay, tmp_Settings.vdisplay ) ) {
      scr_ResList.Count++;
      scr_ResList.Width  = (int*)realloc( scr_ResList.Width, (size_t)scr_ResList.Count * sizeof( zglResolutionList ) );
      scr_ResList.Height = (int*)realloc( scr_ResList.Height, (size_t)scr_ResList.Count * sizeof( zglResolutionList ) );
      scr_ResList.Width[ scr_ResList.Count - 1 ]  = tmp_Settings.hdisplay;
      scr_ResList.Height[ scr_ResList.Count - 1 ] = tmp_Settings.vdisplay;
    }
  }
}

bool scr_Create(void)
{
  int i, j;

  if ( scr_Display ) XCloseDisplay( scr_Display );

  scr_Display = XOpenDisplay( NULL );
  if ( !scr_Display ) {
    u_Error( "Cannot connect to X server" );
    return 0;
  }
  if ( !glXQueryExtension( scr_Display, &i, &j ) ) {
    u_Error( "GLX Extension not found" );
    return 0;
  } else log_Add( "GLX Extension - ok", 1 );

  app_XIM = XOpenIM( scr_Display, NULL, NULL, NULL );
  if ( !app_XIM )
    log_Add( "XOpenIM - Fail", 1 );
  else
    log_Add( "XOpenIM - ok", 1 );

  app_XIC = XCreateIC( app_XIM, XNInputStyle, XIMPreeditNothing | XIMStatusNothing, NULL );
  if ( !app_XIC )
    log_Add( "XCreateIC - Fail", 1 );
  else
    log_Add( "XCreateIC - ok", 1 );

  scr_Default = DefaultScreen( scr_Display );

  if ( !XF86VidModeQueryExtension( scr_Display, &i, &j ) ) {
    u_Error( "XF86VidMode Extension not found" );
    return 0;
  } else log_Add( "XF86VidMode Extension - ok", 1 );

  XF86VidModeGetAllModeLines( scr_Display, scr_Default, (int*)&scr_ModeCount, &scr_ModeList );
  XF86VidModeGetModeLine( scr_Display, scr_Default, (int*)&scr_Desktop.dotclock, (XF86VidModeModeLine*)( (char*)&scr_Desktop + sizeof( scr_Desktop.dotclock ) ) );
  desktop_Width  = scr_Desktop.hdisplay;
  desktop_Height = scr_Desktop.vdisplay;

  ogl_zDepth = 24;
  do {
    i = 0;
    ogl_Attr[ i++ ] = GLX_RGBA;
    ogl_Attr[ i++ ] = GLX_RED_SIZE;
    ogl_Attr[ i++ ] = 1;
    ogl_Attr[ i++ ] = GLX_GREEN_SIZE;
    ogl_Attr[ i++ ] = 1;
    ogl_Attr[ i++ ] = GLX_BLUE_SIZE;
    ogl_Attr[ i++ ] = 1;
    ogl_Attr[ i++ ] = GLX_ALPHA_SIZE;
    ogl_Attr[ i++ ] = 1;
    ogl_Attr[ i++ ] = GLX_DOUBLEBUFFER;
    ogl_Attr[ i++ ] = GLX_DEPTH_SIZE;
    ogl_Attr[ i++ ] = ogl_zDepth;
    if ( ogl_Stencil > 0 ) {
      ogl_Attr[ i++ ] = GLX_STENCIL_SIZE;
      ogl_Attr[ i++ ] = ogl_Stencil;
    }
    if ( ogl_FSAA > 0 ) {
      ogl_Attr[ i++ ] = GLX_SAMPLES_SGIS;
      ogl_Attr[ i++ ] = ogl_FSAA;
    }
    ogl_Attr[ i ] = None;

    char tmp[256];
    sprintf( tmp, "glXChooseVisual: zDepth = %i; stencil = %i; fsaa = %i", ogl_zDepth, ogl_Stencil, ogl_FSAA );
    log_Add( tmp, 1 );
    ogl_VisualInfo = glXChooseVisual( scr_Display, scr_Default, &ogl_Attr[ 0 ] );
    if ( ( !ogl_VisualInfo ) && ( ogl_zDepth == 1 ) ) {
      if ( ogl_FSAA == 0 ) {
        break;
      } else {
          ogl_zDepth = 24;
          ogl_FSAA  -= 2;
        }
    } else if ( !ogl_VisualInfo ) ogl_zDepth -= 8;
  if ( ogl_zDepth == 0 ) ogl_zDepth = 1;
  }
  while ( !ogl_VisualInfo );

  if ( !ogl_VisualInfo ) {
    u_Error( "Cannot choose pixel format" );
    return 0;
  }

  ogl_zDepth = ogl_VisualInfo->depth;

  wnd_Root = RootWindow( scr_Display, ogl_VisualInfo->screen );

  char tmp[256];
  sprintf( tmp, "Current mode: %i x %i", desktop_Width, desktop_Height );
  log_Add( tmp, 1 );
  scr_GetResList();

  return 1;
}

void scr_SetOptions( int Width, int Height, int BPP, int Refresh, bool FullScreen, bool VSync )
{
  int modeToSet;

  wnd_Width      = Width;
  wnd_Height     = Height;
  scr_Width      = Width;
  scr_Height     = Height;
  scr_BPP        = BPP;
  wnd_FullScreen = FullScreen;
  scr_VSync      = VSync;
  if ( !app_Initialized ) return;
  scr_SetVSync( scr_VSync );

  if ( ( Width >= desktop_Width ) && ( Height >= desktop_Height ) ) wnd_FullScreen = 1;
  if ( wnd_FullScreen ) {
    scr_Width  = Width;
    scr_Height = Height;
    scr_BPP    = BPP;
  } else {
      scr_Width  = desktop_Width;
      scr_Height = desktop_Height;
      scr_BPP    = BPP;
    }

  for ( modeToSet = 0; modeToSet < scr_ModeCount; modeToSet++ ) {
    scr_Settings = *scr_ModeList[ modeToSet ];
    if ( ( scr_Settings.hdisplay == scr_Width ) && ( scr_Settings.vdisplay == scr_Height ) ) break;
  }
  if ( ( scr_Settings.hdisplay != scr_Width ) || ( scr_Settings.vdisplay != scr_Height ) ) {
    log_Add( "Cannot find mode to set...", 1 );
    return;
  }

  if ( ( wnd_FullScreen ) &&
       ( scr_Settings.hdisplay != scr_Desktop.hdisplay ) &&
       ( scr_Settings.vdisplay != scr_Desktop.vdisplay ) ) {
    XF86VidModeSwitchToMode( scr_Display, scr_Default, &scr_Settings );
    XF86VidModeSetViewPort( scr_Display, scr_Default, 0, 0 );
  } else {
      scr_Reset();
      XMapWindow( scr_Display, wnd_Handle );
    }

  char tmp[256];
  sprintf( tmp, "Set screen options: %i x %i x %i", Width, Height, scr_BPP );
  if ( wnd_FullScreen )
    strcat( tmp, "bpp fullscreen" );
  else
    strcat( tmp, "bpp windowed" );
  log_Add( tmp, 1 );

  if ( app_Work ) wnd_Update();
}

void scr_Reset(void)
{
  XF86VidModeSwitchToMode( scr_Display, scr_Default, &scr_Desktop );
  XF86VidModeSetViewPort( scr_Display, scr_Default, 0, 0 );
  XUngrabKeyboard( scr_Display, CurrentTime );
  XUngrabPointer( scr_Display, CurrentTime );
  glXWaitX();
}

void scr_SetVSync( bool VSync )
{
  scr_VSync = VSync;
}

void scr_Clear(void)
{
  glClearColor( 1, 1, 1, 1 );
  glClear( GL_COLOR_BUFFER_BIT   * ( app_Flags & COLOR_BUFFER_CLEAR ) |
           GL_DEPTH_BUFFER_BIT   * ( app_Flags & DEPTH_BUFFER_CLEAR ) |
           GL_STENCIL_BUFFER_BIT * ( app_Flags & STENCIL_BUFFER_CLEAR ) );
  glColor3f( 0, 0, 0 );
  glBegin(GL_QUADS);
    glVertex2f( 100, 100 );
    glVertex2f( 612, 100 );
    glVertex2f( 612, 612 );
    glVertex2f( 100, 612 );
  glEnd();
}

void scr_Flush(void)
{
  if ( scr_VSync && ogl_CanVSync ) {
    uint sync;
    glXGetVideoSyncSGI( &sync );
    glXWaitVideoSyncSGI( 2, ( sync + 1 ) % 2, &sync );
    glFinish();
  };

  glXSwapBuffers( scr_Display, wnd_Handle );
}
