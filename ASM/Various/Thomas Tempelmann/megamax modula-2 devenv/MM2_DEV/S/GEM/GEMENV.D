DEFINITION MODULE GEMEnv;


(*      Megamax Modula-2 GEM Library: Diverse Kontrollfunktionen
 *
 *      Autor: Manuel Chakravarty       Erstellt: MÑrz-Oktober 1987
 *
 *      Version 2.2     V#0062
 *)

(*      Mit den Routinen dieses Moduls kann sich eine Anwendung beim GEM
 *      An- und Abmelden, auûerdem erfolgt hier die Anmeldung weiterer
 *      VDI-GerÑte.
 *)
 
 
FROM GrafBase IMPORT Point, Rectangle;

FROM GEMGlobals IMPORT TEffectSet;


                        (*  Kontroll Funktionen  *)
                        (*  ===================  *)
                
                
TYPE    GemHandle;      (*  Dient zur Identifizierung einer kompletten
                         *  Anmeldung (per 'InitGem') beim GEM.
                         *  (GEM-Referenz)
                         *)

        DeviceHandle;   (*  Dient zur Identifizierung eines VDI-GerÑtes.
                         *  Siehe auch 'OpenDevice'. (GerÑte-Referenz)
                         *)
                         
                         
CONST   NoDevice        = DeviceHandle (NIL);   (* Wert fÅr ein nicht besetz-
                                                 * tes GerÑte-handle
                                                 *)

        NDC             = 0;             (*  Normalisierte Koordinaten  *)
        RC              = 2;             (*  Raster Koordinaten  *)


PROCEDURE InitGem (    sysKoor: CARDINAL;
                   VAR handle : DeviceHandle;
                   VAR success: BOOLEAN);

        (*  Anmeldung einer Application beim GEM und Erîffnen einer
         *  virtuellen Bildschirmarbeitsstation.
         *
         *  'sysKoor' -- Bestimmt das zu benutzenden Koordinatensystem,
         *               dabei steht 'RC' fÅr Rasterkoordinaten und NDC
         *               fÅr normalisierte Koordinaten.
         *  'handle'  -- Liefert die GerÑtereferenz der virtuellen Bild-
         *               schirmarbeitsstation. Diese Referenz muû bei
         *               jedem VDI-Aufruf als erster Parameter angege-
         *               ben werden.
         *  'success' -- Meldet ob die Anmeldung erfolgreich verlaufen
         *               ist. Ist dies nicht der Fall, so ist auch der
         *               Wert von 'handle' ungÅltig.
         *
         *  Ein Aufruf dieser Prozedur sollte am Anfang jeder Benutzung
         *  der GEM Bibliothek stehen. Wird er nicht durchgefÅhrt, so
         *  kann es zum Absturz des Systems kommen.
         *  Alternativ kann aber, wenn keine VDI-Funktionen benîtigt
         *  werden, 'InitApplication' (s.u.) aufgerufen werden.
         *
         *  Falls die Prozedur 'GemActive' den Wert 'TRUE' liefert,
         *  sind AES-Aufruf ohne jede Vorbereitung und VDI-Aufruf nach
         *  dem Erzeugen einer (virtuellen) Arbeitstation mit 'OpenDevice'
         *  ohne Benutzung von 'InitGem' mîglich. Doch sollte
         *  diese Vorgehensweise nur in AusnahmefÑllen gewÑhlt werden,
         *  da dann z.B. keine autom. Abmeldung von Fenstern u.Ñ. bei
         *  Prozessende durchgefÅhrt wird.
         *
         *  Die Variablen des Moduls 'PathEnv' werden zudem initialisiert:
         *
         *  'HomePath' wird in der Regel mit dem Pfad besetzt, von dem dies
         *  Programm stammt. Dies erlaubt dann z.B. die Verwendung von '*'
         *  (HomeSymbol) in Pfadlisten fÅr 'Paths.SearchFile'. Siehe dazu
         *  die Hinweise im PathEnv-Modul!
         *
         *  'SelectFile' erhÑlt je nach GEM-Version die Funktion 'SelectFile'
         *  bzw. 'SelectFileExtended' aus dem Modul 'AESMisc' zugewiesen.
         *
         *  ACHTUNG: Alle bisherigen GEM Versionen unterstÅtzen nur
         *           Rasterkoordinaten um normalisierte Koordinaten
         *           benutzen zu kînnen, muû das GDOS geladen werden.
         *)

