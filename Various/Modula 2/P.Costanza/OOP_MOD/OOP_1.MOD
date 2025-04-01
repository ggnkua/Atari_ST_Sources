(* Listing 1 *)

DEFINITION MODULE MOBS;
(* programmed by P.Costanza *)
(* Date : 19:51  24.11.1990 *)

IMPORT SYSTEM;

TYPE CLASS;

     CLASSDEF = RECORD SUPER : CLASS;
                       SIZE  : LONGINT
                END;

PROCEDURE NEW(VAR DEF   : CLASSDEF;
                  SUPER : CLASS;
                  SIZE  : LONGINT) : CLASS;

PROCEDURE IS(VAR ObId  : CLASS;
                 Class : CLASS) : SYSTEM.ADDRESS;

PROCEDURE LET(VAR DestinId,
                  SourceId : CLASS) : BOOLEAN;

PROCEDURE ASSIGN(VAR ObPtr : SYSTEM.ADDRESS;
                 VAR ObId : CLASS);

PROCEDURE FREE(VAR ObPtr : SYSTEM.ADDRESS);

END MOBS.

IMPLEMENTATION MODULE MOBS;
(* programmed by P.Costanza *)
(* Date : 19:56  24.11.1990 *)

IMPORT SYSTEM, BasicLib, Storage;
  
TYPE CLASS = POINTER TO CLASSDEF;

PROCEDURE NEW(VAR DEF   : CLASSDEF;
                  SUPER : CLASS;
                  SIZE  : LONGINT) : CLASS;
BEGIN
  DEF.SUPER := SUPER;
  DEF.SIZE := SIZE;
  RETURN SYSTEM.ADR(DEF)
END NEW;

PROCEDURE IS(VAR ObId  : CLASS;
                 Class : CLASS) : SYSTEM.ADDRESS;
  VAR c : CLASS;
BEGIN c := ObId;
  WHILE (c # NIL) & (c # Class) DO
    c := c^.SUPER
  END;
  IF c = NIL THEN RETURN NIL
    ELSE RETURN SYSTEM.ADR(ObId)
  END
END IS;

PROCEDURE LET(VAR DstId,
                  SrcId : CLASS) : BOOLEAN;
  VAR IdMem : CLASS;
BEGIN
  IF IS(SrcId,DstId) # NIL THEN
    IdMem := DstId;
    BasicLib.BMOVE( SYSTEM.ADR(SrcId),
                    SYSTEM.ADR(DstId),
                    DstId^.SIZE );
    DstId := IdMem;
    RETURN TRUE
  ELSE RETURN FALSE
  END
END LET;

PROCEDURE ASSIGN(VAR ObPtr : SYSTEM.ADDRESS;
                 VAR ObId  : CLASS);
BEGIN
  IF Storage.Available(ObId^.SIZE) THEN
    Storage.ALLOCATE(ObPtr,ObId^.SIZE);
    BasicLib.BMOVE( SYSTEM.ADR(ObId),ObPtr,
                    ObId^.SIZE )
  ELSE ObPtr := NIL
  END
END ASSIGN;
  
PROCEDURE FREE(VAR ObPtr : SYSTEM.ADDRESS);
BEGIN Storage.DEALLOCATE(ObPtr)
END FREE;

(* Diese Prozedur muss durch folgende ersetzt
   werden, falls Storage.DEALLOCATE die Angabe
   einer Groesse erfordert:

PROCEDURE FREE(VAR ObPtr : SYSTEM.ADDRESS);
  VAR c : CLASS;
BEGIN c := ObPtr;
  Storage.DEALLOCATE(ObPtr,c^.SIZE)
END FREE;
*)

END MOBS.


