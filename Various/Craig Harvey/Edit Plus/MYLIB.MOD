IMPLEMENTATION MODULE Mylib; (* 1/13/91 make movemem into longcard *)
(* 1/11/92
   Fixed Find routine to exit case sensitive w/o going into case insens
   routine (& thus capitalizing the search string)!
*)


FROM GEMDOS IMPORT ConWS;
FROM SYSTEM IMPORT CODE, ADDRESS, ADR, SETREG, REGISTER;
FROM Strings IMPORT Length;

CONST D0 = 0;
      D1 = 1;
      D2 = 2;
      D3 = 3;
      A0 = 8;
      A1 = 9;
      A2 = 10;
      A3 = 11;
      A4 = 12;

PROCEDURE Pwr(x, exp: CARDINAL): CARDINAL;
VAR i, y: CARDINAL;
BEGIN
  y:= x;
  IF exp = 0 THEN y:= 1;
  ELSIF exp > 1 THEN
    FOR i:= 2 TO exp DO
      y:= y*x;
    END; (* for *)
  END; (* if *) (* note: if exp=1 then y just stays as x *)
  RETURN y;
END Pwr;

PROCEDURE Cardtostrg(x: CARDINAL; VAR cardstrg: ARRAY OF CHAR);
VAR i, place: CARDINAL;
    big: BOOLEAN;
BEGIN
  i:= 0;
  big:= FALSE; (* whether need a zero in a place *)
  FOR place:= 4 TO 1 BY -1 DO
    IF (x >= Pwr(10, place)) OR big THEN
      cardstrg[i]:= CHR(x DIV Pwr(10, place) + 48);
      x:= x MOD Pwr(10, place);
      big:= TRUE;
      INC(i);
    END; (* if *)
  END; (* for place = 4
   to 1 *)
  cardstrg[i]:= CHR(x + 48);
  cardstrg[i + 1]:= 0C;
END Cardtostrg;

PROCEDURE ConCard(x: CARDINAL);
VAR cardstrg: ARRAY[0..5] OF CHAR;
BEGIN
  Cardtostrg(x, cardstrg);
  ConWS(cardstrg);
END ConCard;

PROCEDURE MoveMem(from, to: ADDRESS; n: LONGCARD); (* was just CARDINAL *)
VAR temp1, temp2, temp3: ADDRESS; (* for register storage *)
BEGIN
  IF n > 0 THEN
    temp1:= REGISTER(A0);
    temp2:= REGISTER(A1);
    temp3:= REGISTER(D1);
    (* NOTE: only low word of D reg is used in DBcc commands!! *)
    (* so it can only count to 65535 *)
    SETREG(1, n-1); (* counter into D1 *)
    IF from < to THEN (* shift right, starting at top in case of overlap *)
      SETREG(A0, to + ADDRESS(n));
      SETREG(A1, from + ADDRESS(n));
