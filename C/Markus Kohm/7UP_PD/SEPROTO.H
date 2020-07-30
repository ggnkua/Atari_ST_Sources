/* SE-Protokoll zur Kommunikation zwischen Shells zur Programmentwicklung
 * und Editoren. (c) DIRK STEINS @K2.MAUS.DE
 *
 * Dieses Protokoll dient dazu, unter Multitasking-Systemen die Shell
 * zur Compilierung und Ñhnlichen Sachen zu veranlassen, und um Fehler-
 * meldungen und/oder Fehlerdateien an den Editor zurÅckzugeben.
 *
 * Kommandos bzw. Nachrichten von der Shell zum Editor beginnen
 * mit SE_, Nachrichten vom Editor zur Shell beginnen mit ES_
 *
 * Da teilweise Zeiger auf Speicherbereiche Åbergeben werden, ist vom
 * jeweiligen Absender der Nachricht darauf zu achten, daû diese
 * Speicherbereiche vom EmpfÑnger auch lesbar sind (Memory Protection!).
 * DafÅr sind diese als Readable zu allozieren!
 *
 * Version  Datum       énderungen
 * =====================================================================
 *   0.1    10.1.94     Erster Entwurf
 *   0.2    17.1.94     SE_TERMINATE hinzugefÅgt
 */

#define SE_INIT 0x4200
    /* Die Shell fragt an, ob ein Editor das SE-Protokoll
     * versteht.
     * Wort 3: Ein Bitset, welche Nachrichten die Shell versendet
     * Wort 4+5: Ein Bitset, welche Editorkommandos verstanden werden
     * Wort 6: UnterstÅtze Versionsnummer des Protokolls
     * Als Antwort erhÑlt es ein ES_OK vom  Editor.
     */
#define SE_OK 0x4201
    /* Die Shell sagt dem Editor, das sie das Protokoll
     * versteht.
     * Wort 3: Ein Bitset, welche Nachrichten die Shell versendet
     * Wort 4+5: Ein Bitset, welche Editorkommandos verstanden werden
     * Wort 6: UnterstÅtze Versionsnummer des Protokolls
     * Wort 7: Die ApId des Programmes, dessen Nachricht beantwortet wird
     */
#define SE_ACK 0x4202
    /* Die Shell bestÑtigt den Empfang eines Editorkommandos und gibt
     * zurÅck, ob das Kommando ausgefÅhrt wird.
     * Wort 3: TRUE: Kommando wird verstanden und ausgefÅhrt.
     *         FALSE: Das Kommando wird nicht verstanden
     * Eine SE_ACK mit TRUE sagt nichts darÅber aus, ob das Kommando erfolg-
     * reich ausgefÅhrt wurde. Es sagt nur, daû die Shell das Kommando
     * versteht und ausfÅhren wird!
     */
#define SE_OPEN 0x4203
    /* Die Shell sagt dem Editor, daû er einen Text îffnen
     * soll. Als Antwort erhÑlt die Shell ein ES_ACK
     * Wort 3+4: Ein Zeiger auf den Filenamen des zu îffnenden Files
     */
#define SE_ERROR 0x4204
    /* Es ist ein Fehler beim Compilieren aufgetreten.
     * Wort 3+4: Ein Zeiger auf eine Infostruktur, die wie folgt
     *           aufgebaut ist:
     *           Wort 0+1: Ein Zeiger auf den Namen des compilierten Textes.
     *           Wort 2+3: Ein Zeiger auf den Text der Fehlermeldung
     *           Wort 4  : Die Fehlernummer
     *           Wort 5  : Die Fehlerspalte
     *           Wort 6+7: Die Fehlerzeile
     * Mit ES_ACK bestÑtigt der Editor die Meldung.
     */
#define SE_ERRFILE 0x4205
    /* Es sind Fehler aufgetreten. Die Fehlermeldungen stehen in einem
     * Errorfile, welches in der Message spezifiziert wird.
     * Wort 3+4: Ein Zeiger auf den Filenamen des Errorfiles mit den
     *           Fehlermeldungen
     * Wort 5+6: Ein Zeiger auf den Namen des compilierten Textes
     * Mit ES_ACK bestÑtigt der Editor die Meldung.
     */
