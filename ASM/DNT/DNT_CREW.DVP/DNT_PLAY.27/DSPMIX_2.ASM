;=========================================================================;
;                            DSP SoundTracking                            ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ce source contient une partie des routines du soundtracker DSP.          ;
;A savoir:                                                                ;
;         o Routines de mixage avec interpolation et balances.            ;
;         o Include et assemblage de l'ensemble des autres routines.      ;
;                                                                         ;
;Comme d'habitude, un 'tab settings' = 11 est le bienvenu...              ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Le cas d'un programme en tache de fond utilisant une routine de reception;
;ou transmission Host, est correctement trait‚, s'il utilise les registres;
;(r4,n4,m4) pour son driver d'interruption.                               ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ceci est un programme freeware, MAIS ce n'est pas du domaine public.     ;
;Si vous utilisez tout ou partie de ce source ou d'un autre source formant;
;ma routine de soundtracker au DSP, dans un but non-lucratif, n'oubliez   ;
;pas de me le signaler.                                                   ;
;Si par contre il s'agit d'une utilisation dans le cadre d'un programme   ;
;commercial, il faudra demander mon autorisation, certes par simple       ;
;formalit‚ mais quand mˆme...                                             ;
;======================================================= Version 2.7 =====;
	nolist
	include	'dspmix_a.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Routines en overlay, assembl‚es pour la m‚moire interne,
;;;;;;;;;;; mais charg‚es en m‚moire externe pour ‚conomiser en place.
;
;(r7,m7), (r5,m5) sont toujours en modulo,
;(r0,m0), (r2,m2) sont parfois en modulo,
;(r1,m1) est toujours en adressage line‚aire.
;
	org	p:$40,p:(BASEAD-maxspl-MixCodSize)

MixOverlay	equ	@LCV(L)		;Adresse de chargement de l'Overlay
				;‡a ‚vite de se retaper le BASEAD-...
;;;;;;;;;;; Mixage 1er voix = remplissage simple
;(r0,m0) = buffer modulo de reception du sample
;(r1,m1) = nparx (fin des donn‚es du sample) en lin‚aire
;(r2,m2) en adressage modulo $fff
;
;En sortie, n5=d‚but de la zone de mixage.
;      (r2,m2)=positions fractionnaires samples 2,3,4
;
FirstVoice	move	x:<nb_ech,b	;On va calculer entre r5 et r5+nb_ech*2.
	asl	b	r5,r2	;On attend donc que r7(=SSI) sorte de
	move	b,n2		;cette zone.
	jsr	<SPL_8_24		;->r1=incr1
	lua	(r2)+n2,r2		;
	move	r5,a		;
	move	r2,b		;Si la zone est a cheval sur la fin
	cmp	b,a	r7,x0	;de buffer, inverse "l'int‚rieur",
	jgt	<_waitssi2		;...et donc le test
_waitssi1	cmp	x0,a	r5,n5	;+---------------------------------+
	jgt	<_freeway		;|..........|//////////|...........|
	cmp	x0,b	r7,x0	;           r5      r5+nb_ech*2
	jle	<_freeway		;           --Interdit--
	jmp	<_waitssi1		;
_waitssi2	cmp	x0,a	r7,x0	;
	jle	<_waitssi2		;+---------------------------------+
	cmp	x0,b	r5,n5	;|////|.....................|//////|
	jgt	<_waitssi2		;  r5+nb_ech*2              r5

_freeway	move	x:fracs,y1		;Position fractionnaire actuelle.
	tfr	y1,a	#<mask,r2	;
	move	#<3-1,m2	;Modulo kitulamor
	move	#<8,n2		;Pas de modulo, car 2**3=comifo

	move	x:(r1+n1),x0	;Pr‚paration mini-buffer:
	move	x0,x:(r2)+		;lvol
	move	x:(r1)+,x0		;
	move	x:(r1+n1),x1	;
	move	x1,x:(r2)+		;rvol
	move	x0,x:(r2)+		;incr
	move	#<$80,x0		;
	move	x0,x:(r2+n2)	;mask
	move	y:(r6)+,b	 	;1er echantillon
	move	y:(r6)+,x0		;
	sub	x0,b	b,y0	;y0=b=xn
	tfr	y0,b	b,x0	;x0=-Dxn=-(xn+1 - xn)
	.loop	x:<nb_ech			;
	  macr	-x0,y1,b	x:(r2)+,x1		;zn=xn-(-Dxn)*pos, r‚cup lvol
	  move	b,y1			;
	  mpyr	x1,y1,b	x:(r2)+,x1		;lech=zn*lvol, r‚cup rvol
	  mpyr	x1,y1,b	b,y:(r5)+	x:(r2)+,x1	;rech=zn*rvol, sauve lech
	  add	x1,a	b,y:(r5)+	y0,b	;sauv rech, avance un coup
	  jec	_nonew			;
	  sub	x0,b	y:(r6)+,x0		;xn+1=xn-(-(xn+1 - xn)), r‚cup xn+2
	  sub	x0,b	b,y0	x:(r2+n2),x1 ;-(Dxn+1)=-(xn+2 - xn+1)
	  eor	x1,a	b,x0		;maskage position, x0=-Dxn+1
	  ;;;	;;;;			;
_nonew	  tfr	y0,b	a,y1		;y0=b=xn, r‚cup y1=pos
	.endl				;
	move	y1,x:fracs		;
	move	#fracs+1,r2	;
	rts			;

