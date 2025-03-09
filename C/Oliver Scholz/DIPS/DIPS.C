/***********************************************/
/* Datei: DIPS.C                               */
/* ------------------------------------------- */
/* Modul: DIPS.CPX                Version 1.00 */
/* (C) 1991 by MAXON Computer                  */
/* Autoren: Oliver Scholz & Uwe Hax            */
/* verwendeter Compiler: Turbo-C 2.0           */
/***********************************************/


/* die Åblichen Header-Dateien --------------- */

#include <portab.h>
#include <aes.h>
#include <string.h>


/* Definitionen zur besseren Lesbarkeit ------ */

#define TRUE         1
#define FALSE        0
#define EOS          '\0'
#define OK_BUTTON    1
#define MESSAGE     -1      /* Message-Event */


/* globale Variablen ------------------------- */

/* Die zu sichernde Variable:                  */
/* gewÅnschter Status der DIP-Schalter         */

LONG schalter = 0xFFL; /* default: alle OFF    */

/* Header, die Daten erzeugen,                 */
/* erst hier einladen                          */

#include "dips.rsh"
#include "dips.h"
#include "xcontrol.h" /* darf erst nach "*.rsh" 
                         eingebunden werden */


/* sonstige globale Variablen ---------------- */

CPX_PARAMS *params; /* vom Kontrollfeld Åber-
                       gebener Zeiger auf die
                       Kontrollfeld-Funktionen */

/* Strings fÅr Dialogbox --------------------- */

char ein[]="Ein";
char aus[]="Aus";
char empty[]="   ";

OBJECT *switches;    /* Zeiger auf Dialogboxen */
OBJECT *error;

/* Prototypen fÅr Turbo-C -------------------- */

WORD cdecl main(GRECT *curr_wind);
CPX_INFO * cdecl init(CPX_PARAMS *params);
OBJECT *get_traddr(WORD tree_index);
VOID pulldown(WORD button, LONG *work_swi);
VOID redraw_object(OBJECT *tree, WORD object);
VOID into_resource(LONG work);
VOID wind_center(OBJECT *tree, WORD *x, WORD *y,
                 WORD *w, WORD *h);

/* diese Funktionen sind im Assembler Modul -- */
VOID set_switches(LONG new_cookie);
LONG get_switches(VOID);

/* Funktionen -------------------------------- */

/***********************************************/
/* Initialisierung des Moduls:                 */
/* öbergabeparameter: Zeiger auf die zur       */
/*    VerfÅgung stehenden Funktionen           */
/* 1. Aufruf bei Laden des Headers             */
/* 2. Aufruf bei Laden des eigentlichen        */
/*    Programms                                */
/***********************************************/
                    
CPX_INFO * cdecl init(CPX_PARAMS *par)
{
  static CPX_INFO info={ main,0L,0L,0L,0L,0L,
                         0L,0L,0L,0L };

  if (par->booting)  /* bei Laden des Headers */
  { 
    /* Cookie auf gewÅnschten Wert setzen */
    set_switches(schalter);  

    return((CPX_INFO *)1L);  /* kein Set-Only */
  }
  else /* Aufruf bei Laden des Programms */
  { 
    params=par;  /* Zeiger retten! */
  
    /* Resource relozieren */
    if (!params->rsc_init)
    {
      (*(params->do_resource))(NUM_OBS,NUM_FRSTR,
        NUM_FRIMG,NUM_TREE,rs_object,rs_tedinfo,
        rs_strings,rs_iconblk,rs_bitblk,rs_frstr,
        rs_frimg,rs_trindex,rs_imdope);
                          
      /* Adressen der Dialoge berechnen */
      switches=get_traddr(SWITCHES);
      error=get_traddr(ERROR);
    }
                                                
    /* Adresse der CPX_INFO-Struktur zurÅck */
    return(&info);
  }
}  

/***********************************************/
/* Aufruf nach Doppelclick auf das Icon im     */
/* Auswahlfenster: Zeichnen der Dialogbox,     */
/* Behandlung der Buttons                      */
/* öbergabeparameter: Koordinaten des Fenster- */
/*                    arbeitsbereichs          */
/***********************************************/

