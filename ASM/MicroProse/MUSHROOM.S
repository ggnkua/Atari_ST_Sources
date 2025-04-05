
*********************************************************
*** MUSHROOM.TOS by Silas Warner, MicroProse Software ***
*********************************************************
*    This is the source for a program
*    that interprets the "post-mortem
*    buffer" that the Atari ST creates
*    when the system crashes. This
*    buffer is saved through RESETS
*    until you turn the computer off.
*    Press RESET and use this program
*    when the screen fills with
*    "mushrooms" and the computer dies.
*

*To assemble this program, type
*AS68 -l MUSHROOM.S
*LINK68 MUSHROOM
*RELMOD MUSHROOM.68K MUSHROOM.TOS
*then remove MUSHROOM.O and MUSHROOM.68K.

*APSTART chunk to set stack and memory
start  bra start1

title  dc.b 27,72,"+-------------------------------------+"
  dc.b 13,10,"!       THE MUSHROOM ANALYZER         !"
  dc.b 13,10,"! by Silas Warner,MicroProse Software !"
  dc.b 13,10,"+-------------------------------------+"
  dc.b 13,10,0
  even

start1  move.l sp,a5
  move.l #ustk,sp 
  move.l 4(a5),a5
  move.l $c(a5),d0
  add.l $14(a5),d0
  add.l $1c(a5),d0
  add.l #$100,d0
  move.l d0,-(sp) *set up m-f call
  move.l a5,-(sp)
  move.w #0,-(sp)
  move.w #$4a,-(sp)
  trap #1    *do m-f call
  addq.l #4,sp
  move.l (sp)+,a5    *recover basepage
  addq.l #4,sp
*NOW THE PROGRAM STARTS
  lea.l start(pc),a5  *set PBR
   lea.l ustk,sp  *use our own stack
*Okay, grab mushroom buffer!
startup  lea.l title,a0  *Found above
  jsr wstring
  jsr supmode  *Slam into super mode
  move.l #$380,a0  *recover the mushroom save area
  lea.l savest,a1  *to our own area for examination
msurup  move.l (a0)+,(a1)+ *Move it fast and long
  cmpa.l #saveend,a1
  bne msurup  
  jsr usrmode  *Now back to user mode
  move.l savest,d0 *Is there a mushroom in memory?
  cmp.l #$12345678,d0 *Magic number set by Atari
  beq wasmush  *Is there a mushroom?
  lea.l nomush,a0  *"NO MUSHROOM IN MEMORY"
  jsr wstring
progwat  lea.l presret,a0 *"--Press RETURN--"
  jsr wstring
  jsr rdchar  *wait for a RETURN key.
  cmp.b #$0d,d0  *Is it RETURN?
  bne progwat  *Nope, try again.
progend  clr.w -(sp)  *end program
  trap #1    *we gone!
wasmush  lea.l mushtit,a0 * "LAST MUSHROOM WAS #"
  jsr wstring
  move.b saveex,d1 *Exception #
  jsr hexbyte  *Print it
  move.b #":",d1
  jsr wrchar
  lea.l errtbl,a0  *Interpret error
  move.b saveex,d1 *Using lower byte of exception #
errloop  move.b (a0)+,d0  *lower limit
  move.b (a0)+,d2  *upper limit
  cmp.b d1,d0  *Below lower limit?
  bhi errskip  *Yes, skip it
  cmp.b d1,d2  *Below or = upper limit?
  bcc errprnt  *Yes, print it
errskip  tst.b (a0)+  *skip to zero byte
  bne errskip
  beq errloop  *and try next entry
errprnt  jsr wstring  *print message!
  lea.l mushreg,a0  *"  Registers"
  jsr wstring
  clr.l d7  *d7 is register #
dline  lea.l mushdr,a0 *" d"
  jsr wstring
  move.b d7,d1  *print reg #
  or.b #"0",d1
  jsr wrchar
  move.b #"=",d1
  jsr wrchar
  move.l d7,d2  *Get reg
  asl.w #2,d2  *indexed by longword
  lea.l saved0,a0  *from saved D-regs
  move.l 0(a0,d2.w),d1
  jsr hexlong  *and print it
  lea.l mushar,a0  *  a"
  jsr wstring
  move.b d7,d1  *print reg #
  or.b #"0",d1
  jsr wrchar
  move.b #"=",d1
  jsr wrchar
  move.l d7,d2  *Get reg
  asl.w #2,d2  *Indexed by longword
  lea.l savea0,a0  *from saved A-regs
  move.l 0(a0,d2.w),d1
  jsr hexlong  *and print it
  addq.l #1,d7  *go to next reg index
  cmp.b #8,d7  *All regs done?
  bne dline  *No, loop back
  move.w saveex+2,d3 *get saved CCR
  lea.l flagm,a0  *Start to print flags
  jsr wstring
  lea traoff,a0  *Trace flag
  btst #15,d3
  beq traprt
  lea traon,a0
