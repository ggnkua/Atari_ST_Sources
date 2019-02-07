Procedure Str(N:Integer; Var Num:String);
Var F: Integer;
    E: real;
Begin
  E:=0.0000001;
  F:=0;
  Num:='';
  if n<0 then begin n:=-n; num:='-' end;
  If (Trunc(n/10000+e)>0) then
    begin
      num:=concat(num,chr(48+Trunc(n/10000+E)));
      n:=n-10000*Trunc(n/10000+e); F:=1
    end;
  if (trunc(n/1000+e)>0) or (F=1) then
    begin
      Num:=Concat(Num,Chr(48+Trunc(N/1000+E)));
      n:=n-1000*trunc(n/1000+e); F:=1
    end;
  if (trunc(n/100+e)>0) or (F=1) then
    begin
      num:=concat(num,chr(48+trunc(n/100+E)));
      n:=n-100*Trunc(n/100+e); f:=1
    end;
  if (Trunc(n/10+e)>0) or (f=1) then
    begin
      num:=concat(num,chr(48+trunc(n/10+e)));
      n:=n-10*trunc(n/10+e); f:=1
    End;
  Num:=concat(num,chr(48+N))
End;

