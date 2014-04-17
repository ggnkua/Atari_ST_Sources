/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.3 $	$Source: /u2/MRS/osrevisions/aes/deskshow.c,v $
* =======================================================================
*  $Author: kbad $	$Date: 89/07/29 20:23:22 $	$Locker: kbad $
* =======================================================================
*  $Log:	deskshow.c,v $
* Revision 2.3  89/07/29  20:23:22  kbad
* Removed error messages requiring keyboard input at the start of showfile.
* Also added uikey() to allow mouse buttons to function like keys during
* showfile.
* 
* Revision 2.2  89/04/26  18:11:42  mui
* aes30
* 
* Revision 2.1  89/02/22  05:22:36  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.3  88/07/01  16:21:10  mui
* Check port for printing
*
* Revision 1.2  88/07/01  15:48:12  mui
* Take out tab expansion, fix fm_show
* 
* Revision 1.1  88/06/02  12:29:59  lozben
* Initial revision
* 
*************************************************************************
*/
/*	DESKSHOW.C		5/3/88			Allan Pratt
 *
 *	
 * show.c: desktop "show file" code.
 *
 * showfile(fname,mode)
 * char *fname;		filename of file to show
 * int mode;		TRUE for printer, FALSE for screen.
 *
 * For screen mode, call this function after the screen is clear and the 
 * cursor is enabled.  When this function returns, the screen needs to
 * be cleared again and the cursor disabled.
 *
 * This code uses BIOS I/O exclusively to avoid ^C handling.
 * It does its own ^S/^Q and ^C handling.
 *
 * ^S/^C get checked every 16 characters or each --more--, whichever comes
 * first.  ^C causes return to the desktop, ^S waits for ^Q (continue) or
 * ^C (quit). 
 *
 * Note that hitting space in the middle of a page makes the "more" come
 * 24 lines from now, rather than having the same effect as waiting
 * for the more and then hitting space.
 *
 * d and D and ^D cause the "more" to come 1/2 page from now; Return
 * makes it come one line from now.
 *
 * q, Q, and ^C cause the output to stop immediately.
 *
 * Line wrap is not modified: if it was no-wrap to begin with, that's
 * what you get.
 *
 * For printer mode, the keyboard gets checked every MAXCHAR characters.
 * q, Q, ^C, and Undo all cause printing to abort.
 * Printer mode, of course, does its own tab expansion.  It only
 * understands TAB, BS, and CR as control characters.  Others will
 * mess up the tab expansion (which means you shouldn't use the desktop
 * print function with wierder files than that).
 */

/*	Return error code back to the caller, form feed after print 
					8/15/89		D.Mui		*/

/*	take out rsrc_gaddr( R_STRING ...	8/30/89	D.Mui		*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include <portab.h>
#include <mobdefs.h>
#include <defines.h>
#include <window.h>
#include <deskusa.h>
#include <gemdefs.h>
#include <osbind.h>
#include <extern.h>

EXTERN	BYTE	*get_fstring();

/* trap() is GEMDOS trap #1; trap13() is (obviously) trap 13. */

extern long trap(), trap13();

#define Fopen(f,m) trap(0x3d,f,m)
#define Fread(handle,count,buf) trap(0x3f,handle,(long)count,buf)
#define Fclose(handle) trap(0x3e,handle)
#define Malloc(size) trap(0x48,(long)size)
#define Mfree(size) trap(0x49,(long)size)

#define Bconstat(d) trap13(1,d)
#define Bconin(d) trap13(2,d)
#define Bconout(d,c) trap13(3,d,c)

#define BUFSIZ 4096	/* Malloc this much as a disk buffer */

/* #define MAXLINE 24	*/	/* line interval for --more-- */
#define MAXCHAR 16	/* character interval for checking keyboard */

/* ASCII equates */

#define CTLC 3
#define CTLD 4
#define BS 8
#define TAB 9
#define NL 10
#define CR 13
#define CTLQ 17
#define CTLS 19
#define SPACE 32

EXTERN WORD	er_num;		/* no device error number */

