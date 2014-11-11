/*
 * COMMON.C - Fonctions d'interfaçage avec les différents périphériques
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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>

#include "log.h"
#include "misc.h"
#include "ext_scsi.h"
#include "common.h"
#include "device.h"
#include "philips.h"
#include "mmc.h"
#include "teac.h"

#define MIN(A,B) (((A)<(B))?(A):(B))

extern unsigned char ReqBuff[18];

long get_sense_information( void )
{
  unsigned long ret;
#if 0
  if( ReqBuff[0] & 0x80 )   /* Valid */
  {
#endif
    ret =  ((unsigned long)ReqBuff[3]) << 24;
    ret |= ((unsigned long)ReqBuff[4]) << 16;
    ret |= ((unsigned long)ReqBuff[5]) << 8;
    ret |= ((unsigned long)ReqBuff[6]);
#if 0
  }
  else
    ret = 0x80000000L;
#endif
  return (long)ret;
}

int get_sense_key( void )
{
  return (int)(ReqBuff[2] & 0x0f);
}

int get_asc( void )
{
  return (int)ReqBuff[12];
}

int get_ascq( void )
{
  return (int)ReqBuff[13];
}

/* Création d'un bloc CD-ROM en mode RAW */
/* buf = adresse mémoire du buffer */
/* adr = adresse logique du premier bloc */
/* mode = mode du secteur (0,1,2) */
/* count = nombre de blocs à générer */
int create_raw_blocks(
  unsigned char * buf, unsigned long adr, int mode, int count )
{
  static unsigned char sync_buf[12] = { 0x00, 0xFF, 0xFF, 0xFF,
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00 };
  int i, m, s, f;
  int blocksize;
  unsigned long off;
  blocksize = /*toc_buf?2368:*/2352;
  memset( buf, 0, (long)count * blocksize );
  for( i=0; i<count; i++ )
  {
    off = (unsigned long)i*blocksize;
    if( mode )
    {
      memcpy( buf + off, sync_buf, 12 );
      msf( adr, &m, &s, &f );
      buf[ off + 12 ] = hex2bcd( m );
      buf[ off + 13 ] = hex2bcd( s );
      buf[ off + 14 ] = hex2bcd( f );
      buf[ off + 15 ] = mode;
    }
    adr++;
  }
  return 0;
}

/********************************************************
 * Fonctions CD-ROM avancées
 ********************************************************/

/* Démarre la rotation du CD, attend que le disque soit prêt ou pas */
int start_cd( void )
{
  int ret;
  busybee();
  if( start_stop_unit( 0, 1, 1 ) )
    start_stop_unit( 0, 1, 1 );
  ret = 0;
  while( test_unit_ready() )
  {
    if( ReqBuff[12] == 0x3A ) /* MEDIUM NOT PRESENT */
    {
      alert_msg( "AL_NOCD", 1 );
      ret = -1;
      break;
    }
    zdelay( 100 );
  }
  arrow();
  return ret;
}

