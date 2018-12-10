section	text
	
	jmp	main
	
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
	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savepal
	
	move.w	#0,-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	rts

**************
* init y rot *
**************
init_y_rot
	lea	y_add,a0
	moveq	#0,d0
	move.w	#200-1,d1
.precy	move.w	d0,(a0)+
	add.w	#160,d0
	dbf	d1,.precy
	
	lea	x_add,a0
	moveq	#0,d0
	moveq	#0,d1
	move.w	#20-1,d6
.precx1	move.w	#16-1,d7
	moveq	#0,d1
.precx2	move.w	d0,(a0)+
	move.w	d1,(a0)+
	add.w	#2560,d1
	dbf	d7,.precx2
	add.w	#8,d0
	dbf	d6,.precx1

*	Precalca 1an

	lea	bredd_add1,a0
	lea	slutmasker3,a2
	moveq	#0,d4			; list add

	move.w	#16-1,d7			; 16 olika scew
.precb1	move.w	#320-1,d6			; 320 olika 'breddar'
	lea	slutmasker,a1		; h„mta slutmasker
	lea	hopp_tab,a6
	add.l	d4,a1			; in i slutmasker
	move.w	(a2)+,d5			; h„mta ettan

.precb2	move.l	(a6),(a0)+		; hopp adr
	move.w	(a1)+,(a0)+		; slutmask 2

	tst.w	(a1)
	bne.s	.go_on
	add.l	#4,a6
	lea	slutmasker,a1
.go_on
	dbf	d6,.precb2
	add.l	#2,d4
	dbf	d7,.precb1

	moveq	#0,d1
	moveq	#0,d2
	move.w	#16-1,d7
	lea	bredd_add1+4,a2
.precb3	move.w	d7,d6
	lea	slutmasker2,a1
	move.l	a2,a0
	add.l	d2,a0
.precb4
	move.w	(a1)+,d0		; ettan och tv†an
	addq.w	#2,a1
	lsr.w	d1,d0
	move.w	d0,(a0)		; slutmask3	

	addq.l	#6,a0		; ner en rad
	dbf	d6,.precb4
	add.l	#1920,d2
	add.l	#1,d1
	dbf	d7,.precb3

*	Precalca 2an
gruff:
	lea	bredd_add2,a0
	lea	slutmasker5,a2
	moveq	#30,d4			; list add

	move.w	#16-1,d7			; 16 olika scew
.precb1	move.w	#320-1,d6			; 320 olika 'breddar'
	lea	slutmasker4,a1		; h„mta slutmasker
	lea	hopp_tab2,a6
	add.l	d4,a1			; in i slutmasker
	move.w	(a2)+,d5			; h„mta ettan

.precb2	move.l	(a6),(a0)+		; hopp adr
	move.w	(a1)+,(a0)+		; slutmask 2

	tst.w	(a1)
	bne.s	.go_on
	add.l	#4,a6
	lea	slutmasker4,a1
.go_on
	dbf	d6,.precb2
	sub.l	#2,d4
	dbf	d7,.precb1

	moveq	#0,d1
	move.l	#1920*15,d2
	move.w	#16-1,d7
	lea	bredd_add2+4,a2
.precb5	move.w	d7,d6
	lea	slutmasker6,a1
	move.l	a2,a0
	add.l	d2,a0
.precb6
	move.w	(a1)+,d0		; ettan och tv†an
	addq.w	#2,a1
	lsl.w	d1,d0
	move.w	d0,(a0)		; slutmask3	

	addq.l	#6,a0		; ner en rad
	dbf	d6,.precb6
	sub.l	#1920,d2
	add.l	#1,d1
	dbf	d7,.precb5

	rts

*********************
* Main och mainloop *
*********************
main	jsr	first_init
	jsr	init_y_rot

	move.w	#$700,$ff8242
	move.w	#$500,$ff8244
	move.w	#$300,$ff8246
	move.w	#$7,$ff8248
	move.w	#$5,$ff824a
	move.w	#$3,$ff824c
	move.w	#$70,$ff824e
	move.w	#$30,$ff8250
	move.w	#$770,$ff8252
	move.w	#$570,$ff8254
	move.w	#$370,$ff8256
	move.w	#$707,$ff8258
	move.w	#$507,$ff825a
	move.w	#$307,$ff825c
	move.w	#$777,$ff825e
	
	move.l	$70.w,svbi
	move.l	#vbi,$70.w
	
