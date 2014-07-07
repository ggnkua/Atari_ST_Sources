*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*           Installation du VertiConf-Boot pour  Falcon 030/16            *
*                                  V1.4                                   *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight NulloS//DNT-Crew 1993*
	opt	o+
	include	tos_030.s		;Macros TOS 4.0x
	include	hard_sys.s		;Variables systŠmes
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	SECTION	TEXT		;
	StartUp			;Pr‚pare la m‚moire (Mshrink)
	bra	The_suite		;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	include	gem_aes.s		;Macros AES.
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	SECTION	TEXT		;
The_suite	Call_AES	appl_init		;Demande l'AES.
	move.w	d0,ap_id		;
	bmi.s	exit		;AES ok ?
	move.l	#"_MCH",d0		;
	bsr.s	Look_Cookie	;recherche un cookie
	bne.s	big_gag		;
	swap	d0		;
	subq.w	#3,d0		;Si pas Falcon...
	bne.s	big_gag		;
	tst.l	d7		;
	bne.s	acc_run		;On est en accessoire ?.
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
prg_run	bsr	do_installboot	;Lancement par programme:
break	Call_AES	appl_exit		;un seul appel
exit	Gemdos	Pterm0		;Cassos
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
big_gag	lea	Falcon(pc),a0	;Faudrait peut-ˆtre mieux
	bsr	Form_Alert		;avoir un falcon...
	bra.s	break		;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
Look_Cookie
	movem.l	d0/a2,-(sp)	;
	clr.l	-(sp)		;La fonction Super du Gemdos
	Gemdos	Super		;est une exception … la rŠgle:
	move.l	d0,-(sp)		;les registre D0-D1/A0-A1 sont
	movea.l	cookie_jar.w,a2	;modifi‚s, et non pas seulement
	Gemdos	Super		;D0/A0. Donc r‚sultat en A2
	move.l	a2,d0		;
	beq.s	.lc_none		;
.scan	move.l	(a2)+,d0		;
	beq.s	.lc_none		;
	addq.l	#4,a2		;
	cmp.l	(sp),d0		;
	bne.s	.scan		;
	move.l	-(a2),(sp)		;
	sub.w	d0,d0		;Z=1
	bra.s	*+4		;
.lc_none	addq.w	#1,d0		;Z=0
	movem.l	(sp)+,d0/a0	;
	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
acc_run	move.w	ap_id,int_in	;
	move.l	#titlebar,addr_in	;D‚claration
	Call_AES	menu_register	;comme accessoire.
	move.w	d0,d6		;No d'ordre de l'AES
	lea	msg_buf(pc),a6	;

.acc_bcl	move.l	a6,addr_in		;
	Call_AES	evnt_mesag		;Attend un message
	cmpi.w	#AC_OPEN,(a6)	;Ouverture d'accessoire ?
	bne.s	.acc_bcl		;
	cmp.w	8(a6),d6		;On est concern‚ (test inutile,
	bne.s	.acc_bcl		;mais prudence..)
	bsr.s	do_installboot	;
	bra.s	.acc_bcl		;recommence
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
do_installboot
	lea	present(pc),a0	;Routine principale
	bsr	Form_Alert		;Petite page de pub.
	subq.w	#1,d0		;Choix du continu ?
	bne	.quit		;
.doit_bcl	lea	volume(pc),a0	;
	bsr	Form_Alert		;
	move.w	(volset,d0.w*2),volsetcode;r‚cupŠre le r‚glage kivabien
				;Putain ca jette cet adressage.
	lea	insertdisk(pc),a0	;Comme son nom l'indique..
	bsr	Form_Alert		;
	subq.w	#1,d0		;
	bne.s	.quit		;Idem: choix='Continue' ?