WORD cdecl main(GRECT *curr_wind)
{  
  LONG work_swi;
  WORD msg_buff[8];
  WORD button,x,y,w,h;
  WORD abort_flag=FALSE;
  char swi[5]="_SWI";

  /* Koordinaten der Dialogbox setzen */
  switches[ROOT].ob_x=curr_wind->g_x;
  switches[ROOT].ob_y=curr_wind->g_y;

  /* aktuellen Switch-Cookie lesen */
  if (!(*params->find_cookie)
	            (*(LONG *)swi,&work_swi))
    {
    /* kein Cookie-Jar oder kein Switch-Cookie */

          wind_center(error,&x,&y,&w,&h);
          objc_draw(error,ROOT,MAX_DEPTH,
                    x-3,y-3,w+6,h+6);
          form_do(error,0);
          error[ERROK].ob_state &= ~SELECTED;
          return(FALSE); /* fertig */
    }
  
  /* akt. Schalter in Dialogbox eintragen */
  into_resource(work_swi);

  /* und Dialogbox zeichnen */
  objc_draw(switches,ROOT,MAX_DEPTH,
	    	switches[ROOT].ob_x,
            switches[ROOT].ob_y,
	    	switches[ROOT].ob_width,
            switches[ROOT].ob_height);

  /* Dialogbox abarbeiten, bis ein Exit-Objekt
     angeklickt wurde */

  do
  {
    /* neuer form_do()-Aufruf */
    button=(*params->do_form)
                          (switches,0,msg_buff);
     
    /* Doppelklick ausmaskieren */
    if (button>=0)
      	button &= 0x7fff;
       
    /* angeklicktes Objekt auswerten */
    switch (button)
    {
      case SAVE:
        /* Werte Åbernehmen */
        schalter=work_swi;
        set_switches(schalter);
        
        /* Parameter in CPX-Datei speichern */
        if ((*params->alert)(0)==OK_BUTTON)
          (*params->write_config)(&schalter,
            sizeof(LONG));
        switches[SAVE].ob_state &= ~SELECTED;
        redraw_object(switches,SAVE);
        break;
                     
      case OK:
	    /* Werte Åbernehmen */
        schalter=work_swi;  
        set_switches(schalter);

        abort_flag=TRUE;
        break;
                
      case READ:
	    /* DIP Schalter lesen */
	    work_swi=get_switches();
        switches[READ].ob_state &= ~SELECTED;
        into_resource(work_swi);
        redraw_object(switches,ROOT);
	    break;
     
      case CANCEL:
        abort_flag=TRUE;
        break;
                       
      case DIP1:   
      case DIP2:      
      case DIP3:
      case DIP4:
      case DIP5:
      case DIP6:
      case DIP7:
      case DIP8:
        pulldown(button,&work_swi);
        break;

      case MESSAGE:
        switch (msg_buff[0])
        {
          case WM_REDRAW:         
            break;        /* nicht notwendig */

          case WM_CLOSED:
            set_switches(work_swi);

            /* fÅr "resident" notwendig */
            schalter=work_swi;  

          case AC_CLOSE:
            abort_flag=TRUE;
            break;
        }
        break;
    }  
  }
  while (!abort_flag);
  switches[button].ob_state &= ~SELECTED;

  return(FALSE);
}


/***********************************************/
/* Parameter in die Dialogbox eintragen        */
/* öbergabeparameter: Zeiger auf Status        */
/* RÅckgabe: keine                             */
/***********************************************/

VOID into_resource(LONG work)
{ 
  WORD i,maske;
  WORD index[] = { DIP1, DIP2, DIP3, DIP4,
                   DIP5, DIP6, DIP7, DIP8 };

  maske=0x01;

  /* alle Knîpfe belegen */
  for(i=0; i<8; i++)
    {
    switches[index[i]].ob_spec.free_string=
    	(work&maske) ? aus : ein;
    maske <<= 1;
    }
}


/***********************************************/
/* Neuzeichnen eines Objekts mit Hilfe der vom */
/* Kontrollfeld gelieferten Rechteck-Liste.    */
/* öbergabeparameter: Zeiger auf Objektbaum,   */
/*                    Objekt-Index             */
/* RÅckgabe: keine                             */
/***********************************************/

VOID redraw_object(OBJECT *tree, WORD object)
{
  GRECT *clip_ptr,clip,xywh;
    
  /* absolute Objekt-Koordinaten berechnen */
  objc_offset(tree,object,&xywh.g_x,&xywh.g_y);
  xywh.g_w=tree[object].ob_width;
  xywh.g_h=tree[object].ob_height;
  
  /* erstes Rechteck holen */
  clip_ptr=(*params->rci_first)(&xywh);

  /* solange noch Rechtecke da sind */
  while (clip_ptr)
  {
    /* clip_ptr: Zeiger auf lokale Variable!! */
    clip=*clip_ptr;  /* deshalb kopieren */

    /* Objekt neu zeichnen */
    objc_draw(tree,object,MAX_DEPTH,clip.g_x,
              clip.g_y,clip.g_w,clip.g_h);

    /* nÑchstes Rechteck holen */
    clip_ptr=(*params->rci_next)();
  }
}


