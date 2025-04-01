(* Listing 6 *)

MODULE LIFOTest;
(* programmed by P.Costanza *)
(* Date : 16:44   4. 2.1991 *)

IMPORT InOut, LIFO, MOBS;

TYPE INTNode = RECORD
                 ID    : MOBS.CLASS;
                 NEXT  : LIFO.Stack;
                 VALUE : INTEGER
               END;
     CHRNode = RECORD
                 ID    : MOBS.CLASS;
                 NEXT  : LIFO.Stack;
                 VALUE : CHAR
               END;

VAR INTNodeDef   : MOBS.CLASSDEF;
    INTNodeClass : MOBS.CLASS;
    CHRNodeDef   : MOBS.CLASSDEF;
    CHRNodeClass : MOBS.CLASS;

    Stack : LIFO.Stack;
    InI : INTNode; OutI : POINTER TO INTNode;
    InC : CHRNode; OutC : POINTER TO CHRNode;
    choice : CHAR;

PROCEDURE IntNotChr() : BOOLEAN;
VAR c : CHAR;
BEGIN InOut.WriteString
        (" Integer- or Charobject (I/C)? ");
      REPEAT InOut.Read(c); c := CAP(c)
      UNTIL (c = "I") OR (c = "C");
      InOut.WriteLn;
      RETURN c = "I"
END IntNotChr;

BEGIN INTNodeClass :=
        MOBS.NEW(INTNodeDef,
                 LIFO.NodeClass,
                 SIZE(INTNode));
      CHRNodeClass :=
        MOBS.NEW(CHRNodeDef,
                 LIFO.NodeClass,
                 SIZE(CHRNode));

      InI.ID := INTNodeClass;
      InI.NEXT := NIL;
      InI.VALUE := 0;

      InC.ID := CHRNodeClass;
      InC.NEXT := NIL;
      InC.VALUE := 0C;
      
      Stack := NIL; choice := "V";

      WHILE choice # "X" DO
        CASE choice OF
          "V" : InOut.WriteString
                  ("V = Verbose commands");
                InOut.WriteLn;
                InOut.WriteString
                  ("S = Push values");
                InOut.WriteLn;
                InOut.WriteString
                  ("P = Pull values");
                InOut.WriteLn;
                InOut.WriteString
                  ("L = Look values");
                InOut.WriteLn;
                InOut.WriteString
                  ("C = Clear stack");
                InOut.WriteLn;
                InOut.WriteString
                  ("H = HALT (Debug)");
                InOut.WriteLn;
                InOut.WriteString("X = Quit")
        | "S" : IF IntNotChr() THEN
                  InOut.WriteString("  >");
                  InOut.ReadInt(InI.VALUE);
                  LIFO.Push(Stack,InI.ID)
                ELSE
                  InOut.WriteString("  >");
                  InOut.Read(InC.VALUE);
                  LIFO.Push(Stack,InC.ID)
                END
        | "P" : LIFO.Pull(Stack);
                InOut.WriteString(" O.k.")
        | "L" : IF Stack # NIL THEN
                  OutI := MOBS.IS(Stack^.ID,
                                  INTNodeClass);
                  OutC := MOBS.IS(Stack^.ID,
                                  CHRNodeClass);
                  IF    OutI # NIL THEN
                    InOut.WriteString
                      (" Integerobject = ");
                    InOut.WriteInt(OutI^.VALUE,1)
                  ELSIF OutC # NIL THEN
                    InOut.WriteString
                      (" Charobject = ");
                    InOut.Write(OutC^.VALUE)
                  ELSE InOut.WriteString
                         (" Unknown object!")
                  END
                ELSE InOut.WriteString
                       (" Stack is empty!")
                END
        | "C" : LIFO.Clear(Stack);
                InOut.WriteString(" O.k.")
        | "H" : HALT; InOut.WriteString(" O.k.")
        ELSE END;
        InOut.WriteLn;
        InOut.Read(choice);
        choice := CAP(choice);
        InOut.WriteLn
      END(* WHILE *);

      LIFO.Clear(Stack)

END LIFOTest.


