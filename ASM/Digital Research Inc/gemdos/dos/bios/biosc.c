/*  biosc.c - C portion of BIOS initialization and front end		*/
/*****************************************************************************
**
**		for VME/10 GEM DOS
**
** MODIFICATIONS
** 17 sep 85 scc	This source combines what was in BIOS.C and MAIN.C
**			from the old architecture BIOS.
**
**			Changed definition of b_mdx to MD.
**
**			Changed definition of m parameter of bios_0() to
**			(MPB *).
**
** 20 sep 85 scc	Moved biosinit() here from DISK.C.
**
** 30 sep 85 scc	Added charvec[] for character device default interrupt
**			handlers.  Added code to biosinit() to initialize it.
**			Added clklox().
**
**  9 oct 85 scc	Modified bios_1() to call sinstat() for AUX:.  Added
**			declaration for sinstat().
**
**  14 Oct 85	KTB	accomodate split of fs.h into fs.h and bios.h
**
**  14 Oct 85	KTB	M01.01.01: getting rid of warnings.
**
**  30 Oct 85	KTB	M01.01.03: changed definitions of xexec() and xsetdrv()
**
**  12 Nov 85	KTB	M01.01.04: brought in panic routine as permanent res.
**
**  12 Nov 85	KTB	M01.01.05: changed printstr calls to use kprintf.
**
**  13 Nov 85	KTB	M01.01.06: added support for bdefdrv module.
**
**  03 Jun 86	KTB	M01.01.0603.01:  check drive range in bios_7
**
**  03 Jun 86	KTB	M01.01.0603.02:  check drive range before exist
**
**  02 Jul 86	KTB	M01.01a.0702.01: If osinit() returns pointer to
**			version string, print it out.
**
** NAMES
**	scc	Steven C. Cavender
**	KTB	Karl T. Braun (kral)
**
******************************************************************************
*/


#include "portab.h"
#include "bios.h"
#include "abbrev.h"
#include "gemerror.h"

#define	DBGBIOSC	FALSE
#define	INITSIO		TRUE

#ifndef	COMMENT
#define	COMMENT	0
#endif

#define	M0101060301	TRUE

/*
**  external declarations
*/

extern	char	*biosts ;	/*  time stamp string			*/
extern char env[] ;		/* found in bdefdrv.c   M01.01.06	*/
extern int  defdrv ;		/* found in bdefdrv.c 	M01.01.06	*/

extern long cons_stat();	/* found in conio.c */
extern long sinstat();		/* found in siostat.c */
extern cons_out();
extern long cons_in ();		/* found in conio.c */
extern long format();		/* found in disk.c */
extern BPB vme_dpb [];		/* found in disk.c */

extern long tticks;		/* found in biosa.s */
extern char shift_keys;		/* found in conio.c */
extern int  shifty;		/* found in conio.c */

extern char modes;		/* found in ikb.c   */

extern MD b_mdx;		/* found in biosa.s */

#if	COMMENT
extern struct dph *slctdsk ();	/* found in disk.c */
#endif

/************************************************************************/
/* BIOS  Table Definitions						*/
/************************************************************************/

static int exist[4] = { 
	1, 0, 1, 0 };  		/* nz if drive present */
static int known[4] = { 
	0, 0, 0, 0 };  		/* nz if disk logged-in */

extern long oscall();

/*  M01.01.03  */
#define	SETDRV(a)	trap_1( 0x0e , a )
#define	EXEC(a,b,c,d)	trap_1( 0x4b , a , b , c , d )

/*
**  PRTVER - set true to print bdos & bios time/date version string
*/

/*  M01.01a.0702  */
#define	PRTVER	1


/*
**  secbuf -  sector buffers
*/

char secbuf[4][512];

/*
**  bcbx - Buffer Control Block array
*/

BCB bcbx[4]; 					/* bcb for each buffer */

/*
**  bufl - buffer lists
**	two lists:  fat,dir / data
*/

BCB *bufl[2];



EXTERN VOID siolox(), moulox();
VOID clklox();

/*****************************************************************************
**
** charvec -
**	vector of logical interrupt handlers for character devices
**
******************************************************************************
*/

PFI charvec[5] =	/* note hard-coded device count */
{				/* note that if this is meant to be ROMed, */
	(PFI) 0,		/* that charvec[] should only be	   */
	siolox,			/* dimensioned, and that it should be	   */
	(PFI) 0,		/* initialized while interrupts are	   */
	clklox,			/* disabled. */
	moulox
};


