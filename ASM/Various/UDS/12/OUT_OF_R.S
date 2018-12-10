***************************************************************************
*	Out of Reach demo, hops„ttning av alla rutiner 940321-??????      *
***************************************************************************
	section	text

	jsr	first_init
	jsr	save_mfp
	jsr	set_mfp
	jsr	init_sam

	move.l	#scrblk,a0
	move.w	#168*365*2/4,d0
clr:	move.l	#0,(a0)+
	dbf.w	d0,clr

***************************************************************************
*	Main loop							  *
***************************************************************************
main_loop:
	jsr	set_screen
	jsr	vsync

	cmp.b	#57,$fffffc02.w
	beq	slut

*	Counter f”r delarna

	addq.w	#1,timer

	move.w	timer,d0
	cmp.w	next,d0
	blt	.hopp
	move.l	#part_order,a0
	add.w	part_pointer,a0
	move.w	(a0),next
	move.l	2(a0),part
	addq.w	#6,part_pointer
.hopp:

	move.l	part,a0
	jsr	(a0)		; hoppa till den nuvarande delen

	bra	main_loop
***************************************************************************
intro_fade1:
	move.w	#$800,$ff8240
	rts
intro_fade2:
	move.w	#$100,$ff8240
	rts
intro_fade3:
	move.w	#$900,$ff8240
	rts
intro_fade4:
	move.w	#$200,$ff8240
	rts
intro_fade5:
	move.w	#$a00,$ff8240
	rts
intro_fade6:
	move.w	#$300,$ff8240
	rts
intro_fade7:
	move.w	#$b00,$ff8240
	rts
intro_fade8:
	move.w	#$400,$ff8240
	rts
intro_fade9:
	move.w	#$c00,$ff8240
	rts
intro_fade10:
	move.w	#$500,$ff8240
	rts
intro_fade11:
	move.w	#$d00,$ff8240
	rts
intro_fade12:
	move.w	#$600,$ff8240
	rts
intro_fade13:
	move.w	#$e00,$ff8240
	rts
intro_fade14:
	move.w	#$700,$ff8240
	rts
intro_fade15:
	move.w	#$f00,$ff8240
	rts
***************************************************************************
fadevit1:
	move.w	#$f22,$ff8240
	rts	
fadevit2:
	move.w	#$f44,$ff8240
	rts	
fadevit3:
	move.w	#$f66,$ff8240
	rts	
fadevit4:
	move.w	#$fff,$ff8240
	move.w	#$fff,$ff8242
	move.w	#$fff,$ff8244
	move.w	#$fff,$ff8246
	move.w	#$fff,$ff8248
	move.w	#$fff,$ff824a
	move.w	#$fff,$ff824c
	move.w	#$fff,$ff824e
	move.w	#$fff,$ff8250
	move.w	#$fff,$ff8252
	move.w	#$fff,$ff8254
	move.w	#$fff,$ff8256
	move.w	#$fff,$ff8258
	move.w	#$fff,$ff825a
	move.w	#$fff,$ff825c
	move.w	#$fff,$ff825e
	rts
setvit:
	move.w	#$666,$ff8240
	move.w	#$777,$ff8242
	move.w	#$666,$ff8244
	move.w	#$666,$ff8246
	move.w	#$666,$ff8248
	move.w	#$666,$ff824a
	move.w	#$666,$ff824c
	move.w	#$666,$ff824e
	move.w	#$666,$ff8250
	move.w	#$666,$ff8252
	move.w	#$666,$ff8254
	move.w	#$666,$ff8256
	move.w	#$666,$ff8258
	move.w	#$666,$ff825a
	move.w	#$666,$ff825c
	move.w	#$666,$ff825e
	rts
***************************************************************************
first_ana_logo:

	move.l	#analogga1,a0

	move.l	#scrblk,a1
	add.w	#160*90,a1
	move.w	#89,d0

.copy:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	dbf.w	d0,.copy

	move.l	#analogga2,a0

	move.l	#scrblk,a1
	add.l	#168*365,a1
	add.w	#160*90,a1
	move.w	#89,d0

.copy2:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	dbf.w	d0,.copy2

	rts
***************************************************************************
fadedownvit1:
	move.w	#$777,$ff8240
	move.w	#$777,$ff8242
	move.w	#$777,$ff8244
	move.w	#$777,$ff8246
	move.w	#$777,$ff8248
	move.w	#$777,$ff824a
	move.w	#$777,$ff824c
	move.w	#$777,$ff824e
	move.w	#$777,$ff8250
	move.w	#$777,$ff8252
	move.w	#$777,$ff8254
	move.w	#$777,$ff8256
	move.w	#$777,$ff8258
	move.w	#$777,$ff825a
	move.w	#$777,$ff825c
	move.w	#$77f,$ff825e
	rts
fadedownvit2:
	move.w	#$666,$ff8240
	move.w	#$666,$ff8242
	move.w	#$666,$ff8244
	move.w	#$666,$ff8246
	move.w	#$666,$ff8248
	move.w	#$666,$ff824a
	move.w	#$666,$ff824c
	move.w	#$666,$ff824e
	move.w	#$666,$ff8250
	move.w	#$666,$ff8252
	move.w	#$666,$ff8254
	move.w	#$666,$ff8256
	move.w	#$666,$ff8258
	move.w	#$66e,$ff825a
	move.w	#$667,$ff825c
	move.w	#$66f,$ff825e
	rts
fadedownvit3:
	move.w	#$555,$ff8240
	move.w	#$555,$ff8242
	move.w	#$555,$ff8244
	move.w	#$555,$ff8246
	move.w	#$555,$ff8248
	move.w	#$555,$ff824a
	move.w	#$555,$ff824c
	move.w	#$555,$ff824e
	move.w	#$555,$ff8250
	move.w	#$555,$ff8252
	move.w	#$555,$ff8254
	move.w	#$55d,$ff8256
	move.w	#$556,$ff8258
	move.w	#$55e,$ff825a
	move.w	#$557,$ff825c
	move.w	#$55f,$ff825e
	rts
fadedownvit4:
	move.w	#$444,$ff8240
	move.w	#$444,$ff8242
	move.w	#$444,$ff8244
	move.w	#$444,$ff8246
	move.w	#$444,$ff8248
	move.w	#$444,$ff824a
	move.w	#$444,$ff824c
	move.w	#$444,$ff824e
	move.w	#$444,$ff8250
	move.w	#$44c,$ff8252
	move.w	#$445,$ff8254
	move.w	#$44d,$ff8256
	move.w	#$446,$ff8258
	move.w	#$44e,$ff825a
	move.w	#$447,$ff825c
	move.w	#$44f,$ff825e
	rts
fadedownvit5:
	move.w	#$333,$ff8240
	move.w	#$333,$ff8242
	move.w	#$333,$ff8244
	move.w	#$333,$ff8246
	move.w	#$333,$ff8248
	move.w	#$333,$ff824a
	move.w	#$333,$ff824c
	move.w	#$33b,$ff824e
	move.w	#$334,$ff8250
	move.w	#$33c,$ff8252
	move.w	#$335,$ff8254
	move.w	#$33d,$ff8256
	move.w	#$336,$ff8258
	move.w	#$33e,$ff825a
	move.w	#$337,$ff825c
	move.w	#$33f,$ff825e
	rts
fadedownvit6:
	move.w	#$222,$ff8240
	move.w	#$222,$ff8242
	move.w	#$222,$ff8244
	move.w	#$222,$ff8246
	move.w	#$222,$ff8248
	move.w	#$22a,$ff824a
	move.w	#$223,$ff824c
	move.w	#$22b,$ff824e
	move.w	#$224,$ff8250
	move.w	#$22c,$ff8252
	move.w	#$225,$ff8254
	move.w	#$22d,$ff8256
	move.w	#$226,$ff8258
	move.w	#$22e,$ff825a
	move.w	#$227,$ff825c
	move.w	#$22f,$ff825e
	rts
