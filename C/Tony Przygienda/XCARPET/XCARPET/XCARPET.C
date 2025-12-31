/********************************************************************
 *
 *  xcarpet.c
 *
 ********************************************************************/
 
/* 14.10.1988   XCARPET 1.1  -> Programm wird zum ANSI-Standard
					entwickelt (TURBOC), einige kleine Fehler rausgenommen
					(wieder) farbfÑhig gemacht!, einige Funktionen 
					(hardcopy) ausprogrammiert!									*/
					
 /*  april 88	Åbernahme der quelle von tony przygienda
  *   1. 5.	unterschiedliche x- und y-auflîsungen
  *  12. 5.	anpassen der neuen resource mit datei-einlesen etc.
  *  		aufteilen in mehrere module
  */
 
/*-------------------------  rest vom original  ------------------------*/
/* XCarpet Designer V1.1: a program drawing 3D-functions                */
/* purpose : a little kidding with GEM got rather big                   */
/* language: MEGAMAX C-COMPILER V1.1   (ATARI 1040 STf) oder				*/
/*       		TURBO C (Ver. 1.0)										         */
/* author  : Tony Przygienda jun., REHERSTR. 22E, CH-9016 ST. GALLEN    */
/*           ETH ZÅrich student (computer science)                      */
/* last modification: XCarpet V1.1 14/10/1988        start: 5/87        */ 

#include "..\carpet.h"
#include <portab.h>
#include <stdio.h>
	
#if COMPILER==MEGAMAX
	#include <obdefs.h>
	#include <gemdefs.h>
#endif
#if COMPILER==TURBOC
	#include "..\xcarpet.h"
	#include <aes.h>
	#include <vdi.h>
	#include <stdlib.h>
	#include <string.h>
#endif


#define WI_KIND     NAME | MOVER | SIZER | VSLIDE | HSLIDE 
#define WINDOWNAME  "XCARPET"

#define NO_WINDOW   -1

/* all variables imported from INOUT */

extern char    func_string[]; /* enthÑlt string der Funktionsgleichung */
extern double  xstart,xend,ystart,yend; /* definition range of function */
extern double  consta,constb,constc;  /* Werte der Konstanten */
extern double  xangle,zangle; /* rotation angles of the carpet in 3D-space */
extern double  look_x,look_y,look_z,plane_y; /* coordinates of the view-point */
extern int     light_x,light_y,light_z; /* of the light source */
extern int     xlines,ylines; /* resolution, how much line does it need */

/* and now functions from INOUT imported */

extern void read_forminp(),write_forminp(); /* to the main dialog vinputfun */
extern void read_rotate(),write_rotate(); /* dialog vrotation */
extern void read_view(),write_view(); /* dialog vview */
extern void read_light(),write_light(); /* dialog vlight */
extern void read_resolution(),write_resolution(); /* dialog vlinien */

#if COMPILER==TURBOC
	#include "..\inout.h"
#endif


/* from CALC module */

extern boolean counted2d,counted3d,shadowed,inferior,funcgiven;
extern void draw_function();
extern void release_all();
extern boolean countedfl; 
/* brauche zur Feststellung ob berechnet */
extern void cald2d(),count_shadows();
extern int make_list(),calc3d();
#if COMPILER==TURBOC
	#include "..\calc.h"
#endif


/* from TREE module */

extern void give_function(); 
extern boolean error;
char   terrorstring [80];

extern double variables[];

#if COMPILER==TURBOC
	#include "..\tree.h"
#endif


/* from INITEXIT */

extern OBJECT *menu_tree;  /* Adress of the pulldown */
extern WORD wi_handle;
extern WORD top_window;
extern WORD handle;

extern WORD gr_hwchar,gr_hhchar;
extern WORD gr_hwbox,gr_hhbox;
extern WORD gr_hspace;

extern int  colours; 
extern char *reserved_screen;
extern long screenbytes;
extern int drawmode;
extern char pic_format;
extern FDB source,target;

