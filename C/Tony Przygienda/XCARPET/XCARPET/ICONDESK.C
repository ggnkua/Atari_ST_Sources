/********************************************************************
 *
 *  icondesk.c		projekt : xcarpet
 *-------------------------------------------------------------------
 *  verwaltung des neuen desktops mit icons
 *-------------------------------------------------------------------
 *  init_desktop()	desktop installieren , icons auf standardpos.
 *
 *  --  icons manipulieren --
 *  icon_select(nr)
 *  switch_icon(nr,flag) 
 *  move_icon(nr,new_x,new_y)
 *  icons_deselect()
 *
 *******************************************************************/
 
 /*  april 88	Åbernahme der quelle 'carpet.c' von tony przygienda
  *  13. 5.	auslagerung von 'icondesk.c'
  */

#include "..\carpet.h"
#if COMPILER==MEGAMAX
	#include <obdefs.h>
	#include <gemdefs.h>
#endif

#include <portab.h>

#if COMPILER==TURBOC
	#include "..\icondesk.h"
	#include <aes.h>
	#include <vdi.h>
#endif


/* from CARPET */
extern OBJECT *icons_tree;
extern int vicons, vdesktop;
extern int xdesk,ydesk,wdesk,hdesk;
extern int visave,viinputf,vidrawf,virotate,vilight,viview,viresol,vistyle;
#if COMPILER==TURBOC
	#include "..\xcarpet.h";
#endif

/* from INITEXIT */
extern void exitus();
#if COMPILER==TURBOC
	#include "..\initexit.h";
#endif


/* from GEMHELP */
extern void do_obj(),undo_obj();
extern WORD ask_obj();
#if COMPILER==TURBOC
	#include "..\gemhelp.h"
#endif	

void init_desktop()		/* neuen Desktop mit Piktogrammen zeichnen */
{
  if (rsrc_gaddr(R_TREE,vicons,&icons_tree))
   {
   			/* zuerst Box auf volle Desktopgrîsse setzen */
   icons_tree[vdesktop].ob_x=xdesk;
   icons_tree[vdesktop].ob_y=ydesk;
   icons_tree[vdesktop].ob_width=wdesk;
   icons_tree[vdesktop].ob_height=hdesk;  
   					/* jetzt zeichnen */
   wind_set(0,WF_NEWDESK,icons_tree,0,0);
   		/* jetzt den Desktop initialisieren und neu zeichnen */
   form_dial(FMD_FINISH,xdesk,ydesk,wdesk,hdesk,xdesk,ydesk,wdesk,hdesk);
   }
  else
   {
   form_alert(1,"[1][Was ist das fÅr|ein Resource ...][ Ich dachte... ]");
   exitus();
   }
}

void icon_select(nr)
  WORD nr;
{
  int x1,y1; /* echte SCREEN-Koordinaten */

  if (nr!=vdesktop)
   {
   do_obj(icons_tree,nr,SELECTED);
   objc_offset(icons_tree,nr,&x1,&y1);
   form_dial(FMD_FINISH,x1-3,y1-3,icons_tree[nr].ob_width+4,icons_tree[nr].ob_height+4,
                        x1-3,y1-3,icons_tree[nr].ob_width+4,icons_tree[nr].ob_height+4);
   }
}

void switch_icon(nr,flag) /* on and off */
  WORD nr;
  int flag; /* <>0 on, 0=off */
{
  if (nr!=vdesktop)
   {
   if (!flag)
      icons_tree[nr].ob_flags|=HIDETREE;
   else
      icons_tree[nr].ob_flags&=(~HIDETREE);
   }
}

void move_icon(nr,new_x,new_y)
  WORD nr,new_x,new_y;
{
  int x1,y1; /* echte SCREEN-Koordinaten */

  if (nr!=vdesktop)
   {
   objc_offset(icons_tree,nr,&x1,&y1);
   icons_tree[nr].ob_x=new_x-icons_tree[vdesktop].ob_x;
   icons_tree[nr].ob_y=new_y-icons_tree[vdesktop].ob_y; /* compute new */   
   form_dial(FMD_FINISH,x1-3,y1-3,icons_tree[nr].ob_width+4,icons_tree[nr].ob_height+4,
                        x1-3,y1-3,icons_tree[nr].ob_width+4,icons_tree[nr].ob_height+4);
   /* clear old coord & draw new */
   objc_offset(icons_tree,nr,&x1,&y1);    
   form_dial(FMD_FINISH,x1-3,y1-3,icons_tree[nr].ob_width+4,icons_tree[nr].ob_height+4,
                        x1-3,y1-3,icons_tree[nr].ob_width+4,icons_tree[nr].ob_height+4);
   }
}
                        
void icons_deselect()		/* deselect all icons on desktop */
{
  int icons_index[9];
  register runner=0;
  int min_x=xdesk+wdesk;
  int max_x=xdesk;
  int min_y=ydesk+hdesk;
  int max_y=ydesk;
  int x1,y1;

	/* Initialisierung nur so, da am Anfang fÅr static die Werte */
	/* der entsprechenden RSC-Variablen unbekannt sind!			*/
  icons_index[0]= visave; icons_index[1]= viinputf;
  icons_index[2]= vidrawf;icons_index[3]= virotate;
  icons_index[4]= vilight;icons_index[5]= viview;
  icons_index[6]= viresol;icons_index[8]= vistyle; icons_index[9]= -1;

  while(icons_index[runner]!=-1)
   {
   if (ask_obj(icons_tree,icons_index[runner],SELECTED))   
      {
      undo_obj(icons_tree,icons_index[runner],SELECTED);
      objc_offset(icons_tree,icons_index[runner],&x1,&y1);
      max_x=max(max_x,icons_tree[icons_index[runner]].ob_width+x1);
      max_y=max(max_y,icons_tree[icons_index[runner]].ob_height+y1);
      min_x=min(min_x,icons_tree[icons_index[runner]].ob_x);
      min_y=min(min_y,icons_tree[icons_index[runner]].ob_y);
      }
   runner++;
   }

  if ((max_x-min_x>0)||(max_y-min_y>0))
   form_dial(FMD_FINISH,min_x,min_y,max_x-min_x,max_y-min_y,
                      min_x,min_y,max_x-min_x,max_y-min_y);                      
}

/********************************************************************/