fadedownvit7:
	move.w	#$111,$ff8240
	move.w	#$111,$ff8242
	move.w	#$111,$ff8244
	move.w	#$119,$ff8246
	move.w	#$112,$ff8248
	move.w	#$11a,$ff824a
	move.w	#$113,$ff824c
	move.w	#$11b,$ff824e
	move.w	#$114,$ff8250
	move.w	#$11c,$ff8252
	move.w	#$115,$ff8254
	move.w	#$11d,$ff8256
	move.w	#$116,$ff8258
	move.w	#$11e,$ff825a
	move.w	#$117,$ff825c
	move.w	#$11f,$ff825e
	rts
fadedownvit8:
	move.w	#$000,$ff8240
	move.w	#$008,$ff8242
	move.w	#$001,$ff8244
	move.w	#$009,$ff8246
	move.w	#$002,$ff8248
	move.w	#$00a,$ff824a
	move.w	#$003,$ff824c
	move.w	#$00b,$ff824e
	move.w	#$004,$ff8250
	move.w	#$00c,$ff8252
	move.w	#$005,$ff8254
	move.w	#$00d,$ff8256
	move.w	#$006,$ff8258
	move.w	#$00e,$ff825a
	move.w	#$007,$ff825c
	move.w	#$00f,$ff825e
	rts
***************************************************************************
init_zoom:
	move.l	#scrblk,a0
	move.w	#(365*2)-1,d7
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	move.l	#0,a1
	move.l	#0,a2
	move.l	#0,a3
	move.l	#0,a4
	move.l	#0,a5
	move.l	#0,a6
	
.cls_z:
	movem.l	d0-d6/a1-a6,(a0)
	movem.l	d0-d6/a1-a6,52(a0)
	movem.l	d0-d6/a1-a6,104(a0)
	move.l	d0,156(a0)
	add.w	#160,a0
	dbf.w	d7,.cls_z

	move.w	#28,$ff820e

	move.l	#hp,a0
	move.l	#put_pixel_1,(a0)+
	move.l	#put_pixel_2,(a0)+
	move.l	#put_pixel_3,(a0)+
	move.l	#put_pixel_4,(a0)+
	move.l	#put_pixel_5,(a0)+
	move.l	#put_pixel_6,(a0)+
	move.l	#put_pixel_7,(a0)+
	move.l	#put_pixel_8,(a0)+
	move.l	#put_pixel_9,(a0)+
	move.l	#put_pixel_10,(a0)+
	move.l	#put_pixel_11,(a0)+
	move.l	#put_pixel_12,(a0)+
	move.l	#put_pixel_13,(a0)+
	move.l	#put_pixel_14,(a0)+
	move.l	#put_pixel_15,(a0)+
	move.l	#put_pixel_16,(a0)+
	jsr	vsync
	rts
***************************************************************************
intro_zoom:

.hur:

	add.w	#96,storlek_y

	cmp.w	#13*3*96+96*2,storlek_y
	blt	.hopp
	move.w	#0,storlek_y
	move.w	#0,storlek_x
	add.w	#48*7*2,plus
	move.w	#136+16*7,x
	move.w	#216*96,y
	bra	.hur
.hopp:

	cmp.w	#13*3*96+96*2-96*3,storlek_y
	blt	.hopp2
	add.w	#$222,$ff8240
.hopp2:

	cmp.w	#96*3,storlek_y
	bgt	.hopp3
	sub.w	#$222,$ff8240
.hopp3:

	add.w	#96,storlek_x

	sub.w	#6,x
	sub.w	#216,y

	move.w	#1000,d0
.wait:	nop
	dbf.w	d0,.wait

	move.w	#27*200,d0
	move.w	#0,d1
	jsr	cls

	move.l	#picture,a0
	add.w	plus,a0
	move.l	#prerot,a1
	move.l	#zoom,a3	; f”r y
	move.l	srn,a4
	add.w	y,a4
	add.w	#160,a4
	move.l	#hp,a6

	add.w	storlek_y,a3

	move.w	#7-1,d0		; 6-1	y
yrader:
	move.w	#48-1,d1		; 70-1	x
	move.w	x,d6	; Vi skall starta p† X
	move.l	#zoom,a2	; f”r x
	add.w	storlek_x,a2
xrader:
	move.w	(a2)+,d2
	add.w	d2,d6
	addq.w	#1,d6

	tst.w	(a0)+
	beq.s	nodraw

	cmp.w	#450,d6
	bgt	nodraw

	move.w	d6,d3
	sub.w	d2,d3		; justering
	move.w	d3,d4
	lsr.w	#1,d3
	and.w	#%1111111111111000,d3
	move.w	d4,d5
	and.w	#%1111111111110000,d5
	sub.w	d5,d4
	lsl.w	#3,d4		; *8 f”r att passa prerotningen

	lsl.w	#7,d2		; *128
	add.w	d4,d2

	add.w	d3,a4		; g† till slutet f”r f”rra pixeln (sk„rmen(16-))

	move.w	(a1,d2),d5
	move.w	2(a1,d2),d4	; yrader
	move.w	(a3),d7
	add	d7,d7		; passa listan p† hopp variabler
	add	d7,d7
	move.l	(a6,d7),a5
	jsr	(a5)		; hoppa till put pixel

	sub.w	d3,a4
nodraw:
	dbf.w	d1,xrader
	move.w	(a3)+,d5
	addq.w	#1,d5
	mulu.w	#216,d5
	add.w	d5,a4		; l„gga till p† y
	dbf.w	d0,yrader

	rts
put_pixel_1:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	rts
put_pixel_2:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	rts
put_pixel_3:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	rts
put_pixel_4:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	rts
put_pixel_5:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	rts
put_pixel_6:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	rts
put_pixel_7:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	rts
put_pixel_8:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	or.w	d5,216*7(a4)
	or.w	d4,216*7+8(a4)
	rts
put_pixel_9:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	or.w	d5,216*7(a4)
	or.w	d4,216*7+8(a4)
	or.w	d5,216*8(a4)
	or.w	d4,216*8+8(a4)
	rts
put_pixel_10:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	or.w	d5,216*7(a4)
	or.w	d4,216*7+8(a4)
	or.w	d5,216*8(a4)
	or.w	d4,216*8+8(a4)
	or.w	d5,216*9(a4)
	or.w	d4,216*9+8(a4)
	rts
put_pixel_11:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	or.w	d5,216*7(a4)
	or.w	d4,216*7+8(a4)
	or.w	d5,216*8(a4)
	or.w	d4,216*8+8(a4)
	or.w	d5,216*9(a4)
	or.w	d4,216*9+8(a4)
	or.w	d5,216*10(a4)
	or.w	d4,216*10+8(a4)
	rts
put_pixel_12:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	or.w	d5,216*7(a4)
	or.w	d4,216*7+8(a4)
	or.w	d5,216*8(a4)
	or.w	d4,216*8+8(a4)
	or.w	d5,216*9(a4)
	or.w	d4,216*9+8(a4)
	or.w	d5,216*10(a4)
	or.w	d4,216*10+8(a4)
	or.w	d5,216*11(a4)
	or.w	d4,216*11+8(a4)
	rts
put_pixel_13:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	or.w	d5,216*7(a4)
	or.w	d4,216*7+8(a4)
	or.w	d5,216*8(a4)
	or.w	d4,216*8+8(a4)
	or.w	d5,216*9(a4)
	or.w	d4,216*9+8(a4)
	or.w	d5,216*10(a4)
	or.w	d4,216*10+8(a4)
	or.w	d5,216*11(a4)
	or.w	d4,216*11+8(a4)
	or.w	d5,216*12(a4)
	or.w	d4,216*12+8(a4)
	rts
put_pixel_14:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	or.w	d5,216*7(a4)
	or.w	d4,216*7+8(a4)
	or.w	d5,216*8(a4)
	or.w	d4,216*8+8(a4)
	or.w	d5,216*9(a4)
	or.w	d4,216*9+8(a4)
	or.w	d5,216*10(a4)
	or.w	d4,216*10+8(a4)
	or.w	d5,216*11(a4)
	or.w	d4,216*11+8(a4)
	or.w	d5,216*12(a4)
	or.w	d4,216*12+8(a4)
	or.w	d5,216*13(a4)
	or.w	d4,216*13+8(a4)
	rts
