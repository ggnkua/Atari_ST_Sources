/*
 * Code to check the drive speed (RPM) on ST drives.
 *
 * GEM version 12/07/87 -- dlm
 */

#include <portab.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <stdio.h>
#include <ctype.h>
#include "speed.h"

/*
 * varying the number of pulses read per drive speed test controls how
 * accurate the speed test will be.  Long periods give better accuracy
 * (about 1 RPM with 8 pulses vs 8 RPM with 1 pulse).  Short periods give
 * better indications of moment-to-moment drive speed but part of their
 * inaccuracy is drift in the index pulse off the disk.  Periods over about
 * 8 pulses don't work since the FDC will shut down the motor about then.
 */
 
#define PULSES (8)		/* number of pulses per time test */
#define TICKS (PULSES * 40L)	/* number of ticks per time test (300 RPM) */

#define FLOCK ((int *)(0x43eL))	/* address of the flock variable	*/

/* 
 * Stuff to call AES.
 */
WORD   contrl[12];
WORD   intin[80];
WORD   ptsin[256];
WORD   intout[45];
WORD   ptsout[12];
WORD   msgbuf[8];

OBJECT_PTR	dialog;		/* the only dialog			*/

GRECT		dial;

WORD		speedx, speedy;

WORD		hchar, wchar;	/* how big is a character?	*/
WORD		VDIhandle;	/* Here VDI. Here VDI. Good VDI.*/

extern void drive_sel();	/* routine to choose the drive to use	*/
extern void motoroff();		/* routine to wait till motor off	*/
extern void drive_step();	/* routine to clear the drive step direction */
extern void driveclr();		/* routine to deselect all drives	*/
extern void drive_pro();	/* routine to check drives protection stat */
extern void drive_status();	/* return the drive status byte in pro_stat */

/* variables used with the select.s code */
int sel_bits;			/* for the drive_sel routine		*/
int pro_stat;			/* drive protection status		*/

int thedisk;

void
init_gem()
{
	register int i;
	WORD     work_in[11], work_out[57], junk;

	appl_init();		/* be trusting, assume it won't fail. (haha) */

	for (i = 0; i < 10; i++)
		work_in[i] = 1;
	work_in[10] = 2;

	VDIhandle = graf_handle(&wchar, &hchar, &junk, &junk);

	v_opnvwk(work_in, &VDIhandle, work_out); /* open virtual work stn */

	vst_alignment(VDIhandle, 0, 5, &junk, &junk);

	/* we have now told AES/VDI everything they wanted to know
	   about us but were afraid to ask.  What a pain in the ass. */

	rsrc_load("speed.rsc");	/* get the resource */
	
	rsrc_gaddr(R_TREE, DIALOG,   &dialog);	/* and the address of our tree */

}

void
show_speed(spd)
int spd;
{
	char str[8];

	itoa_s(spd, str, 3);
	v_gtext(VDIhandle, speedx, speedy, str);
}

void
show_msg(str)
char *str;
{
	dialog[MSG].spec = str;	/* hook the string in */
	objc_draw(dialog, ROOT, MAX_DEPTH, dial.x-1, dial.y-1,dial.w+2, dial.h+2);
}

void
clear_msg()
{
	static char str[1] = { 0 };

	dialog[RPM].spec = str;	/* also nuke the RPM display */
	show_msg(str);
}

void
set_drive()
{
	if (thedisk == 0)
		sel_bits = 0x04;	/* select low logic */
	else
		sel_bits = 0x02;	/* select low logic */
}

static void
clear_sel()
{
	Supexec(driveclr);
}

void
flock_on()
{
	/*
	 * keep the ST from screwing with things
	 */
	*FLOCK = 1;
	Vsync();
	Vsync();	/* give it two vblanks to settle things down */
}

void
flock_off()
{
	Vsync();
	Vsync();	/* wait two vblanks, give time to xlator */
	/*
	 * give it back to the ST
	 */
	*FLOCK = 0;
}

void
motor_off()
{
	/*
	 * if on the xlator, turn off the motor that the STs FDC is holding
	 * on from the drive_step() call.  In "theory" this isn't needed since
	 * the step is done without having the motor on bit set.  But WD lied,
	 * a step always forces the motor on.  Really nice of them to do
	 * that isn't it.
	 */
	Supexec(flock_on);	/* don't let the vblank screw us */
	Supexec(motoroff);	/* do it as super		*/
	Supexec(flock_off);	/* the drives are the STs now	*/
}

static long sys_time;	/* scratch variable for time code */

static void
get_time()
{
	sys_time = *((long *) 0x04baL);
}

int
pulse()
{
	Supexec(drive_status);
	return(pro_stat & 0x02);	/* bit 1 is the index pulse flag */
}

