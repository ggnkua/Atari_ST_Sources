;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*							*
;*		        DSP-replay routine			*
;*		for Graoumf Tracker modules (.GT2)		*
;*			 Falcon 030			*
;*		          Code DSP 56001			*
;*							*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;* Version        : 10/12/1995, v0.742				*
;* Tab setting    : 11					*
;* Fichier g‚n‚r‚ : PLAYDSP (… convertir en .LOD puis en .P56)		*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight L. de Soras 1994-95*
;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*



;*~~~ Constantes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

PLAYDSP:	Ident	$0,$6980	; Soundtracker - by Laurent de SORAS (Dumbo/BiG NoZ) 94/95

	Opt	il		; Supprime l'affichage du listing

PBC	Equ	$ffe0
PCC	Equ	$ffe1
; Host
HSR	Equ	$ffe9
HRX	Equ	$ffeb
HTX	Equ	$ffeb
; SSI
CRA	Equ	$ffec
CRB	Equ	$ffed
SSISR	Equ	$ffee
RX	Equ	$ffef
TX	Equ	$ffef
; Interruptions
BCR	Equ	$fffe
IPR	Equ	$ffff



;*~~~ Macros ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

readhost:	Macro	param
	jclr	#0,x:<<HSR,*
	movep	x:<<HRX,param
	EndM

writhost:	Macro	param
	jclr	#1,x:<<HSR,*
	movep	param,x:<<HTX
	EndM



;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Org	x:0
numsam:		Ds	1	; Num‚ro du sample
frequence:		Ds	2	; Fr‚quence du sample … mixer
finepos:		Ds	1	; 1/65536 de position
balance:		Ds	1	; Balance
volume_g:		Ds	1	; Volume (g‚n‚ral ou gauche)
volume_d:		Ds	1	; Volume droit
flag_interpol:	Ds	1	; 0 = pas d'interpolation au mixage
adrbuf:		Ds	1	; Adresse du buffer courant
taille_b1:		Dc	983	; Taille du buffer en cours de mixage
taille_b2:		Dc	983	; Taille du buffer en cours de replay
cst_left:		Ds	1	; Valeur … additionner … gauche … la fin du mixage
cst_right:		Ds	1	; Valeur … droite
save_reg:		Ds	6	; Sauvegarde des registres
tmp_buffer:	; On entrepose ici diverses donn‚es temporaires
		Ds	1
sambuf:		Ds	8000	; Buffer de r‚ception des samples



;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Org	y:$400	; On commence … $400 car il faut de la place si la longueur
			; du programme est > $200 (pour xxxx>$200, p:xxxx = y:xxxx)
mixbuf1:	Ds	1200*2	; Buffers stereo de mixage
mixbuf2:	Ds	1200*2
mixbuf3:	Ds	1



;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	Org	p:$0
	jmp	debut

	Org	p:$10
	movep	y:(r4)+,x:<<TX	; Emission SSI
	nop

	Org	p:$12
	movep	y:(r4)+,x:<<TX	; Emission SSI avec erreur d'underrun
	nop

	Org	p:$40		; D‚but du programme



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Initialisation					*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
debut:
	move	#>$ffff,m0
	move	m0,m1
	move	m0,m4
	move	m0,m5
	clr	a	#>mixbuf1,r4
	rep	#mixbuf2-mixbuf1
	move	a1,y:(r4)+
	rep	#mixbuf3-mixbuf2
	move	a1,y:(r4)+
	move	#save_reg,r0	; Sauve les registres d'interruptions et de communication
	movep	x:<<CRA,x0
	move	x0,x:(r0)+
	movep	x:<<PCC,x0
	move	x0,x:(r0)+
	movep	x:<<PBC,x0
	move	x0,x:(r0)+
	movep	x:<<BCR,x0
	move	x0,x:(r0)+
	movep	x:<<IPR,x0
	move	x0,x:(r0)+
	movep	x:<<CRB,x0
	move	x0,x:(r0)+
	movep	#>$4100,x:<<CRA	; Configuration SSI
	movep	#>$1f8,x:<<PCC
	btst	#4,x:<<SSISR
	movep	#>$1,x:<<PBC
	movep	#>$0,x:<<BCR
	movep	#>$3800,x:<<IPR	; IPL 3 pour l'interruption SSI
	move	#>mixbuf2,x0
	move	x0,x:adrbuf	; Buffer courant de mixage

	readhost	a1		; attend le signal de d‚part...
	move	#>mixbuf1,r4
	movep	#>$5800,x:<<CRB	; Autorise l'envoi de donn‚es sous interruptions
	andi	#<$FC,mr		; Toutes les interruptions sont autoris‚es



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Routine de soundtracking				*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