extern int  xdesk,ydesk,hdesk,wdesk;
extern int  xwork,ywork,hwork,wwork;
extern int  xpict,ypict,hpict,wpict;

extern int vpulldown;
extern int vsyserror,vqsyserr;
extern int vsavefun,vdrawfun,vcount3d,vcount2d,vcountfl,vcountsh;
extern int vstartinf;

#if COMPILER==TURBOC
	#include "..\initexit.h"
#endif

extern void save_3d();
#if COMPILER==TURBOC
	#include "..\gemhelp.h"
	#include "..\icondesk.h"
	#include "..\multi.h"
	#include "..\xfiles.h"
#endif


void line(xs,ys,xe,ye)             /* draws a 'clipped' line */
register int xs,ys,xe,ye;
{
int tmp[4];

tmp[0]=xs;tmp[1]=ys;tmp[2]=xe;tmp[3]=ye;
v_pline(handle,2,tmp);
}

void bar(xs,ys,xe,ye)              /* draws a 'clipped' bar */
register int xs,ys,xe,ye;
{
int tmp[4];

tmp[0]=xs;tmp[1]=ys;tmp[2]=xe;tmp[3]=ye;
v_bar(handle,tmp);
}

void set_clip(x,y,w,h)               /* sets clip area with given x,y and    */
int x,y,w,h;                    /* width and heigth                     */
{
int clip[4];

clip[0]=x;
clip[1]=y;
clip[2]=x+w;
clip[3]=y+h;
vs_clip(handle,1,clip);
}

#define TESTSLIZE 		0
#define viconsTEST       TRUE

void hslidesize()
/* calculation to show the size of the hslidesize depending on the size */
/* of the actual window in relation to the size of the graph page       */
{
register double hsize=(min(wwork,wpict)*1000.)/(double) wpict;

#if TESTSLIZE
printf("hsize: %g  ",hsize);
gemdos(7);
#endif
wind_set(wi_handle,WF_HSLSIZE,(UWORD) hsize,0,0,0);
}

void vslidesize()
/* calculation to show the size of the vslidesize depending on the size */
/* of the actual window in relation to the size of the graph page       */
{
register double vsize=(min(hwork,hpict)*1000.)/(double) hpict;

#if TESTSLIZE
printf("vsize: %g  ",vsize);
gemdos(7);
#endif
wind_set(wi_handle,WF_VSLSIZE,(UWORD) vsize,0,0,0);
}

void hslidepos()
/* calculation to show the position of the hslide depending on the */
/* position of the actual window on the graph page                 */
{
register double hpos;

hpos= (wwork>=wpict ? 0.:xpict*1000./(double) (wpict-wwork));

wind_set(wi_handle,WF_HSLIDE,(UWORD) hpos,0,0,0);
}

void vslidepos()
/* calculation to show the position of the vslide depending on the */
/* position of the actual window on the graph page                 */
{
register double vpos;

vpos= (hwork>=hpict ? 0.:ypict*1000./(double) (hpict-hwork));

wind_set(wi_handle,WF_VSLIDE,(UWORD) vpos,0,0,0);
}

void open_window()
/* opens the window to show the function in   with max size */
{

wind_calc(WC_WORK,WI_KIND,xdesk+2,ydesk+2,wdesk-4,hdesk-4,
          &xwork,&ywork,&wwork,&hwork); /* workarea got */
xpict=ypict=0; /* it means, the graphics is at the top left corner */
wpict=wwork, hpict=hwork; /* this will not change during the whole appl */
                          /* the help page is as big as the window max */          
wi_handle=wind_create(WI_KIND,xdesk+2,ydesk+2,wdesk-4,hdesk-4);
if (wi_handle!=-1)
   {
   graf_growbox(xdesk/2,ydesk/2,1,1,xwork,ywork,wwork,hwork); /* create */
   /* von der Menueleiste bis hier */
   /* set window name here */
   wind_set(wi_handle,WF_NAME,WINDOWNAME,0);
   wind_open(wi_handle,xdesk+2,ydesk+2,wdesk-4,hdesk-4); /* volle Grîsse */
   hslidesize();
   hslidepos();
   vslidesize();
   vslidepos();
   }
}

