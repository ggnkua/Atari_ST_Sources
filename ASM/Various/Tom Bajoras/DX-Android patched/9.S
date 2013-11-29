;*****************************************************************************;
;   module 9 source file Copyright 1986 Tom Bajoras
;   bank menu command processors:
;      initwb,savebnk,usebank,scrbank,listbnk,execbnk,unnmbnk,namebnk,
;      fetchb,gobank,scrallb
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION nine,code

;*****************************************************************************;
;   initwb
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF initwb

 XREF movemem
 XREF movename
 XREF setdx7
 XREF blnkln
 XREF writfdx7
 XREF writdx7
 XREF wbtosyn
 XREF inkey
 XREF line
 XREF outchar
 XREF unsetdx7
 XREF hardtext
 XREF bell
 XREF getkey
 XREF encode
 XREF message
 XREF setcolor
 XREF blnkscr
 XREF filtowb
 XREF readbnk
 XREF writbnk
 XREF wbtofil

initwb   movem.l  D0-A6,-(a7)   ; save registers
   move.l   x1,-(a7)    ; save x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   clr.b    d0     ; # of slots initialized
   move.l   #initsnd,x1
   move.l   #wkbank,x2
   move.b   #160,x3

.1    jsr   movemem   ; initialize w.b. slots
   addq.b   #1,d0
   cmpi.b   #32,d0
   beq   .2
   add.l    #160,x2
   bra   .1

.2    clr.b    d0     ; # of slot names initialized
   move.l   #initname,x1
   move.l   #wkbname,x2
   move.b   #10,x3

.3    jsr   movemem   ; initialize w.b. slot names
   addq.b   #1,d0
   cmpi.b   #32,d0
   beq   .4
   add.l    #10,x2
   bra   .3

.4    move.l   (a7)+,x3   ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6  ; restore registers
   rts        ; return

;*****************************************************************************;
;   savebnk
;      x1.b = bankx = 1-maxbank
;*****************************************************************************;

 XDEF savebnk

savebnk  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   jsr   wbtofil   ; copy w.b. to file buffer
   jsr   writbnk   ; write file buffer to disk
   tst.b    y1     ; if anything went wrong don't update
   bne   .return   ; info tables

   clr.l    d0
   move.b   x1,d0
   subq.b   #1,d0     ; d0 = bankx -1
   lea   bankflg,a0   ; a0 --> bank existence flags
   tst.b    0(a0,d0.l)   ; already exists?
   bne   .2

   move.b   #1,0(a0,d0.l)   ; new bank: set existence flag
   addq.b   #1,nbanks    ; increment # of banks on disk
   lea   bnamflg,a0
   clr.b    0(a0,d0.l)   ; clear name
   lea   banknam,a0
   mulu  #10,d0
   adda.l   d0,a0     ; a0 --> this bank's name
   moveq    #10,d1
.1    move.b   ascisp,(a0)+ ; space fill bank's name
   subq.b   #1,d1
   bgt   .1
   mulu  #32,d0
   bra   .3

.2    mulu  #320,d0
.3    move.l   #bslotnm,x2
   add.l    d0,x2
   move.l   #wkbname,x1
   move.b   #160,x3   ; copy w.b. slot names to bank
   jsr   movemem   ; slot names
   add.l    #160,x1
   add.l    #160,x2   ; requires two passes
   jsr   movemem

.return  move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   usebank
;      x1.b = bankx = 1-maxbank
;*****************************************************************************;

 XDEF usebank

usebank  move.l   d0,-(a7) ; save d0,x1,x2,x3
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   jsr   readbnk  ; read specified bank into file buffer
   tst.b    y1
   bne   .return  ; if anything went wrong, do not update
   jsr   filtowb  ; info tables or do anything else

   clr.l    d0
   move.b   x1,d0
   subq.b   #1,d0
   mulu  #320,d0
   move.l   #bslotnm,x1
   add.l    d0,x1
   move.l   #wkbname,x2
   move.b   #160,x3
   jsr   movemem  ; copy bank slot names to w.b. slot names
   add.l    #160,x1
   add.l    #160,x2  ; must be done in two passes
   jsr   movemem

.return  move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1 ; restore x3-x1
   move.l   (a7)+,d0 ; and d0
   rts      ; return

