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

#ifndef ZGL_WINDOW_LINUX_H
#define ZGL_WINDOW_LINUX_H

#include <string.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>

#include <GL/glx.h>

#include "../zgl_types.h"
#include "zgl_screen.h"
#include "../zgl_window.h"
#include "zgl_opengl.h"

extern Window               wnd_Handle;
extern Window               wnd_Root;
extern XClassHint           wnd_Class;
extern XSetWindowAttributes wnd_Attr;
extern uint                 wnd_ValueMask;
extern Atom                 wnd_DestroyAtom;
extern Atom                 wnd_Protocols;
extern Cursor               wnd_Cursor;

#endif
