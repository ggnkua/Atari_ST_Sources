/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - WIND-Bibliothek kompatibel zu PureC							*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

/* Wir brauchen die KompatibilitÑts-Funktionen, keine Makro-Definitionen! */
#define __COMPATIBLE_FKT__

/******************************************************************************/

#include <AES.H>
#include <ACSAES.H>
#include <String.H>
#include <StdArg.H>

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
	void *addrin[3];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* Externe benutzte Variablen																	*/
/*																										*/
/******************************************************************************/

/* Anzahl der benutzten Parameter fÅr wind_get und wind_set	*/
/* Belegung:	1. Index: Modus										*/
/* 				2. Index: 0 - wind_get, 1 - wind_set			*/
extern int16 MaxParmsWindGetSet[][2];
extern int16 AnzMaxParmsWindGetSet;

/******************************************************************************/
/*																										*/
/* AES 100:	wind_create																			*/
/*																										*/
/******************************************************************************/

int16 wind_create( const int16 kind, const int16 max_x, const int16 max_y,
				const int16 max_w, const int16 max_h )
{
	return mt_wind_create(kind, max_x, max_y, max_w, max_h, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 101:	wind_open																			*/
/*																										*/
/******************************************************************************/

int16 wind_open( const int16 handle, const int16 x, const int16 y,
				const int16 w, const int16 h )
{
	return mt_wind_open(handle, x, y, w, h, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 102:	wind_close																			*/
/*																										*/
/******************************************************************************/

int16 wind_close( const int16 handle )
{
	return mt_wind_close(handle, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 103:	wind_delete																			*/
/*																										*/
/******************************************************************************/

int16 wind_delete( const int16 handle )
{
	return mt_wind_delete(handle, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 104:	wind_get - PureC-kompatible Version mit variablen Parametern		*/
/*																										*/
/******************************************************************************/

int16 wind_get( const int16 handle, const int16 what, ... )
{
	/* AES-Datenblock anlegen */
	AESData data = {{104, 2, 5, 0, 0}};
	
	/* FÅr die Behandlung der variablen Parameter */
	va_list liste;
	register int16 *value, *pintout;
	register int16 i;
	int16 max = (what>=0 && what<AnzMaxParmsWindGetSet ? MaxParmsWindGetSet[what][0] : 4);
	
	/* Bei Wert -1 wird abgebrochen! */
	if( max<0 )
		return 0;
	
	/* Das globl-Array eintragen */
	data.globl = _globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = handle;
	data.intin[1] = what;
	
	/* Bei manchen Werten muû das intin-Array mit Werten belegt werden */
	switch(what)
	{
		case WF_COLOR:
		case WF_DCOLOR:
			/* Die Fensternummer wird in intin[2] erwartet! */
			data.intin[2] = handle;
			data.contrl[1] += 1;
			break;
		
		case WF_NAME:
		case WF_INFO:
			/* Der Zeiger auf den String wird in intin[2/3] erwartet */
			va_start(liste, what);
			value = va_arg(liste, int16 *);
			va_end(liste);
			
			/* Den Zeiger ggf. eintragen */
			if( value!=NULL )
			{
				*(int16 **)&data.intin[2] = value;
				data.contrl[1] += 2;
			}
			break;
	}
	
	/* Sicherheitshalber intout mit 0 initiaisieren */
	data.intout[0] = data.intout[1] = data.intout[2] = data.intout[3] = data.intout[4] = 0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	pintout=&data.intout[1];
	va_start(liste, what);
	for( i=0, pintout=data.intout+1 ; i<max ; i++, pintout++ )
	{
		value = va_arg(liste, int16 *);
		if( value!=NULL )
			*value = *pintout;
	}
	va_end(liste);
		
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 104:	wind_get - nicht-multithreading-feste Version mit var. Parametern	*/
/*								optimiert fÅr Pointer-öbergaben								*/
/*																										*/
/******************************************************************************/

int16 wind_get_opt( const int16 handle, const int16 what, ... )
{
	/* AES-Datenblock anlegen */
	AESData data={{104, 2, 5, 0, 0}};
	
	/* FÅr die Behandlung der variablen Parameter */
	va_list liste;
	register int16 *value, *pintout;
	register int16 i, j, max;
	static int16 max_parms[][4] =
		{
			{0, 0, 0, 0},				/* unused							 		*/
			{1, 0, 0, 0},				/* WF_KIND 									*/
			{0, 0, 0, 0},				/* WF_NAME 						(N.AES)	*/
			{0, 0, 0, 0},				/* WF_INFO 						(N.AES)	*/
			{1, 1, 1, 1},				/* WF_WORKXYWH 							*/
			{1, 1, 1, 1},				/* WF_CURRXYWH 							*/
			{1, 1, 1, 1},				/* WF_PREVXYWH			 					*/
			{1, 1, 1, 1},				/* WF_FULLXYWH 							*/
			{1, 0, 0, 0},				/* WF_HSLIDE			 					*/
			{1, 0, 0, 0},				/* WF_VSLIDE 								*/
			{1, 1, 1, 0},				/* WF_TOP (was 1, 3 since AES 3.3)	*/
			{1, 1, 1, 1},				/* WF_FIRSTXYWH 							*/
			{1, 1, 1, 1},				/* WF_NEXTXYWH 							*/
			{0, 0, 0, 0},				/* unused 									*/
			{2, 1, 0, 0},				/* WF_NEWDESK 		(since AES 3.3)	*/
			{1, 0, 0, 0},				/* WF_HSLSIZE 								*/
			{1, 0, 0, 0},				/* WF_VSLSIZE 								*/
			{2, 2, 0, 0},				/* WF_SCREEN 								*/
			{1, 1, 1, 0},				/* WF_COLOR     	(since AES 3.3)	*/
			{1, 1, 1, 0},				/* WF_DCOLOR    	(since AES 3.3)	*/
			{1, 1, 1, 1},				/* WF_OWNER     	(since AES 3.3)	*/
			{0, 0, 0, 0},				/* unused								 	*/
			{0, 0, 0, 0},				/* unused								 	*/
			{0, 0, 0, 0},				/* unused								 	*/
			{1, 0, 0, 0},				/* WF_BEVENT 		(since AES 3.31)	*/
			{1, 0, 0, 0},				/* WF_BOTTOM 		(since AES 3.31)	*/
			{1, 1, 1, 0},				/* WF_ICONIFY		(since AES 4.1)	*/
			{1, 1, 1, 1},				/* WF_UNICONIFY	(since AES 4.1)	*/
			{0, 0, 0, 0},				/* unused								 	*/
			{0, 0, 0, 0},				/* unused								 	*/
			{2, 0, 0, 0},				/* WF_TOOLBAR		(since AES 4.1)	*/
			{1, 1, 1, 1},				/* WF_FTOOLBAR		(since AES 4.1)	*/
			{1, 1, 1, 1}				/* WF_NTOOLBAR		(since AES 4.1)	*/
		};
	static int16 anz_max_parms=(int16)(sizeof(max_parms)/sizeof(max_parms[0]));
	
	/* Das globl-Array eintragen */
	data.globl = _globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = handle;
	data.intin[1] = what;
	
	/* Bei manchen Werten muû das intin-Array mit Werten belegt werden */
	switch(what)
	{
		case WF_COLOR:
		case WF_DCOLOR:
			/* Die Fensternummer wird in intin[2] erwartet! */
			data.intin[2] = handle;
			data.contrl[1] += 1;
			break;
		
		case WF_NAME:
		case WF_INFO:
			/* */
			va_start(liste, what);
			value = va_arg(liste, int16 *);
			*(int16 **)&data.intin[2] = value;
			va_end(liste);
			
			data.contrl[1] += 2;
			break;
	}
	
	/* Sicherheitshalber intout mit 0 initiaisieren */
	data.intout[0] = data.intout[1] = data.intout[2] = data.intout[3] = data.intout[4] = 0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	pintout=&data.intout[1];
	va_start(liste, what);
	for( i=0 ; i<4 ; i++ )
	{
		max=(what<anz_max_parms ? max_parms[what][i] : 1);
		if( max>0 )
		{
			value=va_arg(liste, int16 *);
			if( value!=NULL )
				for( j=0 ; j<max ; j++, value++, pintout++ )
					*value=*pintout;
		}
	}
	va_end(liste);
		
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 104:	wind_get - Spezial-Version fÅr die QSB-Ermittelung						*/
/*								(QSB: Quater Screen Buffer, WF_SCREEN)						*/
/*																										*/
/******************************************************************************/

int16 wind_getQSB( const int16 handle, void **buffer, int32 *length )
{
	return mt_wind_getQSB(handle, buffer, length, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 104:	wind_get - Optimiert fÅr RÅckgaben von Rechtecken						*/
/*																										*/
/******************************************************************************/

int16 wind_get_grect( const int16 handle, int16 what, GRECT *r ){
	return mt_wind_get_grect(handle, what, r, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 104:	wind_xget - Spezial-Binding aus der GEMLIB								*/
/*																										*/
/******************************************************************************/

int16 wind_xget_grect( const int16 handle, int16 what, const GRECT *clip, GRECT *r )
{
	return mt_wind_xget_grect(handle, what, clip, r, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 105:	wind_set - PureC-kompatible Version mit variablen Parametern		*/
/*																										*/
/******************************************************************************/

int16 wind_set( const int16 handle, const int16 what, ... )
{
	/* AES-Datenblock anlegen */
	AESData data={{105, 6, 1, 0, 0}};
	
	/* FÅr die Behandlung der variablen Parameter */
	va_list liste;
	register int16 *pintin;
	register int16 i;
	int16 max = (what>=0 && what<AnzMaxParmsWindGetSet ? MaxParmsWindGetSet[what][1] : 4);
	
	/* Bei Wert -1 wird abgebrochen! */
	if( max<0 )
		return 0;
	
	/* Das globl-Array eintragen */
	data.globl=_globl;
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=what;
	
	/* Die Daten Åbertragen */
	va_start(liste, what);
	for( i=0, pintin=&(data.intin[2]) ; i<max ; i++, pintin++ )
		*pintin = va_arg(liste, int16);
	va_end(liste);
	for( ; i<4 ; i++, pintin++ )
		*pintin = 0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 105:	wind_set - FÅr Rechteck-Daten optimierte Version						*/
/*																										*/
/******************************************************************************/

int16 wind_setGRECT( const int16 handle, const int16 what, const GRECT *xywh )
{
	return mt_wind_setGRECT(handle, what, xywh, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 106:	wind_find																			*/
/*																										*/
/******************************************************************************/

int16 wind_find( const int16 x, const int16 y )
{
	return mt_wind_find(x, y, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 107:	wind_update																			*/
/*																										*/
/******************************************************************************/

int16 wind_update( const int16 what )
{
	return mt_wind_update(what, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 108:	wind_calc																			*/
/*																										*/
/******************************************************************************/

int16 wind_calc( const int16 wtype, const int16 kind, const int16 x, const int16 y,
				const int16 w, const int16 h, int16 *px, int16 *py, int16 *pw, int16 *ph )
{
	return mt_wind_calc(wtype, kind, x, y, w, h, px, py, pw, ph, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 108:	wind_calc - optimierte Version												*/
/*																										*/
/******************************************************************************/

int16 wind_calcGRECT( const int16 wtype, const int16 kind, const GRECT *input,
				GRECT *output )
{
	return mt_wind_calcGRECT(wtype, kind, input, output, _globl);
}

/******************************************************************************/
/*																										*/
/* AES 109:	wind_new																				*/
/*																										*/
/******************************************************************************/

int16 wind_new( void )
{
	return mt_wind_new(_globl);
}

/******************************************************************************/
/*																										*/
/* AES 99:	wind_draw																			*/
/*																										*/
/******************************************************************************/

int16 wind_draw( const int16 handle, const int16 startob )
{
	return mt_wind_draw(handle, startob, _globl);
}
