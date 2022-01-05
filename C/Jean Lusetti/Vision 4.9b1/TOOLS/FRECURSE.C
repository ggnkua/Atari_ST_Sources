/********************************/
/* Recurse parsing into folders */
/********************************/
#include    <tos.h>
#include    <ext.h>
#include  <stdio.h>
#include  <ctype.h>
#include <string.h>

#include  "logging.h"
#include "frecurse.h"
#include "xmem.h" /* For memzero */

#define ERR_CODE(x) ( ( (x) & 0xFF000000L ) == 0xFF000000L )

typedef struct __IFR_DATA
{
  FR_DATA  Data ;
  FR_CDATA CData ;
  FILE*    sLog ;
  short    Stop ;
}
IFR_DATA, *PIFR_DATA ;


static short name_in_mask(char *fname, char *mask)
{
  short in_mask = 1 ;

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

  return in_mask ;
}

short file_in_mask(char *fname, char *mask)
{
  short in_mask ;
  char* pdot1, *pdot2 ;
  char* pob, *pcb ;
  char  keyword[64] ;

  /* First see if it is about identifying keyword */
  /* Keyword is between [ and ]                   */
  pob = strchr( mask, '[' ) ;
  if ( pob )
  {
    pcb = strchr( 1+pob, ']' ) ;
    if ( pcb )
    {
      /* Keyword is to be searched */
      char lfname[PATH_MAX] ;

      *pcb = 0 ;
      strcpy( keyword, 1+pob ) ;
      *pcb = ']' ;
      strlwr( keyword ) ;
      strcpy( lfname, fname ) ;
      strlwr( lfname ) ; /* Will operate on lower cases */
      if ( strstr( lfname, keyword ) )
        return 1 ;
      return 0 ; /* No keyword found */
    }
  }

  pdot1 = strrchr( fname, '.' ) ;
  pdot2 = strrchr( mask, '.' ) ;

  if ( ( pdot1 && ( pdot2 == NULL ) ) || ( pdot2 && ( pdot1 == NULL ) ) ) return( 0 ) ;
  if ( pdot1 ) *pdot1 = *pdot2 = 0 ;

  in_mask = name_in_mask( fname, mask ) ;
  if ( in_mask && pdot1 ) in_mask = name_in_mask( 1 + pdot1, 1 + pdot2 ) ;

  if ( pdot1 ) *pdot1 = *pdot2 = '.' ;

  return in_mask ;
}

static short nested_dirs(char* d1, char* d2)
{
  char* d ;
  short stop = 0 ;

  do
  {
    if ( *d1 != *d2 ) return 0 ;
    d1++; if ( *d1 == 0 ) stop = 1 ;
    d2++; if ( *d2 == 0 ) stop = 1 ;
    if ( (*d1 == 0) && (*d2 == 0) ) return 1 ;
  }
  while ( !stop ) ;

  /* Here either *d1 is 0 or *d2 is 0, but not both  */
  /* Typical cases: I:\2006\May2006                  */
  /*                           d1->|                 */
  /* (not nested)   I:\2006\Mai2006\Corse            */
  /*                           d2->|                 */
  /* (not nested)   I:\2006\May2006.tmp              */
  /* (nested)       I:\2006\May2006\.                */
  /* (nested)       I:\2006\May2006\..               */
  if ( *d1 == 0 ) d = d2 ;
  else            d = d1 ;
  if ( *d == '\\')
  {
    d++ ;
    if ( *d == '.' )
    {
      d++ ;
      if ( *d == 0 ) return 1 ;   /* folder .  */
      if ( *d == '.' ) return 1 ; /* folder .. */
    }
  }

  return 0 ;
}

static short IFR_Callback(IFR_DATA* ifrData)
{
  ifrData->CData.nfiles++ ;
  if ( ifrData->sLog )
    fprintf( ifrData->sLog, "%s\r\n", ifrData->CData.filename ) ;

  if ( ifrData->Data.user_func )
    ifrData->Stop = ifrData->Data.user_func( &ifrData->CData ) ;

  if ( ifrData->Stop )
    LoggingDo(LL_INFO, "IFR_Callback stopped by user" ) ;

  return ifrData->Stop ;
}

static void XATTR2CDATA(XATTR* xattr, FR_CDATA* cdata)
{
  cdata->size = (unsigned long) xattr->size ;
  cdata->date = xattr->mdate ;
  cdata->time = xattr->mtime ;
}

