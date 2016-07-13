MSG_TEXT	equ	1
SP_LENGHT	equ	8192
;	include "start_up.s"
;***************************************************************
;START_UP.S
	bra	__ZEU
	dc.b	" Megar/BINARIS. "
 	dc.b	" To contact me: "
 	dc.b	"----------------"
 	dc.b	"BOUTHENOT Gilles"
 	dc.b	"   8 rue des    "
 	dc.b	"    Murgers     "
 	dc.b	" 25350 MANDEURE "
 	dc.b	"     FRANCE     "
 	dc.b	"----------------"
 	dc.b	"Tel: 81 35 61 47"
 	dc.b	"----------------"
 	dc.b	" Minitel:  3615 "
 	dc.b	" RTEL BAL MEGAR "
 	dc.b	"----------------"
__ZEU:	movea.l	4(sp),a0	;basepage
	lea.l	BASEPAGE_ADR(pc),a1
	move.l	a0,(a1)
	move.l	$c(a0),d0	;text
	add.l	$14(a0),d0	;+data
	add.l	$1c(a0),d0	;+bss
 IFD SP_LENGHT
	addi.l	#256+SP_LENGHT,d0	;+pile
 ELSE
	addi.l	#512,d0
 ENDC
	bclr	#0,d0		;pair !
	lea.l	0(a0,d0.l),sp
	move.l	d0,-(sp)
	pea	(a0)
	clr.w	-(sp)
	
	move.l	$1c(a0),d0	;d0= Bss Lenght
	move.l	$18(a0),a0	;a0= Bss
	lea.l	0(a0,d0.l),a1	;a1= Fin Bss
	lsr.l	#5,d0		;divise par 32
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d7,a2
.cl:	movem.l	d1-d7/a2,(a0)
	lea.l	8*4(a0),a0
	dbf	d0,.cl
.cl2:	cmp.l	a1,a0
	bge.s	.ok
	move.b	d1,(a0)+
	bra.s	.cl2
.ok:	
	move.w	#$4a,-(sp)
	trap	#1
	lea.l	12(sp),sp

	jmp	MAIN

BASEPAGE_ADR:
	ds.l	1

;*******************************************************************
;INCLUDE "FILE.S"
;r‚cupŠre la taille du fichier ouvert handle
;exemple: FLen d1 renvoie dans d0 la taille du fichier handle d1
;handle D0 INTERDIT !
FLen	MACRO	handle
	FSeek	#2,\1,0
	move.l	d0,-(sp)
	FSeek	#0,\1,0
	move.l	(sp)+,d0
	ENDM

;ouvre lit et ferme un fichier. en d0=0 <==> ok
FAuto_Load	MACRO	nom,adr
;pea	nom
;pea	adr
	move.w	d7,-(sp)
	Fopen	0,\1
	bmi.s	.error
	move.w	d0,d7
	Fread	adr,-1.w,d7
	Fclose	d7
	beq.s	.ok
.error:	moveq	#1,d0
.ok:	move.w	(sp)+,d7
	ENDM

;Cr‚e un fichier normal. d0=status. tested
FCreate:	MACRO	nom
	movem.l	d1/a0-a1,-(sp)
	clr.w	-(sp)	;fichier normal
	pea	\1
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	movem.l	(sp)+,d1/a0-a1
	tst.w	d0
	ENDM

;ouvre le fichier.
;en d0: le handle (test‚)
; ex: FOpen 0,File(pc)
;mode: 0=lecture, 1=ecriture, 2=lecture/exriture
FOpen:	MACRO	mode,nom
	movem.l	d1/a0-a1,-(sp)
	move.w	#\1,-(sp)
	pea	\2
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	movem.l	(sp)+,d1/a0-a1
	tst.w	d0
	ENDM

FWrite:	MACRO	adr_buf,longueur,handle
	movem.l	d1/a0-a1,-(sp)
	pea	\1
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea.l	12(sp),sp
	movem.l	(sp)+,d1/a0-a1
	tst.w	d0
	ENDM


;lit dans le fichier.;d0=longueur lue
;Ex: FRead Buf(pc),#32000,d0
FRead:	MACRO	adr,lenght,handle
	movem.l	d1/a0-a1,-(sp)
	pea	\1
	move.l	\2,-(sp)
	move.w	\3,-(sp)	
	move.w	#$3f,-(sp)
	trap	#1
	lea.l	12(sp),sp
	movem.l	(sp)+,d1/a0-a1
	tst.l	d0
	ENDM

;Se d‚place dans le fichier.
;mode: 0=relatif au d‚but du fichier
;      1=relatif … la position actuelle
;      2=relatif … la fin du fichier
;ex: FSeek #2,d7,0	:pointe la fin du fichier
;et renvoie la taille du fichier en d0.
FSeek:	MACRO	mode,handle,offset
	movem.l	d1/a0-a1,-(sp)
	move.w	\1,-(sp)
	move.w	\2,-(sp)
	pea	\3
	move.w	#$42,-(sp)
	trap	#1
	lea.l	10(sp),sp
	movem.l	(sp)+,d1/a0-a1
	tst.l	d0
	ENDM

;Ferme le fichier.
;Exemple: FClose d7
FClose:	MACRO	handle
	movem.l	d1/a0-a1,-(sp)
	move.w	\1,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	movem.l	(sp)+,d1/a0-a1
	tst.w	d0
	ENDM

;**********************************************
;************* FICHIER MOD_NTK4.S *************
;**********************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                 Modificateur de modules .MOD->.NTK                    ;
;                            (Version 2.7)                              ;
;                (C)oderight NulloS//DNT-Crew 1991-94                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	SECTION	TEXT

	include	dsp_play.inc
	
print	MACRO
	pea	\1
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	RSRESET
ANC_NAME	rs.b	22	;nom d'un module (format .mod)
ANC_LEN	rs.w	1	;longueur
ANC_VOL	rs.w	1	;{finetune.b|volume.b}
ANC_REP	rs.w	1	;Point de boucle
ANC_RLN	rs.w	1	;longueur de boucle
ANC_SPL	rs.b	0	;taille du header de sample
;!<>! en maj stp !
	RSRESET
NEW_START	rs.l	1	;offset de d‚but&fin de sample par
NEW_END	rs.l	1	;rapport au d‚but du module .ntk
NEW_RLN	rs.l	1	;longueur du repeat
NEW_VOL	rs.w	1	;volume
NEW_FTUN	rs.w	1	;finetune
NEW_SPL	rs.b	0	;
;!<>! en maj stp !

	SECTION	TEXT

;ATTENTION: VARIABLE DEFINIE DANS DSP_PLAY.INC !!
;ADD_SPL	equ	664+8	;avanc‚e maximale dans un sample en 1 VBL
;			;+ s‚curit‚ de 8 pour le player DSP
;La note la plus haute est 108 ($71=113 plus finetune->108).
;Donc 664=(1/2.79365E-7)/(108*50).
;Pas besoin de changer pour 60Hz ou 71Hz (car alors ADD_SPL est plus petit,
;donc la version 50Hz convient).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
convert_mod_to_ntk:
				;Effectue la conversion:
	movem.l	d1-a6,-(sp)	;
	move.l	a3,-(sp)
	bsr.s	prepare_memoire	;D‚place le module.
	bsr.s	extract_infos	;puis on l'analyse.
	move.l	(sp)+,a3
	bsr	copie_partition	;copier les pattern+sequence.
	bsr	bidouille_sample	;modifie les samples.
	move.l	d7,d0		;
	bsr.s	installe_module	;
	movem.l	(sp)+,d1-a6	;
	rts			;En sortie,D0=taille NTK4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prepare_memoire
	lea	1024(a0),a1	;Installe les infos int‚ressantes
	move.l	a1,new_mod		;
	adda.l	#63*1024,a1	;On va d‚placer le module vers
	move.l	a1,anc_mod		;le haut, pour pouvoir ensuite
	adda.l	d0,a0		;le convertir de bas en haut
	adda.l	d0,a1		;sans recouvrements.
	move.b	-(a0),-(a1)	;
	subq.l	#1,d0		;Il reste un double des infos
	bgt.s	*-4		;m‚moires dans les 1024 octets
	rts			;du bas...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