PROCEDURE GemActive (): BOOLEAN;

        (*  Erfragt, ob ein anderes Modul schon einen 'InitGem'- oder
         *  'InitApplication'-Aufruf getÑtigt hat, d.h. ob ein benutz-
         *  barer 'GemHandle' vorhanden ist. (Siehe auch 'InitGem')
         *)

PROCEDURE ExitGem (VAR handle: GemHandle);

        (*  Dient zum Abmelden einer Application beim GEM.
         *
         *  Es werden autom. alle noch offenen Fenster geschlossen, alle
         *  angemeldeten GerÑte beim VDI abgemeldet und eventuell noch
         *  nicht rÅckgÑnig gemachte 'HideCursor', 'WindowUpdate' etc.
         *  Aufrufe zurÅckgesetzt.
         *  Sobald ein Modul terminiert wird fÅr jedes auf dieser Modul-
         *  ebene durchgefÅhrten 'InitGem', welches noch nicht rÅckgÑngig
         *  gemacht wurde, ein 'ExitGem' durchgefÅhrt, dies gilt insbe-
         *  sondere fÅr Laufzeitfehler.
         *)


PROCEDURE InitApplication (VAR success: BOOLEAN);  (* "appl_init" *)

        (*  Wie 'InitGem', jedoch werden weder eine virtuelle "Workstation"
         *  mit 'OpenDevice' geîffnet, noch die PathEnv-Variablen initiali-
         *  siert. Diese Funktion kann statt 'InitGem' aufgerufen werden,
         *  wenn keine VDI-Funktionen benutzt werden. Dies ist beispielsweise
         *  bei vielen Accessories der Fall. Die Abmeldung kann mit
         *  'ExitGem (gemHandle)', wobei 'gemHandle' die mit 'CurrGemHandle'
         *  erfragte Referenz enthalten muû oder mit 'ExitApplication'
         *  durchgefÅhrt werden.
         *)

PROCEDURE ExitApplication ();  (* "appl_exit" *)

        (*  Abmeldung der mit 'InitApplication' durchgefÅhrten AES-Anmeldung.
         *)


PROCEDURE GrafHandle (VAR charW, charH,
                          cellW, cellH: CARDINAL;
                      VAR hdl         : CARDINAL);

        (*  Ermittelt die VDI-Referenz, welche das AES bei seinem 'Open
         *  Workstation' Aufruf erhalten hat. ZusÑtzlich werden noch die
         *  Ausmaûe eines Zeichens des Systemzeichensatzes zurÅckgegeben.
         *
         *  'charW', 'charH',
         *  'cellW', 'cellH'  -- Ausmaûe eines Zeichens des Systemzeichen-
         *                       satzes.
         *  'hdl'             -- VDI-Referenz des AES. Hiermit kann man
         *                       mit 'OpenDevice' weitere virtuelle Bild-
         *                       schirmarbeitsstationen erîffnen.
         *
         *  ACHTUNG: Die Werte von 'charW', 'charH', 'cellW', cellH'
         *           werden vom GEM nicht korrekt geliefert. Daher
         *           ist von ihrer Verwendung abzuraten.
         *)


CONST   NonVirtual      = 0;    (*  GerÑt soll mit Open Workstation geîffnet
                                 *  werden.
                                 *)

PROCEDURE OpenDevice (dev, sysKoor, mode: CARDINAL; VAR hdl: DeviceHandle);

        (*  Dient zum ôffnen einer (virtuellen) Arbeitsstation.
         *
         *  Eingabeparameter:
         *  -----------------
         *
         *  'dev'     -- Gibt das zu îffnende GerÑt an. Entspricht der
         *               in 'ASSIGN.SYS' angegebenen GerÑtenummer.
         *  'sysKoor' -- Bestimmt das zu benutzenden Koordinatensystem,
         *               dabei steht 'RC' fÅr Rasterkoordinaten und NDC
         *               fÅr normalisierte Koordinaten.
         *  'mode'    -- Wird hier 'NonVirtual' angegeben, so wird ein
         *               eine neue Arbeitsstation erîffnet. Wird aber
         *               das VDI-Handle einer Arbeitsstation (z.B. mit
         *               'GrafHandle' ermittelt) Åbergeben, so wird zu
         *               dieser Arbeitsstation eine virtuelle Arbeits-
         *               station geîffnet.
         *
         *  Ausgabeparameter:
         *  -----------------
         *
         *  'hdl'     -- Die neue GerÑtereferenz. Sie muû bei jedem VDI-
         *               Aufruf, der an dieses GerÑt gehen soll als erster
         *               Parameter Åbergeben werden.
         *
         *  ACHTUNG: Das ôffnen weitere nicht virtueller Arbeitsstationen
         *           ist nur mit geledenem GDOS mîglich.
         *)
         
