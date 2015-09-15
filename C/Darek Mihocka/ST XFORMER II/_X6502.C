
/***************************************************************************

   _X6502.C by Darek Mihocka (CIS: 73657,2714  GEnie: DAREKM)

   6502 simulation code is in this file

   June 5, 1987  14:40

 ***************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include "_xformer.h"

/* format of mnemonics: 3 ascii codes of the opcode and the addressing mode:
   00 - implied     01 - immediate     02 - zero page         03 - zero page,x
   04 - zero page,y 05 - (zero page,x) 06 - (zero page),y
   07 - absolute    08 - absolute,x    09 - absolute,y        0A - accumulator
   0B - relative    0C - indirect      0D - absolute indirect

   used by the 6502 monitor for disassembling code

   I found out too late that Megamax supports long character constants. arghh!
*/

long mnemonics[256] = {
 0x42524B00L, 0x4F524105L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x4F524102L,
 0x41534C02L, 0x3F3F3F00L, 0x50485000L, 0x4F524101L, 0x41534C0AL, 0x3F3F3F00L,
 0x3F3F3F00L, 0x4F524107L, 0x41534C07L, 0x3F3F3F00L, 0x42504C0BL, 0x4F524106L,
 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x4F524103L, 0x41534C03L, 0x3F3F3F00L,
 0x434C4300L, 0x4F524109L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x4F524108L,
 0x41534C08L, 0x3F3F3F00L, 0x4A535207L, 0x414E4405L, 0x3F3F3F00L, 0x3F3F3F00L,
 0x42495402L, 0x414E4402L, 0x524F4C02L, 0x3F3F3F00L, 0x504C5000L, 0x414E4401L,
 0x524F4C0AL, 0x3F3F3F00L, 0x42495407L, 0x414E4407L, 0x524F4C07L, 0x3F3F3F00L,
 0x424D490BL, 0x414E4406L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x414E4403L,
 0x524F4C03L, 0x3F3F3F00L, 0x53454300L, 0x414E4409L, 0x3F3F3F00L, 0x3F3F3F00L,
 0x3F3F3F00L, 0x414E4408L, 0x524F4C08L, 0x3F3F3F00L, 0x52544900L, 0x454F5205L,
 0x4C53520AL, 0x3F3F3F00L, 0x4A4D5007L, 0x454F5202L, 0x4C535202L, 0x3F3F3F00L,
 0x50484100L, 0x454F5201L, 0x4C53520AL, 0x3F3F3F00L, 0x4A4D5007L, 0x454F5207L,
 0x4C535207L, 0x3F3F3F00L, 0x4256430BL, 0x454F5206L, 0x3F3F3F00L, 0x3F3F3F00L,
 0x3F3F3F00L, 0x454F5203L, 0x4C535203L, 0x3F3F3F00L, 0x434C4900L, 0x454F5209L,
 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x454F5208L, 0x4C535208L, 0x3F3F3F00L,
 0x52545300L, 0x41444305L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x41444302L,
 0x524F5202L, 0x3F3F3F00L, 0x504C4100L, 0x41444301L, 0x524F520AL, 0x3F3F3F00L,
 0x4A4D500CL, 0x41444307L, 0x524F5207L, 0x3F3F3F00L, 0x4256530BL, 0x41444306L,
 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x41444303L, 0x524F5203L, 0x3F3F3F00L,
 0x53454900L, 0x41444309L, 0x3F3F3F00L, 0x3F3F3F00L, 0x3F3F3F00L, 0x41444308L,
 0x524F5208L, 0x3F3F3F00L, 0X3F3F3F00L, 0X53544105L, 0X3F3F3F00L, 0X3F3F3F00L,
 0X53545902L, 0X53544102L, 0X53545802L, 0X3F3F3F00L, 0X44455900L, 0X3F3F3F00L,
 0X54584100L, 0X3F3F3F00L, 0X53545907L, 0X53544107L, 0X53545807L, 0X3F3F3F00L,
 0X4243430BL, 0X53544106L, 0X3F3F3F00L, 0X3F3F3F00L, 0X53545903L, 0X53544103L,
 0X53545804L, 0X3F3F3F00L, 0X54594100L, 0X53544109L, 0X54585300L, 0X3F3F3F00L,
 0X3F3F3F00L, 0X53544108L, 0X3F3F3F00L, 0X3F3F3F00L, 0X4C445901L, 0X4C444105L,
 0X4C445801L, 0X3F3F3F00L, 0X4C445902L, 0X4C444102L, 0X4C445802L, 0X3F3F3F00L,
 0X54415900L, 0X4C444101L, 0X54415800L, 0X3F3F3F00L, 0X4C445907L, 0X4C444107L,
 0X4C445807L, 0X3F3F3F00L, 0X4243530BL, 0X4C444106L, 0X3F3F3F00L, 0X3F3F3F00L,
 0X4C445903L, 0X4C444103L, 0X4C445804L, 0X3F3F3F00L, 0X434C5600L, 0X4C444109L,
 0X54535800L, 0X3F3F3F00L, 0X4C445908L, 0X4C444108L, 0X4C445809L, 0X3F3F3F00L,
 0X43505901L, 0X434D5005L, 0X3F3F3F00L, 0X3F3F3F00L, 0X43505902L, 0X434d5002L,
 0X44454302L, 0X3F3F3F00L, 0X494E5900L, 0X434D5001L, 0X44455800L, 0X3F3F3F00L,
 0X43505907L, 0X434D5007L, 0X44454307L, 0X3F3F3F00L, 0X424E450BL, 0X434D5006L,
 0X3F3F3F00L, 0X3F3F3F00L, 0X3F3F3F00L, 0X434D5003L, 0X44454303L, 0X3F3F3F00L,
 0X434C4400L, 0X434D5009L, 0X3F3F3F00L, 0X3F3F3F00L, 0X3F3F3F00L, 0X434D5008L,
 0X44454308L, 0X3F3F3F00L, 0X43505801L, 0X53424305L, 0X3F3F3F00L, 0X3F3F3F00L,
 0X43505802L, 0X53424302L, 0X494E4302L, 0X3F3F3F00L, 0X494E5800L, 0X53424301L,
 0X4E4F5000L, 0X3F3F3F00L, 0X43505807L, 0X53424307L, 0X494E4307L, 0X3F3F3F00L,
 0X4245510BL, 0X53424306L, 0X3F3F3F00L, 0X3F3F3F00L, 0X3F3F3F00L, 0X53424303L,
 0X494E4303L, 0X3F3F3F00L, 0X53454400L, 0X53424309L, 0X3F3F3F00L, 0X3F3F3F00L,
 0X3F3F3F00L, 0X53424308L, 0X494E4308L, 0X3F3F3F00L
 } ;

