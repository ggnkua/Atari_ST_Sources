/*     DESKBOTH.C				03/18/93 C.Gee		*/
/*     Started separation of Desktop and AES	03/18/93 C.Gee		*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pgem.h"
#include "pmisc.h"
#include "pboth.h"

#include "machine.h"
#include "vdidefs.h"
#include "mintbind.h"



MLOCAL WORD	restable[] = { 0,2,5,7,3,4,6,8,9,-1 };
MLOCAL WORD	restype[]  = { 0,1,1,1,2,3,4,5,6,-1 };



/*	Change from res type to real device handle	*/

	WORD
res_handle( in )
	WORD	in;
{
	WORD	i;

	i = 0;
	while( TRUE )
	{
	  if ( restype[i] == in )
	    return( restable[i] );	
	  if ( restype[i] == -1 )
	    return( 0 );
	  i++;
	}
}


/*	Change from device handle to res type	*/

	WORD
res_type( in )
	WORD	in;
{
	WORD	i;

	i = 0;
	while( TRUE )
	{
	  if ( restable[i] == in )
	    return( restype[i] );	
	  if ( restable[i] == -1 )
	    return( 0 );
	  i++;
	}
}




/*	Do nothing rouine	*/

	VOID
donothing( VOID )
{

}





/*	Catch the signal and do nothing */

	VOID
catchsignal( ignore )
	WORD	ignore;
{
	WORD	i;

	for( i = 1; i < 31; i++ )
	{
	  if ( i != ignore )
	    Psignal( i, &donothing );
	}
}


