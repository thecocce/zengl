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

#ifndef ZGL_WINDOW_H
#define ZGL_WINDOW_H

#include <stdio.h>

#include "zgl_types.h"
#include "zgl_main.h"

extern int  wnd_X;
extern int  wnd_Y;
extern int  wnd_Width;
extern int  wnd_Height;
extern bool wnd_FullScreen;

extern bool wnd_Create( int Width, int Height );
extern void wnd_Destroy(void);
extern void wnd_Update(void);
extern void wnd_SetCaption( const char* Caption );
extern void wnd_SetPos( int X, int Y );
extern void wnd_SetSize( int Width, int Height );

#endif
