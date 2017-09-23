/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - FSEL-Bibliothek													*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

#include <ACSAES.H>
#include <String.H>
#ifndef C_HBFS
	#include <ACSCook.H>
#endif

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
	int16 contrl[CTRL_BYTES];
	GlobalArray *globl;
	int16 intin[17];
	int16 intout[7];
	void *addrin[3];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 90:	fsel_input																			*/
/*																										*/
/******************************************************************************/

int16 mt_fsel_input( char *path, char *name, int16 *button, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {90, 0, 2, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = path;
	data.addrin[1] = name;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Den Wert zurÅckgeben */
	if( button!=NULL )
		*button = data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 91:	fsel_exinput																		*/
/*																										*/
/******************************************************************************/

int16 mt_fsel_exinput( char *path, char *name, int16 *button, const char *label,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {91, 0, 2, 3, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Wenn fsel_exinput nicht verfÅgbar ist, wird fsel_input verwendet */
	if( data.globl->ap_version<0x0140
			|| (data.globl->ap_version>=0x0200 && data.globl->ap_version<0x0300) )
		return mt_fsel_input(path, name, button, globl);
	else
	{
		/* Die Arrays fÅllen */
		data.addrin[0] = path;
		data.addrin[1] = name;
		data.addrin[2] = label;
		
		/* Ab in die AES... */
		aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
		
		/* Den Wert zurÅckgeben */
		if( button!=NULL )
			*button = data.intout[1];
	
		return data.intout[0];
	}
}

/******************************************************************************/
/*																										*/
/* AES 91:	fsel_exinput																		*/
/*																										*/
/******************************************************************************/

int16 mt_fsel_boxinput( char *path, char *name, int *button, const char *label,
				FSEL_CALLBACK callback, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {91, 0, 2, 4, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Wenn fsel_boxinput nicht verfÅgbar ist, wird fsel_input verwendet */
	if( !Ash_getcookie(C_HBFS, NULL) )
		return mt_fsel_exinput(path, name, button, label, globl);
	else
	{
		/* Die Arrays fÅllen */
		data.addrin[0] = path;
		data.addrin[1] = name;
		data.addrin[2] = label;
		data.addrin[3] = callback;
		
		/* Ab in die AES... */
		aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
		
		/* Den Wert zurÅckgeben */
		if( button!=NULL )
			*button = data.intout[1];
	
		return data.intout[0];
	}
}