/************************************************************************/
/*									*/
/*	Bios initialization.  Must be done before any regular BIOS	*/
/*	calls are performed.						*/
/*									*/
/************************************************************************/


/* The following structures are utilized for all clock/timer interrupt  */
/* references.  These references take place in biosaa.s and here below. */

#define	CLK	struct clkregstruct
CLK	/*  M01.01.01 needs name for casting	*/
{
	BYTE fill0,  c_secs;		/* seconds elapsed in current minute */
	BYTE fill2,  c_sec_alarm;	/* when to generate alarm interrupt  */
	BYTE fill4,  c_mins;		/* minutes elapsed in current hour   */
	BYTE fill6,  c_min_alarm;	/* when to generate alarm interrupt  */
	BYTE fill8,  c_hrs;		/* hours elapsed in current day	     */
	BYTE fill10, c_hrs_alarm;	/* when to generate alarm interrupt  */
	BYTE fill12, c_day_wk;		/* day of week (1-7); sunday=1       */
	BYTE fill14, c_day_mon;		/* day of month (1-31);    0xf1a08e  */
	BYTE fill16, c_mon;		/* month of year (1-12)	   0xf1a090  */
	BYTE fill18, c_yr;		/* year of century (0-99)  0xf1a092  */
	BYTE fill20, c_a;		/* register A		   0xf1a094  */
	BYTE fill22, c_b;		/* register B		   0xf1a096  */
	BYTE fill24, c_c;		/* register C		   0xf1a098  */
	BYTE fill26, c_d;		/* register D		   0xf1a09a  */
} 
*clk;		/* registers in the clock chip */

#define	VMECR	struct vmecr

VMECR	/*  M01.01.01 structure needs name for casting	*/
{
	WORD	grafvcurs;	/* graphics cursor positioning vertical */
	WORD	grafhcurd;	/* graphics cursor positioning horizontal */
	BYTE	fill0;
	BYTE	cr0;		/* control register 0 */
	BYTE	fill1;
	BYTE	cr1;		/* control register 1 */
	BYTE	fill2;
	BYTE	cr2;		/* control register 2 */
	BYTE	fill3;
	BYTE	cr3;		/* control register 3 */
	BYTE	fill4;
	BYTE	cr4;		/* control register 4 */
	BYTE	fill5;
	BYTE	cr5;		/* control register 5 */
	BYTE	fill6;
	BYTE	cr6;		/* control register 6 */
	BYTE	fill7;
	BYTE	grafofst;
} 
*vmecr;				/* vme10 control registers */

/*
**  biosinit - bios initialization. 
**	called from biosa.s, this routine will do necessary bios initialization
**	that can be done in hi level lang.  biosa.s has the rest.
*/

biosinit()
{

#if ! INITIALIZE		/* skip if init.rel */
	char	scratch;

	/* initialize the timer interrupt */
	clk = (CLK *) 0xF1A080;		/* @ of clock chip 		*/
	vmecr = (VMECR *) 0xF19F00;	/* @ of vme10 control regs M01.01.01 */

	/* start the timer intrs occurring */
	vmecr->cr0	|= 0x02;	/* enable timer in CR0 only */
	clk->c_b	|= 0x80;	/* inhibit update so can set clock */

	/* set periodic interrupt to 15.625 ms*/
	clk->c_a 	 = (((clk -> c_a) & 0xf0) | 0x0a);
	scratch		 = clk -> c_c;	/* reset interrupt flag */
	clk->c_b	 = 0x46;	/* initialize and start timer */
#endif

	c_init();		/* initialize the system console */
#if	INITSIO
	m400init();		/* initialize the serial I/O ports */
#endif

#if	MVME410
	m410_init();		/* initialize the parallel printer ports */
#endif

	/*
	**  print version string
	*/

#if	PRTVER
	kprintf("\033H\033J");	/* clear screen */
	kprintf(biosts) ;

	kprintf("LOWTPA = %lX   LENTPA = %lX \n\r",
	    (long)b_mdx.m_start,(long)b_mdx.m_length) ;
	if (b_mdx.m_start < 0x180000L)
		kprintf("System has inadequate memory for GEM AES & DESKTOP.\r\n");

#endif
	initdsks();		/* send disk config info to disk controller */
}


/*
**  cmain - c part of the bios init code
**	inits the disk buffer cache.
**	invokes the bdos init code
**	possibly prints bdos date/version string
**	exec the CLI
*/

