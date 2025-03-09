/**************************************/
/*  MOVEDIAL-Library fÅr Dialogboxen  */
/*------------------------------------*/
/*  Sourcefile: MOVELIB.C             */
/*------------------------------------*/
/*  by M.Baldauf 				              */
/*  (c) 1992 MAXON Computer GmbH      */
/**************************************/ 

#include <aes.h>         /* AES-Routinen */
#include <vdi.h>         /* VDI-Routinen */
#include "movelib.h"     /* Unterprogramm-Deklarationen */

/**********************************************************************/

/*+------------------------------------------------------------------+*/
/*| Erledigung der leidigen GEM-Initialisierung zu Anfang            |*/
/*+------------------------------------------------------------------+*/
int gem_init(void)
{
  int handle;
  int ap_id,work_in[12],work_out[57];
  int gr_1,gr_2,gr_3,gr_4, i;
  
  /* Applikation anmelden */
  ap_id = appl_init();
  
  /* war alles OK? */
  if (ap_id==-1)
    /* scheint nicht so */
    return(-2);
  else
  {
    /* scheinbar war alles OK! => VDI-Handle ermitteln */
  	handle = graf_handle(&gr_1,&gr_2,&gr_3,&gr_4);
	  
    for (i=0; i<10; work_in[i++]=1)
	    ;
    work_in[10] = 2;
    
    /* Virtual-Workstation îffnen */
    v_opnvwk(work_in, &handle, work_out);
    
    /* und das ermittelte Handle zurÅckliefern */
    return(handle);
  }
}

/*+------------------------------------------------------------------+*/
/*| Abmelden der Applikation vom GEM                                 |*/
/*+------------------------------------------------------------------+*/
void gem_exit(int handle)
{
  /* Virtual-Workstation schlieûen */
  v_clsvwk(handle);
  
  /* Applikation abmelden */
  appl_exit();
}

/**********************************************************************/

/*+------------------------------------------------------------------+*/
/*| Vorbereitungen zur Dialogbox-Darstellung                         |*/
/*+------------------------------------------------------------------+*/
void vor_dial(OBJECT *dialbox, int dialtype)
{
  GRECT a;
  int mx,my,dummy;
  GRECT desk;
  
  /* Fenstererneuerung */
  wind_update(BEG_UPDATE);
  
  switch (dialtype)
  {
    case 1: /* MOVEDIAL */
            /* war dies der erste Aufruf? */
            if ((dialbox->ob_x == 0) && (dialbox->ob_y == 0))
            {
              form_center(dialbox,&a.g_x,&a.g_y,&a.g_w,&a.g_h);
              dialbox->ob_x = a.g_x;      dialbox->ob_y = a.g_y;
              dialbox->ob_width = a.g_w;  dialbox->ob_height = a.g_h;
            }
            else
            {
              a.g_x = dialbox->ob_x;      a.g_y = dialbox->ob_y;
              a.g_w = dialbox->ob_width;  a.g_h = dialbox->ob_height;
            }
            break;
            
    case 2: /* POPUPDIAL */
            /* Mausposition ermitteln */
            dummy = evnt_button(1,1,0,&mx,&my,&dummy,&dummy);
            
            /* Grîûe des Desktop ermitteln */  
            wind_get(0,WF_WORKXYWH,&desk.g_x,&desk.g_y,&desk.g_w,&desk.g_h);
            
            /* X-Position der Dialogbox bestimmen */
            a.g_x = mx - (dialbox->ob_width / 2);
            /* ist sie innerhalb der Desktop-Grenzen? */
            if (a.g_x < desk.g_x)
              a.g_x = desk.g_x;
            if ((a.g_x + dialbox->ob_width) > (desk.g_x + desk.g_w))
              a.g_x = desk.g_w - dialbox->ob_width;
            /* Objekt-Position neu setzen */
            dialbox->ob_x = a.g_x;
            
            /* Y-Position der Dialogbox bestimmen */
            a.g_y = my - (dialbox->ob_height / 2);
            /* ist sie innerhalb der Desktop-Grenzen? */
            if (a.g_y < desk.g_y)
              a.g_y = desk.g_y;
            if ((a.g_y + dialbox->ob_height) > (desk.g_y + desk.g_h))
              a.g_y = desk.g_h - dialbox->ob_height;
            /* Objekt-Position neu setzen */
            dialbox->ob_y = a.g_y;
            
            break;
            
    default:/* STANDARDDIAL */
            /* Dialogbox zentrieren */
            form_center(dialbox,&a.g_x,&a.g_y,&a.g_w,&a.g_h);
            break;
  }
  
  /* Hintergrund reservieren */
  form_dial(FMD_START, a.g_x,a.g_y,a.g_w,a.g_h, a.g_x,a.g_y,a.g_w,a.g_h);
}
  
