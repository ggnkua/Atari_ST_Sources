;=========================================================================;
;                            DSP SoundTracking                            ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ce source contient une partie des routines du soundtracker DSP.          ;
;A savoir:                                                                ;
;         o Routines de mixage sans interpolation, avec balances.         ;
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
;    n1  = pour aller sur les volumes gauche&droit
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
_waitssi2	cmp	x0,a	r7,x0	;>>Charge n5 pour la sortie
	jle	<_waitssi2		;+---------------------------------+
	cmp	x0,b	r5,n5	;|////|.....................|//////|
	jgt	<_waitssi2		;  r5+nb_ech*2              r5

_freeway	move	#fracs,r2		;Positions fractionnaires, et
	movec	m1,m2		;adressage lin‚aire.
	move	x:(r2),a		;"Position" actuelle
	move	x:(r1),x0		;Incr‚ment
	move	#<$800000,x1	;Masque pour virer -E-xtension
	move	l:(r6)+,y		;1er ‚chantillon
	move	y1,y:(r5)+		;

	.loop	x:<nb_ech		;Boucle hard
	add	x0,a	y0,y:(r5)+	;
	jec	<_nonew		;Pour ‚viter un jec .endl (impossible)
	eor	x1,a	l:(r6)+,y	;on met les y:(r5)+ en quinconce.
_nonew	move	y1,y:(r5)+		;
	.endl			;

	move	a,x:(r2)+		;Resauve la position
	rts			;

;;;;;;;;;;; Mixage autres voix = addition sur le signal pr‚c‚dent
;(r0,m0) = buffer modulo de reception du sample
;(r1,m1) = nparx (fin des donn‚es du sample) en lin‚aire
;    n1  = pour aller sur les volumes gauche&droit
;(r2,m2) = position fractionnaire courante, en lin‚aire
;    n5  = d‚but zone de mixage.
;Le mixage se fait par limitation, ce qui permet d'avoir un son nikel et
;d'‚viter un d‚bordement quand les balances sont utilis‚es.
;
OtherVoice	jsr	<SPL_8_24		;->r1=incrx
	move	x:(r2),x0		;
	move	r2,n2		;
	move	#<0,r2		;!<>!<>!<>pos_frac=0<>!<>!<>!
	move	n5,r5		;
	move	x0,x:(r2)		;
	
	move	#<$800000,y0	;Masque le bit d'extension
	move	x:(r1),y1		;Incr‚ment fractionnaire
	move	l:(r6)+,x		;Premier ‚chantillon
	move	y:(r5)+,a		;Pr‚paration: r‚sultat pr‚c‚dent gauche

	.loop	x:<nb_ech		;========Attention les yeux!...========
	add	x1,a	y:(r5)-,b		;Mixe gauche - pr‚c‚dent droit
	add	x0,b	a,y:(r5)+	x:(r2),a	;Mixe droite - stocke gauche   - position
	add	y1,a	b,y:(r5)+		;avance	  - stocke droit
	jec	<_nonew		;d‚borde ?
	eor	y0,a	l:(r6)+,x	;oui->annule E        - ‚chantillon suivant
_nonew	move	y:(r5)+,a	a,x:(r2)	;'prefetch' gauche    - sauve position
	.endl			;

	move	x:(r2)+n2,x0 y:(r5)-,a ;Reprend position fractionnaire.
	move	x0,x:(r2)+		;et corrige r5.
	rts	

;;;;;;;;;;; Conversion format DMA/Host -> fractionnaire
;(r0,m0) = buffer modulo de reception du sample
;(r1,m1) = nparx (fin des donn‚es du sample) en lin‚aire
;    n1  = pour aller sur les volumes gauche&droit
SPL_8_24	move	#buff24,r6		;Convertion 8->24
	move	x:(r1+n1),x0	;            volume droit
	move	x:(r1)-,a		;Parit‚ du sample
	move	x:(r1+n1),x1	;volume gauche
	move	x:rx_mode,b	;
	tst	b		;
	jne	<_Host		;

_Dma	move	a,x:<mask		;On verra plus tard.
	clr	b	x:(r0)+,a	;Installe les registres comifo
	move	#<$80,b1		;
	move	#<$ff0000,y0	;

	do	x:(r1)-,_enddma	;
	and	y0,a	a,y1	;
	move	a,y0		;
	mpyr	x1,y0,a		;
	mpyr	x0,y0,a	a,x:(r6)	b,y0
	mpy	y1,y0,a	a,y:(r6)+	;(*):Comme b2=0, pas de limitation surprise
	move	a0,y1		;
	mpyr	x1,y1,a	#<$ff0000,y0
	mpyr	x0,y1,a	a,x:(r6)	;
	move	a,y:(r6)+	x:(r0)+,a	;
_enddma	move	(r0)-		;
	move	#buff24,r6		;
	move	x:<mask,a		;
	tst	a		;
	jeq	_ok		;Si c'est un envoi impair, alors
	move	(r6)+		;ignore le premier ‚chantillon.
_ok	rts			;


_Host	clr	b	#<$ff0000,y0
	move	#>$8000,b0		;
	move	r2,n0		;
	move	#mask,r2		;
	move	y0,x:<mask		;
	move	x:(r0)+,a

	.loop	x:(r1)		;La mˆme chose, mais cette fois pour
	and	y0,a	a,y1	;s‚parer les trois octets d'un mot.
	move	a,y0		;
	mpyr	x1,y0,a	#<$80,b1	;
	mpyr	x0,y0,a	a,x:(r6)	b,y0
	mpy	y1,y0,a	a,y:(r6)+	x:(r2),x1
	move	a0,a		;On utilise x1 un court instant
	and	x1,a	x:(r1+n1),x1 ;..et on reprend sa valeur "volumique"
	move	a,y0		;
	mpyr	x1,y0,a	b0,b1	;
	mpyr	x0,y0,a	a,x:(r6)	b,y0
	mpy	y1,y0,a	a,y:(r6)+	;
	move	a0,y1		;
	mpyr	x1,y1,a	x:(r2),y0	;
	mpyr	x0,y1,a	a,x:(r6)	;
	move	a,y:(r6)+	x:(r0)+,a	;
	.endl			;
	move	(r1)-		;
	move	(r0)-		;
	move	n0,r2		;
	move	#buff24,r6		;
	rts			;

MixOverlaySize equ	@LCV(L)-MixOverlay	;Taille de la chose.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include	'dspmix_b.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; HostCommand principale de gestion du mixage ;;;;;;;;;;;;;;;;;;;;;;;
Interrupt_Mixer			;Tout ceci se passe en IPL2
	andi	#%01010011,mr	;Virer: NO(scaling, trace, loop)
	jmac	SaveAll

	jmac	GetMode		;Mode de transfert? + Restart?
	jmac	GetDelta		;r_nb_ech ?

	jmac	GetVoices		;
	jmac	CalcVol		;
	jmac	GetSpl		;Demande de r‚ception des samples
	jmac	HostResend		;Continuit‚ des transferts Host

	move	#npar1,r1		;et boum, on mixe rapidos
	move	#>rvol1-npar1,n1	;
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