installe_module
	move.l	new_mod(pc),a0	;Installe le module converti
	lea	-1024(a0),a1	;… sa position d‚finitive.
	move.b	(a0)+,(a1)+	;
	subq.l	#1,d7		;Utilise D7=longueur module NTK.
	bgt.s	*-4		;Ne pas toucher … D0!!
	rts			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Analyse le module, pour savoir s'il possŠde 15 ou 31 instruments, —ombien
;de patterns, longueur et bouclage de la s‚quence, et enfin pour ‚tablir le
;tableau des instruments (qui peuvent avoir des num‚ros ‚parpill‚s, avec
;des num‚ros non-utilis‚s, on va donc les regrouper).
extract_infos
	movea.l	anc_mod(pc),a0	;
	move.l	#$01d60258,anc_seq	;pr‚pare les offsets de
	move.w	#14,nb_instr	;partition et autres selon
	cmp.l	#"M.K.",$438(a0)	;le nombre d'instruments
	bne.s	z1		;
	move.l	#$03b6043c,anc_seq	;
	move.w	#30,nb_instr	;
z1	movea.l	a0,a1		;conserve cette adresse
	adda.w	anc_seq(pc),a0	;
	moveq	#0,d0		;
	move.b	(a0)+,d0		;Longueur de la sequence
	move.w	d0,sng_long	;conserve
	move.b	(a0)+,d1		;Point de repeat de la
	cmp.b	d0,d1		;partition. V‚rifie que
	blo.s	*+4		;la valeur est coh‚rente...
	moveq	#0,d1		;
	move.b	d1,song_repeat	;

;D‚ plou en plou fort: les *.mod peuvent avoir des patterns inutilis‚s,
;invisibles dans la partition, mais pr‚sent dans le fichier...
;Faut donc faire un test sur la longueur d‚clar‚e du song (pour le
;fichier *.ntk), puis refaire un test sur la longueur maxi (128) du
;song! (pour se balader dans le *.mod en shuntant le garbage).
	moveq	#0,d1		;
	move.l	a0,a3		;1er test: selon song_long
	subq.w	#1,d0		;a cause du dbf...
z2	cmp.b	(a0)+,d1		;trouve le No maximal pour
	bge.s	z3		;les pattern
	move.b	-1(a0),d1		;
z3	dbf	d0,z2		;
	move.w	d1,new_patmax	;stocke resultat
	addq.w	#1,d1		;
	mulu.w	#1024,d1		;en profite pour avoir la taille
	addi.l	#4+2+128,d1	;des datas de partitions du
	move.l	d1,new_size1	;NTK4.
	moveq	#0,d1		;

	moveq	#0,d0		;2Šme test: ignorer song_long!
	moveq	#0,d1		;
z22	cmp.b	(a3)+,d1		;trouve le No maximal pour
	bge.s	z33		;les pattern
	move.b	-1(a3),d1		;
z33	addq.b	#1,d0		;Sur les 128 positions!!.
	bvc.s	z22		;
	move.w	d1,old_patmax	;

	lea	20(a1),a1		;sur 1er instrument
	move.w	nb_instr(pc),d0	;On va regrouper les instruments
	lea	instr_exg(pc),a0	;
	clr.b	(a0)+		;premier instrument nul,toujours
	moveq	#0,d1		;maintenant on compte les samples
z4	clr.b	(a0)		;par defaut,instrument nul
	tst.w	ANC_LEN(a1)	;Longueur non nulle pour celui
	beq.s	z5		;l… ?.Non
	addq.w	#1,d1		;si,un de plus
	move.b	d1,(a0)		;stocke l'‚quivalent.
z5	addq.l	#1,a0
	lea	ANC_SPL(a1),a1	;instrument suivant
	dbf	d0,z4		;voil… c'est fait.
	lsl.w	#4,d1		;
	move.l	d1,new_size2	;taille des infos sample
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Recopier la partition en changeant les num‚ros d'instrument pour les
;regrouper, et en modifiant le codage de ces num‚ros dans la partition.
copie_partition
	move.l	a3,-(sp)
	;lea	combuf(pc),a3	;pour comptabiliser...
	moveq	#15+16-1,d3	;on commence par effacer
	clr.w	(a3)+		;
	dbf	d3,*-2		;
	;lea	combuf(pc),a3	;
	move.l	(sp)+,a3

	move.l	anc_mod(pc),a0	;
	move.l	new_mod(pc),a1	;
	adda.l	new_size2(pc),a1	;plac‚ sur debut partitions.
	move.l	#"NTK4",(a1)+	;identificateur.
	move.b	sng_long+1(pc),(a1)+	;stocke taille s‚quence
	move.b	song_repeat(pc),(a1)+	;et point de reprise.
	adda.w	anc_seq(pc),a0	;
	addq.w	#2,a0		;on se place sur l'ancienne
	moveq	#127,d0		;partition
cp_bcl0	move.b	(a0)+,(a1)+	;et on copie !
	dbf	d0,cp_bcl0		;
	move.w	new_patmax(pc),d0	;Prendre taille prise par les
	addq.w	#1,d0		;patterns -utilis‚s-
	lsl.l	#8,d0		;*1024 (/4 pour le nb de notes)
	lea	instr_exg(pc),a2	;pour changer No instruments
	move.l	anc_mod(pc),a0	;
	adda.w	anc_part(pc),a0	;on va sur les patterns
	move.l	#$1000f000,d4	;masque pour l'instrument
	move.l	#$07ff0fff,d5	;avant et aprŠs

cp_bcl1	move.l	(a0)+,d1		;prendre le data de note
	move.l	d1,d2		;
	and.l	d4,d2		;isole bits instrument
	rol.l	#4,d2		;000x0001
	lsl.w	#4,d2		;000x0010
	move.w	d2,d3		;
	swap	d2		;0010000x
	or.w	d3,d2		;001x
	move.b	0(a2,d2.w),d2	;‚quivalent 001y
	swap	d2		;
	clr.w	d2		;001y0000
	lsr.l	#5,d2		;0000z800
	swap	d2		;Donc No dans les bits 31..27
	and.l	d5,d1		;efface ancien No+le nouveau
	or.l	d2,d1		;place le nouveau
	move.l	d1,(a1)+		;et stocke

	bsr.s	ComCompt		;comptabilise les commandes

	subq.l	#1,d0		;La suite!
	bgt.s	cp_bcl1		;
	rts
