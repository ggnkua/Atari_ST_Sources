/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - APPL-Bibliothek													*/
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
	INT16 intin[16];
	INT16 intout[7];
	void *addrin[5];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* Lokale Variablen																				*/
/*																										*/
/******************************************************************************/

#if defined(__COMPATIBLE__) && defined(__GNU_C__)
	#undef __COMPATIBLE__
#endif

#ifdef __COMPATIBLE__
	GEMPARBLK _GemParBlk;
	GLOBAL *_globl = (GLOBAL *)_GemParBlk.global;
#else
	static GLOBAL __global;
	GLOBAL *_globl = &__global;
#endif

/******************************************************************************/
/*																										*/
/* AES 10:	appl_init																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_init( void )
#else
	INT16 appl_init( GLOBAL *globl )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{10, 0, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Das globl-Array initialisieren                         */
	/* - damit kann festgestellt werden, ob AES schon da sind */
	memset(data.globl, 0, sizeof(*data.globl));
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 11:	appl_read																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_read( INT16 rwid, INT16 length, void *pbuff )
#else
	INT16 appl_read( GLOBAL *globl, INT16 rwid, INT16 length, void *pbuff )
#endif
{
	/* contrl anlegen */
	AESData data={{11, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=rwid;
	data.intin[1]=length;
	
	data.addrin[0]=pbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 12:	appl_write																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_write( INT16 rwid, INT16 length, void *pbuff )
#else
	INT16 appl_write( GLOBAL *globl, INT16 rwid, INT16 length, void *pbuff )
#endif
{
	/* contrl anlegen */
	AESData data={{12, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=rwid;
	data.intin[1]=length;
	
	data.addrin[0]=pbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 13:	appl_find																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_find( char *pname )
#else
	INT16 appl_find( GLOBAL *globl, char *pname )
#endif
{
	/* contrl anlegen */
	AESData data={{13, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=pname;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 14:	appl_tplay																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_tplay( APPLRECORD *tbuffer, INT16 tlength, INT16 tscale )
#else
	INT16 appl_tplay( GLOBAL *globl, APPLRECORD *tbuffer, INT16 tlength,
				INT16 tscale )
#endif
{
	/* contrl anlegen */
	AESData data={{14, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=tlength;
	data.intin[1]=tscale;
	
	data.addrin[0]=tbuffer;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 15:	appl_trecord																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_trecord( APPLRECORD *tbuffer, INT16 tlength )
#else
	INT16 appl_trecord( GLOBAL *globl, APPLRECORD *tbuffer, INT16 tlength )
#endif
{
	/* contrl anlegen */
	AESData data={{15, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=tlength;
	
	data.addrin[0]=tbuffer;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 16:	appl_bvset																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_bvset( UINT16 bvdisk, UINT16 bvhard )
#else
	INT16 appl_bvset( GLOBAL *globl, UINT16 bvdisk, UINT16 bvhard )
#endif
{
	/* contrl anlegen */
	AESData data={{16, 2, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=bvdisk;
	data.intin[1]=bvhard;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 17:	appl_yield																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_yield( void )
#else
	INT16 appl_yield( GLOBAL *globl )
#endif
{
	/* contrl anlegen */
	AESData data={{17, 0, 1, 0, 0}};
	
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
/* AES 18:	appl_search																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_search( INT16 mode, char *fname, INT16 *type, INT16 *ap_id )
#else
	INT16 appl_search( GLOBAL *globl, INT16 mode, char *fname,
					INT16 *type, INT16 *ap_id )
#endif
{
	/* contrl anlegen */
	AESData data={{18, 1, 3, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=mode;
	
	data.addrin[0]=fname;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	if( type!=NULL )
		*type=data.intout[1];
	if( ap_id!=NULL )
		*ap_id=data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 19:	appl_exit																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_exit( void )
#else
	INT16 appl_exit( GLOBAL *globl )
#endif
{
	/* contrl anlegen */
	AESData data={{19, 0, 1, 0, 0}};
	
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
/* AES 130:	appl_getinfo																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_getinfo( INT16 type, INT16 *out1, INT16 *out2, INT16 *out3, INT16 *out4 )
#else
	INT16 appl_getinfo( GLOBAL *globl, INT16 type,
					INT16 *out1, INT16 *out2, INT16 *out3, INT16 *out4 )
#endif
{
	/* contrl anlegen */
	AESData data={{130, 1, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=type;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( out1!=NULL )
		*out1 = data.intout[1];
	if( out2!=NULL )
		*out2 = data.intout[2];
	if( out3!=NULL )
		*out3 = data.intout[3];
	if( out4!=NULL )
		*out4 = data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 129:	appl_control																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 appl_control( INT16 ap_cid, INT16 ap_cwhat, void *ap_cout )
#else
	INT16 appl_control( GLOBAL *globl, INT16 ap_cid, INT16 ap_cwhat, void *ap_cout )
#endif
{
	/* contrl anlegen */
	AESData data={{129, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=ap_cid;
	data.intin[1]=ap_cwhat;
	
	data.addrin[0] = ap_cout;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	return data.intout[0];
}
