#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <ctype.h>
#include <tos.h>

#include "xfile.h"
#include "stdprog.h"
#include "logging.h"


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
  int           err = 0 ;
  char          buf[512] ;
  void          *pt_alloc = NULL ;

  if ( FileExist( dst ) )
  {
    if ( Options.manage_dst == MD_CANCELOPE ) return( EEXIST ) ;
  }

  size_src = file_size( src ) ;
  sin      = fopen( src, "rb" ) ;
  if ( sin == NULL ) return( ENOENT ) ;

  sout = fopen( dst, "wb" ) ;
  if ( sout == NULL )
  {
    fclose( sin ) ;
    return( EINVAL ) ;
  }
	
  while ( ( pt_alloc == NULL ) && ( size_alloc >= 1024 ) )
  {
    pt_alloc = Xalloc( size_alloc ) ;
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
    (void)GWProgRange( wprog, total_nb_read, size_src, NULL ) ;
  }
  while ( !err && ( nb_read > 0 ) ) ;

  if ( err ) err = ENOSPC ;

  if ( size_alloc >= 1024 ) Xfree( pt_alloc ) ;
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

int FolderExist(char* folder) /* Idea: G.Tello as we can't rely Fattrib on old TOSes */
{
  DTA    dta ;
  DTA*   old_dta ;
  char   bname[PATH_MAX] ;
  size_t folder_len = strlen(folder) ;
  int    folder_exists ;

  if ( folder[folder_len-1] != '\\' ) sprintf( bname, "%s\\*.*", folder ) ;
  else                                sprintf( bname, "%s*.*", folder ) ;
  old_dta = Fgetdta() ;
  Fsetdta( &dta ) ;

  folder_exists = ( Fsfirst( bname, -1 ) == 0 ) ;
  /* Some TOSes may fail here if folder is empty */
  /* Let's create a temporary file then          */
  if ( !folder_exists )
  {
    FILE* tmp_file ;

    LoggingDo(LL_DEBUG, "Folder %s looks non existing, trying to create a file under it to make sure...", folder) ;
    if ( folder[folder_len-1] != '\\' ) sprintf( bname, "%s\\tmp", folder ) ;
    else                                sprintf( bname, "%stmp", folder ) ;
    tmp_file = fopen( bname, "w" ) ;
    if ( tmp_file )
    {
      fclose( tmp_file ) ;
      unlink( bname ) ;
      folder_exists = 1 ;
    }
  }
  LoggingDo(LL_DEBUG, "FolderExist(%s)=%d", folder, folder_exists) ;

  Fsetdta( old_dta ) ;

  return folder_exists ;
}

long FileTxtStats(char* filename, long *nbytes)
{
  FILE* stream = fopen( filename, "rb" ) ;
  char  s[1024] ;
  long  nstrings = 0 ;

  *nbytes = 0 ;
  if ( stream )
  {
    while ( fgets( s, (int)sizeof(s), stream ) )
    {
      nstrings++ ;
      *nbytes += 1+strlen(s) ;
    }
    fclose( stream ) ;
  }
  else nstrings = -1 ;

  return nstrings ;
}
