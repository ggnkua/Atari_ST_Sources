;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*							*
;*		        DSP-replay routine			*
;*		for Graoumf Tracker modules (.GT2)		*
;*			 Falcon 030			*
;*		          Code DSP 56001			*
;*							*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;* Version        : 4/11/1996, v0.87				*
;* Tab setting    : 11					*
;* Fichier g‚n‚r‚ : PLAYDSP (… convertir en .LOD puis en .P56)		*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight L. de Soras 1994-96*
;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

; Ne jamais mettre de e accent grave sous peine d'erreur de compilation

; This mixer is adapted by earx.
; Optimised for size and speed.
; Multitasked DSP is possible.
;
; Beware: using multitasking, implies _not_ using the following:
; - r4/m4, used for transmitting samples in interrupt
; - X:$3BB0 - X:$4000, used for storing samples from cpu
; - Y:$2D40 - Y:$4000, contains doublebuffers for mixing

;*~~~ Constantes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

PLAYDSP:
;	Ident	$0,$8700	; Graoumf Tracker - by Laurent de SORAS (Dumbo/BiG NoZ) 94-96

;	Opt	il		; Supprime l'affichage du listing

PBC:		=	$ffe0
PCC:		=	$ffe1
; Host
HSR:		=	$ffe9
HRX:		=	$ffeb
HTX:		=	$ffeb
; SSI
CRA:		=	$ffec
CRB:		=	$ffed
SSISR:		=	$ffee
RX:		=	$ffef
TX:		=	$ffef
; Interruptions
BCR:		=	$fffe
IPR:		=	$ffff

YMEM_ORG:	=	$4000-4800


;*~~~ Macros ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

readhost:	Macro
	jclr	#0,x:<<HSR,*
	movep	x:<<HRX,\1
	EndM

writhost:	Macro
	jclr	#1,x:<<HSR,*
	movep	\1,x:<<HTX
	EndM



;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Org	x:0

numsam:		Dc	0	; Num‚ro du sample
frequence:		Ds	2	; Fr‚quence du sample … mixer
finepos:		Ds	1	; 1/65536 de position
balance:		Ds	1	; Balance
volume_g:		Ds	1	; Volume (g‚n‚ral ou gauche)
volume_d:		Ds	1	; Volume droit
flag_interpol:	Dc	0	; 0 = pas d'interpolation au mixage
adrbuf:		Ds	1	; Adresse du buffer courant
taille_b1:		Dc	983	; Taille du buffer en cours de mixage
taille_b2:		Dc	983	; Taille du buffer en cours de replay
cst_left:		Dc	0	; Valeur … additionner … gauche … la fin du mixage
cst_right:		Dc	0	; Valeur … droite
realtime_flag:	Dc	1	; 1 = temps r‚el, 0 sinon
cpu_pourcent:	Dc	0	; Pourcentage (0-100 ou +) de temps machine utilis‚.
				; 255 = surcharge des voies (d‚gradation du son)
cpu_overflow:	Dc	0	; 1 = Surcharge du CPU
save_reg:		Ds	6	; Sauvegarde des registres

tmp_buffer:	; On entrepose ici diverses donn‚es temporaires
adr_parity:
adr_buffer:
		Ds	1
amplification:
		Ds	1

resend1:	DS	1
resend2:	DS	1
sauve:		DS	30

		ORG	X:$4000-1200

sambuf:		DS	1200				; Buffer de r‚ception des samples



;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Org	y:YMEM_ORG	; On commence ici car il faut de la place si la longueur
			; du programme est > $200 (pour xxxx>$200, p:xxxx = y:xxxx)

mixbuf1:	Ds	1200*2	; Buffers stereo de mixage
mixbuf2:	Ds	1200*2
mixbuf3:


;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Org	p:$0
	jmp	<debut

	Org	p:$10
	movep	y:(r4)+,x:<<TX	; Emission SSI
	nop

	Org	p:$12
	movep	y:(r4)+,x:<<TX	; Emission SSI avec erreur d'underrun
	nop

	Org	p:$40		; D‚but du programme

;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage						*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
mixer:

