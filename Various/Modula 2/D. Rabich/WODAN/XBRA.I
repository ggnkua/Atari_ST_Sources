IMPLEMENTATION MODULE XBRA;

(*
  18.06.89 Thomas Tempelmann: Megamax-Version
*)

FROM SYSTEM IMPORT ADR, VAL, ADDRESS, BYTE;

IMPORT XBIOS;

FROM SysUtil1 IMPORT SuperPeek, SuperLPeek, SuperLPoke;

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

    IMPORT ADR, VAL, ADDRESS, BYTE;
    FROM XBIOS IMPORT SuperExec;

    EXPORT SuperPeek, SuperLPeek, SuperLPoke;

    VAR from, to: POINTER TO BYTE; bytes: CARDINAL;

    PROCEDURE set;
      BEGIN
        WHILE bytes > 0 DO
          to^:= from^;
          to:= ADDRESS (to) + VAL (LONGCARD, 1);
          from:= ADDRESS (from) + VAL (LONGCARD, 1);
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

      entryOffs = 12; (* Differenz zw. 'Carrier.magic' und 'Carrier.entry' *)

 (*
  * Hilfsfunktionen, die ggf. optimiert werden kînnen
  * -------------------------------------------------
  *)

PROCEDURE equal (s1, s2: ID): BOOLEAN;
  VAR p1, p2: POINTER TO LONGCARD (* ein 4-Byte-Datentyp *);
  BEGIN
    p1:= ADR (s1);
    p2:= ADR (s2);
    RETURN p1^ = p2^
  END equal;

PROCEDURE sub (p: ADDRESS; n: CARDINAL): ADDRESS;
  BEGIN
    RETURN p - VAL (LONGCARD, n)
  END sub;

 (*
  * Exportierte Funktionen
  * ----------------------
  *)

PROCEDURE Create (VAR use: Carrier; name: ID; call: ADDRESS;
                  VAR entry: ADDRESS);
  BEGIN
    use.name:= name;
    use.magic:= Magic;
    use.prev:= NIL;
    use.entry.jmpInstr:= JmpInstr; (* Code fÅr 'JMP <adr>.L' *)
    use.entry.operand:= call;
    entry:= ADR (use.entry)
  END Create;

PROCEDURE Installed (name: ID; vector: ADDRESS; VAR at: ADDRESS): BOOLEAN;
  VAR pc: POINTER TO Carrier; entry: ADDRESS; c: Carrier;
  BEGIN
    at:= vector; (* Vorwahl fÅr RETURN FALSE *)
    LOOP
      entry:= SuperLPeek (vector);
      IF entry = NIL THEN RETURN FALSE END;
      pc:= sub (entry, entryOffs);
      SuperPeek (pc, c);
      IF equal (c.magic, Magic) THEN
        (* XBRA-Kennung gefunden *)
        IF equal (c.name, name) THEN
          (* Ende, da Name gefunden *)
          at:= vector;
          RETURN TRUE
        ELSE
          (* VorgÑnger prÅfen *)
          vector:= sub (entry, 4)
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
      pc:= sub (entry, entryOffs);
      pc^.prev:= SuperLPeek (at);
      SuperLPoke (at, entry)
    END
  END Install;

PROCEDURE Remove (at: ADDRESS);
  VAR pc: POINTER TO Carrier; entry: ADDRESS; c: Carrier;
  BEGIN
    IF at = NIL THEN
      HALT
    ELSE
      entry:= SuperLPeek (at);
      IF entry = NIL THEN
        HALT
      ELSE
        pc:= sub (entry, entryOffs);
        SuperPeek (pc, c);
        IF equal (c.magic, Magic) THEN
          SuperLPoke (at, c.prev)
        ELSE
          HALT
        END
      END
    END
  END Remove;

PROCEDURE Query (vector: ADDRESS; with: QueryProc);
  VAR pc: POINTER TO Carrier; entry: ADDRESS; c: Carrier; dummy: BOOLEAN;
  BEGIN
    LOOP
      entry:= SuperLPeek (vector);
      IF entry = NIL THEN RETURN END;
      pc:= sub (entry, entryOffs);
      SuperPeek (pc, c);
      IF NOT equal (c.magic, Magic) THEN
        EXIT
      END;
      IF NOT with (vector, c.name) THEN RETURN END;
      (* VorgÑnger ist dran *)
      vector:= sub (entry, 4)
    END;
    dummy:= with (vector, '????')
  END Query;

PROCEDURE Entry (at: ADDRESS): ADDRESS;
  BEGIN
    RETURN SuperLPeek (at);
  END Entry;

PROCEDURE Called (at: ADDRESS): ADDRESS;
  VAR pc: POINTER TO Carrier; entry: ADDRESS; c: Carrier;
  BEGIN
    entry:= SuperLPeek (at);
    IF entry # NIL THEN
      pc:= sub (entry, entryOffs);
      SuperPeek (pc, c);
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

PROCEDURE PreviousEntry (entry: ADDRESS): ADDRESS;
  VAR pc: POINTER TO Carrier;
  BEGIN
    IF entry # NIL THEN
      pc:= sub (entry, entryOffs);
      IF equal (pc^.magic, Magic) THEN
        RETURN pc^.prev
      END;
    END;
    RETURN NIL
  END PreviousEntry;

END XBRA.
