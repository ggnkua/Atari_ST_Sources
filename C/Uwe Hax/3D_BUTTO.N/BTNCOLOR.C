/***********************************************/
/* BTNCOLOR.C                                  */
/*---------------------------------------------*/
/* CPX-Modul zur Einstellung der 3D-Buttons    */
/* ab AES-Version 3.40                         */
/* Autor: Uwe Hax                              */
/* (C) 1993 by MAXON                           */
/***********************************************/

#include <portab.h>
#include <aes.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>


/*
 * Definitionen zur besseren Lesbarkeit
 */

#define EOS                     '\0'
#define FALSE                   0
#define TRUE                    1

#define INDICATOR               0
#define ACTIVATOR               1
#define BACKGROUND              2

#define MESSAGE                 -1

#define OK_BUTTON               1

/* 
 * Definitionen fÅr objc_sysvar()    
 */

#define LK3DIND                 1
#define LK3DACT                 2
#define INDBUTCOL               3
#define ACTBUTCOL               4
#define BACKGRCOL               5
#define AD3DVALUE               6


/* 
 * Deklaration der zu sichernden Variablen
 * und Definition
 */
typedef struct 
{ 
  WORD ind_move, act_move;
  WORD ind_change, act_change;
  WORD ind_color, act_color;
  WORD background;
  WORD horizontal, vertical;
} SETTINGS;

SETTINGS settings = 
{ FALSE, TRUE, TRUE, FALSE, LWHITE, LWHITE, 
  LWHITE, 2, 2
};

/*
 * Restliche Include-Dateien
 */

#include "btncolor.rsh"
#include "btncolor.h"
#include "xcontrol.h"

/* 
 * sonstige globale Variablen
 */

WORD errno;
CPX_PARAMS *params;
OBJECT *dialog, *alert, *test;

WORD current_type = INDICATOR;

/*
 * Texte fÅr Popup-MenÅs
 */

char * types[3] = { "  Indikator   ", 
                    "  Aktivator   ", 
                    "  Hintergrund " };

char * status[2] = { "  Nein ",
                     "  Ja   " };

char * colors[16] =
{
  "  Weiû     ", "  Schwarz  ", "  Rot      ",
  "  GrÅn     ", "  Blau     ", "  Zyan     ",
  "  Gelb     ", "  Magenta  ", "  Hellgrau ",
  "  DGrau    ", "  DRot     ", "  DGrÅn    ",
  "  DBlau    ", "  DZyan    ", "  DGelb    ",
  "  DMagenta "
};

/* 
 * Prototypen
 */

CPX_INFO * cdecl init (CPX_PARAMS *par);
WORD objc_sysvar (WORD ob_smode, WORD ob_swhich, 
     WORD ob_sival1, WORD ob_sival2, WORD 
     *ob_soval1, WORD *ob_soval2);
OBJECT *get_traddr(WORD tree_index);
WORD cdecl main (GRECT *curr_wind);
WORD popup (char **texts, WORD items, 
     WORD object);
VOID into_resource (WORD type);
VOID objc_exdraw (OBJECT *tree, WORD object);
VOID cut (char *string);
VOID wind_center(OBJECT *tree,WORD *x,WORD *y,
     WORD *w,WORD *h);
VOID set_settings (SETTINGS *settings);
VOID handle_type (VOID);
VOID handle_color (VOID);
VOID handle_move (VOID);
VOID handle_change (VOID);
VOID handle_test (SETTINGS *save);
VOID handle_save (VOID);


/***********************************************/
/* Initialisierung des Moduls:                 */
/* öbergabeparameter: Zeiger auf die zur       */
/*    VerfÅgung stehenden Funktionen           */
/* 1. Aufruf bei Laden des Headers             */
/*    (par->booting == TRUE)                   */
/*    RÅckgabe: 0 bei Set-Only, 1 sonst        */
/* 2. Aufruf bei Laden des eigentlichen        */
/*    Programms (par->booting == FALSE)        */
/*    RÅckgabe: Adresse der CPX_INFO-Struktur  */
/***********************************************/
 
