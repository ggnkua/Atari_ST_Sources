;*****************************************************************************;
;   module 14 source file    Copyright 1986 Tom Bajoras
;   internal memory routines and edit-bank menu command processors:
;   movemem, filtows, wstofil, syntowb, wbtosyn, swapwbs, syntows,
;   edtosyn, wstosyn, wstoed, edtows, wbtowb, wstowb, wbtows, unpack, pack
;   wbtofil, filtowb, movename, synftows, synftowb, wbftosyn
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION fourteen,code

;*****************************************************************************;
;   movemem
;      x1 = from address (l), x2 = to address (l), x3 = # bytes (b) 1-255
;*****************************************************************************;

 XDEF movemem

movemem  movem.l  D0-A6,-(a7)   ; save registers
   clr.l    d0
   move.b   x3,d0    ; # of bytes to move
   movea.l  x1,a0    ;  a0 --> start of source area
   movea.l  x2,a1    ;  a1 --> start of destination area

movemem1 subq.w   #1,d0    ;  move a byte at a time
   blt   movemem2
   move.b   (a0)+,(a1)+
   bra   movemem1

movemem2 movem.l  (a7)+,D0-A6   ; restore registers
   rts         ; and return

;*****************************************************************************;
;   filtows
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF filtows

filtows  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   lea   filebuf,a0
   lea   wkspace,a1
   bsr   buf_to_w  ; unpack filebuf into w.s.

   move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   wstofil
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF wstofil

wstofil  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   lea   wkspace,a0
   lea   filebuf,a1
   bsr   w_to_buf  ; pack w.s. into filebuf

   move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   syntowb
;      x1 = slotx = 1-32 (b)
;*****************************************************************************;

 XDEF syntowb

syntowb  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   clr.l    d0
   move.b   x1,d0
   subq.l   #1,d0     ; d0.l = slotx = 0-31
   move.l   #synbuf,x1
   add.l    #6,x1
   move.l   #wkbank,x2
   move.l   d0,d2
   mulu  #160,d2
   add.l    d2,x2
   move.b   #145,x3
   jsr   movemem   ; copy non-name part of buffer

   add.l    #145,x1   ; copy name part of buffer
   move.l   #wkbname,x2
   mulu  #10,d0
   add.l    d0,x2
   jsr   movename

   move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   wbtosyn
;      x1 = slotx = 1-32 (b)
;*****************************************************************************;

 XDEF wbtosyn

wbtosyn  movem.l  D0-A6,-(a7) ; store registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   clr.l    d0
   move.b   x1,d0
   subq.l   #1,d0     ; d0.l = slotx = 0-31

   move.l   #wkbank,x1
   move.l   d0,d1
   mulu  #160,d1
   add.l    d1,x1
   move.l   #synbuf,x2
   add.l    #6,x2
   move.b   #145,x3
   jsr   movemem   ; copy w.b. slot to synbuf

   lea   wkbname,a0   ; copy w.b. slot name to synbuf name
   mulu  #10,d0    ; but change all underscores to spaces
   add.l    d0,a0
   lea   synbuf,a1    ; but change all underscores to spaces
   add.l    #151,a1
   clr.b    d0     ; for d0 = 0 to 9
.1    move.b   (a0)+,d1
   cmp.b    asciline,d1
   bne   .2
   move.b   ascisp,d1
.2    move.b   d1,(a1)+
   addq.b   #1,d0
   cmpi.b   #10,d0
   bne   .1

   move.l   #synbuf,a0    ; prepare synbuf header
   move.l   #$F0430000,(a0)
   move.b   midich,2(a0)
   sub.b    #1,2(a0)
   move.w   #$011B,4(a0)

   addq.l   #6,a0
   clr.l    d0
   clr.l    d1
