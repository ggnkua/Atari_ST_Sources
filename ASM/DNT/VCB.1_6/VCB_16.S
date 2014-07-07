*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*           Installation du VertiConf-Boot pour  Falcon 030/16            *
*                                  V1.6                                   *
*           --------------------------------------------------            *
*                                                                         *
* Ces sources n‚cessitent les fichiers tos_030.s et hard_sys.s distribu‚s *
* dans le DNT-Paper 5...                                                  *
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
The_suite	aes	appl_init		;Demande l'AES.
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
break	aes	appl_exit		;un seul appel
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
	aes	menu_register	;comme accessoire.
	move.w	d0,d6		;No d'ordre de l'AES
	lea	msg_buf(pc),a6	;

.acc_bcl	move.l	a6,addr_in		;
	aes	evnt_mesag		;Attend un message
	cmpi.w	#AC_OPEN,(a6)	;Ouverture d'accessoire ?
	bne.s	.acc_bcl		;
	cmp.w	8(a6),d6		;On est concern‚ (test inutile,
	bne.s	.acc_bcl		;mais prudence..)
	bsr.s	do_installboot	;
	bra.s	.acc_bcl		;recommence
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
do_installboot
	clr.l	-(sp)		;
	Gemdos	Super		;
	move.l	d0,-(sp)		;
	move.l	phystop.w,d7	;
	Gemdos	Super		;
	cmpi.l	#$200000,d7	;2Mo = D‚j… pr‚sent ??
	bne.s	.nopi1		;
	move.l	falconfig(pc),d0	;Notre tag est l… ??
	lea	$300000,a6		;
	cmp.l	(a6),d0		;
	bne.s	.nopi1		;
	lea	$1000+falbend-falconfig(a6),a6;
	cmpa.l	(a6),a6		;
	bne.s	.nopi1		;
	lea	savepi1(pc),a0	;Oui, demande s'il faut
	bsr	Form_Alert		;la sauver..
	subq.w	#1,d0		;
	bne.s	.nopi1		;
	lea	fpath(pc),a0	;
	lea	fmask(pc),a1	;
	lea	fname(pc),a2	;
	lea	pathname(pc),a3	;
	moveq	#0,d0		;
	bsr	FileSelect		;Un petit fileselect
	beq.s	.nopi1		;absolument pas beau
	clr.w	-(sp)		;
	pea	(a3)		;Tente d'ouvrir
	Gemdos	Fcreate		;
	move.w	d0,d7		;
	bmi.s	.nopi1		;Pas de d‚tection d'erreur
	clr.l	(a6)+		;Sauvegarde a eu lieu
	lea	bufpi1+2(pc),a1	;
	move.w	#(32000+32)/4-1,d0	;Hop, vazimimil, palette+‚cran
	move.l	(a6)+,(a1)+	;
	dbf	d0,*-2		;
	pea	bufpi1(pc)		;32066 octets,c'est Degas-Elite
	pea	32066.w		;
	move.w	d7,-(sp)		;
	Gemdos	Fwrite		;
	move.w	d7,-(sp)		;
	Gemdos	Fclose		;
	
.nopi1	lea	present(pc),a0	;Routine principale
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
	jmp	(a3)		;OUI:ben vazimimil !
.install	move.w	#$20,phystop.w	;Falcon en 2Mo de m‚moire.
	moveq	#(falbend+4-falconfig)/4,d0;Taille du code r‚sident
.copy	move.l	(a1)+,(a3)+	;que l'on recopie sagement
	dbf	d0,.copy		;(tag inclu)
	jmp	([4.w])		;Un p'tit reset des familles.

__sp	set	0		;Correction de pile initiale.
falconfig	moveq	#2,d0		;TAG={moveq #2,d0|move.b d0,}
	move.b	d0,memctrl.w	;Confirme la configuration 2Mo
	move.b	d0,$ffff8001.w	;hoplaboum. Pour finir,
	clr.l	-(sp)		;puis en passe en r‚solution
	clr.l	-(sp)		;320*200 16 couleur STE, en
	clr.l	-(sp)		;r‚allouant les ‚crans
	addq.w	#5,(sp)		;
	trap	#14		;
	move.l	_v_bas_ad.w,_memtop.w	;
__sp	set	__sp+12		;

	pea	texte(pc)		;Un p'tit message de bienvenue.
	Gemdos	-Cconws		;
__sp	set	__sp+6		;
	
	;(NB:A3=$300000, cf falboot)
	lea	$700+64*4.w,a0	;D‚place l'arborescence PMMU 
	adda.l	a0,a3		;hors d'atteinte,en $300700
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
__sp	set	__sp+5*6		;


.pcm_frq	move.w	#1,-(sp)		;Passe le DMA en 50Khz pour STE.
	clr.l	-(sp)		;De toutes facons, les jeux qui
	pea	8.w		;utilisent le DMA sont rares..
	Xbios	-devconnect	;C'est un euph‚misme !!
__sp	set	__sp+12		;
	

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
__sp	set	__sp+6		;

	move.b	#$45,$ffff8007.w	;Hardware en mode STE 16Mhz

