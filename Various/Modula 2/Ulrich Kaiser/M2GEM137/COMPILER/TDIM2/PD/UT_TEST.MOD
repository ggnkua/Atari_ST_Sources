MODULE UTest;
(* ½ 1994 ROLF SCHRADER. * 3.2.94 *)
(* Demo des Compiler-Bugs bzgl. Prozedur-Parametern vom Unterbereichs-Typ. *)
(* Produziert Meldung "compiler error in assert". Compilat nicht lauff„hig.*)
 
TYPE   U1to50 = INTEGER [1..50];

PROCEDURE Test7 (In1, In2: U1to50; VAR Ex: U1to50);
 VAR   Loc: U1to50;
 BEGIN Loc := In1 + 2; Ex := In2 + Loc END Test7;

VAR   h: U1to50;
BEGIN h := 7;
      Test7 (h,h, h);
  END UTest.


Disassembling:

proc 1:

    0H  7000                MOVEQ   #00H,D0
    2H  4EB9 0000 0000      JSR     00000000H
    8H  4E56 0000           LINK    A6,#0000H ; Keine Reservierung!
 >  CH  1A2E 000C           MOVE.B  0C(A6),D5 ; Der 1. Par steht auf 0D(A6)!!
   10H  5405                ADDQ.B  #2,D5
   12H  1C85                MOVE.B  D5,(A6) ;   Loc liegt blož auf dem Stack!
   14H  1A2E 000C           MOVE.B  0C(A6),D5 ; 2. Par. korrekt geholt.
   18H  DA16                ADD.B   (A6),D5
   1AH  286E 0008           MOVE.L  08(A6),A4
   1EH  1885                MOVE.B  D5,(A4)   ; VAR Ergebnis.
   20H  4E5E                UNLK    A6
   22H  4E75                RTS

init code:

    0H  4EF9 0000 0000      JMP     00000000H
    6H  4E56 0000           LINK    A6,#0000H
    AH  33FC 0007 0000 0000 MOVE.W  #0007H,00000000H
   12H  1F39 0000 0000      MOVE.B  00000000H,-(A7) ; 1 B.
   18H  1F39 0000 0000      MOVE.B  00000000H,-(A7) ; 1 B.
   1EH  4879 0000 0000      PEA     00000000H       ; 4 B.
   24H  4EB9 0000 0000      JSR     00000000H
 > 2AH  588F                ADDQ.L  #4,A7   ; Aufm Stack liegen aber 6 Bytes!
   2CH  4E5E                UNLK    A6
   2EH  4EF9 0000 0000      JMP     00000000H