.read	move.w	#1,-(sp)		;Lire le boot-sector: 1 secteur
	clr.l	-(sp)		;
	pea	1.w		;Format condens‚: piste 0
	clr.l	-(sp)		;face 0
	pea	buffsect(pc)	;
	Xbios	Floprd		;hop
	tst.w	d0		;Y'a un problŠme ?
	bne.s	.floperr		;
	lea	buffsect+30(pc),a1	;Installe notre programme au
	move.w	#$601c,-30(a1)	;30Šme octet. $601c=bra.s *+30
	lea	falboot(pc),a0	;
.copy	move.w	(a0)+,(a1)+	;
	cmpa.l	#falbend,a0	;
	blt.s	.copy		;
	lea	buffsect(pc),a1	;Maintenant, calcule le checksum pour
	moveq	#1,d0		;rendre le boot ex‚cutable.
	move.w	#$1234,d1		;
.checksum	sub.w	(a1)+,d1		;
	addq.b	#1,d0		;de 1+1 … 255+1, soit donc
	bne.s	.checksum		;255 valeurs...
	move.w	d1,(a1)		;Hop, la 256Šme est le checksum
.write	move.w	#1,-(sp)		;Et maintenant, on r‚‚crit le tout
	clr.l	-(sp)		;histoire de ne pas avoir boss‚
	pea	1.w		;pour des prunes.
	clr.l	-(sp)		;
	pea	buffsect(pc)	;
	Xbios	Flopwr		;
	tst.w	d0		;Detection d'erreur.
	bne.s	.floperr		;

.next	lea	nextone(pc),a0	;On s'en refait une petite ?
	bsr	Form_Alert		;
	subq.w	#1,d0		;
	beq	.doit_bcl		;C'est selon..
.quit	rts			;
.floperr	lea	diskerr(pc),a0	;
	bsr	Form_Alert		;
	bra.s	.next		;
	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
TAG	equr	d4		;Histoire d'etre plus clair...
	
falboot	lea	falconfig(pc),a1	;Adresse du code r‚sident
	move.l	(a1),TAG		;Signature VCBx pour signaler la 
	lea	$300000,a3		;pr‚sence. Adresse d'installation
	cmp.l	(a3),TAG		;D‚j… install‚ ?
	bne.s	.install		;
	jmp	4(a3)		;OUI:ben vazimimil !
.install	move.l	#$200000,$42e.w	;Falcon en 2Mo de m‚moire.
	moveq	#(falbend-falconfig)/4,d0;Taille du code r‚sident
.copy	move.l	(a1)+,(a3)+	;que l'on recopie sagement
	dbf	d0,.copy		;(tag inclu)
	jmp	([4.w])		;Un p'tit reset des familles.

falconfig	dc.b	'VCB',$14		;Le TAG en question
	move.b	#2,memctrl.w	;Confirme la configuration 2Mo
	move.b	#2,$ffff8001.w	;hoplaboum. Pour finir,
	subi.l	#$8000,_memtop.w	;replace le memtop comifo.
	move.w	#-1,-(sp)		;
	Xbios	-Vsetmode		;Demande le mode vid‚o.
	andi.w	#%1111111000110000,d0	;Passe en compatible ST 320*200 16 couleurs
	ori.w	#%0000000010000010,d0	;
	move.w	d0,-(sp)		;mode
	move.w	#3,-(sp)		;resol=3=Falcon
	clr.l	-(sp)		;r‚allouer les ‚crans
	clr.l	-(sp)		;
	Xbios	-Setscreen030	;Roulmapoul
	pea	texte(pc)		;Un p'tit message de bienvenue.
	Gemdos	-Cconws		;
	
	;(NB:A3=$300000, cf falboot)
	lea	$700+64*4.w,a0	;D‚place l'arborescence PMMU 
	adda	a0,a3		;hors d'atteinte,en $300700
	movea.l	a3,a2		;Travaille dessus.
	moveq	#64-1,d0		;64 mots-longs
	moveq	#0,d1		;4 pointeurs … reloger
