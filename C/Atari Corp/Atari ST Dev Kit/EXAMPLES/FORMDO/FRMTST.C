#include "form.h"	/* Contains definitions made with RCS */
#include <osbind.h>

#define HIDE_MOUSE graf_mouse(256,&dummy)
#define SHOW_MOUSE graf_mouse(257,&dummy)

int contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];

main()
{
int handle, i, dummy;
int charw, charh, boxw, boxh;
long boxadd;
int mgbuf[8];
char decimal[4];
int x,y,w,h,xdial,ydial,wdial,hdial;

/* Set the system up to do GEM calls*/

appl_init();

/* Get the handle of the desktop */

handle=graf_handle(&charw,&charh,&boxw,&boxh);

/* Open the workstation. */

for (i=1; i<10; ++i) intin[i] = 1;
intin[10] = 2;

x=y=w=h=0;	/* variables for growbox */

v_opnvwk(intin, &handle, intout);

rsrc_load("FORM.RSC");	/* load in resource file */
rsrc_gaddr(0,TREE1,&boxadd);	/* get address of parent object */

	/* find out the size and position of a centered box */
	form_center ( boxadd, &xdial, &ydial, &wdial, &hdial );

	/* reserve room on the screen */
	form_dial ( 0, x, y, w, h, xdial, ydial, wdial, hdial );

	/* draw a growing box */
	form_dial ( 1, x, y, w, h, xdial, ydial, wdial, hdial ); 

	/* draw the dialog box */
	objc_draw ( boxadd,TREE1,1, xdial, ydial, wdial, hdial );

	/* allow user input */
	form_do ( boxadd, 0 ); 

	/* draw shrinking box */
	form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 

	/* free up screen area */
	form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 

rsrc_free();	/* free up memory used by resource file */

/* Close the workstation. */
 
v_clsvwk(handle);
 
 /* Release GEM calls */

appl_exit();

}
