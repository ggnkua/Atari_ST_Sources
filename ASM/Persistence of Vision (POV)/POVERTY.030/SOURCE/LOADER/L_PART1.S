************************************************************************
*
* Loader for POVERTY demo AKA OZ slideshow 3
*
*
* Written by: Machine System Data of Persistence Of Vision
*
* Date: Aug 94
*
*
*			* FALCON 1.44M DISC VERSION *
*
*
************************************************************************

	opt	p+,o+,w-

;		org	$20000

		move.b	#%1110,$ffff8800.w		;i/o port A select
		or.b	#%10111111,$ffff8802.w		;turn internal speaker off

		clr.b	$ffff8260.w
		move.l	$44e.w,a0
		move.l	a0,$220.w
		move.l	a0,a1
		move.w	#32000/4-1,d0
clr_scrn	clr.l	(a0)+
		dbf	d0,clr_scrn
		move.l	a1,a0
		add.w	#160*40+3*8,a0
		lea	logo(pc),a1
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,$ffff8240.w
		movem.l	d0-d7,$300.w
		move.w	#83-1,d0
shift
OFFSET	set	0
		rept	14
		move.l	(a1)+,OFFSET(a0)
		move.l	(a1)+,OFFSET+4(a0)
OFFSET	set	OFFSET+8
	endr
		add.w	#160,a0
		dbf	d0,shift

		lea	part1loader(pc),a0
		lea	$9000,a1
		move.l	#part1loaderend-part1loader,d0
movepart1	move.b	(a0)+,(a1)+
		sub.l	#1,d0
		bne.s	movepart1

		lea	part2loader(pc),a0
		lea	$9100,a1
		move.l	#part2loaderend-part2loader,d0
movepart2	move.b	(a0)+,(a1)+
		sub.l	#1,d0
		bne.s	movepart2

		lea	part3loader(pc),a0
		lea	$9200,a1
		move.l	#part3loaderend-part3loader,d0
movepart3	move.b	(a0)+,(a1)+
		sub.l	#1,d0
		bne.s	movepart3

		lea	de_atom(pc),a0
		lea	$9300,a1
		move.l	#de_atom_end-de_atom,d0
movepart4	move.b	(a0)+,(a1)+
		sub.l	#1,d0
		bne.s	movepart4

		jmp	$9000

************************************************************************


		opt	p+
part1loader
START_SECTOR	equ	1
TRACKS_TO_LOAD	equ	24
		clr.w	$ffff8240.w

		move.w	#18,d7		;number of sectors to read
		move.w	#0,d6		;side
		move.w	#10,d5		;start track
		move.w	#START_SECTOR,d4	;sector to start reading from 1-10
		move.w	#TRACKS_TO_LOAD-1,d3
		lea	$10000,a6	;address to load at
readloop	move.w	d7,-(sp)	;number of sectors to read
		move.w	d6,-(sp)	;side
		move.w	d5,-(sp)	;track
		move.w	d4,-(sp)	;sector to start reading
		clr.w	-(sp)		;drive A
		clr.l	-(sp)		;not used
		move.l	a6,-(sp)	;load address
		move.w	#8,-(sp)
		trap	#14
		lea	20(sp),sp
		tst.l	d0
		bmi.s	error1
		lea	512*18(a6),a6
		add.w	#1,d5		;increase track
		dbf	d3,readloop
		jmp	$9300
error1		move.w	#$2700,sr
.error		eor.w	#$f00,$ffff8240.w
		rept	23
		nop
		endr
		bra.s	.error
part1loaderend



part2loader
TRACKS_TO_LOAD_PART2	equ	63
		clr.w	$ffff8240.w
		clr.b	$ffff8260.w
		movem.l	$300.w,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.l	$220.w,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		move.w	#18,d7		;number of sectors to read
		move.w	#1,d6		;side
		move.w	#10,d5		;track
		move.l	#TRACKS_TO_LOAD_PART2-1,d3
		lea	$10000,a6	;address to load at
readloop2	move.w	d7,-(sp)	;number of sectors to read
		move.w	d6,-(sp)	;side
		move.w	d5,-(sp)	;track
		move.w	#1,-(sp)	;sector to start reading
		clr.w	-(sp)		;drive A
		clr.l	-(sp)		;not used
		move.l	a6,-(sp)	;load address
		move.w	#8,-(sp)
		trap	#14
		lea	20(sp),sp
		tst.l	d0
		bmi.s	error2
		lea	512*18(a6),a6
		add.w	#1,d5
		dbf	d3,readloop2

		jmp	$9300
error2		move.w	#$2700,sr
.error		eor.w	#$f0f,$ffff8240.w
		rept	23
		nop
		endr
		bra.s	.error
part2loaderend



part3loader
START_SECTOR_PART3	equ	1
TRACKS_TO_LOAD_PART3	equ	33
		clr.w	$ffff8240.w
		clr.b	$ffff8260.w
		movem.l	$300.w,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.l	$220.w,d6
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)

		move.w	#18,d7		;number of sectors to read
		move.w	#0,d6		;side
		move.w	#30,d5		;track
		move.w	#1,d4		;sector to start reading from 1-10
		move.w	#TRACKS_TO_LOAD_PART3-1,d3
		lea	$10000,a6	;address to load at
readloop3	move.w	d7,-(sp)	;number of sectors to read
		move.w	d6,-(sp)	;side
		move.w	d5,-(sp)	;track
		move.w	d4,-(sp)	;sector to start reading
		clr.w	-(sp)		;drive A
		clr.l	-(sp)		;not used
		move.l	a6,-(sp)	;load address
		move.w	#8,-(sp)
		trap	#14
		lea	20(sp),sp
		tst.l	d0
		bmi.s	error3
		lea	512*18(a6),a6
		add.w	#1,d5
		dbf	d3,readloop3

		jmp	$9300
error3		move.w	#$2700,sr
.error		eor.w	#$f0f,$ffff8240.w
		rept	23
		nop
		endr
		bra.s	.error
part3loaderend




		opt	p+
;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)
;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)
;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.
;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.

MODE		EQU	1	;a0->a0
PIC_ALGO	EQU	0
DEC_SPACE	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE	EQU	0

de_atom
	lea	$10000,a0
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
.save_m	move.b	(a4)+,(a3)+
	subq	#1,d0
.save	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch	move	d3,d5
take_lenght	add.b	d7,d7
.cont_take	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod	moveq	#3,d6
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

;	move.w	d4,$ffff8240.w	;d2 or d4=flash blue

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
.next_f	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif	sf	-28(a2)
.freq	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string	bra	decrunch
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
		clr.l	d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		movem.l	d0-d7,$ffff8240.w
	jmp	$10000




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
de_atom_end

logo	incbin	i:\poverty\falcon\loader\1stlogo.dat
	dcb.b	2000,0
