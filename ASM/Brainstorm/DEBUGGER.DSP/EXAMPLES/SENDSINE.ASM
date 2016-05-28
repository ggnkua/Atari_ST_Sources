;
;TABSIZE = 8
;
; Sample DSP Demo Program of DSPDEBUG RECEIVE Function ($100 loop)
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
		do	#$100,_EndLoop
_Wait2		jclr	#1,X:<<HSR,_Wait2
		movep	Y:(r0)+,X:<<HTX		; Send sine value
_EndLoop	jmp	_EndLoop

		END	Main			; Program begins at 'Main'

