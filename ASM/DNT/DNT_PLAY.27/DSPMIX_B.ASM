;=========================================================================;
;                            DSP SoundTracking                            ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ce source contient une partie des routines du soundtracker DSP.          ;
;A savoir:                                                                ;
;         o Chargement & ex‚cution de programmes DSP 'paralleles'         ;
;         o Macros de gestion, partie g‚n‚raliste des routines de         ;
;           mixage.                                                       ;
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
	org	p:@LCV(L)		;Routines non-overlay, … la suite.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; HostCommand de chargement de programmes externes ;;;;;;;;;;;;;;;;;;
P_loader	movep	#B_HCIE,x:<<M_HCR	;Host Command uniquement.
	movec	#<0,sp		;Pile … z‚ro, par s‚curit‚.
	movec	#<0,omr		;Operating mode=0, DE=0
	movec	#$0100,sr		;No Loop, No Trace, No Scaling, IPL1
 	clr	a	#_gethost,r1
	movec	#$ffff,m0		;Adressage lin‚aire, pour tout le
	movec	m0,m1		;monde sinon c'est dexu baffes.
	movec	m1,m2		;
	movec	m2,m4		;
	movec	m4,m5		;
	movec	m5,m6		;
	

_section	jsr	(r1)		;Type de section (P,X,Y=0,1,2)
	tfr	x0,b	x0,n0	;
	tst	b	#>_memload,r0
	jmi	<0		;Si Type<0, fini!, et ex‚cute.
	movem	p:(r0+n0),r2	;
	jsr	(r1)		;R‚cupere l'adresse.
	move	x0,r0		;Hop
	jsr	(r1)		;Taille de la section.
	do	x0,_endsect	;
	jsr	(r1)		;R‚ception Host
	jsr	(r2)		;Stockage
	nop			;
_endsect	jmp	_section		;Il en reste encore ?
_pload	movem	x0,p:(r0)+		;
	rts			;
_xload	move	x0,x:(r0)+		;
	rts			;
_yload	move	x0,y:(r0)+		;
	rts			;

_gethost	ReadHost	x0		;
	rts			;

_memload	dc	_pload		;
	dc	_xload		;
	dc	_yload		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Pour ‚viter un jsr sur des routines uniques (gagne 3 mots...) ;;;;;
jmac	MACRO	macname
	macname
	ENDM

;;;;;;;;;;;
CopyInfo	MACRO
	move	#r_lvol1,r1	;Copier les infos samples,
	move	#lvol1,r2		;de la zone de r‚ception vers
	.loop	#rx_mode-lvol1+1	;celle de travail.
	move	x:(r1)+,x0		;
	move	x0,x:(r2)+		;
	.endl			;
	move	x:(r1)+,x0		;
	move	x0,x:<nb_ech	;
	ENDM

;;;;;;;;;;;
SaveAll	MACRO
	move	r0,x:save_r0	;Commence par sauver tous les registres.
	move	m0,x:save_m0	;
	move	#save_a2,r0	;
	movec	#$ffff,m0		;
	move	n0,x:save_n0	;
	move	a2,x:(r0)+		;
	move	a1,x:(r0)+		;
	move	a0,x:(r0)+		;
	move	b2,x:(r0)+		;
	move	b1,x:(r0)+		;On sauvera x0/x1 y0/y1 plus
	move	b0,x:(r0)+		;tard.
	move	r1,x:(r0)+		;
	move	m1,x:(r0)+		;
	move	n1,x:(r0)+		;
	move	r2,x:(r0)+		;
	move	m2,x:(r0)+		;
	move	n2,x:(r0)+		;
	move	r5,x:(r0)+		;
	move	m5,x:(r0)+		;
	move	n5,x:(r0)+		;
	movec	m0,m1		;Tous les adressages sont lin‚aires,
	movec	m0,m2		;sauf r5

	move	#MixOverlay,r1	;
	move	#<$40,r2		;
	.loop	#MixOverlaySize	;Installation du code
	movem	p:(r1)+,a		;en m‚moire interne.
	movem	p:(r2),b		;
	movem	a,p:(r2)+		;
	move	b,x:(r0)+		;
	.endl			;

	move	#<0,r1		;
	.loop	#iram_size		;Sauve le peu de m‚moire X
	move	x:(r1)+,a		;interne
	move	a,x:(r0)+		;
	.endl			;

	move	r6,x:(r0)+		;Sauve les derniers registres
	move	m6,x:(r0)+		;
	move	n6,x:(r0)+		;
	move	x1,x:(r0)+		;
	move	x0,x:(r0)+		;
	move	y1,x:(r0)+		;
	move	y0,x:(r0)+		;
	movec	m0,m6		;

	jmac	CopyInfo		;

	move	#'NTK',x0		;Identification du mixeur
	tfr	x0,a	x0,y0	;
	WritHost	x0		;On l'envoie au 030, les deux
