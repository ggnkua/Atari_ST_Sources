/************************************************************/
/*   Charger le fichier RSC et afficher une barre de menus  */
/*   Megamax Laser C              MENU1.C    */
/************************************************************/

#include "menu1.h"    /* Constantes du fichier RSC */
/* Rappel: les constantes s'appellent MENUS, INFO et FIN */

int  tampon[8],
     title,
     quit = 0;
long menus_adresse;
     
main()
{
  appl_init();
  graf_mouse (0, 0L);   /* Pointeur souris: fläche */
  
  /* Charger le fichier ressource */
  
  if (rsrc_load ("MENU1.RSC") == 0)  /* Erreur en cours de chargement? */
    form_alert (1, "[3][Pas de fichier ressource!][Quitte]");
  else
  {
    /* Trouver l'adresse de l'arbre des menus */
    rsrc_gaddr (0, MENU1, &menus_adresse);
    
    menu_bar (menus_adresse, 1);  /* Afficher la barre des menus */
    
    /* Boucle d'attente d'Çvänement */
    
    do
    {
      evnt_mesag (tampon);
      
      if (tampon[0] == 10)   /* Option cliquÇe? */
      {
        title = tampon[3];   /* stocker pour plus tard */
        
        switch (tampon[4])
        {
          case INFO:  form_alert(1,"[1][DÇmo menus|(c) 1989 Micro Application][Continue]");
                      break;
          
          case FIN:  if (form_alert(2,"[2][Vraiment? Terminer?][Oui|Non]") == 1)
                          quit = 1;
                      break;
        }
        menu_tnormal(menus_adresse, title, 1);  
      }
    }
    while (!quit);
    
    menu_bar (menus_adresse, 0);  /* Effacer le menu */
    rsrc_free();
  }
  appl_exit();

}