/* Etablit la TOC étendue pour toutes les sessions du disque */
int get_ext_toc( struct ext_toc * toc )
{
  int i, ret, src, dest, session, ok, toc_bcd, toc_logical;
  int m, s, f;
  unsigned short len;
  long disc_end, adr;
  struct track_desc * desc;
  struct toc std_toc;
  struct ext_toc buf_toc;

  ret = read_toc( 0, 0, &std_toc, (int)sizeof( std_toc.head ) );
  if( ret ) return -1;
  /* Bidouille Pioneer : ne pas prendre la taille retournée, mais la calculer */
  std_toc.head.toc_len = (std_toc.head.last_track - std_toc.head.first_track + 2) * 8 + 2;
  ret = read_toc( 0, 0, &std_toc, std_toc.head.toc_len + 2 );
  if( ret ) return -1;

  for( i=0; std_toc.entry[i].track_no != 0xAA; i++ );
  disc_end = std_toc.entry[i].abs_address;

  ret = read_toc_format( 0, 1, &buf_toc, (int)sizeof( buf_toc.head ), 2 );
  if( ret ) return -1;
  /* Même bidouille, sauf qu'il faut prendre en compte les lecteurs normaux */
  len = (std_toc.head.last_track - std_toc.head.first_track + 4) * 11 + 2;
  if( buf_toc.head.toc_len < len )
    buf_toc.head.toc_len = len;
  ret = read_toc_format( 0, 1, &buf_toc, buf_toc.head.toc_len + 2, 2 );
  if( ret ) return -1;

  i=0;
  do
    desc = &desc( buf_toc, i++ );
  while( desc->session != buf_toc.head.last_track || desc->point != 0xA2 );
  toc_logical = (disc_end == (((long)desc->pmin << 16) | ((long)desc->psec << 8) | (long)desc->pframe));
  toc_bcd = (!toc_logical) && disc_end != logical( desc->pmin, desc->psec, desc->pframe );

  toc->head = buf_toc.head;
  session = buf_toc.head.first_track;
  dest = 0;
  ok = 0;
  do
  {
    src = 0;
    while( desc( buf_toc, src ).session == session )
    {
      memcpy( toc->desc[dest], buf_toc.desc[src], 11 );
      if( toc_bcd )
      {
        if( desc( buf_toc, src ).point < 0xA0 )
          desc(*toc,dest).point = bcd2hex( desc(buf_toc,src).point );
        desc(*toc,dest).min     = bcd2hex( desc(buf_toc,src).min );
        desc(*toc,dest).sec     = bcd2hex( desc(buf_toc,src).sec );
        desc(*toc,dest).frame   = bcd2hex( desc(buf_toc,src).frame );
        desc(*toc,dest).pmin    = bcd2hex( desc(buf_toc,src).pmin );
        if( desc( buf_toc, src ).point != 0xA0 )
          desc(*toc,dest).psec  = bcd2hex( desc(buf_toc,src).psec );
        desc(*toc,dest).pframe  = bcd2hex( desc(buf_toc,src).pframe );
      } else if( toc_logical )
      {
        desc = &desc( *toc, dest );
        if( desc->point >= 0xB0 )
        {
          adr = (((long)desc->min << 16L) | ((long)desc->sec << 8) | (long)desc->frame);
          msf( adr, &m, &s, &f );
          desc->min = m;
          desc->sec = s;
          desc->frame = f;
        }
        if( desc->point < 0xA0 || desc->point >= 0xA2 )
        {
          adr = (((long)desc->pmin << 16L) | ((long)desc->psec << 8) | (long)desc->pframe);
          msf( adr, &m, &s, &f );
          desc->pmin = m;
          desc->psec = s;
          desc->pframe = f;
        }
      }
      dest++; src++;
    }
    if( session < buf_toc.head.last_track )
    {
      session++;
      ret = read_toc_format( 0, session, &buf_toc, (int)sizeof(buf_toc), 2 );
      if( ret ) return -1;
    } else ok=1;
  } while( !ok );
  /* Pas standard, mais bon comme ça on a le nombre d'entrées */
  toc->head.toc_len = dest;
  return 0;
}

/* Retrouve l'entrée de TOC étendue relative à une piste */
int get_toc_entry( struct ext_toc * toc, int track, int session )
{
  int i;
  for( i=0; i<toc->head.toc_len; i++ )
  {
    if( ( session<=0 || desc(*toc,i).session==session )
          && desc( *toc, i ).point == track ) return i;
  }
  return -1;
}

/* Retourne l'offsets de début de la piste spécifiée.
   L'offset de fin peut être retourné si end_offset est non nul */
long get_track_offset( struct ext_toc * toc, int track, long * end_offset )
{
  int entry, session;
  long ret;
  entry = get_toc_entry( toc, track, 0 );
  ret = logical( desc(*toc,entry).pmin, desc(*toc,entry).psec,
                 desc(*toc,entry).pframe );
  if( end_offset )
  {
    session = desc(*toc,entry).session;
    if( track == desc( *toc, get_toc_entry( toc, 0xA1, session ) ).pmin )
      entry = get_toc_entry( toc, 0xA2, session );
    else
      entry = get_toc_entry( toc, track + 1, 0 );
    *end_offset = logical( desc(*toc,entry).pmin, desc(*toc,entry).psec,
                  desc(*toc,entry).pframe );
  }
  return ret;
}

