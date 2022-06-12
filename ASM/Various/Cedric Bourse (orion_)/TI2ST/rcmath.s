;
; PedroM - Operating System for Ti-89/Ti-92+/V200.
; Copyright (C) 2003, 2005-2008 Patrick Pelissier
;
; This program is free software ; you can redistribute it and/or modify it under the
; terms of the GNU General Public License as published by the Free Software Foundation;
; either version 2 of the License, or (at your option) any later version. 
; 
; This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
; See the GNU General Public License for more details. 
; 
; You should have received a copy of the GNU General Public License along with this program;
; if not, write to the 
; Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 


; ***************************************************************
; 			Float Low Level functions
; ***************************************************************

FLOAT.sign	EQU	0
FLOAT.exponent	EQU	2 	; $2000 < expo < $6000
FLOAT.mantissa	EQU	4
FLOAT.sizeof	EQU	12

BCD.exponent	EQU	0
BCD.mantissa	EQU	2

; ***************************************************************
; 			Internal functions
; ***************************************************************


; In:
;	a0 -> AMS Float
;	a1 -> Pedrom Floating
FloatAMS2Internal:
	; Read AMS float
	move.w	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	ext.l	d1
	andi.w	#$7FFF,d1
	movem.l	d1-d3,(a1)
	bra	FloatAdjustA1

; In:
;	a0 -> Pedrom Floating
;	a1 -> AMS Float
FloatInternal2AMS:
	movem.l	(a0),d1-d3
	add.w	d1,d1
	lsr.l	#1,d1
	move.w	d1,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	rts
	
; Adjust the floating point number to use all significant bits.
FloatAdjust:
	lea	FloatReg1,a1
FloatAdjustA1
	lea	FLOAT.mantissa(a1),a0
.loop		tst.b	(a0)+
		beq.s	.loop
	move.b	-(a0),d1
	suba.l	a1,a0
	subq.l	#FLOAT.mantissa,a0
	move.w	a0,d0
	add.w	d0,d0
	andi.b	#$F0,d1
	bne.s	.Ok
		addq.w	#1,d0
.Ok	movem.l	(a1),d1-d3
	bsr.s	FloatLeftShift
	movem.l	d1-d3,(a1)
	bra.s	FloatCheckA1

; Check if float is too big and copy overflow otherwise
FloatCheck:
	lea	FloatReg1,a1
FloatCheckA1:
	move.w	FLOAT.exponent(a1),d1
	cmpi.w	#$6000,d1
	bhi.s	.Infinity
	cmpi.w	#$2000,d1
	bls.s	.Zero
		rts
.Zero	movem.l	FloatZero(pc),d1-d3
.Copy	movem.l	d1-d3,(a1)
	rts
.Infinity:
	tst.w	FLOAT.sign(a1)
	bge.s	.PosInfinity
		movem.l	FloatNegInfinity(pc),d1-d3
		bra.s	.Copy
.PosInfinity	movem.l	FloatPosInfinity(pc),d1-d3
		bra.s	.Copy
	
; Decalage gauche: (d0.w)
; In:	d1-d3 = Float
; Out:	d1-d3 = Update Float
FloatLeftShift:
	tst.w	d0
	beq.s	.Done
		sub.w	d0,d1
		cmpi.w	#8,d0
		blt.s	.Next4
			cmpi.w	#16,d0
			blt.s	.Next8
				move.l	#$2000,d1	; Zero Exponent / Sign >0
				moveq	#0,d2		; Mantisse
				moveq	#0,d3		; Mantisse
				bra.s	.Done
.Next8			move.l	d3,d2
			moveq	#0,d3
			subq.w	#8,d0
			beq.s	.Done
			lsl.w	#2,d0
			lsl.l	d0,d2
			bra.s	.Done
.Next4		cmpi.w	#4,d0
		blt.s	.Next2
			swap	d2
			swap	d3
			move.w	d3,d2
			clr.w	d3
			subq.w	#4,d0
			beq.s	.Done
.Next2		cmpi.w	#2,d0
		blt.s	.Next1
			lsl.l	#8,d2
			rol.l	#8,d3
			move.b	d3,d2
			clr.b	d3
			subq.w	#2,d0
			beq.s	.Done
.Next1		lsl.l	#4,d2
		rol.l	#4,d3
		move.b	d3,d0
		andi.b	#$F,d0
		or.b	d0,d2
		andi.b	#$F0,d3
.Done	rts
	
; Decalage droite: (d0.w)
; In:	d1-d3 = Float
; Out:	d1-d3 = Update Float
FloatRightShift:
	tst.w	d0
	beq.s	.Done
		add.w	d0,d1
		cmpi.w	#8,d0
		blt.s	.Next4
			cmpi.w	#16,d0
			blt.s	.Next8
				move.l	#$2000,d1	; Zero Exponent / Sign >0
				moveq	#0,d2
				moveq	#0,d3
				bra.s	.Done
.Next8			move.l	d2,d3
			moveq	#0,d2
			subq.w	#8,d0
			beq.s	.Done
			lsl.w	#2,d0
			lsr.l	d0,d3
			bra.s	.Done
.Next4		cmpi.w	#4,d0
		blt.s	.Next2
			move.w	d2,d3
			clr.w	d2
			swap	d2
			swap	d3
			subq.w	#4,d0
			beq.s	.Done
.Next2		cmpi.w	#2,d0
		blt.s	.Next1
			move.b	d2,d3
			lsr.l	#8,d2
			ror.l	#8,d3
			subq.w	#2,d0
			beq.s	.Done
.Next1		moveq	#$F,d0
		and.b	d2,d0
		andi.b	#$F0,d3
		or.b	d0,d3
		lsr.l	#4,d2
		ror.l	#4,d3
.Done	rts

; Calculate the Ceil part of a float
; TODO: Buggy, it looks like much more floor
FloatCeil:
	move.w	FloatReg1+FLOAT.exponent,d0
	sub.w	#$4000+15,d0
	neg.w	d0
	movem.l	FloatReg1,d1-d3
	jsr	FloatRightShift
	movem.l	d1-d3,FloatReg1
	bra	FloatAdjust
	
; Out:
;	d0.b	= 0 if equal
;		= 1 if Float 1 > Float 2
;		= -1 if Float 1 < Float 2
FloatCmp
	; Check sign
	move.w	FloatReg2+FLOAT.sign,d0
	cmp.w	FloatReg1+FLOAT.sign,d0
	beq.s	.SameSign
		bhi.s	.F0Sup
.F1Sup		moveq	#-1,d0
		rts
.F0Sup		moveq	#1,d0
		rts
.SameSign
	lea	FloatReg2,a0
	tst.w	d0	
	beq.s	FloatUCmp
		moveq	#-1,d0		; We assume Float 2 < Float 1 since both are  <0
		bra.s	FloatUCmp_entry

; Cmp the abs values of the float FReg1 and Float ptr by a0
; In:
;	a0 -> Internal Float
; Out:
;	d0.b	= 0 if equal
;		= 1 if Float 1 > Float 2
;		= -1 if Float 1 < Float 2
FloatUCmp:
	moveq	#1,d0
FloatUCmp_entry
	; Check Exponent
	move.w	FloatReg1+FLOAT.exponent,d1
	cmp.w	FLOAT.exponent(a0),d1
	beq.s	.SameExponent
		bhi.s	.F0Sup2
.F1Sup2		neg.w	d0			
.F0Sup2		rts
.SameExponent
	; Check Mantissa
	move.l	FloatReg1+FLOAT.mantissa,d1
	cmp.l	FLOAT.mantissa(a0),d1
	beq.s	.SameMantissa1
		bhi.s	.F0Sup2
		bra.s	.F1Sup2	
.SameMantissa1
	move.l	FloatReg1+FLOAT.mantissa+4,d1
	cmp.l	FLOAT.mantissa+4(a0),d1
	beq.s	.SameMantissa2
		bhi.s	.F0Sup2
		bra.s	.F1Sup2
