;=========================================================================;
;                            DSP SoundTracking                            ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ce source contient une partie des routines du soundtracker DSP.          ;
;A savoir:                                                                ;
;         o Routines de mixage sans interpolation ni balances.            ;
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
;    n5  = 2 pour circuler sur les voix entrelac‚es
;
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
_waitssi1	cmp	x0,a		;+---------------------------------+
	jgt	<_freeway		;|..........|//////////|...........|
	cmp	x0,b	r7,x0	;           r5      r5+nb_ech*2
	jle	<_freeway		;           --Interdit--
	jmp	<_waitssi1		;
_waitssi2	cmp	x0,a	r7,x0	;
	jle	<_waitssi2		;+---------------------------------+
	cmp	x0,b		;|////|.....................|//////|
	jgt	<_waitssi2		;  r5+nb_ech*2              r5

_freeway	move	#fracs,r2		;Positions fractionnaires, et
	movec	m1,m2		;adressage lin‚aire.
	move	x:(r2),a		;"Position" actuelle
	move	x:(r1)-,x0		;Incr‚ment
	move	#>$7fffff,x1	;Masque pour virer -E-xtension
	move	x:(r1),y0		;R‚cupere le volume amiga
	move	y:(r6)+,y1		;1er ‚chantillon
	mpyr	y0,y1,b		;
	andi	#%11011111,ccr	;Virer l'extension
	.loop	x:<nb_ech		;
	jec	<_nonew		;
	and	x1,a	y:(r6)+,y1	;
	mpyr	y0,y1,b		;
_nonew	add	x0,a	b,y:(r5)+n5 ;
	.endl			;
	and	x1,a		;
	move	a,x:(r2)+		;Resauve la position
	rts			;

;;;;;;;;;;; Mixage autres voix = addition sur le signal pr‚c‚dent
;(r0,m0) = buffer modulo de reception du sample
;(r1,m1) = nparx (fin des donn‚es du sample) en lin‚aire
;(r2,m2) = position fractionnaire courante, en lin‚aire
;    n5  = d‚but zone de mixage.
;
OtherVoice	jsr	<SPL_8_24		;->r1=incrx
	move	x:(r2),a		;"Position" actuelle
	move	x:(r1)-,x0		;Incr‚ment
	move	#>$7fffff,x1	;Masque pour virer -E-xtension
	move	x:(r1),y0		;R‚cupere le volume
	move	y:(r6)+,y1		;1er ‚chantillon
	mpyr	y0,y1,b		;
	move	y:(r5),y1		;Echantillon … additionner
	andi	#%11011111,ccr	;Virer l'extension
	.loop	x:<nb_ech		;
	jec	<_nonew		;
	and	x1,a	y:(r6)+,y1	;
	mpyr	y0,y1,b	y:(r5),y1	;
_nonew	add	y1,b		;Mixage des deux voix
	sub	y1,b	b,y:(r5)+n5 ;"D‚mixer" la voix.
	add	x0,a	y:(r5),y1	;Hop, ‡a sent l'avancement.
	.endl			;
	and	x1,a		;
	move	a,x:(r2)+		;Resauve la position
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
	move	(r0)-
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
	move	r5,n0		;
	move	#<2,n5		;
	jsr	<FirstVoice	;Routines en P:ram interne.
	move	n0,r5		;Idem sur la voix 2, mais de
	move	#npar2,r1		;l'autre cot‚.
	move	(r5)+		;
	jsr	<FirstVoice	;
	move	n0,r5		;La voix 3 vient se mixer sur la
	move	#npar3,r1		;voix 2.
	move	(r5)+		;
	jsr	<OtherVoice	;
	move	n0,r5		;Et on termine par la voix 4
	move	#npar4,r1		;
	jsr	<OtherVoice	;

	jmac	ByeBye		;Retour … l'envoyeur

	jmac	Code_SSITD		;Routines de d‚tection de Frame Sync

	IF	(*-MixOverlay)>MixCodSize
	fail	'Code plus grand que pr‚vu!!'
	ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include	'dspmix_c.asm'