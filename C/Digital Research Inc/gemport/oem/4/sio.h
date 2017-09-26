/*  sio.h - header for sio drivers					*/
/*  DORX, DOTX, TXOFF, TXMT, RXRDY, STARTX  */


/*
**  sio constants
*/

#define	CTLS		0x13
#define	CTLQ		0x11
#define	QSIZE		2048	/*  size of tx/rx queues		*/
#define	NEARFULL	1990	/* ctl- s when buffer gets up to this 	*/
#define	NEAREMPTY	32	/* ctl- q when full buffer gets down to this */
#define	DEFESC		0x1D   	/* Default escape character for CONNECT */
#define	HIWATER		(QSIZE - 10)
#define	LOWATER		10

/*
**  local code macros
*/

#define	QSTRUCT		struct	q
#define	DORX()		( *(rs232+7) )
#define	DOTX(ch)	( *(rs232+7) = ch )
#define	TXOFF()		( *(rs232+3) = 0x28 )
#define	TXMT()		( *(rs232+3) & 4 )
#define	RXRDY()		(rq.qcnt)
#define	STARTX()	if( TXMT() ) txint()

/*
**  sio data structures
*/

QSTRUCT
{
    BYTE data[QSIZE];
    WORD front;
    WORD rear;
    WORD qcnt;
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

EXTERN	BYTE	*rs232 ;
EXTERN	WORD 	rctls, sctls ;
EXTERN	BOOLEAN	rxevalid ;
EXTERN	QSTRUCT	rq, tq ;
