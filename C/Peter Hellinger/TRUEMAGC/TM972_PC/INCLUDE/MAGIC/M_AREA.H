/*
   Modul: M_AREA (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPAREA_
#define _MPAREA_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

typedef struct
{
   int      x,
            y,
            w,
            h;
   BOOLEAN  init;
   long     size;
   void     *mfdbadr;
   MFDB     mfdb;
} AreaDescr;

typedef AreaDescr* AREA;

BOOLEAN NewAREA(AREA *a);
void DisposeAREA(AREA *a);
void FreeArea(AREA *a);
BOOLEAN SaveArea(int hndl,AREA *a,GRECT *rect);
void RestoreArea(int hndl,AREA *a);
void CopyArea(int hndl,AREA *a,int xx,int yy);
void MoveArea(int hndl,AREA *a,int xmove,int ymove,int *xx,int *yy);
void SetMFDB(MFDB *m,void *adr,int w,int h,int fm,int planes);

#endif