/***********************************************/
/* Pulldown-MenÅ generieren, darstellen und    */
/* auswerten.                                  */
/* öbergabeparameter: angeklickter Button, aus */
/*                    dem das MenÅ "heraus-    */
/*                    klappen" soll,           */
/*                    Zeiger auf aktuelle      */
/*                    Parameter                */
/* RÅckgabe: keine                             */
/***********************************************/

VOID pulldown(WORD button, LONG *work_swi)
{
  WORD i;
  LONG maske;
  WORD index,checked;
  GRECT button_xywh,window_xywh;
  char *pull_adr[2];
  char pull_buff[2][15];
  WORD dips[] = { DIP1, DIP2, DIP3, DIP4,
                  DIP5, DIP6, DIP7, DIP8 };

  /* Pull-Down-MenÅ generieren */ 

  /* Texte eintragen */

  strcpy(pull_buff[0],empty);
  strcpy(pull_buff[1],empty);

  strcat(pull_buff[0],ein);
  strcat(pull_buff[1],aus);

  strcat(pull_buff[0],empty);
  strcat(pull_buff[1],empty);
              
  i=0;
  maske=1L;
  while(dips[i]!=button)
    {
      maske <<= 1;
      i++;
    }

  if(*work_swi & maske)
      index=1;
  else
      index=0;

  /* absolute Button-Koordinaten berechnen */
  objc_offset(switches,button,&button_xywh.g_x,
              &button_xywh.g_y);
  button_xywh.g_w=switches[button].ob_width;
  button_xywh.g_h=switches[button].ob_height;
 
  /* absolute Koordinaten der Dialogbox 
     ermitteln */
  objc_offset(switches,ROOT,&window_xywh.g_x,
    &window_xywh.g_y);
  window_xywh.g_w=switches[ROOT].ob_width;
  window_xywh.g_h=switches[ROOT].ob_height;

  /* Adressen der einzelnen EintrÑge in das 
     öbergabe-Array eintragen */          

    pull_adr[0]=pull_buff[0];
    pull_adr[1]=pull_buff[1];
 
  /* Pull-Down-MenÅ zeichnen lassen und Index des
     angeklickten Eintrags zurÅckliefern */
  checked=(*params->do_pulldown)
    (pull_adr,2,index,IBM,
    &button_xywh,&window_xywh);

  /* wenn Eintrag angeklickt wurde... */
  if (checked>=0)
  {
    /* ...dann entsprechend reagieren */
     if(checked==0)
       *work_swi &= ~maske;
     else
       *work_swi |= maske;

    /* neue Werte in die Dialogbox eintragen */
    into_resource(*work_swi);
  }

  /* Button neu zeichnen */
  switches[button].ob_state &= ~SELECTED;
  redraw_object(switches,button);
}

/***********************************************/
/* Dialogbox im Fenster zentrieren             */
/* öbergabeparameter: Zeiger auf Dialogbox,    */
/*                    Koordinaten              */
/* RÅckgabe: indirekt Åber Koordinaten         */
/***********************************************/

VOID wind_center(OBJECT *tree,WORD *x,WORD *y,
                              WORD *w,WORD *h)
{
  tree[ROOT].ob_x=switches[ROOT].ob_x+
                  (switches[ROOT].ob_width-
                  tree[ROOT].ob_width)/2;
  tree[ROOT].ob_y=switches[ROOT].ob_y+
                  (switches[ROOT].ob_height-
                  tree[ROOT].ob_height)/2;
    
  *x=tree[ROOT].ob_x;
  *y=tree[ROOT].ob_y;
  *w=tree[ROOT].ob_width;
  *h=tree[ROOT].ob_height;
}

/***********************************************/
/* Liefert Adresse einer Dialogbox             */
/* (neue rsrc_gaddr()-Routine)                 */
/* öbergabeparamter: Baum-Index                */
/* RÅckgabe: Zeiger auf Dialogbox              */
/***********************************************/

OBJECT *get_traddr(WORD tree_index)
{
  WORD i,j;
  
  for (i=0,j=0; i<=tree_index; i++)
    while (rs_object[j++].ob_next!=-1);

  return(&rs_object[--j]);    
}






