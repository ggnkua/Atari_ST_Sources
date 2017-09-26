/*  siostat.c - get/set status routines for gemdos sio driver		*/
/*  contains: soutstat, sinstat, setvec					*/
/*	and no naturally occurring ingredients				*/


#include	"portab.h"
#include	"io.h"
#include	"sio.h"


EXTERN	PFI	siovec ;



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


/*
**  setvec -
**	set interrupt vector for user's routine
*/

PFI	setvec( newvec ) 
	PFI	newvec ;	/*  ptr to user's routine		*/
{
	PFI	oldvec ;

	oldvec = siovec ;
	siovec = newvec ;
	return( oldvec ) ;
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

