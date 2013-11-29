;*****************************************************************************;
;   paramed -- parametric editor, executive and utility routines
;       copyright 1986 Tom Bajoras
;   no entry conditions, no exit conditions
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION paramed,code

  XDEF paramed
  XDEF edreturn

 XREF blnkscr
 XREF line
 XREF outchar
 XREF message
 XREF encode
 XREF sendmute
 XREF _para1e
 XREF writfdx7
 XREF writdx7
 XREF edtosyn
 XREF sendmute
 XREF setcolor

paramed movem.l d0-a6,-(a7) ; save registers
   move.l  x1,-(a7) ; and x1-x5
   move.l  x2,-(a7)
   move.l  x3,-(a7)
   move.l  x4,-(a7)
   move.l  x5,-(a7)

   jsr  blnkscr ; blank screen before setting colors
   move.b  #2,x1   ; change colors
   jsr  setcolor

   lea  wkspace,a5  ; a5--> unedited sound
   lea  edspace,a6  ; a6--> edited sound
   move.b  #$3F,muteflag   ; all operators on
   jsr  sendmute

;  if (monedit<2) send es non-f-pars to synth
;  if (monedit<>1) send es f-pars to synth
   cmpi.b  #2,monedit
   beq  .f_only
   jsr  edtosyn
   jsr  writdx7
   cmpi.b  #1,monedit
   beq  .no_f
.f_only move.l  #edspace,x1
   add.l   #145,x1
   jsr  writfdx7

.no_f   jmp  _para1e ; start with screen 1E


;   all numerical editing returns to edit menu through here:
edreturn move.b  #$3F,muteflag   ; all operators on
   jsr  sendmute
   move.l  (a7)+,x5  ; restore x5-x1
   move.l  (a7)+,x4
   move.l  (a7)+,x3
   move.l  (a7)+,x2
   move.l  (a7)+,x1
   movem.l (a7)+,d0-a6 ; restore registers
   rts      ; return to edit menu

;*****************************************************************************;
;   outpare, outparw, outpar2e, outpar2w, outparc
;      x1.b= cursorx (0-5), x2.b = cursory (0-20),
;      x3.b= color
;*****************************************************************************;

  XDEF outpare
  XDEF outparw
  XDEF outpar2e
  XDEF outpar2w
  XDEF outparc

outpare movem.l d0-a6,-(a7) ; save registers
   move.l  x1,-(a7)
   move.l  x2,-(a7)
   move.l  x3,-(a7)
   move.l  x4,-(a7)
   move.l  x5,-(a7)  ; and x1-x5
   move.l  a6,a1
   lea  cursinfo,a2
   clr.l   d0
   move.b  x2,d0
   mulu  #6,d0
   add.b   x1,d0
   mulu  #3,d0    ; index into cursinfo
   bra  outparx

outparw movem.l d0-a6,-(a7) ; save registers
   move.l  x1,-(a7)
   move.l  x2,-(a7)
   move.l  x3,-(a7)
   move.l  x4,-(a7)
   move.l  x5,-(a7)  ; and x1-x5
   move.l  a5,a1
   lea  cursinfo,a2
   clr.l   d0
   move.b  x2,d0
   mulu  #6,d0
   add.b   x1,d0
   mulu  #3,d0    ; index into cursinfo
   bra  outparx

outpar2e movem.l d0-a6,-(a7) ; save registers
   move.l  x1,-(a7)
   move.l  x2,-(a7)
   move.l  x3,-(a7)
   move.l  x4,-(a7)
   move.l  x5,-(a7)  ; and x1-x5
   move.l  a6,a1
   lea  cursinf2,a2
   clr.l   d0
   move.b  x2,d0
   mulu  #4,d0
   add.b   x1,d0
   mulu  #3,d0    ; index into cursinf2
   bra  outparx

outpar2w movem.l d0-a6,-(a7) ; save registers
   move.l  x1,-(a7)
   move.l  x2,-(a7)
   move.l  x3,-(a7)
   move.l  x4,-(a7)
   move.l  x5,-(a7)  ; and x1-x5
   move.l  a5,a1
   lea  cursinf2,a2
   clr.l   d0
   move.b  x2,d0
   mulu  #4,d0
   add.b   x1,d0
   mulu  #3,d0    ; index into cursinf2
