/*
 * Aes file selection library interface (MagiC only)
 *
 */
#include "gemx.h"


int fslx_close(void *fsd)
{
	aes_addrin[0] = (long)fsd;
	aes_control[0] = 191;
	aes_control[1] = 0;
	aes_control[2] = 1;
	aes_control[3] = 1;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

void *fslx_do(char *title, char *path, int pathlen, char *fname, int fnamelen, 
					char *patterns, XFSL_FILTER filter, char *paths, int *sort_mode, 
					int flags, int *button, int *nfiles, char **pattern)
{
	aes_intin[0] = pathlen;
	aes_intin[1] = fnamelen;
	aes_intin[2] = *sort_mode;
	aes_intin[3] = flags;
	aes_addrin[0] = (long)title;
	aes_addrin[1] = (long)path;
	aes_addrin[2] = (long)fname;
	aes_addrin[3] = (long)patterns;
	aes_addrin[4] = (long)filter;
	aes_addrin[5] = (long)paths;
	aes_control[0] = 194;
	aes_control[1] = 4;
	aes_control[2] = 4;
	aes_control[3] = 6;
	aes_control[4] = 2;
	aes(&aes_params);
	*button = aes_intout[1];
	*nfiles = aes_intout[2];
	*sort_mode = aes_intout[3];
	*pattern = (char *)aes_addrout[1];
	return (void *)aes_addrout[0];
}

int fslx_evnt(void *fsd, EVNT *events, char *path, char *fname, int *button, 
				  int *nfiles, int *sort_mode, char **pattern)
{
	aes_addrin[0] = (long)fsd;
	aes_addrin[1] = (long)events;
	aes_addrin[2] = (long)path;
	aes_addrin[3] = (long)fname;
	aes_control[0] = 193;
	aes_control[1] = 0;
	aes_control[2] = 4;
	aes_control[3] = 4;
	aes_control[4] = 1;
	aes(&aes_params);
	*button = aes_intout[1];
	*nfiles = aes_intout[2];
	*sort_mode = aes_intout[3];
	*pattern = (char *)aes_addrout[0];
	return aes_intout[0];
}

int fslx_getnxtfile(void *fsd, char *fname)
{
	aes_addrin[0] = (long)fsd;
	aes_addrin[1] = (long)fname;
	aes_control[0] = 192;
	aes_control[1] = 0;
	aes_control[2] = 1;
	aes_control[3] = 2;
	aes_control[4] = 0;
	aes(&aes_params);
	return aes_intout[0];
}

void *fslx_open(char *title, int x, int y, int *handle, char *path, int pathlen,
					 char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, 
					 char *paths, int sort_mode, int flags)
{
	aes_intin[0] = x;
	aes_intin[1] = y;
	aes_intin[2] = pathlen;
	aes_intin[3] = fnamelen;
	aes_intin[4] = sort_mode;
	aes_intin[5] = flags;
	aes_addrin[0] = (long)title;
	aes_addrin[1] = (long)path;
	aes_addrin[2] = (long)fname;
	aes_addrin[3] = (long)patterns;
	aes_addrin[4] = (long)filter;
	aes_addrin[5] = (long)paths;
	aes_control[0] = 190;
	aes_control[1] = 6;
	aes_control[2] = 1;
	aes_control[3] = 6;
	aes_control[4] = 1;
	aes(&aes_params);
	*handle = aes_intout[0];
	return (void *)aes_addrout[0];
}

int fslx_set_flags(int flags, int *oldval)
{
	aes_intin[0] = 0;
	aes_intin[1] = flags;
	aes_control[0] = 195;
	aes_control[1] = 2;
	aes_control[2] = 2;
	aes_control[3] = 0;
	aes_control[4] = 0;
	aes(&aes_params);
	*oldval = aes_intout[1];
	return aes_intout[0];
}
