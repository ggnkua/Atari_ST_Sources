IMPLEMENTATION MODULE testpos2;

(*$C-*)

FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD, VAL;

(*$l-*)

PROCEDURE m0;
  BEGIN
    ASSEMBLER
        link    a5,#0
        break
        unlk    a5
    END
  END m0;

PROCEDURE m1;
  BEGIN
    ASSEMBLER
        link    a5,#0
        trap    #6
        dc.w    -1
        unlk    a5
    END
  END m1;

PROCEDURE m2;
  BEGIN
    ASSEMBLER
        link    a5,#0
        jsr     m1
        unlk    a5
    END
  END m2;

END testpos2.