showfile(fname,mode)
char *fname;
int mode;
{
    int linecount,serial,status;
    register int charcount;
    register int handle;
    char *buf;
    register char *ptr;
    register long len;
    register int i;
    long c;
    int ch;
    long  alert; 

    linecount = charcount = 0;
    handle = -1;
    status = TRUE;
	
    if (!(buf = Malloc((long)BUFSIZ))) 
    {		
	status = FALSE;
	
#ifdef SILLY_ERROR_HANDLING
	if ( mode )	/* printer mode	no memory */
	{
#endif
	  do1_alert( FCNOMEM );
	  goto allout;
#ifdef SILLY_ERROR_HANDLING
	}
	else		/* alpha mode	*/
	{
	  alert = get_fstring( NOMEM );
 	  bconws( alert );
	  bconws( Nextline );
	}
	goto allfin;
#endif
    }

    if ((handle = Fopen(fname,0)) < 0) 
    {
	status = FALSE;

#ifdef SILLY_ERROR_HANDLING
	if ( mode )	/* printer mode	no file */
	{
#endif
	  form_error( 2 );
	  goto allout;
#ifdef SILLY_ERROR_HANDLING
	}
	else		/* aplha mode	*/
	{
	  alert = get_fstring( CANTOPEN );
 	  bconws( alert );	/* Can not open	*/
	  bconws( fname );	/* filename	*/
	  bconws( Nextline );
	}
	goto allfin;
#endif
    }

    /* PRINTER MODE CODE */
    if (mode) {
				/* find out where to send */
				/* serial or parallel	  */

	serial = ( trp14( 0x21, 0xFFFF ) & 0x10 ) ? TRUE : FALSE;

	charcount = 0;

	while ((len = Fread(handle,(long)BUFSIZ,buf)) > 0) {
	    for (ptr = buf,i=0; i<len; i++,ptr++) {
		switch(*ptr) {
		    case CR:
			charcount = 0;
			break;
		    case BS:
			charcount--;
			break;
		    default:
			/* advance for printing chars only */
			if (*ptr >= (unsigned)SPACE) charcount++;
		}
doa2:		if ( !Bconout( serial,*ptr ) )/* device not present ?	*/
		{				/* retry ?		*/
		   if ( do_alert( 2, NOOUTPUT ) == 1 )
		     goto doa2;
		   else				/* cancel */
		   {
		     status = FALSE;
		     goto alldone;
		   }
		}		     	 		   
dontprint:
		if (++linecount >= MAXCHAR) {
		    linecount = 0;
		    if (Bconstat(2)) {
			ch = (int)(c = Bconin(2));
			if (ch == CTLC || ch == 'q' || ch == 'Q' ||
			    (c & 0x00ff0000L) == 0x00610000) goto alldone;
		    }
		}
	    }
	}
	goto alldone;
    }

    /* SCREEN MODE CODE */
    while ((len = Fread(handle,(long)BUFSIZ,buf)) > 0) {
	for (ptr = buf, i = 0; i<len; i++, ptr++) {
	    Bconout(2,*ptr);
	    charcount++;
	    if (*ptr == NL) {
		charcount=0;
		linecount++;
		if (linecount >= d_nrows) 
		{
		    alert = get_fstring( MORE );
		    bconws( "\r" );
		    bconws( alert );
		    if (doui(1,&linecount)) 
		      goto alldone;
		    bconws("\r\033K\r");
		}
	    }
	    else if (charcount >= MAXCHAR) {
		if (doui(0,&linecount)) goto alldone;
	    }
	}
    }

    if ( len < 0 )
    {
	alert = get_fstring( READERROR );
	bconws( Nextline );
	bconws( alert );
    }
    else
    {
	 alert = get_fstring( ENDFILE );
	 bconws( Nextline );
	 bconws( alert );
    }

allfin:
    doui( 1, &linecount );

alldone:
    if ( handle >= 0 )
    {
      if ( ( mode ) && ( status ) )
	Bconout( serial, 0x0C );
      Fclose(handle);
    }

allout:
    if ( buf )		/* if there is memory allocated	*/
      Mfree( buf );	/* free it			*/

    return( status );
}


/* This routine uses the global GEM variable gl_btrue to get the button
 * state, and it shouldn't.  But it can't call graf_mkstate, because
 * that causes a dispatch, which causes the AES to buffer keystrokes.
 */
extern gl_btrue;

long
uikey()
{
    if( gl_btrue & 1 ) return SPACE;    /* left mouse button = next page    */
    if( gl_btrue & 2 ) return CTLC;     /* right mouse button quits         */
    if( Bconstat(2) ) return Bconin(2); /* if there's a key, return it      */
    return 0;                           /* otherwise, return nullo          */
}

/*
 * doui: get user I/O.  Mode is 0 for polling, ~0 for blocking (at --more--).
 *
 * Returns 1 if user wants to stop, or modifies *plinecount for next
 * screenful.
 */

int 
doui(mode,plinecount)
int mode;
int *plinecount;
{
    long c;
    int stop = 0;

    while( (c = uikey()) || mode || stop ) {
	switch ((int)(c) & 0xff) {
	    /* ^D and d and D step 1/2 screen ahead */
	    case CTLD:
	    case 'd':
	    case 'D':
		*plinecount = d_nrows/2;
		return 0;

	    /* space steps another screenful */
	    case SPACE:
		*plinecount = 0;
		return 0;

	    /* Return steps another line */
	    case CR:
		/* do one line & say --more-- again */
		*plinecount = d_nrows-1;
		return 0;

	    /* ^S, ^Q pause/restart */
	    case CTLS:
		stop = 1;
		break;

	    case CTLQ:
		stop = 0;
		break;

	    /* ^C, q, and Q quit */
	    case CTLC:
	    case 'Q':
	    case 'q':
		return 1;

	    /* check here for non-ASCII keys */
	    default:
		/* UNDO quits */
		if ((c & 0x00ff0000) == 0x00610000) 
		    return 1;

		/* other keys don't do anything */
		break;
	}
    }
    return 0;
}

bconws(s)
register char *s;
{
    while (*s) Bconout(2,*s++);
}
