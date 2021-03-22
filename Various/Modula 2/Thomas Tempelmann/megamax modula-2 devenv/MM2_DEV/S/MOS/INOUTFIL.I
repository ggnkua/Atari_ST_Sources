IMPLEMENTATION MODULE InOutFile; (* V#030 *)
(*$Y+,R-,S-,M-*)

(*
  27.6.88  TT  Einige $L- eingefhrt.
  17.9.88  TT  ReadNum/ReadLNum korrigiert - auch Korrektur in InOut!
  21.7.91  TT  ReadReal ruft nun korrekterweise RealLReal statt ReadReal
               aus NumberIO auf.
*)

FROM SYSTEM IMPORT ASSEMBLER, WORD, LONGWORD, ADR, ADDRESS;

FROM FileNames IMPORT SplitPath, SplitName;

FROM Strings IMPORT Append, Length, Empty, MaxChars;

FROM InOutBase IMPORT consIn, consOut, done, eop, level, inLev, outLev, termCh;

IMPORT InOutBase;

FROM Files IMPORT File, Access, ReplaceMode;

IMPORT Files, Text, NumberIO;

(* Fr folg. Import: *)
FROM FileBase IMPORT Unit, UDataProc, UCloseProc, UFlushProc, UWStrProc,
        URStrProc, UGChrProc;

(*$I FileDesc.Icl *)


CONST   EOL = 15C;  (* wie in InOut ! *)

VAR     input, output: File;
        ok: BOOLEAN;
        goxy:ARRAY [0..3] OF CHAR;


FORWARD initDriver;


PROCEDURE ctrlIn;
  (*$L-*)
  BEGIN
    IF ~consOut THEN
      IF done THEN
        IF consIn THEN InOutBase.CloseWdw END
      ELSE
        IF ~consIn THEN InOutBase.OpenWdw (0,0) END
      END
    END;
    consIn:= ~done
  END ctrlIn;
  (*$L=*)

PROCEDURE ctrlOut;
  (*$L-*)
  BEGIN
    IF ~consIn THEN
      IF done THEN
        IF consOut THEN InOutBase.CloseWdw END
      ELSE
        IF ~consOut THEN InOutBase.OpenWdw (0,0) END
      END
    END;
    consOut:= ~done
  END ctrlOut;
  (*$L=*)

PROCEDURE clsIn;
  (*$L-*)
  BEGIN
    IF ~consIn THEN Files.Close (input) END
  END clsIn;
  (*$L=*)

PROCEDURE clsOut;
  (*$L-*)
  BEGIN
    IF ~consOut THEN Files.Close (output) END
  END clsOut;
  (*$L=*)

PROCEDURE doneIn;
  (*$L-*)
  BEGIN
    done:= Files.State (input) >= 0;
  END doneIn;
  (*$L=*)

PROCEDURE doneOut;
  (*$L-*)
  BEGIN
    done:= Files.State (output) >= 0;
  END doneOut;
  (*$L=*)


PROCEDURE redirectInput (REF fileName: ARRAY OF CHAR);
  BEGIN
    initDriver;
    clsIn;
    inLev:= level;
    Files.Open (input,fileName,readSeqTxt);
    doneIn;
    ctrlIn;
  END redirectInput;

PROCEDURE redirectOutput (REF fileName: ARRAY OF CHAR; append: BOOLEAN);
  VAR acc:Access;
  BEGIN
    initDriver;
    clsOut;
    IF append THEN acc:=appendSeqTxt ELSE acc:=writeSeqTxt END;
    outLev:= level;
    Files.Create (output,fileName,acc,replaceOld);
    doneOut;
    ctrlOut;
  END redirectOutput;


PROCEDURE apndExt ( REF def: ARRAY OF CHAR; VAR s: ARRAY OF CHAR );
  VAR s1: ARRAY [0..79] OF CHAR;
      s2: ARRAY [0..11] OF CHAR;
  BEGIN
    SplitPath (s,s1,s2);
    SplitName (s2,s1,s2);
    IF Empty (s2) & ( s[Length(s)-1] # '.' ) THEN
      IF def[0]#'.' THEN
        Append ('.',s,ok)
      END;
      Append (def,s,ok)
    END
  END apndExt;

PROCEDURE openInput ( REF defExt: ARRAY OF CHAR );
  VAR name: ARRAY [0..79] OF CHAR; retry: BOOLEAN;
  BEGIN
    initDriver;
    clsIn;
    REPEAT
      InOutBase.GetInput (name);
      IF Empty (name) THEN
        done:= FALSE;
        retry:= FALSE
      ELSE
        apndExt (defExt,name);
        inLev:= level;
        Files.Open (input,name,readSeqTxt);
        doneIn;
        IF ~done THEN
          Files.GetStateMsg (Files.State (input), name);
          InOutBase.OpenError (name, retry)
        END
      END
    UNTIL done OR ~retry;
    ctrlIn;
  END openInput;

PROCEDURE openOutput ( REF defExt: ARRAY OF CHAR );
  VAR name: ARRAY [0..79] OF CHAR;
  VAR retry, append: BOOLEAN;
        acc:Access;
  BEGIN
    initDriver;
    clsOut;
    REPEAT
      InOutBase.GetOutput (name,append);
      IF Empty (name) THEN
        done:= FALSE;
        retry:= FALSE
      ELSE
        apndExt (defExt,name);
        IF append THEN acc:=appendSeqTxt ELSE acc:=writeSeqTxt END;
        outLev:= level;
        Files.Create (output,name,acc,replaceOld);
        doneOut;
        IF ~done THEN
          Files.GetStateMsg (Files.State (output), name);
          InOutBase.OpenError (name, retry)
        END
      END
    UNTIL done OR ~retry;
    ctrlOut;
  END openOutput;

PROCEDURE clsInOut;
  (*$L-*)
  BEGIN
    IF ~consOut & ~consIn & ~eop THEN InOutBase.OpenWdw (0,0) END
  END clsInOut;
  (*$L=*)

PROCEDURE CloseInput;
  (*$L-*)
  BEGIN
    Files.ResetState (input);
    Files.Close (input);
    clsInOut;
    consIn:=TRUE;
  END CloseInput;
  (*$L=*)

PROCEDURE CloseOutput;
  (*$L-*)
  BEGIN
    Files.ResetState (output);
    Files.Close (output);
    clsInOut;
    consOut:=TRUE;
  END CloseOutput;
  (*$L=*)


PROCEDURE IOError (no: INTEGER; t: BOOLEAN);
  VAR msg: ARRAY [0..31] OF CHAR;
  BEGIN
    Files.GetStateMsg (no, msg);
    InOutBase.IOError (msg, t)
  END IOError;
  

PROCEDURE Read (VAR c: CHAR);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  A0,-(A7)
        MOVE.L  input,(A3)+
        MOVE.L  A0,(A3)+
        JSR     Text.Read
        
        MOVE.L  input,(A3)+
        JSR     Text.EOL
        TST     -(A3)
        BEQ     e0
        MOVE.L  input,(A3)+
        JSR     Files.EOF
        TST     -(A3)
        BEQ     d2
        
        MOVE.L  input,(A3)+
        JSR     Files.State
        TST.W   -2(A3)
        BPL     normalClose
        MOVE    #1,(A3)+
        JSR     IOError         ; IOError (State (input),TRUE)
        CLR     done
        JMP     CloseInput

     normalClose
        SUBQ.L  #2,A3
        JSR     CloseInput
        CLR     done
        MOVE.L  (A7)+,A0
        CLR.B   (A0)            ; bei Dateiende ch:= 0C
        RTS
        
     d2 MOVE.L  input,(A3)+
        JSR     Text.ReadLn
        MOVE.L  (A7),A0
        MOVE.B  #EOL,(A0)
     e0 ADDQ.L  #4,A7
        MOVE    #1,done
    END
  END Read;
  (*$L=*)


PROCEDURE KeyPressed   (): BOOLEAN;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE    #1,(A3)+
    END
  END KeyPressed;
  (*$L=*)

PROCEDURE CondRead     (VAR c: CHAR; VAR valid: BOOLEAN);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),D1
        MOVE.L  D1,-(A7)
        MOVE.L  input,A0
        MOVE.W  FileDesc.uecho(A0),-(A7)
        CLR.W   FileDesc.uecho(A0)       ; kein Echo
        MOVE.L  A0,(A3)+
        MOVE.L  D1,(A3)+
        MOVE    #1,(A1)         ; valid:= TRUE
        JSR     Text.Read
        MOVE.L  input,A0
        MOVE.W  (A7)+,FileDesc.uecho(A0)
        
        MOVE.L  A0,(A3)+
        JSR     Text.EOL
        TST     -(A3)
        BEQ     e0
        MOVE.L  input,(A3)+
        JSR     Files.EOF
        TST     -(A3)
        BEQ     d2
        
        MOVE.L  (A7)+,A0
        CLR.B   (A0)            ; ch:= 0C
        MOVE.L  (A7)+,A0
        CLR.W   (A0)            ; valid:= FALSE
        CLR     done
        
        MOVE.L  input,(A3)+
        JSR     Files.State
        TST.W   -2(A3)
        BPL     normalClose
        
        MOVE    #1,(A3)+
        JSR     IOError         ; IOError (State (input),TRUE)
        JMP     CloseInput

     normalClose
        SUBQ.L  #2,A3
        JMP     CloseInput
        
     d2 MOVE.L  input,(A3)+
        JSR     Text.ReadLn
        MOVE.L  (A7),A0
        MOVE.B  #EOL,(A0)
     e0 ADDQ.L  #4,A7
        MOVE.L  (A7)+,A0
        MOVE    #1,(A0)         ; valid
        MOVE    #1,done
    END
  END CondRead;
  (*$L=*)

PROCEDURE Skip;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  input,(A3)+
        JSR     Text.EOL
        TST     -(A3)
        BEQ     d1
        MOVE.L  input,(A3)+
        JSR     Files.EOF
        TST     -(A3)
        BEQ     d2
        
        CLR     done
        MOVE.L  input,(A3)+
        JSR     Files.State
        TST.W   -2(A3)
        BPL     normalClose
        MOVE    #1,(A3)+
        JSR     IOError         ; IOError (State (input),TRUE)
     d3 JMP     CloseInput

     normalClose
        SUBQ.L  #2,A3
        BRA     d3
        
     d2 MOVE.B  #EOL,InOutBase.termCh
        MOVE.L  input,(A3)+
        JMP     Text.ReadLn
     d1 MOVE.L  input,(A3)+
        JSR     Text.UndoRead
        MOVE.L  input,(A3)+
        MOVE.L  #InOutBase.termCh,(A3)+
        JMP     Text.Read
    END
  END Skip;
  (*$L=*)

PROCEDURE ReadString (VAR s: ARRAY OF CHAR);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  input,(A3)+
        MOVE.L  D1,(A3)+
        MOVE.W  D0,(A3)+
        JSR     Text.ReadString
        MOVE    #1,done
        JMP     Skip
    END
  END ReadString;
  (*$L=*)

PROCEDURE RdWLR;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  input,(A3)+
        MOVE.L  D0,(A3)+
        MOVE.L  #done,(A3)+
        JSR     (A0)
        JMP     Skip
    END
  END RdWLR;
  (*$L=*)

PROCEDURE ReadCard     (VAR v: CARDINAL);
  (*$L-*)
  BEGIN
    ASSEMBLER
        JMP     NumberIO.ReadCard
    END
  END ReadCard;
  (*$L=*)

PROCEDURE ReadInt      (VAR v: INTEGER);
  (*$L-*)
  BEGIN
    ASSEMBLER
        JMP     NumberIO.ReadInt
    END
  END ReadInt;
  (*$L=*)

PROCEDURE ReadLCard    (VAR v: LONGCARD);
  (*$L-*)
  BEGIN
    ASSEMBLER
        JMP     NumberIO.ReadLCard
    END
  END ReadLCard;
  (*$L=*)

PROCEDURE ReadLInt     (VAR v: LONGINT);
  (*$L-*)
  BEGIN
    ASSEMBLER
        JMP     NumberIO.ReadLInt
    END
  END ReadLInt;
  (*$L=*)

PROCEDURE ReadReal     (VAR v: LONGREAL);
  (*$L-*)
  BEGIN
    ASSEMBLER
        JMP     NumberIO.ReadLReal
    END
  END ReadReal;
  (*$L=*)

PROCEDURE ReadNum      (VAR v: WORD;     base: CARDINAL);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),D0
        MOVE.L  input,(A3)+
        MOVE.L  D0,(A3)+
        MOVE.W  D1,(A3)+
        MOVE.L  #done,(A3)+
        JSR     NumberIO.ReadNum
        JMP     Skip
    END
  END ReadNum;
  (*$L=*)

