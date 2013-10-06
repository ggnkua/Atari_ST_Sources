/*
 * philips.h - Commandes spécifiques aux graveurs compatibles Philips
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

struct track_info
{
  unsigned char BufLen;
  unsigned char TrackCount;
  long StartAdr;
  unsigned long TrackLength;
  unsigned char StatusMode;
  unsigned char IncrementalData;
  long FreeBlocks;
  long FixedPacketSize;
};

struct philips_track_descriptor
{
  unsigned short length;
  unsigned char control;
  unsigned char isrc1;
  unsigned char isrc2;
  unsigned char isrc3;
  unsigned char isrc4;
  unsigned char isrc5;
  unsigned char isrc6_7;
  unsigned char isrc8_9;
  unsigned char isrc10_11;
  unsigned char isrc12;
  long startadr;
  unsigned long indexadr[100];
};

int philips_read_track_info(
  unsigned long Track,
  struct track_info *Buffer,
  unsigned short Len );
int philips_write_track( int track_no, int copy, int raw, int aud,
                         int mode, int mix );
int philips_write_session(
  unsigned char lofp,
  unsigned char onp,
  unsigned char toctype,
  struct philips_track_descriptor tda[],
  unsigned short num );
int philips_read_session_info( unsigned short buf[2] );
int philips_fixation( int imm, int onp, int toc_type );
int philips_set_speed( int write, int wdummy, int read, int scrambled );
int philips_set_write_speed( int speed );
int philips_set_index_list( unsigned long * index );
int philips_first_writable_address( unsigned long * adr,
  int track,         /* Numéro de piste (0 si nouvelle piste) */
  int raw,           /* Mode raw */
  int audio,         /* Mode audio */
  int mode );        /* Mode data (1 ou 2) */

