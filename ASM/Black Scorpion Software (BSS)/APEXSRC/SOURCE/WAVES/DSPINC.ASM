;-----------------------------------------------------------------------
; Register equates
;-----------------------------------------------------------------------

PBC	equ	$FFE0	; Port B control register (Host port)
HSR	equ	$FFE9	; Host status register
HTX	equ	$FFEB	; Host TX/RX register

;-----------------------------------------------------------------------
; Host communication macros
;-----------------------------------------------------------------------

dspread		macro	var
_rd		jclr		#0,x:<<HSR,_rd
		movep		x:<<HTX,var
		endm

dspwrite	macro	var
_wr		jclr		#1,x:<<HSR,_wr
		movep		var,x:<<HTX
		endm
