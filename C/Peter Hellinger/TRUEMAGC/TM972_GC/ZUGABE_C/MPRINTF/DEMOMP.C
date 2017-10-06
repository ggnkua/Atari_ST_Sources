#include "MPRINTF.H"
#include <MATH.H>
#include <SCANCODE.H>

int 	MyWin = -1;	/* Aktuelles Textfenster */
int		done;				/* != 0, wenn Programm fertig ist */
long	TimeOut;		/* Restzeitcounter fr autm. beenden des Programmes */
int		MyTimer;		/* Id des WarteTimers */

/* Der FensterHandler */
WindowHandler DoMyWindow( PtrWinPara wp )
{
	wp->action = 0;
	switch( wp->message )
	{
		case	WinClosed:	wp->action = wClose;
											CallMagic( 98 );
											done = ~0;						break;
	}
	return 0;
}


HandleEvent DemoTimer( PtrEP ep )
{
	tExData ex;
	char		c;
	TimeOut--;
	
	if( !TimeOut )		/* Timer abgelaufen, Programm beenden */
	{
		SendSpecMessage( MyWin,WinClosed,0, 0, &ScreenRect, ex);
		return 0;
	}
	
	/* Timer noch nicht abgelaufen, Restzeit in Sekunden ausgeben */
	mprintf( MyWin, "\rRestzeit: %4lu Sekunden", TimeOut );
	return 0;
}

int DoBreak( void )
{
	if( Alert (-1, -1, 1, "[1|TASTE UNDO][Wollen sie das Programm beenden|][[Ja|[Nein]") == 1 )
	{
		CallMagic( 98 );
		return ~0;
	}
	return 0;						 
}


int DoHelp( void )
{
	if( Alert(-1, -1,  2, "[1|TASTE HELP][Beenden des Programmes durch:|UNDO, CNTRL_C|Schliesen des Fensters|oder TimeOut|Restzeit durch + bzw. Minus „nderbar|][[Ende|[Weiter]") == 1 )
	{
		CallMagic( 98 );
		return ~0;
	}
	return 0;						 
}

/* Keyboardsteuerung */
HandleEvent DemoKeyBoard( PtrEP ep )
{
	tExData ex;

	switch( ep->kascii )
	{
		case 3:		SendSpecMessage( MyWin,WinClosed,0, 0, &ScreenRect, ex);
							CallMagic( 98 );
							break;
							
		case '+':	TimeOut += 10;		break;
		
		case '-':	TimeOut -=  5; if( TimeOut < 1 ) TimeOut = 1;	break;

		case 0:		switch( ep->ktaste )
							{
									case UNDO:	if( DoBreak() )
													SendSpecMessage( MyWin,WinClosed,0, 0, &ScreenRect, ex);
													break;
																	
									case HELP:	if( DoHelp() ) 
													SendSpecMessage( MyWin,WinClosed,0, 0, &ScreenRect, ex);
													break;
							
							}	break;
				
	}

		
	return 0;
}


/* 	Er”ffnen des Textfensters */
void OpenTerm( void )
{
	MyWin = OpenTextwindow((WindowHandler)DoMyWindow, 
													CLOSER | NAME | INFO,	/* Fensterelemente */
													0, 
													-1, -1, 500, 300,			/* Fenstergr”že */
													10,   0,   0,   0,			/* Reservierter Bereich */
													0,   1,								/* Farben */
													100, 10,							/* Font + Zeichengr”že */
													0, 										/* Texteffecte */
													75,										/* Warpposition */
													"DEMO fr mprintf",		/* Fenstertitel */
													"Tastencodes ber HELP",										/* Fenster info */
													NULL );								/* Resourcepointer */
}

void main( void )
{
	int i;
	float f;
	
	ApplInit();		/* Application initialsieren */
	OpenTerm();		/* Textfenster er”ffenen */
	
	if( MyWin >= 0 )
	{
		/* Werte mittels mprintf in Textfenster schreiben */	
		mprintf( MyWin, "Textausgabe \n%s\n\nIntegerausgabe\n","Das ist ein Text" );
		for( i = 1; i < 5; i++ ) mprintf( MyWin, " Zeile: %04u\n", i );
		f = M_PI;
		mprintf( MyWin,"\nReal-Ausgabe\nPi =%9.4g",f );
		
		TimeOut = 30;			/* Wartetimer auf 30 Sekunden einstellen */
		mprintf( MyWin, "\n\nRestzeit: %4lu Sekunden", TimeOut );
		/* Sekundentimer aktivieren */
		MyTimer = InstMUTIMER((HandleEvent) DemoTimer, 1000L );
		InstMUKEYBD((HandleEvent)	DemoKeyBoard );
		
		while( !done ) CentralDispatcher();			/* Programmsteuerschleife */
		
		RemoveMUTIMER( MyTimer );	/* Timer abschalten */
	}
		
	/* Application anmelden */
	ApplTerm( 0 );
}

