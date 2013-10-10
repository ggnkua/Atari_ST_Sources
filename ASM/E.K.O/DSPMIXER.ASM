;=========================================================================;
;                            DSP SoundTracking                            ;
;                    (C)oderight Nullos / DNT-Crew 1994                   ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ce source contient toute la partie DSP des routines soundtracker.        ;
;A savoir:                                                                ;
;         o Initialisation du DSP                                         ;
;         o Gestion du mixage double-bufferis‚                            ;
;         o Reception & ex‚cution des programmes paralleles               ;
;                                                                         ;
;Comme d'habitude, un 'tab settings' = 11 est le bienvenu...              ;
;'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`';
;Ceci est un programme freeware, MAIS ce n'est pas du domaine public.     ;
;Si vous utilisez tout ou partie de ce source ou d'un autre source formant;
;ma routine de soundtracker au DSP, dans un but non-lucratif, n'oubliez   ;
;pas de me le signaler.                                                   ;
;Si par contre il s'agit d'une utilisation dans le cadre d'un programme   ;
;commercial, il faudra demander mon autorisation, certes par simple       ;
;formalit‚ mais quand mˆme...                                             ;
;=========================================================================;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; D‚finitions standards, hors listing de d‚buggage ;;;;;;;;;;;;;;;;;;
	nolist
	include	'ioequ.asm'
	include	'intequ.asm'
	himem	x:$3fff,y:$3fff,p:$7fff
	list
	OPT	W

DspMixer	ident	2,0		;Mixage Soundtracker au DSP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; D‚finitions pour la taille des buffers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
freq	equ	49170		;Fr‚quence de replay d‚sir‚e
hz	equ	50		;Fr‚quence du gestionnaire


maxspl	equ	(672*50/hz+8)	;672+s‚curit‚: avanc‚e maxi en DMA.
maxech	equ	freq/hz		;Nb maxi d'‚chantillons rejou‚s.

	IF	(maxspl>$800)||(maxech>$400)
	fail	'Buffers SSI trop grands!!'
	ENDIF

BASEAD	equ	$1000		;Position P:..=Y:.. de la routine.

MixCodSize	equ	$200		;Taille approximatives
MixVarSize	equ	$100		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Macros pour acc‚der aux ports Host & SSI en polling ;;;;;;;;;;;;;;;
ReadHost	MACRO	dest
	jclr	#M_HRDF,x:<<M_HSR,*
	movep	x:<<M_HRX,dest
	ENDM

WritHost	MACRO	srce
	jclr	#M_HTDE,x:<<M_HSR,*
	movep	srce,x:<<M_HTX
	ENDM

ReadSSI	MACRO	dest
	jclr	#M_RDF,x:<<M_SR,*
	movep	x:<<M_RX,dest
	ENDM

WritSSI	MACRO	srce
	jclr	#M_TDE,x:<<M_SR,*
	movep	srce,x:<<M_TX
	ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Drivers d'interruption ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	org	p:$0		;
	jmp	<P_begin		;

	org	p:I_SSIRD		;
	movep	x:<<M_RX,x:(r3)+	;Reception SSI du DMA
	nop				;

	movep	x:<<M_RX,x:(r3)+	;Reception en overrun
	movep	x:<<M_SR,x:(r3)		;

	movep	y:(r7)+,x:<<M_TX	;Vecteur SSI-transmit, mode short
	nop				;

	movep	y:(r7),x:<<M_TX		;Idem, en underrun
	movep	x:<<M_SR,y:(r7)+	;

	org	p:I_HSTUC0		;
	jsr	>Interrupt_Mixer	;Routine globale en interruption.
	jsr	>P_loader		;Loader de programmes.

;Utilisation de r3 et r7 en interruption -> ‚quilibrage du nombre de registres
;d'adresse libres par banque m‚moire.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Pr‚paration des hostilit‚s & Corps du mixeur ;;;;;;;;;;;;;;;;;;;;;;
	org	p:$40
