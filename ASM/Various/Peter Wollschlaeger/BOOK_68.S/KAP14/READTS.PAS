{$S10}
program readts;

type buffer = packed array[1..257] of integer;
     bufptr = ^buffer;

var bp: bufptr;

function RDTS(Drive,Track,Sector: integer): bufptr;
  EXTERNAL;

begin
  bp:= RDTS(0,3,1);
  write(bp^[1]);
end.

