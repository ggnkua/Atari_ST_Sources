/* ===============================================================
	 Erweiterung des MPTERMIN um die Funktion mptintf
	 
	 Cpmpiler:	PureC 1.1
	 Autor:			Uwe Kornnagel		(C) 1994
	 
	 Tool zu MAGIC 400
	 
	 ---------------------------------------------------------------
	 
	 Copyrightvermerk:
	 
	 Dieses Tool ist nicht PD und an MAGIC 400 gebunden. Es darf nur
	 in Verbindung mit MAGIC 400 weitergegeben werden.
	 
	 mprintf darf nur im Sourcecode an andere Anwender verteilt werden.
	 
	 Jeder registrierte MAGIC Anwender hat die Erlaubnis, diese Tool
	 kostenfrei in seinen Programmen zu verwenden. 
	 
	 Komerzielle Nutzung in Verbindung mit MAGIC 400 ist gestattet.
	 
	 
	 ----------------------------------------------------------------
	 
	 mprintf wurde sorgfÑltig getestet, so das man davon ausgehen
	 kann, daû die wesentlichtsten Bugs entfernt wurden. Es kann 
	 aber keine Garantie dafÅr Åbernommen werden, daû durch unter-
	 schiedliche Systemlibs, Fehler auftreten. Der Autor Åbernimmt
	 keinerlei Haftung fÅr mittelbare oder unmittelbare SchÑden die
	 durch mprintf verursacht wurden.

	 ----------------------------------------------------------------
	 
	 Fehlerkorrektur in MPTERMIN.H 1.38
	 
	 1. #include <MPWINDOW.H>   ergaenzen
	 2. Definition von OpenTextwindow berichtigen
	 
		int OpenTextwindow(WindowHandler handler,			
												BITSET, BITSET,
												int, int, int, int, int,
												int, int, int,
                        int, int, int, int, BITSET, int,
                        const char *, const char *, OBJECT *);
                        

 ================================================================== */
 
 #include "mprintf.h"
 
 /* die Funktion mprintf selbst:
    mprintf( TextWindow, FormatString, Ausgabewerte );
    
    Parameter:  		TextWindow = Handle des Windows wird von
                		OpenTextWindow geliefert.
                
    FormatString:		siehe  printf, sprintf, fprintf .....
    
    Ausgabewerte:		siehe  printf, sprintf, fprintf .....
    
 */
 
int mprintf( int TextWindow, char *FormatString, ... )
{
 va_list  argptr;			/* Pointer auf die Agumentenliste	*/
  char *str, *c, *d;	/* TemporÑrer Ausgabbuffer, und Splittpointer	*/
  int cnt;						/* Anzahl der ausgegebenen Zeichen */

  va_start( argptr, FormatString );		/* Initialisiere va_ Funktions	*/
  cnt = 0;
  str = calloc( 1, 0x2000 );					/* Ausgabepuffer max 8kb */
  if( str )
  {
  	/* Ausgabestring zusammensetzen */
	  vsprintf( str, FormatString, argptr ); 
	 	c = d = str;
	 	
	 	/* Teilsstrings ausgeben */
	 	while( *d )
	 	{
	 		c = strchr( d, '\n' );		/* suche nÑchstes LF */
	 		if( !c ) break;						/* keines da, dann letzeter Teilstirng */
	 		*c++ = 0;									/* LF ausblenden */
	 		if( *d )									/* wenn vor LF kein Leerstring ist */
	 		{
		 		cnt += strlen( d );						/* Anzahl korrigieren */
		 		WriteLine( TextWindow, d );		/* Teilstring ins Text-Fenster */
		 	}
		 	cnt += 2;								/* Anzahl korrigieren */
	 		WriteLn( TextWindow );	/* neue Zeile im Fenster */
	 		
	 		d = c;									/* weiter mit nÑchstem Teilstring */
	 	}
	 	
	 	if( *d )				/* Falls noch ein Reststring vorhanden ist */
	 	{
	 		cnt += strlen( d );						/* Anzahl korrigieren */
	 		WriteLine( TextWindow, d );		/* Reststring ins Textfenster */
	 	}
	 	
	 	free( str );			/* temporÑren Buffer freigeben */
	}
	
	va_end( argptr );			/* Argumentenliste schliessen */
	return cnt;						/* Anzahl der ausgegebenen Zeichen liefern */
}

/* ===================================================================== */