; Attente d'une commande
receive_loop:
	move	x:taille_b1,a
	clr	a	a,x:taille_b2
	move	a,x:numsam		; Sample 0
	move	a,x:cst_left
	move	a,x:cst_right	; R‚initialise les constantes de mixage
wait_cmd:
	move	#>1,x0
	writhost	x0		; Signale au 030 qu'on attend une commande
wait_cmd2:
	readhost	a0		; a0 = Num‚ro de fonction

	jset	#0,a0,receive	; Bit 0 : Recevoir un sample
	jset	#1,a0,rec_end	; Bit 1 : Fin des samples
	jset	#2,a0,eff_gadr	; Bit 2 : Fin des samples et efface les deux voies
	jset	#3,a0,coupe_son	; Bit 3 : C'est fini, on s'en va
	jset	#4,a0,receive_cst	; Bit 4 : Recevoir un sample constant
	jset	#5,a0,tick_length	; Bit 5 : Indiquer la longueur d'un tick

	jmp	wait_cmd



;--- Indication de la longueur d'un tick -------------------------------------
tick_length:
	readhost	x:taille_b1	; Nombre d'‚chantillons ds la VBL
	jmp	wait_cmd2		; Une autre commande ?



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	R‚ception des samples					*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
receive:
	readhost	x:volume_g		; Volume
	readhost	x:balance		; Balance
	readhost	a0		; Re‡oit la fr‚quence, mot fort
	jset	#23,a0,resampling030
	move	a0,x:frequence
	readhost	x:frequence+1	; Fr‚quence, mot faible
	readhost	x:finepos		; Position pr‚cise
	readhost	x:flag_interpol	; Interpolation ?
	readhost	a		; R‚solution des samples
	move	#>$2,x0
	cmp	x0,a
	jeq	rec_16bits

rec_8bits:				; Samples 8 bits
	readhost	n7		; n7 = Nombre de mots (2 samples) -1 … recevoir
	readhost	x1		; Adresse paire ou impaire ?
	move	#>sambuf,r0	; r0 pointe le buffer de r‚ception
	move	#>sambuf+1,r1
	move	#2,n0
	move	n0,n1
	move	x1,a
	move	#>$8000,x1		; Pour recalibrer de 8 en 24 bits
	tst	a
	jeq	r8_paire
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
	jmp	mixer

rec_16bits:			; R‚ception de samples 16 bits
	readhost	n7		; n7 = Nombre de mots (1 sample) -1 … recevoir
	move	#>sambuf,r0	; r0 pointe le buffer de r‚ception
	move	#>$80,x1		; R‚ajusteur de 16 en 24 bits
	readhost	x0		; Le premier sample...
	mpy	x0,x1,a
	do	n7,r16_transloop
	readhost	x0		; ... Les autres...
	mpy	x0,x1,a	a0,x:(r0)+
r16_transloop:
	move	a0,x:(r0)+		; ... Et hop, le dernier sample
	jmp	mixer

