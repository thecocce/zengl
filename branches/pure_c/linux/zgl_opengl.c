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

GLXContext  ogl_Context;
XVisualInfo *ogl_VisualInfo;
int         ogl_Attr[32];

int (*glXGetVideoSyncSGI)(unsigned int *);
int (*glXWaitVideoSyncSGI)(int, int, unsigned int *);

bool gl_Create(void)
{
  ogl_Context = glXCreateContext( scr_Display, ogl_VisualInfo, 0, 1 );
  if ( !ogl_Context ) {
    ogl_Context = glXCreateContext( scr_Display, ogl_VisualInfo, 0, 0 );
    if ( !ogl_Context ) {
      u_Error( "Cannot create OpenGL context" );
      return 0;
    }
  }

  if ( !glXMakeCurrent( scr_Display, wnd_Handle, ogl_Context ) ) {
    u_Error( "Cannot set current OpenGL context" );
    return 0;
  }

  glXGetAddress( glXGetVideoSyncSGI, "glXGetVideoSyncSGI" );
  if ( glXGetVideoSyncSGI ) {
    ogl_CanVSync        = 1;
    glXGetAddress( glXWaitVideoSyncSGI, "glXWaitVideoSyncSGI" );
    log_Add( "Support WaitVSync: yes", 1 );
  } else {
    ogl_CanVSync = 0;
    log_Add( "Support WaitVSync: no", 1 );
  }

  return 1;
}

void gl_Destroy(void)
{
  if ( !glXMakeCurrent( scr_Display, None, NULL ) ) u_Error( "Cannot release current OpenGL context" );

  glXDestroyContext( scr_Display, ogl_Context );
  glXWaitGL();
}
