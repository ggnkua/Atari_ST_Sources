
Procedure Long_Str(N:Long_Integer; Var Num:Str255);
var f: Integer;
    T: Long_integer;
    e: Real;
begin
  E:=0.0000001;
  F:=0;
  num:='';
  if n<0 then begin n:=-n; num:='-' end;
  if (Long_trunc(n/1000000+e)>0) or (f=1) then
    begin
      num:=concat(num,chr(48+Long_trunc(n/1000000+e)));
      n:=n-1000000*Long_trunc(n/1000000+e); F:=1
    End;
  if (Long_trunc(n/100000+e)>0) or (f=1) then
    begin
      num:=concat(num,chr(48+Long_trunc(n/100000+e)));
      n:=n-100000*Long_trunc(n/100000+E); F:=1
    End;
  if (Long_trunc(n/10000+e)>0) or (f=1) then
    Begin
      num:=concat(num,chr(48+Long_trunc(n/10000+e)));
      n:=n-10000*Long_trunc(n/10000+e); F:=1
    end;
  if (Long_trunc(n/1000+e)>0) or (F=1) then
    begin
      T:=Long_trunc(n/1000+E);
      num:=concat(num,chr(48+T));
      n:=n-1000*Long_trunc(n/1000+e); F:=1
    end;
  if (Long_trunc(n/100+e)>0) or (f=1) then
    begin
      num:=concat(num,chr(48+Long_trunc(n/100+e)));
      n:=n-100*Long_trunc(n/100+e); f:=1
    end;
  If (Long_trunc(n/10+E)>0) or (F=1) then
    Begin
      num:=concat(num,chr(48+Long_trunc(n/10+e)));
      n:=n-10*Long_trunc(n/10+e); F:=1
    end;
  num:=concat(num,Chr(48+N))
end;



