(*$c-*)
module t;
(*
 * test fÅr ctrl-codes in text-files
 *)

from inout import WriteString,writeln,write,read, readstring,
        done, closeoutput, closeinput, redirectoutput, redirectinput;

const   esc=33C;
        ron='p';
        roff='q';

var ch:char;

begin
  redirectoutput ('g:\dat',false);
  WriteString ('normal');
  write (esc);
  write (ron);
  WriteString ('reverse');
  write (esc);
  write (roff);
  WriteString ('normal');
  writeln;
  closeoutput;
  redirectinput ('g:\dat');
  if done then
    loop
      read (ch);
      if not done then exit end;
      write (ch)
    end
  end;
  closeinput;
  read(ch)
end t.


(* $FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$000001D6$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688AÄ$0000006BT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$0000009F$FFF0688A$0000022D$00000259$00000278$000001F2$0000028F$00000285$0000009F$000001E2$000001BB$0000006B$0000027C$00000269$000001E2$000000AB∞ÄÄ*)
