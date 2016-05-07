{---------------------------------------------------------------------}
{                     HighSpeed Pascal Demo Program                   }
{                                                                     }
{              Copyright (C) 1990 by D-House I Aps, Denmark           }
{                                                                     }
{                     Programmed by Jacob V. Pedersen                 }
{                                                                     }
{                                                                     }
{ The program: Expands tabulator signs, and removes any unnessecary   }
{              spaces at the end of each line in the program. The     }
{              original file is renamed to nnnn.BAK before processed. }
{              Output is an nnnn.PAS file.                            }
{---------------------------------------------------------------------}
Program NoTabs;

Uses Dos,UtilUnit;

Const
        MaxLnLng = 127;
        TabSize  =   8;

                                           
Procedure Process(N : Byte);                
Var
        Data    : String[MaxLnLng];
        I,O     : Text;
        Dir     : DirStr;
        Name    : NameStr;
        Ext     : ExtStr;
        InName,
        OutName : PathStr;
        Line    : Integer;
           
Procedure Expand;
Const
        Spaces  = '                      ';
Var
        TabPos  : Byte;
        ToIns   : Byte;
Begin
  While Pos(#9,Data) > 0 Do
    Begin
      TabPos := Pos(#9,Data);
      ToIns  := Succ(TabSize)-(TabPos MOD TabSize);
      Delete(Data,TabPos,1);
      If ToIns < Succ(TabSize) then
        Insert(Copy(Spaces,1,ToIns),Data,TabPos)
      Else
        Insert(' ',Data,Tabpos);
    End;
  While Copy(Data,Length(Data),1) = #32 Do 
    Delete(Data,Length(Data),1);
End; { Expand }
                                                                
Begin { Process }
  FSplit(ParamStr(N),Dir,Name,Ext);
  InName := Dir+Name+'.BAK';
  OutName:= Dir+Name+'.PAS';
  
  If Exist(InName) then
    Writeln('Backup file "',InName,'" already exists. Cannot continiue.')
  Else
  If Not(Exist(OutName)) then
    Writeln('Cannot open input file: "',OutName,'"')
  Else
    Begin
      Rename(OutName,InName);     { From .PAS to .BAK }
      Reset(I,InName);            { Read from .BAK }
      Rewrite(O,OutName);         { Write to .PAS }
      Line := 0;
      While Not(Eof(I)) Do
        Begin
          ReadLn(I,Data);
          Expand;
          WriteLn(O,Data);
          Inc(Line);
          GotoXy(1,WhereY); Write(OutName,' (',Line,')');
          If (Length(Data) = MaxLnLng) then
            Writeln(#7,' ERROR: Long line found. Data may be lost!');
        End;
      Close(I);
      Close(O);
      Writeln;
      Writeln('Done.');
    End;
End; { Process }


Var
        X        : Byte;       
BEGIN
  Clrscr;
  Writeln('HighSpeed Pascal tab-sign expander.');
  Writeln;
  If ParamCount = 0 then
    Writeln('Please specify filename(s) on command line.')
  Else
    For X := 1 to ParamCount Do
      Process(X);
END.
