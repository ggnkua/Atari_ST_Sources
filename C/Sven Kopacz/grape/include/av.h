/*
 * Hinweis:
 * Dieser Text wurde automatisch aus dem beiliegenden Hypertext
 * generiert und enthÑlt die fÅr Programmierer wichtigen defines.
 * sowie zu jeder Nachricht eine Kurzbeschreibung zu deren Aufbau
 */



/*
 * AV_PROTOKOLL
 * msg[3]   = Bitfeld
 *                Bit 0:  VA_SETSTATUS
 *                Bit 1:  VA_START
 *                Bit 2:  AV_STARTED
 *                Bit 3:  VA_FONTCHANGED
 *                Bit 4:  Quoting
 *                Bit 5:  VA_PATH_UPDATE
 *            Alle anderen Bits sind fÅr Erweiterungen reserviert und
 *            sollten daher mit 0 vorbesetzt werden.
 * msg[4]   = 0 (reserviert)
 * msg[5]   = 0 (reserviert)
 * msg[6/7] = Pointer auf den Accessorynamen, wie er bei appl_find benutzt
 *            werden muû; also 8 Zeichen lang und nullterminiert. Wer auf
 *            der sicheren Seite sein will, trÑgt den Namen komplett in Groû-
 *            buchstaben ein.
 */
#define AV_PROTOKOLL 0x4700


/*
 * VA_PROTOSTATUS
 * msg[3]   = Bitfeld
 *                Bit 0   AV_SENDKEY
 *                Bit 1   AV_ASKFILEFONT
 *                Bit 2   AV_ASKCONFONT, AV_OPENCONSOLE
 *                Bit 3   AV_ASKOBJECT
 *                Bit 4   AV_OPENWIND
 *                Bit 5   AV_STARTPROG
 *                Bit 6   AV_ACCWINDOPEN, AV_ACCWINDCLOSED
 *                Bit 7   AV_STATUS, AV_GETSTATUS
 *                Bit 8   AV_COPY_DRAGGED
 *                Bit 9   AV_PATH_UPDATE, AV_WHAT_IZIT, AV_DRAG_ON_WINDOW
 *                Bit 10  AV_EXIT
 *                Bit 11  AV_XWIND
 *                Bit 12  VA_FONTCHANGED
 *                Bit 13  AV_STARTED
 *                Bit 14: Versteht und benutzt Quoting von Dateinamen
 *                Bit 15: AV_FILEINFO, VA_FILECHANGED
 * msg[4]:        Bit 0:  AV_COPYFILE, VA_FILECOPIED
 *                Bit 1:  AV_DELFILE, VA_FILEDELETED
 *                Bit 2:  AV_VIEW, VA_VIEWED
 *                Bit 3:  AV_SETWINDPOS
 *                Bit 4:  erlaubt Anlegen symbolischer Links mit AV_COPYFILE
 *                        Die Belegung dieses Bits ist zum Zeitpunkt der
 *                        Fertigstellung dieser Dokumentation noch nicht
 *                        offiziell.
 * msg[5]   = 0 (reserviert)
 * msg[6/7] = Pointer auf den Programmnamen, wie er bei appl_find benutzt
 *            werden muû; also 8 Zeichen lang und nullterminiert. Wer auf der
 *            sicheren Seite sein will, trÑgt den Namen komplett in Groûbuch-
 *            staben ein.
 */
#define VA_PROTOSTATUS 0x4701


/*
 * AV_GETSTATUS
 */
#define AV_GETSTATUS 0x4703


/*
 * AV_STATUS
 * msg[3/4] = Pointer auf einen String, der keine Steuerzeichen enthalten
 *            darf und nicht lÑnger als 256 Zeichen sein darf. Dieser
 *            Pointer darf allerdings NULL sein.
 */
#define AV_STATUS 0x4704


