/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - FSLX-Bibliothek													*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	#include <AES.H>
#else
	#include <ACSAES.H>
#endif
#include <String.H>

/******************************************************************************/
/*																										*/
/* Lokale Datentypen																				*/
/*																										*/
/******************************************************************************/

typedef struct
{
	INT16 contrl[5];
	GLOBAL *globl;
	INT16 intin[17];
	INT16 intout[7];
	void *addrin[7];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 190:	fslx_open																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void *fslx_open( char *title, INT16 x, INT16 y, INT16 *handle, char *path, INT16 pathlen,
					char *fname, INT16 fnamelen, char *patterns, XFSL_FILTER *filter, char *paths,
					INT16 sort_mode, INT16 flags)
#else
	void *fslx_open( GLOBAL *globl, char *title, INT16 x, INT16 y, INT16 *handle, char *path,
					INT16 pathlen, char *fname, INT16 fnamelen, char *patterns,
					XFSL_FILTER *filter, char *paths, INT16 sort_mode, INT16 flags)
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{190, 6, 1, 6, 1}};
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0] = x;
	data.intin[1] = y;
	data.intin[2] = pathlen;
	data.intin[3] = fnamelen;
	data.intin[4] = sort_mode;
	data.intin[5] = flags;
	
	data.addrin[0] = title;
	data.addrin[1] = path;
	data.addrin[2] = fname;
	data.addrin[3] = patterns;
	data.addrin[4] = filter;
	data.addrin[5] = paths;

	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);

	if( handle!=NULL )
		*handle = data.intout[0];
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 191:	fslx_close																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fslx_close( void *fsd )
#else
	INT16 fslx_close( GLOBAL *globl, void *fsd )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{191, 0, 1, 1, 0}};
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0] = fsd;

	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);

	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 192:	fslx_getnxtfile																	*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fslx_getnxtfile( void *fsd, char *fname )
#else
	INT16 fslx_getnxtfile( GLOBAL *globl, void *fsd, char *fname )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{192, 0, 1, 2, 0}};
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0] = fsd;
	data.addrin[1] = fname;

	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);

	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 194:	fslx_evnt																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fslx_evnt( void *fsd, EVNT *events, char *path, char *fname, INT16 *button,
				INT16 *nfiles, INT16 *sort_mode, char **pattern )
#else
	INT16 fslx_evnt( GLOBAL *globl, void *fsd, EVNT *events, char *path, char *fname,
				INT16 *button, INT16 *nfiles, INT16 *sort_mode, char **pattern )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{193, 0, 4, 4, 1}};
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0] = fsd;
	data.addrin[1] = events;
	data.addrin[2] = path;
	data.addrin[3] = fname;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	if( button!=NULL )
		*button = data.intout[1];
	if( nfiles!=NULL )
		*nfiles = data.intout[2];
	if( sort_mode!=NULL )
		*sort_mode = data.intout[3];
	if( pattern!=NULL )
		*pattern = data.addrout[0];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 194:	fslx_do																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	void *fslx_do( char *title, char *path, INT16 pathlen, char *fname, INT16 fnamelen,
					char *patterns, XFSL_FILTER *filter, char *paths, INT16 *sort_mode,
					INT16 flags, INT16 *button, INT16 *nfiles, char **pattern )
#else
	void *fslx_do( GLOBAL *globl, char *title, char *path, INT16 pathlen, char *fname,
					INT16 fnamelen, char *patterns, XFSL_FILTER *filter, char *paths,
					INT16 *sort_mode, INT16 flags, INT16 *button, INT16 *nfiles, char **pattern )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{194, 4, 4, 6, 2}};
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=pathlen;
	data.intin[1]=fnamelen;
	data.intin[2]=*sort_mode;
	data.intin[3]=flags;
	
	data.addrin[0] = title;
	data.addrin[1] = path;
	data.addrin[2] = fname;
	data.addrin[3] = patterns;
	data.addrin[4] = filter;
	data.addrin[5] = paths;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	if( button!=NULL )
		*button = data.intout[1];
	if( nfiles!=NULL )
		*nfiles = data.intout[2];
	if( sort_mode!=NULL )
		*sort_mode = data.intout[3];

	*pattern = data.addrout[1];
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 194:	fslx_set_flags																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fslx_set_flags( INT16 flags, INT16 *oldval )
#else
	INT16 fslx_set_flags( GLOBAL *globl, INT16 flags, INT16 *oldval )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{195, 2, 2, 0, 0}};
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=0;
	data.intin[1]=flags;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	if( oldval!=NULL )
		*oldval = data.intout[1];
	
	return data.intout[0];
}
