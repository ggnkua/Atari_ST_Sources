MODULE ASMDemo; (*$ E MOS *)

  (*
   *  Dieses Modul zeigt, wie man Systemfunktionen in Assembler
   *  aufruft:
   *
   *       1. GEMDOS function call   trap #1
   *       2. BIOS calls             trap #13
   *
   *  Geschrieben von Andreas Pauletti 24.05.1988,
   *  Verifikation von Thomas Tempelmann, 05.07.1988.
   *
   *  Literaturverweis: 'ATARI ST Profibuch' 2.Auflage Sybex-Verlag
   *)

FROM SYSTEM IMPORT ASSEMBLER;

CONST
    maxChar = 35;
TYPE
    String = ARRAY[0..maxChar] OF CHAR;
VAR
    c: CHAR;
    str0, str1: String;

PROCEDURE Conout (c : CHAR);  (* BIOS routine *)
  (*
   * gibt einen einzelnen Buchstaben mittel BIOS Funktion #3 aus
   *)
  (*$L-*)
  BEGIN
    ASSEMBLER
        SUBQ.L  #1,A3         ; parameter stack korroigieren
        MOVE.B  -(A3),D0      ; auszugebender Char in D0
        MOVE    D0,-(A7)      ; D0 auf den CPU-Stack
        MOVE    #2,-(A7)      ; Ausgabe device auf STACK
        MOVE    #3,-(A7)      ; Funktionsnummer auf STACK
        TRAP    #13           ; BIOS Aufruf
        ADDQ.L  #6,A7         ; CPU Stack wieder herstellen
    END(* asm *)
  END Conout;
  (*$L=*)

PROCEDURE WriteLn;
  (*
   * spricht fr sich !
   *)
  BEGIN
    Conout(CHR(13));
    Conout(CHR(10))
  END WriteLn;


