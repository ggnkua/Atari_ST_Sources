***************************************************************************
*	TrackMania II Coded by Oskar Burman 930816-930???		  * 
***************************************************************************
*	opt	o+
MVOL	EQU $80
FREQ	EQU 2				; 0=6.259, 1=12.517, 2=25.036
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


	move.l	a7,a5
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	jsr	setsuper
	jsr	setscreen
	move.l	$70.w,oldvbi
	move.l	#newvbi,$70.w
	move.w	#$000,$ff8240
	move.w	#$204,$ff8242
	move.w	#$103,$ff8244
	move.w	#$315,$ff8246
	move.w	#$406,$ff8248
	move.w	#$507,$ff824a
	move.w	#$777,$ff8250
	move.w	#$777,$ff8252
	move.w	#$777,$ff8254
	move.w	#$777,$ff8256
	move.w	#$777,$ff8258
	move.w	#$777,$ff825a
	move.w	#$777,$ff825c
	move.w	#$777,$ff825e

	move.l	#$70000,a0
	move.w	#8000*2,d0
i:	clr.l	(a0)+
	dbf.w	d0,i

	move.l	#$ff8a00,a0
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+

	move.w	#2*115,vinkel
	move.w	#0,next

	move.l	#lat1,a0
	jsr	ladda

	move.l	#module,a0
	jsr	ice_decrunch_2

	move.l	#module,a0
	jsr	depack_module

	jsr	muson

***************************************************************************
mainloop:
	move.w	#$0,$ff8240
	jsr	waitvbl
	jsr	screenswap
*	move.w	#$7,$ff8240

	move.b	$fffc02,d0
	cmp.b	#57,d0
	beq	slut

	cmp.w	#0,next
	bne	n_event
	jsr	first_text
n_event:
	cmp.w	#1,next
	bne	n_event2

	add.w	#1,tim
	cmp.w	#20,tim
	blt	hj
	move.w	#0,tim
	move.w	#2,next
hj:

n_event2:
	cmp.w	#2,next
	bne	n_event3

	jsr	fade_down
	cmp.w	#1,fin
	bne	kl
	move.w	#3,next
	move.w	#0,fin
kl:
n_event3:
	cmp.w	#3,next
	bne	n_event4

	jsr	copy_cac_ana
	move.w	#4,next

n_event4:
	cmp.w	#4,next
	bne	n_event5

	add.w	#1,tim
	cmp.w	#25,tim
	blt	hj2
	move.w	#0,tim
	move.w	#5,next
hj2:
n_event5:
	cmp.w	#5,next
	bne	n_event6

	jsr	fade_up
	cmp.w	#1,fin
	bne	kl2
	move.w	#6,next
	move.w	#0,fin
	move.w	#0,pal_point
kl2:
n_event6:
	cmp.w	#6,next
	bne	n_event7

	add.w	#1,tim
	cmp.w	#85,tim
	blt	hj3
	move.w	#0,tim
	move.w	#7,next
hj3:
n_event7:
	cmp.w	#7,next
	bne	n_event8

	jsr	fade_down2
	cmp.w	#1,fin
	bne	kl3
	move.w	#8,next
	move.w	#0,fin
	move.w	#0,pal_point
kl3:
n_event8:
	cmp.w	#8,next
	bne	n_event9

	add.w	#1,tim
	cmp.w	#20,tim
	blt	hj4
	move.w	#0,tim
	move.w	#9,next
hj4:
n_event9:
	cmp.w	#9,next
	bne	n_event10

	jsr	copy_presents
	move.w	#10,next
n_event10:
	cmp.w	#10,next
	bne	n_event11

	jsr	fade_up2
	cmp.w	#1,fin
	bne	kl4
	move.w	#11,next
	move.w	#0,fin
	move.w	#0,pal_point
kl4:
n_event11:
	cmp.w	#11,next
	bne	n_event12

	add.w	#1,tim
	cmp.w	#50,tim
	blt	hj6
	move.w	#0,tim
	move.w	#12,next
