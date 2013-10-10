/*****************************************************************/
/*   Charger, afficher et modifier la premiŠre boŒte de dialogue */
/*   Megamax Laser C                  DIALOG1.C   */
/*****************************************************************/

#include <obdefs.h>    /* D‚finitions GEM-Objet */

#include "gem_inex.c"
#include "dialog1.h"   /* Fichier en-tˆte du fichier ressource */

OBJECT *arbre_adr;      /* pointeur sur le premier objet d'un arbre */
int    bouton;
char   str[50],
       chiffre[2];


select (arbre, index)         /* active le bouton "object" */
OBJECT arbre[];
int    index;
{
  arbre[index].ob_state |= 1;     /* Mettre … 1 le bit 0 de ob_state */ 
}


deselect (arbre, index)       /* D‚sactive le bouton "objet" */
OBJECT arbre[];
int    index;
{
  arbre[index].ob_state &= -2;   /* Effacer le bit 0 de ob_state */ 
}


show_dialog (arbre)             /* Affichage d'une boŒte de dialogue */
OBJECT *arbre;
{
int  x, y, w, h;

  /* Centrage du formulaire … l'‚cran. Simple adaptation des  */
  /* coordonn‚es … la r‚solution. Rien n'est dessin‚. Nous    */
  /* recevons les futures coordonn‚es de la boŒte de dialogue */

  form_center (arbre, &x, &y, &w, &h);
  
  /* Sauvegarde des cadres de fenˆtre, etc: */

  form_dial (0, x, y, w, h, x, y, w, h);
  
  /* Dessin d'un rectangle zoom */
  form_dial (1, x, y, 1, 1, x, y, w, h);

  /* Dessin de l'arbre objet */
  /* Commence par l'objet no 0 (Racine, cadre ext‚rieur) */
  /* Profondeur maxi: 12 niveaux (arbitraire) */
  objc_draw (arbre, 0, 12, x, y, w, h);
}


hide_dialog (arbre)
OBJECT *arbre;
{
int  x, y, w, h;

  /* Redemander les coordonn‚es: */
  form_center (arbre, &x, &y, &w, &h);
  
  /* Dessiner un rectangle diminuant */
  form_dial (2, x, y, 1, 1, x, y, w, h);
  
  /* Restituer les cadres des fenˆtres et envoyer un */
  /* message Redraw … toutes les fenˆtres effac‚es  */
  form_dial (3, x, y, w, h, x, y, w, h);
}


main()
{
  gem_init();
  
  /* Charger le fichier ressource (DIALOG1.RSC) */
  
  if (rsrc_load ("DIALOG1.RSC") == 0)
    form_alert (1, "[3][Pas de fichier RSC!][Fin]");
  else
  {
    /* Trouver l'adresse (0 =) de l'arbre DIALOG */
    rsrc_gaddr (0, FORM1, &arbre_adr);

    /* Affichage de la boŒte de dialogue: */
    show_dialog (arbre_adr);
    
    /* Faire travailler Dialog: attendre l'appui d'un bouton */
    bouton = form_do (arbre_adr, 0);   /* 0 car pas de champ Edit */

    /* Inhiber l'‚tat "SELECTED" du bouton appuy‚ */
    deselect (arbre_adr, bouton);
    
    /* Faire disparaŒtre la boŒte de dialogue */
    hide_dialog (arbre_adr);
    
    /* Message … l'utilisateur indiquant sur quel bouton appuyer: */
    
    switch (bouton)
    {
      case BOUTON1: strcpy (chiffre, "1");
                   break;
      
      case BOUTON2: strcpy (chiffre, "2");
                   break;
      
      case BOUTON3: strcpy (chiffre, "3");
                   break;
    }
    
    strcpy( str,"[1][Appui sur le bouton no: ");
    strcat (str, chiffre);
    strcat (str, " ][C'est vrai!]");
    
    form_alert (1, str);
    
    /* Effacer le fichier ressource de la m‚moire: */
    rsrc_free();
  }
  
  gem_exit();
}
