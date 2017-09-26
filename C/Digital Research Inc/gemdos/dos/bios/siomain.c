/*****************************************************************************
**
** siomain.c - global data for SIO drivers and stat routines
**
** CREATED
**	ktb	For Lisa GEM DOS BIOS.
**
** MODIFICATIONS
**  1 oct 85 scc	Converted to VME/10 BIOS.
**
** NAMES
**	ktb	Karl T. Braun
**	scc	Steven C. Cavender
**
******************************************************************************
*/

#include	"portab.h"
#include	"portab.h"
#include	"io.h"
#include	"sio.h"

/*
**  global variables
*/
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
**  soutstat -
**	return output status
*/

LONG	soutstat()
{
	return( tq.qcnt ? DEVNOTREADY : DEVREADY ) ;
}

/*
**  sinstat -
**	return input status.  
*/

LONG	sinstat()
{
	return( rq.qcnt ? DEVREADY : DEVNOTREADY ) ;
}


#if	SET_BAUD
/*
**  set_baud -
**	set the baud rate to the desired speed.
**	'pointer' is a ptr to the ascii string indicating which speed.
*/

VOID	set_baud(pointer)
	BYTE	**pointer;
{
}
#endif

#if	SET_LINE
/*
**  set_line -
**	set the port for which we are working on.  'pointer' is a ptr to the
**	ascii string indicating which port is desired.
**
**	not implemented in this version
*/

VOID	set_line(pointer)
	BYTE	**pointer;
{
}
#endif

