MODULE Runtime;

(* Runtime module for OP2 68000-variant *)

IMPORT SYSTEM;

CONST ResMem      = 100000;  (* Memory available for other applications than Oberon *)
      MinMem      = 100000;  (* Minimum of memory resource necessary to run Oberon *)
      ResStack    = 1000;    (* Security amount between maximum of heap and act. SP at 'GetBlock' *)
      ArrDescSize = 28;      (* Size of an array descriptor without pointer offsets incl tag *)
      RecDescSize = 40;      (* Size of a record descriptor without pointer offsets incl tag *)

TYPE
    Module*        = POINTER TO ModuleDesc;
    ModuleDesc*    = RECORD
                       next*       : Module;
                       entries*    : LONGINT;
                       commands*   : LONGINT;
                       pointerRefs*: LONGINT;
                       imports*    : LONGINT;
                       constants*  : LONGINT;
                       code*       : LONGINT;
                       variables*  : LONGINT;
                       filename*   : POINTER TO ARRAY 132 OF CHAR;
                       modname*    : POINTER TO ARRAY 20 OF CHAR;
                       dsize*      : LONGINT;
                       blocksize*  : LONGINT;
                       key*        : LONGINT;
                       bofdlink*   : LONGINT;
                       dlnkx*      : INTEGER;
                       nofptrs*    : INTEGER;
                       nofGmod*    : INTEGER
                     END;
    BasePage*      = POINTER TO BasePageDesc;
    BasePageDesc*  = RECORD
                       LowTPA*, HiTPA* : LONGINT;
                       CodeBase*       : LONGINT;
                       CodeLen*        : LONGINT;
                       DataBase*       : LONGINT;
                       DataLen*        : LONGINT;
                       BssBase*        : LONGINT;
                       BssLen*         : LONGINT;
                       EnvPtr*         : POINTER TO ARRAY 80 OF CHAR;
                       CmdLine*        : ARRAY 220 OF CHAR
                     END;

TYPE
    Initialization = PROCEDURE;
    String         = ARRAY 128 OF CHAR;

VAR
    modroot*  : Module;   (* ancore of module descriptor list *)
    loadsize* : LONGINT;  (* the size of the loaded Oberon application (txtlen + datalen + bsslen) *)
    lowmem*   : LONGINT;  (* lowest memory location usable for heap *)
    currmem   : LONGINT;  (* lowest free memory location *)
    highmem*  : LONGINT;  (* highest memory location assigned by TOS *)
    basepage* : BasePage; (* Start of the TOS basepage of Oberon *)

VAR
    free      : ARRAY 5 OF LONGINT;
    mod       : Module;
    init      : Initialization;
    n         : LONGINT;