(***
     (** LOOP1 & 2 **)
      (* MOVE.B -(A1),-(A0) *)
      CODE(01121H); (* 0001 0001 0010 0001 = *)
      (* DBRA(D1,-4) *)
      CODE(051C9H,0FFFCH); (* PC relative decrement & branch *)
        (* 0101 0001 1100 1001, 1111 1111 1111 1100 = *)
     (** END1 **)
(*
   Swap high word into low, check if equal zero, if not then decrement
   it by 1, swap it back into high word, set low word = $FFFF and run
   loop again.
*)
      (* clr.w D1 *)(* zero low word *)
      (* swap D1 *)(* sets Z bit if all 32 bits are zero *)
      (* beq END2  *)(* 2(pc) *)
      (* subq.w D1 *)
      (* swap D1 *)
      (* addi.w #-1, D1 *)
      (* bra LOOP1 *)
     (** END2 **)
***)
(* OR JUST manually check entire D reg with separate subq and beq commands *)
     (** LOOP1 **)
      (* MOVE.B -(A1),-(A0) *)
      CODE(01121H); (* 0001 0001 0010 0001 = *)
      (* subq.l #1,D1 *)
      CODE(05381H);
      (* bcc.s LOOP1 *)(* continue til we get to -1 which generates a carry *)
      CODE(064FAH);
     (** END1 **)
    ELSIF from > to THEN     (* shift left *)
      SETREG(A0, to); (* A0 *)
      SETREG(A1, from); (* A1 *)
     (** LOOP2 **)
      (* MOVE.B (A1)+,(A0)+ *)
      CODE(010D9H); (* 0001 0000 1101 1001 = *)
      (* subq.l #1,D1 *)
      CODE(05381H);
      (* bcc.s LOOP2 *)(* continue til we get to -1 which generates a carry *)
      CODE(064FAH);
     (** END2 **)
(**
      (* DBRA(D1,-4) *)
      CODE(051C9H,0FFFCH); (* PC relative decrement & branch *)
        (* 0101 0001 1100 1001, 1111 1111 1111 1100 *)
**)
    ELSE (* from = to, so don't do anything *)
    END; (* IF from < to *)
    SETREG(A0, temp1); (* restore registers *)
    SETREG(A1, temp2);
    SETREG(D1, temp3);
  END; (* if n > 0 *)
END MoveMem;


PROCEDURE Find(flen: LONGCARD;
               searchadr: ADDRESS; (* adr of search string *)
               srchlen: CARDINAL;
               casesens: BOOLEAN;
               VAR chadr: ADDRESS): BOOLEAN;

(** CAUTION: When doing a case-insensitive search, it capitalizes all of
    the ACTUAL search string in older versions **)
(** A4 & D5 are saved but never gets used as of v 2.10 **)
VAR ch: CHAR;
    found: BOOLEAN;
    tmpbuff: ARRAY[0..20] OF CHAR;
    j: CARDINAL; (* debug only *)

BEGIN
  (* added 11/2/90 for EdHak 2.04 *)
  IF LONG(srchlen) > flen THEN (* not enough room left to find srch string *)
    RETURN FALSE;
  END;

  found:= FALSE;
  (* movem.l A1-A4/D1-D5,-(SP) *)
  CODE(048E7H, 07C78H); (* 0100 1000 1110 0111, 0111 1100 0111 1000 *)

  SETREG(A1, searchadr);
(**)
  SETREG(D1, LONG(srchlen));
  SETREG(A2, ADR(chadr)); (* for subsequent storage of new chadr *)
  SETREG(A3, chadr);
  SETREG(D0, flen); (* how far to search *)
  (* A0 is later a tmp holder for A1 during search strg capitalization *)
  (* D2 will be last possible starting address *)
  (* D3 & D4 are tmp holders for cmp byte *)
  (* A4 is only used at start for xferring findstrg to tmpbuff *)

  (* move.l A3, D2 *)
  CODE(0240BH);  (* 0010 0100 0000 1011 *)
  (* add.l D0, D2 *) (* add length to startadr to get endadr *)
  CODE(0D480H); (* 1101 0100 1000 0000 *)
  (** Note: the following can go <= starting address **)
  (** should check if is room left to be able to find srchstrg **)

  (* sub.l D1, D2 *) (* subtract srchlen for last possible starting adress *)
  CODE(09481H); (* 1001 0100 1000 0001 *)
  (* now D0 is free to use *)
(*
  (* cmpi.b #0, (A3) *)
  CODE(00C13H, 00000H); (* 0000 1100 0001 0011, 0000 0000 0000 0000 *)
  (* beq CASEINSENS: 30(pc)  was 40(pc) *)
  CODE(0671EH); (* 0110 0111 0001 1110 *)
*)
(*
  CODE(04AFCH); (* illegal opcode, for debugging *)
*)
  IF casesens THEN
 (* REPEAT1: *)
    (* clr.l D0 *) (* 0, will be offset from either chadr or srchadr *)
    CODE(04280H); (* 0100 0010 1000 0000 *)
   (* REPEAT2: *)
      (* cmp.w D0,D1 *)(* check if reached end of srchstrg *)
      CODE(0B240H);
      (* beq.s FOUND: 22(pc) *)
      CODE(06716H); (* 0110 0111 0001 0110 *)
      (* move.b (A3,D0), D4 *) (* tmp storage of file char *)
      CODE(01833H, 00000H); (* 0001 1000 0011 0011, 0000 0000 0000 0000 *)
      (* cmp (A1,D0), D4 *) (* compare case sensitively *)
      CODE(0B831H, 00000H); (* 1011 1000 0011 0001, 0000 0000 0000 0000 *)
      (* bne NOTFOUND: 4(pc) *)
      CODE(06604H); (* 0110 0110 0000 0100 *)
      (* addq.w #1, D0 *)
      CODE(05240H);  (* 0101 0010 0100 0000 *)
    (* bra REPEAT2: -18(pc) *)
    CODE(060EEH); (* 0110 0000 1110 1110 *)
    (* NOTFOUND: *)
    (* cmp A3, D2 *) (* at end of possible starting chars? *)
    CODE(0B48BH); (* 1011 0100 1000 1011 *)
    (* bls END:  12(pc) *)
    CODE(0630CH); (* 0110 0011 0001 0000 *)
    (* addq.l #1, A3 *) (* next possible starting address *)
    CODE(0528BH);  (* 0101 0010 1000 1011 *)
  (* bra REPEAT1: -28(pc) *)
  CODE(060E4H); (* 0110 0000 1110 0100 *)
  (* FOUND: *)
  (* movea.l A3, (A2) *)
  CODE(0248BH); (* 0010 0100 1000 1011 *)
  found:= TRUE; (* this command takes 6 bytes in Mod-2 + 4 for JMP to end of IF *)
(*
  (* move.w #1, (A4) *)(* addq.w #1, (A4) *) (* faster than move #1, (A4) *)
  CODE(038BCH, 00101H); (* 0011 1000 1011 1100, 0000 0001 0000 0001 *)
    (* CODE(05254H); *)(* 0101 0010 0101 0100 *)
*)
  (* END: *)
(**
  (* bra ENDALL: 84(pc) *)
  CODE(06054H); (* 0110 0000 0101 0100 *)
**)
(*
  (* restore all registers used *)
  (* movem.l A1-A4/D1-D5,(SP)+ *)
  CODE(04CDFH, 01E3EH); (* 0100 1100 1101 1111, 0001 1110 0011 1110 *)
  RETURN found;
*)
 ELSE (* case insensitive *)
(*
  CODE(04AFCH); (* illegal opcode, for debugging *)
*)
(**)
  (* CASEINSENS: *)
  (* capitalize all of search string *)
  (* clr.l D0 *) (* to make sure hi word is clear *)
  CODE(04280H); (* 0100 0010 1000 0000 *)
  (* move.w D1, D0 *) (* for counter *)
  CODE(03001H); (* 0011 0000 0000 0001 *)
  (* subq.w #1, D0 *) (* for dbra command looking for -1 *)
  CODE(05340H); (* 0101 0011 0100 0000 *)
  (* movea.l A1, A0 *) (* tmp storage while capitalizing *)
  CODE(02049H); (* 0010 0000 0100 1001 *)

  (* start loop *)
  (* cmpi.b #97, (A1) *) (* 'a' *)
  CODE(00C11H, 00061H); (* 0000 1100 0001 0001, 0000 0000 0110 0001 *)
  (* blt END1: 10(pc) *)
  CODE(06D0AH); (* 0110 1101 0000 1010 *)
  (* cmpi.b #122, (A1) *) (* 'z' *)
  CODE(00C11H, 0007AH); (* 0000 1100 0001 0001, 0000 0000 0111 1010 *)
  (* bgt END1: 4(pc) *)
  CODE(06E04H); (* 0110 1110 0000 0100 *)
  (* subi.b #32, (A1) *)
  CODE(00411H, 00020H); (* 0000 0100 0001 0001, 0000 0000 0010 0000 *)
  (* END1: *)
  (* addq.l #1, A1 *) (* next char of srch *)
  CODE(05289H);  (* 0101 0010 1000 1001 *)
  (* dbra D0, -20 *) (* pc relative decrement & branch *)
  CODE(051C8H,0FFECH); (* 0101 0001 1100 1000, 1111 1111 1110 1100 *)

  (* movea.l A0, A1 *) (* restore starting address of searchstrg *)
  CODE(02248H); (* 0010 0010 0100 1000 *)

  (* REPEAT1: *)
    (* clr.l D0 *) (* 0, will be offset from either chadr or srchadr *)
    CODE(04280H); (* 0100 0010 1000 0000 *)
    (* REPEAT2: *)
(* (* 2.30 1/10/92 *)
      (* cmp D1,D0 *)(* check if reached end of srchstrg *)
      CODE(0B041H); (* 1011 0000 0100 0001 *)
*)
      (* cmp.w D0, D1 *)(* check if reached end of srchstrg *)
      CODE(0B240H);

      (* beq FOUND: 40(pc) *)
      CODE(06728H); (* 0110 0111 0010 1000 *)

      (* move.b (A3,D0), D3 *) (* tmp storage of file char *)
      CODE(01633H, 00000H); (* 0001 0110 0011 0011, 0000 0000 0000 0000 *)
      (* move.b (A1,D0), D4 *) (* tmp storage of searchstrg char *)
      CODE(01831H, 00000H); (* 0001 1000 0011 0001, 0000 0000 0000 0000 *)

      (* cmpi.b #97, D3 *) (* 'a' *)
      CODE(00C03H, 00061H); (* 0000 1100 0000 0011, 0000 0000 0110 0001 *)
      (* blt END1: 10(pc) *)
      CODE(06D0AH); (* 0110 1101 0000 1010 *)
      (* cmpi.b #122, D3 *) (* 'z' *)
      CODE(00C03H, 0007AH); (* 0000 1100 0000 0011, 0000 0000 0111 1010 *)
      (* bgt END1: 4(pc) *)
      CODE(06E04H); (* 0110 1110 0000 0100 *)
      (* subi.b #32, D3 *)
      CODE(00403H, 00020H); (* 0000 0100 0000 0011, 0000 0000 0010 0000 *)
      (* END1: *)

      (* cmp D3, D4 *) (* compare case insensitively *)
      CODE(0B803H); (* 1011 1000 0000 0011 *)
      (* bne NOTFOUND: 4(pc) *)
      CODE(06604H); (* 0110 0110 0000 0100 *)
      (* addq.w #1, D0 *)
      CODE(05240H);  (* 0101 0010 0100 0000 *)
    (* bra REPEAT2: -36(pc) *)
    CODE(060DCH); (* 0110 0000 1101 1100 *)
    (* NOTFOUND: *)
    (* cmp A3, D2 *) (* at end of possible starting chars? *)
    CODE(0B48BH); (* 1011 0100 1000 1011 *)
    (* bls ENDALL: 16(pc) *)
    CODE(06310H); (* 0110 0011 0001 0000 *)
    (* addq.l #1, A3 *) (* next possible starting address *)
    CODE(0528BH);  (* 0101 0010 1000 1011 *)
  (* bra REPEAT1: -46(pc) *)
  CODE(060D2H); (* 0110 0000 1101 0010 *)
  (* FOUND: *)
  (* movea.l A3, (A2) *)
  CODE(0248BH); (* 0010 0100 1000 1011 *)
  found:= TRUE; (* this command takes 10 bytes in Mod-2!! *)

  (* ENDALL: *)
 END; (* if casesens *)
  (* restore all registers used *)
  (* movem.l A1-A4/D1-D5,(SP)+ *)
  CODE(04CDFH, 01E3EH); (* 0100 1100 1101 1111, 0001 1110 0011 1110 *)
  RETURN found;
END Find;

END Mylib.