;--- Regarde d'abord si on est en overflow -----------------------------------

; V‚rifie qu'on n'a pas pris trop de temps (d‚bordement du pointeur replay au
; del… du buffer). Si c'est le cas, on le repositionne au d‚but du buffer
; qu'il ‚tait normalement en train de jouer.

	move	x:<realtime_flag,a0	; Si on n'est pas en temps r‚el,
	jclr	#0,a0,_ok		; pas besoin de v‚rifier

	move	x:<taille_b2,b
	lsl	b	x:<adrbuf,a
	move	#>mixbuf1,x0
	cmp	x0,a
	jne	<_buf2
	move	#>mixbuf2,a	; Premier buffer
	jmp	<_tst
_buf2:	move	#>mixbuf1,a	; Deuxieme buffer
_tst:	move	a,x:<adr_buffer
	add	b,a	r4,b
	cmp	a,b		; On a d‚pass‚ ?
	jmi	<_ok
	move	x:<adr_buffer,r4	; Oui, corrige
	bset	#0,x:<cpu_overflow	; On va le dire … la maŒtresse
_ok:

;--- Mixage ------------------------------------------------------------------

	move	#<volume_g,r1
	move	x:<adrbuf,r5
	move	#>2,n5
	move	x:(r1),y0
	move	x:<taille_b1,n7
	move	#>sambuf,a
	move	x:<finepos,a0
	move	a1,r0
	move	x:<flag_interpol,b
	tst	b
	jne	<mix_interpolate
	move	x:<numsam,b
	tst	b		#<0,x0
	jeq	<premier		; C'est le premier sample?
	move	x:<balance,b	; La balance, svp
	cmp	x0,b		#>$7ff800,x0
	jeq	<mix_gauche
	cmp	x0,b		#>$400000,x0
	jeq	<mix_droite
	cmp	x0,b
	jeq	<mix_milieu

mix_quelconque:
	move			b,x0
	mpy	x0,y0,a		(r1)+
	move			a,x:(r1)-		; Volume droit
	move	#$7fffff,a
	sub	b,a
	move			a,x0
	mpy	x0,y0,a
	move			a1,x:(r1)		; Volume gauche

	move			#<frequence,r3			; r3 pointe sur la frequence
	move			x:(r1)+,x1			; left volume
	move			x:(r3)+,y1			; integer add
	move			#>sambuf,a
	move			x:<finepos,a0
	move			a1,r0

	do	n7,m_q_loop
	move			x:(r0),x0	y:(r5),b
	mac	x1,x0,b		x:(r3),y0
	move					b,y:(r5)+
	add	y,a		x:(r1)-,x1	y:(r5),b
	mac	x1,x0,b		a1,r0
	move			x:(r1)+,x1	b,y:(r5)+
m_q_loop:
	jmp	<mix_fin

mix_milieu:			; Balance au milieu
	tfr	y0,b		x:<frequence,y1
	asr	b		x:<frequence+1,y0
	move	b,x0
	do	n7,m_m_loop
	add	y,a		x:(r0),x1	y:(r5),b	; Position suivante
	mac	x0,x1,b						; volume
	move					b,y:(r5)+	; Sur la voie gauche
	move					y:(r5),b	; On refait le volume, pour la droite cette fois
	mac	x0,x1,b		a1,r0				; et le mixage, sans oublier d'ajourner r0
	move					b,y:(r5)+	; Hop sur la voie droite
m_m_loop:
	jmp	<mix_fin

mix_gauche:							; Balance … gauche
	move			y0,x0
	move			x:<frequence,y1
	move			x:<frequence+1,y0
	do	n7,m_g_loop
	add	y,a		x:(r0),x1	y:(r5),b	; Position suivante
	mac	x0,x1,b		a1,r0				; volume
	move					b,y:(r5)+n5	; Sur la voie gauche
m_g_loop:
	jmp	<mix_fin

mix_droite:							; Balance … droite
	move			y0,x0
	move			x:<frequence,y1
	move			x:<frequence+1,y0
	move			(r5)+
	do	n7,m_d_loop
	add	y,a		x:(r0),x1	y:(r5),b	; Position suivante
	mac	x0,x1,b		a1,r0				; volume
	move					b,y:(r5)+n5	; Sur la voie droite
