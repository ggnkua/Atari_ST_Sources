*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*           Installation du VertiConf-Boot pour  Falcon 030/16            *
*                                  V2.7                                   *
*           --------------------------------------------------            *
*                                                                         *
* Ces sources n‚cessitent les fichiers tos_030.s et hard_sys.s distribu‚s *
* dans les DNT-Papers, rubrique programmation...                          *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight NulloS//DNT-Crew 1993-94*
	include	tos_030.s		;Macros TOS 4.0x
	include	hard_sys.s		;Variables systŠmes
	opt	o+,w-		;
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
big_gag	lea	(Falcon,pc),a0	;Faudrait peut-ˆtre mieux
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
	lea	(msg_buf,pc),a6	;

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

	moveq	#$20,d6		;
	swap	d6		;
	cmp.l	d6,d7		;2Mo = D‚j… pr‚sent ??
	bne	.panou_panou	;
	move.l	falboot(pc),d0	;Notre tag est l… ??
	lea	$300000,a6		;
	cmp.l	(a6),d0		;
	bne	.panou_panou	;


	clr.l	-(sp)		;
	Gemdos	Super		;
	move.l	d0,-(sp)		;
	move.w	sr,d0		;On commence par couper la protection
	move.w	#$2700,sr		;m‚moire, pour ne pas se faire ‚jecter.
	pmove.l	pmmu_ttf,tt0	;
	move.l	(pmmu_ttf,pc),(pmmu_ttp-falboot,a6) ; Inhibe le protecteur
	move.w	d0,sr		;
	Gemdos	Super		;

	move.w	#$8000,d6		;Les snaphsots commencent en $208000
	move.l	(Vars+Pnt_Snap-falboot,a6),d7
	cmp.l	d6,d7		;Mais, y'a eu des snapshots?
	beq	.nopi1		;
	lea	(savepic,pc),a0	;Oui, demande s'il faut
	bsr	Form_Alert		;les sauver..
	subq.w	#1,d0		;
	bne	.nopi1		;
	move.l	d6,(Vars+Pnt_Snap-falboot,a6)
	lea	(notabene,pc),a0	;
	bsr	Form_Alert		;
	lea	(fpath,pc),a0	;
	lea	(fmask,pc),a1	;
	lea	(fname,pc),a2	;
	lea	(pathname,pc),a3	;
	moveq	#0,d0		;
	bsr	FileSelect		;Un petit fileselect absolument normal
	beq.s	.nopi1		;

	movea.l	a3,a0		;Aller en fin de nom.
	tst.b	(a0)+		;
	bne.s	*-2		;
.getname	cmpi.b	#'\',-(a0)		;
	beq.s	.getext		;
	cmpa.l	a3,a0		;
	bgt.s	.getname		;
.getext	moveq	#7-1,d1		;
.look	move.b	(a0)+,d0		;
	beq.s	.putext		;
	cmpi.b	#'.',d0		;
	dbeq	d1,.look		;
	beq.s	.putext		;
	addq.l	#1,a0		;
.putext	move.b	#'A'-1,(-1,a0)	;
	movea.l	d7,a5		;
	movea.l	a0,a4		;
.saveloop	lea	(-32066,a5),a5	;
	cmpa.l	d6,a5		;
	blt.s	.nopi1		;
	move.l	#'.PI1',d0		;
	add.w	(a5),d0		;
	move.l	d0,(a4)		;
	clr.b	(4,a4)		;
	addq.b	#1,(-1,a4)		;
	clr.w	-(sp)		;
	pea	(a3)		;Tente d'ouvrir
	Gemdos	Fcreate		;
	move.w	d0,d7		;
	bmi.s	.nopi1		;Pas de d‚tection d'erreur...
	pea	(a5)		;32066 octets,c'est Degas-Elite
	pea	32066.w		;
	move.w	d7,-(sp)		;
	Gemdos	Fwrite		;
	move.w	d7,-(sp)		;
	Gemdos	Fclose		;
	bra.s	.saveloop		;

.nopi1	lea	(deja_la,pc),a0	;Fin de non-recevoir: on est
	bsr	Form_Alert		;d‚j… r‚sident...
	subq.w	#1,d0		;
	beq.s	.again		;
.protect	clr.l	-(sp)		;
	Gemdos	Super		;
	move.l	d0,-(sp)		;
	move.l	(pmmu_ttp,pc),(pmmu_ttp-falboot,a6)
	Gemdos	Super		;Remettre la protection
	rts			;m‚moire

.again	lea	(confirme,pc),a0	;
	bsr	Form_Alert		;
	subq.w	#1,d0		;
	bne.s	.protect		;
	bra.s	.do_it		;
	
.panou_panou	
	lea	(present,pc),a0	;Routine principale
	bsr	Form_Alert		;Petite page de pub.
	subq.w	#1,d0		;Choix du continu ?
	beq.s	.yabon		;
.yapabon	rts			;Non, retour simple.
.yabon	lea	(confirme,pc),a0	;
	bsr	Form_Alert		;
	subq.w	#1,d0		;Confirmation ?
	bne.s	.yapabon		;

.do_it	clr.l	-(sp)		;Bon, ben il ne reste plus qu'…
	Gemdos	Super		;passer en superviseur, … sauver
	move.l	_sysbase.w,sysbase	;l'adresse de sysbase, puis …
	lea	$300000,a0		;installer notre code comifo.
	move.w	#$2700,sr		;Tout le monde dehors!
	move.l	a0,a2		;
	lea	(falboot,pc),a1	;
	move.w	#(falbend-falboot)/4,d0
	move.l	(a1)+,(a0)+	;Vroom
	dbf	d0,*-2		;
	move.l	#$200000,phystop.w	;Le sysbase qui va bien
	jmp	(a2)		;Pof, continue dans le code.

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;La m‚thode de recopie Rom vers Ram pour d‚tourner le boot est issu du
;source 'MegaSTE Speed Configuration', par CodemaSTTer (ST-Mag 58)
;
falboot	lea	(falboot,pc),sp	;Installe une pile, au cas o—!
	move.l	#$31415926,resvalid.w	;Force le reset sur nous, pour
	lea	(falboot,pc),a0	;pas qu'on nous oublie
	move.l	a0,resvector.w	;
	movea.l	(sysbase,pc),a1	;Adresse de la ROM!
	lea	$380000,a0		;On la recopie ici
	movea.l	a0,a2		;
	move.w	#4096-1,d0		;4096*32=128Ko, ‡a devrait