PROCEDURE ReadLNum     (VAR v: LONGWORD; base: CARDINAL);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),D0
        MOVE.L  input,(A3)+
        MOVE.L  D0,(A3)+
        MOVE.W  D1,(A3)+
        MOVE.L  #done,(A3)+
        JSR     NumberIO.ReadLNum
        JMP     Skip
    END
  END ReadLNum;
  (*$L=*)

(* ********************************************************************** *)
(* ************************    A u s g a b e    ************************* *)
(* ********************************************************************** *)


PROCEDURE chkOut;
  (*$L-*)
  BEGIN
    IF Files.State (output) < 0 THEN
      IOError (Files.State (output),FALSE);
      CloseOutput;
    END;
  END chkOut;
  (*$L=*)


PROCEDURE Write (c: CHAR);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        MOVE.L  output,(A3)+
        MOVE    D0,(A3)+
        JSR     Text.Write
        JMP     chkOut
    END;
  END Write;
  (*$L=*)


PROCEDURE WriteLn;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  output,(A3)+
        JSR     Text.WriteLn
        JMP     chkOut
    END
  END WriteLn;
  (*$L=*)

PROCEDURE WritePg;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  output,(A3)+
        JSR     Text.WritePg
        JMP     chkOut
    END
  END WritePg;
  (*$L=*)


