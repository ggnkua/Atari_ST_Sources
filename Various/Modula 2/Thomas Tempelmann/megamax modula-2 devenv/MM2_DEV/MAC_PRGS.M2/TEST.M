(*$c-,x+*)
module test;
import gemio;
from inout import read,write, writeln, writestring, keypressed;
FROM SYSTEM IMPORT ASSEMBLER;
from sysvars import _hz_200;
VAR hz200[_hz_200]: LONGCARD;
 l: LONGCARD;
 ch:char;
begin
 repeat
   l:= hz200+200;
   repeat
   until hz200>=l;
   write ('.');
   if keypressed() then read(ch); end;
 until ch=chr(27);
end test.
