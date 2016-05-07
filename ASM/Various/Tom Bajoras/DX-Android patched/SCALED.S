;*****************************************************************************;
;   scaled -- graphical keyboard scaling editor
;        Copyright 1986 Tom Bajoras
;   no entry conditions, no exit conditions
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION scaled,code


 XDEF scaled

 XREF blnkscr
 XREF dot2line
 XREF encode
 XREF convert
 XREF wstosyn
 XREF sendpar
 XREF hardcopy
 XREF bell
 XREF getkey
 XREF edmenu
 XREF drawsce
 XREF drawscw
 XREF outchar
 XREF writfdx7
 XREF message
 XREF line
 XREF writdx7
 XREF edtosyn
 XREF setcolor


scaled   movem.l  d0-a6,-(a7)  ; save registers
   move.l   x1,-(a7)   ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   jsr   blnkscr   ; start with blank screen
   move.b   #4,x1     ; change colors
   jsr   setcolor

   lea   edspace,a6   ; a6 --> edited sound
   lea   wkspace,a5   ; a5 --> original sound
   clr.l    d6     ; operator # to start with

   bsr   drawkb    ; these parts never change
   bsr   drawtr
   bsr   drawaxes

;   if (monedit <2) send e.s. non-f-pars to synth
   cmpi.b   #2,monedit
   beq   .f_only
   jsr   edtosyn
   jsr   writdx7

;   if (monedit <>1) send e.s. f-pars to synth
   cmpi.b   #1,monedit
   beq   .skip_f
.f_only  move.l   #edspace,x1
   add.l    #145,x1
   jsr   writfdx7

;   put up screen:
.skip_f  lea   editmesl,a0  ; a0 --> lengths of edit mess's
   move.l   #editmess,x1
   add.l    #1440,x1
   move.b   #5,x2
   move.b   #1,x3
   move.b   cmenhed,x4
   move.b   36(a0),x5
   jsr   message    ; title
   move.b   x5,d0
   add.b    d0,x2
   addq.b   #1,x2
   move.l   #wksname,x1
   move.b   cmessge,x4
   move.b   #10,x5
   jsr   message   ; append w.s. name

   move.l   #editmess,x1
   add.l    #1240,x1
   move.b   xmax,d0
   subq.b   #4,d0
   sub.b    31(a0),d0
   move.b   d0,x2
   move.b   #1,x3
   move.b   cmenhed,x4
   move.b   31(a0),x5
   jsr   message   ; "operator _"

;  operator # in upper rh corner
   move.b   xmax,x2
   subq.b   #3,x2
   move.b   #$31,x1
   add.b    d6,x1
   move.b   cmessge,x4
   jsr   outchar

   move.l   #editmess,x1
   add.l    #1560,x1
   move.b   #18,x2
   move.b   #20,x3
   move.b   cmenkey,x4
   lea   editmesl,a0
   add.l    #39,a0
   clr.l    d0
.nameloop   move.b   0(a0,d0.l),x5
   jsr   message
   add.l    #40,x1
   add.b    #9,x2
   addq.l   #1,d0
   cmpi.l   #4,d0
   ble   .nameloop

;  write parameters
   clr.l    d5
   move.b   cmessge,x4
.parloop bsr   outpute
   addq.l   #1,d5
   cmpi.l   #4,d5
   ble   .parloop

   bsr   renew     ; put up grid
   jsr   drawscw
   jsr   drawsce   ; put up display

;  put up menu:
   jsr   edmenu
   move.l   #editmess,x1
   add.l    #1760,x1
   move.b   #1,x2
   move.b   #22,x3
   move.b   cmenkey,x4
   lea   editmesl,a0
   move.b   44(a0),x5
   jsr   message    ; sp
   move.l   #editmess,x1
   add.l    #1800,x1
   move.b   #8,x2
   move.b   cmenu,x4
   move.b   45(a0),x5
   jsr   message    ; next operator

;  initialize cursor
   clr.l    d5    ; cursor-x

.cursloop   move.l   #113,d7
   add.l    d5,d7
   move.l   d6,d0
   mulu  #21,d0
   sub.l    d0,d7    ; d7.l = parameter #

;   mark parameter at cursor
   move.b   cprompt,x4
   bsr   outpute

;   get a key
.keyloop jsr   getkey
   trap  #11    ; key repeat on
   move.b   y1,d4     ; d4.b = gotten key

