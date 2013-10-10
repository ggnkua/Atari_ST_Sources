DEFINITION MODULE WindowBase;


(*  System              : Megamax Modula-2
 *  Autor & Copyright   : Manuel Chakravarty
 *  Vertrieb            : Application Systems Heidelberg
 *  Version             : V1.1
 *)

(*  Dies ist das grundlegende Modul fÅr die Fensterverwaltung. Alle anderen
 *  Fenstermodule bauen auf ihm auf. Der Fensterinhalt ist vîllig unbestimmt
 *  und wird vom Klientenmodul durch Prozedurvariablen (sogenannte server)
 *  festgelegt.
 *  Die aktuelle Implemetierung des Moduls setzt auf den AES-Fenstern des
 *  GEM auf. Trotzdem ist es fÅr den Benutzer dieses Moduls nicht nîtig, daû
 *  er sich mit den Details der AES-Fensterprogrammierung auskennt. Wird re-
 *  gelmÑûig die Prozedur 'EventHandler.HandleEvents' aufgerufen, so ist es
 *  nicht nîtig weitere AES-Routinen zu verwenden. Lediglich zum Darstellen
 *  der Fensterinhalte werden das VDI oder eigenen Grafikroutinen benîtigt.
 *
 *  Einige Bezeichnungen und ihre Verwendung in diesem Modul
 *  --------------------------------------------------------
 *
 *  -- "aktives Fenster": Dies ist das oberste Fenster. Seine Fensterelemente
 *     sind eingezeichnet und manipulierbar.
 *  -- "Arbeitsbereich": Dies ist der Teil eines Fensters, der den sichtbaren
 *     Teil des Fensterinhaltes enthÑlt.
 *  -- "Anwender": Der Anwender ist der Mensch, der vor dem Computer sitzt
 *     und gerade mit einem fertigen Programm arbeitet, ohne unbedingt etwas
 *     mit seiner Programmierung zu tun zu haben.
 *  -- "Anwendung": Dies ist ein fertiges Dienstprogramm, das von einem An-
 *     wender angewendet wird.
 *  -- "Benutzer": Der Benutzer eines Moduls A ist ein Programmierer, der
 *     A in einem seiner Programme benutzt (importiert).
 *  -- "Bildschirmkoordinaten": Dies ist das normale Koordinatensystem, das
 *     seinen Ursprung in der linken, oberen Bildschirmecke hat und das vom
 *     VDI verwendet wird, falls man den 'GEMEnv.InitGem' Aufruf mit der
 *     Konstanten 'GEMEnv.RC' durchfÅhrt. Es wird in der Regel von Variablen
 *     des Typs 'Point' oder 'Rectangle' verwendet.
 *  -- "Fensterinhalt": Dies ist die Information, die innerhalb des Fensters
 *     dargestellt wird. Es ist allerdings nicht nur der sichtbare Teil ge-
 *     meint, sondern auch der Teil, der erst durch bewegen der Fensterslider
 *     eingesehen werden kann.
 *  -- "Fensterkoordinaten": Dieses Koordinatensystem hat seinen Ursprung in
 *     der linken, oberen Ecke des Fensterinhaltes und verÑndert sich mit
 *     jeder Bewegung des Fensters oder dessen Slider. Dieses Koordinaten-
 *     sytem wird in der Regel von Variablen des Typs 'LongPnt' oder 'LongRect'
 *     verwendet.
 *  -- "Klient": Als Klient oder Klientenmodul eines Moduls A wird ein Modul
 *     bezeichnet, falls es A importiert.
 *  -- "Neuzeichnen": Darunter versteht man, daû ein Teilbereich eines Fen-
 *     sters neu gezeichnet wird, z.B. weil ein darÅberliegendes Fenster
 *     entfernt wurde oder der Fensterinhalt geÑndert worden ist.
 *  -- "Slider": Auch Scroll-Balken oder Fensterschieber genannt bezeichnen
 *     die Fensterelemente, die anzeigen welcher Teil des Fensterinhaltes
 *     gerade sichtbar ist und es erlauben durch Verschieben mit der Maus
 *     andere Teile sichtbar zu machen.
 *  -- "virtuelle Koordinaten": Entspricht Fensterkoordinaten.
 *
 *  Einige Bemerkungen zu den Koordinatensystemen und dem Typ 'WindowSpec'
 *  ----------------------------------------------------------------------
 *
 *  Es werden zwei Koordinatensysteme verwendet und zwar Bildschimkoordi-
 *  naten und Fensterkoordinaten. Das erste System wird zur Kommunikation
 *  mit dem VDI gebraucht, daher dient es vor allem zum Angeben von Rechteck-
 *  bereichen, die neugezeichnet oder verschoben werden sollen. Das Zweite
 *  ist fÅr Berechnungen, die den gesamten Fensterinhalt betreffen gedacht
 *  und hat daher auch den grîûeren Wertebereich. Zur Umrechnung zwischen
 *  beiden System wird die Fensterbeschreibung 'spec' vom Typ 'WindowSpec'
 *  gebraucht und es gilt:
 *
 *          (x, y) = (spec.virtual.x + xw, spec.virtual.y + yw),
 *
 *  wobei (x, y) ein Punkt in Bildschirmkoordinaten und (xw, yw) derselbe
 *  Punkt in Fensterkoordinaten ist.
 *  Die beiden Felder von 'WindowSpec' haben folgenden Inhalt:
 *    'virtual' -- Lage und Grîûe des Fensterinhaltes in Bezug zum Bildschirm-
 *                 koorinatensystem
 *    'visible' -- Lage und Grîûe des sichtbaren Fensterinhalts (Arbeitsbe-
 *                 reichs) in Bezug zu 'virtual'
 *
 *  Daraus ergeben sich folgende Tatsachen fÅr den Zustand des Fensters:
 *    i)   Der Arbeitsbereich ist 'LRect (virtual.x + visible.x,
 *                                        virtual.y + visible.y,
 *                                        visible.w, visible.h)'
 *    ii)  Die horizontale Sliderposition ist 'visible.x' und die vertikale
 *         'visible.y', auûerdem ist die Grîûe der Slider 'visible.w' bzw.
 *         'visible.h'
 *    iii) Die Breite bzw. Hîhe des Fensterinhaltes ist 'virtual.w' bzw.
 *         'virtual.h'
 *    iv)  Soll das Fenster verschoben werden, so muû 'virtual.x/y' um diesen
 *         Betrag verschoben werden
 *    v)   Soll das Fenster in der Grîûe verÑndert werden, so muû 'visible.w/h'
 *         auf diese Breite bzw. Hîhe gesetzt werden
 *    vi)  Soll die Sliderposition verÑndert werden, so muû 'visible.x/y' auf
 *         den entsprechenden Wert gesetzt werden und 'virtual.x/y' um den
 *         entgegengesetzten Betrag verschoben werden
 *    vii) Soll die Slidergrîûe geÑndert werden, so muû 'virtual.w/h' in das
 *         richtige VerhÑltnis zu 'visible.w/h' gesetzt werden.
 *)


