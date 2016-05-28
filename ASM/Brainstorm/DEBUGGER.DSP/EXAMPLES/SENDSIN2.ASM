;
;TABSIZE = 8
;
; Sample DSP Demo Program of DSPDEBUG RECEIVE Function (endless loop)
;
PBC		EQU		$ffe0			; HI
HCR		EQU		$ffe8			; HI
HSR		EQU		$ffe9			; HI
HRX		EQU		$ffeb			; HI
HTX		EQU		$ffeb			; HI
BCR		EQU		$fffe			; HI
IPR		EQU		$ffff			; HI

		org		P:0
		jmp		$200

		org		P:$200
		movep		#>$4,X:<<HCR
		movep		#$0c00,X:<<IPR
		movep		#>$1,X:<<PBC
		movep		#>$0,X:<<BCR
		ori		#4,omr
		move		#$100,r0
		move		#$ff,m0
		nop
Loop		jclr		#1,X:<<HSR,Loop
		movep		Y:(r0)+,X:<<HTX
		jmp		Loop
