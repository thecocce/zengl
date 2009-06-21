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

#ifndef ZGL_SCREEN_H
#define ZGL_SCREEN_H

#include "zgl_types.h"

#define REFRESH_DEFAULT 0
#define REFRESH_MAXIMUM 1

typedef struct {
  int Count;
  int *Width;
  int *Height;
} zglResolutionList;

extern int               scr_Width;
extern int               scr_Height;
extern int               scr_BPP;
extern int               scr_Refresh;
extern bool              scr_VSync;
extern int               desktop_Width;
extern int               desktop_Height;
extern zglResolutionList scr_ResList;

extern bool scr_Create(void);
extern void scr_SetOptions( int Width, int Height, int BPP, int Refresh, bool FullScreen, bool VSync );
extern void scr_Reset(void);
extern void scr_SetVSync( bool VSync );

extern void scr_Clear(void);
extern void scr_Flush(void);

#endif
