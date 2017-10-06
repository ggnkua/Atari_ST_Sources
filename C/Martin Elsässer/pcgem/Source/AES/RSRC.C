/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - RSRC-Bibliothek													*/
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
/* AES 110:	rsrc_load																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 rsrc_load( char *name )
#else
	INT16 rsrc_load( GLOBAL *globl, char *name )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{110, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=name;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 111:	rsrc_free																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 rsrc_free( void )
#else
	INT16 rsrc_free( GLOBAL *globl )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{111, 0, 1, 0, 0}};
	
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
/* AES 112:	rsrc_gaddr																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 rsrc_gaddr( INT16 type, INT16 id, void **addr )
#else
	INT16 rsrc_gaddr( GLOBAL *globl, INT16 type, INT16 id, void **addr )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{112, 2, 1, 0, 1}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=type;
	data.intin[1]=id;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Adresse zurÅckgeben */
	if( addr!=NULL )
		*addr=data.addrout[0];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 113:	rsrc_saddr																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 rsrc_saddr( INT16 type, INT16 id, void *addr )
#else
	INT16 rsrc_saddr( GLOBAL *globl, INT16 type, INT16 id, void *addr )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{113, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=type;
	data.intin[1]=id;
	
	data.addrin[0]=addr;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 114:	rsrc_obfix																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 rsrc_obfix( OBJECT *tree, INT16 obj )
#else
	INT16 rsrc_obfix( GLOBAL *globl, OBJECT *tree, INT16 obj )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{114, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=obj;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 115:	rsrc_rcfix																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 rsrc_rcfix( void *rc_header )
#else
	INT16 rsrc_rcfix( GLOBAL *globl, void *rc_header )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{115, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=rc_header;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

