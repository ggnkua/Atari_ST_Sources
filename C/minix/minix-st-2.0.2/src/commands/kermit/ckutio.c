char *ckxv = "Unix tty I/O, 4E(047), 27 Jan 88";

/*  C K U T I O  */

/* C-Kermit interrupt, terminal control & i/o functions for Unix systems */

/*
 Author: Frank da Cruz (SY.FDC@CU20B),
 Columbia University Center for Computing Activities, January 1985.
 Copyright (C) 1985, 1988, Trustees of Columbia University in the City of New 
 York.  Permission is granted to any individual or institution to use, copy, or
 redistribute this software so long as it is not sold for profit, provided this
 copyright notice is retained. 
*/
/* Includes for all Unixes (conditional includes come later) */

#include <sys/types.h>			/* Types */

#ifndef MINIX
#include <sys/dir.h>			/* Directory */
#endif
#include <ctype.h>			/* Character types */
#ifdef NULL
#undef NULL
#endif /* NULL */
#include <stdio.h>			/* Unix Standard i/o */
#include <signal.h>			/* Interrupts */

#ifndef ZILOG
#include <setjmp.h>			/* Longjumps */
#else
#include <setret.h>
#endif

#ifdef MINIX
#include <sys/stat.h>			/* File attributes */
#endif

#include "ckcdeb.h"			/* Typedefs, formats for debug() */

/* Maximum length for the name of a tty device */

#ifndef DEVNAMLEN
#define DEVNAMLEN 25
#endif

/* 4.1 BSD support added by Charles E. Brooks, EDN-VAX */
/* Fortune 32:16 Pro:For 1.8 support mostly like 4.1, added by J-P Dumas */

#ifdef BSD4
#define ANYBSD
#ifdef MAXNAMLEN
#define BSD42
#ifdef aegis
char *ckxsys = " Apollo DOMAIN/IX 4.2 BSD";
#else
char *ckxsys = " 4.2 BSD";
#endif /* aegis */
#else
#ifdef FT18
#define BSD41
char *ckxsys = " Fortune For:Pro 1.8";
#else
#define BSD41
#ifndef C70
char *ckxsys = " 4.1 BSD";
#endif /* not c70 */
#endif /* ft18 */
#endif /* maxnamlen */
#endif /* bsd4 */

/* 2.9bsd support contributed by Bradley Smith, UCLA */
#ifdef BSD29
#define ANYBSD
char *ckxsys = " 2.9 BSD";
#endif /* bsd29 */

/*
 Version 7 UNIX support contributed by Gregg Wonderly,
 Oklahoma State University:  gregg@okstate.csnet
*/

#ifdef	V7
#ifndef MINIX
char *ckxsys = " Version 7 UNIX (tm)";
#endif
#endif /* v7 */

/*
 Minix support added by Charles Hedrick,
 Rutgers University:  hedrick@aramis.rutgers.edu
 Minix also has V7 enabled.
*/

#ifdef MINIX
char *ckxsys = " Minix";
#define TANDEM 0
#define MYREAD
#include <limits.h>
#endif

/* BBN C70 support from Frank Wancho, WANCHO@SIMTEL20 */
#ifdef C70
char *ckxsys = " BBN C/70";
#endif /* c70 */

/* IBM 370 IX/370 support from Wayne Van Pelt, GE/CRD, Schenectedy, NY */
#ifdef IX370
char *ckxsys = " IBM IX/370";
#endif /* ix370 */

/* Amdahl UTS 2.4 (v7 derivative) for IBM 370 series compatible mainframes */
/* Contributed by Garard Gaye, Jean-Pierre Dumas, DUMAS@SUMEX-AIM. */
#ifdef UTS24
char *ckxsys = " Amdahl UTS 2.4";
#endif /* uts24 */

/* Pro/Venix Version 1.x support from Columbia U. */
#ifdef PROVX1
char *ckxsys = " Pro-3xx Venix v1";
#endif /* provx1 */

/* Tower support contributed by John Bray, Auburn, Alabama */
#ifdef TOWER1
char *ckxsys = " NCR Tower 1632, OS 1.02";
#endif /* tower1 */

/* Sys III/V, Xenix, PC/IX support by Herm Fischer, Encino, CA */
#ifdef UXIII
#ifdef XENIX
char *ckxsys = " Xenix/286";
#else
#ifdef PCIX
char *ckxsys = " PC/IX";
#else
#ifdef ISIII
char *ckxsys = " Interactive Systems Corp System III";
#else
#ifdef hpux
/* HP 9000 Series changes contributed by Bill Coalson */
char *ckxsys = " HP 9000 Series HP-UX";
#else
#ifdef aegis
/* Apollo Aegis support from SAS Institute, Cary, NC */
char *ckxsys = " Apollo DOMAIN/IX System V";
#else
#ifdef ZILOG
char *ckxsys = " Zilog S8000 Zeus 3.21+";
#else
#ifdef VXVE
/* Control Data Corp VX/VE 5.2.1 System V support by */
/* S.O. Lidie, Lehigh University, LUSOL@LEHICDC1.BITNET */
char *ckxsys = " CDC VX/VE 5.2.1 System V";
#else
char *ckxsys = " AT&T System III/System V";
#endif /* vxve  */
#endif /* zilog */
#endif /* aegis */
#endif /* hpux  */
#endif /* isiii */
#endif /* pcix  */
#endif /* xenix */
#endif /* uxiii */

/* Features... */

/* Do own buffering, using unbuffered read() calls... */
#ifdef UXIII
#define MYREAD
#endif /* uxiii */

#ifdef BSD42
#undef MYREAD
#include <errno.h>
#endif /* bsd42 */

/*
 Variables available to outside world:

   dftty  -- Pointer to default tty name string, like "/dev/tty".
   dfloc  -- 0 if dftty is console, 1 if external line.
   dfprty -- Default parity
   dfflow -- Default flow control
   ckxech -- Flag for who echoes console typein:
     1 - The program (system echo is turned off)
     0 - The system (or front end, or terminal).
   functions that want to do their own echoing should check this flag
   before doing so.

   flfnam -- Name of lock file, including its path, e.g.,
		"/usr/spool/uucp/LCK..cul0" or "/etc/locks/tty77"
   hasLock -- Flag set if this kermit established a uucp lock.
   inbufc -- number of tty line rawmode unread characters
		(system III/V unixes)
   backgrd -- Flag indicating program executing in background ( & on
		end of shell command). Used to ignore INT and QUIT signals.

 Functions for assigned communication line (either external or console tty):

   sysinit()               -- System dependent program initialization
   syscleanup()            -- System dependent program shutdown
   ttopen(ttname,local,mdmtyp) -- Open the named tty for exclusive access.
   ttclos()                -- Close & reset the tty, releasing any access lock.
   ttpkt(speed,flow)       -- Put the tty in packet mode and set the speed.
   ttvt(speed,flow)        -- Put the tty in virtual terminal mode.
				or in DIALING or CONNECTED modem control state.
   ttinl(dest,max,timo)    -- Timed read line from the tty.
   ttinc(timo)             -- Timed read character from tty.
   myread()		   -- System 3 raw mode bulk buffer read, gives
			   --   subsequent chars one at a time and simulates
			   --   FIONREAD!
   myunrd(c)		   -- Places c back in buffer to be read (one only)
   ttchk()                 -- See how many characters in tty input buffer.
   ttxin(n,buf)            -- Read n characters from tty (untimed).
   ttol(string,length)     -- Write a string to the tty.
   ttoc(c)                 -- Write a character to the tty.
   ttflui()                -- Flush tty input buffer.

   ttlock(ttname)	   -- Lock against uucp collisions (Sys III)
   ttunlck()		   -- Unlock "       "     "
   look4lk(ttname)	   -- Check if a lock file exists
*/

/*
Functions for console terminal:

   congm()   -- Get console terminal modes.
   concb(esc) -- Put the console in single-character wakeup mode with no echo.
   conbin(esc) -- Put the console in binary (raw) mode.
   conres()  -- Restore the console to mode obtained by congm().
   conoc(c)  -- Unbuffered output, one character to console.
   conol(s)  -- Unbuffered output, null-terminated string to the console.
   conola(s) -- Unbuffered output, array of strings to the console.
   conxo(n,s) -- Unbuffered output, n characters to the console.
   conchk()  -- Check if characters available at console (bsd 4.2).
		Check if escape char (^\) typed at console (System III/V).
   coninc(timo)  -- Timed get a character from the console.
   conint()  -- Enable terminal interrupts on the console if not background.
   connoi()  -- Disable terminal interrupts on the console if not background.

Time functions

   msleep(m) -- Millisecond sleep
   ztime(&s) -- Return pointer to date/time string
   rtimer() --  Reset timer
   gtimer()  -- Get elapsed time since last call to rtimer()
*/

/* Conditional Includes */

#ifdef FT18
#include <sys/file.h>	  		/* File information */
#endif /* ft18 */

/* Whether to #include <sys/file.h>... */
#ifndef PROVX1
#ifndef aegis
#ifndef MINIX
#ifndef XENIX
#include <sys/file.h>	  		/* File information */
#endif /* xenix */
#endif /* MINIX */
#endif /* aegis */
#endif /* provx1 */

#ifdef aegis
#ifdef BSD4
#include <sys/file.h>
#include <fcntl.h>
#endif /* bsd4 */
#endif /* aegis */

/* System III, System V */

#ifdef UXIII
#include <termio.h>
#include <sys/ioctl.h>
#include <fcntl.h>			/* directory reading for locking */
#include <errno.h>			/* error numbers for system returns */
#endif /* uxiii */

#ifdef HPUX
#include <sys/modem.h>
#endif

/* Not Sys III/V */

#ifndef UXIII
#include <termios.h>			/* Set/Get tty modes */
#ifndef PROVX1
#ifndef V7
#ifndef BSD41
#include <sys/time.h>			/* Clock info (for break generation) */
#endif /* not bsd41 */
#endif /* not v7 */
#endif /* not provx1 */
#endif /* not uxiii */

#ifdef BSD41
#include <sys/timeb.h>			/* BSD 4.1 ... ceb */
#endif /* bsd41 */

#ifdef BSD29
#include <sys/timeb.h>			/* BSD 2.9 (Vic Abell, Purdue) */
#endif /* bsd29 */

#ifdef TOWER1
#include <sys/timeb.h>			/* Clock info for NCR Tower */
#endif /* tower1 */