put_pixel_15:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	or.w	d5,216*7(a4)
	or.w	d4,216*7+8(a4)
	or.w	d5,216*8(a4)
	or.w	d4,216*8+8(a4)
	or.w	d5,216*9(a4)
	or.w	d4,216*9+8(a4)
	or.w	d5,216*10(a4)
	or.w	d4,216*10+8(a4)
	or.w	d5,216*11(a4)
	or.w	d4,216*11+8(a4)
	or.w	d5,216*12(a4)
	or.w	d4,216*12+8(a4)
	or.w	d5,216*13(a4)
	or.w	d4,216*13+8(a4)
	or.w	d5,216*14(a4)
	or.w	d4,216*14+8(a4)
	rts
put_pixel_16:
	or.w	d5,(a4)
	or.w	d4,8(a4)
	or.w	d5,216(a4)
	or.w	d4,216+8(a4)
	or.w	d5,216*2(a4)
	or.w	d4,216*2+8(a4)
	or.w	d5,216*3(a4)
	or.w	d4,216*3+8(a4)
	or.w	d5,216*4(a4)
	or.w	d4,216*4+8(a4)
	or.w	d5,216*5(a4)
	or.w	d4,216*5+8(a4)
	or.w	d5,216*6(a4)
	or.w	d4,216*6+8(a4)
	or.w	d5,216*7(a4)
	or.w	d4,216*7+8(a4)
	or.w	d5,216*8(a4)
	or.w	d4,216*8+8(a4)
	or.w	d5,216*9(a4)
	or.w	d4,216*9+8(a4)
	or.w	d5,216*10(a4)
	or.w	d4,216*10+8(a4)
	or.w	d5,216*11(a4)
	or.w	d4,216*11+8(a4)
	or.w	d5,216*12(a4)
	or.w	d4,216*12+8(a4)
	or.w	d5,216*13(a4)
	or.w	d4,216*13+8(a4)
	or.w	d5,216*14(a4)
	or.w	d4,216*14+8(a4)
	or.w	d5,216*15(a4)
	or.w	d4,216*15+8(a4)
	rts
***************************************************************************
init_fall1:

	move.l	#scrblk,a0
	move.w	#(365*2)-1,d7
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	move.l	#0,a1
	move.l	#0,a2
	move.l	#0,a3
	move.l	#0,a4
	move.l	#0,a5
	move.l	#0,a6
	
.cls_z:
	movem.l	d0-d6/a1-a6,(a0)
	movem.l	d0-d6/a1-a6,52(a0)
	movem.l	d0-d6/a1-a6,104(a0)
	move.l	d0,156(a0)
	add.w	#160,a0
	dbf.w	d7,.cls_z

	move.w	#4,$ff820e

	move.l	#falldata,a1

	move.w	(a1)+,x
	move.w	(a1)+,y
	move.w	(a1)+,stop
	add.w	#6,pointer
	move.w	(a1)+,x2fall
	move.w	(a1)+,y2fall
	move.w	(a1)+,stop2

	jsr	vsync

	move.w	#$0,$ff8240

	rts
***************************************************************************
fall1:

	move.w	#1000,d0
.wait:	nop
	dbf.w	d0,.wait

*	move.w	#$700,$ff8240

	move.l	#$0,$ff8a00
	move.l	#$0,$ff8a04
	move.l	#$0,$ff8a08
	move.l	#$0,$ff8a0c
	move.l	#$0,$ff8a10
	move.l	#$0,$ff8a14
	move.l	#$0,$ff8a18
	move.l	#$0,$ff8a1c

	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	#0,$ff8a30
	move.l	srn,a0
	move.l	a0,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	#21*365,$ff8a36	; X r„knare
	move.w	#1,$ff8a38	; Y r„knare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

	jsr	draw_boxes

	jsr	fallcube

	jsr	fallcube2

	rts

draw_boxes:

	move.l	#$ffffffff,$ff8a00
	move.l	#$ffffffff,$ff8a04
	move.l	#$ffffffff,$ff8a08
	move.l	#$ffffffff,$ff8a0c
	move.l	#$ffffffff,$ff8a10
	move.l	#$ffffffff,$ff8a14
	move.l	#$ffffffff,$ff8a18
	move.l	#$ffffffff,$ff8a1c

	move.l	#falldata+6*24,a1

	move.w	#23*6,d0
	move.w	pointer,d1
	sub.w	d1,d0
	ext.l	d0
	divs.w	#6,d0
	blt	.no_draw

.draw_box_loop:

	move.w	(a1),d1
	move.w	2(a1),d2

	move.w	#0,d3

	asr.w	#1,d1
	cmp.w	#160,d2
	blt	.flopp
	sub.w	#160,d2
	move.w	#160*168,d3
.flopp
	mulu.w	#168,d2

	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	#168-32+8,$ff8a30
	move.l	srn,a0
	add.w	#160,a0
	add.w	d1,a0
	add.w	d2,a0
	add.w	d3,a0
	add.w	#8,a0
	move.l	a0,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	#4,$ff8a36	; X r„knare
	move.w	#64,$ff8a38	; Y r„knare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

	sub.w	#6,a1

	dbf.w	d0,.draw_box_loop

.no_draw:

	rts
fallcube:
	move.l	#fallanim,a0
	add.w	#4*2*2,anim
	move.w	anim,d0
	cmp.w	stop,d0
	blt	.gt
	add.w	#6,pointer
	cmp.w	#25*6,pointer
	bge	.no_draw

	move.w	#0,anim

	move.l	#falldata,a1
	add.w	pointer,a1

	move.w	(a1)+,xfall
	move.w	(a1)+,yfall
	move.w	(a1)+,stop

.gt:
	add.w	anim,a0

	move.l	srn,a5
	add.w	#160,a5

	move.w	xfall,d0
	move.w	yfall,d1

	move.l	#cords,a6
	move.w	(a0)+,(a6)
	add.w	d0,(a6)
	move.w	(a0)+,2(a6)
	add.w	d1,2(a6)
	move.w	(a0)+,4(a6)
	add.w	d0,4(a6)
	move.w	(a0)+,6(a6)
	add.w	d1,6(a6)
	move.w	(a0)+,8(a6)
	add.w	d0,8(a6)
	move.w	(a0)+,10(a6)
	add.w	d1,10(a6)
	move.w	(a0)+,12(a6)
	add.w	d0,12(a6)
	move.w	(a0)+,14(a6)
	add.w	d1,14(a6)
	move.w	#0,16(a6)	; Colour (0-2)
	move.w	#0,18(a6)	; Medsols-clipping on(1)/off(0)

	jsr	fpoly

	rts

.no_draw:

	rts
fallcube2:
	move.l	#fallanim,a0
	add.w	#4*2*2,anim2
	move.w	anim2,d0
	cmp.w	stop2,d0
	blt	.gt
	add.w	#6,pointer
	cmp.w	#25*6,pointer
	bge	.no_draw

	move.w	#0,anim2

	move.l	#falldata,a1
	add.w	pointer,a1

	move.w	(a1)+,x2fall
	move.w	(a1)+,y2fall
	move.w	(a1)+,stop2

.gt:
	add.w	anim2,a0

	move.l	srn,a5
	add.w	#160,a5

	move.w	x2fall,d0
	move.w	y2fall,d1

	move.l	#cords,a6
	move.w	(a0)+,(a6)
	add.w	d0,(a6)
	move.w	(a0)+,2(a6)
	add.w	d1,2(a6)
	move.w	(a0)+,4(a6)
	add.w	d0,4(a6)
	move.w	(a0)+,6(a6)
	add.w	d1,6(a6)
	move.w	(a0)+,8(a6)
	add.w	d0,8(a6)
	move.w	(a0)+,10(a6)
	add.w	d1,10(a6)
	move.w	(a0)+,12(a6)
	add.w	d0,12(a6)
	move.w	(a0)+,14(a6)
	add.w	d1,14(a6)
	move.w	#0,16(a6)	; Colour (0-2)
	move.w	#0,18(a6)	; Medsols-clipping on(1)/off(0)

	jsr	fpoly

