/*
   Modul: M_POPUPS (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPPOPUPS_
#define _MPPOPUPS_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

void AttachPopup(OBJECT *main,OBJECT *sub,int entry);
void Popup(OBJECT *tree,int x,int y,int idx,OBJECT **pop,int *item);

#endif