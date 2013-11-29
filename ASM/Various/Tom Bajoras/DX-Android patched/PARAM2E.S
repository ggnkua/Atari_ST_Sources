;*****************************************************************************;
;   paramed -- parametric editor, screen 2e
;        Copyright 1986 Tom Bajoras
;   no entry conditions, no exit conditions
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION para2e,code

 XDEF _para2e

 XREF blnkscr
 XREF setlong
 XREF _para2w
 XREF writdx7
 XREF wstosyn
 XREF _para1e
 XREF edreturn
 XREF writfdx7
 XREF sendmute
 XREF writdx7
 XREF edtosyn
 XREF movemem
 XREF hardtext
 XREF sendpar
 XREF bell
 XREF getkey
 XREF algorith
 XREF edmenu2
 XREF outpar2e
 XREF message
 XREF line

_para2e:
   move.l   #setmous,-(a7)
   move.w   #3,-(a7)
   move.w   #25,-(a7)
   trap  #14
   addq.l   #8,a7
   move.b   #1,allowms
   bra   @para2e
setmous  dc.b    10,20,15,4

;  put up screen:
@para2e  jsr   blnkscr
   move.b   coutlne,x5
   clr.w    x1     ; lines make it look nice
   move.w   #13,x2
   move.w   #639,x3
   move.w   #13,x4
   jsr   line
   move.w   #320,x1
   move.w   #320,x3
   move.w   #199,x4
   jsr   line
   move.w   #104,x2
   move.w   #639,x3
   move.w   #104,x4
   jsr   line

;   top line on screen
   move.b   xmax,d0
   lea   editmesl,a0
   sub.b    29(a0),d0
   sub.b    #11,d0
   lsr.b    #2,d0
   addq.b   #1,d0
   move.b   d0,x2
   move.l   #editmess,x1
   add.l    #1160,x1
   move.b   #1,x3
   move.b   cmenhed,x4
   move.b   29(a0),x5
   jsr   message   ; screen title
   move.b   x5,d0
   add.b    d0,x2
   addq.b   #1,x2
   move.l   #wksname,x1
   move.b   cmessge,x4
   move.b   #10,x5
   jsr   message    ; append w.s. name
   move.b   xmax,d0
   addq.b   #1,d0
   sub.b    1(a0),d0
   move.b   d0,x2
   move.l   #editmess,x1
   add.l    #40,x1
   move.b   1(a0),x5
   jsr   message   ; edited version

;    put up parameter names
   move.b   cmenkey,x4   ; color for all text
   lea   parmes2l,a0  ; a0--> lengths of text
   lea   parm2x,a1    ; a1--> x-coords for text
   lea   parm2y,a2    ; a2--> y-coords for text
   clr.l    d0     ; for d0.l = 0 to 34
   clr.l    d1     ; for d1.l = 0 to 510 by 15
.nameloop   move.l   #parmes2,x1
   add.l    d1,x1
   move.b   0(a1,d0.l),x2
   move.b   0(a2,d0.l),x3
   move.b   0(a0,d0.l),x5
   jsr   message
   addq.l   #1,d0
   add.l    #15,d1
   cmpi.l   #510,d1
   ble   .nameloop

;    put up parameters
   clr.b    x2     ; for x2 = 0 to 8
.parloop1   clr.b    x1     ;    for x1 = 0 to 3
   move.b   cmessge,x3
.parloop2   jsr   outpar2e
   addq.b   #1,x1
   cmpi.b   #3,x1
   ble   .parloop2
   addq.b   #1,x2
   cmpi.b   #8,x2
   ble   .parloop1

;   write menu
   clr.b    edmenflg
   jsr   edmenu2
   move.b   #1,ghostch
   move.l   #editmess,x1
   add.l    #1920,x1
   move.b   #43,x2
   move.b   ymax,x3
   move.b   cmenkey,x4
   lea   editmesl,a0
   move.b   48(a0),x5
   jsr   message  ; tab/bs
   add.l    #40,x1
   add.b    #17,x2
   move.b   cmenu,x4
   move.b   49(a0),x5
   jsr   message  ; tab forward/backward
   clr.b    ghostch

;   initialize cursor:
   clr.b    d5    ; xcursor
   clr.b    d6    ; ycursor

.bigloop move.b   134(a6),x1
   move.b   cmessge,x2
   jsr   algorith

