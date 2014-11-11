/*
 * MMC.H - Commandes spécifiques aux graveurs compatibles MMC
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

#ifndef __MMC_H__
#define __MMC_H__

int mmc_read_cd(
  int sector_type, unsigned long blocksize, signed long adr, unsigned long count,
  int sync, int header, int user_data, int edc_ecc, int error,
  int sub_channel_selection, void * buffer );
int mmc_set_speed( unsigned short read, unsigned short write );
int mmc_set_test_write( int test );
int mmc_set_write_parameters( int write_type, int multi_session,
  int track_mode, int block_type, int session_format,
  unsigned long packet_size, unsigned short audio_pause, void * mcn,
  void * isrc, unsigned long sub_header );
int mmc_read_cd_capabilities( void * buffer, int alloc );
int mmc_read_track_information( void * buffer, int track_flag,
    long lba_track, int alloc );
int mmc_read_disc_information( void *buffer, int alloc );
int mmc_repair_track( int track_no );
int mmc_close_track_session( int immed, int type, int track_no );
int mmc_send_cue_sheet( unsigned long length, void * buffer );
int mmc_blank( int type, long adr_tn );

#endif
