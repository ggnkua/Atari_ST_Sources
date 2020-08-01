MODULE AES;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |9.1.93   |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S := SYSTEM;

TYPE global*  = RECORD
                  Version*, NumTasks*, ApId* : INTEGER;
                  Private*, Rsrcaddr* : LONGINT;
                  Rsrvd : ARRAY 8 OF INTEGER;
                END(*RECORD*);
     control* = RECORD
                  Opcode*, SizeIntIn*, SizeIntOut*,
                  SizeAddrIn*, SizeAddrOut*: INTEGER;
                END(*RECORD*);
     intin*   = ARRAY 20 OF INTEGER;
     intout*  = ARRAY 8 OF INTEGER;
     addrin*  = ARRAY 3 OF LONGINT;
     addrout* = ARRAY 2 OF LONGINT;
     param*   = RECORD
                  Control* : POINTER TO control;
                  Global*  : POINTER TO global;
                  IntIn*   : POINTER TO intin;
                  IntOut*  : POINTER TO intout;
                  AddrIn*  : POINTER TO addrin;
                  AddrOut* : POINTER TO addrout;
                END(*RECORD*);

VAR ParamBlk* : param;
    Global*   : global;
    Control*  : control;
    IntIn*    : intin;
    IntOut*   : intout;
    AddrIn*   : addrin;
    AddrOut*  : addrout;

PROCEDURE Call* (Parameter : LONGINT);
 BEGIN
  ASSEMBLER

	MOVE.L	#ParamBlk,D1
	MOVE.L	D1,A5
	MOVEA.L	(A5),A0
	CLR.L	(A0)
	CLR.L	4(A0)
	MOVE.L	8(A6),D0
	MOVEP.L	D0,1(A0)
	MOVE.W	#$C8,D0
	TRAP	#2

  END
 END Call;

BEGIN
  ParamBlk.Control := S.ADR(Control);
  ParamBlk.Global := S.ADR(Global);
  ParamBlk.IntIn := S.ADR(IntIn);
  ParamBlk.IntOut := S.ADR(IntOut);
  ParamBlk.AddrIn := S.ADR(AddrIn);
  ParamBlk.AddrOut := S.ADR(AddrOut);
  Control.SizeAddrOut := 0;
END AES.
