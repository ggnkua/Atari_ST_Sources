/*****************************************************************************
**
** conio.c - Console/keyboard I/O routines
**
** MODIFICATIONS
**  9 oct 85 scc	Changed returns by cons_stat().
**
**  14 Oct 85	KTB	accomodate split of fs.h into fs.h and bios.h
**
**  12 Mar 86	ktb	interrupt driven keyboard
**
** NAMES
**	scc	Steven C. Cavender
**	KTB	Karl T. Braun (kral)
**
******************************************************************************
*/

#include "portab.h"
#include "bios.h"
#include "kbd.h"
#if	0
#include "bios.h"
#include "abbrev.h"
#endif


int	shifty ;


/*
**  _char_save - peek ahead buffer.  If cons_stat gets a valid read from the
**	driver, the character is stored here, and char_avail is set true.
*/

KBCHAR	_char_save = 0 ;

/*
**  _char_avail - set true when char_save contains a valid character.
*/

int	_char_avail = FALSE ;

/*
**  c_init - initialize console
*/

c_init()
{
	_char_avail = FALSE ;
	kbinit() ;
}

/*
**  cons_stat - get console input status
**	See if we have a character saved from the last call to cons_stat.  If
**	we do, return HAVE_CHAR.  If not, try and read a character from the
**	driver.  If we get one, save it and return (HAVE_CHAR).  Otherwise
**	return 0.
**
**  returns:
**	-1:	if character available	(HAVE_CHAR)
**	 0:	if not
*/

long cons_stat()
{
	KBCHAR		kbread() ;

	if( ! _char_avail  )
	{
		if(   (_char_save=kbread()) == -1L  )
			return( 0 ) ;
		_char_avail = TRUE ;
	}
	return( -1L ) ;
}
 

/*
**  cons_in - wait for and return a character from the console
**	bios13(2...)
**	wait for a cons_stat to indicate that there is a character available
**	then fetch it.
*/

long	cons_in()	/* called for bios13, function 2 */
{
	while( ! cons_stat() )		/* wait for input */
		;

	_char_avail = FALSE ;
	return( _char_save );
}
 
/************************************************************************/ 
/*	VME-10 Console output						*/
/************************************************************************/
 
/*	console output is in vt52.c, not biosa.s			*/
 
/************************************************************************/ 
/*      Error procedure for BIOS					*/
/************************************************************************/

bioserr(errmsg)
REG BYTE *errmsg;
{
        printstr("\n\rBIOS ERROR -- ");
        printstr(errmsg);
        printstr(".\n\r");
}
 
printstr(s)     /* used by bioserr */
REG BYTE *s;
{ 
        while (*s)
		cons_out(*s++);
}