.copy	move.w	-(a0),-(a2)	;
	move.w	-(a0),d2		;
	bne.s	.nxt		;Pointeur $000007xx ?
	move.w	d1,d2		;
	moveq	#$30,d1		;
.nxt	move.w	d2,-(a2)		;
	dbf	d0,.copy		;Suivant...
	pmove.d	crp,(a3)		;change le pointeur de PMMU
	move.l	a2,4(a3)		;sans toucher au contr“leur
	pmove.d	(a3),crp		;lui-mˆme

	moveq	#6,d7		;R‚glages sonores: 
	moveq	#3,d6		;(6,3);(5,3);(4,3);(1,$x0);(0,$x0)
.soundsys	cmp.w	d6,d7		;couple (3,3) ?
	bne.s	.soundset		;
	moveq	#1,d7		;Oui->passe au couple (1,$x0)
volsetcode	equ	*+2		;
	move.w	#$00,d6		;La valeur est modifi‚e en court
.soundset	move.w	d6,-(sp)		;de route..
	move.w	d7,-(sp)		;Un couple...
	Xbios	-soundcmd		;
	dbf	d7,.soundsys	;Suivant


.pcm_frq	move.w	#1,-(sp)		;Passe le DMA en 50Khz pour STE.
	clr.l	-(sp)		;De toutes facons, les jeux qui
	pea	8.w		;utilisent le DMA sont rares..
	Xbios	-devconnect	;C'est un euph‚misme !!
	

	lea	$100*6(a3),a2	;Cr‚e le d‚tournement des
	suba.l	a1,a1		;vecteurs du 030.
.copyvec	move.l	a3,(a2)+		;Adresse du vecteur No A1
	move.l	#$4ef001e1,(a3)+	;Code pour JMP ([xx.w]) saut
	move.w	a1,(a3)+		;… l'ancien vecteur
	addq.l	#4,a1		;vecteur suivant
	cmpa.w	#$400,a1		;fini ?
	bne.s	.copyvec		;
	move.l	$20.w,$20(a3)	;Mais privilŠge bloqu‚ (move sr)
	lea	scrutvbl(pc),a1	;et vbl pour configuration.
	move.l	a1,$70(a3)		;Ils deviennent intouchables et
	movec	a3,vbr		;agissent en permanence !!!.

	pea	1.w		;Le DMA STE est branch‚ sur l'event
	Xbios	-setinterrupt	;du Timer A.

	move.b	#$45,$ffff8007.w	;Hardware en mode STE 16Mhz

.boot	clr.w	-(sp)		;Force le boot sur A:\ (mais
	Gemdos	-Dsetdrv		;le disque dur reste actif)
	Gemdos	-Crawcin		;Attendre un p'tit coup
	lea	24+5*6+12+6+4+2(sp),sp;r‚tablit la pile globalement.
	jsr	([$47a.w])		;Booter le disque.
	tst.w	d0		;Boot ex‚cutable ?
	bne.s	.fin		;
	move.l	$4c6.w,a0		;Adresse du boot.
	cmp.l	30+falconfig-falboot(a0),TAG ; C'est encore nous ?
	beq.s	.fin		;alors abrŠge.
	jsr	(a0)		;Oui, alors vazyraoul
.fin	rts			;