/* Donne le mode d'une piste */
int get_mode( struct ext_toc * toc, int track_no )
{
  int entry;
  long offset;
  char block[2352];
  if( track_no == 0xAA )
  {
    /* Le mode du lead-out est le même que celui de la dernière piste */
    track_no = desc( *toc, get_toc_entry( toc, 0xA1, toc->head.last_track ) ).pmin;
  }
  entry = get_toc_entry( toc, track_no, 0 );
  /* if( (toc->entry[entry].adr_control & 0xF) & 4 ) */
  if( desc( *toc, entry ).adr_control & 4 )
  {
    /* Piste de donnée */
    if( set_blocksize_density( 2352, 0 ) ) return -1;
    offset = logical( desc( *toc , entry ).pmin,
             desc( *toc, entry ).psec, desc( *toc, entry ).pframe );
    if( read_data( offset, 1, block ) ) return -1;
    return (int)block[15];
  }
  else
  {
    /* Piste audio */
    return 0;
  }
}

/* Sélection du mode de vitesse du CD */
int set_read_speed( int speed )
{
  int ret;
  switch( current_device->sets->write_mode )
  {
    case WT_PHILIPS:
      ret = philips_set_speed( current_device->write_speed,
                               current_device->dummy_write, speed, 0 );
      break;
    case WT_TEAC:
      ret = teac_set_speed( speed );
      break;
    case WT_MMC:
      break;
  }
  return ret;
}

int set_write_speed( int speed )
{
  return set_ws( speed, current_device->sets->write_mode );
}

/*
int set_write_speed( int speed, int write_mode )
{
  int ret;
  switch( write_mode )
  {
    case WT_PHILIPS:
      ret = philips_set_write_speed( speed );
      break;
    case WT_TEAC:
      ret = teac_set_speed( speed );
      break;
    case WT_MMC:
      ret = mmc_set_speed( 0, speed );
      break;
  }
  return ret;
}
*/

/*
 * Sélection du mode de simulation en écriture
 * Permet également de forcer la vitesse de gravage à 1x
 */
int set_dummy_write( int dum )
{
  int ret;
  ret = 0;
  switch( current_device->sets->write_mode )
  {
    case WT_PHILIPS:
      ret = philips_set_speed( 1, dum, 0, 0 );
      break;
    case WT_TEAC:
      ret = teac_set_speed( 1 );
      ret = ret || teac_set_preview_write( dum );
    case WT_MMC:
      mmc_set_speed( 0, 1 );
      /* Rien, c'est à l'initialisation du gravage que cela s'effectue */
      break;
  }
  if( ret ) return -1;
  current_device->dummy_write = dum;
  return ret;
}

int common_read( unsigned long begin, unsigned short len, void * buffer )
{
  int ret;
  unsigned long segment_len;
  unsigned long segment_size;
  unsigned long b, l;
  void * buf;
  if( current_device == NULL ) return -1;
  segment_len = current_device->DmaLen / current_device->BlockSize;
  segment_size = segment_len * current_device->BlockSize;
  b = begin;
  l = len;
  buf = buffer;
  while ( l > 0 )
  {
    if( l < segment_len )
    {
      segment_len = l;
      segment_size = l * current_device->BlockSize;
    }
    if( (current_device->status & ST_AUDIO)
        && current_device->sets->audio_mode == AM_TEAC )
      ret = teac_read_cd_da( b, segment_len, 0, buf );
    else if( (current_device->status & ST_AUDIO)
            && current_device->sets->audio_mode == AM_MMC )
      ret = mmc_read_cd( 1, 2352, b, segment_len, 0, 0, 1, 0, 0, 0, buf );
    /* else if( !(current_device->status & ST_AUDIO)
             && current_device->BlockSize == 2352
             && !(current_device->sets->flags & DSF_IS_MMC) )
      ret = mmc_read_cd( 0, 2352, b, segment_len, 1, 1, 1, 1, 1, 0, buf ); */
    else
      ret = read10( b, segment_len, buf );
    if( ret )
    {
      /* Gestion des erreurs de lecture audio avec le graveur Philips */
      if( (current_device->status & ST_AUDIO)
          && ReqBuff[12] == 0x15
          && (!strcmp( current_device->sets->dev_id.vend_id, "PHILIPS" )) )
        continue;
      else break;
    }
    b += segment_len;
    l -= segment_len;
    buf = (void *)((long)buf + segment_size );
  }
/*
  if( (current_device->status & ST_AUDIO)
      && (current_device->sets->flags & DSF_AUD_LITTLE_ENDIAN ) )
  {
    if( ret ) len = get_sense_information() - begin;
    swap_endian( buffer, len * current_device->BlockSize );
  }
*/
  return ret;
}

