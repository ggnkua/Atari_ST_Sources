;
;TABSIZE = 8
;
; Sample DSP Demo Program of rom table access
;
	org	P:$200

	move	X:$100,x0
	ori	#4,omr		;set sine table
	nop
	nop
	nop
	move	X:$100,x0
	swi
