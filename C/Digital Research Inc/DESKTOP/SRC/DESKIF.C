/*	DESKIF.C	12/03/84 - 02/09/85	Lee Lorenzen		*/
/*	merge source	5/27/87			mdf			*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 2.3
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include <stddef.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#endif
#else
#include <obdefs.h>
#include <gembind.h>
#endif
#include "deskif.h"

VOID gsx_moff(VOID)
{
	graf_mouse(M_OFF, NULL);
}

VOID gsx_mon(VOID)
{
	graf_mouse(M_ON, NULL);
}

LONG obaddr(LONG tree, WORD obj, WORD fld_off)
{
	return( (tree + ((obj) * sizeof(OBJECT) + fld_off)) );
}
