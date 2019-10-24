
; (c) 1994 AGOPIAN Mathias
; pour STMAG

; routine DSP pour l'exemple
; d'utilisation du DSP (appel de programme)

; Multiplaction de matrice [1,3][3,3]=[1,3]
; (sources libres Motorola)


        page    132,56,1,1


adc		EQU	$ffef		; ADC address
dac		EQU	$ffef		; DAC address
M_CRA		EQU     $FFEC           ; SSI Control Register A
M_CRB		EQU     $FFED           ; SSI Control Register B
M_SR		EQU     $FFEE           ; SSI Status Register
M_PCC		EQU     $FFE1           ; Port C Control Register
BCR		equ	$fffe
IPR		equ	$ffff
PBC		equ	$ffe0
HCR		equ	$ffe8		;Host Control Register
HSR		equ	$ffe9		;Host Status Register
HRX		equ	$ffeb		;Host Receive Register
HTX		equ	$ffeb		;Host Transmit Register



	org	x:0
mat_a	ds	3

        org     y:0
mat_b	ds	3
	ds	3
	ds	3
	
mat_x   ds      3
	

	org	p:$0
	jmp	start			; on saute au debut du programme


	; Programme principal
	
	org	p:$40
start	movep	#$01F8,X:M_PCC		; diverses initialisations
	movep	#$4100,X:M_CRA		; pour le port SSI et le port
	movep	#$F800,X:M_CRB		; HOST
	movep	#0,x:BCR
	movep	#$3000,x:IPR
	movep	#$1,x:PBC

	movec	#-1,m1


matmul 	move	#mat_a,r1		; On charge la matrice A
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r1)+
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r1)+
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r1)+
	
	move	#mat_b,r1		; Puis la matrice B
	do	#9,loop
	jclr	#0,X:HSR,*
	movep	x:HRX,y:(r1)+
loop

	move    #mat_a,r0       	; matrice A
        move    #mat_b,r4       	; matrice B
        move    #2,m0           	; modulo 3
        move    #mat_x,r1       	; matrice X=A+B
 
        move		x:(r0)+,x0  y:(r4)+,y0
        mpy     x0,y0,a	x:(r0)+,x0  y:(r4)+,y0
        mac     x0,y0,a	x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a	x:(r0)+,x0  y:(r4)+,y0
        move    a,y:(r1)+
        mpy     x0,y0,a	x:(r0)+,x0  y:(r4)+,y0
        mac     x0,y0,a	x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a	x:(r0)+,x0  y:(r4)+,y0
        move    a,y:(r1)+
        mpy     x0,y0,a	x:(r0)+,x0  y:(r4)+,y0
        mac     x0,y0,a	x:(r0)+,x0  y:(r4)+,y0
        macr    x0,y0,a	x:(r0)+,x0  y:(r4)+,y0
        move    a,y:(r1)+
        
        move    #mat_x,r1       	; matrice X=A+B
	jclr	#1,X:HSR,*
	movep	y:(r1)+,x:HRX
	jclr	#1,X:HSR,*
	movep	y:(r1)+,x:HRX
	jclr	#1,X:HSR,*
	movep	y:(r1)+,x:HRX
        
	jmp	matmul

