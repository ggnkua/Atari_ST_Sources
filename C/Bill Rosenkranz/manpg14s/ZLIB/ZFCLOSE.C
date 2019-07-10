#include "zdef.h"

/*------------------------------*/
/*	zfclose			*/
/*------------------------------*/
#ifndef __STDC__
void zfclose (z)
ZFILE *z;
#else
void zfclose (ZFILE *z)
#endif
{
	if (z == 0)
	        return;

	if (z->zeof)
	{
		if ((z->flags & ALLOCATED) != 0)
		{
#ifdef MSDOS
			hfree (z->tab_suffixof);
			hfree (z->tab_prefixof);
#else
			free (z->tab_suffixof);
			free (z->tab_prefixof);
#endif
			z->flags &= (~ALLOCATED);
		}
	}
	free (z);
}



