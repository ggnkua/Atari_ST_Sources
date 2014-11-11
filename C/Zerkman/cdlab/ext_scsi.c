/*
 * EXT_SCSI.C  -  Fonctions SCSI standard
 * Librairie de fonctions SCSI en C, s'appuyant sur SCSIDRV.
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
#include "device.h"
#include "ext_scsi.h"
#include "common.h"

#define MIN(A,B) (((A)<(B))?(A):(B))

/* Buffer utilisable pour la conception de blocs de commande */
unsigned char scsi_buf[ SCSI_BUF_SIZE ];

int rezero_unit( void )
{
  return scsi_out( set_cmd( 6, 0x01, 0, 0, NULL, 0 ) );
}

int inquiry( unsigned short len, void * buffer )
{
  return scsi_in( set_cmd( 6, 0x12, 0, len, buffer, len ) );
}

int test_unit_ready( void )
{
  return scsi_in( set_cmd( 6, 0x00, 0, 0, NULL, 0 ) );
}

int mode_select( unsigned char density, long blocks, long blocklen,
                 void * parm, short parmsize )
{
  scsi_cmd * Cmd;
  short out_size;
  void * param;
  int use_ms10, use_blockdesc;
  static union
  {
    struct
    {
      struct parm_head6 header;
      struct block_desc desc;
      char param[1024];
    } p6;
    struct
    {
      struct parm_head10 header;
      struct block_desc desc;
      char param[1024];
    } p10;
  } MSParm;

  memset( &MSParm, 0, sizeof( MSParm ) );
  use_ms10 = ( (current_device->sets->flags & DSF_USE_MS10) || parmsize >= (256-12) );
  use_blockdesc = ( density || blocks || blocklen );
  if( use_ms10 )
  {
    MSParm.p10.header.BlockDescLen = use_blockdesc?8:0;
    if( use_blockdesc )
    {
      MSParm.p10.desc.Blocks = blocks;
      *(unsigned char *)(&MSParm.p10.desc.Blocks) = density;
      MSParm.p10.desc.BlockLen = blocklen;
      param = MSParm.p10.param;
    }
    else
      param = (void*)&MSParm.p10.desc;
  }
  else
  {
    MSParm.p6.header.BlockDescLen = use_blockdesc?8:0;
    if( use_blockdesc )
    {
      MSParm.p6.desc.Blocks = blocks;
      *(unsigned char *)(&MSParm.p6.desc.Blocks) = density;
      MSParm.p6.desc.BlockLen = blocklen;
      param = MSParm.p6.param;
    }
    else
      param = (void*)&MSParm.p6.desc;
  }
  memcpy( param, parm, parmsize );
  out_size = ( (long)param - (long)&MSParm ) + parmsize;

  if( use_ms10 )
    Cmd = set_cmd( 10, 0x55, 0, out_size, &MSParm, out_size );
  else
    Cmd = set_cmd( 6, 0x15, 0, out_size, &MSParm, out_size );
  Cmd->Cmd[1] = 0x10;
  return scsi_out( Cmd );
}

/* Retourne des pages de code, sans header [ni block descriptor (en option)] */
int mode_sense( int dbd, int page_control, int page_code,
                void * buffer, int alloc )
{
  /* dbd : Disable Block Descriptor : Attention sur le Matsu il le
           met kan meme, donc il faut ruser */
  /* page_control = 0:courant, 1:masque, 2:défaut */
  scsi_cmd * Cmd;
  int ret, use_ms10;
  int offset, length;

  use_ms10 = ( (current_device->sets->flags & DSF_USE_MS10) || alloc >= (256-12) );
  offset = (dbd ? 12 : 4);
  length = alloc + offset;

  if( use_ms10 )
  {
    length += 4;
    offset += 4;
    Cmd = set_cmd( 10, 0x5A, 0, length, scsi_buf, length );
  }
  else
  {
    Cmd = set_cmd( 6, 0x1A, 0, length, scsi_buf, length );
  }
  Cmd->Cmd[2] = ((page_control&0x03)<<6) | (page_code&0x3F);
  ret = scsi_in( Cmd );

  memcpy( buffer, scsi_buf + offset, alloc );
  return ret;
}

int seek( long BlockAdr )
{
  return scsi_out( set_cmd( 10, 0x2B, BlockAdr, 0, NULL, 0 ) );
}

/* Fonction de lecture, en cas de pb mettre le Timeout à 20*200 */
int read6( unsigned long begin, unsigned short len, void * buffer )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 6, 0x08, begin, len, buffer, len * current_device->BlockSize );
  Cmd->Timeout = 3200;
  return scsi_in( Cmd );
}

