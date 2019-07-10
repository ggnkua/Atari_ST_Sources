#include "zdef.h"

/*------------------------------*/
/*	zfeof			*/
/*------------------------------*/
#ifndef __STDC__
int zfeof (z)
ZFILE *z;
#else
int zfeof (ZFILE *z)
#endif
{
	if ((z->flags & NOT_COMPRESSED) != 0)
	{
		if      (z->c1 != EOF)
		{
			        return ((int) (0 != 0));
		}
		return ((int) feof (z->file));
	}
	return ((int) (z->zeof));
}



