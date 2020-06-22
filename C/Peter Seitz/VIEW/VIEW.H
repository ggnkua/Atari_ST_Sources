/*
		VIEW.H
		
	22.03.1993, gsp
*/
#ifndef VIEW__H
#define VIEW__H

int ViewFile(const char *file);
/*
	Sucht einen 'Viewer' und l„žt diesen den File anzeigen.
	Return: 0 = Keinen gefunden
	        1 = OK
	       <0 = Fehler beim Anzeigen
*/

int GetViewerId(void);
/*
	Liefert die AES-ID eines Viewers, falls vorhanden, 
	sonst -1.
	
*/

#endif /* VIEW__H */
