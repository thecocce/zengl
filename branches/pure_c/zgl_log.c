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

#include "zgl_log.h"

FILE *log_file;

void log_Init(void)
{
  if ( app_Flags && APP_USE_LOG == 0 ) return;
  if ( log_file ) return;
  app_Log = 1;

  log_file = fopen( "log.txt", "w+" );
  log_Add( "################", 0 );
  log_Add( "# ZenGL 0.1.28 #", 0 );
  log_Add( "################", 0 );
  log_Add( "Begin", 1 );
}

void log_Close(void)
{
  fclose( log_file );
}

void log_Add( const char* Message, bool Timings )
{
  char* tmp;
  if ( !Timings ) {
    tmp = (char*)malloc( strlen( Message ) + 2 );
    strcpy( tmp, Message );
    strcat( tmp, "\n" );
  } else {
      tmp = (char*)malloc( strlen( "[00000000ms] " ) + strlen( Message ) + 2 );
      strcpy( tmp, "[00000000ms] " );
      strcat( tmp, Message );
      strcat( tmp, "\n" );
    }

  fputs( tmp, log_file );
  log_Flush();
  free( tmp );
}

void log_Flush(void)
{
  fflush( log_file );
}