_link	move	y0,y1		;tests ‚tant en quinconce.
	move	a,y0		;
	ReadHost	a		;Attendre celui donn‚ par le 030,
	cmp	x0,a		;en notant un ‚ventuel envoi Host
	jne	_link		;interrompu.
	WritHost	y0		;Echange avec le 030 ce que l'on
	WritHost	y1		;a intercept‚.
	ReadHost	x:(r0)+		;
	ReadHost	x:(r0)+		;
	ENDM

;;;;;;;;;;;
GetMode	MACRO
	move	x:last_calc2,r5	;Point de mixage actuel
	ReadHost	a		;(0=DMA, 1=Host)
	tst	a	#<0,b	;(-2   , -1    )+Restart
	jsmi	Restart		;Tout red‚marrer ?
	add	b,a		;Correction si n‚cessaire
	move	a,x:r_rx_mode	;Range mode de transfert.
	movec	m7,m5		;
	ENDM

;;;;;;;;;;;
;En sortie, b1=2 pour correction mode de transfert.
Restart	movep	#$0800,x:<<M_CRB	;SSI off.
	move	#restitbuf,r5	;
	move	#$fff,m7		;
	clr	b	#restitbuf+2*maxech,r7
	rep	#$fff		;
	move	b,l:(r7)+		;Efface tous les buffers
	move	b,l:(r7)+		;
	move	#lvol1,r0		;
	rep	#last_get1-lvol1	;
	move	b,x:(r0)+		;Efface aussi les donn‚es du sample
	rep	#3		;
	move	r5,x:(r0)+		;last_get1&2, last_calc1
	move	#<2,b1		;N‚cessite b=0
	move	#nspl1,r0		;
	move	#<nspl2-nspl1,n0	;nsplx<>0 sinon plantage.
	rep	#4		;
	move	b,x:(r0)+n0	;
	move	#maxech,x0		;Sans oublier nb_ech
	move	x0,x:<nb_ech	;

	movem	p:>Code_1,x0	;Installer le d‚tecteur de Frame.
	movem	x0,p:<I_SSITD	;
	movem	p:>Code_1+1,x0	;
	movem	x0,p:<I_SSITD+1	;
	movep	#$5800,x:<<M_CRB	;SSI-OUT on, SSI-IN off.
	movep	x0,x:<<M_HTX	;Signale la fin de l'init...
	rts			;

;;;;;;;;;;;
GetDelta	MACRO
_hop	move	r7,a		;delta = nombre d'‚chantillons …
	clr	b	r5,x0	;calculer pour boucler le buffer.
	sub	x0,a	#$800,x0	;Si delta<0, alors prendre
	tmi	x0,b		;delta MOD taille_buffer
	addr	b,a	#maxech/2,b ;(Nb: ‚chantillons st‚r‚o -> asr)
	addr	b,a	#$420,x0	;Moyenne les ‚carts pour stabiliser, et v‚rifie
	cmp	x0,a	#$290,x1	;le r‚sultat. Si visiblement non-valable (le player
	jle	_test		;est trop en retard), alors restart sauvage.
_gasp	WritHost	#0		;
	jsr	Restart		;Nb: $420 et $290 sont calcul‚s … partir des tempos
	jmp	_hop		;mini et maxi plus une erreur de 15625/32Hz sur le
_test	cmp	x1,a		;tempo (moyenn‚ par maxech pour mini)
	jlt	_gasp		;
	move	a,x:r_nb_ech	;Stocke comifo
	WritHost	a		;R‚ponse <>0, pas de restart.
	ENDM

