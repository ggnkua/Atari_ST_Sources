/***************************************************************************** 
 *															  * 
 *						The PROTECTOR							  * 
 *							 by								  * 
 *						Daniel L. Moore						  *	
 *							and								  *
 *					   David Small number 1						  *
 *															  *	
 *				    version 1.000002 for Megamax C (ONLY!)			  * 
 *					works, but crashes on rez changes.  Worry about	  *
 *					that later.								  *
 *						   10/06/86							  * 
 *				    version 1.000003 still for Megamax C			  *
 *					try using AC_CLOSE to remove program when a rez	  *
 *					change is made.							  *
 *						   12/14/86							  *
 *				    version 1.000004 amazing! Still only for Megamax C   *
 *					 change made to install/remove code to handle	  *
 *					 rez changes.	AC_CLOSE can't be used since it      *
 *					 is also sent on every application termination.	  *
 *						   12/16/86							  *
 *															  * 
 *	A software write protect switch for any drive on the system A to F.	  * 
 *															  *
 *****************************************************************************
 *															  *
 *				Dedication:									  *
 *															  *
 *	To Binkley, because he needs the protection from his Anxiety closet.	  *
 *															  * 
 *****************************************************************************/


#include <portab.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include "prtect.rsh"
#include "protect.h"

/* misc defines */
#define TRUE	1
#define FALSE	0
#define RETRY	0x00010000

/* Stuff to call AES.  Needed to run as a DA */
WORD   contrl[12];
WORD   intin[80];
WORD   ptsin[256];
WORD   intout[45];
WORD   ptsout[12];
WORD   msgbuf[8];
WORD   VDIhandle;

/* external variables (defined in system library) */
extern WORD gl_apid;

/* typedefs to make declarations easier */
typedef LONG (*L_FUNC)();	/* pointer to function returning a long */

/* misc. global work variables */
WORD     protect[6] = {0, 0, 0, 0, 0, 0}; /* protect flag for drives A to F */
WORD     mode; 					  /* desired write with verify mode */
L_FUNC   sys_rwabs; 				  /* old rwabs routine.			 */
L_FUNC  *rwvect = (L_FUNC *) 0x476;	  /* pointer to current rwabs 	 */
L_FUNC  *critic = (L_FUNC *) 0x404L;	  /* system critical error handler  */

extern saveA4(), exit(), _exit();
asm {
exit:				; just to fool the linker and prevent the inclusion
_exit:				; of unneeded (and unwanted) library routines

saveA4:	dc.l 0		; pointer to global variables 
					; in program segment so rwabs can get it
}

LONG
my_rwabs(rw, buf, count, recno, dev)
BYTE *buf;
WORD  rw, count, recno, dev;
{
	LONG ret;
	/* at this point the trap dispatcher has saved D3-D7/A3-A6 */
	asm {
		movea.l	saveA4(PC), A4 	; Megamax global variable pointer 
	}

	if (rw & 1) {			   /* write command */
		if (dev < 6)		   /* drive A to F? */
			if (protect[dev]) { 	/* is the drive write protectd? */
				/*
				 * call the critical error handler with a write protected
				 * disk error								 
				 */
				while((ret = (**critic)(-13, dev)) == RETRY);
				return(ret);
			}
	}

	/* 
	 * Not our drive or not write protected, either way pass the call thru
	 * to the system rwabs routine.							 
	 */
	return((*sys_rwabs)(rw, buf, count, recno, dev));
}

get_sysrwabs()
/*
 * read the default sysrwabs vector 
 */
{
	sys_rwabs = *rwvect;
}

install()
/* 
 * Patch our rwabs into the system, must run as super since it mucks with
 * protected memory.										 
 */
{
	*rwvect = my_rwabs;
}

remove()
/* 
 * We aren't wanted here.  So we'll take our ball and go home.  So there!
 */
{
	*rwvect = sys_rwabs;
}

read_v()
/* return the current write verify status */
{
	mode = *((WORD *) 0x444L);
}

write_v()
/* change the write verify status */
{
	*((WORD *) 0x444L) = mode;
}

