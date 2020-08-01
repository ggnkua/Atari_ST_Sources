/********************************************************************
*
* MagiC Device Driver Development Kit
* ===================================
*
* C-Modul
*
*
* Das MDDDK enth„lt alle notwendigen Module, um in 'C' einen
* Ger„tetreiber fr MagiC 3.0 zu erstellen. Im Modul SAMPLE.S
* wird das MagiC Assembler-Interface fr 'C' umgesetzt. Um zu
* allen Compilern kompatibel zu sein, sind alle Funktionen in
* PureC als "cdecl" definiert, d.h. die Parameterbergabe geht
* immer ber den Stack.
*
* Die Include-Dateien mgx_???c.h enthalten cdecl-Prozedur-
* Deklarationen fr den Zugriff ber den "Glue"- Code in sample.s,
* d.h. die Strukturen sind nicht die des Betriebssystems, sondern
* die des "Glue"- Codes. Der "Glue"- Code setzt dann die Prozedur-
* aufrufe fr das Betriebssystem um.
*
* Der Beispieltreiber ignoriert Lese- und Schreibzugriffe, an den
* entsprechenden Stellen sind die eigenen Routinen einzufgen.
*
* Zur detaillierten Beschreibung der Funktionen siehe MGX_DFS.TXT.
*
* Fr die Programmierung eines interruptgesteuerten Ger„tetreibers
* siehe DEV_LPT1. In DEV_LPT1 sind einige der Ger„tefunktionen
* in Assembler ausgefhrt, was einen schnelleren und kompakteren
* Code erm”glicht.
*
*
* (C) Andreas Kromke, 1994
*
********************************************************************/

#include <string.h>
#include <tos.h>
#include <tosdefs.h>

#include "magx.h"
#include "mgx_xfsc.h"
#include "mgx_dfsc.h"

#ifndef NULL
#define NULL ((void *) 0)
#endif


/******************************************************************
*
* Import aus dem Assemblermodul "sample.s".
*
* _drvr ist die Struktur, die beim Kernel angemeldet wird. Sie
* setzt die Aufrufe von Assembler in 'C' um, d.h. kopiert die
* šbergaberegister auf den Stack und ruft die Routinen von drvr
* auf.
* Die Routinen von drvr sind daher als "cdecl" deklariert.
*
* Wenn Routinen in Assembler ausgefhrt werden sollen, kann hier
* in der Struktur "drvr" ein Nullzeiger eingetragen und die
* Funktion vollst„ndig im Assemblerteil implementiert werden.
*
******************************************************************/

extern MX_DDEV _drvr;


/******************************************************************
*
* ger„tespezifische Variablen
*
******************************************************************/

MX_KERNEL *kernel;



#pragma warn -par

/******************************************************************
*
* Ger„t ”ffnen
*
******************************************************************/

LONG cdecl sample_open( MX_DOSFD *f )
{
	return(E_OK);
}


/******************************************************************
*
* Ger„t schlieen
*
******************************************************************/

LONG cdecl sample_close( MX_DOSFD *f )
{
	return(E_OK);
}


/******************************************************************
*
* lesen
*
******************************************************************/

LONG cdecl sample_read( MX_DOSFD *f, void *buf,  LONG len )
{
	return(0L);
}


/******************************************************************
*
* schreiben
*
******************************************************************/

LONG cdecl sample_write( MX_DOSFD *f, void *buf,  LONG len )
{
	return(0L);
}


/******************************************************************
*
* Status
*
******************************************************************/

LONG cdecl sample_stat( MX_DOSFD *f, WORD rwflag, void *unsel,
					void *appl)
{
	return(0);
}


/******************************************************************
*
* Dateizeiger positionieren
*
******************************************************************/

LONG cdecl sample_seek( MX_DOSFD *f, LONG where, WORD mode )
{
	return(EACCDN);
}


/******************************************************************
*
* Uhrzeit/Datum der ge”ffneten Datei
*
******************************************************************/

LONG cdecl sample_datime( MX_DOSFD *f, WORD *buf, WORD rwflag)
{
	return(EACCDN);
}


/******************************************************************
*
* Ger„tespezifische Befehle
*
******************************************************************/

LONG cdecl sample_ioctl( MX_DOSFD *f, WORD cmd, void *buf )
{
	return(EINVFN);
}


/******************************************************************
*
* Ger„t wird gel”scht
*  Ger„tetreiber aus dem Speicher entfernen (!)
*
******************************************************************/

LONG cdecl sample_delete ( MX_DOSFD *parent, MX_DOSDIR *dir )
{
	/* hier den Treiber abmelden */

	/* ... */

	kernel->Pfree(_BasPag);
	return(E_OK);
}

/******************************************************************
*
* Einzelzeichen einlesen (fr Fgetchar)
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rckgabe: ist i.a. ein Langwort bei CON, sonst ein Byte
*           0x0000FF1A bei EOF
*
******************************************************************/

LONG cdecl sample_getc( MX_DOSFD *f, WORD mode )
{
	return(0L);
}


/******************************************************************
*
* Zeile einlesen (fr Cconrs)
*
* mode & 0x0001:    cooked
* mode & 0x0002:    echo mode
*
* Rckgabe: Anzahl gelesener Bytes oder Fehlercode
*
******************************************************************/

LONG cdecl sample_getline( MX_DOSFD *f, char *buf,
						LONG size, WORD mode )
{
	return(0L);
}


/******************************************************************
*
* Einzelzeichen ausgeben (fr Fputchar)
*
* mode & 0x0001:    cooked
*
* Rckgabe: Anzahl geschriebener Bytes, 4 bei einem Terminal
*
******************************************************************/

LONG cdecl sample_putc( MX_DOSFD *f, WORD mode, LONG val )
{
	return(0L);
}


#pragma warn +par


MX_DDEV drvr =
	{
	sample_open,
	sample_close,
	sample_read,
	sample_write,
	sample_stat,
	sample_seek,
	sample_datime,
	sample_ioctl,
	sample_delete,
	sample_getc,
	sample_getline,
	sample_putc
	};

int main( void )
{
	long errcode;

	/* ggf. Standardfunktionen */
	/*
	_drvr.ddev_datime	= NULL;	/* fr Fdatime */
	_drvr.ddev_ioctl	= NULL;	/* fr Fcntl */
	_drvr.ddev_getc	= NULL;	/* fr Fgetchar */
	_drvr.ddev_getline	= NULL;	/* fr Cconrs */
	_drvr.ddev_putc	= NULL;	/* fr Fputchar */
	*/


	errcode = Dcntl(KER_GETINFO, NULL, 0L);
	if   (errcode > 0L)
		{
		kernel = (MX_KERNEL *) errcode;
		errcode = Dcntl(DEV_M_INSTALL, "u:\\dev\\sample",	(long) &_drvr);
		}
	if	(errcode < 0L)
		{
		return((int) errcode);
		}

	Ptermres(-1L, 0);        /* allen Speicher behalten */
	return(0);
}