receive_cst:			; R‚ception d'un sample constant
	readhost	y0		; y0 = volume
	readhost	b		; b = balance
	move	#>cst_left,r1
	move	b,x0
	mpy	x0,y0,a
	move	a,y1		; y1 = volume droit
	move	#$7fffff,a
	sub	b,a
	move	a,x0
	mpy	x0,y0,a
	move	a1,x1		; x1 = volume gauche
	readhost	y0		; Le sample
	mpy	y0,x1,a	x:(r1)+,b	; Mixe les constantes
	add	b,a	x:(r1)-,b
	mac	y0,y1,b	a,x:(r1)+
	move	b,x:(r1)
	jmp	wait_cmd2		; C'‚tait tout, et ‡a comptait mˆme pas pour
				; un sample. Donc pas de nouvelle interruption
				; puisqu'on ne sort pas de la routine 030.



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage						*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
mixer:
	move	#>volume_g,r1
	move	x:adrbuf,r5
	move	#>2,n5
	move	x:(r1),y0
	move	x:taille_b1,n7
	move	#>sambuf,a
	move	x:finepos,a0
	move	a1,r0
	move	x:flag_interpol,b
	tst	b
	jne	mix_interpolate
	move	x:numsam,b
	tst	b
	jeq	premier		; C'est le premier sample?
	move	x:balance,b	; La balance, svp
	move	#>0,x0
	cmp	x0,b
	jeq	mix_gauche
	move	#>$7ff800,x0
	cmp	x0,b
	jeq	mix_droite
	move	#>$400000,x0
	cmp	x0,b
	jeq	mix_milieu

mix_quelconque:
	move	b,x0
	mpy	x0,y0,a	(r1)+
	move	a,x:(r1)-		; Volume droit
	move	#$7fffff,a
	sub	b,a
	move	a,x0
	mpy	x0,y0,a
	move	a1,x:(r1)		; Volume gauche

	move	#>frequence+1,r3	; r3 pointe sur la frequence
	move	x:(r1)+,x1
	move	x:(r3)-,x0
	move	#>sambuf,a
	move	x:finepos,a0
	move	a1,r0

	do	n7,m_q_loop
	move	x:(r0),y0
	mpy	y0,x1,b	x:(r1)-,x1	y:(r5),y0
	add	y0,b	x:(r0),y0
	move	b1,y:(r5)+
	mpy	y0,x1,b	x:(r3),x1	y:(r5),y0
	add	x,a	a1,r0
	add	y0,b	x:(r1)+,x1
	move	b1,y:(r5)+
m_q_loop:
	jmp	mix_fin

mix_milieu:			; Balance au milieu
	move	y0,b
	asr	b
	move	b,y0	x:frequence,x1
	move	x:frequence+1,x0
	do	n7,m_m_loop
	add	x,a	x:(r0),y1	; Position suivante
	mpy	y0,y1,b	y:(r5),y1	; volume
	add	y1,b	x:(r0),y1	; mixe et reprend le sample
	move	b1,y:(r5)+		; Sur la voie gauche
	mpy	y0,y1,b	y:(r5),y1	; On refait le volume, pour la droite cette fois
	add	y1,b	a1,r0	; et le mixage, sans oublier d'ajourner r0
	move	b1,y:(r5)+		; Hop sur la voie droite
m_m_loop:
	jmp	mix_fin

mix_gauche:			; Balance … gauche
	move	x:frequence,x1
	move	x:frequence+1,x0
	do	n7,m_g_loop
	add	x,a	x:(r0),y1	; Position suivante
	mpy	y0,y1,b	y:(r5),y1	; volume
	add	y1,b	a1,r0	; mixe
	move	b1,y:(r5)+n5	; Sur la voie gauche
m_g_loop:
	jmp	mix_fin

mix_droite:			; Balance … droite
	move	x:frequence,x1
	move	x:frequence+1,x0
	lua	(r5)+,r5
	do	n7,m_d_loop
	add	x,a	x:(r0),y1	; Position suivante
	mpy	y0,y1,b	y:(r5),y1	; volume
	add	y1,b	a1,r0	; mixe
	move	b1,y:(r5)+n5	; Sur la voie droite
m_d_loop:
	jmp	mix_fin



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage - premiere voie				*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
premier:
	move	x:balance,b	; La balance
	move	#>0,x0
	cmp	x0,b
	jeq	put_gauche
	move	#>$7ff800,x0
	cmp	x0,b
	jeq	put_droite
	move	#>$400000,x0
	cmp	x0,b
	jeq	put_milieu

put_quelconque:
	move	b,x0
	mpy	x0,y0,a	(r1)+
	move	a,x:(r1)-		; Volume droit
	move	#$7fffff,a
	sub	b,a
	move	a,x0
	mpy	x0,y0,a
	move	a1,x:(r1)		; Volume gauche

	move	#>frequence+1,r3	; r3 pointe sur la frequence
	move	x:(r1)+,x1
	move	x:(r3)-,x0
	move	#>sambuf,a
	move	x:finepos,a0
	move	a1,r0

	do	n7,p_q_loop
	move	x:(r0),y0
	mpy	y0,x1,b	x:(r1)-,x1
	move	x:(r0),y0
	move	b1,y:(r5)+
	mpy	y0,x1,b	x:(r3),x1
	add	x,a	a1,r0
	move	x:(r1)+,x1
	move	b1,y:(r5)+