#ifdef aegis
#include "/sys/ins/base.ins.c"
#include "/sys/ins/error.ins.c"
#include "/sys/ins/ios.ins.c"
#include "/sys/ins/sio.ins.c"
#include "/sys/ins/pad.ins.c"
#include "/sys/ins/time.ins.c"
#include "/sys/ins/pfm.ins.c"
#include "/sys/ins/pgm.ins.c"
#include "/sys/ins/ec2.ins.c"
#include "/sys/ins/type_uids.ins.c"
#include <default_acl.h>
#undef TIOCEXCL
#undef FIONREAD
#endif

/* The following two conditional #defines are catch-alls for those systems */
/* that didn't have or couldn't find <file.h>... */

#ifndef FREAD
#define FREAD 0x01
#endif

#ifndef FWRITE
#define FWRITE 0x10
#endif

/* Declarations */

long time();				/* All Unixes should have this... */
extern int errno;			/* System call error code. */

/* Special stuff for V7 input buffer peeking */

#ifdef	V7
int kmem[2] = { -1, -1};
char *initrawq(), *qaddr[2]={0,0};
#define CON 0
#define TTY 1
#endif /* v7 */

/* dftty is the device name of the default device for file transfer */
/* dfloc is 0 if dftty is the user's console terminal, 1 if an external line */

#ifdef PROVX1
    char *dftty = "/dev/com1.dout"; /* Only example so far of a system */
    int dfloc = 1;		    /* that goes in local mode by default */
#else
    char *dftty = CTTNAM;		/* Remote by default, use normal */
    int dfloc = 0;			/* controlling terminal name. */
#endif /* provx1 */

    int dfprty = 0;			/* Default parity (0 = none) */
    int ttprty = 0;			/* Parity in use. */
    int ttmdm = 0;			/* Modem in use. */
    int dfflow = 1;			/* Xon/Xoff flow control */
    int backgrd = 0;			/* Assume in foreground (no '&' ) */

int ckxech = 0; /* 0 if system normally echoes console characters, else 1 */

/* Declarations of variables global within this module */

static long tcount;			/* Elapsed time counter */

static char *brnuls = "\0\0\0\0\0\0\0"; /* A string of nulls */

static jmp_buf sjbuf, jjbuf;		/* Longjump buffer */
static int lkf = 0,			/* Line lock flag */
    conif = 0,				/* Console interrupts on/off flag */
    cgmf = 0,				/* Flag that console modes saved */
    xlocal = 0,				/* Flag for tty local or remote */
    ttyfd = -1;				/* TTY file descriptor */
static char escchr;			/* Escape or attn character */

#ifdef BSD42
    static struct timeval tv;		/* For getting time, from sys/time.h */
    static struct timezone tz;
#endif /* bsd42 */

#ifdef BSD29
    static long clock;			/* For getting time from sys/time.h */
    static struct timeb ftp;		/* And from sys/timeb.h */
#endif /* bsd29 */

#ifdef BSD41
    static long clock;			/* For getting time from sys/time.h */
    static struct timeb ftp;		/* And from sys/timeb.h */
#endif /* bsd41 */

#ifdef TOWER1
static long clock;			/* For getting time from sys/time.h */
static struct timeb ftp;		/* And from sys/timeb.h */
#endif /* tower1 */

#ifdef V7
static long clock;
#endif /* v7 */

/* termio/termios information... */

#ifdef UXIII
  static struct termio ttold = {0};	/* Init'd for word alignment, */
  static struct termio ttraw = {0};	/* which is important for some */
  static struct termio tttvt = {0};	/* systems, like Zilog... */
  static struct termio ccold = {0};
  static struct termio ccraw = {0};
  static struct termio cccbrk = {0};
#else
  static struct termios 		/* termios info... */
    ttold, ttraw, tttvt, ttbuf,		/* for communication line */
    ccold, ccraw, cccbrk;		/* and for console */
#endif /* uxiii */

static char flfnam[80];			/* uucp lock file path name */
static int hasLock = 0;			/* =1 if this kermit locked uucp */
static int inbufc = 0;			/* stuff for efficient SIII raw line */
static int ungotn = -1;			/* pushback to unread character */
static int conesc = 0;			/* set to 1 if esc char (^\) typed */

static int ttlock();			/* definition of ttlock subprocedure */
static int ttunlck();			/* and unlock subprocedure */
static char ttnmsv[DEVNAMLEN];		/* copy of open path for tthang */

#ifdef aegis
static status_$t st;			/* error status return value */
static short concrp = 0; 		/* true if console is CRP pad */
#define CONBUFSIZ 10
static char conbuf[CONBUFSIZ];		/* console readahead buffer */
static int  conbufn = 0;		/* # chars in readahead buffer */
static char *conbufp;			/* next char in readahead buffer */
static uid_$t ttyuid;			/* tty type uid */
static uid_$t conuid;			/* stdout type uid */

/* APOLLO Aegis main()
 * establish acl usage and cleanup handling
 *    this makes sure that CRP pads
 *    get restored to a usable mode
 */
main(argc,argv) int argc; char **argv; {
	status_$t status;
	pfm_$cleanup_rec dirty;

	int pid = getpid();

	/* acl usage according to invoking environment */
	default_acl(USE_DEFENV);

	/* establish a cleanup continuation */
	status = pfm_$cleanup(dirty);
	if (status.all != pfm_$cleanup_set)
	{
		/* only handle faults for the original process */
		if (pid == getpid() && status.all > pgm_$max_severity)
		{	/* blew up in main process */
			status_$t quo;
			pfm_$cleanup_rec clean;

			/* restore the console in any case */
			conres();

			/* attempt a clean exit */
			debug(F101, "cleanup fault status", "", status.all);

			/* doexit(), then send status to continuation */
			quo = pfm_$cleanup(clean);
			if (quo.all == pfm_$cleanup_set)
				doexit(pgm_$program_faulted);
			else if (quo.all > pgm_$max_severity)
				pfm_$signal(quo); /* blew up in doexit() */
		}
		/* send to the original continuation */
		pfm_$signal(status);
		/*NOTREACHED*/
	}
	return(ckcmai(argc, argv));
}
#endif /* aegis */

/*  S Y S I N I T  --  System-dependent program initialization.  */

sysinit() {

/* for now, nothing... */
    return(0);
}

/*  S Y S C L E A N U P  --  System-dependent program cleanup.  */

syscleanup() {

/* for now, nothing... */
    return(0);
}

/*  T T O P E N  --  Open a tty for exclusive access.  */

/*  Returns 0 on success, -1 on failure.  */
/*
  If called with lcl < 0, sets value of lcl as follows:
  0: the terminal named by ttname is the job's controlling terminal.
  1: the terminal named by ttname is not the job's controlling terminal.
  But watch out: if a line is already open, or if requested line can't
  be opened, then lcl remains (and is returned as) -1.
*/
ttopen(ttname,lcl,modem) char *ttname; int *lcl, modem; {

#ifdef UXIII
#ifndef CIE
    char *ctermid();			/* Wish they all had this! */
#endif /* not cie */
#endif /* uxiii */

#ifdef CIE				/* CIE Regulus doesn't... */
#define ctermid(x) strcpy(x,"")
#endif

    char *x; 
#ifndef MINIX
    extern char* ttyname();
#endif
    char cname[DEVNAMLEN+4];

    if (ttyfd > -1) return(0);		/* If already open, ignore this call */
    ttmdm = modem;			/* Make this available to other fns */
    xlocal = *lcl;			/* Make this available to other fns */
#ifdef NEWUUCP
    acucntrl("disable",ttname);		/* Open getty on line (4.3BSD) */
#endif /* newuucp */
#ifdef UXIII
    /* if modem connection, don't wait for carrier */
    ttyfd = open(ttname,O_RDWR | (modem ? O_NDELAY : 0) );
#else
    ttyfd = open(ttname,2);		/* Try to open for read/write */
#endif /* uxiii */

    if (ttyfd < 0) {			/* If couldn't open, fail. */
	perror(ttname);
	return(-1);
    }
#ifdef aegis
    /* Apollo C runtime claims that console pads are tty devices, which
     * is reasonable, but they aren't any good for packet transfer. */
    ios_$inq_type_uid((short)ttyfd, ttyuid, st);
    if (st.all != status_$ok) {
	fprintf(stderr, "problem getting tty object type: ");
	error_$print(st);
    } else if (ttyuid != sio_$uid) { /* reject non-SIO lines */
	close(ttyfd); ttyfd = -1;
	errno = ENOTTY; perror(ttname);
	return(-1);
    }
#endif /* aegis */
    strncpy(ttnmsv,ttname,DEVNAMLEN);	/* Open, keep copy of name locally. */

/* Caller wants us to figure out if line is controlling tty */

    debug(F111,"ttopen ok",ttname,*lcl);
    if (*lcl == -1) {
	if (strcmp(ttname,CTTNAM) == 0) {   /* "/dev/tty" always remote */
	    debug(F110," Same as CTTNAM",ttname,0);
	    xlocal = 0;
	} else if (isatty(0)) {		/* Else, if stdin not redirected */
#ifndef MINIX
	    x = ttyname(0);		/* then compare its device name */
	    strncpy(cname,x,DEVNAMLEN);	/* (copy from internal static buf) */
	    debug(F110," ttyname(0)",x,0);
	    x = ttyname(ttyfd); 	/* ...with real name of ttname. */
	    xlocal = (strncmp(x,cname,DEVNAMLEN) == 0) ? 0 : 1;
	    debug(F111," ttyname",x,xlocal);
#else
	    xlocal = 1;   /* can't do this test in minix */
#endif /* MINIX */
	} else {			/* Else, if stdin redirected... */
#ifdef UXIII
/* Sys III/V provides nice ctermid() function to get name of controlling tty */
    	    ctermid(cname);		/* Get name of controlling terminal */
	    debug(F110," ctermid",cname,0);
	    x = ttyname(ttyfd); 	/* Compare with name of comm line. */
	    xlocal = (strncmp(x,cname,DEVNAMLEN) == 0) ? 0 : 1;
	    debug(F111," ttyname",x,xlocal);
#else
/* Just assume local, so "set speed" and similar commands will work */
/* If not really local, how could it work anyway?... */
	    xlocal = 1;
	    debug(F101," redirected stdin","",xlocal);
#endif /* uxiii */
        }
    }    

/* Now check if line is locked -- if so fail, else lock for ourselves */

    lkf = 0;				/* Check lock */
    if (xlocal > 0) {
	if (ttlock(ttname) < 0) {
	    fprintf(stderr,"Exclusive access to %s denied\n",ttname);
	    close(ttyfd); ttyfd = -1;
	    debug(F110," Access denied by lock",ttname,0);
	    return(-1);			/* Not if already locked */
    	} else lkf = 1;
    }

/* Got the line, now set the desired value for local. */

    if (*lcl < 0) *lcl = xlocal;

/* Some special stuff for v7... */

#ifdef	V7
#ifndef MINIX
	if (kmem[TTY] < 0) {	/*  If open, then skip this.  */
		qaddr[TTY] = initrawq(ttyfd);	/* Init the queue. */
		if ((kmem[TTY] = open("/dev/kmem", 0)) < 0) {
			fprintf(stderr, "Can't read /dev/kmem in ttopen.\n");
			perror("/dev/kmem");
			exit(1);
		}
	}
#endif /* not MINIX */
#endif /* v7 */

/* Request exclusive access on systems that allow it. */

#ifndef XENIX
/* Xenix exclusive access prevents open(close(...)) from working... */
#ifdef TIOCEXCL
    	if (ioctl(ttyfd,TIOCEXCL, (char *) NULL) < 0)
	    fprintf(stderr,"Warning, problem getting exclusive access\n");
#endif /* tiocexcl */
#endif /* xenix */

/* Get tty device settings */

#ifndef UXIII
    tcgetattr(ttyfd,&ttold);		/* Get termios info */
#ifdef aegis
    sio_$control((short)ttyfd, sio_$raw_nl, false, st);
    if (xlocal) {	/* ignore breaks from local line */
	sio_$control((short)ttyfd, sio_$int_enable, false, st);
	sio_$control((short)ttyfd, sio_$quit_enable, false, st);
    }
#endif /* aegis */
    tcgetattr(ttyfd,&ttraw);		/* And a copy of it for packets*/
    tcgetattr(ttyfd,&tttvt);		/* And one for virtual tty service */
#else
    ioctl(ttyfd,TCGETA,&ttold);		/* Same deal for Sys III, Sys V */
#ifdef aegis
    sio_$control((short)ttyfd, sio_$raw_nl, false, st);
    if (xlocal) {	/* ignore breaks from local line */
	sio_$control((short)ttyfd, sio_$int_enable, false, st);
	sio_$control((short)ttyfd, sio_$quit_enable, false, st);
    }
#endif /* aegis */
    ioctl(ttyfd,TCGETA,&ttraw);
    ioctl(ttyfd,TCGETA,&tttvt);
#endif /* not uxiii */

#ifdef VXVE
    ttraw.c_line = 0;			/* STTY line 0 for VX/VE */
    ioctl(ttyfd,TCSETA,&ttraw);
    tttvt.c_line = 0;			/* STTY line 0 for VX/VE */
    ioctl(ttyfd,TCSETA,&tttvt);
#endif /* vxve */

    debug(F101,"ttopen, ttyfd","",ttyfd);
    debug(F101," lcl","",*lcl);
    debug(F111," lock file",flfnam,lkf);
    return(0);
}

