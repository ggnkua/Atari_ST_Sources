/*
 * XaAES MOUSE SERVER
 *  (w)1995,1996, by Craig Graham.
 */

/*
	This short program is forked off by XaAES during bootup.
	It basicly writes a packet to the mouse data pipe every time a mouse 
	event occurs, and yields to the OS the rest of the time.

	This handles multiple button clicks ok (1, 2 or more clicks).

	The way all this is done is quite CPU intensive - I hope someone can sort me
	out a different way of doing this, but in the mean time......at least it takes
	all the busy waiting out of the AES kernal, and yields as much CPU time as
	possible.

	The format & size of a mouse data packet is different to a standard AES
	command packet, so there is a special mouse.XA pipe to handle them.

	This isn't designed to exit gracefully - if MOUSESRV crashes you have
	problems, as the vex_motv & vex_butv vectors are hooked into it, and will
	NOT be unhooked in event of a crash.
*/

#include <VDI.H>
#include <OSBIND.H>
#include <TIME.H>
#include <MINTBIND.H>
#include <FILESYS.H>
#include <signal.h>
#include "XA_CODES.H"
#include "K_DEFS.H"
#include "KERNAL.H"
#include "MOUSESRV.H"

far int MOUSE_cmd_pipe;		/* Handle to the AES mouse data pipe */
far short V_handle;			/* VDI handle for the AES */

far short button_state;

/* Button click packet */

far MOUSE_DATA button_click_packet;

/* Detection for double clicks */
far short c_count=0;
far short mx=0;
far short my=0;
far short rmx=0;
far short rmy=0;
far short count_clicks=0;
far short temp=0;
far short vdi_timer=0;

far int __regargs (*old_mouse_button_vector)(short);
far int __regargs (*old_mouse_coords_vector)(short,short);
far int (*old_timer_vector)(void);

/* Click handler - hooked into the vex_butv */
__saveds __regargs int mouse_button_handler(short state)
{
	preserve_regs();

	if (!button_state)
	{
		button_state=state;		/* Capture the button state */
		rmx=mx; rmy=my;			/* location of click */
	}
	state=old_mouse_button_vector(state);	/* Call old mouse button handler as well (for now) */

	if (state)
		c_count++;				/* Increment click count */

	restore_regs();

	return (int)state;
}

/* Coords handler - hooked into the vex_motv */
__saveds __regargs int mouse_coords_handler(short x, short y)
{
	preserve_regs();

	mx=x; my=y;							/* Capture coords */

	temp=old_mouse_coords_vector(x,y);	/* Call old mouse coords handler as well (for now) */

	restore_regs();

	return (int)temp;
}

/* Timer Interupt handler - used to get accurate timing of double clicks */
__saveds int timer_handler(void)
{
	preserve_regs();

	vdi_timer++;				/* The vdi_timer variable gets increamented 50 times a second */

	temp=old_timer_vector();	/* Call old vdi timer vector */

	restore_regs();

	return (int)temp;
}

void hook_mouse(void)
{
/* Hook into the VDI mouse handler */
	vex_butv(V_handle, mouse_button_handler, &old_mouse_button_vector);
	vex_motv(V_handle, mouse_coords_handler, &old_mouse_coords_vector);
/* Hook the VDI timer to get accurate timing of double clicks */
	vex_timv(V_handle, timer_handler, &old_timer_vector,&temp);
}

short Terminated=0 ;

/* This SIGTERM handler only sets a flag - VDI calls
	are not allowed from within a signal handler! */
__saveds void DoTerminate(void)
{
	Terminated=1 ;
}

/* Hard coded Double-Click timing = 25 timer ticks */
/* (50 ticks a second, this == 0.5 seconds) - this should really be replaced with a  */
/* value that is changable on the fly. */
#define DC_TIME 25

void main(int argc, char *argv[])
{
	short t;
	long tm;

	DIAGS(("XaAES MOUSE SERVER v0.3\n"));
	DIAGS(("(w)1995,1996 by Craig Graham\n"));
	
	if (argc!=2)
	{
		DIAGS(("MS: ERROR - wrong number of parameters\n"));
		return;
	}
	
	V_handle=atoi(argv[1]);		/* argument 1 is the AES VDI workstation handle */

	MOUSE_cmd_pipe=Fopen("u:\\pipe\\mouse.XA", O_RDWR);

	Pnice(-5);					/* We run as a low priority process */
	
	Psignal(SIGTERM, (long)DoTerminate);
	hook_mouse();				/* Hook into the vex_butv() VDI vector */

/* Main loop - we almost never exit this */
	while (!Terminated)
	{
		if (button_state)		/* Yes, I know it's busy waiting - hopefully someone can help me out here */
		{
			button_click_packet.state=button_state;		/* Embed the button state into the packet (not a pointer to the button state) */
														/* We always return the first button state (so, left click-right click registers as double-left-click) */

			button_click_packet.mx=rmx;					/* Embed the mouse coords for the click */
			button_click_packet.my=rmy;

			vdi_timer=0; tm=time(0);

/* Allow time for a double click to occur if it's going to - use the short DC_TIME for double clicks */
/* time(0)-tm is used as well for click & drag, as the vdi timer interupt is inhibited by a mouse button */
/* being down (whose daft idea was that? thankyou atari (and 2B 'coz NVDI does the same thing)) */
/* Also added a quick check - if the mouse moves more than +/-1 pixel in either axis, we stop */
/* counting clicks. */
			while(((vdi_timer<DC_TIME)&&(time(0)-tm<1))	
					&&((abs(mx-rmx)<2)
					&&(abs(my-rmy)<2)));

			button_click_packet.clicks=c_count;			/* Embed the click count */

			if (!Fwrite(MOUSE_cmd_pipe, sizeof(MOUSE_DATA), &button_click_packet))
			{
				DIAGS(("MS: ERROR - cann't write to command pipe XaAES.cmd\n"));
			}

			button_state=0;					/* Reset button state */
			c_count=0;						/* Reset click count to 0 */
		}
		Syield();							/* Give up some process time */
	}

	DIAGS(("MS: Unhooking mouse vectors & exitting\n"));

	vex_butv(V_handle, old_mouse_button_vector, &old_mouse_button_vector);
	vex_motv(V_handle, old_mouse_coords_vector, &old_mouse_coords_vector);
	vex_timv(V_handle, old_timer_vector, &old_timer_vector, &t);
}
