/*----------------------------------------------------------------------*/
/* GIO.C  Generic I/O Speed Up Package                         1/23/86  */
/* See GIOCall.C for an example of usage.				*/
/* Read not speeded-up yet.  Only one Write file buffered at a time.	*/
/* Note: The speed-up provided is ONLY significant for code such as IFF */
/* which does numerous small Writes and Seeks.				*/
/*                                                              	*/
/* By Jerry Morrison and Steve Shaw, Electronic Arts.           	*/
/* This software is in the public domain.                       	*/
/*                                                              	*/
/* This version for the Commodore-Amiga computer.               	*/
/*   		                                                        */
/*----------------------------------------------------------------------*/
#include "iff/gio.h"	/* See comments here for explanation.*/

#if GIO_ACTIVE

#define local static


local BPTR wFile      = NULL;
local BYTE *wBuffer   = NULL;
local LONG wNBytes    = 0; /* buffer size in bytes.*/
local LONG wIndex     = 0; /* index of next available byte.*/
local LONG wWaterline = 0; /* Count of # bytes to be written.
			    * Different than wIndex because of GSeek.*/

/*----------- GOpen ----------------------------------------------------*/
LONG GOpen(filename, openmode)   char *filename;  LONG openmode; {
    return( Open(filename, openmode) );
    }

/*----------- GClose ---------------------------------------------------*/
LONG GClose(file)  BPTR file; {
    LONG signal = 0, signal2;
    if (file == wFile)
	signal = GWriteUndeclare(file);
    signal2 = Close(file);	/* Call Close even if trouble with write.*/
    if (signal2 < 0)
	signal = signal2;
    return( signal );
    }

/*----------- GRead ----------------------------------------------------*/
LONG GRead(file, buffer, nBytes)   BPTR file;  BYTE *buffer;  LONG nBytes; {
    LONG signal = 0;
    /* We don't yet read directly from the buffer, so flush it to disk and
     * let the DOS fetch it back. */
    if (file == wFile)
	signal = GWriteFlush(file);
    if (signal >= 0)
	signal = Read(file, buffer, nBytes);
    return( signal );
    }

/* ---------- GWriteFlush ----------------------------------------------*/
LONG GWriteFlush(file)  BPTR file; {
    LONG gWrite = 0;
    if (wFile != NULL  &&  wBuffer != NULL  &&  wIndex > 0)
	gWrite = Write(wFile, wBuffer, wWaterline);
    wWaterline = wIndex = 0;	/* No matter what, make sure this happens.*/
    return( gWrite );
    }

/* ---------- GWriteDeclare --------------------------------------------*/
LONG GWriteDeclare(file, buffer, nBytes)
    BPTR file;  BYTE *buffer;  LONG nBytes; {
    LONG gWrite = GWriteFlush(wFile);  /* Finish any existing usage.*/
    if ( file==NULL  ||  (file==wFile  &&  buffer==NULL)  ||  nBytes<=3) {
	wFile = NULL;   wBuffer = NULL;     wNBytes = 0; }
    else {
	wFile = file;   wBuffer = buffer;   wNBytes = nBytes; }
    return( gWrite );
    }

/* ---------- GWrite ---------------------------------------------------*/
LONG GWrite(file, buffer, nBytes)   BPTR file;  BYTE *buffer;  LONG nBytes; {
    LONG gWrite = 0;

    if (file == wFile  &&  wBuffer != NULL) {
	if (wNBytes >= wIndex + nBytes) {
	    /* Append to wBuffer.*/
	    movmem(buffer, wBuffer+wIndex, nBytes);
	    wIndex += nBytes;
	    if (wIndex > wWaterline)
		wWaterline = wIndex;
	    nBytes = 0;		/* Indicate data has been swallowed.*/
	    }
	else {
	    wWaterline = wIndex;     /* We are about to overwrite any
		* data above wIndex, up to at least the buffer end.*/
	    gWrite = GWriteFlush(file);  /* Write data out in proper order.*/
	    }
	}
    if (nBytes > 0  &&  gWrite >= 0)
	gWrite += Write(file, buffer, nBytes);
    return( gWrite );
    }

/* ---------- GSeek ----------------------------------------------------*/
LONG GSeek(file, position, mode)
    BPTR file;   LONG position;   LONG mode; {
    LONG gSeek = -2;
    LONG newWIndex = wIndex + position;

    if (file == wFile  &&  wBuffer != NULL) {
	if (mode == OFFSET_CURRENT  &&
	    newWIndex >= 0  &&  newWIndex <= wWaterline) {
	    gSeek = wIndex; 	/* Okay; return *OLD* position */
	    wIndex = newWIndex;
	    }
	else {
	    /* We don't even try to optimize the other cases.*/
	    gSeek = GWriteFlush(file);
	    if (gSeek >= 0)   gSeek = -2;  /* OK so far */
	    }
	}
    if (gSeek == -2)
	gSeek = Seek(file, position, mode);
    return( gSeek );
    }

#else /* not GIO_ACTIVE */

void GIODummy() { }	/* to keep the compiler happy */

#endif GIO_ACTIVE
