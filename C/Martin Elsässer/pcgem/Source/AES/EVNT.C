/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - EVNT-Bibliothek													*/
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
/* Lokale Variablen																				*/
/*																										*/
/******************************************************************************/

/******************************************************************************/
/*																										*/
/* AES 20:	evnt_keybd																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 evnt_keybd( void )
#else
	INT16 evnt_keybd( GLOBAL *globl )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{20, 0, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 21:	evnt_button																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 evnt_button( INT16 ev_bclicks, UINT16 ev_bmask,
				UINT16 ev_bstate, INT16 *ev_bmx, INT16 *ev_bmy, INT16 *ev_bbutton,
				INT16 *ev_bkstate )
#else
	INT16 evnt_button( GLOBAL *globl, INT16 ev_bclicks, UINT16 ev_bmask,
				UINT16 ev_bstate, INT16 *ev_bmx, INT16 *ev_bmy, INT16 *ev_bbutton,
				INT16 *ev_bkstate )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{21, 3, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=ev_bclicks;
	data.intin[1]=ev_bmask;
	data.intin[2]=ev_bstate;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( ev_bmx!=NULL )
		*ev_bmx=data.intout[1];
	if( ev_bmy!=NULL )
		*ev_bmy=data.intout[2];
	if( ev_bbutton!=NULL )
		*ev_bbutton=data.intout[3];
	if( ev_bkstate!=NULL )
		*ev_bkstate=data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 22:	evnt_mouse																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 evnt_mouse( GLOBAL *globl, INT16 ev_moflags, Axywh *xywh,
			INT16 *ev_momx, INT16 *ev_momy, INT16 *ev_mobutton, INT16 *ev_mokstate )
{
	/* AES-Datenblock anlegen */
	AESData data={{22, 5, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=ev_moflags;
	data.intin[1]=xywh->x;
	data.intin[2]=xywh->y;
	data.intin[3]=xywh->w;
	data.intin[4]=xywh->h;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( ev_momx!=NULL )
		*ev_momx=data.intout[1];
	if( ev_momy!=NULL )
		*ev_momy=data.intout[2];
	if( ev_mobutton!=NULL )
		*ev_mobutton=data.intout[3];
	if( ev_mokstate!=NULL )
		*ev_mokstate=data.intout[4];
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 evnt_mouse( INT16 ev_moflags, INT16 ev_mox,
				INT16 ev_moy, INT16 ev_mowidth, INT16 ev_moheight,
				INT16 *ev_momx, INT16 *ev_momy, INT16 *ev_mobutton, INT16 *ev_mokstate )
#else
	INT16 evnt_mouse_( GLOBAL *globl, INT16 ev_moflags, INT16 ev_mox,
				INT16 ev_moy, INT16 ev_mowidth, INT16 ev_moheight,
				INT16 *ev_momx, INT16 *ev_momy, INT16 *ev_mobutton, INT16 *ev_mokstate )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{22, 5, 5, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=ev_moflags;
	data.intin[1]=ev_mox;
	data.intin[2]=ev_moy;
	data.intin[3]=ev_mowidth;
	data.intin[4]=ev_moheight;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( ev_momx!=NULL )
		*ev_momx=data.intout[1];
	if( ev_momy!=NULL )
		*ev_momy=data.intout[2];
	if( ev_mobutton!=NULL )
		*ev_mobutton=data.intout[3];
	if( ev_mokstate!=NULL )
		*ev_mokstate=data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 23:	evnt_mesag																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 evnt_mesag( INT16 *pbuff )
#else
	INT16 evnt_mesag( GLOBAL *globl, INT16 *pbuff )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{23, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=pbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 24:	evnt_timer																			*/
/*																										*/
/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 evnt_timer( GLOBAL *globl, UINT32 count )
{
	/* AES-Datenblock anlegen */
	AESData data={{24, 2, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	*(UINT32 *)&data.intin[1]=(count>0 ? count : 1);
	data.intin[0]=data.intin[2];
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 evnt_timer( INT16 ev_tlocount, INT16 ev_thicount )
#else
	INT16 evnt_timer_( GLOBAL *globl, INT16 ev_tlocount, INT16 ev_thicount )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{24, 2, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	if( ev_tlocount!=0 || ev_thicount!=0 )
	{
		data.intin[0]=ev_tlocount;
		data.intin[1]=ev_thicount;
	}
	else
	{
		data.intin[0]=1;
		data.intin[1]=0;
	}
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 25:	evnt_event & evnt_multi															*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 evnt_event( MultiEventIn *input, MultiEventOut *output )
#else
	INT16 evnt_event( GLOBAL *globl, MultiEventIn *input, MultiEventOut *output )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{25, 16, 7, 1, 0}};
	
	if( input==NULL || output==NULL )
		return 0;
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die "Arrays" fertig fÅllen */
	if( input->ev_mtcount==0 )
		input->ev_mtcount=1;
	input->reserved=(INT16)(input->ev_mtcount & 0xFFFF);
	
	data.addrin[0]=input->ev_mmgpbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, (INT16 *)input, (INT16 *)output, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	
	return input->reserved;
}

/******************************************************************************/

/* Funktion nur fÅr ACS-AES-Binding */
#ifndef __COMPATIBLE__

INT16 evnt_multi( GLOBAL *globl, INT16 ev_mflags, INT16 ev_mbclicks,
				INT16 ev_mbmask, INT16 ev_mbstate, INT16 ev_mm1flags,
				Axywh *xywh1, INT16 ev_mm2flags, Axywh *xywh2,
				INT16 *ev_mmgpbuff, UINT32 ev_mtcount, INT16 *ev_mmox, INT16 *ev_mmoy,
				INT16 *ev_mmbutton, INT16 *ev_mmokstate, INT16 *ev_mkreturn, INT16 *ev_mbreturn )
{
	/* AES-Datenblock anlegen */
	AESData data={{25, 16, 7, 1, 0}};
	
	/* Das globl-Array bestimmen */
	data.globl=(globl!=NULL ? globl : _globl);
	
	/* Die Arrays fÅllen */
	data.intin[0]=ev_mflags;
	data.intin[1]=ev_mbclicks;
	data.intin[2]=ev_mbmask;
	data.intin[3]=ev_mbstate;
	data.intin[4]=ev_mm1flags;
	data.intin[5]=(xywh1!=NULL ? xywh1->x : 0);
	data.intin[6]=(xywh1!=NULL ? xywh1->y : 0);
	data.intin[7]=(xywh1!=NULL ? xywh1->w : 0);
	data.intin[8]=(xywh1!=NULL ? xywh1->h : 0);
	data.intin[9]=ev_mm2flags;
	data.intin[10]=(xywh2!=NULL ? xywh2->x : 0);
	data.intin[11]=(xywh2!=NULL ? xywh2->y : 0);
	data.intin[12]=(xywh2!=NULL ? xywh2->w : 0);
	data.intin[13]=(xywh2!=NULL ? xywh2->h : 0);
	*(UINT32 *)&data.intin[15]=(ev_mtcount!=0 ? ev_mtcount : 1);
	data.intin[14]=data.intin[16];
	
	data.addrin[0]=ev_mmgpbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( ev_mmox!=NULL )
		*ev_mmox=data.intout[1];
	if( ev_mmoy!=NULL )
		*ev_mmoy=data.intout[2];
	if( ev_mmbutton!=NULL )
		*ev_mmbutton=data.intout[3];
	if( ev_mmokstate!=NULL )
		*ev_mmokstate=data.intout[4];
	if( ev_mkreturn!=NULL )
		*ev_mkreturn=data.intout[5];
	if( ev_mbreturn!=NULL )
		*ev_mbreturn=data.intout[6];
		
	return data.intout[0];
}

#endif

/******************************************************************************/

/* FÅr ACS-AES-Binding die abwÑrtskompatible Fkt., andernfalls die "richtige" */
#ifdef __COMPATIBLE__
	INT16 evnt_multi( INT16 ev_mflags, INT16 ev_mbclicks,
					INT16 ev_mbmask, INT16 ev_mbstate, INT16 ev_mm1flags,
					INT16 ev_mm1x, INT16 ev_mm1y, INT16 ev_mm1width,
					INT16 ev_mm1height, INT16 ev_mm2flags, INT16 ev_mm2x,
					INT16 ev_mm2y, INT16 ev_mm2width, INT16 ev_mm2height,
					INT16 *ev_mmgpbuff, INT16 ev_mtlocount, INT16 ev_mthicount,
					INT16 *ev_mmox, INT16 *ev_mmoy, INT16 *ev_mmbutton, INT16 *ev_mmokstate,
					INT16 *ev_mkreturn, INT16 *ev_mbreturn )
#else
	INT16 evnt_multi_( GLOBAL *globl, INT16 ev_mflags, INT16 ev_mbclicks,
					INT16 ev_mbmask, INT16 ev_mbstate, INT16 ev_mm1flags,
					INT16 ev_mm1x, INT16 ev_mm1y, INT16 ev_mm1width,
					INT16 ev_mm1height, INT16 ev_mm2flags, INT16 ev_mm2x,
					INT16 ev_mm2y, INT16 ev_mm2width, INT16 ev_mm2height,
					INT16 *ev_mmgpbuff, INT16 ev_mtlocount, INT16 ev_mthicount,
					INT16 *ev_mmox, INT16 *ev_mmoy, INT16 *ev_mmbutton, INT16 *ev_mmokstate,
					INT16 *ev_mkreturn, INT16 *ev_mbreturn )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{25, 16, 7, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=ev_mflags;
	data.intin[1]=ev_mbclicks;
	data.intin[2]=ev_mbmask;
	data.intin[3]=ev_mbstate;
	data.intin[4]=ev_mm1flags;
	data.intin[5]=ev_mm1x;
	data.intin[6]=ev_mm1y;
	data.intin[7]=ev_mm1width;
	data.intin[8]=ev_mm1height;
	data.intin[9]=ev_mm2flags;
	data.intin[10]=ev_mm2x;
	data.intin[11]=ev_mm2y;
	data.intin[12]=ev_mm2width;
	data.intin[13]=ev_mm2height;
	if( ev_mtlocount!=0 || ev_mthicount!=0 )
	{
		data.intin[14]=ev_mtlocount;
		data.intin[15]=ev_mthicount;
	}
	else
	{
		data.intin[14]=1;
		data.intin[15]=0;
	}
	
	data.addrin[0]=ev_mmgpbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( ev_mmox!=NULL )
		*ev_mmox=data.intout[1];
	if( ev_mmoy!=NULL )
		*ev_mmoy=data.intout[2];
	if( ev_mmbutton!=NULL )
		*ev_mmbutton=data.intout[3];
	if( ev_mmokstate!=NULL )
		*ev_mmokstate=data.intout[4];
	if( ev_mkreturn!=NULL )
		*ev_mkreturn=data.intout[5];
	if( ev_mbreturn!=NULL )
		*ev_mbreturn=data.intout[6];
		
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 26:	evnt_dclick																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 evnt_dclick( INT16 rate, INT16 setit )
#else
	INT16 evnt_dclick( GLOBAL *globl, INT16 rate, INT16 setit )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{26, 2, 1, 0, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=rate;
	data.intin[1]=setit;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

