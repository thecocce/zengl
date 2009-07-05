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

#include "zgl_screen.h"

int               scr_Width;
int               scr_Height;
int               scr_BPP;
int               scr_Refresh;
bool              scr_VSync;
zglResolutionList scr_ResList;
int               desktop_Width;
int               desktop_Height;

DEVMODE scr_Settings;
DEVMODE scr_Desktop;

int GetDisplayColors(void)
{
  int i;
  HDC tHDC = GetDC( 0 );
  i = GetDeviceCaps( tHDC, BITSPIXEL ) * GetDeviceCaps( tHDC, PLANES );
  ReleaseDC( 0, tHDC );
  return i;
}

int GetDisplayRefresh(void)
{
  int i;
  HDC tHDC = GetDC( 0 );
  i = GetDeviceCaps( tHDC, VREFRESH );
  ReleaseDC( 0, tHDC );
  return i;
}

bool scr_ResIsInList( int Width, int Height )
{
  int i;
  for ( i = 0; i < scr_ResList.Count; i++ )
    if ( ( scr_ResList.Width[ i ] == Width ) && ( scr_ResList.Height[ i ] == Height ) ) return 1;
  return 0;
}

void scr_GetResList()
{
  DEVMODE tmp_Settings;
  int i = 0;
  while ( EnumDisplaySettings( NULL, i, &tmp_Settings ) ) {
    if ( !scr_ResIsInList( tmp_Settings.dmPelsWidth, tmp_Settings.dmPelsHeight ) ) {
      scr_ResList.Count++;
      scr_ResList.Width  = (int*)realloc( scr_ResList.Width, (size_t)scr_ResList.Count * sizeof( zglResolutionList ) );
      scr_ResList.Height = (int*)realloc( scr_ResList.Height, (size_t)scr_ResList.Count * sizeof( zglResolutionList ) );
      scr_ResList.Width[ scr_ResList.Count - 1 ]  = tmp_Settings.dmPelsWidth;
      scr_ResList.Height[ scr_ResList.Count - 1 ] = tmp_Settings.dmPelsHeight;
    }
    i++;
  }
}

bool scr_Create(void)
{
  scr_Desktop.dmSize             = sizeof( DEVMODE );
  scr_Desktop.dmPelsWidth        = GetSystemMetrics( SM_CXSCREEN );
  scr_Desktop.dmPelsHeight       = GetSystemMetrics( SM_CYSCREEN );
  scr_Desktop.dmBitsPerPel       = GetDisplayColors();
  scr_Desktop.dmDisplayFrequency = GetDisplayRefresh();
  scr_Desktop.dmFields           = DM_PELSWIDTH | DM_PELSHEIGHT | DM_BITSPERPEL | DM_DISPLAYFREQUENCY;

  desktop_Width  = scr_Desktop.dmPelsWidth;
  desktop_Height = scr_Desktop.dmPelsHeight;

  char tmp[256];
  sprintf( tmp, "Current mode: %i x %i", desktop_Width, desktop_Height );
  log_Add( tmp, 1 );
  scr_GetResList();

  return 1;
}

void scr_SetOptions( int Width, int Height, int BPP, int Refresh, bool FullScreen, bool VSync )
{
  int i, r;

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

  if ( wnd_FullScreen ) {
    i = 0;
    r = 0;

    while ( EnumDisplaySettings( NULL, i, &scr_Settings ) ) {
      scr_Settings.dmSize   = sizeof( DEVMODE );
      scr_Settings.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT | DM_BITSPERPEL | DM_DISPLAYFREQUENCY;
      if ( ( scr_Settings.dmPelsWidth  == scr_Width ) && ( scr_Settings.dmPelsHeight == scr_Height ) &&
           ( scr_Settings.dmBitsPerPel == scr_BPP   ) && ( scr_Settings.dmDisplayFrequency > r     ) &&
           ( scr_Settings.dmDisplayFrequency <= scr_Desktop.dmDisplayFrequency ) ) {
        if ( ( ChangeDisplaySettings( &scr_Settings, CDS_TEST | CDS_FULLSCREEN ) == DISP_CHANGE_SUCCESSFUL ) )
          r = scr_Settings.dmDisplayFrequency;
        else
          break;
      }
      i++;
    }

    if ( scr_Refresh == REFRESH_MAXIMUM ) scr_Refresh = r;
    if ( scr_Refresh == REFRESH_DEFAULT ) scr_Refresh = 0;
    scr_Settings.dmSize             = sizeof( DEVMODE );
    scr_Settings.dmPelsWidth        = scr_Width;
    scr_Settings.dmPelsHeight       = scr_Height;
    scr_Settings.dmBitsPerPel       = scr_BPP;
    scr_Settings.dmDisplayFrequency = scr_Refresh;
    scr_Settings.dmFields           = DM_PELSWIDTH | DM_PELSHEIGHT | DM_BITSPERPEL | DM_DISPLAYFREQUENCY;

    if ( ChangeDisplaySettings( &scr_Settings, CDS_TEST | CDS_FULLSCREEN ) != DISP_CHANGE_SUCCESSFUL ) {
      u_Warning( "Cannot set fullscreen mode." );
      wnd_FullScreen = 0;
    } else ChangeDisplaySettings( &scr_Settings, CDS_FULLSCREEN );
  } else scr_Reset();

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
  ChangeDisplaySettings( NULL, 0 );
}

void scr_SetVSync( bool VSync )
{
  scr_VSync = VSync;
}

void scr_Clear(void)
{
  glClear( GL_COLOR_BUFFER_BIT   * ( app_Flags & COLOR_BUFFER_CLEAR ) |
           GL_DEPTH_BUFFER_BIT   * ( app_Flags & DEPTH_BUFFER_CLEAR ) |
           GL_STENCIL_BUFFER_BIT * ( app_Flags & STENCIL_BUFFER_CLEAR ) );
}

void scr_Flush(void)
{
  int sync;
  if ( ogl_CanVSync ) {
    sync = wglGetSwapIntervalEXT();
    switch ( scr_VSync ) {
      case 1: if ( sync != 1 ) wglSwapIntervalEXT( 1 ); break;
      case 0: if ( sync != 0 ) wglSwapIntervalEXT( 0 ); break;
    }
    glFinish();
  }

  SwapBuffers( wnd_DC );
}
