/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

/*----------------------------------------------------------------------------------------*/ 
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include <PORTAB.H>
#include	<TOS.H>
#include	<VDI.H>
#include	<MT_AES.H>

#include	<STRING.H>
#include	<STDLIB.H>

/*----------------------------------------------------------------------------------------*/ 
/* Prototypen																										*/
/*----------------------------------------------------------------------------------------*/ 

WORD	open_screen_wk( WORD aes_handle, WORD *work_out );
WORD	wlf_available( void );

/*----------------------------------------------------------------------------------------*/ 
/* Globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/ 

WORD	app_id;
WORD	aes_handle;
WORD	pwchar;
WORD	phchar;
WORD	pwbox;
WORD	phbox;

WORD	work_out[57];
WORD	vdi_handle;

/*----------------------------------------------------------------------------------------*/ 
/* Makros																											*/
/*----------------------------------------------------------------------------------------*/ 

#define	FONT_FLAGS	( FNTS_BTMP + FNTS_OUTL + FNTS_MONO + FNTS_PROP )

#define	BUTTON_FLAGS ( FNTS_SNAME + FNTS_SSTYLE + FNTS_SSIZE + FNTS_SRATIO + FNTS_CHNAME + FNTS_CHSTYLE + FNTS_CHSIZE + FNTS_CHRATIO + FNTS_RATIO + FNTS_BSET + FNTS_BMARK )

/*----------------------------------------------------------------------------------------*/ 
/* Virtuelle Bildschirm-Workstation îffnen																*/
/* Funktionsresultat:	VDI-Handle oder 0 (Fehler)														*/
/*	aes_handle:				Handle der vom AES benutzten Workstation									*/
/* work_out:				GerÑteinformationen																*/
/*----------------------------------------------------------------------------------------*/ 
WORD open_screen_wk( WORD aes_handle, WORD *work_out )
{
	WORD	work_in[11];
	WORD	handle;
	WORD	i;
			
	for( i = 1; i < 10 ; i++ )											/* work_in initialisieren */
		work_in[i] = 1;
		
	work_in[0] = Getrez() + 2;											/* Auflîsung */
	work_in[10] = 2;														/* Rasterkoordinaten benutzen */
	handle = aes_handle;

	v_opnvwk( work_in, &handle, work_out );
	
	return( handle );
}