m_d_loop:
	jmp	<mix_fin


;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage - premiere voie				*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
premier:
	move			x:<balance,b			; La balance
	tst	b		#>$7ff800,x0
	jeq	<put_gauche
	cmp	x0,b		#>$400000,x0
	jeq	<put_droite
	cmp	x0,b
	jeq	<put_milieu

put_quelconque:
	move			b,x0
	mpy	x0,y0,a		(r1)+
	move			a,x:(r1)-			; Volume droit
	move			#$7fffff,a
	sub	b,a
	move			a,x0
	mpy	x0,y0,a
	move			a1,x:(r1)			; Volume gauche

	move			#<frequence+1,r3		; r3 pointe sur la frequence
	move			#>sambuf,a
	move			x:<finepos,a0
	move			x:(r3)-,x0
	move			x:(r3),x1
	move			a1,r0				; On fixe r0 maintenant car
	add	x,a		x:(r1)+,x1			; on est oblig‚ d'incr‚menter A … l'avance

	do	n7,p_q_loop
	move			x:(r0),y0
	mpy	y0,x1,b		x:(r1)-,x1
	mpy	y0,x1,b		x:(r3),x1	b,y:(r5)+
	add	x,a		a1,r0
	move			x:(r1)+,x1	b,y:(r5)+
p_q_loop:
	jmp	<mix_fin

put_milieu:							; Balance au milieu
	tfr	y0,b		x:<frequence,x1
	asr	b		x:<frequence+1,x0
	move			b,y0
	do	n7,p_m_loop
	add	x,a		x:(r0),y1			; Position suivante
	mpy	y0,y1,b		a1,r0				; volume
	move					b,y:(r5)+	; Sur la voie gauche
	move					b,y:(r5)+	; ...et la droite
p_m_loop:
	jmp	<mix_fin

put_gauche:
	move			y0,x0
	move			a1,r0
	move			x:<frequence,y1
	move			x:<frequence+1,y0
	move			x:(r0),x1
	mpy	x0,x1,b		#<0,r1
	do	n7,p_g_loop
	add	y,a		x:(r0),x1	b,y:(r5)+
	mpy	x0,x1,b		a1,r0
	move					r1,y:(r5)+
p_g_loop:
	jmp	<mix_fin

put_droite:
	move			y0,x0
	move			x:<frequence,y1
	move			x:<frequence+1,y0
	move			a1,r0
	move			#<0,r1
	add	y,a		x:(r0),x1
	do	n7,p_d_loop
	move			a1,r0
	mpy	x0,x1,b				r1,y:(r5)+
	add	y,a		x:(r0),x1	b,y:(r5)+
p_d_loop:
	jmp	<mix_fin


;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage avec interpolation				*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
mix_interpolate:
	move			x:<numsam,b
	tst	b
	jeq	<premier_i					; C'est le premier sample?
	move			x:<balance,b			; La balance, svp

mix_i_quelconque:
	move			b,x0
	mpy	x0,y0,a		(r1)+				; r1 pointe sur le volume droit
	move			a,x:(r1)-			; Volume droit
	move			#$7fffff,a
	sub	b,a
	move			a,x0
	mpy	x0,y0,a
	move			a1,x:(r1)			; Volume gauche

;--- 1ere passe: interpolation avec les samples … gauche des points ----------
	move			#<frequence+1,r3		; r3 pointe sur la frequence
	move			x:(r1)+,x1
	move			x:(r3)-,x0
	move			#>sambuf,a
	move			x:<finepos,a0
	move			a1,r0

	do	n7,m_i_q_loopa
	move			a0,b				; Coef d'interpolation
	not	b						; 0.99999999 - coef
	lsr	b		x:(r0),y1			; Passe en 47 bits - prend le sample
	move			b1,y0
	mpy	y0,y1,b						; Interpolation
	move			b1,y1				; y1 contient le sample interpol‚ mais non "volum‚"
	mpy	y1,x1,b		x:(r3),x1	y:(r5)+,y0
	add	x,a		x:(r1)-,x1
	add	y0,b				y:(r5)-,y0
	mpy	y1,x1,b		x:(r1)+,x1	b,y:(r5)+
	add	y0,b		a1,r0
	move					b,y:(r5)+
