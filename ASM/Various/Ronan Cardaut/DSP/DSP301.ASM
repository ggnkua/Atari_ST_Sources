

;------------------------------------------------------------------------------
;HOST EQUATES
;------------------------------------------------------------------------------
M_DTXS	equ	$FFCD         	;slave transmit fifo
M_DRXS	equ	$FFCB         	;slave receive fifo


M_DSR	equ	$FFC9         	;DSP Status register
M_DCTR	EQU	$FFC5         	; DSP CONTROL REGISTER (DCTR)    
M_HINT	EQU	6          	; Host Interrupt A
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
;       PLL EQUATES
;------------------------------------------------------------------------------
M_PCTL	EQU	$FFFD         	; PLL Control Register

M_MF  	EQU	$FFF            ; Multiplication Factor Bits Mask (MF0-MF11)
M_DF  	EQU     $7000           ; Division Factor Bits Mask (DF0-DF2)
M_XTLR 	EQU     15              ; XTAL Range select bit
M_XTLD	EQU     16              ; XTAL Disable Bit
M_PSTP	EQU     17              ; STOP Processing State Bit 
M_PEN	EQU     18              ; PLL Enable Bit
M_PCOD	EQU     19              ; PLL Clock Output Disable Bit
M_PD	EQU	$F00000		; PreDivider Factor Bits Mask (PD0-PD3)
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Bus Interface Unit
;------------------------------------------------------------------------------
M_BCR    EQU     $FFFB         ; Bus Control Register
M_AAR0   EQU     $FFF9         ; Address Attribute Register 0 
M_AAR1   EQU     $FFF8         ; Address Attribute Register 1 
M_AAR2   EQU     $FFF7         ; Address Attribute Register 2 
M_AAR3   EQU     $FFF6         ; Address Attribute Register 3 

;       Address Attribute Registers
M_BAT    EQU     $3              ; External Access Type and Pin Definition Bits Mask (BAT0-BAT1)
M_BAAP   EQU     2               ; Address Attribute Pin Polarity
M_BPEN   EQU     3               ; Program Space Enable
M_BXEN   EQU     4               ; X Data Space Enable
M_BYEN   EQU     5               ; Y Data Space Enable
M_BAM    EQU     6               ; Address Muxing
M_BPAC 	 EQU	 7		 ; Packing Enable
M_BNC    EQU     $F00            ; Number of Address Bits to Compare Mask (BNC0-BNC3)
M_BAC    EQU     $FFF000         ; Address to Compare Bits Mask (BAC0-BAC11)
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; quelques macro bien utiles
;------------------------------------------------------------------------------
rec	MACRO	dest
	jclr	#2,x:<<M_DSR,*
	movep	x:<<M_DRXS,dest
	nop		
	nop		
	ENDM

env	MACRO	dest
	jclr	#1,x:<<M_DSR,*
	movep	dest,x:<<M_DTXS
	nop	
	nop		
	ENDM

;------------------------------------------------------------------------------




SIZE_DEBUG	equ	$300		;taille du noyau...

	org	p:$0
	jmp	>INIT_WITH_PROTECT
	
	jsr	>STACK		;STACK ERROR
	
	jsr	>III		;Illegal Instruction Interrupt
	
	nop
	nop			;Debug Request
	
	
	jsr	>TRAP		;anciennement SWI

	dup	(256-*)
	nop
	endm


	;org	p:$100	
START
	nop
	nop
	nop
	nop
				
	

	jmp	START
	
;------------------------------------------------------------------------------
	;org	p:$7ea9-SIZE_DEBUG		;7ea9= d‚but du TOS
START_DEBUG
	dc	'DSP'

MAIN	

;------------------------------------------------------------------------------
;  La boucle principale du debugeur  *
;------------------------------------------------------------------------------
AGAIN_T
	move	#>'CMD',x0	;id COMMAND
	rec	a
	cmp	x0,a	#TAB_ROUT,r0
	jne	AGAIN_T		; => attente
	rec	n0		;No de CMD
	nop
	move	p:(r0+n0),r0
	nop
	jmp	(r0)


