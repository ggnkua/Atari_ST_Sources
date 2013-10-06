/*
 * philips.c - Commandes spécifiques aux graveurs compatibles Philips
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

#include "io.h"
#include "ext_scsi.h"
#include "device.h"
#include "philips.h"

int philips_read_track_info(
  unsigned long Track,
  struct track_info *Buffer,
  unsigned short Len )
{
  return scsi_in( set_cmd( 10, 0xE5, Track, Len, Buffer, Len ) );
}

int philips_write_session(
  unsigned char lofp,
  unsigned char onp,
  unsigned char toctype,
  struct philips_track_descriptor tda[],
  unsigned short num )
{
  int index;
  unsigned short size;
  scsi_cmd * Cmd;
  struct philips_track_descriptor * pnt;
  size = 0;
  pnt = (struct philips_track_descriptor *)scsi_buf;
  index = 0;
  while( num-->0 )
  {
    size += tda[index].length;
    memcpy( pnt, &tda[index], tda[index].length );
    (char*)pnt += tda[index].length;
    index++;
  }

  Cmd = set_cmd( 10, 0xED, 0, size, scsi_buf, size );
  Cmd->Cmd[6] = ( (lofp&3) << 4 ) + ( (onp&1) << 3 ) + (toctype&7);
  return scsi_out( Cmd );
}

int philips_write_track( int track_no, int copy, int raw, int aud,
                         int mode, int mix )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0xE6, track_no&0xFF, 0, NULL, 0 );
  Cmd->Cmd[6] = ((copy&0x03)<<4) | (raw?8:0) | (aud?4:0) | (mode&0x03);
  if( mix ) Cmd->Cmd[9] |= 0x40;
  return scsi_out( Cmd );
}

/* Lecture de la taille d'un lead-in et d'un lead-out d'une session */
int philips_read_session_info( unsigned short buf[2] )
{
  return scsi_in( set_cmd( 10, 0xEE, 0, 4, buf, 4 ) );
}

/* Recherche de la première adresse écrivable */
int philips_first_writable_address( unsigned long * adr,
  int track,         /* Numéro de piste (0 si nouvelle piste) */
  int raw,           /* Mode raw */
  int audio,         /* Mode audio */
  int mode )         /* Mode data (1 ou 2) */
{
  unsigned char buf[6];
  int ret;
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0xE2, 0, 6, buf, 6 );
  Cmd->Cmd[2] = track&0x7F;
  Cmd->Cmd[3] = (raw?8:0)|(audio?4:0)|(mode&3);
  ret = scsi_in( Cmd );
  if( !ret )
    *adr = ((long)buf[1]<<24) | ((long)buf[2]<<16)
         | ((long)buf[3]<<8) | ((long)buf[4]);
  return ret;
}

/* Ecriture de la TOC après gravage en TAO */
int philips_fixation( int imm, int onp, int toc_type )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0xE9, 0, (onp?8:0)|(toc_type&0x07), NULL, 0 );
  if( imm )
    Cmd->Cmd[1] |= 1;
  else
    Cmd->Timeout = 240*200;      /* Timeout de 4 minutes */
  return scsi_out( Cmd );
}

/*********** Fonctions étendues ****************/

/* Réglage de la vitesse du graveur, du mode d'emulation et de la taille de bloc */
int philips_set_speed( int write, int wdummy, int read, int scrambled )
{
  static char MSParm[ 8 ] = {
            0x23,	/* Page de sélection de la vitesse */
            0x06,	/* Taille de la page de paramètres */
               0,	/* Vitesse d'écriture */
               0,	/* Emulation d'écriture */
               0,	/* Vitesse de lecture */
            0, 0,	/* Réservé */
               0 };	/* Read Scrambled */
  MSParm[ 2 ] = write;
  MSParm[ 3 ] = wdummy;
  MSParm[ 4 ] = read;
  MSParm[ 7 ] = scrambled ? 0x80 : 0;
  return mode_select( 0, 0, current_device->BlockSize, MSParm, 8 );
}

int philips_set_write_speed( int speed )
{
  int ret;
  ret = philips_set_speed( speed, current_device->dummy_write, 0, 0 );
  if( ret ) return -1;
  current_device->write_speed = speed;
  return 0;
}

/*** Sélection de la liste d'index en gravage TAO ***/
int philips_set_index_list( unsigned long * index )
{
  unsigned char MSParm[ 255 ] = {0};
  unsigned int num;

  num = 1;
  while( index[num] ) num++;
  if( num > 49 ) num = 49;

  MSParm[ 0 ] = 0x24;       /* Subcode Increment Index Page */
  MSParm[ 1 ] = 197/*num*4 + 1*/;
  MSParm[ 2 ] = num;
  memcpy( MSParm + 3, index, num * sizeof( index[0] ) );
  return mode_select( 0, 0, current_device->BlockSize, MSParm, 199/*num*4 + 3*/ );
}

