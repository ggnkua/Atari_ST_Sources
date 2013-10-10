#include <gemdefs.h>	/* include file for definitions */
#include <osbind.h>	/* include file for xbios calls */

/* Useful definitions for this program */
#define RETURN 0x1C0D	/* Return key code */

/*	This program prints different text at the mouse position 	    */
/*	determined by which mouse button (or combination) is pressed. 	    */
/* 	Link the assembled new button handler at the end of link statement: */
/*									    */
/*	mac -u -6 button.s						    */
/* 	aln -o button apstart button vdibind aesbind osbind newbut	    */
/*									    */
/*	To exit press the RETURN key. 					    */

/* Global arrays */

int contrl[12], intin[256], ptsin[256], intout[256], ptsout[256];
int dummy;
extern int BUT_STATE;			/* True button state */
extern long NEW_BUT();			/* New button handler */
extern long BUT_ADDR;				/* Old button handler */
unsigned key;

main()
{
int handle, i;
int charw, charh, boxw, boxh;
int mgbuf[8];
int xres,yres;
int abort;
unsigned int which=(MU_KEYBD|MU_BUTTON);
int selection;
int xyarray[4];
int clicks, button, buttonstate;
int mousex,mousey,width,depth;

	/* Set the system up to do GEM calls*/
appl_init();

	/* Get the handle of the desktop */
handle=graf_handle(&charw,&charh,&boxw,&boxh);

	/* Open the workstation. */
intin[0] = Getrez()+2;
for (i=1; i<10; ++i) intin[i] = 1;
intin[10] = 2;

v_opnvwk(intin, &handle, intout);

	/* Keep track of the size of the screen */
xres=intout[0];
yres=intout[1];
xyarray[1]=xyarray[0]=1;xyarray[2]=xres-1;xyarray[3]=yres-1;
vs_clip(handle,1,xyarray);

graf_mouse(ARROW,&dummy);	/* Reset mouse form to arrow */

vex_butv(handle,&NEW_BUT,&BUT_ADDR);  /* new button handler,old button handler */

clicks=1;
button=1;
buttonstate=1;

graf_mouse( M_OFF, 0L );
v_gtext( handle, 0, charh, "Press [Return] to exit" );
graf_mouse( M_ON, 0L );
 
for (;;)
	{
	selection=evnt_multi(which,
			clicks,button,buttonstate,
			0,0,0,0,0,
			0,0,0,0,0,
			&mgbuf,
			0,0,
			&mousex,&mousey,
			&dummy,
			&dummy,
			&key,
			&dummy);

	abort=0;		/* reset flag */

	
	if (selection|MU_KEYBD)
		if (key == RETURN)
			abort=1;
	
	if (selection == MU_BUTTON)	/* display text for button states */

		{
		if (BUT_STATE == 1)
			v_gtext(handle,mousex,mousey,"    left");
		else if (BUT_STATE == 2)
			v_gtext(handle,mousex,mousey,"  right");
		else if (BUT_STATE == 3)
			v_gtext(handle,mousex,mousey,"both");
		}
	if (abort) break;

	}	/* for */
	
	/* Cleanup -  return to the system button handler */
vex_butv(handle,BUT_ADDR,&dummy);

v_clsvwk(handle);			/* Close the workstation. */
 
appl_exit();				/* Release GEM calls */

}
