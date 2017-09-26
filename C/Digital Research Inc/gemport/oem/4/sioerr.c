/*  sioerr.c - error module for sio driver				*/

#include	"portab.h"
#include	"gemerror.h"
#include	"io.h"
#include	"sio.h"


/*
**  global variables
*/

	/*
	**  rxevalid -, rxerror -
	**	if rxevalid is TRUE, then rxerror contains a code (see io.h)
	**	specifying an error condition which occurred after the last
	**	call to the get_receive_status or get_receive_char.
	*/

	BOOLEAN	rxevalid = FALSE ;
	ECODE	rxerror = 0 ;


/*
**  seterr -
**	set an error code into rxerr.
*/

VOID	seterr( ec )
	ECODE	ec ;
{
	if( rxevalid )
	{	/*  there is already an error code in rxerror  */
		rxerror |= ec ;
	}
	else
	{
		rxevalid = TRUE ;
		rxerror = ec ;
	}
}


/*
**  secode -
**	return the current error code, reset rxevalid
*/

ECODE	secode()
{
	ECODE	ec ;

	if( rxevalid )
	{
		ec = rxerror ;
		rxevalid = FALSE ;
	}
	else
	{
		ec = E_OK ;
	}

	return( ec ) ;
}
