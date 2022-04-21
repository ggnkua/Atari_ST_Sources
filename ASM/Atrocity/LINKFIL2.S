;THE Dma_link_file routine
;v2.0
;By Dr Clone/RADIATION
;parametres:
;d0=numero du fichier … lire (1..n) /n=nombre de fichiers ds le Link
;a0=adresse de chargement...............c'est tout!
;appel par trap #$4
;gestion du directory inclue 

trap_04	move	#$2700,sr	;inter bloqu‚es
	movem.l	d0-a6,-(a7)
	move.l	a0,a4		;sauve adresse
	move.l	a0,-(a7)	;pour le decompactage
	
	movea.w	#$8604,a0	;$ffff8604-->a0
	lea	2(a0),a2	;$ffff8606-->a2
	bsr	set_dma		;met en place l'adr

	moveq	#0,d1
	moveq	#1,d3		;secteur 1
	moveq	#0,d4
	moveq	#1,d5		;face 1
	bsr	select		;select une face
	
	moveq	#$1,d2		;restore
	bsr	send_command
	bsr	read_a_sector	;lit le boot
	
	move.b	$10(a3),d6	;nb fats
	move.b	$16(a3),d4	;nb sec/fats
	mulu	d4,d6		;
	add.b	$e(a3),d6	;+sec reserved=start sector du directory

	move.b	$18(a3),d1
	addq.w	#1,d1		;nb sec/piste
	bsr	go_on		;on se place sur le 1er secteur du directory
		
	move.b	$12(a3),d7
	rol.l	#8,d7
	move.b	$11(a3),d7	;nb dir entry
	lsr.l	#4,d7		;d7=nb sec/directory
	move	d7,-(a7)	;sur la pile
	
r_dir	bsr	set_dma
	bsr	read_a_sector	;lit secteur dir
	subq.w	#1,(a7)		;secteur restant 
	bmi.s	error_disk	;negatif??
	bsr	fucking_calc
	moveq	#$f,d6		;16 noms par secteur
search_in_dis
	cmpi.l	#'DOC0',(a3)	;recherche le link file
	beq.s	found_the_file	;trouv‚!
	lea	$20(a3),a3	;prochain
	dbf	d6,search_in_dis
	bra.s	r_dir
error_disk
	illegal
found_the_file
	move.w	(a7)+,d6	;nb secteurs restant pour finir le directory
	
	moveq	#0,d4		;0
	move.b	27(a3),d4
	rol.l	#8,d4
	move.b	26(a3),d4	;no de cluster de depart du linkfile
	subq.w	#2,d4		;-2 
	add.w	d4,d4		;*2 = nb secteurs
	add.w	d4,d6		;+secteurs restant
	beq.s	pas_la_peine
	
	bsr	go_on		;place sur link
pas_la_peine
	bsr	set_dma
	
boucle	bsr	read_a_sector	;lit le 1er secteur
	lea	$200(a3),a3	;adr + 512
	subq.w	#1,d0		;decremente
	bmi.s	read_file	;negatif alors on peut lire
	bsr	get_size	;recherche 'ATM5' et la taille de ce fichier ds le secteur
	tst.w	d0		;nul?alors c'est le fichier … charger
	bne.s	pas_0		;pas 0 
	adda.l	a4,a5		;taille+adr = adr de fin
trans	move.b	(a1)+,(a4)+	;transfert … la bonne adresse
	cmp.l	a1,a3		;teste si fin du secteur
	bne.s	trans		;non
	bsr	set_dma		;charge … la suite
	bra.s	read_file	;on peu lire
pas_0	bsr	set_dma		;refixe adresse
	bsr	put_it  	;pose la tete sur le prochain secteur Atomik
	bra.s	boucle		;bouclons..
read_file
	bsr	fucking_calc	;effectue les tests de chgts
	cmp.l	a3,a5		;a5-a3>0? test si on a tout lu
	bgt.s	boucle
	move.l	a0,a2		;dma mode
	move.l	(a7)+,a0	;recup adr
	bsr	depack		;decrunch
	move.l	a2,a0
