MODULE NewStorTest; (*$E MOS *)

(*
 * Test-Programm fÅr neues Storage-Modul
 *)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, ADR, BYTE;
IMPORT StorBase, StrConv, Terminal;
FROM PrgCtrl IMPORT TermProcess;
FROM Storage IMPORT ALLOCATE, DEALLOCATE, MemSize, AllAvail, More;

FROM RandomGen IMPORT RandomCard;

TYPE
        PtrHead = POINTER TO Head;

        HeadLink = RECORD
                     n: INTEGER;  (* rel. offset von block.data *)
                     p: INTEGER;  (* rel. offset von block.data *)
                   END;

        Head  = RECORD;           (* werden nur fÅr used-Bereiche benutzt *)
                  hd: HeadLink;
                  root: INTEGER;  (* rel. Offset von Block.data (pos.Wert) *)
                  level: INTEGER;
                  size: INTEGER;  (* used-Grîûe, kann ungerade sein!     *)
                                  (* -- muû immer vor 'hd.data' stehen   *)
                                  (* damit 'fullBlk' funktioniert!       *)
                  data: BYTE      (* Beginn der Daten *)
                END;
CONST
        HeadSize = 10;            (* TSIZE (Head ohne data) *)

TYPE
        PtrLink = POINTER TO Link;

        Link = RECORD
                 next: PtrLink;
                 prev: PtrLink;
               END;

        PtrBlock = POINTER TO Block;

        Block = RECORD
                  blk: Link;
                  size: LONGINT;  (* Grîûe des verfÅgbaren Bereichs *)
                                  (*  kann ungerade sein!           *)
                                  (* Bit 30: <full>                 *)
                  CASE : CARDINAL OF
                  | 0: (* full *)
                    level: INTEGER;
                    full: CARDINAL; (* = 0, wenn full *)
                    fullData: BYTE
                  | 1: (* root *)
                    blRov: PtrBlock (* zeigt direkt auf letzten Block *)
                  | 2: (* not full *)
                    hd: HeadLink;
                    hdRov: INTEGER; (* letzer hd, wo alloc durchgef. wurde *)
                    free: LONGINT;  (* gesamter freier Bereich in Block *)
                    hds : BYTE      (* Beginn der Header/Freibereiche *)
                  END
                END;
CONST
        BlockSize     = 22;  (* TSIZE (Block ohne hds) *)
        BlockFullSize = 16;  (* TSIZE (Block, 0) *)

VAR RootPtr: PtrBlock;
    Verify: PROCEDURE (): CARDINAL;


