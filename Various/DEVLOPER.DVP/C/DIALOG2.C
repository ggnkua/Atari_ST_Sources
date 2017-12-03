/*******************************************************************/
/*   Charger, afficher une boåte de dialogue et modifier les Edits */
/*   Megamax Laser C                    DIALOG2.C   */
/*******************************************************************/

#include <obdefs.h>    /* DÇfinitions des objets GEM */

#include "gem_inex.c"
#include "dialog2.h"   /* Fichier en-tàte du fichier ressource */

OBJECT *arbre_adr;      /* pointeur sur le premier objet d'un arbre*/
int    bouton;
char   entree[80];


select (arbre, index)          /* active le bouton "objet" */
OBJECT arbre[];
int    index;
{
  arbre[index].ob_state |= 1;     /* Mettre le bit 0 de ob_state Ö 1 */ 
}


deselect (arbre, index)       /* dÇsactive le bouton "objet" */
OBJECT arbre[];
int    index;
{
  arbre[index].ob_state &= -2;    /* Effacer le bit 0 de ob_state */ 
}


write_text (arbre, index, string)        /* Modifie l'objet TEXT */
OBJECT arbre[];
int    index;
char   string[];
{
TEDINFO *ted;

  ted = (TEDINFO *) arbre[index].ob_spec;
  strcpy (ted->te_ptext, string);
  
  /* ted->te_ptext  correspond Ö:  (*ted).te_ptext */
}


read_text (arbre, index, string)          /* Lit l'objet TEXT */
OBJECT arbre[];
int    index;
char   string[];
{
TEDINFO *ted;

  ted = (TEDINFO *) arbre[index].ob_spec;
  strcpy (string, ted->te_ptext);
}


show_dialog (arbre)              /* Affichage d'une boåte de dialogue */
OBJECT *arbre;
{
int  x, y, w, h;

  /* Centrage du formulaire Ö l'Çcran. Seules les coordonnÇes */
  /* sont adaptÇes Ö la rÇsolution de l'Çcran. Rien n'est     */
  /* encore dessinÇ. Nous recevons les futures coordonnÇes    */
  /* de la boåte de dialogue. */
  
  form_center (arbre, &x, &y, &w, &h);
  
  /* Sauvegarde des cadres, etc, des fenàtres: */
  form_dial (0, x, y, w, h, x, y, w, h);
  
  /* Dessin d'un rectangle "zoom" */
  form_dial (1, 25, 25, 25, 25, x, y, w, h);

  /* Dessin de l'arbre objet */
  /* Commence par l'objet no 0 (Racine, cadre extÇrieur) */
  /* Profondeur: 12 niveaux maxi (valeur arbitraire)     */
  objc_draw (arbre, 0, 12, x, y, w, h);
}


hide_dialog (arbre)
OBJECT *arbre;
{
int  x, y, w, h;

  /* Redemander les coordonnÇes: */
  form_center (arbre, &x, &y, &w, &h);
  
  /* Dessiner un rectangle diminuant */
  form_dial (2, 25, 25, 25, 25, x, y, w, h);
  
  /* Restitution des cadres des fenàtres et envoi */
  /* d'un message Redraw Ö toutes les fenàtres effacÇes */
  form_dial (3, x, y, w, h, x, y, w, h);
}


main()
{
  gem_init();
  
  /* Charger le fichier ressource (DIALOG2.RSC) */
  
  if (rsrc_load ("DIALOG2.RSC") == 0)
    form_alert (1, "[3][PAs de fichier RSC!][Fin]");
  else
  {
    /* Trouver l'adresse de (0 =) l'arbre DIALOG */
    rsrc_gaddr (0, FORM1, &arbre_adr);

    /* Initialisation des champs d'entrÇe et d'affichage */
    write_text (arbre_adr, TEXTP, "*** aucune ***");

    do
    {
      /* Effacer le champ d'entrÇe: */
      write_text (arbre_adr, TEXT, "");
      
      /* Faire afficher la boåte de dialogue: */
      show_dialog (arbre_adr);

      /* Faire travailler Dialog, ENTRêE du premier ÇlÇment EDIT */
      bouton = form_do (arbre_adr,TEXT);

      /* Inhiber l'Çtat "SELECTED" du bouton appuyÇ */
      deselect (arbre_adr, bouton);
    
      /* Faire disparaåtre la boåte de dialogue */
      hide_dialog (arbre_adr);

      /* Lire l'entrÇe et l'Çcrire dans le champ d'affichage */
      read_text (arbre_adr, TEXT, entree);
      write_text (arbre_adr, TEXTP, entree);

    }  while (bouton != FIN);  /* Jusqu'au'au clic de FIN */
    
    /* Effacer le fichier ressource de la mÇmoire: */
    rsrc_free();
  }
  
  gem_exit();
}