/*  T T C L O S  --  Close the TTY, releasing any lock.  */

ttclos() {
    if (ttyfd < 0) return(0);		/* Wasn't open. */
    if (xlocal) {
#ifdef notdef
	if (tthang())			/* Hang up phone line */
	    fprintf(stderr,"Warning, problem hanging up the phone\n");
#endif
    	if (ttunlck())			/* Release uucp-style lock */
	    fprintf(stderr,"Warning, problem releasing lock\n");
    }
    ttold.c_cflag &= ~HUPCL;
    ttres();				/* Reset modes. */
/* Relinquish exclusive access if we might have had it... */
#ifndef XENIX
#ifdef TIOCEXCL
#ifdef TIOCNXCL
    if (ioctl(ttyfd, TIOCNXCL, (char *) NULL) < 0)
    	fprintf(stderr,"Warning, problem relinquishing exclusive access\n");
#endif /* tiocnxcl */
#endif /* tiocexcl */
#endif /* not xenix */
    close(ttyfd);			/* Close it. */
#ifdef NEWUUCP
    acucntrl("enable",flfnam);		/* Close getty on line. */
#endif /* newuucp */
    ttyfd = -1;				/* Mark it as closed. */
    return(0);
}

/*  T T H A N G -- Hangup phone line */

tthang() {
#ifdef UXIII
#ifdef HPUX
    unsigned long dtr_down = 00000000000,
                  modem_rtn;
#else
    unsigned short ttc_save;
#endif /* hpux */
#endif /* uxiii */

    if (ttyfd < 0) return(0);		/* Not open. */
#ifdef aegis
    sio_$control((short)ttyfd, sio_$dtr, false, st);	/* DTR down */
    msleep(500);					/* pause */
    sio_$control((short)ttyfd, sio_$dtr, true,  st);	/* DTR up */
#else
#ifdef ANYBSD
    ioctl(ttyfd,TIOCCDTR,0);		/* Clear DTR */
    msleep(500);			/* Let things settle */
    ioctl(ttyfd,TIOCSDTR,0);		/* Restore DTR */
#endif /* anybsd */
#ifdef UXIII
#ifdef HPUX   /* Hewlett Packard way of modem control  */
    if (ioctl(ttyfd,MCSETAF,&dtr_down) < 0) return(-1); /* lower DTR */
    msleep(500);
    if (ioctl(ttyfd,MCGETA,&modem_rtn) < 0) return(-1); /* get line status */
    if ((modem_rtn & MDCD) != 0) return(-1);        /* check if DCD is low */
    modem_rtn = MRTS | MDTR;                        /* bits for RTS & DTR  */
    if (ioctl(ttyfd,MCSETAF,&modem_rtn) < 0) return(-1);    /*  set lines  */
#else
    ttc_save = ttraw.c_cflag;
    ttraw.c_cflag &= ~CBAUD;		/* swa: set baud rate to 0 to hangup */
    if (ioctl(ttyfd,TCSETAF,&ttraw) < 0) return(-1); /* do it */
    msleep(100);			/* let things settle */
    ttraw.c_cflag = ttc_save;

/* NOTE - The following #ifndef...#endif can be removed for SCO Xenix 2.1.3 */
/* or later, but must keep for earlier versions, which can't do close/open. */

#ifndef XENIX		/* xenix cannot do close/open when carrier drops */
				/* following corrects a PC/IX defficiency */
    ttc_save = fcntl(ttyfd,F_GETFL,0);
    close(ttyfd);		/* close/reopen file descriptor */
    if ((ttyfd = open(ttnmsv, ttc_save)) < 0) return(-1);
#endif /* not xenix */
    if (ioctl(ttyfd,TCSETAF,&ttraw) < 0) return(-1); /* un-do it */
#endif /* uxiii */
#endif /* hpux  */
#endif /* aegis */
    return (0);
}


/*  T T R E S  --  Restore terminal to "normal" mode.  */

ttres() {				/* Restore the tty to normal. */
    int x;

    if (ttyfd < 0) return(-1);		/* Not open. */
#ifndef UXIII				/* except for sIII, */
    sleep(1);				/* Wait for pending i/o to finish. */
#endif	/* uxiii */			/*   (sIII does wait in ioctls) */

#ifdef UXIII
    if (ioctl(ttyfd,TCSETAW,&ttold) < 0) return(-1); /* restore termio stuff */
    if (fcntl(ttyfd,F_SETFL, fcntl(ttyfd, F_GETFL, 0) & ~O_NDELAY) < 0 )
      return(-1);
#else /* not uxiii */
#ifdef FIONBIO
    x = 0;
    x = ioctl(ttyfd,FIONBIO,&x);
    if (x < 0) {
	perror("ttres ioctl");
	debug(F101,"ttres ioctl","",x);
    }
#else /* not fionbio */
#ifdef FNDELAY
    x = (fcntl(ttyfd,F_SETFL,fcntl(ttyfd,F_GETFL,0) & ~FNDELAY) == -1);
    debug(F101,"ttres fcntl","",x);
    if (x < 0) perror("fcntl");
#endif /* fndelay */
#endif /* fionbio */
    x = tcsetattr(ttyfd,TCSANOW,&ttold);	/* Restore termios stuff */
    debug(F101,"ttres tcsetattr","",x);
    if (x < 0) perror("tcsetattr");
#endif /* uxiii */
    return(x);
}

/* Exclusive uucp file locking control */
/*
 by H. Fischer, creative non-Bell coding !
 copyright rights for lock modules assigned to Columbia University
*/
static char *
xxlast(s,c) char *s; char c; {		/* Equivalent to strrchr() */
    int i;
    for (i = strlen(s); i > 0; i--)
    	if ( s[i-1] == c ) return( s + (i - 1) );
    return(NULL);    
}
static
look4lk(ttname) char *ttname; {
    extern char *strcat(), *strcpy();
    char *device, *devname;
    char lockfil[50];			/* Max length for lock file name */

#ifdef MINIX
    char *lockdir = "/usr/spool/locks";
    struct stat stbuf;
#else
#ifdef ISIII
    char *lockdir = "/etc/locks";
#else
#if ATT3BX
    char *lockdir = "/usr/spool/locks";
#else
#ifdef NEWUUCP
    char *lockdir = "/usr/spool/uucp/LCK";
#else
    char *lockdir = "/usr/spool/uucp";
#endif /* newuucp */
#endif /* att3bx | minix */
#endif /* isiii */
#endif /* minix */

    device = ( (devname=xxlast(ttname,'/')) != NULL ? devname+1 : ttname);

#ifdef MINIX
    if (stat(ttname, &stbuf) == -1) {
	fprintf(stderr,"Warning, can't access %s\n", ttname);
	return( 1 );			/* cannot check or set lock file */
    }
    sprintf(lockfil, "LK.%03d.%03d.%03d",
	(int) ((stbuf.st_dev >> 8) & 0xFF),
	(int) ((stbuf.st_rdev >> 8) & 0xFF),
	(int) ((stbuf.st_rdev >> 0) & 0xFF));
#else
#ifdef ISIII
    (void) strcpy( lockfil, device );
#else
    strcat( strcpy( lockfil, "LCK.." ), device );
#endif /* isiii */
#endif /* minix */

#ifndef MINIX
    if (access( lockdir, 04 ) < 0) {	/* read access denied on lock dir */
	fprintf(stderr,"Warning, read access to lock directory denied\n");
	return( 1 );			/* cannot check or set lock file */
    }
#endif
	
    strcat(strcat(strcpy(flfnam,lockdir),"/"), lockfil);
    debug(F110,"look4lk",flfnam,0);

    if ( ! stat( flfnam, &stbuf ) ) {	/* print out lock file entry */
	char lckcmd[40] ;
	strcat( strcpy(lckcmd, "ls -l ") , flfnam);
	system(lckcmd);
#ifndef MINIX
	if (access(flfnam,02) == 0)
	    printf("(You may type \"! rm %s\" to remove this file)\n",flfnam);
#endif
	return( -1 );
    }
#ifndef MINIX
    if ( access( lockdir, 02 ) < 0 ) {	/* lock file cannot be written */
	fprintf(stderr,"Warning, write access to lock directory denied\n");
	return( 1 );
    }
#endif
    return( 0 );			/* okay to go ahead and lock */
}

