
IMPLEMENTATION MODULE Objects;

(*****************************************************)
(*                                                   *)
(*      DRIEDIM OBJECTS V2.1                         *)
(*      --------------------                         *)
(*                                                   *)
(*   Author: Juul v/d Spek, Valkenswaard.            *)
(*                                                   *)
(*   please do not alter this text without           *)
(*   author's permission.                            *)
(*                                                   *)
(*****************************************************)
(*                                                   *)
(* This module implements all kind of objects in     *)
(* which sets of lines and planes can be stored,     *)
(* along with routines to deal with them.            *)
(*                                                   *)
(*****************************************************)

  FROM GEMVDIbase IMPORT PxyArrayType;

  FROM VDIOutputs IMPORT PolyLine;

  FROM Storage    IMPORT ALLOCATE, DEALLOCATE;

  FROM SYSTEM     IMPORT SIZE; 

  FROM GEMDOS     IMPORT Delete, DiskInfoBuffer, DFree, SFirst;

  FROM Streams    IMPORT StreamKinds, Stream, OpenStream, CloseStream;

  FROM TextIO     IMPORT WRiteLn, WRiteInt, WriteCard;

  FROM InOut      IMPORT Done;

  FROM LLexMod    IMPORT LIdenNr;

  FROM Vectors    IMPORT Point, PointList, Transform,
                         Matrix, DeAllPointList, TrPointList;

(*$T-*)(*$C-*)

  PROCEDURE AddPart(VAR l: PartList; p: Part);
    VAR  h: PartList;
  BEGIN
    NEW(h);
    WITH h^ DO
      Head:= p;
      Tail:= l
    END;
    l:= h
  END AddPart;


  PROCEDURE NextPart(VAR l: PartList; VAR p: Part): BOOLEAN;
  BEGIN
    IF  l=NIL THEN RETURN FALSE
     ELSE
      WITH l^ DO
        p:= Head;
        l:= Tail;
      END;
      RETURN TRUE
    END
  END NextPart;




  PROCEDURE TrPartList(l      : PartList;
                       Add    : Point; 
                       Prod   : Matrix   ): PartList;
  (*************************************************)
  (* Transforms each part in l, and returns these  *)
  (* points in a REVERSED list (according to l     *)
  (*************************************************)
    VAR x: Part;
        r: PartList;
  BEGIN
    r:= NIL;

    WHILE NextPart(l, x) DO
      WITH x DO
        CASE Sel OF
          Line : line:= TrPointList(line, Add, Prod); |
          Plane: Transform(int, Add, Prod, int);
                 plane:= TrPointList(plane, Add, Prod); 
        END;
      END;

      AddPart(r,x)
    END;

    RETURN r
  END TrPartList;



  PROCEDURE DeAllPartList(VAR l: PartList);
  (**********************)
  (* Deallocates list l *)
  (**********************)
    VAR r: PartList;
        p: partlist;
  BEGIN
    WHILE l#NIL DO
      r:= l;
      l:= l^.Tail;
      WITH r^.Head DO
        IF Sel=Line THEN DeAllPointList(line)
         ELSE DeAllPointList(plane)
        END
      END;
      DEALLOCATE(r,SIZE(p))      
    END;
  END DeAllPartList;
  









  PROCEDURE AddEnv(VAR l: Alist; i: LIdenNr; p: PartList);
    VAR  h: Alist;
  BEGIN
    NEW(h);
    WITH h^ DO
      Head.Name    := i;
      Head.Contents:= p;
      Tail:= l
    END;
    l:= h
  END AddEnv;


  PROCEDURE Assoc(Env: Alist; i: LIdenNr): PartList;
  BEGIN
    WHILE Env<>NIL DO
      WITH Env^ DO
        IF Head.Name=i THEN RETURN Head.Contents  
         ELSE Env:= Tail
        END
      END
    END;
    RETURN NIL
  END Assoc;


  PROCEDURE DeAllPair(VAR l: Alist);
  (*******************************)
  (* Deallocates first pair of l *)
  (* and pops l                  *)
  (*******************************)
    VAR
      r: Alist;
      x: alist;
  BEGIN
    r:= l;
    l:= l^.Tail;
    DeAllPartList(r^.Head.Contents);
    DEALLOCATE(r,SIZE(x))
  END DeAllPair;





  PROCEDURE DeAllLineList(VAR l: LineList);
  (**********************)
  (* Deallocates list l *)
  (**********************)
    VAR r,h: LineList;
        p  : linelist;
  BEGIN
    h:= l;
    WHILE l#NIL DO
      r:= l;
      l:= l^.Tail;
      DEALLOCATE(r,SIZE(p));
      IF l=h THEN l:= NIL END;      
    END;
  END DeAllLineList;


  PROCEDURE AddLine(VAR l: LineList; p1,p2: Point);
  (*********************)
  (* Add new line to l *)
  (*********************)
    VAR  h: LineList;
  BEGIN
    NEW(h);
    WITH h^ DO
      Head.p1:= p1;
      Head.p2:= p2;
      Tail:= l
    END;
    l:= h
  END AddLine;


  PROCEDURE CopyLineList(l: LineList): LineList;
  (********************)
  (* make a copy of l *)
  (********************)
    VAR r: LineList;
  BEGIN
    r:= NIL;

    WHILE l#NIL DO
      WITH l^ DO
        AddLine(r,Head.p1, Head.p2);
        l:= Tail
      END;
    END;

    RETURN r;
  END CopyLineList;


  PROCEDURE AppendLineList(VAR l1: LineList; l2: LineList);
  (*******************) 
  (* Chains l2 to l1 *)
  (*******************) 
  BEGIN
    IF l1=NIL THEN l1:= l2
     ELSE AppendLineList(l1^.Tail,l2)
    END
  END AppendLineList;



  PROCEDURE Trunk(x: REAL): INTEGER;
  BEGIN
    IF x<0.0 THEN RETURN -VAL(INTEGER,TRUNC(-x))
     ELSE  RETURN VAL(INTEGER,TRUNC(x))
    END
  END Trunk;


  PROCEDURE PlotFile(VAR FileName: ARRAY OF CHAR; 
                     dx, dy: INTEGER; 
                     scale : REAL;
                     l     : LineList): PlotFileResult;
  (******************************************************)
  (* Generate a textfile of name 'FileName', containing *)
  (* the coordinates of endpoints of all linesegments   *)
  (* in proj                                            *)
  (******************************************************)

    CONST len         = 8;    (* Printlen of coords.              *)
          Found       = 0;    (* Flag returned by SFirst          *)
          DefaultDrive= 0;    (* Default drive id                 *)
          TresHold    = 4096; (* minimum nr of allowed free space *)
                              (*  in byte.                        *)

    VAR   buff     : DiskInfoBuffer;
          drive    : CARDINAL;
          b        : BOOLEAN;
          s        : Stream;
          reply    : INTEGER;
          DiskSpace: LONGCARD;

  BEGIN
    (* Check if file exists: *)
    SFirst(FileName, 0, reply);    
    IF reply=Found THEN RETURN FileExists END;

    OpenStream(s, FileName, READWRITE, reply);
    IF reply<0 THEN RETURN CantOpen END;

    (* Get drivenr of filename: *)
    IF FileName[1]=':' THEN
      drive:= ORD(FileName[0])-ORD('A')+1;
     ELSE
      drive:= DefaultDrive
    END;

    (* Get size of free space of disk: *)
    DFree(buff, drive);
    WITH buff DO DiskSpace:= freeSpace * sectorSize * clusterSize END; 

    (* dirty trick to get an order more precision in integers: *)
    scale:= 10.0 * scale;
    dx   := 10 * dx;
    dy   := 10 * dy;
   
    (* Write until ready or disk is full:      *)
    b:= TRUE;
    WHILE (l#NIL) AND b DO
      IF DiskSpace<TresHold THEN b:= FALSE
       ELSE
        WITH l^ DO
          DiskSpace:= DiskSpace - ( 4*len+2 );
          WRiteInt(s, Trunk(scale*Head.p2.x1)+dx, len);
          WRiteInt(s, Trunk(scale*Head.p2.x2)+dy, len);
          WRiteInt(s, Trunk(scale*Head.p1.x1)+dx, len);
          WRiteInt(s, Trunk(scale*Head.p1.x2)+dy, len);
          WRiteLn(s);
          l:= Tail;
        END;
      END;
    END;

    CloseStream(s, reply);

    IF b AND (reply>=0) THEN RETURN Prima
    ELSE RETURN DiskFull END
  END PlotFile;



  PROCEDURE PlotProjection(handle, midX, midY: INTEGER;
                           scale: REAL;
                           l: LineList);
  (****************************************)
  (* Plot lines in l to workstation       *)
  (* "handle", with (midX,midY) as origin *)
  (* and multiplied by scale              *)
  (****************************************)

    TYPE
      Double= RECORD
                CASE BOOLEAN OF (* for omitting index computations *)
                  TRUE : x1,x2,y1,y2: INTEGER     |
                  FALSE: array      : PxyArrayType
                END
              END;                

    VAR Buff: Double;

  BEGIN
    WHILE l#NIL DO
      WITH l^ DO
        Buff.x1:= Trunk(scale*Head.p1.x1)+midX;
        Buff.x2:= Trunk(scale*Head.p1.x2)+midY;
        Buff.y1:= Trunk(scale*Head.p2.x1)+midX;
        Buff.y2:= Trunk(scale*Head.p2.x2)+midY;
        l:= Tail
      END;

      PolyLine(handle,2,Buff.array);
    END
  END PlotProjection;



  PROCEDURE AddPlane(VAR l: PlaneList; p: LineList);
  (*****************************) 
  (* Add new plane (contour)   *)
  (* to planelist l            *)
  (*****************************)
    CONST
      LargeReal   = 70000000000.0; 
      MinLargeReal= -LargeReal;

    VAR
      h: PlaneList;
  BEGIN
    NEW(h);
    WITH h^ DO
      Tail:= l;

     (* Compute rectangle, containing projection of plane: *)

      WITH Head DO
        Contour:= p;

        XMin:= LargeReal;
        YMin:= LargeReal;
        XMax:= MinLargeReal;
        YMax:= MinLargeReal;

        WHILE p#NIL DO
          WITH p^ DO
            WITH Head.p1 DO
              IF x1>XMax THEN XMax:= x1 END;
              IF x1<XMin THEN XMin:= x1 END;
              IF x2>YMax THEN YMax:= x2 END;
              IF x2<YMin THEN YMin:= x2 END;
            END;
            p:= Tail 
          END;
        END;

        AppendLineList(Contour, Contour)
      END;

    END;
    l:= h;

  END AddPlane;


  PROCEDURE DeAllPlaneList(VAR l: PlaneList);
  (************************)
  (* deallocate planelist *)
  (************************)
    VAR r: PlaneList;
        p: planelist;
  BEGIN
    WHILE l#NIL DO
      r:= l;
      WITH l^ DO
        DeAllLineList(Head.Contour);
        l:= Tail;
      END;
      DEALLOCATE(r,SIZE(p));
    END;
  END DeAllPlaneList;



END Objects.
  