PROCEDURE showLinks;


  PROCEDURE abs (bl: PtrBlock; hd: INTEGER): ADDRESS;
    (*$L-*)
    BEGIN
      ASSEMBLER
          ; RETURN ADR (bl^.hds) + LONGCARD (LONG (hd))
          MOVE    -(A3),D0
          MOVE.L  -(A3),A0
          ADDA.W  D0,A0
          ADDA.W  #BlockSize,A0
          MOVE.L  A0,(A3)+
      END
    END abs;
    (*$L=*)

  PROCEDURE sizeHd (bl: PtrBlock; hd: INTEGER): INTEGER;
    (*$L-*)
    BEGIN
      ASSEMBLER
          ; hdp:= abs (bl, hd);
          ; RETURN val (hdp^.size)
          MOVE    -(A3),D0
          MOVE.L  -(A3),A0
          MOVE.W  Head.size+BlockSize(A0,D0.W),D0
          ADDQ    #1,D0
          ANDI    #$FFFE,D0
          MOVE    D0,(A3)+
      END;
    END sizeHd;
    (*$L=*)

  PROCEDURE blkFull (bl: PtrBlock): BOOLEAN;
    (*$L-*)
    BEGIN
      ASSEMBLER
          MOVE.L  -(A3),A0
          BTST    #6,Block.size(A0)
          SNE     D0
          ANDI    #1,D0
          MOVE    D0,(A3)+
      END
    END blkFull;
    (*$L=*)

  PROCEDURE blkSize (bl: PtrBlock): LONGINT;
    (*$L-*)
    BEGIN
      ASSEMBLER
          MOVE.L  -(A3),A0
          MOVE.L  Block.size(A0),D0
          ANDI.L  #$00FFFFFF,D0
          MOVE.L  D0,(A3)+
      END
    END blkSize;
    (*$L=*)

  PROCEDURE nextHd (bl: PtrBlock; hd: INTEGER): INTEGER;
    (*$L-*)
    BEGIN
      ASSEMBLER
          ; hdp:= abs (bl, hd);
          ; RETURN hdp^.hd.n
          MOVE    -(A3),D0
          MOVE.L  -(A3),A0
          MOVE.W  Head.hd.n+BlockSize(A0,D0.W),(A3)+
      END;
    END nextHd;
    (*$L=*)

  PROCEDURE wrabs (a: ADDRESS);
    BEGIN
      Terminal.WriteString (StrConv.LHexToStr (a,7))
    END wrabs;

  PROCEDURE wrrel (a: LONGINT);
    BEGIN
      Terminal.WriteString (StrConv.IntToStr (a,5))
    END wrrel;

  PROCEDURE wr (c: ARRAY OF CHAR);
    BEGIN
      Terminal.WriteString (c)
    END wr;

  VAR line: CARDINAL;
  
  PROCEDURE wrln;
    VAR ch: CHAR;
    BEGIN
      INC (line);
      Terminal.WriteLn;
      IF line > 22 THEN
        Terminal.WriteString ('Taste...');
        Terminal.Read (ch);
        Terminal.WriteLn;
        line:= 0;
      END
    END wrln;

  VAR bl: PtrBlock; hd: PtrHead; freeBeg, usedBeg: INTEGER; ch: CHAR;
      l: INTEGER; ad: ADDRESS; empty: BOOLEAN;

  BEGIN
    line:= 0;
    Terminal.WriteString ('--------------------------------');
    Terminal.WriteLn;
    Terminal.WriteString ('All avail: ');
    Terminal.WriteString (StrConv.CardToStr (StorBase.AllAvail(),0));
    Terminal.WriteString (' < ');
    Terminal.WriteString (StrConv.CardToStr (AllAvail(),0));
    Terminal.WriteLn;
    bl:= RootPtr;
    empty:= TRUE;
    LOOP
      bl:= ADDRESS (bl^.blk.next);
      IF bl = RootPtr THEN EXIT END;
      empty:= FALSE;
      wrabs (bl);
      IF blkFull (bl) THEN
        wr ('  <full>,  size: ');
        wrrel (blkSize (bl));
        (*
          wr (' = ');
          ad:= ADR (bl^.fullData);
          wrrel (MemSize (ad));
        *)
        wr (', level: ');
        wr (StrConv.IntToStr (bl^.level,5));
        IF bl^.full # 0 THEN wr ('  full#0!') END;
        wrln
      ELSE
        wr ('  size: ');
        wrrel (blkSize (bl));
        wr (',  avail: ');
        wrrel (bl^.free);
        wrln;
        freeBeg:= 0;            (* End of last used area *)
        usedBeg:= bl^.hd.n;     (* Start of new used area *)
        LOOP
          IF usedBeg < 0 THEN
            (* rest ist hîchstens frei *)
            l:= VAL (INTEGER, blkSize (bl)) - freeBeg;
            IF l > 0 THEN
              wr ('        free: '); wrrel (l); wrln
            END;
            EXIT
          ELSE
            l:= usedBeg - freeBeg;
            IF l > 0 THEN
              wr ('        free: '); wrrel (l); wrln
            END
          END;
          wr ('        used: '); wrrel (sizeHd (bl, usedBeg));
          hd:= abs (bl, usedBeg);
          (*
            wr (' = ');
            ad:= ADR (hd^.data);
            wrrel (MemSize (ad));
          *)
          wr (', level: ');
          wr (StrConv.IntToStr (hd^.level,5));
          wrln;
          freeBeg:= usedBeg + HeadSize + sizeHd (bl, usedBeg);
          usedBeg:= nextHd (bl, usedBeg)
        END
      END;
      Terminal.Read (ch)
    END;
    IF empty THEN
      wr ('Empty!');
    END;
    wrln;
    Terminal.WriteString ('Press ESC:');
    REPEAT Terminal.Read (ch) UNTIL ch = CHR(27);
  END showLinks;

BEGIN
  More ($4EF3, ADR (RootPtr));
  More ($4EF4, ADR (Verify));
  showLinks;
END NewStorTest.