PROCEDURE- BConIn(dev: INTEGER) : LONGINT
3FH, 3CH, 0, 2H,   (* MOVE.W  #2,-(SP) *)
4EH, 4DH,          (* TRAP    #13      *)
54H, 8FH;          (* ADDQ.L  #2,SP    *)

PROCEDURE- BConOut(ch, dev: INTEGER)
3FH, 3CH, 0, 3H,   (* MOVE.W  #3,-(SP) *)
4EH, 4DH,          (* TRAP    #13      *)
54H, 8FH;          (* ADDQ.L  #2,SP    *)

PROCEDURE- DSetPath(VAR path: String)
3FH, 3CH, 0, 3BH,  (* MOVE.W  #$3B,-(SP) *)
4EH, 41H,          (* TRAP    #1         *)
54H, 8FH;          (* ADDQ.L  #2,SP      *)

PROCEDURE- MAlloc(length: LONGINT) : LONGINT
3FH, 3CH, 0, 48H,  (* MOVE.W  #$48,-(SP) *)
4EH, 41H,          (* TRAP    #1         *)
54H, 8FH;          (* ADDQ.L  #2,SP      *)

PROCEDURE- MFree(adr: LONGINT)
3FH, 3CH, 0, 49H,  (* MOVE.W  #$49,-(SP) *)
4EH, 41H,          (* TRAP    #1         *)
54H, 8FH;          (* ADDQ.L  #2,SP      *)

PROCEDURE- PExec(VAR env, cmd, name: String; mode: INTEGER) : LONGINT
3FH, 3CH, 0, 4BH,  (* MOVE.W  #$4B,-(SP) *)
4EH, 41H,          (* TRAP    #1         *)
54H, 8FH;          (* ADDQ.L  #2,SP      *)

PROCEDURE- Super(ssp: LONGINT): LONGINT
3FH, 3CH, 0, 20H,  (* MOVE.W  #$20,-(SP) *)
4EH, 41H,          (* TRAP    #1         *)
54H, 8FH;          (* ADDQ.L  #2,SP      *)

PROCEDURE- SetBlock(length, adr: LONGINT) : LONGINT
3FH, 3CH, 0, 0,    (* MOVE.W  #0,-(SP)   *)
3FH, 3CH, 0, 4AH,  (* MOVE.W  #$4A,-(SP) *)
4EH, 41H,          (* TRAP    #1         *)
58H, 8FH;          (* ADDQ.L  #4,SP      *)

PROCEDURE- Terminate(value: INTEGER)
3FH, 3CH, 0, 4CH,  (* MOVE.W  #$4C,-(SP) *)
4EH, 41H,          (* TRAP    #1         *)
54H, 8FH;          (* ADDQ.L  #2,SP      *)

PROCEDURE Write(ch: CHAR);
BEGIN BConOut(ORD(ch), 2)
END Write;

PROCEDURE WriteString(str: String);
  VAR i: SHORTINT;
BEGIN
  i:=0;
  WHILE str[i] # 0X DO BConOut(ORD(str[i]), 2); INC(i) END
END WriteString;

PROCEDURE WriteNum(num: LONGINT; len: INTEGER);
  VAR i: INTEGER; signed: BOOLEAN; str: ARRAY 16 OF CHAR;
BEGIN
  i:=0; signed:=FALSE;
  IF num < 0 THEN num:=-num; DEC(len); signed:=TRUE END;
  WHILE num # 0 DO
    str[i]:=CHR(SHORT(num MOD 10 + 30H)); num:=num DIV 10; INC(i)
  END;
  IF i = 0 THEN str[i]:="0"; INC(i) END;
  WHILE len > i DO Write(" "); DEC(len) END;
  IF signed THEN Write("-") END;
  WHILE i > 0 DO DEC(i); Write(str[i]) END
END WriteNum;

PROCEDURE WriteLn;
BEGIN
  BConOut(0DH, 2); BConOut(0AH, 2)
END WriteLn;

PROCEDURE CallDisass;
  VAR env, cmd, name: String;
BEGIN
  COPY("C:\UTILITY\DEC68000.PRG", name);
  COPY("C:\UTILITY\", env); DSetPath(env); env:=""; cmd:="";
  IF PExec(env, cmd, name, 0) = 0 THEN END
END CallDisass;

(* Runtime support routines *)

PROCEDURE LIntToReal*;
END LIntToReal;

PROCEDURE LIntToLReal*;
END LIntToLReal;

PROCEDURE RealToLInt*;
END RealToLInt;

PROCEDURE RealToLReal*;
END RealToLReal;

PROCEDURE LRealToLInt*;
END LRealToLInt;

PROCEDURE LRealToReal*;
END LRealToReal;

PROCEDURE Cmp*;
END Cmp;

PROCEDURE Add*;
END Add;

PROCEDURE Sub*;
END Sub;

PROCEDURE Mul*;
END Mul;

PROCEDURE Div*;
END Div;

PROCEDURE- IntMul321
   4EH, 5EH,     (* UNLK         A6    *)
   24H, 00H,     (* MOVE.L       D0,D2 *)
   6AH, 02H,     (* BPL.S        2     *)
   44H, 80H,     (* NEG.L        D0    *)
   0B3H, 82H,    (* EOR.L        D1,D2 *)
   20H, 42H,     (* MOVE.L       D2,A0 *)
   4AH, 81H,     (* TST.L        D1    *)
   6AH, 02H,     (* BPL.S        2     *)
   44H, 81H,     (* NEG.L        D1    *)
   24H, 00H,     (* MOVE.L       D0,D2 *)
   48H, 42H,     (* SWAP         D2    *)
   4AH, 42H,     (* TST.W        D2    *)
   66H, 22H,     (* BNE.S        $22   *)
   24H, 01H,     (* MOVE.L       D1,D2 *)
   48H, 42H,     (* SWAP         D2    *)
   4AH, 42H,     (* TST.W        D2    *)
   66H, 0AH,     (* BNE.S        $A    *)
   0C0H, 0C1H,   (* MULU         D1,D0 *)
   24H, 08H,     (* MOVE.L       A0,D2 *)
   6AH, 02H,     (* BPL.S        2     *)
   44H, 80H,     (* NEG.L        D0    *)
   4EH, 75H,     (* RTS                *)
   0C4H, 0C0H,   (* MULU         D0,D2 *)
   48H, 42H,     (* SWAP         D2    *)
   0C0H, 0C1H,   (* MULU         D1,D0 *)
   0D0H, 82H,    (* ADD.L        D2,D0 *)
   24H, 08H,     (* MOVE.L       A0,D2 *)
   6AH, 02H,     (* BPL.S        2     *)
   44H, 80H,     (* NEG.L        D0    *)
   4EH, 75H,     (* RTS                *)
   0C4H, 0C1H,   (* MULU         D1,D2 *)
   48H, 42H,     (* SWAP         D2    *)
   0C0H, 0C1H,   (* MULU         D1,D0 *)
   0D0H, 82H,    (* ADD.L        D2,D0 *)
   24H, 08H,     (* MOVE.L       A0,D2 *)
   6AH, 02H,     (* BPL.S        2     *)
   44H, 80H,     (* NEG.L        D0    *)
   4EH, 75H;     (* RTS                *)

PROCEDURE IntMul32*;
BEGIN IntMul321
END IntMul32;

PROCEDURE- IntDiv321
  4EH, 5EH,                     (* UNLK         A6     *)
  24H, 00H,                     (* MOVE.L       D0,D2  *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 80H,                     (* NEG.L        D0     *)
  0B3H, 82H,                    (* EOR.L        D1,D2  *)
  22H, 42H,                     (* MOVE.L       D2,A1  *)
  4AH, 81H,                     (* TST.L        D1     *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 81H,                     (* NEG.L        D1     *)
  24H, 01H,                     (* MOVE.L       D1,D2  *)
  48H, 42H,                     (* SWAP         D2     *)
  4AH, 42H,                     (* TST.W        D2     *)
  66H, 34H,                     (* BNE.S        $34    *)
  24H, 00H,                     (* MOVE.L       D0,D2  *)
  48H, 42H,                     (* SWAP         D2     *)
  4AH, 42H,                     (* TST.W        D2     *)
  66H, 10H,                     (* BNE.S        $10    *)
  80H, 0C1H,                    (* DIVU         D1,D0  *)
  48H, 40H,                     (* SWAP         D0     *)
  42H, 40H,                     (* CLR.W        D0     *)
  48H, 40H,                     (* SWAP         D0     *)
  24H, 09H,                     (* MOVE.L       A1,D2  *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 80H,                     (* NEG.L        D0     *)
  4EH, 75H,                     (* RTS                 *)
  42H, 40H,                     (* CLR.W        D0     *)
  48H, 40H,                     (* SWAP         D0     *)
  48H, 42H,                     (* SWAP         D2     *)
  80H, 0C1H,                    (* DIVU         D1,D0  *)
  30H, 40H,                     (* MOVE.W       D0,A0  *)
  30H, 02H,                     (* MOVE.W       D2,D0  *)
  80H, 0C1H,                    (* DIVU         D1,D0  *)
  48H, 40H,                     (* SWAP         D0     *)
  30H, 08H,                     (* MOVE.W       A0,D0  *)
  48H, 40H,                     (* SWAP         D0     *)
  24H, 09H,                     (* MOVE.L       A1,D2  *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 80H,                     (* NEG.L        D0     *)
  4EH, 75H,                     (* RTS                 *)
  20H, 41H,                     (* MOVE.L       D1,A0  *)
  48H, 40H,                     (* SWAP         D0     *)
  72H, 00H,                     (* MOVEQ.L      #0,D1  *)
  32H, 00H,                     (* MOVE.W       D0,D1  *)
  42H, 40H,                     (* CLR.W        D0     *)
  74H, 0FH,                     (* MOVEQ.L      #15,D2 *)
  0D0H, 80H,                    (* ADD.L        D0,D0  *)
  0D3H, 81H,                    (* ADDX.L       D1,D1  *)
  92H, 88H,                     (* SUB.L        A0,D1  *)
  64H, 02H,                     (* BCC.S        2      *)
  0D2H, 88H,                    (* ADD.L        A0,D1  *)
  0D1H, 80H,                    (* ADDX.L       D0,D0  *)
  0D3H, 81H,                    (* ADDX.L       D1,D1  *)
  051H, 0CAH, 0FFH, 0F4H,       (* DBF          D2,-12 *)
  46H, 40H,                     (* NOT.W        D0     *)
  24H, 09H,                     (* MOVE.L       A1,D2  *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 80H,                     (* NEG.L        D0     *)
  4EH, 75H;                     (* RTS                 *)

PROCEDURE IntDiv32*;
BEGIN IntDiv321
END IntDiv32;

PROCEDURE- IntMod321
  4EH, 5EH,                     (* UNLK         A6     *)
  22H, 40H,                     (* MOVE.L       D0,A1  *)
  24H, 00H,                     (* MOVE.L       D0,D2  *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 80H,                     (* NEG.L        D0     *)
  4AH, 81H,                     (* TST.L        D1     *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 81H,                     (* NEG.L        D1     *)
  24H, 01H,                     (* MOVE.L       D1,D2  *)
  48H, 42H,                     (* SWAP         D2     *)
  4AH, 42H,                     (* TST.W        D2     *)
  66H, 2EH,                     (* BNE.S        $2E    *)
  24H, 00H,                     (* MOVE.L       D0,D2  *)
  48H, 42H,                     (* SWAP         D2     *)
  4AH, 42H,                     (* TST.W        D2     *)
  66H, 0EH,                     (* BNE.S        $E     *)
  80H, 0C1H,                    (* DIVU         D1,D0  *)
  42H, 40H,                     (* CLR.W        D0     *)
  48H, 40H,                     (* SWAP         D0     *)
  24H, 09H,                     (* MOVE.L       A1,D2  *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 80H,                     (* NEG.L        D0     *)
  4EH, 75H,                     (* RTS                 *)
  42H, 40H,                     (* CLR.W        D0     *)
  48H, 40H,                     (* SWAP         D0     *)
  48H, 42H,                     (* SWAP         D2     *)
  80H, 0C1H,                    (* DIVU         D1,D0  *)
  30H, 02H,                     (* MOVE.W       D2,D0  *)
  80H, 0C1H,                    (* DIVU         D1,D0  *)
  42H, 40H,                     (* CLR.W        D0     *)
  48H, 40H,                     (* SWAP         D0     *)
  24H, 09H,                     (* MOVE.L       A1,D2  *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 80H,                     (* NEG.L        D0     *)
  4EH, 75H,                     (* RTS                 *)
  20H, 41H,                     (* MOVE.L       D1,A0  *)
  22H, 00H,                     (* MOVE.L       D0,D1  *)
  42H, 40H,                     (* CLR.W        D0     *)
  48H, 40H,                     (* SWAP         D0     *)
  48H, 41H,                     (* SWAP         D1     *)
  42H, 41H,                     (* CLR.W        D1     *)
  74H, 0FH,                     (* MOVEQ.L      #15,D2 *)
  0D2H, 81H,                    (* ADD.L        D1,D1  *)
  0D1H, 80H,                    (* ADDX.L       D0,D0  *)
  90H, 88H,                     (* SUB.L        A0,D0  *)
  64H, 02H,                     (* BCC.S        2      *)
  0D0H, 88H,                    (* ADD.L        A0,D0  *)
  0D3H, 81H,                    (* ADDX.L       D1,D1  *)
  0D1H, 80H,                    (* ADDX.L       D0,D0  *)
  51H, 0CAH, 0FFH, 0F4H,        (* DBF          D2,-12 *)
  0E2H, 90H,                    (* ROXR.L       #1,D0  *)
  24H, 09H,                     (* MOVE.L       A1,D2  *)
  6AH, 02H,                     (* BPL.S        2      *)
  44H, 80H,                     (* NEG.L        D0     *)
  4EH, 75H;                     (* RTS                 *)

PROCEDURE IntMod32*;
BEGIN IntMod321
END IntMod32;

PROCEDURE- UMul321
  4EH, 5EH,     (* UNLK         A6    *)
  24H, 00H,     (* MOVE.L       D0,D2 *)
  48H, 42H,     (* SWAP         D2    *)
  4AH, 42H,     (* TST.W        D2    *)
  66H, 16H,     (* BNE.S        $16   *)
  24H, 01H,     (* MOVE.L       D1,D2 *)
  48H, 42H,     (* SWAP         D2    *)
  4AH, 42H,     (* TST.W        D2    *)
  66H, 04H,     (* BNE.S        4     *)
  0C0H, 0C1H,   (* MULU         D1,D0 *)
  4EH, 75H,     (* RTS                *)
  0C4H, 0C0H,   (* MULU         D0,D2 *)
  48H, 42H,     (* SWAP         D2    *)
  0C0H, 0C1H,   (* MULU         D1,D0 *)
  0D0H, 82H,    (* ADD.L        D2,D0 *)
  4EH, 75H,     (* RTS                *)
  0C4H, 0C1H,   (* MULU         D1,D2 *)
  48H, 42H,     (* SWAP         D2    *)
  0C0H, 0C1H,   (* MULU         D1,D0 *)
  0D0H, 82H,    (* ADD.L        D2,D0 *)
  4EH, 75H;     (* RTS                *)

PROCEDURE UMul32*;
BEGIN UMul321
END UMul32;

PROCEDURE GetBlock(index: LONGINT; size: LONGINT): LONGINT;
  VAR node1, node2, node3, node4, nsize: LONGINT; found: BOOLEAN;
BEGIN
  IF size > 128 THEN
    IF free[4] = 0 THEN (* free list is empty *)
      SYSTEM.GETREG(15, node1);
      IF currmem <= node1 - size - ResStack THEN
        node1:=currmem; INC(currmem, size)
      ELSE
        node1:=0
      END
    ELSE
      node1:=0; node2:=free[4]; found:=FALSE;
      WHILE (node2 # 0) & ~found DO
        SYSTEM.GET(node2 + 8, nsize);
        IF size <= nsize THEN found:=TRUE
        ELSE node1:=node2; SYSTEM.GET(node2 + 4, node2)
        END
      END;
      IF found THEN (* first fit found *)
        node3:=node2 + size; SYSTEM.GET(node2 + 4, node4); DEC(nsize, size);
        IF nsize # 0 THEN
          SYSTEM.PUT(node3, LONG(LONG(0))); SYSTEM.PUT(node3 + 8, nsize)
        END;
        IF nsize = 128 THEN (* remaining part to small to stay in this list *)
          SYSTEM.PUT(node3 + 4, free[3]);
          free[3]:=node3;
	  IF node1 # 0 THEN SYSTEM.PUT(node1 + 4, node4)
	  ELSE free[4]:=node4
	  END
        ELSE
          IF nsize # 0 THEN
            SYSTEM.PUT(node3 + 4, node4)
          END;
          IF node1 # 0 THEN SYSTEM.PUT(node1 + 4, node3) (* nsize = 0 ==> node3 = node4 *)
          ELSE free[4]:=node3
          END
        END;
        node1:=node2
      ELSE (* no block fits => allocate block from free memory *)
        SYSTEM.GETREG(15, node1);
        IF currmem <= node1 - size - ResStack THEN
          node1:=currmem; INC(currmem, size)
        ELSE
          node1:=0
        END
      END
    END
  ELSE (* get block of sizes 16, 32, 64, or 128 *)
    IF free[index] = 0 THEN (* no free fitting block => get larger block and split *)
      node1:=GetBlock(index + 1, 2 * size);
      IF node1 # 0 THEN
        node2:=node1 + size;
        SYSTEM.PUT(node2, LONG(LONG(0)));
        SYSTEM.PUT(node2 + 4, free[index]); (* as a side effect of 'GetBlock' the list may *)
        SYSTEM.PUT(node2 + 8, size);        (* no longer be empty                          *)
        free[index]:=node2
      END
    ELSE (* take first block in free list *)
      node1:=free[index]; SYSTEM.GET(node1 + 4, free[index])
    END
  END;
  RETURN node1
END GetBlock;

PROCEDURE- New1
  4AH, 80H,                       (* TST.L        D0           *)
  67H, 22H,                       (* BEQ.S        $22          *)
  58H, 80H,                       (* ADDQ.L       #4,D0        *)
  20H, 6EH, 00H, 0EH,             (* MOVE.L       14(A6),A0    *)
  20H, 80H,                       (* MOVE.L       D0,(A0)      *)
  20H, 40H,                       (* MOVE.L       D0,A0        *)
  21H, 6EH, 00H, 08H, 0FFH, 0FCH, (* MOVE.L       8(A6),-4(A0) *)
  20H, 2EH, 0FFH, 0FCH,           (* MOVE.L       -4(A6),D0    *)
  0E4H, 80H,                      (* ASR.L        #2,D0        *)
  53H, 80H,			  (* SUBQ.L       #1,D0        *)
  72H, 00H,                       (* MOVEQ.L      #0,D1        *)
  20H, 0C1H,                      (* MOVE.L       D1,(A0)+     *)
  53H, 80H,                       (* SUBQ.L       #1,D0        *)
  66H, 0FAH,                      (* BNE.S        -6           *)
  60H, 06H,                       (* BRA.S        6            *)
  20H, 6EH, 00H, 0EH,             (* MOVE.L       14(A6),A0    *)
  42H, 90H;                       (* CLR.L        (A0)         *)
  
PROCEDURE New*(adr: LONGINT; isArray: BOOLEAN; tag: LONGINT);
  VAR size, node: LONGINT; index: LONGINT;
BEGIN
  SYSTEM.GET(tag, size);
  IF isArray THEN INC(tag, 40000000H) END;
  IF size > 128 THEN
    index:=4
  ELSE
    index:=0; node:=size DIV 32;
    WHILE node > 0 DO node:=node DIV 2; INC(index) END
  END;
  SYSTEM.PUTREG(0, GetBlock(index, size));
  New1
END New;

PROCEDURE SYSNew*(adr: LONGINT; isArray: BOOLEAN; tag, size: LONGINT);
  VAR node, m, s0, realsize: LONGINT; index: LONGINT;
BEGIN
  INC(size, size MOD 2); realsize:=size;
  IF isArray THEN INC(realsize, ArrDescSize)
  ELSE INC(realsize, RecDescSize)
  END;
  m:=4; s0:=16;
  WHILE (m > 0) & (realsize > s0) DO s0:=2 * s0; DEC(m) END;
  IF realsize > s0 THEN s0:=(realsize + 127) DIV 128 * 128 END;
  realsize:=s0;
  IF realsize > 128 THEN
    index:=4
  ELSE
    index:=0; node:=realsize DIV 32;
    WHILE node > 0 DO node:=node DIV 2; INC(index) END
  END;
  node:=GetBlock(index, realsize);
  IF node # 0 THEN
    SYSTEM.PUT(adr, node + 4); s0:=size;
    IF isArray THEN INC(s0, 40000000H) END;
    SYSTEM.PUT(node, node + s0);
    INC(node, 4); DEC(size, 4);
    WHILE size > 0 DO (* erase block to set potential pointer fields to NIL, *)
                      (* although no offset table entries are generated in the TD *)
      SYSTEM.PUT(node, LONG(0)); DEC(size, 2); INC(node, 2);
    END;
    SYSTEM.PUT(node, realsize);
    IF isArray THEN
      SYSTEM.PUT(node + 4, LONG(LONG(0))); SYSTEM.PUT(node + 8, LONG(LONG(0)));
      SYSTEM.PUT(node + 12, LONG(LONG(-12))); SYSTEM.PUT(node + 16, realsize)
    ELSE
      m:=7; INC(node, 4);
      WHILE m > 0 DO SYSTEM.PUT(node, LONG(LONG(0))); INC(node, 4); DEC(m) END;
      SYSTEM.PUT(node, LONG(LONG(-32)))
    END
  ELSE SYSTEM.PUT(adr, LONG(LONG(0)))
  END
END SYSNew;

PROCEDURE- GCInit
  48H, 0E7H, 0F0H, 0FEH,           (* MOVEM.L   A0-A6/D0-D3,-(SP) *)
  40H, 0E7H,                       (* MOVE.W    SR,-(SP)          *)
  00H, 7CH, 03H, 00H;              (* ORI       #$300,SR          *)
  
PROCEDURE- GCMark1 (* P == (A6 = modroot.next) *)
  26H, 0EH,                        (* MOVE.L    A6,D3          *)
  67H, 00H, 01H, 1AH,              (* BEQ       282            *)
  28H, 6EH, 00H, 0CH,              (* MOVE.L    12(A6),A4      *)
  24H, 54H,                        (* MOVE.L    (A4),A2        *)
  26H, 0AH,                        (* MOVE.L    A2,D3          *)
  6AH, 04H,                        (* BPL.S     4              *)
  2CH, 56H,                        (* MOVE.L    (A6),A6        *)
  60H, 0ECH,                       (* BRA.S     -20            *)
  2AH, 52H,                        (* MOVE.L    (A2),A5        *)
  26H, 0DH,                        (* MOVE.L    A5,D3          *)
  67H, 06H,                        (* BEQ.S     6              *)
  4AH, 0ADH, 0FFH, 0FCH,           (* TST.L     -4(A5)         *)
  6AH, 04H,                        (* BPL.S     4              *)
  58H, 8CH,                        (* ADDQ.L    #4,A4          *)
  60H, 0E6H,                       (* BRA.S     -26            *)
  28H, 8EH,                        (* MOVE.L    A6,(A4)        *)
  24H, 8CH,                        (* MOVE.L    A4,(A2)        *)
  2CH, 4AH,                        (* MOVE.L    A2,A6          *)
  08H, 0ADH, 00H, 06H, 0FFH, 0FCH, (* BCLR.B    #6,-4(A5)      *)
  56H, 0C1H,                       (* SNE       D1             *)
  28H, 6DH, 0FFH, 0FCH,            (* MOVE.L    -4(A5),A4      *)
  24H, 14H,                        (* MOVE.L    (A4),D2        *)
  4AH, 01H,                        (* TST.B     D1             *)
  66H, 08H,                        (* BNE.S     8              *)
  0D9H, 0FCH, 00H, 00H, 00H, 1CH,  (* ADD.L     #8*4-4,A4      *)
  60H, 06H,                        (* BRA.S     4              *)
  2BH, 8DH, 28H, 0F8H,             (* MOVE.L    A5,-8(A5,D2.L) *)
  50H, 8CH,                        (* ADDQ.L    #8,A4          *)
  58H, 8CH,                        (* ADDQ.L    #4,A4          *)
  20H, 14H,                        (* MOVE.L    (A4),D0        *)
  6BH, 52H,                        (* BMI.S     82             *)
  4AH, 01H,                        (* TST.B     D1             *)
  67H, 2CH,                        (* BEQ.S     44             *)
  0D1H, 0B5H, 28H, 0F8H,           (* ADD.L     D0,-8(A5,D2.L) *)
  22H, 75H, 28H, 0F8H,             (* MOVE.L    -8(A5,D2.L),A1 *)
  26H, 51H,                        (* MOVE.L    (A1),A3        *)
  26H, 0BH,                        (* MOVE.L    A3,D3          *)
  67H, 0E8H,                       (* BEQ.S     -24            *)
  4AH, 0ABH, 0FFH, 0FCH,           (* TST.L     -4(A3)         *)
  6BH, 0E2H,                       (* BMI.S     -30            *)
  2BH, 4CH, 0FFH, 0FCH,            (* MOVE.L    A4,-4(A5)      *)
  08H, 0EDH, 00H, 07H, 0FFH, 0FCH, (* BSET.B    #7,-4(A5)      *)
  08H, 0EDH, 00H, 06H, 0FFH, 0FCH, (* BSET.B    #6,-4(A5)      *)
  22H, 8AH,                        (* MOVE.L    A2,(A1)        *)
  24H, 4DH,                        (* MOVE.L    A5,A2          *)
  2AH, 4BH,                        (* MOVE.L    A3,A5          *)
  60H, 0AAH,                       (* BRA.S     -86            *)
  26H, 75H, 08H, 00H,              (* MOVE.L    0(A5,D0.L),A3  *)
  26H, 0BH,                        (* MOVE.L    A3,D3          *)
  67H, 0C2H,                       (* BEQ.S     -62            *)
  4AH, 0ABH, 0FFH, 0FCH,           (* TST.L     -4(A3)         *)
  6BH, 0BCH,                       (* BMI.S     -68            *)
  2BH, 4CH, 0FFH, 0FCH,            (* MOVE.L    A4,-4(A5)      *)
  08H, 0EDH, 00H, 07H, 0FFH, 0FCH, (* BSET.B    #7,-4(A5)      *)
  2BH, 8AH, 08H, 00H,              (* MOVE.L    A2,0(A5,D0.L)  *)
  24H, 4DH;                        (* MOVE.L    A5,A2          *)
  
PROCEDURE- GCMark2
  2AH, 4BH,                        (* MOVE.L    A3,A5          *)
  60H, 88H,                        (* BRA.S     -120           *)
  0D9H, 0C0H,                      (* ADD.L     D0,A4          *)
  4AH, 01H,                        (* TST.B     D1             *)
  67H, 14H,                        (* BEQ.S     20             *)
  26H, 2CH, 00H, 04H,              (* MOVE.L    4(A4),D3       *)
  0D7H, 0B5H, 28H, 0F8H,           (* ADD.L     D3,-8(A5,D2.L) *)
  26H, 35H, 28H, 0F8H,             (* MOVE.L    -8(A5,D2.L),D3 *)
  96H, 0ACH, 00H, 08H,             (* SUB.L     8(A4),D3       *)
  0B6H, 8DH,                       (* CMP.L     A5,D3          *)
  65H, 8CH,                        (* BCS.S     -116           *)
  2BH, 4CH, 0FFH, 0FCH,            (* MOVE.L    A4,-4(A5)      *)
  08H, 0EDH, 00H, 07H, 0FFH, 0FCH, (* BSET.B    #7,-4(A5)      *)
  4AH, 01H,                        (* TST.B     D1             *)
  67H, 06H,                        (* BEQ.S     6              *)
  08H, 0EDH, 00H, 06H, 0FFH, 0FCH, (* BSET.B    #6,-4(A5)      *)
  0BDH, 0CAH,                      (* CMP.L     A2,A6          *)
  66H, 0CH,                        (* BNE.S     12             *)
  28H, 52H,                        (* MOVE.L    (A2),A4        *)
  2CH, 54H,                        (* MOVE.L    (A4),A6        *)
  24H, 8DH,                        (* MOVE.L    A5,(A2)        *)
  28H, 8AH,                        (* MOVE.L    A2,(A4)        *)
  60H, 00H, 0FFH, 42H,             (* BRA       -190           *)
  26H, 4DH,                        (* MOVE.L    A5,A3          *)
  2AH, 4AH,                        (* MOVE.L    A2,A5          *)
  08H, 0ADH, 00H, 07H, 0FFH, 0FCH, (* BCLR.B    #7,-4(A5)      *)
  08H, 0ADH, 00H, 06H, 0FFH, 0FCH, (* BCLR.B    #6,-4(A5)      *)
  56H, 0C1H,                       (* SNE       D1             *)
  28H, 6DH, 0FFH, 0FCH,            (* MOVE.L    -4(A5),A4      *)
  4AH, 01H,                        (* TST.B     D1             *)
  67H, 16H,                        (* BEQ.S     22             *)
  4AH, 9CH,                        (* TST.L     (A4)+          *)
  6AH, 0FCH,                       (* BPL.S     -4             *)
  24H, 14H,                        (* MOVE.L    (A4),D2        *)
  28H, 6DH, 0FFH, 0FCH,            (* MOVE.L    -4(A5),A4      *)
  22H, 75H, 28H, 0F8H,             (* MOVE.L    -8(A4,D2.L),A1 *)
  24H, 51H,                        (* MOVE.L    (A1),A2        *)
  22H, 8BH,                        (* MOVE.L    A3,(A1)        *)
  60H, 00H, 0FFH, 3CH,             (* BRA       -196           *)
  20H, 14H,                        (* MOVE.L    (A4),D0        *)
  24H, 75H, 08H, 00H,              (* MOVE.L    0(A5,D0.L),A2  *)
  2BH, 8BH, 08H, 00H,              (* MOVE.L    A3,0(A5,D0.L)  *)
  60H, 00H, 0FFH, 2EH;             (* BRA       -210           *)

PROCEDURE- GCScan1 (* P == (A0 = ADR(free)) *)
  20H, 2EH, 0FFH, 0FCH,            (* MOVE.L    -4(A6),D0       *)
  0E5H, 80H,                       (* ASL.L     #2,D0           *)
  41H, 0F0H, 08H, 00H,             (* LEA       0(A0,D0.L),A0   *)
  43H, 0F6H, 08H, 0DCH,            (* LEA       -36(A6,D0.L),A1 *)
  4AH, 91H,                        (* TST.L     (A1)            *)
  67H, 0EH,                        (* BEQ.S     14              *)
  50H, 0EEH, 0FFH, 0DBH,           (* ST        -37(A6)         *)
  24H, 51H,                        (* MOVE.L    (A1),A2         *)
  25H, 50H, 00H, 04H,              (* MOVE.L    (A0),4(A2)      *)
  20H, 8AH,                        (* MOVE.L    A2,(A0)         *)
  42H, 91H;                        (* CLR.L     (A1)            *)
  
PROCEDURE GCScan;
  VAR i, j, p,
      k, size : LONGINT;
      V       : ARRAY 5 OF LONGINT;
      inserted: BOOLEAN;

BEGIN
  i:=0;
  WHILE i <= 4 DO free[i]:=0; V[i]:=0; INC(i) END;
  p:=lowmem;
  WHILE p < currmem DO
    IF SYSTEM.BIT(p, 7) THEN
      i:=0;  (* Insert possible predecessors blocks in the free lists *)
      WHILE i <= 4 DO
        IF V[i] # 0 THEN
          SYSTEM.PUT(V[i] + 4, free[i]); free[i]:=V[i]; V[i]:=0
        END;
        INC(i)
      END;
      SYSTEM.GET(p, i); i:=SYSTEM.LSH(SYSTEM.LSH(i, 1), -1); SYSTEM.PUT(p, i);
      i:=i MOD 40000000H; SYSTEM.GET(i, size)
    ELSE
      SYSTEM.GET(p, i);
      IF i # 0 THEN
        i:=i MOD 40000000H; SYSTEM.GET(i, size); SYSTEM.PUT(p, LONG(LONG(0)));
        SYSTEM.PUT(p + 8, size)
      ELSE
        SYSTEM.GET(p + 8, size)
      END;
      IF size > 128 THEN
        k:=4
      ELSE
        k:=0; i:=size DIV 32;
        WHILE i > 0 DO i:=i DIV 2; INC(k) END
      END;
      i:=0; inserted:=FALSE;
      WHILE i < k DO
        IF V[i] # 0 THEN
          inserted:=TRUE; SYSTEM.PUT(V[i] + 4, free[i]); free[i]:=V[i]; V[i]:=0
        END;
        INC(i)
      END;
      IF inserted THEN
        WHILE i <= 4 DO
          IF V[i] # 0 THEN
            SYSTEM.PUT(V[i] + 4, free[i]); free[i]:=V[i]; V[i]:=0
          END;
          INC(i)
        END;
        V[k]:=p
      ELSE (* Melt predecessor and block together *)
           (* enlarge the resulting block as far as possible *)
        WHILE (k < 4) & (V[k] # 0) DO
          p:=V[k]; V[k]:=0; size:=size * 2; SYSTEM.PUT(p + 8, size); INC(k)
        END;
        IF (k < 4) OR (V[4] = 0) THEN
          V[k]:=p
        ELSE (* (k = 4) & (V[k] # 0) *)
          p:=V[k]; SYSTEM.GET(p + 8, i); INC(size, i); SYSTEM.PUT(p + 8, size)
        END
      END
    END;
    INC(p, size)
  END;
  i:=0;
  WHILE i <= 4 DO
    IF V[i] # 0 THEN
      SYSTEM.PUT(V[i] + 4, free[i]); free[i]:=V[i]; V[i]:=0
    END;
    INC(i)
  END
END GCScan;

PROCEDURE- GCExit
  46H, 0DFH,                       (* MOVE.W    (SP)+,SR          *)
  4CH, 0DFH, 7FH, 0FH;             (* MOVEM.L   (SP)+,A0-A6/D0-D3 *)

PROCEDURE GC*;
  VAR ssp: LONGINT;
BEGIN
  ssp:=Super(0);
  GCInit;
  SYSTEM.PUTREG(14, modroot.next); (* Skip 'Runtime' *)
  GCMark1; GCMark2;
  GCScan;
  GCExit;
  ssp:=Super(ssp)
END GC;

BEGIN
  SYSTEM.GETREG(15, n); SYSTEM.GET(n + 4, basepage);
  IF SetBlock(loadsize + SIZE(BasePageDesc), SYSTEM.VAL(LONGINT, basepage)) = 0 THEN
    highmem:=MAlloc(-1) - ResMem + lowmem;
    IF highmem - lowmem >= MinMem THEN
      IF MAlloc(highmem - lowmem) = lowmem THEN
        SYSTEM.PUTREG(15, highmem);
(*
        SYSTEM.PUTREG(14, 0); (* End condition for stack dumper *)
*)
        n:=0;
        WHILE n < 5 DO free[n]:=0; INC(n) END;
        currmem:=lowmem;
        mod:=modroot.next;  (* skip 'Runtime' *)
        WHILE mod # NIL DO
          init:=SYSTEM.VAL(Initialization, mod.code);
          init();
          mod:=mod.next
        END;
(*
        CallDisass;
*)
      ELSE
        WriteString("Runtime: Heap allocation failed!"); WriteLn
      END
    ELSE
      WriteString("Runtime: Unsufficient memory resources!"); WriteLn
    END
  ELSE
    WriteString("Runtime: Initial heap allocation failed!"); WriteLn
  END;
(*
  n:=BConIn(2);
*)
  Terminate(0)
END Runtime.

