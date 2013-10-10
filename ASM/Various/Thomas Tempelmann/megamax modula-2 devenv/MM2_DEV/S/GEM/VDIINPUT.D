DEFINITION MODULE VDIInputs;


(*  Megamax-Modula 2 GEM-Library :  Die VDI Eingabefunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  04.11.87
 *
 *  Version 2.2         V#0006
 *)

FROM    SYSTEM     IMPORT WORD, LONGWORD;
FROM    MOSGlobals IMPORT MemArea;
FROM    GrafBase   IMPORT Point, Rectangle, PtrMouseFormDef;
FROM    GEMGlobals IMPORT GemChar, MButtonSet, SpecialKeySet;
FROM    GEMEnv     IMPORT DeviceHandle;


PROCEDURE RequestLoc (    handle : DeviceHandle;
                          start  : Point;
                      VAR termBut: CHAR;
                      VAR loc    : Point);

        (*  Der Mauszeiger wird auf eine bestimmte Position gesetzt,
         *  danach wird gewartet, bis eine Taste oder ein Mausknopf
         *  gedrÅckt wird.
         *
         *  'start'     -- An diese Stelle wird der Mauszeiger gesetzt.
         *  'termbut'   -- Code der Taste, die zum Abbruch fÅhrte.
         *                 ( = 32/33: linke bzw. rechte Maustaste)
         *
         *  ACHTUNG: Die Routine funktioniert nur bei physikalisch
         *           geîffneten Arbeitsstationen (Devices), jedoch
         *           nicht bei virtuellen (wie dem Bildschirm)!
         *)

PROCEDURE TestLoc (    handle              : DeviceHandle;
                       start               : Point;
                   VAR termbut             : CHAR;
                   VAR keyPress, koorChange: BOOLEAN;
                   VAR loc                 : Point);

        (*  Entspricht 'RequestLoc' nur wird nicht gewartet, bis eine Taste
         *  gedrÅckt ist, sondern gleich zurÅckgekehrt.
         *  Ist 'keyPress = TRUE', so wurde eine Taste betÑtigt.
         *  Ist 'koorChange = TRUE', so wurde der Mauszeiger bewegt.
         *
         *  ACHTUNG: Die Routine funktioniert nur bei physikalisch
         *           geîffneten Arbeitsstationen (Devices), jedoch
         *           nicht bei virtuellen (wie dem Bildschirm)!
         *)


(*      Die folgenden acht Routinen arbeiten in der aktuellen TOS-Version
 *      nicht. Evtl. mit GDOS.
 *)

PROCEDURE RequestValue (    handle : DeviceHandle;
                            start  : CARDINAL;
                        VAR termBut: CHAR;
                        VAR value  : CARDINAL);

        (*  Der Startwert 'start' kann vom Anwender solange mit den
         *  Cursortasten verÑndert werden, bis er eine andere Taste
         *  drÅckt.
         *  'value' liefert den neuen Wert und 'termBut' die Taste,
         *  mit der abgebrochen wurde.
         *  Wert liegt zwischen 1 und 100
         *)

TYPE    TValState       = (nothingHappened, valueChanged, keyPressed);

PROCEDURE TestValue (    handle : DeviceHandle;
                         start  : CARDINAL;
                     VAR termbut: CHAR;
                     VAR status : TValState;
                     VAR value  : CARDINAL);

        (*  Entspricht 'RequestValue', nur wird sofort zurÅckgekehrt und
         *  'status' enthÑlt
         *
         *    'nothingHappened', falls keine Benutzeraktion erfolgte,
         *    'valueChanged'   , falls der Wert geÑndert wurde,
         *    'keyPressed'     , falls eine Taste gedrÅckt wurde.
         *)

PROCEDURE RequestChoice (    handle: DeviceHandle;
                             start : CARDINAL;
                         VAR choice: CARDINAL);

        (*  Es wird gewartet bis eine Taste gedrÅckt wird.
         *  War es eine Funktionstaste, so wird deren Nummer in 'choice'
         *  geliefert, sonst der in 'start' Åbergebenen Wert (1 - 10).
         *)

