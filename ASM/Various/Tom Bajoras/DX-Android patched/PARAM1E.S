;*****************************************************************************;
;   paramed -- parametric editor, screen 1e
;        Copyright 1986 Tom Bajoras
;   no entry conditions, no exit conditions
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION parale,code

  XDEF _para1e

 XREF blnkscr
 XREF _para2e
 XREF _para1w
 XREF writfdx7
 XREF edreturn
 XREF wstosyn
 XREF hardtext
 XREF sendpar
 XREF writdx7
 XREF edtosyn
 XREF movemem
 XREF sendmute
 XREF bell
 XREF getkey
 XREF outpare
 XREF edmenu2
 XREF algorith
 XREF message
 XREF outchar
 XREF line

_para1e:   move.l   #setmous,-(a7)   ; allow mouse and mouse buttons
   move.w   #3,-(a7)
   move.w   #25,-(a7)
   trap  #14
   addq.l   #8,a7
   move.b   #1,allowms
   bra   @para1e
setmous  dc.b    10,16,7,4

@para1e  jsr   blnkscr   ; start with a blank screen
   move.b   coutlne,x5   ; color for all lines
   clr.w    x1     ; lines make it look nice
   move.w   #13,x2
   move.w   #639,x3
   move.w   #13,x4
   jsr   line
   move.w   #324,x1
   move.w   #324,x3
   move.w   #199,x4
   jsr   line
   move.w   #104,x2
   move.w   #639,x3
   move.w   #104,x4
   jsr   line
   move.b   ascidash,x1
   move.b   #4,x3
   move.b   coutlne,x4
   move.b   #1,x2
.dashloop   jsr   outchar
   addq.b   #1,x2
   cmpi.b   #40,x2
   ble   .dashloop

;   top line on screen
   move.b   xmax,d0
   lea   editmesl,a0
   sub.b    (a0),d0
   sub.b    #11,d0
   lsr.b    #2,d0
   addq.b   #1,d0
   move.b   d0,x2
   move.l   #editmess,x1
   move.b   #1,x3
   move.b   cmenhed,x4
   move.b   (a0),x5
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

;   put up parameter names
   move.l   #parmess,x1
   move.b   #1,x2
   move.b   cmenkey,x4
   clr.l    d1
   move.b   parmesl,d1
   move.b   parmesl,x5
   move.b   #5,x3    ; for x3 = 5 to 25
.nameloop   jsr   message
   add.l    d1,x1
   addq.b   #1,x3
   cmpi.b   #25,x3
   ble   .nameloop

;   put up operator #s
   bsr   putopnum

;   put up parameters
   move.b   #1,noblank   ; each outpare not preceeded by blank5
   bsr   putpars
   clr.b    noblank
   move.b   134(a6),x1
   move.b   cmessge,x2
   jsr   algorith

;   write menu (start with page 1)
   clr.b    edmenflg
   jsr   edmenu2
   bsr   xtramen

;   initialize cursor:
   clr.b    d5    ; xcursor
   clr.b    d6    ; ycursor
   clr.l    d3    ; marked operator

;   put up cursor
.bigloop move.b   d5,x1
   move.b   d6,x2
   move.b   cprompt,x3
   jsr   outpare   ; parameter at cursor in red
   clr.l    d0
   move.b   d6,d0
   clr.l    d1
   move.b   parmesl,d1
   mulu  d1,d0
   move.l   #parmess,x1
   add.l    d0,x1
   move.b   #1,x2
   move.b   d6,x3
   addq.b   #5,x3
   move.b   cprompt,x4
   move.b   parmesl,x5
   jsr   message  ;red parameter name in cursor row
   move.b   #$31,x1
   add.b    d5,x1
   move.b   d5,d0
   mulu  #6,d0
   add.b    #6,d0
   move.b   d0,x2
   move.b   #3,x3
   move.b   cprompt,x4
   jsr   outchar  ; red op # in cursor column
   clr.l    d0
   move.b   d6,d0
   mulu  #6,d0
   add.b    d5,d0
   mulu  #3,d0
   lea   cursinfo,a0
   clr.l    d7
   move.b   2(a0,d0.l),d7   ; d7.l = parameter # at cursor
   move.b   #8,x1
   move.l   d3,d0
   mulu  #6,d0
   add.b    #5,d0
   move.b   d0,x2
   move.b   #3,x3
   move.b   cmenkey,x4
   jsr   outchar  ; mark currently marked operator

