{ Funktions Plotter 1.1 9/89 und 2/90 fÅr Pascal+ 2.07 }
{ (C) by Dirk Sabiwalsky                               }

{ Linke: FKT_C.LIB
         ERRNO.LIB
         GDOS_REQ.LIB }

{$S300}

PROGRAM Funktions_Plotter;

CONST {$I GEMCONST.PAS}
      OldPath  = 0;
      SetPath  = 1;
      Pi       = 3.141592654;
      ROMBERG  = 1;
      TRAPEZ   = 0;
      MaxReal  = 1.0E38;
      MinReal  = -1.0E38;
      MaxFLen  = 200;         { Maximale LÑnge eins Funktionsterms    }
      MaxVar   = 26;          { Maximale Stelligkeit einer Funktion   }
      MaxKonst = 20;          { Maximale Anzahl von Konstanten        }
      MaxFkt   = 10;          { Maximale Anzahl von Funktionen        }
      TxtLen   = 70;          { LÑnge einer Funktionstextzeile        }
      MaxRek   = 20;          { Maximale Rekursionstiefe bei Aufrufen }
                              { von Makros                            }
      Max_xAuf = 32767;       { Maximale x-Auflîsung                  }

      { Objektnamen ... }
      {$I FKTPLOT.I}

TYPE {$I GEMTYPE.PAS}
     Dest_Types  = (Screen,Metafile);
     Fun_Enum = (F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,
                 FSIN,FCOS,FTAN,FASIN,FACOS,FATAN,
                 FEXP,FLN,FSQR,FSQRT,FABS,FSGN,FILLEGAL);
     TElement = (Operator,FunCall,Number,Constant,Variable);
     FTree = ^FTNode;
     FTNode= RECORD
              CASE NType : TElement OF
               Operator : (OpType         : CHAR;
                           OpLeft,OpRight : FTree);
               FunCall  : (FunNum   : Fun_Enum;
                           FunParam : FTree);
               Number   : (NumValue : REAL);
               Constant : (ConName : STRING[10]);
               Variable : ();
             END; { FTNode }

     Konsttyp  = RECORD
                  Ko_Name : STRING[10];
                  Ko_Wert : REAL
                 END;

     CKonsttyp = RECORD
                  CKo_Name : STRING[10];
                  CKo_Wert : STRING[20];
                 END;

     KonstArray  = ARRAY [1..MaxKonst] OF Konsttyp;
     CKonstArray = ARRAY [1..MaxKonst] OF CKonsttyp;
     FktArray    = ARRAY [1..MaxFkt] OF FTree;
     TermArray   = ARRAY [1..MaxFkt] OF STRING[255];
     StateSet    = ARRAY[1..MaxFkt] OF INTEGER;

     Str20   = STRING[20];
     Str128  = STRING[128];
     CString = PACKED ARRAY [0..255] OF CHAR;

VAR Konst          : KonstArray;
    FktPtr         : FktArray;
    FktTerm        : TermArray;
    Draw_Dest      : Dest_Types;
    S_Auto,
    Bee_Active     : BOOLEAN;
    xAkt,yAkt,
    xAuf,yAuf,
    handle,meta_nr : INTEGER;
    { Skalierungsgrenzen, etc. }
    S_xl,S_xh,
    S_yl,S_yh,
    Int_low,
    Int_up,
    Int_tol        : REAL;
    Meta_Name,
    ParPfad,ParName: Str128;
    { ResourcebÑume }
    M_Main         : Menu_Ptr;
    D_Info,
    D_Choice,
    D_Edit,
    D_Show,
    D_Konst,
    D_Scale,
    D_Error,
    D_Int,
    D_IShow,
    D_IChoice,
    D_Draw,
    D_Wait         : Dialog_Ptr;
    y_koords       : ARRAY[0..Max_xAuf] OF REAL;

{$I GEMSUBS.PAS}
{$I TOSEXT.PAS}
{$I FKT_C.PAS}

FUNCTION GDOS_Here : BOOLEAN;
EXTERNAL;


PROCEDURE Bing;
BEGIN
 Write(Chr(7))
END; { Bing }

PROCEDURE Bee;
BEGIN
 Set_Mouse(M_Bee);
 Show_Mouse;
 Bee_Active:=TRUE;
END;

PROCEDURE No_Bee;
BEGIN
 Hide_Mouse;
 Set_Mouse(M_Arrow);
 Bee_Active:=FALSE;
END;

PROCEDURE Fehler(msg : STRING);
VAR was_bee  : BOOLEAN;
    Exit_Obj : INTEGER;
BEGIN
 IF Length(msg)>50
  THEN BEGIN
        msg:=Copy(msg,1,45);
        msg:=Concat(msg,'...')
       END;
 Bing;
 Set_DText(D_Error,FUERRTXT,msg,SYSTEM_FONT,TE_CENTER);
 Center_Dialog(D_Error);
 was_bee:=Bee_Active;
 IF Bee_Active THEN No_Bee;
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_Error,0);
 Hide_Mouse;
 IF was_bee THEN Bee;
 Obj_SetState(D_Error,Exit_Obj,NORMAL,FALSE);
 End_Dialog(D_Error)
END; { Fehler }

PROCEDURE Show_Wait;
BEGIN
 Center_Dialog(D_Wait);
 Show_Dialog(D_Wait);
END; { Show_Wait }

FUNCTION UpCase(Ch : CHAR) : CHAR;
BEGIN
 IF Ch IN ['a'..'z']
  THEN UpCase:=Chr(Ord(Ch)-32)
  ELSE CASE Ch OF
        'Ñ' : UpCase:='é';
        'î' : UpCase:='ô';
        'Å' : UpCase:='ö';
        ELSE UpCase:=Ch
       END
END; { UpCase }

PROCEDURE Str_UpCase(VAR s : Str255);
VAR i : INTEGER;
BEGIN
 FOR i:=1 TO Length(s) DO s[i]:=UpCase(s[i])
END; { Str_UpCase }

{ Termoperationen }

PROCEDURE Term_Extract(Term : Str255; TStart,TEnd : INTEGER; VAR s : STRING);
BEGIN
 IF (TStart<=TEnd) AND (1+(TEnd-TStart)<80)
  THEN s:=Copy(Term,TStart,1+(TEnd-TStart))
  ELSE s:='EMPTY'
END; { Term_Extract }

FUNCTION Parens_Ok(VAR Term        : Str255;
                   VAR TStart,TEnd : INTEGER) : BOOLEAN;
VAR p,PLevel      : INTEGER;
    PError,No_Del : BOOLEAN;
BEGIN
 IF (Term[TStart]='(') AND (Term[TEnd]=')')
  THEN BEGIN
        PLevel:=0;
        No_Del:=FALSE;
        FOR p:=TStart TO TEnd DO
        BEGIN
         IF Term[p]='('
          THEN PLevel:=PLevel+1
          ELSE IF Term[p]=')' THEN PLevel:=PLevel-1;
         IF (PLevel<1) AND (p<TEnd) THEN No_Del:=TRUE
        END;
        IF NOT No_Del
         THEN BEGIN
               { Reihenfolge der Deletes ist wichtig ! }
               Delete(Term,TEnd,1);
               TEnd:=TEnd-2;
               Delete(Term,TStart,1)
              END
       END;
 PLevel:=0;
 PError:=FALSE;
 FOR p:=TStart TO TEnd DO
 BEGIN
  IF Term[p]='('
   THEN PLevel:=PLevel+1
   ELSE IF Term[p]=')' THEN PLevel:=PLevel-1;
  IF PLevel<0 THEN PError:=TRUE
 END;
 Parens_Ok:=NOT (PError OR (PLevel<>0) OR (TStart>TEnd))
END; { Parens_Ok }

FUNCTION Search_Op(    Term        : Str255;
                       TStart,TEnd : INTEGER;
                       OpStr       : STRING;
                   VAR p           : INTEGER) : BOOLEAN;
VAR PLevel : INTEGER;
    Found  : BOOLEAN;
BEGIN
 p:=TEnd+1;
 Found:=FALSE;
 PLevel:=0;
 REPEAT
  p:=p-1;
  CASE Term[p] OF
   '(' : Plevel:=PLevel+1;
   ')' : PLevel:=PLevel-1;
   ELSE IF (PLevel=0) AND (Pos(Term[p],OpStr)>0) AND (p>=TStart)
         THEN Found:=TRUE
  END { CASE }
 UNTIL Found OR (p=TStart);
 Search_Op:=Found
END; { Search_Op }

FUNCTION Check_FName(Name : STRING) : Fun_Enum;
BEGIN
 IF Name='F1' THEN Check_FName:=F1 ELSE
 IF Name='F2' THEN Check_FName:=F2 ELSE
 IF Name='F3' THEN Check_FName:=F3 ELSE
 IF Name='F4' THEN Check_FName:=F4 ELSE
 IF Name='F5' THEN Check_FName:=F5 ELSE
 IF Name='F6' THEN Check_FName:=F6 ELSE
 IF Name='F7' THEN Check_FName:=F7 ELSE
 IF Name='F8' THEN Check_FName:=F8 ELSE
 IF Name='F9' THEN Check_FName:=F9 ELSE
 IF Name='F10' THEN Check_FName:=F10 ELSE
 IF Name='SIN' THEN Check_FName:=FSIN ELSE
 IF Name='COS' THEN Check_FName:=FCOS ELSE
 IF Name='TAN' THEN Check_FName:=FTAN ELSE
 IF Name='ASIN' THEN Check_FName:=FASIN ELSE
 IF Name='ACOS' THEN Check_FName:=FACOS ELSE
 IF Name='ATAN' THEN Check_FName:=FATAN ELSE
 IF Name='EXP' THEN Check_FName:=FEXP ELSE
 IF Name='LN' THEN Check_FName:=FLN ELSE
 IF Name='SQR' THEN Check_FName:=FSQR ELSE
 IF Name='SQRT' THEN Check_FName:=FSQRT ELSE
 IF Name='ABS' THEN Check_FName:=FABS ELSE
 IF Name='SGN' THEN Check_FName:=FSGN ELSE
 Check_FName:=FILLEGAL
END; { Check_FName }

FUNCTION Term_Func(    Term        : Str255;
                       TStart,TEnd : INTEGER;
                   VAR FStart,FEnd : INTEGER;
                   VAR FNumber     : Fun_Enum) : BOOLEAN;
VAR POpen : INTEGER;
    TName : STRING;
BEGIN
 IF Term[TEnd]=')'                                { endet <Term> mit ')' ??? }
  THEN BEGIN
        Term_Extract(Term,TStart,TEnd,TName);
        POpen:=Pos('(',TName);
        IF POpen>1                                { steht eine ')' irgendwo  }
         THEN BEGIN                               { hinter der 1. Stelle ??? }
               FStart:=(TStart+POpen);            { Anfang des Parameter-Terms }
               FEnd:=TEnd-1;                      { Ende des Parameter-Terms }
               TName:=Copy(TName,1,POpen-1);      { Funktionsname }
               FNumber:=Check_FName(TName);       { Funktionsname erlaubt ??? }
               IF FNumber<>FILLEGAL
                THEN Term_Func:=TRUE
                ELSE Term_Func:=FALSE
              END
         ELSE Term_Func:=FALSE
       END
  ELSE Term_Func:=FALSE
END; { Term_Func }

FUNCTION Term_Var(Term : Str255; TStart,TEnd : INTEGER) : BOOLEAN;
BEGIN
 Term_Var:=(TStart=TEnd) AND (Term[TStart]='X')
END; { Term_Var }

FUNCTION Term_Const(    Term        : Str255;
                        TStart,TEnd : INTEGER;
                    VAR CName       : STRING) : BOOLEAN;
VAR i   : INTEGER;
    Tok : BOOLEAN;
BEGIN
 Term_Extract(Term,TStart,TEnd,CName);
 Tok:=CName[1] IN ['A'..'Z'];
 FOR i:=2 TO Length(CName) DO
  Tok:=Tok AND (CName[i] IN ['0'..'9','A'..'Z','_']);
 Term_Const:=Tok
END; { Term_Const }

FUNCTION atof(VAR s : Str255; VAR r : REAL) : BOOLEAN;
BEGIN
 IO_Check(FALSE);
 ReadV(s,r);
 atof:=IO_Result=0;
 IO_Check(TRUE)
END; { atof }

FUNCTION atoi(VAR s : Str255; VAR i : INTEGER) : BOOLEAN;
BEGIN
 IO_Check(FALSE);
 ReadV(s,i);
 atoi:=IO_Result=0;
 IO_Check(TRUE)
END; { atof }

FUNCTION Term_Number(    Term        : Str255;
                         TStart,TEnd : INTEGER;
                     VAR NValue      : REAL) : BOOLEAN;
