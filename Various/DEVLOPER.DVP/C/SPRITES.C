/************************************/
/*   Sprites            SPRITES.C   */
/*   Laser C                        */
/************************************/

#include <linea.h>

#include "gem_inex.c"   /* Voir description dans le livre */

char  *donnees[] = {
  "****************","----------------",
  "****************","-**************-",
  "****************","-*--*------*--*-",
  "****************","-*--*------*--*-",
  "****************","-*--*------*--*-",
  "****************","-*--********--*-",
  "****************","-*------------*-",
  "****************","-*------------*-",
  "****************","-*-**********-*-",
  "****************","-*-*--------*-*-",
  "****************","-*-*-*-***--*-*-",
  "****************","-***--------*-*-",
  "****************","-***--**-*--*-*-",
  "****************","-*-*--------*-*-",
  "****************","-**************-",
  "****************","----------------"
} ;

int  sprite_data[32];
int  i;
int  pxyarray[4];
int  save_area[74];                    /* (tout pour moniteur monochrome) */
sprite sprite_info;                    /* struct venant de linea.h */


get_sprite_data()
{
int i;

  for (i=0; i<32; i++)
    sprite_data[i] = bin (donnees[i]);
}


int bin (zeile)
char *zeile;
{
int i, z;

  z=0;
  
  for (i=0; i<16; i++)
    z = ((z << 1) | ((*(zeile+i) == '*') & 1));
  
  return (z);
}  



main()
{
  gem_init();                          /* Voir description... */
  
  v_hide_c (handle);                   /* D‚sactiver pointeur souris */
  v_clrwk (handle);                    /* Effacer ‚cran */

  pxyarray[0] = 140;  pxyarray[1]=  50;     /* Dessiner rectangle */
  pxyarray[2] = 500;  pxyarray[3]= 150;
  vsf_interior (handle, 1);            /* Remplir complŠtement */
  v_rfbox (handle, pxyarray);     /* Dessiner rectangle … angles arrondis */
 
  v_show_c (handle, 1);                /* R‚afficher pointeur souris */
 
  get_sprite_data();

  sprite_info.x = 8;                /* Point d'action */
  sprite_info.y = 8;  
  sprite_info.format = 0;           /* Sprite normal */
  sprite_info.forecolor = 0;        /* Couleur du fond */
  sprite_info.backcolor = 1;        /* Couleur du sprite */
  
  for (i=0; i<32; i++)
    sprite_info.image[i] = sprite_data[i];   /* Masque et sprite */

  for (i=20; i<620; i++)
  {
    if (i>20) a_undrawsprite (save_area);
    a_drawsprite (i, 100, &sprite_info, save_area);
    xbios (37);                             /* Attendre retour d'image */
  }
  
  a_undrawsprite (save_area);
  
  gem_exit();
}
