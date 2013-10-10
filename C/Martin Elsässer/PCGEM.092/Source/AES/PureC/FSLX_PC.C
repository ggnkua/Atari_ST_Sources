/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - FSLX-Bibliothek kompatibel zu PureC							*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

/* Wir brauchen die KompatibilitÑts-Funktionen, keine Makro-Definitionen! */
#define __COMPATIBLE_FKT__

/******************************************************************************/

#include <AES.H>
#include <String.H>

/******************************************************************************/
/*																										*/
/* AES 190:	fslx_open																			*/
/*																										*/
/******************************************************************************/

void *fslx_open( char *title, const int16 x, const int16 y, int16 *handle, char *path,
				const int16 pathlen, char *fname, const int16 fnamelen, char *patterns,
				XFSL_FILTER *filter, char *paths, const int16 sort_mode, const int16 flags )
{
	return mt_fslx_open(title, x, y, handle, path, pathlen, fname, fnamelen, patterns,
				filter, paths, sort_mode, flags, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 191:	fslx_close																			*/
/*																										*/
/******************************************************************************/

int16 fslx_close( void *fsd )
{
	return mt_fslx_close(fsd, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 192:	fslx_getnxtfile																	*/
/*																										*/
/******************************************************************************/

int16 fslx_getnxtfile( void *fsd, char *fname )
{
	return mt_fslx_getnxtfile(fsd, fname, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 194:	fslx_evnt																			*/
/*																										*/
/******************************************************************************/

int16 fslx_evnt( void *fsd, EVNT *events, char *path, char *fname, int16 *button,
				int16 *nfiles, int16 *sort_mode, char **pattern )
{
	return mt_fslx_evnt(fsd, events, path, fname, button, nfiles, sort_mode, pattern, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 194:	fslx_do																				*/
/*																										*/
/******************************************************************************/

void *fslx_do( char *title, char *path, const int16 pathlen, char *fname,
				const int16 fnamelen, char *patterns, XFSL_FILTER *filter, char *paths,
				int16 *sort_mode, const int16 flags, int16 *button, int16 *nfiles,
				char **pattern )

{
	return mt_fslx_do(title, path, pathlen, fname, fnamelen, patterns, filter, paths,
					sort_mode, flags, button, nfiles, pattern, _globl);

}

/******************************************************************************/
/*																										*/
/* AES 194:	fslx_set_flags																		*/
/*																										*/
/******************************************************************************/

int16 fslx_set_flags( const int16 flags, int16 *oldval )
{
	return mt_fslx_set_flags(flags, oldval, _globl);
}
