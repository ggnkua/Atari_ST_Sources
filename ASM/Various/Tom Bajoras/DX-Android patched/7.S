;*****************************************************************************;
;   module 7 source file Copyright 1986 Tom Bajoras
;   index menu command processing routines:
;      copindx,swpindx,scrindx,undoind,creindx,edtindx
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION seven,code

;*****************************************************************************;
;   copindx
;      x1.w = from index #, x2.w = to index # (both are 1-maxfile)
;      y1.b = disk error codes
;*****************************************************************************;

 XDEF copindx

 XREF readindx
 XREF bell
 XREF hardtext
 XREF getkey
 XREF outchar
 XREF line
 XREF setcolor
 XREF blnkscr
 XREF message
 XREF writindx
 XREF getchar

copindx  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x2
   move.l   x2,-(a7)

   move.w   x2,d7
   move.l   #indbuf1,x2
   jsr   readindx  ; get 1st index
   tst.b    y1
   bne   .return   ; go no farther if something's wrong
   move.w   d7,x1
   jsr   writindx  ; copy it to 2nd index
   tst.b    y1
   bne   .return   ; go no farther if something's wrong

   lea   indflg,a0
   subq.w   #1,d7
   tst.b    0(a0,d7.w)   ; 2nd file already indexed?
   bne   .return
   move.b   #1,0(a0,d7.w)   ; no:  Now it is.
   addq.w   #1,nfilind

.return  move.l   (a7)+,x2  ; restore x2-x1
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; and return

;*****************************************************************************;
;   swpindx
;      x1.w = first index #, x2.w = second index # (both are 1-maxfile)
;      y1.b = disk error codes
;*****************************************************************************;

 XDEF swpindx

swpindx  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x2
   move.l   x2,-(a7)
   move.w   x1,d1     ; d1.w = 1st filex
   move.w   x2,d2     ; d2.w = 2nd filex

   move.l   #indbuf1,x2
   jsr   readindx  ; read 1st index to indbuf1
   tst.b    y1
   bne   .return   ; go no farther if read failed
   move.l   #indbuf2,x2
   move.w   d2,x1
   jsr   readindx  ; read 2nd index to indbuf2
   tst.b    y1
   bne   .return   ; go no farther if read failed

   move.l   #indbuf1,x2
   move.w   d2,x1
   jsr   writindx  ; write indbuf1 to 2nd index
   tst.b    y1
   bne   .return   ; go no farther if write failed
   move.l   #indbuf2,x2
   move.w   d1,x1
   jsr   writindx  ; write indbuf2 to 1st index

.return  move.l   (a7)+,x2  ; restore x2-x1
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; and return

;*****************************************************************************;
;   scrindx
;      x1.w = index # to scratch (1-maxfile)
;*****************************************************************************;

 XDEF scrindx

scrindx  move.l   a0,-(a7) ; save a0 and d0
   move.l   d0,-(a7)
   move.w   x1,d0
   subq.w   #1,d0    ; d0.w = filex-1
   lea   indflg,a0
   clr.b    0(a0,d0.w)  ; clear file indexed flag
   subq.w   #1,nfilind  ; decrement # of indexed files
   move.l   (a7)+,d0 ; restore d0 and a0
   move.l   (a7)+,a0
   rts      ; return

;*****************************************************************************;
;   undoind
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF undoind

undoind  movem.l  D0-A6,-(a7)  ; save registers

   lea   fileflg,a0
   lea   indflg,a1

   clr.w    d0    ; d0 = 0 to maxfile-1

.1    tst.b    0(a0,d0.w)   ; exists?
   beq   .2     ; no: skip it
   tst.b    0(a1,d0.w)   ; indexed?
   beq   .2     ; no: skip it
   clr.b    0(a1,d0.w)   ; yes: clear indexed flag
   subq.w   #1,nfilind   ; and decrement # of indexed files
   beq   @return   ; done when no files are indexed

.2    addq.w   #1,d0
   cmp.w    maxfile,d0
   bne   .1

@return  movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   creindx
;      x1.w = index # to create (1-maxfile)
;*****************************************************************************;

 XDEF creindx

creindx  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)
   move.b   #1,invtext   ; invert cursor

   move.w   x1,d7     ; d7.w = filex
   clr.l    d6     ; entry condition for heading routine
   bsr   heading   ; blank screen/write heading
   bra   go     ; go to create/edit common code

;*****************************************************************************;
;   edtindx
;      x1.w = index # to edit (1-maxfile)
;*****************************************************************************;

 XDEF edtindx

