IMPLEMENTATION MODULE Basic;
(* programmed by P.Costanza *)
(* Date : 21:47  25. 5.1991 *)

  IMPORT SYSTEM, BasicLib, Erwin, MOBS,
         Rectangle, Storage, Streams, System;

  VAR Lib : INTEGER;
      ClipArea : Rectangle.Instance;
      Offset : RECORD X, Y : INTEGER END;

  TYPE Deftext = RECORD
         ID : MOBS.CLASS;
         Next : Streams.BasePtr;
         Delete : Streams.DelProc;
         Redraw : Erwin.RedrawProc;
         ColourIndex : ColourRange;
         Effect : TextEffects;
         Angle : TenthDegree;
         Height : INTEGER
       END;
       PlotProc = PROCEDURE(INTEGER,INTEGER);
       Plot = RECORD
         ID : MOBS.CLASS;
         Next : Streams.BasePtr;
         Delete : Streams.DelProc;
         Redraw : Erwin.RedrawProc;
         Proc : PlotProc;
         x, y : INTEGER
       END;
       BoxProc = PROCEDURE(INTEGER,INTEGER,INTEGER,INTEGER);
       Box = RECORD
         ID : MOBS.CLASS;
         Next : Streams.BasePtr;
         Delete : Streams.DelProc;
         Redraw : Erwin.RedrawProc;
         Proc : BoxProc;
         x0, y0, x1, y1 : INTEGER
       END;
       CHARArray = ARRAY [0..127] OF CHAR;
       Text = RECORD
         ID : MOBS.CLASS;
         Next : Streams.BasePtr;
         Delete : Streams.DelProc;
         Redraw : Erwin.RedrawProc;
         x, y : INTEGER;
         str : POINTER TO CHARArray
       END;

  VAR DeftextDef, PlotDef,
      BoxDef, TextDef : MOBS.CLASSDEF;
      DeftextClass, PlotClass,
      BoxClass, TextClass : MOBS.CLASS;

  PROCEDURE DeftextRedraw( VAR ID : MOBS.CLASS );
  VAR b : POINTER TO Deftext;
  BEGIN b := MOBS.IS(ID, DeftextClass);
    BasicLib.DEFTEXT(b^.ColourIndex,b^.Effect,b^.Angle,b^.Height)
  END DeftextRedraw;

  PROCEDURE PlotRedraw( VAR ID : MOBS.CLASS );
  VAR b : POINTER TO Plot;
  BEGIN b := MOBS.IS(ID, PlotClass);
    b^.Proc(b^.x + Offset.X, b^.y + Offset.Y)
  END PlotRedraw;

  PROCEDURE BoxRedraw( VAR ID : MOBS.CLASS );
  VAR b : POINTER TO Box;
  BEGIN b := MOBS.IS(ID, BoxClass);
    b^.Proc(b^.x0 + Offset.X, b^.y0 + Offset.Y,
            b^.x1 + Offset.X, b^.y1 + Offset.Y)
  END BoxRedraw;

  PROCEDURE TextRedraw( VAR ID : MOBS.CLASS );
  VAR b : POINTER TO Text;
  BEGIN b := MOBS.IS(ID, TextClass);
    BasicLib.TEXT(b^.x + Offset.X, b^.y + Offset.Y, b^.str^)
  END TextRedraw;

  PROCEDURE TextDelete( VAR ID : MOBS.CLASS );
  VAR p : POINTER TO Text;
  BEGIN p := MOBS.IS(ID, TextClass);
    Storage.DEALLOCATE(p^.str)
  END TextDelete;

  PROCEDURE CLS;
  BEGIN Streams.Close(Erwin.Active.Stream^)
  END CLS;

  PROCEDURE DEFTEXT(ColourIndex : ColourRange;
                    Effect      : TextEffects;
                    Angle       : TenthDegree;
                    Height      : INTEGER);
  VAR b : Deftext;
  BEGIN b.ID := DeftextClass;
        b.Next := NIL;
        b.Delete := Streams.NoDel;
        b.Redraw := DeftextRedraw;
        b.ColourIndex := ColourIndex;
        b.Effect := Effect;
        b.Angle := Angle;
        b.Height := Height;
        Streams.Append(Erwin.Active.Stream^,b.ID)
  END DEFTEXT;

  PROCEDURE DRAWto(x, y : INTEGER);
  VAR b : Plot;
  BEGIN b.ID := PlotClass;
        b.Next := NIL;
        b.Delete := Streams.NoDel;
        b.Redraw := PlotRedraw;
        b.Proc := BasicLib.DRAWto;
        b.x := x; b.y := y;
        Streams.Append(Erwin.Active.Stream^,b.ID)
  END DRAWto;

  PROCEDURE PLOT(x, y : INTEGER);
  VAR b : Plot;
  BEGIN b.ID := PlotClass;
        b.Next := NIL;
        b.Delete := Streams.NoDel;
        b.Redraw := PlotRedraw;
        b.Proc := BasicLib.PLOT;
        b.x := x; b.y := y;
        Streams.Append(Erwin.Active.Stream^,b.ID)
  END PLOT;

  PROCEDURE BOX(x0, y0, x1, y1 : INTEGER);
  VAR b : Box;
  BEGIN b.ID := BoxClass;
        b.Next := NIL;
        b.Delete := Streams.NoDel;
        b.Redraw := BoxRedraw;
        b.Proc := BasicLib.BOX;
        b.x0 := x0; b.y0 := y0; b.x1 := x1; b.y1 := y1;
        Streams.Append(Erwin.Active.Stream^,b.ID)
  END BOX;

  PROCEDURE PBOX(x0, y0, x1, y1 : INTEGER);
  VAR b : Box;
  BEGIN b.ID := BoxClass;
        b.Next := NIL;
        b.Delete := Streams.NoDel;
        b.Redraw := BoxRedraw;
        b.Proc := BasicLib.PBOX;
        b.x0 := x0; b.y0 := y0; b.x1 := x1; b.y1 := y1;
        Streams.Append(Erwin.Active.Stream^,b.ID)
  END PBOX;

  PROCEDURE TEXT(x, y : INTEGER;
                 str : ARRAY OF CHAR);
  VAR b : Text; s : INTEGER;
  BEGIN b.ID := TextClass;
        b.Next := NIL;
        b.Delete := TextDelete;
        b.Redraw := TextRedraw;
        b.x := x; b.y := y;
        s := HIGH(str) + 1;
        Storage.ALLOCATE(b.str,s);
        BasicLib.BMOVE(SYSTEM.ADR(str),b.str,s);
        Streams.Append(Erwin.Active.Stream^,b.ID)
  END TEXT;

  PROCEDURE Prolog;
  VAR cx1, cy1 : INTEGER;
  BEGIN ClipArea.X := Erwin.Redraw.WorldArea.A.X + Erwin.Redraw.Offset.X;
        ClipArea.Y := Erwin.Redraw.WorldArea.A.Y + Erwin.Redraw.Offset.Y;
        ClipArea.W := Erwin.Redraw.WorldArea.B.X - 1D;
        ClipArea.H := Erwin.Redraw.WorldArea.B.Y - 1D;
        Offset.X := Erwin.Redraw.Offset.X;
        Offset.Y := Erwin.Redraw.Offset.Y;
        cx1 := ClipArea.X + ClipArea.W;
        cy1 := ClipArea.Y + ClipArea.H;
        BasicLib.CLIP( ClipArea.X, ClipArea.Y, cx1, cy1, TRUE );
        BasicLib.BOUNDARY(TRUE);
        BasicLib.COLOR(1);
        BasicLib.DEFTEXT(1,0,0,13);
        BasicLib.DEFLINE(1,1,0,0);
        BasicLib.GRAPHMODE(1);
        BasicLib.SETCOLOR(FALSE);
        BasicLib.DEFFILL(0,0,1);
        BasicLib.PBOX( ClipArea.X, ClipArea.Y, cx1, cy1 );
        BasicLib.DEFFILL(1,1,1)
  END Prolog;

  PROCEDURE ExitMODULE;
  BEGIN Erwin.Deregister(Lib)
  END ExitMODULE;

BEGIN IF ~System.OnModuleTerminationDo(ExitMODULE) THEN HALT END;
      Erwin.Register(Lib,Prolog,Erwin.Nolog);
      IF Lib < 0 THEN HALT END;

      DeftextClass := MOBS.NEW(DeftextDef,Erwin.ItemClass,SIZE(Deftext));
      PlotClass    := MOBS.NEW(PlotDef,Erwin.ItemClass,SIZE(Plot));
      BoxClass     := MOBS.NEW(BoxDef,Erwin.ItemClass,SIZE(Box));
      TextClass    := MOBS.NEW(TextDef,Erwin.ItemClass,SIZE(Text))
END Basic.

