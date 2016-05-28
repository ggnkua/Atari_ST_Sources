;This program uses forbiden vectors for debugging
Start:
	org	p:0
	nop
	nop
	nop		;this will not be allowed by the debugger
			;since it uses this vector.
	END	Start
