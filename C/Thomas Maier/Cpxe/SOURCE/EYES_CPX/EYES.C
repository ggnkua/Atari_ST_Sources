
#include <tmstdlib.h>
#include <cpxdata.h>
#include <aes.h>

#include "eyes.h"
#include "rsh.h"
#include "eyes-rsc.h"
#include "proto.h"

#define INFOSTRING "[0][   ----  EYES CPX  ----  |" \
					   " |" \
				       " Version 0.01ž  01.02.97 |" \
				       " by ToMST, Thomas Maier  |" \
				       "    ***  FREEWARE  ***   ][ Go On ]"



XCPB *xcpb;
CPXINFO cpxinfo = { (WORD (*)(GRECT*))cpx_call, cpx_draw, cpx_wmove, cpx_timer, cpx_key,
					cpx_button, NULL, NULL, NULL, cpx_close };

MOBLK dummymoblk;

LONG time = 250L;

OBJECT *eyes;
WORD eyes_w, eyes_h, pup_w2, pup_h2;

WORD n1x,n1y,n2x,n2y;
WORD o1x,o1y,o2x,o2y;

WORD pup1x,pup2x,pupy;

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

		InitEyes();
	}
	
	return &cpxinfo;
}



WORD cpx_call( GRECT *work, void *copsdialog )
{
	appl_init();
	MultiTOS = ( global[0] >= 0x400 && (global[1] == -1 || global[1] > 8) );
	
	eyes[OBACK].ob_x = work->g_x;
	eyes[OBACK].ob_y = work->g_y;
	
	if ( Cops )
		wdlg_set_tree(copsdialog,eyes);
	else
	{	eyes[OBACK].ob_width = work->g_w;
		eyes[OBACK].ob_height = work->g_h;
		cpx_draw((GRECT*)&eyes[OBACK].ob_x);
	}
	cpxSet_Evnt_Mask(xcpb,MU_TIMER|MU_BUTTON|MU_KEYBD,
					&dummymoblk,&dummymoblk,time);

	return 1; /* weitermachen */
}


void cpx_draw( GRECT *clip )
{
	GRECT *win;
	
	wind_update(BEG_UPDATE);
	win = cpxGetFirstRect(xcpb,clip);
	while (win)
	{	objc_draw(eyes,OBACK,MAX_DEPTH,win->g_x,win->g_y,win->g_w,win->g_h);
		win = cpxGetNextRect(xcpb);
	}
	wind_update(END_UPDATE);
}


void cpx_wmove( GRECT *work )
{
	*((GRECT*)(&eyes[OBACK].ob_x)) = *work;
}