.3    add.b    0(a0,d1.l),d0
   addq.l   #1,d1
   cmpi.l   #155,d1
   bne   .3
   neg.b    d0
   andi.l   #$7F,d0
   move.b   d0,155(a0)    ; checksum
   move.b   #$F7,156(a0)  ; end of system exclusive info

   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1   ; restore x3-x1
   movem.l  (a7)+,D0-A6  ; restore registers
   rts        ; return

;*****************************************************************************;
;   swapwbs
;      x1 = 1stx = 1-32 (b) , x2 = 2ndx = 1-32 (b)
;*****************************************************************************;

 XDEF swapwbs

swapwbs  movem.l  D0-A6,-(a7)  ; save registers

   clr.l    d0
   move.b   x1,d0
   subq.l   #1,d0     ; d0.l = 1stx = 0-31
   clr.l    d1
   move.b   x2,d1
   subq.l   #1,d1     ; d1.l = 2ndx = 0-31

   lea   wkbank,a0
   move.l   d0,d2
   mulu  #160,d2
   add.l    d2,a0     ; a0 --> 1st slot
   lea   wkbank,a1
   move.l   d1,d2
   mulu  #160,d2
   add.l    d2,a1     ; a1 --> 2nd slot

   clr.b    d2     ; d2.b = 1 to 160
.1    move.b   (a0),d3     ; swap slot data
   move.b   (a1),(a0)
   move.b   d3,(a1)
   addq.l   #1,a0
   addq.l   #1,a1
   addq.b   #1,d2
   cmpi.b   #160,d2
   bne   .1

   lea   wkbname,a0
   mulu  #10,d0
   add.l    d0,a0     ; a0 --> 1st slot name
   lea   wkbname,a1
   mulu  #10,d1
   add.l    d1,a1     ; a1 --> 2nd slot name

   clr.b    d2     ; d2.b = 1 to 10
.2    move.b   (a0),d3     ; swap slot name data
   move.b   (a1),(a0)
   move.b   d3,(a1)
   addq.l   #1,a0
   addq.l   #1,a1
   addq.b   #1,d2
   cmpi.b   #10,d2
   bne   .2

   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   syntows
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF syntows

syntows  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   move.l   #synbuf,x1
   add.l    #6,x1
   move.l   #wkspace,x2
   move.b   #145,x3   ; copy non-name part of buffer
   jsr   movemem   ; leaving w.s. f-pars unchanged

   add.l    #145,x1   ; copy name part of buffer
   move.l   #wksname,x2
   jsr   movename

   move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   edtosyn
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF edtosyn

edtosyn  movem.l  D0-A6,-(a7) ; store registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   move.l   #edspace,x1
xtosyn   move.l   #synbuf,x2   ; wstosyn comes here too
   add.l    #6,x2
   move.b   #145,x3
   jsr   movemem   ; copy w.s. to synbuf

   lea   wksname,a0   ; copy w.s. name to synbuf name
   lea   synbuf,a1    ; but change all underscores to spaces
   add.l    #151,a1
   clr.b    d0     ; for d0 = 0 to 9
.1    move.b   (a0)+,d1
   cmp.b    asciline,d1
   bne   .2
   move.b   ascisp,d1
.2    move.b   d1,(a1)+
   addq.b   #1,d0
   cmpi.b   #10,d0
   bne   .1

   move.l   #synbuf,a0
   move.l   #$F0430000,(a0)  ; prepare synbuf header
   move.b   midich,2(a0)
   sub.b    #1,2(a0)
   move.w   #$011B,4(a0)

   addq.l   #6,a0
   clr.l    d0
   clr.l    d1
.3    add.b    0(a0,d1.l),d0
   addq.l   #1,d1
   cmpi.l   #155,d1
   bne   .3
   neg.b    d0
   andi.l   #$7F,d0
   move.b   d0,155(a0)    ; checksum
   move.b   #$F7,156(a0)  ; end of system exclusive info

   move.l   (a7)+,x3   ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6  ; restore registers
   rts        ; return

;*****************************************************************************;
;   wstosyn
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF wstosyn