FROM SYSTEM     IMPORT ADDRESS;

FROM GrafBase   IMPORT Point, Rectangle, LongPnt, LongRect;
 

TYPE    Window;


        (*  Mîgliche Fensterelemente. Es bedeutet:
         *
         *    'closeElem'  -- Das Fenster besitzt ein Schlieûfeld, daû vom
         *                    Anwender betÑtigt werden kann.
         *    'sizeElem'   -- Das Fenster kann vom Anwender in der Grîûe
         *                    verÑndert werden.
         *    'moveElem'   -- Die Lage des Fensters kann vom Anwender ver-
         *                    Ñndert werden.
         *    'scrollElem' -- Der Anwender kann bestimmen, welchen Teil des
         *                    Fensterinhaltes er sehen mîchte.
         *    'titleElem'  -- Das Fenster besitzt einen Titel.
         *    'infoElem'   -- Das Fenster besitzt eine Informationszeile.
         *)
        WdwElement      = (closeElem, sizeElem, moveElem, scrollElem,
                           titleElem, infoElem);
        WdwElemSet      = SET OF WdwElement;
        
        
        (*  Mîgliche FensterzustÑnde. Es bedeutet:
         *
         *    'hiddenWdw' -- Das Fenster ist fÅr den Anwender nicht sichtbar.
         *    'topWdw'    -- Das Fenster ist das oberste aller sichtbaren
         *                   Fenster und kann somit vom Anwender beeinfluût
         *                   werden.
         *)
        WdwFlag         = (hiddenWdw, topWdw);
        WdwFlagSet      = SET OF WdwFlag;
        
        (*  Scroll-Modi
         *)
        WindowScrollMode= (columnLeftWdw, columnRightWdw, rowUpWdw, rowDownWdw,
                           pageLeftWdw, pageRightWdw, pageUpWdw, pageDownWdw);
        
        
        (*  Zustandsbeschreibung des Fensters
         *)
         
        WindowSpec      = RECORD
                            
                            (*  Lage des gesamten Fensterinhaltes innerhalb
                             *  des Weltkoordinatensystems.
                             *)
                            virtual     : LongRect;
                            
                            (*  Lage des sichtbaren Fensterinhaltes relativ
                             *  zum gesamten Fensterinhalt. Dabei ist es er-
                             *  laubt, daû 'visible' 'virtual' Åberschreit-
                             *  tet.
                             *)
                            visible     : LongRect;
                            
                          END;
        
        (*  Fenster-Server  *)
        
        (*  Soll den angegebenen Bildschirmausschnitt bei einem Aufruf
         *  kopieren bzw. neuzeichnen. Die Vereinigung von 'source' und
         *  'dest' ist immer gleich der Vereinigung von 'dest' und 'new'.
         *  Ist 'source.w = 0', so muû nicht kopiert werden.
         *  Der Anwendung ist es freigestellt, ob Sie den zu kopierenden
         *  Bereich wirklich kopiert oder das Zielgebiet 'dest' einfach
         *  neuzeichnet.
         *)
        UpdateWdwProc   = PROCEDURE ((* wdw   : *) Window,
                                     (* env   : *) ADDRESS,
                                     (* source: *) Rectangle,
                                     (* dest  : *) Rectangle,
                                     (* new   : *) Rectangle);
        
        (*  Soll den angegebene Fensterzustand ÅberprÅfen und gegeben-
         *  falls korrigieren. Dabei muû darauf geachtet werden, daû
         *  der Arbeitsbereich des Fensters vollstÑndig in 'border' liegt.
         *)
        CheckSpecWdwProc= PROCEDURE (    (* wdw   : *) Window,
                                         (* env   : *) ADDRESS,
                                     VAR (* spec  : *) WindowSpec,
                                         (* border: *) LongRect);

        (*  Soll die Anzahl der Pixel liefern, um die gescrollt werden soll.
         *)
        ScrollAmtWdwProc= PROCEDURE ((* wdw : *) Window,
                                     (* env : *) ADDRESS,
                                     (* mode: *) WindowScrollMode): LONGINT;
                                        
        (*  Teile der Anwendung mit, daû das angegebene Fenster zum ober-
         *  sten Fenster gemacht wurde.
         *
         *  ACHTUNG: Diese Prozedur wird in der aktuellen Implementation
         *           nie genutzt.
         *)
        ActivatedWdwProc= PROCEDURE ((* wdw: *) Window,
                                     (* env: *) ADDRESS);
                                       
        
        (*  Teile der Anwendung mit, daû der Anwender das Schlieûfeld des
         *  Fensters selektiert hat.
         *)
        CloseWdwProc    = PROCEDURE ((* wdw: *) Window,
                                     (* env: *) ADDRESS);
        
        