/*
 * VA_SETSTATUS
 * msg[3/4] = Pointer auf einen String, der keine Steuerzeichen enthÑlt.
 *            Dieser Pointer kann allerdings NULL sein, dann war
 *            kein Status gespeichert.
 */
#define VA_SETSTATUS 0x4705


/*
 * AV_SENDKEY
 * msg[3] = Tastaturstatus (ev_mmokstate, also SHIFT, CTRL, ALT...)
 * msg[4] = ASCII/Scancode der gedrÅckten Taste (ev_mkreturn)
 */
#define AV_SENDKEY 0x4710


/*
 * VA_START
 * msg[3/4] = Pointer auf eine Kommandozeile, der auch NULL sein kann.
 *            In der Kommandozeile stehen Pfade oder Dateinamen.
 */
#define VA_START 0x4711


/*
 * AV_ASKFILEFONT
 */
#define AV_ASKFILEFONT 0x4712


/*
 * VA_FILEFONT
 * msg[3] = Dateifontnummer (font id)
 * msg[4] = Dateifontgrîûe (in points)
 */
#define VA_FILEFONT 0x4713


/*
 * AV_ASKCONFONT
 */
#define AV_ASKCONFONT 0x4714


/*
 * VA_CONFONT
 * msg[3] = Consolefontnummer (font id)
 * msg[4] = Consolefontgrîûe (in points)
 */
#define VA_CONFONT 0x4715


/*
 * AV_ASKOBJECT
 */
#define AV_ASKOBJECT 0x4716


/*
 * VA_OBJECT
 * msg[3/4] = Namen aller selektierten Dateien, durch Leerzeichen von-
 *            einander getrennt. Falls keine Objekte selektiert sind, so
 *            kann dieser Pointer NULL sein.
 */
#define VA_OBJECT 0x4717


/*
 * AV_OPENCONSOLE
 */
#define AV_OPENCONSOLE  0x4718


/*
 * VA_CONSOLEOPEN
 * msg[3] = 0            -> Console wurde nicht geîffnet
 *          anderer Wert -> Console ist jetzt offen und liegt vorne
 */
#define VA_CONSOLEOPEN 0x4719


/*
 * AV_OPENWIND
 * msg[3/4] = Pfad fÅr das Fenster
 * msg[5/6] = Wildcard fÅr darzustellende Dateien.
 */
#define AV_OPENWIND 0x4720


/*
 * VA_WINDOPEN
 * msg[3] = 0            -> Fenster konnte nicht geîffnet werden
 *          anderer Wert -> Fenster ist jetzt offen und liegt vorne
 */
#define VA_WINDOPEN 0x4721


/*
 * AV_STARTPROG
 * msg[3/4] = Programmname mit kompletten Pfad; kann auch eine beliebige
 *            Datei sein, fÅr die der EmpfÑnger dann die zugehîrige
 *            Applikation startet
 * msg[5/6] = Kommandozeile (kann NULL sein)
 * msg[7]   = Beliebiges 16-Bit Wort, das in VA_PROGSTART wieder
 *            zurÅckgeliefert wird.
 */
#define AV_STARTPROG 0x4722


/*
 * VA_PROGSTART
 * msg[3] = 0            -> Programm wure nicht gestartet
 *          anderer Wert -> Programm wurde gestartet
 * msg[4] = Returncode des gestarteten Programms (so vorhanden)
 * msg[7] = 16-Bit Wort aus AV_STARTPROG
 */
#define VA_PROGSTART 0x4723


/*
 * AV_ACCWINDOPEN
 * msg[3] = AES-Handle des geîffneten Fensters
 */
#define AV_ACCWINDOPEN 0x4724


/*
 * VA_DRAGACCWIND
 * msg[3]   = AES-Handle des Fensters
 * msg[4]   = X-Position der Maus
 * msg[5]   = Y-Position der Maus
 * msg[6/7] = Pointer auf einen String, der die Namen der Objekte enthÑlt.
 */
