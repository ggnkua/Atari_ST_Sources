* PROJECT :
* sss menu 4
* v2, additions made 4/9/90, now resets on STE
* being adapted for predator intro, 9/9/1990
* PROGRAMMER :
* Crossbones
* ORIGINALLY COMMENCED :
* 21/8/90
* ORIGINALLY FINISHED :
* 25/8/90 9.00 p.m
* ORIGINAL RELEASE DATE :
* 27/8/90
* OTHER RELEASES :
* v2, 4/9/90
* predator intro, 24/9/90
* ORIGINAL NOTES :
* to be written as two vbl routines
* and a main routine checking for keyboard
* and doing the depacking.
* to have a border routine, and a reset routine
* OTHER NOTES :
* v2, thanx to DCB for reset routine (ste version)
* predator, to have border scroller
* predator, MCA stile rasters + volume bars
* predator, scroller works fine on screen, but not in border
* predator, border scroll now works, 15/9/90

* for debugging

	opt	d+

* macros

super	MACRO			;macro to go to supervisor
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	ENDM

unsuper	MACRO			;macro to go to user
	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

d_mfp	MACRO			;macro to disable most mfp interupts
	move.w	#12,-(sp)
	move.w	#26,-(sp)
	trap	#14
	addq	#4,sp
	move.w	#11,-(sp)
	move.w	#26,-(sp)
	trap	#14
	addq	#4,sp
	move.w	#10,-(sp)
	move.w	#26,-(sp)
	trap	#14
	addq	#4,sp
	move.w	#9,-(sp)
	move.w	#26,-(sp)
	trap	#14
	addq	#4,sp
	move.w	#5,-(sp)
	move.w	#26,-(sp)
	trap	#14
	addq	#4,sp
	ENDM

e_mfp	MACRO			;macro to enable most mfp interupts
	move.w	#12,-(sp)
	move.w	#27,-(sp)
	trap	#14
	addq	#4,sp
	move.w	#11,-(sp)
	move.w	#27,-(sp)
	trap	#14
	addq	#4,sp
	move.w	#10,-(sp)
	move.w	#27,-(sp)
	trap	#14
	addq	#4,sp
	move.w	#9,-(sp)
	move.w	#27,-(sp)
	trap	#14
	addq	#4,sp
	move.w	#5,-(sp)
	move.w	#27,-(sp)
	trap	#14
	addq	#4,sp
	ENDM

* main program

	move.l	4(a7),a3	; base page
	move.l	#mystack,a7
	move.l	$c(a3),d0	; text len
	add.l	$14(a3),d0	; data len
	add.l	$1c(a3),d0	; BSS len
	add.l	#$100,d0	; basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1		; release memory
	add.l	#12,sp

	super

	MOVE.W	#$FFFF,2000

	move.l	#-1,-(sp)	;disable mouse
	move.l	#-1,-(sp)
	clr.l	-(sp)
	trap	#14
	add	#12,sp

	clr.w	-(sp)		;set screen parameters
	move.l	#472064,-(sp)
	move.l	#472064,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add	#12,sp

	move.l	$70,oldint

	move.l	#intro,a0	;depack title screen
	move.l	#402000,a1
	move.l	#8000,d7
dep2	move.l	(a0)+,(a1)+
	dbf	d7,dep2
	move.l	#$00400040,402002
	move.l	#$00400040,402006
	move.l	#$00400040,402010
	move.l	#$00400040,402014
	move.w	#$0040,402032

	move.l	#pal2,pal_ptr
	move.l	#1,d0
	move.l	#music1,a0
	jsr	(a0)
	move.l	#1,d0
	move.l	#music2,a0
	jsr	(a0)
	move.l	#1,d0
	move.l	#music3,a0
	jsr	(a0)
	move.l	#1,d0
	move.l	#music4,a0
	jsr	(a0)
	move.l	#1,d0
	move.l	#music5,a0
	jsr	(a0)
	move.l	#1,d0
	move.l	#music6,a0
	jsr	(a0)
	move.l	#1,d0
	move.l	#music7,a0
	jsr	(a0)
	move.l	#music1,mus_ptr

	move.l	#main,a0	;depack main screen
	move.l	#367000,a1
	move.l	#8000,d7