p_q_loop:
	jmp	mix_fin

put_milieu:			; Balance au milieu
	move	y0,b
	asr	b
	move	b,y0	x:frequence,x1
	move	x:frequence+1,x0
	do	n7,p_m_loop
	add	x,a	x:(r0),y1	; Position suivante
	mpy	y0,y1,b	a1,r0	; volume
	move	b1,y:(r5)+		; Sur la voie gauche
	move	b1,y:(r5)+		; ...et la droite
p_m_loop:
	jmp	mix_fin

put_gauche:			; Balance … gauche
	move	x:frequence,x1
	move	x:frequence+1,x0
	do	n7,p_g_loop
	add	x,a	x:(r0),y1	; Position suivante
	mpy	y0,y1,b	a1,r0	; volume
	move	b1,y:(r5)+n5	; Sur la voie gauche
p_g_loop:
	move	x:adrbuf,r5	; Comme on n'a ‚crit qu'… gauche,
	clr	a		; on efface la voie de droite
	lua	(r5)+,r5
	do	n7,p_g_loop2
	move	a1,y:(r5)+n5
p_g_loop2:
	jmp	mix_fin

put_droite:			; Balance … droite
	move	x:frequence,x1
	move	x:frequence+1,x0
	lua	(r5)+,r5
	do	n7,p_d_loop
	add	x,a	x:(r0),y1	; Position suivante
	mpy	y0,y1,b	a1,r0	; volume
	move	b1,y:(r5)+n5	; Sur la voie droite
p_d_loop:
	clr	a	x:adrbuf,r5	; De mˆme, comme on n'a ‚crit qu'… droite,
	do	n7,p_d_loop2		; on efface la voie gauche
	move	a1,y:(r5)+n5
p_d_loop2:
	jmp	mix_fin



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage avec interpolation				*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
mix_interpolate:
	move	x:numsam,b
	tst	b
	jeq	premier_i		; C'est le premier sample?
	move	x:balance,b	; La balance, svp

mix_i_quelconque:
	move	b,x0
	mpy	x0,y0,a	(r1)+	; r1 pointe sur le volume droit
	move	a,x:(r1)-		; Volume droit
	move	#$7fffff,a
	sub	b,a
	move	a,x0
	mpy	x0,y0,a
	move	a1,x:(r1)		; Volume gauche

;--- 1ere passe: interpolation avec les samples … gauche des points ----------
	move	#>frequence+1,r3	; r3 pointe sur la frequence
	move	x:(r1)+,x1
	move	x:(r3)-,x0
	move	#>sambuf,a
	move	x:finepos,a0
	move	a1,r0

	do	n7,m_i_q_loopa
	  move	a0,b1		; Coef d'interpolation
	  not	b		; 0.99999999 - coef
	  lsr	b	x:(r0),y1	; Passe en 47 bits - prend le sample
	  move	b1,y0
	  mpy	y0,y1,b		; Interpolation
	  move	b,y1		; y1 contient le sample interpol‚ mais non "volum‚"
	  mpy	y1,x1,b	x:(r1)-,x1	y:(r5),y0
	  add	y0,b
	  move	b1,y:(r5)+
	  mpy	y1,x1,b	x:(r3),x1	y:(r5),y0
	  add	x,a	a1,r0
	  add	y0,b	x:(r1)+,x1
	  move	b1,y:(r5)+
m_i_q_loopa:

