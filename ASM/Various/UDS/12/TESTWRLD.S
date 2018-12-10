*******************************************
* Styr med pilarna (rotera med h”ger-v„nster, g† med fram-bak)
* 
* Du „r den lilla r”da pricken (ganska lik dig ;-), och du tittar
* alltid ned†t!!!
*
* Du kan editera om v„rlden (world.inc), genom att „ndra p† nuffrorna
* 1=v„gg ned
* 2=v„gg v„nster
* 3=v„gg upp
* 4=v„gg h”ger
* 5-8=h”rn (vilken ordning vet jag inte riktigt (gl”mt bort!))
*
* /emp

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

	move.l	screen,d0
	move.b	#0,d0
	move.l	d0,screen
	move.l	screen+4,d0
	move.b	#0,d0
	move.l	d0,screen+4
	
	move.l	screen,a0
	add.l	#100*160+80+2,a0
	move.b	#%10000000,(a0)

	move.l	screen+4,a0
	add.l	#100*160+80+2,a0
	move.b	#%10000000,(a0)

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

	lea	bredd_add1,a0
	lea	slutmasker3,a2
	moveq	#0,d4			; list add
	moveq	#0,d5
	move.w	#-1,d5			; first slutm

	move.w	#16-1,d7
.precb1	move.w	#320-1,d6
	moveq	#1,d0			; xc
	move.w	#160-(8*1)+8,d1		; yadd
	lea	slutmasker,a1
	add.l	d4,a1
	move.w	(a2)+,d5		; h„mta ettan
.precb2
	cmp.w	#1,d0
	bne	.hopp
	move.w	d5,d3
	and.w	(a1)+,d3
	move.w	d3,(a0)+
	move.w	#0,(a0)+	; helt on”dig nu n„r den inte ritas
	bra	.hopp2
.hopp:
	move.w	d5,(a0)+		; slutmask 1
	move.w	(a1)+,(a0)+	; slutmask 2
.hopp2:
	move.w	d0,(a0)+		; xcount
	move.w	d1,(a0)+		; yadd

	tst.w	(a1)
	bne.s	.go_on
	add.w	#1,d0		; ett mera p† xc
	sub.w	#8,d1		; ett mindre p† ya
	lea	slutmasker,a1
.go_on	dbf	d6,.precb2
	add.l	#2,d4
	dbf	d7,.precb1

	lea	bredd_add2,a0
	lea	slutmasker,a2
	moveq	#0,d4			; list add
	moveq	#0,d5
	move.w	#-1,d5			; first slutm

	move.w	#16-1,d7
.precb3	move.w	#320-1,d6
	moveq	#1,d0			; xc
	move.w	#160-(8*1)+8,d1		; yadd
	lea	slutmasker4+30,a1
	add.l	d4,a1
	move.w	(a2)+,d5		; h„mta ettan
.precb4
	cmp.w	#1,d0
	bne	.hopp3
	move.w	d5,d3
	and.w	(a1)+,d3
	move.w	d3,(a0)+
	move.w	#0,(a0)+	; slutmask 3 „r helt on”dig nu n„r den inte ritas
	bra	.hopp4
.hopp3:
	move.w	d5,(a0)+		; slutmask 1
	move.w	(a1)+,(a0)+	; slutmask 2
.hopp4:
	move.w	d0,(a0)+		; xcount
	move.w	d1,(a0)+		; yadd

	tst.w	(a1)
	bne.s	.go_on2
	add.w	#1,d0		; ett mera p† xc
	add.w	#8,d1		; ett mera p† ya
	lea	slutmasker4,a1
.go_on2	dbf	d6,.precb4
	sub.l	#2,d4
	dbf	d7,.precb3
	
	rts

**************
* init y bli *
**************
init_y_bli1
	move.w	#0,$ffff8a20.w
	move.w	#0,$ffff8a22.w
	move.l	#fyllt_word,$ffff8a24.w
	move.w	#-1,$ffff8a2a.w
	move.w	#8,$ffff8a2e.w
	
	move.w	#$0003,$ffff8a3a.w
	move.b	#0,$ffff8a3d.w

	rts

init_y_bli2
	move.w	#0,$ffff8a20.w
	move.w	#0,$ffff8a22.w
	move.l	#fyllt_word,$ffff8a24.w
	move.w	#-1,$ffff8a2a.w
	move.w	#-8,$ffff8a2e.w
	
	move.w	#$0003,$ffff8a3a.w
	move.b	#0,$ffff8a3d.w

	rts

********************
* init 3d-world    *
********************
init_3dworld
	lea	adr_world,a0		; rensa adr_world
	move.w	#32*32-1,d7
.loop	move.l	#0,(a0)+
	dbf	d7,.loop

	lea	world,a0
	lea	adr_world,a1
	lea	cordslist,a2
	
	move.w	#0,d0		; x
	move.w	#0,d1		; y

	move.w	#32-1,d7
.loop1	move.w	#32-1,d6
.loop2	tst.b	(a0)
	beq	.ej_8
	
	cmp.b	#1,(a0)
	bne.s	.ej_1
	move.l	a2,(a1)		; save adr to cords
	move.w	d0,d2		; save x,y
	move.w	d1,d3
	move.w	#2,(a2)+		; antal
	add.w	#64,d3
	move.w	d2,(a2)+		; x1
	move.w	d3,(a2)+		; y1
	add.w	#64,d2
	move.w	d2,(a2)+		; x2
	move.w	d3,(a2)+		; y2
.ej_1
	cmp.b	#2,(a0)
	bne.s	.ej_2
	move.l	a2,(a1)		; save adr to cords
	move.w	d0,d2		; save x,y
	move.w	d1,d3
	move.w	#2,(a2)+		; antal
	move.w	d2,(a2)+		; x1
	move.w	d3,(a2)+		; y1
	add.w	#64,d3
	move.w	d2,(a2)+		; x2
	move.w	d3,(a2)+		; y2
.ej_2
	cmp.b	#3,(a0)
	bne.s	.ej_3
	move.l	a2,(a1)		; save adr to cords
	move.w	d0,d2		; save x,y
	move.w	d1,d3
	move.w	#2,(a2)+		; antal
	add.w	#64,d2
	move.w	d2,(a2)+		; x1
	move.w	d3,(a2)+		; y1
	sub.w	#64,d2
	move.w	d2,(a2)+		; x2
	move.w	d3,(a2)+		; y2
.ej_3
	cmp.b	#4,(a0)
	bne.s	.ej_4
	move.l	a2,(a1)		; save adr to cords
	move.w	d0,d2		; save x,y
	move.w	d1,d3
	move.w	#2,(a2)+		; antal
	add.w	#64,d2
	add.w	#64,d3
	move.w	d2,(a2)+		; x1
	move.w	d3,(a2)+		; y1
	sub.w	#64,d3
	move.w	d2,(a2)+		; x2
	move.w	d3,(a2)+		; y2
.ej_4
	cmp.b	#5,(a0)
	bne.s	.ej_5
	move.l	a2,(a1)		; save adr to cords
	move.w	d0,d2		; save x,y
	move.w	d1,d3
	move.w	#3,(a2)+		; antal
	add.w	#64,d3
	move.w	d2,(a2)+		; x1
	move.w	d3,(a2)+		; y1
	add.w	#64,d2
	move.w	d2,(a2)+		; x2
	move.w	d3,(a2)+		; y2
	sub.w	#64,d3
	move.w	d2,(a2)+		; x3
	move.w	d3,(a2)+		; y3
.ej_5
	cmp.b	#6,(a0)
	bne.s	.ej_6
	move.l	a2,(a1)		; save adr to cords
	move.w	d0,d2		; save x,y
	move.w	d1,d3
	move.w	#3,(a2)+		; antal
	move.w	d2,(a2)+		; x1
	move.w	d3,(a2)+		; y1
	add.w	#64,d3
	move.w	d2,(a2)+		; x2
	move.w	d3,(a2)+		; y2
	add.w	#64,d2
	move.w	d2,(a2)+		; x3
	move.w	d3,(a2)+		; y3
.ej_6
	cmp.b	#7,(a0)
	bne.s	.ej_7
	move.l	a2,(a1)		; save adr to cords
	move.w	d0,d2		; save x,y
	move.w	d1,d3
	move.w	#3,(a2)+		; antal
	add.w	#64,d2
	move.w	d2,(a2)+		; x1
	move.w	d3,(a2)+		; y1
	sub.w	#64,d2
	move.w	d2,(a2)+		; x2
	move.w	d3,(a2)+		; y2
	add.w	#64,d3
	move.w	d2,(a2)+		; x3
	move.w	d3,(a2)+		; y3
.ej_7
	cmp.b	#8,(a0)
	bne.s	.ej_8
	move.l	a2,(a1)		; save adr to cords
	move.w	d0,d2		; save x,y
	move.w	d1,d3
	move.w	#3,(a2)+		; antal
	add.w	#64,d2
	add.w	#64,d3
	move.w	d2,(a2)+		; x1
	move.w	d3,(a2)+		; y1
	sub.w	#64,d3
	move.w	d2,(a2)+		; x2
	move.w	d3,(a2)+		; y2
	sub.w	#64,d2
	move.w	d2,(a2)+		; x3
	move.w	d3,(a2)+		; y3
