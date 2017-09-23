#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <ctype.h>


#include "xfile.h"
#include "stdprog.h"


XFILE_OPTIONS Options ;


void SetXFileOptions(XFILE_OPTIONS *options)
{
 if ( options ) memcpy( &Options, options, sizeof(XFILE_OPTIONS) ) ;
}

int FileExist(char *file)
{
  FILE *stream ;
  int  exist = 1 ;

  stream = fopen( file, "rb" ) ;
  if ( stream == NULL ) exist = 0 ;
  else                  fclose( stream ) ;

  return( exist ) ;
}

int CopyFile(char *src, char *dst)
{
  GEM_WINDOW    *wprog = Options.wprog ;
  FILE          *sin, *sout ;
  unsigned long size_alloc = 64L * 1024L ;
  size_t        total_nb_read, nb_read, nb_written, size_src ;
  int           n = 0, pc, err = 0 ;
  char          buf[512] ;
  void          *pt_alloc = NULL ;

  if ( FileExist( dst ) )
  {
    if ( Options.manage_dst == MD_CANCELOPE ) return( EEXIST ) ;
  }

  size_src = file_size( src ) ;
  if ( size_src < 0 ) return( ENOENT ) ;
  sin  = fopen( src, "rb" ) ;
  if ( sin == NULL ) return( ENOENT ) ;

  sout = fopen( dst, "wb" ) ;
  if ( sout == NULL )
  {
    fclose( sin ) ;
    return( EINVAL ) ;
  }
	
  while ( ( pt_alloc == NULL ) && ( size_alloc >= 1024 ) )
  {
    pt_alloc = malloc( size_alloc ) ;
    if ( pt_alloc == NULL ) size_alloc >>= 1 ;
  }
  if ( size_alloc < 1024 )
  {
    pt_alloc   = buf ;
    size_alloc = sizeof(buf) ;
  }

  total_nb_read = 0 ;
  do
  {
    nb_read = fread( pt_alloc, 1, size_alloc, sin ) ;
    if ( nb_read > 0 )
    {
      nb_written = fwrite( pt_alloc, 1, nb_read, sout ) ;
      err        = ( nb_written != nb_read ) ;
    }

    total_nb_read += nb_read ;
    if ( wprog && ( ( ++n & 0x07 ) == 0x07 ) )
    {
      pc = (int) ( ( total_nb_read * 100L ) / size_src ) ;
      wprog->ProgPc( wprog, pc, NULL ) ;
    }
  }
  while ( !err && ( nb_read > 0 ) ) ;

  if ( err ) err = ENOSPC ;

  if ( size_alloc >= 1024 ) free( pt_alloc ) ;
  fclose( sout ) ;
  fclose( sin ) ;

  return( err ) ;
}

int MoveFile(char *src, char *dst)
{
  int err ;

  if ( tolower( src[0] ) == tolower( dst[0] ) ) err = rename( src, dst ) ;
  else
  {
    err = CopyFile( src, dst ) ;
    if ( !err ) err = unlink( src ) ;
  }

  return( err ) ;
}

int CreateFolder(char *path)
{
  int err ;

  err = Dcreate( path ) ;
  if ( err == -36 ) err = 0 ; /* Le repertoire existe deja */

  return( err ) ;
}

int CmpFiles(char *f1, char *f2)
{
#define RBLK_CMP 1024
  FILE   *s1, *s2 ;
  size_t l1, l2 ;
  size_t nb_read ;
  int    idem = 1 ;
  char   buf1[RBLK_CMP], buf2[RBLK_CMP] ;

  if ( strcmpi( f1, f2 ) == 0 ) return( 1 ) ;

  l1 = file_size( f1 ) ;
  l2 = file_size( f2 ) ;
  if ( l1 != l2 ) return( 0 ) ;

  s1 = fopen( f1, "rb" ) ;
  if ( s1 == NULL ) return( 0 ) ;
  s2 = fopen( f2, "rb" ) ;
  if ( s2 == NULL )
  {
    fclose( s1 ) ;
    return( 0 ) ;
  }

  if ( l1 == l2 )
  {
    do
    {
      nb_read = fread( buf1, 1, RBLK_CMP, s1 ) ;
      nb_read = fread( buf2, 1, nb_read, s2 ) ;
      idem    = ( memcmp( buf1, buf2, nb_read ) == 0 ) ;
    }
    while ( idem && ( nb_read > 0 ) ) ;    
  }
  else idem = 0 ;

  fclose( s2 ) ;
  fclose( s1 ) ;

  return( idem ) ;
}

