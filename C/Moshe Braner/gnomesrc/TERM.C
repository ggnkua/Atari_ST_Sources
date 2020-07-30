/*
 * file termio.c:
 *
 * The functions in this file
 * negotiate with the operating system
 * for characters, and write characters in
 * a barely buffered fashion on the display.
 * All operating systems.
 */
#include	"ed.h"

#if AtST
extern int vidrev;
#endif

#if	VMS
#include	<stdio.h>
#include	<stsdef.h>
#include	<ssdef.h>
#include	<descrip.h>
#include	<iodef.h>
#include	<ttdef.h>

#define	NIBUF	128			/* Input  buffer size		*/
#define	NOBUF	1024			/* MM says bug buffers win!	*/
#define	EFN	0			/* Event flag			*/

char	obuf[NOBUF];			/* Output buffer		*/
nt	nobuf;				/* # of bytes in above		*/
char	ibuf[NIBUF];			/* Input buffer			*/
nt	nibuf;				/* # of bytes in above		*/
int	ibufi;				/* Read index			*/
int	oldmode[2];			/* Old TTY mode bits		*/
int	newmode[2];			/* New TTY mode bits		*/
short	iochan;				/* TTY I/O channel		*/
#endif

#if	CPM
#include	<bdos.h>
#endif

#if	MSDOS
#include	<bios.h>
#include	<dos.h>
#include	<conio.h>
extern int origvidmode, nrmlvidattr, curvidattr, vidrev, vidmode, directvid;
ttinverse()
{
	int fore, back, attr;
	attr = nrmlvidattr;
	fore = attr & 0x07;			/* foreground	*/
	back = attr & 0x70;			/* background	*/
	attr = (fore << 4) | (back >> 4);	/* swap		*/
	textattr (attr | 0x08);			/* hi-lite fore */
	curvidattr = attr;
}
ttnormal()
{
	textattr (nrmlvidattr | 0x08);		/* hi-lite fore */
	curvidattr = nrmlvidattr;
}
ttreverse()
{
	if (curvidattr == nrmlvidattr)
		ttinverse();
	else
		ttnormal();
}
#endif

#if V7
#include	<stdio.h>
#include	<sgtty.h>		/* for stty/gtty functions */
struct  sgttyb  ostate;			/* saved tty state */
struct	sgttyb	nstate;			/* values for editor mode */
#endif

/*
 * This function is called once
 * to set up the terminal device streams.
 * On VMS, it translates SYS$INPUT until it
 * finds the terminal, then assigns a channel to it
 * and sets it raw. On CPM it is a no-op.
 */
ttopen()
{
#if	VMS
	struct	dsc$descriptor	idsc;
	struct	dsc$descriptor	odsc;
	char	oname[40];
	int	iosb[2];
	int	status;

	odsc.dsc$a_pointer = "SYS$INPUT";
	odsc.dsc$w_length  = strlen(odsc.dsc$a_pointer);
	odsc.dsc$b_dtype   = DSC$K_DTYPE_T;
	odsc.dsc$b_class   = DSC$K_CLASS_S;
	idsc.dsc$b_dtype   = DSC$K_DTYPE_T;
	idsc.dsc$b_class   = DSC$K_CLASS_S;
	do {
		idsc.dsc$a_pointer = odsc.dsc$a_pointer;
		idsc.dsc$w_length  = odsc.dsc$w_length;
		odsc.dsc$a_pointer = &oname[0];
		odsc.dsc$w_length  = sizeof(oname);
		status = LIB$SYS_TRNLOG(&idsc, &odsc.dsc$w_length, &odsc);
		if (status!=SS$_NORMAL && status!=SS$_NOTRAN)
			exit(status);
		if (oname[0] == 0x1B) {
			odsc.dsc$a_pointer += 4;
			odsc.dsc$w_length  -= 4;
		}
	} while (status == SS$_NORMAL);
	status = SYS$ASSIGN(&odsc, &iochan, 0, 0);
	if (status != SS$_NORMAL)
		exit(status);
	status = SYS$QIOW(EFN, iochan, IO$_SENSEMODE, iosb, 0, 0,
			  oldmode, sizeof(oldmode), 0, 0, 0, 0);
	if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
		exit(status);
	newmode[0] = oldmode[0];
	newmode[1] = oldmode[1] | TT$M_PASSALL | TT$M_NOECHO;
	status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
			  newmode, sizeof(newmode), 0, 0, 0, 0);
	if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
		exit(status);
