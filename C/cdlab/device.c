/*
 * DEVICE.C - Gestion de l'objet Device
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

#include "ext_scsi.h"
#include "common.h"
#include "io.h"
#include "log.h"
#include "device.h"
#include "misc.h"

#define DEVICE_FILE "DEVICE.INI"

int dev_sets;
struct device_settings dev_set[ MAX_DEV_SETS ];

struct device * current_device;

/* Copie de chaîne de caractères avec suppression des espaces à la fin */
static void strzcpy( void * dest, const void * src, size_t maxlen )
{
  char * z;
  z = ((char*)dest) + maxlen;
  memcpy( dest, src, maxlen );
  *z = '\0';
  while( z>=dest && *--z == ' ' ) *z = '\0';
}

/* Ouverture du device SCSI */
struct device * open_device( int id, unsigned short bus_no )
{
  char          inq_buf[44];
  struct device *retour;
  struct dev_info Dev;
  struct device_id *dev_id;
  unsigned long MaxLen;
  short         *handle;
  int           i;

  /* Recherche du premier bus SCSI disponible */
  Dev.scsi_id.hi = 0;
  Dev.scsi_id.lo = id;
  handle = io_open_device( bus_no, &Dev.scsi_id, &MaxLen );
  if( handle > 0 )
  {
    retour = xmalloc( sizeof( struct device ) );
    if( retour )
    {
      memset( retour, 0, sizeof( struct device ) );
      retour->Handle = handle;
      retour->Lun = 0;
      retour->DmaLen = MaxLen;
      use_device( retour );
      inquiry( 44, inq_buf );

      dev_id = (struct device_id *) scsi_buf;
      strzcpy( dev_id->vend_id, inq_buf + 8, 8 );
      strzcpy( dev_id->prod_id, inq_buf + 16, 16 );
      strzcpy( dev_id->revision_level, inq_buf + 32, 4 );
      strzcpy( dev_id->revision_date, inq_buf + 36, 8 );

      retour->type = inq_buf[0] & 0x1F;
      if( retour->type == 5         /* CD-ROM ? */
          || retour->type == 4 )    /* WORM ? */
      {
        i=0;
        while( i<dev_sets
               && memcmp( &dev_set[ i ].dev_id, dev_id, sizeof( struct device_id )-9 ) )
          i++;
        if( i<dev_sets )
          retour->sets = dev_set + i;
        else
        {
          if( i<MAX_DEV_SETS )
          {
            dev_sets++;
            retour->sets = dev_set + i;
            memset( retour->sets, 0, sizeof( struct device_settings ) );
            retour->sets->dev_id = *dev_id;
            retour->sets->write_mode = WT_AUTODETECT;
            retour->sets->audio_mode = AM_AUTODETECT;
          }
          else
          {
            free( retour );
            retour = NULL;
          }
        }
        /*if( mode_sense( 0, 0, 0x01, retour->context, 8 ) )
        {
          free( retour );
          retour = NULL;
        }*/
      }

      /* set_blocksize( 2048 ); /* Est-ce bien nécessaire ? */
    } else
      io_close_device( handle );
  }
  else retour = NULL;
  return retour;
}

/* Fermeture d'un device */
int close_device( struct device * dev )
{
  /* unsigned short type; */
  if( !dev ) return -1;
  use_device( dev );
  /*type = current_device->type;
  if( ( type == 4 || type == 5 )
      && set_blocksize_density( *((unsigned long *)(dev->context+4)), dev->context[ 0 ] ) )
    return -1;*/
  if( io_close_device( dev->Handle ) )
    return -1;
  if( current_device == dev )
    current_device = NULL;
  free( dev );
  return 0;
}

/* Uniquement dans la gestion de plusieurs devices (implicite sinon) */
void use_device( struct device * dev )
{
  if( current_device != dev )
    current_device = dev;
}

struct device_info * get_device_list( int verbose )
{
  const static char * dev_type[] =
  {
    "Direct-access", "Sequential-access", "Printer", "Processor", "Write-once",
    "CD-ROM", "Scanner", "Optical memory", "Medium Changer", "Communications"
  };
  struct dev_info devinfo;
  struct bus_info businfo;
  struct device * dev;
  struct device_info * first, * info;
  struct device_id *dev_id = (struct device_id *)scsi_buf;
  char * vendor, * prod;
  int ok;

  if( !scsi_init( ) ) return (struct device_info*) -1;
  first = xmalloc( sizeof( struct device_info ) );
  if( !first ) return NULL;
  info = first;

  if( verbose )
  {
    log_begin();
    log_printf( "*** Begin of a bus rescan\n" );
    log_end();
  }

  ok = !io_get_first_bus( &businfo );
  while( ok )
  {
    if( verbose )
    {
      log_begin();
      log_printf( "Found bus - id: %u, name: %s\n", businfo.bus_no, businfo.bus_name );
      log_end();
    }
    ok = !io_get_first_device( businfo.bus_no, &devinfo );
    while( ok )
    {
      info->id = (int)devinfo.scsi_id.lo;
      info->bus_no = businfo.bus_no;
      if( verbose )
      {
        log_begin();
        log_printf( "Found device - %s id: %lu:%lu ", businfo.bus_name,
                    devinfo.scsi_id.hi, devinfo.scsi_id.lo );
        log_end();
      }
      dev = open_device( info->id, info->bus_no );
      if( dev )
      {
        vendor = (dev->sets) ? dev->sets->dev_id.vend_id : dev_id->vend_id;
        prod = (dev->sets) ? dev->sets->dev_id.prod_id : dev_id->prod_id;
        sprintf( info->desc, "%s id:%d - %s %s", businfo.bus_name, info->id, vendor, prod );
        if( verbose )
        {
          log_begin();
          if( dev->type < 10 )
            log_printf( "%s %s, type: %s\n", vendor, prod, dev_type[dev->type] );
          else
            log_printf( "%s %s, type: Unknown (0x%02hx)\n", vendor, prod, dev->type ); 
          log_end();
        }
        if( dev->type == 5         /* CD-ROM ? */
            || dev->type == 4 )    /* WORM ? */
        {
          use_device( dev );
          if( dev->sets->write_mode == WT_AUTODETECT )
          {
            autodetect_ms10();
            autodetect_writemode( 0 );
          }
          info->sets = dev->sets;
          info->next = xmalloc( sizeof( struct device_info ) );
          info = info->next;
        }
        close_device( dev );
      }
      if( (!dev) || (!info) )
      {
        free_device_list( first );
        return NULL;
      }
      ok = !io_get_next_device( businfo.bus_no, &devinfo );
    }
    ok = !io_get_next_bus( &businfo );
  }
  info->id = -1;
  if( first->id < 0 )
  {
    free( first );
    first = NULL;
  }
  else
  {
    info = first;
    while( info->next->id >= 0 ) info = info->next;
    free( info->next );
    info->next = NULL;
  }

  if( verbose )
  {
    log_begin();
    log_printf( "*** End of the bus rescan\n" );
    log_end();
  }
  return first;
}

void free_device_list( struct device_info * first )
{
  if( first )
  {
    free_device_list( first->next );
    free( first );
  }
}

