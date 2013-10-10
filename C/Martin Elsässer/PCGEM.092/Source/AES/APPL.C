/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - APPL-Bibliothek													*/
/*																										*/
/*	(c) 1998-2003 by Martin ElsÑsser															*/
/******************************************************************************/

#include <ACSAES.H>
#include <String.H>
#ifndef C_MagX
	#include <ACSCook.H>
#endif

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
	int16 intin[16];
	int16 intout[7];
	void *addrin[5];
	void *addrout[1];
} AESData;

/******************************************************************************/

/* Struktur des Cookies 'AFnt' (AES Font Loader) */
typedef struct
{
	int32 af_magic;
	int16 version;
	int16 installed;
	int16 cdecl (*afnt_getinfo )( const int16 af_gtype, int16 *af_gout1,
						int16 *af_gout2, int16 *af_gout3, int16 *af_gout4 );
} SGAFNT;

/******************************************************************************/
/*																										*/
/* AES 10:	appl_init																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_init( GlobalArray *globl )
{
	/* AES-Datenblock anlegen */
	static int16 contrl[] = {10, 0, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Das globl-Array initialisieren                         */
	/* - damit kann festgestellt werden, ob AES schon da sind */
	memset(data.globl, 0, sizeof(*data.globl));
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 11:	appl_read																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_read( const int16 rwid, const int16 length, void *pbuff, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {11, 2, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = rwid;
	data.intin[1] = length;
	
	data.addrin[0] = pbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 12:	appl_write																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_write( const int16 rwid, const int16 length, void *pbuff, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {12, 2, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = rwid;
	data.intin[1] = length;
	
	data.addrin[0] = pbuff;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 13:	appl_find																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_find( char *pname, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {13, 0, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.addrin[0] = pname;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 14:	appl_tplay																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_tplay( APPLRECORD *tbuffer, const int16 tlength, const int16 tscale,
				GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {14, 2, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = tlength;
	data.intin[1] = tscale;
	
	data.addrin[0] = tbuffer;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 15:	appl_trecord																		*/
/*																										*/
/******************************************************************************/

int16 mt_appl_trecord( APPLRECORD *tbuffer, const int16 tlength, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {15, 1, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = tlength;
	
	data.addrin[0] = tbuffer;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 16:	appl_bvset																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_bvset( const uint16 bvdisk, const uint16 bvhard, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {16, 2, 1, 0, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = bvdisk;
	data.intin[1] = bvhard;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 17:	appl_yield																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_yield( GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {17, 0, 1, 0, 0};
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
/* AES 18:	appl_search																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_search( const int16 mode, char *fname, int16 *type, int16 *ap_id, GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {18, 1, 3, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl = globl;
	
	/* Die Arrays fÅllen */
	data.intin[0] = mode;
	
	data.addrin[0] = fname;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	if( type!=NULL )
		*type = data.intout[1];
	if( ap_id!=NULL )
		*ap_id = data.intout[2];
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 19:	appl_exit																			*/
/*																										*/
/******************************************************************************/

int16 mt_appl_exit( GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {19, 0, 1, 0, 0};
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
/* AES 130:	appl_getinfo																		*/
/*																										*/
/******************************************************************************/

int16 mt_appl_getinfo( const int16 type, int16 *out1, int16 *out2, int16 *out3, int16 *out4,
				GlobalArray *globl )
{
	/* UnterstÅtzt das System appl_getinfo? */
	static int16 hasInfo = -1;
	static int32 pmmu = 1;
	
	/* Ggf. prÅfen, ob appl_getinfo vorhanden ist */
	if( hasInfo<0 )
	{
		MAGX_COOKIE *cookie;
		
		if( globl->ap_version>0x400
				|| (type<4 && globl->ap_version==0x400)
				|| (mt_appl_find("?AGI", globl)>=0)
				|| (globl->ap_version==0x399 && Ash_getcookie(C_MagX, &cookie)
					&& cookie->aesvars->version>=0 )
				|| (mt_wind_get(0, WF_WINX, NULL, NULL, NULL, NULL, globl)==WF_WINX) )
			hasInfo = 1;
		else
			hasInfo = 0;
		
		/* Auch die PMMU-Features sind wichtig (Speicherschutz!) */
		pmmu = Ssystem(S_OSFEATURES, 0, 0);
		if( pmmu==EINVFN )
			pmmu = 0;
	}
	
	/* Falls vorhanden, appl_getinfo aufrufen */
	if( hasInfo )
	{
		/* contrl anlegen */
		static int16 contrl[] = {130, 1, 5, 0, 0};
		AESData data;
		
		/* Das contrl-Array initialisieren */
		CTRLCPY(data.contrl, contrl);
		
		/* Das globl-Array eintragen */
		data.globl = globl;
		
		/* Die Arrays fÅllen */
		data.intin[0] = type;
		
		/* Ab in die AES... */
		aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
		
		/* Die Werte zurÅckgeben */
		if( out1!=NULL )
			*out1 = data.intout[1];
		if( out2!=NULL )
			*out2 = data.intout[2];
		if( out3!=NULL )
			*out3 = data.intout[3];
		if( out4!=NULL )
			*out4 = data.intout[4];
		
		return data.intout[0];
	}
	else
	{
		/* Die Variante Åber den AES Font Loader (Cookie 'AFnt') versuchen, */
		/* auûer wenn Speicherschutz aktiviert ist (momentan nur in MiNT)   */
		if( (type==0 || type==1) && !(pmmu & 1) )
		{
			SGAFNT *afnt;
			if( (Ash_getcookie(C_AFnt, &afnt)) && (afnt->af_magic=='AFnt') )
				return (afnt->afnt_getinfo)(type, out1, out2, out3, out4);
		}
	}
	
	return FALSE;
}

/******************************************************************************/
/*																										*/
/* AES 130:	appl_getinfo_str																	*/
/*																										*/
/******************************************************************************/

int16 mt_appl_getinfo_str( const int16 type, char *str1, char *str2, char *str3, char *str4,
				GlobalArray *globl )
{
	/* UnterstÅtzt das System appl_getinfo? */
	static int16 hasInfo = -1;
	
	/* Ggf. prÅfen, ob appl_getinfo vorhanden ist */
	if( hasInfo<0 )
	{
		MAGX_COOKIE *cookie;
		
		if( globl->ap_version>0x400
				|| (type<4 && globl->ap_version==0x400)
				|| (mt_appl_find("?AGI", globl)>=0)
				|| (globl->ap_version==0x399 && Ash_getcookie(C_MagX, &cookie)
					&& cookie->aesvars->version>=0 )
				|| (mt_wind_get(0, WF_WINX, NULL, NULL, NULL, NULL, globl)==WF_WINX) )
			hasInfo = 1;
		else
			hasInfo = 0;
	}
	
	/* Falls vorhanden, appl_getinfo aufrufen */
	if( hasInfo )
	{
		/* contrl anlegen */
		static int16 contrl[] = {130, 1, 1, 0, 0};
		AESData data;
		
		/* Das contrl-Array initialisieren */
		CTRLCPY(data.contrl, contrl);
		
		/* Das globl-Array eintragen */
		data.globl = globl;
		
		/* Die Arrays fÅllen */
		data.intin[0] = type;
		
		data.addrin[0] = str1;
		data.addrin[1] = str2;
		data.addrin[2] = str3;
		data.addrin[3] = str4;
		
		/* Ab in die AES... */
		aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
		
		return data.intout[0];
	}
	
	return FALSE;
}

/******************************************************************************/
/*																										*/
/* AES 129:	appl_control																		*/
/*																										*/
/******************************************************************************/

int16 mt_appl_control( const int16 ap_cid, const int16 ap_cwhat, void *ap_cout,
									GlobalArray *globl )
{
	/* contrl anlegen */
	static int16 contrl[] = {129, 2, 1, 1, 0};
	AESData data;
	
	/* Das contrl-Array initialisieren */
	CTRLCPY(data.contrl, contrl);
	
	/* Das globl-Array eintragen */
	data.globl=globl;
	
	/* Die Arrays fÅllen */
	data.intin[0]=ap_cid;
	data.intin[1]=ap_cwhat;
	
	data.addrin[0] = ap_cout;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	/* Die Werte zurÅckgeben */
	return data.intout[0];
}
