MODULE QSort; (* SJ 16.8.93 / 19.2.95 *)

(*
 Quick sort algorithm for any kind of data stored in arrays.
 *)


IMPORT
  S:=SYSTEM;


TYPE
  CompareProc* = PROCEDURE (a: S.PTR; i, j: LONGINT) : LONGINT;
  ExchangeProc* = PROCEDURE (a: S.PTR; i, j: LONGINT);



PROCEDURE QSort*(a : S.PTR; l,r : LONGINT;
    compare: CompareProc; exchange: ExchangeProc);
(*
 a points to an array to be sorted. Its contents is anything. l must be the
 index of the left end (0) and r of the right end ( LEN(a^)-1 ).
 compare must be a procedure returning zero if element i is equal to element
 j, a value smaller than zero if element i is smaller than element j, and
 otherwise a value greater than zero. This is equal to element i minus
 element j if they are numbers.
 exchange must exchange the entries i and j in a.
 Quick sort time consumption is proportional 2n*ld(n).
 *)
  VAR
    i,j : LONGINT;
 BEGIN
  IF r > l THEN
    i := l; j := r-1;
    LOOP
      WHILE compare(a, i, r) < 0 DO INC(i) END;
      WHILE (j >= 0) & (compare(a, r, j) <= 0) DO DEC(j) END;
      IF (i >= j) THEN EXIT END;
      exchange(a, i, j);
    END;
    exchange(a, i, r);
    QSort(a, l, i-1, compare, exchange);
    QSort(a, i+1, r, compare, exchange);
  END;
 END QSort;


PROCEDURE CompareSInt*(a: S.PTR; i, j: LONGINT) : LONGINT;
(*
 A standard compare routine for arrays of SHORTINT.
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  a,A0
    MOVE.L  i,D0
    MOVE.L  j,D1
    MOVE.B  (A0,D0.L),D0
    SUB.B   (A0,D1.L),D0
    EXTB.L  D0
    RETURN
  END;
 END CompareSInt;


PROCEDURE CompareInt*(a: S.PTR; i, j: LONGINT) : LONGINT;
(*
 A standard compare routine for arrays of INTEGER.
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  a,A0
    MOVE.L  i,D0
    LSL.L   #1,D0
    MOVE.L  j,D1
    LSL.L   #1,D1
    MOVE.W  (A0,D0.L),D0
    SUB.W   (A0,D1.L),D0
    EXT.L   D0
    RETURN
  END;
 END CompareInt;


PROCEDURE CompareLInt*(a: S.PTR; i, j: LONGINT) : LONGINT;
(*
 A standard compare routine for arrays of LONGINT.
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  a,A0
    MOVE.L  i,D0
    LSL.L   #2,D0
    MOVE.L  j,D1
    LSL.L   #2,D1
    MOVE.L  (A0,D0.L),D0
    SUB.L   (A0,D1.L),D0
    RETURN
  END;
 END CompareLInt;


PROCEDURE CompareReal*(a: S.PTR; i, j: LONGINT) : LONGINT;
(*
 A standard compare routine for arrays of REAL.
 *)
  VAR
    ri, rj: REAL;
 BEGIN
  ASSEMBLER
    MOVE.L  a,A0
    MOVE.L  i,D0
    LSL.L   #2,D0
    MOVE.L  j,D1
    LSL.L   #2,D1
    MOVE.L  (A0,D0.L),ri
    MOVE.L  (A0,D1.L),rj
  END;
  IF ri = rj THEN RETURN 0 END;
  IF ri < rj THEN RETURN -1 END;
  RETURN 1;
 END CompareReal;


PROCEDURE CompareLReal*(a: S.PTR; i, j: LONGINT) : LONGINT;
(*
 A standard compare routine for arrays of LONGREAL.
 *)
  VAR
    ri, rj: LONGREAL;
 BEGIN
  ASSEMBLER
    MOVE.L  a,A0
    MOVE.L  i,D0
    LSL.L   #3,D0
    MOVE.L  j,D1
    LSL.L   #3,D1
    MOVE.L  (A0,D0.L),ri
    MOVE.L  4(A0,D0.L),ri+4
    MOVE.L  (A0,D1.L),rj
    MOVE.L  4(A0,D1.L),rj+4
  END;
  IF ri = rj THEN RETURN 0 END;
  IF ri < rj THEN RETURN -1 END;
  RETURN 1;
 END CompareLReal;


PROCEDURE CompareStrings*(a: S.PTR; i, j: LONGINT) : LONGINT;
(*
 A standard compare routine for arrays of POINTER TO ARRAY [num] OF CHAR.
 *)
 BEGIN
  ASSEMBLER

    MOVE.L  a,A0
    MOVE.L  i,D0
    LSL.L   #2,D0
    MOVE.L  j,D1
    LSL.L   #2,D1
    MOVE.L  (A0,D0.L),A1
    MOVE.L  (A0,D1.L),A2
  loop:
    TST.B   (A1)
    BEQ.B   striEnd

    CMPM.B  (A1)+,(A2)+
    BEQ.B   loop

  testCmp:
    BHI.B   jgtri

  igtrj:
    MOVEQ   #1,D0
    BRA.B   end

  jgtri:
    MOVEQ   #-1,D0
    BRA.B   end

  striEnd:
    TST.B   (A2)
    BNE.B   testCmp

    MOVEQ   #0,D0

  end:
    RETURN

  END;
 END CompareStrings;


PROCEDURE ExchangeSInt*(a: S.PTR; i, j: LONGINT);
(*
 A standard exchange routine for arrays of any byte sized type
 (SHORTINT, BOOLEAN, BYTE, CHAR).
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  a,A0
    MOVE.L  i,D0
    MOVE.L  j,D1
    MOVE.B  (A0,D0.L),D0
    MOVE.B  (A0,D1.L),(A0,D0.L)
    MOVE.B  D0,(A0,D1.L)
  END;
 END ExchangeSInt;


PROCEDURE ExchangeInt*(a: S.PTR; i, j: LONGINT);
(*
 A standard exchange routine for arrays of any word sized type
 (INTEGER).
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  a,A0
    MOVE.L  i,D0
    LSL.L   #1,D0
    MOVE.L  j,D1
    LSL.L   #1,D1
    MOVE.W  (A0,D0.L),D2
    MOVE.W  (A0,D1.L),(A0,D0.L)
    MOVE.W  D2,(A0,D1.L)
  END;
 END ExchangeInt;


PROCEDURE ExchangeLInt*(a: S.PTR; i, j: LONGINT);
(*
 A standard exchange routine for arrays of any long word sized type
 (LONGINT, SET, REAL, PTR, POINTER TO ...)
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  a,A0
    MOVE.L  i,D0
    LSL.L   #2,D0
    MOVE.L  j,D1
    LSL.L   #2,D1
    MOVE.L  (A0,D0.L),D2
    MOVE.L  (A0,D1.L),(A0,D0.L)
    MOVE.L  D2,(A0,D1.L)
  END;
 END ExchangeLInt;


PROCEDURE ExchangeLReal*(a: S.PTR; i, j: LONGINT);
(*
 A standard exchange routine for arrays of any quad word sized type
 (LONGREAL).
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  a,A0
    MOVE.L  i,D0
    LSL.L   #3,D0
    MOVE.L  j,D1
    LSL.L   #3,D1
    MOVEM.L (A0,D0.L),D2-D3
    MOVEM.L (A0,D1.L),D4-D5
    MOVEM.L D4-D5,(A0,D0.L)
    MOVEM.L D2-D3,(A0,D1.L)
  END;
 END ExchangeLReal;


END QSort.