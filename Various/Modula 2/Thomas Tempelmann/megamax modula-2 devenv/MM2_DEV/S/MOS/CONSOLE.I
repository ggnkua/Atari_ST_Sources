IMPLEMENTATION MODULE Console;

(*$Y+,L-,N+*)

FROM SYSTEM IMPORT ASSEMBLER;

(*
 * Ausgaben Åber GEMDOS.Write mit Handle = 1, Eingaben mit Handle = 0
 * Negative Handles lassen sich offenbar nicht umleiten!
 *)


PROCEDURE Write (ch: CHAR);
  BEGIN
    ASSEMBLER
        SUBQ.L  #2,A3
        MOVE.L  A3,-(A7)
        MOVE.L  #1,-(A7)
        MOVE.L  #$00400001,-(A7)
        TRAP    #1
        ADDA.W  #12,A7
    END
  END Write;

PROCEDURE WriteString (REF str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),A0
        
        ; Length (str) bestimmen
        MOVE.L  A0,D0
l       TST.B   (A0)+
        DBEQ    D1,l
        BNE     c
        SUBQ.L  #1,A0
c       SUBA.L  D0,A0

        MOVE.L  D0,-(A7)
        MOVE.L  A0,-(A7)
        MOVE.L  #$00400001,-(A7)
        TRAP    #1
        ADDA.W  #12,A7
    END
  END WriteString;

PROCEDURE WriteLn;
  BEGIN
    Write (15C);
    Write (12C);
  END WriteLn;

PROCEDURE Read (VAR ch: CHAR);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  #1,-(A7)
        MOVE.L  #$003F0001,-(A7)
        TRAP    #1
        ADDA.W  #12,A7
    END
  END Read;

PROCEDURE ReadLine (VAR str: ARRAY OF CHAR);
  BEGIN
    ASSEMBLER
        MOVEQ   #0,D0
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),-(A7)
        ADDQ.L  #1,D0
        MOVE.L  D0,-(A7)
        MOVE.L  #$003F0001,-(A7)
        TRAP    #1
        ADDQ.L  #4,A7
        MOVE.L  (A7)+,D1
        MOVE.L  (A7)+,A0
        TST.L   D0
        BMI     error
        
        ; nun kann Zeile auch ohne Return-Taste beendet worden sein.
        ; Das ist der Fall, wenn der String voll ist.
        ; In diesem Fall wird dann auf Return noch gewartet.
        ; Jede andere Taste wird mit einem Bing (CHR (7)), und zwar IMMER
        ; an die Console ohne Umleitung, bestÑtigt
        CMP.L   D1,D0
        BCS     ok
        
        SUBQ.L  #2,A7

      wait
        MOVE.L  A7,-(A7)
        MOVE.L  #1,-(A7)
        MOVE.L  #$003F0001,-(A7)
        TRAP    #1
        ADDA.W  #12,A7
        TST.L   D0
        BEQ     wait
        BMI     ende
        CMPI.B  #13,(A7)
        BEQ     ende
        
        MOVE.B  #7,(A7)
        MOVE.L  A7,-(A7)
        MOVE.L  #1,-(A7)
        MOVE.L  #$0040FFFF,-(A7)
        TRAP    #1
        ADDA.W  #12,A7
        BRA     wait
        
      ende
        ADDQ.L  #2,A7
        RTS
        
      ok
        CLR.B   0(A0,D0.W)
        RTS
        
      error
        CLR.B   (A0)
    END
  END ReadLine;

PROCEDURE BusyRead (VAR c: CHAR);
  BEGIN
    ASSEMBLER
        MOVE    #$FF,-(A7)
        MOVE    #6,-(A7)
        TRAP    #1
        ADDQ.L  #4,A7
        MOVE.L  -(A3),A0
        MOVE.B  D0,(A0)
    END
  END BusyRead;

PROCEDURE KeyPressed (): BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVE    #$B,-(A7)
        TRAP    #1
        ADDQ.L  #2,A7
        TST     D0
        SNE     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END KeyPressed;

VAR c: CHAR; (* muû global sein wg. $L- *)

PROCEDURE FlushKbd;
  BEGIN
    WHILE KeyPressed () DO
      BusyRead (c)
    END;
  END FlushKbd;

END Console.
