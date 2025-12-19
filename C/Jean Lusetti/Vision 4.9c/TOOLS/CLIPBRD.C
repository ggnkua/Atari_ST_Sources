/******************************/
/* Gestion du Clipboard       */
/* (c) LUSETTI Jean A“ut 1993 */
/******************************/
#include    <tos.h>
#include   "xaes.h"
#include <string.h>
#include <stddef.h>
#include "xmem.h" /* For memzero */


int clbd_create(char* path)
{
  int drive_boot ;
  int res ;

  if ( Drvmap() & 0x04L ) drive_boot = 2 ;
  else                    drive_boot = 0 ;
   
  path[0] = 'A'+drive_boot ;
  strcpy( &path[1], ":\\CLIPBRD" ) ;

  res = Dcreate( path ) ;
  if ( res != 0 )
  {
    form_error(5) ;
    path[0] = 0 ;
    return -1 ;
  }
  else
  {
    strcat( path, "\\" ) ;
    res = scrp_write( path ) ;
    if ( res == 0 )
    {
      path[0] = 0 ;
      return -2 ;
    }
    return 0 ;
  }
}

int clbd_getpath(char* path)
{
  char name[200] ;
  int  res ;
  
  memzero( name, sizeof(name) ) ;
  res = scrp_read( name ) ;
  if ( (res == 0) || (*name == 0) ) /* Clipboard does not exist */
    return( clbd_create( path ) ) ; /* Let's create it          */
  else
  {
    char* last_aslash ;
    
    last_aslash = strrchr(name, '\\') ;
    if ( last_aslash == NULL )
      return( clbd_create( path ) ) ;
    {
      if ( *(1+last_aslash) == 0 )
      {
        strcpy( path, name ) ; /* Format is OK       */
        return 0 ;             /* eg : "C:\CLIPBRD\" */
      }
      else                   /* It's either :            */
                             /* 1 : "C:\CLIPBRD\SCRAP.XXX" */
      {                      /* 2 : "C:\CLIPBRD"           */
        DTA  new_dta ;
        DTA* old_dta ;

        old_dta = Fgetdta() ;
        Fsetdta( &new_dta ) ;

        if ( Fsfirst( 1+last_aslash, FA_SUBDIR ) != 0 ) /* Not a folder */
          *(1+last_aslash) = 0 ; /* Cas 1 */
        else
          strcat(name, "\\") ; /* \ was missing */

        strcpy( path, name ) ;
        Fsetdta( old_dta ) ;
        res = scrp_write( path ) ;
        if ( res == 0 )
        {
          path[0] = 0 ;
          return -2 ;
        }

        return 0 ;
      }
    }
  }
}
