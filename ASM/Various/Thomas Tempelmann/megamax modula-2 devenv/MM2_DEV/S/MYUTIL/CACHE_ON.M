MODULE CacheOn;

(*$N+*)
(*$L-*)

FROM SYSTEM IMPORT ASSEMBLER;
FROM SysInfo IMPORT Has020;
FROM XBIOS IMPORT SuperExec;

PROCEDURE on;
  BEGIN
    ASSEMBLER
        MOVEQ   #1,D0
        DC.W    $4E7B   ; MOVEC
        DC.W    $0002   ; D0,CACR
    END
  END on;
  
BEGIN
  IF Has020 () THEN
    SuperExec (on)
  END
END CacheOn.