P_begin	movep	#1,x:<<M_PBC	;Host enable
	movep	#B_HCIE,x:<<M_HCR	;Host Command
	movep	#B_SSL|B_HPL1,x:<<M_IPR ;SSI en IPL3, Host en IPL2
	movep	#$4100,x:<<M_CRA	;SSI en 2 mots/frame, 16 bits
	movep	#$0800,x:<<M_CRB	;SSI off
	movep	#$01f8,x:<<M_PCC	;Port C en SSI
	movep	#$0008,x:<<M_PCDDR	;Idem
	andi	#%11110000,mr	;Vroom, autorise tout le monde.
	jmp	<*		;Hop, fini...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Routines en overlay, assembl‚e pour la m‚moire interne,
;;;;;;;;;;; mais charg‚es en m‚moire externe pour ‚conomiser en place.
;
;(r7,m7), (r5,m5) sont toujours en modulo,
;(r0,m0), (r2,m2) sont parfois en modulo,
;(r1,m1) est toujours en adressage line‚aire.
;(r4) n'est utilisable que pour les adressages statiques.
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
;      (m2,n2)=positions fractionnaires samples 2,3,4
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

_freeway	move	#frac1,r2		;Positions fractionnaires, et
	movec	m1,m2		;adressage lin‚aire.
	move	#buff24,r6		;
	move	x:(r2),a		;"Position" actuelle
	move	x:(r1),x0		;Incr‚ment
	move	#<$800000,x1	;Masque pour virer -E-xtension
	move	l:(r6)+,y		;1er ‚chantillon
	move	#<_nonew,r4	;
	move	y1,y:(r5)+		;

	.loop	x:<nb_ech		;Boucle hard
	add	x0,a	y0,y:(r5)+	;
	jec	(r4)		;Pour ‚viter un jec .endl (impossible)
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
	move	#buff24,r6		;
	move	x:(r2),x0		;
	move	r2,n2		;
	move	#<0,r2		;!<>!<>!<>pos_frac=0<>!<>!<>!
	move	n5,r5		;
	move	x0,x:(r2)		;
	
	move	#<_nonew,r4	;
	move	#<$800000,y0	;Masque le bit d'extension
	move	x:(r1),y1		;Incr‚ment fractionnaire
	move	l:(r6)+,x		;Premier ‚chantillon
	move	y:(r5)+,a		;Pr‚paration: r‚sultat pr‚c‚dent gauche

	.loop	x:<nb_ech		;========Attention les yeux!...========
	add	x1,a	y:(r5)-,b		;Mixe gauche - pr‚c‚dent droit
	add	x0,b	a,y:(r5)+	x:(r2),a	;Mixe droite - stocke gauche   - position
	add	y1,a	b,y:(r5)+		;avance	  - stocke droit
	jec	(r4)		;d‚borde ?
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
	move	x:(r1+n1),y0	;            volume droit
	move	x:(r1)-,a		;Parit‚ du sample
	move	x:(r1+n1),y1	;volume gauche
	move	x:rx_mode,b	;
	tst	b		;
	jne	<_Host		;

_Dma	move	x:(r0)+,x1		;1er sample
	tst	a	#<$80,b1	;Parit‚ de l'envoi ?
	jne	<_impair		;
_pair	tfr	x1,a	#<$ff0000,x0 ;Oui, donc tenir compte du 1er octet.
	and	x0,a		;On isole ainsi le gros de la convertion
	move	a1,x0		;pour aller le plus vite&court possible.
	mpyr	y1,x0,a		;
	mpyr	y0,x0,a	a,x:(r6)	;Applique les deux volume, r‚sultat
	move	a,y:(r6)+		;dans L (X:Y)