/*----------------------------------------------------------------------------------------*/ 
/* Testen, ob wdlg_xx()/lbox_xx()/fnts_xx()-Funktionen vorhanden sind							*/
/* Funktionsresultat:	1: vorhanden, 0: nicht vorhanden												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wlf_available( void )
{
	if ( appl_find( "?AGI" ) == 0 )									/* appl_getinfo() vorhanden? */
	{
		WORD	ag1;
		WORD	ag2;
		WORD	ag3;
		WORD	ag4;

		if ( appl_getinfo( 7, &ag1, &ag2, &ag3, &ag4 ))			/* Unterfunktion 7 aufrufen */
		{
			if (( ag1 & 7 ) == 7 )										/* wdlg_xx()/lbox_xx()/fnts_xx() vorhanden? */
				return( 1 );
		}	
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Hauptprogramm																									*/
/*----------------------------------------------------------------------------------------*/ 
WORD	main( void )
{
	extern WORD	app_id;
	extern WORD	aes_handle;
	extern WORD	pwchar;
	extern WORD	phchar;
	extern WORD	pwbox;
	extern WORD	phbox;
	
	FNT_DIALOG	*fnt_dialog;
	
	app_id = appl_init();

	if( app_id != -1 )													/* Anmeldung erfolgreich? */
	{
		if ( wlf_available())											/* Dialogroutinen vorhanden? */
		{
			aes_handle = graf_handle( &pwchar, &phchar, &pwbox, &phbox );
			graf_mouse( ARROW, 0L );										/* Mauszeiger anschalten */
			vdi_handle = open_screen_wk( aes_handle, work_out );	/* Workstation îffnen */
	
			if( vdi_handle != 0 )
			{
				WORD	no_fonts;
				
				no_fonts = work_out[10];								/* Anzahl der bereits vorhandenen (System-)Fonts */
				no_fonts += vst_load_fonts( vdi_handle, 0 );		/* plus Anzahl der geladenen Fonts */
				
				fnt_dialog = fnts_create( vdi_handle, no_fonts, FONT_FLAGS, FNTS_3D,
												  "Was Shake'beer Your Favourite Poet?",
												  "Warum" );
	
				if ( fnt_dialog )
				{
					LONG	id;
					LONG	pt;
					LONG	ratio;
					WORD	x;
					WORD	y;
					
					id = 1;													/* Systemfont */
					pt = 10L << 16;										/* 10 Punkt einstellen */
					ratio = 1L << 16;										/* VerhÑltnis 1/1 (Bitmapfonts kînnen nicht gestaucht oder gedehnt werden) */
					x = -1;
					y = -1;
	
					if ( fnts_open( fnt_dialog, BUTTON_FLAGS, x, y, id, pt, ratio ))
					{
						EVNT	evnts;
						WORD	button;
						WORD	check_boxes;
						WORD	cont;
						WORD	index;
						
						index = 1;
						cont = 1;											/* weitermachen... */
						
						while( cont )
						{
							EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG + MU_TIMER, 2, 1, 1, 0L, 0L, 2000, &evnts );
							
							if ( evnts.mwhich & MU_TIMER )
							{
								BYTE	name[36];
																
								index++;
								if ( index > no_fonts )
									index = 1;

								pt = ( index % 10 ) + 10;				/* Grîûe zwischen 10 und 19 pt einstellen */
								pt <<= 16;
								
								ratio = 10 + ( index % 10 );
								ratio <<= 16;
								ratio /= 10;								/* B/H-VerhÑltnis zwischen 1 und 1.9 */
																
								id = vqt_name( vdi_handle, index, name );
								fnts_update( fnt_dialog, BUTTON_FLAGS, id, pt, ratio );
							}
							
							if	( fnts_evnt( fnt_dialog, &evnts, &button, &check_boxes, &id, &pt, &ratio ) == 0 )
							{
								switch ( button )
								{
									case	FNTS_CANCEL:					/* "Abbruch" */
									{
										cont = 0;							/* Schleife beenden */
										break;
									}
									case	FNTS_OK:							/* "OK" */
									{
										/* markierte Bereiche sollten auf die Åbergebenen */
										/*	Attribute gesetzt werden; der Dialog muû */
										/* geschlossen werden. */
	
										cont = 0;							/* Schleife beenden */
										break;
									}
									case	FNTS_SET:						/* "setzen" */
									{
										/* markierte Bereiche sollten auf die Åbergebenen */
										/*	Attribute gesetzt werden; der Dialog sollte wird */
										/* nicht geschlossen */
	
										break;
									}
									case	FNTS_MARK:						/* "markieren" */
									{
										/* wenn das Markieren unterstÅtzt wird sollten jetzt */
										/* alle Bereiche mit dem Font <id> in der Hîhe <pt> */
										/*	mit dem Breite/Hîhe-VerhÑltnis <ratio> markiert */
										/* werden. Wenn das Programm die Checkboxen fÅr Name, */
										/* Stil, Hîhe und SeitenverhÑltnis unterstÅtzt, sollte */
										/* auûerdem noch <check_boxes> beachtet werden. */
										
										break;
									}
									case	FNTS_OPT:						/* beliebiger Button-Text */
									{
										/* hier kînnte jetzt ein applikationsspezifischer */
										/* Dialog (besser Fensterdialog) geîffnet werden */
										/* ...beispielsweise fÅrs Kerning oder...*/
	
										form_alert( 1, "[0][Beispiel fÅr fnts_update().][OK]" );
										break;
									}
								}
							}
						}
				
						fnts_close( fnt_dialog, &x, &y );			/* Fenster des Fontdialogs schlieûen */
					}
					fnts_delete( fnt_dialog, vdi_handle );			/* Speicher fÅr Fontdialog freigeben */
				}
				vst_unload_fonts( vdi_handle, 0 );
				v_clsvwk( vdi_handle );
			}
		}		
		else
			form_alert( 1, "[1][Bitte starten Sie die System-|erweiterung WDIALOG.][Ende]" );

		appl_exit();
	}
	return( 0 );
}