.copy				;suffire pour ce qu'on veut faire.
	rept	8		;
	move.l	(a1)+,(a2)+	;
	endr			;
	dbf	d0,.copy		;

	move.w	#$4e70,d0		;On vire le reset (soft) sinon
	bsr.s	.look_word		;le hard se sent mal.
	move.w	#$4e71,-(a1)	;

	move.w	#$4ed0,d0		;Cherche un jmp (a0), c'est
	bsr.s	.look_word		;celui qui appelle le reset
	move.w	#$4e71,-(a1)	;Un NOP, ‡a ira mieux

	move.w	#$47a,d0		;
	bsr.s	.look_word		;Maintenant, on ruse la ROM
	movea.l	a1,a3		;
	subq.l	#6,a1		;en squattant le hdv_boot.
	lea	(save_hdv_boot,pc),a2	;
	move.l	(a1),(a2)		;
	lea	(falconfig,pc),a2	;On s'y met!
	move.l	a2,(a1)		;
	addq.l	#6,a1		;
	move.w	#$4ef9,(a1)+	;Pour la suite, c'est la ROM qui
	suba.l	a0,a3		;se d‚merde.
	lea	([sysbase.w,pc],a3.l),a3
	move.l	a3,(a1)		;
	jmp	(a0)		;Pof, on saute dans les fausses ROM

.look_word	movea.l	a0,a1		;
	move.w	#2048,d1		;Dans les 4 premiers Ko
.lw_bcl	cmp.w	(a1)+,d0		;On cherche le JMP du reset.
	dbeq	d1,.lw_bcl		;
	bne.s	.the_bug		;Ben merde, il a disparu!!
	rts			;
.the_bug	clr.l	resvalid.w		;On s'emmerde pas: reset total.
	jmp	([sysbase.w,pc])	;

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	RSRESET
Cur_Vbase	rs.l	1
Nxt_Vbase	rs.l	1

Pnt_Snap	rs.l	1

Save_VDE	rs.w	1
Ctrl_adr	rs.l	1

Vbl_Dlay	rs.w	1
Last_Key	rs.b	1
Flag_Key	rs.b	1
Flag_Vbase	rs.b	1
Flag_Alt	rs.b	1
Flag_Rep	rs.b	1
Flag_View	rs.b	1
Flag_RSM	rs.b	1
	rs.b	1
Varsize	rs.b	0
;ATTENTION: En cas de modification de ces variables, il faut modifier la
;d‚claration de Vars en fin de sources !!

Vars	dc.l	0,0

	dc.l	$208000	;Evite les 32 premiers Ko pour les snapshots!

	dc.w	0
	dc.l	0

	dc.w	%1000100010001000
	dc.b	0,$80
	dc.b	0,0,0,0,0
	dc.b	0
	IFNE	(*-Vars)-Varsize
	fail	ProblŠme avec les variables!!
	ENDC

	even
sysbase	ds.l	1

