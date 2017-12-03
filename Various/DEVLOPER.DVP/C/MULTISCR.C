/****************************************************************/
/*   Plusieurs ‚crans logiques (graphisme sans scintillement)   */
/*   Megamax Laser C                MULTISCR.C     */
/****************************************************************/


#include <osbind.h>                  /* D‚finitions systŠme d'exploitation */

#include "gem_inex.c"                /* Mentionn‚ dans chap. 5 */

long screen1,
     screen2,
     memory,

     malloc ();
     

init_screens()
{
  screen1 = Logbase();                            /* Adresse de la RAM-Video */
  if ((memory = malloc (32256)) == 0L)            /* Allouer nouvelle m‚moire */
  {
    printf ("La m‚moire est pleine!!!\n");        /* Message d'erreur */
    Crawcin();                                    /* Attendre touche */
    Pterm0();                                     /* Quitter programme */
  }
  screen2 = (memory & 0xffffff00) + 256;         /* doit ˆtre au bord de page */
}


swap_screens()                                    /* Commuter ‚crans 1/2 */
{
  if (Logbase () == screen1)
    Setscreen (screen2, screen1, -1);
  else
    Setscreen (screen1, screen2, -1);
}


main()
{
int i;
  init_screens ();                          /* Initialisiation du 2Šme ‚cran */

  gem_init();                    /* Se trouve dans fichier Include GEM_INEX.C */

  v_hide_c (handle);                        /* D‚sactiver pointeur souris */
  
  for (i=20; i<=300; i++)
  {
     Cconws ("\33E");                        /* Effacer ‚cran */
     v_gtext (handle, i, i, "Salut!");       /* Affichage texte sous GEM */
     swap_screens ();                        /* Commuter ‚crans log./phys. */
     
     Vsync();                                /* Attente retour image */
  }

  Crawcin();                                 /* Attente appui touche */

  Setscreen (screen1, screen1, -1);          /* Retour … l'‚cran normal */
  v_show_c (handle, 1);                      /* Pointeur souris actif */

  gem_exit();
}
