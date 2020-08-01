MODULE TOSRUN;

(*
 * tool to run TOS programs on Mag!X and Chatwin.
 * Don't run any other TOS programs parallel!
 * Don't link it, it works just under the loader with Chatwin!
 * This module makes it possible to run a TOS program with
 * Chatwins environment and with its output in Chatwins CLI window.
 *)

IMPORT
  S:=SYSTEM, Task, XBIOS, Sys, CL:=CommandLine, IO:=CHATIO, Str:=Strings,
  Error, GEMDOS;


TYPE
  msg    = RECORD
             Type : INTEGER;
             Ptr  : S.PTR;
             Char : INTEGER;
             Env  : S.PTR;
           END;


VAR
  message     : msg;


(*$-c *)

PROCEDURE XConOut;
 BEGIN
  ASSEMBLER

    DC.L 'XBRA','TOSR'
OldXConOut*:  DC.L 0

NewXConOut*:
    LEA   message,A0
    MOVE  6(SP),6(A0)
    MOVE.L  IO.SendMsg,A0
    MOVE.L  #message,-(SP)
    JSR  (A0)
    ADDQ  #4,SP
    RTS

  END;
 END XConOut;


PROCEDURE LinkXConOut;
 BEGIN
  ASSEMBLER
    MOVE.L  $586.W,OldXConOut
    MOVE.L  #NewXConOut,$586.W
    RTS
  END;
 END LinkXConOut;


PROCEDURE UnlinkXConOut;
 BEGIN
  ASSEMBLER
    MOVE.L  OldXConOut,$586.W
    RTS
  END;
 END UnlinkXConOut;

(*$+c *)

PROCEDURE CallUnlinkXConOut;
 BEGIN
  XBIOS.Supexec(UnlinkXConOut);
 END CallUnlinkXConOut;


PROCEDURE LaunchProgram;
  VAR
    prg,cmd : ARRAY 120 OF CHAR;
    bp      : Sys.basepage;
    ret     : LONGINT;
 BEGIN
  cmd[0] := 0X; cmd[1] := 0X; (* no cmd *)
  COPY(CL.arg^, prg);
  CL.Next;
  WHILE CL.arg # NIL DO
    Str.AppendC(" ", cmd);
    Str.Append(CL.arg^, cmd);
    CL.Next;
  END;
  IF cmd[0] # 0X THEN
    cmd[0] := CHR( Str.Length(cmd) - 1);
  END;
  XBIOS.Supexec(LinkXConOut);
  Task.StoreExit(CallUnlinkXConOut);
  IO.BufferOff;
  message.Type := 6503H;
  ret := GEMDOS.Pexec( Sys.Basepage.Env, S.ADR(cmd), S.ADR( prg), 0);
  IF ret < 0 THEN
    Error.NumStrOut( SHORT(ret), prg);
  END;
 END LaunchProgram;


PROCEDURE Run*;
 BEGIN
  IF CL.arg # NIL THEN
    LaunchProgram;
  ELSE
    IO.WriteString("Usage: tosrun <tos-prog> [<command>]"); IO.WriteLn;
  END;
 END Run;


END TOSRUN.