;    bra  outparx

outparx clr.l   d1
   move.b  2(a2,d0.l),d1   ; d1.l = par #
   cmpi.b  #$FF,d1  ; forbidden zone?
   beq  return
   move.b  0(a2,d0.l),d5   ; d5.b = x-coord
   move.b  1(a2,d0.l),d6   ; d6.b = y-coord
outparc lea  parminfo,a0
   move.l  d1,d0
   mulu  #8,d0
   move.l  4(a0,d0.l),x1   ; x1--> non-numeric values
   beq  numeric

   cmpi.b  #19,d1   ; ffq must be handled special
   beq  @ffq
   cmpi.b  #40,d1
   beq  @ffq
   cmpi.b  #61,d1
   beq  @ffq
   cmpi.b  #82,d1
   beq  @ffq
   cmpi.b  #103,d1
   beq  @ffq
   cmpi.b  #124,d1
   beq  @ffq

nonnum clr.l   d2
   move.b  2(a0,d0.l),d2   ; d2.l = # chars per value
   clr.l   d3
   move.b  0(a1,d1.l),d3   ; d3.l = value
   mulu  d3,d2    ; d2.l = offset into non-numeric
   add.l   d2,x1
   move.b  2(a0,d0.l),x5
color  move.b  x3,x4    ; color
   move.b  0(a5,d1.l),d2   ; d2 = w.s. value
   cmp.b   0(a1,d1.l),d2
   bne  .noteq
   move.b  ascisp,d4   ; append space if e.s. = w.s.
   bra  doit
.noteq  move.b  asciast,d4  ; append asterisk if e.s. <> w.s.
   bra  doit
numeric cmpi.b  #18,d1   ; cfq must be handled special
   beq  @cfq
   cmpi.b  #39,d1
   beq  @cfq
   cmpi.b  #60,d1
   beq  @cfq
   cmpi.b  #81,d1
   beq  @cfq
   cmpi.b  #102,d1
   beq  @cfq
   cmpi.b  #123,d1
   beq  @cfq
   cmpi.b  #148,d1  ; port mode must be handled special
   beq  portmode
   clr.w   d2
   move.b  0(a1,d1.l),d2
   move.w  d2,x1
   cmpi.b  #134,d1  ; algorithm?
   bne  .not_alg
   addq.w  #1,x1    ; algorithm is 1-32, not 0-31
.not_alg jsr  encode   ; encode the value
   lea  parminfo,a0
   move.l  d1,d0
   mulu  #8,d0
   cmpi.b  #99,1(a0,d0.l)
   beq  .99
   cmpi.w  #9,x1
   bgt  .gt9

   move.b  #1,x5
   cmpi.b  #135,d1
   beq  .gt9x
   cmpi.b  #143,d1
   beq  .gt9x    ; don't do this for fb or pms

   lea  namebuf,a0
   move.b  (a0),1(a0)
   move.b  ascisp,(a0) ; turn single digit into blank+digit
   bra  .gt9
.99  cmpi.b  #9,d2
   bgt  .gt9
   lea  namebuf,a0  ; put single digit into 2-digit form
   move.b  (a0),1(a0)
   move.b  #$30,(a0)
.gt9  move.b  #2,x5
.gt9x   move.l  #namebuf,x1
   bra  color
doit   cmpi.w  #126,d1
   bge  .doitx
   tst.b   noblank
   bne  .doitx
   bsr  blank5   ; for screen 1: blank 5
.doitx  move.b  d5,x2
   move.b  d6,x3
   jsr  message
   move.b  x5,d0
   add.b   d0,x2
   move.b  d4,x1
   jsr  outchar  ; append space or asterisk
return  move.l  (a7)+,x5  ; restore x5-x1
   move.l  (a7)+,x4
   move.l  (a7)+,x3
   move.l  (a7)+,x2
   move.l  (a7)+,x1
   movem.l (a7)+,d0-a6 ; restore registers
   rts      ; return

