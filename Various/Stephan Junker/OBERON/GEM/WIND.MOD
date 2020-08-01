MODULE Wind;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |30.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, AES, DCL:=DoubleChainedList, Error, Task, Appl;

CONST (* element bits *)
  TITLE* = 0; CLOSER* = 1; FULLER* = 2; MOVER* = 3; INFOLINE* = 4;
  SIZER* = 5; UPARROW* = 6; DNARROW* = 7; VSLIDER* = 8; LFARROW* = 9;
  RTARROW* = 10; HSLIDER* = 11;

  (* get/set types *)
  ELEMENTS* = 1; NAME* = 2; INFO* = 3; WORK* = 4; CURR* = 5; PREV* = 6;
  FULL* = 7; HSLIDE* = 8; VSLIDE* = 9; TOP* = 10; FIRST* = 11; NEXT* = 12;
  NEWDESK* = 14; HSLSIZE* = 15; VSLSIZE* = 16; SCREEN* = 17;

  (* update type *)
  ENDUPD* = 0; BEGUPD* = 1; ENDMCTRL* = 2; BEGMCTRL* = 3;

  (* calc type *)
  WHOLE* = 0; WORKSP* = 1;

TYPE info*   = POINTER TO desc;
     desc*   = RECORD (DCL.elem) Opened* : BOOLEAN END;

VAR First* : info;
    Updat,Mouse : BOOLEAN;

PROCEDURE Search*(Handle : INTEGER; VAR Info : info) : BOOLEAN;
 (* searches for the window with AES handle Handle. Returns FALSE if not
    found *)
 BEGIN
  RETURN DCL.Search(First,Handle,Info)
 END Search;

PROCEDURE GetInfo*(Handle : INTEGER; VAR Info : info) : BOOLEAN;
 (* same as Search, buts shows an error if not found *)
 BEGIN
  IF DCL.Search(First,Handle,Info) AND (Info.Task = Task.Current) THEN
    RETURN TRUE
  END(*IF*);
(*  Error.NumOut(-100); *)RETURN FALSE
 END GetInfo;

PROCEDURE Create*(Elements : SET; X,Y,W,H : INTEGER; w : info) : BOOLEAN;
 (* tells AES to create a new window. If it has no windows left, an error
    message is shown and FALSE returned. w must be initialized, because
    Create does not know which extended type it points to. It serves as
    a replace for the AES window handle. If the AES handle is needed, it
    can be found in w.Handle. The current process number is stored and all
    procedures in this module check if a window belongs to the calling
    process *)
 BEGIN
  AES.IntIn[0] := SHORT(S.VAL(LONGINT,Elements));
  AES.IntIn[1] := X; AES.IntIn[2] := Y;
  AES.IntIn[3] := W; AES.IntIn[4] := H;
  AES.Call(64050100H); w.Handle := AES.IntOut[0];
  IF w.Handle > 0 THEN DCL.New(First,w,w.Handle); w.Opened := FALSE;
    RETURN TRUE
  END(*IF*);
  Error.StrOut("no more windows"); RETURN FALSE
 END Create;

PROCEDURE Open*(w : info; X,Y,W,H : INTEGER);
 (* opens a window that was created before. An error message is shown,
    if the window is already opened *)
 BEGIN
  IF w.Opened THEN Error.NumOut(-100)
  ELSE
    w.Opened := TRUE; AES.IntIn[0] := w.Handle;
    AES.IntIn[1] := X; AES.IntIn[2] := Y;
    AES.IntIn[3] := W; AES.IntIn[4] := H;
    AES.Call(65050100H);
  END(*IF*);
 END Open;

PROCEDURE Close*(w : info);
 (* closes a window so that it can be reopened *)
 BEGIN
  IF w.Opened THEN
    w.Opened := FALSE; AES.IntIn[0] := w.Handle; AES.Call(66010100H);
  ELSE Error.NumOut(-100)
  END(*IF*);
 END Close;

PROCEDURE Delete*(w : info);
 (* deletes a window which cannot be reopened afterwards *)
 BEGIN
  DCL.Extract(First,w);
  IF w.Opened THEN Close(w) END;
  AES.IntIn[0] := w.Handle; AES.Call(67010100H);
 END Delete;

(* The Get?/Set? procedures are derived from the AES wind_get/wind_set
   procedures *)

PROCEDURE GetXYWH*(wn : info; Type : INTEGER; VAR x,y,w,h : INTEGER);
 (* Type can be WORK, CURR, PREV, FULL, FIRST or NEXT *)
 BEGIN
  AES.IntIn[0] := wn.Handle; AES.IntIn[1] := Type;
  AES.Call(68020500H);
  x := AES.IntOut[1]; y := AES.IntOut[2];
  w := AES.IntOut[3]; h := AES.IntOut[4];
 END GetXYWH;

