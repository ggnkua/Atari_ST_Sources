	OPT NOW

PBC	equ	$ffe0	;Port B Control register
PCC	equ	$ffe1	;Port C Control register
PBDDR	equ	$ffe2	;Port B Data Direction Register
PCDDR	equ	$ffe3	;Port C Data Direction Register
PBD	equ	$ffe4	;Port B Data register
PCD	equ	$ffe5	;Port C Data register
HCR	equ	$ffe8	;Host Control Register
HSR	equ	$ffe9	;Host Status Register
HRX	equ	$ffeb	;Host Receive Register
HTX	equ	$ffeb	;Host Transmit Register
CRA	equ	$ffec	;SSI Control Register A
CRB	equ	$ffed	;SSI Control Register B
SSISR	equ	$ffee	;SSI Status Register
SSITSR	equ	$ffee	;SSI Time Slot Register
RX	equ	$ffef	;SSI Serial Receive data/shift register
TX	equ	$ffef	;SSI Serial Transmit data/shift register
SCR	equ	$fff0	;SCI Control Register
SSR	equ	$fff1	;SCI Status Register
SCCR	equ	$fff2	;SCI Clock Control Register
STXA	equ	$fff3	;SCI Transmit data Address Register
SRX	equ	$fff4	;SCI Receive data register (4-5-6)
STX	equ	$fff4	;SCI Transmit data register (4-5-6)
BCR	equ	$fffe	;Port A Bus Control Register
IPR	equ	$ffff	;Interrupt Priority Register

size_buffer	equ	$800

rhost	MACRO	dest
	jclr	#0,x:<<HSR,*
	movep	x:<<HRX,dest
	ENDM
whost	MACRO	source
	jclr	#1,x:<<HSR,*
	movep	source,x:<<HTX
	ENDM


	org	p:0
	jmp	start
	
	org	p:$40
;--------------------------------------------
start
	rhost	x0
	move	#>1,x1
	clr	a
	do	x0,loop
	whost	a
	add	x1,a
loop
	nop
	jmp	start
