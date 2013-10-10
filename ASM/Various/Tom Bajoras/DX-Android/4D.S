;*****************************************************************************;
;   module 4d source file    Copyright 1986 Tom Bajoras
;   catalog menu command processing routine: br4anch
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION fourd,code

;*****************************************************************************;
;   br4anch
;      x1 = itemx
;*****************************************************************************;

 XDEF br4anch

 XREF branch1
 XREF branch5
 XREF branch8
 XREF branch9
 XREF branch11
 XREF branch13
 XREF findfil
 XREF value
 XREF catinfx
 XREF catsufx
 XREF catprex
 XREF parsnam
 XREF getit
 XREF creturn
 XREF catone
 XREF catrevs
 XREF catall
 XREF catlock
 XREF catnotl
 XREF catindx
 XREF catnoti

br4anch  movem.l  D0-A6,-(a7)  ; save registers,x1-x5
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.l   #3,d6      ; d6 = menux = 3 (l)
   move.l   x1,d0      ; d0 = itemx = 0-7 (l)

   tst.w    nfiles     ; all these items require
   bne   .start     ; non-empty disk
   move.l   #7,x3
   jsr   branch1
.start   tst.b    d0      ; branch according to itemx
   beq   .one
   cmpi.b   #1,d0
   beq   .prefix
   cmpi.b   #2,d0
   beq   .suffix
   cmpi.b   #3,d0
   beq   .infix
   cmpi.b   #4,d0
   beq   .all
   cmpi.b   #5,d0
   beq   .lock
   cmpi.b   #6,d0
   beq   .index
   cmpi.b   #7,d0
   beq   .unlk
   cmpi.b   #8,d0
   beq   .unind
   cmpi.b   #9,d0
   beq   .revs
.return  move.l   (a7)+,x5   ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6  ; restore registers
   rts

.one  lea   .one2,a6    ; loop back on bad name
.one2    moveq    #3,d7
   jsr   branch8    ; get file name
   jsr   findfil    ; get file handle
   move.w   y1,d1
   bgt   .one3
   move.l   #17,x2
   jsr   branch11   ; file not found: try again
.one3    move.w   d1,x1
   jsr   catone     ; catalog the file
   bra   .return

.prefix  lea   .prefix2,a6     ; loop back on bad prefix
.prefix2 move.l   d6,x1
   jsr   creturn
   move.l   #10,x1
   clr.b    x5
   jsr   getit      ; get a prefix
   tst.b    y2
   beq   .prefix3
   jsr   branch5    ; cr: abort
.prefix3 movea.l  y1,a0
   move.l   a0,x1
   jsr   parsnam    ; parse the prefix
   tst.b    y1
   beq   .prefix4
   move.l   #18,x2
   jsr   branch11   ; bad prefix: error, try again
.prefix4 jsr   catprex
   tst.b    y1      ; were any found?
   bne   .prefix5
   jsr   branch13
.prefix5 move.l   #16,x2
   lea   .prefix2,a6
   jsr   branch11

.suffix  lea   .suffix2,a6     ; loop back on bad suffix
.suffix2 move.l   d6,x1
   jsr   creturn
   move.l   #11,x1
   clr.b    x5
   jsr   getit      ; get a suffix
   tst.b    y2
   beq   .suffix3
   jsr   branch5    ; cr: abort
.suffix3 movea.l  y1,a0
   move.l   a0,x1
   jsr   parsnam    ; parse the suffix
   tst.b    y1
   beq   .suffix4
   move.l   #19,x2
   jsr   branch11   ; bad suffix: error message
.suffix4 jsr   catsufx
   tst.b    y1
   bne   .suffix5
   jsr   branch13
.suffix5 lea   .suffix2,a6
   move.l   #16,x2
   jsr   branch11

.infix   lea   .infix2,a6     ; loop back on bad infix
.infix2  move.l   d6,x1
   jsr   creturn
   move.l   #1,x1
   clr.b    x5
   jsr   getit      ; get an infix
   tst.b    y2
   beq   .infix3
   jsr   branch5    ; cr: abort
.infix3  movea.l  y1,a0
   move.l   a0,x1
   jsr   parsnam    ; parse the infix
   tst.b    y1
   beq   .infix4
   move.l   #46,x2
   jsr   branch11   ; bad infix: error message
.infix4  jsr   catinfx
   tst.b    y1
   bne   .infix5
   jsr   branch13
.infix5  lea   .infix2,a6
   move.l   #16,x2
   jsr   branch11

.all  jsr   catall     ; catalog all files
   jsr   branch13   ; re-init screen, return

.lock    tst.w    nfillok
   bne   .lock2
   move.l   #11,x3     ; no files locked: cannot catalog
   jsr   branch1
.lock2   jsr   catlock    ; catalog locked files
   jsr   branch13   ; re-init screen , return

.index   tst.w    nfilind
   bne   .index2
   move.l   #28,x3     ; no files indexed: cannot catalog
   jsr   branch1
.index2  jsr   catindx    ; catalog indexed files.
   jsr   branch13   ; re-init screen, return

.unlk    move.w   nfiles,d1
   cmp.w    nfillok,d1
   bne   .unlk2
   move.l   #15,x3     ; if nfiles=nfillok cannot catalog
   jsr   branch1
.unlk2   jsr   catnotl    ; catalog unlocked files
   jsr   branch13   ; re-init screen, return

.unind   move.w   nfiles,d1
   cmp.w    nfilind,d1
   bne   .unind2
   move.l   #19,x3     ; if nfiles=nfilind cannot catalog
   jsr   branch1
.unind2  jsr   catnoti    ; catalog unindexed files.
   jsr   branch13   ; re-init screen, return

.revs    lea   .revs2,a6      ; loop back if bad #
.revs2   moveq    #19,d7
   jsr   branch9   ; get from rev
   jsr   value
   move.l   y1,d1     ; d1.l = #
   blt   .revs3    ; bad # if < 0
   cmp.l    #$FF,d1
   bgt   .revs3    ; bad # if > 255
   bra   .revs4
.revs3   move.l   #1,x2
   jsr   branch11  ; bad # routine
.revs4   move.l   namebuf,d3   ; save 1st 4 bytes of namebuf
   lea   .revs5,a6      ; loop back if bad #
.revs5   moveq    #20,d7
   jsr   branch9   ; get to rev
   jsr   value
   move.l   y1,d2     ; d2.l = #
   blt   .revs3    ; bad # if < 0
   cmp.l    #$FF,d2
   bgt   .revs3    ; bad # if > 255
   cmp.l    d1,d2
   blt   .revs3    ; bad # if to # < from #
   move.l   namebuf,d4   ; save 1st 4 bytes of namebuf
   clr.l    d5     ; zero out namebuf
   lea   namebuf,a0
.revs6   clr.b    0(a0,d5.l)
   addq.l   #1,d5
   cmpi.l   #10,d5
   bne   .revs6
   move.l   d3,(a0)
   cmp.l    d1,d2
   beq   .revs8
   addq.l   #2,a0
   cmpi.l   #10,d1
   blt   .revs7
   addq.l   #2,a0
   cmpi.l   #100,d1
   blt   .revs7
   addq.l   #2,a0
.revs7   move.b   ascidash,(a0)
   addq.l   #2,a0
   move.l   d4,(a0)
.revs8   move.b   d1,x1
   move.b   d2,x2
   jsr   catrevs
   tst.b    y1      ; any found?
   bne   .revs9
   jsr   branch13   ; yes: return
.revs9   lea   .revs2,a6
   move.l   #16,x2
   jsr   branch11   ; no: try again