CONST   NoWindow        = Window (NIL); (*  Unbesetzte Fensterkennung  *)


                        (*  Fensterverwaltung  *)
                        (*  =================  *)
        
PROCEDURE CreateWindow (VAR wdw            : Window;

                            elems          : WdwElemSet;
                            updateServer   : UpdateWdwProc;
                            checkSpecServer: CheckSpecWdwProc;
                            scrollAmtServer: ScrollAmtWdwProc;
                            activatedServer: ActivatedWdwProc;
                            closeServer    : CloseWdwProc;
                            serverEnv      : ADDRESS);
                        
        (*  Erzeugt und initalisiert ein neues Fenster.
         *
         *  Dabei gibt 'elems' an welche Fensterelemente das neue Fenster
         *  besitzen soll und die '...Server'-Parameter bestimmen durch
         *  ihre Funktion (Semantik) das Verhalten und den Inhalt des Fen-
         *  sters. 'serverEnv' ist ein Zeiger auf eine vom Klientenmodul
         *  frei bestimmbare Datenstruktur. Dieser Zeiger wird jedem Server
         *  beim Aufruf Åbergeben (in 'env') und kann zum Beispiel auf ein
         *  Record zeigen, das alle Informationen Åber Inhalt und Aussehen
         *  des Fensters beinhaltet.
         *
         *  Ist 'WindowState (wdw) = invalidWdw', so konnte das Fenster aus
         *  Mangel an Speicherplatz nicht erzeugt werden.
         *)
 