scrutvbl	movem.l	d0-d1/a0,-(sp)	;VBL de configuration.
	lea	.sv_count(pc),a0	;rotation de $1111 -> 4 bits
	ror.w	(a0)+		;espac‚s qui diminuent le nombre
	bcc.s	.sv_end		;de tests clavier parasites.
	movec	cacr,d1		;Registre du cache.
	btst	#0,$fffffc00.w	;Intercepte le clavier, mais
	bne.s	.sv_end		;seulement quand y'a pas d'IT
	move.b	$fffffc02.w,d0	;pour ne pas parasiter.
	bmi.s	.sv_cflag		;Touche relach‚e ? -> fini
	tst.b	(a0)		;Alternate enfonc‚e ?
	bne.s	.sv_alt		;Non, ->est ce le cas maintenant ?
	subi.b	#$69,d0		;Pav‚ num‚rique: '9'
	bmi.s	.sv_end		;
	beq.s	.sv_hp		;->hp on/off
	subq.b	#2,d0		;
	bmi.s	.sv_ci_on		;'4'
	beq.s	.sv_cd_on		;'5'
	subq.b	#2,d0		;
	bmi.s	.sv_16Mhz		;'6'
	beq.s	.sv_ci_off		;'1' <-WARNING !!
	subq.b	#2,d0		;
	bmi.s	.sv_cd_off		;'2'
	beq.s	.sv_8Mhz		;'3'
	subq.b	#1,d0		;
	bne.s	.sv_end		;

.sv_burst	eori.w	#%0001000000010000,d1	;Commute le Burst.
	bra.s	.sv_set		;
.sv_ci_on	bset.l	#0,d1		;Commute le cache.
	bra.s	.sv_set		;Bref, rien de bien grave.
.sv_ci_off	bclr.l	d0,d1		;WARNING: OPTIMISATION
	bra.s	.sv_set		;IL FAUT QUE D0=0 APRES
.sv_cd_on	bset.l	#8,d1		;LES TESTS CLAVIERS
	bra.s	.sv_set		;
.sv_cd_off	bclr.l	#8,d1		;
.sv_set	movec	d1,cacr		;RŠgle le cache
.sv_cflag	st	(a0)		;Alternate prise en compte->relache
.sv_end	movem.l	(sp)+,d0-d1/a0	;
	jmp	([$70.w])		;Saute … la VBL actuelle.

.sv_alt	cmpi.b	#$38,d0		;D‚tection Alternate: ok ?
	sne	(a0)		;
	bra.s	.sv_end		;

.sv_8Mhz	andi.b	#~(1<<0+1<<2),$ffff8007.w;Commute … 8 ou 16 Mhz
	bra.s	.sv_cflag		;
.sv_16Mhz	ori.b	 #(1<<0+1<<2),$ffff8007.w;
	bra.s	.sv_cflag		;

.sv_hp	move.b	#$e,yam_ctrl.w	;
	move.b	yam_read.w,d0	;
	bchg	#6,d0		;Commute sagement le HP.
	move.b	d0,yam_write.w	;
	bra.s	.sv_cflag		;

.sv_count	dc.w	%1000100010001000
.sv_flag	dc.b	-1
texte	equ	*
	dc.b	"VertiConf V1.4 =¯ Insert disk",$d,$a,0

falbend
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
present	dc.b	2,"[0][ Cr‚ation du VertiConf Boot | pour Falcon030/16. Ce boot    | permet de configurer votre | Falcon … volont‚. | "
	dc.b	"V1.4 (C)DNT-Crew 1993 ][ Continue | Annule ]",0
insertdisk	dc.b	1,"[3][ Ins‚rez la disquette sur | laquelle va etre plac‚ le | boot de configuration... ][ Ok | Annule ]",0
volume	dc.b	1,"[2][ Comment faut-il r‚gler le | niveau sonore ? ][ Mini | Moyen | Maxi ]",0
nextone	dc.b	2,"[2][ | On s'en refait une petite ? | ][ Continue | Annule ]",0
diskerr	dc.b	1,"[1][ | Erreur de lecture/‚criture !| ][ Arg ]",0
Falcon	dc.b	1,"[1][ | Vaut mieux avoir un Falcon | pour se servir de ce | programme !!.][ J'achŠte ]",0
titlebar	dc.b	"  ConfigBoot",0
	EVEN
volset	dc.w	$00,$f0,$70,$00
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	SECTION	BSS
buffsect	ds.w	512
msg_buf	ds.w	16
stack	ds.w	512