CPX_INFO * cdecl init (CPX_PARAMS *par)
{
  static CPX_INFO info={ main,0L,0L,0L,0L,0L,
                         0L,0L,0L,0L };

  appl_init();

  if (par->booting)
  {                
    /*
     * Bei Laden des Headers alle
     * Parameter setzen
     */
     
    if (_GemParBlk.global[0] >= 0x340)
      set_settings(&settings);
    
    /*
     * weitermachen
     */
     
    return((CPX_INFO *)1L);
  }
  else
  { 
    /*
     * Aufruf bei Laden des Programms:
     * Resource relozieren
     */
     
    params = par;  /* Zeiger retten */
    if (!params->rsc_init)
    {
      (*(params->do_resource))(NUM_OBS,NUM_FRSTR,
        NUM_FRIMG,NUM_TREE,rs_object,rs_tedinfo,
        rs_strings,rs_iconblk,rs_bitblk,rs_frstr,
        rs_frimg, rs_trindex, rs_imdope);
                          
      /*
       * globale Variablen initialisieren
       */
       
      dialog = get_traddr(DIALOG);
      test = get_traddr(TEST);
      alert = get_traddr(ALERT);
    } /* if */
                                                
    /* 
     * Adresse der CPX_INFO-Struktur
     * zurÅckgeben
     */

    return (&info);
  } /* else */
} /* init */


/***********************************************/
/* Aufruf nach Doppelclick auf das Icon im     */
/* Auswahlfenster: Zeichnen der Dialogbox,     */
/* Behandlung der Buttons                      */
/* öbergabeparameter: Koordinaten des Fenster- */
/*                    arbeitsbereichs          */
/* RÅckgabe: FALSE, wenn der Dialog mittels    */
/*           do_form() abgearbeitet wurde,     */
/*           TRUE, falls eigene Event-Routinen */
/*           benutzt werden sollen             */
/***********************************************/

WORD cdecl main (GRECT *curr_wind)
{  
  SETTINGS save;
  WORD dummy, button;
  WORD msg_buff[8];
  WORD abort_flag = FALSE;
  WORD x,y,w,h;
      
  appl_init();

  /* 
   * Koordinaten der Dialogbox setzen
   */
   
  dialog[ROOT].ob_x = curr_wind->g_x;
  dialog[ROOT].ob_y = curr_wind->g_y;

  /*
   * Fehlermeldung bei falscher AES-Version
   */
   
  if (_GemParBlk.global[0] < 0x340)
  {
    wind_center(alert, &x, &y, &w, &h);
    objc_exdraw(alert, ROOT); 
    (*params->do_form)(alert, 0, msg_buff);
    return (FALSE);
  } /* if */

  /* 
   * aktuelle Systemparameter einlesen 
   */
   
  objc_sysvar(FALSE, LK3DIND, 0, 0, 
       &settings.ind_move, &settings.ind_change);
  objc_sysvar(FALSE, LK3DACT, 0, 0, 
       &settings.act_move, &settings.act_change);
  objc_sysvar(FALSE, INDBUTCOL, 0, 0, 
       &settings.ind_color, &dummy);
  objc_sysvar(FALSE, ACTBUTCOL, 0, 0, 
       &settings.act_color, &dummy);
  objc_sysvar(FALSE, BACKGRCOL, 0, 0, 
       &settings.background, &dummy);
  objc_sysvar(FALSE, AD3DVALUE, 0, 0, 
       &settings.horizontal, &settings.vertical);
  save = settings;
  
  /* 
   * Parameter fÅr Indikator in Dialog eintragen
   * und Dialog zeichnen
   */
   
  into_resource(INDICATOR);
  objc_exdraw(dialog, ROOT);

  /* 
   * Dialog abarbeiten, bis ein Exit-Objekt
   * angeklickt wurde
   */

  do
  {
    button = (*params->do_form)(dialog, 0, 
                                msg_buff);
    if (button >= 0)
      button &= 0x7fff;
       
    switch (button)
    {
      case D_TYPE:
        handle_type();
        break;
        
      case D_COLTEXT:
        handle_color();
        break;
        
      case D_MOVE:
        handle_move();
        break;
        
      case D_CHANGE:
        handle_change();
        break;
        
      case D_TEST:
        handle_test(&save);
        break;
        
      case D_SAVE:
        handle_save();
        break;
        
      case D_OK:
        set_settings(&settings);
        abort_flag = TRUE;
        break;
        
      case D_CANCEL:
        abort_flag = TRUE;
        break;
        
      case MESSAGE:
        switch (msg_buff[0])
        {
          case WM_CLOSED:
            set_settings(&settings);

          case AC_CLOSE:
            abort_flag = TRUE;
            break;
        }
        break;
    } /* switch */
  }
  while (!abort_flag);
  dialog[button].ob_state &= ~SELECTED;

  return (FALSE);    
} /* main */


/***********************************************/
/* Alle Einstellungen fÅr 3D-Buttons ans       */
/* AES weitermelden.                           */
/* öbergabeparameter: Struktur mit allen Ein-  */
/*                    stellungen               */
/***********************************************/