#define SE_PROJECT 0x4206
    /* Die Shell teilt dem Editor mit, daû das Projekt
     * geÑndert wurde. Der Filename des aktuellen
     * Projektfiles wird als Parameter Åbergeben
     * Wort 3+4: Ein Zeiger auf den Namen des Projektfiles
     * Der Editor bestÑtigt mit ES_ACK.
     * Eine vernÅnftige Reaktion des Editors wÑre es in dem Fall,
     * ebenfalls das Projekt zu wechseln, sofern er diese unterstÅtzt.
     */
#define SE_QUIT 0x4207
    /* Die Shell teilt dem Editor mit, daû sie jetzt beendet wird.
     * Der Editor sollte in dem Fall die Shell als Kommunikationspartner
     * vergessen.
     * Parameter gibt es keine.
     * Es wird keine Antwort erwartet!
     */
#define SE_TERMINATE 0x4208
    /* Die Shell teilt dem Editor mit, daû dieser sich beenden soll.
     * Der Editor sollte in dem Fall sich selbst beenden und seinen ganz
     * normalen Terminierungsprozeû durchlaufen (und in dem auch ein
     * ES_QUIT schicken!). Der Grund fÅr so eine Meldung der Shell kînnte
     * zum Beispiel zu wenig Speicher zum compilieren sein.
     * Mit ES_ACK bestÑtigt der Editor die Meldung.
     */

#define ES_INIT 0x4240
    /* Ein Editor fragt an, ob eine Shell das SE-Protokoll versteht.
     * Wort 3: Ein Bitset, welche Shellnachrichten verstanden werden
     * Wort 4+5: Ein Bitset, welche Editorkommandos versendet werden
     * Wort 6: UnterstÅtze Versionsnummer des Protokolls
     * Als Antwort erhÑlt es SE_OK von der Shell
     */
#define ES_OK 0x4241
    /* Der Editor beantwortet die Anfrage der Shell nach dem Protokoll.
     * Wort 3: Ein Bitset, welche Shellnachrichten verstanden werden
     * Wort 4+5: Ein Bitset, welche Editorkommandos versendet werden
     * Wort 6: UnterstÅtze Versionsnummer des Protokolls
     * Wort 7: Die ApId des Programmes, dessen Nachricht beantwortet wird
     */
#define ES_ACK 0x4242
    /* Der Editor bestÑtigt den Empfang des Kommandos
     * Wort 3: TRUE: Kommando wird verstanden und ausgefÅhrt.
     *         FALSE: Das Kommando wird nicht verstanden
     * Eine ES_ACK mit TRUE sagt nichts darÅber aus, ob das Kommando erfolg-
     * reich ausgefÅhrt wurde. Es sagt nur, daû der Editor das Kommando
     * versteht und ausfÅhren wird!
     */
#define ES_COMPILE 0x4243
    /* Der Editor sagt der Shell, daû sie ein File Åbersetzen soll.
     * Ein Pointer auf den Dateinamen wird in der Message Åbergeben.
     * Wort 3+4: Zeiger auf den Namen der zu compilierenden Datei.
     * Diese Nachricht muû mit SE_ACK bestÑtigt werden.
     */
#define ES_MAKE 0x4244
    /* Der Editor sagt der Shell, daû sie ein Make ausfÅhren soll.
     * Ein Filename kann in der Message Åbergeben werden, muû aber
     * nicht gesetzt sein und muû von der Shell auch nicht beachtet
     * werden!
     * Wort 3+4: Zeiger auf den Namen des Makefiles (oder NULL)
     * Die Shell bestÑtigt mit SE_ACK.
     */
#define ES_MAKEALL 0x4245
    /* Der Editor sagt der Shell, daû ein komplettes Make All ausgefÅhrt
     * werden soll. Ein Filename fÅr das Makefile kann (muû nicht) in
     * der Message Åbergeben werden.
     * Wort 3+4: Zeiger auf den Namen des Makefiles (oder NULL)
     * Die Shell bestÑtigt mit SE_ACK.
     */