;------------------------------------------------------------------------------
; liste des fonctions DISPO
;------------------------------------------------------------------------------
TAB_ROUT 
	dc	P_DUMP
	dc	X_DUMP
	dc	Y_DUMP
	dc	L_DUMP
	dc	RUN
	dc	P_REC
	dc	X_REC
	dc	Y_REC
	dc	L_REC

;------------------------------------------------------------------------------
P_DUMP	rec	r0
	rec	a
	tst	a
	jeq	_loop
	do	a,_loop
	env	P:(r0)+	
        nop
_loop	jmp	AGAIN_T
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
X_DUMP	rec	r0
	rec	a
	tst	a
	jeq	_loop
	do	a,_loop
	env	X:(r0)+	
_loop	jmp	AGAIN_T
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
Y_DUMP	
	rec	r0
	rec	a
	tst	a
	jeq	_loop
	do	a,_loop
	env	Y:(r0)+	
_loop	jmp	AGAIN_T
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
L_DUMP	
	rec	r0
	rec	a
	tst	a
	jeq	_loop
	do	a,_loop
	move	l:(r0)+,x
	env	x1
	env	x0
_loop	jmp	AGAIN_T
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
P_REC	rec	r0
	rec	a
	tst	a
	jeq	_loop
	do	a,_loop
	rec	P:(r0)+	
        nop
_loop	jmp	AGAIN_T
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
X_REC	rec	r0
	rec	a
	tst	a
	jeq	_loop
	do	a,_loop
	rec	X:(r0)+	
_loop	jmp	AGAIN_T
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
Y_REC	rec	r0
	rec	a
	tst	a
	jeq	_loop
	do	a,_loop
	rec	y:(r0)+	
_loop	jmp	AGAIN_T
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
L_REC	rec	r0
	rec	a
	tst	a
	jeq	_loop
	do	a,_loop
	rec	x1
	rec	x0
	move	x,l:(r0)+
_loop	jmp	AGAIN_T
;------------------------------------------------------------------------------






;------------------------------------------------------------------------------
; deux cas pour les inits: avec ou sans la protection... eh eh
;------------------------------------------------------------------------------
INIT_WITH_PROTECT
	env	p:DMSP
	env	p:DMSP+1
	rec	a	
	move	#>4,x0
	cmp	x0,a
	jgt	Y_DUMP		;erreur trop importante => on plante le DSP
	env	#>7614		;ok ca a march‚ (nombre magique)

	jclr	#5,x:<<M_DSR,*		;attend que le 040 mette HF2

;------------------------------------------------------------------------------



INIT	
	;andi	#<%11111100,mr	;passe en IPL0

;------------------------------------------------------------------------------
; r‚glage de la PLL
;------------------------------------------------------------------------------
; XTAL disabled moins de noise
; Pll ENable
; Clock Output Disabled moins de noise
;
; Attention, le temps max pour avoir une PLL op‚rationnelle est
;  1000 * ETC * PDF 	..koa c'est ETC ???
;
;------------------------------------------------------------------------------
; plusieurs vitesses possibles
; 	FREQUENCE	ratio	DF	PDF	MF0
;	25		0.5	0	16	8
;	50		1	0	8	8
;	62.5		1.25	0	8	10
;	75		1.5	0	8	12
;	81.25		1.625	0	8	13		
;------------------------------------------------------------------------------
PDF	equ	8
MF	equ	13


	movep    #(MF-1)|(1<<M_PEN)|((PDF-1)<<20),x:<<M_PCTL
	
	move	#>1000*PDF,x0
	.LOOP	x0
	nop
	.ENDL



