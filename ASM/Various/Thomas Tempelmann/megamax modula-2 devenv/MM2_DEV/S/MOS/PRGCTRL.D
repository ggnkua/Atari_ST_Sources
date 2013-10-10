DEFINITION MODULE PrgCtrl;

(*
 * Dies Modul dient zur Kontrolle von programm-/prozeûbedingten Ereignissen:
 *  - Prozeûbeendigung (TermProcess)
 *  - Abfangen einer Prozeûbeendigung (CatchProcessTerm)
 *  - Abfangen von neuen Prozeûstarts und deren Beendigungen (SetEnvelope)
 *  - Ermitteln der 'Base Page' eines Prozesses (GetBasePageAddr)
 *  - Erkennung, ob das Programm als Accessory gestartet wurde (Accessory).
 *)

FROM SYSTEM IMPORT LONGWORD, WORD, ADDRESS;

FROM MOSGlobals IMPORT MemArea;


TYPE    PState = ( created,   (* Angelegt, aber noch nicht laufend. *)
                   opening,   (* Prozeû aktiv in Initialisierung. *)
                   running,   (* Prozeû aktiv im Hauptprogramm. *)
                   closing,   (* Prozeû aktiv in Deinitialisierung. *)
                   finished );(* Prozeû beendet. *)


PROCEDURE TermProcess ( exitCode: INTEGER );
  (*
   * Abbruch eines Prozesses. Wenn ein Modul mittels "SetChain" (im
   * Modul "Loader") als Nachfolger bestimmt wurde, wird dieses gestartet.
   * Ansonsten erfolgt RÅckkehr zum aufrufenden Modul / Programm.
   *)


TYPE TermCarrier = ARRAY [0..9] OF WORD;

PROCEDURE CatchProcessTerm ( VAR hdl: TermCarrier; call: PROC; wsp: MemArea );
  (*
   * Ermîglicht das Anmelden von Prozeduren, die aufgerufen werden,
   * wenn der zum Zeitpunkt der Anmeldung aktive Prozeû beendet wird.
   *
   * Achtung: Diese Funktion eignet sich nicht fÅr die Verwendung in Imple-
   * mentations-Moduln, die 'Sys'-Funktionen verwenden oder "Systemvektoren"
   * verÑndern - in solchen FÑllen muû die Funktion 'CatchRemoval' aus
   * 'ResCtrl' verwendet werden (siehe auch Anmerkungenin betreffendem Def-
   * Text)! 'CatchProcessTerm' sollte nur im Hauptmodul oder in FÑllen, in
   * denen wirklich das Prozeûende erwartet wird, verwendet werden!
   * Siehe auch Beispielprogramm 'SysLibDemo.M' im UTILITY-Ordner.
   *
   * Der Funktion 'call' wird beim Aufruf 'wsp' als Stack zugeteilt.
   * Wenn 'wsp.bottom' = NIL ist, wird der Stack des beendeten Prozesses
   * verwendet, was in der Regel empfohlen werden kann.
   *
   * Die angemeldeten Prozeduren werden automatisch nach ihrem Aufruf
   * abgemeldet.
   *
   * 'hdl' darf keine lokale Variable sein, sie muû so lange erhalten
   * bleiben, bis 'call' aufgerufen wurde !
   *
   * Es ist darauf zu achten, daû diese Funktion nur einmal pro anzumeldende
   * 'call'-Prozedur aufgerufen wird.
   *
   * FÅr diese Funktion wird der 'etv_term'-Systemvektor benutzt, dabei
   * wird die XBRA-Kennung 'MM2T' verwendet.
   *)


TYPE EnvlpCarrier = ARRAY [0..15] OF WORD;
     EnvlpProc = PROCEDURE (    (* opening: *) BOOLEAN,
                                (* inChild: *) BOOLEAN,
                            VAR (* exitCode:*) INTEGER );

