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

#include "zgl_opengl.h"

HGLRC ogl_Context;
float ogl_fAttr[2] = { 0, 0 };
int   ogl_iAttr[32];
int   ogl_Format;
uint  ogl_Formats;

bool (*wglSwapIntervalEXT)(GLint);
GLint (*wglGetSwapIntervalEXT)(void);

bool gl_Create(void)
{
  wnd_First = 0;
  int PixelFormat;
  PIXELFORMATDESCRIPTOR pfd;
  uint i, ga, gf;

  if ( !ogl_Context ) wglDeleteContext( ogl_Context );

  memset( &pfd, 0, sizeof( PIXELFORMATDESCRIPTOR ) );

  if ( !ogl_Format ) {
    pfd.nSize        = sizeof( PIXELFORMATDESCRIPTOR );
    pfd.nVersion     = 1;
    pfd.dwFlags      = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType   = PFD_TYPE_RGBA;
    pfd.cColorBits   = scr_BPP;
    pfd.cAlphaBits   = 8;
    pfd.cDepthBits   = ogl_zDepth;
    pfd.cStencilBits = ogl_Stencil;
    pfd.iLayerType   = PFD_MAIN_PLANE;
    PixelFormat      = ChoosePixelFormat( wnd_DC, &pfd );
  } else PixelFormat = ogl_Format;

  if ( !SetPixelFormat( wnd_DC, PixelFormat, &pfd ) ) {
    u_Error( "Cannot set pixel format" );
    return 0;
  }

  ogl_Context = wglCreateContext( wnd_DC );
  if ( !ogl_Context ) {
    u_Error( "Cannot create OpenGL context" );
    return 0;
  }
  log_Add( "Create OpenGL Context", 1 );

  if ( !wglMakeCurrent( wnd_DC, ogl_Context ) ) {
    u_Error( "Cannot set current OpenGL context" );
    return 0;
  }
  log_Add( "Make Current OpenGL Context", 1 );

  gf = pfd.dwFlags & PFD_GENERIC_FORMAT;
  ga = pfd.dwFlags & PFD_GENERIC_ACCELERATED;

  /*ogl_3DAccelerator = gf & ( !ga ) == 0;
  if ( ogl_3DAccelerator ) u_Warning( "Cannot find 3D-accelerator! Application run in software-mode, it''s very slow" );*/

  /* if ( !ogl_Format )
  {$IFDEF USE_WINEHACK}
    wglChoosePixelFormatARB := gl_GetProc( 'wglChoosePixelFormatARB' );
  {$ELSE}
    wglChoosePixelFormatARB := gl_GetProc( 'wglChoosePixelFormat' );
  {$ENDIF}*/
  if /*( not Assigned( wglChoosePixelFormatARB ) )*/ ( !ogl_Format ) {
    wnd_First  = 0;
    ogl_Format = PixelFormat;
    gl_Destroy();
    wnd_Destroy();
    wnd_Create( wnd_Width, wnd_Height );
    return gl_Create();
  }
  /*if ( ogl_Format = 0 ) and ( Assigned( wglChoosePixelFormatARB ) ) and ( not app_InitToHandle ) Then
    begin
      ogl_zDepth := 24;

      repeat
        ogl_iAttr[ 0 ] := WGL_ACCELERATION_ARB;
        ogl_iAttr[ 1 ] := WGL_FULL_ACCELERATION_ARB;
        ogl_iAttr[ 2 ] := WGL_DRAW_TO_WINDOW_ARB;
        ogl_iAttr[ 3 ] := GL_TRUE;
        ogl_iAttr[ 4 ] := WGL_SUPPORT_OPENGL_ARB;
        ogl_iAttr[ 5 ] := GL_TRUE;
        ogl_iAttr[ 6 ] := WGL_DOUBLE_BUFFER_ARB;
        ogl_iAttr[ 7 ] := GL_TRUE;
        ogl_iAttr[ 8 ] := WGL_DEPTH_BITS_ARB;
        ogl_iAttr[ 9 ] := ogl_zDepth;
        i := 10;
        if ogl_Stencil > 0 Then
          begin
            ogl_iAttr[ i     ] := WGL_STENCIL_BITS_ARB;
            ogl_iAttr[ i + 1 ] := ogl_Stencil;
            INC( i, 2 );
          end;
        ogl_iAttr[ i     ] := WGL_COLOR_BITS_ARB;
        ogl_iAttr[ i + 1 ] := scr_BPP;
        ogl_iAttr[ i + 2 ] := WGL_ALPHA_BITS_ARB;
        ogl_iAttr[ i + 3 ] := 8;
        INC( i, 4 );
        if ogl_FSAA > 0 Then
          begin
            ogl_iAttr[ i     ] := WGL_SAMPLE_BUFFERS_ARB;
            ogl_iAttr[ i + 1 ] := GL_TRUE;
            ogl_iAttr[ i + 2 ] := WGL_SAMPLES_ARB;
            ogl_iAttr[ i + 3 ] := ogl_FSAA;
            INC( i, 4 );
          end;
        ogl_iAttr[ i     ] := 0;
        ogl_iAttr[ i + 1 ] := 0;

        log_Add( 'wglChoosePixelFormatARB: zDepth = ' + u_IntToStr( ogl_zDepth ) + '; ' + 'stencil = ' + u_IntToStr( ogl_Stencil ) + '; ' + 'fsaa = ' + u_IntToStr( ogl_FSAA )  );
        wglChoosePixelFormatARB( wnd_DC, @ogl_iAttr, @ogl_fAttr, 1, @ogl_Format, @ogl_Formats );
        if ( ogl_Format = 0 ) and ( ogl_zDepth < 16 ) Then
          begin
            if ogl_FSAA <= 0 Then
              break
            else
              begin
                ogl_zDepth := 24;
                DEC( ogl_FSAA, 2 );
              end;
          end else
            DEC( ogl_zDepth, 8 );
      until ogl_Format <> 0;

      if ogl_Format <> 0 Then
        begin
          wnd_First := FALSE;
          gl_Destroy;
          wnd_Destroy;
          wnd_Create( wnd_Width, wnd_Height );
          Result := gl_Create;
          exit;
        end;
    end;*/

  if ( !PixelFormat ) {
    u_Error( "Cannot choose pixel format" );
    return 0;
  }

  wglGetAddress( wglSwapIntervalEXT, "wglSwapIntervalEXT" );
  if ( wglSwapIntervalEXT ) {
    ogl_CanVSync        = 1;
    wglGetAddress( wglGetSwapIntervalEXT, "wglGetSwapIntervalEXT" );
    log_Add( "Support WaitVSync: yes", 1 );
  } else {
    ogl_CanVSync = 0;
    log_Add( "Support WaitVSync: no", 1 );
  }

  return 1;
}

void gl_Destroy(void)
{
  if ( !wglMakeCurrent( wnd_DC, 0 ) ) u_Error( "Cannot release current OpenGL context" );

  wglDeleteContext( ogl_Context );
}
