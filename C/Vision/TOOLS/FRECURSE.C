/******************************************/
/* D‚placement r‚cursif dans les dossiers */
/******************************************/
#include    <tos.h>
#include    <ext.h>
#include  <stdio.h>
#include  <ctype.h>
#include <string.h>

#define ERR_CODE(x) ( ( (x) & 0xFF000000L ) == 0xFF000000L )
static FILE *stream ;

int name_in_mask(char *fname, char *mask)
{
  int  in_mask = 1 ;

  while ( *fname && *mask && in_mask )
  {
    switch( *mask )
    {
      case '?' : fname++ ;
                 mask++ ;
                 break ;

      case '*' : fname++ ;
                 break ;

      default  : if ( tolower(*fname) != tolower(*mask) ) in_mask = 0 ;
                 else
                 {
                   fname++ ;
                   mask++ ;
                 }
                 break ;
      }
    }

  if ( in_mask && ( *mask != '*' ) && ( *fname == 0 ) ) in_mask = ( *mask == 0 ) ;
  if ( in_mask && ( *mask == 0 ) ) in_mask = ( *fname == 0 ) ;

  return( in_mask ) ;
}

int file_in_mask(char *fname, char *mask)
{
  int  in_mask ;
  char *pdot1, *pdot2 ;

  pdot1 = strrchr( fname, '.' ) ;
  pdot2 = strrchr( mask, '.' ) ;

  if ( ( pdot1 && ( pdot2 == NULL ) ) || ( pdot2 && ( pdot1 == NULL ) ) ) return( 0 ) ;
  if ( pdot1 ) *pdot1 = *pdot2 = 0 ;

  in_mask = name_in_mask( fname, mask ) ;
  if ( in_mask && pdot1 ) in_mask = name_in_mask( 1 + pdot1, 1 + pdot2 ) ;

  if ( pdot1 ) *pdot1 = *pdot2 = '.' ;

  return( in_mask ) ;
}

void LNfind_files(char *path, char *mask, void (*user_func)(char *new_path, DTA *dta, void *user_data), void *user_data)
{
  long handle, hdir2 ;
  char fname[PATH_MAX] ;
  char out_name[PATH_MAX] ;

  handle = Dopendir( path, 0 ) ;
  if ( ERR_CODE( handle ) ) return ;

  while ( Dreaddir( PATH_MAX, handle, fname ) == 0 )
  {
    sprintf( out_name, "%s\\%s", path, 4 + fname ) ;
    hdir2 = Dopendir( out_name, 0 ) ;
    if ( ERR_CODE( hdir2 ) )
    {
      if ( file_in_mask( 4 + fname, mask ) ) user_func( out_name, NULL, user_data ) ;
    }
    else Dclosedir( hdir2 ) ;
  }

  Dclosedir( handle ) ;
}

void LNfolder_recurse(char *path, char *file_mask, void (*user_func)(char *new_path, DTA *dta, void *user_data), void *user_data)
{
  long handle, hdir2 ;
  char fname[PATH_MAX] ;
  char out_name[PATH_MAX] ;

  handle = Dopendir( path, 0 ) ;
  if ( !ERR_CODE( handle ) )
  {
    while ( Dreaddir( PATH_MAX, handle, fname ) == 0 )
    {
      sprintf( out_name, "%s\\%s", path, 4 + fname ) ;
      hdir2 = Dopendir( out_name, 0 ) ;
      if ( ERR_CODE( hdir2 ) )
      {
        /* out_name est un fichier */
        if ( file_in_mask( 4 + fname, file_mask ) ) user_func( out_name, NULL, user_data ) ;
      }
      else
      {
        Dclosedir( hdir2 ) ;
        LNfolder_recurse( out_name, file_mask, user_func, user_data ) ;
      }
    }
  }

  Dclosedir( handle ) ;
}

void SNfind_files(char *path, char *mask, int attrib, void (*user_func)(char *new_path, DTA *dta, void *user_data), void *user_data)
{
  DTA  *old_dta, dta ;
  int  ret ;
  char name[PATH_MAX] ;

  old_dta = Fgetdta() ;
  Fsetdta( &dta ) ;
  sprintf( name, "%s\\%s", path, mask ) ;
  ret = Fsfirst( name, attrib ) ;
  while ( ret == 0 )
  {
    sprintf( name, "%s\\%s", path, dta.d_fname ) ;
    if ( stream ) fprintf( stream, "%s\\%s\r\n", path, dta.d_fname ) ;
    user_func( name, &dta, user_data ) ;
    Fsetdta( &dta ) ;
    ret = Fsnext() ;
  }
  Fsetdta( old_dta ) ;
}

void SNfolder_recurse(char *path, char *file_mask, int attrib, void (*user_func)(char *new_path, DTA *dta, void *user_data), void *user_data)
{
  DTA  *old_dta, dta ;
  int  ret ;
  char mask[PATH_MAX] ;

  old_dta = Fgetdta() ;
  Fsetdta( &dta ) ;
  sprintf( mask, "%s\\*.*", path ) ;
  ret = Fsfirst( mask, attrib ) ;
  while ( ret == 0 )
  {
    if ( dta.d_fname[0] != '.' )
    {
      sprintf( mask, "%s\\%s", path, dta.d_fname) ;
      if ( dta.d_attrib & FA_SUBDIR )
        SNfolder_recurse( mask, file_mask, attrib, user_func, user_data ) ;
      else if ( file_in_mask( dta.d_fname, file_mask ) )
      {
        if ( stream ) fprintf( stream, "%s\\%s\r\n", path, dta.d_fname ) ;
        user_func( mask, &dta, user_data ) ;
      }
    }
    ret = Fsnext() ;
  }
  Fsetdta( old_dta ) ;
}

void find_files(int long_names, char *path, char *mask, void (*user_func)(char *new_path, DTA *dta, void *user_data), void *user_data)
{
  if ( long_names ) LNfind_files( path, mask, user_func, user_data ) ;
  else              SNfind_files( path, mask, FA_READONLY | FA_ARCHIVE, user_func, user_data ) ;
}

void folder_recurse(int long_names, char *path, char *mask, void (*user_func)(char *filename, DTA *dta, void *user_data), void *user_data, char *logfile)
{
  if ( logfile && logfile[0] ) stream = fopen( logfile, "a+b" ) ;
  if ( long_names ) LNfolder_recurse( path, mask, user_func, user_data ) ;
  else              SNfolder_recurse( path, mask, FA_READONLY | FA_ARCHIVE | FA_SUBDIR, user_func, user_data ) ;
  if ( stream ) fclose( stream ) ;
  stream = NULL ;
}

#pragma warn -par
void fnb_files(char *file, DTA *dta, void *user_data)
{
  long *nb_files = (long *) user_data ;

  (*nb_files)++ ;
}
#pragma warn +par

long count_files(char *path, char *file_mask, int recurse, char *log_file)
{
  long nb_files = 0 ;

  if ( recurse ) folder_recurse( 0, path, file_mask, fnb_files, &nb_files, log_file ) ;
  else           find_files( 0, path, file_mask, fnb_files, &nb_files ) ;

  return( nb_files ) ;
}