_impair	move	b1,x0		;$xxyy00*$000080=$0000xx yy0000
	mpy	x1,x0,a	b1,b	;(*):b1->b <=>b2=$00
	move	a0,x1		;
	mpyr	y1,x1,a	#<$ff0000,x0
	mpyr	y0,x1,a	a,x:(r6)	;
	move	a,y:(r6)+		;

	do	x:(r1)-,_enddma	;<<>>Comme on a d‚ja d‚cod‚ 1 mot<<>>
	move	x:(r0)+,a		;<<>>on travail sur longueur-1 !!<<>>
	and	x0,a	a,x1	;
	move	a,x0		;
	mpyr	y1,x0,a		;
	mpyr	y0,x0,a	a,x:(r6)	;
	move	a,y:(r6)+	b,x0	;(*):Comme b2=0, pas de limitation surprise
	mpy	x1,x0,a		;
	move	a0,x1		;
	mpyr	y1,x1,a	#<$ff0000,x0
	mpyr	y0,x1,a	a,x:(r6)	;
	move	a,y:(r6)+		;
_enddma	rts			;


_Host	clr	b	#<$ff0000,x0
	move	#$8000,b0		;

	.loop	x:(r1)-		;
	move	x:(r0)+,a		;La mˆme chose, mais cette fois pour
	and	x0,a	a,x1	;s‚parer les trois octets d'un mot.
	move	a,x0		;
	mpyr	y1,x0,a	#<$80,b1	;
	mpyr	y0,x0,a	a,x:(r6)	;
	move	a,y:(r6)+	b,x0	;
	mpy	x1,x0,a	#<$ff0000,x0
	move	a0,a		;
	and	x0,a		;
	move	a,x0		;
	mpyr	y1,x0,a	b0,b1	;
	mpyr	y0,x0,a	a,x:(r6)	;
	move	a,y:(r6)+	b,x0	;
	mpy	x1,x0,a		;
	move	a0,x1		;
	mpyr	y1,x1,a	#<$ff0000,x0
	mpyr	y0,x1,a	a,x:(r6)	;
	move	a,y:(r6)+		;
	.endl			;
	rts			;

MixOverlaySize equ	@LCV(L)-MixOverlay	;Taille de la chose.
	org	p:@LCV(L)		;Routines non-overlay, … la suite.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; HostCommand de chargement de programmes externes ;;;;;;;;;;;;;;;;;;
P_loader	andi	#%11110000,mr	;IPL1 & pas de scaling
	movec	#$ffff,m0		;Adressage lin‚aire
	move	#<1,n0		;
	movec	sp,r0		;...Pointeur de pile...
	ori	#%00000001,mr	;
	lua	(r0)-n0,r0		;...enleve un niveau qui est celui
	move	#_gethost,r1	;
	movec	r0,sp		;...de l'appel … P_loader !
_section	jsr	(r1)		;Type de section (P,X,Y=0,1,2)
	move	#$4000/2,x1	;On charge tout en P:, sachant que
	mpy	x0,x1,a		;P:$0000=Y:$0000 / P:$4000=X:$0000
	jmi	<0		;Si Type<0, fini!, et ex‚cute.
	jsr	(r1)		;R‚cupere l'adresse.
	add	x,a		;Seul a0+x0 compte...
	move	a0,r0		;
	jsr	(r1)		;Taille de la section.
	do	x0,_endsect	;
	jsr	(r1)		;
	movem	x0,p:(r0)+		;Pof, charge comifo !
_endsect	jmp	_section		;Il en reste encore ?

_gethost	ReadHost	x0		;
	rts			;

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
	move	r0,x:save_r0	;Commance par sauver tous les
	move	m0,x:save_m0	;registres utilis‚s.
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
	move	r4,x:(r0)+		;
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

	move	x:<nb_ech,a	;Sauve le peu de m‚moire X
	move	a,x:(r0)+		;interne.
	move	x:<pos_frac,a	;
	move	a,x:(r0)+		;

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
	tst	a		;(-2   , -1    )+Restart
	jpl	_letsgo		;