main_loop
	jsr	change_screen

	move.l	#0,$ff8a00
	move.l	#$0,$ff8a04
	move.l	#0,$ff8a08
	move.l	#$0,$ff8a0c
	move.l	#0,$ff8a10
	move.l	#$0,$ff8a14
	move.l	#0,$ff8a18
	move.l	#$0,$ff8a1c

	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#2,$ff8a2e
	move.w	#0,$ff8a30
	move.l	screen,a0
	move.l	a0,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	#80*100,$ff8a36	; X r„knare
	move.w	#1,$ff8a38	; Y r„knare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

	move.w	#$353,$ffff8240.w
	lea	koords,a0		; x1,y1,x2,y2,c
	move.l	screen,a1
	move.w	x1,(a0)
	move.w	y1,2(a0)
	move.w	x2,4(a0)
	move.w	y2,6(a0)
	move.w	#6,8(a0)
	jsr	do_yrot_poly
	move.w	#$0,$ffff8240.w
	jsr	vsync

	move.b	$fffffc02.w,d0
	cmp.b	#75,d0
	bne	.no1
	sub.w	#1,x1
.no1:
	cmp.b	#77,d0
	bne	.no2
	add.w	#1,x1
.no2:
	cmp.b	#72,d0
	bne	.no3
	sub.w	#1,y1
.no3:
	cmp.b	#80,d0
	bne	.no4
	add.w	#1,y1
.no4:
	cmp.b	#106,d0
	bne	.no5
	sub.w	#1,x2
.no5:
	cmp.b	#108,d0
	bne	.no6
	add.w	#1,x2
.no6:
	cmp.b	#104,d0
	bne	.no7
	sub.w	#1,y2
.no7:
	cmp.b	#110,d0
	bne	.no8
	add.w	#1,y2
.no8:

	cmp.b	#57,d0
	bne	main_loop
	bra	end

****************
* Do yrot poly *
****************	
do_yrot_poly
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7

	move.w	6(a0),d3
	cmp.w	2(a0),d3
	bge	.pytte_hopp
	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)
.pytte_hopp

	move.w	(a0),d0		; x1,y1,x2,y2,c
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	6(a0),d3
	move.w	8(a0),d4

	move.w	d3,d5
	sub.w	d1,d5
	cmp.w	#1,d5
	blt	draw_rectangle

*	Nu „r vi s„kra p† att triangeln skall ritas

	cmp.w	d0,d2
	blt	tv„rt_om

	jsr	self_modifying_1

	lea	x_add,a2
	lea	y_add,a3
	lea	bredd_add1,a4

	add.w	d0,d0		; x1*4
	add.w	d0,d0
	add.w	d1,d1		; y1*2

	add.w	(a2,d0.w),a1	; in p† sk„rmen
	add.w	(a3,d1.w),a1	; ner p† sk„rmen

	move.w	(a0),d7
	and.w	#%0000000000001111,d7
	move.w	d7,d4	; Spara tillf„lligt
	mulu.w	#1920,d7
	add.w	d7,a4	; r„tt skew och allt

	lea	slutmasker3,a5
	add.w	d4,d4
	move.w	(a5,d4),d5	; d5 inneh†ller slutmask1

	lea	lutning,a5

	sub.w	(a0),d2		; x2-x1
	moveq	#0,d0		; x1
	lsr.w	#1,d1		; y1/2 (utg†ngsl„ge!)

	move.w	d3,d4		; save y2
	sub.w	d1,d4		; y2-y1=ant scan

	sub.w	d1,d3		; y2-y1
	asl.w	#6,d2
	divs	d3,d2		; d3=k*64 (K „r inverterat)
	move.w	d2,d6		; spara k(d2)
	cmp.w	#416,d6
	bgt	.traff_pa_sidan
	move.w	#49,d7
	muls.w	d7,d6		; y*k=x (d6=x)
	asr.w	#6,d6
	muls	#100,d6
	bra	.hopp
.traff_pa_sidan:
	move.w	#319*64,d7
	divs.w	d6,d7
	neg.w	d7
	add.w	#49,d7
	muls.w	#100,d7
	move.w	d7,d6		; d6 „r adden
	add.l	#32000,a5
.hopp:
***	H„r plockar vi ut offsetten ur K tabellen

	add.w	d6,a5	; addar p† offsetten p† k-v„rdes tabellen

*	D6/D7 skall inneh†lla f„rgerna (bakl„nges !!!)
	move.l	col1,d6
	move.l	col2,d7
	move.l	d6,d0
	move.l	d7,d2

*	cmp.l	#$ffffffff,col2
*	beq	.kl
*	move.w	#$fff,$ff8240
*.kl
	move.l	a4,a6
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !
	move.l	(a4)+,a2		; bara f”r dumhuvet inte fattar...
	jmp	(a2)

*****	R1

r1
	addq.l	#6,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask
	move.w	d3,d1		; save and not it
	not.w	d1
mod1a	or.w	d3,-(a1)		; ut med plan 1-3
mod1b	or.w	d3,-(a1)
mod1c	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R2

r2
	add.l	#6+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod2a	or.w	d3,-(a1)		; ut med plan 1-3
