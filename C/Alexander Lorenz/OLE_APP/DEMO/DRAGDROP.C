/*
*	Grundroutinen fÅr MultiTOS Drag & Drop, Revision 1.1
*
*	Basierend auf den D&D-Samplesourcen von Atari.
*
*	énderungen:
*	 09.11.94 al - Original Sourcen PureC-konform gemacht
*	 15.11.94 al - Sourcen debugged
*	 22.11.94 al - Sourcen fÅr Revision 1.1 Protokoll erweitert
*	 23.01.95 al - Kommentare hinzugefÅgt
*	 08.02.95 al - OEP-FÑhigkeit sichergestellt
*	 20.02.95 al - Sourcen auf OEP Rev. 0.5 Åberarbeitet
*
*	(c) 1994-1995 Alexander Lorenz
*
*	Global verwendete Variable:
*	 Struktur OEP (oep.apid): AES-ID der Applikation
*
*	(Tab = 4)
*/

#include <tos.h>
#include <string.h>
#include <aes.h>
#include <stdio.h>

#include "portab.h"
#include "dragdrop.h"
#include "atarierr.h"
#include "oep.h"


static BYTE pipename[] = "U:\\PIPE\\DRAGDROP.AA";
static LONG pipesig;

extern OEP oep;


/*
*	Routinen fÅr den Sender
*/

/*
*	Erzeugt Pipe fÅr D&D
*
* 	Eingabeparameter:
*	pipe	-	Pointer auf 2 Byte Buffer fÅr Pipeextension
*
*	Ausgabeparameters:
*	keine
*
*	Returnwert:
* 	>0: Filehandle der Pipe
* 	-1: Fehler beim Erzeugen der Pipe
*/

WORD ddcreate(WORD *pipe)
{
	LONG fd;

	pipename[17] = 'A';
	pipename[18] = 'A' - 1;

	do
	{
		pipename[18]++;
		if (pipename[18] > 'Z')
		{
			pipename[17]++;
			if (pipename[17] > 'Z')
				break;
			else
				pipename[18] = 'A';
		}

		/* FA_HIDDEN fÅr Pipe notwendig! */

		fd = Fcreate(pipename, FA_HIDDEN);

	} while (fd == (LONG) EACCDN);

	if (fd < 0L)
		return(-1);

	*pipe = (pipename[17] << 8) | pipename[18];
	

	/* Signalhandler konfigurieren */
	
	ddgetsig(&pipesig);


	return((WORD) fd);
}



/*
*	Sendet AP_DRAGDROP an EmpfÑngerapplikation
*
* 	Eingabeparameter:
* 	apid		- 	AES-ID der EmfÑngerapp.
* 	fd			- 	Filehandle der D&D-Pipe
*	winid		-	Handle des Zielfensters (0 fÅr Desktopfenster)
*	mx/my		-	Maus X und Y Koord.
*					(-1/-1 fÅr einen fake Drag&Drop)
* 	kstate		-	Sondertastenstatus
* 	pipename	-	Extension der D&D-Pipe
*
*	Ausgabeparameter:
*	keine
*
*	Returnwert:
* 	>0: kein Fehler
* 	-1: EmpfÑngerapp. gibt DD_NAK zurÅck
*	-2: EmpfÑngerapp. antwortet nicht (Timeout)
*	-3: Fehler bei appl_write()
*/

WORD ddmessage(WORD apid, WORD fd, WORD winid, WORD mx, WORD my, WORD kstate, WORD pipename)
{
	BYTE c;
	WORD i, msg[8];
	LONG fd_mask;


	/* AES-Message definieren und senden */
	
	msg[0] = AP_DRAGDROP;
	msg[1] = oep.apid;
	msg[2] = 0;
	msg[3] = winid;
	msg[4] = mx;
	msg[5] = my;
	msg[6] = kstate;
	msg[7] = pipename;

	i = appl_write(apid, 16, msg);

	if (i == 0)
	{
		ddclose(fd);
		return(-3);
	}


	/* warten bis der EmpfÑnger reagiert */
	
	fd_mask = (1L << fd);
	i = Fselect(DD_TIMEOUT, &fd_mask, 0L, 0L);
	if (!i || !fd_mask)
	{
		/* Timeout eingetreten */
		
		ddclose(fd);
		return(-2);
	}


	/* Antwortbyte lesen */
	
	if (Fread(fd, 1L, &c) != 1L)
	{
		ddclose(fd);
		return(-1);
	}

	if (c != DD_OK)
	{
		ddclose(fd);
		return(-1);
	}
	
	return(1);
}