PROCEDURE CloseDevice (handle: DeviceHandle);

        (*  Die (virtuelle) Arbeitsstation wird geschlossen.
         *
         *  Bei einem Aufruf von 'ExitGem', werden alle GerÑte, die unter
         *  dem abgemeldeten 'GemHandle' geîffnet wurden autom. geschlossen.
         *)
         
        
TYPE    GDPAttribute = (lineOp, markerOp, textOp, fillOp, noAttribute,
                        notAvaible);
        GDPFkt       = (barGDP, arcGDP, pieGDP, circleGDP, ellipseGDP,
                        eArcGDP,  ePieGDP, rRectGDP, fRectGDP, jTextGDP);
        InputDev     = (keybd, other);
        DeviceType   = (outDev, inDev, inoutDev, reservedDev, metafile);
        ScreenType   = (noScreen, difCtrlDifScrn, difCtrlSamScrn,
                        samCtrlDifMem, samCtrlSamMem);
        TextRotType  = (noTextRot, step90, everyDirec);
        
        PtrDevParm   = POINTER TO DevParm;
        DevParm      = RECORD
        
                         (*  Diese 4 Werte entsprechen den von
                          *  'GrafHandle' gelieferten Werten.
                          *)
                         charWidth, charHeight,
                         cellWidth, cellHeight,
                         
                         (*  Breite und Hîhe des Pixelrasters
                          *  [0..rasterWidth] und [0..rasterHeight]
                          *)
                         rasterWidth, rasterHeight,
                         
                         (*  Breite und Hîhe eines Pixels in mm/1000
                          *)
                         pointWidth, pointHeight,
                         
                         (*  Anzahl der Schriftgrîûen (0 bed. kontinuierlich)
                          *)
                         fontSizes,
                         
                         (*  Anzahl der Linienarten und -stÑrken
                          *  (bei Letzterem bedeutet 0 kontinuierlich)
                          *)
                         lTypes, lWidths,
                         
                         (*  Anzahl der Makierungsarten und -grîûen
                          *  (bei Letzterem bedeutet 0 kontinuierlich)
                          *)
                         mTypes, mSizes,
                         
                         (*  Anzahl der verfÅgbaren ZeichensÑtze
                          *)
                         fonts,
                         
                         (*  Anzahl der FÅllmuster und Schraffuren
                          *)
                         fPatterns, fHatchings,
                         
                         (*  Anzahl der gleichzeitig darstellbaren Farben
                          *)
                         noColors,
                         
                         (*  Minimale und maximale Zeichenbreite und -hîhe
                          *)
                         minWChar, maxWChar,
                         minHChar, maxHChar,
                         
                         (*  Minimale und maximale Zeilenbreite
                          *)
                         minWRow, maxWRow,
                         
                         (*  Minimale und maximale Breite und Hîhe
                          *  von Makierungen
                          *)
                         minWMark, maxWMark,
                         minHMark, maxHMark,
                         
                         (*  Anzahl der verfÅgbaren Hintergrundfarben
                          *)
                         bgColors,
                         
                         (*  Anzahl der Farbebenen (planes)
                          *)
                         maxRasterPls,
                         
                         (*  Anzahl der 16x16 Pixel Rasteroperationen pro sec.
                          *)
                         op16PerSec,
                         
                         (*  Anzahl der Schreibmodi
                          *)
                         noWrtModes,
                         
                         (*  Hîchster Eingabemodus (0 ~ keine Eingabe,
                          *  1 ~ Nachfragemodus, 2 ~ Testmodus)
                          *)
                         maxInMode,
                         
                         (*  Maximale Anzahl von Punkten in einem
                          *  Punkte-Array und maximale Anzahl von
                          *  Zeichen in einem Zeichen-Array
                          *)
                         maxMarker, maxStrLen,
                         
                         (*  Anzahl der Mausknîpfe
                          *)
                         noMButts,
                         
                         (*  Anzahl der Zeichenmodi fÅr verbreiterte Linien
                          *)
                         thickLnModes : CARDINAL;
                         
                         (*  Gibt die verfÅgbaren grafischen
                          *  Grundfunktionen an
                          *)
                         possibleGDPs : ARRAY GDPFkt OF GDPAttribute;
                         
                         (*  Folgende Flags bestimmen ob gewisse
                          *  Operationen mit dem beschriebenen
                          *  GerÑt mîglich sind und zwar:
                          *)
                         color,         (*  Farbe                       *)
                         fill,          (*  FÅllmuster                  *)
                         cArray,        (*  Cell-Arrays                 *)
                         zooming,       (*  Skalierung von Rastern      *)
                         lookUpTab,     (*  Color Look Up Table (CLUT)  *)
                         textJust,      (*  Textausrichtung             *)
                         contFill,      (*  contour fill                *)
                         penChange,     (*  Plotterstift austauschen    *)
                         colorRibbon,   (*  Farbband (Drucker)          *)
                         thickLnTyps    (*  verbreiterte Linientypen    *)
                                      : BOOLEAN;
                         
                         (*  Folgende Variable bestimmen das EingabegerÑt
                          *  fÅr diverse Arten der Eingabe und zwar fÅr:
                          *)
                         grafCCtrl,     (*  grafische Eingaben        *)
                         valueIn,       (*  Werteingaben              *)
                         caseIn,        (*  Auswahleingaben           *)
                         alphanumIn     (*  alphanumerische Eingaben  *)
                                      : InputDev;
                         
                         (*  Typ des beschriebenen GerÑtes
                          *)
                         deviceType   : DeviceType;
                         
                         (*  Art des Bildschirms
                          *)
                         screen       : ScreenType;
                         
                         (*  UnterstÅtzte Texteffekte
                          *)
                         useTEffects  : TEffectSet;
                         
                         (*  Art der unterstÅtzten Textrotation
                          *)
                         textRot      : TextRotType;
                         
                       END;
     