static void LNfind_files(IFR_DATA* ifrData)
{
  long handle, hdir2 ;
  char fname[PATH_MAX] ;
  char out_name[PATH_MAX] ;

  if ( ifrData->Stop ) return ;

  handle = Dopendir( ifrData->Data.path, 0 ) ;
  if ( ERR_CODE( handle ) ) return ;

  while ( !ifrData->Stop && (Dreaddir( PATH_MAX, handle, fname ) == 0) )
  {
    sprintf( out_name, "%s\\%s", ifrData->Data.path, 4 + fname ) ;
    hdir2 = Dopendir( out_name, 0 ) ;
    if ( ERR_CODE( hdir2 ) )
    {
      if ( file_in_mask( 4 + fname, ifrData->Data.mask ) )
      {
        XATTR xattr ;
        long  status = 0 ;

        ifrData->CData.filename  = out_name ;
        if ( (ifrData->Data.flags & FFR_NOLONGNAMESDETAILS) == 0 ) status = Fxattr( 0, out_name, &xattr ) ;
        else                                                       memzero( &xattr, sizeof(XATTR) ) ;
        if ( status == 0 )
        {
          XATTR2CDATA( &xattr, &ifrData->CData ) ;
          ifrData->CData.user_data = ifrData->Data.user_data ;
          IFR_Callback( ifrData ) ;
        }
        else LoggingDo(LL_WARNING, "Fxattr returned %ld for %s", status, out_name);
      }
    }
    else Dclosedir( hdir2 ) ;
  }

  Dclosedir( handle ) ;
}

static void LNfolder_recurse(IFR_DATA* ifrData)
{
  long handle, hdir2 ;
  char fname[PATH_MAX] ;
  char out_name[PATH_MAX] ;

  if ( ifrData->Stop ) return ;

  LoggingDo(LL_DEBUG, "Opening %s", ifrData->Data.path);
  handle = Dopendir( ifrData->Data.path, 0 ) ;
  if ( !ERR_CODE( handle ) )
  {
    while ( !ifrData->Stop && (Dreaddir( PATH_MAX, handle, fname ) == 0) )
    {
      sprintf( out_name, "%s\\%s", ifrData->Data.path, 4 + fname ) ;
      LoggingDo(LL_DEBUG, "Opening %s", out_name);
      hdir2 = Dopendir( out_name, 0 ) ;
      if ( ERR_CODE( hdir2 ) )
      {
        /* out_name is a file */
        if ( file_in_mask( 4 + fname, ifrData->Data.mask ) )
        {
          XATTR xattr ;
          long  status = 0 ;

          LoggingDo(LL_DEBUG, "%s is a file in_mask", out_name);
          ifrData->CData.filename  = out_name ;
          if ( (ifrData->Data.flags & FFR_NOLONGNAMESDETAILS) == 0 ) status = Fxattr( 0, out_name, &xattr ) ;
          else                                                       memzero( &xattr, sizeof(XATTR) ) ;
          if ( status == 0 )
          {
            XATTR2CDATA( &xattr, &ifrData->CData ) ;
            ifrData->CData.user_data = ifrData->Data.user_data ;
            IFR_Callback( ifrData ) ;
          }
          else LoggingDo(LL_WARNING, "Fxattr returned %ld for %s", status, out_name);
        }
        else LoggingDo(LL_DEBUG, "%s is a file NOT in_mask %s", out_name, ifrData->Data.mask);
      }
      else
      {
        Dclosedir( hdir2 ) ;
        if ( !nested_dirs( ifrData->Data.path, out_name ) ) /* Some OSes report ./ which leads to infinite recursion... */
        {
          char* opath = ifrData->Data.path ;

          LoggingDo(LL_DEBUG, "%s and %s are NOT nested", ifrData->Data.path, out_name);
          ifrData->Data.path = out_name ;
          LNfolder_recurse( ifrData ) ;
          ifrData->Data.path = opath ;
        }
        else LoggingDo(LL_DEBUG, "%s and %s are nested", ifrData->Data.path, out_name);
      }
    }
  }
  else LoggingDo(LL_ERROR, "Dopendir: error %ld on %s", handle, ifrData->Data.path);

  Dclosedir( handle ) ;
}

static void DTA2CDATA(DTA* dta, FR_CDATA* cdata)
{
  cdata->size = dta->d_length ;
  cdata->date = dta->d_date ;
  cdata->time = dta->d_time ;
}

