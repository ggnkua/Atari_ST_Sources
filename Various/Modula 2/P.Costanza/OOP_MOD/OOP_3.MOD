(* Listing 3 *)

DEFINITION MODULE Box;

  IMPORT MOBS, Point;

  TYPE Type = RECORD
                ID   : MOBS.CLASS;
                x, y : INTEGER;
                w, h : INTEGER
              END;

  PROCEDURE INIT(VAR b : Type;
                     x, y, w, h : INTEGER);
  PROCEDURE DRAW(VAR BoxID : MOBS.CLASS);

  VAR Class : MOBS.CLASS;
(* Subclass of Point.Class *)

END Box.

IMPLEMENTATION MODULE Box;

  IMPORT BasicLib, MOBS, Point;

  TYPE BPtr = POINTER TO Type;

  VAR BoxDef : MOBS.CLASSDEF;

  PROCEDURE DRAW(VAR ID : MOBS.CLASS);
  VAR b : BPtr;
  BEGIN b := MOBS.IS(ID, Class);
        IF b # NIL
        THEN BasicLib.BOX(b^.x,b^.y,
                          b^.x+b^.w,b^.y+b^.h)   
        END
  END DRAW;

  PROCEDURE INIT(VAR b : Type;
                     x, y, w, h : INTEGER);
  BEGIN b.ID := Class;
        b.x := x; b.y := y; b.w := w; b.h := h
  END INIT;

BEGIN Class :=
        MOBS.NEW(BoxDef,Point.Class,SIZE(Type))
END Box.


