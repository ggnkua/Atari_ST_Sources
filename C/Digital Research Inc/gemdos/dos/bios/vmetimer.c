/*  vmetimer.c - PROTOTYPE for vme timer driver				*/

#include	"kportab.h"
#include	"bios.h"
#include	"interrup.h"
#if	0
#include	"ivec.h"
#endif
#include	"vmecr.h"
#include	"clock.h"




/*****************************    local constants   ************************/

/*
**  VMECLKADDR  - Base Address for Vme Clock Register map
*/

#define	VMECLKADDR	((CLK *)(0xF1A080)) 



/*****************************  data structures ************************/

/*
**  CLK - clock memory map for the MC146818 RTC + Ram
*/

#define	CLK	struct clkregstruct
CLK	/*  M01.01.01 needs name for casting	*/
{
	BYTE c_fil0,  c_secs;		/* seconds elapsed in current minute */
	BYTE c_fil2,  c_sec_alarm;	/* when to generate alarm interrupt  */
	BYTE c_fil4,  c_mins;		/* minutes elapsed in current hour   */
	BYTE c_fil6,  c_min_alarm;	/* when to generate alarm interrupt  */
	BYTE c_fil8,  c_hrs;		/* hours elapsed in current day	     */
	BYTE c_fil10, c_hrs_alarm;	/* when to generate alarm interrupt  */
	BYTE c_fil12, c_day_wk;		/* day of week (1-7); sunday=1       */
	BYTE c_fil14, c_day_mon;	/* day of month (1-31);    0xf1a08e  */
	BYTE c_fil16, c_mon;		/* month of year (1-12)	   0xf1a090  */
	BYTE c_fil18, c_yr;		/* year of century (0-99)  0xf1a092  */
	BYTE c_fil20, c_a;		/* register A		   0xf1a094  */
	BYTE c_fil22, c_b;		/* register B		   0xf1a096  */
	BYTE c_fil24, c_c;		/* register C		   0xf1a098  */
	BYTE c_fil26, c_d;		/* register D		   0xf1a09a  */
} ;

	/*
	**  register values
	*/

/*  register A (read/write)						*/
#	define	CA_UIP	0x080		/*  T: update in progress	*/
#	define	CA_DIV	0x070		/*  mask for dividers		*/
#		define	CAD_4MHZ	0x000	/*  4.194304 MHz base	*/
#		define	CAD_1MHZ	0x010	/*  1.048576 MHz base	*/
#		define	CAD_32KHZ	0x020	/*  32.768   KHz base	*/
#		define	CAD_RESET	0x070	/*  reset function	*/
#	define	CA_RATE	0x00f		/*  mask for rate selectors [1]	*/
#		define	CAR_NONE	0x000	/*  None		*/
#		define	CAR_030US	0x001	/*   30.517 us		*/
#		define	CAR_061US	0x002	/*   61.035 us		*/
#		define	CAR_122US	0x003	/*  122.070 us		*/
#		define	CAR_244US	0x004	/*  244.141 us		*/
#		define	CAR_500US	0x005	/*  488.281 us		*/
#		define	CAR_001MS	0x006	/*  976.562 us		*/
#		define	CAR_002MS	0x007	/*  001.953 ms		*/
#		define	CAR_004MS	0x008	/*  003.906 ms		*/
#		define	CAR_008MS	0x009	/*  007.813 ms		*/
#		define	CAR_016MS	0x00a	/*  015.625 ms		*/
#		define	CAR_032MS	0x00b	/*  031.250 ms		*/
#		define	CAR_064MS	0x00c	/*  062.500 ms		*/
#		define	CAR_125MS	0x00d	/*  125.xxx ms		*/
#		define	CAR_250MS	0x00e	/*  250.xxx ms		*/
#		define	CAR_500MS	0x00f	/*  500.xxx ms		*/
/*  register B (read/write)						*/
#	define	CB_SET	0x080		/*  T: inhibit clock update	*/
#	define	CB_PIE	0x040		/*  T: Enable Periodic Ints.	*/
#	define	CB_AIE	0x020		/*  T: Enable Alarm Interrupts	*/
#	define	CB_UIE	0x010		/*  T: Enable Update-End Ints.	*/
#	define	CB_SQWE	0x008		/*  T: Enable Sq Wave Gen'r	*/
#	define	CB_DM	0x004		/*  T: Binary Mode, F: BCD Mode	*/
#	define	CB_24HR	0x002		/*  T: 24 Hr Mode, F: 12 Hr Md	*/
#	define	CB_DSE	0x001		/*  T: Enable Daylight Savings	*/
/*  register C (Read Only)						*/
#	define	CC_IRQF	0x080		/*  T: Interrupt Pending	*/
#	define	CC_PF	0x040		/*  T: Periodic Interrupt Pendg	*/
#	define	CC_AF	0x020		/*  T: Alarm Interrupt Pending	*/
#	define	CC_UF	0x010		/*  T: Update-End Interrupt Pdg	*/
/*  register D (Read Only)						*/
#	define	CD_VRT	0x080		/*  T: Valid Ram and Time	*/


