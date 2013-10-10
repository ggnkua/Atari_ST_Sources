/************************************/
/*   Ouvrir et fermer une fenˆtre   */
/*   Laser C   WIND1.C   */
/************************************/

#include <osbind.h>
#include "gem_inex.c"

int  whandle,
     pxyarray[4],
     x,y,w,h;

main()
{
  gem_init();
  
  whandle = wind_create (4095, 20, 20, 280, 150);
            /* 4095 = tous les organes de commande */
  
  if (whandle < 0)
    form_alert (1, "[3][D‚sol‚!|Il ne reste plus de handle fenˆtre libre!][OK]"
);
  else
  {
    wind_open (whandle, 20, 20, 280, 150);
    
    /* Calcul de la zone de travail */
    
    wind_calc (1, 4095, 20, 20, 280, 150, &x, &y, &w, &h);
    
    /* Conversion de hauteur/largeur du deuxiŠme angle (x2/y2) */
    
    pxyarray[0] = x;          pxyarray[1] = y;
    pxyarray[2] = x+w-1;      pxyarray[3] = y+h-1;

    /* Effacer la zone de travail */
    
    vsf_interior (handle, 0);   /* Remplir avec couleur du fond */
    vsf_perimeter (handle, 0);  /* Pas de cadre */
    
    v_bar (handle, pxyarray);
    
    vsf_perimeter (handle, 1);  /* R‚activer le cadre */
    
    Crawcin();   /* Attendre appui touche */
    
    wind_close (whandle);
    wind_delete (whandle);
  }
  
  gem_exit();
}
