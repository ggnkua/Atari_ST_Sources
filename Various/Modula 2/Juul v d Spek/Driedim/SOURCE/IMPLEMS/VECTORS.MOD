

IMPLEMENTATION MODULE Vectors;

(*****************************************************)
(*                                                   *)
(*      VECTORS V2.1                                 *)
(*      ------------                                 *)
(*                                                   *)
(*   Author: Juul v/d Spek, Valkenswaard.            *)
(*                                                   *)
(*   please do not alter this text without           *)
(*   author's permission.                            *)
(*                                                   *)
(*****************************************************)
(*                                                   *)
(* This module implements                            *)
(*   1) 3D vectors, along with several vector        *)
(*      functions (inproduct, rotation, outproduct)  *)
(*   2) Lists of vectors, along with routines to     *)
(*      handle them.                                 *)
(*   3) Some Driedim specific vector functions.      *)
(*                                                   *)
(*****************************************************)

  FROM MathLib0 IMPORT sqrt, arctan;

  FROM sincos   IMPORT sin, cos;

  FROM SYSTEM   IMPORT SIZE; 

  FROM Storage  IMPORT ALLOCATE, DEALLOCATE;


  CONST ScreenFactor= (* multiplication factor, roughly dependant *)
                      (* on pixel size on screen                  *)
                       1500.0;


  VAR
         (* next globals are to be set by ViewDirection: *)

    ViewDir,      (* View direction         *)

    e1, e2        (* Transformation vectors *) 
                  : Point;   
    
