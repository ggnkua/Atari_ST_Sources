/**************************************************/
/*   Deux fenˆtre en mˆme temps, avec fonctions   */
/*   Laser C                WIND3.C   */
/**************************************************/

#include <osbind.h>
#include "gem_inex.c"

int  whandle[2],                     /* Tout pour deux Fenˆtres */
     opened[2] = {1, 1};             /* Drapeau si fenˆtre ouverte */
     
int  tampon[8];                   /* Les messages AES arrivent ici */

int  wx[2] = {20, 50},      /* Dimensions ext‚rieures des fenˆtres */
     wy[2] = {20, 50},      /* avec valeurs initiales */
     ww[2] = {200, 200},
     wh[2] = {120, 120};
     
int  xdesk, ydesk, wdesk, hdesk;        /* Dimensions du Bureau */

int  i, window;                         /* Variables */


void clip_window (pxyarray)             /* Limite tous les affichages VDI */
     int pxyarray[];                    /* suivants … une seule zone */
{
  vs_clip (handle, 1, pxyarray);        /* 1: Active le clipping */
}


void switch_clipping_off()              /* annule clip_window */
{
int  pxyarray[4];

  vs_clip (handle, 0, pxyarray);        /* 0: Clipping d‚sactiv‚ */
}


void output_text(window)
     int window;
{
int  pxyarray[4],
     x,y,w,h;     
  
  /* Calcul de la zone de travail */

  wind_calc (1, 63, wx[window], wy[window], ww[window],
             wh[window], &x, &y, &w, &h);
  
  /* Conversion de hauteur/largeur en deuxiŠme angle: (x2/y2) */
    
  pxyarray[0] = x;          pxyarray[1] = y;
  pxyarray[2] = x+w-1;      pxyarray[3] = y+h-1;

  clip_window (pxyarray);
  
  draw_text (pxyarray, x, y);
  
  switch_clipping_off();
}


draw_text (pxyarray, x, y)
int pxyarray[], x, y;
{
  /* D‚sactiver le pointeur souris */
  
  v_hide_c (handle);

  /* Effacer zone de travail */
   
  vsf_interior (handle, 0);   /* Remplir avec couleur du fond */
  vsf_perimeter (handle, 0);  /* pas de cadre */
  v_bar (handle, pxyarray);   /* Rectangle rempli de blanc */
  vsf_perimeter (handle, 1);  /* R‚activer le cadre */
    
  /* Nous ‚crivons un texte quelconque dans la fenˆtre */

  v_gtext (handle, x + 8, y + 14, 
         "Salut! Voici une d‚monstration de fenˆtre");
  v_gtext (handle, x + 8, y + 30, 
         "Vous pouvez d‚placer la fenˆtre et modifier sa taille.");
  v_gtext (handle, x + 8, y + 46, 
         "Pour quitter, cliquer sur la boŒte de fermeture!");
         
  /* R‚afficher le pointeur souris */
  
  v_show_c (handle, 1);
}


int create_windows()
{
  /* Passer la taille du bureau par la commande no 4 de wind_get  */
  /* Le bureau a un handle (identificateur) de fenˆtre fixe: le 0 */
  
  wind_get (0, 4, &xdesk, &ydesk, &wdesk, &hdesk);
  
  for (i = 0;  i <= 1;  i++)
    whandle[i] = wind_create (63, xdesk, ydesk, wdesk, hdesk);

  return (whandle[0] < 0 || whandle[1] < 0);
}


int intersect (x1, y1, w1, h1, x2, y2, w2, h2, pxyarray)
    int x1, y1, w1, h1, x2, y2, w2, h2, pxyarray[];
{
int x, y, w, h;

  w = (x2+w2 < x1+w1) ? x2+w2 : x1+w1;
  h = (y2+h2 < y1+h1) ? y2+h2 : y1+h1;
  x = (x2 > x1) ? x2 : x1;
  y = (y2 > y1) ? y2 : y1;
  
  pxyarray[0] = x;
  pxyarray[1] = y;
  pxyarray[2] = w - 1;
  pxyarray[3] = h - 1;

  return (w > x && h > y);
}