;--- 2eme passe: interpolation avec les samples … droite des points ----------
m_i_q_droite:
	move	#>sambuf+1,a
	move	x:finepos,a0
	move	a1,r0
	move	x:adrbuf,r5
	move	x:taille_b1,n7

	do	n7,m_i_q_loopb
	  move	a0,b1		; Coef d'interpolation
	  lsr	b	x:(r0),y1	; Passe en 47 bits - prend le sample
	  move	b1,y0
	  mpy	y0,y1,b		; Interpolation
	  move	b,y1		; y1 contient le sample interpol‚ mais non "volum‚"
	  mpy	y1,x1,b	x:(r1)-,x1	y:(r5),y0
	  add	y0,b
	  move	b1,y:(r5)+
	  mpy	y1,x1,b	x:(r3),x1	y:(r5),y0
	  add	x,a	a1,r0
	  add	y0,b	x:(r1)+,x1
	  move	b1,y:(r5)+
m_i_q_loopb:
	jmp	mix_fin



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage avec interpolation - premiere voie			*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
premier_i:
	move	x:balance,b	; La balance

put_i_quelconque:
	move	b,x0
	mpy	x0,y0,a	(r1)+
	move	a,x:(r1)-		; Volume droit
	move	#$7fffff,a
	sub	b,a
	move	a,x0
	mpy	x0,y0,a
	move	a1,x:(r1)		; Volume gauche

;--- 1ere passe: interpolation avec les samples … gauche des points ----------
	move	#>frequence+1,r3	; r3 pointe sur la frequence
	move	x:(r1)+,x1
	move	x:(r3)-,x0
	move	#>sambuf,a
	move	x:finepos,a0
	move	a1,r0

	do	n7,p_i_q_loopa
	move	a0,b1		; Coef d'interpolation: fraq(a)
	not	b		; (0.99999999 - coef) en 48 bits (pas de signe)
	lsr	b	x:(r0),y1	; Passe en 47 bits (car mpy est sign‚) - prend le sample
	move	b1,y0
	mpy	y0,y1,b		; Interpolation
	move	b1,y1		; y1 contient le sample interpol‚ mais non "volum‚"
	mpy	y1,x1,b	x:(r1)-,x1	; Volume le sample gauche - prend le volume droit
	move	b1,y:(r5)+		; Place le sample gauche
	mpy	y1,x1,b	x:(r3),x1	; Volume le sample droit - reprend la fr‚quence mot fort
	add	x,a	a1,r0	; Incr‚mente le pas - fixe r0 … l'adresse du sample suivant
	move	x:(r1)+,x1		; Prend le volume gauche
	move	b1,y:(r5)+		; Place le sample droit
p_i_q_loopa:

;--- 2eme passe: interpolation avec les samples … droite des points ----------
	jmp	m_i_q_droite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;put_gauche:			; Balance … gauche
;	move	x:frequence,x1
;	move	x:frequence+1,x0
;	do	n7,p_g_loopa
;	move	a0,b1		; Coef d'interpolation
;	not	b		; 0.99999999 - coef
;	lsr	b		; Passe en 47 bits
;	move	b1,y0
;	add	x,a	x:(r0),y1	; Calcule la position suivante - sample
;	mpy	y0,y1,b	x:(r1),y0	; Interpole - Prend le volume
;	move	b,y1
;	mpy	y0,y1,b	a1,r0	; Volume - Position suivante dans r0
;	move	b1,y:(r5)+n5	; Sur la voie gauche
;p_g_loopa:
;	move	#>sambuf+1,a
;	move	x:finepos,a0
;	move	a1,r0
;	move	x:adrbuf,r5
;	move	x:taille_b1,n7
;	do	n7,p_g_loopb
;	move	a0,b1		; Coef d'interpolation
;	lsr	b
;	move	b1,y0
;	add	x,a	x:(r0),y1	; Calcule la position suivante - sample
;	mpy	y0,y1,b	x:(r1),y0	; Interpole - Prend le volume
;	move	b,y1
;	mpy	y0,y1,b	y:(r5),y1	; Volume - Prend le sample d‚j… … moiti‚ calcul‚
;	add	y1,b	a1,r0	; Additionne - Position suivante dans r0
;	move	b1,y:(r5)+n5	; Sur la voie gauche
;p_g_loopb:
;	move	x:adrbuf,r5	; Comme on n'a ‚crit qu'… gauche,
;	clr	a		; on efface la voie de droite
;	lua	(r5)+,r5
;	do	n7,p_g_loop2
;	move	a1,y:(r5)+n5
;p_g_loop2:
;	jmp	mix_fin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Mixage sans resampling				*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
resampling030:
	move	x:adrbuf,r5
	move	#>2,n5
	move	#>tmp_buffer,r0
	move	x:taille_b1,n7
	move	x:volume_g,y0
	move	x:numsam,b
	readhost	x0		; x0 = multiplicateur 8 ou 16 -> 24 bits
	tst	b
	jeq	premier030		; C'est le premier sample?
	move	x:balance,b	; La balance, svp
	move	#>0,x1
	cmp	x1,b
	jeq	mix_gauche030
	move	#>$7ff800,x1
	cmp	x1,b
	jeq	mix_droite030
	move	#>$400000,x1
	cmp	x1,b
	jeq	mix_milieu030

