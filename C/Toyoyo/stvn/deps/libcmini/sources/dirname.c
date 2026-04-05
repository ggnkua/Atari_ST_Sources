/*  dirname.c -- MiNTLib.
    Copyright (C) 1999 Guido Flohr <guido@freemint.de>

    This file is part of the MiNTLib project, and may only be used
    modified and distributed under the terms of the MiNTLib project
    license, COPYMINT.  By continuing to use, modify, or distribute
    this file you indicate that you have read the license and
    understand and accept it fully.
*/

#include <string.h>
#include "ctype.h"
#include "lib.h"


char* dirname(char *path)
{
	static char here[] = ".";

	if (path == NULL)
	{
		path = here;  /* Yes, this is stupid.  See below!  */
	} else if (path[1] == ':' && path[2] == '\0' && (isupper(path[0]) || islower(path[0]) || isdigit(path[0])))
	{
		/* A drive letter followed by a colon.  */
	} else
	{
		char *last_slash, *slash, *backslash;

		slash = strrchr(path, '/');
		backslash = strrchr(path, '\\');

		if (slash > backslash)
			last_slash = slash;
		else if (backslash != NULL)
			last_slash = backslash;
		else
			last_slash = NULL;

		/* End of Atari-specifific kludges.  The rest is more or less taken
		   unchanged from the GNU libc.  */
		if (last_slash == path)
		{
			/* The last slash is the first character in the string.  We have to
			   return "/".  */
			++last_slash;
		} else if (last_slash != NULL && last_slash[1] == '\0')
		{
			/* Determine whether all remaining characters are slashes.  */
			char *runp;
			
			for (runp = last_slash; runp != path; --runp)
				if (runp[-1] != '/' && runp[-1] != '\\')
					break;
	
			if (runp != path)
			{
				/* The '/' or '\\' is the last character, we have to look further.  */
				slash = memrchr(path, '/', runp - path);
				backslash = memrchr(path, '\\', runp - path);
				if (slash == NULL || backslash > slash)
					slash = backslash;
				last_slash = slash;
			}
		}

		if (last_slash != NULL)
		{
			/* Determine whether all remaining characters are slashes.  */
			char *runp;

			for (runp = last_slash; runp != path; --runp)
				if (runp[-1] != '/' && runp[-1] != '\\')
					break;

			/* Terminate the path.  */
			if (runp == path)
			{
				/* The last slash is the first character in the string.  We have to
				   return "/".  As a special case we have to return "//" if there
				   are exactly two slashes at the beginning of the string.  See
				   XBD 4.10 Path Name Resolution for more information.  */
				if (last_slash == path + 1 && path[0] == path[1])
					++last_slash;
				else
					last_slash = path + 1;
			} else
			{
				last_slash = runp;
			}

			last_slash[0] = '\0';
		} else
		{
			/* This assignment is ill-designed but the XPG specs require to
			   return a string containing "." in any case no directory part is
			   found and so a static and constant string is required.  */
			path = here;
		}
	}

	return path;
}
