/**************************************************************************/
/*   Charger et afficher une boŒte de dialogue, traiter les boutons radio */
/*   Megamax Laser C                      DIALOG3.C       */
/**************************************************************************/

#include <obdefs.h>    /* D‚finitions des objets GEM */

#include "gem_inex.c"
#include "dialog3.h"   /* Fichier en-tˆte du fichier ressource */

OBJECT *arbre_adr;      /* pointeur sur le premier objet d'un arbre */
int    bouton;
char   str[80],
       frq[20];


select (arbre, index)          /* active le bouton "objet" */
OBJECT arbre[];
int    index;
{
  arbre[index].ob_state |= 1;     /* Mettre … 1 le bit 0 de ob_state */ 
}


deselect (arbre, index)       /* D‚sactive le bouton "objet" */
OBJECT arbre[];
int    index;
{
  arbre[index].ob_state &= -2;    /* Effacer le bit 0 de ob_state */ 
}


int selected (arbre, index)   /* true quand l'objet est s‚lectionn‚ */
OBJECT arbre[];
int    index;
{
  return (arbre[index].ob_state && 1);    /* retourner le bit 0 */
}


write_text (arbre, index, string)        /* Modifie l'objet TEXT */
OBJECT arbre[];
int    index;
char   string[];
{
TEDINFO *ted;

  ted = (TEDINFO *) arbre[index].ob_spec;
  strcpy (ted->te_ptext, string);
  
  /* ted->te_ptext   correspond …:  (*ted).te_ptext */
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


show_dialog (arbre)              /* Affichage d'une boŒte de dialogue */
OBJECT *arbre;
{
int  x, y, w, h;

  /* Centrage du masque sur l'‚cran. Seules les coordonn‚es sont  */
  /* adapt‚es … la r‚solution de l'‚cran, rien n'est dessin‚ pour */
  /* le moment. Nous obtenons les futures coordonn‚es de la boŒte */
  /* de dialogue.                                                 */
  
  form_center (arbre, &x, &y, &w, &h);
  
  /* Sauvegarder les cadres des fenˆtres, etc: */
  form_dial (0, x, y, w, h, x, y, w, h);
  
  /* Dessiner un rectangle "zoom" */
  form_dial (1, 25, 25, 25, 25, x, y, w, h);

  /* Dessiner l'arbre objet */
  /* D‚part … l'objet no 0 (Racine, cadre ext‚rieur) */
  /* Profondeur: 12 niveaux maxi (val. arbitraire) */
  objc_draw (arbre, 0, 12, x, y, w, h);
}


hide_dialog (arbre)
OBJECT *arbre;
{
int  x, y, w, h;

  /* Redemander les coordonn‚es: */
  form_center (arbre, &x, &y, &w, &h);
  
  /* Dessiner un rectangle diminuant */
  form_dial (2, 25, 25, 25, 25, x, y, w, h);
  
  /* Restituer les cadres des fenˆtres et envoyer un message */
  /* Redraw … toutes les fenˆtres effac‚es.                  */
  form_dial (3, x, y, w, h, x, y, w, h);
}


main()
{
  gem_init();
  
  /* Charger le fichier ressource (DIALOG3.RSC) */
  
  if (rsrc_load ("DIALOG3.RSC") == 0)
    form_alert (1, "[3][Pas de fichier RSC!][Fin]");
  else
  {
    /* Adresse de (0 =) l'arbre DIALOG */
    rsrc_gaddr (0, FORM1, &arbre_adr);

    /* D‚terminer un bouton par d‚faut (dans l'exemple: FM) */
    select (arbre_adr, FM);

    /* Affichage de la boŒte de dialogue */
    show_dialog (arbre_adr);
    
    /* Dialog fait son travail, pas d'‚l‚ment EDIT */
    bouton = form_do (arbre_adr, 0);

    /* Inhiber l'‚tat "SELECTED" du bouton appuy‚ */
    deselect (arbre_adr, bouton);
    
    /* Effacer la boŒte de dialogue */
    hide_dialog (arbre_adr);
    
    /* Examiner les boutons: */
    if (selected (arbre_adr, FM))
      strcpy (frq, "Modulation de fr‚quence");
                
    if (selected (arbre_adr, OM))
      strcpy (frq, "Ondes moyennes");
      
    if (selected (arbre_adr, OC))
      strcpy (frq, "Ondes courtes");
      
    if (selected (arbre_adr, GO))
      strcpy (frq, "Grandes ondes");
    
    strcpy (str, "[1][Vous avez choisi la gamme |");
    strcat (str, frq);
    strcat (str, " ][Oui!]");
    
    form_alert (1, str);
    
    /* Effacer le fichier ressource de la m‚moire */
    rsrc_free();
  }
  
  gem_exit();
}
