/********************************************************************/
/*               			 Demo zu Submenu V1.15                        */
/*              - Einsatz von Submenus unter GEM -                  */
/* - lauff�hig unter allen TOS-Versionen und in allen Aufl�sungen - */
/*                     von Uwe Hax in Megamax C                     */
/*								Pure C-Konvertierung: Thomas Werner								*/
/*                   (c) 1992 MAXON Computer GmbH   								*/
/********************************************************************/

#include <stdio.h>
#include <aes.h>
#include <vdi.h>
#include "submenu.h"

typedef enum
{
    FALSE,
    TRUE
}
boolean;


int  dummy;

extern 	GEMPARBLK	_GemParBlk;
extern	int	handle;

/* -------------------------------------------------------------------------- */
#define MAX_SUBMENU   4                    /* 4 Submenus                      */

#include "menu.h"                          /* RSC-Definitionen f�r Men�s      */
#include "s_menu.h"                        /* RSC-Definitionen f�r Submenus   */

extern int  subnum;             /* R�ckgabewert: angeklickter Submenu-Eintrag */
/* -------------------------------------------------------------------------- */



void gem_prg(void)
{
  int  mesg_buff[8];
  OBJECT *menu,*submenu;
  int  event;
  OBJECT **rcs_pointer;
  OBJECT *rcs_adr;
  int  ende=FALSE;
  char string[20];
  int  m_index[MAX_SUBMENU];


  /* Resource-Files laden */
  /* 1. Resource-File mit den Submenus */
  if (!rsrc_load("s_menu.rsc"))
  {
    form_alert(1,"[3][SUBMENU.RSC nicht gefunden!][ Abbruch ]");
    return;
  }
  rsrc_gaddr(R_TREE,MENU,&submenu);

  /* Adresse des Resource-Files merken */
  rcs_pointer=(OBJECT **)&_GemParBlk.global[5];
  rcs_adr=*rcs_pointer;

  /* 2. Resource-File mit allen anderen Definitionen: normale Men�s,
     Dialogboxen, ... laden */
  if (!rsrc_load("menu.rsc"))
  {
    form_alert(1,"[3][MENU.RSC nicht gefunden!][ Abbruch ]");
    return;
  }
  rsrc_gaddr(R_TREE,MENU,&menu);

  /* Submenus installieren */
  m_index[0]=BILDTYP;      /* Indices aller Men�-Eintr�ge, die Titel f�r */
  m_index[1]=SYSTEM;       /* Submen�s sein sollen                       */
  m_index[2]=COMPUTER;     /* in fortlaufender Reihenfolge               */
  m_index[3]=STIL;
  init_submenus(handle,menu,submenu,MAX_SUBMENU,m_index);

  graf_mouse(ARROW,0);
  menu_bar(menu,TRUE);

  do
  {
    event=evnt_multi(MU_MESAG | MU_TIMER,dummy,dummy,dummy,dummy,dummy,dummy,
                     dummy,dummy,dummy,dummy,dummy,dummy,dummy,mesg_buff,100,
                     0,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);

    if (event & MU_MESAG)
    {
      if (mesg_buff[0]==MN_SELECTED)
      {
        switch (mesg_buff[4])
        {
          case BILDTYP:
          case SYSTEM:
          case COMPUTER:
          case STIL:      redraw_bg();    /* bei Anklicken der Submenu-Titel  */
                          break;          /* m�ssen auch die Submenus ein-    */
                                          /* klappen                          */
          case ENDE:      ende=TRUE;
                          break;
        }
        menu_tnormal(menu,mesg_buff[3],TRUE);
      }
    }


    if (event & MU_TIMER)    /* subnum mu� regelm��ig abgefragt werden        */
    {                        /* da kein MU_MESAG gesendet wird                */
      if (subnum)            /* Submenu angew�hlt? */
      {
        /* Haken setzen bzw. l�schen */
        if (submenu[subnum].ob_state & CHECKED)
          menu_icheck(submenu,subnum,FALSE);
        else
          menu_icheck(submenu,subnum,TRUE);

        /* Index-Nr. des angew�hlten Submenus ausgeben */
        sprintf(string,"Submenu-Index: %d ",subnum);
        v_gtext(handle,0,150,string);
        subnum=0;     /* anschlie�end zur�cksetzen */
      }
    }
  }
  while (!ende);

  /* Resource-Files wieder freigeben */
  rsrc_free();
  *rcs_pointer=rcs_adr;
  rsrc_free();
}


