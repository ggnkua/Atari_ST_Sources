IMPLEMENTATION MODULE RcMgr;

(*
Rectangle Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM PORTAB IMPORT SIGNEDWORD,UNSIGNEDWORD;
#if long
FROM INTRINSIC IMPORT LONG;
#endif
CAST_IMPORT

PROCEDURE Min(a,b: SIGNEDWORD): SIGNEDWORD;
BEGIN
#if long

#else
  IF a > b THEN
    RETURN b;
  ELSE
    RETURN a;
  END;
#endif
END Min;

PROCEDURE Max(a,b: SIGNEDWORD): SIGNEDWORD;
BEGIN
#if long

#else
  IF a < b THEN
    RETURN b;
  ELSE
    RETURN a;
  END;
#endif
END Max;

PROCEDURE RcIntersect(VAR R1,R2: GRect): BOOLEAN;

VAR T: GRect;

BEGIN
  WITH T DO
    GW:= Min(R2.GX + R2.GW,R1.GX + R1.GW);
    GH:= Min(R2.GY + R2.GH,R1.GY + R1.GH);
    GX:= Max(R2.GX,R1.GX);
    GY:= Max(R2.GY,R1.GY);
    R2.GX:= GX;
    R2.GY:= GY;
    R2.GW:= GW - GX;
    R2.GH:= GH - GY;
    RETURN (GW > GX) AND (GH > GY);
  END;
END RcIntersect;

PROCEDURE RcUnion(R1: GRect; VAR R2: GRect);

VAR T: GRect;

BEGIN
  WITH T DO
    GW:= Max(R2.GX + R2.GW,R1.GX + R1.GW);
    GH:= Max(R2.GY + R2.GH,R1.GY + R1.GH);
    GX:= Min(R2.GX,R1.GX);
    GY:= Min(R2.GY,R1.GY);
    R2.GX:= GX;
    R2.GY:= GY;
    R2.GW:= GW - GX;
    R2.GH:= GH - GY;
  END;
END RcUnion;

PROCEDURE RcConstrain(R1: GRect; VAR R2: GRect);
BEGIN
  IF R2.GX < R1.GX THEN
    R2.GX:= R1.GX;
  END;

  IF R2.GY < R1.GY THEN
    R2.GY:= R1.GY;
  END;

  IF (R2.GX + R2.GW) > (R1.GX + R1.GW) THEN
    R2.GX:= R1.GX + R1.GW - R2.GW;
  END;

  IF (R2.GY + R2.GH) > (R1.GY + R1.GH) THEN
    R2.GY:= R1.GY + R1.GH - R2.GH;
  END;
END RcConstrain;

PROCEDURE RcEqual(VAR R1,R2: GRect): BOOLEAN;
BEGIN
  RETURN (R1.GX = R2.GX) AND
         (R1.GY = R2.GY) AND
         (R1.GW = R2.GW) AND
         (R1.GH = R2.GH);
END RcEqual;

PROCEDURE RcCopy(VAR From,To: GRect);
BEGIN
  To:= From;
END RcCopy;

PROCEDURE RcInside(P: GPnt; VAR R: GRect): BOOLEAN;
BEGIN
  WITH R DO
    RETURN (P.GX >= GX) AND
           (P.GY >= GY) AND
           (P.GX < (GX + GW)) AND
           (P.GY < (GY + GH));
  END;
END RcInside;

PROCEDURE RcSnap(X: SIGNEDWORD; N: UNSIGNEDWORD): SIGNEDWORD;
BEGIN
  X:= X + CAST(SIGNEDWORD,N) DIV 4 - 1;
  RETURN CAST(SIGNEDWORD,N) * (X DIV CAST(SIGNEDWORD,N));
END RcSnap;

PROCEDURE XYWHToGRect(    X,Y,W,H: SIGNEDWORD;
                      VAR Rect   : GRect);
BEGIN
  WITH Rect DO
    GX:= X;
    GY:= Y;
    GW:= W;
    GH:= H;
  END;
END XYWHToGRect;

END RcMgr.
