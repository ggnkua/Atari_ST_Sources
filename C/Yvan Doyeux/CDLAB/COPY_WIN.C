/*
 * COPY_WIN.C - Fenêtre de copie de CD
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
#include "log.h"
#include "device.h"
#include "misc.h"
#include "dao.h"
#include "main.h"
#include "prefs.h"
#include "copy_win.h"

#define MAX_SPEEDS 32
#define MAX_FRED_COPY 40
#define MAX_FRED_INT 37

static struct
{
  struct _copy_flags flags;
  int write_speed;
  struct device_info * source_dev;
  struct device_info * dest_dev;
  char source_fred[MAX_FRED_COPY+1];  /* nom (réduit) du fichier source */
  char dest_fred[MAX_FRED_COPY+1];    /* nom (réduit) du fichier destination */
  char source_file[256]; /* nom (éventuel) du fichier source */
  char dest_file[256];   /* nom (éventuel) du fichier destination */
  char int_fred[MAX_FRED_INT+1];      /* nom (réduit) du fichier intermédiaire */
  char int_file[256];    /* nom (éventuel) du fichier intermédiaire */
} copy_info;

static struct popup_item speed_popup_items[ MAX_SPEEDS ];
/*  = { "Simple      ", NULL, "Double      ", NULL, "Quadruple   ", NULL }; */
static struct popup_str speed_popup = { CB_SPEED, speed_popup_items, 0, 0 };

static struct popup_item source_popup_items[ MAX_DEVICES ];
static struct popup_item dest_popup_items[ MAX_DEVICES ];
static struct popup_str srcdev_popup = { CB_SOURCE, source_popup_items, 0, 0 };
static struct popup_str dstdev_popup = { CB_DEST, dest_popup_items, 0, 0 };

void copy_seltempfile( void )
{
  fileselect( copy_info.int_file, "*.cd", "TXT_SELINT" );
  reduce_name( copy_info.int_fred, copy_info.int_file, MAX_FRED_INT );
}

int dao_copy( unsigned short source, unsigned short dest,
              int simul, int ejsrc, int ejdst )
{
  int ret;
  struct idao_stream * in;
  struct odao_stream * out;

  log_begin();
  log_printf( "*** Begin of a DAO copy\n\n" );

  if( source == TST_FILE )
    in = idao_open_file( copy_info.source_file );
  else if( source == 20000 )
    in = idao_open_file( copy_info.int_file );
  else
    in = idao_open_cd( copy_info.source_dev );
  if( !in )
  {
    alert_msg( "AL_DAOSRCERR", 1 );
    return -1;
  }

  if( dest == TST_FILE )
    out = odao_open_file( copy_info.dest_file );
  else if( dest == 20000 )
    out = odao_open_file( copy_info.int_file );
  else
    out = odao_open_cd( copy_info.dest_dev );
  if( !out )
  {
    idao_close( in );
    alert_msg( "AL_DAODSTERR", 1 );
    return -1;
  }

  if( in->type == TST_CD )
  {
    if( ejsrc ) in->spec.cd.flags |= CDFLG_EJECT;
  }
  if( out->type == TST_CD )
  {
    if( ejdst ) out->spec.cd.flags |= CDFLG_EJECT;
    use_device( out->spec.cd.dev );
    set_dummy_write( simul );
    set_write_speed( copy_info.write_speed );
  }

  ret = dao_pipe( "TXT_COPY", in, out );

  odao_close( out );
  idao_close( in );

  log_printf( "*** End of the DAO copy\n\n" );
  log_end();

  return ret;
}