#define ES_LINK 0x4246
    /* Der Editor sagt der Shell, daû das Programm
     * gelinkt werden soll. Ein Filename kann
     * in der Message Åbergeben werden, muû aber
     * nicht unbedingt beachtet werden von der Shell!
     * Wort 3+4: Zeiger auf den Namen der Source, die gelinkt werden soll
     *           (oder NULL)
     * Die Shell bestÑtigt mit SE_ACK.
     */
#define ES_EXEC 0x4247
    /* Der Editor sagt der Shell, daû das Programm
     * zu der Source ausgefÅhrt werden soll. Ein
     * Filename kann Åbergeben werden, muû von der
     * Shell aber nicht beachtet werden.
     * Wort 3+4: Zeiger auf den Namen des auszufÅhrenden Files (oder NULL)
     *           Bei einer Sourcedatei ist diese ggf. noch zu
     *           compilieren und/oder zu linken
     * Die Shell bestÑtigt mit SE_ACK.
     */
#define ES_MAKEEXEC 0x4248
    /* Die Shell soll ein Make ausfÅhren und danach das Programm ausfÅhren.
     * Ein Filename fÅr das Makefile kann (muû nicht) in der Message
     * Åbergeben werden.
     * Wort 3+4: Zeiger auf den Namen des Makefiles (oder NULL)
     * Die Shell bestÑtigt mit SE_ACK.
     */
#define ES_PROJECT 0x4249
    /* Der Editor teilt der Shell mit, daû das Project
     * geÑndert/gewechselt wurde. Der Filename des
     * Projektfiles wird als Parameter in der Message
     * Åbergeben.
     * Wort 3+4: Zeiger auf den Namen des Projektfiles
     * Die Shell bestÑtigt mit SE_ACK.
     * Eine vernÅnftige Reaktion der Shell wÑre in dem Fall, ebenfalls
     * das Projekt zu wechseln, sofern es diese unterstÅtzt.
     */
#define ES_QUIT 0x424A
    /* Der Editor teilt der Shell mit, daû er jetzt beendet wird.
     * Die Shell sollte in dem Fall den Editor als Kommunikationspartner
     * vergessen.
     * Parameter gibt es keine.
     * Es wird keine Antwort erwartet!
     */

#define SE_DATA 0
    /* Nur fÅr Typdeklaration benutzt, eigentlich ÅberflÅssig
     */

#define SEPROTOVERSION 0x0100 /* Die Versionsnummer des Protokolls.
                               * Highbyte ist die Major Number
                               * Lowbyte ist die Lower Number
                               */

/* Typdefinitionen fÅr die Nachrichten
 */

/* Dies definiert die einzelnen Bits, welche Nachrichten unterstÅtzt werden
 */
#define seInit     0x0001
#define seOk       0x0002
#define seAck      0x0004
#define seOpen     0x0008
#define seError    0x0010
#define seErrfile  0x0020
#define seProject  0x0040

#define esInit     0x0001
#define esOk       0x0002
#define esAck      0x0004
#define esCompile  0x0008
#define esMake     0x0010
#define esMakeall  0x0020
#define esLink     0x0040
#define esExec     0x0080
#define esMakeexec 0x0100
#define esProject  0x0200

typedef struct
{
   char *errfile; /* Zeiger auf den Namen der compilierten Datei */
   char *errmess; /* Zeiger auf die Fehlermeldung */
   WORD  errnum;  /* Die Fehlernummer */
   WORD  errcol;
   LONG  errline;
}ERRINFO;