/*
*	Liest die 8 "bevorzugten" Extensionen der EmpfÑngerapplikation
*
* 	Eingabeparameter:
* 	fd		- 	Filehandle der D&D-Pipe
*
*	Ausgabeparameters:
*	exts	-	32 Bytebuffer fÅr die 8 bevorzugten Extensionen
*				der Zielapp.
*
*	Returnwert:
* 	>0: kein Fehler
* 	-1: Fehler beim Lesen aus der Pipe
*/

WORD ddrexts(WORD fd, BYTE *exts)
{
	if (Fread(fd, DD_EXTSIZE, exts) != DD_EXTSIZE)
	{
		ddclose(fd);
		return(-1);
	}

	return(1);
}



/*
*	Testet, ob der EmpfÑnger einen Datentyp akzeptiert
*
*	Eingabeparameter:
*	fd		-	Filehandle (von ddcreate())
*	ext		-	Zeiger auf Datentyp (4 Bytes zB. "ARGS")
*	text	-	Zeiger auf Datenbeschreibung (optional, zB. "DESKTOP args")
*	name	-	Zeiger auf Datendateiname (optional, zB. "SAMPLE.TXT")
*	size	-	Anzahl Bytes der zu sendenden Daten
*
*	Ausgabeparameter:
*	keine
*
*	Returnwert:
* 	DD_OK			-	EmpfÑnger akzeptiert Datentyp
*	DD_NAK			-	EmpfÑnger brach Drag&Drop ab
*	DD_EXT			-	EmpfÑnger lehnt Datentyp ab
*	DD_LEN			-	EmpfÑnger kann Datenmenge nicht verarbeiten
*	DD_TRASH		-	Drop erfolgte auf MÅlleimer
*	DD_PRINTER		-	Drop erfolgte auf Drucker
*	DD_CLIPBOARD	-	Drop erfolgte auf Clipboard
*/

WORD ddstry(WORD fd, BYTE *ext, BYTE *text, BYTE *name, LONG size)
{
	BYTE c;
	WORD hdrlen, i;
	
	/* 4 Bytes fÅr "ext", 4 Bytes fÅr "size",
	   2 Bytes fÅr Stringendnullen */
	
	hdrlen = (WORD) (4 + 4 + strlen(text)+1 + strlen(name)+1);


	/* Header senden */

	if (Fwrite(fd, 2L, &hdrlen) != 2L)
		return(DD_NAK);

	i = (WORD) Fwrite(fd, 4L, ext);
	i += (WORD) Fwrite(fd, 4L, &size);
	i += (WORD) Fwrite(fd, strlen(text)+1, text);
	i += (WORD) Fwrite(fd, strlen(name)+1, name);

	if (i != hdrlen)
		return(DD_NAK);


	/* auf die Antwort warten */
	
	if (Fread(fd, 1L, &c) != 1L)
		return(DD_NAK);

	return(c);
}



/* Routinen fÅr Sender und EmpfÑnger */

/*
*	Pipe schlieûen (Drag&Drop beenden/abbrechen)
*/

VOID ddclose(WORD fd)
{
	/* Signalhandler restaurieren */
	
	ddsetsig(pipesig);
	
	
	Fclose(fd);
}


/*
*	Signalhandler fÅr D&D konfigurieren
*
*	Eingabeparameter:
*	oldsig	-	Zeiger auf 4 Byte Puffer fÅr alten Handlerwert
*
* 	Ausgabeparameter:
*	keine
*
*	Returnwerte:
*	keine
*/

VOID ddgetsig(LONG *oldsig)
{
	*oldsig = (LONG) Psignal(SIGPIPE, (VOID *) SIG_IGN);
}


/*
*	Signalhandler nach D&D restaurieren
*
*	Eingabeparameter:
*	oldsig	-	Alter Handlerwert (von ddgetsig)
*
* 	Ausgabeparameter:
*	keine
*
*	Returnwerte:
*	keine
*/

VOID ddsetsig(LONG oldsig)
{
	if (oldsig != -32L)
		Psignal(SIGPIPE, (VOID *) oldsig);
}



/* Routinen fÅr EmpfÑnger */

/*
*	Drag&Drop Pipe îffnen
*
*	Eingabeparameter:
*	ddnam	-	Extension der Pipe (letztes WORD von AP_DRAGDROP)
*	ddmsg	-	DD_OK oder DD_NAK
*
* 	Ausgabeparameter:
*	keine
*
*	Returnwerte:
*	>0	-	Filehandle der Drag&Drop pipe
*	-1	-	Drag&Drop abgebrochen
*/

