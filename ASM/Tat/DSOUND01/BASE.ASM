; BASE.ASM

;--------------------- EQUATES--------------------------


PBC	equ	$ffe0	;Port B Control register
PCC	equ	$ffe1	;Port C Control register
PBDDR	equ	$ffe2	;Port B Data Direction Register
PCDDR	equ	$ffe3	;Port C Data Direction Register
PBD	equ	$ffe4	;Port B Data register
PCD	equ	$ffe5	;Port C Data register
HCR	equ	$ffe8	;Host Control Register
HSR	equ	$ffe9	;Host Status Register
hsr	equ	$ffe9

HRX	equ	$ffeb	;Host Receive Register
hrx	equ	$ffeb

HTX	equ	$ffeb	;Host Transmit Register
htx	equ	$ffeb

BCR	equ	$fffe	;Port A Bus Control Register

OFF	equ	0
ON	equ	1	


;--------------------- MACROS --------------------------
wait_receive	MACRO
		jclr	#0,x:<<HSR,*
		ENDM
wait_transmit	MACRO
		jclr	#1,x:<<HSR,*
		ENDM