.ej_8
	addq.l	#1,a0		; next in world
	addq.l	#4,a1
	add.w	#64,d0		; ut p† x
	dbf	d6,.loop2
	
	move.w	#0,d0		; restal x
	add.w	#64,d1		; ner p† y
	dbf	d7,.loop1
	
	rts

*********************
* init lite listor  *
*********************
init_3dlist
	move.w	#-256,object_points
	move.w	#-16,object_points+2

	lea	sin_360,a0		; sin
	lea	sin_360+90*2,a1		; cos
	lea	look_cord,a4		; x,z
	move.w	#0,look_angle

	move.w	#360-1,d7
.loop1	lea	object_points,a2		; ta ifr†n
	move.l	a2,a3			; ta ifr†n
	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	
	move.w	look_angle,d4
	add.w	d4,d4
	move.w	(a0,d4.w),d1		; sin alpha
	move.w	(a1,d4.w),d0		; cos alpha

	move.w	(a2)+,d2		; x
	move.w	(a2)+,d3		; z
	
	muls	d1,d2
	swap	d2
	rol.l	#2,d2
	muls	d0,d3
	swap	d3
	rol.l	#2,d3
	add.w	d2,d3
	
	move.w	d3,(a4)+		; look x
	
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a3)+,d2		; x
	move.w	(a3)+,d3		; z
	
	muls	d1,d3
	swap	d3
	rol.l	#2,d3
	muls	d0,d2
	swap	d2
	rol.l	#2,d2
	sub.w	d2,d3
	
	move.w	d3,(a4)+		; look z
	add.w	#1,look_angle

	dbf	d7,.loop1
	

**** Lite f”r plotten
	
	lea	y_add,a0
	moveq	#0,d0
	move.w	#200-1,d7
.precy	move.w	d0,(a0)+
	add.w	#160,d0
	dbf	d7,.precy
	
	moveq	#0,d0
	lea	x_add,a0
	move.w	#20-1,d7
.precx1	move.w	#16-1,d6
	move.w	#%1000000000000000,d1
.precx2	move.w	d0,(a0)+
	move.w	d1,(a0)+
	ror.w	#1,d1
	dbf	d6,.precx2
	add.w	#8,d0
	dbf	d7,.precx1
	
	rts

*********************
* Main och mainloop *
*********************
main	jsr	first_init
	jsr	init_y_rot
	jsr	init_3dworld
	jsr	init_3dlist
	
	move.w	#1024,x_gubbe
	move.w	#1024,y_gubbe
	move.w	#0,look_angle

	move.w	#$001,$ffff8240.w
	move.w	#$667,$ffff8242.w
	move.w	#$701,$ffff8244.w
	move.w	#$701,$ffff8246.w

	move.l	$70.w,svbi
	move.l	#vbi,$70.w
	
main_loop
*	move.w	#$353,$ffff8240.w
	jsr	change_screen
	jsr	erase_screen
	jsr	styr
	jsr	make_3dworld
	move.w	#$001,$ffff8240.w

	move.w	#2,d0
	jsr	vsync2
	
	cmp.b	#57,$fffffc02.w
	bne	main_loop
	bra	end

*****************
* Sudda sk„rmen *
*****************
erase_screen
	lea	$ffff8a20.w,a0
	move.l	#0,(a0)+
	move.l	screen,(a0)+
	addq.l	#6,a0
	move.l	#$00080008,(a0)+
	move.l	screen,(a0)+
	move.w	#20,(a0)+
	move.w	#200,(a0)+
	move.l	#$0000c000,(a0)+
	
	rts

*****************
* Styra runt    *
*****************
styr	
	lea	sin_360,a0
	lea	sin_360+180,a1
	move.w	look_angle,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1		; sin
	move.w	(a1,d0.w),d2		; cos
	
	muls	#14,d1
	swap	d1
	rol.l	#2,d1
	muls	#14,d2
	swap	d2
	rol.l	#2,d2
	
	moveq	#0,d0
	move.b	$fffffc02.w,d0

	cmp.b	#77,d0
	bne.s	.ej_van
	sub.w	#4,look_angle
.ej_van	cmp.b	#75,d0
	bne.s	.ej_hog
	add.w	#4,look_angle
.ej_hog
	
	cmp.w	#-1,look_angle
	bgt.s	.angle1
	move.w	#359,look_angle
.angle1	cmp.w	#360,look_angle
	blt.s	.angle2
	move.w	#0,look_angle
.angle2

	cmp.b	#80,d0
	bne.s	.ej_fram
	add.w	d1,x_gubbe
	sub.w	d2,y_gubbe

	cmp.w	#512,x_gubbe
	bgt.s	.jop1
	sub.w	d1,x_gubbe
	add.w	d2,y_gubbe
.jop1	cmp.w	#1536,x_gubbe
	blt.s	.jop2
	sub.w	d1,x_gubbe
	add.w	d2,y_gubbe
.jop2	cmp.w	#512,y_gubbe
	bgt.s	.jop3
	sub.w	d1,x_gubbe
	add.w	d2,y_gubbe
.jop3	cmp.w	#1536,y_gubbe
	blt.s	.jop4
	sub.w	d1,x_gubbe
	add.w	d2,y_gubbe
.jop4

.ej_fram	cmp.b	#72,d0
	bne.s	.ej_bak
	sub.w	d1,x_gubbe
	add.w	d2,y_gubbe

	cmp.w	#512,x_gubbe
	bgt.s	.jop1b
	add.w	d1,x_gubbe
	sub.w	d2,y_gubbe
.jop1b	cmp.w	#1536,x_gubbe
	blt.s	.jop2b
	add.w	d1,x_gubbe
	sub.w	d2,y_gubbe
.jop2b	cmp.w	#512,y_gubbe
	bgt.s	.jop3b
	add.w	d1,x_gubbe
	sub.w	d2,y_gubbe
.jop3b	cmp.w	#1536,y_gubbe
	blt.s	.jop4b
	add.w	d1,x_gubbe
	sub.w	d2,y_gubbe
.jop4b

.ej_bak

	rts
	
*****************
* Make 3d-world *
*****************
make_3dworld
	jsr	get_right_cords
	
	tst.w	num_points
	bge.s	.just_go_on
	rts

.just_go_on
	jsr	rotera_cords
	jsr	display_cords
	jsr	plotta

	rts
	
***********************
* get the right cords *
***********************
get_right_cords

	lea	adr_world,a0
	lea	look_cord,a1
	lea	xcya_circ,a2
	lea	object_points,a4	; h„r kommer x,y ligga

	move.w	x_gubbe,d0	; gubbens x,y koordinat
	move.w	y_gubbe,d1
	move.w	look_angle,d2
	add.w	d2,d2		; *4
	add.w	d2,d2
	add.w	0(a1,d2.w),d0	; relativ add p† x,y f”r
	add.w	2(a1,d2.w),d1	; att n† synf„ltscirkelns mitt
	
	lsr.w	#6,d0		; /64 f”r att f† r„tt ruta
	lsr.w	#6,d1		; /64

	add.w	d0,d0		; x*4
	add.w	d0,d0
	lsl.w	#7,d1		; y*32*4

	add.w	d0,a0		; †t sidan
	add.w	d1,a0		; och ner†t
	sub.l	#2*4+6*4*32,a0

	move.l	x_gubbe,d4	; x och y gubbe
*	sub.l	#$00200020,d4

	moveq	#-1,d3		; num_points
	
	move.w	#12-1,d7		; antal rader
.loop1	move.w	(a2)+,d6		; antal x per rad...
.loop2	tst.l	(a0)
	beq.s	.no_cord

	move.l	(a0),a3		; koord lista

	add.w	(a3),d3		; antal kordinater
	move.w	(a3)+,d5
	subq.w	#1,d5
.loop3	move.l	(a3)+,(a4)	; lassa koords
	sub.l	d4,(a4)+
	dbf	d5,.loop3

.no_cord	addq.l	#4,a0
	dbf	d6,.loop2
	add.w	(a2)+,a0		; n„sta rad
	dbf	d7,.loop1
	
	move.w	#2,num_points
	
	rts

***********************
* Rotera kordinaterna *
***********************
rotera_cords

	lea	sin_360,a0		; sin
	lea	sin_360+90*2,a1		; cos
	lea	object_points,a2		; ta ifr†n (x,z)
	move.l	a2,a3			; l„gga i
	
	moveq	#0,d0
	moveq	#0,d1
	
	move.w	look_angle,d2
	add.w	d2,d2
	move.w	(a0,d2.w),d0		; sin alpha
	move.w	(a1,d2.w),d1		; cos alpha

	move.w	num_points,d7
