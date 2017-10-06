/*
	@(#)iso-time.c

	Written by Julian F. Reschke and placed into the 
	public domain.
	
	Cookie routines written by Arnd Beissner.
	
	This program sets or changes the _IDT cookie to a value
	compliant to ISO 8601 (YY-MM-DD, 24 hour format).
*/

#include "cookie.h"
#include "tos.h"


/* Note that this program does NOT use the standard startup
   code. The function below needs to be the first one in the
   text segment */

void cdecl
main (BASPAG *bp)
{
	long len;				/* Programml„nge */
	int success;
	int resident = 1;
	long dummy;

	/* calculate size of TPA */
	len = sizeof(BASPAG) + bp->p_tlen + bp->p_dlen + bp->p_blen;
	Mshrink (0, bp, len);

	/* print banner */
	Cconws ("\r\n\033p ISO-TIME 1.00        1997-12-31 \033q\r\n"
			" Copyright (c) Julian F. Reschke\r\n\r\n");

	/* cookie lib needs supervisor mode */
	Super (0);

	/* find out whether we need to terminate and stay resident
	   (cookie jar created or resized */
	   
	if (CK_JarInstalled ())
	{
		if (CK_ReadJar ('_IDT', &dummy))
			resident = 0;
		if (CK_JarSize () - CK_UsedEntries () > 0)
			resident = 0;
	}
	
	/* set the cookie */
	success = CK_WriteJar ('_IDT', '\x00\x00\x12-');

	/* report what happened */
	if (success)
		Cconws ("_IDT cookie set to YY-MM-DD 24 hour format.\r\n");
	else
		Cconws ("Unable to set _IDT cookie.\r\n");
	
	/* and terminate */
	if (resident)
		Ptermres (len, success ? 0 : 1);
	else
		Pterm (success ? 0 : 1);
}

/* Set SCCS id suitable for 'what' command */

char *
sccsid (void)
{
	return "@(#)iso-time.prg, Copyright (c) Julian F. Reschke, "__DATE__;
}