.no_draw:

	rts
***************************************************************************
***************************************************************************
*  Polygon rout by OB 940129-940130,At laaaaast a working poly rout !!	  *
*  Small bugs fixed during february -94					  *
***************************************************************************
*	move.l	#$70000,a5
*	add.w	srnp,a5		; Screen pointer
*
*	move.l	#cords,a6
*	move.w	x1,(a6)
*	move.w	y1,2(a6)
*	move.w	x2,4(a6)
*	move.w	y2,6(a6)
*	move.w	x3,8(a6)
*	move.w	y3,10(a6)
*	move.w	x4,12(a6)
*	move.w	y4,14(a6)
*	move.w	#0,16(a6)	; Colour (0-2)
*	move.w	#0,18(a6)	; Medsols-clipping on(1)/off(0)
*
*	jsr	poly
*
*	; svar = Om medsols-clippingen „r p† och polygonen har blivit
*	; bortklippt s† inneh†ller d0 en etta.
*
*	; Rutinen klipper nu ocks† mot nedre borden
***************************************************************************
	opt	o+,ow-
fpoly:

	move.l	#cords,a0
	move.l	#tabell,a1

	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	move.l	(a0),16(a1)
	move.l	4(a0),20(a1)
	move.l	8(a0),24(a1)
	move.l	12(a0),28(a1)

	move.w	2(a0),d0
	moveq.w	#0,d2
	cmp.w	6(a0),d0
	ble	.hopp
	move.w	6(a0),d0
	moveq.w	#4,d2
.hopp:
	cmp.w	10(a0),d0
	ble	.hopp2
	move.w	10(a0),d0
	moveq.w	#8,d2
.hopp2:
	cmp.w	14(a0),d0
	ble	.hopp3
	move.w	14(a0),d0
	move.w	#12,d2
.hopp3:
	move.w	d0,start

	move.w	2(a0),d0
	cmp.w	6(a0),d0
	bge	.hopp4
	move.w	6(a0),d0
.hopp4:
	cmp.w	10(a0),d0
	bge	.hopp5
	move.w	10(a0),d0
.hopp5:
	cmp.w	14(a0),d0
	bge	.hopp6
	move.w	14(a0),d0
.hopp6:
	move.w	d0,end

	move.l	(a1,d2),(a0)
	move.l	4(a1,d2),4(a0)
	move.l	8(a1,d2),8(a0)
	move.l	12(a1,d2),12(a0)

*	Kolla med/motsols

	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	6(a0),d3
	cmp.w	d3,d1
	ble	.h2pp
	move.w	d0,d5
	move.w	d2,d0
	move.w	d5,d2
	move.w	d1,d5
	move.w	d3,d1
	move.w	d5,d3
.h2pp:

	sub.w	d0,d2
	sub.w	d1,d3
	asl.w	#6,d2
	ext.l	d2
	divs.w	d3,d2	; d2=k
	move.w	d2,d4

	move.w	12(a0),d0
	move.w	14(a0),d1
	move.w	(a0),d2
	move.w	2(a0),d3
	cmp.w	d3,d1
	ble	.h2pp4
	move.w	d0,d5
	move.w	d2,d0
	move.w	d5,d2
	move.w	d1,d5
	move.w	d3,d1
	move.w	d5,d3
.h2pp4:
                                                                     
	sub.w	d0,d2
	sub.w	d1,d3
	bne	.big
	move.w	#32767,d2
	bra	.big2
.big:
	asl.w	#6,d2
	ext.l	d2
	divs.w	d3,d2	; d2=k
.big2:
	tst.w	18(a0)
	beq	.flip	; inget medsols-clip
	move.l	#1,d0
	cmp.w	d2,d4
	bgt	.end
	bra	.cont
.flip:
	cmp.w	d2,d4
	ble	.cont
	move.l	4(a0),d0
	move.l	12(a0),4(a0)
	move.l	d0,12(a0)
.cont:

*	h„r „r det slut med kolla med/motsols

	cmp.w	#150,start
	blt.w	.fly
	sub.w	#150,start
	sub.w	#150,end
	sub.w	#150,2(a0)
	sub.w	#150,6(a0)
	sub.w	#150,10(a0)
	sub.w	#150,14(a0)
	add.l	#150*168,a5
.fly:

	move.w	end,d0

	moveq.w	#0,d6	; A1
	moveq.w	#4,d7	; A2

	cmp.w	6(a0),d0
	bne	.hupp
	moveq.w	#4,d6
.hupp:
	cmp.w	14(a0),d0
	bne	.hupp2
	moveq.w	#0,d7
.hupp2:

*	First part

	move.w	6(a0),d0
	cmp.w	2(a0),d0
	beq	.second

	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	6(a0),d3
	cmp.w	d3,d1
	ble	.hpp
	move.w	d0,d5
	move.w	d2,d0
	move.w	d5,d2
	move.w	d1,d5
	move.w	d3,d1
	move.w	d5,d3
.hpp:
*	cmp.w	#199,d1
*	bgt	.second

	move.l	#lines,a2
	move.w	d1,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,a2

	move.w	d3,a6

	move.l	#bitar+4,a4

	sub.w	d0,d2
	sub.w	d1,d3
	asl.w	#6,d2
	ext.l	d2
	divs.w	d3,d2	; d2=k

	asl.w	#6,d0

	subq.w	#1,d3

	cmp.w	#199,a6
	ble	.skutta
	sub.w	#199,a6
	sub.w	a6,d3
.skutta:

	move.w	#%1111111111000000,d5	; Bara f”r att snabba upp

.loop:
	add.w	d2,d0
	move.w	d0,d4
	and.w	d5,d4
	move.l	(a4,d4),(a2)

	addq.w	#8,a2
	dbf.w	d3,.loop

*	Second part

.second:

	move.w	10(a0),d0
	cmp.w	6(a0),d0
	beq	.third

	move.w	4(a0),d0
	move.w	6(a0),d1
	move.w	8(a0),d2
	move.w	10(a0),d3
	cmp.w	d3,d1
	ble	.hpp2
	move.w	d0,d5
	move.w	d2,d0
	move.w	d5,d2
	move.w	d1,d5
	move.w	d3,d1
	move.w	d5,d3
.hpp2:
*	cmp.w	#199,d1
*	bgt	.third

	move.l	#bitar+4,a4
	sub.w	d6,a4

	move.l	#lines,a2
	add.w	d6,a2
	move.w	d1,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,a2

	move.w	d3,a6

	sub.w	d0,d2
	sub.w	d1,d3
	asl.w	#6,d2
	ext.l	d2
	divs.w	d3,d2	; d2=k

	asl.w	#6,d0

	subq.w	#1,d3

*	cmp.w	#199,a6
*	ble	.skutta2
*	sub.w	#199,a6
*	sub.w	a6,d3
*.skutta2:

	move.w	#%1111111111000000,d5	; Bara f”r att snabba upp

.loop2:
	add.w	d2,d0

	move.w	d0,d4
	and.w	d5,d4
	move.l	(a4,d4),(a2)

	addq.w	#8,a2
	dbf.w	d3,.loop2

*	Third part

.third:

	move.w	14(a0),d0
	cmp.w	10(a0),d0
	beq	.fourth

	move.w	8(a0),d0
	move.w	10(a0),d1
	move.w	12(a0),d2
	move.w	14(a0),d3
	cmp.w	d3,d1
	ble	.hpp3
	move.w	d0,d5
	move.w	d2,d0
	move.w	d5,d2
	move.w	d1,d5
	move.w	d3,d1
	move.w	d5,d3
.hpp3:
*	cmp.w	#199,d1
*	bgt	.fourth

	move.l	#bitar+4,a4
	sub.w	d7,a4

	move.l	#lines,a2
	add.w	d7,a2
	move.w	d1,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,a2

	move.w	d3,a6

	sub.w	d0,d2
	sub.w	d1,d3
	asl.w	#6,d2
	ext.l	d2
	divs.w	d3,d2	; d2=k

	asl.w	#6,d0

	subq.w	#1,d3

