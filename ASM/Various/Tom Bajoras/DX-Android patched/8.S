;*****************************************************************************;
;   module 8 source file Copyright 1986 Tom Bajoras
;   catalog menu command processing routines:
;   catone,catprex,catsufx,catinfx,catall,catindx,catnoti,catlock,catnotl
;   catrevs, catout, bildcat, catret, catmore
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION eight,code

;*****************************************************************************;
;   catone
;      x1.w = file # to catalog (1-maxfile)
;*****************************************************************************;

 XDEF catone

 XREF unpromp
blnkln
writinfo
scratch
writfdx7
 XREF writdx7
 XREF wstosyn
 XREF checkws
 XREF usefile
 XREF findfil
 XREF outchar
 XREF getkey
 XREF hardtext
 XREF bell
 XREF cmpinfx
 XREF cmpsufx
 XREF length
 XREF setcolor
 XREF blnkscr
 XREF movemem
 XREF message
 XREF creturn

catone   movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.w   x1,d7     ; inputs to bildcat
   subq.w   #1,d7
   lea   catbuf,a5
   bsr   bildcat
   jsr   unpromp   ; un-prompt current line
   move.l   #3,x1     ; catalog menux for creturn/scroll
   jsr   creturn   ; move cursor to next line

   move.l   #catmess,x1
   add.l    #320,x1   ; "catalog one file:"
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cmessge,x4
   lea   catmesl,a0
   move.b   8(a0),x5
   jsr   message
   move.b   8(a0),x2
   addq.b   #2,x2
   move.l   a5,x1     ; append catalog buffer
   move.b   cecho,x4
   move.b   #19,x5
   jsr   message

   move.l   (a7)+,x5
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x5-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return

;*****************************************************************************;
;   catprex
;      namebuf contains prefix, y1.b = 0 ok, =1 none found
;*****************************************************************************;

 XDEF catprex

catprex  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   clr.l    d2
   move.b   catfmt,d2
   clr.l    d1
   move.b   ymax,d1
   subq.b   #6,d1
   mulu  d1,d2     ; d2.b = max # cats per page

   lea   catbuf,a5    ; a5 --> area to build into
   lea   fileflg,a1   ; a1 --> file existence flags
   move.l   #namebuf,x1
   move.l   #fixbuf,x2
   move.b   #10,x3
   jsr   movemem
   lea   fixbuf,a2    ; a2 --> prefix

   lea   filenam,a3   ; a3 --> file names

   clr.w    d5     ; d5.w = # cat'd files so far
   clr.l    d3     ; d3.l = 0 to maxfile-1
   clr.b    d4     ; d4.b = 0 to d2

.catloop tst.b    0(a1,d3.l)   ; skip it if it doesn't exist
   beq   .next

   move.b   ascisp,d7    ; try to match prefix to this name
   clr.w    d0
.preloop tst.b    0(a2,d0.w)
   beq   .good
   cmp.b    0(a2,d0.w),d7
   beq   .good
   move.b   0(a2,d0.w),d1
   cmp.b    0(a3,d0.w),d1
   bne   .next
   addq.w   #1,d0
   cmpi.w   #10,d0
   bne   .preloop

.good    move.w   d3,d7
   bsr   bildcat   ; matches:  build it
   add.l    #19,a5
   addq.b   #1,d4
   addq.w   #1,d5
   cmp.b    d2,d4     ; do screen if no more will fit
   bne   .next     ; on it

.out  jsr   blnkscr
   move.b   #7,x1     ; change colors
   jsr   setcolor

   move.l   #catmess,x1
   add.l    #240,x1
   move.b   #1,x2
   move.b   #1,x3
   move.b   cmenhed,x4
   lea   catmesl,a0
   move.b   6(a0),x5
   jsr   message   ; heading
   move.b   x5,x2
   addq.b   #2,x2
   move.l   #fixbuf,x1
   move.b   cmessge,x4
   move.b   #10,x5
   jsr   message   ; append prefix

   move.b   d4,d7
   bsr   catout
   lea   catbuf,a5    ; re-init area to build into
   cmp.w    nfiles,d5    ; done?
   bne   .more
   bsr   catret

.more    bsr   catmore
   clr.b    d4
.next    addq.l   #1,d3
   add.l    #10,a3
   cmp.w    maxfile,d3
   bne   .catloop
   tst.b    d4     ; any left? yes: output them
   beq   .return
   move.w   nfiles,d5
   bra   .out

