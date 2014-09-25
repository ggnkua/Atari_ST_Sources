/* 
   INITWIND.C Controls opening and closing of a workstation's screen, for
   the startup and exit of a program (generic).

   Kenneth Soohoo
   September 5, 1988		Atari Corporation
 */

#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>

int contrl[12],		/* Must have stuff */
    intin[128], ptsin[128],
    intout[128], ptsout[128];

int work_in[12],	/* Workstation stats */
    work_out[57],
    handle,
    gr_handle;

int app_handle;		/* Application handle */
int res;		/* 0 = low, 1 = medium, 2 = high */
int SCw, SCh;		/* screen width and height */
int num_colors;		/* # colors this device supports */
int micron_width, micron_height;

void mouse_on()
{
	graf_mouse(M_ON, 0);
	return;
}

void mouse_off()
{
	graf_mouse(M_OFF, 0);
	return;
}

void change_mouse()
{
	graf_mouse(ARROW, 0);
}

void mouse_arrow()
{
	graf_mouse(ARROW, 0);
}

void mouse_busy()
{
	graf_mouse(BUSY_BEE, 0);
}

int say_hello()
/* say_hello()
   Connects application with the outside world, saves the colors for later
   restoration.  Also saves the path, so we can restore upon exit.
 */
{
	app_handle = appl_init();

	res = Getrez();

	return(res);			/* Return the current resolution */
}

void open_work()
/* open_work()
   Create a virtual workstation. Get size of station, etc.
 */
{
	int i, dum;			/* Loop variable */

	work_in[0] = res + 2;
	for (i = 1; i < 10; ++i) {	/* Set up normal workstation */
		work_in[i] = 0;
	}
	work_in[10] = 2;		
	gr_handle = graf_handle(&dum, &dum, &dum ,&dum);
	handle = gr_handle;
	v_opnvwk(work_in, &handle, work_out);

	change_mouse();			/* Get an arrow for a cursor */

	SCw = work_out[0] + 1; SCh = work_out[1] + 1;
	num_colors = work_out[13];
	micron_width = work_out[3];
	micron_height= work_out[4];

	return;
}

void close_work()
/* close_work()
   Clears the current screen and then closes up the virtual workstation.
 */
{
	v_clsvwk(handle);			/* Close  workstation */
	graf_mouse(BUSY_BEE, 0l);		/* Return to busy */ 

	return;
}

void clean_up()
/* clean_up()
   Performs menial tasks before exiting the application.
   Restores color map.
 */
{

	appl_exit();			/* Say goodbye */

	return;
}

