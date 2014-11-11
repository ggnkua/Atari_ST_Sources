/*
 * PREFS.C - Gestion des préférences
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
#include <string.h>
#include <tos.h>
#include <windom.h>

#include "rsc/cdlab.h"
#include "log.h"
#include "misc.h"
#include "main.h"
#include "device.h"
#include "prefs.h"

#define PREF_FILE "CDLAB.INF"
#define PREF_VERSION 0x0002

struct pref_str preferences;

#define MAX_FRED_LOG 25

char log_fred[MAX_FRED_LOG+1];
char log_file[256];

void pref_gestion_acces( OBJECT * tree )
{
  int enable;
  if( !(tree[OB_INFO_TEMP].ob_state&SELECTED)
      == !(tree[OB_VALUE_TEMP].ob_flags&HIDETREE) )
     objc_enable( tree, OB_VALUE_TEMP, tree[OB_INFO_TEMP].ob_state&SELECTED);
  if( !(tree[OB_LOG].ob_state&SELECTED)
      == !(tree[OB_LOG_TEXT].ob_flags&HIDETREE) )
  {
    enable = tree[OB_LOG].ob_state&SELECTED;
    objc_enable( tree, OB_LOG_TEXT, enable );
    objc_enable( tree, OB_LOGFILE, enable );
    objc_enable( tree, OB_FLUSHLOG, enable );
  }
}

void pref_default( OBJECT * tree )
{
  char * p;

  objc_select( tree, OB_INFO_NONE, preferences.pref_flags.bubble==0 );
  objc_select( tree, OB_INFO_RBUT, preferences.pref_flags.bubble==1 );
  objc_select( tree, OB_INFO_TEMP, preferences.pref_flags.bubble==2 );
  p = tree[OB_VALUE_TEMP].ob_spec.tedinfo->te_ptext;
  sprintf( p, "%03d", preferences.bubble_delay );
  p+=3;
  while( *--p == '0' ) *p = 0;
  objc_select( tree, OB_PREEMP, preferences.pref_flags.multitask );

  objc_select( tree, OB_LOG, preferences.pref_flags.log );
  objc_select( tree, OB_FLUSHLOG, preferences.pref_flags.flushlog );
  strncpy( log_file, preferences.log_file, 255 );
  reduce_name( log_fred, log_file, MAX_FRED_LOG );
  ObjcString( tree, OB_LOGFILE, log_fred );

  objc_select( tree, OB_IGNERR, preferences.pref_flags.ignore_err );
  objc_select( tree, OB_INTERR, !preferences.pref_flags.ignore_err );
  sprintf( tree[ OB_RELECVAL ].ob_spec.tedinfo->te_ptext, "%d", preferences.retry_count );

  objc_select( tree, OB_EJECTSRC, preferences.pref_flags.eject_src );
  objc_select( tree, OB_EJECTDST, preferences.pref_flags.eject_dst );
  p = tree[ OB_TIMEOUT ].ob_spec.tedinfo->te_ptext;
  sprintf( p, "%02d", preferences.scsi_timeout / 200 );
}

void pref_clicked( WINDOW * win )
{
  OBJECT * form;
  char buf[256];
  char * p;
  int obj, i;

  form = FORM( win );
  obj = evnt.buff[4];
  switch( obj )
  {
  case OB_OK:
    if( form[OB_INFO_NONE].ob_state&SELECTED )
      preferences.pref_flags.bubble = 0;
    if( form[OB_INFO_RBUT].ob_state&SELECTED )
      preferences.pref_flags.bubble = 1;
    if( form[OB_INFO_TEMP].ob_state&SELECTED )
      preferences.pref_flags.bubble = 2;
    strcpy( buf, form[OB_VALUE_TEMP].ob_spec.tedinfo->te_ptext );
    buf[3] = 0;
    i = 3;
    while( buf[ --i ] == 0 ) buf[ i ] = '0';
    preferences.bubble_delay = atoi( buf );
    preferences.pref_flags.multitask = (form[OB_PREEMP].ob_state&SELECTED)?1:0;

    preferences.pref_flags.ignore_err = (form[OB_IGNERR].ob_state&SELECTED)?1:0;
    p = form[ OB_RELECVAL ].ob_spec.tedinfo->te_ptext;
    while( *p == ' ' ) p++;
    preferences.retry_count = atoi( p );

    preferences.pref_flags.log = (form[OB_LOG].ob_state&SELECTED)?1:0;
    strncpy( preferences.log_file, log_file, 255 );
    preferences.pref_flags.flushlog = (form[OB_FLUSHLOG].ob_state&SELECTED)?1:0;

    preferences.pref_flags.eject_src = (form[OB_EJECTSRC].ob_state&SELECTED)?1:0;
    preferences.pref_flags.eject_dst = (form[OB_EJECTDST].ob_state&SELECTED)?1:0;
    preferences.scsi_timeout = atoi( form[ OB_TIMEOUT ].ob_spec.tedinfo->te_ptext ) * 200;
    set_logfile( preferences.pref_flags.log?log_file:NULL );
  case OB_CANCEL:
    ApplWrite( app.id, WM_DESTROY, win->handle );
    break;
  /* case OB_LOG_TEXT: */
  case OB_LOGFILE:
    fileselect( log_file, "*.*", "IB_LOG" );
    reduce_name( log_fred, log_file, MAX_FRED_LOG );
    ObjcDraw( OC_FORM, win, OB_LOGFILE, MAX_DEPTH );
  default:
    pref_gestion_acces( form );
    break;
  }
}