/*+------------------------------------------------------------------+*/
/*| Dialogbox zeichnen (nur nach 'vor_dial' aufrufen !!!)            |*/
/*+------------------------------------------------------------------+*/
void draw_dial(OBJECT *dialbox, int dialtype)
{
  GRECT a;
  
  switch (dialtype)
  {
    case 1: /* MOVEDIAL */
            a.g_x = dialbox->ob_x;      a.g_y = dialbox->ob_y;
            a.g_w = dialbox->ob_width;  a.g_h = dialbox->ob_height;
            break;
    case 2: /* POPUPDIAL */
            a.g_x = dialbox->ob_x;      a.g_y = dialbox->ob_y;
            a.g_w = dialbox->ob_width;  a.g_h = dialbox->ob_height;
            break;
    default:/* STANDARDDIAL */
            /* Dialogbox zentrieren */
            form_center(dialbox,&a.g_x,&a.g_y,&a.g_w,&a.g_h);
            break;
  }
  
  /* Dialogbox ausgeben */
  objc_draw(dialbox,ROOT,MAX_DEPTH,a.g_x,a.g_y,a.g_w,a.g_h);
}

/*+------------------------------------------------------------------+*/
/*| Nachbereitung der Dialogbox-Darstellung                          |*/
/*+------------------------------------------------------------------+*/
void nach_dial(OBJECT *dialbox, int dialtype)
{
  GRECT a;
  
  switch (dialtype)
  {
    case 1: /* MOVEDIAL */
            a.g_x = dialbox->ob_x;      a.g_y = dialbox->ob_y;
            a.g_w = dialbox->ob_width;  a.g_h = dialbox->ob_height;
            break;
    case 2: /* POPUPDIAL */
            a.g_x = dialbox->ob_x;      a.g_y = dialbox->ob_y;
            a.g_w = dialbox->ob_width;  a.g_h = dialbox->ob_height;
            break;
    default:/* STANDARDDIAL */
            /*   Dialogbox zentrieren */
            form_center(dialbox,&a.g_x,&a.g_y,&a.g_w,&a.g_h);
            break;
  }
  
  /*   Hintergrund freigeben */
  form_dial(FMD_FINISH, a.g_x,a.g_y,a.g_w,a.g_h, a.g_x,a.g_y,a.g_w,a.g_h);
  /*   Erneuerung beendet */
  wind_update(END_UPDATE);
}

