program sine;   { Calculate sine list }

var
  F:file;      
  n:byte;
  s:integer;
  
const
  pi = 3.1415;
  
begin
  assign(F,'e:\bad_mood\sine.dat');
  rewrite(F);
  for n:=0 to 255 do
   begin
     s:=round( sin(n*pi/128)*$7FFF );
     writeln(s);
     blockwrite(F,s,2); 
   end;
  close(F);
end.      