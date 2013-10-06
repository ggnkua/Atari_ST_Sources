/******************************************/
/*   D‚mo d'utilisation du timer A du MFP   */
/*   Laser C      TIMER_A.C   */
/******************************************/

#include <osbind.h>
#define  CONSOLE 2

long i;


routine()
{
static char *str = "ceci est un message important\15\12\12\12\
le timer a du mfp de l'atari st est beaucoup plus\15\12\
facile … utiliser que ce que la plupart des gens\15\12\
croient      \15\12\12\12\
          strictement confidentiel \15\12\
          ======================== \15\12\12\12\12\12";

  if (*str)    /* si pas encore fin de chaŒne, alors... */
  {
    Bconout (CONSOLE, *str);   /* Afficher caractŠre */
    str++;                     /* Pointeur sur caractŠre suivant */
  }
}


static entry();  
asm {      /* Intervention de l'interruption */

entry:     movem.l D0-D7/A0-A6,-(A7)
           jsr     routine
           movem.l (A7)+,D0-D7/A0-A6
           bclr.b  #5,0xfffffa0f
           rte
    }


main()
{
  Cursconf (3,0);   /* Le curseur ne doit pas clignoter */
  
  /* Lancer le timer: */
  /* Timer A (0) … 48 Hz --> Diviseur par 200 (7) */
  /* et registre donn‚es 0=256 */
   
  Xbtimer (0, 7, 0, entry);
  
  /* Boucle de ralentissement */
  for (i=0; i<1100000; i++);
  
  /* D‚sactiver le timer: */  
  Xbtimer (0, 0, 0, entry);
}
