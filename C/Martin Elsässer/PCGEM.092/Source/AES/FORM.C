/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - FORM-Bibliothek													*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

#include <ACSAES.H>
#include <String.H>

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
	int16 contrl[5];
	GlobalArray *globl;
	int16 intin[17];
	int16 intout[7];
	void *addrin[2];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 50:	form_do																				*/
/*																										*/
/******************************************************************************/

int16 mt_form_do( OBJECT *tree, const int16 start, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {50, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = start;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 51:	form_dial																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_dial( const int16 flag, const int16 xlittle, const int16 ylittle,
				const int16 wlittle, const int16 hlittle, const int16 xbig, const int16 ybig,
				const int16 wbig, const int16 hbig, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {51, 9, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = flag;
	data.intin[1] = xlittle;
	data.intin[2] = ylittle;
	data.intin[3] = wlittle;
	data.intin[4] = hlittle;
	data.intin[5] = xbig;
	data.intin[6] = ybig;
	data.intin[7] = wbig;
	data.intin[8] = hbig;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 52:	form_alert																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_alert( const int16 defbutton, char *string, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {52, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = defbutton;
	
	data.addrin[0] = string;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 53:	form_error																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_error( const int16 errnum, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {53, 1, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = (errnum<0 ? (~errnum)-30 : errnum);
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 54:	form_center																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_center( OBJECT *tree, int16 *x, int16 *y, int16 *w, int16 *h,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {54, 0, 5, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	if( x!=NULL )
		*x = data.intout[1];
	if( y!=NULL )
		*y = data.intout[2];
	if( w!=NULL )
		*w = data.intout[3];
	if( h!=NULL )
		*h = data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 55:	form_keybd																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_keybd( OBJECT *tree, const int16 obj, const int16 next,
				const int16 input_char, int16 *next_obj, int16 *pchar, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {55, 3, 3, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = input_char;
	data.intin[2] = next;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	if( next_obj!=NULL )
		*next_obj = data.intout[1];
	if( pchar!=NULL )
		*next_obj = data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 64:	form_wkeybd																			*/
/*																										*/
/******************************************************************************/

/* Weiû der Henker, was das ist, steht in der CAT_Bibliothek so drin... */

/******************************************************************************/
/*																										*/
/* AES 56:	form_button																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_button( OBJECT *tree, const int16 obj, const int16 clicks, int16 *next_obj,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {56, 2, 2, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = obj;
	data.intin[1] = clicks;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	if( next_obj!=NULL )
		*next_obj = data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 135:	form_popup																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_popup( OBJECT *tree, const int16 x, const int16 y, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {135, 2, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = x;
	data.intin[1] = y;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 63:	form_wbutton																		*/
/*																										*/
/******************************************************************************/

int16 mt_form_wbutton( const OBJECT *fo_btree, const int16 fo_bobject,
					const int16 fo_bclicks, int16 *fo_bnxtobj, const int16 whandle,
					GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {63, 3, 2, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = fo_bobject;
	data.intin[1] = fo_bclicks;
	data.intin[2] = whandle;
	
	data.addrin[0] = fo_btree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Den RÅckgabewert liefern */
	if( fo_bnxtobj!=NULL )
		*fo_bnxtobj = data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 51:	form_xdial																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_xdial( const int16 fo_diflag, const int16 fo_dilittlx, const int16 fo_dilittly,
				const int16 fo_dilittlw, const int16 fo_dilittlh, const int16 fo_dibigx,
				const int16 fo_dibigy, const int16 fo_dibigw, const int16 fo_dibigh,
				void **flydial, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {51, 9, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = fo_diflag;
	data.intin[1] = fo_dilittlx;
	data.intin[2] = fo_dilittly;
	data.intin[3] = fo_dilittlw;
	data.intin[4] = fo_dilittlh;
	data.intin[5] = fo_dibigx;
	data.intin[6] = fo_dibigy;
	data.intin[7] = fo_dibigw;
	data.intin[8] = fo_dibigh;
	
	data.addrin[0] = flydial;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 50:	form_xdo																				*/
/*																										*/
/******************************************************************************/

int16 mt_form_xdo( const OBJECT *tree, const int16 startob, int16 *lastcrsr,
				const XDO_INF *tabs, void *flydial, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {50, 1, 2, 3, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = startob;
	
	data.addrin[0] = tree;
	data.addrin[1] = tabs;
	data.addrin[2] = flydial;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Den RÅckgabewert liefern */
	if( lastcrsr!=NULL )
		*lastcrsr = data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 136:	form_xerr																			*/
/*																										*/
/******************************************************************************/

int16 mt_form_xerr( const int32 errcode, int8 *errfile, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {136, 2, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	*(int32 *)&data.intin[0] = errcode;
	
	data.addrin[0] = errfile;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}
