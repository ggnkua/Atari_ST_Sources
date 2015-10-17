
IMPLEMENTATION MODULE RandomGen;        (*$ c- *)
(*$R-,S-,Y+*)

(* Zufallszahlengenerator
   (Knuth, Art of Computer Programming Vol.2, 2nd Ed., pp.16/102)

   jm 15.6.87
   
   tt 25.9.88: RandomCard (x,MaxCard) ergibt keinen šberlauf mehr.
   tt 14.3.90: RandomCard berechnet nun direkt aus Rnd() mit Int-Arithm.
               statt ber Random() mit Reals.
   tt 20.5.91: Rnd() zerst”rt nicht mehr D3
*)

FROM SYSTEM IMPORT ASSEMBLER, CompilerVersion;

CONST  a = 1664525;     (* Knuth S.102 Zeile 26 *)
       c = 117;         (* teilerfremd mit 2^32 fr max. Periode 2^32 *)
  maxRnd = 4294967296.; (* 2^32 fr Normierung auf [0..1) *)

VAR    x: LONGCARD;     (* letzte erzeugte Zufallszahl *)

(*$ l- *)
PROCEDURE Randomize (seed: LONGCARD);
  BEGIN
    ASSEMBLER
      move.l    -(a3),d0
      beq       rnd2
      move.l    d0,x
      rts
    rnd2
      move      #17,-(a7)
      trap      #14
      eor.l     d0,x
      trap      #14
      addq.l    #2,a7
      lsl.l     #8,d0
      eor.l     d0,x
    END
  END Randomize;
  
(*$ l- *)
PROCEDURE Rnd (): LONGCARD;
  BEGIN
    ASSEMBLER
      
      ; berechne a * x: drei Teilprodukte bilden
      ; (x.high * a.high brauchen wir nicht, f„llt dem MOD zum Opfer)
      
      move.l    x,d0    ;x.low
      move.l    d0,d1   ;x.low
      move.l    d0,d2
      swap      d2      ;x.high
      move.l    d3,-(a7)
      move.l    #a,d3
      mulu      d3,d0   ;al * xl
      mulu      d3,d2   ;al * xh
      swap      d3
      mulu      d3,d1   ;ah * xl
      move.l    (a7)+,d3
      
      ; Teilprodukte aufaddieren
      
      swap      d1
      clr.w     d1
      swap      d2
      clr.w     d2
      add.l     d1,d0
      add.l     d2,d0
      
      ; nun noch c addieren und Ergebnis abliefern
      
      addi.l    #c,d0
      move.l    d0,x
      move.l    d0,(A3)+
    END
  END Rnd;
  
(*$ l+ *)
PROCEDURE Random (): LONGREAL;
  BEGIN
    (*$? CompilerVersion = 3: RETURN float (Rnd()) / maxRnd *)
    (*$? CompilerVersion > 3: RETURN Lfloat (Rnd()) / maxRnd *)
  END Random;

(*$ l+ *)
PROCEDURE RandomCard (min, max: CARDINAL): CARDINAL;
  (* liefert Pseudo-Zufallszahl  min <= RandomCard () <= max *)
  VAR siz: LONGCARD;
  BEGIN
    ASSEMBLER
        MOVEQ   #0,D0
        MOVEQ   #0,D1
        MOVE    max(A6),D0
        ADDQ.L  #1,D0
        MOVE    min(A6),D1
        SUB.L   D1,D0
        MOVE.L  D0,siz(A6)
    END;
    RETURN (* min + SHORT (LONGCARD (TRUNC (Random () * Lfloat (siz)))) *)
           min + SHORT (Rnd () MOD siz)
  END RandomCard;

BEGIN
  Randomize (0L)
END RandomGen.

(* $FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$00000341$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082$FFF8B082€$00000636T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000581$00000646$00000636$0000063E$00000357$FFEDF490$0000040B$FFEDF490$000003C8$0000037A$00000101$000001A4$00000184$FFF16614$000001A2$00000593€€*)
