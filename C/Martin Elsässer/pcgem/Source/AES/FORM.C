/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - FORM-Bibliothek													*/
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
/* AES 50:	form_do																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 form_do( OBJECT *tree, INT16 start )
#else
	INT16 form_do( GLOBAL *globl, OBJECT *tree, INT16 start )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{50, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=start;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 51:	form_dial																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 form_dial( GLOBAL *globl, INT16 flag, Axywh *little, Axywh *big )
{
	/* AES-Datenblock anlegen */
	AESData data={{51, 9, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=flag;
	data.intin[1]=little->x;
	data.intin[2]=little->y;
	data.intin[3]=little->w;
	data.intin[4]=little->h;
	data.intin[5]=big->x;
	data.intin[6]=big->y;
	data.intin[7]=big->w;
	data.intin[8]=big->h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 form_dial( INT16 flag, INT16 xlittle,
					INT16 ylittle, INT16 wlittle, INT16 hlittle,
					INT16 xbig, INT16 ybig, INT16 wbig, INT16 hbig )
#else
	INT16 form_dial_( GLOBAL *globl, INT16 flag, INT16 xlittle,
					INT16 ylittle, INT16 wlittle, INT16 hlittle,
					INT16 xbig, INT16 ybig, INT16 wbig, INT16 hbig )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{51, 9, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=flag;
	data.intin[1]=xlittle;
	data.intin[2]=ylittle;
	data.intin[3]=wlittle;
	data.intin[4]=hlittle;
	data.intin[5]=xbig;
	data.intin[6]=ybig;
	data.intin[7]=wbig;
	data.intin[8]=hbig;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 52:	form_alert																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 form_alert( INT16 defbutton, char *string )
#else
	INT16 form_alert( GLOBAL *globl, INT16 defbutton, char *string )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{52, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=defbutton;
	
	data.addrin[0]=string;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 53:	form_error																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 form_error( INT16 errnum )
#else
	INT16 form_error( GLOBAL *globl, INT16 errnum )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{53, 1, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=(errnum<0 ? (~errnum)-30 : errnum);
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 54:	form_center																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 form_center( GLOBAL *globl, OBJECT *tree, Axywh *xywh )
{
	/* AES-Datenblock anlegen */
	AESData data={{54, 0, 5, 1, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	if( xywh!=NULL )
	{
		xywh->x=data.intout[1];
		xywh->y=data.intout[2];
		xywh->w=data.intout[3];
		xywh->h=data.intout[4];
	}
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 form_center( OBJECT *tree, INT16 *x, INT16 *y, INT16 *w, INT16 *h )
#else
	INT16 form_center_( GLOBAL *globl, OBJECT *tree,
					INT16 *x, INT16 *y, INT16 *w, INT16 *h )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{54, 0, 5, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	if( x!=NULL )
		*x=data.intout[1];
	if( y!=NULL )
		*y=data.intout[2];
	if( w!=NULL )
		*w=data.intout[3];
	if( h!=NULL )
		*h=data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 55:	form_keybd																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 form_keybd( OBJECT *tree, INT16 obj, INT16 next,
					INT16 input_char, INT16 *next_obj, INT16 *pchar )
#else
	INT16 form_keybd( GLOBAL *globl, OBJECT *tree, INT16 obj, INT16 next,
					INT16 input_char, INT16 *next_obj, INT16 *pchar )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{55, 3, 3, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=obj;
	data.intin[1]=input_char;
	data.intin[2]=next;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	if( next_obj!=NULL )
		*next_obj=data.intout[1];
	if( pchar!=NULL )
		*next_obj=data.intout[2];
	
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

#ifdef __COMPATIBLE__
	INT16 form_button( OBJECT *tree, INT16 obj,
					INT16 clicks, INT16 *next_obj )
#else
	INT16 form_button( GLOBAL *globl, OBJECT *tree, INT16 obj,
					INT16 clicks, INT16 *next_obj )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{56, 2, 2, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=obj;
	data.intin[1]=clicks;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Werte zurÅckgeben */
	if( next_obj!=NULL )
		*next_obj=data.intout[1];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 135:	form_popup																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 form_popup( OBJECT *tree, INT16 x, INT16 y)
#else
	INT16 form_popup( GLOBAL *globl, OBJECT *tree, INT16 x, INT16 y)
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{135, 2, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0] = x;
	data.intin[1] = y;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}


/******************************************************************************/
/*																										*/
/* AES 63:	form_wbutton																			*/
/*																										*/
/******************************************************************************/

/* Weiû der Henker, was das ist, steht in der CAT_Bibliothek so drin... */

/******************************************************************************/
/*																										*/
/* AES 51:	form_xdial																			*/
/*																										*/
/******************************************************************************/

/* Weiû der Henker, was das ist, steht in der CAT_Bibliothek so drin... */

/******************************************************************************/
/*																										*/
/* AES 50:	form_xdo																			*/
/*																										*/
/******************************************************************************/

/* Weiû der Henker, was das ist, steht in der CAT_Bibliothek so drin... */

/******************************************************************************/
/*																										*/
/* AES 136:	form_xerr																			*/
/*																										*/
/******************************************************************************/

/* Weiû der Henker, was das ist, steht in der CAT_Bibliothek so drin... */

