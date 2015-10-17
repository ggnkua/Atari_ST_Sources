MODULE testpos;

(*$C-*)

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD, VAL;

(*
import directory;
*)

import modbase, TESTPOS2;

(*$l-*)

PROCEDURE l0;
  BEGIN
    ASSEMBLER
        link    a5,#0
        break
        unlk    a5
    END
  END l0;

PROCEDURE l1;
  BEGIN
    ASSEMBLER
        link    a5,#0
        jsr     testpos2.m2
        unlk    a5
    END
  END l1;

PROCEDURE l2;
  BEGIN
    ASSEMBLER
        link    a5,#0
        jsr     l1
        unlk    a5
    END
  END l2;

var i: modbase.modref; s1, s2: array [0..1] of char;

BEGIN
  modbase.FindRef (ADDRESS(l2),i);
  ASSEMBLER
        move.l  i,a0
        BREAK
  END;
  (* directory.splitname ('a33.33a', s1, s2); *)
  l2
END testpos.
