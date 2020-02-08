/* xbra.c	/	25.8.91	/	MATRIX	/	WA	*/

# include <stdio.h>

# include <string.h>
# include <tos.h>

# include "global.h"
# include "traps.h"

# include "xbra.h"

#define XBRA "XBRA"

/*--------------------------------------------------- link_axbra ----*/
void link_axbra ( XBRAstruct *xbra, PROC **pexcserv, char *ids )
{
	strncpy ( &xbra->magic[0], XBRA, 4 ) ;
	xbra->oldvec = (PROC *)get_lcont ( (long *)pexcserv ) ;
	strncpy ( xbra->id, ids, 4 ) ;
	put_lcont ( (long *)pexcserv, (long)(xbra + 1) ) ;
}

/*--------------------------------------------------- link_xbra ----*/
void link_xbra ( XBRAstruct *xbra, int number, char *ids )
{
	strncpy ( &xbra->magic[0], XBRA, 4 ) ;
	xbra->oldvec = Setexc ( number, (void (*)())-1L ) ;
	strncpy ( xbra->id, ids, 4 ) ;
	Setexc ( number, (PROC *)(xbra + 1) ) ;
}

PROC **vbr = (PROC **) 0x0 ;

/*------------------------------------------------ get_vector_base -*/
long get_vector_base ( void )
{
	vbr = get_excv_base() ;
	return ( 0 ) ;
}


/*------------------------------------------------- print_xbra ----*/
void print_xbra ( char *deli, XBRAstruct *xbra )
{
	printf ( "%s$%8.8lx : %-4.4s $%8.8lx",
				deli, xbra, xbra->id, xbra->oldvec ) ;
}

/*------------------------------------------------- list_xbra ----*/
void list_xbra ( int number, bool priall )
{
	PROC **excserv ;
	XBRAstruct *xbra ;
	bool head_printed ;
	bool some_output ;
	
	Supexec ( get_vector_base ) ;
	excserv = &vbr[number] ;

	head_printed = FALSE ;
	some_output = FALSE ;

	if ( priall )
	{
		printf ( "%3d:$%2.2x:$%8.8lx ", number, number, excserv ) ;
		head_printed = TRUE ;
	}

	for(;;)
	{
		xbra = (XBRAstruct *)( get_lcont ( (long *)excserv ) ) ;
		if ( priall )
			printf ( " - $%8.8lx", xbra ) ;
		xbra-- ;
		if ( strncmp ( xbra->magic, XBRA, 4 ) != 0 )
		{
			if ( some_output )
				printf ( "\n" ) ;
			return ;
		}

		some_output = TRUE ;
		if ( ! head_printed )
		{
			printf ( "%3d:$%2.2x:$%8.8lx ", number, number, excserv ) ;
			head_printed = TRUE ;
		}

		print_xbra ( ", ", xbra ) ;

		excserv = &xbra->oldvec ;
	}
}

/*------------------------------------------------- find_pxbra ----*/
PROC **find_paxbra ( PROC **pexcserv, char *ids )
{
	XBRAstruct *xbra ;

	for(;;)
	{
		xbra = (XBRAstruct *)( get_lcont ( (long *)pexcserv ) ) - 1 ;
		if ( strncmp ( xbra->magic, XBRA, 4 ) != 0 )
			return ( NULL ) ;
		if ( strncmp ( xbra->id, ids, 4 ) == 0 )
			return ( pexcserv ) ;
		pexcserv = &xbra->oldvec ;
	}
}


/*------------------------------------------------- find_pxbra ----*/
PROC **find_pxbra ( int number, char *ids )
{
	Supexec ( get_vector_base ) ;
	return ( find_paxbra ( &vbr[number], ids ) ) ;
}


/*------------------------------------------------- unlink_xbra ----*/
bool unlink_xbra ( int number, char *ids )
{
	PROC **found_xbra ;
	XBRAstruct *xbra ;

	found_xbra = find_pxbra ( number, ids ) ;

	if ( found_xbra != NULL )
	{
		xbra = (XBRAstruct *)( get_lcont ( (long *)found_xbra ) ) - 1 ;
		put_lcont ( (long *)found_xbra, (long)xbra->oldvec ) ;
		return ( TRUE ) ;
	}
	else
	{
		printf ( " - xbra structure '%s' in vector list %d not found\n",
						ids, number ) ;
		return ( FALSE ) ;
	}
}