_restart	movep	#$0800,x:<<M_CRB	;Remet tout en ordre: SSI off
	clr	b	#restitbuf+2*maxech,r7
	movec	#$fff,m7		;Modulo buffer.
	move	#restitbuf,r5	;
	rep	#$fff		;
	move	b,l:(r7)+		;Efface tous les buffers
	move	b,l:(r7)+		;
	move	#lvol1,r0		;
	rep	#last_get1-lvol1	;Efface aussi les donn‚es du sample
	move	b,x:(r0)+		;
	rep	#3		;
	move	r5,x:(r0)+		;last_get1&2, last_calc1
	move	#<2,b1		;N‚cessite b=0
	add	b,a	#nspl1,r0	;Corrige le mode de transfert.
	move	#<nspl2-nspl1,n0	;nsplx<>0 sinon plantage.
	rep	#4		;
	move	b,x:(r0)+n0	;
	move	#maxech,b		;Sans oublier nb_ech
	move	b,x:<nb_ech	;
	movep	#$5800,x:<<M_CRB	;SSI-OUT on, SSI-IN off.
;SSI on: ExClock,Network,Tmit,Tirq +>+>+ SSI off/on -> alignement de frame
	movep	b,x:<<M_HTX	;Signale la fin de l'init...
_letsgo	move	a,x:r_rx_mode	;Range mode de transfert.
	movec	m7,m5		;
	ENDM

;;;;;;;;;;;
GetDelta	MACRO
	move	r7,a		;delta = nombre d'‚chantillons …
	clr	b	r5,x0	;calculer pour boucler le buffer.
	sub	x0,a	#$800,x0	;Si delta<0, alors prendre
	tmi	x0,b		;delta MOD taille_buffer
	addr	b,a	#maxech/2,b ;(Nb: ‚chantillons st‚r‚o -> asr)
	addr	b,a		;Moyenne les ‚carts pour stabiliser.
	move	a,x:r_nb_ech	;Stocke comifo
	ENDM

;;;;;;;;;;; R‚ception des parametres de mixage par le port Host
GetVoices	MACRO
	move	#r_bala1,r1	;Info 1ere voix
	move	#(r_bala2-r_bala1)-4,n1
	move	#r_fracs,r2	;
	.loop	#4		;
	ReadHost	x:(r1)+		;Re‡oie les parametres: balance,
	ReadHost	x:(r1)+		;Volume
	ReadHost	x1		;Puis l'incr‚ment de fr‚quence
	move	x1,x:(r1)+		;
	move	x:r_nb_ech,x0	;r_nb_ech
	mpy	x1,x0,b	#<0,a	;        *incr‚ment=avanc‚e
	move	x:(r2),a0		;en bits faibles !
	add	b,a		;
	WritHost	a1		;largeur sample ce coup-ci,
	move	a0,x:(r2)+		;et resauver sa fraction.
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
	move	#<4+16,n2		;<<>>Corrige 4* -1 du chargement DMA<<>>
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
	move	r2,x:last_get1	;
	WritHost	r2		;On est pret … recevoir le sample..
	ReadHost	x0		;Ici, 030 et DSP sont 100% synchro
	tst	a		;
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
	.endl			;
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
	move	x:(r0)+,r4		;
	move	x:(r0)+,r5		;
	move	x:(r0)+,m5		;
	move	x:(r0)+,n5		;

	move	#<$40,r6		;
	.loop	#MixOverlaySize	;
	move	x:(r0)+,x0		;
	movem	x0,p:(r6)+		;
	.endl			;

	move	x:(r0)+,x0		;
	move	x0,x:<nb_ech	;
	move	x:(r0)+,x0		;
	move	x0,x:<pos_frac	;

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

	jmac	RestoreAll		;
	rti			;Retour … l'envoyeur

	IF	(*-MixOverlay)>MixCodSize
	fail	'Code plus grand que pr‚vu!!'
	ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Variables 'lentes' de travail global.
	org	x:(BASEAD-maxspl-MixVarSize)
			;Zone de travail, pour le mixage.
lvol1	ds	1	;Volume gauche voix 1
rvol1	ds	1	;Volume droit
bala1	ds	1	;Balance
avol1	ds	1	;Volume original, amiga
incr1	ds	1	;Incr‚ment de fr‚quence
nspl1	ds	1	;Nb de paquets de 2 … traiter
npar1	ds	1	;Parit‚ de l'envoi DMA

