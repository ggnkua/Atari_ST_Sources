IMPLEMENTATION MODULE TAccel;
(* ½ 1992-96 ROLF SCHRADER. * 21.9.92 ~ 8.9.93 + 9.6.94 *)

FROM   BIOX   IMPORT ConSt, NecCI, ConCO,  ConSO, GetCookie;
FROM   GDB    IMPORT ConIS, NecIn, ConOut, ConWS, ConWC;
FROM Terminal IMPORT DoStatus, DoRead,DoWrite, DoWStr;
FROM   VE     IMPORT wChr, wTxt;

PROCEDURE Switch (Io: INTEGER; Dips: BITSET);
 VAR   d: CARDINAL;
 BEGIN
  FOR  d := 0 TO 3 DO
   IF (d IN Dips) THEN
     CASE Io OF
     | 0: CASE d OF
          | 0: DoStatus := ConIS; | 1: DoRead := NecIn;
          | 2: DoWrite  := ConOut | 3: DoWStr := ConWS; END (*C*);
     | 1: CASE d OF
          | 0: DoStatus := ConSt; | 1: DoRead := NecIn;
          | 2: DoWrite  := ConWC; | 3: DoWStr := ConWS; END (*C*);
     | 2: CASE d OF
          | 0: DoStatus := ConSt; | 1: DoRead := NecCI;
          | 2: DoWrite  := ConCO; | 3: DoWStr := ConSO; END (*C*);
     | 3: CASE d OF
          | 0: DoStatus := ConSt; | 1: DoRead := NecCI;
          | 2: DoWrite  := wChr;  | 3: DoWStr := wTxt;  END (*C*);
     ELSE END END END (*C,I,d*); END Switch;

VAR   pNVDI: POINTER TO
               RECORD Vers: CARDINAL; Date: LONGCARD; Conf: BITSET END;
BEGIN IF  (0 > GetCookie ("NVDI", pNVDI))
           OR (pNVDI^.Vers < 210H)  OR ~ (2 IN pNVDI^.Conf) THEN
           Switch (BIOS,    {0..3});     (* ^ Bitflag fr schnelles GEMDOS.*)
      ELSE Switch (VIRTUAL, {WRITE}) END;
           (* Da mit NVDI >=2.11 ConWS viel schneller ist als alle andern! *)
  END TAccel.