/* source et dest sont TST_FILE ou TST_CD */
int dao_launch( unsigned short source, unsigned short dest )
{
  int ret, use_tempfile, same_sd;

  same_sd = copy_info.source_dev == copy_info.dest_dev;
  use_tempfile = ( source == TST_CD && dest == TST_CD &&
                   ( copy_info.flags.use_hd || same_sd ) );
  if( use_tempfile )
  {
    if( !strlen( copy_info.int_file ) )
      copy_seltempfile();
    if( same_sd && alert_msg( "AL_INSERTSRC", 1, copy_info.source_dev->desc ) != 1 )
      return -2;
    ret = dao_copy( source, 20000, 0, 1, 0 );
    if( ret ) return ret;
    source = 20000;

    if( same_sd && alert_msg( "AL_INSERTDST", 1, copy_info.source_dev->desc ) != 1 )
      return -2;
  }
  if( dest == TST_CD && copy_info.flags.simul )
  {
    ret = dao_copy( source, dest, 1,
                    preferences.pref_flags.eject_src && !copy_info.flags.write_cd,
                    preferences.pref_flags.eject_dst || copy_info.flags.write_cd );
    if( ret ) return ret;
  }
  if( dest == TST_FILE || copy_info.flags.write_cd )
  {
    ret = dao_copy( source, dest, 0, preferences.pref_flags.eject_src, 
                    preferences.pref_flags.eject_dst );
    if( ret ) return ret;
  }

  if( use_tempfile && copy_info.flags.int_del )
    remove( copy_info.int_file );
  return 0;
}

void copy_default( OBJECT * tree )
{
  struct device_info * info;
  int i;
  struct _copy_flags f;
  for( i=1; i<srcdev_popup.item_count; i++ )
  {
    info = (struct device_info *)srcdev_popup.item[i].info;
    if( info->id == preferences.source_id
        && info->bus_no == preferences.source_bus )
      srcdev_popup.selected = i;
  }
  for( i=1; i<dstdev_popup.item_count; i++ )
  {
    info = (struct device_info *)dstdev_popup.item[i].info;
    if( info->id == preferences.dest_id
        && info->bus_no == preferences.dest_bus )
      dstdev_popup.selected = i;
  }
  strncpy( copy_info.source_file, preferences.source_file, 255 );
  strncpy( copy_info.dest_file, preferences.dest_file, 255 );
  strncpy( copy_info.int_file, preferences.int_file, 255 );
  reduce_name( copy_info.source_fred, copy_info.source_file, MAX_FRED_COPY );
  reduce_name( copy_info.dest_fred, copy_info.dest_file, MAX_FRED_COPY );
  reduce_name( copy_info.int_fred, copy_info.int_file, MAX_FRED_INT );
  if( preferences.source_id < 0 )
    tree[ CB_SOURCE ].ob_spec.free_string = copy_info.source_fred;
  else
    tree[ CB_SOURCE ].ob_spec.free_string = srcdev_popup.item[srcdev_popup.selected].text;
  if( preferences.dest_id < 0 )
    tree[ CB_DEST ].ob_spec.free_string = copy_info.dest_fred;
  else
    tree[ CB_DEST ].ob_spec.free_string = dstdev_popup.item[dstdev_popup.selected].text;
  if( dstdev_popup.selected )
    gen_speed_popup( &speed_popup,
      ((struct device_info*)dstdev_popup.item[dstdev_popup.selected].info)->sets->max_write_speed );
  speed_popup.selected = 0;
  for( i=0; i<speed_popup.item_count; i++ )
  {
    if( *((unsigned int *)(speed_popup.item[i].info)) == preferences.write_speed )
      speed_popup.selected = i;
  }
  tree[ CB_SPEED ].ob_spec.free_string = speed_popup.item[speed_popup.selected].text;
  tree[ CB_INTFILE ].ob_spec.free_string = copy_info.int_fred;

  tree[ CB_SIMUL ].ob_state &= ~SELECTED;
  tree[ CB_WR ].ob_state &= ~SELECTED;
  tree[ CB_USEHD ].ob_state &= ~SELECTED;
  tree[ CB_INTDEL ].ob_state &= ~SELECTED;
  f = preferences.copy_flags;
  tree[ CB_SIMUL ].ob_state |= f.simul?SELECTED:0;
  tree[ CB_WR ].ob_state |= f.write_cd?SELECTED:0;
  tree[ CB_USEHD ].ob_state |= f.use_hd?SELECTED:0;
  tree[ CB_INTDEL ].ob_state |= f.int_del?SELECTED:0;
}