PROCEDURE SysCreateWindow (VAR wdw            : Window;

                               elems          : WdwElemSet;
                               updateServer   : UpdateWdwProc;
                               checkSpecServer: CheckSpecWdwProc;
                               scrollAmtServer: ScrollAmtWdwProc;
                               activatedServer: ActivatedWdwProc;
                               closeServer    : CloseWdwProc;
                               serverEnv      : ADDRESS);

        (*  Erzeugt ein neues Fenster, das erst abgemeldet wird, sobald
         *  'WindowBase' aus dem Speicher entfernt wird.
         *)
                        
PROCEDURE DeleteWindow (VAR wdw: Window);

        (*  Meldet ein Fenster ab, dabei wird es falls nîtig zuvor geschlos-
         *  sen.
         *
         *  Nach diesem Aufruf ist 'wdw' keine gÅltige Kennung mehr.
         *  Wird ein Fenster nicht vom Klientenmodul durch Aufruf dieser
         *  Prozedur abgemeldet, so erledigt dies 'WindowBase' selbst, bei
         *  der Beendigung (Terminierung) des Klienten. Eine Ausnahme bilden
         *  mit 'SysCreateWindow' erzeugt Fenster.
         *)
 
 
PROCEDURE OpenWindow (wdw: Window);

        (*  ôffnet ein Fenster, d.h. das Fenster wird auf dem Bildschirm
         *  dargestellt.
         *)
         
PROCEDURE CloseWindow (wdw: Window);

        (*  Schlieût ein Fenster, d.h. entfernt es vom Bildschirm.
         *
         *  Dabei wird das Fenster nicht gelîscht (siehe 'DeleteWindow'),
         *  auch seine Ausmaûe, Lage und momentane Sliderstellung bleiben
         *  erhalten und werden bei einem erneuten 'OpenWindow' wiederver-
         *  wendet.
         *)

TYPE    WindowCopyMode = (noCopyWdw, copyHorWdw, copyVertWdw);
        