PROCEDURE PrintLine (VAR str: ARRAY OF CHAR);
  (*
   *  Gibt String str mittel GEMDOS Funktion Cconws (=#9) aus.
   *  Der String muž mit einem Null-Zeichen abgeschlossen sein!
   *)
  BEGIN
    ASSEMBLER
       MOVE.L  str(A6),-(SP)   ; Adresse von 'str' auf Stack
       MOVE.W  #9, -(SP)       ; Funktionsnummer auf STACK
       TRAP    #1              ; GEMDOS Aufruf
       ADDQ.L  #6,A7           ; CPU Stack wieder herstellen
    END
  END PrintLine;

PROCEDURE ReadString (VAR s: ARRAY OF CHAR);
  (*
   * liest einen String von der Tastatur ein und zeigt die Eingabe auf
   * dem Bildschirm laufend an.
   * (verwendet GEMDOS-Funktion 10: 'conrs')
   *)
  BEGIN
    ASSEMBLER
        ; zuerst muž in s[0] die Anzahl der max. einzulesenden Zeichen
        ; gespeichert werden. Dies sind die Anzahl der Zeichen des
        ; bergebenen Strings minus Zwei, bzw. der HIGH-Wert minus Eins:
        MOVE.L  s(A6),A0       ; Adr. des Strings
        MOVE.W  s+4(A6),D0     ; HIGH-Wert (immer 4 Byte darber)
        SUBQ    #1,D0
        MOVE.B  D0,(A0)        ; s[0] setzen
        MOVE.L  A0,-(SP)       ; Adresse von 'str' auf Stack
        MOVE.W  #$0A, -(SP)    ; Funktionsnummer auf STACK
        TRAP    #1             ; GEMDOS Aufruf
        ADDQ.L  #6,SP          ; CPU Stack wieder herstellen
    END
  END ReadString;

PROCEDURE WaitForKey (VAR ch : CHAR);
  VAR str: ARRAY[0..79] OF CHAR;
      i: CARDINAL;
  BEGIN
    FOR i:= 0 TO 9 DO
      WriteLn
    END;
    str:= '     [Space] Abbruch  ...   wiederholen beliebige Taste drcken';
    PrintLine(str);
    ASSEMBLER
        MOVE.W #8,-(SP)       ; load function #
        TRAP   #1             ; execute GEMDOS trap
        ADDQ.L #2,SP          ; adjust stack
        MOVE.L ch(A6),A0      ; move address of ch to A0
        MOVE.B D0,(A0)        ; D0 containes in the 1 byte the returned
                              ; ascii value
    END(* asm *)
  END WaitForKey;

PROCEDURE ClrScr;
  (*
   * l”scht den gesamten Bildschirm ber ESC Sequenz
   *)
  BEGIN
    ASSEMBLER
           PEA     ff(PC)       ; push address of string to the stack
           MOVE    #9,-(SP)     ; load function #
           TRAP    #1           ; execute GEMDOS trap
           ADDQ.L  #6,SP        ; adjust stack
           BRA     cont
    ff     DC.B    27,'E',13,0
    cont
    END(* asm *)
  END ClrScr;


PROCEDURE WriteLnChar (c: CHAR; k: CARDINAL; newLine: BOOLEAN);
  (*
   * Prozedur, die den Buchstaben 'c' k-mal auf den Bildschirm schreibt
   *)

  PROCEDURE ConOut (c: CHAR);  (* GEMDOS routine *)
    (*
     * gibt einen einzelnen Buchstaben mittel GEMDOS Funktion #2 aus
     *)
    (*$L-*)
    BEGIN
      ASSEMBLER
          SUBQ.L #1,A3          ; adjust parameter stack
          MOVE.B -(A3),D0       ; move c from parameter stack to D0
          MOVE.W D0,-(SP)       ; now move it to the stack
          MOVE.W #2,-(SP)       ; call GEMDOS function #2
          TRAP   #1
          ADDQ.L #4,SP          ; adjust stack
      END(* asm *)
    END ConOut;
    (*$L=*)

  VAR
     i: CARDINAL;
  BEGIN
    FOR i:= 1 TO k DO
      ConOut(c)
    END;
    IF newLine THEN
      WriteLn
    END
  END WriteLnChar;

PROCEDURE DoTitle;
  CONST
      text1 ='Demoprogramm zu MEGAMAX MODULA-2';
      text2 ='---------------------------------';
      text3 ='Eingabe und Ausgabe in Assembler';
      blanks = 23;
  VAR
      t: String;
  BEGIN
    WriteLn; WriteLn;
    WriteLnChar(' ', blanks, FALSE);
    t:= text1;
    PrintLine(t); WriteLn;
    WriteLnChar(' ', blanks, FALSE);
    t:= text2;
    PrintLine(t); WriteLn;
    WriteLn;
    WriteLnChar(' ', blanks, FALSE);
    t:= text3;
    PrintLine(t); WriteLn; WriteLn
  END DoTitle;

PROCEDURE AdjustString (VAR s: ARRAY OF CHAR);
  (*
   * Prozedur, die zur Umrechnung des Strings dient
   * InputString hat Format : s[1] enth„lt die Anzahl Buchstaben
   *                          die der String enth„lt
   *                          eigentliche Daten beginnen ab s[2]
   * OutputString normaler C-Konventions String mit null Byte am Schluss
   *)
  VAR
      i: CARDINAL;
      k: CARDINAL;
  BEGIN
    i:= 2;
    k:= ORD(s[1]);
    WHILE k > 0 DO
      s[i-2]:= s[i];
      INC(i);
      DEC(k)
    END(* while *);
    s[i-2]:= CHR(0)
  END AdjustString;


BEGIN
  REPEAT
    ClrScr;
    DoTitle;
    WriteLnChar(' ', 2, FALSE);
    WriteLnChar('-', 76, TRUE); WriteLn;
    str0:= '  Geben Sie einen String ein     : ';
    PrintLine(str0);
    ReadString(str1);
    WriteLn; WriteLn;
    WriteLnChar(' ', 2,FALSE);
    WriteLnChar('-', 76, TRUE); WriteLn;
    str0:= '  Der eingegebene String lautete : ';
    PrintLine(str0);
    AdjustString(str1);
    PrintLine(str1);
    WaitForKey(c)
  UNTIL c = ' '
END ASMDemo.