;*****************************************************************************;
;   scrbank
;      x1.b = bankx = 1-maxbank
;*****************************************************************************;

 XDEF scrbank

scrbank  movem.l  D0-A6,-(a7) ; save registers
   clr.l    d0
   move.b   x1,d0
   subq.b   #1,d0     ; d0.l = bankx -1
   subq.b   #1,nbanks    ; decrement # banks
   lea   bankflg,a0
   clr.b    0(a0,d0.l)   ; clear bank flag
   lea   bnamflg,a0
   clr.b    0(a0,d0.l)   ; clear bank name flag
   mulu  #10,d0
   lea   banknam,a0
   adda.l   d0,a0     ; a0 --> this bank's name

   moveq    #10,d2    ; for d2 = 9 to 0
.2    subq.l   #1,d2
   blt   .3
   move.b   ascisp,(a0)+ ; space-fill bank name
   bra   .2

.3    mulu  #32,d0
   lea   bslotnm,a0
   adda.l   d0,a0     ; a0 --> slot names in this bank

   move.l   #320,d2   ; for d2 = 319 to 0
.4    subq.l   #1,d2
   blt   .5
   move.b   ascisp,(a0)+ ; space-fill all slot names
   bra   .4

.5    movem.l  (a7)+,D0-A6 ; restores registers
   rts       ; return

;*****************************************************************************;
;   listbnk
;      x1.b = bankx = 1-maxbank
;*****************************************************************************;

 XDEF listbnk

listbnk  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   jsr   blnkscr  ; start with a blank screen
   clr.l    d7
   move.b   x1,d7    ; d7.l = bankx (1-maxbank)
   move.b   #7,x1    ; set colors
   jsr   setcolor

   move.l   #locmess,x1    ; menu
   move.b   #10,x2
   move.b   ymax,x3
   subq.b   #1,x3
   move.b   cmenu,x4
   lea   locmesl,a0
   move.b   (a0),x5
   jsr   message
   add.l    #30,x1
   addq.b   #1,x3
   move.b   1(a0),x5
   jsr   message
   add.l    #30,x1
   move.b   xmax,x2
   sub.b    #30,x2
   move.b   ymax,x3
   subq.b   #1,x3
   move.b   2(a0),x5
   jsr   message
   add.l    #30,x1
   addq.b   #1,x3
   move.b   3(a0),x5
   jsr   message

.bigloop move.l   #bnkmess,x1
   lea   bnkmesl,a6
   move.b   (a6),x5
   move.b   xmax,d0
   sub.b    (a6),d0
   lsr.b    #1,d0
   addq.b   #1,d0
   move.b   d0,x2
   move.b   #1,x3
   move.b   cmenhed,x4
   jsr   message   ; heading
   move.b   x5,d0
   add.b    d0,x2
   addq.b   #1,x2
   move.b   #2,x5
   move.w   d7,x1
   jsr   encode
   move.l   #namebuf,x1
   jsr   message   ; append bank #

   move.l   d7,d0
   subq.l   #1,d0
   mulu  #320,d0
   lea   bslotnm,a0
   add.l    d0,a0
   lea   bankkeyn,a1
   addq.l   #1,a1     ; a1 --> numerical bankkeys
   clr.l    d1
   move.b   xmax,d1
   sub.b    #26,d1
   divu  #3,d1     ; d1 = tab

   move.b   #3,x3     ; start y-coord
   move.b   d1,d2     ; x-coord for 1st column

   clr.b    d0

.1    move.l   a1,x1
   addq.l   #5,a1
   move.b   d2,x2
   move.b   cmenkey,x4
   move.b   #2,x5
   jsr   message   ; bank key

   addq.b   #3,x2
   move.l   a0,x1
   move.b   cmenu,x4
   move.b   #10,x5
   jsr   message   ; slot name

   add.l    #10,a0
   addq.b   #1,d0
   cmpi.b   #32,d0    ; done?
   beq   .keyloop
   cmpi.b   #16,d0    ; done with first column?
   beq   .2

   addq.b   #1,x3     ; increment y-coord
   bra   .1

.2    add.b    #13,d2
   add.b    d1,d2     ; x-coord for 2nd column
   move.b   #3,x3     ; restart y-coord
   bra   .1