m_i_q_loopa:

;--- 2eme passe: interpolation avec les samples … droite des points ----------
m_i_q_droite:
	move			#>sambuf+1,a
	move			x:<finepos,a0
	move			a1,r0
	move			x:<adrbuf,r5
	move			x:<taille_b1,n7

	do	n7,m_i_q_loopb
	move			a0,b1				; Coef d'interpolation
	lsr	b		x:(r0),y1			; Passe en 47 bits - prend le sample
	move			b1,y0
	mpy	y0,y1,b						; Interpolation
	move			b,y1				; y1 contient le sample interpol‚ mais non "volum‚"
	mpy	y1,x1,b		x:(r3),x1	y:(r5)+,y0
	add	x,a		x:(r1)-,x1
	add	y0,b				y:(r5)-,y0
	mpy	y1,x1,b		x:(r1)+,x1	b,y:(r5)+
	add	y0,b		a1,r0
	move					b,y:(r5)+
m_i_q_loopb:
	jmp	<mix_fin

;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage avec interpolation - premiere voie			*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
premier_i:
	move			x:<balance,b			; La balance

put_i_quelconque:
	move			b,x0
	mpy	x0,y0,a		(r1)+
	move			a,x:(r1)-			; Volume droit
	move			#$7fffff,a
	sub	b,a
	move			a,x0
	mpy	x0,y0,a
	move			a1,x:(r1)			; Volume gauche

;--- 1ere passe: interpolation avec les samples … gauche des points ----------
	move			#<frequence+1,r3		; r3 pointe sur la frequence
	move			#>sambuf,a
	move			x:<finepos,a0
	move			x:(r3)-,x0

	do	n7,p_i_q_loopa
	move			a0,b				; Coef d'interpolation: fraq(a)
	not	b		a1,r0				; (0.99999999 - coef) en 48 bits (pas de signe)
	lsr	b						; Passe en 47 bits (car mpy est sign‚) - Prend le sample
	move			b1,y0
	move			x:(r0),x1
	mpy	y0,x1,b		x:(r3),x1			; Interpolation
	add	x,a		x:(r1)+,x1	b,y1		; y1 contient le sample interpol‚ mais non "volum‚"
	mpyr	y1,x1,b		x:(r1)-,x1			; Volume le sample gauche - prend le volume droit
	mpyr	y1,x1,b				b,y:(r5)+	; Volume le sample droit - reprend la fr‚quence mot fort
	move					b,y:(r5)+	; Incr‚mente le pas
p_i_q_loopa:

;--- 2eme passe: interpolation avec les samples … droite des points ----------
	move			x:(r1)+,x1
	jmp	<m_i_q_droite


;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage sans resampling				*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
resampling030:
	move	x:<adrbuf,r5
	move	#<2,n5
	move	#<tmp_buffer,r0
	move	x:<taille_b1,n7
	move	x:<volume_g,y0

	readhost	a		; a = multiplicateur 8 ou 16 -> 24 bits
	move	x:<amplification,b	; Doit-on faire une amplification du sample?
	tst	b
	jeq	<_no_amp
	rep	b		; *** Ne peut pas ˆtre interrompu
	asl	a
_no_amp:
	move	a,x0		; x0 devient le multiplicateur -> 24 bits

	move	x:<numsam,b
	tst	b		#<0,x1
	jeq	<premier030		; C'est le premier sample?
	move	x:<balance,b	; La balance, svp
	cmp	x1,b		#>$7ff800,x1
	jeq	<mix_gauche030
	cmp	x1,b		#>$400000,x1
	jeq	<mix_droite030
	cmp	x1,b
	jeq	<mix_milieu030

