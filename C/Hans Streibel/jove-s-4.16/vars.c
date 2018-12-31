/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"
#include "extend.h"
#include "vars.h"

/* included for variable declarations */
#include "abbrev.h"
#include "ask.h"
#include "c.h"
#include "jctype.h"
#include "disp.h"
#include "insert.h"
/* #include "io.h" */
#include "sysprocs.h"	/* needed for iproc.h */
#include "iproc.h"
/* #include "jove.h" */
#include "mac.h"
#include "mouse.h"
#include "paragraph.h"
#include "proc.h"
#include "re.h"
#include "reapp.h"
#include "rec.h"
#include "screen.h"
#include "term.h"
#include "ttystate.h"
/* #include "util.h" */
#include "wind.h"


#define VAR(v)	(UnivPtr)(v), sizeof(v)
#include "vars.tab"

data_obj *
findvar(prompt)
const char	*prompt;
{
	static char	*strings[elemsof(variables)];
	static int	last = -1;

	if (strings[0] == NULL) {
		register char	**strs = strings;
		register const struct variable	*v = variables;

		for (; v->Name; v++)
			*strs++ = v->Name;
		*strs = NULL;
	}

	last = complete(strings, last >= 0? strings[last] : (char *)NULL,
		prompt, ALLOW_OLD);
	return (data_obj *) &variables[last];
}