void close_window()
/* closes and deletes the window the application uses */
{
if (wi_handle!=NO_WINDOW)
   {
   wind_close(wi_handle);
#if COMPILER!=TURBOC  
   graf_shrinkbox(xdesk/2,ydesk/2,1,1,xwork,ywork,wwork,hwork); 
#else
	/* scheint beim TURBOC falsche ParameterÅbergabe zu haben!!! */
   form_dial(FMD_SHRINK,xdesk/2,ydesk/2,1,1,xwork,ywork,wwork,hwork);
#endif
   wind_delete(wi_handle);
   wi_handle=NO_WINDOW;
   }
}   

/* Behandlung von Errors */

void eingabe_error()
{
normal_error("UnzulÑssige Eingabe wurde automatisch korrigiert ...");
}

void memory_error()
{
normal_error("SpeicherplatzÅberlauf ...");
release_all();
close_window();
if (reserved_screen)
   free(reserved_screen); /* auch nicht mehr gebraucht */
menu_bar(menu_tree,0);
rsrc_free();
close_vwork();
appl_exit();
exit(1);
}

void normal_error(s)
register char *s;
{
OBJECT *tree_adress;

rsrc_gaddr(R_TREE,vsyserror,&tree_adress);
((TEDINFO *) tree_adress[vqsyserr].ob_spec)->te_ptext=s;

undo_obj(tree_adress,hndl_dial(tree_adress,0,xdesk/2,ydesk/2,1,1),SELECTED);
}


void main()
{
  init_carpet();

  wind_update(BEG_UPDATE);     /* menu nicht anwÑhlbar */   
  menu_bar(menu_tree,1); /* Leiste anzeigen */
  reserve_screen(); /* AbhÑngigkeit der Auflîsung */
  wind_get(0,WF_WORKXYWH,&xdesk,&ydesk,&wdesk,&hdesk); /* desktopsize */
  
  init_desktop();
  show_startmessage();
  open_window();
  init_variables();
  test_name();
  wind_update(END_UPDATE);
  
  if (wi_handle==-1)
  {
    form_alert(1,"[1][Keine Windows zum|Rausgucken mehr ...][ Schade ]");
    exitus();
  }
  show_mouse();
  arrow();
  
  multi(); 
  
  release_all();
  close_window();
  menu_bar(menu_tree,0);

  if (reserved_screen)
    free(reserved_screen); /* auch nicht mehr gebraucht */

  exitus();

}

/* wegen dem Umschalten der Resource Objekte in diesem MODUL */
#define RCSTEST  FALSE

void calc_function(x,y,w,h)
int x,y,w,h;
{ 
OBJECT *tree_adress;

rsrc_gaddr(R_TREE,vdrawfun,&tree_adress);
#if RCSTEST
printf ("%tree:%lx\nobspec:%lx\n",tree_adress,tree_adress[vcount3d].ob_spec);
gemdos(7);
#endif
*(((WORD *) &tree_adress[vcount3d].ob_spec)+1)=0x11; 
         /* Farbe, dh. sichtbar */
*(((WORD *) &tree_adress[vcount2d].ob_spec)+1)=0; 
*(((WORD *) &tree_adress[vcountfl].ob_spec)+1)=0;
*(((WORD *) &tree_adress[vcountsh].ob_spec)+1)=0;
objc_draw(tree_adress,0,10,x,y,w,h); /* GANZE BOX */
if (!counted3d)
   {
   bee(); 
   calc3d(terrorstring);
   arrow(); 
   }
*(((WORD *) &tree_adress[vcount2d].ob_spec)+1)=0x31; 
objc_draw(tree_adress,vcount2d,10,x,y,w,h);
if ((!counted2d) && (!error))
   {
   bee();    
   calc2d(terrorstring);
   arrow(); 
   }
/* zuerst Liste herstellen der FlÑchen der Entfernung nach */
if ((drawmode!=WIREFRAME) && (!error))
   {
   *(((WORD *) &tree_adress[vcountfl].ob_spec)+1)=0x51;
   objc_draw(tree_adress,vcountfl,10,x,y,w,h);
   if (!countedfl)
      {
      bee(); 
      make_list(terrorstring);
      arrow(); 
      }
   }
if ((drawmode==SHADOW) && !(error))
   {
   *(((WORD *) &tree_adress[vcountsh].ob_spec)+1)=0x71;
   objc_draw(tree_adress,vcountsh,10,x,y,w,h);   
   if (!shadowed)
      {
      bee(); 
      count_shadows(terrorstring); /* sonst geht's nicht */
      arrow(); 
      }
   }  
if (error)
   {
   normal_error(terrorstring); 
   counted3d=FALSE; /* nicht zeichnen */
   error=FALSE;
   }
}