cmain()
{
	long	l;
	extern	long	osinit() ;

	/* set up sector buffers */
	bcbx[0].b_link = &bcbx[1];
	bcbx[2].b_link = &bcbx[3];

	/*  
	**  invalidate BCBs
	*/

	bcbx[0].b_bufdrv = -1;
	bcbx[1].b_bufdrv = -1;
	bcbx[2].b_bufdrv = -1;
	bcbx[3].b_bufdrv = -1;

	/*
	**  initialize buffer pointers in BCBs
	*/

	bcbx[0].b_bufr = &secbuf[0][0];
	bcbx[1].b_bufr = &secbuf[1][0];
	bcbx[2].b_bufr = &secbuf[2][0];
	bcbx[3].b_bufr = &secbuf[3][0];

	/*
	**  initialize the buffer list pointers
	*/

	bufl[BI_FAT] = &bcbx[0]; 			/* fat buffers */
	bufl[BI_DATA] = &bcbx[2]; 			/* dir/data buffers */

	l = osinit();					/*  l => bdos 	*/
#if	PRTVER
	if( l != 0 )					/*  date/version*/
		kprintf("%s\n",(char *)l) ;
#endif
	SETDRV(defdrv);					/*  M01.01.06	*/
	l = EXEC(0,"COMMAND.PRG","",env);
	kprintf("******* cmain: xexec returns %lx\n\r",l) ;

	while(1) ;
}


/*****************************************************************************
*/

bios_0(m)
MPB *m;
{
	m->mp_mfl = m->mp_rover = &b_mdx;
	m->mp_mal = (MD *)0;
}


/*****************************************************************************
*/
/* Returns status in D0.L:		*/
/*  	-1	device is ready		*/
/* 	 0	device is not ready	*/

LONG bios_1(handle)	/* GEMBIOS character_input_status */
WORD	handle;		/* 0:PRT 1:AUX 2:CON */
{
	switch(handle & 7)
	{
	case h_PRT :
		return(NULL); 		/* This device does not accept input */

	case h_AUX :
		return( sinstat() );

	case h_CON :
		return ( cons_stat() );

	default:
		return(NULL);		/* non-existent devices never ready */
	}
}


/*****************************************************************************
*/
/* This function does not return until a character has been */
/* input.  It returns the character value in D0.L, with the */
/* high word set to zero.  For CON:, it returns the GSX 2.0 */
/* compatible scan code in the low byte of the high word, & */
/* the ASCII character in the lower byte, or zero in the    */
/* lower byte if the character is non-ASCII.  For AUX:, it  */
/* returns the character in the low byte.		    */

LONG bios_2(handle)	/* GEMBIOS character_input() */
int	handle;		/* 0:PRT 1:AUX 2:CON */
{

	switch(handle)
	{
	case h_PRT :
		return(NULL);		/* printer is not an input dev*/

	case h_AUX :
		return(sgetc());	/* read input f serial port A */

	case h_CON :
		return( cons_in() );		/* read the keyboard */

	default:
		return(NULL);			/*non-existnt devices ret null*/

	}
}

/*****************************************************************************
*/

bios_3(handle,what)	/* GEMBIOS character_output */
int	handle;		/* 0:PRT 1:AUX 2:CON */
char	what;		/* the byte to output */
{
	switch(handle & 3)
	{
	case h_PRT :
#if MVME410
		m410_out(what);		/* output char to parallel printer */
#else
		sputc(what);		/* output char to printer	   */
#endif
		break;

	case h_AUX :
		sputc(what);		/* output char to AUX:		*/
		break;

	case h_CON :
		cons_out(what);		/* output char to the screen	*/
		break;

	default:
		cons_out(what);
		break;

	}
}


/*****************************************************************************
*/
/* Returns a 2's complement error number in D0.L.  It */
/* is the responsibility of the driver to check for   */
/* media change before any write to FAT sectors.  If  */
/* media has changed, no write should take place, just*/
/* return with error code.			      */

/*
**  bios_4 - read/write disk sectors
*/

