;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                 Modificateur de modules .MOD->.NTK                    ;
;                          (Version IV.4)                               ;
;                (C)oderight NulloS//DNT-Crew 1991-94                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include	dsp_play.inc

	SECTION	TEXT
print	MACRO
	pea	\1
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	opt	o+

start	dc.w	$a00a		;coupe souris
	move.l	a7,a5		;
	move.l	4(a5),a5		;
	move.l	$c(a5),d0		;
	add.l	$14(a5),d0		;
	add.l	$1c(a5),d0		;
	add.l	#4096,d0		;
	move.l	d0,d1		;
	add.l	a5,d1		;
	and.w	#-2,d1		;
	move.l	d1,a7		;
	move.l	d0,-(sp)		;
	move.l	a5,-(sp)		;
	clr.w	-(sp)		;
	move.w	#$4a,-(sp)		;Mshrink habituel
	trap	#1		;
	lea	12(sp),sp		;
	clr.l	-(sp)		;
	move.w	#$20,-(sp)		;
	trap	#1		;petit coup de superviseur
	move.l	d0,2(sp)		;

	print	present(pc)	;
	pea	dta(pc)		;
	move.w	#$1a,-(sp)		;
	trap	#1		;Fixe le buffer DTA
	addq.l	#6,sp		;
	move.b	#100,nom1-2	;pr‚pare les longueurs
	move.b	#100,nom2-2	;de chaine.

kelmod	print	demande1(pc)	;
	pea	nom1-2(pc)		;
	move.w	#$0a,-(sp)		;
	trap	#1		;Input sourcename
	addq.l	#6,sp		;
	clr.w	-(sp)		;
	pea	nom1(pc)		;
	move.w	#$4e,-(sp)		;
	trap	#1		;Cherche le fichier
	addq.l	#8,sp		;
	tst.l	d0		;problŠme ?
	beq.s	okmod		;non,ca roule
	cmp.l	#"END!",nom1	;cassos ?
	bne.s	kelmod		;
	beq	the_end		;
okmod	move.l	dta+26(pc),d0	;Taille du fichier
	move.l	d0,mod_long	;on conserve
	move.l	d0,d1		;par d‚faut: ntk=5/4*mod
	lsl.l	#2,d1		;
	add.l	d1,d0		;
	lsr.l	#2,d0		;
	move.l	d0,ntk_long	;
	move.l	mod_long(pc),-(sp)	;Malloc la place du mod
	move.w	#$48,-(sp)		;
	trap	#1		;
	move.l	d0,anc_mod		;
	ble	the_end		;oula !
	move.l	ntk_long(pc),-(sp)	;et celle du ntk
	move.w	#$48,-(sp)		;
	trap	#1		;
	lea	12(sp),sp		;
	move.l	d0,new_mod		;
	ble	the_end		;gasp..


kelntk
	print	demande2(pc)	;le nom du fichier de
	pea	nom2-2(pc)		;sortie..
	move.w	#$0a,-(sp)		;
	trap	#1		;
	addq.l	#6,sp		;

load_mod	print	mess4(pc)		;"loading.."
	clr.w	-(sp)		;
	pea	nom1(pc)		;
	move.w	#$3d,-(sp)		;ouverture du fichier
	trap	#1		;source
	addq.l	#8,sp		;
	move.w	d0,handle		;
	ble.s	the_end		;
	move.l	anc_mod(pc),-(sp)	;
	move.l	mod_long(pc),-(sp)	;charge-le
	move.w	d0,-(sp)		;
	move.w	#$3f,-(sp)		;
	trap	#1		;
	lea	12(sp),sp		;
	move.w	handle(pc),-(sp)	;fermeture
	move.w	#$3e,-(sp)		;
	trap	#1		;
	addq.l	#4,sp		;
	bsr.s	transforme_module	;transformation
				;->D7=taille module NTK4
save_ntk	print	mess5(pc)		;
	clr.w	-(sp)		;
	pea	nom2(pc)		;
	move.w	#$3c,-(sp)		;Ouvre la destination
	trap	#1		;
	addq.l	#8,sp		;
	move.w	d0,handle		;
	ble.s	the_end		;
	move.l	new_mod(pc),-(sp)	;
	move.l	d7,-(sp)		;‚crire la totalit‚
	move.w	d0,-(sp)		;
	move.w	#$40,-(sp)		;
	trap	#1		;
	lea	12(sp),sp		;
	move.w	handle(pc),-(sp)	;
	move.w	#$3e,-(sp)		;
	trap	#1		;
	addq.l	#4,sp		;
	bsr	AffCompt		;

