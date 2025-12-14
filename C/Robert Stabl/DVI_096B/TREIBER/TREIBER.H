/*******************************************************************
 *******************************************************************
 ** Routinen aus Treiber.c (c)'93 m.pristovsek                    **
 ** Diese Routinen sind in TREIBER.C und FAST_DVI.S definiert     **
 *******************************************************************
 *******************************************************************/


/*******************************************************************
 * DIE Arbeitsroutine im eigentlichen Modul (als Parametercheck!)  *
 * Diese Routine ist druckerspezifisch                             *
 *******************************************************************
 * Sie gibt das Handle der Zwischendatei zurÅck, oder -1, wenn sie *
 * selber fÅr den Druck sorgt (wie beim SLM804 und JP350ws)        *
 * Ist der RÅckgabewert >0, dann wird diese Datei an die parallele *
 * Schnittstelle geschickt.                                        *
 *******************************************************************
 * Man sollte immer testen, ob es u.U. mit Zwischendatei nicht     *
 * schneller oder genauso schnell ist, denn dann kann man viel     *
 * Arbeit sparen, man muû sich nicht mehr um die Ausgabe kÅmmern   *
 * Die Breite einer Bitmap in Bytes erhÑlt man durch:              *
 *                    ((weite+15)/16)*2                            *
 *******************************************************************
 * GROSSE VARIABLEN AUSSERHALB ALLER FUNKTIONEN UND STATISCH       *
 * DEKLARIEREN, SONST GIBT ES U.U. STACKöBERLAUF!                  *
 *******************************************************************/
int	drucke( char *bitmap, long weite, long hoehe, long h_dpi, long v_dpi );


/*******************************************************************
 * ôffnet eine temporÑre Datei mit der Endung "drucker_ext" zum    *
 * Zwischenspeichern und liefert Handle zurÅck. (Fehler <0)        *
 * Dieses Handle sollte die Funktion "drucke" (s.o.) zurÅckgeben.  *
 *******************************************************************
 * "drucker_ext": String mit druckerspezifische Endung             *
 * Bei Epson9 z.B. "n9"                                            *
 *******************************************************************
 * Wird der Treiber zum Drucken in Datei aufgerufen, wird das      *
 * Handle der angesprochenen Datei zurÅckgeliefert und die Daten   *
 * an diese angehÑngt                                              *
 *******************************************************************/
int		get_tempfile( char *drucker_ext );
/* 6.2.93 */



/*==================================================================*
 " Folgende Routinen sind allgemein zur Eingrenzung des Bereiches,  "
 " der gedruckt werden soll, interessant                            "
 *==================================================================*/

/*******************************************************************
 * Ist diese Zeile Leerzeile? (d.h. sind "offset" Bytes==0?)       *
 *******************************************************************
 * "ptr": Zeiger auf Bitmap            "offset":  Breite in Bytes  *
 *******************************************************************/
int	ist_leerzeile( char *ptr, long offset );
/* 16.1.93 */


/*******************************************************************
 * Sind in den nÑchsten #next-Zeilen keine Zeichen? D.h. damit kann*
 * man z.B den linken Rand bestimmen.                              *
 *******************************************************************
 * "ptr":  Zeiger auf Bitmap           "offset":  Breite in Bytes  *
 * "next":  Anzahl zu testender Zeilen                             *
 *******************************************************************/
int	ist_next_leer( char *ptr, long offset, long next );
/* 16.1.93 */


/*==================================================================*
 " Folgende Routinen sind nur bei eigener Druckausgabe interressant "
 " Als Beispiel siehe HP.C, denn dort wird fÅr das Drucken in eine  "
 " Datei extra eine andere Routine aufgerufen: Nur geht es so halt  "
 " VIEL schneller                                                   "
 *==================================================================*/

/*******************************************************************
 * Versucht Drucker zu ôffnen und die Semaphore 'PRN:' zu bekommen *
 * Leider kann man die Datei "U:\dev\prn" nicht verriegeln; deshalb*
 * wurde die Semaphore eingefÅhrt.                                 *
 *******************************************************************
 * Der RÅckgabewert ist >0 (das Handle der Druckerdatei) oder im   *
 * Fehlerfall negativ                                              *
 *******************************************************************/
int	open_printer( void );
/* 6.2.93 */


/*******************************************************************
 * Gibt die "len" Daten ab "blk" an Spooler weiter (umgeht GEMDOS) *
 * Gleichzeitig sorgt diese Funktion fÅr das Blinken *+*+*+ ...    *
 *******************************************************************/
void	print_block( long len, char *blk );
/* 22.1.93 */


/*******************************************************************
 * Leert Spoolerspeicher, MUSS vor dem Druckende aufgerufen werden!*
 *******************************************************************/
void	flush_block( void );
/* 23.1.93 */