PROCEDURE DeviceParameter (handle: DeviceHandle): PtrDevParm;

        (*  Liefert die GerÑteparameter eines geîffneten GerÑtes.
         *
         *  'handle' -- GerÑtereferenz des GerÑtes von dem die Parameter
         *              ermittelt werden sollen.
         *)


PROCEDURE CurrGemHandle (): GemHandle;

        (*  Ermittelt die aktuelle GEM-Referenz ('GemHandle').
         *)

PROCEDURE SetCurrGemHandle (handle: GemHandle; VAR success: BOOLEAN);

        (*  Setzt die aktuelle GEM-Refrenz.
         *
         *  'handle'  -- Neu zu setzende GEM-Referenz.
         *  'success' -- Wird hier 'FALSE' geliefert, so ist 'handle'
         *               keine gÅltige GEM-Referenz und die aktuelle
         *               Refrenz wurde nicht verÑndert.
         *)
         

                        (*  Fehlerbehandlung  *)
                        (*  ================  *)

VAR     ErrorProc: PROC;

PROCEDURE GemError (): BOOLEAN;

        (*  Ermittelt, ob beim letzten Aufruf einer GEM-Routine ein
         *  Fehler aufgetretten ist.
         *
         *  Tritt ein Fehler auf, der nicht mittels dieser Prozedur
         *  erfragt wird, so ruft die GEM-Bibliothek beim nÑchsten
         *  Aufruf einer GEM-Routine die Prozedur 'ErrorProc' auf.
         *  Ist letztere von der Applikation nicht verÑndert worden,
         *  so wird die Modula-Standardprozedur 'HALT' aufgerufen.
         *)

PROCEDURE ErrorNumber (): INTEGER;

        (*  Ermittelt im Fehlerfall den Fehler auslîsenden Wert.
         *
         *  Ist 'GemError () = TRUE', so liefert diese Funktion
         *  den INTEGER-Wert, der von der zuletzt benutzten ROM-
         *  Routine geliefert wurde, um den Fehler anzuzeigen.
         *)

VAR ErrHdlProc: PROC;

        (*  Wird bei Auftreten eines Fehlers aufgerufen.
         *  Die normalerweise hier installierte Routine tut nichts.
         *  Wenn aber Åber die 'ErrorProc' der Fehler gemeldet wird,
         *  kann hierÅber herausgefunden werden, _wo_ der Fehler
         *  auftrat.
         *)


                        (*   Nachfragefunktionen  *)
                        (*   ===================  *)
         
