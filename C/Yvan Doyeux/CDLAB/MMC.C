/*
 * MMC.C - Commandes spécifiques aux graveurs compatibles MMC
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
#include "mmc.h"

int mmc_read_cd(
  int sector_type, unsigned long blocksize, signed long adr, unsigned long count,
  int sync, int header, int user_data, int edc_ecc, int error,
  int sub_channel_selection, void * buffer )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 12, 0xBE, adr, count<<8, buffer, count * blocksize );
  Cmd->Cmd[1] |= (sector_type&7) << 2;
  Cmd->Cmd[9] = (sync?0x80:0) | ((header&3)<<5) | (user_data?0x10:0)
                | (edc_ecc?8:0) | ((error&3)<<1);
  Cmd->Cmd[10] = sub_channel_selection&7;
  return scsi_in( Cmd );
}

int mmc_set_speed( unsigned short read, unsigned short write )
{
  unsigned long adr;
  read = (read*353)/2;
  write = (write*353)/2;
  if( !read ) read = 0xffff;
  if( !write ) write = 0xffff;
  adr = (((long)read)<<16) | (long)write;
  return scsi_out( set_cmd( 12, 0xBB, adr, 0, NULL, 0 ) );
}

int mmc_set_write_parameters( int write_type, int multi_session,
  int track_mode, int block_type, int session_format,
  unsigned long packet_size, unsigned short audio_pause, void * mcn,
  void * isrc, unsigned long sub_header )
{
  unsigned char MSParm[ 52 ] = {0};
  MSParm[ 0 ] = 0x05;       /* Write Parameter Page */
  MSParm[ 1 ] = 0x32;
  MSParm[ 2 ] = ((current_device->dummy_write
                  &&(write_type==1||write_type==2))?0x10:0)
                |(write_type&0x0F);
  MSParm[ 3 ] = ((multi_session&3)<<6)|(track_mode&0x0F);
  MSParm[ 4 ] = block_type&0x0F;
  MSParm[ 8 ] = session_format;
  *((unsigned long *)(MSParm+10)) = packet_size;
  *((unsigned short *)(MSParm+14)) = audio_pause;
  if( mcn ) memcpy( MSParm + 16, mcn, 16 );
  if( isrc ) memcpy( MSParm + 32, isrc, 16 );
  *((unsigned long *)(MSParm+48)) = sub_header;

  return mode_select( 0, 0, 0/*current_device->BlockSize*/, MSParm, 52 );
}

int mmc_read_cd_capabilities( void * buffer, int alloc )
{
  int ret;
  ret = mode_sense( 1, 0, 0x2a, buffer, alloc );
  return ret;
}

int mmc_read_track_information( void * buffer, int track_flag,
    long lba_track, int alloc )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0x52, lba_track, alloc, buffer, alloc );
  if( track_flag ) Cmd->Cmd[1] = 0x01;
  return scsi_in( Cmd );
}

int mmc_read_disc_information( void *buffer, int alloc )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0x51, 0, alloc, buffer, alloc );
  Cmd->Timeout = 60*200;
  return scsi_in( Cmd );
}

int mmc_repair_track( int track_no )
{
  return scsi_in( set_cmd( 10, 0x58, track_no&0xFF, 0, NULL, 0 ) );
}

/* Fermeture d'une piste (type==1) / session (type==2) */
int mmc_close_track_session( int immed, int type, int track_no )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0x5b, 0, 0, NULL, 0 );
  Cmd->Cmd[1] = immed?1:0;
  Cmd->Cmd[2] = type&0x03;
  Cmd->Cmd[5] = track_no&0x00FF;
  Cmd->Timeout = 4 * 60 * 200;
  return scsi_in( Cmd );
}

int mmc_send_cue_sheet( unsigned long length, void * buffer )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0x5d, 0, 0, buffer, length );
  Cmd->Cmd[6] = (length>>16) & 0xff;
  Cmd->Cmd[7] = (length>>8) & 0xff;
  Cmd->Cmd[8] = length & 0xff;
  return scsi_out( Cmd );
}

int mmc_blank( int type, long adr_tn )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 12, 0xA1, adr_tn, 0, NULL, 0 );
  Cmd->Cmd[1] = type & 0x07;
  Cmd->Timeout = 80 * 60 * 200;
  return scsi_out( Cmd );
}


