MODULE Coroutines; (* SJ 9.12.94 *)

(*
 Module Coroutines provides non-preemptive threads each with its
 own stack but otherwise sharing a common address space.
 Coroutines can explicitly transfer control to other coroutines
 which are then resumed from the point where they did their last
 transfer of control.

Operations

ú Init(p, s, c)   creates and initialises a new coroutine c with a
                  stack of s bytes and a body provided as the procedure
                  p.  An initialised coroutine can be started by a
                  Transfer to it.  In this case its execution will start
                  at the first instruction of p. Procedure p must never
                  return.

ú Transfer(f, t)  transfers control from the currently executing
                  coroutine to the coroutine t. The state of the currently
                  executing coroutine is saved in f.  When control is
                  transferred back to f later, f will be restarted in the
                  saved state.

Source:

Proposed by Prof Hanspeter M”ssenb”ck, ETH.
 *)


IMPORT
  S:=SYSTEM, Sys;


TYPE
  Coroutine* = RECORD
    regs: ARRAY 16 OF LONGINT;
    address, stack: S.PTR;
    stackSize: LONGINT;
    codeAddress-: S.PTR;  (* Non standard extension. Do not use! *)
  END;
  Body* = PROCEDURE;



PROCEDURE Init* (body: Body; stackSize: LONGINT;
          VAR cor: Coroutine);
 BEGIN
  S.NEW( cor.stack, stackSize);
  cor.address := S.VAL( LONGINT, body);
  cor.codeAddress := S.VAL( LONGINT, body);
  cor.stackSize := stackSize;
 END Init;


PROCEDURE Transfer* (VAR from, to: Coroutine);
 BEGIN
  from.stack := Sys.stackEnd-1000;
  from.stackSize := Sys.stackSize+1000;
  Sys.stackEnd := to.stack+1000;
  Sys.stackSize := to.stackSize-1000;
  ASSEMBLER
    MOVE.L from,A0
    MOVEM.L D0-A7,(A0)    ; save registers
    CLR.L 64(A0)          ; from.address := NIL
    MOVE.L to,A0
    TST.L 64(A0)          ; to.address = NIL?
    BEQ Resume            ; yes -> was already used
    MOVE.L 68(A0),SP      ; no: first start
    ADD.L 72(A0),SP
    MOVE.L 64(A0),A0
    JMP (A0)
  Resume:
    MOVEM.L (A0),D0-A7    ; the following UNLK A6 restarts to
  END;
 END Transfer;


PROCEDURE Dispose* (VAR co: Coroutine);
(*
 Free the stack memory of co.
 (Additional procedure by SJ)
 *)
 BEGIN
  S.DISPOSE( co.stack);
 END Dispose;


END Coroutines.