;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; r‚glage de la RAM externe
;------------------------------------------------------------------------------
;
; AA0 sert de CS et est donc active low elle est asserted sur tout acces externe
;
; AA3		‚tat		A16
; inactive	0		0V
; active	1		5V
;
;les 384 ko de Static Ram sont divis‚s en 2 bank de 64 Kw : Low et High
;	ACCES		BANK		AA3
; P:0 … 64K		H		active
; P:64K … 128K		L		inactive
; X:0 … 64K		H		active
; Y:0 … 64K		L		inactive
;------------------------------------------------------------------------------
boot

 	movep	#>%01|(1<<M_BPEN)|(1<<M_BXEN)|(1<<M_BYEN),x:<<M_AAR0	;AAR0 active(Low) sur acces … la ram externe

 	movep	#>%01|(1<<M_BPEN)|(1<<M_BXEN)|(8<<8)|($00<<12)|(1<<M_BAAP),x:<<M_AAR3

	movep	#(1<<16)|(1<<13)|(1),x:<<M_BCR	;1 WS sur AA3,AA0 et default

	bset	#14,omr

;------------------------------------------------------------------------------


	;*------------------------*
	;* si y a jmp init en 0
	;* remplace par un saut en $40
	;* ca le fait que au lancement ...
	;*------------------------*
	move	p:1,a
	move	#>INIT,x0
	cmp	x0,a	#>INIT_WITH_PROTECT,x0
	jeq	_ok0
	cmp	x0,a	
	jne	MAIN
_ok0
	move	#>$100,x0
	move	x0,p:1
	jmp	MAIN

;------------------------------------------------------------------------------
; arret sur STACK ERROR
;------------------------------------------------------------------------------
STACK
	bset	#M_HINT,x:<<M_DCTR	;d‚clenche HINT
	jclr	#5,x:<<M_DSR,*		;attend que le 040 mette HF2
	bclr	#M_HINT,x:<<M_DCTR	;coupe HINTA
	jset	#5,x:<<M_DSR,*		;attend que le 040 efface HF2
	
	env	#>'CTK'
	env	#0
	jmp	SAVE_REG

TRACE

;------------------------------------------------------------------------------
; arret sur TRAP ( ancien SWI )
;------------------------------------------------------------------------------
TRAP
	bset	#M_HINT,x:<<M_DCTR	;d‚clenche HINT
	jclr	#5,x:<<M_DSR,*		;attend que le 040 mette HF2
	bclr	#M_HINT,x:<<M_DCTR	;coupe HINTA

	env	#>'CTK'
	env	#>2
	jmp	SAVE_REG

;------------------------------------------------------------------------------
; arret sur III
;------------------------------------------------------------------------------
III
	bset	#M_HINT,x:<<M_DCTR	;d‚clenche HINT
	jclr	#5,x:<<M_DSR,*		;attend que le 040 mette HF2
	bclr	#M_HINT,x:<<M_DCTR	;coupe HINTA
	jset	#5,x:<<M_DSR,*		;attend que le 040 efface HF2
	
	env	#>'CTK'
	env	#3
	jmp	SAVE_REG

;------------------------------------------------------------------------------
; H C =interruption par le 40
;------------------------------------------------------------------------------
HC_EXEP
	bset	#M_HINT,x:<<M_DCTR	;d‚clenche HINT
	jclr	#5,x:<<M_DSR,*		;attend que le 040 mette HF2
	bclr	#M_HINT,x:<<M_DCTR	;coupe HINTA
	jset	#5,x:<<M_DSR,*		;attend que le 040 efface HF2
	
	env	#>'CTK'
	env	#4
	jmp	SAVE_REG


;------------------------------------------------------------------------------
; la  on sauve l'etat du CPU
;------------------------------------------------------------------------------
SAVE_REG	


	;*---------------------*
	;* SAUVE AGU
	;*---------------------*
	env	r0
	env	n0
	env	m0
	env	r1
	env	n1
	env	m1
	env	r2
	env	n2
	env	m2
	env	r3
	env	n3
	env	m3
	env	r4
	env	n4
	env	m4
	env	r5
	env	n5
	env	m5
	env	r6
	env	n6
	env	m6
	env	r7
	env	n7
	env	m7

	;*---------------------*
	;* SAUVE ALU
	;*---------------------*
	env	a2
	env	a1
	env	a0
	env	b2
	env	b1
	env	b0

	env	x1
	env	x0

	env	y1
	env	y0
			

	;*---------------------*
	;* SAUVE PCU
	;*---------------------*
	env	LA
	env	LC
	env	SSL	
	env	SSH		;sp-1
	env	SP		;sauve SP-1	
	

	;*---------------------*
	;* recoit le contenu du buffer HOST … recevoir
	;* et le renvoie imm‚diatemment au 040
	;*---------------------*
	move	#>'CTK',x0
	move	#HOST_BUF,r0
