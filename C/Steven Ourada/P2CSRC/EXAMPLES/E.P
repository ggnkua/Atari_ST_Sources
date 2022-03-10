
$partial_eval on$

program e(input,output);

const
   NDIGITS = 1007;
   NPRINT = 1000;

type
   digit = 0..255;
   digitarray = packed array [0..NDIGITS] of digit;

var
   s,x,t: ^digitarray;
   xs,ts: integer;
   i: integer;

procedure initinteger(var x:digitarray; n:integer);
var
   i: integer;
begin
   x[0] := n;
   for i := 1 to NDIGITS do x[i] := 0;
end;

procedure divide(var x:digitarray; xs,n:integer;
                 var y:digitarray; var ys:integer);
var
   i: integer;
   c: integer;
begin
   c := 0;
   for i := xs to NDIGITS do begin
      c := 10*c + x[i];
      y[i] := c div n;
      c := c mod n;
   end;
   ys := xs;
   while (ys <= NDIGITS) and (y[ys] = 0) do ys := ys+1;
end;

procedure add(var s,x:digitarray; xs:integer);
var
   i: integer;
   c: integer;
begin
   c := 0;
   for i := NDIGITS downto xs do begin
      c := s[i] + x[i] + c;
      if c >= 10 then begin
         s[i] := c - 10;
         c := 1;
      end else begin
         s[i] := c;
         c := 0;
      end;
   end;
   i := xs;
   while c <> 0 do begin
      i := i-1;
      c := s[i] + c;
      if c >= 10 then begin
         s[i] := c - 10;
         c := 1;
      end else begin
         s[i] := c;
         c := 0;
      end;
   end;
end;

procedure sub(var s,x:digitarray; xs:integer);
var
   i: integer;
   c: integer;
begin
   c := 0;
   for i := NDIGITS downto xs do begin
      c := s[i] - x[i] + c;
      if c < 0 then begin
         s[i] := c + 10;
         c := -1;
      end else begin
         s[i] := c;
         c := 0;
      end;
   end;
   i := xs;
   while c <> 0 do begin
      i := i-1;
      c := s[i] + c;
      if c < 0 then begin
         s[i] := c + 10;
         c := -1;
      end else begin
         s[i] := c;
         c := 0;
      end;
   end;
end;

begin
   new(s); new(x);
   initinteger(s^,0);
   initinteger(x^,1);
   xs := 0;
   add(s^,x^,xs);
   i := 0;
   repeat
      i := i+1;
      divide(x^,xs,i,x^,xs);
      add(s^,x^,xs);
      write(#M'Series: ',100*xs/(NDIGITS+1):5:2,'%');
   until xs > NDIGITS;
   writeln;
   writeln('':45,'e = ',s^[0]:1,'.');
   i := 0;
   for i := 1 to NPRINT do begin
      write(s^[i]:1);
      if i mod 1000 = 0 then writeln;
      if i mod 100 = 0 then writeln
      else if i mod 10 = 0 then write(' ');
   end;
   writeln;
   write('Final digits: ');
   for i := NPRINT+1 to NDIGITS do begin
      write(s^[i]:1);
   end;
   writeln;
end.