traprt  jsr wstring
  jsr dospace
  lea.l supoff,a0  *User/Super flag
  btst #13,d3
  beq supprt
  lea supon,a0
supprt  jsr wstring
  jsr dospace
  lea negoff,a0  *N flag
  btst #3,d3
  beq negprt
  lea negon,a0
negprt  jsr wstring
  lea zeroff,a0  *Z flag
  btst #2,d3
  beq zerprt
  lea zeron,a0
zerprt  jsr wstring
  jsr dospace
  lea extoff,a0  *X flag
  btst #4,d3
  beq extprt
  lea exton,a0
extprt  jsr wstring
  jsr dospace
  lea ovroff,a0  *V flag
  btst #1,d3
  beq ovrprt
  lea ovron,a0
ovrprt  jsr wstring
  jsr dospace
  lea.l caroff,a0  *C flag
  btst #0,d3
  beq carprt
  lea.l caron,a0
carprt  jsr wstring
  lea.l mushstk,a0 *"STACKS:User="
  jsr wstring
  move.l saveusp,d1 *User stack ptr
  jsr hexlong  *print it
  lea.l mushst2,a0 *    Super="
  jsr wstring
  move.l savea7,d1  *Super stack ptr
  jsr hexlong  *Print it
  lea.l savestk,a4 *start to print stack
  move.l savea7,a3 *with loc it came from
savestl  jsr newline
  move.l a3,d1  *Saved stack addr
  jsr hexlong  *Print it
  move.b #":",d1
  jsr wrchar
  jsr dospace
  move.l (a4)+,d1  *Saved stack contents
  jsr hexlong  *Print it
  addq.l #4,a3  *Inc stack address
  cmpa.l #saveend,a4 *We at end of saved stack?
  bne savestl  *Nope, back for more
  jmp progwat  *Go back and wait for RETURN

*print a hex word to screen or printer
hexlong  move.l d1,-(sp)
  swap d1
  jsr hexword
  move.l (sp)+,d1
hexword  move.w d1,-(sp)  *thanks to Jez San
  lsr.w #8,d1
  lsr.w #4,d1
  bsr.s hxpnibbl  *1st nybble
  move.w (sp),d1
  lsr.w #8,d1
  bsr.s hxpnibbl  *2nd nybble
  move.w (sp)+,d1
hexbyte  move.w d1,-(sp)
  lsr.w #4,d1
  bsr.s hxpnibbl  *3rd nybble
  move.w (sp)+,d1
hxpnibbl
  and.w #15,d1  *finally print out ONE hex digit!
  cmp.b #9,d1
  bls.s hxpnib2
  add.b #7,d1
hxpnib2  add.b #"0",d1
  bra wrchar

*getchar - Get key without echo and without waiting!
*          Exit, d0.b is key, or zero if no key ready
getchar  movem.l a0-a6/d1-d7,-(sp)
  move.w #$0b,-(sp)
  trap #1
  addq.l #2,sp
  tst.l d0  *is there a key?
  bmi.s rdchq
  movem.l (sp)+,a0-a6/d1-d7
  clr.l d0  NO,return zero
  rts

*rdchar  - Wait fpr a key (no echo)
*          Exit, d0.b is key
rdchar  movem.l a0-a6/d1-d7,-(sp)
rdchq  move.w #$07,-(sp)
  trap #1    *call DOS which returns 2 bytes
  addq.l #2,sp  *in lower & upper word of d0
  movem.l (sp)+,a0-a6/d1-d7
  tst.w d0  *is lower word zero?
  bne tsttop  *no, return upper word
lswap  swap d0    *get upper if zero
rdora  or.b #$80,d0  *set high bit
rdout  and.l #$ff,d0  *of lower byte only!
rdrts  rts    *and return
tsttop  swap d0    *lower word nonzero
  cmp.w #$44,d0  *if upper out of range
  bcs bswap  *go to swap lower back
  cmp.w #$54,d0  *same if above range
  bls lswap  *if in range lower word or #$80
bswap  swap d0    *if out of range, lower word!
  bra rdout

*wstring - Print a string to the screen (up to zero byte)
*          Entry, a0 =address of string
wstring  movem.l a1-a6/d0-d7,-(sp)
  move.l a0,-(sp)
  move.w #$09,-(sp)
  trap #1
  addq.l #2,sp
  move.l (sp)+,a0
  movem.l (sp)+,a1-a6/d0-d7
  rts

