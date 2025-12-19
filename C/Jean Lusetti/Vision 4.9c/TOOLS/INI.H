#ifndef __INI_H
#define __INI_H

typedef void* HINI ;

HINI OpenIni(char* file) ;
long CloseIni(HINI h_ini) ;
long SaveAndCloseIni(HINI h_ini, char* new_name) ;
long GetIniKey(HINI h_ini, char* section_name, char* key_name, char* key_value) ;
long SetIniKey(HINI h_ini, char* section_name, char* key_name, char* key_value) ;
long SetIniKeyUShort(HINI h_ini, char* section_name, char* key_name, unsigned short key_value) ;
long SetIniKeyShort(HINI h_ini, char* section_name, char* key_name, short key_value) ;
long SetIniKeyBool(HINI h_ini, char* section_name, char* key_name, short key_value) ;
long GetOrSetIniKey(HINI h_ini, char* section_name, char* key_name, char* key_value) ;
long GetIniKeyFromFile(char* file, char* section_name, char* key_name, char* key_value) ;

/* Testing Purpose */
int IniTest(int nsections, int nkeys_start, int nkeys_add) ;

#endif
