;This program produces oscillations on HI flags (hf2 and hf3)

PBC	EQU	$ffe0	; HI
HCR	EQU	$ffe8	; HI
BCR	EQU	$fffe	; HI
IPR	EQU	$ffff	; HI & SCI
HF3	EQU	4
HF2	EQU	3

	org	p:$200
	ori	#3,mr
	movep	#>%10100,X:<<HCR	;HCIE+HF2
	movep	#$0c00,X:<<IPR
	movep	#>1,X:<<PBC
	movep	#>0,X:<<BCR
loop:	movep	X:<<HCR,A
	bchg	#HF3,A
	bchg	#HF2,A
	movep	A,X:<<HCR
	jmp	loop