mod2b	or.w	d3,-(a1)
mod2c	or.w	d3,-(a1)

	subq.w	#2,a1

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod2d	or.w	d3,-(a1)		; ut med plan 1-3
mod2e	or.w	d3,-(a1)
mod2f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R3

r3
	add.l	#6+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod3a	or.w	d3,-(a1)		; ut med plan 1-3
mod3b	or.w	d3,-(a1)
mod3c	or.w	d3,-(a1)

	subq.w	#2,a1

	move.l	d7,-(a1)
	move.w	d6,-(a1)

	subq.w	#2,a1

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod3d	or.w	d3,-(a1)		; ut med plan 1-3
mod3e	or.w	d3,-(a1)
mod3f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R4

r4
	add.l	#6+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod4a	or.w	d3,-(a1)		; ut med plan 1-3
mod4b	or.w	d3,-(a1)
mod4c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod4d	or.w	d3,-(a1)		; ut med plan 1-3
mod4e	or.w	d3,-(a1)
mod4f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R5

r5
	add.l	#6+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod5a	or.w	d3,-(a1)		; ut med plan 1-3
mod5b	or.w	d3,-(a1)
mod5c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod5d	or.w	d3,-(a1)		; ut med plan 1-3
mod5e	or.w	d3,-(a1)
mod5f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R6

r6
	add.l	#6+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod6a	or.w	d3,-(a1)		; ut med plan 1-3
mod6b	or.w	d3,-(a1)
mod6c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod6d	or.w	d3,-(a1)		; ut med plan 1-3
mod6e	or.w	d3,-(a1)
mod6f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R7

r7
	add.l	#6+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod7a	or.w	d3,-(a1)		; ut med plan 1-3
mod7b	or.w	d3,-(a1)
mod7c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod7d	or.w	d3,-(a1)		; ut med plan 1-3
mod7e	or.w	d3,-(a1)
mod7f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R8

r8
	add.l	#6+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod8a	or.w	d3,-(a1)		; ut med plan 1-3
mod8b	or.w	d3,-(a1)
mod8c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod8d	or.w	d3,-(a1)		; ut med plan 1-3
mod8e	or.w	d3,-(a1)
mod8f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R9

r9
	add.l	#6+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod9a	or.w	d3,-(a1)		; ut med plan 1-3
mod9b	or.w	d3,-(a1)
mod9c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod9d	or.w	d3,-(a1)		; ut med plan 1-3
mod9e	or.w	d3,-(a1)
mod9f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R10

r10
	add.l	#6+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod10a	or.w	d3,-(a1)		; ut med plan 1-3
mod10b	or.w	d3,-(a1)
mod10c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod10d	or.w	d3,-(a1)		; ut med plan 1-3
mod10e	or.w	d3,-(a1)
mod10f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R11

r11
	add.l	#6+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod11a	or.w	d3,-(a1)		; ut med plan 1-3
mod11b	or.w	d3,-(a1)
mod11c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod11d	or.w	d3,-(a1)		; ut med plan 1-3
mod11e	or.w	d3,-(a1)
mod11f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R12

r12
	add.l	#6+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod12a	or.w	d3,-(a1)		; ut med plan 1-3
mod12b	or.w	d3,-(a1)
mod12c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod12d	or.w	d3,-(a1)		; ut med plan 1-3
mod12e	or.w	d3,-(a1)
mod12f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R13

r13
	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod13a	or.w	d3,-(a1)		; ut med plan 1-3
mod13b	or.w	d3,-(a1)
mod13c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod13d	or.w	d3,-(a1)		; ut med plan 1-3
mod13e	or.w	d3,-(a1)
mod13f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R14

r14
	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod14a	or.w	d3,-(a1)		; ut med plan 1-3
mod14b	or.w	d3,-(a1)
mod14c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod14d	or.w	d3,-(a1)		; ut med plan 1-3
mod14e	or.w	d3,-(a1)
mod14f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R15

r15
	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod15a	or.w	d3,-(a1)		; ut med plan 1-3
mod15b	or.w	d3,-(a1)
mod15c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod15d	or.w	d3,-(a1)		; ut med plan 1-3
mod15e	or.w	d3,-(a1)
mod15f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R16

r16
	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod16a	or.w	d3,-(a1)		; ut med plan 1-3
mod16b	or.w	d3,-(a1)
mod16c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod16d	or.w	d3,-(a1)		; ut med plan 1-3
mod16e	or.w	d3,-(a1)
mod16f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R17

r17
	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod17a	or.w	d3,-(a1)		; ut med plan 1-3
mod17b	or.w	d3,-(a1)
mod17c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod17d	or.w	d3,-(a1)		; ut med plan 1-3
mod17e	or.w	d3,-(a1)
mod17f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R18

r18
	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod18a	or.w	d3,-(a1)		; ut med plan 1-3
