DEFINITION MODULE AESWindows;


(*  Megemax-Module 2 GEM-Library :  Die AES Fensterfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.2     V#0016
 *)


FROM    MOSGlobals      IMPORT MemArea;

FROM    GrafBase        IMPORT Point, Rectangle;

FROM    GEMGlobals      IMPORT PtrMaxStr, PtrObjTree;



                (*  Window Manager  *)
                (*  ==============  *)


CONST   NoWindow        = 65535;    (*  Dies ist der Wert fÅr ein nicht be-
                                     *  setztes Window-Handle
                                     *)

        DeskHandle      = 0;        (*  Dies ist das Fensterkennung der
                                     *  Desktop-OberflÑche
                                     *)


TYPE    WindowElement   = (nameBar,    closer,    fuller,     mover,
                           infoBar,    sizer,     upArrow,    downArrow,
                           vertSlider, leftArrow, rightArrow, horSlider);

        WElementSet     = SET OF WindowElement;


PROCEDURE CreateWindow (    elems : WElementSet;
                            max   : Rectangle;
                        VAR handle: CARDINAL   );

        (*  Es wird ein neues Fenster beim AES angemeldet.
         *
         *  'elems'     -- die Elemente, die das Fenster besitzt.
         *  'max'       -- die maximalen Ausmaûe des Fensters.
         *  'handle'    -- liefert die Fensterkennung als Ergebnis.Be-
         *                 sitzt es den Wert 'NoWindow', so konnte kein
         *                 Fenster mehr erzeugt werden. (Das GEM ist nur
         *                 fÅr eine Verwaltung von hîchstens sieben
         *                 Fenstern ausgelegt).
         *)

PROCEDURE OpenWindow (handle: CARDINAL; frame: Rectangle);

        (*  Das Fenster mit der Kennung 'handle' wird in der Grîûe 'frame'
         *  auf den Bildschirm gebracht.
         *)

PROCEDURE CloseWindow (handle: CARDINAL);

        (*  Das durch die Kennung 'handle' bezeichnete Fenster wird vom
         *  Bildschirm entfernt. Es wird dabei nicht aus dem Speicher
         *  gelîscht.
         *)

PROCEDURE DeleteWindow (handle: CARDINAL);

        (*  Das Fenster, das die Kennung 'handle' besitzt wird abgemeldet.
         *  Das bedeutet, daû dieses Fenster nicht mehr angesprochen werden
         *  darf, es ist gelîscht.
         *)


TYPE    WSizeMode       = (workSize, borderSize, previousSize, fullSize);

PROCEDURE WindowSize (handle: CARDINAL; typ: WSizeMode): Rectangle;

        (*  Diese Funktion liefert die Ausmaûe eines Fensters. Es kînnen
         *  folgende Ausmaûe erfragt werden:
         *
         *  'workSize'     -- Die Grîûe des Arbeitsbereichs (ohne Fenster-
         *                    elemente)
         *  'borderSize'   -- Die Grîûe des gesamten Fensters (mit Fenster-
         *                    elementen)
         *  'previousSize' -- Die letzte Grîûe des Gesamtfensters
         *  'fullSize'     -- Die maximale Grîûe des Fensters
         *
         *  Insbesondere kînnen, mit Hilfe der Kennung 'DeskHandle', die
         *  Ausmaûe des Desktop's erfragt werden.
         *)


TYPE    WSliderMode     = (horPosition, vertPosition, horSize, vertSize);

PROCEDURE WindowSliderValue (handle: CARDINAL; typ: WSliderMode): INTEGER;

        (*  Es wird die Position eines Fensterschiebers geliefert.
         *  'handle' enthÑlt die Fensterkennung und 'typ' kann fol-
         *  gende Werte annehmen:
         *
         *  'horPosition'  -- Position des horizontalen Schiebers
         *  'vertPosition' -- Position des vertikalen Schiebers
         *  'horSize'      -- Ausmaûe des horizontalen Schiebers
         *  'vertSize'     -- Ausmaûe des vertikalen Schiebers
         *
         *  Schieberposition und Schiebergrîûe werden in Promille ange-
         *  geben (Wertebereich: 0 - 1000), bei der Schiebergrîûe ist
         *  allerdings auch der Wert -1 zugelassen, der die kleinste
         *  mîgliche Grîûe reprÑsentiert.
         *)

PROCEDURE TopWindow (): CARDINAL;

        (*  Liefert die Fensterkennung des oben aufliegenden Fensters.
         *)


TYPE    RListMode       = (firstElem, nextElem);

PROCEDURE WindowRectList (handle: CARDINAL; typ: RListMode): Rectangle;

        (*  Zum Zeichnen innerhalb teilweiser verdeckter Fensterbereiche
         *  ist es unerlÑûlich, die nicht verdeckten Ausschnitte zu ken-
         *  nen. Genau diese Ausschnitte sind in der so genannten Recht-
         *  eckliste, die von dieser Funktion ausgelesen wird, festgehal-
         *  ten. Das Ende der Liste ist durch ein Rechteck mit der FlÑche
         *  Null gekennzeichnet.
         *  Besitzt 'typ' den Wert 'firstElem', so wird das erste Element
         *  der Rechteckliste gelesen. Bei jedem folgenden Aufruf mit
         *  'nextElem' wird sukzessiv ein weiteres Element ermittelt.
         *)

