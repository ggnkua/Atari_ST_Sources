/*
 * ERASEWIN.C - Fenêtre de copie de CD
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

#include "rsc/cdlab.h"
#include "log.h"
#include "prefs.h"
#include "device.h"
#include "mmc.h"
#include "ext_scsi.h"
#include "misc.h"
#include "common.h"
#include "main.h"
#include "erasewin.h"

struct popup_item erase_popup_items[ MAX_DEVICES ];
struct popup_str erase_popup = { EB_ERASE, erase_popup_items, 0, 0 };

int cdrw_erase( int id, unsigned short bus_no )
{
  short buf[11];
  int ret;
  struct device * dev;
  dev = open_device( id, bus_no );
  if( !dev )
  {
    alert_msg( "AL_DAODSTERR", 1 );
    return -1;
  }

  log_begin();
  log_printf( "*** Begin of a CD blanking operation\n\n" );

  busybee();
  /* autodetect_writemode( 0 ); */
  if( start_cd() ) goto erreur;
  mmc_read_cd_capabilities( buf, 22 );
  set_write_speed( buf[9] / 176 );
  mmc_blank( preferences.erase_method, 0 );
  ret = 0;
  if( preferences.pref_flags.eject_dst )
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
  close_device( dev );
  arrow();

  log_printf( "*** End of the CD blanking operation\n\n" );
  log_end();

  return ret;
}

void erase_gestion_acces( OBJECT * form )
{
}


void erase_default( OBJECT * form )
{
  struct device_info * info;
  int i, obj;
  for( i=0; i<erase_popup.item_count; i++ )
  {
    info = (struct device_info *)erase_popup.item[i].info;
    if( info->id == preferences.erase_id
        && info->bus_no == preferences.erase_bus )
      erase_popup.selected = i;
  }
  form[ EB_ERASE ].ob_spec.free_string = erase_popup.item[erase_popup.selected].text;

  form[EB_COMP].ob_state &= ~SELECTED;
  form[EB_MINI].ob_state &= ~SELECTED;

  switch( preferences.erase_method )
  {
    case 0: /* Effacement complet du disque */
      obj = EB_COMP;
      break;
    case 1: /* Effacement minimal du disque */
      obj = EB_MINI;
      break;
  }
  form[obj].ob_state |= SELECTED;
}

void erase_valid( OBJECT * form )
{
  struct device_info * info;
  info = erase_popup.item[erase_popup.selected].info;
  preferences.erase_id = info->id;
  preferences.erase_bus = info->bus_no;
  if( form[EB_COMP].ob_state & SELECTED ) preferences.erase_method = 0;
  if( form[EB_MINI].ob_state & SELECTED ) preferences.erase_method = 1;
}

void erase_clicked( WINDOW * win )
{
  struct device_info * info;
  OBJECT * form;
  int obj;
  form = FORM(win);
  obj = evnt.buff[4];

  switch( obj )
  {
  case EB_OK:
    info = erase_popup.item[erase_popup.selected].info;
    erase_valid( form );
    if( cdrw_erase( info->id, info->bus_no ) )
      alert_msg( "AL_ERASEERR", 1 );
    else
      alert_msg( "AL_ERASEOK", 1 );
    break;
  case EB_CANCEL:
    ApplWrite( app.id, WM_DESTROY, win->handle );
    break;
  case EB_ERASE:
    popup_mgr( win, &erase_popup, obj );
    erase_gestion_acces( form );
    break;
  default:
    erase_gestion_acces( form );
    break;
  }
}

void erase_open( void )
{
  OBJECT * tree;
  WINDOW * win;
  gen_dev_popup( &erase_popup, DSF_WRITE_CDRW, 0 );
  if( erase_popup.item_count == 0 )
    alert_msg( "AL_NOCDRW", 1 );
  else
  {
    rsrc_gaddr( 0, ERASE_BOX, &tree );
    erase_default( tree );
    erase_gestion_acces( tree );
    win = open_dialog( tree, get_string( "TXT_ERASE" ) );
    EvntAttach( win, UE_CLICKED, erase_clicked );
  }
}


