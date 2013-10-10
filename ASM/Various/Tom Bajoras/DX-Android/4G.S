;*****************************************************************************;
;   module 4g source file    Copyright 1986 Tom Bajoras
;   edit-bank menu command processing routine: br7anch
;   branch routines called from br(x)anch routines, and diskerr routine
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION fourf,code

;*****************************************************************************;
;   br7anch
;      x1 = itemx
;*****************************************************************************;

 XDEF br7anch

 XREF redisbnk
 XREF initpri5
 XREF mazetabl
 XREF parsnum
 XREF initscr
 XREF errmess
 XREF parsnam
 XREF getit
 XREF abort
 XREF tagtry
 XREF cannot
 XREF writinfo
 XREF mixbank
 XREF swapwbs
 XREF getabc
 XREF message
 XREF checkws
 XREF movemem
 XREF getyn
 XREF readtx7
 XREF readdx7
 XREF value
 XREF writfdx7
 XREF writdx7
 XREF wstosyn
 XREF getslot
 XREF creturn
 XREF wstowb
 XREF wbtows
 XREF syntowb	
 XREF wbtosyn
 XREF wbtowb

br7anch  movem.l  D0-A6,-(a7)  ; save registers and x1-x5
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.l   #6,d6      ; d6.l = menux = 6
   move.l   x1,d0      ; branch according to itemx
   beq   @wstowb
   cmpi.b   #1,d0
   beq   @wbtows
   cmpi.b   #2,d0
   beq   @syntowb
   cmpi.b   #3,d0
   beq   @wbtosyn
   cmpi.b   #4,d0
   beq   @wbtowb
   cmpi.b   #5,d0
   beq   swap
   cmpi.b   #6,d0
   beq   mix
   cmpi.b   #7,d0
   beq   name
   cmpi.b   #8,d0
   beq   match
   bra   returnx  ; illegal itemx simply returns

return  move.b   d1,d0
   andi.l   #$FF,d0
   subq.l   #1,d0
   move.l   d0,x1     ; x1.l = slotx = 0-31
   jsr   redisbnk    ; update w.s. area of screen
returnx move.l   (a7)+,x5  ; restore x5-x1,registers,return
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6
   rts

@wstowb  move.l   #15,d1
   lea   .wstowb2,a6  ; return address for .getslot
   bra   @getslot  ; get slotx
.wstowb2 move.b   y1,x1     ; x1.b = slotx = 1-32
   jsr   wstowb    ; copy w.s. to specified w.b. slot
   move.b   x1,d1
   bra   return

@getslot move.l   d6,x1     ; get slot routine:  y1.b = 1-32
   jsr   creturn   ;   carriage return
   move.l   d1,x1
   jsr   getslot   ;   prompt for slot
   tst.b    y2
   bne   .getslotx    ;   cr: abort
   jmp   (a6)   ;   not cr: go to addr in a6
.getslotx   jsr   branch5

@wbtows  move.l   #15,d1
   lea   .wbtows2,a6  ; .getslot return address
   bra   @getslot  ; get slotx
.wbtows2 move.b   y1,x1
   jsr   wbtows    ; copy specified w.b. slot to w.s.
   tst.b    monws     ; if monws=1 send w.s. to synth
   beq   returnx
   jsr   wstosyn
   jsr   writdx7
   move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7
   bra   returnx  ; restore registers,x5-x1,return

@syntowb lea   .syntowb2,a6   ; loop back if bad #
.syntowb2   moveq    #22,d7
   jsr   branch9   ; get #
   jsr   value
   move.l   y1,d1     ; d1.l = #
   ble   .syntowb3    ; bad # if < 1 or > maxslot
   cmp.l    #$7F,d1
   bgt   .syntowb3
   cmp.b    maxslot,d1
   ble   .syntowb4
.syntowb3   move.l   #1,x2
   jsr   branch11  ; bad # routine
.syntowb4   move.b   d1,x1     ; x1.b = 1-32
   jsr   readdx7   ; read synth sound into buffer
   cmpi.b   #2,y1     ; check for abort or error
   beq   synerr
   tst.b    y1
   beq   .success
   jsr   readtx7
   tst.b    y1
   bne   synerr
.success move.l   #15,d1
   lea   .syntowb5,a6 ; return address for .getslot
   bra   @getslot  ; get w.b. slotx
.syntowb5   move.b   y1,d1     ; d1.b = slotx = 1-32
   move.b   d1,x1
   jsr   syntowb   ; copy buffer into specified w.b. slot
   move.l   d6,x1
   jsr   creturn
   move.l   #-1,x1
   move.l   #39,x2
   jsr   getyn      ; default w.b. slot function pars? (y/n)
   cmpi.b   #1,y1
   bne   .syntowb6
   move.l   #initsnd,x1
   add.l    #145,x1
   move.l   #wkbank,x2   ; compute pointer to this slot's f-pars
   clr.l    d7
   move.b   d1,d7
   subq.b   #1,d7
   mulu  #160,d7
   add.l    d7,x2    ; x2 --> this slot
   add.l    #145,x2  ; x2 --> this slot's f-pars
   move.b   #15,x3    ; if y:
   jsr   movemem   ; default w.b. slot function parameters
