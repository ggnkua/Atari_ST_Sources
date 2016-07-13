	OPT	O+	;Optimisation branchements court+offset nuls
	OUTPUT	.TTP
;Ram disque r‚sident reset-proof,re-dimmensionnable+horloge semi-permanente
;(c)NulloS//DNT
;
;NE PAS OUBLIER DE MODIFIER LE NUMERO DE VERSION LORS D'EVOLUTIONS FUTURES
;APRES M'AVOIR CONTACT...
;
;Nb:les lignes sont faites pour une tabulation de 11 caractŠres.
;
REL_TXT	equ	"V1.4"
REL_NUM	equ	$0140



CmdLine	equ	$80
dir_size	equ	5	;taille du dir en secteurs (80 entr‚es)
soft_boot	equ	1024	;taille de la routine my_boot (arrondi …
			;512 octets prŠs par excŠs)


main	lea	PARAM(pc),a6
	move.l	a7,a5		;par ici la page de base !!
	moveq	#0,d0		;on passe ne superviseur
	moveq	#$20,d1		;
	bsr	Gemdos_go		;hop
	move.l	d0,save_SSP(a6)

	movea.l	a7,a5
	movea.l	4(a5),a5		;r‚cupŠre BasePage
	movea.l	$c(a5),a0		;TEXT
	adda.l	$14(a5),a0		;+DATA
	adda.l	$1c(a5),a0		;+BSS
	lea	4224(a0),a0	;BasePage_lenght+Stack_size
	movea.l	a5,a7
	adda.l	a0,a7		;nouvelle pile
	move.l	a0,-(a7)		;taille
	move.l	a5,-(a7)		;BasePage
	clr.w	-(a7)		;Dummy
	move.w	#$4a,-(a7)		;Mshrink
	trap	#1		;go!
	lea	12(a7),a7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	bsr.s	init
	bne.s	prg_abort		;en cas d'erreur
	tst.b	CmdLine(a5)	;Ligne de commande utilis‚e ?
	beq.s	main_0		;non,gere le "menu"
	bsr	auto_install	;si,installation automatique
	bra.s	prg_abort
main_0	bsr	menu_gere		;boucle principale
prg_abort	move.l	save_SSP(a6),d0
	moveq	#$20,d1		;on revient en utilisateur
	bsr	Gemdos_go
	clr.w	-(a7)
	trap	#1		;Pterm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init		;En sortie:Z=1 ok,Z=0 probleme
	movem.l	d0/a0,-(sp)
	movea.l	a6,a0
	move.w	#param_size-1,d0	;par prudence...
init_bcl	clr.l	(a0)+		;on efface tout !!!
	dbf	d0,init_bcl
	bsr.s	cookie_check	;en sortie,si DNTR existe,
	bne.s	init5		;A0=DNTR+4={descr_ad}
	st	resident(a6)	;Z=1,donc DNTR existe
	move.l	(a0),a0
	move.l	a0,descr_ad(a6)	;adresse du descripteur
	move.w	version(a0),d0
	cmpi.w	#REL_NUM,d0	;quelle version
	beq.s	init1		;V1.4 ?

init_brk	lea	mes13(pc),a0	;si,on arrŠte les frais
	bsr	print		;(par s‚curit‚).
	bsr	WaitKey
	moveq	#-1,d0		;Z=0,erreur
i_end	movem.l	(sp)+,d0/a0
	rts


init1	move.b	(a0),d0
	cmp.b	$447.w,d0		;ram-disque en bootdev ?
	beq.s	init4		;oui
	move.w	$446.w,bootdev(a0)	;non,actualise bootdev
init4	move.w	options(a0),options(a6) ;r‚cupŠre les options
	move.l	(a0),ram_size(a6)	;r‚cupŠre les autres paramŠtres
	clr.b	ram_size(a6)	;ram_size,identificateur,etc..
	move.l	8(a0),disk_size(a6)
	move.w	bpbtab+8(a0),FAT_size(a6)
init5	moveq	#0,d0		;Z=1,tout est ok
	bra	i_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                               ;
;                                               ;
;      Gestion principale de l'occupation       ;
;             m‚moire de DNT-RAM                ;
;                                               ;
;                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cookie_check		;regarde si un cookie DNTR existe
			;En sortie:_Z=1 si pr‚sent
			;           A0=adresse de DNTR+4
			;          _Z=0 si absent
			;           A0=Null_cookie+4
	move.l	d0,-(sp)
	move.l	$5a0.w,d0
	beq.s	cc_end
	movea.l	d0,a0
cc_bcl0	move.l	(a0)+,d0
	beq.s	cc_end
	cmpi.l	#'DNTR',d0
	beq.s	cc_quit
	addq.l	#4,a0
	bra.s	cc_bcl0
cc_end	moveq	#-1,d0
cc_quit	movem.l	(sp)+,d0		;pour conserver le CCR
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
name_disk	movem.l	d0-a5,-(sp)
	tst.b	resident(a6)	;r‚sidence ?
	beq.s	ndisk_end		;non,ben on se casse !!
	move.l	descr_ad(a6),a5	;descripteur
	move.b	(a5),d2		;lecteur actuel
	move.l	$4c2.w,d1		;lecteurs actifs
	lea	mes31(pc),a0	;message de selection
	bsr	print		;affiche
	moveq	#0,d3		;… partir du lecteur A
ndisk_0	move.w	#"-",d0		;par d‚faut
	btst	d3,d1		;lecteur actif ?
	beq.s	ndisk_1		;non,ben on affiche
	move.w	d3,d0		;si,alors affiche sa lettre
	addi.w	#"A",d0		;
	cmp.b	d2,d3		;c'est l'id actuel ?
	bne.s	ndisk_1		;non
	move.w	#"*",d0		;si,on le signale
ndisk_1	move.w	d0,-(sp)		;affichage du caractŠre
	move.w	#2,-(sp)		;hop
	trap	#1		;fulgoro-pantoufle
	addq.l	#4,sp		;lasero-camember
	addq.w	#1,d3		;lecteur suivant
	cmpi.w	#25,d3		;fini ?
	bls.s	ndisk_0		;ah ben non
	lea	mes32(pc),a0	;ah ben si
	bsr	print		;splash

ndisk_bcl	bsr	WaitKey		;demande une touche
	tst.w	d0		;c'‚tait une touche classique ?
	beq.s	ndisk_pb		;non
	cmpi.w	#"*",d0		;conserver le choix actuel ?
	beq.s	ndisk_end		;oui,cassos
	ori.w	#$20,d0		;passe en minuscules
	subi.w	#"a",d0		;puis en [0..25]
	bmi.s	ndisk_pb		;pas correct
	cmpi.w	#25,d0		;plafond ?
	bgt.s	ndisk_pb		;pas correct
	cmp.b	d2,d0		;lecteur actuel ?
	beq.s	ndisk_end		;oui,c'est fini
	btst	d0,d1		;lecteur d‚j… occup‚ ?
	beq.s	ndisk_ok		;non,on continue
ndisk_pb	bsr	BipBip
	bra.s	ndisk_bcl		;on reessaye

ndisk_ok	bset	d0,d1		;on active le lecteur
	bclr	d2,d1		;puis on enleve l'ancien
	move.l	d1,$4c2.w		;range le tout
	move.b	d0,(a5)		;pr‚viens les routines
ndisk_end	movem.l	(sp)+,d0-a5
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Saisie de la taille du disk&installation
size_disk
	movem.l	d0-a5,-(sp)
size1	lea	mes3(pc),a0
	bsr	print
	move.w	#80,-(sp)
	bsr	input		;renvoi en D0=nb_car,A0=ad_string
	addq.l	#2,sp
	tst.w	d0
	beq.s	size1
	moveq	#0,d0
size2	move.b	(a0)+,d0
	beq.s	size1
	cmpi.w	#'*',d0		;joker ?
	beq	sd_abort1		;oui,inchang‚
	cmpi.w	#'0',d0
	blt.s	size2		;recherche du premier nombre
	cmpi.w	#'9',d0		;pr‚sent dans la chaine.
	bgt.s	size2

	moveq	#0,d1		;On l'a trouv‚,il faut retirer
	subq.l	#1,a0		;1 … A0 (post-incr‚ment‚)
size3	move.b	(a0)+,d0
	beq.s	size4
	subi.w	#'0',d0
	bmi.s	size4
	cmpi.w	#9,d0		;conversion ASCII->binaire
	bgt.s	size4
	mulu.w	#10,d1
	add.l	d0,d1
	bra.s	size3

size4	move.l	d1,d2
	beq.s	sd_abort1		;taille non nulle de pr‚f‚rence
	move.l	d2,d0
	lsl.l	#8,d2		;transforme Ko=>o
	lsl.l	#2,d2
	cmpi.l	#$ff7cff,d2	;Plus de 16350Ko ????
	bhi.s	sd_abort1		;oui,il est fou lui !!
	move.l	d2,disk_size(a6)	;c'est la taille des donn‚es
	tst.b	resident(a6)	;r‚sident ?
	beq.s	size4_1
	move.l	descr_ad(a6),a4	;adresse ancien descripteur
	cmp.l 	8(a4),d2		;taille ancien=taille nouveau ?
	beq.s	sd_abort1		;oui,pas besoin de s'emmerder
size4_1	add.l	d0,d0		;nb de {cluster=0,5Ko} utiles
	addq.l	#2,d0		;+2 car 0&1 innoccup‚s
	tst.b	d0		;detecte un reste apres la division
	sne	d0		;par 256,et conserve l'indication.
	ror.l	#8,d0		;/256 car un secteur de FAT contient
				;256 clusters (FAT 16 bits)
	bpl.s	size4_2		;y'a un reste ?
	addq.w	#1,d0		;oui,arrondi … +1
size4_2	move.w	d0,FAT_size(a6)	;taille en secteurs de la FAT16
	addi.l	#512+soft_boot+varsize*4+(my_boot-my_bpb)+(1+dir_size)*512,d2
	mulu.w	#1024,d0		;varsize*4:taille header
				;myboot-mybpb:taille routines
				;FAT_size*1024
	add.l	d0,d2		;place totale
	move.l	d2,ram_size(a6)
	bsr	reorg_disk		;D0=taille utile old disk
	move.l	d0,util_size(a6)	;ou 0 si pas encore r‚sident
	cmp.l	disk_size(a6),d0	;ancien tient dans nouveau ?	
	ble.s	size5		;taille Ok
sd_abort2	lea	mes8(pc),a0	;Taille trop petite !!!
	bsr	print
sd_abort1	movem.l	(sp)+,d0-a5	;non,on se casse
	rts