wstosyn  movem.l  D0-A6,-(a7) ; store registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   move.l   #wkspace,x1
   bra   xtosyn    ; go to wstosyn/edtosyn common code

;*****************************************************************************;
;   wstoed
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF wstoed

wstoed   movem.l  D0-A6,-(a7)
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   move.l   #wkspace,x1
   move.l   #edspace,x2
   move.b   #160,x3
   jsr   movemem

   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6
   rts

;*****************************************************************************;
;   edtows
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF edtows

edtows   movem.l  D0-A6,-(a7)
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   move.l   #edspace,x1
   move.l   #wkspace,x2
   move.b   #160,x3
   jsr   movemem

   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6
   rts

;*****************************************************************************;
;   wbtowb
;      x1 = fromx = 1-32 (b) , x2 = tox = 1-32 (b)
;*****************************************************************************;

 XDEF wbtowb

wbtowb   movem.l  D0-A6,-(a7)   ; save registers
   move.l   x1,-(a7)    ; save x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   clr.l    d0
   clr.l    d1
   move.b   x1,d0
   subq.l   #1,d0    ; d0.l = from slotx = 0-31
   move.b   x2,d1
   subq.l   #1,d1    ; d1.l = to slotx = 0-31
   move.l   #wkbank,x1
   move.l   #wkbank,x2
   move.l   d0,d2
   mulu  #160,d2
   add.l    d2,x1    ; x1 --> specified workbank from slot
   move.l   d1,d2
   mulu  #160,d2
   add.l    d2,x2    ; x2 --> specified workbank to slot
   move.b   #160,x3
   jsr   movemem  ; copy w.s. to w.b. slot

   move.l   #wkbname,x1
   move.l   #wkbname,x2
   mulu  #10,d0
   add.l    d0,x1    ; x1 --> from slot name
   mulu  #10,d1
   add.l    d1,x2    ; x2 --> to slot name
   move.b   #10,x3
   jsr   movemem  ; copy w.s. name to w.b. slot name

   move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return



;*****************************************************************************;
;   wstowb
;      x1 = slotx = 1-32 (b)
;*****************************************************************************;

 XDEF wstowb

wstowb   movem.l  D0-A6,-(a7)   ; save registers
   move.l   x1,-(a7)    ; save x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   clr.l    d0
   move.b   x1,d0
   subq.l   #1,d0    ; d0.l = slotx = 0-31
   move.l   #wkspace,x1
   move.l   #wkbank,x2
   move.l   d0,d1
   mulu  #160,d1
   add.l    d1,x2    ; x2 --> specified workbank slot
   move.b   #160,x3
   jsr   movemem  ; copy w.s. to w.b. slot

   move.l   #wksname,x1
   move.l   #wkbname,x2
   mulu  #10,d0
   add.l    d0,x2
   move.b   #10,x3
   jsr   movemem  ; copy w.s. name to w.b. slot name

   move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return


;*****************************************************************************;
;   wbtows
;      x1 = slotx = 1-32 (b)
;*****************************************************************************;

 XDEF wbtows

wbtows   movem.l  D0-A6,-(a7)  ; save registers
   move.l   x1,-(a7)   ; save x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   clr.l    d0
   move.b   x1,d0
   subq.l   #1,d0    ; d0.l = slotx = 0-31
   move.l   #wkbank,x1
   move.l   d0,d1
   mulu  #160,d1
   add.l    d1,x1    ; x1 --> specified w.b. slot
   move.l   #wkspace,x2
   move.b   #160,x3
   jsr   movemem  ; copy w.b. slot to w.s.

   move.l   #wkbname,x1
   mulu  #10,d0
   add.l    d0,x1    ; x1 --> specified w.b. slot name
   move.l   #wksname,x2
   move.b   #10,x3
   jsr   movemem  ; copy w.b. slot name to w.s. name

   move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   unpack