;   put up cursor
   move.b   d5,x1
   move.b   d6,x2
   move.b   cprompt,x3
   jsr   outpar2e  ; parameter at cursor in red
   clr.l    d0
   move.b   d6,d0
   mulu  #4,d0
   add.b    d5,d0
   mulu  #3,d0
   lea   cursinf2,a0
   clr.l    d7
   move.b   2(a0,d0.l),d7   ; d7.l = parameter # at cursor

;   get a key:
.keyloop jsr   getkey
   move.b   y1,d4    ; d4.b = gotten key

;   branch according to key:
.keyloop2   cmp.b    ascicr,d4
   beq   .return
   cmp.b    ascidel,d4
   beq   .del
   cmp.b    ascitab,d4
   beq   .tab
   cmp.b    ascibs,d4
   beq   .bs
   cmp.b    ascis,d4
   beq   .para1e
   cmp.b    asci0,d4
   blt   .notnum
   cmp.b    asci9,d4
   bgt   .notnum
   bra   .number
.notnum  cmp.b    asciw,d4
   beq   .para2w
   cmp.b    ascihelp,d4
   beq   .help
   cmp.b    ascirit,d4
   beq   .right
   cmp.b    ascilef,d4
   beq   .left
   cmp.b    asciup,d4
   beq   .up
   cmp.b    ascidwn,d4
   beq   .down
   cmp.b    asciplus,d4
   beq   .plus
   cmp.b    ascimrit,d4
   beq   .plus
   cmp.b    ascidash,d4
   beq   .minus
   cmp.b    ascimlef,d4
   beq   .minus
   cmp.b    asciu,d4
   beq   .undo
.badkey  jsr   bell   ; bad key: bell, get another key
   bra   .keyloop

.del  move.b   0(a6,d7.l),d0   ; do nothing if es par already
   cmp.b    0(a5,d7.l),d0   ; equals ws par
   beq   .keyloop
   cmpi.b   #134,d7   ; about to change algorithm?
   bne   .del1
   move.b   134(a6),x1
   move.b   cbakgnd,x2   ; blank out previous algorithm
   jsr   algorith
.del1    move.b   0(a5,d7.l),0(a6,d7.l)   ; unedit parameter
.update  move.b   d5,x1
   move.b   d6,x2
   move.b   cprompt,x3
   jsr   outpar2e
   cmpi.b   #146,d7
   bne   .del2
   bsr   pbrange
   bra   .del3
.del2    cmpi.b   #147,d7
   bne   .del3
   bsr   pbstep
;  if (monedit<2) send es non-f-par to synth
;  if (monedit<>1) send es f-par to synth
.del3    cmpi.b   #144,d7   ; f-par?
   bgt   .del_f
   cmpi.b   #2,monedit
   beq   .modechek
   jsr   sendpar   ; send non-f-par
   bra   .modechek
.del_f   cmpi.b   #1,monedit
   beq   .modechek
   jsr   sendpar
   bra   .modechek

.number  move.l   d7,d0
   mulu  #8,d0
   lea   parminfo,a0
   cmpi.b   #99,1(a0,d0.l)  ; is this a 00-99 parameter?
   beq   .numberx
   jsr   bell  ; no: ring bell, get another key
   bra   .keyloop
.numberx sub.b    #$30,d4  ; d4.b = 0-9
   mulu  #10,d4   ; d4.b = 0,10,20,...90
   clr.l    d0
   move.b   0(a6,d7.l),d0
   divu  #10,d0
   lsr.l    #8,d0
   lsr.l    #8,d0     ; d0 = former right digit of par value
   add.b    d4,d0     ; d0.b = new value
   move.b   d0,0(a6,d7.l)   ; put new value into e.s.
   move.b   d5,x1
   move.b   d6,x2
   move.b   cprompt,x3
   jsr   outpar2e
;  if (monedit<2) send es non-f-pars to synth
;  if (monedit<>1) send es f-pars to synth
   cmpi.b   #144,d7   ; f-par?
   bgt   .num1_f
   cmpi.b   #2,monedit
   beq   .skipsend
   jsr   sendpar   ; send non-f-par
   bra   .skipsend
.num1_f  cmpi.b   #1,monedit
   beq   .skipsend
   jsr   sendpar
.skipsend   jsr   getkey
   move.b   y1,d4    ; d4.b = gotten key
   cmp.b    asci0,d4
   blt   .keyloop2
   cmp.b    asci9,d4
   bgt   .keyloop2
   clr.l    d0
   move.b   0(a6,d7.l),d0
   divu  #10,d0    ; d0.b = former left digit of par value
   andi.l   #$FF,d0
   mulu  #10,d0
   sub.b    #$30,d4   ; d4.b = 0-9
   add.b    d4,d0     ; d0.b = new par value
   move.b   d0,0(a6,d7.l)   ; put new value into e.s.
   move.b   d5,x1
   move.b   d6,x2
   move.b   cprompt,x3
   jsr   outpar2e