dep1	move.l	(a0)+,(a1)+
	dbf	d7,dep1

	move.l	#font,a0	;depack font
	move.l	#437000,a1
	bsr	decrunch

	move.l	#472064,a0	;copy screen
	move.l	#367034,a1
	move.l	#7999,d7
p_cpy_2	move.l	(a1)+,(a0)+
	dbf	d7,p_cpy_2

	sub.l	#2,a0		;copy border stuff
	move.l	#402034,a1
	move.l	#1279,d7
b_cpy	move.l	(a1)+,(a0)+
	dbf	d7,b_cpy

	move.l	#$ff8240,a0	;copy palette
	move.l	#367002,a1
	move.l	#7,d7
c_pal_2	move.l	(a1)+,(a0)+
	dbf	d7,c_pal_2

	move.l	#$800,d4	;set up scroll registers
	moveq.l	#1,d1		;for interupts
	move.l	#11,d7
	movem.l	d0-a6,vb2_reg
	jsr	resmes		;scroll once normally

	d_mfp			;disable most mfp ints

	move.l	#vbl2,$70	;main routine on vbl

* check for key and act on acordingly

m_loop	move.w	#7,-(sp)	;test for key
	trap	#1
	addq	#2,sp

nx2	cmp.b	#"(",d0		;scroll speed check
	bne	nx3
	move.w	#4,speed
	bra	m_loop
nx3	cmp.b	#")",d0
	bne	nx4
	move.w	#3,speed
	bra	m_loop
nx4	cmp.b	#"/",d0
	bne	nx5
	move.w	#2,speed
	bra	m_loop
nx5	cmp.b	#"*",d0
	bne	nx6
	move.w	#1,speed
	bra	m_loop

nx6	cmp.b	#"1",d0		;change music
	bne	nx7
	move.l	#music1,mus_ptr
	bra	m_loop
nx7	cmp.b	#"2",d0
	bne	nx8
	move.l	#music2,mus_ptr
	bra	m_loop
nx8	cmp.b	#"3",d0
	bne	nx9
	move.l	#music3,mus_ptr
	bra	m_loop
nx9	cmp.b	#"4",d0
	bne	nx10
	move.l	#music4,mus_ptr
	bra	m_loop
nx10	cmp.b	#"5",d0
	bne	nx11
	move.l	#music5,mus_ptr
	bra	m_loop
nx11	cmp.b	#"6",d0
	bne	nx12
	move.l	#music6,mus_ptr
	bra	m_loop
nx12	cmp.b	#"7",d0
	bne	nx14
	move.l	#music7,mus_ptr
	bra	m_loop

nx14	cmp.b	#"0",d0		;50/60hz
	bne	nx99
	eor.w	#$222,367002
	bra	m_loop

nx99	bra	m_loop

* terminate routine

term	clr.b	$426		;quit
	move.l	oldint,$70
	move.l	#$08080000,$ff8800
	move.l	#$09090000,$ff8800
	move.l	#$0a0a0000,$ff8800
	move.w	#37,-(sp)
	trap	#14
	addq	#2,sp
	and.w	#$222,367002
	cmp.w	#$222,367002
	bne	t2
	eor.b	#2,$ff820a
t2	unsuper
	e_mfp
	clr.w	-(sp)
	trap	#1

* reset for games routine

reset2	clr.b	$426
	move.l	oldint,$70
	move.l	#$08080000,$ff8800
	move.l	#$09090000,$ff8800
	move.l	#$0a0a0000,$ff8800
	move.w	#37,-(sp)
	trap	#14
	addq	#2,sp
	and.w	#$222,367002
	cmp.w	#$222,367002
	bne	t3
	move.w	#1,1998
