/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - GRAF-Bibliothek													*/
/*																										*/
/*	(c) 1998-2000 by Martin Els„sser															*/
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

/* šbertragen des contrl-Arrays */
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
/* AES 70:	graf_rubbox																			*/
/*																										*/
/******************************************************************************/

int16 mt_graf_rubbox( const int16 x, const int16 y, const int16 w_min,
				const int16 h_min, int16 *w_end, int16 *h_end, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {70, 4, 3, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fllen */
	data.intin[0] = x;
	data.intin[1] = y;
	data.intin[2] = w_min;
	data.intin[3] = h_min;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurckgeben */
	if( w_end!=NULL )
		*w_end = data.intout[1];
	if( h_end!=NULL )
		*h_end = data.intout[2];
		
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 70:	graf_rubberbox - anderer Name fr graf_rubbox							*/
/*																										*/
/******************************************************************************/

#undef mt_graf_rubberbox
int16 mt_graf_rubberbox( const int16 x, const int16 y, const int16 w_min,
				const int16 h_min, int16 *w_end, int16 *h_end, GlobalArray *globl )
{
	return mt_graf_rubbox(x, y, w_min, h_min, w_end, h_end, globl);
}

/******************************************************************************/
/*																										*/
/* AES 70:	graf_rubbbox - anderer Name fr graf_rubbox								*/
/*																										*/
/******************************************************************************/

#undef mt_graf_rubbbox
int16 mt_graf_rubbbox( const int16 x, const int16 y, const int16 w_min,
				const int16 h_min, int16 *w_end, int16 *h_end, GlobalArray *globl )
{
	return mt_graf_rubbox(x, y, w_min, h_min, w_end, h_end, globl);
}

/******************************************************************************/
/*																										*/
/* AES 71:	graf_dragbox																		*/
/*																										*/
/******************************************************************************/

int16 mt_graf_dragbox( const int16 w, const int16 h, const int16 sx, const int16 sy,
				const int16 xc, const int16 yc, const int16 wc, const int16 hc,
				int16 *x, int16 *y, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {71, 8, 3, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fllen */
	data.intin[0] = w;
	data.intin[1] = h;
	data.intin[2] = sx;
	data.intin[3] = sy;
	data.intin[4] = xc;
	data.intin[5] = yc;
	data.intin[6] = wc;
	data.intin[7] = hc;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurckgeben */
	if( x!=NULL )
		*x = data.intout[1];
	if( y!=NULL )
		*y = data.intout[2];
		
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 72:	graf_mbox																			*/
/*																										*/
/******************************************************************************/

int16 mt_graf_mbox( const int16 w, const int16 h, const int16 start_x, const int16 start_y,
				const int16 ende_x, const int16 ende_y, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {72, 6, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fllen */
	data.intin[0] = w;
	data.intin[1] = h;
	data.intin[2] = start_x;
	data.intin[3] = start_y;
	data.intin[4] = ende_x;
	data.intin[5] = ende_y;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 72:	graf_movebox - anderer Name fr graf_mbox									*/
/*																										*/
/******************************************************************************/

int16 mt_graf_movebox( const int16 w, const int16 h, const int16 start_x, int16 const start_y,
				const int16 ende_x, const int16 ende_y, GlobalArray *globl )
{
	return mt_graf_movebox(w, h, start_x, start_y, ende_x, ende_y, globl);
}

/******************************************************************************/
/*																										*/
/* AES 73:	graf_growbox																		*/
/*																										*/
/******************************************************************************/

int16 mt_graf_growbox( const int16 start_x, const int16 start_y, const int16 start_w,
				const int16 start_h, const int16 ende_x, const int16 ende_y, const int16 ende_w,
				const int16 ende_h, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {73, 8, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fllen */
	data.intin[0] = start_x;
	data.intin[1] = start_y;
	data.intin[2] = start_w;
	data.intin[3] = start_h;
	data.intin[4] = ende_x;
	data.intin[5] = ende_y;
	data.intin[6] = ende_w;
	data.intin[7] = ende_h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 74:	graf_shrinkbox																		*/
/*																										*/
/******************************************************************************/

int16 mt_graf_shrinkbox( const int16 start_x, const int16 start_y, const int16 start_w,
				const int16 start_h, const int16 ende_x, const int16 ende_y, const int16 ende_w,
				const int16 ende_h, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {74, 8, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fllen */
	data.intin[0] = start_x;
	data.intin[1] = start_y;
	data.intin[2] = start_w;
	data.intin[3] = start_h;
	data.intin[4] = ende_x;
	data.intin[5] = ende_y;
	data.intin[6] = ende_w;
	data.intin[7] = ende_h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 75:	graf_watchbox																		*/
/*																										*/
/******************************************************************************/

int16 mt_graf_watchbox( OBJECT *tree, const int16 obj_nr, const int16 instate,
				const int16 outstate, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {75, 4, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fllen */
	data.intin[0] = 0;
	data.intin[1] = obj_nr;
	data.intin[2] = instate;
	data.intin[3] = outstate;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 62:	graf_wwatchbox																		*/
/*																										*/
/******************************************************************************/

int16 mt_graf_wwatchbox( const OBJECT *gr_wptree, const int16 gr_wobject,
				const int16 gr_winstate, const int16 gr_woutstate, const int16 whandle,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {62, 4, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fllen */
	data.intin[0] = gr_wobject;
	data.intin[1] = gr_winstate;
	data.intin[2] = gr_woutstate;
	data.intin[3] = whandle;
	
	data.addrin[0] = gr_wptree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 76:	graf_slidebox																		*/
/*																										*/
/******************************************************************************/

int16 mt_graf_slidebox( OBJECT *tree, const int16 parent, const int16 obj_nr,
				const int16 isvert, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {76, 3, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fllen */
	data.intin[0] = parent;
	data.intin[1] = obj_nr;
	data.intin[2] = isvert;
	
	data.addrin[0] = tree;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 77:	graf_handle																			*/
/*																										*/
/******************************************************************************/

int16 mt_graf_handle( int16 *wchar, int16 *hchar, int16 *wbox, int16 *hbox,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {77, 0, 5, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurckgeben */
	if( wchar!=NULL )
		*wchar = data.intout[1];
	if( hchar!=NULL )
		*hchar = data.intout[2];
	if( wbox!=NULL )
		*wbox = data.intout[3];
	if( hbox!=NULL )
		*hbox = data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 77:	graf_xhandle																		*/
/*																										*/
/******************************************************************************/

int16 mt_graf_xhandle( int16 *wchar, int16 *hchar,	int16 *wbox, int16 *hbox, int16 *device,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {77, 0, 6, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;

	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( wchar!=NULL )
		*wchar = data.intout[1];
	if( hchar!=NULL )
		*hchar = data.intout[2];
	if( wbox!=NULL )
		*wbox = data.intout[3];
	if( hbox!=NULL )
		*hbox	= data.intout[4];
	if( device!=NULL )
		*device = data.intout[5];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 78:	graf_mouse																			*/
/*																										*/
/******************************************************************************/

int16 mt_graf_mouse( const int16 mouse_nr, MFORM *form, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {78, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;

	/* Die Arrays fllen */
	data.intin[0] = mouse_nr;
	
	data.addrin[0] = form;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 79:	graf_mkstate																		*/
/*																										*/
/******************************************************************************/

int16 mt_graf_mkstate( int16 *x, int16 *y, int16 *mstate, int16 *kstate, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {79, 0, 5, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;

	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( x!=NULL )
		*x = data.intout[1];
	if( y!=NULL )
		*y = data.intout[2];
	if( mstate!=NULL )
		*mstate = data.intout[3];
	if( kstate!=NULL )
		*kstate = data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 69:	graf_multirubber																	*/
/*																										*/
/******************************************************************************/

int16 mt_graf_multirubber( const int16 x, const int16 y, const int16 minw, const int16 minh,
				GRECT *rec, int16 *outw, int16 *outh, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {69, 4, 3, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;

	/* Die Arrays fllen */
	data.intin[0] = x;
	data.intin[1] = y;
	data.intin[2] = minw;
	data.intin[3] = minh;
	
	data.addrin[0] = rec;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte verteilen */
	if( outw!=NULL )
		*outw = data.intout[1];
	if( outh!=NULL )
		*outh = data.intout[2];
	
	return data.intout[0];
}