PROCEDURE GetVal*(w : info; Type : INTEGER) : INTEGER;
 (* Type can be HSLIDE, VSLIDE, HSLSIZE or VSLSIZE. Returns position or size *)
 BEGIN
  AES.IntIn[0] := w.Handle; AES.IntIn[1] := Type;
  AES.Call(68020500H); RETURN AES.IntOut[1];
 END GetVal;

PROCEDURE GetTop*(VAR w : info) : BOOLEAN;
 (* returns the top window. FALSE means no window open or top window
    belonging to a different process *)
  VAR Handle : INTEGER;
 BEGIN
  AES.IntIn[0] := 0; AES.IntIn[1] := TOP;
  AES.Call(68020500H); Handle := AES.IntOut[1];
  RETURN (Handle > 0) AND Search(Handle,w)
 END GetTop;

PROCEDURE SetElements*(w : info; Elements : SET);
 (* set the elements of a window *)
 BEGIN
  AES.IntIn[0] := w.Handle; AES.IntIn[1] := ELEMENTS;
  AES.IntIn[2] := SHORT(S.VAL(LONGINT,Elements));
  AES.Call(69060100H);
 END SetElements;

PROCEDURE SetAddress*(w : info; Type : INTEGER; Address : LONGINT);
 (* Type can be NAME,INFO or NEWDESK *)
 BEGIN
  AES.IntIn[0] := w.Handle; AES.IntIn[1] := Type;
  AES.IntIn[2] := SHORT(Address DIV 10000H); AES.IntIn[3] := SHORT(Address);
  AES.Call(69060100H);
 END SetAddress;

PROCEDURE SetCurr*(wn : info; x,y,w,h : INTEGER);
 (* set current size of a window *)
 BEGIN
  AES.IntIn[0] := wn.Handle; AES.IntIn[1] := CURR;
  AES.IntIn[2] := x; AES.IntIn[3] := y;
  AES.IntIn[4] := w; AES.IntIn[5] := h;
  AES.Call(69060100H);
 END SetCurr;

PROCEDURE SetVal*(w : info; Type,Val : INTEGER);
 (* Type can be HSLIDE,VSLIDE,HSLSIZE or VSLSIZE *)
 BEGIN
  AES.IntIn[0] := w.Handle; AES.IntIn[1] := Type;
  AES.IntIn[2] := Val; AES.Call(69060100H);
 END SetVal;

PROCEDURE SetTop*(w : info);
 (* Type can be HSLIDE,VSLIDE,HSLSIZE or VSLSIZE *)
 BEGIN
  AES.IntIn[0] := w.Handle; AES.IntIn[1] := TOP;
  AES.Call(69060100H);
 END SetTop;

PROCEDURE Find*(X,Y : INTEGER; VAR w : info) : BOOLEAN;
 (* finds window under the position X,Y. Returns FALSE if no window there *)
  VAR h : INTEGER;
 BEGIN
  AES.IntIn[0] := X; AES.IntIn[1] := Y;
  AES.Call(6A020100H); h := AES.IntOut[0];
  RETURN (h > 0) AND Search(h,w)
 END Find;

PROCEDURE Update*(Type : INTEGER);
 BEGIN
  CASE Type OF
    BEGUPD : Updat := TRUE |
    ENDUPD : Updat := FALSE |
    BEGMCTRL : Mouse := TRUE |
    ENDMCTRL : Mouse := FALSE |
  END(*CASE*);
  AES.IntIn[0] := Type; AES.Call(6B010100H);
 END Update;

PROCEDURE Calc*(Type : INTEGER; Elements : SET; InX,InY,InW,InH : INTEGER;
                VAR OutX,OutY,OutW,OutH : INTEGER);
 (* calculates the whole or work space of a window *)
 BEGIN
  AES.IntIn[0] := Type; AES.IntIn[1] := SHORT(S.VAL(LONGINT,Elements));
  AES.IntIn[2] := InX; AES.IntIn[3] := InY;
  AES.IntIn[4] := InW; AES.IntIn[5] := InH;
  AES.Call(6C060500H);
  OutX := AES.IntOut[1]; OutY := AES.IntOut[2];
  OutW := AES.IntOut[3]; OutH := AES.IntOut[4];
 END Calc;

PROCEDURE* Delete2(w : info);
 BEGIN
  IF w.Opened THEN Close(w) END;
  AES.IntIn[0] := w.Handle; AES.Call(67010100H);
 END Delete2;

PROCEDURE* CloseAll;
 BEGIN
  IF Task.Closed THEN First := NIL
  ELSE
    DCL.DeleteTask(First,Task.Current,Delete2);
    IF Updat THEN Update(ENDUPD) END;
    IF Mouse THEN Update(ENDMCTRL) END;
  END;
 END CloseAll;

BEGIN
  Task.StoreExit(CloseAll);
END Wind.
