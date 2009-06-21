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

#ifndef ZGL_WINDOW_WIN32_H
#define ZGL_WINDOW_WIN32_H

#include <string.h>

#include <windows.h>

#include "../zgl_types.h"
#include "zgl_screen.h"
#include "../zgl_window.h"
#include "zgl_opengl.h"
#include "../zgl_opengl.h"

extern bool       wnd_First; // Microsoft Sucks! :)
extern HWND       wnd_Handle;
extern HDC        wnd_DC;
extern HINSTANCE  wnd_INST;
extern WNDCLASSEX wnd_Class;
extern char*      wnd_ClassName;
extern uint       wnd_Style;
extern int        wnd_CpnSize;
extern int        wnd_BrdSizeX;
extern int        wnd_BrdSizeY;

extern void wnd_Select(void);

#endif
