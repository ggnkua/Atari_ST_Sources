; Le probleme ne se pose que si on fait directement Mandelbrot sans
; passer par A,B...
DEBUG		equ	0
BOOT		equ	0

;  #[ EQUates & Defines:

		define	MNT		'X'	; Mantissa space
		define	EXP		'Y'	; Exponant space
		define	FLT		'L'	; Float space
		define	TMP		'X'	; Float tmp space

PBC		equ		$ffe0	; HI
HCR		equ		$ffe8	; HI
HSR		equ		$ffe9	; HI
HRX		equ		$ffeb	; HI
HTX		equ		$ffeb	; HI
BCR		equ		$fffe	; HI
IPR		equ		$ffff	; HI

DESPROF		equ		$0000ff

HAUT		equ		128
LARGE		equ		128

		IF		BOOT
width		equ		$20
		ELSE
width		equ		$1000
		ENDIF
height		equ		width+1
immin		equ		width+2
immax		equ		width+3
remin		equ		width+4
remax		equ		width+5
infini		equ		width+6
two		equ		width+7
calcprof	equ		width+8
xx		equ		width+9
yy		equ		width+10
im		equ		width+11
re		equ		width+12
lreal		equ		width+13
limag		equ		width+14
dreal		equ		width+15
dimag		equ		width+16
tmp_dreal	equ		width+17
tmp_dimag	equ		width+18
tmp		equ		width+19
prof		equ		width+20
x_counter	equ		width+21
gcounter	equ		width+22
fp_temp		equ		0

		org		P:$0
		jmp		begin


;  #] EQUates & Defines:

;  #[ Start of program:
		IF	BOOT
		org		P:$40		;y:2000
		ELSE
		org		P:$2000
		ENDIF

begin		ori		#$3,mr
		movep		#>$0,X:<<HCR
		movep		#$0c00,X:<<IPR
		movep		#>$1,X:<<PBC
		movep		#>$0,X:<<BCR

		move		TMP:fp_m1,m0
		move		#fp_shift,n0
;		and		#$f3,mr
		and		#$bf,ccr
		clr		a
		move		a,X:gcounter
		

;  #] Start of program:

;  #[ Wait order:
;
;				A = TopLeft
;				B = TopRight
;				C = BottomLeft
;				D = BottomRight
;				E = Reset
;
		jsr		data_init
		move		#>$1f,x0
		move		x0,TMP:calcprof
userchoice	clr		a

		IF	DEBUG
		nop
		ELSE
_order		jclr		#0,X:<<HSR,_order
		movep		X:<<HRX,r3
_prof		jclr		#0,X:<<HSR,_prof
		movep		X:<<HRX,a1
		ENDIF
		move		a1,TMP:calcprof
		move		#remax,r6
		move		#remin,r7
		jsr		ffp_sub
		move		a,FLT:re
		move		#re,r6
		move		#two,r7
		jsr		ffp_div
		move		a,FLT:re
		move		#re,r6
		move		#remin,r7
		jsr		ffp_add
		move		a,FLT:re
		move		#immax,r6
		move		#immin,r7
		jsr		ffp_sub
		move		a,FLT:im
		move		#im,r6
		move		#two,r7
		jsr		ffp_div
		move		a,FLT:im
		move		#im,r6
		move		#immin,r7
		jsr		ffp_add
		move		a,FLT:im
		move		FLT:re,b
		move		a,y1
		move		a0,y0
		clr		a
		move		r3,a
		IF		DEBUG
		jmp		reset
		ELSE
		move		#>$41,x1
		sub		x1,a
		jeq		topleft				; A
		move		#>$1,x1
		sub		x1,a
		jeq		topright			; B
		sub		x1,a
		jeq		bottomleft			; C
		sub		x1,a
		jeq		bottomright			; D
		sub		x1,a
		jeq		reset				; E
		jmp		userchoice
		ENDIF
;  #] Wait order:
;  #[ TopLeft:

topleft		move		b,FLT:remax
		move		y,FLT:immax
		jsr		mandelbrot
		jmp		userchoice

;  #] TopLeft:
;  #[ TopRight:

topright	move		b,FLT:remin
		move		y,FLT:immax
		jsr		mandelbrot
		jmp		userchoice

;  #] TopRight:
;  #[ BottomLeft:

bottomleft	move		b,FLT:remax
		move		y,FLT:immin
		jsr		mandelbrot
		jmp		userchoice

;  #] BottomLeft:
;  #[ BottomRight:


bottomright	move		b,FLT:remin
		move		y,FLT:immin
		jsr		mandelbrot
		jmp		userchoice

;  #] BottomRight:
;  #[ Reset:

reset		jsr		data_init
		jsr		mandelbrot
		jmp		userchoice

;  #] Reset:
;  #[ DATA init:

