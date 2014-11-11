/*
 * AUDIO.C - Fonctions d'interfaçage avec les données audio
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

#include "device.h"
#include "misc.h"
#include "common.h"
#include "dao.h"
#include "prefs.h"
#include "audio.h"

/*
 * Positionnement dans un flux audio
 */
long audio_pos( struct audio_stream * in, long pos )
{
  if( in->type == AST_DAO )
    in->spec.dao.position = pos;
  return pos;
}

/*
 * Lecture dans un flux audio
 */
long audio_read( struct audio_stream * in, void * buffer, long nblocks )
{
  int ret;
  long size;
  size = (nblocks<in->block_count) ? nblocks : in->block_count;
  in->block_count -= size;
  if( in->type == AST_DAO )
  {
    ret = dao_pipe_read( in->spec.dao.stream, in->spec.dao.position, size, buffer, 1 );
    if( ret )
    {
      alert_msg( "AL_COPYREADERR", 1 );
      size = 0;
    }
    in->spec.dao.position += size;
  }
  return size;
}


/*
 * Ouverture d'une piste d'un fichier DAO
 */
struct audio_stream * audio_open_dao( char * filename, int track_no,
                                      long zap_beg, long zap_end )
{
  long position, fin;
  struct audio_stream * out;
  out = xmalloc( sizeof( struct audio_stream ) );
  if( !out ) goto error;

  out->type = AST_DAO;
  out->spec.dao.stream = idao_open_file( filename );
  if( !out->spec.dao.stream ) goto openerror;

  position = get_track_offset( &out->spec.dao.stream->toc, track_no, &fin ) + zap_beg;
  out->spec.dao.position = position;
  out->block_count = fin - position - zap_end;
  if( out->block_count < 0 )
    out->block_count = 0;
  lseek( out->spec.dao.stream->spec.file.handle, position * 2352, SEEK_CUR );
  out->little_endian = out->spec.dao.stream->flags.audio_little_endian;

  return out;
/*zaperror:
  idao_close( out->spec.dao.stream );*/
openerror:
  free( out );
error:
  return NULL;
}


/*
 * Ouverture d'une piste d'un CD
 */
struct audio_stream * audio_open_cd( struct device_info * info, int track_no,
                                     long zap_beg, long zap_end )
{
  long position, fin;
  struct audio_stream * out;

  out = xmalloc( sizeof( struct audio_stream ) );
  if( !out ) goto error;
  out->type = AST_DAO;
  out->spec.dao.stream = idao_open_cd( info );
  if( !out->spec.dao.stream ) goto openerror;
  if( autodetect_audiomode( &out->spec.dao.stream->toc ) )
  {
    alert_msg( "AL_NOREADDA", 1 );
    goto zaperror;
  }
  if( preferences.pref_flags.eject_src )
    out->spec.dao.stream->spec.cd.flags |= CDFLG_EJECT;
  position = get_track_offset( &out->spec.dao.stream->toc, track_no, &fin ) + zap_beg;
  out->spec.dao.position = position;
  out->block_count = fin - position - zap_end;
  if( out->block_count < 0 )
    out->block_count = 0;
  out->little_endian = out->spec.dao.stream->flags.audio_little_endian;

  return out;
zaperror:
  idao_close( out->spec.dao.stream );
openerror:
  free( out );
error:
  return NULL;
}


/*
 * Ouverture, d'une entrée audio
 */
struct audio_stream * audio_open( struct audio_entry * entry )
{
  struct audio_stream * ret;
  switch( entry->type )
  {
    case AET_FILE:
      ret = NULL;
      break;
    case AET_DAOIMG:
      ret = audio_open_dao( entry->spec.daoimg.filename, entry->spec.daoimg.track_no,
                            entry->zap_beg, entry->zap_end );
      break;
    case AET_CD:
      ret = audio_open_cd( entry->spec.cd.info, entry->spec.cd.track_no,
                           entry->zap_beg, entry->zap_end );
      break;
  }
  return ret;
}

/*
 * Réouverture d'un flux audio
 */
struct audio_stream * audio_reopen( struct audio_stream *in, struct audio_entry * entry )
{
  long position, fin;
  int track_no;
  if( in->type == AST_DAO )
  {
    track_no = (entry->type == AET_DAOIMG) ? entry->spec.daoimg.track_no
                                           : entry->spec.cd.track_no;
    position = get_track_offset( &in->spec.dao.stream->toc, track_no, &fin ) + entry->zap_beg;
    in->spec.dao.position = position;
    in->block_count = fin - position - entry->zap_end;
    if( in->block_count < 0 )
      in->block_count = 0;
  }
  return in;
}


/*
 * Fermeture d'un flux audio
 */
