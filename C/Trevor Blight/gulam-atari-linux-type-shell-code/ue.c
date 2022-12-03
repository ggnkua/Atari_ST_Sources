/*
	ue.c of Gulam -- builtin microEmacs

This file is a revised version of the public domain one written by
Dave G.  Conroy.  It contains the main driving routine of uE, and some
keyboard processing code, for the microEmacs screen editor.

Revisions by: prabhaker mateti, sep-86, made it part of gulam;
prabhaker mateti, 3-Jan-86, ported to Atari 520ST Steve Wilhite,
30-Nov-85

*/

#include        "ue.h"
#include	"keynames.h"

#ifdef STANC
# define P_(s) s
#else
# define P_(s) ()
#endif
local enter P_((void));
local execute P_((int f, int n, int c));
#undef P_

uchar	msginit[] = "\xe6\xee as adapted by tbb " __DATE__;

local	execute();

int     thisflag;                       /* Flags, this command          */
int     lastflag;                       /* Flags, last command          */

int	exitue = 2;	/* == 2    => uebody is not active		*/
			/* == 3    => tried to enter, but fatal err	*/
			/* == 1,4  => uebody active, but about to leave	*/
			/* == 0    => within enter() --> uebody()	*/
			/* == -1   => uebody active, via >mini<		*/

local	int	nctlxe;			/* arg of ctlxe			*/
local	uchar	kbdm[NKBDM];		/* kbd macro area               */
local	uchar	*kbdmip;		/* Input  for above             */
local	BUFFER	*fgbp;
local	int	rdonly;

/* Normally bound to ^U	*/

	int
getarg()
{
        register int    c;
        register int    n;
        register int    mflag;

	n = 4;                          /* with argument of 4 */
	mflag = 0;                      /* that can be discarded. */
	mlwrite("Arg: 4");
        while ((c=getctlkey()) >='0' && c<='9' || c==(CTRL|'U') || c=='-')
	{       if (c == (CTRL|'U')) n *= 4;
                else
                /* If dash, and start of argument string, set arg to -1.  */
		/* Otherwise, insert it.  */
		if (c == '-')
                {	if (mflag) break;
                        n = 0;
                        mflag = -1;
                }
                /* If first digit entered, replace previous argument */
		/* with digit and set sign.  Otherwise, append to arg. */
                else
                {	if (!mflag) {n = 0; mflag = 1;}
                        n = 10*n + c - '0';
                }
                mlwrite("Arg: %d", (mflag >=0) ? n : (n ? -n : -1));
        }
	/* Make arguments preceded by a minus sign negative and change */
	/* the special argument "^U -" to an effective "^U -1". */
	if (mflag == -1)
        {	if (n == 0) n++;
		n = -n;
        }
	execute(TRUE, n, c);
}

/* body of microEmacs: rearranged from original	*/

uebody()
{
        register int    c;

	mousecursor();
	lastflag = 0;				/* Fake last flags.     */
	while (exitue <= 0)
	{	if (nctlxe <= 0) update();	/* Fix up the screen    */
	        c = getctlkey();
        	if (mpresf != FALSE)
		{       mlerase();
                	update();
                	if (c == ' ') continue;  /* ITS EMACS does this  */
		}
		execute(FALSE, 1, c);
	}
	mouseregular();
}

	local
enter()
{	extern uchar	Verbosity[], Tempexit[];

	refresh(FALSE, 1); exitue = 0;
	setvarnum(Verbosity, varnum(Verbosity)+1);
	uebody();
	if (exitue == 4)
	{	vttidy(); mlmesg(ES); fgbp = curbp;
		mlwrite(Tempexit);
	} else 	{fgbp = NULL; ueexit();}
	exitue = 2;
	setvarnum(Verbosity, varnum(Verbosity)-1);
}

fg()
{	if (fgbp == NULL) return;
	switchwindow(wheadp); switchbuffer(fgbp);
	mlmesg(ES);
	enter();
}

ue()
{
	extern uchar *	lexgetword();

        int    		n;			/* &n is used below	*/
	register uchar	*p;

	mlmesg(msginit);
	togulambuf(1, 1);

	for (;;)
	{	p = lexgetword();  if (*p == '\000') break;
		if (*p == '-') rdonly ++;
		else
		{	n = flvisit(p);
			if (rdonly) curbp->b_flag |= BFRDO;
			if (n != TRUE) break;
	}	}
	enter();
}

moreue()
{	rdonly = 1;
	ue();
}

outofroom()
{
	gputs("gulam's ueinit() ran out of room\r\n");
	exit(-1);
}

/* This is the general command execution routine.  It handles the fake
binding of all the keys to "self-insert".  It also clears out the
"thisflag" word, and arranges to move it to the "lastflag", so that
the next command can look at it.  Return the status of command.  */

	local
execute(f, n, c)
register int	c;
int		f, n;
{
        register KB	*ktp;
        register int    status, kc;
	extern	FPFS	fpfs[];
	extern	KB	*kba[];

	for (ktp = kba[curbp->b_kbn]; (kc = ktp->k_code) != KEOTBL; ktp++)
	{	if (kc == c)
		{	thisflag = 0;
			status   = (*(fpfs[ktp->k_fx]))(f, n, c);
                        lastflag = thisflag;
			goto ret;
	}	}

        if (Selfinserting(c))
	{	if (n <= 0)			/* Fenceposts.          */
		{	lastflag = 0;
                        status = (n<0 ? FALSE : TRUE);
			goto ret;
                }
                thisflag = 0;                   /* For the future.      */
                status   = linsert(n, c);
                lastflag = thisflag;
		goto ret;
        }
        lastflag = 0;                           /* Fake last flags.     */
	status = FALSE;
	ret:
	if (status != TRUE) nctlxe = 0;
	return (status);
}

