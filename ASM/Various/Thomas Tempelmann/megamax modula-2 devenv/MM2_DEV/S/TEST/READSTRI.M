(*$C-*)
module readstri;(*$E mos *)
from console import write, WriteString, writeln, read, readline,
  busyread,keypressed;
var ch: char; s: array [0..69] of char;
begin
    WriteLn;
    write ('?');
    readline (s);
    WriteLn;
    WriteString (s);
    WriteLn;
    WriteString ('CR? ');
    repeat
      busyread (ch)
    until ch = chr(13);
    WriteString ('ende...');
    write ('.');
    WriteLn;
    read(ch);
end readstri.