int (*vec_6502[256])() = {  /* create an array of pointers to 256 functions */

 op00, op01, op02, op03, op04, op05, op06, op07, op08,
 op09, op0A, op0B, op0C, op0D, op0E, op0F, op10, op11, op12,
 op13, op14, op15, op16, op17, op18, op19, op1A, op1B,
 op1C, op1D, op1E, op1F, op20, op21, op22, op23, op24,
 op25, op26, op27, op28, op29, op2A, op2B, op2C, op2D,
 op2E, op2F, op30, op31, op32, op33, op34, op35, op36,
 op37, op38, op39, op3A, op3B, op3C, op3D, op3E, op3F,
 op40, op41, op42, op43, op44, op45, op46, op47, op48,
 op49, op4A, op4B, op4C, op4D, op4E, op4F, op50, op51,
 op52, op53, op54, op55, op56, op57, op58, op59, op5A,
 op5B, op5C, op5D, op5E, op5F, op60, op61, op62, op63,
 op64, op65, op66, op67, op68, op69, op6A, op6B, op6C,
 op6D, op6E, op6F, op70, op71, op72, op73, op74, op75,
 op76, op77, op78, op79, op7A, op7B, op7C, op7D, op7E,
 op7F, op80, op81, op82, op83, op84, op85, op86, op87,
 op88, op89, op8A, op8B, op8C, op8D, op8E, op8F, op90,
 op91, op92, op93, op94, op95, op96, op97, op98, op99,
 op9A, op9B, op9C, op9D, op9E, op9F, opA0, opA1, opA2,
 opA3, opA4, opA5, opA6, opA7, opA8, opA9, opAA, opAB,
 opAC, opAD, opAE, opAF, opB0, opB1, opB2, opB3, opB4,
 opB5, opB6, opB7, opB8, opB9, opBA, opBB, opBC, opBD,
 opBE, opBF, opC0, opC1, opC2, opC3, opC4, opC5, opC6,
 opC7, opC8, opC9, opCA, opCB, opCC, opCD, opCE, opCF,
 opD0, opD1, opD2, opD3, opD4, opD5, opD6, opD7, opD8,
 opD9, opDA, opDB, opDC, opDD, opDE, opDF, opE0, opE1,
 opE2, opE3, opE4, opE5, opE6, opE7, opE8, opE9, opEA,
 opEB, opEC, opED, opEE, opEF, opF0, opF1, opF2, opF3,
 opF4, opF5, opF6, opF7, opF8, opF9, opFA, opFB, opFC,
 opFD, opFE, opFF } ;


int (*dec_6502[256])() = {  /* an array of pointers assuming D flag is on */

 op00, op01, op02, op03, op04, op05, op06, op07, op08,
 op09, op0A, op0B, op0C, op0D, op0E, op0F, op10, op11, op12,
 op13, op14, op15, op16, op17, op18, op19, op1A, op1B,
 op1C, op1D, op1E, op1F, op20, op21, op22, op23, op24,
 op25, op26, op27, op28, op29, op2A, op2B, op2C, op2D,
 op2E, op2F, op30, op31, op32, op33, op34, op35, op36,
 op37, op38, op39, op3A, op3B, op3C, op3D, op3E, op3F,
 op40, op41, op42, op43, op44, op45, op46, op47, op48,
 op49, op4A, op4B, op4C, op4D, op4E, op4F, op50, op51,
 op52, op53, op54, op55, op56, op57, op58, op59, op5A,
 op5B, op5C, op5D, op5E, op5F, op60, op61dec, op62, op63,
 op64, op65dec, op66, op67, op68, op69dec, op6A, op6B, op6C,
 op6Ddec, op6E, op6F, op70, op71dec, op72, op73, op74, op75dec,
 op76, op77, op78, op79dec, op7A, op7B, op7C, op7Ddec, op7E,
 op7F, op80, op81, op82, op83, op84, op85, op86, op87,
 op88, op89, op8A, op8B, op8C, op8D, op8E, op8F, op90,
 op91, op92, op93, op94, op95, op96, op97, op98, op99,
 op9A, op9B, op9C, op9D, op9E, op9F, opA0, opA1, opA2,
 opA3, opA4, opA5, opA6, opA7, opA8, opA9, opAA, opAB,
 opAC, opAD, opAE, opAF, opB0, opB1, opB2, opB3, opB4,
 opB5, opB6, opB7, opB8, opB9, opBA, opBB, opBC, opBD,
 opBE, opBF, opC0, opC1, opC2, opC3, opC4, opC5, opC6,
 opC7, opC8, opC9, opCA, opCB, opCC, opCD, opCE, opCF,
 opD0, opD1, opD2, opD3, opD4, opD5, opD6, opD7, opD8,
 opD9, opDA, opDB, opDC, opDD, opDE, opDF, opE0, opE1dec,
 opE2, opE3, opE4, opE5dec, opE6, opE7, opE8, opE9dec, opEA,
 opEB, opEC, opEDdec, opEE, opEF, opF0, opF1dec, opF2, opF3,
 opF4, opF5dec, opF6, opF7, opF8, opF9dec, opFA, opFB, opFC,
 opFDdec, opFE, opFF } ;