/* Initialize all of the buffers and windows.  The buffer name is
passed down as an argument, because the main routine may have been
told to read in a file by default, and we want the buffer name to be
right.  */

ueinit()
{
	vtinit();
	kbddisplayinit();
	keysetup();
	bufinit();
	wininit();
	rdonly = 0;
	exitue = 2;
}
        

ueexit()
{	update();		/* so the modeline doesn't have ** */
	kdelete(); uefreeall();	/* in display.c */
	ueinit(); tominibuf();
	vttidy(); sgarbf = FALSE;
}

/* Get a key.  Apply control modifications to the read key. */

getctl()
{	register int    c;

	c = ueinkey();
        if (c>='a' && c<='z')	c -= 0x20;		/* Force to upper   */
        if (c>=0x00 && c<=0x1F)	c = CTRL | (c+'@');	/* C0 control -> C- */
        return c;
}

getkey()
{	register int    c;

	c = ueinkey();
        if (c == METACH)	c = META | getctl(); else
        if (c == CCHR('X'))	c = CTLX | getctl(); else
        if (c>=0x00 && c<=0x1F)	c = CTRL | (c+'@');
        return c;
}

getctlkey()
{	register int    c;

	c = ueinkey();
        if (c>=0x00 && c<=0x1F)	c = CTRL | (c+'@');
        return c;
}

/* Got META/^X.  Now get next key and execute it. */

metanext(f, n, c) {execute(f, n, META | getctl());}
ctlxnext(f, n, c) {execute(f, n, CTLX | getctl());}

ueinkey()
{	register int	i;

	i = inkey();	/* see util.c */
	if (kbdmip)
	{	if (kbdmip > &kbdm[NKBDM-4])
		{	*kbdmip++ = '\030'; *kbdmip++ = ')';
			*kbdmip = '\000'; kbdmip = NULL;
			mlmesg("[kbd macro forced to end; no more room]");
		}
		else	*kbdmip++ = (uchar) i;	/* room for ^X, rt-paren,\0 */
	}
	return i;
}

/* Begin a keyboard macro.  Error if not at the top level in keyboard
processing.  Set up variables and return.  */

ctlxlp()
{
        if (kbdmip!=NULL || nctlxe > 0)
	{	mlwrite("sorry, cannot nest key board macros");
                return FALSE;
        }
        mlwrite("[Start macro]");
        kbdmip = &kbdm[0];
        return  TRUE;
}


/* End keyboard macro.  This is invoked not only at the end of
defining the kbd macro, but also at the end of each execution of the
macro.  */

ctlxrp()
{
	if (nctlxe > 1) {storekeys(kbdm); nctlxe--;}
	else nctlxe = 0;
        if (kbdmip) {mlwrite("[End macro]"); *kbdmip = '\000';}
        kbdmip = NULL;
        return TRUE;
}

showkbdmacro()
{
	outstr(sprintp("kbd macro is :%s:", kbdm));
}

/* Execute a macro.  The command argument is the number of times to
loop.  Quit as soon as a command gets an error.  Return TRUE if all
ok, else FALSE.  */


ctlxe(f, n)
register int	n;
{
        if (kbdmip!=NULL || nctlxe > 0)
	{	mlwrite("sorry, cannot do recursive kbd macro!");
                return FALSE;
        }
        if (n <= 0) return TRUE;
	if (kbdm[0]) {nctlxe = n; storekeys(kbdm);}
	return TRUE;
}


/* Abort.  Beep the beeper.  Kill off any keyboard macro, etc., that
is in progress.  Sometimes called as a routine, to do general aborting
of stuff.  */

ctrlg()
{
	mlwrite("^G...ok!");
        if (kbdmip)  {kbdm[0] = '\000';  kbdmip  = NULL;}
	nctlxe = 0;
        return (ABORT);
}

/* temporary exit from ue to gulam; usr expects to return to ue */
tempexit()
{
	exitue = 4;
}

/* Fancy quit command, as implemented by Norm.  If the current buffer
has changed do a write current buffer and exit emacs, otherwise simply
exit.  */

quickexit(f)
register int	f;
{
        if ((curbp->b_flag&BFCHG) != 0          /* Changed.             */
        && (curbp->b_flag&BFTEMP) == 0)         /* Real.                */
                filesave();
	return quit(f);				/* conditionally quit   */
}

/* Quit command.  If an argument, always quit.  Otherwise confirm if a
buffer has been changed and not written out.  Normally bound to "C-X
C-C".  Look through the list of buffers, giving the user a chance to
save them.  Return FALSE if there are any changed buffers afterwards,
or the user does not wish to quit after all.  Buffers that don't have
an associated file don't count.  Return TRUE if there are no changed
buffers, or user insists on quitting.  */

quit(f)
{
	register int	s;

        if (f != FALSE || anycb() == FALSE) goto doquit;

	s = savebuffers(FALSE);
	if (s != TRUE)
	{	s = mlyesno("Unsaved buffers exist! Quit? ");
		if (s != TRUE) return s;
	}
	doquit:
       	exitue = 2;
	return	TRUE;
}

/* -eof- */
