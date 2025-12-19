; defs.inc
; Todd Day (todd@ivucsb.sba.ca.us)
; Wed Aug  2 23:43:22 PDT 1989
; miscellaneous definitions that I've found useful
; sometimes I use them in programs I write

; number of samples per second = 20 MHz / 512 (your value here)
numsamp	equ	39062

; program starting point (we aren't using the host vectors - $40 if you do)
pgmram	equ	$0020

; beginning of internal data ram
intram	equ	$0000

; beginning of internal data rom
introm	equ	$0100

; beginning of external data ram
extram	equ	$0200

; end of external data ram
endram	equ	$ffbf
