DEFINITION MODULE AESEvents;


(*  Megamax Modula-2 GEM-Library:  Die AES Ereignisfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt:  05.11.87
 *
 *  Version   2.3     V#0018
 *)
 

(*      In diesem Modul sind die vom AES zur VerfÅgung gestellten Eingabe-
 *      funktionen zusammengefaût.
 *      Jedes einzelne Ereigniss kann entweder allein erfragt werden, oder
 *      es kann auf eine ganze Reihe von Ereignissen gleichzeitig gewartet
 *      werden ('MultiEvent').
 *)
 
 
FROM SYSTEM     IMPORT WORD;
 
FROM GrafBase   IMPORT Point, Rectangle;
 
FROM GEMGlobals IMPORT GemChar, MButtonSet, SpecialKeySet;


CONST   (*  Identifikationen der einzelnen Nachrichtenereignisse
         *)
        unspecMessage   = 0;
        menuSelected    = 10;
        windRedraw      = 20;
        windTopped      = 21;
        windClosed      = 22;
        windFulled      = 23;
        windArrowed     = 24;
        windHSlid       = 25;
        windVSlid       = 26;
        windSized       = 27;
        windMoved       = 28;
        windNewTop      = 29;
        accOpen         = 40;
        accClose        = 41;


TYPE  (*  Eine Variable folgenden Typs wird bei der AES-Nachricht
       *  'windArrowed' geliefert. Es bedeutet:
       *
       *  'pageUp'      -- Fensterinhalt soll um eine Seite nach oben ge-
       *                   schoben werden.
       *  'pageDown'    -- Fensterinhalt eine Seite nach unten.
       *  'rowUp'       -- Eine Zeile nach oben.
       *  'rowDown'     -- Eine Zeile nach unten.
       *  'pageLeft'    -- Eine Seite nach links.
       *  'pageRight'   -- Eine Seite nach rechts.
       *  'columnLeft'  -- Eine Spalte nach links.
       *  'columnRight' -- Eine Spalte nach rechts.
       *)
      ArrowedMode = (pageUp, pageDown, rowUp, rowDown, pageLeft,
                     pageRight, columnLeft, columnRight);

      MessageBuffer = RECORD CASE : CARDINAL OF 0:
                        CASE msgType: CARDINAL OF
                          unspecMessage : uMsgId   : CARDINAL;
                                          uMsgRmd  : CARDINAL;
                                          uMsgData : ARRAY[0..4] OF WORD|
                          menuSelected  : mSelId   : CARDINAL;
                                          mSelRmd  : CARDINAL;
                                          selTitle : CARDINAL;
                                          selItem  : CARDINAL|
                          windRedraw    : rdrwId   : CARDINAL;
                                          rdrwRmd  : CARDINAL;
                                          rdrwHdl  : CARDINAL;
                                          rdrwFrame: Rectangle|
                          windTopped    : topId    : CARDINAL;
                                          topRmd   : CARDINAL;
                                          topHdl   : CARDINAL|
                          windClosed    : clsId    : CARDINAL;
                                          clsRmd   : CARDINAL;
                                          clsHdl   : CARDINAL|
                          windFulled    : fullId   : CARDINAL;
                                          fullRmd  : CARDINAL;
                                          fullHdl  : CARDINAL|
                          windArrowed   : arrwId   : CARDINAL;
                                          arrwRmd  : CARDINAL;
                                          arrwHdl  : CARDINAL;
                                          arrwMode : ArrowedMode|
                          windHSlid     : hSldId   : CARDINAL;
                                          hSldRmd  : CARDINAL;
                                          hSldHdl  : CARDINAL;
                                          horPos   : CARDINAL|
                          windVSlid     : vSldId   : CARDINAL;
                                          vSldRmd  : CARDINAL;
                                          vSldHdl  : CARDINAL;
                                          vertPos  : CARDINAL|
                          windSized     : sizeId   : CARDINAL;
                                          sizeRmd  : CARDINAL;
                                          sizeHdl  : CARDINAL;
                                          sizeFrame: Rectangle|
                          windMoved     : moveId   : CARDINAL;
                                          moveRmd  : CARDINAL;
                                          moveHdl  : CARDINAL;
                                          moveFrame: Rectangle|
                          windNewTop    : nwTpId   : CARDINAL;
                                          nwTpRmd  : CARDINAL;
                                          nwTpHdl  : CARDINAL|
                          accOpen       : aOpnId   : CARDINAL;
                                          aOpnRmd  : CARDINAL;
                                          aOpnVoid : WORD;
                                          aOpnMId  : CARDINAL|
                          accClose      : aClsId   : CARDINAL;
                                          aClsRmd  : CARDINAL;
                                          aClsMId  : CARDINAL|
                        END| 1:
                          int: ARRAY [0..7] OF INTEGER;
                        END
                      END;


                        (*  Event-Manager-Prozeduren  *)
                        (*  ========================  *)

