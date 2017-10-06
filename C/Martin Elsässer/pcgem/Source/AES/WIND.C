/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - WIND-Bibliothek													*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	#include <AES.H>
#else
	#include <ACSAES.H>
#endif
#include <String.H>
#include <StdArg.H>

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
	void *addrin[3];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 100:	wind_create																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 wind_create( GLOBAL *globl, INT16 kind, Axywh *max )
{
	/* AES-Datenblock anlegen */
	AESData data={{100, 5, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=kind;
	data.intin[1]=max->x;
	data.intin[2]=max->y;
	data.intin[3]=max->w;
	data.intin[4]=max->h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 wind_create( INT16 kind, INT16 max_x, INT16 max_y,
					INT16 max_w, INT16 max_h )
#else 
	INT16 wind_create_( GLOBAL *globl, INT16 kind, INT16 max_x, INT16 max_y,
					INT16 max_w, INT16 max_h )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{100, 5, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=kind;
	data.intin[1]=max_x;
	data.intin[2]=max_y;
	data.intin[3]=max_w;
	data.intin[4]=max_h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 101:	wind_open																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 wind_open( GLOBAL *globl, INT16 handle, Axywh *rect )
{
	/* AES-Datenblock anlegen */
	AESData data={{101, 5, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=rect->x;
	data.intin[2]=rect->y;
	data.intin[3]=rect->w;
	data.intin[4]=rect->h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 wind_open( INT16 handle, INT16 x, INT16 y,
					INT16 w, INT16 h )
#else
	INT16 wind_open_( GLOBAL *globl, INT16 handle, INT16 x, INT16 y,
					INT16 w, INT16 h )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{101, 5, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=x;
	data.intin[2]=y;
	data.intin[3]=w;
	data.intin[4]=h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 102:	wind_close																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 wind_close( INT16 handle )
#else
	INT16 wind_close( GLOBAL *globl, INT16 handle )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{102, 1, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 103:	wind_delete																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 wind_delete( INT16 handle )
#else
	INT16 wind_delete( GLOBAL *globl, INT16 handle )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{103, 1, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 104:	wind_get																				*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 wind_get( GLOBAL *globl, INT16 handle, INT16 what,
				INT16 *value1, INT16 *value2, INT16 *value3, INT16 *value4 )
{
	/* AES-Datenblock anlegen */
	AESData data={{104, 2, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=what;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( value1!=NULL )
		*value1=data.intout[1];
	if( value2!=NULL )
		*value2=data.intout[2];
	if( value3!=NULL )
		*value3=data.intout[3];
	if( value4!=NULL )
		*value4=data.intout[4];
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* Funktion nur fÅr nicht ACS-AES-Binding */
#ifdef __COMPATIBLE__

INT16 wind_get( INT16 handle, INT16 what, ... )
{
	/* AES-Datenblock anlegen */
	AESData data={{104, 2, 5, 0, 0}};
	
	/* FÅr die Behandlung der variablen Parameter */
	va_list liste;
	register INT16 *value, *pintout;
	register INT16 i, j, max;
	static INT16 max_parms[][4]=
		{
			{0, 0, 0, 0},
			{1, 0, 0, 0},
			{2, 2, 0, 0},
			{2, 2, 0, 0},
			{1, 1, 1, 1},
			{1, 1, 1, 1},
			{1, 1, 1, 1},
			{1, 1, 1, 1},
			{1, 0, 0, 0},
			{1, 0, 0, 0},
			{1, 0, 0, 0},
			{1, 1, 1, 1},
			{1, 1, 1, 1},
			{0, 0, 0, 0},
			{2, 1, 0, 0},
			{1, 0, 0, 0},
			{1, 0, 0, 0},
			{2, 2, 0, 0},
			{1, 1, 1, 0},
			{1, 1, 1, 0}
		};
	static INT16 anz_max_parms=(INT16)(sizeof(max_parms)/sizeof(max_parms[0]));
	
	/* Das globl-Array bestimmen */
	data.globl=_globl;
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=what;
	
	/* Spezial-Behandlung fÅr WF_COLOR und WF_DCOLOR */
	if( what==WF_COLOR || what==WF_DCOLOR )
	{
		va_start(liste, what);
		value=va_arg(liste, INT16 *);
		va_end(liste);
		
		data.intin[2]=*value;
		data.contrl[1]=3;
	}
	
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
			value=va_arg(liste, INT16 *);
			if( value!=NULL )
				for( j=0 ; j<max ; j++, value++, pintout++ )
					*value=*pintout;
		}
	}
	va_end(liste);
		
	return data.intout[0];
}

#endif

/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 wind_getAxywh( GLOBAL *globl, INT16 handle, INT16 what, Axywh *xywh )
{
	/* AES-Datenblock anlegen */
	AESData data={{104, 2, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=what;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( xywh!=NULL )
	{
		xywh->x=data.intout[1];
		xywh->y=data.intout[2];
		xywh->w=data.intout[3];
		xywh->h=data.intout[4];
	}
	
	return data.intout[0];
}

#endif

/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 wind_getQSB( INT16 handle, void **buffer, INT32 *length )
#else
	INT16 wind_getQSB( GLOBAL *globl, INT16 handle, void **buffer, INT32 *length )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{104, 2, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=WF_SCREEN;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( buffer!=NULL )
		*buffer=*(void **)&data.intout[1];
	if( length!=NULL )
	{
		*length=*(INT32 *)&data.intout[3];
		
		/* Die Korrektur fÅr TOS 1.02 aus dem Profibuch */
		if( *length==0 && data.globl->ap_version==0x0120 )
			*length=8000;
	}
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 105:	wind_set																				*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 wind_set( GLOBAL *globl, INT16 handle, INT16 what,
				INT16 value1, INT16 value2, INT16 value3, INT16 value4 )
{
	/* AES-Datenblock anlegen */
	AESData data={{105, 6, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=what;
	data.intin[2]=value1;
	data.intin[3]=value2;
	data.intin[4]=value3;
	data.intin[5]=value4;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* Funktion nur fÅr nicht ACS-AES-Binding */
#ifdef __COMPATIBLE__

INT16 wind_set( INT16 handle, INT16 what, ... )
{
	/* AES-Datenblock anlegen */
	AESData data={{105, 6, 1, 0, 0}};
	
	/* FÅr die Behandlung der variablen Parameter */
	va_list liste;
	register INT16 *pintin;
	register INT16 i, max;
	static INT16 max_parms[]={0, 0, 2, 2, 0, 4, 0, 0, 1, 1, 1, 0, 0, 0, 3, 1, 1, 0, 3, 3};
	static INT16 anz_max_parms=(INT16)(sizeof(max_parms)/sizeof(max_parms[0]));
	
	/* Das globl-Array bestimmen */
	data.globl=_globl;
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=what;
	
	/* Die Daten Åbertragen */
	max=(what<anz_max_parms ? max_parms[what] : 4);
	va_start(liste, what);
	for( i=0, pintin=&(data.intin[2]) ; i<max ; i++, pintin++ )
		*pintin=va_arg(liste, INT16);
	va_end(liste);
	for( ; i<4 ; i++, pintin++ )
		*pintin=0;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 wind_setAxywh( GLOBAL *globl, INT16 handle, INT16 what, Axywh *xywh )
{
	/* AES-Datenblock anlegen */
	AESData data={{105, 6, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=handle;
	data.intin[1]=what;
	data.intin[2]=xywh->x;
	data.intin[3]=xywh->y;
	data.intin[4]=xywh->w;
	data.intin[5]=xywh->h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/
/*																										*/
/* AES 106:	wind_find																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 wind_find( INT16 x, INT16 y )
#else
	INT16 wind_find( GLOBAL *globl, INT16 x, INT16 y )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{106, 2, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=x;
	data.intin[1]=y;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 107:	wind_update																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 wind_update( INT16 what )
#else
	INT16 wind_update( GLOBAL *globl, INT16 what )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{107, 1, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=what;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 108:	wind_calc																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 wind_calc( GLOBAL *globl, INT16 wtype, INT16 kind,
				Axywh *input, Axywh *output )
{
	/* AES-Datenblock anlegen */
	AESData data={{108, 6, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=wtype;
	data.intin[1]=kind;
	data.intin[2]=input->x;
	data.intin[3]=input->y;
	data.intin[4]=input->w;
	data.intin[5]=input->h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( output!=NULL )
	{
		output->x=data.intout[1];
		output->y=data.intout[2];
		output->w=data.intout[3];
		output->h=data.intout[4];
	}
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 wind_calc( INT16 wtype, INT16 kind,
					INT16 x, INT16 y, INT16 w, INT16 h,
					INT16 *px, INT16 *py, INT16 *pw, INT16 *ph )
#else 
	INT16 wind_calc_( GLOBAL *globl, INT16 wtype, INT16 kind,
					INT16 x, INT16 y, INT16 w, INT16 h,
					INT16 *px, INT16 *py, INT16 *pw, INT16 *ph )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{108, 6, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=wtype;
	data.intin[1]=kind;
	data.intin[2]=x;
	data.intin[3]=y;
	data.intin[4]=w;
	data.intin[5]=h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( px!=NULL )
		*px=data.intout[1];
	if( py!=NULL )
		*py=data.intout[2];
	if( pw!=NULL )
		*pw=data.intout[3];
	if( ph!=NULL )
		*ph=data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 109:	wind_new																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 wind_new( void )
#else
	INT16 wind_new( GLOBAL *globl )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{109, 0, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 99:	wind_draw																			*/
/*																										*/
/******************************************************************************/

/* Aus CAT-Bibliothek geholt ... */
#ifdef __COMPATIBLE__
	INT16 wind_draw( INT16 wi_dhandle, INT16 wi_dstartob )
#else
	INT16 wind_draw( GLOBAL *globl, INT16 wi_dhandle, INT16 wi_dstartob )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{99, 2, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0] = wi_dhandle;
	data.intin[1] = wi_dstartob;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

