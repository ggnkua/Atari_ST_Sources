MODULE Reals;   (*NW 9.2.89 / 6.12.91*)
                (*SJ 12.2.94*)


 IMPORT
   NumStr;

 CONST
  NumTen = 6;
  NumTenL = 9;


 VAR
   potenzPTen, potenzNTen : ARRAY NumTen OF REAL;
   expoPTen, expoNTen : ARRAY NumTen OF INTEGER;
   potenzPTenL, potenzNTenL : ARRAY NumTenL OF LONGREAL;
   expoPTenL, expoNTenL : ARRAY NumTenL OF INTEGER;


 PROCEDURE Expo*(x: REAL): INTEGER;
 BEGIN
  ASSEMBLER
		MOVE.L	x(A6),D0
		SWAP	D0
		LSR	#7,D0
		AND	#$FF,D0		; just exponent
		SUB	#$7F,D0		; 2's komplement
		UNLK	A6
		RTS
  END
 END Expo;


 PROCEDURE ExpoL*(x: LONGREAL): INTEGER;
 BEGIN
  ASSEMBLER
		MOVE.L	x(A6),D0
		SWAP	D0
		LSR	#4,D0
		AND	#$7FF,D0	; just exponent
		SUB	#$3FF,D0	; 2's komplement
		UNLK	A6
		RTS
  END
 END ExpoL;


 PROCEDURE SetExpo*(e: INTEGER; VAR x: REAL);
 BEGIN
  ASSEMBLER
		MOVE.L	x(A6),A0	; ADR(x)
		AND	#$807F,(A0)	; clr expo
		MOVE	e(A6),D0
		ADD	#$7F,D0
		LSL	#7,D0		; correct pos
		OR	D0,(A0)		; set expo
  END
 END SetExpo;


 PROCEDURE SetExpoL*(e: INTEGER; VAR x: LONGREAL);
 BEGIN
  ASSEMBLER
		MOVE.L	x(A6),A0	; ADR(x)
		AND	#$800F,(A0)	; clr expo
		MOVE	e(A6),D0
		ADD	#$3FF,D0
		LSL	#4,D0		; correct pos
		OR	D0,(A0)		; set expo
  END
 END SetExpoL;


 PROCEDURE Ten*(e: INTEGER): REAL;
  (* returns 10^e *)
  VAR
    i : INTEGER;
    r : REAL;
 BEGIN
  r := 1.0;
  IF e > 0 THEN
    i := NumTen-1;
    WHILE e # 0 DO
      IF e >= expoPTen[i] THEN
        r := r * potenzPTen[i];
        DEC(e, expoPTen[i]);
      ELSE
        DEC(i)
      END;
    END;
  ELSIF e < 0 THEN
    i := NumTen-1;
    WHILE e # 0 DO
      IF e <= expoNTen[i] THEN
        r := r * potenzNTen[i];
        DEC(e, expoNTen[i]);
      ELSE
        DEC(i)
      END;
    END;
  END;
  RETURN r;
 END Ten;


 PROCEDURE TenL*(e: INTEGER): LONGREAL;
  VAR
    i : INTEGER;
    r : LONGREAL;
 BEGIN
  r := 1.0;
  IF e > 0 THEN
    i := NumTenL-1;
    WHILE e # 0 DO
      IF e >= expoPTenL[i] THEN
        r := r * potenzPTenL[i];
        DEC(e, expoPTenL[i]);
      ELSE
        DEC(i)
      END;
    END;
  ELSIF e < 0 THEN
    i := NumTenL-1;
    WHILE e # 0 DO
      IF e <= expoNTenL[i] THEN
        r := r * potenzNTenL[i];
        DEC(e, expoNTenL[i]);
      ELSE
        DEC(i)
      END;
    END;
  END;
  RETURN r;
 END TenL;


 PROCEDURE Convert*(x: REAL; n: INTEGER; VAR d: ARRAY OF CHAR);
 BEGIN
  NumStr.RealTo(x, n, d);
 END Convert;

 PROCEDURE ConvertL*(x: LONGREAL; n: INTEGER; VAR d: ARRAY OF CHAR);
 BEGIN
  NumStr.LRealTo(x, n, d);
 END ConvertL;

 PROCEDURE ConvertH*(x: REAL; VAR d: ARRAY OF CHAR);
 END ConvertH;

 PROCEDURE ConvertHL*(x: LONGREAL; VAR d: ARRAY OF CHAR);
 END ConvertHL;

 PROCEDURE FSR*(): LONGINT;
 END FSR;

 PROCEDURE SetFSR*(status: LONGINT);
 END SetFSR;


 PROCEDURE Init;
  VAR
    i : INTEGER;
 BEGIN
  expoPTen[0] := 1; potenzPTen[0] := 10.0;
  expoNTen[0] := -1; potenzNTen[0] := 0.1;
  FOR i := 0 TO NumTen-2 DO
    potenzPTen[i+1] := potenzPTen[i] * potenzPTen[i];
    expoPTen[i+1] := 2 * expoPTen[i];
    potenzNTen[i+1] := potenzNTen[i] * potenzNTen[i];
    expoNTen[i+1] := 2 * expoNTen[i];
  END;
  expoPTenL[0] := 1; potenzPTenL[0] := 10.0;
  expoNTenL[0] := -1; potenzNTenL[0] := 0.1;
  FOR i := 0 TO NumTenL-2 DO
    potenzPTenL[i+1] := potenzPTenL[i] * potenzPTenL[i];
    expoPTenL[i+1] := 2 * expoPTenL[i];
    potenzNTenL[i+1] := potenzNTenL[i] * potenzNTenL[i];
    expoNTenL[i+1] := 2 * expoNTenL[i];
  END;
 END Init;


BEGIN
  Init
END Reals.
