/*
 * DEV_WIN.C - Fenêtre d'info des devices
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
#include <string.h>
#include <stdlib.h>
#include <windom.h>

#include "rsc/cdlab.h"
#include "ext_scsi.h"
#include "log.h"
#include "dao.h"
#include "misc.h"
#include "device.h"
#include "main.h"
#include "prefs.h"
#include "dev_win.h"

struct popup_item reader_popup_items[ MAX_DEVICES ];
struct popup_item writer_popup_items[ MAX_DEVICES ];
struct popup_str rddev_popup = { DB_RDUNIT, reader_popup_items, 0, 0 };
struct popup_str wrdev_popup = { DB_WRUNIT, writer_popup_items, 0, 0 };

struct
{
  int reader_sel;
  int writer_sel;
} dev_info;

int dev_insert_open( struct device_info * info, int open )
{
  int ret;
  struct device * dev;

  dev = open_device( info->id, info->bus_no );
  if( !dev ) return -1;
  if( open ) prevent_allow_medium_removal( 0 );
  ret = start_stop_unit( 1, 1, !open );
  close_device( dev );
  return ret;
}

int dev_redetect( void )
{
  int ret;
  struct ext_toc toc;
  struct device_info * info;
  struct device * dev;

  log_begin();
  ret = 0;
  info = (struct device_info*)rddev_popup.item[rddev_popup.selected].info;
  if( alert_msg( "AL_INSERTCDDA", 1, info->desc ) == 1 )
  {
    busybee();
    info->sets->audio_mode = AM_AUTODETECT;
    info->sets->write_mode = WT_AUTODETECT;
    dev = open_device( info->id, info->bus_no );
    if( dev )
    {
      start_cd();
      autodetect_ms10();
      get_ext_toc( &toc );
      autodetect_audiomode( &toc );
      autodetect_writemode( 1 );
      close_device( dev );
    }
    else
      ret = -1;
    arrow();
  }
  log_end();
  return ret;
}

void dev_default( OBJECT * tree )
{
  struct device_info * info;
  int i;
  for( i=1; i<rddev_popup.item_count; i++ )
  {
    info = (struct device_info *)rddev_popup.item[i].info;
    if( info->id == preferences.dev_rd_id
        && info->bus_no == preferences.dev_rd_bus )
      rddev_popup.selected = i;
  }
  for( i=1; i<wrdev_popup.item_count; i++ )
  {
    info = (struct device_info *)wrdev_popup.item[i].info;
    if( info->id == preferences.dev_wr_id
        && info->bus_no == preferences.dev_wr_bus )
      wrdev_popup.selected = i;
  }

  tree[ DB_RDUNIT ].ob_spec.free_string = rddev_popup.item[rddev_popup.selected].text;
  tree[ DB_WRUNIT ].ob_spec.free_string = wrdev_popup.item[wrdev_popup.selected].text;
}

void dev_valid( OBJECT * tree )
{
  struct device_info * info;

  info = (struct device_info*)rddev_popup.item[rddev_popup.selected].info;
  preferences.dev_rd_id = info->id;
  preferences.dev_rd_bus = info->bus_no;
  info = (struct device_info*)wrdev_popup.item[wrdev_popup.selected].info;
  if( tree[ DB_WRRAW ].ob_state & SELECTED )
    info->sets->flags |= DSF_PREF_RAW;
  else
    info->sets->flags &= ~DSF_PREF_RAW;
  preferences.dev_wr_id = info->id;
  preferences.dev_wr_bus = info->bus_no;
}

void dev_gestion_acces( OBJECT * tree )
{
  struct device_info * r_info, * w_info;
  const static char * wt_info[] =
    { "TXT_WRPHILIPS", "TXT_WRTEAC", "TXT_WRMMC" };
  int type; /*, enable, change; */

  r_info = (struct device_info *)rddev_popup.item[rddev_popup.selected].info;
  w_info = (struct device_info *)wrdev_popup.item[wrdev_popup.selected].info;

  if( r_info && (dev_info.reader_sel != rddev_popup.selected) )
  {
    dev_info.reader_sel = rddev_popup.selected;
    strcpy( tree[ DB_RDREV ].ob_spec.free_string, r_info->sets->dev_id.revision_level );
    strcpy( tree[ DB_RDDATE ].ob_spec.free_string, r_info->sets->dev_id.revision_date );
    if( r_info->sets->max_read_speed )
      sprintf( tree[ DB_RDSPEED ].ob_spec.free_string, "%dx", r_info->sets->max_read_speed );
    else
      strcpy( tree[ DB_RDSPEED ].ob_spec.free_string, "????" );

    objc_select( tree, DB_RDCDRW, r_info->sets->flags & DSF_READ_CDRW );

    type = r_info->sets->audio_mode;
    ObjcString( tree, DB_AUDIOSTR, get_string(
                (type<0)?"TXT_AUDNDET":(type==0)?"TXT_AUDNOK":"TXT_AUDOK" ) );

    objc_redraw( tree, DB_AUDIOSTR );
    objc_redraw( tree, DB_RDREV );
    objc_redraw( tree, DB_RDDATE );
    objc_redraw( tree, DB_RDSPEED );
  }
  if( w_info && (dev_info.writer_sel != wrdev_popup.selected) )
  {
    dev_info.writer_sel = wrdev_popup.selected;
    ObjcString( tree, DB_WRTYPE, ( w_info->sets->write_mode > 0 ) ?
                get_string( wt_info[ w_info->sets->write_mode - 1 ] ) : "???" );

    if( w_info->sets->max_write_speed )
      sprintf( tree[ DB_WRSPEED ].ob_spec.free_string, "%dx", w_info->sets->max_write_speed );
    else
      strcpy( tree[ DB_WRSPEED ].ob_spec.free_string, "????" );

    objc_select( tree, DB_WRRAW, w_info->sets->flags & DSF_PREF_RAW );
    objc_lock( tree, DB_WRRAW, !(w_info->sets->flags&DSF_SUP_SAO_WR
               && w_info->sets->flags&DSF_SUP_RAW_WR) );

    objc_redraw( tree, DB_WRTYPE );
    objc_select( tree, DB_WRTAO, w_info->sets->flags&DSF_IS_WRITER );
    objc_select( tree, DB_WRDAO, w_info->sets->flags&DSF_SUP_DAO_WR );
    objc_select( tree, DB_WRCDRW, w_info->sets->flags&DSF_WRITE_CDRW );
    objc_redraw( tree, DB_WRSPEED );
  }
}

