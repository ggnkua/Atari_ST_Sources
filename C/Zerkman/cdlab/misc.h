/*
 * MISC.H - Fonctions de gestion diverses
 *
 * Copyright 2004 Francois Galea
 *
 * This file is part of CDLab.
 *
 * CDLab is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * CDLab is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

extern char version_string[];

int read_messages_file( const char * filename );
char * get_string( const char * name );
int alert_msg( const char * msg, int deflt, ... );
int alert_freemsg( const char * msg, int deflt );
long timer( void );
void progress_init( const char * title_msg, long max );
void progress_exit( void );
void progress_init_timer( void );
void progress_activate_cancel( int activate );
void progress_setinfo( char * info );
void progress_setcount( long count );
void progress_display( void );
int progress_calc_prct( void );
int yield( void );
void busybee( void );
void arrow( void );
void zdelay( long ticks );
unsigned char hex2bcd( unsigned char hex );
unsigned char bcd2hex( unsigned char bcd );
long logical( int m, int s, int f );
void msf( long logical, int * minute, int * second, int * frame );
void * alloc_comm_buffer( long amount );
void free_comm_buffer( void * adr );
void * xmalloc( size_t size );
void * xrealloc( void * ptr, size_t size );

