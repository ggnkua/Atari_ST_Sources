*************************************************************************
*			POVerty demo slideshow				*
*			~~~~~~~~~~~~~~~~~~~~~~				*
*									*
*									*
* Written by:	MAC SYS DATA of Persistence Of Vision			*
*									*
*									*
* Start date:	24th May 1993						*
*									*
*									*
*									*
*									*
*									*
*									*
*									*
*									*
*************************************************************************
 
no	equ	1
NO	equ	no
yes	equ	0
YES	equ	yes

FINAL		equ	yes
TEST		equ	no	;yes turns off tracker to hopefully prevent total bomb out
SORT_PICS	equ	no	;yes for development to include 9 PI1s
DISASSEM	equ	no	;yes to check using MONST, no for hard scroll

**************************************
; STE stuff original from (c) May 1990
**************************************
LINEWID		equ	160

start
		ifeq	FINAL
		org	$10000
		endc

		opt	o+,w-

		lea	bss_start,a0
		move.l	#bss_end-bss_start,d0
		lsr.l	#2,d0
clear_bss	clr.l	(a0)+
		sub.l	#1,d0
		bne.s	clear_bss

		ifne	FINAL
		bsr	set_super
		move.b	#$12,$fffffc02.w
		endc

		bsr	setup


****** REMEMBER:
******          FROM HERE ONWARDS THE SCREEN IS 480 BYTES LONG
******


;************************************************************************
;
		ifne	DISASSEM
		move.w	#LINEWID,$ffff820e.w	;offset to next line
		endc
;
;		size
;FF820E		8	Line offset (LINEWID) - the number of extra words 
;			added to the address counter at the end of each 
;			line, _MINUS ONE DATA FETCH_. This allows for 
;			virtual screens that are wider than the actual 
;			screen display. Clearing this register means the 
;			STE acts like an ordinary ST.
;************************************************************************


main_loop
		ifne	DISASSEM
		move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		elseif
		movem.l	d0/d1/d2/a0/a1/a2,-(sp)
		move.w	#$25,-(sp)
		trap	#14
		addq.l	#2,sp
		movem.l	(sp)+,d0/d1/d2/a0/a1/a2
		endc

;		move.w	#$123,$ffff8240.w
		tst.w	event_timer
		bne.s	.no

		bsr	fadetoblack

		move.w	offset_into_tables,d0
		lea	offset_tables,a0
		add.w	d0,a0
		tst.l	(a0)
		bpl.s	.okay
		bsr	 scroll
.okay
		bsr	getapic

		bsr	fadeup
EVENT_TIMER	equ	480-32
EVENT_PLUS	equ	32
		move.w	#EVENT_TIMER,event_timer

.no
;		move.w	#0,$ffff8240.w
		sub.w	#1,event_timer

		move.w	key,d0

		ifne	DISASSEM
		cmp.w	#$b9,d0
		bne	main_loop
		ELSEIF
		cmp.b	#1,$fffffc02.w
		bne	main_loop
		endc
		bsr	shut_down

		move.b	#8,$fffffc02.w
		ifne	FINAL
		bsr	set_user
		clr.w	-(sp)
		trap	#1
		endc

		jmp	$9500

		move.l	$4.w,a0
		jmp	(a0)



***************************** PATCH ROUTINES ***************************
getapic		move.w	#-1,scroll_enable
		move.l	pictable_pos,a1
		tst.l	(a1)
		bpl.s	.not_end
		lea	pictable,a1
.not_end	move.l	(a1)+,a0		;A0 points to where pic starts
		move.l	a1,pictable_pos
		bsr	newpic
		clr.w	scroll_enable
		rts



* On entry A0 points to new pic
newpic		lea	depack_space,a1
		bsr	depack
		lea	depack_space,a0
		move.l	screen_base,a1
		add.l	#(480*200)+160,a1
		movem.l	2(a0),d0-d7
		movem.l	d0-d7,new_pal
		lea	34(a0),a0
		move.w	#200-1,d0
