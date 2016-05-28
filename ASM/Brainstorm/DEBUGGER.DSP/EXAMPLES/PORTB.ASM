;This program produces oscillations on the port B transmit register

PBC	EQU	$ffe0	;Port B Control register
PBDDR	EQU	$ffe2	;Port B Data Direction Register
PBD	EQU	$ffe4	;Port B Data register

	org	p:$200
	movep	#>0,X:<<PBC		;GPIO
	movep	#>$7fff,X:<<PBDDR
loop:	movep	#>0,X:<<PBD
	movep	#>$ffff,X:<<PBD
	jmp	loop
