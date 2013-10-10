/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Utility-Funktionen																			*/
/*																										*/
/*	(c) 1998-2005 by Martin ElsÑsser															*/
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
/* Lokale Variablen																				*/
/*																										*/
/******************************************************************************/

int16 mt_wind_calc_grect( const int16 type, int16 parts, const GRECT *in, GRECT *out, GlobalArray *globl );int16 mt_wind_create_grect( const int16 parts, const GRECT *r, short *global_aes);
/******************************************************************************/
/*																										*/
/* AES 100:	wind_create																			*/
/*																										*/
/******************************************************************************/

{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {104, 6, 5, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = handle;
	data.intin[1] = what;
	data.intin[2] = in->g_x;
	data.intin[3] = in->g_y;
	data.intin[4] = in->g_w;
	data.intin[4] = in->g_h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* NÅtzliche Erweiterungen																		*/
/*																										*/
/******************************************************************************/

int16 mt_wind_open_grect( const int16 handle, const GRECT *r, GlobalArray *globl );int16 mt_wind_set_grect( const int16 handle, const int16 what, const GRECT *r, GlobalArray *globl );int16 mt_wind_xset_grect( const int16 handle, const int16 what, const GRECT *s, GRECT *r, GlobalArray *globl );int16 mt_wind_set_str( const int16 handle, const int16 what, const char *str, GlobalArray *globl );
