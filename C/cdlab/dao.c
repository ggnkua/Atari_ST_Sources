/*
 * DAO.C - Fonctions de gestion du mode DAO
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
#include <stddef.h>
#include <tos.h>

#include "misc.h"
#include "prefs.h"
#include "ext_scsi.h"
#include "common.h"
#include "device.h"
#include "teac.h"
#include "philips.h"
#include "mmc.h"
#include "audio.h"
#include "dao.h"

#define MIN(A,B) ((A)<(B)?(A):(B))

#define HEADER_VERSION 0x0002
#define MAX_INDEX_SIZE 0x2000L
#define BUFSIZE 0x20000L    /* Taille du buffer pour la copie de CD */
#define MAX_WRITE_TIME 4000  /* Temps d'écriture au delà duquel on considère que le lead-in est écrit */

unsigned char toc_buf[ 110*16 ];
int toc_buf_entry_count;

int dao_asc, dao_ascq;

/*** Petite fonction pour open_session ***/
/* Pour les graveurs MMC, retourne le DATA FORM de génération automatique */
/* par rapport au Data Form de génération manuelle */
int ops_mmc_data_form( int form )
{
  switch( form )
  {
    case 0x11:    /* CD-Rom mode 1 */
      return 0x14;
    case 0x31:    /* CD-Rom Mode 2 */
      return 0x34;
    case 0x00:    /* CD Audio */
      return 0x01;
  }
  return 0xff;   /* en cas d'erreur */
}

/* Génération d'une TOC au format Teac */
void generate_toc( unsigned char * buf, int * length, int toc_type,
                   struct index_position index[], int first, int last )
{
  int i, j, k, m, s, f;

  *length = (index[last-1].track-index[first].track+4)*5;
  memset( buf, 0, *length );
  k = 0;
  for( i = index[ first ].track; i <= index[ last-1 ].track; i++ )
  {
    j=first; while( index[j].track != i || index[j].index != 1 ) j++;
    msf( index[j].offset, &m, &s, &f );
    buf[k++] = ( (index[j].control&0xF) << 4 ) | 1;
    buf[k++] = hex2bcd( index[j].track );
    buf[k++] = hex2bcd( m );
    buf[k++] = hex2bcd( s );
    buf[k++] = hex2bcd( f );
  }
  buf[k++] = ( (index[first].control&0xF) << 4 ) | 1;
  buf[k++] = 0xa0;
  buf[k++] = hex2bcd( index[first].track );
  buf[k++] = toc_type;
  k += 1;
  buf[k++] = ( (index[last-1].control&0xF) << 4 ) | 1;
  buf[k++] = 0xa1;
  buf[k++] = hex2bcd( index[last-1].track );
  k += 2;
  buf[k++] = ( (index[last-1].control&0xF) << 4 ) | 1;
  buf[k++] = 0xa2;
  msf( index[last].offset, &m, &s, &f );
  buf[k++] = hex2bcd( m );
  buf[k++] = hex2bcd( s );
  buf[k++] = hex2bcd( f );
}