/* Fonction de lecture, en cas de pb mettre le Timeout à 20*200 */
int read10( unsigned long begin, unsigned short len, void * buffer )
{
  return scsi_in( set_cmd( 10, 0x28, begin, len, buffer, len * current_device->BlockSize ) );
}

int write10( unsigned long begin, unsigned short len, void * buffer )
{
  scsi_cmd * Cmd;
  int ret;
  unsigned long segment_len;
  unsigned long segment_size;
  
  segment_len = current_device->DmaLen / current_device->BlockSize;
  segment_size = segment_len * current_device->BlockSize;

  while ( len > segment_len )
  {
    Cmd = set_cmd( 10, 0x2A, begin, segment_len, buffer, segment_size );
    Cmd->Timeout = 180 * 200;
    ret = scsi_out( Cmd );
    if ( ret != 0 ) return ret;
    begin += segment_len;
    len -= segment_len;
    buffer = (void *)((long)buffer + segment_size );
  }

  Cmd = set_cmd( 10, 0x2A, begin, len, buffer,
                 current_device->BlockSize * len );
  Cmd->Timeout = 180 * 200;
  return scsi_out( Cmd );
}

int prevent_allow_medium_removal( int prevent )
{
  return scsi_out( set_cmd( 6, 0x1E, 0, prevent?1:0, NULL, 0 ) );
}

int verify( unsigned long BlockAdr, unsigned short VerifyLen, int Blank )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0x2F, BlockAdr, VerifyLen, NULL, 0 );
  Cmd->Cmd[1] |= Blank?4:0;
  return scsi_in( Cmd );
}

int synchronize_cache( void )
{
  scsi_cmd * Out;
  Out = set_cmd( 10, 0x35, 0, 0, NULL, 0 );
  Out->Timeout = 180 * 200;
  return scsi_out( Out );
}

int read_sub_channel( int MSF, int SUBQ,
                    unsigned int SubFormat, unsigned int Track,
                    void *Data, unsigned int Len)
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0x42, 0, 0, Data, Len );

  Cmd->Cmd[1] = ( MSF ? 2 : 0 );
  Cmd->Cmd[2] = ( SUBQ ? 0x40 : 0 );
  Cmd->Cmd[3] = SubFormat;
  Cmd->Cmd[6] = Track;
  Cmd->Cmd[7] = Len >> 8;
  Cmd->Cmd[8] = Len & 0xff;

  return scsi_in( Cmd );
}

int read_toc( int MSF, int StartTrack, void *Buffer, int Len )
{
  return read_toc_format( MSF, StartTrack, Buffer, Len, 0 );
}

int read_toc_format( int MSF, int StartTrack, void *Buffer, int Len, int format )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0x43, 0, Len, Buffer, Len );
  if (MSF) Cmd->Cmd[1] |= 2;
  Cmd->Cmd[6] = StartTrack;
  Cmd->Cmd[9] |= (format&3)<<6;
  return scsi_in( Cmd );
}

int play_audio( int relative_address, long address, unsigned short length )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 10, 0x45, address, length, NULL, 0 );
  if( relative_address ) Cmd->Cmd[1] |= 1;
  return scsi_in( Cmd );
}

int start_stop_unit( int imm, int loej, int str )
{
  scsi_cmd * Cmd;
  Cmd = set_cmd( 6, 0x1B, 0, 0, NULL, 0 );
  if( imm ) Cmd->Cmd[1] |= 1;
  Cmd->Cmd[4] |= (loej?2:0) | (str?1:0);
  Cmd->Timeout = 20*200;
  return scsi_in( Cmd );
}

/* Définit le mode de récupération d'erreur
 * Bits de mode :
 * 5 : TB : Transfer Block
 * 4 : RC : Read Continuous
 * 2 : PER : Post Error
 * 1 : DTE : Disable Transfer on Error
 * 0 : DCR : Disable Correction */
int set_error_recovery( int mode, int retry_count )
{
  char MSParm[8] = {0};
  MSParm[ 0 ] = 0x01;          /* Error Recovery Page */
  MSParm[ 1 ] = 0x06;          /* Taille de la page */
  MSParm[ 2 ] = mode;          /* Mode de récupération d'erreur */
  MSParm[ 3 ] = retry_count;   /* Nombre de relectures avant échec */
  return mode_select( 0, 0, 0 /*current_device->BlockSize*/, MSParm, 8 );
}

/* Définit la durée d'inactivité avant de passer en stand by */
int set_cdrom_parameters( int inactivity )
{
  static char cdparm[] = { 0x0d, 0x06, 0, 0x00, 0, 60, 0, 75 };
  cdparm[3] = inactivity & 0x0f;
  return mode_select( 0, 0, current_device->BlockSize, cdparm, 8 );
}

