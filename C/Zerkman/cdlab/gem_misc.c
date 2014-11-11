/*
 * GEM_MISC.C - Fonctions diverses non SCSI
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

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <stdarg.h>
#include <tos.h>
#include <windom.h>

#include "rsc/cdlab.h"
#include "main.h"
#include "misc.h"
#include "prefs.h"
#include "log.h"

#define MAX_MESSAGES_COUNT 0x0100   /* Nombre de messages maxi */
#define MAX_MESSAGES_SIZE  0x2000   /* Taille maximum à réserver pour les messages */

WINDOW * progress_win = NULL;
OBJECT * progress_tree = NULL;

const struct _message
{
  char * name;
  char * value;
} messages[ MAX_MESSAGES_COUNT ];
char messages_value[ MAX_MESSAGES_SIZE ];
int messages_count;

int progress_exitflag;
int progress_prct;
long progress_max, progress_count;
char *progress_info;
long progress_start_time;
#define PROGRESS_REFRESH_RATE (3*200)
long progress_next_refresh;

int bee_count = 0;

int read_messages_file( const char * filename )
{
  char buf[256];
  FILE * fd;
  char * pos, *msg_pos;

  fd = fopen( filename, "r" );
  if( !fd ) return -1;

  messages_count = 0;
  msg_pos = messages_value;

  while( !feof( fd ) )
  {
    fgets( buf, 255, fd );
    pos = strchr( buf, '=' );
    if( pos )
    {
      pos[ 0 ] = 0;
      pos++;
      strcpy( msg_pos, buf );
      messages[ messages_count ].name = msg_pos;
      msg_pos = msg_pos + strlen( msg_pos ) + 1;
      strcpy( msg_pos, pos );
      messages[ messages_count ].value = msg_pos;
      msg_pos = msg_pos + strlen( msg_pos );
      msg_pos[-1] = 0;
      messages_count++;
    }
  }
  fclose( fd );
  return 0;
}

char * get_string( const char * name )
{
  int i;
  i = 0;
  while( i<messages_count && strcmp( messages[i].name, name ) )
    i++;
  if( i<messages_count )
    return messages[i].value;
  return (char *) name;
}

int alert_msg( const char * msg, int deflt, ... )
{
  va_list arg;
  char message[200];

  if( !msg ) return 0;
  va_start( arg, 0 );
  vsprintf( message, get_string( msg ), arg );
  va_end( arg );
  return alert_freemsg( message, deflt );
}

int alert_freemsg( const char * msg, int deflt )
{
  char buf[32];
  int ret, i;
  log_write( msg );
  strcpy( buf, " -> " );
  ret = form_alert( deflt, msg );
  for( i=0; i<3; i++ ) while( *msg++ != '[' );
  for( i=1; i<ret; i++ ) while( *msg++ != '|' );
  for( i=0; i<19 && *msg != '|' && *msg != ']'; i++ )
    buf[i+4] = *msg++;
  buf[i+4] = 0;
  strcat( buf, "\n" );
  log_write( buf );
  return ret;
}

long timer( void )
{
  void * ssp;
  long ret;
  ssp = (void *)Super( NULL );
  ret = *((long *)0x4BA);
  Super( ssp );
  return ret;
}

void progress_init( const char * title_msg, long max )
{
  rsrc_gaddr( 0, PROC_BOX, &progress_tree );
  progress_tree[PB_PROGBAR].ob_width = 0;
  progress_tree[PB_CANCEL].ob_state &= ~SELECTED;
  strcpy( ObjcString( progress_tree, PB_ELATIME, NULL ), "--:--" );
  strcpy( ObjcString( progress_tree, PB_REMTIME, NULL ), "--:--" );
  ObjcString( progress_tree, PB_STATUS, "" );
  if( preferences.pref_flags.multitask )
  {
    progress_tree[0].ob_state &= ~OUTLINED;
    progress_tree[PB_CANCEL].ob_flags &= ~HIDETREE;
    progress_tree[PB_ESC].ob_flags |= HIDETREE;
    progress_win = FormWindBegin( progress_tree, get_string( title_msg ) );
  }
  else
  {
    /* MouseWork(); */
    graf_mouse( BUSYBEE, NULL );
    progress_tree[0].ob_state |= OUTLINED;
    progress_tree[PB_CANCEL].ob_flags |= HIDETREE;
    progress_tree[PB_ESC].ob_flags &= ~HIDETREE;
    FormBegin( progress_tree, NULL );
  }

  progress_exitflag = 0;
  progress_max = max;
  progress_count = 0;
  progress_info = NULL;
  progress_start_time = 0;
  progress_next_refresh = 0;
}

void progress_exit( void )
{
  if( preferences.pref_flags.multitask )
    FormWindEnd();
  else
  {
    graf_mouse( ARROW, NULL );
    FormEnd( progress_tree, NULL );
  }
  progress_win = NULL;
  progress_tree = NULL;
}

void progress_init_timer( void )
{
  progress_start_time = timer();
  progress_next_refresh = progress_start_time;
}

void progress_display_object( int obj )
{
  int x, y;
  objc_offset( progress_tree, obj, &x, &y );
  if( preferences.pref_flags.multitask )
  {
    ApplWrite( app.id, WM_REDRAW, progress_win->handle, x, y,
               progress_tree[obj].ob_width,
               progress_tree[obj].ob_height );
    /* yield(); */
  }
  else
    objc_draw( progress_tree, 0, MAX_DEPTH, x, y,
             progress_tree[obj].ob_width,
             progress_tree[obj].ob_height );
}

