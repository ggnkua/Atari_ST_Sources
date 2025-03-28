IMPLEMENTATION MODULE BoolOps;

(* (C) Robert Tolksdorf fuer ST-Computer, 8/90 *)

FROM SYSTEM IMPORT BYTE, VAL;

PROCEDURE And(VAR a: ARRAY OF BYTE; b: ARRAY OF BYTE);
VAR i:INTEGER;
BEGIN
  i:=0;
  WHILE (i<=HIGH(a)) AND (i<=HIGH(b)) DO
    a[i]:=VAL(CHAR,VAL(BITSET,a[i])*VAL(BITSET,b[i]));
    i:=i+1
  END;
END And;

PROCEDURE Or(VAR a: ARRAY OF BYTE; b: ARRAY OF BYTE);
VAR i:INTEGER;
BEGIN
  i:=0;
  WHILE (i<=HIGH(a)) AND (i<=HIGH(a)) DO
    a[i]:=VAL(CHAR,VAL(BITSET,a[i])+VAL(BITSET,b[i]));
    i:=i+1;
  END;
END Or;

PROCEDURE Xor(VAR a: ARRAY OF BYTE; b: ARRAY OF BYTE);
VAR i:INTEGER;
BEGIN
  i:=0;
  WHILE (i<=HIGH(a)) AND (i<=HIGH(a)) DO
    a[i]:=VAL(CHAR,VAL(BITSET,a[i])/VAL(BITSET,b[i]));
    i:=i+1;
  END;
END Xor;

PROCEDURE Not(VAR a: ARRAY OF BYTE);
VAR i:INTEGER;
BEGIN
  i:=0;
  WHILE (i<=HIGH(a)) AND (i<=HIGH(a)) DO
    a[i]:=VAL(CHAR,VAL(BITSET,a[i])/{0..15});
    i:=i+1;
  END;
END Not;

PROCEDURE Imp(VAR a: ARRAY OF BYTE; b: ARRAY OF BYTE);
VAR i:INTEGER;
BEGIN
  i:=0;
  WHILE (i<=HIGH(a)) AND (i<=HIGH(a)) DO
    a[i]:=VAL(CHAR,(VAL(BITSET,a[i])-VAL(BITSET,b[i]))/{0..15});
    i:=i+1;
  END;
END Imp;

PROCEDURE Nand(VAR a:ARRAY OF BYTE; b: ARRAY OF BYTE);
VAR i:INTEGER;
BEGIN
  i:=0;
  WHILE (i<=HIGH(a)) AND (i<=HIGH(a)) DO
    a[i]:=VAL(CHAR,(VAL(BITSET,a[i])*VAL(BITSET,b[i]))/{0..15});
    i:=i+1;
  END;
END Nand;

PROCEDURE Nor(VAR a: ARRAY OF BYTE; b: ARRAY OF BYTE);
VAR i:INTEGER;
BEGIN
  i:=0;
  WHILE (i<=HIGH(a)) AND (i<=HIGH(a)) DO
    a[i]:=VAL(CHAR,(VAL(BITSET,a[i])+VAL(BITSET,b[i]))/{0..15});
    i:=i+1;
  END;
END Nor;

PROCEDURE Nimp(VAR a: ARRAY OF BYTE; b: ARRAY OF BYTE);
VAR i:INTEGER;
BEGIN
  i:=0;
  WHILE (i<=HIGH(a)) AND (i<=HIGH(a)) DO
    a[i]:=VAL(CHAR,VAL(BITSET,a[i])-VAL(BITSET,b[i]));
    i:=i+1;
  END;
END Nimp;

END BoolOps.