void pref_load( void )
{
  int handle;
  memset( &preferences, 0, sizeof( preferences ) );
  handle = open( PREF_FILE, O_RDONLY );
  if( handle >= 0 )
  {
    read( handle, &preferences, sizeof( preferences ) );

    /* La taille du header est stockée à partir de la version 2 */
    if( preferences.version != PREF_VERSION )
    {
      close( handle );
      handle = -1;
      memset( &preferences, 0, sizeof( preferences ) );
    }
    else
    {
      set_logfile( preferences.pref_flags.log?preferences.log_file:NULL );
      if( preferences.dev_sets > MAX_DEV_SETS )
        preferences.dev_sets = MAX_DEV_SETS;
      dev_sets = preferences.dev_sets;
      read( handle, dev_set, sizeof( struct device_settings ) * dev_sets );
      close( handle );
    }
  }
  if( handle < 0 )
  {
    preferences.scsi_timeout = 30 * 200;
    preferences.retry_count = 6;
    preferences.pref_flags.bubble = 2;
    preferences.bubble_delay = 200;
    dev_sets = 0;
  }
}

void pref_save( void )
{
  char key_buf[8];
  DOSTIME tm;
  void * buf, *adr;
  OBJECT * obj;
  int i, handle, rschdl;
  size_t taille;
  handle = creat( PREF_FILE );
  if( handle >= 0 )
  {
    if( preferences.reg.ok && !reg_ok )
    {
      rschdl = open( rsc_name, O_RDWR );
      if( rschdl )
      {
        buf = xmalloc( 32768L );
        if( buf )
        {
          Fdatime( &tm, rschdl, 0 );
          preferences.reg.ok = 1;
          taille = read( rschdl, buf, 32768L );
          obj = (OBJECT *)(((char*)buf)
                + *((long *)(((char*)buf)+((short*)buf)[9]+4*REG_BOX)));
          adr = ((char*)buf) + obj[RB_REGINFO].ob_spec.index;
          for( i=0; i<8; i++ )
            key_buf[i] = ((preferences.reg.key[i*2]-1)<<4)
                         | ((preferences.reg.key[i*2+1]-1)&0x0f);
          memcpy( adr, key_buf, 8 );
          lseek( rschdl, 0, SEEK_SET );
          write( rschdl, buf, taille );
          Fdatime( &tm, rschdl, 1 );
          free( buf );
        }
        close( rschdl );
      }
    }
    preferences.version = PREF_VERSION;
    preferences.dev_sets = dev_sets;
    write( handle, &preferences, sizeof( preferences ) );
    write( handle, dev_set, sizeof( struct device_settings ) * dev_sets );
    close( handle );
  }
  set_logfile( NULL );
}

void pref_open( void )
{
  const static int thbut[] = {OB_ONG1, OB_ONG2, OB_ONG3, OB_ONG4};
  const static int thsub[] = {OB_FD1, OB_FD2, OB_FD3, OB_FD4};
  OBJECT * tree;
  WINDOW * win;
  rsrc_gaddr( 0, OPT_BOX, &tree );
  pref_default( tree );
  pref_gestion_acces( tree );
  win = open_dialog( tree, get_string( "TXT_PREFS" ) );
  FormThumb( win, thsub, thbut, (int)(sizeof( thsub ) / sizeof( int )) );
  EvntAttach( win, UE_CLICKED, pref_clicked );
}