.return  clr.b    y1     ; any prefixes found?
   tst.w    d5
   bne   .returnx
   move.b   #1,y1
.returnx move.l   (a7)+,x5
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x5-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return

;*****************************************************************************;
;   catsufx
;      namebuf contains suffix, y1.b = 0 ok, =1 none found
;*****************************************************************************;

 XDEF catsufx

catsufx  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   clr.l    d2
   move.b   catfmt,d2
   clr.l    d1
   move.b   ymax,d1
   subq.b   #6,d1
   mulu  d1,d2     ; d2.b = max # cats per page

   lea   catbuf,a5    ; a5 --> area to build into
   lea   fileflg,a1   ; a1 --> file existence flags
   move.l   #namebuf,x1
   move.l   #fixbuf,x2
   move.b   #10,x3
   jsr   movemem
   lea   fixbuf,a2      ; a2 --> suffix

   lea   filenam,a3   ; a3 --> file names
   move.l   a2,x1
   jsr   length
   move.b   y1,d6     ; d6.b = length of suffix

   clr.w    d5     ; d5.w = # cat'd files so far
   clr.l    d3     ; d3.l = 0 to maxfile-1
   clr.b    d4     ; d4.b = 0 to d2

.catloop tst.b    0(a1,d3.l)   ; skip it if it doesn't exist
   beq   .next
   move.l   a2,x1
   move.l   a3,x2
   move.b   d6,x3
   jsr   cmpsufx   ; suffix matches?
   tst.b    y1     ; no: skip it
   beq   .next

   move.w   d3,d7
   bsr   bildcat   ; matches:  build it
   add.l    #19,a5
   addq.b   #1,d4
   addq.w   #1,d5
   cmp.b    d2,d4     ; do screen if no more will fit
   bne   .next     ; on it

.out  jsr   blnkscr
   move.b   #7,x1     ; change colors
   jsr   setcolor

   move.l   #catmess,x1
   add.l    #280,x1
   move.b   #1,x2
   move.b   #1,x3
   move.b   cmenhed,x4
   lea   catmesl,a0
   move.b   7(a0),x5
   jsr   message   ; heading
   move.b   x5,x2
   addq.b   #2,x2
   move.l   #fixbuf,x1
   move.b   cmessge,x4
   move.b   #10,x5
   jsr   message   ; append suffix

   move.b   d4,d7
   bsr   catout
   lea   catbuf,a5    ; re-init area to build into
   cmp.w    nfiles,d5    ; done?
   bne   .more
   bsr   catret

.more    bsr   catmore
   clr.b    d4     ; re-init # of cats on next page

.next    addq.l   #1,d3
   add.l    #10,a3
   cmp.w    maxfile,d3
   bne   .catloop
   tst.b    d4     ; any left? yes: output them
   beq   .return
   move.w   nfiles,d5
   bra   .out

.return  clr.b    y1     ; any suffixes found?
   tst.w    d5
   bne   .returnx
   move.b   #1,y1
.returnx move.l   (a7)+,x5
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x5-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return

;*****************************************************************************;
;   catinfx
;      namebuf contains infix, y1.b = 0 ok, =1 none found
;*****************************************************************************;

 XDEF catinfx

catinfx  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   clr.l    d2
   move.b   catfmt,d2
   clr.l    d1
   move.b   ymax,d1
   subq.b   #6,d1
   mulu  d1,d2     ; d2.b = max # cats per page

   lea   catbuf,a5    ; a5 --> area to build into
   lea   fileflg,a1   ; a1 --> file existence flags
   move.l   #namebuf,x1
   move.l   #fixbuf,x2
   move.b   #10,x3
   jsr   movemem
   lea   fixbuf,a2      ; a2 --> infix
   lea   filenam,a3   ; a3 --> file names
   move.l   a2,x1
   jsr   length
   move.b   y1,d6     ; d6.b = length of infix

   clr.w    d5     ; d5.w = # cat'd files so far
   clr.l    d3     ; d3.l = 0 to maxfile-1
   clr.b    d4     ; d4.b = 0 to d2

