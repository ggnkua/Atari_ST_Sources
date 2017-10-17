/*
 * cd_lab.h - Types et prototypes de l'application CD-LAB
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

#ifndef __COMMON_H__
#define __COMMON_H__

/* Données d'informations pour la commande READ SUB-CHANNEL */
struct SubQData
{
  unsigned char Res0;
  unsigned char AudioStatus;
  unsigned short DataLength;
  unsigned char FormatCode;
  unsigned char AdrControl;
  unsigned char TrackNo;
  unsigned char IndexNo;
  long AbsTrackAdr;
  long RelTrackAdr;
/*  unsigned char MCNB[16];
  unsigned char ISRC[16]; */
};

/*union msf
{
  struct {
  unsigned char Resrvd;
  unsigned char M;
  unsigned char S;
  unsigned char F;
  } s;
  unsigned long longval;
};*/

#define MAXTOC 100          /* Maximum laut SCSI-2 */
struct toc_entry
{
  char          Res0;
  unsigned char adr_control;
  unsigned char track_no;
  char          Res3;
  long          abs_address;
};

struct toc_head
{
  unsigned short toc_len;   /* sans le champ toc_len */
  unsigned char  first_track;
  unsigned char  last_track;
};

struct toc
{
  struct toc_head  head;
  struct toc_entry entry[MAXTOC];
};

#define MAX_EXT_TOC 100     /* Maximum au pif */
struct track_desc
{
  unsigned char session;
  unsigned char adr_control;
  unsigned char tno;
  unsigned char point;
  unsigned char min;
  unsigned char sec;
  unsigned char frame;
  unsigned char zero;
  unsigned char pmin;
  unsigned char psec;
  unsigned char pframe;
};

/* Infos ISRC d'une piste par READ SUB-CHANNEL */
struct isrc
{
  unsigned char res0;
  unsigned char audio_status;
  unsigned short data_length;
  unsigned char format_code;
  unsigned char adr_ctrl;
  unsigned char track_number;
  unsigned char res7;
  unsigned char tcval;
  unsigned char isrc[15];
};

/* TOC étendue */
struct ext_toc
{
  struct toc_head head;
  unsigned char   desc[MAXTOC][11];
};
/* Obtenir un descripteur de piste */
#define desc( toc, index ) (*((struct track_desc *)(toc).desc[index]))

/* COMMON.C */
int create_raw_blocks(
  unsigned char * buf, unsigned long adr, int mode, int count );

long get_sense_information( void );
int get_sense_key( void );
int get_asc( void );
int get_ascq( void );
int start_cd( void );
int get_ext_toc( struct ext_toc * toc );
int get_toc_entry( struct ext_toc * toc, int track, int session );
long get_track_offset( struct ext_toc * toc, int track, long * end_offset );
int get_mode( struct ext_toc * toc, int track_no );
int set_read_speed( int speed );
int set_write_speed( int speed );
int set_dummy_write( int dum );
int read_audio( unsigned long begin, unsigned short len, void * buffer );
int read_data( unsigned long begin, unsigned short len, void * buffer );
int set_blocksize_density( unsigned long blocksize, int density );
int set_blocksize( unsigned long blocksize );
int open_track( int copy, int raw, int aud, int mode );
int close_track( void );
int close_pma( int onp, int toc_type );
int set_index_list( unsigned long * index );
int write_to_cd( long begin, unsigned short len, void * buffer );
int writes_little_endian_audio( struct device_info * info );
int autodetect_audiomode( struct ext_toc * toc );
int autodetect_writemode( int verbose );
int autodetect_ms10( void );
/*
int write_empty_audio( unsigned short len );
int write_empty_data( unsigned short len, unsigned long adr, int mode );
*/

/* COM_ASM.S */
unsigned long swap_long( unsigned long a );
unsigned short swap_short( unsigned short a );
int set_ws( int speed, int write_mode );
void swap_endian( void * buf, unsigned long size );
void change_format( void * buf, unsigned long count, unsigned long offset,
                    unsigned long blocksize );
void scramble( void * buf, unsigned short size );

#endif
