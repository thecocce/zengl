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

#include "zgl_opengl.h"

HGLRC ogl_Context;
float ogl_fAttr[2] = { 0, 0 };
int   ogl_iAttr[32];
int   ogl_Format;
uint  ogl_Formats;

bool (*wglChoosePixelFormatARB)(HDC, const int *, const float *, uint, int *, uint *);
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
  if ( !wnd_First ) log_Add( "Create OpenGL Context", 1 );

  if ( !wglMakeCurrent( wnd_DC, ogl_Context ) ) {
    u_Error( "Cannot set current OpenGL context" );
    return 0;
  }
  if ( !wnd_First ) log_Add( "Make Current OpenGL Context", 1 );

  gf = pfd.dwFlags & PFD_GENERIC_FORMAT;
  ga = pfd.dwFlags & PFD_GENERIC_ACCELERATED;

  ogl_3DAccelerator = gf & ( !ga ) == 0;
  if ( ogl_3DAccelerator ) u_Warning( "Cannot find 3D-accelerator! Application run in software-mode, it''s very slow" );

  if ( !ogl_Format ) wglGetAddress( wglChoosePixelFormatARB, "wglChoosePixelFormatARB" );
  if ( ( !wglChoosePixelFormatARB ) && ( !ogl_Format ) ) {
    wnd_First  = 0;
    ogl_Format = PixelFormat;
    gl_Destroy();
    wnd_Destroy();
    wnd_Create( wnd_Width, wnd_Height );
    return gl_Create();
  }
  if ( ( ogl_Format == 0 ) && ( wglChoosePixelFormatARB ) ) {
    ogl_zDepth = 24;

    do
    {
      i = 0;
      ogl_iAttr[ i++ ] = WGL_ACCELERATION_ARB;
      ogl_iAttr[ i++ ] = WGL_FULL_ACCELERATION_ARB;
      ogl_iAttr[ i++ ] = WGL_DRAW_TO_WINDOW_ARB;
      ogl_iAttr[ i++ ] = GL_TRUE;
      ogl_iAttr[ i++ ] = WGL_SUPPORT_OPENGL_ARB;
      ogl_iAttr[ i++ ] = GL_TRUE;
      ogl_iAttr[ i++ ] = WGL_DOUBLE_BUFFER_ARB;
      ogl_iAttr[ i++ ] = GL_TRUE;
      ogl_iAttr[ i++ ] = WGL_DEPTH_BITS_ARB;
      ogl_iAttr[ i++ ] = ogl_zDepth;
      if ( ogl_Stencil > 0 ) {
        ogl_iAttr[ i++ ] = WGL_STENCIL_BITS_ARB;
        ogl_iAttr[ i++ ] = ogl_Stencil;
      }
      ogl_iAttr[ i++ ] = WGL_COLOR_BITS_ARB;
      ogl_iAttr[ i++ ] = scr_BPP;
      ogl_iAttr[ i++ ] = WGL_ALPHA_BITS_ARB;
      ogl_iAttr[ i++ ] = 8;
      if ( ogl_FSAA > 0 ) {
        ogl_iAttr[ i++ ] = WGL_SAMPLE_BUFFERS_ARB;
        ogl_iAttr[ i++ ] = GL_TRUE;
        ogl_iAttr[ i++ ] = WGL_SAMPLES_ARB;
        ogl_iAttr[ i++ ] = ogl_FSAA;
      }
      ogl_iAttr[ i++ ] = 0;
      ogl_iAttr[ i++ ] = 0;

      char tmp[256];
      sprintf( tmp, "wglChoosePixelFormatARB: zDepth = %i; stencil = %i; fsaa = %i", ogl_zDepth, ogl_Stencil, ogl_FSAA );
      log_Add( tmp, 1 );
      wglChoosePixelFormatARB( wnd_DC, (int*)&ogl_iAttr[0], (float*)&ogl_fAttr[0], 1, &ogl_Format, &ogl_Formats );
      if ( ( ogl_Format == 0 ) && ( ogl_zDepth < 16 ) ) {
        if ( ogl_FSAA <= 0 ) {
          break;
        } else {
            ogl_zDepth = 24;
            ogl_FSAA -= 2;
          }
      } else ogl_zDepth -= 8;
    }
    while ( !ogl_Format );

    if ( ogl_Format ) {
      wnd_First = 0;
      gl_Destroy();
      wnd_Destroy();
      wnd_Create( wnd_Width, wnd_Height );
      return gl_Create();
    }
  }

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
