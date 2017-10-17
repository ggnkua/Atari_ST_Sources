/*
 * TEAC.C - Commandes spécifiques aux graveurs compatibles TEAC
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

#include "misc.h"
#include "io.h"
#include "ext_scsi.h"
#include "device.h"
#include "teac.h"

int teac_read_cd_da( unsigned long adr, unsigned long length,
                        unsigned char subcode, void * buffer )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 12, 0xD8, adr, length, buffer, length * current_device->BlockSize );
  Cmd->Cmd[10] = subcode;
  return scsi_in( Cmd );
}

int teac_write( unsigned long begin, unsigned short len, void * buffer,
                int extwr )
{
  int ret;
  scsi_cmd * Cmd;
  unsigned long segment_len;
  unsigned long segment_size;

  segment_len = current_device->DmaLen / current_device->BlockSize;
  segment_size = segment_len * current_device->BlockSize;

  while ( len > segment_len )
  {
    Cmd = set_cmd( 10, 0x2A, begin, segment_len, buffer, segment_size );
    Cmd->Cmd[9] |= 0x80;     /* On force le ExtWr puisque c'est pas le dernier write */
    Cmd->Timeout = 120 * 200;
    ret = scsi_out( Cmd );
    if ( ret != 0 ) return ret;
    begin += segment_len;
    len -= segment_len;
    buffer = (char *)buffer + segment_size;
  }

  Cmd = set_cmd( 10, 0x2A, begin, len, buffer,
                 current_device->BlockSize * len );
  if( extwr ) Cmd->Cmd[9] |= 0x80;
  Cmd->Timeout = 120 * 200;
  return scsi_out( Cmd );
}

int teac_set_limits( long adr, unsigned long count )
{
  return scsi_out( set_cmd( 12, 0xB3, adr, count, NULL, 0 ) );
}

int teac_set_subcode( int isrc_tno, unsigned short length, void * buffer )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0xC2, 0, length, buffer, length );
  if( isrc_tno ) Cmd->Cmd[6] = isrc_tno;
  return scsi_out( Cmd );
}

int teac_set_subcode_pma( int p, int control, int tno, int index )
{
  /* P : 1 si pause ou lead_in, 0 sinon */
  char buffer[4];
  buffer[0] = p;                       /* Subcode P */
  buffer[1] = ((control&0xF)<<4) | 1;  /* Subcode Q : control + adr */
  buffer[2] = hex2bcd( tno );          /* Numéro de piste */
  buffer[3] = hex2bcd( index );        /* Numéro d'index */
  return teac_set_subcode( 0, 4, buffer );
}

int teac_write_pma( void )
{
  return scsi_out( set_cmd( 12, 0xE1, 0, 0, NULL, 0 ) );
}

int teac_freeze( int bp )
{
  return scsi_out( set_cmd( 12, 0xE3, bp?0x80:0, 0, NULL, 0 ) );
}

int teac_clear_subcode( void )
{
  return scsi_out( set_cmd( 12, 0xE4, 0x80, 0, NULL, 0 ) );
}

/* Récupère la première adresse écrivable */
/* slba : Start Logical Block Address
   elba : Last Logical Block Address
   Si slba = elba = -1, on scanne tout le disque */
int teac_next_writable_address( long * adr, long slba, long elba )
{
  return scsi_in( set_cmd( 12, 0xE6, slba, elba, adr, 4 ) );
}

/* Test de calibration du laser */
/* jd = judge disc : 0:normal, 1:on juge le type de disque */
int teac_opc_execution( int jd )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 12, 0xEC, 0, 0, NULL, 0 );
  if( jd ) Cmd->Cmd[1] |= 1;
  return scsi_out( Cmd );
}

int teac_set_preview_write( int preview )
{
  static char MSParm[ 3 ] = {
            0x21,       /* Preview Write Page */
            0x01,       /* Taille de la page de paramètres */
               0 };     /* Octet d'informations */
  MSParm[ 2 ] = preview?1:0;
  return mode_select( 0, 0, current_device->BlockSize, MSParm, 3 );
}

/* Méthodes de gravage =
 * 0:TAO 1:Fixed Packet 2:DAO 4:SAO 0x84:SAO + Disc Close
 */
int teac_set_write_method( int method )
{
  static char MSParm[ 9 ] = {
            0x22,       /* Write Method Page */
            0x07,       /* Taille de la page de paramètres */
      0x00, 0x00,       /* Réservé */
            0x00,       /* Méthode de gravage */
      0x00, 0x00,       /* Réservé */
      0x00, 0x00 };     /* Packet Size */
  MSParm[ 4 ] = method;
  return mode_select( 0, 0, current_device->BlockSize, MSParm, 9 );
}

/* Vitesse de lecture ou d'écriture */
int teac_set_speed( unsigned int speed )
{
  static char MSParm[ 4 ] = {
            0x31,       /* Drive Speed Page */
            0x02,       /* Taille de la page de paramètres */
            0x00,       /* Vitesse */
            0x00 };     /* Réservé */
  MSParm[ 2 ] =
  ( speed == 0 )  ? 0xFF : (
  ( speed == 1 )  ? 0 : (
  ( speed < 4 )   ? 1 : (
  ( speed < 8 )   ? 2 : (
  ( speed < 12 )  ? 4 : (
  ( speed == 12 ) ? 6 : 0xFF )))));
  return mode_select( 0, 0, current_device->BlockSize, MSParm, 4 );
}

/* Récupération de la vitesse maxi */
/*int teac_get_max_speed( unsigned int * speed )
{
  unsigned int ret;
  if( mode_sense( 1, 2, 0x31, scsi_buf, 8 ) ) return -1;
  ret = scsi_buf[ 4+2 ];
  if( !ret ) *speed = 1;
  else *speed = ret * 2;
  return 0;
}*/

