;*****************************************************************************;
;   module 4c source file    Copyright 1986 Tom Bajoras
;   index menu command branching routine: br3anch
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION fourc,code

;*****************************************************************************;
;   br3anch
;      x1 = itemx 0-4 (l)
;*****************************************************************************;

 XDEF br3anch

 XREF branch1
 XREF branch2
 XREF branch5
 XREF branch6
 XREF branch8
 XREF branch13
 XREF undoind
 XREF scrindx
 XREF swpindx
 XREF diskerr
 XREF copindx
 XREF edtindx
 XREF writinfo
 XREF creindx
 XREF getyn
 XREF creturn
 XREF findfil
 XREF infobar
 XREF writinfo

br3anch  movem.l  D0-A6,-(a7)  ; save registers and x1-x5
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.l   x1,d0      ; d0 = itemx = 0-4 (l)
   moveq    #2,d6      ; d6 = menux = 2 (l)

   tst.w    nfiles     ; all items on this menu
   bne   .start     ; require non-empty disk
   move.l   #7,x3
   jsr   branch1    ; no files on disk
.start   tst.b    d0
   beq   .edit
   cmpi.b   #1,d0
   beq   .copy
   cmpi.b   #2,d0
   beq   .swap
   cmpi.b   #3,d0
   beq   .scratch
   cmpi.b   #4,d0
   beq   .scrall
   bra   .returnx   ; illegal itemx simply returns

.return  jsr   writinfo
   move.l   d6,x1
   jsr   infobar    ; update info bar
.returnx move.l   (a7)+,x5   ; restore registers,x1-x5,return
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6
   rts

.edit    lea   .edit2,a6       ; loop back on bad name
.edit2   moveq    #3,d7
   jsr   branch8    ; get name
   jsr   findfil    ; get file handle
   move.w   y1,d1
   bgt   .edit3
   move.l   #9,x3
   jsr   branch2    ; file not found: try again
.edit3   lea   indflg,a0
   subq.l   #1,a0
   tst.b    0(a0,d1.w)
   bne   .edit5
   move.l   d6,x1
   jsr   creturn
   move.l   #13,x1
   move.l   #14,x2
   jsr   getyn      ; file not indexed.  create index?
   tst.b    y1
   bne   .edit4
   jsr   branch6    ; no: try again
.edit4   move.w   d1,x1
   move.b   #1,allowlc    ; allow lower case input
   move.w   nfilind,d1    ; save # files indexed
   trap  #11     ; key repeat on
   jsr   creindx    ; yes: create index
   trap  #10     ; key repeat off
   clr.b    allowlc    ; stop allowing lower case input
   cmp.w    nfilind,d1    ; # files indexed has changed?
   beq   .edit6     ; if no, skip writinfo
   jsr   writinfo
   bra   .edit6
.edit5   move.w   d1,x1
   move.b   #1,allowlc    ; allow lower case input
   move.w   nfilind,d1    ; save # files indexed
   trap  #11     ; key repeat on
   jsr   edtindx    ; edit index
   trap  #10     ; key repeat off
   clr.b    allowlc    ; stop allowing lower case input
   cmp.w    nfilind,d1    ; # files indexed has changed?
   beq   .edit6     ; if no, skip writinfo
   jsr   writinfo
.edit6   jsr   branch13   ; re-init screen, return

.copy    tst.w    nfilind
   bne   .copy2
   move.l   #28,x3
   jsr   branch1    ; no files indexed
.copy2   lea   .copy3,a6     ; loop back on bad name
.copy3   moveq    #7,d7
   jsr   branch8    ; get file name
   jsr   findfil    ; get file handle
   move.w   y1,d1
   bgt   .copy4
   move.l   #9,x3      ; file not found: try again
   jsr   branch2
.copy4   lea   indflg,a1
   subq.l   #1,a1
   tst.b    0(a1,d1.w)
   bne   .copy5
   move.l   #29,x3     ; file not indexed: try again
   jsr   branch2
.copy5   lea   .copy6,a6       ; loop back on bad name
.copy6   moveq    #8,d7
   jsr   branch8    ; get 2nd file name
   jsr   findfil    ; get 2nd file handle
   move.w   y1,d2
   bgt   .copy7
   move.l   #9,x3
   jsr   branch2    ; 2nd file not found: try again
.copy7   cmp.b    d1,d2      ; 2nd filex = 1st filex: do nothing
   beq   .returnx
   tst.b    0(a1,d2.w)
   beq   .copy8
   move.l   d6,x1
   jsr   creturn
   move.l   #11,x1
   move.l   #44,x2
   jsr   getyn      ; 2nd file already indexed:
   tst.b    y1      ; replace index? (y/n)
   bne   .copy8
   jsr   branch6    ; n: try again
.copy8   move.w   d1,x1
   move.w   d2,x2
   jsr   copindx    ; copy index
   tst.b    y1
   beq   .return    ; restore registers,x1-x5,return
   jmp   diskerr

.swap    tst.w    nfilind
   bne   .swap2
   move.l   #28,x3
   jsr   branch1    ; no files indexed
.swap2   lea   .swap3,a6     ; loop back on bad name
.swap3   moveq    #12,d7
   jsr   branch8    ; get file name
   jsr   findfil    ; get file handle
   move.w   y1,d1
   bgt   .swap4
   move.l   #9,x3
   jsr   branch2    ; file not found: try again
.swap4   lea   indflg,a1
   subq.l   #1,a1
   tst.b    0(a1,d1.w)
   bne   .swap5
   move.l   #29,x3
   jsr   branch2    ; file not indexed: try again
.swap5   lea   .swap6,a6     ; loop back on bad name
.swap6   moveq    #13,d7
   jsr   branch8    ; get 2nd file name
   jsr   findfil    ; get 2nd file handle
   move.w   y1,d2
   bgt   .swap7     ; file not found: try again
   move.l   #9,x3
   jsr   branch2
.swap7   cmp.b    d1,d2      ; 1st filex = 2nd filex: do nothing
   beq   .returnx
   tst.b    0(a1,d2.w)
   bne   .swap8
   move.l   #29,x3
   jsr   branch2    ; file not indexed: try again
.swap8   move.w   d1,x1
   move.w   d2,x2
   jsr   swpindx    ; swap indexes
   tst.b    y1
   beq   .return    ; restore registers,x1-x5,return
   jmp   diskerr

.scratch tst.w    nfilind
   bne   .scratch2
   move.l   #28,x3
   jsr   branch1    ; no files indexed
.scratch2   lea   .scratch3,a6  ; loop back on bad name
.scratch3   moveq    #3,d7
   jsr   branch8    ; get file name
   jsr   findfil    ; get file handle
   move.w   y1,d1
   bgt   .scratch4
   move.l   #9,x3
   jsr   branch2    ; file not found: try again
.scratch4   lea   indflg,a1
   subq.l   #1,a1
   tst.b    0(a1,d1.w)
   bne   .scratch5
   move.l   #29,x3     ; file not indexed: try again
   jsr   branch2
.scratch5   move.w   d1,x1
   jsr   scrindx	    ; scratch index
   bra   .return

.scrall  tst.w    nfilind
   bne   .scrall2
   move.l   #28,x3
   jsr   branch1    ; no files indexed
.scrall2 move.l   d6,x1
   jsr   creturn
   move.l   #28,x1
   move.l   #6,x2
   jsr   getyn      ; are you sure ? (y/n)
   tst.b    y1
   bne   .scrall3
   jsr   branch5    ; n: abort
.scrall3 jsr   undoind    ; scratch all indexes
   bra   .return    ; restore registers,x1-x5,return