#define VA_DRAGACCWIND 0x4725


/*
 * AV_ACCWINDCLOSED
 * msg[3] = AES-Handle des Fensters
 */
#define AV_ACCWINDCLOSED 0x4726


/*
 * AV_COPY_DRAGGED
 * msg[3]   = Tastaturstatus (Alternate, Control, Shift)
 * msg[4/5] = Pointer auf einen String, der den Namen des Zielobjektes
 *            enthÑlt. Dies @{B}muû@{0} ein Pfad sein!
 */
#define AV_COPY_DRAGGED 0x4728


/*
 * VA_COPY_COMPLETE
 * msg[3] = Wenn hier ein Wert ungleich Null steht, dann wurde
 *          wirklich etwas kopiert oder verschoben.
 */
#define VA_COPY_COMPLETE 0x4729


/*
 * AV_PATH_UPDATE
 * msg[3/4] = Pointer auf den absoluten Pfad
 */
#define AV_PATH_UPDATE 0x4730


/*
 * AV_WHAT_IZIT
 * msg[3] = X-Koordinate
 * msg[4] = Y-Koordinate
 */
#define AV_WHAT_IZIT 0x4732


/*
 * VA_THAT_IZIT
 * msg[3]   = ID der zustÑndigen Applikation
 * msg[4]   = Typ des Objektes
 *             Unbekannt: 0
 *             MÅlleimer: 1
 *             Shredder : 2
 *             Clipboard: 3
 *             Datei    : 4
 *             Ordner   : 5
 *             Laufwerk : 6
 *             Fenster  : 7
 *             (alle anderen fÅr Erweiterungen reserviert.)
 * msg[5+6] = Zeiger auf den Namen des Objektes (oder NULL, falls nicht
 *            vorhanden)
 */
#define VA_THAT_IZIT    0x4733
#define VA_OB_UNKNOWN   0
#define VA_OB_TRASHCAN  1
#define VA_OB_SHREDDER  2
#define VA_OB_CLIPBOARD 3
#define VA_OB_FILE      4
#define VA_OB_FOLDER    5
#define VA_OB_DRIVE     6
#define VA_OB_WINDOW    7


/*
 * AV_DRAG_ON_WINDOW
 * msg[3]   = X-Position, wohin die Maus gezogen wurde
 * msg[4]   = Y-Position, wohin die Maus gezogen wurde
 * msg[5]   = Tastaturstatus (Shift,Control,Alternate)
 * msg[6/7] = Pointer auf einen String, der die Namen der Objekte enthÑlt.
 */
#define AV_DRAG_ON_WINDOW 0x4734


/*
 * VA_DRAG_COMPLETE
 * msg[3] = Status der Aktion. (!= 0 heiût, daû wirklich etwas
 *          kopiert oder verschoben wurde.
 */
#define VA_DRAG_COMPLETE 0x4735


/*
 * AV_EXIT
 * msg[3] = AES-ID des Senders
 */
#define AV_EXIT 0x4736


/*
 * AV_STARTED
 * msg[3/4] = Der Pointer aus der VA_START Nachricht.
 */
#define AV_STARTED 0x4738


/*
 * VA_FONTCHANGED
 * msg[3] = Dateifontnummer   (font id)
 * msg[4] = Dateifontgrîûe    (in points)
 * msg[5] = Consolefontnummer (font id)
 * msg[6] = Consolefontgrîûe  (in points)
 */
#define VA_FONTCHANGED 0x4739


/*
 * AV_XWIND
 * msg[3/4] = Pfad fÅr das Fenster
 * msg[5/6] = Wildcard als Filter fÅr die Anzeige
 * msg[7]   = Bitmaske  0x0001 - toppe evtl. vorhandenes Fenter
 *                      0x0002 - Wildcard soll nur selektieren
 *                             - alle anderen Bits auf 0 setzen!
 */
