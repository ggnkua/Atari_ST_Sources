DEFINITION MODULE EventHandler;


(*  Definitionen des 'EventHandler's der Megamax Modula-2 Biblothek
 *
 *  System              : Megamax Modula-2 (MOS 2.0)
 *  Author & Copyright  : Manuel Chakravarty
 *  Vertrieb            : Application Systems Heidelberg
 *  Version             : 2.1      V#0037
 *)
 
(*  Dieses Modul erfÅllt zwei Aufgaben, ersten erleichtert es die Program-
 *  mierung von Ereignisschleifen (dies ist die Sorte von Schleife, die
 *  sich typischerweise um ein 'MultiEvent'-Aufruf rankt) und zweitens er-
 *  laubt es das öberwachen des durch 'AESEvent' laufenden Ereignisstroms.
 *
 *  Die Programmierung herkîmmlicher Ereignisschleifen kann man mit der
 *  Prozedur 'HandleEvents' vermeiden. Statt eines Aufrufes von 'MultiEvent'
 *  und den darauf folgenden IF's zum Behandlen der Ereignisse, schreibt man
 *  einfach fÅr jedes Ereignis, das man bearbeiten will ein oder mehrere Pro-
 *  zeduren in ein 'ARRAY OF EventProc' und ruft danach 'HandleEvents' auf.
 *  Treten nun ein oder mehrere Ereignisse auf, so werden automatisch alle
 *  Prozeduren, die fÅr eines dieser Ereignise angemeldet sind, mit den vom
 *  AES gelieferten Werten aufgerufen. Diese Prozeduren mÅssen nach der Be-
 *  arbeitung des Ereignisses mit einem BOOLEAN-Wert zurÅckkehren. Dabei be-
 *  deutet der Wert 'TRUE', daû das Ereignis auch noch an eventuell vorhandene
 *  andere Prozeduren des gleichen Typs weitergegeben werden soll. Bei der
 *  RÅckgabe von 'FALSE' wird das Ereignis als vollstÑndig bearbeitet ange-
 *  sehen und aus der Menge der aufgetrettenen Ereignisse gestrichen.
 *  Nachdem alle Ereignisse oder Prozeduren bearbeitet sind, kehrt 'Handle
 *  Events' zurÅck. Nun sollte man ermitteln, ob es an der Zeit ist die Er-
 *  eignisschleife zu beenden, falls nicht, wird 'HandleEvents' erneut auf-
 *  gerufen.
 *
 *  Das zweite Feature diese Moduls wird wohl seltener verwendet werden, es
 *  hat aber zum Beispiel in 'TextWindows' Anwendung gefunden.
 *  Es kînnen, mit 'InstallWatchDog', fÅr jedes Ereignis beliebig viele öber-
 *  wachungsprozeduren angemeldt und diese mit 'DeInstallWatchDog' auch wie-
 *  der abgemeldt werden. Wann immer nun ein Ereignis mit 'HandleEvents',
 *  oder AUCH mit einer der in 'AESEvent' befindlichen Event Manager Rou-
 *  tinen ermittelt wird, wird ZUERST geprÅft ob fÅr diesen Ereignistyp ein
 *  "Wachhund auf der Lauer liegt". Ist dies der Fall, so wird die entspre-
 *  chende Funktion aufgerufen. Falls diese nun 'TRUE' als Ergebnis liefert,
 *  so wird ganz normal verfahren und das Ereignis an die aufrufende Routine
 *  weitergegeben; ist der Wert aber 'FALSE', so wird das Ereignis sozusagen
 *  unterschlagen und wieder das AES angesprungen, um erneut auf ein Ereignis
 *  zu warten. Bei 'MultiEvent' wird das Ereignis nur aus der Menge aller
 *  aufgetrettenen Ereignisse ausmaskiert und der Rest, der auch leer sein
 *  kann, an die aufrufende Routine weitergegeben. Bei 'HandleEvents', wird
 *  wie bei 'MultiEvent' verfahren, nur werden die Ereignisse nicht zurÅck-
 *  gegeben, sondern die entsprechenden Prozeduren ausgefÅhrt.
 *  Bei der Benutzung von 'HandleEvents', ist folgende Besonderheit anzu-
 *  merken: In der Regel werden nur solche Ereignisse vom AES erfragt, fÅr
 *  die auch Prozeduren in dem 'ARRAY OF EventProc' angegeben sind. Falls
 *  aber einen Anmeldung fÅr ein Nachrichtenereignis mittels 'InstallWatchDog'
 *  vorliegt, so werden auch Nachrichtenereignise erfragt. (Wird eine Nach-
 *  richt Åbergeben, die von keiner der angemeldeten Routine bearbeitet wer-
 *  den kann, so ist Sorge getragen, daû das Ereignis nicht verloren geht)
 *  Als Letztes sei noch angemerkt, daû die Aufteilung der Nachrichtenerei-
 *  gnisse in die Unterpunkte nur aus GrÅnden der einfacheren Handhabung
 *  erfolgte.
 *  Dabei gilt: Meldet man eine 'MessageProc' (mit 'unspecMessage') an, so
 *  wird diese bei jeder Nachricht, also sowohl bei AES-Nachrichten, als
 *  auch bei Nachrichten von anderen Applikationen (in der Regel Accesory's).
 *  aufgerufen. Dabei ist zu beachten, daû wann immer man mit 'AESMisc.Write
 *  ToAppl' einen Nachricht absetzt, das erste Wort die Art der Nachricht,
 *  das zweite Wort die Applikationsnummer des Senders und das dritte Wort
 *  die LÑnge der Nachricht minus 16 (in Byte) enthÑlt.
 *)


FROM SYSTEM     IMPORT WORD;

FROM GrafBase   IMPORT Point, Rectangle;

FROM GEMGlobals IMPORT GemChar, MButtonSet, SpecialKeySet;
                       
FROM AESEvents  IMPORT unspecMessage, menuSelected, windRedraw, windTopped,
                       windClosed, windFulled, windArrowed, windHSlid,
                       windVSlid, windSized, windMoved, windNewTop, accOpen,
                       accClose, ArrowedMode, Event, MessageBuffer,
                       RectEnterMode;
 

TYPE    WatchDogCarrier = ARRAY[0..7] OF WORD;

        (*  ACHTUNG: Der Parameter 'ctrl' sollte bei watch dogs nicht
         *           genutzt werden, da er nur von 'MultiEvent' und
         *           nicht von 'KeyboardEvent' unterstÅtzt wird.
         *)
        KeyboardProc    = PROCEDURE (VAR (* key : *) GemChar,
                                     VAR (* ctrl: *) SpecialKeySet): BOOLEAN;

        MouseButtonProc = PROCEDURE ((* clicks: *) CARDINAL,
                                     (* loc   : *) Point,
                                     (* buts  : *) MButtonSet,
                                     (* keys  : *) SpecialKeySet): BOOLEAN;

        MouseRectProc   = PROCEDURE ((* loc : *) Point,
                                     (* buts: *) MButtonSet,
                                     (* keys: *) SpecialKeySet): BOOLEAN;

        MessageProc     = PROCEDURE ((* buffer: *) MessageBuffer): BOOLEAN;

        TimerProc       = PROCEDURE (): BOOLEAN;

        MenuProc        = PROCEDURE ((* title: *) CARDINAL,
                                     (* item : *) CARDINAL): BOOLEAN;

        WindRedrawProc  = PROCEDURE ((* handle: *) CARDINAL,
                                     (* frame : *) Rectangle): BOOLEAN;
                                      
        WindToppedProc  = PROCEDURE ((* handle: *) CARDINAL): BOOLEAN;
        
        WindClosedProc  = PROCEDURE ((* handle: *) CARDINAL): BOOLEAN;
        
        WindFulledProc  = PROCEDURE ((*handle: *) CARDINAL): BOOLEAN;
        
        WindArrowedProc = PROCEDURE ((* handle: *) CARDINAL,
                                     (* mode  : *) ArrowedMode): BOOLEAN;
                                  
        WindHSlidProc   = PROCEDURE ((* handle: *) CARDINAL,
                                     (* pos   : *) CARDINAL): BOOLEAN;
                                  
        WindVSlidProc   = PROCEDURE ((* handle: *) CARDINAL,
                                     (* pos   : *) CARDINAL): BOOLEAN;
                                  
        WindSizedProc   = PROCEDURE ((* handle: *) CARDINAL,
                                     (* frame : *) Rectangle): BOOLEAN;
                                  
        WindMovedProc   = PROCEDURE ((* handle: *) CARDINAL,
                                     (* frame : *) Rectangle): BOOLEAN;
                                  
        WindNewTopProc  = PROCEDURE ((* handle: *) CARDINAL): BOOLEAN;
        
        AccOpenProc     = PROCEDURE ((* id: *) CARDINAL): BOOLEAN;
        
        AccCloseProc    = PROCEDURE ((* id: *) CARDINAL): BOOLEAN;
        
        
        EventProc = RECORD
        
                      CASE event:Event OF
                      
                        keyboard    : keyHdler   :KeyboardProc|
                        mouseButton : butHdler   :MouseButtonProc|
                        firstRect   : stRectHdler:MouseRectProc|
                        secondRect  : ndRectHdler:MouseRectProc|
                        message     :
                                      CASE msgType:CARDINAL OF
                                     
                                        unspecMessage: msgHdler :MessageProc|
                                        menuSelected : menuHdler:MenuProc|
                                        windRedraw   : drawHdler:WindRedrawProc|
                                        windTopped   : topHdler :WindToppedProc|
                                        windClosed   : clsHdler :WindClosedProc|
                                        windFulled   : fullHdler:WindFulledProc|
                                        windArrowed  : arrwHdler:WindArrowedProc|
                                        windHSlid    : hSldHdler:WindHSlidProc|
                                        windVSlid    : vSldHdler:WindVSlidProc|
                                        windSized    : sizeHdler:WindSizedProc|
                                        windMoved    : moveHdler:WindMovedProc|
                                        windNewTop   : newTHdler:WindNewTopProc|
                                        accOpen      : accOHdler:AccOpenProc|
                                        accClose     : accCHdler:AccCloseProc|
                                        
                                      END|
                                      
                        timer       : timeHdler :TimerProc|
                        
                      END;
                      
                    END;


PROCEDURE InstallWatchDog (VAR handle: WatchDogCarrier; proc: EventProc);

        (*  Meldet einen watch dog, d.h. eine auf ein bestimmtes Ereignis
         *  wartende Prozedur an.
         *
         *  Beim Aufruf wird die in 'proc' specifizierte Prozedur fÅr
         *  das ebenfalls in 'proc' angegebene Ereignis angemeldet.
         *  'handle' dient einerseits zur Aufnahme einiger Informati-
         *  onen fÅr das 'EventHandler'-Modul, als auch zur Identifi-
         *  kation der Prozedur beim Abmelden mit 'DeInstallWatchDog'.
         *  Es ist wichtig, daû 'handle' vom Anmelden bis zum Abmelden
         *  erhalten bleibt, am besten ist die Variable also global
         *  zu definieren.
         *  Es ist ohne Schwierigkeiten mîglich ein und die selbe Pro-
         *  zudur mehrmals mit VERSCHIEDENEN 'handle's anzumelden, al-
         *  so zum Beispiel fÅr 'windMoved' und 'windSized' dieselbe
         *  Routine zu verwenden. Doch darf dasselbe 'handle' NIE
         *  gleichzeitig fÅr mehrere Anmeldungen herhalten!
         *  Die angemeldetet Routine muû bei ihrem Aufruf, falls sie
         *  Routinen aus einem GEM-Modul verwendet darauf achten, daû
         *  die richtige GEM-Kennung aktiv ist!
         *
         *  Bei der Terminierung eines Moduls werden alle dort ange-
         *  meldeten Routinen abgemeldet (Siehe 'SysInstallWatchDog')
         *)
         
PROCEDURE SysInstallWatchDog (VAR handle: WatchDogCarrier; proc: EventProc);

        (*  Funktionsweise wie 'InstallWatchDog', nur wird keine autom.
         *  Abmeldung durchgefÅhrt.
         *  Diese Routine sollte von residenten und Systemmoduln benutzt
         *  werden.
         *)
         
PROCEDURE DeInstallWatchDog (VAR handle: WatchDogCarrier);

        (*  Meldet die zu 'handle' gehîrende Routine ab.
         *
         *  Danach kann Åber 'handle' wieder frei verfÅgt werden.
         *)

PROCEDURE HandleEvents (    noClicks  : CARDINAL;
                            butMask,
                            butState  : MButtonSet;
                            moveDirec1: RectEnterMode; rect1Size: Rectangle;
                            moveDirec2: RectEnterMode; rect2Size: Rectangle;
                            time      : LONGCARD;
                        REF procs     : ARRAY OF EventProc;
                            usedProcs : CARDINAL);

        (*  Bearbeitet eventuell anstehende Ereignisse.
         *
         *  FÅhrt einen Aufruf von 'AESEvent.MultiEvent' durch, dabei werden
         *  die Parameter 'noClicks' bis 'time' verwendet. Anschlieûend wer-
         *  den fÅr jedes aufgetrettene Ereignis die entsprechenden Routinen
         *  aus 'procs' aufgerufen. Dabei wird mit dem niedrigsten Feldindex
         *  begonnen und fÅr jede Routine geprÅft ab das zugehîrige Ereignis
         *  aufgetretten ist, falls ja, wird die Routine angesprungen. Gibt
         *  die Prozedur als Ergebnis 'FALSE' zurÅck, so wird das Ereignis
         *  aus der Menge der aufgetrettenen Ereignisse gelîscht.
         *  'usedProcs' gibt an wieviele Feldelemente beachtet werden sollen.
         *  Falls 'usedProcs' gleich Null ist, so werden alle EintrÑge behan-
         *  delt.
         *  Nach Abarbeitung aller Routinen kehrt 'HandleEvents' zurÅck.
         *)
         
PROCEDURE ShareTime (time: LONGCARD);

        (*  Gibt Accessories oder watch dogs die Mîglichkeit auf Ereignisse
         *  zu reagieren.
         *
         *  Diese Prozedur fÅhrt einen Aufruf von 'HandleEvents' aus, der
         *  dazu fÅhrt, daû nach der angegebenen Zeit 'time' (in ms) zu-
         *  rÅckgekehrt wird.
         *  Sinn und Zweck dieser Routine ist, daû eventuell im Hinter-
         *  grund arbeitende Accessorys zum Zug kommen und das zweitens
         *  watch dogs (s.o.) die auf message events angesetzt sind, vom
         *  AES mit Nachrichten (z.B. Redraws) versorgt werden kînnen.
         *  Ein Beispiel fÅr die Anwendung bietet 'TextWindows':
         *  Benutzt ein Programm nur Fenster von 'TextWindows' und will es
         *  dem Anwender die Gelegenheit zur Manipulation dieser Fenster ge-
         *  ben, ohne eine Eingabeoperation durchfÅhren zu mÅssen, so kann
         *  es zum Beispiel regelmÑûig 'ShareTime (0L)' aufrufen.
         *)

PROCEDURE FlushEvents;

        (*  Holt solange Nachrichtenereignisse vom AES und verteilt Sie an
         *  die angemeldeten watch dogs, bis keine mehr anstehen oder sie
         *  nicht mehr angenommen werden.
         *
         *  Ist besser fÅr Redraws geeignet als 'ShareTime', da oft mehrer
         *  Redraw-Ereignisse anstehen, die gleich alle abgearbeitet werden
         *  sollen.
         *)


END EventHandler.