void copy_valid( OBJECT * tree )
{
  if( srcdev_popup.selected == 0 ) /* Fichier source */
  {
    copy_info.source_dev = NULL;
    strncpy( preferences.source_file, copy_info.source_file, 255 );
  }
  if( dstdev_popup.selected == 0 ) /* Fichier destination */
  {
    copy_info.dest_dev = NULL;
    strncpy( preferences.dest_file, copy_info.dest_file, 255 );
  }
  strncpy( preferences.int_file, copy_info.int_file, 255 );
  copy_info.source_dev = (struct device_info*)srcdev_popup.item[srcdev_popup.selected].info;
  copy_info.dest_dev = (struct device_info*)dstdev_popup.item[dstdev_popup.selected].info;
  if( dstdev_popup.selected )
    copy_info.write_speed = *(unsigned int*)(speed_popup.item[speed_popup.selected].info);
  copy_info.flags.simul = ( tree[ CB_SIMUL ].ob_state&SELECTED ) ? 1 : 0;
  copy_info.flags.write_cd = ( tree[ CB_WR ].ob_state&SELECTED ) ? 1 : 0;
  copy_info.flags.use_hd = ( tree[ CB_USEHD ].ob_state&SELECTED ) ? 1 : 0;
  copy_info.flags.int_del = ( tree[ CB_INTDEL ].ob_state&SELECTED ) ? 1 : 0;

  preferences.source_id = copy_info.source_dev?copy_info.source_dev->id:-1;
  preferences.source_bus = copy_info.source_dev?copy_info.source_dev->bus_no:-1;
  preferences.dest_id = copy_info.dest_dev?copy_info.dest_dev->id:-1;
  preferences.dest_bus = copy_info.dest_dev?copy_info.dest_dev->bus_no:-1;
  if( dstdev_popup.selected )
    preferences.write_speed = copy_info.write_speed;
  preferences.copy_flags = copy_info.flags;
}

void copy_gestion_acces( OBJECT * tree )
{
  int enable, change;

  /* Onglet Copie */
  enable = ( speed_popup.item_count > 1 );
  change = enable == ((tree[ CB_SPEED ].ob_state&DISABLED)?1:0);
  if( change )
    objc_lock( tree, CB_SPEED, !enable );
  enable = ( dstdev_popup.selected > 0
             && ((tree[ CB_SIMUL ].ob_state&SELECTED)||(tree[ CB_WR ].ob_state&SELECTED))
             || dstdev_popup.selected == 0
             && strlen( copy_info.dest_file ) );
  change = enable == ((tree[ CB_COPY ].ob_state&DISABLED)?1:0);
  if( change )
    objc_lock( tree, CB_COPY, !enable );
  enable = dstdev_popup.selected;
  change = (!enable) == !(tree[CB_WSTXT].ob_flags&HIDETREE);
  if( change )
  {
    objc_enable( tree, CB_WSTXT, enable );
    objc_enable( tree, CB_SPEED, enable );
    objc_enable( tree, CB_ACTTXT, enable );
    objc_enable( tree, CB_SIMUL, enable );
    objc_enable( tree, CB_WR, enable );
  }

  /* Onglet Options de lecture */
  enable = srcdev_popup.selected && dstdev_popup.selected;
  change = enable == ((tree[CB_USEHD].ob_state&DISABLED)?1:0);
  if( change )
    objc_lock( tree, CB_USEHD, !enable );
  if( change || (!(tree[CB_USEHD].ob_state&SELECTED)
                 == !(tree[CB_INTTEXT].ob_flags&HIDETREE)) )
  {
    enable = enable && (tree[CB_USEHD].ob_state&SELECTED);
    objc_enable( tree, CB_INTTEXT, enable );
    objc_enable( tree, CB_INTFILE, enable );
    objc_enable( tree, CB_INTDEL, enable );
  }
  /*enable = tree[CB_IGNERR].ob_state&SELECTED;
  change = (!enable) == !(tree[CB_RELECTXT].ob_flags&HIDETREE);
  if( change )
  {
    objc_enable( tree, CB_RELECTXT, enable );
    objc_enable( tree, CB_RELECVAL, enable );
  }*/
}

