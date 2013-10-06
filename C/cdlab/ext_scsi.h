/*
 * EXT_SCSI.H
 * Librairie de fonctions SCSI en C, s'appuyant sur la SCSI LIB.
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

#ifndef __EXT_SCSI__
#define __EXT_SCSI__

#define SCSI_BUF_SIZE 65536L
extern unsigned char scsi_buf[ SCSI_BUF_SIZE ];

int rezero_unit( void );
int inquiry( unsigned short len, void * buffer );
int test_unit_ready( void );
int mode_select( unsigned char density, long blocks, long blocklen,
                 void * parm, short parmsize  );
int mode_sense( int dbd, int page_control, int page_code,
                void * buffer, int alloc );
int seek( long BlockAdr );
int read6( unsigned long begin, unsigned short len, void * buffer );
int read10( unsigned long begin, unsigned short len, void * buffer );
int write10( unsigned long begin, unsigned short len, void * buffer );
int prevent_allow_medium_removal( int prevent );
int verify( unsigned long BlockAdr, unsigned short VerifyLen, int Blank );
int synchronize_cache( void );
int read_sub_channel( int MSF, int SUBQ,
                    unsigned int SubFormat, unsigned int Track,
                    void *Data, unsigned int Len);
int read_toc( int MSF, int StartTrack, void *Buffer, int Len );
int read_toc_format( int MSF, int StartTrack, void *Buffer, int Len, int format );
int play_audio( int relative_address, long address, unsigned short length );
int start_stop_unit( int imm, int loej, int str );
int set_error_recovery( int mode, int retry_count );
int set_cdrom_parameters( int inactivity );

#endif

