TITLE: PIM2 fractions program - FOR with no iterations
MODULE fractions;
FROM InOut      IMPORT  Write, WriteLn, WriteString, WriteCard;

CONST
        Base    = 10;
        N       = 32;
VAR
        i,j,m   : CARDINAL;
        rem     : CARDINAL;
        d       : ARRAY[1..N] OF CARDINAL;
        x       : ARRAY[0..N] OF CARDINAL;

BEGIN
  FOR i := 2 TO N DO
    FOR j := 0 TO i-1 DO
      x[j] := 0
    END;
    m := 0; rem := 1;
    REPEAT
      m := m + 1;
      x[rem] := m;
      rem := Base * rem;
      d[m] := rem DIV i;
      rem := rem MOD i;
    UNTIL x[rem] # 0;
    WriteCard(i,6); WriteString(" 0.");
    FOR j := 1 TO x[rem]-1 DO
      Write(CHR(d[j]+ORD("0")));
    END;
    Write("'");
    FOR j := x[rem] TO m DO
      Write(CHR(d[j]+ORD("0")));
    END;
    WriteLn;
  END;
END fractions.