;   branch according to key
.keyloop2   cmp.b    ascilef,d4
   beq   .left
   cmp.b    ascirit,d4
   beq   .right
   cmp.b    ascihelp,d4
   beq   .help
   cmp.b    asciplus,d4
   beq   .plus
   cmp.b    ascidash,d4
   beq   .minus
   cmp.b    asciu,d4
   beq   .undo
   cmp.b    ascitab,d4
   beq   .tab
   cmp.b    ascibs,d4
   beq   .bs
   cmp.b    asciw,d4
   beq   .doubleu
   cmp.b    ascie,d4
   beq   .e
   cmp.b    ascisp,d4
   beq   .sp
   cmp.b    ascicr,d4
   beq   .return
   cmp.b    ascidel,d4
   beq   .del
   cmp.b    asci0,d4
   blt   .badkey
   cmp.b    asci9,d4
   ble   .number
.badkey  jsr   bell
   bra   .keyloop

.left    move.b   cmessge,x4
   bsr   outpute
   subq.l   #1,d5    ; move cursor to left
   bge   .cursloop
   moveq    #4,d5    ; wrap around
   bra   .cursloop

.right   move.b   cmessge,x4
   bsr   outpute
   addq.l   #1,d5    ; move cursor to right
   cmpi.l   #4,d5
   ble   .cursloop
   clr.l    d5    ; wrap around
   bra   .cursloop

.help    jsr   hardcopy
   bra   .keyloop

.plus    lea   parminfo,a0  ; increment es par, with wraparound
   move.l   d7,d0
   mulu  #8,d0
   addq.b   #1,0(a6,d7.l)
   move.b   1(a0,d0.l),d1   ; d1.b = high mark
   cmp.b    0(a6,d7.l),d1   ; have we gone over the high mark?
   bge   .update
   move.b   0(a0,d0.l),0(a6,d7.l)   ; yes: wraparound
.update  bsr   renew
   jsr   drawscw
   jsr   drawsce   ; re-do display
   move.b   cprompt,x4
   bsr   outpute
   cmpi.b   #2,monedit
   beq   .keyloop
   jsr   sendpar
   bra   .keyloop

.minus   lea   parminfo,a0  ; decrement es par, with wraparound
   move.l   d7,d0
   mulu  #8,d0
   subq.b   #1,0(a6,d7.l)
   move.b   0(a0,d0.l),d1   ; d1.b = low mark
   cmp.b    0(a6,d7.l),d1   ; have we gone under the low mark?
   ble   .update
   move.b   1(a0,d0.l),0(a6,d7.l)   ; yes: wraparound
   bra   .update

.tab  move.b   0(a6,d7.l),d1   ; d1.b = value to be tabbed
   lea   parminfo,a0
   move.l   d7,d0
   mulu  #8,d0
   add.b    3(a0,d0.l),d1   ; tab the value
   cmp.b    1(a0,d0.l),d1   ; overflow?
   bgt   .badkey
   move.b   d1,0(a6,d7.l)   ; ok
   bra   .update

.bs   move.b   0(a6,d7.l),d1   ; d1.b = value to be tabbed
   lea   parminfo,a0
   move.l   d7,d0
   mulu  #8,d0
   sub.b    3(a0,d0.l),d1   ; tab the value
   cmp.b    0(a0,d0.l),d1   ; underflow?
   blt   .badkey
   move.b   d1,0(a6,d7.l)   ; ok
   bra   .update

.undo    jsr   getkey    ; get 2 more keys: n and d
   move.b   y1,d4
   cmp.b    ascin,d4
   bne   .badkey
   jsr   getkey
   move.b   y1,d4
   cmp.b    ascid,d4
   bne   .badkey
   move.l   #113,d7
   move.l   d6,d0
   mulu  #21,d0
   sub.l    d0,d7     ; d7.l --> bp for current operator
   move.b   0(a5,d7.l),0(a6,d7.l)   ; unedit the 5 parameters
   move.b   1(a5,d7.l),1(a6,d7.l)
   move.b   2(a5,d7.l),2(a6,d7.l)
   move.b   3(a5,d7.l),3(a6,d7.l)
   move.b   4(a5,d7.l),4(a6,d7.l)
; re-output 5 parameters
   move.l   d5,-(a7)  ; save cursorx
   clr.l    d5
   move.b   cmessge,x4
.undoloop   bsr   outpute
   addq.l   #1,d5
   cmpi.l   #4,d5
   ble   .undoloop
   move.l   (a7)+,d5  ; restore cursor
; if monedit<>2 send 5 parameters to synth
   cmpi.b   #2,monedit
   beq   .undo2
   clr.l    d1    ; for d1.l=0 to 4
.sendloop   jsr   sendpar
   addq.l   #1,d7
   addq.l   #1,d1
   cmpi.l   #4,d1
   ble   .sendloop
