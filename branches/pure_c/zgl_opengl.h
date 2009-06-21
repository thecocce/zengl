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

#ifndef ZGL_OPENGL_H
#define ZGL_OPENGL_H

#include "zgl_types.h"

extern int  ogl_zDepth;
extern int  ogl_Stencil;
extern bool ogl_FSAA;

extern int ogl_Width;
extern int ogl_Height;

extern bool ogl_CanVSync;

extern bool gl_Create(void);
extern void gl_Destroy(void);
extern void gl_LoadExtensions(void);

#endif
