#include <stdlib.h>
#include <tos.h>

#include "gem.h"
#include "scr2.h"

static long *Scr2Original;	                  /* Address of old screen */
static long *Scr2Extra;  	                /* Address of extra screen */
static long *Scr2Malloc;  	         /* Malloc-Address of extra screen */

/*-------------------------------------------------------------------------*/
/* Defines a second screen. Returns the address from the two screens.      */ 
/*-------------------------------------------------------------------------*/
void Scr2Init()
{
   Scr2Original = (long*)Physbase();
   Scr2Extra = Scr2Malloc = (long*)malloc(0x7e00);  
   if (!Scr2Malloc)
       GemAbort("Scr2Init: memory exhausted!");

   (long)Scr2Extra += (0x100 - ((long)Scr2Malloc)%0x100);      /* Mod 256 */
   Setscreen(Scr2Extra, Scr2Original, -1); 
}

/*-------------------------------------------------------------------------*/
/* Physbase = Logbase = original screen					   */
/* extra screen is deleted.						   */
/*-------------------------------------------------------------------------*/
void Scr2Exit()
{
   /* What we see now is the extra screen, so first copy this to the other */
   if (Physbase() == (void *)Scr2Extra) {
      Scr2Copy();
      Scr2Swap();
   }
   Setscreen(Scr2Original, Scr2Original, -1);
   free(Scr2Malloc);
}

/*-------------------------------------------------------------------------*/
/* The logical and physical screens are switched.                          */
/*-------------------------------------------------------------------------*/
void Scr2Swap()
{
   Setscreen(Physbase(), Logbase(), -1);
}

/*-------------------------------------------------------------------------*/
/* Copies the Physical_screen to the Logical_screen. So after a            */
/* switch_init, it copies the current screen to the background screen.     */
/*-------------------------------------------------------------------------*/
void Scr2Copy()
{
   register int cnt;
   register long *screen1, *screen2;

   screen1 = (long *)Physbase();
   screen2 = (long *)Logbase();
   for (cnt=0 ; cnt<8000 ; cnt++)
      *(screen2++) = *(screen1++);
}