VOID set_settings (SETTINGS *settings)
{
  WORD dummy;
  
  objc_sysvar(TRUE, LK3DIND, settings->ind_move, 
       settings->ind_change, &dummy, &dummy);
  objc_sysvar(TRUE, LK3DACT, settings->act_move, 
       settings->act_change, &dummy, &dummy);
  objc_sysvar(TRUE, INDBUTCOL, 
       settings->ind_color, 0, &dummy, &dummy);
  objc_sysvar(TRUE, ACTBUTCOL, 
       settings->act_color, 0, &dummy, &dummy);
  objc_sysvar(TRUE, BACKGRCOL, 
       settings->background, 0, &dummy, &dummy);
} /* set_settings */


/***********************************************/
/* Alle Einstellungen fÅr einen der drei       */
/* Button-Typen in den Dialog eintragen        */
/* öbergabeparameter: Button-Typ               */
/***********************************************/

VOID into_resource (WORD type)
{
  WORD color;

  /*
   * Typ-Name und Vergrîûerung der Buttons 
   * eintragen.
   */
     
  strncpy(dialog[D_TYPE].ob_spec.free_string, 
          &types[type][2], 11);
  dialog[D_HORIZONTAL].ob_spec.free_string[5] = 
          settings.horizontal + '0';
  dialog[D_VERTICAL].ob_spec.free_string[6] = 
          settings.vertical + '0';

  /*
   * Je nach Button-Typ Parameter eintragen.
   */
   
  switch (type)
  {
    case INDICATOR:
      color = settings.ind_color;
      strncpy(dialog[D_MOVE].ob_spec.free_string,
              &status[settings.ind_move][2], 4);
      strncpy(
            dialog[D_CHANGE].ob_spec.free_string,
            &status[settings.ind_change][2], 4);
      dialog[D_FRAME].ob_flags &= ~HIDETREE;
      break;
      
    case ACTIVATOR:
      color = settings.act_color;
      strncpy(dialog[D_MOVE].ob_spec.free_string,
              &status[settings.act_move][2], 4);
      strncpy(
            dialog[D_CHANGE].ob_spec.free_string,
            &status[settings.act_change][2], 4);
      dialog[D_FRAME].ob_flags &= ~HIDETREE;
      break;
      
    case BACKGROUND:
      color = settings.background;
      dialog[D_FRAME].ob_flags |= HIDETREE;
      break;
  } /* switch */

  /*
   * Ende der Strings abschneiden, damit der Text
   * im Button zentriert ist.
   */
   
  cut(dialog[D_MOVE].ob_spec.free_string);
  cut(dialog[D_CHANGE].ob_spec.free_string);

  /*
   * Farbe eintragen
   */
   
  dialog[D_COLOR].ob_spec.obspec.interiorcol = 
          color;
  strncpy(dialog[D_COLTEXT].ob_spec.free_string, 
          &colors[color][2], 8);
  cut(dialog[D_COLTEXT].ob_spec.free_string);
} /* into_resource */


/***********************************************/
/* Adresse eines Objektbaums ermitteln.        */
/* (neue rsrc_gaddr()-Routine)                 */
/* öbergabeparamter: Baum-Index                */
/* RÅckgabe: Zeiger auf Dialogbox              */
/***********************************************/

OBJECT *get_traddr(WORD tree_index)
{
  WORD i,j;
  
  for (i = 0,j = 0; i <= tree_index; i++)
    while (rs_object[j++].ob_next != -1);

  return (&rs_object[--j]);    
}

                        
/***********************************************/
/* Popup-MenÅ darstellen.                      */
/* öbergabeparameter: Textliste, Anzahl der    */
/*                    EintrÑge, Objektindex des*/
/*                    zugehîrigen Buttons      */
/* RÅckgabe: angeklickter Eintrag              */
/***********************************************/

WORD popup (char **texts, WORD items,WORD object)
{
  WORD checked;
  GRECT button, window;
  WORD i;
    
  /*
   * Aktuellen Eintrag ermitteln.
   */
   
  checked = -1;
  for (i = 0; i < items; i++)
    if (!strncmp(&texts[i][2], 
        dialog[object].ob_spec.free_string, 2))
    {
      checked = i;
      break;
    } /* if */
  
  /*
   * Grîûen festlegen.
   */    
   
  objc_offset(dialog, object, &button.g_x, 
              &button.g_y);
  button.g_w = dialog[object].ob_width;
  button.g_h = dialog[object].ob_height;
  window = *(GRECT *)&dialog[ROOT].ob_x;
  
  /* 
   * Pull-Down-MenÅ zeichnen lassen und Index des
   * angeklickten Eintrags zurÅckliefern
   */
   
  checked = (*params->do_pulldown)(texts, items, 
             checked, IBM, &button, &window);
             
  return (checked);
} /* popup_type */