t3	move.w	#$2700,sr	;thanx to Dave C B, (writer of
	movea.l	0,a7		; Stampede, for the new
	movea.l	4,a0		; reset routine.
	jmp	(a0)
fin	bra.s	fin

* depacker source

decrunch:	movem.l d0-a6,-(sp)
		cmpi.l	#'Ice!',(a0)+	; Is data packed?
		bne.s	ice_03		; no!
		move.l	(a0)+,d0	; read packed data
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		movea.l a1,a4
		movea.l a1,a6
		adda.l	(sp),a6
		movea.l a6,a3
		bsr.s	ice_08
		bsr.s	ice_04
		bsr	ice_0c		;; Picture decrunch!
		bcc.s	ice_03		;; These marked lines may be
		move.w	#$0f9f,d7	;; removed in your own sources
ice_00:		moveq	#3,d6		;; if you do not use the
ice_01:		move.w	-(a3),d4	;; additional algorithm.
		moveq	#3,d5		;;
ice_02:		add.w	d4,d4		;;
		addx.w	d0,d0		;;
		add.w	d4,d4		;;
		addx.w	d1,d1		;;
		add.w	d4,d4		;;
		addx.w	d2,d2		;;
		add.w	d4,d4		;;
		addx.w	d3,d3		;;
		dbra	d5,ice_02	;;
		dbra	d6,ice_01	;;
		movem.w d0-d3,(a3)	;;
		dbra	d7,ice_00	;;
ice_03:		movem.l (sp)+,d0-a6
		rts
ice_04:		bsr.s	ice_0c
		bcc.s	ice_07
		moveq	#0,d1
		bsr.s	ice_0c
		bcc.s	ice_06
		lea	ice_1a(pc),a1
		moveq	#4,d3
ice_05:		move.l	-(a1),d0
		bsr.s	ice_0f
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice_05
		add.l	20(a1),d1
ice_06:		move.b	-(a5),-(a6)
		dbra	d1,ice_06
ice_07:		cmpa.l	a4,a6
		bgt.s	ice_12
		rts
ice_08:		moveq	#3,d0
ice_09:		move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice_09
		rts
ice_0a:		move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0b
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice_11
ice_0b:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice_11
ice_0c:		add.l	d7,d7
		beq.s	ice_0d
		rts
ice_0d:		move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0e
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice_0e:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice_0f:		moveq	#0,d1
ice_10:		add.l	d7,d7
		beq.s	ice_0a
ice_11:		addx.w	d1,d1
		dbra	d0,ice_10
		rts
ice_12:		lea	ice_1b(pc),a1
		moveq	#3,d2
ice_13:		bsr.s	ice_0c
		dbcc	d2,ice_13
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice_14
		bsr.s	ice_0f
ice_14:		move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice_16
		lea	ice_1c(pc),a1
		moveq	#1,d2
ice_15:		bsr.s	ice_0c
		dbcc	d2,ice_15
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice_0f
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice_18
ice_16:		moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice_0c
		bcc.s	ice_17
		moveq	#8,d0
		moveq	#$40,d2
ice_17:		bsr.s	ice_0f
		add.w	d2,d1
ice_18:		lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice_19:		move.b	-(a1),-(a6)
		dbra	d4,ice_19
		bra	ice_04
		DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
		DC.B $00,$07,$00,$02,$00,$03,$00,$01
		DC.B $00,$03,$00,$01
ice_1a:		DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
		DC.B $00,$00,$00,$07,$00,$00,$00,$04
		DC.B $00,$00,$00,$01
ice_1b:		DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
		DC.B $01,$00
ice_1c:		DC.B $0b,$04,$07,$00,$01,$20,$00,$00
		DC.B $00,$20