hj6:
n_event12:
	cmp.w	#12,next
	bne	n_event13

	jsr	fade_down3
	cmp.w	#1,fin
	bne	kl5
	move.w	#13,next
	move.w	#0,fin
	move.w	#0,pal_point
kl5:
n_event13:
	cmp.w	#13,next
	bne	n_event14

	add.w	#1,tim
	cmp.w	#40,tim
	blt	hj41
	move.w	#0,tim
	move.w	#14,next
hj41:
n_event14:
	cmp.w	#14,next
	bne	n_event15

	jsr	copy_track_m
	move.w	#15,next
n_event15:
	cmp.w	#15,next
	bne	n_event16

	jsr	fade_up3
	cmp.w	#1,fin
	bne	kl51
	move.w	#16,next
	move.w	#0,fin
	move.w	#0,pal_point
kl51:
n_event16:

	jmp	mainloop
***************************************************************************
first_text:

	cmp.w	#0,fde
	beq	kt
	jsr	fade

	cmp.w	#1,next
	beq	ob

	cmp.w	#9,fde
	beq	jihoo
kt:

	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	#0,$ff8a30
	move.l	#$70006,a0	; flytta dest. adress till blitter chipet
	add.w	srnp,a0
	move.l	a0,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	#20*200,$ff8a36	; X rÑknare
	move.w	#1,$ff8a38	; Y rÑknare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; hîger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

*	move.w	#$2,$ff8240

	cmp.w	#0,fde
	bne	ob

	add.w	#14,vinkel
	cmp.w	#718,vinkel
	blt	hopp
	clr.w	vinkel
hopp:
	move.l	#cos,a0
	move.l	#sin,a1
	move.l	#data,a2
	add.w	font_p,a2

	move.l	#$70006,a3
	add.w	srnp,a3

	clr.w	d0
	move.w	vinkel,d1
	move.w	z,d4
loop:
	move.w	2(a2,d0),d2
	cmp.w	#$5678,d2
	beq	next_l
	cmp.w	#$1234,d2
	beq	io
	muls.w	(a0,d1),d2
	move.w	(a1,d1),d3
	muls.w	6(a2,d0),d3
	sub.l	d3,d2

	divs.w	d4,d2

	add.w	addx,d2		; x

	move.w	(a1,d1),d5
	muls.w	2(a2,d0),d5
	move.w	(a0,d1),d3
	muls.w	6(a2,d0),d3
	add.l	d3,d5

	divs.w	d4,d5

	add.w	addy,d5		; y

	move.w	d2,d6
	move.w	d5,d7
back:
			; next point

	move.w	(a0,d1),d2
	muls.w	10(a2,d0),d2
	move.w	(a1,d1),d3
	muls.w	14(a2,d0),d3
	sub.l	d3,d2

	divs.w	d4,d2

	add.w	addx,d2		; x

	move.w	(a1,d1),d5
	muls.w	10(a2,d0),d5
	move.w	(a0,d1),d3
	muls.w	14(a2,d0),d3
	add.l	d3,d5

	divs.w	d4,d5

	add.w	addy,d5		; y

	move.w	d2,d3

	move.w	d3,s1
	move.w	d5,s2

	movem.l	d0-d7/a0/a1,-(sp)
*	move.w	#$4,$ff8240
	move.w	d3,d0
	move.w	d5,d1
	move.w	d6,d2
	move.w	d7,d3
	jsr	line
*	move.w	#$30,$ff8240
	movem.l	(sp)+,d0-d7/a0/a1

	add.w	#16,d0
	cmp.w	#8*16,d0

	blt	loop

next_l:

	move.l	#cos,a0
	move.l	#sin,a1
	move.l	#data,a2
	add.w	font_p2,a2

	move.l	#$70006,a3
	add.w	srnp,a3

	clr.w	d0
	move.w	vinkel,d1
	move.w	z,d4