void progress_activate_cancel( int activate )
{
  if( !progress_tree ) return;
  if( (!activate) != !(progress_tree[ PB_ESC ].ob_state&DISABLED) )
    return;
  if( activate )
  {
    progress_tree[ PB_CANCEL ].ob_state &= ~DISABLED;
    progress_tree[ PB_ESC ].ob_state &= ~DISABLED;
  }
  else
  {
    progress_tree[ PB_CANCEL ].ob_state |= DISABLED;
    progress_tree[ PB_ESC ].ob_state |= DISABLED;
  }

  if( preferences.pref_flags.multitask )
    progress_display_object( PB_CANCEL );
  else
    progress_display_object( PB_ESC );
}

void progress_setinfo( char * info )
{
  /*if( progress_info != info )
  {*/
    ObjcString( progress_tree, PB_STATUS, info );
    progress_display_object( PB_STATUS );
    progress_info = info;
    progress_display();
  /*} */
}

void progress_setcount( long count )
{
  progress_count = count;
  if( progress_calc_prct() != progress_prct )
    progress_display();
}

void progress_display( void )
{
  int x, y, w;
  int anc_width;
  if( progress_info )
  {
    progress_prct = progress_calc_prct();
    anc_width = progress_tree[PB_PROGBAR].ob_width;
    w = (int)((long)progress_tree[PB_PROGBACK].ob_width * progress_prct / 100);
    progress_tree[PB_PROGBAR].ob_width = w;
    objc_offset( progress_tree, PB_PROGBACK, &x, &y );
    x += anc_width;
    w -= anc_width;
    if( preferences.pref_flags.multitask )
      ObjcWindDraw( progress_win, progress_tree, PB_PROGBACK, MAX_DEPTH,
                    x, y-3, w+3, progress_tree[PB_PROGBACK].ob_height+6 );
    else
      objc_draw( progress_tree, PB_PROGBACK, MAX_DEPTH,
                 x, y-3, w+3, progress_tree[PB_PROGBACK].ob_height+6 );
  }
}

int progress_calc_prct( void )
{
  return (int)(progress_count*100/progress_max);
}

/* Fonction appelée continuellement en cours de traitement */
int yield( void )
{
  int ret;
  long time, elapsed, remaining;
  evnt.timer = 0;
  if( preferences.pref_flags.multitask )
  {
    ret = FormWindDo( FORM_EVNT|MU_MESAG|MU_TIMER );
    if( !(ret & FORM_EVNT) )
    {
      if( ret == PB_CANCEL )
        progress_exitflag = 1;
    }
  } else
  {
    ret = EvntWindom( MU_KEYBD|MU_TIMER );
    if( (ret & MU_KEYBD) && evnt.keybd == 0x11b )
      progress_exitflag = 1;
  }
  if( progress_start_time )
  {
    time = timer();
    if( time > progress_next_refresh )
    {
      elapsed = (time - progress_start_time) / 200;
      remaining = progress_count
                  ? (progress_max * elapsed / progress_count - elapsed)
                  : 0;
      sprintf( ObjcString( progress_tree, PB_ELATIME, NULL ),
               "%02d:%02d", (int)(elapsed/60), (int)(elapsed%60) );
      if( remaining > 0 )
        sprintf( ObjcString( progress_tree, PB_REMTIME, NULL ),
                 "%02d:%02d", (int)(remaining/60), (int)(remaining%60) );
      progress_display_object( PB_ELATIME );
      progress_display_object( PB_REMTIME );
      progress_next_refresh = time + PROGRESS_REFRESH_RATE;
    }
  }
  return progress_exitflag;
}

void busybee( void )
{
  if( bee_count == 0 )
    graf_mouse( BUSYBEE, NULL );
  bee_count++;
}

void arrow( void )
{
  bee_count--;
  if( bee_count == 0 )
    graf_mouse( ARROW, NULL );
}

/* Attend ticks/200 secondes */
void zdelay( long ticks )
{
  busybee();
  evnt.timer = ticks;
  EvntWindom( MU_TIMER );
  arrow();
}

unsigned char hex2bcd( unsigned char hex )
{
  return ((hex/10)<<4)|(hex%10);
}

unsigned char bcd2hex( unsigned char bcd )
{
  return (bcd/16*10 + bcd%16);
}

/* Conversion d'adresse MSF en adresse logique */
long logical( int m, int s, int f )
{
  return (long)m*4500L + (long)s*75L + (long)f -150L;
}

/* conversion d'adresse logique en adresse MSF */
void msf( long logical, int * minute, int * second, int * frame )
{
  long adr;
  adr = logical + 150;
  if( adr < 0 ) adr += 450000L; /* + 100 minutes */
  *minute = (int)((adr)/(75*60));
  *second = (int)((adr)%(75*60)/75);
  *frame  = (int)((adr)%(75*60)%75);
}

/* Allocation d'un buffer en vue d'utilisation pour une transmission */
void * alloc_comm_buffer( long amount )
{
  void * alloc_adr;
  alloc_adr = Mxalloc( amount, 0 );
  if( !alloc_adr )
    alert_msg( "AL_FREEMEM", 1 );
  return alloc_adr;
}

/* Libération d'un bloc alloué avec alloc_comm_buffer */
void free_comm_buffer( void * adr )
{
  Mfree( adr );
}

/* Gestionnaire de mémoire avancé */
void * xmalloc( size_t size )
{
  void * p = malloc( size );
  if( !p )
    alert_msg( "AL_FREEMEM", 1 );
  else
    memset( p, 0, size );
  return p;
}

void * xrealloc( void * ptr, size_t size )
{
  void * p = realloc( ptr, size );
  if( !p )
    alert_msg( "AL_FREEMEM", 1 );
  return p;
}