blank5  move.l  x1,-(a7)  ; save x1-x5
   move.l  x2,-(a7)
   move.l  x3,-(a7)
   move.l  x4,-(a7)
   move.l  x5,-(a7)
   move.b  ascisp,x1
   move.b  d5,x2
   move.b  d6,x3
   move.b  cbakgnd,x4
   clr.b   d2
.bl5loop jsr  outchar
   addq.b  #1,x2
   addq.b  #1,d2
   cmpi.b  #5,d2
   bne  .bl5loop
   move.l  (a7)+,x5  ; restore x5-x1
   move.l  (a7)+,x4
   move.l  (a7)+,x3
   move.l  (a7)+,x2
   move.l  (a7)+,x1
   rts      ; return

@cfq  subq.b  #1,d1
   tst.b   0(a1,d1.l)   ; fixed frq?
   bne  .ffmode
   addq.l  #1,d1   ;    restore d1.l --> par value
   clr.l   d2
   move.b  0(a1,d1.l),d2    ; d2.l = cfq (0-31)
   clr.l   d3
   move.b  1(a1,d1.l),d3   ; d3.l = ffq (0-99)
   add.l   #100,d3
   tst.l   d2    ; treat cfq=0 as .5
   beq  .divide
   mulu  d2,d3    ; d3.l=composite frequency
   bra  .cfqx
.divide divu  #2,d3    ; d3.w=composite frequency
   andi.l  #$FFFF,d3   ; clear out remainder from divide
.cfqx   divu  #100,d3  ; d3.w = cfq to be displayed
   move.w  d3,x1    ; encode this
   jsr  encode
   lea  namebuf,a3
   cmpi.b  #9,d3
   bgt  .cfqgt9
   move.b  (a3),1(a3)
   move.b  ascisp,(a3)
.cfqgt9 move.l  #namebuf,x1
   move.b  #2,x5
   bra  color
.ffmode move.l  #val_cfq2,x1
   addq.l  #1,d1    ; restore d1.l --> cfq
   clr.l   d2
   move.b  2(a0,d0.l),d2   ; d2.l = # chars per value
   clr.l   d3
   move.b  0(a1,d1.l),d3   ; d3.l = cfq value (0-31)
   divu  #4,d3
   lsr.l   #8,d3
   lsr.l   #8,d3    ; d3.w = 0,1,2,3
   mulu  d3,d2    ; d2.l = offset into non-numeric
   add.l   d2,x1
   move.b  2(a0,d0.l),x5
   bra  color

@ffq  subq.b  #2,d1
   tst.b   0(a1,d1.l)   ; fixed frq?
   bne  .ffmode2
   addq.b  #1,d1    ; d1.b --> cfq
   clr.l   d2
   move.b  0(a1,d1.l),d2    ; d2.l = cfq (0-31)
   clr.l   d3
   move.b  1(a1,d1.l),d3   ; d3.l = ffq (0-99)
   addq.b  #1,d1    ; restore d1.b --> ffq
   add.l   #100,d3
   tst.l   d2    ; treat cfq=0 as .5
   beq  .divide2
   mulu  d2,d3    ; d3.l=composite frequency
   bra  .ffqx
.divide2 divu  #2,d3    ; d3.w=composite frequency
   andi.l  #$FFFF,d3   ; clear out remainder from divide
.ffqx   divu  #100,d3
   lsr.l   #8,d3
   lsr.l   #8,d3    ; d3.w = ffq to be displayed
   move.w  d3,x1    ; encode this
   jsr  encode
   lea  namebuf,a3
   cmpi.b  #9,d3
   bgt  .ffqgt9
   move.b  (a3),1(a3)
   move.b  asci0,(a3)
.ffqgt9 move.b  1(a3),2(a3)
   move.b  (a3),1(a3)
   move.b  asciper,(a3)
   move.l  #namebuf,x1
   move.b  #3,x5
   bra  color
.ffmode2 addq.b  #2,d1    ; restore d1.l --> ffq
   clr.l   d2
   move.b  0(a1,d1.l),d2   ; d2.l = ffq
   mulu  #2,d2    ; d2.l = index into invlog10
   lea  invlog10,a3
   move.w  0(a3,d2.l),x1
   jsr  encode
   move.l  #namebuf,x1
   move.b  #4,x5
   bra  color