.catloop tst.b    0(a1,d3.l)   ; skip it if it doesn't exist
   beq   .next
   move.l   a2,x1
   move.l   a3,x2
   move.b   d6,x3
   jsr   cmpinfx   ; infix matches?
   tst.b    y1     ; no: skip it
   beq   .next

   move.w   d3,d7
   bsr   bildcat   ; matches:  build it
   add.l    #19,a5
   addq.b   #1,d4
   addq.w   #1,d5
   cmp.b    d2,d4     ; do screen if no more will fit
   bne   .next     ; on it

.out  jsr   blnkscr
   move.b   #7,x1     ; change colors
   jsr   setcolor

   move.l   #catmess,x1
   add.l    #360,x1
   move.b   #1,x2
   move.b   #1,x3
   move.b   cmenhed,x4
   lea   catmesl,a0
   move.b   9(a0),x5
   jsr   message   ; heading
   move.b   x5,x2
   addq.b   #2,x2
   move.l   #fixbuf,x1
   move.b   cmessge,x4
   move.b   #10,x5
   jsr   message   ; append infix

   move.b   d4,d7
   bsr   catout
   lea   catbuf,a5    ; re-init area to build into
   cmp.w    nfiles,d5    ; done?
   bne   .more
   bsr   catret

.more    bsr   catmore
   clr.b    d4     ; re-init # of cats on next page

.next    addq.l   #1,d3
   add.l    #10,a3
   cmp.w    maxfile,d3
   bne   .catloop
   tst.b    d4     ; any left? yes: output them
   beq   .return
   move.w   nfiles,d5
   bra   .out

.return  clr.b    y1     ; any infixes found?
   tst.w    d5
   bne   .returnx
   move.b   #1,y1
.returnx move.l   (a7)+,x5
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x5-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return

;*****************************************************************************;
;   catall
;      no entry conditions, no exit conditions,
;*****************************************************************************;

 XDEF catall

catall   movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.l   #fileflg,catdat1
   move.w   nfiles,catdat2
   move.l   #40,catdat3
   move.l   #1,catdat4
   move.b   #1,catdat5
   bra   catxxx

;*****************************************************************************;
;   catindx
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF catindx

catindx  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.l   #indflg,catdat1
   move.w   nfilind,catdat2
   move.l   #160,catdat3
   move.l   #4,catdat4
   move.b   #1,catdat5
;     bra   catxxx

;******************************************************************************
;   catxxx  --  common code for catall,catindx,catnoti,catlock,catnotl
;******************************************************************************

 XDEF catxxx

catxxx   clr.l    d2
   move.b   catfmt,d2
   clr.l    d1
   move.b   ymax,d1
   subq.b   #6,d1
   mulu  d1,d2     ; d2.b = max # cats per page

   lea   catbuf,a5    ; a5 --> area to build into
   lea   fileflg,a1   ; a1 --> file existence flags
   move.l   catdat1,a2

   clr.w    d5     ; d5.w = # cat'd files so far
   clr.w    d3     ; d3.w = 0 to maxfile-1
   clr.b    d4     ; d4.b = 0 to d2

.catloop tst.b    0(a1,d3.w)   ; skip it if it doesn't exist
   beq   .next
   move.b   catdat5,d0
   cmp.b    0(a2,d3.w),d0
   bne   .next

   move.w   d3,d7
   bsr   bildcat   ; else build it
   add.l    #19,a5
   addq.b   #1,d4
   addq.w   #1,d5
   cmp.w    catdat2,d5   ; do screen if end of catloop
   beq   .out   ; and some cats are left over
   cmp.b    d2,d4     ; do screen if no more will fit
   bne   .next     ; on it

.out  jsr   blnkscr
   move.b   #7,x1     ; change colors
   jsr   setcolor

   lea   catmess,a0
   add.l    catdat3,a0
   move.l   a0,x1
   move.b   #1,x2
   move.b   #1,x3
   move.b   cmenhed,x4
   lea   catmesl,a0
   add.l    catdat4,a0
   move.b   (a0),x5
   jsr   message   ; heading

   move.b   d4,d7
   bsr   catout
   lea   catbuf,a5    ; re-init area to build into
   cmp.w    catdat2,d5   ; done?
   bne   .more
   bsr   catret

.more    bsr   catmore
   clr.b    d4     ; re-init # of cats on next page

.next    addq.w   #1,d3
   cmp.w    maxfile,d3
   bne   .catloop

.return  move.l   (a7)+,x5
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x5-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return

;*****************************************************************************;
;   catnoti
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF catnoti

