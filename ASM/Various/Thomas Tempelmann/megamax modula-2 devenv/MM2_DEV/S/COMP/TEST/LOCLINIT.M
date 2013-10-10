MODULE LoclInit;
(*$S-*)

(*
 prÅfen, ob A5/A6 gesichert sind, wenn Modul lok. zu Proc. init. wird.
*)

FROM SYSTEM IMPORT ASSEMBLER;

PROCEDURE proc;

  PROCEDURE proc2;
  
    MODULE local;
      VAR a: RECORD b,c:CARDINAL END;
      BEGIN
        WITH a DO
          WITH a DO
            WITH a DO
              WITH a DO
              END
            END
          END
        END
      END local;

    BEGIN
    END proc2;

  BEGIN
    proc2
  END proc;

BEGIN
  ASSEMBLER BREAK END;
  proc
END LoclInit.