_loop0	rec	a
	move	a,p:(r0)+
	cmp	x0,a
	jne	_loop0

	move	#HOST_BUF,r0
	nop	
_loop00	move	p:(r0)+,a
	env	a
	cmp	x0,a
	jne	_loop00



	
	;*---------------------*
	;* recoit le contenu du buffer HOST … r‚‚mettre
	;*---------------------*
	move	#HOST_BUF,r0
_loop1	rec	a
	move	a,p:(r0)+
	cmp	x0,a
	jne	_loop1

	
	

	jmp	MAIN
;------------------------------------------------------------------------------





;------------------------------------------------------------------------------
; restauration des registres & compagnie
;------------------------------------------------------------------------------
RESTORE_REG
RUN
;------------------------------------------------------------------------------
	;*---------------------*
	; je remet mes exceptions
	;*---------------------*
	move	#>$bf080,x0

	move	#2,r0		;STACK ERROR
	move	#>STACK,x1
	move	x0,p:(r0)+
	move	x1,p:(r0)+		

	move	#8,r0		;TRAP
	move	#>TRAP,x1
	move	x0,p:(r0)+
	move	x1,p:(r0)+		

	move	#$4,r0		;III
	move	#>III,x1
	move	x0,p:(r0)+
	move	x1,p:(r0)+		
	
	
	
	;*---------------------*
	;* je r‚‚met les trucs coinc‚s ds le HOST
	;*---------------------*
	move	#HOST_BUF,r0
	move	#>'CTK',x0
_loop1	
	move	p:(r0)+,a
	cmp	x0,a
	jeq	_fin0
	env	a
	jmp	_loop1	
_fin0

	;*---------------------*
	;* RESTORE AGU
	;*---------------------*
	rec	r0
	rec	n0
	rec	m0
	rec	r1
	rec	n1
	rec	m1
	rec	r2
	rec	n2
	rec	m2
	rec	r3
	rec	n3
	rec	m3
	rec	r4
	rec	n4
	rec	m4
	rec	r5
	rec	n5
	rec	m5
	rec	r6
	rec	n6
	rec	m6
	rec	r7
	rec	n7
	rec	m7

	;*---------------------*
	;* RESTORE ALU
	;*---------------------*
	rec	a2
	rec	a1
	rec	a0
	rec	b2
	rec	b1
	rec	b0

	rec	x1
	rec	x0
	rec	y1
	rec	y0
			

	;*---------------------*
	;* RESTORE PCU
	;*---------------------*
	rec	LA
	rec	LC
	
	rec	SP		;r‚cupere SP-1	
	rec	SSH		;sp+1
	rec	SSL	
	
	
	jset	#5,x:<<M_DSR,*		;attend que le 040 efface HF2 
	nop
	nop
	

	
	rti

;*-----------------------------------------------------------------------------
;* Un buffer pour sauver les registres
;*-----------------------------------------------------------------------------
;SAVE_AGU	ds	3*8	
;SAVE_ALU	ds	6+4
;SAVE_LA		ds	1
;SAVE_LC		ds	1
;SAVE_SSL	ds	1	
;SAVE_SSH	ds	1	
;SAVE_SP		ds	1
;SAVE_SS		ds	15*2
;------------------------------------------------------------------------------
HOST_BUF	dc	'CTK'
		ds	5

;-----------------------------------------------------------------------------
; MAGIE !! MAGIE !! 
;-----------------------------------------------------------------------------
		dc	$5b042e,$312e02
DMSP		dc	$00359F,$0078BA
;-----------------------------------------------------------------------------


END_DEBUG