/***********************************************/
/* Erweitere objc_draw()-Routine.              */
/* öbergabeparameter: Objektbaum, Objektindex  */
/***********************************************/

VOID objc_exdraw (OBJECT *tree, WORD object)
{
  WORD x, y, w, h;
  
  objc_offset(tree, object, &x, &y);
  w = tree[object].ob_width;
  h = tree[object].ob_height;
  if (tree[object].ob_state & OUTLINED)
  {
    x -= 3;
    y -= 3;
    w += 6;
    h += 6;
  } /* if */
  objc_draw(tree, ROOT, MAX_DEPTH, x, y, w, h);
} /* objc_exdraw */


/***********************************************/
/* Einen String nach dem ersten Leerzeichen    */
/* durchsuchen und durch ein EOS ersetzen.     */
/* Dadurch wird ein Text im Button zentriert.  */
/* öbergabeparameter: Button-String            */
/***********************************************/

VOID cut (char *string)
{
  while (*string != EOS)
  {
    if (*string == ' ')
    {
      *string = EOS;
      break;
    } /* if */
    string++;
  } /* while */
} /* cut */


/***********************************************/
/* Dialogbox im Fenster zentrieren             */
/* öbergabeparameter: Zeiger auf Dialogbox,    */
/*                    Koordinaten              */
/* RÅckgabe: indirekt Åber Koordinaten         */
/***********************************************/

VOID wind_center(OBJECT *tree,WORD *x,WORD *y,
                              WORD *w,WORD *h)
{
  tree[ROOT].ob_x = dialog[ROOT].ob_x +
                    (dialog[ROOT].ob_width -
                     tree[ROOT].ob_width) / 2;
  tree[ROOT].ob_y = dialog[ROOT].ob_y +
                    (dialog[ROOT].ob_height -
                     tree[ROOT].ob_height) / 2;
    
  *x = tree[ROOT].ob_x;
  *y = tree[ROOT].ob_y;
  *w = tree[ROOT].ob_width;
  *h = tree[ROOT].ob_height;
}


/***********************************************/
/* Auf das Anklicken des Typ-Buttons reagieren,*/
/* d.h. Popup-MenÅ darstellen und neue Werte   */
/* in den Dialog eintragen.                    */
/***********************************************/

VOID handle_type (VOID)
{
  WORD index, hidden;
  
  index = popup(types, 3, D_TYPE);
  if (index >= 0)
  {
    current_type = index;
    hidden = dialog[D_FRAME].ob_flags & HIDETREE;
    into_resource(index);
    objc_exdraw(dialog, D_TYPE);
    objc_exdraw(dialog, D_COLOR);
    objc_exdraw(dialog, D_COLTEXT);
    if (hidden != (dialog[D_FRAME].ob_flags & 
                   HIDETREE))
    {
      objc_exdraw(dialog, D_FRAME);
    }
    else
    {
      objc_exdraw(dialog, D_MOVE);
      objc_exdraw(dialog, D_CHANGE);
    } /* if */
  } /* if */
} /* handle_type */


/***********************************************/
/* Auf das Anklicken des Farb-Buttons reagie-  */
/* ren, d.h. Popup-MenÅ darstellen und neuen   */
/* Wert in den Dialog Åbernehmen.              */
/***********************************************/

VOID handle_color (VOID)
{
  WORD index;
  
  index = popup(colors, 16, D_COLTEXT);
  if (index >= 0)
  {
    dialog[D_COLOR].ob_spec.obspec.interiorcol = 
          index;
    strncpy(
          dialog[D_COLTEXT].ob_spec.free_string,
          &colors[index][2], 8);
    cut(dialog[D_COLTEXT].ob_spec.free_string);
    objc_exdraw(dialog, D_COLOR);
    objc_exdraw(dialog, D_COLTEXT);
          
    switch (current_type)
    {
      case INDICATOR:
        settings.ind_color = index;
        break;
              
      case ACTIVATOR:
        settings.act_color = index;
        break;
              
      case BACKGROUND:
        settings.background = index;
        break;
    } /* switch */
  } /* if */
} /* handle_color */