mix_quelconque030:
	move	#>volume_d,r1
	move	b,x1
	mpy	x1,y0,a
	move	a,x:(r1)-		; Volume droit
	move	#$7fffff,a
	sub	b,a
	move	a,x1
	mpy	x1,y0,a
	move	a1,x:(r1)		; Volume gauche
	move	x:(r1)+,x1

	do	n7,m_q_loop030
	readhost	y0
	mpy	x0,y0,a
	move	a0,y0
	move	y0,x:(r0)
	mpy	y0,x1,b	x:(r1)-,x1	y:(r5),y0
	add	y0,b	x:(r0),y0
	move	b1,y:(r5)+
	mpy	y0,x1,b		y:(r5),y0
	add	y0,b	x:(r1)+,x1
	move	b1,y:(r5)+
m_q_loop030:
	jmp	mix_fin

mix_milieu030:			; Balance au milieu
	move	y0,b
	asr	b
	move	b,y0
	do	n7,m_m_loop030
	readhost	y1
	mpy	x0,y1,a
	move	a0,y1
	move	y1,x:(r0)
	mpy	y0,y1,b	y:(r5),y1	; volume
	add	y1,b	x:(r0),y1	; mixe et reprend le sample
	move	b1,y:(r5)+		; Sur la voie gauche
	mpy	y0,y1,b	y:(r5),y1	; On refait le volume, pour la droite cette fois
	add	y1,b		; et le mixage
	move	b1,y:(r5)+		; Hop sur la voie droite
m_m_loop030:
	jmp	mix_fin

mix_gauche030:			; Balance … gauche
	do	n7,m_g_loop030
	readhost	y1
	mpy	x0,y1,a
	move	a0,y1
	mpy	y0,y1,b	y:(r5),y1	; volume
	add	y1,b		; mixe
	move	b1,y:(r5)+n5	; Sur la voie gauche
m_g_loop030:
	jmp	mix_fin

mix_droite030:			; Balance … droite
	lua	(r5)+,r5
	do	n7,m_d_loop030
	readhost	y1
	mpy	x0,y1,a
	move	a0,y1
	mpy	y0,y1,b	y:(r5),y1	; volume
	add	y1,b		; mixe
	move	b1,y:(r5)+n5	; Sur la voie droite
m_d_loop030:
	jmp	mix_fin

premier030:
	move	x:balance,b	; La balance
	move	#>0,x1
	cmp	x1,b
	jeq	put_gauche030
	move	#>$7ff800,x1
	cmp	x1,b
	jeq	put_droite030
	move	#>$400000,x1
	cmp	x1,b
	jeq	put_milieu030

put_quelconque030:
	move	#>volume_d,r1
	move	b,x1
	mpy	x1,y0,a
	move	a,x:(r1)-		; Volume droit
	move	#$7fffff,a
	sub	b,a
	move	a,x1
	mpy	x1,y0,a
	move	a1,x:(r1)		; Volume gauche
	move	x:(r1)+,x1

	do	n7,p_q_loop030
	readhost	y0
	mpy	x0,y0,a
	move	a0,y0
	move	y0,x:(r0)
	mpy	y0,x1,b	x:(r1)-,x1
	move	x:(r0),y0
	move	b1,y:(r5)+
	mpy	y0,x1,b	x:(r1)+,x1
	move	b1,y:(r5)+
p_q_loop030:
	jmp	mix_fin

