
#include <tmstdlib.h>
#include <cpxdata.h>
#include <aes.h>

#include "rsh.h"
#include "dog-rsc.h"
#include "proto.h"


#define INFOSTRING "[0][   ----  DOG CPX  ----   |" \
					   " |" \
				       " Version 0.01ž  01.02.97 |" \
				       " by ToMST, Thomas Maier  |" \
				       "    ***  FREEWARE  ***   ][ Go On ]"

#define DOG_W 32
#define DOG_H 36

#define FELD_W 100
#define FELD_H 44

#define MOVE_W 4

WORD abl_c = 0, x;

#define NOMOVE 0x1000

WORD ablauf[] = { ODOG1|NOMOVE, ODOG1|NOMOVE, ODOG2|NOMOVE,
			 ODOG3|NOMOVE, ODOG4,ODOG5,ODOG6,ODOG7,
			 ODOG4,ODOG5,ODOG6,ODOG7, ODOG4,ODOG5,ODOG6,ODOG7,
			 ODOG2|NOMOVE,ODOG3|NOMOVE,ODOG2|NOMOVE,ODOG3|NOMOVE,-1 };


XCPB *xcpb;
CPXINFO cpxinfo = { (WORD (*)(GRECT*))cpx_call, cpx_draw, cpx_wmove, cpx_timer, cpx_key,
					cpx_button, NULL, NULL, NULL, cpx_close };

MOBLK dummymoblk;

LONG time = 250L;

OBJECT *dog;

BOOLEAN Cops = FALSE;
BOOLEAN MultiTOS = FALSE;


CPXINFO *cpx_init( XCPB *Xcpb, LONG copsmagic, LONG copsversion )
{
	xcpb = Xcpb;
	
	Cops = ( copsmagic == asc2long('C','O','P','S') && copsversion >= 0x10000L );
	
	if ( xcpb->booting )
		return (CPXINFO*)1;
	
	if ( ! xcpb->SkipRshFix )
	{	static OBJECT dummy = {-1,-1,-1,G_BOX,0,0,{NULL},1,1,1,1};
		cpxrsh_obfix(xcpb,&dummy,0);   /* setzt SkipRshFix zurck, sichere Methode */
		
		InitDog();
	}		

	return &cpxinfo;
}

DIALOG *dialog = NULL;

WORD cpx_call( GRECT *work, void *copsdialog )
{
	appl_init();
	MultiTOS = ( global[0] >= 0x400 && (global[1] == -1 || global[1] > 8) );
	
	dog[OBACK].ob_x = work->g_x;
	dog[OBACK].ob_y = work->g_y;
	
	if ( Cops )
	{	wdlg_set_tree(copsdialog,dog); /* zeichnet auch Objektbaum, laut Doku */
		dialog = copsdialog;
	}
	else
	{	dog[OBACK].ob_width = work->g_w;
		dog[OBACK].ob_height = work->g_h;
		cpx_draw((GRECT*)&dog[OBACK].ob_x);
	}

	cpxSet_Evnt_Mask(xcpb,MU_TIMER|MU_BUTTON|MU_KEYBD,
					&dummymoblk,&dummymoblk,time);
	
	return 1; /* weitermachen */
}


void redraw( GRECT *clip, WORD obj, WORD depth )
{
	GRECT *win;
	
	wind_update(BEG_UPDATE);
	win = cpxGetFirstRect(xcpb,clip);
	while (win)
	{	objc_draw(dog,obj,depth,win->g_x,win->g_y,win->g_w,win->g_h);
		win = cpxGetNextRect(xcpb);
	}
	wind_update(END_UPDATE);
}

void cpx_draw( GRECT *clip )
{
	redraw(clip,OBACK,MAX_DEPTH);
}


void cpx_wmove( GRECT *work )
{
	*((GRECT*)(&dog[OBACK].ob_x)) = *work;
}



