#ifndef __INI
#define __INI

/* Demander les infos MEMDEBUG si MEMDEBUG est d‚fini (Define Macro) */
#ifdef MEMDEBUG
#include "d:\pure_c\projects\tools\memdebug\memdebug.h"
#endif

typedef long HINI ;

HINI OpenIni(char *file) ;
long CloseIni(HINI h_ini) ;
long SaveAndCloseIni(HINI h_ini, char *new_name) ;
long GetIniKey(HINI h_ini, char *section, char *key, char *val_key) ;
long SetIniKey(HINI h_ini, char *section, char *key, char *val_key) ;
long GetOrSetIniKey(HINI h_ini, char *section, char *key, char *val_default_key) ;

#endif
