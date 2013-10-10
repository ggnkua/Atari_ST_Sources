MODULE ShowKeys; (*$E MOS *)
(*$C-*)

(*
 * "Quick-And-Dirty"-Programm zum Anzeigen der Tastenkodes
 *)

import tosio;
from mosglobals import key, ctrlset, ctrlkey;
from keyboard import specialcode, cap;
from kbdctrl import getkey;

IMPORT inout;
IMPORT keyboard;

var i,o,n:CARDINAL;c:char;
 sk: specialcode; k,k2:key;

PROCEDURE show;
  begin
    inout.WriteString ('  ');
    if shift in k.ctrl then inout.write ('S') else inout.write (' ') end;
    inout.Write(' ');
    if control in k.ctrl then inout.write ('C') else inout.write (' ') end;
    inout.Write(' ');
    if alternate in k.ctrl then inout.write ('A') else inout.write (' ') end;
    inout.WriteString ('  ');
    inout.writehex (k.scan,3);
    inout.WriteString ('  ');
    inout.writehex (ord(k.ch),3);
    if k.ch>' ' then
      inout.WriteString ('  ');
      inout.write (k.ch)
    else
      inout.WriteString ('   ');
    end;
    inout.WriteString ('   ');
    if keyboard.isascii(k) then
      inout.writeString('A ');
    else
      inout.writeString('  ');
    end;
    if keyboard.isspecial(k) then
      inout.writeString('X ');
    else
      inout.writeString('  ');
    end;
    if keyboard.iscursor(k) then
      inout.writeString('C ');
    else
      inout.writeString('  ');
    end;
    if keyboard.isalternate(k) then
      inout.writeString('A ');
    else
      inout.writeString('  ');
    end;
    if keyboard.isfunction(k) then
      inout.writeString('F ');
    else
      inout.writeString('  ');
    end;
    if keyboard.onnumblock(k) then
      inout.writeString('NB ');
    else
      inout.writeString('   ');
    end;
    if keyboard.oncursorblock(k) then
      inout.writeString('CB ');
    else
      inout.writeString('   ');
    end;
    if keyboard.onalphablock(k) then
      inout.writeString('AB ');
    else
      inout.writeString('   ');
    end;
    if keyboard.onfunctionblock(k) then
      inout.writeString('FB ');
    else
      inout.writeString('   ');
    end;
    case keyboard.keycap(k) of
      unspecCap: inout.WriteString ('no  ') |
      escCap: inout.WriteString ('esc ') |
      tabCap: inout.WriteString ('tab ') |
      backspaceCap: inout.WriteString ('bs  ') |
      deleteCap: inout.WriteString ('del ') |
      returnCap: inout.WriteString ('ret ') |
      enterCap: inout.WriteString ('ent ') |
      helpCap: inout.WriteString ('help') |
      undoCap: inout.WriteString ('undo') |
      insertCap: inout.WriteString ('ins ') |
      clrHomeCap: inout.WriteString ('clr ') |
      upCap: inout.WriteString ('up  ') |
      downCap: inout.WriteString ('dwn ') |
      leftCap: inout.WriteString ('left') |
      rightCap: inout.WriteString ('rig ') |
      f1Cap: inout.WriteString ('f1  ') |
      f2Cap: inout.WriteString ('f2  ') |
      f3Cap: inout.WriteString ('f3  ') |
      f4Cap: inout.WriteString ('f4  ') |
      f5Cap: inout.WriteString ('f5  ') |
      f6Cap: inout.WriteString ('f6  ') |
      f7Cap: inout.WriteString ('f7  ') |
      f8Cap: inout.WriteString ('f8  ') |
      f9Cap: inout.WriteString ('f9  ') |
      f10Cap: inout.WriteString ('f10 ') |
    end;
    inout.writestring (' cap / ');
    sk:=keyboard.specialkey (k);
    case sk of
      unspecKey: inout.writestring ('...') |
      f1..f20: inout.writestring ('f');inout.writecard(ord(sk)+1-ord(f1),0) |
      esc: inout.writestring ('esc') |
      tab: inout.writestring ('tab') |
      backspace: inout.writestring ('bs') |
      delete: inout.writestring ('del') |
      insert: inout.writestring ('ins') |
      insLine: inout.writestring ('ins ln') |
      return: inout.writestring ('ret') |
      enter: inout.writestring ('ent') |
      up: inout.writestring ('up') |
      down: inout.writestring ('down') |
      left: inout.writestring ('left') |
      right: inout.writestring ('right') |
      pgUp: inout.writestring ('pgup') |
      pgDown: inout.writestring ('pgdown') |
      wdLeft: inout.writestring ('wdleft') |
      wdRight: inout.writestring ('wdright') |
      soln: inout.writestring ('soln') |
      eoln: inout.writestring ('eoln') |
      clr: inout.writestring ('clr') |
      home: inout.writestring ('home') |
      help: inout.writestring ('help') |
      undo: inout.writestring ('undo') |
      delLine: inout.writestring ('delln') |
      ctrlA..ctrlZ: inout.writestring ('ctrl');
        inout.write(chr(ord(sk)-ord(ctrla)+$41)) |
      alt1..alt0: inout.writestring ('alt');
        inout.writecard(ord(sk)+1-ord(alt1),0) |
      altA..altZ: inout.writestring ('alt');
        inout.write(chr(ord(sk)-ord(alta)+$41)) |
    end;
    inout.writeln;
  end show;

var ok: BOOLEAN;

begin
  inout.writeln;
  inout.WriteString ('Ende mit "%".');
  inout.writeln;
  loop
    repeat
      GetKey (k, ok);
    until ok;
    if k.ch='%' then exit end;
    show;       (* key-werte zeigen *)
  end;
END ShowKeys.
