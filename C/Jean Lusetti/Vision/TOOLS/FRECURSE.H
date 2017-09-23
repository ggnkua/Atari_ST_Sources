/************************/
/* Header de FRECURSE.C */
/************************/
#if !defined(__FRECURSE)
#define __FRECURSE

/* Demander les infos MEMDEBUG si MEMDEBUG est d‚fini (Define Macro) */
#ifdef MEMDEBUG
#include "d:\pure_c\projects\tools\memdebug\memdebug.h"
#endif


void find_files(int long_names, char *path, char *mask, void (*user_func)(char *filename, DTA *dta, void *user_data), void *user_data) ;
void folder_recurse(int long_names, char *path, char *mask, void (*user_func)(char *filename, DTA *dta, void *user_data), void *user_data, char *logfile) ;

long count_files(char *path, char *file_mask, int recurse, char *log_file) ;

int file_in_mask(char *fname, char *mask) ;


#endif
