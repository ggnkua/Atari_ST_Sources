Program Dirdemo;

Uses Dos;

{ Filename: DirDemo.pas       }
{ Coder   : Jacob V. Pedersen }
{ Coded   : 4-8-1990          }
{ Purpose : Example           }

{ Gives a listing of the current directory. }

{ Exercise:

    Make code to calculate the total size of the directory, and
    the total number of files in the directory.                  }

CONST
        DisplayAttr     = TRUE;         { Show file attributes ? }
        DisplayTime     = TRUE;         { --------- time stamp ? }
        DisplayDate     = TRUE;         { --------- date stamp ? }
VAR
        DosData         : SearchRec;    { Information from DOS }
        DirName         : DirStr;       { Current directory }
        Dt              : DateTime;     { Holds the date and time }
        PauseParam      : Boolean;      { Pause after each screen? }


Function Spaces( Number : Byte ) : String;
Var S : String;
Begin
  FillChar(S[1],Number,' ');
  S[0] := Chr(Number);
  Spaces := S;
End; { Spaces }


{ Make a filename presentable. }
Function LookGood ( FileName : String ) : String;
Var
        PuncPos : Byte;
Begin
  PuncPos := Pos('.',FileName);
  If (PuncPos > 1) then
    Insert(Spaces(9-PuncPos),FileName,PuncPos);
  LookGood := FileName + Spaces(12-Length(FileName));
End; { LookGood }

  
{ Pad a string with nulls, until it has a length that equals Lng. }
Function AddZero ( Number : Integer; Lng : Byte ) : String;
Var
  WorkRes : String;
Begin
  Str(Number,WorkRes);
  While Length(WorkRes)<Lng do Insert('0',WorkRes,1);
  AddZero := WorkRes;
End; { AddZero }


{ Traverse the directory. Display the file information. }
Procedure ShowDir( DirName : DirStr );
Var
        FileCounter : Integer;
        Ch : Char;
Begin
  FileCounter := 0;
  FindFirst( DirName+'*.*', AnyFile, DosData );
  While (DosError = 0) DO
    Begin
      If (FileCounter = 24) AND (PauseParam) then
        Begin
          Write('Press SPACEBAR');
          Repeat until ' '=ReadKey;
          DelLine;
          FileCounter := 0;
        End;

      With DosData DO
        Begin
          Inc(FileCounter);
          Write(LookGood(Name));
          If (Attr and Directory > 0) then
            Write('<DIR>' :10)
          ELSE
            Write(Size:10);
          If (DisplayAttr) then
            Begin
              Write('   ');
              If (Attr And ReadOnly > 0) then
                Write('r') else Write('-');
              If (Attr And Hidden > 0) then
                Write('h') else Write('-');
              If (Attr And SysFile > 0) then
                Write('s') else Write('-');
              If (Attr And VolumeID > 0) then
                Write('v') else Write('-');
              If (Attr And Directory > 0) then
                Write('d') else Write('-');
              If (Attr And Archive > 0) then
                Write('a') else Write('-');
            End; { displayattr }
          UnpackTime(Time,Dt);
          With Dt DO
            Begin
              If (DisplayDate) then
                Write(Day:6, '-',AddZero(Month,2),'/',Year);
              If (DisplayTime) then
                Write(Hour:6, '.',AddZero(Min,2));
            End; { with dt do }
          Writeln;
        End; { with dosdata do }
      FindNext(DosData);
    End; { while doserror = 0 }
End; { ShowDir }

BEGIN { main }
  PauseParam := (ParamStr(1) = '/p') OR (ParamStr(1) = '/P');
  DirName := FExpand(''); { Get current directory. }
  ShowDir(DirName);
END.