#endif
#if	CPM
#endif
#if	MSDOS
	struct text_info tinfo;
	putch(' ');			/* get orig attr for normvideo() */
	gettextinfo (&tinfo);
	origvidmode = tinfo.currmode;
	if (vidmode >= 0)
		textmode (vidmode);
	gettextinfo (&tinfo);
	nrmlvidattr = curvidattr = tinfo.attribute;
	if (vidrev)
		ttinverse();
#endif
#if	AtST
	ttputs("\033e");	/* enable text cursor */
	if (vidrev) {
		ttputs("\033c1");	/* set backgnd to black */
		ttputs("\033b0");	/* set foregnd to white */
	}
	vt52nrml();
#endif
#if	V7
	ioctl(1,TIOCFLUSH,0);		/* mb: wait for chars to flush	*/
	sleep(1);			/* still seems necessary!	*/
	gtty(1, &ostate);			/* save old state */
	gtty(1, &nstate);			/* get base of new state */
	nstate.sg_flags |= RAW;
	nstate.sg_flags &= ~(ECHO|CRMOD);	/* no echo for now... */
	stty(1, &nstate);			/* set mode */
#endif
}

/*
 * This function gets called just
 * before we go back home to the command interpreter.
 * On VMS it puts the terminal back in a reasonable state.
 * Another no-operation on CPM.
 */
ttclose()
{
#if	VMS
	int	status;
	int	iosb[1];

	ttflush();
	status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
		 oldmode, sizeof(oldmode), 0, 0, 0, 0);
	if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
		exit(status);
	status = SYS$DASSGN(iochan);
	if (status != SS$_NORMAL)
		exit(status);
#endif
#if	CPM
#endif
#if	AtST
	if (vidrev) {
		ttputs("\033c0");	/* set backgnd to white */
		ttputs("\033b1");	/* set foregnd to black */
	}
	vt52nrml();
#endif
#if	MSDOS
	if (vidmode >= 0)
		textmode (origvidmode);
	normvideo();
	putch(' ');		/* put norm attr into effect */
	clreol();
#endif
#if	V7
	ttflush();
	ioctl(1,TIOCFLUSH,0);	/* mb: wait for chars to flush	*/
	sleep(1);		/* still seems necessary!	*/
	stty(1, &ostate);
#endif
}

/*
 * Write a character to the display.
 * On VMS, terminal output is buffered, and
 * we just put the characters in the big array,
 * after cheching for overflow. On CPM terminal I/O
 * unbuffered, so we just write the byte out.
 * Ditto on MS-DOS (use the very very raw console
 * output routine).
 */
ttputc(c)
{
#if	VMS
	if (nobuf >= NOBUF)
		ttflush();
	obuf[nobuf++] = c;
#endif
#if	CPM
	bios(BCONOUT, c, 0);
#endif
#if	AtST
	Bconout(2, c);
#endif
#if	MSDOS
	putch(c);		/* Turbo C library MS-DOS call	*/
#endif
#if	V7
	fputc(c, stdout);
#endif
}

ttputs(str)			/* mb: added */
	register char *str;
{
	register int c;
	while ((c=(*str++))!='\0')
		ttputc(c);
}

/*
 * Flush terminal buffer. Does real work
 * where the terminal output is buffered up. A
 * no-operation on systems where byte at a time
 * terminal I/O is done.
 */
ttflush()
{
#if	VMS
	int	status;
	int	iosb[2];

	status = SS$_NORMAL;
	if (nobuf != 0) {
		status = SYS$QIOW(EFN, iochan, IO$_WRITELBLK|IO$M_NOFORMAT,
			 iosb, 0, 0, obuf, nobuf, 0, 0, 0, 0);
		if (status == SS$_NORMAL)
			status = iosb[0] & 0xFFFF;
		nobuf = 0;
	}
	return (status);
#endif
#if	CPM
#endif
#if	MSDOS
#endif
#if	AtST
#endif
#if	V7
	fflush(stdout);
#endif
}

/*
 *  mb: find out if there is a char waiting to be read.
 */
