/**********************************************/
/*   Fenàtre avec fonctions (agrandir...)     */
/*   Laser C          WIND2.C   */
/**********************************************/

#include <osbind.h>
#include "gem_inex.c"

int  whandle,      /* Comme dans WIND1.C */
     pxyarray[4],
     x,y,w,h;
     
int  tampon[8];    /* Les messages AES arrivent ici */

int  wx =  20,  /* Dimensions extÇrieures de la fenàtre avec valeurs initiales*/

     wy = 20,
     ww = 280,
     wh = 150;


void clip_window (pxyarray)    /* Limitent tous les affichages VDI suivants */
     int pxyarray[];           /* Ö une zone */
{
  vs_clip (handle, 1, pxyarray);        /* 1: Activer le clipping */
}


void switch_clipping_off()         /* annule la fenàtre avec clip_window */
{
int  pxyarray[4];

  vs_clip (handle, 0, pxyarray);        /* 0: clipping inactif */
}


void output_text()
{
  /* DÇsactiver le pointeur souris */
  
  v_hide_c (handle);
  
  /* Calcul de la zone de travail */

  wind_calc (1, 63, wx, wy, ww, wh, &x, &y, &w, &h);
  
  /* Conversion de hauteur/largeur dans le deuxiäme angle (x2/y2) */
  
  pxyarray[0] = x;          pxyarray[1] = y;
  pxyarray[2] = x+w-1;      pxyarray[3] = y+h-1;

  /* Effacer la zone de travail */
   
  vsf_interior (handle, 0);   /* Remplir avec couleur du fond */
  vsf_perimeter (handle, 0);  /* Pas de cadre */
  v_bar (handle, pxyarray);   /* Rectangle rempli de blanc */
  vsf_perimeter (handle, 1);  /* RÇactiver le cadre */
   
  /* êcrivons un texte quelconque dans la fenàtre */

  clip_window (pxyarray);
  
  v_gtext (handle, x+8, y+14,
         "Salut! Voici une dÇmonstration de fenàtre!");
  v_gtext (handle, x+8, y+30,
         "Vous pouvez dÇplacer cette fenàtre et modifier sa taille");
  v_gtext (handle, x+8, y+46,
         "Pour quitter: cliquer sur la boåte de fermeture!");
         
  switch_clipping_off();

  /* Afficher Ö nouveau le pointeur souris */
  
  v_show_c (handle, 1);
}


main()
{
  gem_init();
  
  graf_mouse (0, 0L);   /* Pointeur souris: fläche */
  
  whandle = wind_create (63, 0, 0, x_max, y_max);
            /* 63 = tout sauf les fläches et les ascenseurs */
  
  if (whandle < 0)
    form_alert (1, "[3][DÇsolÇ!|Plus de handle de fenàtre libre!][OK]");
  else
  {
    /* DÇfinition des lignes de titre et d'information */
    
    wind_set (whandle, 2, "WIND2.PRG", 0, 0);         /* 2 -> Titre et */
    wind_set (whandle, 3, "Veuillez noter:", 0, 0);   /* 3 -> Info */
    
    wind_open (whandle, wx, wy, ww, wh);

    /* Maintenant, effacer la zone de travail et */
    /* remplir la fenàtre avec quelque chose de sensÇ */
    
    output_text();   /* Nous le faisons dans un sous-programme */
    
    /***************************************************/
    /*              Voici le plus important:           */
    /*  Nous attendons des activitÇs de l'utilisateur  */
    /*  et nous les exploitons                         */
    /***************************************************/
    
    do
    {
      evnt_mesag (tampon);     /* Attendre un message */

      switch (tampon[0])
      {
        case 20:               /* Redraw */
          output_text();
          break;
          
        case 23:               /* Boåte plein Çcran */
          wx = 2;
          wy = 20;
          ww = x_max - 5;
          wh = y_max - 25;
          wind_set (whandle, 5, wx, wy, ww, wh); /* nouvelles dimensions */
          break;
          
        case 27:               /* Size-Box */
          ww = tampon[6];
          wh = tampon[7];
          wind_set (whandle, 5, wx, wy, ww, wh); /* nouvelles dimensions */
          break;
          
        case 28:               /* Move-Bar */
          wx = tampon[4];
          wy = tampon[5];
          wind_set (whandle, 5, wx, wy, ww, wh);
          break;
      }
    }   while (tampon[0] != 22);  /* Jusqu'Ö clic sur boåte de fermeture */
        
    
    wind_close (whandle);
    wind_delete (whandle);
  }
  gem_exit();
}