lloop:
	move.w	2(a2,d0),d2
	cmp.w	#$5678,d2
	beq	next_l2
	cmp.w	#$1234,d2
	beq	io2
	muls.w	(a0,d1),d2
	move.w	(a1,d1),d3
	muls.w	6(a2,d0),d3
	sub.l	d3,d2

	divs.w	d4,d2

	add.w	addx2,d2		; x

	move.w	(a1,d1),d5
	muls.w	2(a2,d0),d5
	move.w	(a0,d1),d3
	muls.w	6(a2,d0),d3
	add.l	d3,d5

	divs.w	d4,d5

	add.w	addy2,d5		; y

	move.w	d2,d6
	move.w	d5,d7
lback:
			; next point

	move.w	(a0,d1),d2
	muls.w	10(a2,d0),d2
	move.w	(a1,d1),d3
	muls.w	14(a2,d0),d3
	sub.l	d3,d2

	divs.w	d4,d2

	add.w	addx2,d2		; x

	move.w	(a1,d1),d5
	muls.w	10(a2,d0),d5
	move.w	(a0,d1),d3
	muls.w	14(a2,d0),d3
	add.l	d3,d5

	divs.w	d4,d5

	add.w	addy2,d5		; y

	move.w	d2,d3

	move.w	d3,s1
	move.w	d5,s2

	movem.l	d0-d7/a0/a1,-(sp)
*	move.w	#$4,$ff8240
	move.w	d3,d0
	move.w	d5,d1
	move.w	d6,d2
	move.w	d7,d3
	jsr	line
*	move.w	#$30,$ff8240
	movem.l	(sp)+,d0-d7/a0/a1

	add.w	#16,d0
	cmp.w	#8*16,d0

	blt	lloop

next_l2:

	cmp.w	#100,z
	bgt	slut2
	add.w	#3,z
	bra	ob
slut2:
	move.l	#$70000,a1
	move.w	addx,d0
	add.w	#16,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	sub.w	#8,d0
	add.w	d0,a1
	move.w	addy,d0
	sub.w	#10,d0
	mulu.w	#160,d0
	add.w	d0,a1
	move.l	a1,a3
	add.w	#32000,a3
	move.l	#font,a0
	move.l	#realtext,a2
	add.w	text_p,a2
	clr.l	d0
	move.b	(a2),d0
	sub.w	#32,d0
	cmp.w	#0,d0
	ble	jihoo
	mulu.w	#120,d0
	add.w	d0,a0
	move.w	#19,d1
on_stage:
	move.l	(a0),(a1)
	move.w	4(a0),4(a1)
	move.w	(a0),d2
	or.w	2(a0),d2
	or.w	4(a0),d2
	move.w	d2,6(a1)
	add.w	#160,a1
	move.l	(a0),(a3)
	move.w	4(a0),4(a3)
	move.w	(a0)+,d2
	or.w	(a0)+,d2
	or.w	(a0)+,d2
	move.w	d2,6(a3)
	add.w	#160,a3
	dbf.w	d1,on_stage
	move.w	#1,fde
jihoo:
	move.w	#40,z

	addq.w	#1,text_p
	move.l	#text,a0
	add.w	text_p,a0
	clr.l	d0
	move.b	(a0),d0
	cmp.w	#0,d0
	bne	no_next_rad
	add.w	#20,addy
	move.w	#40,addx
	bra	slut2
no_next_rad:
	cmp.w	#32,d0
	bne	op
	add.w	#16,addx
	bra	slut2
op:
	sub.w	#53,d0
	mulu.w	#4*4*8,d0
	move.w	d0,font_p
	add.w	#16,addx
	move.w	#210*2,vinkel

	cmp.w	#9,fde
	beq	jihoo2
slut3:
	move.l	#$70000,a1
	move.w	addx2,d0
	add.w	#16,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	sub.w	#8,d0
	add.w	d0,a1
	move.w	addy2,d0
	sub.w	#10,d0
	mulu.w	#160,d0
	add.w	d0,a1
	move.l	a1,a3
	add.w	#32000,a3
	move.l	#font,a0
	move.l	#realtext_end-1,a2
	sub.w	text_p2,a2
	clr.l	d0
	move.b	(a2),d0
	sub.w	#32,d0
	cmp.w	#0,d0
	ble	jihoo2
	mulu.w	#120,d0
	add.w	d0,a0
	move.w	#19,d1
