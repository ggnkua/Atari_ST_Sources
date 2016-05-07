;*****************************************************************************;
;   mixbank --  Copyright 1986 Tom Bajoras
;      x1.b = bankx (1-maxbank)
;      y1.b = 0 all ok, <>0 disk error
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION mixbank,code

  XDEF mixbank

 XREF getkey
 XREF writbnk
 XREF buf_to_w
 XREF w_to_buf
 XREF bell
 XREF readbnk
 XREF blnkln
 XREF movemem
 XREF outchar
 XREF line
 XREF message
 XREF setcolor
 XREF blnkscr

mixbank  movem.l  d0-a6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   lea   wkbank,a0    ; copy w.b. to w.b. alias
   lea   wwkbank,a1
   move.l   #1280,d0
.loopww1 move.l   (a0)+,(a1)+
   subq.l   #1,d0
   bne   .loopww1
   lea   wkbname,a0   ; copy w.b. names to w.b. names alias
   lea   wwkbname,a1
   move.w   #80,d0
.loopww2 move.l   (a0)+,(a1)+
   subq.w   #1,d0
   bne   .loopww2

; set up local variables:
   move.b   x1,d4     ; d4.b= saved copy of x1
   lea   bnkmesl,a6   ; a6--> bnkmesl
   lea   wwkbname,a5  ; a5--> w.b. alias names
   lea   bslotnm,a4
   clr.l    d0
   move.b   x1,d0
   subq.b   #1,d0
   mulu  #320,d0
   add.l    d0,a4     ; a4--> bank slot names
   lea   bankkey,a3   ; a3--> bank keys

   jsr   readbnk   ; read specified bank into filebuf
   tst.b    y1
   bne   .error    ; go no farther if read failed

   jsr   blnkscr   ; start with a blank screen
   move.b   #6,x1     ; change colors
   jsr   setcolor

   move.l   #bnkmess,x1
   add.l    #600,x1
   move.b   xmax,d0
   sub.b    15(a6),d0
   lsr.b    #1,d0
   move.b   d0,x2
   move.b   #1,x3
   move.b   cmenhed,x4
   move.b   15(a6),x5
   jsr   message   ; center title
   move.w   #2,x1     ; draw left rectangle
   move.w   #20,x2
   move.w   #261,x3
   move.w   #20,x4
   move.b   coutlne,x5
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #170,x4
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #2,x3
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #20,x4
   jsr   line   ; draw left rectangle
   move.w   #378,x1
   move.w   #20,x2
   move.w   #637,x3
   move.w   #20,x4
   move.b   coutlne,x5
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #170,x4
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #378,x3
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #20,x4
   jsr   line   ; draw right rectangle
   move.l   #bnkmess,x1
   add.l    #640,x1
   move.b   #14,x2
   move.b   #3,x3
   move.b   cmessge,x4
   move.b   16(a6),x5
   jsr   message   ;"workbank"
   move.l   #bnkmess,x1
   move.b   #61,x2
   move.b   (a6),x5
   jsr   message   ; "bank"
   move.b   ascisp,x1
   move.b   #65,x2
   jsr   outchar  ; space after "bank"
   cmpi.b   #9,d4
   bgt   .twodig
   move.b   d4,x1    ; bankx < 10: single digit after "bank_"
   add.b    #$30,x1
   addq.b   #1,x2
   jsr   outchar
   bra   .1
.twodig  move.b   #$31,x1  ; bankx > 9: two digits after "bank_"
   addq.b   #1,x2
   jsr   outchar
   move.b   d4,x1
   sub.b    #10,x1
   add.b    #$30,x1
   addq.b   #1,x2
   jsr   outchar

.1    clr.l    d0    ; for d0.l=0 to 31
   move.b   cmenu,d1
.loopwb  bsr   .diswb   ; call diswb(d0.l,d1.b)
   addq.l   #1,d0
   cmpi.l   #31,d0
   ble   .loopwb

   clr.l    d0    ; for d0.l=0 to 31
   move.b   cmenu,d1