int
ttpending()
{
#if V7
#ifdef FIONREAD
	long c;
	if (ioctl(0, FIONREAD, (struct sgttyb *) &c) == -1)
		return (FALSE);
	return (c > 0);
#else
	return (FALSE);
#endif FIONREAD
#endif V7
#if AtST
	return (Cconis());
#endif
#if MSDOS
	return (bioskey(1));		/* Turbo C specific */
#endif
#if (CPM | VMS)
	return (FALSE);
#endif
}

/*
 * Read a character from the terminal,
 * performing no editing and doing no echo at all.
 * More complex in VMS than almost anyplace else, which
 * figures. Very simple on CPM, because the system can
 * do exactly what you want.
 */
ttgetc()
{
#if	VMS
	int	status;
	int	iosb[2];
	int	term[2];

	while (ibufi >= nibuf) {
		ibufi = 0;
		term[0] = 0;
		term[1] = 0;
		status = SYS$QIOW(EFN, iochan, IO$_READLBLK|IO$M_TIMED,
			 iosb, 0, 0, ibuf, NIBUF, 0, term, 0, 0);
		if (status != SS$_NORMAL)
			exit(status);
		status = iosb[0] & 0xFFFF;
		if (status!=SS$_NORMAL && status!=SS$_TIMEOUT)
			exit(status);
		nibuf = (iosb[0]>>16) + (iosb[1]>>16);
	if (nibuf == 0) {
			status = sys$qiow(EFN, iochan, IO$_READLBLK,
				 iosb, 0, 0, ibuf, 1, 0, term, 0, 0);
			if (status != SS$_NORMAL
			|| (status = (iosb[0]&0xFFFF)) != SS$_NORMAL)
				exit(status);
			nibuf = (iosb[0]>>16) + (iosb[1]>>16);
		}
	}
	return (ibuf[ibufi++] & 0xFF);		/* Allow multinational	*/
#endif
#if	CPM
	return (biosb(BCONIN, 0, 0));
#endif
#if	AtST
	register long key;
	register int  kbs;
	register int  c;
	register int  k;

	key = Bconin(2);	/* key code in upper word */
	kbs = Kbshift(-1);	/* read shift and alt keys */
	c = (int)(key & 0xFF);
	k = (int)((key >> 16) & 0xFF);
	if ( k==0x0E || k==0x53		/* bs & del	*/
	  || k==0x4B || k==0x4D		/* arrow keys	*/
	  || k==0x48 || k==0x50
	  || k==0x52 || k==0x47		/* ins & clr	*/
	  || (c==0 && k!=0x03) ) {	/* other function keys or
					   Alt-, but leave ^@	*/
		if (k>=0x54 && k<=0x5D)	/* shifted F1..f10 ->	*/
			k -= 0x19;	/*    unshifted codes	*/
		c = FUNC | k;
		if (kbs & 0x0F)		/* Ctrl, Shift or Alt?	*/
			c |= SHFT;
	}
	return (c);
#endif
#if	MSDOS
	int k;

	k = getch();
	if (k)				/* not a function key	*/
		return (k);
	k = getch();			/* get scan code	*/
	if (k >= 0x5E && k <= 0x67)	/* CNTL-Fn		*/
		k -= 0x0A;
	if (k >= 0x68 && k <= 0x71)	/* ALT-Fn		*/
		k -= 0x14;
	return (FUNC | k);
#endif
#if	V7
	return(fgetc(stdin));
#endif
}

/*
 *  mb: output to a hardcopy device (port identified by 'hdev').
 */
int
hardputc(c)
	int c;
{
	int s;
	extern int hdev;
#if AtST
	return (Bconout (hdev, c));
#endif
#if MSDOS
	if (hdev == PARPORT) {
		s = biosprint (0,c,0);	/* Turbo C.  LPT1. */
		if (s & 0x0001)
			return (FALSE);
		return (TRUE);
	} else {
		s = bioscom (1,c,0);	/* Turbo C.  COM1. */
		if (s & 0x8000)
			return (FALSE);
		return (TRUE);
	}
#endif
#if (V7 | VMS | CPM)
	return (FALSE);
#endif
}

/*
 * file vt52.c:
 *
 * The routines in this file
 * provide support for VT52 style terminals
 * over a serial line. The serial I/O services are
 * provided by routines in "termio.c". It compiles
 * into nothing if not a VT52 style device. The
 * bell on the VT52 is terrible, so the "beep"
 * routine is conditionalized on defining BEL.
 */

