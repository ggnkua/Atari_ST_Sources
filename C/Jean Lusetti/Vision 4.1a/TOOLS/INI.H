#ifndef __INI
#define __INI

typedef long HINI ;

HINI OpenIni(char *file) ;
long CloseIni(HINI h_ini) ;
long SaveAndCloseIni(HINI h_ini, char *new_name) ;
long GetIniKey(HINI h_ini, char *section, char *key, char *val_key) ;
long SetIniKey(HINI h_ini, char *section, char *key, char *val_key) ;
long GetOrSetIniKey(HINI h_ini, char *section, char *key, char *val_default_key) ;
long GetIniKeyFromFile(char *file, char *section, char *key, char *val_key) ;

#endif