VAR TName : Str255;
BEGIN
 Term_Extract(Term,TStart,TEnd,TName);
 Term_Number:=atof(TName,NValue)
END; { Term_Number }

{ Baumkonstruktoren }

FUNCTION Make_OpNode(Op : CHAR; TLeft,TRight : FTree) : FTree;
VAR New_Node : FTree;
BEGIN
 New(New_Node);
 IF New_Node<>NIL
  THEN WITH New_Node^ DO
       BEGIN
        NType:=Operator;
        OpType:=Op;
        OpLeft:=TLeft;
        OpRight:=TRight
       END
  ELSE Fehler('Zu wenig Speicher !');
 Make_OpNode:=New_Node
END; { Make_OpNode }

FUNCTION AtomP(T : FTree) : BOOLEAN;
BEGIN
 IF T<>NIL THEN AtomP:=T^.NType IN [Variable,Constant,Number,FunCall]
           ELSE AtomP:=TRUE
END; { AtomP }

FUNCTION Make_Number(NValue : REAL) : FTree;
VAR New_Node : FTree;
BEGIN
 New(New_Node);
 IF New_Node<>NIL
  THEN WITH New_Node^ DO
       BEGIN
        NType:=Number;
        NumValue:=NValue
       END
  ELSE Fehler('Zu wenig Speicher !');
 Make_Number:=New_Node
END; { Make_Number }

FUNCTION NumberP(T : FTree) : BOOLEAN;
BEGIN
 IF T<>NIL THEN NumberP:=T^.NType=Number
           ELSE NumberP:=FALSE
END; { NumberP }

FUNCTION Make_Sum(TLeft,TRight : FTree) : FTree;
BEGIN
 IF NumberP(TLeft) AND NumberP(TRight)
  THEN Make_Sum:=Make_Number(TLeft^.NumValue+TRight^.NumValue)
  ELSE IF NumberP(TLeft)
        THEN IF TLeft^.NumValue=0
              THEN Make_Sum:=TRight
              ELSE Make_Sum:=Make_OpNode('+',TLeft,TRight)
        ELSE IF NumberP(TRight)
              THEN IF TRight^.NumValue=0
                    THEN Make_Sum:=TLeft
                    ELSE Make_Sum:=Make_OpNode('+',TLeft,TRight)
              ELSE Make_Sum:=Make_OpNode('+',TLeft,TRight)
END; { Make_Sum }

FUNCTION Make_Difference(TLeft,TRight : FTree) : FTree;
BEGIN
 IF NumberP(TLeft) AND NumberP(TRight)
  THEN Make_Difference:=Make_Number(TLeft^.NumValue-TRight^.NumValue)
  ELSE IF NumberP(TRight)
        THEN IF TRight^.NumValue=0
              THEN Make_Difference:=TLeft
              ELSE Make_Difference:=Make_OpNode('-',TLeft,TRight)
        ELSE Make_Difference:=Make_OpNode('-',TLeft,TRight)
END; { Make_Difference }

FUNCTION Make_Product(TLeft,TRight : FTree) : FTree;
BEGIN
 IF NumberP(TLeft) AND NumberP(TRight)
  THEN Make_Product:=Make_Number(TLeft^.NumValue*TRight^.NumValue)
  ELSE IF NumberP(TLeft)
        THEN IF TLeft^.NumValue=0
              THEN Make_Product:=Make_Number(0)
              ELSE IF TLeft^.NumValue=1
                    THEN Make_Product:=TRight
                    ELSE Make_Product:=Make_OpNode('*',TLeft,TRight)
        ELSE IF NumberP(TRight)
              THEN IF TRight^.NumValue=0
                    THEN Make_Product:=Make_Number(0)
                    ELSE IF TRight^.NumValue=1
                          THEN Make_Product:=TLeft
                          ELSE Make_Product:=Make_OpNode('*',TLeft,TRight)
              ELSE Make_Product:=Make_OpNode('*',TLeft,TRight)
END; { Make_Product }

FUNCTION Make_Division(TLeft,TRight : FTree) : FTree;
BEGIN
 IF NumberP(TLeft) AND NumberP(TRight)
  THEN IF TRight^.NumValue<>0
        THEN Make_Division:=Make_Number(TLeft^.NumValue/TRight^.NumValue)
        ELSE Make_Division:=Make_OpNode('/',TLeft,TRight)   { Division durch Null }
  ELSE IF NumberP(TLeft)
        THEN IF TLeft^.NumValue=0
              THEN Make_Division:=Make_Number(0)
              ELSE Make_Division:=Make_OpNode('/',TLeft,TRight)
        ELSE IF NumberP(TRight)
              THEN IF TRight^.NumValue=0
                    THEN Make_Division:=Make_OpNode('/',TLeft,TRight)  { Division durch Null }
                    ELSE IF TRight^.NumValue=1
                          THEN Make_Division:=TLeft
                          ELSE Make_Division:=Make_OpNode('/',TLeft,TRight)
              ELSE Make_Division:=Make_OpNode('/',TLeft,TRight)
END; { Make_Division }

FUNCTION Power(Base,Expo : REAL) : REAL;
VAR m : REAL;
BEGIN
 IF Base<0
  THEN BEGIN
        m:=-1.0;
        IF Expo=Round(Expo)
         THEN IF NOT Odd(Round(Expo))
               THEN m:=1;
        Base:=Abs(Base)
       END
  ELSE m:=1.0;
 IF Base>0 THEN Power:=m*Exp(Expo*Ln(Base))
           ELSE Power:=0
END; { Power }

FUNCTION Make_Expo(TLeft,TRight : FTree) : FTree;
BEGIN
 IF NumberP(TLeft) AND NumberP(TRight)
  THEN Make_Expo:=Make_Number(Power(TLeft^.NumValue,TRight^.NumValue))
  ELSE IF NumberP(TLeft)
        THEN IF TLeft^.NumValue=0
              THEN Make_Expo:=Make_Number(0)
              ELSE IF TLeft^.NumValue=1
                    THEN Make_Expo:=Make_Number(1)
                    ELSE Make_Expo:=Make_OpNode('^',TLeft,TRight)
        ELSE IF NumberP(TRight)
              THEN IF TRight^.NumValue=0
                    THEN Make_Expo:=Make_Number(1)
                    ELSE IF TRight^.NumValue=1
                          THEN Make_Expo:=TLeft
                          ELSE Make_Expo:=Make_OpNode('^',TLeft,TRight)
              ELSE Make_Expo:=Make_OpNode('^',TLeft,TRight)
END; { Make_Expo }

FUNCTION Make_Function(FNumber : Fun_Enum; FParam : FTree) : FTree;
VAR New_Node : FTree;
BEGIN
 New(New_Node);
 IF New_Node<>NIL
  THEN WITH New_Node^ DO
       BEGIN
        NType:=FunCall;
        FunNum:=FNumber;
        FunParam:=FParam;
       END
  ELSE Fehler('Zu wenig Speicher !');
 Make_Function:=New_Node
END; { Make_Function }

FUNCTION Make_Variable : FTree;
VAR New_Node : FTree;
BEGIN
 New(New_Node);
 IF New_Node<>NIL
  THEN New_Node^.NType:=Variable
  ELSE Fehler('Zu wenig Speicher !');
 Make_Variable:=New_Node
END; { Make_Variable }

FUNCTION Make_Constant(CName : Str255) : FTree;
VAR New_Node : FTree;
BEGIN
 New(New_Node);
 IF New_Node<>NIL
  THEN WITH New_Node^ DO
       BEGIN
        NType:=Constant;
        IF Length(CName)<10
         THEN ConName:=CName
         ELSE ConName:=Copy(CName,1,9)
       END
  ELSE Fehler('Zu wenig Speicher !');
 Make_Constant:=New_Node
END; { Make_Constant }

{ Baumaufbau }

FUNCTION Build_Tree(    Term   : Str255;
                    VAR TError : BOOLEAN) : FTree;
VAR ErrMsg  : STRING;

 FUNCTION Make_FTree(    Term        : Str255;
                         TStart,TEnd : INTEGER;
                     VAR TError      : BOOLEAN) : FTree;
 VAR p,
     FStart,FEnd : INTEGER;
     FNumber     : Fun_Enum;
     Name        : Str255;
     NValue      : REAL;
 BEGIN
  IF TError
   THEN Make_FTree:=NIL
   ELSE
  IF Length(Term)=0
   THEN BEGIN
         Make_FTree:=NIL;
         ErrMsg:='TermlÑnge 0';
         TError:=TRUE
        END
   ELSE
  IF TStart>TEnd
   THEN Make_FTree:=NIL
   ELSE
  IF NOT Parens_Ok(Term,TStart,TEnd)
   THEN BEGIN
         Make_FTree:=NIL;
         ErrMsg:=Concat('Falsche Klammerung');
         TError:=TRUE
        END
   ELSE
  IF Search_Op(Term,TStart,TEnd,'+',p)
   THEN Make_FTree:=Make_Sum(Make_FTree(Term,TStart,p-1,TError),
                             Make_FTree(Term,p+1,TEnd,TError))
   ELSE
  IF Search_Op(Term,TStart,TEnd,'-',p)
   THEN Make_FTree:=Make_Difference(Make_FTree(Term,TStart,p-1,TError),
                                    Make_FTree(Term,p+1,TEnd,TError))
   ELSE
  IF Search_Op(Term,TStart,TEnd,'*',p)
   THEN Make_FTree:=Make_Product(Make_FTree(Term,TStart,p-1,TError),
                                 Make_FTree(Term,p+1,TEnd,TError))
   ELSE
  IF Search_Op(Term,TStart,TEnd,'/',p)
   THEN Make_FTree:=Make_Division(Make_FTree(Term,TStart,p-1,TError),
                                  Make_FTree(Term,p+1,TEnd,TError))
   ELSE
  IF Search_Op(Term,TStart,TEnd,'^',p)
   THEN Make_FTree:=Make_Expo(Make_FTree(Term,TStart,p-1,TError),
                              Make_FTree(Term,p+1,TEnd,TError))
   ELSE
  IF Term_Func(Term,TStart,TEnd,FStart,FEnd,FNumber)
   THEN Make_FTree:=Make_Function(FNumber,Make_FTree(Term,FStart,FEnd,TError))
   ELSE
  IF Term_Var(Term,TStart,TEnd)
   THEN Make_FTree:=Make_Variable
   ELSE
  IF Term_Const(Term,TStart,TEnd,Name)
   THEN Make_FTree:=Make_Constant(Name)
   ELSE
  IF Term_Number(Term,TStart,TEnd,NValue)
   THEN Make_FTree:=Make_Number(NValue)
   ELSE BEGIN
         Make_FTree:=NIL;
         Term_Extract(Term,TStart,TEnd,Name);
         ErrMsg:=Concat('Unbekanntes Objekt:',Name);
         TError:=TRUE
        END
 END; { Make_FTree }

BEGIN
 TError:=FALSE;
 Bee;
 Build_Tree:=Make_FTree(Term,1,Length(Term),TError);
 No_Bee;
 IF TError THEN BEGIN
                 Fehler(ErrMsg);
                 Build_Tree:=NIL
                END
END; { Build_Tree }

{ Baumspeicher zurÅckgeben }

PROCEDURE FTree_Free(T : FTree);
BEGIN
 IF T<>NIL
  THEN IF T^.NType IN [Variable,Constant,Number]
        THEN { Dispose(T) }
        ELSE IF T^.NType=Operator
              THEN BEGIN
                    FTree_Free(T^.OpLeft);
                    FTree_Free(T^.OpRight);
                    { Dispose(T) }
                   END
              ELSE IF T^.NType=FunCall
                    THEN BEGIN
                          FTree_Free(T^.FunParam);
                          { Dispose(T) }
                         END
                    ELSE Fehler('Unvorhergesehener Fall #1 !')
END;

{ Baumberechnung }

FUNCTION Get_Constant(CName : Str255; VAR x : REAL) : BOOLEAN;
VAR i     : INTEGER;
    Found : BOOLEAN;
BEGIN
 Found:=FALSE;
 FOR i:=1 TO MaxKonst DO
  IF CName=Konst[i].Ko_Name
   THEN BEGIN
         x:=Konst[i].Ko_Wert;
         Found:=TRUE
        END;
 Get_Constant:=Found
END; { Get_Constant }