/*  T T L O C K  */

static
ttlock(ttfd) char *ttfd; {		/* lock uucp if possible */
#ifndef aegis
#ifdef ATT3BX
    FILE *lck_fild;
#endif /* att3bx */
    int lck_fil, l4l;
    int pid_buf = getpid();		/* pid to save in lock file */
	
    hasLock = 0;			/* not locked yet */
    l4l = look4lk(ttfd);
    if (l4l < 0) return (-1);		/* already locked */
    if (l4l == 1) return (0);		/* can't read/write lock directory */
    lck_fil = creat(flfnam, 0444);	/* create lock file ... */
    if (lck_fil < 0) return (-1);	/* create of lockfile failed */
		/* creat leaves file handle open for writing -- hf */
#ifdef ATT3BX
    fprintf((lck_fild = fdopen(lck_fil, "w")), "%10d\n", pid_buf);
    fflush(lck_fild);
#else
    write (lck_fil, &pid_buf, sizeof(pid_buf) ); /* uucp expects int in file */
#endif /* att3bx */
    close (lck_fil);
    hasLock = 1;			/* now is locked */
#endif /* not aegis */
    return(0);
}

/*  T T U N L O C K  */

static
ttunlck() {				/* kill uucp lock if possible */
    if (hasLock) return( unlink( flfnam ) );
    return(0);
}

/* New-style (4.3BSD) UUCP line direction control (Stan Barber, Rice U) */

#ifdef NEWUUCP
acucntrl(flag,ttname) char *flag, *ttname; {
    char x[DEVNAMLEN+32], *device, *devname;

    if (strcmp(ttname,CTTNAM) == 0 || xlocal == 0) /* If not local, */
        return;				/* just return. */
    device = ((devname = xxlast(ttname,'/')) != NULL ? devname+1 : ttname);
    if (strncmp(device,"LCK..",4) == 0) device += 5;
    sprintf(x,"/usr/lib/uucp/acucntrl %s %s",flag,device);
    debug(F000,"called ",x,0);
    system(x);
}
#endif /* newuucp */

/*  T T P K T  --  Condition the communication line for packets. */
/*		or for modem dialing */

#define DIALING	4		/* flags (via flow) for modem handling */
#define CONNECT 5

/*  If called with speed > -1, also set the speed.  */

/*  Returns 0 on success, -1 on failure.  */

ttpkt(speed,flow,parity) int speed, flow, parity; {
    int s, x;

    if (ttyfd < 0) return(-1);		/* Not open. */
    ttprty = parity;			/* Let other tt functions see this. */
    debug(F101,"ttpkt setting ttprty","",ttprty);
    s = ttsspd(speed);			/* Check the speed */

#ifndef UXIII
    if (flow == 1) ttraw.c_iflag |= (IXON|IXOFF);
    if (flow == 0) ttraw.c_iflag &= ~(IXON|IXOFF);

    if (flow == DIALING)  ttraw.c_cflag |= CLOCAL|HUPCL;
    if (flow == CONNECT)  ttraw.c_cflag &= ~CLOCAL;

    ttraw.c_lflag &= ~(ICANON|ECHO);
    ttraw.c_lflag |= ISIG;		/* do check for interrupt */
    ttraw.c_iflag |= (BRKINT|IGNPAR);
    ttraw.c_iflag &= ~(IGNBRK|INLCR|IGNCR|ICRNL|INPCK|ISTRIP);
    ttraw.c_oflag &= ~OPOST;
    ttraw.c_cflag &= ~(CSIZE|PARENB);
    ttraw.c_cflag |= (CS8|CREAD);
    ttraw.c_cc[VMIN] = 1;
    ttraw.c_cc[VTIME] = 0;
    if (s > -1) {				/* Do the speed */
	cfsetispeed(&ttraw, s);
	cfsetospeed(&ttraw, s);
    }
    if (tcsetattr(ttyfd,TCSANOW,&ttraw) < 0) return(-1);/* Set the new modes. */

#ifdef MYREAD
#ifdef BSD4
/* Try to make reads nonblocking */
#ifdef aegis
    return(0);
#endif /* aegis */
#ifdef FIONBIO
    x = 1;
    if (ioctl(ttyfd,FIONBIO,&x) < 0) {
	perror("ttpkt ioctl");
	return(-1);
    }
#else /* fionbio */
#ifdef FNDELAY
    if (fcntl(ttyfd,F_SETFL,fcntl(ttyfd,F_GETFL,0) | FNDELAY) == -1) {
	return(-1);
    }
#endif /* fndelay */
#endif /* fionbio */
    ttflui();				/* Flush any pending input */
    return(0);
#endif /* bsd4 */
#ifdef MINIX
    ttflui();				/* Flush any pending input */
    return(0);
#endif
#else  /* myread */
    ttflui();				/* Flush any pending input */
    return(0);
#endif /* myread */
#endif /* not uxiii */

#ifdef UXIII
    if (flow == 1) ttraw.c_iflag |= (IXON|IXOFF);
    if (flow == 0) ttraw.c_iflag &= ~(IXON|IXOFF);

    if (flow == DIALING)  ttraw.c_cflag |= CLOCAL|HUPCL;
    if (flow == CONNECT)  ttraw.c_cflag &= ~CLOCAL;

    ttraw.c_lflag &= ~(ICANON|ECHO);
    ttraw.c_lflag |= ISIG;		/* do check for interrupt */
    ttraw.c_iflag |= (BRKINT|IGNPAR);
    ttraw.c_iflag &= ~(IGNBRK|INLCR|IGNCR|ICRNL|IUCLC|INPCK|ISTRIP|IXANY);
    ttraw.c_oflag &= ~OPOST;
    ttraw.c_cflag &= ~(CSIZE|PARENB);
    ttraw.c_cflag |= (CS8|CREAD);
#ifdef IX370
    ttraw.c_cc[4] = 48;	 /* So Series/1 doesn't interrupt on every char */
    ttraw.c_cc[5] = 1;
#else
#ifdef VXVE
    ttraw.c_cc[4] = 1;   /* [VMIN]  for CDC VX/VE */
    ttraw.c_cc[5] = 0;   /* [VTIME] for CDC VX/VE */
#else
#ifdef MYREAD
    ttraw.c_cc[4] = 200; /* return max of this many characters */
    ttraw.c_cc[5] = 1;   /* or when this many secs/10 expire w/no input */
#else
    ttraw.c_cc[4] = 1;   /* [VMIN]  Maybe should be bigger for all Sys V? */
    ttraw.c_cc[5] = 0;   /* [VTIME] Should be set high enough to ignore */
					/* intercharacter spacing? */
    /* But then we have to distinguish between Sys III and Sys V.. */
#endif
#endif
#endif
    if (s > -1) {			/* set speed */
        ttraw.c_cflag &= ~CBAUD;
	ttraw.c_cflag |= s;
    }
    if (ioctl(ttyfd,TCSETAW,&ttraw) < 0) return(-1);  /* set new modes . */
    if (flow == DIALING) {
#ifndef aegis
	if (fcntl(ttyfd,F_SETFL, fcntl(ttyfd, F_GETFL, 0) & ~O_NDELAY) < 0 )
		return(-1);
#endif /* not aegis */
	close( open(ttnmsv,2) );	/* magic to force mode change!!! */
    }
    ttflui();
    return(0);
#endif /* uxiii */
}

/*  T T V T -- Condition communication line for use as virtual terminal  */

ttvt(speed,flow) int speed, flow; {
    int s;
    if (ttyfd < 0) return(-1);		/* Not open. */

    s = ttsspd(speed);			/* Check the speed */

#ifndef UXIII
    if (flow == 1) tttvt.c_iflag |= (IXON|IXOFF);
    if (flow == 0) tttvt.c_iflag &= ~(IXON|IXOFF);

    if (flow == DIALING)  tttvt.c_cflag |= CLOCAL|HUPCL;
    if (flow == CONNECT)  tttvt.c_cflag &= ~CLOCAL;

    tttvt.c_lflag &= ~(ISIG|ICANON|ECHO);
    tttvt.c_iflag |= (IGNBRK|IGNPAR);
    tttvt.c_iflag &= ~(INLCR|IGNCR|ICRNL|BRKINT|INPCK|ISTRIP);
    tttvt.c_oflag &= ~OPOST;
    tttvt.c_cflag &= ~(CSIZE|PARENB);
    tttvt.c_cflag |= (CS8|CREAD);
    tttvt.c_cc[VMIN] = 1;
    tttvt.c_cc[VTIME] = 0;

    if (s > -1) {			/* set speed */
	cfsetispeed(&tttvt, s);
	cfsetospeed(&tttvt, s);
    }
    if (tcsetattr(ttyfd,TCSANOW,&tttvt) < 0) return(-1);

#ifdef MYREAD
#ifdef BSD4
/* Make reads nonblocking */
#ifdef aegis
	return(0);
#endif
	if (fcntl(ttyfd,F_SETFL,fcntl(ttyfd,F_GETFL,0) | FNDELAY) == -1)
	    return(-1);
	else return(0);
#endif /* bsd4 */
#endif /* myread */

#else /* uxiii */
    if (flow == 1) tttvt.c_iflag |= (IXON|IXOFF);
    if (flow == 0) tttvt.c_iflag &= ~(IXON|IXOFF);

    if (flow == DIALING)  tttvt.c_cflag |= CLOCAL|HUPCL;
    if (flow == CONNECT)  tttvt.c_cflag &= ~CLOCAL;

    tttvt.c_lflag &= ~(ISIG|ICANON|ECHO);
    tttvt.c_iflag |= (IGNBRK|IGNPAR);
    tttvt.c_iflag &= ~(INLCR|IGNCR|ICRNL|IUCLC|BRKINT|INPCK|ISTRIP|IXANY);
    tttvt.c_oflag &= ~OPOST;
    tttvt.c_cflag &= ~(CSIZE|PARENB);
    tttvt.c_cflag |= (CS8|CREAD);
    tttvt.c_cc[4] = 1;
    tttvt.c_cc[5] = 0;

    if (s > -1) {			/* set speed */
	tttvt.c_cflag &= ~CBAUD;
	tttvt.c_cflag |= s;
    }
    if (ioctl(ttyfd,TCSETAW,&tttvt) < 0) return(-1);  /* set new modes . */

    if (flow == DIALING) {
#ifndef aegis
	if (fcntl(ttyfd,F_SETFL, fcntl(ttyfd, F_GETFL, 0) & ~O_NDELAY) < 0 )
		return(-1);
#endif
	close( open(ttnmsv,2) );	/* magic to force mode change!!! */
	}
#endif
    return(0);
}