* vbl 2 routine

vbl2	movem.l	d0-a6,-(sp)
	movem.l	pal1,d0-3
	move.b	#2,$ff820a
	movem.l	d0-3,$ff8240
	movem.l	bod_reg,d0-a6
	jsr	border
	movem.l	d0-a6,bod_reg
	move.l	mus_ptr,a0
	addq.l	#8,a0
	jsr	(a0)
	movem.l	vb2_reg,d0-a6
	jsr	cnt
	movem.l	d0-a6,vb2_reg
	jsr	volbar
	movem.l	(sp)+,d0-a6
	rte

* volume bar routine

volbar	clr.l	d0

	move.b	#8,$ff8800		vol of chan a
	move.b	$ff8800,d0
	and.l	#$0000000f,d0
	move.l	#18,d1
	sub.l	d0,d1

	move.l	#502478,a0			draw vol bar 1
draw1	move.w	#$ff,(a0)
	move.w	#$ffff,8(a0)
	move.w	#$ffff,16(a0)
	move.w	#$ffff,24(a0)
	move.w	#$ffff,32(a0)
	move.w	#$ff00,40(a0)
	sub.l	#160,a0
	move.w	#$ff,(a0)
	move.w	#$ffff,8(a0)
	move.w	#$ffff,16(a0)
	move.w	#$ffff,24(a0)
	move.w	#$ffff,32(a0)
	move.w	#$ff00,40(a0)
	sub.l	#320,a0
	dbf	d0,draw1
clr1	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	clr.w	32(a0)
	clr.w	40(a0)
	sub.l	#160,a0
	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	clr.w	32(a0)
	clr.w	40(a0)
	sub.l	#320,a0
	dbf	d1,clr1

	clr.l	d0

	move.b	#9,$ff8800		vol of chan b
	move.b	$ff8800,d0
	and.l	#$0000000f,d0
	move.l	#18,d1
	sub.l	d0,d1

	move.l	#502526,a0			draw vol bar 2
draw2	move.w	#$ff,(a0)
	move.w	#$ffff,8(a0)
	move.w	#$ffff,16(a0)
	move.w	#$ffff,24(a0)
	move.w	#$ffff,32(a0)
	move.w	#$ff00,40(a0)
	sub.l	#160,a0
	move.w	#$ff,(a0)
	move.w	#$ffff,8(a0)
	move.w	#$ffff,16(a0)
	move.w	#$ffff,24(a0)
	move.w	#$ffff,32(a0)
	move.w	#$ff00,40(a0)
	sub.l	#320,a0
	dbf	d0,draw2
clr2	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	clr.w	32(a0)
	clr.w	40(a0)
	sub.l	#160,a0
	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	clr.w	32(a0)
	clr.w	40(a0)
	sub.l	#320,a0
	dbf	d1,clr2


 	clr.l	d0

	move.b	#$a,$ff8800		vol of chan c
	move.b	$ff8800,d0
	and.l	#$0000000f,d0
	move.l	#18,d1
	sub.l	d0,d1

	move.l	#502574,a0			draw vol bar 3
draw3	move.w	#$ff,(a0)
	move.w	#$ffff,8(a0)
	move.w	#$ffff,16(a0)
	move.w	#$ffff,24(a0)
	move.w	#$ffff,32(a0)
	move.w	#$ff00,40(a0)
	sub.l	#160,a0
	move.w	#$ff,(a0)
	move.w	#$ffff,8(a0)
	move.w	#$ffff,16(a0)
	move.w	#$ffff,24(a0)
	move.w	#$ffff,32(a0)
	move.w	#$ff00,40(a0)
	sub.l	#320,a0
	dbf	d0,draw3
clr3	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	clr.w	32(a0)
	clr.w	40(a0)
	sub.l	#160,a0
	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	clr.w	32(a0)
	clr.w	40(a0)
	sub.l	#320,a0
	dbf	d1,clr3

	rts