edtindx  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)
   move.b   #1,invtext   ; invert cursor

   move.w   x1,d7     ; d7.w = filex
   move.l   #indbuf1,x2
   jsr   readindx  ; read specified index into indbuf1
   tst.b    y1
   bne   error     ; go no farther if read failed

   moveq    #1,d6     ; entry condition for heading routine
   bsr   heading

   move.l   #indbuf1,x1
   move.b   #20,x2
   move.b   #4,x3
   move.b   cmessge,x4
   move.b   #42,x5
   jsr   message   ; write indbuf1 to screen
   add.l    #42,x1    ; 42 characters (1/3 of index)
   add.b    #2,x3     ; at a time
   jsr   message
   add.l    #42,x1
   add.b    #2,x3
   jsr   message

   bra   go

;*****************************************************************************;
;   heading -- local routine to prepare screen for create/edit index
;*****************************************************************************;

heading  movem.l  D0-A6,-(a7)

   jsr   blnkscr
   move.b   #6,x1     ; change colors
   jsr   setcolor

   lea   indmesl,a0
   move.b   0(a0,d6.l),d1
   move.b   xmax,d0
   sub.b    d1,d0
   sub.b    #11,d0
   lsr.b    #1,d0
   move.b   d0,x2
   move.l   #indmess,x1
   mulu  #40,d6
   add.l    d6,x1
   move.b   #1,x3
   move.b   cmenhed,x4
   move.b   d1,x5     ; "create index for" or
   jsr   message   ; "edit index for"

   move.l   #filenam,x1
   clr.l    d0
   move.w   d7,d0
   subq.w   #1,d0
   mulu  #10,d0
   add.l    d0,x1
   add.b    d1,x2
   addq.b   #1,x2
   move.b   cmessge,x4
   move.b   #10,x5
   jsr   message   ; append file name to heading

   move.b   coutlne,x5   ; rectangle
   move.w   #149,x1
   move.w   #21,x2
   move.w   #490,x3
   move.w   #21,x4
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #66,x4
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #149,x3
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #21,x4
   jsr   line

   movem.l  (a7)+,D0-A6
   rts

;*****************************************************************************;
;   go -- common code for create/edit index (local)
;*****************************************************************************;

go    move.b   asciline,x1
   move.b   ymax,x3
   sub.b    #11,x3
   move.b   coutlne,x4
   moveq    #1,d0
.line    move.b   d0,x2
   jsr   outchar   ; draw line above menu
   addq.b   #1,d0
   cmp.b    xmax,d0
   ble   .line

   lea   indmesl,a0
   move.l   #indmess,x1
   add.l    #120,x1
   addq.b   #2,x3
   move.b   cmenkey,x4
   move.b   3(a0),x5
   move.b   xmax,d0
   sub.b    8(a0),d0
   sub.b    #20,d0
   sub.b    7(a0),d0
   lsr.b    #1,d0
   move.b   d0,x2     ; center all this based on 3rd line
   jsr   message
   add.b    #20,x2
   add.l    #40,x1
   move.b   cmenu,x4
   move.b   4(a0),x5
   jsr   message   ; hardcopy

   addq.b   #1,x3
   move.b   d0,x2
   add.l    #40,x1
   move.b   cmenkey,x4
   move.b   5(a0),x5
   jsr   message
   add.b    #20,x2
   add.l    #40,x1
   move.b   cmenu,x4
   move.b   6(a0),x5
   jsr   message   ; cursor control

   addq.b   #1,x3
   move.b   d0,x2
   add.l    #40,x1
   move.b   cmenkey,x4
   move.b   7(a0),x5
   jsr   message
   add.b    #20,x2
   add.l    #40,x1
   move.b   cmenu,x4
   move.b   8(a0),x5
   jsr   message   ; backspace

   addq.b   #1,x3
   move.b   d0,x2
   add.l    #40,x1
   move.b   cmenkey,x4
   move.b   9(a0),x5
   jsr   message
   add.b    #20,x2
   add.l    #40,x1
   move.b   cmenu,x4
   move.b   10(a0),x5
   jsr   message   ; clear/home

   addq.b   #1,x3
   move.b   d0,x2
   add.l    #40,x1
   move.b   cmenkey,x4
   move.b   11(a0),x5
   jsr   message
   add.b    #20,x2
   add.l    #40,x1
   move.b   cmenu,x4
   move.b   12(a0),x5
   jsr   message   ; undo

   addq.b   #1,x3
   move.b   d0,x2
   add.l    #40,x1
   move.b   cmenkey,x4
   move.b   13(a0),x5
   jsr   message
   add.b    #20,x2
   add.l    #40,x1
   move.b   cmenu,x4
   move.b   14(a0),x5
   jsr   message   ; finish

   addq.b   #1,x3
   move.b   d0,x2
   move.l   #indmess,x1
   add.l    #720,x1
   move.b   cmenkey,x4
   move.b   18(a0),x5
   jsr   message
   add.b    #20,x2
   add.l    #40,x1
   move.b   cmenu,x4
   move.b   19(a0),x5
   jsr   message   ; delete

   addq.b   #1,x3
   move.b   d0,x2
   move.l   #indmess,x1
   add.l    #800,x1
   move.b   cmenkey,x4
   move.b   20(a0),x5
   jsr   message
   add.b    #20,x2
   add.l    #40,x1
   move.b   cmenu,x4
   move.b   21(a0),x5
   jsr   message   ; insert

   addq.b   #2,x3
   move.b   d0,x2
   move.l   #indmess,x1
   add.l    #600,x1
   move.b   15(a0),x5
   jsr   message   ; 'Any printable key.'

   move.b   #20,d5    ; d5 = current cursor x
   move.b   #4,d6     ; d6 = current cursor y
   move.b   #20,d4    ; d4 = leftmost column
   move.b   #61,d3    ; d3 = rightmost column

