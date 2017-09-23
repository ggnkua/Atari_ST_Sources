/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - OBJC-Bibliothek													*/
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
	int16 contrl[CTRL_BYTES];
	GlobalArray *globl;
	int16 intin[17];
	int16 intout[7];
	void *addrin[2];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 40:	objc_add																				*/
/*																										*/
/******************************************************************************/

int16 mt_objc_add( OBJECT *tree, const int16 parent, const int16 child, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {40, 2, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = parent;
	data.intin[1] = child;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 41:	objc_delete																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_delete( OBJECT *tree, const int16 objnr, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {41, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = objnr;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 42:	objc_draw																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_draw( OBJECT *tree, const int16 start, const int16 depth, const int16 xclip,
				const int16 yclip, const int16 wclip, const int16 hclip, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {42, 6, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = start;
	data.intin[1] = depth;
	data.intin[2] = xclip;
	data.intin[3] = yclip;
	data.intin[4] = wclip;
	data.intin[5] = hclip;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 42:	objc_wdraw																			*/
/*																										*/
/******************************************************************************/

void mt_objc_wdraw( OBJECT *tree, const int16 start, const int16 depth, GRECT *clip,
				const int16 whandle, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {60, 3, 0, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = start;
	data.intin[1] = depth;
	data.intin[2] = whandle;
	
	data.addrin[0] = tree;
	data.addrin[1] = clip;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 43:	objc_find																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_find( OBJECT *tree, const int16 start, const int16 depth, const int16 mx,
				const int16 my, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {43, 4, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = start;
	data.intin[1] = depth;
	data.intin[2] = mx;
	data.intin[3] = my;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 44:	objc_offset																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_offset( OBJECT *tree, const int16 objnr, int16 *x, int16 *y,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {44, 1, 3, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = objnr;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( x!=NULL )
		*x = data.intout[1];
	if( y!=NULL )
		*y = data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 45:	objc_order																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_order( OBJECT *tree, const int16 objnr, const int16 new_nr, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {45, 2, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = objnr;
	data.intin[1] = new_nr;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 46:	objc_edit																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_edit( OBJECT *tree, const int16 objnr, const int16 inchar, int16 *idx,
				const int16 kind, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {46, 4, 2, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* SicherheitsprÅfung */
	if( idx==NULL )
		return 0;
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = objnr;
	data.intin[1] = inchar;
	data.intin[2] = *idx;
	data.intin[3] = kind;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Wert zurÅckgeben */
	*idx = data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 46:	objc_xedit																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_xedit( OBJECT *tree, const int16 objnr, const int16 inchar, int16 *idx,
				int16 kind, GRECT *r, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {46, 4, 2, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* SicherheitsprÅfung */
	if( idx==NULL )
		return 0;
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = objnr;
	data.intin[1] = inchar;
	data.intin[2] = *idx;
	data.intin[3] = kind;
	
	data.addrin[0] = tree;
	data.addrin[1] = r;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Wert zurÅckgeben */
	*idx = data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 65:	objc_wedit																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_wedit( OBJECT *tree, const int16 objnr, const int16 inchar, int16 *idx,
				const int16 kind, const int16 whandle, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {65, 5, 2, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* SicherheitsprÅfung */
	if( idx==NULL )
		return 0;
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = objnr;
	data.intin[1] = inchar;
	data.intin[2] = *idx;
	data.intin[3] = kind;
	data.intin[4] = whandle;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Wert zurÅckgeben */
	*idx = data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 47:	objc_change																			*/
/*																										*/
/******************************************************************************/

/* Parameter 'reserved' wird nicht benutzt */
#pragma warn -par

int16 mt_objc_change( OBJECT *tree, const int16 objnr, const int16 reserved, 
				const int16 xclip, const int16 yclip, const int16 wclip, const int16 hclip,
				const int16 newstate, const int16 redraw, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {47, 8, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = objnr;
	data.intin[1] = 0;
	data.intin[2] = xclip;
	data.intin[3] = yclip;
	data.intin[4] = wclip;
	data.intin[5] = hclip;
	data.intin[6] = newstate;
	data.intin[7] = redraw;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#pragma warn .par

/******************************************************************************/
/*																										*/
/* AES 47:	objc_wchange																		*/
/*																										*/
/******************************************************************************/

void mt_objc_wchange( OBJECT *tree, const int16 objnr, const int16 newstate,
				GRECT *clip, const int16 whandle, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {61, 3, 0, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = objnr;
	data.intin[1] = newstate;
	data.intin[2] = whandle;
	
	data.addrin[0] = tree;
	data.addrin[1] = clip;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
}

/******************************************************************************/
/*																										*/
/* AES 48:	objc_sysvar																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_sysvar( const int16 mode, const int16 which, const int16 in1, const int16 in2,
				int16 *out1, int16 *out2, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {48, 4, 3, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = mode;
	data.intin[1] = which;
	data.intin[2] = in1;
	data.intin[3] = in2;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	if( out1!=NULL )
		*out1 = data.intout[1];
	if( out2!=NULL )
		*out2 = data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 49:	objc_xfind																			*/
/*																										*/
/******************************************************************************/

int16 mt_objc_xfind( OBJECT *obj, const int16 start, const int16 depth,
				const int16 x, const int16 y, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {49, 4, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = start;
	data.intin[1] = depth;
	data.intin[2] = x;
	data.intin[3] = y;
	
	data.addrin[0] = obj;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	return data.intout[0];
}