void redraw (window)
     int window;
{
int  x, y, w, h,        /* Nouvelle zone … dessiner */
     rx, ry, rw, rh,    /* Variables pour la liste des rectangles */
     ax, ay, aw, ah,    /* Zone de travail */
     pxyarray[4];
     
  wind_update (1);   /* D‚sactiver souris, bloquer la liste des rectangles */
  
  x = tampon[4];     /* Coordonn‚es de la zone … redessiner */
  y = tampon[5];     /* (fait partie du message) */
  w = tampon[6];
  h = tampon[7];
  
  /* Passer les dimensions de la zone de travail */
  
  wind_calc (1, 63, wx[window], wy[window], ww[window],
       wh[window], &ax, &ay, &aw, &ah);
  
  /* Appel du premier rectangle de la liste: (11) */
  
  wind_get (whandle[window], 11, &rx, &ry, &rw, &rh);

  while (rw != 0)    /* Tant que largeur > 0... */
  {
    if (intersect (x, y, w, h, rx, ry, rw, rh, pxyarray))
    {
      clip_window (pxyarray);
      draw_text (pxyarray, ax, ay); 
      /* pxyarray indique le rectangle … dessiner et */
      /* x et y donnent le coin sup‚rieur gauche     */
      /* (pas forc‚ment dans le rectangle)           */
    }
  wind_get (whandle[window], 12, &rx, &ry, &rw, &rh);  /* Rectangle suivant */
  }
  
  switch_clipping_off();
  wind_update (0);   /* Nous avons termin‚ */
}


main()
{
  gem_init();
  
  graf_mouse (0, 0L);   /* Pointeur souris: flŠche */
  
  if (create_windows())  /* La fonction retourne 1 en cas d'erreur */
    form_alert (1, "[3][D‚sol‚!|Plus de handle fenˆtre disponible!][OK]");
  else
  {
    /* Param‚trer lignes de titre et d'information */
    
    wind_set (whandle[0], 2, "Fenˆtre 1", 0, 0);      
    wind_set (whandle[1], 2, "Fenˆtre 2", 0, 0);
    
    wind_set (whandle[0], 3, "Veuillez noter:", 0, 0); 
    wind_set (whandle[1], 3, "Veuillez noter ‚galement:", 0, 0);
    
    /* Ouvrir une fenˆtre et ‚crire quelque chose */
    
    for (i = 0;  i <= 1;  i++)
    {
      wind_open (whandle[i], wx[i], wy[i], ww[i], wh[i]);
      output_text (i);
    }
    
    /*******************************************************************/
    /*                  Voici le plus important:                       */
    /* Nous attendons des activit‚s de l'utilisateur et les exploitons */
    /*******************************************************************/
    
    do
    {
      evnt_mesag (tampon);     /* Attente d'un message */
      
      /* Passer l'index de la fenˆtre origine du message */
      /* tampon[3] contient le handle de la fenˆtre */

      for (window = 0;  
             !(tampon[3] == whandle[window] || window == 2);  window++);
      
      if (window != 2)   /* Trouv‚ le handle ou notre fenˆtre? */
      {
        switch (tampon[0])
        {
          case 20:               /* Redraw */
            redraw (window);
            break;
         
          case 21:               /* Topped */
            wind_set(whandle[window], 10, 0, 0, 0, 0);  /* 10 -> Top */
            break;
              
          case 23:               /* BoŒte plein ‚cran */
            wx[window] = xdesk + 2;
            wy[window] = ydesk + 2;
            ww[window] = wdesk - 6;
            wh[window] = hdesk - 6;
            wind_set (whandle[window], 5, wx[window],
                 wy[window], ww[window], wh[window]); /* nouvelles dimensions */
            break;
              
          case 27:               /* Size Box (boŒte de modification de taille)
 */
            ww[window] = tampon[6];
            wh[window] = tampon[7];
            wind_set (whandle[window], 5, wx[window],
                wy[window], ww[window], wh[window]); /* Nouvelles dimensions */
            break;
              
          case 28:               /* Barre de d‚placement */
            wx[window] = tampon[4];
            wy[window] = tampon[5];
            wind_set (whandle[window], 5, wx[window],
                wy[window], ww[window], wh[window]); /* Nouvelles dimensions */
            break;
              
          case 22:               /* Close Box (boŒte fermeture) */
            wind_close (whandle[window]);
            wind_delete (whandle[window]);
            opened[window] = 0;   /* d‚signer comme ferm‚ */
            break;
        }
      }
    }   while (opened[0] || opened[1]);  /* Jusqu'… ce que les 2 fenˆtres */
  }                                      /* soient ferm‚es */
  gem_exit();
}
