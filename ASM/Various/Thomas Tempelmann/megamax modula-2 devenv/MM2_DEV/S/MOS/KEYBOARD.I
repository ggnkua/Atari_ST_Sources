IMPLEMENTATION MODULE Keyboard;
(*$Y+,C-,L-,N+*)

(*
  TT 30.08.89  wdLeft/Right mit soln/eoln vertauscht
  TT 26.05.90  GemCharToKey korrigiert: ctrl wird nun richtig (?) gesetzt
*)

FROM SYSTEM IMPORT ASSEMBLER;
FROM SYSTEM IMPORT BYTE, LONGWORD, WORD, ADDRESS;

FROM MOSGlobals IMPORT Key;



PROCEDURE GemCharToKey (gemChar: WORD; specialKeySet: BYTE; VAR k: Key);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        SUBQ.L  #1,A3
        MOVE.B  -(A3),D1        ; D1: ctrl
        MOVEQ   #0,D0
        MOVE.W  -(A3),D0        ; |   0|   0|scan|  ch|
        ROR.L   #8,D0           ; |  ch|   0|   0|scan|
        SWAP    D0              ; |   0|scan|  ch|   0|
        MOVE.B  D1,D0           ; |   0|scan|  ch|ctrl|
        LSR.B   #1,D0
        BCC     n
        BSET    #0,D0
     n: ANDI.B  #1111%,D0
        SWAP    D0
        MOVE.L  D0,(A0)         ; |  ch|ctrl|   0|scan|
    END
  END GemCharToKey;

PROCEDURE KeyToGemChar (k: Key; VAR gemChar: WORD; VAR specialKeySet: BYTE);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A1
        MOVE.L  -(A3),A0
        MOVE.L  -(A3),D0        ; |  ch|ctrl|   0|scan|
        SWAP    D0              ; |   0|scan|  ch|ctrl|
        LSL.B   #1,D0
        MOVE.B  D0,(A1)
        LSR.L   #8,D0           ; |   0|   0|scan|  ch|
        MOVE.W  D0,(A0)
    END
  END KeyToGemChar;

PROCEDURE LongToKey (l: LONGWORD; VAR k: Key);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  -(A3),D0        ; |ctrl|scan|   0|  ch|
        ROR.L   #8,D0
        SWAP    D0
        LSR.B   #1,D0
        BCC     n
        BSET    #0,D0
     n: ANDI.B  #1111%,D0
        SWAP    D0
        LSR.W   #8,D0
        MOVE.L  D0,(A0)         ; |  ch|ctrl|   0|scan|
    END
  END LongToKey;

PROCEDURE KeyToLong (k: Key; VAR l: LONGWORD);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  -(A3),D0        ; |  ch|ctrl|   0|scan|
        LSL.W   #8,D0           ; |  ch|ctrl|scan|   0|
        SWAP    D0
        LSL.B   #1,D0
        SWAP    D0
        ROL.L   #8,D0
        MOVE.L  D0,(A0)         ; |ctrl|scan|   0|  ch|
    END
  END KeyToLong;


VAR keyTable: ADDRESS;

TABLE.B

  CapTbl: (* Alphablock *)
          0,escCap,0,0,0,0,0,0,0,0,0,0,0,0,backspaceCap,
          tabCap,0,0,0,0,0,0,0,0,0,0,0,0,returnCap,
          0,0,0,0,0,0,0,0,0,0,0,0,0,  (* Control..'~' *)
          0,0,0,0,0,0,0,0,0,0,0,0,0,  (* Shift..Shift *)
          0, (* print screen *)
          0,0,0, (* Alternate; Space; Caps *)
          f1Cap,f2Cap,f3Cap,f4Cap,f5Cap,f6Cap,f7Cap,f8Cap,f9Cap,f10Cap,
          0,0,clrHomeCap,upCap,0,0,leftCap,0,rightCap,0,0,downCap,
          0,insertCap,deleteCap,
          f1Cap,f2Cap,f3Cap,f4Cap,f5Cap,f6Cap,f7Cap,f8Cap,f9Cap,f10Cap,
          0,0,0,undoCap,helpCap,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          enterCap,leftCap,rightCap,0,0,clrHomeCap;

PROCEDURE KeyCap (VAR k: Key): Cap;
  BEGIN
    ASSEMBLER
        CLR     D1
        MOVE.L  -(A3),A0
        MOVE.W  Key.scan(A0),D0
        CMPI    #$77,D0
        BHI     unspec
        LEA     CapTbl,A0
        MOVE.B  0(A0,D0.W),D1
