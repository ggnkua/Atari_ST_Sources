/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die (N)VDI-Funktionen - Allgemeines														*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

#include <ACSVDI.H>
#include <ACSCook.H>

/******************************************************************************/
/*																										*/
/* Lokale Variablen																				*/
/*																										*/
/******************************************************************************/

/* Globaler Parameterblock fÅr "Dummy-Zwecke" */
VDIPARBLK _VDIParBlk;

/******************************************************************************/
/*																										*/
/* Funktion:	Umrechnen von fix31-Einheiten (Vektorfonts) in Pixel				*/
/*																										*/
/******************************************************************************/

int16 fix31ToPixel( fix31 a )
{
	return (int16)((a+0x00010000l)>>16);
}

/******************************************************************************/
/*																										*/
/* Funktion:	Auslesen des NVDI-Cookies													*/
/*																										*/
/******************************************************************************/

NVDI_STRUC *Ash_NVDICookie( void )
{
	/* Zeiger auf die NVDI-Versions-Infos (Cookie 'NVDI') */
	static NVDI_STRUC *nvdi_vers_info=NULL;
	static int16 nvdi_read=FALSE;
	
	/* Ggf. den Cookie suchen */
	if( !nvdi_read )
	{
		if( !Ash_getcookie(C_NVDI, &nvdi_vers_info) )
			nvdi_vers_info=NULL;
		nvdi_read=TRUE;
	}
	
	return nvdi_vers_info;
}

/******************************************************************************/
/*																										*/
/* Funktion:	Die NVDI-Versionsnummer abfragen											*/
/*																										*/
/******************************************************************************/

uint16 Ash_NVDIVersion( void )
{
	NVDI_STRUC *cookie=Ash_NVDICookie();
	return (cookie!=NULL ? cookie->nvdi_version : 0);
}

/******************************************************************************/
/*																										*/
/* Funktion:	Das NVDI-Datum abfragen														*/
/*																										*/
/******************************************************************************/

uint32 Ash_NVDIDatum( void )
{
	NVDI_STRUC *cookie=Ash_NVDICookie();
	return (cookie!=NULL ? cookie->nvdi_datum : 0);
}

/******************************************************************************/
/*																										*/
/* Funktion:	Aufruf einer EdDI-Funktion - falls mîglich							*/
/*																										*/
/******************************************************************************/

int16 Ash_CallEdDI( int16 fkt_nr )
{
	/* Zeiger auf die EdDI-Versions-Infos (Cookie 'EdDI') */
	static int16 (*eddi_func)(int16 fkt)=NULL;
	static int16 eddi_read=FALSE;
	
	/* Ggf. den Cookie suchen */
	if( !eddi_read )
	{
		if( !Ash_getcookie(C_EdDI, &eddi_func) )
			eddi_func=NULL;
		eddi_read=TRUE;
	}
	
	if( eddi_func!=NULL )
		return (*eddi_func)(fkt_nr);
	else
		return -1;
}

/******************************************************************************/