void cpx_timer( WORD *event )
{	WORD newobj;
	GRECT win;
	
	*event = 0;

	abl_c++;
	if ( ablauf[abl_c] < 0 )
		abl_c = 0;
	newobj = ablauf[abl_c] & ~NOMOVE;
	
	if ( !(ablauf[abl_c] & NOMOVE) )	
	{	x += MOVE_W;
		if ( x > (FELD_W - DOG_W) )
		{	/* move window */
			WORD sx,sy,sw,sh;
		
			x = 0;
			if ( dialog )
			{	wind_get(0,WF_WORKXYWH,&sx,&sy,&sw,&sh);
				if ( (dog[OBACK].ob_x + FELD_W) > (sx + sw) )
					dog[OBACK].ob_x = sx + MOVE_W;
				else
					dog[OBACK].ob_x += (FELD_W - DOG_W);
				redraw((GRECT*)&dog[OBACK].ob_x,OBACK,0);
				wdlg_set_size(dialog,(GRECT*)&dog[OBACK].ob_x);
			}
		}
	}
	dog[newobj].ob_x = x;
	dog[newobj].ob_spec.bitblk->bi_color = BLACK;
	dog[OBACK].ob_head = dog[OBACK].ob_tail = newobj;
	win.g_x = dog[OBACK].ob_x + x - MOVE_W; /* damit altes Bild berschrieben wird */
	win.g_y = dog[OBACK].ob_y + dog[newobj].ob_y;
	win.g_w = DOG_W + MOVE_W;
	win.g_h = DOG_H;
	cpx_draw(&win);
}


void cpx_key( WORD kstate, WORD key, WORD *event )
{
	*event = 0;
}

	


void cpx_button( MRETS *mrets, WORD nclicks, WORD *event )
{
	static char *menu[] = { "  Info    ","  Refresh ",NULL };
	static char *timemenu[] = { "  100 ms ","  250 ms ","  500 ms ","  1 s    ",NULL };
	static WORD sel = 1;
	WORD ret;
	GRECT button;
	
	button.g_x = mrets->x;
	button.g_y = mrets->y;
	button.g_w = 1;
	button.g_h = 1;
	
	switch ( cpxPopup(xcpb,menu,2,-1,IBM,&button,(GRECT*)&dog[OBACK].ob_x) )
	{
	 case 0:	form_alert(1,INFOSTRING); break;
		
	 case 1:	ret = cpxPopup(xcpb,timemenu,4,sel,IBM,&button,(GRECT*)&dog[OBACK].ob_x);
				if ( ret >= 0 )
				{	switch ( ret )
					{
					 case 0:	sel = 0; time = 100L; break;
					 case 1:	sel = 1; time = 250L; break;
					 case 2:	sel = 2; time = 500L; break;
					 case 3:	sel = 3; time = 1000L; break;
					}
			
					cpxSet_Evnt_Mask(xcpb,MU_TIMER|MU_BUTTON|MU_KEYBD,
										&dummymoblk,&dummymoblk,time);
				}
				break;
	}
	*event = 0;
}

void cpx_close(WORD flag)
{
	if ( MultiTOS )
		appl_exit();
}


/*-------------------------------*/

void InitDog(void)
{	WORD i;
	OBJECT *o;

	dog = rs_trindex[OTDOGS];
	dog[OBACK].ob_spec.index = 0L;
	dog[OBACK].ob_width = FELD_W;
	dog[OBACK].ob_height = FELD_H;
	for ( i = ODOG1; i <= ODOG7; i++ )
	{	o = &dog[i];
		o->ob_next = 0;
		o->ob_y = (FELD_H - DOG_H) / 2;
		o->ob_width = DOG_W;
		o->ob_height = DOG_H;
	}
	dog[OBACK].ob_head = dog[OBACK].ob_tail = ablauf[abl_c] & ~NOMOVE;
	dog[ODOG1].ob_x = x = (FELD_W - DOG_W) / 2;
}