catnoti  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.l   #indflg,catdat1
   move.w   nfiles,d0
   sub.w    nfilind,d0
   move.w   d0,catdat2
   move.l   #200,catdat3
   move.l   #5,catdat4
   clr.b    catdat5
   bra   catxxx

;*****************************************************************************;
;   catlock
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF catlock

catlock  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.l   #fillock,catdat1
   move.w   nfillok,catdat2
   move.l   #80,catdat3
   move.l   #2,catdat4
   move.b   #1,catdat5
   bra   catxxx

;*****************************************************************************;
;   catnotl
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF catnotl

catnotl  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.l   #fillock,catdat1
   move.w   nfiles,d0
   sub.w    nfillok,d0
   move.w   d0,catdat2
   move.l   #120,catdat3
   move.l   #3,catdat4
   clr.b    catdat5
   bra   catxxx

;*****************************************************************************;
;   catrevs
;      x1.b = from rev, x2.b = to rev, y1.b = 0 ok, =1 none found
;*****************************************************************************;

 XDEF catrevs

catrevs  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   clr.l    d2
   move.b   catfmt,d2
   clr.l    d1
   move.b   ymax,d1
   subq.b   #6,d1
   mulu  d1,d2     ; d2.b = max # cats per page
   clr.w    d1
   clr.w    d6
   move.b   x1,d1    ; d1.w = from rev
   move.b   x2,d6    ; d6.w = to rev
   move.l   #namebuf,x1
   move.l   #fixbuf,x2
   move.b   #10,x3
   jsr   movemem   ; fixbuf contains encoded rev range
   lea   catbuf,a5    ; a5 --> area to build into
   lea   fileflg,a1   ; a1 --> file existence flags
   lea   revtabl,a2   ; a2 --> revision table
   clr.w    d5     ; d5.w = # cat'd files so far
   clr.l    d3     ; d3.l = 0 to maxfile-1
   clr.b    d4     ; d4.b = 0 to d2

.catloop tst.b    0(a1,d3.l)   ; skip it if it doesn't exist
   beq   .next
   clr.w    d0
   move.b   0(a2,d3.l),d0
   cmp.w    d0,d1     ; rev is in given range?
   bgt   .next
   cmp.w    d0,d6
   blt   .next     ; too high or too low: skip it

   move.w   d3,d7
   bsr   bildcat   ; it's in range: build it
   add.l    #19,a5
   addq.b   #1,d4
   addq.w   #1,d5
   cmp.b    d2,d4     ; do screen if no more will fit
   bne   .next     ; on it

.out  jsr   blnkscr
   move.b   #7,x1     ; change colors
   jsr   setcolor

   move.l   #catmess,x1
   add.l    #400,x1
   move.b   #1,x2
   move.b   #1,x3
   move.b   cmenhed,x4
   lea   catmesl,a0
   move.b   10(a0),x5
   jsr   message   ; heading
   move.b   x5,x2
   addq.b   #2,x2
   move.l   #fixbuf,x1
   move.b   cmessge,x4
   move.b   #10,x5
   jsr   message   ; append revision range

   move.b   d4,d7
   bsr   catout
   lea   catbuf,a5    ; re-init area to build into
   cmp.w    nfiles,d5    ; done?
   bne   .more
   bsr   catret

.more    bsr   catmore
   clr.b    d4     ; re-init # of cats on next page

.next    addq.l   #1,d3
   add.l    #10,a3
   cmp.w    maxfile,d3
   bne   .catloop
   tst.b    d4     ; any left? yes: output them
   beq   .return
   move.w   nfiles,d5
   bra   .out

.return  clr.b    y1     ; any found?
   tst.w    d5
   bne   .returnx
   move.b   #1,y1
.returnx move.l   (a7)+,x5
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x5-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return

;*****************************************************************************;
;   bildcat
;      entry conditions: d7.w = filex (0 to maxfile-1)
;         a5.l --> area to build into
;*****************************************************************************;

 XDEF bildcat

bildcat  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   lea   indflg,a0
   tst.b    0(a0,d7.w)
   bne   .ind
   move.b   ascisp,18(a5)
   bra   .1
.ind  move.b   ascii,18(a5)

.1    lea   fillock,a0
   tst.b    0(a0,d7.w)
   bne   .lock
   move.b   ascisp,16(a5)
   bra   .2
.lock    move.b   ascil,16(a5)