.undo2   bsr   renew
   jsr   drawscw
   jsr   drawsce   ; re-do display
   bra   .cursloop

; if monedit <> 2 send w.s. non-f-pars to synth
.doubleu    cmpi.b   #2,monedit
   beq   .f_onlyw
   jsr   wstosyn
   jsr   writdx7
;   if (monedit <>1) send w.s. f-pars to synth
   cmpi.b   #1,monedit
   beq   .keyloop
.f_onlyw move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7
   bra   .keyloop

; if monedit <> 2 send e.s. non-f-pars to synth
.e    cmpi.b   #2,monedit
   beq   .f_onlye
   jsr   edtosyn
   jsr   writdx7
;   if (monedit <>1) send e.s. f-pars to synth
   cmpi.b   #1,monedit
   beq   .keyloop
.f_onlye move.l   #edspace,x1
   add.l    #145,x1
   jsr   writfdx7
   bra   .keyloop

.del  move.b   0(a5,d7.l),0(a6,d7.l)    ; unedit parameter
   bra   .update

.number  tst.l    d5   ; cannot directly enter bp
   beq   .badkey
   cmpi.l   #3,d5   ; cannot directly enter lc or rc
   bge   .badkey
   clr.l    d0
   move.b   0(a6,d7.l),d0
   divu  #10,d0
   lsr.l    #8,d0
   lsr.l    #8,d0
   clr.l    d1
   move.b   d4,d1
   sub.b    #$30,d1
   mulu  #10,d1
   add.b    d1,d0
   move.b   d0,0(a6,d7.l)
   move.b   cprompt,x4
   bsr   outpute
   bsr   renew
   jsr   drawscw
   jsr   drawsce   ; re-do display
   cmpi.b   #2,monedit
   beq   .skipsend
   jsr   sendpar
.skipsend   jsr   getkey    ; get another key
   move.b   y1,d4     ; d4.b = gotten key
   cmp.b    asci0,d4
   blt   .keyloop2
   cmp.b    asci9,d4
   bgt   .keyloop2
   clr.l    d0
   move.b   0(a6,d7.l),d0
   divu  #10,d0
   andi.l   #$FFFF,d0
   mulu  #10,d0
   add.b    d4,d0
   sub.b    #$30,d0
   move.b   d0,0(a6,d7.l)
   bra   .update

.sp   addq.l   #1,d6
   cmpi.l   #5,d6
   ble   .spx
   clr.l    d6
;  update # in upper righthand corner
.spx  move.b   d6,x1
   add.b    #$31,x1
   move.b   xmax,x2
   subq.b   #3,x2
   move.b   #1,x3
   move.b   cmessge,x4
   jsr   outchar
   bsr   renew
   jsr   drawscw
   jsr   drawsce   ; re-do display
; re-output all parameters
   move.l   d5,-(a7)  ; save cursorx
   clr.l    d5
   move.b   cmessge,x4
.sploop  bsr   outpute
   addq.l   #1,d5
   cmpi.l   #4,d5
   ble   .sploop
   move.l   (a7)+,d5  ; restore cursorx
   bra   .cursloop

.return  move.l   (a7)+,x5 ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6 ; restore registers
   rts       ; return

;******************************************************************************
;  local routine to draw a 128-key keyboard across the screen
;  no entry conditions, no exit conditions
;******************************************************************************

 XDEF drawkb

drawkb   movem.l  d0-a6,-(a7) ; save registers

;   draw borders:
   move.w   #20,x1
   move.w   #123,x2
   move.w   #619,x3
   move.w   #123,x4
   move.b   coutlne,x5
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #147,x4
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #20,x3
   jsr   line
   move.w   x3,x1
   move.w   x4,x2
   move.w   #123,x4
   jsr   line

;   fill it in
   clr.l    d0    ; for octave = 0 to 10
.loop1   move.l   d0,d1
   mulu  #56,d1
   add.l    #20,d1   ; d1.l = octave
   clr.l    d2    ; for whitekey = 0 to 6
.loop2   move.l   d2,d3
   mulu  #8,d3
   addq.l   #8,d3
   add.l    d1,d3    ; d3.l = x
   move.w   d3,x1
   move.w   #124,x2
   move.w   d3,x3
   move.w   #146,x4
   jsr   line  ; white key
   cmpi.l   #2,d2
   beq   .2    ; black key needed here?
   cmpi.l   #6,d2
   beq   .2
   move.l   d2,d3
   mulu  #8,d3
   addq.l   #5,d3
   add.l    d1,d3    ; d3.l = x
   move.w   d3,x1
   move.w   #123,x2
   move.w   d3,x3
   move.w   #139,x4
   jsr   line  ; black key -- part 1
   addq.w   #1,x1
   addq.w   #1,x3
   jsr   line  ; black key -- part 2
   addq.w   #1,x1
   addq.w   #1,x3
   jsr   line  ; black key -- part 3
   cmpi.l   #2,d0
   bne   .5
   cmpi.l   #6,d2    ; skip part 4 for B in octave 2
   beq   .2