;      x1.l --> from area (0/1 flags packed 8 per byte)
;      x2.l --> to area (0/1 flags will be 1 per byte, right justified)
;      x3.w --> # of bytes in to area
;*****************************************************************************;

 XDEF unpack

unpack   movem.l  D0-A6,-(a7)  ; save registers
   move.l   x3,-(a7)   ; save x3

   move.l   x1,a0    ; a0 --> from area
   move.l   x2,a1    ; a1 --> to area
.1    moveq    #7,d1    ; for d1 = 7 to 0
.2    btst  d1,(a0)
   beq   .3
   move.b   #1,(a1)+
   bra   .4
.3    clr.b    (a1)+
.4    sub.w    #1,x3    ; done?
   beq   .return
   subq.l   #1,d1
   bge   .2
   addq.l    #1,a0
   bra   .1

.return  move.l   (a7)+,x3  ; restore x3
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   pack
;      x1.l --> from area (0/1 flags 1 per byte, right justified)
;      x2.l --> to area (0/1 flags will be packed 8 per byte, left to right)
;      x3.l --> # of bytes in from area
;*****************************************************************************;

 XDEF pack

pack  movem.l  D0-A6,-(a7) ; save registers
   move.l   x3,-(a7)  ; and x3

   move.l   x1,a0     ; a0 --> from area
   move.l   x2,a1     ; a1 --> to area

.1    moveq    #7,d1     ; for d1 = 7 to 0
   clr.b    (a1)
.2    move.b   (a0)+,d7
   lsl.b    d1,d7
   or.b  d7,(a1)
   sub.w    #1,x3     ; done ?
   beq   .return
   subq.l   #1,d1
   bge   .2
   addq.l   #1,a1
   bra   .1

.return  move.l   (a7)+,x3  ; restore x3
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   wbtofil
;      no entry conditions, no exit conditions
;      packs w.b. into 4096 bytes in filebuf
;*****************************************************************************;

 XDEF wbtofil

wbtofil  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   lea   wkbank,a0
   lea   filebuf,a1
   clr.l    d7
.1    bsr   w_to_buf  ; pack w.b. into filebuf, 1 slot
   addq.b   #1,d7     ; at a time
   cmpi.b   #32,d7
   beq   .2
   add.l    #160,a0
   add.l    #128,a1
   bra   .1

.2    move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x3-x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   filtowb
;      no entry conditions, no exit conditions
;      unpacks 4096 bytes in filebuf into w.b.
;*****************************************************************************;

 XDEF filtowb

filtowb  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   lea   filebuf,a0
   lea   wkbank,a1
   clr.l    d7
.1    bsr   buf_to_w  ; unpack filebuf into w.b., 1 slot
   addq.b   #1,d7     ; at a time
   cmpi.b   #32,d7
   beq   .2
   add.l    #128,a0
   add.l    #160,a1
   bra   .1

.2    move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x3-x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   w_to_buf
;      entry conditions: a0 --> from area (160 bytes),
;      a1 --> to area (128 bytes)
;      exit conditions: a0,a1,d7 preserved
;*****************************************************************************;

 XDEF w_to_buf

w_to_buf move.l   a0,a2
   move.l   a1,a3
   moveq    #6,d6    ; per operator data (d6 = 6 to 1)

.1    move.l   a2,x1
   move.l   a3,x2
   move.b   #11,x3
   jsr   movemem  ; EG,bp,ld,rd

   move.b   11(a2),d0
   lsl.b    #2,d0
   or.b  12(a2),d0
   move.b   d0,11(a3)   ; lc,rc

   move.b   13(a2),d0
   lsl.b    #2,d0
   or.b  14(a2),d0
   lsl.b    #3,d0
   or.b  15(a2),d0
   move.b   d0,12(a3)   ; kbrt,ams,vel

   move.b   16(a2),d0
   lsl.b    #1,d0
   or.b  17(a2),d0
   move.b   d0,13(a3)    ; level,mode

   move.b   18(a2),14(a3)   ; cfq
   move.b   19(a2),15(a3)   ; ffq
   move.b   20(a2),16(a3)   ; dtn

   subq.b   #1,d6
   beq   .2
   add.l    #21,a2   ; point to next
   add.l    #17,a3   ; operator's data
   bra   .1    ; and loop

