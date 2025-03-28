/*3456789012345678901234567890123456789012345678*/
/*
 * errortxt.h
 *
 * EnthÑlt Textarrays fÅr GEMDOS- und BIOS-
 * Fehlermeldungen.
 *
 * History:
 * 04.09.1994: Erstellung
 */

/* Maximale negative Fehlernummer */
#define MAX_NEG_ERRNR	-67
/* Maximale positive Fehlernummer */
#define MAX_POS_ERRNR	2
/* Unbekannter Fehler */
#define UNKNOWN	"Unbekannter Fehler"

/* Das Array fÅr die negativen Fehlernummern */
char	*neg_err_txt[] =
		{
/* 0 */		"OK",
/* 1 */		"Unbestimmter Fehler",
/* 2 */		"GerÑt nicht bereit",
/* 3 */		"Unbekanntes Kommando",
/* 4 */		"CRC-Fehler",
/* 5 */		"Falsches Befehlsformat",
/* 6 */		"Spur nicht gefunden",
/* 7 */		"Unbekanntes Format",
/* 8 */		"Sektor nicht gefunden",
/* 9 */		"Drucker nicht bereit",
/* 10 */	"Schreibfehler",
/* 11 */	"Lesefehler",
/* 12 */	"Allgemeiner Fehler",
/* 13 */	"Medium schreibgeschÅtzt",
/* 14 */	"Medienwechsel aufgetreten",
/* 15 */	"Unbekanntes GerÑt",
/* 16 */	"Formatierfehler",
/* 17 */	"Diskette wechseln",
/* 18 */	"Medium einlegen",
/* 19 */	"GerÑt antwortet nicht",
/*3456789012345678901234567890123456789012345678*/
/* 20-23 */	UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN,
/* 24-27 */	UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN,
/* 28-31 */ UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN,
/* 32 */	"Unbekannte Funktion",
/* 33 */	"Datei nicht gefunden",
/* 34 */	"Pfad nicht gefunden",
/* 35 */	"Zu viele offene Dateien",
/* 36 */	"Zugriff verweigert",
/* 37 */	"Falsches Dateihandle",
/* 38 */	UNKNOWN,
/* 39 */	"Zu wenig Speicher",
/* 40 */	"Falsche Speicheradresse",
/* 41-44 */	UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN,
/* 45 */	UNKNOWN,
/* 46 */	"UngÅltige Laufwerkskennung",
/* 47 */	UNKNOWN,
/* 48 */	"Verschiedene Laufwerke",
/* 49 */	"Keine weiteren Dateien",
/* 50-53 */	UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN,
/* 54-57 */	UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN,
/* 58 */	"Datei gesperrt",
/* 59 */	"Sperre existiert nicht",
/* 60-63 */	UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN,
/* 64 */	"Dateizeiger ungÅltig",
/* 65 */	"Interner GEMDOS-Fehler",
/* 66 */	"Datei nicht ausfÅhrbar",
/* 67 */	"Speicherblock vergrîûert"
		};

/* Array fÅr positive Fehlernummern */
char	*pos_err_txt[] =
		{
/* 0 */		"OK",
/* 1 */		"Allgemeiner Fehler",
/* 2 */		"Fehler in Parametern"
		};

/* EOF */
