/* Resource file example */
/*   By  Janice Murray   */

#include <obdefs.h>
#include <osbind.h>

#define DIALOGUE	0	/* form/dialog */
#define QUIT		3	/* BUTTON in tree DIALOGUE */
#define BUTTONA		5	/* BUTTON in tree DIALOGUE */
#define BUTTONB		6	/* BUTTON in tree DIALOGUE */
 
#define POINTER		0	/* mouse macros */
#define SHOW		257
#define HIDE		256
 
int contrl[12],
     intin[128],
     intout[128],
     ptsin[128],
     ptsout[128],
     work_in[12],
     work_out[57];

int	handle,			/* vdi handle */
	ch,				/* character height */
	cw,				/* character width */
	x,y,w,h;		/* dialog coords */

OBJECT *dialog;

gem_on()
{
	int i;
	appl_init();
	handle = graf_handle(&cw,&ch,&i,&i);	/* i is dummy variable */
	for (i = 0; i < 10; work_in[i++] = 1);	/* fill work_in[] */
	work_in[10] = 2;
	v_opnvwk(work_in,&handle,work_out);	/* open workstation */
}
 
gem_off()
{
	rsrc_free();		/* free memory used by resource */
	v_clsvwk(handle);	/* close workstation */
	appl_exit();		/* exit program */
}
 
main()
{
	gem_on();		/* initialise program */
	if (!rsrc_load("test.rsc"))
		gem_off();	/* exit if can't find resource */
	rsrc_gaddr(0,DIALOGUE,&dialog);	/* get dialog address */
	form_center(dialog,&x,&y,&w,&h);	/* centre dialog */
	do_dialog();
	gem_off();		/* exit */
}
 
do_dialog()
{
	int result;
	graf_mouse(POINTER,0);	/* mouse pointer */
	graf_mouse(HIDE,0);		/* hide mouse */
	form_dial(0,0,0,0,0,x,y,w,h);		/* save screen */
	objc_draw(dialog,0,32767,x,y,w,h);	/* draw dialog */
	do {
		graf_mouse(SHOW,0);
		do {
			result = form_do(dialog,0);	/* do dialog */
		} while ( result!=QUIT );
		graf_mouse(HIDE,0);	/* hide mouse */
		dialog[result].ob_state ^= SELECTED;	/* de-select object */
		objc_draw(dialog,result,0,x,y,w,h);		/* draw it */
	}while (result != QUIT);
	graf_mouse(SHOW,0);		/* show mouse */
	form_dial(3,0,0,0,0,x,y,w,h);	/* restore screen */
}