;   get a key:
.keyloop jsr   getkey
   trap  #11
   move.b   y1,d4    ; d4.b = gotten key

;   branch according to key:
.keyloop2   cmp.b    ascicr,d4
   beq   .return
   cmp.b    ascidel,d4
   beq   .del
   cmp.b    ascis,d4
   beq   .para2e
   cmp.b    asci0,d4
   blt   .notnum
   cmp.b    asci9,d4
   bgt   .notnum
   bra   .number
.notnum  cmp.b    asciw,d4
   beq   .para1w
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
   cmp.b    ascitab,d4
   beq   .tab
   cmp.b    ascibs,d4
   beq   .bs
   cmp.b    asciu,d4
   beq   .undo
   cmp.b    ascip,d4
   beq   .p
   cmp.b    asciast,d4
   beq   .mark
   cmp.b    ascix,d4
   beq   .xeg
   cmp.b    asciesc,d4
   beq   .esc
   cmp.b    asciz,d4
   beq   .xall
   cmp.b    ascim,d4
   beq   .mute
.badkey  jsr   bell   ; bad key: bell, get another key
   bra   .keyloop

.esc  jsr   getkey    ; get another key
   move.b   y1,d4
   cmp.b    ascic,d4
   beq   .copyeg
   cmp.b    ascia,d4
   beq   .copyall
   bra   .badkey

.p    tst.b    edmenflg  ; toggle edmenflg
   bne   .p1
   move.b   #1,edmenflg
   bra   .px
.p1   clr.b    edmenflg
.px   jsr   edmenu2   ; toggle menu page
   bsr   xtramen
   bra   .keyloop

.mute    moveq    #5,d0    ; toggle operator mute flag
   sub.b    d5,d0
   bchg  d0,muteflag
   bsr   putmute
   jsr   sendmute
   bra   .keyloop

.mark    move.b   ascisp,x1
   move.l   d3,d0
   mulu  #6,d0
   add.b    #5,d0
   move.b   d0,x2
   move.b   #3,x3
   move.b   cbakgnd,x4
   jsr   outchar  ; un-mark currently marked operator
   move.b   d5,d3    ; move mark to current operator
   move.b   #8,x1
   move.l   d3,d0
   mulu  #6,d0
   add.b    #5,d0
   move.b   d0,x2
   move.b   #3,x3
   move.b   cmenkey,x4
   jsr   outchar  ; mark currently marked operator
   bra   .keyloop

.copyeg  move.b   #8,x3
.copyx   move.l   #105,x1
   move.l   d3,d0
   mulu  #21,d0
   sub.l    d0,x1
   move.l   a6,d0
   add.l    d0,x1     ; x1--> marked op eg data
   move.l   #105,x2
   clr.l    d0
   move.b   d5,d0
   mulu  #21,d0
   sub.l    d0,x2
   move.l   a6,d0
   add.l    d0,x2     ; x2 --> current op eg data
   jsr   movemem
   bsr   putpars   ; update entire parameter display
   cmpi.b   #2,monedit
   beq   .bigloop
   jsr   edtosyn
   jsr   writdx7
   jsr   sendmute
   bra   .bigloop

.xeg  move.b   #8,x3
.xx   move.l   #105,x1
   move.l   d3,d0
   mulu  #21,d0
   sub.l    d0,x1
   move.l   a6,d0
   add.l    d0,x1     ; x1--> marked op eg data
   move.l   #wwkbank,x2
   jsr   movemem   ; copy marked op eg to temp area
   move.l   x1,x2     ; x2--> marked op eg data
   move.l   #105,x1
   clr.l    d0
   move.b   d5,d0
   mulu  #21,d0
   sub.l    d0,x1
   move.l   a6,d0
   add.l    d0,x1     ; x1 --> current op eg data
   jsr   movemem   ; copy current op eg data to marked
   move.l   x1,x2
   move.l   #wwkbank,x1
   jsr   movemem   ; copy temp area to current op eg data
   bsr   putpars   ; update entire parameter display
   cmpi.b   #2,monedit
   beq   .bigloop
   jsr   edtosyn
   jsr   writdx7
   jsr   sendmute
   bra   .bigloop

