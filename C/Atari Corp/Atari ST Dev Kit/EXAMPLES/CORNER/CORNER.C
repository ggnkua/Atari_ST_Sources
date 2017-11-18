#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include "corner.h"	/* Contains definitions made with RCS */
#define ROOT 0
#define HIDE_MOUSE graf_mouse(256,&dummy)
#define SHOW_MOUSE graf_mouse(257,&dummy)

int contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];

main()
{
int handle, i, dummy;
int deskx,desky,deskw,deskh;	/* size of desktop area */
OBJECT *boxadd, *other;
int x,y,w,h,xdial,ydial,wdial,hdial;
int xother,yother,wbox,hbox;
int choice;

/* Set the system up to do GEM calls*/

appl_init();

/* Get the handle of the desktop */

handle=graf_handle(&dummy,&dummy,&dummy,&dummy);

/* Open the workstation. */

intin[0]=Getrez()+2;
for (i=1; i<10; i++) intin[i] = 1;
intin[10] = 2;

v_opnvwk(intin, &handle, intout);

graf_mouse(ARROW,&dummy);

x=y=w=h=0;

wind_get(0,WF_WORKXYWH,		/* get edges of desktop */
	&deskw,&desky,&deskw,&deskh);
rsrc_load("CORNER.RSC");	/* load in resource file */
rsrc_gaddr(0,TREE1,&boxadd);	/* get address of structure */
rsrc_gaddr(0,TREE2,&other);	/* get address of structure */
form_center ( boxadd, &xdial, &ydial, &wdial, &hdial );

/* do this ONLY to get the size */
form_center ( other, &dummy, &dummy, &wbox, &hbox );

while ((boxadd[UNCLE].ob_state&SELECTED)!=SELECTED)
	{
	form_dial ( 0, x, y, w, h, xdial, ydial, wdial, hdial );
	form_dial ( 1, x, y, w, h, xdial, ydial, wdial, hdial ); 
	objc_draw ( boxadd,ROOT,1, xdial, ydial, wdial, hdial );
	form_do ( boxadd, 0 ); 
	form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 
	form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 

	choice=-1;
	if ((boxadd[UL].ob_state&SELECTED)==SELECTED)
		choice=UL;
	if ((boxadd[UR].ob_state&SELECTED)==SELECTED)
		choice=UR;
	if ((boxadd[LL].ob_state&SELECTED)==SELECTED)
		choice=LL;
	if ((boxadd[LR].ob_state&SELECTED)==SELECTED)
		choice=LR;
	switch(choice)
		{
		case UL:
			xother=deskx;
			yother=desky;
			break;
		case UR:
			xother=deskx+deskw-wbox;
			yother=desky;
			break;
		case LL:
			xother=deskx;
			yother=desky+deskh-hbox;
			break;
		case LR:
			xother=deskx+deskw-wbox;
			yother=desky+deskh-hbox;
			break;
		}
	if (choice==-1)
		break;
	boxadd[choice].ob_state=NORMAL;
	form_dial (0,x,y,w,h,xother,yother,wbox,hbox);
	form_dial (1,x,y,w,h,xother,yother,wbox,hbox);

/*	This is the important stuff
	The x,y,width,height
	were set by the form_center
	call above	*/
	other[ROOT].ob_x=xother;
	other[ROOT].ob_y=yother;
	other[ROOT].ob_width=wbox;
	other[ROOT].ob_height=hbox;
	objc_draw (other,ROOT,1,xother,yother,wbox,hbox);
	form_do (other,ROOT);
	form_dial (2,x,y,w,h,xother,yother,wbox,hbox);
	form_dial (3,x,y,w,h,xother,yother,wbox,hbox);
	other[OVER].ob_state=NORMAL;
	}

rsrc_free();	/* free up memory used by resource file */

/* Close the workstation. */
 
v_clsvwk(handle);
 
 /* Release GEM calls */

appl_exit();

}
