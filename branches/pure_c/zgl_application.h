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

#ifndef ZGL_APPLICATION_H
#define ZGL_APPLICATION_H

#include <unistd.h>

#include "zgl_types.h"
#include "zgl_main.h"

/* callback functions */
extern void (*app_cbInit)(void);
extern void (*app_cbDraw)(void);
extern void (*app_cbExit)(void);

/* states */
extern bool app_Work;
extern uint app_Flags;
extern bool app_Pause;
extern bool app_AutoPause;
extern bool app_Focus;
extern bool app_Log;
extern int  app_FPS;

extern void app_MainLoop(void);
extern void app_Draw(void);
extern void app_ProcessMessages(void);

#endif