PROCEDURE KeyboardEvent (VAR ch: GemChar);

        (*  Wartet auf ein Tastaturereignis (Tastendruck).
         *
         *  In 'ch' wird der Scancode und falls vorhanden der zugehîrige
         *  ASCII-Code geliefert.
         *)

PROCEDURE ButtonEvent (    clicks     : CARDINAL;
                           mask, state: MButtonSet;
                       VAR mouseLoc   : Point;
                       VAR buttons    : MButtonSet;
                       VAR keyState   : SpecialKeySet;
                       VAR doneClicks : CARDINAL);

        (*  Wartet auf ein Maustastenereignis (d.h. darauf, das die Maus-
         *  tasten auf eine bestimmte Art gedrÅckt oder losgelassen werden).
         *
         *  Eingabeparameter:
         *  -----------------
         *
         *  'clicks'    -- Ist der Wert grîûer als 1, so prÅft die Routine,
         *                 ob der gewÅnschte Zustand der Maustasten, inner-
         *                 halb einer festgelegten Zeit nocheinmal eintritt.
         *                 Diese Zeit kann mit 'SetDClickSpeed' gesetzt und
         *                 mit 'DClickSpeed' erfragt werden.
         *  'mask'      -- Alle in dieser Menge enthaltenen Maustasten wer-
         *                 den von der Routine berÅcksichtigt (Ist 'mask'
         *                 die leere Menge, so kehrt die Routine, unabhÑnig
         *                 vom aktuellen Zustand der Maustasten, sofort zu-
         *                 rÅck).
         *  'state'     -- Bestimmt den Zustand (gedrÅckt oder nicht), in
         *                 dem sich die einzelnen Maustasten befinden mÅs-
         *                 sen, damit die Routine zurÅckkehrt (Nur die in
         *                 'mask bezeichneten Tasten sind interessant).
         *                 Die Tasten die gedrÅckt sein mÅssen, werden in
         *                 die Menge eingetragen.
         *
         *   Ausgabeparameter:
         *   -----------------
         *
         *  'mouseLoc'  -- Liefert die Mausposition zum Zeitpunkt des
         *                 Ereignisses.
         *  'buttons'   -- Liefert die Menge der zum Zeitpunkt des Ereignis-
         *                 ses gedrÅckten Maustasten.
         *  'keyState'  -- Liefert die Menge der zum Zeitpunkt des Ereignis-
         *                 ses gedrÅckten Sondertasten.
         *  'doneclicks'-- Liefert wie oft der gewÅnschte Zustand der Maus-
         *                 tasten wÑhrend der Abfrage erreicht wurde.
         *)
                      

TYPE    RectEnterMode   = (lookForEntry, lookForExit);
                     
PROCEDURE MouseEvent (    moveDirec: RectEnterMode;
                          frame    : Rectangle;
                      VAR buttons  : MButtonSet;
                      VAR keyState : SpecialKeySet;
                      VAR mouseLoc : Point);

        (*  Wartet auf ein Mausereignis (d.h. darauf, daû der Mauszeiger
         *  einen bestimmten Bildschirmbereich betritt oder verlÑût).
         *
         *  Eingabeparameter:
         *  -----------------
         *
         *  'moveDirec' -- Legt fest, ob der Mauszeiger den Bereich be-
         *                 tretten oder verlassen muû.
         *  'frame'     -- Legt den zu Åberwachenden Bereich fest.
         *
         *   Ausgabeparameter:
         *   -----------------
         *
         *  'buttons'   -- Liefert die Menge der zum Zeitpunkt des Ereignis-
         *                 ses gedrÅckten Maustasten.
         *  'keyState'  -- Liefert die Menge der zum Zeitpunkt des Ereignis-
         *                 ses gedrÅckten Sondertasten.
         *  'mouseLoc'  -- Liefert die Mausposition, zum Zeitpunkt des Er-
         *                 eingnisses.
         *)
                     
PROCEDURE TimerEvent (time: LONGCARD);

        (*  Wartet auf ein Zeitereignis (d.h. bis eine bestimmte Zeitspanne
         *  vergangen ist).
         *
         *  'time' -- Zeitspanne in Millisekunden.
         *)

PROCEDURE MessageEvent (VAR msg: MessageBuffer);

        (*  Wartet auf ein Nachrichtenereignis (sowohl vom AES als auch von
         *  einer anderen Applikation).
         *
         *  'msg' -- Liefert die empfangene Nachricht.
         *
         *  Hinweis: Da das GEM nur sehr eingeschrÑnkte MultitaskingfÑhig-
         *           keiten besitzt, muû eine von zwei Applikationen, die
         *           miteinander kommunizieren wollen, ein Accessory sein.
         *)


TYPE    Event           = (keyboard, mouseButton, firstRect, secondRect,
                           message, timer);
        EventSet        = SET OF Event;
        
PROCEDURE MultiEvent (    events       : EventSet;
                          noClicks     : CARDINAL;
                          butMask,
                          butState     : MButtonSet;
                          moveDirec1   : RectEnterMode; rect1Size: Rectangle;
                          moveDirec2   : RectEnterMode; rect2Size: Rectangle;
                      VAR msg          : MessageBuffer;
                          time         : LONGCARD;
                      VAR mouseLoc     : Point;
                      VAR buttons      : MButtonSet;
                      VAR keyState     : SpecialKeySet;
                      VAR key          : GemChar;
                      VAR doneClicks   : CARDINAL;
                      VAR occuredEvents: EventSet);
                     
        (*  Wartet auf eine beliebige Kombination von Ereignissen.
         *
         *  Dabei gibt 'events' an auf welche Ereignisse gewartet wird und
         *  'occuredEvents' liefert die Menge der tatsÑchlich aufgetrettenen
         *  Ereignistypen.
         *  Alle anderen Parameter entsprechen den namensgleichen Parametern
         *  der fÅnf vorangegangenen '...Event'-Prozeduren.
         *
         *  Besondere Beachtung verdient aber 'keyState': Es liefert den
         *  Wert der Sondertasten zum Zeitpunkt der Abfrage und nicht etwa
         *  den Wert, der beim Druck der Taste anstand! Wenn Sie dies nÑher
         *  interessiert, beachten Sie das Modul "KbdEvent".
         *)
                     
PROCEDURE SetDClickSpeed (speed: CARDINAL);

        (*  Legt die Zeitspanne fest, innerhalb derer zwei Klicks als Doppel-
         *  klick gewertet werden.
         *
         *  'speed' -- Zeitspanne (Wertebereich: [0..4])
         *)

PROCEDURE DClickSpeed (): CARDINAL;

        (*  Erfragt die mit 'SetDClickSpeed' gesetzte Zeitspanne.
         *)
                     
                     
END AESEvents.