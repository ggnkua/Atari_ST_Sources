/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemsclib.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:26:50 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemsclib.c,v $
* Revision 2.2  89/04/26  18:26:50  mui
* TT
* 
* Revision 2.1  89/02/22  05:29:27  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:35:07  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMSCLIB.C	07/10/84 - 02/02/85	Lee Lorenzen		*/
/*	to 68k		03/08/85		Lowell Webster		*/

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <gemlib.h>

EXTERN THEGLO		D;


	WORD
sc_read(pscrap)
	LONG		pscrap;
{
	LSTCPY(pscrap, &D.g_scrap[0]);
}


	WORD
sc_write(pscrap)
	LONG		pscrap;
{
	LSTCPY( &D.g_scrap[0], pscrap);
}