;Maintenant: A4=Descripteur r‚sident (s'il existe)
;            A5=Descripteur provisoire
;            A6=variables (comme dans le reste du programme,d'ailleurs)
;Installation du BPB dans la zone DESCRIPT provisoire
size5	lea	DESCRIPT(pc),a5	;cr‚er le descripteur DNT-RAM
	move.l	d2,(a5)		;taille du bloc Malloqu‚
	move.l	disk_size(a6),d1	;taille utilisable du drive
	move.l	d1,8(a5)		;mise dans le descripteur
	lsr.l	#8,d1		;/512=>taille en clusters
	lsr.w	#1,d1		;on fait +2 car les clusters 0
	addq.w	#2,d1		;et 1 sont inutilis‚s et rep‚r‚s
	move.w	#2,media_ch(a5)	;par rapport au 1er data -2 clusters
	lea	bpbtab(a5),a1	;media_ch ON (bicoze le disk est
	move.l	#$02000001,(a1)+	;cr‚‚ ou modifi‚)
	move.l	#$02000000+dir_size,(a1)+
	move.w	FAT_size(a6),d0
	move.w	d0,(a1)+
	addq.w	#1,d0
	move.w	d0,(a1)+
	add.w	FAT_size(a6),d0
	addi.w	#dir_size,d0
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	#1,(a1)+

;Structure de notre BPB
; 0200     0001     0200     00ds    fs   fs+1     frsect     size     0001
;sctsize  clsize   clszisb  dirlen FATlen 2Š FAT  firstdata  nbfrcls  FAT16
;Donc des FATs 16 bits,qui permettent une taille de 2^15-1 (et non pas 2^16,
;parce que ce sont des donn‚es sign‚es,en tout cas je crois) clusters.Un
;cluster=un secteur,d'o— un cluster=512 octets.En tout,la taille maximum est
;de 16Mo

;Recherche d'un identificateur de drive libre
	tst.b	resident(a6)	;r‚sident ?
	beq.s	size6_0		;ben non
	move.b	(a4),d1		;si,le lecteur est d‚j…
	bra.s	size7_1		;connu
size6_0	moveq	#2,d1		;… partir du drive C
	move.l	$4c2.w,d0		;drive actifs
size6_1	btst	d1,d0		;le drive est utilis‚ ?
	beq.s	size7_0		;Ah que non !
	addq.w	#1,d1		;si merde,c'est rat‚
	cmpi.w	#26,d1		;suivant.
	blt.s	size6_1		;Y'a un suivant ?!?
	lea	mes7(pc),a0	;non,ben merde,pas de lecteur
	bsr	print		;libre
	bra	sd_abort1		;Stop.
size7_0	bset	d1,d0		;
	move.l	d0,$4c2.w		;installe identificateur
size7_1	move.b	d1,(a5)		;et le range

;Initialise les 1eres donn‚es retenues dans DESCRIPT provisoire
	move.w	#REL_NUM,d1	;version du driver
	swap	d1		;hop
	move.w	$446.w,d1		;ancien lecteur de boot
	tst.b	resident(a6)	;r‚sident ?
	beq.s	size8_0		;Non
	move.w	bootdev(a4),d1	;oui=>bootdev de l'ancien descripteur
size8_0	lea	options(a5),a1	;adresse descripteur provisoire
	move.w	options(a6),(a1)+	;range les options
	move.l	d1,(a1)+		;version|bootdev

;On s'occupe du cookie-jar (en zone provisoire)
size9	clr.b	jar_inst(a5)	;par d‚faut,pas de chgt de jar
	movea.l	$5a0.w,a2		;celui install‚ actuellement
	tst.b	resident(a6)	;r‚sident ?
	bne.s	size9_10		;oui,deuxiŠme algo.

size9_0	bsr	my_cook		;compte les cookies
	blt.s	size9_4		;ok,y'a de la place dans le jar
	cmpi.w	#40,d0		;et non!.mais y'en a combien?
	blt.s	size9_1		;pas trop,ca baigne !...
size9_err	lea	mes10(pc),a0	;aie,cookies trop nombreux
	bsr	print		;installation refus‚e
	bra	sd_abort1		;Cancel

size9_1	lea	cookie_jar(a5),a0	;jar provisoire
	st.b	jar_inst(a5)	;nouveau jar … installer
	moveq	#40,d0		;taille que l'on donne.
	move.l	a2,d6		;y'a-t-il un cookie-jar ?
	beq.s	size9_3		;non=>A0 pointe NULL_cookie
size9_2	move.l	(a2)+,(a0)+	;analyse du cookie-jar tout
	beq.s	size9_4		;en le recopiant
	move.l	(a2)+,(a0)+
	bra.s	size9_2		;cookie suivant
size9_3	addq.l	#4,a0		;+4,car sortie "anormale"
size9_4	move.l	#'DNTR',-4(a0)	;A0 pointe NULL_cookie+4
	clr.l	(a0)+		;cook_info=descripteur (+tard)
	clr.l	(a0)+		;nouveau NULL_cookie
	bra.s	size9_20		;raccordement

size9_10	lea	cookie_jar(a5),a0	;jar provisoire
	suba.l	a4,a2		;jar actuel-descr_ad
	cmpa.l	#cookie_jar,a2	;c'‚tait notre jar ?
	bne.s	size11		;non,pas de manip cookie-jar
	st.b	jar_inst(a5)	;si,faut re-installer notre jar
	adda.l	a4,a2		;r‚tablit a2...
	moveq	#40,d0		;c'est notre taille.
size9_12	move.l	(a2)+,(a0)+	;analyse du cookie-jar tout
	beq.s	size9_20		;en le recopiant
	move.l	(a2)+,(a0)+
	bra.s	size9_12

;A1 pointe NULL_cookie+4 en sortie de size9_xx
size9_20	move.l	d0,(a0)+		;taille du cookie-jar

;Effectue les sauvegardes des anciens vecteurs disk
size11
	tst.b	resident(a6)	;
	beq.s	size11_0		;non r‚sident,no prob.
	move.l	dv_bpb-4(a4),-(sp)	;si,on enlŠve le chainage
	pea	$472.w		;XBRA des 3 vecteurs
	bsr	xbra_kill		;On enleve le chainage,
	move.l	dv_rw-4(a4),(sp)	;puis on le remet plus
	pea	$476.w		;tard.Cela revient …
	bsr	xbra_kill		;changer l'adresse du
	move.l	dv_ch-4(a4),(sp)	;maillon,mais en plus
	pea	$47e.w		;on se retrouve en tete
	bsr	xbra_kill		;de liste XBRA
	lea	16(sp),sp

size11_0	move.l	d2,-(sp)		;recherche la m‚moire
	bsr	memory_search	;Retour:D0=adresse new_ramdisk
	lea	4(sp),sp		;conserve CCR.
	bne	sd_abort1		;Aie,pas de m‚moire dispo
	move.l	d0,d7		;conserve l'adresse m‚moire.
	
;my_boot-my_bpb=taille prise par toutes les routines except‚e my_boot
;calculer adresse nouveau disk+recopier l'ancien disk
size12	movea.l	d7,a0		;calcul adresse du disque
	lea	my_boot-my_bpb+varsize*4(a0),a0 ;d‚finitif
	move.l	a0,d0
	andi.w	#$fe00,d0		;arrondi … 512 prŠs
	exg.l	a0,d0
	cmp.l	a0,d0		;adresse d‚j… multiple de 512?
	beq.s	size12_0		;si ‚gal,pas besoin de compenser
	lea	$200(a0),a0	;non,donc +512
size12_0	lea	soft_boot(a0),a0	;maintenant,+soft_boot pour l'adresse
	move.l	a0,4(a5)		;du disk,que l'on range dans
				;le descripteur provisoire
	tst.b	resident(a6)	;r‚sident ??
	beq.s	size12_1		;non
	move.l	a0,-(sp)		;
	bsr	copy_disk		;cette routine recopie les secteurs
	addq.l	#4,sp		;du disk … leur nouvelle place
	bra.s	size13

size12_1	moveq	#0,d0
	move.w	FAT_size(a6),d0	;A0 contient l'adresse du disk
	add.l	d0,d0		;on efface les 2 FATs
	addq.l	#dir_size+1,d0	;le directory+le boot-sector
	lsl.l	#7,d0		;(512/4=128 mots-long).
	moveq	#0,d1		;
size12_2	move.l	d1,(a0)+		;(le plus important est d'effacer les
	subq.l	#1,d0		;FATs et le catalogue,le reste est
	bne.s	size12_2		;facultatif)

;Installation du descripteur provisoire et du cookie-jar en m‚moire
size13	movea.l	d7,a1		;installe DESCRIPT
	lea	mb_vars(pc),a3	;repŠre les variables.
	move.l	d7,(a3)+		;sauve DESCRIPT dans my_vars
	moveq	#varsize-1,d0	;-1 car dbf
	movea.l	a5,a0		;copie de travail
size13_0	move.l	(a0)+,(a1)+
	dbf	d0,size13_0	;en fin,A1=derriŠre le descripteur
	tst.b	jar_inst(a5)	;faut installer notre jar ?
	beq.s	size13_1		;non,pas la peine
	movea.l	d7,a0		;si,on prend son adresse
	lea	cookie_jar(a0),a0	;voil… qui est fait
	move.l	a0,$5a0.w		;on l'installe
size13_1	bsr	cookie_check	;recherche le cookie DNTR
	move.l	d7,(a0)		;on y installe l'adresse du
				;descripteur.

;installation du driver de ram-disk en m‚moire
				;A3 pointe sur le tableau de
				;   variables de my_boot
size14	lea	my_bpb(pc),a0	;A0 contient la routine source
	move.l	#my_rw,d0		;D0=fin de la routine
	lea	12(a1),a1		;deplace=>les pointeurs suivent
	move.l	a1,-(sp)		;A1 contient l'adresse d'arriv‚e
	pea	$472.w		;pr‚pare l'appel … xbra_link
	move.l	a1,(a3)+		;
	lea	-12(a1),a1		;A1 repointe sur le chunck XBRA
	bsr.s	deplace		;on installe la routine
	bsr	xbra_link		;et on la relie.

	move.l	a1,4(sp)
	move.l	a1,(a3)+
	addq.l	#4,(sp)		;vecteur suivant
	move.l	#my_ch,d0
	bsr.s	deplace
	bsr	xbra_link

	move.l	a1,4(sp)
	move.l	a1,(a3)+
	addq.l	#8,(sp)
	move.l	#my_reset,d0
	bsr.s	deplace
	bsr	xbra_link
	addq.l	#8,sp
	bra.s	rb_install
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deplace	sub.l	a0,d0		;A0:source|A1:arriv‚e|D0=fin
	subq.w	#1,d0
deplace0	move.b	(a0)+,(a1)+
	dbf	d0,deplace0		;transfert des routines
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Installation des routines de reset & soft-boot.
rb_install	move.l	a1,(a3)+		;stocke my_reset dans mb_vars
	lea	$426.w,a2		;par d‚faut,d‚bute le chainage
	tst.b	resident(a6)	;disque r‚sident ?
	beq.s	rbinst_0		;non,‡a marche.
	lea	dv_reset(a4),a2	;oui,garde chainage
rbinst_0	move.l	(a2)+,(a1)+	;effectue chainage reset
	move.l	(a2)+,(a1)+	;...8 octets
	move.l	a1,$42a.w		;reset vector
	move.l	#$31415926,$426.w	;magic-reset
	move.l	#my_boot,d0	:copier my_reset
	addq.l	#8,a0		;saute le dc.l 0,0
	bsr.s	deplace

rbinst_3	movea.l	d7,a2		;r‚cupŠre l'adresse du ram-disque
	movea.l	4(a2),a2		;calcul‚e plus haut et en d‚duit
	lea	-soft_boot(a2),a2	;l'adresse de my_boot en memoire
	move.l	#$12123456,(a2)	;magic1 pour le soft-boot
	move.l	a2,4(a2)		;magic2 pour le soft-boot
	lea	8(a2),a1		;copier la routine aprŠs ces 2
	move.l	#my_end,d0		;magics.(my_boot+my_cook+messages)
	bsr.s	deplace

;installation du checksum,qui est en d‚but de boot-soft (car ce dernier
;d‚passe 512 octets )
	lea	10(a2),a1		;aprŠs magic1,magic2 et "bra.s *+4"
	move.w	#$ff,d1
	move.w	#$5678,d0
size15	sub.w	(a2)+,d0
	dbf	d1,size15
	move.w	d0,(a1)

	move.l	d7,descr_ad(a6)
	st	resident(a6)
	lea	mes6(pc),a0
	bsr	print
	bra	sd_abort1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;d‚truit les liens de DNT-RAM dans la chaine XBRA d'un vecteur
;donn‚.Appel:Fn(v_vect,old_val)
;‚crase le vecteur si la chaine XBRA est rompue avant nous
xbra_kill	movem.l	d0/a0-1,-(sp)
	movea.l	16(sp),a0		;adresse vecteur
	movea.l	(a0),a1		;pointeur
	moveq	#0,d0		;premier de la liste
xkill0	cmpi.l	#"XBRA",-12(a1)	;XBRA compatible ?
	bne.s	xkill2		;non,‚crase le vecteur
	cmpi.l	#"DNTR",-8(a1)	;est-ce nous ?
	beq.s	xkill1		;oui,on se retire
	move.l	a1,d0		;conserve le pr‚c‚dent
	movea.l	-4(a1),a1		;suivant
	bra.s	xkill0		;barbatruc
xkill1	tst.l	d0		;DNTR premier de la liste ?
	beq.s	xkill2		;oui,‚crase le vecteur avec !
	movea.l	d0,a0		;non,on se retire de la chaine
	move.l	20(sp),-4(a0)	;old_val dans le chainage
xkill_end	movem.l	(sp)+,d0/a0-1	;cassos
	rts
xkill2	move.l	20(sp),(a0)	;‚crase le vecteur avec old_val
	bra.s	xkill_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Effectue la liaison entre nous et le reste d'une chaine XBRA.
;Le vecteur est effectivement modifi‚.
xbra_link			;Fn(v_vect,new_val)
	movem.l	a0-1,-(sp)
	movem.l	12(sp),a0-1	;v_vect et new_val
	move.l	(a0),-4(a1)	;copie {v_vect} dans XBRA-chunck
	move.l	a1,(a0)		;mettre new_val dans v_vect
	movem.l	(sp)+,a0-1
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;copier d'un ancien disk … un nouveau (pas de perte de donn‚es au re-size)
copy_disk		;fn(new_ram).Les notations new: et old: indiquent
		;… quel disque (le nouveau ou l'ancien) se r‚fŠrent
		;les indications & calculs
	movem.l	d0-a5,-(sp)
	move.l	60(sp),a0
	move.l	util_size(a6),d0	;D0=TAILLE UTILE DU DISQUE
	move.l	descr_ad(a6),a1	;descripteur r‚sident
	movea.l	4(a1),a2		;adresse ancien disk
	clr.l	-soft_boot(a2)	;on ecrase magic-boot de l'
				;ancienne routine de soft-boot
	cmpa.l	a0,a2		;copier dans quel sens ?
	blt.s	cd10		;A0=new_disk,A2=old_disk
				;A1=old_descr D0=TAILLE UTILE
;copier=descendre l'adresse.=>copie de bas en haut
	move.w	bpbtab+8(a1),d2	;old:FAT_size,nombre de secteurs
				;… copier (de l'ancien disk,car
				;il est + petit que le nouveau,
				;donc moins de FATs)
	move.w	d2,d3		;conserve ce nombre (l'accŠs
				;aux datas du descripteur est
				;interdit plus tard,vu qu'on
				;trifouille l'ancien disk)
	move.l	a0,-(sp)		;paramŠtres r‚-utilis‚s plus
	move.l	a2,-(sp)		;tard
cd1	moveq	#31,d1		;A1>A0 <=> ancien>nouveau
cd2	move.l	(a2)+,(a0)+	;donc copier de bas en haut
	move.l	(a2)+,(a0)+	;
	move.l	(a2)+,(a0)+	;
	move.l	(a2)+,(a0)+	;
	dbf	d1,cd2		;copier,secteurs par secteurs,
	dbf	d3,cd1		;les secteurs {boot+FAT}
;dbf se fait sur FAT_size,donc FAT_size+1 secteurs donc le boot sector est
;du voyage
	movea.l	(sp)+,a2		;R‚cupŠre old_disk
	movea.l	(sp)+,a0		;adresse new:boot-sector
	lea	512(a0),a0		;=>adresse new:1ere FAT
	move.w	FAT_size(a6),d1	;new:FAT_size
	mulu.w	#512,d1		;offset pour new:2eme FAT
	movea.l	a0,a3		;
	adda.w	d1,a3		;calcul new:2eme FAT
	movea.l	a3,a4		;conserve new:2Šme FAT
	move.w	d2,d3		;nb de secteurs de FAT
	subq.w	#1,d3		;-1
cd3	moveq	#31,d1
cd4	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	dbf	d1,cd4		;doubler,secteurs par secteurs,
	dbf	d3,cd3		;les new:FATs

	bra.s	cd6		;ensuite,clear le reste des FAT
cd5	clr.l	(a0)+		;sproutch
	clr.l	(a3)+		;damned.je suis fait
cd6	cmpa.l	a0,a4		;fin de 1ere FAT ?
	bgt.s	cd5		;qd ca arrive,a3=new:fin 2eme FAT
				;donc d‚but du disk (root-dir)
	add.w	d2,d2		;A2=old_disk+(1+2*FAT)*512
	addq.w	#1,d2		;donc A2=new:fin de 2eme FAT
	mulu.w	#512,d2		;(la aussi c'est le root-dir)
	add.l	d2,a2		;
	addi.l	#dir_size*512,d0	;Ne pas oublier le root-dir !!
	lsr.l	#4,d0		;/16:4 mot-longs … la fois
cd7	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	subq.l	#1,d0
	bne.s	cd7
cd_end	movem.l	(sp)+,d0-a5
	rts

;A0=new_disk,A2=old_disk,A1=old_descr
;copier=augmenter l'adresse=>copie de haut en bas
cd10
	movea.l	a2,a3		;
	adda.l	d0,a3		;a3=old:(disque+util_size)
	movea.l	a0,a4		;
	adda.l	d0,a4		;
	move.w	bpbtab+8(a1),d1	;
	add.w	d1,d1		;old:(1+dir_size+2*FAT_size)
	addq.w	#1+dir_size,d1	;
	mulu.w	#512,d1		;a3+(dir+2*FAT+1)*512
	adda.l	d1,a3		;=>a3=old:fin des donn‚es utiles
	move.w	FAT_size(a6),d1	;
	add.w	d1,d1		;
	addq.w	#dir_size+1,d1	;idem calcul sur nouveau disk
	mulu.w	#512,d1		;donc A4=new:fin donn‚es utiles
	adda.l	d1,a4		;(qui ne sont pas encore l…!!)
	addi.l	#dir_size*512,d0	;Ne pas oublier le directory !!
	lsr.l	#4,d0		;/16 car 4 mots-longs … la fois
cd11	move.l	-(a3),-(a4)
	move.l	-(a3),-(a4)
	move.l	-(a3),-(a4)
	move.l	-(a3),-(a4)
	subq.l	#1,d0
	bne.s	cd11

	move.w	FAT_size(a6),d0	;taille new:FAT car le nouveau
	addq.w	#1,d0		;disk est plus petit,donc moins
	mulu.w	#512,d0		;de FATs.
	adda.l	d0,a2		;old:fin de 1ereFAT utile
	adda.l	d0,a0		;new:fin de 1ereFAT r‚elle
				;A4=new:fin de 2eme FAT
	subi.l	#512,d0		;pas le boot-sector !!!!
	lsr.l	#4,d0		;/16:4 mots-longs … la fois
cd12	REPT 4
	move.l	-(a2),-(a0)
	move.l	(a2),-(a4)
	ENDR
	subq.l	#1,d0
	bne.s	cd12
	moveq	#31,d0		;maintenant,le boot !
cd13	move.l	-(a2),-(a0)
	move.l	-(a2),-(a0)
	move.l	-(a2),-(a0)
	move.l	-(a2),-(a0)
	dbf	d0,cd13
	bra.s	cd_end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;D0.L=fn(nouvelle taille)
memory_search			;Z=0 erreur|Z=1 Ok
	movem.l	d1-a5,-(sp)
	movea.l	descr_ad(a6),a5	;A5=descripteur r‚sident ou 0
	move.l	56(sp),d2		;D2=nouv. taille
	move.l	#"YEAH",-(sp)	;fin de pile,pour la fonction
				;free_bloc qui broute sinon.
	moveq	#0,d7		;taille disponible=0 (d‚but)
	tst.b	resident(a6)	;ram-disque d‚j… r‚sident ?
	beq	ms_bcl10		;non,2eme algorithme

	move.l	(a5),d3		;D3=taille ancien ram-disque
	lsl.l	#8,d3		;On ‚limine les 8 bits forts
	lsr.l	#8,d3		;ensuite Delta(tailles)=qt‚
	sub.l	d2,d3		;enlev‚e au ram-disque (sign‚e)
	moveq	#-1,d4		;flag "non trouv‚"
ms_bcl0	moveq	#-1,d0		;
	moveq	#$48,d1		;demande le + grand bloc
	bsr	Gemdos_go		;au Gemdos
	move.l	d0,d5		;note sa taille.
	ble.s	ms1		;pas de place/erreur ?
	add.l	d0,d7		;non.Actualise taille disponible
	bsr	Gemdos_go		;r‚serve le bloc
	move.l	d0,-(sp)		;empile sa taille
	add.l	d5,d0		;taille+start=fin du bloc
	cmpa.l	d0,a5		;correspont-elle au ram-disque?
	bne.s	ms_bcl0		;non,suivant.
	movea.l	sp,a4		;note son adresse dans la
	move.l	d5,d4		;pile et sa taille
	bra.s	ms_bcl0		;puis on boucle.

ms1	tst.l	d4		;on a trouv‚ ?
	bmi.s	ms1_err		;non (gasp)
	add.l	d3,d4		;taille rajout+Delta(tailles)
	bpl.s	ms2		;=taille dummy >=0 ? OUI->ok
ms1_err	lea	mes9(pc),a0	;aie,erreur dans la m‚moire
	bsr	print		;on signale l'erreur et on se
	bsr.s	free_blocs		;casse,aprŠs lib‚ration
	moveq	#-1,d0		;ci-dessus//Z=0,erreur
ms_end	movem.l	(sp)+,d1-a5	;
	rts

ms2	add.l	d3,d7		;taille disponible aprŠs ‡a
	cmpi.l	#$8000,d7		;>32Ko ?
	bge.s	ms2_0		;oui,saute
	bsr	ms_sysq		;non,demande confirmation
ms2_0	moveq	#$49,d1		;Mfree pour Gemdos_go
	move.l	(a4),d0		;r‚cupŠre le bloc interessant
	move.l	#"YEAH",(a4)	;on le marque
	bsr	Gemdos_go		;et on le libŠre !
	bsr.s	exchange_run	;=>comme son nom l'indique...
	move.l	a5,d0		;libere ancienne place
	bsr	Gemdos_go		;hop
	move.l	d4,d0		;taille dummy
	moveq	#$48,d1		;Malloc
	bsr	Gemdos_go		;reserve dummy
	move.l	d0,d4		;conserve dummy
	move.l	d2,d0		;taille du d‚finitif
	bsr	Gemdos_go		;reserve d‚finitif
	exg.l	d0,d4		;‚change dummy et d‚finitif
	moveq	#$49,d1
	bsr	Gemdos_go		;libŠre dummy
	bsr.s	exchange_run	;r‚tablit le _run
ms3	bsr.s	free_blocs		;2 fois (comme toujours
	bsr.s	free_blocs		;quand ca marche.hum...)
	move.l	d4,d0		;adresse du bloc
	moveq	#0,d4		;Z=1,tout est Ok
	bra.s	ms_end

exchange_run
	move.l	a0,-(sp)
	lea	save_BIOS(a6),a0	;adresse de sauvegarde
	bsr	swap_BIOS		;installe le _run fictif
	movea.l	(sp)+,a0		;ou le "d‚sinstalle",c'est
	rts			;une bascule

free_blocs			;ATTENTION:pas de sauvegarde registres
	move.l	(sp)+,a1		;adresse de retour
	moveq	#$49,d1		;Mfree
fb_bcl	move.l	(sp)+,d0		;d‚pile les adresses de blocs
	cmpi.l	#"YEAH",d0		;Fin de liste ?
	beq.s	fb_end		;oui !
	bsr	Gemdos_go		;non,libŠre le bloc
	bra.s	fb_bcl		;et repart pour une boucle !
fb_end	jmp	(a1)		;retour … l'appelant

;On arrive en ms_bcl10 si resident(a6)=0 donc descr_ad(a6)=a5=0
;Le but du jeu est de rechercher tous les blocs m‚moires que
;peut offir le Gemdos,et chercher celui qui est assez grand et le plus
;haut possible en m‚moire.
ms_bcl10	moveq	#-1,d0
	moveq	#$48,d1		;plus grand bloc actuel
	bsr	Gemdos_go
	add.l	d0,d7		;actualise memoire disponible
	move.l	d0,d4		;pas de m‚moire ?
	beq.s	ms11		;oui,stop
	bsr	Gemdos_go		;si,reserve le bloc
	move.l	d0,-(sp)		;empile son adresse
	cmp.l	d2,d4		;bloc assez grand ?
	blt.s	ms_bcl10		;non,boucle
	cmp.l	a5,d0		;adresse plus haute ?
	blt.s	ms_bcl10		;non,boucle
	movea.l	d0,a5		;si,note le bloc valide
	move.l	d4,d5		;puis sa taille
	movea.l	sp,a4		;et sa position sur la pile
	bra.s	ms_bcl10		;boucle
ms11	move.l	a5,d0		;on va lib‚rer notre bloc
	beq	ms1_err		;aie,aucun bloc trouv‚
	sub.l	d2,d7		;taille disponible aprŠs installation
	cmpi.l	#$8000,d7		;il en reste au moins 32Ko ?
	bge.s	ms11_0		;oui,saute
	bsr.s	ms_sysq		;non,demande confirmation
ms11_0	moveq	#$49,d1		;Mfree
	bsr	Gemdos_go		;hop
	move.l	#"YEAH",(a4)	;marquage pour stopper free_bloc

ms12	sub.l	d2,d5		;bloc_size-nouvelle taille
	bsr	exchange_run	;=dummy_size/../
	move.l	d5,d0		;taille dummy
	moveq	#$48,d1		;Malloc
	bsr	Gemdos_go		;reserve dummy
	move.l	d0,d5		;conserve dummy
	move.l	d2,d0
	bsr	Gemdos_go		;reserve d‚finitif
	exg.l	d0,d5		;‚change dummy et d‚finitif
	moveq	#$49,d1
	bsr	Gemdos_go		;libŠre dummy
	bsr	exchange_run

ms13	bsr.s	free_blocs		;2 free_blocs car on a pos‚
	bsr.s	free_blocs		;une 2eme marque plus haut
	move.l	d5,d0		;adresse du bloc
	moveq	#0,d4		;Z=1,tout est Ok
	bra	ms_end
	
ms_sysq	movem.l	d0-1/a0,-(sp)	;sauve registres
	pea	mes4(pc)		;alerte m‚moire systŠme
	move.l	(sp)+,d0		;affichage de la demande
	moveq	#$9,d1		;
	bsr	Gemdos_go		;
	move.w	#1,-(sp)		;attend la r‚ponse de
	trap	#1		;l'utilisateur
	addq.l	#2,sp		;
	ori.w	#$20,d0		;passe en minuscules
	cmpi.w	#"o",d0		;r‚ponse positive ?
	beq.s	mss_0		;oui,retour
	move.l	#ms1_err,12(sp)	;non,allez vers l'erreur
mss_0	movem.l	(sp)+,d0-1/a0	;restitue les registres
	rts			;hop,on y va
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
kill_disk	movem.l	d0/d1/a0-2/a5,-(sp)
	tst.b	resident(a6)	;r‚sident ?
	beq	kill_end		;non,c'est dur de le tuer..
	lea	mes12(pc),a0	;demande confirmation avant
	bsr	print		;de virer le Ramdisk
	move.w	#1,-(sp)
	trap	#1		;Cconin
	addq.l	#2,sp
	ori.w	#$20,d0		;passe en minuscules
	cmpi.w	#"o",d0		;alors,c'est bien ‡a ?
	bne	kill_end		;non,on stoppe.
;remet les vecteurs disque
kill0	move.l	descr_ad(a6),a5	;cherche le descripteur
	move.l	dv_bpb-4(a5),-(sp)	;si,on enlŠve le chainage
	pea	$472.w		;XBRA des 3 vecteurs
	bsr	xbra_kill
	move.l	dv_rw-4(a5),(sp)
	pea	$476.w
	bsr	xbra_kill
	move.l	dv_ch-4(a5),(sp)
	pea	$47e.w
	bsr	xbra_kill
	lea	16(sp),sp
;libere le bloc
kill1	bsr	exchange_run
	move.l	a5,d0		;lib‚rer la place du ram-disk
	moveq	#$49,d1
	bsr	Gemdos_go
	bsr	exchange_run
	move.b	(a5),d0		;r‚cupere indicateur disk
	move.l	$4c2.w,d1
	bclr	d0,d1		;retirer le disk des actifs
	move.l	d1,$4c2.w
	move.w	bootdev(a5),$446.w	;r‚tablir disque de boot
	move.l	4(a5),a1		;r‚cupŠre adresse disque,
	clr.l	-soft_boot(a1)	;-soft_boot=>kill le magic-boot
	sf	resident(a6)	;pas de r‚sident
	clr.l	descr_ad(a6)	;A partir de maintenant,
	clr.l	ram_size(a6)	;le disque a cess‚ d'exister.
	clr.l	util_size(a6)	;
	clr.l	disk_size(a6)	;
	clr.w	FAT_size(a6)	;

;conserve le cookie-jar et la routine reset (… cause des TOS 1.2 et 1.0)
kill2
	move.l	#40*8+my_cook-my_reset,-(sp) ;taille n‚cessaire.
	bsr	memory_search	;prendre la m‚moire
	addq.l	#4,sp		;il faut qu'on s'installe.
	movea.l	d0,a1		;adresse destination de my_reset
	lea	my_reset+8(pc),a0	;pour la copie on r‚-utilise
				;la fonction >deplace<
	lea	dv_reset(a5),a2	;adresse ancien my_reset
	move.l	(a2)+,(a1)+	;poursuit le chainage
	move.l	(a2)+,(a1)+	;‚tabli pr‚cedement.
	move.l	a1,$42a.w		;installe notre reset
	move.l	#$31415926,$426.w	;<-au cas o— qqn l'aurait d‚truit
	move.l	#my_boot,d0
	bsr	deplace

	move.l	$5a0.w,d0		;adresse jar actuel.
	movea.l	d0,a0		;en A0 pour transfert.
	sub.l	a5,d0		;offset avec le jar du driver
	cmpi.l	#cookie_jar,d0	;c'‚tait le notre ?
	beq.s	*+4		;oui,transfert le jar !!.
	movea.l	a0,a1		;non,pas de chgt d'adresse.
	move.l	a1,$5a0.w		;nouveau jar
kill4	move.l	(a0)+,d0		;actualise le jar en
	beq.s	kill6		;retirant le cookie DNTR
	cmpi.l	#"DNTR",d0		;c'est nous ?
	beq.s	kill5		;oui
	move.l	d0,(a1)+		;non,recopie le cookie
	move.l	(a0)+,(a1)+	;
	bra.s	kill4		;suivant
kill5	addq.l	#4,a0		;c'est nous,on se saute
	bra.s	kill4		;suivant
kill6	move.l	d0,(a1)+		;fini
	move.l	(a0),(a1)		;
	lea	mes21(pc),a0
	bsr	print
kill_end	movem.l	(sp)+,d0/d1/a0-2/a5
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                               ;
;                                               ;
;       R‚organisation du disque virtuel        ;
;          et estimation de sa taille           ;
;                                               ;
;                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reorg_disk			;Renvoie en D0 la taille du disk
			;(en Ko),apres "compression" des
			;fichiers
	moveq	#0,d0
	tst.b	resident(a6)
	beq.s	reorg_end
	movem.l	d1-a5,-(sp)
	move.l	descr_ad(a6),a1
	move.w	bpbtab+6(a1),-(sp)	;dir_size,celle qui est en bpbtab
	move.w	bpbtab+8(a1),d7
	move.w	d7,-(sp)		;FAT_size,en bpbtab (comme ca ce sont
	mulu.w	#512,d7		;des donn‚es sures,car l'appel depuis
	move.l	d7,-(sp)		;size_disk modifie FAT_size(a6))
	move.w	#$48,-(sp)		;cherche de la place pour
	trap	#1		;new_FAT
	addq.l	#6,sp
	move.l	d0,-(sp)		;empile new_FAT
	beq.s	reorg_error	;si pas de m‚moire disponible,
	bmi.s	reorg_error	;on se casse vite fait

	movea.l	d0,a2		;efface les donn‚es de new_FAT
	lsr.l	#2,d7		;nb de mots...-1
	subq.l	#1,d7		;Phase obligatoire,car new_FAT
reorg_0	clr.l	(a2)+		;contient n'importe quoi (zone
	dbf	d7,reorg_0		;donn‚e par le Gemdos=>suspect)

	move.l	4(a1),-(sp)	;empile disk_adresse
	bsr	explore_root_for_FAT	;=>d6 contient le nb de clusters
	move.l	d0,d6		;occup‚s du disque (taille utile)
	bsr	make_new_FAT	;effectuer le travail
	bsr.s	sort_sectors
	move.w	#2,media_ch(a1)	;disk chang‚
	addq.l	#4,sp
	move.w	#$49,-(sp)		;liberer new_FAT
	trap	#1
	lea	10(sp),sp		;fini de r‚tablir la pile
	move.l	d6,d0		;renvoie le nbre de clusters occup‚s
	subq.w	#2,d0		;-2 car 0&1 inutilis‚s
	mulu.w	#512,d0		;*512 pour la taille
reorg_quit	movem.l	(sp)+,d1-a5
reorg_end	rts
reorg_error
	addq.l	#8,sp		;r‚tablit la pile
	lea	mes11(pc),a0	;pas de v‚ritable r‚organisation,
	bsr	print		;on regarde seulement quel taille
	move.l	4(a1),a0		;adresse du disk
	adda.l	d7,a0		;est prise par les fichiers
	lea	512(a0),a0 	;se mettre en fin de FAT
re_bcl	tst.w	-(a0)		;cluster occup‚ ?
	bne.s	re_0		;oui,on a trouv‚
	subq.l	#2,d7		;non,d‚cremente le nombre de
	bra.s	re_bcl		;clusters occup‚s
re_0	subq.l	#4,d7		;clusters 0&1 inoccup‚s
	lsl.l	#8,d7		;*256 au lieu de 512 car D7
	move.l	d7,d0		;est d‚j… *2,vu que c'est un
	bra.s	reorg_quit		;compteur de mots.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
name	equ	$00
ext	equ	$08
attrib	equ	$0b
ftime	equ	$16	;diff‚rents offsets des entr‚es du
fdate	equ	$18	;directory.Attention,les donn‚es
clust	equ	$1a	;en mot et mot-long sont invers‚es
size	equ	$1c	;(poids faible/fort ou min/faible/fort/max)

read_only	equ	0
hidden	equ	1
systeme	equ	2	;num‚ro de bit des attributs de fichier
label	equ	3
sub_dir	equ	4
arch_bit	equ	5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;sort_sectors(disk_adress,new_FAT,FAT_size,dir_size)
sort_sectors
	movem.l	d0-a6,-(sp)
	movem.l	64(sp),a4/a6
	lea	$200(a4),a5	;A4=disk_adress|A5=old_FAT
	movem.w	72(sp),d0/d1	;A6=new_FAT
	add.w	d0,d1
	add.w	d0,d1
	subq.w	#1,d1		;sect_off<=>cluster0
	lsl.w	#8,d0
	subq.w	#1,d0		;.W car moins de 32000 clusters
	moveq	#2,d6		;index x dans les FATs
	moveq	#4,d7		;… partir du cluster No2
ss_bcl0	moveq	#0,d2		;annule pour calculs d'offset
	move.w	0(a6,d7.l),d2	;si nul,l'exploration de new_FAT
	beq.s	ss_end		;est termin‚e
	andi.w	#$7fff,d2		;EnlŠve marque de fin de fichier
	cmp.w	d6,d2		;x=new_FAT[x] ?
	beq.s	ss_bcl0_end	;oui,le secteur est … sa place
	move.l	d6,d3		;non,on procŠde … l'‚change
	add.w	d1,d3		;(x+sect_off)*512
	add.w	d3,d3
	lsl.l	#8,d3
	movea.l	a4,a0		;adresse du secteur correspondant
	adda.l	d3,a0		;au cluster x
	add.w	d1,d2
	add.w	d2,d2
	lsl.l	#8,d2		;(new_FAT[x]+sect_off)*512
	movea.l	a4,a1		;adresse du secteur correspondant
	adda.l	d2,a1		;au cluster new_FAT[x]
	moveq	#31,d2		;32*4 mots-longs … ‚changer
ss_bcl1	REPT	4
	move.l	(a0),d3
	move.l	(a1),(a0)+
	move.l	d3,(a1)+
	ENDR
	dbf	d2,ss_bcl1
	move.l	d6,d2		;maintenant,recherche y tel que
	addq.l	#1,d2		;new_FAT[y]=x pour transformer
	add.l	d2,d2		;en new_FAT[y]=new_FAT[x] (on
	move.w	d0,d3		;vient d'‚changer les secteurs)
	subq.w	#1,d3		;On cherche ca pour y>x
ss_bcl2	move.w	0(a6,d2.l),d4	;cluster suivant
	andi.w	#$7fff,d4		;EnlŠve marque de fin de fichier
	addq.l	#2,d2		;y++
	cmp.w	d6,d4		;new_FAT[y]=x ?
	dbeq	d3,ss_bcl2		;non,boucle
	bne.s	ss_bcl0_end	;boucle finie sans trouver ?
	move.w	0(a6,d7.l),-2(a6,d2.l) ;new_FAT[y]=new_FAT[x]
ss_bcl0_end
	addq.w	#1,d6
	addq.l	#2,d7		;x++
	dbf	d0,ss_bcl0
ss_end	movem.l	(sp)+,d0-a6
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;make_new_FAT(disk_adress,new_FAT,FAT_size)
make_new_FAT
	movem.l	d1/d6/a4-a6,-(sp)
	moveq	#0,d1
	movem.l	24(sp),a5-a6
	move.w	32(sp),d1
	lea	$204(a5),a5	;A5=old_FAT+4|A6=new_FAT
	movea.l	a5,a4		;les deux FAT16
	lsl.w	#8,d1		;.W car moins de 32000 clusters
	adda.w	d1,a4
	adda.w	d1,a4		;adresse deuxieme FAT16
	subq.w	#2+1,d1		;d1=FAT_size.-2 car on commence
				;au cluster2,et -1 car dbf
	moveq	#3,d6		;x+1
	clr.l	(a6)+		;+4 car 0&1 libres
mnf_bcl0	ror.w	#8,d6		;mise au format Intel
	move.w	d6,(a5)		;par defaut,old_FAT[x]=x+1
	ror.w	#8,d6
	tst.w	(a6)+		;new_FAT[x]<=0 ?
	bne.s	mnf0_0		;=0 ?
	clr.w	(a5)		;oui,effacer (cluster libre)
				;le bpl.s sert de bra.s pour
				;cette branche (clr.w=>PL)
mnf0_0	bpl.s	mnf0_1		;>0 ?,oui old_FAT correct
	move.w	#$ffff,(a5)	;non,fin de fichier dans old_FAT
mnf0_1	addq.w	#1,d6
	move.w	(a5)+,(a4)+	;recopie dans la 2eme FAT16
	dbf	d1,mnf_bcl0
	movem.l	(sp)+,d1/d6/a4-a6
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;nb_clust=explore_root_for_FAT(disk_adresse,new_FAT,FAT_size,dir_size)
explore_root_for_FAT		;A4=adresse disk|A5=adresse ancienne FAT
			;A6=adresse new_FAT
	movem.l	d1-a6,-(sp)
	movem.l	60(sp),a4/a6	;adresse disk&nvelle FAT16
	movem.w	68(sp),d0/d1	;D0=dir_size,D1=FAT_size
	exg	d0,d1
	moveq	#2,d6		;num‚ro }cluster No 2
	moveq	#4,d7		;offset }dans la new_FAT
	clr.w	-(sp)		;new_parent=0 (root),cf plus
				;bas dans explore_sub_for_FAT
	move.w	d0,-(sp)
	add.w	d1,(sp)
	add.w	d1,(sp)
	subq.w	#1,(sp)		;sect_off=cluster0,empil‚

	movea.l	a4,a1
	add.w	d1,d1
	addq.w	#1,d1		;512*(FAT_size*2+1)
	mulu.w	#512,d1
	adda.l	d1,a1		;adresse root_directory

	movea.l	a4,a5
	lea	512(a5),a5		;adresse ancienne FAT16

	lsl.w	#4,d0		;nb d'entr‚es
	subq.w	#1,d0		;pour 1 secteur,16 entr‚es

erff_bcl	cmp.b	#$e5,name(a1)	;entr‚e valide ?
	beq.s	erff_bcl_end
	tst.b	name(a1)
	beq.s	erff_bcl_end
	move.w	clust(a1),d1
	ror.w	#8,d1		;remet au format Motorola
	ror.w	#8,d6		;mettre D6 au format Intel
	move.w	d6,clust(a1)	;nouveau starter du fichier
	ror.w	#8,d6 		;remettre D6 normal
	move.w	d6,-(sp)		;empile new_own
	move.w	d1,-(sp)		;tracer le fichier par l'
	bsr.s	trace_file		;ancienne FAT16
	addq.w	#4,sp
	btst	#sub_dir,attrib(a1)	;un dossier ?
	beq.s	erff_bcl_end	;non,break
	subq.w	#4,sp
	bsr.s	explore_sub_for_FAT	;si,on l'explore
	addq.w	#4,sp
erff_bcl_end
	lea	32(a1),a1		;entr‚e suivante
	dbf	d0,erff_bcl	;hop
	addq.l	#4,sp		;r‚tablit la pile
	move.l	d6,d0		;resultat:nb de clusters
	movem.l	(sp)+,d1-a6
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R‚cupŠre l'ensemble des secteurs d'une entr‚e.
trace_file			;fn(start_cluster.w)
	move.l	d0,-(sp)
	move.w	8(sp),d0
tf_0	move.w	d0,0(a6,d7.w)	;stockage
	add.w	d0,d0		;cluster=>offset (16bits)
	move.w	0(a5,d0.w),d0	;cluster suivant dans	la
	addq.w	#2,d7		;vieille FAT16,on le met dans
	addq.w	#1,d6		;la nouvelle,et index++
	ror.w	#8,d0		;mise au format Motorola
	tst.w	d0		;cluster de fin ?
	bpl.s	tf_0		;non,continue
	ori.w	#$8000,-2(a6,d7.w)	;indique fin de fichier
	move.l	(sp)+,d0
	rts	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Explore un sous-directory (start_clust,new_own,sect_off,new_parent)
;idem root_directory,mais en g‚rant les particularit‚s d'un sub-directory
;(cad:secteurs d'entr‚es non contigus,etc..)
explore_sub_for_FAT
	movem.l	d0-d5/a0-a3,-(sp)
	movem.w	44(sp),d0-d2/d4
	ror.w	#8,d4		;format Intel pour new_parent
	move.w	d1,-(sp)		;empile new_own=new_parent
				;pour la prochaine g‚n‚ration
	move.w	d2,-(sp)		;empile sect_off	
	move.w	d2,d1		;sect_off en d1
esff_bcl0	move.w	d0,d3		;conserve la trace
	add.w	d1,d0		;du cluster actuel
	mulu.w	#512,d0		;(cluster+sect_off)*512
	movea.l	a4,a0		;adresse de secteur du
	adda.l	d0,a0		;sub-directory
	moveq	#15,d0		;16 entr‚es/secteurs
	cmpi.l	#".   ",(a0)	;1ere entr‚e du dir ?
	bne.s	esff_bcl1		;non
	move.w	d4,clust+32(a0)	;mettre new_parent dans ".."
	move.w	2(sp),d4
	ror.w	#8,d4
	move.w	d4,clust(a0)	;mettre new_own dans "."
	lea	64(a0),a0		;si,les 2 premieres sont
	moveq	#13,d0		;inutiles
esff_bcl1
	cmp.b	#$e5,name(a0)	;entr‚e valide ?
	beq.s	esff_bcl1_end
	tst.b	name(a0)
	beq.s	esff_bcl1_end
	move.w	clust(a0),d2
	ror.w	#8,d2		;remet au format Motorola
	ror.w	#8,d6		;mettre au format Intel
	move.w	d6,clust(a0)
	ror.w	#8,d6 		;remettre au format Motorola
	move.w	d6,-(sp)		;empile new_own pour la
	move.w	d2,-(sp)		;r‚curence,puis start_clust
	bsr	trace_file
	addq.l	#4,sp
	btst	#sub_dir,attrib(a0)
	beq.s	esff_bcl1_end
	subq.l	#4,sp
	bsr	explore_sub_for_FAT
	addq.l	#4,sp
esff_bcl1_end
	lea	32(a0),a0		;entr‚e suivante
	dbf	d0,esff_bcl1	;hop
	add.w	d3,d3		;cluster=>offset (16bits)
	move.w	0(a5,d3),d0	;cluster suivant du dir
	ror.w	#8,d0		;Mise au format Motorola
	bpl.s	esff_bcl0		;dernier ? non,suivant
	addq.l	#4,sp		;r‚tablir la pile
	movem.l	(sp)+,d0-d5/a0-a3
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                               ;
;                                               ;
;      Boucle principale de gestion des         ;
;             diff‚rentes options               ;
;                                               ;
;                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
freemem			;renvoie la m‚moire libre.
	movem.l	d1-2/a0,-(sp)
	moveq	#$48,d1
	moveq	#0,d2
	move.l	#"YEAH",-(sp)
fm_0	moveq	#-1,d0
	bsr	Gemdos_go
	tst.l	d0
	ble.s	fm_1
	add.l	d0,d2
	bsr	Gemdos_go
	move.l	d0,-(sp)
	bra.s	fm_0

fm_1	moveq	#$49,d1
	move.l	(sp)+,d0
	cmpi.l	#"YEAH",d0
	beq.s	fm_end
	bsr	Gemdos_go
	bra.s	fm_1

fm_end	move.l	d2,d0
	movem.l	(sp)+,d1-2/a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
out_koctet			;A0:adresse fin chaine.D0:nb_octets.w
	movem.l	d0-1/a0,-(sp)
	lsr.l	#8,d0
	lsr.l	#2,d0		;/1024=>en Ko
	moveq	#4,d1		;sortie de 5 chiffres
pc_bcl	divu	#10,d0
	swap	d0
	addi.b	#"0",d0
	move.b	d0,-(a0)
	clr.w	d0
	swap	d0
	dbf	d1,pc_bcl
	movem.l	(sp)+,d0-1/a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

param_check		;regarde les options,modifie en cons‚quence
			;les messages affich‚es et installe les
			;options si le ram-disque est r‚sident
	movem.l	d0-1/a0-2,-(sp)
	lea	5+o5(pc),a0	;par d‚faut,on
	moveq	#0,d0		;a un disk non r‚sident,
	bsr.s	out_koctet		;donc de 0 Ko
	bsr.s	freemem		;taille m‚moire disponible
	lea	m0+5(pc),a0	;on l'affiche fiŠrement
	bsr.s	out_koctet		;vraoum.
	move.w	options(a6),d0	;r‚cupŠre les options en D0
	tst.b	resident(a6)
	beq.s	pc_1
;si r‚sident...
	move.l	descr_ad(a6),a2
;num‚ro de lecteur ?...
	move.b	#'A',d0
	add.b	(a2),d0
	move.b	d0,indic
;Taille utile maxi du disk ?...
	move.l	8(a2),d0		;taille totale
	lea	5+o5(pc),a0	;adresse de sortie
	bsr	out_koctet		;hop
;regarde l'auto-boot
	move.w	bootdev(a2),$446.w	;par d‚faut,l'ancien bootdev
	move.w	options(a6),d0	;r‚cupŠre les options en D0
	btst	#2,d0		;(ca colle avec en haut,comme
	beq.s	pc_0		;‡a … l'entr‚e de pc_0 D0 contient
	move.b	(a2),$447.w	;les options dans tous les cas)
;afficher les options
pc_0	move.w	options(a6),options(a2)
pc_1	lea	o10(pc),a0
	moveq	#0,d1
pc_bcl1	move.l	#'qNon',otmo(a0)
	btst	d1,d0
	beq.s	pc_bcl1_end
	move.l	#'pOui',otmo(a0)
pc_bcl1_end
	lea	oto(a0),a0
	addq.w	#1,d1
	cmpi.w	#3,d1
	bne.s	pc_bcl1
pc_end	movem.l	(sp)+,d0-1/a0-2
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gere_option		;d0:num‚ro de l'option (2-4)
	movem.l	d0-d1/a0,-(sp)
	subq.w	#2,d0
	move.w	options(a6),d1
	bchg	d0,d1
	move.w	d1,options(a6)
	movem.l	(sp)+,d0-d1/a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
menu_gere	movem.l	d0-a5,-(sp)
__menu	bsr	param_check
	lea	present(pc),a0
	bsr	print
	tst.b	resident(a6)
	beq.s	mg1
	lea	mes1(pc),a0
	bsr	print
mg1	lea	mes2(pc),a0
	bsr	print
mg_bcl2	bsr	BipBip
	bsr	WaitKey
	move.w	d0,d2		;conserve caractŠre
	subi.w	#'0',d2
	bmi.s	mg_bcl2
	cmpi.w	#NB_OPT,d2
	bgt.s	mg_bcl2
	swap	d0		;
	moveq	#2,d1		;sortir le caractere … l'‚cran
	bsr	Gemdos_go
	move.w	d2,d0		;passe le No de fonction en D0
	add.w	d2,d2
	beq.s	mg3			;option 0=Break
	move.w	menu_adresses-2(pc,d2.w),a0	;-2 car option 0 n'est
	jsr	menu_adresses(pc,a0.w)	;dans menu_adresses
	lea	mes5(pc),a0
	bsr	print
	bsr	WaitKey
	bra.s	__menu
mg3	movem.l	(sp)+,d0-a5
	rts

NB_OPT	equ	7	;nombre de choix-1
menu_adresses			;adresses r‚f‚renc‚es par
	dc.w	reorg_disk-menu_adresses	;rapport … menu_adresses
	dc.w	gere_option-menu_adresses	;pour tenir sur 2 octets
	dc.w	gere_option-menu_adresses
	dc.w	gere_option-menu_adresses
	dc.w	kill_disk-menu_adresses
	dc.w	size_disk-menu_adresses
	dc.w	name_disk-menu_adresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                               ;
;                                               ;
;       Boucle principale de gestion de         ;
;         l'installation automatique            ;
;                                               ;
;                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
auto_install
	movem.l	d0-a6,-(sp)
	pea	dta(a6)		;fixe le buffer DTA (‚vite un bug Gemdos)
	move.w	#$1a,-(sp)		;La pile est r‚tablie + tard
	trap	#1		;(au niveau de auto_end)
	lea	mes28(pc),a0	;une 'tit pr‚sentation
	bsr	print
	bsr	dgetdrive		;D0=drive courant
	move.w	d0,sdrive(a6)	;on le stocke

	moveq	#$37,d0		;sous-r‚pertoire inclus
	lea	dum_fname(pc),a0	;adresse de la chose
	bsr	fsfirst		;hop,un p'tit appel,histoire
				;de d‚bloquer le Gemdos
	st	redirige(a6)	;entr‚e redirig‚e
	lea	CmdLine+1(a5),a0	;ouvre le fichier de commandes
	bsr	fopen		;la fonction input d‚tecte
	move.w	d0,redir_h(a6)	;la redirection,et lit le fichier
	bpl.s	auto_0		;dans ce cas au lieu d'appeler
	lea	mes15(pc),a0	;Gemdos(9)=Cconrs.
	bsr	print		;Si pas possible ouvrir le fichier
	bra.s	auto_end		;on se casse

auto_0	bsr	size_disk		;cr‚e le ram-disque (ou le redimmensionne)
	tst.b	resident(a6)	;OK ?
	beq.s	auto_exit		;non,exit
	moveq	#0,d0		;si.Maintenant,r‚cupŠre le drive
	move.l	descr_ad(a6),a0	;du Ram-disque stock‚ dans
	move.b	(a0),d0		;le descripteur r‚sident
	bsr	force_id		;force le Gemdos … reconnaitre
				;le drive...
	move.w	#80,(sp)		;on ne se gŠne pas:80 caract/ligne
auto_bcl	lea	mes21(pc),a0	
	bsr	print		;aller … la ligne
	bsr	input		;input de 80 caractŠres maxi !
	tst.w	d0
	beq.s	auto_exit		;si fin de fichier de commandes
	bmi.s	auto_exit		;atteint,alors break
	bsr	kill_space
	lea	auto_menu(pc),a1
	moveq	#AMENU,d2		;nb de commandes disponibles
autobcl_0	move.l	(a1)+,d0		;mot de commande
	move.w	(a1)+,d1		;adresse relative correspondante
	bsr	str_cmp		;compare avec saisie
	beq.s	autobcl_1		;si ‚gale,alors vas-y
	dbf	d2,autobcl_0	;commande pas identifi‚e,boucle
	bra.s	auto_bcl		;ce n'‚tait pas une commande,
				;on lit une autre ligne
autobcl_1	moveq	#AMENU,d0		;communique le No de l'option
	sub.w	d2,d0		;… partir de d2
	jsr	auto_menu(pc,d1.w)	;executer la commande
	bra.s	auto_bcl


auto_exit	move.w	redir_h(a6),d0
	bsr	fclose
auto_end	addq.l	#6,sp
	lea	mes30(pc),a0
	bsr	print
	bsr	WaitKey
	movem.l	(sp)+,d0-a6
	rts	

AMENU	equ	9		;nombre d'options-1
auto_menu	dc.b	"ddir"
	dc.w	change_ddir-auto_menu
	dc.b	"sdir"		;les adresses sont r‚f‚renc‚es
	dc.w	change_sdir-auto_menu	;sur auto_menu pour n'utiliser
	dc.b	"copy"		;que 2 octets
	dc.w	copy_etendue-auto_menu
	dc.b	"copx"
	dc.w	copy_etendue-auto_menu
	dc.b	"copz"
	dc.w	copy_etendue-auto_menu
	dc.b	"dexg"
	dc.w	exchange_dir-auto_menu
	dc.b	"opt."
	dc.w	read_opt-auto_menu
	dc.b	"n_id"
	dc.w	read_id-auto_menu
	dc.b	"rorg"
	dc.w	reorg_disk-auto_menu
	dc.b	"kill"
	dc.w	auto_kill-auto_menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                               ;
;                                               ;
;             Gestion de fichiers               ;
;                                               ;
;                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dsetpath	move.l	a0,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.l	#2,sp
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dgetpath	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$47,-(sp)
	trap	#1
	addq.l	#8,sp
	movea.l	-6(sp),a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dsetdrive	move.l	a0,-(sp)
	move.w	d0,-(sp)
	move.w	#$0e,-(sp)
	trap	#1
	addq.l	#2,sp
	move.w	(sp)+,d0
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dgetdrive	move.l	a0,-(sp)
	move.w	#$19,-(sp)
	trap	#1
	addq.l	#2,sp
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fopen	move.l	a0,-(sp)
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fclose	move.l	a0,-(sp)
	move.w	d0,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fcreate	move.l	a0,-(sp)
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fsfirst	move.l	a0,-(sp)
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fsnext	move.l	a0,-(sp)
	move.w	#$4f,-(sp)
	trap	#1
	addq.l	#2,sp
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
exchange_dir
	move.w	d0,-(sp)
	move.w	ddrive(a6),d0
	move.w	sdrive(a6),ddrive(a6)
	move.w	d0,sdrive(a6)
	move.w	(sp)+,d0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;change le directory destination (en cr‚ant des dossiers s'ils
;n'existent pas encore).Z=1 si tout va vien
change_ddir
	movem.l	d0-a5,-(sp)	;
	addq.l	#4,a0		;saute le mot de commande
	bsr	kill_space		;=> chemin dans la commande
	lea	ddrive(a6),a4	;drive destination
	moveq	#";",d0		;recherche le commentaire
	bsr	str_chc		;(si y'en a un !)
	bmi.s	cdd_0		;alors ??
	clr.b	0(a0,d0.w)		;y'en a un,on l'expulse
cdd_0	bsr	str_len		;longueur sans commentaires
	movea.l	a0,a1		;
	adda.w	d0,a1		;a1=fin de commande
	movea.l	a0,a2		;
	cmpi.b	#":",1(a2)		;changement de lecteur ?
	bne.s	cdd_bcl1		;non
	addq.l	#3,a2		;si,on garde le premier '\'
cdd_bcl1	cmpi.b	#"\",(a2)+		;cherche tous les s‚parateurs
	bne.s	cdd_1		;c'en est pas un
	clr.b	-1(a2)		;ben si,on saucissone la chaine
cdd_1	cmpa.l	a1,a2		;fin de chaine atteinte ?
	ble.s	cdd_bcl1		;non
cdd_bcl2	bsr.s	in_chg_ddir	;va dans le 1er dossier
	bne.s	cdd_end		;erreur
	bsr	next_str		;partie suivante du chemin
	cmpa.l	a1,a0		;fin de chaine atteinte ?
	blt.s	cdd_bcl2		;non,on boucle
	moveq	#0,d0		;force Z=1
cdd_end	movem.l	(sp)+,d0-a5
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
in_chg_ddir			;En sortie,Z=1 si ok
	bsr.s	change_dir		;changement de dir.
	beq.s	icdd_end		;ok
	move.l	a0,-(sp)		;inexistant,essaye de le cr‚er
	move.w	#$39,-(sp)		;Create Dir
	trap	#1
	addq.l	#2,sp
	movea.l	(sp)+,a0		;reprend A0
	bsr.s	change_dir		;maintenant on ouvre le disque
	beq.s	icdd_end		;ok
	movea.l	a0,a1		;non,pr‚pare le texte d'erreur
	lea	mes18(pc),a0	;le chemin n'existe pas,et on
	bsr	print		;peut pas le creer.
	movea.l	a1,a0
	bsr	print
	moveq	#-1,d0		;force Z=0
icdd_end	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sdir			;En sortie,Z=1 si ok
	movem.l	d0-a5,-(sp)
	addq.l	#4,a0		;saute le mot de commande
	bsr	kill_space		;=> chemin dans la commande
	lea	sdrive(a6),a4	;drive source
	bsr.s	change_dir		;appel de la fonction
	beq.s	csd_end		;Ok ?
	movea.l	a0,a1		;non,pr‚pare le texte d'erreur
	lea	mes18(pc),a0	;le chemin n'existait
	bsr	print		;pas
	movea.l	a1,a0
	bsr	print
	moveq	#-1,d0
csd_end	movem.l	(sp)+,d0-a5
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_dir				;En sortie,Z=1 si ok
	move.w	(a4),d0		;En entr‚e,A4=xdrive(a6)
	bsr	dsetdrive		;on fixe le lecteur
	cmpi.b	#"\",(a0)		;chemin mal-form‚ ??
	bne.s	changed_0		;non
	addq.w	#1,a0		;si,il faut virer le 1er "\"
	bra.s	changed_2		;voil… qui est fait
changed_0	cmpi.b	#":",1(a0)		;changement de disk ? (X:\)
	bne.s	changed_2		;non !
	moveq	#0,d0		;si,on regarde quel est
	move.b	(a0),d0		;le nouveau disque.
	cmpi.b	#"#",d0		;drive DNT-RAM par d‚faut ?
	bne.s	changed_1		;non
	move.l	a0,-(sp)		;si.Pas de test de r‚sidence
	movea.l	descr_ad(a6),a0	;car elle est implicite
	move.b	(a0),d0		;identificateur de DNT-RAM
	addi.b	#"a",d0		;transform‚ en ASCII
	move.l	(sp)+,a0		;reprend la commande
	move.b	d0,(a0)		;mettre le nom du disk
changed_1	ori.w	#$20,d0		;passage en minuscules
	subi.w	#"a",d0		;
	andi.w	#$1f,d0		;‚vite les grosses erreurs
	move.w	d0,(a4)		;yeah !!,change le disk
	bsr	dsetdrive
changed_2	bsr	dsetpath		;fixe le chemin d'accŠs
	tst.l	d0		;erreur ?
	bmi.s	changed_end	;oui,Z=0
	moveq	#0,d0		;Z=1
changed_end
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;effectue le maskage du nom trouv‚ par le Gemdos selon l'ordre de
;l'utilisateur.
pose_mask	movem.l	d0-1/a0-2,-(sp)
	lea	dmask(a6),a2	;mask
	lea	dta+30(a6),a0	;d‚but du nom dta
	lea	13(a0),a1		;fin du nom dta
	bsr	str_len		;longueur du nom trouv‚
	adda.w	d0,a0		;on case le nom trouv‚
pos_msk_0	move.b	-(a0),-(a1)	;… la fin de son buffer
	subq.w	#1,d0		;pour pouvoir le triturer
	bne.s	pos_msk_0		;komonveuh
pos_msk_1	move.b	(a1)+,d0		;nom original
	beq.s	pos_msk_3		;d‚j… la fin (pas d'extension)
	cmpi.b	#".",d0		;on en est au . ?
	beq.s	pos_msk_3		;oui,stoppe
	move.b	(a2)+,d1		;caractŠre du mask
	cmpi.b	#" ",d1		;caractŠre de fin de nom ?
	beq.s	pos_msk_25		;oui,stop
	cmpi.b	#"?",d1		;transparant ?
	beq.s	pos_msk_2		;oui
	move.b	d1,d0		;non,remplacement
pos_msk_2	move.b	d0,(a0)+		;on cr‚e le nom final
	bra.s	pos_msk_1		;et on boucle

pos_msk_25	cmpi.b	#".",d0		;sortie … cause du masque.
	beq.s	pos_msk_3		;pas de malaises...
pos_msk_26	move.b	(a1)+,d0		;faut chercher le point.
	beq.s	pos_msk_3		;si d‚j… fini,arrŠte.
	cmpi.b	#".",d0		;alors,trouv‚ ?
	bne.s	pos_msk_26		;non,suivant.

pos_msk_3	move.b	d0,(a0)+		;hop.Ici,D0=0 OR D0="."
	beq.s	pos_msk_6+2	;ah ben,c'est la fin du nom
pos_msk_35	cmp.b	(a2)+,d0		;prochain caract du masque
	bne.s	pos_msk_35		;‚gal … un point ?.non

pos_msk_4	move.b	(a1)+,d0		;maintenant,c'est l'extension
	beq.s	pos_msk_6		;idem pos_msk_1..
	move.b	(a2)+,d1		;
	cmpi.b	#" ",d1		;
	beq.s	pos_msk_6		;
	cmpi.b	#"?",d1		;
	beq.s	pos_msk_5		;
	move.b	d1,d0		;
pos_msk_5	move.b	d0,(a0)+		;
	bra.s	pos_msk_4		;

pos_msk_6	clr.b	(a0)+		;fin de chaine dans DTA
	movem.l	(sp)+,d0-1/a0-2	;barbatruc.
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
copy_file	movem.l	d0-a5,-(sp)
	suba.l	a1,a1		;adresse blok par d‚faut
	lea	dta+30(a6),a0	;on r‚cupŠre le nom du
	move.w	sdrive(a6),d0	;fichier
	bsr	dsetdrive		;on l'ouvre en source
	moveq	#0,d0		;lecture uniquement
	bsr	fopen		;hop
	move.w	d0,fshandle(a6)	;conserve son handle
	bmi	copyf_err0		;gasp,impossible
	bsr	pose_mask		;pose le masque sur le nom
	move.w	ddrive(a6),d0	;maintenant,on ouvre dest
	bsr	dsetdrive		;hop
	move.b	dta+21(a6),d0	;r‚cupŠre les attributs
	bsr	fcreate		;creer le fichier
	move.w	d0,fdhandle(a6)	;son handle est en D0
	bmi	copyf_err1		;gasp,le Gemdos y veut pas
	moveq	#-1,d0		;demande la maximum de m‚moire
	moveq	#$48,d1		;au Gemdos
	bsr	Gemdos_go		;barbatruc
	move.l	d0,d6		;taille disponible
	ble	copyf_err2		;merdouille,pas de m‚moire !
	bsr	Gemdos_go		;moi vouloir bloc
	movea.l	d0,a1		;moi l'avoir (bounga)
	move.l	dta+26(a6),d7	;taille du fichier.

next_blok	cmp.l	d6,d7		;copie D6 octets,donc on veille
	bge.s	cfnb_0		;… ce que D6 soit plus petit
	move.l	d7,d6		;ou ‚gal … D7 (taille restante)
cfnb_0	move.l	a1,-(sp)		;adresse buffer
	move.l	d6,-(sp)		;taille … lire
	move.w	fshandle(a6),-(sp)	;handle source
	move.w	#$3f,-(sp)		;fread
	trap	#1		;go!
	tst.l	d0		;teste erreur
	bmi.s	copyf_err3		;=>ciel mon mari
	move.w	fdhandle(a6),2(sp)	;handle dest (reste est idem)
	move.w	#$40,(sp)		;fwrite
	trap	#1		;go!
	lea	12(sp),sp		;r‚tablit pile
	tst.l	d0		;teste erreur
	bmi.s	copyf_err4		;=>enfer et damnation
	cmp.l	d0,d6		;on a pu tout ‚crire ?
	bne.s	copyf_err5		;non,break
	sub.l	d6,d7		;D6 octets lu,… enlever … la
	bgt.s	next_blok		;taille restante,jusqu'… 0

copyf_end	move.l	a1,d0
	moveq	#$49,d1		;libŠre la memoire
	bsr	Gemdos_go
	move.w	fshandle(a6),d0
	bsr	fclose		;ferme les fichiers
	move.w	fdhandle(a6),d0	;source et destination
	bsr	fclose
	cmpi.l	#'kill',d6		;le fichier doit etre enlev‚?
	bne.s	copyf_exit		;non!
	pea	dta+30(a6)		;si,on le d‚truit sauvagement
	move.w	#$41,-(sp)		;avec Fdelete.
	trap	#1		;Gloubiboulga
	addq.l	#6,sp		;et hop
copyf_exit	movem.l	(sp)+,d0-a5	;
	rts

copyf_err0	lea	mes22(pc),a0	;les differentes erreurs
cpfe_in	bsr	print		;possibles....
	lea	dta+30(a6),a0
_cpfe_in	bsr	print
	lea	mes21(pc),a0
	bsr	print
	bra.s	copyf_end
copyf_err1	lea	mes23(pc),a0
	bra.s	cpfe_in
copyf_err2	lea	mes24(pc),a0
	bra.s	_cpfe_in
copyf_err3	lea	12(sp),sp		;r‚tablit la pile,cf lieu de l'erreur
	lea	mes25(pc),a0
	bra.s	cpfe_in
copyf_err4	lea	mes26(pc),a0
	bra.s	cpfe_in
copyf_err5	move.l	#'kill',d6		;indique qu'il faut tuer le
	lea	mes29(pc),a0	;fichier destination
	moveq	#65,d0
	add.w	ddrive(a6),d0
	move.b	d0,indic_err-mes29(a0)
	bra.s	cpfe_in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
copy_subdir	;copier un sub-dir.D7=mode (recursif ou non)
	movem.l	d0-5/d7-a5,-(sp)	;D6=nb de fichiers/dossiers
	move.w	sdrive(a6),d0	;fixe le drive,coco
	bsr	dsetdrive		;vas-y ma poule
	moveq	#$7,d0		;tous types de fichiers
	lea	smask(a6),a0	;masque de recherche
	bsr	fsfirst		;recherche...
copsd_bcl0	tst.w	d0		;trouv‚ ?
	bne.s	copsd_1		;non,y'a pas (ou y'a plus)
	addq.w	#1,d6		;si,une entr‚e de plus
	bsr	copy_file		;on effectue la copie
	bsr	fsnext		;prochaine entr‚e du sub-dir
	bra.s	copsd_bcl0		;nouvelle tentative

copsd_1	cmpi.w	#2,d7		;recursivit‚ autoris‚e ?
	beq.s	copsd_end		;non,on saute
	move.w	sdrive(a6),d0	;fixe le drive,coco
	bsr	dsetdrive		;vas-y ma poule
	lea	smask(a6),a0	;masque de recherche
	moveq	#$10,d0		;Moi vouloir sub-dir
	bsr	fsfirst		;Lui cherche (moi feignant...)
	cmpi.w	#4,d7		;copier en gardant le masque ?
	beq.s	copsd_bcl2		;oui
	move.l	#"*.*"*256,(a0)	;non,maintenant tous les fichiers
copsd_bcl2	tst.w	d0		;trouv‚ ?
	bne.s	copsd_end		;non,fini
	btst	#4,dta+21(a6)	;c'est un sub-dir ?
	beq.s	copsd_2		;ben non
	cmpi.w	#"."*256,dta+30(a6)	;primitive No1 du subdir ?
	beq.s	copsd_2		;oui,on la saute (hum..)
	cmpi.w	#"..",dta+30(a6)	;primitive No2 du subdir ?
	beq.s	copsd_2		;idem commentaire
	lea	dta+30-4(a6),a0	;adresse nom_dta-4
	bsr	change_sdir	;(car addq.l #4,a0 au d‚but des
	bne.s	copsd_err		;change_xdir)//Erreur ?
	bsr	change_ddir	;
	bne.s	copsd_err		;erreur ?
	movem.l	dta(a6),d0-5/a0-a4	;sauvegarde la DTA
	addq.w	#1,d6		;une entr‚e de plus...
	bsr	copy_subdir	;on r‚curre un p'tit coup
	bne.s	copsd_end+2	;si prob,inverse la recurrence
	movem.l	d0-5/a0-a4,dta(a6)	;restitue la DTA
	lea	up_dir-4(pc),a0	;on remonte d'un cran dans
	bsr	change_sdir	;les directories
	bsr	change_ddir	;source et destination
copsd_2	bsr	fsnext
	bra.s	copsd_bcl2		;suivant !

copsd_end	moveq	#0,d0		;Z=1,tous va bien
	movem.l	(sp)+,d0-5/d7-a5
	rts

copsd_err	moveq	#-1,d0
	bra.s	copsd_end+2

up_dir	dc.b	"..",$0
	EVEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
copy_etendue		;fonction principale de copie
	movem.l	d0-a5,-(sp)
	lea	sav_source(a6),a0	;on sauvegarde le chemin
	move.w	sdrive(a6),d0	;et le lecteur de destination
	move.w	d0,sav_sdrive(a6)	;\
	move.w	#"A:",(a0)		; \
	add.b	d0,(a0)		;  -merci dgetpath...
	addq.l	#2,a0		; /
	addq.w	#1,d0		;/
	bsr	dgetpath		;on r‚cupŠre skifo
	tst.b	(a0)		;chemin nul (racine,donc) ?
	bne.s	copyet_0		;non,y'a un chemin
	move.w	#"\"*256,(a0)	;si,faut sp‚cifier le cas
copyet_0	lea	sav_dest(a6),a0	;maintenant,idem avec le
	move.w	ddrive(a6),d0	;chemin et le lecteur source
	move.w	d0,sav_ddrive(a6)	;\
	move.w	#"A:",(a0)		; \
	add.b	d0,(a0)		;  -merci dgetpath...
	addq.l	#2,a0		; /
	addq.w	#1,d0		;/
	bsr	dgetpath		;
	tst.b	(a0)		;encore une fois,faut
	bne.s	copyet_1		;regarder si on est …
	move.w	#"\"*256,(a0)	;la racine,et corriger

copyet_1	movea.l	32(sp),a0		;reprend chaine de commande
	bsr.s	traite_copycom	;traitement de la commande
	subq.l	#4,a0		;cf le "addq.l #4,a0" -^
	bsr	change_sdir	;avec A0 du retour...
	bne.s	copyet_end		;gasp,problŠme
	movea.l	a1,a0		;puis A1 du retour...
	subq.l	#4,a0		;cf le "addq.l #4,a0" -^
	bsr	change_ddir	;les chemins sont fix‚s
	bne.s	copyet_end		;re-gasp,re-problŠme

	moveq	#0,d6		;au d‚part,0 fichiers/dossiers
	move.l	(sp),d7		;reprend maintenant le type
	bsr	copy_subdir	;de copie,et execute
	tst.w	d6		;y'a eu des fichiers copi‚s ?
	bne.s	copyet_end		;oui
	lea	mes20(pc),a0	;non,signale l'erreur
	bsr	print		;voil… qui est fait
	lea	smask(a6),a0	;hop-la-boum
	bsr	print
copyet_end
	move.w	sav_ddrive(a6),d0	;Maintenant,on passe … la
	move.w	d0,ddrive(a6)	;restauration des chemins
	lea	sav_dest(a6),a0	;et lecteurs source+dest
	bsr	dsetdrive		;
	bsr	dsetpath		;(veuillez laisser le contexte
	move.w	sav_sdrive(a6),d0	;dans l'‚tat...)
	move.w	d0,sdrive(a6)
	lea	sav_source(a6),a0
	bsr	dsetdrive
	bsr	dsetpath
	movem.l	(sp)+,d0-a5	;finito
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;tripatouillage de la chaine de commande copy/copx pour en extraire la
;substance...En a0,adresse chaine de commande
;en retour A0=adresse chemin source
;          A1=adresse chemin destination
traite_copycom
	move.w	d0,-(sp)
	lea	smask(a6),a1
	moveq	#13*2-1,d0
tccom_clr	clr.b	(a1)+		;efface les chaines de mask
	dbf	d0,tccom_clr	;source et destination
	move.w	(sp)+,d0		;on restaure D0
	bsr.s	extrait_source	;extraire le chemin source
	tst.b	smask(a6)		;y'avait un prototype ?
	bne.s	tccom_0		;oui
	move.l	#"*.*"*256,smask(a6)	;non,prototype par d‚faut
tccom_0	move.l	a1,-(sp)		;conserve le resultat
	bsr	next_str		;partie suivante=destination
	bsr.s	extrait_mask	;
	move.l	(sp),a0		;reprend chemin source.
	bsr	str_len		;taille ?
	tst.w	d0		;nulle=>ok
	beq.s	tccom_1		;pas nulle,faut corriger
	add.w	d0,a0		;le tir (on le fait maintenant
	move.b	#"\",(a0)+		;car tous les masques sont
	clr.b	(a0)+		;extraits,on les abime pas)
tccom_1	move.l	a1,a0		;idem pour le chemin destination
	bsr	str_len		;(sans cette correction,un
	tst.w	d0		;chemin F:\ deviendrait F:
	beq.s	tccom_2		;ce qui n'est pas pareil !!)
	add.w	d0,a0
	move.b	#"\",(a0)+
	clr.b	(a0)+
tccom_2	bsr	mask_format	;PL=ok/MI=bug
	movea.l	(sp)+,a0		;conserve CCR
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;extrait dans une commande de copie le chemin source ainsi
;que le prototype de recherche.
;en A0,chaine de commande
;en A1,adresse chemin source
extrait_source
	movem.l	d0-1/a0/a2,-(sp)
	movea.l	a0,a1		;conserve adresse d‚part
	addq.l	#4,a0		;saute le mot de commande
	bsr	kill_space		;arrive sur le chemin
	bsr	look_space		;va … la fin du chemin
	move.l	a0,-(sp)		;empile la fin du chemin
	movea.l	a1,a0		;reprend d‚but de commande
	lea	smask(a6),a1	;adresse du mask de recherche
	bra.s	exmsk_0+4		;raccordement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;extrait le masque d'une commande de copie,situ‚ aprŠs le copy *.* to
;en A0,chaine de commande
;en retour,A1=adresse chemin destination
extrait_mask
	movem.l	d0-1/a0/a2,-(sp)
	bsr	str_len
	movea.l	a0,a1		;on met en A1 l'adresse
	adda.w	d0,a1		;de fin de commande
	move.l	a1,-(sp)		;on empile...
	exg.l	a0,a1
exmsk_bcl0	move.l	#" to ",d0		;recherche le mot " to "
	bsr	str_cmp		;compare
	beq.s	exmsk_0		;trouv‚,suite
	move.l	#"	to	",d0
	bsr	str_cmp		;idem avec les autres combinaisons
	beq.s	exmsk_0		;(… base de $09='TAB')
	move.l	#"	to ",d0
	bsr	str_cmp
	beq.s	exmsk_0
	move.l	#" to	",d0
	bsr	str_cmp
	beq.s	exmsk_0
	subq.l	#1,a0		;non trouv‚,descend dans
	cmpa.l	a1,a0		;la chaine
	bge.s	exmsk_bcl0		;encore des caractŠres !
	lea	dmask(a6),a1	;plus de caractŠres.Donc
	clr.b	(a1)		;pas de " to ".Pas de mask
	movea.l	(sp)+,a1		;d‚pile a1 (=\0 chemin nul)
exmsk_fin	movem.l	(sp)+,d0-1/a0/a2	;retour
	rts
exmsk_0	lea	dmask(a6),a1
	addq.l	#4,a0		;on se place aprŠs " to "
	bsr	kill_space		;et devant le nom destination
	movea.l	(sp)+,a2		;d‚pile fin de la commande
exmsk_bcl1	cmpi.b	#"\",-(a2)		;caractŠre kifo ?
	beq.s	exmsk_1		;oui! tout va bien
	cmpa.l	a0,a2		;fini ?
	bge.s	exmsk_bcl1		;non,boucle
	movea.l	a2,a0		;pas de chemin=>force A0='\0'
exmsk_1	clr.b	(a2)+		;on se place sur 1er caractŠre
	moveq	#11,d0		;y'en a douze (8+"."+3)
exmsk_bcl2	move.b	(a2)+,d1		;recupŠre caractŠre du mask
	cmpi.b	#" ",d1		;espace ?
	ble.s	exmsk_2		;plus petit,stop
	cmpi.b	#";",d1		;commentaire ?
	beq.s	exmsk_2		;oui,fin aussi
	move.b	d1,(a1)+		;hop,recopie
	dbeq	d0,exmsk_bcl2	;tant que pas '\0'
exmsk_2	clr.b	(a1)		;force fin de chaine
	movea.l	a0,a1		;communique chemin arriv‚e
	movem.l	(sp)+,d0-1/a0/a2
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mask_format	;v‚rifie format mask
		;en sortie PL=tout va bien
		;          MI=gasp,bug
	movem.l	d0-2/a0-2,-(sp)
	lea	dmask(a6),a0	;adresse mask
	bsr	str_len		;sa longueur
	move.w	d0,d1		;sauv‚e en d1
	bne.s	mfmt_0		;longueur nulle?
	lea	default_mask(pc),a1	;oui,chaine par d‚faut
mfmt_01	move.b	(a1)+,(a0)+	;recopier
	bne.s	mfmt_01		;jusqu'… octet nul
	bra.s	mfmt_3		;finito
default_mask
	dc.b	"????????.???",0,0

mfmt_0	moveq	#".",d0		;caractŠre recherch‚
	bsr	str_chc		;on le cherche (logique,non?)
	bmi.s	mfmt_10		;n'existe pas...
	cmpi.w	#9,d0		;situ‚ avant 9Šme caractŠre
	bge.s	mfmt_bad		;non,syntax error
	lea	13(a0),a1		;fin de la chaine mask
	clr.b	-(a1)		;pose le \0 de fin de chaine
	adda.w	d0,a0		;on est sur le point
	bsr	str_len		;longueur extension
	adda.w	d0,a0		;on se place … sa fin
	sub.w	d0,d1		;d(total)-d(.ext)=d(nom)
	move.w	d0,d2		;en D2,taille manquante dans
	subq.w	#4,d2		;l'extension (p.ex ".H" sera
	beq.s	mfmt_bcl1		;transform‚ en ".H  ")
mfmt_bcl0	move.b	#" ",-(a1)		;hop,on comble le manque
	addq.w	#1,d2
	bmi.s	mfmt_bcl0
mfmt_bcl1	move.b	-(a0),-(a1)	;recopie l'extension
	subq.w	#1,d0		;
	bgt.s	mfmt_bcl1		;tant que pas encore la fin...
	subq.w	#8,d1		;maintenant on comble le nom
	bge.s	mfmt_3		;pas la peine
mfmt_bcl2	move.b	#" ",-(a1)		;mais si,on rempli le trou
	addq.w	#1,d1
	bmi.s	mfmt_bcl2		;en sortie,N=0
mfmt_3	movem.l	(sp)+,d0-2/a0-2	;fini (ouf !!)
	rts

mfmt_bad	moveq	#-1,d0		;force N=1
	bra.s	mfmt_3

mfmt_10	cmpi.w	#8,d1		;taille du nom (sans extension ici)
	bgt.s	mfmt_bad		;erreur !!
	lea	13(a0),a1		;fin de chaine mask
	clr.b	-(a1)		;place le \0
	lea	mes3-1(pc),a0	;adresse point (ici avant mes3)
	moveq	#-1,d0		;un caractŠre (le point!)
	moveq	#-3,d2		;3 cases … remplir
	bra.s	mfmt_bcl0		;on se raccorde.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;routine … premiŠre vue stupide.Or il s'avŠre que le Gemdos a des
;problŠmes parfois..Cf le fichier d'explication DNT_RAM.EXP
;routine appel‚e lors de la cr‚ation d'un identificateur de disque
force_id	movem.l	d0/a0,-(sp)
	tst.b	resident(a6)	;disque pr‚sent (normal=oui)
	beq.s	fid_0		;non (ne devrait pas se produire)
	move.l	descr_ad(a6),a0	;Le disque change de nom (ou
	move.w	#2,media_ch(a0)	;apparait)=>media_ch=OUI
fid_0	move.w	d0,ddrive(a6)	;stocke drive destination
	bsr	dsetdrive		;on l'active puis 
	lea	saisie(a6),a0	;on fixe le chemin sur le
	move.l	#"A:\"*256,(a0)	;root-directory
	add.b	d0,(a0)		;selon le drive bien entendu
	bsr	dsetpath		;et hop,magik
	moveq	#$37,d0		;sous-r‚pertoire inclus
	lea	dum_fname(pc),a0	;Encore un appel d‚lirant,
	bsr	fsfirst		;… nouveau pour d‚bloquer
	movem.l	(sp)+,d0/a0	;le Gemdos.
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
read_id	movem.l	d0-2/a0,-(sp)
	tst.b	resident(a6)	;disque r‚sident ?
	beq.s	readid_end		;non,cassos
	addq.l	#4,a0		;on se place aprŠs la commande
	bsr	kill_space		;sur l'identificateur
	moveq	#0,d0		;...
	move.b	(a0)+,d0		;on le lit
	ori.w	#$20,d0		;passe en minuscules
	subi.w	#"a",d0		;formate en [0..25]
	bmi.s	readid_err		;non valable
	cmpi.w	#25,d0		;trop grand ?
	bgt.s	readid_err		;oui !
	move.l	descr_ad(a6),a0	;prend le descripteur
	move.b	(a0),d2		;et l'id actuel
	cmp.b	d2,d0		;c'est le meme ?
	beq.s	readid_end		;oui,cassos
	move.l	$4c2.w,d1		;non,on commence par valider
	bset	d0,d1		;le nouvel identificateur
	bclr	d2,d1		;puis on efface l'ancien
	move.b	d0,(a0)		;Pr‚viens les autres du changement
	move.l	d1,$4c2.w		;..y compris le TOS !!
	bsr	force_id		;d‚bloque le Gemdos
readid_end	movem.l	(sp)+,d0-2/a0	;
	rts

readid_err	lea	mes19(pc),a0
	bsr	print
	bra.s	readid_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
read_opt	movem.l	d0-1/a0,-(sp)
	addq.l	#4,a0
	moveq	#0,d0
reado_bcl	bsr.s	kill_space
	move.b	(a0)+,d0
	beq.s	reado_end
	cmpi.b	#";",d0
	beq.s	reado_end
	subi.b	#"0",d0
	bmi.s	reado_err
	cmpi.b	#2,d0
	bgt.s	reado_err
	move.w	options(a6),d1
	bset	d0,d1
	cmpi.b	#"-",(a0)+
	bne.s	reado_0
	bclr	d0,d1
reado_0	move.w	d1,options(a6)
	bra.s	reado_bcl
reado_end	bsr	param_check	;la partie raffraichissement des
	movem.l	(sp)+,d0-1/a0	;messages de param_check,on s'en
	rts			;fout.Elle sert uniquement …
				;installer les options
reado_err	lea	mes27(pc),a0
	bsr	print
	bra.s	reado_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
auto_kill	bsr	kill_disk		;destruction du ram-disk
	tst.b	resident(a6)	;destruction accomplie ?
	bne.s	akill_end		;non,on continue
	addq.l	#4,sp		;d‚pile la boucle
	pea	auto_exit(pc)	;empile le break
akill_end	rts			;sortie du programme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
kill_space
	move.w	d0,-(sp)
ksp_bcl	move.b	(a0)+,d0
	beq.s	kps_end
	cmpi.b	#" ",d0
	beq.s	ksp_bcl
	cmpi.b	#9,d0
	beq.s	ksp_bcl
	cmpi.b	#",",d0
	beq.s	ksp_bcl
kps_end	move.w	(sp)+,d0
	subq.l	#1,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
look_space	move.w	d0,-(sp)
lsp_bcl	move.b	(a0)+,d0
	beq.s	kps_end
	cmpi.b	#" ",d0
	beq.s	kps_end
	cmpi.b	#9,d0
	beq.s	kps_end
	cmpi.b	#",",d0
	beq.s	kps_end
	bra.s	lsp_bcl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
next_str			;se placer sur prochaine chaine non nulle
	tst.b	(a0)+	;
	bne.s	next_str	;cherche fin chaine actuelle
	rts		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;cherche un caractŠre.D0=   -1     + MI si pas trouv‚
;                        [0..7FFF] + PL si trouv‚
str_chc	movem.l	a0/d1,-(sp)
	moveq	#-1,d1		;compteur
schc_bcl	addq.w	#1,d1		;un caractŠre de plus
	tst.b	(a0)		;fin de chaine ?
	beq.s	schc_non		;oui
	cmp.b	(a0)+,d0		;caractŠre trouv‚ ?
	bne.s	schc_bcl		;non,continue
schc_fin	move.w	d1,d0		;r‚cupŠre le compteur
	movem.l	(sp)+,a0/d1	;et test positivit‚
	rts
schc_non	moveq	#-1,d1		;test n‚gativit‚
	bra.s	schc_fin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
str_len	move.l	a0,-(sp)
	moveq	#-1,d0
strlen_bcl	tst.b	(a0)+
	dbeq	d0,strlen_bcl
	neg.w	d0
	subq.w	#1,d0
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
str_cmp	move.l	d0,-(sp)
	cmp.b	3(a0),d0
	bne.s	strcmp_end
	lsr.w	#8,d0
	cmp.b	2(a0),d0
	bne.s	strcmp_end
	swap	d0
	cmp.b	1(a0),d0
	bne.s	strcmp_end
	lsr.w	#8,d0
	cmp.b	(a0),d0
strcmp_end	movem.l	(sp)+,d0		;movem conserve le CCR
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#2,sp
	movea.l	(sp)+,a0
	move.l	(sp)+,d0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WaitKey	move.l	a0,-(sp)		;renvoie code touche en D0
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BipBip	movem.l	d0/a0,-(sp)
	move.l	#$20007,-(sp)
	trap	#1
	addq.l	#4,sp
	movem.l	(sp)+,d0/a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
input			;(D0,A0)=input(max_car.w)
	lea	saisie(a6),a0
	tst.b	redirige(a6)	;sortie redirig‚e ?
	bne.s	input2		;oui,va lire le fichier
input1	moveq	#0,d0		;input classique avec Cconrs
	move.b	5(sp),(a0)
	beq.s	input_end
	move.l	a0,-(sp)
	move.w	#$0a,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	saisie+1(a6),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	clr.b	0(a0,d0.w)
input_end	rts

input2	movem.l	d1-2/a1,-(sp)	;input redirig‚ sur un fichier
	movea.l	a0,a1
	moveq	#0,d2
	move.b	5+12(sp),d2	;nombre maxi de caractŠres
	move.b	d2,(a1)+		;stock‚ dans saisie (comme
	moveq	#-1,d1		;‡a pas besoin de le faire
	moveq	#1,d0		;soit meme,idem input1)
inp2_bcl	addq.l	#1,a1		;un caractŠre de plus,
	addq.l	#1,d1		;… charger un octet plus
	cmp.w	d2,d1		;loin.Nb maxi de caractŠres ?
	bge.s	inp2_end		;oui,stoppe
inp2_0	move.l	a1,-(sp)		;empile adresse o— est charg‚
	move.l	d0,-(sp)		;le caractŠre,le nombre d'octets
	move.w	redir_h(a6),-(sp)	;(ici D0=1),le handle,
	move.w	#$3f,-(sp)		;et Fread
	trap	#1		;go!
	lea	12(sp),sp		;r‚tablir la pile
	cmpi.b	#$d,(a1)		;RETURN ??
	beq.s	inp2_end		;oui,alors fini!
	tst.l	d0		;un caractŠre a ‚t‚ charg‚ ??
	beq.s	inp2_end		;non,D0=0 donc fini
	bmi.s	inp2_err		;    D0<0 erreur de lecture
	cmpi.b	#$a,(a1)		;flŠche bas (fin de ligne ASCII=$0D0A)
	beq.s	inp2_0		;oui,alors ignore
	bra.s	inp2_bcl		;non,un caractŠre de plus

inp2_end	move.b	#$d,(a1)+		;return
	clr.b	(a1)		;fin de chaine pour print
	lea	saisie+1(a6),a0	;r‚cupŠre adresse chaine
	move.l	d1,d0		;puis nb de caractŠres charg‚s
	move.b	d0,(a0)+		;que l'on stocke
	bsr	print		;affiche la chaine
	clr.b	-(a1)		;fin de chaine pour fn appelante
	movem.l	(sp)+,d1-2/a1	;(Cconrs oublie Return)//finito
	rts
inp2_err	lea	mes16(pc),a0
	bsr	print
	bra.s	inp2_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                               ;
;                                               ;
;         Driver du disque virtuel              ;
;                                               ;
;                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
my_bpb	dc.l	"XBRA"
	dc.l	"DNTR"
	dc.l	0
_my_bpb	move.w	4(sp),d0	;~~Getbpb(dev%)~~
	cmp.b	my_bpb-varsize*4(pc),d0	;est-ce notre
	beq.s	bpb1			;lecteur … nous ?
	move.l	_my_bpb-4(pc),a0		;non,goto routine
	jmp	(a0)			;systeme
bpb1	lea	my_bpb-varsize*4+bpbtab(pc),a0	;si,on renvoie l'
	move.l	a0,d0			;adresse de notre
	rts				;BPB … nous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	dc.l	"XBRA"
	dc.l	"DNTR"
	dc.l	0
my_rw	move.w	14(sp),d0	;~~Rwabs(rw%,L:buffer%,nb%,sect%,dev%)~~
	cmp.b	my_bpb-varsize*4(pc),d0 ;notre lecteur ?
	beq.s	rw1		;oui,vas-y L‚on
	move.l	my_rw-4(pc),a0	;non,routine systŠme
	jmp	(a0)
rw1	moveq.l	#0,d0
	move.w	12(sp),d0		;r‚cupŠre le num‚ro du 1er
	lsl.l	#8,d0		;secteur,*512 pour accŠs en
	add.l	d0,d0		;m‚moire
	move.l	6(sp),a0		;r‚cupŠre adresse du transfert
	move.w	10(sp),d1		;et le nombre de secteurs
	subq.w	#1,d1		;-1 pour le dbf
	bmi.s	rw_end		;au cas o—...
	move.l	my_bpb-varsize*4+4(pc),a1	;adresse ramdisk
	add.l	d0,a1		;+offset du secteur
	move.w	a0,d0
	add.w	d0,d0		;stocke A0.bit0 en D0.bit1
	or.w	4(sp),d0		;r‚cupŠre R/W.bit0
	lsr.w	#1,d0		;si R/W=0
	bcc.s	rw2		;alors lecture
	exg	a0,a1		;si non,inverse source
rw2	lsr.w	#1,d0		;adresse paire ?
	bcc.s	rw5		;oui
rw3	moveq.l	#127,d0		;non,aie.
rw4	move.b	(a1)+,(a0)+	;transfert octet par octet
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	dbf	d0,rw4
	dbf	d1,rw3
rw_end	moveq.l	#0,d0
	rts
rw5	moveq.l	#31,d0		;l'adresse est paire,on y
rw6	move.l	(a1)+,(a0)+	;va par 4 mots-longs
	move.l	(a1)+,(a0)+	;… la fois
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d0,rw6
	dbf	d1,rw5
	bra.s	rw_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	dc.l	"XBRA"
	dc.l	"DNTR"
	dc.l	0
my_ch	move.w	4(sp),d0
	lea	my_bpb-varsize*4(pc),a0
	cmp.b	(a0),d0
	beq.s	ch1
	move.l	my_ch-4(pc),a0
	jmp	(a0)
ch1	moveq.l	#0,d0		;Le ch est un mot-long !
	move.w	media_ch(a0),d0	;on le r‚cupŠre
	clr.w	media_ch(a0)	;annule un ‚ventuel changement
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;routine pr‚c‚d‚e en m‚moire par 8 octets (chainage reset)
my_reset	dc.l	0,0		;espace de chainage reset
	clr.l	$5a0.w		;plus de cookie jar (TOS 1.2)
	move.l	my_reset(pc),$426.w	;routine reset suivante
	move.l	my_reset+4(pc),$42a.w	;voil… qui est fait
	jmp	(a6)		;retour au systŠme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Routine bootsoft.Elle r‚installe et re-protŠge le Ram-disque.Il n'est
;pas ecras‚ au Reset,mais le TOS,en s'initialisant,enlŠve la r‚servation
;m‚moire et d‚sactive les routines de gestion.
my_boot	bra.s	*+4
	dc.w	0		;checksum pour soft-boot
	lea	mb_vars(pc),a5	;zone de variables.
	movea.l	(a5)+,a6		;adresse descripteur
	lea	cookie_jar(a6),a2	;adresse de notre jar
	cmpa.l	$5a0.w,a2		;Notre jar d‚j… l… ?
	beq.s	mb3		;oui,arrŠte (prob TOS<1.6)
	bsr	my_cook		;compte les cookies
	blt.s	mb2		;y'a de la place...
	cmpi.w	#40,d0		;non,mais taille du jar ??
	blt.s	mb0		;ouf,on est plus gros
	lea	warning(pc),a0	;gasp,pas de d‚claration
	move.l	a0,d0		;on pr‚vient
	moveq	#9,d1		;l'utilisateur
	bsr	Gemdos_go		;de l'etat des choses.
	bra.s	mb3

				;pas de place=>mettre notre jar
mb0	moveq	#40,d0		;cookie_jar de 40 de long
	move.l	$5a0.w,d1		;prendre l'ancien
	move.l	a2,$5a0.w		;hop,installe le notre
	move.l	a2,a0		;on travaille sur A0
	tst.l	d1		;y'avait un cookie-jar ?
	beq.s	mb1_5		;non,pas de recopie
	movea.l	d1,a1		;
mb1	move.l	(a1)+,(a0)+	;recopie l'ancien cookie-jar
	beq.s	mb2		;dans le nouveau
	move.l	(a1)+,(a0)+	;
	bra.s	mb1		;

mb1_5	addq.l	#4,a0
mb2	move.l	#'DNTR',-4(a0)	;installe notre cookie
	move.l	a6,(a0)+		;
	clr.l	(a0)+		;
	move.l	d0,(a0)		;

mb3	lea	$472.w,a1		;
	move.l	(a5)+,a2		;effectuer le chainage
	move.l	(a1),-4(a2)	;XBRA des routines hdv_xxx
	move.l	a2,(a1)+		;
	move.l	(a5)+,a2		;
	move.l	(a1),-4(a2)	;
	move.l	a2,(a1)+		;
	move.l	(a5)+,a2		;
	addq.l	#4,a1		;pour aller sur hdv_mediach
	move.l	(a1),-4(a2)	;
	move.l	a2,(a1)		;

	movea.l	(a5),a5		;adresse de notre reset-8
	move.l	$426.w,(a5)+	;chainage des routines reset
	move.l	$42a.w,(a5)+	;meme en soft-boot.
	move.l	#$31415926,$426.w	;le magic-reset
	move.l	a5,$42a.w		;notre reset
	move.l	$4c2.w,d0		;force l'existence du
	move.l	(a6),d2		;lecteur dans _drvbits
	rol.l	#8,d2		;r‚cupŠre les 8 bits forts
	bset.l	d2,d0		;fixe le lecteur
	move.l	d0,$4c2.w		;

	clr.l	-(sp)		;flag de fin de pile
	st	(sp)		;(adresse n‚gative)
	lsr.l	#8,d2		;r‚cupŠre la taille de DNT-RAM
	moveq	#-1,d4		;flag "non trouv‚" (d4<0)
mb4	moveq	#-1,d0		;demande le + grand bloc au
	moveq	#$48,d1		;Malloc
	bsr	Gemdos_go		;Puis on note sa taille
	move.l	d0,d3		;si nul,fin !
	ble.s	mb5		;si n‚gatif aussi
	bsr	Gemdos_go		;on le r‚serve et on
	move.l	d0,-(sp)		;note son adresse.
	sub.l	d2,d3		;notre bloc tient dedans ?
	bmi.s	mb4		;non=>suivant
	sub.l	a6,d0		;notre bloc peut-il etre ici?
	bgt.s	mb4		;non=>il est moins haut
	add.l	d0,d3		;et il ne d‚passe pas ?
	bmi.s	mb4		;si (erreur,mais on continue)
	move.l	d0,d4		;noter la taille dummy.
	neg.l	d4		;(neg bicoze D0 est l'inverse!)
	movea.l	(sp)+,a1		;retire l'adresse de la liste.
	bra.s	mb4		;continuer les reservations.

mb_err	lea	critical(pc),a1	;en cas d'erreur,averti l'
	bra.s	mb10		;utilisateur et break.

mb5	tst.l	d4		;a-t-on trouv‚ le bloc ?
	bmi.s	mb_err		;aie,non! lib‚ration directe
	move.l	a1,d0		;bloc Gemdos qui nous contient
	moveq	#$49,d1		;Mfree
	bsr.s	Gemdos_go		;libŠre la partie concern‚e.
	movea.l	4(a6),a0		;sauvegarde dans boot-sector
	bsr.s	swap_BIOS		;save les paramŠtres du BIOS
	move.l	d4,d0		;Reserve le dummy (taille
	moveq	#$48,d1		;trouv‚e plus haut pendant la
	bsr.s	Gemdos_go		;recherche du bloc)
	exg.l	d0,d2		;D0=taille d‚finitif/D2=dummy
	bsr.s	Gemdos_go		;On le reserve
	move.l	d2,d0
	moveq	#$49,d1		;Mfree
	bsr.s	Gemdos_go		;libŠre le dummy
	movea.l	4(a6),a0		;adresse du boot-sector
	bsr.s	swap_BIOS		;restitution du BIOS

mb7	move.w	options(a6),d7	;
	lsr.w	#1,d7		;option 60Hz ?
	bcc.s	mb8		;non,saute
	bclr	#1,$ffff820a.w	;si,change la fr‚quence
mb8	lsr.w	#1,d7		;option HORLoge ?
	bcc.s	mb9		;non,saute
	move.w	#23,-(sp)		;
	trap	#14		;heure XBIOS
	addq.l	#2,sp		;D0=date.w|time.w
	move.w	d0,d2		;D2=time.w (Gemdos d‚truit D0)
	moveq	#$2b,d1		;TSETDATE
	bsr.s	Gemdos_go		;appel GEMDOS
	move.w	d2,d0		;reprend time.w
	swap	d0		;D0=time.w|????.w
	moveq	#$2d,d1		;TSETTIME
	bsr.s	Gemdos_go		;appel GEMDOS

mb9	lea	message(pc),a1	;pr‚pare l'affichage
mb10	moveq	#$49,d1		;Mfree
	move.l	(sp)+,d0		;d‚pile les adresses de bloc
	bmi.s	mb11		;fin de chaine ?
	bsr.s	Gemdos_go		;liberer bloc
	bra.s	mb10		;suivant
mb11	move.l	a1,d0		;affiche le message
	moveq	#$9,d1		;Cconws
	
Gemdos_go	move.l	d0,-(sp)		;empile le parametre (.L)
	move.w	d1,-(sp)		;et le No de fonction Gemdos.
	trap	#1		;Si le paramŠtre est .W,il doit
	addq.l	#6,sp		;etre dans le mot haut de D0
	rts			;processus achev‚
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Cr‚e une page de base fictive dans la zone des vecteurs du BIOS (zone
;officielle,donc stable) aprŠs sauvegarde des vecteurs.AUCUN ACCES
;I/O NE DOIT ETRE TENTE PENDANT LA PERIODE OU LES VECTEURS SONT
;DETRUIT !!!!
swap_BIOS				;En A0,adresse de sauvegarde
	movem.l	d0-1/a0-2,-(sp)	;Cette zone doit faire 134 octets
	lea	$51e.w,a1		;adresse des vecteurs bios
	movea.l	a1,a2		;doubl‚e en a2
	moveq	#31,d0		;32 mots long
swapb_bcl	move.l	(a0),d1		;procŠde … la sauvegarde par ‚change
	move.l	(a1),(a0)+		;des donn‚es (=>une routine pour 2
	move.l	d1,(a1)+		;sens)
	dbf	d0,swapb_bcl	;
	movea.l	$4f2.w,a1		;
	cmpi.w	#$0100,2(a1)	;TOS 1.0 ?
	movea.l	40(a1),a1		;adresse du _run (CCR intact)
	bne.s	swapb_ok		;TOS >1.0,ca baigne
	lea	$602c.w,a1		;non,adresse _run TOS 1.0
swapb_ok	cmpa.l	(a1),a2		;fausse base_page d‚j… activ‚e?
	beq.s	swapb_0		;oui
	move.l	(a1),(a0)+		;non,on sauvegarde la vraie
	move.w	sr,(a0)+		;ainsi que le SR
	move.w	#$2700,sr		;IPL7,controle total du systŠme
	move.l	a2,(a1)		;et on active la fausse
swapb_end	movem.l	(sp)+,d0-1/a0-2	;
	rts			;

swapb_0	move.l	(a0)+,(a1)		;remet la vraie page de base
	move.w	(a0)+,sr		;repasse … l'ancien SR
	bra.s	swapb_end		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Compte les cookies et renvoie A0=NULL_cookie+4.
my_cook	move.l	$5a0.w,d0		;compte les cookies pr‚sents
	beq.s	my_cook_end	;si pas de jar..
	movea.l	d0,a0		;prendre adresse
	moveq	#0,d0		;efface d0
my_cook0	addq.w	#1,d0		;un cookie de plus
	tst.l	(a0)+		;NULL-cookie ?
	beq.s	my_cook1		;oui
	addq.l	#4,a0		;non,au suivant
	bra.s	my_cook0		;hop
my_cook1	cmp.l	(a0),d0		;Et voil…,on obtient le nb
				;de cookies + le CCR.
	movem.l	(a0),d0		;et revoie taille du jar.
my_cook_end			;CCR={GE}=(inexistant/plein)
	rts			;   ={LT}=(A0=NULL_cookie+4
				;          D0=taille jar   )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mb_vars	dc.l	0,0,0,0,0,0	;diff‚rents pointeurs
message	dc.b	27,'E'
	dc.b	'~-~ ',27,'pDNT-RAM '
	dc.l	REL_TXT
	dc.b	' r‚sident!',27,'q ~-~',$d,$a,7,$0
critical	dc.b	27,'E',27,'pDNT-RAM EN ECHEC!!',27,'q',7,$0
warning	dc.b	27,'E',27,'pDNT-RAM absent du cookie-jar!!',27,'q',7,$0
	EVEN
my_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	DATA
present	dc.b	27,'E',$a,$d
	dc.b	9,9,"  +-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-+",$a,$d
	dc.b	9,9,"  |            ",27,"p ",$e8," DNT-RAM ",$e8,$20,27,"q            |",$d,$a
	dc.b	9,9,"  |",9,9,9,9,9,"| ",$a,$d
	dc.b	9,9,"  |      RAM-DISQUE r‚sident  "
	dc.l	REL_TXT
	dc.b	"      |",$a,$d
	dc.b	9,9,"  |",9,9,9,9,9,"|",$a,$d
	dc.b	9,9,"  |        ",27,"p ",$be," Nullos//DNT",$bf," 1991 ",27,"q        |",$d,$a
	dc.b	9,9,"  +-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-+",$a,$d
	dc.b	$a,$a,$d,$0
mes1	dc.b	27,"pDNT-RAM est r‚sident,le ram-disque ayant comme identificateur " 
indic	dc.b	"D:",27,'q ',$0a,$0d,$0
mes2	dc.b	"0)STOP",$d,$d,$a,$d
	dc.b	"1)R‚organisation du disque virtuel ",$a,$d
o10	dc.b	"2)Passage en 60Hz au boot : ",27
o11	dc.b	"pNon",27,'q ',$a,$d
o2	dc.b	"3)Sauvegarde de l'Horloge : ",27,"pNon",27,'q ',$a,$d
o3	dc.b	"4)Booter sur le Ram-disque: ",27,"pNon",27,'q ',$a,$d
	dc.b	"5)D‚sactiver le disk",$a,$d
o4	dc.b	"6)Taille du disque virtuel:",27,'p'
o5	dc.b	"00000",27,"qKo <=> M‚moire libre:"
m0	dc.b	"00000Ko",$a,$d
	dc.b	"7)Choix de l'identifiateur du ram-disque",$d,$a
	dc.b	"Votre choix :..",$0
oto	equ	o2-o10		;..entre deux options
otmo	equ	o11-o10		;..vers le message Oui/Non


mes3	dc.b	$a,$d,"Taille d‚sir‚e (en K-octets) ?: ",$0
mes4	dc.b	$a,$d,27,"pIl restera moins de 32Ko de libre pour le TOS et les applications",27,"q aprŠs l'"
	dc.b	$d,$a,"installation d'un ram-disque de cette taille.Confirmez votre choix (O/N):",$0
mes5	dc.b	$d,$a,"Pressez une touche SVP...",$0
mes6	dc.b	$a,$d,"Installation r‚ussie !",$0
mes7	dc.b	$a,$d,"Pas de lecteur libre !!!.C'est trŠs fort...",$0
mes8	dc.b	$a,$d,"Argh,les donn‚es du disque sont plus grande que cette taille !!!",$0
mes9	dc.b	$a,$d,"M‚moire insuffisante et/ou morcel‚e,impossible de cr‚er/agrandir le ram-disque.",$0
mes10	dc.b	$d,$a,"Trop de programme r‚sidents install‚s en meme temps.",$0
mes11	dc.b	$a,$d,"M‚moire insuffisante pour r‚organiser le disk.",$0
mes12	dc.b	$a,$d,27,"pAttention,toutes les donn‚es du disque vont etre perdues !!",27,'q',$a,$d
	dc.b	"Confirmez ce choix SVP (O/N): ",$0
mes13	dc.b	"DNT-RAM est pr‚sent en m‚moire,mais son num‚ro de version n'est pas compatible",$a,$d
	dc.b	"avec le pr‚sent programme !!",$0
mes31	dc.b	$d,$a,$a,"Liste des identificateurs occup‚s:",27,"p",$d,$a,$0
mes32	dc.b	27,"q",$d,$a,"Quel identificateur utiliser ['*'=DNT-RAM actuel] ?",$0

mes15	dc.b	$a,$d,"Impossible d'ouvrir le fichier de commandes indiqu‚ !!",$a,$d,$0
mes16	dc.b	$d,$a,"Fichier de commandes illisible !!",$d,$a,$0
mes18	dc.b	$d,$a,"Impossible d'ouvrir le dossier : ",$0
mes20	dc.b	$d,$a,"Le fichier suivant n'existe pas :",$0
mes21	dc.b	$a,$d,$0
mes22	dc.b	"Impossible d'ouvrir le fichier source :",$0
mes23	dc.b	"Impossible d'ouvrir le fichier destination :",$0
mes24	dc.b	"Pas de m‚moire disponible pour copier les fichiers !!",$a,$d,$0
mes25	dc.b	"Impossible de lire le fichier source :",$0
mes26	dc.b	"Impossible d'‚crire dans le fichier destination :",$0
mes27	dc.b	$d,$a,"Option inexistante ou erreur de syntaxe !",$0
mes28	dc.b	27,"E",9,9,9,9,27,"p ",$e8," DNT-RAM ",$e8,$20,$a,$d
	dc.b	"Auto-installation",27,"q",$d,$a,$0
mes29	dc.b	"Le disque "
indic_err	dc.b	"D: est trop petit pour le fichier :",$0
mes30	dc.b	"Installation termin‚e...",$a,$d,$0
mes19	dc.b	$d,$a,"Erreur de syntaxe:identificateur incorrect.",$0
dum_fname	dc.b	"ZOBYLAMO.UCH",$0
;^----Si vous avez un fichier portant ce nom,‚crivez moi !!!-----^
	EVEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	BSS
	RSRESET
;GARDER CET ORDRE DE DECLARATION (des optimisations en d‚pendent !!)
;[cad ram_descr en premier,options-bootdev r‚unis]
;[Mais vaut mieux faire les rajouts en fin,aprŠs bpbtab pour ne pas gener]
ram_descr	rs.l	3	;info RAM: (identif.b|taille totale.bw).l
			;          (adresse ramdisk).l
			;          (taille utile ramdisk).l
options	rs.w	1	;[...Boot,Horloge,60Hz]
version	rs.w	1	;No de version $xxyy (Vxx.yy)
bootdev	rs.w	1	;ancien lecteur de boot
cookie_jar	rs.l	40*2	;cookie-jar maison
media_ch	rs.w	1	;le m‚dia-change du disque virtuel
bpbtab	rs.l	5	;le tableau de get_bpb
varsize	equ	90	;Taille totale
DESCRIPT	ds.l	varsize	;variables du RAM-disk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dv_bpb	equ	varsize*4+12	;routines par rapport
dv_rw	equ	dv_bpb+my_rw-_my_bpb	;au descripteur.+12 … cause du
dv_ch	equ	dv_bpb+my_ch-_my_bpb	;chunck {XBRA/DNTR/old_vec.l}
dv_reset	equ	dv_bpb+my_reset-_my_bpb ;ici,pointe les 2 longs de
				;chainage reset.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	RSRESET
ram_size	rs.l	1	;"double" des donn‚es du descripteur
disk_size	rs.l	1	;de disk,plus quelques extras
save_SSP	rs.l	1
_options	rs.w	1	;nom inutilis‚,car _options=options=12
FAT_size	rs.w	1
redirige	rs.b	1
resident	rs.b	1	;  $00=OUI  // $FF=NON  \  RESPECTER
descr_ad	rs.l	1	; <>$000000 // =$000000 /     CA!
util_size	rs.l	1
saisie	rs.b	82
save_BIOS	rs.b	134	;buffer de sauvegarde du BIOS
redir_h	rs.w	1
fshandle	rs.w	1	;pour les copies de fichier...
fdhandle	rs.w	1	;le handle de redirection du clavier
sdrive	rs.w	1	;ceux pour la copie proprement dite,
ddrive	rs.w	1	;et les indicateurs de disk source et
dta	rs.l	11	;arriv‚e.Et un buffer de DTA
sav_source	rs.b	264
sav_dest	rs.b	264
sav_sdrive	rs.w	1
sav_ddrive	rs.w	1
smask	rs.b	13
dmask	rs.b	13
jar_inst	rs.b	1

param_size	equ	214
PARAM	ds.l	param_size

