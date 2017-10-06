/*
   Modul: M_EVENT (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPEVENT_
#define _MPEVENT_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

#ifndef MU_RECT
   #define MU_RECT   16384
   #define MU_MOVED  32768
#endif

int SetPriority(int which,int id);
int InstMUKEYBD(HandleEvent handler);
int InstMUBUTTON(HandleEvent handler);
int InstMUMESAG(HandleEvent handler);
int InstMUMOVED(HandleEvent handler);
int InstMURECT(HandleEvent handler,GRECT *rect);
int InstMUTIMER(HandleEvent handler,long time);
void EnableEvent(int event);
void DisableEvent(int event);
void RemoveMUKEYBD(int id);
void RemoveMUBUTTON(int id);
void RemoveMUMESAG(int id);
void RemoveMUMOVED(int id);
void RemoveMURECT(int id);
void RemoveMUTIMER(int id);
void CentralDispatcher(void);
void ChangeMURECT(int handlerID,GRECT *rect);
void LazyMUMOVED(int val);

#endif