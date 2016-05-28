;
;TABSIZE = 8
;
PBC		EQU	$ffe0
HCR		EQU	$ffe8
HSR		EQU	$ffe9
HTX		EQU	$ffeb
BCR		EQU	$fffe
IPR		EQU	$ffff

		ORG	P:$200
Main		movep	#>$4,X:<<HCR		; Set HCIE for DSPDebug Commands
		movep	#$0c00,X:<<IPR
		movep	#>$1,X:<<PBC
		movep	#>$0,X:<<BCR
		andi	#$fe,mr			; IPL 2 to enable Host Commands
		ori	#4,omr			; Set DE (Sine table)
		move	#$100,r0		; Start of sine table
		move	#$ff,m0			; Modulo $100
_Loop		jclr	#1,X:<<HSR,Loop
		movep	Y:(r0)+,X:<<HTX		; Send sine value
		jmp	_Loop
		END	Main			; Program begins at 'Main'
