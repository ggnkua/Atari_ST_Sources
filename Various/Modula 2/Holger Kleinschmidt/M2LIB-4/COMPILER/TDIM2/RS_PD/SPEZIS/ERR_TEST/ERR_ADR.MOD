(*$S-,$T-,$Q+,$U+*)
MODULE Err_Adr;
(* ½ 1996 by RS. * 8.3.96 *)                         (* Odd Address kludge.*)

FROM SYSTEM IMPORT ADDRESS;
VAR   a: ADDRESS; p: POINTER TO INTEGER; i: INTEGER;
BEGIN a := 54321; p := a; i := p^ END Err_Adr.