*dospace - Print one space
*          Exit, d1 = #32 (SPACE)
dospace  move.w #32,d1  *and fall thru to

*wrchar  - Print a character to the screen
*          Entry, d1 =character to print
wrchar  movem.l d0-d7/a0-a6,-(sp)
  move.w d1,-(sp)
  move.w #2,-(sp)
  trap #1
  addq.l #4,sp
  movem.l (sp)+,d0-d7/a0-a6
  rts

*newline - Print a CR and LF
*          Exit, d1 = #10 (LF)
newline  move.w #13,d1
  bsr wrchar
  move.w #10,d1
  bra wrchar

supstak  dc.l 0

*Slip into super mode to get system vars
supmode  movem.l a0-a6/d0-d7,-(sp)  *save regs
  tst.l supstak  *Has supmode been called?
  bne superet  *You ARE in sup mode, turkey!
  clr.l -(sp)
  move.w #32,-(sp)
  trap #1    *call the supertrap
  move.l d0,supstak *and save systack
  addq.l #6,sp  *correct stack ptr
superet  movem.l (sp)+,a0-a6/d0-d7  *restore regs
  rts

*Return from super mode to user mode
usrmode  movem.l a0-a6/d0-d7,-(sp)  *save regs
  tst.l supstak  *Has supmode been called?
  beq useret  *You ARE in user mode, fool!
  move.l supstak,-(sp)
  move.w #32,-(sp)
  trap #1    *call the supertrap
  clr.l supstak  *clear the systack save
  addq.l #6,sp  *correct stack ptr
useret  movem.l (sp)+,a0-a6/d0-d7  *restore regs
  rts

*DATA segment
  .data
nomush  dc.b 13,10,"NO MUSHROOMS IN MEMORY!"
  dc.b 13,10,0
mushtit  dc.b "LAST MUSHROOM:#",0
mushat  dc.b " AT ",0
mushreg  dc.b 13,10,"       Registers        ",0
mushdr  dc.b 13,10," d",0
mushar  dc.b "  a",0
mushstk  dc.b 13,10,"Stacks: User=",0
mushst2  dc.b " Super=",0
errtbl  dc.b 0,0,"Reset ROM destroyed!",0
  dc.b 1,1,"Processor Error!",0
  dc.b 2,2,"Bus Error.",0
  dc.b 3,3,"Address Error.",0
  dc.b 4,4,"Illegal Instruction.",0
  dc.b 5,5,"Divide by Zero.",0
  dc.b 6,6,"CHK Out of Bounds.",0
  dc.b 7,7,"Overflow Trap.",0
  dc.b 8,8,"Super-Mode Violation.",0
  dc.b 9,9,"Trace Not On.",0
  dc.b 10,10,"Line-A Code Clobbered.",0
  dc.b 11,11,"Line-F Code Clobbered.",0
  dc.b 12,14,"Unknown Interrupt.",0
  dc.b 15,15,"Bad Interrupt Vector.",0
  dc.b 16,23,"Unknown Interrupt.",0
  dc.b 24,24,"Spurious Interrupt.",0
  dc.b 25,31,"Hardware Interrupt.",0
  dc.b 32,47,"Unknown TRAP.",0
  dc.b 48,63,"Unknown Interrupt.",0
  dc.b 64,255,"Interrupt Instruction.",0
flagm  dc.b 13,10,"Flags:"
traoff  dc.b "   ",0
traon  dc.b "Trc",0
supoff  dc.b "Usr",0
supon  dc.b "Sup",0
extoff  dc.b "Xc",0
exton  dc.b "Xs",0
negoff  dc.b "+",0
negon  dc.b "-",0
zeroff  dc.b " ",0
zeron  dc.b "0",0
ovroff  dc.b "Vc",0
ovron  dc.b "Vs",0
caroff  dc.b "Cc",0
caron  dc.b "Cs",0
presret  dc.b 13,10,"--Press RETURN.--",0
  even

*BSS segment
  .bss
  even
  ds.l 256 *256 stacks
ustk  ds.l 1
savest  ds.l 1  *must be $12345678
saved0  ds.l 1  *D regs begin here
saved1  ds.l 1
saved2  ds.l 1
saved3  ds.l 1
saved4  ds.l 1
saved5  ds.l 1
saved6  ds.l 1
saved7  ds.l 1
savea0  ds.l 1  *A regs begin here
savea1  ds.l 1
savea2  ds.l 1
savea3  ds.l 1
savea4  ds.l 1
savea5  ds.l 1
savea6  ds.l 1
savea7  ds.l 1
saveex  ds.l 1  *exception #, long-255
saveusp  ds.l 1  *usp
savestk  ds.l 8  *stack popped
saveend  ds.l 1  *end of save area
  even

*********************
  end
