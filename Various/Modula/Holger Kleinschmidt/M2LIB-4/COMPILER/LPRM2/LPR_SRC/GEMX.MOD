IMPLEMENTATION MODULE GEMX;

(* Rekompiliertes LPR-Originalmodul.
 *
 * 11-Nov-93, Holger Kleinschmidt
 *)

FROM SYSTEM IMPORT
(* TYPE *) VAL,
(* PROC *) ADDRESS, REG, SETREG, INLINE;

CONST
  PUSHW = 3F00H; (* move.w D0,-(SP) *)
  PUSHL = 2F00H; (* move.l D0,-(SP) *)
  TRAP1 = 4E41H; (* trap   #1 *)

  PTERM0  = 0D;
  MSHRINK = 74D;

  d0 = 0;
  sp = 15;

VAR
  start : PROC;
  (* Der Inhalt von 'start' wird vom Linker eingesetzt. Deswegen
   * darf keine weitere Variable im Definitionsmodul deklariert
   * werden, und 'start' muss hier an erster Stelle stehen, damit sich
   * die Adresse der Variable nicht aendert!!
   *)
  pEnd  : LONGINT;
  pLen  : LONGINT;
  Info  : ExtInfoPtr;

BEGIN
 INLINE(202FH, 12); (* move.l 12(SP),D0 *)
 BasePagePtr := VAL(ADDRESS,REG(d0));
 WITH BasePagePtr^ DO
   Info := VAL(ExtInfoPtr,CodeBase);
   pEnd := CodeBase + CodeLen + DataLen + BssLen;
 END;
 WITH Info^ DO
   INC(pEnd, heapSize + stackSize);
 END;
 IF ODD(pEnd) THEN
   INC(pEnd);
 END;
 IF pEnd < BasePagePtr^.HighTPA THEN
   (* Programm nur ausfuehren, wenn genuegend Platz *)
   pLen := pEnd - BasePagePtr^.LowTPA;
   SETREG(sp, pEnd); (* Stack setzen *)

   (* Mshrink(pLen, BasePagePtr, 0) *)
   SETREG(d0, pLen);
   INLINE(PUSHL);
   SETREG(d0, BasePagePtr);
   INLINE(PUSHL);
   SETREG(d0, 0D);
   INLINE(PUSHW);
   SETREG(d0, MSHRINK);
   INLINE(PUSHW);
   INLINE(TRAP1);
   INLINE(4FEFH, 12); (* lea 12(SP),SP *)

   BasePagePtr^.HighTPA := pEnd;

   start; (* Programm ausfuehren *)
 END;

 (* Pterm0 *)
 SETREG(d0, PTERM0);
 INLINE(PUSHL);  (* PUSHW reicht auch... *)
 INLINE(TRAP1);
END GEMX.
