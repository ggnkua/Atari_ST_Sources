/*
 * Utility functions for Teradesk. Copyright 1993, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _BOOLEAN_
#include <boolean.h>
#endif

typedef struct
{
	long name;
	long value;
} COOKIE;

/* Funkties voor filenamen */

void make_path( char *name,const char *path,const char *fname );
void split_path( char *path,char *fname,const char *name );

/* Funkties voor cookie-jar */

long find_cookie( long name );		/* HR 151102: return cookie value or -1 */
int install_cookie( long name,long value,COOKIE *buffer,long l );

/* GEM uitbreidingen */

int aprintf( int def,const char *string, ... );

/* Funkties voor het bepalen van de TOS-versie */

int get_tosversion( void );
boolean tos1_4( void );
boolean tos2_0( void );