.keyloop jsr   getkey    ; get a key
   move.b   y1,d0     ; hardcopy?
   cmp.b    ascihelp,d0
   beq   .hard
   cmp.b    ascicr,d0
   beq   .return
   cmp.b    ascin,d0
   beq   .next
   cmp.b    ascip,d0
   beq   .previous
   jsr   bell
   bra   .keyloop
.hard    move.b   #18,x1
   jsr   hardtext
   bra   .keyloop
.next    addq.l   #1,d7
   cmp.b    maxbank,d7
   ble   .nextx
   moveq    #1,d7
.nextx   lea   bankflg,a0
   subq.l   #1,a0
   tst.b    0(a0,d7.l)
   bne   .bigloop
   bra   .next
.previous   subq.l   #1,d7
   bgt   .prevx
   clr.l    d7
   move.b   maxbank,d7
.prevx   lea   bankflg,a0
   subq.l   #1,a0
   tst.b    0(a0,d7.l)
   bne   .bigloop
   bra   .previous
.return  move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   execbnk
;      x1.b = 0 with f-pars, =1 without f-pars, =0 only f-pars
;*****************************************************************************;

 XDEF execbnk

execbnk  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; save x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)  ; un-set-up dx7:
   jsr   unsetdx7

   clr.l    d7     ; d7.l = exec mode
   move.b   x1,d7

   jsr   blnkscr   ;  start with a blank screen
   move.b   #9,x1     ;  change colors
   jsr   setcolor

   lea   bnkmesl,a6   ; a6--> bank message lengths
   move.b   xmax,d0
   sub.b    2(a6),d0
   lsr.b    #1,d0     ; center title
   move.b   d0,x2
   move.l   #bnkmess,x1
   add.l    #80,x1
   move.b   #1,x3
   move.b   cmenhed,x4
   move.b   2(a6),x5
   jsr   message

   move.l   #wkbname,a1  ; a1--> w.b. names
   lea   wkbnx,a2  ; a2--> x-coords for w.b. names
   lea   bankkey,a3   ; a3--> bankkeys
   lea   bankkeyn,a4  ; a4--> bankkeys, numerically

   moveq    #4,d0    ; d0.b = 4 to 1
.loop2   move.b   #3,x3
   move.b   (a2)+,d3 ; d3 = x-coord for w.b. names in this col
   moveq    #8,d1    ; for d1.b = 8 to 1
.loop1   move.l   a1,x1
   add.l    #10,a1
   move.b   d3,x2
   move.b   cmenu,x4
   move.b   #10,x5
   jsr   message
   move.l   a4,x1
   addq.l   #5,a4
   subq.b   #5,x2
   move.b   cmenkey,x4
   move.b   #4,x5
   jsr   message  ; bank key numerically
   move.b   (a3)+,x1
   subq.b   #2,x2
   jsr   outchar  ; bank key
   addq.b   #1,x3
   subq.b   #1,d1
   bne   .loop1
   subq.b   #1,d0
   bne   .loop2

   clr.w    x1
   move.w   #106,x2
   move.w   #639,x3
   move.w   #106,x4
   move.b   coutlne,x5
   jsr   line

   move.l   #bnkmess,x1
   move.l   d7,d0
   add.l    #10,d0
   mulu  #40,d0
   add.l    d0,x1
   move.b   10(a6,d7.l),x5
   move.b   xmax,d0
   sub.b    x5,d0
   lsr.b    #1,d0
   move.b   d0,x2
   move.b   #15,x3
   move.b   cmessge,x4
   jsr   message   ; inform exwb mode

   move.l   #bnkmess,x1
   add.l    #520,x1
   move.b   #16,x3
   move.b   13(a6),x5
   jsr   message   ; 'esc to change exwb mode'

   clr.w    x1
   move.w   #130,x2
   move.w   #639,x3
   move.w   #130,x4
   move.b   coutlne,x5
   jsr   line

   move.b   xmax,d0
   sub.b    3(a6),d0  ; sort of center this stuff
   lsr.b    #1,d0
   move.b   d0,x2

   move.l   #bnkmess,x1
   add.l    #560,x1
   move.b   #20,x3
   move.b   cmenhed,x4
   move.b   14(a6),x5
   jsr   message   "menu:"

   move.l   #bnkmess,x1
   add.l    #120,x1
   move.b   #22,x3
   move.b   cmessge,x4
   move.b   3(a6),x5
   jsr   message   ; "1-9,0,A-V"

   move.l   #bnkmess,x1
   add.l    #320,x1
   move.b   #23,x3
   move.b   8(a6),x5
   jsr   message   ; "step forward"

   move.l   #bnkmess,x1
   add.l    #360,x1
   move.b   #24,x3
   move.b   9(a6),x5
   jsr   message   ; "step backward"

   move.l   #bnkmess,x1
   add.l    #160,x1
   move.b   ymax,x3
   move.b   4(a6),x5
   jsr   message   ; "cr to return to bank menu"

   clr.b    d6     ; set current slot = 0

   move.l   midiaddr,a4
   move.l   kbaddr,a5
