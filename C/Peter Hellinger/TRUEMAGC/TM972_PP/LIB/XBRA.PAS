UNIT XBRA;

(*------------------------------------------------------------------------*
 * Universelle XBRA-Funktionen                  Version 1.1  vom  18.6.89
 *
 * Erstellt von Thomas Tempelmann.
 *
 * Pascal-Anpassung von Peter Hellinger, 12.04.92
 *
 * Die vorhandenen Funktionen bieten alles, um auf einfache Weise installierte
 * Vektoren zu erkunden (wahlweise alle oder einen spezifischen) und sie
 * korrekt ein-, bzw. wieder auszutragen.
 *
 * Wurde eine Funktion installiert, kann durch die Funktion 'PreviousEntry' die
 * vorher installierte Routine ermittelt werden. Damit ist es dann mîglich,
 * den VorgÑnger in der Funktion selbst aufzurufen, falls dies nîtig wÑre.
 * Die zum Aufrufen notwendigen Funktionen sind jedoch nicht Bestandteil
 * dieser XBRA-Library, da sie erstens Compiler-spezifisch und zweitens
 * sie je nach Anwendung sehr unterschiedlich implementiert werden mÅssen.
 *
 * Die Funktionen sind so ausgelegt, daû sie normalerweise im User-Mode
 * aufgerufen werden und selbst beim Zugriff Åber die Vektoren in den Super-
 * visor-Mode wechseln (das Programm darf sich aber auch bereits im Supervi-
 * sor-Mode befinden). Dies erleichtert dem Programmierer die Anwendung der
 * Funktionen. Da die Anwendungen beim Installieren von Vektoren in der Regel
 * nicht zeitkritisch ausgelegt sein brauchen, sollte man diese KomfortabilitÑt
 * dem leichten Zeitverlust durch - meist - zwei statt nur einem Wechsel vom
 * User- in den Supervisor-Mode vorziehen.
 *
 *
 * Hier noch eine allgemeine Beschreibung zur Anwendung der Funktionen:
 *
 * Folgendermaûen sieht eine XBRA-Installation aus:
 *
 *   vector:= 400H;   (# z.B. der 'etv_timer'-Vektor #)
 *   IF NOT Installed ('Test', vector, at) THEN
 *     Create (carrier, 'Test', ADDRESS (TestProzedur), entry);
 *     Install (entry, at)
 *   END;
 *
 * 'Installed' prÅft, ob die Funktion schon mit XBRA-Kennung installiert
 * ist. Wenn nicht, wird mit 'Create' ein XBRA-Header erzeugt, der neben
 * der XBRA-Informationen auch eine Sprunganweisung enthÑlt. Der so
 * erzeugte Header wird dann mit 'Install' als erster neuer Vektor
 * eingetragen und die XBRA-Verkettung erzeugt.
 *
 * Da je nach Implementation verschiedene Prozeduren mit beliebigen
 * Parametern verwendet werden kînnten, und der XBRA-Header nur einfach
 * dazwischengesetzt wird, ist die Prozeduradresse 'call' als ADDRESS
 * deklariert. FÅr die korrekte ParameterÅbergabe haben nicht die XBRA-
 * Funktionen zu sorgen, sondern schon die Routine, die zu installierende
 * Funktion Åber den Vektor aufruft.
 *
 * Zum Vergleich obige Installation ohne XBRA:
 *   vector:= 400H;  (# VAR vector: POINTER TO ADDRESS #)
 *   vector^:= ADDRESS (TestProzedur);
 * Falls es Probleme gibt, sollte erst das Programm ohne XBRA zum Laufen
 * gebracht werden, und dann erst die XBRA-Installation eingefÅgt werden.
 * Z.B. ist beim Megamax-System zu beachten, daû normalerweise Installationen
 * Åber externe Vektoren Åber die Funktionen aus dem Modul 'Calls' vorgenommen
 * werden sollten. Dies bleibt auch so, wenn dann die XBRA-Funktionen zuhilfe
 * genommen werden!
 *
 * Soll die Funktion spÑter wieder aus der Vektor-Kette ausgehÑngt werden,
 * geht das so:
 *
 *   IF Installed ('Test', vector, at) THEN
 *     Remove (at)
 *   END
 *
 * Bei 'PreviousEntry' (s.o.) wird der bei 'Create' erhaltene 'entry'-Wert
 * wieder Åbergeben, um z.B. in 'TestProzedur' den VorgÑnger zu
 * ermitteln und dann ggf. aufzurufen.
 *
 * 'Query' dient dazu, alle installierten XBRA-Kennungen einer Vektor-
 * Kette zu ermitteln. Dabei kînnen auch z.B. mit folgender Routine alle
 * installierten XBRA-Vektoren ausgehÑngt werden:
 *
 *   PROCEDURE step (at: ADDRESS; name: Str4): BOOLEAN;
 *     BEGIN
 *       (#
 *        * Hier kînnten der jeweilige VorgÑnger mit
 *        *  'PreviousEntry ( Entry (at) )'
 *        * oder die Adr. der aufgerufenen Prozedur mit
 *        *  'Called (at)'  ermittelt und angezeigt werden.
 *        #)
 *       IF prev # NIL THEN (# ist dies ein XBRA-Eintrag? #)
 *         Remove (at)      (#  -> nur dann kann er entfernt werden #)
 *       END;
 *       RETURN TRUE        (# weitermachen, solange die Kette weitergeht #)
 *     END step;
 *
 *   PROCEDURE RemoveAll (vector: ADDRESS);
 *     BEGIN Query (vector, step) END RemoveAll;
 *
 *
 * HINWEIS:
 * --------
 * Diese Version ist eine Anpassung an Pure Pascal, sollte aber auch mit
 * anderen Pascal-Dialekten funktionieren.  Die obigen Hinweise beziehen
 * sich auf die Original-Implementation in Modula-2!!!  ph 12.04.92
 *)

INTERFACE

TYPE    ID =            ARRAY [0..3] OF CHAR;
                        (* String zur Aufnahme der Kennung *)

TYPE    JmpCarrier =    RECORD             (* Interne Datenstruktur!     *)
                         jmpInstr: WORD;   (*  - nicht darauf zugreifen! *)
                         operand: POINTER;
                        END;
                

TYPE    Carrier =       RECORD (* Interne Datenstruktur - nicht darauf zugreifen! *)
                         magic: ID;         (* CONST 'XBRA' *)
                         name : ID;         (* individuelle Kennung *)
                         prev : POINTER;    (* voriger Vektor *)
                         entry: JmpCarrier;
                        END;

TYPE    QueryProc =     FUNCTION (at: POINTER; name: ID): BOOLEAN;


(*
 * Funktionen fÅr die XBRA-Installation
 * ------------------------------------
 *)

PROCEDURE Create (VAR use: Carrier; name: ID; call: POINTER; 
                  VAR entry: POINTER);
(*
 * Erzeugt einen XBRA-Header mit einer Sprunganweisung zur Prozedur 'call'.
 * Achtung: die Carrier-Variable muû global (statisch) deklariert sein -
 *   sie muû so lange erhalten bleiben, wie die XBRA-Einbindung besteht!
 * Der erhaltene 'entry'-Wert kann daraufhin mittels der Prozedur 'Install'
 * in den gewÅnschten Vektor eingetragen werden.
 *)

FUNCTION Installed (name: ID; vector: POINTER; VAR at: POINTER): BOOLEAN;
(*
 * Wird 'name' in Kette ab 'vector' gefunden, enthÑlt 'at' die Adresse
 * des Vektors auf den Funktionseinsprung (welcher Teil von 'Carrier' ist).
 * Wird 'name' nicht gefunden, ist 'at'=vector
 *)

PROCEDURE Install (entry: POINTER; at: POINTER);
(*
 * FÅgt einen XBRA-Header 'entry' im Vektor 'at' ein. Der alte Vektorinhalt
 * wird im XBRA-Header gesichert und kann mittels 'PreviousEntry' abgefragt
 * werden.
 *)

PROCEDURE Remove (at: POINTER);
(*
 * Klinkt den XBRA-Header, auf den der Vektor bei 'at' zeigt, aus.
 * In den Vektor wird wieder der VorgÑnger eingetragen.
 *)

(*
 * Funktionen zum Abfragen XBRA-Informationen
 * ------------------------------------------
 *)

PROCEDURE Query (vector: POINTER; withproc: QueryProc);
(*
 * Ruft 'with' fÅr alle im Vektor 'vector' installierten Funktionen auf,
 * solange sie durch XBRA-Strukturen verbunden sind.
 * Die 'with'-Funktion kann 'FALSE' zurÅckgeben, um die Aufrufe vorzeitig
 * zu beenden.
 *)

FUNCTION Entry (at: POINTER): POINTER;
(*
 * Liefert die Adresse, auf die der Vektor 'at' zeigt.
 * Dies ist der "Entry", vor dem ggf. die XBRA-Struktur steht.
 * Das Ergebnis dieser Funktion kann z.B. fÅr die 'PreviousEntry'-Funktion
 * verwendet werden, sollte jedoch nicht zur rein informativen Ermitttelung
 * der in 'at' installierten Funktion verwendet werden - dafÅr ist 'Called'
 * (s.u.) vorgesehen!
 *)

FUNCTION PreviousEntry (entry: POINTER): POINTER;
(*
 * Liefert den "Entry", der vor dem angegebenen "Entry" installiert ist.
 * Diese Funktion kann z.B. in der eigenen installierten Funktion dazu
 * benutzt werden, den VorgÑnger aufzurufen (hier sollte aus Effizienz-
 * grÅnden nicht 'Called' verwendet werden), um eine Aufrufkette zu reali-
 * sieren (ist z.B. beim 200Hz-Vektor sinnvoll, da hier mehrere Routinen
 * hintereinander installiert werden, die alle sich nacheinander aufrufen).
 * Zu diesem Zweck muû dann der bei 'Create' erhaltene 'entry'-Wert Åber-
 * geben werden. Achtung: Da damit gerechnet werden muû, daû wÑhrend der
 * Lebzeit des Programms im Speicher die XBRA-Verkettung jederzeit ver-
 * Ñndert werden kann, darf nicht einmalig fest die VorgÑngeradr. abgefragt
 * und dann Åber eine Programmlokale Variable adressiert werden, sondern
 * muû immer genau dann, wenn sie benîtigt wird, mit dieser Funktion ab-
 * gefragt werden. Es sind dabei keine nennenswerten Zeitverluste zu be-
 * fÅrchten.
 * Wenn 'entry'=NIL, oder kein VorgÑnger ermittelt werden kann (keine XBRA-
 * Struktur vorhanden), wird NIL geliefert.
 *)

FUNCTION Called (at: POINTER): POINTER;
(*
 * Liefert die korrekte Programmeinsprungstelle, die Åber den Vektor 'at'
 * erreicht wird. Dies wÑre normalerweise identisch mit dem Ergebnis der
 * 'Entry'-Funktion, jedoch wird hier erkannt, wenn diese "Entry"-Stelle
 * nur die von diesem Modul erzeugte Sprunganweisung in die eigentliche
 * Funktion ist, die bei der 'Install'-Funktion angegeben wurde. Dann
 * wird jene Funktionsadresse geliefert.
 *)

IMPLEMENTATION

(*
  18.06.89 Thomas Tempelmann:   Megamax-Version
  04.07.89 Peter Hellinger:     Umgearbeitet auf TDI
  05.05.91 Peter Hellinger:     Modul arbeitet jetzt unabhÑngig vom 
                                verwendeten Compiler (MM2, TDI, SPC, LPR)
  12.04.92 Peter Hellinger:     Modula-2 to Pascal
*)

USES OS;

{$I COMPOPT.INC}

CONST   JmpInstr =      $4EF9; (* Code fÅr 'JMP <adr>.L' *)


(* MODULE SysUtil1; *)
  
(*
 * lokales Modul mit Funktionen zum Zugriff auf Daten im Supervisor-Modus
 * ----------------------------------------------------------------------
 *
 * Die in diesem Modul verwendeten Funktionen
 *   SuperPeek, SuperLPeek und SuperLPoke
 * dienen dazu, Daten im Supervisor-Mode zuzuweisen. Sie sind folgender-
 * maûen definiert:
 *   PROCEDURE SuperPeek  ( addr: ADDRESS; VAR data: ARRAY OF BYTE );
 *     liest ab der Adresse 'addr' die Anzahl von 'HIGH (data)+1' Bytes.
 *   PROCEDURE SuperLPeek ( addr: ADDRESS ): LONGWORD;
 *     liefert 4 Bytes ab Adresse 'addr'.
 *   PROCEDURE SuperLPoke ( addr: ADDRESS; data: LONGWORD );
 *     weist 4 Bytes ab Adresse 'addr' zu.
 * Diese Funktionen mÅssen auch korrekt ablaufen, wenn bereits bei ihrem
 * Aufruf der Supervisor-Mode aktiv ist. Sie kînnen wahlweise durch Verwen-
 * dung der Funktion 'XBIOS.SuperExec' ('sup_exec()') oder mit 'GEMDOS.Super'
 * ('super()') implementiert werden.
 *)

TYPE    datarray = ARRAY [1..4096] OF BYTE;
VAR     from, topos: ^datarray;
        bytes:    INTEGER;
  
FUNCTION setbytes: LONGINT;
VAR i: INTEGER;
BEGIN
 FOR i:= 1 TO bytes DO BEGIN  topos^[i]:= from^[i];  END;
 setbytes:= 0;
END (*setbytes*);
  
PROCEDURE SuperPeek  (adr: POINTER; VAR data: Carrier);
BEGIN
 from:= adr;
 topos:= ADDR (data);
 bytes:= SIZEOF (data);
 Supexec (setbytes); (* 'setbytes' im Supervisor-Mode ausfÅhren *)
END (*SuperPeek*);
  
FUNCTION SuperLPeek (adr: POINTER): LONGINT;
VAR data: LONGINT;
BEGIN
 from:= adr;
 topos:= ADDR (data);
 bytes:= 4;
 Supexec (setbytes); (* 'setbytes' im Supervisor-Mode ausfÅhren *)
 SuperLPeek:= data;
END (*SuperLPeek*);
  
PROCEDURE SuperLPoke (adr: POINTER; data: POINTER);
BEGIN
 from:= ADDR (data);
 topos:= adr;
 bytes:= 4;
 Supexec (setbytes); (* 'setbytes' im Supervisor-Mode ausfÅhren *)
END (*SuperLPoke*);
  
(* END SysUtil1; *)

CONST   Magic:          ID = 'XBRA';
        entryOffs =     12; (* Differenz zw. 'Carrier.magic' und 'Carrier.entry' *)

(*
 * Hilfsfunktionen, die ggf. optimiert werden kînnen
 * -------------------------------------------------
 *)

FUNCTION equal (s1, s2: ID): BOOLEAN;
BEGIN
 equal:= (s1[0] = s2[0]) AND 
         (s1[1] = s2[1]) AND
         (s1[2] = s2[2]) AND
         (s1[3] = s2[3]);
END (*equal*);

FUNCTION sub (p: POINTER; n: INTEGER): POINTER;
VAR x, y: LONGINT;
BEGIN
 (* sub:= POINTER (LONGINT (p) - LONGINT (n)); klappt nicht! *)
 y:= LONGINT (p);
 x:= y - n;
 sub:= POINTER (x);
END (*sub*);

(*
 * Exportierte Funktionen
 * ----------------------
 *)

PROCEDURE Create (VAR use: Carrier; name: ID; call: POINTER; 
                  VAR entry: POINTER);
VAR i: INTEGER;
BEGIN
 use.name:= name;
 FOR i:= 0 TO 3 DO BEGIN  use.magic[i]:= Magic[i];  END;
 use.prev:= NIL;
 use.entry.jmpInstr:= JmpInstr; (* Code fÅr 'JMP <adr>.L' *)
 use.entry.operand:= call;
 entry:= ADDR (use.entry)
END (*Create*);

FUNCTION Installed (name: ID; vector: POINTER; VAR at: POINTER): BOOLEAN;
VAR pc:    ^Carrier;
    entry: POINTER;
    c:     Carrier;
    lw:    LONGINT;
    b:     BOOLEAN;
BEGIN
 at:= vector; b:= TRUE; (* Vorwahl fÅr RETURN FALSE *)
 REPEAT
  entry:= POINTER (SuperLPeek (vector));
  IF entry = NIL THEN BEGIN  Installed:= FALSE;  EXIT;  END;
  pc:= sub (entry, entryOffs);
  SuperPeek (pc, c);
  IF equal (c.magic, Magic) THEN
   (* XBRA-Kennung gefunden *)
   IF equal (c.name, name) THEN BEGIN
    at:= vector;  Installed:= TRUE;  EXIT;
   END
   ELSE BEGIN
    vector:= sub (entry, 4);
   END
  ELSE BEGIN
   (* Ende, da XBRA-Kette zuende *)
   b:= FALSE;
  END;
 UNTIL NOT b;
 Installed:= b;
END (*Installed*);

PROCEDURE Install (entry: POINTER; at: POINTER);
VAR pc: ^Carrier;
BEGIN
 IF (entry = NIL) OR (at = NIL) THEN  EXIT;
 pc:= sub (entry, entryOffs);
 pc^.prev:= POINTER (SuperLPeek (at));
 SuperLPoke (at, entry);
END (*Install*);

PROCEDURE Remove (at: POINTER);
VAR pc:    ^Carrier;
    entry: POINTER;
    c:     Carrier;
BEGIN
 IF at = NIL THEN  EXIT;
 entry:= POINTER (SuperLPeek (at));
 IF entry = NIL THEN  EXIT;
 pc:= sub (entry, entryOffs);
 SuperPeek (pc, c);
 IF equal (c.magic, Magic) THEN  SuperLPoke (at, c.prev);
END (*Remove*);

PROCEDURE Query (vector: POINTER; withproc: QueryProc);
CONST dummy: ID = '????';
VAR pc:    ^Carrier;
    entry: POINTER;
    c:     Carrier;
    b:     BOOLEAN;
BEGIN
 b:= TRUE;
 WHILE b DO BEGIN
  entry:= POINTER (SuperLPeek (vector));
  IF entry = NIL THEN BEGIN  EXIT;  END;
  pc:= sub (entry, entryOffs);
  SuperPeek (pc, c);
  IF NOT equal (c.magic, Magic) THEN BEGIN  b:= FALSE;  END;
  IF NOT withproc (vector, c.name) THEN BEGIN  EXIT;  END;
   (* VorgÑnger ist dran *)
  vector:= sub (entry, 4)
 END;
 (*b:=*) withproc (vector, dummy)
END (*Query*);

FUNCTION Entry (at: POINTER): POINTER;
BEGIN
 Entry:= POINTER (SuperLPeek (at));
END (*Entry*);

FUNCTION Called (at: POINTER): POINTER;
VAR pc:    ^Carrier;
    entry: POINTER;
    c:     Carrier;
BEGIN
 entry:= POINTER (SuperLPeek (at));
 IF entry <> NIL THEN BEGIN
  pc:= sub (entry, entryOffs);
  SuperPeek (pc, c);
  IF equal (c.magic, Magic) THEN BEGIN
   IF c.entry.jmpInstr = JmpInstr THEN BEGIN
    (* Wenn dies eine vom XBRA-Modul erzeugte Struktur ist, dann lie- *)
    (* fern wir die Code-Adresse, die bei 'Install' angegeben wurde.  *)
    Called:= c.entry.operand;  EXIT;
   END
  END;
  (* Ansonsten wird einfach die direkte Einsprungadr. geliefert *)
  Called:= entry;  EXIT;
 END;
 Called:= NIL;
END (*Called*);

FUNCTION PreviousEntry (entry: POINTER): POINTER;
VAR pc: ^Carrier;
BEGIN
 IF entry <> NIL THEN BEGIN
  pc:= sub (entry, entryOffs);
  IF equal (pc^.magic, Magic) THEN BEGIN
   PreviousEntry:= pc^.prev;  EXIT;
  END;
 END;
 PreviousEntry:= NIL;
END (*PreviousEntry*);

END (*XBRA*).
