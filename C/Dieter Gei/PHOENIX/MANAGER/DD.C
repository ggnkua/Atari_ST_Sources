/*****************************************************************************
 *
 * Module : DD.C
 * Author : Gerhard Stoll
 *
 * Creation date    : 02.11.02
 * Last modification: 
 *
 *
 * Description: This module implements the drag & drop  protocol
 *							Based on the code from ST-Computer 12/93
 *
 * History:
 * 24.01.04: dd_start um den Dateityp ARGS erweitert.
 * 05.01.03: dd_end Sicherheitsabfrage eingebaut
 * 07.11.02: ZusÑtzlicher Parameter in hndl_dd (window).
 * 02.11.02: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"

#include "ph_lib.h"
#include "windows.h"
#include "tos.h"

#include "export.h"

/****** DEFINES **************************************************************/

#define AP_DRAGDROP   63

#define	DD_OK		0
#define DD_NAK		1											/* negativ acknowlege								 */
#define DD_EXT		2
#define DD_LEN		3

/* Standard-Extensionliste */
#define DD_NUMEXTS	8
#define DD_EXTSIZE	32

/* Objektname; MaximallÑnge */
#define DD_NAMEMAX	128

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL BYTE pipename[] = "U:\\PIPE\\DRAGDROP.AA";
LOCAL VOID *oldsig;
LOCAL BYTE *buffer;

/****** FUNCTIONS ************************************************************/

LOCAL LONG dd_open ( WORD pipe_num, CONST BYTE *extlist);
LOCAL LONG dd_open_fifo ( WORD pnum);
LOCAL VOID dd_close ( LONG fd );
LOCAL WORD dd_getheader (	LONG fd, BYTE *obname, BYTE *fname, BYTE *datatype, LONG *size);
LOCAL WORD dd_reply ( LONG fd, BYTE ack);

/*****************************************************************************/
/* Kînnen wir nicht  																												 */

GLOBAL VOID dd_no ( WINDOWP window, WORD msg[16] )
{
	BYTE c;
  LONG fd;
	
  pipename[18] = msg[7] & 0x00ff;
  pipename[17] = (msg[7] & 0xff00) >> 8;

  fd = Fopen (pipename, 2);
  if (fd >= 0)
  {
		c = DD_NAK;
		
		Fwrite ((WORD) fd, 1, &c);
		Fclose ((WORD) fd);
  }
} /* no_dd */

/*****************************************************************************/
/* Drag und Drop durchfÅhren 																								 */

GLOBAL VOID *dd_start ( WORD msg[] )
{
	LONG fd;
	BYTE obname[DD_NAMEMAX], ext[5];
	BYTE fname[PATH_MAX];
/* [GS] 5.1d Start: */
	BYTE ourexts[DD_EXTSIZE] = ".TXTARGS";
/* Ende; alt:
	BYTE ourexts[DD_EXTSIZE] = ".TXT";
*/
	LONG size;

	fd = dd_open (msg[7], ourexts);
	if (fd < 0) return NULL;

	do
	{
		if (!dd_getheader (fd, obname, fname,	ext, &size))
		{
			dd_close (fd);
			return NULL;
		} /* if */

/* [GS] 5.1d Start: */
		if ( strncmp (ext, ".TXT", 4) == 0 || strncmp (ext, "ARGS", 4) == 0 )
/* Ende; alt:
		if ( strncmp (ext, ".TXT", 4) == 0  )
*/
		{
			buffer = malloc_global (size + 1);
			dd_reply (fd, DD_OK);

			if ( buffer != NULL )
				Fread ((int) fd, size, buffer);

			dd_close (fd);

			if ( buffer != NULL )
				buffer[size] = 0;

			return buffer;
		} /* if */
	} while (dd_reply (fd, DD_EXT));
	return NULL;
} /* dd_receive */

/*****************************************************************************/

GLOBAL VOID dd_end ( void )
{
/* GS 5.1c Start: */
	if ( buffer != NULL )
/* Ende */
		Mfree ( buffer );
}

/*****************************************************************************/
/* D&D-Pipe îffnen und Extensionliste hereinschreiben. Wenn dabei etwas			 */
/* schiefgeht, wird der alte SIGPIPE-Handler wiederhergestellt. Ergebnis		 */
/* ist das Dateihandle oder ein Fehlercode 																	 */