/* Modes TOSHIBA :
 * 0x00 = Livre jaune (CD-ROM)
 * 0x81 = XA Mode 2
 * 0x82 = Raw Audio (Livre rouge ?)
 * 0x83 = XA Mode 1
 */

/*** Lecture audio ***/
int read_audio( unsigned long begin, unsigned short len, void * buffer )
{
  int read_density;
  if( current_device == NULL ) return -1;
  if( !(current_device->status & ST_AUDIO) )
  {
    if( current_device->sets->audio_mode == AM_TOSHIBA )
      read_density = 0x82;
    else
      read_density = 0;
    if( mode_select( read_density, 0, 2352, NULL, 0 ) ) return -1;
    current_device->status |= ST_AUDIO;
  }
  return common_read( begin, len, buffer );
}

/*** Lecture de données ***/
int read_data( unsigned long begin, unsigned short len, void * buffer )
{
  int ret;
  if( current_device == NULL ) return -1;
  if( current_device->sets->audio_mode == AM_TOSHIBA
      && (current_device->status & ST_AUDIO)
      && set_blocksize( current_device->BlockSize ) ) return -1;
  ret = common_read( begin, len, buffer );
  if( (!ret) && current_device->BlockSize == 2352 )
  {
    if( ((char*)buffer)[15] > 2 )
      scramble( buffer, len );
  }
  return ret;
}

/*** Changement de taille de block et de densité ***/
int set_blocksize_density( unsigned long blocksize, int density )
{
  int ret;
  if( current_device == NULL ) return -1;
  ret = mode_select( density, 0, blocksize, NULL, 0 );
  if( ret ) return -1;
  current_device->status &= ~ST_AUDIO;
  current_device->density = density;
  current_device->BlockSize = blocksize;
  return 0;
}

/*** Changement de taille de block en lecture CD-Rom ***/
int set_blocksize( unsigned long blocksize )
{
  return set_blocksize_density( blocksize, 0 );
}

#if 0
/*** Ouverture d'une piste pour gravage TAO ***/
int open_track( int copy, int raw, int aud, int mode )
{
  static unsigned long def_index[] = { 150, 0 };
  if( raw && set_index_list( def_index ) ) return -1;
  return philips_write_track( 0, copy, raw, aud, mode, 0 );
}

/*** Fermeture d'une piste pour gravage TAO ***/
int close_track( void )
{
  synchronize_cache();
  return 0;
}

/*** Fermeture de la PMA en fin de gravage TAO ***/
int close_pma( int onp, int toc_type )
{
  return philips_fixation( 0, onp, toc_type );
}

/*** Sélection de la liste d'index en gravage TAO ***/
int set_index_list( unsigned long * index )
{
  int ret;
  if( current_device->sets->write_mode == WT_PHILIPS )
    ret = philips_set_index_list( index );
  else
    ret = -1;
  return ret;
}
#endif

/*** Envoi d'infos à graver sur le CD ***/
int write_to_cd( long begin, unsigned short len, void * buffer )
{
  int ret;
  unsigned short length;
  unsigned long segment_len;
  unsigned long size;

  segment_len = current_device->DmaLen / current_device->BlockSize;

  do
  {
    length = MIN( len, segment_len );
    size = length * current_device->BlockSize;
    switch( current_device->sets->write_mode )
    {
    case WT_TEAC:
      ret = teac_write( begin, length, buffer, 1 );
      break;
    case WT_PHILIPS:
      ret = write10( /*begin*/ 0, length, buffer );
      break;
    case WT_MMC:
      ret = write10( begin, length, buffer );
      break;
    }
    if ( ret != 0 ) return ret;
    len -= length;
    buffer = (void *)((long)buffer + size );
    begin += size;
  } while ( len > 0 );
  return ret;
}

#if 0
/*** Ecriture de blocs vides ***/
int write_empty_audio( long begin, unsigned short len )
{
  unsigned short size;
  memset( scsi_buf, 0, MIN( (size_t)len*2352, SCSI_BUF_SIZE ) );
  while( len>0 )
  {
    size = MIN( len, SCSI_BUF_SIZE / 2352 );
    write_to_cd( begin, size, scsi_buf );
    len -= size;
  }
  return 0;
}
#endif