.syntowb6   move.l   #wkbank,x1
   clr.l    d7
   move.b   d1,d7
   subq.b   #1,d7
   mulu  #160,d7
   add.l    d7,x1
   jsr   checkws   ; check for mangled data
   bra   return   ; update w.b. area of screen, return
synerr   move.b   y1,d1     ; protect y1
   move.l   d6,x1
   jsr   creturn
   move.l   #messss,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cmessge,x4
   lea   messsl,a0
   cmpi.b   #1,d1
   bne   synerr2
   add.l    #600,x1   ; time-out error
   move.b   15(a0),x5
   bra   synerrx
synerr2  add.l    #1360,x1  ; format error
   move.b   34(a0),x5
synerrx  jsr   message
   bra   returnx

@wbtosyn lea   .wbtosyn2,a6 ; .getslot return address
   move.l   #15,d1
   bra   @getslot  ; get w.b. slotx
.wbtosyn2   move.b   y1,x1
   move.b   x1,d7     ; save slotx for below
   jsr   wbtosyn   ; copy specified w.b. slot to buffer
   move.l   d6,x1
   jsr   creturn
   move.l   #38,x1
   jsr   getabc    ; send f-pars, non-f-pars, or both?
   cmpi.b   #2,y1
   beq   .wbtosyn3
   jsr   writdx7   ; write buffer to synth
   cmpi.b   #1,y1
   beq   returnx
.wbtosyn3   move.l   #wkbank,x1
   clr.l    d0
   move.b   d7,d0
   subq.b   #1,d0
   mulu  #160,d0
   add.l    d0,x1     ; compute pointer to this w.b.'s
   add.l    #145,x1   ; function parameters
   jsr   writfdx7
   bra   returnx  ; restore x5-x1,registers,return

@wbtowb  move.l   #16,d1
   lea   .wbtowb2,a6  ; .getslot return address
   bra   @getslot  ; get 1st w.b. slotx
.wbtowb2 move.b   y1,d2     ; d2 = 1st w.b. slotx
   move.l   #17,d1
   lea   .wbtowb3,a6  ; .getslot return address
   bra   @getslot  ; get 2nd w.b. slotx
.wbtowb3 move.b   y1,d1     ; d1 = 2nd w.b. slotx
   cmp.b    d1,d2     ; if d1=d2 do nothing
   beq   returnx
   move.b   d2,x1
   move.b   d1,x2
   jsr   wbtowb    ; copy 1st w.b. slot to 2nd w.b. slot
   bra   return   ; update w.b. area of screen, return

swap    move.l   #18,d1
   lea   .swap2,a6    ; .getslot return address
   bra   @getslot  ; get 1st w.b. slotx
.swap2   move.b   y1,d2     ; d2 = 1st w.b. slotx
   move.l   #9,d1
   lea   .swap3,a6    ; .getslot return address
   bra   @getslot  ; get 2nd w.b. slotx
.swap3   move.b   y1,d1     ; d1 = 2nd w.b. slotx
   cmp.b    d1,d2     ; if d1=d2 do nothing
   beq   returnx
   move.b   d2,x1
   move.b   d1,x2
   jsr   swapwbs   ; swap the two w.b. slots
   andi.l   #$FF,d2
   subq.l   #1,d2
   move.l   d2,x1
   jsr   redisbnk  ; update 1st w.b. slot name
   bra   return   ; update 2nd w.b. slot name, return

mix  tst.b    nbanks
   bne   .mix2      ; if no banks on disk: error
   move.l   #22,x3
   jsr   branch1
.mix2    lea   .mix3,a6   ; loop back if bad #
.mix3    moveq    #6,d7
   jsr   branch9    ; get #
   jsr   value
   move.l   y1,d1      ; d1.l = #
   ble   .mix6
   cmp.l    #$7F,d1    ; bad # if #<1 or >maxbank
   bgt   .mix6
   cmp.b    maxbank,d1
   bgt   .mix6
   lea   bankflg,a1
   subq.l   #1,a1
   tst.b    0(a1,d1.w)
   bne   .mix4
   move.l   #24,x3     ; error if bank doesn't exist
   jsr   branch2
.mix4    move.b   d1,x1
   jsr   mixbank
   move.b   y1,d7      ; protect y1
   move.l   #wkbank,x1
   move.b   #32,d1    ; for d1.b = 32 to 1
.mixloop jsr   checkws   ; check for mangled data
   add.l    #160,x1
   subq.b   #1,d1
   bgt   .mixloop
   tst.b    d7
   bne   .mix5
   jsr   writinfo