.keyloop bsr   .cursor

   jsr   getkey    ; get a key
   move.b   y1,d0     ; d0.b = key

   cmp.b    ascihelp,d0
   beq   .help
   cmp.b    ascilef,d0   ; branch according to keys
   beq   .left
   cmp.b    ascirit,d0
   beq   .right
   cmp.b    asciup,d0
   beq   .up
   cmp.b    ascidwn,d0
   beq   .down
   cmp.b    ascicr,d0
   beq   .cr
   cmp.b    ascitab,d0
   beq   .tab
   cmp.b    ascibs,d0
   beq   .bs
   cmp.b    ascihome,d0
   beq   .home
   cmp.b    asciesc,d0
   beq   .esc
   cmp.b    asciundo,d0
   beq   .undo
   cmp.b    ascidel,d0
   beq   .del
   cmp.b    asciins,d0
   beq   .ins
   cmp.b    ascisp,d0
   blt   .bad

   move.b   d0,x1     ; printable key
   move.b   d5,x2
   move.b   d6,x3
   move.b   cmessge,x4
   jsr   outchar
   bsr   .forward  ; move cursor
   bra   .keyloop  ; get another key

.help    move.b   #8,x1
   jsr   hardtext  ; hardcopy
   bra   .keyloop

.left    bsr   .blnkcur  ; left arrow
   subq.b   #1,d5
   cmp.b    d4,d5
   bge   .keyloop
   move.b   d3,d5
   subq.b   #2,d6
   cmpi.b   #4,d6
   bge   .keyloop
   move.b   #8,d6
   bra   .keyloop

.right   bsr   .forward  ; right arrow
   bra   .keyloop

.up   bsr   .blnkcur  ; up arrow
   subq.b   #2,d6
   cmpi.b   #4,d6
   bge   .keyloop
   move.b   #8,d6
   bra   .keyloop

.down    bsr   .blnkcur  ; down arrow
.down_cr addq.b   #2,d6
   cmpi.b   #8,d6
   ble   .keyloop
   move.b   #4,d6
   bra   .keyloop

.cr   bsr   .blnkcur
   move.b   d4,d5     ; carriage return
   bra   .down_cr

.tab  bsr   .blnkcur
   add.b    #9,d5
   cmp.b    d3,d5
   beq   .keyloop
   subq.b   #1,d5
   cmp.b    d3,d5
   blt   .keyloop
   move.b   d3,d5
   bra   .keyloop

.undo    lea   indflg,a0
   subq.l   #1,a0
   tst.b    0(a0,d7.w)
   beq   .home
   bsr   .blnkcur
   move.l   #indbuf1,x1
   move.b   #20,x2
   move.b   #4,x3
   move.b   cmessge,x4
   move.b   #42,x5
   jsr   message   ; write indbuf1 to screen
   add.l    #42,x1    ; 42 characters (1/3 of index)
   add.b    #2,x3     ; at a time
   jsr   message
   add.l    #42,x1
   add.b    #2,x3
   jsr   message
   move.b   #20,d5
   move.b   #4,d6
   bra   .keyloop

.del  move.b   d5,d0
   addq.b   #1,d0
   move.b   d6,x3
   move.b   cmessge,x4

