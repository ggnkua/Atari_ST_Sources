/*	COMPICON.H	10/05/84 - 10/10/84 	Gregg Morris		*/
#include <stdio.h>
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <obdefs.h>
#endif

/* beg_file and end_file must be initialised. because */
/* they should be locates in the data segement like   */
/* the included icons and not in the bss like the     */
/* uninitialised variables. */
VOID *beg_file = NULL;

#include "iconlist.h"

VOID *end_file = NULL;

VOID main(VOID)
{
	WORD	length;
	FILE	*handle;

	beg_file = &gl_ilist;
	handle = fopen( "DESKTOP.IMG", "wb");
	length = (WORD)( ((BYTE *)&end_file) - ((BYTE *)&beg_file) );
	fwrite(ADDR(&beg_file+1), 1, (LONG)(length-2), handle);
	fclose(handle);
} /* compicon */
