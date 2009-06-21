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

int   ogl_zDepth;
int   ogl_Stencil;
bool  ogl_FSAA;
float ogl_FOVY  = 45.0f;
float ogl_zNear = 0.1f;
float ogl_zFar  = 100.0f;

int ogl_Mode = 2;

bool ogl_CanVSync;

void gl_Initialize(void)
{
  glHint( GL_LINE_SMOOTH_HINT,            GL_NICEST );
  glHint( GL_POLYGON_SMOOTH_HINT,         GL_NICEST );
  glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
  glHint( GL_FOG_HINT,                    GL_DONT_CARE );
  glHint( GL_SHADE_MODEL,                 GL_NICEST );
  glShadeModel( GL_SMOOTH );

  glClearColor( 0, 0, 0, 0 );

  glDepthFunc ( GL_LEQUAL );
  glClearDepth( 1.0 );

  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
  glAlphaFunc( GL_GREATER, 0 );

  glDisable( GL_BLEND );
  glDisable( GL_ALPHA_TEST );
  glDisable( GL_DEPTH_TEST );
  glDisable( GL_TEXTURE_2D );
  glEnable ( GL_NORMALIZE );
}

void gl_Set2DMode(void)
{
  ogl_Mode = 2;

  glDisable( GL_DEPTH_TEST );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity();
  glOrtho( 0, wnd_Width, wnd_Height, 0, -1, 1 );
  glMatrixMode( GL_MODELVIEW );
  glLoadIdentity();
}

void gl_Set3DMode( float FOVY )
{
  ogl_Mode = 3;
  ogl_FOVY = FOVY;

  glColor4ub( 255, 255, 255, 255 );

  glEnable( GL_DEPTH_TEST );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity();
  gluPerspective( FOVY, wnd_Width / wnd_Height, ogl_zNear, ogl_zFar );
  glMatrixMode( GL_MODELVIEW );
  glLoadIdentity();
}

void gl_SetCurrentMode(void)
{
  if ( ogl_Mode == 2 )
    gl_Set2DMode();
  else
    gl_Set3DMode( ogl_FOVY );
  glViewport( 0, 0, wnd_Width, wnd_Height );
}
