{$M 5,1,1,10}
{Show a magic square, where the sum of each
coloum, row or diagonal is the same
}

Program magic(input,output);

const
  maxsize = 19;

type
  sqrtype = array[1..maxsize,1..maxsize] of integer;

var
  sqare: sqrtype;
  Size,row,col: integer;

procedure makesqare(var sq:sqrtype;limit:integer);
var
  num,r,c: integer;
begin
  for r:=1 to limit do for c:=1 to limit do sq[r,c]:=0;
  r:=(limit+1) div 2;
  c:=limit;
  for num:=1 to sqr(limit) do begin
    if sq[r,c]<>0 then begin
      r:=r-1; if r<1 then r:=r+limit;
      c:=c-2; if c<1 then c:=c+limit
    end;
    sq[r,c]:=num;
    gotoxy(r*4,2+c); write(num:4);
    r:=r+1; if r>limit then r:=r-limit;
    c:=c+1; if c>limit then c:=c-limit
  end
end;

begin
  Size:=5;
  repeat
    if ((Size>2) and (Size<maxsize+1)) and (odd(Size)) then begin
      ClrScr;
      makesqare(sqare,Size);
      writeln;
    end else begin
       write('Only odd numbers in the range 3..',maxsize:0)
    end;
    gotoxy(1,22);
    ClrEol;
    write('Enter size (0 to exit) : '); read(Size);
    Writeln;
  until Size=0;
end.