.5    addq.w   #1,x1
   addq.w   #1,x3
   jsr   line  ; black key -- part 4
.2    cmpi.l   #10,d0
   bne   .3
   cmpi.l   #3,d2    ; done?
   beq   .done
.3    addq.l   #1,d2
   cmpi.l   #6,d2
   ble   .loop2   ; end for whitekey = 0 to 6
   addq.l   #1,d0
   cmpi.l   #10,d0
   ble   .loop1   ; end for octave = 0 to 10

.done    movem.l  (a7)+,d0-a6 ; restore registers
   rts       ; return

;******************************************************************************
;   routine to mark keyboard transpose limits
;******************************************************************************

drawtr   movem.l  d0-a6,-(a7) ; save registers
   move.b   coutlne,x5   ; color for all this
   move.w   #122,x2   ; y-coords for all this
   move.w   #118,x4

   clr.l    d0
   move.b   144(a6),d0
   add.l    #12,d0    ; d0.l = lower key
   jsr   convert   ; d1.l = lower x-pixel value
   move.w   d1,x1
   move.w   d1,x3
   addq.w   #2,x3
   jsr   line
   subq.w   #4,x3
   jsr   line

   clr.l    d0
   move.b   144(a6),d0
   add.l    #72,d0    ; d0.l = upper key
   jsr   convert   ; d1.l = upper x-pixel value
   move.w   d1,x1
   move.w   d1,x3
   addq.w   #2,x3
   jsr   line
   subq.w   #4,x3
   jsr   line

   movem.l  (a7)+,d0-a6  ; restore registers
   rts        ; return

;******************************************************************************
;   routine to draw left and right y-axes
;   no entry or exit conditions
;******************************************************************************

 XDEF drawaxes

drawaxes move.w   #20,x1
   move.w   #619,x3
   move.w   #116,x2
   move.w   #116,x4
   move.b   coutlne,x5
   jsr   line   ; x-axis
   move.w   #20,x1
   move.w   #116,x2
   move.w   #20,x3
   move.w   #17,x4
   jsr   line   ; left y-axis
   move.w   #17,x1
   move.w   #20,x3
   move.w   #116,d0   ; for d0 = 116 to 16 by -20
.leftloop   cmpi.w   #16,d0
   bne   .1
   addq.w   #1,d0     ; last hashmark is at 17, not 16
.1    move.w   d0,x2
   move.w   d0,x4
   jsr   line
   sub.w    #20,d0
   cmpi.w   #16,d0
   bge   .leftloop

   move.b   cmenkey,x4
   move.b   asci0,x1
   move.b   #2,x2
   move.b   #15,x3
   jsr   outchar   ; '0'
   move.b   #2,x5
   move.b   #1,x2
   move.w   #20,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #12,x3
   jsr   message   ; '20'
   move.w   #40,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #10,x3
   jsr   message   ; '40'
   move.w   #60,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #7,x3
   jsr   message   ; '60'
   move.w   #80,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #5,x3
   jsr   message   ; '80'
   move.w   #99,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #3,x3
   jsr   message   ; '99'

   move.w   #619,x1
   move.w   #116,x2
   move.w   #619,x3
   move.w   #17,x4
   move.b   coutlne,x5
   jsr   line   ; right y-axis
   move.w   #619,x1
   move.w   #622,x3
   move.w   #116,d0   ; for d0 = 116 to 16 by -20
.ritloop cmpi.w   #16,d0
   bne   .2
   addq.w   #1,d0     ; last hashmark is at 17, not 16
.2    move.w   d0,x2
   move.w   d0,x4
   jsr   line
   sub.w    #20,d0
   cmpi.w   #16,d0
   bge   .ritloop

   move.b   cmenkey,x4
   move.b   asci0,x1
   move.b   xmax,x2
   move.b   #15,x3
   jsr   outchar   ; '0'
   move.b   #2,x5
   move.b   xmax,x2
   subq.b   #1,x2
   move.w   #20,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #12,x3
   jsr   message   ; '20'
   move.w   #40,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #10,x3
   jsr   message   ; '40'
   move.w   #60,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #7,x3
   jsr   message   ; '60'
   move.w   #80,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #5,x3
   jsr   message   ; '80'
   move.w   #99,x1
   jsr   encode
   move.l   #namebuf,x1
   move.b   #3,x3
   jsr   message   ; '99'

   rts       ; return

