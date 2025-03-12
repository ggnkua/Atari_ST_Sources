
/*
 * TT44TT.C
 * Hauptmodul: Ereignisverwaltung und Dispatcher
 * Copyright (c) 1991 by MAXON
 * Autoren: Oliver Scholz & Uwe Hax
 */


#include <aes.h>
#include <portab.h>
#include <vdi.h>
#include <stdlib.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "tt44tt.h"
#include "termdefs.h"
#include "proto.h"
#include "tt44tt.rsh"

#define GLOBAL
#include "variable.h"


/*
 * Hauptprogramm...
 */

VOID main(VOID)
{
  WORD x,y,w,h;
  WORD i;
  WORD phys_handle;
  CHAR pathbuf[128];
  BCONMAP *bc;

  /* Programmstart und Initialisierung */
  if ((gl_apid=appl_init())<0)
  {
    form_alert(1,APP_NOT_STARTED);
    exit(-1);
  }

  wind_get(DESKTOP,WF_WORKXYWH,&x,&y,&w,&h);
  phys_handle=graf_handle(&wchar,&hchar,
             &wbox,&hbox);
  open_vwork(phys_handle);
  vqt_fontinfo(vdi_handle,&dummy,&dummy,
           distances,&dummy,effects);
  vswr_mode(vdi_handle,MD_REPLACE);

  strcpy(inf_path,"A:");
  inf_path[0]=(CHAR)(Dgetdrv()+('A'));
  Dgetpath(pathbuf,0);
  strcat(inf_path,pathbuf);
  strcat(inf_path,"\\*.INF");
  strcpy(inf_name,"TT44TT.INF");
    
  get_tos_version();
  get_addresses();
  
  if (tos_version>=0x200)
  {
    aux_offset=6;
    bc=(BCONMAP *)Bconmap(-2);
    num_aux=bc->maptabsize;
    if (num_aux==3)
    { /* Mega STE */
      iconlist[2]=SCC1;
      iconlist[3]=MFP2;
      strcpy(window[2].title,window[3].title);
    }
                                    
    /* LAN-Port aktiv: eine weniger... */
    if (!(Giaccess(0,14) & 0x80))
      num_aux--;
  }  
  else
  {
    num_aux=1;
    aux_offset=1;
  }
  
  /* nicht ben”tigte Icons ausblenden */
  for(i=num_aux;i<4;i++)
    newdesk[iconlist[i]].ob_flags |= HIDETREE; 

  init_ports(port);

  for(i=0; i<num_aux; i++)
  {
    write_port(i);
    wind_info(i);
    init_terminal(i);
  }
  
  wind_update(BEG_UPDATE);
  hide_mouse();

  /* eigenes Desktop installieren */
  newdesk[ROOT].ob_width=x+w;
  newdesk[ROOT].ob_height=h+y;
  wind_set(DESKTOP,WF_NEWDESK,newdesk,ROOT);
  objc_draw(newdesk,ROOT,MAX_DEPTH,x,y,w,h);

  /* Menzeile anzeigen */
  ienable(FALSE);
  menu_icheck(menu,ZOOM,zoomflag);
  menu_bar(menu,TRUE);

  loadinf("TT44TT.INF",1);

  graf_mouse(ARROW,0L);
  show_mouse();
  wind_update(END_UPDATE);
  
  events();    /* Hauptschleife */
  
  /* Programm beenden, alle Fenster schliežen */
  wind_update(BEG_UPDATE);
  hide_mouse();
  for (i=0; i<4; i++)
    if (window[i].handle>=0)
    {
      wind_close(window[i].handle);
      wind_delete(window[i].handle);
    }
  menu_bar(menu,FALSE);
  rsrc_free();
  show_mouse();
  wind_update(END_UPDATE);
  
  v_clsvwk(vdi_handle);
  appl_exit();
  exit(0);
}


/*
 * Workstation ”ffnen
 */

VOID open_vwork(WORD phys_handle)
{
  WORD i;
  static WORD work_in[12];
  static WORD work_out[57];

  for (i=0; i<10; i++)
    work_in[i]=1;
  work_in[10]=2;
  vdi_handle=phys_handle;
  v_opnvwk(work_in,&vdi_handle,work_out);
}