.loopbnk bsr   .disbnk  ; call disbnk(d0.l,d1.b)
   addq.l   #1,d0
   cmpi.l   #31,d0
   ble   .loopbnk

   move.l   a4,x1    ; save bank slot names in catbuf
   move.l   #catbuf,x2  ; in case of error or abort at end of
   move.b   #160,x3  ; editing session (must be done in
   jsr   movemem  ; two parts)
   add.l    #160,x1
   add.l    #160,x2
   jsr   movemem

   move.b   #1,d7    ; "no changes" flag set

.loop1:  move.b   #23,x1   ; (re)init command area
   jsr   blnkln
   move.b   #24,x1
   jsr   blnkln
   move.b   #25,x1
   jsr   blnkln
   move.l   #bnkmess,x1
   add.l    #680,x1
   move.b   xmax,d0
   sub.b    17(a6),d0
   lsr.b    #1,d0
   move.b   d0,x2     ; sort of center this
   move.b   #23,x3
   move.b   cprompt,x4
   move.b   17(a6),x5
   jsr   message   ; "select wb slot"
   move.l   #bnkmess,x1
   add.l    #720,x1
   move.b   #24,x3
   move.b   18(a6),x5
   jsr   message   ; "return?"
   move.l   #bnkmess,x1
   add.l    #1040,x1  ; "abort?"
   move.b   #25,x3
   move.b   26(a6),x5
   jsr   message
.loop2   jsr   getkey
   move.b   y1,d0
   cmp.b    ascicr,d0
   beq   .return
   cmp.b    asciesc,d0
   beq   .escape
   move.l   #31,d6
.find1   cmp.b    0(a3,d6.l),d0
   beq   .found1
   subq.l   #1,d6
   bge   .find1
   jsr   bell   ; couldn't find key: bell,
   bra   .loop2    ; and get another key
.found1  move.l   d6,d0
   move.b   ccurmen,d1
   move.b   #1,forceinv
   bsr   .diswb    ; selected w.b. slot green
   clr.b    forceinv
   move.b   #23,x1    ; erase prompts
   jsr   blnkln
   move.b   #24,x1
   jsr   blnkln
   move.b   #25,x1
   jsr   blnkln
   move.l   #bnkmess,x1
   add.l    #760,x1
   move.b   xmax,d0
   sub.b    19(a6),d0
   lsr.b    #1,d0
   move.b   d0,x2     ; sort of center this
   move.b   #23,x3
   move.b   cprompt,x4
   move.b   19(a6),x5
   jsr   message   ; 'select bank slot'
   move.l   #bnkmess,x1
   add.l    #800,x1
   addq.b   #1,x3
   move.b   20(a6),x5
   jsr   message   ; "de-select w.b. slot?"
.loop3   jsr   getkey
   move.b   y1,d0
   cmp.b    ascicr,d0
   beq   .deselect
   move.l   #31,d5
.find2   cmp.b    0(a3,d5.l),d0
   beq   .found2
   subq.l   #1,d5
   bge   .find2
   jsr   bell   ; couldn't find key: bell,
   bra   .loop3    ; and get another key
.deselect   move.l   d6,d0
   move.b   cmenu,d1
   bsr   .diswb
   bra   .loop1
.found2  move.l   d5,d0
   move.b   ccurmen,d1
   move.b   #1,forceinv
   bsr   .disbnk   ; selected bank slot green
   clr.b    forceinv
   move.b   #23,x1   ; erase prompts
   jsr   blnkln
   move.b   #24,x1
   jsr   blnkln
   move.l   #bnkmess,x1
   add.l    #840,x1
   move.b   xmax,d0
   sub.b    21(a6),d0
   lsr.b    #1,d0
   move.b   d0,x2    ; sort of center this
   move.b   #23,x3
   move.b   cprompt,x4
   move.b   21(a6),x5
   jsr   message  ; 'right arrow'
   move.l   #bnkmess,x1
   add.l    #880,x1
   addq.b   #1,x3
   move.b   22(a6),x5
   jsr   message  ; 'left arrow'
   move.l   #bnkmess,x1
   add.l    #920,x1
   addq.b   #1,x3
   move.b   23(a6),x5
   jsr   message  ; 'swap'