PROCEDURE UpdateWindow (wdw   : Window;
                        update: UpdateWdwProc;
                        env   : ADDRESS;
                        frame : LongRect;
                        mode  : WindowCopyMode;
                        amount: LONGINT);

        (*  Erzwingt das Neuzeichnen eines Teils des Fensterinhaltes.
         *
         *  Eingabeparameter:
         *  -----------------
         *
         *    'wdw'    -- Kennzeichnet das angesprochene Fenster.
         *    'update' -- Bestimmt die zu verwendende Zeichenroutine. Meist
         *                ist es die gleiche, die bei 'CreateWindow' als
         *                'updateServer' angegeben wurde.
         *    'env'    -- Zeiger auf eine vom Klientenmodul zu bestimmende
         *                Datenstruktur, der an 'update' weitergegeben wird.
         *    'frame'  -- Bestimmt den Fensterausschnitt, der neu gezeichnet
         *                werden soll. Die Angabe erfolgt in Fensterkoordi-
         *                naten.
         *    'mode'   -- Bestimmt ob und wenn ja in welche Richtung der an-
         *                gegebene Fensterausschnitt verschoben werden soll.
         *
         *                  'noCopyWdw'   -- Keine Verschiebung
         *                  'copyHorWdw'  -- Horizontale Verschiebung
         *                  'copyVertWdw' -- Vertikale Verschiebung
         *
         *    'amount' -- Bestimmt um welchen Betrag der Auschnitt verschoben
         *                werden soll. Dabei verschieben positive Werte nach
         *                rechts bzw. unten und negative nach links bzw. oben.
         *)

PROCEDURE RedrawWindow (wdw: Window);

        (*  Erzwingt das Neuzeichnen des gesamten sichtbaren Fensterinhaltes.
         *)


                        (*  Setzfunktionen  *)
                        (*  ==============  *)

PROCEDURE SetWindowSpec (wdw: Window; spec: WindowSpec);

        (*  Setzt eine neuen Fensterbeschreibung.
         *
         *  Die Fensterbeschreibung wird in die interne Verwaltungsdaten-
         *  struktur Åbernommen und falls das Fenster sichtbar ist, werden
         *  Fenstergrîûe, -position und -sliderstellung sofern sie sich ge-
         *  Ñndert haben an das AES weitergegeben.
         *
         *  Hinweis: Sollte sich die Sliderstellung geÑndert haben, so wird
         *           nicht unbedingt ein Neuzeichnen o.Ñ. ausgelîût. Soll mit
         *           dem éndern der Sliderstellung gleichzeeitig der Fenster-
         *           inhalt verschoben werden, so sollte 'SetWindowSliderPos'
         *           verwendet werden.
         *)


TYPE    SetWdwStrMode   = (titleWdwStr, infoWdwStr);

PROCEDURE SetWindowString (    wdw : Window;
                               mode: SetWdwStrMode;
                           REF str : ARRAY OF CHAR);

        (*  Setzt den Titel oder die Informationszeile eines Fensters.
         *
         *  Die angegebene Zeichenkette wird Åbernommen und falls das Fenster
         *  sichtbar ist sofort dargestellt.
         *
         *  Ist das angesprochene Fensterelement nicht vorhanden, so liefert
         *  'WindowState (wdw)' den Wert 'invalidElemWdw'.
         *)

CONST   CenterWdw = MinInt;       (*  Hor./vert. zentriert          *)
        MaxWdw    = MinInt;       (*  Maximale Fensterbreite/-hîhe  *)
        
PROCEDURE SetWindowWorkArea (wdw     : Window;
                             workArea: Rectangle);
        
        (*  Setzt den Arbeitsbereich eines Fensters in Bildschirmkoordinaten.
         *
         *  Sobald nîtig wird durch diese Routine ein Neuzeichnen von Teilen
         *  des Fensterinhaltes ausgelîût.
         *
         *  Es kînnen die Sonderwerte 'CenterWdw' und 'MaxWdw' Åbergeben wer-
         *  den. Ersterer bewirkt bei x- und y-Werten das Zentrieren des Fen-
         *  sters innerhalb des Desktops. 'MaxWdw' sorgt bei w- und h-Werten
         *  dafÅr, daû das Fenster auf maximale Breite bzw. Hîhe gesetzt
         *  wird.
         *)


CONST   OldWindowSlider = MinLInt;

