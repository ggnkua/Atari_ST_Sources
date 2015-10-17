DEFINITION MODULE AESMisc;


(*  Megemax-Modula 2 GEM-Library :  Verschiedene AES Funktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.2     V#0014
 *)


FROM SYSTEM     IMPORT BYTE;

FROM GrafBase   IMPORT Point, WordBitSet;

FROM GEMGlobals IMPORT GemChar;


                (*  Application Manager  *)
                (*  ===================  *)

(*      Die folgenden drei Routinen bieten die Mîglichkeit mit anderen
 *      Anwendungen zu kommunizieren.
 *      Um die einzelnen Prozesse zu identifizieren weiût das TOS jedem
 *      eine Identifikationsnummer (ID) zu. Die Zuweisung geschieht beim
 *      Start des Programms. Dabei ist zu beachten, daû Moduln, die von
 *      dem Megamax-Modula-Loader gestartet wurden keine ID im Sinne des
 *      TOS besitzen. Vielmehr haben alle Moduln, die von ein und dem-
 *      selben Loader gestartet wurden, die gleiche TOS-ID wie der Loader.
 *      Dies zieht aber keine nenneswerten EinschrÑnkungen nach sich, da
 *      die Organisation des TOS sowieso nur eine Kommunikation zwischen
 *      Accessory's und einem einzelnen Anwendungsprogramm unterstÅtzt.
 *      Die Kommunikation zwischen Parent und Child Prozessen kann in
 *      Modula mit Hilfe entsprechender Modulakonstrukte abgewickelt wer-
 *      den, weshalb man dabei die UnterstÅtzung des TOS gar nicht benîtigt.
 *)


PROCEDURE ReadFromAppl (    id     : CARDINAL;
                        VAR buffer : ARRAY OF BYTE;
                            noBytes: CARDINAL);

        (*  Diese Routine erlaubt es den Åber die 16 Standardbyte hinaus-
         *  gehenden Rest einer Nachricht (Siehe 'AESEvents') zu lesen.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'id'        -- Die Identifikationsnummer der Anwendung aus
         *                 Nachrichtenschlange gelesen werden soll.
         *                 In der Regel ist dies wohl die eigne, die
         *                 mit 'GEMEnv.ApplicationID' erfragt werden
         *                 kann.
         *  'noBytes'   -- Anzahl der zu lesenden Bytes. Ist die gleich
         *                 Null, wird stattdessen der HIGH-Wert von
         *                 'buffer' herangezogen.
         *
         *
         *  Ausgabeparameter
         *  ----------------
         *
         *  'buffer'    -- Hier steht die ausgelesene Nachricht.
         *)
        
PROCEDURE WriteToAppl (    id     : CARDINAL;
                       REF message: ARRAY OF BYTE;
                           noBytes: CARDINAL);

        (*  Diese Prozedur schickt einer Anwendung eine Nachricht
         *  geschickt.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'id'        -- Die Identifikationsnummer der Anwendung
         *  'message'   -- enthÑlt die Nachricht
         *  'noBytes'   -- LÑnge der Nachricht. EnthÑlt es Null, wird
         *                 HIGH(message) eingesetzt.
         *
         *  Im Regelfall mÅssen die ersten 16 Byte der Nachricht das
         *  'MessageBuffer'-Format haben, da die Nachricht normalerweise
         *  als Nachrichtenereignis empfangen wird.
         *)
        
PROCEDURE FindApplication (REF fname  : ARRAY OF CHAR;
                           VAR id     : CARDINAL;
                           VAR success: BOOLEAN);

        (*  Sucht nach einer bestimmten Anwendung
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'fname'     -- Name der gesuchten Anwendung (ohne Endung!),
         *                 evtl. nîtige Leerzeichen fÅllt diese Funktion auf.
         *
         *  Ausgabeparameter
         *  ----------------
         *
         *  'success'   --'TRUE' : Anwendung wurde gefunden
         *                'FALSE': ..nicht gefunden
         *  'id'        -- Falls die Suche erfolgreich war, liefert
         *                 es die Identifikationsnummer der Anwendung.
         *
         *  Normalerweise kann damit ein Programm ein Accessory finden,
         *  indem es dessen Dateinamen angibt.
         *  Umgekehrt kînnen Accessories auch die Hauptanwendung finden,
         *  jedoch ist zu beachten, daû evtl. unter der Megamax-Shell
         *  gestartete Programme nicht dem AES bekannt sind, sondern nur
         *  das direkt vom GEM-Desktop gestartete Programm. Das kommt v.A.
         *  vor bei TOS-Versionen vor 1.4. In diesem Fall mÅûte ein
         *  Accessory nach dem Namen der Shell fragen, oder das Programm
         *  muû gelinkt und dann vom GEM-Desktop gestartet werden.
         *)


  (*    Die folgenden zwei Routinen funktionieren im aktuellen TOS nicht
   *    einwandfrei, eventuell arbeiten sie mit dem GDOS.
   *)