/*  T T S S P D  --  Return the internal baud rate code for 'speed'.  */

ttsspd(speed) {
    int s, spdok;

    if (speed < 0) return(-1);
	spdok = 1;			/* Assume arg ok */
	switch (speed) {
#ifndef MINIX
	    case 0:    s = B0;    break;	/* Just the common ones. */
#endif
	    case 110:  s = B110;  break;	/* The others from ttydev.h */
#ifndef MINIX
	    case 150:  s = B150;  break;	/* could also be included if */
#endif
	    case 300:  s = B300;  break;	/* necessary... */
#ifndef MINIX
	    case 600:  s = B600;  break;
#endif
	    case 1200: s = B1200; break;
#ifndef MINIX
	    case 1800: s = B1800; break;
#endif
	    case 2400: s = B2400; break;
	    case 4800: s = B4800; break;
	    case 9600: s = B9600; break;
#ifdef MINIX
	    case 19200: s = B19200; break;
	    case 38400: s = B38400; break;
	    case 57600: s = B57600; break;
	    case 115200: s = B115200; break;
#endif
#ifdef PLEXUS
	    case 19200: s = EXTA; break;
#endif
#ifdef aegis
	    case 19200: s = EXTA; break;
#endif
	    default:
	    	spdok = 0;
		fprintf(stderr,"Unsupported line speed - %d\n",speed);
		fprintf(stderr,"Current speed not changed\n");
		break;
	}    
	if (spdok) return(s); else return(-1);
 }

/*  T T F L U I  --  Flush tty input buffer */

ttflui() {

#ifndef UXIII
    long n;
#endif
    if (ttyfd < 0) return(-1);		/* Not open. */

    ungotn = -1;			/* Initialize myread() stuff */
    inbufc = 0;

#ifdef aegis
    sio_$control((short)ttyfd, sio_$flush_in, true, st);
    if (st.all != status_$ok)
    {  fprintf(stderr, "flush failed: "); error_$print(st); }
    else {	/* sometimes the flush doesn't work */
	for (;;)
	{   char buf[256];
	    /* eat all the characters that shouldn't be available */
	    (void)ios_$get((short)ttyfd, ios_$cond_opt, buf, 256L, st);
	    if (st.all == ios_$get_conditional_failed) break;
	    fprintf(stderr, "flush failed(2): "); error_$print(st);
	}
    }
#else
#ifdef UXIII
#ifndef VXVE
    if (ioctl(ttyfd,TCFLSH,0) < 0) perror("flush failed");
#endif /* vxve */
#else
#ifdef TIOCFLUSH
#ifdef ANYBSD
    n = FREAD;				/* Specify read queue */
    if (ioctl(ttyfd,TIOCFLUSH,&n) < 0) perror("flush failed");
#else
    if (ioctl(ttyfd,TIOCFLUSH, (char *)NULL) < 0) perror("flush failed");
#endif
#endif
#endif
#endif
    return(0);
}

/* Interrupt Functions */


/* Timeout handler for communication line input functions */

timerh() {
    longjmp(sjbuf,1);
}

 
/* Set up terminal interrupts on console terminal */

#ifdef UXIII
esctrp() {				/* trap console escapes (^\) */
    conesc = 1;
    signal(SIGQUIT,SIG_IGN);		/* ignore until trapped */
}
#endif

#ifdef V7
esctrp() {				/* trap console escapes (^\) */
    conesc = 1;
    signal(SIGQUIT,SIG_IGN);		/* ignore until trapped */
}
#endif

#ifdef C70
esctrp() {				/* trap console escapes (^\) */
    conesc = 1;
    signal(SIGQUIT,SIG_IGN);		/* ignore until trapped */
}
#endif

/*  C O N I N T  --  Console Interrupt setter  */

conint(f) int (*f)(); {			/* Set an interrupt trap. */
    int x, y;
#ifdef SIGTSTP
    int stptrap();			/* Suspend trap */
#endif

/* Check for background operation, even if not running on real tty, so that */
/* background flag can be set correctly. */

#ifdef BSD4
    int mypgrp;				/* In BSD, we can check whether */
    int ctpgrp;				/* this process's group is the */
					/* same as the controlling */
    mypgrp = getpgrp(0);		/* terminal's process group. */
    ioctl (1, TIOCGPGRP, &ctpgrp);
    x = (mypgrp != ctpgrp);		/* If they differ, then background. */
    debug(F101,"conint process group test","",x);
#else
    x = (signal(SIGINT,SIG_IGN) == SIG_IGN);
    debug(F101,"conint signal test","",x);
#endif
    y = isatty(0);
    debug(F101,"conint isatty test","",y);
#ifdef BSD29
/* For some reason the signal() test doesn't work under 2.9 BSD... */
    backgrd = !y;
#else
#ifdef MINIX
/* Signal test definitely doesn't work on Minix */
    backgrd = !y;
#else
    backgrd = (x || !y);
#endif
#endif
    debug(F101,"conint backgrd","",backgrd);

    signal(SIGHUP,f);			/* Ensure lockfile cleared on hangup */
    signal(SIGTERM,f);			/* or soft kill. */

/* check if invoked in background -- if so signals set to be ignored */

    if (backgrd) {			/* In background, ignore signals */
#ifdef SIGTSTP
	signal(SIGTSTP,SIG_IGN);	/* Keyboard stop */
#endif
	signal(SIGQUIT,SIG_IGN);	/* Keyboard quit */
	signal(SIGINT,SIG_IGN);		/* Keyboard interrupt */
    } else {
	signal(SIGINT,f);		/* Catch terminal interrupt */
#ifdef SIGTSTP
	signal(SIGTSTP,stptrap);	/* Keyboard stop */
#endif
#ifdef UXIII
        signal(SIGQUIT,esctrp);		/* Quit signal, Sys III/V. */
	if (conesc) conesc = 0;		/* Clear out pending escapes */
#else
#ifdef V7
        signal(SIGQUIT,esctrp);		/* V7 like Sys III/V */
	if (conesc) conesc = 0;
#else
#ifdef aegis
        signal(SIGQUIT,f);		/* Apollo, catch it like others. */
#else
        signal(SIGQUIT,SIG_IGN);	/* Others, ignore like 4D & earlier. */
#endif
#endif
#endif
	conif = 1;			/* Flag console interrupts on. */
    }
    return;
}


/*  C O N N O I  --  Reset console terminal interrupts */

connoi() {				/* Console-no-interrupts */

#ifdef SIGTSTP
    signal(SIGTSTP,SIG_DFL);
#endif
    signal(SIGINT,SIG_DFL);
    signal(SIGHUP,SIG_DFL);
    signal(SIGQUIT,SIG_DFL);
    signal(SIGTERM,SIG_DFL);
    conif = 0;				/* Flag interrupt trapping off */
}

/*  myread() -- For use by systems that can do nonblocking read() calls  */
/*
 Returns:
  -1  if no characters available, timer expired
  -2  upon error (such as disconnect),
  otherwise value of character (0 or greater)
*/
myread() {
    static int inbuf_item;
    static CHAR inbuf[257];
    CHAR readit;

    if (ungotn >= 0) {
	readit = ungotn;
	ungotn = -1;
    } else {
        if (inbufc > 0) {
	    readit = inbuf[++inbuf_item];
        } else {
#ifdef aegis
    /* myread() returns -1 when no input is available.  All the users of */
    /* myread() explicitly loop until it returns a character or error. */
    /* The Apollo code waits for input to be available. */

    /* read in characters */
	    inbufc = ios_$get((short)ttyfd, ios_$cond_opt, inbuf, 256L, st);
	    errno = EIO;
	    if (st.all == ios_$get_conditional_failed) /* get at least one */
		inbufc = ios_$get((short)ttyfd, 0, inbuf, 1L, st);
	    if (st.all == ios_$end_of_file) inbufc = 0;
	    else if (st.all != status_$ok)
	    {   inbufc = -1; errno = EIO; }
#else
            inbufc = read(ttyfd,inbuf,256);
	    if (inbufc > 0) {
		inbuf[inbufc] = '\0';
		debug(F101,"myread read","",inbufc);
	    }
#endif /* aegis */
	    if (inbufc == 0) {
		if (ttmdm) {
		    debug(F101,"myread read=0, ttmdm","",ttmdm);
		    errno = 9999;	/* magic number for no carrier */
		    return(-2);		/* end of file has no errno */
		} else return(-1);	/* in sys 5 means no data available */
	    }
	    if (inbufc < 0) {		/* Real error */
#ifdef EWOULDBLOCK
		if (errno == EWOULDBLOCK) return(-1); else return(-2);
#else
		return(-2);
#endif /* ewouldblock */
    	    }
	    readit = inbuf[inbuf_item = 0];
	}
        inbufc--;	
    }
    return(((int) readit) & 255);
}

myunrd(ch) CHAR ch; {			/* push back up to one character */
    ungotn = ch;
}

/*  I N I T R A W Q  --  Set up to read /DEV/KMEM for character count.  */

#ifdef	V7
/*
 Used in Version 7 to simulate Berkeley's FIONREAD ioctl call.  This
 eliminates blocking on a read, because we can read /dev/kmem to get the
 number of characters available for raw input.  If your system can't
 or you won't let it read /dev/kmem (the world that is) then you must
 figure out a different way to do the counting of characters available,
 or else replace this by a dummy function that always returns 0.
*/
/*
 * Call this routine as: initrawq(tty)
 * where tty is the file descriptor of a terminal.  It will return
 * (as a char *) the kernel-mode memory address of the rawq character
 * count, which may then be read.  It has the side-effect of flushing
 * input on the terminal.
 */