PROCEDURE SetWindowSliderPos (wdw: Window; horPos, vertPos: LONGINT);

        (*  Setzt die Fensterslider, also den sichtbaren Bereich des Fenster-
         *  inhaltes.
         *
         *  Die neuen Werte werden Åbernommen und auûerdem werden nicht nur
         *  die Slider auf die neuen Werte gesetzt, sondern auch der Fenster-
         *  inhalt durch einen Aufruf von 'updateServer' auf den neusten
         *  Stand gebracht.
         *
         *  Soll der horizontale oder vertikale Slider unverÑndert bleiben,
         *  so kann der Werte 'OldWindowSlider' Åbergeben werden.
         *)

PROCEDURE PutWindowOnTop (wdw: Window);

        (*  Macht das Fenster zum obersten und somit aktiven Fenster.
         *)

PROCEDURE ResetWindowState (wdw: Window);

        (*  Setzt einen eventuellem Fehlerzustand zurÅck.
         *
         *  Wird durch eine der Routinen ein Fehler erkannt und dieser nicht
         *  zurÅckgesetzt, so wird beim nÑchsten Aufruf einer Routinen mit
         *  demselben Fenster ein Laufzeitfehler ausgelîût.
         *)


                        (*  Nachfragefunktionen  *)
                        (*  ===================  *)

PROCEDURE GetWindowSpec (wdw: Window; VAR spec: WindowSpec);

        (*  Ermittelt die aktuelle Fensterbeschreibung.
         *)

PROCEDURE WindowWorkArea (wdw: Window): Rectangle;

        (*  Liefert die aktuellen Ausmaûe des Arbeitsbereichs des bezeich-
         *  neten Fensters in Bildschirmkoordinaten.
         *)

PROCEDURE GetWindowSliderPos (wdw: Window; VAR horPos, vertPos: LONGINT);

        (*  Ermittelt die aktuelle Lage des sichtbaren Bereichs innerhalb
         *  des gesamten Fensterinhaltes.
         *
         *  Entspricht den Werten 'spec.visible.x' und 'spec.visible.y', die
         *  von der Prozedur 'GetWindowSpec' geliefert werden.
         *)

PROCEDURE WindowFlags (wdw: Window): WdwFlagSet;

        (*  Liefert den aktuellen Fensterzustand.
         *)


TYPE    WdwState        = (okWdw, cantOpenWdw, alreadyOpenWdw, alreadyCloseWdw,
                           invalidElemWdw, invalidWdw);

PROCEDURE WindowState (wdw: Window): WdwState;

        (*  Liefert den aktuellen Fehlerzustand des Fensters.
         *
         *  Die Fehlermeldung bezieht sich immer auf die letzte mit dieser
         *  Fensterkennung durchgefÅhrt Operation, mit Ausnahme des letzten
         *  Fehlers 'invalidWdw', der sich direkt auf die Åbergebene Kennung
         *  bezieht.
         *
         *  HINWEIS: Wurde ein Fehler erkannt und soll dieser nicht zu einem
         *           Laufzeitfehler fÅhren, so muû 'ResetWindowState' aufge-
         *           rufen werden.
         *)

PROCEDURE MinWindowWorkArea (wdw: Window): Rectangle;

        (*  Liefert die minimale Hîhe und Breite eines Fensters. Sowie die
         *  linkeste und oberste Position.
         *
         *  ACHTUNG: Darf vom 'checkStateServer' nicht aufgerufen werden!
         *)

PROCEDURE MaxWindowWorkArea (wdw: Window): Rectangle;

        (*  Liefert die maximale Hîhe und Breite, sowie die linkeste und
         *  oberste Position eines Fensters.
         *
         *  ACHTUNG: Darf vom 'checkStateServer' nicht aufgerufen werden!
         *)


TYPE    DetectWdwResult = (noWdwDWR, unkownWdwDWR, foundWdwDWR);

