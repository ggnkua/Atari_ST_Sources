#include <stdio.h>
#include <tos.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>
#include <stdlib.h>

#include "n_global.h"
#include "nau_rsc.h" 
#include "nau_graf.h" 
#include "nau_rout.h"
#include "nau_game.h"

/*********************** Funktionen *******************************/

/* -------------------------------------------------------------------- */
/* Endemeldungen mit Abbruchbedingungen */
void ende_meldung(int *abbruch)
{

  int exit_obj;

  exit_obj = hndl_dial(NOSTONES,0,3,1,1);    
  switch (exit_obj)
  {
    case ONCEMORE:
      *abbruch = 1;
      form_alert(1,"[1][Lobenswert, aber|eigentlich ÅberflÅssig !|Der eigene C-Source wartet!][Schluck]");
      break;
    case KICKSHIT:
      *abbruch = 2;
       break;
  }
}


/* Routine zum Setzen der Tournament-Zeit */
void tournament_limit(OBJECT *menutree, int *t_stufe)
{
  int  lim_exit;

  menu_icheck((OBJECT *)menutree,TTIME,1);
  lim_exit =  hndl_dial(ZEITLMIT,0,2,1,1);
  switch (lim_exit)
  {
    case MIN15:                 /* Zeiten 12,10,8,6,4 Minuten */
      *t_stufe = 0;
      break;
    case MIN12:
      *t_stufe = 1;
      break;
    case MIN10:
      *t_stufe = 2;
      break;
    case MIN8:
      *t_stufe = 3;
      break;
    case MIN5:
      *t_stufe = 4;
      break;
  }
}