.copyall move.b   #21,x3
   bra   .copyx
.xall    move.b   #21,x3
   bra   .xx

.del  move.b   0(a5,d7.l),0(a6,d7.l)   ; unedit parameter
.update  move.b   d5,x1
   move.b   d6,x2
   move.b   cprompt,x3
   jsr   outpare  ; echo new parameter value
;  if monedit<>2 send new parameter value to synth
   cmpi.b   #2,monedit
   beq   .modechek
   jsr   sendpar
   bra   .modechek

.number  move.l   d7,d0
   mulu  #8,d0
   lea   parminfo,a0
   cmpi.b   #99,1(a0,d0.l)  ; is this a 00-99 parameter?
   bne   .badnum
   tst.l    4(a0,d0.l)   ; is it numeric?
   beq   .numberx
.badnum  jsr   bell  ; no: ring bell, get another key
   bra   .keyloop
.numberx sub.b    #$30,d4  ; d4.b = 0-9
   mulu  #10,d4   ; d4.b = 0,10,20,...90
   clr.l    d0
   move.b   0(a6,d7.l),d0
   divu  #10,d0
   lsr.l    #8,d0
   lsr.l    #8,d0    ; d0 = former right digit of par value
   add.b    d4,d0   ; d0.b = new value
   move.b   d0,0(a6,d7.l)   ; put new value into e.s.
   move.b   d5,x1
   move.b   d6,x2
   move.b   cprompt,x3
   jsr   outpare  ; echo new par value
;  if (monedit<>2) send new par value to synth
   cmpi.b   #2,monedit
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
   sub.b    #$30,d4  ; d4.b = 0-9
   add.b    d4,d0    ; d0.b = new par value
   move.b   d0,0(a6,d7.l)   ; put new value into e.s.
   move.b   d5,x1
   move.b   d6,x2
   move.b   cprompt,x3
   jsr   outpare  ; echo new par value
;  if (monedit<>2) send new par value to synth
   cmpi.b   #2,monedit
   beq   .bigloop
   jsr   sendpar
   bra   .bigloop

.help    move.b   ymax,x1
   jsr   hardtext
   bra   .keyloop

.right   cmpi.b   #5,d5    ; can't go any farther right ?
   beq   .keyloop
   move.b   d5,x1
   move.b   d6,x2
   move.b   cmessge,x3
   move.b   #1,noblank
   jsr   outpare  ; un-prompt current red parameter
   clr.b    noblank
   move.b   #$31,x1
   add.b    d5,x1
   move.b   d5,d0
   mulu  #6,d0
   add.b    #6,d0
   move.b   d0,x2
   move.b   #3,x3
   move.b   cmenkey,x4
   jsr   outchar  ; green op # in cursor column
   addq.b   #1,d5
   bra   .bigloop

.left    tst.b    d5    ; can't go any farther left ?
   beq   .keyloop
   move.b   d5,x1
   move.b   d6,x2
   move.b   cmessge,x3
   move.b   #1,noblank
   jsr   outpare  ; un-prompt current red parameter
   clr.b    noblank
   move.b   #$31,x1
   add.b    d5,x1
   move.b   d5,d0
   mulu  #6,d0
   add.b    #6,d0
   move.b   d0,x2
   move.b   #3,x3
   move.b   cmenkey,x4
   jsr   outchar  ; green op # in cursor column
   subq.b   #1,d5
   bra   .bigloop