/***********************************************/
/* Auf das Anklicken des Buttons zur Einstel-  */
/* lung der Textverschiebung reagieren, d.h.   */
/* Popup-MenÅ darstellen und neuen Wert in     */
/* den Dialog Åbernehmen.                      */
/***********************************************/

VOID handle_move (VOID)
{
  WORD index;
  
  index = popup(status, 2, D_MOVE);
  if (index >= 0)
  {
    strncpy(dialog[D_MOVE].ob_spec.free_string, 
            &status[index][2], 4);
    cut(dialog[D_MOVE].ob_spec.free_string);
    objc_exdraw(dialog, D_MOVE);
       
    switch (current_type)
    {
      case INDICATOR:
        settings.ind_move = index;
        break;
          
      case ACTIVATOR:
        settings.act_move = index;
        break;
    } /* switch */
  } /* if */
} /* handle_move */


/***********************************************/
/* Auf das Anklicken des Buttons zur Einstel-  */
/* lung der FarbÑnderung reagieren, d.h.       */
/* Popup-MenÅ darstellen und neuen Wert in     */
/* den Dialog Åbernehmen.                      */
/***********************************************/

VOID handle_change (VOID)
{
  WORD index;
  
  index = popup(status, 2, D_CHANGE);
  if (index >= 0)
  {
    strncpy(dialog[D_CHANGE].ob_spec.free_string,
            &status[index][2], 4);
    cut(dialog[D_CHANGE].ob_spec.free_string);
    objc_exdraw(dialog, D_CHANGE);
          
    switch (current_type)
    {
       case INDICATOR:
         settings.ind_change = index;
         break;
              
       case ACTIVATOR:
         settings.act_change = index;
         break;
     } /* switch */
   } /* if */
} /* handle_change */



/***********************************************/
/* Auf das Anklicken des Test-Buttons reagie-  */
/* ren, d.h. Test-Dialog darstellen und bear-  */
/* beiten.                                     */
/* öbergabeparameter: Struktur mit allen Ein-  */
/*                    stellungen               */
/***********************************************/

VOID handle_test (SETTINGS *save)
{
  WORD dummy;
  
  wind_center(test, &dummy, &dummy, &dummy, 
              &dummy);

  set_settings(&settings);
  objc_exdraw(test, ROOT);
  form_do(test, 0);
  set_settings(save);

  test[T_INDICATOR].ob_state &= ~SELECTED;
  test[T_ACTIVATOR].ob_state &= ~SELECTED;
  test[T_OK].ob_state &= ~SELECTED;
  dialog[D_TEST].ob_state &= ~SELECTED;

  objc_exdraw(dialog, ROOT);
} /* handle_text */


/***********************************************/
/* Alle eingestellten Parameter speichern.     */
/***********************************************/

VOID handle_save (VOID)
{
   if ((*params->alert)(0) == OK_BUTTON)
     (*params->write_config)(&settings, 
                             sizeof(SETTINGS));
   dialog[D_SAVE].ob_state &= ~SELECTED;
   objc_exdraw(dialog, ROOT);
} /* handle_save */


/***********************************************/
/* objc_sysvar()-Routine ab AES 3.4, da sie in */
/* den meisten Compilern noch nicht integriert */
/* ist.                                        */
/***********************************************/

WORD objc_sysvar (WORD ob_smode, WORD ob_swhich, 
                 WORD ob_sival1, WORD ob_sival2,
                 WORD *ob_soval1,WORD *ob_soval2)
{
  AESPB aespb;
  
  aespb.contrl = _GemParBlk.contrl;
  aespb.global = _GemParBlk.global;
  aespb.intin = _GemParBlk.intin;
  aespb.intout = _GemParBlk.intout;
  aespb.addrin = (WORD *)_GemParBlk.addrin;
  aespb.addrout = (WORD *)_GemParBlk.addrout;

  _GemParBlk.contrl[0] = 48;
  _GemParBlk.contrl[1] = 4;
  _GemParBlk.contrl[2] = 3;
  _GemParBlk.contrl[3] = 0;
  _GemParBlk.contrl[4] = 0;

  _GemParBlk.intin[0] = ob_smode;
  _GemParBlk.intin[1] = ob_swhich;
  _GemParBlk.intin[2] = ob_sival1;
  _GemParBlk.intin[3] = ob_sival2;
  
  _crystal(&aespb);
  
  *ob_soval1 = _GemParBlk.intout[1];
  *ob_soval2 = _GemParBlk.intout[2];
  
  return(_GemParBlk.intout[0]);
} /* objc_sysvar */