.SameMantissa2
	clr.w	d0
	rts

; In:
;	d0.w = Int		TODO: Long args !
Short2Float:
	ext.l	d0

; In:
;	d0.l = Int		TODO: Long args !
Int2Float:
	lea	FloatReg1,a0
	clr.w	d1
	tst.l	d0
	beq.s	.Zero
	bge.s	.Ok
		neg.l	d0
		moveq	#-1,d1
.Ok	move.w	d1,(a0)+
	move.w	#$4000,(a0)
	; Convert to 10 base
	moveq	#0,d2
.Loop		divu.w	#10,d0
		move.w	d0,d1
		beq.s	.End
		swap	d0
		or.b	d0,d2
		ror.l	#4,d2
		clr.w	d0
		swap	d0
		addq.w	#1,(a0)		; Exponent++
		bra.s	.Loop
.End	swap	d0			; Setup the final
	or.b	d0,d2			; finger
	ror.l	#4,d2			
	addq.l	#2,a0			; Skip Exponent
	; Set up the mantisse
	move.l	d2,(a0)+
	clr.l	(a0)+
	bra	FloatAdjust
.Zero	move.l	#$00002000,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	rts
	
; In:	FReg1
Float2Int:
	move.w	FloatReg1+FLOAT.exponent,d0
	sub.w	#$4000+15,d0
	neg.w	d0
	movem.l	FloatReg1,d1-d3
	jsr	FloatRightShift
	; Convert Bcd d2-d3 to int d4.l
	moveq	#0,d4
	moveq	#16-1,d5
.loop		move.l	d2,d0
		rol.l	#4,d0
		andi.l	#$F,d0
		mulu.w	#10,d4
		add.l	d0,d4
		moveq	#1,d0
		jsr	FloatLeftShift
		dbf	d5,.loop
	; Change sign
	tst.w	FloatReg1+FLOAT.sign
	beq.s	.Pos
		neg.l	d4
.Pos	move.l	d4,d0
	rts
	
;	Freg1 - Freg2
;	(Both destroyed)
FloatSub:
	not.w	FloatReg2+FLOAT.sign			; Change the Freg2 sign

;	FReg1 + FReg2 
;	(Both destroyed)
FloatAdd:
	; Sort so that Abs(FloatReg2) < Abs(FloatReg1)
	lea	FloatReg2,a0
	jsr	FloatUCmp
	tst.w	d0
	bgt.s	.OkOrdo
		movem.l	FloatReg1,d1-d6			; Exchange the float registers (Load Reg1 & Reg2)
		movem.l	d4-d6,FloatReg1			; Save Reg1 
		movem.l	d1-d3,FloatReg2			; Save Reg2
.OkOrdo
	; Shift FloatReg2
	move.w	FloatReg1+FLOAT.exponent,d0
	sub.w	FloatReg2+FLOAT.exponent,d0
	beq.s	.NoShift
		movem.l	FloatReg2,d1-d3
		jsr	FloatRightShift
		movem.l	d1-d3,FloatReg2
.NoShift
	; Determine l'operation a faire
	move.w	FloatReg1+FLOAT.sign,d0
	cmp.w	FloatReg2+FLOAT.sign,d0
	bne.s	.SubMantissa
		lea	FloatReg1+FLOAT.sizeof,a0
		lea	FloatReg2+FLOAT.sizeof,a1
		; Add the mantissa
		move	#0,CCR
		abcd	-(a1),-(a0)
		abcd	-(a1),-(a0)
		abcd	-(a1),-(a0)
		abcd	-(a1),-(a0)
		abcd	-(a1),-(a0)
		abcd	-(a1),-(a0)
		abcd	-(a1),-(a0)
		abcd	-(a1),-(a0)
		bcc.s	.ret
			; Final Carry
			moveq	#1,d0
			movem.l	FloatReg1,d1-d3
			jsr	FloatRightShift		; Shift by one to add the carry
			addi.l	#$10000000,d2		; Add carry 1
			movem.l	d1-d3,FloatReg1
			bra	FloatCheck
.ret	rts					; FloatCheck is not needed since we don't change the expo !
.SubMantissa
		lea	FloatReg1+FLOAT.sizeof,a0
		lea	FloatReg2+FLOAT.sizeof,a1
		move	#4,CCR
		sbcd	-(a1),-(a0)
		sbcd	-(a1),-(a0)
		sbcd	-(a1),-(a0)
		sbcd	-(a1),-(a0)
		sbcd	-(a1),-(a0)
		sbcd	-(a1),-(a0)
		sbcd	-(a1),-(a0)
		sbcd	-(a1),-(a0)
		bra	FloatAdjust
	

