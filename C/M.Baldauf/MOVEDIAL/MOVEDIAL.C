/*****************************************/
/*  Demoprogramm der MOVEDIAL-Routinen  */
/*  written in Turbo C 2.0              */
/*--------------------------------------*/
/*  Sourcefile: MOVEDIAL.C              */
/*--------------------------------------*/
/*  by M.Baldauf 6/1990                 */
/*  (c) by MAB                          */
/****************************************/ 

#include "movedial.h"    /* RSC-Definitionen */
#include "movelib.h"     /* Unterprogramm-Deklarationen */
#include <aes.h>         /* AES-Routinen */
#include <vdi.h>         /* VDI-Routinen */

void do_popup_menue(void);
void do_popup_menue(void)
{
  /* Objecte (Dialogboxen, Men, etc.) deklarieren */
  OBJECT *dialog,  /* MOVEDIAL-Box */
         *infodial,/* STANDARD-Dialogbox */
         *poppie,  /* POPUP-Dialogbox */
         *popup;   /* Auswahl-(Popup-)Dialog */
         
  int ret;
 
  rsrc_gaddr(R_TREE, DIALOG,   &dialog);
  rsrc_gaddr(R_TREE, POPUP,    &popup);
  rsrc_gaddr(R_TREE, INFODIAL, &infodial);
  rsrc_gaddr(R_TREE, POPPIE,   &poppie);
 
  /* Durchfhrung */  
  do
  {
    /* Vorbereitung */
    vor_dial(popup,2);

    /* Dialogbox ausgeben (zeichnen) */
    draw_dial(popup,2);
    
    ret = form_do(popup,0);            /* dies erledigt das AES */
    popup[ret].ob_state &= ~SELECTED;  /* SELECTED zurcksetzen */
    
    /* Nachbereitung */
    nach_dial(popup,2); 
    
    /* was hat der Benutzer gew„hlt? */
    switch (ret)
    {
      case POPMOVE:  do_movedial(dialog,DIALOGDR);
                     break;
      case POPPOPUP: do_popup(poppie);
                     break;
      case POPSTAND: do_dial(infodial);
                     break;
      default:       break;
    }
    
  } while (ret != POPQUIT);
}
      
int main(void)
{
  int handle;
  char rsc_name[] = "MOVEDIAL.RSC";  

  /* Initialisierung der Applikation */
  handle = gem_init();
  
  if (handle >= 0)
  {
    /* Maus als Bienchen */
    graf_mouse(HOURGLASS,0L);
  
    /* Resource-Datei laden */
    if (rsrc_load(rsc_name)) 
    {
      /* und los gehts */
      graf_mouse(ARROW,0L);
      
      do_popup_menue();
    }
    else
      return(-1);
      
    /* Abmelden der Applikation */
    gem_exit(handle);
  
    return(0);
  }
  else
    return(-1);
}