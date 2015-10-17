
IMPLEMENTATION MODULE XBRA;

(*
  18.06.89 Thomas Tempelmann: Megamax-Version
  24.10.90 Thomas Tempelmann: $H+
  04.11.90 Thomas Tempelmann: $S-
  10.02.91 Thomas Tempelmann: Neben dem Null-Ptr wird nun auch ein Ptr auf sich
                              selbst als Listenende gewertet, da das proTOS fÅr
                              den hyperCACHE 030 solche XBRA-Listen anlegt.
*)

(*$Y+,H+,R-,S-*)

FROM SYSTEM IMPORT ASSEMBLER;

FROM SYSTEM IMPORT ADR, ADDRESS, BYTE;

FROM SysUtil1 IMPORT SuperPeek, SuperLPeek, SuperLPoke;

(*
IMPORT XBIOS;
*)

CONST
  JmpInstr = 4EF9H; (* Code fÅr 'JMP <adr>.L' *)

(* fÅr nicht-Megamax-Systeme:
  MODULE SysUtil1;
  
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
    *   PROCEDURE SuperLPeek ( addr: ADDRESS ): LONGCARD;
    *     liefert 4 Bytes ab Adresse 'addr'.
    *   PROCEDURE SuperLPoke ( addr: ADDRESS; data: LONGCARD );
    *     weist 4 Bytes ab Adresse 'addr' zu.
    * Diese Funktionen mÅssen auch korrekt ablaufen, wenn bereits bei ihrem
    * Aufruf der Supervisor-Mode aktiv ist. Sie kînnen wahlweise durch Verwen-
    * dung der Funktion 'XBIOS.SuperExec' ('sup_exec()') oder mit 'GEMDOS.Super'
    * ('super()') implementiert werden.
    *)
  
    IMPORT ADR, ADDRESS, BYTE;
    FROM XBIOS IMPORT SuperExec;
  
    EXPORT SuperPeek, SuperLPeek, SuperLPoke;
  
    VAR from, to: POINTER TO BYTE; bytes: CARDINAL;
  
    PROCEDURE set;
      BEGIN
        WHILE bytes > 0 DO
          to^:= from^;
          to:= ADDRESS (to) + 1L;
          from:= ADDRESS (from) + 1L;
          DEC (bytes)
        END
      END set;
  
    PROCEDURE SuperPeek  ( addr: ADDRESS; VAR data: ARRAY OF BYTE );
      BEGIN
        from:= addr;
        to:= ADR (data);
        bytes:= HIGH (data)+1;
        SuperExec ( ADDRESS (set) ) (* 'set' im Supervisor-Mode ausfÅhren *)
      END SuperPeek;
  
    PROCEDURE SuperLPeek ( addr: ADDRESS ): LONGCARD;
      VAR data: LONGCARD;
      BEGIN
        from:= addr;
        to:= ADR (data);
        bytes:= 4;
        SuperExec ( ADDRESS (set) ); (* 'set' im Supervisor-Mode ausfÅhren *)
        RETURN data
      END SuperLPeek;
  
    PROCEDURE SuperLPoke ( addr: ADDRESS; data: LONGCARD );
      BEGIN
        from:= ADR (data);
        to:= addr;
        bytes:= 4;
        SuperExec ( ADDRESS (set) ) (* 'set' im Supervisor-Mode ausfÅhren *)
      END SuperLPoke;
  
    END SysUtil1; (* lokales Modul *)
*)

CONST Magic = 'XBRA';

      entryOffs = 12L; (* Differenz zw. 'Carrier.magic' und 'Carrier.entry' *)

 (*
  * Hilfsfunktionen, die ggf. optimiert werden kînnen
  * -------------------------------------------------
  *)

