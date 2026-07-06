(*$A+*) (*$F-*)
MODULE ArcShell;

FROM SYSTEM      IMPORT ADDRESS, ADR, CODE;
FROM Storage     IMPORT CreateHeap;

FROM GEMDOS      IMPORT GetDrv, Open, Close, GetPath, Term,
                        loadExecute, Exec;
FROM BIOS        IMPORT SetException, GetException;

FROM GEMAESbase  IMPORT MouseOff, MouseOn;
FROM AESGraphics IMPORT GrafMouse;
FROM AESForms    IMPORT FileSelectorInput;

FROM SYSCIO      IMPORT GoToXY,
                        Read,
                        Write, WriteString, WriteCard, WriteInt, WriteLn;

IMPORT GEMVDIbase, VDIControls, VDIAttribs,
       GEMAESbase, AESGraphics, AESForms, AESObjects,
       AESResources, AESApplications ;

CONST OFF       = FALSE;
      ON        = TRUE;

TYPE Object  = RECORD
       next  : CARDINAL;
       head  : CARDINAL;
       tail  : CARDINAL;
       type  : CARDINAL;
       flags : CARDINAL;
       state : CARDINAL;
       spec  : ADDRESS;
       obx   : CARDINAL;
       oby   : CARDINAL;
       width : CARDINAL;
       depth : CARDINAL;
     END;

     ObjectStates = (Selected, Crossed, Checked, Disabled, Outlined, Shadowed);

     Tree     = POINTER TO ARRAY [0..200] OF Object;

CONST MOPTIONS =  0 ;
      ADDBUTON =  2 ;
      EXTRACTB =  3 ;
      MOVEBUTN =  4 ;
      UPDATEBU =  5 ;
      FRESHENB =  6 ;
      DELETEBU =  7 ;
      VERBOSEB =  8 ;
      LISTBUTN =  9 ;
      COPYBUTN = 10 ;
      RUNBUTON = 11 ;
      TESTARCI = 12 ;
      CNVTONPM = 13 ;
      KEEPBACK = 17 ;
      SUPPCOMP = 18 ;
      SUPPWARN = 19 ;
      SUPPNOTE = 20 ;
      HOLDBUTN = 21 ;
      CRYPTBUT = 22 ;
      CANBUTON = 23 ;
      OKBUTTON = 24 ;

      ABOUTBOX =  1 ;
      ABOUTOKB =  4 ;
      ABOUTCAN =  5 ;

VAR VDIHandle  : INTEGER ;
    workIn     : GEMVDIbase.VDIWorkInType ;
    workOut    : GEMVDIbase.VDIWorkOutType ;
    WidthChar,
    HeightChar,
    WidthFont,
    HeightFont : INTEGER ;

  (* Window data *)

    Window     : INTEGER ; (* window handle *)
    WindX,
    WindY,
    WindWidth,
    WindHeight : INTEGER ; (* Total window *)

    Appl         : INTEGER;
    MainMenuTree : ADDRESS;
    MoptMenuTree : ADDRESS;
    SendMenuTree : ADDRESS;
    RecvMenuTree : ADDRESS;

    Colour     : BOOLEAN ;    (* Running on Colour ST system *)

  (* Work area available to graphics modules *)
    WorkX,
    WorkY,
    WorkWidth,
    WorkHeight : INTEGER ;

CONST CancelButton=     0;
      OKButton=         1;

TYPE  NameString=       ARRAY[0..64] OF CHAR;

VAR CurrentDrive:       CARDINAL;
    CurrentPath:        NameString;

    Path:               NameString;
    Name:               NameString;

    ArcProgramName:     NameString;

    DataPathName:       NameString;
    DataFileName:       NameString;
    DataName:           NameString;

    ArcPathName:        NameString;
    ArcFileName:        NameString;
    ArcName:            NameString;

    FileName:           NameString;
    ExButton:           INTEGER;
    Reply:              CHAR;
    AskForStdOutput:    BOOLEAN;
    MouseState:         BOOLEAN;

    MainOption:         ARRAY[0.. 0] OF CHAR;
    SecondaryOption:    ARRAY[0..10] OF CHAR;

    CommandLine:        ARRAY[0..127] OF CHAR;
    ProgramName:        ARRAY[0..127] OF CHAR;
    ProgramCommand:     ARRAY[0..127] OF CHAR;
    EnvironmentString:  ARRAY[0..127] OF CHAR;
    ExitCode:           INTEGER;

