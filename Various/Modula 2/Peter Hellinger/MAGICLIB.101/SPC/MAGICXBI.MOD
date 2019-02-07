(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  XBIOS  Extended Basic Input Output System     Interface for Modula-2

                Implementation fÅr LPR-Modula-2

########################################################################
  V1.01  18.06.90  Peter Hellinger      Bugs fixed, Anpassung an neues DEF
  V1.01  (C) by Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicXBIOS;

FROM SYSTEM IMPORT ADDRESS, SETREG, REG, ADR, WORD, LONG, BYTE, INLINE, VAL;
IMPORT MagicSys;

CONST   Trap14 =        04E4EH;
        AddSP =         0DFFCH;
        D0 =            0;


VAR     res:            LONGCARD;


(* Systemfunktionen *)

PROCEDURE Xbios         (z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosW        (a: WORD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosWW       (a, b: WORD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosL        (a: LONGCARD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosLL       (a, b: LONGCARD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosWLL      (a: WORD; b, c: LONGCARD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosWWWWWLL  (a,b,c,d,e: WORD; f, g: LONGCARD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosWLWWWWWLL  (a: WORD; b: LONGCARD; c,d,e,f,g: WORD;
                           h, i: LONGCARD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosLW       (a: LONGCARD; b: WORD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosLLW      (a, b: LONGCARD; c: WORD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosWWWWWW   (a,b,c,d,e,f: WORD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosLLL      (a, b, c: LONGCARD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosWWLL     (a,b: WORD; c, d: LONGCARD; z: CARDINAL);  CODE Trap14;
PROCEDURE XbiosLWWW     (a: LONGCARD; b,c,d: WORD; z: CARDINAL);  CODE Trap14;



PROCEDURE Initmouse (type: INTEGER; VAR param: PARAM; vec: PROC);
VAR a: ADDRESS;
BEGIN
 a:= VAL (ADDRESS, vec);
 XbiosLLW (a, ADR(param), type, 0);
 INLINE (AddSP, 0, 12);
END Initmouse;


PROCEDURE Physbase (): ADDRESS;
BEGIN
 Xbios (2);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToAddr (res);
END Physbase;


PROCEDURE Logbase (): ADDRESS;
BEGIN
 Xbios (3);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToAddr (res);
END Logbase;


PROCEDURE Getrez (): INTEGER;
BEGIN
 Xbios (4);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Getrez;


PROCEDURE Setscreen (log, phys: ADDRESS; rez: INTEGER);
BEGIN
 XbiosWLL (rez, phys, log, 5);
 INLINE (AddSP, 0, 12);
END Setscreen;


PROCEDURE Setpalette (VAR palette: ARRAY OF WORD);
BEGIN
 XbiosL (ADR (palette), 6);
 INLINE (AddSP, 0, 6);
END Setpalette;


PROCEDURE Setcolor (colNum, color: CARDINAL): CARDINAL;
BEGIN
 XbiosWW (color, colNum, 7);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN MagicSys.LCardToCard (res);
END Setcolor;


PROCEDURE Floprd (buf: ADDRESS; drv, sec, trck, side, count: INTEGER): INTEGER;
BEGIN
 XbiosWWWWWLL (count, side, trck, sec, drv, LONG(0), buf, 8);
 INLINE (AddSP, 0, 20);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Floprd;


PROCEDURE Flopwr (buf: ADDRESS; drv, sec, trck, side, count: INTEGER): INTEGER;
BEGIN
 XbiosWWWWWLL (count, side, trck, sec, drv, LONG(0), buf, 9);
 INLINE (AddSP, 0, 20);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Flopwr;


PROCEDURE Flopfmt (buf: ADDRESS; drv, spt, trck, side, il, virgin: INTEGER): INTEGER;
CONST magic = 087654321H;
BEGIN
 XbiosWLWWWWWLL (virgin, magic, il, side, trck, spt, drv, LONG(0), buf, 10);
 INLINE (AddSP, 0, 26);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Flopfmt;


PROCEDURE Midiws (VAR string: ARRAY OF BYTE; len: CARDINAL);
BEGIN
 XbiosLW (ADR(string), len, 12);
 INLINE (AddSP, 0, 8);
END Midiws;


PROCEDURE Mfpint (intNo: CARDINAL; vector: PROC);
VAR x: ADDRESS;
BEGIN
 x:= VAL (ADDRESS, vector);
 XbiosLW (x, intNo, 13);
 INLINE (AddSP, 0, 8);
END Mfpint;


PROCEDURE Iorec (dev: INTEGER): PtrIOREC;
BEGIN
 XbiosW (dev, 14);
 INLINE (AddSP, 0, 4);
 res:= REG (0);
 RETURN MagicSys.LCardToAddr (res);
END Iorec;


PROCEDURE Rsconf (speed: INTEGER; flavor: BITSET;  u, r, t, s: INTEGER): INTEGER;
BEGIN
 XbiosWWWWWW (s, t, r, u, flavor, speed, 15);
 INLINE (AddSP, 0, 14);
 res:= REG (0);
 RETURN MagicSys.LCardToInt (res);
END Rsconf;


PROCEDURE Keytbl (VAR unshift, shift, capslock: Keycode): PtrKEYTAB;
VAR a,b,c: ADDRESS;
BEGIN
 a:= VAL (ADDRESS, capslock);
 b:= VAL (ADDRESS, shift);
 c:= VAL (ADDRESS, unshift);
 XbiosLLL (a, b, c, 16);
 INLINE (AddSP, 0, 14);
 res:= REG (0);
 RETURN MagicSys.LCardToAddr (res);
END Keytbl;


PROCEDURE Random(): LONGCARD;
BEGIN
 Xbios (17);
 INLINE (AddSP, 0, 2);
 res:= REG (0);
 RETURN res;
END Random;


PROCEDURE Protobt (buf: ADDRESS; num: LONGINT; typ, exec: INTEGER);
BEGIN
 XbiosWWLL (exec, typ, num, buf, 18);
 INLINE (AddSP, 0, 14);
END Protobt;


PROCEDURE Flopver (buf: ADDRESS; drv, sec, trck, side, count: INTEGER): INTEGER;
BEGIN
 XbiosWWWWWLL (count, side, trck, sec, drv, LONG(0), buf, 19);
 INLINE (AddSP, 0, 20);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Flopver;


PROCEDURE Scrdmp;
BEGIN
 Xbios (20);
 INLINE (AddSP, 0, 2);
END Scrdmp;


PROCEDURE Cursconf (function, operand: INTEGER): INTEGER;
BEGIN
 XbiosWW (operand, function, 21);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN MagicSys.LCardToInt (res);
END Cursconf;


PROCEDURE Settime (datetime: LONGCARD);
BEGIN
 XbiosL (datetime, 22);
 INLINE (AddSP, 0, 6);
END Settime;


PROCEDURE Gettime (): LONGCARD;
BEGIN
 Xbios (23);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN res;
END Gettime;


PROCEDURE Bioskeys;
BEGIN
 Xbios (24);
 INLINE (AddSP, 0, 2);
END Bioskeys;


PROCEDURE Ikbdws (VAR str: ARRAY OF BYTE; len: CARDINAL);
BEGIN
 XbiosLW (ADR(str), len, 25);
 INLINE (AddSP, 0, 8);
END Ikbdws;


PROCEDURE Jdisint (intNo: CARDINAL);
BEGIN
 XbiosW (intNo, 26);
 INLINE (AddSP, 0, 4);
END Jdisint;


PROCEDURE Jenabint (intNo: CARDINAL);
BEGIN
 XbiosW (intNo, 27);
 INLINE (AddSP, 0, 4);
END Jenabint;


PROCEDURE Giaccess (regno: CARDINAL; data: BYTE): CARDINAL;
VAR c: CARDINAL;
BEGIN
 c:= MagicSys.ByteToCard (data);
 XbiosWW (regno, c, 25);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN MagicSys.LCardToCard (res);
END Giaccess;


PROCEDURE Offgibit (bitno: CARDINAL);
BEGIN
 XbiosW (bitno, 29);
 INLINE (AddSP, 0, 4);
END Offgibit;


PROCEDURE Ongibit (bitno: CARDINAL);
BEGIN
 XbiosW (bitno, 29);
 INLINE (AddSP, 0, 4);
END Ongibit;


PROCEDURE Xbtimer (timer, control, data: CARDINAL; vec: PROC);
BEGIN
 XbiosLWWW (VAL (ADDRESS, vec), data, control, timer, 31);
 INLINE (AddSP, 0, 12);
END Xbtimer;


PROCEDURE Dosound (VAR data: ARRAY OF BYTE);
BEGIN
 XbiosL (ADR(data), 32);
 INLINE (AddSP, 0, 6);
END Dosound;


PROCEDURE Setprt (config: BITSET): BITSET;
BEGIN
 XbiosW (config, 33);
 INLINE (AddSP, 0, 4);
END Setprt;


PROCEDURE Kbdvbase(): PtrKBVECS;
BEGIN
 Xbios (34);
 INLINE (AddSP, 0, 2);
 res:= REG (D0);
 RETURN MagicSys.LCardToAddr (res);
END Kbdvbase;


PROCEDURE Kbrate (initial, repeat: INTEGER): CARDINAL;
BEGIN
 XbiosWW (repeat, initial, 35);
 INLINE (AddSP, 0, 6);
 res:= REG (D0);
 RETURN MagicSys.LCardToCard (res);
END Kbrate;


PROCEDURE Prtblk (block: PtrPBDEF);
BEGIN
 XbiosL (VAL (ADDRESS, block), 36);
 INLINE (AddSP, 0, 6);
END Prtblk;
 

PROCEDURE Vsync;
BEGIN
 Xbios (37);
 INLINE (AddSP, 0, 2);
END Vsync;


PROCEDURE Supexec (code: ADDRESS);
BEGIN
 XbiosL (code, 38);
 INLINE (AddSP, 0, 6);
END Supexec;


PROCEDURE Puntaes;
BEGIN
 Xbios (37);
 INLINE (AddSP, 0, 2);
END Puntaes;


PROCEDURE Blitmode (flag: INTEGER): BITSET;
BEGIN
 XbiosW (flag, 64);
 INLINE (AddSP, 0, 4);
 res:= REG (D0);
 RETURN MagicSys.LCardToBitset (res);
END Blitmode;


END MagicXBIOS.

