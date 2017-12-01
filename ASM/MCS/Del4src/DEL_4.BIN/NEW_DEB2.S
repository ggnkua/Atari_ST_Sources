boot	
	move.w	#$2700,sr

	move.b	#$03,$fffffc00.w
	move.b	#$96,$fffffc00.w
	move.b	#$12,$fffffc02.w

	lea	deb_dma(pc),a0
	lea	fin_dma(pc),a1
	lea	$140.w,a2
reloc_dma
	move.l	(a0)+,(a2)+
	cmp.l	a0,a1
	bge.s	reloc_dma
	
	lea	deb_load(pc),a0
	lea	fin_load(pc),a1
	lea	$500.w,a2
reloc_load
	move.l	(a0)+,(a2)+
	cmp.l	a0,a1
	bge.s	reloc_load
	jmp	$500.w
deb_dma

read_one_sec
	bsr.s	read_sector
	addq	#1,d1
	lea	512(a1),a1
	cmp.w	#$b,d1
	bne.s	go_on
	addq	#1,d0
	moveq	#1,d1
	bsr.s	stepin
go_on
	dbra	d2,read_one_sec
	rts
;***********************  Restore FDC ****************************

RESTORE:

                move.w  #$80,$FFFF8606.W  ; S‚lection du Command-Reg.
                move.w  #1,D7		; Command => Restore
                bsr   WRT1772         ; Envoi de la commande
                bsr   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                rts

;***********************  SEEK TRACK  ****************************

SEEK_TRACK:

                move.w  #$86,$FFFF8606.W  ; S‚lection du registre de donn‚es
                move.w  D0,D7           ; Tracknr. dans d7
                bsr   WRT1772         ; Ecrire Tracknr.
                move.w  #$80,$FFFF8606.W  ; S‚lection du Command-Reg.
                move.w  #$11,D7         ; Command => Seek
                bsr   WRT1772         ; Ecrire commande
                bsr   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                rts

;*************************  Step in  *****************************

STEPIN:

                move.w  #$80,$FFFF8606.W  ; S‚lection du FDC-Commandreg.
                move.w  #$51,D7 	; Command => Step in
                bsr   WRT1772         ; Ecrire commande
                bsr   FDCWAIT         ; Attente jusqu'… ce que FDC soit prˆt
                rts

;***********************  Force Interrupt  ***********************

FORCE:
                move.w  #$D0,D7  ; Command => Force Interrupt
                bsr   WRT1772         ; Ecrire commande
                move.w  #$0100,D7       ; Boucle de temporisation
WTFRC:
                dbra    D7,WTFRC
                rts

;*********************  READ SECTOR(S)  **************************

READ_SECTOR:

                move.l  A1,D7           ; DMA-Adress sur tampon de secteur
                bsr.s   SETDMA

      MOVE.W  #$90,$FF8606
      MOVE.W  #$190,$FF8606
      MOVE.W  #$90,$FF8606
      MOVE.W  #1,$FF8604		* rajoute
      MOVE.W  #$80,$FF8606
      MOVE.W  #$80,$FF8604

                move.w  #$84,$FFFF8606.W  ; S‚lectionner Sector-Reg.
                move.w  D1,D7           ; Sektor-Nr. dans d7
                bsr.s   WRT1772         ; Ecrire Sektor-Nr.

                move.w  #$80,$FFFF8606.W  ; S‚lection du Command-Reg.
                move.w  #$84,D7         ; Command => Read multiple Sectors
                bsr.s     WRT1772         ; Ecrire commande

                bsr.s   FDCWAIT         ; attente jusqu'… ce que FDC soit prˆt
                rts

;********************  Set DMA-Transfer Adress  *****************

SETDMA:

	lea	add_deb(pc),a6
                move.l  D7,(a6)       ; Mettre Start-Adress dans FDC-Array
                move.b  D7,$FFFF860D.W       ; Ecrire d'abord  Low-Byte
                lsr.l   #8,D7
                move.b  D7,$FFFF860B.W       ; puis Mid-Byte
                lsr.l   #8,D7
                move.b  D7,$FFFF8609.W      ; et enfin  High-Byte

                move.l  ADD_DEB(pc),D7       ; R‚cup‚ration de la Start-Adress
                moveq   #0,D6
		move.w	#512,d6
                add.l   D6,D7           ; Addition des deux
	lea	add_fin(pc),a6
                move.l  D7,(a6)
                rts


;*****************    Ecriture du FDC-Register    *******************

WRT1772:

                bsr   WAIT
                move.w  D7,$FFFF8604.W      ; Ecrire FDC-Reg. ou DMA-Sectorcount
                bsr.s   WAIT
                rts

;*****************     Lecture du FDC-Register      ********************