the_end	trap	#1
	addq.l	#6,sp
	bsr.s	libere_memoire
	print	mess3(pc)
	move.w	#7,-(sp)
	trap	#1
	dc.w	$a009
	clr.w	(sp)
	trap	#1

libere_memoire
	move.l	anc_mod(pc),-(sp)
	move.w	#$49,-(sp)
	trap	#1
	move.l	new_mod(pc),-(sp)
	move.w	#$49,-(sp)
	trap	#1
	lea	12(sp),sp
	rts
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
ANC_spl	rs.b	0	;taille du header de sample
	RSRESET
NEW_START	rs.l	1	;offset de d‚but&fin de sample par
NEW_END	rs.l	1	;rapport au d‚but du module .ntk
NEW_RLN	rs.l	1	;longueur du repeat
NEW_VOL	rs.w	1	;volume
NEW_FTUN	rs.w	1	;finetune
NEW_spl	rs.b	0	;

;ATTENTION: VARIABLE DEFINIE DANS DSP_PLAY.INC !!
;ADD_SPL	equ	664+8	;avanc‚e maximale dans un sample en 1 VBL
;			;+ s‚curit‚ de 8 pour le player DSP
;La note la plus haute est 108 ($71=113 plus finetune->108).
;Donc 664=(1/2.79365E-7)/(108*50).
;Pas besoin de changer pour 60Hz ou 71Hz (car alors ADD_SPL est plus petit,
;donc la version 50Hz convient).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
transforme_module			;Effectue la convertion
	bsr.s	extract_infos	;analyse le module
	bsr	copie_partition	;copier les pattern+sequence
	bsr	bidouille_sample	;modifie les samples
	rts			;En sortie,D7=taille NTK4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Analyse le module, pour savoir s'il possŠde 15 ou 31 instruments, combien
;de patterns, longueur et bouclage de la s‚quence, et enfin pour ‚tablir le
;tableau des instruments (qui peuvent avoir des num‚ros ‚parpill‚s, avec
;des num‚ros non-utilis‚s, on va donc les regrouper).
extract_infos
	print	mess1(pc)
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
	moveq	#0,d1		;
	subq.w	#1,d0		;a cause du dbf...
z2	cmp.b	(a0)+,d1		;trouve le No maximal pour
	bge.s	z3		;les pattern
	move.b	-1(a0),d1		;
z3	dbf	d0,z2		;
	move.w	d1,pat_max		;stocke resultat
	addq.w	#1,d1		;
	mulu.w	#1024,d1		;en profite pour avoir la taille
	addi.l	#4+2+128,d1	;des datas de partitions du
	move.l	d1,new_size1	;NTK4.

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
	lea	ANC_spl(a1),a1	;instrument suivant
	dbf	d0,z4		;voil… c'est fait.
	lsl.w	#4,d1		;
	move.l	d1,new_size2	;taille des infos sample
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Recopier la partition en changeant les num‚ros d'instrument pour les
;regrouper, et en modifiant le codage de ces num‚ros dans la partition.
copie_partition
	lea	combuf(pc),a3	;pour comptabiliser...
	moveq	#15+16-1,d3	;on commence par effacer
	clr.w	(a3)+		;
	dbf	d3,*-2		;

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
	move.w	pat_max(pc),d0	;Prendre taille prise
	addq.w	#1,d0		;par les patterns
	lsl.l	#8,d0		;*1024 (/4 pour le nb de notes)
	lea	instr_exg(pc),a2	;pour changer No instruments
	move.l	anc_mod(pc),a0	;
	adda.w	anc_part(pc),a0	;on va sur les patterns
	move.l	#$1000f000,d4	;masque pour l'instrument
	move.l	#$07ff0fff,d5	;avant et aprŠs
	lea	combuf(pc),a3	;pour comptabiliser...

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


AffCompt	print	stat(pc)		;
	lea	combuf(pc),a3	;
	lea	list(pc),a4	;
	lea	.AC_poscur(pc),a5	;
	moveq	#32+0,d7		;
	moveq	#14,d5		;15 commandes d'abord
	moveq	#1,d4		;2 groupes
