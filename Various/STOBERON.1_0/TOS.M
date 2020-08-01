MODULE TOS;

(* Interface to BIOS, XBIOS and GEMDOS *)

(* ===================================================================== *)

IMPORT SYSTEM;

CONST
     (* Bit numbers describing the result value of KBShift *)
     rshift = 0; lshift = 1; control = 2; alternate = 3; capslock = 4;
     rmouse = 5; lmouse = 6;
     
TYPE
     pBPB        = POINTER TO BPB;
     BPB         = RECORD
                     recsiz : INTEGER;
                     clsiz  : INTEGER;
                     clsizb : INTEGER;
                     rdlen  : INTEGER;
                     fsiz   : INTEGER;
                     fatrec : INTEGER;
                     datrec : INTEGER;
                     numcl  : INTEGER;
                     bflags : INTEGER
                   END;
     PaletteType = ARRAY 16 OF INTEGER;
     pIOBuffer   = POINTER TO IOBuffer;
     IOBuffer    = RECORD
                     buffer: LONGINT;
                     size  : INTEGER;
                     head  : INTEGER;
                     tail  : INTEGER;
                     low   : INTEGER;
                     high  : INTEGER
                   END;
                  
(* ===================================================================== *)
(* BIOS *)

PROCEDURE- BConStat1(dev: INTEGER): BOOLEAN
  3FH, 3CH, 00H, 01H,           (* MOVE.W       #1,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE BConStat*(dev: INTEGER): BOOLEAN;
BEGIN RETURN BConStat1(dev)
END BConStat;

(* --------------------------------------------------------------------- *)

PROCEDURE- BConIn1(dev: INTEGER): LONGINT
  3FH, 3CH, 00H, 02H,           (* MOVE.W       #2,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE BConIn*(dev: INTEGER): LONGINT;
BEGIN RETURN BConIn1(dev)
END BConIn;

(* --------------------------------------------------------------------- *)

PROCEDURE- BConOut1(ch, dev: INTEGER)
  3FH, 3CH, 00H, 03H,           (* MOVE.W       #3,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE BConOut*(dev: INTEGER; ch: CHAR);
BEGIN BConOut1(ORD(ch), dev)
END BConOut;

(* --------------------------------------------------------------------- *)

PROCEDURE- RWAbs1(dev, rec, num: INTEGER; buffer: LONGINT; flag: INTEGER)
  3FH, 3CH, 00H, 04H,           (* MOVE.W       #4,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE RWAbs*(flag: INTEGER; VAR buffer: ARRAY OF BYTE; num, rec, dev: INTEGER);
BEGIN RWAbs1(dev, rec, num, SYSTEM.ADR(buffer), flag)
END RWAbs;

(* --------------------------------------------------------------------- *)

PROCEDURE- SetExec1(vector: LONGINT; num: INTEGER)
  3FH, 3CH, 00H, 05H,           (* MOVE.W       #5,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE SetExec*(num: INTEGER; vector: LONGINT);
BEGIN SetExec1(vector, num)
END SetExec;

(* --------------------------------------------------------------------- *)

PROCEDURE- TickCal1(): LONGINT
  3FH, 3CH, 00H, 06H,           (* MOVE.W       #6,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE TickCal*(): LONGINT;
BEGIN RETURN TickCal1()
END TickCal;

(* --------------------------------------------------------------------- *)

PROCEDURE- GetBPB1(dev: INTEGER): pBPB
  3FH, 3CH, 00H, 07H,           (* MOVE.W       #7,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE GetBPB*(dev: INTEGER): pBPB;
BEGIN RETURN GetBPB1(dev)
END GetBPB;

(* --------------------------------------------------------------------- *)

PROCEDURE- BCoStat1(dev: INTEGER): BOOLEAN
  3FH, 3CH, 00H, 08H,           (* MOVE.W       #8,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE BCoStat*(dev: INTEGER): BOOLEAN;
BEGIN RETURN BCoStat1(dev)
END BCoStat;

(* --------------------------------------------------------------------- *)

PROCEDURE- MediaChange1(dev: INTEGER): SHORTINT
  3FH, 3CH, 00H, 09H,           (* MOVE.W       #9,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE MediaChange*(dev: INTEGER): SHORTINT;
BEGIN RETURN MediaChange1(dev)
END MediaChange;

(* --------------------------------------------------------------------- *)

PROCEDURE- DrvMap1(dev: INTEGER): SET
  3FH, 3CH, 00H, 0AH,           (* MOVE.W       #10,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)

PROCEDURE DrvMap*(dev: INTEGER): SET;
BEGIN RETURN DrvMap1(dev)
END DrvMap;

(* --------------------------------------------------------------------- *)

PROCEDURE- KBShift1(mode: INTEGER): INTEGER
  3FH, 3CH, 00H, 0BH,           (* MOVE.W       #11,-(SP) *)
  4EH, 4DH,                     (* TRAP         #13      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE KBShift*(mode: INTEGER): SET;
BEGIN RETURN SYSTEM.VAL(SET, LONG(KBShift1(mode)))
END KBShift;

(* ===================================================================== *)
(* XBIOS *)

PROCEDURE- PhysBase1(): LONGINT
  3FH, 3CH, 00H, 02H,           (* MOVE.W       #2,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE PhysBase*(): LONGINT;
BEGIN RETURN PhysBase1()
END PhysBase;

(* --------------------------------------------------------------------- *)

PROCEDURE- LogBase1(): LONGINT
  3FH, 3CH, 00H, 03H,           (* MOVE.W       #3,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE LogBase*(): LONGINT;
BEGIN RETURN LogBase1()
END LogBase;

(* --------------------------------------------------------------------- *)

PROCEDURE- GetRes1(): SHORTINT
  3FH, 3CH, 00H, 04H,           (* MOVE.W       #4,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE GetRes*(): SHORTINT;
BEGIN RETURN GetRes1()
END GetRes;

(* --------------------------------------------------------------------- *)

PROCEDURE- SetScreen1(res: INTEGER; physadr, logadr: LONGINT)
  3FH, 3CH, 00H, 05H,           (* MOVE.W       #5,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE SetScreen*(logadr, physadr: LONGINT; res: INTEGER);
BEGIN SetScreen1(res, physadr, logadr)
END SetScreen;

(* --------------------------------------------------------------------- *)

PROCEDURE- SetPalette1(VAR palette: PaletteType)
  3FH, 3CH, 00H, 05H,           (* MOVE.W       #5,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE SetPalette*(VAR palette: PaletteType);
BEGIN SetPalette1(palette)
END SetPalette;

(* --------------------------------------------------------------------- *)

PROCEDURE- SetColor1(color, colornum: INTEGER)
  3FH, 3CH, 00H, 05H,           (* MOVE.W       #5,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE SetColor*(colornum, color: INTEGER);
BEGIN SetColor1(color, colornum)
END SetColor;

(* --------------------------------------------------------------------- *)

PROCEDURE- MFPInt1(vector: LONGINT; num: INTEGER)
  3FH, 3CH, 00H, 0DH,           (* MOVE.W       #13,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE MFPInt*(num: INTEGER; vector: LONGINT);
BEGIN MFPInt1(vector, num)
END MFPInt;

(* --------------------------------------------------------------------- *)

PROCEDURE- IORec1(dev: INTEGER): pIOBuffer
  3FH, 3CH, 00H, 0EH,           (* MOVE.W       #14,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE IORec*(dev: INTEGER): pIOBuffer;
BEGIN RETURN IORec1(dev)
END IORec;

(* --------------------------------------------------------------------- *)

PROCEDURE- RSConf1(scr, tsr, rsr, ucr, ctrl, baud: INTEGER)
  3FH, 3CH, 00H, 0FH,           (* MOVE.W       #15,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE RSConf*(baud, ctrl, ucr, rsr, tsr, scr: INTEGER);
BEGIN RSConf1(scr, tsr, rsr, ucr, ctrl, baud)
END RSConf;

(* --------------------------------------------------------------------- *)

PROCEDURE- KeyTable1(capslock, shift, unshift: LONGINT)
  3FH, 3CH, 00H, 10H,           (* MOVE.W       #16,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE KeyTable*(unshift, shift, capslock: LONGINT);
BEGIN KeyTable1(capslock, shift, unshift)
END KeyTable;

(* --------------------------------------------------------------------- *)

PROCEDURE- Random1(): LONGINT
  3FH, 3CH, 00H, 11H,           (* MOVE.W       #17,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE Random*(): LONGINT;
BEGIN RETURN Random1()
END Random;

(* --------------------------------------------------------------------- *)

PROCEDURE- CursorConf1(rate, function: INTEGER)
  3FH, 3CH, 00H, 15H,           (* MOVE.W       #21,-(SP) *)
  4EH, 4EH,                     (* TRAP         #14      *)
  54H, 8FH;                     (* ADDQ.L       #2,SP    *)
  
PROCEDURE CursorConf*(function, rate: INTEGER);
BEGIN CursorConf1(rate, function)
END CursorConf;

(* ===================================================================== *)
(* GEMDOS *)

END TOS.