/*
 * John Mackin, Physiology Dept., University of Sydney (Australia)
 * ...!decvax!mulga!physiol.su.oz!john
 *
 * Permission is hereby granted to do anything with this code, as
 * long as this comment is retained unmodified and no commercial
 * advantage is gained.
 */
#ifndef MINIX
#include <a.out.h>
#include <sys/proc.h>
#endif

char *initrawq(tty) int tty; {
#ifdef MINIX
    return(0);
#else
#ifdef UTS24
    return(0);
#else
#ifdef BSD29
    return(0);
#else
    long lseek();
    static struct nlist nl[] = {
	{PROCNAME},
	{NPROCNAME},
	{""}
    };
    static struct proc *pp;
    char *malloc(), *qaddr, *p, c;
    int m, pid, me;
    NPTYPE xproc;			/* Its type is defined in makefile. */
    int catch();

    me = getpid();
    if ((m = open("/dev/kmem", 0)) < 0) err("kmem");
    nlist(BOOTNAME, nl);
    if (nl[0].n_type == 0) err("proc array");
 
    if (nl[1].n_type == 0) err("nproc");

    lseek(m, (long)(nl[1].n_value), 0);
    read (m, &xproc, sizeof(xproc));
    signal(SIGALRM, catch);
    if ((pid = fork()) == 0) {
	while(1)
	    read(tty, &c, 1);
    }
    alarm(2);
 
    if(setjmp(jjbuf) == 0) {
	while(1)
	    read(tty, &c, 1);
    }
    signal(SIGALRM, SIG_DFL);

#ifdef DIRECT
    pp = (struct proc *) nl[0].n_value;
#else
    if (lseek(m, (long)(nl[0].n_value), 0) < 0L) err("seek");
    if (read(m, &pp, sizeof(pp)) != sizeof(pp))  err("no read of proc ptr");
#endif
    lseek(m, (long)(nl[1].n_value), 0);
    read(m, &xproc, sizeof(xproc));

    if (lseek(m, (long)pp, 0) < 0L) err("Can't seek to proc");
    if ((p = malloc(xproc * sizeof(struct proc))) == NULL) err("malloc");
    if (read(m,p,xproc * sizeof(struct proc)) != xproc*sizeof(struct proc))
    	err("read proc table");
    for (pp = (struct proc *)p; xproc > 0; --xproc, ++pp) {
	if (pp -> p_pid == (short) pid) goto iout;
    }
    err("no such proc");
 
iout:
    close(m);
    qaddr = (char *)(pp -> p_wchan);
    free (p);
    kill(pid, SIGKILL);
    wait((int *)0);		/* Destroy the ZOMBIEs! */
    return (qaddr);
#endif
#endif
#endif
}

/*  More V7-support functions...  */

static
err(s) char *s; {
    char buf[200];

    sprintf(buf, "fatal error in initrawq: %s", s);
    perror(buf);
    doexit(1);
}

static
catch() {
    longjmp(jjbuf, -1);
}


/*  G E N B R K  --  Simulate a modem break.  */

#ifndef MINIX

#define	BSPEED	B150

genbrk(fn) int fn; {
    struct sgttyb ttbuf;
    int ret, sospeed;

    ret = ioctl(fn, TIOCGETP, &ttbuf);
    sospeed = ttbuf.sg_ospeed;
    ttbuf.sg_ospeed = BSPEED;
    ret = ioctl(fn, TIOCSETP, &ttbuf);
    ret = write(fn, "\0\0\0\0\0\0\0\0\0\0\0\0", 8);
    ttbuf.sg_ospeed = sospeed;
    ret = ioctl(fn, TIOCSETP, &ttbuf);
    ret = write(fn, "@", 1);
    return;
}
#endif
#endif

/*  T T C H K  --  Tell how many characters are waiting in tty input buffer  */

ttchk() {
    int x; long n;
#ifdef FIONREAD
    x = ioctl(ttyfd, FIONREAD, &n);	/* Berkeley and maybe some others */
    debug(F101,"ttchk","",n);
    return((x < 0) ? 0 : n);
#else
#ifdef	V7
#ifdef MINIX
    return(0);
#else
    lseek(kmem[TTY], (long) qaddr[TTY], 0); /* 7th Edition Unix */
    x = read(kmem[TTY], &n, sizeof(int));
    return((x == sizeof(int))? n: 0);
#endif
#else
#ifdef UXIII
    return(inbufc + (ungotn >= 0) );	/* Sys III, Sys V */
#else
#ifdef PROVX1
    x = ioctl(ttyfd, TIOCQCNT, &ttbuf);	/* Pro/3xx Venix V.1 */
    n = ttbuf.sg_ispeed & 0377;
    return((x < 0) ? 0 : n);
#else
#ifdef aegis
    return(inbufc + (ungotn >= 0) );	/* Apollo Aegis */
#else
#ifdef C70
    return(inbufc + (ungotn >= 0) );	/* etc... */
#else
    return(0);
#endif
#endif
#endif
#endif
#endif
#endif
}


/*  T T X I N  --  Get n characters from tty input buffer  */

/*  Returns number of characters actually gotten, or -1 on failure  */

/*  Intended for use only when it is known that n characters are actually */
/*  Available in the input buffer.  */

ttxin(n,buf) int n; char *buf; {
    int x;

#ifdef MYREAD
    for( x = 0; (x > -1) && (x < n); buf[x++] = myread() );
#else
    debug(F101,"ttxin: n","",n);
    x = read(ttyfd,buf,n);
    debug(F101," x","",x);
#endif
    if (x > 0) buf[x] = '\0';
    if (x < 0) x = -1;
    return(x);
}

/*  T T O L  --  Similar to "ttinl", but for writing.  */

ttol(s,n) int n; char *s; {
    int x;
    if (ttyfd < 0) return(-1);		/* Not open. */
    x = write(ttyfd,s,n);
    debug(F111,"ttol",s,n);
    if (x < 0) debug(F101,"ttol failed","",x);
    return(x);
}


/*  T T O C  --  Output a character to the communication line  */

ttoc(c) char c; {
    if (ttyfd < 0) return(-1);		/* Not open. */
    return(write(ttyfd,&c,1));
}

/*  T T I N L  --  Read a record (up to break character) from comm line.  */
/*
  If no break character encountered within "max", return "max" characters,
  with disposition of any remaining characters undefined.  Otherwise, return
  the characters that were read, including the break character, in "dest" and
  the number of characters read as the value of the function, or 0 upon end of
  file, or -1 if an error occurred.  Times out & returns error if not completed
  within "timo" seconds.
*/
#define CTRLC '\03'
ttinl(dest,max,timo,eol) int max,timo; CHAR *dest, eol; {
    int x = 0, ccn = 0, c, i, j, m, n;	/* local variables */

    if (ttyfd < 0) return(-1);		/* Not open. */

    m = (ttprty) ? 0177 : 0377;		/* Parity stripping mask. */
    *dest = '\0';			/* Clear destination buffer */
    if (timo) signal(SIGALRM,timerh);	/* Enable timer interrupt */
    alarm(timo);			/* Set it. */
    if (setjmp(sjbuf)) {		/* Timer went off? */
        x = -1;
    } else {
	i = 0;				/* Next char to process */
	j = 0;				/* Buffer position */
        while (1) {
            if ((n = ttchk()) > 0) {	/* See how many chars have arrived */
                if (n > (max - j)) n = max - j;
                if ((n = ttxin(n,dest+i)) < 0) { /* Get them all at once */
		    x = -1;
		    break;
		}
	    } else {			/* Or else... */
		n = 1;			/* just wait for a char */
		if ((c = ttinc(0)) == -1) {
		    x = -1;
		    break;
		}
                dest[i] = c;		/* Got one. */
	    }
	    j = i + n;			/* Remember next buffer position. */
	    if (j >= max) {
		debug(F101,"ttinl buffer overflow","",j);
		x = -1;
		break;
	    }
	    for (i; i < j; i++) {	/* Go thru all chars we just got */
		dest[i] &= m;		/* Strip any parity */
	        if (dest[i] == eol) {	/* Got eol? */
		  dest[++i] = '\0';	/* Yes, tie off string, */
		  alarm(0);		/* turn off timers, etc, */
		  if (timo) signal(SIGALRM,SIG_DFL); /* and return length. */
		  return(i);
	      } else if ((dest[i] & 0177) == CTRLC) { /* Check for ^C^C */
		  if (++ccn > 1) {	/* If we got 2 in a row, clean up */
		     alarm(0);		/* and exit. */
		     signal(SIGALRM,SIG_DFL);
		     fprintf(stderr,"^C...");
		     ttres();
		     fprintf(stderr,"\n");
		     return(-2);
		  }
	      } else ccn = 0;	/* Not ^C, so reset ^C counter, */
	  }
	}
    }
    debug(F100,"ttinl timout","",0);	/* Get here on timeout. */
    debug(F111," with",dest,i);
    alarm(0);				/* Turn off timer */
    signal(SIGALRM,SIG_DFL);		/* and interrupt, */
    return(x);				/* and return error code. */
}

/*  T T I N C --  Read a character from the communication line  */

ttinc(timo) int timo; {
    int m, n = 0;
    CHAR ch = 0;

    m = (ttprty) ? 0177 : 0377;		/* Parity stripping mask. */
    if (ttyfd < 0) return(-1);		/* Not open. */
    if (timo <= 0) {			/* Untimed. */
#ifdef MYREAD
    	/* comm line failure returns -1 thru myread, so no &= 0377 */
    	while ((n = myread()) == -1) ;	/* Wait for a character... */
	if (n == -2) n++;
	return( (n < 0) ? -1 : n & m );
#else
	while ((n = read(ttyfd,&ch,1)) == 0) ; /* Wait for a character. */
	return( (n < 0) ? -1 : (ch & 0377) );
#endif
    }
    signal(SIGALRM,timerh);		/* Timed, set up timer. */
    alarm(timo);
    if (setjmp(sjbuf)) {
	n = -1;
    } else {
#ifdef MYREAD
    	while ((n = myread()) == -1) ;	/* If managing own buffer... */
	if (n == -2) {
	    n++;
	} else {
	    ch = n;
	    n = 1;	
	}
#else
    	n = read(ttyfd,&ch,1);		/* Otherwise call the system. */
#endif
    }
    alarm(0);				/* Turn off timer, */
    signal(SIGALRM,SIG_DFL);		/* and interrupt. */
    return( (n < 0) ? -1 : (ch & m) );  /* Return char or -1. */
}

/*  T T S N D B  --  Send a BREAK signal  */