LONG bios_4(r_w,adr,numb,first,drive)	/* GEMBIOS read_write_sectors */
WORD	r_w;			/* 0:Read 1:Write */
BYTE	*adr;			/* where to get/put the data */
WORD	numb;			/* # of sectors to get/put */
WORD	first;			/* 1st sector # to get/put= 1st record # tran*/
WORD	drive;			/* drive #: 0 = A:, 1 = B:, etc */
{
	WORD	n;
	LONG	error, adr_inc;

#if	DBGBIOSC
	fkprintf( 1 , "Entering biosc:bios_4(%x,%lx,%x,%x,%x)" ,
		r_w, adr, numb, first, drive) ;
#endif

	/*  M01.01.0603.02  */
	if( ( drive > MAXDSK ) ||  (! exist[drive] ) )
		return(EDRVNR);	/* T iff asking for a drive we ain't got */

	known[drive] = 1;

	/* we told gemdos we have 512 byte sectors */

	if (drive < 2)		/* True iff it is a floppy else h.d.  */
	{
		adr_inc = 0x1FF00L;
		tticks = 0;		/* reinitiz timer tick count cause new*/
	}				/*     disk access is now taking place*/
	else	/* Get here iff it is a H. D. access  */
	{
		adr_inc = 0xFF00L;
	}

	while (numb)
	{
		n = (numb > 255) ? 255 : numb;

		if (r_w == 0)
		{
			if (error = ReadSector(drive, (long)first, n, adr))
				return(error);
		}
		else if (r_w == 1)
		{
			if (error = WriteSector(drive, (long)first, n, adr))
				return(error);
		}
		else
			return (EBADRQ);

		numb -= n;
		first += n;
		adr += adr_inc;
	}
	return(E_OK);
}


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/
#if 0
Function 05
-----------
LONG set_exception_vector(vecnum, vecadr)/* HANDLED IN ASSEMBLER IN BIOSA.S */
WORD vecnum;
LONG vecadr;
{
}
#endif

/*--------------------------------------------------------------------------*/
LONG bios_6()	/* GEMBIOS get_timer_ticks */
{
	return(16L);	/* intterupt is 64 Hz so 15.625 ms is the period */
}

/*--------------------------------------------------------------------------*/
/* Returns a pointer to the BIOS Parameter Block for  */
/* the specified drive in D0.L.  If necessary, it     */
/* should read boot header information from the media */
/* in the drive to determine BPB values.	      */
LONG bios_7(drive)	/* GEMBIOS *get_bpb */
WORD	drive;		/* drive number of interest:  0 = drv A, 1 = B:, etc */
{
#if	M0101060301
	return(  ( drive>MAXDSK  ||  !exist[drive] ) ? 0L : &vme_dpb[drive]  );
#else
	if(exist[drive])
		return((LONG)&vme_dpb[drive]);
	else
		return(0L);	/* drive doesn't exist */
#endif
}


/*--------------------------------------------------------------------------*/
/* Returns status in D0.L:	*/
/* -1	device is ready		*/
/* 0	device is not ready	*/
LONG bios_8(handle)	/* GEMBIOS character_output_status */
WORD	handle;		/* 0:PRT 1:AUX 2:CON */
{
	switch(handle)
	{
	case h_PRT :
#if MVME410
		if (m410_stat ())
			return (dev_RDY);
		else return (NULL);
#else
		return(dev_RDY);
#endif

	case h_AUX :
		return( soutstat() );

	case h_CON :
		return(dev_RDY);

	default:
		return(NULL);			/*non-existnt devices ret null*/

	}
}


/*--------------------------------------------------------------------------*/
/* Returns media change status for specified drive in D0.L: */
/* 0	Media definitely has not changed		    */
/* 1	Media may have changed				    */
/* 2	Media definitely has changed			    */
/* where "changed" = "removed" 				    */
LONG bios_9(drv)
WORD	drv;
{
	if(drv < 2)			/* T iff is a floppy disk drive	      */
	{
		if (tticks > 320)	/* T iff no disk access in last 5 sec */
			return(1L);	/* no floppy disk access in past 5 sec*/
	}
	return(0L);		/* winchesters cannot have media chngd and    */
	/* assumption is that no m changed if floppy  */
	/* disk access in last 5 sec; 64 ticks/sec    */
}



/*--------------------------------------------------------------------------*/
/* Returns a long containing a bit map of logical drives on */
/* the system, with bit 0, the least significant bit,       */
/* corresponding to drive A.  Note that if the BIOS supports*/
/* logical drives A and B on a single physical drive, it    */
/* should return both bits set if a floppy is present.	    */
LONG bios_A()
{
	return(exist[0] | (exist[1]<<1) | (exist[2]<<2) | (exist[3]<<3));
}



