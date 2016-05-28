;This program outputs $ABCDEF $100 times using the HI transmit register

PBC		equ		$ffe0	; HI
HCR		equ		$ffe8	; HI
HSR		equ		$ffe9	; HI
HTX		equ		$ffeb	; HI
BCR		equ		$fffe	; HI
IPR		equ		$ffff	; HI

		org		P:$2000
begin		ori		#$3,mr		; Prepare HOST
		movep		#>$0,X:<<HCR	; Prepare HOST
		movep		#$0c00,X:<<IPR	; Prepare HOST
		movep		#>$1,X:<<PBC	; Prepare HOST
		movep		#>$0,X:<<BCR	; Prepare HOST

		move		#>$100,x0
		do		x0,_loop
		nop
_send		jclr		#1,X:<<HSR,_send
		movep		#$ABCDEF,X:<<HTX	;send magic
_loop:		swi