* scroll routine, (from menu 3)

resmes	move.l	#message,mes_p	;move message addr to mes pointer
nxtlet	movea.l	mes_p,a2	;move pointer to a2
	moveq.l	#0,d0		;clear d reg
	move.b	(a2)+,d0	;get char and increment pointer
	cmpi.w	#$ff,d0		;end of message?
	beq	resmes		;yes? restart
	subi.w	#32,d0		;so space=0, not 32 etc.
	move.l	a2,mes_p	;copy pointer back to buffer
	asl.w	#2,d0		;multi by 4, use l-words not bytes
	movea.l	#fnt_tbl,a2	;font table addr
	adda.l	d0,a2		;plus char no=addr of offset
	move.l	#437000,a6	;font data
	adda.l	(a2),a6		;plus offset
	adda.l	#5160,a6	;start from end of char,miss palette data,miss 3 bitplanes
	move.l	a6,chr_ptr	;move font ops to buffer

****************************scroll routine*********************

	move.l	#$8000,d4
	moveq.l	#1,d1
	moveq.l	#15,d7
tcb	movea.l	#472064,a4	;move scr addr for working with
	adda.l	#37116,a4	;offset to start of work area
	moveq.w	#31,d6		;no of lines+1 to scroll
lines	andi.w  #$ffef,sr	;clear extend bit in status register
	roxl.w	(a4)		;roll with extend left
	roxl.w	-8(a4)		;the left most bit of the word
	roxl.w	-16(a4)		;is copied to the extend bit
	roxl.w	-24(a4)		;in the status register
	roxl.w	-32(a4)		;the other 15 bits are shifted
	roxl.w	-40(a4)		;one bit to the left
	roxl.w	-48(a4)		;and the right most bit
	roxl.w	-56(a4)		;has what was previously in
	roxl.w	-64(a4)		;the status register copied
	roxl.w	-72(a4)		;into it.
	roxl.w	-80(a4)		
	roxl.w	-88(a4)		
	roxl.w	-96(a4)		
	roxl.w	-104(a4)	
	roxl.w	-112(a4)	
	roxl.w	-120(a4)	
	roxl.w	-128(a4)	
	roxl.w	-136(a4)	
	roxl.w	-144(a4)	
	roxl.w	-152(a4)	

	move.w	(a6),d0		;start copying new char
	and.w	d4,d0		;has bit got to be copied
	beq	no_coa		;no? miss some code
	or.w	#1,(a4)		;add bit required
no_coa	sub.l	#160,a6		;position to start of next line
	sub.l	#160,a4		;do same with screen
	dbf	d6,lines	;do all rows
	sub.w	#1,buff		;no. scrolls per vbl
	bne	cont		;if no. gone, reset buff
	move.w	speed,buff
cont	ror.w	d4		;next mask
	move.l	chr_ptr,a6	;to correct registers
	move.w	speed,d0
	move.w	buff,d2
	cmp.b	d2,d0
	bne	cnt
	rts

cnt	dbf	d7,tcb		;do half char
	addq.l	#8,chr_ptr	;second half pos on big chars
	move.l	chr_ptr,a6	;put it in the correct register
	subq.l	#1,d1		;done both halfs of big char?
	bmi	nxtlet		;yes, get next letter poss
	moveq.l	#15,d7		;16 pixels between next char get
	bra	tcb		;loop back to do it again

* border routine

border	ori.b	#1,$fffa07	;i just rip em,
	ori.b	#1,$fffa13	;i dont know how they work
	clr.b	$fffa1b		;so there's no
	move.b	#22,$fffa21	;comments..
	move.b	#8,$fffa1b
	bclr	#0,$fffa0f
	move.l	#border3,$120
	move.b	#2,$ff820a
	rts

border3	clr.b	$fffa1b
	move.w	#$707,$ff8240
	move.b	#5,$fffa21
	move.b	#8,$fffa1b
	move.l	#border4,$120
	bclr	#0,$fffa0f
	rte

