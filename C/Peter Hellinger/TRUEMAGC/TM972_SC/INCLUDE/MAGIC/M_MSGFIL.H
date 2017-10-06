/*
   Modul: M_MSGFIL (Headerdatei)

   geschrieben von:
   
   Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach
    
   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPADVANC_
#define _MPADVANC_

#include <magic\m_types.h>

BOOLEAN ReadMsgfile(char *name,int *date_ptr,int *time_ptr);
void FreeMsgfile(void);
void GetMsgString(int num,char *msg);
void *GetMsgPtr(int num);

#endif /*_MPADVANC_*/