/*+------------------------------------------------------------------+*/
/*| 'MOVEDIAL'-Box auf Desktop verschieben                           |*/
/*+------------------------------------------------------------------+*/
void movedial(OBJECT *dialbox, int dialtype)
{
  int nx,ny;
  GRECT desk;
  
  if (dialtype == 1)  /* es ist also eine 'MOVEDIAL'-Box */
  {
    wind_update(BEG_UPDATE);  /* Fenstererneuerung */
    wind_update(BEG_MCTRL);   /* Mauskontrolle */
    graf_mouse(FLAT_HAND,0);  /* Maus auf "flache Hand" */
    
    /* Grîûe des Desktop ermitteln */  
    wind_get(0,WF_WORKXYWH,&desk.g_x,&desk.g_y,&desk.g_w,&desk.g_h);

    /* Rechteck an neue Position verschieben */
    graf_dragbox(dialbox->ob_width, dialbox->ob_height,
                 dialbox->ob_x,     dialbox->ob_y,
                 desk.g_x,          desk.g_y,
                 desk.g_w,          desk.g_h,
                 &nx,&ny);
    
    /* Alte Object-Zeichnung lîschen (Speicher freigeben) */
    form_dial(FMD_FINISH, dialbox->ob_x,    dialbox->ob_y,
                          dialbox->ob_width,dialbox->ob_height,
                          dialbox->ob_x,    dialbox->ob_y,
                          dialbox->ob_width,dialbox->ob_height);
    
    /* Jetzt die Verschiebung in die OBJECT-Struktur eintragen */
    dialbox->ob_x += nx-dialbox->ob_x; 
    dialbox->ob_y += ny-dialbox->ob_y;
    
    /* Speicher an der neuen Position reservieren */
    form_dial(FMD_START, dialbox->ob_x,    dialbox->ob_y,
                         dialbox->ob_width,dialbox->ob_height,
                         dialbox->ob_x,    dialbox->ob_y,
                         dialbox->ob_width,dialbox->ob_height);
   
    graf_mouse(ARROW,0);      /* Maus wieder Pfeil */
    wind_update(END_MCTRL);   /* keine Mauskontrolle */
    wind_update(END_UPDATE);  /* Erneuerung beendet */
  }
}

/*+------------------------------------------------------------------+*/
/*| 'STANDARD' Dialog erledigen                                      |*/
/*+------------------------------------------------------------------+*/
int do_dial(OBJECT *tree)
{
  int ret;
  
  /* Vorbereitung */
  vor_dial(tree,0);
  
  /* DurchfÅhrung */
  draw_dial(tree,0);
  
  ret = form_do(tree,0);            /* dies erledigt das AES */
  tree[ret].ob_state &= ~SELECTED;  /* SELECTED zurÅcksetzen */

  /* Nachbereitung */  
  nach_dial(tree,0);  
  
  return(ret);
}

/*+------------------------------------------------------------------+*/
/*| 'MOVEDIAL' Dialog erledigen                                      |*/
/*+------------------------------------------------------------------+*/
int do_movedial(OBJECT *tree, int DRAGGER)
{
  int ret;
  
  /* Vorbereitung */
  vor_dial(tree,1);

  /* DurchfÅhrung */  
  do
  {
    /* Dialogbox ausgeben*/
    draw_dial(tree,1);
    
    ret = form_do(tree,0);            /* dies erledigt das AES */
    tree[ret].ob_state &= ~SELECTED;  /* SELECTED zurÅcksetzen */

    if (ret==DRAGGER)
      movedial(tree,1);
    
  } while (ret == DRAGGER);
  
  /* Nachbereitung */
  nach_dial(tree,1);  
  
  return(ret);
}

/*+------------------------------------------------------------------+*/
/*| 'POPUP' Dialog erledigen                                         |*/
/*+------------------------------------------------------------------+*/
int do_popup(OBJECT *tree)
{
  int ret;
  
  /* Vorbereitung */
  vor_dial(tree,2); 
  
  /* DurchfÅhrung */
  draw_dial(tree,2);
  
  ret = form_do(tree,0);            /* dies erledigt das AES */
  tree[ret].ob_state &= ~SELECTED;  /* SELECTED zurÅcksetzen */

  /* Nachbereitung */  
  nach_dial(tree,2);  
  
  return(ret);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~ ENDE von MYLIB.C ~~~~~~~~~~~~~~~~~~~~~~~~~*/