LOCAL LONG dd_open ( WORD pipe_num, CONST BYTE *extlist)
{
	LONG fd;
	BYTE outbuf[DD_EXTSIZE + 1];

	fd = dd_open_fifo (pipe_num);
	if (fd < 0)
		return fd;

	outbuf[0] = DD_OK;
	strncpy (outbuf + 1, extlist, DD_EXTSIZE);

	if (DD_EXTSIZE + 1 != Fwrite ((int) fd, DD_EXTSIZE + 1, outbuf))
	{
		dd_close ((int) fd);
		return -1;
	} /* if */

	return fd;
} /* dd_open */

/*****************************************************************************/
/* ôffnet die Pipe anhand `extension'. Bei Erfolg wird der Handler fÅr			 */
/* SIGPIPE gesetzt.																													 */
/* Ergebnis ist das Dateihandle 																						 */

LOCAL LONG dd_open_fifo ( WORD pnum)
{
	BYTE pipename[20];
	LONG fd;

	sprintf (pipename, "U:\\PIPE\\DRAGDROP.%c%c",
		(pnum & 0xff00) >> 8, pnum & 0xff);

	if (0 <= (fd = Fopen (pipename, 2)))
		oldsig = (VOID *) Psignal (SIGPIPE, (void *) 1);

	return fd;
}

/*****************************************************************************/
/* Drag und Drop-Operation beenden 																					 */

LOCAL VOID dd_close ( LONG fd )
{
	Psignal (SIGPIPE, oldsig);
	Fclose ( (WORD) fd );
}

/*****************************************************************************/
/* Holt den nÑchsten Header aus der Pipe (fd) ab. Ausgabeparameter sind			 */
/* name' (Name des Objekts, mindestens DD_NAMEMAX Zeichen), `datatype'			 */
/* (Datentyp, 4 + 1 Zeichen) und `size' (Grîûe der Daten).									 */
/* RÅckgabewert ist 1 im Erfolgsfall, 0 sonst 															 */

LOCAL WORD dd_getheader (	LONG fd, BYTE *obname, BYTE *fname, BYTE *datatype, LONG *size)
{
	WORD hdrlen;
	size_t cnt, slen;
	BYTE buf[PATH_MAX + DD_NAMEMAX + 1];

	if (2 != Fread ((int) fd, 2, &hdrlen))
		return 0;
	if (hdrlen < 9) return 0;

	if (4 != Fread ((int) fd, 4, datatype))
		return 0;
	datatype[4] = '\0';

	if (4 != Fread ((int) fd, 4, size))
		return 0;

	hdrlen -= 8;
	cnt = hdrlen;

																			/* Objektnamen und Dateinamen lesen 	 */
	if (cnt > PATH_MAX + DD_NAMEMAX)
		cnt = PATH_MAX + DD_NAMEMAX;
	if (cnt != Fread ((int) fd, cnt, buf))
		return 0;

	buf[PATH_MAX + DD_NAMEMAX] = '\0';
	hdrlen -= cnt;
	slen = strlen (buf);

	if (slen < DD_NAMEMAX)
		strcpy (obname, buf);

	if (slen < PATH_MAX + DD_NAMEMAX)
	{
		BYTE *fp = buf + slen + 1;

		slen = strlen (fp);

		if (slen < PATH_MAX)
			strcpy (fname, fp); 
	} /* if */

																			/* Rest Åberspringen 									 */
	while (hdrlen)
	{
		size_t cnt = hdrlen;
		if (cnt > sizeof (buf))
			hdrlen = sizeof (buf);

		Fread ((int) fd, cnt, buf);
		hdrlen -= cnt;
	}

	return 1;
} /* dd_getheader */

/*****************************************************************************/
/* Ein-Zeichen-Antwort verschicken. Im Fehlerfall wird die Pipe geschlossen. */
/* RÅckgabewert: 0 bei Fehlern 																							 */

LOCAL WORD dd_reply ( LONG fd, BYTE ack)
{
	if (1 != Fwrite ((int) fd, 1L, &ack))
	{
		dd_close (fd);
		return 0;
	} /* if */

	return 1;
} /* dd_replay */
