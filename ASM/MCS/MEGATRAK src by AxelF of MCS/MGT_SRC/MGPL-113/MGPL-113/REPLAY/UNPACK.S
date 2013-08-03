***********************************************************************
***********										***********
***********	    Routine de d‚tection et d‚packing		***********
***********		automatique des packers suivants		***********
***********										***********
***********		 Atomik 3.5 - Speed 3 - Ice 2.4		***********
***********			Sentry 2.0 et Power 2.0			***********
***********										***********
***********		  Par Simplet / FATAL DESIGN			***********
***********										***********
***********************************************************************

	XDef		Unpack_Detect_Memory,Unpack_Detect_Disk,Unpack_All

	Section	TEXT

;
; D‚tection du packer utilis‚ sur un fichier
;
; En Entr‚e :
; d0 - handle du fichier
; d1 - place m‚moire disponible

Unpack_Detect_Disk
		movem.l	d1/d3/a2,-(sp)
		move.w	d0,d3

		clr.w	-(sp)			; Mode 0 SEEK_SET
		move.w	d3,-(sp)			; Handle
		clr.l	-(sp)			; D‚but du Fichier
		move.w	#$42,-(sp)		; Fseek
		trap		#1				; Gemdos
		lea.l	10(sp),sp

		pea.l	Unpack_Disk_Buffer(pc)
		pea.l	16.w				; Header 16 octets
		move.w	d3,-(sp)			; Handle
		move.w	#$3f,-(sp)		; Fread
		trap		#1				; Gemdos
		lea.l	12(sp),sp

		move.w	#2,-(sp)			; Mode 2 SEEK_END
		move.w	d3,-(sp)			; Handle
		pea.l	8.w				; 8 octets avant la fin
		move.w	#$42,-(sp)		; Fseek
		trap		#1				; Gemdos
		lea.l	10(sp),sp

		pea.l	Unpack_Disk_Buffer+16(pc)
		pea.l	8.w				; les 8 derniers octets
		move.w	d3,-(sp)			; Handle
		move.w	#$3f,-(sp)		; Fread
		trap		#1				; Gemdos
		lea.l	12(sp),sp

		clr.w	-(sp)			; Mode 0 SEEK_SET
		move.w	d3,-(sp)			; Handle
		clr.l	-(sp)			; D‚but du Fichier
		move.w	#$42,-(sp)		; Fseek
		trap		#1				; Gemdos
		lea.l	10(sp),sp

		movem.l	(sp)+,d1/d3/a2
		lea.l	Unpack_Disk_Buffer(pc),a0
		moveq.l	#16+8,d0
		bra.s	Unpack_Detect_Memory

Unpack_Disk_Buffer
		ds.l		6

;
; D‚tection du packer utilis‚ sur un bloc m‚moire
;
; En Entr‚e :
; a0 - adresse du Bloc … d‚packer
; d0 - longueur du Bloc … d‚packer
; d1 - place m‚moire disponible

; En Sortie :
; d0 - code de retour :
; -2 si pas assez de m‚moire
; -1 si packer pas encore g‚r‚ ou trop vieux
; 0 si non pack‚ (ou packer non reconnu)
; Sinon, num‚ro du Packer Identifi‚ :
;  1 = Atomik 3.5		2 = Speed 3		3 = Ice 2.4
;  4 = Power 2			5 = Sentry 2.0
;

Unpack_Detect_Memory
		cmp.l	#'ATM5',(a0)				; Atomik 3.5
		beq		Unpack_Atomik_3_5
		cmp.l	#'ATOM',(a0)				; Atomik 3.3
		beq		Unpack_Not_Supported
		cmp.l	#'SPv3',(a0)				; Speed 3
		beq		Unpack_Speed_3
		cmp.l	#'SP20',(a0)				; Spacker 2.0
		beq		Unpack_Not_Supported
		cmp.l	#'ICE!',(a0)				; Ice 2.34/2.4
		beq		Unpack_Ice_2_4
		cmp.l	#'Ice!',(a0)				; Ice 2.0-2.2
		beq.s	Unpack_Not_Supported
		cmp.l	#'Ice!',-4(a0,d0.l)			; Ice 1.0
		beq.s	Unpack_Not_Supported
		cmp.l	#'Snt2',-4(a0,d0.l)			; Sentry 2.01->2.11
		beq.s	Unpack_Not_Supported
		cmp.l	#'.tnS',-4(a0,d0.l)			; Sentry 2.0
		beq		Unpack_Sentry_2_0
		cmp.l	#'PP20',(a0)				; Power 2.0
		beq.s	Unpack_Power_2_0
		cmp.l	#'NPKK',(a0)				; Noise Packer..beurk..
		beq.s	Unpack_Not_Supported
		cmp.l	#'AQC!',(a0)				; Aquarium Crunchy
		beq.s	Unpack_Not_Supported
		cmp.l	#'FIRE',(a0)				; Fire 2.4
		beq.s	Unpack_Not_Supported
		cmp.l	#'Fire',-4(a0,d0.l)			; Fire 1.0
		beq.s	Unpack_Not_Supported
		cmp.l	#'AU5!',(a0)				; Automation 5.01
		beq.s	Unpack_Not_Supported
		cmp.l	#'JEK!',-4(a0,d0.l)			; Jek 2.3
		beq.s	Unpack_Not_Supported
		cmp.l	#'DEL!',-4(a0,d0.l)			; Jek 1.6
		beq.s	Unpack_Not_Supported
		cmp.l	#'TPWM',(a0)				; Identificateur Inconnu...
		beq.s	Unpack_Not_Supported

