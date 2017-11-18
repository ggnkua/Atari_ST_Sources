#include "mentst.h"	/* include file from RCS */
#include <gemdefs.h>	/* include file for definitions */
#include "osbind.h"

/* Useful definitions for this program */
#define HIDE_MOUSE graf_mouse(256,&dummy)
#define SHOW_MOUSE graf_mouse(257,&dummy)
#define NORMAL 1
#define PATTERN 2
#define SHOW 1

/* Global arrays */

int contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];

main()
{
int handle, i, dummy;
int charw, charh, boxw, boxh;
long menuadd;
int mgbuf[8];
int xres,yres;
int pattern,abort;

/* Set the system up to do GEM calls*/

appl_init();

/* Get the handle of the desktop */

handle=graf_handle(&charw,&charh,&boxw,&boxh);

/* Open the workstation. */

intin[0]=Getrez()+2;
for (i=1; i<10; i++) intin[i] = 1;
intin[10] = 2;


v_opnvwk(intin, &handle, intout);

/* Keep track of the size of the scrren */

xres=intout[0];
yres=intout[1];

/* Fill with patterns for circle */
vsf_interior(handle,PATTERN);
rsrc_load("MENTST.RSC");	/* Load resource file */
rsrc_gaddr(0,TREE1,&menuadd);	/* get address of loaded file */
HIDE_MOUSE;
menu_bar(menuadd,SHOW);		/* Show the menu bar */
SHOW_MOUSE;
graf_mouse(ARROW,&dummy);	/* Reset mouse form to arrow */
while (evnt_multi(MU_MESAG,
	0,0,0,			/*evnt_button*/
	0,0,0,0,0,		/*evnt_mouse1*/
	0,0,0,0,0,		/*evnt_mouse2*/
	&mgbuf,			/*evnt_mesg*/
	0,0,			/*evnt_timer*/
	&dummy,&dummy,		/*mouse x,y*/
	&dummy,			/*mouse button*/
	&dummy,			/*shift keys*/
	&dummy,			/*evnt_keyboard*/
	&dummy)==MU_MESAG)	/*number of clicks*/

{
	wind_update(1);		/* grab the screen */
	abort=0;		/* reset flag */
	switch (mgbuf[0])	/* check message type */
	{
	case MN_SELECTED:
		switch (mgbuf[4])
		{
		case PAT1:
			pattern=9;
			break;
		case PAT2:
			pattern=10;
			break;
		}
		menu_tnormal(menuadd,mgbuf[3],NORMAL); /* set menu to normal */
		if (mgbuf[4]==QUIT) abort=1;
		else
			{
			vsf_style(handle,pattern);
			v_circle(handle,xres/2,yres/2,yres/4);
			}
		break;
	}
	wind_update(0);		/* let go of the screen */
	if (abort) break;	/* if QUIT then leave */
}

/* Close the workstation. */
 
v_clsvwk(handle);
 
 /* Release GEM calls */

appl_exit();

}