mix_quelconque030:
	move			b,x1
	mpy	x1,y0,a
	move			a,y1		; Volume droit
	move			#$7fffff,a
	sub	b,a
	move			a,x1
	mpy	x1,y0,a
	move			a,x1		; Volume gauche

	do	n7,m_q_loop030
	readhost	y0
	mpy	x0,y0,a				y:(r5)+,b
	move			a0,y0
	mac	y0,x1,b				y:(r5)-,a
	mac	y0,y1,a				b,y:(r5)+
	move					a,y:(r5)+
m_q_loop030:
	jmp	<mix_fin

mix_milieu030:							; Balance au milieu
	move			y0,b
	asr	b
	move			b,x1				; center volume

	do	n7,m_m_loop030
	readhost	y0
	mpy	x0,y0,a				y:(r5)+,b
	move			a0,y0
	mac	y0,x1,b				y:(r5)-,a
	mac	y0,x1,a				b,y:(r5)+
	move					a,y:(r5)+
m_m_loop030:
	jmp	<mix_fin

mix_gauche030:							; Balance … gauche
	do	n7,m_g_loop030
	readhost	y1
	mpy	x0,y1,a				y:(r5),b
	move			a0,y1
	mac	y0,y1,b						; volume
	move					b,y:(r5)+n5	; Sur la voie gauche
m_g_loop030:
	jmp	<mix_fin

mix_droite030:							; Balance … droite
	move			(r5)+,r5
	do	n7,m_d_loop030
	readhost	y1
	mpy	x0,y1,a				y:(r5),b
	move			a0,y1
	mac	y0,y1,b						; volume
	move					b,y:(r5)+n5	; Sur la voie droite
m_d_loop030:
	jmp	<mix_fin

premier030:
	move			x:<balance,b			; La balance
	move	#<0,x1
	cmp	x1,b
	jeq	<put_gauche030
	move			#>$7ff800,x1
	cmp	x1,b
	jeq	<put_droite030
	move			#>$400000,x1
	cmp	x1,b
	jeq	<put_milieu030

put_quelconque030:
	move			b,x1
	mpy	x1,y0,a
	move			a,y1				; Volume droit
	move			#$7fffff,a
	sub	b,a
	move			a,x1
	mpy	x1,y0,a
	move			a,x1				; Volume gauche

	do	n7,p_q_loop030
	readhost	y0
	mpy	x0,y0,a
	move			a0,y0
	mpy	y0,x1,b
	mpy	y0,y1,b				b,y:(r5)+
	move					b,y:(r5)+
p_q_loop030:
	jmp	<mix_fin

put_milieu030:						; Balance au milieu
	move			y0,b
	asr	b
	move			b,y0

	do	n7,p_m_loop030
	readhost	y1
	mpy	x0,y1,a
	move			a0,y1
	mpy	y0,y1,b						; volume
	move					b,y:(r5)+	; Sur la voie gauche
	move					b,y:(r5)+	; ...et la droite
p_m_loop030:
	jmp	<mix_fin

put_gauche030:							; Balance … gauche
	move			#<0,x1
	do	n7,p_g_loop030
	readhost	y1
	mpy	x0,y1,a		(r5)+
	move			a0,y1
	mpy	y0,y1,b				x1,y:(r5)-	; Deleter les droites fromage.
	move					b,y:(r5)+n5	; Sur la voie gauche.
p_g_loop030:
	jmp	<mix_fin

put_droite030:							; Balance … droite
	move			#<0,x1
	do	n7,p_d_loop030
	readhost	y1
	mpy	x0,y1,a				x1,y:(r5)+
	move			a0,y1
	mpy	y0,y1,b		a1,r0				; volume
	move					b,y:(r5)+	; Sur la voie droite
p_d_loop030:

mix_fin:
	move	x:<numsam,a1	; Sample suivant
	move	#>$1,x0
	add	x0,a
	move	a1,x:<numsam
	jmp	<wait_cmd