/*
 * Resource-Koordinaten umrechnen und
 * Adressen der B„ume holen
 */

VOID get_addresses(VOID)
{
  WORD i;
  
  for (i=0; i<NUM_OBS; i++)
    rsrc_obfix(rs_object,i);

  menu=get_traddr(MENU);
  newdesk=get_traddr(NEWDESK);
  port_dial=get_traddr(PORTS);
  info_box=get_traddr(ABOUTBOX);
}


/*
 * Adresse eines Baumes ermitteln
 */

OBJECT *get_traddr(WORD tree_index)
{
  WORD i,j;
  
  for (i=0,j=0; i<=tree_index; i++)
    while (rs_object[j++].ob_next!=-1);

  return(&rs_object[--j]);    
}


/*
 * Hauptschleife: Events behandeln
 */

VOID events(VOID)
{
  WORD exit_flag=FALSE;
  WORD events;
  WORD mesg_buff[8];
  WORD xmouse,ymouse,mbutton,clicks;
  WORD iconidx,i,j;
  WORD key;
    
  do
  {
    events=evnt_multi(MU_MESAG | MU_BUTTON |
            MU_KEYBD | MU_TIMER,2,1,1,
            dummy,dummy,dummy,dummy,dummy,
            dummy,dummy,dummy,dummy,dummy,
            mesg_buff,
            100,0, /* Timerkonstante 100ms */
            &xmouse,&ymouse,&mbutton,
            &dummy,&key,&clicks);

    wind_update(BEG_UPDATE);
  
    if (events & MU_TIMER)
      for (i=0; i<num_aux; i++)
        if (Bconstat(i+aux_offset))
        {
          hide_mouse();
          do_output(i);
          show_mouse();
        }

    if (events & MU_KEYBD)
    {
      hide_mouse();
      key &= 0xff;
      if (key && (top_window >= 0))
      {
        Bconout(aux_offset+top_window,key);
        if (key == CR)
          Bconout(aux_offset+top_window,LF);
      }
      show_mouse();
    }        

    if (events & MU_BUTTON)
    {
      hide_mouse();
      if (wind_find(xmouse,ymouse)==DESKTOP)
      {
        /* Icon-Behandlung */
        iconidx=objc_find(newdesk,ROOT,MAX_DEPTH,
                xmouse,ymouse);
        
        curr_icon=-1;
        curr_device=top_window;
        
        for (i=0; i<4; i++)
        {
          if (newdesk[iconlist[i]].ob_state
              & SELECTED)
          {
            newdesk[iconlist[i]].ob_state &=
                ~SELECTED;
            draw_icon(iconlist[i]);
          }
          if (iconidx==iconlist[i])
            curr_icon=i;
        }
        
        if (curr_icon != -1)    
          if (clicks==1)  /* einfacher Click */
          {
            newdesk[iconidx].ob_state |=SELECTED;
            draw_icon(iconidx);
            curr_device=curr_icon;
          } 
          else            /* Doppelclick */
          {
            j=curr_icon;
            curr_icon=-1;
            open_window(j);
          }

        if (curr_device==-1)
          ienable(FALSE);
        else
          ienable(TRUE);
 
        evnt_button(1,1,0,&dummy,
                    &dummy,&dummy,&dummy);
      }
      show_mouse();
    }
      
    if (events & MU_MESAG)
    {
      hide_mouse();
      switch (mesg_buff[0])
      {
        case WM_REDRAW:
             wm_redraw(mesg_buff[3],mesg_buff[4],
                       mesg_buff[5],mesg_buff[6],
                       mesg_buff[7]);
             break;           

        case WM_MOVED:
             wm_moved(mesg_buff);
             break;
          
        case WM_SIZED:      
             wm_sized(mesg_buff);
             break;
          
        case WM_NEWTOP:
        case WM_TOPPED:     
             wm_topped(mesg_buff[3]);
             break;

        case WM_CLOSED:     
             wm_closed(mesg_buff[3]);
             break;

        case WM_FULLED:
             wm_fulled(mesg_buff);
             break;
         
        case WM_ARROWED:
             wm_arrowed(mesg_buff);
             break;
                                     
        case WM_VSLID:
             wm_vslid(mesg_buff);
             break;
                            
        case WM_HSLID:
             wm_hslid(mesg_buff);
             break;               
     
        case MN_SELECTED:   
             exit_flag=mn_selected(mesg_buff);
             break;
      }
      show_mouse();
    }
    wind_update(END_UPDATE);
  }
  while (!exit_flag);
}