READ1772:

                bsr.s   WAIT
                move.w  $FFFF8604.W,D5      ; Lire FDC-Reg. ou DMA-Sectorcount
                bsr.s   WAIT
                rts

;****************    Attente jusqu'… ce que FDC soit prˆt *****************

FDCWAIT:

                move.l  #$0180,D5       ; Attendre un peu jusqu'… ce Busy soit positionn‚
LITLWT:         dbra    D5,LITLWT
                move.l  #$040000,D5     ; d5 sert de compteur Timeout

READMFP         btst    #5,$FFFFFA01.W          ; Commande finie ?
                beq.s   FDCREADY        ; oui
                subq.l  #1,D5           ; non, D‚cr‚menter compteur Timeout
                beq.s   TIMEOUT         ; Si arriv‚ … la fin
                BRA.S   READMFP         ; non, Continuer le test
                move.b  $FFFF8609.W,ADD_FIN+1 ; C'est la  DMA-Endadress attendue
                move.b  $FFFF860B.W,ADD_FIN+2 ; d‚j… atteinte ?
                move.b  $FFFF860D.W,ADD_FIN+3
                move.l  ADD_FIN(pc),D7
                cmp.l   ADD_END(pc),D7
                blt.s   READMFP         ; non, continuer … tester
                bsr   FORCE           ; Si oui, interrompre la commande
                bra.s     FDCREADY        ; et quitter normalement la routine
TIMEOUT:
                move.w  $FFFF8604.W,D5      ; Lire l'‚tat avant l'interruption
                and.w   #$FF,D5         ; Masquer l'octet de poids fort
                lea	status(pc),a6
                move.w  D5,(a6)
                bsr   FORCE           ; ArrŠter la commande
		MOVEQ	#-1,D4		* PROBLEME
                rts
FDCREADY:
                move.w  $FFFF8604.W,D5      ; Lire l'‚tat
                and.w   #$FF,D5         ; Masquer l'octet de poids fort
                lea	status(pc),a6
                move.w  D5,(a6)
                rts

;*************************    Wait   *****************************

WAIT:
                move    SR,-(SP)        ; Sauvegarder Status
                move.w  #$20,D5         ; d5 sert de compteur
WT2:
                dbra    D5,WT2
                move    (SP)+,SR        ; R‚cup‚rer Status
                rts

;*****************  SELECTION DE LA FACE  *******************************

SETSIDE
      MOVE    SR,-(A7)
      ORI.W   #$700,SR
      MOVE.B  #$E,$FFFF8800.W
      MOVE.B  $FFFF8800.W,D7 
      CMP.B   #0,D3
      BNE.S   FACE1
      BSET    #0,D7
      BRA.S   O.K.
FACE1 BCLR    #0,D7
O.K.  MOVE.B  D7,$FFFF8802.W 
      MOVE    (A7)+,SR
      RTS 


;*****************  S‚lection du lecteur et de la piste  ****************

SETDRIVE:
                eori.b  #7,D2           ; Inverser les Bits pour le  Hardware
                and.b   #7,D2           ; Seuls les 3 Low-Bits sont modifi‚s
                move    SR,-(SP)        ; Sauvegarder Status
                ori     #$0700,SR       ; D‚sactiver Interruptions
                move.b  #$0E,$FFFF8800.W   ; S‚lectionner Port A du Sound-Chips
                move.b  $FFFF8800.W,D5     ; Lire Port A
                and.b   #$F8,D5         ; Effacer Bits 0-2
                or.b    D5,D2           ; Positionner nouveaux bits
                move.b  D2,$FFFF8802.W  ; Et ‚crire sur  Port A
                move    (SP)+,SR        ; restore Status
	bsr	RESTORE
                rts

;***************************** FIN ******************************
ADD_DEB		DC.L	0
ADD_FIN		DC.L	0
ADD_END		DC.L	0
STATUS		DC.W	0

fin_dma
***************** ICI *****************
deb_load
	jmp	suite_load(pc)
	nop

MODE:	EQU	1
PIC_ALGO:	EQU	0
DEC_SPACE:	EQU	$0	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	0

depack:	
	move.l	a0,-(sp)
	bsr	code_it
	move.l	(sp)+,a0
	movem.l	d0-a6,-(a7)
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
	bsr.s	copy_decrun
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
code_it
	lea	10(a0),a1
	move.l	a0,-(sp)
	bsr.s	decode
	move.l	(sp)+,a0
	move.l	8(a0),d0
	lea	12(a0),a0
	move.l	a0,a1
	add.l	d0,a1
	lea	$100(a1),a1
	bsr.s	decode
	rts
decode
	movem.l	zero(pc),d0-d7/a2-a6
	lea	crypt(pc),a3
	lea	fcrypt(pc),a4
