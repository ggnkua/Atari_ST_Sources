/***********************************************/
/*  Petit programme de d‚monstration graphique */
/*  Laser C         VDI_DEMO.C   */
/***********************************************/

#include "gem_inex.c"
#include <osbind.h>

int  pxyarray[4];   /* Il nous faut 2 points */
                        /* = 4 coordonn‚es */
main()
{
  gem_init();
  
  Cconws ("\33E");    /* Effacer l'‚cran avec une */
                               /* s‚quence Escape */
  pxyarray[0] = 11;
  pxyarray[1] = 10;
  pxyarray[2] = x_max-10;
  pxyarray[3] = y_max-30;
  v_rbox (handle, pxyarray);

  v_ellipse (handle, x_max/2, y_max/2-10, x_max/2-10, y_max/2-20);
  
  v_gtext (handle, x_max/2-96, y_max-10, " Le graphisme VDI? C'est facile!");
  
  Crawcin();          /* Attendre appui touche */
  
  gem_exit();
}