.2    lea   revtabl,a0   ; encode revision into catbuf
   clr.l    d0     ; cannot use encode routine to do
   move.b   0(a0,d7.w),d0   ; this, because we can't clobber
   divu  #100,d0   ; namebuf
   tst.b    d0
   bne   .3
   move.b   ascisp,12(a5)
   bra   .4
.3    move.b   d0,12(a5)
   add.b    #$30,12(a5)
.4    lsr.l    #8,d0
   lsr.l    #8,d0
   divu  #10,d0
   tst.b    d0
   bne   .6
   move.b   12(a5),d0
   cmp.b    ascisp,d0
   bne   .5
   move.b   ascisp,13(a5)
   bra   .7
.5    move.b   #$30,13(a0)
   bra   .7
.6    move.b   d0,13(a5)
   add.b    #$30,13(a5)
.7    lsr.l    #8,d0
   lsr.l    #8,d0
   move.b   d0,14(a5)
   add.b    #$30,14(a5)

   andi.l   #$FFFF,d7
   mulu  #10,d7
   move.l   #filenam,x1
   add.l    d7,x1
   move.l   a5,x2
   move.b   #10,x3
   jsr   movemem
   move.b   ascisp,10(a5)   ; blank out possible garbage
   move.b   ascisp,11(a5)
   move.b   ascisp,15(a5)
   move.b   ascisp,17(a5)

   move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers

   rts

;*****************************************************************************;
;   catout
;      entry conditions: d7.b = # of cat to write on screen, assumed to be
;      not greater than max # of cats that can fit on a screen
;*****************************************************************************;

 XDEF  catout

catout   movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   cmpi.b   #1,d7
   beq   .skipsort
   move.b   d7,d6
   subq.b   #1,d6
.sort    lea   catbuf,a0
   clr.b    d0     ; semi-alphabetize the buffer by doing
.sortloop   move.b   19(a0),d1    ; a bubble-sort on first letters
   move.b   (a0),d4   ; d1,d4 = chars to be compared

   cmp.b    #$61,d1   ; capitalize d1
   blt   .d4
   cmp.b    #$7A,d1
   bgt   .d4
   sub.b    #$20,d1
.d4   cmp.b    #$61,d4   ; capitalize d4
   blt   .dx
   cmp.b    #$7A,d4
   bgt   .dx
   sub.b    #$20,d4

.dx   cmp.b    d4,d1
   bge   .next
   move.l   a0,a1
   move.l   a0,a2
   add.l    #19,a2   ; a1,a2 --> 19-char buffers to be swapped
   moveq    #18,d2   ; d2.l = 18 to 0
.swap    move.b   0(a1,d2.l),d3
   move.b   0(a2,d2.l),0(a1,d2.l)
   move.b   d3,0(a2,d2.l)
   subq.l   #1,d2
   bge   .swap
   bra   .sort
.next    add.l    #19,a0
   addq.b   #1,d0
   cmp.b    d6,d0
   bne   .sortloop