/*
 * ein Icon zeichnen, dabei Rechteckliste
 * des Desktops beachten
 */

VOID draw_icon(WORD iconidx)
{
  GRECT t1,t2;
 
  objc_offset(newdesk,iconidx,&t2.g_x,&t2.g_y);
  t2.g_w=newdesk[iconidx].ob_width;
  t2.g_h=newdesk[iconidx].ob_height;

  wind_get(DESKTOP,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,
           &t1.g_w,&t1.g_h);
  while (t1.g_w && t1.g_h)
  {
    if (rc_intersect(&t2,&t1))
      objc_draw(newdesk,iconidx,MAX_DEPTH,
                t1.g_x,t1.g_y,t1.g_w,t1.g_h);
    wind_get(DESKTOP,WF_NEXTXYWH,&t1.g_x,&t1.g_y,
             &t1.g_w,&t1.g_h);
  }
}


/*
 * die abschaltbaren Meneintr„ge ein/ausschalten
 */

VOID ienable(WORD flag)
{
    menu_ienable(menu,PORT,flag);
    menu_ienable(menu,OPEN,flag);
    menu_ienable(menu,CLOSE,flag);
}


/*
 * angew„hlten Meneintrag auswerten
 */

WORD mn_selected(WORD *mesg_buff)
{
  WORD temp,button;
  CHAR path[128],*ptr;
  
  switch(mesg_buff[4])
  {
    case LOADINF:  /* Inf-Datei laden */
        fileselect(inf_path,inf_name,&button,
                   "INF Datei laden");
        if (button)
        {
          strcpy(path,inf_path);
          ptr=strrchr(path,'\\');
          if (ptr)
            *(ptr+1)=EOS;
          strcat(path,inf_name);
          loadinf(path,0);
        }
        break;
                
    case SAVEINF:  /* Inf-Datei speichern */
        fileselect(inf_path,inf_name,&button,
                   "INF Datei sichern");
        if (button)
        {
          strcpy(path,inf_path);
          ptr=strrchr(path,'\\');
          if (ptr)
            *(ptr+1)=EOS;
          strcat(path,inf_name);
          saveinf(path);
        }
        break;

    case ZOOM:  /* Zoomboxen */
        zoomflag = (!zoomflag);
        menu_icheck(menu,ZOOM,zoomflag);
        break;
                
    case OPEN:  /* Fenster ”ffnen */  
        if (curr_icon!=-1)
        {
          temp=curr_icon;
          curr_icon=-1;
          open_window(temp);      
          newdesk[iconlist[temp]].ob_state &=
                 ~SELECTED;            
          draw_icon(iconlist[temp]);     
        }
        break;
                
    case CLOSE:  /* Fenster schliežen */
        if (curr_icon!=-1)
        {
          temp=curr_icon;
          curr_icon=-1;
          if (window[temp].handle!=-1)
            wm_closed(window[temp].handle);
          newdesk[iconlist[temp]].ob_state &=
                  ~SELECTED;
          draw_icon(iconlist[temp]);
        }
        else
        {
          if (window[top_window].handle!=-1)
            wm_closed(window[top_window].handle);
        }
        break;

    case QUIT:  /* Program beenden */
        return(TRUE);
      
    case ABOUT:  /* About-Dialog anzeigen */
        show_info();
        break;

    case PORT:  /* Port konfigurieren */
        read_port(curr_device);
        if (conf_port(&port[curr_device]))
        {
          write_port(curr_device);
          wind_info(curr_device);
        }
        if (curr_icon!=-1)
        {
          newdesk[iconlist[curr_icon]].ob_state 
            &= ~SELECTED;            
          draw_icon(iconlist[curr_icon]);
          curr_icon=-1;
          curr_device=top_window;
        }
        break;
  }
  menu_tnormal(menu,mesg_buff[3],TRUE);
  return(FALSE);
}