TYPE    RecEvent        = (timerRec, buttonRec, mouseRec, keyboardRec);

        RecordedEvent   = RECORD
                            CASE event :RecEvent OF

                              timerRec    : time  : LONGCARD|
                              buttonRec   : clicks: CARDINAL;
                                            state : WordBitSet|
                              mouseRec    : loc   : Point|
                              keyboardRec : spcl  : WordBitSet;
                                            ch    : GemChar|

                            END;
                          END;

PROCEDURE PlayEvents (REF buffer: ARRAY OF RecordedEvent;
                          no    : CARDINAL;
                          scale : CARDINAL);

        (*  Bestimmte Ereignisse werden abgespielt, d.h. heiût das
         *  GEM reagiert, als wÅrden diese Ereignisse im Moment
         *  vom Benutzer ausgelîst.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'buffer'    -- Hier werden die Ereignisse abgespeichert,
         *                 die abgespielt werden sollen.
         *  'no'        -- Gibt die Anzahl der Ereignisse an, die
         *                 abgespielt werden sollen. Ist sie gleich
         *                 Null wird das gesamte Array abgearbeitet.
         *  'scale'     -- Gibt den Geschwindigkeitsfaktor an, mit dem
         *                 die Ereignisse abgearbeitet werden sollen.
         *                 Dabei ist
         *                 50  -- Halbe Geschwindigkeit
         *                 100 -- Normale Geschwindigkeit
         *                 200 -- Doppelte Geschwindigkeit
         *)
                      
PROCEDURE RecordEvents (VAR buffer  : ARRAY OF RecordedEvent;
                            no      : CARDINAL;
                        VAR recorded: CARDINAL);

        (*  Zeichnet Ereignisse auf, die spÑter mit 'PlayEvents' re-
         *  produziert werden kînnen.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'no'        -- Anzahl der Ereignisse
         *
         *  Ausgabeparameter
         *  ----------------
         *
         *  'buffer'    -- Hier werden die Ereignisse abgespeichert.
         *  'record'    -- Anzahl der gespeicherten Ereignisse
         *)


                (*  File Selector Manager  *)
                (*  =====================  *)


PROCEDURE SelectFile (VAR path, name: ARRAY OF CHAR;
                      VAR ok        : BOOLEAN);

        (*  Damit kann die bekannte GEM File-Selector-Box erzeugt werden.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'path'      -- GEMDOS Pfadnamen oder Leerstring (dann benutzt
         *                 die Routine das Bootlaufwerk)
         *  'name'      -- Filename oder Leerstring
         *
         *  Ausgabeparameter
         *  ----------------
         *
         *  'path'      -- EnthÑlt den GEMDOS Pfadnamen (mit Wildcards)
         *  'name'      -- EnthÑlt den Filenamen
         *  'ok'        -- Liefert 'TRUE',nachdem der Anwender seine
         *                 Auswahl getroffen hat und die Box mit dem
         *                 OK-Knopf beendet wurde.
         *
         *  ACHTUNG: 'path' muû mindestens 64 Zeichen und 'name' mindestens
         *           12 Zeichen fassen kînnen, sonst wird ein Laufzeitfehler
         *           ausgelîst.
         *)