PROCEDURE ScreenBuffer (handle: CARDINAL): MemArea;

        (*  Es wird die Beschreibung eines Speicherbereichs geliefert,
         *  der vom AES zur Zwischenspeicherung von Bildschirminhalten
         *  benutzt wird.
         *  Dieser Bereich kann ohne weiteres auch von Anwendungspro-
         *  grammen mitverwendet werden. Allerdings sollte er nur fÅr
         *  kurzfristige Aufgaben benutzt werden. Sein Umfang betrÑgt
         *  in der Regel circa 8 kByte.
         *  Beim Aufruf der Funktion muû als Kennung ('handle') 'Desk
         *  Handle' eingetragen werden.
         *)


TYPE    WStringMode     = (nameStr, infoStr);

PROCEDURE SetWindowString (handle: CARDINAL;
                           typ   : WStringMode;
                           str   : PtrMaxStr);

        (*  Einem Fenster wird eine Zeichenkette fÅr einen Namen oder
         *  eine Informationszeile zugewiesen.
         *
         *  'handle'    -- Die Kennung des Fensters
         *  'typ'       -- '= nameStr': Name
         *                 '= infoStr': Infozeile
         *  'str'       -- EnthÑlt einen Zeiger auf die Zeichenkette.
         *)

PROCEDURE SetWindowSize (handle: CARDINAL; frame: Rectangle);

        (*  Damit werden die Fensterausmaûe des Fensters 'handle' auf
         *  'frame' gesetzt.
         *  Es muû immer die Grîûe der Fensterauûenmaûe angegeben werden.
         *)

PROCEDURE SetWindowSlider (handle: CARDINAL;
                           typ   : WSliderMode;
                           value : INTEGER);

        (*  Setzt ein Fensterschieberparameter auf den Wert 'value'.
         *  Die Parameterbeschreibung entspricht der von 'WindowSliderValue'.
         *)

PROCEDURE SetTopWindow (handle: CARDINAL);

        (*  Das Fenster mit der Kennung 'handle' wird nach oben gebracht.
         *)

PROCEDURE SetNewDesk (tree: PtrObjTree; first: CARDINAL);

        (*  Diese Routine erlaubt es eine eigene Desktop-OberfÑche anzu-
         *  melden. Dadurch kann der Bildschirmhintergrund frei gestaltet
         *  werden. Die OberflÑche muû in Form eines Objektbaumes vor-
         *  liegen.
         *  'tree'      -- derObjektbaum
         *  'first'     -- gibt das erste zu Zeichnende Objekt des
         *                 Baumes an.
         *
         *  Hinweis: Durch das Anmelden wird der neue Hintergrund noch
         *           nicht dargestellt, dafÅr muû erst ein Neuzeichnen
         *           veranlaût werden (Siehe 'AESForms.FormDial').
         *)

PROCEDURE FindWindow (loc: Point): CARDINAL;

        (*  Diese Funktion ermittelt, welches Fenster sich an der Position
         *  'loc' befindet. Als Ergebnis wird die Fensterkennung geliefert.
         *)

PROCEDURE UpdateWindow (update: BOOLEAN);

        (*  Hiermit wird dem AES mitgeteilt, zu welchem Zeitpunkt eine An-
         *  wendung Ausgaben in ein Fenster tÑtigen will. WÑhrend dieser
         *  Zeit reagiert das AES nicht auf Versuche des Anwenders die Menu-
         *  zeile zu benutzen oder Fensterelemente zu bedienen.
         *  Mit 'update = TRUE' werden die Ausgaben eingeleitet und mit
         *  'FALSE' beendet.
         *  Diese Routine hat einen internen ZÑhler, so daû fÅr zwei ge-
         *  schachtelte Aufrufe mit 'TRUE' auch zwei mit 'FALSE' folgen
         *  mÅûen.
         *)

PROCEDURE MouseControl (user: BOOLEAN);

        (*  Die Reaktion des AES auf diese Routine entspricht im wesentlichen
         *  der auf 'UpdateWindow', nur ist dafÅr vorgesehen, daû die Anwen-
         *  dung die Kontrolle Åber alle Mausfunktionen selbst Åbernimmt.
         *)


TYPE    WCalcMode       = (calcBorder, calcWork);

PROCEDURE CalcWindow (typ  : WCalcMode;
                      elems: WElementSet;
                      in   : Rectangle  ): Rectangle;

        (*  Diese Funktion berechnet aus Fensterauûenmaûen die Arbeitsbe-
         *  reichsmaûe und umgekehrt.
         *
         *  'elems'      -- enthÑlt die Fensterelemente
         *
         *  FÅr 'typ' gilt:
         *
         *  'calcBorder' -- 'in' enthÑlt Arbeitsbereichsgrîûe und das Er-
         *                   gebnis sind die Auûenmaûe.
         *  'calcWork'   -- 'in' enthÑlt die Auûenmaûe un das Ergebnis ist
         *                   die Arbeitsbereichsgrîûe.
         *)


PROCEDURE ResetWindows ();

        (*  Es werden alle noch offenen Fenster der Applikation geschlossen,
         *  auûerdem wird 'UpdateWindow' und 'MouseControl' zurÅckgesetzt.
         *
         *  ACHTUNG: Diese Prozedur ist erst ab TOS 1.4 funktionsfÑhig.
         *           Die TOS-Version kann mit 'GEMEnv.GEMVersion' erfragt
         *           werden.
         *)


END AESWindows.