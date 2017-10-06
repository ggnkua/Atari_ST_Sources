
#include <tmstdlib.h>
#include <cpxdata.h>
#include <aes.h>

#include "galaxy.h"
#include "proto.h"

#define INFOSTRING "[0][   ---  GALAXY CPX  ---  |" \
					   " |" \
				       " Version 0.01ž  01.02.97 |" \
				       " by ToMST, Thomas Maier  |" \
				       "    ***  FREEWARE  ***   ][ Go On ]"


XCPB *xcpb;
CPXINFO cpxinfo = { (WORD (*)(GRECT*))cpx_call, cpx_draw, cpx_wmove, cpx_timer, cpx_key,
					cpx_button, NULL, NULL, NULL, cpx_close };

MOBLK dummymoblk;

LONG time = 250L;

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
	
		calc();
	}

	return &cpxinfo;
}



WORD cpx_call( GRECT *work, void *copsdialog )
{
	appl_init();
	MultiTOS = ( global[0] >= 0x400 && (global[1] == -1 || global[1] > 8) );
	
	tree[ROOT].ob_x = work->g_x;
	tree[ROOT].ob_y = work->g_y;
	
	if ( Cops )
		wdlg_set_tree(copsdialog,tree);
	else
	{	tree[ROOT].ob_width = work->g_w;
		tree[ROOT].ob_height = work->g_h;
		cpx_draw((GRECT*)&tree[ROOT].ob_x);
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
	{	objc_draw(tree,ROOT,MAX_DEPTH,win->g_x,win->g_y,win->g_w,win->g_h);
		win = cpxGetNextRect(xcpb);
	}
	wind_update(END_UPDATE);
}


void cpx_wmove( GRECT *work )
{
	*((GRECT*)(&tree[ROOT].ob_x)) = *work;
}



void cpx_timer( WORD *event )
{
	calc();
	cpx_draw((GRECT*)&tree[ROOT].ob_x);

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
	
	switch ( cpxPopup(xcpb,menu,2,-1,IBM,&button,(GRECT*)&tree[ROOT].ob_x) )
	{
	 case 0:	form_alert(1,INFOSTRING); break;
		
	 case 1:	ret = cpxPopup(xcpb,timemenu,4,sel,IBM,&button,(GRECT*)&tree[ROOT].ob_x);
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

void calc(void)
{
	static WORD phi = 0; /* in 2er Schritten , erst sin, das cos */
	WORD i;
	WORD x,y;
	WORD bw_w = bild_w / 16;
	
	/* x' = cos(phi) * x - sin(phi) * y
	   y' = - sin(phi) * x - cos(phi) * y */
	
	for ( i = 0; i < (bw_w * bild_h); i++ )
		image[i] = 0;
	
	for ( i = 0; i < (num_stars * 2); i += 2 )
	{	x = ( (LONG)sintab[phi+1] * stars[i] - (LONG)sintab[phi] * stars[i+1]) / MATHOFFSET;
		y = (- (LONG)sintab[phi] * stars[i] - (LONG)sintab[phi+1] * stars[i+1]) / MATHOFFSET;
		y /= 2;
	
		x += bild_w / 2;
		y += bild_h / 2;
		if ( x < 0 || y < 0 || x >= bild_w || y >= bild_h )
			continue;
		image[y*bw_w + (x / 16)] |= ((UWORD)0x8000 >> (x & 0xf));
	}
	
	phi += 2;
	if ( phi >= 360*2/SINSTEP )
		phi = 0;
	
}