;  if (monedit<2) send es non-f-pars to synth
;  if (monedit<>1) send es f-pars to synth
   cmpi.b   #144,d7   ; f-par?
   bgt   .num2_f
   cmpi.b   #2,monedit
   beq   .bigloop
   jsr   sendpar   ; send non-f-par
   bra   .bigloop
.num2_f  cmpi.b   #1,monedit
   beq   .bigloop
   jsr   sendpar
   bra   .bigloop

.help    move.b   ymax,x1
   jsr   hardtext
   bra   .keyloop

.right   cmpi.b   #1,d5
   ble   .rightx
   cmpi.b   #3,d5    ; can't go any farther right?
   beq   .keyloop
   cmpi.b   #5,d6
   bgt   .keyloop
.rightx  move.b   d5,x1
   move.b   d6,x2
   move.b   cmessge,x3
   jsr   outpar2e
   addq.b   #1,d5
   bra   .bigloop

.left    tst.b    d5    ; can't go any farther left?
   beq   .keyloop
   move.b   d5,x1
   move.b   d6,x2
   move.b   cmessge,x3
   jsr   outpar2e
   subq.b   #1,d5
   bra   .bigloop

.up   tst.b    d6    ; can't go any farther up?
   beq   .keyloop
   move.b   d5,x1
   move.b   d6,x2
   move.b   cmessge,x3
   jsr   outpar2e
   subq.b   #1,d6
   bra   .bigloop

.down    cmpi.b   #4,d6
   ble   .downx
   cmp.b    #7,d6    ; can't go any farther down?
   bgt   .keyloop
   cmp.b    #3,d5
   bge   .keyloop
.downx   move.b   d5,x1
   move.b   d6,x2
   move.b   cmessge,x3
   jsr   outpar2e
   addq.b   #1,d6
   bra   .bigloop

.plus    cmpi.b   #134,d7  ; about to change algorithm?
   bne   .plus1
   move.b   134(a6),x1
   move.b   cbakgnd,x2   ; blank out previous algorithm
   jsr   algorith
.plus1   lea   parminfo,a0
   move.l   d7,d0
   mulu  #8,d0
   addq.b   #1,0(a6,d7.l)   ; increment e.s. parameter
   move.b   1(a0,d0.l),d1   ; d1.b = high mark
   cmp.b    0(a6,d7.l),d1   ; have we gone over the high mark?
   bge   .update
   move.b   0(a0,d0.l),0(a6,d7.l)   ; wrap around
   bra   .update

.minus   cmpi.b   #134,d7   ; about to change algorithm?
   bne   .minus1
   move.b   134(a6),x1
   move.b   cbakgnd,x2   ; blank out previous algorithm
   jsr   algorith
.minus1  lea   parminfo,a0
   move.l   d7,d0
   mulu  #8,d0
   subq.b   #1,0(a6,d7.l)   ; decrement e.s. parameter
   move.b   0(a0,d0.l),d1   ; d1.b = low mark
   cmp.b    0(a6,d7.l),d1   ; have we gone under the low mark?
   ble   .update
   move.b   1(a0,d0.l),0(a6,d7.l)   ; wrap around
   bra   .update

.tab  move.b   0(a6,d7.l),d1   ; value to be tabbed
   move.l   d7,d0
   mulu  #8,d0
   lea   parminfo,a0
   add.b    3(a0,d0.l),d1   ; tab it
   cmp.b    1(a0,d0.l),d1   ; overflow?
   bgt   .badkey
   cmpi.b   #134,d7   ; about to change algorithm?
   bne   .tab1
   move.b   134(a6),x1   ; blank out previous algorithm
   move.b   cbakgnd,x2
   jsr   algorith
.tab1    move.b   d1,0(a6,d7.l)   ; ok
   bra   .update

.bs   move.b   0(a6,d7.l),d1   ; value to be tabbed
   move.l   d7,d0
   mulu  #8,d0
   lea   parminfo,a0
   sub.b    3(a0,d0.l),d1   ; tab it
   cmp.b    0(a0,d0.l),d1   ; underflow?
   blt   .badkey
   cmpi.b   #134,d7   ; about to change algorithm?
   bne   .bs1
   move.b   134(a6),x1   ; blank out previous algorithm
   move.b   cbakgnd,x2
   jsr   algorith
