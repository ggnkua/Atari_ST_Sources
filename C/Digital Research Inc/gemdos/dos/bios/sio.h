/*****************************************************************************
**
** sio.h -	header for sio drivers
**
** CREATED
** ktb			For Lisa GEM DOS BIOS.
**
** MODIFICATIONS
** 26 sep 85 scc	Removed Lisa specific macros and constants.
**
** NAMES
**	ktb	Karl T. Braun
**	scc	Steven C. Cavender
**
******************************************************************************
*/

/*
**  sio constants
*/

#define	CTLS		0x13
#define	CTLQ		0x11
#define	QSIZE		2048	/*  size of tx/rx queues		*/
#define	NEARFULL	1990	/* ctl- s when buffer gets up to this 	*/
#define	NEAREMPTY	32	/* ctl- q when full buffer gets down to this */
#define	HIWATER		(QSIZE - 10)
#define	LOWATER		10


/*
**  sio data structures
*/

#define	QSTRUCT		struct	q

QSTRUCT
{
    WORD front;
    WORD rear;
    WORD qcnt;
    BYTE data[QSIZE];
} ;

/*
**  conditional compile switches
*/

#define	SET_BAUD	FALSE
#define	SET_LINE	FALSE
#define	MDMCTL		FALSE		/* no support for mdm ctl lines	*/

/*
**  externals
*/

EXTERN	WORD 	rctls, sctls ;
EXTERN	BOOLEAN	rxevalid ;
EXTERN	QSTRUCT	rq, tq ;
