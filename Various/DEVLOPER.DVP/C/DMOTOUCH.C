/******************************************************/
/*   Demo automatique (Pour quitter taper une touche) */
/*   Megamax Laser C      DMOTOUCH.C  */
/******************************************************/

#include <osbind.h>
#define  CONSOLE 2

int  i;

affichage (string)
char *string;
{
  while (*string != 0)
    Bconout (CONSOLE, *(string++));
}

main()
{
  while (!Bconstat (CONSOLE))  /* Poursuivre ex‚cution tant qu'aucune */
                               /* touche n'est tap‚e */
  {
    affichage ("DEMONSTRATION. Touche = FIN...        \n");

       for (i=0; i<9999; i++)               /* Boucle de ralentissement */
      ;
  }
    Bconin (CONSOLE);          /* Le caractŠre en attente doit ˆtre */
                               /* r‚cup‚r‚ dans le tampon du clavier */
}

