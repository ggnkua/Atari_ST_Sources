MODULE VDIInput;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |30.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM,VDI,Task,Error, DCL:=DoubleChainedList;

TYPE proc = PROCEDURE();
     vector = POINTER TO RECORD(DCL.elem) Prv : proc END;

VAR MouseOff : INTEGER;
    ButVecs,CurVecs,MotVecs,TimVecs : vector;

PROCEDURE VexButv*(Handle : INTEGER; Proc : proc);
  VAR v : vector;
 BEGIN
  VDI.Contrl.Misc[0] := SHORT(S.VAL(LONGINT,Proc) DIV 10000H);
  VDI.Contrl.Misc[1] := SHORT(S.VAL(LONGINT,Proc));
  VDI.Call(125,0,Handle,0);
  NEW(v); DCL.New(ButVecs,v,Handle);
  v.Prv := S.VAL(proc, VDI.Contrl.Misc[2] * 10000H + VDI.Contrl.Misc[3] )
 END VexButv;

PROCEDURE VexCurv*(Handle : INTEGER; Proc : proc);
  VAR v : vector;
 BEGIN
  VDI.Contrl.Misc[0] := SHORT(S.VAL(LONGINT,Proc) DIV 10000H);
  VDI.Contrl.Misc[1] := SHORT(S.VAL(LONGINT,Proc));
  VDI.Call(127,0,Handle,0);
  NEW(v); DCL.New(CurVecs,v,Handle);
  v.Prv := S.VAL(proc, VDI.Contrl.Misc[2] * 10000H + VDI.Contrl.Misc[3] )
 END VexCurv;

PROCEDURE VexMotv*(Handle : INTEGER; Proc : proc);
  VAR v : vector;
 BEGIN
  VDI.Contrl.Misc[0] := SHORT(S.VAL(LONGINT,Proc) DIV 10000H);
  VDI.Contrl.Misc[1] := SHORT(S.VAL(LONGINT,Proc));
  VDI.Call(126,0,Handle,0);
  NEW(v); DCL.New(MotVecs,v,Handle);
  v.Prv := S.VAL(proc, VDI.Contrl.Misc[2] * 10000H + VDI.Contrl.Misc[3] )
 END VexMotv;

PROCEDURE VexTimv*(Handle : INTEGER; Proc : proc);
  VAR v : vector;
 BEGIN
  VDI.Contrl.Misc[0] := SHORT(S.VAL(LONGINT,Proc) DIV 10000H);
  VDI.Contrl.Misc[1] := SHORT(S.VAL(LONGINT,Proc));
  VDI.Call(118,0,Handle,0);
  NEW(v); DCL.New(TimVecs,v,Handle);
  v.Prv := S.VAL(proc, VDI.Contrl.Misc[2] * 10000H + VDI.Contrl.Misc[3] )
 END VexTimv;

PROCEDURE VsinMode*(Handle,DevType,Mode : INTEGER) : INTEGER;
 BEGIN
  VDI.Intin[0] := DevType; VDI.Intin[1] := Mode;
  VDI.Call(33,0,Handle,201H); RETURN VDI.Intout[0];
 END VsinMode;

PROCEDURE VrqChoice*(Handle,ChoiceIn : INTEGER) : INTEGER;
 BEGIN
  VDI.Intin[0] := ChoiceIn; VDI.Call(30,0,Handle,101H);
  RETURN VDI.Intout[0];
 END VrqChoice;

PROCEDURE VsmChoice*(Handle : INTEGER; VAR Choice : INTEGER) : BOOLEAN;
 BEGIN
  VDI.Call(30,0,Handle,1H); Choice := VDI.Intout[0];
  RETURN S.VAL(BOOLEAN, SHORT(VDI.Contrl.SizeIntout) );
 END VsmChoice;

PROCEDURE VsmLocator*(Handle,x,y : INTEGER; VAR xout,yout,Term : INTEGER) : SET;
 BEGIN
  VDI.Ptsin[0] := x; VDI.Ptsin[1] := y;
  VDI.Call(28,0,Handle,201H);
  xout := VDI.Ptsout[0]; yout := VDI.Ptsout[1]; Term := VDI.Intout[0];
  RETURN S.VAL(SET, LONG(ASH(VDI.Contrl.SizeIntout,1) + VDI.Contrl.SizePtsout) );
 END VsmLocator;

PROCEDURE VrqLocator*(Handle,x,y : INTEGER; VAR xout,yout,Term : INTEGER);
  VAR d : SET;
 BEGIN
  d := VsmLocator(Handle,x,y,xout,yout,Term);
 END VrqLocator;

PROCEDURE VsmString*(Handle : INTEGER; Echo : BOOLEAN; x,y : INTEGER;
                     VAR String : ARRAY OF CHAR) : INTEGER;
  VAR i,Len : INTEGER;
 BEGIN
  VDI.Intin[0] := LEN(String)-1;
  VDI.Intin[1] := LONG( S.VAL(SHORTINT,Echo) );
  VDI.Ptsin[0] := x; VDI.Ptsin[1] := y;
  VDI.Call(31,0,Handle,1000200H);
  i := 0; Len := VDI.Contrl.SizeIntout;
  WHILE i < Len DO String[i] := CHR(VDI.Intout[i]); INC(i) END;
  String[i] := 0X;
  RETURN VDI.Contrl.SizeIntout;
 END VsmString;

