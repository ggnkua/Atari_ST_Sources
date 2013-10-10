; Replay de soundtrack DSP

	opt	p=68030

	TEXT


writhost	macro
wrhst\@:	btst	#1,$ffffa202.w
	beq.s	wrhst\@
	endm



interruption:
;------------------------------------------------------------------------------
;	Gestion de la partition
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;	Envoi des samples au DSP
;	Les samples sont sign‚s. Toutes les informations (rep, pos...)
;	sont donn‚es en octets. Un sample non boucl‚ doit avoir un
;	replen … 2 et reppos = longueur - 2. Tout sample doit avoir
;	un buffer de bouclage.
;------------------------------------------------------------------------------

	move.w	nbrvoies(pc),d0	; d0 = compteur de voie
	lea	info_track(pc),a0	; a0 pointe sur le tableau d'infos des voies
	lea	$ffffa204.w,a2	; Penser … optimiser avec ces registres
	lea	$ffffa206.w,a3
	lea	$ffffa202.w,a4	; ISR
sendsamloop:
	tst.w	onoff_t(a0)	; Teste si la voie est active ou non
	bne.s	sendsam_voieon
	writhost
	move.l	#0,$ffffa204.w	; Voie ‚teinte
	bra	sendsam_next
sendsam_voieon:
	writhost
	move.l	#1,$ffffa204.w	; Voie on
	move.w	vol_t(a0),d1
	move.w	d1,d2
	mulu.w	balg_t(a0),d1	; d1 = volume gauche
	writhost
	move.l	d1,$ffffa204.w
	mulu.w	bald_t(a0),d2	; d2 = volume droit
	writhost
	move.l	d2,$ffffa204.w
	move.w	per_t(a0),d1
	move.w	d1,d2
	lea	dsp_periodetable(pc),a1
	writhost			; Envoie la p‚riode du sample
	move.l	(a1,d1.w*4),$ffffa204.w
	move.w	#$1ac,d1		; P‚riode "soundtrack" du DO 2
	mulu.w	freq_do2_50(pc),d1	; Calcule le nombre d'‚chantillons
	divu.w	d2,d1		; … envoyer en 1 VBL
	ext.l	d1		; d1 = N
	move.l	adrsam_t(a0),a1	; a1 = adresse du sample
	add.l	pos_t(a0),a1
	btst	#0,pos_t+3(a0)
	beq.s	sendsam_even	; Adresse de d‚but de bloc paire

	move.l	d1,d2		; l… c'est impair
	subq.l	#2,d2
	lsr.w	#1,d2		; d2 = N/2-1 arrondi par d‚faut
	subq.l	#1,d1
	addq.l	#1,pos_t(a0)
	writhost
	move.l	d2,$ffffa204.w	; Envoie le nbr de mots (2 ‚chantillons)
	writhost
	move.w	#1,$ffffa206.w	; Adresse impaire
	writhost
	move.b	(a1)+,$ffffa207.w	; Envoie 1 ‚chantillon -> adresse paire
	bra.s	sendsam_transfert

sendsam_even:			; L… c'est pair
	move.l	d1,d2
	subq.w	#1,d2
	lsr.w	#1,d2		; d2 = N/2-1 arrondi par excŠs
	writhost
	move.l	d2,$ffffa204.w	; Envoie le nbr de mots (2 ‚chantillons)
	writhost
	move.w	#0,$ffffa206.w	; Adresse paire

sendsam_transfert:
	move.l	reppos_t(a0),d2
	add.l	replen_t(a0),d2	; d2 = longueur
	sub.l	pos_t(a0),d2	; d2 = nbr d'‚chantillons avant la fin
	beq.s	sendsam_transloop	; Si pos = longueur, passe en boucle
	cmp.l	d1,d2
	blt.s	sendsam_transpreloop	; S'il y a un bouclage

	add.l	d1,pos_t(a0)	; Mise … jour de la nouvelle position
	lsr.w	#1,d1		; Il n'y a pas de bouclage, transfert simple
	subq.w	#1,d1		; A partir de 0
	moveq	#1,d2