PROCEDURE SelectFileExtended (REF label     : ARRAY OF CHAR;
                              VAR path, name: ARRAY OF CHAR;
                              VAR ok        : BOOLEAN);

        (*  Damit kann die bekannte GEM File-Selector-Box erzeugt werden.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'label'     -- Eine öberschrift, die angibt fÅr welchen Zweck
         *                 eine Datei ausgewÑhlt werden soll.
         *  'path'      -- GEMDOS Pfadnamen oder Leerstring (dann benutzt
         *                 die Routine das Bootlaufwerk)
         *  'name'      -- Filename oder Leerstring
         *
         *  Ausgabeparameter
         *  ----------------
         *
         *  'path'      -- EnthÑlt den GEMDOS Pfadnamen (mit Wildcards)
         *  'name'      -- EnthÑlt den Filenamen
         *  'ok'        -- Liefert 'TRUE',nachdem der Anwender seine
         *                 Auswahl getroffen hat und die Box mit dem
         *                 OK-Knopf beendet wurde.
         *
         *  ACHTUNG: 'path' muû mindestens 64 Zeichen und 'name' mindestens
         *           12 Zeichen fassen kînnen, sonst wird ein Laufzeitfehler
         *           ausgelîst. Auûerdem darf 'label' nicht lÑnger als 30
         *           Zeichen sein.
         *           Diese Routine ist erst ab TOS 1.4 implementiert
         *           (kann mit GEMEnv.GEMVersion erfragt werden).
         *)



                (*  Scrap Manager  *)
                (*  =============  *)
                
                
(*      Der Scrap Manager (Notizenverwalter) verwaltet einen Puffer
 *      (Clipboard, Zwischenablage, Klemmbrett), in dem EIN Objekt
 *      abgelegt und wieder ausgelesen werden kann.
 *
 *      Praktisch sieht das so aus: Eine Anwendung, z.B. eine
 *      Textverarbeitung (1st Word) legt auf Befehl des Benutzers
 *      einen markierten Textblock auf der Disk ab. Dann kann der
 *      Benutzer ein anderes Programm starten oder ein Accessory
 *      aufrufen, wo dann diese Textdatei wiederum zur Weiterver-
 *      arbeitung eingelesen werden kann.
 *
 *      Damit dies funktioniert, mÅssen sich beide Anwendungen
 *      auf einen Ordner einigen, Åber den dieses Objekt (der
 *      Textblock) ausgetauscht wird. Zudem mÅssen beide das Format
 *      des Objekts richtig erkennen (eben, daû es beispielsweise
 *      ein Text ist).
 *
 *      Um das Format zu erkennen, geht man einen einfachen Weg:
 *      Es sind einige Formate festgelegt worden, die dann durch
 *      bestimmte Dateiendungen kenntlich gemacht werden.
 *      So erhalten einfache ASCII-Text-Dateien die Endung "TXT",
 *      Text-Dateien im First-Word-Format die Endung "1ST".
 *      Es gibt noch weitere Festlegungen, z.B. fÅr Grafiken.
 *
 *      Die Anwendung, die die Datei erzeugt, legt diese nun in
 *      mîglichst vielen sinnvollen verschiedenen Formaten ab.
 *      1st Word beispielsweise legt sie im 1st-Word-Format und
 *      im einfacheren ASCII-Format (ohne Formatierungs- und Text-
 *      Attribute) ab. Die Dateinamen werden immer aus dem festgelegten
 *      Ordner, 'SCRAP' und der zugehîrigen Endung zusammengesetzt,
 *      also im Beispiel "SCRAP.1ST" und "SCRAP.TXT".
 *      Die lesende Anwendung sucht dann ihrerseits ihre mîglichen,
 *      sinnvollen Formate. Ist es z.B. nur ein einfacher Texteditor,
 *      wird er ggf. nicht das 1st-Word-Format kennen, aber das
 *      einfache Textformat sollte er zumindest verstehen - er sucht
 *      also im festgelegten Ordner nach der Datei "SCRAP.TXT" und
 *      lÑdt sie.
 *
 *      FÅr die Anwendung, die die Dateien schreibt, ist zu beachten,
 *      daû sie vor dem Ablegen das evtl. vorher im Ordner liegende
 *      Objekt lîscht - also mÅssen alle Dateien, die auf "SCRAP"
 *      beginnen, gelîscht werden. Dies ist beim MM2-System sehr
 *      einfach mit der Funktion EasyGEM1.ClearScrap zu erreichen.
 *
 *      Der Ordnername nun soll eigentlich vom Start des Rechners an
 *      festgelegt sein und kann dann mit der Funktion "ReadScrapDir"
 *      (s.u.) gelesen werden.
 *      Allerdings ist der Name leider nicht automatisch zu Beginn
 *      festgelegt. Abhilfe schafft hier ein Hilfsprogramm, z.B. ein
 *      Accessory, das ggf. einen Ordner dazu anlegt und dann mittels
 *      "WriteScrapDir" diesen Ordnernamen fÅr alle weiteren Anwendungen
 *      setzt.
 *      Nun muû aber jede Anwendung damit rechnen, daû dieser Scrap-
 *      Pfad nicht gesetzt wurde. Sie darf dann ggf. selbst einen
 *      Ordner anlegen und diesen zum Scrap-Dir machen.
 *      Dies alles erledigt die Funktion 'MakeScrapName' im Modul
 *      'EasyGem1' automatisch!
 *)

