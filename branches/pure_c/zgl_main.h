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

#ifndef ZGL_MAIN_H
#define ZGL_MAIN_H

#include <GL/gl.h>

#include "zgl_application.h"
#include "zgl_screen.h"
#include "zgl_window.h"
#include "zgl_opengl.h"
#include "zgl_log.h"

#define ZENGL_VERSION "ZenGL 0.1.28"

#define SYS_INIT   0x000001
#define SYS_DRAW   0x000002
#define SYS_UPDATE 0x000003
#define SYS_EXIT   0x000004

#define SYS_FPS         1
#define APP_PAUSED      2
#define APP_DIRECTORY   3
#define USR_HOMEDIR     4
#define LOG_FILENAME    5
#define ZGL_VERSION     6
#define SCR_ADD_X       7
#define SCR_ADD_Y       8
#define DESKTOP_WIDTH   9
#define DESKTOP_HEIGHT  10
#define RESOLUTION_LIST 11
#define MANAGER_TIMER   12
#define MANAGER_TEXTURE 13
#define MANAGER_FONT    14
#define MANAGER_RTARGET 15
#define MANAGER_SOUND   16
#define MANAGER_GUI     17

#define COLOR_BUFFER_CLEAR    0x000001
#define DEPTH_BUFFER          0x000002
#define DEPTH_BUFFER_CLEAR    0x000004
#define DEPTH_MASK            0x000008
#define STENCIL_BUFFER_CLEAR  0x000010
#define CORRECT_RESOLUTION    0x000020
#define APP_USE_AUTOPAUSE     0x000040
#define APP_USE_LOG           0x000080
#define APP_USE_ENGLISH_INPUT 0x000100
#define APP_USE_UTF8          0x000200
#define WND_USE_AUTOCENTER    0x000400
#define SND_CAN_PLAY          0x000800
#define SND_CAN_PLAY_FILE     0x001000
#define CROP_INVISIBLE        0x002000

extern void zgl_Init( int FSAA, int StencilBits );
extern void zgl_Exit(void);
extern void zgl_Reg( uint What, void* UserData );
extern void zgl_Enable( uint What );
extern void zgl_Disable( uint What );

#endif