PROCEDURE TestChoice (    handle  : DeviceHandle;
                      VAR keyPress: BOOLEAN;
                      VAR choice  : CARDINAL);

        (*  Wie 'TestChoice', nur wird nicht gewartet. Und es ist 'keyPress
         *  = TRUE', falls eine Funktionstaste betÑtigt wurde.
         *)

PROCEDURE RequestString (    handle : DeviceHandle;
                         VAR str    : ARRAY OF CHAR;
                             echo   : BOOLEAN;
                             echoLoc: Point);

        (*  Wartet bis ein String vollstÑndig, durch <Return> abgeschlossen,
         *  eingegeben wurde. Falls 'echo = TRUE' ist, wird die Eingabe ab
         *  der Position 'echoLoc' auf dem Bildschirm ausgegeben.
         *
         *  ACHTUNG: Diese Routine ist in der aktuellen Version nicht impl.
         *)

PROCEDURE TestString (    handle : DeviceHandle;
                      VAR str    : ARRAY OF CHAR;
                          echo   : BOOLEAN;
                          echoLoc: Point;
                      VAR success: BOOLEAN);

        (*  Entspricht 'RequestString' nur wird nicht auf ein <Return> ge-
         *  wartet. Ist 'success = TRUE', so wurde mindestens ein Zeichen
         *  gelesen.
         *
         *  ACHTUNG: Diese Routine ist in der aktuellen Version nicht impl.
         *)

PROCEDURE RStringCode (    handle : DeviceHandle;
                       VAR str    : ARRAY OF GemChar;
                           echo   : BOOLEAN;
                           echoLoc: Point);

        (*  Wie 'RequestString', nur wird sowohl ASCII als auch IBM-Scancode
         *  geliefert.
         *
         *  ACHTUNG: Diese Routine ist in der aktuellen Version nicht impl.
         *)

PROCEDURE TStringCode (    handle : DeviceHandle;
                       VAR str    : ARRAY OF GemChar;
                           echo   : BOOLEAN;
                           echoLoc: Point;
                       VAR success: BOOLEAN);

        (*  Wie 'TestString', nur wird sowohl ASCII als auch IBM-Scancode
         *  geliefert.
         *
         *  ACHTUNG: Diese Routine ist in der aktuellen Version nicht impl.
         *)


PROCEDURE SetMouseForm (handle : DeviceHandle;
                        newForm: PtrMouseFormDef);

        (*  Die durch 'newForm' spezifierte Mausform wird durch diese
         *  Routine gesetzt.
         *)

PROCEDURE ShowCursor (handle: DeviceHandle; force: BOOLEAN);

        (*  Der Grafikcursor (Mauszeiger) wird sichtbar gemacht.
         *  Da das VDI mitzÑhlt, wie oft der Zeiger versteckt wurde, muû
         *  er auch entsprechend oft sichtbar gemacht werden. Dies kann
         *  umgangen werden, indem man fÅr 'force' den Wert 'TRUE' an-
         *  gibt. Daraufhin wird der Cursor auf alle FÑlle angezeigt.
         *
         *  ACHTUNG: Diese Funktion darf nur bei physikalisch geîffneten
         *           Arbeitstationen (Devices) verwendet werden. Beim
         *           Bildschirm (eine virtuelle Arbeitsstation) mÅssen
         *           Sie stattdessen die Funktion "GrafMouse" aus
         *           AESGraphics verwenden!
         *)

PROCEDURE HideCursor (handle: DeviceHandle);

        (*  Der Grafikcursor wird versteckt (unsichtbar).
         *  Siehe auch 'ShowCursor'.
         *
         *  ACHTUNG: Diese Funktion darf nur bei physikalisch geîffneten
         *           Arbeitstationen (Devices) verwendet werden. Beim
         *           Bildschirm (eine virtuelle Arbeitsstation) mÅssen
         *           Sie stattdessen die Funktion "GrafMouse" aus
         *           AESGraphics verwenden!
         *)

PROCEDURE GetMouseState (    handle  : DeviceHandle;
                         VAR position: Point;
                         VAR buts    : MButtonSet);

        (*  Es wird die aktuelle Position des Mauszeigers ('position')
         *  und der Status (gedrÅckt oder nicht) der Mausknîpfe ('buts')
         *  erfragt.
         *)