PROCEDURE ReadScrapDir (VAR dir: ARRAY OF CHAR);

        (*  Ermittelt Namen des aktuellen Scrap-Pfades.
         *
         *  'dir'       -- Der Scrap-Pfadname wird hier abge-
         *                 speichert. Dieser Name ist nicht
         *                 unbedingt mit einem '\' abgeschlossen,
         *                 dieser ist dann ggf. selbst anzufÅgen
         *                 (z.B. mit 'Directory.ValidatePath')!
         *
         *  Siehe auch 'EasyGEM1.MakeScrapName'!
         *)

PROCEDURE WriteScrapDir (REF dir: ARRAY OF CHAR);

        (*  Setzt den Namen des aktuellem Scrap-Pfades.
         *
         *  'dir'       -- Wird zum neuen Scrap-Pfadnamen
         *                 Bsp: WriteScrapDir ("C:\CLIPBRD\")
         *)


                (*  Shell Manager  *)
                (*  =============  *)


PROCEDURE ShellRead (VAR cmd, tail: ARRAY OF CHAR);

        (*  Diese Routine erfragt die Kommandozeile und das Kommando,
         *  durch welches das aktuelle Programm gestartet wurde.
         *
         *  Ausgabeparameter
         *  ----------------
         *
         *  'cmd'       -- EnthÑlt das Kommando (Programmnamen)
         *  'tail'      -- EnthÑlt die Kommandozeile (das LÑngenbyte ist
         *                   bereits ausgewertet)
         *
         *  Vorsicht: Bei den TOS-Versionen Ñlter als 1.4 (also beim
         *    altem ROM-TOS und Blitter-TOS) wird der Programname
         *    nur solange korrekt zurÅckgeliefert, bis ein 'ShellFind'-
         *    oder 'LoadResource'-Aufruf getÑtigt wird (danach wird
         *    fÑlschlicherweise der Name der Resource geliefert)!
         *
         *)


TYPE    ProgramType     = (textPrgm, graphicPrgm);

PROCEDURE ShellWrite (    start    : BOOLEAN;
                          io       : ProgramType;
                      REF cmd, tail: ARRAY OF CHAR);

        (*  Damit ist es mîglich, andere Programme von einer laufenden
         *  Anwendung aus zu starten.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *  'cmd'         -- Bestimmt das Kommando fÅr den zu star-
         *                   tenden Prozeû (Programmname, am Besten mit
         *                   vollst. Pfad -> 'Directory.MakeFullPath')
         *  'tail'        -- Bestimmt die Kommandozeile (Argumentzeile)
         *
         *  'io' kann folgende Werte annehmen:
         *
         *    'textPrgm'    -- Zu startendes Programm lÑuft im Textmodus
         *    'graphicPrgm' -- Zu startendes Programm lÑuft im Grafikmodus
         *
         *  'start' kann folgende Werte annehmen:
         *
         *    'TRUE'        -- Die in 'cmd' angegebene Anwendung wird
         *                     nach Terminierung der Laufenden vom GEM-
         *                     Desktop gestartet, sofern dahin zurÅckgekehrt
         *                     wird.
         *    'FALSE'       -- TOS 1.0 & 1.2: wie 'TRUE'; ab TOS 1.4:
         *                     Es wird keine neue Anwendung gestartet.
         *                     Bei diesem Modus sollte 'io' = 'graphicPrgm'
         *                     (bzw. der Typ des endenden Programms), weil
         *                     sonst beim Verlassen das Desktop hÑngen bleiben
         *                     kann.
         *
         *  Achtung:           Erst ab TOS 1.4 ist es hiermit mîglich,
         *  ========           einen vorher erfolgten ShellWrite-Aufruf wieder
         *                     rÅckgÑngig zu machen, sodaû bei Terminierung
         *                     des laufenden Programms keine neue Anwendung
         *                     gestartet sondern zum Desktop zurÅckgekehrt
         *                     wird. Bei den alten TOS-Versionen dagegen
         *                     hat dies keinen Effekt - wenn erstmal ein
         *                     ShellWrite-Aufruf erfolgte, versucht das
         *                     GEM-Desktop immer, das beim letzten ShellWrite-
         *                     Aufruf in 'cmd' angegebene Programm zu starten,
         *                     wenn das aktuelle Programm abgelaufen ist.
         *                     Deshalb sollte dann zumindest ein Programm
         *                     bei 'start = FALSE' angegeben werden, das
         *                     praktisch nichts tut, als sich starten zu
         *                     lassen und gleich wieder zu terminieren. Ist
         *                     auch das nicht vorsehbar, sollte ein Leername
         *                     bei 'cmd' angegeben werden, damit nicht irgend-
         *                     ein anderes Programm unerwÅnscht aufgerufen
         *                     wird. Allerdings ist dann mit einer Fehler-
         *                     meldung des GEM-Desktop zu rechnen.
         *)

PROCEDURE ShellGet (VAR buffer: ARRAY OF BYTE; no: CARDINAL);

        (*  Liest Zeichen aus dem Environment-Speicher des GEM.
         *
         *  Der Puffer 'buffer' sollte mind. 4192 Bytes groû sein!
         *
         *  'no'        -- Anzahl der zu öbertragenden Zeichen
         *                 Falls 'no = 0' wird das gesammte Array
         *                 gefÅllt.
         *)

PROCEDURE ShellPut (REF buffer: ARRAY OF BYTE; no: CARDINAL);

        (*  Schreibt Zeichen in den Environment-Speicher des GEM.
         *
         *  'no'        -- Gibt an, wieviele Zeichen Åbertragen
         *                 werden sollen.Bei einem Wert von Null
         *                 wird das gesamte Array gefÅllt.
         *
         *  Die Anzahl der zu schreibenden Bytes darf bei TOS 1.0
         *  und TOS 1.2 (Blitter-TOS) 1024, bei TOS 1.4 (Rainbow-TOS)
         *  4192 Byte nicht Åberschreiten! (Ggf. die Version des
         *  GEM mittels GEMEnv.GEMVersion abfragen).
         *)

PROCEDURE ShellFind (VAR name: ARRAY OF CHAR);

        (*  Das AES sucht die Datei 'name'.
         *
         *  Bei TOS 1.0 und 1.2 wird dazu im aktuellen Inhaltsverzeichnis
         *  und dann im Wurzelverzeichnis des Boot-Laufwerks gesucht
         *  (genaugenommen in den Verzeichnissen, die im Environment-Speicher
         *  unter "PATH" eingetragen sind - dieser ist bisher aber praktisch
         *  nicht verÑnderbar).
         *  Ab TOS 1.4 wird zusÑtzlich auf dem Pfad gesucht, von dem die
         *  laufende Anwendung gestartet wurde (also dem Verzeichnis, das
         *  in 'cmd' aus 'ShellRead' ermittelbar ist).
         *
         *  'name'      -- EnthÑlt den Namen der zu suchenden Datei.
         *                 Ist sie vorhanden, wird der komplette Name
         *                 incl. Pfad zurÅckgeliefert. Wird es nicht
         *                 gefunden, so ist 'GemError() = TRUE'.
         *)

PROCEDURE ShellEnvironment (REF parm: ARRAY OF CHAR; VAR value: ARRAY OF CHAR);

        (*  In den Zeichenketten der TOS-Umgebung wird nach 'parm' gesucht.
         *  VerlÑuft die Suche erfolgreich, so enthÑlt 'value' die Zeichen,
         *  die in der Umgebungszeichenkette auf 'parm' folgen.
         *)


END AESMisc.
