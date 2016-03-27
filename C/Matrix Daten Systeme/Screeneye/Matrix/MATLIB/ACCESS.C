/********************************************************************/
/* 				Bus error access checking							*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 07.11.91												*/
/*																	*/
/*  WA - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*																	*/
/********************************************************************/

# include <stdio.h>
# include "global.h"
# include "traps.h"
# include "access.h"

# define TEST 1
# if TEST
extern int verbose ;
# define ttprintf if ( verbose ) printf
# endif

/*--------------------------------------- access_check ---------*/
int access_check ( void *address, int dir, int wrdata )
{
	int result ;
	
# if TEST > 1		
	ttprintf ( "+ acc_check, dir = %d\n", dir ) ;
# endif
	inst_buserr();

# if TEST > 1		
	ttprintf ( "= access $%8.8lx", address ) ;
# endif
	result = 0 ;

	if ( dir & RD )
	{
# if TEST > 1		
		ttprintf ( ", read" ) ;
# endif
		berr_flag = FALSE ;
# if 0
		if(*(byte *)address) ;	/* access address only	*/
# else
		rd_byte ( address ) ;
# endif
		if ( ! berr_flag )
			result = RD ;
# if TEST > 1	
		else
			ttprintf ( ":BAD\n" ) ;
# endif
	}
	
	if ( dir & WR )
	{
# if TEST > 1		
		ttprintf ( ", write" ) ;
# endif
		berr_flag = FALSE ;
# if 0
		*(byte *)address = wrdata ;
# else
		wr_byte ( address, wrdata ) ;
# endif
		if ( ! berr_flag )
			result |= WR ;
# if TEST > 1	
		else
			ttprintf ( ":BAD\n" ) ;
# endif
	}
	
	remove_buserr();
	
# if TEST > 1		
	ttprintf ( "- acc_check : req = %d, ok = %d\n", dir, result ) ;
# endif
	return ( result ) ;
} /*- acc_check -*/


/*---------------------------------------- rd_acc_check -----------*/
bool rd_acc_check (void *address)
{
	return ( access_check (address, RD, 0) == RD ) ;
} /*- rd_acc_check -*/


/*---------------------------------------- wr_acc_check -----------*/
bool wr_acc_check (void *address, int wrdata)
{
	return ( access_check (address, WR, wrdata ) == WR ) ;
} /*- wr_acc_check -*/