data_init	move		#fp_var,r0
		move		#fp_temp,r1
		do		#31,end_loop1
		move		P:(r0)+,x0
		move		x0,TMP:(r1)+
end_loop1	move		#Mandel,r0
		move		#width,r1
		do		#8,end_loop2
		move		P:(r0)+,x0
		move		P:(r0)+,x1
		move		x,FLT:(r1)+
end_loop2	nop
		clr		a		(r1)+
		rep		#13
		move		a,FLT:(r1)+
		rts

;  #] DATA init:
;  #[ Mandelbrot:

mandelbrot
; dreal = (remax - remin) / (width - 1)
		move		#remax,r6
		move		#remin,r7
		jsr		ffp_sub
		move		a,FLT:tmp
		move		#tmp,r6
		move		#width,r7		; -1
		jsr		ffp_div
		move		a,FLT:dreal
; dimag = (immax - immin) / (height - 1)
		move		#immax,r6
		move		#immin,r7
		jsr		ffp_sub
		move		a,FLT:tmp
		move		#tmp,r6
		move		#height,r7		; -1
		jsr		ffp_div
		move		a,FLT:dimag
; clr tmp_dimag
		clr		a
		move		a,FLT:tmp_dimag
; for iimag = 0 to haut
		do		#HAUT,end_y
; limag = immin + tmp_dimag
		move		#immin,r6
		move		#tmp_dimag,r7
		jsr		ffp_add
		move		a,FLT:limag
; tmp_dimag = tmp_dimag + dimag
		move		#tmp_dimag,r6
		move		#dimag,r7
		jsr		ffp_add
		move		a,FLT:tmp_dimag
; clr tmp_dreal
		clr		a
		move		a,FLT:tmp_dreal
; for ireal = 0 to large
		do		#LARGE,end_x
; lreal = remin + tmp_dreal
		move		#remin,r6
		move		#tmp_dreal,r7
		jsr		ffp_add
		move		a,FLT:lreal
; tmp_dreal = tmp_dreal + dreal
		move		#tmp_dreal,r6
		move		#dreal,r7
		jsr		ffp_add
		move		a,FLT:tmp_dreal
; re = lreal
		move		FLT:lreal,a
		move		a,FLT:re
; im = limag
		move		FLT:limag,a
		clr		b		a,FLT:im
; prof = 0
		move		b,TMP:prof
depth_loop
; xx = re * re
		move		#re,r6
		move		r6,r7
		jsr		ffp_mpy
		move		a,FLT:xx
; yy = im * im
		move		#im,r6
		move		r6,r7
		jsr		ffp_mpy
		move		a,FLT:yy
; im = 2 * re * im - limag
		move		#re,r6
		move		r6,r7
		jsr		ffp_add
		move		a,FLT:tmp
		move		#tmp,r6
		move		#im,r7
		jsr		ffp_mpy
		move		a,FLT:tmp	
		move		#tmp,r6
		move		#limag,r7
		jsr		ffp_sub
		move		a,FLT:im
; re = xx - yy - lreal
		move		#xx,r6
		move		#yy,r7
		jsr		ffp_sub
		move		a,FLT:tmp
		move		#tmp,r6
		move		#lreal,r7
		jsr		ffp_sub
		move		a,FLT:re
; prof = prof + 1
		move		TMP:prof,a
		move		#>1,x1
		add		x1,a
		move		a,TMP:prof
; if (( prof = calcprof) or ((xx + yy) > infini)) then end_depth else depth_loop
		move		#xx,r6
		move		#yy,r7
		jsr		ffp_add
		move		a,FLT:tmp
		move		#tmp,r6
		move		#infini,r7
		jsr		ffp_cmp
		jpl		end_depth
		move		TMP:prof,a
		move		TMP:calcprof,x0
		sub		x0,a
		jne		depth_loop
end_depth
		jsr		trace
		nop
		nop
		nop
end_x		nop
end_y		nop
		nop
		rts

;  #] Mandelbrot:
;  #[ Trace:

trace		move		#0,y1
; if (prof > calcprof) then plot 'BLACK' else modulo
		move		TMP:prof,a
		move		TMP:calcprof,x1
		cmp		x1,a
		jpl		plot
; color = prof & desprof
modulo		move		#0,a2
		move		#>DESPROF,x1
		and		x1,a
		move		a,y1
		IF		DEBUG
plot		nop
		ELSE
plot		jclr		#1,X:<<HSR,plot
		movep		#$ABCDEF,X:<<HTX
realplot	jclr		#1,X:<<HSR,realplot
		movep		y1,X:<<HTX
		ENDIF
		move		#>1,y1
		move		X:gcounter,a
		add		y1,a
		move		a,X:gcounter
		rts

;  #] Trace:
;  #[ FFP add:

ffp_add		move		EXP:(r6),b1
		move		MNT:(r6),a
		move		FLT:(r7),x
		cmp		x0,b		TMP:fp_23,y0
		jge		_dpos
