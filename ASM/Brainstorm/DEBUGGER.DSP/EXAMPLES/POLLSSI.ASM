;
;TABSIZE = 8
;
; Sample DSP Demo Program of SSI transmit register (polling)
;

BCR	equ	$fffe
IPR	equ	$ffff
CRA	equ	$ffec
CRB	equ	$ffed
PCC	equ	$ffe1
SSISR	equ	$ffee
SSITX	equ	$ffef

;	ORG	P:0
;	jmp	Start

	ORG	P:$200
Start	ori	#3,mr
	movep	#0,X:<<BCR
	movep	#$3000,X:<<IPR
	movep	#$4100,X:<<CRA
	movep	#$f83c,X:<<CRB
	movep	#$1ff,X:<<PCC
	btst	#4,X:<<SSISR
	movep	#>0,X:<<SSITX
	ori	#4,omr
	move	#$100,r0
	move	#$ff,m0
	move	#$20000,x1
Loop	;jclr	#0,X:<<SSISR,Loop
	movep	Y:(r0)+,X:<<SSITX
	rep	x1
	nop
	jmp	Loop

	END	Start