.2    move.l   a0,x1
   move.l   a1,x2
   add.l    #126,x1
   add.l    #102,x2
   move.b   #8,x3
   jsr   movemem  ; pitch eg

   move.b   134(a0),d0
   lsl.b    #1,d0
   or.b  136(a0),d0
   move.b   d0,110(a1)  ; alg,op sync

   move.b   135(a0),d0
   lsl.b    #1,d0
   or.b  141(a0),d0
   lsl.b    #3,d0
   or.b  142(a0),d0
   move.b   d0,111(a1)  ; fb,lfo sync, lfo wave

   move.b   137(a0),112(a1) ; lfo spd
   move.b   138(a0),113(a1) ; lfo dly
   move.b   139(a0),114(a1) ; pmd
   move.b   140(a0),115(a1) ; amd

   move.b   143(a0),d0
   lsl.b    #1,d0
   or.b  145(a0),d0
   lsl.b    #4,d0
   or.b  146(a0),d0
   move.b   d0,116(a1)  ; pms, mono/poly , pb range

   move.b   144(a0),d0
   lsl.b    #1,d0
   or.b  148(a0),d0
   lsl.b    #1,d0
   or.b  149(a0),d0
   move.b   d0,117(a1)  ; tr, port mode, gliss

   move.b   147(a0),118(a1) ; pb step

   move.l   a0,x1
   move.l   a1,x2
   add.l    #150,x1
   add.l    #119,x2
   move.b   #9,x3
   jsr   movemem  ; port time, controller assignments

   rts      ; return

;*****************************************************************************;
;   buf_to_w
;      entry conditions: a0 --> from area (128 bytes),
;      a1 --> to area (160 bytes)
;      exit conditions: a0,a1,d7 preserved
;*****************************************************************************;

 XDEF buf_to_w

buf_to_w move.l   a0,a2
   move.l   a1,a3
   moveq    #6,d6    ; per operator data (d6 = 6 to 1)

.1    move.l   a2,x1
   move.l   a3,x2
   move.b   #11,x3
   jsr   movemem  ; eg, bp, ld, rd

   move.b   11(a2),d0
   move.b   d0,12(a3)
   andi.b   #$3,12(a3)   ; rc
   lsr.b    #2,d0
   move.b   d0,11(a3)    ; lc

   move.b   12(a2),d0
   move.b   d0,15(a3)
   andi.b   #$7,15(a3)   ; vel
   lsr.b    #3,d0
   move.b   d0,14(a3)
   andi.b   #$3,14(a3)   ; ams
   lsr.b    #2,d0
   move.b   d0,13(a3)    ; kb rate

   move.b   13(a2),d0
   move.b   d0,17(a3)
   andi.b   #$1,17(a3)   ; mode
   lsr.b    #1,d0
   move.b   d0,16(a3)    ; level

   move.b   14(a2),18(a3)    ; cfq
   move.b   15(a2),19(a3)   ; ffq
   move.b   16(a2),20(a3)   ; dtn

   subq.b   #1,d6
   beq   .2
   add.l    #17,a2    ; point to next
   add.l    #21,a3    ; operator's data
   bra   .1     ; and loop