PROCEDURE SetEnvelope ( VAR hdl: EnvlpCarrier; call: EnvlpProc; wsp: MemArea );
  (*
   * Hiermit kînnen Funktionen angemeldet werden, die jeweils bei Start
   * und Beendigung eines neuen Prozesses aufgerufen werden.
   *
   * Der Funktion 'call' wird beim Aufruf 'wsp' als Stack zugeteilt.
   * Wenn 'wsp.bottom' = NIL ist, wird der Stack des beendeten Prozesses
   * verwendet (ist in der Regel empfehlenswert).
   *
   * 'call' wird fÅr einen neuen Prozeû viermal aufgerufen. Die beiden
   * Parameter geben den Aufrufzeitpunkt an, die Funktion kann dann bei
   * den beiden Aufrufen mit 'inChild'=FALSE (s.u.) jeweils einen Fehler-
   * code (s. MOSGlobals) in 'exitCode' liefern, wenn ein Fehler aufgetre-
   * ten ist. Bei 'inChild'=TRUE kann der Prozeû auch direkt mit einem
   * Laufzeitfehler beendet werden.
   * Je ein Aufruf erfolgt vor Einrichtung ('opening' = TRUE) und nach
   * Entfernung ('opening' = FALSE) des neuen Prozesses ('inChild' ist
   * dabei immer FALSE). Tritt beim ersten Aufruf kein Fehler auf, er-
   * folgen zwei Aufrufe direkt nach Einrichtung ('opening' = TRUE) und
   * vor Entfernung ('opening' = FALSE) des neuen Prozesses ('inChild'
   * ist dabei immer TRUE).
   *
   * Die Funktion 'call' kann mit der Prozedur "RemoveEnvelope" abgemeldet
   * werden.
   *
   * 'hdl' darf keine lokale Variable sein, sie muû so lange erhalten
   * bleiben, wie die Funktion 'call' angemeldet ist.
   *
   * Es ist darauf zu achten, daû diese Funktion nur einmal pro anzumeldende
   * 'call'-Prozedur aufgerufen wird.
   *
   * WICHTIG: Das benutzende Modul muû mit der Directive "$Y+" Åbersetzt
   *          werden!
   *)

PROCEDURE SysSetEnvelope (VAR hdl: EnvlpCarrier; call: EnvlpProc; wsp: MemArea);
  (*
   * Siehe Anm. zu 'Sys'-Funktionen im Handbuch
   *)

PROCEDURE RemoveEnvelope ( VAR hdl: EnvlpCarrier );
  (*
   * Meldet das Funktionenpaar, das vorher mit "SetEnvelope" angemeldet
   * war, wieder ab.
   *)

PROCEDURE GetBasePageAddr ( VAR bpp: ADDRESS );
  (*
   * Liefert die Adresse der Base-Page vom aktuellen Programm
   * (auch bei Accessories).
   * Vorsicht bei residenten Programmen: Hier muû, wenn die Base-Page
   * vom eigenen Programm ermittelt werden soll, diese Funktion
   * aufgerufen werden, bevor sich das Programm resident gemacht
   * und sich beendet hat!
   *)

PROCEDURE Accessory (): BOOLEAN;
  (*
   * Liefert TRUE, wenn das Programm als Accessory gestartet wurde.
   *)

PROCEDURE ActiveProcess (): ADDRESS;
  (*
   * Liefert die Adresse der 'base page' des gerade aktiven Prozesses
   * (eines mit 'Pexec' oder 'Loader.CallModule' gestarteten Programms
   * oder Moduls).
   * Bei Accessories wird dann hier nicht die Basepage des ACCs, sondern
   * die des laufenden Hauptprogramms geliefert.
   *)

PROCEDURE BaseProcess (): ADDRESS;
  (*
   * Liefert immer die 'base page' des untersten, gelinkten Prozesses.
   * Dies geht auch bei Accessories und residenten Programmen.
   *)

PROCEDURE ProcessLinked (): BOOLEAN;
  (*
   * Liefert TRUE, wenn der aktive Prozeû der unterste, gelinkte ist.
   * Bei Accessories und residenten Programmen wird ebenfalls TRUE geliefert.
   *)

PROCEDURE ProcessState (): PState;
  (*
   * Liefert den augenblicklichen Status des laufenden Prozesses.
   *)

PROCEDURE CurrentExitCode (): INTEGER;
PROCEDURE SetNewExitCode ( i: INTEGER );
  (*
   * Die Funktionen sind gedacht, um wÑhrend der Terminierungsphase eines
   * Programm den ExitCode nachtrÑglich zu Ñndern (so, wie es beim
   * Envelope-Handler direkt durch éndern der Åbergebenen 'exitCode'-Variablen
   * mîglich ist). Deshalb kînnen diese Funktionen nur aufgerufen werden,
   * solange 'ProcessState () = closing' ist.
   * 'CurrentExitCode' liefert den bisherigen ExitCode,
   * 'SetNewExitCode' weist ihm einen neuen Wert zu.
   *)

END PrgCtrl.