/***************************************************************************
**  bios_B - (kbshift)  Shift Key mode get/set.
**  two descriptions:
**	o	If 'mode' is non-negative, sets the keyboard shift bits
**		accordingly and returns the old shift bits.  If 'mode' is 
**		less than zero, returns the IBM0PC compatible state of the 
**		shift keys on the keyboard, as a bit vector in the low byte 
**		of D0
**	o	The flag parameter is used to control the operation of 
**		this function.  If flag is not -1, it is copied into the
**		state variable(s) for the shift, control and alt keys,
**		and the previous key states are returned in D0.L.  If 
**		flag is -1, then only the inquiry is done.
*/

LONG bios_B(flag)
WORD flag;
{
	WORD oldy;

	if(shift_keys & LEFT)
		shifty |= 1;			/* bit 0 */
	if(shift_keys & RIGHT)
		shifty |= 2;			/* bit 1 */
	if(modes & CTRL)
		shifty |= 4;			/* bit 2 */
	if(modes & ALT)
		shifty |= 8;			/* bit 3 */
	if(modes & ALPHA_LOCK)
		shifty |= 16;			/* bit 4 */
	if(flag == -1)
		return(shifty);

	oldy = shifty;
	shift_keys &= ~(LEFT | RIGHT);	/* clear previous state of shift keys */
	modes &= ~(ALT | CTRL | ALPHA_LOCK);

	if(flag & 1) 				/* right shift */
		shift_keys &= ~RIGHT;
	if(shifty & 2) 				/* left shift */
		shift_keys |= LEFT;
	if(shifty & 4) 				/* control key */
		modes |= CTRL;
	if(shifty & 8) 				/* alt key */
		modes |= ALT;
	if(shifty & 16)				 /* caps lock key */
		modes |= ALPHA_LOCK;
	return(oldy);
}


/*****************************************************************************
**
** bios_C - character device control channel input
*/

LONG	bios_C(handle, length, buffer)
WORD	handle, length;
BYTE	*buffer;
{
	bios_null( handle, length, buffer ) ;	/*  for lint		*/
	return(ERR);
}


/*****************************************************************************
**
** bios_D - character device control channel output
*/

LONG	bios_D(handle, length, buffer)
WORD	handle, length;
BYTE	*buffer;
{
	bios_null( handle, length, buffer) ;	/* for lint  */
	return(ERR);
}


/*****************************************************************************
**
** bios_E - block device control channel input
*/

LONG	bios_E(drive, length, buffer)
WORD	drive, length;
BYTE	*buffer;
{
	bios_null( drive , length , buffer ) ;	/*  for lint	*/
	return(ERR);
}


/*****************************************************************************
**
** bios_F - block device control channel output
*/

LONG	bios_F(drive, length, buffer)
WORD	drive, length;
BYTE	*buffer;
{
	if ((drive == 0) || (drive == 1))
	{
		if ((length == 1) && (buffer[0] == 1))	/* disk format */
		{
			return(format(drive));
		}
	}
	return( EBADRQ ) ;
}


/*****************************************************************************
**
** bios_10 - character device exchange logical interrupt vector
**
******************************************************************************
*/

PFI	bios_10(handle, address)
WORD	handle;
PFI	address;
{
	PFI	temp;

	if (handle < 5)	/* note hard-coded device count */
	{
		temp = charvec[handle];
		if (address != (PFI)-1)
			charvec[handle] = address;
		return(temp);
	}
	return((PFI)ERR);
}

/*
**  clklox -
*/

VOID	clklox(flags, ticks)
LONG	flags, ticks;
{
	bios_null( (WORD)flags , (WORD)ticks , 0L ) ;	/* for lint	*/
}


/*
**  nullint - an unexpected interrupt has happened
**	the 'a' parameter is really the first word in the information pushed
**	onto the stack for exception processing.
*/

VOID	nullint(a)
WORD	a ;
{
	WORD	*b ;

	b = &a ;
	kprintf("\n\rUnexpected Interrupt: %x %x %x %x\n\r",
	    b[0],b[1],b[2],b[3]) ;
	kpanic("System Crash") ;
}
/*
**  kpanic - throw out a panic message and halt
*/

kpanic( s )
char	*s ;
{
	kprintf( "\n\rpanic: %s\n\r",s ) ;
	while(1)
		;
}


/*
**  bios_null - so lint wont complain
*/

bios_null( x , y , ptr )
UWORD	x, y ;
BYTE	*ptr ;
{
	x = y ;
	y = x ;
	++ptr ;
}