int audio_close( struct audio_stream * stream )
{
  if( !stream ) return -1;
  if( stream->type == AST_DAO )
  {
    idao_close( stream->spec.dao.stream );
  }
  free( stream );
  return 0;
}


/*
 * Détermination du nombre de blocs dans une entrée audio
 */
long audio_block_count( struct audio_entry * entry )
{
  long ret;
  struct audio_stream * stream;
  stream = audio_open( entry );
  if( stream )
  {
    ret = stream->block_count;
    audio_close( stream );
  }
  else
    ret = -1;
  return ret;
}


/*
 * Génération de la TOC d'un CD à partir des infos audio
 */
int audio_gen_toc( struct ext_toc * toc, struct audio_entry * entry, int entry_count )
{
  int i, ret, m, s, f;
  long count, total;
  struct track_desc * dsc;

  toc->head.first_track = 1;
  toc->head.last_track = 1;
  toc->head.toc_len = entry_count + 3;
  memset( toc->desc, 0, toc->head.toc_len * 11 );
  desc( *toc, 0 ).session = 1;
  desc( *toc, 0 ).adr_control = 0x10;
  desc( *toc, 0 ).point = 0xA0;
  desc( *toc, 0 ).pmin = 1;
  desc( *toc, 1 ).session = 1;
  desc( *toc, 1 ).adr_control = 0x10;
  desc( *toc, 1 ).point = 0xA1;
  desc( *toc, 1 ).pmin = entry_count;
  desc( *toc, 2 ).session = 1;
  desc( *toc, 2 ).adr_control = 0x10;
  desc( *toc, 2 ).point = 0xA2;

  ret = 0;
  total = 0;
  for( i=0; i<entry_count; i++ )
  {
    dsc = &desc( *toc, i + 3 );
    dsc->session = 1;
    dsc->adr_control = 0x10;
    dsc->point = i + 1;
    count = audio_block_count( entry + i );
    if( count < 0 ) ret = -1;
    msf( total, &m, &s, &f );
    dsc->pmin = m;
    dsc->psec = s;
    dsc->pframe = f;
    total += count;
  }

  msf( total, &m, &s, &f );
  desc( *toc, 2 ).pmin = m;
  desc( *toc, 2 ).psec = s;
  desc( *toc, 2 ).pframe = f;

  return ret;
}


/*
 * Génération d'une entrée audio de type fichier image DAO
 */
int gen_daoimg_entry( struct audio_entry * entry, char * filename, int track_no,
                      long zap_beg, long zap_end )
{
  entry->type = AET_DAOIMG;
  entry->zap_beg = zap_beg;
  entry->zap_end = zap_end;
  strcpy( entry->spec.daoimg.filename, filename );
  entry->spec.daoimg.track_no = track_no;
  return 0;
}


/*
 * Génération d'une entrée audio de type piste CD
 */
int gen_cd_entry( struct audio_entry * entry, struct device_info * info,
                  int track_no, long zap_beg, long zap_end )
{
  entry->type = AET_CD;
  entry->zap_beg = zap_beg;
  entry->zap_end = zap_end;
  entry->spec.cd.info = info;
  entry->spec.cd.track_no = track_no;
  return 0;
}


#if 0
void audio_test( struct device_info * dev )
{
  int ret;
  char txt[80];
  struct audio_entry * entry;
  struct idao_stream * in;
  struct odao_stream * out;

  entry = xmalloc( sizeof( struct audio_entry ) * 256 );
  if( !entry ) return;

  gen_daoimg_entry( entry + 0, "g:\\explicit.cd", 1, 0, 344 );
  gen_daoimg_entry( entry + 1, "g:\\explicit.cd", 3, 0, 4494 );
  gen_daoimg_entry( entry + 2, "g:\\explicit.cd", 4, 0, 0 );
  gen_daoimg_entry( entry + 3, "g:\\explicit.cd", 3, 13950, 0 );
  gen_daoimg_entry( entry + 4, "g:\\explicit.cd", 2, 150, 0 );
  gen_daoimg_entry( entry + 5, "g:\\explicit.cd", 5, 0, 0 );
  gen_daoimg_entry( entry + 6, "g:\\explicit.cd", 6, 0, 0 );

  in = idao_open_audio( entry, 7 );
  /* out = odao_open_file( "g:\\essai.cd" ); */

  out = odao_open_cd( dev );
  use_device( out->spec.cd.dev );
  set_dummy_write( 0 );
  set_write_speed( 4 );

  ret = dao_pipe( "TXT_COPY", in, out );

  odao_close( out );
  idao_close( in );

  sprintf( txt, "[1][Code retour : %d][Ok]", ret );
  form_alert( 1, txt );

  free( entry );
}
#endif
