; *******************************
; **	               **
; **  Line routine by Dracula  **
; **     made on june 93       **
; ** commercial use prohibited **
; **	               **
; *******************************
; Parameters:
;     a0.l = ramvideo adress.
;     d0.l = x1.
;     d1.l = y1.
;     d2.l = x2.
;     d3.l = y2.
; Uses no register, uses no customchips!...
;   ( Who needs a blitter anyway?... )

;************
 Section TEXT

  movem.l	d4-d5/a1,-(sp)
 
  sub.w	d0,d2	; d2=x2-x1.
  beq	.vline	; Vertical line?
  bmi.s	.dxneg 	; We want to begin by the right brow.
.dxpos:
  exg.l	d1,d3	; If x1 was on left, then we exchange
  add.w	d2,d0	; the two brows in order to have the
  neg.w	d2	; first brow (d0,d1) on the right.
.dxneg:
  neg.w	d2	; d2=abs(x2-x1).
  move.l	#$a0,a1	; a1=$a0*sy.
  sub.w	d1,d3	; d3=y2-y1.
  beq	.hline	; Horizontal line?
  bpl.s	.dypos
.dyneg:
  move.l	#-$a0,a1	; if y2-y1 is negative, sy=-1.
  neg.w	d3	; d3=dy=abs(y2-y1).
.dypos:
  moveq.l	#$0,d4	; Now we calculate the beginning adress.
  move.w	d1,d4	; So, we mulitiply y1 by $a0.
  add.w	d4,d4
  add.w	d4,d4
  add.w	d1,d4
  lsl.w	#$5,d4
  add.l	d4,a0	; a0 points on the good line.

  moveq.l	#$0,d1	; Now we have to know the beginning
  moveq.l	#$f,d4	; pattern and the beginning word.
  move.w	d0,d1
  and.l	d4,d0	; d0=x1 mod(16).
  sub.w	d0,d1	; d1=x1-x1 mod(16).
  lsr.w	#$1,d1	; division by 2.
  add.l	d1,a0	; a0 points on the good word.
  moveq.l	#$0,d1
  sub.l	d4,d0
  neg.l	d0	; d0=15-x1 mod(16).
  bset.l	d0,d1	; d1 is the pattern.
  cmp.w	d2,d3
  bgt	.big_slope 	


;*********************************
; First case: dx>=dy and dx<=2dy.
;*********************************
 
.low_slope:
  move.w	d2,d4	; d4=nb of points.
  add.w	d3,d3	; d3=2*dy.
  move.w	d3,d5
  sub.w	d2,d5	; d5=Error=2dy-dx.
  bmi	.very_low	; dx greater than 2dy?
  add.w	d2,d2	; d2=2*dx.
  sub.w	d3,d2	; d2=2*dx-2*dy.
  or.w	d1,(a0)	; Print first point.
.low_epos:		; The next point is on the diagonal.
  add.l	a1,a0	; y=y+sy.
  add.w	d1,d1	; x=x+sx. ( We change the pattern. )
  beq.s	.low_xnul1	; Next word?
  or.w	d1,(a0)	; Print the point.
  subq.w	#$1,d4	; We have drawn one point.
  beq.s	.low_end
  sub.w	d2,d5	; Error=Error-2dx+2dy.
  bpl.s	.low_epos
.low_eneg:		; The next point is on the hline.
  add.w	d1,d1	; x=x+sx.
  beq.s	.low_xnul2	; Next word.
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.low_end
  add.w	d3,d5	; Error=Error+2dy.
  bra.s	.low_epos	; Next point IS on the diagonal.
 
.low_xnul2:
  moveq.l	#$1,d1	; New pattern.
  subq.l	#$8,a0	; Previous word.
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.low_end
  add.w	d3,d5	; Error=Error+2dy.
  cmpi.w	#$10,d4	; More than 16 points to draw?
  blt.s	.low_epos2	; Next point on the diagonal.
  sub.w	#$f,d4
  bra.s	.low_x0_epos1
 