;TRES IMPORTANT: il faut virer l'ancien num‚ro pour la lecture de la
;partition plus tard (pour l'effet voulu,on ne masque plus par $0fff !)
;                    (cf vpr_no_inst)

ComCompt	move.w	d1,d3		;
	lsr.w	#8,d3		;commande pure
	add.w	d3,d3		;
	move.w	.CC_off(pc,d3.w),d3	;
	bne.s	*+6		;
	tst.b	d1		;un arpeggio ?
	beq.s	.CC_end		;non !
	cmpi.w	#30,d3		;commande E ?
	bne.s	*+10		;
	andi.w	#$0f0,d1		;oui,alors dispatch
	lsr.w	#3,d1		;les cas possibles
	add.w	d1,d3		;
	addq.w	#1,0(a3,d3.w)	;une de plus
.CC_end	rts
	
.CC_off	dc.w	00,02,04,06,08,10,12,14
	dc.w	16,18,20,22,24,26,30,28

AffCompt:
	print	stat(pc)		;
	;lea	combuf(pc),a3	;
	lea	list(pc),a4	;
	moveq	#31-1,d5		;total:31 effets
.AC_1	print	(a4)		;ecrit entr‚e
	lea	msize(a4),a4	;entr‚e suivante
	moveq	#3,d2		;4 chiffres
	moveq	#0,d3		;
	move.w	(a3)+,d3		;
	lea	buf_aff+6(pc),a2	;pour travailler
	clr.b	-(a2)		;
.AC_2	divu	#10,d3		;
	swap	d3		;
	addi.b	#"0",d3		;
	move.b	d3,-(a2)		;
	clr.w	d3		;
	swap	d3		;
	dbf	d2,.AC_2		;chiffre suivant
	print	(a2)		;
	dbf	d5,.AC_1		;suivant
	print	AC_cr(pc)
	rts
AC_cr:	dc.b	13,10,0,0
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;On triture les samples, afin de leur rajouter ce qu'il faut sur leur fin
;pour faire sauter les tests du mixage.
bidouille_sample

	move.l	anc_mod(pc),a0	;Base des 2 modules
	move.l	new_mod(pc),a1	;
	movea.l	a0,a2		;Vont servir pour se ballader
	movea.l	a1,a3		;dans les samples.
	lea	20-1024(a1),a0	;Aller sur les infos samples.

	move.l	new_size1(pc),d7	;offset NEW_START du 1er
	add.l	new_size2(pc),d7	;sample.
	adda.l	d7,a3		;se place sur les futurs samples
	move.w	old_patmax(pc),d0	;nb de pattern
	addq.w	#1,d0		;
	mulu.w	#1024,d0		;*1024 pour taille
	adda.l	d0,a2		;on se place aprŠs
	adda.w	anc_part(pc),a2	;donc sur les samples
	move.w	nb_instr(pc),d6	;compteur de samples

bs_bcl0	moveq	#0,d0		;annule bits forts
	move.w	ANC_LEN(a0),d0	;longueur du sample (en mots)
	bne.s	bs_1		;nulle ?
bs_bcl0_end
	lea	ANC_SPL(a0),a0	;sample suivant
	dbf	d6,bs_bcl0		;
	rts			;

bs_1	add.l	d0,d0		;longueur en octets
	moveq	#$f,d1		;
	and.b	ANC_VOL(a0),d1	;ANC_VOL={finetune.b|volume.b}
	mulu	#36*2,d1		;une table de finetune=36 mots
	move.w	d1,NEW_FTUN(a1)	;donc dispatch les deux
	move.w	ANC_VOL(a0),d1	;octets
	lsl.w	#8,d1		;un volume=256 valeurs
	move.w	d1,NEW_VOL(a1)	;
	move.l	d7,NEW_START(a1)	;position actuelle=start
	cmpi.w	#1,ANC_RLN(a0)	;y'a une boucle ?
	bne.s	bs_repeat		;ouaip

bs_norepeat
	add.l	d0,d7		;position actuelle+=spl_len
	move.l	d7,NEW_END(a1)	;c'est la fin r‚elle
	clr.l	NEW_RLN(a1)	;pas de repeat,donc
	lsr.l	#1,d0		;nb mots
	subq.w	#1,d0		;corrige dbf
bs_bcl1	move.w	(a2)+,(a3)+	;mot-…-mot de sample
	dbf	d0,bs_bcl1		;recopier
	move.b	-1(a3),d0		;rajoute la derniŠre valeure
	lsl.w	#8,d0		;
	move.b	-1(a3),d0		;(toujours un mot !)
	move.w	#ADD_SPL/2-1,d1	;pour que le sample coupe
bs_bcl2	move.w	d0,(a3)+		;en arrivant … la fin
	dbf	d1,bs_bcl2		;
	lea	NEW_SPL(a1),a1	;sample (NTK) suivant
	addi.l	#ADD_SPL,d7	;position+le rajout
	bra.s	bs_bcl0_end	;

bs_repeat	movea.l	a2,a4		;registre de travail
	adda.l	d0,a2		;passe au sample suivant
	moveq	#0,d0		;
	move.w	ANC_RLN(a0),d0	;Taille du repeat (rln)
	bne.s	.normal		;
.ending	move.w	ANC_LEN(a0),d0	;Si rln=0, alors on le calcule
	sub.w	ANC_REP(a0),d0	;en prenant le fin du sample.
	bhi.s	*+4		;V‚rifie le r‚sultat...
	moveq	#1,d0		;
.normal	add.l	d0,d0		;Longueur en octet
	move.l	#ADD_SPL,d1	;Compare rln et bouclage
	cmp.l	d1,d0		;plus grande ?
	bge.s	old_repeat		;oui,ok
new_repeat	divu	d0,d1		;non,faut changer la taille
	move.l	d1,d2		;du repeat pour que le
	swap	d2		;bouclage soit correct.
	tst.w	d2		;new_rln=
	beq.s	nr_0		;(1+Int(ADD_SPL/anc_rln))*anc_rln
	addq.w	#1,d1		;
nr_0	mulu	d0,d1		;taille du nouveau repeat
	bra.s	*+4		;D0=ancien rlen D1=nouveau rlen
old_repeat	move.l	d0,d1		;Pas de changement:D0=D1

	move.l	d1,NEW_RLN(a1)	;range le repeat_lengh
	moveq	#0,d2		;on construit un nouveau sample
	move.w	ANC_REP(a0),d2	;en ne prenant que avant le repeat,
	add.l	d2,d2		;et le repeat (ce qui est aprŠs
	add.l	d2,d7		;le repeat disparait,mais souvent
	add.l	d1,d7		;y'a rien).D'o— fin du sample
	move.l	d7,NEW_END(a1)	;
	move.l	a3,a5		;      <<cf ci-dessous>>
	tst.l	d2		;Tout le sample est en boucle ?
	beq.s	bsr_bcl1		;oui,on shunte ce qui suit.
	
	lsr.l	#1,d2		;repasse en nb de mots
	subq.w	#1,d2		;
bsr_bcl0	move.w	(a4)+,(a3)+	;mot-…-mot, copier corps du sample
	dbf	d2,bsr_bcl0	;(cad sans le repeat)
	move.l	a3,a5		;<<conserve repeat, dans NEW>>

bsr_bcl1	move.l	d0,d2		;Ensuite,recopie autant de
	lsr.l	#1,d2		;fois que necessaire le vieux
	subq.w	#1,d2		;ANC_RLN,pour construire le
bsr_bcl2	move.w	(a4)+,(a3)+	;nouveau NEW_RLN (qui est qqch
	dbf	d2,bsr_bcl2	;du style n*ANC_RLN)
	movea.l	a5,a4		;Revient d‚but repeat
	sub.l	d0,d1		;NEW_RLN-=ANC_RLN
	bgt.s	bsr_bcl1		;NEW_RLN-n*ANC_RLN ?
	move.w	#ADD_SPL/2-1,d0	;On a fini,on garnit donc la
bsr_bcl3	move.w	(a5)+,(a3)+	;fin, depuis NEW_SPL car on peut
	dbf	d0,bsr_bcl3	;avoir modifi‚ le repeat length.

	lea	NEW_SPL(a1),a1	;Sample suivant...
	addi.l	#ADD_SPL,d7	;...en offset adresse aussi.
	bra	bs_bcl0_end	;Goto Next Until End Quit (!)
;Nb:en cas de nouveau RLN (donc si ANC_RLN<ADD_SPL), comme NEW_RLN est
;un multiple de ANC_RLN (vu que mulu d0,d1),et que ANC_RLN est un nombre
;de mots (parit‚ en octets), alors NEW_RLN est aussi pair. Donc les copies
;mot-…-mot sont valables pour tous les RLN.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

anc_mod	ds.l	1
new_mod	ds.l	1
nb_instr	ds.w	1
instr_exg	ds.b	32
anc_seq	ds.w	1
anc_part	ds.w	1
old_patmax	ds.w	1
new_patmax	ds.w	1
sng_long	ds.w	1
new_size1	ds.l	1
new_size2	ds.l	1
song_repeat
	ds.b	1
	EVEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

stat	dc.b	13,10,"Figure for the used commands :     ",0

list	dc.b	      "      0 -Arpeggio..............: ",0
	dc.b	13,10,"    1 -Portamento Up.........: ",0
	dc.b	      "      2 -Portamento Down.......: ",0
	dc.b	13,10,"    3 -Tone Portamento.......: ",0
	dc.b	      "      4 -Vibrato...............: ",0
	dc.b	13,10,"    5 -TonePorta+Volume Slide: ",0
	dc.b	      "      6 -Vibrato+Volume Slide..: ",0
	dc.b	13,10,"    7 -Tremolo...............: ",0
	dc.b	      "      8 -Inexistant............: ",0
	dc.b	13,10,"    9 -Sample Offset.........: ",0
	dc.b	      "      A -Volume Slide..........: ",0
	dc.b	13,10,"    B -Position Jump.........: ",0
	dc.b	      "      C -Set Volume............: ",0
	dc.b	13,10,"    D -Pattern Break.........: ",0
	dc.b	      "      F -Set Speed.............: ",0
	dc.b	13,10,"    E0-Set Filter............: ",0
	dc.b	      "      E1-Fine Portamento Up....: ",0
	dc.b	13,10,"    E2-Fine Portamento Down..: ",0
	dc.b	      "      E3-Set Glissando.........: ",0
	dc.b	13,10,"    E4-Set Vibrato Waveforme.: ",0
	dc.b	      "      E5-Set FineTune..........: ",0
	dc.b	13,10,"    E6-Set Loop Control......: ",0
	dc.b	      "      E7-Set Tremolo Waveform..: ",0
	dc.b	13,10,"    E8-Song Stop.............: ",0
	dc.b	      "      E9-Rettrig Sample........: ",0
	dc.b	13,10,"    EA-Fine Volume Slide Up..: ",0
	dc.b	      "      EB-Fine Volume Slide Down: ",0
	dc.b	13,10,"    EC-Note Cut..............: ",0
	dc.b	      "      ED-Note Delay............: ",0
	dc.b	13,10,"    EE-Pattern Delay.........: ",0
	dc.b	      "      EF-Set Balance...........: ",0
msize	equ	34


	SECTION	TEXT

;**********************************************
;**********************************************
;**********************************************

PRINT:	MACRO
	movem.l	d0-d1/a0-a1,-(sp)
	pea	\1
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d1/a0-a1
	ENDM

INTRO_TXT:
 dc.b 27,"w",27,"l"
 dc.b "********************************************************************************",13,10
 dc.b "*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*",13,10
 dc.b "*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷   MOD' Player   ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*",13,10
 dc.b "*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*",13,10
 dc.b "* This TTP uses the NuLLoS DSP replayrouts. I really thinx that it is the      *",13,10
 dc.b "* _best_ replayrout ever coded on Falcon030 ... And this rout is FREEWARE !    *",13,10
 dc.b "* _________________________________________     You can use it in your public- *",13,10
 dc.b "* | This rout offers you many features as:|     domain programs                *",13,10
 dc.b "* | 3 Qualities (respectively 10,16 and   | _______    Author: NULLOS/DNT-CREW *",13,10
 dc.b "* | 20% of DSP time); 50 Khz; DSP free (!)| address: Monsieur Sylvain LANGLADE *",13,10
 dc.b "* | Balance of each of the four voices    | ÿÿÿÿÿÿÿ  rue de l'Oradou           *",13,10
 dc.b "* | _Real-Time_ DMA/HOST ports Toggle     |          63000 Clermont-Ferrand    *",13,10
 dc.b "* | Protracker bugs compatible !          |                   - FRANCE -       *",13,10
 dc.b "* ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ                                    *",13,10
 dc.b "*  òòòòòòòòòò  Mod may be packed with Atomic 3.5; SpeedPacker III  óóóóóóóóóó  *",13,10
 dc.b "*  òòòòòòòòòò        Ice 2.4; Sentry 2.0; or PowerPacker2.0        óóóóóóóóóó  *",13,10
 dc.b "************************************************** TTP: Megar/BinariS **********",13,10,10,0

ACTUAL_TXT
 dc.b "Actual Settings:  -DMA transfert (faster than HOST but Timer-A needed)",13,10
 dc.b "  -Verify Module: ON   -FineTune: On   -Interpolation: ON   -Balances:ON",13,10
 dc.b "You can run this TTP by typing a mod mask in the dialog box: if you type '*.mod'",13,10
 dc.b "the proggy will play a random mod ! Very Useful ! You can also let a ' ' or '&'",13,10
 dc.b "character at the start of the line, thus will automatically set the player in",13,10
 dc.b "resident status, without displaying menu. Example: ' A:OPERA.MOD' or ' E:*.MOD'!",13,10
 dc.b "To automatically stop the player, just type '-' as command-line !",13,10
 dc.b "   TTP-version: 1.2 by Megar/BinariS- ReplayRout-version: 2.7 by NuLLoS/DNT-CREW",13,10
 dc.b 0

USAGE_TXT:
 dc.b "|",13,10
 dc.b "---> Usage: Drag mod File to the program or type the name in dialog box ...",13,10,10,0

UNFOUNDABLE_TXT:
 dc.b 13,10,"|",13,10,"---> I can't open the mod'File !",13,10,10,0

LOADING_TXT:
 dc.b 27,"e"
 dc.b "     Now Loading : ",0

NOMEMORY_TXT:
 dc.b 13,10,"|",13,10,"---> I can't reserve enough memory to play mod ... Sorry !",13,10,10,0

READERROR_TXT:
 dc.b 13,10,"|",13,10,"Error while loading file !",13,10,10,0

DSP_USED_TXT:
 dc.b 13,10,"|",13,10,"Can't install player in DSP...",13,10,10,0

DSP_MEMORY_TXT
 dc.b 13,10,"|",13,10,"---> Not Enough Memory In DSP...",13,10,10,0

NOT_MOD_TXT
 dc.b 13,10,"|",13,10,"---> This is NOT a Mod File !!!",13,10,10,0

NO_COOKIE_TXT:
 dc.b 13,10,"|",13,10,"---> Not Enough Cookie and I can't create others !",13,10,10,0

ALALIGNE_TXT:
 dc.b 10,13,0

DEPACKING_TXT:
 dc.b 27,"l","     Now Depacking ...",0

CONVERTING_TXT:
 dc.b 27,"l","     Now Converting to NTK4 format...",0

PLAYING_TXT:
PLAYING_TXT2	equ	*+2
 dc.b 27,"l---> Now Playing : ",34
MOD_NAM: dcb.b 20,1
 dc.b 34,"   ("
FILE_NAM dcb.b 12,1
	dc.b	") ...",13,10,10,0

CPU_TXT:
 dc.b 27,"l"," --> Actual amount of time used by replayrout : xx.x %",10,13
 dc.b        " --> Maximum amount of time used by replayrout : xx.x %"
 dc.b 27,"f",8,8,8,27,65,0

CPU_MAX:
 dc.b 8,8,8,27,66,0

CPU_MAX_ACT:
 dc.b 27,65,8,0

CPU_RT:
 dc.b 8,8,8,8
CPU_Percent
 dc.b	0,0	;%
 dc.b	"."
 dc.b	0	;dizieme
 dc.b	0

MAIN_MENU_TXT:
 dc.b 27,"e",27,"l"
 dc.b "  ",27,"p -------------------------------- MAIN MENU ------------------------------- ",27,"q",13,10
 dc.b "  ",27,"p <0> ",27,"q Quit, module OFF                ",27,"p <Space> ",27,"q Quit in same Status",13,10
 dc.b "  ",27,"p <1> ",27,"q --> MAKE RESIDENT <--             ",27,"p <3> ",27,"q Informations about the program",13,10
 dc.b "  ",27,"p <2> ",27,"q Show module informations          ",27,"p <4> ",27,"q Show used time",13,10
 dc.b "  ",27,"p -------------------------------------------------------------------------- ",27,"q",13,10,0

	even
NOMEMORY:
	pea	NOMEMORY_TXT(pc)
	bra	printq
READERROR:
	pea	READERROR_TXT(pc)
	bra	printq

MAIN:
	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,STACK

	lea	FILE_NAM(pc),a0	;vide nom du fichier
	moveq	#12-1,d0
.cl:	move.b	#1,(a0)+
	dbf	d0,.cl
	
	move.l	#"NTK4",d0	;Driver d‚j… pr‚sent ?
	bsr	Cookie		;oui: d3=adresse bloc
	tst.l	d0
	beq.s	Flush_Key

; driver d‚j… pr‚sent:

	st	resident
	st	resident+1
	move.l	d3,Bloc_Adr
	move.l	8(a0),(a0)	;enlŠve le cookie
	move.l	12(a0),4(a0)

	move.l	d3,a6
	lea	name(a6),a5
	lea	FILE_NAM(pc),a1
	moveq	#12-1,d0		;12 car.
.c2:	move.b	(a5)+,d1
	beq.s	.c3
	move.b	d1,(a1)+
	dbf	d0,.c2
	
.c3	moveq	#20-1,d0		;20 caractŠres
	lea.l	title(a6),a5	;copie dans title
	lea.l	MOD_NAM(pc),a1	;adresse d‚but
.c:	move.b	(a5)+,(a1)+
	dbf	d0,.c

Flush_Key:
	move.w	#$0b,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.w	d0
	bne.s	.flush
	bra.s	.flushed

.flush:	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	bra.s	Flush_Key
.flushed:	
	move.l	BASEPAGE_ADR(pc),a6
	lea.l	$80(a6),a6
	move.b	(a6)+,d7
	bne	read_lig		;ligne de commande pr‚sente ?
	tst.b	resident(pc)	;non, resident alors ?
	bne	Installed
	pea	USAGE_TXT(pc)
printq:	
	move.w	#9,-(sp)
	PRINT	INTRO_TXT(pc)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
Quit:	tst.b	dsp_locked(pc)
	beq.s	Pterm
	move.w	#$69,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	#$81,-(sp)
	trap	#14
	addq.l	#2,sp
Pterm:	tst.l	Bloc_Adr(pc)
	beq.s	User_Stack
	bsr	BP_Bidouille
	move.l	Bloc_Adr(pc),-(sp)
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	BP_Bidouille
User_Stack:
	move.l	STACK,-(sp)
	move.w	#$20,-(sp)		;Retour en user
	trap	#1
	addq.l	#6,sp

	PRINT	ALALIGNE_TXT(pc)
	
	clr.w	-(sp)
	trap	#1

read_lig:
;ligne de commande pr‚sente, stoppe module si pr‚sent !
	tst.b	resident(pc)
	beq.s	.notr
	
	move.w	#$2700,sr
	lea.l	$fffffa00.w,a0
	move.l	Bloc_Adr(pc),a5
	bclr	#4,$09(a0)	;
 	bclr	#4,$15(a0)	;
	move.l	V_TD(a5),$110.w	;
	move.b	VR(a5),$17(a0)	;
	move.w	#$2300,sr
	clr.b	$ffff8901.w	;
	clr.l	-(sp)		;Coupe la sortie son du DSP,
	move.w	#$89,-(sp);Snd_DspTriState	;pour pas merder.
	trap	#14
	addq.w	#6,sp

	bsr	BP_Bidouille
	pea	(a5)
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	BP_Bidouille
	
.notr:	lea.l	mod_name(pc),a5
	cmp.b	#"-",(a6)
	bne.s	.noof
	move.w	#$69,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	#$81,-(sp)
	trap	#14
	addq.l	#2,sp
	bra	User_Stack

.noof	cmp.b	#" ",(a6)		;AUTO_RESIDENT ?
	beq.s	.auto
	cmp.b	#"&",(a6)
	bne.s	.no_auto
.auto	st	auto_resident
	tst.b	(a6)+
	subq.w	#1,d7
.no_auto:	move.l	a5,a4
	addq.w	#1,d7
	move.w	d7,Com_Len
	subq.w	#2,d7	
.cp_na:	move.b	(a6)+,(a5)+
	dbf	d7,.cp_na
	clr.b	(a5)
	lea	FILE_NAM(pc),a0	;vide nom mod
	moveq	#12-1,d0
.clr:	move.b	#1,(a0)+
	dbf	d0,.clr
	tst.b	resident
	bne.s	.dspfree
	move.w	#$80,-(sp)	;SND_LOCK
	trap	#14
	addq.l	#2,sp
	subq.w	#1,d0
	beq.s	.soundfree	;ALREADY LOCKED ?
	pea	DSP_USED_TXT(pc)
	bra	printq
.soundfree:
	move.w	#$68,-(sp)	;DSP_LOCK
	trap	#14
	addq.l	#2,sp
	tst.w	d0
	beq.s	.dspfree		;ALREADY LOCKED ?
	move.w	#$81,-(sp)	;SND_UNLOCK
	trap	#14
	addq.l	#2,sp
	pea	DSP_USED_TXT(pc)
	bra	printq

.dspfree
	sf	resident

	st	dsp_locked
	pea	Buf(pc)
	pea	Buf+4(pc)
	move.w	#$6a,-(sp)
	trap	#14
	lea.l	10(sp),sp

	cmpi.l	#$3000-$200,Buf(pc)
	ble.s	.dspmem		;pas Assez de place en m‚moire Y ?
	cmpi.l	#$3000-$100,Buf(pc)
	bgt.s	.dspmemok		;et X ?
.dspmem:	pea	DSP_MEMORY_TXT(pc)
	bra	printq
.dspmemok:

	pea	-1.w		;petit Malloc des familles
	move.w	#72,-(sp)		;place libre
	trap	#1		;d0=espace libre
	addq.l	#6,sp
	move.l	d0,d3		;d3=longueur BLOC
	bmi	NOMEMORY
	cmp.l	#64*1024,d0
	bmi	NOMEMORY

	bsr	BP_Bidouille
	move.l	d0,-(sp)		;moa je r‚serve tout-32Ko ...
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	BP_Bidouille
	
	move.l	d0,a6		;a6=adresse bloc
	move.l	d0,Bloc_Adr
	tst.l	d0
	ble	NOMEMORY	
	
	move.l	d3,Bloc_Len(a6)

	moveq	#0,d7		;d7=nombre de fichier
	lea.l	mod_name(pc),a4	;a4=Mask fichier
	move.l	a6,a5		;a6=a5=bloc
	addq.l	#4,a5
	move.w	#$2f,-(sp)	;GETDTA
	trap	#1
	addq.l	#2,sp
	move.l	d0,a3		;a3=DTA
	move.w	#$27,-(sp)	;TOUT fichier
	pea	(a4)
	move.w	#$4e,-(sp)	;FSFIRST
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	.cantopen
.FSnext	addq.l	#1,d7
	move.l	30(a3),(a5)+	;copier nom
	move.l	34(a3),(a5)+
	move.l	38(a3),(a5)+
	move.l	42(a3),(a5)+
	move.w	#$4f,-(sp)	;FSFIRST
	trap	#1
	addq.l	#2,sp
	tst.w	d0
	beq.s	.FSnext
	
	move.l	a4,a5
.sbl:	tst.b	(a5)+
	bne.s	.sbl
	move.w	Com_Len(pc),d0
.ssl:	cmp.b	#"\",-(a5)
	dbeq	d0,.ssl
	tst.b	(a5)+
	
	move.w	#$11,-(sp)	;Random
	trap	#14
	addq.l	#2,sp
	lsr.l	#8,d0		;sur 16 bits
	divu	d7,d0		;d0=Rnd/Nbr
	swap	d0
	ext.l	d0
	lsl.l	#4,d0		;d0=numero du fichier*16
	lea.l	4(a6,d0.l),a3
	
	move.l	(a3)+,(a5)+	;copier nom
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a5)+
	move.l	(a3)+,(a5)+
	
	movem.l	d0/a3/a5,-(sp)
	moveq	#12-1,d0		;12 cars
	lea	-16(a3),a3
	lea	FILE_NAM(pc),a5
.cn:	move.b	(a3)+,d1
	beq.s	.cn2
	move.b	d1,(a5)+
	dbf	d0,.cn
.cn2:
	movem.l	(sp)+,d0/a3/a5
	
;a4= fichier
	PRINT	LOADING_TXT(pc)
	PRINT	(a4)

	FOpen	0,(a4)		;ouvre fichier
	bgt.s	.opened
.cantopen	pea	UNFOUNDABLE_TXT(pc)
	bra	printq
.opened:	move.w	d0,d7		;d7=handle fichier
	FLen	d7		;d0=taille fichier
	move.l	d0,d1		;d1=taille fichier
	move.l	d1,d2		;d2=taille fichier
	move.l	d1,Mod_Len(a6)
	addi.l	#64*1024,d1	;d1=taille fichier+64Ko avant NTK4
	cmp.l	d3,d1
	bhi	NOMEMORY
	
	lea.l	module(a6),a5

	FRead	(a5),d2,d7	;lire fichier
	bmi	READERROR
	FClose	d7		;fermer fichier
	
;d2=taille fichier
;d3=longueur bloc
;a5=adresse fichier
	PRINT	DEPACKING_TXT

	cmpi.l	#"PP20",(a5)	;Compactage PowerPacker?
	bne.s	.nopp20		;
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	-4(a5,d2.l),d6
	lsr.l	#8,d6		;
	bra.s	.ModPack		;
.nopp20	;D‚tection Sentry 2_0. Encore plus
	;merdique que le PowerPacker: la taille
	;est aussi en fin de fichier, mais aussi
	;l'identification... et le tout dans le
	;format Intel !!. All“ la terre ?
	move.l	-4(a5,d2.l),d0
	cmpi.l	#"Snt.",d0		;
	bne.s	NoModPack		;La taille d‚compact‚e tient dans
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	-8(a5,d2.l),d6	;l'avant dernier mot-long.
	ror.w	#8,d6		;
	swap	d6		;
	ror.w	#8,d6		;
.ModPack:	sub.l	#64*1024,d3
	cmp.l	d3,d6
	bhi	NOMEMORY
	move.l	a5,a0
	move.l	d2,d0
	bsr	PP20
	bsr	Sentry2_0
	movem.l	(sp)+,d0-d7/a0-a6

NoModPack	move.l	a5,a0		;adresse fichier
	move.l	d3,d0		;longueur memoire
	bsr	Depack_All	;vazy-vaza
	bmi	NOMEMORY
	beq.s	.npak
	move.l	d0,Mod_Len(a6)
	add.l	#64*1024,d0
	cmp.l	d0,d3
	bmi	NOMEMORY
.npak:	;pr‚pare l'affichage de Now Playing + FileName + titre
	lea.l	module(a6),a0
	move.l	a0,a1
	moveq	#20-1,d0		;20 caractŠres
	lea.l	MOD_NAM(pc),a2
.clrti:	move.b	#1,(a2)+
	dbf	d0,.clrti
	lea.l	-20(a2),a2
	moveq	#20-1,d0
.loop:	move.b	(a1)+,d1
	beq.s	.until
	move.b	d1,(a2)+
	dbf	d0,.loop
.until:	lea.l	FILE_NAM(pc),a2
	lea.l	name(a6),a1
	moveq	#12-1,d0		;12 car copie FileName
.c3	move.b	(a2)+,(a1)+
	beq.s	.c2
	dbf	d0,.c3
.c2	moveq	#20-1,d0		;20 caractŠres
	lea.l	title(a6),a2	;copie dans title
	lea.l	MOD_NAM(pc),a1	;adresse d‚but
.c:	move.b	(a1)+,(a2)+
	dbf	d0,.c
	
	lea.l	module(a6),a0
	move.l	Mod_Len(a6),d0
	lea.l	combuf(a6),a3
	PRINT	CONVERTING_TXT
	bsr	convert_mod_to_ntk
STOP_IT	tst.l	d0
	bgt.s	.okmod
	pea	NOT_MOD_TXT(pc)
	bra	printq
.okmod	add.l	#Save_SizeOf,d0
	move.l	d0,d7		;d7=taille optimale du bloc
	
;partie qui recherche le bloc de m‚moire optimal
	pea	0.w	;0: commencement de l'empilement
	
MMY_Cherche
	pea	-1.w		;demande + gand bloc
	move.w	#72,-(sp)		;restant
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	beq.s	.End_MMY
	
	move.l	d0,-(sp)		;reserve ce bloc
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	beq.s	.End_MMY2
	
	move.l	d0,-(sp)	;empilement de l'adresse

	bra.s	MMY_Cherche
.End_MMY2	addq.l	#4,sp
.End_MMY:
	move.l	Bloc_Adr(pc),a6	;a6=bloc adresse
	move.l	Bloc_Len(a6),d6	;d6=bloc len
	sub.l	d7,d6		;d6=bloc len-bloc optimal

	bsr	BP_Bidouille
	sub.l	#256,d6
	move.l	d6,-(sp)			;newsize
	add.l	#256,d6
	pea	(a6)			;adresse
	pea	$4a0000			;MSHRINK
	trap	#1
	lea.l	12(sp),sp	
	move.l	d7,-(sp)		;reserve bloc optimal
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,a5		;a5=bloc optimal adresse
	move.l	a5,a3
	move.l	a6,a4
	move.l	d7,d6		;d6=bloc len
.cblocs:	move.b	(a4)+,(a3)+	;cope blocs
	subq.l	#1,d6
	bne.s	.cblocs
	move.l	d7,Bloc_Len(a5)
	move.l	a5,Bloc_Adr
	pea	(a6)		;libŠre grand bloc
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	BP_Bidouille
.mmy_de:	move.l	(sp)+,d0
	beq.s	.mmy_end
	move.l	d0,-(sp)		;libŠre blocs
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	bra.s	.mmy_de
.mmy_end:
	

;INSTALLE LE PLAYER DE MODULE.
;PHASE I: INITIALISATION
	move.l	Bloc_Adr(pc),a6
	move.l	Mod_Len(a6),d0
	lea.l	module(a6),a0
	lea.l	buf(a6),a1
	lea.l	dsp_play(a6),a2
	lea.l	adsp_play(pc),a3	;player a copier
	lea.l	-28(a2),a4
	move.w	#adsp_len-1,d1
.co:	move.b	(a3)+,(a4)+
	dbf	d1,.co
	jsr	(a2)

;PHASE II: REGLAGES
	move.l	dsp_play+8(a6),a0	;Adresse des variables internes
	clr.b	song_stop(a0)	;->D‚bloque
	clr.b	dma2dsp(a0)	;->Transfert par le DMA
	;st	dma2dsp(a0)
	move.w	#$100,master_vol(a0)

;PHASE III: INSTALLATION
	move.w	#$2700,sr
	lea	$fffffa00.w,a6	;Installe le TimerD en 50Hz
	move.l	Bloc_Adr(pc),a5
	move.b	$17(a6),VR(a5)	;MFP en mode AEI
	bclr	#3,$17(a6)		;
	move.l	$110.w,V_TD(a5)	;
	lea.l	it_50hz(a5),a4
	move.l	#$612a4e73,(a4)
	move.l	a4,$110.w
	move.b	#246,$25(a6)	;~50Hz
	ori.b	#7,$1d(a6)	;
	bset	#4,$09(a6)	;
	bset	#4,$15(a6)	;
	move.w	#$2300,sr
	
Installed:
	tst.b	auto_resident
	bne	Resident

	PRINT	INTRO_TXT
	PRINT	PLAYING_TXT
Aff_M_Menu
	PRINT	MAIN_MENU_TXT
	
Main_M_Gere
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	cmp.w	#" ",d0
	beq.s	Space
	
	sub.w	#"0",d0
	bmi.s	Main_M_Gere
	beq	Quitter		;0 ?
	cmp.w	#2,d0
	bmi.s	Resident		;1 ?
	beq	M_Figures
	cmp.w	#4,d0
	beq.s	Show_CPU
	bhi.s	Main_M_Gere

	PRINT	INTRO_TXT
	PRINT	ACTUAL_TXT
	PRINT	PLAYING_TXT2
	bra	Aff_M_Menu

Space:	tst.b	resident+1
	beq	Quitter
Resident:
	moveq	#0,d0
	bsr	Cookie	;cherche dernier cookie
	cmp.l	d1,d3
	bne.s	.ok
	pea	NO_COOKIE_TXT(pc)
	bra	printq
.ok:
	move.l	(a0),8(a0)
	move.l	4(a0),12(a0)
	move.l	#"NTK4",(a0)
	move.l	Bloc_Adr(pc),4(a0)
	bra	User_Stack

Show_CPU:
	PRINT	CPU_TXT(pc)
	move.w	#$2700,sr
	move.l	#Hz50_IT_CPU,$110.w
	move.w	#$2300,sr

	lea.l	$ffff82a0.w,a6
	move.w	#500,d7
	moveq	#0,d6
	move.w	d6,d2
	moveq	#1,d3
	lea	CPU_Percent(pc),a5
	lea	CPU(pc),a4
	moveq	#0,d5
	
;a4: CPU
;a5: CPU_Percent
;a6: pointeur ligne ecran
;d7: scan_mini
;d6: scan_maxi
;d2: CPU_maxi en ligne
;d3: scan_maxi-scan_mini+1 (diviseur)
;d5: maximum time

Cpu_Loop	
	move.w	#$0b,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.w	d0
	bne	Cpu_End

	move.w	(a6),d4
	cmp.w	d7,d4	;plus petit que scan_mini ?
	bge.s	.no1
	move.w	d4,d7
	bra	CpuRecalcDiv
.no1:	cmp.w	d6,d4	;plus grand que scan_maxi ?
	bls.s	.no2
	move.w	d4,d6
	bra	CpuRecalcDiv
.no2:	move.w	(a4),d4		;delta dans d4
	bls.s	Cpu_Loop		;<0 ?
	cmp.w	d2,d4		;idem pr‚c‚dement ?
	beq.s	Cpu_Loop
	cmp.w	d6,d4		;>max ?
	bhi.s	Cpu_Loop
	move.w	d4,d2

;calcul le temps...
	mulu	#1000,d4	;*1000
	divu	d3,d4	;/max --> pourcentage*10 (%.)
	ext.l	d4	;d4=0...pourcent
	divu.w	#10,d4
	swap	d4
	add.b	#$30,d4
	move.b	d4,3(a5)
	swap	d4
	ext.l	d4
	divu.w	#10,d4	;d4=000u|000d
	swap	d4	;d4=000d|000u
	lsl.w	#8,d4	;d4=000d|0u00
	lsr.l	#8,d4	;d4=0000|0d0u
	add.w	#$3030,d4
	move.w	d4,(a5)
	cmp.l	(a5),d5
	bge.s	.noplus
	move.l	(a5),d5
	pea	CPU_MAX(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	(a5)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	CPU_MAX_ACT(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
.noplus	pea	CPU_RT-CPU_Percent(a5)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra	Cpu_Loop
	
Cpu_End:	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	PRINT	ALALIGNE_TXT(pc)
	PRINT	ALALIGNE_TXT(pc)
	move.w	#$2700,sr
	move.l	Bloc_Adr(pc),a0
	lea.l	it_50hz(a0),a0
	move.l	a0,$110.w
	move.w	#$2300,sr
	bra	Aff_M_Menu

CpuRecalcDiv:
	move.l	d6,d3
	sub.w	d7,d3
	addq.w	#1,d3
	bra	Cpu_Loop
	
M_Figures
	move.l	Bloc_Adr(pc),a3
	lea.l	combuf(a3),a3
	bsr	AffCompt
	bra	Aff_M_Menu

Quitter:	move.w	#$2700,sr
	lea.l	$fffffa00.w,a6
	move.l	Bloc_Adr(pc),a5
	bclr	#4,$09(a6)	;
 	bclr	#4,$15(a6)	;
	move.l	V_TD(a5),$110.w	;
	move.b	VR(a5),$17(a6)	;
	move.w	#$2300,sr

fini	clr.b	$ffff8901.w	;
	clr.l	-(sp)		;Coupe la sortie son du DSP,
	move.w	#$89,-(sp);Snd_DspTriState	;pour pas merder.
	trap	#14
	addq.w	#6,sp
	
SOUNDCMD:	MACRO	wot,value
	move.w	#\2,-(sp)
	move.w	#\1,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp
	ENDM

DEVCONNECT:	MACRO	source,dest,horloge,predv
	move.w	#1,-(sp)	;No handchecking
	move.w	#\4,-(sp)	;Predivision de l'horloge
	move.w	#\3,-(sp)	;horloge choisie
	move.w	#\2,-(sp)	;dest
	move.w	#\1,-(sp)	;source
	move.w	#139,-(sp)
	trap	#14
	lea.l	12(sp),sp
	ENDM

;	SOUNDCMD	0,0	;Att‚nuation en sortie gauche=0
;	SOUNDCMD	1,0	;Att‚nuation en sortie droite=0
;	SOUNDCMD	2,0	;Gain gauche=0
;	SOUNDCMD	3,0	;Gain droit=0
	SOUNDCMD	4,%11	;Additionneur 16 bits prend ses donnees
			;de la matrice ET de l'ADC
	SOUNDCMD	5,3	;fixe l'entr‚e de l'ADC sur les voies
			;gauches et droites du PSG.
	SOUNDCMD	6,3	;SETPRESCALE sur 50Khz STE
	;DEVCONNECT	3,8,0,0
	DEVCONNECT	0,8,0,0
	
.pcm_frq	move.w	#1,-(sp)		;Voil…, on a remis le son
	clr.l	-(sp)		;dans un ‚tat correct.
	pea	8.w		;
	move.w	#$8b,-(sp)	;Snd_DevConnect
	trap	#14
	lea.l	$c(sp),sp

	move.w	#$81,-(sp)		;Snd_Unlock On libŠre tout le monde
	trap	#14
	addq.l	#2,sp
	move.w	#$69,-(sp)		;Dsp_Unlock
	trap	#14
	addq.l	#2,sp

	bsr.s	BP_Bidouille	
	move.l	Bloc_Adr,-(sp)	;libŠre bloc
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr.s	BP_Bidouille

	bra	User_Stack

;****************************************************
;Cookie: en d0: le Cookie a trouver. POSSIBILITE de
;               chercher le Cookie NUL !
;sortie: en d1: le num‚ro du cookie (ou nbre de cookie 0);
;        en a0: pointe le cookie ou le cookie 0
;        en d0: le cookie trouv‚
;        en d3: la valeur du cookie
;****************************************************
Cookie:	
	move.l	$5a0.w,a0
	move.l	d2,-(sp)
	moveq	#0,d1
.s:	movem.l	(a0)+,d2-d3
	addq.w	#1,d1
	cmp.l	d2,d0		;trouv‚ ?
	beq.s	.found
	tst.l	d2		;encore libre ?
	bne.s	.s
	move.l	d3,d1
	moveq	#0,d0
.found:	subq.l	#8,a0
	move.l	(sp)+,d2
	rts

;****************************************************
; Bidouille de la basepage pour que le m‚chant
; Gemdos ne nous confisque pas notre bloc
; DŠs qu'on a le (MS)dos tourn‚ ...
;****************************************************
BP_Bidouille
	movem.l	d0-d1/a0-a2,-(sp)
	lea.l	S_run(pc),a0
;en a0: zone de sauvegarde de 132 octets.
	lea	$51e.w,a1		;adresse new basepage
	move.l	a1,a2
	move.w	#$2700,sr		;pas b“ mais indispensable
	moveq	#32-1,d0
.loop:	move.l	(a0),d1		;echange ...
	move.l	(a1),(a0)+
	move.l	d1,(a1)+
	dbf	d0,.loop
	move.l	$4f2.w,a1
	move.l	40(a1),a1		;a1=_run
	cmp.l	(a1),a2		;basepage = zone de sauvegarde ?
	beq.s	.same
	move.l	(a1),(a0)+	;sauve vraie basepage
	move.l	a2,(a1)		;fause basepage install‚e
.end:	movem.l	(sp)+,d0-d1/a0-a2
	rts
.same:	move.l	(a0)+,(a1)	;remet vraie basepage
	move.w	#$2300,sr		;r‚autorise BIOS
	movem.l	(sp)+,d0-d1/a0-a2
	rts
	
Hz50_IT_CPU:
	move.w	d0,-(sp)
	move.w	$ffff82a0.w,d0
	jsr	([Bloc_Adr,pc],dsp_play+12)	;sucrerie 68030
	sub.w	$ffff82a0.w,d0
	neg.w	d0
	move.w	d0,CPU
	move.w	(sp)+,d0
	rte

Depack_All equ	*+28
	incbin	"depack.pc"
	even

adsp_play	incbin	"dsp_play.bin"
adsp_play_end equ *
adsp_len	equ	adsp_play_end-adsp_play

	SECTION	BSS
CPU:		ds.w	1	;nombre de lignes used
Com_Len		ds.w	1
mod_name:		ds.b	128
Buf:
S_run:		ds.b	134
STACK:		ds.l	1
Bloc_Adr		ds.l	1	;adresse du bloc malloqu‚
dsp_locked	ds.b	1
resident		ds.b	1	;0->non r‚sident (buffer)
		ds.b	1	;0->non r‚sident (constant)
auto_resident	ds.b	1	;<>0 --> auto resident
buf_aff:		ds.b	20

; STRUCTURE SAUVEE DANS LE BLOC
	rsreset
Bloc_Len		rs.l	1
Mod_Len		rs.l	1	;longueur module
V_TD		rs.l	1
VR		rs.b	1
		rs.b 1
title		rs.b	20
name		rs.b	14
combuf:		rs.w	15+16
it_50hz		rs.l	1
		rs.b	28
dsp_play		rs.b	adsp_len-28
buf		rs.b	3204
module		rs.b	0
Save_SizeOf	rs.b	0

	SECTION	TEXT
PP20	movem.l	d0-a6,-(sp)
	lea	$100(a0),a3
	move.l	a0,a5
	adda.l	d0,a0
	cmpi.l	#'PP20',(a5)+
	bne.w	.abort
	moveq	#3,d6
	moveq	#7,d7
	moveq	#1,d5
	movea.l	a3,a2
	move.l	-(a0),d1
	tst.b	d1
	beq.s	.pp_0
	bsr.s	.pp_4
	subq.b	#1,d1
	lsr.l	d1,d5
.pp_0	lsr.l	#8,d1
	adda.l	d1,a3
	move.l	d1,(sp)
	lea	BufAtm+260(pc),a6
	moveq	#63,d0
	move.l	-(a3),-(a6)
	dbf	d0,*-2
	move.l	a3,-(a6)
	lea	$100(a3),a3

.pp_1	bsr.s	.pp_4
	bcs.s	.pp_11
	moveq	#0,d2
.pp_2	moveq	#1,d0
	bsr.s	.pp_7
	add.w	d1,d2
	cmp.w	d6,d1
	beq.s	.pp_2
.pp_3	moveq	#7,d0
	bsr.s	.pp_7
	move.b	d1,-(a3)
	dbf 	d2,.pp_3
	cmpa.l	a3,a2
	bcc.s	.pp_17

.pp_11	moveq	#1,d0
	bsr.s	.pp_7
	moveq	#0,d0
	move.b	(a5,d1.w),d0
	move.w	d1,d2
	cmp.w	d6,d2
	bne.s	.pp_14
	bsr.s	.pp_4
	bcs.s	.pp_12
	moveq	#7,d0
.pp_12	bsr.s	.pp_6
	move.w	d1,d3
.pp_13	moveq	#2,d0
	bsr.s	.pp_7
	add.w	d1,d2
	cmp.w	d7,d1
	beq.s	.pp_13
	bra.s	.pp_15

.pp_4	lsr.l	#1,d5
	beq.s	.pp_5
	rts  	

.pp_5	move.l	-(a0),d5
	roxr.l	#1,d5
	rts  	

.pp_6	subq.w	#1,d0
.pp_7	moveq	#0,d1
.pp_8	lsr.l	#1,d5
	beq.s	.pp_10
	addx.l	d1,d1
	dbf 	d0,.pp_8
	rts  	
.pp_10	move.l	-(a0),d5
	roxr.l	#1,d5
	addx.l	d1,d1
	dbf 	d0,.pp_8
	rts  	

.pp_14	bsr.s	.pp_6
	move.w	d1,d3
.pp_15	addq.w	#1,d2
.pp_16	move.b	(a3,d3.w),-(a3)
	dbf 	d2,.pp_16
	cmpa.l	a3,a2
	bcs.s	.pp_1
.pp_17	lea	-$100(a2),a1
	move.l	$104(sp),d0
	lsr.l	#3,d0
.pp_18	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	subq.l	#1,d0
	bcc.s	.pp_18
	lea	BufAtm(pc),a6
	move.l	(a6)+,a3
	moveq	#63,d0
	move.l	(a6)+,(a3)+
	dbf	d0,*-2
	moveq	#0,d0
.abort	movem.l	(sp)+,d0-a6
	rts

Sentry2_0	movem.l	d0-a6,-(sp)
	move.l	a0,a3
	lea	(a0,d0.l),a0
	moveq	#8,d6
	bsr	get_long
	cmpi.l	#'.tnS',d0
	beq.s	.unpack
	movem.l	(sp)+,d0-a6
	rts
.unpack	bsr	get_long		;
	move.l	d0,(sp)		; save depack len
	lea	(a3,d0.l),a2	; dest adres
	move.l	a2,a5		; save for picture depack
	bsr	get_long
	moveq	#0,d1
	add.l	d0,d0
	addx.w	d1,d1
	move.w	d1,unp_pic
	moveq	#0,d1
	add.l	d0,d0
	addx.w	d1,d1
	move.w	d1,unp_sam
	bne.s	.no_sam
	move.l	d0,-(sp)
	bsr	get_long
	move.l	d0,samoff+4
	bsr	get_long
	move.l	d0,samoff
	move.l	(sp)+,d0
.no_sam	bsr.s	unp_loop	; unpack data
	tst	unp_pic
	bne.s	.no_pic
	bsr	unp_picture
.no_pic	tst	unp_sam
	bne.s	.no_mod
	bsr	samples
.no_mod	movem.l	(sp)+,d0-a6
	rts

unp_loop
	bsr.s	.getbit
.cont	bcs.s   .blocks
	bsr.s	.getbit
	bcs.s	.copy_2
	move.b	-(a0),-(a2)	; 1 byte copy
	bra	l_col
.copy_2	bsr.s	.getbit
	bcs.s	.c_more
	moveq	#1,d2		; copy 2 bytes
	bra.s	.copy
.c_more	lea	copy_tab(pc),a4
.c_loop	move.l	(a4)+,d1
	bsr.s	.getbyte		; haal aantal
	subq.w	#1,d2
	bpl.s	.found
	bra.s	.c_loop
.found	swap	d1
	add.w	d1,d2

.copy	move.b	-(a0),-(a2)
	dbf	d2,.copy
	bra	l_col

.get_off
	MOVEQ	#1,D1		;OFFSET
	BSR.S	.getbyte
	move.b	(a4,d2),d1	; bits
	ADD.W	D2,D2
	ext.w	d1
	move.w	4(a4,d2),d4
	bsr.s	.getbyte
	add.w	d4,d2
	rts
.getbit	add.l	d0,d0	;LSR.L	#1,D0
	beq.s	.haha
	rts
.haha	bsr.s	get_long
	addx.l	d0,d0	;ROXR.L  #1,D0
	rts
.haha1	bsr.s	get_long
	addx.l	d0,d0	;ROXR.L  #1,D0
	bra.s	.getbyt
.getbyte
	CLR.W   D2
.loop	add.l	d0,d0	;LSR.L	#1,D0
	beq.s	.haha1
.getbyt	addx.L  d2,D2 
	DBF     D1,.loop
	RTS

.blocks	bsr.s	.getbit
	bcs.s	.string3
	moveq	#1,d3		; 2 bytes-string
	moveq	#8-1,d1	; small-bits-offset
	bra.s	.string_copy
.string3
	lea	small_offset(pc),a4
	bsr.s	.getbit
	bcs.s	.string_more
	moveq	#2,d3		; 3 bytes-string
	bra.s	.do_strings
.string_more
	moveq	#1,d1		; 2 bits-commando
	bsr.s	.getbyte
	subq.w	#1,d2		; large string?
	bmi.s	.large
	moveq	#3,d3		; minimaal 4 bytes-string
	add.w	d2,d3		; meer?
	bra.s	.do_strings
.large	lea	aantal_tab(pc),a4
	bsr.s	.get_off
	move.w	d2,d3
	lea	offset_tab(pc),a4
.do_strings
	bsr.s	.get_off
	bra.s	.s_copy
.string_copy
	bsr.s	.getbyte
.s_copy	move.b	-1(a2,d2.w),-(a2) 
	dbf	d3,.s_copy

l_col	cmpa.l	a2,a3 
	blt	unp_loop
ex_unp	RTS
get_long
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	lsl.l	d6,d0
	move.b	-(a0),d0
	move.w	#$10,ccr
	rts
samples	lea	samoff(pc),a1
	move.l	a3,a0		; source adres
	add.l	(a1)+,a0
	move.l	(a1),d0
	lea	(a0,d0.l),a2
.loop	move.b	(a0)+,d0
	sub.b	d0,(a0)
	neg.b	(a0)
	cmp.l	a2,a0
	blt.s	.loop
	rts
unp_picture
.low	move.w	#$0f9f,d7
snt2_01	moveq	#3,d6
snt2_02	move.w	-(a5),d4
	moveq	#3,d5
snt2_03	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,snt2_03
	dbra	d6,snt2_02
	movem.w d0-d3,(a5)
	dbra	d7,snt2_01
	rts
samoff	dc.l	0,0
unp_pic	dc.w	0
unp_sam	dc.w	0
offset_tab
	dc.b	5-1,8-1,9-1,13-1
	dc.w	2,2+32,2+32+256,2+32+256+512
aantal_tab
	dc.b	2-1,3-1,5-1,9-1
	dc.w	6,6+4,6+4+8,6+4+8+32
small_offset
	dc.b	4-1,5-1,7-1,9-1
	dc.w	2,2+16,2+16+32,2+16+32+128
copy_tab
	dc.w	2,1
	dc.w	5,2
	dc.w	12,3
	dc.w	27,4

	SECTION	BSS
BufAtm:	ds.l	907-108+1		;Buffer indispensable

	SECTIOn	TEXT