on_stge:
	move.l	(a0),(a1)
	move.w	4(a0),4(a1)
	move.w	(a0),d2
	or.w	2(a0),d2
	or.w	4(a0),d2
	move.w	d2,6(a1)
	add.w	#160,a1
	move.l	(a0),(a3)
	move.w	4(a0),4(a3)
	move.w	(a0)+,d2
	or.w	(a0)+,d2
	or.w	(a0)+,d2
	move.w	d2,6(a3)
	add.w	#160,a3
	dbf.w	d1,on_stge
	move.w	#1,fde

jihoo2:

	addq.w	#1,text_p2
	move.l	#textend-1,a0
	sub.w	text_p2,a0
	clr.l	d0
	move.b	(a0),d0
	cmp.w	#0,d0
	bne	no_next_rad2
	sub.w	#20,addy2
	move.w	#232,addx2
	bra	slut3
no_next_rad2:
	cmp.w	#32,d0
	bne	op2
	sub.w	#16,addx2
	bra	slut3
op2:
	sub.w	#53,d0
	mulu.w	#4*4*8,d0
	move.w	d0,font_p2
	sub.w	#16,addx2
ob:
	rts
***************************************************************************
io:
	move.w	s1,d6
	move.w	s2,d7
	bra	back
***************************************************************************
io2:
	move.w	s1,d6
	move.w	s2,d7
	bra	lback
***************************************************************************
copy_cac_ana:

	move.l	#cac_ana,a0
	move.l	#$70000,a1
	move.l	#$70000+32000,a2
	move.w	#7998,d0
oskar:
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf.w	d0,oskar

	rts
***************************************************************************
copy_presents:

	move.l	#presents,a0
	move.l	#$70000,a1
	move.l	#$70000+32000,a2
	move.w	#7998,d0
oskar2:
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf.w	d0,oskar2

	rts
***************************************************************************
copy_track_m:

	move.l	#track_m,a0
	move.l	#$70000,a1
	move.l	#$70000+32000,a2
	move.w	#7998,d0
oskar3:
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf.w	d0,oskar3

	rts
***************************************************************************
main_key_check:

	move.b	$fffc02,d0
	cmp.b	#57,d0
	beq	slut

	cmp.b	#59,d0
	blt	no
	cmp.w	#60,d0
	bgt	no
	jsr	change_tune
no:

	rts
***************************************************************************
change_tune
	cmp.w	#59,d0
	bne	a1
	move.l	#lat1,a0
a1:	cmp.w	#60,d0
	bne	a2
	move.l	#lat2,a0
a2:
	jsr	musoff

	jsr	ladda

	move.l	#module,a0
	jsr	ice_decrunch_2

	move.l	#module,a0
	jsr	depack_module

	jsr	muson

	rts
***************************************************************************
ladda:
*	ôppna fil

	move.w	#0,-(sp)
	move.l	a0,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp

	move.w	d0,filnum


*	Ladda fil

	move.l	#module,-(sp)
	move.l	#150000,-(sp)
	move.w	filnum,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp

	rts
***************************************************************************
***************************************************************************
slut:
	jsr	musoff
preslut:
	move.l	oldvbi,$70

	move.w	#$777,$ff8240
	move.w	#$700,$ff8242
	move.w	#$70,$ff8244
	move.w	#$0,$ff8246

	jsr	endsuper

	clr.w	-(sp)
	trap	#1
;********************************************* Unpacking routine of PACK-ICE
; a0 = Adress of packed data
; "bsr" or "jsr" to ice_decrunch_2 with register a0 prepared.
ice_decrunch_2:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'ICE!',d0
	bne	.not_packed
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
	bmi.s	.no_Åber
.get_Åber:
	bsr.s	.get_d0_bits
.no_Åber:	move.b	6(a1,d2.w),d4
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
***************************************************************************
; depack routine for module packer
; In :
; a0 = Pointer on module
depack_module:

                bsr     analyse_module       ; find sample start/end

                bsr     init_depack

                movea.l sample_start(PC),A0  ; packed sample
                move.l  sample_end(PC),D0
                sub.l   A0,D0                ; unpacked length

                move.l  D0,-(A7)
                bsr     depack_sample        ; depack over source
                move.l  (A7)+,D0
                rts

