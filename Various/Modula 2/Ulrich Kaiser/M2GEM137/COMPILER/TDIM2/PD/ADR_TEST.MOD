MODULE AdrTest;  (* Demo des Compiler-Bugs bzgl. Stacking von VALUE-Arrays.*)
(* ½ 1994 ROLF SCHRADER. * 8.2.94 *)

FROM SYSTEM IMPORT ADR;
(* IMPORT VT, VZ; *)
(* IMPORT ErrTraps, GEMError, ErrAl; *)

TYPE GR = RECORD x,y,w,h: INTEGER END;
     RP = POINTER TO GR;
VAR  Msg: ARRAY [0..7] OF INTEGER;
     Rec: ARRAY [0..3] OF RECORD i: INTEGER; P: RP END;
     k:   CARDINAL;

PROCEDURE test (msg: ARRAY OF INTEGER);
 VAR   o: GR;   p: RP;
 BEGIN k := 3;  p := ADR (msg[4]);
   WITH Rec[k] DO i := 7;
    WITH  p^ DO   h := 1111H;
     WITH P^ DO (* VT.Home; VZ.wHexL (ADR(x), 10); *)
       IF (o.w = w) & (o.h = h) THEN END END END END; END test;

BEGIN Rec[3].P := ADR (Msg[4]); test (Msg) END AdrTest.


DisAssembling:

proc 1:
     0H        700C                     MOVEQ   #0CH,D0
     2H        4EB9 0000 0000           JSR     00000000H
     8H        4E56 FFF4                LINK    A6,#FFF4H ;     12 B. reserv.

     CH        3A2E 000C                MOVE.W  000C(A6),D5
    10H        4BBC 7FFF                CHK     #7FFFH,D5
    14H        5245                     ADDQ.W  #1,D5
    16H        DA45                     ADD.W   D5,D5
    18H        4E76                     TRAPV
    1AH        48C5                     EXT.L   D5 ;            |msg| = 16
    1CH        0C85 0000 7FFF           CMPI.L  #00007FFFH,D5
    22H        6304                     BLS     [04H] = 00000028H
    24H        41BC FFFF                CHK     #FFFFH,D0
    28H        D085                     ADD.L   D5,D0
    2AH        4EB9 0000 0000           JSR     00000000H

    30H        9FC5                     SUBA.L  D5,A7 ;               !
    32H        286E 0008                MOVE.L  0008(A6),A4
    36H        2D4F 0008                MOVE.L  A7,0008(A6)
    3AH        264F                     MOVE.L  A7,A3
    3CH        5345                     SUBQ.W  #1,D5
    3EH        16DC                     MOVE.B  (A4)+,(A3)+
    40H        51CD FFFC                DBRA    D5,[FFFCH] = 0000003EH

    44H        33FC 0003 0000 0028      MOVE.W  #0003H,00000028H

    4CH        7A04                     MOVEQ   #04H,D5
    4EH        4BAE 000C                CHK     000C(A6),D5
    52H        286E 0008                MOVE.L  0008(A6),A4
    56H        49EC 0008                LEA     0008(A4),A4
    5AH        2A0C                     MOVE.L  A4,D5
    5CH        2D45 FFF4                MOVE.L  D5,FFF4(A6)

    60H        3A39 0000 0028           MOVE.W  00000028H,D5
    66H        4BBC 0003                CHK     #0003H,D5
    6AH        CAFC 0006                MULU    #0006H,D5
    6EH        49F9 0000 0010           LEA     00000010H,A4
    74H        49F4 5000                LEA     00H(A4,D5.W),A4

    78H        38BC 0007                MOVE.W  #0007H,(A4)

    7CH        266E FFF4                MOVE.L  FFF4(A6),A3
    80H        377C 1111 0006           MOVE.W  #1111H,0006(A3)

    86H        246C 0002                MOVE.L  0002(A4),A2 ;  P
    8AH        4852                     PEA     (A2) ;         A7 ~ FFE0(A6)

 >  8CH        246E FFF0                MOVE.L  FFF0(A6),A2 ;  msg[6] statt P
    90H        3A2E FFFC                MOVE.W  FFFC(A6),D5
 -  94H        BA6A 0004                CMP.W   0004(A2),D5 ;  odd adr error
    98H        660E                     BNE     [0EH] = 000000A8H

    9AH        246E FFF0                MOVE.L  FFF0(A6),A2
    9EH        3A2E FFFE                MOVE.W  FFFE(A6),D5
    A2H        BA6A 0006                CMP.W   0006(A2),D5
    A6H        4E71                     NOP

    A8H        588F                     ADDQ.L  #4,A7

    AAH        4E5E                     UNLK    A6
    ACH        4E75                     RTS