(*$P- Turn normal entry and exit code generation off *)
PROCEDURE DivideByZero;

BEGIN (* DivideByZero *)

  CODE(4E73H);          (*      rte                             *)

END DivideByZero;
(*$P= Turn normal entry and exit code generation on*)

PROCEDURE SetMouseState(SetMouse : BOOLEAN);

BEGIN (* SetMouseState *)

  CASE SetMouse OF
    ON  : CASE MouseState OF
            ON  : ;
          | OFF : GrafMouse(MouseOn, NIL);
          END;
  | OFF : CASE MouseState OF
            ON  : GrafMouse(MouseOff, NIL);
          | OFF : ;
          END;
  END;

  MouseState := SetMouse;

END SetMouseState;

PROCEDURE ClearScreen;

BEGIN (* ClearScreen *)

  Write(CHR(27)); Write('E');

END ClearScreen;

PROCEDURE CenterMessage(VAR Message : ARRAY OF CHAR);

VAR c, cmax:    CARDINAL;

BEGIN (* CenterMessage *)

  IF Message[0] = 0C
     THEN RETURN;
  END;

  c    := 0;
  cmax := HIGH(Message);

  WHILE (c <= cmax)       AND
        (Message[c] # 0C) DO
        INC(c);
  END;

  IF (c > cmax)        OR
     (Message[c] = 0C)
     THEN DEC(c);
  END;

  GoToXY((80 - c) DIV 2, 02);

  WriteString(Message);

END CenterMessage;

PROCEDURE Exit(ExitCode : INTEGER);

BEGIN (* Exit *)

   IF NOT Term(ExitCode)
      THEN HALT;
   END;

END Exit;

PROCEDURE MoveStr(VAR To, From : ARRAY OF CHAR);

VAR c, cmax,
    c1, c1max:          CARDINAL;

BEGIN (* MoveStr *)

  c := 0;
  cmax := HIGH(To);
  c1 := 0;
  c1max := HIGH(From);

  WHILE (c <= cmax)    AND
        (c1 <= c1max)  AND
        (From[c1] # 0C) DO
        To[c] := From[c1];
        INC(c);
        INC(c1);
  END;

  IF c <= cmax
     THEN To[c] := 0C;
  END;

END MoveStr;

PROCEDURE Append(VAR To:   ARRAY OF CHAR;
                 VAR Data: ARRAY OF CHAR);

VAR c, cmax,
    c1, c1max:          CARDINAL;

BEGIN (* Append *)

  c := 0;
  cmax := HIGH(To);

  WHILE (c <= cmax) AND
        (To[c] # 0C) DO
        INC(c);
  END;

  c1 := 0;
  c1max := HIGH(Data);

  WHILE (c <= cmax)    AND
        (c1 <= c1max)  AND
        (Data[c1] # 0C) DO
        To[c] := Data[c1];
        INC(c);
        INC(c1);
  END;

  IF c <= cmax
     THEN To[c] := 0C;
  END;

END Append;

PROCEDURE ConvertString(VAR To, From : ARRAY OF CHAR);

VAR c, cmax,
    c1, c1max:          CARDINAL;

BEGIN (* ConvertString *)

  c := 1;
  cmax := HIGH(To);

  c1 := 0;
  c1max := HIGH(From);

  WHILE (c  <= cmax )    AND
        (c1 <= c1max)    AND
        (From[c1] # 0C)   DO
        To[c] := From[c1];
        INC(c);
        INC(c1);
  END;

  IF c <= cmax
     THEN To[c] := 0C;
  END;

  To[0] := CHR(c-1);

END ConvertString;

(* ------------------------------------------------------------------- *)
(*                     Dialog Stuff lives here                         *)
(* ------------------------------------------------------------------- *)

PROCEDURE ObjectAddress(tree : INTEGER; obindex : INTEGER) : ADDRESS;

VAR res     : INTEGER;
    treeadr : Tree;
    ob : POINTER TO ADDRESS;

BEGIN

  AESResources.ResourceGetAddr(0,tree,treeadr);

  RETURN ADR(treeadr^[obindex]);

END ObjectAddress;

PROCEDURE GetObjectState(tree : INTEGER; obindex : INTEGER) : BITSET;

VAR res     : INTEGER;
    treeadr : Tree;

BEGIN

  AESResources.ResourceGetAddr(0,tree,treeadr);

  RETURN BITSET(treeadr^[obindex].state);

END GetObjectState;

PROCEDURE TestObjectState(Tree : INTEGER;
                          ObIndex : INTEGER;
                          Mask : ObjectStates) : BOOLEAN;

TYPE States = SET OF ObjectStates;

VAR Value : BITSET;

BEGIN

  Value := GetObjectState(Tree,ObIndex);

  RETURN (Mask IN States(Value));

END TestObjectState;

PROCEDURE SetObjectState(tree : INTEGER; obindex : INTEGER; state : BITSET);

VAR res     : INTEGER;
    treeadr : Tree;

BEGIN

  AESResources.ResourceGetAddr(0,tree,treeadr);

  treeadr^[obindex].state := INTEGER(state);

END SetObjectState;

PROCEDURE SelectObject(tree : INTEGER; obindex : INTEGER);

CONST Selected = 0 ;

VAR b:          BITSET;

BEGIN

  b := GetObjectState(tree,obindex);

  INCL(b, Selected);

  SetObjectState(tree,obindex,b);

END SelectObject;

PROCEDURE DeselectObject(tree : INTEGER; obindex : INTEGER);

CONST Selected = 0 ;

VAR b: BITSET;

BEGIN

  b := GetObjectState(tree,obindex);

  EXCL(b, Selected);

  SetObjectState(tree,obindex,b);

END DeselectObject;

PROCEDURE DoDialog(DialogIndex : INTEGER) : INTEGER ;

VAR dTree    : ADDRESS ;
    x,y,w,h  : INTEGER ;
    result   : INTEGER ;

BEGIN

  AESResources.ResourceGetAddr(GEMAESbase.RTree,DiogIndex,dTree))) ;

  AESForms.FormCenter(dTree,x,y,w,h) ;

  AESForms.FormDialogue(GEMAESbase.FormStart,0,0,0,0,x,y,w,h) ;
  AESForms.FormDialogue(GEMAESbase.FormGrow,0,0,0,0,x,y,w,h) ;

  AESObjects.ObjectDraw(dTree,0,10,x,y,w,h) ;

  SetMouseState(ON);
  result := AESForms.FormDo(dTree,0) ;
  SetMouseState(OFF);

  AESForms.FormDialogue(GEMAESbase.FormShrink,0,0,0,0,x,y,w,h) ;
  AESForms.FormDialogue(GEMAESbase.FormFinish,0,0,0,0,x,y,w,h) ;

  ClearScreen;

  RETURN result;

END DoDialog ;

PROCEDURE FormatFileName(VAR FileName,
                             Path,
                             Name : NameString);

VAR c:          CARDINAL;

BEGIN (* FormatFileName *)

  IF (Path[0] = 0C) AND
     (Name[0] = 0C)
           THEN FileName := '\*.*';
                RETURN;
     ELSIF Path[0] = 0C
           THEN FileName := Name;
                RETURN;
     ELSIF Name[0] = 0C
           THEN FileName := Path;
                RETURN;
  END;

  FileName := Path;

  c := 0;

  WHILE (c <= HIGH(FileName)) AND
        (FileName[c] # 0C)    DO
        INC(c);
  END;

  WHILE (c # 0)             AND
        (FileName[c] # '\') DO
        DEC(c);
  END;

  IF c = 0
     THEN FileName := Name;
          RETURN;
  END;

  FileName[c+1] := 0C;

  Append(FileName, Name);

END FormatFileName;

PROCEDURE DoMainOptions;

CONST RS        = 1EH;
      GS        = 1DH;
      FS        = 1CH;

BEGIN (* DoMainOptions *)

  IF       TestObjectState(MOPTIONS, ADDBUTON, Selected)
           THEN MainOption := 'A';
     ELSIF TestObjectState(MOPTIONS, EXTRACTB, Selected)
           THEN MainOption := 'X';
     ELSIF TestObjectState(MOPTIONS, MOVEBUTN, Selected)
           THEN MainOption := 'M';
     ELSIF TestObjectState(MOPTIONS, FRESHENB, Selected)
           THEN MainOption := 'F';
     ELSIF TestObjectState(MOPTIONS, UPDATEBU, Selected)
           THEN MainOption := 'U';
     ELSIF TestObjectState(MOPTIONS, DELETEBU, Selected)
           THEN MainOption := 'D';
     ELSIF TestObjectState(MOPTIONS, VERBOSEB, Selected)
           THEN MainOption := 'V';
     ELSIF TestObjectState(MOPTIONS, COPYBUTN, Selected)
           THEN MainOption := 'P';
     ELSIF TestObjectState(MOPTIONS, LISTBUTN, Selected)
           THEN MainOption := 'L';
     ELSIF TestObjectState(MOPTIONS, RUNBUTON, Selected)
           THEN MainOption := 'R';
     ELSIF TestObjectState(MOPTIONS, TESTARCI, Selected)
           THEN MainOption := 'T';
     ELSIF TestObjectState(MOPTIONS, CNVTONPM, Selected)
           THEN MainOption := 'C';
  END;

END DoMainOptions;

PROCEDURE DoSecondaryOptions;

CONST ESC=              1BH;

VAR   CryptData:        ARRAY[0..3] OF CHAR;

BEGIN (* DoSecondaryOptions *)

  SecondaryOption := '';

  IF TestObjectState(MOPTIONS, SUPPCOMP, Selected)
     THEN Append(SecondaryOption, 'S');
  END;

  IF TestObjectState(MOPTIONS, KEEPBACK, Selected)
     THEN Append(SecondaryOption, 'B');
  END;

  IF TestObjectState(MOPTIONS, SUPPWARN, Selected)
     THEN Append(SecondaryOption, 'W');
  END;

  IF TestObjectState(MOPTIONS, SUPPNOTE, Selected)
     THEN Append(SecondaryOption, 'N');
  END;

  IF TestObjectState(MOPTIONS, HOLDBUTN, Selected)
     THEN Append(SecondaryOption, 'H');
          AskForStdOutput := FALSE;
     ELSE AskForStdOutput := TRUE;
  END;

  IF TestObjectState(MOPTIONS, CRYPTBUT, Selected)
     THEN Append(SecondaryOption, 'G');
  END;

END DoSecondaryOptions;

PROCEDURE DoArc;

VAR EncryptionKey:      ARRAY[0..3] OF CHAR;
    c:                  CARDINAL;
    CReply:             CHAR;

    OldDivideByZero:    PROC;

BEGIN (* DoArc *)

  IF ArcPathName[0] # 0C
     THEN Path := ArcPathName;
          Name := ArcFileName;
     ELSE Path := CurrentPath;
          Append(Path, '\*.ARC');
          Name := '';
  END;

  ExButton := 0;

  CenterMessage('We are asking for the Archive File Name here');
  SetMouseState(ON);
  FileSelectorInput(ADR(Path), ADR(Name), ExButton);
  SetMouseState(OFF);

  ClearScreen;

  IF ExButton = CancelButton
     THEN Exit(-1);
  END;

  IF Name[0] = 0C
     THEN Exit(-2);
  END;

  ArcPathName := Path;
  ArcFileName := Name;

  FormatFileName(FileName, Path, Name);

  ArcName := FileName;

  IF (MainOption[0] = 'A') OR
     (MainOption[0] = 'M') OR
     (MainOption[0] = 'U') OR
     (MainOption[0] = 'F') OR
     (MainOption[0] = 'D') OR
     (MainOption[0] = 'X') OR
     (MainOption[0] = 'R') OR
     (MainOption[0] = 'P')
     THEN IF DataPathName[0] # 0C
             THEN Path := DataPathName;
             ELSE Path := CurrentPath;
                  Append(Path, '\*.*');
          END;
          Name := '';
          ExButton := 0;
          CenterMessage('We are asking for the Data File Name(s) here');
          SetMouseState(ON);
          FileSelectorInput(ADR(Path), ADR(Name), ExButton);
          SetMouseState(OFF);
          ClearScreen;
          IF ExButton = CancelButton
             THEN Exit(-1);
          END;
          DataPathName := Path;
          IF       MainOption[0] = 'R' THEN FileName := Name;
             ELSIF MainOption[0] = 'D' THEN IF Name[0] = 0C
                                               THEN FileName := Path;
                                               ELSE FileName := Name;
                                            END;
             ELSE  FormatFileName(FileName, Path, Name);
          END;
     ELSE FileName := '';
  END;

  DataName := FileName;

  CommandLine[0] := MainOption[0];
  CommandLine[1] := 0C;

  Append(CommandLine, SecondaryOption);

  ClearScreen;

  IF TestObjectState(MOPTIONS, CRYPTBUT, Selected)
     THEN WriteString('Enter the Encryption key ');
          c := 0;
          EncryptionKey := '    ';
          LOOP Read(CReply);
               IF CReply = CHR(0DH)
                  THEN EXIT;
               END;
               Write(CReply);
               EncryptionKey[c] := CReply;
               INC(c);
               IF c = 4
                  THEN EXIT;
               END;
          END;
          Append(CommandLine, EncryptionKey);
  END;

  Append(CommandLine, ' ');
  Append(CommandLine, ArcName);

  IF DataName[0] # 0C
     THEN Append(CommandLine, ' ');
          Append(CommandLine, DataName);
  END;

  IF AskForStdOutput
     THEN Name := '';
          ExButton := 0;
      CenterMessage('We are asking for the Standard Output File Name here');
          SetMouseState(ON);
          FileSelectorInput(ADR(Path), ADR(Name), ExButton);
          SetMouseState(OFF);
          ClearScreen;
          IF ExButton = CancelButton
             THEN Exit(-1);
          END;
          IF Name[0] # 0C
             THEN FormatFileName(FileName, Path, Name);
                  IF FileName[0] # 0C
                     THEN Append(CommandLine, ' >');
                          Append(CommandLine, FileName);
                  END;
          END;
  END;

  MoveStr(ProgramName, ArcProgramName);

  ConvertString(ProgramCommand, CommandLine);
  EnvironmentString := '';

  WriteString(ProgramName); Write(' ');
  WriteString(CommandLine); Write(' ');
  WriteString(EnvironmentString); WriteLn;

  OldDivideByZero := PROC(GetException(5));
  SetException(5, DivideByZero); (* It would seem that zero length files induce
                                    a divide by zero wich Modula-2 picks up so
                                    let's intercept with a dummy *)

  Exec(loadExecute,
       ProgramName, ProgramCommand, EnvironmentString, ExitCode);

  SetException(5, OldDivideByZero);

  CommandLine[0] := 0C;

  IF ExitCode # 0
     THEN WriteLn;
          WriteString('Arc ExitCode is');
          WriteInt(ExitCode,6);
          Read(CReply);
  END;

  ClearScreen;

END DoArc;

PROCEDURE DoProcess;

  PROCEDURE InitializeObjects;

  BEGIN (* InitializeObjects *)

    SelectObject(MOPTIONS, UPDATEBU);
(*
    SelectObject(MOPTIONS, SUPPWARN);
    SelectObject(MOPTIONS, SUPPNOTE);
*)
    SelectObject(MOPTIONS, HOLDBUTN);

  END InitializeObjects;

BEGIN (* DoProcess *)

  InitializeObjects;

  LOOP DeselectObject(MOPTIONS, OKBUTTON);
       DeselectObject(MOPTIONS, CANBUTON);

       CASE DoDialog(MOPTIONS) OF
         OKBUTTON : DoMainOptions;
                    DoSecondaryOptions;
                    DoArc;
       | CANBUTON : EXIT;
       | ELSE       ;
       END;
  END;

END DoProcess;

(* ------------------------------------------------------------------- *)

PROCEDURE InitResource() : BOOLEAN ;

CONST ResourceFileName = 'ARCSHELL.RSC';
      Alert            = "[3][ ArcShell.rsc not found ][OK]" ;

VAR str    : ARRAY [0..99] OF CHAR ;
    result : INTEGER ;
    i      : CARDINAL ;

BEGIN

  Appl := AESApplications.ApplInitialise() ;

  str := ResourceFileName ;

  AESResources.ResourceLoad(str) ;

  IF ( GEMAESbase.AESCallResult = 0 )
     THEN str := Alert ;
          result := AESForms.FormAlert(1,str) ;
          RETURN FALSE ;
  END ;

(* Get AES VDI handle *)

  VDIHandle := AESGraphics.GrafHandle(WidthChar,HeightChar,
                                      WidthFont,HeightFont);

(* Open VDI Virtual workstation *)

  FOR i := 0 TO 9 DO
      workIn[i] := 1 ;
  END ;

  workIn[10] := 2 ; (* Set RC *)

  VDIControls.OpenVirtualWorkstation(workIn,VDIHandle,workOut) ;

  Colour := workOut[39] (* number of colours *) > 2 ; 

  AESGraphics.GrafMouse(GEMAESbase.Arrow,NIL) ; (* put pointing mouse *)

  MouseState := ON;

  SetMouseState(OFF);

  DeselectObject(ABOUTBOX, ABOUTOKB);
  DeselectObject(ABOUTBOX, ABOUTCAN);

  IF DoDialog(ABOUTBOX) = ABOUTCAN
     THEN RETURN FALSE;
  END;

  ClearScreen;

  GetDrv(CurrentDrive);
  GetPath(CurrentPath, 0);

  Path[0] := CHR(ORD(CurrentDrive) + ORD('A'));
  Path[1] := ':';
  Path[2] := 0C;

  Append(Path, CurrentPath);

  CurrentPath := Path;

  ArcProgramName := CurrentPath;
  Append(ArcProgramName, 'ARC.TTP');

  Open(ArcProgramName, 0, result);

  IF result > 0
     THEN IF NOT Close(result)
             THEN Exit(-1);
          END;
     ELSE ExButton := 0;
          Path := CurrentPath;
          Append(Path, '\*.*');
          Name := '';
          CenterMessage('We are asking for the Archive Program Name here');
          SetMouseState(ON);
          FileSelectorInput(ADR(Path), ADR(Name), ExButton);
          SetMouseState(OFF);
          ClearScreen;
          IF ExButton = CancelButton
             THEN Exit(-1);
          END;
          IF Name[0] = 0C
             THEN Exit(-2);
          END;
          FormatFileName(ArcProgramName, Path, Name);
  END;

  ArcPathName  := '';
  DataPathName := '';

  RETURN TRUE ;

END InitResource ;

(* ------------------------------------------------------------------- *)

PROCEDURE Terminate ;

BEGIN

  AESResources.ResourceFree() ;

  VDIControls.CloseVirtualWorkstation(VDIHandle) ;  

  AESApplications.ApplExit ;

END Terminate ;

BEGIN (* ArcShell *)

  IF CreateHeap(32 * 1024, TRUE)
     THEN IF InitResource()
             THEN DoProcess;
          END;
          Terminate;
  END;

END ArcShell.