.input   tst.b    thruflag
   bne   .input2
   clr.w    6(a4)     ; reset midi & kb buffers
   clr.w    8(a4)
.input2  clr.w    6(a5)
   clr.w    8(a5)
.inloop  tst.b    thruflag
   bne   .inloop2
   move.w   8(a4),d0
   cmp.w    6(a4),d0  ; midi buffer empty?
   bne   .dx7
.inloop2 move.w   8(a5),d0
   cmp.w    6(a5),d0  ; kb buffer non-empty?
   beq   .inloop
   bra   .st

.dx7  move.w   #3,-(a7)
   move.w   #2,-(a7)
   trap  #13
   addq.l   #4,a7
   andi.b   #$F0,d0  ; accept any MIDI channel (modified synth?)
   cmpi.b   #$B0,d0  ; ignore anything other than yes/no
   bne   .inloop
   move.w   #3,-(a7)
   move.w   #2,-(a7)
   trap  #13    ; get second byte
   addq.l   #4,a7
   cmpi.b   #$60,d0    ; yes?
   beq   .forward
   cmpi.b   #$61,d0    ; no?
   beq   .backwrd
   bra   .input

.st   jsr   inkey     ; get ST key
   move.b   y1,d0     ; d0.b = key
   cmp.b    ascisp,d0
   beq   .forward
   cmp.b    ascibs,d0
   beq   .backwrd
   cmp.b    ascicr,d0
   beq   .return
   cmp.b    asciesc,d0
   beq   .esc
   move.w   #32,d5    ; d5 = 32 to 1
   lea   bankkey,a0
   subq.l   #1,a0
.keyloop cmp.b    0(a0,d5.w),d0
   beq   .new
   subq.w   #1,d5
   bgt   .keyloop
   jsr   bell
   bra   .input

.forward move.w   #1,d5
   tst.b    d6
   beq   .new
   move.b   d6,d5
   addq.b   #1,d5
   cmpi.b   #33,d5
   blt   .new
   move.b   #1,d5     ; wrap around
   bra   .new
.backwrd move.w   #32,d5
   tst.b    d6
   beq   .new
   move.b   d6,d5
   subq.b   #1,d5
   cmpi.b   #0,d5
   bgt   .new
   move.b   #32,d5    ; wrap around

; d5.b = new slot (1-32), d6 = old slot (0-32)
.new  move.b   d5,x1
   jsr   wbtosyn   ; copy specified slot to synth i/o buffer
   cmpi.b   #2,d7     ; send only f-pars?
   beq   .fpars
   jsr   writdx7
   cmpi.b   #1,d7     ; send without f-pars
   beq   .update
.fpars   move.l   #wkbank,x1
   clr.l    d0
   move.b   d5,d0
   subq.l   #1,d0
   mulu  #160,d0
   add.l    d0,x1     ; x1 --> specified w.b. slot
   add.l    #145,x1   ; x1 --> specified f-pars
   jsr   writfdx7
   move.l   #$20000,d0      ; wait for synth to digest f-pars
.waitloop   subq.l   #1,d0
   bgt   .waitloop

.update  tst.b    d6
   beq   .echo
   move.b   d6,d0
   andi.l   #$FF,d0
   subq.b   #1,d0
   divu  #8,d0
   lea   wkbnx,a0
   move.b   0(a0,d0.w),x2
   lsr.l    #8,d0
   lsr.l    #8,d0
   move.b   d0,x3
   addq.b   #3,x3
   clr.l    d0
   move.b   d6,d0
   subq.b   #1,d0
   mulu  #10,d0
   move.l   #wkbname,x1
   add.l    d0,x1
   move.b   cmenu,x4
   move.b   #10,x5
   jsr   message   ; change old to color cmenu
