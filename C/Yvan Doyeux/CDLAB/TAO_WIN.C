/*
 * TAO_WIN.C - Fenêtre de masterisation en TAO
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

#include <windom.h>
#include <string.h>
#include <stdio.h>

#include "rsc/cdlab.h"
#include "log.h"
#include "prefs.h"
#include "device.h"
#include "ext_scsi.h"
#include "common.h"
#include "misc.h"
#include "main.h"
#include "iso9660.h"
#include "tao.h"

#define MAX_SPEEDS 32
#define MAX_FRED_SRC 34
#define MAX_FRED_DEST 40

char src_fred[MAX_FRED_SRC+1];
char src_file[256];
char dest_fred[MAX_FRED_DEST+1];
char dest_file[256];

struct popup_item speed_popup_items[ MAX_SPEEDS ];
struct popup_str speed_popup = { TB_SPEED, speed_popup_items, 0, 0 };
struct popup_item tao_popup_items[ MAX_DEVICES ];
struct popup_str tao_popup = { TB_DEST, tao_popup_items, 0, 0 };


int tao_launch2( int simul, int eject )
{
  char buf[256];
  size_t len;
  struct tao_ostream * out;
  struct tao_track * in[1];

  struct device_info * info;
  int ret;

  busybee();

  log_begin();
  log_printf( "*** Begin of a TAO write session\n\n" );

  info = tao_popup.item[ tao_popup.selected ].info;
  if( info )
    out = tao_open( info );
  else
    out = tao_open_file( dest_file );

  if( !out )
  {
    alert_msg( "AL_DAODSTERR", 1 );
    goto erreur;
  }

  len = strlen( src_file ) - 1;
  if( src_file[ len ] == '\\' )
  {
    memcpy( buf, src_file, len );
    buf[ len ] = '\0';
    in[0] = tao_track_new_ig( buf, 2048 );
  }
  else
    in[0] = tao_track_new_iso( src_file, 2048 );

  if( in[0] )
  {
    if( out->type == TAO_CDR )
    {
      set_dummy_write( simul );
      set_write_speed( preferences.tao_write_speed );
    }
    tao_pipe( in, 1, out );
    tao_track_dispose( in[0] );
  }
  tao_close( out );

  ret = 0;
  if( eject && preferences.pref_flags.eject_dst )
  {
    ret = prevent_allow_medium_removal( 0 );
    if( ret ) goto erreur;
    ret = start_stop_unit( 1, 1, 0 );
    if( ret ) goto erreur;
  }

  goto ok;
erreur:
  ret = -1;

ok:

  log_printf( "*** End of the TAO write session\n\n" );
  log_end();
  arrow();

  return ret;
}

int tao_launch( void )
{
  char * err;
  int ret, iso;
  iso = !tao_popup.selected;
  if( iso || preferences.tao_flags.simul )
  {
    ret = tao_launch2( 1, iso || !preferences.tao_flags.write_cd );
    if( ret )
      goto erreur;
  }
  if( (!iso) && preferences.tao_flags.write_cd )
  {
    ret = tao_launch2( 0, 1 );
    if( ret )
      goto erreur;
  }

  err = iso?"AL_ISOOK":"AL_TAOOK";
  goto ok;
erreur:
  err = iso?"AL_ISOERR":"AL_DAOWRTERR";
ok:
  alert_msg( err, 1 );
  return ret;
}

void tao_gestion_acces( OBJECT * form )
{
  int enable, change;

  objc_lock( form, TB_SPEED, speed_popup.item_count <= 1 );

  enable = tao_popup.selected;
  change = (!enable) == !(form[TB_WSTXT].ob_flags&HIDETREE);
  if( change )
  {
    objc_enable( form, TB_WSTXT, enable );
    objc_enable( form, TB_SPEED, enable );
    objc_enable( form, TB_ACTTXT, enable );
    objc_enable( form, TB_SIMUL, enable );
    objc_enable( form, TB_WR, enable );
  }

  objc_lock( form, TB_START,
      (tao_popup.selected == 0 && strlen( dest_file ) == 0)
      || strlen( src_file ) == 0
      || ( tao_popup.selected && !(form[TB_SIMUL].ob_state&SELECTED)
          && !(form[TB_WR].ob_state&SELECTED) ) );
}

void tao_default( OBJECT * form )
{
  struct device_info * info;
  int i;

  strncpy( src_file, preferences.tao_src_file, 255 );
  reduce_name( src_fred, src_file, MAX_FRED_SRC );
  strncpy( dest_file, preferences.tao_dest_file, 255 );
  reduce_name( dest_fred, dest_file, MAX_FRED_DEST );

  ObjcString( form, TB_SRC_FILE, src_fred );

  for( i=0; i<tao_popup.item_count; i++ )
  {
    info = (struct device_info *)tao_popup.item[i].info;
    if( info && info->id == preferences.tao_id
        && info->bus_no == preferences.tao_bus )
      tao_popup.selected = i;
  }
  if( preferences.tao_id < 0 )
    form[ TB_DEST ].ob_spec.free_string = dest_fred;
  else
    form[ TB_DEST ].ob_spec.free_string = tao_popup.item[tao_popup.selected].text;

  if( tao_popup.selected )
    gen_speed_popup( &speed_popup,
      ((struct device_info*)tao_popup.item[tao_popup.selected].info)->sets->max_write_speed );

  speed_popup.selected = 0;
  for( i=0; i<speed_popup.item_count; i++ )
  {
    if( *((unsigned int *)(speed_popup.item[i].info)) == preferences.tao_write_speed )
      speed_popup.selected = i;
  }
  form[ TB_SPEED ].ob_spec.free_string = speed_popup.item[speed_popup.selected].text;
  objc_select( form, TB_SIMUL, preferences.tao_flags.simul );
  objc_select( form, TB_WR, preferences.tao_flags.write_cd );
}

void tao_valid( OBJECT * form )
{
  struct device_info * info;
  info = tao_popup.item[tao_popup.selected].info;
  preferences.tao_id = (info?info->id:-1);
  preferences.tao_bus = (info?info->bus_no:-1);
  strncpy( preferences.tao_src_file, src_file, 255 );
  strncpy( preferences.tao_dest_file, dest_file, 255 );
  if( tao_popup.selected )
    preferences.tao_write_speed =
      *((unsigned int *)(speed_popup.item[speed_popup.selected].info));
  preferences.tao_flags.simul = (form[ TB_SIMUL ].ob_state&SELECTED)?1:0;
  preferences.tao_flags.write_cd = (form[ TB_WR ].ob_state&SELECTED)?1:0;
}

void tao_clicked( WINDOW * win )
{
  OBJECT * form;
  int obj;
  form = FORM(win);
  obj = evnt.buff[4];

  switch( obj )
  {
  case TB_SRC_TEXT:
  case TB_SRC_FILE:
    fileselect( src_file, "*.*", "TXT_SELTAOSRC" );
    reduce_name( src_fred, src_file, MAX_FRED_SRC );
    ObjcDraw( OC_FORM, win, TB_SRC_FILE, MAX_DEPTH );
    tao_gestion_acces( form );
    break;
  case TB_DEST:
  case TB_DSTCYC:
    if( popup_mgr( win, &tao_popup, obj ) == 0 )
    {
      fileselect( dest_file, "*.iso", "TXT_SELDST" );
      form[ TB_DEST ].ob_spec.free_string = dest_fred;
      reduce_name( dest_fred, dest_file, MAX_FRED_DEST );
      ObjcDraw( OC_FORM, win, TB_DEST, MAX_DEPTH );
    }

    if( tao_popup.selected )
    {
      gen_speed_popup( &speed_popup,
        ((struct device_info*)tao_popup.item[tao_popup.selected].info)->sets->max_write_speed );
      if( speed_popup.selected >= speed_popup.item_count )
        speed_popup.selected = speed_popup.item_count - 1;
    }
    form[ TB_SPEED ].ob_spec.free_string = speed_popup.item[speed_popup.selected].text;
    ObjcDraw( OC_FORM, win, TB_SPEED, MAX_DEPTH );

    tao_gestion_acces( form );
    break;
  case TB_SPEED:
  case TB_SPDCYC:
    if( speed_popup.item_count > 1 )
      popup_mgr( win, &speed_popup, obj );
    break;
  case TB_OK:
    tao_valid( form );
  case TB_CANCEL:
    ApplWrite( app.id, WM_DESTROY, win->handle );
    break;
  case TB_START:
    tao_valid( form );
    tao_launch();
    break;
  default:
    tao_gestion_acces( form );
    break;
  }
}

void tao_window_open( void )
{
  static char txt[MAX_FRED_DEST+1];
  OBJECT * tree;
  WINDOW * win;
  gen_dev_popup( &tao_popup, DSF_IS_WRITER, 1 );
  rsrc_gaddr( 0, TAO_BOX, &tree );

  sprintf( txt, "%-40s", get_string( "TXT_ISOFILE" ) );
  tao_popup.item[0].text = txt;

  tao_default( tree );
  tao_gestion_acces( tree );
  win = open_dialog( tree, get_string( "TXT_TAOTITLE" ) );
  EvntAttach( win, UE_CLICKED, tao_clicked );
}