void copy_clicked( WINDOW * win )
{
  OBJECT * form;
  int obj, ret;
  form = FORM(win);
  obj = evnt.buff[4];

  switch( obj )
  {
  case CB_COPY:
    copy_valid( form );
    ret = dao_launch( srcdev_popup.selected?TST_CD:TST_FILE,
                      dstdev_popup.selected?TST_CD:TST_FILE );
    switch( ret )
    {
      case -5:
        alert_msg( "AL_UNDERRUN", 1 );
        break;
      case -4:
        alert_msg( "AL_DAOWRTERR", 1 );
        break;
      case -3:
        alert_msg( "AL_COPYREADERR", 1 );
        break;
      case -2:
        alert_msg( "AL_COPYINT", 1 );
        break;
      case -1:
        alert_msg( "AL_DAOOPSERR", 1 );
        break;
      case 0:
        alert_msg( "AL_COPYOK", 1 );
        break;
    }
    break;
  case CB_OK:
    copy_valid( form );
  case CB_CANCEL:
    ApplWrite( app.id, WM_DESTROY, win->handle );
    break;
  case CB_SPEED:
  case CB_SPDCYC:
    if( speed_popup.item_count > 1 )
      popup_mgr( win, &speed_popup, obj );
    break;
  case CB_SRCCYC:
  case CB_SOURCE:
    if( popup_mgr( win, &srcdev_popup, obj ) == 0 )
    {
      fileselect( copy_info.source_file, "*.cd", "TXT_SELSRC" );
      form[ CB_SOURCE ].ob_spec.free_string = copy_info.source_fred;
      reduce_name( copy_info.source_fred, copy_info.source_file, MAX_FRED_COPY );
      ObjcDraw( OC_FORM, win, CB_SOURCE, MAX_DEPTH );
    }
    copy_gestion_acces( form );
    break;
  case CB_DSTCYC:
  case CB_DEST:
    if( popup_mgr( win, &dstdev_popup, obj ) == 0 )
    {
      fileselect( copy_info.dest_file, "*.cd", "TXT_SELDST" );
      form[ CB_DEST ].ob_spec.free_string = copy_info.dest_fred;
      reduce_name( copy_info.dest_fred, copy_info.dest_file, MAX_FRED_COPY );
      ObjcDraw( OC_FORM, win, CB_DEST, MAX_DEPTH );
    }
    if( dstdev_popup.selected )
    {
      gen_speed_popup( &speed_popup,
        ((struct device_info*)dstdev_popup.item[dstdev_popup.selected].info)->sets->max_write_speed );
      if( speed_popup.selected >= speed_popup.item_count )
        speed_popup.selected = speed_popup.item_count - 1;
    }
    form[ CB_SPEED ].ob_spec.free_string = speed_popup.item[speed_popup.selected].text;
    ObjcDraw( OC_FORM, win, CB_SPEED, MAX_DEPTH );
    copy_gestion_acces( form );
    break;
  case CB_INTFILE:
    copy_seltempfile();
    ObjcDraw( OC_FORM, win, CB_INTFILE, MAX_DEPTH );
    break;
  default:
    copy_gestion_acces( form );
    break;
  }
}

void copy_open( void )
{
  const static int thbut[] = {CB_ONG1, CB_ONG2};
  const static int thsub[] = {CB_FD1, CB_FD2};
  OBJECT * tree;
  WINDOW * win;
  gen_dev_popup( &srcdev_popup, 0, 1 );
  gen_dev_popup( &dstdev_popup, DSF_SUP_DAO_WR, 1 );
  rsrc_gaddr( 0, COPY_BOX, &tree );
  copy_default( tree );
  copy_gestion_acces( tree );
  win = open_dialog( tree, get_string( "TXT_COPY" ) );
  FormThumb( win, thsub, thbut, (int)(sizeof( thbut ) / sizeof( int )) );
  EvntAttach( win, UE_CLICKED, copy_clicked );
}
