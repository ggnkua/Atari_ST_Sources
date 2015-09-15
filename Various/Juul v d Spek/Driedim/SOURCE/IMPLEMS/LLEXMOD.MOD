
IMPLEMENTATION MODULE LLexMod;

(*****************************************************)
(*                                                   *)
(*      DRIEDIM SCANNER V2.1                         *)
(*      --------------------                         *)
(*                                                   *)
(*   Author: Juul v/d Spek, Valkenswaard.            *)
(*                                                   *)
(*   please do not alter this text without           *)
(*   author's permission.                            *)
(*                                                   *)
(*****************************************************)
(*                                                   *)
(* This module implements a lexical analyser for     *)
(* program DrieDim.                                  *)
(*                                                   *)
(*****************************************************)

  (*$T-*) (*$C-*)

FROM TextIO  IMPORT Read, Write, WriteLn, WriteString,
                    WriteCard, WriteInt, WriteReal,
                    REad;

FROM String  IMPORT Strings, Length;

FROM Streams IMPORT Stream, StreamKinds,
                    OpenStream, CloseStream, EOS;

  CONST  
       LNrString   = 100;  (* number of keywords    *)

       StringSpace = 500; (* size of stringspace   *)

       TabSym   = 11C;
       FFSym    = 14C;
       EofSym   =  0C;
       EolnSym  = 15C;
       LFSym    = 12C;

  TYPE   

       SOC         = SET OF CHAR; (* Type id for character sets *)

       StringTab   = (* identifier table, with next free place *)
 
                      RECORD    
                        Space   : ARRAY [1 .. StringSpace ] OF CHAR;
                        Tab     : ARRAY [1 .. LNrString ] OF Str;
                        NxtCh   : CARDINAL; (* Next free char in Space    *)
                        NxtId   : LIdenNr;  (* Next free id in Tab        *)
                      END;                            

       ErrorId= (* Messages for all kinds of errors: *)
                (IllegalSymbErr, NumbOvfErr, SpaceFullErr,
                 SymbTabFullErr, StrNotTermErr);


      

  VAR 
    InputHead: CHAR;        (* lookahead symbol for file InFile of LLex    *)
    StrTab   : StringTab;   (* table for reserved words and identifiers    *)
    NrKeys   : CARDINAL;    (* Number of reserved words placed into StrTab *)
    SOpen    : BOOLEAN;     (* Boolean to flag that s is still open        *)
    s        : Stream;      (* Inputfile                                   *)
    i        : INTEGER;


PROCEDURE EqString(s1,s2: Str): BOOLEAN;
  VAR b: BOOLEAN;
      i: CARDINAL;
BEGIN
  WITH StrTab DO
    WITH s1 DO
      b:= Len=s2.Len;
      i:= 0;
      WHILE (i<Len) AND b DO
        IF Space[Base+i]=Space[s2.Base+i] THEN
          i:= i+1
         ELSE b:= FALSE
        END;
      END;
    END;
  END;
  RETURN b;
END EqString;


PROCEDURE PrintString(s: Str);
  VAR i: CARDINAL;
BEGIN
  WITH StrTab DO
    WITH s DO
      FOR i:= Base TO Base+Len-1 DO Write(Space[i]) END;
    END;
  END;
END PrintString;


PROCEDURE KeyTok(i: LIdenNr): LTokenId;
(* translation of identifier numbers to Tokens *)
BEGIN
  CASE i OF 
    1 :  RETURN LObjectTok     |
    2 :  RETURN LObendTok      |
    3 :  RETURN LLineTok       |
    4 :  RETURN LLineEndTok    |
    5 :  RETURN LPlaneTok      |
    6 :  RETURN LPlaneEndTok   |
    7 :  RETURN LAtTok         |
    8 :  RETURN LTurnTok       |
    9 :  RETURN LTimesTok      |
   10 :  RETURN LInternTok     |
   11 :  RETURN LHeapSizeTok
  END;
END KeyTok;



PROCEDURE TokKey(i: LTokenId): LIdenNr;
(* translation of Reserved word tokens to iden nrs *)
BEGIN
  CASE i OF 
    LObjectTok     :  RETURN 1 |
    LObendTok      :  RETURN 2 |
    LLineTok       :  RETURN 3 |
    LLineEndTok    :  RETURN 4 |
    LPlaneTok      :  RETURN 5 |
    LPlaneEndTok   :  RETURN 6 |
    LAtTok         :  RETURN 7 |
    LTurnTok       :  RETURN 8 |
    LTimesTok      :  RETURN 9 |
    LInternTok     :  RETURN 10|
    LHeapSizeTok   :  RETURN 11
  END;
END TokKey;


PROCEDURE IntToReal(i: INTEGER): REAL;
  VAR b: BOOLEAN;
      r: REAL;
BEGIN
  IF i>0 THEN RETURN  FLOAT( VAL(CARDINAL, i) )
         ELSE RETURN -FLOAT( VAL(CARDINAL,-i) )
  END;
END IntToReal;


PROCEDURE LMakeReal(VAR t: LToken);
(********************************)
(* Converts integer token t to  *)
(* a REAL token of same value   *)
(* PRE: t.Sel= LIntegerTok      *)
(********************************)
BEGIN
  WITH t DO
    Sel:= LRealTok;
    RealVal:= IntToReal(IntegerVal)
  END
END LMakeReal;


PROCEDURE Error(e: ErrorId);
(* print message for error e *)
BEGIN
  LexError:= TRUE;
  WriteString('** lexical error in line ');
  WriteCard(LineNr,1); WriteString(": ");
  CASE e OF
    IllegalSymbErr: WriteString('Illegal symbol encountered.')      |
    SpaceFullErr  : WriteString("String space overflow.")           |
    NumbOvfErr    : WriteString('Numeric constant overflows.')      |
    StrNotTermErr : WriteString('No string terminator before eoln.')|
    SymbTabFullErr: WriteString('No space left in Symbol Table.')   
  END;
  WriteLn;
END Error;



PROCEDURE ReadIn;
(* read next Character from InFile *)
BEGIN
  IF SOpen THEN
    IF EOS(s) THEN 
      InputHead:= EofSym;
      SOpen:= FALSE;
      CloseStream(s,i)
     ELSE REad(s,InputHead) 
    END
   ELSE InputHead:= EofSym
  END;

  IF InputHead=EolnSym THEN LineNr:= LineNr+1 END;

  (* EolnSyms not converted to spaces, because *)
  (* we want to flag StrNotTermErrs:           *)
  IF InputHead IN SOC{TabSym, LFSym, FFSym} THEN InputHead:= ' ' END;

END ReadIn;


PROCEDURE ReadChar(): CHAR;
(* read next Character from InFile 
 * through lookahead table
 *)
  VAR c: CHAR;
BEGIN
  c:= InputHead;
  ReadIn;
  RETURN c;
END ReadChar;


PROCEDURE PeekChar(): CHAR;
(* Function to obtain the first nonblank Character 
 *  to be read (is not read yet).
 *)
  VAR c: CHAR;
      i: CARDINAL;
BEGIN
  WHILE InputHead IN SOC{' ', EolnSym} DO ReadIn END;
  RETURN InputHead
END PeekChar;


PROCEDURE ReadNumb(VAR Tok: LToken; Negative: BOOLEAN);
(* Read next number, and construct numeric 
 *  token with that value into Tok.
 *)
  CONST MaxInt= 65000;

  VAR  i     : CARDINAL;
       Card  : BOOLEAN;
       c     : CHAR;
       j     : REAL;

BEGIN
  WITH Tok DO
    Card:= TRUE;   (* Assume number is an integer *)
    Sel := LIntegerTok;
    IntegerVal:= 0;

    (* read integer (part of Real) *)
    WHILE InputHead IN SOC{'0' .. '9'} DO 
      i:= ORD(ReadChar()) - ORD('0');
      IF Card THEN
        IF ((MaxInt-i) DIV 10)>=VAL(CARDINAL,IntegerVal)
          THEN IntegerVal:= 10*IntegerVal + VAL(INTEGER,i)
         ELSE (* integer overflow: try real *)
          Sel := LRealTok;
          Card:= FALSE;
          RealVal:= IntToReal(IntegerVal)
        END
       ELSE (* If not Card *)
        RealVal:= 10.0*RealVal + FLOAT(i)
      END;
    END;

    IF InputHead="." THEN
      IF Card THEN 
        Sel := LRealTok;
        Card:= FALSE;
        RealVal:= IntToReal(IntegerVal);
      END;
      ReadIn;
      j:= 1.0;
      (* read integer (part of Real) *)
      WHILE InputHead IN SOC{'0' .. '9'} DO 
        j:= j*10.0;
        i:= ORD(ReadChar()) - ORD('0'); 
        RealVal:= RealVal+FLOAT(i)/j;
      END;
    END;


    IF Negative THEN 
      IF Card THEN IntegerVal:= -IntegerVal 
       ELSE RealVal:= -RealVal
      END;
    END;

  END;
END ReadNumb;


PROCEDURE ReadStr(VAR Tok: LToken);
(* Read next string, and construct string
 *  token with that value into Tok.
 *)
  VAR c: CHAR;
BEGIN
  WITH Tok DO WITH StrTab DO WITH StringVal DO
    ReadIn;
    Sel:= LStringTok;
    Base:= NxtCh;
    Len := 0; 

    WHILE NOT ( InputHead IN SOC{'"', EolnSym, EofSym} ) DO 
      Space[NxtCh]:= ReadChar();
      IF NxtCh=StringSpace THEN Error(SpaceFullErr)
       ELSE NxtCh:= NxtCh+1
      END;
    END;
    Len:= NxtCh-Base;

    IF InputHead=EolnSym THEN 
      Error(StrNotTermErr);
      WriteString("   String: '");
      PrintString(StringVal);
      Write("'");
      WriteLn
    END;

    ReadIn;
  END; END; END;  (* WITH`s *)
END ReadStr;


PROCEDURE ReadIden(VAR Tok: LToken);
(* read an identifier; when that identifier 
 * turns out to be a reserved word, then
 * return a token for that reserved word.
 *)
  VAR i : LIdenNr;

BEGIN
  WITH Tok DO WITH StrTab DO WITH Tab[NxtId] DO
    Sel:= LIdenTok;
    Base:= NxtCh;
    Len:=  0;

   (* read representation of identifier into first free place *)
    WHILE InputHead IN SOC{'A' .. 'Z', 'a' .. 'z', '0' .. '9'} DO 
      Space[NxtCh]:= CAP(ReadChar());
      IF NxtCh=StringSpace THEN Error(SpaceFullErr)
       ELSE NxtCh:= NxtCh+1
      END;
    END;
    Len:= NxtCh-Base;

   (* check if identifier already exists *)
    i:= 1;   
    WHILE NOT EqString(Tab[i], Tab[NxtId]) DO i:= i+1 END;

   (* if not: increase NxtId (place is now occupied by new Id) *)
    IF i=NxtId THEN 
      IF NxtId=LNrString THEN Error(SymbTabFullErr)
       ELSE NxtId:= NxtId+1;
      END
     ELSE
      NxtCh:= Base
    END;

 (* change Tok to token of reserved word, if neccessary *)      
    IF i<= NrKeys THEN
      Sel:= KeyTok(i)
     ELSE
      IdenVal:= i    
    END;
  END; END; END;
END ReadIden;


PROCEDURE LLex(VAR Tok: LToken); 

(********************************)
(* Reads one new token which is *)
(*  placed into Tok.            *)
(********************************)

  VAR c        : CHAR;

BEGIN
 WITH Tok DO
  REPEAT  (* UNTIL the token read is not an errortoken *)

    c:= PeekChar();
    WHILE c='{' DO (*  read comment  *)
      REPEAT c:= ReadChar() UNTIL c IN SOC{'}', EofSym};
      c:= PeekChar();
    END;

  
        IF c IN SOC{'a' .. 'z', 'A' .. 'Z'} THEN ReadIden(Tok)
     ELSIF c IN SOC{".", '0' .. '9'}        THEN ReadNumb(Tok,FALSE)
     ELSIF c='"'                            THEN ReadStr(Tok)
     ELSIF c=EofSym                         THEN Sel:= LEofTok
     ELSIF c="-"  THEN
        c:= ReadChar();
        IF PeekChar() IN SOC{".", '0' .. '9'} THEN ReadNumb(Tok,TRUE)
         ELSE
          Sel:= LErrTok;
          ErrVal:= "-"
        END
    ELSE 
        c:= ReadChar();
        Sel   := LErrTok;    (* default Token is error *)
        ErrVal:= c;          (* with erroneous Char= c *)
    
        IF c IN SOC{ ';', ',', '='}
          THEN
            CASE c OF
              ';': Sel:= LSemicolTok|
              ',': Sel:= LCommaTok  |
              '=': Sel:= LEqualTok
            END
        END;
    
    END;

    IF Sel=LErrTok THEN (* give error message, and try again *)
      Error(IllegalSymbErr);
      WriteString   ("   Symbol: '");
      Write         (ErrVal);
      WriteString   ("'; repr= ");
      WriteCard     (ORD(ErrVal),1);
      Write         ('.');
      WriteLn
    END;

  UNTIL Sel<>LErrTok;
 END;
END LLex;


PROCEDURE AddId(k: Strings);
(* procedure to put representation of reserved word
 * into symbol table. Is used during initialisation
 * NOTE: No checking on overflow is done yet
 *)
  VAR i: CARDINAL;
      s: Str;
BEGIN
  WITH StrTab DO WITH Tab[NxtId] DO
    Base:= NxtCh;    

    FOR i:= 0 TO Length(k)-1 DO
      Space[NxtCh]:= k[i];
      NxtCh:= NxtCh+1; 
    END;

    Len:= NxtCh-Base;
    NxtId:= NxtId+1;
  END; END;
  NrKeys:= NrKeys+1;
END AddId;


PROCEDURE LInitWarmLex(Fil: Strings): BOOLEAN;
(*******************************************)
(* This procedure is used to open an input *)
(*  file for the lexical analyser          *)
(*******************************************)
BEGIN
  OpenStream(s, Fil, READ, i);
  SOpen:= i>=0;

  LexError:= FALSE;

  ReadIn;

  RETURN SOpen;
END LInitWarmLex;  



PROCEDURE LInitColdLex;
(******************************************)
(* This procedure is used to initialise   *)
(*  the lexical analyser for the first    *)
(*  time. Tables are set up, and reserved *)
(*  words are declared.                   *)
(******************************************)

BEGIN
  LineNr:= 1;
  NrKeys:= 0;
  StrTab.NxtId := 1;
  StrTab.NxtCh := 1;

  AddId('OBJECT'   );
  AddId('OBEND'    );
  AddId('LINE'     );
  AddId('ENDLINE'  );
  AddId('PLANE'    );
  AddId('ENDPLANE' );
  AddId('AT'       );
  AddId('TURN'     );
  AddId('TIMES'    );
  AddId('INTERN'   );
  AddId('HEAPSIZE' );  
END LInitColdLex;



PROCEDURE LPrintToken(t: LToken);
(**************************************)
(* print representation of t into Fil *)
(**************************************)
BEGIN
  Write(' ');
  WITH t DO
    CASE Sel OF
      LIdenTok     :  PrintString(StrTab.Tab[IdenVal]) |
      LRealTok     :  WriteReal(RealVal,8,2);          |
      LIntegerTok  :  WriteInt(IntegerVal,1)           |
      LEofTok      :  WriteString('<Eof>')             |
      LErrTok      :  WriteString('<Error>')           |

      LStringTok   :  Write("'");
                      PrintString(StringVal);
                      Write("'")|

      LCommaTok    :  Write(',')|
      LSemicolTok  :  Write(';')|
      LEqualTok    :  Write(':')          
      
      ELSE PrintString(StrTab.Tab[TokKey(Sel)] )
    END;
  END;
END LPrintToken;


BEGIN
  LInitColdLex
END LLexMod.