lvol2	ds	1
rvol2	ds	1
bala2	ds	1
avol2	ds	1
incr2	ds	1
nspl2	ds	1
npar2	ds	1

lvol3	ds	1
rvol3	ds	1
bala3	ds	1
avol3	ds	1
incr3	ds	1
nspl3	ds	1
npar3	ds	1

lvol4	ds	1
rvol4	ds	1
bala4	ds	1
avol4	ds	1
incr4	ds	1
nspl4	ds	1
npar4	ds	1

rx_mode	ds	1


r_lvol1	ds	1	;Ceci est la zone de r‚ception des
r_rvol1	ds	1	;infos pour les samples. Elle est
r_bala1	ds	1	;remplie par le GetVoice, et
r_avol1	ds	1	;transf‚r‚e en zone de travail
r_incr1	ds	1	;avec un d‚lai pour la reception.
r_nspl1	ds	1
r_npar1	ds	1
r_lvol2	ds	1
r_rvol2	ds	1
r_bala2	ds	1
r_avol2	ds	1
r_incr2	ds	1
r_nspl2	ds	1
r_npar2	ds	1
r_lvol3	ds	1
r_rvol3	ds	1
r_bala3	ds	1
r_avol3	ds	1
r_incr3	ds	1
r_nspl3	ds	1
r_npar3	ds	1
r_lvol4	ds	1
r_rvol4	ds	1
r_bala4	ds	1
r_avol4	ds	1
r_incr4	ds	1
r_nspl4	ds	1
r_npar4	ds	1
r_rx_mode	ds	1
r_nb_ech	ds	1

frac1	ds	1	;Positions d‚cimales actuelles
frac2	ds	1
frac3	ds	1
frac4	ds	1
r_fracs	ds	4	;Idem, mais pour r‚ception
;Nb: On commande la r‚ception R(n+1), et on mixe M(n). Or fracx correspond au
;d‚part de M(n), alors que pour R(n+1) on a besoin des positions terminales
;de M(n). Donc on a besoin d'un double pour la r‚ception, dont la coh‚sion est
;assur‚ par l'‚quit‚ du calcul (par n*add .. en mix, et mpy n,.. en r‚ception)
;La seule diff‚rence est un facteur 2 dans les valeurs.

last_get1	ds	1	;Points de d‚part et de fin, pour la
last_get2	ds	1	;r‚ception des samples.
last_calc1	ds	1	;Idem pour le mixage. Ils renseignent
last_calc2	ds	1	;sur l'interruption pr‚c‚dente.

save_r0	ds	1
save_m0	ds	1
save_n0	ds	1
save_a2	ds	1
save_a1	ds	1
save_a0	ds	1
save_b2	ds	1
save_b1	ds	1
save_b0	ds	1
save_r1	ds	1
save_m1	ds	1
save_n1	ds	1
save_r2	ds	1
save_m2	ds	1
save_n2	ds	1
save_r4	ds	1
save_r5	ds	1
save_m5	ds	1
save_n5	ds	1
save_code	ds	MixOverlaySize
save_xram	ds	2
save_r6	ds	1
save_m6	ds	1
save_n6	ds	1
save_x1	ds	1
save_x0	ds	1
save_y1	ds	1
save_y0	ds	1
re_send1	ds	1
re_send2	ds	1

	IF	(*-lvol1)>MixVarSize
	fail	'Variables plus grandes que pr‚vu!!'
	ENDIF
;;;;;;;;;;; Travail de la boucle de mixage, en m‚moire interne
	org	x:$0
pos_frac	ds	1
nb_ech		ds	1
;;;;;;;;;;; Buffers de mixage
	org	l:BASEAD-maxspl
buff24	ds	maxspl

	org	y:BASEAD
restitbuf	dsm	$1000

	org	x:BASEAD
receptbuf	dsm	$1000