.loop
offset	set	0
		rept	40
		move.l	(a0)+,offset(a1)
offset	set	offset+4
		endr
		lea	480(a1),a1
		dbf	d0,.loop
		rts




fadespeed	equ	4		;speed at which fade is done (no. of VBLs)
;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadeup
		lea	new_pal,a1
		bra.s	common_fade

;A0=SOURCE PALETTE 	A1=TARGET PALETTE
fadetoblack
		lea	black,a1

common_fade	move.w	#8-1,d5
		move.l	a1,a2
.next_value
		lea	$ffff8240.w,a0
		move.w	#16-1,d7
.loop		bsr	modify
		addq.w	#2,a0
		addq.w	#2,a1
		dbf	d7,.loop

		move.w	#fadespeed-1,d6
.syncloop	move.w	#-1,vsync_flag
.sync		tst.w	vsync_flag
		bne.s	.sync
		dbf	d6,.syncloop
		move.l	a2,a1
		dbf	d5,.next_value
		rts

modify		move.w	(a0),d0		;get color value
		move.w	(a1),d1		;target pal
		move.w	d0,d4		;NEW COL
		move.w	d0,d2
		move.w	d1,d3
		and.w	#7,d2
		and.w	#7,d3
		cmp.w	d2,d3
		beq.s	blue_ok
		bmi.s	blue_dn
		addq.w	#1,d4
		bra.s	blue_ok
blue_dn		subq	#1,d4
blue_ok		move.w	d0,d2
		move.w	d1,d3
		and.w	#$70,d2
		and	#$70,d3
		cmp.w	d2,d3
		beq.s	grn_ok
		bmi.s	grn_dn
		add.w	#$10,d4
		bra.s	grn_ok
grn_dn		sub.w	#$10,d4
grn_ok		move.w	d0,d2
		move.w	d1,d3
		and.w	#$700,d2
		and.w	#$700,d3
		cmp.w	d2,d3
		beq.s	red_ok
		bmi.s	red_dn
		add.w	#$100,d4
		bra.s	red_ok
red_dn		sub.w	#$100,d4
red_ok		move.w	d4,(a0)
		rts




scroll		tst.w	scroll_enable
		beq.s	.aok
		rts
.aok		move.l	offset_pointer,a0
.get		move.l	(a0)+,d0
		bpl.s	.no_reset
		add.w	#4,offset_into_tables
		move.w	offset_into_tables,d0
		lea	offset_tables,a0
		add.w	d0,a0
		tst.l	(a0)
		bpl.s	.okay
		lea	offset_tables,a0
		clr.w	offset_into_tables
.okay		move.l	(a0)+,a0
		bra.s	.get
.no_reset	move.l	a0,offset_pointer
		move.w	d0,d1
		move.w	d0,d2
		move.l	d0,d4
		swap	d4

		and.l	#$f0,d1		;shift /8
		lsr.w	#1,d1

		move.l	screen_base,d6
		and.l	#$ff00,d2	;256 boundary
		lsr.l	#1,d2
		add.w	d1,d2
		add.l	d2,d6

		and.l	#$ffff,d4	;Y offset
		mulu	#16*60,d4
		add.l	d4,d6

		move.l	d6,hard_addr

		and.w	#15,d0		;bit shift
		bne.s	.extra_fetch

		ifne	DISASSEM
		move.b	#LINEWID,$ffff820f.w	;offset to next line
		move.b	d0,$ffff8265.w		;pixel shift
		endc
		move.b	hard_addr+1,$ffff8205.w
		move.b	hard_addr+2,$ffff8207.w
		move.b	hard_addr+3,$ffff8209.w
		rts
