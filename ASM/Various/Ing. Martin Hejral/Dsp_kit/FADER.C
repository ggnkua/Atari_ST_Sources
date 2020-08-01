/****************************************/
/* fader.c                              */
/*                                      */
/* Written by Martin Hejral     1996    */
/****************************************/

#include <aes.h>
#include <tos.h>
#include <stdio.h>

#include "dsp_col.h"

/*****************************************************************************/

int mx,my,mb,ks;	/* for mouse */

static OBJECT *obj_addr;
static int xdial, ydial, wdial, hdial;

/***************************************************************/

#define MAX_VAL	255
#define STATE(obj)	(obj_addr+(obj))->ob_state
#define X(obj) 	(obj_addr+(obj))->ob_x
#define Y(obj) 	(obj_addr+(obj))->ob_y
#define WIDTH(obj) 	(obj_addr+(obj))->ob_width
#define HEIGHT(obj)	(obj_addr+(obj))->ob_height
#define TEXT(obj)	(obj_addr+(obj))->ob_spec.tedinfo->te_ptext
#define STRING(obj)	(obj_addr+(obj))->ob_spec.free_string
#define SET_SLIDER(obj,val)	sprintf((obj_addr+(obj))->ob_spec.tedinfo->te_ptext,"%li",(long)(val)*1000/256); (obj_addr+(obj))->ob_y=(long)(val)*((obj_addr+(obj-1))->ob_height-6+1)/256
#define TEST_VAL(val)    	if(val<0) val=0; else if(val>255) val=255

void fader_draw(int tree, char *title, int val_l, int val_r)
{
rsrc_gaddr( R_TREE, tree, &obj_addr );
form_center( obj_addr, &xdial, &ydial, &wdial, &hdial );

form_dial( 0, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
form_dial( 1, 0, 0, 0, 0, xdial, ydial, wdial, hdial );

/* set title */
sprintf(TEXT(F_TITLE),"%.12s",title);
/* set right size of scrollers */
Y(L_SCROLL)=Y(L_UP)+HEIGHT(L_UP)+4;
HEIGHT(L_SCROLL)=Y(L_DOWN)-Y(L_UP)-HEIGHT(L_UP)-4-4;
Y(R_SCROLL)=Y(R_UP)+HEIGHT(R_UP)+4;
HEIGHT(R_SCROLL)=Y(R_DOWN)-Y(R_UP)-HEIGHT(R_UP)-4-4;
/* set position & text of sliders */
SET_SLIDER(R_SLIDER,val_r);
SET_SLIDER(L_SLIDER,val_l);

objc_draw(obj_addr, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);
} /* fader_draw() */



int fader_control(int *l, int *r)
{
int exit_obj, x, y, ret=1;
int val_l=*l,val_r=*r;

wind_update( BEG_UPDATE );

exit_obj = form_do( obj_addr, -1 );
exit_obj &= 0x7fff;

switch(exit_obj) {
case F_EXIT:
	ret=0;
break;
/*** RIGHT SLIDER ***/
case R_SCROLL:
	graf_mkstate(&mx, &my, &mb, &ks);
	objc_offset(obj_addr, R_SCROLL, &x, &y);
	val_r=(my-y)*MAX_VAL/HEIGHT(R_SCROLL);
	TEST_VAL(val_r);
	SET_SLIDER(R_SLIDER,val_r);
	objc_draw(obj_addr, R_SCROLL, 1, xdial, ydial, wdial, hdial);
break;
case R_SLIDER:
	val_r=(long)255*graf_slidebox(obj_addr, R_SCROLL, R_SLIDER, 1)/1000;
	TEST_VAL(val_r);
	SET_SLIDER(R_SLIDER,val_r);
	objc_draw(obj_addr, R_SCROLL, 1, xdial, ydial, wdial, hdial);
break;
case R_DOWN:
	val_r++;
	TEST_VAL(val_r);
	SET_SLIDER(R_SLIDER,val_r);
	objc_draw(obj_addr, R_SCROLL, 1, xdial, ydial, wdial, hdial);
break;
case R_UP:
	val_r--;
	TEST_VAL(val_r);
	SET_SLIDER(R_SLIDER,val_r);
	objc_draw(obj_addr, R_SCROLL, 1, xdial, ydial, wdial, hdial);
break;
/*** LEFT SLIDER ***/
case L_SCROLL:
	graf_mkstate(&mx, &my, &mb, &ks);
	objc_offset(obj_addr, L_SCROLL, &x, &y);
	val_l=(my-y)*MAX_VAL/HEIGHT(L_SCROLL);
	TEST_VAL(val_l);
	SET_SLIDER(L_SLIDER,val_l);
	objc_draw(obj_addr, L_SCROLL, 1, xdial, ydial, wdial, hdial);
break;
case L_SLIDER:
	val_l=(long)255*graf_slidebox(obj_addr, L_SCROLL, L_SLIDER, 1)/1000;
	TEST_VAL(val_l);
	SET_SLIDER(L_SLIDER,val_l);
	objc_draw(obj_addr, L_SCROLL, 1, xdial, ydial, wdial, hdial);
break;
case L_DOWN:
	val_l++;
	TEST_VAL(val_l);
	SET_SLIDER(L_SLIDER,val_l);
	objc_draw(obj_addr, L_SCROLL, 1, xdial, ydial, wdial, hdial);
break;
case L_UP:
	val_l--;
	TEST_VAL(val_l);
	SET_SLIDER(L_SLIDER,val_l);
	objc_draw(obj_addr, L_SCROLL, 1, xdial, ydial, wdial, hdial);
break;
} /* switch() */

wind_update( END_UPDATE );

*l=val_l; *r=val_r; return ret;

} /* fader_control() */



void fader_free(void)
{
form_dial( 2, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
form_dial( 3, 0, 0, 0, 0, xdial, ydial, wdial, hdial );
}


/***
long main(void)
{
int left=0,right=255;

appl_init();

rsrc_load( "DSP_COL.RSC" );
graf_mouse( ARROW, 0L );

fader_draw(FADER,"VOLUME CTRL", left, right);
while( fader_control(&left, &right) ) {
	printf("\rL%i-R%i; ",left,right);
}
fader_close();

rsrc_free();
appl_exit();
return 0;

}
***/