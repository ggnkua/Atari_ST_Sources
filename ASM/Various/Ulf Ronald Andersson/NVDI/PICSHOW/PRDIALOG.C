/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

/*----------------------------------------------------------------------------------------*/ 
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include	<Types2B.h>														/* ProzessorunabhÑngige Datentypen */
#include	<PORTAB.H>														/* KompatibilitÑt */
#include	<TOS.H>															/* GEMDOS-, Bios- und XBios-Funktionen */
#include	<MT_AES.H>														/* AES-Funktionen */

/*----------------------------------------------------------------------------------------*/ 
/* Prototypen																										*/
/*----------------------------------------------------------------------------------------*/ 
PRN_SETTINGS	*read_settings_from_file( void );
void	write_settings_to_file( PRN_SETTINGS *settings );
PRN_SETTINGS	*read_psettings( PRN_DIALOG *prn_dialog );
int16	save_psettings( PRN_SETTINGS *settings );
int16	do_print_dialog( PRN_SETTINGS *settings, int8 *document_name, int16 kind );

/*----------------------------------------------------------------------------------------*/ 
/* Druckereinstellung aus den Programm-Voreinstellungen auslesen									*/
/* Funktionsresultat:	Zeiger auf Druckereinstellung oder 0L										*/
/*----------------------------------------------------------------------------------------*/ 
PRN_SETTINGS	*read_settings_from_file( void )
{
	/* Diese Funktion sollte aus den Voreinstellungen (im Home-Verzeichnis) die Druckereinstellung einlesen */
	return( 0L );
}

/*----------------------------------------------------------------------------------------*/ 
/* Druckereinstellung in den Programm-Voreinstellungen speichern									*/
/* Funktionsresultat:	Zeiger auf Druckereinstellung oder 0L										*/
/*	settings:				Zeiger auf die Druckereinstellung											*/
/*----------------------------------------------------------------------------------------*/ 
void	write_settings_to_file( PRN_SETTINGS *settings )
{
	/* Diese Funktion sollte die Druckereinstellung in den Voreinstellungen (im Home-Verzeichnis) speichern */
}

/*----------------------------------------------------------------------------------------*/ 
/* Gespeicherte Druckereinstellung zurÅckliefern														*/
/* Funktionsresultat:	Zeiger auf Druckereinstellung oder 0L										*/
/*	prn_dialog:				Zeiger auf Verwaltungsstruktur (wenn dauerhaft geîffnet) oder 0L	*/
/*----------------------------------------------------------------------------------------*/ 
PRN_SETTINGS	*read_psettings( PRN_DIALOG *prn_dialog )
{
	PRN_DIALOG		*p;
	PRN_SETTINGS	*settings;

	settings = 0L;

	if ( prn_dialog == 0L )												/* noch nicht offen? */
	{
		p = pdlg_create( 0 );											/* kurzzeitig îffnen */
		if ( p == 0L ) 
			return( 0L );
	
		prn_dialog = p;
	}
	else
		p = 0L;

	settings = read_settings_from_file();							/* Einstellungen aus programmeigener Datei holen */
	
	if ( settings )														/* Einstellungen aus Datei gelesen? */
	{
		if ( pdlg_validate_settings( prn_dialog, settings ) == 0 )	/* schwerwiegender Fehler? */
		{
			Mfree( settings );
			settings = 0L;
		}		
	}

	if ( settings == 0L )
	{
		settings = 	Malloc( pdlg_get_setsize());					/* Speicherbereich anfordern */
		
		if ( settings )
			pdlg_dflt_settings( prn_dialog, settings );			/* und initialisieren */
	}
	
	if ( p )																	/* nur kurzzeitig geîffnet? */
		pdlg_delete( p );

	return( settings );
}

/*----------------------------------------------------------------------------------------*/ 
/* Druckereinstellung speichern																				*/
/* Funktionsresultat:	1: alles in Ordnung																*/
/*	settings:				Druckereinstellung																*/
/*----------------------------------------------------------------------------------------*/ 
int16	save_psettings( PRN_SETTINGS *settings )
{
	if ( settings )
	{
		write_settings_to_file( settings );							/* Druckereinstellung speichern */
		Mfree( settings );												/* Speicher freigeben */
		return( 1 );
	}
	
	return( 0 );
}

/* Hoch/Querformat, Kopien und gerade/ungerade Seiten anbieten */
#define	PRINT_FLAGS	PDLG_ALWAYS_ORIENT + PDLG_ALWAYS_COPIES + PDLG_EVENODD

/*----------------------------------------------------------------------------------------*/ 
/* Druckdialog anzeigen																							*/
/* Funktionsresultat:	0, PDLG_CANCEL oder PDLG_OK													*/
/*	settings:				Druckereinstellung																*/
/*	document_name:			Dokumentenname																		*/
/*	kind:						PDLG_PREFS: Einstelldialog PDLG_PRINT: Druckdialog						*/
/*----------------------------------------------------------------------------------------*/ 
int16	do_print_dialog( PRN_SETTINGS *settings, int8 *document_name, int16 kind )
{
	PRN_DIALOG	*gprn_dialog;
	int16	button;

	gprn_dialog = pdlg_create( PDLG_3D );							/* Speicher anfordern, Treiber scannen */
	if ( gprn_dialog )
	{
		button = pdlg_do( gprn_dialog, settings, document_name, PRINT_FLAGS + kind );
		pdlg_delete( gprn_dialog );									/* Speicher freigeben */
		gprn_dialog = 0L;
		return( button );
	}
	return( 0 );
}
