/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - SCRP-Bibliothek													*/
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
	void *addrin[2];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 80:	scrp_read																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 scrp_read( char *pathname )
#else
	INT16 scrp_read( GLOBAL *globl, char *pathname )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{80, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=pathname;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 81:	scrp_write																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 scrp_write( char *pathname )
#else
	INT16 scrp_write( GLOBAL *globl, char *pathname )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{81, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=pathname;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 82:	scrp_clear																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 scrp_clear( void )
#else
	INT16 scrp_clear( GLOBAL *globl )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{82, 0, 1, 0, 0}};
	
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