void full_update() 
{
  form_dial(FMD_FINISH,xwork,ywork,wwork,hwork,xwork,ywork,wwork,hwork);
}

#if COMPILER==TURBOC    /* nicht definiert */
static int rc_intersect(const GRECT *t1, const GRECT *t2)
{
register int okw, okh;

okw = (t1->g_x<=t2->g_x ) ?
	 (t2->g_x - t1->g_x) <= t1->g_w  :  (t1->g_x - t2->g_x) <= t2->g_w;
okh = (t1->g_y<=t2->g_y ) ?
	 (t2->g_y - t1->g_y) <= t1->g_h  :  (t1->g_y - t2->g_y) <= t2->g_h; 
	
return (okw && okh);
}
#endif

void do_redraw(xc,yc,wc,hc)
int xc,yc,wc,hc;
{
GRECT t1,t2;
WORD pxy[8]; /* fÅr RASTER COPY */

hide_mouse();
wind_update(BEG_UPDATE);
t2.g_x=xc;
t2.g_y=yc;
t2.g_w=wc;
t2.g_h=hc;
wind_get(wi_handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
while (t1.g_w && t1.g_h) 
   {
   if (rc_intersect(&t2,&t1)) 
      {
      set_clip(t1.g_x,t1.g_y,t1.g_w-2,t1.g_h-2);
      pxy[0]=t1.g_x-xwork+xpict; /* left upper */
      pxy[1]=t1.g_y-ywork+ypict;
      pxy[2]=pxy[0]+t1.g_w-1;
      pxy[3]=pxy[1]+t1.g_h-1; /* the area to copy from the graph page */
      pxy[4]=t1.g_x;
      pxy[5]=t1.g_y;
      pxy[6]=t1.g_x+t1.g_w-1;
      pxy[7]=t1.g_y+t1.g_h-1; /* target matches the given rectangle */
      vro_cpyfm(handle, S_ONLY, pxy,&target, &source);
      }
   wind_get(wi_handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
   }
wind_update(END_UPDATE);
show_mouse();
set_clip(xwork,ywork,wwork-2,hwork-2);
}

#if COMPILER==MEGAMAX
	overlay "calc"
#endif

void hard_copy ()
{
  form_alert (1,"[1][hardcopy geht noch nicht| ][ aber bald ]");
}

void save_screen()
{
static char path[64]="\\*.*";
static char fname[16];
int  button;
static char monodegas[]= {
                        0,2,7,119,0,0,0,112,0,0,7,119,7,0,0,112,7,112,
                        0,7,7,7,0,119,5,85,3,51,7,51,3,115,7,115
                         };
static char middegas[]=  {
                        0,1,0,0,0,7,7,0x54,7,0x77,7,0x77,7,0,0,0x70,7,0x70,
                        0,7,7,7,0,0x77,5,0x55,3,0x33,7,0x33,3,0x73,7,0x73
                         };
static char lowdegas[]=  {
                        0,0,0,0,1,0,2,0x10,4,0x20,3,0x12,4,0x30,3,0x20,5,
                        0x30,5,0x40,6,0x50,6,0x61,7,0x75,6,0x71,7,0x77,7,
                        0x73,5,0x55 };                         
char *degasarray; /* which array to use ? */
char degastail; /* letzte Zahl im Filenamen */
int    fsave;
   static int    last_slash=1; /* im path string, der erhalten bleibt !!! */
/* ====== */
WORD   tmp_pipe[8]; /* zum Window Restauren */
register char *picp=(char *) target.fd_addr;

switch(colours)
   {
   case 2: /* low resolution */
      degasarray=monodegas;
      degastail='3';
      break;
   case 4: /* middle */
      degasarray=middegas;
      degastail='2';
      break;
   case 16: /* low */
      degasarray=lowdegas;
      degastail='1';
      break;
   default:
      degasarray=NIL;
      break;
   } /* of switch */
   
/* zuerst names prÑparieren */
switch (pic_format)
   {
   case FDEGAS:
      strcpy(&path[last_slash],"*.PI ");
      *(&path[last_slash+4])=degastail;
      break;
   case FDOODLE:
      strcpy(&path[last_slash],"*.PIC");
      break;
   case FSTAD:
      strcpy(&path[last_slash],"*.S");
      break;
   case FIMG:
   	strcpy(&path[last_slash],"*.IMG");
   	break;
   }

if ((pic_format!=FDEGAS) || (degasarray))
   {
   if (fsel_input(path,fname,&button)) /* Åberhaupt OK ? */
      if (button && strlen(fname)) /* wie gehts */
         {
         evnt_mesag(tmp_pipe);
         if (tmp_pipe[0]!=WM_REDRAW) 
            printf("\nError Window Handling !\n");
         else   
            if (tmp_pipe[3] == wi_handle)   /* NOT SO CLEAR */
               {
               do_redraw(tmp_pipe[4],tmp_pipe[5],
               tmp_pipe[6],tmp_pipe[7]);
               set_clip(xwork,ywork,
               wwork-2,hwork-2);
               }
         /* file und path zusammenflicken */
         for (button=0, last_slash=0; button<strlen(path); button++)
            if (path[button]=='\\')
               last_slash=button+1;
         strcpy(&path[last_slash],fname); /* filenamen ranhÑngen */
         
         if((fsave=creat(path,0xFFFF))!=-1)
            /* open the file for SCREEN as bits saving  */      
            {
            WORD xdial,ydial,wdial,hdial;
            OBJECT *dial_adr;         
               
            bee();
            rsrc_gaddr(R_TREE,vsavefun,&dial_adr);
            form_center(dial_adr,&xdial,&ydial,&wdial,&hdial);
            form_dial(FMD_START,xdesk/2,ydesk/2,1,1,xdial,ydial,wdial,hdial);
            form_dial(FMD_GROW,xdesk/2,ydesk/2,1,1,xdial,ydial,wdial,hdial);
            objc_draw(dial_adr,0,10,xdial,ydial,wdial,hdial); /* GANZE BOX */                              
            switch (pic_format)
               {
               case FDEGAS:
                  write(fsave,degasarray,34);
                  /* Durchfluss !!! */
               case FDOODLE:
                  write(fsave,picp,(unsigned int) screenbytes);
                  close(fsave);
                  break;
               case FSTAD:
                  close(fsave); /* nÑmlich save_3d() macht ein eigenes auf */
                  if (counted3d) /* einzig interessantes */
                     save_3d(path);
                  else 
                     normal_error("Funktion nicht berechnet ...");
                  /* ablegen des ganzen als File */
                  break;
               case FIMG:
               	close(fsave); /* nicht nîtig */
               	save_img(path);
               	break;
               }
            form_dial(FMD_SHRINK,xdesk/2,ydesk/2,1,1,xdial,ydial,wdial,hdial);
            form_dial(FMD_FINISH,xdesk/2,ydesk/2,1,1,xdial,ydial,wdial,hdial);
            /* next multi event will regenerate window */ 
            arrow(); 
            }
         else
            normal_error("Diskettenfehler ...");
         }
   }
else
   normal_error("Unerlaubte DEGAS Auflîsung ...");            
}

/********************************************************************/

