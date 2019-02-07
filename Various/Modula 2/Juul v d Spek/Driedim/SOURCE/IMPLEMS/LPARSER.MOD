
IMPLEMENTATION MODULE LParser;

(*****************************************************)
(*                                                   *)
(*      DRIEDIM PARSER V2.1                          *)
(*      --------------------                         *)
(*                                                   *)
(*   Author: Juul v/d Spek, Valkenswaard.            *)
(*                                                   *)
(*   please do not alter this text without           *)
(*   author's permission.                            *)
(*                                                   *)
(*****************************************************)
(*                                                   *)
(* This module implements the parser for the Driedim *)
(* Object definition language.                       *)
(*                                                   *)
(*****************************************************)

  FROM String  IMPORT Strings;

  FROM InOut   IMPORT OpenInput, Write, WriteString, 
                      Read, WriteLn, WriteCard;

  FROM LLexMod IMPORT LToken, LexError, LLex, LInitWarmLex,
                      LTokenId, LPrintToken, LMakeReal,
                      LineNr, LIdenNr;

  FROM Vectors IMPORT Point, PointList, NextPoint, AddPoint,
                      Matrix, MatProd;

  FROM Objects IMPORT Alist, Part, PartList, PartKind, 
                      AddEnv, Assoc, AddPart, NextPart,
                      TrPartList, DeAllPair;

  FROM sincos  IMPORT sin, cos;

  CONST

    EnvLen= 10;          (* nr of last tokens printed out after error *)

    MaxLookahead= 2;     (* lookahead bound for parser                *)

    PiDIV180    = 3.1415926536 / 180.0;

  TYPE 
   
    SOT    = SET OF LTokenId;   (* set to remember Follow symbols *)

    
    (* circular environment table: *)

    EnvRan = [0 .. EnvLen];

    EnvT   = RECORD
               Tab: ARRAY EnvRan  OF LToken;
               Pt : EnvRan
             END;


    (* Circular lookahead table: *)

    LookaheadPt= [0 .. MaxLookahead];

    Lookahead  = RECORD
                   Tab: ARRAY LookaheadPt OF LToken;
                   b,             (* Contents of Tab:                   *)
                   e  : CARDINAL; (* first on pos  (b MOD MaxLookahead) *)
                 END;             (* last  on pos  (e MOD MaxLookahead) *)



  VAR
    ParseError: BOOLEAN;       (* set when error is encountered *)
    InputHead : Lookahead;     
    Env       : EnvT; 

(*$T-*) (*$C-*)

PROCEDURE LInitWarmParser(Fil: Strings): BOOLEAN;
(*******************************************)
(* Warm start of parser with inputfile Fil *)
(*******************************************)
  VAR i: EnvRan;
BEGIN

  (* empty lookahead table *)
  WITH InputHead DO 
    e:= 0;
    b:= 1;
  END;

  (* last tokens all set to semicolon *)
  WITH Env DO
    FOR i:= 0 TO EnvLen DO Tab[i].Sel:= LSemicolTok END;
    Pt:= 0;
  END;

  (* still no error encountered *)
  ParseError:= FALSE;

  (* start lexical with inputfile Fil *)
  RETURN LInitWarmLex(Fil);
END LInitWarmParser;


PROCEDURE LParseError(): BOOLEAN;
(*******************************)
(* tests if error has occurred *)
(*******************************)
BEGIN
  RETURN ParseError OR LexError;
END LParseError;



PROCEDURE ReadIn;
(***********************************************)
(* read next token into lookahead table        *)
(* NOTE: this token is not read by parser yet. *)
(***********************************************)
  VAR t: LToken;
BEGIN
  (* get next token from lexical: *)
  LLex(t);

  (* The following construct is added to ReadIn *)
  (* for this special parser. not standard      *)
  IF t.Sel=LIntegerTok THEN LMakeReal(t) END;

  (* put t into table of last tokens: *)
  WITH Env DO
    Pt:= (Pt+1) MOD EnvLen;
    Tab[Pt]:= t;
  END;

  (* .. and into lookahead table of course *)
  WITH InputHead DO
    e  := e+1;
    Tab[e MOD MaxLookahead]:= t
  END;

END ReadIn;



PROCEDURE LookTok(n: LookaheadPt; VAR t: LToken);
(**************************************************)
(* get value token, n positions behind token that *)
(* was last read by parser.                       *)
(**************************************************)
  VAR i: LookaheadPt;
BEGIN
  WITH InputHead DO

    (* make sure that token is present: *)
    FOR i:=1 TO n-e+b-1 DO ReadIn END;

    (* .. and return it:                *)
    t:= Tab[(b-1+n) MOD MaxLookahead];

  END;
END LookTok;



PROCEDURE ReadTok(VAR t: LToken);
(************************************)
(* Let next token be read by parser *)
(************************************)
BEGIN
  LookTok(1,t);
  WITH InputHead DO b:= b+1 END;
END  ReadTok;


PROCEDURE PeekTok(VAR t: LToken);
(************************************)
(* Peek at next input token         *)
(************************************)
BEGIN
  LookTok(1,t);
END PeekTok;




PROCEDURE Skip(Align: SOT);
(*****************************************)
(* skip tokens after error has occurred; *)
(* when Object definition or part can be *)
(* parsed, then parse it                 *)
(*****************************************)
  VAR i    : EnvRan;
      t    : LToken;
      env  : Alist;
      parts: PartList;
BEGIN
  env:= NIL;
  ParseError:= TRUE;

  (* print environment *)
  WriteString('   " ');
  WITH Env DO
    FOR i:= 1 TO EnvLen-1 DO 
      LPrintToken(Tab[ (i+Pt) MOD EnvLen ]);
    END;
  END;
  WriteString(' ".');
  WriteLn;

  (* and go to skipping mode *)
  PeekTok(t);
  WHILE NOT (t.Sel IN Align) DO
    WITH t DO
      (* recognised something?? *)
      IF Sel=LObjectTok THEN PDef(Align,env)
       ELSIF Sel IN SOT{LLineTok, LPlaneTok, LIdenTok} THEN 
         PPart(Align,env,parts)
       ELSE
        (* no. *)
        LPrintToken(t);
        WriteString('   (Skipped)'); WriteLn;
        ReadTok(t);
      END;
    END;
    PeekTok(t)
  END;

  (* synchronisation symbol encountered: *)
  WriteString('  - Synchronised on:  ');
  LPrintToken(t);
  WriteLn;
END Skip;





PROCEDURE Error(Align: SOT);
(*************************************)
(* Error: illegal symbol encountered *)
(*************************************)
BEGIN
  WriteString("*** Parse Error in line ");
  WriteCard( LineNr,1 );
  WriteString(": Unexpected Token after:");
  WriteLn;
  Skip(Align);
END Error;


PROCEDURE Synchronise(Align: SOT; t: LTokenId; VAR lt: LToken): BOOLEAN;
(************************************************)
(* check if next symbol is a token of type t.   *)
(* if not then go to skipping mode              *)
(* after that, check again, and read next token *)
(* into lt if match found.                      *)
(************************************************)
  VAR b : BOOLEAN;
BEGIN
  PeekTok(lt);
  IF lt.Sel<>t THEN
    lt.Sel:= t;
    WriteString("*** Parse Error in line ");
    WriteCard( LineNr,1 ); WriteString(": ");
    IF t=LIdenTok THEN WriteString('Identifier')
     ELSE 
      Write('"');
      LPrintToken(lt);
      WriteString(' " ');
    END;
    WriteString(' expected after:');
    WriteLn;
    INCL(Align,t);
    Skip(Align);
    PeekTok(lt);
  END;
  b:= lt.Sel=t;
  IF lt.Sel=t THEN ReadTok(lt) END;
  RETURN b;
END  Synchronise;


(****************************************************************)
(*                 end of general stuf                          *)
(****************************************************************)


PROCEDURE PPoint(Align: SOT; VAR p: Point);
  VAR nxt: LToken;
BEGIN
  PeekTok(nxt);  
  WITH p DO
    IF nxt.Sel#LRealTok THEN Error(Align)
     ELSE
      ReadTok(nxt);
      x1:= nxt.RealVal;
      PeekTok(nxt);
      IF nxt.Sel#LRealTok THEN Error(Align)
       ELSE
        ReadTok(nxt);
        x2:= nxt.RealVal;
        PeekTok(nxt);
        IF nxt.Sel#LRealTok THEN Error(Align)
          ELSE
          ReadTok(nxt);
          x3:= nxt.RealVal
        END
      END
    END
  END
END PPoint;


PROCEDURE PObjectPart(Align: SOT; Env: Alist; VAR l: PartList);
  VAR nxt       : LToken;
      t         : LTokenId;
      M         : Matrix;
      cfi,sfi,
      rot       : REAL;
      parts     : PartList;
      at,times,p: Point;

  PROCEDURE Append(VAR l1: PartList; l2: PartList);
  BEGIN
    IF l1=NIL THEN l1:= l2
     ELSE Append(l1^.Tail, l2)
    END
  END Append;

BEGIN

  (* initialisation and defaults: *)
  rot:= 0.0;                                     (* no rotation       *)
  WITH at    DO x1:=0.0; x2:=0.0; x3:=0.0 END;   (* no translation    *)
  WITH times DO x1:=1.0; x2:=1.0; x3:=1.0 END;   (* no multiplication *)

  (* object identifier: *)
  ReadTok(nxt);
  parts:= Assoc(Env, nxt.IdenVal);    
  IF parts=NIL THEN (* Error: unknown object *)
    WriteString(" *** Error: Unknown Object ");
    LPrintToken(nxt);
    WriteString(" encountered in line ");
    WriteCard(LineNr,1);
    WriteLn;
    ParseError:= TRUE
  END;

  (* process transformation parameters: *)
  PeekTok(nxt);
  WHILE nxt.Sel IN SOT{LAtTok, LTimesTok, LTurnTok} DO
    ReadTok(nxt);
    t:= nxt.Sel;
    PeekTok(nxt);
    IF nxt.Sel#LRealTok THEN Error(Align)
     ELSE
      CASE t OF
         LAtTok   : PPoint(Align, at   ) |
         LTimesTok: PPoint(Align, times) |
         LTurnTok : ReadTok(nxt); rot  := nxt.RealVal*PiDIV180
       END;
    END;
    PeekTok(nxt);
  END;

  IF NOT ParseError THEN
    cfi:= cos(rot);
    sfi:= sin(rot);

    WITH M DO
      WITH times DO
        x11:= x1*cfi; x22:= x2*cfi; x33:= x3;
        x21:= x1*sfi; x12:=-x2*sfi
      END;
    END;

    Append(l, TrPartList(parts, at, M));
    
  END;
END PObjectPart;
      

PROCEDURE PPlanePart(Align: SOT; VAR l: PartList);
  VAR part: Part;
      nxt : LToken;
      p   : Point;
      b,
      intern: BOOLEAN;  (* To flag if INTERN was specified *)
BEGIN
  INCL(Align, LCommaTok);
  INCL(Align, LPlaneEndTok);
  ReadTok(nxt);        (* PLANE *)

  WITH part DO
    Sel:= Plane;

    (* INTERN? *)
    PeekTok(nxt);
    IF nxt.Sel=LInternTok THEN
      ReadTok(nxt);
      PPoint(Align, int);
      b:= Synchronise(Align,LCommaTok,nxt);
      intern:= TRUE
     ELSE
      intern:= FALSE
    END;    

    (* contour (at least 3 points):             *)   
    (* use first point for default intern point *)
    plane:= NIL;
    PPoint(Align, p); AddPoint(plane,p);
    IF NOT intern THEN int:= p END;

    IF Synchronise(Align,LCommaTok, nxt) THEN
      PPoint(Align, p); AddPoint(plane,p);
      IF Synchronise(Align,LCommaTok, nxt) THEN
        PPoint(Align, p); AddPoint(plane,p);
        PeekTok(nxt);
        WHILE nxt.Sel=LCommaTok DO
          ReadTok(nxt);
          PPoint(Align, p); AddPoint(plane,p);
          PeekTok(nxt);
        END;
    
        b:= Synchronise(Align, LPlaneEndTok, nxt)
      END;
    END;
  END;

  AddPart(l,part);
END PPlanePart;
 


PROCEDURE PLinePart(Align: SOT; VAR l: PartList);
  VAR part: Part;
      nxt : LToken;
      p   : Point;
      b   : BOOLEAN;
BEGIN
  INCL(Align, LCommaTok);
  INCL(Align, LLineEndTok);
  ReadTok(nxt);        (* "LINE" *)

  WITH part DO
    Sel:= Line;

    (* line (at least 2 points: *)
    line:= NIL;
    PPoint(Align, p); AddPoint(line,p);
    IF Synchronise(Align,LCommaTok, nxt) THEN
      PPoint(Align, p); AddPoint(line,p);
      PeekTok(nxt);
      WHILE nxt.Sel=LCommaTok DO
        ReadTok(nxt);
        PPoint(Align, p); AddPoint(line,p);
        PeekTok(nxt);
      END;
      b:= Synchronise(Align, LLineEndTok, nxt)
    END;
  END;

  AddPart(l, part);
END PLinePart;
 

PROCEDURE PPart(Align: SOT; Env: Alist; VAR l: PartList);
  VAR nxt: LToken;
BEGIN
  PeekTok(nxt);
  WITH nxt DO
       IF Sel=LLineTok   THEN PLinePart  (Align,l)     
    ELSIF Sel=LPlaneTok  THEN PPlanePart (Align,l)    
    ELSIF Sel=LIdenTok   THEN PObjectPart(Align,Env,l)    
    ELSE   Error(Align)  END;
  END;
END PPart;


PROCEDURE PPartList(Align: SOT; Env: Alist; VAR l: PartList);
  VAR nxt : LToken;
      part: Part;
BEGIN
  INCL(Align, LSemicolTok);
  l:= NIL;
  PPart(Align, Env, l);
  PeekTok(nxt);
  WHILE nxt.Sel=LSemicolTok DO
    ReadTok(nxt);
    PPart(Align, Env, l);
    PeekTok(nxt)
  END;
END PPartList;

PROCEDURE PDef(Align: SOT; VAR Env: Alist);
  VAR nxt : LToken;
      hEnv: Alist;    (* local environment            *)
      obj : LIdenNr;  (* name of object to be defined *)
      prts: PartList; (* partlist of new object       *)
      b   : BOOLEAN;
BEGIN
  INCL(Align, LObendTok);
  IF Synchronise(Align, LObjectTok, nxt) THEN
    IF Synchronise(Align, LIdenTok, nxt) THEN

      hEnv:= Env;          (* local env initialised to Env *)
      prts:= NIL;          (* empty partlist yet           *)
      obj := nxt.IdenVal;  (* name just parsed             *)
      IF Synchronise(Align, LEqualTok, nxt) THEN
        PeekTok(nxt);
        WHILE nxt.Sel=LObjectTok DO
           PDef(Align, hEnv); (* add new object def to local env *)
           b:= Synchronise(Align, LSemicolTok, nxt);
           PeekTok(nxt)
        END;           
       
        (* get partlist with local env: *)
        PPartList(Align, hEnv, prts);

        (* Deallocate all local items:  *)
        (* Only if no errors occurred   *)
        IF NOT ParseError THEN
          WHILE hEnv#Env DO  DeAllPair(hEnv) END;
        END;

        (* add new definition to Env parameter: *)
        AddEnv(Env, obj, prts);

        b:= Synchronise(Align, LObendTok, nxt)
      END;
    END;
  END;
END PDef;


PROCEDURE ReadObject(): PartList;
  VAR Env: Alist;
BEGIN

  Env:= NIL;
  PDef(SOT{LEofTok, LSemicolTok}, Env);

  IF Env#NIL THEN RETURN Env^.Head.Contents
   ELSE RETURN NIL
  END
END ReadObject;



PROCEDURE ReadHeapSize(): LONGCARD;
(**************************************************)
(* Parses '[ "HEAPSIZE" number ";" ]' and returns *)
(* the number, or 0 if none specified.            *)
(**************************************************)
  TYPE Tricky=(* It is a shame how we have to convert *)
              (* between different number types in    *)
              (* MODULA-2.                            *) 
              RECORD 
                 CASE BOOLEAN OF
                   TRUE : c1,c2: CARDINAL  |
                   FALSE: c    : LONGCARD;
                 END
              END;

  VAR nxt : LToken;
      buff: Tricky;
      b   : BOOLEAN;
BEGIN
  PeekTok(nxt);

  IF nxt.Sel=LHeapSizeTok THEN
    ReadTok(nxt);
    IF Synchronise(SOT{LEofTok, LSemicolTok}, LRealTok, nxt) THEN
      IF (nxt.RealVal>0.0) AND (nxt.RealVal<1000.0) THEN
        buff.c1:= 0;
        buff.c2:= TRUNC(nxt.RealVal);
        b:= Synchronise(SOT{LEofTok}, LSemicolTok, nxt);
        RETURN buff.c
       ELSE
        WriteString("** Illegal workspace size encountered.");
        WriteLn;
        RETURN 0
      END
     ELSE RETURN 0
    END
   ELSE RETURN 0
  END;
END ReadHeapSize;

END LParser.

 
 

 


