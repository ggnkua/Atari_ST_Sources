/*	GEMSCLIB.C	07/10/84 - 02/02/85	Lee Lorenzen		*/
/*	to 68k		03/08/85		Lowell Webster		*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*
*	02/12/93	cjg	Convert to Lattice C 5.51
*	02/23/93	cjg	Force the use of prototypes
*/

#include "pgem.h"
#include "pmisc.h"

#include "machine.h"


EXTERN THEGLO		D;


	VOID
sc_read(pscrap)
	LONG		pscrap;
{
	LSTCPY( ( BYTE *)pscrap, ( BYTE *)&D.g_scrap[0]);
}


	VOID
sc_write(pscrap)
	LONG		pscrap;
{
	LSTCPY( ( BYTE *)&D.g_scrap[0], ( BYTE *)pscrap);
}