void cpx_timer( WORD *event )
{
	static WORD oldx = 0, oldy = 0;
	WORD mx,my,i,x,y;
	
	graf_mkstate(&mx,&my,&i,&i);
	objc_offset(eyes,OPUPS,&x,&y);
	mx -= x;
	my -= y;
	if ( mx != oldx || my != oldy )
	{	oldx = mx;
		oldy = my;
		calc(mx - pup1x,my - pupy,&n1x,&n1y);
		calc(mx - pup2x,my - pupy,&n2x,&n2y);
		n1x += pup1x - pup_w2;
		n1y += pupy - pup_h2;
		n2x += pup2x - pup_w2;
		n2y += pupy - pup_h2;
		if ( o1x != n1x || o1y != n1y || o2x != n2x || o2y != n2y )
		{	draw_pup();
			o1x = n1x;
			o1y = n1y;
			o2x = n2x;
			o2y = n2y;
		}
	}
	*event = 0;
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
	
	switch ( cpxPopup(xcpb,menu,2,-1,IBM,&button,(GRECT*)&eyes[OBACK].ob_x) )
	{
	 case 0:	form_alert(1,INFOSTRING); break;
		
	 case 1:	ret = cpxPopup(xcpb,timemenu,4,sel,IBM,&button,(GRECT*)&eyes[OBACK].ob_x);
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

void InitEyes(void)
{
	BITBLK *bit;

	eyes = rs_trindex[OTEYES];
	bit = eyes[OEYES].ob_spec.bitblk;
	eyes_w = bit->bi_wb * 8;
	eyes_h = bit->bi_hl;
	eyes[OBACK].ob_width = eyes[OEYES].ob_width = eyes[OPUPS].ob_width = eyes_w;
	eyes[OBACK].ob_height = eyes[OEYES].ob_height = eyes[OPUPS].ob_height = eyes_h;
	eyes[OEYES].ob_x = eyes[OEYES].ob_y = 0;
	eyes[OPUPS].ob_x = eyes[OPUPS].ob_y = 0;
	bit = eyes[OPUP1].ob_spec.bitblk;
	pup_w2 = bit->bi_wb << 2;
	pup_h2 = bit->bi_hl >> 1;

	pupy = eyes_h >> 1;
	pup1x = eyes_w >> 2;
	pup2x = (eyes_w >> 1) + pup1x;
	
	eyes[OPUP1].ob_x = n1x = o1x = pup1x - pup_w2;
	eyes[OPUP1].ob_y = n1y = o1y = pupy - pup_h2;
	eyes[OPUP2].ob_x = n2x = o2x = pup2x - pup_w2;
	eyes[OPUP2].ob_y = n2y = o2y = pupy - pup_h2;
}


void draw_pup(void)
{
	GRECT *win;
	OBJECT *pup1 = &eyes[OPUP1], *pup2 = &eyes[OPUP2];
	
	wind_update(BEG_UPDATE);
	win = cpxGetFirstRect(xcpb,(GRECT*)&eyes[OBACK].ob_x);
	while (win)
	{	pup1->ob_spec.bitblk->bi_color = WHITE;
		pup2->ob_spec.bitblk->bi_color = WHITE;
		pup1->ob_x = o1x;
		pup1->ob_y = o1y;
		pup2->ob_x = o2x;
		pup2->ob_y = o2y;
		objc_draw(eyes,OPUPS,MAX_DEPTH,win->g_x,win->g_y,win->g_w,win->g_h);
	
		pup1->ob_spec.bitblk->bi_color = BLACK;
		pup2->ob_spec.bitblk->bi_color = BLACK;
		pup1->ob_x = n1x;
		pup1->ob_y = n1y;
		pup2->ob_x = n2x;
		pup2->ob_y = n2y;
		objc_draw(eyes,OPUPS,MAX_DEPTH,win->g_x,win->g_y,win->g_w,win->g_h);
	
		win = cpxGetNextRect(xcpb);
	}
	wind_update(END_UPDATE);
}


#define XA 7
#define YB 11

void calc( WORD dx, WORD dy, WORD *px, WORD *py )
{
	WORD a,b;
	WORD phi;
	LONG c;
	
	if ( dx == 0 )
	{	*px = 0;
		if ( dy < 0 )
			*py = ( dy > -YB ? dy : -YB );
		else
			*py = ( dy > YB ? YB : dy );
		return;
	}
	
	if ( (LONG)dx * dx + (LONG)dy * dy <= XA * XA )
	{	*px = dx; /* N„herungsweise */
		*py = dy;
		return;
	}
	
	/* Winkel berechnen */
	a = (dx > 0 ? dx : -dx);
	c = (dy > 0 ? dy : -dy);
	c = (c * MATHOFFSET) / (LONG)a;
	for ( phi = 0; phi < TANTABMAX; phi++ )
		if ( c < (LONG)tantab[phi] ) break;
	
	b = ((LONG)sintab[phi] * YB) / MATHOFFSET;
	a = ((LONG)sintab[90-phi] * XA) / MATHOFFSET;
	
	if ( dx < 0 )
		a = -a;
	if ( dy < 0 )
		b = -b;
	
	*px = a;
	*py = b;
}