unspec  MOVE    D1,(A3)+
    END
  END KeyCap;

TABLE.B

  KeyTbl: (* Alphablock *)
          0,esc,0,0,0,0,0,0,0,0,0,0,0,0,backspace,
          tab,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,return,
          0,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,  (* Control..'~' *)
          0,0,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,  (* Shift..Shift *)
          0, (* print screen *)
          0,0,0, (* Alternate; Space; Caps *)
          f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,
          0,0,-1(*home*),-1(*up*),pgUp,0,-1(*left*),0,-1(*right*),
          0,0,-1(*down*),
          pgDown,-1,-1,
          f11,f12,f13,f14,f15,f16,f17,f18,f19,f20,
          0,0,0,undo,help,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          enter,wdLeft,wdRight,0,pgDown,home,
          alt1, alt2, alt3, alt4, alt5, alt6, alt7, alt8, alt9, alt0,
          0,0,pgUp;

  CrsrTbl: home, clr, up, pgUp, left, soln, right, eoln, down, pgDown,
           insert, insLine, delete, delLine;

PROCEDURE SpecialKey (VAR k: Key): SpecialCode;
  BEGIN
    ASSEMBLER
        CLR     D1
        MOVE.L  -(A3),A0
        MOVE.W  Key.scan(A0),D0
        MOVE.B  Key.ch(A0),D2
        CMPI    #$84,D0
        BHI     ok
        LEA     KeyTbl,A1
        MOVE.B  0(A1,D0.W),D1
        BPL     ok
        CLR     D1
        ; Sonderbehandlung
        LEA     CrsrTbl,A1
        CMPI    #$47,D0         ; home ?
        BEQ     x
        ADDQ.L  #2,A1
        CMPI    #$48,D0         ; up ?
        BEQ     x
        ADDQ.L  #2,A1
        CMPI    #$4B,D0         ; left ?
        BEQ     x
        ADDQ.L  #2,A1
        CMPI    #$4D,D0         ; right ?
        BEQ     x
        ADDQ.L  #2,A1
        CMPI    #$50,D0         ; down ?
        BEQ     x
        ADDQ.L  #2,A1
        CMPI    #$52,D0         ; insert ?
        BEQ     x
        ADDQ.L  #2,A1
        CMPI    #$53,D0         ; delete ?
        BEQ     y
        ; Es ist ein Buchstabe
        TST.B   D2              ; Alternate-Kombination ?
        BEQ     altCh
        CMPI.B  #' ',D2         ; Ist es ein Ctrl-Zeichen ?
        BCC     ok
        MOVE.B  D2,D1
        ADDI    #ctrlA-1,D1
        BRA     ok
y       CMPI.B  #$7F,D2
        BRA     z
x       TST.B   D2
z       BNE     second
        MOVE.B  (A1),D1
        BRA     ok
altCh   MOVE.L  keyTable,A1
        MOVE.B  0(A1,D0.W),D1   ; Buchstabenwert holen (ungeshiftet)
        ADDI    #altA-$61,D1
        BRA     ok
second  MOVE.B  1(A1),D1
ok      MOVE    D1,(A3)+
    END
  END SpecialKey;