#define AV_XWIND 0x4740


/*
 * VA_XOPEN
 * msg[3] = Gibt an, ob das Fenster geîffnet werden konnte.
 *          (Word 3 == 0 (nein) != 0 (ja))
 */
#define VA_XOPEN 0x4741


/*
 * AV_VIEW
 * msg[3/4]: Zeiger auf den Namen der anzuzeigenden Datei (es ist nur
 *           EINE einzelne Datei zulÑssig!)
 * msg[5-7]: reserviert, immer 0
 */
#define AV_VIEW 0x4751


/*
 * VA_VIEWED
 *  msg[3]  : 0=Fehler, 1=Alles ok
 *  msg[4-7]: reserviert, immer 0
 */
#define VA_VIEWED 0x4752


/*
 * AV_FILEINFO
 * msg[3/4]: Zeiger auf Datei oder Ordnernamen. Mehrere Dateien/Ordner
 *           werden durch Leerzeichen getrennt. Ordner MöSSEN mit ab-
 *           schliessendem '\' Åbergeben werden!
 * msg[5-7]: reserviert, immer 0
 */
#define AV_FILEINFO 0x4753


/*
 * VA_FILECHANGED
 * msg[3/4]: Zeiger auf die Namen der Dateien/Ordner, die bei
 *           AV_FILEINFO Åbergeben wurden, wobei natÅrlich einige
 *           Dateien/Ordner neue Namen haben kînnen
 *           Beispiel: Es wurde 'C:\ANNA.TXT C:\AUTO\' Åbergeben.
 *                     Der Benutzer Ñndert 'ANNA.TXT' in 'ANNELIE.TXT'
 *                     um. Als Ergebnis erhÑlt man dann in dieser
 *                     Message den String 'C:\ANNELIE.TXT C:\AUTO\'
 * msg[5-7]: reserviert, immer 0
 */
#define VA_FILECHANGED 0x4754


/*
 * AV_COPYFILE
 * msg[3/4]: Zeiger auf die Quelldateie(n) und -Ordner, durch Leer-
 *           stellen getrennt, Order mit abschliessendem '\'
 * msg[5/6]: Zeiger auf den Zielordner
 * msg[7]  : Bit 0:    Originale lîschen (verschieben)
 *           Bit 1:    Kopien umbenennen
 *           Bit 2:    Ziel kommentarlos Åberschreiben
 *           Bit 3:    Nur symbolische Links der Quellen erzeugen
 *                     (Bit 0 ist dann bedeutungslos)
 *           Bit 3-15: reserviert, immer 0
 */
#define AV_COPYFILE 0x4755


/*
 * VA_FILECOPIED
 * msg[3]  : 0=Fehler, 1=Alles Ok
 * msg[4-7]: reserviert, immer 0
 */
#define VA_FILECOPIED 0x4756


/*
 * AV_DELFILE
 * msg[3/4]: Zeiger auf die zu lîschenden Dateie(n)/Ordner, durch Leer-
 *           stellen getrennt, Order mit abschliessendem '\'
 * msg[5-7]: reserviert, immer 0
 */
#define AV_DELFILE 0x4757


/*
 * VA_FILEDELETED
 *  msg[3]  : 0=Fehler, 1=Alles Ok
 *  msg[4-7]: reserviert, immer 0
 */
#define VA_FILEDELETED 0x4758


/*
 * AV_SETWINDPOS
 * msg[3]:  Position X
 * msg[4]:  Position Y
 * msg[5]:  Breite
 * msg[6]:  Hîhe
 * msg[7]:  reserviert, immer 0
 */
#define AV_SETWINDPOS 0x4759


/*
 * VA_PATH_UPDATE
 * msg[3/4]: Zeiger auf das Verzeichnis, immer mit '\' abgeschlossen
 * msg[5-7]: reserviert, immer 0
 */
#define VA_PATH_UPDATE 0x4760

