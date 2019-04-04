/************************************************************************
 * Datei: FName.c    	Zweck: 	Dateinamen-Behandlung					*
 * Autor: RSB                                                           *
 * Datum 23.05.90       Grund: 	TOS-Magazin								*
 ************************************************************************/

#define _SLASH '\\'

/************************************************************************
 * Dateiname aufspalten													*
 *	Die Funktion spaltet den angegebenen Dateinamen in seine maximal 	*
 *	vier Bestandteile auf und schreibt diese in drive, path, node und 	*
 *	ext. Ist eines dieser Argumente NULL, so wird die Komponente 		*
 *	verworfen.															*
 ************************************************************************/

void strsfn(const char *file, char *drive,char *path,char *node,char *ext);

/************************************************************************
 * Dateiname aus node und path zusammenfÅgen							*
 *  Beispiele:		Pfad				Dateiname						*
 *					"SWAPDEMO.C"		"SWAPDEMO.C"					*
 *					"\tc.backup\ls"		"ls"							*
 *					"c:ls"				"ls"							*
 *					"\tc.backup\"		""								*
 ************************************************************************/

void strmfp(char *name, char *path, char *node);

/************************************************************************
 * Pfadnamen ermitteln													*
 *	Die Funktion ermittelt aus einem beliebigen Dateinamen den Pfad und	*
 *	legt ihn in path ab.												*
 *  Beispiele:		Dateiname			Pfad							*
 *					"SWAPDEMO.C"		""								*
 *					"\tc.backup\ls"		"\tc.backup\"					*
 ************************************************************************/

int stcgfp(char *path, char *name);