.2    move.l   a0,x1
   move.l   a1,x2
   add.l    #102,x1
   add.l    #126,x2
   move.b   #8,x3
   jsr   movemem   ; pitch eg

   move.b   110(a0),d0
   move.b   d0,136(a1)
   andi.b   #$1,136(a1)  ; op sync
   lsr.b    #1,d0
   move.b   d0,134(a1)   ; alg

   move.b   111(a0),d0
   move.b   d0,142(a1)
   andi.b   #$7,142(a1)  ; lfo wv
   lsr.b    #3,d0
   move.b   d0,141(a1)
   andi.b   #$1,141(a1)  ; lfo sync
   lsr.b    #1,d0
   move.b   d0,135(a1)   ; fb

   move.b   112(a0),137(a1) ; lfo spd
   move.b   113(a0),138(a1) ; lfo dly
   move.b   114(a0),139(a1) ; pmd
   move.b   115(a0),140(a1) ; amd

   move.b   116(a0),d0
   move.b   d0,146(a1)
   andi.b   #$F,146(a1)  ; pb range
   lsr.b    #4,d0
   move.b   d0,145(a1)
   andi.b   #$1,145(a1)  ; mono/poly
   lsr.b    #1,d0
   move.b   d0,143(a1)   ; pms

   move.b   117(a0),d0
   move.b   d0,149(a1)
   andi.b   #$1,149(a1)  ; gliss
   lsr.b    #1,d0
   move.b   d0,148(a1)
   andi.b   #$1,148(a1)  ; port mode
   lsr.b    #1,d0
   move.b   d0,144(a1)   ;tr

   move.b   118(a0),147(a1) ; pb step

   move.l   a0,x1
   move.l   a1,x2
   add.l    #119,x1
   add.l    #150,x2
   move.b   #9,x3
   jsr   movemem   ; port time, controller assignments

   rts       ; return

;*****************************************************************************;
;   movename
;      x1.l --> from name , x2.l --> to name
;*****************************************************************************;

 XDEF movename

movename movem.l  D0-A6,-(a7) ; save registers

   move.l   x1,a0
   move.l   x2,a1
   add.l    #10,a0    ; a0 --> end of from name + 1b
   add.l    #10,a1    ; a1 --> end of to name + 1b

   clr.b    d7     ; d7 = 1 if non-space char found
   moveq    #10,d0    ; for d0 = 10 to 1

.1    move.b   -(a0),d1  ; d1 = character
   beq   .3     ; treat null as space
   cmp.b    ascisp,d1
   beq   .3

   moveq    #1,d7     ; non-space character
.2    move.b   d1,-(a1)  ; copy it as it is
   bra   .4

.3    cmpi.b   #1,d7     ; space (or null)
   bne   .2     ; allow space fill on right
   move.b   asciline,-(a1)  ; otherwise convert space to underscore

.4    subq.b   #1,d0
   bne   .1     ; done? no: loop

   cmpi.b   #1,d7
   beq   .return
   moveq    #10,d0     ; all spaces: convert to all underscores
   move.l   x2,a1
.5    move.b   asciline,(a1)+
   subq.b   #1,d0
   bne   .5

.return  movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   synftows
;      copies tx f-par dump from synth buffer to w.s.
;*****************************************************************************;

 XDEF synftows

synftows movem.l  D0-A6,-(a7) ; save all registers
   lea   synbuf,a0
   addq.l   #6,a0    ; skip header
   lea   wkspace,a1

 XREF txtodx
 XREF dxtotx

   move.b   2(a0),145(a1)   ; mono/poly
   move.b   3(a0),146(a1)   ; pb range
   move.b   4(a0),147(a1)   ; pb step
   move.b   5(a0),150(a1)   ; port time
   move.b   6(a0),149(a1)   ; gliss on/off
   move.b   7(a0),148(a1)   ; port mode
   move.b   9(a0),x1
   jsr   txtodx
   move.b   y1,151(a1)   ; mw range
   move.b   10(a0),152(a1)  ; mw assign
   move.b   11(a0),x1
   jsr   txtodx
   move.b   y1,153(a1)  ; fc range
   move.b   12(a0),154(a1)  ; fc assign
   move.b   13(a0),x1
   jsr   txtodx
   move.b   y1,157(a1)  ; at range
   move.b   14(a0),158(a1)  ; at assign
   move.b   15(a0),x1
   jsr   txtodx
   move.b   y1,155(a1)  ; bc range
   move.b   16(a0),156(a1)  ; bc assign

   movem.l  (a7)+,D0-A6 ; restore registers
   rts