.rotta	move.w	(a2)+,d2		; x
	move.w	(a2)+,d3		; z
	move.w	d2,d5
	move.w	d3,d6
	
	muls	d1,d2		; x*cos(alpha)
	swap	d2
	rol.l	#2,d2

	muls	d0,d3
	swap	d3
	rol.l	#2,d3
	add.w	d2,d3
	
	move.w	d3,(a3)+		; new x
	
	move.w	d5,d2		; x
	move.w	d6,d3		; z
	
	muls	d0,d2
	swap	d2
	rol.l	#2,d2

	muls	d1,d3
	swap	d3
	rol.l	#2,d3
	sub.w	d2,d3
	
	move.w	d3,(a3)+		; new z
	dbf	d7,.rotta
	
	rts

*********************
* Display ska mamma *
*********************
display_cords
	lea	object_points,a0
	move.l	a0,a1
	move.w	#500,d0
	move.w	num_points,d7
.proj_it	move.w	(a0)+,d1		; x
	move.w	#(-40*2),d2		; y
	move.w	(a0)+,d3		; z

	muls	d0,d1		; a*x
	add.w	d0,d3		; a+z
	divs	d3,d1
	move.w	d1,(a1)+		; new x
	muls	d0,d2		; a*y
	divs	d3,d2
	move.w	d2,(a1)+		; new y
	dbf	d7,.proj_it

	rts

****************
* Plotta saken *
****************
plotta
	move.l	screen,a0
	lea	x_add,a1
	lea	y_add,a2
	lea	object_points,a3

	move.w	#160,d2
	move.w	#100,d3
	
	lea	koords,a0		; x1,y1,x2,y3,col
	move.w	(a3)+,(a0)
	move.w	(a3)+,2(a0)
	move.w	(a3)+,4(a0)
	move.w	(a3)+,6(a0)
	move.w	#1,8(a0)
	jsr	do_yrot_poly
	
	rts

****************
* Do yrot poly *
****************
do_yrot_poly

	move.w	6(a0),d0
	cmp.w	2(a0),d0
	bge	.hopp
	move.w	2(a0),6(a0)
	move.w	d0,2(a0)
	move.w	4(a0),d0
	move.w	(a0),4(a0)
	move.w	d0,(a0)
.hopp:

	tst.w	2(a0)
	bgt	.no_pure_box
	tst.w	6(a0)
	ble	pure_box
.no_pure_box:

	cmp.w	#0,(a0)
	blt	clipp
	cmp.w	#255,(a0)
	bgt	clipp
	cmp.w	#0,4(a0)
	blt	clipp
	cmp.w	#255,4(a0)
	bgt	clipp

back_to_poly:

	tst.w	2(a0)
	bgt	.no_pure_box
	tst.w	6(a0)
	ble	pure_box
.no_pure_box:

	moveq	#0,d2
	move.w	(a0),d0		; x1
	move.w	2(a0),d1		; y1
	move.w	4(a0),d2		; x2
	move.w	6(a0),d3		; y2

	cmp.w	d0,d2
	blt	rita_bak	; H„r hoppar vi till en mycket lik rutin fast den har inverterade x1,x2

	move.w	#$770,$ff8240

*	Clear tillf screen

	move.l	#tillf_scr,a5		; tillf screen adr
	move.w	2(a0),d4
	bge	.small_jmp
	move.w	#0,d4
.small_jmp:
	mulu.w	#160,d4
	add.w	d4,a5
	move.w	(a0),d4
	asr.w	#4,d4
	asl.w	#3,d4
	add.w	d4,a5
	move.w	4(a0),d4
	sub.w	(a0),d4
	asr.w	#4,d4
	addq.w	#2,d4	; antal word att rita
	move.w	d4,d5
	asl.w	#3,d5
	neg.w	d5
	add.w	#168,d5	;160+xinc

	move.w	6(a0),d6
	bge	.sml_jmp
	move.w	#0,d6
.sml_jmp:
	move.w	2(a0),d7
	bge	.sml_jmp2
	move.w	#0,d7
.sml_jmp2:
	sub.w	d7,d6
	addq.w	#2,d6

	move.w	#$ffff,$ff8a28
	move.w	#$ffff,$ff8a2c
	move.l	#0,$ff8a00
	move.l	#0,$ff8a04
	move.l	#0,$ff8a08
	move.l	#0,$ff8a0c
	move.l	#0,$ff8a10
	move.l	#0,$ff8a14
	move.l	#0,$ff8a18
	move.l	#0,$ff8a1c

	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	d5,$ff8a30	; rad add
	move.l	a5,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	d4,$ff8a36	; X r„knare
	move.w	d6,$ff8a38	; Y r„knare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

	move.w	#$345,$ff8240

	jsr	init_y_bli1
	lea	x_add2,a1
	lea	y_add2,a2
	lea	$ffff8a00,a3
	lea	bredd_add1,a4

	tst.w	2(a0)
	blt	draw_y_clip_poly


	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	move.l	#tillf_scr,d4		; screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	add.w	(a2,d1.w),d4	; dest ner
	move.l	d4,save_source
	add.w	(a1,d0.w),a6	; dest in
	add.w	(a2,d1.w),a6	; dest ner
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	move.l	save_source,$32(a3)	; s„tt dest

	sub.w	(a0),d2
	moveq	#0,d0		; x1
	move.w	2(a0),d1		; y1
	move.w	d3,d4		; save y2
	sub.w	d1,d4		; y2-y1=ant scan
	subq.w	#1,d4		; -1 for the dbf

	moveq	#0,d6	
	sub.w	d1,d3		; y2-y1
	bne	.do_a_little_jump
	move.w	#1,d4
	asl.w	#6,d2
	move.w	d2,d6
	move.w	#0,d2
	move.l	a4,a5		; save
	move.w	d4,d5
	bra	.tri_lp1
.do_a_little_jump:
	asl.w	#6,d2
	divs	d3,d2		; d3=k*64
	move.l	a4,a5		; save
	move.w	d4,d5
.tri_lp1
	add.w	d2,d6		; x1+k
	move.w	d6,d0
	asr.w	#3,d0		; /64*8

	and.w	#%1111111111111000,d0
	move.l	a5,a4
	add.w	d0,a4
	move.w	(a4)+,$28(a3)	; slutmask1
	move.w	(a4)+,$2c(a3)	; slutmask3
	move.w	(a4)+,$36(a3)	; xcount
	move.w	#1,$38(a3)	; ycount
	move.w	(a4)+,$30(a3)	; yadd
	move.b	#$c0,$3c(a3)	; blitta
	dbf	d4,.tri_lp1	

*	Nu har vi ritat triangeln p† en egen sk„rm och den skall nu ritas
*	p† den riktiga sk„rmen.

	addq.w	#1,d5

	move.w	8(a0),d0	; col
	move.b	#3,$3b(a3)	; det normala
	btst.l	#0,d0
	bne	.no_bitplane1
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane1:

	move.w	#$7,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#1,d0
	bne	.no_bitplane2
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane2:

	move.w	#$5,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#2,d0
	bne	.no_bitplane3
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane3:

	move.w	#$3,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta


*	Rita den raka delen av v„ggen


	move.w	6(a0),d4
	neg.w	d4
	add.w	#99,d4

	tst.w	d4
	ble	.no_rak_draw	

	sub.w	#4,a6		; Fixxa till sk„rmadressen
	subq.w	#1,d5
	mulu.w	#160,d5
	add.w	d5,a6

	
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

.no_rak_draw:

	rts

*	Y clip polyn

draw_y_clip_poly:

	add.w	d0,d0
	add.w	d0,d0
	move.l	#tillf_scr,d4		; screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	move.l	d4,save_source
	add.w	(a1,d0.w),a6	; dest in
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	sub.w	(a0),d2
	moveq	#0,d0		; x1
	move.w	2(a0),d1		; y1
	move.w	d3,d4		; save y2
	subq.w	#1,d4		; -1 for the dbf


	moveq	#0,d6	
	sub.w	d1,d3		; y2-y1
	bne	.do_a_little_jump
	move.w	#1,d4
	asl.w	#6,d2
	move.w	d2,d6
	move.w	#0,d2
	move.l	a4,a5		; save
	move.w	d4,d5
	move.w	4(a0),d6
	muls.w	d2,d6
	bra	.tri_lp1

.do_a_little_jump:
	asl.w	#6,d2
	ext.l	d2
	divs	d3,d2		; d3=k*64
	move.l	a4,a5		; save
	move.w	2(a0),d6
	neg.w	d6
	muls.w	d2,d6
	move.w	d4,d5
.tri_lp1
	add.w	d2,d6		; x1+k
	move.w	d6,d0
	asr.w	#3,d0		; /64*8

	and.w	#%1111111111111000,d0
	move.l	a5,a4
	add.w	d0,a4
	move.w	(a4)+,$28(a3)	; slutmask1
	move.w	(a4)+,$2c(a3)	; slutmask3
	move.w	(a4)+,$36(a3)	; xcount
	move.w	#1,$38(a3)	; ycount
	move.w	(a4)+,$30(a3)	; yadd
	move.b	#$c0,$3c(a3)	; blitta
	dbf	d4,.tri_lp1	

