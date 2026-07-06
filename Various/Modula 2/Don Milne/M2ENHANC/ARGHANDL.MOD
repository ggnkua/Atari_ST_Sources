(*$T-*)
IMPLEMENTATION MODULE ArgHandler;

(* Copyright (C) Don Milne & MicroPack Ltd 1986. Permission granted to
   use for non-commercial purposes. *)

FROM SYSTEM IMPORT
       ADR,ADDRESS;
FROM GEMDOS IMPORT
       GetDTA;

VAR lnth,sptr,dptr:CARDINAL;
    rawarg:ArgPtr;
    argbuff:ARRAY[0..255] OF CHAR;

(*......................................................*)

PROCEDURE CharsCopied():CARDINAL;

VAR c:CHAR;
    origdptr:CARDINAL;
    stopped:BOOLEAN;

BEGIN
     origdptr:=dptr;
     IF sptr>lnth THEN RETURN(0) END;
     WHILE rawarg^[sptr]=' ' DO  (* SKIP OVER SPACES *)
         INC(sptr);
         IF sptr>lnth THEN RETURN(0) END;
     END;
     LOOP
         c:=rawarg^[sptr];
         IF (origdptr=dptr) OR
            ((c>='A') AND (c<='Z')) OR
            ((c>='a') AND (c<='z')) OR
            ((c>='0') AND (c<='9')) OR
            (c=':') OR (c='\') OR (c='.') OR (c='*') OR (c='?') THEN
              argbuff[dptr]:=c;
              INC(dptr);
              INC(sptr);
              IF sptr>lnth THEN EXIT END
           ELSE
              EXIT;
         END;
     END;
     IF origdptr<>dptr THEN
         argbuff[dptr]:=CHR(0); INC(dptr);
     END;
     RETURN dptr-origdptr;
END CharsCopied;

(*......................................................*)

PROCEDURE InitArgs;

VAR i:CARDINAL;

BEGIN
     GetDTA(rawarg);
     lnth := ORD(rawarg^[0]);
     argc:=0; sptr:=1; dptr:=0;
     argv[argc+1]:=ADR(argbuff[dptr]);
     WHILE CharsCopied()<>0 DO
         INC(argc);
         argv[argc+1]:=ADR(argbuff[dptr]);
     END;
     FOR i:=argc+1 TO 128 DO argv[i]:=NIL END;
END InitArgs;

(*......................................................*)

BEGIN
     InitArgs;
END ArgHandler.