;;;;;;;;;;; Mixage autres voix = addition sur le signal pr‚c‚dent
;(r0,m0) = buffer modulo de reception du sample
;(r1,m1) = nparx (fin des donn‚es du sample) en lin‚aire
;(r2,m2) = position fractionnaire courante, en lin‚aire
;    n5  = d‚but zone de mixage.
;Le mixage se fait par limitation, ce qui permet d'avoir un son nikel et
;d'‚viter un d‚bordement quand les balances sont utilis‚es.
;
OtherVoice	jsr	<SPL_8_24		;->r1=incrx
	move	x:(r2),y1		;"Position" actuelle
	move	r2,x:<pos_frac	;Sauve son pointeur
	move	#<5-1,m2		;Modulo kitulamor
	move	#<mask,r2		;
	move	#<3,n2		;
	move	n5,r5		;

	move	x:(r1+n1),x0	;Pr‚paration mini-buffer:
	move	x0,x:(r2)+		;lvol
	move	x:(r1)+,x0		;
	move	x:(r1+n1),x1	;
	move	x1,x:(r2)+		;rvol
	move	x0,x:(r2)+		;incr
	move	y1,x:(r2)+		;y1=pos
	move	#<$80,x0		;
	move	x0,x:(r2)+		;mask
	move	y:(r6)+,b		;
	move	y:(r6)+,x0		;
	sub	x0,b	b,y0	;y0=b=xn
	tfr	y0,b	b,x0	;x0=-Dxn=-(xn+1 - xn)
	.loop	x:<nb_ech			;
	  macr	-x0,y1,b	y:(r5)+,a		;zn=xn-(-Dxn)*pos
	  move	x:(r2)+,x1	b,y1		;Echantillon courant gauche
	  macr	x1,y1,a	x:(r2)+,x1	y:(r5)-,b	;Ajoute zn*lvol dessus, goto droite
	  macr	x1,y1,b	a,y:(r5)+	x:(r2)+,a	;idem, r‚cup incr
	  tfr	y0,b	x:(r2)+,x1	b,y:(r5)+	;Reprend b=y0=xn, r‚cup pos
	  add	x1,a	x:(r2)+,x1		;pos+=incr, r‚cup mask
	  jec	_nonew			;
	  sub	x0,b	y:(r6)+,x0		;xn+1=xn-(-(xn+1 - xn)), xn+2
	  sub	x0,b	b,y0		;-(Dxn+1)=-(xn+2 - xn+1), b=y0=xn+1
	  eor	x1,a	b,x0		;Vire l'ext, x0=-(Dxn+1)
	  ;;;	;;;;			;
_nonew	  tfr	y0,b	a,x:(r2+n2) a,y1	;y0=b=xn, sauve&r‚cup y1=pos
	.endl				;
	move	x:<pos_frac,r2	;
	move	m1,m2		;Repasse en lin‚aire
	nop			;
	move	y1,x:(r2)+		;Resauve la position
	rts	

;;;;;;;;;;; Conversion format DMA/Host -> fractionnaire
;(r0,m0) = buffer modulo de reception du sample
;(r1,m1) = nparx (fin des donn‚es du sample) en lin‚aire
SPL_8_24	move	#buff24,r6		;Convertion 8->24
	move	x:(r1)-,b		;Parit‚ du sample
	move	x:rx_mode,a	;
	tst	a		;
	jne	<_Host		;

_Dma	move	#<$ff0000,x1	;
	move	#>$000080,y0	;
	do	x:(r1)-,_enddma	;
	move	x:(r0)+,a		;
	and	x1,a	a,x0	;
	mpy	x0,y0,a	a,y:(r6)+	;
	move	a0,y:(r6)+		;
_enddma	tst	b	#buff24,r6	;Parit‚ ?
	jeq	_ok		;
	move	(r6)+		;Non, saute le premier echantillon.
_ok	rts			;


_Host	move	#<$ff0000,x1	;
	move	#>$000080,y0	;
	move	#>$008000,y1	;
	move	x:(r0)+,a		;
	and	x1,a	a,x0	;
	.loop	x:(r1)-		;
	mpy	x0,y0,a	a,y:(r6)+	;
	mpy	x0,y1,b	a0,a	;
	and	x1,a	b0,b	;
	move	a,y:(r6)+	x:(r0)+,a	;
	and	x1,a	a,x0	b,y:(r6)+
	.endl			;
	move	#buff24,r6		;
	move	(r0)-		;
	rts

MixOverlaySize equ	@LCV(L)-MixOverlay	;Taille de la chose.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include	'dspmix_b.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; HostCommand principale de gestion du mixage ;;;;;;;;;;;;;;;;;;;;;;;
Interrupt_Mixer			;
	andi	#%01010011,mr	;Virer: NO(scaling, trace, loop)
	jmac	SaveAll		;MAIS laisser IPL(Host)->HTIE/HRIE bloqu‚s

	jmac	GetMode		;Mode de transfert? + Restart?
	jmac	GetDelta		;r_nb_ech ?

	jmac	GetVoices		;
	jmac	CalcVol		;
	jmac	GetSpl		;Demande de r‚ception des samples
	jmac	HostResend		;Continuit‚ des transferts Host

	move	#npar1,r1		;et boum, on mixe rapidos
	move	#>lvol1-incr1,n1	;
	jsr	<FirstVoice	;Routines en P:ram interne.
	move	#npar2,r1		;
	jsr	<OtherVoice	;
	move	#npar3,r1		;
	jsr	<OtherVoice	;
	move	#npar4,r1		;
	jsr	<OtherVoice	;
	movec	m1,m0		;Repasse R0 en adressage lin‚aire.

	jmac	ByeBye		;Retour … l'envoyeur

	jmac	Code_SSITD		;Routines de d‚tection de Frame Sync

	IF	(*-MixOverlay)>MixCodSize
	fail	'Code plus grand que pr‚vu!!'
	ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include	'dspmix_c.asm'