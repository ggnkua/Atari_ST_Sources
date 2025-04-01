(* Listing 2 *)

DEFINITION MODULE Point;

  IMPORT MOBS;

  TYPE DrawProc = PROCEDURE(VAR MOBS.CLASS);
       Type = RECORD
                ID   : MOBS.CLASS;
                x, y : INTEGER
              END;

  PROCEDURE INIT( VAR p : Type; x, y : INTEGER );
  PROCEDURE DRAW( VAR PointID : MOBS.CLASS );
  PROCEDURE MOVE( VAR SrcID, DstId : MOBS.CLASS; 
                      Draw : DrawProc );

  VAR Class : MOBS.CLASS;

END Point.

IMPLEMENTATION MODULE Point;

  IMPORT BasicLib, MOBS;

  TYPE PPtr = POINTER TO Type;

  VAR PointDef : MOBS.CLASSDEF;

  PROCEDURE DRAW( VAR ID : MOBS.CLASS );
  VAR p : PPtr;
  BEGIN p := MOBS.IS(ID, Class);
        IF p # NIL
        THEN BasicLib.PCIRCLE(p^.x,p^.y,5)
        END
  END DRAW;

  PROCEDURE INIT( VAR p : Type; x, y : INTEGER );
  BEGIN p.ID := Class; p.x := x; p.y := y
  END INIT;

  PROCEDURE MOVE( VAR SrcId, DstId : MOBS.CLASS; 
                      Draw : DrawProc );
  VAR s, d, p : PPtr;
  BEGIN s := MOBS.IS(SrcId, Class);
        d := MOBS.IS(DstId, Class);
        IF (s # NIL) & (d # NIL) THEN
          BasicLib.GRAPHMODE(3);
          MOBS.ASSIGN(p,s^.ID);
          WHILE (p^.x < d^.x) & (p^.y < d^.y) DO
            Draw(p^.ID); BasicLib.PAUSE(2);
            Draw(p^.ID);
            INC(p^.x,5); INC(p^.y,5)
          END;
          MOBS.FREE(p)
        END
  END MOVE;

BEGIN Class := MOBS.NEW(PointDef,NIL,SIZE(Type))
END Point.


