/*************************************************/
/*   D‚mo pour Copy trame, Opaque (vro_cpyfm)   */
/*  Megamax Laser C      COPYTRAM.C */
/*************************************************/

#include <osbind.h>
#include "gem_inex.c"

int  pxyarray[8];
long null_long = 0L;

main()
{
  gem_init();
  
  v_gtext (handle, 20, 50, "Salut, voici le texte");
  
  /* Vous devez avoir stock‚ les coordonn‚es des trames */
  /* source et cible avant l'appel de la fonction Raster */
  
  pxyarray[0] = 20;    pxyarray[1] = 36;   /* Trame source */
  pxyarray[2] = 204;   pxyarray[3] = 52;

  pxyarray[4] = 20;    pxyarray[5] = 65;   /* Trame cible */
  pxyarray[6] = 204;   pxyarray[7] = 81;
  
  vro_cpyfm (handle, 3, pxyarray, &null_long, &null_long);
  
  /* "&variable" donne le pointeur sur "variable" */
  /* Le mode 3 est le mode de remplacement */

  pxyarray[5] = 90;   /* Seules les coordonn‚es en y */
  pxyarray[7] = 106;  /* sont modifi‚es … la deuxiŠme copie */

  vro_cpyfm (handle, 7, pxyarray, &null_long, &null_long);
  
  /* Nous venons de passer en mode 7 (transparent) */
  
  Crawcin();   /* Attendre appui touche */
  
  gem_exit();

}