/* No more C code in this file, but we have to declare an entry point */

execute() {

  asm {
    movem.l D0-D7/A0-A3,-(SP)   ; save enviornment

 ; clear everything just to be safe
    clr.l   D0
    clr.l   D1
    clr.l   D2
    clr.l   D3
    clr.l   D4
    clr.l   D5
    clr.l   D6
    clr.l   D7

 ; convert   P register NV_BDIZC to CCR register BDIXNZVC
    move.b  p(GLOBAL),REGST
    move.b  REGST,DBUS          ; BDI
    move.b  REGST,REGA          ; N
    move.b  REGST,REGX          ; V
    move.b  REGST,REGY          ; Z
    move.b  REGST,REGEA         ; set X equal to C

    asl.b   #3,DBUS
    and.b   #0xE0,DBUS          ; BDI_____
    asl.b   #4,REGEA
    and.b   #BITX,REGEA         ; ___X____
    asl.b   #1,REGY
    and.b   #BITZ,REGY          ; _____Z__
    asr.b   #4,REGA
    and.b   #BITN,REGA          ; ____N___
    asr.b   #5,REGX
    and.b   #BITV,REGX          ; ______V_

    move.b  REGEA,REGST
    or.b    REGX,REGST
    or.b    REGY,REGST
    or.b    REGA,REGST
    or.b    DBUS,REGST          ; that gets BDIXNZVC !!!

    move.b  a(GLOBAL),REGA      ; load 6502 registers
    move.b  x(GLOBAL),REGX
    move.b  y(GLOBAL),REGY
    move.w  #0x100,REGSP
    move.b  sp(GLOBAL),REGSP    ; stack is on page 1
    move.w  pc(GLOBAL),REGPC

    lea     emul(PC),REGOPS     ; pointer to emulator
    tst.b   fTrace(GLOBAL)
    beq.s   notrace             ; if trace bit set...
    lea     exit_emul(PC),REGOPS    ; divert to exit routine
  notrace:
    lea     pemul(PC),REGMEA
    move.l  REGOPS,(REGMEA)

    lea     vec_6502(GLOBAL),REGOPS ; pointer to table
    btst.b   #6,REGST               ; check decimal flag
    beq.s   nodec
    lea     dec_6502(GLOBAL),REGOPS ; pointer to table
  nodec:
    move.l  mem(GLOBAL),REGMEA  ; pointer to mem[ea]
    move.l  stat(GLOBAL),REGSTAT
    move.l  REGMEA,REGEA
    add.l   REGMEA,REGPC        ; pointer to mem[pc]
    move.l  REGPC,REGMPC

 ; fall through into dispatch routine

  emul:
    clr.w   IR                      ; clear "instruction register"
    move.b  (REGMPC)+,IR            ; fetch an opcode
    add.w   IR,IR
    add.w   IR,IR                   ; multiply by 4
    move.l  0(REGOPS,IR.w),REGMEA   ; calculate address of opcode handler
    jmp     (REGMEA)                ; and jump to it

  pemul:
    dc.l    0                       ; pointer to emul, exit_emul, or sysvbl

  exit_emul:
    move.b  REGA,a(GLOBAL)          ; save 6502 registers
    move.b  REGX,x(GLOBAL)
    move.b  REGY,y(GLOBAL)
    move.b  REGSP,sp(GLOBAL)
    move.w  REGMPC,pc(GLOBAL)
    move.w  REGMEA,ea(GLOBAL)

 ; convert CCR register BDIXNZVC to  P  register NV_BDIZC
    move.b  REGST,DBUS          ; BDI
    move.b  REGST,REGA          ; N
    move.b  REGST,REGX          ; V
    move.b  REGST,REGY          ; Z
    move.b  REGST,REGEA         ; C

    asr.b   #3,DBUS
    and.b   #0x1C,DBUS          ; ___BDI__
    asr.b   #4,REGEA
    and.b   #CBIT,REGEA         ; _______C
    asr.b   #1,REGY
    and.b   #ZBIT,REGY          ; ______Z_
    asl.b   #4,REGA
    and.b   #NBIT,REGA          ; N_______
    asl.b   #5,REGX
    and.b   #VBIT,REGX          ; _V______

    move.b  REGEA,REGST
    or.b    REGX,REGST
    or.b    REGY,REGST
    or.b    REGA,REGST
    or.b    DBUS,REGST          ; that gets NV_BDIZC
    ori.b   #0x20,REGST         ; and then  NV1BDIZC

    move.b  REGST,p(GLOBAL)

    movem.l (SP)+,D0-D7/A0-A3   ; restore enviornment

; and get outta here!
  }

    return ;

  asm {

 ; Some common code to save space

 ; at entry, all common routines MUST have REGEA loaded!!

 ; this does an ORA with REGA and set the flags in REGST
 ; first check if the status byte is negative, if so, call emul_serv
  doORchk:
    move.b  0(REGSTAT,REGEA.w),IR   ; get status byte
    bpl.s   doOR                ; if OK to read memory go do so
    SETREAD                     ; else set read flag
    BSR     emul_serv           ; and call service routine
  doOR:
    move.l  REGEA,REGMEA        ; get the byte
    or.b    (REGMEA),REGA       ; ORA with accumualtor
    move.w  SR,DBUS             ; get CCR register
    and.b   #(BITN|BITZ),DBUS   ; isolate N and Z flags
    and.b   #~(BITN|BITZ),REGST ; clear them out in P register
    or.b    DBUS,REGST          ; join them
    DISPATCH                    ; and go do another opcode

 ; similar to doOR except it does an AND
  doANDchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doAND
    SETREAD
    BSR     emul_serv
  doAND:
    move.l  REGEA,REGMEA
    and.b   (REGMEA),REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

  doEORchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doEOR
    SETREAD
    BSR     emul_serv
  doEOR:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS       ; silly 68000 limitation
    eor.b   DBUS,REGA           ; makes you do it in 2 steps
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; increment memory location REGEA
  doINCchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doINC
    SETREAD
    BSR     emul_serv
  doINC:
    move.l  REGEA,REGMEA
    addq.b  #1,(REGMEA)
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; decrement memory location REGEA
  doDECchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doDEC
    SETREAD
    BSR     emul_serv
  doDEC:
    move.l  REGEA,REGMEA
    subq.b  #1,(REGMEA)
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; do a LDA, but first check to see if the status byte is positive
  doLDAchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doLDA
    SETREAD
    bsr     emul_serv
 ; at this point the service routine executed, or the status byte was zero
  doLDA:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

  doLDXchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doLDX
    SETREAD
    BSR     emul_serv
  doLDX:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),REGX
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

  doLDYchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doLDY
    SETREAD
    BSR     emul_serv
  doLDY:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),REGY
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; do a STA, but first check to see if the status byte is non-zero
  doSTAchk:
    move.b  0(REGSTAT,REGEA.w),IR
    beq.s   doSTA
    SETWRITE
    SWAP    DBUS                ; save status byte in lo word of D0
    move.b  REGA,DBUS           ; put the byte to store in the hi word
    SWAP    DBUS
    bra     emul_serv           ; call emul serv
  doSTA:
    move.l  REGEA,REGMEA        ; most routines will do this themselves
    move.b  REGA,(REGMEA)       ; but just in case, do the write to memory
    DISPATCH

 ; ditto, but for STX
  doSTXchk:
    move.b  0(REGSTAT,REGEA.w),IR
    beq.s   doSTX
    SETWRITE
    SWAP    DBUS
    move.b  REGX,DBUS
    SWAP    DBUS
    bra     emul_serv
  doSTX:
    move.l  REGEA,REGMEA
    move.b  REGX,(REGMEA)
    DISPATCH

 ; ditto, but for STY
  doSTYchk:
    move.b  0(REGSTAT,REGEA.w),IR
    beq.s   doSTY
    SETWRITE
    SWAP    DBUS
    move.b  REGY,DBUS
    SWAP    DBUS
    bra     emul_serv
  doSTY:
    move.l  REGEA,REGMEA
    move.b  REGY,(REGMEA)
    DISPATCH

 ; do an ADC, similar to above
  doADCchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doADC
    SETREAD
    BSR     emul_serv
  doADC:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    ori.b   #BITZ,REGST         ; ADDX doesn't set Z flag
    move.b  REGST,CCR           ; also prepare C bit
    addx.b  DBUS,REGA           ; binary add
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITV|BITX),DBUS
    and.b   #~(BITN|BITZ|BITV|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

  doADCdecchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doADCdec
    SETREAD
    BSR     emul_serv
  doADCdec:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    ori.b   #BITZ,REGST
    move.b  REGST,CCR
    ABCD    DBUS,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITV|BITX),DBUS
    and.b   #~(BITN|BITZ|BITV|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

  doSBCchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doSBC
    SETREAD
    BSR     emul_serv
  doSBC:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    eori.b  #BITX,REGST         ; different than 6502
    ori.b   #BITZ,REGST         ; SUBX doesn't set Z flag
    move.b  REGST,CCR
    subx.b  DBUS,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX|BITV),DBUS
    eori.b  #BITX,DBUS
    and.b   #~(BITN|BITZ|BITX|BITV),REGST
    or.b    DBUS,REGST
    DISPATCH

  doSBCdecchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doSBCdec
    SETREAD
    BSR     emul_serv
  doSBCdec:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    eori.b  #BITX,REGST
    ori.b   #BITZ,REGST
    move.b  REGST,CCR
    SBCD    DBUS,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX|BITV),DBUS
    eori.b  #BITX,DBUS
    and.b   #~(BITN|BITZ|BITX|BITV),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; in CMP, DBUS already has the byte loaded
  doCMP:
    SWAP    DBUS
    move.b  REGA,DBUS
    SWAP    DBUS
    SUB.b   DBUS,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    eori.b  #BITX,DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    SWAP    DBUS
    move.b  DBUS,REGA
    SWAP    DBUS
    DISPATCH

  doCPX:
    SWAP    DBUS
    move.b  REGX,DBUS
    SWAP    DBUS
    SUB.b   DBUS,REGX
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    eori.b  #BITX,DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    SWAP    DBUS
    move.b  DBUS,REGX
    SWAP    DBUS
    DISPATCH

  doCPY:
    SWAP    DBUS
    move.b  REGY,DBUS
    SWAP    DBUS
    SUB.b   DBUS,REGY
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    eori.b  #BITX,DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    SWAP    DBUS
    move.b  DBUS,REGY
    SWAP    DBUS
    DISPATCH

  doROLchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doROL
    SETREAD
    BSR     emul_serv
  doROL:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),IR         ; get byte
    move.b  REGST,CCR
    ROXL.b  #1,IR               ; shift it
    move.b  IR,(REGMEA)         ; save in memory
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

  doRORchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doROR
    SETREAD
    BSR     emul_serv
  doROR:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),IR
    move.b  REGST,CCR
    ROXR.b  #1,IR
    move.b  IR,(REGMEA)
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

  doASLchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doASL
    SETREAD
    BSR     emul_serv
  doASL:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),IR
    asl.b   #1,IR
    move.b  IR,(REGMEA)
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

  doLSRchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doLSR
    SETREAD
    BSR     emul_serv
  doLSR:
    move.l  REGEA,REGMEA
    move.b  (REGMEA),IR
    lsr.b   #1,IR
    move.b  IR,(REGMEA)
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

  doBITchk:
    move.b  0(REGSTAT,REGEA.w),IR
    bpl.s   doBIT
    SETREAD
    BSR     emul_serv
  doBIT:
    tst.b   (REGMEA)            ; V bit not set by a tst
    move.w  SR,DBUS
    and.b   #(BITN),DBUS
    and.b   #~(BITN|BITV|BITZ),REGST
    or.b    DBUS,REGST
    move.b  (REGMEA),DBUS       ; read the byte and...
    lsr.b   #5,DBUS             ; shift V bit into position
    and.b   #(BITV),DBUS
    or.b    DBUS,REGST
    move.b  (REGMEA),DBUS
    and.b   REGA,DBUS
    move.w  SR,DBUS
    and.b   #(BITZ),DBUS        ; Z flag set if M AND A = 0
    or.b    DBUS,REGST
    DISPATCH

 ; 256 emulation routines go here

 ; BRK is not quite implemented since it should never really occur in real life
  op00:
    or.b    #BITB,REGST
    bra     exit_emul

 ; ORA (zp,X)
  op01:
    clr.w   REGEA               ; clear IR
    move.b  (REGMPC)+,REGEA     ; get zero page address
    add.b   REGX,REGEA          ; add X and wraparound to zero page
    move.l  REGEA,REGMEA        ; effective address calculated
    move.b  1(REGMEA),-(SP)     ; get hi byte
    move.w  (SP)+,REGEA         ; and shift by 8 (faster than a lsl.w #8)
    move.b  (REGMEA),REGEA      ; get lo byte
    bra     doORchk             ; go to common ORing routine

 ; ORA zp
  op05:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doOR

 ; ASL zp
  op06:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doASL

 ; PHP - do a 68000 to 6502 flag conversion, like in the init code
  op08:
    move.w  REGSP,REGEA
    move.l  REGEA,REGMEA
    movem.l DBUS/REGST/REGA/REGX/REGY/REGEA,-(SP)
    move.b  REGST,DBUS
    move.b  REGST,REGA
    move.b  REGST,REGX
    move.b  REGST,REGY
    move.b  REGST,REGEA
    asr.b   #3,DBUS
    and.b   #0x1C,DBUS
    asr.b   #4,REGEA
    and.b   #CBIT,REGEA
    asr.b   #1,REGY
    and.b   #ZBIT,REGY
    asl.b   #4,REGA
    and.b   #NBIT,REGA
    asl.b   #5,REGX
    and.b   #VBIT,REGX
    move.b  REGEA,REGST
    or.b    REGX,REGST
    or.b    REGY,REGST
    or.b    REGA,REGST
    or.b    DBUS,REGST
    ori.b   #0x20,REGST
    move.b  REGST,(REGMEA)
    movem.l (SP)+,DBUS/REGST/REGA/REGX/REGY/REGEA
    subq.b  #1,REGSP
    DISPATCH

 ; ORA #
  op09:
    or.b    (REGMPC)+,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; ASL A
  op0A:
    asl.b   #1,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; ORA abs
  op0D:
    move.b  1(REGMPC),-(SP)     ; get hi byte
    move.w  (SP)+,REGEA         ; shift it 8 times
    move.b  (REGMPC),REGEA      ; get lo byte
    addq.w  #2,REGMPC
    bra     doORchk

 ; ASL abs
  op0E:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doASLchk

 ; BPL
  op10:
    btst    #3,REGST
    bne.s   nobpl               ; BITN = 0x08 = bit #3
    move.b  (REGMPC)+,DBUS
    ext.w   DBUS
    adda.w  DBUS,REGMPC
    DISPATCH
  nobpl:
    addq.l  #1,REGMPC
    DISPATCH

 ; ORA (zp),Y
  op11:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA;
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    bra     doORchk

 ; ORA zp,X
  op15:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doOR

 ; ASL zp,X
  op16:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doASL

 ; CLC
  op18:
    andi.b  #~BITX,REGST
    DISPATCH

 ; ORA abs,Y
  op19:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA;
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doORchk

 ; ORA abs,X
  op1D:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA;
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doORchk

 ; ASL abs,X
  op1E:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doASLchk

 ; JSR abs
  op20:
    subq.b  #2,REGSP
    move.w  REGSP,REGEA
    move.l  REGEA,REGMEA
    move.w  REGMPC,REGPC
    addq.w  #1,REGPC
    move.b  REGPC,1(REGMEA)     ; push PClo
    move.w  REGPC,-(SP)
    move.b  (SP)+,2(REGMEA)     ; push PChi
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGPC
    move.b  (REGMPC),REGPC
    move.l  REGPC,REGMPC
    DISPATCH

 ; AND (zp,X)
  op21:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    bra     doANDchk

 ; BIT zp
  op24:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    bra     doBIT

 ; AND zp
  op25:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doAND

 ; ROL zp
  op26:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doROL

 ; PLP
  op28:
    addq.b  #1,REGSP
    move.w  REGSP,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),REGST
    movem.l DBUS/REGA/REGX/REGY/REGEA,-(SP)
    move.b  REGST,DBUS
    move.b  REGST,REGA
    move.b  REGST,REGX
    move.b  REGST,REGY
    move.b  REGST,REGEA
    asl.b   #3,DBUS
    and.b   #0xE0,DBUS
    asl.b   #4,REGEA
    and.b   #BITX,REGEA
    asl.b   #1,REGY
    and.b   #BITZ,REGY
    asr.b   #4,REGA
    and.b   #BITN,REGA
    asr.b   #5,REGX
    and.b   #BITV,REGX
    move.b  REGEA,REGST
    or.b    REGX,REGST
    or.b    REGY,REGST
    or.b    REGA,REGST
    or.b    DBUS,REGST;
    movem.l (SP)+,DBUS/REGA/REGX/REGY/REGEA
    DISPATCH

 ; AND #
  op29:
    and.b   (REGMPC)+,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; ROL A
  op2A:
    move.b  REGST,CCR                   ; prepare X bit
    ROXL.b  #1,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; BIT abs
  op2C:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doBITchk

 ; AND abs
  op2D:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doANDchk

 ; ROL abs
  op2E:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doROLchk

 ; BMI
  op30:
    btst    #3,REGST
    beq.s   nobmi               ; BITN = 0x08 = bit #3
    move.b  (REGMPC)+,DBUS
    ext.w   DBUS
    adda.w  DBUS,REGMPC
    DISPATCH
  nobmi:
    addq.l  #1,REGMPC
    DISPATCH

 ; AND (zp),Y
  op31:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    bra     doANDchk

 ; AND zp,X
  op35:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doAND

 ; ROL zp,X
  op36:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doROL

 ; SEC
  op38:
    ori.b   #BITX,REGST
    DISPATCH

 ; AND abs,Y
  op39:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doANDchk

 ; AND abs,X
  op3D:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doANDchk

 ; ROL abs,X
  op3E:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doROLchk

 ; RTI
 ; should never execute since the emulator doesn't really support interrupts
 ; But, deferred VBIs end in an RTI, so it is included here
  op40:
    move.w  REGSP,REGEA
    move.l  REGEA,REGMEA
    move.b  2(REGMEA),-(SP)     ; pull PChi
    move.w  (SP)+,REGPC
    move.b  1(REGMEA),REGPC     ; pull PClo
    move.l  REGPC,REGMPC        ; do NOT increment PC for an RTI
    move.b  3(REGMEA),REGST     ; pull processor, don't bother decoding
    addq.b  #3,REGSP
    DISPATCH

 ; EOR (zp,X)
  op41:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    bra     doEORchk

 ; EOR zp
  op45:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doEOR

 ; LSR zp
  op46:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doLSR

 ; PHA
  op48:
    move.w  REGSP,REGEA
    move.l  REGEA,REGMEA
    move.b  REGA,(REGMEA)       ; push acc
    subq.b  #1,REGSP
    DISPATCH

 ; EOR #
  op49:
    move.b  (REGMPC)+,DBUS
    eor.b   DBUS,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; LSR A
  op4A:
    lsr.b   #1,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; JMP abs
  op4C:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGPC
    move.b  (REGMPC),REGPC
    move.l  REGPC,REGMPC
    DISPATCH

 ; EOR abs
  op4D:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doEORchk

 ; LSR abs
  op4E:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doLSRchk

 ; BVC
  op50:
    btst    #1,REGST
    bne.s   nobvc               ; BITV = 0x02 = bit #1
    move.b  (REGMPC)+,DBUS
    ext.w   DBUS
    adda.w  DBUS,REGMPC
    DISPATCH
  nobvc:
    addq.l  #1,REGMPC
    DISPATCH

 ; EOR (zp),Y
  op51:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    bra     doEORchk

 ; EOR zp,X
  op55:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doEOR

 ; LSR zp,X
  op56:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doLSR

 ; CLI
  op58:
    andi.b  #~BITI,REGST
    DISPATCH

 ; EOR abs,Y
  op59:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doEORchk

 ; EOR abs,X
  op5D:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doEORchk

 ; LSR abs,X
  op5E:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doLSRchk

 ; RTS
  op60:
    move.w  REGSP,REGEA
    move.l  REGEA,REGMEA
    move.b  2(REGMEA),-(SP)     ; pull PChi
    move.w  (SP)+,REGPC
    move.b  1(REGMEA),REGPC     ; pull PClo
    addq.b  #2,REGSP
    addq.w  #1,REGPC
    move.l  REGPC,REGMPC
    DISPATCH

 ; ADC (zp,X)
  op61:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    bra     doADCchk

 ; ADC (zp,X)
  op61dec:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doADCdecchk

 ; ADC zp
  op65:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doADC

 ; ADC zp
  op65dec:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doADCdec

 ; ROR zp
  op66:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doROR

 ; PLA
  op68:
    addq.b  #1,REGSP
    move.w  REGSP,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; ADC #
  op69:
    move.b  (REGMPC)+,DBUS
    ori.b   #BITZ,REGST
    move.b  REGST,CCR
    addX.b  DBUS,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITV|BITX),DBUS
    and.b   #~(BITN|BITZ|BITV|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; ADC #
  op69dec:
    move.b  (REGMPC)+,DBUS
    ori.b   #BITZ,REGST
    move.b  REGST,CCR
    ABCD    DBUS,REGA           ; decimal add
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITV|BITX),DBUS
    and.b   #~(BITN|BITZ|BITV|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; ROR A
  op6A:
    move.b  REGST,CCR           ; prepare carry bit
    ROXR.b  #1,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX),DBUS
    and.b   #~(BITN|BITZ|BITX),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; JMP (abs)
  op6C:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGPC
    move.b  (REGMPC),REGPC
    move.w  REGPC,REGEA         ; get vector
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGPC
    move.b  (REGMEA),REGPC
    move.l  REGPC,REGMPC
    DISPATCH

 ; ADC abs
  op6D:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doADCchk

 ; ADC abs
  op6Ddec:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doADCdecchk

 ; ROR abs
  op6E:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doRORchk

 ; BVS
  op70:
    btst    #1,REGST
    beq.s   nobvs               ; BITV = 0x02 = bit #1
    move.b  (REGMPC)+,DBUS
    ext.w   DBUS
    adda.w  DBUS,REGMPC
    DISPATCH
  nobvs:
    addq.l  #1,REGMPC
    DISPATCH

 ; ADC (zp),Y
  op71:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    bra     doADCchk

 ; ADC (zp),Y
  op71dec:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    bra     doADCdecchk

 ; ADC zp,X
  op75:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doADC

 ; ADC zp,X
  op75dec:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doADCdec

 ; ROR zp,X
  op76:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doROR

 ; SEI
  op78: ori.b   #BITI,REGST
    DISPATCH

 ; ADC abs,Y
  op79:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doADCchk

 ; ADC abs,Y
  op79dec:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doADCdecchk

 ; ADC abs,X
  op7D:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doADCchk

 ; ADC abs,X
  op7Ddec:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doADCdecchk

 ; ROR abs,X
  op7E:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doRORchk

 ; STA (zp,X)
  op81:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    bra     doSTAchk

 ; STY zp
  op84:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  REGY,(REGMEA)
    DISPATCH

 ; STA zp
  op85:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  REGA,(REGMEA)
    DISPATCH

 ; STX zp
  op86:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  REGX,(REGMEA)
    DISPATCH

 ; DEY
  op88:
    subq.b  #1,REGY
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; TXA
  op8A:
    move.b  REGX,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; STY abs
  op8C:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doSTYchk

 ; STA abs
  op8D:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doSTAchk

 ; STX abs
  op8E:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doSTXchk

 ; BCC
  op90:
    btst    #4,REGST
    bne.s   nobcc               ; BITX = 0x10 = bit #4
    move.b  (REGMPC)+,DBUS
    ext.w   DBUS
    adda.w  DBUS,REGMPC
    DISPATCH
  nobcc:
    addq.l  #1,REGMPC
    DISPATCH

 ; STA (zp),Y
  op91:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    bra     doSTAchk

 ; STY zp,X
  op94:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  REGY,(REGMEA)
    DISPATCH

 ; STA zp,X
  op95:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  REGA,(REGMEA)
    DISPATCH

 ; STX zp,Y
  op96:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGY,REGEA
    move.l  REGEA,REGMEA
    move.b  REGX,(REGMEA)
    DISPATCH

 ; TYA
  op98:
    move.b  REGY,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; STA abs,Y
  op99:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doSTAchk

 ; TXS
  op9A:
    move.b  REGX,REGSP
    DISPATCH

 ; STA abs,X
  op9D:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doSTAchk

 ; LDY #
  opA0:
    move.b  (REGMPC)+,REGY
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; LDA (zp,X)
  opA1:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    bra     doLDAchk

 ; LDX #
  opA2:
    move.b  (REGMPC)+,REGX
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; LDY zp
  opA4:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),REGY
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; LDA zp
  opA5:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; LDX zp
  opA6:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),REGX
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; TAY
  opA8:
    move.b  REGA,REGY
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; LDA #
  opA9:
    move.b  (REGMPC)+,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; TAX
  opAA:
    move.b  REGA,REGX
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; LDY abs
  opAC:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doLDYchk

 ; LDA abs
  opAD:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doLDAchk

 ; LDX abs
  opAE:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doLDXchk

 ; BCS
  opB0:
    btst    #4,REGST
    beq.s   nobcs               ; BITX= 0x10 = bit #4
    move.b  (REGMPC)+,DBUS
    ext.w   DBUS
    adda.w  DBUS,REGMPC
    DISPATCH
  nobcs:
    addq.l  #1,REGMPC
    DISPATCH

 ; LDA (zp),Y
  opB1:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    bra     doLDAchk

 ; LDY zp,X
  opB4:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doLDY

 ; LDA zp,X
  opB5:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doLDA

 ; LDX zp,Y
  opB6:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGY,REGEA
    bra     doLDX

 ; CLV
  opB8: andi.b  #~BITV,REGST
    DISPATCH

 ; LDA abs,Y
  opB9:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doLDAchk

 ; TAX
  opBA:
    move.b  REGSP,REGX
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; LDY abs,X
  opBC:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doLDYchk

 ; LDA abs,X
  opBD:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doLDAchk

 ; LDX abs,Y
  opBE:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doLDXchk

 ; CPY #
  opC0:
    move.b  (REGMPC)+,DBUS
    bra     doCPY

 ; CMP (zp,X)
  opC1:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCMP

 ; CPY zp
  opC4:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCPY

 ; CMP zp
  opC5:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCMP

 ; DEC zp
  opC6:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doDEC

 ; INY
  opC8: addq.b  #1,REGY
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; CMP #
  opC9:
    move.b  (REGMPC)+,DBUS
    bra     doCMP

 ; DEX
  opCA:
    subq.b  #1,REGX
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; CPY abs
  opCC:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCPY

 ; CMP abs
  opCD:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCMP

 ; DEC abs
  opCE:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doDECchk

 ; BNE
  opD0:
    btst    #2,REGST
    bne.s   nobne               ; BITZ = 0x04 = bit #2
    move.b  (REGMPC)+,DBUS
    ext.w   DBUS
    adda.w  DBUS,REGMPC
    DISPATCH
  nobne:
    addq.l  #1,REGMPC
    DISPATCH

 ; CMP (zp),Y
  opD1:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCMP

 ; CMP zp,X
  opD5:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCMP

 ; DEC zp,X
  opD6:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doDEC

 ; CLD
  opD8:
    andi.b  #~BITD,REGST
    lea     vec_6502(GLOBAL),REGOPS     ; pointer to opcode table
    DISPATCH

 ; CMP abs,Y
  opD9:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCMP

 ; CMP abs,X
  opDD:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCMP

 ; DEC abs,X
  opDE:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doDECchk

 ; CPX #
  opE0:
    move.b  (REGMPC)+,DBUS
    bra     doCPX

 ; SBC (zp,X)
  opE1:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    bra     doSBCchk

 ; SBC (zp,X)
  opE1dec:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    bra     doSBCdecchk

 ; CPX zp
  opE4:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCPX

 ; SBC zp
  opE5:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doSBC

 ; SBC zp
  opE5dec:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doSBCdec

 ; INC zp
  opE6:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    bra     doINC

 ; INX
  opE8:
    addq.b  #1,REGX
    move.w  SR,DBUS
    and.b   #(BITN|BITZ),DBUS
    and.b   #~(BITN|BITZ),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; SBC #
  opE9:
    move.b  (REGMPC)+,DBUS
    eori.b  #BITX,REGST
    ori.b   #BITZ,REGST
    move.b  REGST,CCR
    subx.b  DBUS,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX|BITV),DBUS
    eori.b  #BITX,DBUS
    and.b   #~(BITN|BITZ|BITX|BITV),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; SBC #
  opE9dec:
    move.b  (REGMPC)+,DBUS
    eori.b  #BITX,REGST
    ori.b   #BITZ,REGST
    move.b  REGST,CCR
    sbcd    DBUS,REGA
    move.w  SR,DBUS
    and.b   #(BITN|BITZ|BITX|BITV),DBUS
    eori.b  #BITX,DBUS
    and.b   #~(BITN|BITZ|BITX|BITV),REGST
    or.b    DBUS,REGST
    DISPATCH

 ; CPX abs
  opEC:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    move.l  REGEA,REGMEA
    move.b  (REGMEA),DBUS
    bra     doCPX

 ; SBC abs
  opED:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doSBCchk

 ; SBC abs
  opEDdec:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doSBCdecchk

 ; INC abs
  opEE:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    addq.w  #2,REGMPC
    bra     doINCchk

 ; BEQ
  opF0:
    btst    #2,REGST
    beq.s   nobeq               ; BITZ = 0x04 = bit #2
    move.b  (REGMPC)+,DBUS
    ext.w   DBUS
    adda.w  DBUS,REGMPC
    DISPATCH
  nobeq:
    addq.l  #1,REGMPC
    DISPATCH

 ; SBC (zp),Y
  opF1:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    bra     doSBCchk

 ; SBC (zp),Y
  opF1dec:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    move.l  REGEA,REGMEA
    move.b  1(REGMEA),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMEA),REGEA
    add.w   REGY,REGEA
    bra     doSBCdecchk

 ; SBC zp,X
  opF5:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doSBC

 ; SBC zp,X
  opF5dec:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doSBCdec

 ; INC zp,X
  opF6:
    clr.w   REGEA
    move.b  (REGMPC)+,REGEA
    add.b   REGX,REGEA
    bra     doINC

 ; SED
  opF8:
    ori.b   #BITD,REGST
    lea     dec_6502(GLOBAL),REGOPS     ; pointer to table of dec opcodes
    DISPATCH

 ; SBC abs,Y
  opF9:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doSBCchk

 ; SBC abs,Y
  opF9dec:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGY,REGEA
    addq.w  #2,REGMPC
    bra     doSBCdecchk

 ; SBC abs,X
  opFD:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doSBCchk

 ; SBC abs,X
  opFDdec:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doSBCdecchk

 ; INC abs,X
  opFE:
    move.b  1(REGMPC),-(SP)
    move.w  (SP)+,REGEA
    move.b  (REGMPC),REGEA
    add.w   REGX,REGEA
    addq.w  #2,REGMPC
    bra     doINCchk
  }
}

