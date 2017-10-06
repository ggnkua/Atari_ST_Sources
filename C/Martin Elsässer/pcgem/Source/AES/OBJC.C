/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - OBJC-Bibliothek													*/
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
/* AES 40:	objc_add																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 objc_add( OBJECT *tree, INT16 parent, INT16 child )
#else
	INT16 objc_add( GLOBAL *globl, OBJECT *tree, INT16 parent, INT16 child )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{40, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=parent;
	data.intin[1]=child;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 41:	objc_delete																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 objc_delete( OBJECT *tree, INT16 objnr )
#else
	INT16 objc_delete( GLOBAL *globl, OBJECT *tree, INT16 objnr )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{41, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=objnr;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 42:	objc_draw																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 objc_draw( GLOBAL *globl, OBJECT *tree, INT16 start, INT16 depth,
				Axywh *clip )
{
	/* AES-Datenblock anlegen */
	AESData data={{42, 6, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=start;
	data.intin[1]=depth;
	data.intin[2]=clip->x;
	data.intin[3]=clip->y;
	data.intin[4]=clip->w;
	data.intin[5]=clip->h;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 objc_draw( OBJECT *tree, INT16 start, INT16 depth,
					INT16 xclip, INT16 yclip, INT16 wclip, INT16 hclip )
#else
	INT16 objc_draw_( GLOBAL *globl, OBJECT *tree, INT16 start, INT16 depth,
					INT16 xclip, INT16 yclip, INT16 wclip, INT16 hclip )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{42, 6, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=start;
	data.intin[1]=depth;
	data.intin[2]=xclip;
	data.intin[3]=yclip;
	data.intin[4]=wclip;
	data.intin[5]=hclip;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 42:	objc_wdraw																			*/
/*																										*/
/******************************************************************************/

/* Aus CAT-Bibliothek geholt... */

/******************************************************************************/
/*																										*/
/* AES 43:	objc_find																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 objc_find( OBJECT *tree, INT16 start, INT16 depth,
					INT16 mx, INT16 my )
#else
	INT16 objc_find( GLOBAL *globl, OBJECT *tree, INT16 start, INT16 depth,
					INT16 mx, INT16 my )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{43, 4, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=start;
	data.intin[1]=depth;
	data.intin[2]=mx;
	data.intin[3]=my;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 44:	objc_offset																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 objc_offset( OBJECT *tree, INT16 objnr, INT16 *x, INT16 *y )
#else
	INT16 objc_offset( GLOBAL *globl, OBJECT *tree, INT16 objnr, INT16 *x, INT16 *y )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{44, 1, 3, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=objnr;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( x!=NULL )
		*x=data.intout[1];
	if( y!=NULL )
		*y=data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 45:	objc_order																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 objc_order( OBJECT *tree, INT16 objnr, INT16 new_nr )
#else
	INT16 objc_order( GLOBAL *globl, OBJECT *tree, INT16 objnr, INT16 new_nr )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{45, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=objnr;
	data.intin[1]=new_nr;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 46:	objc_edit																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 objc_edit( OBJECT *tree, INT16 objnr, INT16 inchar,
					INT16 *idx, INT16 kind )
#else
	INT16 objc_edit( GLOBAL *globl, OBJECT *tree, INT16 objnr, INT16 inchar,
					INT16 *idx, INT16 kind )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{46, 4, 2, 1, 0}};
	
	/* SicherheitsprÅfung */
	if( idx==NULL )
		return 0;
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=objnr;
	data.intin[1]=inchar;
	data.intin[2]=*idx;
	data.intin[3]=kind;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Wert zurÅckgeben */
	*idx=data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 46:	objc_wedit																			*/
/*																										*/
/******************************************************************************/

/* Aus CAT-Bibliothek geholt ... */

/******************************************************************************/
/*																										*/
/* AES 47:	objc_change																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 objc_change( GLOBAL *globl, OBJECT *tree, INT16 objnr,
				Axywh *clip, INT16 newstate, INT16 redraw )
{
	/* AES-Datenblock anlegen */
	AESData data={{47, 8, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=objnr;
	data.intin[1]=0;
	data.intin[2]=clip->x;
	data.intin[3]=clip->y;
	data.intin[4]=clip->w;
	data.intin[5]=clip->h;
	data.intin[6]=newstate;
	data.intin[7]=(redraw ? 1 : 0);
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__

	#pragma warn -par
	
	INT16 objc_change( OBJECT *tree, INT16 objnr, INT16 reserved, 
					INT16 xclip, INT16 yclip, INT16 wclip, INT16 hclip,
					INT16 newstate, INT16 redraw )
#else
	INT16 objc_change_( GLOBAL *globl, OBJECT *tree, INT16 objnr,
					INT16 xclip, INT16 yclip, INT16 wclip, INT16 hclip,
					INT16 newstate, INT16 redraw )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{47, 8, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=objnr;
	data.intin[1]=0;
	data.intin[2]=xclip;
	data.intin[3]=yclip;
	data.intin[4]=wclip;
	data.intin[5]=hclip;
	data.intin[6]=newstate;
	data.intin[7]=(redraw ? 1 : 0);
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#ifdef __COMPATIBLE__
	#pragma warn -par
#endif

/******************************************************************************/
/*																										*/
/* AES 47:	objc_wchange																		*/
/*																										*/
/******************************************************************************/

/* Aus CAT-Bibliothek ... */

/******************************************************************************/
/*																										*/
/* AES 48:	objc_sysvar																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 objc_sysvar( INT16 mode, INT16 which, INT16 in1, INT16 in2,
					INT16 *out1, INT16 *out2 )
#else
	INT16 objc_sysvar( GLOBAL *globl, INT16 mode, INT16 which, INT16 in1, INT16 in2,
					INT16 *out1, INT16 *out2 )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{48, 4, 3, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=mode;
	data.intin[1]=which;
	data.intin[2]=in1;
	data.intin[3]=in2;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	if( out1!=NULL )
		*out1=data.intout[1];
	if( out2!=NULL )
		*out2=data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 47:	objc_xfind																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 objc_xfind( OBJECT *obj, INT16 start, INT16 depth, INT16 x, INT16 y )
#else
	INT16 objc_xfind( GLOBAL *globl, OBJECT *obj, INT16 start, INT16 depth, INT16 x, INT16 y )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{49, 4, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
    _GemParBlk.addrin[0] = obj;
    _GemParBlk.intin[0]  = start;
    _GemParBlk.intin[1]  = depth;
    _GemParBlk.intin[2]  = x;
    _GemParBlk.intin[3]  = y;
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