crypt
	move.l	(a0),d1
	move.l	(a3)+,d0
	eor.l	d0,d1
	move.l	d1,(a0)+
	cmp.l	a4,a3
	ble.s	pas_fcrypt
	lea	crypt(pc),a3
pas_fcrypt
	cmp.l	a0,a1
	bge.s	crypt
	rts
fcrypt
zero	dcb.l	16,0

suite_load
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	lea	reset_vbl(pc),a0
	move.l	a0,$70.w
	move.w	#$2300,sr

	stop	#$2300

	moveq	#6,d6		* reset shifter
	move.l	d6,d4
reset_shifter
	move.b	#1,$ffff8260.w	* moyenne
	stop	#$2300
	move.b	#0,$ffff8260.w	* basse
	stop	#$2300
	dbra	d6,reset_shifter
	move.b	#0,$ffff8260.w	* basse

	move.w	#$2700,sr
	lea	illeg(pc),a0
	move.l	a0,$10.w
	lea	my_vbl(pc),a0
	move.l	a0,$70.w
	lea	clavier(pc),a0
	move.l	a0,$118.w
	move.b	#$40,$fffffa09.w
	move.b	#$40,$fffffa15.w
	move.w	#$2300,sr
	stop	#$2300

	move.l	$42e.w,a0
	cmp.l	#$80000,a0
	beq.s	et_merde_un_520_st
	cmp.l	#$100000,a0
	beq.s	youpi_ya_un_mega

*********** plus d'un mega *********
***********     hi axel !  *********

	move.l	#$80000,$42e.w
	move.l	#$f8000,$436.w
	move.b	#$5,$424.w
	move.l	#$752019f3,$420.w
	move.l	#$a892,$432.w
	move.l	#$237698a,$43a.w

youpi_ya_un_mega

	move.l	#1,$c.w		* 1 si un meg ou plus
	bra.s	suite

et_merde_un_520_st
	move.l	#0,$c.w		* 0 si 520 (ou moins ??)
suite				* je vais tester si stf ou ste
	lea	$ffff8205.w,a0
	moveq	#-1,d1
	move.b	(a0),d0
	move.b	d1,(a0)
	cmp.b	(a0),d1
	bne.s	pas_ste
	move.b	d0,(a0)
	move.l	#1,$8.w
	bra.s	fin_test_stf_ste
pas_ste				* stf
	move.l	#0,$8.w
fin_test_stf_ste
	
*********** test nb lecteurs ***********

	move.w	$4a6.w,d0
	SUBQ	#1,D0
	move.w	d0,$20.w
	
************************ ICI ************************
***********  c'est tout pour les tests   ************
*********** maintenant on charge l'intro ************

	move.l	#$80000-8,a0
	tst.l	$c.w
	beq.s	pile_520
	move.l	#$f0000,a0
pile_520
	move.l	a0,sp		* installe ma pile !
	move.l	a0,$80.w

	lea	$1000.w,a0
	lea	$7f000,a1
	moveq	#0,d0
eff_all
	move.l	d0,(a0)+
	cmp.l	a0,a1
	bge.s	eff_all

	lea	$1000-28.w,a1
	moveq	#2,d2
	moveq	#0,d3
	jsr	$2e4.w		* set drive
	jsr	$2bc.w		* set side

	moveq	#15,d0
	jsr	$16e.w		* seek track

	moveq	#10,d1
	move.w	#293,d2
	jsr	$140.w		* read one sec

	lea	$1000-28.w,a0
	bsr	depack

	move.b	#$7,$ffff8201.w
	move.b	#$0,$ffff8203.w

	jmp	$1000.w

clr_col
	moveq	#0,d0
	moveq	#7,d7
	lea	$ffff8240.w,a0
eff_colors_after_intro
	move.l	d0,(a0)+
	dbra	d7,eff_colors_after_intro
	rts
illeg				* apres l'intro
	move.l	$80.w,sp
	bsr.s	clr_col

	lea	$bc0.w,a1		* adresse load reset
	moveq	#2,d2
	moveq	#0,d3
	jsr	$2e4.w
	jsr	$2bc.w

	moveq	#45,d0
	jsr	$16e.w
	moveq	#4,d1
	move.w	#21,d2
	jsr	$140.w

	move.l	#$31415926,$426.w	* magic valeur
	lea	reset(pc),a1
	move.l	a1,$42a.w		* detourne reset

*********** charger le menu ! **********

	tst.l	$c.w		* regarder si 520
	bne.s	yo_guy_you_ve_got_more_than_a_half_meg_machine

********* si 520 ***********

