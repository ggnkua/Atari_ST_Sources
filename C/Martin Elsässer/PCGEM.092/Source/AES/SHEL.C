/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - SHEL-Bibliothek													*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

#include <ACSAES.H>
#include <String.H>
#include <StdArg.H>

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
/* AES 120:	shel_read																			*/
/*																										*/
/******************************************************************************/

int16 mt_shel_read( char *cmd, char *tail, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {120, 0, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = cmd;
	data.addrin[1] = tail;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 121:	shel_write																			*/
/*																										*/
/******************************************************************************/

int16 mt_shel_write( const int16 do_execute, const int16 is_graph, const int16 is_overlay,
				char *cmd, char *tail, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {121, 3, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = do_execute;
	data.intin[1] = is_graph;
	data.intin[2] = is_overlay;
	
	data.addrin[0] = cmd;
	data.addrin[1] = tail;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 122:	shel_get																				*/
/*																										*/
/******************************************************************************/

int16 mt_shel_get( char *addr, const int16 len, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {122, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = len;
	
	data.addrin[0] = addr;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 123:	shel_put																				*/
/*																										*/
/******************************************************************************/

int16 mt_shel_put( char *addr, const int16 len, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {123, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = len;
	
	data.addrin[0] = addr;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 124:	shel_find																			*/
/*																										*/
/******************************************************************************/

int16 mt_shel_find( char *path, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {124, 0, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = path;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 125:	shel_envrn																			*/
/*																										*/
/******************************************************************************/

int16 mt_shel_envrn( char **value, char *name, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {125, 0, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = value;
	data.addrin[1] = name;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Fix fÅr Suche nach "PATH" wegen TOS-Bug                          */
	/* TOS hat den netten Bug, beim Initialisieren des Environments die */
	/* Variable _bootdev ($446) als BYTE und nicht als WORD auszulesen, */
	/* so daû natÅrlich das Bootlaufwerk als Null-Byte eingetragen wird */
	if( *value!=NULL && **value=='\0' && strcmp(name, "PATH=")==0 )
		(*value)++;
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 126:	shel_rdef																			*/
/*																										*/
/******************************************************************************/

int16 mt_shel_rdef( char *cmd, char *dir, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {126, 0, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = cmd;
	data.addrin[1] = dir;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 127:	shel_wdef																			*/
/*																										*/
/******************************************************************************/

int16 mt_shel_wdef( char *cmd, char *dir, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {127, 0, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = cmd;
	data.addrin[1] = dir;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 128:	shel_help																			*/
/*																										*/
/******************************************************************************/

int16 mt_shel_help( const int16 mode, char *file, char *key, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {128, 1, 1, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = mode;
	
	data.addrin[0] = file;
	data.addrin[1] = key;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}