portmode   tst.b   145(a1)  ; mono?
   bne  .mono
   move.l  #val_prt2,x1
   bra  nonnum
.mono   move.l  #val_prt1,x1
   bra  nonnum

;*****************************************************************************;
;   algorith
;   x1.b = algorithm # (0-31), x2.b = color
;*****************************************************************************;

  XDEF algorith

algorith movem.l d0-a6,-(a7) ; store registers
   move.l  x1,-(a7)  ; and x1-x5
   move.l  x2,-(a7)
   move.l  x3,-(a7)
   move.l  x4,-(a7)
   move.l  x5,-(a7)
   move.b  x1,d7    ; d7.b = algorithm #
   move.b  x2,d6    ; d6.b = color
   move.b  #1,ghostch  ; none of this will hardcopy

   move.b  xmax,d0
   lsr.b   #1,d0
   move.b  d0,x2
   lea  editmesl,a0
   sub.b   21(a0),d0
   subq.b  #3,d0
   lsr.b   #1,d0
   add.b   d0,x2
   addq.b  #1,x2  ; center "algorithm" on right half of screen
   move.b  #3,x3
   move.b  cmenhed,x4
   move.l  #editmess,x1
   add.l   #840,x1
   move.b  21(a0),x5
   jsr  message
   clr.w   d0
   move.b  d7,d0
   addq.b  #1,d0    ; algorithm # = 1-32
   move.w  d0,x1
   jsr  encode
   move.l  #namebuf,x1
   move.b  x5,d0
   add.b   d0,x2
   addq.b  #1,x2
   move.b  cmessge,x4
   move.b  #2,x5
   jsr  message  ; append algorithm #

; draw algorithm in upper right square:
   clr.l   d2
   move.b  d7,d2   ; d2.l = algorithm (0-31)
   move.b  d6,x5   ; x5 = color
   lea  algboxes,a1
   lea  algmaps,a0
   mulu  #12,d2
   add.l   d2,a0   ; a0--> this alg's map (6 words)
   clr.l   d0   ; d0.l = 0 to 10 by 2

.algloop move.w  0(a0,d0.l),d1   ; d1.w = index into algboxes
   move.w  0(a1,d1.w),x1
   move.w  4(a1,d1.w),x2
   move.w  2(a1,d1.w),x3
   move.w  x2,x4
   jsr  line
   move.w  x4,x2
   move.w  x3,x1
   move.w  6(a1,d1.w),x4
   jsr  line
   move.w  x4,x2
   move.w  x3,x1
   move.w  0(a1,d1.w),x3
   jsr  line
   move.w  x4,x2
   move.w  x3,x1
   move.w  4(a1,d1.w),x4
   jsr  line
   move.b  d0,d2
   lsr.b   #1,d2
   add.b   #$31,d2
   move.b  d2,x1   ; x1.b = op # encoded
   move.w  0(a1,d1.w),d2
   add.w   2(a1,d1.w),d2
   lsr.w   #1,d2
   addq.w  #5,d2
   lsr.w   #3,d2
   move.b  d2,x2
   move.w  4(a1,d1.w),d2
   add.w   6(a1,d1.w),d2
   lsr.w   #1,d2
   addq.w  #5,d2
   lsr.w   #3,d2
   move.b  d2,x3
   move.b  x5,x4
   jsr  outchar ; put op # in center of box
   add.l   #2,d0
   cmpi.l  #10,d0
   ble  .algloop

;  draw connector lines
   move.b  d6,x5    ; color for all lines
   lea  alglines,a0
   clr.l   d0
   move.b  d7,d0   ; d0.l = alg # (0-31)
   mulu  #20,d0
   add.l   d0,a0   ; a0--> alg lines for this alg
   lea  algboxes,a1
   clr.l   d0   ; d0.l = 0 to 16 by 4
