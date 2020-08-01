MODULE Key;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |15.5.93  |started
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, Task;

CONST
  shift* = 1; control* = 2; alternate* = 3;

TYPE
  proc   = PROCEDURE;
  keyptr = POINTER TO keys;
  keys   = RECORD
             Prev : keyptr;
             Keys : ARRAY 8,120 OF proc;
           END;

VAR
  ShiftBits* : SET;
  Scancode*  : INTEGER;
  (* the key combination that called the procedure *)
  FirstFC  : keys;
  FuncKeys : keyptr;

PROCEDURE ShiftIndex(Shift : SET) : INTEGER;
 BEGIN
  RETURN SHORT( S.ANL( S.VAL(LONGINT,Shift) DIV 2, 7) ); 
 END ShiftIndex;
 
PROCEDURE Call*(Shift : SET; Scan : INTEGER) : BOOLEAN;
  VAR Proc : proc;
 BEGIN
  Proc := FuncKeys.Keys[ShiftIndex(Shift)][Scan];
  IF Proc # NIL THEN ShiftBits := Shift; Scancode := Scan;
    Proc 
  END;
  RETURN Proc # NIL;
 END Call;
 
PROCEDURE Assign*(Shift : SET; Scan : INTEGER; Proc : proc);
 BEGIN
  FuncKeys.Keys[ShiftIndex(Shift)][Scan] := Proc;
 END Assign;

PROCEDURE* Init;
  VAR fc : keyptr;
 BEGIN
  NEW(fc); fc.Keys := FuncKeys.Keys; fc.Prev := FuncKeys;
  FuncKeys := fc;
 END Init;
 
PROCEDURE* Exit;
 BEGIN
  IF Task.Current # 0 THEN FuncKeys := FuncKeys.Prev END;
 END Exit;
 
BEGIN
  Task.StoreInit(Init); Task.StoreExit(Exit); 
  FuncKeys := S.ADR(FirstFC);
END Key.