#if	VT52

#define	BIAS	0x20			/* Origin 0 coordinate bias.	*/
#define	ESC	0x1B			/* ESC character.		*/
#define BEL	0x07			/* ascii bell character		*/

extern	int	vt52move();		/* Forward references.		*/
extern	int	vt52eel();
extern	int	vt52eep();
extern  int	vt52hglt();
extern  int	vt52nrml();
extern	int	vt52beep();
extern	int	vt52open();

/*
 * Dispatch table. All the
 * hard fields just point into the
 * terminal I/O code.
 */
TERM	term	= {
	NROW-1,
	NCOL,
	vt52open,
	ttclose,
	ttgetc,
	ttputc,
	ttflush,
	vt52move,
	vt52eel,
	vt52eep,
	vt52beep,
	vt52hglt,
	vt52nrml,
	ttpending
};

vt52move(row, col)
{
	ttputs("\033Y");
	ttputc(row+BIAS);
	ttputc(col+BIAS);
}

vt52eel()
{
	ttputs("\033K");
}

vt52eep()
{
	ttputs("\033J");
}

vt52beep()
{
	ttputc(BEL);
	ttflush();
}

vt52hglt()
{
	ttputs("\033p");
}

vt52nrml()
{
	ttputs("\033q");
}

vt52open()
{
#if	V7
	register char *cp;
	char *getenv();

	if ((cp = getenv("TERM")) == NULL) {
		puts("Shell variable TERM not defined!");
		exit(1);
	}
	if (strcmp(cp, "vt52") != 0 && strcmp(cp, "z19") != 0) {
		puts("Terminal type not 'vt52'or 'z19' !");
		exit(1);
	}
#endif
	ttopen();
}

#endif	VT52

/*
 * file ansi.c:
 *
 * The routines in this file
 * provide support for ANSI style terminals
 * over a serial line. The serial I/O services are
 * provided by routines in "termio.c". It compiles
 * into nothing if not an ANSI device.
 */

#if	ANSI

#define BEL	0x07			/* BEL character.		*/
#define ESC	0x1B			/* ESC character.		*/

extern  int	ttopen();		/* Forward references.		*/
extern  int	ttgetc();
extern  int	ttputc();
extern  int	ttflush();
extern  int	ttclose();
extern  int	ansimove();
extern  int	ansieeol();
extern  int	ansieeop();
extern  int	ansihglt();
extern  int	ansinrml();
extern  int	ansibeep();
extern  int	ansiopen();

/*
 * Standard terminal interface
 * dispatch table. Most of the fields
 * point into "termio" code.
 */
TERM	term	= {
	NROW-1,
	NCOL,
	ansiopen,
	ttclose,
	ttgetc,
	ttputc,
	ttflush,
	ansimove,
	ansieeol,
	ansieeop,
	ansibeep,
	ansihglt,
	ansinrml,
	ttpending
};

ansimove(row, col)
{
	ttputc(ESC);
	ttputc('[');
	ansiparm(row+1);
	ttputc(';');
	ansiparm(col+1);
	ttputc('H');
}

ansieeol()
{
	ttputs("\033[K");
}

ansieeop()
{
	ttputs("\033[J");
}

ansibeep()
{
	ttputc(BEL);
	ttflush();
}

ansihglt()
{
	ttputs("\033[7m");
}

ansinrml()
{
	ttputs("\033[m");
}

ansiparm(n)
register int	n;
{
	register int	q;

	q = n/10;
	if (q != 0)
		ansiparm(q);
	ttputc((n%10) + '0');
}

ansiopen()
{
#if	V7
	register char *cp;
	char *getenv();

	if ((cp = getenv("TERM")) == NULL) {
		puts("Shell variable TERM not defined!");
		exit(1);
	}
	if (strcmp(cp, "vt100") != 0) {
		puts("Terminal type not 'vt100'!");
		exit(1);
	}
#endif
	ttopen();
}

#endif	ANSI

/*
 * "file" tcconio.c:
 * These routines provide support for Turbo-C direct console output.
 */

#if	TCCONIO

#define BEL 0x07

extern  int	ttopen();		/* Forward references.		*/
extern  int	ttgetc();
extern  int	ttputc();
extern  int	ttflush();
extern  int	ttclose();
extern  int	coniomove();
extern  int	conioeeop();
extern  int	coniohglt();
extern  int	conionrml();
extern  int	coniobeep();
extern	void	clreol();