ttsndb() {
    int x; long n; char spd;

    if (ttyfd < 0) return(-1);		/* Not open. */

#ifdef PROVX1
    gtty(ttyfd,&ttbuf);			/* Get current tty flags */
    spd = ttbuf.sg_ospeed;		/* Save speed */
    ttbuf.sg_ospeed = B50;		/* Change to 50 baud */
    stty(ttyfd,&ttbuf);			/*  ... */
    write(ttyfd,brnuls,3);		/* Send 3 nulls */
    ttbuf.sg_ospeed = spd;		/* Restore speed */
    stty(ttyfd,&ttbuf);			/*  ... */
    return(0);
#else
#ifdef aegis
    sio_$control((short)ttyfd, sio_$send_break, 250, st);
    return(0);
#else
#ifdef UXIII
    if (ioctl(ttyfd,TCSBRK,(char *)0) < 0) {	/* Send a BREAK */
    	perror("Can't send BREAK");
	return(-1);
    }
    return(0);
#else
#ifdef ANYBSD
    n = FWRITE;				/* Flush output queue. */
    ioctl(ttyfd,TIOCFLUSH,&n); 		/* Ignore any errors.. */
    if (ioctl(ttyfd,TIOCSBRK,(char *)0) < 0) {	/* Turn on BREAK */
    	perror("Can't send BREAK");
	return(-1);
    }
    x = msleep(275);			/* Sleep for so many milliseconds */
    if (ioctl(ttyfd,TIOCCBRK,(char *)0) < 0) {	/* Turn off BREAK */
	perror("BREAK stuck!!!");
	doexit(1);			/* Get out, closing the line. */
					/*   with exit status = 1 */
    }
    return(x);
#else
#ifdef MINIX
    tcsendbreak(ttyfd, 0);
#else
#ifdef	V7
    genbrk(ttyfd);			/* Simulate a BREAK */
    return(x);
#endif
#endif
#endif
#endif
#endif
#endif
}

/*  M S L E E P  --  Millisecond version of sleep().  */

/*
 Intended only for small intervals.  For big ones, just use sleep().
*/

msleep(m) int m; {

#ifdef aegis
    time_$clock_t dur;

    dur.c2.high16 = 0;
    dur.c2.low32  = 250 * m; /* one millisecond = 250 four microsecond ticks */
    time_$wait(time_$relative, dur, st);
    return(0);
#else 
#ifdef PROVX1
    if (m <= 0) return(0);
    sleep(-((m * 60 + 500) / 1000));
    return(0);
#endif

#ifdef ANYBSD
    int t1, t3, t4;
    if (m <= 0) return(0);
#ifndef BSD42
/* 2.9 and 4.1 BSD do it this way */
    if (ftime(&ftp) < 0) return(-1);	/* Get current time. */
    t1 = ((ftp.time & 0xff) * 1000) + ftp.millitm;
    while (1) {
	ftime(&ftp);			/* new time */
	t3 = (((ftp.time & 0xff) * 1000) + ftp.millitm) - t1;
	if (t3 > m) return(t3);
    }
#else
/* 4.2 & above can do it with select()... */
    if (gettimeofday(&tv, &tz) < 0) return(-1); /* Get current time. */
    t1 = tv.tv_sec;			/* Seconds */

    tv.tv_sec = 0;			/* Use select() */
    tv.tv_usec = m * 1000;
    return(select( 0, (int *)0, (int *)0, (int *)0, &tv) );
#endif
#endif

/* The clock-tick business is a pain.  Wm. E. Davidsen suggested: */
/*   #include <sys/param.h>      */
/*   #define CLOCK_TICK 1000/HZ  */
/* But I don't see the symbol HZ in this file on my VAX. */
/* Maybe just for XENIX. */

#ifdef UXIII
#ifdef XENIX
/* Actually, watch out.  It's 50 on the AT, 20 on older PCs... */
#define CLOCK_TICK 50			/* millisecs per clock tick */
#else
#ifndef XENIX
#define CLOCK_TICK 17			/* 1/60 sec */
#endif
#endif

    extern long times();
    long t1, t2, tarray[4];
    int t3;

/* In SCO Xenix 2.1.3 or later, you can use nap((long)m) to do this. */

    if (m <= 0) return(0);
    if ((t1 = times(tarray)) < 0) return(-1);
    while (1) {
	if ((t2 = times(tarray)) < 0) return(-1);
	t3 = ((int)(t2 - t1)) * CLOCK_TICK;
	if (t3 > m) return(t3);
    }
#endif

#ifdef TOWER1
    int t1, t3;
    if (m <= 0) return(0);
    if (ftime(&ftp) < 0) return(-1);		/* Get current time. */
    t1 = ((ftp.time & 0xff) * 1000) + ftp.millitm;
    while (1) {
	ftime(&ftp);				/* new time */
	t3 = (((ftp.time & 0xff) * 1000) + ftp.millitm) - t1;
	if (t3 > m) return (t3);
    }
#endif
#endif
}

/*  R T I M E R --  Reset elapsed time counter  */

rtimer() {
    tcount = time( (long *) 0 );
}


/*  G T I M E R --  Get current value of elapsed time counter in seconds  */

gtimer() {
    int x;
    x = (int) (time( (long *) 0 ) - tcount);
    rtimer();
    return( (x < 0) ? 0 : x );
}


/*  Z T I M E  --  Return date/time string  */

ztime(s) char **s; {

#ifdef UXIII
    extern long time();			/* Sys III/V way to do it */
    char *ctime();
    long clock_storage;

    clock_storage = time( (long *) 0 );
    *s = ctime( &clock_storage );
#endif

#ifdef PROVX1
    int utime[2];			/* Venix way */
    time(utime);
    *s = ctime(utime);
#endif

#ifdef ANYBSD
    char *asctime();			/* Berkeley way */
    struct tm *localtime();
    struct tm *tp;
#ifdef BSD42
    gettimeofday(&tv, &tz);		/* BSD 4.2 */
    time(&tv.tv_sec);
    tp = localtime(&tv.tv_sec);
#else
    time(&clock);			/* BSD 4.1, 2.9 ... ceb */
    tp = localtime(&clock);
#endif
    *s = asctime(tp);
#endif

#ifdef TOWER1
    char *asctime();			/* Tower way */
    struct tm *localtime();
    struct tm *tp;

    time(&clock);
    tp = localtime(&clock);
    *s = asctime(tp);
#endif

#ifdef V7
#ifdef MINIX
    int utime[2];			/* Venix way */
    time(utime);
    *s = ctime(utime);
#else
    char *asctime();			/* V7 way */
    struct tm *localtime();
    struct tm *tp;

    time(&clock);
    tp = localtime(&clock);
    *s = asctime(tp);
#endif
#endif
}

/*  C O N G M  --  Get console terminal modes.  */

/*
 Saves current console mode, and establishes variables for switching between 
 current (presumably normal) mode and other modes.
*/

congm() {
    if (!isatty(0)) return(0);		/* only for real ttys */
#ifdef aegis
    ios_$inq_type_uid(ios_$stdin, conuid, st);
    if (st.all != status_$ok)
    {  fprintf(stderr, "problem getting stdin objtype: "); error_$print(st); }
    concrp = (conuid == mbx_$uid);
    conbufn = 0;
#endif
#ifndef UXIII
     tcgetattr(0,&ccold);		/* Structure for restoring */
     tcgetattr(0,&cccbrk);		/* For setting CBREAK mode */
     tcgetattr(0,&ccraw);		/* For setting RAW mode */
#else
     ioctl(0,TCGETA,&ccold);
     ioctl(0,TCGETA,&cccbrk);
     ioctl(0,TCGETA,&ccraw);
#endif
#ifdef VXVE
     cccbrk.c_line = 0;			/* STTY line 0 for CDC VX/VE */
     ioctl(0,TCSETA,&cccbrk);
     ccraw.c_line = 0;			/* STTY line 0 for CDC VX/VE */
     ioctl(0,TCSETA,&ccraw);
#endif /* vxve */
     cgmf = 1;				/* Flag that we got them. */
     return(0);
}


/*  C O N C B --  Put console in cbreak mode.  */

/*  Returns 0 if ok, -1 if not  */

concb(esc) char esc; {
    int x;
    if (!isatty(0)) return(0);		/* only for real ttys */
    if (cgmf == 0) congm();		/* Get modes if necessary. */
    escchr = esc;			/* Make this available to other fns */
    ckxech = 1;				/* Program can echo characters */
#ifdef aegis
    conbufn = 0;
    if (concrp) return(write(1, "\035\002", 2));
    if (conuid == input_pad_$uid) {pad_$raw(ios_$stdin, st); return(0);}
#endif
#ifndef UXIII
    cccbrk.c_lflag &= ~(ICANON|ECHO);
    cccbrk.c_cc[VINTR] = 003;		/* interrupt char is control-c */
    cccbrk.c_cc[VQUIT] = escchr;	/* escape during packet modes */
    cccbrk.c_cc[VMIN] = 1;
    cccbrk.c_cc[VTIME] = 1;
    x = tcsetattr(0,TCSANOW,&cccbrk);
#else
    cccbrk.c_lflag &= ~(ICANON|ECHO);
    cccbrk.c_cc[0] = 003;		/* interrupt char is control-c */
    cccbrk.c_cc[1] = escchr;		/* escape during packet modes */
    cccbrk.c_cc[4] = 1;
#ifdef ZILOG
    cccbrk.c_cc[5] = 0;
#else
    cccbrk.c_cc[5] = 1;
#endif /* zilog */
    x = ioctl(0,TCSETAW,&cccbrk);  	/* set new modes . */
#endif

#ifndef aegis
    if (x > -1) setbuf(stdout,(char *) NULL);	/* Make console unbuffered. */
#endif
#ifdef	V7
#ifndef MINIX
    if (kmem[CON] < 0) {
	qaddr[CON] = initrawq(0);
	if((kmem[CON] = open("/dev/kmem", 0)) < 0) {
	    fprintf(stderr, "Can't read /dev/kmem in concb.\n");
	    perror("/dev/kmem");
	    exit(1);
	}
    }
#endif
#endif
    return(x);
}

/*  C O N B I N  --  Put console in binary mode  */

/*  Returns 0 if ok, -1 if not  */