(*$T-*)(*$C-*)

  PROCEDURE IntToReal(i: INTEGER): REAL;
    VAR b: BOOLEAN;
        r: REAL;
  BEGIN
    IF i>0 THEN RETURN  FLOAT( VAL(CARDINAL, i) )
           ELSE RETURN -FLOAT( VAL(CARDINAL,-i) )
    END;
  END IntToReal;


  PROCEDURE AddPoint(VAR l: PointList; p: Point);
    VAR h: PointList;
  (* Add p to list l *)
  BEGIN
    NEW(h);
    WITH h^ DO
      Head:= p;
      Tail:= l
    END;
    l:= h;
  END AddPoint;


  PROCEDURE NextPoint(VAR l: PointList; VAR p: Point): BOOLEAN;
  (* Get next point of l into p if l is not empty *)
  BEGIN
    IF  l=NIL THEN RETURN FALSE
     ELSE
      WITH l^ DO
        p:= Head;
        l:= Tail
      END;
      RETURN TRUE
    END
  END NextPoint;


  PROCEDURE TrPointList(l      : PointList;
                        Add    : Point; 
                        Prod   : Matrix   ): PointList;
  (*************************************************)
  (* Transforms each point in l, and returns these *)
  (* points in a REVERSED list (according to l     *)
  (*************************************************)

    VAR x: Point;
        r: PointList;
  BEGIN
    r:= NIL;

    WHILE NextPoint(l, x) DO
      Transform(x, Add, Prod, x);
      AddPoint(r,x)
    END;

    RETURN r
  END TrPointList;



  PROCEDURE DeAllPointList(VAR l: PointList);
  (**********************)
  (* Deallocates list l *)
  (**********************)
    VAR r: PointList;
        p: point;
  BEGIN
    WHILE l#NIL DO
      r:= l;
      l:= l^.Tail;
      DEALLOCATE(r,SIZE(p))      
    END;
  END DeAllPointList;
  






  PROCEDURE InProd(x,y: Point): REAL;
  (* Returns inproduct of vectors x and y *)
  BEGIN
    WITH x DO
      RETURN x1*y.x1 + x2*y.x2 + x3*y.x3;
    END
  END InProd;





  PROCEDURE Norm(x: Point): REAL;
  (* Returns size of vector x *)
  BEGIN
    WITH x DO
      RETURN sqrt(x1*x1 + x2*x2 + x3*x3 )
    END;
  END Norm;


  PROCEDURE Normalise(x: Point; VAR y: Point);
  (* Returns a vector of length 1, that points into *)
  (* the same direction of x                        *)
    VAR h: REAL;
  BEGIN
    h:= Norm(x);
    WITH x DO
      y.x1:= x1/h;
      y.x2:= x2/h;
      y.x3:= x3/h;
    END;
  END Normalise;



  PROCEDURE UitProd(x,y: Point; VAR z: Point);
  (* Returns the outproduct of x and y *)
  BEGIN
    WITH z DO
      x1:= x.x2*y.x3 - x.x3*y.x2;
      x2:= x.x3*y.x1 - x.x1*y.x3;
      x3:= x.x1*y.x2 - x.x2*y.x1;
    END;
  END UitProd;


  PROCEDURE Add(x,y: Point; VAR z: Point);
  (* Returns a vector constructed by componentwise *)
  (* addition of x and y                           *)
  BEGIN
    WITH z DO
      x1:= x.x1+y.x1;
      x2:= x.x2+y.x2;
      x3:= x.x3+y.x3;
    END;
  END Add;


  PROCEDURE Mult(x: Point;
                 f: REAL;
                 VAR y: Point);
  (* y:= f.x *)
  BEGIN
    WITH y DO
      x1:= f * x.x1;
      x2:= f * x.x2;
      x3:= f * x.x3;
    END;
  END Mult;


  PROCEDURE Subtract(x,y: Point; VAR z: Point);
  (* Returns a vector constructed by componentwise *)
  (* subtraction of x and y   (x-y)                *)
  BEGIN
    WITH z DO
      x1:= x.x1-y.x1;
      x2:= x.x2-y.x2;
      x3:= x.x3-y.x3;
    END;
  END Subtract;


  PROCEDURE EqPoint(x,y: Point): BOOLEAN;
  (* x=y? *)
  BEGIN
    RETURN (x.x1=y.x1) AND (x.x2=y.x2) AND (x.x3=y.x3);
  END EqPoint;


  PROCEDURE ViewDirection(viewdir: Point);
  (* Sets view direction                  *)
  (* and computes transformation matrix.  *)
    VAR   h,k: Point;
  BEGIN
    Normalise(viewdir, ViewDir);

    IF ( ViewDir.x1*ViewDir.x1 + ViewDir.x2*ViewDir.x2) > 0.000001 THEN
      (* Observer does not look straight down: *)
      WITH h DO
        x1:= 0.0;
        x2:= 0.0;
        x3:= 1.0;
      END;

      (* Compute first transformation vector: *)
      UitProd  (ViewDir, h, k);
      Normalise(k, e1);
      Mult(e1, ScreenFactor, e1);

      (* Compute second transformation vector: *)
      UitProd  (ViewDir, e1, k);
      Normalise(k, e2);
      Mult(e2, ScreenFactor, e2);

    ELSE  (* look straight down: *)

      WITH e1 DO
        x1:= -ScreenFactor;
        x2:=  0.0;
        x3:=  0.0;
      END;

      WITH e2 DO
        x1:= 0.0;
        x2:= ScreenFactor;
        x3:= 0.0;
      END;

    END;

  END ViewDirection;






  PROCEDURE Transform(x      : Point; 
                      Trans  : Point; 
                      Prod   : Matrix;
                      VAR y  : Point);
  (* y:= Trans + Prod . x *)
  BEGIN
    MatProd(Prod, x, y);
    Add (y, Trans, y);
  END Transform;


  PROCEDURE Visible(x: Point): BOOLEAN;
  (* Is x visible for Observer? *)
  (* i.e. Angle between point & *)
  (* view direction less than   *)
  (* Deg degrees.               *)
  (* See ViewDirection.         *) 
    CONST CosDeg= 0.5;
  BEGIN 
    RETURN InProd(ViewDir, x) > (Norm(x) * CosDeg)
  END Visible;


  PROCEDURE Project(x: Point; VAR y: Point);
  (* Project x onto a plane before the observer *)
  (* Result: x1 and x2: Coordinates in plane    *)
  (*         x3      : Distance x to Observer   *)
  (* WARNING: Projection is performed according *)
  (*  to global variables, set by ViewDir()     *)
  BEGIN
    WITH y DO
      x3:= InProd(ViewDir, x);
      x2:= InProd(e2, x)/x3;
      x1:= InProd(e1, x)/x3
    END;
  END Project;


PROCEDURE MatProd(M: Matrix;
                  x: Point;
                  VAR y: Point);
(***********)
(* y:= M.x *)
(***********)
BEGIN
  WITH y DO
    WITH M DO
      x1:= x11*x.x1+x12*x.x2;
      x2:= x21*x.x1+x22*x.x2;
      x3:= x33*x.x3
    END;
  END;
END MatProd;


PROCEDURE MatMult(M1,M2: Matrix; VAR M: Matrix);
(*************)
(* M:= M1.M2 *)
(*************)
BEGIN
  WITH M DO
    x11:= M1.x11*M2.x11 + M1.x12*M2.x21;
    x22:= M1.x21*M2.x12 + M1.x22*M2.x22;
    x33:= M1.x33*M2.x33;
    x21:= M1.x21*M2.x11 + M1.x22*M2.x21;
    x12:= M1.x11*M2.x12 + M1.x12*M2.x22;
  END;
END MatMult;



PROCEDURE MoveHoriz(VAR Observer, ObPoint: Point;
                    Step: REAL);
(*************************************************)
(* Move Step to the right (according to ViewDir) *)  
(*************************************************)
  VAR h: Point;
BEGIN
  Normalise(e1,h);
  Mult(h, Step, h);
  Add(Observer, h, Observer);
  Add(ObPoint,  h, ObPoint );
END MoveHoriz;
  


PROCEDURE MoveUp(VAR Observer, ObPoint: Point;
                    Step: REAL);
(***************************************)
(* Move Step up (according to ViewDir) *)  
(***************************************)
  VAR h: Point;
BEGIN
  Normalise(e2,h);
  Mult(h, Step, h);
  Add(Observer, h, Observer);
  Add(ObPoint,  h, ObPoint );
END MoveUp;
  


PROCEDURE MoveFurther(VAR Observer, ObPoint: Point;
                      Step: REAL);
(**************************)
(* Move Step into ViewDir *)  
(**************************)
  VAR h: Point;
BEGIN
  Mult(ViewDir, Step, h);
  Add(Observer, h, Observer);
  Add(ObPoint,  h, ObPoint );
END MoveFurther;



PROCEDURE Elevate(VAR Observer, ObPoint: Point;
                  Angle: REAL);
(*************************)
(* Look Angle degrees up *)  
(*************************)
  VAR
    norm: REAL;
    View,
    k,v2: Point;

BEGIN
  Subtract(ObPoint, Observer, View);
  ViewDirection(View);
  norm:= Norm(View);

  Normalise(e2,v2);

  WITH k DO 
    x1:= norm * cos(Angle);
    x2:= 0.0;
    x3:= norm * sin(Angle);
  END;

  WITH View DO
    x1:= ViewDir.x1*k.x1 + v2.x1*k.x3 ;
    x2:= ViewDir.x2*k.x1 + v2.x2*k.x3 ;
    x3:= ViewDir.x3*k.x1 + v2.x3*k.x3 ;
  END;

  Add    (Observer, View, ObPoint); (* new observed point    *)
END Elevate;



PROCEDURE Rotate(VAR Observer, ObPoint: Point;
                 Angle: REAL);
(***********************************)
(* Look Angle degrees to the right *)  
(***********************************)
  VAR
    View    : Point;
    cfi, sfi: REAL;
    m       : Matrix;

BEGIN
  cfi:= cos(Angle);
  sfi:= sin(Angle);

  WITH m DO (* create matrix for rotation *)
    x11:= cfi;  x22:= cfi; x33:= 1.0;
    x21:=-sfi;  x12:= sfi
  END;

  Subtract(ObPoint, Observer, View);
  ViewDirection(View);

  MatProd(m,View,View);             (* Rotate view direction *)
  Add    (Observer, View, ObPoint); (* new observed point    *)
END Rotate;



PROCEDURE LookAt(dx, dy: INTEGER;
                 Zoom  : REAL;
                 VAR Observer, ObPoint: Point);
(********************************************************)
(* Set new view direction, such that points with old    *)
(* projection coordinates (dx, dy) are observed now..   *)
(********************************************************)

  VAR
    norm,
    AngleY, AngleX: REAL;   (* angles to be looked 'up' and 'right' *)
    View,k,v1,v2  : Point;

BEGIN

  AngleX:= arctan( IntToReal(dx) / (Zoom*ScreenFactor) );
  AngleY:= arctan( IntToReal(dy) / (Zoom*ScreenFactor) );

  Subtract(ObPoint, Observer, View);
  norm:= Norm(View);

 (* Rotate in Y direction: *)

  ViewDirection(View);
  Normalise(e1,v1);
  Normalise(e2,v2);

  WITH k DO 
    x1:= norm * cos(AngleY);
    x2:= 0.0;
    x3:= norm * sin(AngleY);
  END;

  WITH View DO
    x1:= ViewDir.x1*k.x1 + v2.x1*k.x3 ;
    x2:= ViewDir.x2*k.x1 + v2.x2*k.x3 ;
    x3:= ViewDir.x3*k.x1 + v2.x3*k.x3 ;
  END;


 (* Rotate in X direction: *)

  ViewDirection(View);
  Normalise(e1,v1);
  Normalise(e2,v2);

  WITH k DO 
    x1:=  norm * cos(AngleX);
    x2:= -norm * sin(AngleX);
    x3:=  0.0;
  END;

  WITH View DO
    x1:= ViewDir.x1*k.x1 + v1.x1*k.x2 ;
    x2:= ViewDir.x2*k.x1 + v1.x2*k.x2 ;
    x3:= ViewDir.x3*k.x1 + v1.x3*k.x2 ;
  END;


 (* new observed point:    *)
  Add(Observer, View, ObPoint);

END LookAt;

END Vectors.




