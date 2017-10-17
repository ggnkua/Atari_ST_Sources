/*
 * misc.c - fonctions de gestion spécifiques au système
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
/*
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
*/

#include "iso9660.h"
#include "misc.h"

/*
 * gestionnaire de mémoire avancé
 */
void * xmalloc( size_t size )
{
  void * p = malloc( size );
  if( !p )
  {
    perror( "xmalloc" );
    abort();
  }
  memset( p, 0, size );
  return p;
}

void * xrealloc( void * ptr, size_t size )
{
  void * p = realloc( ptr, size );
  if( !p )
  {
    perror( "xrealloc" );
    abort();
  }
  return p;
}

/*
void print_direntry( const char * prefix, IsoGenerator * gen,
    struct dir_entry * di, long count, int level )
{
  char buf[ NAME_MAX + 1 ];
  int i;
  struct dir_entry *current, *sub;
  const char * str = gen->string_buf;
  current = di;
  for( i = 0; i < count; i++ )
  {
    sprintf( buf, "%s/%s", prefix, str + current->name );
    printf( "%-46s %-12s %8ld %3ld\n", buf, str + current->iso_name,
        current->attr.size, current->blocks );
    if( current->attr.type == 'd' )
    {
      sub = (struct dir_entry *)((char*)gen->entries[level+1] + current->sub);
      print_direntry( buf, gen, sub, current->count, level+1 );
    }
    current ++;
  }
}
*/


#define BUF_SIZE 128
#define BLOCKSIZE 2048
int main( int argc, char ** argv )
{
  char * buf;
  IsoGenerator * ig;
  long size, segment_size;
  int fd;

  buf = xmalloc( (long)BUF_SIZE * BLOCKSIZE );
/*  if( argc != 2 )
  {
    fprintf( stderr, "usage : %s pathname\n", argv[0] );
    return 1;
  }*/
  ig = iso_new( "d:", "ATARI", "VOLNAME", "VOLSET", "PUBLISHER",
      "PREPARER", "CDLAB", BLOCKSIZE );
  if( !ig )
  {
    fprintf( stderr, "%s: profondeur de répertoire supérieure à 8\n",
        argv[0] );
    return 1;
  }
  size = iso_blocks( ig );
  printf( "size = %ld\n", size );
  fd = open( "G:\\test.iso", O_WRONLY|O_CREAT|O_TRUNC, 0666 );
  while( size )
  {
    segment_size = (( size > BUF_SIZE ) ? BUF_SIZE : size );
    iso_read( ig, buf, segment_size );
    write( fd, buf, segment_size * BLOCKSIZE );
    size -= segment_size;
  }
  close( fd );

  iso_delete( ig );
  free( buf );

  return 0;
}
