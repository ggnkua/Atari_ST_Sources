/*
   Modul: M_PROFIL (Headerdatei)
   
   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach
   
   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden
   
   Alle Rechte beim Autor
*/

#ifndef _M_PROFIL_
#define _M_PROFIL_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

BOOLEAN ReadProfile(char *name);
void FreeProfile(void);
BOOLEAN GetValue(char *token,long *val);
BOOLEAN GetBoolean(char *token,BOOLEAN *val);
BOOLEAN GetString(char *token,char *val);
BOOLEAN GetSV(char *token, int num, long val[]);

#endif