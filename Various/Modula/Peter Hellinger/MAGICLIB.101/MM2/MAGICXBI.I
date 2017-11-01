(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  XBIOS  Extended Basic Input Output System     Interface for Modula-2

                Implementation fÅr Megamax-Modula-2

########################################################################
  V1.01  18.06.90  Peter Hellinger      Bugs gefixed
  V1.00  (c) by    Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicXBIOS;

(*------------------------------*)
(*    MM2-COMPILERSWITCHES      *)      
(*                              *)
(*$R-   Range-Checks            *)
(*$S-   Stack-Check             *)
(*------------------------------*)


FROM SYSTEM IMPORT ADDRESS, ADR, WORD, BYTE, ASSEMBLER;


VAR     a:      ADDRESS;
        c:      CARDINAL;
        i:      INTEGER;

PROCEDURE Initmouse (type: INTEGER; VAR param: PARAM; vec: PROC);
BEGIN
 ASSEMBLER
  MOVE.L  vec(A6), -(SP)
  MOVE.L  param(A6), -(SP)
  MOVE.W  type(A6), -(SP)
  MOVE.W  #0, -(SP);
  TRAP    #14
  LEA     12(SP), SP
 END;
END Initmouse;


PROCEDURE Physbase (): ADDRESS;
BEGIN
 ASSEMBLER
  MOVE.W  #2, -(SP);
  TRAP    #14
  ADDQ.L  #2, SP
  MOVE.L  D0, a
 END;
 RETURN a;
END Physbase;


PROCEDURE Logbase (): ADDRESS;
BEGIN
 ASSEMBLER
  MOVE.W  #3, -(SP);
  TRAP    #14
  ADDQ.L  #2, SP
  MOVE.L  D0, a
 END;
 RETURN a;
END Logbase;


PROCEDURE Getrez (): INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  #4, -(SP);
  TRAP    #14
  ADDQ.L  #2, SP
  MOVE.W  D0, i
 END;
 RETURN i;
END Getrez;


PROCEDURE Setscreen (log, phys: ADDRESS; rez: INTEGER);
BEGIN
 ASSEMBLER
  MOVE.W  rez(A6), -(SP)
  MOVE.L  phys(A6), -(SP)
  MOVE.L  log(A6), -(SP)
  MOVE.W  #5, -(SP)
  TRAP    #14
  LEA     $C(SP), SP
 END;
END Setscreen;


PROCEDURE Setpalette (VAR palette: ARRAY OF WORD);
BEGIN
 ASSEMBLER
  MOVE.L  palette(A6), -(SP)
  MOVE.W  #6, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
 END;
END Setpalette;


PROCEDURE Setcolor (colNum, color: CARDINAL): CARDINAL;
VAR c: CARDINAL;
BEGIN
 ASSEMBLER
  MOVE.W  color(A6), -(SP)
  MOVE.W  colNum(A6), -(SP)
  MOVE.W  #7, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
  MOVE.W  D0, c(A6)
 END;
 RETURN c;
END Setcolor;


PROCEDURE Floprd (buf: ADDRESS; drv, sec, trck, side, count: INTEGER): INTEGER;
VAR i: INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  count(A6), -(SP)
  MOVE.W  side(A6), -(SP)
  MOVE.W  trck(A6), -(SP)
  MOVE.W  sec(A6), -(SP)
  MOVE.W  drv(A6), -(SP)
  MOVE.L  #0, -(SP)
  MOVE.L  buf(A6), -(SP)
  MOVE.W  #8, -(SP)
  TRAP    #14
  LEA     $14(SP), SP
  MOVE.W  D0, i(A6)
 END;
 RETURN i;
END Floprd;


PROCEDURE Flopwr (buf: ADDRESS; drv, sec, trck, side, count: INTEGER): INTEGER;
VAR i: INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  count(A6), -(SP)
  MOVE.W  side(A6), -(SP)
  MOVE.W  trck(A6), -(SP)
  MOVE.W  sec(A6), -(SP)
  MOVE.W  drv(A6), -(SP)
  MOVE.L  #0, -(SP)
  MOVE.L  buf(A6), -(SP)
  MOVE.W  #9, -(SP)
  TRAP    #14
  LEA     $14(SP), SP
  MOVE.W  D0, i(A6)
 END;
 RETURN i;
END Flopwr;


PROCEDURE Flopfmt (buf: ADDRESS; drv, spt, trck, side, il, virgin: INTEGER): INTEGER;
VAR i: INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  virgin(A6), -(SP)
  MOVE.L  #$087654321, -(SP)
  MOVE.W  il(A6), -(SP)
  MOVE.W  side(A6), -(SP)
  MOVE.W  trck(A6), -(SP)
  MOVE.W  spt(A6), -(SP)
  MOVE.W  drv(A6), -(SP)
  MOVE.L  #0, -(SP)
  MOVE.L  buf(A6), -(SP)
  MOVE.W  #10, -(SP)
  TRAP    #14
  LEA     $1A(SP), SP
  MOVE.W  D0, i(A6)
 END;
 RETURN i;
END Flopfmt;


PROCEDURE Midiws (VAR string: ARRAY OF BYTE; len: CARDINAL);
BEGIN
 ASSEMBLER
  MOVE.L  string(A6), -(SP)
  MOVE.W  len(A6), -(SP)
  MOVE.W  #12, -(SP)
  TRAP    #14
  ADDQ.L  #8, SP
 END;
END Midiws;


PROCEDURE Mfpint (intNo: CARDINAL; vector: PROC);
BEGIN
 ASSEMBLER
  MOVE.L  vector(A6), -(SP)
  MOVE.W  intNo(A6), -(SP)
  MOVE.W  #13, -(SP)
  TRAP    #14
  ADDQ.L  #8, SP
 END;
END Mfpint;


PROCEDURE Iorec (dev: INTEGER): PtrIOREC;
VAR a: ADDRESS;
BEGIN
 ASSEMBLER
  MOVE.W  dev(A6), -(SP)
  MOVE.W  #14, -(SP)
  TRAP    #14
  ADDQ.L  #4, SP
  MOVE.L  D0, a(A6)
 END;
 RETURN a;
END Iorec;


PROCEDURE Rsconf (speed: INTEGER; flavor: BITSET;  u, r, t, s: INTEGER): INTEGER;
VAR i: INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  s(A6), -(SP)
  MOVE.W  t(A6), -(SP)
  MOVE.W  r(A6), -(SP)
  MOVE.W  u(A6), -(SP)
  MOVE.W  flavor(A6), -(SP)
  MOVE.W  speed(A6), -(SP)
  MOVE.W  #15, -(SP)
  TRAP    #14
  LEA     $E(SP), SP
  MOVE.W  D0, i(A6)
 END;
 RETURN i;
END Rsconf;


PROCEDURE Keytbl (VAR unshift, shift, capslock: Keycode): PtrKEYTAB;
VAR a: ADDRESS;
BEGIN
 ASSEMBLER
  MOVE.L  capslock(A6), -(SP)
  MOVE.L  shift(A6), -(SP)
  MOVE.L  unshift(A6), -(SP)
  MOVE.W  #16, -(SP)
  TRAP    #14
  LEA     $E(SP), SP
  MOVE.L  D0, a(A6)
 END;
 RETURN a;
END Keytbl;


PROCEDURE Random(): LONGCARD;
VAR l: LONGCARD;
BEGIN
 ASSEMBLER
  MOVE.W  #17, -(SP)
  TRAP    #14
  ADDQ.L  #2, SP
  MOVE.L  D0, l(A6)
 END;
 RETURN l;
END Random;


PROCEDURE Protobt (buf: ADDRESS; num: LONGINT; typ, exec: INTEGER);
BEGIN
 ASSEMBLER
  MOVE.W  exec(A6), -(SP)
  MOVE.W  typ(A6), -(SP)
  MOVE.L  num(A6), -(SP)
  MOVE.L  buf(A6), -(SP)
  MOVE.W  #18, -(SP)
  TRAP    #14
  LEA     $E(SP), SP
 END;
END Protobt;


PROCEDURE Flopver (buf: ADDRESS; drv, sec, trck, side, count: INTEGER): INTEGER;
VAR i: INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  count(A6), -(SP)
  MOVE.W  side(A6), -(SP)
  MOVE.W  trck(A6), -(SP)
  MOVE.W  sec(A6), -(SP)
  MOVE.W  drv(A6), -(SP)
  MOVE.L  #0, -(SP)
  MOVE.L  buf(A6), -(SP)
  MOVE.W  #19, -(SP)
  TRAP    #14
  LEA     $E(SP), SP
  MOVE.W  D0, i(A6)
 END;
 RETURN i;
END Flopver;


PROCEDURE Scrdmp;
BEGIN
 ASSEMBLER
  MOVE.W  #20, -(SP)
  TRAP    #14
  ADDQ.L  #2, SP
 END;
END Scrdmp;


PROCEDURE Cursconf (function, operand: INTEGER): INTEGER;
VAR i: INTEGER;
BEGIN
 ASSEMBLER
  MOVE.W  operand(A6), -(SP)
  MOVE.W  function(A6), -(SP)
  MOVE.W  #21, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
  MOVE.W  D0, i(A6)
 END;
 RETURN i;
END Cursconf;


PROCEDURE Settime (datetime: LONGCARD);
BEGIN
 ASSEMBLER
  MOVE.W  datetime(A6), -(SP)
  MOVE.W  #22, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
 END;
END Settime;


PROCEDURE Gettime (): LONGCARD;
VAR l: LONGCARD;
BEGIN
 ASSEMBLER
  MOVE.W    #23, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
  MOVE.L  D0, l(A6)
 END; 
 RETURN l;
END Gettime;


PROCEDURE Bioskeys;
BEGIN
 ASSEMBLER
  MOVE.W  #24, -(SP)
  TRAP    #14
  ADDQ.L  #2, SP
 END;
END Bioskeys;


PROCEDURE Ikbdws (VAR str: ARRAY OF BYTE; len: CARDINAL);
BEGIN
 ASSEMBLER
  MOVE.W  str(A6), -(SP)
  MOVE.W  len(A6), -(SP)
  MOVE.W  #25, -(SP)
  TRAP    #14
  ADDQ.L  #8, SP
 END; 
END Ikbdws;


PROCEDURE Jdisint (intNo: CARDINAL);
BEGIN
 ASSEMBLER
  MOVE.W  intNo(A6), -(SP)
  MOVE.W  #26, -(SP)
  TRAP    #14
  ADDQ.L  #4, SP
 END;
END Jdisint;


PROCEDURE Jenabint (intNo: CARDINAL);
BEGIN
 ASSEMBLER
  MOVE.W  intNo(A6), -(SP)
  MOVE.W  #27, -(SP)
  TRAP    #14
  ADDQ.L  #4, SP
 END;
END Jenabint;


PROCEDURE Giaccess (regno: CARDINAL; data: BYTE): CARDINAL;
VAR c: CARDINAL;
BEGIN
 c:= ORD (data);
 ASSEMBLER
  MOVE.W  regno(A6), -(SP)
  MOVE.W  c(A6), -(SP)
  MOVE.W  #28, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
  MOVE.W  D0, c(A6)
 END;
 RETURN c;
END Giaccess;


PROCEDURE Offgibit (bitno: CARDINAL);
BEGIN
 ASSEMBLER
  MOVE.W  bitno(A6), -(SP)
  MOVE.W  #29, -(SP)
  TRAP    #14
  ADDQ.L  #4, SP
 END;
END Offgibit;


PROCEDURE Ongibit (bitno: CARDINAL);
BEGIN
 ASSEMBLER
  MOVE.W  bitno(A6), -(SP)
  MOVE.W  #30, -(SP)
  TRAP    #14
  ADDQ.L  #4, SP
 END;
END Ongibit;


PROCEDURE Xbtimer (timer, control, data: CARDINAL; vec: PROC);
BEGIN
 ASSEMBLER
  MOVE.L  vec(A6), -(SP)
  MOVE.W  data(A6), -(SP)
  MOVE.W  control(A6), -(SP)
  MOVE.W  timer(A6), -(SP)
  MOVE.W  #31, -(SP)
  TRAP    #14
  LEA     $C(SP), SP
 END;
END Xbtimer;


PROCEDURE Dosound (VAR data: ARRAY OF BYTE);
BEGIN
 ASSEMBLER
  MOVE.L  data(A6), -(SP)
  MOVE.W  #32, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
 END;
END Dosound;


PROCEDURE Setprt (config: BITSET): BITSET;
VAR b: BITSET;
BEGIN
 ASSEMBLER
  MOVE.W  config(A6), -(SP)
  MOVE.W  #33, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
  MOVE.W  D0, b(A6)
 END;
 RETURN b;
END Setprt;


PROCEDURE Kbdvbase(): PtrKBVECS;
VAR a: ADDRESS;
BEGIN
 ASSEMBLER
  MOVE.W  #34, -(SP)
  TRAP    #14
  ADDQ.L  #2, SP
  MOVE.L  D0, a(A6)
 END;
 RETURN a;
END Kbdvbase;


PROCEDURE Kbrate (initial, repeat: INTEGER): CARDINAL;
VAR c: CARDINAL;
BEGIN
 ASSEMBLER
  MOVE.W  repeat(A6), -(SP)
  MOVE.W  initial(A6), -(SP)
  MOVE.W  #35, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
  MOVE.W  D0, c(A6)
 END;
 RETURN c;
END Kbrate;


PROCEDURE Prtblk (block: PtrPBDEF);
BEGIN
 ASSEMBLER
  MOVE.L  block(A6), -(SP)
  MOVE.W  #36, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
 END;
END Prtblk;
 

PROCEDURE Vsync;
BEGIN
 ASSEMBLER
  MOVE.W  #37, -(SP)
  TRAP    #14
  ADDQ.L  #2, SP
 END;
END Vsync;


PROCEDURE Supexec (code: ADDRESS);
BEGIN
 ASSEMBLER
  MOVE.L  code(A6), -(SP)
  MOVE.W  #38, -(SP)
  TRAP    #14
  ADDQ.L  #6, SP
 END;
END Supexec;


PROCEDURE Puntaes;
BEGIN
 ASSEMBLER
  MOVE.W    #39, -(SP)
  TRAP    #14
  ADDQ.L  #2, SP
 END;
END Puntaes;


PROCEDURE Blitmode (flag: INTEGER): BITSET;
VAR b: BITSET;
BEGIN
 ASSEMBLER
  MOVE.W  flag(A6), -(SP)
  MOVE.W  #64, -(SP)
  TRAP    #14
  ADDQ.L  #4, SP
  MOVE.W  D0, b(A6)
 END;
 RETURN b;
END Blitmode;


END MagicXBIOS.