.extra_fetch
		ifne	DISASSEM
		move.b	#LINEWID-4,$ffff820f.w	;offset to next line
		move.b	d0,$ffff8265.w		;pixel shift
		endc
		move.b	hard_addr+1,$ffff8205.w
		move.b	hard_addr+2,$ffff8207.w
		move.b	hard_addr+3,$ffff8209.w
		rts







;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)
;MODE=1 depack data from a0 to a0 
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)
;PIC_ALGO = 0 decrunch file not encoded with special picture algorythm.
;PIC_ALGO = 1 decrunch all files with or without picture algorythm.
;DEC_SPACE = (lesser decrunch space is gived after packing by atomik v3.5)
;RESTORE_SPACE = 1 the allocated decrunch space will be restored .
;RESTORE_SPACE = 0 the allocated decrunch space will not be restored.
MODE		EQU	0	;a0 to a1
PIC_ALGO	EQU	1	;pictures!
DEC_SPACE	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE	EQU	0
depack		movem.l	d0-a6,-(a7)
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
.save_m		move.b	(a4)+,(a3)+
		subq	#1,d0
.save		bne.s	.save_m
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
.next_cod1	moveq	#7,d6
		bsr.s	get_bit2
		beq.s	.next_cod2
		add	#15,d5
		bra.s	.do_copy
.empty1		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont_take
.next_cod2	moveq	#13,d6
		bsr.s	get_bit2
		add	#255+15,d5
.do_copy	add	d3,d5
.do_copy1	lea	decrun_table(pc),a4
		move	d5,d2
		bne.s	bigger
		add.b	d7,d7
		bne.s	.not_empty
		move.b	-(a6),d7
		addx.b	d7,d7
.not_empty	bcs.s	.ho_kesako
		moveq	#1,d6
		bra.s	word
.ho_kesako	moveq	#3,d6
		bsr.s	get_bit2
		tst.b	-28(a2)
		beq.s	.ho_kesako1
		move.b	10-28(a2,d5.w),-(a5)
		bra	tst_end
.ho_kesako1	move.b	(a5),d0
		btst	#3,d5
		bne.s	.ho_kesako2
		bra.s	.ho_kesako3
.ho_kesako2	add.b	#$f0,d5
.ho_kesako3	sub.b	d5,d0
		move.b	d0,-(a5)
		bra	tst_end
get_bit2	clr	d5
.get_bits	add.b	d7,d7
		beq.s	.empty
.cont		addx	d5,d5
		dbf	d6,.get_bits
		tst	d5
		rts
.empty		move.b	-(a6),d7
		addx.b	d7,d7
		bra.s	.cont
bigger		moveq	#2,d6
word		bsr.s	get_bit2
contus		move	d5,d4
		move.b	14(a4,d4.w),d6
		ext	d6
		tst.b	1-28(a2)
		bne.s	.spe_ofcod1
		addq	#4,d6
		bra.s	.nospe_ofcod1
.spe_ofcod1	bsr.s	get_bit2
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
.its_little	or.b	2-28(a2),d1
		bra.s	.spe_ofcod3
.take_orof	or.b	3-28(a2,d5.w),d1
.spe_ofcod3	move	d1,d5
		bra.s	.spe_ofcod2
.nospe_ofcod1	bsr.s	get_bit2
.spe_ofcod2	add	d4,d4
		beq.s	.first
		add	-2(a4,d4.w),d5
.first		lea	1(a5,d5.w),a4
		move.b	-(a4),-(a5)
.copy_same	move.b	-(a4),-(a5)
		dbf	d2,.copy_same
		bra.s	tst_end
make_jnk	add.b	d7,d7
		bne.s	.not_empty
		move.b	-(a6),d7
		addx.b	d7,d7
.not_empty	bcs.s	string
		move.b	-(a6),-(a5)
tst_end		cmp.l	a5,a3
		bne.s	make_jnk
		cmp.l	a6,a0
		beq.s	work_done
take_type	moveq	#0,d6
		bsr	get_bit2
		beq.s	.nospe_ofcod
		move.b	-(a6),d0
		lea	2-28(a2),a1
		move.b	d0,(a1)+
		moveq	#1,d1
		moveq	#6,d2
