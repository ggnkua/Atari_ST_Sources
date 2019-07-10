/* Changes should be made in Makefile, not to this file! */

/***************************************************************************
 * This program is Copyright (C) 1986, 1987, 1988 by Jonathan Payne.  JOVE *
 * is provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is    *
 * included in all the files.                                              *
 ***************************************************************************/

#include "jove.h"

char	*d_tempfile = "joveXXXXXX",	/* buffer lines go here */
	*p_tempfile = "jrecXXXXXX",	/* line pointers go here */
	*Recover = "c://jove//lib/recover",
	*CmdDb = "c://jove//lib/cmds.doc",
		/* copy of "cmds.doc" lives in the doc subdirectory */

	*Joverc = "c://jove//lib/jove.rc",

#if defined(IPROCS) && defined(PIPEPROCS)
	*Portsrv = "c://jove//lib/portsrv",
	*Kbd_Proc = "c://jove//lib/kbd",
#endif

/* these are variables that can be set with the set command, so they are
   allocated more memory than they actually need for the defaults */

	TmpFilePath[FILESIZE] = "d://tmp",
	Shell[FILESIZE] = "c://ash.ttp",
	ShFlags[16] = "-c";
