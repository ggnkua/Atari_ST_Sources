/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - GRAF-Bibliothek													*/
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
/* AES 70:	graf_rubbox																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_rubbox( INT16 x, INT16 y, INT16 w_min,
					INT16 h_min, INT16 *w_end, INT16 *h_end )
#else
	INT16 graf_rubbox( GLOBAL *globl, INT16 x, INT16 y, INT16 w_min,
					INT16 h_min, INT16 *w_end, INT16 *h_end )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{70, 4, 3, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=x;
	data.intin[1]=y;
	data.intin[2]=w_min;
	data.intin[3]=h_min;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( w_end!=NULL )
		*w_end=data.intout[1];
	if( h_end!=NULL )
		*h_end=data.intout[2];
		
	return data.intout[0];
}

/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_rubberbox( INT16 x, INT16 y, INT16 w_min,
					INT16 h_min, INT16 *w_end, INT16 *h_end )
#else
	INT16 graf_rubberbox( GLOBAL *globl, INT16 x, INT16 y, INT16 w_min,
					INT16 h_min, INT16 *w_end, INT16 *h_end )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{70, 4, 3, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=x;
	data.intin[1]=y;
	data.intin[2]=w_min;
	data.intin[3]=h_min;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( w_end!=NULL )
		*w_end=data.intout[1];
	if( h_end!=NULL )
		*h_end=data.intout[2];
		
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 71:	graf_dragbox																		*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 graf_dragbox( GLOBAL *globl, Axywh *start, Axywh *max, INT16 *x, INT16 *y )
{
	/* AES-Datenblock anlegen */
	AESData data={{71, 8, 3, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=start->w;
	data.intin[1]=start->h;
	data.intin[2]=start->x;
	data.intin[3]=start->y;
	data.intin[4]=max->x;
	data.intin[5]=max->y;
	data.intin[6]=max->w;
	data.intin[7]=max->h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( x!=NULL )
		*x=data.intout[1];
	if( y!=NULL )
		*y=data.intout[2];
		
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 graf_dragbox( INT16 w, INT16 h, INT16 sx,
					INT16 sy, INT16 xc, INT16 yc, INT16 wc, INT16 hc,
					INT16 *x, INT16 *y )
#else
	INT16 graf_dragbox_( GLOBAL *globl, INT16 w, INT16 h, INT16 sx,
					INT16 sy, INT16 xc, INT16 yc, INT16 wc, INT16 hc,
					INT16 *x, INT16 *y )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{71, 8, 3, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=w;
	data.intin[1]=h;
	data.intin[2]=sx;
	data.intin[3]=sy;
	data.intin[4]=xc;
	data.intin[5]=yc;
	data.intin[6]=wc;
	data.intin[7]=hc;
	
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
/* AES 72:	graf_mbox																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_mbox( INT16 w, INT16 h, INT16 start_x,
					INT16 start_y, INT16 ende_x, INT16 ende_y )
#else
	INT16 graf_mbox( GLOBAL *globl, INT16 w, INT16 h, INT16 start_x,
					INT16 start_y, INT16 ende_x, INT16 ende_y )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{72, 6, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=w;
	data.intin[1]=h;
	data.intin[2]=start_x;
	data.intin[3]=start_y;
	data.intin[4]=ende_x;
	data.intin[5]=ende_y;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_movebox( INT16 w, INT16 h, INT16 start_x,
					INT16 start_y, INT16 ende_x, INT16 ende_y )
#else
	INT16 graf_movebox( GLOBAL *globl, INT16 w, INT16 h, INT16 start_x,
					INT16 start_y, INT16 ende_x, INT16 ende_y )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{72, 6, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=w;
	data.intin[1]=h;
	data.intin[2]=start_x;
	data.intin[3]=start_y;
	data.intin[4]=ende_x;
	data.intin[5]=ende_y;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 73:	graf_growbox																		*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 graf_growbox( GLOBAL *globl, Axywh *start, Axywh *ende )
{
	/* AES-Datenblock anlegen */
	AESData data={{73, 8, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=start->x;
	data.intin[1]=start->y;
	data.intin[2]=start->w;
	data.intin[3]=start->h;
	data.intin[4]=ende->x;
	data.intin[5]=ende->y;
	data.intin[6]=ende->w;
	data.intin[7]=ende->h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 graf_growbox( INT16 start_x, INT16 start_y,
					INT16 start_w, INT16 start_h, INT16 ende_x,
					INT16 ende_y, INT16 ende_w, INT16 ende_h )
#else
	INT16 graf_growbox_( GLOBAL *globl, INT16 start_x, INT16 start_y,
					INT16 start_w, INT16 start_h, INT16 ende_x,
					INT16 ende_y, INT16 ende_w, INT16 ende_h )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{73, 8, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=start_x;
	data.intin[1]=start_y;
	data.intin[2]=start_w;
	data.intin[3]=start_h;
	data.intin[4]=ende_x;
	data.intin[5]=ende_y;
	data.intin[6]=ende_w;
	data.intin[7]=ende_h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 74:	graf_shrinkbox																		*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 graf_shrinkbox( GLOBAL *globl, Axywh *start, Axywh *ende )
{
	/* AES-Datenblock anlegen */
	AESData data={{74, 8, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=start->x;
	data.intin[1]=start->y;
	data.intin[2]=start->w;
	data.intin[3]=start->h;
	data.intin[4]=ende->x;
	data.intin[5]=ende->y;
	data.intin[6]=ende->w;
	data.intin[7]=ende->h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 graf_shrinkbox( INT16 start_x, INT16 start_y,
					INT16 start_w, INT16 start_h, INT16 ende_x,
					INT16 ende_y, INT16 ende_w, INT16 ende_h )
#else
	INT16 graf_shrinkbox_( GLOBAL *globl, INT16 start_x, INT16 start_y,
					INT16 start_w, INT16 start_h, INT16 ende_x,
					INT16 ende_y, INT16 ende_w, INT16 ende_h )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{74, 8, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=start_x;
	data.intin[1]=start_y;
	data.intin[2]=start_w;
	data.intin[3]=start_h;
	data.intin[4]=ende_x;
	data.intin[5]=ende_y;
	data.intin[6]=ende_w;
	data.intin[7]=ende_h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 75:	graf_watchbox																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_watchbox( OBJECT *tree, INT16 obj_nr,
					INT16 instate, INT16 outstate )
#else
	INT16 graf_watchbox( GLOBAL *globl, OBJECT *tree, INT16 obj_nr,
					INT16 instate, INT16 outstate )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{75, 4, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=0;
	data.intin[1]=obj_nr;
	data.intin[2]=instate;
	data.intin[3]=outstate;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 76:	graf_wwatchbox																		*/
/*																										*/
/******************************************************************************/

/* Aus CAT-Bibliothek geholt... */

/******************************************************************************/
/*																										*/
/* AES 76:	graf_slidebox																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_slidebox( OBJECT *tree, INT16 parent,
					INT16 obj_nr, INT16 isvert )
#else
	INT16 graf_slidebox( GLOBAL *globl, OBJECT *tree, INT16 parent,
					INT16 obj_nr, INT16 isvert )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{76, 3, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=0;
	data.intin[1]=parent;
	data.intin[2]=obj_nr;
	data.intin[3]=isvert;
	
	data.addrin[0]=tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 77:	graf_handle																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_handle( INT16 *wchar, INT16 *hchar, INT16 *wbox, INT16 *hbox )
#else
	INT16 graf_handle( GLOBAL *globl, INT16 *wchar, INT16 *hchar, INT16 *wbox, INT16 *hbox )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{77, 0, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( wchar!=NULL )
		*wchar=data.intout[1];
	if( hchar!=NULL )
		*hchar=data.intout[2];
	if( wbox!=NULL )
		*wbox=data.intout[3];
	if( hbox!=NULL )
		*hbox=data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 78:	graf_mouse																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_mouse( INT16 mouse_nr, MFORM *form )
#else
	INT16 graf_mouse( GLOBAL *globl, INT16 mouse_nr, MFORM *form )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{78, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif

	/* Die Arrays fÅllen */
	data.intin[0]=mouse_nr;
	
	data.addrin[0]=form;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 79:	graf_mkstate																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_mkstate( INT16 *x, INT16 *y, INT16 *mstate, INT16 *kstate )
#else
	INT16 graf_mkstate( GLOBAL *globl, INT16 *x, INT16 *y, INT16 *mstate, INT16 *kstate )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{79, 0, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif

	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( x!=NULL )
		*x=data.intout[1];
	if( y!=NULL )
		*y=data.intout[2];
	if( mstate!=NULL )
		*mstate=data.intout[3];
	if( kstate!=NULL )
		*kstate=data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 69:	graf_mkstate																		*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 graf_multirubber( INT16 x, INT16 y, INT16 minw, INT16 minh, Axywh *rec,
					INT16 *outw, INT16 *outh )
#else
	INT16 graf_multirubber( GLOBAL *globl, INT16 x, INT16 y, INT16 minw, INT16 minh,
					Axywh *rec, INT16 *outw, INT16 *outh )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{69, 4, 3, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif

	/* Die Arrays fÅllen */
	data.intin[0] = x;
	data.intin[1] = y;
	data.intin[2] = minw;
	data.intin[3] = minh;
	
	data.addrin[0] = rec;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( outw!=NULL )
		*outw=data.intout[1];
	if( outh!=NULL )
		*outh=data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 79:	graf_xhandle																		*/
/*																										*/
/******************************************************************************/

/* Aus CAT-Bibliothek geholt... */
