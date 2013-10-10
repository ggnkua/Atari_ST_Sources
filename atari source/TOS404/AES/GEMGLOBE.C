/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemglobe.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:23:20 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemglobe.c,v $
* Revision 2.2  89/04/26  18:23:20  mui
* TT
* 
* Revision 2.1  89/02/22  05:26:46  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:33:58  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMGLOBE.C 	4/23/84 - 01/29/85	Lee Lorenzen		*/
/*	to 68k		4/08/85			Lowell Webster		*/
/*	Update		1/15/88			D.Mui			*/


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
#include <obdefs.h>
#include <gemusa.h>
#include <gemlib.h>

GLOBAL THEGLO		D;

/*
*	return size in words of struct THEGLO
*/

	WORD
size_theglo()
{
	return( sizeof(THEGLO)/2 );
}
