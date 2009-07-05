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

#ifndef ZGL_MOUSE_H
#define ZGL_MOUSE_H

#include "zgl_types.h"
#include "zgl_window.h"

#define M_BLEFT  0
#define M_BMIDLE 1
#define M_BRIGHT 2
#define M_WUP    0
#define M_WDOWN  1

extern int  mX;
extern int  mY;
extern bool mDown[3];
extern bool mUp[3];
extern bool mClick[3];
extern bool mCanClick[3];
extern bool mWheel[2];
extern bool mLock;

extern int  mouse_X(void);
extern int  mouse_Y(void);
extern int  mouse_DX(void);
extern int  mouse_DY(void);
extern bool mouse_Down( int Button );
extern bool mouse_Up( int Button );
extern bool mouse_Click( int Button );
extern bool mouse_Wheel( int Axis );
extern void mouse_ClearState(void);
extern void mouse_Lock(void);

#endif
