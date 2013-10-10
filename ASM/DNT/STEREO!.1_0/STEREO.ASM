;=========================================================================;
;                            Real Stereo Machine !                        ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;======================================================= Version 1.0 =====;
	NOLIST
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; D‚finitions standards, hors listing de d‚buggage ;;;;;;;;;;;;;;;;;;
	include	'ioequ.asm'
	include	'intequ.asm'
	include	'readwrit.asm'
	himem	x:$3fff,y:$3fff,p:$7fff
	OPT	W

R_S_D	ident	1,0	;Correction de la fausse st‚r‚o...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BuffSiz	equ	4096	;1024 mots de r‚ception st‚r‚o
Delay	equ	32	;D‚lai de st‚r‚o (32 couples, environ 38cm … 25Khz)
Ampl	equ	0.45	;45% du signal initial...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	org	x:0
Buffers	dsm	BuffSiz
	baddr	m,2
Offsets	dc	((-2*Delay)&-2)+1
	dc	((-2*Delay)&-2)-1
	baddr	m,8
X_Fir	dc	-901,0.40*1
	dc	-1200,0.16*1
	dc	-451,0.49*1
	dc	-600,0.14*1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Drivers d'interruption ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org	p:$0			;
	jmp	<P_begin			;

	org	p:I_SSIRD			;
	movep	x:<<M_RX,x:(r3)+		;Reception SSI du DMA
	nop				;
	movep	x:<<M_SR,x:(r3)+		;Reception en overrun
	movep	x:<<M_RX,x:(r3)+

	jsr	>Trans_Stereo		;
	movep	x:<<M_SR,y:(r7)+		;
	jsr	<Trans_Stereo		;

	org	p:I_HSTUC0			;
	jsr	>Set_Stereo		;Enhanced Stereo
	jsr	>Set_Mono			;Enhanced Mono
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Pr‚paration de la SSI ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org	p:$40
P_begin	movep	#1,x:<<M_PBC		;Host enable
	movep	#B_HCIE,x:<<M_HCR		;Host Command
	movep	#B_SSL|B_HPL0,x:<<M_IPR	;SSI en IPL3, Host en IPL1
	movep	#$4100,x:<<M_CRA		;SSI en 2 mots/frame, 16 bits
	movep	#$0800,x:<<M_CRB		;SSI off
	movep	#$01f8,x:<<M_PCC		;Port C en SSI
	movep	#$0008,x:<<M_PCDDR		;Idem

	movem	p:I_HSTUC4,b0		;
	movem	b0,p:I_HSTUC5		;
	move	#<Set_50,b0		;
	movem	b0,p:1+I_HSTUC5		;

	move	#Buffers+16,r3		;r‚ception un peu en avance
	move	#Buffers,r7		;sur l'‚mission.
	move	#BuffSiz-1,m3		;
	move	m3,m7			;Installe buffers & modulo.
	andi	#$f3,mr			;En Stereo, pas de scaling...

	move	#X_Fir,r6			;
	move	#<8-1,m6			;4 coefficients

	move	#-1,m0			;R0,M0,N0 pour divers travaux
	
	clr	a			;
	.loop	#BuffSiz/2			;
	move	a,l:(r3)+			;Plouf, init les buffers
	move	a,l:(r3)+			;
	.endl				;
	move	#1.0-Ampl,x0		;Amplitude du d‚lai.
	move	#Ampl,x1			;-> x0=part dominante, x1=feedback st‚r‚o
	
	andi	#%11110000,mr		;Vroom, autorise tout le monde.
	movep	#$f800,x:<<M_CRB		;Lance la SSI

	jmp	<*			;Attendre que ‡a se passe !

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Trans_Stereo
	jset	#M_TFS,x:<<M_SR,_right 	;Frame Sync ?
_left	move	x:(r7+n7),y0		;
	mpy	x1,y0,a	x:(r7)+,y0		;b=feedback droit
	macr	x0,y0,a	x:Offsets+1,n7	; +dominant gauche
	movep	a,x:<<M_TX			;
	rti
_right	move	x:(r7+n7),y0		;
	mpy	x1,y0,a	x:(r7)+,y0		;b=feedback gauche
	macr	x0,y0,a	x:Offsets,n7	; +dominant droit
	movep	a,x:<<M_TX			;
	rti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Trans_Mono	move	x:(r6)+,n7			;Delai et coefficient du
	move	x:(r6)+,y1			;feedback.
	move	x:(r7),y0			;R‚cupere signal (mono!)
	mpy	y1,y0,a	x:(r7+n7),y0	;
	add	y0,a	y:(r7+n7),y0	;Que l'on bidouille, avec un
	macr	-y1,y0,a	x:(r6)+,n7		;plusieurs feedback entrelac‚s.
	move	x:(r6)+,y1			;
	move	x:(r7+n7),y0		;
	macr	y1,y0,a			;
	
	move	a,y:(r7)+			;Scaling Down ==>> a/2
	movep	a,x:<<M_TX			;Car on a arrive … un intervale
	rti				;environ [-2,2[

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IT_Stereo	jsr	<Trans_Stereo		;
IT_Mono	jsr	<Trans_Mono		;

Set_Stereo	move	#<Trans_Stereo,b0
	andi	#$f3,mr
	movem	b0,p:<I_SSITD+1
	movem	p:IT_Stereo,b0
	movem	b0,p:<I_SSITD+3
	ReadHost	n0
	move	#<Set_Adr,r0
	nop
	movem	p:(r0+n0),r0
	nop
	jmp	(r0)
Set_Adr	dc	Set_030
	dc	Set_12
	dc	Set_25
	dc	Set_50
Set_12	move	#>((-Delay/2)&-2)+1,b1
	move	#>((-Delay/2)&-2)-1,b0
	jmp	<Set_it
Set_25	move	#>((-Delay)&-2)+1,b1
	move	#>((-Delay)&-2)-1,b0
	jmp	<Set_it
Set_030	
Set_50	move	#>((-Delay*2)&-2)+1,b1
	move	#>((-Delay*2)&-2)-1,b0
Set_it	move	b1,x:Offsets
	move	b0,x:Offsets+1
	rti


Set_Mono	move	#<Trans_Mono,b0
	ori	#$04,mr
	movem	b0,p:<I_SSITD+1
	movem	p:IT_Mono,b0
	movem	b0,p:<I_SSITD+3
	rti