.bs1  move.b   d1,0(a6,d7.l)   ; ok
   bra   .update

.undo    jsr   getkey    ; get 2 more keys: n and d
   move.b   y1,d4
   cmp.b    ascin,d4
   bne   .badkey
   jsr   getkey
   move.b   y1,d4
   cmp.b    ascid,d4
   bne   .badkey
   move.b   134(a6),d0
   cmp.b    134(a5),d0
   beq   .undox
   move.b   134(a6),x1
   move.b   cbakgnd,x2   ; blank out previous algorithm
   jsr   algorith
.undox   move.l   a5,x1
   move.l   a6,x2
   move.b   #160,x3
   jsr   movemem  ; copy w.s. --> e.s.
;  if (monedit<2) send es non f-pars to synth
;  if (monedit<>1) send es f-pars to synth

   cmpi.b   #2,monedit
   beq   .f_only2
   jsr   edtosyn
   jsr   writdx7
   jsr   sendmute
   cmpi.b   #1,monedit
   beq   .no_f2
.f_only2 move.l   #edspace,x1
   add.l    #145,x1
   jsr   writfdx7

; re-write all parameters:

.no_f2   clr.b    x2     ; for x2 = 0 to 8
.parloop3   clr.b    x1     ;    for x1 = 0 to 3
   move.b   cmessge,x3
.parloop4   jsr   outpar2e
   addq.b   #1,x1
   cmpi.b   #3,x1
   ble   .parloop4
   addq.b   #1,x2
   cmpi.b   #8,x2
   ble   .parloop3
   bra   .bigloop

.modechek   cmpi.b   #145,d7   ; just changed mono/poly mode?
   bne   .bigloop   ; no: loop
   move.b   #2,x1      ; yes: re-echo port mode
   move.b   #8,x2
   move.b   cmessge,x3
   jsr   outpar2e
   bra   .bigloop

.return  jmp   edreturn

;  to jump out of this module:

.para1e  jmp   _para1e
;  if going to screen 2w:
;  if (monedit<2) send ws non-f-pars to synth
;  if (monedit<>1) send ws f-pars to synth

.para2w  cmpi.b   #2,monedit
   beq   .f_only
   jsr   wstosyn
   jsr   writdx7
   jsr   sendmute
   cmpi.b   #1,monedit
   beq   .no_f
.f_only  move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7

.no_f    jmp   _para2w

;  handle interaction of pb range  /  pb step
pbrange  cmpi.b   #12,146(a6)   ; new pb range = 12?
   beq  pb_ret
   clr.b    147(a6)    ; if pbrange <> 12 force pbstep =0
   move.b   #1,x1
   move.b   #7,x2
   move.b   cmessge,x3    ; and re-echo pbstep
   jsr   outpar2e
   cmpi.b   #1,monedit
   beq   pb_ret
   jsr   sendpar
   bra   pb_ret
pbstep   tst.b    147(a6)    ; new pb step = 0?
   beq   pb_ret
   move.b   #12,146(a6)  ; if pbstep <> 0 force pbrange = 12
   clr.b    x1
   move.b   #7,x2
   move.b   cmessge,x3   ; and re-echo pbrange
   jsr   outpar2e
   cmpi.b   #1,monedit
   beq   pb_ret
   jsr   sendpar
pb_ret  rts

;*****************************************************************************;
;   initpri8 -- part of primary initialization daisy chain
;      turn key repeat off, define midiaddr and kbaddr
;*****************************************************************************;

 XDEF initpri8

initpri8:
   trap  #10    ; key repeat off

   move.w   #2,-(a7)
   move.w   #14,-(a7)
   trap  #14
   addq.l   #4,a7
   move.l   d0,midiaddr  ; get pointer to midi input record

   move.w   #1,-(a7)
   move.w   #14,-(a7)
   trap  #14
   addq.l   #4,a7
   move.l   d0,kbaddr    ; get pointer to keyboard input record

   rts

; Hybrid Arts serial number for A-Lock copy protection
serial   dc.b   "100002"

;******************************************************************************
 SECTION harry,data

;  x- and y- coords for parameter names

parm2x   dc.b    1,6,14,22,30,6,14,22,30,1
   dc.b    9,17,25,33,1,1,2,14,22,31
   dc.b    1,5,13,21,29,5,13,21,1,13
   dc.b    22,1,4,13,23

parm2y   dc.b    3,5,5,5,5,6,6,6,6,8
   dc.b    10,10,10,10,11,12,15,15,15,15
   dc.b    18,19,19,19,19,20,20,20,22,22
   dc.b    22,24,25,25,25
