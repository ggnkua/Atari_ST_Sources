/*
 * fsglob.c - global variables for the file system                
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors:
 *  xxx <xxx@xxx>
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



/*
 *  Mod #          who date             modification
 *  -------------- --- ---------        ------------
 *  M01.01.1023.02 scc 10/23/86         Changed the definition of time and date
 *                                      to unsigned int
 *
 */

#include        "portab.h"
#include        "fs.h"
#include        "bios.h"                /*  M01.01.01                   */
#include        "gemerror.h"



/*
 * Global Filesystem related variables
 */



/*
 *  drvtbl -
 */

DMD *drvtbl[32];



/*
 *  sft -
 */

FTAB sft[OPNFILES];



/*
 * rwerr -  hard error number currently in progress
 */

long rwerr; 
long errcode;



/*
 * errdrv -  drive on which error occurred
 */

short errdrv; 
jmp_buf errbuf;



/*
 * time - , date - who knows why this is here?
 */

unsigned short    time, date ;

