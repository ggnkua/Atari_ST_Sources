/****************************************************************
*
* Dieses Modul implementiert die erweiterten
* Dateiauswahlfunktionen von MagiC 4 fÅr Pure C
*
* Formatierung:	Tabulatorbreite 5
* Andreas Kromke
* 5.11.95
*
****************************************************************/

#include <portab.h>
#include <aes.h>
#include <wdial_g.h>
#include <tos.h>
#include "fslx_lib.h"

extern void _aes(int dummy, long code);


/*
*
* Dateiauswahlfenster îffnen
*
*/

void * fslx_open(
			char *title,
			WORD x, WORD y,
			WORD	*handle,
			char *path, WORD pathlen,
			char *fname, WORD fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			WORD sort_mode,
			WORD flags)
{
	WORD *intin = _GemParBlk.intin;
	void **addrin = _GemParBlk.addrin;

	*intin++ = x;
	*intin++ = y;
	*intin++ = pathlen;
	*intin++ = fnamelen;
	*intin++ = sort_mode;
	*intin = flags;

	*addrin++ = title;
	*addrin++ = path;
	*addrin++ = fname;
	*addrin++ = patterns;
	*addrin++ = filter;
	*addrin = paths;

	_aes(0, 0xbe060106L);

	*handle = _GemParBlk.intout[0];
	return(_GemParBlk.addrout[0]);
}


/*
*
* Dateiauswahl (Dialog oder Fenster) schlieûen
*
*/

WORD fslx_close( void *fsd )
{
	_GemParBlk.addrin[0] = fsd;

	_aes(0, 0xbf000101L);

	return(_GemParBlk.intout[0]);
}


/*
*
* ausgewÑhlte Dateinamen ermitteln
*
*/

WORD fslx_getnxtfile(
			void *fsd,
			char *fname
			)
{
	_GemParBlk.addrin[0] = fsd;
	_GemParBlk.addrin[1] = fname;

	_aes(0, 0xc0000102L);

	return(_GemParBlk.intout[0]);
}


/*
*
* Dateiauswahlfenster bedienen
*
*/

WORD fslx_evnt(
			void *fsd,
			EVNT *events,
			char *path,
			char *fname,
			WORD *button,
			WORD *nfiles,
			WORD *sort_mode,
			char **pattern )
{
	WORD *intout = _GemParBlk.intout;
	void **addrin = _GemParBlk.addrin;

	*addrin++ = fsd;
	*addrin++ = events;
	*addrin++ = path;
	*addrin = fname;

	_aes(0, 0xc1000404L);

	*button = intout[1];
	*nfiles = intout[2];
	*sort_mode = intout[3];

	*pattern = _GemParBlk.addrout[0];

	return(intout[0]);
}


/*
*
* Dateiauswahldialog
*
*/

void * fslx_do(
			char *title,
			char *path, WORD pathlen,
			char *fname, WORD fnamelen,
			char *patterns,
			XFSL_FILTER *filter,
			char *paths,
			WORD *sort_mode,
			WORD flags,
			WORD *button,
			WORD *nfiles,
			char **pattern )
{
	WORD *intin = _GemParBlk.intin;
	WORD *intout = _GemParBlk.intout;
	void **addrin = _GemParBlk.addrin;

	*intin++ = pathlen;
	*intin++ = fnamelen;
	*intin++ = *sort_mode;
	*intin = flags;

	*addrin++ = title;
	*addrin++ = path;
	*addrin++ = fname;
	*addrin++ = patterns;
	*addrin++ = filter;
	*addrin = paths;

	_aes(0, 0xc2040406L);

	*button = intout[1];
	*nfiles = intout[2];
	*sort_mode = intout[3];

	*pattern = _GemParBlk.addrout[1];
	return(_GemParBlk.addrout[0]);
}

/*
*
* Globale Flags
*
*/

extern WORD fslx_set_flags(
			WORD flags,
			WORD *oldval )
{

	_GemParBlk.intin[0] = 0;
	_GemParBlk.intin[1] = flags;

	_aes(0, 0xc3020200L);

	*oldval = _GemParBlk.intout[1];
	return(_GemParBlk.intout[0]);
}
