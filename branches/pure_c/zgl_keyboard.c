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

#include "zgl_keyboard.h"

bool  kDown[256];
bool  kUp[256];
bool  kPress[256];
bool  kCanPress[256];
char* kText;
int   kMax;
char  kLast[2];

bool key_Down( int KeyCode )
{
  return kDown[ KeyCode ];
}

bool key_Up( int KeyCode )
{
  return kUp[ KeyCode ];
}

bool key_Press( int KeyCode )
{
  return kPress[ KeyCode ];
}

int  key_Last( int KeyAction )
{
  return kLast[ KeyAction ];
}

void key_ClearState(void)
{
  memset( kUp, 0, 256 );
  memset( kPress, 0, 256 );
  memset( kCanPress, 1, 256 );
  memset( kLast, 0, 2 );
}

int SCA( int KeyCode )
{
  if ( ( KeyCode == K_SHIFT_L ) || ( KeyCode == K_SHIFT_R ) ) return K_SHIFT;
  if ( ( KeyCode == K_CTRL_L ) || ( KeyCode == K_CTRL_R ) ) return K_CTRL;
  if ( ( KeyCode == K_ALT_L ) || ( KeyCode == K_ALT_R ) ) return K_ALT;
  return KeyCode;
}

void DoKeyPress( int KeyCode )
{
  if ( kCanPress[ KeyCode ] ) {
    kPress   [ KeyCode ] = 1;
    kCanPress[ KeyCode ] = 0;
  }
}
