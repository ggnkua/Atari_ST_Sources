/*
*			FILE:	FDDKCOMP.C
*
*	Ein Source, der die Funktionen des FDDK von Tim Mehrvarz
*	auf diejenigen des FAX_OUT Cookies von TeleOffice abbildet.
*
*	Wenn Sie bereits einen Treiber fÅr QFax entwickelt haben,
*	so compilieren Sie dieses File und linken es an Stelle von
*	QFAXDRV.O mit Ihren Sourcen, fertig ist ein Treiber fÅr
*	TeleOffice (der allerdings nicht alle Features nutzt)
*
*	Version  1.0	vom		03.03.1992
*
* Copyright (C) 1992	Jens Briesofsky
* All rights reserved.
*
* This software may be freely copied, modified, and redistributed
* provided that this copyright notice is preserved on all copies.
*
* You may not distribute this software, in whole or in part, as part of
* any commercial product without the express consent of 
*
*		TKR GmbH & Co. KG
*		Stadtparkweg 2
* 	 WD-2300 Kiel 1
*
* There is no warranty or other guarantee of fitness of this software
* for any purpose.  It is provided solely "as is".
*
*/

#include <tos.h>
#include "fax_out.h"

#define NULL	(void *)0L

/*
*	qfax_init
*
*	--> void
*	<--  0:		Alles OK
*		-1:		FAX_OUPUT-Cookie nicht gefunden
*		-2:		Faxausgabe nicht initialisiert
*	
*	Im Fehlerfalle hat der RÅckgabewert zwar eine andere Bedeutung
*	als bei qfax, aber Ausgabe ist in jedem Fall nur bei retval==0
*	mîglich.
*/

static FAX_OUTPUT *fxout=NULL;

int qfax_init( void )
{
	long oldsp=0L;
	struct cookie *cptr;

	if( Super((void *)1L)==0 ) oldsp = Super( NULL );
	cptr = *(struct cookie **)0x5a0;
	if( oldsp ) Super( (void *)oldsp );
	fxout=NULL;
	if( cptr == NULL ) return -1;	/* altes TOS ohne Cookie Jar! */
	while( cptr->c ){
		if( cptr->c == FAX_COOKIE ) {		/* gefunden */
			fxout = (FAX_OUTPUT *)cptr->v;
			if( fxout->fax_ready==1 ) return 0;
			fxout=NULL;
			return -2;
		}
		cptr++;
	}
	return -1;
}

/*
*	qfax_open
*
*	-->	Dateiname (wird bei TeleOffice ignoriert)
*	<--		0:	Alles Ok
*		   -3:	Dateifehler ( QFax: ERR_CREATE )
*
*	diese Funktion initialisiert den Output-Driver
*/
	
#pragma warn-par
int qfax_open( char *file_name )
{
	int rv;
	if( fxout==NULL ) return -3;
	rv = (*fxout->init_app)(1,196,196,0);	/* neue Seite,keine Skalierung,
											   SeitenlÑnge nicht Ñndern */
	return rv?-3:0;
}
#pragma warn+par

/*
*	qfax_pix
*
*	--> Bit-Buffer, Zeilenrepeat
*	<--		0:	Alles OK
*		   -4:	Dateifehler (QFax: ERR_WRITE)
*/

int qfax_pix( unsigned char *pix, int repeat )
{
	int rv;
	if( fxout==NULL ) return -4;
	while( repeat-- ) {
		rv = (*fxout->bit_out)((int *)pix,1728,1,108);
		if( rv ) return -4;
	}
	return 0;
}

/*
*	qfax_text
*
*	--> Nullterminierter String
*	<--		0:	Alles OK
*		   -4:	Dateifehler (QFax: ERR_WRITE)
*/

int qfax_text( char *string )
{
	int rv;

	if( fxout==NULL ) return -4;
	rv = (*fxout->txt_out)( string );
	/* 
	*	Hier muû jetzt noch ein LineFeed aufgerufen werden,
	*	da bei Teleoffice die Mîglichkeit besteht, Text und Grafik zu
	*	Åberlagern (siehe Doc.)
	*/
	rv |= (*fxout->lf)( );
	return rv ? -4 : 0;
}

/*
*	qfax_close
*	
*	--> nix
*	<-- 	0:	Alles Ok
*		 <> 0:  Fehler
*/

int qfax_close( void )
{
	int rv;
	if( fxout==NULL ) return -4;
	rv = (*fxout->page_break)( );
	(*fxout->exit_app)( );
	return rv;
}

/*
*	qfax_clr
*
*	Gibts bei TeleOffice nicht.
*	--> nix
*	<-- 0 (OK)
*/

int qfax_clr( void )
{
	return 0;
}

