DEFINITION MODULE SysUtil2;

(*
 * SetJump/LongJump (globales GOTO), sowie Funktionen zum Erlangen des
 * Supervisormodus und Kontrolle der Interruptlevel-Maske.
 *
 * 07.12.88  TT  Grunderstellung
 * 13.06.90  TT  'SupervisorMode'/'UserMode' in 'EnterSupervisorMode'
 *               und 'LeaveSupervisorMode' umbenannt, 'InSupervisorMode' neu.
 *)


FROM SYSTEM IMPORT WORD, ADDRESS, LONGWORD;

(*
 * C-artige 'SetJmp' / 'LongJmp'
 * -----------------------------
 *
 *   Diese aus der Sprache C bekannten Funktionen stellen ein "globales"
 * GOTO dar. 'SetJump' deklariert ein "Label" und 'LongJump' fÅhrt den
 * Sprung aus. Die Verwendung dieser Funktionen ist v.A. fÅr Fehlerbehand-
 * lungen sehr nÅtzlich. So kann beispielsweise von einem tief verschachtel-
 * ten Prozeduraufruf direkt zurÅck auf hîher gelegenes Level zurÅckge-
 * sprungen werden.
 *   Zu beachten ist dabei, daû nie von einer "hîheren" in eine "tiefer"
 * verschachtelte Funktion gesprungen werden darf (z.B. von einer Prozedur
 * in ihre lokale), da in einem solchen Fall der dazwischen notwendige
 * Initialisierungsteil fÅr die lokalen Daten fehlen wÅrde. In der anderen
 * Richtung werden lediglich alle lokalen Daten "weggeworfen", Ñhnlich der
 * RETURN-Anweisung bei Modula-2.
 *
 * Beispiel:
 *
 *  VAR ljbuf1: JumpBuf;
 *  PROCEDURE zwei;
 *    PROCEDURE lokal;
 *      BEGIN
 *         IF fehler1 () THEN LongJump (ljbuf1, 1) END;
 *      END lokal;
 *    BEGIN (* von 'zwei' *)
 *      lokal;
 *      IF fehler2 () THEN LongJump (ljbuf1, 2) END;
 *    END zwei;
 *  PROCEDURE haupt;
 *    BEGIN
 *      CASE SetJump (ljbuf1) OF
 *        0: (* Label wurde deklariert -> 'zwei' aufrufen: *)
 *           zwei;
 *           (* 'zwei' kehrte ohne Fehler zurÅck *)
 *           zeige ('Kein Fehler.')
 *      | 1: zeige ('Fehler in Prozedur "lokal" !')
 *      | 2: zeige ('Fehler in Prozedur "zwei" !')
 *      END;
 *    END haupt;
 *
 * Im Beispiel wird zuerst 'haupt' ausgefÅhrt. Diese installiert die Sprung-
 * marke 'ljbuf1' und ruft dann 'zwei' auf. Jene Prozedur ruft 'lokal' auf,
 * welche dann eine Operation durchfÅhrt, die ggf. einen RÅcksprung zur
 * 'SetJump'-Anweisung ausfÅhrt. Ist dies nicht der Fall, kann ebenso, nach
 * RÅckkehr zu 'zwei' diese Prozedur einen RÅcksprung auslîsen - im Gegensatz
 * zum 'LongJump'-Aufruf in 'lokal' wird hier aber zur Kontrolle ein anderer
 * Wert (2) zurÅckgeliefert. Wird auch dieser 'LongJump'-Aufruf nicht durch-
 * gefÅhrt, kehrt 'zwei' normal zu 'haupt' zurÅck, wo "kein Fehler" signali-
 * siert wird. In den anderen FÑllen wird zu den anderen CASE-Marken gesprun-
 * gen und ein entsprechender Fehler signalisiert.
 *)

TYPE JumpBuf = RECORD
                 pc: ADDRESS;
                 ssp: LONGWORD;
                 usp: LONGWORD;
                 sr: WORD;
                 d: ARRAY [1..7] OF LONGWORD;
                 a: ARRAY [1..6] OF LONGWORD;
               END;

PROCEDURE SetJump ( VAR hdl: JumpBuf ): INTEGER;
  (*
   * Setzt eine "globale" RÅcksprungmarke.
   * Das bedeutet, daû diese Prozedur nach ihrem Aufruf den Wert Null liefert.
   * Wird dann spÑter 'LongJump' (s.u.) mit demselben 'hdl' aufgerufen, wird
   * das Programm wiedrum hinter 'SetJump' weitergefÅhrt, wobei diese Proze-
   * dur einen von Null verschiedenen Wert liefern wird.
   *)

PROCEDURE LongJump ( VAR hdl: JumpBuf; rtnCode: INTEGER );
  (*
   * FÅhrt einen RÅcksprung zum Aufruf der zu 'hdl' gehîrenden 'SetJump'-
   * Funktion durch. 'SetJump' liefert dabei 'rtnCode'. 'rtnCode' darf nicht
   * Null sein - ist dies trotzdem der Fall, wird stattdessen 1 geliefert.
   *
   * Restauriert D3-D7, A3-A7, PC und SR (incl. User-/Superv.-Modus und IRMask)
   *)

(*
 * Enter/LeaveSupervisorMode
 * -------------------------
 *   zum Erlangen des Supervisor-Modus und RÅckkehr in den User-Modus.
 * Nur im Supervisor-Modus lassen sich bestimmte Operationen durchfÅhren,
 * wie z.B. der Zugriff auf die Systemvariablen auf den Adressen zw. $400
 * und $800 (gerade fÅr solche Zugriffe bieten sich aber eher die Peek-
 * und Poke-Funktionen aus dem Modul 'SysUtil1' an!).
 * Auch kann alternativ die Funktion 'Calls.CallSupervisor' verwendet werden.
 *
 * Als Stack wird der aktuelle User-Stack verwendet.
 *)

TYPE ModeBuf = LONGWORD;

PROCEDURE EnterSupervisorMode ( VAR hdl: ModeBuf );
PROCEDURE LeaveSupervisorMode ( VAR hdl: ModeBuf );
PROCEDURE InSupervisorMode (): BOOLEAN;
  (*
   * 'EnterSupervisorMode' darf auch im Supervisor-Modus aufgerufen werden,
   * in dem Fall Ñndert sich nichts.
   * Ein 'LeaveSupervisorMode'-Aufruf nur nach vorherigem Aufruf von
   * 'EnterSupervisorMode' erfolgen!
   * Beide Aufrufe mÅssen auf demselben "Scope-Level" erfolgen.
   * Das heiût, daû sie nicht nur in der selben Prozedur, sondern auch auf
   * dem selben EinrÅckungs-Level erfolgen mÅssen (also z.B. nicht die eine
   * auûerhalb einer FOR- und die andere innerhalb dieser Schleife).
   *
   * 'InSupervisorMode()' liefert TRUE, wenn sich das Programm gerade im
   * Supervirsor-Modus befindet.
   *)

TYPE IRLevel = [0..7];

PROCEDURE SetIRMask ( level: IRLevel );
  (*
   * Setzt, unabhÑngig vom Modus (User- o. Supervisor), die Interruptlevel-
   * Maske (0-7).
   *)

PROCEDURE IRMask (): IRLevel;
  (*
   * Liefert den aktuellen Wert der IR-Level-Maske.
   *)

END SysUtil2.
