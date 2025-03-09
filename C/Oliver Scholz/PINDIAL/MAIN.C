/*
 * MAIN.C
 * "pinbare" Dialogboxen
 * by Oliver Scholz
 * Copyright (c) 1991 MAXON Computer
 */

#include <aes.h>
#include <portab.h>
#include <vdi.h>
#include <stdlib.h>

#include "defs.h"
#include "pindials.h"
#include "pindials.rsh"

#define GLOBAL
#include "globals.h"

extern VOID do_dial1(VOID);
extern VOID do_dial2(VOID);
extern VOID init_pins(VOID);
extern VOID open_window(VOID);
extern VOID wm_redraw(WORD whandle,WORD wx,
                      WORD wy,WORD ww,WORD wh);
extern VOID click_desktop(WORD index);

VOID initial_status(VOID);
VOID get_addresses(VOID);
OBJECT *get_traddr(WORD tree_index);
VOID open_vwork(WORD phys_handle);
VOID events(VOID);
WORD menu_selected(WORD *mesg_buff);

VOID main(VOID)
{
  WORD x,y,w,h;
  WORD phys_handle;
  
  if ((gl_apid=appl_init())<0)
  {
    form_alert(1,APP_NOT_STARTED);
    exit(-1);
  }

  initial_status();
  get_addresses();
  pin_unpinned = (BITBLK *) &rs_bitblk[0];
  pin_pinned = (BITBLK *) &rs_bitblk[1];
  init_pins();
  
  phys_handle=graf_handle(&dummy,&hchar,
                          &dummy,&dummy);
  open_vwork(phys_handle);
  vswr_mode(vdi_handle,MD_REPLACE);
  vsf_style(vdi_handle,19);
  vsf_perimeter(vdi_handle,TRUE);

  wind_update(BEG_UPDATE);
  HIDE_MOUSE;

  /* eigenes Desktop installieren */

  wind_get(DESKTOP,WF_WORKXYWH,&x,&y,&w,&h);
  newdesk[ROOT].ob_width=x+w;
  newdesk[ROOT].ob_height=h+y;
  wind_set(DESKTOP,WF_NEWDESK,newdesk,ROOT);
  objc_draw(newdesk,ROOT,MAX_DEPTH,x,y,w,h);

  window.handle=-1;     /* Fenster ist zu */  

  menu_bar(menu,TRUE);  /* MenÅzeile anzeigen */

  graf_mouse(ARROW,0L);
  SHOW_MOUSE;

  wind_update(END_UPDATE);

  open_window();
  events();                 /* Hauptschleife */

  /* Programm beenden, alle Fenster schlieûen */
  wind_update(BEG_UPDATE);
  HIDE_MOUSE;
  if (window.handle>=0)
  {
    wind_close(window.handle);
    wind_delete(window.handle);
  }
  menu_bar(menu,FALSE);
  rsrc_free();
  SHOW_MOUSE;
  wind_update(END_UPDATE);
  
  v_clsvwk(vdi_handle);
  appl_exit();
  exit(0);
}

/* Voreinstellung fÅr Textattribute */

VOID initial_status(VOID)
{
    status.font = PICA;
    status.kursiv = FALSE;
    status.fett = FALSE;
    status.leicht = FALSE;
    status.unterstrichen = FALSE;
}

/* Resource-Koordinaten umrechnen und */
/* Adressen der BÑume holen           */

VOID get_addresses(VOID)
{
  WORD i;
  
  for (i=0; i<NUM_OBS; i++)
    rsrc_obfix(rs_object,i);

  menu=get_traddr(MENU);
  newdesk=get_traddr(NEWDESK);
}


/* Adresse eines Baumes ermitteln */

OBJECT *get_traddr(WORD tree_index)
{
  WORD i,j;
  
  for (i=0,j=0; i<=tree_index; i++)
    while (rs_object[j++].ob_next!=-1);

  return(&rs_object[--j]); 
}

/* Workstation îffnen */

VOID open_vwork(WORD phys_handle)
{
  WORD i;
  static WORD work_in[12];
  static WORD work_out[57];

  for (i=1; i<10; i++)
    work_in[i]=1;
  work_in[10]=2;
  vdi_handle=phys_handle;
  v_opnvwk(work_in,&vdi_handle,work_out);
  
  xres=work_out[0]; /* Bildschirmgrîûe */
  yres=work_out[1];
}

/* Hauptschleife: Events behandeln */

VOID events(VOID)
{
  WORD exit_flag=FALSE;
  WORD events;
  WORD mesg_buff[8];
  WORD xmouse,ymouse,mbutton,clicks;
  WORD obj_idx;
  WORD click_window;

  do
  {
    events=evnt_multi(MU_MESAG | MU_BUTTON ,
            2, 1, 1,
            dummy,dummy,dummy,dummy,dummy,
            dummy,dummy,dummy,dummy,dummy,
            mesg_buff,
            0,0,
            &xmouse,&ymouse,&mbutton,
            &dummy,&dummy,&clicks);

    wind_update(BEG_UPDATE);
  
    if (events & MU_BUTTON)
    {
      HIDE_MOUSE;
      
      /* in welches Fenster wurde geclickt */
      click_window = wind_find(xmouse,ymouse);
      
      if (click_window == DESKTOP)
      {
        /* welches Objekt wurde angeclickt */
        obj_idx=objc_find(newdesk,ROOT,MAX_DEPTH,
                          xmouse,ymouse);
        
        if ((obj_idx != -1) && (clicks == 1))   
            click_desktop(obj_idx);

        /* warten, bis Knopf losgelassen wurde */
        evnt_button(1,1,0,&dummy,&dummy,
                    &dummy,&dummy);
      }
      
      if (click_window == window.handle)
      {
        /* in das Fenster geclickt: nichts tun */
      }
      SHOW_MOUSE;
    }
      
    if (events & MU_MESAG)
    {
      HIDE_MOUSE;
      switch (mesg_buff[0])
      {
        case MN_SELECTED:   
             exit_flag=menu_selected(mesg_buff);
             break;
             
        case WM_REDRAW:
             wm_redraw(mesg_buff[3],mesg_buff[4],
                       mesg_buff[5],mesg_buff[6],
                       mesg_buff[7]);
             break;           

        case WM_MOVED:
        case WM_SIZED:      
             wind_set(mesg_buff[3],WF_CURRXYWH,
                      mesg_buff[4],mesg_buff[5],
                      mesg_buff[6],mesg_buff[7]);
             break;
          
        case WM_NEWTOP:
        case WM_TOPPED:     
             wind_set(mesg_buff[3],WF_TOP);
             break;
      }
      SHOW_MOUSE;
    }
    wind_update(END_UPDATE);
  }
  while (!exit_flag);
}

/* ausgewÑhlten MenÅeintrag auswerten */

WORD menu_selected(WORD *mesg_buff)
{
  switch(mesg_buff[4])
  {
    case QUIT:  return(TRUE);
      
    case ABOUT: form_alert(1,ABOUT_PRG);
                break;
                
    case DIAL1: do_dial1();
                break;
                
    case DIAL2: do_dial2();
                break;
  }

  menu_tnormal(menu,mesg_buff[3],TRUE);
  return(FALSE);
}