PROCEDURE GotoXY (x, y: CARDINAL);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        LEA     goxy,A0
        ADDI    #32,D0
        MOVE.B  D0,3(A0)
        SWAP    D0
        ADDI    #32,D0
        MOVE.B  D0,2(A0)
        MOVE.L  output,(A3)+
        MOVE.L  A0,(A3)+
        MOVE    #3,(A0)+
        JSR     Text.WriteString
        JMP     chkOut
    END
  END GotoXY;
  (*$L=*)


PROCEDURE WriteString (REF s: ARRAY OF CHAR);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  output,(A3)+
        MOVE.L  D1,(A3)+
        MOVE    D0,(A3)+
        JSR     Text.WriteString
        JMP     chkOut
    END;
  END WriteString;
  (*$L=*)


PROCEDURE initDriver;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  #Read,InOutBase.fRead
        MOVE.L  #KeyPressed,InOutBase.fKeyPressed
        MOVE.L  #CondRead,InOutBase.fCondRead
        MOVE.L  #ReadString,InOutBase.fReadString
        MOVE.L  #RdWLR,InOutBase.fRdWLR
        MOVE.L  #ReadCard,InOutBase.fReadCard
        MOVE.L  #ReadInt,InOutBase.fReadInt
        MOVE.L  #ReadLCard,InOutBase.fReadLCard
        MOVE.L  #ReadLInt,InOutBase.fReadLInt
        MOVE.L  #ReadNum,InOutBase.fReadNum
        MOVE.L  #ReadLNum,InOutBase.fReadLNum
        MOVE.L  #ReadReal,InOutBase.fReadReal
        MOVE.L  #Write,InOutBase.fWrite
        MOVE.L  #WriteLn,InOutBase.fWriteLn
        MOVE.L  #WritePg,InOutBase.fWritePg
        MOVE.L  #GotoXY,InOutBase.fGotoXY
        MOVE.L  #WriteString,InOutBase.fWriteString
        MOVE.L  #CloseInput,InOutBase.fCloseInput
        MOVE.L  #CloseOutput,InOutBase.fCloseOutput
    END
  END initDriver;
  (*$L=*)

BEGIN
  ASSEMBLER
        ; goxy[0]:=33C; (* ESC *)
        ; goxy[1]:='Y';
        MOVE    #$2759,goxy
  END;
END InOutFile.

(* $00000D4D$00001F82$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$00002564$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFF68A69$FFFC497A$FFFC497A$FFFC497A$FFFC497A$FFFC497A€$0000011DT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000173$0000030E$0000003A$0000307B$000022C1$000025B5$000022B5$000031C3$000025B1$0000011E$FFEACF24$00000159$00001309$00000144$0000256C$00000033¨€*)
