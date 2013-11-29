program sign; { signed <-> unsigned converter }

uses 
  crt,dos;

var
  FO,FN:file;
  b:array[0..255] of byte;
  w,n:integer;
  
begin
  if paramcount<2 then
   begin
     writeln('Usage: sign filename.raw newfile.raw');
     halt
   end;
  assign(FO,paramstr(1));
  reset(FO);
  assign(FN,paramstr(2));
  rewrite(FN);
  while not eof(FO) do
   begin
        blockread(FO,b,256,w);
        write(b[0],' ');
        for n:=0 to w-1 do 
         begin
           b[n]:=b[n] xor $80;
         end;
        write(b[0]);
        blockwrite(FN,b,w);      
        writeln('.');
   end;
  
  close(FO);
  close(FN);
end.