.low_end: 
  movem.l	(sp)+,d4-d5/a1
  rts
 
.low_x0_less:
  sub.w	d2,d5	; Error.
  bpl.s	.low_epos2
  bra.s	.low_eneg2

.low_epos2:		; This is the same as above, except that
  add.l	a1,a0	; we now know ther are less than 16 points
  add.w	d1,d1	; to draw, so there will be no more
  or.w	d1,(a0)	; pattern changing.
  subq.w	#$1,d4
  beq.s	.low_end
  sub.w	d2,d5
  bpl.s	.low_epos2
.low_eneg2:
  add.w	d1,d1
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.low_end
  add.w	d3,d5	
  bra.s	.low_epos2
 
.low_xnul1:
  moveq.l	#$1,d1	; New pattern.
  subq.l	#$8,a0	; Previous word.
  or.w	d1,(a0) 
  subq.w	#$1,d4
  beq.s	.low_end
  cmpi.w	#$10,d4	; More than 16 points to draw?
  blt.s	.low_x0_less	; No!
  sub.w	#$f,d4	; Yes, then we now will draw 15 points
  sub.w	d2,d5	; without taking care of the patten changes
  ble.s	.low_x0_eneg1	; and of the number of points.
.low_x0_epos1:
  add.l	a1,a0	; y=y+sy.
  add.w	d1,d1	; Next pattern.
  or.w	d1,(a0)
  sub.w	d2,d5	; Error.
  ble.s	.low_x0_eneg2
.low_x0_epos2:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_eneg3
.low_x0_epos3:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  bpl.s	.low_x0_epos4
.low_x0_eneg4:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_epos5

.low_x0_eneg1:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_epos2
 
.low_x0_eneg2:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_epos3
 
.low_x0_eneg3:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
.low_x0_epos4:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_eneg5
.low_x0_epos5:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_eneg6
.low_x0_epos6:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_eneg7
.low_x0_epos7:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  bpl.s	.low_x0_epos8
.low_x0_eneg8:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_epos9

.low_x0_eneg5:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_epos6
  
.low_x0_eneg6:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_epos7
  
.low_x0_eneg7:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
.low_x0_epos8:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_eneg9
.low_x0_epos9:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_enegA
.low_x0_eposA:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_enegB
.low_x0_eposB:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  bpl.s	.low_x0_eposC
.low_x0_enegC:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_eposD

.low_x0_eneg9:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_eposA
  
.low_x0_enegA:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_eposB
  
.low_x0_enegB:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
.low_x0_eposC:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_enegD
.low_x0_eposD:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_enegE
.low_x0_eposE:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	
  ble.s	.low_x0_enegF
.low_x0_eposF:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d2,d5	; Now, we have drawn 16 points, we must	
  ble	.low_xnul2  	; change the pattern again...
  add.l	a1,a0	; Cos it's not included in low_xnul1.
  bra	.low_xnul1

.low_x0_enegD:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_eposE

.low_x0_enegE:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  bra.s	.low_x0_eposF

.low_x0_enegF:
  add.w	d1,d1
  or.w	d1,(a0)
  add.w	d3,d5	
  add.l	a1,a0	; Cos it's not included in low_xnul1.
  bra	.low_xnul1	; Same comment as for low_x0_eposF.

;**********************
;  Second  case:  dx>2dy.
;**********************
  
.very_low:
  add.w	d2,d2	; This is a mere copy of the low_slope
  sub.w	d3,d2	; case, except that:
  move.w	(a0),d0	;   - I don't directly work on the  
  or.w	d1,d0	;  ramvideo, I put the words to be