/*
 * Standard terminal interface
 * dispatch table. Most of the fields
 * point into "termio" code.
 */
TERM	term	= {
	NROW-1,
	NCOL,
	ttopen,
	ttclose,
	ttgetc,
	ttputc,
	ttflush,
	coniomove,
	clreol,
	conioeeop,
	coniobeep,
	ttreverse,
	ttreverse,
	ttpending
};

coniomove(row, col)
{
	gotoxy (col+1, row+1);
}
conioeeop()
{
	int i;

	clreol();
	for (i=wherey()+1; i<=term.t_nrow; i++) {
		gotoxy (1, i);
		clreol();
	}
}

coniobeep()
{
	ttputc(BEL);
}

#endif	TCCONIO

/*
 * file: tcap.c
 *
 * This file does the term stuff for systems
 * that have 'termcap' flexibility.
 */

#if TERMCAP

#define BEL	0x07
#define ESC	0x1B

extern int	ttopen();
extern int	ttgetc();
extern int	ttputc();
extern int	ttflush();
extern int 	ttclose();
extern int 	tcapmove();
extern int 	tcapeeol();
extern int	tcapeeop();
extern int	tcaphglt();
extern int	tcapnrml();
extern int	tcapbeep();
extern int	tcapopen();
extern int	tput();
extern char	*tgoto();

/* mb: following 3 entries added: */

extern int	tgetent();
extern char	*tgetstr();
extern int	tputs();

#define TCAPSLEN 315

char tcapbuf[TCAPSLEN];
char	*CM=NULL,
	*CL=NULL,
	*CE=NULL,
	*CD=NULL,
	*MR=NULL,
	*ME=NULL;

TERM term = {
	0,		/* will be set from termcap entry */
	0,
	tcapopen,
	ttclose,
	ttgetc,
	ttputc,
	ttflush,
	tcapmove,
	tcapeeol,
	tcapeeop,
	tcapbeep,
	tcaphglt,
	tcapnrml,
	ttpending
};

tcapopen()
{
	char *getenv();
	char *t, *p, *tgetstr();
	char tcbuf[1024];
	char *tv_stype;
	char err_str[72];
	int	n;

	if ((tv_stype = getenv("TERM")) == NULL)
	{
		puts("Environment variable TERM not defined!");
		exit(1);
	}

	if((tgetent(tcbuf, tv_stype)) != 1)
	{
		sprintf(err_str, "Unknown terminal type %s!", tv_stype);
		puts(err_str);
		exit(1);
	}

	/* mb: if these have not been set from the command
	 *     line, get the screen size from the termcap file.
	 */
	if (! term.t_ncol)
		term.t_ncol = ((n=tgetnum("co"))>0? n : NCOL);
	if (! term.t_nrow)
		term.t_nrow = ((n=tgetnum("li"))>0? n-1 : NROW-1);

	p = tcapbuf;

	CD = tgetstr("cd", &p);
	CE = tgetstr("ce", &p);
	CM = tgetstr("cm", &p);
	ME = tgetstr("me", &p);
	MR = tgetstr("mr", &p);
	if (ME == NULL)
		ME = tgetstr("se", &p);
	if (MR == NULL)
		MR = tgetstr("so", &p);
	if (ME == NULL)
		MR = NULL;

	if(CD==NULL || CM==NULL || CE==NULL) {
		puts("Termcap entry insufficient!\n");
		exit(1);
	}

	if (p >= &tcapbuf[TCAPSLEN])
	{
		puts("Terminal description too big!\n");
		exit(1);
	}
	ttopen();
}

tcapmove(row, col)
register int row, col;
{
	putpad(tgoto(CM, col, row));
}

tcapeeol()
{
	putpad(CE);
}

tcapeeop()
{
	putpad(CD);
}

tcapbeep()
{
	ttputc(BEL);
}

tcaphglt()
{
	if (MR != NULL)
		putpad(MR);
}

tcapnrml()
{
	if (ME != NULL)
		putpad(ME);
}

putpad(str)
char	*str;
{
	tputs(str, 1, ttputc);
}

/*
putnpad(str, n)
char	*str;
{
	tputs(str, n, ttputc);
}
 */
#endif TERMCAP