/*
TYPE    tShellCommands = (seInit, seOk, seAck, seOpen, seError, seErrfile,
                          seProject);

        tEditCommands  = (esInit, esOk, esAck, esCompile, esMake, esMakeall,
                          esLink, esExec, esMakeexec, esProject);

        tPtrString  = POINTER TO ARRAY [0..255] OF CHAR;
        /* Zeiger auf einen nullterminierten String
         */

        LONGBITSET  = SET OF [0..31];
        /* Leider kennt das nicht jeder Compiler
         */

        tErrInfo     = RECORD
                        errFile : tPtrString;
                        /* Zeiger auf den Namen der compilierten Datei
                         */
                        errMess : tPtrString;
                        /* Zeiger auf die Fehlermeldung
                         */
                        errNum  : INTEGER;
                        /* Die Fehlernummer
                         */
                      END;
        tPtrErrInfo = POINTER TO tErrInfo;


        /* öber diese Recorddefinition kann man alle
         * Messages des Protokolls behandeln
         */

        tMessRec    = RECORD
                        msg     : INTEGER;
                        /* Messagenummer, Wort 0 */
                        apId    : INTEGER;
                        /* Applikation ID des Senders, Wort 1 */
                        overLen : INTEGER;
            /* öberlÑnge der Nachricht (immer 0 fÅr SE-Protokoll), Wort 2 */
                        CASE : CARDINAL OF
                          SE_INIT,
                          ES_INIT   : shellBits: BITSET;
                          /* Bits, die angeben, welche Shell-Nachrichten
                           * unterstÅtzt werden (Wort 3)
                           */
                                      editBits : LONGBITSET;
                          /* Bits, die angeben, welche Editor-Nachrichten
                           * unterstÅtzt werden (Worte 4 und 5)
                           */
                                      version  : CARDINAL;
                          /* UnterstÅtze Versionsnummer des Protokolls
                           * Aktuell: $100
                           */
                        | SE_OK,
                          ES_OK     : okShellBits: BITSET;
                          /* Bits, die angeben, welche Shell-Nachrichten
                           * unterstÅtzt werden (Wort 3)
                           */
                                      okEditBits : LONGBITSET;
                          /* Bits, die angeben, welche Editor-Nachrichten
                           * unterstÅtzt werden (Worte 4 und 5)
                           */
                                      okVersion: CARDINAL;
                          /* UnterstÅtze Versionsnummer des Antwortenden
                           * Aktuell: $100
                           */
                                      otherId  : INTEGER;
                          /* Die ApId des Senders, auf das dies eine Antwort
                           * ist (Wort 7)
                           */
                        | SE_ACK,
                          ES_ACK    : acknowledge:  BOOLEAN;
                          /* TRUE: Kommando wurde akzeptiert,
                           * FALSE: Kommando konnte nicht ausgefÅhrt werden
                           */
                        | SE_OPEN   : namePtr   : tPtrString;
                          /* Zeiger auf den Namen des zu ladenden Textes
                           * (Worte 3 und 4)
                           */
                        | SE_ERROR  : errorPtr  : tPtrErrInfo;
                          /* Zeiger auf Speicherbereich, der die
                           * Fehlermeldung spezifiziert.
                           */
                                      errorRow  : INTEGER;
                          /* Die Spalte, in der der Fehler aufgetreten ist
                           * (Wort 5)
                           */
                                      errorLine : LONGINT;
                          /* Die Zeile, in der der Fehler aufgetreten ist
                           * (Worte 6 und 7)
                           */
                        | SE_ERRFILE : errPtr   : tPtrString;
                          /* Zeiger auf den Namen des Errorfiles */
                                       fnamePtr : tPtrString;
                          /* Zeiger auf den Namen der compilierten Datei */
                        | SE_PROJECT,
                          ES_COMPILE,
                          ES_MAKE,
                          ES_MAKEALL,
                          ES_LINK,
                          ES_EXEC,
                          ES_MAKEEXEC,
                          ES_PROJECT : filePtr  : tPtrString;
                          /* Zeiger auf den Filenamen des Files, welches
                           * behandelt werden soll
                           */
                        | SE_QUIT,
                          SE_TERMINATE,
                          ES_QUIT,
                          SE_DATA:     data     : ARRAY [0..4] OF INTEGER;
                          /* Definition fÅr MaximallÑnge des Records
                           */
                        END;
                      END;

        tPtrMessRec = POINTER TO tMessRec;
        /* Ein Zeiger auf diese Messageblock
         */
*/