illeg_men_520
	move.l	$80.w,sp
	bsr.s	clr_col
	lea	$10000,a1
	bsr	load_men
	lea	$10000,a0
	bsr	depack
	lea	illeg_load_520(pc),a0
	move.l	a0,$10.w
	jmp	$10000

yo_guy_you_ve_got_more_than_a_half_meg_machine
	lea	illeg_men_1040(pc),a0
	move.l	a0,$10.w
	lea	$80000,a1
	bsr	load_men
	lea	$c0000,a1
	bsr	load_loader
illeg_men_1040
	move.l	$80.w,sp
	bsr	clr_col
	lea	$80000,a0		* recopie le menu en $10000
	lea	$10000,a1
	move.w	#38574/4-1,d7
recop_men
	move.l	(a0)+,(a1)+
	dbra	d7,recop_men
	lea	$10000,a0
	bsr	depack
	lea	illeg_load_1040(pc),a0
	move.l	a0,$10.w
	jmp	$10000

illeg_load_1040
	bsr	clr_col
	lea	$c0000,a0
	lea	$59c00,a2
	lea	$c0000+73*512,a1
reloc_loader
	move.l	(a0)+,(a2)+
	cmp.l	a0,a1
	bge.s	reloc_loader
	
	lea	$59c00,a0
	bsr	depack

	lea	illeg_men_1040(pc),a0
	move.l	a0,$10.w

	lea	tableau(pc),a0
	moveq	#0,d0
	move.w	$24.w,d0
	mulu	#10,d0
	movem.w	(a0,d0.w),d1-d5
	movem.w	d1-d5,$4000-20.w
	move.w	#0,$24.w

	jmp	$59c00

illeg_load_520
	bsr	clr_col
	lea	$59c00,a1
	bsr.s	load_loader

	lea	$59c00,a0
	bsr	depack

	lea	illeg_men_520(pc),a0
	move.l	a0,$10.w

	jmp	$59c00

my_vbl
	clr.b	$ffff8260.w
	move.b	#$d,$fffc02
reset_vbl
	rte
load_loader
	moveq	#2,d2
	moveq	#0,d3
	jsr	$2e4.w
	jsr	$2bc.w

	moveq	#8,d0
	jsr	$16e.w
	moveq	#7,d1
	moveq	#72,d2
	jsr	$140.w
	rts
load_men
	moveq	#2,d2
	moveq	#0,d3
	jsr	$2e4.w
	jsr	$2bc.w

	moveq	#1,d0
	jsr	$16e.w
	moveq	#1,d1
	move.w	#75,d2
	jsr	$140.w
	rts

clavier
	move.l	d7,-(sp)
	move.b	$fffc02,d7
	move.l	(sp)+,d7
	rte
reset
	move.w	#$2700,sr
	clr.w	$fffff8900.w
	move.b	#2,$ffff820a.w
	lea	$ffff8240.w,a0
	moveq	#0,d0
	moveq	#7,d7
clr_res_col
	move.l	d0,(a0)+
	dbra	d7,clr_res_col
	clr.l	$426.w
	lea	fin_load+$200(pc),sp

	lea	$bc0+10948.w,a0
	lea	$7ffff,a1
	moveq	#0,d0
clr_all
	move.l	d0,(a0)+
	cmp.l	a0,a1
	bge.s	clr_all

	lea	$bc0.w,a0
	lea	$bc0+10948.w,a1
	lea	$40000,a2
reloc_reset
	move.l	(a0)+,(a2)+
	cmp.l	a0,a1
	bge.s	reloc_reset
	lea	$40000,a0
	bsr	depack
	jmp	$40000

tableau
	dc.w	51,4,124,2,1	* snake
	dc.w	55,6,60,2,0	* no scroll
	dc.w	0,1,100,2,1	* kbjardin
	dc.w	47,6,31,2,0	* gen

	dc.w	60,2,81,4,0	* ngc
	dc.w	68,4,78,4,0	* cromax
	
	dc.w	50,8,47,2,0	* hlm
	dc.w	19,2,3,2,1	* del 3
	dc.w	19,6,77,2,1	* vodka
	dc.w	74,10,42,2,0	* ripper
	dc.w	67,6,73,2,0	* tbc

	dc.w	18,1,8,4,1	* albedo

	dc.w	10,2,89,2,1	* push it

	dc.w	18,10,110,4,1	* columns
	dc.w	15,10,243,4,0	* lemmings

	dc.w	61,7,58,2,0	* pause
	dc.w	74,2,36,2,1	* tek

	dc.w	40,4,197,4,0	* boring
	dc.w	77,9,8,2,1	* nightmare

	dc.w	76,3,14,4,0	* mufe
	dc.w	36,3,x,2,1	* miga
	dc.w	30,1,61,4,1	* 90 degres

	dc.w	63,9,102,2,1	* thrud
f_tableau
fin_load