*	Nu har vi ritat triangeln p† en egen sk„rm och den skall nu ritas
*	p† den riktiga sk„rmen.

	addq.w	#1,d5

	move.w	8(a0),d0	; col
	move.b	#3,$3b(a3)	; det normala
	btst.l	#0,d0
	bne	.no_bitplane1
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane1:

	move.w	#$7,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#1,d0
	bne	.no_bitplane2
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane2:

	move.w	#$5,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#2,d0
	bne	.no_bitplane3
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane3:

	move.w	#$3,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

*	Rita den raka delen av v„ggen

	move.w	6(a0),d4
	neg.w	d4
	add.w	#99,d4

	tst.w	d4
	ble	.no_rak_draw	

	sub.w	#4,a6		; Fixxa till sk„rmadressen
	subq.w	#1,d5
	mulu.w	#160,d5
	add.w	d5,a6

	
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

.no_rak_draw:

	rts

************************************************ DRA MIG BAKLŽNGES
rita_bak:
	move.w	#$770,$ff8240

*	Clear tillf screen

	move.l	#tillf_scr,a5		; tillf screen adr
	move.w	2(a0),d4
	bge	.small_jmp
	move.w	#0,d4
.small_jmp:
	mulu.w	#160,d4
	add.w	d4,a5
	move.w	4(a0),d4
	asr.w	#4,d4
	asl.w	#3,d4
	add.w	d4,a5
	move.w	(a0),d4
	sub.w	4(a0),d4
	asr.w	#4,d4
	addq.w	#2,d4	; antal word att rita
	move.w	d4,d5
	asl.w	#3,d5
	neg.w	d5
	add.w	#168,d5	;160+xinc

	move.w	6(a0),d6
	bge	.sml_jmp
	move.w	#0,d6
.sml_jmp:
	move.w	2(a0),d7
	bge	.sml_jmp2
	move.w	#0,d7
.sml_jmp2:
	sub.w	d7,d6
	addq.w	#2,d6

	move.l	#0,$ff8a00
	move.l	#0,$ff8a04
	move.l	#0,$ff8a08
	move.l	#0,$ff8a0c
	move.l	#0,$ff8a10
	move.l	#0,$ff8a14
	move.l	#0,$ff8a18
	move.l	#0,$ff8a1c

	move.w	#$ffff,$ff8a28
	move.w	#$ffff,$ff8a2c
	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	d5,$ff8a30	; rad add
	move.l	a5,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	d4,$ff8a36	; X r„knare
	move.w	d6,$ff8a38	; Y r„knare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

	move.w	#$345,$ff8240

	jsr	init_y_bli2
	lea	x_add2,a1
	lea	y_add2,a2
	lea	$ffff8a00,a3
	lea	bredd_add2,a4

	tst.w	2(a0)
	blt	draw_y_clip_poly2

	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	move.l	#tillf_scr,d4		; tillf. screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	add.w	(a2,d1.w),d4	; dest ner
	add.w	(a1,d0.w),a6	; dest in
	add.w	(a2,d1.w),a6	; dest ner
	move.l	d4,save_source
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	sub.w	(a0),d2
	neg.w	d2
	moveq	#0,d0		; x1
	move.w	2(a0),d1		; y1
	move.w	d3,d4		; save y2
	sub.w	d1,d4		; y2-y1=ant scan
	subq.w	#1,d4		; -1 for the dbf

	moveq	#0,d6	
	sub.w	d1,d3		; y2-y1
	bne	.do_a_little_jump
	move.w	#1,d4
	asl.w	#6,d2
	move.w	d2,d6
	move.w	#0,d2
	move.l	a4,a5		; save
	move.w	d4,d5
	bra	.tri_lp1
.do_a_little_jump:

	asl.w	#6,d2
	divs	d3,d2		; d3=k*64
	move.l	a4,a5		; save
	move.w	d4,d5
.tri_lp1
	add.w	d2,d6		; x1+k
	move.w	d6,d0
	asr.w	#3,d0		; /64*8
	and.w	#%1111111111111000,d0
	move.l	a5,a4
	add.w	d0,a4
	move.w	(a4)+,$28(a3)	; slutmask1
	move.w	(a4)+,$2c(a3)	; slutmask3
	move.w	(a4)+,$36(a3)	; xcount
	move.w	#1,$38(a3)	; ycount
	move.w	(a4)+,$30(a3)	; yadd
	move.b	#$c0,$3c(a3)	; blitta
	dbf	d4,.tri_lp1	

*	Nu har vi ritat triangeln p† en egen sk„rm och den skall nu ritas
*	p† den riktiga sk„rmen.

	add.w	#1,d5

	move.w	8(a0),d0	; col
	move.b	#3,$3b(a3)	; det normala
	btst.l	#0,d0
	bne	.no_bitplane1
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane1:

	move.w	#$7,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#1,d0
	bne	.no_bitplane2
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane2:

	move.w	#$5,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#2,d0
	bne	.no_bitplane3
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane3:

	move.w	#$3,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

*	Rita den raka delen av v„ggen

	move.w	6(a0),d4
	neg.w	d4
	add.w	#99,d4

	tst.w	d4
	ble	.no_rak_draw	

	sub.w	#4,a6		; Fixxa till sk„rmadressen
	subq.w	#1,d5
	mulu.w	#160,d5
	add.w	d5,a6
	
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

.no_rak_draw:

	rts

draw_no_poly:

	rts

draw_y_clip_poly2:

	add.w	d0,d0
	add.w	d0,d0
	move.l	#tillf_scr,d4		; screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	move.l	d4,save_source
	add.w	(a1,d0.w),a6	; dest in
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	sub.w	(a0),d2
	neg.w	d2
	moveq	#0,d0		; x1
	move.w	2(a0),d1		; y1
	move.w	d3,d4		; save y2
	subq.w	#1,d4		; -1 for the dbf

	moveq	#0,d6	
	sub.w	d1,d3		; y2-y1
	bne	.do_a_little_jump
	move.w	#1,d4
	asl.w	#6,d2
	move.w	d2,d6
	move.w	#0,d2
	move.l	a4,a5		; save
	move.w	d4,d5
	move.w	4(a0),d6
	muls.w	d2,d6
	bra	.tri_lp1

.do_a_little_jump:
	asl.w	#6,d2
	ext.l	d2
	divs	d3,d2		; d3=k*64
	move.l	a4,a5		; save
	move.w	2(a0),d6
	neg.w	d6
	muls.w	d2,d6
	move.w	d4,d5
.tri_lp1
	add.w	d2,d6		; x1+k
	move.w	d6,d0
	asr.w	#3,d0		; /64*8

	and.w	#%1111111111111000,d0
	move.l	a5,a4
	add.w	d0,a4
	move.w	(a4)+,$28(a3)	; slutmask1
	move.w	(a4)+,$2c(a3)	; slutmask3
	move.w	(a4)+,$36(a3)	; xcount
	move.w	#1,$38(a3)	; ycount
	move.w	(a4)+,$30(a3)	; yadd
	move.b	#$c0,$3c(a3)	; blitta
	dbf	d4,.tri_lp1	

*	Nu har vi ritat triangeln p† en egen sk„rm och den skall nu ritas
*	p† den riktiga sk„rmen.

	addq.w	#1,d5

	move.w	8(a0),d0	; col
	move.b	#3,$3b(a3)	; det normala
	btst.l	#0,d0
	bne	.no_bitplane1
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane1:

	move.w	#$7,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#1,d0
	bne	.no_bitplane2
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane2:

	move.w	#$5,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#2,d0
	bne	.no_bitplane3
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane3:

	move.w	#$3,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

*	Rita den raka delen av v„ggen

	move.w	6(a0),d4
	neg.w	d4
	add.w	#99,d4

	tst.w	d4
	ble	.no_rak_draw	

	sub.w	#4,a6		; Fixxa till sk„rmadressen
	subq.w	#1,d5
	mulu.w	#160,d5
	add.w	d5,a6

	
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

.no_rak_draw:

	rts

*****************************************************************
*	Om Triangeln inte syns skall det bara ritas en fyrkant

pure_box:

	move.w	#$300,$ff8240

	tst.w	(a0)
	bge	.hoppy
	move.w	#0,(a0)
.hoppy:
	cmp.w	#255,(a0)
	ble	.hoppy2
	move.w	#255,(a0)
.hoppy2:
	tst.w	4(a0)
	bge	.hoppy3
	move.w	#0,4(a0)
.hoppy3:
	cmp.w	#255,4(a0)
	ble	.hoppy4
	move.w	#255,4(a0)
.hoppy4:

	jsr	init_y_bli2

	move.w	4(a0),d0
	cmp.w	(a0),d0
	ble	.hopp
	move.w	(a0),4(a0)
	move.w	d0,(a0)
	move.w	6(a0),d0
	move.w	2(a0),6(a0)
	move.w	d0,2(a0)