.next		cmp.b	d0,d1
		bne.s	.no_off_4b
		addq	#2,d1
.no_off_4b	move.b	d1,(a1)+
		addq	#2,d1
		dbf	d2,.next
		st	1-28(a2)
		bra.s	.spe_ofcod
.nospe_ofcod	sf	1-28(a2)
.spe_ofcod	moveq	#0,d6
		bsr	get_bit2
		beq.s	.relatif
		lea	10-28(a2),a1
		moveq	#15,d0
.next_f		move.b	-(a6),(a1)+
		dbf	d0,.next_f
		st	-28(a2)
		bra.s	.freq
.relatif	sf	-28(a2)
.freq		clr	d3
		move.b	-(a6),d3
		move.b	-(a6),d0
		lsl	#8,d0
		move.b	-(a6),d0
		move.l	a5,a3
		sub	d0,a3
		bra.s	make_jnk
string		bra	decrunch
work_done
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
.restore_m	move.b	-(a3),-(a4)
		subq	#1,d0
.restore	bne.s	.restore_m
		endc
		unlk	a2
not_packed	movem.l	(a7)+,d0-a6
	 	rts
decrun_table
	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture	move	-2(a2),d7
.next_picture	dbf	d7,.decod_algo
		rts
.decod_algo	move.l	-(a0),d0
		lea	0(a5,d0.l),a1
.no_odd		lea	$7d00(a1),a2
.next_planes	moveq	#3,d6
.next_word	move	(a1)+,d0
		moveq	#3,d5
.next_bits	add	d0,d0
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
copy_decrun	lsr.l	#4,d0
		lea	-12(a6),a6
.copy_decrun	rept	4
		move.l	(a5)+,(a6)+
		endr
		dbf	d0,.copy_decrun
		rts
		endc
		ifne	RESTORE_SPACE
buff_marg	dcb.b	$90+DEC_SPACE+$C
		endc









setup		move.l	$44e.w,old_base
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_pal

		move.b	$ffff8260.w,org_rez

		clr.b	$ffff8260.w

		move.l	#screen,d6
		clr.b	d6
		move.l	d6,screen_base
		bsr	set_screen

		move.l	pictable,a0
		bsr	newpic

		ifeq	SORT_PICS
;make 9 PI1's into a 3*3 pic image
		movem.l	image+2,d0-d7
		movem.l	d0-d7,new_pal
		movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	screen_base,a0
		lea	image+34,a1		;pic 1
		lea	32034(a1),a2		;pic 2
		lea	32034(a2),a3		;pic 3

		move.w	#200-1,d0
.loop		move.w	d0,-(sp)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,128(a0)	;160 bytes (1 line)
		lea	160(a0),a0

		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,128(a0)
		lea	160(a0),a0

		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,128(a0)
		lea	160(a0),a0

		move.w	(sp)+,d0
		dbf	d0,.loop


		lea	image+34+(3*32034),a1	;pic 4
		lea	32034(a1),a2		;pic 5
		lea	32034(a2),a3		;pic 6

		move.w	#200-1,d0
.mid3		move.w	d0,-(sp)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,128(a0)	;160 bytes (1 line)
		lea	160(a0),a0

		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,128(a0)
		lea	160(a0),a0

		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,128(a0)
		lea	160(a0),a0
		move.w	(sp)+,d0
		dbf	d0,.mid3

		lea	image+34+(6*32034),a1	;pic 7
		lea	32034(a1),a2		;pic 8
		lea	32034(a2),a3		;pic 9

		move.w	#200-1,d0