put_milieu030:			; Balance au milieu
	move	y0,b
	asr	b
	move	b,y0
	do	n7,p_m_loop030
	readhost	y1
	mpy	x0,y1,a
	move	a0,y1
	mpy	y0,y1,b		; volume
	move	b1,y:(r5)+		; Sur la voie gauche
	move	b1,y:(r5)+		; ...et la droite
p_m_loop030:
	jmp	mix_fin

put_gauche030:			; Balance … gauche
	do	n7,p_g_loop030
	readhost	y1
	mpy	x0,y1,a
	move	a0,y1
	mpy	y0,y1,b		; volume
	move	b1,y:(r5)+n5	; Sur la voie gauche
p_g_loop030:
	move	x:adrbuf,r5	; Comme on n'a ‚crit qu'… gauche,
	clr	a		; on efface la voie de droite
	lua	(r5)+,r5
	do	n7,p_g_loop2030
	move	a1,y:(r5)+n5
p_g_loop2030:
	jmp	mix_fin

put_droite030:			; Balance … droite
	lua	(r5)+,r5
	do	n7,p_d_loop030
	readhost	y1
	mpy	x0,y1,a
	move	a0,y1
	mpy	y0,y1,b	a1,r0	; volume
	move	b1,y:(r5)+n5	; Sur la voie droite
p_d_loop030:
	clr	a	x:adrbuf,r5	; De mˆme, comme on n'a ‚crit qu'… droite,
	do	n7,p_d_loop2030		; on efface la voie gauche
	move	a1,y:(r5)+n5
p_d_loop2030:

mix_fin:
	move	x:numsam,a1	; Sample suivant
	move	#>$1,x0
	add	x0,a
	move	a1,x:numsam
	jmp	wait_cmd



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;*	Fin : mixage des constantes avec fade vers 0		*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
rec_end:
	move	x:taille_b1,n7
	move	x:adrbuf,r5
	move	x:cst_left,x0
	move	x:cst_right,x1
	move	#0.995,y0
	do	n7,addcst_loop
	mpy	x0,y0,b	y:(r5)+,a
	mpy	x1,y0,b	b,x0
	move	b,x1
	add	x0,a	y:(r5)-,b
	add	x1,b	a,y:(r5)+
	move	b,y:(r5)+
addcst_loop:



;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;;*	Attend le moment de r‚cup‚rer le prochain bloc de samples	*
;*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
wait_next_frame:
	move	x:taille_b2,b
	lsl	b	x:adrbuf,a
	move	#>mixbuf1,x0
	cmp	x0,a
	jne	wait_buf2
;--- Attend le d‚but du premier buffer ---------------------------------------
	move	#>mixbuf2,a
	add	b,a	r4,b
wait_buf1_loop:
	cmp	b,a	r4,b
	jne	wait_buf1_loop
	move	#>mixbuf1,r4
	move	#>mixbuf2,x0
	move	x0,x:adrbuf
	jmp	receive_loop
;--- Attend le d‚but du deuxieme buffer --------------------------------------
wait_buf2:
	move	#>mixbuf1,a
	add	b,a	r4,b
wait_buf2_loop:
	cmp	b,a	r4,b
	jne	wait_buf2_loop
	move	#>mixbuf2,r4
	move	#>mixbuf1,x0
	move	x0,x:adrbuf
	jmp	receive_loop

;--- Efface les voies (met les constantes) -----------------------------------
eff_gadr:
	move	x:adrbuf,r5
	move	x:cst_left,a
	move	x:cst_right,b
	do	#(mixbuf2-mixbuf1)/2,eff_gadr_loop
	move	a,y:(r5)+
	move	b,y:(r5)+
eff_gadr_loop:
	jmp	wait_next_frame

coupe_son:				; L… c'est quand on se tire
	move	#save_reg,r0	; Remet la valeur d'origine des registres E/S
	nop
	move	x:(r0)+,x0
	movep	x0,x:<<CRA
	move	x:(r0)+,x0
	movep	x0,x:<<PCC
	move	x:(r0)+,x0
	movep	x0,x:<<PBC
	move	x:(r0)+,x0
	movep	x0,x:<<BCR
	move	x:(r0)+,x0
	movep	x0,x:<<IPR
	move	x:(r0)+,x0
	movep	x0,x:<<CRB
	jmp	*		; On attend que ‡a se passe...



;*~~~ FIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