/*
** [1]	Only the Periodic Interrupt Rate Values are shown.  For more accurate
**	timing data, see MOTOROLA 8-BIT MICROPROCESSOR & PERIPHERAL DATA
**	manual under MC146818.
*/

/*******************************  code macros *******************************/

	/*
	**  wt4update - wait for update in progress to go false
	*/

#define	wt4update()	{CLK *p=VMECLKADDR ; while( p->c_a & CA_UIP ) ; }


	/*
	**  SETVEC - set hardware interrupt vector
	*/

#define	SETVEC		hsetv




/********************************** global data ***********************/

/*
**  timhdr - timer driver header
**	must be first in data segment
*/

#if	0
DH	timhdr =
{
	NULL,
	MAXUNITS,
	DHF_DSYNC,		/* Driver Level Interface */
	t_init,			/*  init routine		*/
	t_null,			/*  reserved (cdos subdriver	*/
	t_uninit,		/*  uninit routine		*/
	t_select,		/*  select (open)		*/
	t_flush,		/*  flush (clear any buffers	*/
	t_read,			/*  standard read		*/
	t_write,		/*  standard write		*/
	t_get,			/*  standard get parameters	*/
	t_set,			/*  standard set parameters	*/
	t_special,		/*  special routine interface	*/
	NULL, NULL, NULL,
	NULL,
	(LONG (**)())NULL,
};

#endif


/*
**  inittime - time after clock was set up.
*/

TIME	inittime ;

/*
**  initimage - image of clock registers at init time
*/

CLK	initimage ;

/*
**  tnticks - total number of ticks that have occurred since boot, mod (long)
*/

long	tnticks = 0 ;

/*
**  nms - total number of milleseconds since boot, modulow 4 gig.
*/

long	nms = 0 ;


/*
**  initrc - init return code.  cl_init stores it's return code here for
**	postmortem analysis.
*/

int	initrc = 0x0a0a ;		/* invalid value		*/

/*
**  ostick - address to call every tick
*/

PFI	ostick = 0 ;
 
/***************************************************************************
			timer driver xface routines
				for gemdos 1.x
***************************************************************************/

#if	0
ERROR	t_init()
{
	PISR	dummy ;
	int	rc ;

	SETVEC( TIMVECNO , cl_intr ) ;
	rc = cl_init() ;
	return( rc < 0 ? -1L : 0L ) ;
}
#endif


/***************************************************************************
			clock manipulation routines
***************************************************************************/


/*
**  cl_init - initialize clock 
**	not re-entrant code.
**
**  returns:
**	-1:	hardware error, can't initialize
**	 0:	init complete, battery power available.
**	+1:	init complete, no battery power available.
*/

int	cl_init()
{
	REG CLK		*clk = VMECLKADDR ;
	REG VMECRP	vmecr = VMECRADDR ;
	int		tmp, i ;



	/*
	**  if we have battery power, no need to do anything
	*/

	cl_imgdump( &initimage ) ;		/*  get current image	*/
	if( clk->c_d & CD_VRT )
		return( initrc = 0 ) ;

	/*
	**  disable timer interrupts in cr0, reset the clock chip
	*/

	vmecr->cr0 &= ~C0_TIMIMSK ;
	clk->c_b = CB_SET ;

	/* 
	**  use 4MHz rate and set int to ~16ms (see defs, above)
	*/

	clk->c_a = CAD_4MHZ | CAR_032MS ;

	/*
	**  clear all pending interrupts
	**	if there is a pending interrupt, one or more flags are set
	**	in reg c.  merely reading this reg should clear the interrupt.
	**	In case something is stacked up, we keep reading if the bits
	**	don't clear, but we don't loop forever... [1]
	*/

	for( i = 32 ; (i--) && (tmp = clk->c_c) ; )
		;

	/*
	**  set mode: binary and 24 hour clock
	*/

	clk->c_b = CB_DM | CB_24HR | CB_PIE ;

	/*
	**  save time at init and deterine init status
	*/

	cl_gettime( &inittime ) ;
	initrc = clk->c_d & CD_VRT ? 0 : -1 ;

	/*
	** enable periodic interrupts
	*/

	if( initrc == 0 )
	{
		clk->c_b |= CB_PIE ;
		vmecr->cr0 |= C0_TIMIMSK ;/* enable timer in CR0 only 	*/
	}

	return( initrc ) ;
}
/*
** [1]	the loop count is arbitrary.  I don't have any reason except paranoia
**	for looping on clearing the interrupts, so if you know better, take it
**	out.
*/

