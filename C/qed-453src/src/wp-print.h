/*
 * Schnittstelle fÅr ASCII-Druckfunktionen, die einen Wordplus-Treiber
 * benutzen.
 * Basiert auf Modula2-Quellen von Uwe Mindrup, 1993
 * PureC-Portierung von Christian Felsch, 1995
 *
 *  Druckertreiber;
 *  Der Druckertreiber dient dazu, Texte mit Hilfe der reichlich vorhandenen
 *  Druckeranpassungen fÅr Wordplus ausdrucken zu kînnen. Zur Initialisierung
 *  muû eine CFG-Datei geladen werden.
 *  Aufbau einer CFG-Datei:
 *  - Header 'GST-CFG:'; dient als Kennung zur Unterscheidung von anderen
 *                       Formaten.
 *  - Es folgen sechs Bytes mit folgender Bedeutung:
 *    (1)   1 fÅr Typenrad mit horizontalem Spacing, sonst 0
 *    (2)   Zeichenbreite in Druckereinheiten (Typenrad)
 *    (3)   Zeilenabstand in Druckereinheiten
 *    (4)   Wagenmitte (Typenrad); Pixel/Inch (Matrixdrucker)
 *    (5)   Zeichenabstand bei Fettdruck (Typenrad)
 *    (6)   1 Pause mit Abfrage zwischen Seiten, sonst 0
 *    Diese Werte werden vom vorliegenden Modul ignoriert.
 *
 *  - Jetzt folgen die Druckercharakteristiken.
 *    Diese Tabelle enthÑlt die Steuersequenzen, die zur Steuerung des
 *    Druckers benutzt werden (hoch, tief, fett, unterstrichen, kursiv,
 *    Draft, NLQ etc).
 *    Die Tabelle endet mit einem Null-Byte.
 *  - Zuletzt folgt die öbersetzungstabelle. Hier werden einzelne Zeichen
 *    in andere Zeichen (-folgen) umgesetzt.
 *    Auch diese Tabelle endet mit einem Null-Byte.
 *
 *  Bei einer Initialisierung werden alle Aussschaltsequenzen der aktuellen
 *  DruckqualitÑt sowie die horizontale und vertikale Initialisierung durch-
 *  laufen.
 *  Sind die Sequenzen der Druckercharakteristiken fÅr die beiden
 *  DruckqualitÑten gleich (unterscheiden sich also nur durch die Ein/Ausschalt-
 *  sequenz fÅr NLQ/Draft), dann reicht es aus, nur bei einer Ausschaltsequenz
 *  die entsprechende SchriftqualitÑt zu setzen (am besten bei einer selten
 *  benîtigten Sequenz, z.B. Index unten).
 *  Mehr noch: FÅr die Åbrigen Druckercharakteristiken reicht es aus, wenn die
 *  Sequenz nur in der einen SchriftqualitÑt gesetzt wird. Der Treiber setzt die
 *  Sequenz automatisch auch fÅr die andere SchriftqualitÑt ein.
 *
 */
#ifndef _wp_print_h_ 
#define _wp_print_h_ 

#define PICA       0    /* 10 cpi */
#define ELITE      1    /* 12 cpi */
#define CONDENSED  2    /* 17 cpi */
#define EXPANDED   3    /*  6 cpi */
/* 
 * Werte fÅr die Zeichenbreite (SetMode)
*/


extern bool	wp_load_cfgfile	(char *name);
/* 
 * Erîffnung einer CFG-Datei. Der komplette Dateiname muû Åbergeben werden.
 * Die Extension wird ggfs. automatisch korrigiert.
 * Die Datei wird nach Erîffnung auf die Dateikennung in den ersten 8 Bytes
 * ÅberprÅft ('GST-CFG:'). 
*/

extern void	wp_get_prnname		(char *Printername, int max_len);
/* 
 * Eingetragenen Druckernamen liefern. Falls keiner vorhanden ist, dann
 * wird ein Leerstring ('') geliefert.
 * max_len begrenzt die NamenslÑnge.
*/

extern bool	wp_send_exit		(void);
/* 
 * Es wird Eintrag 21H (Allgemeiner Druckerreset am Textende) gesendet.
*/

extern bool	wp_send_init		(bool use_nlq);
/*
 * Drucker-Initialisierung senden. Es werden nacheinander folgende
 * EintrÑge geschickt (in Klammern die NLQ-EintrÑge):
 * - Eintrag 20H       Horizontale Initialisierung
 * - Eintrag 1FH       Vertikale Initialisierung
 * - Eintrag  7H ( 9H) Fettschrift aus.
 * - Eintrag  BH ( DH) Kursivschrift aus.
 * - Eintrag  FH (11H) Light aus.
 * - Eintrag 13H (15H) Superscript aus.
 * - Eintrag 17H (19H) Subscript aus.
 * - Eintrag 1BH (1DH) Unterstreichung aus.
 * - Falls vorhanden, werden noch die folgenden Sequenzn geschickt:
 * - Eintrag 28H (29H) PICA (10 CPI).
 * - Eintrag 30H       Color-Einstellung: Black.
 * - Eintrag 35H       Proportional-Schrift wird ausgeschaltet.
*/

extern bool	wp_set_mode			(int Mode);
/*
 * Zeichenbreite einstellen.
 *   Achtung: vorher 'SendInit' durchfÅhren!
 *   UnterstÅtzt werden:
 *   - PICA      = 0;    (* 10 cpi *)
 *   - ELITE     = 1;    (* 12 cpi *)
 *   - CONDENSED = 2;    (* 17 cpi *)
 *   - EXPANDED  = 3;    (*  6 cpi *)
*/

extern bool	wp_formfeed			(void);
/* 
 * Seitenvorschub ausgeben
*/

extern void	wp_set_tabsize		(int tab);
/* 
 * Tabulatorweite einstellen
*/

extern bool	wp_write				(char ch);
extern bool	wp_write_string	(char *Str);
extern bool	wp_write_ln			(void);

extern bool	wp_open				(char *Name);
/* 
 * Erîffnung eines Druckerkanals
*/

extern void	wp_close				(void);
/* 
 * Schlieûung eines Druckerkanals
*/

#endif