save_hdv_boot
	ds.l	1

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
falconfig	movem.l	d0-a6,-(sp)	;
	move.w	#$20,phystop.w	;Falcon en 2Mo de m‚moire.
	moveq	#2,d0		;
	move.b	d0,memctrl.w	;Confirme la configuration 2Mo
	move.b	d0,$ffff8001.w	;hoplaboum. Pour finir,
	clr.l	-(sp)		;puis on passe en r‚solution
	clr.l	-(sp)		;320*200 16 couleur STE, en
	clr.l	-(sp)		;r‚allouant les ‚crans
	addq.w	#5,(sp)		;
	trap	#14		;
	lea	12(sp),sp		;
	move.l	_v_bas_ad.w,_memtop.w	;Remet _memtop … la mode ST(E)
	clr.w	$446.w		;Booter depuis A:\ (variable foireuse
				;depuis TOS 1.2, mais certains l'utilisent)
	pea	(ctrl_text,pc)	;
	Gemdos	Cconws		;
	movea.l	_v_bas_ad.w,a0	;
	lea	(ctrl_pic+16,pc),a1	;
	moveq	#-16,d0		;
	move.l	a1,d1		;
	and.l	d1,d0		;
	movea.l	d0,a1		;
	move.w	#2*8*160/8-1,d1	;
.get_cpic	move.w	(a0)+,(a1)+	;
	clr.w	(a1)+		;
	clr.l	(a1)+		;
	addq.l	#6,a0		;
	dbf	d1,.get_cpic	;
	lea	(Vars,pc),a0	;
	move.b	#$80,Flag_Key(a0)	;Remet certaines variables dans le
	clr.b	Flag_Vbase(a0)	;bon sens.
	clr.b	Flag_Alt(a0)	;
	clr.b	Flag_Rep(a0)	;
	clr.b	Flag_View(a0)	;
	clr.b	Flag_RSM(a0)	;
	move.w	v_VDE.w,Save_VDE(a0)	;
	move.l	d0,Ctrl_adr(a0)	;
	bclr	#0,IERA+MFP_base.w	;D‚connecte totalement le MFP
	bclr	#0,IMRA+MFP_base.w	;
	clr.b	TBCR+MFP_base.w	;
	clr.b	TBDR+MFP_base.w	;
	clr.l	V_TB.w		;

	lea	(anticold,pc),a0	;
	lea	$8.w,a1		;
	move.w	#($800-8)/4-1,d0	;
.get_ram	move.l	(a1)+,(a0)+	;
	dbf	d0,.get_ram	;

	pea	(welcome,pc)	;Un p'tit message de bienvenue.
	Gemdos	Cconws		;

	lea	yam_ctrl.w,a1	;
	moveq	#$e,d1		;
	move.b	d1,(a1)		;Couper le HP interne, pour ne
	move.w	(a1)+,d0		;pas r‚veiller les voisins.
	bset	d1,d0		;
	move.w	d0,(a1)		;
	move.w	d0,-(sp)		;Installe le programme DSP qui fait
	pea	stereosize/3.w	;du "Spatial Stereo"
	pea	stereo(pc)		;
	Xbios	Dsp_ExecProg	;
	lea	PCM_base.w,a0	;
	move.w	#$0ff0,cda_att(a0)	;
	move.w	#$0400,pcm_irq(a0) 	;Interruption Timer A, coupe DMA
	move.b	#$03,cdc_add(a0)	;ADDRin sur Matrice+Yamaha
	move.b	#$03,cdc_inp(a0)	;Entr‚e depuis le micro.
	move.w	#$0000,pcm_ptrk(a0)	;piste 0 en 8 bits st‚r‚o
	move.w	#$0191,mpx_src(a0)	;On remet la matrice comifo:
	move.w	#$0393,mpx_dst(a0)	;(Yamaha -> ADC) + DMA -> DAC
	move.w	#$0000,mpx_clk(a0)	;Diviseur STE. \-> DSP -> External
	ori.b	#$03,pcm_ctrl(a0)	;
	

	lea	(vectors,pc),a3	;
	lea	($100*6,a3),a2	;Cr‚e le d‚tournement des
	suba.l	a1,a1		;vecteurs du 030.
.copyvec	move.l	a3,(a2)+		;Adresse du vecteur No A1
	move.l	#$4ef001e1,(a3)+	;Code pour JMP ([xx.w]) saut
	move.w	a1,(a3)+		;… l'ancien vecteur
	addq.l	#4,a1		;vecteur suivant
	cmpa.w	#$400,a1		;fini ?
	bne.s	.copyvec		;
	move.l	$20.w,($20,a3)	;Mais privilŠge bloqu‚ (move sr)
	lea	(scrutvbl,pc),a1	;et vbl+keyboard pour configuration.
	move.l	a1,($70,a3)	;Ils deviennent intouchables et
	lea	(scrutkbd,pc),a1	;agissent en permanence !!!.
	move.l	a1,($118,a3)	;
	movec	a3,vbr		;

	pea	1.w		;Le DMA STE est branch‚ sur l'event
	Xbios	Snd_SetInterrupt	;du Timer A.

	move.b	#$45,$ffff8007.w	;Hardware en mode STE 16Mhz

.boot	clr.w	-(sp)		;Force le boot sur A:\ (mais
	Gemdos	Dsetdrv		;le disque dur reste actif)
.wait	Gemdos	Crawcin		;Attendre un p'tit coup, pour
	cmpi.b	#" ",d0		;laisser le temps de faire les
	bne.s	.wait		;premiers r‚glages.
	pea	(cls,pc)		;
	Gemdos	Cconws		;Efface l'‚cran avant de sortir

brutus	lea	(pmmu_tree,pc),a0	;
	move.l	a0,d0		;Aligne l'arbre sur une adresse *16
	moveq	#-16,d1		;
	and.l	d1,d0		;
	move.l	d0,(pmmu_crp+4-pmmu_tree,a0);Installe l'adresse finale.
	movea.l	d0,a1		;
	cmpi.w	#$1234,(a0)	;On s'est d‚j… install‚ une fois ?
	bne.s	.install		;Oui, alors saute la relocation.
.copy	cmpi.w	#$1234,(a0)	;
	bne.s	.noreloc		;
.reloc	addq.l	#2,a0		;Non, alors reloge les pointeurs de
	move.w	(a0)+,a2		;l'arbre. Ils sont tous bas‚s sur
	adda.l	d0,a2		;l'adresse $12340000.
	move.l	a2,(a1)+		;
	bra.s	.copy		;
.noreloc	move.l	(a0)+,(a1)+	;
	bne.s	.copy		;
.install	lea	(pmmu_null,pc),a0	;
	pmove.l	(a0),tt0		;Explose les registres de translation
	pmove.l	(a0),tt1		;transparante.
	pmove.l	(a0),tc		;On coupe la PMMU le temps de lui bourrer
	pflusha			;le mou, histoire d'‚viter les gags
	lea	(pmmu_crp,pc),a0	;incongrus.
	pmove.d	(a0),crp		;Puis on installe l'arbre, et on
	lea	(pmmu_tc,pc),a0	;relance la PMMU.
	pmove.l	(a0),tc		;
	movem.l	(sp)+,d0-a6	;
	jsr	([save_hdv_boot.w,pc]);Retour … l'original.
	rts

pmmu_null	dc.l	0		;Pour annuler des registres PMMU
pmmu_tc	dc.l	$80f04445		;PMMU On, pages de 32Ko
pmmu_ttp	dc.l	$00000000		;TT0 d‚sactiv‚ -> m‚moire prot‚g‚e
pmmu_ttf	dc.l	$00008107		;TT0 activ‚e   -> m‚moire lib‚r‚e
pmmu_crp	dc.l	$80000002		;PMMU activ‚e, pointeurs courts.
	dc.l	$12340000		;Arbre … cette adresse.
pmmu_void	dcb.b	16		;Pour le travail sur la PMMU
;Arbre IS=0 A=4 B=4 C=4 D=5 PS=15
pmmu_tree	dc.l	$12340042	;00
	dc.l	$12340042	;S‚lection sur champ A
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340042
	dc.l	$12340082

	
	dc.l	$123400c2	;42
	dc.l	$123400c2	;S‚lection sur champ B:
	dc.l	$123400c2	;Toutes les adresses de type $x....
	dc.l	$123400c2	;avec x<>F
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2

	dc.l	$123400c2	;82
	dc.l	$123400c2	;S‚lection sur champ B:
	dc.l	$123400c2	;Toutes les adresses $F....
	dc.l	$123400c2	;Si <>$FF..., alors goto c2
	dc.l	$123400c2	;
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$123400c2
	dc.l	$12340102	;Sinon, adresses p‚riph‚riques

	dc.l	$00000011	;c2, S‚lection sur champ C
	dc.l	$00100011	;Adresses $xx.... avec xx<>FF
	dc.l	$123401c2	;[2Mo,3Mo[: m‚moire snaphsot
	dc.l	$00300055	;[3Mo,4Mo[: m‚moire du VCB en Write Protected
	dc.l	$00400000	;	& cache inhibit
	dc.l	$00500000	;[4Mo,16Mo[: invalid
	dc.l	$00600000	;
	dc.l	$00700000	;
	dc.l	$00800000	;
	dc.l	$00900000	;
	dc.l	$00a00000	;
	dc.l	$00b00000	;
	dc.l	$00c00000	;
	dc.l	$00d00000	;
	dc.l	$00e00001	;Rom, cachable mais pas modifiable.
	dc.l	$12340142	;Sp‚cial Rom STF & P‚riph‚riques

	dc.l	$00000011	;100
	dc.l	$00100011	;S‚lection sur champ C
	dc.l	$123401c2	;Adresses $FFx...
	dc.l	$00300055	;
	dc.l	$00400000	;
	dc.l	$00500000	;
	dc.l	$00600000	;Par d‚faut, les $FFx...
	dc.l	$00700000	;avec x<>F sont remapp‚es comme
	dc.l	$00800000	;de la m‚moire normale, sauf
	dc.l	$00900000	;$FFE qui n'est pas de la Rom, mais
	dc.l	$00a00000	;qui est invalid.
	dc.l	$00b00000	;
	dc.l	$00c00000	;
	dc.l	$00d00000	;
	dc.l	$00e00000	;
	dc.l	$00f00051	;Seules $FFF.. sont p‚riph‚riques, et donc
			;non-cachables


	dc.l	$00f00051	;140, S‚lection sur champ D
	dc.l	$00f08000	;Mapping Rom STF -> Rom Falcon
	dc.l	$00f10000	;et p‚riph‚riques (adresses $00FF...)
	dc.l	$00f18000	;
	dc.l	$00f20000	;de $00F08.. … $00FB8, d‚clar‚ invalid.
	dc.l	$00f28000	;
	dc.l	$00f30000	;$00F0.. correspond au contr“leur IDE!
	dc.l	$00f38000	;
	dc.l	$00f40000	;
	dc.l	$00f48000	;
	dc.l	$00f50000	;
	dc.l	$00f58000	;
	dc.l	$00f60000	;
	dc.l	$00f68000	;
	dc.l	$00f70000	;
	dc.l	$00f78000	;
	dc.l	$00f80000	;
	dc.l	$00f88000	;
	dc.l	$00f90000	;
	dc.l	$00f98000	;
	dc.l	$00fa0041	;De $00FA0.. … $00FB8.., Rom du port cartouche.
	dc.l	$00fa8041	;
	dc.l	$00fb0041	;
	dc.l	$00fb8041	;
	dc.l	$00e00001	;De $00FC0.. … $00FF0.., rejette sur la Rom
	dc.l	$00e08001	;des STE/Falcon
	dc.l	$00e10001	;
	dc.l	$00e18001	;
	dc.l	$00e20001	;
	dc.l	$00e28001	;
	dc.l	$00e30001	;
	dc.l	$00ff8051	;A partir de $00FF8.., c'est du p‚riph‚rique!

	dc.l	$00200011	;1c0 : S‚lection sur champ D
	dc.l	$00208055	;Protection m‚moire du buffer de snapshot,
	dc.l	$00210055	;seuls les 32 premiers Ko sont libres.
	dc.l	$00218055	;
	dc.l	$00220055	;
	dc.l	$00228055	;Ca fait beaucoup de pointeurs, mais en
	dc.l	$00230055	;temps normal, c'est nous qui acc‚dons …
	dc.l	$00238055	;ces adresses, avec la translation
	dc.l	$00240055	;transparante, donc normalement l'ATC n'est
	dc.l	$00248055	;pas perturb‚.
	dc.l	$00250055	;
	dc.l	$00258055	;
	dc.l	$00260055	;
	dc.l	$00268055	;
	dc.l	$00270055	;
	dc.l	$00278055	;
	dc.l	$00280055	;
	dc.l	$00288055	;
	dc.l	$00290055	;
	dc.l	$00298055	;
	dc.l	$002a0055	;
	dc.l	$002a8055	;
	dc.l	$002b0055	;
	dc.l	$002b8055	;
	dc.l	$002c0055	;
	dc.l	$002c8055	;
	dc.l	$002d0055	;
	dc.l	$002d8055	;
	dc.l	$002e0055	;
	dc.l	$002e8055	;
	dc.l	$002f0055	;
	dc.l	$002f8055	;

	dc.l	0	;finito

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
pmmu_on	macro	\1
	lea	(pmmu_ttp,pc),\1
	pmove.l	(\1),tt0
	pflusha
	endm
pmmu_off	macro	\1
	lea	(pmmu_ttf,pc),\1
	pmove.l	(\1),tt0
	pflusha
	endm
pmmu_sav	macro
	subq.l	#4,sp
	pmove.l	tt0,(sp)
	endm
pmmu_bak	macro
	pmove.l	(sp),tt0
	addq.l	#4,sp
	endm
	

scrutkbd	move.w	#$118,-(sp)	;StackFrame 0, donc offset
	pea	(.beback,pc)	;du vecteur, adresse de retour
	move.w	sr,-(sp)		;et SR courant.
	jmp	([$118.w])		;
.beback	move.l	a0,-(sp)		;
	pmmu_sav			;Vire la protection m‚moire.
	pmmu_off	a0		;
	lea	(Last_Key+Vars,pc),a0	;
	move.b	KBD_data.w,(a0)+	;Signale qu'un ‚vŠnement clavier
	clr.b	(a0)+		;vient d'arriver.
	pmmu_bak			;Remet l'ancien tt0 (qui peut ˆtre celui
	movea.l	(sp)+,a0		;de scrutvbl, donc pmmu_on interdit!)
	rte			;


scrutvbl	movem.l	d0-d3/a0-a3,-(sp)	;VBL de configuration.
	pmmu_off	a0		;Vire la protection m‚moire, on est
	lea	(Vars,pc),a0	;ici chez nous.
	moveq	#0,d0		;
	move.b	v_base_h.w,d0	;
	swap	d0		;
	move.b	v_base_m.w,d0	;
	lsl.w	#8,d0		;Un changement de v_base a eu lieu
	move.b	v_base_l.w,d0	;en dehors de la VBL ?
	cmp.l	Cur_Vbase(a0),d0	;Oui -> Laisser tel-quel
	bne.s	.no_vbchg		;Non -> Ajouter le d‚lai ST(E)
	move.l	Nxt_Vbase(a0),d0	;
.no_vbchg	move.l	d0,Cur_Vbase(a0)	;
	tst.b	Flag_Vbase(a0)	;Autorisation d'agir?
	beq.s	.no_vbase		;
	swap	d0		;Oui -> Force la base vid‚o,
	move.b	d0,v_base_h.w	;donc ‚mulation du d‚lai ST(E)
	rol.l	#8,d0		;
	move.b	d0,v_base_m.w	;
	rol.l	#8,d0		;
	move.b	d0,v_base_l.w	;
.no_vbase
	tst.b	Flag_View(a0)	;
	beq.s	*+6		;
	bsr	.sv_show		;
	movec	cacr,d1		;Registre du cache.
	moveq	#6,d0		;L'interruption clavier est
	btst.b	d0,IERB+MFP_base.w	;activ‚e ?
	beq.s	.polling		;
	btst.b	d0,IMRB+MFP_base.w	;
	beq.s	.polling		;
.inter	tas.b	Flag_Key(a0)	;Une IT clavier a eu lieu?
	bne.s	.sv_end		;
	clr.b	Flag_Rep(a0)	;Sous IT, donc pas de repeat!
	move.b	Last_Key(a0),d0	;Oui, on la r‚cupŠre
	bra.s	.testkey		;
.polling	ror.w	Vbl_Dlay(a0)	;Polling uniquement 1 vbl sur 4
	bcc.s	.sv_end		;
	btst	#0,KBD_stat.w	;Lire uniquement si y'a pas de
	bne.s	.sv_end		;donn‚e re‡ue (logique :-)
	move.b	KBD_data.w,d0	;
.testkey	bmi	.sv_alt0		;Touche enfonc‚e ?
	tst.b	Flag_Alt(a0)	;Alternate activ‚e ?
	beq	.sv_alt1		;
	cmpi.b	#$38,d0		;C'est encore Alternate ?
	beq.s	.sv_end		;
	tas.b	Flag_Rep(a0)	;Ca peut venir du polling en action, donc
	bne.s	.sv_end		;faire gaffe au repeat.
	moveq	#Nb_Choices-1,d2	;Alternate + Touche: test clavier autoris‚
	lea	(.Choices,pc),a1	;
.scrute	move.l	(a1)+,d3		;
	cmp.b	d0,d3		;
	dbeq	d2,.scrute		;
	bne.s	.sv_end		;
	swap	d3		;
	jsr	-4(a1,d3.w)	;

.sv_end	pmmu_on	a0		;Remet la protection m‚moire.
	movem.l	(sp)+,d0-d3/a0-a3	;
	move.w	#$70,-(sp)		;StackFrame 0, donc offset
	pea	(.beback,pc)	;du vecteur, adresse de retour
	move.w	sr,-(sp)		;et SR courant.
	jmp	([$70.w])		;
.beback	movem.l	d0-d3/a0-a3,-(sp)	;
	pmmu_off	a0		;
	lea	(Vars,pc),a0	;
	moveq	#0,d0		;R‚cupŠre v_base qui peut avoir ‚t‚
	move.b	v_base_h.w,d0	;chang‚ pendant la VBL.
	swap	d0		;
	move.b	v_base_m.w,d0	;
	lsl.w	#8,d0		;
	move.b	v_base_l.w,d0	;
	move.l	d0,Nxt_Vbase(a0)	;
	tst.b	Flag_Vbase(a0)	;
	beq.s	.quit		;Si on y est autoris‚, on remet
	move.l	Cur_Vbase(a0),d0	;l'ancienne valeur de v_base pour
	swap	d0		;simuler le delai des ST(E).
	move.b	d0,v_base_h.w	;
	rol.l	#8,d0		;
	move.b	d0,v_base_m.w	;
	rol.l	#8,d0		;
	move.b	d0,v_base_l.w	;
.quit	pmmu_on	a0		;
	movem.l	(sp)+,d0-d3/a0-a3	;
	rte			;

.sv_alt0	clr.b	Flag_Rep(a0)	;Touche relƒch‚e, donc...
	cmpi.b	#$38+$80,d0	;
	bne	.sv_end		;Si Alternate a ‚t‚ relach‚,
	clr.b	Flag_Alt(a0)	;ben on vire son flag!
	bra	.sv_end		;
.sv_alt1	cmpi.b	#$38,d0		;D‚tection Alternate: ok ?
	seq.b	Flag_Alt(a0)	;
	clr.b	Flag_Rep(a0)	;Pas encore de repeat..
	bra	.sv_end		;

.Choices	dc.w	.sv_snapit-*,$70
	dc.w	.sv_cd_off-*,$6e
	dc.w	.sv_cd_on-*,$6b
	dc.w	.sv_ci_off-*,$6d
	dc.w	.sv_ci_on-*,$6a
	dc.w	.sv_8Mhz-*,$6f
	dc.w	.sv_16Mhz-*,$6c
	dc.w	.sv_hp-*,$69
	dc.w	.sv_ide-*,$72
	dc.w	.sv_volup-*,$4e
	dc.w	.sv_voldn-*,$4a
	dc.w	.sv_RSM-*,$68
	dc.w	.sv_vbase-*,$71
	dc.w	.sv_view-*,$63
	dc.w	.sv_force-*,$64
	dc.w	.sv_reset-*,$66
	dc.w	.sv_reset-*,$53
	dc.w	.sv_dcnx-*,$67
	dc.w	.sv_kill-*,$65
Nb_Choices	equ	(*-.Choices)/4

.sv_vbase	not.b	Flag_Vbase(a0)
	rts

.sv_volup	moveq	#-1,d1
	bra.s	*+4
.sv_voldn	moveq	#1,d1
	move.w	#%11110000,d0
	and.w	cda_att+PCM_base.w,d0
	lsr.w	#4,d0
	add.w	d1,d0
	bpl.s	*+4
	moveq	#0,d0
	moveq	#15,d1
	cmp.w	d1,d0
	ble.s	*+4
	move.w	d1,d0
	lsl.w	#4,d0
	move.w	d0,d1
	lsl.w	#4,d0
	or.w	d1,d0
	move.w	d0,cda_att+PCM_base.w
	rts
	

.sv_snapit	movem.l	d4-d7/a2-a5,-(sp)	;
	movea.l	Pnt_Snap(a0),a1	;
	lea	(falboot-32066.l,pc),a2
	cmpa.l	a1,a2		;Y'a encore de la place ?
	blt.s	.nomem		;
	moveq	#2,d1		;
	tst.w	v_SpShift.w	;R‚solution de l'‚cran, comme dans
	bne.s	.hirez		;toute image PI? qui se respecte.
	move.b	v_Shift.w,d1	;Le cas SpShift<>0 indique du 640*400
.hirez	move.w	d1,(a1)+		;sur un moniteur VGA/RGB.
	movem.l	v_color.w,d1-d7/a2	;
	movem.l	d1-d7/a2,(a1)	;Puis les couleurs.
	lea	(32,a1),a1		;
	movea.l	Cur_Vbase(a0),a2	;
	move.w	#800-1,d0		;
.yo	movem.l	(a2)+,d1-d7/a3-a5	;Et enfin l'image, par paquet
	movem.l	d1-d7/a3-a5,(a1)	;de 40 octets.
	lea	40(a1),a1		;
	dbf	d0,.yo		;
	moveq	#8-1,d0		;Remplissage … 32066 octets.
	clr.l	(a1)+		;
	dbf	d0,*-2		;
	move.l	a1,Pnt_Snap(a0)	;Une image de plus!
.nomem	movem.l	(sp)+,d4-d7/a2-a5	;
	rts			;

.sv_cd_off	andi.w	#~$0100,d1		;
	bra.s	.sv_set		;
.sv_ci_off	andi.w	#~$0001,d1		;
	bra.s	.sv_set		;
.sv_cd_on	ori.w	#$3900,d1		;
	bra.s	.sv_set		;
.sv_ci_on	ori.w	#$0009,d1		;
.sv_set	movec	d1,cacr		;RŠgle le cache
	rts			;

.sv_ide	moveq	#7+8,d2		;IDE= Il D‚gage les Esgourdes (?!)
	bra.s	*+4		;
.sv_hp	moveq	#6+8,d2		;
	lea	yam_ctrl.w,a1	;
	moveq	#$e,d1		;
	move.b	d1,(a1)		;Commute sagement le HP.
	move.w	(a1)+,d0		;R‚cupŠre XX..
	bchg	d2,d0		;-> change le bit kivabien 
	move.w	d0,(a1)		;hop, range le tout
	rts			;


.sv_8Mhz	andi.b	#~(1<<0+1<<2),$ffff8007.w;Commute … 8 ou 16 Mhz
	rts			;
.sv_16Mhz	ori.b	 #(1<<0+1<<2+1<<6),$ffff8007.w;
	rts

.sv_reset	move.w	#$2700,sr		;
	lea	(anticold,pc),a0	;R‚-installe la Ram basse, car les
	lea	$8.w,a1		;memvalid ne sont pas les seuls …
	move.w	#($800-8)/4-1,d0	;pouvoir provoquer un reset … froid...
.svr_ram	move.l	(a0)+,(a1)+	;
	dbf	d0,.svr_ram	;
	move.l	#$31415926,resvalid.w	;Force le reset sur nous, au cas o—
	lea	(falboot,pc),a0	;y'ai eu un problŠme avec la zone anticold
	move.l	a0,resvector.w	;(ce qui serait ‚tonnant).
	suba.l	a0,a0		;
	movea.l	(a0)+,sp		;Provoque un reset en bonne
	movea.l	(a0)+,a0		;et due forme.
	jmp	(a0)		;

.sv_force	clr.b	TBCR+MFP_base.w	;
	bclr	#0,IERA+MFP_base.w	;
	bclr	#0,IMRA+MFP_base.w	;
	clr.b	TBDR+MFP_base.w	;
	clr.l	V_TB.w		;

.sv_view	tst.b	Flag_View(a0)	;D‚j… activ‚ ?
	bne.s	.svv_off		;Alors coupe-le simplement
	bsr.s	.test_timerb	;Sinon, teste l'occupation du TimerB
	bne.s	.svv_break		;
.svv_off	move.w	Save_VDE(a0),v_VDE.w	;Dans tous les cas, pas encore d'overscan!
	not.b	Flag_View(a0)	;
.svv_break	rts			;

.test_timerb
	btst	#0,IERA+MFP_base.w	;
	bne.s	.tt_break		;
	btst	#0,IMRA+MFP_base.w	;
	bne.s	.tt_break		;
	tst.b	TBCR+MFP_base.w	;
	bne.s	.tt_break		;
	tst.b	TBDR+MFP_base.w	;
	bne.s	.tt_break		;
	tst.l	V_TB.w		;
.tt_break	rts			;

.sv_show	bsr.s	.test_timerb	;TimerB vierge ?
	bne	.svs_arg		;
	move.w	Save_VDE(a0),d0	;
	addi.w	#16*2,d0		;
	move.w	d0,v_VDE.w		;
	movec	cacr,d1		;
	lsr.w	#1,d1		;Faire rentrer Inst
	addx.w	d0,d0		;puis Data dans le mot
	lsr.w	#8,d1		;d'options (si on peut dire)
	addx.w	d0,d0		;
	move.b	$ffff8007.w,d2	;
	lsr.w	#1,d2		;16Mhz
	addx.w	d0,d0		;
	lea	yam_ctrl.w,a1	;
	move.b	#$e,(a1)		;
	move.w	(a1)+,d2		;R‚cupŠre la donn‚e.
	not.w	d2		;
	add.w	d2,d2		;
	addx.w	d0,d0		;IDE
	add.w	d2,d2		;
	addx.w	d0,d0		;Puis HP
	tst.b	Flag_Vbase(a0)	;
	sne	d2		;
	add.b	d2,d2		;
	addx.w	d0,d0		;
	tst.b	Flag_RSM(a0)	;
	sne	d2		;
	add.b	d2,d2		;
	addx.w	d0,d0		;
	lea	([Ctrl_adr,a0],160*8),a1;
	lea	(ctrl_inf,pc),a2	;
	moveq	#7-1,d1		;
.svs_hop	moveq	#0,d2		;
	move.b	(a2)+,d2		;
	lsr.w	#1,d2		;
	subx.w	d3,d3		;
	lsl.w	#3,d2		;
	sub.w	d3,d2		;
	lea	(a1,d2),a3		;
	moveq	#%11111110,d3	;
	move.b	d3,1*160(a3)	;
	move.b	d3,6*160(a3)	;
	lsr.w	#1,d0		;
	bcs.s	*+4		;
	moveq	#%10000010,d3	;
	move.b	d3,2*160(a3)	;
	move.b	d3,3*160(a3)	;
	move.b	d3,4*160(a3)	;
	move.b	d3,5*160(a3)	;
	dbf	d1,.svs_hop	;
	lea	MFP_base.w,a3	;
	clr.b	TBCR(a3)		;
	bset	#0,IERA(a3)	;
	bset	#0,IMRA(a3)	;
	move.b	#200-2,TBDR(a3)	;
	lea	(.sv_tb200,pc),a2	;
	move.l	a2,V_TB.w		;
	move.b	#8,TBCR(a3)	;
	rts
.svs_arg	clr.b	Flag_View(a0)	;Gasp!, le Timer B est d‚j… utilis‚,
	move.w	Save_VDE(a0),v_VDE.w	;donc on s'arrˆte imm‚diatement.
	rts			;

.sv_tb200	move.w	#$2500,sr		;
	bclr	#0,ISRA+MFP_base.w	;
	move.l	d0,-(sp)		;
	move.l	a0,-(sp)		;
	lea	(Vars+Save_VDE,pc),a0	;
	move.w	(a0)+,d0		;
	addq.l	#1,a0		;
.svt_w0	cmp.w	v_VFC.w,d0		;
	bgt.s	.svt_w0		;
	move.b	(a0)+,v_count_h.w	;
	move.b	(a0)+,v_count_m.w	;
	move.b	(a0)+,v_count_l.w	;
	movea.l	(sp)+,a0		;
	move.l	(sp)+,d0		;
	clr.b	TBCR+MFP_base.w	;
	bclr	#0,IERA+MFP_base.w	;
	bclr	#0,IMRA+MFP_base.w	;
	clr.b	TBDR+MFP_base.w	;
	clr.l	V_TB.w		;
	rte			;

.sv_RSM	not.b	Flag_RSM(a0)	; Alors ?
	beq.s	.svR_off		;
.svR_on	btst	#0,pcm_mode+PCM_base.w	;
	beq.s	.svR_chip			;
.svR_dma	move.w	#$0191,mpx_src+PCM_base.w 	;Le DMA en activit‚, donc 'Spatial Stereo'
	move.w	#$2393,mpx_dst+PCM_base.w	;(DMA -> DSP) + (Yamaha -> ADC) -> DAC
	move.b	#$03,cdc_add+PCM_base.w	;	  -> External
	move.b	#$93,hcvr+HST_base.w		;
	moveq	#$3,d0			;
	and.b	pcm_ctrl+PCM_base.w,d0	;et selon la fr‚quence d'exploitation,
	move.l	d0,htx+HST_base.w		;activer le bon d‚lai.
	rts				;
.svR_chip	move.w	#$0191,mpx_src+PCM_base.w 	;Le DMA est en pause, donc on fait
	move.w	#$23f3,mpx_dst+PCM_base.w	;du 'Enhanced Mono'. Matrice comme
	move.b	#$02,cdc_add+PCM_base.w	;suit: Yamaha -> ADC -> DSP -> DAC
	ori.b	#$03,pcm_ctrl+PCM_base.w	;		      -> External
	move.b	#$94,hcvr+HST_base.w		;
	rts				;

.svR_off	move.w	#$0191,mpx_src+PCM_base.w	;On remet la matrice comifo:
	move.w	#$0393,mpx_dst+PCM_base.w	;(Yamaha -> ADC) + DMA -> DAC
	move.b	#$03,cdc_add+PCM_base.w	;		 -> DSP -> External
	rts				;

	lea	(vectors,pc),a3		;
	lea	($100*6,a3),a2		;Cr‚e le d‚tournement des
	suba.l	a1,a1			;vecteurs du 030.
.copyvec	move.l	a3,(a2)+			;Adresse du vecteur No A1
	move.l	#$4ef001e1,(a3)+		;Code pour JMP ([xx.w]) saut
	move.w	a1,(a3)+			;… l'ancien vecteur
	addq.l	#4,a1			;vecteur suivant
	cmpa.w	#$400,a1			;fini ?
	bne.s	.copyvec			;
	move.l	$20.w,($20,a3)		;Mais privilŠge bloqu‚ (move sr)
	lea	(scrutvbl,pc),a1		;et vbl+keyboard pour configuration.
	move.l	a1,($70,a3)		;Ils deviennent intouchables et
	lea	(scrutkbd,pc),a1		;agissent en permanence !!!.
	move.l	a1,($118,a3)		;
	movec	a3,vbr			;

.sv_dcnx	clr.b	Flag_Alt(a0)		;
	lea	(sleepvbl,pc),a1		;D‚connection momentann‚e.
	lea	($100*6+$70+vectors,pc),a2	;
	move.l	a1,(a2)			;
	lea	($118*6/4+vectors,pc),a1	;
	lea	($100*6+$118+vectors,pc),a2	;Explose l'interruption clavier,
	move.l	a1,(a2)			;mais conserve une mini-vbl.
	rts				;

.sv_kill	lea	($70*6/4+vectors,pc),a1	;D‚connection totale et d‚finitive.
	lea	($100*6+$70+vectors,pc),a2	;
	move.l	a1,(a2)			;D‚truire les drivers d'interruption,
	lea	($118*6/4+vectors,pc),a1	;c'est donc irratrapable par la suite.
	lea	($100*6+$118+vectors,pc),a2	;
	move.l	a1,(a2)			;
	rts				;


sleepvbl	cmpi.b	#$66+$80,KBD_data.w		;VBL 'de sommeil': on demande la
	bne.s	.dommage			;re-activation du driver ?
	move.l	a3,-(sp)			;
	move.l	a4,-(sp)			;
	pmmu_off	a3			;
	lea	(scrutvbl,pc),a3		;
	lea	($100*6+$70+vectors,pc),a4	;
	move.l	a3,(a4)			;
	lea	(scrutkbd,pc),a3		;
	lea	($100*6+$118+vectors,pc),a4	;
	move.l	a3,(a4)			;
	pmmu_on	a3			;
	move.l	(sp)+,a4			;
	move.l	(sp)+,a3			;
.dommage	jmp	([$70.w])			;

	

stereo	incbin	stereo.p56
stereosize	equ	*-stereo

welcome	dc.b	27,"E"
	dc.b	"       ®÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷¯",$d,$a
	dc.b	"       ¯  ",27,"pVertiConf Booter 2.7",27,"q  ®",$d,$a
	dc.b	"       ®÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷¯",$d,$a
	dc.b	"        ½oderight NulloS/DNT '94  ",$d,$a
	dc.b	$a
	dc.b	"Rappel des commandes du pav‚ num‚rique:",$d,$a
	dc.b	"        (combin‚ avec Alternate)",$d,$a
	dc.b	" +--------+--------+--------+--------+",$d,$a
	dc.b	" |(  Show |)  Force|/  Kill |*  Warm |\",$d,$a
	dc.b	" |   Stat |   Timer|   me!  |   Boot | |",$d,$a
	dc.b	" +--------+--------+--------+--------+ |",$d,$a
	dc.b	" |7  Go   |8  Real |9       |-  Vol  |\|",$d,$a
	dc.b	" |   Sleep|  Stereo|   HP   |   Down | |",$d,$a
	dc.b	" +--------+--------+--------+--------+ |",$d,$a
	dc.b	" |4  Inst |5  Data |6       |+  Vol  |\|",$d,$a
	dc.b	" |   On   |   On   |   16Mhz|   Up   | |",$d,$a
	dc.b	" +--------+--------+--------+--------+ |",$d,$a
	dc.b	" |1  Inst |2  Data |3       |E       |\|",$d,$a
	dc.b	" |   Off  |   Off  |   8Mhz |n       | |",$d,$a
	dc.b	" +-----------------+--------|t       | |",$d,$a
	dc.b	" |0  Snapshot      |.  Vbase|e       | |",$d,$a
	dc.b	" |   PI2           |   Emul |r  IDE  | |",$d,$a
	dc.b	" +-----------------+--------+--------+ |",$d,$a
	dc.b	"  \_________________\________\________\|",$d,$a
	dc.b	9,27,"pEspace pour continuer...",27,"q",0
cls	dc.b	27,'E',0

ctrl_text	dc.b	27,'E'
	dc.b	"=======¯  VertiConf Booter 2.7  ®=======",$d,$a
	dc.b	"-Inst -Data -16Mz  -HP -RSM  -Vbase -IDE",$d,$a,0
ctrl_inf	dc.b	23,29,19,36,12,6,0 ;No des caractŠres d'indication


	even
falbend
anticold	equ	*		;ds.b	$800-8
ctrl_pic	equ	anticold+($800-8)	;ds.b	2*8*160+16
vectors	equ	ctrl_pic+(2*8*160+16)	;ds.b	$100*(4+6)
	EVEN
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
deja_la	dc.b	1,"[1][ | VertiConf v2.7 est d‚j… | r‚sident en m‚moire ! | On le re-initialise ? |  ][ Oui | Non ]",0
present	dc.b	2,"[1][ Installation du VertiConf | pour Falcon030/16. Ce booter | en RAM permet de configurer | votre Falcon … volont‚. | "
	dc.b	"V2.7 (C)DNT-Crew 1993-94 ][ Continue | Annule ]",0
confirme	dc.b	1,"[3][ Attention, l'installation se | fait par un RESET, voulez-vous | vraiment continuer ? ][ Oui | Non ]",0
insertdisk	dc.b	1,"[3][ Ins‚rez la disquette sur | laquelle va etre plac‚ le | boot de configuration... ][ Ok | Annule ]",0
Falcon	dc.b	1,"[1][ | Vaut mieux avoir un Falcon | pour se servir de ce | programme !!.][ J'achŠte ]",0
savepic	dc.b	1,"[2][ | Le snapshot DegasElite | a ‚t‚ activ‚, doit-on | sauver les images ? | ][ Oui | Non ]",0
notabene	dc.b	1,"[3][ Dans le s‚lecteur de fichier | qui suit, indiquez un nom | de fichier de 7 caractŠres,| qui servira de pr‚fixe. | ][ Vaziraoul ]",0
titlebar	dc.b	"  ConfigBoot",0
fmask	dc.b	"*.PI1",0
fname	dc.b	"SNAP_.PI?",0
	EVEN
volset	dc.w	$00,$f0,$70,$00
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	SECTION	BSS
fpath	ds.b	128
pathname	ds.b	142
buffsect	ds.w	512
msg_buf	ds.w	16
stack	ds.w	512
