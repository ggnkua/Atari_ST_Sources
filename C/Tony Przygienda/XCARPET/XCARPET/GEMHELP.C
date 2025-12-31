/********************************************************************
 *
 *  gemhelp.c		projekt : xcarpet
 *-------------------------------------------------------------------
 *  gem-hilfsfunktionen
 *-------------------------------------------------------------------
 *  hndl_dial (tree,def,xywh)	dialogbox ausgeben und bearbeiten
 *     do_obj (tree,obj,bit)	'bit' in 'obj' setzen
 *   undo_obj (    ....    )	     ....      lîschen
 *    ask_obj (    ....    )	     ....      abfragen
 *
 *  show_mouse(),hide_mouse()	...
 *  arrow(),bee(),point_hand()	aussehen des mauszeigers bestimmen
 *
 *******************************************************************/
 
 /*  april 88	Åbernahme der quelle 'carpet.c' von tony przygienda
  *  13. 5.	auslagerung von 'gemhelp.c'
  *  12.10. Umschreiben in ANSI
  */

#include "..\carpet.h"
#if COMPILER==MEGAMAX
	#include <obdefs.h>
	#include <gemdefs.h>
#endif

#include <portab.h>

#if COMPILER==TURBOC
	#include <aes.h>
	#include <vdi.h>
	#include "..\gemhelp.h"
#endif


int  hndl_dial(tree,def,x,y,w,h)   /* center, display and get input */
  register OBJECT *tree;           /* from specified dialogue box   */
  register int def;
  register int x,y,w,h;
{
  int xdial,ydial,wdial,hdial;
  register int exit_obj;

  form_center(tree,&xdial,&ydial,&wdial,&hdial);
  form_dial(FMD_START,x,y,w,h,xdial,ydial,wdial,hdial);
  form_dial(FMD_GROW,x,y,w,h,xdial,ydial,wdial,hdial);
  objc_draw(tree,0,25,xdial,ydial,wdial,hdial);
  exit_obj = form_do(tree,def);
  form_dial(FMD_SHRINK,x,y,w,h,xdial,ydial,wdial,hdial);
  form_dial(FMD_FINISH,x,y,w,h,xdial,ydial,wdial,hdial);

  return(exit_obj);
}

#define OB_STATE(obj)   &tree[obj].ob_state
/* gets the state of an object */

void undo_obj(tree,which,bit)      /* clear specified bit in object state */
  OBJECT *tree;
  WORD which,bit;
{
  WORD state;

  state = LWGET(OB_STATE(which));
  LWSET(OB_STATE(which),state & ~bit);
}

void do_obj(tree,which,bit)      /* set specified bit in object state */
  OBJECT *tree;
  WORD which,bit;
{
  WORD state;

  state = LWGET(OB_STATE(which));
  LWSET(OB_STATE(which),state | bit);
}

WORD ask_obj(tree,which,bit)     /* ask bit in object's state*/
  OBJECT *tree;
  WORD which,bit;
{
  WORD state;

  state = LWGET(OB_STATE(which));
  return state & bit;
}

/* globale Variable, die angibt, ob Maus hidden ist oder nicht! */

static hidden=FALSE;

void hide_mouse()	
{    
  if (!hidden)
    graf_mouse(M_OFF,0x0L); 
  hidden=TRUE;
}

void show_mouse()
{ 
  if (hidden)
    graf_mouse(M_ON,0x0L);
  hidden=FALSE;

}

void arrow()  		{    graf_mouse(ARROW,0x0L);		}
void point_hand()	{    graf_mouse(POINT_HAND,0x0L); 	}
void bee()    		{    graf_mouse(HOURGLASS,0x0L);  	}


/********************************************************************/