.skipsort   clr.l    d0
   move.b   catfmt,d0
   mulu  #19,d0    ; d0 = # of non-spaces across
   clr.l    d1
   move.b   xmax,d1
   sub.b    d0,d1     ; d1= # of spaces across
   move.b   catfmt,d0
   addq.b   #1,d0     ; d0 =# of columns of spaces
   divu  d0,d1   ; d1.b = tab (# of spaces in each column of sp)

   move.b   ymax,d0
   subq.b   #4,d0     ; d0.b = last line

   move.b   cmessge,x4
   move.b   #19,x5
   move.l   #catbuf,x1
   move.b   d1,x2
   move.b   #3,x3
   move.b   x2,xcurs1
   subq.b   #1,xcurs1
   move.b   xcurs1,xcurs2
   add.b    d1,xcurs2
   add.b    #19,xcurs2
   move.b   xcurs2,xcurs3
   add.b    d1,xcurs3
   add.b    #19,xcurs3

.outloop jsr   message   ; print a column
   subq.b   #1,d7
   beq   .end
   add.l    #19,x1
   addq.b   #1,x3
   cmp.b    x3,d0
   bge   .outloop

   add.b    d1,x2
   add.b    #19,x2    ; x-coord for next column
   move.b   #3,x3     ; go to top of next column
   bra   .outloop

.end  move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   catmore -- routine to handle non-last catalog output page
;   catret  -- routine to handle last catalog output page
;*****************************************************************************;

 XDEF catmore
 XDEF catret
catmore  movem.l  D0-A6,-(a7)
   move.b   #1,moreflag
   bra   ret_more
catret   movem.l  D0-A6,-(a7)
   clr.b    moreflag
ret_more:
; compute cursor y limit on bottom of each column
   move.b   #1,ncolumns
   cmpi.b   #19,d7
   bgt   .1
   move.b   d7,ylimit1   ; only 1 column
   clr.b    ylimit2
   clr.b    ylimit3
   addq.b   #2,ylimit1
   bra   .3
.1    move.b   #21,ylimit1  ; full first column
   addq.b   #1,ncolumns  ; at least 2 columns
   sub.b    #19,d7
   cmpi.b   #19,d7
   bgt   .2
   move.b   d7,ylimit2   ; only 2 columns
   addq.b   #2,ylimit2
   clr.b    ylimit3
   bra   .3
.2    move.b   #21,ylimit2  ; full third column
   addq.b   #1,ncolumns  ; 3 columns
   sub.b    #19,d7
   move.b   d7,ylimit3
   addq.b   #2,ylimit3

; put up menu
.3    lea   locmesl,a0
   lea   locmesx,a1
   lea   locmesy,a2
   move.b   cprompt,x4
   moveq    #4,d0
menuloop move.l   d0,d1
   mulu  #25,d1
   move.l   #locmess,x1
   add.l    d1,x1
   move.b   0(a0,d0.l),x5
   tst.b    d0
   bne   do_menu
   tst.b    moreflag
   beq   keyloop
do_menu  move.b   (a1)+,x2
   move.b   (a2)+,x3
   jsr   message
   subq.b   #1,d0
   bge   menuloop

   bra   keyloop
@bell    jsr bell

keyloop jsr   getkey
   move.b   y1,d0
   cmp.b    ascicr,d0
   beq   .returnx
   cmp.b    ascihelp,d0
   beq   .hardcopy
   cmp.b    ascir,d0
   beq   .read
   cmp.b    ascie,d0
   beq   .erase
   tst.b    moreflag
   beq   @bell
   cmp.b    ascim,d0
   bne   @bell
   bra   .return
.hardcopy   move.b   #21,x1
   jsr   hardtext
   bra   keyloop
.read    clr.b    catfunc
   move.l   #readmess,x1
   bra   file_fun
.erase   move.b   #1,catfunc
   move.l   #erasmess,x1
   bra   file_fun
.returnx movem.l  (a7)+,D0-A6
   addq.l   #4,a7     ; exit from this module
   clr.b    y1
   move.l   (a7)+,x5
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
.return  movem.l  (a7)+,D0-A6
   rts

file_fun move.b   #1,x2
   move.b   ymax,x3
   subq.b   #2,x3
   move.b   cmenhed,x4
   move.b   readmesl,x5
   jsr   message
   movem.l  D0-A6,-(a7)  ; enable mouse
   move.l   #setmous,-(a7)
   move.w   #3,-(a7)
   move.w   #25,-(a7)
   trap  #14
   addq.l   #8,a7
   movem.l  (a7)+,D0-A6
   move.b   #1,allowms
   clr.l    d5
   clr.l    d6
   clr.l    d7
   move.b   xcurs1,d6     ; initialize cursor position
   move.b   #3,d7
   move.b   #1,d5
   bra   cursloop
setmous  dc.b    10,39,7,4
cursbell   jsr   bell
cursloop   move.b   #3,x1
   move.b   d6,x2
   move.b   d7,x3
   move.b   cprompt,x4
   jsr   outchar    ; put up cursor
curskey jsr   getkey
   move.b   y1,d0
   cmp.b    ascilef,d0
   beq   .left
   cmp.b    ascirit,d0
   beq   .right
   cmp.b    asciup,d0
   beq   .up
   cmp.b    ascidwn,d0
   beq   .down
   cmp.b    ascimlef,d0
   beq   select
   cmp.b    ascimrit,d0
   beq   abort
   bra   cursbell
.left    cmp.b    xcurs1,d6
   beq   curskey
   bsr   blnkcur
   subq.b   #1,d5
   cmp.b    xcurs2,d6
   bne   .left2
   move.b   xcurs1,d6
   bra  cursloop
.left2   move.b   xcurs2,d6
   bra   cursloop
.right   cmp.b    ncolumns,d5
   beq   curskey
   cmp.b    #1,d5
   bne   .right2
   cmp.b    ylimit2,d7
   bgt   curskey
   bra   .right3
.right2  cmp.b    #2,d5
   bne   .right3
   cmp.b    ylimit3,d7
   bgt   curskey
.right3  bsr   blnkcur
   addq.b   #1,d5
   cmp.b    xcurs1,d6
   bne   .rightx
   move.b   xcurs2,d6
   bra   cursloop
.rightx  move.b   xcurs3,d6
   bra   cursloop
.up   cmp.b    #3,d7
   beq   curskey
   bsr   blnkcur
   subq.b   #1,d7
   bra   cursloop
.down    cmp.b    #1,d5
   bne   .down2
   cmp.b    ylimit1,d7
   beq   curskey
   bra   .downx
.down2   cmp.b    #2,d5
   bne   .down3
   cmp.b    ylimit2,d7
   beq   curskey
   bra   .downx
.down3   cmp.b    ylimit3,d7
   beq   curskey
.downx   bsr   blnkcur
   addq.b   #1,d7
   bra   cursloop
blnkcur  move.b   ascisp,x1
   move.b   d6,x2
   move.b   d7,x3
   move.b   cbakgnd,x4
   jsr   outchar
   rts
select  move.l   d5,d0
   subq.l   #1,d0
   mulu  #19,d0
   add.l    d7,d0
   subq.l   #3,d0
   mulu  #19,d0    ; d0.l = index into catbuf
   lea   catbuf,a0
   add.l    d0,a0     ; a0 --> file name
   move.l   a0,x1
   move.l   #namebuf,x2
   move.b   #10,x3
   jsr   movemem   ; move file name into namebuf
   jsr   findfil
   move.w   y1,d0     ; d0.w = file handle
   beq   cursbell
   tst.b    catfunc
   bne   .select1
   move.w   d0,x1
   jsr   usefile   ; read a file to WS
   move.l   #wkspace,x1
   jsr   checkws
   tst.b    monws
   beq   abort
   jsr   wstosyn
   jsr   writdx7
   move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7
   bra   abort
.select1 lea   fillock,a1   ; erase a file
   subq.l   #1,a1
   tst.b    0(a1,d0.w)
   bne   cursbell
   move.w   d0,x1
   jsr   scratch
   jsr   writinfo
   move.l   #blank19,x1
   move.b   d6,x2
   addq.b   #1,x2
   move.b   d7,x3
   move.b   cmenhed,x4
   move.b   #19,x5
   jsr   message
   bra   curskey
abort   bsr   blnkcur
   movem.l  D0-A6,-(a7) ; disable mouse
   move.l   #remouse,-(a7)
   move.w   #2,-(a7)
   move.w   #25,-(a7)
   trap  #14
   addq.l   #8,a7
   movem.l  (a7)+,D0-A6
   clr.b    allowms
   move.b   ymax,x1
   subq.b   #2,x1
   jsr   blnkln
   bra   keyloop
remouse  dc.b    18,8,0

;*****************************************************************************;
;   local data structures
;*****************************************************************************;

 SECTION _MERGED,bss

catdat1  ds.b   4
catdat2  ds.b   2
catdat3  ds.b   4
catdat4  ds.b   4
catdat5  ds.b   1
moreflag ds.b   1
catfunc  ds.b   1     ; = 0 read, =1 erase
xcurs1   ds.b   1
xcurs2   ds.b   1
xcurs3   ds.b   1
ncolumns ds.b   1
ylimit1  ds.b   1
ylimit2  ds.b   1
ylimit3  ds.b   1
fixbuf   ds.b   10    ; contains pre/suf/in fix, or encoded rev range

 SECTION fred,data

locmess  dc.b    "[m]  more... xxxxxxxxxxx "
   dc.b    "[cr] go to catalog menu x"
   dc.b    "[help]  hardcopy xxxxxxxx"
   dc.b    "[e]  erase file xxxxxxxxx"
   dc.b    "[r]  read file to WS xxxx"
locmesl  dc.b     12,23,16,15,20
locmesx  dc.b     1,1,30,30,65
locmesy  dc.b     24,25,24,25,24
blank19  dc.b    "---- (erased) ---- "
readmess dc.b    "Left button to read file, right button to cancel. "
erasmess dc.b    "Left button to erase file, right button to cancel."
readmesl dc.b     50
