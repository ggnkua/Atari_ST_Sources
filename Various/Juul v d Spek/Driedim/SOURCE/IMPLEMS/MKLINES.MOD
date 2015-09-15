IMPLEMENTATION MODULE MkLines;
 
(*****************************************************)
(*                                                   *)
(*      MKLINES V2.1                                 *)
(*      ------------                                 *)
(*                                                   *)
(*   Author: Juul v/d Spek, Valkenswaard.            *)
(*                                                   *)
(*   please do not alter this text without           *)
(*   author's permission.                            *)
(*                                                   *)
(*****************************************************)
(*                                                   *)
(* This module implements procedures to generate a   *)
(* projection of a set of lines and planes;          *)
(* Here also the HLR procedures can be found.        *)
(*                                                   *)
(*****************************************************)

  FROM Vectors     IMPORT Point, PointList, NextPoint, 
                          UitProd, InProd, Subtract,
                          Visible, Project, Add,
                          ViewDirection; 

  FROM Objects     IMPORT Part, PartKind, PartList, NextPart,
                          DeAllPlaneList, LineList, AddLine, 
                          DeAllLineList, PlaneList, AddPlane,
                          CopyLineList, AppendLineList, 
                          linelist, LineSeg, plane;

  FROM Storage     IMPORT ALLOCATE, DEALLOCATE;

  FROM SYSTEM      IMPORT SIZE;

  FROM TextIO      IMPORT Read,
                          WriteReal, WriteLn, WriteCard, WriteString, Write;



  CONST 
    RealEps       =  0.000001;      (* Tolerance for Real comparisions *)
    MinRealEps    = -RealEps; 
    EenPlusRealEps= 1.0+RealEps;
    EenMinRealEps = 1.0-RealEps;  

    SpecialPlane  = 0;              (* Special plane identifier        *)
    EmptySet      = NIL;            (* Empty set of planes             *)


  TYPE 
    PlaneId = CARDINAL;             (* plane identification type *)

    PlaneSet= POINTER TO planeset;  (* Set of planes               *)
                                    (* used to keep track of all   *)
                                    (* the planes that shield part *)
                                    (* of some line segment.       *)

    planeset= RECORD
                Head: PlaneId;
                Tail: PlaneSet
              END;


    IntersectInfo= RECORD
                     u: REAL;   (* intersect parameter       *)
                     p: PlaneId (* Id of intersected plane   *)
                   END;

    ParList= (* list of plane intersection information *)
             POINTER TO parlist;

    parlist      = RECORD
                     Head: IntersectInfo;
                     Tail: ParList;
                   END;

    IntersectMsg= (* Messages from procedure Intersect, *)
                  (* which intersects a line segment L  *)
                  (* with one segment of the contour    *)
                  (* of plane V.                        *)
                  (Parallel,  (* The segments are parallel lines        *)
                   Cross,     (* the carriers of the two segments cross *)
                              (*  each other.                           *)
                   VLine);    (* it is detected that V's projection     *)
                              (*  is a line.                            *)


(*$C-*) (*$T-*)


PROCEDURE FlipPlane(VAR s: PlaneSet; p: CARDINAL);
(******************************************)
(* Insert p in s if s does not contain p, *)
(* delete p from s otherwise.             *)
(******************************************)
  VAR h: PlaneSet;
      x: planeset;

  PROCEDURE Flip(VAR s: PlaneSet);
  BEGIN
    IF s=EmptySet THEN 
      NEW(s);
      WITH s^ DO
        Head:= p;
        Tail:= EmptySet;
      END
     ELSE
      WITH s^ DO
        IF Head<p THEN
          Flip(Tail)
         ELSIF Head=p THEN
          h:= s;
          s:= Tail;
          DEALLOCATE(h,SIZE(x));
         ELSE
          h:= s;
          NEW(s);
          WITH s^ DO
            Head:= p;
            Tail:= h;
          END;
        END;
      END
    END;
  END Flip;

BEGIN
  Flip(s)
END FlipPlane;



PROCEDURE DeAllPlaneSet(VAR l: PlaneSet);
(**********************)
(* Deallocates list l *)
(**********************)
  VAR p: planeset;
      h: PlaneSet;
BEGIN
  WHILE l#NIL DO
    h:= l;
    l:= l^.Tail;
    DEALLOCATE(h, SIZE(p))
  END;
END DeAllPlaneSet;




PROCEDURE EqReal(x1,x2: REAL): BOOLEAN;
BEGIN
  RETURN ABS(x1-x2)<RealEps
END EqReal;



PROCEDURE AddIntersection(VAR l: ParList;
                              r: REAL;
                              p: PlaneId);
(**********************************)
(* Add new intersection to list l *)
(* and keep l sorted.             *)
(**********************************)
  VAR h: ParList;

  PROCEDURE AddPar(VAR l: ParList);
  (******************************)
  (* Insert h in l              *)
  (******************************)
  BEGIN
    IF l=NIL THEN
      NEW(h);
      WITH h^ DO
        Head.u:= r;
        Head.p:= p;
        Tail  := l
      END;
      l:= h;
     ELSE
      WITH l^ DO
        IF Head.u<r THEN AddPar(Tail)
         ELSE
          NEW(h);
          WITH h^ DO
            Head.u:= r;
            Head.p:= p;
            Tail  := l
          END;
          l:= h;
        END;
      END;
    END;
  END AddPar;

BEGIN
  AddPar(l)
END AddIntersection;




PROCEDURE AddParList(VAR l1,l2: ParList);
(******************************************************)
(* PRE: l2 is sorted according to u in its components *)
(* ACTION: l1 is added to l2 in sorted order          *)
(* POST: l1 is empty                                  *)
(******************************************************)
  VAR h: ParList;
      r: REAL;

  PROCEDURE AddPar(VAR l: ParList);
  (******************************)
  (* Insert h in l              *)
  (* h^.Head.u is reserved in r *)
  (******************************)
  BEGIN
    IF l=NIL THEN
      h^.Tail:=NIL;
      l:= h
     ELSE
      WITH l^ DO
        IF Head.u<r THEN AddPar(Tail)
         ELSE
          h^.Tail:= l;
          l:= h
        END;
      END;
    END;
  END AddPar;

BEGIN
  WHILE l1#NIL DO
    h:= l1;
    r:= h^.Head.u;
    l1:= l1^.Tail;
    AddPar(l2);
  END;
END AddParList;




PROCEDURE DeAllParList(VAR l: ParList);
(**********************)
(* Deallocates list l *)
(**********************)
  VAR p: parlist;
      h: ParList;
BEGIN
  WHILE l#NIL DO
    h:= l;
    l:= l^.Tail;
    DEALLOCATE(h, SIZE(p))
  END;
END DeAllParList;


                                      (**************************************)
PROCEDURE Intersect(VAR l,v: LineSeg; (* VAR to avoid copy overhead at call *)
                    VAR u,t: REAL;    (* RETURNED intersect parameters      *)
                                      (*  when segment carriers cross:      *)
                                      (*  l.p1+u(l.p2-l.p1)                 *) 
                                      (*   = v.p1+t(v.p2-v.p1)              *)
                    VAR d3 : REAL)    (* v(t)-l(u); to determine if         *)
                                      (*  v lies before l.                  *)
                      : IntersectMsg; (* Returned intersect information.    *)
                                      (**************************************)
(*****************************************************)
(* Procedure to intersect two line segments          *)
(* and returns all kind of usefull information       *)
(* PRE: l is not a point (this is tested before)     *)
(* NOTE that the following facts are used here:      *)
(*  The contour of a plane is flat (lies in a plane) *)
(*  For all planes v anf all line segments l, the    *)
(*  following holds:                                 *)
(*   l does not intersect the interior of the        *)
(*   smallest convex polygon that contains the       *)
(*   contour of v (except for the endpoinds of l).   *)
(*****************************************************)

  VAR D, dvx, dvy, dlx, dly, lvx, lvy, lu3, vt3: REAL;

BEGIN
  IF EqReal(v.p1.x1, v.p2.x1) AND EqReal(v.p1.x2, v.p2.x2) THEN
    RETURN VLine END;

  dvx:= v.p2.x1-v.p1.x1; 
  dvy:= v.p2.x2-v.p1.x2;
  dlx:= l.p1.x1-l.p2.x1;
  dly:= l.p1.x2-l.p2.x2;
  lvx:= l.p1.x1-v.p1.x1;
  lvy:= l.p1.x2-v.p1.x2;
  D  := dvx*dly - dvy*dlx;  (* Determinant *)

  IF EqReal(D, 0.0) THEN RETURN Parallel END;

 (* Crosspoint parameters: *)
  t:= (lvx*dly - lvy*dlx) / D;
  u:= (dvx*lvy - dvy*lvx) / D;
  
 (* distance observer to crosspoint on l: *)
  lu3:= l.p1.x3 + u*(l.p2.x3-l.p1.x3); 

 (* distance observer to crosspoint on v: *)
  vt3:= v.p1.x3 + t*(v.p2.x3-v.p1.x3);

  d3:= lu3-vt3;

  RETURN Cross;
END Intersect;



PROCEDURE Shield(VAR l : LineSeg; 
                 Planes: LineList; 
                 pid   : PlaneId): ParList;
  VAR h       : LineList;
      m       : IntersectMsg;
      d3,t,u  : REAL;
      res     : ParList;
      p       : Point;

      dist1,
      dist2,
      par1,
      par2,
      a, b     : REAL;    
      NrInters : CARDINAL;


  PROCEDURE AddContourCrossing;
  (*****************************************)
  (* Add a new countour crossing from l(u) *)
  (* store distance l(u)-v(t)              *)
  (*****************************************)
  BEGIN
    NrInters:= NrInters+1;
    AddIntersection(res,u,pid);
    dist2:= dist1;
    par2 := par1;
    dist1:= d3;
    par1 := u;
  END AddContourCrossing;


  PROCEDURE DifferentSides(p1,p2: Point; VAR l: LineSeg): BOOLEAN;
  (*************************************************)
  (* do p1 and p2 ly on different sides of line l? *)
  (*************************************************)
    VAR dx,dy,d1,d2,d: REAL;
  BEGIN
    WITH l DO
      dx:= p1.x1-p2.x1;
      dy:= p1.x2-p2.x2;
      d := dy*p1.x1 - dx*p1.x2;
    END;

    d1:= dy*p1.x1 - dx*p1.x2;
    d2:= dy*p2.x1 - dx*p2.x2;

    RETURN ((d1-d)*(d2-d)) < 0.0
  END DifferentSides;



BEGIN

 (* Set Planes (a circular LineList) on a segment that is not     *)
 (* intersected by l in p1, and which is not parallel to l.       *)
 (* (to ensure that next loop ends...)                            *)
  h:= Planes;
  REPEAT
    t:= -1.0;
    m:= Intersect(l, Planes^.Head, u,t,d3);
    Planes:= Planes^.Tail;
    IF Planes=h THEN (* plane projects to line *) RETURN NIL END; 
  UNTIL NOT ( EqReal(t, 1.0)  OR  (m=Parallel) );


 (* Compute all intersections with contour of plane *)
 (* and keep track of distance information:         *)

  res:= NIL;    (* Result of this Proc *)
  h  := Planes; (* Endmarker           *)
  NrInters:= 0; (* Number of times l intersected contour of plane *)

  REPEAT
    m:= Intersect(l, Planes^.Head, u, t, d3);
    IF m=VLine THEN
      DeAllParList(res);
      RETURN NIL;
    END;

    IF m=Cross THEN
      IF (t>0.0) AND (t<EenPlusRealEps) THEN

        IF t<EenMinRealEps THEN (* Line enters/leaves projection of plane *)
          AddContourCrossing
         ELSE
          p:= Planes^.Head.p1;

          REPEAT Planes:= Planes^.Tail
          UNTIL Intersect(l, Planes^.Head, d3, t, d3) # Parallel;

          IF DifferentSides(p, Planes^.Head.p2, l)
           THEN (* Line enters/leaves projection of plane *) 
            AddContourCrossing
           (* ELSE line touches border of planeprojection *)
          END;
        END;
      END;
    END;

    Planes:= Planes^.Tail;
  UNTIL Planes=h;


  IF NrInters<2 THEN DeAllParList(res) 
   ELSE
   (* compute distance function "l(u)-v(u)"= a+ub *)
    d3:= par2-par1;

    IF EqReal(d3,0.0) THEN (* plane projects almost to line *)
      DeAllParList(res) 
     ELSE
      a:= (dist1*par2 - dist2*par1) / d3;
      b:= (dist2 - dist1) / d3;

     (* and compute final hiding information *)
      Hide(res, a, b)
    END
  END;

  RETURN res
END Shield;



PROCEDURE Hide(VAR CrossInfo: ParList; a,b: REAL);
(******************************************************)
(* Decide which of the contour crossings in CrossInfo *)
(* is a real hide/show line transition..              *)
(******************************************************)
  VAR 
    BeforeU0,
    InContour: BOOLEAN;
    h, res   : ParList;
    d, u0    : REAL;
  
BEGIN
  res      := NIL;
  InContour:= FALSE;
  h        := CrossInfo;

  IF EqReal(b,0.0) THEN BeforeU0:= FALSE
   ELSE
    BeforeU0:= TRUE;
    u0:= -a/b               (* l(u0)=v(u0) *)
  END;

  WHILE h#NIL DO
    WITH h^ DO
      WITH Head DO
        d:= a + b*u;         (* l(u)-v(u) *)

        IF BeforeU0 THEN
          IF u0<(u-RealEps) THEN
            IF InContour THEN AddIntersection(res,u0,p) END
          END;

          BeforeU0:= u<(u0-RealEps)
        END;

        IF    d>RealEps  THEN AddIntersection(res,u,p)
        ELSIF EqReal(d,0.0) THEN
          CASE InContour OF
            FALSE: IF b>RealEps    THEN AddIntersection(res,u,p) END |
            TRUE : IF b<MinRealEps THEN AddIntersection(res,u,p) END 
          END;
        END;

        InContour:= NOT InContour;
      END;

      h:= Tail;
    END;
  END;

  DeAllParList(CrossInfo);
  CrossInfo:= res;
END Hide;


PROCEDURE AddLineSegments(l       : LineSeg;
                          Ints    : ParList;
                      VAR NewLines: LineList);
(******************************************)
(* Add visible fractions of l to Newlines *)
(* visibility information in Ints         *)
(******************************************)
  VAR InPlanes : PlaneSet;
      dx,dy,u  : REAL;
      p1,p2    : Point;


  PROCEDURE SkipNext;
    VAR
      b: BOOLEAN;
  BEGIN
    b := TRUE;
    WHILE b DO
      WITH Ints^ DO
        IF NOT EqReal(u, Head.u) THEN b:= FALSE
         ELSE
          FlipPlane(InPlanes, Head.p);
          Ints:= Tail;
          b   := Ints#NIL; 
        END;
      END;
    END;    
    
  END SkipNext;
 
BEGIN
  dx:= l.p2.x1-l.p1.x1;
  dy:= l.p2.x2-l.p1.x2;
  InPlanes:= EmptySet;
  FlipPlane(InPlanes, SpecialPlane);

  REPEAT
    u:= Ints^.Head.u;
    p2.x1:= l.p1.x1 + u*dx;
    p2.x2:= l.p1.x2 + u*dy;

    IF InPlanes = EmptySet THEN AddLine(NewLines,p2,p1) END;
    SkipNext;
    p1:= p2;
  UNTIL Ints=NIL;

  DeAllPlaneSet(InPlanes)
END AddLineSegments;


PROCEDURE ShieldLine(VAR l       : LineSeg;
                     Planes      : PlaneList;
                     VAR NewLines: LineList);
(*****************************************************)
(* Shield l by all planes in Planes, and add visible *)
(* parts to NewLines.                                *)
(*****************************************************)
  VAR Ints, Tmp: ParList;
      pl       : PlaneId;

  PROCEDURE Overlap(VAR l: LineSeg; VAR p: plane): BOOLEAN;
    VAR xmin,xmax,ymin,ymax: REAL; 
  BEGIN

   (* compute rectangular, enclosing l: *)
    WITH l DO
      IF p1.x1>p2.x1 THEN
        xmin:= p2.x1;
        xmax:= p1.x1
       ELSE
        xmin:= p1.x1;
        xmax:= p2.x1
      END;

      IF p1.x2>p2.x2 THEN
        ymin:= p2.x2;
        ymax:= p1.x2
       ELSE
        ymin:= p1.x2;
        ymax:= p2.x2
      END;

    END;


    WITH p DO
      RETURN   (xmin<XMax)
           AND (XMin<xmax)
           AND (ymin<YMax)
           AND (YMin<ymax) 
    END
  END Overlap;

BEGIN
 (* Test if line projects to point: *)
  IF EqReal(l.p1.x1, l.p2.x1) 
     AND EqReal(l.p1.x2, l.p2.x2) THEN (* Do nothing. *)

 (* Else start hiding: *)
   ELSE
    pl:= 0;
    Ints:= NIL;
    (* SpecialPlane shields from the carrier of l all *)
    (* parts that are not on l:                       *)
    AddIntersection(Ints, 1.0, SpecialPlane);
    AddIntersection(Ints, 0.0, SpecialPlane);

    WHILE Planes#NIL DO
      WITH Planes^ DO
        IF Overlap(l,Head) THEN
          pl:= pl+1;
          Tmp:= Shield(l, Head.Contour, pl);
          AddParList(Tmp, Ints);  
        END;
        Planes:= Tail;
      END;
    END;

    AddLineSegments(l, Ints, NewLines);

    DeAllParList(Ints);
  END;
END ShieldLine;




PROCEDURE HLR(VAR Lines: LineList; Planes: PlaneList);
(********************************************************)
(* Replace Lines by a new set, representing Lines, with *)
(* parts behind a Plane removed.                        *)
(********************************************************)
  VAR lines, NewLines: LineList;
      p      : linelist;
      count  : CARDINAL;
BEGIN
  NewLines:= NIL;
  lines   := Lines;

  count:= 0;
  WHILE lines#NIL DO
   count:= count+1;
   lines:= lines^.Tail
  END;  



  WHILE Lines#NIL DO

    count:= count-1;
    WriteString(" *** Line "); WriteCard(count,4);
    WriteString(" ***                 "); 
    Write(15C);

    lines:= Lines;
    WITH Lines^ DO
      ShieldLine(Head, Planes, NewLines);
      Lines:= Tail
    END;

   (* Deallocate Lines as soon as possible: *)
    DEALLOCATE(lines, SIZE(p))    
  END;

  Lines:= NewLines;
END HLR;



PROCEDURE MkProjection(obj     : PartList;
                       Observer, ObPoint: Point;
                       hlr     : BOOLEAN;
                       VAR proj: LineList);

  VAR ViewDir,
      a, h         : Point;
      part         : Part;
      d            : REAL;
      Planes       : PlaneList; (* list of all visible plane contours for HLR *)
      pl1,pl2      : LineList;
      i, p1, p2, p3: Point;
      b            : BOOLEAN;

  PROCEDURE AddLines(line : PointList;
                     VAR to: LineList): BOOLEAN;
  (*************************************************)
  (* Add projection of line to to. return true iff *)
  (* one point of line was invisible.              *)
  (* This fact is used in case of a plane: the HLR *)
  (* procedure used here requires that all contours*)
  (* of planes must be closed.                     *)
  (*************************************************)
    VAR old,p,h: Point;
        res, vis, plotting: BOOLEAN;
  BEGIN
    res:= TRUE;
    plotting:= FALSE;

    WHILE NextPoint(line,h) DO
      Subtract(h,Observer,h);
      vis:= Visible(h);

      IF vis THEN
        Project(h,p); 
        IF plotting THEN (* Add line only when both ends visible *) 
          AddLine(to, old, p) END;
        old:= p;
       ELSE
        res:= FALSE;
      END;

      plotting:= vis;
    END;

    RETURN res
  END AddLines;



BEGIN
 (* Deallocate old contents of proj   *)
 (* and set plane information to NIL: *)

  DeAllLineList (proj);
  Planes:= NIL;


 (* Compute and set transformation info for driedim: *)

  Subtract(ObPoint,Observer, ViewDir);
  ViewDirection(ViewDir);


 (* Compute new lineset: *)

  WHILE NextPart(obj, part) DO 
    WITH part DO
      CASE Sel OF
        Line  : b:= AddLines(line, proj)  |

        Plane : (* plot planes only if INTERN point and *)
                (* observer on different sides          *)
                (* p1 p2 and p3: first points of plane; *)
                (* supposed to be not on one line       *)
                Subtract(int                    , Observer, i);
                Subtract(plane^.Head            , Observer,p1);
                Subtract(plane^.Tail^.Head      , Observer,p2);
                Subtract(plane^.Tail^.Tail^.Head, Observer,p3);

                Subtract(p1,p2,a);
                Subtract(p3,p2,h);
                UitProd (a,h,p3);

                d:= InProd(p1,p3);

                IF ((InProd(i,p3)-d) * d) >= 0.0  THEN
                  pl1:= NIL;
                  b  := AddLines(plane, pl1);

                  IF b AND hlr THEN
                    pl2:= CopyLineList(pl1);
                    AddPlane(Planes, pl2)
                  END;

                  AppendLineList(pl1, proj);
                  proj:= pl1; 
                END
      END;
    END;
  END;

  (* Remove hidden lines, if requested: *)
  IF hlr THEN HLR(proj, Planes) END;

  (* discard plane information: *)
  DeAllPlaneList(Planes);

END MkProjection;

END MkLines.