int writes_little_endian_audio( struct device_info * info )
{
  int ret;
  ret = -1;
  switch( info->sets->write_mode )
  {
  case WT_TEAC:
    ret = 1;
    break;
  case WT_PHILIPS:
    ret = 0;
    break;
  case WT_MMC:
    ret = 1;
    break;
  }
  return ret;
}

int autodetect_audiomode( struct ext_toc * toc )
{
  long adr, high_sum, low_sum;
  signed char high, low, x;
  int i, entry, ret, mode, begin_track, end_track, track, session;
  char * type, *format;
  adr = -1L;
  for( session = toc->head.first_track;
       session <= toc->head.last_track && adr < 0; session++ )
  {
    begin_track = desc( *toc, get_toc_entry( toc, 0xa0, session ) ).pmin;
    end_track = desc( *toc, get_toc_entry( toc, 0xa1, session ) ).pmin;
    for( track = begin_track; track <= end_track && adr < 0; track++ )
    {
      entry = get_toc_entry( toc, track, session );
      if( !(desc( *toc, entry ).adr_control & 0x04) )
        adr = logical( desc( *toc, entry ).pmin,
              desc( *toc, entry ).psec, desc( *toc, entry ).pframe );
    }
  }
  if( adr < 0 ) return 0;    /* Pas de pistes audio, donc détection impossible */

  track = desc( *toc, entry ).point;
  entry = get_toc_entry( toc, (track == end_track)?(0xa2):(track+1),
          desc( *toc, entry ).session );
  adr = ( adr + logical( desc( *toc, entry ).pmin,
        desc( *toc, entry ).psec, desc( *toc, entry ).pframe ) ) / 2;

  mode = current_device->sets->audio_mode;
  if( mode != AM_AUTODETECT ) return (mode == AM_NONE)?(-1):0;

  mode = AM_NONE;

  /* Détection Philips */
  ret = set_blocksize_density( 2352, 0 );
  if( ret ) return -1;
  ret = read10( adr, 1, scsi_buf );
  if( !ret ) { mode = AM_CDROM; goto fin; }

  /* Détection Toshiba */
  ret = set_blocksize_density( 2352, 0x82 );
  if( !ret )
  {
    ret = read10( adr, 1, scsi_buf );
    if( !ret ) { mode = AM_TOSHIBA; goto fin; }
    set_blocksize_density( 2352, 0 );
  }

  /* Détection TEAC */
  ret = teac_read_cd_da( adr, 1, 0, scsi_buf );
  if( !ret ) { mode = AM_TEAC; goto fin; }

  /* Détection MMC */
  ret = mmc_read_cd( 1, 2352, adr, 1, 0, 0, 1, 0, 0, 0, scsi_buf );
  if( !ret ) { mode = AM_MMC; goto fin; }

fin:
  switch( mode )
  {
  case AM_NONE:
    type = "none available";
    break;
  case AM_CDROM:
    type = "Philips";
    break;
  case AM_TOSHIBA:
    type = "Toshiba";
    break;
  case AM_TEAC:
    type = "TEAC";
    break;
  case AM_MMC:
    type = "SCSI-3 MMC";
    break;
  }

  if( mode == AM_CDROM || mode == AM_TEAC )
  {
    /* On effectue la détection automatique du mode Big/Little Endian */
    high_sum = low_sum = 0;
    high = low = 0;
    /* Test Big-Little Endian */
    for( i=0; i<2352; i+=4 )
    {
      x = ((signed char)scsi_buf[i])-high;
      high_sum += (x<0)?(-x):x;
      high += x;
      x = ((signed char)scsi_buf[i+1])-low;
      low_sum += (x<0)?(-x):x;
      low += x;
    }
    if( high_sum > low_sum )
      current_device->sets->flags |= DSF_AUD_LITTLE_ENDIAN;
  }
  else if( mode == AM_TOSHIBA || mode == AM_MMC )
    current_device->sets->flags |= DSF_AUD_LITTLE_ENDIAN;
  current_device->sets->audio_mode = mode;

  format = ( current_device->sets->flags & DSF_AUD_LITTLE_ENDIAN )?"little":"big";
  log_device_name();
  log_printf( "*** Detected audio grabbing method : %s, %s-endian format\n\n", type, format );

  return (mode == AM_NONE)?(-1):0;
}

