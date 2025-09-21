#include <stdio.h>
#include <tos.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>
#include <stdlib.h>

#include "nau_rsc.h" 
#include "n_global.h"
#include "nau_graf.h"
#include "nau_rout.h"
#include "nau_game.h" 

/*********************** Funktionen *******************************/

void get_akt_path(char * pfad)
{
  int drive;
  char temp[128];
  
  drive = Dgetdrv();    /* Aktuelles Laufwerk holen */
  pfad[0] = (char) drive + 'A';
  pfad[1] = '\0';
  strcat(pfad,":");
  Dgetpath(temp,drive+1);     /* Pfad holen               */
  strcat(pfad,temp);
  strcat(pfad,"\\");
}


/* --------------------------------------------------- */
/*        Dialog mit dem Anwender ausfhren            */
/* --------------------------------------------------- */

int hndl_dial (int baumindex,int anfangsfeld, int tiefe, int normal_set, int save_area)
    
{
              long tree;
              int  xd, yd, wd, hd;
     register int exit_obj;

     wind_update(BEG_UPDATE);
     MAUS_AUS;
     wind_update(END_UPDATE);

     rsrc_gaddr(R_TREE,baumindex,&tree);
                              /* bestimme Objektbaumadresse           */

     form_center((OBJECT *)tree,&xd,&yd,&wd,&hd);
                              /* errechne zentrierte Position der Box */
                              /* und trage diese im Objektbaum ein.   */
   
     if (save_area == 1)      /* Hintergrund sichern */
        save_rechteck(xd,yd,wd+1,hd+1);

     MAUS_EIN;
     MAUS_HAND;   


     form_dial(0,0,0,0,0,xd,yd,wd,hd );
                              /* reserviere Bildschirmbereich fr die */
                              /* Dialogbox.                           */

     objc_draw((OBJECT *)tree,0,tiefe,xd,yd,wd,hd);
                              /* zeichne Dialog auf den Bildschirm    */

     exit_obj = form_do((OBJECT *)tree,anfangsfeld);
                              /* fhre Dialog                         */

     if (normal_set == 1)
        objc_change((OBJECT *)tree,exit_obj,0,xd,yd,wd,hd,NORMAL,0);
                              /* selektiertes Objekt auf normal setzen */

     form_dial(3,0,0,0,0,xd,yd,wd,hd );
                              /* gebe Bildschirmbereich wieder frei   */

     MAUS_AUS;
     if (save_area == 1)      /* Hintergrund restaurieren */
        restore_rechteck(xd,yd,wd+1,hd+1);

     MAUS_EIN;
     MAUS_HAND;   

     return (exit_obj);     /* return exit-Button */
}

  /*------- Holt die Stringadresse aus einem Dialogbaum ---------------*/
char *get_dial_str_adr(int baumindex, int obj_nr, int mode)
{
  OBJECT * baum_zeiger = {0L};
  TEDINFO * text_zeiger;
  char * out_str = {0L};

  /* Holt Zeiger auf Objekt-Wurzel */
  if(0 != rsrc_gaddr(R_TREE,baumindex,&baum_zeiger))
  {
    baum_zeiger += obj_nr;   /* zeigt nun auf Tochter-Objekt */
    switch(mode)
    {
      case G_FTEXT  : text_zeiger = baum_zeiger -> ob_spec.tedinfo; 
      /* TEDINFO */   out_str = text_zeiger -> te_ptext;    break;
      case G_STRING : out_str = baum_zeiger -> ob_spec.free_string;
      /* STRING */    break;
    }
  }
  return (out_str);
}