WORD ddopen(WORD ddnam, BYTE ddmsg)
{
	LONG fd;

	pipename[17] = (ddnam & 0xff00) >> 8;
	pipename[18] = ddnam & 0x00ff;

	fd = Fopen(pipename, 2);

	if (fd < 0L)
		return(-1);


	/* Signalhandler konfigurieren */
	
	ddgetsig(&pipesig);
	
	
	if (Fwrite((WORD) fd, 1L, &ddmsg) != 1L)
	{
		ddclose((WORD) fd);
		return(-1);
	}

	return((WORD) fd);
}



/*
*	Schreibt die 8 "bevorzugten" Extensionen der Applikation
*
* 	Eingabeparameter:
* 	fd		- 	Filehandle der D&D-Pipe
*	exts	-	Liste aus acht 4 Byte Extensionen die verstanden
*				werden. Diese Liste sollte nach bevorzugten Datentypen
*				sortiert sein. Sollten weniger als DD_NUMEXTS
*				Extensionen unterstÅtzt werden, muû die Liste mit
*				Nullen (0) aufgefÅllt werden!
*
* 	Ausgabeparameter:
*	keine
*
*	Returnwert:
* 	>0: kein Fehler
* 	-1: Fehler beim Schreiben in die Pipe
*/

WORD ddsexts(WORD fd, BYTE *exts)
{
	if (Fwrite(fd, DD_EXTSIZE, exts) != DD_EXTSIZE)
	{
		ddclose(fd);
		return(-1);
	}

	return(1);
}



/*
*	NÑchsten Header vom Sender holen
*
*	Eingabeparameter:
*	fd		-	Filehandle der Pipe (von ddopen())
*
*	Ausgabeparameters:
*	name	-	Zeiger auf Buffer fÅr Datenbeschreibung (min. DD_NAMEMAX!)
*	file	-	Zeiger auf Buffer fÅr Datendateiname (min. DD_NAMEMAX!)
*	whichext-	Zeiger auf Buffer fÅr Extension (4 Bytes)
*	size	-	Zeiger auf Buffer fÅr Datengrîûe (4 Bytes)
*
*	Returnwert:
*	>0: kein Fehler
*	-1: Sender brach Drag&Drop ab
*/

WORD ddrtry(WORD fd, BYTE *name, BYTE *file, BYTE *whichext, LONG *size)
{
	BYTE buf[DD_NAMEMAX * 2];
	WORD hdrlen, i, len;

	if (Fread(fd, 2L, &hdrlen) != 2L)
		return(-1);
	

	if (hdrlen < 9)
	{
		/* sollte eigentlich nie passieren */

		return(-1);
	}
	
	if (Fread(fd, 4L, whichext) != 4L)
		return(-1);
	
	if (Fread(fd, 4L, size) != 4L)
		return(-1);
	
	hdrlen -= 8;
	
	if (hdrlen > DD_NAMEMAX*2)
		i = DD_NAMEMAX*2;
	else
		i = hdrlen;

	len = i;
	
	if (Fread(fd, (LONG) i, buf) != (LONG) i)
		return(-1);
	
	hdrlen -= i;
	
	strncpy(name, buf, DD_NAMEMAX);
	
	i = (WORD) strlen(name) + 1;
	
	if (len - i > 0)
		strncpy(file, buf + i, DD_NAMEMAX);
	else
		file[0] = '\0';


	/* weitere Bytes im Header in den MÅll */
	
	while (hdrlen > DD_NAMEMAX*2)
	{
		if (Fread(fd, DD_NAMEMAX*2, buf) != DD_NAMEMAX*2)
			return(-1);
		
		hdrlen -= DD_NAMEMAX*2;
	}
	
	if (hdrlen > 0)
	{
		if (Fread(fd, (LONG) hdrlen, buf) != (LONG) hdrlen)
			return(-1);
	}

	return(1);
}



/*
*	Sendet der Senderapplikation eine 1 Byte Antwort 
*
*	Eingabeparameter:
*	fd	-	Filehandle der Pipe (von ddopen())
*	ack	-	Byte das gesendet werden soll (zB. DD_OK)
*
*	Ausgabeparameter:
*	keine
*
*	Returnwert:
*	>0: kein Fehler
*	-1: Fehler (die Pipe wird automatisch geschlossen!)
*/

WORD ddreply(WORD fd, BYTE ack)
{
	if (Fwrite(fd, 1L, &ack) != 1L)
	{
		ddclose(fd);
		return(-1);
	}
	
	return(1);
}


