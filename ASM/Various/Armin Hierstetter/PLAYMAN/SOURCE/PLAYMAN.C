/* ----------------- */
/*  Include-Dateien	*/
/* ----------------- */

#include <portab.h>
#include <aes.h>
#include <tos.h>
#include <sndbind.h>

#include "playman.rh"
#include "playman.rsh"

/* ------------------- */
/*  Globale Variablen  */
/* ------------------- */

int x, y, w, h;

OBJECT *button;

/* --------------------- */
/*  Funktionsprototypen  */
/* --------------------- */

void do_it( void );					/* Hauptschleife des Programms	*/
void open_dial ( int a );			/* Zeichnet eine Dialogbox			*/
void close_dial( void );			/* Schlieût eine Dialogbox			*/
int  handle_dial( int a );			/* Bearbeitet Dialog komplett		*/
void slide_it( int a );				/* Routine fÅr Schieberegler		*/
void get_data( void );				/* Holt aktuelle LautstÑrke		*/

main()
{
	int i, appl_id;
	int msg_buf[8], menu_id;

	appl_id = appl_init( );		/* Beim AES anmelden						*/

	if ( !_app )					/* Als Accessory gestartet?			*/
	{
		menu_id = menu_register(appl_id,"  PlayMan ");

		for ( i = 0; i <= NUM_OBS-1; i++)	/* Resource anfixen		*/
		{
			rsrc_obfix( &rs_object[i], 0 );	/* FÅr jedes Element		*/
		}

		if ( menu_id != -1 )					/* Kein freier Eintrag ?	*/
		{
			while (1)							/* Endlosschleife des ACCs	*/
			{
				evnt_mesag( msg_buf );
				if ( !msg_buf[2] )
				{
					if ( msg_buf[0] == AC_OPEN && msg_buf[4] == menu_id )
						 do_it();					/* Das Hauptprogramm		*/
				}
			}
		}
		else
		{
			form_alert( 1,"[3][ Keine freien | Accessory-EintrÑge [ ABBRUCH ]" );
			appl_exit();
			return -1;
		}
	}
	else
	{
		for ( i = 0; i <= NUM_OBS-1; i++)	/* Resource anfixen		*/
		{
			rsrc_obfix( &rs_object[i], 0 );	/* FÅr jedes Element		*/
		}
		do_it();							/* Das Hauptprogramm	*/
		appl_exit();					/* abmelden und raus	*/
		return 0;
	}
}

void do_it( void )
{
	int but;

	if ( locksnd( ) == SNDLOCKED )		/* Soundsubsystem belegt ?	*/
	{
		form_alert( 1, rs_frstr[LOCKED]);	/* Alertbox zeigen		*/
		return;										/* und tschuess...		*/
	}
	else unlocksnd( );				/* Sound-Subsystem freigeben		*/

	button = rs_trindex[MAIN];

	get_data( );						/* Akutelle Einstellungen holen	*/

	devconnect (ADC,DAC,CLK_25M,CLK50K,NO_SHAKE);
	soundcmd( ADDERIN, 1 );

	graf_mouse( ARROW, 0 );

	do
	{
		open_dial( MAIN );					/* Hauptdialog îffnen		*/
		do
		{
			but = form_do( rs_trindex[MAIN], 0 ) & 0xff;
			switch( but )
			{
				case B_GAIN:
				case B_ATTEN:
					slide_it(but); break;	/* Schieber auswerten		*/
				case B_MUSIK:
				{
					if ( button[B_MUSIK].ob_state & SELECTED )
						soundcmd( ADCINPUT, 0 );	/* Soundquelle = ADC	*/
					else
						soundcmd( ADCINPUT, 3 );	/* Soundquelle = PSG	*/
				}						
			}
		} while( rs_trindex[MAIN][but].ob_flags & TOUCHEXIT );
		rs_trindex[MAIN][but].ob_state &= ~SELECTED;
		close_dial( );	

		if (but == B_INFO)	handle_dial( ABOUT );		/* Infobox	*/

	} while ( but != B_OK );					/* Auf wiederschîn		*/	
}