/*** Ouverture d'une session en DAO ***/
/* Le dernier index doit avoir un numéro de piste à 0 */
int open_session( int session, int toc_type, struct index_position index[],
                  int * lead_in_size, int * lead_out_size )
{
  int index_count[100];
  unsigned short lead[2];
  long adr;
  int ret, first, last, i, j, k, track_count, m, s, f, length;
  int lofp, type;
  struct philips_track_descriptor * td;
  unsigned char * src, * dst;

  first = 0; while( index[first].session != session ) first++;

  switch( current_device->sets->write_mode )
  {
  case WT_PHILIPS:
    set_blocksize( 2352 );

    if( philips_read_session_info( lead ) ) return 1;
    *lead_in_size = lead[0];
    *lead_out_size = lead[1];

    td = xmalloc( sizeof( struct philips_track_descriptor ) * 100 );
    if( !td )
      return -1;
    memset( index_count, 0, 100*sizeof( index_count[0] ) );
    track_count = 0;
    for( i=first; index[i].track!=0; i++ )
    {
      if( index[i].index == 0 ) continue;
      if( index[i].track > track_count ) track_count = index[i].track;
      j = index[i].track - 1;
      if( index[i].index == 1 )
      {
        td[j].isrc1 = 0;
        td[j].isrc2 = 0;
        td[j].isrc3 = 0;
        td[j].isrc4 = 0;
        td[j].isrc5 = 0;
        td[j].isrc6_7 = 0;
        td[j].isrc8_9 = 0;
        td[j].isrc10_11 = 0;
        td[j].isrc12 = 0;
        td[j].control = index[i].control;
        td[j].startadr = index[i].offset;
      }
      else
      {
        td[j].indexadr[index[i].index-2] = index[i].offset;
        index_count[j]++;
      }
    }
    for( j=0; j<track_count; j++ )
    {
      for( i=0; (index[i].track!=(j+2) || index[i].index!=0)
                && index[i].track > 0; i++ );
      if( index[i].track > 0 || j==(track_count-1) )
        td[j].indexadr[index_count[j]] = index[i].offset;
      else
        td[j].indexadr[index_count[j]] = td[j+1].startadr;
      td[j].length = 20 + index_count[j] * 4;
    }

    switch( toc_type )
    {
    case 0x00:
      lofp = 0;
      type = 0;             /* CD-DA ou CD-Rom */
      break;
    case 0x10:
      lofp = 0;
      type = 4;             /* CDI */
      break;
    case 0x20:
      lofp = 0;
      type = 3;             /* CD-ROM XA avec premère piste en mode 2 */
      break;
    }
    ret = philips_write_session( lofp, 0, type, td, track_count );
    free( td );
    if( ret ) return -1;
    break;

  case WT_TEAC:
    *lead_in_size = 0;
    *lead_out_size = 0;
    ret = teac_set_write_method( 2 );  /* Mode DAO */
    if( ret ) return ret;
    ret = teac_opc_execution( 1 );     /* Teste si le CD est gravable */
    if( ret ) return ret;
    ret = teac_clear_subcode();
    if( ret ) return ret;

    ret = teac_set_limits( -150, 150 );
    if( ret ) return ret;
    ret = teac_set_subcode_pma( 1, index[0].control, 1, 0 );
    if( ret ) return ret;
    for( i=first; index[i].track!=0; i++ )
    {
      ret = teac_set_limits( index[i].offset,
                             index[i+1].offset - index[i].offset );
      if( ret ) return ret;
      ret = teac_set_subcode_pma( index[i].index?0:1,
            index[i].control, index[i].track, index[i].index );
      if( ret ) return ret;
    }

    scsi_buf[ 2 ] = scsi_buf[ 1 ] = scsi_buf[ 0 ] = 0;
    generate_toc( scsi_buf + 3, &length, toc_type, index, first, i );
    ret = teac_set_subcode( 0, length + 3, scsi_buf );
    if( ret ) return ret;
    ret = teac_opc_execution( 0 );     /* Exécute la calibration optique */
    if( ret ) return ret;

    break;

  case WT_MMC:
    ret = mmc_read_disc_information( scsi_buf, 32 );
    if( ret ) return ret;
    if( current_device->sets->flags & DSF_SUP_SAO_WR )
    {
      *lead_in_size = *lead_out_size = 0;
      ret = mmc_set_write_parameters( 2, 0, 4, 8, toc_type, 0, 0, NULL, NULL, 0 );
      if( ret ) return ret;
      ret = mmc_read_track_information( scsi_buf, 0, 1, 28 );
      if( ret ) return ret;
      current_device->BlockSize = 2352;
      for( i=first; index[i].track!=0; i++ );
      last = i;
      length = (last-first+3) * 8;
      memset( scsi_buf, 0, length );
      k = 16;
      for( i = first; i < last; i++ )
      {
        scsi_buf[k++] = ( (index[i].control&0xF) << 4 ) | 1;
        scsi_buf[k++] = index[i].track;
        scsi_buf[k++] = index[i].index;
        switch( index[i].blocksize )
        {
        case 2048:        /* CD-Rom Mode 1 */
          scsi_buf[k] = 0x11;
          break;
        case 2336:        /* CD-Rom Mode 2 */
          scsi_buf[k] = 0x31;
          break;
        case 2352:        /* CD Audio */
          scsi_buf[k] = 0x00;
          break;
        }
        k++;
        scsi_buf[k++] = 0;    /* Serial Copy Management System */
        msf( index[i].offset, &m, &s, &f );
        scsi_buf[k++] = m;
        scsi_buf[k++] = s;
        scsi_buf[k++] = f;
      }
      scsi_buf[0]  = scsi_buf[16];
      scsi_buf[3]  = scsi_buf[19]; /* ops_mmc_data_form( scsi_buf[ 19 ] ); */
      scsi_buf[8]  = scsi_buf[16];
      scsi_buf[9]  = scsi_buf[17];
      scsi_buf[11] = scsi_buf[3];
      scsi_buf[k] = scsi_buf[k++-8];
      scsi_buf[k++] = 0xaa;   /* lead-out */
      scsi_buf[k++] = 0x01;
      scsi_buf[k++] = ret;
      k++;
      msf( index[last].offset, &m, &s, &f );
      scsi_buf[k++] = m;
      scsi_buf[k++] = s;
      scsi_buf[k++] = f;
      ret = mmc_send_cue_sheet( length, scsi_buf );
      /* out,  */
      if( ret ) return ret;
    }
    else if( current_device->sets->flags & DSF_SUP_RAW_WR )
    {
      adr = logical( scsi_buf[17]-100, scsi_buf[18], scsi_buf[19] );
      *lead_in_size = (int)(-adr - 150L);
      *lead_out_size = (int)logical( scsi_buf[20], scsi_buf[21], scsi_buf[22] );
      ret = mmc_set_write_parameters( 3, 0, 0, 1, 0, 0, 0, NULL, NULL, 0 );
      current_device->BlockSize = 2368;
      for( i=first; index[i].track!=0; i++ );
      generate_toc( scsi_buf, &length, toc_type, index, first, i );
      src = scsi_buf;
      dst = toc_buf;
      length /= 5;
      toc_buf_entry_count = length;
      memset( toc_buf, 0, length * 16 );
      for( i=0; i<length; i++ )
      {
        *dst++ = *src++;
        dst ++;
        *dst++ = *src++;
        dst +=4;
        *dst++ = *src++;
        *dst++ = *src++;
        *dst++ = *src++;
        dst += 6;
      }
    }
    break;
  default:
    return -1;          /* Graveur inexistant */
  }
  return 0;
}