mod18b	or.w	d3,-(a1)
mod18c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod18d	or.w	d3,-(a1)		; ut med plan 1-3
mod18e	or.w	d3,-(a1)
mod18f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R19

r19
	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod19a	or.w	d3,-(a1)		; ut med plan 1-3
mod19b	or.w	d3,-(a1)
mod19c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod19d	or.w	d3,-(a1)		; ut med plan 1-3
mod19e	or.w	d3,-(a1)
mod19f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R20

r20
	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	(a4)+,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
mod20a	or.w	d3,-(a1)		; ut med plan 1-3
mod20b	or.w	d3,-(a1)
mod20c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	d5,d3
	move.w	d3,d1		; save and not it
	not.w	d1
mod20d	or.w	d3,-(a1)		; ut med plan 1-3
mod20e	or.w	d3,-(a1)
mod20f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*	Rutinen som anropas om triangeln „r v„nd †t 'fel' h†ll.

tv„rt_om:

	jsr	self_modifying_2

	lea	x_add,a2
	lea	y_add,a3
	lea	bredd_add2,a4

	add.w	d0,d0		; x1*4
	add.w	d0,d0
	add.w	d1,d1		; y1*2

	add.w	(a2,d0.w),a1	; in p† sk„rmen
	add.w	(a3,d1.w),a1	; ner p† sk„rmen

	move.w	(a0),d7
	and.w	#%0000000000001111,d7
	move.w	d7,d4	; Spara tillf„lligt
	mulu.w	#1920,d7
	add.w	d7,a4	; r„tt skew och allt

	lea	slutmasker,a5
	add.w	d4,d4
	move.w	(a5,d4),d5	; d5 inneh†ller slutmask1

	lea	lutning,a5

	move.w	(a0),d2
	sub.w	4(a0),d2	; x1-x2
	moveq	#0,d0		; x1
	lsr.w	#1,d1		; y1/2 (utg†ngsl„ge!)

	move.w	d3,d4		; save y2
	sub.w	d1,d4		; y2-y1=ant scan

	sub.w	d1,d3		; y2-y1
	asl.w	#6,d2
	divs	d3,d2		; d3=k*64 (K „r inverterat)
	move.w	d2,d6		; spara k(d2)
	cmp.w	#416,d6
	bgt	.traff_pa_sidan
	move.w	#49,d7
	muls.w	d7,d6		; y*k=x (d6=x)
	asr.w	#6,d6
	muls	#100,d6
	bra	.hopp
.traff_pa_sidan:
	move.w	#319*64,d7
	divs.w	d6,d7
	neg.w	d7
	add.w	#49,d7
	muls.w	#100,d7
	move.w	d7,d6		; d6 „r adden
	add.l	#32000,a5
.hopp:
***	H„r plockar vi ut offsetten ur K tabellen

	add.w	d6,a5	; addar p† offsetten p† k-v„rdes tabellen

*	D6/D7 skall inneh†lla f„rgerna (bakl„nges !!!)
	move.l	col1,d6
	move.l	col2,d7
	move.l	d6,d0
	move.l	d7,d2

	add.w	#6,a1	; Korrigering

	move.l	a4,a6
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !
	move.l	(a4)+,a2		; bara f”r dumhuvet inte fattar...
	jmp	(a2)

*****	R1

tr1
*	add.l	#6,a1

	move.w	(a4)+,d3		; get slutmask
	move.w	d3,d1		; save and not it
	not.w	d1