PROCEDURE KeyboardState (handle: DeviceHandle): SpecialKeySet;

        (*  Es wird ermittelt welche Sondertasten (Alternate, Control,
         *  linke und rechte Shifttaste) gedrÅckt sind.
         *)
         
         
(*      Mit Hilfe der folgenden Routinen kînnen sogenannte 'Softvektoren',
 *      dies sind datentechnisch Prozedurvariablen, 'umgebogen' werden.
 *      Im Klartext bedeutet dies, daû fÅr den ursprÅnglichen Wert der Pro-
 *      zedurvariable ein neuer eingesetzt wird. Diese neue Prozedur hat
 *      zwei Mîglichkeiten, zum einen kann sie die alte Prozedur voll-
 *      stÑndig ersetzen. Andererseits kann sie die zu verarbeitenden Daten
 *      lediglich modifizieren, kontrollieren oder protokolieren und da-
 *      nach die ursprÅngliche Routine aufrufen.
 *      Dies Prinzip ist nun folgendermaûen implementiert worden. Zu jedem
 *      der Vektoren (Prozedurvariablen) wird eine Liste verwaltet. In diese
 *      Liste kînnen Prozeduren mit einer bestimmten Schnittstelle (Para-
 *      meterliste) eingetragen und natÅrlich auch wieder gelîscht werden.
 *      Wird nun eine dieser Prozedurvariablen benutzt, so wird zuerst die
 *      zuletzt installierte Routine ausgefÅhrt und falls diese es wÅnscht
 *      eine weitere. Dies setzt sich durch die gesamte Liste fort. Wird
 *      nun das Listenende erreicht, so wird die, vor dem Aktivieren dieses
 *      Moduls aktuelle Prozedur ausgefÅhrt.
 *      Jede installierte Routine liefert als Ergebnis einen BOOLEAN-Wert.
 *      Ist dieser gleich 'TRUE', so heiût dies, daû mit der AusfÅhrung
 *      der in der Liste enthaltenen Prozeduren fortgefahren werden soll.
 *      Sonst wird die Kette unterbrochen.
 *
 *      Zum Installieren einer Prozedur muû ein 'Carrier' (TrÑger) Åbergeben
 *      werden, dieser dient erstens als Kennung (handle) und zweitens wird
 *      er zur zum Aufbau der Listenstruktur benîtigt. Daher ist es von ele-
 *      mentarer Wichtigkeit, daû der Carrier global definiert wird und bis
 *      zum Entfernen der Routine aus der Liste weder anderweitig verwendet,
 *      noch irgendwie freigegeben wird. Weiter muû ein Arbeitsbereich (work-
 *      space) fÅr die Prozedur angegeben werden, dieser wird wÑhrend der Ab-
 *      arbeitung der Routine als Stackbereich verwendet, es muû also unbe-
 *      dingt sichergestellt werden, daû dieser Speicherbereich erstens zur
 *      VerfÅgung steht, zweitens nicht schon benutzt wird und eine aus-
 *      reichende Grîûe besitzt. In der Regel reichen wohl 2 kByte aus.
 *
 *      Achtung: Die Aufrufe der Vektoren geschehen von Interruptroutinen aus.
 *               Da groûe Teile des Betriebssystem nicht oder nur bedingt re-
 *               entrantfÑhig sind, das heiût es darf wÑhrend eines Betriebs-
 *               systemaufrufes noch ein weiterer ausgefÅhrt werden, ist es
 *               zu empfehlen, solche Aufrufe (dazu gehîhrt z.B. auch 'Write')
 *               nicht in einer Vektorroutine zu tÑtigen. Es kînnten vîllig
 *               unvorhersehbare SystemabstÅrze herbeigefÅhrt werden!
 *)


TYPE    TimerVecCarrier          = ARRAY[0..11] OF WORD;
        TimerVecProc             = PROCEDURE (): BOOLEAN;

PROCEDURE InstallTimerProc (VAR hdl      : TimerVecCarrier;
                                newProc  : TimerVecProc;
                                wsp      : MemArea;
                            VAR deltaTime: CARDINAL);
                            
        (*  Der Timervektor stellt eine Prozedurvariable dar, die in bestim-
         *  mten ZeitabstÑnden immer wieder aufgerufen wird. Er ist also
         *  fÅr das Abarbeiten zyklisch wiederkehrender Aufgaben prÑdesti-
         *  niert.
         *  'hdl'       --  der Carrier fÅr die hiermit angemeldete Prozedur
         *  'newProc'   --  beschreibt den von ihr zu benutzenden Stack-
         *                  bereich.
         *  'wsp'       --  ebenfalls
         *  'deltaTime' --  Der Zeitabstand zwischen zwei Aufrufen (in Milli-
         *                  sekunden).
         *)