void open_dial( baum )
{
	/* Dialog zentrieren, Growbox und Dialog zeichnen					*/

	wind_update( BEG_UPDATE );
	form_center(rs_trindex[baum], &x, &y, &w, &h);
	graf_growbox( x + w/2, y + h/2, 0, 0, x, y, w, h);
   form_dial(FMD_START, x + w/2, y + h/2, 0, 0, x, y, w, h);
	objc_draw( rs_trindex[baum] , ROOT, MAX_DEPTH, x, y, w, h);
}

int handle_dial ( baum )
{
	/* Dialog zeichnen, ausfÅhren, lîschen, Exit-Button
		deselktieren und an aufrufende Funktion weitergeben 			*/

	int exit_but;

	open_dial( baum );
	exit_but = form_do(rs_trindex[baum], 0) & 0xFF;
	close_dial(  );

	rs_trindex[baum][exit_but].ob_state &= ~SELECTED;
	return exit_but;
}

void close_dial( void )
{
	/* Shrinkbox zeichnen und Dialog lîschen								*/

	graf_shrinkbox( x + w/2, y + h/2, 0, 0, x, y, w, h);
   form_dial(FMD_FINISH, x + w/2, y + h/2, 0, 0, x, y, w, h);
	wind_update( END_UPDATE );
}

void slide_it( int but )
{
	int init_obx, obx, ht;
	int init_m_x = -123;
	int m_x, m_y, m_k, m_x_last =- 123;
	int dummy;

	init_obx = button[but].ob_x;

	graf_mouse( FLAT_HAND, 0 );
	while ( 1 )
	{
		graf_mkstate( &m_x, &m_y, &m_k,&dummy );
		if(init_m_x == -123) init_m_x = m_x;
		if ( !(m_k & 1 ) ) break;
		{
			if ( m_x != m_x_last )
			{
				obx = init_obx+(m_x-init_m_x);

				if(obx<0) obx=0;				
				if(obx>button[but-1].ob_width - button[but].ob_width)
				{
					obx = button[but-1].ob_width - button[but].ob_width;
				}
				button[but].ob_x = obx;
				if ( m_x_last != m_x )
				{
					m_x_last = m_x;
					ht = ( ( (button[but].ob_width - button[but-1].ob_width)- obx )*15)/(button[but].ob_width - button[but-1].ob_width) -15;
					ht <<= 4;

					if(but==B_GAIN)
					{ 
						objc_draw( rs_trindex[MAIN], but-1, MAX_DEPTH, 0,0,0,0 );
						soundcmd( RTGAIN, ht );
						soundcmd( LTGAIN, ht );
					}
					else if(but==B_ATTEN)
					{
						objc_draw( rs_trindex[MAIN], but-1, MAX_DEPTH, 0,0,0,0 );
						soundcmd( LTATTEN, ht );
						soundcmd( RTATTEN, ht );
					}
				}
			}
		}
	}
	graf_mouse( ARROW, 0 );
}

void get_data( void )
{
	int atten, gain;

	/* Durchschnitt fÅr DÑmpfung und VerstÑrkung des linken und
		rechten Kanals berechnen und neu setzen	*/

	atten = ( soundcmd( LTATTEN, INQUIRE ) +	
			  soundcmd( RTATTEN, INQUIRE ) ) / 2;
	gain = ( soundcmd( LTGAIN, INQUIRE ) + 
			  soundcmd( RTGAIN, INQUIRE ) ) / 2;

	/* Schieberegler im Dialog anpassen	*/

	button[B_GAIN].ob_x = ( ( button[B_GAIN-1].ob_width - 
	button[B_GAIN].ob_width ) / 15 ) * gain/16;

	button[B_ATTEN].ob_x = ( ( button[B_ATTEN-1].ob_width -
	button[B_ATTEN].ob_width ) / 15 ) * atten/16;

	/* Button "Musik" in AbhÑngigkeit der akutellen Einstellungen
		des ADCINPUT setzen. */

	if ( soundcmd( ADCINPUT, INQUIRE) == 0 )
		button[B_MUSIK].ob_state = SELECTED;
	else
		button[B_MUSIK].ob_state = NORMAL;
}
