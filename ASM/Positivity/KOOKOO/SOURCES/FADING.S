; *********************************
; **	                 **
; **  Fading routine by Dracula  **
; **       made on june 93       **
; **  commercial use prohibited  **
; **	                 **
; *********************************
; Parameters:
;     a0.l = adress of initial colors.
;     a1.l = adress for colors storage.
;     d0.w = fading index. ( between 1-7).
;     d1.w = indicates if we have to change background color.
;            ( d1=0 no, else yes. )
; Uses no register, uses no customchips!...
;   ( Who needs a copper anyway?... )

;************
 Section TEXT

  movem.l	d2-d6/a2-a4,-(sp)

  tst.w	d1	; Change the background color?
  beq.s	.no_backgr
.backgr_change:		; Yes.
  move.w	#$f,d6	; Then change 16 colors.
  bra.s	.prepare

.no_backgr:		; No.
  move.w	(a0)+,(a1)+	; So copy the backgr color,
  move.w	#$e,d6	; and change 15 colors.
  
.prepare:
  move.w	d0,a2	; a2=index for the blue compound.
  lsl.w	#$4,d0
  move.w	d0,a3	; a3=.. green ..
  lsl.w	#$4,d0
  move.w	d0,a4	; a4=.. red ..
  
  move.w	#$007,d0	; d0=mask for the blue compound.
  move.w	#$070,d1	; d1=.. green ..
  move.w	#$700,d2	; d2=.. red ..
    
.one_color:
  move.w	(a0)+,d3	; Load the color.
  move.w	d3,d4
  move.w	d4,d5
  and.w	d0,d3	; d3 contains the blue compound.
  and.w	d1,d4	; d4 .. green ..
  and.w	d2,d5	; d5 .. red ..
  cmp.w	a2,d3	; Blue compound bigger than fading index?
  ble.s	.blue_ok
  move.w	a2,d3	; Yes, then replace.
.blue_ok:
  cmp.w	a3,d4	; Same with the green.
  ble.s	.green_ok
  move.w	a3,d4
.green_ok:
  cmp.w	a4,d5	; And with the red.
  ble.s	.melt_rvb
  move.w	a4,d5
.melt_rvb:
  or.w	d5,d4	; Melt the compounds.
  or.w	d4,d3
  move.w	d3,(a1)+
  dbra	d6,.one_color
  
  
.end:
  movem.l	(sp)+,d2-d6/a2-a4
  rts
  