; In:
;	a4 -> Poly coeff list (.w / .bcd, .bcd ...)
;	FReg3 = x
; Out:
;	FReg1 = Result
; Faster than if you use FloatAdd / FloatMult ;)
; Precalcul x and uses Horner algorithm (((c3)*x + c2)*x + c1)*x + c0
; Destroy:
;	FReg1, FReg2 & FReg4
;	d0-d7/a0-a4
FloatPolyEval:
	pea	(a5)
	jsr	MultiplyPrecalcul		; Precalcul of x (Since x does not change, you don't need to precalcul again & again)
	move.w	(a4)+,a5			; Read number of coeff
	movem.l	(a4)+,d1-d3			; Load first coeff
	movem.l	d1-d3,FloatReg1			; Set initial Sum
	subq.w	#1,a5				; Coeff - 1
	move.w	a5,d0				; Check if last ?
	beq.s	.ret				; Yes so quit
.loop		movem.l	FloatReg1,d1-d3		; FReg1 / Sum
		movem.l	d1-d3,FloatReg4		; Current Value in FReg4 = Sum (so that it will be * FReg3=x)
		bsr.s	FloatMult_2nd		; FReg1 = FReg4 * FReg3 = Sum * x
		movem.l	(a4)+,d1-d3		; Read new coeff
		movem.l	d1-d3,FloatReg2		; Save it in FReg2
		jsr	FloatAdd		; FReg1 = FReg1 + FReg2 = Sum*x + Coeff
		subq.w	#1,a5			; Next coeff
		move.w	a5,d0			;
		bne.s	.loop			;
.ret	move.l	(a7)+,a5
	rts
	

; FReg1 = FReg3 x FReg4
; Destroy:
;	FReg1 / FReg2 (Freg3 & Freg4 are not destroyed)
;	d0-d7/a0-a3
; NOTE: Not very efficient... (14% slower than AMS but more precise ! Can be speed up by avoiding mult by the 2 last signifient digits).
FloatMult:
	bsr	MultiplyPrecalcul		; Precalcul FReg3
FloatMult_2nd:					; In: FPrecalculTab, FReg4 & Sign FReg3
	movem.l	FloatZero(pc),d1-d3
	movem.l	d1-d3,(FloatReg1)
	moveq	#7,d7				; 8 bytes
	swap	d7
	move.w	(FloatReg4+FLOAT.exponent),d7
	sub.w	#$4000+15,d7				; Current exponent
	lea	(FloatReg4+FLOAT.sizeof),a2
	lea	(FloatPreCalculMultTab),a3
.loop		moveq	#$F,d0
		and.b	-(a2),d0
		beq.s	.Next1
			mulu.w	#12,d0
			lea	0(a3,d0.w),a0
			movem.l	(a0),d1-d3
			add.w	d7,d1
			movem.l	d1-d3,(FloatReg2)
			jsr	FloatAdd
.Next1		addq.w	#1,d7
		clr.w	d0
		move.b	(a2),d0
		lsr.w	#4,d0
		beq.s	.Next2
			mulu.w	#12,d0
			lea	0(a3,d0.w),a0
			movem.l	(a0),d1-d3
			add.w	d7,d1
			movem.l	d1-d3,(FloatReg2)
			jsr	FloatAdd
.Next2		addq.w	#1,d7
		sub.l	#65536,d7
		bge.s	.loop
	; Sign ?
	move.w	(FloatReg3+FLOAT.sign),d0
	cmp.w	(FloatReg4+FLOAT.sign),d0
	sne	d0
	ext.w	d0
	move.w	d0,(FloatReg1+FLOAT.sign)
	bra	FloatAdjust
	
; In:
;	FReg3
; Out:
;	FloatPreCalculMultTab contains x0 / x9
MultiplyPrecalcul:
	lea	(FloatPreCalculMultTab),a2
	movem.l	FloatZero(pc),d1-d3
	movem.l	(FloatReg3),d4-d6
	movem.l	d1-d6,(a2)		; Save x0 & x1
	movem.l	d4-d6,(FloatReg1)		
	jsr	FloatMult2		; => x2
	movem.l	(FloatReg1),d1-d3		
	movem.l	d1-d3,2*12(a2)		; Save x2
	jsr	FloatMult2		; => x4
	movem.l	(FloatReg1),d1-d3		
	movem.l	d1-d3,4*12(a2)		; Save x4
	jsr	FloatMult2		; => x8
	movem.l	(FloatReg1),d1-d3		
	movem.l	d1-d3,8*12(a2)		; Save x8
	movem.l	FloatReg3,d1-d3
	movem.l	d1-d3,FloatReg2
	jsr	FloatSub		; => x8 - x1 = x7
	movem.l	(FloatReg1),d1-d3		
	movem.l	d1-d3,7*12(a2)		; Save x7
	movem.l	2*12(a2),d4-d6		; Reload x2
	movem.l	FloatReg3,d1-d3		; Reload x1
	movem.l	d1-d6,(FloatReg1)		; Save Reg1(x1) & Reg2(x2)
	jsr	FloatAdd		; => x3
	movem.l	(FloatReg1),d1-d3
	movem.l	d1-d3,3*12(a2)		; Save x3
	jsr	FloatMult2		; => (x3) x2
	movem.l	(FloatReg1),d1-d3
	movem.l	d1-d3,6*12(a2)		; Save x6
	movem.l	4*12(a2),d4-d6		; Reload x4
	movem.l	FloatReg3,d1-d3		; Reload x1
	movem.l	d1-d6,(FloatReg1)		; Save Reg1 & Reg2
	jsr	FloatAdd		; => x5
	movem.l	(FloatReg1),d1-d3
	movem.l	d1-d3,5*12(a2)		; Save x5
	movem.l	8*12(a2),d4-d6		; Reload x8
	movem.l	FloatReg3,d1-d3		; Reload x1
	movem.l	d1-d6,(FloatReg1)		; Save Reg1 & Reg2
	jsr	FloatAdd		; => x9
	movem.l	(FloatReg1),d1-d3
	movem.l	d1-d3,9*12(a2)		; Save x9
	rts
	
;	FReg1 = FReg1 x 2
; More or less like FloatAdd but much more optimised
; Do not change FloatReg2
FloatMult2:
	lea	(FloatReg1+FLOAT.sizeof),a0
	move.l	a0,a1
	; Add the mantissa
	move	#0,CCR
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	abcd	-(a1),-(a0)
	bcc.s	.ret
		; Final Carry
		moveq	#1,d0
		movem.l	(FloatReg1),d1-d3
		jsr	FloatRightShift		; Shift by one to add the carry
		addi.l	#$10000000,d2		; Add carry 1
		movem.l	d1-d3,(FloatReg1)
.ret	rts					; FloatCheck is not needed since we will call it later

; In:
;	FReg3, Freg4
; Out:
;	FReg4 = FReg4 / FReg3
; Destroy:
;	FReg1, FReg2 & FReg3
;	d0-d7/a0-a3
; NOTE: Not very efficient... (19% slower than AMS).
FloatDivide:
	; Save expo : FReg4.expo - FReg3.expo dans reg4
	move.w	(FloatReg3+FLOAT.exponent),d1
	cmpi.w	#$2000,d1
	beq	.DivideByZero
	sub.w	#$4000,d1
	sub.w	d1,(FloatReg4+FLOAT.exponent)
	; Save Sign in FReg4
	move.w	(FloatReg3+FLOAT.sign),d1
	eor.w	d1,(FloatReg4+FLOAT.sign)
	; Clear both expo & sign of FReg3
	move.l	#$00004000,(FloatReg3+FLOAT.sign)
	; Precalcul...
	jsr	MultiplyPrecalcul
	; Copy FReg4 -> FReg1
	movem.l	(FloatReg4),d1-d3
	; Clear both expo & sign of FReg1
	move.l	#$00004000,d1
	movem.l	d1-d3,(FloatReg1)
	; Load Tables 
	moveq	#7,d7
	swap	d7					; Index
	lea	(FloatPreCalculMultTab),a2
	lea	(FloatReg4+FLOAT.mantissa),a3
	clr.l	(a3)
	clr.l	4(a3)
.loop		jsr	FloatDivideFindIndice		; Check Number (0-9)
		move.b	d0,d7				; Save it in d7.b
		beq.s	.Next1
			lsl.w	#4,d7			; x16
			mulu.w	#12,d0			; a0 may not be the indexx12
			lea	0(a2,d0.w),a0		; a0 -> Number
			movem.l	(a0),d1-d3		; Read number xN
			movem.l	d1-d3,(FloatReg2)	; and copy it in FReg2
			jsr	FloatSub		; FReg1 -= FReg2
.Next1		move.w	(FloatReg1+FLOAT.exponent),d0	; Check if FReg1 == 0
		cmpi.w	#$2000,d0			;
		bls	.End				; == 0 ? ==> Quit
		addq.w	#1,d0				; FReg1 x10
		move.w	d0,(FloatReg1+FLOAT.exponent)	;
		jsr	FloatDivideFindIndice		; Check Another indice	
		or.b	d0,d7
		mulu.w	#12,d0				; a0 may not be the indexx12
		beq.s	.Next2
			lea	0(a2,d0.w),a0
			movem.l	(a0),d1-d3
			movem.l	d1-d3,(FloatReg2)
			jsr	FloatSub
.Next2		move.w	(FloatReg1+FLOAT.exponent),d0
		cmpi.w	#$2000,d0
		bls.s	.End
		addq.w	#1,d0
		move.w	d0,(FloatReg1+FLOAT.exponent)
		move.b	d7,(a3)+			; Save the 2 digits in the mantissa
		sub.l	#65536,d7
		bge.s	.loop		
		bra.s	.continue
.DivideByZero
	cmpi.w	#$2000,(FloatReg4+FLOAT.exponent)
	beq.s	.Nan
		move.w	#$6000,(FloatReg1+FLOAT.exponent)
		move.l	#$99999999,(FloatReg1+FLOAT.mantissa)
		move.l	#$99999999,(FloatReg1+FLOAT.mantissa+4)
		rts
.Nan		move.w	#$7FFF,(FloatReg1+FLOAT.exponent)
		clr.l	(FloatReg1+FLOAT.mantissa)
		clr.l	(FloatReg1+FLOAT.mantissa+4)
		rts
.End:	move.b	d7,(a3)
.continue
	movem.l	(FloatReg4),d1-d3
	movem.l	d1-d3,(FloatReg1)
	bra	FloatAdjust				; Adjust float (First digit may be 0 !)

FloatDivideFindIndice:
; 	Recherche de q tels que Tab[q] <= FReg1 < Tab[q+1]
	lea	12*5(a2),a0
	jsr	FloatUCmp
	tst.w	d0
	beq.s	.Found5
	bgt.s	.Cmp7
		lea	12*2(a2),a0
		jsr	FloatUCmp
		tst.w	d0
		beq.s	.Found2
		bgt.s	.Cmp4
			lea	12*1(a2),a0
			jsr	FloatUCmp
			tst.w	d0
			bge.s	.Found1
			bra.s	.Found0
.Cmp4			lea	12*4(a2),a0
			jsr	FloatUCmp
			tst.w	d0
			bge.s	.Found4
			lea	12*3(a2),a0
			jsr	FloatUCmp
			tst.w	d0
			bge.s	.Found3
			bra.s	.Found2	
.Found0		moveq	#0,d0
		rts
.Found1		moveq	#1,d0
		rts
.Found2		moveq	#2,d0
		rts
.Found3		moveq	#3,d0
		rts
.Found4		moveq	#4,d0
		rts
.Found5		moveq	#5,d0
		rts
.Cmp7		lea	12*7(a2),a0
		jsr	FloatUCmp
		tst.w	d0
		beq.s	.Found7
		bgt.s	.Cmp9
			lea	12*6(a2),a0
			jsr	FloatUCmp
			tst.w	d0
			blt.s	.Found5
			bra.s	.Found6
.Cmp9		lea	12*9(a2),a0
		jsr	FloatUCmp
		tst.w	d0
		bge.s	.Found9
		lea	12*8(a2),a0
		jsr	FloatUCmp
		tst.w	d0
		bge.s	.Found8
.Found7		moveq	#7,d0
		rts
.Found6		moveq	#6,d0
		rts
.Found8		moveq	#8,d0
		rts
.Found9		moveq	#9,d0
		rts


FloatNegInfinity	dc.l	$FFFF6000,$99999999,$99999999
FloatPosInfinity	dc.l	$00006000,$99999999,$99999999
FloatZero		dc.l	$00002000,0,0
FloatOne		dc.l	$00004000,$10000000,0
FloatTen		dc.l	$00004001,$10000000,0
FloatMinusOne		dc.l	$FFFF4000,$10000000,0
FloatNAN		dc.l	$00007FFF,$AA000000,0
FloatLn10:		dc.l	$00004000,$23025850,$92994046
FloatInvLn10:		dc.l	$00003FFF,$43429448,$19032518
FloatHalf		dc.l	$00003FFF,$50000000,$00000000
FloatMinusHalf		dc.l	$FFFF3FFF,$50000000,$00000000
FloatSqrtHalf		dc.l	$00003FFF,$70710678,$11865475
FloatLn10Div2:		dc.l	$00004000,$11512925,$46497023
FloatPi			dc.l	$00004000,$31415926,$53589793
FloatPiDiv2		dc.l	$00004000,$15707963,$26794897
FloatE			dc.l	$00004000,$27182818,$28459045
FloatSqrt10		dc.l	$00004000,$31622776,$60168379
FloatInv32		dc.l	$00003FFE,$31250000,$00000000
FloatInv64		dc.l	$00003FFE,$15625000,$00000000
FloatInv3		dc.l	$00003FFF,$14476482,$73010839	; 1/(3*ln(10))
Float2DivPi		dc.l	$00003FFF,$63661977,$23675814
FloatMinusPi:		dc.l	$FFFF4000,$31415926,$53589793
Float2Pi:		dc.l	$00004000,$62831853,$07179586

; 10^x in the range [0...1] by Series 
Float10ExpPolyEval	dc.w	27		
			dc.l	$4000-018,$64861782,$47150469
			dc.l	$4000-017,$73239696,$95583724
			dc.l	$4000-016,$79518990,$61046626
			dc.l	$4000-015,$82883181,$18874074
			dc.l	$4000-014,$82790128,$93557226
			dc.l	$4000-013,$79101651,$53611110
			dc.l	$4000-012,$72142162,$62029055
			dc.l	$4000-011,$62661886,$27711842
			dc.l	$4000-010,$51706051,$72802308
			dc.l	$4000-009,$40420175,$30367213
			dc.l	$4000-008,$29842240,$45630973
			dc.l	$4000-007,$20736512,$57248847
			dc.l	$4000-006,$13508629,$47622372
			dc.l	$4000-006,$82134125,$35439407
			dc.l	$4000-005,$46371516,$64257231
			dc.l	$4000-004,$24166672,$55442475 
			dc.l	$4000-003,$11544997,$78998437
			dc.l	$00003FFD,$50139288,$33775446
			dc.l	$00003FFE,$19597694,$62647854
			dc.l	$00003FFE,$68089365,$07443712
			dc.l	$00003FFF,$20699584,$86968683
			dc.l	$00003FFF,$53938292,$91955817
			dc.l	$00004000,$11712551,$48912268
			dc.l	$00004000,$20346785,$92293477
			dc.l	$00004000,$26509490,$55239200
			dc.l	$00004000,$23025850,$92994046
			dc.l	$00004000,$10000000,$00000000

; In: FReg1 / Out: FReg1
FloatExp:
	movem.l	FloatReg1,d1-d3
	movem.l	FloatInvLn10(pc),d4-d6
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult		; x * (1/ln(10))
	
; Calcul of 10^FReg1=10^(Int + Frac)
; where -1<frac<1.
Float10Pow:
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,FloatReg2
	jsr	FloatCeil			; FReg1 = Int(x)
	jsr	Float2Int			; d0.l = (FReg1)
	move.w	d0,-(a7)			; d0.w = Int(x)
	jsr	FloatSub			; z = int(x)-x
	not.w	FloatReg1+FLOAT.sign
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,FloatReg3			
	lea	Float10ExpPolyEval(pc),a4	; PolyEval(z, 10POwPoly)
	jsr	FloatPolyEval			; FReg3 (0<x<1)
	move.w	(a7)+,d0
	add.w	d0,FloatReg1+FLOAT.exponent
	bra	FloatCheck
	
; In: FloatReg1
; Out: FloatReg1
FloatLn:
	bsr.s	FloatLog10
	movem.l	FloatReg1,d1-d3
	movem.l	FloatLn10(pc),d4-d6
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult
	bra	FloatCheck
	
FloatLog10Infinity:
	movem.l	FloatNegInfinity(pc),d1-d3
FloatLog10Copy:
	movem.l	d1-d3,FloatReg1
	rts
FloatLog10Nan
	movem.l	FloatNAN(pc),d1-d3
	bra.s	FloatLog10Copy
; Calcul of log(FReg1)=log(Mantisse*10^N)= log(Mantisse) + N
; NOTE: Very slow but at least it works.
FloatLog10:	
	pea	(a5)
	; Check for Zero
	cmpi.w	#$2000,FloatReg1+FLOAT.exponent
	beq.s	FloatLog10Infinity
	tst.w	FloatReg1+FLOAT.sign
	bne.s	FloatLog10Nan
	; Input is m*10^b (1 <= a < 10). Thus our result is log(a) + b
	; Calculation of log(a) is done in the following way:
	;        log(a) = integrate(differentiate(log(a))) = integrate(10/x)
	;    <=> log(a) = integrate(1/(ln(10)x) from 1 to a)
	;    The integral is calculated using the Simpson approximation algorithm.
	;    Integration boundaries are 1 to 10. 
	;    F(0) to F(32) are our function values 1/1 up to 1/a
	;    m is the number of integration segments
	;    h is the width of one integration segment (a-1)/m
	;    So the result is: 
	;    log(a) = log(1) + h/3 * (F(0) + F(64)
	;                              + 2*sum(F(2i), i from 1 to m/2-1) 
	;                              + 4*sum(F(2i-1), i from 1 to m/2))
	;          = F(0)*h/3 + F(1)*h*4/3 + F(2)*h*2/3 + F3*h*4/3 + F(4)*h*2/3 + ... + F(32)*h/3
	; Save b and set exponent 0 in FReg1
	move.w	FloatReg1+FLOAT.exponent,-(a7)
	move.w	#$4000,FloatReg1+FLOAT.exponent
	; Alloc Stack Frame
	lea	-12*6(a7),a7
sum	equ	00
x	equ	12
h	equ	24
h3	equ	36
h3_2	equ	48
h3_4	equ	60
	; calculate h
	movem.l	FloatMinusOne(pc),d1-d3
	movem.l	d1-d3,FloatReg2
	jsr	FloatAdd		; (a-1)
	movem.l	FloatReg1,d1-d3
	movem.l	FloatInv64(pc),d4-d6
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult		; h = (a-1) /(64)
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,h(a7)
	; Calculate h/3
	movem.l	FloatInv3(pc),d4-d6	; (1/3ln(10))
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult		; (h/3ln(10))
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,h3(a7)
	; Calculate h/3 *2
	jsr	FloatMult2
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,h3_2(a7)
	; Calculate h/3 *4
	jsr	FloatMult2
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,h3_4(a7)
	; Set vars
	movem.l	FloatZero(pc),d1-d3	; sum = 0
	movem.l	FloatOne(pc),d4-d6	; x = 1
	movem.l	d1-d6,sum(a7)
	movea.w	#65,a5
.Loop		
		; get the divisor h*a/3 where a is 1, 2 or 4 
		lea	h3(a7),a0
		; the first and last summands are F(x) = F(x) * h/3
		move.w	a5,d0
		subq.w	#1,d0
		beq.s	.DivisorGot
		cmpi.w	#64,d0
		beq.s	.DivisorGot
			; For even x: F(x) = F(x)*2 *h/3 
			lea	h3_2(a7),a0
			btst.l	#0,d0
			beq.s	.DivisorGot
				; For odd x: F(x) = F(x)*4*h/3
				lea	h3_4(a7),a0
.DivisorGot:	; calculate F(x) * h*a/3 ie h*a/(3*ln(10)) / x
		movem.l	(a0),d4-d6
		movem.l	x(a7),d1-d3
		movem.l	d1-d6,FloatReg3
		jsr	FloatDivide
		; Increase our sum
		movem.l	sum(a7),d1-d3
		movem.l	d1-d3,FloatReg2
		jsr	FloatAdd
		movem.l	FloatReg1,d1-d3
		movem.l	d1-d3,sum(a7)
		; Increase our x by h
		movem.l	x(a7),d1-d6		; x & h
		movem.l	d1-d6,FloatReg1
		jsr	FloatAdd
		movem.l	FloatReg1,d1-d3
		movem.l	d1-d3,x(a7)
		; Next Item
		subq.w	#1,a5
		move.w	a5,d0
		bne.s	.Loop
	movem.l	sum(a7),d1-d3
	movem.l	d1-d3,FloatReg2
	lea	12*6(a7),a7
	; Add log(1)= 0 (Skip)
	; Add M 	
	move.w	(a7)+,d0
	sub.w	#$4000,d0
	ext.l	d0
	jsr	Int2Float
	jsr	FloatAdd
	move.l	(a7)+,a5
	bra	FloatCheck
	
; Calcul of FloatPow: FReg
; x^y = 10^(y*log10(x))
; x = Freg1 / y = FReg2
FloatPow:
	movem.l	FloatReg2,d1-d3
	movem.l	d1-d3,-(a7)			; Push FReg2
	jsr	FloatLog10			; log10(FReg1)
	movem.l	FloatReg1,d1-d3			; Get log10(x)
	movem.l	(a7)+,d4-d6			; pOp y
	movem.l	d1-d6,FloatReg3			; Save for mult
	jsr	FloatMult			; FReg1 = log10(x) * y
	bra	Float10Pow			; 10^(log10(x) * y)

; Reduce a float to an interval. [0...y]
; In:
;	a5 -> Internal_bcd x
;	a4 -> 3 const internal_bcd:
;		R = 1/y / M1 = ~y / M2 = (y - M1)
; Out:
;	d0.l = N / FloatReg1 = mod
;	
FloatRangeReducByMod:
	movem.l	(a5),d1-d3		; FReg3 = x
	movem.l	(a4)+,d4-d6		; FReg4 = R
	movem.l	d1-d6,FloatReg3		; Save FReg3 & Freg4
	jsr	FloatMult		; FReg1 = FReg3 x FReg4
	jsr	Float2Int		; d0.l = int(x * R);
	tst.l	d0			
	bne.s	.NoZero			; if n == 0, return
		movem.l	(a5),d1-d3
		movem.l	d1-d3,FloatReg1
		rts
.NoZero
	move.l	d0,-(a7)
	jsr	FloatCeil		; x_n = FReg1 = FloatCeil(FReg1) -More precise than Int2Float(n)-
	movem.l	FloatReg1,d1-d3
	movem.l	(a4)+,d4-d6
	movem.l	d1-d6,FloatReg3		; FReg3 = x_n / FReg4 = M1
	jsr	FloatMult		; tmp2 = x_n * M1
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,-(a7)		; Push tmp2
	movem.l	(a4)+,d1-d3
	movem.l	d1-d3,FloatReg4		; FReg3 = x_n / Freg4 = M2
	jsr	FloatMult		; tmp1 = x_n * M1
	not.w	FloatReg1+FLOAT.sign	; - tmp1
	movem.l	(a5),d1-d3
	movem.l	d1-d3,FloatReg2
	jsr	FloatAdd		; FReg1 = x-tmp1
	movem.l	(a7)+,d1-d3
	movem.l	d1-d3,FloatReg2
	jsr	FloatSub		; result = x - tmp2 - tmp1
	move.l	(a7)+,d0
	rts

; Compute sqrt(x)
; In:
;	FloatReg1 >=0
FloatSqrt:
	pea	(a5)
	movem.l	FloatReg1,d1-d3
	movem.l	FloatTen(pc),d4-d6
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult
	tst.w	FloatReg1+FLOAT.sign
	bne	.Return
	move.w	FloatReg1+FLOAT.exponent,-(a7)		; Push org exponent
	move.w	#$3FFF,FloatReg1+FLOAT.exponent		; Exponent -1
	; Calcul Sqrt(mantissa) using this :
	;	P(0) = 0
	;	P(1) = x * 1/2
	;	P(n+1) = (x + 2*P(n) - P(n)*P(n)) /2
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,-(a7)		; Push x
	movem.l	FloatZero(pc),d1-d3
	movem.l	d1-d3,FloatReg1		; Freg1 = P(0) = 0
	move.w	#$10,a5
.Loop		movem.l	FloatReg1,d1-d3
		movem.l	d1-d3,FloatReg3
		movem.l	d1-d3,FloatReg4
		jsr	FloatMult	; FReg1 = P^2
		not.w	FloatReg1+FLOAT.sign	; - P^2
		movem.l	(a7),d1-d3	;x
		movem.l	d1-d3,FloatReg2	
		jsr	FloatAdd	; FReg1 = -P^2 + x
		movem.l	FloatReg1,d1-d3
		movem.l	d1-d3,FloatReg2	; FReg2 = x-P^2
		movem.l	FloatReg3,d1-d3
		movem.l	d1-d3,FloatReg1	; FReg1 = P
		jsr	FloatMult2	; FReg1 = 2 * P
		jsr	FloatAdd	; FReg1 = 2*P + x-P^2
		movem.l	FloatReg1,d1-d3
		movem.l	FloatHalf(pc),d4-d6
		movem.l	d1-d6,FloatReg3	; FReg3 = x+2*P-P^2 / FReg4 = 0.5
		jsr	FloatMult	; FReg1 = (x+2*P-P^2) * 0.5
		subq.w	#1,a5
		move.w	a5,d0
		bne	.Loop
	; Calcul de sqrt(10^exponent)	
	lea	12(a7),a7		; Pop x
	move.w	(a7)+,d0
	sub.w	#$4000,d0
	asr.w	#1,d0
	bcc.s	.Even
		add.w	d0,FloatReg1+FLOAT.exponent ; FReg1 = FReg1 * 10^(N/2)
		movem.l	FloatReg1,d1-d3
		movem.l	FloatSqrt10(pc),d4-d6
		movem.l	d1-d6,FloatReg3		; FReg1 = sqrt(mantissa)*10^(N/2) * sqrt(10) = sqrt(x)
		jsr	FloatMult
		bra.s	.Return	
.Even	add.w	d0,FloatReg1+FLOAT.exponent ; FReg1 = FReg1 * 10^(N/2)
.Return	move.l	(a7)+,a5
	rts
	
FloatSinTable:
	dc.w	20
	dc.l	$4000-018,$82206352,$46624330
	dc.l	$00002000,$00000000,$00000000
	dc.l	$4000-015,$28114572,$54345521
	dc.l	$00002000,$00000000,$00000000
	dc.l	$4000-013,$76471637,$31819816
	dc.l	$00002000,$00000000,$00000000
	dc.l	$4000-010,$16059043,$83682161
	dc.l	$00002000,$00000000,$00000000
	dc.l	$4000-008,$25052108,$38544172
	dc.l	$00002000,$00000000,$00000000
	dc.l	$4000-006,$27557319,$22398589
	dc.l	$00002000,$00000000,$00000000
	dc.l	$4000-004,$19841269,$84126984
	dc.l	$00002000,$00000000,$00000000
	dc.l	$4000-003,$83333333,$33333333
	dc.l	$00002000,$00000000,$00000000
	dc.l	$4000-001,$16666666,$66666667
	dc.l	$00002000,$00000000,$00000000
	dc.l	$4000-000,$10000000,$00000000
	dc.l	$00002000,$00000000,$00000000

; cos(x) = sin(x+Pi/2)
FloatCos:
	movem.l	FloatPiDiv2(pc),d1-d3
	movem.l	d1-d3,FloatReg2
	jsr	FloatAdd
	
FloatSin:
	move.w	FloatReg1+FLOAT.sign,-(a7)
	clr.w	FloatReg1+FLOAT.sign
	; x may be in:
	; 0 < x < Pi/2		=>					PolyEval(x)
	; Pi/2 < x < Pi		=>			x = Pi-x	PolyEval(x)
	; Pi < x < 3Pi/2	=>	Exg sign	x = x - Pi	PolyEval(x)
	; 3Pi/2 < x < 2Pi	=>	Exg sign	x = 2Pi-x	PolyEval(x)
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,-(a7)
	movem.l	Float2DivPi(pc),d4-d6
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult		; x / (Pi/2)
	jsr	FloatCeil		; Int(x/(Pi/2))
	jsr	Float2Int
	move.w	d0,a5
	movem.l	FloatReg1,d1-d3
	movem.l	FloatPiDiv2(pc),d4-d6
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult		; Int(x/(Pi/2)) * (Pi/2)
	not.w	FloatReg1+FLOAT.sign	; FReg1 = - Int(x/(Pi/2))*(Pi/2)
	movem.l	(a7)+,d1-d3		
	movem.l	d1-d3,FloatReg2		; FReg2 = x
	jsr	FloatAdd		; FReg1 = x - Int(x/(Pi/2))*(Pi/2)
	move.w	a5,d0
	andi.w	#3,d0
	beq.s	.PolyEval
		subq.w	#2,d0
		blt.s	.Pi2XPi
		beq.s	.PiX3Pi2
		; 3Pi/2 < x < 2Pi
		not.w	FloatReg1+FLOAT.sign
		movem.l	Float2Pi(pc),d1-d3
		bra.s	.PiX
.Pi2XPi:	; Pi < x < 3Pi/2
		movem.l	FloatMinusPi(pc),d1-d3
.PiX		not.w	(a7)
		bra.s	.PiY
.PiX3Pi2:	; Pi/2 < x < Pi
		not.w	FloatReg1+FLOAT.sign
		movem.l	FloatPi(pc),d1-d3
.PiY		movem.l	d1-d3,FloatReg2
		jsr	FloatAdd
.PolyEval
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,FloatReg3			
	lea	FloatSinTable(pc),a4		; PolyEval(z, 10POwPoly)
	jsr	FloatPolyEval			; FReg3 (0<x<1)
	move.w	(a7)+,d0
	eor.w	d0,FloatReg1+FLOAT.sign
	rts
	
	
; ***************************************************************
; 			AMS functions
; ***************************************************************
;float pow (float x, float y);
pow:
	lea	FloatPow(pc),a0
	bra.s	bcd_entry
;bcd bcddiv (bcd x, bcd y);
bcddiv
	lea	FloatDivide(pc),a0
	bra.s	bcd_entry
;bcd bcdmul (bcd x, bcd y);
bcdmul:
	lea	FloatMult(pc),a0
	bra.s	bcd_entry
;bcd bcdsub (bcd x, bcd y);
bcdsub:
	lea	FloatSub(pc),a0
	bra.s	bcd_entry
;bcd bcdadd (bcd x, bcd y);
bcdadd:
	lea	FloatAdd(pc),a0
bcd_entry:
	movem.l	d3-d7/a2-a5,-(a7)
	move.l	a0,a3
	lea	10*4(a7),a0
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	movem.l	FloatReg1,d4-d6
	lea	10*4+10(a7),a0
	lea	FloatReg2,a1
	jsr	FloatAMS2Internal
	movem.l	FloatReg2,d1-d3
	movem.l	d1-d6,FloatReg3
	jsr	(a3)
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a5
	rts

;long bcdcmp (bcd x, bcd y); 
bcdcmp:
	movem.l	d3-d7/a2-a5,-(a7)
	lea	10*4(a7),a0
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	lea	10*4+10(a7),a0
	lea	FloatReg2,a1
	jsr	FloatAMS2Internal
	jsr	FloatCmp
	ext.l	d0
	movem.l	(a7)+,d3-d7/a2-a5
	rts

; bcd bcdbcd (long x);
bcdbcd:
	move.l	4(a7),d0
	move.l	d3,-(a7)
	jsr	Int2Float
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS		; Does not destroy d0 !
	move.l	(a7)+,d3
	rts
	
;long bcdlong (bcd x); 
bcdlong:
	movem.l	d3-d7/a2-a5,-(a7)
	lea	10*4(a7),a0
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal	
	jsr	Float2Int
	movem.l	(a7)+,d3-d7/a2-a5
	rts

;bcd bcdneg (bcd x);
bcdneg:
	move.w	4(a7),d0			; Read field 1
	eori.w	#$8000,d0			; Change the sign
	move.w	d0,-10(a6)			; Write it
	move.l	6(a7),-8(a6)			; Copy field 2
	move.l	10(a7),-4(a6)			; Copy field 3
;void init_float (void); 
init_float
	rts

;short is_float_signed_infinity (float x);
is_float_signed_infinity
;short is_float_infinity (float x); 
is_float_infinity:
	move.w	4+BCD.exponent(a7),d0
	andi.w	#$7FFF,d0
	cmpi.w	#$6000-1,d0
	seq	d0
	ext.w	d0
	rts

;short is_float_unsigned_zero (float x); 
is_float_unsigned_zero
;short is_float_positive_zero (float x);
is_float_positive_zero:				; Due to the fact the functions don't try t
;short is_float_negative_zero (float x); 
is_float_negative_zero:
	move.w	4+BCD.exponent(a7),d0
	andi.w	#$7FFF,d0
	cmpi.w	#$2000,d0
	seq	d0
	ext.w	d0
	rts

;short is_float_unsigned_inf_or_nan (float x); 
is_float_unsigned_inf_or_nan:
	moveq	#1,d0
	move.w	4+BCD.exponent(a7),d1
	cmpi.w	#$7FFF,d1
	beq.s	.Found
	cmpi.w	#$6000|$F000,d1
	beq.s	.Found
		moveq	#0,d0
.Found	rts

;short is_float_transfinite (float x); 
is_float_transfinite:
	move.w	4+BCD.exponent(a7),d0
	andi.w	#$7FFF,d0
	cmpi.w	#$6000-1,d0
	shi	d0
	ext.w	d0
	rts

;short is_nan (float x);
is_nan:	
	move.w	4+BCD.exponent(a7),d0
	cmpi.w	#$7FFF,d0
	seq	d0
	ext.w	d0
	rts

;short fpisanint (unsigned long long *mantissa, unsigned short exponent);
fpisanint:
	moveq	#0,d1
	move.l	4(a7),a0
	move.w	8(a7),d1
	andi.w	#$7FFF,d1
	subi.w	#$4000,d1
	bcs.s	.End
		cmpi.w	#$10,d1
		bcc.s	.End2
		lea	7(a0),a1
		btst	#0,d1
		beq.s	.Cont
			addq.l	#1,d1
			bpl.s	.Ok
				addq.l	#1,d1
.Ok			asr.l	#1,d1
			adda.l	d1,a0
			bra.s	.Next2
.Cont		lsr.w	#1,d1
		ext.l	d1
		adda.l	d1,a0
		moveq	#$F,d0
		and.b	(a0),d0
		beq.s	.Next
.End			moveq	#0,d0
			rts
.Next		addq.l	#1,a0
.Next2		bra.s	.EndLoop
.Loop			tst.b	(a0)+
			bne.s	.End
.EndLoop		cmpa.l	a1,a0
			bls.s	.Loop
.End2	moveq	#1,d0
	rts

;short fpisodd (const unsigned long long *mantissa, unsigned short exponent);
fpisodd
	moveq	#1,d0
	move.w	8(a7),d1
	andi.w	#$7FFF,d1
	subi.w	#$4000,d1
	bcs.s	.End
		moveq	#0,d0
		cmpi.w	#$10,d1
		bcc.s	.End
			moveq	#$10,d0
			btst	#0,d1
			beq.s	.Ok
				moveq	#1,d0
.Ok			lsr.w	#1,d1
			move.l	4(a7),a0
			move.b	0(a0,d1.w),d2
			and.b	d2,d0
.End	rts

;float round12 (float x);
round12:
	move.w	4(a7),-10(a6)
	move.l	6(a7),-8(a6)
	move.l	10(a7),d0
	clr.w	d0
	move.l	d0,-4(a6)
	rts

;float round14 (float x);
round14:
	move.w	4(a7),-10(a6)
	move.l	6(a7),-8(a6)
	move.l	10(a7),d0
	clr.b	d0
	move.l	d0,-4(a6)
	rts

;float round12_err (float x, short error_code);
round12_err:
	move.w	4(a7),d0
	move.w	d0,d1
	andi.w	#$7FFF,d1
	cmpi.w	#$4000+999,d1
	bls.s	.Ok
		move.w	4+12(a7),d0
;		jmp	ER_throwVar_reg
.Ok	cmpi.w	#$4000-1000,d1
	bhi.s	.Ok2
		move.w	#$2000,-10(a6)
		clr.l	-8(a6)
		clr.l	-4(a6)
		rts
.Ok2	move.w	d0,-10(a6)
	move.l	6(a7),-8(a6)
	move.l	10(a7),d0
	clr.w	d0
	move.l	d0,-4(a6)
	rts

;short float_class (float x);
float_class:
	move.w	4(a7),d0		; Exponent
	ext.l	d0
	andi.w	#$7FFF,d0
	cmpi.w	#$7FFF,d0
	bne.s	.NoNan
		moveq	#1,d0
		rts
.NoNan:	cmpi.w	#$2000,d0
	bne.s	.NoZero
		moveq	#6,d0
		rts
.NoZero	cmpi.w	#$6000,d0
	bne.s	.NoInfinity
		tst.l	d0
		bmi.s	.inf
		moveq	#10,d0
		rts
.inf		moveq	#2,d0
		rts		
.NoInfinity
	tst.l	d0
	bmi.s	.inf2
	moveq	#9,d0
	rts	
.inf2	moveq	#3,d0
	rts
	
;float fabs (float x);
fabs:
	move.w	4(a7),d0
	andi.w	#$7FFF,d0
	move.w	d0,-10(a6)
	move.l	6(a7),-8(a6)
	move.l	10(a7),-4(a6)
	rts

;float floor (float x); 
floor:
	lea	4(a7),a0
	bsr.s	ceil_entry
	movem.l	d3-d7/a2-a6,-(a7)
	tst.w	FloatReg1+FLOAT.sign
	beq.s	.Ok
		movem.l	FloatMinusOne(pc),d0-d2
		movem.l	d0-d2,FloatReg2
		jsr	FloatAdd		; + -1
		lea	FloatReg1,a0
		lea	-10(a6),a1
		jsr	FloatInternal2AMS
.Ok:	movem.l	(a7)+,d3-d7/a2-a6
	rts
	
;float ceil (float x);
ceil:
	lea	4(a7),a0
ceil_entry:
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	jsr	FloatCeil
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float fmod (float x, float y);	
fmod:
	movem.l	d3-d7/a2-a5,-(a7)
	lea	10*4(a7),a0
	lea	FloatReg4,a1			; FReg4 = x
	jsr	FloatAMS2Internal
	lea	10*4+10(a7),a0
	lea	FloatReg3,a1			
	jsr	FloatAMS2Internal		; FReg3 = y
	jsr	FloatDivide			; x / y
	jsr	FloatCeil			; Calculate Ceil(x/y)
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,FloatReg4			; FReg4 = FReg1
	jsr	FloatMult			; FReg1 = FReg3 * Ceil(FReg4/FReg3)
	lea	10*4(a7),a0
	lea	FloatReg2,a1
	jsr	FloatAMS2Internal
	jsr	FloatSub			; FReg1 = y*Ceil(x/y) - x
	not.w	FloatReg1+FLOAT.sign
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a5
	rts

;float log10 (float x);
log10:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	jsr	FloatLog10
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float log (float x);
; ln(x) = log10(x)*log(10)
log:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	jsr	FloatLn
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float exp (float x);
; 10^x = exp(x*ln(10)), so exp(x) = 10^(x/ln(10))
exp:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg4,a1
	jsr	FloatAMS2Internal
	jsr	FloatExp
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float sqrt (float x);
sqrt:	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	jsr	FloatSqrt
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float sin (float x); 
sin:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	jsr	FloatSin
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float cos (float x); 
cos:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	jsr	FloatCos
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float tan (float x); 
tan:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
;	jsr	FloatTan
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float asin (float x); 
asin:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
;	jsr	FloatAsin
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float acos (float x); 
acos:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
;	jsr	FloatAcos
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float atan (float x); 
atan:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	;jsr	FloatAtan
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float atan2 (float x, float y);
atan2:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal
	;jsr	FloatDiv
	;jsr	FloatAtan
	lea	FloatZero(pc),a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float acosh (float x)
; log(bcdadd(x, sqrt(bcdadd(bcdmul(x,x),-1.0))));
acosh:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg3,a1			; FReg3 = x
	jsr	FloatAMS2Internal
	movem.l	FloatReg3,d1-d3		
	movem.l	d1-d3,FloatReg4			; FReg4 = Freg3 = x
	jsr	FloatMult			; FReg1 = x^2
	movem.l	FloatMinusOne(pc),d1-d3
	movem.l	d1-d3,FloatReg2			; FReg2 = -1
	jsr	bcdadd				; FReg1 = x^2-1
	movem.l	FloatHalf(pc),d1-d3
	movem.l	d1-d3,FloatReg2			; Freg2 = 1/2
	jsr	FloatPow			; FReg1 = (x^2-1) ^ (1/2)
	lea	40+4(a7),a0
	lea	FloatReg2,a1			; FReg2 = x
	jsr	FloatAMS2Internal
	jsr	FloatAdd			; FReg1 = x + (x^2-1)^(1/2)
	jsr	FloatLog10			; FReg1 = log10( x+(x^2-1)^(1/2) )
	movem.l	FloatReg1,d1-d3
	movem.l	FloatLn10(pc),d4-d6
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult			; Freg1 = ln(")
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS		; Result = FReg1
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float acinh (float x)
; log(bcdadd(x, sqrt(bcdadd(bcdmul(x,x),1.0))));
asinh:
	lea	4(a7),a0
	movem.l	d3-d7/a2-a6,-(a7)
	lea	FloatReg3,a1			; FReg3 = x
	jsr	FloatAMS2Internal
	movem.l	FloatReg3,d1-d3		
	movem.l	d1-d3,FloatReg4			; FReg4 = Freg3 = x
	jsr	FloatMult			; FReg1 = x^2
	movem.l	FloatOne(pc),d1-d3
	movem.l	d1-d3,FloatReg2			; FReg2 = 1
	jsr	bcdadd				; FReg1 = x^2+1
	movem.l	FloatHalf(pc),d1-d3
	movem.l	d1-d3,FloatReg2			; Freg2 = 1/2
	jsr	FloatPow			; FReg1 = (x^2+1) ^ (1/2)
	lea	40+4(a7),a0
	lea	FloatReg2,a1			; FReg2 = x
	jsr	FloatAMS2Internal
	jsr	FloatAdd			; FReg1 = x + (x^2+1)^(1/2)
	jsr	FloatLog10			; FReg1 = log10(x+(x^2+1)^(1/2))
	movem.l	FloatReg1,d1-d3
	movem.l	FloatLn10(pc),d4-d6
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult			; FReg1 = log10(x+(x^2+1)^(1/2))*ln(10)
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS		; Result = FReg1
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float	atanh(float x)
;bcdmul( log( bcddiv( bcdadd(x, 1.0), bcdsub(1, x) )) ,0.5);
atanh:
	movem.l	d3-d7/a2-a6,-(a7)
	lea	44(a7),a0
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal		; FReg1 = x
	movem.l	FloatOne(pc),d1-d3
	movem.l	d1-d3,FloatReg2			; FReg2 = 1
	jsr	FloatAdd			; FReg1 = x + 1
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,FloatReg4			; FReg4 = x+1
	lea	44(a7),a0
	lea	FloatReg2,a1
	jsr	FloatAMS2Internal		; FReg2 = x
	movem.l	FloatOne(pc),d1-d3
	movem.l	d1-d3,FloatReg2			; FReg1 = 1
	jsr	FloatSub			; FReg1 = 1 - x
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,FloatReg3			; FReg3 = 1 - x
	jsr	FloatDivide			; FReg1 = (x+1) / (1-x)
	jsr	FloatLog10
	movem.l	FloatReg1,d1-d3
	movem.l	FloatLn10Div2(pc),d4-d6
	movem.l	d1-d6,FloatReg3
	jsr	FloatMult			; FReg1 = log10((x+1)/(1-x)) * log(10)/2
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS		; Result = FReg1
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float cosh (float x)
;bcdmul(bcdadd(exp(x), exp(bcdneg(x))),0.5);
cosh:
	movem.l	d3-d7/a2-a6,-(a7)
	lea	44(a7),a0
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal		; FReg1 = x
	jsr	FloatExp			; FReg1 = exp(x)
	movem.l	FloatReg1,d1-d3
	lea	44(a7),a0
	movem.l	d1-d3,-(a7)			; Push FReg1
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal		; FReg4 = x
	not.w	FloatReg1+FLOAT.sign		; FReg4 = -x
	jsr	FloatExp			; FReg1 = exp(-x)
	movem.l	(a7)+,d1-d3
	movem.l	d1-d3,FloatReg2			; FReg2 = exp(x)
	jsr	FloatAdd			; FReg1 = exp(x) + exp(-x)
	movem.l	FloatReg1,d1-d3
	movem.l	FloatHalf(pc),d4-d6
	movem.l	d1-d6,FloatReg3			; FReg3 = exp(x)+exp(-x) FReg4 = 0.5
	jsr	FloatMult			; FReg1 = (exp(x)+exp(-x)) / 2
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS		; Result = FReg1
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float cosh (float x)
;bcdmul(bcdsub(exp(x), exp(bcdneg(x))),0.5);
sinh:
	movem.l	d3-d7/a2-a6,-(a7)
	lea	44(a7),a0
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal		; FReg4 = x
	jsr	FloatExp			; FReg1 = exp(x)
	movem.l	FloatReg1,d1-d3
	lea	44(a7),a0
	movem.l	d1-d3,-(a7)			; Push FReg1
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal		; FReg1 = x
	jsr	FloatExp			; FReg1 = exp(-x)
	movem.l	(a7)+,d1-d3
	movem.l	d1-d3,FloatReg2			; FReg2 = exp(x)
	jsr	FloatSub			; FReg1 = exp(x) - exp(-x)
	movem.l	FloatReg1,d1-d3
	movem.l	FloatHalf(pc),d4-d6
	movem.l	d1-d6,FloatReg3			; FReg3 = exp(x)-exp(-x) FReg4 = 0.5
	jsr	FloatMult			; FReg1 = (exp(x)-exp(-x)) / 2
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS		; Result = FReg1
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float	tanh(float x)
;bcddiv( bcdsub(exp(x), exp(bcdneg(x))), bcdadd(exp(x), exp(bcdneg(x))));
tanh:
	movem.l	d3-d7/a2-a6,-(a7)
	lea	44(a7),a0
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal		; FReg1 = x
	jsr	FloatExp			; FReg1 = exp(x)
	movem.l	FloatReg1,d1-d3
	lea	44(a7),a0
	movem.l	d1-d3,-(a7)			; Push FReg1
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal		; FReg4 = x
	jsr	FloatExp			; FReg1 = exp(-x)	
	movem.l	(a7),d1-d3			; Read 
	movem.l	FloatReg1,d4-d6			; FReg2 = exp(x)
	movem.l	d4-d6,-(a7)			; Push FReg1 = exp(-x)
	movem.l	d1-d3,FloatReg2			; FReg2 = exp(x)
	jsr	FloatSub			; FReg1 = exp(x) - exp(-x)
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,FloatReg4			; FReg4 = exp(x)-exp(-x)
	movem.l	(a7)+,d1-d6			
	movem.l	d1-d6,FloatReg1			; FReg1 = exp(-x) FReg2 = exp(x)
	jsr	FloatAdd			; FReg1 = exp(-x) + exp(x)
	movem.l	FloatReg1,d1-d3
	movem.l	d1-d3,FloatReg3			; FReg3 = exp(x)+exp(-x)
	jsr	FloatDivide			; FReg1 = (exp(x)-exp(-x)) / (exp(x)+exp(-x))
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS		; Result = FReg1
	movem.l	(a7)+,d3-d7/a2-a6
	rts

;float frexp10 (float x, short *exponent);
frexp10:
	movem.l	d3-d7/a2-a6,-(a7)
	lea	44(a7),a0
	lea	FloatReg1,a1
	jsr	FloatAMS2Internal		; FReg1 = x
	move.w	FloatReg1+FLOAT.exponent,d0
	sub.w	#$3FFF,d0
	move.l	48(a7),a1
	move.w	d0,(a1)			; Store exponent
	move.w	#$3FFF,FloatReg1+FLOAT.exponent
	lea	FloatReg1,a0
	lea	-10(a6),a1
	jsr	FloatInternal2AMS		; Result = FReg1
	movem.l	(a7)+,d3-d7/a2-a6
	rts



		
FloatArgError:
	;ER_THROW ARG_ERROR
