(* Listing 5 *)

DEFINITION MODULE LIFO;
(* programmed by P.Costanza *)
(* Date :  0:15  14. 9.1990 *)

  IMPORT MOBS;

  TYPE Stack = POINTER TO Node;
       Node = RECORD
                ID   : MOBS.CLASS;
                NEXT : Stack
              END;

  VAR NodeClass : MOBS.CLASS;

  PROCEDURE Init(VAR s : Node);
  PROCEDURE Push(VAR s : Stack;
                 VAR NodeID : MOBS.CLASS);
  PROCEDURE Pull(VAR s : Stack);
  PROCEDURE Clear(VAR s : Stack);

END LIFO.

IMPLEMENTATION MODULE LIFO;
(* programmed by P.Costanza *)
(* Date : 20: 6  24.11.1990 *)

  IMPORT MOBS;

  VAR NodeDef : MOBS.CLASSDEF;

  PROCEDURE Init(VAR s : Node);
  BEGIN s.ID := NodeClass; s.NEXT := NIL
  END Init;

  PROCEDURE Push(VAR s : Stack;
                 VAR NodeID : MOBS.CLASS);
  VAR m : Stack;
  BEGIN IF MOBS.IS(NodeID, NodeClass) # NIL THEN
          MOBS.ASSIGN(m,NodeID);
          IF m # NIL THEN
            m^.NEXT := s; s := m
          END
        END
  END Push;

  PROCEDURE Pull(VAR s : Stack);
  VAR m : Stack;
  BEGIN IF s # NIL THEN
          m := s^.NEXT;
          MOBS.FREE(s); s := m
        END
  END Pull;

  PROCEDURE Clear(VAR s : Stack);
  VAR m : Stack;
  BEGIN WHILE s # NIL DO
          m := s^.NEXT;
          MOBS.FREE(s); s := m
        END
  END Clear;

BEGIN NodeClass :=
        MOBS.NEW(NodeDef,NIL,SIZE(Stack))
END LIFO.



