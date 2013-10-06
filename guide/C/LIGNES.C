/***************************************************************/
/*   Modification de la largeur et des extr‚mit‚s des lignes   */
/*   Megamax Laser C                   LIGNES.C   */
/***************************************************************/

#include <osbind.h>
#include "gem_inex.c"

int  i;
int  pxyarray[4];   /* Ce tableau nous servira pour les coordonn‚es */

main()
{
  gem_init();
  
  Cconws ("\33E");    /* Effacer l'‚cran */
  
  vsl_width (handle, 33);        /* D‚finir la largeur de ligne */
  
  for (i=0; i<=2; i++)
  {
    vsl_ends (handle, i, i);     /* Permuter les extr‚mit‚s de ligne */
  
    pxyarray[0] = 20;            /* Coordonn‚es dans le tableau d'aide */
    pxyarray[1] = 20+70*i;
    pxyarray[2] = 300;
    pxyarray[3] = pxyarray[1];

    v_pline (handle, 2, pxyarray);  /* Relier 2 points */
  }
  
  Crawcin();     /* Attente appui touche */
  
  gem_exit();
}



