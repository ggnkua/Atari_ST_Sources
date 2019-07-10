MODULE HDWBootC;  (* write bootsector to wait for harddisk *)
FROM SYSTEM   IMPORT ADR, ADDRESS, CODE;
FROM ConInOut IMPORT ConInWait, ConSetCursor;
FROM InOut    IMPORT WriteInt, WriteString;
FROM BIOS     IMPORT GetBPB, BPBPtr, BPB, RWAbs, RW;
FROM XBIOS    IMPORT PrototypeBootSector;
FROM GEMDOS   IMPORT OldTerm;     (* link with GEMACCX.LNK *)

VAR BufferB: ARRAY [0..0FFH] OF CARDINAL;
    BootCodeAdr: POINTER TO CARDINAL;
    BPBAdr: BPBPtr;
    rc: LONGINT;
    drive, sector, count: CARDINAL;
    i: CARDINAL;

(*$P- no entry nor exit code for the following procedure *)
PROCEDURE BootCode;
BEGIN CODE(
                  (* gpip     equ     $FFFFFA01       * MFP[GPIP]        *)
                  (* diskctrl equ     $FFFF8604   * Controller access reg*)
                  (* dmamode  equ     $FFFF8606       * DMA Mode Reg     *)
                  (* flock    equ     $43E            * DMA lock         *)
                  (* _hz_200  equ     $4BA            * 200hz counter    *)
                  (* *                                                   *)
   04E56H,0FFFEH, (*          link    A6,#$FFFE       * n.w              *)
   0426EH,0FFFEH, (*          clr.w   $FFFE(A6)       * n:=0             *)
   06100H,00128H, (* CallTest bsr     TestACSI        * TestACSI         *)
   07A07H,        (*          moveq.l #7,D5           * 8 Targets        *)
   049FAH,00164H, (*          lea     ACSIrdy(PC),A4  * result           *)
   04A34H,05000H, (* TestLoop tst.b   $0(A4,D5)       * if true          *)
   0674CH,        (*          beq     ExitTest        *      then exit   *)
   051CDH,0FFF8H, (*          dbf     D5,TestLoop     * loop             *)
   0C6EH,32H,0FFFEH,(*        cmpi.w  #50,$FFFE(A6)   * if n = 50        *)
   0660EH,        (*          bne     INCn(PC)                           *)
   0487AH,0017EH, (*          pea     NoHDMes(PC)     *      then No HD  *)
   03F3CH,00009H, (*          move.w  #9,-(A7)        *           ConWS  *)
   04E41H,        (*          trap    #1              *           GEMDOS *)
   05C8FH,        (*          addq.l  #6,A7                              *)
   06048H,        (*          bra     Exit            *           exit   *)
   0526EH,0FFFEH, (* INCn     addq.w  #$1,$FFFE(A6)   * n++              *)
   07A00H,        (*          moveq.l #$0,D5                             *)
   03A2EH,0FFFEH, (*          move.w  $FFFE(A6),D5    * n                *)
   08AFCH,0000AH, (*          divu    #10,D5          *   DIV 10         *)
   07830H,        (*          moveq.l #$30,D4                            *)
   0DA44H,        (*          add.w   D4,D5           *     + '0'        *)
   049FAH,00156H, (*          lea     WaitMesZ(PC),A4                    *)
   01885H,        (*          move.b  D5,(A4)         * to Message       *)
   04845H,        (*          swap    D5              * n MOD 10         *)
   07830H,        (*          moveq.l #$30,D4                            *)
   0DA44H,        (*          add.w   D4,D5           *     + '0'        *)
   049FAH,0014BH, (*          lea     WaitMesE(PC),A4                    *)
   01885H,        (*          move.b  D5,(A4)         * to Message       *)
   0487AH,00124H, (*          pea     WaitMes(PC)     * Wait Message     *)
   03F3CH,00009H, (*          move.w  #9,-(A7)        * ConWS            *)
   04E41H,        (*          trap    #1              * GEMDOS           *)
   05C8FH,        (*          addq.l  #6,A7                              *)
   060A4H,        (*          bra     CallTest                           *)
   049FAH,00136H, (* ExitTest lea     WaitMesZ(PC),A4                    *)
   00C14H,00078H, (*          cmpi.b  #'x',(A4)                          *)
   0670CH,        (*          beq     Exit                               *)
   0487AH,00130H, (*          pea     ClrMes(PC)      * Clear Home       *)
   03F3CH,00009H, (*          move.w  #9,-(A7)        * ConWS            *)
   04E41H,        (*          trap    #1              * GEMDOS           *)
   05C8FH,        (*          addq.l  #6,A7                              *)
   04E5EH,        (* Exit     unlk    A6                                 *)
   04E75H,        (*          rts                                        *)
                  (* *                                                   *)
   0DAB9H,0,4BAH, (* INTWait  add.l   _hz_200,D5      * Hz200 + wait200  *)
   839H,5H,0FFFFH,0FA01H,
                  (* MFPTest  btst    #$5,gpip        * DMA done         *)
   06604H,        (*          bne     ctime                              *)
   04280H,        (*          clr.l   D0              * yes: return true *)
   04E75H,        (*          rts                                        *)
   0BAB9H,0,4BAH, (* ctime    cmp.l  _hz_200,D5       * no: compare time *)
   062EAH,        (*          bhi     MFPTest         * loop             *)
   070FFH,        (*          moveq.l #-1,D0       * timout: return false*)
   04E75H,        (*          rts                                        *)
                  (* *                                                   *)
   04E56H,0FFFCH, (* TestTarg link    A6,#$FFFC       *                  *)
   03A2EH,00008H, (*          move.w  $8(A6),D5       * Device           *)
   0EB45H,        (*          asl.w   #5,D5           * * 20H + 0 (=TEST)*)
   01D45H,0FFFFH, (*          move.b  D5,$FFFF(A6)    * Command byte     *)
   03A3CH,00088H, (*          move.w  #$88,D5    * mode {FDCData,ACSIReg}*)
   03D45H,0FFFCH, (*          move.w  D5,$FFFC(A6)                       *)
   33C5H,0FFFFH,8606H,(*      move.w  D5,dmamode      * set dma mode     *)
   07200H,        (*          moveq.l #$0,D1                             *)
   0122EH,0FFFFH, (*          move.b  $FFFF(A6),D1    * Command byte     *)
   04841H,        (*          swap    D1              * to left w        *)
   03205H,        (*          move.w  D5,D1           * mode to right w  *)
   023C1H,0FFFFH,8604H,(*     move.l  D1,diskctrl   * to DMA command regs*)
   07A0AH,        (*          move.l  #10,D5                             *)
   061B0H,        (*          bsr     INTWait         * wait 50ms        *)
   04A40H,        (*          tst.w   D0              * DMA done ?       *)
   06704H,        (*          beq     NextCmd                            *)
   04E5EH,        (*          unlk    A6                                 *)
   04E75H,        (*          rts                     * no: return false *)
   6EH,2,0FFFCH,  (* NextCmd  ori.w   #$2,$FFFC(A6)   * INCL(mode,A1)    *)
   04281H,        (*          clr.l   D1                                 *)
   0322EH,0FFFCH, (*          move.w  $FFFC(A6),D1    * to command       *)
   07803H,        (*          moveq.l #3,D4           * counter          *)
   023C1H,0FFFFH,8604H,
                  (* CmdLoop  move.l  D1,diskctrl * comm to DMA comm regs*)
   07A0AH,        (*          move.l  #10,D5                             *)
   06190H,        (*          bsr     INTWait         * wait 50ms        *)
   04A40H,        (*          tst.w   D0              * DMA done         *)
   06704H,        (*          beq     CmdLoopE                           *)
   04E5EH,        (*          unlk    A6                                 *)
   04E75H,        (*          rts                     * no: return false *)
   051CCH,0FFECH, (* CmdLoopE dbf     D4,CmdLoop                         *)
   26EH,0FF7FH,0FFFCH,
                  (*       andi.w  #$FF7F,$FFFC(A6) * EXCL(mode,FDCData) *)
   0322EH,0FFFCH, (*          move.w  $FFFC(A6),D1    * to command       *)
   23C1H,0FFFFH,8604H,(*      move.l  D1,diskctrl * comm to DMA comm regs*)
   02A3CH,0,0C8H, (*          move.l  #200,D5                            *)
   06100H,0FF6CH, (*          bsr     INTWait         * wait 1s          *)
   04A40H,        (*          tst.w   D0              * DMA done         *)
   06704H,        (*          beq     readstat                           *)
   04E5EH,        (*          unlk    A6                                 *)
   04E75H,        (*          rts                     * no: return false *)
   6EH,80H,0FFFCH,(* readstat ori.w   #$80,$FFFC(A6) * INCL(mode,FDCData)*)
   02A2EH,0FFFCH, (*          move.l  $FFFC(A6),D5                       *)
   33C5H,0FFFFH,8606H,(*      move.w  D5,dmamode      * set DMA mode     *)
   04280H,        (*          clr.l   D0              * return true      *)
   04E5EH,        (*          unlk    A6                                 *)
   04E75H,        (*          rts                                        *)
                  (* *                                                   *)
   04E56H,0FFFEH, (* TestACSI link    A6,#$FFFE                          *)
   0426EH,0FFFEH, (*          clr.w   $FFFE(A6)       * target           *)
   050F9H,0,43EH, (*          st      flock           * lock DMA         *)
   03F2EH,0FFFEH, (* TargLoop move.w  $FFFE(A6),-(A7)                    *)
   06100H,0FF58H, (*          bsr     TestTarg        * test target      *)
   03A2EH,0FFFEH, (*          move.w  $FFFE(A6),D5                       *)
   049FAH,00026H, (*          lea     ACSIrdy(PC),A4                     *)
   01980H,05000H, (*          move.b  D0,$0(A4,D5)    * store result     *)
   33FCH,80H,0FFFFH,8606H,(*  move.w  #$80,dmamode * dmamode: = {FDCData}*)
   51F9H,0,43EH,  (*          sf      flock           * unlock DMA       *)
   0C6EH,7,0FFFEH,(*          cmpi.w  #$7,$FFFE(A6)                      *)
   06406H,        (*          bcc     EndTest                            *)
   0526EH,0FFFEH, (*          addq.w  #$1,$FFFE(A6)                      *)
   060D0H,        (*          bra     TargLoop                           *)
   04E5EH,        (* EndTest  unlk    A6                                 *)
   04E75H,        (*          rts                                        *)
                  (* *                                                   *)
   0,0,0,0,       (* ACSIrdy  dc.b    0,0,0,0,0,0,0,0                    *)
   (* WaitMes  dc.b    $1B,'Y',32+12,32+25,'jkSoft waiting for harddisk '*)
   1B59H,2C39H,6A6BH,536FH,
   6674H,2077H,6169H,7469H,
   6E67H,2066H,6F72H,2068H,
   6172H,6464H,6973H,6B20H,
   07878H,0,      (* WaitMesZ dc.b    'x'                                *)
                  (* WaitMesE dc.b    'x',0                              *)
   01B45H,0,      (* ClrMes   dc.b    $1B,'E',0       * Clear Home       *)
                  (* *                                                   *)
(* NoHDMes  dc.b    $1B,'Y',32+12,32+25,'         no harddisk          ',0*)
   1B59H,2C39H,2020H,2020H,
   2020H,2020H,206EH,6F20H,
   6861H,7264H,6469H,736BH,
   2020H,2020H,2020H,2020H,
   2020H,0        (*                                                     *)
                  (*          .end                                       *)

            ) END BootCode;

PROCEDURE BootCodeEnd; END BootCodeEnd;

BEGIN
   ConSetCursor(10,12);
   WriteString(" Write hard disk wait boot sector on A ! (hit any key)");
   ConInWait;
   ConSetCursor(12,12);
   drive:=0 (* A *); sector:=0; count:=1;
   (* accept disk: *)
   BPBAdr:=GetBPB(drive);
   rc:=RWAbs(Read,ADR(BufferB),count,sector,drive);
   IF rc # 0 THEN
      WriteString(" Error "); WriteInt(INTEGER(rc),3);
      WriteString(" reading existing boot sector");
      ConInWait
   ELSE
      BufferB[0]:=601CH;  (* jump to 1E *)
      BufferB[1]:=6A6BH;  (* \           *)
      BufferB[2]:=536FH;  (*  > "jkSoft" *)
      BufferB[3]:=6674H;  (* /           *)
      BootCodeAdr:=ADDRESS(BootCode);
      i:=0FH;
      REPEAT BufferB[i]:=BootCodeAdr^;
             INC(i); BootCodeAdr:=ADDRESS(BootCodeAdr) + 2
      UNTIL BootCodeAdr = ADDRESS(BootCodeEnd);
      REPEAT BufferB[i]:=0; INC(i) UNTIL i = 100H;
      PrototypeBootSector(ADR(BufferB),-1,-1,1);
      rc:=RWAbs(Write,ADR(BufferB),count,sector,drive);
      IF rc # 0 THEN
         WriteString(" Error "); WriteInt(INTEGER(rc),3);
         WriteString(" writing new boot sector"); 
         ConInWait
      END
   END;
   OldTerm
END HDWBootC.
