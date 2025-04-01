/********************************************************************/
/*	EASYFSEL.C																											*/
/*																																	*/
/*	Routine zum leichten und AES-Versions abhÑngigen Aufruf der			*/
/*	GEM-Fileselectorbox mit Auswertung des 'FSEL' - Cookies.				*/
/*	Auûerdem sind einige Routinen zum Umgang mit Dateien enthalten,	*/
/*	sowie zum Suchen eines Cookies.																	*/
/*																																	*/
/*	Version : 1.27																									*/
/*	Datum   : 15.06.1992																						*/
/*	Autor		: Andreas Papula																				*/
/*																																	*/
/*	Copyright 1992 by MAXON Computer GmbH														*/
/********************************************************************/

/*------------------------------------------------------------------*/
/*	Include-Files einbinden.																				*/
/*------------------------------------------------------------------*/

#include <easyfsel.h>

/*------------------------------------------------------------------*/
/*	BOOLEAN easy_fsel(BYTE *pfad, BYTE *dateiname, BYTE *text)			*/
/*																																	*/
/*	Zeigt die Fileselectorbox je nach AES-Version und 'FSEL'-Cookie	*/
/*	an und Åbernimmt die Auswertung.																*/
/*	Bei einer AES-Version >= 0x0014 oder gesetztem 'FSEL-Cookie'		*/
/*	wird fsel_exinput() aufgerufen, sonst fsel_input().							*/
/*																																	*/
/*	Parameter:Pfad und Dateiname, mit denen die Fileselectorbox 		*/
/*						aufgerufen werden soll.																*/
/*	RÅckgabe :TRUE, wenn alles glattging und der Benutzer OK ge-		*/
/*						drÅckt hat, FALSE falls ein Fehler aufgetreten ist		*/
/*						oder Abbruch gewÑhlt wurde.														*/
/*						Der neue Pfad steht in 'pfad', der ausgewÑhlte Datei-	*/
/*						name in 'dateiname'.																	*/
/*------------------------------------------------------------------*/

BOOLEAN easy_fsel(BYTE *pfad, BYTE *dateiname, BYTE *text)
{
	WORD button;
	WORD result;
	LONG c_wert = 0;
	extern GEMPARBLK _GemParBlk;

	/* Entsprechend der Version und des 'FSEL' - Cookies */
	/* fsel_input() oder fsel_exinput() aufrufen */

	if(_GemParBlk.global[0] < 0x0014 && get_cookie("FSEL", &c_wert) == FALSE)
		result = fsel_input(pfad, dateiname, &button);
	else
		result = fsel_exinput(pfad, dateiname, &button, text);

	/* Wenn Fehler aufgetreten oder Abbruch ausgewÑhlt */
	if(result == 0 || button == 0)
		return FALSE;
	else
		return TRUE;
}

/*------------------------------------------------------------------*/
/*	VOID build_filename(BYTE *dest, BYTE *pfad, BYTE *dateiname)		*/
/*																																	*/
/*	Bastelt Pfad- und Dateinamen zusammen.													*/
/*																																	*/
/*	Parameter:dest      = Zielstring.																*/
/*						pfad      = Pfadname.																	*/
/*						dateiname = Dateiname.																*/
/*	RÅckgabe :Das Ergebnis befindet sich in dest.										*/
/*------------------------------------------------------------------*/

VOID build_filename(BYTE *dest, BYTE *pfad, BYTE *dateiname)
{
	BYTE *xyz;

	strcpy(dest, pfad);
	xyz = strrchr(dest, (int) '\\');
	strcpy(++xyz, dateiname);
}

/*------------------------------------------------------------------*/
/*	BOOLEAN exist(const BYTE *dateiname)														*/
/*																																	*/
/*	öberprÅft, ob die Datei 'dateiname' existiert.									*/
/*																																	*/
/*	Parameter:Name der Datei.																				*/
/*	RÅckgabe :TRUE, falls die Datei existiert, FALSE wenn nicht.		*/
/*------------------------------------------------------------------*/

BOOLEAN exist(const BYTE *dateiname)
{
	if(Fsfirst(dateiname, FA_READONLY | FA_HIDDEN | FA_SYSTEM |
												FA_ARCHIVE) == 0)
		return TRUE;
	else
		return FALSE;
}

/*------------------------------------------------------------------*/
/*			BYTE *get_akt_path(BYTE *path)															*/
/*																																	*/
/*			Gibt das aktuelle Laufwerk und dessen Pfad zurÅck.					*/
/*																																	*/
/*			Parameter: Zeiger auf einen String.													*/
/*			RÅckgabe : Zeiger auf das aktuelle Laufwerk und Directory.	*/
/*------------------------------------------------------------------*/

BYTE *get_akt_path(BYTE *path)
{
	strcpy(path, " :");
	path[0] = 'A' + getdisk();  /* Laufwerk */
	getcurdir(0, path+2);				/* Directory */
	return(path);
}

/*------------------------------------------------------------------*/
/*	BOOLEAN get_cookie(BYTE *cookie_name, LONG *cookie_value)				*/
/*																																	*/
/*	Sucht nach einem Cookie 'cookie_name' und liefert dessen Wert		*/
/*	in 'cookie_value' zurÅck.																				*/
/*																																	*/
/*	Parameter:Name des Cookies und einen Zeiger auf den Wert des		*/
/*						Cookies.																							*/
/*	RÅckgabe :TRUE, falls der Cookie gefunden wurde, FALSE falls		*/
/*						nicht.																								*/
/*						In 'cookie_value' steht der Wert des Cookies.					*/
/*------------------------------------------------------------------*/

BOOLEAN get_cookie(BYTE *cookie_name, LONG *cookie_value)
{
	LONG alter_stack;
	LONG *cookiejar;

	/* Zuerst einen Zeiger auf den Cookiejar holen */

	alter_stack = Super (0L);
	cookiejar = *((LONG **) 0x5a0L);
	Super((VOID *) alter_stack);

	/* Ist der Cookiejar vorhanden ? */
    
	if(!cookiejar)
		return FALSE;
	else
	{
		do
		{
			/* Ist es unser Cookie ? */
			if(!strncmp((BYTE *)cookiejar, cookie_name, 4))
			{
				/* Wenn kein NULL-Zeiger, dann Wert des Cookies 
					 eintragen und TRUE zurÅckgeben */

				if(cookie_value)
				{
					*cookie_value = cookiejar[1];
					return TRUE;
				}
			}    
			else
			{
				/* nÑchster Cookie aus Jar */
				cookiejar = &(cookiejar[2]);
			}
		} 
		while(cookiejar[0]);  /* solange nicht NULL-Cookie */
    
		return FALSE;
  }
}

/*----------------------- Ende der Datei. --------------------------*/