.AC_0	moveq	#32+3,d6		;coords de d‚part
.AC_1	move.b	d6,2(a5)		;
	move.b	d7,3(a5)		;
	print	(a5)		;
	print	(a4)		;
	lea	msize(a4),a4	;
	moveq	#3,d2		;4 chiffres
	moveq	#0,d3		;
	move.w	(a3)+,d3		;
	lea	nom2(pc),a2	;pour travailler (nom1 n'est
	clr.b	-(a2)		;
.AC_2	divu	#10,d3		;plus utile !)
	swap	d3		;
	addi.b	#"0",d3		;
	move.b	d3,-(a2)		;
	clr.w	d3		;
	swap	d3		;
	dbf	d2,.AC_2		;
	print	(a2)		;
	addq.w	#1,d6		;une ligne plus bas
	dbf	d5,.AC_1		;suivant
	moveq	#32+40,d7		;deuxiŠme banc..
	moveq	#15,d5		;les commandes E
	dbf	d4,.AC_0		;
	rts
	


.AC_poscur	dc.b	27,'Y',0,0,0
	EVEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;On triture les samples, afin de leur rajouter ce qu'il faut sur leur fin
;pour faire sauter les tests du mixage.
bidouille_sample
	print	mess2
	move.l	anc_mod(pc),a0
	move.l	new_mod(pc),a1
	movea.l	a0,a2
	movea.l	a1,a3
	lea	20(a0),a0
	move.l	new_size1(pc),d7	;offset NEW_START du 1er
	add.l	new_size2(pc),d7	;sample.
	adda.l	d7,a3		;se place sur les futurs samples
	move.w	pat_max(pc),d0	;nb de pattern
	addq.w	#1,d0		;
	mulu.w	#1024,d0		;*1024 pour taille
	adda.l	d0,a2		;on se place aprŠs
	adda.w	anc_part(pc),a2	;donc sur les samples
	move.w	nb_instr(pc),d6	;compteur de samples

bs_bcl0	moveq	#0,d0		;annule bits forts
	move.w	ANC_LEN(a0),d0	;longueur du sample (en mots)
	bne.s	bs_1		;nulle ?
bs_bcl0_end
	lea	ANC_spl(a0),a0	;sample suivant
	dbf	d6,bs_bcl0		;
	rts			;

bs_1	add.l	d0,d0		;longueur en octets
	moveq	#0,d1		;
	move.b	ANC_VOL(a0),d1	;ANC_VOL={finetune.b|volume.b}
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
	lsr.w	#1,d0		;nb mots (.w<=0..65535 octets)
	subq.w	#1,d0		;corrige dbf
bs_bcl1	move.w	(a2)+,(a3)+	;mot-…-mot de sample
	dbf	d0,bs_bcl1		;recopier
	move.b	-1(a3),d0		;rajoute la derniŠre valeure
	lsl.w	#8,d0		;
	move.b	-1(a3),d0		;(toujours un mot !)
	move.w	#ADD_SPL/2-1,d1	;pour que le sample coupe
bs_bcl2	move.w	d0,(a3)+		;en arrivant … la fin
	dbf	d1,bs_bcl2		;
	lea	NEW_spl(a1),a1	;sample (NTK) suivant
	addi.l	#ADD_SPL,d7	;position+le rajout
	bra.s	bs_bcl0_end	;


bs_repeat	movea.l	a2,a4		;registre de travail
	adda.l	d0,a2		;passe au sample suivant
	moveq	#0,d0		;
	move.w	ANC_RLN(a0),d0	;Taille du repeat
	add.l	d0,d0		;
	move.l	#ADD_SPL,d1	;compare la au bouclage
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
	
	lsr.w	#1,d2		;repasse en nb de mots
	subq.w	#1,d2		;.w car 0..65535->0..32767
bsr_bcl0	move.w	(a4)+,(a3)+	;mot-…-mot, copier corps du sample
	dbf	d2,bsr_bcl0	;(cad sans le repeat)
	move.l	a3,a5		;<<conserve repeat, dans NEW>>

bsr_bcl1	move.l	d0,d2		;Ensuite,recopie autant de
	lsr.w	#1,d2		;fois que necessaire le vieux
	subq.w	#1,d2		;ANC_RLN,pour construire le
bsr_bcl2	move.w	(a4)+,(a3)+	;nouveau NEW_RLN (qui est qqch
	dbf	d2,bsr_bcl2	;du style n*ANC_RLN)
	movea.l	a5,a4		;Revient d‚but repeat
	sub.l	d0,d1		;NEW_RLN-=ANC_RLN
	bgt.s	bsr_bcl1		;NEW_RLN-n*ANC_RLN ?
	move.w	#ADD_SPL/2-1,d0	;On a fini,on garnit donc la
bsr_bcl3	move.w	(a5)+,(a3)+	;fin, depuis NEW_SPL car on peut
	dbf	d0,bsr_bcl3	;avoir modifi‚ le repeat length.

	lea	NEW_spl(a1),a1	;Sample suivant...
	addi.l	#ADD_SPL,d7	;...en offset adresse aussi.
	bra	bs_bcl0_end	;Goto Next Until End Quit (!)
;Nb:en cas de nouveau RLN (donc si ANC_RLN<ADD_SPL), comme NEW_RLN est
;un multiple de ANC_RLN (vu que mulu d0,d1),et que ANC_RLN est un nombre
;de mots (parit‚ en octets), alors NEW_RLN est aussi pair. Donc les copies
;mot-…-mot sont valables pour tous les RLN.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	DATA
present	dc.b	27,"E+----------------------------------------------------+",$d,$a
	dc.b	"! Programme de transfert SoundTracker=>NullosTracker !",$d,$a
	dc.b	"+----------------------------------------------------+",$d,$a
	dc.b	"!             ==>  V4.4 (c)Nullos94  <==             !",$d,$a
	dc.b	"+----------------------------------------------------+",$d,$a
	dc.b	"!          [Control]+C ou END! pour quitter          !",$d,$a
	dc.b	"+----------------------------------------------------+",$d,$a,$a,$a,0,0
demande1	dc.b	$d,$a,$a,"Entrez le nom du module … modifier...:",0
demande2	dc.b	$d,$a,"Entrez le nom du nouveau module......:",0
mess4	dc.b	$d,$a,"Chargement du module...",0
mess1	dc.b	$d,$a,"Conversion de la partition en cours...",0
mess2	dc.b	$d,$a,"Conversion des instruments en cours...",0
mess5	dc.b	$d,$a,"Sauvegarde du module...",$d,$a,0
stat	dc.b	27,"EStatistique des commandes rencontr‚es:",0

list	dc.b	"0 -Arpeggio..............: ",0
	dc.b	"1 -Portamento Up.........: ",0
	dc.b	"2 -Portamento Down.......: ",0
	dc.b	"3 -Tone Portamento.......: ",0
	dc.b	"4 -Vibrato...............: ",0
	dc.b	"5 -TonePorta+Volume Slide: ",0
	dc.b	"6 -Vibrato+Volume SLide..: ",0
	dc.b	"7 -Tremolo...............: ",0
	dc.b	"8 -Inexistant............: ",0
	dc.b	"9 -Sample Offset.........: ",0
	dc.b	"A -Volume Slide..........: ",0
	dc.b	"B -Position Jump.........: ",0
	dc.b	"C -Set Volume............: ",0
	dc.b	"D -Pattern Break.........: ",0
	dc.b	"F -Set Speed.............: ",0
	dc.b	"E0-Set Filter............: ",0
	dc.b	"E1-Fine Portamento Up....: ",0
	dc.b	"E2-Fine Portamento Down..: ",0
	dc.b	"E3-Set Glissando.........: ",0
	dc.b	"E4-Set Vibrato Waveforme.: ",0
	dc.b	"E5-Set FineTune..........: ",0
	dc.b	"E6-Set Loop Control......: ",0
	dc.b	"E7-Set Tremolo Waveform..: ",0
	dc.b	"E8-Song Stop.............: ",0
	dc.b	"E9-Rettrig Sample........: ",0
	dc.b	"EA-Fine Volume Slide Up..: ",0
	dc.b	"EB-Fine Volume Slide Down: ",0
	dc.b	"EC-Note Cut..............: ",0
	dc.b	"ED-Note Delay............: ",0
	dc.b	"EE-Pattern Delay.........: ",0
	dc.b	"EF-Funk It...............: ",0
msize	equ	28

mess3	dc.b	27,'Y',32+23,32+0
	dc.b	"Voila,c'est fini.A la prochaine...",$d,$a,0

	EVEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	BSS
mod_long	ds.l	1
ntk_long	ds.l	1
anc_mod	ds.l	1
new_mod	ds.l	1

	ds.w	1
nom1	ds.b	100
	ds.w	1
nom2	ds.b	100
dta	ds.b	44
handle	ds.w	1

combuf	ds.w	15+16

nb_instr	ds.w	1
instr_exg	ds.b	32
anc_seq	ds.w	1
anc_part	ds.w	1
pat_max	ds.w	1
sng_long	ds.w	1
new_size1	ds.l	1
new_size2	ds.l	1
song_repeat
	ds.b	1