/*
 * Programminfo ausgeben
 */

VOID show_info(VOID)
{
  WORD cx,cy,cw,ch;

  form_center(info_box,&cx,&cy,&cw,&ch);
  form_dial(FMD_START,cx,cy,cw,ch,cx,cy,cw,ch);

  objc_draw(info_box,ROOT,MAX_DEPTH,cx,cy,cw,ch);

  show_mouse();
  form_do(info_box,0);
  hide_mouse();

  info_box[ABOUTOK].ob_state &= ~SELECTED;

  form_dial(FMD_FINISH,cx,cy,cw,ch,cx,cy,cw,ch);
}


/*
 * je nach TOS-Version andere Fileselectbox
 * aufrufen
 */ 

WORD fileselect (CHAR *inpath, CHAR *insel,
                 WORD *exbutton, CHAR *label)
{
    WORD retcode;
    show_mouse();

    if (tos_version > 0x104)
      retcode=fsel_exinput( inpath,
              insel, exbutton, label );
    else
      retcode=fsel_input(inpath,insel,exbutton);

    hide_mouse();
    return(retcode);
}


/*
 * Tos-Version ermitteln
 */

VOID get_tos_version(VOID)
{ 
  VOID *_ssp;
  SYSHDR **hdr;
  
  _ssp=(VOID*) Super(0L);
  hdr=(SYSHDR **)_sysbase;
  tos_version=(*hdr)->os_version;
  Super(_ssp);
}


/*
 * INF-Datei schreiben
 */

VOID saveinf(CHAR *pfad)
{
  WORD handle,error,i;

  error=FALSE;

  for (i=0; i<4; i++)
    if (window[i].handle >= 0)
      wind_get(window[i].handle,WF_CURRXYWH,
               &window[i].x,&window[i].y,
               &window[i].w,&window[i].h);
      
  if ((handle=Fcreate(pfad,0)) >= 0 )
  {
    if (Fwrite(handle,sizeof(CONF_RS)*4,&port) ==
       (sizeof(CONF_RS)*4)) 
      if (Fwrite(handle,sizeof(WINDOW)*4,&window)
          == (sizeof(WINDOW)*4))
      {
        if (Fwrite(handle,sizeof(WORD),&zoomflag)
           !=(sizeof(WORD)))
          error=TRUE;
      }
      else 
        error=TRUE;
    else
      error=TRUE;
    Fclose(handle);
  }
  else 
    error=TRUE;
 
 if (error)
   form_alert(1,INF_WRERR);
}


/*
 * INF Datei lesen
 */

VOID loadinf(CHAR *pfad,WORD init)
{
  WORD handle,error,i;
  CONF_RS lport[4];
  WINDOW lwindow[4];

  error=FALSE;

  if ((handle=Fopen(pfad,0)) >= 0 )
  {
    if (Fread(handle,sizeof(CONF_RS)*4,&lport)==
       (sizeof(CONF_RS)*4)) 
      if (Fread(handle,sizeof(WINDOW)*4,&lwindow)
         ==(sizeof(WINDOW)*4))
      {
        if (Fread(handle,sizeof(WORD),&zoomflag)
           !=(sizeof(WORD)))
          error=TRUE;
      }
      else 
        error=TRUE;
    else
      error=TRUE;

    Fclose(handle);
  }
  else
    error=TRUE;
 
 if (error && !init)
   form_alert(1,INF_RDERR);

  if (!error)
  {
    for (i=0;i<num_aux;i++)
    {
      if (window[i].handle != -1)
        wm_closed(window[i].handle);
      port[i]=lport[i];
      write_port(i);
        
      window[i]=lwindow[i];
      window[i].fulled = FALSE;
      wind_info(i);
        
      if (window[i].handle != -1)
      {
        window[i].handle = -1;
        open_window(i);
      }
    }
    menu_icheck(menu,ZOOM,zoomflag);
 }
}


/*
 * Bconmap fr alle!
 */

LONG _bconmap(WORD devno)
{
  LONG old;
  
  if (tos_version>=0x200)
    old=Bconmap(devno);
  else
    old=1L;  /* AUX */
    
  return(old);
}



