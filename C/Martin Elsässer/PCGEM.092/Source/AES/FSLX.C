/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - FSLX-Bibliothek													*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

#include <ACSAES.H>
#include <String.H>

/******************************************************************************/
/*																										*/
/* Lokale Konstanten																				*/
/*																										*/
/******************************************************************************/

/* Anzahl der Byte des contrl-Arrays */
#define CTRL_BYTES	5

/******************************************************************************/

/* öbertragen des contrl-Arrays */
#ifndef __USE_MEMCPY__
	#if CTRL_BYTES==4
		#define CTRLCPY(dest, src)	{((int32 *)dest)[0] = ((int32 *)src)[0];((int32 *)dest)[1] = ((int32 *)src)[1];}
	#elif CTRL_BYTES==5
		#define CTRLCPY(dest, src)	{((int32 *)dest)[0] = ((int32 *)src)[0];((int32 *)dest)[1] = ((int32 *)src)[1];((int16 *)dest)[4] = ((int16 *)src)[4];}
	#elif CTRL_BYTES==6
		#define CTRLCPY(dest, src)	{((int32 *)dest)[0] = ((int32 *)src)[0];((int32 *)dest)[1] = ((int32 *)src)[1];((int32 *)dest)[3] = ((int32 *)src)[3];}
	#else
		#define CTRLCPY(dest, src)	memcpy(dest, src, CTRL_BYTES*sizeof(int16))
	#endif
#else
	#define CTRLCPY(dest, src)	memcpy(dest, src, CTRL_BYTES*sizeof(int16))
#endif

/******************************************************************************/
/*																										*/
/* Lokale Datentypen																				*/
/*																										*/
/******************************************************************************/

typedef struct
{
	int16 contrl[5];
	GlobalArray *globl;
	int16 intin[17];
	int16 intout[7];
	void *addrin[7];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 190:	fslx_open																			*/
/*																										*/
/******************************************************************************/

void *mt_fslx_open( char *title, const int16 x, const int16 y, int16 *handle, char *path,
				const int16 pathlen, char *fname, const int16 fnamelen, char *patterns,
				XFSL_FILTER *filter, char *paths, const int16 sort_mode, const int16 flags,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {190, 6, 1, 6, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
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

int16 mt_fslx_close( void *fsd, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {191, 0, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
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

int16 mt_fslx_getnxtfile( void *fsd, char *fname, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {192, 0, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
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

int16 mt_fslx_evnt( void *fsd, EVNT *events, char *path, char *fname, int16 *button,
				int16 *nfiles, int16 *sort_mode, char **pattern, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {193, 0, 4, 4, 1};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
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

void *mt_fslx_do( char *title, char *path, const int16 pathlen, char *fname,
				const int16 fnamelen, char *patterns, XFSL_FILTER *filter, char *paths,
				int16 *sort_mode, const int16 flags, int16 *button, int16 *nfiles,
				char **pattern, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {194, 4, 4, 6, 2};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = pathlen;
	data.intin[1] = fnamelen;
	data.intin[2] = *sort_mode;
	data.intin[3] = flags;
	
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
	if( pattern!=NULL )
		*pattern = data.addrout[1];
	
	return data.addrout[0];
}

/******************************************************************************/
/*																										*/
/* AES 194:	fslx_set_flags																		*/
/*																										*/
/******************************************************************************/

int16 mt_fslx_set_flags( const int16 flags, int16 *oldval, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {195, 2, 2, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Die Arrays anlegen */
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = 0;
	data.intin[1] = flags;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	if( oldval!=NULL )
		*oldval = data.intout[1];
	
	return data.intout[0];
}
