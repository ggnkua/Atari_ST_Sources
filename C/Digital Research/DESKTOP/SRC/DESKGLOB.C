/*	DESKGLOB.C	06/11/84 - 06/09/85		Lee Lorenzen	*/
/*	merge source	5/27/87				mdf		*/

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
#include "deskapp.h"
#include "deskfpd.h"
#include "deskwin.h"
#include "deskbind.h"

/* this has been pulled out of GLOBES & moved here from DESKBIND.H */
GLOBAL ICONBLK		gl_icons[NUM_WOBS];

#if MC68K
GLOBAL GLOBES		G;  
#else
GLOBAL	WORD		G;
#endif
