{
 * Copyright © Kemka Andrey aka Andru
 * mail: dr.andru@gmail.com
 * site: http://andru.2x4.ru
 *
 * This library is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
}
unit zgl_const;

{$I define.inc}

interface

const
  // constant value
  cv_MaxCount = 1023;
  cv_pi       = 3.1415926;
  cv_pi180    = 3.1415926 / 180;

  // constant string
  cs_CopyLeft = '© ZenGL by Kemka Andrey aka Andru';
  cs_ZenGL    = 'ZenGL build 22[03.08.08]';

  // zgl_Reg
  SYS_LOAD             = $000001;
  SYS_DRAW             = $000002;
  SYS_EXIT             = $000003;
  TEX_FORMAT_EXTENSION = $000010;
  TEX_FORMAT_LOADER    = $000011;
  SND_FORMAT_EXTENSION = $000020;
  SND_FORMAT_LOADER    = $000021;

  // zgl_Get
  SYS_FPS      = 1;
  LOG_FILENAME = 2;

  // zgl_Enable/zgl_Disable
  COLOR_BUFFER_CLEAR = $000001;
  DEPTH_BUFFER       = $000002;
  DEPTH_BUFFER_CLEAR = $000004;
  CORRECT_RESOLUTION = $000008;
  APP_USE_AUTOPAUSE  = $000010;
  SND_CAN_PLAY       = $000020;
  SND_CAN_PLAY_FILE  = $000040;

  // Screen
  REFRESH_MAXIMUM = 0;
  REFRESH_DEFAULT = 1;

implementation

end.
