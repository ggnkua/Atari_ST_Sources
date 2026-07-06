MODULE AnyCase;
  FROM Storage    IMPORT ALLOCATE, DEALLOCATE;
  FROM InOut      IMPORT WriteLn, WriteString;
  FROM Options    IMPORT FileNameAndOptions, GetOption,
                         Termination;
  FROM FileSystem IMPORT Close, Response, File, Lookup,
                         WriteChar, Rename, ReadChar;
  CONST
    maxidlength=80;
    maxfilenamelength=12;

  TYPE
    NodePtr=POINTER TO Node;
    ListPtr=POINTER TO ListNode;
    Node=RECORD
           List : ListPtr;
           Len : CARDINAL;
           left, right : NodePtr;
         END;
    ListNode=RECORD
               ch : ARRAY [0..1] OF CHAR;
               next : ListPtr
             END;
    idtype= ARRAY [0..maxidlength-1] OF CHAR;
    leg =(LessThan,Equal,GreaterThan);
    filename = ARRAY [0..maxfilenamelength-1] OF CHAR;

  VAR
    Root, where : NodePtr;
    j,k,c,i,d : CARDINAL;
    Nput,Output : File;
    term : Termination;
    NputName, OutputName : ARRAY [0..maxfilenamelength-1]
                                 OF CHAR;
    OptString : ARRAY [0..1] OF CHAR;
    OverWrite : BOOLEAN;
    id : idtype;
    ch : CHAR;
    List : ListPtr;
    F : File;

  PROCEDURE RelativeSize (id : idtype; anode : NodePtr;
                          VAR RelSize : leg);
  VAR
    cell : ListPtr;
    a,b : CHAR;
    c,d : CARDINAL;
  BEGIN
    d:=0;
    cell:=anode^.List;
    FOR c:=0 TO anode^.Len + 1 DO
      a:=CAP(cell^.ch[d]);
      b:=CAP(id[c]);
      IF a=b THEN
        (* keep looking *)
        IF d=1 THEN
          d:=0;
          cell:=cell^.nextŠ        ELSE d:=1;
        END;
      ELSIF a>b THEN
          RelSize:=LessThan;
          RETURN
      ELSE
        RelSize:=GreaterThan;
        RETURN
      END;
    END;
    RelSize:=Equal;
  END RelativeSize;

  PROCEDURE addit(id : idtype; VAR anode : NodePtr);
  VAR
    RelSize : leg;
    PROCEDURE addstring(List : ListPtr; VAR Len : CARDINAL;
                        id : idtype);
    VAR
      d,c : CARDINAL;
    BEGIN (* addstring *)
      c:=0; d:=0;
      WHILE (c<maxidlength) & (id[c]#" ") DO
        List^.ch[d]:=id[c];
        INC(c);
        IF d=0 THEN
          d:=1
        ELSE
          d:=0;
          NEW(List^.next);
          List:=List^.next;
          List^.next:=NIL;
        END;
      END;
      List^.ch[d]:=" ";
      IF c>maxidlength-1
      THEN Len:=maxidlength-1
      ELSE Len:=c-1
      END;
    END addstring;

  BEGIN  (* addit *)
    IF anode=NIL THEN
      (* not in tree insert it *)
      NEW(anode);
      WITH anode^ DO
        left:=NIL;
        right:=NIL;
        NEW(List);
        addstring(List,Len,id);
      END;
    ELSE
      RelativeSize(id,anode,RelSize);
      IF RelSize=LessThan THEN
        addit(id,anode^.left)
      ELSIF RelSize=GreaterThan THEN
        addit(id,anode^.right)
      (* ELSE id is already in the spelling list
         simply return *)
      ENDŠ    END;
  END addit;

  PROCEDURE InTree(id : idtype; VAR anode : NodePtr):
            BOOLEAN;
  (* SIDE EFFECT is to set anode to point to place in tree
     id is located *)
  VAR
    RelSize : leg;
  BEGIN  (*InTree *)
  LOOP
    IF anode=NIL THEN
      (* not in tree *)
      RETURN(FALSE)
    ELSE
      RelativeSize(id,anode,RelSize);
      IF RelSize=LessThan THEN
        (* create side effect *)
        anode:=anode^.left;
      ELSIF RelSize=GreaterThan THEN
         (* create side effect *)
         anode:=anode^.right
      ELSE
        (* its in the tree *)
        RETURN(TRUE);
      END
    END
  END;
  END InTree;

  PROCEDURE delit(id : idtype; VAR anode : NodePtr);
  VAR
    qnode : NodePtr;
    mark, markhold : ListPtr;
    RelSize : leg;
    PROCEDURE del (VAR anode : NodePtr);
    BEGIN  (* del *)
      IF anode^.right#NIL THEN
        del(anode^.right)
      ELSE
        qnode^.Len:=anode^.Len;
        qnode^.List:=anode^.List;
        qnode:=anode;
        anode:=anode^.left;
      END
    END del;
  BEGIN  (* delit *)
    IF anode=NIL THEN
      WriteString("Can't delete ");
      WriteString(id);
      WriteString(" not in tree");
      WriteLn;
    ELSE
      RelativeSize(id,anode,RelSize);
      IF RelSize=LessThan THEN
        delit(id,anode^.left)
      ELSIF RelSize=GreaterThan THENŠ        delit(id,anode^.right)
      ELSE
        qnode:=anode;
        IF qnode^.right=NIL THEN
          anode:=qnode^.left
        ELSIF qnode^.left=NIL THEN
          anode:=qnode^.right
        ELSE del(qnode^.left);
          (* dispose of qnode *)
          mark:=qnode^.List;
          WHILE mark#NIL DO
            markhold:=mark;
            mark:=mark^.next;
            DISPOSE(markhold)
          END;
         DISPOSE(qnode)
        END
      END
    END
  END delit;


PROCEDURE copy;
BEGIN (* copy *)
  WriteChar(Output,ch); ReadChar(Nput,ch);
END copy;

PROCEDURE FinishComment;
BEGIN
  REPEAT
    REPEAT
      copy;
      IF ch="(" THEN
        copy;
        IF ch="*" THEN
          FinishComment
        END;
      END;
    UNTIL ch="*";
  copy
  UNTIL ch= ")";
  copy
END FinishComment;

PROCEDURE WriteResponse(res : Response);
BEGIN
  CASE F.res OF
      done:WriteString("done");|
      notdone:WriteString("notdone");|
      notsupported:WriteString("notsupported");|
      callerror:WriteString("callerror");|
      unknownmedium:WriteString("unknownmedium");|
      unknownfile:WriteString("unknownfile");|
      paramerror:WriteString("paramerror");|
      toomanyfiles:WriteString("toomanyfiles");|
      eom:WriteString("eom");|Š      eom:WriteString("eom");|
      deviceoff:WriteString("deviceoff");|
      softparityerror:WriteString("softparityerror");|
      softprotected:WriteString("softprotected");|
      softerror:WriteString("softerror");|
      hardparityerror:WriteString("hardparityerror");|
      hardprotected:WriteString("hardprotected");|
      timeout:WriteString("timeout");|
      harderror:WriteString("harderror");
  END;
END WriteResponse;

PROCEDURE GetId( Nput : File; Adding, printing : BOOLEAN;
                 VAR ch : CHAR);
VAR
  j,k : CARDINAL;
BEGIN
  IF (CAP(ch) >= "A") & (CAP(ch)<="Z") THEN
    k:=0;
    REPEAT
      id[k]:=ch;
      k:=k+1;
      ReadChar(Nput,ch);
    UNTIL ( ((ch<"0") OR (ch>"9")) &
            ((CAP(ch)<"A") OR (CAP(ch) > "Z")) )
          OR (k=maxidlength);
    IF k<maxidlength THEN id[k]:=" " END;
    IF printing THEN
      FOR j:=0 TO k-1 DO WriteChar(Output,id[j]) END
    END;
    IF Adding THEN addit(id,Root); ELSE delit(id,Root) END;
  END;
END GetId;

PROCEDURE ProcessFile(Nput : File; Adding : BOOLEAN);
VAR
  ch : CHAR;
BEGIN
  ReadChar(Nput,ch);
    IF Nput.res=done THEN
      REPEAT
      GetId(Nput,Adding,FALSE,ch);
      ReadChar(Nput,ch);
      UNTIL Nput.eof;
    END;
END ProcessFile;

PROCEDURE ProcessFName(Adding : BOOLEAN);
VAR
  FName : filename;
  Immediate : BOOLEAN;


  PROCEDURE GetFilename;
  VAR
    c,d : CARDINAL;Š
    PROCEDURE FileNameCh(ch : CHAR) : BOOLEAN;
    BEGIN
      RETURN
        ( ( (CAP(ch)>="A") & (CAP(ch)<="Z") )
          OR ( (ch>="0") & (ch<="9") )
          OR (ch="$") OR (ch="#")
          OR (ch="&") OR (ch="@@") OR (ch="!") OR (ch="%")
          OR (ch="(") OR (ch=")") OR (ch="-") OR (ch="{")
          OR (ch="}") OR (ch="'") OR (ch="`") OR (ch="_") )
    END FileNameCh;

  BEGIN (* GetFilename *)
    REPEAT
      copy;
    UNTIL NOT (   (ch =" ")
               OR (ch=CHR(30)) );
    Immediate:=ch="!";
    IF Immediate THEN
      copy;
      GetId(Nput,Adding,TRUE,ch);
    ELSE
      FOR c:=0 TO maxfilenamelength-1 DO FName[c]:=" " END;
      c:=0;d:=0;
      WHILE  (c<8) & (FileNameCh(ch)) DO
        FName[c]:=ch;
        copy;
        INC(c);
      END;
      (* check for extension *)
      IF ch="." THEN
        FName[c]:=ch;
        INC(c);
        copy;
        WHILE (d<3)&(FileNameCh(ch)) DO
          FName[d+c]:=ch;
          copy;
          INC(d);
        END;
      END;
    END;
  END GetFilename;

BEGIN (* ProcessFName *)
LOOP
  GetFilename;
  IF NOT(Immediate) THEN
    Lookup(F,FName,FALSE);
    IF F.res=done THEN
      ProcessFile(F,Adding);
      Close(F);
      IF F.res#done THEN
        WriteString("Error closing File ");
        WriteString(FName);
        WriteString(" status ");
        WriteResponse(F.res);
        WriteLn;
      END;
    ELSEŠ      WriteString("Keyword file ");WriteString(FName);
      WriteString(" not processed status=");
      WriteResponse(F.res);
      WriteLn
    END
  END;
  IF ch#"," THEN
    WHILE ch="*" DO
      copy;
      IF ch=")" THEN copy; EXIT END;
    END;
    FinishComment;
    EXIT
  END;
END;
END ProcessFName;

BEGIN  (* AnyCase *)
Root:=NIL;
(* load default spelling list from file MODULA2.KWD *)
Lookup(Nput,"MODULA2.KWD",FALSE);
IF Nput.res=done THEN
  (* gather identifiers and load into table *)
  ProcessFile(Nput,TRUE);
  Close(Nput);
ELSE
  WriteString("Default keyword file MODULA2.KWD not found");
  WriteString("status="); WriteResponse(Nput.res); WriteLn
END;
(* get file name for input file *)
i:=0;
WHILE i<maxfilenamelength DO NputName[i]:=" "; INC(i) END;
WriteString("Input file[/O] >>");
FileNameAndOptions(".mod",NputName,term,TRUE);
WriteLn;
GetOption(OptString,c);
OverWrite:= (c<>0) & (CAP(OptString[0])="O");
Lookup(Nput,NputName,FALSE);
IF NOT (Nput.res=done) THEN
  WriteString("Input file ");
  WriteString(NputName);
  WriteString(" not found");
  WriteString(" status="); WriteResponse(Nput.res);
  WriteLn;
  WriteString("Program Terminated"); WriteLn;
  HALT;
END;
(* open output file formed from input filename
   with extension of .TMP *)
(* the following code takes advantage of the fact that
   NputName has already been acepted as a legitimatly
   constructed file name by the OS If this weren't the case
   extra checks would be requied *)
i:=0;
WHILE (i<maxfilenamelength) & (NputName[i]#".")DO
  INC(i)
END;
IF i=maxfilenamelength THEN
  (* there was no extension. add extension *)Š  i:=0;
  REPEAT
    INC(i)
  UNTIL NputName[i]=" ";
  (* put new extension on *)
  FOR j:=0 TO i-1 DO OutputName[j]:=NputName[j] END;
  OutputName[i]:=".";
ELSE
  (* there was an extension put new one on *)
  FOR j:=0 TO i DO OutputName[j]:=NputName[j] END;
END;
OutputName[i+1]:="T";
OutputName[i+2]:="M";
OutputName[i+3]:="P";
FOR j:=i+4 TO maxfilenamelength-1 DO
  OutputName[j]:=" "
END;
Lookup(Output,OutputName,TRUE);
IF NOT (Output.res=done) THEN
  WriteString("Error opening temporary work File");
  WriteString(OutputName);
  WriteString(" status="); WriteResponse(Output.res);
  WriteLn;
  WriteString("Program Terminated");
  WriteLn;
  HALT;
END;
ReadChar(Nput,ch);
  IF Nput.res=done THEN
    REPEAT
    IF (CAP(ch) >= "A") & (CAP(ch)<="Z") THEN
      k:=0;
      REPEAT
        id[k]:=ch;
        k:=k+1;
        ReadChar(Nput,ch);
        (* do not copy to output until see if its in the
           "spelling table"  *)
      UNTIL (((ch<"0") OR (ch>"9")) & ((CAP(ch)<"A")
            OR (CAP(ch) > "Z"))) OR (k=maxidlength);
      IF k<maxidlength THEN id[k]:=" " END;
      (* look for identifier in spelling list"*)
      where:=Root;
      IF InTree(id,where) THEN
        (* put spelling from tree to output *)
        d:=0;
        List:=where^.List;
        FOR i:=0 TO where^.Len DO
          WriteChar(Output,List^.ch[d]);
          IF d=1 THEN
            d:=0;
            List:=List^.next
          ELSE d:=1
          END
        END
      ELSE
        (* not in tree send to output as it came in *)
        FOR i:=0 TO k-1 DO
          WriteChar(Output,id[i])Š        END
      END;
      copy
    ELSIF (ch>="0") & (ch<="9") THEN
      REPEAT
        copy
      UNTIL ((ch<"0") OR (ch>"9"))
    ELSIF ch="(" THEN
      copy;
      IF ch="*" THEN (* comment *)
        copy;
        IF ch="$" THEN (* compiler directive *)
          copy;
          (* check for KW+ or KW- *)
          IF CAP(ch)="K" THEN
            copy;
            IF CAP(ch)="W" THEN
              copy;
              IF ch="+" THEN
                ProcessFName(TRUE);
              ELSIF ch="-" THEN
                ProcessFName(FALSE);
              ELSE
                FinishComment
              END
            ELSE
              FinishComment
            END;
          ELSE
            FinishComment
          END;
        ELSE
          FinishComment
        END
      END
    ELSIF ch="'" THEN
      REPEAT
        copy
      UNTIL ch="'";
      copy
    ELSIF ch='"' THEN
      REPEAT
        copy
      UNTIL ch='"';
      copy
    ELSE
      copy
    END
  UNTIL Nput.eof
END;
Close(Nput);
Close(Output);
(* we purposefully avoid the use of true TEMPORARY files as
   implemented by this implementation of Modula-2 for the
   PC in order to make the program easier to port to other
   implementations which do not have true temporary files *)
(* check to see if overwriting of input is desired *)
IF OverWrite THEN
  (* Delete old file *)
  Lookup(Nput,NputName,FALSE);
  Rename(Nput,"");
  Close(Nput);
  (* Rename xxx.TMP to NputName *)
  Lookup(Output,OutputName,FALSE);
  Rename (Output,NputName);
  Close (Output);
END
END AnyCase.