.hopp:

	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	6(a0),d3

	lea	x_add2,a1
	lea	y_add2,a2
	lea	$ffff8a00,a3
	lea	bredd_add2,a4

	add.w	d0,d0
	add.w	d0,d0
	move.l	#tillf_scr,d4		; screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	move.l	d4,save_source
	add.w	(a1,d0.w),a6	; dest in
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	move.w	(a0),d3
	sub.w	d3,d2
	tst.w	d2
	bge	.haha
	neg.w	d2
.haha:
	asl.w	#3,d2
	add.w	d2,a4

*	move.w	6(a0),d4
*	neg.w	d4
*	add.w	#99,d4

*	tst.w	d4
*	ble	.no_rak_draw	

*	move.w	(a4),$28(a3)	; slutmask1
*	move.w	2(a4),$2c(a3)	; slutmask3
*	move.w	4(a4),$36(a3)	; xcount
*	move.w	#99,$38(a3)	; ycount
*	move.w	6(a4),$30(a3)	; yadd
*	move.b	#$c0,$3c(a3)	; blitta

*	move.w	6(a0),d4
*	neg.w	d4
*	add.w	#99,d4

*	tst.w	d4
*	ble	.no_rak_draw	

*	sub.w	#4,a6		; Fixxa till sk„rmadressen
*	mulu.w	#160,d5
*	add.w	d5,a6

	moveq	#0,d0
	move.w	8(a0),d0
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	(a4),$28(a3)	; slutmask1
	move.w	2(a4),$2c(a3)	; slutmask3
	move.w	4(a4),$36(a3)	; xcount
	move.w	#99,$38(a3)	; ycount
	move.w	6(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	(a4),$28(a3)	; slutmask1
	move.w	2(a4),$2c(a3)	; slutmask3
	move.w	4(a4),$36(a3)	; xcount
	move.w	#99,$38(a3)	; ycount
	move.w	6(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	(a4),$28(a3)	; slutmask1
	move.w	2(a4),$2c(a3)	; slutmask3
	move.w	4(a4),$36(a3)	; xcount
	move.w	#99,$38(a3)	; ycount
	move.w	6(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

*.no_rak_draw:

*.no_rak_draw:

	rts

***************************************************************************
*	Clipping rutinen ; step p† 1/32=0,03125 vilket „r lite f”r d†lig
*	precision...

clipp:

*	Sortera f”rst bort boxen om den inte syns ((x1 och x2)<0 eller >255)

	tst.w	(a0)
	bge	.no_bort
	tst.w	4(a0)
	bge	.no_bort
	bra	draw_no_poly
.no_bort:
	cmp.w	#255,(a0)
	ble	.no_bort2
	cmp.w	#255,4(a0)
	ble	.no_bort2
	bra	draw_no_poly
.no_bort2:

*	Clipp linjen

	move.w	(a0),d1
	sub.w	4(a0),d1
	move.w	2(a0),d0
	sub.w	6(a0),d0
	asl.w	#5,d0
	ext.l	d0
	divs.w	d1,d0	; d0 inneh†ller K v„rdet p† linjen


*	X1<0 klipp

	tst.w	(a0)
	bge	.no_clipp_x1

	move.w	4(a0),d3
	muls.w	d0,d3
	move.w	6(a0),d4
	asl.w	#5,d4
	sub.w	d3,d4
	asr.w	#5,d4
	move.w	#0,(a0)
	move.w	d4,2(a0)

.no_clipp_x1:

*	X1>255 klipp

	cmp.w	#255,(a0)
	ble	.no_clipp_x1_2

	move.w	4(a0),d3
	muls.w	d0,d3
	move.w	#255,d5
	muls.w	d0,d5
	move.w	6(a0),d4
	asl.w	#5,d4
	add.w	d5,d4
	sub.w	d3,d4
	asr.w	#5,d4
	move.w	#255,(a0)
	move.w	d4,2(a0)

.no_clipp_x1_2:

*	X2<0 klipp

	tst.w	4(a0)
	bge	.no_clipp_x2

	move.w	(a0),d3
	muls.w	d0,d3
	move.w	2(a0),d4
	asl.w	#5,d4
	sub.w	d3,d4
	asr.w	#5,d4
	move.w	#0,4(a0)
	move.w	d4,6(a0)

.no_clipp_x2:

*	X2>255 klipp

	cmp.w	#255,4(a0)
	ble	.no_clipp_x2_2

	move.w	#255,d3
	muls.w	d0,d3
	move.w	(a0),d5
	muls.w	d0,d5
	move.w	2(a0),d4
	asl.w	#5,d4
	sub.w	d5,d4
	add.w	d3,d4
	asr.w	#5,d4
	move.w	#255,4(a0)
	move.w	d4,6(a0)

.no_clipp_x2_2:

	bra	back_to_poly

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
	movem.l	d0-d1,-(sp)
	move.l	screen+0,d0
	move.l	screen+4,d1
	move.l	d1,screen+0
	move.l	d0,screen+4
	movem.l	(sp)+,d0-d1
	
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

screen		dc.l	scrblk+256,scrblk+32000+256
xcya_circ		dc.w	05-1,25*4
		dc.w	09-1,23*4
		dc.w	09-1,22*4
		dc.w	11-1,21*4
		dc.w	11-1,21*4
		dc.w	11-1,21*4
		dc.w	11-1,21*4
		dc.w	11-1,21*4
		dc.w	11-1,22*4
		dc.w	09-1,23*4
		dc.w	09-1,25*4
		dc.w	05-1,0

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

slutmasker4
		dc.w	%0000000000000001
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

fyllt_word	dc.w	$ffff
tomt_word:	dc.w	$0


sin_360		include	'a:\sin_360.inc'
world		include	'a:\world.inc'

	section	bss
scrblk		ds.l	2*8000+256
ustk		ds.l	1
oldphys		ds.l	1
oldlog		ds.l	1
oldrez		ds.l	1
svbi		ds.l	1
savepal		ds.w	16
vflag		ds.w	1

x_gubbe		ds.w	1
y_gubbe		ds.w	1
look_angle	ds.w	1
num_points	ds.w	1

x_add		ds.w	640
y_add		ds.w	200

		ds.l	32*4		; bara d„rf”r att
adr_world		ds.l	32*36
cordslist		ds.w	6*16*16
look_cord		ds.l	360	
object_points	ds.w	101*2
object_points2	ds.w	101*3
y_add2		ds.w	200
x_add2		ds.w	640
bredd_add1	ds.w	20480
bredd_add2	ds.w	20480
tillf_scr:	ds.l	4000
save_source:	ds.l	1
koords		ds.w	5


	end

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

	lea	bredd_add1,a0
	lea	slutmasker3,a2
	moveq	#0,d4			; list add
	moveq	#0,d5
	move.w	#-1,d5			; first slutm

	move.w	#16-1,d7
.precb1	move.w	#320-1,d6
	moveq	#1,d0			; xc
	move.w	#160-(8*1)+8,d1		; yadd
	lea	slutmasker,a1
	add.l	d4,a1
	move.w	(a2)+,d5		; h„mta ettan
.precb2
	cmp.w	#1,d0
	bne	.hopp
	move.w	d5,d3
	and.w	(a1)+,d3
	move.w	d3,(a0)+
	move.w	#0,(a0)+	; helt on”dig nu n„r den inte ritas
	bra	.hopp2
.hopp:
	move.w	d5,(a0)+		; slutmask 1
	move.w	(a1)+,(a0)+	; slutmask 2
.hopp2:
	move.w	d0,(a0)+		; xcount
	move.w	d1,(a0)+		; yadd

	tst.w	(a1)
	bne.s	.go_on
	add.w	#1,d0		; ett mera p† xc
	sub.w	#8,d1		; ett mindre p† ya
	lea	slutmasker,a1
.go_on	dbf	d6,.precb2
	add.l	#2,d4
	dbf	d7,.precb1

	lea	bredd_add2,a0
	lea	slutmasker,a2
	moveq	#0,d4			; list add
	moveq	#0,d5
	move.w	#-1,d5			; first slutm

	move.w	#16-1,d7
.precb3	move.w	#320-1,d6
	moveq	#1,d0			; xc
	move.w	#160-(8*1)+8,d1		; yadd
	lea	slutmasker4+30,a1
	add.l	d4,a1
	move.w	(a2)+,d5		; h„mta ettan
.precb4
	cmp.w	#1,d0
	bne	.hopp3
	move.w	d5,d3
	and.w	(a1)+,d3
	move.w	d3,(a0)+
	move.w	#0,(a0)+	; slutmask 3 „r helt on”dig nu n„r den inte ritas
	bra	.hopp4
.hopp3:
	move.w	d5,(a0)+		; slutmask 1
	move.w	(a1)+,(a0)+	; slutmask 2
.hopp4:
	move.w	d0,(a0)+		; xcount
	move.w	d1,(a0)+		; yadd

	tst.w	(a1)
	bne.s	.go_on2
	add.w	#1,d0		; ett mera p† xc
	add.w	#8,d1		; ett mera p† ya
	lea	slutmasker4,a1
.go_on2	dbf	d6,.precb4
	sub.l	#2,d4
	dbf	d7,.precb3
	
	rts

**************
* init y bli *
**************
init_y_bli1
	move.w	#0,$ffff8a20.w
	move.w	#0,$ffff8a22.w
	move.l	#fyllt_word,$ffff8a24.w
	move.w	#-1,$ffff8a2a.w
	move.w	#8,$ffff8a2e.w
	
	move.w	#$0003,$ffff8a3a.w
	move.b	#0,$ffff8a3d.w

	rts

init_y_bli2
	move.w	#0,$ffff8a20.w
	move.w	#0,$ffff8a22.w
	move.l	#fyllt_word,$ffff8a24.w
	move.w	#-1,$ffff8a2a.w
	move.w	#-8,$ffff8a2e.w
	
	move.w	#$0003,$ffff8a3a.w
	move.b	#0,$ffff8a3d.w

	rts
	
*********************
* Main och mainloop *
*********************
main	jsr	first_init
	jsr	init_y_rot

	move.w	#$3,$ff8242
	move.w	#$7,$ff8244
	move.w	#$30,$ff8246
	move.w	#$70,$ff8248
	move.w	#$300,$ff824a
	move.w	#$700,$ff824c
	move.w	#$770,$ff824e
	
	move.l	$70.w,svbi
	move.l	#vbi,$70.w
	
main_loop
	jsr	change_screen

	move.l	#0,$ff8a00
	move.l	#0,$ff8a04
	move.l	#0,$ff8a08
	move.l	#0,$ff8a0c
	move.l	#0,$ff8a10
	move.l	#0,$ff8a14
	move.l	#0,$ff8a18
	move.l	#0,$ff8a1c

	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	#0,$ff8a30
	move.l	screen,a0
	move.l	a0,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	#20*100-1,$ff8a36	; X r„knare
	move.w	#1,$ff8a38	; Y r„knare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

	move.w	#$353,$ffff8240.w
	lea	koords,a0		; x1,y1,x2,y3,col
	move.w	x1,(a0)
	move.w	y1,2(a0)
	move.w	x2,4(a0)
	move.w	y2,6(a0)
	move.w	#1,8(a0)
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

	cmp.b	#59,d0
	bne.s	h
	add.w	#1,koords
	move.l	screen,a0
	move.w	#7999,d0
suddgg	move.l	#0,(a0)+
	dbf	d0,suddgg
h
	cmp.b	#57,d0
	bne	main_loop
	bra	end

****************
* Do yrot poly *
****************
do_yrot_poly

	move.w	6(a0),d0
	cmp.w	2(a0),d0
	bge	.hopp
	move.w	2(a0),6(a0)
	move.w	d0,2(a0)
	move.w	4(a0),d0
	move.w	(a0),4(a0)
	move.w	d0,(a0)
.hopp:

	tst.w	2(a0)
	bgt	.no_pure_box
	tst.w	6(a0)
	ble	pure_box
.no_pure_box:

	cmp.w	#0,(a0)
	blt	clipp
	cmp.w	#255,(a0)
	bgt	clipp
	cmp.w	#0,4(a0)
	blt	clipp
	cmp.w	#255,4(a0)
	bgt	clipp

back_to_poly:

	tst.w	2(a0)
	bgt	.no_pure_box
	tst.w	6(a0)
	ble	pure_box
.no_pure_box:

	moveq	#0,d2
	move.w	(a0),d0		; x1
	move.w	2(a0),d1		; y1
	move.w	4(a0),d2		; x2
	move.w	6(a0),d3		; y2

	cmp.w	d0,d2
	blt	rita_bak	; H„r hoppar vi till en mycket lik rutin fast den har inverterade x1,x2

	move.w	#$770,$ff8240

*	Clear tillf screen

	move.l	#tillf_scr,a5		; tillf screen adr
	move.w	2(a0),d4
	bge	.small_jmp
	move.w	#0,d4
.small_jmp:
	mulu.w	#160,d4
	add.w	d4,a5
	move.w	(a0),d4
	asr.w	#4,d4
	asl.w	#3,d4
	add.w	d4,a5
	move.w	4(a0),d4
	sub.w	(a0),d4
	asr.w	#4,d4
	addq.w	#2,d4	; antal word att rita
	move.w	d4,d5
	asl.w	#3,d5
	neg.w	d5
	add.w	#168,d5	;160+xinc

	move.w	6(a0),d6
	bge	.sml_jmp
	move.w	#0,d6
.sml_jmp:
	move.w	2(a0),d7
	bge	.sml_jmp2
	move.w	#0,d7
.sml_jmp2:
	sub.w	d7,d6
	addq.w	#2,d6

	move.w	#$ffff,$ff8a28
	move.w	#$ffff,$ff8a2c
	move.l	#0,$ff8a00
	move.l	#0,$ff8a04
	move.l	#0,$ff8a08
	move.l	#0,$ff8a0c
	move.l	#0,$ff8a10
	move.l	#0,$ff8a14
	move.l	#0,$ff8a18
	move.l	#0,$ff8a1c

	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	d5,$ff8a30	; rad add
	move.l	a5,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	d4,$ff8a36	; X r„knare
	move.w	d6,$ff8a38	; Y r„knare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

	move.w	#$345,$ff8240

	jsr	init_y_bli1
	lea	x_add,a1
	lea	y_add,a2
	lea	$ffff8a00,a3
	lea	bredd_add1,a4

	tst.w	2(a0)
	blt	draw_y_clip_poly


	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	move.l	#tillf_scr,d4		; screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	add.w	(a2,d1.w),d4	; dest ner
	move.l	d4,save_source
	add.w	(a1,d0.w),a6	; dest in
	add.w	(a2,d1.w),a6	; dest ner
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	move.l	save_source,$32(a3)	; s„tt dest

	sub.w	(a0),d2
	moveq	#0,d0		; x1
	move.w	2(a0),d1		; y1
	move.w	d3,d4		; save y2
	sub.w	d1,d4		; y2-y1=ant scan
	subq.w	#1,d4		; -1 for the dbf

	moveq	#0,d6	
	sub.w	d1,d3		; y2-y1
	bne	.do_a_little_jump
	move.w	#1,d4
	asl.w	#6,d2
	move.w	d2,d6
	move.w	#0,d2
	move.l	a4,a5		; save
	move.w	d4,d5
	bra	.tri_lp1
.do_a_little_jump:
	asl.w	#6,d2
	divs	d3,d2		; d3=k*64
	move.l	a4,a5		; save
	move.w	d4,d5
.tri_lp1
	add.w	d2,d6		; x1+k
	move.w	d6,d0
	asr.w	#3,d0		; /64*8

	and.w	#%1111111111111000,d0
	move.l	a5,a4
	add.w	d0,a4
	move.w	(a4)+,$28(a3)	; slutmask1
	move.w	(a4)+,$2c(a3)	; slutmask3
	move.w	(a4)+,$36(a3)	; xcount
	move.w	#1,$38(a3)	; ycount
	move.w	(a4)+,$30(a3)	; yadd
	move.b	#$c0,$3c(a3)	; blitta
	dbf	d4,.tri_lp1	

*	Nu har vi ritat triangeln p† en egen sk„rm och den skall nu ritas
*	p† den riktiga sk„rmen.

	addq.w	#1,d5

	move.w	8(a0),d0	; col
	move.b	#3,$3b(a3)	; det normala
	btst.l	#0,d0
	bne	.no_bitplane1
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane1:

	move.w	#$7,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#1,d0
	bne	.no_bitplane2
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane2:

	move.w	#$5,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#2,d0
	bne	.no_bitplane3
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane3:

	move.w	#$3,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta


*	Rita den raka delen av v„ggen


	move.w	6(a0),d4
	neg.w	d4
	add.w	#99,d4

	tst.w	d4
	ble	.no_rak_draw	

	sub.w	#4,a6		; Fixxa till sk„rmadressen
	subq.w	#1,d5
	mulu.w	#160,d5
	add.w	d5,a6

	
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

.no_rak_draw:

	rts

*	Y clip polyn

draw_y_clip_poly:

	add.w	d0,d0
	add.w	d0,d0
	move.l	#tillf_scr,d4		; screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	move.l	d4,save_source
	add.w	(a1,d0.w),a6	; dest in
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	sub.w	(a0),d2
	moveq	#0,d0		; x1
	move.w	2(a0),d1		; y1
	move.w	d3,d4		; save y2
	subq.w	#1,d4		; -1 for the dbf


	moveq	#0,d6	
	sub.w	d1,d3		; y2-y1
	bne	.do_a_little_jump
	move.w	#1,d4
	asl.w	#6,d2
	move.w	d2,d6
	move.w	#0,d2
	move.l	a4,a5		; save
	move.w	d4,d5
	move.w	4(a0),d6
	muls.w	d2,d6
	bra	.tri_lp1

.do_a_little_jump:
	asl.w	#6,d2
	ext.l	d2
	divs	d3,d2		; d3=k*64
	move.l	a4,a5		; save
	move.w	2(a0),d6
	neg.w	d6
	muls.w	d2,d6
	move.w	d4,d5
.tri_lp1
	add.w	d2,d6		; x1+k
	move.w	d6,d0
	asr.w	#3,d0		; /64*8

	and.w	#%1111111111111000,d0
	move.l	a5,a4
	add.w	d0,a4
	move.w	(a4)+,$28(a3)	; slutmask1
	move.w	(a4)+,$2c(a3)	; slutmask3
	move.w	(a4)+,$36(a3)	; xcount
	move.w	#1,$38(a3)	; ycount
	move.w	(a4)+,$30(a3)	; yadd
	move.b	#$c0,$3c(a3)	; blitta
	dbf	d4,.tri_lp1	

*	Nu har vi ritat triangeln p† en egen sk„rm och den skall nu ritas
*	p† den riktiga sk„rmen.

	addq.w	#1,d5

	move.w	8(a0),d0	; col
	move.b	#3,$3b(a3)	; det normala
	btst.l	#0,d0
	bne	.no_bitplane1
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane1:

	move.w	#$7,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#1,d0
	bne	.no_bitplane2
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane2:

	move.w	#$5,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#2,d0
	bne	.no_bitplane3
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane3:

	move.w	#$3,$ff8240

	move.l	save_source,$24(a3)
	move.w	#8,$20(a3)
	move.w	-2(a4),$22(a3)
	move.l	a6,$32(a3)
	move.w	#$ffff,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

*	Rita den raka delen av v„ggen

	move.w	6(a0),d4
	neg.w	d4
	add.w	#99,d4

	tst.w	d4
	ble	.no_rak_draw	

	sub.w	#4,a6		; Fixxa till sk„rmadressen
	subq.w	#1,d5
	mulu.w	#160,d5
	add.w	d5,a6

	
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

.no_rak_draw:

	rts

************************************************ DRA MIG BAKLŽNGES
rita_bak:
	move.w	#$770,$ff8240

*	Clear tillf screen

	move.l	#tillf_scr,a5		; tillf screen adr
	move.w	2(a0),d4
	bge	.small_jmp
	move.w	#0,d4
.small_jmp:
	mulu.w	#160,d4
	add.w	d4,a5
	move.w	4(a0),d4
	asr.w	#4,d4
	asl.w	#3,d4
	add.w	d4,a5
	move.w	(a0),d4
	sub.w	4(a0),d4
	asr.w	#4,d4
	addq.w	#2,d4	; antal word att rita
	move.w	d4,d5
	asl.w	#3,d5
	neg.w	d5
	add.w	#168,d5	;160+xinc

	move.w	6(a0),d6
	bge	.sml_jmp
	move.w	#0,d6
.sml_jmp:
	move.w	2(a0),d7
	bge	.sml_jmp2
	move.w	#0,d7
.sml_jmp2:
	sub.w	d7,d6
	addq.w	#2,d6

	move.l	#0,$ff8a00
	move.l	#0,$ff8a04
	move.l	#0,$ff8a08
	move.l	#0,$ff8a0c
	move.l	#0,$ff8a10
	move.l	#0,$ff8a14
	move.l	#0,$ff8a18
	move.l	#0,$ff8a1c

	move.w	#$ffff,$ff8a28
	move.w	#$ffff,$ff8a2c
	move.w	#0,$ff8a20
	move.w	#0,$ff8a22
	move.l	#tom,$ff8a24	; flytta source. adress till blitter chipet
	move.w	#8,$ff8a2e
	move.w	d5,$ff8a30	; rad add
	move.l	a5,$ff8a32	; flytta dest. adress till blitter chipet
	move.w	d4,$ff8a36	; X r„knare
	move.w	d6,$ff8a38	; Y r„knare
	move.b	#1,$ff8a3a	; HOP
	move.b	#3,$ff8a3b	; Op
	move.b	#0,$ff8a3d	; h”ger shift
	move.b	#%11000011,$ff8a3c	; let's go !!!!

	move.w	#$345,$ff8240

	jsr	init_y_bli2
	lea	x_add,a1
	lea	y_add,a2
	lea	$ffff8a00,a3
	lea	bredd_add2,a4

	tst.w	2(a0)
	blt	draw_y_clip_poly2

	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d1
	move.l	#tillf_scr,d4		; tillf. screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	add.w	(a2,d1.w),d4	; dest ner
	add.w	(a1,d0.w),a6	; dest in
	add.w	(a2,d1.w),a6	; dest ner
	move.l	d4,save_source
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	sub.w	(a0),d2
	neg.w	d2
	moveq	#0,d0		; x1
	move.w	2(a0),d1		; y1
	move.w	d3,d4		; save y2
	sub.w	d1,d4		; y2-y1=ant scan
	subq.w	#1,d4		; -1 for the dbf

	moveq	#0,d6	
	sub.w	d1,d3		; y2-y1
	bne	.do_a_little_jump
	move.w	#1,d4
	asl.w	#6,d2
	move.w	d2,d6
	move.w	#0,d2
	move.l	a4,a5		; save
	move.w	d4,d5
	bra	.tri_lp1
.do_a_little_jump:

	asl.w	#6,d2
	divs	d3,d2		; d3=k*64
	move.l	a4,a5		; save
	move.w	d4,d5
.tri_lp1
	add.w	d2,d6		; x1+k
	move.w	d6,d0
	asr.w	#3,d0		; /64*8
	and.w	#%1111111111111000,d0
	move.l	a5,a4
	add.w	d0,a4
	move.w	(a4)+,$28(a3)	; slutmask1
	move.w	(a4)+,$2c(a3)	; slutmask3
	move.w	(a4)+,$36(a3)	; xcount
	move.w	#1,$38(a3)	; ycount
	move.w	(a4)+,$30(a3)	; yadd
	move.b	#$c0,$3c(a3)	; blitta
	dbf	d4,.tri_lp1	

*	Nu har vi ritat triangeln p† en egen sk„rm och den skall nu ritas
*	p† den riktiga sk„rmen.

	add.w	#1,d5

	move.w	8(a0),d0	; col
	move.b	#3,$3b(a3)	; det normala
	btst.l	#0,d0
	bne	.no_bitplane1
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane1:

	move.w	#$7,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#1,d0
	bne	.no_bitplane2
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane2:

	move.w	#$5,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#2,d0
	bne	.no_bitplane3
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane3:

	move.w	#$3,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

*	Rita den raka delen av v„ggen

	move.w	6(a0),d4
	neg.w	d4
	add.w	#99,d4

	tst.w	d4
	ble	.no_rak_draw	

	sub.w	#4,a6		; Fixxa till sk„rmadressen
	subq.w	#1,d5
	mulu.w	#160,d5
	add.w	d5,a6
	
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

.no_rak_draw:

	rts

draw_no_poly:

	rts

draw_y_clip_poly2:

	add.w	d0,d0
	add.w	d0,d0
	move.l	#tillf_scr,d4		; screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	move.l	d4,save_source
	add.w	(a1,d0.w),a6	; dest in
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	sub.w	(a0),d2
	neg.w	d2
	moveq	#0,d0		; x1
	move.w	2(a0),d1		; y1
	move.w	d3,d4		; save y2
	subq.w	#1,d4		; -1 for the dbf

	moveq	#0,d6	
	sub.w	d1,d3		; y2-y1
	bne	.do_a_little_jump
	move.w	#1,d4
	asl.w	#6,d2
	move.w	d2,d6
	move.w	#0,d2
	move.l	a4,a5		; save
	move.w	d4,d5
	move.w	4(a0),d6
	muls.w	d2,d6
	bra	.tri_lp1

.do_a_little_jump:
	asl.w	#6,d2
	ext.l	d2
	divs	d3,d2		; d3=k*64
	move.l	a4,a5		; save
	move.w	2(a0),d6
	neg.w	d6
	muls.w	d2,d6
	move.w	d4,d5
.tri_lp1
	add.w	d2,d6		; x1+k
	move.w	d6,d0
	asr.w	#3,d0		; /64*8

	and.w	#%1111111111111000,d0
	move.l	a5,a4
	add.w	d0,a4
	move.w	(a4)+,$28(a3)	; slutmask1
	move.w	(a4)+,$2c(a3)	; slutmask3
	move.w	(a4)+,$36(a3)	; xcount
	move.w	#1,$38(a3)	; ycount
	move.w	(a4)+,$30(a3)	; yadd
	move.b	#$c0,$3c(a3)	; blitta
	dbf	d4,.tri_lp1	

*	Nu har vi ritat triangeln p† en egen sk„rm och den skall nu ritas
*	p† den riktiga sk„rmen.

	addq.w	#1,d5

	move.w	8(a0),d0	; col
	move.b	#3,$3b(a3)	; det normala
	btst.l	#0,d0
	bne	.no_bitplane1
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane1:

	move.w	#$7,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#1,d0
	bne	.no_bitplane2
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane2:

	move.w	#$5,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.b	#3,$3b(a3)	; det normala
	btst.l	#2,d0
	bne	.no_bitplane3
	move.b	#4,$3b(a3)	; men skall ej planet ritas s† maska det
.no_bitplane3:

	move.w	#$3,$ff8240

	move.l	save_source,$24(a3)
	move.w	#-8,$20(a3)
	move.w	-2(a4),$22(a3)
	add.w	#8,$22(a3)
	move.l	a6,$32(a3)
	add.l	#8,$32(a3)
	move.w	#$0,$28(a3)	; slutmask1
	move.w	#$ffff,$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	add.w	#1,$36(a3)
	move.w	d5,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	add.w	#8,$30(a3)
	move.b	#2,$3a(a3)
	move.b	#$c0,$3c(a3)	; blitta

*	Rita den raka delen av v„ggen

	move.w	6(a0),d4
	neg.w	d4
	add.w	#99,d4

	tst.w	d4
	ble	.no_rak_draw	

	sub.w	#4,a6		; Fixxa till sk„rmadressen
	subq.w	#1,d5
	mulu.w	#160,d5
	add.w	d5,a6

	
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	-8(a4),$28(a3)	; slutmask1
	move.w	-6(a4),$2c(a3)	; slutmask3
	move.w	-4(a4),$36(a3)	; xcount
	move.w	d4,$38(a3)	; ycount
	move.w	-2(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

.no_rak_draw:

	rts

*****************************************************************
*	Om Triangeln inte syns skall det bara ritas en fyrkant

pure_box:

	move.w	#$300,$ff8240

	tst.w	(a0)
	bge	.hoppy
	move.w	#0,(a0)
.hoppy:
	cmp.w	#255,(a0)
	ble	.hoppy2
	move.w	#255,(a0)
.hoppy2:
	tst.w	4(a0)
	bge	.hoppy3
	move.w	#0,4(a0)
.hoppy3:
	cmp.w	#255,4(a0)
	ble	.hoppy4
	move.w	#255,4(a0)
.hoppy4:

	jsr	init_y_bli2

	move.w	4(a0),d0
	cmp.w	(a0),d0
	ble	.hopp
	move.w	(a0),4(a0)
	move.w	d0,(a0)
	move.w	6(a0),d0
	move.w	2(a0),6(a0)
	move.w	d0,2(a0)
.hopp:

	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	4(a0),d2
	move.w	6(a0),d3

	lea	x_add,a1
	lea	y_add,a2
	lea	$ffff8a00,a3
	lea	bredd_add2,a4

	add.w	d0,d0
	add.w	d0,d0
	move.l	#tillf_scr,d4		; screen adr
	move.l	screen,a6		; screen adr
	add.w	(a1,d0.w),d4	; dest in
	move.l	d4,save_source
	add.w	(a1,d0.w),a6	; dest in
	move.l	d4,$32(a3)	; s„tt dest
	moveq	#0,d4
	move.w	2(a1,d0.w),d4	; r„tt skew och allt
	add.l	d4,a4

	move.w	(a0),d3
	sub.w	d3,d2
	tst.w	d2
	bge	.haha
	neg.w	d2
.haha:
	asl.w	#3,d2
	add.w	d2,a4

*	move.w	6(a0),d4
*	neg.w	d4
*	add.w	#99,d4

*	tst.w	d4
*	ble	.no_rak_draw	

*	move.w	(a4),$28(a3)	; slutmask1
*	move.w	2(a4),$2c(a3)	; slutmask3
*	move.w	4(a4),$36(a3)	; xcount
*	move.w	#99,$38(a3)	; ycount
*	move.w	6(a4),$30(a3)	; yadd
*	move.b	#$c0,$3c(a3)	; blitta

*	move.w	6(a0),d4
*	neg.w	d4
*	add.w	#99,d4

*	tst.w	d4
*	ble	.no_rak_draw	

*	sub.w	#4,a6		; Fixxa till sk„rmadressen
*	mulu.w	#160,d5
*	add.w	d5,a6

	moveq	#0,d0
	move.w	8(a0),d0
	move.l	#-1,d3		;det normala
	btst.l	#0,d0
	bne	.no_bitplane1_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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
	move.w	(a4),$28(a3)	; slutmask1
	move.w	2(a4),$2c(a3)	; slutmask3
	move.w	4(a4),$36(a3)	; xcount
	move.w	#99,$38(a3)	; ycount
	move.w	6(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#1,d0
	bne	.no_bitplane2_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	(a4),$28(a3)	; slutmask1
	move.w	2(a4),$2c(a3)	; slutmask3
	move.w	4(a4),$36(a3)	; xcount
	move.w	#99,$38(a3)	; ycount
	move.w	6(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

	add.w	#2,a6
	move.l	#-1,d3		; det normala
	btst.l	#2,d0
	bne	.no_bitplane3_2
	move.l	#0,d3		; men skall ej planet ritas s† maska det
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

	move.w	#0,$20(a3)
	move.w	#0,$22(a3)
	move.w	(a4),$28(a3)	; slutmask1
	move.w	2(a4),$2c(a3)	; slutmask3
	move.w	4(a4),$36(a3)	; xcount
	move.w	#99,$38(a3)	; ycount
	move.w	6(a4),$30(a3)	; yadd
	move.l	a6,$32(a3)
	move.b	#1,$3a(a3)
	move.b	#3,$3b(a3)
	move.b	#$c0,$3c(a3)	; blitta

*.no_rak_draw:

*.no_rak_draw:

	rts

***************************************************************************
*	Clipping rutinen ; step p† 1/32=0,03125 vilket „r lite f”r d†lig
*	precision...

clipp:

*	Sortera f”rst bort boxen om den inte syns ((x1 och x2)<0 eller >255)

	tst.w	(a0)
	bge	.no_bort
	tst.w	4(a0)
	bge	.no_bort
	bra	draw_no_poly
.no_bort:
	cmp.w	#255,(a0)
	ble	.no_bort2
	cmp.w	#255,4(a0)
	ble	.no_bort2
	bra	draw_no_poly
.no_bort2:

*	Clipp linjen

	move.w	(a0),d1
	sub.w	4(a0),d1
	move.w	2(a0),d0
	sub.w	6(a0),d0
	asl.w	#5,d0
	ext.l	d0
	divs.w	d1,d0	; d0 inneh†ller K v„rdet p† linjen


*	X1<0 klipp

	tst.w	(a0)
	bge	.no_clipp_x1

	move.w	4(a0),d3
	muls.w	d0,d3
	move.w	6(a0),d4
	asl.w	#5,d4
	sub.w	d3,d4
	asr.w	#5,d4
	move.w	#0,(a0)
	move.w	d4,2(a0)

.no_clipp_x1:

*	X1>255 klipp

	cmp.w	#255,(a0)
	ble	.no_clipp_x1_2

	move.w	4(a0),d3
	muls.w	d0,d3
	move.w	#255,d5
	muls.w	d0,d5
	move.w	6(a0),d4
	asl.w	#5,d4
	add.w	d5,d4
	sub.w	d3,d4
	asr.w	#5,d4
	move.w	#255,(a0)
	move.w	d4,2(a0)

.no_clipp_x1_2:

*	X2<0 klipp

	tst.w	4(a0)
	bge	.no_clipp_x2

	move.w	(a0),d3
	muls.w	d0,d3
	move.w	2(a0),d4
	asl.w	#5,d4
	sub.w	d3,d4
	asr.w	#5,d4
	move.w	#0,4(a0)
	move.w	d4,6(a0)

.no_clipp_x2:

*	X2>255 klipp

	cmp.w	#255,4(a0)
	ble	.no_clipp_x2_2

	move.w	#255,d3
	muls.w	d0,d3
	move.w	(a0),d5
	muls.w	d0,d5
	move.w	2(a0),d4
	asl.w	#5,d4
	sub.w	d5,d4
	add.w	d3,d4
	asr.w	#5,d4
	move.w	#255,4(a0)
	move.w	d4,6(a0)

.no_clipp_x2_2:

	bra	back_to_poly

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
y_normal		dc.w	99
koords		ds.w	5
x1:		dc.w	11
y1:		dc.w	30
x2:		dc.w	100
y2:		dc.w	10
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

slutmasker4
		dc.w	%0000000000000001
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

fyllt_word	dc.w	$ffff
tomt_word:	dc.w	$0

	section	bss
scrblk		ds.l	2*8000
ustk		ds.l	1
oldphys		ds.l	1
oldlog		ds.l	1
oldrez		ds.l	1
svbi		ds.l	1
y_add		ds.w	200
x_add		ds.w	640
bredd_add1	ds.w	20480
bredd_add2	ds.w	20480
tillf_scr:	ds.l	4000
savepal		ds.w	16
vflag		ds.w	1
save_source:	ds.l	1
	end
                                                             