PROCEDURE IsSpecial (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        JSR     SpecialKey
        TST     -(A3)
        SNE     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END IsSpecial;

PROCEDURE IsCharacter (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        ; true, wenn Ctrl-2 (NUL) oder ch # 0C und keine Cursortaste.
        MOVE.L  -(A3),A0
        MOVE    Key.scan(A0),D0
        TST.B   Key.ch(A0)
        BNE     ch
        CMPI    #3,D0   ; Ctrl-2
        BEQ     yes
        CMPI    #$6E,D0 ; Ctrl-2 auf Ziffernblock
        BEQ     yes
        CMPI    #$39,D0 ; Ctrl-SPACE
        BEQ     yes
no:     CLR     (A3)+
        RTS
ch:     CMPI    #$4A,D0 ; + auf Ziffernblock
        BEQ     yes
        CMPI    #$4E,D0 ; - auf Ziffernblock
        BEQ     yes
        CMPI    #$53,D0 ; Delete
        BEQ     yes
        CMPI    #$45,D0
        BCS     yes
        CMPI    #$54,D0
        BCS     no
yes:    MOVE    #1,(A3)+
    END
  END IsCharacter;

PROCEDURE IsASCII (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        JMP     IsCharacter
    END
  END IsASCII;

PROCEDURE IsCursor (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE    Key.scan(A0),D0
        CMPI    #$73,D0
        BEQ     yes
        CMPI    #$74,D0
        BEQ     yes
        CMPI    #$4D,D0
        BEQ     yes
        CMPI    #$4B,D0
        BEQ     yes
        CMPI    #$48,D0
        BEQ     yes
        CMPI    #$50,D0
        BEQ     yes
        CLR     (A3)+
        RTS
yes:    MOVE    #1,(A3)+
    END
  END IsCursor;

PROCEDURE IsAlternate (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        TST.B   Key.ch(A0)
        BNE     no
        MOVE    Key.scan(A0),D0
        ; Alt1-Alt0 ?
        CMPI    #$82,D0
        BCC     no
        CMPI    #$78,D0
        BCC     yes
        ; Y-M ?
        CMPI    #$32,D0
        BCC     no
        CMPI    #$2C,D0
        BCC     yes
        ; A-L ?
        CMPI    #$27,D0
        BCC     no
        CMPI    #$1E,D0
        BCC     yes
        ; Q-P ?
        CMPI    #$1A,D0
        BCC     no
        CMPI    #$10,D0
        BCC     yes
no:     CLR     (A3)+
        RTS
yes:    MOVE    #1,(A3)+
    END
  END IsAlternate;

PROCEDURE IsFunction (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE    Key.scan(A0),D0
        ; F11-F20 ?
        CMPI    #$5E,D0
        BCC     no
        CMPI    #$54,D0
        BCC     yes
        ; F1-F10 ?
        CMPI    #$45,D0
        BCC     no
        CMPI    #$3B,D0
        BCC     yes
no:     CLR     (A3)+
        RTS
yes:    MOVE    #1,(A3)+
    END
  END IsFunction;

PROCEDURE OnNumBlock (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE    Key.scan(A0),D0
        CMPI    #$4A,D0
        BEQ     yes
        CMPI    #$4E,D0
        BEQ     yes
        CMPI    #$72,D0
        BHI     no
        CMPI    #$63,D0
        BCC     yes
no:     CLR     (A3)+
        RTS
yes:    MOVE    #1,(A3)+
    END
  END OnNumBlock;

PROCEDURE OnAlphaBlock (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE    Key.scan(A0),D0
        BEQ     no
        CMPI    #$53,D0         ; delete ?
        BEQ     yes
        CMPI    #$60,D0         ; < / >
        BEQ     yes
        CMPI    #$84,D0         ; alt-# +1
        BCC     no
        CMPI    #$78,D0         ; alt-1
        BCC     yes
        CMPI    #$3A,D0
        BLS     yes
no:     CLR     (A3)+
        RTS
yes:    MOVE    #1,(A3)+
    END
  END OnAlphaBlock;

PROCEDURE OnCursorBlock (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        JSR     IsCursor
        TST     -2(A3)
        BNE     ok
        CMPI    #$47,D0         ; home
        BEQ     yes
        CMPI    #$77,D0         ; ctrl-home
        BEQ     yes
        CMPI    #$52,D0         ; insert
        BEQ     yes
        CMPI    #$61,D0         ; help
        BEQ     yes
        CMPI    #$62,D0         ; undo
        BNE     ok
yes     MOVE    #1,-2(A3)
ok
    END
  END OnCursorBlock;

PROCEDURE OnFunctionBlock (VAR k: Key): BOOLEAN;
  BEGIN
    ASSEMBLER
        JMP     IsFunction
    END
  END OnFunctionBlock;


BEGIN
  ASSEMBLER
        ; Key-Tabelle ermitteln
        MOVEQ   #-1,D0
        MOVE.L  D0,-(A7)
        MOVE.L  D0,-(A7)
        MOVE.L  D0,-(A7)
        MOVE    #16,-(A7)
        TRAP    #14
        ADDA.W  #14,A7
        MOVE.L  D0,A0
        MOVE.L  (A0),keyTable
  END
END Keyboard.
 
(* $FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$00000158$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877$FFF6B877€$000001F4T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFEE2C3C$FFEE2C3C$0000002A$000007FB$00000826$00000622$00000108$00000026$000000DF$00000306$00000071$0000007C$000000B8$000001F4$000002CD$00000306Œ€€*)
