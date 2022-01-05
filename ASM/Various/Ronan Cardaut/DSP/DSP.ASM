HSR	equ	$ffe9	;Host Status Register
HRX	equ	$ffeb	;Host Receive Register
HTX	equ	$ffeb	;Host Transmit Register
PBC	equ	$ffe0	;Port B Control register
BCR	equ	$fffe	;Bus Control Register
HCR	EQU	$FFE8	; Host Control Register
IPR	EQU	$FFFF	; Interrupt Priority Register
CRA	equ	$ffec	;SSI control register A
CRB	equ	$ffed	;SSI control register B

rec	MACRO	dest
	jclr	#0,x:<<HSR,*
	movep	x:<<HRX,dest
	ENDM
env	MACRO	source
	jclr	#1,x:<<HSR,*
	movep	source,x:<<HTX
	ENDM

SIZE_DEBUG	equ	$300		;taille du noyau...

	org	p:$0
	jmp	INIT_WITH_PROTECT

	org	p:2
	jsr	STACK		;STACK ERROR
	
	org	p:4
	jsr	TRACE		;TRACE
	org	p:6
	jsr	SWI		;SWI
	org	p:$3e
	jsr	III		;III

	org	p:$40	
START
	jmp	*
	

	
;------------------------------------------------------------------------------
	org	p:$7ea9-SIZE_DEBUG		;7ea9= d‚but du TOS
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
	

;------------------------------------------------------------------------------
INIT	
	movep	#4,x:HCR		;autorise HC
	movep	#1,x:PBC		;Port B en mode HOST
	movep	#$c00,x:IPR		;HC PRIORITE 3 le reste coup‚
	movep	#$0,x:BCR		;0 WS


	move	#>$bf080,x0
	move	x0,p:$1e
	move	#HC_EXEP,x0
	move	x0,p:$1f		;place le jsr HC

	andi	#<%11111100,mr	;passe en IPL0
	;jmp	*


	bclr	#3,x:HCR
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
	move	#>$40,x0
	move	x0,p:1
	bclr	#3,x:HCR	;place HF2 … 0
	jmp	MAIN

;------------------------------------------------------------------------------
; arret sur STACK ERROR
;------------------------------------------------------------------------------
STACK
	bset	#3,x:HCR		;place HF2 … 1
	env	#>'CTK'
	env	#0
	jmp	SAVE_REG

;------------------------------------------------------------------------------
; arret sur TRACE
;------------------------------------------------------------------------------
TRACE
	bset	#3,x:HCR		;place HF2 … 1
	env	#>'CTK'
	env	#1
	jmp	SAVE_REG

;------------------------------------------------------------------------------
; arret sur SWI
;------------------------------------------------------------------------------
SWI
	bset	#3,x:HCR		;place HF2 … 1
	env	#>'CTK'
	env	#2
	jmp	SAVE_REG

;------------------------------------------------------------------------------
; arret sur III
;------------------------------------------------------------------------------
III
	bset	#3,x:HCR		;place HF2 … 1
	env	#>'CTK'
	env	#3
	jmp	SAVE_REG

;------------------------------------------------------------------------------
; H C =interruption par le 40
;------------------------------------------------------------------------------
HC_EXEP
	bset	#3,x:HCR		;place HF2 … 1
	env	#>'CTK'
	env	#4
	jmp	SAVE_REG


;------------------------------------------------------------------------------
; la  on sauve l'etat du CPU
;------------------------------------------------------------------------------
SAVE_REG	
	or	#3,mr		;IPL=3


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

	
	

	bclr	#3,x:HCR	;place HF2 … 0
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
	move	#STACK,x1
	move	x0,p:(r0)+
	move	x1,p:(r0)+		

	move	#4,r0		;TRACE
	move	#TRACE,x1
	move	x0,p:(r0)+
	move	x1,p:(r0)+		

	move	#6,r0		;SWI
	move	#SWI,x1
	move	x0,p:(r0)+
	move	x1,p:(r0)+		

	move	#$3e,r0		;III
	move	#III,x1
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
	nop
	
	jset	#3,x:HSR,*
	
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