motors	move.w	(a0),d0		;status
	btst	#7,d0		;motor on?
	bne.s	motors		;oui alors on attend
	moveq	#0,d5
	bsr	select		;deselectionne
	movem.l	(a7)+,d0-a6
	rte			;back to the meaning of life...
read_a_sector
	move.w	#$90,(a2)	;dma en lecture
	move.w	#$190,(a2)
	move.w	#$90,(a2)
	move.w	#1,(a0)		;1 secteur … la fois
	divu	d7,d7
	move.w	#$84,(a2)
	move	d3,(a0)		;ecrit secteur
	move.w	#$80,d2		;read a sector
	bsr	send_command
	rts
fucking_calc
	addq.w	#1,d3		;secteur + 1
	cmp.w	d3,d1		;test si dernier secteur
	bne.s	suite0		;non alors c bon
	moveq	#1,d3		;secteur 1
	neg.w	d5		;face=-face
	addq.w	#3,d5		;face 1 --> -1 -->2 / 2 --> -2 -->1
	bsr	select		;select
	cmpi.w	#1,d5		;face = 1?
	bne.s	suite0
	moveq	#$51,d2
	bsr	send_command	;step in
suite0	rts
get_size
	move.l	a4,a1		;adr de depart
get_0	cmpi.w	#'AT',(a1)+	;recherche au mot
	bne.s	get_0
	cmpi.w	#'M5',(a1)+	;2eme partie de la marque de compactage
	bne.s	get_0
	move.l	4(a1),d6	;nb bytes … lire
	btst	#0,d6		;taille paire??
	beq.s	ok_eve
	addq.l	#1,d6		;aligne au mot
ok_eve	move.l	d6,a5		;taille ds a5
	subq.l	#4,a1		;pointe sur les octets
	rts
send_command
	move.w	#$80,(a2)	;select command
	divu	d7,d7		;wait
	move.w	d2,(a0)		;send
waitfdc	btst	#5,$73fd(a0)
	bne.s	waitfdc		;wait fin de commande
	rts
set_dma	move.l	a4,d6		;adresse
	move.b	d6,9(a0)	;low byte
	lsr.l	#8,d6
	move.b	d6,7(a0)	;mid
	lsr.l	#8,d6
	move.b	d6,5(a0)	;high
	move.l	a4,a3		;adresse en cours
	rts
select	move	d5,d7		;face ds d7
	lea	side_value(pc),a6	;pointe sur les valeurs hexa
	lsl.l	#2,d7		;*4
	move.l	0(a6,d7.w),$1fc(a0)	;envoie la bonne valeur
	rts
side_value
	dc.l	$0e0e2727		;deselect
	dc.l	$0e0e2525		;side 1
	dc.l	$0e0e2424		;side 2
put_it
	moveq	#2,d7
	rol.l	#8,d7		;d7=$200
	move.l	a5,d6		;d6=taille
	divu	d7,d6		;d6/512 = nb secteurs
	swap	d6		;reste
	suba.l	a4,a1		;offset
	sub.w	a1,d7		;octet restant avant fin secteur
	cmp.w	d7,d6		;reste_div>=reste ?
	bge.s	not_in		;ds ce cas le prochain marqueur sera ds le secteur juste apres..
	swap	d6		;swap
	bra.s	go_on
not_in	swap	d6		;swap
	addq.w	#1,d6		;+1
go_on	moveq	#0,d7		;sector count
seeking	move.w	d7,-(a7)	;sauve
	bsr	fucking_calc	;on simule la lecture du secteur
	move.w	(a7)+,d7
	addq.w	#1,d7		;+1
	cmp.w	d7,d6		;all 'read' ?
	bne.s	seeking		;non ,on continue
	rts

MODE:	EQU	1
PIC_ALGO:	EQU	0
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	1

depack:	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	MODE
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	MODE
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	RESTORE_SPACE
buff_marg:	dcb.b	$90+DEC_SPACE+$C
	endc
	end

