 MODULE Scrp;

 IMPORT S:=SYSTEM, AES;


 PROCEDURE Read*(VAR pscrap: ARRAY OF CHAR);

  BEGIN
   AES.AddrIn[0]:= S.ADR(pscrap);
   AES.Call(50000101H);
  END Read;


 PROCEDURE Write*(pscrap: ARRAY OF CHAR);

  BEGIN
   AES.AddrIn[0]:= S.ADR(pscrap);
   AES.Call(51000101H);
  END Write;


 PROCEDURE Clear*();

  BEGIN
   AES.Call(52000100H);
  END Clear;


 END Scrp.
