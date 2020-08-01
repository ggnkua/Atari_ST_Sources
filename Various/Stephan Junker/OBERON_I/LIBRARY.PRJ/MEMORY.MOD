MODULE Memory; (* SJ 19.10.94 *)


IMPORT
  SYSTEM;


(*$-c no compiler code *)

PROCEDURE Copy*(src, dest: SYSTEM.PTR; length: LONGINT);
(*
 Copies memory at src with length length to dest. Minimum speed is
 necessary if src or dest is odd and the other isn't. Otherwise
 copying is done with about 1 MByte per second on an ST.
 *)
 BEGIN
  ASSEMBLER

                TST.L   4(SP)
                BLE     exit

                MOVE.B  15(SP),D0
                MOVE.B  11(SP),D1
                EOR.B   D1,D0

                MOVE.L  8(SP),D2        ; Wenn Dest
                CMP.L   12(SP),D2       ; < Source
                BLO     CopyDown        ; ->

                BTST    #0,D0
                BEQ     CopyEvenUp

CopyBytesUp:    MOVE.L  4(SP),D0        ; Size
                MOVEA.L 12(SP),A0       ; Source
                MOVEA.L D2,A1           ; Dest
                ADDA.L  D0,A0           ; Ende Source
                ADDA.L  D0,A1           ; Ende Dest

L000D:          MOVE.B  -(A0),-(A1)
                SUBQ.L  #1,D0
                BNE     L000D

                RTS

CopyEvenUp:     MOVE.L  A6,-(SP)

                MOVEA.L 16(SP),A4       ; Source-Adresse
                MOVEA.L D2,A5           ; Dest-Adresse
                MOVEA.L 8(SP),A6        ; Size
                ADDA.L  A6,A4           ; Ende Source
                ADDA.L  A6,A5           ; Ende Dest
                MOVE.W  A5,D0
                BTST    #0,D0           ; Adresse ungerade ?
                BEQ     L0003           ; nein ->

                MOVE.B  -(A4),-(A5)
                SUBQ.L  #1,A6

L0003:          CMPA.W  #48,A6          ; weniger als 48 Bytes ?
                BLO     L0004           ; ja ->

                LEA     -48(A4),A4      ; Source-Ad kleiner
                MOVEM.L (A4),D0-A3      ; lesen
                MOVEM.L D0-A3,-(A5)     ; schreiben
                LEA     -48(A6),A6      ; Size kleiner
                BRA     L0003

L0004:          MOVE.W  A6,D0
                LSR.W   #2,D0
                BEQ     L0005

                SUBQ.W  #1,D0

L0004a:         MOVE.L  -(A4),-(A5)
                DBRA    D0,L0004a

L0005:          MOVE.W  A6,D0
                AND.W   #3,D0
                BEQ     L0006

                SUBQ.W  #1,D0

L0005a:         MOVE.B  -(A4),-(A5)
                DBRA    D0,L0005a

L0006:          MOVEA.L (SP)+,A6
                RTS

CopyDown:       BTST    #0,D0
                BEQ     CopyEvenDown

CopyBytesDown:  MOVE.L  4(SP),D0        ; Size
                MOVEA.L 12(SP),A0       ; Source
                MOVEA.L D2,A1           ; Dest

L0010:          MOVE.B  (A0)+,(A1)+
                SUBQ.L  #1,D0
                BNE     L0010

                RTS

CopyEvenDown:   MOVE.L  A6,-(SP)

                MOVEA.L 16(SP),A4       ; Source-Adresse
                MOVEA.L D2,A5           ; Dest-Adresse
                MOVEA.L 8(SP),A6        ; Size
                MOVE.W  A5,D0
                BTST    #0,D0           ; Adresse ungerade ?
                BEQ     L0008           ; nein ->

                MOVE.B  (A4)+,(A5)+
                SUBQ.L  #1,A6

L0008:          CMPA.W  #48,A6          ; weniger als 48 Bytes ?
                BLO     L0009           ; ja ->

                MOVEM.L (A4)+,D0-A3     ; lesen
                MOVEM.L D0-A3,(A5)      ; schreiben
                LEA     48(A5),A5       ; Dest-Ad gr”žer
                LEA     -48(A6),A6      ; Size kleiner
                BRA     L0008

L0009:          MOVE.W  A6,D0
                LSR.W   #2,D0
                BEQ     L000A

                SUBQ.W  #1,D0

L0009a:         MOVE.L  (A4)+,(A5)+
                DBRA    D0,L0009a

L000A:          MOVE.W  A6,D0
                AND.W   #3,D0
                BEQ     L000B

                SUBQ.W  #1,D0

L000Aa:         MOVE.B  (A4)+,(A5)+
                DBRA    D0,L000Aa

L000B:          MOVEA.L (SP)+,A6

exit:           RTS

  END;
 END Copy;


PROCEDURE Fill* ( dest : SYSTEM.PTR; length, filler : LONGINT );
(*
 fills memory at dest with length length with filler. Speed is about
 1MByte per second. If bytes should be filled, repeat the byte four
 times in filler (for example 20202020H for spaces).
 *)
 BEGIN
  ASSEMBLER

                MOVE.L  A6,-(SP)

                MOVE.L  8(SP),D0
                MOVE.L  D0,D1
                MOVE.L  D0,D2
                MOVE.L  D0,D3
                MOVE.L  D0,D4
                MOVE.L  D0,D5
                MOVE.L  D0,D6
                MOVE.L  D0,D7
                MOVEA.L D0,A0
                MOVEA.L D0,A1
                MOVEA.L D0,A2
                MOVEA.L D0,A3

                MOVEA.L 16(SP),A5       ; Adresse
                MOVEA.L 12(SP),A6       ; Size
                ADDA.L  A6,A5           ; Endad
                MOVE.L  A5,16(SP)
                BTST    #0,19(SP)       ; Endad ungerade ?
                BEQ     L0025           ; nein ->

                SUBQ.L  #1,A6
                MOVE.B  D0,-(A5)

L0025:          CMPA.W  #48,A6
                BLO     L0026

                MOVEM.L D0-A3,-(A5)
                LEA     -48(A6),A6
                BRA     L0025

L0026:          MOVE.W  A6,D0
                LSR.W   #2,D0
                BEQ     L0027

                SUBQ.W  #1,D0

L0026a:         MOVE.L  D1,-(A5)
                DBRA    D0,L0026a

L0027:          MOVE.W  A6,D0
                AND.W   #3,D0
                BEQ     L0028

                SUBQ.W  #1,D0

L0027a:         MOVE.B  D1,-(A5)
                DBRA    D0,L0027a

L0028:          MOVEA.L (SP)+,A6
                RTS

  END;
 END Fill;

(*$+c *)

PROCEDURE Compare*(src, dest : SYSTEM.PTR; length : LONGINT) : BOOLEAN;
(*
 Compares memory byte by byte starting at src with length length with
 the memory at dest. No special care for speed is taken except that it
 is written in Assembler.
 *)
 BEGIN
  ASSEMBLER

    MOVE.L  length(A6), D0
    MOVE.L  src(A6), A0
    MOVE.L  dest(A6), A1
comp:
    SUBQ.L  #1,D0
    TST.L   D0              ; Ende Bereich?
    BMI     equal           ; dann gleich

    CMPM.B   (A0)+, (A1)+
    BEQ     comp

    MOVEQ   #0,D0           ; ungleich
    UNLK    A6
    RTS

equal:
    MOVEQ   #1,D0           ; gleich

  END;
 END Compare;


END Memory.