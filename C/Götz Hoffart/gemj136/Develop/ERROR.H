#if !defined(__NARGL_ERROR__)
#define __NARGL_ERROR__

#define E_OK	0			/* Ok. Kein Fehler aufgetreten */
#define EINVFN -32      /* Unbekannte Funktionsnummer. */
#define EFILNF -33		/* Datei nicht gefunden. */
#define EPTHNF -34		/* Verzeichnis (Ordner) nicht gefunden. */
#define ENHNDL -35		/* Keine Datei-Handles mehr verfÅgbar. */
#define EACCDN -36		/* Zugriff nicht erlaubt. */
#define EIHNDL -37		/* Datei-Handle war nicht korrekt. */
#define ENSMEM -39		/* Speicher reicht nicht aus. */
#define EIMBA  -40		/* Adresse des Speicherblocks ungÅltig. */
#define EDRIVE -46		/* Laufwerksbezeichnung ungÅltig. */
#define ENSAME -48		/* Dateien auf versch. logischen Laufwerken. */
#define ENMFIL -49		/* Es kînnen keine Dateien mehr geîffnet werden. */
#define ELOCKED -58		/* Bereich einer Datei ist geschÅtzt (Netzwerk). */
#define ENSLOCK -59		/* Angegebenes Locking existiert nicht. */
#define ERANGE  -64		/* Dateizeiger in ungÅltigem Bereich. */
#define EINTRN  -65		/* Interner Fehler des GEMDOS. */
#define EPLFMT  -66		/* UngÅltiges Programm-Format. */
#define EGSBF   -67		/*  Allozierter Speicherblock konnte nicht
                            vergrîûert werden. */
#define EBREAK  -68		/* Programm-Abbruch durch Control-C. */
#define EXCPT   -69		/* 68000er Exception (Bomben). */
#define EPTHOV  -70		/* Pfad öberlauf. */
#define ELOOP   -80		/* Endlosschleife mit symbolischen Links. */

#endif
