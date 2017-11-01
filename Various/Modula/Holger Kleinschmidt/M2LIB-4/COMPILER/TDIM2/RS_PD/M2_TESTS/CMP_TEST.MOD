MODULE Test;            (* Zur Demo eines Compiler-Bugs beim Ptr-Vergleich.*)
(* ½ 1993-94 ROLF SCHRADER. * 23.8.94 *)

(*$T- Erm”glicht Pointer-Arithmetik.*)

FROM  SYSTEM  IMPORT ADDRESS;

TYPE  PTR = POINTER TO CARDINAL;

VAR   p: PTR;
      a: ADDRESS;
      b: BOOLEAN;

BEGIN a := 4711H;    p := a;

      b := (p <= a); b := (p < a); b := (p = a); b := (p > a); b := (p >= a);

      b := (a <= p); b := (a < p); b := (a = p); b := (a > p); b := (a >= p);

      END Test.
