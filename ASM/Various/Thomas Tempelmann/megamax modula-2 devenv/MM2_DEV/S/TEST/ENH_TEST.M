(*$C-*)
(*$g+*)
module enh_test;
import terminal;
from inout import write, WriteString, writeln;
var ch: char;
begin
    write(27c);
    write('E');
    Write (27C); Write (5C); (* Ctrl-E: Enhanced Output *)
    WriteString('       asdhasdj al');
    WriteLn;
    WriteString('Copyright (C) 1986 JÅrgen MÅller');
    WriteLn; WriteLn;
    WriteString ('Compiling '); WriteLn;
    Write (27C); Write (6C); (* Ctrl-F: Enhanced Output off *)
    WriteString('das muû sichtbar sein!');
    terminal.read(ch)
end enh_test.