*	cmp.w	#199,a6
*	ble	.skutta3
*	sub.w	#199,a6
*	sub.w	a6,d3
*.skutta3:

	move.w	#%1111111111000000,d5	; Bara f”r att snabba upp

.loop3:
	add.w	d2,d0

	move.w	d0,d4
	and.w	d5,d4
	move.l	(a4,d4),(a2)

	addq.w	#8,a2
	dbf.w	d3,.loop3

*	Fourth part
.fourth:

	move.w	2(a0),d0
	cmp.w	14(a0),d0
	beq	.fill

	move.w	12(a0),d0
	move.w	14(a0),d1
	move.w	(a0),d2
	move.w	2(a0),d3
	cmp.w	d3,d1
	ble	.hpp4
	move.w	d0,d5
	move.w	d2,d0
	move.w	d5,d2
	move.w	d1,d5
	move.w	d3,d1
	move.w	d5,d3
.hpp4:
*	cmp.w	#199,d1
*	bgt	.fill

	move.l	#bitar,a4

	move.l	#lines,a2
	add.w	#4,a2
	move.w	d1,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,a2

	move.w	d3,a6

	sub.w	d0,d2
	sub.w	d1,d3
	asl.w	#6,d2
	ext.l	d2
	divs.w	d3,d2	; d2=k

	asl.w	#6,d0

	subq.w	#1,d3

*	cmp.w	#199,a6
*	ble	.skutta4
*	sub.w	#199,a6
*	sub.w	a6,d3
.skutta4:

	move.w	#%1111111111000000,d5	; Bara f”r att snabba upp

.loop4:
	add.w	d2,d0

	move.w	d0,d4
	and.w	d5,d4
	move.l	(a4,d4),(a2)

	addq.w	#8,a2

	dbf.w	d3,.loop4
.fill:
*	move.w	#$7,$ff8240

	move.w	end,d0
	cmp.w	start,d0
	beq	.end	; Ingen poly

	move.w	end,d7
*	cmp.w	#199,d7
*	ble	.noendchange
*	move.w	d7,d6
*	sub.w	#199,d6
*	sub.w	d6,d7
*.noendchange:
	sub.w	start,d7
	add.w	d7,d7

	move.l	#lines,a2
	move.w	start,d6
	add.w	d6,d6
	add.w	d6,d6
	add.w	d6,d6
	add.w	d6,a2

*	move.w	#$707,$ff8240

	move.l	#lines,a2
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a2
*	move.w	-2(a2),-4(a2)

	move.l	#-1,$ff8a00
	move.l	#-1,$ff8a04
	move.l	#-1,$ff8a08
	move.l	#-1,$ff8a0c
	move.l	#-1,$ff8a10
	move.l	#-1,$ff8a14
	move.l	#-1,$ff8a18
	move.l	#-1,$ff8a1c

	move.w	#-1,$ff8a2a
	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	#0,$ff8a30
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift

	move.l	#lines-4,a2
	move.l	#lines,a3
	move.l	#$ff8a28,a6
	move.w	start,d0
	move.w	d0,d1
	move.w	d0,d3
	lsl.w	#3,d3
	add.w	d3,a2
	add.w	d3,a3
	cmp.w	#190,d1
	bgt	.jippi
	mulu.w	#168,d1
	add.w	d1,a5
	bra	.jippa
.jippi:
	sub.w	#190,d1
	add.l	#31920,a5
	mulu.w	#168,d1
	add.w	d1,a5
.jippa:
	move.w	end,d2
	sub.w	d0,d2
	subq.w	#1,d2

*	cmp.w	#199,end
*	ble	.skutt
*	move.w	end,d7
*	sub.w	#199,d7
*	sub.w	d7,d2
*.skutt:

	move.l	a5,d7

	move.l	#.hopp_tabell+4,a5

 	move.l	#-1,d3

	move.l	#cords,a1
	cmp.w	#1,16(a1)
	blt	.col1
	bgt	.col3

	addq.w	#2,d7

*	Colour 1 and 2

.col1

.fill_loop:
	addq.w	#4,a2
	addq.w	#4,a3

	move.w	(a2)+,d4
	move.w	(a3)+,d5

	sub.w	d4,d5

	blt.s	.draw_0

	move.l	d7,a1
	add.w	d4,d4
	add.w	d4,a1

	move.l	(a5,d5),a4
	jmp	(a4)


*	Olika hopp alternativ

.draw_0:
	addq.w	#2,a2
	addq.w	#2,a3

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0
.end:
	rts