border4	clr.b	$fffa1b
	move.l	#$04040000,$ff8240
	move.w	#$0777,$ff8244
	move.b	#1,$fffa21
	move.b	#8,$fffa1b
	move.l	#borde5,$120
	bclr	#0,$fffa0f
	move.w	#49,ras_scr
	rte

ras_scr	dc.w	0

borde5	clr.b	$fffa1b
	move.b	#1,$fffa21
	move.b	#8,$fffa1b
	bclr	#0,$fffa0f
	subq.w	#1,ras_scr
	bmi	borde1
	addq.l	#2,pal_ptr
	move.l	a0,bod_reg
	move.l	pal_ptr,a0
	cmp.w	#$ff,(a0)
	beq	bored1
	move.w	(a0),$ff8242
	move.l	#borde5,$120
	move.l	bod_reg,a0
	rte
borde1	move.l	#border5,$120
	move.b	#5,$fffa21
	rte
bored1	move.l	#pal2,pal_ptr
	move.w	#0,$ff8242
	move.l	#borde5,$120
	move.l	bod_reg,a0
	rte

border5	clr.b	$fffa1b
	move.w	#$0202,$ff8240
	move.b	#5,$fffa21
	move.b	#8,$fffa1b
	move.l	#border6,$120
	bclr	#0,$fffa0f
	rte

border6	clr.b	$fffa1b
	clr.w	$ff8240
	movem.l	d0-3,-(sp)
	movem.l	pal1,d0-3
	move.b	#2,$ff820a
	movem.l	d0-3,$ff8240
	movem.l	(sp)+,d0-3
	move.b	#55,$fffa21
	move.b	#8,$fffa1b
	move.l	#border7,$120
	bclr	#0,$fffa0f
	rte

border7	clr.b	$fffa1b
	movem.l	d0-7,-(sp)
	movem.l	367002,d0-7
	move.b	#2,$ff820a
	movem.l	d0-7,$ff8240
	movem.l	(sp)+,d0-7
	move.b	#55,$fffa21
	move.b	#8,$fffa1b
	move.l	#border8,$120
	bclr	#0,$fffa0f
	rte

border8	clr.b	$fffa1b
	move.w	#$0070,$ff8240
	move.b	#5,$fffa21
	move.b	#8,$fffa1b
	move.l	#border9,$120
	bclr	#0,$fffa0f
	rte

border9	clr.b	$fffa1b
	move.w	#$040,$ff8240
	move.b	#1,$fffa21
	move.b	#8,$fffa1b
	move.l	#border2,$120
	bclr	#0,$fffa0f
	movem.l	d0-3,-(sp)
	movem.l	402002,d0-3
	move.b	#2,$ff820a
	movem.l	d0-3,$ff8240
	movem.l	(sp)+,d0-3
	rte

border2	clr.b	$fffa1b
	move.l	d0,-(sp)
	move	sr,-(sp)
	move.w	#$2700,sr
	move.w	#$e,d0
wt1	nop
	dbf	d0,wt1
	move.b	#0,$ff820a
	move.w	#$c,d0
wt2	nop
	dbf	d0,wt2
	move.b	#2,$ff820a
	movem.l	d0-7,-(sp)
	movem.l	402002,d0-7
	move.b	#2,$ff820a
	movem.l	d0-7,$ff8240
	movem.l	(sp)+,d0-7
	move	(sp)+,sr
	move.l	(sp)+,d0
	bclr	#0,$fffa0f
	rte

* labels n prog space

	ds.l	100		stack space
mystack	ds.w	1		(stacks go backwards)
oldint	dc.l	0
oldsp	dc.l	0
vb2_reg	ds.l	13		;buffs for vbl2 regs
	ds.l	100
stck	dc.l	0
	ds.l	200
clr_mem	dc.l	0