.lower3		move.w	d0,-(sp)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,128(a0)	;160 bytes (1 line)
		lea	160(a0),a0

		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,128(a0)
		lea	160(a0),a0

		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,32(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,64(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,96(a0)
		movem.l	(a3)+,d0-d7
		movem.l	d0-d7,128(a0)
		lea	160(a0),a0
		move.w	(sp)+,d0
		dbf	d0,.lower3
		endc

		move.w	#$2700,sr
		lea	store_all,a0
		move.l	$70.w,(a0)+
		move.l	$118.w,(a0)+
		ifne	DISASSEM
		move.l	#new_vbl,$70.w
		move.l	#new_key,$118.w
		endc
;-----------------------------------------------------------------------;
; Replay is started by calling MUSON in supervisor mode. Returns with	;
; timer A running. Calling MUSOFF will stop music.			;
;									;
; This routine needs some workspace after the module to work properly.	;
; We've set it to 16k, some modules needs more, some need less. If the	;
; workspace is too small, initialization will hang on an ILLEGAL	;
; instruction. Adjust workspace size to fit the specific module.	;
;									;
; MVOL = Main volume	  (Unnecessary to adjust. $80 default)		;
; FREQ = replay frequency (See below)					;
;-----------------------------------------------------------------------;

MVOL	EQU	$80
FREQ	EQU	2			; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)

	IFEQ FREQ
PARTS	EQU 5-1				; 6.259
LEN	EQU 25
INC	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ-1
PARTS	EQU 5-1				; 12.517
LEN	EQU 50
INC	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ-2
PARTS	EQU 5-1				; 25.035
LEN	EQU 100
INC	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ-3
PARTS	EQU 5-1				; 50.072
LEN	EQU 200
INC	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC

		ifne	TEST
muson		bsr	vol			; Calculate volume tables
		bsr	incrcal			; Calculate tonetables

		jsr	init			; Initialize music
		jsr	prepare			; Prepare samples

		bset	#5,$FFFFFA07.w
		bset	#5,$FFFFFA13.w
		clr.b	$FFFFFA19.w
		move.b	#1,$FFFFFA1F.w
		move.b	#8,$FFFFFA19.w
		move.l	$134.w,oldtima
		move.l	#stereo,$134.w
		move.b	#FREQ,$FFFF8921.w		; Frequency
		lea	$FFFF8907.w,a0
		move.l	#sample1,d0
		move.b	d0,(a0)
		lsr.w	#8,d0
		move.l	d0,-5(a0)
		move.l	#sample1+LEN*2,d0
		move.b	d0,12(a0)
		lsr.w	#8,d0
		move.l	d0,7(a0)
		move.b	#3,$FFFF8901.w		; Start DMA
		endc

		movem.l	new_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.w	#$2300,sr

		move.w	#EVENT_TIMER+EVENT_PLUS,event_timer

		rts



shut_down	move.w	#$2700,sr
		lea	store_all,a0
		move.l	(a0)+,$70.w
		move.l	(a0)+,$118.w

		clr.b	$ffff8264.w		;bit offset

		move.w	#0,$ffff820e.w		;offset to next word of screen
		move.w	#0,$ffff8264.w

		clr.b	$ffff8901.w		;DI DMA sample

		ifne	TEST
musoff		clr.b	$fffffa19.w	; Stop timers
		move.l	oldtima,$134.w	; Restore everything
		bclr	#5,$fffffa07.w
		bclr	#5,$fffffa13.w
		clr.b	$ffff8901.w		; Stop DMA
		endc

		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr	set_old_rez

		move.w	#$2300,sr
		rts

new_vbl		clr.w	vsync_flag
		movem.l	d0-a6,-(sp)
		bsr	scroll
		movem.l	(sp)+,d0-a6
		rte

new_key		movem.l	d0,-(sp)
		move.b	$fffffc02.w,d0
		cmp.b	#$1d,d0
		bne.s	.k1
		bset	#2,key
.k1		cmp.b	#$9d,d0
		bne.s	.k2
		bclr	#2,key
.k2		cmp.b	#$38,d0
		bne.s	.k3
		bset	#3,key
.k3		cmp.b	#$b8,d0
		bne.s	.k4
		bclr	#3,key
.k4		move.b	d0,key+1
		bclr	#6,$fffffa11.w
		movem.l	(sp)+,d0
		rte


set_screen	lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

set_old_rez	move.b	org_rez,$ffff8260.w
		move.l	old_base,d6
		bra.s	set_screen


		ifne	TEST
********************* TRACKER CODE **************************************
;---------------------------------------------- Interrupts on/off --



;--------------------------------------------------------- Volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab	DS.B 65*256
vtabend

;------------------------------------------------------ Increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	DS.L $30
stab	DS.L $03A0-$30

;-------------------------------------------------------- DMA interrupt --
stereo	move	#$2500,sr
	bclr	#5,$FFFFFA0F.w
	movem.l	d0-a6,-(sp)

	move.l	samp1(pc),d0
	move.l	samp2(pc),samp1
	move.l	d0,samp2

	lea	$FFFF8907.w,a0

	move.l	samp1(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	samp1(pc),d0
	add.l	#LEN*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v1	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2


	movea.l	wiz3lc(pc),a1

	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5

	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud3vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	ENDR

	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc



	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v2	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2


	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1(pc),a6
	moveq	#0,d3

	REPT LEN
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	ENDR

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	movem.l	(sp)+,d0-a6
	rte

;-------------------------------------------- Hardware-registers & data --
count	DC.W PARTS

wiz1lc	DC.L sample1
wiz1len	DC.L 0
wiz1rpt	DC.W 0
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1
wiz2len	DC.L 0
wiz2rpt	DC.W 0
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1
wiz3len	DC.L 0
wiz3rpt	DC.W 0
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1
wiz4len	DC.L 0
wiz4rpt	DC.W 0
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0

dummy	DC.L 0

samp1	DC.L sample1
samp2	DC.L sample2

sample1	DS.W LEN
sample2	DS.W LEN

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	module(pc),a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	module(pc),a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	lea	module(pc),a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	module+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

		moveq	#0,d3
	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	move.w	d3,wiz1pos		;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	move.w	d3,wiz2pos		;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	move.w	d3,wiz3pos		;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	move.w	d3,wiz4pos		;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	move.w	d3,pattpos
	move.b	d3,break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	module+$03B6(pc),d1
	bne.s	endr
	move.b	module+$03B7(pc),songpos
endr:	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop:	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W	0
samplestarts	DS.L	$1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3


*****************************
	SECTION DATA
*****************************

module	incbin	xpansion.mod

	DS.B	6720			; Workspace
workspc	DS.W	1

	endc

		even
offset_pointer	dc.l	table1
offset_tables	dc.l	table1
		dc.l	table2
		dc.l	table4
		dc.l	table3
		dc.l	table5
		dc.l	table6
		dc.l	table7
		dc.l	table8
		dc.l	table9
		dc.l	table10
		dc.l	table11
		dc.l	table12
		dc.l	table13
		dc.l	-1

table1		incbin	sine1.dat
		dc.l	-1
table2		incbin	sine2.dat
		dc.l	-1
table3		incbin	sine3.dat
		dc.l	-1
table4		incbin	sine4.dat
		dc.l	-1
table5		incbin	sine5.dat
		dc.l	-1
table6		incbin	sine6.dat
		dc.l	-1
table7		incbin	sine7.dat
		dc.l	-1
table8		incbin	sine8.dat
		dc.l	-1
table9		incbin	sine9.dat
		dc.l	-1
table10		incbin	sine10.dat
		dc.l	-1
table11		incbin	sine11.dat
		dc.l	-1
table12		incbin	sine12.dat
		dc.l	-1
table13		incbin	sine13.dat
		dc.l	-1

		ifeq	SORT_PICS
image		incbin	develop\1.pi1
		incbin	develop\2.pi1
		incbin	develop\3.pi1
		incbin	develop\4.pi1
		incbin	develop\5.pi1
		incbin	develop\6.pi1
		incbin	develop\7.pi1
		incbin	develop\8.pi1
		incbin	develop\9.pi1
		endc


pictable_pos	dc.l	pictable+4
pictable	dc.l	pic20
		dc.l	pic1
		dc.l	pic2
		dc.l	pic3
		dc.l	pic4
		dc.l	pic5
		dc.l	pic6
		dc.l	pic20
		dc.l	pic7
		dc.l	pic8
		dc.l	pic9
		dc.l	pic10
		dc.l	pic11
		dc.l	pic20
		dc.l	pic12
		dc.l	pic13
		dc.l	pic14
		dc.l	pic15
		dc.l	pic20
		dc.l	pic16
		dc.l	pic17
		dc.l	pic18
		dc.l	pic19
		dc.l	pic20
		dc.l	pic21
		dc.l	pic22
		dc.l	pic23
		dc.l	pic24
		dc.l	pic25
		dc.l	pic26
		dc.l	pic27
		dc.l	pic28
		dc.l	pic20
		dc.l	pic29
		dc.l	pic30
		dc.l	pic31
		dc.l	pic32
		dc.l	pic33
		dc.l	pic34
		dc.l	pic35
		dc.l	pic20
		dc.l	pic36
		dc.l	pic37
		dc.l	-1

pic1		incbin	pics\blakpool.pi1
pic2		incbin	pics\carter.pi1
pic3		incbin	pics\cat.pi1
pic4		incbin	pics\close.pi1
pic5		incbin	pics\e_gener.pi1
pic6		incbin	pics\firenice.pi1
pic7		incbin	pics\grn_man.pi1
pic8		incbin	pics\hardcor2.pi1
pic9		incbin	pics\hiveborn.pi1
pic10		incbin	pics\jet_pak2.pi1
pic11		incbin	pics\judge.pi1
pic12		incbin	pics\klf_grim.pi1
pic13		incbin	pics\lichenst.pi1
pic14		incbin	pics\mean2.pi1
pic15		incbin	pics\moon.pi1
pic16		incbin	pics\my_world.pi1
pic17		incbin	pics\nin1.pi1
pic18		incbin	pics\nirvana.pi1
pic19		incbin	pics\num_1.pi1
pic20		incbin	pics\oz_g_i_d.pi1
pic21		incbin	pics\polologo.pi1
pic22		incbin	pics\povsys.pi1
pic23		incbin	pics\pov_mac1.pi1
pic24		incbin	pics\pov_mac2.pi1
pic25		incbin	pics\pov_mac3.pi1
pic26		incbin	pics\pov_mac4.pi1
pic27		incbin	pics\pov_mac5.pi1
pic28		incbin	pics\pov_mac6.pi1
pic29		incbin	pics\purple.pi1
pic30		incbin	pics\saintpov.pi1
pic31		incbin	pics\semaj.pi1
pic32		incbin	pics\soma_pic.pi1
pic33		incbin	pics\stompin.pi1
pic34		incbin	pics\sushi.pi1
pic35		incbin	pics\techgods.pi1
pic36		incbin	pics\trust2.pi1
pic37		incbin	pics\twin_p.pi1



	SECTION	BSS
bss_start
offset_into_tables	ds.w	1

screen_base		ds.l	1
new_pal			ds.w	16
stack_save		ds.l	1
old_pal			ds.w	16
old_base		ds.l	1
org_rez			ds.b	1
			even
store_all		ds.l	2
key			ds.w	1
vsync_flag		ds.w	1
hard_addr		ds.l	1

black			ds.w	16

scroll_enable		ds.w	1
event_timer		ds.w	1

;**** tracker variables ******************
oldtima		ds.l	1


depack_space	ds.b	32034


;	1 2 3
;	4 5 6
;	7 8 9
		ds.b	256
screen		ds.b	32000*9

bss_end
stop