tmod1a	or.w	d3,-(a1)		; ut med plan 1-3
tmod1b	or.w	d3,-(a1)
tmod1c	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	166(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R2

tr2
*	add.l	#6+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod2a	or.w	d3,-(a1)		; ut med plan 1-3
tmod2b	or.w	d3,-(a1)
tmod2c	or.w	d3,-(a1)

	subq.w	#2,a1

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod2d	or.w	d3,-(a1)		; ut med plan 1-3
tmod2e	or.w	d3,-(a1)
tmod2f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+14(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R3

tr3
*	add.l	#6+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod3a	or.w	d3,-(a1)		; ut med plan 1-3
tmod3b	or.w	d3,-(a1)
tmod3c	or.w	d3,-(a1)

	subq.w	#2,a1

	move.l	d7,-(a1)
	move.w	d6,-(a1)

	subq.w	#2,a1

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod3d	or.w	d3,-(a1)		; ut med plan 1-3
tmod3e	or.w	d3,-(a1)
tmod3f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+22(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R4

tr4
*	add.l	#6+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod4a	or.w	d3,-(a1)		; ut med plan 1-3
tmod4b	or.w	d3,-(a1)
tmod4c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod4d	or.w	d3,-(a1)		; ut med plan 1-3
tmod4e	or.w	d3,-(a1)
tmod4f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+30(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R5

tr5
*	add.l	#6+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod5a	or.w	d3,-(a1)		; ut med plan 1-3
tmod5b	or.w	d3,-(a1)
tmod5c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod5d	or.w	d3,-(a1)		; ut med plan 1-3
tmod5e	or.w	d3,-(a1)
tmod5f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+38(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R6

tr6
*	add.l	#6+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod6a	or.w	d3,-(a1)		; ut med plan 1-3
tmod6b	or.w	d3,-(a1)
tmod6c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod6d	or.w	d3,-(a1)		; ut med plan 1-3
tmod6e	or.w	d3,-(a1)
tmod6f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+46(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R7

tr7
*	add.l	#6+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod7a	or.w	d3,-(a1)		; ut med plan 1-3
tmod7b	or.w	d3,-(a1)
tmod7c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod7d	or.w	d3,-(a1)		; ut med plan 1-3
tmod7e	or.w	d3,-(a1)
tmod7f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+54(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R8

tr8
*	add.l	#6+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod8a	or.w	d3,-(a1)		; ut med plan 1-3
tmod8b	or.w	d3,-(a1)
tmod8c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod8d	or.w	d3,-(a1)		; ut med plan 1-3
tmod8e	or.w	d3,-(a1)
tmod8f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+62(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R9

tr9
*	add.l	#6+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod9a	or.w	d3,-(a1)		; ut med plan 1-3
tmod9b	or.w	d3,-(a1)
tmod9c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod9d	or.w	d3,-(a1)		; ut med plan 1-3
tmod9e	or.w	d3,-(a1)
tmod9f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+70(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R10

tr10
*	add.l	#6+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod10a	or.w	d3,-(a1)		; ut med plan 1-3
tmod10b	or.w	d3,-(a1)
tmod10c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod10d	or.w	d3,-(a1)		; ut med plan 1-3
tmod10e	or.w	d3,-(a1)
tmod10f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+78(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R11

tr11
*	add.l	#6+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod11a	or.w	d3,-(a1)		; ut med plan 1-3
tmod11b	or.w	d3,-(a1)
tmod11c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod11d	or.w	d3,-(a1)		; ut med plan 1-3
tmod11e	or.w	d3,-(a1)
tmod11f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+86(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R12

tr12
*	add.l	#6+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod12a	or.w	d3,-(a1)		; ut med plan 1-3
tmod12b	or.w	d3,-(a1)
tmod12c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod12d	or.w	d3,-(a1)		; ut med plan 1-3
tmod12e	or.w	d3,-(a1)
tmod12f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+94(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R13

tr13
*	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod13a	or.w	d3,-(a1)		; ut med plan 1-3
tmod13b	or.w	d3,-(a1)
tmod13c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod13d	or.w	d3,-(a1)		; ut med plan 1-3
tmod13e	or.w	d3,-(a1)
tmod13f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+102(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R14

tr14
*	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod14a	or.w	d3,-(a1)		; ut med plan 1-3
tmod14b	or.w	d3,-(a1)
tmod14c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod14d	or.w	d3,-(a1)		; ut med plan 1-3
tmod14e	or.w	d3,-(a1)
tmod14f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+110(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R15

tr15
*	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod15a	or.w	d3,-(a1)		; ut med plan 1-3
tmod15b	or.w	d3,-(a1)
tmod15c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod15d	or.w	d3,-(a1)		; ut med plan 1-3
tmod15e	or.w	d3,-(a1)
tmod15f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+118(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R16

tr16
*	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod16a	or.w	d3,-(a1)		; ut med plan 1-3
tmod16b	or.w	d3,-(a1)
tmod16c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod16d	or.w	d3,-(a1)		; ut med plan 1-3
tmod16e	or.w	d3,-(a1)
tmod16f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+126(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R17

tr17
*	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod17a	or.w	d3,-(a1)		; ut med plan 1-3
tmod17b	or.w	d3,-(a1)
tmod17c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod17d	or.w	d3,-(a1)		; ut med plan 1-3
tmod17e	or.w	d3,-(a1)
tmod17f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+134(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R18

tr18
*	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod18a	or.w	d3,-(a1)		; ut med plan 1-3
tmod18b	or.w	d3,-(a1)
tmod18c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod18d	or.w	d3,-(a1)		; ut med plan 1-3
tmod18e	or.w	d3,-(a1)
tmod18f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+142(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R19

tr19
*	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod19a	or.w	d3,-(a1)		; ut med plan 1-3
tmod19b	or.w	d3,-(a1)
tmod19c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod19d	or.w	d3,-(a1)		; ut med plan 1-3
tmod19e	or.w	d3,-(a1)
tmod19f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+150(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump

*****	R20

tr20
*	add.l	#6+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8+8,a1		; till bitplan 3

	move.w	d5,d3		; get slutmask2
	move.w	d3,d1		; save and not it
	not.w	d1
tmod20a	or.w	d3,-(a1)		; ut med plan 1-3
tmod20b	or.w	d3,-(a1)
tmod20c	or.w	d3,-(a1)

	subq.w	#2,a1

	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)
	movem.l	d6/d7/d0/d2,-(a1)

	move.w	(a4)+,d3
	move.w	d3,d1		; save and not it
	not.w	d1
tmod20d	or.w	d3,-(a1)		; ut med plan 1-3
tmod20e	or.w	d3,-(a1)
tmod20f	or.w	d3,-(a1)

	subq.w	#1,d4		; minska h”jdr„knar'n
	beq	slut

	move.l	a6,a4		; get a adr
	add.w	(a5)+,a4	; add at adr - Senare relativ tycker jag !

	lea	160+158(a1),a1	; ner en rad
	move.l	(a4)+,a2		; get next jump adr
	jmp	(a2)		; jump


slut	jsr	draw_rectangle

	rts	

draw_rectangle:

	move.w	8(a0),d0

	move.w	6(a0),d4
	neg.w	d4
	add.w	#99,d4

	tst.w	d4
	ble	.no_rak_draw	

	lea	$ffff8a00,a3

	move.w	(a0),d1
	cmp.w	4(a0),d1
	blt	.hopp
	move.w	4(a0),(a0)
	move.w	d1,4(a0) ; Nu har jag swappat runt i grund datat, INTE bra!
.hopp
	move.l	screen,a6
	move.w	6(a0),d5
	muls.w	#160,d5
	move.w	(a0),d7
	asr.w	#4,d7
	asl.w	#3,d7
	add.w	d7,d5
	add.w	d5,a6

	move.l	#slutmasker4,a2
	move.w	(a0),d7
	and.w	#%0000000000001111,d7
	neg.w	d7
	add.w	#15,d7
	asl.w	d7
	move.w	(a2,d7),d7	; slutmask1

	move.l	#slutmasker,a2
	move.w	4(a0),d6
	and.w	#%0000000000001111,d6
	asl.w	d6
	move.w	(a2,d6),d6	; slutmask3

	move.w	4(a0),d1
	asr.w	#4,d1
	move.w	(a0),d2
	asr.w	#4,d2
	sub.w	d2,d1
	bne	.rox
	and.w	d6,d7
.rox:
	add.w	#1,d1		; d1=x count

	move.w	d1,d2
	asl.w	#3,d2
	neg.w	d2
	add.w	#168,d2		; d2=y count
	
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	moveq.l	#0,d3		; men skall ej planet ritas s† maska det
.no_bitplane1_2:

	move.l	d3,(a3)
	move.l	d3,4(a3)
	move.l	d3,8(a3)
	move.l	d3,12(a3)
	move.l	d3,16(a3)	; men skall ej planet ritas s† maska det
	move.l	d3,20(a3)
	move.l	d3,24(a3)
	move.l	d3,28(a3)

	move.w	#$700,$ff8240

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	d7,$28(a3)	; slutmask1
	move.w	d6,$2c(a3)	; slutmask3
	move.w	d1,$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	#8,$2e(a3)	; xadd
	move.w	d2,$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.l	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	moveq.l	#0,d3		; men skall ej planet ritas s† maska det
.no_bitplane2_2:

	move.l	d3,(a3)
	move.l	d3,4(a3)
	move.l	d3,8(a3)
	move.l	d3,12(a3)
	move.l	d3,16(a3)	; men skall ej planet ritas s† maska det
	move.l	d3,20(a3)
	move.l	d3,24(a3)
	move.l	d3,28(a3)

	move.w	#$500,$ff8240

*	move.w	#0,$20(a3)
*	move.w	#0,$22(a3)
	move.w	d7,$28(a3)	; slutmask1
	move.w	d6,$2c(a3)	; slutmask3
	move.w	d1,$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	d2,$30(a3)	; yadd
	move.l	a6,$32(a3)
*	move.b	#1,$3a(a3)
*	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.l	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	moveq.l	#0,d3		; men skall ej planet ritas s† maska det
.no_bitplane3_2:

	move.l	d3,(a3)
	move.l	d3,4(a3)
	move.l	d3,8(a3)
	move.l	d3,12(a3)
	move.l	d3,16(a3)	; men skall ej planet ritas s† maska det
	move.l	d3,20(a3)
	move.l	d3,24(a3)
	move.l	d3,28(a3)

	move.w	#$300,$ff8240

*	move.w	#0,$20(a3)
*	move.w	#0,$22(a3)
	move.w	d7,$28(a3)	; slutmask1
	move.w	d6,$2c(a3)	; slutmask3
	move.w	d1,$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	d2,$30(a3)	; yadd
	move.l	a6,$32(a3)
*	move.b	#1,$3a(a3)
*	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

.no_rak_draw:

	rts

*	Bygga om koden lite f”r att f†r fram r„tt f„rger

self_modifying_1:

	move.w	#$353,$ff8240

	move.w	4(a0),d5
	asr.w	#4,d5
	move.w	(a0),d6
	asr.w	#4,d6
	sub.w	d6,d5
	add.w	d5,d5
	add.w	#1,d5		; d1=antal word att bygga om

	move.w	8(a0),d6
	mulu.w	#14,d6
	move.l	#f„rg_koder,a4
	move.l	(a4,d6),col1
	move.l	4(a4,d6),col2
	move.l	8(a4,d6),d7
	move.w	12(a4,d6),d6

	move.l	#modisar1,a2

.rebuild:
	move.l	(a2)+,a3
	move.l	d7,(a3)+
	move.w	d6,(a3)+

	dbf.w	d5,.rebuild

	move.w	#$272,$ff8240

	rts

self_modifying_2:

	move.w	#$353,$ff8240

	move.w	(a0),d5
	asr.w	#4,d5
	move.w	4(a0),d6
	asr.w	#4,d6
	sub.w	d6,d5
	add.w	d5,d5
	add.w	#1,d5		; d1=antal word att bygga om

	move.w	8(a0),d6
	mulu.w	#14,d6
	move.l	#f„rg_koder,a4
	move.l	(a4,d6),col1
	move.l	4(a4,d6),col2
	move.l	8(a4,d6),d7
	move.w	12(a4,d6),d6

	move.l	#modisar2,a2

.rebuild:
	move.l	(a2)+,a3
	move.l	d7,(a3)+
	move.w	d6,(a3)+

	dbf.w	d5,.rebuild

	move.w	#$272,$ff8240

	rts

****************
* Endif        *
****************
end
	movem.l	savepal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	move.l	svbi,$70.w
	
	move.w	oldrez,-(sp)
	move.l	oldphys,-(sp)
	move.l	oldlog,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	move.l	ustk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1
	
*****************
* VBI och VSYNC *
*****************
vbi	add.w	#1,vflag
	rte
	
vsync	tst.w	vflag
	beq.s	vsync
	clr.w	vflag
	rts

vsync2	cmp.w	vflag,d0		; d0 = parameter f”r antal vbi
	bgt.s	vsync2
	clr.w	vflag
	rts
	
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
	move.b	screen+1,$ffff8201.w
	move.b	screen+2,$ffff8203.w
	move.b	screen+3,$ffff820d.w
	rts

set_screen2
	move.b	screen+4+1,$ffff8201.w
	move.b	screen+4+2,$ffff8203.w
	move.b	screen+4+3,$ffff820d.w
	rts
	
***************************************************************************
	section	data
	
screen		dc.l	scrblk,scrblk+32000
y_normal	dc.w	99
koords		ds.w	5
x1:		dc.w	10
y1:		dc.w	10
x2:		dc.w	60
y2:		dc.w	40
tom:		dc.w	0

slutmasker	dc.w	%1000000000000000
		dc.w	%1100000000000000
		dc.w	%1110000000000000
		dc.w	%1111000000000000
		dc.w	%1111100000000000
		dc.w	%1111110000000000
		dc.w	%1111111000000000
		dc.w	%1111111100000000
		dc.w	%1111111110000000
		dc.w	%1111111111000000
		dc.w	%1111111111100000
		dc.w	%1111111111110000
		dc.w	%1111111111111000
		dc.w	%1111111111111100
		dc.w	%1111111111111110
		dc.w	%1111111111111111
		dc.w	0			; endcode

slutmasker2	dc.l	%10000000000000000000000000000000
		dc.l	%11000000000000000000000000000000
		dc.l	%11100000000000000000000000000000
		dc.l	%11110000000000000000000000000000
		dc.l	%11111000000000000000000000000000
		dc.l	%11111100000000000000000000000000
		dc.l	%11111110000000000000000000000000
		dc.l	%11111111000000000000000000000000
		dc.l	%11111111100000000000000000000000
		dc.l	%11111111110000000000000000000000
		dc.l	%11111111111000000000000000000000
		dc.l	%11111111111100000000000000000000
		dc.l	%11111111111110000000000000000000
		dc.l	%11111111111111000000000000000000
		dc.l	%11111111111111100000000000000000
		dc.l	%11111111111111110000000000000000

slutmasker3	dc.w	%1111111111111111
		dc.w	%0111111111111111
		dc.w	%0011111111111111
		dc.w	%0001111111111111
		dc.w	%0000111111111111
		dc.w	%0000011111111111
		dc.w	%0000001111111111
		dc.w	%0000000111111111
		dc.w	%0000000011111111
		dc.w	%0000000001111111
		dc.w	%0000000000111111
		dc.w	%0000000000011111
		dc.w	%0000000000001111
		dc.w	%0000000000000111
		dc.w	%0000000000000011
		dc.w	%0000000000000001

slutmasker4	dc.w	%0000000000000001
		dc.w	%0000000000000011
		dc.w	%0000000000000111
		dc.w	%0000000000001111
		dc.w	%0000000000011111
		dc.w	%0000000000111111
		dc.w	%0000000001111111
		dc.w	%0000000011111111
		dc.w	%0000000111111111
		dc.w	%0000001111111111
		dc.w	%0000011111111111
		dc.w	%0000111111111111
		dc.w	%0001111111111111
		dc.w	%0011111111111111
		dc.w	%0111111111111111
		dc.w	%1111111111111111
		dc.w	0			; endcode

slutmasker5	dc.w	%1111111111111111
		dc.w	%1111111111111110
		dc.w	%1111111111111100
		dc.w	%1111111111111000
		dc.w	%1111111111110000
		dc.w	%1111111111100000
		dc.w	%1111111111000000
		dc.w	%1111111110000000
		dc.w	%1111111100000000
		dc.w	%1111111000000000
		dc.w	%1111110000000000
		dc.w	%1111100000000000
		dc.w	%1111000000000000
		dc.w	%1110000000000000
		dc.w	%1100000000000000
		dc.w	%1000000000000000

slutmasker6	dc.l	%00000000000000010000000000000000
		dc.l	%00000000000000110000000000000000
		dc.l	%00000000000001110000000000000000
		dc.l	%00000000000011110000000000000000
		dc.l	%00000000000111110000000000000000
		dc.l	%00000000001111110000000000000000
		dc.l	%00000000011111110000000000000000
		dc.l	%00000000111111110000000000000000
		dc.l	%00000001111111110000000000000000
		dc.l	%00000011111111110000000000000000
		dc.l	%00000111111111110000000000000000
		dc.l	%00001111111111110000000000000000
		dc.l	%00011111111111110000000000000000
		dc.l	%00111111111111110000000000000000
		dc.l	%01111111111111110000000000000000
		dc.l	%11111111111111110000000000000000

fyllt_word	dc.w	$ffff

hopp_tab	dc.l	r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20
hopp_tab2	dc.l	tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,tr10,tr11,tr12,tr13,tr14,tr15,tr16,tr17,tr18,tr19,tr20

f„rg_koder:	dc.w	$0000,$0000,$0000,$0000,$c361,$c361,$c361
		dc.w	$0000,$ffff,$0000,$0000,$c361,$c361,$8761
		dc.w	$0000,$0000,$ffff,$0000,$c361,$8761,$c361
		dc.w	$0000,$ffff,$ffff,$0000,$c361,$8761,$8761
		dc.w	$0000,$0000,$0000,$ffff,$8761,$c361,$c361
		dc.w	$0000,$ffff,$0000,$ffff,$8761,$c361,$8761
		dc.w	$0000,$0000,$ffff,$ffff,$8761,$8761,$c361
		dc.w	$0000,$ffff,$ffff,$ffff,$8761,$8761,$8761

modisar1:	dc.l	mod1a,mod2a,mod2d,mod3a,mod3d,mod4a,mod4d,mod5a,mod5d,mod6a,mod6d,mod7a,mod7d,mod8a,mod8d,mod9a,mod9d,mod10a,mod10d,mod11a,mod11d,mod12a,mod12d,mod13a,mod13d,mod14a,mod14d,mod15a,mod15d,mod16a,mod16d
		dc.l	mod17a,mod17d,mod18a,mod18d,mod19a,mod19d,mod20a,mod20d
modisar2:	dc.l	tmod1a,tmod2a,tmod2d,tmod3a,tmod3d,tmod4a,tmod4d,tmod5a,tmod5d,tmod6a,tmod6d,tmod7a,tmod7d,tmod8a,tmod8d,tmod9a,tmod9d,tmod10a,tmod10d,tmod11a,tmod11d,tmod12a,tmod12d,tmod13a,tmod13d,tmod14a,tmod14d,tmod15a,tmod15d
		dc.l	tmod16a,tmod16d,tmod17a,tmod17d,tmod18a,tmod18d,tmod19a,tmod19d,tmod20a,tmod20d


lutning:	incbin	"prevink.dat"

	section	bss
scrblk		ds.l	2*8000
ustk		ds.l	1
oldphys		ds.l	1
oldlog		ds.l	1
oldrez		ds.l	1
svbi		ds.l	1

col1:		ds.l	1
col2:		ds.l	1
y_add		ds.w	200
x_add		ds.w	640
		ds.w	10
bredd_add1	ds.w	30720
		ds.w	10
bredd_add2	ds.w	30720
savepal		ds.w	16
vflag		ds.w	1

	end
