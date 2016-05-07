{ LibMaker merges named UNI files together into one big LIB file.
  The file PASCAL.LIB is the only one known by the commandline compiler.
  The integrated compiler can use a LIB with any name put into the dialog.

  Compile this program to LIBMAKER.PRG.
}

{ 1990 Christen Fihl }

{$I-,M 10,1,1,20}
Program LibMaker;

Uses DOS;

var
  F_Lib,F_Tpu: File;
  fhead: record
          name: packed array[1..4] of char;
          count: integer
        end;

procedure AddUNItoLIB(S: String);
var
  s2: string;
  m,n: integer;
  B: packed array[1..4096] of byte;
  head: record
          name: string[8];
          len: longint;
          DateTime: longint
        end;
begin
  s2:=s;
  while pos(':',s)+pos('\',s)>0 do delete(s,1,1);
  if pos('.',s2)=0 then s2:=s2+'.Uni';
  writeln('From file: ',s2,'. unit= ',s);
  reset(F_Tpu,s2); if IOResult<>0 then begin
    writeln('cannot open file');
    halt
  end;
  inc(fhead.count);
  while pos('.',s)>0 do delete(s,length(s),1);
  with head do begin
    name:=s; len:=fileSize(F_Tpu); DateTime:=-1;
    blockwrite(F_Lib,name,10+4+4);
    repeat
      blockread(F_Tpu,B,SizeOf(B),n);
      blockwrite(F_Lib,B,n,m);
    until m=0;
  end;
  close(F_Tpu);
end;

procedure CloseLIB;
begin
  seek(F_Lib,4); blockwrite(F_Lib,fhead.count,2);
  close(F_Lib);
  if IOResult=0 then writeln('Ok') else writeln('Bad');
end;

{ Main program }
var
  Index: Integer;
  s: string;
begin
  if ParamCount<2 then begin
    writeln('LibMaker: Merges .UNI files together into one .LIB file');
    writeln('LibMaker syntax:');
    writeln('LibMaker file1 file2 ... fileN NewLib');
    halt(99);
  end;
  s:=ParamStr(ParamCount); if pos('.',s)=0 then s:=s+'.Lib';

  Erase(S); rewrite(F_Lib,s); if IOResult<>0 then begin
    writeln('cannot create file: ',s);
    halt
  end;
  writeln('To file: ',s);
  with fhead do begin
    name:='Uni1'; count:=0;
    blockwrite(F_Lib,name,4+2);    {2 = space for Count}
  end;
  for Index:=1 to ParamCount-1 do  {Add all UNITs listed on command line}
    AddUNItoLIB(ParamStr(Index));
  CloseLIB
end.
