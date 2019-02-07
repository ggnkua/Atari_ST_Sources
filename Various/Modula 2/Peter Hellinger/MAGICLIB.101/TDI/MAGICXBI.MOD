(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  XBIOS  Extended Basic Input Output System     Interface for Modula-2

                Implementation fÅr TDI-Modula-2/ST

########################################################################
  V1.0  (C) by Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicXBIOS;

(*------------------------------*)
(*    TDI-COMPILERSWITCHES      *)      
(*                              *)
(*$V-   Overflow-Checks         *)
(*$R-   Range-Checks            *)
(*$S-   Stack-Check             *)
(*$N-   NIL-Checks              *)
(*$T-   TDI-Compiler vor 3.01   *)
(*$Q+   Branch statt Jumps      *)
(*------------------------------*)


FROM SYSTEM IMPORT ADDRESS, SETREG, REGISTER, CODE, ADR, WORD, LONGWORD,
                   BYTE, PUSH;

CONST   TRAP14 =        04E4EH;
        D0 =            0;


PROCEDURE Initmouse (type: INTEGER; VAR param: PARAM; vec: PROC);
BEGIN
 PUSH (vec);
 PUSH (ADR(param));
 PUSH (type);
 PUSH (CARDINAL (0));
 CODE (TRAP14);
END Initmouse;


PROCEDURE Physbase (): ADDRESS;
BEGIN
 PUSH (CARDINAL (2));
 CODE (TRAP14);
 RETURN ADDRESS (REGISTER (D0));
END Physbase;


PROCEDURE Logbase (): ADDRESS;
BEGIN
 PUSH (CARDINAL (3));
 CODE (TRAP14);
 RETURN ADDRESS (REGISTER (D0));
END Logbase;


PROCEDURE Getrez (): INTEGER;
BEGIN
 PUSH (CARDINAL (4));
 CODE (TRAP14);
 RETURN INTEGER (REGISTER (D0));
END Getrez;


PROCEDURE Setscreen (log, phys: ADDRESS; rez: INTEGER);
BEGIN
 PUSH (rez);
 PUSH (phys);
 PUSH (log);
 PUSH (CARDINAL (5));
 CODE (TRAP14);
END Setscreen;


PROCEDURE Setpalette (VAR palette: ARRAY OF WORD);
BEGIN
 PUSH (ADR(palette));
 PUSH (CARDINAL (6));
 CODE (TRAP14);
END Setpalette;


PROCEDURE Setcolor (colNum, color: CARDINAL): CARDINAL;
BEGIN
 PUSH (color);
 PUSH (colNum);
 PUSH (CARDINAL (7));
 CODE (TRAP14);
 RETURN CARDINAL (REGISTER (D0));
END Setcolor;


PROCEDURE Floprd (buf: ADDRESS; drv, sec, trck, side, count: INTEGER): INTEGER;
BEGIN
 PUSH (count);
 PUSH (side);
 PUSH (trck);
 PUSH (sec);
 PUSH (drv);
 PUSH (CARDINAL(0));
 PUSH (buf);
 PUSH (CARDINAL (8));
 CODE (TRAP14);
 RETURN INTEGER (REGISTER (D0));
END Floprd;


PROCEDURE Flopwr (buf: ADDRESS; drv, sec, trck, side, count: INTEGER): INTEGER;
BEGIN
 PUSH (count);
 PUSH (side);
 PUSH (trck);
 PUSH (sec);
 PUSH (drv);
 PUSH (CARDINAL(0));
 PUSH (buf);
 PUSH (CARDINAL (9));
 CODE (TRAP14);
 RETURN INTEGER (REGISTER (D0));
END Flopwr;


PROCEDURE Flopfmt (buf: ADDRESS; drv, spt, trck, side, il, virgin: INTEGER): INTEGER;
BEGIN
 PUSH (virgin);
 PUSH (LONGCARD(087654321H));
 PUSH (il);
 PUSH (side);
 PUSH (trck);
 PUSH (spt);
 PUSH (drv);
 PUSH (CARDINAL(0));
 PUSH (buf);
 PUSH (CARDINAL (10));
 CODE (TRAP14);
 RETURN INTEGER (REGISTER (D0));
END Flopfmt;


PROCEDURE Midiws (VAR string: ARRAY OF BYTE; len: CARDINAL);
BEGIN
 PUSH (ADR(string));
 PUSH (len);
 PUSH (CARDINAL (12));
 CODE (TRAP14);
END Midiws;


PROCEDURE Mfpint (intNo: CARDINAL; vector: PROC);
BEGIN
 PUSH (vector);
 PUSH (intNo);
 PUSH (CARDINAL (13));
 CODE (TRAP14);
END Mfpint;


PROCEDURE Iorec (dev: INTEGER): PtrIOREC;
BEGIN
 PUSH (dev);
 PUSH (CARDINAL (14));
 CODE (TRAP14);
 RETURN ADDRESS (REGISTER (D0));
END Iorec;


PROCEDURE Rsconf (speed: INTEGER; flavor: BITSET;  u, r, t, s: INTEGER): INTEGER;
BEGIN
 PUSH (s);
 PUSH (t);
 PUSH (r);
 PUSH (u);
 PUSH (flavor);
 PUSH (speed);
 PUSH (CARDINAL (15));
 CODE (TRAP14);
 RETURN INTEGER (REGISTER(D0));
END Rsconf;


PROCEDURE Keytbl (VAR unshift, shift, capslock: Keycode): PtrKEYTAB;
BEGIN
 PUSH (capslock);
 PUSH (shift);
 PUSH (unshift);
 PUSH (CARDINAL (16));
 CODE (TRAP14);
 RETURN ADDRESS (REGISTER (D0));
END Keytbl;


PROCEDURE Random(): LONGCARD;
BEGIN
 PUSH (CARDINAL (17));
 CODE (TRAP14);
 RETURN LONGCARD (REGISTER (D0));
END Random;


PROCEDURE Protobt (buf: ADDRESS; num: LONGINT; typ, exec: INTEGER);
BEGIN
 PUSH (exec);
 PUSH (typ);
 PUSH (num);
 PUSH (buf);
 PUSH (CARDINAL (18));
 CODE (TRAP14);
END Protobt;


PROCEDURE Flopver (buf: ADDRESS; drv, sec, trck, side, count: INTEGER): INTEGER;
BEGIN
 PUSH (count);
 PUSH (side);
 PUSH (trck);
 PUSH (sec);
 PUSH (drv);
 PUSH (CARDINAL(0));
 PUSH (buf);
 PUSH (CARDINAL (19));
 CODE (TRAP14);
 RETURN INTEGER (REGISTER(D0));
END Flopver;


PROCEDURE Scrdmp;
BEGIN
 PUSH (CARDINAL (20));
 CODE (TRAP14);
END Scrdmp;


PROCEDURE Cursconf (function, operand: INTEGER): INTEGER;
BEGIN
 PUSH (operand);
 PUSH (function);
 PUSH (CARDINAL (21));
 CODE (TRAP14);
END Cursconf;


PROCEDURE Settime (datetime: LONGCARD);
BEGIN
 PUSH (datetime);
 PUSH (CARDINAL (22));
 CODE (TRAP14);
END Settime;


PROCEDURE Gettime (): LONGCARD;
BEGIN
 PUSH (CARDINAL (23));
 CODE (TRAP14);
 RETURN LONGCARD (REGISTER (D0));
END Gettime;


PROCEDURE Bioskeys;
BEGIN
 PUSH (CARDINAL (24));
 CODE (TRAP14);
END Bioskeys;


PROCEDURE Ikbdws (VAR str: ARRAY OF BYTE; len: CARDINAL);
BEGIN
 PUSH (ADR(str));
 PUSH (len);
 PUSH (CARDINAL (25));
 CODE (TRAP14);
END Ikbdws;


PROCEDURE Jdisint (intNo: CARDINAL);
BEGIN
 PUSH (intNo);
 PUSH (CARDINAL (26));
 CODE (TRAP14);
END Jdisint;


PROCEDURE Jenabint (intNo: CARDINAL);
BEGIN
 PUSH (intNo);
 PUSH (CARDINAL (27));
 CODE (TRAP14);
END Jenabint;


PROCEDURE Giaccess (regno: CARDINAL; data: BYTE): CARDINAL;
BEGIN
 PUSH (regno);
 PUSH (CARDINAL(data));
 PUSH (CARDINAL (28));
 CODE (TRAP14);
 RETURN CARDINAL (REGISTER (D0));
END Giaccess;


PROCEDURE Offgibit (bitno: CARDINAL);
BEGIN
 PUSH (bitno);
 PUSH (CARDINAL (29));
 CODE (TRAP14);
END Offgibit;


PROCEDURE Ongibit (bitno: CARDINAL);
BEGIN
 PUSH (bitno);
 PUSH (CARDINAL (30));
 CODE (TRAP14);
END Ongibit;


PROCEDURE Xbtimer (timer, control, data: CARDINAL; vec: PROC);
BEGIN
 PUSH (vec);
 PUSH (data);
 PUSH (control);
 PUSH (timer);
 PUSH (CARDINAL (31));
 CODE (TRAP14);
END Xbtimer;


PROCEDURE Dosound (VAR data: ARRAY OF BYTE);
BEGIN
 PUSH (ADR(data));
 PUSH (CARDINAL (32));
 CODE (TRAP14);
END Dosound;


PROCEDURE Setprt (config: BITSET): BITSET;
BEGIN
 PUSH (config);
 PUSH (CARDINAL (33));
 CODE (TRAP14);
 RETURN BITSET (REGISTER (D0));
END Setprt;


PROCEDURE Kbdvbase(): PtrKBVECS;
BEGIN
 PUSH (CARDINAL (34));
 CODE (TRAP14);
 RETURN ADDRESS (REGISTER (D0));
END Kbdvbase;


PROCEDURE Kbrate (initial, repeat: INTEGER): CARDINAL;
BEGIN
 PUSH (repeat);
 PUSH (initial);
 PUSH (CARDINAL (35));
 CODE (TRAP14);
 RETURN CARDINAL (REGISTER (D0));
END Kbrate;


PROCEDURE Prtblk (block: PtrPBDEF);
BEGIN
 PUSH (block);
 PUSH (CARDINAL (36));
 CODE (TRAP14);
END Prtblk;
 

PROCEDURE Vsync;
BEGIN
 PUSH (CARDINAL (37));
 CODE (TRAP14);
END Vsync;


PROCEDURE Supexec (code: ADDRESS);
BEGIN
 PUSH (code);
 PUSH (CARDINAL (38));
 CODE (TRAP14);
END Supexec;


PROCEDURE Puntaes;
BEGIN
 PUSH (CARDINAL (39));
 CODE (TRAP14);
END Puntaes;


PROCEDURE Blitmode (flag: INTEGER): BITSET;
BEGIN
 PUSH (flag);
 PUSH (CARDINAL (64));
 CODE (TRAP14);
 RETURN BITSET (REGISTER (D0));
END Blitmode;


END MagicXBIOS.