_dneg		tfr		x1,a		a1,x1
		tfr		x0,b		b1,x0
_dpos		sub		x0,b		b1,y1
		cmp		y0,b		b1,r0
		jgt		done1
addm		move		TMP:(r0+n0),x0
		mac		-x1,x0,a	y1,r0
		jmp		norm1
norm		rep		#8
norm1		norm		r0,a
		jnn		norm
round		rnd		a
		norm		r0,a
check		move		r0,TMP:fp_temp
		jset		#15,TMP:fp_temp,under
		jset		#14,TMP:fp_temp,limit
check1		tst		a		r0,b
		teq		a,b
		move		b1,a0
		rts
under		or		#$40,ccr
zero		clr		a		#0,b
		jmp		done
limit		asl		a		TMP:fp_emax,y1
done1		tfr		y1,b		a,a
done		move		b1,a0
end_ffp		rts

;  #] FFP add:
;  #[ FFP sub:

ffp_sub		move		EXP:(r6),b1
		move		MNT:(r6),a
		move		FLT:(r7),x
		sub		x0,b		b1,y1
		jge		_dpos
_dneg		tfr		x1,a		a1,x1
		neg		a		x0,y1
		abs		b		TMP:fp_23,y0
		cmp		y0,b		b1,r0
		jle		addm
		tst		a		x0,r0
		jmp		norm1
_dpos		move		TMP:fp_23,y0
		cmp		y0,b		b1,r0
		jgt		done1
		move		TMP:(r0+n0),x0
		mac		x1,x0,a		y1,r0
		jmp		norm

;  #] FFP sub:
;  #[ FFP cmp:

ffp_cmp		move		EXP:(r6),b1
		move		MNT:(r6),a
		move		FLT:(r7),x
		eor		x1,a		a,y0
		jmi		_mant
_sign		eor		x1,a
		jpl		_sign1
		tfr		x0,b		b,x0
_sign1		cmp		x0,b
		jne		end_ffp
_mant		tfr		y0,a
		cmp		x1,a
		rts

;  #] FFP cmp:
;  #[ FFP mpy:

ffp_mpy		move		EXP:(r6),b1
		move		MNT:(r6),a
		move		FLT:(r7),x
		add		x0,b		TMP:fp_ebias,x0
		sub		x0,b		a,y1
		mpy		x1,y1,a		b,r0
		jmp		norm1

;  #] FFP mpy:
;  #[ FFP div:

ffp_div		move		EXP:(r6),b1
		move		MNT:(r6),a
		move		FLT:(r7),x
		sub		x0,b		TMP:fp_ebias,x0
		add		x0,b
		tfr		x1,b		b,r0
		tst		b
		jne		_divl
		tst		a
		jne		limit
		or		#$40,ccr
_divl		asr		a		a,b
		jeq		done
		abs		a		(r0)+
		eor		x1,b
		and		#$fe,ccr
		rep		#24
		div		x1,a
		jpl		_qpos
		neg		a
_qpos		move		a0,a
		tst		a
		norm		r0,a
		jmp		norm1

;  #] FFP div:
;  #[ Data section:

Mandel		dc		$002007,$400000		; width	128
		dc		$002007,$400000		; height	128
		dc		$002000,$b33fff		; immin	-1.2
		dc		$002000,$4cc000		; immax	+1.2
		dc		$001fff,$9fffff		; remin	-0.75
		dc		$002001,$480000		; remax	+2.25
		dc		$002009,$400000		; infini	512
		dc		$002001,$400000		; two		2
		dc		$00001f,$00001f		; CALCPROF
fp_var
		dc		0
		dc		0
		dc		0
		dc		0
		dc		23
		dc		$001fff
		dc		$003fff
		dc		$800000,$c00000,$e00000,$f00000
		dc		$f80000,$fc0000,$fe0000,$ff0000
		dc		$ff8000,$ffc000,$ffe000,$fff000
		dc		$fff800,$fffc00,$fffe00,$ffff00
		dc		$ffff80,$ffffc0,$ffffe0,$fffff0
		dc		$fffff8,$fffffc,$fffffe
		dc		$ffffff				; 31 vars

		org		TMP:fp_temp
		dc		0
		dc		0
		dc		0
		dc		0
fp_23		dc		23
fp_ebias	dc		$001fff
fp_emax		dc		$003fff
fp_shift	dc		$800000,$c00000,$e00000,$f00000
		dc		$f80000,$fc0000,$fe0000,$ff0000
		dc		$ff8000,$ffc000,$ffe000,$fff000
		dc		$fff800,$fffc00,$fffe00,$ffff00
		dc		$ffff80,$ffffc0,$ffffe0,$fffff0
		dc		$fffff8,$fffffc,$fffffe
fp_m1		dc		$ffffff				; 31 vars
;  #] Data section:

;  #[ End:

		end

;  #] End:

