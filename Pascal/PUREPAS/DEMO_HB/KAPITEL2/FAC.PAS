program faculty;

var
  n : integer;

  function fac( n : integer ) : integer;
  begin
    if n <= 0 then
      fac := 1
    else
      fac := fac( n - 1 ) * n;
  end;

begin
  write( 'n = ' );
  readln( n );
  writeln( 'fac(', n, ') = ', fac( n ));
  readln;
end.