PROCEDURE RemoveTimerProc (VAR hdl: TimerVecCarrier);

        (*  Meldet die durch 'hdl' beschriebene Prozedur wieder ab, das
         *  heiût sie wird aus der Liste der aufzurufenden Prozeduren
         *  gestrichen.
         *)


TYPE    ButChgVecCarrier        = ARRAY[0..9] OF WORD;
        ButChgVecProc           = PROCEDURE (VAR (* pressed: *) MButtonSet)
                                            : BOOLEAN;
        
PROCEDURE InstallButChgProc (VAR hdl: ButChgVecCarrier;
                             newProc: ButChgVecProc;
                             wsp    : MemArea);
                             
        (*  Der Button-Change-Vektor wird immer aufgerufen, wenn der Status
         *  der Maustasten geÑndert wurde. Also eine Maustaste gedrÅckt oder
         *  losgelassen wurde. Jeder installierten Routine werden die zur
         *  Zeit gedrÅckten Maustasten (in 'pressed') Åbergeben. Dieser
         *  Wert kann geÑndert werden und es wird die geÑnderte Version dann
         *  auch vom Betriebssystem Åbernommen.
         *  'hdl' enthÑlt den Carrier, 'newProc' die neue Prozedur und 'wsp'
         *  ihren Stackbereich.
         *)

PROCEDURE RemoveButChgProc (VAR hdl: ButChgVecCarrier);

        (*  Meldet die mit 'InstallButChgProc' installierte Routine
         *  wieder ab.
         *)


TYPE    MsMoveVecCarrier        = ARRAY[0..9] OF WORD;
        MsMoveVecProc           = PROCEDURE (VAR (*loc:*) Point)
                                            : BOOLEAN;
        
PROCEDURE InstallMsMoveProc (VAR hdl    : MsMoveVecCarrier;
                                 newProc: MsMoveVecProc;
                                 wsp    : MemArea);

        (*  Der Mouse-Movement-Vektor wird bei jeder Mausbewegung ange-
         *  sprungen. Dabei wird der Routine (in 'loc') die aktuelle
         *  Mausposition Åbergegeben, diese kann von der Routine auch
         *  verÑndert werden. Durch Vertauschen der Koordinaten kann man
         *  z.B die beiden Bewegungsrichtungen der Maus vertauschen.
         *  Mit etwas mehr Aufwand kînnen die Bewegungen auch gespie-
         *  gelt werden oder es wird einfach ein Rahmen vorgegeben,
         *  der von der Maus nicht verlassen werden darf.
         *  Es ist 'hdl' der Carrier und 'wsp' der Stackbereich fÅr die
         *  zu installierende Routine 'newProc'.
         *)
                          
PROCEDURE RemoveMsMoveProc (VAR hdl: MsMoveVecCarrier);

        (*  Es wird 'hdl' abgemeldet.
         *)
         

TYPE    CurChgVecCarrier        = ARRAY[0..9] OF WORD;
        CurChgVecProc           = PROCEDURE (VAR (*loc:*) Point)
                                            : BOOLEAN;
        
PROCEDURE InstallCurChgProc (VAR hdl    : CurChgVecCarrier;
                                 newProc: CurChgVecProc;
                                 wsp    : MemArea);
                             
        (*  Der Cursor-Change-Vektor wird bei jeder PositionsÑnderung
         *  des Mauszeigers aufgerufen. Der aufgerufenen Prozedur wird
         *  (in 'loc') die neue Mauszeigerposition Åbergeben.
         *  Dabei ist 'hdl' der Carrier und 'wsp' der Stackbereich der
         *  Prozedur 'newProc'.
         *)
                          
PROCEDURE RemoveCurChgProc (VAR hdl: CurChgVecCarrier);

        (*  Es wird eine mit obiger Prozedur angemeldete Routine wieder
         *  abgemeldet.
         *)


END VDIInputs.
