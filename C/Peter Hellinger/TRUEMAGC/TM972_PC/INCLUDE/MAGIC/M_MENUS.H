/*
   Modul: M_MENUS (Headerdatei)

   geschrieben von Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte beim Autor
*/

#ifndef _MPMENUS_
#define _MPMENUS_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

#define mDefault        0  /* Nix gesetzt       */
#define mCheck          1  /* HÑckchen setzen   */
#define mUncheck        2  /* HÑckchen lîschen  */
#define mDisable        4  /* Eintrag disablen  */
#define mEnable         8  /* Eintrag freigeben */
#define mSwapDisabled  16  /* Bei den EintrÑgen, die in spec.x und spec.y stehen
                              werden die Disabled-Flags geswapped. Disabled
                              wird zu nicht disabled und umgekehrt. */
#define  mSwapChecked  32  /* wie bei mSwapDisabled, nur mit checked-Flag */
#define  mBell         64  /* Das Stadler-Flag: Klingeling!!! */

typedef struct
{
   OBJECT   *tree;
   tKey     key;
   int      window,
            mx,
            my,
            menu,
            entry;
   GRECT    spec;
   BITSET   action;
}  MenuParameter;

typedef MenuParameter* PtrMenupara;

typedef  void  (*MenuHandler)(PtrMenupara);

BOOLEAN InitMenuline(OBJECT *menu, MenuHandler handler, BOOLEAN lines);
void InstallDeskMenu(OBJECT *menu);
void AttachMenu(void *main, void *sub, int entry, int back, int start, int scroll);
BOOLEAN ScanMenu(OBJECT *menu, tKey key, BITSET kbshift, int *title, int *item, int *sub);

#define  ReleaseDeskMenu() CallMagic(1602)
#define  DisableDeskMenu() CallMagic(1603)
#define  EnableDeskMenu()  CallMagic(1604)

#endif