.lineloop   move.w  0(a0,d0.l),d1   ; d1.w =fromx
   move.w  2(a0,d0.l),d2   ; d2.w =tox
   cmp.w   d1,d2    ; done early?
   beq  .drawfb
   move.w  0(a1,d1.w),d3
   add.w   2(a1,d1.w),d3
   lsr.w   #1,d3    ; d3.w = x1
   move.w  6(a1,d1.w),x2
   move.w  0(a1,d2.w),d5
   add.w   2(a1,d2.w),d5
   lsr.w   #1,d5    ; d5.w = x2
   move.w  4(a1,d2.w),x4
   cmp.w   d3,d5
   beq  .noslant
   bgt  .slant2
   move.w  0(a1,d1.w),d3   ; x2<x1
   move.w  2(a1,d2.w),d5
   bra  .noslant
.slant2 move.w  2(a1,d1.w),d3   ; x2>x1
   move.w  0(a1,d2.w),d5
.noslant move.w  d3,x1
   move.w  d5,x3
   jsr  line   ; draw a connecting line

   addq.l  #4,d0
   cmpi.l  #16,d0
   ble  .lineloop

;  draw f.b. path polyline
.drawfb clr.l   d0
   move.b  d7,d0
   mulu  #24,d0
   lea  algfb,a0
   add.l   d0,a0   ; a0--> polyline coords
   move.b  d6,x5   ; color for fb polyline
   clr.l   d0   ; for d0.l = 0 to 16 by 4
.fbloop move.w  0(a0,d0.l),x1   ; x1
   move.w  2(a0,d0.l),d2   ; y1
   cmp.w   x1,d2   ; done early?
   beq  .return
   move.w  d2,x2
   move.w  4(a0,d0.l),x3
   move.w  6(a0,d0.l),d2
   cmp.w   x3,d2   ; done early?
   beq  .return
   move.w  d2,x4
   jsr  line
   addq.l  #4,d0
   cmpi.l  #16,d0
   ble  .fbloop

.return clr.b   ghostch ; allow hardcopying
   move.l  (a7)+,x5 ; restore x5-x1
   move.l  (a7)+,x4
   move.l  (a7)+,x3
   move.l  (a7)+,x2
   move.l  (a7)+,x1
   movem.l (a7)+,d0-a6 ; restore registers
   rts      ; return

;*****************************************************************************;
;   sendpar
;   entry condition: d7.l = parameter #
;   clobbers a0, d0
;*****************************************************************************;

  XDEF sendpar

sendpar movem.l d0-a6,-(a7)  ; save all registers
   cmpi.w  #144,d7   ; f-par?
   bgt  sendpar2

   lea  synbuf,a0    ; send non-f-par
   move.w  #$F043,(a0)
   move.b  #$10,2(a0)
   move.b  midich,d0
   subq.b  #1,d0
   add.b   d0,2(a0)
   move.l  d7,d0
   move.b  0(a6,d0.l),5(a0)
   divu  #128,d0
   move.b  d0,3(a0)
   lsr.l   #8,d0
   lsr.l   #8,d0
   move.b  d0,4(a0)
   move.l  #synbuf,-(a7)
   move.w  #5,-(a7)
   move.w  #12,-(a7)
   trap  #14
   addq.l  #8,a7
   bra  @return

sendpar2 lea  synbuf,a0    ; send f-par
   move.w  #$F043,(a0)
   move.b  #$10,2(a0)
   move.b  midich,d0
   subq.b  #1,d0
   add.b   d0,2(a0)
   move.b  0(a6,d7.l),5(a0)
   move.b  d7,4(a0)
   sub.b   #81,4(a0)
   move.b  #8,3(a0)
   move.l  #synbuf,-(a7)
   move.w  #5,-(a7)
   move.w  #12,-(a7)
   trap  #14
   addq.l  #8,a7

@return movem.l (a7)+,d0-a6  ; restore all registers
   rts

;*****************************************************************************;
;   data used by routines in this module
;*****************************************************************************;

 SECTION eugene,data

;   x- and y- coordinates for drawing algorithms on upper right screen

algboxes dc.w   446,474,39,48,486,514,39,48
   dc.w   406,434,55,64,446,474,55,64
   dc.w   486,514,55,64,526,554,55,64
   dc.w   366,394,71,80,406,434,71,80
   dc.w   446,474,71,80,486,514,71,80
   dc.w   526,554,71,80,566,594,71,80
   dc.w   446,474,87,96,486,514,87,96

