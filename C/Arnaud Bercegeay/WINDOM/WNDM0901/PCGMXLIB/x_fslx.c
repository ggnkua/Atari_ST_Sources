/*
 * Aes file selection library interface (MagiC only)
 *
 */

#include <aes.h>
#include <vdi.h>
#include "pcgemx.h"

int fslx_close(void *fsd)
{
	aespb.addrin[0] = (long)fsd;
	aespb.contrl[0] = 191;
	aespb.contrl[1] = 0;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 1;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

void *fslx_do(char *title, char *path, int pathlen, char *fname, int fnamelen, 
					char *patterns, XFSL_FILTER filter, char *paths, int *sort_mode, 
					int flags, int *button, int *nfiles, char **pattern)
{
	aespb.intin[0] = pathlen;
	aespb.intin[1] = fnamelen;
	aespb.intin[2] = *sort_mode;
	aespb.intin[3] = flags;
	aespb.addrin[0] = (long)title;
	aespb.addrin[1] = (long)path;
	aespb.addrin[2] = (long)fname;
	aespb.addrin[3] = (long)patterns;
	aespb.addrin[4] = (long)filter;
	aespb.addrin[5] = (long)paths;
	aespb.contrl[0] = 194;
	aespb.contrl[1] = 4;
	aespb.contrl[2] = 4;
	aespb.contrl[3] = 6;
	aespb.contrl[4] = 2;
	aes( &aespb);
	*button = aespb.intout[1];
	*nfiles = aespb.intout[2];
	*sort_mode = aespb.intout[3];
	*pattern = (char *)aespb.addrout[1];
	return (void *)aespb.addrout[0];
}

int fslx_evnt(void *fsd, EVNT *events, char *path, char *fname, int *button, 
				  int *nfiles, int *sort_mode, char **pattern)
{
	aespb.addrin[0] = (long)fsd;
	aespb.addrin[1] = (long)events;
	aespb.addrin[2] = (long)path;
	aespb.addrin[3] = (long)fname;
	aespb.contrl[0] = 193;
	aespb.contrl[1] = 0;
	aespb.contrl[2] = 4;
	aespb.contrl[3] = 4;
	aespb.contrl[4] = 1;
	aes( &aespb);
	*button = aespb.intout[1];
	*nfiles = aespb.intout[2];
	*sort_mode = aespb.intout[3];
	*pattern = (char *)aespb.addrout[0];
	return aespb.intout[0];
}

int fslx_getnxtfile(void *fsd, char *fname)
{
	aespb.addrin[0] = (long)fsd;
	aespb.addrin[1] = (long)fname;
	aespb.contrl[0] = 192;
	aespb.contrl[1] = 0;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 2;
	aespb.contrl[4] = 0;
	aes( &aespb);
	return aespb.intout[0];
}

void *fslx_open(char *title, int x, int y, int *handle, char *path, int pathlen,
					 char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, 
					 char *paths, int sort_mode, int flags)
{
	aespb.intin[0] = x;
	aespb.intin[1] = y;
	aespb.intin[2] = pathlen;
	aespb.intin[3] = fnamelen;
	aespb.intin[4] = sort_mode;
	aespb.intin[5] = flags;
	aespb.addrin[0] = (long)title;
	aespb.addrin[1] = (long)path;
	aespb.addrin[2] = (long)fname;
	aespb.addrin[3] = (long)patterns;
	aespb.addrin[4] = (long)filter;
	aespb.addrin[5] = (long)paths;
	aespb.contrl[0] = 190;
	aespb.contrl[1] = 6;
	aespb.contrl[2] = 1;
	aespb.contrl[3] = 6;
	aespb.contrl[4] = 1;
	aes( &aespb);
	*handle = aespb.intout[0];
	return (void *)aespb.addrout[0];
}

int fslx_set_flags(int flags, int *oldval)
{
	aespb.intin[0] = 0;
	aespb.intin[1] = flags;
	aespb.contrl[0] = 195;
	aespb.contrl[1] = 2;
	aespb.contrl[2] = 2;
	aespb.contrl[3] = 0;
	aespb.contrl[4] = 0;
	aes( &aespb);
	*oldval = aespb.intout[1];
	return aespb.intout[0];
}
