/********************************************************************
 *
 *  multi.c		projekt : xcarpet
 *-------------------------------------------------------------------
 *  evnt_multi()-auswertung
 *-------------------------------------------------------------------
 *
 *******************************************************************/
 
 /*  april 88	Åbernahme der quelle 'carpet.c' von tony przygienda
  *  13. 5.	auslagerung von 'multi.c'
  *   5. 6.	V1.3	daten von/zur ascii-datei
  */

#include "..\carpet.h"
#include <portab.h>
#include <stdio.h>
	
#if COMPILER==MEGAMAX
	#include <obdefs.h>
	#include <gemdefs.h>
#endif
#if COMPILER==TURBOC
	#include "..\multi.h"
	#include <aes.h>
	#include <vdi.h>
	#include <string.h>
#endif


extern int xdesk,ydesk;

	/* import der resource-variablen vom modul initexit	*/
extern int vpulldown, vtinfo, vtdata, vtaction, vtconst, vthelp; 
extern int vinfo,vmyname;

extern int vminfo;
extern int vmfile, vmsavemode, vmsave;
extern int vinputfun,vfunc1,vfunc2;

extern int vmdrawf, vmhardcopy, vmexit;
extern int vdrawfun;

extern int vmrotate,vmview,vmlight,vmresol,vmdrawmode,vmdegree,vmradiant;
extern int vrotation,vview,vlight,vdrawmode;

extern int vresoluti,vmhstad,vmhfunc,vmhspecf,vmhrotate,vmhview,vmhresol,vmhdraw; 
extern int vhfunct,vhrotate,vhprojekt,vhresol,vhdraw,vhspecf,vhstad;

extern int vsyserror,vqsyserr,vsavefun;
extern int vicons,vdesktop,visave,viinputf,vidrawf,virotate,vilight,viview,viresol,vistyle;
extern int vmemostat,vhelpkey;

extern char    func_string[];
extern char    pic_format;
extern boolean degree,central,shadowed,counted2d,counted3d,countedfl,  
               funcgiven,filegiven,funcinput;
extern int     drawmode;
extern long    screenbytes;
extern WORD    handle,wi_handle,top_window;
extern OBJECT  *menu_tree,*icons_tree;
extern FDB     source,target;
extern boolean error; 
extern char    *terrorstring;

extern int  xdesk,ydesk,hdesk,wdesk;
extern int  xwork,ywork,hwork,wwork;
extern int  xpict,ypict,hpict,wpict;

extern double  xangle,zangle;
#if COMPILER==TURBOC
	#include "..\initexit.h"
	#include "..\inout.h"	
	#include "..\tree.h"
	#include "..\gemhelp.h"
	#include "..\icondesk.h"
	#include "..\xcarpet.h"
	#include "..\calc.h"
	#include "..\fileio.h"
#endif


	/* makros zur und funktionen zur menÅ-manipulation	*/
#define selectoff(a,b)  switch_icon(a,0),disable(b)
#define selecton(a,b)   switch_icon(a,1), enable(b) 

#define TITLE	msgbuff [3]
#define ITEM	msgbuff [4]

void check   (item) int item;   { menu_icheck  (menu_tree, item, 1);  }
void uncheck (item) int item;   { menu_icheck  (menu_tree, item, 0);  }
void enable  (item) int item;   { menu_ienable (menu_tree, item, 1);  }
void disable (item) int item;   { menu_ienable (menu_tree, item, 0);  }

static void dialog (box)
  int box;
{
  OBJECT *dial_adr;

  rsrc_gaddr (R_TREE,box,&dial_adr);
  undo_obj(dial_adr,hndl_dial(dial_adr,0,xdesk/2,ydesk/2,1,1),SELECTED);
}


#define ICONTEST		FALSE
#define KEYTEST		FALSE

