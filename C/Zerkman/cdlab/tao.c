/*
 * TAO.C - Fonctions de gestion du mode TAO
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
#include "mmc.h"
#include "iso9660.h"
#include "tao.h"

#define BUFSIZE 0x40000L    /* Taille du buffer pour le gravage en TAO */

#define MIN(A,B) ((A)<(B)?(A):(B))

struct tao_track * tao_track_new( enum track_type type, int blocksize )
{
  struct tao_track * track;

  track = xmalloc( sizeof( *track ) );
  if( !track )
    return NULL;

  track->type = type;
  switch( type )
  {
    case ISO_FILE:
      track->spec.file.handle = -1;
      break;
    case AUDIO:
      track->spec.file.handle = -1;
      break;
  }
  track->blocksize = blocksize;

  return track;
}

/* Prépare une piste à la lecture */
int tao_track_open( struct tao_track * track )
{
  int handle;
  switch( track->type )
  {
    case ISO_FILE:
      handle = open( track->spec.file.name, O_RDONLY );
      if( handle < 0 ) return -1;
      track->spec.file.handle = handle;
      break;
  }
  return 0;
}

/* Ferme une piste qui a été ouverte */
void tao_track_close( struct tao_track * track )
{
  switch( track->type )
  {
    case ISO_FILE:
      close( track->spec.file.handle );
      break;
  }
}

void tao_track_dispose( struct tao_track * track )
{
  switch( track->type )
  {
    case ISO_FILE:
    case AUDIO:
      free( track->spec.file.name );
      break;
    case ISO_GEN:
      iso_delete( track->spec.ig.gen );
      break;
  }
  free( track );
}

struct tao_track * tao_track_new_ig( const char * path, int blocksize )
{
  IsoGenerator * ig;
  long blocks;
  struct tao_track * track;

  ig = iso_new( path, "ATARI", "VOLNAME", "VOLSET", "PUBLISHER",
      "PREPARER", "CDLAB", blocksize );
  if( !ig )
  {
    alert_msg( "AL_DIRERR", 1, path );
    return NULL;
  }
  blocks = iso_blocks( ig );

  track = tao_track_new( ISO_GEN, blocksize );
  if( !track )
    return NULL;

  track->spec.ig.gen = ig;
  track->blocks = blocks;
  return track;
}

struct tao_track * tao_track_new_iso( const char * filename, int blocksize )
{
  int handle;
  long blocks;
  struct tao_track * track;

  handle = open( filename, O_RDONLY );
  if( handle < 0 )
  {
    alert_msg( "AL_FILEERR", 1, filename );
    return NULL;
  }
  blocks = lseek( handle, 0, SEEK_END ) / blocksize;
  close( handle );

  track = tao_track_new( ISO_FILE, blocksize );
  if( !track )
    return NULL;

  track->spec.file.name = strdup( filename );
  track->spec.file.handle = -1;
  track->blocks = blocks;
  return track;
}

int tao_track_read( struct tao_track * track, void * read_buf, long nblocks )
{
  switch( track->type )
  {
    case ISO_FILE:
      if( read( track->spec.file.handle, read_buf,
                (size_t)nblocks * track->blocksize ) < 0 )
        return -1;
      break;
    case ISO_GEN:
      if( iso_read( track->spec.ig.gen, read_buf, nblocks ) )
        return -1;
      break;
    case AUDIO:
      break;
  }
  return 0;
}

int tao_write( struct tao_ostream *out, void * write_buf,
    long offset, long nblocks, int blocksize )
{
  int ret = 0;
  switch( out->type )
  {
    case TAO_CDR:
      use_device( out->t.cdr.dev );
      ret = write_to_cd( offset, (unsigned short)nblocks, write_buf );
      break;
    case TAO_FILE:
      ret = ( write( out->t.file.fd, write_buf, nblocks * blocksize ) ? 0 : -1 );
      break;
  }
  return ret;
}

