/*
 * Aes file selection library interface (MagiC only)
 * modified: ol -- olivier.landemarre.free.fr
 *
 */
#include "mgemx.h"


int mt_fslx_close(void *fsd, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={191,0,1,1,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes_addrin[0] = (long)fsd;

	aes(&aes_params);

	return aes_intout[0];
}

int fslx_close(void *fsd)
{
	return(mt_fslx_close(fsd, aes_global));
}

void *mt_fslx_do(char *title, char *path, int pathlen, char *fname, int fnamelen, 
					char *patterns, XFSL_FILTER filter, char *paths, INT16 *sort_mode, 
					int flags, INT16 *button, INT16 *nfiles, char **pattern, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={194,4,4,6,2};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

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

	aes(&aes_params);

	*button = aes_intout[1];
	*nfiles = aes_intout[2];
	*sort_mode = aes_intout[3];
	*pattern = (char *)aes_addrout[1];
	return (void *)aes_addrout[0];
}

void *fslx_do(char *title, char *path, int pathlen, char *fname, int fnamelen, 
					char *patterns, XFSL_FILTER filter, char *paths, INT16 *sort_mode, 
					int flags, INT16 *button, INT16 *nfiles, char **pattern)
{
	return(mt_fslx_do(title, path, pathlen, fname, fnamelen, patterns, filter, paths, sort_mode, flags, button, nfiles, pattern, aes_global));
}

int mt_fslx_evnt(void *fsd, EVNT *events, char *path, char *fname, INT16 *button, 
				  INT16 *nfiles, INT16 *sort_mode, char **pattern, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={193,0,4,4,1};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes_addrin[0] = (long)fsd;
	aes_addrin[1] = (long)events;
	aes_addrin[2] = (long)path;
	aes_addrin[3] = (long)fname;

	aes(&aes_params);

	*button = aes_intout[1];
	*nfiles = aes_intout[2];
	*sort_mode = aes_intout[3];
	*pattern = (char *)aes_addrout[0];
	return aes_intout[0];
}

int fslx_evnt(void *fsd, EVNT *events, char *path, char *fname, INT16 *button, 
				  INT16 *nfiles, INT16 *sort_mode, char **pattern)
{
	return(mt_fslx_evnt(fsd, events, path, fname, button,nfiles, sort_mode, pattern, aes_global));
}


int mt_fslx_getnxtfile(void *fsd, char *fname, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={192,0,1,2,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes_addrin[0] = (long)fsd;
	aes_addrin[1] = (long)fname;

	aes(&aes_params);

	return aes_intout[0];
}

int fslx_getnxtfile(void *fsd, char *fname)
{
	return(mt_fslx_getnxtfile(fsd, fname, aes_global));
}

void *mt_fslx_open(char *title, int x, int y, INT16 *handle, char *path, int pathlen,
					 char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, 
					 char *paths, int sort_mode, int flags, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={190,6,1,6,1};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

                    
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

	aes(&aes_params);

	*handle = aes_intout[0];
	return (void *)aes_addrout[0];
}

void *fslx_open(char *title, int x, int y, INT16 *handle, char *path, int pathlen,
					 char *fname, int fnamelen, char *patterns, XFSL_FILTER filter, 
					 char *paths, int sort_mode, int flags)
{
	return(mt_fslx_open(title, x, y, handle, path, pathlen, fname, fnamelen, patterns, filter, paths, sort_mode, flags, aes_global));
}

int mt_fslx_set_flags(int flags, INT16 *oldval, INT16 *global_aes)
{
	static INT16 	aes_control[AES_CTRLMAX]={195,2,2,0,0};
	INT16	aes_intin[AES_INTINMAX],
			aes_intout[AES_INTOUTMAX];
	long	aes_addrin[AES_ADDRINMAX],
			aes_addrout[AES_ADDROUTMAX];
   
	AESPB aes_params;
  	aes_params.control = &aes_control[0];   /* AES Control Array             */
  	aes_params.global  = &global_aes[0];    /* AES Global Array              */
  	aes_params.intin   = &aes_intin[0];     /* input integer array           */
  	aes_params.intout  = &aes_intout[0];    /* output integer array          */
  	aes_params.addrin  = &aes_addrin[0];    /* input address array           */
  	aes_params.addrout = &aes_addrout[0];   /* output address array          */

	aes_intin[0] = 0;
	aes_intin[1] = flags;

	aes(&aes_params);

	*oldval = aes_intout[1];
	return aes_intout[0];
}

int fslx_set_flags(int flags, INT16 *oldval)
{
	return(mt_fslx_set_flags(flags, oldval, aes_global));
}