.draw_1:

	move.w	(a2)+,d5
	and.w	(a3)+,d5
	or.w	d5,(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_2:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	or.w	d1,8(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_3:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	move.w	d3,8(a1)
	or.w	d1,16(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_4:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	move.w	d3,8(a1)
	move.w	d3,16(a1)
	or.w	d1,24(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_5:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	move.w	d3,8(a1)
	move.w	d3,16(a1)
	move.w	d3,24(a1)
	or.w	d1,32(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_6:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	move.w	d3,8(a1)
	move.w	d3,16(a1)
	move.w	d3,24(a1)
	move.w	d3,32(a1)
	or.w	d1,40(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_7:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	move.w	d3,8(a1)
	move.w	d3,16(a1)
	move.w	d3,24(a1)
	move.w	d3,32(a1)
	move.w	d3,40(a1)
	or.w	d1,48(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_8:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	move.w	d3,8(a1)
	move.w	d3,16(a1)
	move.w	d3,24(a1)
	move.w	d3,32(a1)
	move.w	d3,40(a1)
	move.w	d3,48(a1)
	or.w	d1,56(a1)

	add	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_9:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00090001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_10:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000a0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_11:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000b0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_12:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000c0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_13:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000d0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_14:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000e0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_15:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000f0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_16:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00100001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_17:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00110001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_18:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00120001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_19:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00130001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.draw_20:

	move.w	(a2)+,(a6)
	move.w	(a3)+,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00140001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

*	Colour 3

.col3

	move.l	#.hopp_tabell2+4,a5

.fill_loop3:

	addq.w	#4,a2
	addq.w	#4,a3

	move.w	(a2)+,d4
	move.w	(a3)+,d5

	sub.w	d4,d5

	blt.s	.2draw_0

	move.l	d7,a1
	add.w	d4,d4
	add.w	d4,a1

	move.l	(a5,d5),a4
	jmp	(a4)

*	Olika hopp alternativ

.2draw_0:

	addq.w	#2,a2
	addq.w	#2,a3

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_1:

	move.w	(a3)+,d0
	and.w	(a2)+,d0
	or.w	d0,(a1)
	or.w	d0,2(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_2:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	or.w	d0,2(a1)
	or.w	d1,8(a1)
	or.w	d1,10(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_3:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	or.w	d0,2(a1)
	move.l	d3,8(a1)
	or.w	d1,16(a1)
	or.w	d1,18(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_4:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	or.w	d0,2(a1)
	move.l	d3,8(a1)
	move.l	d3,16(a1)
	or.w	d1,24(a1)
	or.w	d1,26(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_5:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	or.w	d0,2(a1)
	move.l	d3,8(a1)
	move.l	d3,16(a1)
	move.l	d3,24(a1)
	or.w	d1,32(a1)
	or.w	d1,34(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_6:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	or.w	d0,2(a1)
	move.l	d3,8(a1)
	move.l	d3,16(a1)
	move.l	d3,24(a1)
	move.l	d3,32(a1)
	or.w	d1,40(a1)
	or.w	d1,42(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_7:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	or.w	d0,2(a1)
	move.l	d3,8(a1)
	move.l	d3,16(a1)
	move.l	d3,24(a1)
	move.l	d3,32(a1)
	move.l	d3,40(a1)
	or.w	d1,48(a1)
	or.w	d1,50(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_8:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	or.w	d0,(a1)
	or.w	d0,2(a1)
	move.l	d3,8(a1)
	move.l	d3,16(a1)
	move.l	d3,24(a1)
	move.l	d3,32(a1)
	move.l	d3,40(a1)
	move.l	d3,48(a1)
	or.w	d1,56(a1)
	or.w	d1,58(a1)

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_9:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00090001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00090001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_10:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000a0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000a0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_11:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000b0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000b0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_12:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000c0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000c0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_13:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000d0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000d0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_14:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000e0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000e0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_15:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000f0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$000f0001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_16:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00100001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00100001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_17:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00110001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00110001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_18:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00120001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00120001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_19:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00130001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00130001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.2draw_20:

	move.w	(a2)+,d0
	move.w	(a3)+,d1

	move.w	d0,(a6)
	move.w	d1,$4(a6)
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00140001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!
	addq.w	#2,a1
	move.l	a1,$a(a6)	; flytta dest. adress till blitter chipet
	move.l	#$00140001,$e(a6)	; X och y r„knare 
	move.b	#%11000011,$14(a6)	; let's go !!!!

	add.l	#168,d7
	
	dbf.w	d2,.fill_loop

	move.l	#0,d0

	rts

.hopp_tabell:	dc.l	.draw_0,.draw_1,.draw_2,.draw_3,.draw_4,.draw_5,.draw_6,.draw_7,.draw_8,.draw_9,.draw_10,.draw_11,.draw_12,.draw_13,.draw_14,.draw_15,.draw_16,.draw_17,.draw_18,.draw_19,.draw_20
.hopp_tabell2:	dc.l	.2draw_0,.2draw_1,.2draw_2,.2draw_3,.2draw_4,.2draw_5,.2draw_6,.2draw_7,.2draw_8,.2draw_9,.2draw_10,.2draw_11,.2draw_12,.2draw_13,.2draw_14,.2draw_15,.2draw_16,.2draw_17,.2draw_18,.2draw_19,.2draw_20
***************************************************************************
***************************************************************************
dummy:	rts
***************************************************************************
***************************************************************************
*	Clear screen, d0 inneh†ller antal block (20*200), d1 - Offset	  *
***************************************************************************
cls:
	move.l	#$0,$ff8a00
	move.l	#$0,$ff8a04
	move.l	#$0,$ff8a08
	move.l	#$0,$ff8a0c
	move.l	#$0,$ff8a10
	move.l	#$0,$ff8a14
	move.l	#$0,$ff8a18
	move.l	#$0,$ff8a1c

	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	#0,$ff8a30
	move.l	srn,a0
	add.w	d1,a0
	move.l	a0,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	d0,$ff8a36	; X r„knare
	move.w	#1,$ff8a38	; Y r„knare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

	rts
***************************************************************************
*******************
* fade rutinen    *
*******************
fade	lea	.trans_lista,a2	; transfer list
	lea	.col_list,a3
.fade_lp	move.w	(a0),d1		; color from
	move.w	(a1),d2		; color to
	and.w	#$f00,d1	; just r
	and.w	#$f00,d2
	ror.w	#8,d1		; to lower nibble		
	ror.w	#8,d2		
	add.w	d1,d1
	add.w	d2,d2
	move.w	0(a2,d1.w),d3
	move.w	0(a2,d2.w),d4	
	cmp.w	d3,d4		; if eq goto green
	beq.s	.equal1
	cmp.w	d3,d4
	blt.s	.ner†t1
	add.w	#2,d3
	move.w	0(a3,d3.w),d3	; new color
	rol.w	#8,d3
	move.w	d3,d7		; total color data reg
	bra.s	.green
.ner†t1	sub.w	#2,d3	
	move.w	0(a3,d3.w),d3	
	rol.w	#8,d3
	move.w	d3,d7
	bra.s	.green
.equal1	move.w	0(a3,d3.w),d3	; new color
	rol.w	#8,d3
	move.w	d3,d7		; total color data reg
.green	move.w	(a0),d1		; color from
	move.w	(a1),d2		; color to
	and.w	#$0f0,d1	; just g
	and.w	#$0f0,d2
	ror.w	#4,d1		; to lower nibble		
	ror.w	#4,d2		
	add.w	d1,d1
	add.w	d2,d2
	move.w	0(a2,d1.w),d3
	move.w	0(a2,d2.w),d4	
	cmp.w	d3,d4		; if eq goto green
	beq.s	.equal2
	cmp.w	d3,d4
	blt.s	.ner†t2
	add.w	#2,d3
	move.w	0(a3,d3.w),d3	; new color
	rol.w	#4,d3
	or.w	d3,d7		; total color data reg
	bra.s	.blue
.ner†t2	sub.w	#2,d3	
	move.w	0(a3,d3.w),d3	
	rol.w	#4,d3
	or.w	d3,d7
	bra.s	.blue
.equal2	move.w	0(a3,d3.w),d3	; new color
	rol.w	#4,d3
	or.w	d3,d7		; total color data reg
.blue	move.w	(a0),d1		; color from
	move.w	(a1)+,d2	; color to
	and.w	#$00f,d1	; just b
	and.w	#$00f,d2
	add.w	d1,d1
	add.w	d2,d2
	move.w	0(a2,d1.w),d3
	move.w	0(a2,d2.w),d4	
	cmp.w	d3,d4		; if eq goto green
	beq.s	.equal3
	cmp.w	d3,d4
	blt.s	.ner†t3
	add.w	#2,d3
	move.w	0(a3,d3.w),d3	; new color
	or.w	d3,d7		; total color data reg
	bra.s	.save_col
.ner†t3	sub.w	#2,d3	
	move.w	0(a3,d3.w),d3	
	or.w	d3,d7
	bra.s	.save_col
.equal3	move.w	0(a3,d3.w),d3	; new color
	or.w	d3,d7		; total color data reg
.save_col
	move.w	d7,(a0)+	; save color
	dbf	d0,.fade_lp
	rts

.trans_lista	dc.w	1*2,3*2,5*2,7*2,9*2,11*2,13*2,15*2,2*2,4*2,6*2,8*2,10*2,12*2,14*2,16*2
.col_list	dc.w	$0,$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
***************************************************************************
****************
* First init   *
****************
first_init
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ustk

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldphys
	
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldlog
	
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,oldrez
	
	move.w	#0,-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	rts
***************************************************************************
*********************
* fixa mfp dj„veln  *
*********************
save_mfp	lea	s_buffer,a0
	move.l	$120.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$68.w,(a0)+
	move.w	sr,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	rts

set_mfp	move.w	#$2700,sr
	move.l	#hbl_68000,$68.w
	move.l	#vbl,$70.w
	move.l	#lo_border,$120.w
	move.b	#1,$fffffa07.w
	move.b	#0,$fffffa09.w
	bset	#0,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.b	#198,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	#$2300,sr
	rts

stop_mfp	lea	s_buffer,a0
	move.l	(a0)+,$120.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$68.w
	move.w	(a0)+,sr
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	bclr	#0,$fffffa13.w
	bset	#3,$fffffa17.w
	move.b	(a0)+,$fffffa21.w
	move.b	(a0)+,$fffffa1b.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts
	
***************************************************************************
*************
* init sam  *
*************
init_sam
	move.w	#37,-(sp)		; sync screen
	trap	#14
	addq.l	#2,sp

	move.w	#$2700,sr
	
	bset	#5,$fffffa07.w
	bset	#5,$fffffa13.w
	move.l	$0134.w,save_a
	move.l	#change_sam,$0134.w		; adr to sub
	move.b	#%10000001,$ffff8921.w
	
	lea	order,a0

	move.b	#0,$fffffa1f.w
	move.b	#0,$fffffa19.w
	move.b	#1,$fffffa1f.w
	move.b	#8,$fffffa19.w		; h„ndelser„knar l„ge

	move.b	1(a0),$ffff8903.w
	move.b	2(a0),$ffff8905.w
	move.b	3(a0),$ffff8907.w

	move.b	5(a0),$ffff890f.w
	move.b	6(a0),$ffff8911.w
	move.b	7(a0),$ffff8913.w

	move.b	#3,$ffff8901.w		; start dma
	move.w	#$2300,sr

	rts
***************************************************************************
***************
* change sam  *
***************
change_sam

	move.w	#$2700,sr
	bclr	#5,$fffffa0f.w

	move.l	a0,-(sp)

	add.l	#12,vilken_sam		; start end adr + times to play
	lea	order,a0
	add.l	vilken_sam,a0

	tst.l	(a0)			; look if end
	bge.s	order_ej_slut
	lea	order,a0
	move.l	#0,vilken_sam
order_ej_slut

	move.b	#0,$fffffa1f.w
	move.b	#0,$fffffa19.w
	move.b	11(a0),$fffffa1f.w
	move.b	#8,$fffffa19.w		; h„ndelser„knar l„ge
	
	move.b	1(a0),$ffff8903.w	; start adr
	move.b	2(a0),$ffff8905.w
	move.b	3(a0),$ffff8907.w

	move.b	1+4(a0),$ffff890f.w	; end adr
	move.b	2+4(a0),$ffff8911.w
	move.b	3+4(a0),$ffff8913.w

	move.l	(sp)+,a0

	move.w	#$2300,sr

	rte
***************************************************************************
****************
* Endif        *
****************
slut:
	jsr	stop_mfp

	move.w	#$2700,sr
	
	clr.b	$fffffa19.w
	move.l	save_a,$0134.w
	bclr	#5,$fffffa07.w
	bclr	#5,$fffffa13.w
	move.b	#0,$ffff8901.w		; dma off

	move.w	#$2300,sr

	move.w	oldrez,-(sp)
	move.l	oldphys,-(sp)
	move.l	oldlog,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#$777,$ff8240
	move.w	#$700,$ff8242
	move.w	#$70,$ff8244
	move.w	#$0,$ff8246

	move.w	#0,$ff820e
	
	move.l	ustk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1
	
***************************************************************************
*****************
* VBI och VSYNC *
*****************
vbl	move.w	#$2700,sr
	move.w	#2,top_count
	move.w	#1,vflag

	move.b	#0,$fffffa1b.w
	move.l	#soon_upper,$120.w
	move.b	#100,$fffffa21.w
	move.b	#4,$fffffa1b.w
	move.w	#$2300,sr
	rte

hbl_68000	subq.w	#1,top_count
	beq.s	.cont
	rte
.cont	move.b	#0,$fffffa1b.w
	move.l	#lo_border,$120.w
	move.b	#228,$fffffa21.w
	move.b	#8,$fffffa1b.w
	dcb.w	92-16,$4E71
	move.b	#0,$ffff820a.w
	addq.l	#6,sp
	move.b	#2,$ffff820a.w
	rte

lo_border	bclr	#0,$fffffa0f.w
	move.b	#0,$fffffa1b.w
	move.l	#hhb2,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.w	#$2300,sr
	dcb.w	128,$4E71
	rte

hhb2	move.b	#0,$ffff820a.w
	move.b	#0,$fffffa1b.w
	move.b	#2,$ffff820a.w
	addq.l	#6,sp
	rte

soon_upper
	move.w	#$2100,sr
	dcb.w	200,$4E71
	rte
	
vsync	tst.w	vflag
	beq.s	vsync
	clr.w	vflag
	rts

vsync2	cmp.w	vflag,d0		; d0 = parameter f”r antal vbi
	bgt.s	vsync2
	clr.w	vflag
	rts
	
***************************************************************************
**********************
* olika screenseters * 
**********************
change_screen
	move.l	a0,-(sp)
	move.l	screen,a0
	move.l	screen,screen+4
	move.l	a0,screen
	move.l	(sp)+,a0

set_screen
	addq.w	#1,flag
	cmp.w	#2,flag
	blt	set_screen2

	move.w	#0,flag
	move.b	screen+1,$ffff8201.w
	move.b	screen+2,$ffff8203.w
	move.b	screen+3,$ffff820d.w

	move.l	screen+4,srn

	rts

set_screen2
	move.b	screen+4+1,$ffff8201.w
	move.b	screen+4+2,$ffff8203.w
	move.b	screen+4+3,$ffff820d.w

	move.l	screen,srn

	rts	
***************************************************************************
	section	data
	
screen		dc.l	scrblk,scrblk+168*365
border		dc.w	0
s_super		dc.l	0
top_count	dc.w	34
		ds.l	100
tom:		dc.w	0
timer:		dc.w	0
part_pointer:	dc.w	0
storlek_x:	dc.w	0
storlek_y:	dc.w	0
l„ngd:		dc.w	0
plus:		dc.w	0
x:		dc.w	136+7*16
y:		dc.w	216*96
hp:		ds.l	16
pointer:	dc.w	0
jump_out:	dc.w	0

fallanim:	incbin	"fallanim.dat"

falldata:	dc.w	64*0,64*4,10*2*2*4
		dc.w	64*1,64*4,10*2*2*4
		dc.w	64*0,64*3,20*2*2*4
		dc.w	64*2,64*4,10*2*2*4
		dc.w	64*1,64*3,20*2*2*4
		dc.w	64*0,64*2,25*2*2*4
		dc.w	64*3,64*4,10*2*2*4
		dc.w	64*2,64*3,20*2*2*4
		dc.w	64*1,64*2,25*2*2*4
		dc.w	64*0,64*1,30*2*2*4
		dc.w	64*4,64*4,10*2*2*4
		dc.w	64*3,64*3,20*2*2*4
		dc.w	64*2,64*2,25*2*2*4
		dc.w	64*1,64*1,30*2*2*4
		dc.w	64*0,64*0,34*2*2*4
		dc.w	64*4,64*3,20*2*2*4
		dc.w	64*3,64*2,25*2*2*4
		dc.w	64*2,64*1,30*2*2*4
		dc.w	64*1,64*0,34*2*2*4
		dc.w	64*4,64*2,25*2*2*4
		dc.w	64*3,64*1,30*2*2*4
		dc.w	64*2,64*0,34*2*2*4
		dc.w	64*4,64*1,30*2*2*4
		dc.w	64*3,64*0,34*2*2*4
		dc.w	64*4,64*0,34*2*2*4

cords:		ds.w	10
start:		dc.w	0
end:		dc.w	0
anim:		dc.w	0
anim2:		dc.w	6*5


*	F„rdigroterade bitar upp†t och ned†t

inc:	set	0

bitar:
	rept 22

		dc.w	inc	
		dc.w	%1000000000000000
		dc.w	inc	
		dc.w	%1111111111111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1100000000000000
		dc.w	inc	
		dc.w	%0111111111111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1110000000000000
		dc.w	inc	
		dc.w	%0011111111111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111000000000000
		dc.w	inc	
		dc.w	%0001111111111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111100000000000
		dc.w	inc	
		dc.w	%0000111111111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111110000000000
		dc.w	inc	
		dc.w	%0000011111111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111000000000
		dc.w	inc	
		dc.w	%0000001111111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111100000000
		dc.w	inc	
		dc.w	%0000000111111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111110000000
		dc.w	inc	
		dc.w	%0000000011111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111111000000
		dc.w	inc	
		dc.w	%0000000001111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111111100000
		dc.w	inc	
		dc.w	%0000000000111111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111111110000
		dc.w	inc	
		dc.w	%0000000000011111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111111111000
		dc.w	inc	
		dc.w	%0000000000001111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111111111100
		dc.w	inc	
		dc.w	%0000000000000111
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111111111110
		dc.w	inc	
		dc.w	%0000000000000011
		ds.w	14*2
		dc.w	inc	
		dc.w	%1111111111111111
		dc.w	inc	
		dc.w	%0000000000000001
		ds.w	14*2

inc:	set	inc+4

	endr


picture:	incbin	"from.zom"
		incbin	"sweden.zom"
		incbin	"is.zom"
		incbin	"back.zom"
prerot:		incbin	"zoom.dat"
zoom:

low	set	0
hi	set	1
	rept	16

	dc.w low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low,low
	dc.w low,low,hi,low,low,low,hi,low,low,hi,low,low,low,hi,low,low,low,hi,low,low,low,hi,low,low,hi,low,low,low,hi,low,low,low,hi,low,low,hi,low,low,low,hi,low,low,low,hi,low,low,hi,low
	dc.w hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,low,hi,hi,low,hi,low
	dc.w hi,hi,hi,low,hi,hi,hi,hi,low,hi,hi,hi,low,hi,hi,hi,low,hi,hi,hi,hi,low,hi,hi,hi,low,hi,hi,hi,hi,low,hi,hi,hi,low,hi,hi,hi,low,hi,hi,hi,hi,low,hi,hi,hi,low

low	set	low+1
hi	set	hi+1
	endr


part_order:	dc.w	12
		dc.l	intro_fade1
		dc.w	24
		dc.l	intro_fade2
		dc.w	36
		dc.l	intro_fade3
		dc.w	48
		dc.l	intro_fade4
		dc.w	60
		dc.l	intro_fade5
		dc.w	72
		dc.l	intro_fade6
		dc.w	84
		dc.l	intro_fade7
		dc.w	96
		dc.l	intro_fade8
		dc.w	108
		dc.l	intro_fade9
		dc.w	120
		dc.l	intro_fade10
		dc.w	132
		dc.l	intro_fade11
		dc.w	144
		dc.l	intro_fade12
		dc.w	156
		dc.l	intro_fade13
		dc.w	168
		dc.l	intro_fade14
		dc.w	175
		dc.l	intro_fade15
		dc.w	176
		dc.l	fadevit1
		dc.w	177
		dc.l	fadevit2
		dc.w	178
		dc.l	fadevit3
		dc.w	179
		dc.l	fadevit4
		dc.w	180
		dc.l	first_ana_logo
		dc.w	181
		dc.l	fadedownvit1
		dc.w	182
		dc.l	fadedownvit2
		dc.w	183
		dc.l	fadedownvit3
		dc.w	184
		dc.l	fadedownvit4
		dc.w	185
		dc.l	fadedownvit5
		dc.w	186
		dc.l	fadedownvit6
		dc.w	187
		dc.l	fadedownvit7
		dc.w	350
		dc.l	fadedownvit8
		dc.w	351
		dc.l	fadedownvit6
		dc.w	352
		dc.l	fadedownvit4
		dc.w	353
		dc.l	fadedownvit2
		dc.w	354
		dc.l	setvit
		dc.w	315
		dc.l	init_zoom
		dc.w	515
		dc.l	intro_zoom
		dc.w	516
		dc.l	fadevit4
		dc.w	517
		dc.l	init_fall1
		dc.w	860
		dc.l	fall1
		dc.w	10000
		dc.l	dummy


order *********     beg  end   times
	dc.l	d,de,4-1
	dc.l	sam1a+128,sam1ae,1
	dc.l	sam1b+128,sam1be,1
	dc.l	sam2+128,sam2e,1
	dc.l	sam3+128,sam3e-630,1
	dc.l	sam2+128,sam2e,1
	dc.l	sam4+128,sam4e-630,1
	dc.l	sam5+128,sam5e,1
	dc.l	sam6+128,sam6e-630,1
	dc.l	sam5+128,sam5e,1
	dc.l	sam6+128,sam6e-630,1
	dc.l	sam2+128,sam2e,1
	dc.l	sam3+128,sam3e-630,1
	dc.l	sam2+128,sam2e,1
	dc.l	sam4+128,sam4e-630,1
	dc.l	sam5+128,sam5e,1
	dc.l	sam6+128,sam6e-630,1
	dc.l	sam5+128,sam5e,1
	dc.l	sam7+128,sam7e-630,1
	dc.l	sam11+128,sam11e-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam8+128,sam8e,1
	dc.l	sam9+128,sam9e-630,1
	dc.l	sam8+128,sam8e,1
	dc.l	sam10+128,sam10e-630,1
	dc.l	sam2+128,sam2e,1
	dc.l	sam3+128,sam3e-630,1
	dc.l	sam2+128,sam2e,1
	dc.l	sam4+128,sam4e-630,1
	dc.l	sam13+128,sam13e,1
	dc.l	sam14+128,sam14e-630,1
	dc.l	sam13+128,sam13e,1
	dc.l	sam14+128,sam14e-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam11+128,sam11e,1
	dc.l	sam8+128,sam8e,1
	dc.l	sam9+128,sam9e-630,1
	dc.l	sam8+128,sam8e,1
	dc.l	sam9+128,sam9e-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam13+128,sam13e,1
	dc.l	sam14+128,sam14e-630,1
	dc.l	sam13+128,sam13e,1
	dc.l	sam14+128,sam14e-630,1
	dc.l	sam2+128,sam2e,1
	dc.l	sam3+128,sam3e-630,1
	dc.l	sam2+128,sam2e,1
	dc.l	sam4+128,sam4e-630,1
	dc.l	sam11+128,sam11e,1
	dc.l	sam16+128,sam16e,1
	dc.l	sam17+128,sam17e-630,1
	dc.l	sam16+128,sam16e,1
	dc.l	sam18+128,sam18e-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam5+128,sam5e,1
	dc.l	sam6+128,sam6e-630,1
	dc.l	sam5+128,sam5e,1
	dc.l	sam6+128,sam6e-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam12a+128,sam12ae,1
	dc.l	sam12b+128,sam12be-630,1
	dc.l	sam16+128,sam16e,1
	dc.l	sam17+128,sam17e-630,1
	dc.l	sam16+128,sam16e,1
	dc.l	sam18+128,sam18e-630,1
	dc.l	sam19+128,sam19e,1
	dc.l	sam19+128,sam19e,1
	dc.l	sam19+128,sam19e,1
	dc.l	sam20+128,sam20e,1
	dc.l	-1


*	Saker att ladda fr†n disk

analogga1:	incbin	"ana1.dat"
analogga2:	incbin	"ana2.dat"

sam1a	incbin	'c:\oorfiles\1_a.avr'
sam1ae
sam1b	incbin	'c:\oorfiles\1_b.avr
sam1be
sam2	incbin	'c:\oorfiles\2.avr'
sam2e
sam3	incbin	'c:\oorfiles\3.avr'
sam3e
sam4	incbin	'c:\oorfiles\4.avr'
sam4e
sam5	incbin	'c:\oorfiles\5.avr'
sam5e
sam6	incbin	'c:\oorfiles\6.avr'
sam6e
sam7	incbin	'c:\oorfiles\7.avr'
sam7e
sam8	incbin	'c:\oorfiles\8.avr'
sam8e
sam9	incbin	'c:\oorfiles\9.avr'
sam9e
sam10	incbin	'c:\oorfiles\10.avr'
sam10e
sam11	incbin	'c:\oorfiles\11.avr'
sam11e
sam12a	incbin	'c:\oorfiles\12_a.avr'
sam12ae
sam12b	incbin	'c:\oorfiles\12_b.avr'
sam12be
sam13	incbin	'c:\oorfiles\13.avr'
sam13e
sam14	incbin	'c:\oorfiles\14.avr'
sam14e
sam15	incbin	'c:\oorfiles\15.avr'
sam15e
sam16	incbin	'c:\oorfiles\16.avr'
sam16e
sam17	incbin	'c:\oorfiles\17.avr'
sam17e
sam18	incbin	'c:\oorfiles\18.avr'
sam18e
sam19	incbin	'c:\oorfiles\19.avr'
sam19e
sam20	incbin	'c:\oorfiles\20.avr'
sam20e
d	ds.b	1000
de
	section	bss
scrblk		ds.b	2*168*365
ustk		ds.l	1
oldphys		ds.l	1
oldlog		ds.l	1
oldrez		ds.l	1
svbi		ds.l	1
s_buffer		ds.b	50
s_pal		ds.w	16
hsync		ds.w	1
stack		ds.l	1
vflag		ds.w	1
part:		ds.l	1
next:		ds.w	1
flag:		ds.w	1
srn:		ds.l	1
savessp		ds.l	1
vilken_sam	ds.l	1
save_a		ds.l	1
xfall:		ds.w	1
yfall:		ds.w	1
stop:		ds.w	1
x2fall:		ds.w	1
y2fall:		ds.w	1
stop2:		ds.w	1
tabell:	ds.w	16
lines:	ds.l	512


	end