;*****************************************************************************;
;   synftowb
;      unpacks tx f-par dump from synth buffer into w.b.
;*****************************************************************************;

 XDEF synftowb

synftowb movem.l  D0-A6,-(a7) ; save registers

   lea   synbuf,a0
   addq.l   #6,a0    ; a0 --> from area (64 bytes x 32)
   lea   wkbank,a1
   add.l    #145,a1  ; a1 --> to area (160 bytes x 32)
   moveq    #32,d7   ; d7 = 32 to 1

.loop    move.b   (a0),d0
   lsr.b    #6,d0
   andi.b   #1,d0
   move.b   d0,(a1)  ; mono/poly
   move.b   1(a0),d0
   andi.b   #$F,d0
   move.b   d0,1(a1) ; pb range
   move.b   1(a0),d0
   lsr.b    #4,d0
   andi.b   #7,d0
   move.b   15(a0),d1
   lsr.b    #3,d1
   andi.b   #8,d1
   add.b    d1,d0
   move.b   d0,2(a1) ; pb step
   move.b   2(a0),5(a1) ; port time
   move.b   3(a0),d0
   andi.b   #1,d0
   move.b   d0,4(a1) ; gliss on/off
   move.b   3(a0),d0
   lsr.b    #1,d0
   andi.b   #1,d0
   move.b   d0,3(a1) ; port mode
   move.b   4(a0),x1
   andi.b   #$F,x1
   jsr   txtodx
   move.b   y1,6(a1) ; mw range
   move.b   4(a0),d0
   lsr.b    #4,d0
   andi.b   #7,d0
   move.b   d0,7(a1) ; mw assign
   move.b   5(a0),x1
   andi.b   #$F,x1
   jsr   txtodx
   move.b   y1,8(a1) ; fc range
   move.b   5(a0),d0
   lsr.b    #4,d0
   andi.b   #7,d0
   move.b   d0,9(a1) ; fc assign
   move.b   6(a0),x1
   andi.b   #$F,x1
   jsr   txtodx
   move.b   y1,12(a1)   ; at range
   move.b   6(a0),d0
   lsr.b    #4,d0
   andi.b   #7,d0
   move.b   d0,13(a1)    ; at assign
   move.b   7(a0),x1
   andi.b   #$F,x1
   jsr   txtodx
   move.b   y1,10(a1)    ; bc range
   move.b   7(a0),d0
   lsr.b    #4,d0
   andi.b   #7,d0
   move.b   d0,11(a1)    ; bc assign

   add.l    #64,a0
   add.l    #160,a1
   subq.b   #1,d7
   bne   .loop

   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   wbftosyn
;      packs w.b. f-pars into synth buffer
;*****************************************************************************;

 XDEF wbftosyn

wbftosyn movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   lea   synbuf,a1
   addq.l   #6,a1     ; a1 --> to area (64 x 32)
   lea   wkbank,a0
   add.l    #145,a0   ; a0 --> from area (160 x 32)
   lea   wkbname,a2   ; a2 --> w.b. names (10 x 32)
   moveq    #32,d7    ; d7 = 32 to 1

