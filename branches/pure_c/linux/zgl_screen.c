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
      scr_ResList.Width  = (int*)malloc( (size_t)scr_ResList.Count * sizeof( zglResolutionList ) );
      scr_ResList.Height = (int*)malloc( (size_t)scr_ResList.Count * sizeof( zglResolutionList ) );
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
    /* u_Error( "Cannot connect to X server" ); */
    return 0;
  }
  if ( !glXQueryExtension( scr_Display, &i, &j ) ) {
    /* u_Error( "GLX Extension not found" ); */
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
    /* u_Error( "XF86VidMode Extension not found" ); */
    return 0;
  } else log_Add( "XF86VidMode Extension - ok", 1 );

  XF86VidModeGetAllModeLines( scr_Display, scr_Default, (int*)&scr_ModeCount, &scr_ModeList );
  XF86VidModeGetModeLine( scr_Display, scr_Default, (int*)&scr_Desktop.dotclock, (XF86VidModeModeLine*)( (char*)&scr_Desktop + sizeof( scr_Desktop.dotclock ) ) );

  ogl_zDepth = 24;
  do
  {
    ogl_Attr[ 0 ]  = GLX_RGBA;
    ogl_Attr[ 1 ]  = GLX_RED_SIZE;
    ogl_Attr[ 2 ]  = 1;
    ogl_Attr[ 3 ]  = GLX_GREEN_SIZE;
    ogl_Attr[ 4 ]  = 1;
    ogl_Attr[ 5 ]  = GLX_BLUE_SIZE;
    ogl_Attr[ 6 ]  = 1;
    ogl_Attr[ 7 ]  = GLX_ALPHA_SIZE;
    ogl_Attr[ 8 ]  = 1;
    ogl_Attr[ 9 ]  = GLX_DOUBLEBUFFER;
    ogl_Attr[ 10 ] = GLX_DEPTH_SIZE;
    ogl_Attr[ 11 ] = ogl_zDepth;
    i = 12;
    if ( ogl_Stencil > 0 ) {
      ogl_Attr[ i++ ] = GLX_STENCIL_SIZE;
      ogl_Attr[ i++ ] = ogl_Stencil;
    }
    if ( ogl_FSAA > 0 ) {
      ogl_Attr[ i++ ] = GLX_SAMPLES_SGIS;
      ogl_Attr[ i++ ] = ogl_FSAA;
    }
    ogl_Attr[ i ] = None;

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
    /* u_Error( "Cannot choose pixel format" ); */
    return 0;
  }

  ogl_zDepth = ogl_VisualInfo->depth;

  wnd_Root = RootWindow( scr_Display, ogl_VisualInfo->screen );

  char tmp[256];
  sprintf( tmp, "Current mode: %i x %i", 1280, 1024 );
  log_Add( tmp, 1 );
  scr_GetResList();

  return 1;
}

void scr_SetOptions( int Width, int Height, int BPP, int Refresh, bool FullScreen, bool VSync )
{
  int modeToSet;

  ogl_Width      = Width;
  ogl_Height     = Height;
  wnd_Width      = Width;
  wnd_Height     = Height;
  scr_Width      = Width;
  scr_Height     = Height;
  scr_BPP        = BPP;
  wnd_FullScreen = FullScreen;
  scr_VSync      = VSync;
  if ( !app_Work ) return;
  /* scr_SetVSync( scr_VSync ); */

  /* if ( Width >= zgl_Get( DESKTOP_WIDTH ) ) and ( Height >= zgl_Get( DESKTOP_HEIGHT ) ) Then
    wnd_FullScreen := TRUE; */
  if ( wnd_FullScreen ) {
    scr_Width  = Width;
    scr_Height = Height;
    scr_BPP    = BPP;
  } else {
      scr_Width  = 1280; /* zgl_Get( DESKTOP_WIDTH ); */
      scr_Height = 1024; /* zgl_Get( DESKTOP_HEIGHT ); */
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
    /* XSetInputFocus( scr_Display, wnd_Handle, RevertToPointerRoot, CurrentTime ); */
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

  wnd_Update();
}

void scr_Reset(void)
{
  XF86VidModeSwitchToMode( scr_Display, scr_Default, &scr_Desktop );
  XF86VidModeSetViewPort( scr_Display, scr_Default, 0, 0 );
  XUngrabKeyboard( scr_Display, CurrentTime );
  XUngrabPointer( scr_Display, CurrentTime );
  glXWaitX();
}
