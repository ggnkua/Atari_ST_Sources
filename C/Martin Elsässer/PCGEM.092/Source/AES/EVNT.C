/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - EVNT-Bibliothek													*/
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
/* AES 20:	evnt_keybd																			*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_keybd( GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {20, 0, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 21:	evnt_button																			*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_button( const int16 ev_bclicks, const uint16 ev_bmask,
				const uint16 ev_bstate, int16 *ev_bmx, int16 *ev_bmy, int16 *ev_bbutton,
				int16 *ev_bkstate, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {21, 3, 5, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = ev_bclicks;
	data.intin[1] = ev_bmask;
	data.intin[2] = ev_bstate;
	
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
/* AES 21:	evnt_xbutton - Erweiterung um Wheels gem. TORG 105						*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_xbutton( const int16 ev_bclicks, const uint16 ev_bmask,
				const uint16 ev_bstate, int16 *ev_bmx, int16 *ev_bmy, int16 *ev_bbutton,
				int16 *ev_bkstate, int16 *ev_bwhlpbuff, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {21, 3, 5, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = ev_bclicks;
	data.intin[1] = ev_bmask;
	data.intin[2] = ev_bstate;
	
	data.addrin[0] = ev_bwhlpbuff;
	
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

int16 mt_evnt_mouse( const int16 ev_moflags, const int16 ev_mox, const int16 ev_moy,
				const int16 ev_mowidth, const int16 ev_moheight, int16 *ev_momx, int16 *ev_momy,
				int16 *ev_mobutton, int16 *ev_mokstate, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {22, 5, 5, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = ev_moflags;
	data.intin[1] = ev_mox;
	data.intin[2] = ev_moy;
	data.intin[3] = ev_mowidth;
	data.intin[4] = ev_moheight;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( ev_momx!=NULL )
		*ev_momx = data.intout[1];
	if( ev_momy!=NULL )
		*ev_momy = data.intout[2];
	if( ev_mobutton!=NULL )
		*ev_mobutton = data.intout[3];
	if( ev_mokstate!=NULL )
		*ev_mokstate = data.intout[4];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 23:	evnt_mesag																			*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_mesag( int16 *pbuff, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {23, 0, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = pbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 24:	evnt_timer																			*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_timer( const uint32 count, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {24, 2, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	*(uint32 *)&data.intin[1] = (count>0 ? count : 1);
	data.intin[0] = data.intin[2];
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 25:	evnt_multi																			*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_multi( const int16 ev_mflags, const int16 ev_mbclicks, const int16 ev_mbmask,
				const int16 ev_mbstate, const int16 ev_mm1flags, const int16 ev_mm1x,
				const int16 ev_mm1y, const int16 ev_mm1width, const int16 ev_mm1height,
				const int16 ev_mm2flags, const int16 ev_mm2x, const int16 ev_mm2y,
				const int16 ev_mm2width, const int16 ev_mm2height, int16 *ev_mmgpbuff,
				const int32 ev_mtimer, int16 *ev_mmox, int16 *ev_mmoy, int16 *ev_mmbutton,
				int16 *ev_mmokstate, int16 *ev_mkreturn, int16 *ev_mbreturn, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {25, 16, 7, 1, 0};
	ConvInt32To2Int16 tmp;
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0]  = ev_mflags;
	data.intin[1]  = ev_mbclicks;
	data.intin[2]  = ev_mbmask;
	data.intin[3]  = ev_mbstate;
	data.intin[4]  = ev_mm1flags;
	data.intin[5]  = ev_mm1x;
	data.intin[6]  = ev_mm1y;
	data.intin[7]  = ev_mm1width;
	data.intin[8]  = ev_mm1height;
	data.intin[9]  = ev_mm2flags;
	data.intin[10] = ev_mm2x;
	data.intin[11] = ev_mm2y;
	data.intin[12] = ev_mm2width;
	data.intin[13] = ev_mm2height;
	if( ev_mtimer!=0 )
	{
		tmp.val32 = ev_mtimer;
		data.intin[14] = tmp.val16.lowWord;
		data.intin[15] = tmp.val16.highWord;
		/*
		data.intin[14] = (int16)(ev_mtimer & 0xFFFF);
		data.intin[15] = (int16)((ev_mtimer>>16) & 0xFFFF);
		*/
	}
	else
	{
		data.intin[14] = 1;
		data.intin[15] = 0;
	}
	
	data.addrin[0] = ev_mmgpbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( ev_mmox!=NULL )
		*ev_mmox = data.intout[1];
	if( ev_mmoy!=NULL )
		*ev_mmoy = data.intout[2];
	if( ev_mmbutton!=NULL )
		*ev_mmbutton = data.intout[3];
	if( ev_mmokstate!=NULL )
		*ev_mmokstate = data.intout[4];
	if( ev_mkreturn!=NULL )
		*ev_mkreturn = data.intout[5];
	if( ev_mbreturn!=NULL )
		*ev_mbreturn = data.intout[6];
		
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 25:	evnt_xmulti - Erweiterung von evnt_multi um Wheels gem. TORG 105	*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_xmulti( const int16 ev_mflags, const int16 ev_mbclicks, const int16 ev_mbmask,
				const int16 ev_mbstate, const int16 ev_mm1flags, const int16 ev_mm1x,
				const int16 ev_mm1y, const int16 ev_mm1width, const int16 ev_mm1height,
				const int16 ev_mm2flags, const int16 ev_mm2x, const int16 ev_mm2y,
				const int16 ev_mm2width, const int16 ev_mm2height, int16 *ev_mmgpbuff,
				const int32 ev_mtimer, int16 *ev_mmox, int16 *ev_mmoy, int16 *ev_mmbutton,
				int16 *ev_mmokstate, int16 *ev_mkreturn, int16 *ev_mbreturn, int16 *ev_mwhlpbuff,
				GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {25, 16, 7, 1, 0};
	ConvInt32To2Int16 tmp;
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0]  = ev_mflags;
	data.intin[1]  = ev_mbclicks;
	data.intin[2]  = ev_mbmask;
	data.intin[3]  = ev_mbstate;
	data.intin[4]  = ev_mm1flags;
	data.intin[5]  = ev_mm1x;
	data.intin[6]  = ev_mm1y;
	data.intin[7]  = ev_mm1width;
	data.intin[8]  = ev_mm1height;
	data.intin[9]  = ev_mm2flags;
	data.intin[10] = ev_mm2x;
	data.intin[11] = ev_mm2y;
	data.intin[12] = ev_mm2width;
	data.intin[13] = ev_mm2height;
	if( ev_mtimer!=0 )
	{
		tmp.val32 = ev_mtimer;
		data.intin[14] = tmp.val16.lowWord;
		data.intin[15] = tmp.val16.highWord;
		/*
		data.intin[14] = (int16)(ev_mtimer & 0xFFFF);
		data.intin[15] = (int16)((ev_mtimer>>16) & 0xFFFF);
		*/
	}
	else
	{
		data.intin[14] = 1;
		data.intin[15] = 0;
	}
	
	data.addrin[0] = ev_mmgpbuff;
	if( ev_mwhlpbuff!=NULL )
	{
		data.addrin[1] = ev_mwhlpbuff;
		data.contrl[3]++;
	}
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	if( ev_mmox!=NULL )
		*ev_mmox = data.intout[1];
	if( ev_mmoy!=NULL )
		*ev_mmoy = data.intout[2];
	if( ev_mmbutton!=NULL )
		*ev_mmbutton = data.intout[3];
	if( ev_mmokstate!=NULL )
		*ev_mmokstate = data.intout[4];
	if( ev_mkreturn!=NULL )
		*ev_mkreturn = data.intout[5];
	if( ev_mbreturn!=NULL )
		*ev_mbreturn = data.intout[6];
		
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 25:	evnt_event 																			*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_event( MultiEventIn *input, MultiEventOut *output, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {25, 16, 7, 2, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	if( input==NULL || output==NULL )
		return 0;
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die "Arrays" fertig fÅllen */
	if( input->ev_mtcount==0 )
		input->ev_mtcount = 1;
	input->reserved = (int16)(input->ev_mtcount & 0xFFFF);
	
	data.addrin[0] = input->ev_mmgpbuff;
	data.addrin[1] = input->ev_mwhlpbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, (int16 *)input, (int16 *)output, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	return input->reserved;
}

/******************************************************************************/
/*																										*/
/* AES 25:	EvntMulti																			*/
/*																										*/
/******************************************************************************/

int16 mt_EvntMulti( EVENT *evnt_data, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {25, 16, 7, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	if( evnt_data==NULL )
		return 0;
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = evnt_data->ev_mmgpbuf;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, &evnt_data->ev_mflags, &evnt_data->ev_mwich, 
		data.addrin, data.addrout);
	
	return evnt_data->ev_mwich;
}

/******************************************************************************/
/*																										*/
/* AES 26:	evnt_dclick																			*/
/*																										*/
/******************************************************************************/

int16 mt_evnt_dclick( const int16 rate, const int16 setit, GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {26, 2, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = rate;
	data.intin[1] = setit;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}