* message + other scrolltext stuff

chr_ptr	dc.l	0
speed	dc.w	4
buff	dc.w	4
message	DC.B	" ONLY A SHORT SCROLLTEXT AS I'M VERY PUSHED FOR"
	DC.B	" TIME RIGHT NOW, (I'VE GOT 5 LOTS OF A LEVEL"
	DC.B	" HOMEWORK TO FINISH, A MENU 5 ADAPTATION TO DO"
	DC.B	" FOR BLUEBEARD, AND MORE, ALL BY TOMMOROW,"
	DC.B	" (MONDAY 24TH SEPTEMBER, ALSO THE RELEASE DATE"
	DC.B	" FOR THIS), I ALSO HAVE ENOUGH HACKING, PACKING,"
	DC.B	" RIPPING AND CODING WORK SITTING ON MY DESK TO"
	DC.B	" LAST ME TILL CHRISTMAS).."
	DC.B	" SO I'LL KEEP IT SHORT, FIRST NEWS, CREDITS,"
	DC.B	" THANX, AND THEN GREETINGS. O.K.."
	DC.B	" AND NO LONG GAPS..                           "
	DC.B	" O.K. SO I'M A BORN FIBBER.."
	DC.B	" PRESS 1-7 FOR MUSIX, AND ()/* FOR SCROLL SPEED.."
	DC.B	" NEWS, EXPECT TO SEE DPAINT ON AN SSS MENU SOON AS"
	DC.B	" MOBEY DICK AND MYSELF WILL BE BUYING IT NEXT WEEK,"
	DC.B	" YOU CAN EXPECT MOST OF THE MANUAL ON DISK AS WELL"
	DC.B	" IF ONE OF US GETS THE TIME.."
	DC.B	" ALSO I NOW HAVE OVER 40 PICTURES FOR FUTURE MENUS,"
	DC.B	" (I'VE JUST SPENT A DAY RIPPING THEM ALL).."
	DC.B	" NEXT, EXPECT TO SEE MY DEMO, (WRITTEN IN CO-OPERATION"
	DC.B	" WITH THE PENGUIN), AROUND CHRISTMAS, WE ALSO HAVE"
	DC.B	" MOBEY DICK WORKING ON SOME IDEAS FOR IT RIGHT NOW.."
	DC.B	" LASTLY, THIS IS NOT AN SSS MENU, BUT JUST A"
	DC.B	" CROSSBONES INTRO, (IT WOULD HAVE BEEN ON A MENU,"
	DC.B	" BUT ICE PACK 2.11 MADE THE GAME GO WRONG AFTER THE"
	DC.B	" FIRST LEVEL.  AREN'T YOU LUCKY I CHECK THESE THINGS).."
	DC.B	" CREDITS, ALL CODE, CROSSBONES, RASTER PALETTES, THE"
	DC.B	" CABIN BOY, IDEAS, MOBEY DICK, (AND INDIRECTLY, THE ALIEN),"
	DC.B	" MUSIX RIPPED BY ZIPPY OF THE MEDWAY BOYS,"
	DC.B	" GRAFIX, CROSSBONES.."
	DC.B	" THANX TO, ZIPPY FOR THE MUSIX, THE ALIEN FOR SOME IDEAS,"
	DC.B	" MOBEY DICK FOR SOME IDEAS, THE PENGUIN FOR CODING HELP,"
	DC.B	" BLUEBEARD FOR MUCKING UP MY MENU 3 CODE WHILE TRYING TO"
	DC.B	" WRITE MENU 5, (WHY DO I HAVE TO FIX IT? YOU MUCKED IT"
	DC.B	" UP!!).."
	DC.B	" MEGA BORING GREETINGS TIME.."
	DC.B	" THE COFFIN, GILBERT, ACCESS, BLUEBEARD, MOBEY DICK,"
	DC.B	" THE PARROT, SKULL, THE CABIN BOY, DARREN (KENT),"
	DC.B	" ZIPPY, WIZPOP, THE MIGHTY CLOG, THE ALIEN, ANY OTHER"
	DC.B	" MEMBERS OF THE POMPEY PIRATES, SEWER SOFTWARE,"
	DC.B	" KING, CLAIR C (COUGH COUGH, SMOKE BOMBS AT SCHOOL!),"
	DC.B	" CLAIR M, KIM G, TONI R, LYNNE C,"
	DC.B	" LYNNE K, GOODAY AND GOODAY, JK, JF, ANDREW SE,"
	DC.B	" ANDREW ST, ANDREW C, ADAM H, JAMIE H, CHRIS F,"
	DC.B	" MAUREEN, SPANNAH, GINA I, JAKIE I,"
	DC.B	" KENNY, GRAHAM P, DEXTER A (GOOD LUCK), MELANIE B,"
	DC.B	" CARLA, RACHEL, MARTIN B (BANG!!), OWEN G, SHAWN P,"
	DC.B	" SIAN N, AND ELAINE.."
	DC.B	" NORMAL BORING GREETS.."
	DC.B	" MEGAWOT, JAILHOUSE, DEFJAM, UZI, DREAM WEAVERS,"
	DC.B	" AUTOMATION (LSD/WAS (NOT WAS) WORKED A LOT BETTER),"
	DC.B	" REPLICANTS, TLB, TCB, LEVEL 16, D.I., THE EMPIRE,"
	DC.B	" ATARI, SONY, BEST BYTE, SOFTVILLE, JIFFY,"
	DC.B	" KAM, GUARDIANS OF LOGIK, OH SH*T, IS THAT THE TIME,"
	DC.B	" IF YOU'VE APPEARED ON A PREVIOUS MENU GREETINGS,"
	DC.B	" YOU SHOULD HAVE BEEN ON THIS ONE, BUT I'M OUT OF TIME,"
	DC.B	" SO LET'S WRAP.. "
	dc.b	$ff
