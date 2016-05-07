{----------------------------------------------------------------------}
{                      HighSpeed Pascal Demo Program                   }
{                                                                      }
{              Copyright (C) 1990 by D-House I Aps, Denmark            }
{                                                                      }
{                     Programmed by Jacob V. Pedersen                  }
{                                                                      }
{                                                                      }
{ The program: Prints your Pascal programs (source-code). Any include  }
{              files are also loaded and printed. Remarks can be dis-  }
{              carded when printing.                                   }
{----------------------------------------------------------------------}
Program Print;

Uses Printer,Dos;

Const
        TopMargin       =    2;      { Top margin }
        PrintLines      =   59;      { Lines to print per page }
        BottomMargin    =   11;      { Bottom margin }
        PageLines       =   72;      { Adds up to total lines per page }
        MaxIncludeLevel =    7;      { 0 is the same as IncLoad=False }
        RemShow         =False;      { Show remarks? }
        LinShow         =False;      { Show line numbers? }
        IncLoad         = True;      { Load include files? }
Var
        LineNum         : Integer;   { Line counter. Total }
        PageCount       : Byte;      { Line counter. Page }
        IncludeLevel    : Byte;      { Include-file level }


{ Main procedure to process the primary file, as well as any }
{ found include files.                                       }
Procedure Process_File(Fil : PathStr; FirstFile : Boolean);
Var
        InFil      : Text;      { Input file }
        Ch         ,            { Current character }
        PrevCh     : Char;      { Previous character }
        Buffer     ,            { Buffer for output }
        Data       : String;    { Line read from file }
        LinePos    : Byte;      { Current position on line }
        StrExp     ,            { Currently in a strig expression? }
        IgnoreStr  ,            { Used in connection with StrExp }
        In_Remark  ,            { Currently in a remark? }
        FirstLine,              { First line in file? }
        NormChr    : Boolean;   { Is there a character on the line? }