/*** Fermeture d'une session DAO ***/
int close_session( void )
{
  int ret;
  switch( current_device->sets->write_mode )
  {
  case WT_PHILIPS:
  case WT_MMC:
    ret = synchronize_cache();
    break;
  case WT_TEAC:
    ret = teac_write( 0, 0, NULL, 0 );
    break;
  }

  return ret;
}

unsigned short dao_calc_blocksize( struct ext_toc * toc, int track )
{
  const static unsigned short val[] = { 2352, 2048, 2336 };
  int mode;
  mode = get_mode( toc, track );
  return (mode >= 0) ? val[ mode ] : 0;
}

/* Récupération d'une liste ORDONNEE d'index */
int dao_get_index( struct ext_toc * toc,
                   struct index_position * index, int * index_count )
{
  int session, track, i, max_trk, entry, prec, first_session_track;
  unsigned char control;
  unsigned short blocksize;
  long offset, previous_session_end, supposed_offset;
  /* Pour l'instant, la fonction est simplifiée à l'extrême */
  /*if( in == NULL || in->type != TST_CD ) return -1;*/
  i = 0;
  previous_session_end = -11400L;
  for( session = toc->head.first_track;
       session <= toc->head.last_track; session ++ )
  {
    max_trk = desc( *toc, get_toc_entry( toc, 0xa1, session ) ).pmin;
    first_session_track = desc( *toc, get_toc_entry( toc, 0xa0, session ) ).pmin;
    for( track = first_session_track; track <= max_trk; track ++ )
    {
      entry = get_toc_entry( toc, track, session );
      control = desc( *toc, entry ).adr_control & 0xF;
      offset = logical( desc( *toc , entry ).pmin,
               desc( *toc, entry ).psec, desc( *toc, entry ).pframe );
      blocksize = dao_calc_blocksize( toc, track );
      if( !blocksize ) return -1;
      if( track == first_session_track )
      {
        supposed_offset = previous_session_end + 11400L;
        if( offset > supposed_offset )
        {
          index[i].session = session;
          index[i].track = track;
          index[i].index = 0;
          index[i].control = control;
          index[i].blocksize = blocksize;
          index[i].offset = supposed_offset;
          i++;
        }
      }
      if( track > 1 )
      {
        prec = get_toc_entry( toc, track - 1, session );
        if( desc( *toc, entry ).session == desc( *toc, prec ).session
            && (desc( *toc, prec ).adr_control & 0x0F) != control )
        {
          index[i].session = session;
          index[i].track = track;
          index[i].index = 0;
          index[i].control = control;
          index[i].blocksize = blocksize;
          index[i].offset = offset - 150;
          i++;
        }
      }
      index[i].session = session;
      index[i].track = track;
      index[i].index = 1;
      index[i].control = control;
      index[i].blocksize = blocksize;
      index[i].offset = offset;
      i++;
    }
    entry = get_toc_entry( toc, 0xa2, session );
    index[i].session = session;
    index[i].track = 0;
    index[i].index = 0;
    index[i].control = 0;
    index[i].blocksize = 0;
    previous_session_end = logical( desc( *toc , entry ).pmin,
            desc( *toc, entry ).psec, desc( *toc, entry ).pframe );
    index[i].offset = previous_session_end;
    i++;
  }
  *index_count = i;
  return 0;
}