mes_p	dc.l	0
fnt_tbl	dc.l	0,16,32,48,64,80,96,112,128,144
	dc.l	5120,5136,5152,5168,5184,5200,5216,5232,5248,5264
	dc.l	10240,10256,10272,10288,10304,10320,10336,10352,10368,10384
	dc.l	15360,15376,15392,15408,15424,15440,15456,15472,15488,15504
	dc.l	20480,20496,20512,20528,20544,20560,20576,20592,20608,20624
	dc.l	25600,25616,25632,25648,25664,25680,25696,25712,25728,25744

* palettes (for scroller)

pal1	dc.w	0,$111,$222,$333,$444,$555,$666,$777
pal2	dc.w	$100,$200,$300,$400,$500,$600,$700
	dc.w	$710,$720,$730,$740,$750,$760,$770
	dc.w	$771,$772,$773,$774,$775,$776,$777
	dc.w	$677,$577,$477,$377,$277,$177,$077
	dc.w	$067,$057,$047,$037,$027,$017,$007
	dc.w	$006,$005,$004,$003,$002,$001
	dc.w	0,0,0,0,0,0,0,0,0
	dc.w	$ff
pal_ptr	dc.l	0
bod_reg	ds.l	13

* include files

mus_ptr	dc.l	0
intro	incbin	"a:\predator.int\scroll.pi1"
main	incbin	"a:\predator.int\top.pi1"
music1	incbin	"a:\predator.int\cuddly.mus"
music2	incbin	"a:\predator.int\cuddly1.mus"
music3	incbin	"a:\predator.int\cuddly2.mus"
music4	incbin	"a:\predator.int\cuddly3.mus"
music5	incbin	"a:\predator.int\land.mus"
music6	incbin	"a:\predator.int\warp1.mus"
music7	incbin	"a:\predator.int\teramis1.mus"
font	incbin	"a:\predator.int\font.pi1"
