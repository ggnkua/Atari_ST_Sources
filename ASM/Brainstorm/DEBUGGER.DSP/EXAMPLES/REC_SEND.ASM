;
;TABSIZE = 8
;
; Sample DSP Demo Program of DSPDEBUG SEND and RECEIVE Functions on HI.
;
PBC		EQU	$ffe0
HCR		EQU	$ffe8
HSR		EQU	$ffe9
HRX		EQU	$ffeb
HTX		EQU	$ffeb
BCR		EQU	$fffe
IPR		EQU	$ffff

		ORG	P:$200
Main		movep	#>$4,X:<<HCR		; Set HCIE for DSPDebug Commands
		movep	#$0c00,X:<<IPR
		movep	#>$1,X:<<PBC
		movep	#>$0,X:<<BCR
		andi	#$fe,mr			; IPL 2 to enable DSPDebug Host Commands
		ori	#4,omr			; Set DE (Sine table)
		move	#$100,r0		; Start of sine table
		move	#$ff,m0			; Modulo $100
_Wait1		jclr	#0,X:<<HSR,_Wait1
		movep	X:<<HRX,a
		move	Y:(r0)+,b
		cmp	a,b
		jeq	_Wait2
		swi
_Wait2		jclr	#1,X:<<HSR,_Wait2
		movep	a,X:<<HTX		; Send sine value
		jmp	_Wait1

		END	Main			; Program begins at 'Main'