;   map each operator in each algorithm to one of the algboxes

algmaps dc.w   96,64,104,72,32,8      ;1
   dc.w   96,64,104,72,32,8      ;2
   dc.w   64,24,0,72,32,8    ;3
   dc.w   64,24,0,72,32,8    ;4
   dc.w   64,24,72,32,80,40      ;5
   dc.w   64,24,72,32,80,40      ;6
   dc.w   56,16,64,24,32,8    ;7
   dc.w   56,16,64,24,32,8    ;8
   dc.w   56,16,64,24,32,8    ;9
   dc.w   72,32,8,64,16,24    ;10
   dc.w   72,32,8,64,16,24    ;11
   dc.w   80,40,64,16,24,32      ;12
   dc.w   80,40,64,16,24,32      ;13
   dc.w   64,24,72,32,0,8    ;14
   dc.w   64,24,72,32,0,8    ;15
   dc.w   64,16,24,0,32,8    ;16
   dc.w   64,16,24,0,32,8    ;17
   dc.w   96,56,24,72,32,8    ;18
   dc.w   64,24,0,72,80,32    ;19
   dc.w   56,64,16,80,32,40      ;20
   dc.w   56,64,16,72,80,32      ;21
   dc.w   56,16,64,72,80,32      ;22
   dc.w   56,64,24,72,80,32      ;23
   dc.w   48,56,64,72,80,32      ;24
   dc.w   48,56,64,72,80,32      ;25
   dc.w   56,64,24,80,32,40      ;26
   dc.w   56,64,24,80,32,40      ;27
   dc.w   56,16,64,24,0,72    ;28
   dc.w   56,64,72,32,80,40      ;29
   dc.w   56,64,72,32,8,80    ;30
   dc.w   48,56,64,72,80,40      ;31
   dc.w   48,56,64,72,80,88      ;32

;  connecting lines for algorithm drawings

alglines dc.w   64,96,8,32,32,72,72,104,0,0 ;1
   dc.w   64,96,8,32,32,72,72,104,0,0 ;2
   dc.w    0,24,24,64,8,32,32,72,0,0 ;3
   dc.w    0,24,24,64,8,32,32,72,0,0 ;4
   dc.w   40,80,24,64,32,72,0,0,0,0 ;5
   dc.w   40,80,24,64,32,72,0,0,0,0 ;6
   dc.w   16,56,24,64,8,32,32,64,0,0 ;7
   dc.w   16,56,24,64,8,32,32,64,0,0 ;8
   dc.w   16,56,24,64,8,32,32,64,0,0 ;9
   dc.w   16,64,24,64,8,32,32,72,0,0 ;10
   dc.w   16,64,24,64,8,32,32,72,0,0 ;11
   dc.w   16,64,24,64,32,64,40,80,0,0 ;12
   dc.w   16,64,24,64,32,64,40,80,0,0 ;13
   dc.w   24,64,0,32,8,32,32,72,0,0 ;14
   dc.w   24,64,0,32,8,32,32,72,0,0 ;15
   dc.w   16,64,0,24,24,64,8,32,32,64   ;16
   dc.w   16,64,0,24,24,64,8,32,32,64   ;17
   dc.w   56,96,24,96,72,96,8,32,32,72   ;18
   dc.w    0,24,24,64,32,72,32,80,0,0 ;19
   dc.w   16,56,16,64,32,80,40,80,0,0 ;20
   dc.w   16,56,16,64,32,72,32,80,0,0 ;21
   dc.w   16,56,32,64,32,72,32,80,0,0 ;22
   dc.w   24,64,32,72,32,80,0,0,0,0 ;23
   dc.w   32,64,32,72,32,80,0,0,0,0 ;24
   dc.w   32,72,32,80,0,0,0,0,0,0 ;25
   dc.w   24,64,32,80,40,80,0,0,0,0 ;26
   dc.w   24,64,32,80,40,80,0,0,0,0 ;27
   dc.w   16,56,0,24,24,64,0,0,0,0 ;28
   dc.w   32,72,40,80,0,0,0,0,0,0 ;29
   dc.w    8,32,32,72,0,0,0,0,0,0 ;30
   dc.w   40,80,0,0,0,0,0,0,0,0 ;31
   dc.w    0,0,0,0,0,0,0,0,0,0 ;32