int
wait_pulse()
{
	/*
	 * wait for a single index pulse with timeout.
	 *
	 * it's possible that we can call drive_status fast enough to see
	 * a single index pulse more than once (it lasts a long time 
	 * compared to a 68K command).  so we loop for it to turn on
	 * then wait for it turn back off.
	 */
	register long time_out;

	Supexec(get_time);
	time_out = sys_time + 100L;	/* allow 1/2 seconds (more than enough) */

	while (!pulse()) {	/* wait for the start of a pulse */
		Supexec(get_time);
		if (sys_time > time_out)
			return (0);	/* timed out */
	}

	while (pulse()) {	/* wait for the end of a pulse */
		Supexec(get_time);
		if (sys_time > time_out)
			return (0);	/* timed out */
	}

	return(1);
}

int
count_pulse(count)
int count;
{
	/*
	 * call the low level code and check for index pulses,
	 * attempt to read count pulses while checking for a timeout
	 * of 1 second.  If all pulses read return true else return false.
	 *
	 */
	while (count--) {
		if (wait_pulse() == 0)
			return(0);	/* we lost */
	}
	return (1);	/* we won */
}

void
main()
{
	register long start, end;
	register long time;
	register int first;
	register int which;
	WORD MouseX, MouseY, GEMbutton;

	init_gem();

	graf_mouse(0, 0L);	/* arrow */
	form_center(dialog, &dial.x, &dial.y, &dial.w, &dial.h);
	form_dial(FMD_START, dial.x, dial.y, dial.w, dial.h, dial.x, dial.y, dial.w, dial.h);

	objc_offset(dialog, RPM, &speedx, &speedy);

	clear_msg();	/* also draws dialog box */

	thedisk = -1;	/* say no disk installed */

	for(;;) {	/* loop until done */
		vq_mouse(VDIhandle, &GEMbutton, &MouseX, &MouseY);

		if (GEMbutton == 1) { /* button event? */

			which = objc_find(dialog, ROOT, MAX_DEPTH, MouseX, MouseY);

			switch (which) {
			case QUIT :	/* done? */
				if (thedisk != -1)
					motor_off();	/* free flock_off */
				if (thedisk == -1) {/* clean up GEM */
					Supexec(flock_off);
					v_clsvwk(VDIhandle);
					appl_exit();
					_exit();
				}
				thedisk = -1;	/* not testing */
				DeselObj(dialog, DRIVEA);
				DeselObj(dialog, DRIVEB);
				clear_msg();
				while (GEMbutton) /* till button up */
					vq_mouse(VDIhandle, &GEMbutton, &MouseX, &MouseY);
				break;
			case DRIVEA :
				thedisk = 0;
				first = 0;	/* force a spin up delay */
				SelObj(dialog, DRIVEA);
				DeselObj(dialog, DRIVEB);
				clear_msg();
				break;
			case DRIVEB :
				thedisk = 1;
				first = 0;	/* force a spin up delay */
				SelObj(dialog, DRIVEB);
				DeselObj(dialog, DRIVEA);
				clear_msg();
				break;
			}
		}			

		if (thedisk == -1)
			continue;	/* loop back if no disk */

		Supexec(flock_on);

		set_drive();	/* set the select mask */

		Supexec(drive_step);	/* forces the drive to spin up */

		/*
		 * wait 1 second to allow a spinup on first loop
		 * on a given drive.
		 */
		if (first) {
			Supexec(get_time);
			end = sys_time + 201L;

			do {
				Supexec(get_time);
			} while (sys_time < end);
			first = 1;
		}

		/*
		 * then select the drive
		 */
		Supexec(drive_sel);	/* select drive     */
	
		/*
		 * before starting the timer wait till a single pulse occurs.
		 * this will ensure that the timing interval is constant
		 */
		wait_pulse();		/* get sync'd up before timing */
	
		Supexec(get_time);
		start = sys_time;
	
		/*
		 * wait one less than PULSES since we will use up a full 
		 * rev before the first one comes by.  By doing the 
		 * wait_pulse above this "extra" interval is always constant.
		 */
		if (count_pulse(PULSES) == 0) {
			/*
			 * timed out, must be no disk in the drive
			 */
			thedisk = -1;
			DeselObj(dialog, DRIVEA);
			DeselObj(dialog, DRIVEB);
			show_msg("No index pulse from drive.");
			clear_sel();	/* deselect all drives */
			continue;	/* jump back to evnt call */
		}
	
		Supexec(get_time);
		end = sys_time;
	
		/*
		 * the drive is spinning at 300 RPM, so there should be
		 * 300 index pulses per minute or 1 index pulse every 
		 * 1/5 second (40 ticks).
		 *
		 * 5 index pulses should occur in 1/60 minute or 1 second
		 * or 200 timer ticks.
		 *
		 * Dividing delta off the ideal time by 200 gives 
		 * fraction fast/slow (do this in floats). Multiply
		 * by 300 to get RPM slow/fast add to 300 to get real speed.
		 */
	
		time = TICKS - (end - start);

		show_speed((int) (((time * 300L) / TICKS) + 300L));
	
	}

	/* never reaches here */	
}

