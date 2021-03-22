(*$c-*)
module Dirtest;

from inout import OpenOutput, writeln, WriteString, readstring, write, read,
        CloseOutput, writeint;
from directory import dirquery, direntry, fileattr, fileattrset;
import strings;
from system import val;
var ch:char;
    res:INTEGER;
    level:CARDINAL;
    b: BOOLEAN;


PROCEDURE showentry (path:ARRAY OF CHAR; e:direntry):BOOLEAN;
  var res:integer; i:CARDINAL; p:ARRAY [0..142] of char; b:BOOLEAN; c:char;
  begin
    with e do
      writestring (name);
      IF subdirAttr IN attr THEN
        write ('\')
      end;
      writeln;
    end;
    return true
  end showentry;

VAR p: ARRAY [0..127] of char;

begin
  level:=0;
  dirquery ('*.*',
  FileAttrSet{
    archiveattr
  },showentry,res);
  if res<0 then
    writeint (res,0); writeln;
  else
    writestring ('OK...');
  end;
  read(ch)
end dirtest.