conbin(esc) char esc; {
    if (!isatty(0)) return(0);		/* only for real ttys */
    if (cgmf == 0) congm();		/* Get modes if necessary. */
    escchr = esc;			/* Make this available to other fns */
    ckxech = 1;				/* Program can echo characters */
#ifdef aegis
    conbufn = 0; if (concrp) return(write(1, "\035\002", 2));
    if (conuid == input_pad_$uid) {pad_$raw(ios_$stdin, st); return(0);}
#endif
#ifndef UXIII
    ccraw.c_lflag &= ~(ISIG|ICANON|ECHO);
    ccraw.c_iflag |= (BRKINT|IGNPAR);
    ccraw.c_iflag &= ~(IGNBRK|INLCR|IGNCR|ICRNL|IXON|IXOFF|INPCK|ISTRIP);
    ccraw.c_oflag &= ~OPOST;
    ccraw.c_cc[VMIN] = 1;
    ccraw.c_cc[VTIME] = 1;
    return(tcsetattr(0,TCSANOW,&ccraw));
#else
    ccraw.c_lflag &= ~(ISIG|ICANON|ECHO);
    ccraw.c_iflag |= (BRKINT|IGNPAR);
    ccraw.c_iflag &= ~(IGNBRK|INLCR|IGNCR|ICRNL|IUCLC|IXON|IXANY|IXOFF
			|INPCK|ISTRIP);
    ccraw.c_oflag &= ~OPOST;

/*** Kermit used to put the console in 8-bit raw mode, but some users have
 *** pointed out that this should not be done, since some sites actually
 *** use terminals with parity settings on their Unix systems, and if we
 *** override the current settings and stop doing parity, then their terminals
 *** will display blotches for characters whose parity is wrong.  Therefore,
 *** the following two lines are commented out (Larry Afrin, Clemson U):
 ***
 ***   ccraw.c_cflag &= ~(PARENB|CSIZE);
 ***   ccraw.c_cflag |= (CS8|CREAD);
 ***
 *** Sys III/V sites that have trouble with this can restore these lines.
 ***/
    ccraw.c_cc[4] = 1;
    ccraw.c_cc[5] = 1;
    return(ioctl(0,TCSETAW,&ccraw) );  	/* set new modes . */
#endif
}


/*  C O N R E S  --  Restore the console terminal  */

conres() {
    if (cgmf == 0) return(0);		/* Don't do anything if modes */
    if (!isatty(0)) return(0);		/* only for real ttys */
#ifndef UXIII				/* except for sIII, */
    sleep(1);				/*  not known! */
#endif					/*   (sIII does wait in ioctls) */
    ckxech = 0;				/* System should echo chars */
#ifdef aegis
    conbufn = 0; if (concrp) return(write(1, "\035\001", 2));
    if (conuid == input_pad_$uid) {pad_$cooked(ios_$stdin, st); return(0);}
#endif
#ifndef UXIII
    return(tcsetattr(0,TCSANOW,&ccold));	/* Restore controlling tty */
#else
    return(ioctl(0,TCSETAW,&ccold));
#endif
}

/*  C O N O C  --  Output a character to the console terminal  */

conoc(c) char c; {
    write(1,&c,1);
}

/*  C O N X O  --  Write x characters to the console terminal  */

conxo(x,s) char *s; int x; {
    write(1,s,x);
}

/*  C O N O L  --  Write a line to the console terminal  */

conol(s) char *s; {
    int len;
    len = strlen(s);
    write(1,s,len);
}

/*  C O N O L A  --  Write an array of lines to the console terminal */

conola(s) char *s[]; {
    int i;
    for (i=0 ; *s[i] ; i++) conol(s[i]);
}

/*  C O N O L L  --  Output a string followed by CRLF  */

conoll(s) char *s; {
    conol(s);
    write(1,"\r\n",2);
}

/*  C O N C H K  --  Return how many characters available at console  */

conchk() {
    int x; long n;

#ifdef PROVX1
    x = ioctl(0, TIOCQCNT, &ttbuf);
    n = ttbuf.sg_ispeed & 0377;
    return((x < 0) ? 0 : n);
#else
#ifdef aegis
    if (conbufn > 0) return(conbufn);	/* use old count if nonzero */

    /* read in more characters */
    conbufn = ios_$get(ios_$stdin,
	      ios_$cond_opt, conbuf, (long)sizeof(conbuf), st);
    if (st.all != status_$ok) conbufn = 0;
    conbufp = conbuf;
    return(conbufn);
#else
#ifdef V7
#ifdef MINIX
    if (conesc) {			/* Escape typed */
	conesc = 0;
	signal(SIGQUIT,esctrp);		/* Restore escape */
	return(1);
    }
    return(0);
#else
    lseek(kmem[CON], (long) qaddr[CON], 0);
    x = read(kmem[CON], &n, sizeof(int));
    return((x == sizeof(int))? n: 0);
#endif
#else
#ifdef UXIII
    if (conesc) {			/* Escape typed */
	conesc = 0;
	signal(SIGQUIT,esctrp);		/* Restore escape */
	return(1);
    }
    return(0);
#else
#ifdef C70
    if (conesc) {			/* Escape typed */
	conesc = 0;
	signal(SIGQUIT,esctrp);		/* Restore escape */
	return(1);
    }
    return(0);
#else
#ifdef FIONREAD
    x = ioctl(0, FIONREAD, &n);		/* BSD and maybe some others */
    return((x < 0) ? 0 : n);
#else
    return(0);				/* Others can't do. */
#endif
#endif
#endif
#endif
#endif
#endif
}

/*  C O N I N C  --  Get a character from the console  */

coninc(timo) int timo; {
    int n = 0; char ch;
#ifdef aegis
    fflush(stdout);
    if (conchk() > 0)
    {  --conbufn; return(*conbufp++ & 0377); }
#endif
    if (timo <= 0 ) {			/* untimed */
	n = read(0, &ch, 1);		/* Read a character. */
	ch &= 0377;
	if (n > 0) return(ch); 		/* Return the char if read */
	else 
#ifdef UXIII
#ifndef CIE				/* CIE Regulus has no such symbol */
	    if (n < 0 && errno == EINTR) /* if read was interrupted by QUIT */
		return(escchr);		 /* user entered escape character */
	    else		    /* couldnt be ^c, sigint never returns */
#endif
#endif
		return(-1);  		/* Return the char, or -1. */
	}
    signal(SIGALRM,timerh);		/* Timed read, so set up timer */
    alarm(timo);
    if (setjmp(sjbuf)) n = -2;
    else {
	n = read(0, &ch, 1);
	ch &= 0377;
    }
    alarm(0);				/* Stop timing, we got our character */
    signal(SIGALRM,SIG_DFL);
    if (n > 0) return(ch);
    else
#ifdef UXIII
#ifndef CIE				/* CIE Regulus has no such symbol */
        if (n == -1 && errno == EINTR)  /* If read interrupted by QUIT, */
	    return(escchr);		/* user entered escape character, */
        else		    		/* can't be ^c, sigint never returns */
#endif
#endif
	return(-1);
}

#ifdef ATT7300
#include <sys/phone.h>
#include <dial.h>
#define ATT7300 4			/* REH */
CALL tcfig;
struct termio ctermio = {0};
struct updata ph;
static int att7300 = 0;			/* REH */

/*  A T T D I A L  --  Dial up the remote system */

/* Purpose: to open and dial a number on the internal modem available on the 
 * ATT7300 UNIX PC.  Richard E. Hill, Dickinson, TX.
 */

attdial(ttname,speed,telnbr) char *ttname,*telnbr; int speed; {
    int err;

    if (ttyfd > 0) {
	ioctl(ttyfd,TCGETA,&ctermio);	/* save current settings */
	err=ttclos();			/* close port */
    } else ioctl(0,TCGETA,&ctermio);	/* get standard settings */

/* Open line, check availability & data mode, turn on speaker, close port. */

    ttyfd = open (ttname,O_RDWR | O_NDELAY);
    if (err=ioctl(ttyfd,PIOCOFFHOOK,&ph)) {
	printf("Phone line for %s not available:%d %d %d\n",
	       ttname,ttyfd,err,errno);
	close(ttyfd);
	ttyfd = -1;
	return(-1);
    }
    ioctl(ttyfd,PIOCGETP,&ph);     /* set phone parameters   */
    if (ph.c_lineparam & VOICE) {
	printf("Phone line %s not in data mode. Switch to data & redial\n",
	       ttname);
	ioctl(ttyfd,PIOCDISC,&ph);
	close(ttyfd);
	ttyfd = -1;
	  return(-1);
    }
    ph.c_feedback |= (SPEAKERON | RINGON | NORMSPK);
    ioctl(ttyfd,PIOCSETP,&ph);		/* set phone parameters   */
    ioctl(ttyfd,PIOCDISC,&ph);		/* release phone resources for dial */
    close(ttyfd);
/*
	fprintf(stderr,"Phone line status. line_par:%o dialtone_wait:%o \
line_status:%o feedback:%o\n",
        ph.c_lineparam, ph.c_waitdialtone, ph.c_linestatus,ph.c_feedback);
*/

/*  Close line so that it can be reopened using system routine "dial". */
/*  Set terminal configuration parameters. */

    ctermio.c_iflag |= (BRKINT|IGNPAR|IXON|IXOFF);
    ctermio.c_iflag &= ~(IGNBRK|INLCR|IGNCR|ICRNL|IUCLC|INPCK|ISTRIP| IXANY);
    ctermio.c_oflag &= ~OPOST;
    ctermio.c_cflag = (B1200 | CS8 | CREAD | CLOCAL | HUPCL);
    ctermio.c_lflag &= ~(ICANON|ECHO);
    ctermio.c_cc[4] = 1;
    ctermio.c_cc[5] = 0;
    tcfig.attr = &ctermio;
    tcfig.baud = speed <= 1200 ? speed : 1200;
    tcfig.speed = speed <= 300 ? 300 : 1200;
    tcfig.line = ttname;
    tcfig.telno = telnbr;
    tcfig.modem = 0;
    fprintf (stderr,"dialing:%s on line:%s at %d baud, speed:%d\n",
	     tcfig.telno,tcfig.line,tcfig.baud,tcfig.speed);
    if ((ttyfd = dial(tcfig)) > 0) {
	att7300 = 1;
/*
	ioctl(ttyfd,TCGETA,&ctermio);
	fprintf(stderr,"after dial:iflag:%o, oflag:%o, cflag:%o, lflag:%o,\
	line:%o\n", ctermio.c_iflag,ctermio.c_oflag,ctermio.c_cflag,
	ctermio.c_lflag, ctermio.c_line);
*/
	return(0);
    }
    printf("Sorry, connection not made. Error status: %d\n",ttyfd);
    return(-2);
}
#endif /* ATT7300 */