static void SNfind_files(IFR_DATA* ifrData, short attrib)
{
  DTA*  old_dta, dta ;
  short ret ;
  char  name[PATH_MAX] ;

  if ( ifrData->Stop ) return ;

  old_dta = Fgetdta() ;
  Fsetdta( &dta ) ;
  sprintf( name, "%s\\%s", ifrData->Data.path, ifrData->Data.mask ) ;
  ret = Fsfirst( name, attrib ) ;
  while ( !ifrData->Stop && (ret == 0) )
  {
    sprintf( name, "%s\\%s", ifrData->Data.path, dta.d_fname ) ;
    ifrData->CData.filename  = name ;
    DTA2CDATA( &dta, &ifrData->CData ) ;
    ifrData->CData.user_data = ifrData->Data.user_data ;
    IFR_Callback( ifrData ) ;
    Fsetdta( &dta ) ;
    ret = Fsnext() ;
  }
  Fsetdta( old_dta ) ;
}

static void SNfolder_recurse(IFR_DATA* ifrData, short attrib)
{
  DTA*  old_dta, dta ;
  short ret ;
  char  mask[PATH_MAX] ;

  if ( ifrData->Stop ) return ;
  
  old_dta = Fgetdta() ;
  Fsetdta( &dta ) ;
  sprintf( mask, "%s\\*.*", ifrData->Data.path ) ;
  ret = Fsfirst( mask, attrib ) ;
  while ( !ifrData->Stop && (ret == 0 ) )
  {
    if ( dta.d_fname[0] != '.' )
    {
      sprintf( mask, "%s\\%s", ifrData->Data.path, dta.d_fname) ;
      if ( dta.d_attrib & FA_SUBDIR )
      {
        char* opath = ifrData->Data.path ;

        ifrData->Data.path = mask ;
        SNfolder_recurse( ifrData, attrib ) ;
        ifrData->Data.path = opath ;
      }
      else if ( file_in_mask( dta.d_fname, ifrData->Data.mask ) )
      {
        ifrData->CData.filename  = mask ;
        DTA2CDATA( &dta, &ifrData->CData ) ;
        ifrData->CData.user_data = ifrData->Data.user_data ;
        IFR_Callback( ifrData ) ;
      }
    }
    ret = Fsnext() ;
  }
  Fsetdta( old_dta ) ;
}

static void ifind_files(IFR_DATA* ifrData)
{
  if ( ifrData->Data.flags & FFR_LONGNAMES ) LNfind_files( ifrData ) ;
  else                                       SNfind_files( ifrData, FA_READONLY | FA_ARCHIVE ) ;
}

static void ifolder_recurse(IFR_DATA* ifrData)
{
  if ( ifrData->Data.flags & FFR_LONGNAMES ) LNfolder_recurse( ifrData ) ;
  else                                       SNfolder_recurse( ifrData, FA_READONLY | FA_ARCHIVE | FA_SUBDIR ) ;
}

static void initIFRData(IFR_DATA* ifrData, FR_DATA* frData)
{
  memzero( ifrData, sizeof(IFR_DATA) ) ;
  memcpy( &ifrData->Data, frData, sizeof(FR_DATA) ) ;
  if ( frData->log_file && frData->log_file[0] )
    ifrData->sLog = fopen( frData->log_file, "a+b" ) ;
}

void find_files(FR_DATA* frData)
{
  IFR_DATA ifr_data ;

  initIFRData( &ifr_data, frData ) ;

  ifind_files( &ifr_data ) ;

  if ( ifr_data.sLog )
    fclose( ifr_data.sLog ) ;
}

void folder_recurse(FR_DATA* frData)
{
  IFR_DATA ifr_data ;

  initIFRData( &ifr_data, frData ) ;

  ifolder_recurse( &ifr_data ) ;

  if ( ifr_data.sLog )
    fclose( ifr_data.sLog ) ;
}

long count_files(short recurse, FR_DATA* fr_data)
{
  IFR_DATA ifr_data ;

  initIFRData( &ifr_data, fr_data ) ;

  if ( recurse ) ifolder_recurse( &ifr_data ) ;
  else           ifind_files( &ifr_data ) ;

  if ( ifr_data.sLog ) fclose( ifr_data.sLog ) ;

  return ifr_data.CData.nfiles ;
}