main()
{
	/* 
	 * lets do all sorts of perverted stuff to the bios i/o code.
	 */
		  LONG  drives;
		  WORD  x, y, w, h, dummy, pflag;
	static WORD  dbuttons[] = {DRIVEA, DRIVEB, DRIVEC, DRIVED, DRIVEE, DRIVEF};

	/*
	 * first get the base address for the global variables so our rwabs can
	 * use them.
	 */
	asm {
		lea saveA4(PC), A0
		move.l A4, (A0)
	}

	/*
	 * Install myself as a GEM app. 
	 *	  Dan, you are a GEM app.  (NO, THAT ISN'T WHAT I MEANT!)
	 *
	 * Lets be lazy.  It "never" fails.  haha  (Trusting aren't we.)
	 */

	appl_init();

	/* get the physical work station handle. for my form_do */
	VDIhandle = graf_handle(&dummy, &dummy, &dummy, &dummy);

	/* Go fix up the string pointers in the dialog. */
	for (w = h = 0; h < NUM_OBS; h++) {
		rsrc_obfix(rs_object, h);		 /* fix the coordinates system */
		if (rs_object[h].type == G_STRING || rs_object[h].type == G_BUTTON)
			rs_object[h].spec = rs_strings[w++];
	}

	/* Stick the name in the DA pull down */
	menu_register(gl_apid, "  The PROTECTOR");

	/* find the current rwabs routine */
	Supexec(get_sysrwabs);

	/* set the floppy to no verify (new default) */
	mode = FALSE;
	Supexec(write_v);

	/*
	 * Lets go look at the drives on the system and set the buttons.
	 * This is the short way to init the .rsh file.  Don't.
	 * It works so quit complaining. The qoal is to be SHORT.
	 */
	drives = Drvmap();

	for (w = 0; w < 6; w++, drives >>= 1)
		if (!(drives & 1)) 
			rs_object[dbuttons[w]].state |= DISABLED;

	for (;;) {  /* loop forever or at least till the machine is turned off */

		/* GEM, GEM, are you there GEM? */
		evnt_mesag(msgbuf);

		if (msgbuf[0] == AC_OPEN) { /* start up.  yeah! */
			/* deselect the OK button */
			rs_object[BUTTONOK].state = 0;

			if (mode)
				rs_object[VERIFY].state |= SELECTED;
			else
				rs_object[VERIFY].state &= ~SELECTED;

			/* put up the dialog */
			form_center(rs_object, &x, &y, &w, &h);
			form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
			objc_draw(rs_object, ROOT, 9, x-1, y-1, w+2, h+2);
			/* 
			 * As you may gather, this isn't the normal form_do.
			 * If you are using the normal one (highly likely 
			 * since you don't have mine) just remove the 
			 * ", 0L, 0L" from the call.  (No, you can't
			 * ask what they are far.  I'm not there so how
			 * can you ask?)
			 */
			form_do(rs_object, 0, 0L, 0L);
			form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);

			/*
			 * check which drive buttons were selected.	For each one
			 * set the protect array entry for that drive. 
			 */
			pflag= FALSE;
			for (w = 0; w < 6; w++) 
				pflag |= protect[w] = rs_object[dbuttons[w]].state & SELECTED;

			/*
			 * if pflag is true a drive is write protected.  That
			 * means we should install our rwabs routine.
			 *
			 * otherwise we should install the system rwabs
			 * routine.  (This _MUST_ be done before a rez change.
			 * GEM clears the RAM used by .ACC's when a rez change
			 * is made, which kills our rwabs code.  If the vector
			 * points to our code, bad things will happen the next
			 * time disk i/o is attempted.  So always unprotect
			 * all drives before a rez change is attempted.)
			 */
			if (pflag)
				Supexec(install);
			else
				Supexec(remove);

			/* read the verify setting */
			if (rs_object[VERIFY].state & SELECTED)
				mode = TRUE; /* write verified */
			else
				mode = FALSE;
			Supexec(write_v);
		}
	}
	/* if we ever get here we are in BIG trouble. */
}