; a0=module address

analyse_module: move.l  A0,-(A7)

                lea     $03b8(A0),A1

                moveq   #$7f,D0
                moveq   #0,D4
mt_loop:        move.l  D4,D2
                subq.w  #1,D0
mt_lop2:        move.b  (A1)+,D4
                cmp.b   D2,D4
                bgt.s   mt_loop
                dbra    D0,mt_lop2
                addq.b  #1,D2

                asl.l   #8,D2
                asl.l   #2,D2
                add.l   #$043c,D2
                move.l  D2,D1
                add.l   A0,D2
                movea.l D2,A2

                move.l  A2,sample_start

                moveq   #$1e,D0
mt_lop3:
                moveq   #0,D4
                move.w  42(A0),D4
                add.l   D4,D4
                adda.l  D4,A2
                adda.l  #$1e,A0
                dbra    D0,mt_lop3

                move.l  A2,sample_end

                movea.l (A7)+,A0

                rts

; a0=packed sample (also destination)
; d0=unpacked length

depack_sample:
                lea     depack_hi(PC),A2
                lea     depack_lo(PC),A3

                addq.l  #1,D0
                and.b   #-2,D0               ; round length up
                move.l  D0,D7
                lsr.l   #1,D7                ; sample length in words

                lea     0(A0,D0.l),A1        ; destination end
                adda.l  D7,A0                ; source end

                move.w  #128,D0              ; last byte
                moveq   #0,D1                ; clear temp

depack_loop:    move.b  -(A0),D1             ; get 2 distances
                add.b   0(A2,D1.w),D0
                move.b  D0,-(A1)
                add.b   0(A3,D1.w),D0
                move.b  D0,-(A1)

                subq.l  #1,D7
                bne.s   depack_loop

                rts

init_depack:

                lea     depack_lo(PC),A1
                move.w  #15,D7
init1:          lea     power_bytes(PC),A0
                move.w  #15,D6
init2:          move.b  (A0)+,(A1)+
                dbra    D6,init2
                dbra    D7,init1

                lea     power_bytes(PC),A0
                lea     depack_hi(PC),A1
                move.w  #15,D7
init3:          move.w  #15,D6
                move.b  (A0)+,D0
init4:          move.b  D0,(A1)+
                dbra    D6,init4
                dbra    D7,init3

                rts


power_bytes:    DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64

sample_start:   DC.L 0
sample_end:     DC.L 0

depack_lo:      DS.B 256
depack_hi:      DS.B 256

***************************************************************************
muson	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move	#$2700,sr

	bset	#5,$FFFFFA07.w
	bset	#5,$FFFFFA13.w

	clr.b	$FFFFFA19.w
	move.b	#1,$FFFFFA1F.w
	move.b	#8,$FFFFFA19.w

	move.l	$0134.w,oldtima
	move.l	#stereo,$0134.w

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

	move	#$2300,sr
	rts

musoff	move	#$2700,sr

	clr.b	$FFFFFA19.w		; Stop timers

	move.l	oldtima(pc),$0134.w	; Restore everything

	bclr	#5,$FFFFFA07.w
	bclr	#5,$FFFFFA13.w

	clr.b	$FFFF8901.w		; Stop DMA

	move	#$2300,sr
	rts

oldtima	DC.L 0

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
loopp	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loopp
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
	clr.w	wiz1pos			;

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
	clr.w	wiz2pos			;

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
	clr.w	wiz3pos			;

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
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
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
	lea	sin2(pc),a1
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

***************************************************************************

sin2	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
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

dmacon		DC.W $00
samplestarts	DS.L $1F

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

module:	ds.b	150000
	ds.b	20000
workspc:ds.w	1
***************************************************************************
fade_down:
	addq.w	#1,tim
	cmp.w	#4,tim
	bne	pe
	move.w	#0,tim

	move.l	#pal,a0
	add.w	pal_point,a0

	move.w	(a0),$ff8242
	move.w	2(a0),$ff8244
	move.w	4(a0