.up   tst.b    d6    ; can't go any farther up ?
   beq   .keyloop
   move.b   d5,x1
   move.b   d6,x2
   move.b   cmessge,x3
   move.b   #1,noblank
   jsr   outpare  ; un-prompt current red parameter
   clr.b    noblank
   clr.l    d0
   move.b   d6,d0
   clr.l    d1
   move.b   parmesl,d1
   mulu  d1,d0
   move.l   #parmess,x1
   add.l    d0,x1
   move.b   #1,x2
   move.b   d6,x3
   addq.b   #5,x3
   move.b   cmenkey,x4
   move.b   parmesl,x5
   jsr   message  ;green parameter name in cursor row
   subq.b   #1,d6
   bra   .bigloop

.down    cmpi.b   #20,d6   ; can't go any farther down ?
   beq   .keyloop
   move.b   d5,x1
   move.b   d6,x2
   move.b   cmessge,x3
   move.b   #1,noblank
   jsr   outpare  ; un-prompt current red parameter
   clr.b    noblank
   clr.l    d0
   move.b   d6,d0
   clr.l    d1
   move.b   parmesl,d1
   mulu  d1,d0
   move.l   #parmess,x1
   add.l    d0,x1
   move.b   #1,x2
   move.b   d6,x3
   addq.b   #5,x3
   move.b   cmenkey,x4
   move.b   parmesl,x5
   jsr   message  ;green parameter name in cursor row
   addq.b   #1,d6
   bra   .bigloop

.plus    lea   parminfo,a0
   move.l   d7,d0
   mulu  #8,d0
   addq.b   #1,0(a6,d7.l)   ; increment e.s. parameter
   move.b   1(a0,d0.l),d1   ; d1.b = high mark
   cmp.b    0(a6,d7.l),d1   ; have we gone over the high mark?
   bge   .update
   move.b   0(a0,d0.l),0(a6,d7.l)   ; wrap around
   bra   .update

.minus   lea   parminfo,a0
   move.l   d7,d0
   mulu  #8,d0
   subq.b   #1,0(a6,d7.l)   ; decrement e.s. parameter
   move.b   0(a0,d0.l),d1   ; d1.b = low mark
   cmp.b    0(a6,d7.l),d1   ; have we gone under the low mark?
   ble   .update
   move.b   1(a0,d0.l),0(a6,d7.l)   ; wrap around
   bra   .update

.tab  move.b   0(a6,d7.l),d1   ; d1.b = value to be tabbed
   move.l   d7,d0
   mulu  #8,d0
   lea   parminfo,a0
   add.b    3(a0,d0.l),d1   ; tab the value
   cmp.b    1(a0,d0.l),d1   ; overflow?
   bgt   .badkey
   move.b   d1,0(a6,d7.l)   ; ok
   bra   .update

.bs   move.b   0(a6,d7.l),d1   ; d1.b = value to be tabbed
   move.l   d7,d0
   mulu  #8,d0
   lea   parminfo,a0
   sub.b    3(a0,d0.l),d1   ; tab the value
   cmp.b    0(a0,d0.l),d1   ; underflow?
   blt   .badkey
   move.b   d1,0(a6,d7.l)   ; ok
   bra   .update

.undo    jsr   getkey    ; get two more keys: n and d
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
   move.b   134(a6),x1   ; if es alg <> ws alg,
   move.b   cbakgnd,x2   ; erase current algorithm display
   jsr   algorith
.undox   move.l   a5,x1
   move.l   a6,x2
   move.b   #160,x3
   jsr   movemem  ; copy w.s. --> e.s.
   bsr   sendeds

; re-write all parameters:
   move.b   134(a6),x1
   move.b   cmessge,x2
   jsr   algorith  ; redraw algorithm
   bsr   putpars
   bra   .bigloop

.modechek   move.b   cmessge,x3  ; when op mode, ffq, or cfq change
   move.b   d5,x1    ; re-echo the other two
   cmpi.b   #18,d7
   beq   .modechk2
   cmpi.b   #39,d7
   beq   .modechk2
   cmpi.b   #60,d7
   beq   .modechk2
   cmpi.b   #81,d7
   beq   .modechk2
   cmpi.b   #102,d7
   beq   .modechk2
   cmpi.b   #123,d7
   beq   .modechk2
   cmpi.b   #19,d7
   beq   .modechk3
   cmpi.b   #40,d7
   beq   .modechk3
   cmpi.b   #61,d7
   beq   .modechk3
   cmpi.b   #82,d7
   beq   .modechk3
   cmpi.b   #103,d7
   beq   .modechk3
   cmpi.b   #124,d7
   beq   .modechk3
   cmpi.b   #17,d7
   beq   .modechk1
   cmpi.b   #38,d7
   beq   .modechk1
   cmpi.b   #59,d7
   beq   .modechk1
   cmpi.b   #80,d7
   beq   .modechk1
   cmpi.b   #101,d7
   beq   .modechk1
   cmpi.b   #122,d7
   beq   .modechk1
   bra   .bigloop