.loop4   jsr   getkey
   move.b   y1,d0
   cmp.b    ascirit,d0
   beq   .wbtob
   cmp.b    ascilef,d0
   beq   .btowb
   cmp.b    asciup,d0
   beq   .swap
   cmp.b    ascidwn,d0
   beq   .swap
   jsr   bell  ; bad key: bell, get another key
   bra   .loop4

.wbtob   lea   wwkbank,a0
   lea   filebuf,a1
   move.l   d6,d0
   mulu  #160,d0
   add.l    d0,a0     ; a0--> from area
   move.l   d5,d0
   mulu  #128,d0
   add.l    d0,a1     ; a1--> to area
   movem.l  d0-a6,-(a7) ; protect all registers
   jsr   w_to_buf
   movem.l  (a7)+,d0-a6 ; restore all registers
   move.l   #wwkbname,x1
   move.l   d6,d0
   mulu  #10,d0
   add.l    d0,x1
   move.l   a4,x2
   move.l   d5,d0
   mulu  #10,d0
   add.l    d0,x2
   move.b   #10,x3
   jsr   movemem   ; copy w.b. name to bank slot name
   clr.b    d7     ; clear no-changes flag
   bra   .next

.btowb   lea   filebuf,a0
   lea   wwkbank,a1
   move.l   d5,d0
   mulu  #128,d0
   add.l    d0,a0    ; a0--> from area
   move.l   d6,d0
   mulu  #160,d0
   add.l    d0,a1    ; a1--> to area
   movem.l  d0-a6,-(a7) ; protect all registers
   jsr   buf_to_w
   movem.l  (a7)+,d0-a6 ; restore all registers
   move.l   a4,x1
   move.l   d5,d0
   mulu  #10,d0
   add.l    d0,x1
   move.l   #wwkbname,x2
   move.l   d6,d0
   mulu  #10,d0
   add.l    d0,x2
   move.b   #10,x3
   jsr   movemem   ; copy bank slot name to w.b. name
   bra   .next

.swap    move.l   #wwkbank,x1
   move.l   d6,d0
   mulu  #160,d0
   add.l    d0,x1
   move.l   #catbuf,x2
   add.l    #320,x2
   move.b   #160,x3
   jsr   movemem  ; copy w.b. slot to catbuf
   lea   filebuf,a0
   lea   wwkbank,a1
   move.l   d5,d0
   mulu  #128,d0
   add.l    d0,a0    ; a0--> bank slot to be swapped
   move.l   d6,d0
   mulu  #160,d0
   add.l    d0,a1    ; a1--> w.b. slot to be swapped
   movem.l  d0-a6,-(a7)  ; protect registers
   jsr   buf_to_w  ; copy bank slot to w.b. slot
   movem.l  (a7)+,d0-a6 ; restore registers
   lea   catbuf,a0
   add.l    #320,a0   ; a0--> catbuf to be swapped
   lea   filebuf,a1
   move.l   d5,d0
   mulu  #128,d0
   add.l    d0,a1     ; a1--> bank slot to be swapped
   movem.l  d0-a6,-(a7) ; protect registers
   jsr   w_to_buf  ; copy catbuf to bank slot
   movem.l  (a7)+,d0-a6 ; restore registers
   lea   wwkbname,a0
   move.l   d6,d0
   mulu  #10,d0
   add.l    d0,a0     ; a0--> w.b. slot name
   move.l   a4,a1
   move.l   d5,d0
   mulu  #10,d0
   add.l    d0,a1     ; a1--> bank slot name
   clr.l    d0    ; for d0.l=0 to 9
.swaploop   move.b   0(a0,d0.l),d1
   move.b   0(a1,d0.l),0(a0,d0.l)
   move.b   d1,0(a1,d0.l)
   addq.l   #1,d0
   cmpi.l   #9,d0     ; swap names
   ble   .swaploop
   clr.b    d7     ; clear no-changes flag

