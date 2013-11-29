#ifndef __FRFILES
#define __FRFILES

#if !defined(__STDIO)
#include <stdio.h>     /* Pour FILE et PATH_MAX */
#endif

/* 1+FIND_FOLDER4-FIND_FOLDER1 */
#define NB_MAX_RFILES   4
typedef struct
{
  char path[PATH_MAX] ;
  char mask[10] ;

  int  recurse ;
}
RFILE ;

/* En retour :                                 */
/* Si return_nb_files = 0, 1 : OK, 0 : Annule  */
/* Sinon -2 : Le bouton annuler a ete actionne */ 
/*       -1 : Annulation lors du comptage      */
/*     >= 0 : nombre de fichiers trouves       */ 
long GetRFiles(RFILE *rfiles, int nb_max_rfiles, int return_nb_files, char *log_file) ;

#endif