;  x- and y-coords of algorithm feedback polylines

algfb   dc.w   500,39,500,36,520,36,520,52,500,52,0,0  ;1
   dc.w   460,71,460,68,440,68,440,84,460,84,0,0  ;2
   dc.w   500,39,500,36,520,36,520,52,500,52,0,0  ;3
   dc.w   500,39,500,36,520,36,520,84,500,84,500,80   ;4
   dc.w   540,55,540,52,560,52,560,68,540,68,0,0  ;5
   dc.w   540,55,540,52,560,52,560,84,540,84,0,0  ;6
   dc.w   500,39,500,36,520,36,520,52,500,52,0,0  ;7
   dc.w   460,55,460,52,440,52,440,68,460,68,0,0  ;8
   dc.w   420,55,420,52,400,52,400,68,420,68,0,0  ;9
   dc.w   500,39,500,36,520,36,520,52,500,52,0,0  ;10
   dc.w   460,55,460,52,480,52,480,68,460,68,0,0  ;11
   dc.w   540,55,540,52,560,52,560,68,540,68,0,0  ;12
   dc.w   500,55,500,52,520,52,520,68,500,68,500,64   ;13
   dc.w   500,39,500,36,520,36,520,52,500,52,0,0  ;14
   dc.w   460,55,460,52,440,52,440,68,460,68,0,0  ;15
   dc.w   500,39,500,36,520,36,520,52,500,52,0,0  ;16
   dc.w   420,55,420,52,440,52,440,68,0,0,0,0  ;17
   dc.w   460,55,460,52,480,52,480,68,460,68,0,0  ;18
   dc.w   500,55,500,52,520,52,520,68,0,0,0,0  ;19
   dc.w   420,55,420,52,440,52,440,68,0,0,0,0  ;20
   dc.w   420,55,420,52,440,52,440,68,0,0,0,0  ;21
   dc.w   500,55,500,52,520,52,520,68,0,0,0,0  ;22
   dc.w   500,55,500,52,520,52,520,68,0,0,0,0  ;23
   dc.w   500,55,500,52,520,52,520,68,0,0,0,0  ;24
   dc.w   500,55,500,52,520,52,520,68,0,0,0,0  ;25
   dc.w   540,55,540,52,560,52,560,68,540,68,0,0  ;26
   dc.w   460,55,460,52,480,52,480,68,460,68,0,0  ;27
   dc.w   460,39,460,36,480,36,480,52,460,52,0,0  ;28
   dc.w   540,55,540,52,560,52,560,68,540,68,0,0  ;29
   dc.w   500,39,500,36,520,36,520,52,500,52,0,0  ;30
   dc.w   540,55,540,52,560,52,560,68,540,68,0,0  ;31
   dc.w   580,80,580,84,600,84,600,68,580,68,580,71   ;32

;  inv log-base-10 used for ff mode ffq

invlog10 dc.w   1000,1023,1047,1072,1096,1122,1148,1175,1202,1230
   dc.w   1259,1288,1318,1349,1380,1413,1445,1479,1514,1549
   dc.w   1585,1622,1660,1698,1738,1778,1820,1862,1905,1950
   dc.w   1995,2042,2089,2138,2188,2239,2291,2344,2399,2455
   dc.w   2512,2570,2630,2692,2716,2818,2884,2951,3020,3090
   dc.w   3162,3236,3311,3388,3467,3548,3631,3715,3802,3890
   dc.w   3981,4074,4169,4266,4365,4467,4571,4677,4786,4898
   dc.w   5012,5129,5248,5370,5495,5623,5754,5888,6026,6166
   dc.w   6310,6457,6607,6761,6918,7079,7244,7413,7586,7762
   dc.w   7943,8128,8318,8511,8718,8913,9120,9333,9550,9772