.next    move.l   d6,d0
   move.b   cmenu,d1
   bsr   .diswb
   move.l   d5,d0
   bsr   .disbnk
   bra   .loop1   ; start all this over again!

.return  move.b   #1,y1
   cmp.b    #1,d7    ; if no changes simply return (y1.b=1)
   beq   .returnx
   move.b   d4,x1
   jsr   writbnk  ; write filebuf back to disk
   tst.b    y1    ; if write succeeded return
   beq   .returnx
   move.l   #catbuf,x1  ; else: restore bank slot names
   move.l   a4,x2    ; from catbuf
   move.b   #160,x3
   jsr   movemem
   add.l    #160,x1
   add.l    #160,x2
   jsr   movemem  ; (must be done in two parts)
.error   jsr   blnkscr  ; blank screen
   clr.b    x1    ; restore menu colors
   jsr   setcolor
   move.l   #bnkmess,x1
   add.l    #960,x1
   move.b   #1,x2
   move.b   #1,x3
   move.b   cmessge,x4
   move.b   24(a6),x5
   jsr   message  ; inform user of error
   move.l   #bnkmess,x1
   add.l    #1000,x1
   addq.b   #1,x3
   move.b   cprompt,x4
   move.b   25(a6),x5
   jsr   message  ; prompt for any key to return
   jsr   getkey
   move.b   #1,y1    ; error code

.returnx lea   wkbank,a1    ; copy w.b. alias to w.b.
   lea   wwkbank,a0
   move.l   #1280,d0
.loopww3 move.l   (a0)+,(a1)+
   subq.l   #1,d0
   bne   .loopww3
   lea   wkbname,a1   ; copy w.b. names alias to w.b. names
   lea   wwkbname,a0
   move.w   #80,d0
.loopww4 move.l   (a0)+,(a1)+
   subq.w   #1,d0
   bne   .loopww4

.bailout move.l   (a7)+,x5 ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6 ; restore registers
   rts

.escape  move.l   #catbuf,x1  ; restore bank slot names
   move.l   a4,x2    ; from catbuf
   move.b   #160,x3
   jsr   movemem
   add.l    #160,x1
   add.l    #160,x2
   jsr   movemem  ; (must be done in two parts)
   move.b   #1,y1    ; no disk update necessary
   bra   .bailout

.diswb   move.l   d0,d2
   divu  #16,d2   ; d2.l = row # | col #
   move.w   d2,d3    ; d3.w = col # (0 or 1)
   move.b   #2,x2
   mulu  #19,d3   ; d3.b = 0 or 19
   add.b    d3,x2    ; x2.b = 2 or 21
   lsr.l    #8,d2
   lsr.l    #8,d2    ; d2.l = 0 to 15
   move.b   #5,x3
   add.b    d2,x3
   move.b   0(a3,d0.l),x1
   move.b   cmenkey,x4
   jsr   outchar  ; output w.b. key
   move.l   a5,x1
   move.l   d0,d2
   mulu  #10,d2
   add.l    d2,x1
   addq.b   #2,x2
   move.b   d1,x4
   move.b   #10,x5
   jsr   message  ; output w.b. name
   rts

.disbnk  move.l   d0,d2
   divu  #16,d2   ; d2.l = row # | col #
   move.w   d2,d3    ; d3.w = col #
   move.b   #49,x2
   mulu  #19,d3   ; d3.b = 0 or 19
   add.b    d3,x2
   lsr.l    #8,d2
   lsr.l    #8,d2    ; d2.l = 0 to 15
   move.b   #5,x3
   add.b    d2,x3
   move.b   0(a3,d0.l),x1
   move.b   cmenkey,x4
   jsr   outchar  ; output bank key
   move.l   a4,x1
   move.l   d0,d2
   mulu  #10,d2
   add.l    d2,x1
   addq.b   #2,x2
   move.b   d1,x4
   move.b   #10,x5
   jsr   message  ; output bank name
   rts