.boot	clr.w	-(sp)		;Force le boot sur A:\ (mais
	Gemdos	-Dsetdrv		;le disque dur reste actif)
	Gemdos	-Crawcin		;Attendre un p'tit coup
__sp	set	__sp+6		;
	lea	__sp(sp),sp	;r‚tablit la pile globalement.
	jsr	([$47a.w])		;Booter le disque.
	tst.w	d0		;Boot ex‚cutable ?
	bne.s	.fin		;
	move.l	$4c6.w,a0		;Adresse du boot.
	cmp.l	30+falconfig-falboot(a0),TAG ; C'est encore nous ?
	beq.s	.fin		;alors abrŠge.
	jsr	(a0)		;Oui, alors vazyraoul
.fin	rts			;


scrutvbl	movem.l	d0-d1/a0-a1,-(sp)	;VBL de configuration.
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

.sv_snapit	move.l	v_base.w,d0	;
	lsl.w	#8,d0		;
	move.b	v_base_l.w,d0	;
	lsl.l	#8,d0		;Faut annuler les bits 24-31
	lsr.l	#8,d0		;bicoze ils sont non nuls sur
	st	(a0)		;Falcon, ce qui est trŠs con..
	lea	v_color.w,a0	;
	lea	falbend+$1000(pc),a1	;‚vite simplement la PMMU !!!!
	move.l	a1,(a1)+		;
	moveq	#7,d1		;
	move.l	(a0)+,(a1)+	;
	dbf	d1,*-2		;
	move.l	d0,a0		;
	move.w	#3999,d1		;
	move.l	(a0)+,(a1)+	;
	move.l	(a0)+,(a1)+	;
	dbf	d1,*-4		;
	clr.l	resvalid.w		;
	bra.s	.sv_end		;

.sv_cd_off	moveq	#8,d0		;
.sv_ci_off	bclr.l	d0,d1		;WARNING: CECI SUPPOSE D0=0 APRES
	bra.s	.sv_set		;LES TESTS CLAVIERS.
.sv_cd_on	moveq	#8-1,d0		;
.sv_ci_on	addq.w	#1,d0		;IL FAUT D0=-1 APRES TESTS!!
	bset.l	d0,d1		;
.sv_set	movec	d1,cacr		;RŠgle le cache
.sv_cflag	st	(a0)		;Alternate prise en compte->relache
.sv_end	movem.l	(sp)+,d0-d1/a0-a1	;
	jmp	([$70.w])		;Saute … la VBL actuelle.

.sv_alt	cmpi.b	#$38,d0		;D‚tection Alternate: ok ?
	sne	(a0)		;
	bra.s	.sv_end		;

.sv_hp	lea	yam_ctrl.w,a1	;
	moveq	#$e,d1		;
	move.b	d1,(a1)		;Commute sagement le HP.
	move.w	(a1)+,d0		;R‚cupŠre XX..
	bchg	d1,d0		;$e=6+8 -> change bit 6 de XX
	move.w	d0,(a1)		;hop, range le tout
	bra.s	.sv_cflag		;

.sv_8Mhz	andi.b	#~(1<<0+1<<2),$ffff8007.w;Commute … 8 ou 16 Mhz
	bra.s	.sv_cflag		;
.sv_16Mhz	ori.b	 #(1<<0+1<<2+1<<6),$ffff8007.w;
	bra.s	.sv_cflag		;


.sv_count	dc.w	%1000100010001000
.sv_flag	dc.b	-1
texte	equ	*
	dc.b	"VCB 1.6 =¯ Insert disk",$d,$a,0
textesize	equ	*-texte

	ifeq	(textesize&-2)-textesize
	fail	"Erreur de parit‚ !"
	endc
falbend
	EVEN
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
present	dc.b	2,"[0][ Cr‚ation du VertiConf Boot | pour Falcon030/16. Ce boot    | permet de configurer votre | Falcon … volont‚. | "
	dc.b	"V1.6 (C)DNT-Crew 1993 ][ Continue | Annule ]",0
insertdisk	dc.b	1,"[3][ Ins‚rez la disquette sur | laquelle va etre plac‚ le | boot de configuration... ][ Ok | Annule ]",0
volume	dc.b	1,"[2][ Comment faut-il r‚gler le | niveau sonore ? ][ Mini | Moyen | Maxi ]",0
nextone	dc.b	2,"[2][ | On s'en refait une petite ? | ][ Continue | Annule ]",0
diskerr	dc.b	1,"[1][ | Erreur de lecture/‚criture !| ][ Arg ]",0
Falcon	dc.b	1,"[1][ | Vaut mieux avoir un Falcon | pour se servir de ce | programme !!.][ J'achŠte ]",0
savepi1	dc.b	1,"[2][ | Un ‚cran a ‚t‚ 'snapshoot‚':| doit-on le sauver sur disque ? | ][ Oui | Non ]",0
titlebar	dc.b	"  ConfigBoot",0
fmask	dc.b	"*.PI1",0
fname	dc.b	"SNAP_VCB.PI1",0
	EVEN
volset	dc.w	$00,$f0,$70,$00
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	SECTION	BSS
fpath	ds.b	128
pathname	ds.b	142
buffsect	ds.w	512
msg_buf	ds.w	16
bufpi1	ds.b	32066
stack	ds.w	512
