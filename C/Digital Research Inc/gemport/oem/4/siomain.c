/*  siomain.c - main module for gemdos/lisa sio drivers.  		*/
/*  global data, init routines						*/

/****************************************************************************
**
**  improvements
**
**  1	make determination of port dynamic by storing an indicator and looking
**	at that indicator for port-dependant code.	- ktb
**
****************************************************************************/


#include	"portab.h"
#include	"io.h"
#include	"sio.h"

/*
**  external only to this  module
*/

	/*
	**  initialize/uninitialize routines
	*/

	EXTERN	VOID	sioinit() ;
	EXTERN	ISR	siolox() ;

/*
**  global variables
*/
	/* 
	**  Version String 
	*/

	BYTE *siover = "Lisa Sio Drivers for GEMDOS version 01.02" ;

	/*
	**  rs232 -
	**	ptr to rs232 port
	*/

	BYTE *rs232 = (BYTE *) 0xFCD200 ; 

	/*
	**  rctls -, sctls -
	*/

	WORD rctls, sctls;		/* received ctl-s, sent ctl-s 	*/

	/*
	**  rq -, tq -
	**	que structures for transmit and receive
	*/

	QSTRUCT	rq, tq ;

	/*
	**  siovec -
	**	pointer to current logical interrupt handler (lox)
	*/

	PFI	siovec ;

/*
**  sinit -
**	initialize the driver
*/

VOID	sinit()
{
	extern int	sioint() ;

	siovec = ADDRESS_OF( siolox ) ;	/*  our log intr hand.	*/
	rq.front = rq.rear = rq.qcnt = 0; 	/*  init rx queue	*/
	tq.front = tq.rear = tq.qcnt = 0;	/*  init tx queue	*/
	sioinit();				/*  init hardware	*/
}

/*
**  dinit -
**	wait for the tx que to drain and uninitialize the driver.
*/

VOID	sdinit()
{
	while (tq.qcnt) ;			/*  wait for tx to fin	*/
	rq.front = rq.rear = rq.qcnt = 0; 	/*  clear rx queue	*/
	tq.front = tq.rear = tq.qcnt = 0;	/*  clear tx queue	*/
	siodinit();				/*  reset hardware	*/
}

