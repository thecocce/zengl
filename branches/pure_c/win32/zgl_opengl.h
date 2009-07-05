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

#ifndef ZGL_OPENGL_WIN32_H
#define ZGL_OPENGL_WIN32_H

#include <windows.h>
#include <GL/gl.h>

#include "../zgl_types.h"
#include "zgl_screen.h"
#include "../zgl_opengl.h"

/* Pixel Format */
#define WGL_DRAW_TO_WINDOW_ARB    0x2001
#define WGL_ACCELERATION_ARB      0x2003
#define WGL_FULL_ACCELERATION_ARB 0x2027
#define WGL_SUPPORT_OPENGL_ARB    0x2010
#define WGL_DOUBLE_BUFFER_ARB     0x2011
#define WGL_COLOR_BITS_ARB        0x2014
#define WGL_ALPHA_BITS_ARB        0x201B
#define WGL_DEPTH_BITS_ARB        0x2022
#define WGL_STENCIL_BITS_ARB      0x2023

/* AA */
#define WGL_SAMPLE_BUFFERS_ARB    0x2041
#define WGL_SAMPLES_ARB           0x2042

extern HGLRC ogl_Context;
extern float ogl_fAttr[2];
extern int   ogl_iAttr[32];
extern int   ogl_Format;
extern uint  ogl_Formats;

#define wglGetAddress( a, b ) a = (void*)wglGetProcAddress( (GLubyte*)b )

extern bool (*wglChoosePixelFormatARB)(HDC, const int *, const float *, uint, int *, uint *);
extern bool (*wglSwapIntervalEXT)(GLint);
extern GLint (*wglGetSwapIntervalEXT)(void);

#endif