FUNCTION Calc_Tree(T : FTree; x : REAL; VAR CError : BOOLEAN) : REAL;
VAR ErrMsg : STRING;

 FUNCTION Calc_FTree(T : FTree; x : REAL; VAR CError : BOOLEAN; CLevel : INTEGER) : REAL;
 VAR v,v1 : REAL;
 BEGIN
  IF (T<>NIL) AND (NOT CError) AND (CLevel<MaxRek)
   THEN WITH T^ DO
         CASE NType OF
          Operator: CASE OpType OF
                     '+' : Calc_FTree:=Calc_FTree(OpLeft,x,CError,CLevel)+Calc_FTree(OpRight,x,CError,CLevel);
                     '-' : Calc_FTree:=Calc_FTree(OpLeft,x,CError,CLevel)-Calc_FTree(OpRight,x,CError,CLevel);
                     '*' : Calc_FTree:=Calc_FTree(OpLeft,x,CError,CLevel)*Calc_FTree(OpRight,x,CError,CLevel);
                     '/' : BEGIN
                            v:=Calc_FTree(OpRight,x,CError,CLevel);
                            IF v<>0
                             THEN Calc_FTree:=Calc_FTree(OpLeft,x,CError,CLevel)/v
                             ELSE BEGIN
                                   ErrMsg:='Division durch 0 !';
                                   CError:=TRUE
                                  END
                           END;
                     '^' : BEGIN
                            v:=Calc_FTree(OpLeft,x,CError,CLevel);
                            v1:=Calc_FTree(OpRight,x,CError,CLevel);
                            IF v<0
                             THEN IF v1=Round(v1)
                                   THEN Calc_FTree:=Power(v,v1)
                                   ELSE BEGIN
                                         ErrMsg:='Negative Basis !';
                                         CError:=TRUE
                                        END
                             ELSE Calc_FTree:=Power(v,v1)
                           END
                    END; { CASE OpType }
          FunCall : CASE FunNum OF
                     FSIN     : Calc_FTree:=Sin(Calc_FTree(FunParam,x,CError,CLevel));
                     FCOS     : Calc_FTree:=Cos(Calc_FTree(FunParam,x,CError,CLevel));
                     FTAN     : BEGIN
                                 v:=Calc_FTree(FunParam,x,CError,CLevel);
                                 IF v*2/Pi<>Round(v*2/Pi)
                                  THEN Calc_FTree:=sin(v)/cos(v)
                                  ELSE BEGIN
                                        ErrMsg:='Tangens nicht definiert !';
                                        CError:=TRUE
                                       END
                                END;
                     FASIN    : BEGIN
                                 v:=Calc_FTree(FunParam,x,CError,CLevel);
                                 IF (v>-1) AND (v<1)
                                  THEN Calc_FTree:=Arctan(v/Sqrt(1-Sqr(v)))
                                  ELSE IF v=-1
                                        THEN Calc_FTree:=-Pi/2
                                        ELSE IF v=1
                                              THEN Calc_FTree:=Pi/2
                                              ELSE BEGIN
                                                    ErrMsg:='Arcus Sinus nicht definiert !';
                                                    CError:=TRUE
                                                   END
                                END;
                     FACOS    : BEGIN
                                 v:=Calc_FTree(FunParam,x,CError,CLevel);
                                 IF (v>-1) AND (v<1)
                                  THEN Calc_FTree:=Pi/2-Arctan(v/Sqrt(1-Sqr(v)))
                                  ELSE IF v=-1
                                        THEN Calc_FTree:=Pi
                                        ELSE IF v=1
                                              THEN Calc_FTree:=0
                                              ELSE BEGIN
                                                    ErrMsg:='Arcus Cosinus nicht definiert !';
                                                    CError:=TRUE
                                                   END
                                END;
                     FATAN    : Calc_FTree:=Arctan(Calc_FTree(FunParam,x,CError,CLevel));
                     FEXP     : Calc_FTree:=Exp(Calc_FTree(FunParam,x,CError,CLevel));
                     FLN      : BEGIN
                                 v:=Calc_FTree(FunParam,x,CError,CLevel);
                                 IF v>0
                                  THEN Calc_FTree:=Ln(v)
                                  ELSE BEGIN
                                        ErrMsg:='NatÅrlicher Logarithmus nicht definiert !';
                                        CError:=TRUE
                                       END
                                END;
                     FSQR     : Calc_FTree:=Sqr(Calc_FTree(FunParam,x,CError,CLevel));
                     FSQRT    : BEGIN
                                 v:=Calc_FTree(FunParam,x,CError,CLevel);
                                 IF v>=0
                                  THEN Calc_FTree:=Sqrt(v)
                                  ELSE BEGIN
                                        ErrMsg:='Wurzel fÅr neg. Zahlen nicht def.!';
                                        CError:=TRUE
                                       END
                                END;
                     F1       : Calc_FTree:=Calc_Tree(FktPtr[1],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     F2       : Calc_FTree:=Calc_Tree(FktPtr[2],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     F3       : Calc_FTree:=Calc_Tree(FktPtr[3],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     F4       : Calc_FTree:=Calc_Tree(FktPtr[4],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     F5       : Calc_FTree:=Calc_Tree(FktPtr[5],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     F6       : Calc_FTree:=Calc_Tree(FktPtr[6],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     F7       : Calc_FTree:=Calc_Tree(FktPtr[7],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     F8       : Calc_FTree:=Calc_Tree(FktPtr[8],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     F9       : Calc_FTree:=Calc_Tree(FktPtr[9],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     F10      : Calc_FTree:=Calc_Tree(FktPtr[10],Calc_FTree(FunParam,x,CError,CLevel+1),CError);
                     FABS     : Calc_FTree:=Abs(Calc_FTree(FunParam,x,CError,CLevel));
                     FSGN     : BEGIN
                                 v:=Calc_FTree(FunParam,x,CError,CLevel);
                                 IF v<0
                                  THEN Calc_FTree:=-1
                                  ELSE IF v=0
                                        THEN Calc_FTree:=0
                                        ELSE Calc_FTree:=1;
                                END;
                    END;
          Variable: Calc_FTree:=x;
          Constant: IF Get_Constant(ConName,v)
                     THEN Calc_FTree:=v
                     ELSE BEGIN
                           ErrMsg:=Concat('Unbekannte Konstante: ',ConName);
                           CError:=TRUE
                          END;
          Number  : Calc_FTree:=NumValue;
          ELSE Fehler('Unvorhergesehener Fall #2 !')
         END { CASE NType }
   ELSE BEGIN
         Calc_FTree:=0;
         IF CLevel>=MaxRek
          THEN BEGIN
                ErrMsg:='Zu viele verschachtelte Makro-Aufrufe !';
                CError:=TRUE
               END
        END
 END; { Calc_FTree }

BEGIN
 CError:=FALSE;
 IF T<>NIL
  THEN Calc_Tree:=Calc_FTree(T,x,CError,0)
  ELSE CError:=TRUE;
 IF CError THEN Fehler(ErrMsg)
END; { Calc_Tree }

{ Funktionen Differenzieren }

FUNCTION Diff_Function(T : FTree; DLevel : INTEGER) : FTree;
BEGIN
 IF (T<>NIL) AND (DLevel<MaxRek)
  THEN WITH T^ DO
        CASE NType OF
         Constant : Diff_Function:=Make_Number(0);
         Variable : Diff_Function:=Make_Number(1);
         Number   : Diff_Function:=Make_Number(0);
         Operator : CASE OpType OF
                     '+' : Diff_Function:=Make_Sum(Diff_Function(OpLeft,DLevel),
                                                   Diff_Function(OpRight,DLevel));
                     '-' : Diff_Function:=Make_Difference(Diff_Function(OpLeft,DLevel),
                                                          Diff_Function(OpRight,DLevel));
                     '*' : Diff_Function:=Make_Sum(Make_Product(OpLeft,
                                                                Diff_Function(OpRight,DLevel)),
                                                   Make_Product(Diff_Function(OpLeft,DLevel),
                                                                OpRight));
                     '/' : Diff_Function:=Make_Division(Make_Difference(Make_Product(Diff_Function(OpLeft,DLevel),
                                                                                     OpRight),
                                                                        Make_Product(OpLeft,
                                                                                     Diff_Function(OpRight,DLevel))),
                                                        Make_Function(FSQR,
                                                                      OpRight));
                     '^' : Diff_Function:=Make_Sum(Make_Product(Make_Function(FLN,OpLeft),
                                                                Make_Product(Diff_Function(OpRight,DLevel),
                                                                             Make_Expo(OpLeft,OpRight))),
                                                   Make_Product(Diff_Function(OpLeft,DLevel),
                                                                Make_Product(Make_Expo(OpLeft,
                                                                                       Make_Difference(OpRight,Make_Number(1))),
                                                                             OpRight)));
                    END; { CASE OpType }
         FunCall  : CASE FunNum OF
                     FSIN     : Diff_Function:=Make_Product(Make_Function(FCOS,FunParam),
                                                            Diff_Function(FunParam,DLevel));
                     FCOS     : Diff_Function:=Make_Product(Make_Difference(NIL,
                                                                            Make_Function(FSIN,FunParam)),
                                                            Diff_Function(FunParam,DLevel));
                     FTAN     : Diff_Function:=Make_Division(Diff_Function(FunParam,DLevel),
                                                             Make_Function(FSQR,
                                                                           Make_Function(FCOS,FunParam)));
                     FASIN    : Diff_Function:=Make_Division(Diff_Function(FunParam,DLevel),
                                                             Make_Function(FSQRT,
                                                                           Make_Difference(Make_Number(1),
                                                                                           Make_Function(FSQR,FunParam))));
                     FACOS    : Diff_Function:=Make_Difference(NIL,
                                                               Diff_Function(Make_Function(FASIN,FunParam),DLevel));
                     FATAN    : Diff_Function:=Make_Division(Diff_Function(FunParam,DLevel),
                                                             Make_Sum(Make_Number(1),
                                                                      Make_Function(FSQR,FunParam)));
                     FEXP     : Diff_Function:=Make_Product(Make_Function(FEXP,FunParam),
                                                            Diff_Function(FunParam,DLevel));
                     FLN      : Diff_Function:=Make_Division(Diff_Function(FunParam,DLevel),FunParam);
                     FSQR     : Diff_Function:=Make_Product(Make_Product(Make_Number(2),FunParam),
                                                            Diff_Function(FunParam,DLevel));
                     FSQRT    : Diff_Function:=Make_Division(Diff_Function(FunParam,DLevel),
                                                             Make_Product(Make_Number(2),
                                                                          Make_Function(FSQRT,FunParam)));
                     FABS     : Diff_Function:=Make_Product(Make_Function(FSGN,FunParam),
                                                            Diff_Function(FunParam,DLevel));
                     F1  : Diff_Function:=Make_Product(Diff_Function(FktPtr[1],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     F2  : Diff_Function:=Make_Product(Diff_Function(FktPtr[2],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     F3  : Diff_Function:=Make_Product(Diff_Function(FktPtr[3],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     F4  : Diff_Function:=Make_Product(Diff_Function(FktPtr[4],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     F5  : Diff_Function:=Make_Product(Diff_Function(FktPtr[5],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     F6  : Diff_Function:=Make_Product(Diff_Function(FktPtr[6],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     F7  : Diff_Function:=Make_Product(Diff_Function(FktPtr[7],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     F8  : Diff_Function:=Make_Product(Diff_Function(FktPtr[8],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     F9  : Diff_Function:=Make_Product(Diff_Function(FktPtr[9],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     F10 : Diff_Function:=Make_Product(Diff_Function(FktPtr[10],DLevel+1),
                                                       Diff_Function(FunParam,DLevel));
                     ELSE Fehler('Unvorhergesehener Fall #4 !');
                    END; { CASE FunNum }
        END { CASE NType }
  ELSE Diff_Function:=NIL
END; { Diff_Function }

{ Aus einem Baum einen String machen }

PROCEDURE Make_FunName(FunNum : Fun_Enum; VAR s : STRING);
BEGIN
 CASE FunNum OF
  F1       : s:='F1';
  F2       : s:='F2';
  F3       : s:='F3';
  F4       : s:='F4';
  F5       : s:='F5';
  F6       : s:='F6';
  F7       : s:='F7';
  F8       : s:='F8';
  F9       : s:='F9';
  F10      : s:='F10';
  FSIN     : s:='SIN';
  FCOS     : s:='COS';
  FTAN     : s:='TAN';
  FASIN    : s:='ASIN';
  FACOS    : s:='ACOS';
  FATAN    : s:='ATAN';
  FEXP     : s:='EXP';
  FLN      : s:='LN';
  FSQR     : s:='SQR';
  FSQRT    : s:='SQRT';
  FABS     : s:='ABS';
  FSGN     : s:='SGN';
  FILLEGAL : s:='ILLEG';
 END
END;

PROCEDURE Make_FText(T : FTree; VAR s : Str255);
VAR dummy : STRING;
BEGIN
 IF (T<>NIL) AND (Length(s)<MaxFLen)
  THEN WITH T^ DO
        CASE NType OF
         Constant : s:=Concat(s,ConName);
         Variable : s:=Concat(s,'X');
         Number   : BEGIN
                     IF (   (Abs(NumValue)<0.000001)
                         OR (Abs(NumValue)>99999))
                        AND (NumValue<>0)
                      THEN BEGIN
                            WriteV(dummy,NumValue);
                            IF Pos('E',dummy)>0
                             THEN BEGIN
                                   Delete(dummy,Pos('E',dummy)-4,4);
                                   dummy:=Concat('(',dummy,')')
                                  END
                           END
                      ELSE IF NumValue=Round(NumValue)
                            THEN WriteV(dummy,Round(NumValue):14)
                            ELSE WriteV(dummy,NumValue:14:7);
                     WHILE(Pos(' ',dummy)>0) DO Delete(dummy,Pos(' ',dummy),1);
                     s:=Concat(s,dummy)
                    END;
         Operator : BEGIN
                     IF (OpLeft<>NIL) OR (OpType<>'-')
                      THEN IF AtomP(OpLeft)
                            THEN Make_FText(OpLeft,s)
                            ELSE BEGIN
                                  s:=Concat(s,'(');
                                  Make_FText(OpLeft,s);
                                  IF Length(s)<MaxFLen THEN s:=Concat(s,')')
                                 END;
                     IF Length(s)<MaxFLen THEN s:=Concat(s,OpType);
                     IF AtomP(OpRight)
                      THEN Make_FText(OpRight,s)
                      ELSE BEGIN
                            IF Length(s)<MaxFLen THEN s:=Concat(s,'(');
                            Make_FText(OpRight,s);
                            IF Length(s)<MaxFLen THEN s:=Concat(S,')')
                           END
                    END;
         FunCall  : BEGIN
                     Make_FunName(FunNum,dummy);
                     s:=Concat(s,dummy,'(');
                     Make_FText(FunParam,s);
                     IF Length(s)<MaxFLen THEN s:=Concat(s,')')
                    END;
         ELSE Fehler('Unvorhergesehener Fall #5 !')
        END { CASE NType }
  ELSE IF (Length(s)>=MaxFLen) AND (s[Length(s)]<>'.') THEN s:=Concat(s,'...')
END; { Make_FText }

{ Funktionen zeichnen }

FUNCTION Buttons : INTEGER;
VAR d,bstate : INTEGER;
    msg      : Message_Buffer;
BEGIN
 d:=Get_Event(E_TIMER,1,0,0,1,FALSE,0,0,0,0,FALSE,0,0,0,0,msg,d,bstate,d,d,d,d);
 Buttons:=bstate
END; { Buttons }

FUNCTION Max(a,b : INTEGER) : INTEGER;
BEGIN
 IF a>b THEN Max:=a
        ELSE Max:=b
END; { Max }

FUNCTION Min(a,b : INTEGER) : INTEGER;
BEGIN
 IF a<b THEN Min:=a
        ELSE Min:=b
END; { Min }

PROCEDURE Init_Graphics;
VAR x,y : INTEGER;
BEGIN
 Text_Color(BLACK);
 Line_Color(BLACK);
 Paint_Color(BLACK);
 Draw_Mode(Replace_Mode);
 Text_Style(NORMAL);
 Text_Height(13);
 Text_Rotation(0);
 Line_Style(Solid);
 Line_Width(1);
 Line_Endstyle(NORMAL,NORMAL);
 Paint_Style(NORMAL);
 Paint_Outline(FALSE);
 Set_Clipping(FALSE,0,0,0,0);
END;

PROCEDURE My_Line(x1,y1,x2,y2 : INTEGER);
VAR xmult,ymult : INTEGER;
BEGIN
 IF Draw_Dest=Screen
  THEN PLine(x1,y1,x2,y2)
  ELSE BEGIN
        xmult:=Trunc(32767/xAkt);
        ymult:=Trunc(32767/yAkt);
        m_line(handle,x1*xmult,32767-y1*ymult,
                      x2*xmult,32767-y2*ymult);
       END;
END;

PROCEDURE My_String(x,y : INTEGER; s : Str128);
VAR cs : CString;
    xmult,ymult : INTEGER;
BEGIN
 IF Draw_Dest=Screen
  THEN Draw_String(x,y,s)
  ELSE BEGIN
        make_cstring(s,cs);
        xmult:=Trunc(32767/xAkt);
        ymult:=Trunc(32767/yAkt);
        m_gtext(handle,x*xmult,32767-y*ymult,cs);
       END;
END;

PROCEDURE Paint_UpArrow(x : INTEGER);
BEGIN
 My_Line(Max(0,x-5),5,x,0);     { / }
 My_Line(x,0,Min(xAkt-1,x+5),5) { \ }
END; { Paint_UpArrow }

PROCEDURE Paint_RightArrow(y : INTEGER);
BEGIN
 My_Line(xAkt-6,Max(0,y-5),xAkt-1,y);     { \ }
 My_Line(xAkt-1,y,xAkt-6,Min(yAkt-1,y+5)) { / }
END; { Paint_RightArrow }

FUNCTION Real_Round(r : REAL; VAR s : STRING) : REAL;
VAR sdummy : Str255;
    N_Flag : BOOLEAN;
BEGIN
 IF r<0
  THEN BEGIN
        N_Flag:=TRUE;
        r:=Abs(r)
       END
  ELSE N_Flag:=FALSE;
 IF (r<>0) AND ((r<0.001) OR (r>99))
  THEN BEGIN
        WriteV(s,r);
        Delete(s,5,8);
        IF s[4]='0' THEN Delete(s,4,1)
       END
  ELSE BEGIN
        WriteV(s,r:5:2);
        IF s[Length(s)]='0'
         THEN BEGIN
               Delete(s,Length(s),1);
               IF s[Length(s)]='0' THEN Delete(s,Length(s)-1,2)
              END
       END;
 IF N_Flag THEN s:=Concat('-',s);
 WHILE Pos(' ',s)>0 DO Delete(s,Pos(' ',s),1);
 sdummy:=s;
 IF NOT atof(sdummy,r) THEN;
 Real_Round:=r
END; { Real_Round }

FUNCTION Calc_yko(y : REAL) : INTEGER;
BEGIN
 Calc_yko:=Round((y-S_yl)*yAkt/Abs(S_yh-S_yl))
END; { Calc_yko }

FUNCTION Calc_xko(x : REAL) : INTEGER;
BEGIN
 Calc_xko:=Round((x-S_xl)*xAkt/Abs(S_xh-S_xl))
END; { Calc_xko }

PROCEDURE Paint_Axis(Ch : CHAR; x1,y1,x2,y2 : INTEGER);
VAR VDist       : REAL;
    s           : STRING;
    i,New_Koord,
    anz         : INTEGER;
BEGIN
 IF     (x1>=0) AND (x2>=0) AND (x1<=(xAkt-1)) AND (x2<=(xAkt-1))
    AND (y1>=0) AND (y2>=0) AND (y1<=(yAkt-1)) AND (y2<=(yAkt-1))
  THEN BEGIN
        IF x1=x2                                       { Achse vertikal ??? }
         THEN BEGIN
               Paint_UpArrow(x1);                      { Pfeil hoch zeichnen }
               IF x1>xAkt-16                           { am rechten Rand ??? }
                THEN My_String(x1-13,20,Ch)
                ELSE My_String(x1+5,20,Ch);
               anz:=Round(yAkt/40);
               VDist:=Abs(S_yh-S_yl)/anz;
               FOR i:=1 TO anz-1 DO
               BEGIN
                New_Koord:=Calc_yko(Real_Round(S_yl+i*VDist,s));
                IF (x1>xAkt-70) And (x1>=70)
                 THEN My_String(x1-70,(yAkt-1)-(New_Koord-5),s)
                 ELSE My_String(x1+5,(yAkt-1)-(New_Koord-5),s);
                IF (New_Koord>=0) AND (New_Koord<=(yAkt-1))
                 THEN My_Line(Max(0,x1-3),(yAkt-1)-New_Koord,Min((xAkt-1),x1+3),(yAkt-1)-New_Koord)
               END
              END
         ELSE BEGIN
               Paint_RightArrow(y1);
               IF y1>yAkt-24
                THEN My_String(xAkt-16,y1-5,Ch)
                ELSE My_String(xAkt-16,y1+15,Ch);
               anz:=Round(xAkt/60);
               VDist:=Abs(S_xh-S_xl)/anz;
               FOR i:=1 TO anz-1 DO
               BEGIN
                New_Koord:=Calc_xko(Real_Round(S_xl+i*VDist,s));
                IF y1>yAkt-24
                 THEN My_String(New_Koord-Length(s)*4,y1-5,s)
                 ELSE My_String(New_Koord-Length(s)*4,y1+23,s);
                IF (New_Koord>=0) AND (New_Koord<=(xAkt-1))
                 THEN My_Line(New_Koord,Max(0,y1-3),New_Koord,Min((yAkt-1),y1+3))
               END
              END;
       My_Line(x1,y1,x2,y2)
      END
END; { Paint_Axis }

PROCEDURE gotoxy(x,y : INTEGER);
BEGIN
 IF x<0
  THEN x:=0
  ELSE IF x>79 THEN x:=79;
 IF y<0
  THEN y:=0
  ELSE IF y>24 THEN y:=24;
 Write(Chr(27),'Y',Chr(y+32),Chr(x+32));
END;

PROCEDURE Auto_Paint(VAR FktState : StateSet);
VAR xd,xpos,res,ymult,
    y_min,y_max     : REAL;
    FktCnt,xkoCnt,
    Last_y,yko,x,y,
    x_achse,y_achse : INTEGER;
    err,FirstFkt    : BOOLEAN;
BEGIN
 IF Draw_Dest=Screen THEN Show_Wait;
 xd:=Abs(S_xh-S_xl)/xAkt;
 FirstFkt:=TRUE;
 FOR FktCnt:=1 TO MaxFkt DO
  IF FktState[FktCnt]=SELECTED
   THEN BEGIN
         IF Draw_Dest=Screen THEN Bee;
         xpos:=S_xl;
         IF FirstFkt
          THEN BEGIN
                y_min:=MaxReal;
                y_max:=MinReal
               END;
         FOR xkoCnt:=0 TO (xAkt-1) DO
         BEGIN
          IF FirstFkt
           THEN BEGIN
                 gotoxy(74,0); write(xkoCnt:6);
                 res:=Calc_Tree(FktPtr[FktCnt],xpos,err);
                 IF res>y_max THEN y_max:=res;
                 IF res<y_min THEN y_min:=res;
                 y_koords[xkoCnt]:=res;
                END
           ELSE y_koords[xkoCnt]:=Calc_Tree(FktPtr[FktCnt],xpos,err);
          xpos:=xpos+xd;
          IF Buttons<>0 THEN err:=TRUE;
          IF err THEN xkoCnt:=xAkt-1;
         END;
         gotoxy(75,0); write('     ');
         IF Draw_Dest=Screen THEN No_Bee;
         IF (Draw_Dest=Screen) AND FirstFkt
          THEN BEGIN
                Init_Graphics;
                Paint_Rect(0,0,xAuf,yAuf);
                IF yAkt<yAuf THEN PLine(0,yAkt,xAkt,yAkt);
                IF xAkt<xAuf THEN PLine(xAkt,yAkt,xAkt,0);
                IF yAkt+1<yAuf THEN PLine(0,yAkt+1,xAkt,yAkt+1);
                IF xAkt+1<xAuf THEN PLine(xAkt+1,yAkt,xAkt+1,0);
               END;
         IF NOT err
          THEN BEGIN
                IF FirstFkt
                 THEN BEGIN
                       IF y_min<0 THEN S_yl:=y_min*1.1
                                  ELSE S_yl:=y_min*0.9;
                       IF y_max>0 THEN S_yh:=y_max*1.1
                                  ELSE S_yh:=y_max*0.9;
                       ymult:=yAkt/Abs(S_yh-S_yl);
                       IF ((S_yl<=0) AND (S_yh>0)) OR ((S_yl<0) AND (S_yh>=0))
                        THEN BEGIN
                              x_achse:=Round(Abs(S_yl)*ymult);
                              Paint_Axis('x',0,(yAkt-1)-x_achse,(xAkt-1),(yAkt-1)-x_achse)
                             END;
                       IF ((S_xl<=0) AND (S_xh>0)) OR ((S_xl<0) AND (S_xh>=0))
                        THEN BEGIN
                              y_achse:=Round(Abs(S_xl)*(xAkt/Abs(S_xh-S_xl)));
                              Paint_Axis('y',y_achse,0,y_achse,(yAkt-1))
                             END
                      END;
                Last_y:=Round((y_koords[0]-S_yl)*ymult);
                FOR xkoCnt:=1 TO (xAkt-1) DO
                BEGIN
                 yko:=Round((y_koords[xkoCnt]-S_yl)*ymult);
                 IF (yko>=0) AND (yko<=(yAkt-1))
                  THEN My_Line(xkoCnt-1,(yAkt-1)-Last_y,xkoCnt,(yAkt-1)-yko);
                 Last_y:=yko
                END
               END;
         FirstFkt:=FALSE
        END;
 Write(#7);
 REPEAT
 UNTIL (Buttons<>0) OR err OR (Draw_Dest=Metafile);
END; { Auto_Paint }

PROCEDURE Scale_Paint(VAR FktState : StateSet);
VAR FktCnt,xkoCnt,
    Last_y,yko,
    x_achse,y_achse   : INTEGER;
    xd,xpos,res,ymult : REAL;
    err               : BOOLEAN;
BEGIN
 IF Draw_Dest=Screen
  THEN BEGIN
        Init_Graphics;
        Paint_Rect(0,0,xAuf,yAuf);
        IF yAkt<yAuf THEN PLine(0,yAkt,xAkt,yAkt);
        IF xAkt<xAuf THEN PLine(xAkt,yAkt,xAkt,0);
        IF yAkt+1<yAuf THEN PLine(0,yAkt+1,xAkt,yAkt+1);
        IF xAkt+1<xAuf THEN PLine(xAkt+1,yAkt,xAkt+1,0);
       END
  ELSE Bee;
 xd:=Abs(S_xh-S_xl)/xAkt;
 ymult:=yAkt/Abs(S_yh-S_yl);
 IF (S_xl<0) AND (S_xh>0)
  THEN BEGIN
        y_achse:=Round(Abs(S_xl)*(xAkt/Abs(S_xh-S_xl)));
        Paint_Axis('y',y_achse,0,y_achse,(yAkt-1))
       END;
 IF (S_yl<0) AND (S_yh>0)
  THEN BEGIN
        x_achse:=Round(Abs(S_yl)*ymult);
        Paint_Axis('x',0,(yAkt-1)-x_achse,(xAkt-1),(yAkt-1)-x_achse)
       END;
 FOR FktCnt:=1 TO MaxFkt DO
  IF FktState[FktCnt]=SELECTED
   THEN BEGIN
         xpos:=S_xl;
         Last_y:=-1;
         FOR xkoCnt:=0 TO (xAkt-1) DO
         BEGIN
          res:=Calc_Tree(FktPtr[FktCnt],xpos,err);
          IF (res>=S_yl) AND (res<=S_yh) AND (NOT err)
           THEN BEGIN
                 yko:=Round((res-S_yl)*ymult);
                 IF Last_y<0
                  THEN Last_y:=yko
                  ELSE BEGIN
                        IF (yko>=0) AND (yko<=(yAkt-1))
                         THEN My_Line(xkoCnt-1,(yAkt-1)-Last_y,xkoCnt,(yAkt-1)-yko);
                        Last_y:=yko
                       END
                END
           ELSE IF err THEN xkoCnt:=xAkt;
          xpos:=xpos+xd;
          IF xkoCnt MOD 10=0 THEN IF Buttons<>0 THEN xkoCnt:=xAkt
         END
        END;
 Write(#7);
 REPEAT
 UNTIL (Buttons<>0) OR err OR (Draw_Dest=Metafile);
 IF Draw_Dest=Metafile THEN No_Bee;
END; { Scale_Paint }

{ Dialoge }

PROCEDURE Show_Info;
VAR Exit_Obj : INTEGER;
BEGIN
 Center_Dialog(D_Info);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_Info,0);
 Hide_Mouse;
 Obj_SetState(D_Info,Exit_Obj,NORMAL,FALSE);
 End_Dialog(D_Info)
END; { Show_Info }

FUNCTION CheckFkts : BOOLEAN;
VAR i     : INTEGER;
    Found : BOOLEAN;
BEGIN
 Found:=FALSE;
 FOR i:=1 TO MaxFkt DO
  IF FktPtr[i]<>NIL THEN Found:=TRUE;
 CheckFkts:=Found;
END; { CheckFkts }

FUNCTION Get_Fktno(Ch_Msg : STRING) : INTEGER;
VAR Exit_Obj : INTEGER;
BEGIN
 Obj_SetState(D_Choice,FUC1,NORMAL,FALSE);
 Obj_SetState(D_Choice,FUC2,NORMAL,FALSE);
 Obj_SetState(D_Choice,FUC3,NORMAL,FALSE);
 Obj_SetState(D_Choice,FUC4,NORMAL,FALSE);
 Obj_SetState(D_Choice,FUC5,NORMAL,FALSE);
 Obj_SetState(D_Choice,FUC6,NORMAL,FALSE);
 Obj_SetState(D_Choice,FUC7,NORMAL,FALSE);
 Obj_SetState(D_Choice,FUC8,NORMAL,FALSE);
 Obj_SetState(D_Choice,FUC9,NORMAL,FALSE);
 Obj_SetState(D_Choice,FUC10,NORMAL,FALSE);
 Set_DText(D_Choice,FUCTEXT,Ch_Msg,SYSTEM_FONT,TE_CENTER);
 Center_Dialog(D_Choice);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_Choice,0);
 Hide_Mouse;
 CASE Exit_Obj OF
  FUC1 : Get_Fktno:=1;
  FUC2 : Get_Fktno:=2;
  FUC3 : Get_Fktno:=3;
  FUC4 : Get_Fktno:=4;
  FUC5 : Get_Fktno:=5;
  FUC6 : Get_Fktno:=6;
  FUC7 : Get_Fktno:=7;
  FUC8 : Get_Fktno:=8;
  FUC9 : Get_Fktno:=9;
  FUC10 : Get_Fktno:=10
 END;
 Obj_SetState(D_Choice,Exit_Obj,NORMAL,FALSE);
 End_Dialog(D_Choice)
END; { Get_Fktno }

FUNCTION Get_Legal_Fktno(Ch_Msg : STRING) : INTEGER;
VAR Exit_Obj,i : INTEGER;
    FktState   : StateSet;
BEGIN
 FOR i:=1 TO MaxFkt DO
  IF FktPtr[i]=NIL
   THEN FktState[i]:=DISABLED
   ELSE FktState[i]:=NORMAL;
 Obj_SetState(D_Choice,FUC1,FktState[1],FALSE);
 Obj_SetState(D_Choice,FUC2,FktState[2],FALSE);
 Obj_SetState(D_Choice,FUC3,FktState[3],FALSE);
 Obj_SetState(D_Choice,FUC4,FktState[4],FALSE);
 Obj_SetState(D_Choice,FUC5,FktState[5],FALSE);
 Obj_SetState(D_Choice,FUC6,FktState[6],FALSE);
 Obj_SetState(D_Choice,FUC7,FktState[7],FALSE);
 Obj_SetState(D_Choice,FUC8,FktState[8],FALSE);
 Obj_SetState(D_Choice,FUC9,FktState[9],FALSE);
 Obj_SetState(D_Choice,FUC10,FktState[10],FALSE);
 Set_DText(D_Choice,FUCTEXT,Ch_Msg,SYSTEM_FONT,TE_CENTER);
 Center_Dialog(D_Choice);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_Choice,0);
 Hide_Mouse;
 CASE Exit_Obj OF
  FUC1 : Get_Legal_Fktno:=1;
  FUC2 : Get_Legal_Fktno:=2;
  FUC3 : Get_Legal_Fktno:=3;
  FUC4 : Get_Legal_Fktno:=4;
  FUC5 : Get_Legal_Fktno:=5;
  FUC6 : Get_Legal_Fktno:=6;
  FUC7 : Get_Legal_Fktno:=7;
  FUC8 : Get_Legal_Fktno:=8;
  FUC9 : Get_Legal_Fktno:=9;
  FUC10 : Get_Legal_Fktno:=10
 END;
 End_Dialog(D_Choice)
END; { Get_Legal_Fktno }

PROCEDURE Split(VAR s1,s2 : Str255; p : INTEGER);
VAR i : INTEGER;
BEGIN
 s2:='';
 IF Length(s1)>p
  THEN BEGIN
        FOR i:=p+1 TO Length(s1) DO
         s2[i-p]:=s1[i];
        s2[0]:=Chr(Length(s1)-p);
        s1[0]:=Chr(p)
       END
END; { Split }

PROCEDURE Edit_Fkt(Fktno : INTEGER);
VAR s1,s2,s3,f : Str255;
    err        : BOOLEAN;
    ZwiPtr     : FTree;
    i,Exit_Obj : INTEGER;
BEGIN
 s1:=FktTerm[Fktno];
 s2:='';
 s3:='';
 IF Length(s1)>TxtLen-3 THEN Split(s1,s2,TxtLen-3);
 IF Length(s2)>TxtLen THEN Split(s2,s3,TxtLen);
 Set_DEdit(D_Edit,FUESTR1,
          'f(x)=___________________________________________________________________',
          'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
          s1,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Edit,FUESTR2,
          '  ______________________________________________________________________',
          'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
          s2,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Edit,FUESTR3,
          '  ______________________________________________________________________',
          'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
          s3,SYSTEM_FONT,TE_LEFT);
 WriteV(f,Fktno);
 Set_DText(D_Edit,FUEFN,Concat('Funktion Nr.:',f),SYSTEM_FONT,TE_CENTER);
 Center_Dialog(D_Edit);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_Edit,FUESTR1);
 Hide_Mouse;
 IF Exit_Obj<>FUEEXIT
  THEN BEGIN
        Get_DEdit(D_Edit,FUESTR1,s1);
        Get_DEdit(D_Edit,FUESTR2,s2);
        Get_DEdit(D_Edit,FUESTR3,s3);
        s1:=Concat(s1,s2,s3);
        WHILE Pos(' ',s1)>0 DO Delete(s1,Pos(' ',s1),1);
        FTree_Free(FktPtr[Fktno]);
        IF Length(s1)>0
         THEN BEGIN
               Str_UpCase(s1);
               ZwiPtr:=Build_Tree(s1,err);
               FktTerm[Fktno]:=s1;
               IF NOT err THEN FktPtr[Fktno]:=ZwiPtr
                          ELSE FktPtr[Fktno]:=NIL
              END
         ELSE BEGIN
               err:=TRUE;
               FktTerm[Fktno]:='';
               FktPtr[Fktno]:=NIL
              END
       END;
 Obj_SetState(D_Edit,Exit_Obj,NORMAL,FALSE);
 End_Dialog(D_Edit)
END; { Edit_Fkt }

PROCEDURE Show_Fkts;
VAR Exit_Obj,i : INTEGER;
    Fstrs      : ARRAY[1..MaxFkt] OF Str255;
    s          : Str255;
BEGIN
 FOR i:=1 TO MaxFkt DO
 BEGIN
  Fstrs[i]:=FktTerm[i];
  Split(Fstrs[i],s,70);
  IF Length(s)>0 THEN Fstrs[i]:=Concat(Fstrs[i],'...')
 END;
 Set_DText(D_Show,FUS1,Fstrs[1],SMALL_FONT,TE_LEFT);
 Set_DText(D_Show,FUS2,Fstrs[2],SMALL_FONT,TE_LEFT);
 Set_DText(D_Show,FUS3,Fstrs[3],SMALL_FONT,TE_LEFT);
 Set_DText(D_Show,FUS4,Fstrs[4],SMALL_FONT,TE_LEFT);
 Set_DText(D_Show,FUS5,Fstrs[5],SMALL_FONT,TE_LEFT);
 Set_DText(D_Show,FUS6,Fstrs[6],SMALL_FONT,TE_LEFT);
 Set_DText(D_Show,FUS7,Fstrs[7],SMALL_FONT,TE_LEFT);
 Set_DText(D_Show,FUS8,Fstrs[8],SMALL_FONT,TE_LEFT);
 Set_DText(D_Show,FUS9,Fstrs[9],SMALL_FONT,TE_LEFT);
 Set_DText(D_Show,FUS10,Fstrs[10],SMALL_FONT,TE_LEFT);
 Center_Dialog(D_Show);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_Show,0);
 Hide_Mouse;
 Obj_SetState(D_Show,Exit_Obj,NORMAL,FALSE);
 End_Dialog(D_Show)
END; { Show_Fkts }

PROCEDURE Paint_Grey(x,y,b,h : INTEGER);
BEGIN
 IF (x>=0) AND (y>=0) AND (x+b<=xAuf) AND (y+h<=yAuf)
  THEN BEGIN
        Paint_Style(5);
        Paint_Rect(x,y,b,h);
       END;
END; { Paint_Grey }

PROCEDURE Screen_Disable;
BEGIN
 Erase_Menu(M_Main);
END;

PROCEDURE Screen_Enable;
BEGIN
 Paint_Grey(0,0,xAuf,yAuf);
 Draw_Menu(M_Main);
END;

PROCEDURE Open_Metafile;
VAR cs : CString;
BEGIN
 handle:=meta_nr;
 m_opnwk(handle);
 IF handle>0
  THEN BEGIN
        make_cstring(Meta_Name,cs);
        m_filename(handle,cs);
        m_meta_extents(handle,0,0,32767,32767);
        m_pagesize(handle,2100,2100);
        m_coords(handle,0,0,32767,32767);
       END;
END;

PROCEDURE Close_Metafile;
VAR int_in  : Int_In_Parms;
    int_out : Int_Out_Parms;
    pts_in  : Pts_In_Parms;
    pts_out : Pts_Out_Parms;
    ctrl    : Ctrl_Parms;
BEGIN
 m_updwk(handle);
 m_clswk(handle);
END;

PROCEDURE Paint_Fkts;
VAR Exit_Obj,i : INTEGER;
    FktState   : StateSet;
    s          : Str255;
BEGIN
 FOR i:=1 TO MaxFkt DO
  IF FktPtr[i]=NIL
   THEN FktState[i]:=DISABLED
   ELSE FktState[i]:=SELECTED;
 Obj_SetState(D_Draw,FUD1,FktState[1],FALSE);
 Obj_SetState(D_Draw,FUD2,FktState[2],FALSE);
 Obj_SetState(D_Draw,FUD3,FktState[3],FALSE);
 Obj_SetState(D_Draw,FUD4,FktState[4],FALSE);
 Obj_SetState(D_Draw,FUD5,FktState[5],FALSE);
 Obj_SetState(D_Draw,FUD6,FktState[6],FALSE);
 Obj_SetState(D_Draw,FUD7,FktState[7],FALSE);
 Obj_SetState(D_Draw,FUD8,FktState[8],FALSE);
 Obj_SetState(D_Draw,FUD9,FktState[9],FALSE);
 Obj_SetState(D_Draw,FUD10,FktState[10],FALSE);
 IF Draw_Dest=Screen
  THEN BEGIN
        Obj_SetState(D_Draw,FUDSCRN,SELECTED,FALSE);
        Obj_SetState(D_Draw,FUDMETA,NORMAL,FALSE);
       END
  ELSE BEGIN
        Obj_SetState(D_Draw,FUDSCRN,NORMAL,FALSE);
        Obj_SetState(D_Draw,FUDMETA,SELECTED,FALSE);
       END;
 WriteV(s,meta_nr);
 Set_DEdit(D_Draw,FUDHNDLE,'Kennung:__','99',s,SYSTEM_FONT,TE_CENTER);
 Set_DEdit(D_Draw,FUDNAME,'Name:____________','XXXXXXXXXXXX',Meta_Name,SYSTEM_FONT,TE_CENTER);
 WriteV(s,xAkt);
 Set_DEdit(D_Draw,FUDXAUF,'x:_____','99999',s,SYSTEM_FONT,TE_CENTER);
 WriteV(s,yAkt);
 Set_DEdit(D_Draw,FUDYAUF,'y:_____','99999',s,SYSTEM_FONT,TE_CENTER);
 IF NOT GDOS_Here
  THEN BEGIN
        Obj_SetState(D_Draw,FUDMETA,DISABLED,FALSE);
        Obj_SetFlags(D_Draw,FUDMETA,0);
        Obj_SetState(D_Draw,FUDHNDLE,DISABLED,FALSE);
        Obj_SetFlags(D_Draw,FUDHNDLE,0);
        Obj_SetState(D_Draw,FUDNAME,DISABLED,FALSE);
        Obj_SetFlags(D_Draw,FUDNAME,0);
       END;
 Center_Dialog(D_Draw);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_Draw,0);
 Hide_Mouse;
 IF Exit_Obj<>FUDEXIT
  THEN BEGIN
        FktState[1]:=Obj_State(D_Draw,FUD1);
        FktState[2]:=Obj_State(D_Draw,FUD2);
        FktState[3]:=Obj_State(D_Draw,FUD3);
        FktState[4]:=Obj_State(D_Draw,FUD4);
        FktState[5]:=Obj_State(D_Draw,FUD5);
        FktState[6]:=Obj_State(D_Draw,FUD6);
        FktState[7]:=Obj_State(D_Draw,FUD7);
        FktState[8]:=Obj_State(D_Draw,FUD8);
        FktState[9]:=Obj_State(D_Draw,FUD9);
        FktState[10]:=Obj_State(D_Draw,FUD10);
        IF Obj_State(D_Draw,FUDSCRN)=SELECTED
         THEN Draw_Dest:=Screen
         ELSE BEGIN
               Get_DEdit(D_Draw,FUDHNDLE,s);
               IF NOT atoi(s,meta_nr)
                THEN BEGIN
                      Bing;
                      meta_nr:=0;
                      Draw_Dest:=Screen;
                      Fehler('Falsche Metafile-Kennung !');
                     END
                ELSE Draw_Dest:=Metafile;
              END;
        Get_DEdit(D_Draw,FUDNAME,s);
        IF Length(s)>0
         THEN Meta_Name:=s
         ELSE Meta_Name:='FKTPLOT.GEM';
        Get_DEdit(D_Draw,FUDXAUF,s);
        IF NOT atoi(s,xAkt)
         THEN BEGIN
               Bing;
               xAkt:=xAuf;
              END
         ELSE IF (xAkt>xAuf) AND (Draw_Dest=Screen)
               THEN BEGIN
                     Bing;
                     xAkt:=xAuf;
                    END;
        Get_DEdit(D_Draw,FUDYAUF,s);
        IF NOT atoi(s,yAkt)
         THEN BEGIN
               Bing;
               yAkt:=yAuf;
              END
         ELSE IF (yAkt>yAuf) AND (Draw_Dest=Screen)
               THEN BEGIN
                     Bing;
                     yAkt:=yAuf;
                    END;
        Screen_Disable;
        IF Draw_Dest=Metafile
         THEN BEGIN
               IF xAkt>Max_xAuf
                THEN BEGIN
                      Bing;
                      xAkt:=Max_xAuf;
                     END;
               Bee;
               Open_Metafile;
               No_Bee;
               IF handle<0
                THEN Fehler('Fehler beim ôffnen des Metafiles !')
                ELSE BEGIN
                      Show_Wait;
                      IF S_Auto
                       THEN Auto_Paint(FktState)
                       ELSE Scale_Paint(FktState);
                      Bee;
                      Close_Metafile;
                      No_Bee;
                     END;
              END
         ELSE IF S_Auto
                      THEN Auto_Paint(FktState)
                      ELSE Scale_Paint(FktState);
        Screen_Enable;
       END;
 Obj_SetState(D_Draw,Exit_Obj,NORMAL,FALSE);
 End_Dialog(D_Draw)
END; { Paint_Fkts }

PROCEDURE Edit_Konsts;
VAR Kval       : ARRAY[1..MaxKonst] OF Str255;
    i,Exit_Obj : INTEGER;
BEGIN
 { Namen: }
 Set_DEdit(D_Konst,FKNAME1,'Name:________','XXXXXXXX',Konst[1].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME2,'Name:________','XXXXXXXX',Konst[2].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME3,'Name:________','XXXXXXXX',Konst[3].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME4,'Name:________','XXXXXXXX',Konst[4].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME5,'Name:________','XXXXXXXX',Konst[5].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME6,'Name:________','XXXXXXXX',Konst[6].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME7,'Name:________','XXXXXXXX',Konst[7].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME8,'Name:________','XXXXXXXX',Konst[8].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME9,'Name:________','XXXXXXXX',Konst[9].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME10,'Name:________','XXXXXXXX',Konst[10].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME11,'Name:________','XXXXXXXX',Konst[11].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME12,'Name:________','XXXXXXXX',Konst[12].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME13,'Name:________','XXXXXXXX',Konst[13].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME14,'Name:________','XXXXXXXX',Konst[14].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME15,'Name:________','XXXXXXXX',Konst[15].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME16,'Name:________','XXXXXXXX',Konst[16].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME17,'Name:________','XXXXXXXX',Konst[17].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME18,'Name:________','XXXXXXXX',Konst[18].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME19,'Name:________','XXXXXXXX',Konst[19].Ko_Name,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKNAME20,'Name:________','XXXXXXXX',Konst[20].Ko_Name,SYSTEM_FONT,TE_LEFT);
 { Werte: }
 FOR i:=1 TO MaxKonst DO
 BEGIN
  IF (   (Abs(Konst[i].Ko_Wert)<0.000001)
      OR (Abs(Konst[i].Ko_Wert)>99999))
     AND (Konst[i].Ko_Wert<>0)
   THEN BEGIN
         WriteV(Kval[i],Konst[i].Ko_Wert);
         IF Pos('E',Kval[i])>0
          THEN Delete(Kval[i],Pos('E',Kval[i])-4,4);
        END
   ELSE BEGIN
         IF Konst[i].Ko_Wert=Round(Konst[i].Ko_Wert)
          THEN WriteV(Kval[i],Round(Konst[i].Ko_Wert):14)
          ELSE WriteV(Kval[i],Konst[i].Ko_Wert:14:7);
        END;
  WHILE Pos(' ',Kval[i])>0 DO Delete(Kval[i],Pos(' ',Kval[i]),1);
 END;
 Set_DEdit(D_Konst,FKVAL1,'Wert:______________','XXXXXXXXXXXXXX',Kval[1],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL2,'Wert:______________','XXXXXXXXXXXXXX',Kval[2],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL3,'Wert:______________','XXXXXXXXXXXXXX',Kval[3],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL4,'Wert:______________','XXXXXXXXXXXXXX',Kval[4],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL5,'Wert:______________','XXXXXXXXXXXXXX',Kval[5],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL6,'Wert:______________','XXXXXXXXXXXXXX',Kval[6],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL7,'Wert:______________','XXXXXXXXXXXXXX',Kval[7],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL8,'Wert:______________','XXXXXXXXXXXXXX',Kval[8],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL9,'Wert:______________','XXXXXXXXXXXXXX',Kval[9],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL10,'Wert:______________','XXXXXXXXXXXXXX',Kval[10],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL11,'Wert:______________','XXXXXXXXXXXXXX',Kval[11],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL12,'Wert:______________','XXXXXXXXXXXXXX',Kval[12],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL13,'Wert:______________','XXXXXXXXXXXXXX',Kval[13],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL14,'Wert:______________','XXXXXXXXXXXXXX',Kval[14],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL15,'Wert:______________','XXXXXXXXXXXXXX',Kval[15],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL16,'Wert:______________','XXXXXXXXXXXXXX',Kval[16],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL17,'Wert:______________','XXXXXXXXXXXXXX',Kval[17],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL18,'Wert:______________','XXXXXXXXXXXXXX',Kval[18],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL19,'Wert:______________','XXXXXXXXXXXXXX',Kval[19],SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Konst,FKVAL20,'Wert:______________','XXXXXXXXXXXXXX',Kval[20],SYSTEM_FONT,TE_LEFT);
 Center_Dialog(D_Konst);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_Konst,FKNAME1);
 Hide_Mouse;
 IF Exit_Obj<>FKEXIT
  THEN BEGIN
        { Namen: }
        Get_DEdit(D_Konst,FKNAME1,Kval[1]);
        Get_DEdit(D_Konst,FKNAME2,Kval[2]);
        Get_DEdit(D_Konst,FKNAME3,Kval[3]);
        Get_DEdit(D_Konst,FKNAME4,Kval[4]);
        Get_DEdit(D_Konst,FKNAME5,Kval[5]);
        Get_DEdit(D_Konst,FKNAME6,Kval[6]);
        Get_DEdit(D_Konst,FKNAME7,Kval[7]);
        Get_DEdit(D_Konst,FKNAME8,Kval[8]);
        Get_DEdit(D_Konst,FKNAME9,Kval[9]);
        Get_DEdit(D_Konst,FKNAME10,Kval[10]);
        Get_DEdit(D_Konst,FKNAME11,Kval[11]);
        Get_DEdit(D_Konst,FKNAME12,Kval[12]);
        Get_DEdit(D_Konst,FKNAME13,Kval[13]);
        Get_DEdit(D_Konst,FKNAME14,Kval[14]);
        Get_DEdit(D_Konst,FKNAME15,Kval[15]);
        Get_DEdit(D_Konst,FKNAME16,Kval[16]);
        Get_DEdit(D_Konst,FKNAME17,Kval[17]);
        Get_DEdit(D_Konst,FKNAME18,Kval[18]);
        Get_DEdit(D_Konst,FKNAME19,Kval[19]);
        Get_DEdit(D_Konst,FKNAME20,Kval[20]);
        FOR i:=1 TO MaxKonst DO
        BEGIN
         Str_Upcase(Kval[i]);
         Konst[i].Ko_Name:=Kval[i]
        END;
        { Werte: }
        Get_DEdit(D_Konst,FKVAL1,Kval[1]);
        Get_DEdit(D_Konst,FKVAL2,Kval[2]);
        Get_DEdit(D_Konst,FKVAL3,Kval[3]);
        Get_DEdit(D_Konst,FKVAL4,Kval[4]);
        Get_DEdit(D_Konst,FKVAL5,Kval[5]);
        Get_DEdit(D_Konst,FKVAL6,Kval[6]);
        Get_DEdit(D_Konst,FKVAL7,Kval[7]);
        Get_DEdit(D_Konst,FKVAL8,Kval[8]);
        Get_DEdit(D_Konst,FKVAL9,Kval[9]);
        Get_DEdit(D_Konst,FKVAL10,Kval[10]);
        Get_DEdit(D_Konst,FKVAL11,Kval[11]);
        Get_DEdit(D_Konst,FKVAL12,Kval[12]);
        Get_DEdit(D_Konst,FKVAL13,Kval[13]);
        Get_DEdit(D_Konst,FKVAL14,Kval[14]);
        Get_DEdit(D_Konst,FKVAL15,Kval[15]);
        Get_DEdit(D_Konst,FKVAL16,Kval[16]);
        Get_DEdit(D_Konst,FKVAL17,Kval[17]);
        Get_DEdit(D_Konst,FKVAL18,Kval[18]);
        Get_DEdit(D_Konst,FKVAL19,Kval[19]);
        Get_DEdit(D_Konst,FKVAL20,Kval[20]);
        FOR i:=1 TO MaxKonst DO
         IF NOT atof(Kval[i],Konst[i].Ko_Wert) THEN Bing
       END;
 Obj_SetState(D_Konst,Exit_Obj,NORMAL,FALSE);
 End_Dialog(D_Konst)
END; { Edit_Konsts }

PROCEDURE Edit_Scale;
VAR xl,xh,yl,yh   : Str255;
    i,Exit_Obj    : INTEGER;
    alt_xl,alt_xh,
    alt_yl,alt_yh : REAL;
    alt_auto,ok   : BOOLEAN;

 FUNCTION ScaleCheck : BOOLEAN;
 BEGIN
  ScaleCheck:=(S_xl<S_xh) AND (S_xh-S_xl<>0) AND (S_yl<S_yh) AND (S_yh-S_yl<>0)
 END;

BEGIN
 alt_xl:=S_xl;
 alt_xh:=S_xh;
 alt_yl:=S_yl;
 alt_yh:=S_yh;
 alt_auto:=S_Auto;
 WriteV(xl,S_xl:14:4);
 WriteV(xh,S_xh:14:4);
 WriteV(yl,S_yl:14:4);
 WriteV(yh,S_yh:14:4);
 Set_DEdit(D_Scale,FSXL,'x von:______________','XXXXXXXXXXXXXX',xl,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Scale,FSXH,'bis:______________','XXXXXXXXXXXXXX',xh,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Scale,FSYL,'y von:______________','XXXXXXXXXXXXXX',yl,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Scale,FSYH,'bis:______________','XXXXXXXXXXXXXX',yh,SYSTEM_FONT,TE_LEFT);
 IF S_Auto
  THEN Obj_SetState(D_Scale,FSAUTO,SELECTED,FALSE)
  ELSE Obj_SetState(D_Scale,FSAUTO,NORMAL,FALSE);
 Center_Dialog(D_Scale);
 REPEAT
  Show_Mouse;
  Exit_Obj:=Do_Dialog(D_Scale,FSXL);
  Hide_Mouse;
  IF Exit_Obj<>FSEXIT
   THEN BEGIN
         Get_DEdit(D_Scale,FSXL,xl);
         Get_DEdit(D_Scale,FSXH,xh);
         Get_DEdit(D_Scale,FSYL,yl);
         Get_DEdit(D_Scale,FSYH,yh);
         IF NOT atof(xl,S_xl) THEN Bing;
         IF NOT atof(xh,S_xh)THEN Bing;
         IF NOT atof(yl,S_yl) THEN Bing;
         IF NOT atof(yh,S_yh) THEN Bing;
         S_Auto:=(Obj_State(D_Scale,FSAUTO)=SELECTED)
        END
   ELSE BEGIN
         S_xl:=alt_xl;
         s_xh:=alt_xh;
         S_yl:=alt_yl;
         S_yh:=alt_yh;
         S_Auto:=alt_auto
        END;
  Obj_SetState(D_Scale,Exit_Obj,NORMAL,FALSE);
  ok:=ScaleCheck;
  IF NOT ok THEN Bing
 UNTIL ok;
 End_Dialog(D_Scale)
END; { Edit_Scale }

PROCEDURE Edit_Int;
VAR Exit_Obj : INTEGER;
    il,iu,it : Str255;
    alt_low,
    alt_up,
    alt_tol  : REAL;
    ok       : BOOLEAN;

 FUNCTION IntCheck : BOOLEAN;
 BEGIN
  IntCheck:=(Int_low<Int_up) AND (Int_up-Int_low<>0)
 END;

BEGIN
 alt_low:=Int_low;
 alt_up:=Int_up;
 alt_tol:=Int_tol;
 WriteV(il,Int_low:14:4);
 WriteV(iu,Int_up:14:4);
 WriteV(it,Int_tol:14:4);
 Set_DEdit(D_Int,FILOW,'Untere Grenze:______________','XXXXXXXXXXXXXX',il,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Int,FIUP,'Obere Grenze :______________','XXXXXXXXXXXXXX',iu,SYSTEM_FONT,TE_LEFT);
 Set_DEdit(D_Int,FITOL,'Toleranz     :______________','XXXXXXXXXXXXXX',it,SYSTEM_FONT,TE_LEFT);
 Center_Dialog(D_Int);
 REPEAT
  Show_Mouse;
  Exit_Obj:=Do_Dialog(D_Int,FILOW);
  Hide_Mouse;
  IF Exit_Obj<>FIEXIT
   THEN BEGIN
         Get_DEdit(D_Int,FILOW,il);
         Get_DEdit(D_Int,FIUP,iu);
         Get_DEdit(D_Int,FITOL,it);
         IF NOT atof(il,Int_low) THEN Bing;
         IF NOT atof(iu,Int_up)THEN Bing;
         IF NOT atof(it,Int_tol) THEN Bing;
        END
   ELSE BEGIN
         Int_low:=alt_low;
         Int_up:=alt_up;
         Int_tol:=alt_tol;
        END;
  Obj_SetState(D_Int,Exit_Obj,NORMAL,FALSE);
  ok:=IntCheck;
  IF NOT ok THEN Bing
 UNTIL ok;
 End_Dialog(D_Int)
END; { Edit_Int }

PROCEDURE Save_Params;
TYPE ParFile = RECORD
                Konstanten : KonstArray;
                Funktionen : TermArray;
                Skalierung : RECORD
                              xl,xh,yl,yh : REAL;
                              auto        : BOOLEAN
                             END
               END;
VAR f        : File OF ParFile;
    Mask     : Str128;
    C_Path   : CString;
BEGIN
 IF ParPfad='\'
  THEN Mask:='\*.PAR'
  ELSE Mask:=Concat(ParPfad,'\*.PAR');
 Show_Mouse;
 IF Get_In_File(Mask,ParName)
  THEN IF Length(ParName)>0
        THEN BEGIN
              Dgetpath(C_Path,0);
              beauty_path(C_Path);
              make_pstring(C_Path,ParPfad);
              Hide_Mouse;
              IO_Check(FALSE);
              Bee;
              Rewrite(f,ParName);
              No_Bee;
              IF Io_Result<>0
               THEN Fehler('Fehler beim ôffnen der Parameterdatei !')
               ELSE BEGIN
                     WITH f^ DO
                     BEGIN
                      Konstanten:=Konst;
                      Funktionen:=FktTerm;
                      WITH Skalierung DO
                      BEGIN
                       xl:=S_xl; xh:=S_xh;
                       yl:=S_yl; yh:=S_yh;
                       auto:=S_auto
                      END
                     END;
                     Bee;
                     Put(f);
                     No_Bee;
                     IF Io_Result<>0
                      THEN Fehler('Fehler beim Schreiben der Parameter !');
                     Bee;
                     Close(f);
                     No_Bee;
                    END;
                    IO_Check(TRUE)
             END
        ELSE Hide_Mouse
  ELSE Hide_Mouse;
END; { Save_Params }

PROCEDURE Load_Params;
TYPE ParFile = RECORD
                Konstanten : KonstArray;
                Funktionen : TermArray;
                Skalierung : RECORD
                              xl,xh,yl,yh : REAL;
                              auto        : BOOLEAN
                             END
               END;
VAR f         : File OF ParFile;
    Mask      : Str128;
    err       : BOOLEAN;
    i         : INTEGER;
    C_Path    : CString;
BEGIN
 IF ParPfad='\'
  THEN Mask:='\*.PAR'
  ELSE Mask:=Concat(ParPfad,'\*.PAR');
 Show_Mouse;
 IF Get_In_File(Mask,ParName)
  THEN IF Length(ParName)>0
        THEN BEGIN
              Dgetpath(C_Path,0);
              beauty_path(C_Path);
              make_pstring(C_Path,ParPfad);
              Hide_Mouse;
              IO_Check(FALSE);
              Bee;
              Reset(f,ParName);
              No_Bee;
              IF Io_Result<>0
               THEN Fehler('Fehler beim ôffnen der Parameterdatei !')
               ELSE BEGIN
                     FOR i:=1 TO MaxFkt DO FTree_Free(FktPtr[i]);
                     WITH f^ DO
                     BEGIN
                      Konst:=Konstanten;
                      FktTerm:=Funktionen;
                      WITH Skalierung DO
                      BEGIN
                       S_xl:=xl; S_xh:=xh;
                       S_yl:=yl; S_yh:=yh;
                       S_auto:=auto
                      END
                     END;
                     Bee;
                     Close(f);
                     No_Bee;
                     { Funktionspointer intialisieren }
                     FOR i:=1 TO MaxFkt DO
                     BEGIN
                      IF Length(FktTerm[i])>0
                       THEN BEGIN
                             Str_UpCase(FktTerm[i]);
                             FktPtr[i]:=Build_Tree(FktTerm[i],err);
                             IF err THEN FktPtr[i]:=NIL
                            END
                       ELSE FktPtr[i]:=NIL
                     END
                    END;
              IO_Check(TRUE)
             END
        ELSE Hide_Mouse
  ELSE Hide_Mouse;
END; { Load_Params }

PROCEDURE Load_Standards;
TYPE ParFile = RECORD
                Konstanten : KonstArray;
                Funktionen : TermArray;
                Skalierung : RECORD
                              xl,xh,yl,yh : REAL;
                              auto        : BOOLEAN
                             END
               END;
VAR f       : File OF ParFile;
    err     : BOOLEAN;
    i       : INTEGER;
BEGIN
 IO_Check(FALSE);
 Bee;
 Reset(f,'STANDARD.PAR');
 No_Bee;
 IF IO_Result=0
  THEN BEGIN
        WITH f^ DO
        BEGIN
         Konst:=Konstanten;
         FktTerm:=Funktionen;
         WITH Skalierung DO
         BEGIN
          S_xl:=xl; S_xh:=xh;
          S_yl:=yl; S_yh:=yh;
          S_auto:=auto
         END
        END;
        Bee;
        Close(f);
        No_Bee;
        { Funktionspointer intialisieren }
        FOR i:=1 TO MaxFkt DO
        BEGIN
         IF Length(FktTerm[i])>0
          THEN BEGIN
                Str_UpCase(FktTerm[i]);
                FktPtr[i]:=Build_Tree(FktTerm[i],err);
                IF err THEN FktPtr[i]:=NIL
               END
          ELSE FktPtr[i]:=NIL
         END
       END;
 IO_Check(TRUE)
END; { Load_Params }

PROCEDURE Diff_Fkt(Fktno : INTEGER);
VAR i : INTEGER;
    s : Str255;
    t : FTree;
BEGIN
 Bee;
 t:=Diff_Function(FktPtr[FktNo],0);
 No_Bee;
 IF t<>NIL
  THEN BEGIN
        i:=Get_Fktno('Wohin ?');
        s:='';
        Make_FText(t,s);
        FktPtr[i]:=t;
        FktTerm[i]:=s
       END
  ELSE Fehler('Fehler beim Differenzieren !')
END; { Diff_Fkt }

FUNCTION Int_Choice : INTEGER;
VAR Exit_Obj : INTEGER;
BEGIN
 Center_Dialog(D_IChoice);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_IChoice,0);
 Hide_Mouse;
 IF Exit_Obj=IROMBERG
  THEN Int_Choice:=ROMBERG
  ELSE Int_Choice:=TRAPEZ;
 Obj_SetState(D_IChoice,Exit_Obj,NORMAL,FALSE);
 End_Dialog(D_IChoice);
 Show_Wait;
END; { Int_Choice }

FUNCTION RInt_Fkt(Fktno : INTEGER; VAR Ans : REAL) : BOOLEAN;
VAR Nx          : ARRAY [1..16] OF INTEGER;
    T           : ARRAY [1..136] OF REAL;
    Done,Error,
    err         : BOOLEAN;
    Pieces,
    Nt,I,
    Ii,N,Nn,L,
    Ntra,K,M,J  : INTEGER;
    Delta_x,c,
    Sum,Fotom,X : REAL;
BEGIN
 Bee;
 Done:=FALSE;
 Error:=FALSE;
 Pieces:=1;
 Nx[1]:=1;
 Delta_x:=(Int_up-Int_low)/Pieces;
 C:=(Calc_Tree(FktPtr[Fktno],Int_low,err)
     +Calc_Tree(FktPtr[Fktno],Int_up,err))*0.5;
 IF NOT Err
  THEN BEGIN
        T[1]:=Delta_x*C;
        N:=1;
        Nn:=2;
        Sum:=C;
        REPEAT
         N:=N+1;
         Fotom:=4.0;
         Nx[N]:=NN;
         Pieces:=Pieces*2;
         L:=Pieces-1;
         Delta_x:=(Int_up-Int_low)/Pieces;
         FOR Ii:=1 TO (L+1) DIV 2 DO
         BEGIN
          I:=Ii*2-1;
          X:=Int_low+I*Delta_x;
          Sum:=Sum+Calc_Tree(FktPtr[Fktno],x,err);
         END;
         T[NN]:=Delta_x*Sum;
         Ntra:=Nx[N-1];
         K:=N-1;
         FOR M:=1 TO K DO
         BEGIN
          J:=NN+M;
          Nt:=Nx[N-1]+M-1;
          T[J]:=(Fotom*T[J-1]-T[Nt])/(Fotom-1.0);
          Fotom:=Fotom*4.0;
         END;
         IF N>4
          THEN BEGIN
                IF T[Nn+1]<>0.0
                 THEN IF (Abs(T[Ntra+1]-T[Nn+1])<=Abs(T[Nn+1]*Int_tol)) OR (Abs(T[Nn-1]-T[J])<=Abs(T[J]*Int_tol))
                       THEN Done:=TRUE
                       ELSE IF N>15
                             THEN BEGIN
                                   Done:=TRUE;
                                   Error:=TRUE;
                                  END;
               END;
         Nn:=J+1;
        UNTIL Done OR err OR (Buttons<>0);
        Ans:=T[J];
        RInt_Fkt:=NOT (Error OR err)
       END
  ELSE RInt_Fkt:=FALSE;
  No_Bee;
END; { RInt_Fkt }

PROCEDURE TInt_Fkt(Fktno : INTEGER; VAR sum:REAL);
VAR pieces,i    : INTEGER;
    x,delta_x,
    end_sum,
    mid_sum,sum1: REAL;
    err         : BOOLEAN;
BEGIN
 Bee;
 pieces:=1;
 delta_x:=(Int_up-Int_low)/pieces;
 end_sum:=Calc_Tree(FktPtr[Fktno],Int_low,err)
          +Calc_Tree(FktPtr[Fktno],Int_up,err);
 IF NOT err
  THEN BEGIN
        sum:=end_sum*delta_x/2.0;
        mid_sum:=0.0;
        REPEAT
         pieces:=pieces*2;
         sum1:=sum;
         delta_x:=(Int_up-Int_low)/pieces;
         FOR i:=1 TO pieces DIV 2 DO
         BEGIN
          x:=Int_low+delta_x*(2.0*i-1.0);
          mid_sum:=mid_sum+Calc_Tree(FktPtr[Fktno],x,err);
         END;
         sum:=(end_sum+2.0*mid_sum)*delta_x*0.5
        UNTIL (Abs(sum-sum1)<=Abs(Int_tol*sum)) OR err OR (Buttons<>0)
       END;
 No_Bee;
END; { TInt_Fkt }

PROCEDURE Show_Int(Erg : REAL);
VAR Exit_Obj : INTEGER;
    s        : Str255;
BEGIN
 WriteV(s,Erg:14:4);
 Set_DText(D_IShow,FINTERG,s,SYSTEM_FONT,TE_CENTER);
 Center_Dialog(D_IShow);
 Show_Mouse;
 Exit_Obj:=Do_Dialog(D_IShow,0);
 Hide_Mouse;
 Obj_SetState(D_IShow,Exit_Obj,NORMAL,FALSE);
 End_Dialog(D_IShow)
END; { Show_Int }

PROCEDURE Handle_Menu(Entry : INTEGER; VAR Quit : BOOLEAN);
VAR i   : INTEGER;
    Erg : REAL;
BEGIN
 CASE Entry OF
  FMINFO : Show_Info;         { Informationen mittels FUINFO anzeigen }
  FMINPUT : BEGIN
             i:=Get_Fktno('Funktionsauswahl:');   { Funktionsnummer mittels FUCHOICE ermitteln }
             Edit_Fkt(i)      { Funktion mittels FUEDIT editieren }
            END;
  FMOUTPUT : Show_Fkts;       { Funktionen mittels FUSHOW ausgeben }
  FMPAINT : IF CheckFkts
             THEN Paint_Fkts  { Funktionen zeichnen }
             ELSE Fehler('Keine Funktion definiert !');
  FMDIFF : IF CheckFkts
            THEN BEGIN        { Differenzieren }
                  i:=Get_Legal_Fktno('Welche Funktion ?');
                  Diff_Fkt(i)
                 END
            ELSE Fehler('Keine Funktion definiert !');
  FMINT : IF CheckFkts
           THEN BEGIN         { Integrieren }
                 i:=Get_Legal_Fktno('Welche Funktion ?');
                 IF Int_Choice=ROMBERG
                  THEN IF RInt_Fkt(i,Erg)
                        THEN Show_Int(Erg)
                        ELSE Fehler('Integrationsverfahren konvergiert nicht!')
                  ELSE BEGIN
                        TInt_Fkt(i,Erg);
                        Show_Int(erg)
                       END
                END
           ELSE Fehler('Keine Funktion definiert !');
  FMEND : Quit:=TRUE;         { Programmende }
  FMCONST : Edit_Konsts;      { Konstanten mittels FUCONST editieren }
  FMSCALE : Edit_Scale;       { Skalierung mittels FUSCALE editieren }
  FMEINT : Edit_Int;          { Integrationskonstanten editieren }
  FMLOAD : Load_Params;       { Parameter laden }
  FMSAVE : Save_Params        { Parameter speichern }
 END
END; { Handle_Menu }

PROCEDURE Handle_Keyboard(Key : INTEGER; VAR Quit : BOOLEAN);
BEGIN
 CASE Key & $FF OF
  03 : Handle_Menu(FMINFO,Quit);   { ^C }
  05 : Handle_Menu(FMINPUT,Quit);  { ^E }
  01 : Handle_Menu(FMOUTPUT,Quit); { ^A }
  26 : Handle_Menu(FMPAINT,Quit);  { ^Z }
  04 : Handle_Menu(FMDIFF,Quit);   { ^D }
  09 : Handle_Menu(FMINT,Quit);    { ^I }
  17 : Handle_Menu(FMEND,Quit);    { ^Q }
  11 : Handle_Menu(FMCONST,Quit);  { ^K }
  19 : Handle_Menu(FMSCALE,Quit);  { ^S }
  12 : Handle_Menu(FMLOAD,Quit);   { ^L }
  22 : Handle_Menu(FMEINT,Quit);   { ^V }
  23 : Handle_Menu(FMSAVE,Quit)    { ^W }
 END
END; { Handle_Keyboard }

FUNCTION Fenster_Auf : INTEGER;
VAR W_Title  : Window_Title;
    W_Handle : INTEGER;
BEGIN
 W_Title:='DisabSoft';
 W_Handle:=New_Window(None,W_Title,0,0,xAuf,yAuf);
 Open_Window(W_Handle,0,0,0,0);
 Fenster_Auf:=W_Handle
END; { Fenster_Auf }

PROCEDURE Rahmen;
VAR W_Handle,Event,
    Taste,d         : INTEGER;
    x2,y2,w2,h2     : INTEGER;
    Msg             : Message_Buffer;
    Quit            : BOOLEAN;
BEGIN
 Load_Standards;
 W_Handle:=Fenster_Auf;
 Draw_Menu(M_Main);
 Quit:=FALSE;
 REPEAT
  Show_Mouse;
  FOR d:=0 TO 15 DO Msg[d]:=0;
  REPEAT
   Event:=Get_Event(E_Message | E_Timer | E_Keyboard,1,1,1,$1000,
                    FALSE,0,0,0,0,FALSE,0,0,0,0,
                    Msg,Taste,d,d,d,d,d)
  UNTIL (   (Msg[0]=Mn_Selected)
         OR (Msg[0]=Wm_Redraw)
         OR ((Event & E_Keyboard)<>0));
  Hide_Mouse;
  IF Msg[0]=Mn_Selected
   THEN BEGIN
         Handle_Menu(Msg[4],Quit);
         Menu_Normal(M_Main,Msg[3])
        END
   ELSE IF Msg[0]=Wm_Redraw
         THEN BEGIN
               Erase_Menu(M_Main);
               first_rect(W_Handle,x2,y2,w2,h2);
               begin_update;
               WHILE (w2<>0) OR (h2<>0) DO
               BEGIN
                IF rect_intersect(Msg[4],Msg[5],Msg[6],Msg[7],x2,y2,w2,h2)
                 THEN Paint_Grey(x2,y2,w2,h2);
                next_rect(W_Handle,x2,y2,w2,h2);
               END;
               end_update;
               Draw_Menu(M_Main);
              END
         ELSE IF (Event & E_Keyboard)<>0
               THEN Handle_Keyboard(Taste,Quit)
 UNTIL Quit;
 Erase_Menu(M_Main);
 Delete_Menu(M_Main);
 Close_Window(W_Handle);
 Delete_Window(W_Handle)
END; { Rahmen }

PROCEDURE Init_Objects;
BEGIN
 Find_Menu(FUMENU,M_Main);
 Find_Dialog(FUINFO,D_Info);
 Find_Dialog(FUCHOICE,D_Choice);
 Find_Dialog(FUEDIT,D_Edit);
 Find_Dialog(FUSHOW,D_Show);
 Find_Dialog(FUCONST,D_Konst);
 Find_Dialog(FUSCALE,D_Scale);
 Find_Dialog(FUDRAW,D_Draw);
 Find_Dialog(FUERROR,D_Error);
 Find_Dialog(FUINT,D_Int);
 Find_Dialog(FINTSHOW,D_IShow);
 Find_Dialog(ICHOICE,D_IChoice);
 Find_Dialog(FUWAIT,D_Wait);
END; { Init_Objects }

PROCEDURE Init_Vars;
VAR i,x,y  : INTEGER;
    C_Path : CString;
BEGIN
 FOR i:=1 TO MaxKonst DO
 BEGIN
  Konst[i].Ko_Name:='';
  Konst[i].Ko_Wert:=0;
 END;
 FOR i:=1 TO MaxFkt DO
 BEGIN
  FktTerm[i]:='';
  FktPtr[i]:=NIL
 END;
 S_xl:=-10;
 S_xh:=10;
 S_yl:=-10;
 S_yh:=10;
 Int_low:=-10;
 Int_up:=10;
 Int_tol:=0.0001;
 S_Auto:=FALSE;
 Dgetpath(C_Path,0);
 beauty_path(C_Path);
 make_pstring(C_Path,ParPfad);
 ParName:='STANDARD.PAR';
 Bee_Active:=FALSE;
 Border_Rect(0,x,y,xAuf,yAuf);
 IF xAuf>Max_xAuf Then xAuf:=Max_xAuf;
 xAkt:=xAuf;
 yAkt:=yAuf;
 meta_nr:=31;
 Meta_Name:='FKTPLOT.GEM';
 Draw_Dest:=Screen;
END; { Init_Vars }


BEGIN
 IF Getrez<>2 THEN BEGIN
                    WriteLn('FktPlot lÑuft nur in hoher Auflîsung ! <RETURN>');
                    ReadLn;
                    Halt
                   END;
 IF Init_Gem<>0 THEN BEGIN
                      WriteLn('GEM-Anwendung konnte nicht angemeldet werden ! <RETURN>');
                      ReadLn;
                      Halt
                     END;
 IF NOT Load_Resource('FKTPLOT.RSC') THEN BEGIN
                                           WriteLn('Resource-Datei nicht gefunden ! <RETURN>');
                                           ReadLn;
                                           Halt
                                          END;
 Init_Objects;
 Init_Vars;
 Init_Graphics;
 Init_Mouse;
 Hide_Mouse;
 Rahmen;
 Show_Mouse;
 Exit_Gem
END.