;;;;;;;;;;; R‚ception des parametres de mixage par le port Host
GetVoices	MACRO
	move	#r_bala1,r1	;Info 1ere voix
	move	#(r_bala2-r_bala1)-4,n1
	move	#r_fracs,r2	;
	.loop	#4		;
	ReadHost	x:(r1)+		;Re‡oie ses parametres: balance,
	ReadHost	x:(r1)+		;Volume
	ReadHost	x1		;Puis l'incr‚ment de fr‚quence
	clr	a	x:r_nb_ech,x0
	move	x:(r2),a0		;
	mac	x1,x0,a	x1,x:(r1)+	;
	WritHost	a1		;largeur sample ce coup-ci,
	move	a0,x:(r2)+		;Sauve le tout
	ReadHost	x:(r1)+		;Lire le nb de paquets,
	ReadHost	x:(r1)+n1		;et la parit‚.
	.endl
	ENDM
	
;;;;;;;;;;;
CalcVol	MACRO
	move	#r_avol1,r0	;Dispatch volume sur les canaux
	.loop	#4		;gauche et droite.
	move	x:(r0)-,x0		;Imp‚ratifs:
	move	x:(r0)-,x1		;   Balance=[gauche=0...$80=droite]
	mpy	x0,x1,a		;   Volume =[0...$40000]
	abs	a	#<r_avol2-r_lvol1,n0
	sub	x0,a	a,x:(r0)-	;
	abs	a		;
	move	a,x:(r0)+n0	;
	.endl			;
	ENDM

;;;;;;;;;;; Routine pour synchroniser, r‚ceptionner et v‚rifier les samples
;En sortie, (r0,m0) = adresse buffer align‚e sur la r‚ception, pour mixage.
GetSpl	MACRO
	move	x:rx_mode,a	;
_OldHost	move	x:last_get1,r0	;On vient de le recevoir.
	movec	m7,m0		;Modulos in/out identiques.
	move	x:last_get2,r2	;
	movec	m7,m2		;
	tst	a	#<1+16,n0	;C'‚tait du Host ? | Pour le test DMA
	jne	_NewGet		;
_OldDma	move	#nspl1,r1		;
	move	#<nspl2-nspl1,n1	;
	move	r0,r2		;Non, faut chercher le 1er couple.
	move	#<16,n2		;
	lua	(r0)+n0,r0		;
	do	#5,_rewind		;A cause d'un couple parasite qui apparait
	lua	(r2)+n2,r2		;parfois en d‚but de transfert DMA, faut rajouter
	move	x:(r1)+n1,n2	;un faux sample $7F80 $7F80... en dernier, et
	move	#$7f8000,x0	;regarder sa position pour passer outre ce
_rewind	move	x:-(r2),a		;d‚calage ‚ventuel.
	cmp	x0,a	(r0)-	;Ce test est valable pour une r‚ception 4
	jeq	_rewind		;pistes st‚r‚o (->4 couples parasites), et
	lua	(r2)+,r2		;peut etre simplifi‚ ici.

_NewGet	move	x:r_rx_mode,a	;
	WritHost	r2		;On est pret … recevoir le sample..
	ReadHost	x0		;Ici, 030 et DSP sont 100% synchro
	tst	a	r2,x:last_get1
	jne	_NewHost		;

_NewDma	move	r2,r3		;
	movec	m2,m3		;
	movep	#$f800,x:<<M_CRB	;Pof, autorise le SSI-IN
	jmp	_endget		;SSI on/off -> alignement.

_NewHost	movep	#$5800,x:<<M_CRB	;Coupe le SSI-IN (s'il ‚tait autoris‚!)
	move	#r_nspl1,r1	;R‚ception Host, rien … signaler..
	move	#<r_nspl2-r_nspl1,n1	;
	clr	a	#<0,x1	;
	rep	#5		;
	add	x1,a	x:(r1)+n1,x1
	.loop	a		;
	ReadHost	x:(r2)+		;
	.endl			;
	move	r2,x:last_get2	;
_endget				;
	ENDM

