/***********************************************************************/
/*   Affichage d'une barre de menus/d'une option en tapant une touche  */
/*   Megamax Laser C                      MENU2.C   */

/***********************************************************************/

#include "menu2.h"    /* Constantes du fichier RSC */
/* Les deux nouvelles constantes s'appellent DESK & FONCTION */

int  tampon[8],
     key,
     dummy,
     title,
     quit = 0,
     which;
long menus_adresse;


void sub_info()
{
  form_alert (1,
      "[1][D‚mo de menus|(c) 1989 Micro Application][Continue]");
}


void sub_fin()
{
 if (form_alert (2, "[2][Vraiment? Terminer?][Oui|Non]") == 1)
   quit = 1;
}

     
main()
{
  appl_init();
  graf_mouse (0, 0L);   /* Pointeur souris: flŠche */
  
  /* Charger le fichier ressource */
  
  if (rsrc_load ("MENU2.RSC") == 0)  /* Erreur en cours de chargement? */
    form_alert (1, "[3][Pas de fichier ressource!][Quitter]");
  else
  {
    /* Trouver l'adresse de l'arbre des menus */
    rsrc_gaddr (0, MENU1, &menus_adresse);
    
    menu_bar (menus_adresse, 1);  /* Afficher la barre des menus */
    
    /* Boucle d'attente d'un ‚vŠnement: */
    
    do
    {
      which = evnt_multi (17, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
               tampon, 0, 0, &dummy, &dummy, &dummy, &dummy,
               &key, &dummy);
      
      if ((tampon[0] == 10) &&
          (which && 16))         /* Option cliqu‚e? */
      {
        title = tampon[3];       /* stocker pour plus tard */
        
        switch (tampon[4])
        {
          case INFO:  sub_info();
                      break;
          
          case FIN:  sub_fin();
                      break;
        }
        menu_tnormal (menus_adresse, title, 1);  
      }
      
      if (which && 1)      /* Touche appuy‚e */
      {
        key &= 255;        /* Ne prendre que le Low-Byte en consid‚ration */
        key = key > 'Z' ? key-('z'-'Z') : key;  /* Majuscule */
        switch (key)
        {
          case 'I': menu_tnormal (menus_adresse, DESK, 0);
                    sub_info();
                    menu_tnormal (menus_adresse, DESK, 1);
                    break;
         
         case 'E':  menu_tnormal (menus_adresse, FONCTION, 0);
                    sub_fin();
                    menu_tnormal (menus_adresse, FONCTION, 1);
                    break;
         }
      }
    }
    while (!quit);
    
    menu_bar (menus_adresse, 0);  /* Effacer le menu */
    rsrc_free();
  }
  appl_exit();
}