Unpack_Not_Packed
		moveq.l	#0,d0
		rts
Unpack_Not_Supported
		moveq.l	#-1,d0
		rts
Unpack_Not_Enough_Memory
		moveq.l	#-2,d0
		rts
Unpack_Atomik_3_5
		cmp.l	4(a0),d1
		blo.s	Unpack_Not_Enough_Memory
		moveq.l	#1,d0
		rts
Unpack_Speed_3
		cmp.l	12(a0),d1
		blo.s	Unpack_Not_Enough_Memory
		moveq.l	#2,d0
		rts
Unpack_Ice_2_4
		cmp.l	8(a0),d1
		blo.s	Unpack_Not_Enough_Memory
		moveq.l	#3,d0
		rts
Unpack_Power_2_0
		cmp.l	-4(a0,d0.l),d1
		blo.s	Unpack_Not_Enough_Memory
*		lsr.l	#8,d1
		moveq.l	#4,d0
		rts
Unpack_Sentry_2_0
		move.l	-8(a0,d0.l),d0
		ror.w	#8,d0
		swap.w	d0
		ror.w	#8,d0
		cmp.l	d0,d1
		blo.s	Unpack_Not_Enough_Memory
		moveq.l	#5,d0
		rts

;
; Depacking automatique des packers
;
; En Entr‚e :
; a0 - adresse du Bloc … d‚packer
; d0 - longueur du Bloc … d‚packer

; En Sortie :
; d0 - longueur du Bloc d‚pack‚
;
Unpack_All
		cmp.l	#'ATM5',(a0)
		bne.s	Unpack_Not_Atomik_3_5
		move.l	4(a0),d0
		bra.s	depack
Unpack_Not_Atomik_3_5
		cmp.l	#'SPv3',(a0)
		bne.s	Unpack_Not_Speed_3
		move.l	12(a0),d0
		bra		unpack
Unpack_Not_Speed_3
		cmp.l	#'ICE!',(a0)
		bne.s	Unpack_Not_Ice_2_4
		move.l	8(a0),d0
		bra		ice_decrunch_2
Unpack_Not_Ice_2_4
		cmp.l	#'PP20',(a0)
		beq		power_decrunch
		cmp.l	#'.tnS',-4(a0,d0.l)
		bne.s	Unpack_Not_Sentry_2_0
		move.l	d1,-(sp)
		move.l	-8(a0,d0.l),d1
		ror.w	#8,d1
		swap.w	d1
		ror.w	#8,d1
		bsr		sentry20
		move.l	d1,d0
		move.l	(sp)+,d1
Unpack_Not_Sentry_2_0
		rts


; d‚packing patch‚ pour 030

;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)

;ce depacker est indissociable du programme ATOMIK V3.5 tous les mecs
;qui garderons se source dans l'espoir de prendre de l'importance
;en se disant moi je l'ai et pas l'autre sont des lamers.

;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.

;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
             
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

;call it by BSR DEPACK or JSR DEPACK but call it!

MODE:	EQU	1
PIC_ALGO:	EQU	0
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	0

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
	bra.s	tst_end
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
copy_decrun:
	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:
	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	RESTORE_SPACE
buff_marg:	dcb.b	$90+DEC_SPACE+$C
	endc

* UNPACK source for SPACKERv3	(C)THE FIREHAWKS'92
* -------------------------------------------------
* in	a0: even address start packed block
* out	d0: original length or 0 if not SPv3 packed
* =================================================
* Use AUTO_SP3.PRG for multiblk packed files

unpack:	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	sp3_02
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:	movem.l	(sp)+,d0-a6
	rts
sp3_03:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_04
	move.w	$FFFF8240.W,2(a6)
	btst	#1,$FFFF8260.W
	bne.s	sp3_04
	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_16
	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
	beq.s	sp3_23
	move.w	d5,$FFFF8240.W
sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512

;********************************************* Unpacking routine of PACK-ICE
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.
ice_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr.s	.getinfo
	cmpi.l	#'ICE!',d0
	bne.s	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_uber
.get_uber:
	bsr.s	.get_d0_bits
.no_uber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_2:
;************************************************** end of unpacking routine

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;                  Routine de d‚compactage PowerPacker 2
;
;Entr‚e	A0 = d‚but du block compact‚
;	D0 = taille du block compact‚
;
;Sortie	( Z , D0 ) = ( 1 , taille d‚compact‚e )
;		= ( 0 , taille block) si !PP20
;
;D‚compactage 'sur place'. Il doit y avoir un espace libre sur la pile d'au
;moins 320 octets...
;
;                      Modifications cosm‚tiques par Nullos, DNT-Crew 1994
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
power_decrunch
	movem.l	d0-a6,-(sp)
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
	moveq	#63,d0
	move.l	-(a3),-(sp)
	dbf	d0,*-2
	move.l	a3,-(sp)
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
	move.l	(sp)+,a3
	moveq	#63,d0
	move.l	(sp)+,(a3)+
	dbf	d0,*-2
	moveq	#0,d0
.abort	movem.l	(sp)+,d0-a6
	rts

; routine de depacking du Sentry 2.0

sentry20
	movem.l	d0-a6,-(sp)
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
	bra.s	l_col

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
	move.b	#$10,ccr
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
