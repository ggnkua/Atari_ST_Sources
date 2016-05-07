;*****************************************************************************;
;   paramed -- parametric editor, screen 2w
;        Copyright 1986 Tom Bajoras
;   also this module includes the sendmute routine
;   no entry conditions, no exit conditions
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION para2w,code

  XDEF _para2w

 XREF line
 XREF _para2e
 XREF writfdx7
 XREF writdx7
 XREF edtosyn
 XREF _para1w
 XREF blnkscr
 XREF edreturn
 XREF hardtext
 XREF bell
 XREF getkey
 XREF algorith
 XREF edmenu3
 XREF outpar2w
 XREF message

_para2w:
   move.l   #remouse,-(a7)
   move.w   #1,-(a7)
   move.w   #25,-(a7)
   trap  #14
   addq.l   #8,a7
   clr.b    allowms
   bra   para2w
remouse  dc.b    8,0

;  put up screen:
para2w  jsr   blnkscr
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
   sub.b    22(a0),d0
   move.b   d0,x2
   move.l   #editmess,x1
   add.l    #880,x1
   move.b   22(a0),x5
   jsr   message   ; original version

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
.parloop2   jsr   outpar2w
   addq.b   #1,x1
   cmpi.b   #3,x1
   ble   .parloop2
   addq.b   #1,x2
   cmpi.b   #8,x2
   ble   .parloop1

;   write menu
   jsr   edmenu3

   move.b   134(a5),x1
   move.b   cmessge,x2
   jsr   algorith

;   get a key:
.keyloop jsr   getkey
   move.b   y1,d4    ; d4.b = gotten key

;   branch according to key:
   cmp.b    ascicr,d4
   beq   .return
   cmp.b    ascis,d4
   beq   .para1w
   cmp.b    ascie,d4
   beq   .para2e
   cmp.b    ascihelp,d4
   beq   .help
   jsr   bell   ; bad key: bell, get another key
   bra   .keyloop

.help    move.b   ymax,x1
   jsr   hardtext
   bra   .keyloop

.return  jmp   edreturn

;  to jump out of this module:

.para1w  jmp   _para1w
;  when going to screen 2e:
;  if (monedit<2) send es non-f-pars to synth
;  if (monedit<>1) send es f-pars to synth

.para2e  cmpi.b   #2,monedit
   beq   .f_only
   jsr   edtosyn
   jsr   writdx7
   bsr   sendmute
   cmpi.b   #1,monedit
   beq   .no_f
.f_only  move.l   #edspace,x1
   add.l    #145,x1
   jsr   writfdx7

.no_f    jmp   _para2e

;*****************************************************************************;
;   sendmute  --  send muteflag (operator off/on bits) to synth
;*****************************************************************************;

  XDEF sendmute

sendmute movem.l  d0-a6,-(a7)
   lea   synbuf,a0
   move.w   #$F043,(a0)
   move.w   #$1001,2(a0)
   move.b   #$1B,4(a0)
   move.b   muteflag,5(a0)
   move.b   #$F7,6(a0)
   move.b   midich,d0
   subq.b   #1,d0
   add.b    d0,2(a0)

   move.l   #synbuf,-(a7)
   move.w   #6,-(a7)
   move.w   #12,-(a7)
   trap  #14
   addq.l   #8,a7

   movem.l  (a7)+,d0-a6
   rts

;**************************************************************************

 SECTION george,data

;  x- and y- coords for parameter names

parm2x   dc.b    1,6,14,22,30,6,14,22,30,1
   dc.b    9,17,25,33,1,1,2,14,22,31
   dc.b    1,5,13,21,29,5,13,21,1,13
   dc.b    22,1,4,13,23

parm2y   dc.b    3,5,5,5,5,6,6,6,6,8
   dc.b    10,10,10,10,11,12,15,15,15,15
   dc.b    18,19,19,19,19,20,20,20,22,22
   dc.b    22,24,25,25,25

savessp  dc.l    0
magic    dc.l    0
file  dc.b  "TEXTDATA.RCS"
command  dc.w    0
