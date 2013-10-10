MODULE KeyCodes; (*$E MOS *)
(*$C-*)

(*
 * "Quick-And-Dirty"-Programm zum Anzeigen der Tastenkodes
 *)

import tosio;
from keyboard import specialcode, cap;

IMPORT inout;
IMPORT keyboard;
IMPORT SYSTEM, SysUtil2, MOSGlobals, MOSSupport;


MODULE KbdCtrl;
(*$L-*)

FROM SYSTEM IMPORT ASSEMBLER;
FROM SYSTEM IMPORT ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;
FROM MOSSupport IMPORT ToSuper, ToUser;

EXPORT GetKey, Key, CtrlKey, CtrlSet;

TYPE    CtrlKey = ( rshift, lshift, control, alternate, capsLock );
        CtrlSet = SET OF CtrlKey;

        Key = RECORD
                ch  : CHAR;
                ctrl: CtrlSet;
                scan: CARDINAL;
              END;

VAR KbdRec: ADDRESS;

TYPE KbdRecT= RECORD
                buf:  ADDRESS;
                size: CARDINAL;
                head: CARDINAL;      (* hiernach steht die n„chste Taste an *)
                tail: CARDINAL;      (* hier hinter kommt n„chste Taste rein *)
              END;

PROCEDURE asn;
  BEGIN
    ASSEMBLER
        MOVE.B  D0,Key.ch(A2)
        SWAP    D0
        CLR     D1
        MOVE.B  D0,D1
        MOVE    D1,Key.scan(A2)
        LSR     #8,D0
        ANDI    #11111%,D0
        MOVE.B  D0,Key.ctrl(A2)
    END
  END asn;

PROCEDURE GetKey (VAR k: Key; VAR ok: BOOLEAN);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A1        ; ok
        MOVE.L  -(A3),A2        ; k
        MOVE.L  KbdRec,A0
        MOVE    KbdRecT.head(A0),D1
        CMP     KbdRecT.tail(A0),D1
        BEQ     n
        MOVE    #1,(A1)
        ADDQ    #4,D1
        CMP     KbdRecT.size(A0),D1
        BCS     o
        CLR     D1
     o: MOVE    D1,KbdRecT.head(A0)
        MOVE.L  KbdRecT.buf(A0),A1
        MOVE.L  0(A1,D1.W),D0
        JMP     asn
     n: CLR.L   (A2)
        CLR     (A1)
    END
  END GetKey;

PROCEDURE SetExtMode ( VAR lastMode: BOOLEAN );
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        JSR     ToSuper
        BSET    #3,$484
        SNE     D0
        ANDI    #1,D0
        MOVE.L  -(A3),A0
        MOVE    D0,(A0)
        JSR     ToUser
        ADDQ.L  #4,A7
    END
  END SetExtMode;

PROCEDURE CurrentMode (): BOOLEAN;
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        JSR     ToSuper
        BTST    #3,$484
        SNE     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
        JSR     ToUser
        ADDQ.L  #4,A7
    END
  END CurrentMode;

PROCEDURE SetMode ( extended: BOOLEAN );
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        JSR     ToSuper
        TST     -(A3)
        BNE     setit
        BCLR    #3,$484
        BRA     ret
  setit BSET    #3,$484
  ret:  JSR     ToUser
        ADDQ.L  #4,A7
    END
  END SetMode;

BEGIN
  ASSEMBLER
        ; I/O-Buffer f. Tastatur ermitteln
        MOVE    #1,-(A7)
        MOVE    #14,-(A7)
        TRAP    #14         ; iorec (kbd)
        ADDQ.L  #4,A7
        MOVE.L  D0,KbdRec
  END;
  SetMode (TRUE);
END KbdCtrl;
(*$L=*)

var i,o,n:CARDINAL;c:char;
 sk: specialcode; k,k2:key;

PROCEDURE show;
  begin
    inout.WriteString ('  ');
    if lshift in k.ctrl then inout.writestring ('LS') else inout.writestring ('  ') end;
    inout.Write(' ');
    if rshift in k.ctrl then inout.writestring ('RS') else inout.writestring ('  ') end;
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
END KeyCodes.