;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Initialisation					*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
debut:
	move	#>$ffff,m0
	move	m0,m1
	move	m0,m4
	move	m0,m5
	clr	a		#>mixbuf1,r4
	move			#<save_reg,r0			; Sauve les registres d'interruptions et de communication

	rep	#mixbuf2-mixbuf1
	move			a,y:(r4)+

	rep	#mixbuf3-mixbuf2
	move			a,y:(r4)+

	movep	x:<<CRA,x:(r0)+
	movep	x:<<PCC,x:(r0)+
	movep	x:<<PBC,x:(r0)+
	movep	x:<<BCR,x:(r0)+
	movep	x:<<IPR,x:(r0)+
	movep	x:<<CRB,x:(r0)+
	movep	#>$4100,x:<<CRA	; Configuration SSI
	movep	#>$1f8,x:<<PCC
	btst	#4,x:<<SSISR
	movep	#>$1,x:<<PBC
	movep	#>$0,x:<<BCR
	movep	#>$3800,x:<<IPR	; IPL 3 pour l'interruption SSI
	move	#>mixbuf2,x0
	move	x0,x:<adrbuf	; Buffer courant de mixage

	readhost	a1		; attend le signal de d‚part...
	move	#>mixbuf1,r4
	movep	#>$5800,x:<<CRB	; Autorise l'envoi de donn‚es sous interruptions
	andi	#<$FC,mr		; Toutes les interruptions sont autoris‚es



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Routine de soundtracking				*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

; Attente d'une commande
receive_loop:
	move	x:<taille_b1,a
	clr	a	a,x:<taille_b2
	move	a,x:<numsam		; Sample 0
	move	a,x:<cst_left
	move	a,x:<cst_right	; R‚initialise les constantes de mixage
wait_cmd:
	move	x:<cpu_pourcent,x0	; Signale au 030 qu'on attend une commande
	writhost	x0		; en renvoyant du mˆme coup le pourcentage de temps machine
wait_cmd2:
	readhost	a0		; a0 = Num‚ro de fonction

	jset	#0,a0,receive	; Bit 0: Recevoir un sample
	jset	#1,a0,rec_end	; Bit 1: Fin des samples
	jset	#2,a0,eff_gadr	; Bit 2: Fin des samples et efface les deux voies
	jset	#3,a0,coupe_son	; Bit 3: C'est fini, on s'en va
	jset	#4,a0,receive_cst	; Bit 4: Recevoir un sample constant
	jset	#5,a0,tick_length	; Bit 5: Indiquer la longueur d'un tick

	jset	#6,a0,no_realtime_rec	; Bit 6: Simple mixage et export des donn‚es
	jset	#7,a0,bck_to_realtime	; Bit 7: Retour … la normale

	jmp	<wait_cmd



;--- Indication de la longueur d'un tick -------------------------------------

tick_length:
	readhost	x:taille_b1	; Nombre d'‚chantillons ds la VBL
	jmp	<wait_cmd2		; Une autre commande ?



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	R‚ception des samples					*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
receive:
	readhost	x:volume_g		; Volume
	readhost	x:amplification	; Amplification
	readhost	x:balance		; Balance
	readhost	a0		; Re‡oit la fr‚quence, mot fort
	jset	#23,a0,resampling030
	move	a0,x:<frequence
	readhost	x:frequence+1	; Fr‚quence, mot faible
	readhost	x:finepos		; Position pr‚cise
	readhost	x:flag_interpol	; Interpolation ?
	readhost	a		; R‚solution des samples
	move	#>$2,x0
	cmp	x0,a
	jeq	<rec_16bits

rec_8bits:				; Samples 8 bits
	readhost	n7		; n7 = Nombre de mots (2 samples) -1 … recevoir
	readhost	x:adr_parity	; Adresse paire ou impaire ?
	move	#>sambuf,r0	; r0 pointe le buffer de r‚ception
	move	#>sambuf+1,r1
	move	#<2,n0
	move	n0,n1

	move	#>$8000,x1		; Pour recalibrer de 8 en 24 bits
				; Ici on ne fait pas d'amplification parceque
				; 1) Ca ne peut pas ˆtre utile sur du 8 bits
				; 2) C'est pas du tout pratique … faire

	move	x:<adr_parity,a
	tst	a
	jeq	<r8_paire
	readhost	x0		; Adresse 030 impaire, on prend une
	mpy	x0,x1,a	(r1)+	; donn‚e suppl‚mentaire
	move	a0,x:(r0)+
