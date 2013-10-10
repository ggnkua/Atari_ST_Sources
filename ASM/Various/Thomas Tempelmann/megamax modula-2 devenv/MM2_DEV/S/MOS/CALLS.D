DEFINITION MODULE Calls;

(*
 * Funktionen zum Verwenden eines eigenen, definierten Stacks
 * sowie zum Aufrufen/Bereistellen von externen, Modula-fremden,
 * Funktionen.
 *
 * Die ehemaligen Funktionen 'CallSystem' und 'CallExternal' sind
 * nicht mehr vorhanden und mÅssen ggf. durch die entsprechenden
 * Funktionen aus dem Modul SYSTEM ersetzt werden.
 *)

FROM SYSTEM IMPORT LONGWORD, ADDRESS;

FROM MOSGlobals IMPORT MemArea;

FROM SysTypes IMPORT PtrAnyType, AnyType, AnyLongType;


TYPE AddrProc = PROCEDURE ( ADDRESS );


(*$H+  >> erlaubt lokale Prozeduren bei 'CallProc' *)

PROCEDURE CallProc (procedure: AddrProc; data: ADDRESS; REF workSpace: MemArea);
  (*
   * Ruft eine Modula-Funktion mit einem eigens dafÅr angelegten Stackbereich
   * auf. Der Stackbereich muû mind. 512 Byte groû sein.
   * ZusÑtzlich kann ihr in 'data' z.B. ein Pointer auf ein Datenfeld Åbergeben
   * werden.
   *
   * Beispiel:
   *
   *   TYPE dataType = RECORD a,b,c: REAL END;
   *
   *   PROCEDURE p1 ( dat0: ADDRESS );
   *     VAR a: ARRAY [1..5000] OF LONGCARD; (* belegt 20000 Bytes des Stacks *)
   *         data: POINTER TO dataType;
   *     BEGIN
   *       data:= dat0;
   *       ...
   *       data^.c:= data^.a DIV data^.b;
   *       ...
   *     END p1;
   *
   *   VAR stck: MemArea; data1, data2: dataType;
   *
   *   BEGIN
   *     stck.length := 25000;
   *     ALLOCATE ( stck.bottom, stck.length ); (* Stack-Bereich reservieren *)
   *     IF stck.bottom = NIL THEN HALT END; (* Programmstop, wenn kein Speicher *)
   *     ...
   *     data1.a:= 8.9; data1.b:= 1.144;
   *     CallProc ( p1, ADR (data1), stck );
   *     ...
   *     data2.a:= 8.9; data2.b:= 1.144;
   *     CallProc ( p1, ADR (data2), stck );
   *     ...
   *)

(*$H+  >> erlaubt lokale Prozeduren bei 'CallSupervisor' *)

PROCEDURE CallSupervisor (proc: AddrProc; data: ADDRESS; REF wsp: MemArea);
  (*
   * Wie 'CallProc', jedoch wird hier die Prozedur 'proc' im Supervisor-
   * modus aufgerufen.
   * 'wsp.length' muû mindestens 512 sein, da Platz fÅr evtl. Interrupts
   * vorhanden sein muû.
   *)

(*$H-*)

TYPE    Registers = RECORD
          regD0, regD1, regD2, regD3, regD4, regD5, regD6, regD7: AnyLongType;
          regA0, regA1, regA2, regA3, regA4, regA5, regA6       : AnyLongType;
          parm: PtrAnyType;  (* Pointer auf evtl. Daten (SP) *)
        END;

TYPE    RegsProc = PROCEDURE ( VAR Registers );


PROCEDURE NewCaller (     m2Proc       : RegsProc;
                          enterUserMode: BOOLEAN;
                          wsp          : MemArea;
                      VAR entry        : ADDRESS );
  (*
   * Generiert eine Routine, die von externen Funktionen bei 'entry' per
   * 'JSR'-Anweisung angesprungen werden kann (nicht geeignet fÅr Exceptions).
   * Sie erzeugt eine Modula-gerechte Umgebung mit Hilfe des Stackbereichs
   * 'wsp', von der dann die Modula-Funktion 'm2Proc' aufgerufen wird.
   *
   * 'm2Proc' bekommt dabei alle Informationen Åber Register und Parameter
   * Åbergeben. 'parm' enthÑlt den Stack-Pointer, der evtl. auf darauf
   * geladene Parameter zeigt.
   * Wenn 'm2Proc' endet, wird zur aufrufenden Funktion zurÅckgekehrt.
   *
   * 'enterUserMode' muû FALSE sein, wenn der Aufruf aus dem Usermode erfolgt.
   * Erfolgt der Aufruf im Supervisormode (z.B, wenn die Routine auf einen
   * System- oder Exceptionvektor installiert wird), bestimmt 'enterUserMode',
   * ob die Modula-Funktion auch im Supervisormode (FALSE) oder im Usermode
   * (TRUE) ausgefÅhrt werden soll.
   * In jedem Fall zeigt 'Registers.parm' auf die Stackdaten des Aufrufers.
   *
   * 'Registers.parm' darf willkÅrlich verÑndert werden, der Wert wird beim
   * RÅcksprung nicht benîtigt. Alle Åbrigen Werte des RECORDs werden dagegen
   * beim RÅcksprung zurÅckgeladen.
   *
   * Der Stack (wsp.length) sollte mindestens 800 Byte groû sein.
   *
   * Es muû beachtet werden, daû bei Beendigung des Programms, das
   * 'NewCaller' aufrief, 'entry' nicht mehr angesprungen werden darf.
   *
   * Wenn nach dem Aufruf 'entry' = NIL ist, konnte die Routine nicht
   * generiert werden, da der vorhandene Speicherplatz nicht ausreichte.
   *
   * Die Hilfsroutine wird im angegebenen Stack-Bereich erzeugt, somit
   * wird kein verzîgernder ALLOCATE-Aufruf mehr getÑtigt, wie in frÅheren
   * Versionen.
   *)

PROCEDURE DisposeCaller ( VAR entry: ADDRESS );
  (*
   * Ist nun ÅberflÅssig. Diese Funktion ist nur zur KompatibilitÑts-
   * wahrung noch vorhanden.
   *)

PROCEDURE SysNewCaller ( m2Proc: RegsProc; enterUserMode: BOOLEAN; wsp: MemArea; VAR entry: ADDRESS );
  (*
   * Ist nun ÅberflÅssig. Diese Funktion ist nur zur KompatibilitÑts-
   * wahrung noch vorhanden.
   *)

PROCEDURE CallExtRegs ( procAddr: ADDRESS; VAR regs: Registers );
  (*
   * Ruft eine Funktion an der Adresse 'procAddr' per JSR-Instruktion auf.
   * Alle Register kînnen frei gewÑhlt werden, nach dem Aufruf enthÑlt
   * 'regs' wiederum die von der Routine gelieferten Registerwerte.
   * Es ist nicht mîglich, Daten Åber den Stack zu Åbergeben.
   * Auch 'regs.parm' wird nicht benutzt!
   * Diese Funktion rettet sicherheitshalber selbst die Register D3-D7
   * und A3-A6.
   *)

END Calls.