PROCEDURE DetectWindow (REF targets: ARRAY OF Window;
                            noTrgs : CARDINAL;
                            loc    : Point;
                        VAR wdw    : Window;
                        VAR result : DetectWdwResult);

        (*  Ermittelt das an einer bestimmten Bildschirmposition befindliche
         *  Fenster.
         *
         *  Eingabeparameter:
         *  -----------------
         *
         *    'targets' -- Liste aller Fenster nach denen gesucht werden soll.
         *    'noTrgs'  -- Gibt an wieviele EintrÑge in 'targets' relevant
         *                 sind, wird der Werte '0' Åbergeben, so werden alle
         *                 EintrÑge benutzt.
         *    'loc'     -- Die zu untersuchende Bildschirmposition.
         *
         *  Ausgabeparameter:
         *  -----------------
         *
         *    'wdw'     -- Falls an der Position 'loc' ein in 'targets' ange-
         *                 gebenes Fenster liegt, so wird dessen Kennung ge-
         *                 liefert, sonst wird 'NoWindow' geliefert.
         *    'result'  -- Falls an der angegebenen Stelle kein Fenster liegt,
         *                 so wird 'noWdwDWR' geliefert. Ist das unter 'loc'
         *                 liegende Fenster in 'targets' eingetragen, so wird
         *                 'foundWdwDWR', sonst 'unkownWdwDWR' geliefert.
         *
         *  HINWEIS: In 'targets' sind auch EintrÑge mit dem Wert 'NoWindow'
         *           erlaubt.
         *)

PROCEDURE FullArea (): Rectangle;

        (*  Liefert die Ausmaûe der DesktopoberflÑche, die mit Fenster be-
         *  legt werden kann.
         *)
         
         
                (*  Rechenfunktionen  *)
                (*  ================  *)

PROCEDURE CalcWindowCoor (    wdw      : Window;
                              screenLoc: Point;
                          VAR wdwLoc   : LongPnt;
                          VAR legal    : BOOLEAN);

        (*  Wandelt eine Punkt von Bildschirm- in -Fensterkoordinaten um.
         *
         *  Eingabeparameter:
         *  -----------------
         *
         *    'wdw'       -- Kennung des Fensters, dessen Koordinatensystem
         *                   gemeint ist.
         *    'screenLoc' -- Der Punkt in Bildschirmkoordinaten.
         *
         *  Ausgabeparameter:
         *  -----------------
         *
         *    'wdwLoc'    -- Der Punkt in Fensterkoordinaten.
         *    'legal'     -- Liefert 'TRUE', falls der Punkt innerhalb des
         *                   Fensterinhaltes ('spec.virtual') liegt. Die
         *                   Umwandlung ist aber auf jeden Fall korrekt.
         *)

PROCEDURE CalcScreenCoor (    wdw      : Window;
                              wdwLoc   : LongPnt;
                          VAR screenLoc: Point;
                          VAR success  : BOOLEAN);
        
        (*  Wandelt einen Punkt von Fenster- in Bildschirmkoordinaten um.
         *
         *  Eingabeparameter:
         *  -----------------
         *
         *    'wdw'       -- Kennung des Fensters, dessen Koordinatensystem
         *                   gemeint ist.
         *    'wdwLoc'    -- Der Punkt in Fensterkoordinaten.
         *
         *  Ausgabeparameter:
         *  -----------------
         *
         *    'screenLoc' -- Der Punkt in Bildschirmkoordinaten.
         *    'success'   -- Liefert 'TRUE', falls der Punkt im Wertebereich
         *                   des Typs 'Point' liegt. Ist dies nicht der Fall,
         *                   so wird der am nÑchsten liegende Punkt innerhalb
         *                   des Wertebereichs geliefert.
         *)

PROCEDURE BorderToWorkArea (wdw: Window; borderArea: Rectangle): Rectangle;

        (*  Berechnet zu gegebenen Randausmaûen den Arbeitsbereich eines
         *  Fensters.
         *)


END WindowBase.