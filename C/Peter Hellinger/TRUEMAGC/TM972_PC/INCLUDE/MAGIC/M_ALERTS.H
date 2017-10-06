/*
   Modul: M_ALERTS (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPALERTS_
#define _MPALERTS_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

typedef struct {
   int   message,
         objc;
} Alertpara;

typedef Alertpara* PtrAlertpara;

typedef  void  (*AlertHandler)(PtrAlertpara);

int Alert(int x,int y,int def,char *str);
void WindowAlert(int x,int y,int def,char *str,AlertHandler handler);
void SetIconColor(int fcolor,int bcolor);
CICONBLK *Iconslot(int slotnum);
void SetIconslot(int slotnum,CICONBLK *icon);

#endif
