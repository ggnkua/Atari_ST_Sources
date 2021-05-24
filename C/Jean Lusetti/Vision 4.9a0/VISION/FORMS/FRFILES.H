#ifndef __FRFILES_H
#define __FRFILES_H

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
long GetRFilesEx(RFILE *rfiles, int nb_max_rfiles, int return_nb_files, char *log_file, int (*user_func)(long nfiles_so_far, char* current_filename, void* user_data), void* user_data) ;

#define GetRFiles(rfiles,nb_max_rfiles,return_nb_files,log_file) GetRFilesEx(rfiles,nb_max_rfiles,return_nb_files,log_file,(int (*)(long nfiles_so_far, char* current_filename, void* user_data))NULL,NULL)

#endif
