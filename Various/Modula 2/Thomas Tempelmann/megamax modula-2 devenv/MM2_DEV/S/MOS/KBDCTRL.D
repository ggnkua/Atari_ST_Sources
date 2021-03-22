DEFINITION MODULE KbdCtrl;

(*
 *                                                 Thomas Tempelmann 28.08.88
 *                                                             Stand 04.22.90
 *
 * Die Funktionen dieses Moduls bieten Zugriff auf den Tastaturpuffer.
 * Sie kînnen auch in Interruptroutinen aufgerufen werden.
 *
 * VORSICHT:
 *   Die Funktionen, die direkt auf den Tastaturpuffer zugreifen, verhindern
 *   nicht, daû wÑhrenddessen gerade ein neues Zeichen im Interrupt eingefÅgt
 *   wird. Werden die Funktionen im Tastatur-Interrupt aufgerufen, macht
 *   das natÅrlich nichts, weil wÑhrenddessen kein weiterer Interrupt auf-
 *   treten kann. Erfolt der Aufruf aber aus dem User-Modus bzw. im normal
 *   laufenden Programm, mÅssen wÑhrenddessen die Interrupts gesperrt werden.
 *   Das ist beispielsweise durch ein "Monitor-Modul" (PrioritÑt im Modulkopf,
 *   muû mind. 5 sein!) oder durch die Funktion 'LockKeyBuffer' (s.u.) mîglich.
 *
 * Damit bei den Tastenabfragen Åber die hiesigen Funktionen oder auch
 * Åber die BIOS/GEMDOS-Funktionen im oberen Wort neben dem Scan-Code
 * auch der Status der Shift-, Ctrl- und Alt- Tasten Åbermittelt wird,
 * wird Bit 3 der Systemvariable 'conterm' (bei Adr. $484) automatisch
 * bei der Initialisierung dieses Modul von seinem Kîrper (Body) gesetzt.
 * Bei Prozeûende des (Ñltesten) importierenden Moduls oder Freigabe eines
 * importierenden residenten Moduls/Programms wird der alte Wert in 'conterm'
 * wiederhergestellt.
 * Der alte Wert wird in der globalen Variablen 'PreviousMode' gerettet
 * und kann ggf. verÑndert werden, um damit eine andere RÅckstellung des
 * Wertes bei Programmende/-freigabe zu bewirken.
 * Zwischendurch kann der 'conterm'-Wert auch mit der Funktion 'SetMode'
 * verÑndert werden.
 *)

FROM MOSGlobals IMPORT Key, CtrlKey, CtrlSet;
FROM SYSTEM IMPORT ADDRESS;


VAR PreviousMode: BOOLEAN;
 (*
  * EnthÑlt den Wert des 'conterm'-Bits (Nr.3) vor dem Start dieses
  * Moduls.
  * Der Wert dieser Variablen wird bei Programmende/-freigabe wieder
  * nach 'conterm' geschrieben.
  *)

PROCEDURE CurrentMode (): BOOLEAN;
PROCEDURE SetMode (extended: BOOLEAN);
PROCEDURE SetExtMode (VAR lastMode: BOOLEAN);
 (*
  * 'CurrentMode' liefert den aktuellen Status des Bit 3 aus 'conterm',
  * 'SetMode' setzt oder lîscht das Bit, je nach dem Åbergebenen
  * BOOLEAN-Wert.
  * 'SetExtMode' setzt das Bit und liefert in 'lastMode' den vorherigen
  * Wert, sodaû dieser danach mit 'SetMode (lastMode)' zurÅckgesetzt
  * werden kann (dies ist eine optimierte Funktion, um kurzzeitig das Bit
  * zu setzen und danach wiederherzustellen).
  * VORSICHT: Diese drei Prozeduren nicht in Interrupt-Routinen aufrufen!
  *)


PROCEDURE LookKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * Liefert die als nÑchste anstehende Taste (also die Ñlteste im
  * Puffer), ohne sie aus dem Puffer zu entfernen.
  * Wenn 'ok' = FALSE, ist keine Taste vorhanden.
  *)

PROCEDURE GetKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * Holt die als nÑchste anstehende (die Ñlteste) Taste aus dem Puffer.
  * Wenn 'ok' = FALSE, ist keine Taste vorhanden.
  *)

PROCEDURE LookMostRecentKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * Liefert die zuletzt eingefÅgte Taste (also die jÅngste im
  * Puffer), ohne sie aus dem Puffer zu entfernen.
  * Wenn 'ok' = FALSE, ist keine Taste vorhanden.
  *)

PROCEDURE PushBackKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * Schreibt die Taste so in den Puffer zurÅck, daû sie als
  * nÑchste Taste wieder ausgelesen wird.
  * Wenn 'ok' = FALSE, ist der Puffer voll.
  *)

PROCEDURE PutKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * FÅgt die Taste in Puffer hinten an, so, als ob die Taste
  * gedrÅckt worden wÑre.
  * Wenn 'ok' = FALSE, ist der Puffer voll.
  *)

PROCEDURE ClrKeyBuffer;
 (*
  * Lîscht die anstehenden Tasten im Puffer.
  *)

PROCEDURE KeysAvail (): CARDINAL;
 (*
  * Liefert Anzahl der vorhandenen Tasten im Puffer
  *)

PROCEDURE KeyBufferSize (): CARDINAL;
 (*
  * Liefert Fassungsvermîgen des Puffers.
  *)

VAR KbdRec: ADDRESS;
 (*
  * Zeigt auf den verwendeten Tastaturpuffer-Descriptor des BIOS.
  * Wird von diesem Modul automatisch initialisiert, kann jedoch
  * bei Bedarf verÑndert werden.
  *)


(*
 *   Die folgenden beiden Funktionen erlauben es, mehrere Tasten mittels
 * 'PutKey' oder 'PushBackKey' nacheinander in den Puffer zu schreiben,
 * ohne daû TastendrÅcke von der Tastatur dazwischengeraten kînnen.
 * Dazu werden alle Interrupts gesperrt.
 *   Bei ihrer Verwendung ist unbedingt darauf zu achten, daû nach dem Aufruf
 * von 'LockKeyBuffer' und dem EinfÅgen der Tasten wieder 'UnlockKeyBuffer'
 * aufgerufen wird. Auch sollte die Zeit zwischen den beiden Aufrufen so
 * kurz wie mîglich gehalten werden.
 *)

PROCEDURE LockKeyBuffer ( VAR hdl: LONGCARD );
 (*
  * Sperrt die Interrupts bis einschl. Level 6. Dabei wird in 'hdl'
  * ein Wert zurÅckgegeben, der beim Aufruf von 'UnlockKeyBuffer'
  * wieder Åbergeben werden muû.
  *)

PROCEDURE UnlockKeyBuffer ( hdl: LONGCARD );
 (* Gibt die Interrupts wieder frei *)

END KbdCtrl.