;;;;;;;;;;;
HostResend	MACRO
	move	#'NTK',x0		;Remplir le port Host avec ce
	move	#re_send1,r1	;qu'il contenait au moment de
	.loop	#2		;l'interruption … destination
	move	x:(r1)+,a		;du 68030...
	cmp	x0,a		;
	jeq	_nosend		;
	movep	a,x:<<M_HTX	;
_nosend	nop			;
	.endl			;Rabaisse l'IPL pour laisser passer
	andi	#%11111100,mr	;un ‚ventuel HTIE/HRIE.
	ENDM

;;;;;;;;;;;
RestoreAll	MACRO
	move	#save_n0,r0	;Restaure les registres,
	move	n5,x:last_calc1	;sauve le d‚but de mixage,
	move	r5,x:last_calc2	;ainsi que son point final.
	move	x:(r0)+,n0		;
	move	x:(r0)+,a2		;
	move	x:(r0)+,a1		;
	move	x:(r0)+,a0		;
	move	x:(r0)+,b2		;
	move	x:(r0)+,b1		;
	move	x:(r0)+,b0		;
	move	x:(r0)+,r1		;
	move	x:(r0)+,m1		;
	move	x:(r0)+,n1		;
	move	x:(r0)+,r2		;
	move	x:(r0)+,m2		;
	move	x:(r0)+,n2		;
	move	x:(r0)+,r5		;
	move	x:(r0)+,m5		;
	move	x:(r0)+,n5		;

	move	#<$40,r6		;
	.loop	#MixOverlaySize	;
	move	x:(r0)+,x0		;
	movem	x0,p:(r6)+		;
	.endl			;

	move	#<0,r6		;
	.loop	#iram_size		;Sauve le peu de m‚moire X
	move	x:(r0)+,x0		;interne
	move	x0,x:(r6)+		;
	.endl			;

	move	x:(r0)+,r6		;
	move	x:(r0)+,m6		;
	move	x:(r0)+,n6		;
	move	x:(r0)+,x1		;
	move	x:(r0)+,x0		;
	move	x:(r0)+,y1		;
	move	x:(r0)+,y0		;

	move	x:save_r0,r0	;Commance par sauver tous les
	move	x:save_m0,m0	;registres utilis‚s.
	ENDM

;;;;;;;;;;;
ByeBye	MACRO
	movec	m1,m0		;Repasse R0 en adressage lin‚aire.
	jmac	RestoreAll		;
	rti			;Pof!
	ENDM

;;;;;;;;;;;
Code_SSITD	MACRO
Code_1	jsr	>Code_2		;Alignement de la transmission

Code_2	jclr	#M_TFS,x:<<M_SR,Code_3 ;Frame Sync ?
	move	x0,x:save_cx0	;Oui, alors installer l'interruption
	movem	p:<I_SSITDE+1,x0	;de service, si on peut dire.
	movem	x0,p:<I_SSITD	;On le construit … partir du SSITDE
	move	#<0,x0		;qui reste tout le temps le mˆme.
	movem	x0,p:<I_SSITD+1	;
	move	x:save_cx0,x0	;
Code_3	movep	y:(r7),x:<<M_TX	;
	rti			;
	ENDM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Big Bug...
;	ReadHost	x:last_calc1	;Relire les infos sauv‚es pendant
;	ReadHost	x:last_calc2	;la synchro dans GetSpl.
;	ReadHost	x:last_get1	;r_nb_ech et nb_ech sont ‚chang‚s.
;	ReadHost	x:last_get2	;De plus on sauve xxxx pour le
;	ReadHost	x:r_nb_ech		;recharger dans r_xxxx.
;	ReadHost	x:nb_ech		;
;	ReadHost	x:r_incr1		;Il faut fixer en d‚but de debuggage
;	ReadHost	x:frac1		;r7=last_calc2+nb_ech*2
;	ReadHost	x:r_nspl1		;
;	ReadHost	x:r_incr2		;
;	ReadHost	x:frac2		;
;	ReadHost	x:r_nspl2		;
;	ReadHost	x:r_incr3		;
;	ReadHost	x:frac3		;
;	ReadHost	x:r_nspl3		;
;	ReadHost	x:r_incr4		;
;	ReadHost	x:frac4		;
;	ReadHost	x:r_nspl4		;