/*
**  cl_intr - clock interrupt handler
**	Only periodic interrupts are handled right now.
**	returns quantum since last tick (in ms)
*/

ISR	cl_intr()
{
	static int	intrctr ;		/* [1]  */
	static int	qtm[2] = {31,32} ;
	int		realqtm ;

	++tnticks ;			/*  advance ticks ctr		*/
	intrctr = (intrctr + 1) % 4 ;
	realqtm = qtm[ (intrctr == 0) ] ;
	
	if( charvec[3] )
		(*charvec[3])(IF_RPKT,(long)realqtm) ;

}

/*
**  [1]	QTM: current resolution is 31.25 ms.  So we tell the external logic
**	(ostick()) that 31 ms has passed since the last tick, except for
**	every 4th tick, when we tell it 32 ms has passed.  We get the correct
**	qtm (quantum) by comparing the intrctr with 0.  If it is 0, we pass
**	the upper qtm, otherwise the lower qtm.
*/



/*
**  cl_gettime - put the current time into the buffer.
**
**  returns:
**	TRUE if valid time returned
**	FALSE if fail.
*/

BOOLEAN	cl_gettime( t )
	REG TIME	*t ;
{
	REG CLK		*c = VMECLKADDR ;

	wt4update() ;

	/*  see if hardware fault (VRT is Valid Ram & Time flag on clock)  */

	if( ! c->c_d & CD_VRT  )
		return( FALSE ) ;

	t->ti_sec = c->c_secs ;
	t->ti_min = c->c_mins ;
	t->ti_hour = c->c_hrs ;
	t->ti_daymo = c->c_day_mon ;
	t->ti_daywk = c->c_day_wk ;
	t->ti_mon = c->c_mon ;
	t->ti_year = c->c_yr ;

	return( TRUE ) ;
}

/*
**  cl_settime - set the current clock
*/
BOOLEAN	cl_settime( t )
	REG TIME	*t ;
{
	REG CLK		*c = VMECLKADDR ;
	static int	temp ;

	c->c_b |= CB_SET ;		/*  disable updates		*/

	c->c_secs = t->ti_sec ;
	c->c_mins = t->ti_min ;
	c->c_hrs = t->ti_hour ;
	c->c_day_wk = t->ti_daywk ;
	c->c_day_mon = t->ti_daymo ;
	c->c_mon = t->ti_mon ;
	c->c_yr = t->ti_year ;

	temp = c->c_d ;			/*  read reg d to 'set' vrt	*/
	c->c_b &= ~CB_SET ;		/*  enable updates		*/

	/*
	**  if VRT is still set, ram is valid, otherwise it's not
	*/

	return( c->c_d & CD_VRT ? TRUE : FALSE ) ;
}	


/*
**  cl_imgdump - dump image of clock chip
*/

VOID	cl_imgdump( ci )
	CLK	*ci ;
{
	CLK	*c = VMECLKADDR ;

	ci->c_secs = c->c_secs ;
	ci->c_mins = c->c_mins ;
	ci->c_hrs = c->c_hrs ;
	ci->c_day_mon = c->c_day_mon ;
	ci->c_day_wk = c->c_day_wk ;
	ci->c_mon = c->c_mon ;
	ci->c_yr = c->c_yr ;
	ci->c_a = c->c_a ;
	ci->c_b = c->c_b ;
	ci->c_c = c->c_c ;
	ci->c_d = c->c_d ;

}


#ifndef	wt4update
/*
**  wt4update - returns when update in progress flag is false
*/

VOID	wt4update()
{
	REG CLK	*p ;

	while( p->c_a & CA_UIP )
		;
}
#endif