.vlow_eneg:		;  changed in d0 and work on d0.
  add.w	d1,d1	;   - After a diagonal move, you
  beq.s	.vlow_xnul1	;  automatically have a horizontal
  or.w	d1,d0	;  move. ( It was the contrary in
  subq.w	#$1,d4	;  .vlow_slope! )
  beq.s	.vlow_end
  add.w	d3,d5
  ble.s	.vlow_eneg
.vlow_epos:
  move.w	d0,(a0)	; We have to change the word, so we
  add.l	a1,a0	; shall put d0 in the ramvideo before.
  add.w	d1,d1
  beq.s	.vlow_xnul2
  move.w	(a0),d0
  or.w	d1,d0
  subq.w	#$1,d4
  beq.s	.vlow_end
  sub.w	d2,d5
  bra.s	.vlow_eneg	; Next point IS on the horizontal.
  
.vlow_xnul2:
  moveq.l	#$1,d1	; New pattern.
  subq.l	#$8,a0	; Previous word.
  move.w	(a0),d0
  or.w	d1,d0
  subq.w	#$1,d4
  beq.s	.vlow_end
  sub.w	d2,d5
  cmpi.w	#$10,d4	; More than 16 points to draw?
  blt.s	.vlow_eneg2	; Next point on the horizontal.
  sub.w	#$f,d4
  bra.s	.vlow_x0_eneg1
  
.vlow_end:  
  move.w	d0,(a0)
  movem.l	(sp)+,d4-d5/a1
  rts

.vlow_x0_less:
  add.w	d3,d5
  ble.s	.vlow_eneg2
  bra.s	.vlow_epos2

.vlow_eneg2:
  add.w	d1,d1
  or.w	d1,d0
  subq.w	#$1,d4
  beq.s	.vlow_end
  add.w	d3,d5
  ble.s	.vlow_eneg2
.vlow_epos2:
  move.w	d0,(a0)	; We have to change the word, so we
  add.l	a1,a0	; shall put d0 in the ramvideo before.
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  subq.w	#$1,d4
  beq.s	.vlow_end
  sub.w	d2,d5
  bra.s	.vlow_eneg2	; Next point IS on the horizontal.

.vlow_xnul1:
  move.w	d0,(a0)	; Save the word.
  moveq.l	#$1,d1	; New pattern.
  subq.l	#$8,a0	; Previous word.
  move.w	(a0),d0
  or.w	d1,d0
  subq.w	#$1,d4
  beq.s	.vlow_end
  cmpi.w	#$10,d4	; More than 16 points to draw?
  blt.s	.vlow_x0_less	; Next point on the horizontal.
  sub.w	#$f,d4
  add.w	d3,d5
  bpl.s	.vlow_x0_epos1
.vlow_x0_eneg1:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_epos2
.vlow_x0_eneg2:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_epos3
.vlow_x0_eneg3:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  ble.s	.vlow_x0_eneg4
.vlow_x0_epos4:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_eneg5

.vlow_x0_epos1:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_eneg2
 
.vlow_x0_epos2:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_eneg3
 
.vlow_x0_epos3:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
.vlow_x0_eneg4:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_epos5
.vlow_x0_eneg5:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_epos6
.vlow_x0_eneg6:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_epos7
.vlow_x0_eneg7:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  ble.s	.vlow_x0_eneg8
.vlow_x0_epos8:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_eneg9

.vlow_x0_epos5:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_eneg6
 
.vlow_x0_epos6:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_eneg7
 
.vlow_x0_epos7:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
.vlow_x0_eneg8:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_epos9
.vlow_x0_eneg9:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_eposA
.vlow_x0_enegA:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_eposB
.vlow_x0_enegB:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  ble.s	.vlow_x0_enegC
.vlow_x0_eposC:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_enegD

.vlow_x0_epos9:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_enegA
 
.vlow_x0_eposA:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_enegB
 
.vlow_x0_eposB:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
.vlow_x0_enegC:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_eposD
.vlow_x0_enegD:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_eposE
.vlow_x0_enegE:
  add.w	d1,d1
  or.w	d1,d0
  add.w	d3,d5
  bpl.s	.vlow_x0_eposF
.vlow_x0_enegF:
  add.w	d1,d1	
  or.w	d1,d0
  move.w	d0,(a0)
  add.w	d3,d5	
  ble	.vlow_xnul1
  add.l	a1,a0	; Cos it's not included in .vlow_xnul2.
  bra	.vlow_xnul2    
  
.vlow_x0_eposD:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_enegE
  
.vlow_x0_eposE:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  sub.w	d2,d5
  bra.s	.vlow_x0_enegF
  
.vlow_x0_eposF:
  move.w	d0,(a0)
  add.l	a1,a0
  move.w	(a0),d0
  add.w	d1,d1
  or.w	d1,d0
  move.w	d0,(a0)
  sub.w	d2,d5
  bra	.vlow_xnul1


;********************************
; Third case: dx<dy and dy<=2dx.
;********************************
 
.big_slope:		; In this case, after a vertical move 
  move.w	d3,d4	; we automatically have a diagonal one.
  add.w	d2,d2	; As for low_slope, when we have to
  move.w	d2,d5	; change the pattern, we look if we have
  sub.w	d3,d5	; more than 16 points, if it's the case
  bmi	.very_big	; we draw 16 points without worrying about
  add.w	d3,d3	; the number of points and the pattern
  sub.w	d2,d3	; changes, but when this 16 points are
  or.w	d1,(a0)	; drawn, we cannot be sure that there will
.big_epos:		; be a new pattern.
  add.l	a1,a0
  add.w	d1,d1
  beq.s	.big_xnul
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.big_end
  sub.w	d3,d5
  bpl.s	.big_epos
.big_eneg:
  add.l	a1,a0
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.big_end
  add.w	d2,d5
  bra.s	.big_epos
  
.big_end:  
  movem.l	(sp)+,d4-d5/a1
  rts
  
.big_x0_less:
  sub.w	d3,d5
  bpl.s	.big_epos2
  bra.s	.big_eneg2

.big_epos2:		
  add.l	a1,a0
  add.w	d1,d1
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.big_end
  sub.w	d3,d5
  bpl.s	.big_epos2
.big_eneg2:
  add.l	a1,a0
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.big_end
  add.w	d2,d5	
  bra.s	.big_epos2
  
.big_xnul:
  moveq.l	#$1,d1	
  subq.l	#$8,a0	
  or.w	d1,(a0)  
  subq.w	#$1,d4
  beq.s	.big_end
  cmpi.w	#$10,d4	
  blt.s	.big_x0_less	
  sub.w	#$f,d4	
  sub.w	d3,d5	
  ble.s	.big_x0_eneg1	
.big_x0_epos1:
  add.l	a1,a0	
  add.w	d1,d1	
  or.w	d1,(a0)
  sub.w	d3,d5
  ble.s	.big_x0_eneg2
.big_x0_epos2:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_eneg3
.big_x0_epos3:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bpl.s	.big_x0_epos4
.big_x0_eneg4:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_epos5

.big_x0_eneg1:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_epos2
  
.big_x0_eneg2:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_epos3
  
.big_x0_eneg3:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
.big_x0_epos4:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_eneg5
.big_x0_epos5:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_eneg6
.big_x0_epos6:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_eneg7
.big_x0_epos7:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bpl.s	.big_x0_epos8
.big_x0_eneg8:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_epos9

.big_x0_eneg5:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_epos6
  
.big_x0_eneg6:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_epos7
  
.big_x0_eneg7:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
.big_x0_epos8:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_eneg9
.big_x0_epos9:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_enegA
.big_x0_eposA:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_enegB
.big_x0_eposB:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bpl.s	.big_x0_eposC
.big_x0_enegC:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_eposD

.big_x0_eneg9:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_eposA
  
.big_x0_enegA:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_eposB
  
.big_x0_enegB:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
.big_x0_eposC:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_enegD
.big_x0_eposD:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_enegE
.big_x0_eposE:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  ble.s	.big_x0_enegF
.big_x0_eposF:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5
  ble	.big_eneg
  bra	.big_epos

.big_x0_enegD:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_eposE

.big_x0_enegE:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra.s	.big_x0_eposF

.big_x0_enegF:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bra	.big_epos


;**********************
; Fourth case: dy>2dx.
;**********************
  
.very_big:
  add.w	d3,d3	; After a diagonal move,
  sub.w	d2,d3	; there is a vertical one.
  or.w	d1,(a0)
.vbig_eneg:
  add.l	a1,a0
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.vbig_end
  add.w	d2,d5
  ble.s	.vbig_eneg
.vbig_epos:
  add.l	a1,a0
  add.w	d1,d1
  beq.s	.vbig_xnul
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.vbig_end
  sub.w	d3,d5
  bra.s	.vbig_eneg
  
.vbig_end:  
  movem.l	(sp)+,d4-d5/a1
  rts

.vbig_eneg2:
  add.l	a1,a0
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.vbig_end
  add.w	d2,d5
  ble.s	.vbig_eneg2
.vbig_epos2:
  add.l	a1,a0
  add.w	d1,d1
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.vbig_end
  sub.w	d3,d5
  bra.s	.vbig_eneg2

.vbig_xnul:
  moveq.l	#$1,d1
  subq.l	#$8,a0
  or.w	d1,(a0)
  subq.w	#$1,d4
  beq.s	.vbig_end
  sub.w	d3,d5
  cmpi.w	#$10,d4	
  blt.s	.vbig_eneg2
  sub.w	#$f,d4
.vbig_x0_eneg1:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_epos2
.vbig_x0_eneg2:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_epos3
.vbig_x0_eneg3:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  ble.s	.vbig_x0_eneg4
.vbig_x0_epos4:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_eneg5

.vbig_x0_epos2:		; There is no .vbig_x0_epos1.
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_eneg3
  
.vbig_x0_epos3:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
.vbig_x0_eneg4:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_epos5
.vbig_x0_eneg5:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_epos6
.vbig_x0_eneg6:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_epos7
.vbig_x0_eneg7:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  ble.s	.vbig_x0_eneg8
.vbig_x0_epos8:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_eneg9

.vbig_x0_epos5:	
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_eneg6

.vbig_x0_epos6:	
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_eneg7
  
.vbig_x0_epos7:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
.vbig_x0_eneg8:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_epos9
.vbig_x0_eneg9:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_eposA
.vbig_x0_enegA:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_eposB
.vbig_x0_enegB:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  ble.s	.vbig_x0_enegC
.vbig_x0_eposC:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_enegD

.vbig_x0_epos9:	
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_enegA

.vbig_x0_eposA:	
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_enegB
  
.vbig_x0_eposB:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
.vbig_x0_enegC:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_eposD
.vbig_x0_enegD:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_eposE
.vbig_x0_enegE:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  bpl.s	.vbig_x0_eposF
.vbig_x0_enegF:
  add.l	a1,a0
  or.w	d1,(a0)
  add.w	d2,d5	
  ble	.vbig_eneg
  bra	.vbig_epos

.vbig_x0_eposD:
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_enegE

.vbig_x0_eposE:	
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra.s	.vbig_x0_enegF

.vbig_x0_eposF:	
  add.l	a1,a0	
  add.w	d1,d1
  or.w	d1,(a0)
  sub.w	d3,d5	
  bra	.vbig_eneg
  
;***********************
; x1=x2, vertical line.
;***********************

.vline:
  move.l	#$a0,d4	; d4=sy.
  sub.w	d1,d3	; d3=dy.
  beq.s	.single_dot	; dy=0 et dx=0.
  bpl.s	.v_dypos	; If dy<0 we have to change
  neg.w	d3	; the signs of dy and sy.
  neg.l	d4
.v_dypos:
  moveq.l	#$0,d5
  move.w	d1,d5
  add.w	d5,d5
  add.w	d5,d5
  add.w	d1,d5
  lsl.w	#$5,d5
  add.l	d5,a0	; a0 points the good line.
  moveq.l	#$0,d1
  move.w	d0,d1
  andi.w	#$fff0,d1	; d1=x-x mod(16).
  sub.w	d1,d0	; d0=x mod(16).
  lsr.w	#$1,d1	; Number of words before the good x.
  add.l	d1,a0	; a0 points on the good word.
  sub.w	#$f,d0
  neg.w	d0	; d0=15-x mod(16).
  moveq.l	#$0,d1
  bset.l	d0,d1	; d1 contains the pattern.
.v_one_line:
  or.w	d1,(a0)
  add.l	d4,a0
  dbra	d3,.v_one_line
  movem.l	(sp)+,d4-d5/a1
  rts

.single_dot:
  moveq.l	#$0,d4	; Calculate coords and pattern.
  move.w	d1,d4
  add.w	d4,d4
  add.w	d4,d4
  add.w	d1,d4
  lsl.w	#$5,d4
  add.l	d4,a0	; a0 points the good line.
  move.w	d0,d1
  andi.w	#$fff0,d1	; d1=x-x mod(16).
  sub.w	d1,d0	; d0=x mod(16).
  lsr.w	#$1,d1	; Number of words before the good x.
  add.l	d1,a0	; a0 points on the good word.
  sub.w	#$f,d0
  neg.w	d0	; d0=15-x mod(16).
  moveq.l	#$0,d1
  bset.l	d0,d1	; d1 contains the pattern.
  or.w	d1,(a0)	; Print the dot.
  movem.l	(sp)+,d4-d5/a1
  rts

;*************************
; y1=y2, horizontal line.
;*************************

.hline:
  sub.w	d0,d2	; We want to know x2.
  neg.w	d2	; d0 greater than d2, so we
  moveq.l	#$0,d3	; call d0=xsup, d2=xinf.
  move.w	d1,d3
  add.w	d3,d3
  add.w	d3,d3
  add.w	d1,d3
  lsl.w	#$5,d3
  add.l	d3,a0	; a0 points the good line.
  
  moveq.l	#$0f,d4
  moveq.l	#$0,d1
  move.l	d1,d3
  move.w	d0,d1
  move.w	d2,d3
  and.l	d4,d0	; d0=xsup mod(16).
  and.l	d4,d2	; d2=xinf mod(16).
  sub.l	d0,d1	; d1=xsup-xsup mod(16).
  sub.l	d2,d3	; d3=xinf-xinf mod(16).
  lsr.w	#$1,d3	; d3 number of bytes before the 1st pattern.
  lsr.w	#$1,d1	; d1 .... 2nd pattern.
  add.l	d3,a0	; a0 points on the 1st word.
  
  add.w	d0,d0	; We search the patterns.
  add.w	d2,d2
  move.l	#.patterns,a1	; Adress of beginning patterns.
  move.w	(a1,d2.w),d2
  add.l	#$20,a1	; Adress of end patterns.
  move.w	(a1,d0.w),d0

  sub.w	d3,d1	; Number of words to be drawn.
  beq	.h_melted	; Melted patterns?
  subq.w	#$8,d1
  beq.s	.h_near	; Patterns are near?

  or.w	d2,(a0)	; 1st pattern.
  addq.l	#$8,a0
  move.w	#$ffff,d5	; Internal pattern.	 
.h_fill:
  move.w	d5,(a0)
  addq.l	#$8,a0
  subq.w	#$8,d1
  bne.s	.h_fill 
  or.w	d0,(a0)	; Last pattern.
  movem.l	(sp)+,d4-d5/a1
  rts
 
.h_melted:
  and.w	d0,d2	
  or.w	d2,(a0)	
  movem.l	(sp)+,d4-d5/a1
  rts
 
.h_near:
  or.w	d2,(a0)	
  addq.l	#$8,a0
  or.w	d0,(a0)	
  movem.l	(sp)+,d4-d5/a1
   rts

.patterns:
  dc.w	$ffff,$7fff,$3fff,$1fff
  dc.w	$0fff,$07ff,$03ff,$01ff
  dc.w	$00ff,$007f,$003f,$001f
  dc.w	$000f,$0007,$0003,$0001
  
  dc.w	$8000,$c000,$e000,$f000
  dc.w	$f800,$fc00,$fe00,$ff00
  dc.w	$ff80,$ffc0,$ffe0,$fff0
  dc.w	$fff8,$fffc,$fffe,$ffff
  
  
  
