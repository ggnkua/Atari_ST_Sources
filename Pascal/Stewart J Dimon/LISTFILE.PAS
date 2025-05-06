Program ListTheSource;

{******************************************************************************
**                                                                           **
**                              Program ListTheSource                        **
**                                                                           **
**      Purpose : To provide a means to list PASCAL programs from the ATARI  **
**                ST to any printer.  This is a SIMPLE program that will be  **
**                followed in the near future by a FANCIER (formats/etc)     **
**                program.                                                   **
**                                                                           **
**                Adapted from a Turbo Pascal Program by : Stewart Dimon     **
**                Copyright 1986, Stewart J Dimon                            **
**                Donated to the PUBLIC DOMAIN 02/03/1986                    **
**                                                                           **
******************************************************************************}

Const


    PageWidth    =  80;
    PrintLength  =  55;
    PathLength   =  65;
    FormFeed     =  12;
    VertTab      =   3;

Type

    WString      =  String[80];
    FileName     =  String[PathLength];

Var

    CurRow       :  Integer;
    MainFileName :  FileName;
    MainFile     :  Text;
    LST          :  Text;
    Search1,
    Search2,
    Search3,
    Search4      :  String[5];


Procedure IO_Check(B : Boolean); External;

Function IO_Result : Integer; External;

{$I DistrMsg}

Procedure Initialize;

Begin
    IO_Check(False);
    Repeat
        ReWrite(LST,'LST:');
        If (IO_Result <> 0) Then
            Begin
                Close(LST);
                WriteLn('Unable to access printer ... press a key when ready');
                Repeat
                Until KeyPress;
            End;
    Until (IO_Result = 0);
    IO_Check(True);
    CurRow  := 0;
    Search1 := ConCat('{$', 'I');
    Search2 := ConCat('{$', 'i');
    Search3 := ConCat('(*$','I');
    Search4 := ConCat('(*$','i');
End; {Procedure Initialize}

Function Open(Var FP : Text; Name : FileName) : Boolean;

Begin
    IO_Check(False);
    If (Pos('.',Name) = 0) Then
        Name := ConCat(Name,'.Pas');
    Reset(FP, Name);
    If ((EOF(FP)) OR (IO_Result <> 0)) Then
        Begin
            Open := False;
            Close(FP);
        End
    Else
        Open := True;
    IO_Check(True);
End; {Function Open}

Procedure OpenMain;

Begin
    Write('Enter filename : ');
    ReadLn(MainFileName);
    If Not Open(MainFile, MainFileName) Then
        Begin
            WriteLn('File ',MainFileName,' NOT Found.');
            Halt;
        End;
End; {Procedure OpenMain}

Procedure VerticalTab;

Var

    I : Integer;

Begin
    For I := 1 to VertTab Do
        WriteLn(LST);
End; {Procedure VerticalTab}

Procedure ProcessLine(PrintStr : WString);

Begin
    CurRow := Succ(CurRow);
    If Length(PrintStr) > PageWidth Then
        CurRow := Succ(CurRow);
    If CurRow > PrintLength Then
        Begin
            Write(LST,Chr(FormFeed));
            VerticalTab;
            CurRow := 1;
        End;
    WriteLn(LST,PrintStr);
End; {Procedure ProcessLine}

Procedure ProcessFile;

Var

    LineBuffer : WString;

    Function IncludeIn(Var CurStr : WString) : Boolean;

    Var

        ChkChar : Char;
        Column  : Integer;

    Begin
        ChkChar := '-';
        Column := Pos(Search1, CurStr);
        If Column <> 0 Then
            ChkChar := CurStr[Column + 3]
        Else
            Begin
                Column := Pos(Search3, CurStr);
                If Column <> 0 Then
                    ChkChar := CurStr[Column + 4]
                Else
                    Begin
                        Column := Pos(Search2, CurStr);
                        If Column <> 0 Then
                            ChkChar := CurStr[Column + 3]
                        Else
                            Begin
                                Column := Pos(Search4, CurStr);
                                If Column <> 0 Then
                                    ChkChar := CurStr[Column + 4];
                            End; {Else 3}
                    End; {Else 2}
            End; {Else 1}
        If ChkChar in ['+','-'] Then
            IncludeIn := False
        Else
            IncludeIn := True;
    End; {Procedure IncludeIn}

    Procedure ProcessIncludeFile(Var IncStr : WString);

    Var

        NameStart,
        NameEnd     : Integer;
        IncludeFile : Text;
        IncludeName : FileName;

    Procedure Parse(    IncStr  : WString;
                    VAR IncName : FileName);

    Begin
        NameStart := Pos('$I',IncStr) + 2;
        While IncStr[NameStart] = ' ' Do
            NameStart := Succ(NameStart);
        NameEnd := NameStart;
        While (Not(IncStr[NameEnd] in [' ', '}', '*'])) AND
             ((NameEnd - NameStart) <= PathLength) Do
            NameEnd := Succ(NameEnd);
        NameEnd := Pred(NameEnd);
        IncName := Copy(IncStr, NameStart, (NameEnd - NameStart + 1));
    End; {Function Parse}

    Begin {Procedure ProcessIncludeFile}
        Parse(IncStr, IncludeName);
        If Not Open(IncludeFile, IncludeName) Then
            Begin
                LineBuffer := ConCat('Error in Include File ', IncludeName);
                ProcessLine(LineBuffer);
            End
        Else
            Begin
                While Not(EOF(IncludeFile)) Do
                    Begin
                        ReadLn(IncludeFile, LineBuffer);
                        ProcessLine(LineBuffer);
                    End;
                Close(IncludeFile);
            End;
    End; {Procedure ProcessIncludeFile}

Begin {Procedure ProcessFile}
    VerticalTab;
    WriteLn('Printing . . . ');
    While Not(EOF(MainFile)) Do
        Begin
            ReadLn(MainFile,LineBuffer);
            If IncludeIn(LineBuffer) Then
                ProcessIncludeFile(LineBuffer)
            Else
                ProcessLine(LineBuffer);
        End;
    Close(MainFile);
    Write(LST, Chr(FormFeed));
    Close(LST);
End; {Procedure ProcessFile}

Procedure Mainline;

Begin
    DistrMsg;
    Initialize;
    OpenMain;
    ProcessFile;
End;

Begin
    MainLine;
End. {Program ListTheSource}
