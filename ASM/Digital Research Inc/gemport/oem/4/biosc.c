/*  biosc.c - bios interface module.  compliments biosa.s		*/

#include	"portab.h"
#include	"io.h"
#include	"gemerror.h"
#include	"fs.h"

/*
**  *************************  to go in bios.h ***************************
*/

#define	IOCFMT	1
#define	DRVA	0
#define	DRVB	1
#define	DRVC	2

/*
**  *******************************  end  ********************************
*/


#define	COMMENT	0


/*
**  external declarations
*/

	/*
	**  console
	*/

EXTERN	VOID	coninit() ;
EXTERN	LONG	coutstat() ;
EXTERN	LONG	cinstat() ;
EXTERN	LONG	cgetc() ;
EXTERN	LONG	cputc() ;
EXTERN	LONG	setvec(), mousvec(), clksvec() ;

	/*
	**  floppy
	*/

EXTERN	LONG	ffmt() ;

	/*
	**  printer
	*/

EXTERN	LONG	pinstat() ;
EXTERN	LONG	poustat() ;
EXTERN	LONG	pputc() ;
EXTERN	LONG	pgetc() ;

	/*
	**  aux (serial)
	*/

EXTERN	LONG	sinstat() ;
EXTERN	LONG	soutstat() ;
EXTERN	LONG	sputc() ;
EXTERN	LONG	sgetc() ;




/*
**  bchistat -
**	trap 13, function # 1.  return input status.
**	vector to appropriate handler
*/

LONG	bchistat(h)
	int	h ;		/*  file handle				*/
{
	switch(h)
	{
		case BFHPRN: return(  pinstat() ) ;
		case BFHAUX: return(  sinstat() ) ;
		case BFHCON: return(  cinstat() ) ;
		case BFHCLK:
		case BFHMOU:
		default:
			return(  DEVREADY  ) ;
	}
}



/*
**  bchostat -
**	trap 13, function # 8.  return output status.
**	vector to appropriate handler
*/

LONG	bchostat(h)
	int	h ;
{
	switch( h )
	{
		case BFHPRN:	return( poutstat() ) ;
		case BFHAUX:	return( soutstat() ) ;
		case BFHCON:	return( coutstat() ) ;
		case BFHCLK:
		case BFHMOU:
		default:
				return( DEVREADY ) ;
	}
}




/*
**  bchgetc 
**	Trap 13, func 2.  character input vector.
**	vector to appropriate handler
*/

LONG	bchgetc( h )
	int	h ;
{
	switch( h )
	{
		case BFHPRN:	return(  pgetc() ) ;
		case BFHAUX:	return(  sgetc() ) ;
		case BFHCON:	return(  cgetc() ) ;
		case BFHCLK:
		case BFHMOU:
		default:
				return( ERROR ) ;
	}
}




/*
**  bchputc -
**	Trap 13, func 3.  character output vector.
**	vector to appropriate handler
*/

LONG	bchputc( h, c )
	int	h, c ;
{
	switch( h )
	{
		case BFHPRN:	return(  pputc( c ) ) ;
		case BFHAUX:	return(  sputc( c ) ) ;
		case BFHCON:	return(  cputc( c ) ) ;
		case BFHCLK:
		case BFHMOU:
		default:
				return( ERROR ) ;
	}
}




/*
**  bchictl -  trap 13, func 0x0c
**	character input control
*/

LONG	bchictl( h , len , buffer )
	WORD	h ;		/*  device handle			*/
	WORD	len ;		/*  length of control string		*/
	BYTE	*buffer ;	/*  ptr to control string		*/
{
	LONG	r ;

	/*  for now just return an error				*/

	if( len == 0 )
	{	/*  does device do i/o ctrl ?  */
		r = ERROR ;
	}
	else
	{
		r = ERROR ;
	}

	return( r ) ;
}



/*
**  bchoctl -  trap 13, func 0x0d
**	character output control
*/

LONG	bchoctl( h , len , buffer )
	WORD	h ; 		/*  device handle			*/
	WORD	len ;		/*  len of ctrl string			*/
	BYTE	*buffer ;	/*  ptr to ctrl string			*/
{
	/*  for now, just return error  */

	return( ERROR ) ;
}



/*
**  bblictl -
**	block device input control [1]
*/

LONG	bblictl( d , len , buffer )
	WORD	d ;		/*  drive number			*/
	WORD	len ;		/*  len of ctrl string			*/
	BYTE	*buffer ;	/*  ptr to ctrl string			*/
{
	LONG	r ;

	if( d == DRVC )
		r = ERROR ;	/*  not supported on hard disk		*/
	else
	{
		if( len == 0 )
		{	
			r = E_OK ;	/*  yes, we support ioctl	*/
		}
		else
		{
			r = 0 ;		/*  we don't return any strings	*/
		}
	}

	return( r ) ;
}

/* 
** [1]	hard disk, error for input (and output)			
**	for floppy, we support format thru ioctl			
*/




/*
**  bbloctl -
**	block device output control strings
*/

LONG	bbloctl( d , len , buffer )
	WORD	d ;		/*  drive number			*/
	WORD	len ;		/*  length of io ctrl string		*/
	BYTE	*buffer ;	/*  ptr to ctrl string			*/
{
	LONG	r ;
	int	i ;

	if( d == DRVC )
		r = ERROR ;
	else
	{
		if( len != 1  ||  *buffer != IOCFMT )
			r = ERROR ;
		else 
			r = ffmt( d ) ;		/*  call format rtn	*/
	}

	return( r ) ;
}



/*
**  bchsvec -
**	character set vector routine
*/

LONG	bchsvec( h , newrtn )
	WORD	h ;		/*  device handle			*/
	PFI	newrtn ;	/*  ptr to new intr routine		*/
{
	switch( h )
	{
		case BFHAUX:	return(  setvec( newrtn ) ) ;
		case BFHCLK:	return(  clksvec( newrtn ) ) ;
		case BFHMOU:	return(  mousvec( newrtn ) ) ;
		case BFHPRN:	
		case BFHCON:	
		default:
				return( ERROR ) ;
	}
}

