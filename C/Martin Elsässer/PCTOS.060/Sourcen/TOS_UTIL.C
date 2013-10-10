/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* NÅtzliches rund um das TOS-Binding														*/
/*																										*/
/*	(c) 1998-2003 Martin ElsÑsser																*/
/******************************************************************************/

#include <tos.h>
#include <acscook.h>

/******************************************************************************/
/*																										*/
/* Lokale Konstanten und Datentypen															*/
/*																										*/
/******************************************************************************/

typedef struct
{
	int32 id;
	int32 val;
} COOKJAR;

/******************************************************************************/
/*																										*/
/* Funktion:	PrÅfen, ob das System die Speicherschutz-Bit kennt					*/
/*																										*/
/******************************************************************************/

int16 Mxmask( void )
{
	static boolean has_mxalloc = -1;
	static boolean has_sysconf = -1;
	
	if( has_mxalloc == -1 )
		has_mxalloc = ((int32)Mxalloc(-1, 0)!=EINVFN ? 1 : 0);
	if( has_sysconf == -1 )
		has_sysconf = (Sysconf(-1)!=EINVFN ? 1 : 0);
	
	return(has_mxalloc ? (has_sysconf ? -1 : 3) : 0);
}

/******************************************************************************/
/*																										*/
/* Funktion: Wert eines Cookies bestimmen													*/
/*																										*/
/******************************************************************************/

/* Adresse des CookieJar-Vektors als Konstante */
#define COOKIEJAR	0x05A0

/******************************************************************************/

boolean Ash_getcookie( int32 cookie, void *value )
{
	static int16 use_ssystem = -1; 
	COOKJAR	*cookiejar;
	int32		val = -1l;
	int16		i=0;
	
	/* PrÅfen, ob Ssystem vorhanden ist */
	if( use_ssystem<0 )
		use_ssystem = (Ssystem(S_INQUIRE, 0l, 0)==E_OK);
	
	/* Ggf. den Cookie per Ssystem suchen */
	if(use_ssystem)
	{
		if( Ssystem(S_GETCOOKIE, cookie, (int32)&val)==E_OK )
		{
			if( value!=NULL )
				*(int32 *)value = val;
			return TRUE;
		}
	}
	else	/* Den CookieJar selbst durchkramen */
	{
		cookiejar = (COOKJAR *)(Setexc(COOKIEJAR/4,(const void (*)(void))-1));
		if( cookiejar )
		{
			for( i=0 ; cookiejar[i].id ; i++ )
				if( cookiejar[i].id==cookie )
				{
					if( value!=NULL )
						*(int32 *)value = cookiejar[i].val;
					return TRUE;
				}
		}
	}
	
	return FALSE;
}

/******************************************************************************/

/* Die Konstante wird nicht mehr benîtigt */
#undef COOKIEJAR

/******************************************************************************/
/*																										*/
/* Funktion:	Den 200Hz-ZÑhler auslesen													*/
/*																										*/
/******************************************************************************/

/* Adresse des Timers */
#define _hz_200 ((uint32 *)0x4BA)

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Funktion:	Den Timer-Wert des System-Timers durch dirkektes Auslesen		*/
/*					liefern																			*/
/*	Achtung:		Funktion nur im Supervisor-Mode aufrufen!								*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

static int32 get_hz_200( void )
{
    return *_hz_200;
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Funktion:	Den Timer-Wert liefern														*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

uint32 Ash_gettimer( void )
{
	static int16 has_ssystem = -1;
	
	/* Ist Ssystem vorhanden? */
	if( has_ssystem<0 )
		has_ssystem = (Ssystem(-1, 0l, 0l)==E_OK ? TRUE : FALSE);
	
	/* Den Timer auslesen, bevorzugt per Ssystem, */
	/* andernfalls eben per Supervisor-Mode!      */
	if( has_ssystem )
		return Ssystem(S_GETLVAL, (int32)_hz_200, 0L);
	else
		return Supexec(get_hz_200);
}

#undef _hz_200

/******************************************************************************/
/*																										*/
/* Funktion:	Einen Zeiger auf die SYSHDR-/OSHEADER-Struktur liefern			*/
/*																										*/
/******************************************************************************/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*																										*/
/* Funktion:	Die OS-Header-Struktur liefern											*/
/*																										*/
/*	Achtung:		Funktion nur im Supervisor-Mode aufrufen!								*/
/*																										*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* Adresse der Struktur */
#define _sysbase ((SYSHDR **)0x4F2)

static INT32 get_sysbase( void )
{
	SYSHDR *os_header = *_sysbase;
	
	return (UINT32)(os_header->os_base);
}

#undef _sysbase

/******************************************************************************/

SYSHDR *Ash_getOSHeader( void )
{
	return (SYSHDR *)Supexec(get_sysbase);
}

/******************************************************************************/
/*																										*/
/* Funktion:	Den MagiC-Cookie auslesen													*/
/*																										*/
/******************************************************************************/

MAGX_COOKIE *Ash_getMagiC( void )
{
	static boolean is_read = FALSE;
	static MAGX_COOKIE *cookie = NULL;
	
	/* Ggf. den Cookie auslesen */
	if( !is_read )
	{
		if( !Ash_getcookie(C_MagX, &cookie) )
			cookie = NULL;
		is_read = TRUE;
	}
	
	return cookie;
}

/******************************************************************************/
/*																										*/
/* Funktion:	Den N.AES-Cookie auslesen													*/
/*																										*/
/******************************************************************************/

N_AESINFO *Ash_getNAES( void )
{
	static boolean is_read = FALSE;
	static N_AESINFO *cookie = NULL;
	
	/* Ggf. den Cookie auslesen */
	if( !is_read )
	{
		if( !Ash_getcookie(C_nAES, &cookie) )
			cookie = NULL;
		is_read = TRUE;
	}
	
	return cookie;
}

/******************************************************************************/
/*																										*/
/* Funktion:	Die MagiC-Versionsnummer liefern											*/
/*																										*/
/******************************************************************************/

int16 Ash_getMagiCVersion( void )
{
	MAGX_COOKIE *cookie = Ash_getMagiC();
	
	/* Cookie vorhanden? */
	if( cookie!=NULL )
	{
		/* MagiC-AES aktiv? */
		if( cookie->aesvars )
			return cookie->aesvars->version;		/* MagiC lÑuft, MagiC-AES aktiv */
		else
			return -2;									/* MagiC lÑuft, aber MagiC-AES inaktiv */
	}
	else
		return -1;										/* MagiC lÑuft nicht */
}

/******************************************************************************/
/*																										*/
/* Funktion:	Die AES-Variablen von MagiC liefern - auch im Auto-Ordner		*/
/*																										*/
/******************************************************************************/

AESVARS *Ash_getMagiCAESVars( void )
{
	static boolean have_it = 0;
	static AESVARS *aesvars = NULL;
	
	/* Ggf. die Variablen bestimmen */
	if( !have_it )
	{
		MAGX_COOKIE *cookie = Ash_getMagiC();
		if( cookie!=NULL )
		{
			if( cookie->aesvars!=NULL )
				aesvars = cookie->aesvars;
			else
			{
				aesvars = (AESVARS *)Ash_getOSHeader()->os_magic;
				if( aesvars->magic!=0x87654321l || aesvars->magic2!='MAGX' )
					aesvars = NULL;
			}
		}
		
		/* Die Variablen wurden bestimmt! */
		have_it = TRUE;
	}
	
	return aesvars;
}

/******************************************************************************/