PROCEDURE VrqString*(Handle : INTEGER; Echo : BOOLEAN; x,y : INTEGER;
                     VAR String : ARRAY OF CHAR);
  VAR d : INTEGER;
 BEGIN
  d := VsmString(Handle,Echo,x,y,String);
 END VrqString;

PROCEDURE VsmValuator*(Handle,ValIn : INTEGER; VAR ValOut,Term : INTEGER)
                       : INTEGER;
 BEGIN
  VDI.Intin[0] := ValIn; VDI.Call(29,0,Handle,100H);
  ValOut := VDI.Intout[0]; Term := VDI.Intout[1];
  RETURN VDI.Contrl.SizeIntout;
 END VsmValuator;

PROCEDURE VrqValuator*(Handle,ValIn : INTEGER; VAR ValOut,Term : INTEGER);
  VAR d : INTEGER;
 BEGIN
  d := VsmValuator(Handle,ValIn,ValOut,Term);
 END VrqValuator;

PROCEDURE VscForm*(Handle : INTEGER; VAR MouseForm : ARRAY OF INTEGER);
 BEGIN
  VDI.ParmBlk.Intin := S.ADR(MouseForm);
  VDI.Call(111,0,Handle,2500H);
  VDI.ParmBlk.Intin := S.ADR(VDI.Intin);
 END VscForm;

PROCEDURE VShowC*(Handle : INTEGER; Normal : BOOLEAN);
 BEGIN
  IF MouseOff = 0 THEN Error.NumOut(-100)
  ELSE IF NOT Normal THEN MouseOff := 1 END;
    DEC(MouseOff);
    IF MouseOff = 0 THEN
      VDI.Intin[0] := 1; VDI.Call(122,0,Handle,100H);
    END(*IF*);
  END(*IF*);
 END VShowC;

PROCEDURE VHideC*(Handle : INTEGER);
 BEGIN
  IF MouseOff = 0 THEN VDI.Call(123,0,Handle,0) END;
  INC(MouseOff);
 END VHideC;

PROCEDURE VqMouse*(Handle : INTEGER; VAR Buttons : SET; VAR Mx,My : INTEGER);
 BEGIN
  VDI.Call(124,0,Handle,101H);
  Buttons := S.VAL(SET, LONG(VDI.Intout[0]) );
  Mx := VDI.Ptsout[0]; My := VDI.Ptsout[1];
 END VqMouse;

PROCEDURE VqKeyS*(Handle : INTEGER) : SET;
 BEGIN
  VDI.Call(128,0,Handle,1);
  RETURN S.VAL(SET, LONG(VDI.Intout[0]) );
 END VqKeyS;

PROCEDURE CallPrevBut*;
  VAR v : vector;
 BEGIN
  IF DCL.SearchTask( ButVecs,Task.Current,v ) THEN v.Prv END;
 END CallPrevBut;

PROCEDURE CallPrevCur*;
  VAR v : vector;
 BEGIN
  IF DCL.SearchTask( CurVecs,Task.Current,v ) THEN v.Prv END;
 END CallPrevCur;

PROCEDURE CallPrevMot*;
  VAR v : vector;
 BEGIN
  IF DCL.SearchTask( MotVecs,Task.Current,v ) THEN v.Prv END;
 END CallPrevMot;

PROCEDURE CallPrevTim*;
  VAR v : vector;
 BEGIN
  IF DCL.SearchTask( TimVecs,Task.Current,v ) THEN v.Prv END;
 END CallPrevTim;

PROCEDURE* Unchain(v : vector);
  VAR Handle : INTEGER; v2 : vector;
 BEGIN
  IF v.Prev = NIL THEN
    VDI.Contrl.Misc[0] := SHORT(S.VAL(LONGINT,v.Prv) DIV 10000H);
    VDI.Contrl.Misc[1] := SHORT(S.VAL(LONGINT,v.Prv));
    IF v.Next # NIL THEN Handle := v.Next.Handle ELSE Handle := 1 END;
    VDI.Call(127,0,Handle,0);
  ELSE
    v2 := v.Prev; v2.Prv := v.Prv
  END;
 END Unchain;

PROCEDURE* Kill;
 BEGIN
  IF MouseOff # 0 THEN VShowC(1,FALSE) END;
  DCL.DeleteTask(ButVecs,Task.Current,Unchain);
  DCL.DeleteTask(CurVecs,Task.Current,Unchain);
  DCL.DeleteTask(MotVecs,Task.Current,Unchain);
  DCL.DeleteTask(TimVecs,Task.Current,Unchain);
 END Kill;

BEGIN
  Task.StoreExit(Kill);
END VDIInput.
