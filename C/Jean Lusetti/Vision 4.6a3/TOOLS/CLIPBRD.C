/******************************/
/* Gestion du Clipboard       */
/* (c) LUSETTI Jean A“ut 1993 */
/******************************/
#include    <tos.h>
#include   "xaes.h"
#include <string.h>
#include <stddef.h>


int clbd_create(char *path)
{
  int  drive_boot ;
  int  res ;

  if (Drvmap() & 0x04L) drive_boot = 2 ;
  else                  drive_boot = 0 ;
   
  path[0] = 'A'+drive_boot ;
  strcpy(&path[1], ":\\CLIPBRD") ;
    
  res = Dcreate(path) ;
  if (res != 0)
  {
    form_error(5) ;
    path[0] = 0 ;
    return(-1) ;
  }
  else
  {
    strcat(path, "\\") ;
    res = scrp_write(path) ;
    if (res == 0)
    {
      path[0] = 0 ;
      return(-2) ;
    }
    
    return(0) ;
  }
}

int clbd_getpath(char *path)
{
  char name[200] ;
  int  res ;
  
  memset(name, 0, 200) ;
  res = scrp_read(name) ;
  if ((res == 0) || (*name == 0)) /* Le clipboard n'existe pas */
    return(clbd_create(path)) ;   /* On le cr‚e */
  else
  {
    char *last_aslash ;
    
    last_aslash = strrchr(name, '\\') ;
    if (last_aslash == NULL)
      return(clbd_create(path)) ;
    {
      if (*(1+last_aslash) == 0)
      {
        strcpy(path, name) ; /* La chaine est au bon format */
        return(0) ;          /* Ex : "C:\CLIPBRD\"          */
      }
      else                   /* L… 2 cas soit :            */
                             /* 1 : "C:\CLIPBRD\SCRAP.XXX" */
      {                      /* 2 : "C:\CLIPBRD"           */
        DTA  new_dta ;
        DTA  *old_dta ;

        old_dta = Fgetdta() ;
        Fsetdta(&new_dta) ;

        if (Fsfirst(1+last_aslash, FA_SUBDIR) != 0) /* Pas un dossier */
          *(1+last_aslash) = 0 ; /* Cas 1 */
        else
          strcat(name, "\\") ; /* Il manquait juste le \ */

        strcpy(path, name) ;
        Fsetdta(old_dta) ;
        res = scrp_write(path) ;
        if (res == 0)
        {
          path[0] = 0 ;
          return(-2) ;
        }
    
        return(0) ;
      }
    }
  }
}
