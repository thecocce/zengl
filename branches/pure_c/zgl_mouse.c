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

#include "zgl_mouse.h"

int  mX;
int  mY;
bool mDown[3];
bool mUp[3];
bool mClick[3];
bool mCanClick[3];
bool mWheel[2];
bool mLock;

int mouse_X(void)
{
  return mX;
}

int mouse_Y(void)
{
  return mY;
}

int mouse_DX(void)
{
  if ( mLock )
    return mX - wnd_Width / 2;
  else
    return 0;
}

int mouse_DY(void)
{
  if ( mLock )
    return mY - wnd_Height / 2;
  else
    return 0;
}

bool mouse_Down( int Button )
{
  return mDown[ Button ];
}

bool mouse_Up( int Button )
{
  return mUp[ Button ];
}

bool mouse_Click( int Button )
{
  return mClick[ Button ];
}

bool mouse_Wheel( int Axis )
{
  return mWheel[ Axis ];
}

void mouse_ClearState(void)
{
  memset( mUp, 0, 3 );
  memset( mClick, 0, 3 );
  memset( mCanClick, 1, 3 );
  memset( mWheel, 1, 2 );
}

void mouse_Lock(void)
{
  mLock = 1;
}
