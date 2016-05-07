{$M 10,10,10,10}
Program FileCopy;

Uses Dos,UtilUnit;

{ Filename: FileCopy.pas      }
{ Coder   : Jacob V. Pedersen }
{ Coded   : 26-11-1990        }
{ Purpose : Example           }

Const
        Bsize   = 8000;                 { Size of disk buffer }
Var
        Buffer  : Pointer;
        File1,                          { Source file. }
        File2   : File;                 { Destination file. }



{ Copies Source file to Dest file. }
Procedure CopyAFile( Source, Dest : String );
Var
        Reply     : Char;
        BytesRead,
        BytesWrit : Integer;
Begin
  GetMem(Buffer,BSize);

  WriteLn;
  If (Not(Exist(Source))) then
    Begin
      Writeln('Cannot access the SOURCE file. (',Source,').');
      HALT;
    End;

  If (Exist(Dest)) then
    Begin
      Write('DESTINATION file ',Dest,' already exist. Overwrite (Y/N): ');
      Repeat
        Reply := UpCase(ReadKey);
      Until (Reply IN ['Y','N']);
      WriteLn(Reply);
      If (Reply = 'N') then
        EXIT;
      Writeln;
      Erase(Dest);
    End; { to exists }

  Reset(File1, Source );
  Rewrite(File2, Dest );
  Write('Copying from ',Source,' to ',Dest,' ');
  Repeat
    BlockRead(File1, Buffer^, Bsize, BytesRead);
    BlockWrite(File2, Buffer^, BytesRead, BytesWrit);
  Until (BytesRead = 0) or (BytesRead <> BytesWrit);

  Close(File1);
  Close(File2);
  If (BytesRead = BytesWrit) then
    Writeln('Ok')
  Else Begin
    Writeln('Insufficient disk space.');
    Erase(Dest);
  End;

  FreeMem(Buffer,Bsize);
End; { CopyAFile }


BEGIN { main }
  If (ParamCount <> 2) then BEGIN
    Writeln('Please enter FROM and TO filename on the command line.');
    Writeln('Use the OPTIONS/Run dialog.');
    Writeln;
  END ELSE
    CopyAFile(ParamStr(1),ParamStr(2));
END.