sendsam_loopt1:			; Transfert !
	btst	d2,(a4)
	beq.s	sendsam_loopt1
	move.w	(a1)+,(a3)
	dbra	d1,sendsam_loopt1
	bra.s	sendsam_next

sendsam_transpreloop:
	move.l	d1,d3
	sub.l	d2,d1
	lsr.w	#1,d2
	subq.w	#1,d2
	moveq	#1,d3
sendsam_loopt2:			; Transfert !
	btst	d3,(a4)
	beq.s	sendsam_loopt2
	move.w	(a1)+,(a3)
	dbra	d2,sendsam_loopt2

sendsam_transloop:
	move.l	rbuffer_t(a0),a1	; a1 pointe sur le buffer de boucle
	lsr.w	#1,d1
	subq.w	#1,d1
	moveq	#1,d2
sendsam_loopt3:			; Transfert !
	btst	d2,(a4)
	beq.s	sendsam_loopt3
	move.w	(a1)+,(a3)
	dbra	d1,sendsam_loopt3

	move.l	pos_t(a0),d4	; Calcul de la position suivante
	add.l	d3,d4
	sub.l	reppos_t(a0),d4
	divul.l	replen_t(a0),d3:d4
	add.l	reppos_t(a0),d3
	move.l	d3,pos_t(a0)	; pos = ((pos + N - rep) MOD replen) + rep

sendsam_next:
	add.l	#next_t,a0
	dbra	d0,sendsamloop
	writhost
	move.l	#2,$ffffa204.w	; Plus de voie … mixer

	rte




	DATA

nbrvoies:		dc.w	4
freq_do2:		dc.w	8200	; Fr‚quence de restitution du DO 2
freq_do2_50:	dc.w	164	; Pour 1/50Šme de seconde
dsp_voltable:	; Volumes G/D pour balances de 0 … F
		dc.w	$40,$00,$3C,$04,$38,$08,$34,$0C
		dc.w	$30,$10,$2C,$14,$28,$18,$24,$1C
		dc.w	$1C,$24,$18,$28,$14,$2C,$10,$30
		dc.w	$0C,$34,$08,$38,$04,$3C,$00,$40




; Bloc de descritption de l'‚tat actuel de chaque voie
	rsreset
vol_t:	rs.w	1	; Volume courant (0-64)
balg_t:	rs.w	1	; Balance courante gauche (0-64)
bald_t:	rs.w	1	; Balance droite (0-64)
per_t:	rs.w	1	; P‚riode courante (format "soundtracker")
adrsam_t:	rs.l	1	; Adresse du sample
pos_t:	rs.l	1	; Position dans le sample
reppos_t:	rs.l	1	; Position de r‚p‚tition du sample
replen_t:	rs.l	1	; Longueur de bouclage du sample	
onoff_t:	rs.w	1	; 0 = voie off, 1= voie on
rbuffer_t:	rs.l	1	; Adresse du buffer de r‚p‚tition de l'instrument
next_t:	rs	1

; Bloc de description des samples (au d‚but d'un module)
	rsreset
name_s:	rs.b	22	; Nom du sample
length_s:	rs.w	1	; Longueur du sample	(/2)
ftune_s:	rs.b	1	; Finetune
vol_s:	rs.b	1	; Volume
repeat_s:	rs.w	1	; Point de bouclage	(/2)
replen_s:	rs.w	1	; Longueur de boucle	(/2)
next_s:	rs	1





	BSS

info_track:	ds.b	16*next_t	; Informations sur les 16 voies
dsp_periodetable:	ds.l	900	; Table de p‚riodes pour le DSP (50 KHz)
repeatbuffer:	ds.b	31*2048	; Buffers de r‚p‚tition des 31 samples