;******************************************************************************
;   local routines to output a parameter value
;   entry conditions: d5.l = cursorx, d6.l = 0-5 op # , x4.b = color
;******************************************************************************

 XDEF outpute

outpute  movem.l  d0-a6,-(a7) ; save registers
   lea   edspace,a2   ; a2 --> edited version
   move.l   #113,d7
   add.l    d5,d7
   move.l   d6,d0
   mulu  #21,d0
   sub.l    d0,d7    ; d7.l = parameter #
   move.l   d7,d0
   mulu  #8,d0    ; d0.l = index into parminfo
   lea   parminfo,a0
   move.l   4(a0,d0.l),x1
   beq   .numeric
   clr.l    d1
   move.b   2(a0,d0.l),d1   ; d1.l = # chars per value
   clr.l    d2
   move.b   0(a2,d7.l),d2   ; d2.l = value
   mulu  d1,d2
   add.l    d2,x1
   move.b   d1,x5
   bra   .1

.numeric clr.l    d2
   move.b   0(a2,d7.l),d2   ; d2.l = value
   move.w   d2,x1
   jsr   encode
   lea   namebuf,a0
   cmpi.b   #9,d2
   bgt   .gt9
   move.b   (a0),1(a0)   ; convert 0-9 to 00-09
   move.b   asci0,(a0)
.gt9  move.l   #namebuf,x1
   move.b   #2,x5

.1    move.b   #21,x2
   mulu  #9,d5
   add.b    d5,x2
   move.b   #20,x3
   jsr   message
   move.b   ascisp,x1
   move.b   0(a2,d7.l),d2
   cmp.b    0(a5,d7.l),d2   ; equal to w.s. parameter?
   beq   .eq
   move.b   asciast,x1
.eq   move.b   x5,d0
   add.b    d0,x2
   jsr   outchar

   movem.l  (a7)+,d0-a6 ; restore registers
   rts       ; return

;******************************************************************************
;   renew --  blank out area inside axes, add grid
;   renew2 -- blank out param1e/2e menu
;******************************************************************************

 XDEF renew
 XDEF renew2

renew    movem.l  d0-a6,-(a7) ; save registers

   move.l   vdiaddr,a0
   move.w   #21,38(a0)   ; x1
   move.w   #17,d0
   mulu  bwflag,d0
   move.w   d0,40(a0)    ; y1
   move.w   #618,42(a0)  ; x2
   move.w   #115,d0
   mulu  bwflag,d0
   move.w   d0,44(a0)    ; y2
   clr.b    d7     ; renew flag
   bra   renewx

renew2   movem.l  d0-a6,-(a7) ; save registers

   move.l   vdiaddr,a0
   move.w   #336,38(a0)   ; x1
   move.w   #112,d0
   mulu  bwflag,d0
   move.w   d0,40(a0)     ; y1
   move.w   #639,42(a0)   ; x2
   move.w   #199,d0
   mulu  bwflag,d0
   move.w   d0,44(a0)     ; y2
   moveq    #1,d7     ; renew2 flag

renewx   clr.w    24(a0)    ; color 0
   clr.w    26(a0)
   clr.w    28(a0)
   clr.w    30(a0)
   clr.w    36(a0)    ; replace mode
   move.l   #fill,46(a0) ; pointer to solid fill
   clr.w    50(a0)    ; pattern mask
   clr.w    52(a0)    ; multi-fill
   clr.w    54(a0)    ; clipping off
   clr.w    56(a0)    ; 4 clipping values all 0
   clr.w    58(a0)
   clr.w    60(a0)
   clr.w    62(a0)
   dc.w    $A005     ; do it

   tst.b    d7     ; go no farther for renew2
   bne   .return
   move.w   #21,x1
   move.w   #618,x3   ; x-coords for grid lines
   move.b   coutlne,x5
   move.w   #17,x2
   move.w   #17,x4    ; y-coord for top grid line
   jsr   dot2line
   move.w   #36,x2
   move.w   #36,x4
   moveq    #4,d0
.gridloop   jsr   dot2line  ; draw other 4 grid lines
   add.w    #20,x2
   add.w    #20,x4
   subq.b   #1,d0
   bgt   .gridloop

.return  movem.l  (a7)+,d0-a6 ; restore registers
   rts

 SECTION mary,data

fill  dc.l    $FFFFFFFF    ; fill pattern for renew
