/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - FSEL-Bibliothek													*/
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
	void *addrin[3];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 90:	fsel_input																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fsel_input( char *path, char *name, INT16 *button )
#else
	INT16 fsel_input( GLOBAL *globl, char *path, char *name, INT16 *button )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{90, 0, 2, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=path;
	data.addrin[1]=name;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Den Wert zurÅckgeben */
	if( button!=NULL )
		*button=data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 91:	fsel_exinput																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fsel_exinput( char *path, char *name, INT16 *button, char *label )
#else
	INT16 fsel_exinput( GLOBAL *globl, char *path, char *name, INT16 *button, char *label )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{91, 0, 2, 3, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Wenn fsel_exinput nicht verfÅgbar ist, wird fsel_input verwendet */
	if( data.globl->ap_version>=0x0300
			|| (data.globl->ap_version>=0x0140 && data.globl->ap_version<0x0200) )
		#ifdef __COMPATIBLE__
			return fsel_input(path, name, button);
		#else
			return fsel_input(globl, path, name, button);
		#endif
	else
	{
		/* Die Arrays fÅllen */
		data.addrin[0]=path;
		data.addrin[1]=name;
		data.addrin[2]=label;
		
		/* Ab in die AES... */
		aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
		
		/* Den Wert zurÅckgeben */
		if( button!=NULL )
			*button=data.intout[1];
	
		return data.intout[0];
	}
}

/******************************************************************************/
/*																										*/
/* AES 91:	fsel_exinput																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 fsel_boxinput( char *path, char *name, int *button,
				char *label, FSEL_CALLBACK callback )
#else
	INT16 fsel_boxinput( GLOBAL *globl, char *path, char *name, int *button,
				char *label, FSEL_CALLBACK callback )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{91, 0, 2, 4, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Wenn fsel_exinput nicht verfÅgbar ist, wird fsel_input verwendet */
	if( data.globl->ap_version>=0x0300
			|| (data.globl->ap_version>=0x0140 && data.globl->ap_version<0x0200) )
		#ifdef __COMPATIBLE__
			return fsel_input(path, name, button);
		#else
			return fsel_input(globl, path, name, button);
		#endif
	else
	{
		/* Die Arrays fÅllen */
		data.addrin[0]=path;
		data.addrin[1]=name;
		data.addrin[2]=label;
		data.addrin[3]=callback;
		
		/* Ab in die AES... */
		aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
		
		/* Den Wert zurÅckgeben */
		if( button!=NULL )
			*button=data.intout[1];
	
		return data.intout[0];
	}
}