void multi()
{
#if COMPILER==TURBOC
	void dialog(int);
#endif

register int      event;
OBJECT            *dial_adr;    /* fÅr Dialoge mit Programm */
WORD              msgbuff[8];   /* event message buffer */
int               keycode;      /* keycode returned by event-keyboard */
int               mx,my;        /* mouse x and y pos. */
int               ret;          /* dummy return variable */
boolean           qflag=FALSE;  /* if true = leave programm */
boolean           restoreflag;  /* whether restore the whole window or not */
boolean           inputgiven=((funcinput && funcgiven)||(!funcinput && filegiven));
WORD              mclicks;
int               xmid,ymid;
int               sicher;

xmid=xdesk/2;
ymid=ydesk/2;

				/* no function at the begin */
selectoff(vidrawf,vmdrawf);
selectoff(virotate,vmrotate);
selectoff(vilight,vmlight);
selectoff(viview,vmview);
selectoff(viresol,vmresol);
selectoff(vistyle,vmdrawmode);

do
   {
   update_memostat();
#if ICONTEST
	printf("mask:%x \n",MU_MESAG | MU_KEYBD | MU_BUTTON);
#endif
   event = evnt_multi( MU_MESAG | MU_KEYBD | MU_BUTTON ,
         2,3,1,   /* beide Knoepfe */
         0,0,0,0,0,
         0,0,0,0,0,
         msgbuff,0,0,&mx,&my,&ret,&ret,&keycode,&mclicks);

#if ICONTEST
	printf("%x ",event);
#endif
   wind_update(BEG_UPDATE);
   wind_get(wi_handle,WF_TOP,&top_window,&ret,&ret,&ret);
   /* WHO IS TO BE SERVED ?, CAN BE AN ACCESSORY */

     
   if ((event & MU_KEYBD) && !(event & MU_MESAG) && (top_window==wi_handle))
         /* Wandle TastendrÅcke in MenÅwahl -> Trick */
      {
      event=MU_MESAG; /* nachfÑlschen des WÑhlens eines Eintrags ! */
      msgbuff[0]=MN_SELECTED; TITLE=0; /* zur Unterscheidung ! */
      switch(keycode & 0xFF)
         {
         case 19: /* ^S */
            TITLE=vtdata; ITEM=vmsave;
            break;
         case 15: /* ^O */
         	TITLE=vtdata; ITEM=vmsavemode;
         	break;
         case 17: /* ^Q */
            /* flow through */
         case 24: /* ^X */
            TITLE=vtaction; ITEM=vmexit;
            break;                     
         case 9: /* ^I */
            TITLE=vtdata; ITEM=vmfunc;
            break; 
         case 12: /* ^L */
            TITLE=vtdata; ITEM=vmfile;
            break; 
         case 26: /* ^Z */
            if (inputgiven)
               { TITLE=vtaction; ITEM=vmdrawf; }
            break; 
         case 18: /* ^R */
            if (inputgiven)
               { TITLE=vtconst; ITEM=vmrotate; }
            break;                
         case 16: /* ^P */
            if (inputgiven && central)
               { TITLE=vtconst; ITEM=vmview; }
            break;                      
         case 1: /* ^A */
            if (funcgiven)    /* Auflîsung nur bei eingetippter Funktion */
               { TITLE=vtconst; ITEM=vmresol; }
            break;
         case 2: /* ^B */
            if (inputgiven && (drawmode==SHADOW))
               { TITLE=vtconst; ITEM=vmlight; }
            break;
         case 4: /* ^D */
            if (inputgiven)
               { TITLE=vtconst; ITEM=vmdrawmode; }
            break;
         default: /* show key */
#if KEYTEST
			printf("Key number $%4x\n",keycode);
#endif
			break;
         } /* any other ignore */  
      if (TITLE)
         menu_tnormal(menu_tree,TITLE,0); /* einschalten dazu */
      }

   if ((event & MU_BUTTON) && !(event & MU_MESAG) && (top_window==wi_handle))
      {
      int obj_found= -1;
      /* mouse button event, handles icons */
#if ICONTEST            
      puts("Im mu_button\n");      
#endif
      if (!wind_find(mx,my)) /* no window below mouse ? */
#if ICONTEST
      	puts("nach wind find\n");
#endif
         if (mclicks==2) /* single one */
            {
            icons_deselect();
            obj_found=objc_find(icons_tree,0,10,mx,my);
            if ((obj_found!=-1) && (obj_found!=vdesktop) &&
            	 (obj_found != vmemostat))
               {
               icon_select(obj_found);            
               event=MU_MESAG; /* nachfÑlschen des WÑhlens eines Eintrags ! */
               msgbuff[0]=MN_SELECTED; TITLE=0; /* zur Unterscheidung ! */
               if (obj_found== visave) 
                  { 
                  TITLE=vtdata; ITEM=vmsave;
                  }
               else if (obj_found== viinputf) 
                  { 
                  TITLE=vtdata; ITEM=vmfunc;
                  } 
               else if (obj_found== vidrawf) 
                  {
                  if (inputgiven)
                     { TITLE=vtaction; ITEM=vmdrawf; }
                  } 
               else if (obj_found== virotate) 
                  {
                  if (inputgiven) 
                     { TITLE=vtconst; ITEM=vmrotate; }
                  }                
               else if (obj_found== viview) 
                  { 
                  if (inputgiven && central)
                     { TITLE=vtconst; ITEM=vmview; }
                  }                      
               else if (obj_found== viresol) 
                  { 
                  TITLE=vtconst; ITEM=vmresol;
                  }
               else if (obj_found== vilight) 
                  { 
                  if (inputgiven && drawmode==SHADOW)
                     { TITLE=vtconst; ITEM=vmlight; }
                  }
					else if (obj_found== vistyle)  
						{       
                  if (inputgiven)
               		{ TITLE=vtconst; ITEM=vmdrawmode; }
            		}
               else
                  {
                  puts("Unkown ICON selected\n");
                  } /* any other ignore */  
               if (TITLE)
                  menu_tnormal(menu_tree,TITLE,0); /* einschalten dazu */  
               }
            }
         else /* 1 click */
            {
            int gr_mkmstate;

            icons_deselect();
            obj_found=objc_find(icons_tree,0,10,mx,my);
            if ((obj_found!=-1) && (obj_found!=vdesktop))
               {
               if (obj_found!=vmemostat)
               	icon_select(obj_found);
               graf_mkstate(&mx,&my,&gr_mkmstate,&ret);
               if (gr_mkmstate)
                  {
                  /* Bewegen des Piktogramms */
                  objc_offset(icons_tree,obj_found,&mx,&my);
                  graf_dragbox(icons_tree[obj_found].ob_width,
                            icons_tree[obj_found].ob_height,
                            mx,my, /* screen coord of icon */
                            xdesk,ydesk,wdesk,hdesk, &mx, &my);  
                  mx&=~7; my&=~7; /* byte boundary */                          
                  move_icon(obj_found,mx,my);
                  }
               }
            }   
         /* no window found ? */
      }   

   if (event & MU_MESAG) /* Nachricht ? Window ? */
      switch (msgbuff[0]) 
         {
         case WM_REDRAW:
            if (TITLE == wi_handle)   /* NOT SO CLEAR */
               {
               do_redraw(ITEM,msgbuff[5],msgbuff[6],msgbuff[7]);
               set_clip(xwork,ywork,wwork-1,hwork-1);
               }
            break;
         case WM_TOPPED:
         if (TITLE == wi_handle)   /* NOT SO CLEAR */
               {
               wind_set(wi_handle,WF_TOP,0,0,0,0);
               hslidesize();
               hslidepos();
               vslidesize();
               vslidepos();
               }
            break;   
         case WM_MOVED:
         if (TITLE == wi_handle)   /* NOT SO CLEAR */
               {
               if (msgbuff[6]+ITEM>wdesk)
                  ITEM=max(xdesk,xdesk+wdesk-msgbuff[6]);
               if (msgbuff[7]+msgbuff[5]>hdesk)
                  msgbuff[5]=max(ydesk,ydesk+hdesk-msgbuff[7]);
               /* because if he moves the window out of screen, the */
               /* draw can't use the whole area of the window */
               wind_set(wi_handle,WF_CURRXYWH,ITEM,msgbuff[5],
                           msgbuff[6],msgbuff[7]);
               wind_get(wi_handle,WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
               counted2d=FALSE;
               }
            break; /* it was easy */
         case WM_SIZED:
         	if (TITLE == wi_handle)   /* NOT SO CLEAR */
               {
               /* rather cruel */
               wind_set(wi_handle,WF_CURRXYWH,ITEM,msgbuff[5],
                           msgbuff[6],msgbuff[7]);
               wind_get(wi_handle,WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
               restoreflag=FALSE; /* not needed */
               if ((wpict-xpict<wwork) && xpict>0)
                  /* he pulled the window's size over the picture */
                  {
                  xpict=max(0,wpict-wwork); 
                  restoreflag=TRUE;
                  }
               if ((hpict-ypict<hwork) && ypict>0)
                  {
                  ypict=max(0,hpict-hwork);
                  restoreflag=TRUE;
                  }
               if (hpict!=hwork || wpict!=wwork)
                  {
                  restoreflag=TRUE;
                  counted2d=FALSE;
                  }
               /* now redraw the whole window, in case I moved the picture */
               /* in the window, but do not, if he only made it bigger ->  */
               /* GEM will give the restore message anyway as event */
               hslidesize();
               hslidepos();
               vslidesize();
               vslidepos(); 
               if (restoreflag)
                  full_update();
               }
            break;
         case WM_HSLID:
            if (wwork<wpict)
               {
               xpict=(int) (((double) ITEM/1000.)*(wpict-wwork));
               full_update();
               hslidepos();
               }
            break;
         case WM_VSLID:
            if (hwork<hpict)
               {
               ypict=(int) (((double) ITEM/1000.)*(hpict-hwork));
               full_update();
               vslidepos();
               }
            break;
         case WM_ARROWED:
            switch(ITEM)
               {
               case 0: /* page up */
                  ypict-=hpict/10;
                  if (ypict<0)
                     ypict=0;
                  break;
               case 1: /* page down */
                  ypict+=hpict/10;
                  if (ypict+hwork>hpict)
                     ypict=max(0,hpict-hwork);
                  break;
               case 4: /* page left */
                  xpict-=wpict/10;
                  if (xpict<0)
                     xpict=0;
                  break;
               case 5: /* page right */
                  xpict+=wpict/10;
                  if (xpict+wwork>wpict)
                     xpict=max(0,wpict-wwork);
                  break;
               /* row scrolling should never happen <- no arrows */
               }
            full_update();
            hslidepos();
            vslidepos(); 
            break;   
         case MN_SELECTED:
            if (TITLE == vtinfo) 
               { /* Info Zeile */
               if (ITEM==vminfo) /* Eintrag */
                  {
                  dialog (vinfo);
                  }
               }
            else if (TITLE == vtdata) 
               {
					if (ITEM == vmsavemode)
						{
						dialog(vsavemode);
						read_savemode();
						write_savemode();
						}
               else if (ITEM == vmsave) 
                  {
                  if (pic_format != FASCII)
                    save_screen();
                  else
                    {
                    if (! counted3d)
                      normal_error ("Es liegen keine gÅltigen Daten vor!");
                    else if (!out_filename())
                      ;
                    else
                      {
                      if (!write_header())
                        normal_error("Fehler bei Header-Ausgabe!");
                      else
                        write_data();
                      }
                    }
                  }
               else if (ITEM == vmfile)
                  {
                  if (!inp_filename())
                    ;
                  else if (!read_header())
                    {
                    normal_error ("Datei-Header fehlerhaft!");
                    filegiven = FALSE;
                    }
                  else
                    {
                    filegiven = TRUE;
                    funcinput = FALSE;
              		  funcgiven = FALSE;
                    counted3d=counted2d=FALSE;
                    }
                  }
               else if (ITEM == vmfunc) 
                  {
                  dialog (vinputfun);
                  
                  /* alle Werte auslesen */   
                  read_forminp();
                  write_forminp();    
                                          
                  /* string zusammensetzen */
                  rsrc_gaddr(R_TREE,vinputfun,&dial_adr);
                  strcpy(func_string,
                  ((TEDINFO *) dial_adr[vfunc1].ob_spec)->te_ptext);
                  strcpy(&(func_string[strlen(func_string)]),
                  ((TEDINFO *) dial_adr[vfunc2].ob_spec)->te_ptext);
                  give_function(func_string,&terrorstring);
                  if (!error)
                     {
                     read_resolution();	/* nach dateieingabe verÑndert */
  							write_resolution();
                     funcgiven=TRUE;
                     funcinput=TRUE;
                     counted3d=counted2d=FALSE;
                     }
                  else
                     {
                     normal_error(terrorstring);
                     funcgiven=FALSE;
                     funcinput=FALSE;
                     }
                  error=FALSE;
                  }
               }     
            else if (TITLE == vtaction) 
               {
               if (ITEM == vmdrawf) 
                  {
                  if (inputgiven)
                     {
                     WORD xdial,ydial,wdial,hdial;

                     if ((!counted3d) || (!counted2d) ||
                        ((drawmode!=WIREFRAME) && (!countedfl)) ||
                        ((drawmode==SHADOW) && (!shadowed)))
                        {                        
                        wind_get(wi_handle,WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
                        set_clip(xwork,ywork,wwork-1,hwork-1);
                        wpict=wwork; hpict=hwork; 
                        xpict=ypict=0;
                        rsrc_gaddr(R_TREE,vdrawfun,&dial_adr);
                        form_center(dial_adr,&xdial,&ydial,
                                    &wdial,&hdial);
                        form_dial(FMD_START,xmid,ymid,1,1,
                                      xdial,ydial,wdial,hdial);
                        form_dial(FMD_GROW,xmid,ymid,1,1,
                                      xdial,ydial,wdial,hdial);
                        calc_function(xdial,ydial,wdial,hdial);
                        form_dial(FMD_SHRINK,xmid,ymid,1,1,
                                       xdial,ydial,wdial,hdial);
                        form_dial(FMD_FINISH,xmid,ymid,1,1,
                                       xdial,ydial,wdial,hdial);
               
                        } /* end if needed at all */
                     wind_get(wi_handle,WF_TOP,&top_window,&ret,&ret,&ret);
                     if (top_window==wi_handle && counted3d)
                        {
                        register BYTE *clearer=(BYTE *) target.fd_addr; 
                        register long runner;                                

                        hide_mouse();
                        clearer=(BYTE *) target.fd_addr;
                        for(runner=0;runner<screenbytes;runner++)
                           *(clearer++)='\0'; /* i hope 0 is no colour */
                        vsf_interior(handle,1);
                        vsf_color(handle,0);
                        bar(xwork,ywork,wwork+xwork,ywork+hwork);
                        draw_function();
                        hslidesize();
                        hslidepos();
                        vslidesize();
                        vslidepos();    /* has to be done, too */
                        show_mouse();
                        }
                     else
                        wind_set(wi_handle,WF_TOP,0,0,0,0);
                     }   
                  }
               else if (ITEM == vmhardcopy)
                  {
                  hard_copy ();
                  }
               else if (ITEM ==  vmexit) 
                  {
                  if (form_alert(1,
    "[2][CARPET DESIGNER wirklich|     verlassen ?][ Irrtum | Klar ]"
                         )==2)
                     qflag=TRUE;
                  }
      
               }
            else if (TITLE == vtconst) 
               {
               if (ITEM == vmrotate) 
                  {
                  dialog (vrotation);
                  read_rotate();
                  write_rotate();
                  counted3d=counted2d=FALSE;
                  }
               else if (ITEM == vmview) 
                  {
                  dialog (vview);
                  read_view();
                  write_view();
                  if (central)
                     counted2d=FALSE;
                  }
               else if (ITEM == vmlight) 
                  {
                  dialog (vlight);
                  read_light();
                  write_light();
                  }
               else if (ITEM == vmresol) 
                  {
                  dialog (vresoluti);
                  read_resolution();
                  write_resolution();
                  counted2d=counted3d=FALSE;
                  }
               else if (ITEM == vmdrawmode)
                  {
                  sicher=central;
                  dialog (vdrawmode);
                  read_drawmode();
                  write_drawmode();
                  if (sicher != central)
                    counted2d=FALSE;
                  }  
               else if (ITEM == vmdegree) 
                  {
                  if (!degree) /* war Radiant, Rotation umrechnen */
                     {
                     xangle*=180./PI;
                     zangle*=180./PI;
                     write_rotate();
                     }
                  degree=TRUE;
                  check (vmdegree); 
                  uncheck (vmradiant); 
                  }                          
               else if (ITEM == vmradiant) 
                  {
                  if (degree) /* war Grad, Rotation umrechnen */
                     {
                     xangle/=180./PI;
                     zangle/=180./PI;
                     write_rotate();
                     }
                  degree=FALSE;
                  uncheck (vmdegree); 
                  check (vmradiant); 
                  }    
               }
            else if (TITLE == vthelp) 
               {
               if (ITEM == vmhfunc) 
                  dialog (vhfunct);
               else if (ITEM == vmhspecf) 
                  dialog (vhspecf);
               else if (ITEM == vmhrotate) 
                  dialog (vhrotate);
               else if (ITEM == vmhview) 
                  dialog (vhprojekt);
               else if (ITEM == vmhresol) 
                  dialog (vhresol);
               else if (ITEM == vmhdraw) 
                  dialog (vhdraw);
               else if (ITEM == vmhstad) 
                  dialog (vhstad);
               }
            menu_tnormal(menu_tree,TITLE,1);

            /* switch all menus & icons on and off, depending on variables */
            /* first all on */
            selecton(vidrawf,vmdrawf);
            selecton(virotate,vmrotate); 
            selecton(vilight,vmlight);
            selecton(viview,vmview);
            selecton(viresol,vmresol);
            selecton(vistyle,vmdrawmode);

            inputgiven=((funcinput && funcgiven)||(!funcinput && filegiven));
            
            /* now off, depending on mode */
            if (!inputgiven) /* noch keine Funktion */
               {
               selectoff(vidrawf,vmdrawf);
               selectoff(virotate,vmrotate);
               selectoff(vilight,vmlight);
               selectoff(viview,vmview);
               selectoff(viresol,vmresol);
               selectoff(vistyle,vmdrawmode);
               }
            else /* func is here */
               {
               if (drawmode!=SHADOW)
                  {
                  selectoff(vilight,vmlight);
                  }
               if (!central)
                  {
                  selectoff(viview,vmview);
                  }
               if (filegiven && !funcinput && !funcgiven)
                  {
                  selectoff(viresol,vmresol);
                  }
               }
   			update_memostat();
            form_dial(FMD_FINISH,xdesk,ydesk,wdesk,hdesk,xdesk,ydesk,wdesk,hdesk);
            /* to draw all icons */
            break;       
         }
   wind_update(END_UPDATE);
   }
while (!qflag);
}

/*******************************************************************/