(*$Z+*)
PROCEDURE equal (s1, s2: ID): BOOLEAN;
(*$Z-,L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        CMP.L   -(A3),D0
        SEQ     D0
        ANDI    #1,D0
        ; MOVE    D0,(A3)+
    END
  END equal;
  (*$L=*)

 (*
  * Exportierte Funktionen
  * ----------------------
  *)

PROCEDURE Create (VAR use: Carrier; nam: ID; call: ADDRESS;
                  VAR entr: ADDRESS);
  BEGIN
    WITH use DO
      name:= nam;
      magic:= Magic;
      prev:= NIL;
      entry.jmpInstr:= JmpInstr; (* Code fÅr 'JMP <adr>.L' *)
      entry.operand:= call;
      entr:= ADR (entry)
    END
  END Create;

PROCEDURE Installed (name: ID; vector: ADDRESS; VAR at: ADDRESS): BOOLEAN;
  VAR lastentry, entry: ADDRESS; c: Carrier;
  BEGIN
    lastentry:= 0;
    at:= vector; (* Vorwahl fÅr RETURN FALSE *)
    LOOP
      entry:= SuperLPeek (vector);
      IF (entry = 0) OR (entry = lastentry) THEN RETURN FALSE END;
      SuperPeek (entry - entryOffs, c);
      IF equal (c.magic, Magic) THEN
        (* XBRA-Kennung gefunden *)
        IF equal (c.name, name) THEN
          (* Ende, da Name gefunden *)
          at:= vector;
          RETURN TRUE
        ELSE
          (* VorgÑnger prÅfen *)
          vector:= entry - 4L;
          lastentry:= entry
        END
      ELSE
        (* Ende, da XBRA-Kette zuende *)
        RETURN FALSE
      END;
    END;
  END Installed;

PROCEDURE Install (entry: ADDRESS; at: ADDRESS);
  VAR pc: POINTER TO Carrier;
  BEGIN
    IF (entry = NIL) OR (at = NIL) THEN
      HALT
    ELSE
      pc:= entry - entryOffs;
      pc^.prev:= SuperLPeek (at);
      SuperLPoke (at, entry)
    END
  END Install;

PROCEDURE Remove (at: ADDRESS);
  VAR entry: ADDRESS; c: Carrier;
  BEGIN
    IF at = NIL THEN
      HALT
    ELSE
      entry:= SuperLPeek (at);
      IF entry = NIL THEN
        HALT
      ELSE
        SuperPeek (entry - entryOffs, c);
        IF equal (c.magic, Magic) THEN
          SuperLPoke (at, c.prev)
        ELSE
          HALT
        END
      END
    END
  END Remove;

PROCEDURE Query (vector: ADDRESS; with: QueryProc);
  VAR lastentry, entry: ADDRESS; c: Carrier; dummy: BOOLEAN;
  BEGIN
    lastentry:= 0;
    LOOP
      entry:= SuperLPeek (vector);
      IF (entry = 0) OR (entry = lastentry) THEN RETURN END;
      SuperPeek (entry - entryOffs, c);
      IF NOT equal (c.magic, Magic) THEN
        EXIT
      END;
      IF NOT with (vector, c.name) THEN RETURN END;
      (* VorgÑnger ist dran *)
      vector:= entry - 4L;
      lastentry:= entry
    END;
    dummy:= with (vector, '????')
  END Query;

PROCEDURE Entry (at: ADDRESS): ADDRESS;
  BEGIN
    RETURN SuperLPeek (at);
  END Entry;

PROCEDURE Called (at: ADDRESS): ADDRESS;
  VAR entry: ADDRESS; c: Carrier;
  BEGIN
    entry:= SuperLPeek (at);
    IF entry # NIL THEN
      SuperPeek (entry - entryOffs, c);
      IF equal (c.magic, Magic) THEN
        IF c.entry.jmpInstr = JmpInstr THEN
          (* Wenn dies eine vom XBRA-Modul erzeugte Struktur ist, dann lie- *)
          (* fern wir die Code-Adresse, die bei 'Install' angegeben wurde.  *)
          RETURN c.entry.operand
        END
      END;
      (* Ansonsten wird einfach die direkte Einsprungadr. geliefert *)
      RETURN entry
    END;
    RETURN NIL
  END Called;

PROCEDURE PreviousEntry (entry0: ADDRESS): ADDRESS;
  VAR pc: POINTER TO Carrier;
  BEGIN
    IF entry0 # NIL THEN
      pc:= entry0 - entryOffs;
      WITH pc^ DO
        IF equal (magic, Magic) AND (prev # entry0) THEN
          RETURN prev
        END
      END
    END;
    RETURN NIL
  END PreviousEntry;

END XBRA.