/* fonction de gestion d'une session de gravage en mode TAO */
int tao_pipe( struct tao_track **in, int track_count, struct tao_ostream *out )
{
  int ret;
  int tno;
  int block_type;
  long offset, end_offset;
  int block_size;
  long buf_len, len;
  struct tao_track * src;
  void * buffer;

  if( out->type == TAO_CDR )
    use_device( out->t.cdr.dev );

  /*** A FAIRE : détection du Session format (CDDA, CDI, CD/XA) */
  /*** A FAIRE : détection du numéro de la première piste gravable */

  /* Allocation du buffer de mémoire */
  buffer = alloc_comm_buffer( BUFSIZE );

  /* Gravage de piste en piste */
  for( tno = 1; tno <= track_count; tno++ )
  {
    src = *in++;
    ret = tao_track_open( src );
    if( ret )
      goto error;

    /* WRITE PARAMETERS :
     * write type => track
     * set mode / control
     * set open next session bit pointer as appropriate
     * blocksize
     */
    block_size = src->blocksize;
    switch( src->type )
    {
      case ISO_FILE:
      case ISO_GEN:
        switch( block_size )
        {
          case 2048:
            block_type = 8;
            break;
          case 2324:
            block_type = 12;
            break;
          case 2332:
            block_type = 13;
            break;
          case 2336:
            block_type = 9;
            break;
        }
        break;
      case AUDIO:
        block_type = 0;
        break;
    }

    offset = 0;
    if( out->type == TAO_CDR )
    {
      ret = mmc_set_write_parameters( 1, 0, 4, block_type, 0x00, 0, 0, NULL, NULL, 0 );
      if( ret ) goto error;
      out->t.cdr.dev->BlockSize = block_size;
      /* READ TRACK INFO -> # of 1st data block */
      ret = mmc_read_track_information( scsi_buf, 1, tno, 28 );
      if( ret ) goto error;
      offset = *(long*)(scsi_buf+8);
    }
    end_offset = offset + src->blocks;
    buf_len = BUFSIZE / block_size;

    /* WRITE */
    while( offset < end_offset )
    {
      if( yield() ) goto cancel;
      len = end_offset - offset;
      if( len > buf_len )
        len = buf_len;
      ret = tao_track_read( src, buffer, len );
      if( ret ) goto error;
      ret = tao_write( out, buffer, offset, len, block_size );
      if( ret ) goto error;
      offset += len;
    }

    if( out->type == TAO_CDR )
    {
      /* SYNCHRONIZE CACHE */
      ret = synchronize_cache();
      /* ret = mmc_close_track_session( 0, 1, tno ); */
    }

    tao_track_close( src );
  }
  /* CLOSE SESSION */
  if( out->type == TAO_CDR )
  {
    ret = mmc_close_track_session( 0, 2, 0 );
    if( ret )
      goto error;
  }

cancel:
  ret = 2;
error:
  free_comm_buffer( buffer );
  return ret;
}

/* ouverture d'un flux d'écriture TAO */
struct tao_ostream * tao_open( struct device_info * info )
{
  struct device * dev;
  struct tao_ostream * stream;

  if( (dev = open_device( info->id, info->bus_no )) == NULL ) return NULL;
  use_device( dev );
  if( start_cd( ) < 0 || (stream = xmalloc( sizeof( *stream ))) == NULL )
  {
    alert_msg( "AL_CANTOPEN", 1, info->bus_no, info->id );
    close_device( dev );
    return NULL;
  }

  stream->type = TAO_CDR;
  stream->t.cdr.dev = dev;
  return stream;
}

/* ouverture d'un flux d'écriture dans un fichier (image ISO) */
struct tao_ostream * tao_open_file( const char * filename )
{
  struct tao_ostream * stream;
  int fd;

  fd = open( filename, O_WRONLY|O_CREAT|O_TRUNC, 0666 );
  if( fd < 0 )
    return NULL;
  if( (stream = xmalloc( sizeof( *stream ))) == NULL )
  {
    close( fd );
    return NULL;
  }

  stream->type = TAO_FILE;
  stream->t.file.fd = fd;
  return stream;
}

/* fermeture d'un flux d'écriture */
void tao_close( struct tao_ostream * stream )
{
  switch( stream->type )
  {
    case TAO_CDR:
      close_device( stream->t.cdr.dev );
      break;
    case TAO_FILE:
      close( stream->t.file.fd );
      break;
  }
  free( stream );
}

#if 0
#include "log.h"

/*** fonction de test à dégager */
void tao_test( struct device_info * info )
{
  struct tao_ostream * out;
  struct tao_track * in[1];

  log_begin();
  log_printf( "*** Begin of a TAO write session\n\n" );

  out = tao_open( info );
  /* in[0] = tao_track_new_iso( "g:\\test.iso", 2048 ); */
  in[0] = tao_track_new_ig( "G:\GLOUBA", 2048 );
  if( out && in[0] )
  {
    set_dummy_write( 0 );
    set_write_speed( 4 );
    tao_pipe( in, 1, out );
  }
  tao_track_dispose( in[0] );
  tao_close( out );

  log_printf( "*** End of the TAO write session\n\n" );
  log_end();
}

#endif