.del_x   move.b   d0,x1
   move.b   x3,x2
   jsr   getchar
   move.b   x1,x2
   subq.b   #1,x2
   move.b   y1,x1
   jsr   outchar  ; shift all characters to left
   addq.b   #1,d0
   cmp.b    d3,d0
   ble   .del_x
   move.b   ascisp,x1
   move.b   d3,x2
   move.b   cbakgnd,x4
   jsr   outchar  ; blank out last character
   bra   .keyloop

.ins  move.b   d3,d0
   subq.b   #1,d0
   move.b   d6,x3
   move.b   cmessge,x4

.ins_x   move.b   d0,x1
   move.b   x3,x2
   jsr   getchar
   move.b   x1,x2
   addq.b   #1,x2
   move.b   y1,x1
   jsr   outchar   ; shift all characters to right
   subq.b   #1,d0
   cmp.b    d5,d0
   bge   .ins_x
   move.b   ascisp,x1
   move.b   d5,x2
   move.b   cbakgnd,x4
   jsr   outchar   ; blank out first character
   bra   .keyloop

.bs   move.b   ascisp,x1    ; backspace
   move.b   d5,x2
   move.b   d6,x3
   move.b   cbakgnd,x4
   jsr   outchar
   bra   .left

.home    bsr   .blnkcur  ; clear/home
   move.b   ascisp,x1
   move.b   cbakgnd,x4
   move.b   #4,x3
.home_y  move.b   d4,x2
.home_x  jsr   outchar
   addq.b   #1,x2
   cmp.b    x2,d3
   bge   .home_x
   addq.b   #2,x3
   cmpi.b   #8,x3
   ble   .home_y
   move.b   d4,d5
   move.b   #4,d6
   bra   .keyloop

.bad  jsr   bell   ; bad key
   bra   .keyloop

.esc  lea   indbuf1,a0   ; finish
   clr.b    invtext   ; normal cursor
   clr.b    d1     ; d1 = 0 if all spaces, else = 1
   move.b   ascisp,d0

   move.b   #4,x2
.esc_y   move.b   d4,x1
.esc_x   jsr   getchar
   cmp.b    y1,d0
   beq   .space
   moveq    #1,d1
.space   move.b   y1,(a0)+
   addq.b   #1,x1
   cmp.b    x1,d3
   bge   .esc_x
   addq.b   #2,x2
   cmpi.b   #8,x2
   ble   .esc_y

   subq.w   #1,d7
   lea   indflg,a0
   tst.b    d1
   bne   .notallsp
   tst.b    0(a0,d7.w)
   beq   return   ; file already not indexed
   clr.b    0(a0,d7.w)   ; else scratch its index
   subq.w   #1,nfilind   ; and increment # of indexed files
   bra   return

.notallsp   move.w   d7,x1
   addq.w   #1,x1
   move.l   #indbuf1,x2
   jsr   writindx  ; write new index to disk
   tst.b    y1
   bne   error     ; go no farther if write failed
   tst.b    0(a0,d7.w)
   bne   return   ; file already indexed
   move.b   #1,0(a0,d7.w)   ; else set indexed flag
   addq.w   #1,nfilind   ; and decrement # of indexed files
   bra   return

.forward bsr   .blnkcur  ; move cursor forward routine
   addq.b   #1,d5
   cmp.b    d3,d5
   ble   .for_ret
   move.b   d4,d5
   addq.b   #2,d6
   cmpi.b   #8,d6
   ble   .for_ret
   move.b   #4,d6
.for_ret rts

.blnkcur move.b   cmessge,x4   ; blank cursor
   bra   .cursorx
.cursor  move.b   cprompt,x4   ; put cursor
.cursorx move.b   d5,x1
   move.b   d6,x2
   jsr   getchar
   move.b   y1,x1
   move.b   d5,x2
   move.b   d6,x3
   jsr   outchar
   rts

;*****************************************************************************;
;   error -- local routine to handle disk i/o errors during create/edit index
;*****************************************************************************;

error    clr.b    invtext
   jsr   blnkscr   ; blank screen
   clr.b    x1     ; go to menu colors
   jsr   setcolor

   move.l   #indmess,x1
   add.l    #640,x1
   move.b   #1,x2
   move.b   #1,x3
   move.b   cmessge,x4
   lea   indmesl,a0
   move.b   16(a0),x5
   jsr   message   ; 'disk i/o error'
   add.l    #40,x1
   addq.b   #1,x3
   move.b   cprompt,x4
   move.b   17(a0),x5
   jsr   message   ; 'any key to return to index menu'
   jsr   getkey

return  move.l   (a7)+,x5
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x5-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return