void dev_clicked( WINDOW * win )
{
  OBJECT * form;
  int obj;
  form = FORM(win);
  obj = evnt.buff[4];

  switch( obj )
  {
  case DB_OK:
    dev_valid( form );
  case DB_CANCEL:
    ApplWrite( app.id, WM_DESTROY, win->handle );
    break;
  case DB_RDUCYC:
  case DB_RDUNIT:
    popup_mgr( win, &rddev_popup, obj );
    dev_gestion_acces( form );
    break;
  case DB_REDETECT:
    dev_redetect();
    dev_info.reader_sel = -1;
    dev_info.writer_sel = -1;
    dev_gestion_acces( form );
    break;
  case DB_OPEN:
  case DB_CLOSE:
    dev_insert_open( rddev_popup.item[rddev_popup.selected].info, obj == DB_OPEN );
    break;
  case DB_WRUCYC:
  case DB_WRUNIT:
    popup_mgr( win, &wrdev_popup, obj );
    dev_gestion_acces( form );
    break;
  default:
    dev_gestion_acces( form );
    break;
  }
}

void dev_open( void )
{
  const static int thbut[] = {DB_ONG1, DB_ONG2};
  const static int thsub[] = {DB_FD1, DB_FD2};
  OBJECT * tree;
  WINDOW * win;
  gen_dev_popup( &rddev_popup, 0, 0 );
  gen_dev_popup( &wrdev_popup, DSF_IS_WRITER, 0 );

  if( rddev_popup.item_count == 0 && wrdev_popup.item_count == 0 )
  {
    alert_msg( "AL_NODEV", 1 );
    return;
  }
  rsrc_gaddr( 0, DEV_BOX, &tree );
  objc_lock( tree, DB_ONG2, wrdev_popup.item_count == 0 );
  dev_default( tree );
  dev_info.reader_sel = -1;
  dev_info.writer_sel = -1;
  dev_gestion_acces( tree );
  win = open_dialog( tree, get_string( "TXT_DEV" ) );
  FormThumb( win, thsub, thbut, (int)(sizeof( thsub ) / sizeof( int )) );
  EvntAttach( win, UE_CLICKED, dev_clicked );
}
