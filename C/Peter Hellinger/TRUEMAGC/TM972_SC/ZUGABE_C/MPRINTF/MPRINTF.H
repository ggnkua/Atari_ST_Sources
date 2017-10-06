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
 
 #ifndef __MPRINTF__
 	#define __MPRINTF__
 	
 		/* Einbinden der PureC Headerfiles */
		#include	<stdio.h>
		#include  <stdlib.h>
		#include	<stdarg.h>
		#include	<string.h>
		
		#ifndef __MP400__
			#define __MP400__
			
			#include	<MAGIC.H>
			
		#endif
		
		extern int mprintf( int TextWindow, char *FormatString, ... );
		
#endif
