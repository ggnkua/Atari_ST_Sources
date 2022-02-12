#include <lib.h>

PUBLIC int link(name, name2)
_CONST char *name, *name2;
{
  return(callm1(FS, LINK, len(name), len(name2), 0,
	 (char *) name, (char *) name2,	/* perhaps callm1 preserves these */
	 NIL_PTR));
}