PROCEDURE GEMAvailable (): BOOLEAN;

        (*  Erfragt, ob das GEM schon initalisiert ist.
         *
         *  Dies ist zum Beispiel bei Auto-Ordner-Programmen nicht der
         *  Fall.
         *  Solange diese Routine kein 'TRUE' liefert ist eine Anmeldung
         *  mittels 'InitGem' sinnlos.
         *)

PROCEDURE GDOSAvailable (): BOOLEAN;

        (*  Liefert 'TRUE', sobald ein GDOS-Treiber vorhanden ist.
         *  BerÅcksichtigt auch das GEM 2.1 (liefert dort immer TRUE).
         *)

PROCEDURE GEMVersion (): CARDINAL;

        (*  Liefert die Versionsnummer, die das GEM beim Anmelden einer
         *  Applikation zurÅckgibt.
         *
         *  Das zuerst von Atari ausgelieferte TOS und das Blitter-TOS
         *  liefern den Wert $120, das TOS 1.4 den Wert $140.
         *
         *  ACHTUNG: Damit diese Routine funktionieren kann muû die
         *           Funktionsprozedur 'GemActive' den Wert 'TRUE'
         *           liefern, also schon ein 'InitGem' durchgefÅhrt
         *           sein.
         *)

PROCEDURE ApplicationID (): CARDINAL;

        (*  Liefert die GEM-Identifikationsnummer der aktuellen
         *  GEM-Refrenz.
         *)

PROCEDURE MaxPoints (): CARDINAL;

        (*  Liefert die maximale Anzahl der Punkte, die in einem Aufruf
         *  von 'PolyLine', 'PolyMarker', etc. verarbeitet werden kînnen.
         *  Ein Wert von 0 bedeutet, daû die Anzahl nicht begrenzt ist.
         *)
         
         
(*   Jede der nachfolgenden Routinen erlaubtes einen Status abzufragen,
 *   der fÅr Module die ihrerseits andere GEM benutzende Module aufrufen
 *   von Interesse sein kann. Ist z.B. 'NoUpdateWindow () # 0', so ist
 *   es nicht mîglich eine Menuzeile zu benutzen, man muû also erst die
 *   entsprechende Anzahl von 'UpdateWindow (FALSE)' durchfÅhren.
 *)
         
PROCEDURE NoHideCursor (device: DeviceHandle): CARDINAL;

        (*  Liefert die Anzahl der 'HideCursor'-Aufrufe, die noch nicht
         *  mit 'ShowCursor' rÅckgÑnig gemacht wurden.
         *)

PROCEDURE NoGrafMouseOff (): CARDINAL;

        (*  Liefert die Anzahl der 'GrafMouse (mouseOff, NIL)'-Aufrufe,
         *  die noch nicht mit 'GrafMouse (mouseOn, NIL)' rÅckgÑnig ge-
         *  macht wurden.
         *)

PROCEDURE NoUpdateWindow (): CARDINAL;

        (*  Liefert die Anzahl der 'UpdateWindow (TRUE)'-Aufrufe, die noch
         *  nicht mit 'UpdateWindow (FALSE)' rÅckgÑnig gemacht wurden.
         *)

PROCEDURE NoMouseControl (): CARDINAL;

        (*  Liefert die Anzahl der 'MouseControl (TRUE)-Aufrufe, die noch
         *  nicht mit 'MouseControl (FALSE)' rÅckgÑnig gemacht wurden.
         *)

PROCEDURE MouseInput (start: BOOLEAN);

        (*  Sorgt dafÅr, daû der Mauszeiger, unabhÑnig von seinem aktuellen
         *  Zustand, sichtbar wird. Dies ist zum Beispiel vor dem Benutzen
         *  einer Dialogbox sinnvoll.
         *
         *  TRUE  -- Der Mauszeiger wird sichtbar
         *  FALSE -- Der Mauszeiger erhÑlt seinen alten Status wieder
         *
         *  HINWEIS: Diese Routine sollte normallerweise nicht benutzt
         *           werden. Sie ist systeminternen Funktionen vorbehalten.
         *)



PROCEDURE SysInitGem (    sysKoor: CARDINAL;
                      VAR handle : DeviceHandle;
                      VAR success: BOOLEAN);

PROCEDURE SysInitApplication (VAR success: BOOLEAN);

END GEMEnv.