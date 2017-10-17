/******************************************************************************
 *	TTY.h	Tty handler definitions
 ******************************************************************************
 */
/* Miscellaneus */
# define	EOF		-1

/* define TTY struct */
# define	NDEVS		2	/* Total number of devs driven */
# define	CONSOLE		0	/* Console device number */
# define	TTYBUFSIZE	256	/* Input and output buffer sizes */
# define	MAXEXPAND	16	/* Output expansion buffer size */

# define	LOWMARK		100	/* Low and high water marks */
# define	HIGHMARK	200
# define	XONSTATE	0	/* Xon state flag */
# define	XOFFSTATE	1	/* Xoff state flag no output */

# define	RDY		1	/* Buffer ready for i/o */
# define	NOTRDY		0	/* Buffer not ready for i/o */
# define	TOPB		0x80	/* Top bit of character */

# define	TABSIZE		8	/* Size of tab */
# define	TABMASK		0xFFFFFFF8	/* Mask for tab */

#ifdef	VIWINDOWS
# define	TFLGNONE	0	/* No touch command */
# define	TFLGCMD		1	/* Is touch command */
# define	TFLGHASX	2	/* Has X co-ord */
# define	TFLGHASY	3	/* Has Y co-ord */
# define	TFLGTERM	4	/* Completed touch command */

# define	IFLGNONE	0	/* No inc command */
# define	IFLGCMD		1	/* Is inc command */
# define	IFLGNULL	2	/* Null byte recieved */
# define	IFLGHIGH	3	/* Has High byte of increment */
# define	IFLGTERM	4	/* Has Low byte of increment */

/* Windows special info for process switching and touch control */
struct Wintty {
	short	wmode;			/* Window mode on/off */
	short	cpid;			/* Current process ID */
	short	tflag;			/* Touch flag */
	struct	Ipoint	ipoint;		/* Cursor position tempary */
	short	iflag;			/* Increment flag */
	struct	Iinc	iinc;		/* Increment info tempary */
};
#endif

/* TTY buffer information */
struct ttybuf {

	char	buf[TTYBUFSIZE];	/* Input buffer (from acia) */
	short	count;			/* Number of chars in buffer */
	char	*inptr;			/* Pointer to input to buffer */
	char	*outptr;		/* Pointer to output from  buffer */
	char	outrdy;			/* Buffer available for output */
	char	inrdy;			/* Buffer available for input */
};

/* TTY structure per i/o device */
struct ttystruct {

	short	dev;			/* Minor device number */
	short	nopens;			/* Number of opens */
	short	col;			/* Current column on screen, 1-80 ish */
	short	line;			/* Current line number output */
	struct	sgttyb sgtty;		/* TTY settings */
	struct	tchars tchars;		/* Special characters */
	struct	ltchars ltchars;	/* Local special characters */
#ifdef	VIWINDOWS
	struct	Wintty wintty;		/* Special info for window mode */
#endif

	struct	ttybuf inbuf;		/* Input buffer */
	struct	ttybuf outbuf;		/* Output buffer */

	char	expand[MAXEXPAND];	/* Expanded characters buffer */
	char	*exp;			/* Curent character in expand list */
	short	nexpand;		/* Number of characters in expand list*/

	char	inxoff;			/* Xoff flag input */
	char	outxoff;		/* Xoff flag output */
	char	tx_rdy;			/* Set if acia waiting for tx */
	char	tx_ewait;		/* Waiting for tx of curent character */
};

/* TTY device driver structure */

/* Entries are :-
 *	setfnc()	Sets up minor device
 *	wchar()		Ouputs a character to device waits till ready
 *	rchar()		Gets a character from the device when ready
 *	status()	Returns status of device (WRDY, RDRDY)
 *	m_mdev		Minor minor device number
 *	type		Interupt driven or polled
 *
 */
struct ttydev {
	char	(*setfnc)();		/* Set up function */
	char	(*wchar)();		/* Write char */
	char	(*rchar)();		/* Read char */
	char	(*status)();		/* Status of device */
	char	m_m_dev;		/* Minor minor device */
	char	type;			/* Type of device 0 - polled, */
					/* 	1 - Interupt */
};

/* Types of device */
#define	POLLED		0		/* Polled mode */
#define	INTERUPT	1		/* Interupt mode */

/* Status word returned */
#define	WRDY		1		/* Ready for write status bit */
#define	RRDY		2		/* Ready for write status bit */

/* Types of waiting arround */
#define	WWAITB		1		/* Waiting for a write to buffer */
#define	WWAITC		2		/* Waiting for a write character */
#define	RWAITB		3		/* Waiting for a read from buffer */
#define	RWAITC		4		/* Waiting for a read character */
#define	DWAIT		5		/* Delaying (A mega doss around) */

#define	CTRL(c)	(c & 037)

/* Default settings of Sgtty */
#define INITBAUD	B9600		/* Baud rate */
#define	INITFLAGS	ECHO | CRMOD | EVENP |ODDP	/* Flags */

/* default special characters */
#define	RUBOUT	0x7F		/* Rubout character */
#define	CERASE	RUBOUT
#define	CEOT	CTRL('d')
#define	CKILL	CTRL('u')
#define	CQUIT	CTRL('\\')
#define	CINTR	CTRL('c')
#define	CSTOP	CTRL('s')
#define	CSTART	CTRL('q')
#define	CBRK	0377

#define CSUSP	0200		/* for now, later ^z */
#define CDSUSP	0200		/* for now, later ^y */

#define CRPRNT	CTRL('r')
#define CFLUSH	CTRL('o')
#define CWERAS	CTRL('w')
#define CLNEXT	CTRL('v')
#define CCLEAR	CTRL('l')

/* Useful characters */

#define	CR	0x0D
#define	NL	0x0A
#define	TAB	0x09
#define	BS	0x08