r8_paire:				; L… on va vraiment transf‚rer...
	readhost	x0			; Les 2 premiers samples
	mpy	x0,x1,a			; a0 contient le sample 2 en 24 bits
	move	a1,x0			; a1 sample 1 en 8 bits
	mpy	x0,x1,b	a0,x:(r1)+n1	; b0 sample 1 en 24 bits
	do	n7,r8_transloop		; Les autres samples
	readhost	x0			; 2 samples dans x0
	mpy	x0,x1,a	b0,x:(r0)+n0
	move	a1,x0
	mpy	x0,x1,b	a0,x:(r1)+n1
r8_transloop:
	move	b0,x:(r0)+n0	; M‚morise le dernier sample...
	jmp	<mixer

rec_16bits:			; R‚ception de samples 16 bits
	readhost	n7		; n7 = Nombre de mots (1 sample) -1 … recevoir
	move	#>sambuf,r0	; r0 pointe le buffer de r‚ception

	move	#>$80,a		; R‚ajusteur de 16 en 24 bits
	move	x:<amplification,b	; Doit-on faire une amplification du sample?
	tst	b		; Si le sample est trop faible, on peut le suramplifier
	jeq	<_no_amp
	rep	b		; *** Ne peut pas ˆtre interrompu
	asl	a
_no_amp:
	move	a,x1

	readhost	x0		; Le premier sample...
	mpy	x0,x1,a
	do	n7,r16_transloop
	readhost	x0		; ... Les autres...
	mpy	x0,x1,a	a0,x:(r0)+
r16_transloop:
	move	a0,x:(r0)+		; ... Et hop, le dernier sample
	jmp	<mixer

receive_cst:			; R‚ception d'un sample constant
	readhost	y0		; y0 = volume
	readhost	b		; b = balance
	move	#<cst_left,r1
	move	b,x0
	mpy	x0,y0,a
	move	a,y1		; y1 = volume droit
	move	#$7fffff,a
	sub	b,a
	move	a,x0
	mpy	x0,y0,a
	move	a1,x1		; x1 = volume gauche
	readhost	y0		; Le sample
	mpy	y0,x1,a		x:(r1)+,b	; Mixe les constantes
	add	b,a		x:(r1)-,b
	mac	y0,y1,b		a,x:(r1)+
	move			b,x:(r1)
	jmp	<wait_cmd2		; C'‚tait tout, et ‡a comptait mˆme pas pour
				; un sample. Donc pas de nouvelle interruption
				; puisqu'on ne sort pas de la routine 030.






;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Fin : mixage des constantes avec fade vers 0		*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
rec_end:
	move	x:<taille_b1,n7
	move	x:<adrbuf,r5
	move	x:<cst_left,x0
	move	x:<cst_right,x1
	move	#0.995,y0
	do	n7,addcst_loop
	mpy	x0,y0,b				y:(r5)+,a
	mpy	x1,y0,b		b,x0
	add	x0,a		b,x1		y:(r5)-,b
	add	x1,b				a,y:(r5)+
	move					b,y:(r5)+
addcst_loop:



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Attend le moment de recuperer le prochain bloc de samples	*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
wait_next_frame:
	move	x:<realtime_flag,a0
	jclr	#0,a0,no_realtime_send

	move	x:<taille_b2,b
	lsl	b	x:<adrbuf,a
	move	b,x1
	move	r4,b
	move	#>mixbuf1,x0
	cmp	x0,a
	jne	<wait_buf2

;--- Attend le d‚but du premier buffer ---------------------------------------

	move	#>mixbuf2,a
	sub	a,b
	move	b,x:<cpu_pourcent
	add	x1,a	r4,b
	cmp	a,b	r4,b
	jpl	<_overflow
_loop:
	cmp	a,b	r4,b
	jmi	<_loop
_loop_end:	move	#>mixbuf1,r4
	move	#>mixbuf2,x0
	move	x0,x:<adrbuf
	jmp	<calc_cpu_pourcent

_overflow:
	bset	#0,x:<cpu_overflow
	jmp	<_loop_end

;--- Attend le d‚but du deuxieme buffer --------------------------------------