.mix5    jsr   branch13
; bad bank # routine
.mix6    move.l   #1,x2
   jsr   branch11

name    move.l   #15,d1
   lea   .name2,a6    ; return address for @getslot
   bra   @getslot
.name2   move.b   y1,d4     ; protect d7.b = slotx
   lea   .name3,a6    ; loop back to here if bad name
.name3   clr.l    d7
   jsr   branch8   ; get name
   move.l   a0,x1     ; --> name
   move.l   #wkbname,x2
   andi.l   #$FF,d4
   move.b   d4,d1     ; slotx for redisbnk
   subq.l   #1,d4
   mulu  #10,d4
   add.l    d4,x2
   move.b   #10,x3
   jsr   movemem   ; copy name to specified w.b. name
   bra   return

match   move.l   #15,d1
   lea   .match1,a6   ; return address for @getslot
   bra   @getslot  ; get slotx
.match1  move.b   y1,d2     ; d2.b = slotx = 1-32
   lea   .match2,a6    ; loop back if bad #
.match2  moveq    #24,d7
   jsr   branch9    ; get #
   jsr   value
   move.l   y1,d1      ; d1.l = # differ
   blt   .match3
   cmp.l    #$7FFF,d1
   bgt   .match3
   cmp.w    #159,d1
   bgt   .match3
   move.w   d1,x1
   move.b   d2,x2
   jsr   match
   bra   returnx
.match3  move.l   #1,x2
   jsr   branch11

;*****************************************************************************;
;   branch  routines
;      entry and exit conditions are very complex
;*****************************************************************************;

 XDEF branch1
 XDEF branch2
 XDEF branch5
 XDEF branch6
 XDEF branch8
 XDEF branch8b
 XDEF branch9
 XDEF branch11
 XDEF branch13

branch1  clr.b    d7     ; cannot + menu item + reason
   bra   br_3
branch2  moveq    #1,d7   ; cannot + menu item + reason + try again
br_3  move.l   d6,x1
   move.l   d0,x2
   jsr   cannot
br_4  tst.b    d7
   beq   br_0
   jsr   tagtry
   bra   br_99

branch5  clr.b    d7    ; menu item + aborted
   bra   br_7
branch6  moveq    #1,d7    ; menu item + aborted + try again
br_7  move.l   d6,x1
   move.l   d0,x2
   jsr   abort
   bra   br_4

branch8b move.b   #1,x5    ; default w.s. name
   clr.b    x4
   bra   br_10
branch8  clr.b    x5
   clr.b    x4    ; get 10 characters, call parsnam
   bra   br_10
branch9  clr.b    x5
   move.b   #1,x4    ; get 10 characters, call parsnum
br_10    move.l   d6,x1
   jsr   creturn
   move.l   d7,x1
   jsr   getit
   tst.b    y2
   bne   branch5  ; cr: abort
   movea.l  y1,a0
   move.l   a0,x1
   tst.b    x4
   bne   br_12
   jsr   parsnam
   tst.b    y1
   beq   br_98
   clr.l    x2
branch11 move.l   d6,x1    ; parse error: error message, try again
   jsr   errmess
   bra   br_99
br_12    jsr   parsnum
   tst.b    y1
   beq   br_98
   move.l   #1,x2
   bra   branch11

branch13 move.l   d6,x1    ; re-init screen, return to main
   move.l   d0,x2
   jsr   initscr
   bra   br_0

br_0  addq.l   #4,a7    ; return to routine which called the
         ; routine which called a branch routine:
   move.l   (a7)+,x5  ; restore x5-x1,registers,return
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6
   rts

br_99    addq.l   #4,a7    ; return to address in a6
   jmp   (a6)

br_98    rts      ; return

;*****************************************************************************;
;   diskerr
;      called after a routine requiring disk i/o
;      entry conditions: y1.b = disk i/o error code
;      d6.l = menux, d0.l = itemx
;*****************************************************************************;

 XDEF diskerr

diskerr  cmpi.b   #1,y1     ; cannot read
   bne   .2
   move.l   #18,x3
   jsr   branch1

.2    cmpi.b   #2,y1     ; cannot write
   bne   .4
   move.l   #23,x3
   jsr   branch1

.4    cmpi.b   #4,y1     ; format hard-failed
   bne   .5
   move.l   #5,x3
   jsr   branch1

.5    move.l   #25,x3    ; format soft-failed
   jsr   branch1

;*****************************************************************************;
;   initpri4 -- part of primary initialization daisy chain
;      get screen rez and define bwflag
;*****************************************************************************;

 XDEF initpri4

initpri4:
   move.w   #4,-(a7)  ; get resolution (0 low, 1 med, 2 hi)
   trap  #14
   addq.l   #2,a7
   move.w   d0,bwflag
   bne   .skip
   move.w   #1,bwflag    ; bwflag=1 for color, =2 for b&w

; go on to next link in daisy chain
.skip   jsr   initpri5
   rts