/* Ouverture d'un flux DAO sur fichier, en lecture */
struct idao_stream * idao_open_file( char * filename )
{
  char * err = NULL;
  int handle;
  long index_size;
  struct idao_stream * stream;
  struct dao_file_header header;

  handle = open( filename, O_RDONLY );
  if( handle <= 0 )
  {
    err = "AL_FILEERR";
    goto fileerror;
  }
  stream = xmalloc( sizeof( *stream ) );
  if( !stream )
    goto memerror;
  read( handle, &header, sizeof( header ) );
  if( header.version != HEADER_VERSION )
  {
    err = "AL_WRONGVER";
    goto error;
  }
  index_size = header.index_count * sizeof( struct index_position );
  stream->index = xmalloc( index_size );
  if( !stream->index )
    goto error;
  read( handle, &(stream->toc), header.toc_size );
  read( handle, stream->index, index_size );
  lseek( handle, header.header_size, SEEK_SET );
  stream->index_count = header.index_count;
  stream->spec.file.handle = handle;
  stream->spec.file.header_size = header.header_size;
  stream->spec.file.position = 0;
  stream->flags = header.flags;
  stream->type = TST_FILE;
  return stream;

error:
  free( stream );
memerror:
  close( handle );
fileerror:
  alert_msg( err, 1, filename );
  return NULL;
}

struct idao_stream * idao_open_cd( struct device_info * info )
{
  char * err = NULL;
  struct device * dev;
  struct idao_stream * stream;

  if( (dev = open_device( info->id, info->bus_no )) == NULL )
  {
    err = "AL_CANTOPEN";
    goto error;
  }
  use_device( dev );
  if( start_cd() )
    goto memerror;
  stream = xmalloc( sizeof( *stream ));
  if( !stream )
    goto memerror;
  prevent_allow_medium_removal( 1 );

  mode_sense( 0, 0, 0x01, stream->spec.cd.context, 8 );
  /* recherche du type de TOC */
  get_ext_toc( &stream->toc );
  stream->index = xmalloc( MAX_INDEX_SIZE );
  if( !stream->index )
    goto mem2error;
  if( dao_get_index( &stream->toc, stream->index, &stream->index_count ) )
  {
    err = "AL_CANTREAD";
    goto mem2error;
  }
  stream->index = realloc( stream->index,
                  stream->index_count * sizeof( struct index_position ) );

  if( autodetect_audiomode( &stream->toc ) )
  {
    err = "AL_NOREADDA";
    goto mem2error;
  }
  set_cdrom_parameters( 0x0c );   /* Attente de 4 minutes */
  set_error_recovery( 0x20, preferences.retry_count );
  set_blocksize( 2352 );

  stream->type = TST_CD;
  stream->flags.audio_little_endian = ((info->sets->flags & DSF_AUD_LITTLE_ENDIAN)?1:0);
  stream->spec.cd.dev = dev;
  stream->spec.cd.flags = 0;
  return stream;

mem2error:
  free( stream );
memerror:
  close_device( dev );
error:
  alert_msg( err, 1, info->id, info->bus_no );
  return NULL;
}

struct idao_stream * idao_open_audio( struct audio_entry * entry, int entry_count )
{
  char * err = NULL;
  struct idao_stream * stream;

  stream = xmalloc( sizeof( *stream ) );
  if( !stream )
    goto memerror;

  stream->index = xmalloc( MAX_INDEX_SIZE );
  if( !stream->index )
    goto mem2error;

  /* Génération de la toc */
  /***/
  audio_gen_toc( &stream->toc, entry, entry_count );

  dao_get_index( &stream->toc, stream->index, &stream->index_count );
  stream->index = realloc( stream->index,
                  stream->index_count * sizeof( struct index_position ) );
  stream->type = TST_AUDIO;
  stream->flags.audio_little_endian = 0;
  stream->spec.audio.count = entry_count;
  stream->spec.audio.entry = entry;

  return stream;
mem2error:
  free( stream );
memerror:
  alert_msg( err, 1 );
  return NULL;
}


/* Ouverture d'un flux DAO sur fichier, en écriture */
struct odao_stream * odao_open_file( char * filename )
{
  int handle;
  struct odao_stream * stream;
  struct device_info * info;

  handle = creat( filename );
  if( handle <= 0 ) return NULL;
  stream = xmalloc( sizeof( *stream ) );
  if( stream == NULL ) { close( handle ); return NULL; }

  stream->type = TST_FILE;