.echo    move.b   d5,d0
   andi.l   #$FF,d0
   subq.b   #1,d0
   divu  #8,d0
   lea   wkbnx,a0
   move.b   0(a0,d0.w),x2
   lsr.l    #8,d0
   lsr.l    #8,d0
   move.b   d0,x3
   addq.b   #3,x3
   clr.l    d0
   move.b   d5,d0
   subq.b   #1,d0
   mulu  #10,d0
   move.l   #wkbname,x1
   add.l    d0,x1
   move.b   ccurmen,x4
   move.b   #10,x5
   move.b   #1,forceinv
   jsr   message   ; change new to color ccurmen (inverse)
   clr.b    forceinv
   move.b   d5,d6     ; current = new
   bra   .input

.esc  move.b   #16,x1
   jsr   blnkln
   move.l   #messss,x1
   add.l    #1520,x1
   move.b   #16,x3
   move.b   cprompt,x4
   lea   messsl,a0
   move.b   38(a0),x5
   move.b   xmax,d0
   sub.b    10(a6,d7.l),d0
   lsr.b    #1,d0
   move.b   d0,x2
   jsr   message
.abcloop jsr   getkey
   clr.l    d7
   move.b   y1,d7
   sub.b    ascia,d7 ; d7 = 0,1,2
   beq   .good
   cmpi.b   #1,d7
   beq   .good
   cmpi.b   #2,d7
   beq   .good
   jsr   bell
   bra   .abcloop
.good    move.b   #15,x1
   jsr   blnkln
   move.l   #bnkmess,x1
   move.l   d7,d0
   add.l    #10,d0
   mulu  #40,d0
   add.l    d0,x1
   move.b   10(a6,d7.l),x5
   move.b   xmax,d0
   sub.b    x5,d0
   lsr.b    #1,d0
   move.b   d0,x2
   move.b   #15,x3
   move.b   cmessge,x4
   jsr   message   ; inform exwb mode

   move.b   #16,x1
   jsr   blnkln
   move.l   #bnkmess,x1
   add.l    #520,x1
   move.b   #16,x3
   move.b   13(a6),x5
   jsr   message   ; 'esc to change exwb mode'
   bra   .input

.return  jsr   setdx7    ; re-set-up dx7
   move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   unnmbnk
;      x1.b = bankx = 1-maxbank
;*****************************************************************************;

 XDEF unnmbnk

unnmbnk  movem.l  D0-A6,-(a7) ; save registers
   clr.l    d0
   move.b   x1,d0
   subq.b   #1,d0     ; d0.l = bankx -1

   lea   bnamflg,a0
   clr.b    0(a0,d0.l)   ; clear bank named flag
   lea   banknam,a0
   mulu  #10,d0
   adda.l   d0,a0     ; a0 --> this bank's name

   moveq    #10,d1    ; d1 = 9 to 0
.1    subq.l   #1,d1
   blt   .2
   move.b   ascisp,(a0)+ ; space-fill this bank's name
   bra   .1

.2    movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   namebnk
;      x1.b = bankx = 1-maxbank , namebuf contains 10-character name
;*****************************************************************************;

 XDEF namebnk

namebnk  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   clr.l    d0
   move.b   x1,d0
   subq.b   #1,d0     ; d0.l = bankx -1

   lea   bnamflg,a1
   move.b   #1,0(a1,d0.l)   ; set bank name flag
   lea   banknam,a1
   mulu  #10,d0
   adda.l   d0,a1     ; a1 --> name for this bank
   move.b   #10,x3
   move.l   #namebuf,x1
   move.l   a1,x2
   jsr   movemem   ; copy given name to this bank name

   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x3-x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   fetchb
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF fetchb

fetchb   movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   lea   wkbank,a1    ; a1 --> a w.b. slot
   lea   synbuf,a0    ; a0 --> synth i/o buffer
   adda.l   #6,a0     ; skip header
   clr.b    d6     ; do this 32 times
   lea   wkbname,a2   ; a2 --> a w.b. slot name

