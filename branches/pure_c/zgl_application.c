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

#include "zgl_application.h"

/* callback functions */
void (*app_cbInit)(void);
void (*app_cbDraw)(void);
void (*app_cbExit)(void);

/* states */
bool app_Initialized;
bool app_Work;
uint app_Flags = WND_USE_AUTOCENTER | APP_USE_LOG | COLOR_BUFFER_CLEAR | DEPTH_BUFFER | DEPTH_BUFFER_CLEAR | CROP_INVISIBLE;
bool app_Pause;
bool app_AutoPause = 1;
bool app_Focus;
bool app_Log;
int  app_FPS;
bool app_ShowCursor;

void app_Draw(void)
{
  scr_Clear();
  if ( app_cbDraw ) app_cbDraw();
  scr_Flush();
}

void app_MainLoop(void)
{
  if ( app_cbInit ) app_cbInit();

  while ( app_Work ) {
    app_Proc();

    if ( !app_Pause ) {
    } else {
        u_Sleep( 10 );
      }

    if ( app_Pause ) continue;
    app_Draw();
  }
  scr_Reset();
}