wait_buf2:
	move	#>mixbuf1,a
	sub	a,b
	move	b,x:<cpu_pourcent
	add	x1,a	r4,b
	cmp	a,b	r4,b
	jpl	<_overflow
_loop:
	cmp	a,b	r4,b
	jmi	<_loop
_loop_end:	move	#>mixbuf2,r4
	move	#>mixbuf1,x0
	move	x0,x:<adrbuf
	jmp	<calc_cpu_pourcent

_overflow:
	bset	#0,x:<cpu_overflow
	jmp	<_loop_end

;--- Calcul du temps machine utilis‚ -----------------------------------------

calc_cpu_pourcent:
	jset	#0,x:<cpu_overflow,_overflow
	move	x:<taille_b1,b
	asl	b		; * 2 pour convertir en stereo
	asl	b		; * 2 encore au cas o— cpu_pourcent >= taille_b1
	move	x:<cpu_pourcent,a
	move	b,x0
	andi	#$FE,ccr
	do	#24,_loop
	div	x0,a
_loop:
	move	#>100*2,x0		; * 2 pour corriger le 2eme asl b
	move	a0,x1
	mpy	x0,x1,a		; Conversion en pourcentage
	move	a,x:<cpu_pourcent
	jmp	<receive_loop

_overflow:
	clr	a
	move	a,x:<cpu_overflow
	move	#>255,a
	move	a,x:<cpu_pourcent
	jmp	<receive_loop



;--- Efface les voies (met les constantes) -----------------------------------

eff_gadr:
	move	x:<adrbuf,r5
	move	x:<cst_left,a
	move	x:<cst_right,b
	do	#(mixbuf2-mixbuf1)/2,_loop
	move	a,y:(r5)+
	move	b,y:(r5)+
_loop:
	jmp	<wait_next_frame

coupe_son:				; L… c'est quand on se tire
	move	#<save_reg,r0	; Remet la valeur d'origine des registres E/S
	nop
	movep	x:(r0)+,x:<<CRA
	movep	x:(r0)+,x:<<PCC
	movep	x:(r0)+,x:<<PBC
	movep	x:(r0)+,x:<<BCR
	movep	x:(r0)+,x:<<IPR
	movep	x:(r0)+,x:<<CRB
	jmp	*		; On attend que ‡a se passe...



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Enregistrement de la musique sans ecoute			*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
no_realtime_rec:
	clr	a
	move	a,x:<realtime_flag	; On n'est plus en temps reel
	movep	#>$0800,x:<<CRB	; Cloue le bec … la SSI
	jmp	<wait_cmd

no_realtime_send:

;--- Positionne r4 sur le d‚but du buffer QU'ON VIENT DE MIXER ---------------

	move	x:<adrbuf,a
	move	a,r4

;--- Envoie le r‚sultat du mixage au 030 -------------------------------------

	move	x:<taille_b1,a	; Nombre de paquets de 2 samples: stereo
	writhost	a
	do	a,_sendloop
	move	y:(r4)+,x0		; Gauche
	writhost	x0
	move	y:(r4)+,x0		; Droit
	writhost	x0
_sendloop:

	readhost	a		; Attend que le 030 donne l'autorisation de repartir

;--- Change de buffer pour la prochaine fois ---------------------------------

	move	x:<adrbuf,a
	move	#>mixbuf1,x0
	cmp	x0,a
	jne	<_nextbuf1
_nextbuf2:
	move	#>mixbuf1,r4
	move	#>mixbuf2,x0
	move	x0,x:<adrbuf
	jmp	<receive_loop
_nextbuf1:
	move	#>mixbuf2,r4
	move	#>mixbuf1,x0
	move	x0,x:<adrbuf
	jmp	<receive_loop



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Repasse le DSP en mode temps r‚el			*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
bck_to_realtime:
	move	#>1,a
	move	a,x:<realtime_flag	; On n'est plus en temps reel
	movep	#>$5800,x:<<CRB	; R‚autorise l'envoi de donn‚es sous interruptions
	jmp	<wait_cmd

code_end:

;*~~~ FIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
