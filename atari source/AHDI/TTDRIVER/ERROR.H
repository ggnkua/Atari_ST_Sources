;+
; BIOS error codes
;-
EDRVNR		equ	-2		; driver not ready
EWRITF		equ	-10		; write fault
EREADF		equ	-11		; read fault
EWRPRO		equ	-13		; write on write-protected media
E_CHNG		equ	-14		; media change detected
CRITRETRY	equ	$00010000	; "retry" return code

;+
; Controller error codes
;-
DRVNRDY		equ	$4		; drive not ready
WRTPRTD		equ	$27		; write on write-protected media
MDMCHGD		equ	$28		; media change detected