.modechk1   move.b   d6,x2     ; mode: re-echo cfq and ffq
   subq.b   #3,x2
   jsr   outpare
   addq.b   #1,x2
   jsr   outpare
   bra   .bigloop
.modechk2   move.b   d6,x2     ; cfq: re-echo ffq
   addq.b   #1,x2
   jsr   outpare
   bra   .bigloop
.modechk3   move.b   d6,x2     ; ffq: re-echo cfq
   subq.b   #1,x2
   jsr   outpare
   bra   .bigloop

.return  jmp   edreturn

;  to jump out of this module:
;  when jumping to screen 1w:
;  if (monedit<2) send ws non-f-pars to synth
;  if (monedit<>1) send ws f-pars to synth

.para1w  cmpi.b   #2,monedit
   beq   .f_only
   jsr   wstosyn
   jsr   writdx7
   jsr   sendmute
   cmpi.b   #1,monedit
   beq   .no_f
.f_only  move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7

.no_f    jmp   _para1w

.para2e  jmp   _para2e

;  routine to add one more line to edmenu2
xtramen  move.b   #1,ghostch   ; extra item won't hardcopy
   move.l   #editmess,x1
   add.l    #2080,x1
   move.b   #43,x2
   move.b   ymax,x3
   move.b   cmenkey,x4
   lea   editmesl,a0
   move.b   52(a0),x5
   jsr   message   ; p
   add.l    #40,x1
   add.b    #17,x2
   move.b   cmenu,x4
   move.b   53(a0),x5
   jsr   message   ; list other commands
   clr.b    ghostch
   rts

;  routine to put up all parameter values
putpars  move.b   cmessge,x3   ; color
   clr.b    x2     ; for x2 = 0 to 20
.parloop1   clr.b    x1     ;    for x1 = 0 to 5
.parloop2   jsr   outpare
   addq.b   #1,x1
   cmpi.b   #5,x1
   ble   .parloop2
   addq.b   #1,x2
   cmpi.b   #20,x2
   ble   .parloop1
   rts

;  routine to send edspace to synth
;  if (monedit<2) send es non f-pars to synth
;  if (monedit<>1) send es f-pars to synth
sendeds  cmpi.b   #2,monedit
   beq   .f_only2
   jsr   edtosyn
   jsr   writdx7
   jsr   sendmute
   cmpi.b   #1,monedit
   beq   .sendeds2
.f_only2 move.l   #edspace,x1
   add.l    #145,x1
   jsr   writfdx7
.sendeds2   rts

;   routine to put up operator #'s and mute flags
  XDEF putopnum
putopnum move.b   #3,x3
   move.b   cmenkey,x4
   move.b   asci0,x1
   move.b   #6,x2
   clr.b    d0    ; for d0 = 0 to 5
.numloop addq.b   #1,x1
   jsr   outchar
   addq.b   #6,x2
   addq.b   #1,d0
   cmpi.b   #5,d0
   ble   .numloop
putmute  move.b   #3,x3
   move.b   cmenkey,x4
   clr.b    d0    ; for d0 = 0 to 5, and d2 = 5 to 0
   moveq    #5,d2
   move.b   #7,x2
.muteloop   btst  d2,muteflag
   beq   .muted
   move.b   #1,x1
   bra   .domute
.muted   move.b   #2,x1
.domute  jsr   outchar
   addq.b   #6,x2
   subq.b   #1,d2
   addq.b   #1,d0
   cmpi.b   #5,d0
   ble   .muteloop
   rts