{ Stuffs characters into the output stream }
Procedure OutPut(C : Char);
Begin
  If In_Remark and Not(RemShow) then Exit;
  Buffer := Buffer + C;
  If (C > #32) then
    NormChr := True;
End;


{ Print a line to the output file }
Procedure PrintLine;
Var
        X       : Byte;

{ Returns true if no characters are present in the output stream }
Function EmptyLine : Boolean;
Var X : Byte;
Begin
  For X := 1 to Length(Data) Do
    If Data[x] <> #32 then
      Begin
        EmptyLine := False;
        Exit;
      End;
  EmptyLine := True;
End;


{ Takes care of top and bottom margins }
Procedure MakeMargin(Lines : Byte);
Var
        X : Byte;
Begin
  For X := 1 to Lines Do
    WriteLn(Lst);
End;


Begin { PrintLine }
  If (NormChr or EmptyLine) and Not(FirstLine) then
    Begin
      If (PageCount = 0) then
        MakeMargin(TopMargin)
      Else
      If (PageCount = PrintLines) then
        Begin
          MakeMargin(BottomMargin);
          MakeMargin(TopMargin);
          PageCount := 0;
       End;           
      Inc(PageCount);
      If LinShow then
        Begin
          Inc(LineNum);
          Write(Lst,LineNum:5,',',IncludeLevel,': ');
        End;              
      Writeln(Lst,Buffer);
    End;
  Buffer := '';
End; { PrintLine }


{ Provides the next character in the input stream }
Procedure NextCh;
Begin
  PrevCh := Ch;
  If LinePos = Length(Data) then
    Begin
      LinePos := 0;
      PrintLine;
      ReadLn(InFil,Data);
      FirstLine := In_Remark and Not(RemShow);
      NormChr   := False;
      Ch        := #0;
    End
  Else
    Begin
      Inc(LinePos);
      Ch := Data[LinePos];
    End;
End; { NextCh }


{ Looks ahead in the input stream. Used to determine if a character }
{ is the start of a remark or a compiler directive                  }
Function LookAhead(Chars : Byte) : Char;
Begin
  If LinePos+Chars <= Length(Data) then
    LookAhead := Data[LinePos+Chars]
  Else
    LookAhead := #0;
End; { LookAhead }


{ Reads and processes any remarks found in the input stream }
Procedure Process_Remark;
Begin
  In_Remark := True;
  OutPut(Ch);
  Case Ch Of
    '{' : Repeat
            NextCh; OutPut(Ch);
          Until (Ch = '}');
    '(' : Repeat
            NextCh; OutPut(Ch);
          Until (PrevCh = '*') and (Ch = ')');
  End;
  In_Remark := False;
End; { Process_Remark }


{ Reads and processes compiler directives. If IncLoad is True, then }
{ include files are processed by calling Process_File recursively   }
Procedure Process_Directive;
Var
        OldPos  : Byte;
        Navn    : PathStr;
        Stop    : Char;
Begin
  If IncLoad then
    Begin
      OldPos := LinePos;
      If Ch = '{' then
        Stop := '}' Else Stop := '*';
      While PrevCh <> '$' Do
        NextCh;    
      If (UpCase(Ch) = 'I') then
        Begin
          NextCh;
          If (Ch = #32) then
            Begin
              Navn := '';
              Repeat
                NextCh;
                If (Ch <> #32) and (Ch <> Stop) then
                  Navn := Navn + Ch;
              Until (Ch = Stop);
              If Ch = '*' then
                NextCh;
              Process_File(Navn,False);
              Exit;
            End;
        End;
      LinePos := OldPos;
      OutPut(Data[LinePos]);
    End { IncLoad }
  Else
    OutPut(Ch);
End; { Process_Directive }


Begin { Process_File }
  If (IncludeLevel <= MaxIncludeLevel) Then     { Check include level }
    Begin
      If (Pos('.',Fil) = 0) then
        Fil := Fil + '.PAS';                   { Check file extension }
      Assign(InFil,Fil);
      {$I-}
      Reset(InFil);                            { Try to open the file }
      {$I+}
      If IOresult = 0 then            { File exists. Begin processing }
        Begin
          If FirstFile then            { If beginning of new printout }
            Begin
              LineNum      := 0;          { then reset some variables }
              PageCount    := 0;
              IncludeLevel := 0;
            End;

          Inc(IncludeLevel);
          FirstLine := True;
          In_Remark := False;
          StrExp    := False;
          IgnoreStr := False;
          Ch        := #0;
          Data      := '';
          LinePos   := 0;
          Repeat
            NextCh;
            If Not(In_Remark) and (PrevCh = '''') then
              Begin
                If (Ch = '''') then
                  IgnoreStr := True
                Else
                  Begin
                    If IgnoreStr then
                      IgnoreStr := False
                    Else
                      StrExp := Not(StrExp);
                  End;
              End;

            If StrExp then
              OutPut(Ch)
            Else
              Case Ch Of
                '{'  : If (LookAhead(1) = '$') then
                         Process_Directive
                       else
                         Process_Remark;
                '('  : If (LookAhead(1) = '*') then
                         Begin
                           If (LookAhead(2) = '$') then
                             Process_Directive
                           else
                             Process_Remark
                         End
                       Else
                         OutPut(Ch);
              Else
                OutPut(Ch);
              End; { Case }
          Until (Eof(InFil)) and (LinePos = Length(Data));
          PrintLine;
          Close(InFil);
          Dec(IncludeLevel);
          If (IncludeLevel = 0) then
            Page(Lst);
        End
      Else
        Writeln(#7,'Can''t process the file: ',Fil);
    End
  Else
    Writeln('Include-level ',IncludeLevel,' is too deep.');
End; { Process_File }


Var
        Name    : String;
        X       : Byte;
BEGIN { Main }
  ClrScr;
  Writeln('HighSpeed Pascal print program.');
  Writeln;
  If ParamCount = 0 then
    Begin
      Write('Enter name of program to print: ');
      Readln(Name);
      Process_File(Name,True);
    End
  Else
    For X := 1 to ParamCount Do
      Begin
        Writeln('Printing: ',ParamStr(x));
        Process_File(ParamStr(X),True);
      End;
END.
