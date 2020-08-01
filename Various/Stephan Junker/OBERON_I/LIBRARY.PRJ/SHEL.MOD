 MODULE Shel;

 IMPORT S:=SYSTEM, AES;


 PROCEDURE Read*(VAR pcmd, ptail: ARRAY OF CHAR);

  BEGIN
   AES.AddrIn[0]:= S.ADR(pcmd);
   AES.AddrIn[1]:= S.ADR(ptail);
   AES.Call(78000102H);
  END Read;


 PROCEDURE Write*(doex, isgr, isover: INTEGER; pcmd, ptail: ARRAY OF CHAR):
INTEGER;

  BEGIN
   AES.IntIn[0]:= doex;
   AES.IntIn[1]:= isgr;
   AES.IntIn[2]:= isover;
   AES.AddrIn[0]:= S.ADR(pcmd);
   AES.AddrIn[1]:= S.ADR(ptail);
   AES.Call(79030102H);
   RETURN AES.IntOut[0];
  END Write;


 PROCEDURE Get*(VAR addr: ARRAY OF CHAR; len: INTEGER);

  BEGIN
   AES.IntIn[0]:= len;
   AES.AddrIn[0]:= S.ADR(addr);
   AES.Call(7A010101H);
  END Get;


 PROCEDURE Put*(VAR addr: ARRAY OF CHAR; len: INTEGER);

  BEGIN
   AES.IntIn[0]:= len;
   AES.AddrIn[0]:= S.ADR(addr);
   AES.Call(7B010101H);
  END Put;


 PROCEDURE Find*(VAR ppath: ARRAY OF CHAR);

  BEGIN
   AES.AddrIn[0]:= S.ADR(ppath);
   AES.Call(7C000101H);
  END Find;


 PROCEDURE Envrn*(VAR pvalue : ARRAY OF CHAR; parm: ARRAY OF CHAR);

  BEGIN
   AES.AddrIn[0]:= S.ADR(pvalue);
   AES.AddrIn[1]:= S.ADR(parm);
   AES.Call(7D000102H);
  END Envrn;


 END Shel.
