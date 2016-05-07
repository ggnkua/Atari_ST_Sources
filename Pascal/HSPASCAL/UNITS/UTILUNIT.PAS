{$D+}
UNIT UtilUnit;

{ Filename: UtilUnit.pas      }
{ Coder   : Jacob V. Pedersen }
{ Coded   : 06-02-1991        }
{ Purpose : Example           }

{ This unit contains some routines that might come in handy. }

{ Changes in version 1.1:    

        For an example of how to use the new Inline Assembler,
        take a look at the HZ200 function.

        The Exist function shows how to use Assign as in Turbo Pascal.
}
        
INTERFACE

Uses DOS;

Const
        Version = 1.1;
Var
        StrIn   : Text;   { Read }
        StrOut  : Text;   { Write }
        StrData : String; { IO buffer for StrIn and StrOut }

Function Int2Str(Num : Integer) : String;
Function Exist(Filename : PathStr) : Boolean;
Procedure WaitToGo(KeyVal : Byte);
Function NoSpaces(S : String) : String;
Function UpperStr(S : String) : String;
Procedure ClearStrInOut;
Function HZ200 : LongInt;

IMPLEMENTATION

Function HZ200 : LongInt; ASSEMBLER;
ASM
        CLR.L   -(SP)           { Enter SuperVisor mode }
        MOVE.W  #$20,-(SP)      
        TRAP    #1
        MOVE.L  $4BA,@result    { Get long-word containing HZ200 counter }
        MOVE.L  D0,2(SP)        { Exit SuperVisor mode }
        TRAP    #1
        ADDQ.W  #6,SP           { Cleanup stack }                     
END;

Function Exist(Filename : PathStr) : Boolean;
Var
        Dummy : File;
        IOres : Integer;
Begin
  Assign(Dummy,FileName);
  {$I-} 
  Reset(Dummy); 
  {$I+}
  IOres := IOresult;
  If (IOres = 0) then
    Close(Dummy);
  Exist := IOres = 0;
End;

Function Int2Str(Num : Integer) : String;
Var
        Res : String;
Begin
  Str(Num, Res); Int2Str := Res;
End;

Procedure WaitToGo(KeyVal : Byte);
Begin
  Repeat Until (ReadKey = Chr(KeyVal));
End;

Function NoSpaces(S : String) : String;
Begin
  While (Pos(#32,S) > 0) Do
    Delete(S,Pos(#32,S),1);
  NoSpaces := S;
End;

Function UpperStr(S : String) : String;
Var
     X : Byte;
Begin
  For X := 1 To Length(S) Do
    S[X] := UpCase(S[X]);
  UpperStr := S;
End;

Procedure ClearStrInOut;
Begin
  While Not(Eof(StrIn)) Do
    ReadLn(StrIn);
End;

Procedure StrInOutHandler(Var F : TextRec);
Var
        Tmp : String;
Begin
  With F Do
    Begin
      If fInpFlag then
        Begin { read }
          Move(StrData[1],fBufPtr^[0],Length(StrData));
          fBufEnd := Length(StrData);
          StrData := '';
        End
      Else
        Begin { write }
          Move(fBufPtr^[0],Tmp[1],fBufPos);
          Tmp[0] := Chr(fBufPos);
          Insert(Tmp,StrData,Length(StrData)+1);
        End;
      fBufPos := 0;
    End;
End;

Var     
        DevBuf : TDevBuf;
BEGIN
  Device('StrInOut',@StrInOutHandler,DevBuf);
  Assign(StrIn,'StrInOut');
  Reset(StrIn);
  Assign(StrOut,'StrInOut');
  Rewrite(StrOut);
END.