.1    clr.b    d7    ; per operator stuff: do it 6 times
.2    move.b   #11,x3
   move.l   a0,x1
   move.l   a1,x2
   jsr   movemem  ; copy eg's,bp,ld,rd
   move.b   11(a0),d0
   move.b   d0,11(a1)
   andi.b   #$3,11(a1)   ; lc
   lsr.l    #2,d0
   move.b   d0,12(a1)    ; rc
   move.b   12(a0),d0
   move.b   d0,13(a1)
   andi.b   #$7,13(a1)   ; kb rate scaling
   lsr.l    #3,d0
   move.b   d0,20(a1)    ; detune
   move.b   13(a0),d0
   move.b   d0,14(a1)
   andi.b   #$3,14(a1)   ; ams
   lsr.l    #2,d0
   move.b   d0,15(a1)    ; velocity sensitivity
   move.b   14(a0),16(a1)   ; output level
   move.b   15(a0),d0
   move.b   d0,17(a1)
   andi.b   #$1,17(a1)   ; mode
   lsr.l    #1,d0
   move.b   d0,18(a1)    ; coarse frq
   move.b   16(a0),19(a1)   ; fine frq

   add.l    #17,a0
   add.l    #21,a1
   addq.b   #1,d7
   cmpi.b   #6,d7
   bne   .2     ; end of per operator data

   move.l   a0,x1
   move.l   a1,x2
   move.b   #9,x3
   jsr   movemem   ; pitch eg, algorithm
   move.b   9(a0),d0
   move.b   d0,9(a1)
   andi.b   #$7,9(a1)      ; feedback
   lsr.l    #3,d0
   move.b   d0,10(a1)    ; op sync
   move.b   10(a0),11(a1)   ; lfo speed
   move.b   11(a0),12(a1)   ; lfo delay
   move.b   12(a0),13(a1)   ; pmd
   move.b   13(a0),14(a1)   ; amd
   move.b   14(a0),d0
   move.b   d0,15(a1)
   andi.b   #$1,15(a1)   ; lfo sync
   lsr.l    #1,d0
   move.b   d0,16(a1)
   andi.b   #$7,16(a1)   ; lfo waveform
   lsr.l    #3,d0
   move.b   d0,17(a1)    ; pms
   move.b   15(a0),18(a1)   ; transpose

   move.l   a0,x1
   add.l    #16,x1    ; copy name
   move.l   a2,x2
   jsr   movename

   add.l    #34,a1
   add.l    #26,a0
   add.l    #10,a2
   addq.b   #1,d6
   cmpi.b   #32,d6
   bne   .1     ; end of do for each bank slot

   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x3-x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   gobank
;      pack w.b. into synbuf
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF gobank

gobank   movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   lea   synbuf,a1
   move.b   #$F0,(a1)   ; header
   move.b   #$43,1(a1)
   move.b   midich,2(a1)
   subq.b   #1,2(a1)
   move.b   #$09,3(a1)
   move.b   #$20,4(a1)
   move.b   #$00,5(a1)
         ; copy data:
   lea   wkbank,a0
   addq.l   #6,a1
   move.b   #32,d6

.0    moveq    #6,d7    ; d7 =6 to 1
   move.l   a0,a2    ; a2 --> from operator data
   move.l   a1,a3    ; a3 --> to operator data