/* Détection du mode de gravage */
int autodetect_writemode( int verbose )
{
  int mode;
  unsigned short flags;
  unsigned int read_speed, write_speed;
  char buf[128];
  char * type;
  if( current_device->sets->write_mode != WT_AUTODETECT ) return 0;
  current_device->BlockSize = 2352;
  mode = WT_NONE;
  read_speed = 0;
  write_speed = 0;
  busybee();
  while( test_unit_ready() )
  {
    if( ReqBuff[12] == 0x3A ) /* MEDIUM NOT PRESENT */
      break;
    zdelay( 100 );
  }

  /* 17/5/00 : mise de la détection TEAC en premier
   * à cause du CD-R58s modifié en CD-R55s
   */
  if( (!teac_set_preview_write( 0 )) || ReqBuff[12] == 0x3A )
  {
    mode = WT_TEAC;
    current_device->sets->flags |= DSF_SUP_DAO_WR;
    /* teac_get_max_speed( &speed ); */
    write_speed = 4;
  }
  else if( !mmc_read_cd_capabilities( buf, 22 ) )
  {
    flags = DSF_IS_MMC;
    if( buf[3] & 0x01 ) /* Grave les CD-R ? */
    {
      mode = WT_MMC;
      write_speed = *((short *)(buf+18)) / 176;
      /* current_device->sets->flags &=
        ~(DSF_SUP_SAO_WR|DSF_SUP_RAW_WR|DSF_WRITE_CDRW); */
      if( !mmc_set_write_parameters( 2, 0, 4, 8, 0, 0, 0, NULL, NULL, 0 ) )
        flags |= DSF_SUP_SAO_WR;
      if( !mmc_set_write_parameters( 3, 0, 4, 1, 0, 0, 0, NULL, NULL, 0 ) )
        flags |= DSF_SUP_RAW_WR;
      if( (!(flags & DSF_SUP_SAO_WR)) && (flags & DSF_SUP_RAW_WR) )
        flags |= DSF_PREF_RAW;
      if( flags & DSF_SUP_SAO_WR || flags & DSF_SUP_RAW_WR )
        flags |= DSF_SUP_DAO_WR;
      if( buf[3] & 0x02 ) flags |= DSF_WRITE_CDRW;
    }
    read_speed = *((short *)(buf+8)) / 176;
    if( buf[2] & 0x02 ) flags |= DSF_READ_CDRW;
    current_device->sets->flags |= flags;
  }
  else if( !philips_set_speed( 1, 1, 0, 0 ) )
  {
    mode = WT_PHILIPS;
    current_device->sets->flags |= DSF_SUP_DAO_WR;
    read_speed = 6;
    write_speed = 2;
  }
  if( verbose )
  {
    switch( mode )
    {
    case WT_NONE:
      type = "Unknown";
      break;
    case WT_MMC:
      strcpy( buf, "SCSI-3 MMC" );
      if( current_device->sets->flags & DSF_SUP_SAO_WR )
        strcat( buf, " - SAO support" );
      if( current_device->sets->flags & DSF_SUP_RAW_WR )
        strcat( buf, " - RAW write support" );
      if( current_device->sets->flags & DSF_WRITE_CDRW )
        strcat( buf, " - CD-RW support" );
      type = buf;
      break;
    case WT_TEAC:
      type = "TEAC";
      break;
    case WT_PHILIPS:
      type = "PHILIPS";
      break;
    }
    log_device_name();
    log_printf( "*** Detected type of the recorder : %s\n\n", type );
  }

  if( mode != WT_NONE ) current_device->sets->flags |= DSF_IS_WRITER;
  current_device->sets->write_mode = mode;
  current_device->sets->max_read_speed = read_speed;
  current_device->sets->max_write_speed = write_speed;
  arrow();
  return (mode == WT_NONE)?(-1):0;
}

/* Détection de l'utilisation ou non du Mode Select 10 */
int autodetect_ms10( void )
{
  int ret;
  /* Forçage du Mode Select 6 */
  current_device->sets->flags &= ~DSF_USE_MS10;
  ret = mode_sense( 0, 0, 0x0d, scsi_buf, 8 );
  /* Si ça ne marche pas, on passe en Mode Select 10 */
  if( ret )
  {
    current_device->sets->flags |= DSF_USE_MS10;
    /* Ceci ne sert à rien, c'est juste pour le log */
    mode_sense( 0, 0, 0x0d, scsi_buf, 8 );
  }
  return ret;
}