.loop    move.b   (a0),d0
   lsl.b    #6,d0
   add.b    #32,d0
   sub.b    d7,d0
   move.b   d0,(a1)   ; mono/poly + slot # (0-31)
   move.b   2(a0),d0
   andi.b   #7,d0
   lsl.b    #4,d0
   add.b    1(a0),d0
   move.b   d0,1(a1)  ; pb step / pb range
   move.b   5(a0),2(a1)  ; port time
   move.b   3(a0),d0
   lsl.b    #1,d0
   add.b    4(a0),d0
   addq.b   #4,d0
   move.b   d0,3(a1) ; mysterious bit / port mode/ gliss
   move.b   7(a0),d0
   lsl.b    #4,d0
   move.b   6(a0),x1
   jsr   dxtotx
   add.b    y1,d0
   move.b   d0,4(a1) ; mw assign / range
   move.b   9(a0),d0
   lsl.b    #4,d0
   move.b   8(a0),x1
   jsr   dxtotx
   add.b    y1,d0
   move.b   d0,5(a1) ; fc assign / range
   move.b   13(a0),d0
   lsl.b    #4,d0
   move.b   12(a0),x1
   jsr   dxtotx
   add.b    y1,d0
   move.b   d0,6(a1) ; at assign / range
   move.b   11(a0),d0
   lsl.b    #4,d0
   move.b   10(a0),x1
   jsr   dxtotx
   add.b    y1,d0
   move.b   d0,7(a1) ; bc assign / range
   clr.b    8(a1)    ; padding
   clr.b    9(a1)
   clr.b    10(a1)
   clr.b    11(a1)
   move.b   #$63,12(a1) ; 2 mysterious $63 's
   move.b   #$63,13(a1)
   move.b   #$10,14(a1) ; default attenuation
   move.b   txatten,d0
   or.b  d0,14(a1)
   move.b   2(a0),d0
   andi.b   #8,d0
   lsl.b    #3,d0
   add.b    #$18,d0
   move.b   d0,15(a1)   ; pb step high bit plus 2 mysterious bits
   move.l   a1,x1
   move.l   a1,x2
   add.l    #16,x2
   move.b   #16,x3
   jsr   movemem  ; voice B = voice A exactly
   clr.b    32(a1)   ; vms/kmod
   move.b   #$27,33(a1) ; mysterious
   move.l   #33,d0
   sub.l    d7,d0    ; d0 = slot # (1-32)
   divu  #10,d0   ; d0 = remainder | quotient
   move.b   d0,d1
   add.b    #$30,d1
   move.b   d1,34(a1)
   lsr.l    #8,d0
   lsr.l    #8,d0    ; d0 = remainder
   add.b    #$30,d0
   move.b   d0,35(a1)   ; 34(a1)&35(a1) = '01'...'32'
   move.b   #$20,36(a1)
   move.l   a2,x1
   move.l   a1,x2
   add.l    #37,x2
   move.b   #10,x3
   jsr   movemem  ; copy name into synbuf
   move.b   #$20,47(a1) ; all this is very mysterious
   move.b   #$20,48(a1)
   move.b   #$4C,49(a1)
   move.b   #$6F,50(a1)
   move.b   #$3A,51(a1)
   move.b   #$43,52(a1)
   move.b   #$20,53(a1)
   move.b   #$2D,54(a1)
   move.b   #$32,55(a1)
   move.b   #$20,56(a1)
   move.b   #$48,57(a1)
   move.b   #$69,58(a1)
   move.b   #$3A,59(a1)
   move.b   #$47,60(a1)
   move.b   #$20,61(a1)
   move.b   #$38,62(a1)
   move.b   #$20,63(a1)

   move.l   a1,x1     ; unused slots 33-64 same as 1-32
   move.l   a1,x2
   add.l    #2048,x2
   move.b   #64,x3
   jsr   movemem

   add.l    #64,a1
   add.l    #160,a0
   add.l    #10,a2
   subq.b   #1,d7
   bne   .loop

   lea   synbuf,a0
   move.w   #$F043,(a0) ; create header
   move.b   midich,2(a0)
   subq.b   #1,2(a0)
   move.b   #2,3(a0)
   move.b   #$20,4(a0)
   clr.b    5(a0)

   addq.l   #6,a0
   clr.l    d0
   clr.l    d1
.3    add.b    0(a0,d1.l),d0
   addq.l   #1,d1
   cmpi.l   #4096,d1
   bne   .3
   neg.b    d0
   andi.l   #$7F,d0
   move.b   d0,4096(a0)    ; checksum
   move.b   #$F7,4097(a0)     ; end of system exclusive info

   move.l   (a7)+,x3 ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return