.1    move.l   a2,x1
   move.l   a3,x2
   move.b   #11,x3
   jsr   movemem  ; eg data

   move.b   12(a2),d0   ; rc
   lsl.b    #2,d0
   or.b  11(a2),d0   ; lc
   move.b   d0,11(a3)

   move.b   20(a2),d0   ; dtn
   lsl.b    #3,d0
   or.b  13(a2),d0   ; kb rate
   move.b   d0,12(a3)

   move.b   15(a2),d0   ; vel
   lsl.b    #2,d0
   or.b  14(a2),d0   ; ams
   move.b   d0,13(a3)

   move.b   16(a2),14(a3)   ; level
   move.b   18(a2),d0    ; cfq
   lsl.b    #1,d0
   or.b  17(a2),d0   ; mode
   move.b   d0,15(a3)

   move.b   19(a2),16(a3)   ; ffq

   add.l    #21,a2   ; end of operator data loop
   add.l    #17,a3
   subq.b   #1,d7
   bne   .1

   move.l   a0,x1
   add.l    #126,x1
   move.l   a1,x2
   add.l    #102,x2
   move.b   #8,x3
   jsr   movemem  ; pitch eg

   move.b   134(a0),110(a1)    ; alg
   move.b   136(a0),d0   ; op sync
   lsl.b    #3,d0
   or.b  135(a0),d0   ; fb
   move.b   d0,111(a1)

   move.b   137(a0),112(a1)  ; lfo spd
   move.b   138(a0),113(a1)  ; lfo dly
   move.b   139(a0),114(a1)  ; lfo pmd
   move.b   140(a0),115(a1)  ; lfo amd

   move.b   143(a0),d0   ; pms
   lsl.b    #3,d0
   or.b  142(a0),d0   ; wave
   lsl.b    #1,d0
   or.b  141(a0),d0   ; lfo sync
   move.b   d0,116(a1)

   move.b   144(a0),117(a1) ; transpose

   add.l    #128,a1   ; end of w.b. slot loop
   add.l    #160,a0
   subq.b   #1,d6
   bne   .0

   move.b   asciline,d0
   lea   synbuf,a1    ; copy names
   add.l    #124,a1
   lea   wkbname,a0
   move.l   #32,d7
.3    clr.l    d6
.4    cmp.b    0(a0,d6.w),d0
   bne   .5
   move.b   ascisp,0(a1,d6.w)
   bra   .6
.5    move.b   0(a0,d6.w),0(a1,d6.w)
.6    addq.l   #1,d6
   cmpi.l   #10,d6
   bne   .4
   add.l    #128,a1
   add.l    #10,a0
   subq.l   #1,d7
   bne   .3

   lea   synbuf,a0    ; checksum
   addq.l   #6,a0
   clr.l    d0
   clr.l    d1
.7    add.b    0(a0,d1.l),d0
   addq.l   #1,d1
   cmpi.l   #4096,d1
   bne   .7
   neg.b    d0
   andi.l   #$7F,d0
   lea   synbuf,a0
   move.b   d0,4102(a0)

   move.b   #$F7,4103(a0)   ; end of system exclusive

   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x3-x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   scrallb
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF scrallb

scrallb  movem.l  D0-A6,-(a7) ; save registers
   lea   bankflg,a0   ; a0 --> bank existence flags
   lea   bnamflg,a1   ; a1 --> bank named flags
   lea   banknam,a2   ; a2 --> bank names
   lea   bslotnm,a3   ; a3 --> bank slot names

   clr.w    d0    ; d0 = 0 to maxbank-1
   clr.l    d1    ; d1 = 10*d0
   clr.l    d2    ; d2 = 320*d0

.1    tst.b    0(a0,d0.w)   ; exists?
   beq   .5     ; no: skip it
   clr.b    0(a0,d0.w)   ; yes: clear existence flag

   tst.b    0(a1,d0.w)   ; named?
   beq   .3
   clr.b    0(a1,d0.w)   ; yes: clear named flag

   move.l   a2,a6
   add.l    d1,a6
   moveq    #10,d7
.2    move.b   ascisp,(a6)+ ; and space-fill name
   subq.b   #1,d7
   bne   .2

.3    move.l   a3,a6
   add.l    d2,a6
   move.w   #320,d7
.4    move.b   ascisp,(a6)+ ; space-fill slot names
   subq.w   #1,d7
   bne   .4

   subq.b   #1,nbanks    ; decrement # of banks
   beq   .return   ; all banks gone?

.5    addq.w   #1,d0
   add.l    #10,d1
   add.l    #320,d2
   cmp.b    maxbank,d0
   bne   .1     ; loop until all banks gone

.return  movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; and return

;*****************************************************************************
;   local data
;*****************************************************************************

 SECTION jonah,data

locmess  dc.b   "[Help]  Hardcopy this screen x"   ; 0
   dc.b   "[Return]  Go to bank menu xxxx"   ; 1
   dc.b   "[n]  next screen xxxxxxxxxxxxx"   ; 2
   dc.b   "[p]  previous screen xxxxxxxxx"   ; 3
locmesl  dc.b    28,25,16,20
