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

#include "zgl_main.h"

void zgl_Init( int FSAA, int StencilBits )
{
  log_Init();

  if ( !scr_Create() ) return;
  if ( !wnd_Create( wnd_Width, wnd_Height ) ) return;
  if ( !gl_Create() ) return;

  app_Work = 1;
  app_MainLoop();
}

void zgl_Exit(void)
{
  app_Work = 0;
  if ( app_cbExit ) app_cbExit();
}

void zgl_Reg( unsigned int What, void* UserData )
{
  switch ( What ) {
    case SYS_INIT: {
      app_cbInit = (void (*)())UserData;
      break;
    }
    case SYS_DRAW: {
      app_cbDraw = (void (*)())UserData;
      break;
    }
    case SYS_EXIT: {
      app_cbExit = (void (*)())UserData;
      break;
    }
  }
}

void zgl_Enable( uint What )
{
  app_Flags |= What;

  if ( What && DEPTH_BUFFER ) glEnable( GL_DEPTH_TEST );

  if ( What && DEPTH_MASK ) glDepthMask( GL_TRUE );

  if ( What && APP_USE_AUTOPAUSE ) app_AutoPause = 0;

  if ( What && APP_USE_LOG ) {
    app_Log = 1;
    log_Init();
  }

  /* if ( What && SND_CAN_PLAY ) sndCanPlay = 1;

  if ( What && SND_CAN_PLAY_FILE ) sndCanPlayFile = 1; */
}

void zgl_Disable( uint What )
{
  if ( app_Flags && What ) app_Flags ^= What;

  if ( What && DEPTH_BUFFER ) glDisable( GL_DEPTH_TEST );

  if ( What && DEPTH_MASK ) glDepthMask( GL_FALSE );

  if ( What && APP_USE_AUTOPAUSE ) app_AutoPause = 0;

  if ( What && APP_USE_LOG ) {
    if ( log_file ) log_Close();
    app_Log = 0;
  }

  /* if ( What && SND_CAN_PLAY ) sndCanPlay = 0;

  if ( What && SND_CAN_PLAY_FILE ) sndCanPlayFile = 0; */
}
