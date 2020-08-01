MODULE Error; (* SJ 29.1.93 *)


IMPORT
  S:=SYSTEM, Str:=Strings, NStr:=NumStr, Form, Sys, Task;


CONST error1   = '  General error';
      error2   = '  Drive not ready';
      error3   = '  Unknown function number|at XBIOS call';
      error4   = '  CRC error with RS232';
      error5   = '  Illegal parameters';
      error6   = '  Track not found';
      error7   = '  Bootsektor ungÅltig';
      error8   = '  Sector not found';
      error10  = '  Write fault';
      error11  = '  Read fault';
      error12  = '  General error';
      error13  = '  Disk is write protected';
      error14  = '  Disk was changed';
      error15  = '  Device does not exist';
      error16  = '  Verify error';
      error17  = '  No disk in drive';
      error32  = '  Unknown function number|at GEMDOS call';
      error33  = '  File **|not found';
      error34  = '  Path **|does not exist';
      error35  = '  No handle available';
      error36  = '  Illegal access';
      error37  = '  Unknown handle';
      error39  = '  out of memory';
      error40  = '  Illegal memory block|address';
      error46  = '  Unknown drive';
      error49  = '  No more files satisfying|**';
      error64  = '  Out of range at Fseek';
      error65  = '  Internal error';
      error66  = '  Wrong program format';
      error67  = '  Shrink of memory failed';
      error100 = '  Programming error';
      enderr   = '  ';
(* the first two bytes are needed for the error number *)

      listend  = -32000;

TYPE errptr    = POINTER TO errdef;
     errdef    = RECORD
                   ErrorNo : INTEGER;
                   ErrStr  : ARRAY 100 OF CHAR;
                 END(*RECORD*);

VAR NoErr* : BOOLEAN;
  (* TRUE if there was no error (i.e. the error number was positive *)

VAR Inited : BOOLEAN;

PROCEDURE Dummy;
  VAR Ptr : errptr;
 BEGIN
  Ptr := S.ADR(error1);	(* locate strings *)
  Ptr := S.ADR(error2);
  Ptr := S.ADR(error3);
  Ptr := S.ADR(error4);
  Ptr := S.ADR(error5);
  Ptr := S.ADR(error6);
  Ptr := S.ADR(error7);
  Ptr := S.ADR(error8);
  Ptr := S.ADR(error10);
  Ptr := S.ADR(error11);
  Ptr := S.ADR(error12);
  Ptr := S.ADR(error13);
  Ptr := S.ADR(error14);
  Ptr := S.ADR(error15);
  Ptr := S.ADR(error16);
  Ptr := S.ADR(error17);
  Ptr := S.ADR(error32);
  Ptr := S.ADR(error33);
  Ptr := S.ADR(error34);
  Ptr := S.ADR(error35);
  Ptr := S.ADR(error36);
  Ptr := S.ADR(error37);
  Ptr := S.ADR(error39);
  Ptr := S.ADR(error40);
  Ptr := S.ADR(error46);
  Ptr := S.ADR(error49);
  Ptr := S.ADR(error64);
  Ptr := S.ADR(error65);
  Ptr := S.ADR(error66);
  Ptr := S.ADR(error67);
  Ptr := S.ADR(error100);
  Ptr := S.ADR(enderr);
 END Dummy;

PROCEDURE IncErrPtr(VAR Ptr : errptr);
  VAR Len : INTEGER;
 BEGIN
  Len := Str.Length(Ptr.ErrStr) + 1;
  IF ODD(Len) THEN INC(Len) END(*IF*);
  Ptr := S.ADR(Ptr.ErrStr[Len]);
 END IncErrPtr;

PROCEDURE Init;
  VAR Ptr : errptr;
      ErrNo : INTEGER;
 BEGIN
  IF NOT Inited THEN
    Ptr := S.ADR(error1);
    ErrNo := -1;
    LOOP
      Ptr.ErrorNo := ErrNo;
      IF ErrNo = listend THEN EXIT END;
      IncErrPtr(Ptr); DEC(ErrNo);
      IF ErrNo = -9 THEN ErrNo := -10
      ELSIF ErrNo = -18 THEN ErrNo := -32
      ELSIF ErrNo = -38 THEN ErrNo := -39
      ELSIF ErrNo = -41 THEN ErrNo := -46
      ELSIF ErrNo = -47 THEN ErrNo := -49
      ELSIF ErrNo = -50 THEN ErrNo := -64
      ELSIF ErrNo = -68 THEN ErrNo := -100
      ELSIF ErrNo = -101 THEN ErrNo := listend
      END(*IF*);
    END(*LOOP*);
    Inited := TRUE;
  END(*IF*);
 END Init;

PROCEDURE FindErrNum(ErrNo : INTEGER; VAR Ptr : errptr) : BOOLEAN;
 BEGIN
  Init;
  Ptr := S.ADR(error1);
  REPEAT
    IF Ptr.ErrorNo = ErrNo THEN RETURN TRUE END(*IF*);
    IncErrPtr(Ptr);
  UNTIL Ptr.ErrorNo = listend;
  RETURN FALSE
 END FindErrNum;

PROCEDURE DoAlert(VAR s : ARRAY OF CHAR; errNo : INTEGER);
  VAR Button : INTEGER;
      addr   : LONGINT;
 BEGIN
  Str.Insert('[1][',0,s); Str.Append('][Weiter|Abbruch|Halt]',s);
  Button := Form.Alert(1,s);
  IF Button = 3 THEN
    HALT(99);
  ELSIF (Button = 2) AND (Sys.Basepage.Parent # 0) THEN
    Task.Exit(-1)
  END(*IF*);
  NoErr := FALSE;
 END DoAlert;

PROCEDURE NumOut* (Nr : INTEGER);
  (* shows a standard TOS error *)
  VAR s   : ARRAY 128 OF CHAR;
      s2  : ARRAY 10 OF CHAR;
      Ptr : errptr;
 BEGIN
  NoErr := TRUE;
  IF Nr < 0 THEN
    IF FindErrNum(Nr,Ptr) THEN COPY(Ptr.ErrStr,s);
    ELSE s := 'Fehler Nr '; NStr.IntTo(Nr,10,s2); Str.Append(s2,s) END;
    DoAlert(s, Nr);
  END(*IF*);
 END NumOut;

PROCEDURE StrOut* (ErrStr : ARRAY OF CHAR);
  (* shows a user defined error message *)
  VAR s : ARRAY 128 OF CHAR;
 BEGIN
  COPY(ErrStr,s); DoAlert(s, -1);
 END StrOut;

PROCEDURE NumStrOut* (Nr : INTEGER; AddStr : ARRAY OF CHAR);
  (* as NumOut, but AddStr is added where "**" is found in the error string *)
  VAR s   : ARRAY 128 OF CHAR;
      s2  : ARRAY 10 OF CHAR;
      i   : INTEGER;
      Ptr : errptr;
 BEGIN
  NoErr := TRUE;
  IF Nr < 0 THEN
    IF FindErrNum(Nr,Ptr) THEN
      COPY(Ptr.ErrStr,s); i := Str.FPos('**',s);
      IF i >= 0 THEN
        Str.Delete(i,i+2,s); Str.Insert(AddStr,i,s);
      END(*IF*);
    ELSE
      s := 'Fehler Nr '; NStr.IntTo(Nr,10,s2); Str.Append(s2,s);
    END(*IF*);
    DoAlert(s, Nr);
  END(*IF*);
 END NumStrOut;

END Error.
