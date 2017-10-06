; -------------------------------------------------------------------------
; -      Falcon030 DSP Grafik-Konverter   01.04.1994 Bernd HÅbenett       -
; -------------------------------------------------------------------------
; - V1.0 : Umsetzung von MC68030 -> DSP56001                              -
; - V2.0 : MPY statt mehreren ROL-befehlen seit dem 23.03.1994            -
; - V3.0 : Parallel-Data-Moves seit dem 31.03.1994 (Schneller,kÅrzer)     -
; - V3.1 : I/O Short Adressierungsart seit dem 01.05.1994                 -
; -------------------------------------------------------------------------

PBC	equ	$ffe0
HCR	equ	$ffe8
HSR	equ	$ffe9
HTX	equ	$ffeb
BCR	equ	$fffe

	org	p:$0
	jmp	start

	org	P:$40

start	movep	#0,X:BCR		; No Wait-States
	movep	#1,X:PBC		; configure for host port

xrece_1	jclr	#0,X:<<HSR,xrece_1	; wait again for data from host
	move	X:HTX,Y1		

	move	#>0.125,Y0
	mpy	Y1,Y0,B		#>$1f,Y0
	and	Y0,B1		#>0.03125,Y0

	mpy	Y1,Y0,A		#>$7E0,Y0
	and	Y0,A1		#>0.00390625,Y0
	move	A1,X1

	mpy	Y1,Y0,A		#>$F800,Y0
	and	Y0,A1		B1,X0
	or	X0,A1
	or	X1,A1

xmit_2	move	A1,X:HTX
	jmp	xrece_1


