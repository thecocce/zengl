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

#include "zgl_utils.h"

void u_Error( const char* Error )
{
  printf( "%s\n", Error );
  char* tmp = (char*)malloc( 7 + strlen( Error ) );
  strcpy( tmp, "ERROR: " );
  strcat( tmp, Error );
  log_Add( tmp, 1 );
  free( tmp );
}

void u_Warning( const char* Warning )
{
  printf( "%s\n", Warning );
  char* tmp = (char*)malloc( 9 + strlen( Warning ) );
  strcpy( tmp, "WARNING: " );
  strcat( tmp, Warning );
  log_Add( tmp, 1 );
  free( tmp );
}

void u_Sleep( int msec )
{
  struct timeval tv;
  tv.tv_sec  = msec / 1000;
  tv.tv_usec = ( msec % 1000 ) * 1000;
  select( 0, NULL, NULL, NULL, &tv );
}