  info = first_dev;
  while( info != NULL && !(info->sets->flags & DSF_IS_WRITER) )
    info = info->next;
  stream->flags.audio_little_endian =
    (info ? writes_little_endian_audio( info ) : 0);
  stream->spec.file.handle = handle;
  return stream;
}

struct odao_stream * odao_open_cd( struct device_info * info )
{
  struct device * dev;
  struct odao_stream * stream;

  if( (dev = open_device( info->id, info->bus_no )) == NULL ) return NULL;
  use_device( dev );
  if( start_cd( ) < 0 || (stream = xmalloc( sizeof( *stream ))) == NULL )
  {
    alert_msg( "AL_CANTOPEN", 1, info->bus_no, info->id );
    close_device( dev );
    return NULL;
  }
  prevent_allow_medium_removal( 1 );
  memset( stream, 0, sizeof( *stream ) );
  mode_sense( 0, 0, 0x01, stream->spec.cd.context, 8 );
  stream->type = TST_CD;
  stream->spec.cd.dev = dev;
  stream->flags.audio_little_endian = writes_little_endian_audio( info );
  stream->spec.cd.flags = 0;
  return stream;
}

int idao_close( struct idao_stream * stream )
{
  if( !stream ) return -1;
  if( stream->type == TST_CD )
  {
    use_device( stream->spec.cd.dev );
    set_blocksize_density( *((unsigned long *)(stream->spec.cd.context+4)),
                           stream->spec.cd.context[ 0 ] );
    prevent_allow_medium_removal( 0 );
    if( ( stream->spec.cd.flags & CDFLG_EJECT )
      && start_stop_unit( 1, 1, 0 ) ) return -1;
    close_device( stream->spec.cd.dev );
  }
  else if( stream->type == TST_FILE )
    close( stream->spec.file.handle );
  free( stream->index );
  free( stream );
  return 0;
}

int odao_close( struct odao_stream * stream )
{
  if( !stream ) return -1;
  if( stream->type == TST_CD )
  {
    use_device( stream->spec.cd.dev );
    set_blocksize_density( *((unsigned long *)(stream->spec.cd.context+4)),
                           stream->spec.cd.context[ 0 ] );
    prevent_allow_medium_removal( 0 );
    if( ( stream->spec.cd.flags & CDFLG_EJECT )
      && start_stop_unit( 0, 1, 0 ) ) return -1;
    close_device( stream->spec.cd.dev );
  }
  else if( stream->type == TST_FILE ) close( stream->spec.file.handle );
  free( stream );
  return 0;
}

int dao_pipe_read( struct idao_stream * in, long offset, long len,
                   unsigned char * read_buf, int audio )
{
  int key, asc;
  int ret, cont;
  long adr, decal;
  long toread;
  switch( in->type )
  {
  case TST_CD:
    use_device( in->spec.cd.dev );
    do
    {
      cont = 0;
      if( audio )
        ret = read_audio( offset, len, read_buf );
      else
        ret = read_data( offset, len, read_buf );
      if( ret && preferences.pref_flags.ignore_err )
      {
        /* Il y a eu une erreur et on doit l'ignorer */
        adr = get_sense_information();
        key = get_sense_key();
        asc = get_asc();
        /* (Medium error ou invalid mode ou end of user area ou erreur cdd3600
            ou servo failure) et adresse valide ? */
        if( (key == 3 || asc == 0x63 || asc == 0x64 || asc == 0x3b || asc == 0x09)
             && adr != 0x80000000L )
        {
          if( asc == 0x02 )  /* Si c'est un no seek complete, le rezero suffit */
            rezero_unit();
          else
          {
            decal = adr - offset + 1;
            offset = adr + 1;
            len -= decal;
            read_buf += decal * in->spec.cd.dev->BlockSize;
            ret = 0;
          }
          cont = 1;
        }
      }
    } while( cont && len > 0 );
    break;

  case TST_FILE:
    if( offset != in->spec.file.position )
      lseek( in->spec.file.handle, offset*2352 + in->spec.file.header_size, SEEK_SET );
    ret = (read( in->spec.file.handle, read_buf, len * 2352 )
        == len * 2352)?0:-1;
    break;
  
  case TST_AUDIO:
    if( !in->spec.audio.stream )
    {
      /* Cas de la première lecture */
      in->spec.audio.stream = audio_open( in->spec.audio.entry + 0 );
      if( !in->spec.audio.stream )
      {
        ret = -1;
        break;
      }
      in->flags.audio_little_endian = in->spec.audio.stream->little_endian;
    }
    toread = MIN( len, in->spec.audio.stream->block_count );
    ret = 0;
    while( toread > 0L && !ret )
    {
      audio_read( in->spec.audio.stream, read_buf, toread );
      read_buf = read_buf + toread * 2352;
      len -= toread;
      toread = MIN( len, in->spec.audio.stream->block_count );
      if( in->spec.audio.stream->block_count == 0L )
      {
        audio_close( in->spec.audio.stream );
        in->spec.audio.current ++;
        if( in->spec.audio.current < in->spec.audio.count )
        {
          in->spec.audio.stream = audio_open( in->spec.audio.entry + in->spec.audio.current );
          if( !in->spec.audio.stream ) ret = -1;
          in->flags.audio_little_endian = in->spec.audio.stream->little_endian;
        }
        else if( toread )
          ret = -1;
      }
    }
    ret = 0;
    break;
  }

  return ret;
}

/* Fonction locale */
void dao_pipe_transform( struct idao_stream * in, struct odao_stream * out, long offset,
                         long len, short blocksize, unsigned char * buffer, int audio,
                         int track_no, int index_no, long track_offset )
{
  /* offset       = position sur le CD (si >= 100:00:00 ( 449850 ), alors lead-in)
     len          = nombre de blocks à transformer
     blocksize    = taille des blocs qui devront être envoyés (TEAC ou RAW uniquement)
     buffer       = adresse des blocs au format brut (2352 octets)
     audio        = les pistes sont au format audio
     track_no     = numéro de la piste actuelle
     index_no     = numéro de l'index actuel
     track_offset = offset du début de la piste (index 0)
  */

  int i, idx, start;
  int m, s, f;
  unsigned char * dest;

  if( audio && in->flags.audio_little_endian != out->flags.audio_little_endian )
    swap_endian( buffer, 2352*len );

  else if( (!audio) && out->type == TST_CD 
           && ( out->spec.cd.dev->sets->write_mode == WT_PHILIPS
                || ( out->spec.cd.dev->sets->write_mode == WT_MMC 
                     && current_device->sets->flags & DSF_PREF_RAW ) ) )
  {
    scramble( buffer, len );
    if( out->spec.cd.dev->sets->write_mode == WT_PHILIPS )
      swap_endian( buffer, 2352*len );
  }

  if( out->type == TST_CD )
  {
    if( out->spec.cd.dev->sets->write_mode == WT_TEAC
        && ( blocksize == 2048 || blocksize == 2336 ) )
      start = 16;
    else
    {
      start = 0;
      blocksize = ( out->spec.cd.dev->BlockSize == 2368 ) ? 2368 : 2352;
    }
    change_format( buffer, len, start, blocksize );
    if( out->spec.cd.dev->BlockSize == 2368 )  /* raw writing */
    {
      for( i=0; i<len; i++ )
      {
        dest = buffer + (unsigned long)i*2368 + 2352;
        if( track_no == 0 )
        {
          /* On est dans le lead-in */
          idx = ( (int)(offset - 449850L) ) % (3 * toc_buf_entry_count) / 3;
          memcpy( dest, toc_buf + idx * 16, 16 );
          dest += 3;
          msf( offset - 449850L - 150L, &m, &s, &f );
          *dest++ = hex2bcd( m );
          *dest++ = hex2bcd( s );
          *dest++ = hex2bcd( f );
        }
        else
        {
          /* Piste ordinaire */
          memset( dest, 0, 16 );
          *dest++ = audio?0x01:0x41;
          *dest++ = (track_no <= 99) ? hex2bcd( track_no ) : track_no;
          *dest++ = hex2bcd( index_no );
          msf( offset - track_offset - 150, &m, &s, &f );
          *dest++ = hex2bcd( m );
          *dest++ = hex2bcd( s );
          *dest++ = hex2bcd( f );
          dest++;
          msf( offset, &m, &s, &f );
          *dest++ = hex2bcd( m );
          *dest++ = hex2bcd( s );
          *dest++ = hex2bcd( f );
        }
        offset ++;
      }
    }
  }
}

/* Fonction locale */
int dao_pipe_write( struct odao_stream * out, long offset, long len,
                    short blocksize, unsigned char * buffer )
{
/* offset = adresse logique d'écriture sur le CD
   len    = nombre de blocs à écrire
   blocksize = format des blocs (significatif uniquement en mode TEAC)
   buffer    = adresse du bloc de données
*/

  int ret, density;
  if( out->type == TST_FILE )
  {
    ret = ( write( out->spec.file.handle, buffer, len * 2352 )
            == len * 2352 )?0:-1;
  }
  else if( out->type == TST_CD )
  {
    use_device( out->spec.cd.dev );
    /* Gestion différente selon les graveurs */
    if( out->spec.cd.dev->sets->write_mode == WT_TEAC )
    {
      /* Gestion du changement de taille de bloc (TEAC) */
      switch( blocksize )
      {
        case 2048: /* CD-ROM Mode 1 */
          density = 0x01;
          break;
        case 2336: /* CD-ROM Mode 2 */
          density = 0xC1;
          break;
        case 2352: /* Audio */
          density = 0x04;
          break;
      }
      if( (long)blocksize != out->spec.cd.dev->BlockSize
       || density != out->spec.cd.dev->density )
      {
        set_blocksize_density( blocksize, density );
      }
    }

    /* écriture proprement dite */
    /* ret = 0; */
    ret = write_to_cd( offset, len, buffer );
    if( ret == 2 )    /* Status error */
    {
      dao_asc = get_asc();
      dao_ascq = get_ascq();
      rezero_unit();
    }
  }
  return ret;
}

int dao_pipe( const char * copy_msg, struct idao_stream * in, struct odao_stream * out )
{
  int session, entry, buf_len, index_i, last_index_i, audio, mode, track;
  int lead_in_size, lead_out_size;
  int ret, header_size, index_size;
  int timer_started;
  long len, offset, end_offset, track_offset, header_offset;
  long time;
  struct dao_file_header header;
  unsigned char * buffer, * read_buf;

  if( (!in) || (!out) ) return -1;
  buffer = alloc_comm_buffer( BUFSIZE );
  if( !buffer )
    return -1;

  /* Init de la liste d'index */
  index_size = in->index_count * (int)sizeof( struct index_position );

  offset = -150;
  progress_init( copy_msg, (out->type == TST_CD) ? (in->index[in->index_count-1].offset + 150)
                 : (in->index[in->index_count-1].offset - in->index[0].offset) );
  index_i = 0;

  read_buf = buffer;
  if( out->type == TST_CD && out->spec.cd.dev->sets->write_mode == WT_MMC
      && out->spec.cd.dev->sets->flags & DSF_PREF_RAW )
    buf_len = (int)( BUFSIZE / 2368 );
  else
    buf_len = (int)( BUFSIZE / 2352 );
  session = in->toc.head.first_track;
  while( session <= in->toc.head.last_track )
  {
    timer_started = 0;
    if( out->type == TST_CD )
    {
      progress_setinfo( get_string( "TXT_DAO_OSESS" ) );
      progress_activate_cancel( 0 );
      use_device( out->spec.cd.dev );
      if( open_session( session, desc( in->toc, get_toc_entry(
                    &in->toc, 0xa0, session ) ).psec, in->index, &lead_in_size, &lead_out_size ) )
        goto open_session_error;

      memset( read_buf, 0, (long)buf_len * 2352 );

      /* Ecriture du lead-in et du pregap */

      entry = get_toc_entry( &in->toc, 0xa0, session );
      mode = desc( in->toc, entry ).psec;
      track = desc( in->toc, entry ).pmin;
      entry = get_toc_entry( &in->toc, track, session );
      if( mode == 0 )
        mode = (desc( in->toc, entry ).adr_control & 4) ? 1 : 0;
      else
        mode = 2;

      header_offset = 449850L;   /* 100:00:00 */
      offset = -lead_in_size - 150;
      while( lead_in_size > 0 )
      {
        if( yield() ) goto cancel;
        len = MIN( buf_len, lead_in_size );
        create_raw_blocks( read_buf, header_offset, mode, (int)len );
        dao_pipe_transform( in, out, header_offset, len, 2352, read_buf, mode==0, 0, 0, -150 );
        ret = dao_pipe_write( out, offset, len, 2352, read_buf );
        if( ret ) goto write_error;
        lead_in_size -= (int)len;
        header_offset += len;
        offset += len;
      }

      /* Ecriture du pregap */

      track_offset = in->index[index_i].offset;
      while( offset < in->index[index_i].offset )
      {
        if( yield() ) goto cancel;
        len = MIN( in->index[index_i].offset - offset, buf_len );
        create_raw_blocks( read_buf, offset, mode, (int)len );
        if( !timer_started ) time = timer();
        dao_pipe_transform( in, out, offset, len, in->index[index_i].blocksize,
                            read_buf, mode == 0, 1, 0, track_offset );
        ret = dao_pipe_write( out, offset, len, in->index[index_i].blocksize,
                              read_buf );
        if( ret ) goto write_error;
        if( !timer_started )
        {
          time = timer() - time;
          if( time > MAX_WRITE_TIME )
          {
            progress_setinfo( get_string( "TXT_DAO_DATA" ) );
            progress_init_timer();
            progress_activate_cancel( 1 );
            timer_started = 1;
          }
        }
        progress_setcount( offset + 150 );
        offset += len;
      }
    }
    else /* out->type == TST_FILE */
    {
      /* Ecriture du header de fichier */
      header.version = HEADER_VERSION;
      header.toc_size = in->toc.head.toc_len * 11 + (int)sizeof( in->toc.head );
      header_size = (int)sizeof( header ) + header.toc_size + index_size;
      header.header_size = (int)((header_size + 15) & 0xFFFFFFF0L);
      header.index_count = in->index_count;
      header.flags = out->flags;
      write( out->spec.file.handle, &header, sizeof( header ) );
      write( out->spec.file.handle, &(in->toc), header.toc_size );
      write( out->spec.file.handle, in->index, index_size );
      header_size = header.header_size - header_size;
      memset( buffer, 0, header_size );
      write( out->spec.file.handle, buffer, header_size );
    }

    /* Ecriture des données */
    last_index_i = index_i;
    while( in->index[last_index_i].track ) last_index_i ++;
    while( index_i < last_index_i )
    {
      offset = in->index[index_i].offset;
      /* offset = 280825L; */
      if( index_i > 0 && in->index[index_i].track != in->index[index_i - 1].track )
        track_offset = offset;

      entry = get_toc_entry( &in->toc, in->index[index_i].track, 0 );
      audio = !(desc( in->toc, entry ).adr_control & 4);
      end_offset = in->index[index_i + 1].offset;

      /* Boucle principale de lecturage */
      while( offset < end_offset )
      {
        if( yield() ) goto cancel;
        len = MIN( end_offset-offset, buf_len );
        ret = dao_pipe_read( in, offset, len, read_buf, audio );
        if( ret ) goto read_error;
        if( !timer_started ) time = timer();
        dao_pipe_transform( in, out, offset, len, in->index[index_i].blocksize,
                            read_buf, audio, in->index[index_i].track,
                            in->index[index_i].index, track_offset );
        ret = dao_pipe_write( out, offset, len, in->index[index_i].blocksize, read_buf );
        if( ret ) goto write_error;
        if( !timer_started )
        {
          time = timer() - time;
          if( time > MAX_WRITE_TIME || out->type == TST_FILE || lead_out_size > 0 )
          {
            progress_setinfo( get_string( "TXT_DAO_DATA" ) );
            progress_init_timer();
            progress_activate_cancel( 1 );
            timer_started = 1;
          }
        }
        offset += len;
        progress_setcount( offset + 150 );
      }
      index_i ++;
    }
    index_i ++;   /* On zappe l'index de longueur nulle */

    /* Ecriture du lead-out */
    if( out->type == TST_CD )
    {
      progress_setinfo( get_string( "TXT_DAO_CSESS" ) );
      progress_activate_cancel( 0 );

      entry = get_toc_entry( &in->toc, 0xa1, session );
      track = desc( in->toc, entry ).pmin;
      entry = get_toc_entry( &in->toc, track, session );
      mode = (desc( in->toc, entry ).adr_control & 0x04 ) ? 1 : 0;

      header_offset = offset;

      /* memset( read_buf, 0, (long)buf_len * 2352 ); */
      while( lead_out_size > 0 )
      {
        if( yield() ) goto cancel;
        len = MIN( buf_len, lead_out_size );

        create_raw_blocks( read_buf, offset, mode, (int)len );
        dao_pipe_transform( in, out, offset, len, 2352, read_buf, mode==0,
                            0xaa, 1, header_offset );
        ret = dao_pipe_write( out, offset, len, 2352, read_buf );
        if( ret ) goto write_error;
        lead_out_size -= (int)len;
        offset += len;
      }
      close_session();
      progress_activate_cancel( 1 );
    }

    session++;
  }
  ret = 0;
  goto ok;
open_session_error:
  ret = -1;
  goto ok;
cancel:
  if( out->type == TST_CD )
  {
    use_device( out->spec.cd.dev );
    close_session();
    /* rezero_unit(); */
  }
  ret = -2;
  goto ok;
read_error:
  ret = -3;
  goto ok;
write_error:
  if( out->type == TST_CD &&
     ( out->spec.cd.dev->sets->write_mode == WT_PHILIPS && dao_asc == 0xad
     || out->spec.cd.dev->sets->write_mode == WT_MMC
        && ( dao_asc == 0x0c && ( dao_ascq == 0x07 || dao_ascq == 0x0a )
             || dao_asc == 0x04 && dao_ascq == 0x08 )
     || out->spec.cd.dev->sets->write_mode == WT_TEAC && dao_asc == 0xba ) )
    ret = -5;
  else
    ret = -4;
ok:
  progress_exit();
  free_comm_buffer( buffer );
  return ret;
}

