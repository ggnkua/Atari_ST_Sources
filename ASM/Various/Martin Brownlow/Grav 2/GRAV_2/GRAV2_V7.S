	opt	o+
	opt	w-

*********defines***********

* defines for finishing sequence

fin_count	equ	255
fin_turn	equ	4000
fin_door	equ	520
fin_door2	equ	750
fin_you1	equ	70
fin_you2	equ	125
fin_you3	equ	165
fin_you4	equ	280	
fin_you5	equ	420
fin_you6	equ	475
fin_you7	equ	520
fin_you8	equ	555
fin_you9	equ	850
ground		equ	140*32

buysound	equ	7
loadsound	equ	4
lrsound		equ	1
grav_power	equ	64
min_fire_speed	equ	2
max_fire_speed	equ	6
min_turn_speed	equ	2
max_turn_speed	equ	6
min_thrust	equ	0
max_thrust	equ	3
start_credits	equ	20
start_worlds	equ	%1111
start_wrldone	equ	%10000000001000000000
timershtime	equ	4
cloaktime	equ	10
fuelmax		equ	256
ammomax		equ	256
fuelconsumption	equ	32
bombpower	equ	8
gbas_mspeed	equ	8
turnspeed	equ	16
maxbuls		equ	50
maxprts		equ	100
maxexpl		equ	20
maxbmbs		equ	5
scrluppt	equ	60
scrldnpt	equ	116
scrlftpt	equ	80
scrlrtpt	equ	225
noscrolls	equ	4

ycolmin		equ	-1
ycolmax		equ	14

***************************

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		* supervisor mode
	addq.l	#6,sp
	move.b	$484,oldkey	* no keypress
	move.b	#0,$484		*
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	cmp.l	#$78000,d0
	bgt	moremeg
	move.l	#$78000,d0
moremeg	move.l	d0,physic
	move.l	d0,iphysic
	sub.l	#$8000,d0
	move.l	d0,back
	sub.l	#$8000,d0
	move.l	d0,back2
	add.l	#$10000,d0
	move.w	#0,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14		* set screen
	add.l	#12,sp
	move.w	#$0,-(sp)
	pea	hsname
	move.w	#$3d,-(sp)
	trap	#1		* Is gravhs.dat there?
	addq.l	#8,sp
	tst.l	d0
	bmi	noload		* No
	move.w	d0,youx
	pea	saveloc
	move.l	#saveend-saveloc,-(sp)
	move.w	youx,-(sp)
	move.w	#$3f,-(sp)
	trap	#1		* load it..
	lea	12(sp),sp
	cmp.l	#saveend-saveloc,d0	* long enough?
	bne	retgen2			* if not, quit
	pea	savel2
	move.l	#savee2-savel2,-(Sp)
	move.w	youx,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	cmp.l	#savee2-savel2,d0
	bne	retgen2
	move.w	youx,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
noload	bsr	install
	jsr	save_interrupts		* ready muzexx...
	
	movem.l	tpal,d0-d7		* title screen palette
	movem.l	d0-d7,$ff8240		* into palette registers
	bsr	playsam
	bsr	slowcls
	bsr	swap
	bsr	slowcls
	lea	share,a5		* put nice shareware text up..
	bsr	dotext
	bsr	swap
	bset	#6,newsam
	move.b	#0,lastkey
wkey	cmp.b	#0,lastkey		* wait for a key
	bne	dotitle
	btst	#7,joy1
	beq	wkey
dotitle	bsr	samstop	
	bsr	slowcls
	bsr	swap
	
title	bclr	#7,flags+1
	movem.l	tpal,d0-d7
	movem.l	d0-d7,$ff8240
	lea	scrltxt,a0
	move.l	a0,savescr
	bsr	cline
	bset	#7,flags
	bsr	slowcls
	bsr	swap
	bset	#7,flags
	bsr	slowcls
	bsr	swap
	bsr	slowcls
	bsr	mkstrz			* make stars
	jsr	init_muzexx		* play music
	jsr	play_muzexx
	move.b	#0,cmethod
	
wait	bsr	scrlit			* do scrolly
	bsr	stars			* do stars
	bsr	putlogo			* do logo
	bsr	swap2			* swap screen
	sub.w	#1,nolines
	bcc	nocline
	bsr	cline			* next line of text
nocline	btst	#7,joy1
	bne	main
	btst	#3,sshift
	beq	notkey1
	move.b	#16,cmethod
	bra	main
notkey1	cmp.b	#0,fkeytab+$39
	beq	notkey2
	move.b	#16,cmethod
	bra	main
notkey2	cmp.b	#0,fkeytab+$1f		* 'S' pressed?
	beq	notshs
	jsr	reinstall_interrupts	* Stop the music!
	move.w	#$0,-(sp)
	pea	hsname			* save hi-scores
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	error
	move.w	d0,youx
	pea	saveloc
	move.l	#saveend-saveloc,-(sp)
	move.w	youx,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	closeit
	pea	savel2
	move.l	#savee2-savel2,-(sp)
	move.w	youx,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	closeit
closeit	move.w	youx,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
error	jsr	init_muzexx
	jsr	play_muzexx
	bra	wait
notshs	bra	wait
	cmp.b	#0,fkeytab+$12
	beq	wait
	bra	musgen
putlogo	lea	logo,a4			* slam logo on screen
	movea.l	back,a5
	lea	160*32+48(a5),a5
	moveq	#31,d7
putlglp	movem.l	(a4)+,d4-d6/a6
	movem.l	d4-d6/a6,(a5)
	movem.l	(a4)+,d4-d6/a6
	movem.l	d4-d6/a6,16(a5)
	movem.l	(a4)+,d4-d6/a6
	movem.l	d4-d6/a6,32(a5)
	movem.l	(a4)+,d4-d6/a6
	movem.l	d4-d6/a6,48(a5)
	lea	160(a5),a5
	dbra.w	d7,putlglp
	rts
	

*********************************************

standard_vbl				* exactly what it says
	bset	#7,flags
	move.b	#$16,$fffffc02.w	* request joystick package
	btst	#7,flags+1
	bne	flashit
	cmp.w	#0,baw
	bne	makebaw
	rts
makebaw	cmp.w	#-1,baw			* nice black and white effect..
	beq	putpal
	cmp.w	#1,baw
	bne	notsbaw
	move.l	d0,-(sp)
	move.l	#$07770777,d0
	move.l	d0,$ff8240
	move.l	d0,$ff8244
	move.l	d0,$ff8248
	move.l	d0,$ff824c
	move.l	d0,$ff8250
	move.l	d0,$ff8254
	move.l	d0,$ff8258
	move.l	d0,$ff825c
	move.l	(sp)+,d0
	move.w	#4,baw
bawout	rts
notsbaw	cmp.w	#33,baw
	beq	bawout
	movem.l	d0/d1/a0/a1,-(sp)
	move.w	baw,d0
	and.w	#3,d0
	cmp.w	#0,d0
	bne	restreg
	move.w	baw,d0
	lsr.w	#2,d0
	moveq.w	#8,d1
	sub.w	d0,d1
	move.w	#$111,d0
	mulu.w	d1,d0
	lea	pbawpal,a0
	move.l	#$ff8240,a1
	moveq.w	#0,d1
backlp	cmp.w	(a0,d1.w),d0
	blt	nextcol
	move.w	d0,(a1,d1.w)
nextcol	addq.w	#2,d1
	cmp.w	#32,d1
	bne	backlp
restreg	movem.l	(sp)+,d0/d1/a0/a1
	add.w	#1,baw
	rts
putpal	movem.l	d0-d7,-(sp)
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240
	move.w	#0,baw
	movem.l	(sp)+,d0-d7
	rts
flashit	move.l	a4,-(sp)
	movea.l	flashpl,a4
	move.w	(a4)+,$ff825e
	cmp.l	#flashend,a4
	bne	flashot
	lea	flashdt,a4
flashot	move.l	a4,flashpl
	move.l	(sp)+,a4
	rts

flashpl	dc.l	flashdt
flashdt	dc.w	$000,$100,$200,$300
	dc.w	$400,$500,$600,$700
	dc.w	$700,$600,$500,$400
	dc.w	$300,$200,$100,$000
flashend

main	move.w	#5,lives		* set up a lot of stuff
	move.w	#0,score		* 'cos just started game..
	move.l	#0,stordat
	move.l	#0,stordat+4
	move.l	#0,stordat+8
	move.l	#0,nobombs
	move.w	#0,nobombs+4
	move.l	#start_worlds,worlds
	move.w	#start_credits,creds
	move.l	#start_wrldone,d7
	move.l	#$00040000,youts
	move.w	#64,youthrt
	move.w	#0,youbulr
	move.w	#4,youfs
	move.w	#0,youfc
	move.w	#4,fuelcnt
	not.l	d7
	move.l	d7,wrldone
	
choose_world			* choose world screen
	move.b	#128,youx
	bsr	slowcls
	bsr	swap2
	bsr	slowcls
	movem.l	chpal,d4-d7
	movem.l	d4-d7,$ff8240
	movem.l	chpal+16,d4-d7
	movem.l	d4-d7,$ff8250
	lea	lastnos,a4
	move.l	#$ffffffff,(a4)
	move.w	#0,4(a4)
	moveq	#0,d7
	moveq	#4,d5
	move.l	worlds,d6
worldlp	btst	d7,d6
	beq	nxtwrld
	move.b	d7,(a4)+
	subq.w	#1,d5
	beq	gotwlds
nxtwrld	addq.w	#1,d7
	cmp.w	#32,d7
	bne	worldlp
gotwlds	lea	lastnos,a4
	moveq.w	#0,d4
pritlp	moveq	#0,d6
	move.b	(a4)+,d6
	cmp.b	#$ff,d6
	beq	outplan
	mulu.w	#52,d6
	move.w	d4,d5
	mulu.w	#160*8*5,d5
	add.w	#136+160*8*3,d5
	movea.l	back,a5
	lea	(a5,d5.w),a5
	lea	level_names,a6
	lea	(a6,d6.w),a6
	moveq	#0,d7
	move.b	38(a6),d7
	lsl.w	#8,d7
	add.w	d7,d7
	lea	plangrf,a6		* put planet graphic
	lea	(a6,d7.w),a6
	moveq	#31,d7
pplan1	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	lea	144(a5),a5
	dbra.w	d7,pplan1
	move.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	add.w	d4,d5
	addq.b	#3,d5
	bsr	putname
	lea	choose_text,a5
	bsr	dotext
	addq.w	#1,d4
	cmpi.w	#4,d4
	bne	pritlp
outplan	bsr	swap2
	bsr	putglow		* put glowy box..
	bset	#7,flags+1	* set glow going
	
waitjoy	bsr	getinp		* "get input"
	btst	#7,input
	beq	noselct
	btst	#7,youx
	bne	waitjoy
	bset	#7,youx
	bra	loadlev
noselct	bclr	#7,youx
	btst	#0,input
	beq	nogoup
	btst	#0,youx
	bne	waitjoy
	bset	#0,youx
	bsr	delglow
	cmp.w	#0,lastnos+4
	beq	upoftop
	sub.w	#1,lastnos+4
	bsr	putglow
	bra	waitjoy
upoftop	moveq	#0,d6
	move.b	lastnos,d6
	move.l	worlds,d7
	subq.w	#1,d6
	bcs	notftop
getitlp	btst	d6,d7
	bne	gotplan
	dbra.w	d6,getitlp
	bra	notftop
gotplan	lea	lastnos,a4
	move.b	2(a4),3(a4)
	move.b	1(a4),2(a4)
	move.b	(a4),1(a4)
	move.b	d6,(a4)
	movea.l	physic,a5
	movea.l	back,a6
	lea	8*8*160(a6),a6
	lea	3*8*160(a5),a5
	move.w	#14*8*20,d4
scrllst	move.l	(a5)+,(a6)+		* scroll planet list
	move.l	(a5)+,(a6)+
	dbra.w	d4,scrllst
	mulu.w	#52,d6
	move.w	#136+160*8*3,d5
	movea.l	back,a5
	lea	(a5,d5.w),a5
	lea	level_names,a6
	lea	(a6,d6.w),a6
	moveq	#0,d7
	move.b	38(a6),d7
	lsl.w	#8,d7
	add.w	d7,d7
	lea	plangrf,a6
	lea	(a6,d7.w),a6
	moveq	#31,d7
pplan2	move.l	(a6)+,(a5)+		* put planet graphic again..
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	lea	144(a5),a5
	dbra.w	d7,pplan2
	moveq	#3,d5
	bsr	putname
	lea	choose_text,a5
	bsr	dotext
	bsr	swap2
notftop	bsr	putglow
	bra	waitjoy
nogoup	bclr	#0,youx
	btst	#1,input
	beq	nogodwn
	btst	#1,youx
	bne	waitjoy
	bset	#1,youx
	bsr	delglow
	cmp.w	#3,lastnos+4
	beq	dnofbot
	lea	lastnos,a4
	move.w	4(a4),d4
	cmp.b	#$ff,1(a4,d4.w)
	beq	nochdwn
	add.w	#1,4(a4)
nochdwn	bsr	putglow
	bra	waitjoy
dnofbot	moveq	#0,d6
	move.b	lastnos+3,d6
	move.l	worlds,d7
	addq.w	#1,d6
	cmp.w	#31,d6
	bgt	notfbot
getitl2	btst	d6,d7
	bne	gotpl2
	addq.w	#1,d6
	cmp.w	#32,d6
	blt	getitl2
	bra	notfbot
gotpl2	lea	lastnos,a4
	move.b	1(a4),(a4)
	move.b	2(a4),1(a4)
	move.b	3(a4),2(a4)
	move.b	d6,3(a4)
	movea.l	physic,a5
	movea.l	back,a6
	lea	3*8*160(a6),a6
	lea	8*8*160(a5),a5
	move.w	#14*8*20,d4
scrll2	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbra.w	d4,scrll2
	mulu.w	#52,d6
	move.w	#3*160*8*5+136+160*8*3,d5
	movea.l	back,a5
	lea	(a5,d5.w),a5
	lea	level_names,a6
	lea	(a6,d6.w),a6
	moveq	#0,d7
	move.b	38(a6),d7
	lsl.w	#8,d7
	add.w	d7,d7
	lea	plangrf,a6
	lea	(a6,d7.w),a6
	moveq	#31,d7
pplan3	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	move.l	(a6)+,(a5)+
	lea	144(a5),a5
	dbra.w	d7,pplan3
	moveq	#18,d5
	bsr	putname
	lea	choose_text,a5
	bsr	dotext
	bsr	swap2
notfbot	bsr	putglow
	bra	waitjoy
nogodwn	bclr	#1,youx
	bra	waitjoy
	
getinp	move.b	joy1,input		* routine to get input
	cmp.b	#0,cmethod
	beq	gotcont
	lea	kbstab+16,a4
	move.b	sshift,d4
	and.w	#$f,d4
	move.b	(a4,d4.w),d4
	lea	fkeytab,a4
	cmp.b	#0,$27(a4)
	beq	noklft2
	bset	#2,d4
	bra	nokrgt2
noklft2	cmp.b	#0,$28(a4)
	beq	nokrgt2
	bset	#3,d4
nokrgt2	cmp.b	#0,$39(a4)
	beq	nofire2
	bset	#7,d4
nofire2	move.b	d4,input	
gotcont	rts

putars	movea.l	physic,a4	* routine to print the arrows on the screen
	move.w	lastnos+2,d4
	move.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	add.w	d5,d4
	lsl.w	#8,d4
	lea	(a4,d4.w),a4
	lea	0(a4),a5
	move.w	lastnos,d4
	btst	#0,d4
	beq	notarod
	addq.l	#1,a4
notarod	and.w	#254,d4
	lsl.w	#2,d4
	lea	(a4,d4.w),a4
	move.w	lastnos+4,d4
	btst	#0,d4
	beq	notard2
	addq.l	#1,a5
notard2	and.w	#254,d4
	lsl.w	#2,d4
	lea	(a5,d4.w),a5
	lea	mpfont+32*17,a6
	moveq	#7,d7
putar1	move.l	(a6)+,d6
	movep.l	d6,(a4)
	move.l	28(a6),d6
	movep.l	d6,(a5)
	lea	160(a4),a4
	lea	160(a5),a5
	dbra.w	d7,putar1
	rts
delars	movea.l	physic,a4
	move.w	lastnos+2,d4
	move.w	d4,d5
	add.w	d5,d5
	add.w	d5,d5
	add.w	d5,d4
	lsl.w	#8,d4
	lea	(a4,d4.w),a4
	lea	0(a4),a5
	move.w	lastnos,d4
	btst	#0,d4
	beq	notard3
	addq.l	#1,a4
notard3	and.w	#254,d4
	lsl.w	#2,d4
	lea	(a4,d4.w),a4
	move.w	lastnos+4,d4
	btst	#0,d4
	beq	notard4
	addq.l	#1,a5
notard4	and.w	#254,d4
	lsl.w	#2,d4
	lea	(a5,d4.w),a5
	moveq	#0,d6
	moveq	#7,d7
delar1	movep.l	d6,(a4)
	movep.l	d6,(a5)
	lea	160(a4),a4
	lea	160(a5),a5
	dbra.w	d7,delar1
	rts
	
putglow	movea.l	physic,a4		* put glowy box on screen
	move.w	lastnos+4,d4
	mulu.w	#160*8*5,d4
	add.w	#160*16+320,d4
	lea	(a4,d4.w),a4
	moveq	#3,d4
hzlp1	move.l	#$003f003f,(a4)+
	move.l	#$003f003f,(a4)+
	moveq	#17,d5
hzlp2	move.l	#$ffffffff,(a4)+
	move.l	#$ffffffff,(a4)+
	dbra.w	d5,hzlp2
	move.l	#$fc00fc00,(a4)+
	move.l	#$fc00fc00,(a4)+
	dbra.w	d4,hzlp1
	moveq	#35,d4
vtlp1	move.l	#$003c003c,(a4)
	move.l	#$003c003c,4(a4)
	move.l	#$3c003c00,152(a4)
	move.l	#$3c003c00,156(a4)
	lea	160(a4),a4
	dbra.w	d4,vtlp1
	moveq	#3,d4
hzlp3	move.l	#$003f003f,(a4)+
	move.l	#$003f003f,(a4)+
	moveq	#17,d5
hzlp4	move.l	#$ffffffff,(a4)+
	move.l	#$ffffffff,(a4)+
	dbra.w	d5,hzlp4
	move.l	#$fc00fc00,(a4)+
	move.l	#$fc00fc00,(a4)+
	dbra.w	d4,hzlp3
	rts
delglow	movea.l	physic,a4		* remove glowy box
	move.w	lastnos+4,d4
	mulu.w	#160*8*5,d4
	add.w	#160*16+320,d4
	lea	(a4,d4.w),a4
	moveq	#3,d4
	moveq	#0,d6
hzlp5	move.l	d6,(a4)+
	move.l	d6,(a4)+
	moveq	#17,d5
hzlp6	move.l	d6,(a4)+
	move.l	d6,(a4)+
	dbra.w	d5,hzlp6
	move.l	d6,(a4)+
	move.l	d6,(a4)+
	dbra.w	d4,hzlp5
	moveq	#35,d4
vtlp2	move.l	d6,(a4)
	move.l	d6,4(a4)
	move.l	d6,152(a4)
	move.l	d6,156(a4)
	lea	160(a4),a4
	dbra.w	d4,vtlp2
	moveq	#3,d4
hzlp7	move.l	d6,(a4)+
	move.l	d6,(a4)+
	moveq	#17,d5
hzlp8	move.l	d6,(a4)+
	move.l	d6,(a4)+
	dbra.w	d5,hzlp8
	move.l	d6,(a4)+
	move.l	d6,(a4)+
	dbra.w	d4,hzlp7
	rts

putname	lea	level_names,a5		* put planet's name on screen
	lea	(a5,d6.w),a5
	move.b	d5,yname
	addq.b	#1,d5
	move.b	d5,ytype
	addq.b	#1,d5
	move.b	d5,ygrav
	addq.b	#1,d5
	move.b	d5,yrate
	lea	yname+1,a6
	moveq	#23,d5
putnlp1	move.b	(a5)+,(a6)+
	dbra.w	d5,putnlp1
	lea	ytype+10,a6
	moveq	#11,d5
putnlp2	move.b	(a5)+,(a6)+
	dbra.w	d5,putnlp2
	move.l	a4,-(sp)
	moveq	#0,d6
	move.b	(a5)+,d6
	lea	gravtab,a4
	move.w	d6,d5
	add.w	d5,d5
	add.w	d5,d5
	add.w	d6,d6
	add.w	d5,d6
	lea	(a4,d6.w),a4
	moveq	#5,d5
	lea	ygrav+10,a6
putnlp3	move.b	(a4)+,(a6)+
	dbra.w	d5,putnlp3
	moveq	#0,d6
	move.b	(a5)+,d6
	lea	rattab,a4
	lsl.w	#3,d6
	lea	(a4,d6.w),a4
	moveq	#7,d5
	lea	yrate+10,a6
putnlp4	move.b	(a4)+,(a6)+
	dbra.w	d5,putnlp4
	movea.l	(sp)+,a4
textout	rts
dotext	moveq	#0,d5		* exactly what it says..
	move.b	(a5)+,d5
	cmp.b	#1,d5
	blt	textout
	beq	prat
	sub.w	#32,d5
	lsl.w	#3,d5
	move.l	a5,-(sp)
	lea	bplfont,a5
	move.l	4(a5,d5.w),d6
	move.l	(a5,d5.w),d5
	move.b	d6,1120(a6)
	lsr.l	#8,d6
	move.b	d6,960(a6)
	lsr.l	#8,d6
	move.b	d6,800(a6)
	lsr.l	#8,d6
	move.b	d6,640(a6)
	move.b	d5,480(a6)
	lsr.l	#8,d5
	move.b	d5,320(a6)
	lsr.l	#8,d5
	move.b	d5,160(a6)
	lsr.l	#8,d5
	move.b	d5,(a6)+
	movea.l	(sp)+,a5
	not.w	d7
	bne	dotext
	addq.l	#6,a6
	bra	dotext
prat	moveq	#0,d5		* really, I mean print at.
	moveq	#0,d6
	move.b	(a5)+,d5
	move.b	(a5)+,d6
	move.w	d6,d7
	add.w	d7,d7
	add.w	d7,d7
	add.w	d7,d6
	lsl.w	#8,d6
	move.w	#0,d7
	btst	#0,d5
	beq	notodd1
	not.w	d7
	addq.w	#1,d6
notodd1	and.w	#254,d5
	lsl.w	#2,d5
	add.w	d5,d6
	movea.l	back,a6
	lea	(a6,d6.w),a6
	bra	dotext

loadlev	bsr	slowcls		* exactly what it says
	lea	load_text,a5
	bsr	dotext
	bsr	swap2
	
	jsr	reinstall_interrupts	* get rid of music
	lea	lastnos,a4
	move.w	4(a4),d7
	moveq	#0,d6
	move.b	(a4,d7.w),d6
	move.w	d6,level
	mulu.w	#52,d6
	lea	level_names,a6
	lea	39(a6,d6.w),a6
	lea	inshere,a5
	moveq	#11,d6
copfnlp	move.b	(a6)+,(a5)+
	dbra.w	d6,copfnlp
reopen	move.w	#0,-(sp)
	pea	filename
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	reopen
	move.w	d0,d7
	pea	levdat
	move.l	#20000,-(sp)
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	bsr	playsam			* set samples going
	
newlev	bclr	#0,flags+1		* get level ready for player
	bclr	#2,flags+1
	lea	levdat,a0
	move.w	(a0),d0
	mulu.w	2(a0),d0
	add.w	#12,d0
	move.w	(a0,d0.w),gravstr
	move.w	2(a0,d0.w),reward
	move.l	4(a0,d0.w),fcond1
	move.w	8(a0,d0.w),fcond3
	lea	quotas,a1
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	lea	10(a0,d0.w),a0
	lea	sbads,a2
	move.w	#99,d7
dosbad	move.l	(a0),(a2)		* copy bad guys to data area
	move.l	4(a0),12(a2)
	move.l	4(a0),16(a2)
	move.w	4(a0),d0
	move.b	8(a0),23(a2)
	move.b	9(a0),24(a2)
	move.w	10(a0),26(a2)
	move.b	12(a0),29(a2)
	move.w	#0,30(a2)
	lea	sbd16,a1
	move.l	(a1,d0.w),4(a2)
	move.l	4(a1,d0.w),8(a2)
	move.w	(a2),d1
	move.w	2(a2),d2
	add.w	d1,4(a2)
	add.w	d1,6(a2)
	add.w	d2,8(a2)
	add.w	d2,10(a2)
	move.w	12(a1,d0.w),20(a2)
	move.b	18(a1,d0.w),25(a2)
	move.b	19(a1,d0.w),22(a2)
	lea	14(a0),a0
	lea	32(a2),a2
	dbra.w	d7,dosbad
	
	lea	levdat,a0	* restart data
	move.w	2(a0),d1
	move.w	(a0),d0
	sub.w	#40,d0
	move.w	d0,maxlft
	sub.w	#28,d1
	move.w	d1,maxtop
	moveq	#0,d0
	move.w	(a0),d0
	mulu.w	#26,d0
	move.w	d0,botldis
	lea	rstrt,a1
	move.l	4(a0),(a1)
	move.w	4(a0),d0
	move.w	6(a0),d1
	lsl.w	#3,d0
	lsl.w	#3,d1
	move.w	d0,12(a1)
	move.w	d0,4(a1)
	add.w	#318,d0
	move.w	d0,6(a1)
	add.w	#16,d1
	move.w	d1,14(a1)
	move.w	d1,8(a1)
	add.w	#190,d1
	move.w	d1,10(a1)
	move.w	#16,16(a1)
	lea	scrlbuf+160*16,a2
	move.l	a2,18(a1)
	move.l	8(a0),22(a1)
	
newlife	cmp.w	#999,creds		* where the new life routine
	ble	okcr1			* joins up to this bit..
	move.w	#999,creds		* ie, this is the shop screen
okcr1	add.w	#1,lives
	move.w	#$ffff,youx
	bset	#7,flags+1
	movem.l	chpal,d0-d7
	movem.l	d0-d7,$ff8240
	bsr	slowcls
	bsr	swap2
	move.w	#20,youy
	move.w	#10,lastnos
	move.w	#29,lastnos+4
	move.w	#13,lastnos+2
consscr	bsr	slowcls
	lea	plangrf+3*512,a4
	movea.l	back,a5
	lea	40+160*8(a5),a5
	moveq	#6,d7
iconlp1	lea	0(a5),a6
	moveq	#31,d6
iconlp2	move.l	(a4)+,(a6)+
	move.l	(a4)+,(a6)+
	move.l	(a4)+,(a6)+
	move.l	(a4)+,(a6)+
	lea	144(a6),a6
	dbra.w	d6,iconlp2
	lea	16(a5),a5
	dbra.w	d7,iconlp1
	lea	stores_text,a4
	lea	stordat,a5
	moveq	#6,d7
strlp1	moveq	#0,d6
	move.w	(a5)+,d6
	divu.w	#10,d6
	add.w	#'0',d6
	cmp.w	#'0',d6
	bne	vstr
	move.w	#' ',d6
vstr	move.b	d6,(a4)+
	swap	d6
	add.w	#'0',d6
	move.b	d6,(a4)+
	addq.l	#2,a4
	dbra.w	d7,strlp1
	lea	loaded_text,a4
	lea	nobombs,a5
	moveq	#5,d7
loadlp1	moveq	#0,d6
	move.b	(a5)+,d6
	divu.w	#10,d6
	add.w	#'0',d6
	cmp.w	#'0',d6
	bne	vload
	move.w	#' ',d6
vload	move.b	d6,(a4)+
	swap	d6
	add.w	#'0',d6
	move.b	d6,(a4)+
	addq.l	#2,a4
	dbra.w	d7,loadlp1
	lea	fstext,a4
	move.w	youfs,d4
	sub.w	#min_fire_speed,d4
	addq.w	#1,d4
	add.w	#'0',d4
	move.b	d4,18(a4)
	move.w	youts,d4
	sub.w	#min_turn_speed,d4
	addq.w	#1,d4
	add.w	#'0',d4
	move.b	d4,37(a4)
	move.w	youthrt,d4
	lsr.w	#6,d4
	sub.w	#min_thrust,d4
	addq.w	#1,d4
	add.w	#'0',d4
	move.b	d4,56(a4)
	lea	score_text,a4
	move.w	score,d7
	and.l	#$ffff,d7
	divu.w	#10000,d7
	add.w	#'0',d7
	move.b	d7,(a4)+
	swap	d7
	and.l	#$ffff,d7
	divu.w	#1000,d7
	add.w	#'0',d7
	move.b	d7,(a4)+
	swap	d7
	and.l	#$ffff,d7
	divu.w	#100,d7
	add.w	#'0',d7
	move.b	d7,(a4)+
	swap	d7
	and.l	#$ffff,d7
	divu.w	#10,d7
	add.w	#'0',d7
	move.b	d7,(a4)+
	swap	d7
	add.w	#'0',d7
	move.b	d7,(a4)+
	lea	cred_text,a4
	move.w	creds,d7
	and.l	#$ffff,d7
	divu.w	#100,d7
	add.w	#'0',d7
	move.b	d7,(a4)+
	swap	d7
	and.l	#$ffff,d7
	divu.w	#10,d7
	add.w	#'0',d7
	move.b	d7,(a4)+
	swap	d7
	add.w	#'0',d7
	move.b	d7,(a4)+
	
	lea	screen_text,a5
	bsr	dotext
	bsr	swap2
	bsr	putars
doscrn	bsr	getinp
	btst	#7,input
	bne	selct
	bclr	#7,youx
	btst	#0,input
	bne	scrnup
	bclr	#0,youx
	btst	#1,input
	bne	scrndwn
	bclr	#1,youx
	btst	#2,input
	bne	scrnlft
	bclr	#2,youx
	btst	#3,input
	bne	scrnrgt
	bclr	#3,youx
	bra	doscrn
scrnup	btst	#0,youx
	bne	doscrn
	bset	#0,youx
	cmp.w	#6,youy
	ble	doscrn
	bsr	delars
	cmp.w	#20,youy
	beq	ontoem
	bgt	normup
	sub.w	#7,youy
wkoutop	moveq	#0,d4
	move.w	youy,d4
	divu.w	#7,d4
	add.w	d4,d4
	addq.w	#6,d4
	move.w	d4,lastnos+2
	swap	d4
	lsl.w	#2,d4
	add.w	#10,d4
	move.w	d4,lastnos
	addq.w	#3,d4
	move.w	d4,lastnos+4
	bsr	putars
	bra	doscrn
ontoem	move.w	#16,youy
	bra	wkoutop
normup	sub.w	#1,youy
	sub.w	#2,lastnos+2
	bsr	putars
	bra	doscrn
selct	btst	#7,youx
	bne	doscrn
	bset	#7,youx
	cmp.w	#20,youy
	beq	playlev
	bgt	normsel
	cmp.w	#13,youy
	beq	doscrn
	bgt	unload
	cmp.w	#6,youy
	ble	buyem
	move.w	youy,d4
	sub.w	#7,d4
	move.w	d4,d5
	add.w	d4,d4
	lea	stordat,a4
	cmp.w	#0,(a4,d4.w)
	beq	doscrn
	lea	nobombs,a5
	cmp.b	#9,(a5,d5.w)
	beq	doscrn
	bset	#loadsound,newsam
	sub.w	#1,(a4,d4.w)
	add.b	#1,(a5,d5.w)
	bra	consscr
unload	move.w	youy,d4
	sub.w	#14,d4
	move.w	d4,d5
	add.w	d4,d4
	lea	stordat,a4
	lea	nobombs,a5
	cmp.w	#99,(a4,a4.w)
	beq	doscrn
	cmp.b	#0,(a5,d5.w)
	beq	doscrn
	sub.b	#1,(a5,d5.w)
	add.w	#1,(a4,d4.w)
	bset	#loadsound,newsam
	bra	consscr
buyem	lea	stordat,a4
	lea	costs,a5
	move.w	youy,d4
	move.w	d4,d5
	add.w	d4,d4
	cmp.w	#99,(a4,d4.w)
	beq	doscrn
	moveq	#0,d6
	move.b	(a5,d5.w),d6
	cmp.w	creds,d6
	bgt	doscrn
	sub.w	d6,creds
	bset	#buysound,newsam
	add.w	#1,(a4,d4.w)
	bra	consscr
normsel	bra	doscrn
scrndwn	btst	#1,youx
	bne	doscrn
	bset	#1,youx
	cmp.w	#19,youy
	bgt	normdn
	cmp.w	#13,youy
	bge	offofem
	bsr	delars
	add.w	#7,youy
	bra	wkoutop
offofem	bsr	delars
	move.w	#20,youy
	move.w	#10,lastnos
	move.w	#29,lastnos+4
	move.w	#13,lastnos+2
	bsr	putars
	bra	doscrn
normdn	cmp.w	#23,youy
	beq	doscrn
	bsr	delars
	add.w	#1,youy
	add.w	#2,lastnos+2
	bsr	putars
	bra	doscrn
scrnlft	btst	#2,youx
	bne	doscrn
	bset	#2,youx
	cmp.w	#20,youy
	beq	doscrn
	bgt	normlft
	cmp.w	#0,youy
	beq	doscrn
	cmp.w	#7,youy
	beq	doscrn
	cmp.w	#14,youy
	beq	doscrn
	bsr	delars
	sub.w	#1,youy
	bra	wkoutop
normlft	cmp.w	#22,youy
	beq	dts
	blt	dfs
	cmp.w	#min_thrust*64,youthrt
	beq	doscrn
	sub.w	#64,youthrt
	bset	#lrsound,newsam
	bra	consscr
dts	cmp.w	#min_turn_speed,youts
	beq	doscrn
	sub.w	#1,youts
	bset	#lrsound,newsam
	bra	consscr
dfs	cmp.w	#min_fire_speed,youfs
	beq	doscrn
	sub.w	#1,youfs
	bset	#lrsound,newsam
	bra	consscr
scrnrgt	btst	#3,youx
	bne	doscrn
	bset	#3,youx
	cmp.w	#20,youy
	beq	doscrn
	bgt	normrgt
	cmp.w	#6,youy
	beq	doscrn
	cmp.w	#13,youy
	beq	doscrn
	cmp.w	#19,youy
	beq	doscrn
	bsr	delars
	add.w	#1,youy
	bra	wkoutop
normrgt	cmp.w	#22,youy
	beq	its
	blt	ifs
	cmp.w	#max_thrust*64,youthrt
	beq	doscrn
	add.w	#64,youthrt
	bset	#lrsound,newsam
	bra	consscr
its	cmp.w	#max_turn_speed,youts
	beq	doscrn
	add.w	#1,youts
	bset	#lrsound,newsam
	bra	consscr
ifs	cmp.w	#max_fire_speed,youfs
	beq	doscrn
	add.w	#1,youfs
	bset	#lrsound,newsam
	bra	consscr
playlev	move.w	#0,onyet		* OK, lets go!!
	sub.w	#1,lives		* take a life, any life.
	bclr	#7,flags+1		* stop glow..
	movem.l	palette,d0-d7		* in-game palette
	movem.l	d0-d7,$ff8240		* to video chip
	move.w	#100,dead		* set incoming counter
	move.b	#0,wep2act
	move.w	#0,wep2def
	move.w	#0,wep2cnt
	move.w	#0,wep2frm
	move.l	#$ffffffff,lastnos	* make so reprints all
	move.w	#$ffff,lastnos+4	* bottom of screen
	move.w	#$ffff,lastsc		* data
	move.w	#$ffff,lastful
	move.w	#$ffff,lastamm
	move.w	#$ffff,lastlen
	move.w	#fuelmax,yfuel
	move.w	#ammomax,yammo
	move.w	#0,scrrght
	move.w	#0,scrlft
	lea	scrlbuf,a0
	move.l	a0,printto
	move.w	#0,youxs
	move.w	#0,youys
	move.w	#0,yougr
	move.w	#0,youtc
	move.w	#0,turn
	move.w	#0,youfc
	lea	rstrt,a0	* get restart data
	lea	left,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.l	(a0)+,copfrom
	move.w	norots,d0
	lea	scrlbuf,a1
	mulu.w	#160,d0
	lea	(a1,d0.w),a1
	move.l	a1,copfrom
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	d0,youx
	move.w	d1,youy
	lsr.w	#5,d0
	lsr.w	#5,d1
	move.w	d0,yourx
	move.w	d1,youry
	bsr	slowcls
	bsr	swap
	bset	#7,flags
	bsr	slowcls
	bsr	swap
	bset	#7,flags
	bsr	slowcls
	bsr	swap
	bsr	slowcls
	bsr	putpanl		* put the panel on
	
	lea	buldat,a0	* delete all bullets
	move.w	#maxbuls-1,d0
clrblp	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra.w	d0,clrblp
	lea	partdat,a0	* and particles
	move.w	#maxprts-1,d0
clrplp	clr.l	(a0)+
	clr.l	(a0)+
	clr.w	(a0)+
	dbra.w	d0,clrplp
	lea	bombdat,a0
	move.w	#maxbmbs-1,d0	* and bombs
clrbmlp	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra.w	d0,clrbmlp
	lea	expldat,a0	* and explosions
	move.w	#maxexpl-1,d0
clrexlp	clr.l	(a0)+
	clr.l	(a0)+
	dbra.w	d0,clrexlp
	
setup	lea	scrlbuf,a1	* draw the screen, amongst other
	moveq	#0,d0		* things.
	moveq	#0,d1
	move.w	left,d0
	move.w	top,d1
	add.w	#12,d0
	lea	levdat,a0
	mulu.w	(a0),d1
	add.l	d1,d0
	move.w	d0,topldis
	lea	(a0,d0.w),a0
	move.w	#13,d5
setuplp	bsr	prinrow		* draw a row of screen
	dbra.w	d5,setuplp
	movea.l	back,a0
	lea	192*160+105(a0),a0
	move.w	lives,d7
	cmp.w	#5,d7
	ble	okld7
	moveq	#5,d7
okld7	subq.w	#1,d7		* draw lives
	bcs	notlife
	moveq.w	#1,d6
lifelp	move.w	#10*32,d0
	bsr	putmpf
	addq.l	#1,a0
	bchg	#0,d6
	beq	notano7
	addq.l	#6,a0
notano7	dbra.w	d7,lifelp
notlife	bsr	dopanel
	bclr	#1,flags+1
	
game	bsr	swap		* the actual game loop!! (woooh)
noswap	cmp.b	#0,cmethod	* get control things into input
	beq	joystik
	move.b	sshift,d0
	lea	kbstab,a0
	and.w	#$f,d0
	move.b	(a0,d0.w),d0
	lea	fkeytab,a0
	cmp.b	#0,$27(a0)
	beq	noklft
	bset	#2,d0
	bra	nokrght
noklft	cmp.b	#0,$28(a0)
	beq	nokrght
	bset	#3,d0
nokrght	move.b	d0,input
	bra	contrej
kbstab	dc.b	%00000000,%00000000,%00000000,%00000000
	dc.b	%00000001,%00000001,%00000001,%00000001
	dc.b	%10000000,%10000000,%10000000,%10000000
	dc.b	%10000001,%10000001,%10000001,%10000001
*2nd key method
	dc.b	%00000000,%00000000,%00000000,%00000000
	dc.b	%00000001,%00000001,%00000001,%00000001
	dc.b	%00000010,%00000010,%00000010,%00000010
	dc.b	%00000011,%00000011,%00000011,%00000011
joystik	move.b	joy1,input		* this is for the joystick (NO!)
contrej	cmp.w	#0,scrrght		* scroll right??
	bne	scrlr
	cmp.w	#0,scrlft		* scroll left??
	bne	scrll
hzscrlr	bsr	youmove			* move you routine..
	move.b	#2,control		* used for control reverser..
	bsr	copbuf			* copy background to screen
	bsr	landchk			* land check
	bsr	dosbads			* do baddies
	bsr	doexpl			* do explosions
	cmp.b	#0,lastkey		* key pressed?
	beq	keybret			* no.
	move.b	#0,lastkey
	lea	fkeytab,a0
	cmp.b	#0,$39(a0)		* space?
	bne	second
	*cmp.b	#0,$12(a0)		* delete the *s on these 2 lines
	*bne	retgen			* to allow a quit with @ (i think)
	cmp.b	#0,$19(a0)		* pause? (P)
	beq	nopaws
paws	bset	#6,flags
	move.b	#0,$19(a0)
nopaws	cmp.w	#0,dead			* are you dead or incoming?
	bne	bmbret			* yes
	cmp.b	#0,$0e(a0)		* backspace (scuttle) pressed?
	beq	notdie			* no.
	move.w	#1,dead			* make you die
notdie	cmp.b	#0,$10(a0)		* Q
	bne	firebmb
	cmp.b	#0,$1e(a0)		* A
	bne	deflas
	cmp.b	#0,$1f(a0)		* S
	bne	caretro
	cmp.b	#0,$2c(a0)		* Z
	bne	cloak
	cmp.b	#0,$2d(a0)		* X
	bne	timesh
chkret	btst	#0,flags+1		* finished level?
	beq	notfin			* no
	cmp.b	#0,$14(a0)		* F
	beq	notfin
	move.w	#200,dead		* make you teleport up
notfin	cmp.b	#0,$1c(a0)		* Return
	bne	chsec
	cmp.b	#0,cmethod
	bne	keybret
	move.b	sshift,d0
	and.w	#%1110,d0
	bne	chsec
keybret	bclr	#5,flags
bmbret	bsr	youprnt
	btst	#1,flags+1
	bne	dodef
defout	lea	bombdat,a0		* Your bomb
	moveq	#0,d7
	bsr	bmblp			* do your bomb
	bsr	dobuls			* do bullets
	bsr	dobmbs			* do other bombs
	bsr	doparts			* do particles

	add.w	#1,turn			* increase turn
	move.w	turn,d0
	and.w	#15,d0
	bne	nofchk

 * Check finishing conditions!
	btst	#0,flags+1
	bne	nofchk
	cmp.w	#0,dead
	bne	nofchk		* Can't finish if not on!
	lea	quotas,a0
	lea	fcond1,a1
	moveq	#2,d7
fclp	move.b	(a1)+,d6
	cmp.b	#255,d6
	beq	finishd
	addq.b	#1,d6
	cmp.b	#255,d6
	bne	notall
	moveq.b	#0,d6
notall	and.w	#127,d6
	move.b	(a1)+,d5
	cmp.b	(a0,d6.w),d5
	bgt	nofchk
	dbra.w	d7,fclp
finishd	bset	#0,flags+1
	bset	#5,newsam
	
nofchk	btst	#5,turn+1
	bne	noT
	btst	#0,flags+1
	beq	noC		* finished??? (for printing T)
	lea	sprites+160*38,a5
	movea.l	back,a4
	adda.l	#176*160,a4
	moveq	#15,d0
Tlp	movem.w	(a5)+,d1-d5
	and.w	d1,(a4)
	and.w	d1,2(a4)
	and.w	d1,4(a4)
	and.w	d1,6(a4)
	or.w	d2,(a4)+
	or.w	d3,(a4)+
	or.w	d4,(a4)+
	or.w	d5,(a4)+
	lea	152(a4),a4
	dbra.w	d0,Tlp
	bra	noC
noT	btst	#2,flags+1		* done computer (for printing C)
	beq	noC
	lea	sprites+160*39,a5
	movea.l	back,a4
	adda.l	#176*160+152,a4
	moveq	#15,d0
Clp	movem.w	(a5)+,d1-d5
	and.w	d1,(a4)
	and.w	d1,2(a4)
	and.w	d1,4(a4)
	and.w	d1,6(a4)
	or.w	d2,(a4)+
	or.w	d3,(a4)+
	or.w	d4,(a4)+
	or.w	d5,(a4)+
	lea	152(a4),a4
	dbra.w	d0,Clp
noC	bsr	clock		* print any active clocks.
	bsr	gravity		* do gravity
	bsr	dopanel		* update panel
	btst	#6,flags	* paused?
	beq	nopause		* no
	move.l	back,a0		* pause mode routine
	lea	160*11*8+8*8(a0),a0
	moveq	#23,d0
ppslp2	moveq	#7,d1
ppslp1	clr.l	(a0)+
	dbra.w	d1,ppslp1
	lea	128(a0),a0
	dbra.w	d0,ppslp2
	lea	pawstxt,a5
	bsr	dotext
	bsr	swap
	move.w	#1,baw
	lea	fkeytab,a0
pawslp	cmp.b	#0,$19(a0)
	bne	pawsout
	cmp.b	#0,cmethod
	beq	pjoy
	move.b	sshift,d0
	lea	kbstab-16,a1
	moveq	#0,d1
	move.b	cmethod,d1
	lea	(a1,d1.w),a1
	and.w	#$f,d0
	btst.b	#7,(a1,d0.w)
	beq	pawslp
	bra	pawsout
pjoy	btst	#7,joy1
	beq	pawslp
pawsout	move.w	#-1,baw
	move.b	#0,lastkey
	bclr	#6,flags
	bra	noswap
nopause	cmp.w	#1,dead		* no pause mode
	blt	game		* this following routine is for
	beq	dead1		* the dead "variable" and includes
	cmp.w	#12,dead	* the dying routine (0<dead<99)
	beq	dead2		* the teleport in routine (100<dead<199)
	cmp.w	#28,dead	* the teleport out routine (200<dead<299)
	beq	dead1
	
incdead	add.w	#1,dead
	cmp.w	#100,dead
	blt	game
	beq	lostlif
	move.w	dead,d2
	cmp.w	#200,d2
	bge	outlev
* Check for if not just entered level...
	sub.w	#101,d2
	move.w	yourx,d0
	move.w	youry,d1
	move.w	#48,d7
	sub.w	d2,d7	*d7=displacement
	and.w	#15,d2
	moveq	#15,d3
	lea	sprites,a5
	movem.l	d0/d1/d2/d3/d7/a5,-(sp)
	sub.w	d7,d0
	sub.w	d7,d1
	bsr	sprite
	movem.l	(sp),d0/d1/d2/d3/d7/a5
	sub.w	d7,d0
	add.w	d7,d1
	bsr	sprite
	movem.l	(sp),d0/d1/d2/d3/d7/a5
	add.w	d7,d0
	sub.w	d7,d1
	bsr	sprite
	movem.l	(sp)+,d0/d1/d2/d3/d7/a5
	add.w	d7,d0
	add.w	d7,d1
	bsr	sprite
	cmp.w	#148,dead
	bne	game
	move.w	#0,dead
	bra	game
outlev	sub.w	#200,d2
	move.w	yourx,d0
	move.w	youry,d1
	move.w	d2,d7	*d7=displacement
	and.w	#15,d2
	moveq	#15,d3
	lea	sprites,a5
	movem.l	d0/d1/d2/d3/d7/a5,-(sp)
	sub.w	d7,d0
	sub.w	d7,d1
	bsr	sprite
	movem.l	(sp),d0/d1/d2/d3/d7/a5
	sub.w	d7,d0
	add.w	d7,d1
	bsr	sprite
	movem.l	(sp),d0/d1/d2/d3/d7/a5
	add.w	d7,d0
	sub.w	d7,d1
	bsr	sprite
	movem.l	(sp)+,d0/d1/d2/d3/d7/a5
	add.w	d7,d0
	add.w	d7,d1
	bsr	sprite
	cmp.w	#248,dead
	bne	game		* finished level (actually left it too!)
	move.w	#0,dead
	move.w	level,d0
	mulu.w	#6,d0
	lea	level_bits,a0
	move.w	(a0,d0.w),d1
	add.w	d1,creds	* add reward.
	cmp.w	#999,creds
	ble	okcreds
	move.w	#999,creds
okcreds	move.l	wrldone,d7
	move.w	level,d6	* clear this world from mask
	bclr	d6,d7
	move.l	d7,wrldone
	btst	#2,flags+1	* got codes?
	beq	notneww		* no
	move.l	2(a0,d0.w),d0	* enter new worlds
	or.l	d0,worlds
notneww	and.l	d7,worlds	* mask worlds, so can't do one twice.
	cmp.w	#21,d6		* Just done last one?
	beq	fingame		* yes, do finishing effect
	cmp.l	#0,worlds	* any worlds left?
	beq	nonelft		* no, game over
	bsr	samstop		* stop samples
	jsr	init_muzexx	* restart music
	jsr	play_muzexx
	bra	choose_world	* goto choose world
	
dead1	move.w	yourx,d0	* more dead routine
	move.w	youry,d1
	add.w	xline,d0
	add.w	pixline,d1
	subq.w	#8,d0
	subq.w	#8,d1
	moveq	#1,d2
	bsr	makexpl
	move.w	yourx,d0
	move.w	youry,d1
	add.w	xline,d0
	add.w	pixline,d1
	lsl.w	#3,d0
	lsl.w	#3,d1
	add.w	#8*8,d0
	add.w	#8*8,d1
	moveq	#5,d6
	bsr	makeprt
	bra	incdead
dead2	move.w	#6,d5
d2lp	move.w	yourx,d0
	move.w	youry,d1
	add.w	xline,d0
	add.w	pixline,d1
	bsr	random
	and.w	#31,d7
	sub.w	#16,d7
	add.w	d7,d0
	bsr	random
	and.w	#31,d7
	sub.w	#16,d7
	add.w	d7,d1
	bsr	random
	and.w	#31,d7
	moveq	#0,d2
	cmp.w	#20,d7
	bgt	oklitx
	moveq	#1,d2
	subq.w	#8,d0
	subq.w	#8,d1
oklitx	bsr	makexpl
	addq.w	#8,d0
	addq.w	#8,d1
	cmp.w	#0,d2
	beq	okd0d1
	addq.w	#8,d0
	addq.w	#8,d1
okd0d1	lsl.w	#3,d0
	lsl.w	#3,d1
	moveq	#3,d6
	bsr	makeprt
	dbra.w	d5,d2lp
	bra	incdead
	
lostlif	move.l	#0,nobombs	* lost a life routine
	move.w	#0,nobombs+4
	sub.w	#1,lives	* lose the life
	bcs	gamover		* game over when no lives left.
	bra	newlife		* goto new life
nonelft	movea.l	back,a0		* no lives left ( game over )
	lea	160*8+32(a0),a0
	moveq	#0,d2
	moveq	#31,d0
boxlp2	moveq	#19,d1
	movep.l	d2,1(a0)
	addq.l	#8,a0
boxlp1	clr.l	(a0)+
	dbra.w	d1,boxlp1
	movep.l	d2,(a0)
	lea	72(a0),a0
	dbra.w	d0,boxlp2
	lea	nonetxt,a5
	bsr	dotext
gamover	lea	highs,a0	* check hs table to see if you're in it
	lea	hstab+5,a1
	moveq	#9,d0
	move.w	score,d1
scrlp	cmp.w	(a0),d1
	ble	hsout
	cmp.w	#9,d0
	beq	ntcophs
	move.w	(a0),2(a0)
	moveq	#26,d2
cophslp	move.b	(a1,d2.w),32(a1,d2.w)
	dbra.w	d2,cophslp
ntcophs	subq.l	#2,a0
	lea	-32(a1),a1
	dbra.w	d0,scrlp
hsout	addq.l	#2,a0
	lea	32(a1),a1
	cmp.w	#9,d0
	beq	nohs
	move.w	score,d0
	move.w	d0,(a0)
	and.l	#$ffff,d0
	divu.w	#10000,d0
	add.w	#'0',d0
	move.b	d0,(a1)
	swap	d0
	and.l	#$ffff,d0
	divu.w	#1000,d0
	add.w	#'0',d0
	move.b	d0,1(a1)
	swap	d0
	and.l	#$ffff,d0
	divu.w	#100,d0
	add.w	#'0',d0
	move.b	d0,2(a1)
	swap	d0
	and.l	#$ffff,d0
	divu.w	#10,d0
	add.w	#'0',d0
	move.b	d0,3(a1)
	swap	d0
	add.w	#'0',d0
	move.b	d0,4(a1)
	lea	7(a1),a1
	moveq	#19,d2
delhslp	move.b	#' ',(a1,d2.w)
	dbra.w	d2,delhslp
	movea.l	back,a0
	lea	160*8*6+56(a0),a0
	moveq	#23,d1
thnglp6	moveq	#11,d0
thnglp5	clr.l	(a0)+
	dbra.w	d0,thnglp5
	lea	112(a0),a0
	dbra.w	d1,thnglp6
	movea.l	back,a0
	lea	160*8*10+32(a0),a0
	moveq	#31,d1
thnglp8	moveq	#23,d0
thnglp7	clr.l	(a0)+
	dbra.w	d0,thnglp7
	lea	64(a0),a0
	dbra.w	d1,thnglp8
	movea.l	back,a0
	lea	160*8*15+32(a0),a0
	moveq	#31,d1
thnglp0	moveq	#23,d0
thnglp9	clr.l	(a0)+
	dbra.w	d0,thnglp9
	lea	64(a0),a0
	dbra.w	d1,thnglp0
	lea	hstext,a5
	bsr	dotext
	move.w	#1,baw
	bsr	swap
	moveq	#10,d0
	movea.l	physic,a0
	lea	160*8*17+40(a0),a0
nextlet	move.b	#0,lastkey
letlp	cmp.b	#0,lastkey
	beq	letlp
	lea	keylist,a2
	move.b	lastkey,d1
	and.w	#$ff,d1
	cmp.w	#$3a,d1
	bgt	nextlet
	move.b	(a2,d1.w),d1
	cmp.b	#32,d1
	blt	special
	move.b	d1,(a1)+
	and.w	#$ff,d1
	sub.w	#32,d1
	lsl.w	#3,d1
	lea	bplfont,a5
	move.l	4(a5,d1.w),d6
	move.l	(a5,d1.w),d5
	move.b	d6,1120(a0)
	lsr.l	#8,d6
	move.b	d6,960(a0)
	lsr.l	#8,d6
	move.b	d6,800(a0)
	lsr.l	#8,d6
	move.b	d6,640(a0)
	move.b	d5,480(a0)
	lsr.l	#8,d5
	move.b	d5,320(a0)
	lsr.l	#8,d5
	move.b	d5,160(a0)
	lsr.l	#8,d5
	move.b	d5,(a0)+
	addq.w	#1,d0
	btst	#0,d0
	bne	notcros
	addq.l	#6,a0
notcros	bset	#2,newsam
	cmp.w	#30,d0
	bne	nextlet
donname	bsr	samstop
	bra	title
special	cmp.b	#1,d1
	blt	nextlet
	beq	donname
	cmp.w	#10,d0
	beq	nextlet
	subq.w	#1,d0
	subq.l	#1,a0
	btst	#0,d0
	beq	notcr2
	subq.l	#6,a0
notcr2	subq.l	#1,a1
	move.b	#' ',(a1)
	clr.b	(a0)
	clr.b	160(a0)
	clr.b	320(a0)
	clr.b	480(a0)
	clr.b	640(a0)
	clr.b	800(a0)
	clr.b	960(a0)
	clr.b	1120(a0)
	bset	#1,newsam
	bra	nextlet
nohs	movea.l	back,a0
	lea	160*8*9+56(a0),a0
	moveq	#23,d1
thnglp2	moveq	#11,d0
thnglp1	clr.l	(a0)+
	dbra.w	d0,thnglp1
	lea	112(a0),a0
	dbra.w	d1,thnglp2
	movea.l	back,a0
	lea	160*8*21+32(a0),a0
	moveq	#23,d1
thnglp4	moveq	#23,d0
thnglp3	clr.l	(a0)+
	dbra.w	d0,thnglp3
	lea	64(a0),a0
	dbra.w	d1,thnglp4
	lea	gamtxt2,a5
	bsr	dotext
	move.w	#1,baw
	bsr	swap
nohslp	lea	fkeytab,a0
	cmp.b	#0,$39(a0)
	bne	goveout
	btst	#3,sshift
	bne	goveout
	btst	#7,joy1
	beq	nohslp
goveout	bsr	samstop
	bra	title
	
landchk	and.w	#%1110011011110111,flags	* land check
	cmp.w	#0,dead
	bne	noland
	cmp.w	#0,yougr
	bne	noland
	cmp.w	#0,youys
	blt	noland
	cmp.w	#32*4,youys		* check speed
	bgt	noland
	cmp.w	#12*4,youxs
	bgt	noland
	cmp.w	#-12*4,youxs
	blt	noland
	lea	coltab,a0
	move.w	12(a0),d0
	move.w	14(a0),d1
	add.w	yourx,d0
	add.w	youry,d1
	addq.w	#1,d1
	bsr	point
	cmp.w	#0,d0
	beq	noland
	move.w	16(a0),d0
	move.w	18(a0),d1
	add.w	yourx,d0
	add.w	youry,d1
	addq.w	#1,d1
	bsr	point
	cmp.w	#0,d0
	beq	noland
******Check for landed on ff	* mot implemented.

	bset	#0,flags
	move.w	#0,youxs
	move.w	#0,youys

******Check refuel/rearm here
	lea	sbads,a2	
	move.w	#99,d7
chfullp	cmp.w	#0,(a2)
	beq	noreful
	cmp.b	#0,28(a2)
	beq	nxtbase
	cmp.w	#4,20(a2)
	beq	chrngef
	cmp.w	#36,20(a2)
	beq	chrnged
	cmp.w	#32,20(a2)
	bne	nxtbase
	cmp.w	#ammomax,yammo
	beq	nxtbase
	move.w	yourx,d0
	move.w	youry,d1
	add.w	xline,d0
	add.w	pixline,d1
	sub.w	(a2),d0
	sub.w	2(a2),d1
	cmp.w	#-32,d0
	blt	nxtbase
	cmp.w	#32,d0
	bgt	nxtbase
	cmp.w	#8,d1
	bgt	nxtbase
	cmp.w	#-8,d1
	blt	nxtbase
	add.w	#1,yammo
	bset	#4,flags
	bsr	savepos
	bra	noreful
nxtbase	lea	32(a2),a2
	dbra.w	d7,chfullp
noreful	
noland	rts
				* Save position
savepos	lea	left,a0
	lea	rstrt,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.l	copfrom,(a1)+
	move.w	youx,(a1)+
	move.w	youy,(a1)+
	rts
chrngef	cmp.w	#fuelmax,yfuel
	beq	nxtbase
	move.w	yourx,d0
	move.w	youry,d1
	add.w	xline,d0
	add.w	pixline,d1
	sub.w	(a2),d0
	sub.w	2(a2),d1
	cmp.w	#-32,d0
	blt	nxtbase
	cmp.w	#32,d0
	bgt	nxtbase
	cmp.w	#8,d1
	bgt	nxtbase
	cmp.w	#-8,d1
	blt	nxtbase
	add.w	#1,yfuel
	bset	#3,flags
	bsr	savepos
	bra	noreful
chrnged	move.w	yourx,d0
	move.w	youry,d1
	add.w	xline,d0
	add.w	pixline,d1
	sub.w	(a2),d0
	sub.w	2(a2),d1
	cmp.w	#-32,d0
	blt	nxtbase
	cmp.w	#32,d0
	bgt	nxtbase
	cmp.w	#8,d1
	bgt	nxtbase
	cmp.w	#-8,d1
	blt	nxtbase
	bset	#3,flags+1
	bset	#2,flags+1
	bsr	savepos
	bra	noreful
	
chsec	move.b	#0,$1c(a0)	* change secondary weapon
	btst	#5,flags
	bne	bmbret
	bset	#5,flags
	moveq	#0,d0
	move.b	wep2typ,d0
	lsr.w	#2,d0
	lea	nobombs,a0
	moveq	#3,d1
chnlp	addq.w	#1,d0
	cmp.w	#5,d0
	blt	nowraps
	moveq	#0,d0
nowraps	cmp.b	#0,(a0,d0.w)
	bne	choosd0
	dbra.w	d1,chnlp
	bra	bmbret
choosd0	lsl.w	#2,d0
	move.b	d0,wep2typ
	move.w	#$ffff,lastnos
	bra	bmbret
second	move.b	#0,$39(a0)		* do secondary weapon
	cmp.w	#0,dead
	bne	bmbret
	moveq	#0,d0
	move.b	wep2typ,d0
	lea	sectab,a1
	movea.l	(a1,d0.w),a1
	jmp	(a1)
firebmb	move.b	#0,$10(a0)		* bomb
	cmp.b	#0,nobombs
	beq	bmbret
	lea	bombdat,a0
	cmp.w	#0,(a0)
	bne	bmbret
	sub.b	#1,nobombs
	bset	#3,newsam
	move.w	yougr,d2
	lsl.w	#5,d2
	move.w	yourx,d0
	move.w	youry,d1
	add.w	xline,d0
	add.w	pixline,d1
	lea	coltab,a1
	add.w	24(a1,d2.w),d0
	add.w	26(a1,d2.w),d1
	subq.w	#1,d1
	subq.w	#7,d0
	lsl.w	#3,d0
	lsl.w	#3,d1
	move.w	d0,(a0)
	move.w	d1,2(a0)
	move.w	#1,10(a0)
	move.w	#100,8(a0)
	lea	dirtab,a1
	lsr.w	#3,d2
	move.w	(a1,d2.w),4(a0)
	move.w	2(a1,d2.w),6(a0)
	bra	bmbret
deflas	move.b	#0,$1e(a0)		* defence laser
	cmp.b	#0,nodefs
	beq	bmbret
	* Play sample
	move.w	#0,nodef
	bset	#1,flags+1
	sub.b	#1,nodefs
	move.w	yourx,d0
	move.w	youry,d1
	addq.w	#7,d0
	addq.w	#7,d1
	lea	defspace,a1
	lea	0(a1),a2
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	lea	buldat,a3
	moveq.w	#maxbuls-1,d7
dbullp	move.w	d7,-(sp)
	cmp.w	#0,(a3)
	beq	nxtdbul
	move.w	(a3),d2
	move.w	2(a3),d3
	lsr.w	#3,d2
	lsr.w	#3,d3
	sub.w	xline,d2
	bcs	nxtdbul
	cmp.w	#319,d2
	bgt	nxtdbul
	sub.w	pixline,d3
	bcs	nxtdbul
	cmp.w	#191,d3
	bgt	nxtdbul
	move.w	(a1),d0
	move.w	2(a1),d1
	move.w	d2,d4
	move.w	d3,d5
	sub.w	d0,d4
	sub.w	d1,d5
	muls.w	d4,d4
	muls.w	d5,d5
	add.l	d5,d4
	cmp.l	#68*68,d4
	bgt	nxtdbul
	bsr	sline
	cmp.w	#0,d7
	bne	nxtdbul
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.l	a2,-(sp)
	move.w	(a3),d0
	move.w	2(a3),d1
	moveq	#2,d6
	bsr	makeprt	
	movea.l	(sp)+,a2
	move.w	#0,(a3)
	add.w	#1,nodef
nxtdbul	lea	12(a3),a3
	move.w	(sp)+,d7
	dbra.w	d7,dbullp
	lea	bombdat+12,a3
	move.w	#maxbmbs-2,d7
dbmblp	move.w	d7,-(sp)
	cmp.w	#0,(a3)
	beq	nxtdbmb
	move.w	(a3),d2
	move.w	2(a3),d3
	lsr.w	#3,d2
	lsr.w	#3,d3
	addq.w	#1,d3
	addq.w	#7,d2
	sub.w	xline,d2
	bcs	nxtdbmb
	cmp.w	#319,d2
	bgt	nxtdbmb
	sub.w	pixline,d3
	bcs	nxtdbmb
	cmp.w	#191,d3
	bgt	nxtdbmb
	move.w	(a1),d0
	move.w	2(a1),d1
	move.w	d2,d4
	move.w	d3,d5
	sub.w	d0,d4
	sub.w	d1,d5
	muls.w	d4,d4
	muls.w	d5,d5
	add.l	d5,d4
	cmp.l	#68*68,d4
	bgt	nxtdbmb
	bsr	sline
	cmp.w	#0,d7
	bne	nxtdbmb
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.l	a2,-(sp)
	move.w	(a3),d0
	move.w	2(a3),d1
	moveq	#5,d6
	bsr	makeprt
	lsr.w	#3,d0
	lsr.w	#3,d1
	moveq	#1,d2
	subq.w	#8,d0
	sub.w	#14,d1
	bsr	makexpl
	movea.l	(sp)+,a2
	move.w	#0,(a3)
	add.w	#1,nodef
nxtdbmb	lea	12(a3),a3
	move.w	(sp)+,d7
	dbra.w	d7,dbmblp
	
	bra	bmbret
sline	move.w	d2,d4		* line routine ( point, not plot )
	move.w	d3,d5
	sub.w	d0,d4
	sub.w	d1,d5
	move.w	#1,xstep
	move.w	#1,ystep
	moveq	#0,d6
	cmp.w	#0,d4
	bge	okxstep
	move.w	#-1,xstep
	not.w	d4
	addq.w	#1,d4
okxstep	cmp.w	#0,d5
	bgt	okystep
	beq	ysiszer
	move.w	#-1,ystep
	not.w	d5
	addq.w	#1,d5
okystep	move.w	d0,-(sp)
	move.w	d1,-(sp)
	bsr	point
	cmp.w	#0,d0
	bne	hitpnt
	move.w	(sp)+,d1
	move.w	(sp)+,d0
	cmp.w	d1,d3
	bne	notat
	cmp.w	d0,d2
	bne	notat
	moveq	#0,d7
	rts
notat	cmp.w	#0,d6
	bge	chy
	add.w	xstep,d0
	add.w	d5,d6
	bra	okystep
chy	add.w	ystep,d1
	sub.w	d4,d6
	bra	okystep
hitpnt	move.w	(sp)+,d1
	move.w	(sp)+,d0
	moveq.w	#1,d7
	rts
doline	move.w	d2,d4		* draw line routine
	move.w	d3,d5
	sub.w	d0,d4
	sub.w	d1,d5
	move.w	#1,xstep
	move.w	#1,ystep
	moveq	#0,d6
	cmp.w	#0,d4
	bge	kxstep
	move.w	#-1,xstep
	not.w	d4
	addq.w	#1,d4
kxstep	cmp.w	#0,d5
	bgt	kystep
	beq	yiszer
	move.w	#-1,ystep
	not.w	d5
	addq.w	#1,d5
kystep	move.w	d0,-(sp)
	move.w	d1,-(sp)
	bsr	plot1
	move.w	(sp)+,d1
	move.w	(sp)+,d0
	cmp.w	d1,d3
	bne	notat2
	cmp.w	d0,d2
	bne	notat2
	rts
notat2	cmp.w	#0,d6
	bge	chy2
	add.w	xstep,d0
	add.w	d5,d6
	bra	kystep
chy2	add.w	ystep,d1
	sub.w	d4,d6
	bra	kystep
plot1	move.w	d1,d7
	add.w	d7,d7
	add.w	d7,d7
	add.w	d7,d1
	lsl.w	#5,d1
	move.w	d0,d7
	and.w	#65535-15,d7
	lsr.w	#1,d7
	add.w	d7,d1
	and.w	#15,d0
	move.w	#32768,d7
	ror.w	d0,d7
	movea.l	back,a5
	lea	(a5,d1.w),a5
	or.w	d7,(a5)+
	not.w	d7
	and.w	d7,(a5)+
	and.w	d7,(a5)+
	and.w	d7,(a5)+
	rts
yiszer	move.w	#-1,d6
	bra	kystep
dodef	lea	defspace,a0
	lea	4(a0),a1
	bclr	#1,flags+1
	move.w	nodef,d7
	subq.w	#1,d7
	bcs	defout	
deflp	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	(a1)+,d2
	move.w	(a1)+,d3
	move.w	d7,-(sp)
	bsr	doline
	move.w	(sp)+,d7
	dbra.w	d7,deflp
	bra	defout
ysiszer	moveq.w	#-1,d6
	bra	okystep
timesh	move.b	#0,$2d(a0)		* timer shields
	cmp.b	#0,notimer
	beq	bmbret
	cmp.b	#0,wep2act
	bne	bmbret
	bset	#4,newsam
	move.b	#1,wep2act
	sub.b	#1,notimer
	move.w	#timershtime,wep2cnt
	move.w	#0,wep2frm
	move.w	#timershtime,wep2def
	bra	bmbret
caretro	move.b	#0,$1f(a0)		* retros
	cmp.b	#0,noretro
	beq	bmbret
	bset	#4,newsam
	sub.b	#1,noretro
	move.w	#0,youxs
	move.w	#0,youys
	bra	bmbret
cloak	move.b	#0,$2c(a0)		* cloaking device
	cmp.b	#0,nocloak
	beq	bmbret
	cmp.b	#0,wep2act
	bne	bmbret
	bset	#6,newsam
	move.b	#2,wep2act
	sub.b	#1,nocloak
	move.w	#cloaktime,wep2cnt
	move.w	#0,wep2frm
	move.w	#cloaktime,wep2def
	bra	bmbret
youmove	cmp.w	#0,dead			* move you routine
	bne	scrlret
	btst	#0,flags
	bne	turnout
	move.b	control,d0
	btst	d0,input
	bne	turnlft
	bchg	#0,d0
	btst	d0,input
	bne	turnrgt
turnout	btst	#0,input
	bne	thrust
	move.w	youxs,d0
	move.w	youys,d1
	bsr	coryouv
thrret	movem.w	youx,d0-d3
	movem.w	d2-d3,-(sp)
	asr.w	#2,d2
	asr.w	#2,d3
	add.w	d2,d0
	add.w	d3,d1
	movem.w	(sp)+,d2-d3
	move.w	d0,d4
	move.w	d1,d5
	asr.w	#5,d4
	asr.w	#5,d5
	movem.w	d0-d5,youx
	cmp.w	#scrluppt,youry
	ble	scrlup
	cmp.w	#scrldnpt,youry
	bgt	scrldwn
scrlret	cmp.w	#scrlrtpt,yourx
	bge	dorgtsc
	cmp.w	#scrlftpt,yourx
	ble	dolftsc
	rts
dorgtsc	move.w	#noscrolls,scrrght
	rts
dolftsc	move.w	#noscrolls,scrlft
	rts

youprnt	cmp.w	#0,dead			* print you routine
	bne	yourded
	moveq	#0,d0
	move.w	yougr,d0
	lsl.w	#5,d0
	lea	coltab,a0
	lea	(a0,d0.w),a0
	moveq	#5,d6
chcklp	move.w	yourx,d0
	move.w	youry,d1
	add.w	(a0)+,d0
	add.w	(a0)+,d1
	bsr	point
	cmp.w	#0,d0
	bne	deadha
	dbra.w	d6,chcklp
	
	movem.w	yourx,d0-d2
	moveq	#15,d3
	lea	sprites,a5
	btst	#0,flags
	beq	notlnd
	btst	#3,flags
	bne	fueling
	btst	#3,flags+1
	bne	dataing
	btst	#4,flags
	beq	notlnd
	moveq.w	#34,d2
	bra	lndanim
dataing	moveq.w	#40,d2
	bra	lndanim
fueling	moveq.w	#32,d2
lndanim	btst	#0,turn+1
	bne	nothr2
	addq.w	#1,d2
	bra	nothr2
notlnd	btst	#0,input
	beq	nothr2
	cmp.w	#0,yfuel
	beq	nothr2
	add.w	#16,d2
nothr2	bsr	sprite
	btst	#7,input
	bne	fire
	bclr	#1,flags
	move.w	#0,youfc
fireout
yourded	rts
notonyt	rts
deadha	move.w	#1,dead
	rts
fire	move.w	youfs,d0
	btst	#1,flags
	beq	nofrqc
	add.w	d0,youfc
	cmp.w	#16,youfc
	blt	fireout
	sub.w	#16,youfc
nofrqc	cmp.w	#0,yammo
	beq	fireout
	sub.w	#1,yammo
	bset	#1,flags
	lea	coltab,a0
	move.w	yougr,d7
	lsl.w	#5,d7
	move.w	24(a0,d7.w),d0
	move.w	26(a0,d7.w),d1
	add.w	yourx,d0
	add.w	youry,d1
	add.w	pixline,d1
	add.w	xline,d0
	lsl.w	#3,d0
	lsl.w	#3,d1
	lea	dirtab,a0
	move.w	yougr,d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	(a0,d7.w),d2
	move.w	2(a0,d7.w),d3
	moveq.w	#0,d4
	moveq.w	#0,d5
	move.w	youbulr,d6
	bset	#2,newsam
	bsr	makebul
	bra	fireout
turnrgt	move.w	youts,d0
	add.w	d0,youtc
	cmp.w	#turnspeed,youtc
	blt	turnout
	sub.w	#turnspeed,youtc
	add.w	#1,yougr
	cmp.w	#16,yougr
	blt	turnout
	move.w	#0,yougr
	bra	turnout
turnlft	move.w	youts,d0
	add.w	d0,youtc
	cmp.w	#turnspeed,youtc
	blt	turnout
	sub.w	#turnspeed,youtc
	sub.w	#1,yougr
	bcc	turnout
	move.w	#15,yougr
	bra	turnout
thrust	cmp.w	#0,yfuel
	beq	thrret
	lea	thrtab,a0
	move.w	yougr,d7
	add.w	d7,d7
	add.w	d7,d7
	add.w	youthrt,d7
	move.w	youxs,d0
	move.w	youys,d1
	add.w	(a0,d7.w),d0
	add.w	2(a0,d7.w),d1
	bsr	coryouv
	move.b	fuelcad,d7
	add.b	d7,fuelcnt
	cmp.b	#fuelconsumption,fuelcnt
	blt	thrret
	sub.b	#fuelconsumption,fuelcnt
	sub.w	#1,yfuel
	bra	thrret
coryouv	cmp.w	#-64*4,d0
	bge	nocorls
	move.w	#-64*4,d0
	bra	nocorhs
nocorls	cmp.w	#64*4,d0
	ble	nocorhs
	move.w	#64*4,d0
nocorhs	cmp.w	#-64*4,d1
	bge	nocorus
	move.w	#-64*4,d1
	bra	nocorvs
nocorus	cmp.w	#64*4,d1
	ble	nocorvs
	move.w	#64*4,d1
nocorvs	move.w	d0,youxs
	move.w	d1,youys
	rts
	
gravity	move.w	gravstr,d0		* do gravity
	add.w	d0,gravcnt
	cmp.w	#grav_power,gravcnt
	blt	gravout
	sub.w	#grav_power,gravcnt
	lea	partdat,a0
	move.w	#maxprts-1,d7
partlp2	cmp.w	#0,(a0)
	beq	nxtprt3
	add.w	#1,6(a0)
nxtprt3	lea	10(a0),a0
	dbra.w	d7,partlp2
	btst	#0,flags
	bne	gravout
	add.w	#1,youys
	cmp.w	#64*4,youys
	ble	gravout
	move.w	#64*4,youys
gravout	rts

*************Panel updates****************

dopanel	bclr	#2,flags
	move.l	nobombs,d7
	cmp.l	lastnos,d7
	beq	notsecs
dosecs	bset	#2,flags
	movea.l	back,a0
	lea	192*160+88(a0),a0
	moveq	#0,d7
	move.b	wep2typ,d7
	lsr.w	#2,d7
	move.w	d7,d0
	add.w	#12,d0
	lsl.w	#5,d0
	bsr	putmpf
	addq.l	#1,a0
	lea	nobombs,a1
	moveq	#0,d0
	move.b	(a1,d7.w),d0
	lsl.w	#5,d0
	bsr	putmpf
	move.l	nobombs,lastnos
	move.b	notimer,lastnos+4
notsecs	move.b	notimer,d7
	cmp.b	lastnos+4,d7
	bne	dosecs
	move.b	nimpact,d7
	cmp.b	lastnos+5,d7
	beq	notimps
	bset	#2,flags
	movea.l	back,a0
	lea	192*160+64(a0),a0
	move.w	#11*32,d0
	bsr	putmpf
	addq.l	#1,a0
	moveq	#0,d0
	move.b	nimpact,d0
	lsl.w	#5,d0
	bsr	putmpf
	move.b	nimpact,lastnos+5
notimps	move.w	yfuel,d7
	cmp.w	lastful,d7
	beq	notfuel
	addq.w	#7,d7
	lsr.w	#3,d7
	cmp.b	lastlen,d7
	beq	notfuel
	move.b	d7,lastlen
	bset	#2,flags
	movea.l	back,a0
	lea	194*160+8(a0),a0
	bsr	clrbar
	move.w	#$ffff,d0
	cmp.w	#16,d7
	blt	cutlen1
	sub.w	#16,d7
	move.w	d0,6(a0)
	move.w	d0,160(a0)
	move.w	d0,162(a0)
	move.w	d0,164(a0)
	move.w	d0,320(a0)
	move.w	d0,322(a0)
	move.w	d0,324(a0)
	move.w	d0,482(a0)
	move.w	d0,484(a0)
	lea	8(a0),a0
cutlen1	cmp.w	#0,d7
	beq	barout1
	not.w	d7
	addq.w	#1,d7
	and.w	#15,d7
	lsl.w	d7,d0
	move.w	d0,6(a0)
	move.w	d0,160(a0)
	move.w	d0,162(a0)
	move.w	d0,164(a0)
	move.w	d0,320(a0)
	move.w	d0,322(a0)
	move.w	d0,324(a0)
	move.w	d0,482(a0)
	move.w	d0,484(a0)
barout1	move.w	yfuel,lastful
notfuel	move.w	yammo,d7
	cmp.w	lastamm,d7
	beq	notammo
	addq.w	#7,d7
	lsr.w	#3,d7
	cmp.b	lastlen+1,d7
	beq	notammo
	move.b	d7,lastlen
	bset	#2,flags
	movea.l	back,a0
	lea	194*160+136(a0),a0
	bsr	clrbar
	move.w	#$ffff,d0
	cmp.w	#16,d7
	blt	cutlen2
	sub.w	#16,d7
	move.w	d0,(a0)
	move.w	d0,4(a0)
	move.w	d0,6(a0)
	move.w	d0,160(a0)
	move.w	d0,162(a0)
	move.w	d0,164(a0)
	move.w	d0,166(a0)
	move.w	d0,320(a0)
	move.w	d0,322(a0)
	move.w	d0,324(a0)
	move.w	d0,326(a0)
	move.w	d0,482(a0)
	move.w	d0,484(a0)
	move.w	d0,486(a0)
	lea	8(a0),a0
cutlen2	cmp.w	#0,d7
	beq	barout2
	not.w	d7
	addq.w	#1,d7
	and.w	#15,d7
	lsl.w	d7,d0
	move.w	d0,(a0)
	move.w	d0,4(a0)
	move.w	d0,6(a0)
	move.w	d0,160(a0)
	move.w	d0,162(a0)
	move.w	d0,164(a0)
	move.w	d0,166(a0)
	move.w	d0,320(a0)
	move.w	d0,322(a0)
	move.w	d0,324(a0)
	move.w	d0,326(a0)
	move.w	d0,482(a0)
	move.w	d0,484(a0)
	move.w	d0,486(a0)
barout2	move.w	yammo,lastamm
notammo	moveq	#0,d7
	move.w	score,d7
	cmp.w	lastsc,d7
	beq	notsc
	bset	#2,flags
	movea.l	back,a0
	lea	192*160+32(a0),a0
	divu.w	#10000,d7
	move.w	d7,d0
	lsl.w	#5,d0
	bsr	putmpf
	swap	d7
	and.l	#$ffff,d7
	addq.l	#1,a0
	divu.w	#1000,d7
	move.w	d7,d0
	lsl.w	#5,d0
	bsr	putmpf
	swap	d7
	and.l	#$ffff,d7
	addq.l	#7,a0
	divu.w	#100,d7
	move.w	d7,d0
	lsl.w	#5,d0
	bsr	putmpf
	swap	d7
	and.l	#$ffff,d7
	addq.l	#1,a0
	divu.w	#10,d7
	move.w	d7,d0
	lsl.w	#5,d0
	bsr	putmpf
	swap	d7
	addq.l	#7,a0
	move.w	d7,d0
	lsl.w	#5,d0
	bsr	putmpf
	move.w	score,lastsc
notsc	btst	#2,flags
	beq	notupd
	movea.l	back,a0
	movea.l	physic,a1
	movea.l	back2,a2
	lea	192*160(a0),a0
	lea	192*160(a1),a1
	lea	192*160(a2),a2
	moveq	#7,d0
copanlp	movem.l	(a0)+,d1-d7/a3-a6
	movem.l	d1-d7/a3-a6,(a1)
	movem.l	d1-d7/a3-a6,(a2)
	movem.l	(a0)+,d1-d7/a3-a6
	movem.l	d1-d7/a3-a6,44(a1)
	movem.l	d1-d7/a3-a6,44(a2)
	movem.l	(a0)+,d1-d7/a3-a6
	movem.l	d1-d7/a3-a6,88(a1)
	movem.l	d1-d7/a3-a6,88(a2)
	movem.l	(a0)+,d1-d7
	movem.l	d1-d7,132(a1)
	movem.l	d1-d7,132(a2)
	lea	160(a2),a2
	lea	160(a1),a1
	dbra.w	d0,copanlp
notupd	rts

putmpf	lea	mpfont,a2
	lea	(a2,d0.w),a2
	movea.l	a0,a1
	movem.l	(a2)+,d0-d3
	movep.l	d0,(a1)
	movep.l	d1,160(a1)
	movep.l	d2,320(a1)
	movep.l	d3,480(a1)
	lea	640(a1),a1
	movem.l	(a2)+,d0-d3
	movep.l	d0,(a1)
	movep.l	d1,160(a1)
	movep.l	d2,320(a1)
	movep.l	d3,480(a1)
	rts
clrbar	movea.l	a0,a1
	move.w	#3,d0
clrbrlp	move.l	#0,(a1)
	move.l	#0,4(a1)
	move.l	#0,8(a1)
	move.l	#0,12(a1)
	lea	160(a1),a1
	dbra.w	d0,clrbrlp
	rts

*************Clock countdown code*********

clock	cmp.w	#0,clckdef
	beq	clckout
	sub.w	#1,clckcnt
	bne	putclck
	add.w	#128,clckfrm
	move.w	clckdef,clckcnt
	cmp.w	#24*128,clckfrm
	beq	timeout
putclck	move.w	clckfrm,d0
	lea	clckgrf,a0
	lea	(a0,d0.w),a0
	movea.l	back,a1
	lea	152(a1),a1
	moveq	#15,d1
clcklp	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	lea	160(a1),a1
	dbra.w	d1,clcklp
clckout	cmp.b	#0,wep2act
	beq	clckdon
	movea.l	back,a1
	cmp.w	#0,dead
	bne	putlclk
	sub.w	#1,wep2cnt
	bne	putlclk
	move.w	wep2def,wep2cnt
	add.w	#128,wep2frm
	cmp.w	#128*24,wep2frm
	bne	putlclk
	move.b	#0,wep2act
	move.w	#0,wep2def
	move.l	#0,wep2cnt
	bra	clckdon
putlclk	lea	clckgrf+128*25,a0
	move.w	wep2frm,d0
	lea	(a0,d0.w),a0
	moveq	#15,d0
clcklp2	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	lea	160(a1),a1
	dbra.w	d0,clcklp2
clckdon	rts
timeout	bra	retgen

********bombs and missiles****************

dobmbs	lea	bombdat+12,a0
	move.w	#maxbmbs-2,d7
bmblp	move.w	(a0),d0
	cmp.w	#0,d0
	beq	nextbmb
	move.w	d7,-(sp)
	sub.w	#1,8(a0)
	beq	bmbhits
	move.w	2(a0),d1
	add.w	4(a0),d0
	add.w	6(a0),d1
	move.w	d0,(a0)
	move.w	d1,2(a0)
	lsr.w	#3,d0
	lsr.w	#3,d1
	cmp.b	#0,10(a0)
	beq	ordinry
	cmp.w	#0,dead
	bne	ordinry
	cmp.b	#2,wep2act
	beq	ordinry
	move.w	turn,d4
	and.w	#3,d4
	bne	ordinry
	move.w	d0,-(sp)
	move.w	d1,-(sp)
	addq.w	#6,d1
	sub.w	xline,d0
	sub.w	pixline,d1
	sub.w	yourx,d0
	sub.w	youry,d1
	not.w	d0
	not.w	d1
	addq.w	#1,d0
	addq.w	#1,d1
	asr.w	#4,d0
	asr.w	#4,d1
	add.w	4(a0),d0
	add.w	6(a0),d1
	cmp.w	#16,d0
	ble	okd0_1
	move.w	#16,d0
	bra	okd0_2
okd0_1	cmp.w	#-16,d0
	bge	okd0_2
	move.w	#-16,d0
okd0_2	cmp.w	#16,d1
	ble	okd1_1
	move.w	#16,d1
	bra	okd1_2
okd1_1	cmp.w	#-16,d1
	bge	okd1_2
	move.w	#-16,d1
okd1_2	move.w	d0,4(a0)
	move.w	d1,6(a0)
	move.w	(sp)+,d1
	move.w	(sp)+,d0
ordinry	sub.w	xline,d0
	sub.w	pixline,d1
	move.w	d0,d4
	move.w	d1,d5
	addq.w	#1,d5
	addq.w	#7,d4
	cmp.w	#0,d4
	blt	boffscr
	cmp.w	#318,d4
	bgt	boffscr
	cmp.w	#0,d5
	blt	boffscr
	cmp.w	#190,d5
	bgt	boffscr
	bsr	point4
	cmp.w	#0,d4
	bne	bmbhits
	moveq.w	#3,d3
	move.w	#37,d2
	lea	sprites,a5
	bsr	sprite
hitout	move.w	(sp)+,d7
nextbmb	lea	12(a0),a0
	dbra.w	d7,bmblp
	rts
bmbhits	move.w	(a0),d0
	move.w	2(a0),d1
	lsr.w	#3,d0
	lsr.w	#3,d1
	moveq	#1,d2
	sub.w	#14,d1
	subq.w	#8,d0
	bsr	makexpl
	move.w	(a0),d0
	move.w	2(a0),d1
	addq.w	#8,d1
	add.w	#7*8,d0
	move.w	#9,d6
	bsr	makeprt
	cmp.b	#0,11(a0)
	bne	destbad
losebmb	move.w	#0,(a0)
	bra	hitout
destbad	move.w	(a0),d0
	move.w	2(a0),d1
	lsr.w	#3,d0
	lsr.w	#3,d1
	addq.w	#1,d1
	addq.w	#7,d0
	move.w	d1,d3
	move.w	d0,d2
	add.w	#15,d2
	add.w	#15,d3
	sub.w	#15,d0
	sub.w	#15,d1
	lea	sbads,a1
	move.w	#99,d4
chbadlp	cmp.w	6(a1),d0
	bgt	nxbhbad
	cmp.w	10(a1),d1
	bgt	nxbhbad
	cmp.w	4(a1),d2
	blt	nxbhbad
	cmp.w	8(a1),d3
	blt	nxbhbad
	cmp.w	#16,20(a1)
	beq	nxbhbad
	cmp.w	#8,20(a1)
	bne	hurtb2
	move.w	16(a1),d1
	sub.w	12(a1),d1
	cmp.w	#20*2,d1
	blt	nxbhbad
hurtb2	sub.b	#bombpower,29(a1)
	bcc	nxbhbad
	movem.l	d0-d4/d7/a1,-(sp)
	move.w	d4,d7
	bsr	killbad
	movem.l	(sp)+,d0-d4/d7/a1
	bra	notinc1
nxbhbad	lea	32(a1),a1
notinc1	dbra.w	d4,chbadlp
	bra	losebmb
boffscr	add.w	xline,d0
	add.w	pixline,d1
	addq.w	#1,d1
	addq.w	#7,d0
	movem.w	d0-d7,-(sp)
	move.w	#99,d7
	lea	sbads,a1
bosbad?	cmp.w	#0,(a1)
	beq	bhbdout
	cmp.b	#0,28(a1)
	beq	bnxhobd
	cmp.w	4(a1),d0
	blt	bnxhobd
	cmp.w	6(a1),d0
	bgt	bnxhobd
	cmp.w	8(a1),d1
	blt	bnxhobd
	cmp.w	10(a1),d1
	ble	bhtwoff
bnxhobd	lea	32(a1),a1
	dbra.w	d7,bosbad?
bhbdout	lea	expldat,a1
	move.w	#maxexpl-1,d7
bchkxpl	cmp.w	#0,2(a1)
	beq	bnxbxpl
	move.w	(sp),d0
	move.w	2(sp),d1
	cmp.b	#0,7(a1)
	bne	bbxpl32
	subq.w	#1,d0
	subq.w	#1,d1
	cmp.w	(a1),d0
	blt	bnxbxpl
	cmp.w	2(a1),d1
	blt	bnxbxpl
	sub.w	#12,d0
	sub.w	#12,d1
	cmp.w	(a1),d0
	blt	bnxbxpl
	cmp.w	2(a1),d1
	blt	bnxbxpl
	bra	bhtwoff
bbxpl32	subq.w	#4,d0
	subq.w	#4,d1
	cmp.w	(a1),d0
	blt	bnxbxpl
	cmp.w	2(a1),d1
	blt	bnxbxpl
	sub.w	#23,d0
	sub.w	#23,d1
	cmp.w	(a1),d0
	blt	bnxbxpl
	cmp.w	2(a1),d1
	bge	bhtwoff
bnxbxpl	addq.l	#8,a1
	dbra.w	d7,bchkxpl
	move.w	(sp),d0
	move.w	2(sp),d1
	lsr.w	#3,d0
	lsr.w	#3,d1
	add.w	#12,d0
	mulu.w	levdat,d1
	add.w	d0,d1
	lea	levdat,a1
	moveq	#0,d6
	move.b	(a1,d1.w),d6
	lea	coldat,a1
	cmp.b	#0,(a1,d6.w)
	bne	bhtwoff
	movem.w	(sp)+,d0-d7
	bra	hitout
bhtwoff	movem.w	(sp)+,d0-d7
	bra	bmbhits

*******static bad guys********************

dosbads	lea	sbads,a0
	lea	sbadtab,a1
	move.w	#99,d0
	move.w	minx,d7
	sub.w	#160,d7
	move.w	d7,mminx
	add.w	#640,d7
	move.w	d7,mmaxx
	move.w	miny,d7
	sub.w	#100,d7
	move.w	d7,mminy
	add.w	#400,d7
	move.w	d7,mmaxy
sbadlp	cmp.w	#0,(a0)
	beq	badout
	movem.w	mminx,d1-d4
	cmp.w	2(a0),d3
	bgt	notonbd
	cmp.w	2(a0),d4
	blt	badout
	cmp.w	(a0),d1
	bgt	notonbd
	cmp.w	(a0),d2
	blt	notonbd
	move.b	#1,28(a0)
	move.w	20(a0),d1
	movea.l	(a1,d1.w),a2
	jmp	(a2)
ret16	move.w	d0,-(sp)
	move.w	(a0),d0
	moveq	#0,d1
	move.w	2(a0),d1
	sub.w	minx,d0
	sub.w	miny,d1
	cmp.w	#-15,d0
	blt	nxtbad
	cmp.w	#-15,d1
	blt	nxtbad
	cmp.w	#319,d0
	bgt	nxtbad
	cmp.w	#191,d1
	bgt	nxtbad
	
	btst	#0,23(a0)
	beq	norot16
*check for rotate but nomask
	move.w	16(a0),d2
	lsl.w	#3,d2
	lea	badspr,a5
	lea	(a5,d2.w),a5
	moveq	#0,d3
	move.b	22(a0),d3
	bsr	sprite2
nxtbad	move.w	(sp)+,d0
nextbad	lea	32(a0),a0
	dbra.w	d0,sbadlp
badout	rts
ret32	bra	nextbad
notonbd	move.b	#0,28(a0)
	bra	nextbad
norot16	move.w	16(a0),d2
	lsl.w	#3,d2
	lea	badspr,a5
	lea	(a5,d2.w),a5
	moveq	#0,d5
	move.b	22(a0),d5
	movea.l	back,a6
	move.w	d1,d7
	lsr.w	#1,d0
	cmp.w	#0,d1
	ble	notonrt
	move.w	d1,d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	d4,d1
	lsl.w	#5,d1
notonrj	add.w	d0,d1
	lea	(a6,d1.w),a6
	btst	#1,23(a0)
	bne	nrnm16
norotrw	cmp.w	#0,d7
	blt	notonnr
	cmp.w	#191,d7
	bgt	nxtbad
	movem.w	(a5)+,d0-d4
	movem.w	d1-d4,(a6)
	lea	160(a6),a6
nextrow	addq.w	#1,d7
	dbra.w	d5,norotrw
	bra	nxtbad
nrnm16	cmp.w	#0,d7
	blt	nonnrnm
	cmp.w	#191,d7
	bgt	nxtbad
	movem.w	(a5)+,d0-d4
	and.w	d0,(a6)
	and.w	d0,2(a6)
	and.w	d0,4(a6)
	and.w	d0,6(a6)
	or.w	d1,(a6)
	or.w	d2,2(a6)
	or.w	d3,4(a6)
	or.w	d4,6(a6)
	lea	160(a6),a6
nxnrnm	addq.w	#1,d7
	dbra.w	d5,nrnm16
	bra	nxtbad
nonnrnm	lea	10(a5),a5
	bra	nxnrnm
notonrt	moveq.w	#0,d1
	bra	notonrj
notonnr	lea	10(a5),a5
	bra	nextrow
booster	bra	ret16
fuel	bsr	animsbd
	bra	ret16
animsbd	cmp.w	#0,18(a0)
	beq	animlv
	add.w	#20,16(a0)
	sub.w	#1,18(a0)
	bne	animout
	move.l	12(a0),16(a0)
animout	lea	sbd16,a2
	move.w	16(a0),d1
	move.l	(a2,d1.w),4(a0)
	move.l	4(a2,d1.w),8(a0)
	move.w	(a0),d2
	move.w	2(a0),d3
	add.w	d2,4(a0)
	add.w	d2,6(a0)
	add.w	d3,8(a0)
	add.w	d3,10(a0)
	move.b	18(a2,d1.w),25(a0)
	move.b	19(a2,d1.w),22(a0)
animlv	rts
door	cmp.b	#2,30(a0)
	blt	countin
	beq	opening
	cmp.w	#51*20,16(a0)
	beq	close1
closerj	sub.w	#20,16(a0)
	bsr	animout
	move.w	16(a0),d1
	cmp.w	12(a0),d1
	bne	doorlv
	move.b	27(a0),31(a0)
	move.b	#0,30(a0)
doorlv	bra	ret16
close1	move.w	12(a0),d1
	add.w	#8*20,d1
	move.w	d1,16(a0)
	bra	closerj
opening	add.w	#20,16(a0)
	move.w	12(a0),d1
	add.w	#20*8,d1
	cmp.w	16(a0),d1
	bne	notfop
	move.w	#51*20,16(a0)
	move.b	26(a0),31(a0)
	move.b	#1,30(a0)
notfop	bsr	animout
	bra	ret16
countin	sub.b	#1,31(a0)
	bcc	ret16
	add.b	#2,30(a0)
	bra	ret16
gravbas	cmp.w	#0,dead
	bne	ret16
	cmp.b	#2,wep2act
	beq	ret16
	move.w	d1,d6
	bsr	getdist
	moveq	#0,d4
	move.b	26(a0),d4
	lea	disttab,a2
	move.l	(a2,d4.w),d4
	move.w	d4,d5
	mulu.w	d5,d5
	cmp.l	d5,d3
	bgt	ret16
	move.b	27(a0),d5
	add.b	d5,24(a0)
	cmp.b	#gbas_mspeed,24(a0)
	blt	grvbout	
	sub.b	#gbas_mspeed,24(a0)
	muls.w	d4,d1
	muls.w	d4,d2
	divs.w	d3,d1
	divs.w	d3,d2
	cmp.w	#20,d6
	beq	repulse
	add.w	d1,youxs
	add.w	d2,youys
	bra	grvbout
repulse	sub.w	d1,youxs
	sub.w	d2,youys
grvbout	bsr	animsbd
	bra	ret16
contbas	cmp.w	#0,dead
	bne	ret16
	cmp.b	#2,wep2act
	beq	ret16
	bsr	getdist
	moveq	#0,d4
	move.b	26(a0),d4
	lea	disttab,a2
	move.l	(a2,d4.w),d4
	mulu.w	d4,d4
	cmp.l	d4,d3
	bgt	ret16
	bsr	animsbd
	move.b	#3,control
	bra	ret16
ffgen	bsr	animsbd
	bra	ret16
getdist	move.w	(a0),d1
	addq.w	#8,d1
	moveq	#1,d2
	add.b	22(a0),d2
	lsr.w	#1,d2
	add.w	2(a0),d2
	move.w	yourx,d3
	move.w	youry,d4
	addq.w	#7,d3
	addq.w	#7,d4
	add.w	pixline,d4
	add.w	xline,d3
	sub.w	d3,d1
	sub.w	d4,d2
	move.w	d1,d3
	move.w	d2,d4
	muls.w	d3,d3
	muls.w	d4,d4
	add.l	d4,d3
	rts
getdir	cmp.b	#2,wep2act
	beq	getfail
	move.w	(a0),d1
	addq.w	#8,d1
	moveq	#1,d4
	add.b	22(a0),d4
	lsr.w	#1,d4
	add.w	2(a0),d4
	move.w	yourx,d3
	moveq	#0,d2
	move.w	youry,d2
	addq.w	#7,d3
	addq.w	#7,d2
	add.w	pixline,d2
	add.w	xline,d3
	sub.w	d3,d1
	lsl.l	#5,d2
	lsl.l	#5,d4
	sub.l	d4,d2
	cmp.w	#0,d1
	beq	xiszero
	divs.w	d1,d2		* (32*y)/x
	lea	gdirtab,a2
	moveq	#0,d3
gdirlp	cmp.w	(a2)+,d2
	bgt	gotdir
	addq.w	#1,d3
	cmp.w	#8,d3
	bne	gdirlp
gotdir	cmp.w	#0,d1
	blt	dirout
	addq.w	#8,d3
	cmp.w	#16,d3
	bne	dirout
	moveq	#0,d3
dirout	rts
getfail	move.w	#$ff,d3
	rts
gdirtab	dc.w	161,48,21,6,-6,-21,-48,-161
xiszero	moveq.w	#0,d3
	cmp.w	#0,d2
	bgt	dirout
	moveq.w	#8,d3
	rts
sphere	cmp.w	#1,30(a0)
	beq	sphopen
	bgt	sphcloz
	cmp.w	#0,dead
	bne	ret16
	bsr	random
	moveq	#0,d1
	move.b	24(a0),d1
	and.w	#$ff,d7
	cmp.w	d1,d7
	bgt	ret16
	move.w	#1,30(a0)
	bra	ret16
sphopen	btst	#0,turn+1
	bne	ret16
	add.w	#20,16(a0)
	bsr	animout
	move.w	12(a0),d1
	add.w	#20*6,d1
	cmp.w	16(a0),d1
	bne	ret16
	move.w	#2,30(a0)
	lea	bombdat+12,a2
	moveq	#maxbmbs-2,d7
sphblp	cmp.w	#0,(a2)
	bne	nxtsbmb
	move.w	d0,-(sp)
	move.w	(a0),d0
	move.w	2(a0),d1
	lea	sbd16,a3
	move.w	16(a0),d7
	add.w	8(a3,d7.w),d0
	add.w	10(a3,d7.w),d1
	lsl.w	#3,d0
	lsl.w	#3,d1
	lea	dirtab,a3
	moveq	#0,d7
	move.b	25(a0),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	(a3,d7.w),d2
	move.w	2(a3,d7.w),d3
	sub.w	#7*8,d0
	sub.w	#8,d1
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	#300,(a2)+
	move.w	#$100,(a2)+
	bset	#3,newsam
	move.w	(sp)+,d0
	bra	ret16
nxtsbmb	lea	12(a2),a2
	dbra.w	d7,sphblp
	bra	ret16
sphcloz	btst	#0,turn+1
	bne	ret16
	sub.w	#20,16(a0)
	bsr	animout
	move.w	12(a0),d1
	cmp.w	16(a0),d1
	bne	ret16
	move.w	#0,30(a0)
	bra	ret16
pyram	cmp.w	#0,dead
	bne	ret16
	bsr	sbdfire
	bra	ret16
aimy	cmp.w	#0,dead
	bne	ret16
	cmp.b	#3,26(a0)
	blt	doaimy
	bsr	getdir
	cmp.w	#255,d3
	beq	noaimy
	cmp.w	#111*20,12(a0)
	beq	aimy1
	blt	aimy0
	cmp.w	#132*20,12(a0)
	beq	aimy3
	blt	aimy2
	bra	ret16	* This can't be an aimy one?!?
aimy1	cmp.w	#10,d3
	blt	noaimy
	cmp.w	#14,d3
	bgt	noaimy
	add.w	#99,d3
	bra	calcd3
aimy2	cmp.w	#9,d3
	blt	noaimy
	add.w	#113,d3
	bra	calcd3
aimy3	cmp.w	#0,d3
	beq	noaimy
	cmp.w	#7,d3
	bgt	noaimy
	add.w	#128,d3
	bra	calcd3
aimy0	addq.w	#3,d3
	cmp.w	#6,d3
	ble	yaimy
	cmp.w	#18,d3
	bgt	noaimy
	cmp.w	#16,d3
	blt	noaimy
	sub.w	#16,d3
yaimy	add.w	#90,d3
calcd3	move.w	d3,d4
	add.w	d4,d4	*
	add.w	d4,d4	* d3=d3*20
	add.w	d4,d3	*
	add.w	d3,d3	*
	add.w	d3,d3	*
	move.w	d3,d4
	sub.w	16(a0),d4
	cmp.w	#-20,d4
	ble	chby1
	cmp.w	#20,d4
	ble	doch
	add.w	#20,16(a0)
	bsr	animout
	bra	ret16
chby1	sub.w	#20,16(a0)
	bsr	animout
	bra	ret16
doch	move.w	d3,16(a0)
	bsr	animout
doaimy	bsr	sbdfire
noaimy	bra	ret16
sbdfire	bsr	random
	moveq	#0,d1
	move.b	24(a0),d1
	cmp.w	#0,d1
	beq	bdnfire
	and.w	#$ff,d7
	cmp.w	d1,d7
	bgt	bdnfire
	move.b	26(a0),d7
	lsl.w	#2,d7
	lea	ftyptab,a2
	movea.l	(a2,d7.w),a2
	jmp	(a2)
dofire	move.w	d0,-(sp)
	lea	sbd16,a2
	move.w	16(a0),d7
	move.w	(a0),d0
	move.w	2(a0),d1
	add.w	8(a2,d7.w),d0
	add.w	10(a2,d7.w),d1
	lsl.w	#3,d0
	lsl.w	#3,d1
	lea	dirtab,a2
	moveq	#0,d7
	move.b	25(a0),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	(a2,d7.w),d2
	move.w	2(a2,d7.w),d3
atmjoin	cmp.b	#0,27(a0)
	bne	badfbmb
	moveq	#0,d4
	moveq	#1,d5
	move.w	#150,d6
	bset	#2,newsam
	bsr	makebul
	move.w	(sp)+,d0
bdnfire	rts
badfbmb	lea	bombdat+12,a2
	moveq	#maxbmbs-2,d7
mbmblp	cmp.w	#0,(a2)
	bne	nxtmbmb
	sub.w	#7*8,d0
	sub.w	#8,d1
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	#150,(a2)+
	move.b	27(a0),(a2)
	sub.b	#1,(a2)+
	move.b	#0,(a2)+
	move.w	(sp)+,d0
	bset	#3,newsam
	bra	bdnfire
nxtmbmb	lea	12(a2),a2
	dbra.w	d7,nxtmbmb
	move.w	(sp)+,d0
	bra	bdnfire
ftyptab	dc.l	dofire,rwifd,rwntfd,fw90dfd
	dc.l	dofire,dofire,dofire,dofire
	dc.l	databov,datbelo,datleft,datrigt
datrigt	move.w	(a0),d2
	sub.w	yourx,d2
	sub.w	xline,d2
	cmp.w	#0,d2
	ble	okfat
	rts
datleft	move.w	(a0),d2
	sub.w	yourx,d2
	sub.w	xline,d2
	cmp.w	#0,d2
	bge	okfat
	rts
datbelo	move.w	2(a0),d2
	sub.w	youry,d2
	sub.w	pixline,d2
	cmp.w	#0,d2
	ble	okfat
	rts
databov	move.w	2(a0),d2
	sub.w	youry,d2
	sub.w	pixline,d2
	cmp.w	#0,d2
	bge	okfat
fatfail	rts
okfat	cmp.b	#2,wep2act
	beq	fatfail
	move.w	(a0),d1
	addq.w	#8,d1
	moveq	#1,d4
	add.b	22(a0),d4
	lsr.w	#1,d4
	add.w	2(a0),d4
	move.w	yourx,d3
	moveq	#0,d2
	move.w	youry,d2
	addq.w	#7,d3
	addq.w	#7,d2
	add.w	pixline,d2
	add.w	xline,d3
	sub.w	d3,d1
	lsl.l	#5,d2
	lsl.l	#5,d4
	sub.l	d4,d2
	cmp.w	#0,d1
	beq	fxzero
	divs.w	d1,d2		* (32*y)/x
	lea	tanspd,a2
	move.w	#71,d3
ftanlp	cmp.w	(a2),d2
	blt	gotfat
	addq.l	#6,a2
	dbra.w	d3,ftanlp
	subq.l	#6,a2
gotfat	move.w	2(a2),d2
	move.w	4(a2),d3
	cmp.w	#0,d1
	ble	atmbul
	not.w	d2
	not.w	d3
	addq.w	#1,d2
	addq.w	#1,d3
atmbul	move.w	d0,-(sp)
	lea	sbd16,a2
	move.w	16(a0),d7
	move.w	(a0),d0
	move.w	2(a0),d1
	add.w	8(a2,d7.w),d0
	add.w	10(a2,d7.w),d1
	lsl.w	#3,d0
	lsl.w	#3,d1
	bra	atmjoin
fxzero	cmp.w	#0,d2
	blt	bdown
	moveq	#0,d2
	move.w	#-16,d3
	bra	atmbul
bdown	moveq	#0,d2
	moveq	#16,d3
	bra	atmbul
	
fw90dfd	bra	dofire
rwntfd	bsr	getdir
	cmp.b	25(a0),d3
	beq	dofire
	move.w	d3,d4
	subq.w	#1,d3
	bcc	okd3_1
	moveq	#15,d3
okd3_1	cmp.b	25(a0),d3
	beq	dofire
	addq.w	#1,d4
	cmp.w	#16,d4
	bne	okd4_1
	moveq	#0,d4
okd4_1	cmp.b	25(a0),d4
	beq	dofire
	rts
rwifd	bsr	getdir
	cmp.b	25(a0),d3
	beq	dofire
	rts
nokbad	move.w	(sp)+,d7
	rts
killbad	move.w	d7,-(sp)
	cmp.w	#136*20,12(a1)
	beq	nokbad
	cmp.w	#144*20,12(a1)
	beq	nokbad
	cmp.w	#117*20,12(a1)
	bne	noreact
	movem.l	d0-d7/a0-a6,-(sp)
	lea	levdat,a0
	move.w	(a0),d4
	move.w	(a1),d0
	move.w	2(a1),d1
	lsr.w	#3,d0
	lsr.w	#3,d1
	subq.w	#2,d1
	subq.w	#1,d0
	move.w	d0,d2
	move.w	d1,d3
	mulu.w	d4,d1
	add.w	d1,d0
	lea	12(a0,d0.w),a0
	lea	destgrf,a2
	moveq	#4,d5
bigdlp	moveq	#3,d7
litdlp	move.w	d2,d0
	move.w	d3,d1
	move.w	(a2)+,d6
	cmp.w	#0,d6
	beq	notput
	move.b	d6,(a0)+
	move.w	d2,-(sp)
	bsr	dest2
	move.w	(sp)+,d2
notput1	addq.w	#1,d2
	dbra.w	d7,litdlp
	subq.w	#4,d2
	addq.w	#1,d3
	lea	-4(a0,d4.w),a0
	dbra.w	d5,bigdlp
	move.w	(a1),d0
	move.w	2(a1),d1
	move.w	d0,d2
	move.w	d1,d3
	add.w	#32,d2
	sub.w	#32,d0
	add.w	#64,d3
	sub.w	#64,d1
	lea	sbads-32,a1
immbadl	lea	32(a1),a1
	cmp.w	#0,(a1)
	beq	doneimm
	cmp.w	(a1),d0
	bgt	immbadl
	cmp.w	(a1),d2
	blt	immbadl
	cmp.w	2(a1),d1
	bgt	immbadl
	cmp.w	2(a1),d3
	blt	immbadl
	move.l	#0,24(a1)
	bra	immbadl
notput	addq.l	#1,a0
	bra	notput1
doneimm	
	
	movem.l	(sp)+,d0-d7/a0-a6
	bra	nboost2
destgrf	dc.w	0,212,213,0
	dc.w	208,209,210,211
	dc.w	200,204,205,202
	dc.w	201,206,207,203
	dc.w	0,214,215,0
noreact	cmp.w	#121*20,12(a1)
	bne	nboost2
	movem.l	d0/d1/d2/d6/d7/a0/a2,-(sp)
	move.w	(a1),d0
	move.w	2(a1),d1
	lea	sbads-32,a0
	sub.w	#16,d0
srch4m	lea	32(a0),a0
	cmp.w	(a0),d0
	bne	srch4m
	cmp.w	2(a0),d1
	bne	srch4m
	move.w	#117*20,12(a0)
	move.w	#4,14(a0)
	move.w	#117*20,16(a0)
	move.w	#4,18(a0)
	move.w	#56,20(a0)
	move.b	#15,22(a0)
	move.b	#4,29(a0)
	move.b	#1,d2
	subq.w	#8,d0
	subq.w	#8,d1
	bsr	makexpl
	add.w	#15,d0
	add.w	#15,d1
	moveq	#9,d6
	lsl.w	#3,d0
	lsl.w	#3,d1
	bsr	makeprt
	movem.l	(sp)+,d0/d1/d2/d6/d7/a0/a2
nboost2	lea	quotas,a5	*
	add.b	#1,(a5)		* Increase relevant
	move.w	20(a1),d0	* counters
	lsr.w	#2,d0		*
	add.b	#1,1(a5,d0.w)	*
	cmp.w	#28,20(a1)
	bne	notfrce
	move.w	(a1),d0
	move.w	2(a1),d1
	cmp.w	#68*20,12(a1)
	beq	addbit
	cmp.w	#72*20,12(a1)
	bne	noaddbt
addbit	addq.w	#8,d0
noaddbt	moveq	#1,d3
	cmp.w	#68*20,12(a1)
	ble	notchd3
	subq	#2,d3
notchd3	lsr.w	#3,d0
	lsr.w	#3,d1
	move.w	d0,d4
	move.w	d1,d6
	add.w	#12,d0
	lea	levdat,a3
	mulu.w	(a3),d6
	add.w	d6,d0
ffflp	add.w	d3,d0
	add.w	d3,d4
	cmp.b	#18,(a3,d0.w)
	bne	notfrce
	move.b	#0,(a3,d0.w)
	movem.l	d0/d1/d4/d7/a2,-(sp)
	sub.w	left,d4
	bcs	notonff
	cmp.w	#39,d4
	bgt	notonff
	sub.w	top,d1
	bcs	notonff
	cmp.w	#27,d1
	bgt	notonff
	movea.l	printto,a2
	move.w	d1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d1
	and.l	#$ffff,d1
	lsl.l	#8,d1
	move.w	d4,d0
	lsr.w	#1,d0
	lsl.w	#3,d0
	btst	#0,d4
	beq	notadd1
	addq.w	#1,d0
notadd1	and.w	#$ffff,d0
	add.l	d0,d1
	lea	(a2,d1.l),a2
	cmp.l	#scrlbuf+224*160,a2
	blt	oka2
	suba.l	#224*160,a2
oka2	moveq.l	#0,d0
	movep.l	d0,480(a2)
	movep.l	d0,640(a2)
notonff	move.l	4(sp),d1
	move.l	8(sp),d4
	move.w	d4,d0
	lsl.w	#6,d0
	lsl.w	#6,d1
	add.w	#16,d0
	bsr	mkprt
	add.w	#32,d0
	bsr	mkprt
	add.w	#32,d0
	movem.l	(sp)+,d0/d1/d4/d7/a2
	bra	ffflp
notfrce	move.w	12(a1),d4
	move.w	(a1),d0
	move.w	2(a1),d1
	moveq	#0,d3
	move.b	22(a1),d3
	lsr.w	#1,d3
	add.w	d3,d1
	addq.w	#7,d0
	lea	sbd16,a3
	movem.w	d0-d1,-(sp)
	subq.w	#7,d0
	subq.w	#7,d1
	moveq	#0,d2
	move.b	15(a3,d4.w),d2
	cmp.w	#0,d2
	beq	ex16
	subq.w	#8,d0
	subq.w	#8,d1
ex16	bsr	makexpl
	movem.w	(sp)+,d0-d1
	lsl.w	#3,d0
	lsl.w	#3,d1
	moveq	#0,d6
	move.b	16(a3,d4.w),d6
	bsr	makeprt
	moveq	#0,d0
	move.b	14(a3,d4.w),d0
	add.w	d0,score
	move.b	17(a3,d4.w),d0
	add.w	d0,creds
	move.w	(sp)+,d7
	cmp.w	#0,d7
	beq	twatit
	subq.w	#1,d7
closelp	movem.l	32(a1),d0-d6/a2
	movem.l	d0-d6/a2,(a1)
	lea	32(a1),a1
	dbra.w	d7,closelp
twatit	move.w	#0,(a1)
	rts
	
mminx	dc.w	0
mmaxx	dc.w	0
mminy	dc.w	0
mmaxy	dc.w	0
sbadtab	dc.l	pyram,fuel,sphere,gravbas
	dc.l	door,gravbas,contbas,ffgen
	dc.l	fuel,fuel,aimy,fuel
	dc.l	ret16,booster,fuel

********explosions************************

makexpl	lea	expldat,a2
	move.w	#maxexpl-1,d7
fexpl	cmp.w	#0,2(a2)
	bne	nextxpl
	move.w	d0,(a2)
	move.w	d1,2(a2)
	move.l	#0,4(a2)
	move.b	d2,7(a2)
	bset	#0,newsam
	rts
nextxpl	addq.l	#8,a2
	dbra.w	d7,fexpl
	rts
doexpl	lea	expldat,a0
	move.w	#maxexpl-1,d7
doexplp	cmp.w	#0,2(a0)
	beq	nxtexpl
	add.b	#1,6(a0)
	cmp.b	#4,6(a0)
	bne	nochfra
	move.b	#0,6(a0)
	add.w	#1,4(a0)
	cmp.w	#8,4(a0)
	bne	nochfra
	move.w	#0,2(a0)
	bra	nxtexpl
nochfra	move.w	(a0),d0
	move.w	2(a0),d1
	sub.w	minx,d0
	sub.w	miny,d1
	cmp.w	#191,d1
	bgt	nxtexpl
	cmp.w	#319,d0
	bgt	nxtexpl
	cmp.b	#0,7(a0)
	bne	explo32
	cmp.w	#-15,d0
	blt	nxtexpl
	cmp.w	#-15,d1
	blt	nxtexpl
	move.w	4(a0),d2
	lea	expl16,a5
	move.w	d7,-(sp)
	moveq.w	#15,d3
	bsr	sprite
	move.w	(sp)+,d7
nxtexpl	addq.l	#8,a0
	dbra.w	d7,doexplp
	rts
explo32	cmp.w	#-31,d0
	blt	nxtexpl
	cmp.w	#-31,d1
	blt	nxtexpl
	move.w	4(a0),d2
	lea	expl32,a5
	move.w	d7,-(sp)
	bsr	spr32
	move.w	(sp)+,d7
	bra	nxtexpl

*************bullets**********************

makebul	move.w	#maxbuls-1,d7
	lea	buldat,a2
findbul	cmp.w	#0,(a2)
	bne	nextbul
	movem.w	d0-d3,(a2)
	move.b	d4,8(a2)
	move.b	d5,9(a2)
	move.w	d6,10(a2)
	rts
nextbul	lea	12(a2),a2
	dbra.w	d7,findbul
	rts

dobuls	lea	buldat,a0
	move.w	#maxbuls-1,d0
dobullp	cmp.w	#0,(a0)
	beq	nxtbul2
	sub.w	#1,10(a0)
	beq	losebul
	move.w	(a0),d4
	move.w	2(a0),d5
	add.w	4(a0),d4
	add.w	6(a0),d5
	move.w	d4,(a0)
	move.w	d5,2(a0)
	lsr.w	#3,d4
	lsr.w	#3,d5
	cmp.w	minx,d4
	blt	offscr
	cmp.w	maxx,d4
	bgt	offscr
	cmp.w	miny,d5
	blt	offscr
	cmp.w	maxy,d5
	bgt	offscr
	sub.w	pixline,d5
	sub.w	xline,d4
	bsr	point4
	cmp.w	#0,d4
	bne	hitsmf
	move.w	#2,d6
	bsr	plotpnt
nxtbul2	lea	12(a0),a0
	dbra.w	d0,dobullp
	rts
notyrs	cmp.w	#0,dead
	bne	hbadout
	move.w	(a0),d0
	move.w	2(a0),d1
	lsr.w	#3,d0
	lsr.w	#3,d1
	move.w	yourx,d2
	move.w	youry,d3
	add.w	minx,d2
	add.w	miny,d3
	add.w	#ycolmin,d2
	add.w	#ycolmin,d3
	cmp.w	d2,d0
	blt	hbadout
	cmp.w	d3,d1
	blt	hbadout
	add.w	#ycolmax-ycolmin,d2
	add.w	#ycolmax-ycolmin,d3
	cmp.w	d2,d0
	bgt	hbadout
	cmp.w	d3,d1
	bgt	hbadout
	cmp.b	#1,wep2act
	bne	hurtyou
	bset	#1,newsam
	bra	hbadout
hurtyou	cmp.b	#0,nimpact
	beq	bulhitu
	sub.b	#1,nimpact
	bset	#1,newsam
	bra	hbadout
bulhitu	move.w	#1,dead
	bra	hbadout
hitsmf	move.w	d0,-(sp)
	cmp.b	#0,9(a0)
	bne	notyrs
	move.w	(a0),d0
	move.w	2(a0),d1
	lsr.w	#3,d0
	lsr.w	#3,d1
	move.w	#99,d7
	lea	sbads,a1
hsbad?	cmp.w	#0,(a1)
	beq	hbadout
	cmp.b	#0,28(a1)
	beq	nxthbad
	cmp.w	4(a1),d0
	blt	nxthbad
	cmp.w	6(a1),d0
	bgt	nxthbad
	cmp.w	8(a1),d1
	blt	nxthbad
	cmp.w	10(a1),d1
	ble	hitsbad
nxthbad	lea	32(a1),a1
	dbra.w	d7,hsbad?
hbadout	lea	levdat,a2
	move.w	(a0),d4
	move.w	2(a0),d5
	lsr.w	#6,d4
	lsr.w	#6,d5
	mulu.w	levdat,d5
	add.w	#12,d4
	add.w	d4,d5
	moveq	#0,d6
	move.b	(a2,d5.w),d6
	lea	coldat,a1
	cmp.b	#1,(a1,d6.w)
	bgt	hdest1
	move.w	(a0),d0
	and.w	#%111000,d0
	cmp.w	#%111000,d0
	bne	nohzcor
	add.w	#8,(a0)
	addq.w	#1,d5
	move.b	(a2,d5.w),d6
	cmp.b	#1,(a1,d6.w)
	bgt	hdest1
	move.w	2(a0),d1
	and.w	#%111000,d1
	cmp.w	#%111000,d1
	bne	desto2
	add.w	levdat,d5
	add.w	#8,2(a0)
	move.b	(a2,d5.w),d6
	cmp.b	#1,(a1,d6.w)
	bgt	hdest1
	sub.w	#8,(a0)
	subq.w	#1,d5
	move.b	(a2,d5.w),d6
	cmp.b	#1,(a1,d6.w)
	bgt	hdest1
	bra	desto2
nohzcor	move.w	2(a0),d1
	and.w	#%111000,d1
	cmp.w	#%111000,d1
	bne	desto2
	add.w	levdat,d5
	add.w	#8,2(a0)
	move.b	(a2,d5.w),d6
	cmp.b	#1,(a1,d6.w)
	bgt	hdest1
desto2	move.w	(a0),d0
	move.w	2(a0),d1
	moveq.w	#2,d6
	bsr	makeprt
	move.w	(sp)+,d0
	bra	losebul
hitsbad	cmp.w	#16,20(a1)
	beq	hbadout
	cmp.w	#8,20(a1)
	bne	hurtbad
	move.w	16(a1),d1
	sub.w	12(a1),d1
	cmp.w	#20*2,d1
	blt	hbadout
hurtbad	sub.b	#1,29(a1)
	bcc	hbadout
	bsr	killbad
	move.w	(sp)+,d0
	bra	losebul
offscr	movem.w	d0/d4-d5,-(sp)
	cmp.b	#1,9(a0)
	beq	hobdout
	move.w	#99,d7
	lea	sbads,a1
hosbad?	cmp.w	#0,(a1)
	beq	hobdout
	cmp.b	#0,28(a1)
	beq	nxthobd
	cmp.w	4(a1),d4
	blt	nxthobd
	cmp.w	6(a1),d4
	bgt	nxthobd
	cmp.w	8(a1),d5
	blt	nxthobd
	cmp.w	10(a1),d5
	ble	hitosbd
nxthobd	lea	32(a1),a1
	dbra.w	d7,hosbad?
hobdout	lea	expldat,a1
	move.w	#maxexpl-1,d7
chkexpl	cmp.w	#0,2(a1)
	beq	nxbexpl
	move.w	2(sp),d4
	move.w	4(sp),d5
	cmp.b	#0,7(a1)
	bne	bexpl32
	subq.w	#1,d4
	subq.w	#1,d5
	cmp.w	(a1),d4
	blt	nxbexpl
	cmp.w	2(a1),d5
	blt	nxbexpl
	sub.w	#12,d4
	sub.w	#12,d5
	cmp.w	(a1),d4
	blt	nxbexpl
	cmp.w	2(a1),d5
	blt	nxbexpl
	bra	hosexpl
bexpl32	subq.w	#4,d4
	subq.w	#4,d5
	cmp.w	(a1),d4
	blt	nxbexpl
	cmp.w	2(a1),d5
	blt	nxbexpl
	sub.w	#23,d4
	sub.w	#23,d5
	cmp.w	(a1),d4
	blt	nxbexpl
	cmp.w	2(a1),d5
	bge	hosexpl
nxbexpl	addq.l	#8,a1
	dbra.w	d7,chkexpl
	movem.w	(sp)+,d0/d4-d5
	lsr.w	#3,d4
	lsr.w	#3,d5
	add.w	#12,d4
	mulu.w	levdat,d5
	add.w	d4,d5
	lea	levdat,a2
	moveq	#0,d6
	move.b	(a2,d5.w),d6
	lea	coldat,a1
	cmp.b	#1,(a1,d6.w)
	blt	nxtbul2
	bne	hdest
hitwoff	move.w	d0,-(sp)
destout	move.w	(a0),d0
	move.w	2(a0),d1
	moveq.w	#2,d6
	bsr	makeprt
	move.w	(sp)+,d0
losebul	move.w	#0,(a0)
	bra	nxtbul2
hdest	move.w	d0,-(sp)
hdest1	cmp.b	#2,(a1,d6.w)
	beq	killblk
			* sound effect?
	addq.w	#1,d6
	move.b	d6,(a2,d5.w)
	bsr	destblk
	bra	destout	
killblk	moveq	#0,d6
	move.b	d6,(a2,d5.w)
	bsr	destblk
	bset	#7,newsam
	move.w	(a0),d0
	move.w	2(a0),d1
	and.w	#65535-15,d0
	and.w	#65535-15,d1
	bsr	mkprt
	addq.w	#3,d0
	bsr	mkprt
	addq.w	#3,d0
	bsr	mkprt
	subq.w	#6,d0
	addq.w	#3,d1
	bsr	mkprt
	addq.w	#3,d0
	bsr	mkprt
	addq.w	#3,d0
	bsr	mkprt
	subq.w	#6,d0
	addq.w	#3,d1
	bsr	mkprt
	addq.w	#3,d0
	bsr	mkprt
	addq.w	#3,d0
	bsr	mkprt
	bra	destout
destblk	move.w	(a0),d0
	move.w	2(a0),d1
	lsr.w	#6,d0
	lsr.w	#6,d1
dest2	cmp.w	left,d0
	blt	notdest
	cmp.w	top,d1
	blt	notdest
	sub.w	left,d0
	cmp.w	#39,d0
	bgt	notdest
	sub.w	top,d1
	cmp.w	#27,d1
	bgt	notdest
	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d1
	and.l	#$ffff,d1
	lsl.l	#8,d1
	btst	#0,d0
	beq	oknoadd
	addq.l	#1,d1
oknoadd	andi.l	#254,d0
	lsl.w	#2,d0
	add.l	d0,d1
	lsl.w	#5,d6
	movea.l	printto,a3
	lea	(a3,d1.l),a3
	cmp.l	#scrlbuf+224*160,a3
	blt	oka3
	suba.l	#224*160,a3
oka3	lea	blocks,a4
	lea	(a4,d6.w),a4
	moveq	#7,d0
destlp	move.l	(a4)+,d1
	movep.l	d1,(a3)
	lea	160(a3),a3
	dbra.w	d0,destlp
notdest	rts
hitosbd	cmp.b	#1,9(a0)
	beq	hosexpl
	cmp.w	#16,20(a1)
	beq	hitwof2
	cmp.w	#8,20(a1)
	bne	hurtb1
	move.w	16(a1),d1
	sub.w	12(a1),d1
	cmp.w	#20*2,d1
	blt	hitwof2
hurtb1	sub.b	#1,29(a1)
	bcc	hitwof2
	bsr	killbad
hosexpl	movem.w	(sp)+,d0/d4-d5
	bra	losebul
hitwof2	move.w	(a0),d0
	move.w	2(a0),d1
	moveq.w	#2,d6
	bsr	makeprt
	movem.w	(sp)+,d0/d4-d5
	bra	losebul
	
*******explosion particles****************

makeprt	bsr	mkprt
	cmp.w	#0,d7
	beq	makeout
	dbra.w	d6,makeprt
makeout	rts
mkprt	move.w	#maxprts-1,d7
	lea	partdat,a2
mkprtlp	cmp.w	#0,(a2)
	bne	nextprt
	move.w	d0,(a2)
	move.w	d1,2(a2)
	bsr	random
	and.w	#31,d7
	sub.w	#15,d7
	move.w	d7,4(a2)
	bsr	random
	and.w	#31,d7
	sub.w	#16,d7
	move.w	d7,6(a2)
	bsr	random
	and.w	#15,d7
	add.w	#42,d7
	move.w	d7,8(a2)
	rts
nextprt	lea	10(a2),a2
	dbra.w	d7,mkprtlp
	moveq	#0,d7
	rts
doparts	lea	partdat,a0
	move.w	#maxprts-1,d0
doprtlp	cmp.w	#0,(a0)
	beq	nxtprt2
	sub.w	#1,8(a0)
	beq	loseprt
	move.w	(a0),d4
	move.w	2(a0),d5
	add.w	4(a0),d4
	add.w	6(a0),d5
	move.w	d4,(a0)
	move.w	d5,2(a0)
	lsr.w	#3,d4
	lsr.w	#3,d5
	cmp.w	minx,d4
	blt	nxtprt2
	cmp.w	maxx,d4
	bgt	nxtprt2
	cmp.w	miny,d5
	blt	nxtprt2
	cmp.w	maxy,d5
	bgt	nxtprt2
	sub.w	pixline,d5
	sub.w	xline,d4
	move.w	#13,d6
	cmp.w	#40,8(a0)
	bgt	okplot
	move.w	#15,d6
	cmp.w	#20,8(a0)
	bgt	okplot
	move.w	#14,d6
okplot	bsr	plot4
nxtprt2	lea	10(a0),a0
	dbra.w	d0,doprtlp
	rts
loseprt	move.w	#0,(a0)
	bra	nxtprt2

random	move.w	seed,d7
	add.w	lastloc,d7
	add.w	lastrot,d7
	add.w	$ff8208,d7
	ror.w	#3,d7
	move.w	d7,seed
	rts
seed	dc.w	13579
	
********scrollbuffer stuff****************

prinrow	lea	blocks,a2
	moveq	#1,d7
prinlp1	move.l	a0,-(sp)
	move.w	#19,d6
prinlp2	moveq	#0,d0
	move.b	(a0)+,d0
	lsl.w	#5,d0
	movem.l	(a2,d0.w),d1-d4
	movep.l	d1,(a1)
	movep.l	d2,160(a1)
	movep.l	d3,320(a1)
	movep.l	d4,480(a1)
	movem.l	16(a2,d0.w),d1-d4
	movep.l	d1,640(a1)
	movep.l	d2,800(a1)
	movep.l	d3,960(a1)
	movep.l	d4,1120(a1)
	moveq	#0,d0
	move.b	(a0)+,d0
	lsl.w	#5,d0
	movem.l	(a2,d0.w),d1-d4
	movep.l	d1,1(a1)
	movep.l	d2,161(a1)
	movep.l	d3,321(a1)
	movep.l	d4,481(a1)
	movem.l	16(a2,d0.w),d1-d4
	movep.l	d1,641(a1)
	movep.l	d2,801(a1)
	movep.l	d3,961(a1)
	movep.l	d4,1121(a1)
	addq.l	#8,a1
	dbra.w	d6,prinlp2
	lea	7*160(a1),a1
	movea.l	(sp)+,a0
	moveq	#0,d0
	move.w	levdat,d0
	lea	(a0,d0.w),a0
	dbra.w	d7,prinlp1
	rts
scrlup	cmp.w	#16,norots
	bne	nochck1
	cmp.w	#0,top
	beq	scrlret
nochck1	sub.w	#1,pixline
	sub.w	#1,maxy
	sub.w	#1,miny
	add.w	#1,youry
	add.w	#32,youy
	lea	scrlbuf,a0
	sub.l	#160,copfrom
	cmp.l	copfrom,a0
	ble	norscf
	add.l	#160*16*14,copfrom
norscf	sub.w	#1,norots
	bne	another
	sub.w	#2,top
	sub.l	#160*16,printto
	cmp.l	printto,a0
	ble	norspt
	add.l	#160*16*14,printto
norspt	movea.l	printto,a1
	moveq	#0,d6
	move.w	topldis,d6
	sub.w	levdat,d6
	sub.w	levdat,d6
	move.w	d6,topldis
	lea	levdat,a0
	lea	(a0,d6.w),a0
	bsr	prinrow
	move.w	#16,norots
another	cmp.w	#scrluppt,youry
	ble	scrlup
	bra	scrlret
scrldwn	cmp.w	#16,norots
	bne	nochck2
	move.w	maxtop,d7
	cmp.w	top,d7
	beq	scrlret
nochck2	add.w	#1,pixline
	add.w	#1,maxy
	add.w	#1,miny
	sub.w	#32,youy
	sub.w	#1,youry
	lea	scrlbuf+160*16*14,a0
	add.l	#160,copfrom
	cmp.l	copfrom,a0
	bgt	norscf2
	sub.l	#160*16*14,copfrom
norscf2	add.w	#1,norots
	cmp.w	#32,norots
	bne	nother
	add.w	#2,top
	add.l	#160*16,printto
	cmp.l	printto,a0
	bgt	norspt2
	sub.l	#160*16*14,printto
norspt2	movea.l	printto,a1
	adda.l	#160*16*13,a1
	cmp.l	a1,a0
	bgt	norspt3
	suba.l	#160*16*14,a1
norspt3	moveq	#0,d6
	move.w	topldis,d6
	add.w	levdat,d6
	add.w	levdat,d6
	move.w	d6,topldis
	add.w	botldis,d6
	lea	levdat,a0
	lea	(a0,d6.w),a0
	bsr	prinrow
	move.w	#16,norots
nother	cmp.w	#scrldnpt,youry
	bgt	scrldwn
	bra	scrlret
scrlr	move.w	left,d1
	cmp.w	maxlft,d1
	bne	dor
	move.w	#0,scrrght
	bra	hzscrlr
dor	sub.w	#1,scrrght
	move.w	#16,d0
	sub.w	#16*32,youx
	sub.w	d0,yourx
	add.w	d0,xline
	add.w	d0,minx
	add.w	d0,maxx
	add.w	#2,left
	add.w	#2,topldis
	lea	scrlbuf,a0
	move.w	#(14*16)-1,d7
rlp1	movem.l	8(a0),d0-d6/a1-a6
	movem.l	d0-d6/a1-a6,(a0)
	movem.l	60(a0),d0-d6/a1-a6
	movem.l	d0-d6/a1-a6,52(a0)
	movem.l	112(a0),d0-d6/a1-a5
	movem.l	d0-d6/a1-a5,104(a0)
	lea	160(a0),a0
	dbra.w	d7,rlp1
	move.w	topldis,d0
	add.w	#38,d0
	lea	levdat,a0
	lea	(a0,d0.w),a0
	movea.l	printto,a1
	lea	19*8(a1),a1
	bsr	princol
	bra	hzscrlr
scrll	move.w	left,d1
	cmp.w	#0,d1
	bne	dol
	move.w	#0,scrlft
	bra	hzscrlr
dol	sub.w	#1,scrlft
	add.w	#16*32,youx
	move.w	#16,d0
	add.w	d0,yourx
	sub.w	d0,xline
	sub.w	d0,minx
	sub.w	d0,maxx
	sub.w	#2,left
	sub.w	#2,topldis
	lea	scrlbuf,a0
	move.w	#(14*16)-1,d7
llp1	movem.l	104(a0),d0-d6/a1-a5
	movem.l	d0-d6/a1-a5,112(a0)
	movem.l	52(a0),d0-d6/a1-a6
	movem.l	d0-d6/a1-a6,60(a0)
	movem.l	(a0),d0-d6/a1-a6
	movem.l	d0-d6/a1-a6,8(a0)
	lea	160(a0),a0
	dbra.w	d7,llp1
	move.w	topldis,d0
	lea	levdat,a0
	lea	(a0,d0.w),a0
	movea.l	printto,a1
	bsr	princol
	bra	hzscrlr
copbuf	movea.l	copfrom,a0
	movea.l	back,a1
	lea	scrlbuf+160*16*14,a2
	move.w	#192-1,d0
coplp1	movem.l	(a0)+,d1-d7/a3-a6
	movem.l	d1-d7/a3-a6,(a1)
	movem.l	(a0)+,d1-d7/a3-a6
	movem.l	d1-d7/a3-a6,44(a1)
	movem.l	(a0)+,d1-d7/a3-a6
	movem.l	d1-d7/a3-a6,88(a1)
	movem.l	(a0)+,d1-d7
	movem.l	d1-d7,132(a1)
	lea	160(a1),a1
	cmp.l	a0,a2
	bne	carryon
	lea	scrlbuf,a0
carryon	dbra.w	d0,coplp1
	rts
princol	lea	blocks,a2
	move.w	#27,d6
prnclp	moveq	#0,d0
	move.b	(a0),d0
	lsl.w	#5,d0
	movem.l	(a2,d0.w),d1-d4
	movep.l	d1,(a1)
	movep.l	d2,160(a1)
	movep.l	d3,320(a1)
	movep.l	d4,480(a1)
	movem.l	16(a2,d0.w),d1-d4
	movep.l	d1,640(a1)
	movep.l	d2,800(a1)
	movep.l	d3,960(a1)
	movep.l	d4,1120(a1)
	moveq	#0,d0
	move.b	1(a0),d0
	lsl.w	#5,d0
	movem.l	(a2,d0.w),d1-d4
	movep.l	d1,1(a1)
	movep.l	d2,161(a1)
	movep.l	d3,321(a1)
	movep.l	d4,481(a1)
	movem.l	16(a2,d0.w),d1-d4
	movep.l	d1,641(a1)
	movep.l	d2,801(a1)
	movep.l	d3,961(a1)
	movep.l	d4,1121(a1)
	move.w	levdat,d0
	lea	(a0,d0.w),a0
	lea	8*160(a1),a1
	cmp.l	#scrlbuf+160*16*14,a1
	blt	noresa1
	suba.l	#160*16*14,a1
noresa1	dbra.w	d6,prnclp
	rts

*******panel stuff*******************

putpanl	movea.l	back,a5
	adda.l	#193*160,a5
	lea	panel,a6
	move.w	#6-1,d0
panlp1	movem.l	(a6)+,d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,(a5)
	movem.l	(a6)+,d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,48(a5)
	movem.l	(a6)+,d1-d7/a0-a4
	movem.l	d1-d7/a0-a4,96(a5)
	movem.l	(a6)+,d1-d4
	movem.l	d1-d4,144(a5)
	lea	160(a5),a5
	dbra.w	d0,panlp1
	
	bsr	coppanl
	rts
coppanl	movea.l	back,a6
	movea.l	back2,a5
	movea.l	physic,a4
	adda.l	#193*160,a4
	adda.l	#193*160,a5
	adda.l	#193*160,a6
	move.w	#6-1,d0
panlp2	movem.l	(a6)+,d1-d7/a0-a3
	movem.l	d1-d7/a0-a3,(a5)
	movem.l	d1-d7/a0-a3,(a4)
	movem.l	(a6)+,d1-d7/a0-a3
	movem.l	d1-d7/a0-a3,44(a5)
	movem.l	d1-d7/a0-a3,44(a4)
	movem.l	(a6)+,d1-d7/a0-a3
	movem.l	d1-d7/a0-a3,88(a5)
	movem.l	d1-d7/a0-a3,88(a4)
	movem.l	(a6)+,d1-d7
	movem.l	d1-d7,132(a5)
	movem.l	d1-d7,132(a4)
	lea	160(a5),a5
	adda.l	160(a4),a4
	dbra.w	d0,panlp2
	rts

*** plots, points etc. **************

point	move.w	d1,d7
	add.w	d7,d7
	add.w	d7,d7
	add.w	d7,d1
	lsl.w	#5,d1		*160
	move.w	d0,d7
	lsr.w	#4,d7
	lsl.w	#3,d7
	add.w	d7,d1
	lsl.w	#1,d7
	sub.w	d7,d0
	and.l	#$ffff,d1
	movea.l	back,a5
	lea	(a5,d1.w),a5
	move.w	#32768,d7
	lsr.w	d0,d7
	move.w	(a5)+,d0
	or.w	(a5)+,d0
	or.w	(a5)+,d0
	or.w	(a5),d0
	and.w	d7,d0
	rts
plot4	move.w	d5,d3
	add.w	d3,d3
	add.w	d3,d3
	add.w	d3,d5
	lsl.w	#5,d5		*160
	move.w	d4,d7
	lsr.w	#4,d7
	lsl.w	#3,d7
	add.w	d7,d5
	lsl.w	#1,d7
	sub.w	d7,d4
	and.l	#$ffff,d5
	movea.l	back,a5
	lea	(a5,d5.w),a5
	bra	notpnt
plotpnt	movea.l	lastloc,a5
	move.w	lastrot,d4
notpnt	move.w	#49152,d7
	cmp.w	#15,d4
	beq	over
	lsr.w	d4,d7
	move.w	d7,d4
	not.w	d4
	btst	#0,d6
	bne	or4it
	and.w	d4,(a5)+
	and.w	d4,158(a5)
	bra	bit41
or4it	or.w	d7,(a5)+
	or.w	d7,158(a5)
bit41	btst	#1,d6
	bne	orit42
	and.w	d4,(a5)+
	and.w	d4,158(a5)
	bra	bit42
orit42	or.w	d7,(a5)+
	or.w	d7,158(a5)
bit42	btst	#2,d6
	bne	orit43
	and.w	d4,(a5)+
	and.w	d4,158(a5)
	bra	bit43
orit43	or.w	d7,(a5)+
	or.w	d7,158(a5)
bit43	btst	#3,d6
	bne	orit44
	and.w	d4,(a5)+
	and.w	d4,158(a5)
	rts
orit44	or.w	d7,(a5)+
	or.w	d7,158(a5)
	rts
over	move.w	#1,d7
	move.w	#65534,d4
	move.w	#32768,d2
	move.w	#32767,d1
	btst	#0,d6
	bne	vor4it
	and.w	d4,(a5)+
	and.w	d1,6(a5)
	and.w	d1,166(a5)
	and.w	d4,158(a5)
	bra	vbit41
vor4it	or.w	d7,(a5)+
	or.w	d2,6(a5)
	or.w	d2,166(a5)
	or.w	d7,158(a5)
vbit41	btst	#1,d6
	bne	vorit42
	and.w	d4,(a5)+
	and.w	d1,6(a5)
	and.w	d1,166(a5)
	and.w	d4,158(a5)
	bra	vbit42
vorit42	or.w	d7,(a5)+
	or.w	d2,6(a5)
	or.w	d2,166(a5)
	or.w	d7,158(a5)
vbit42	btst	#2,d6
	bne	vorit43
	and.w	d4,(a5)+
	and.w	d1,6(a5)
	and.w	d1,166(a5)
	and.w	d4,158(a5)
	bra	vbit43
vorit43	or.w	d7,(a5)+
	or.w	d2,6(a5)
	or.w	d2,166(a5)
	or.w	d7,158(a5)
vbit43	btst	#3,d6
	bne	vorit44
	and.w	d4,(a5)+
	and.w	d1,6(a5)
	and.w	d1,166(a5)
	and.w	d4,158(a5)
	rts
vorit44	or.w	d7,(a5)+
	or.w	d2,6(a5)
	or.w	d2,166(a5)
	or.w	d7,158(a5)
	rts
point4	move.w	d5,d6
	add.w	d6,d6
	add.w	d6,d6
	add.w	d6,d5
	lsl.w	#5,d5		*160
	move.w	d4,d7
	lsr.w	#4,d7
	lsl.w	#3,d7
	add.w	d7,d5
	lsl.w	#1,d7
	sub.w	d7,d4
	and.l	#$ffff,d5
	movea.l	back,a5
	lea	(a5,d5.w),a5
	move.l	a5,lastloc
	move.w	d4,lastrot
	move.w	#49152,d7
	lsr.w	d4,d7
	cmp.w	#15,d4
	beq	splitpt
	move.w	(a5),d4
	or.w	2(a5),d4
	or.w	4(a5),d4
	or.w	6(a5),d4
	or.w	160(a5),d4
	or.w	162(a5),d4
	or.w	164(a5),d4
	or.w	166(a5),d4
	and.w	d7,d4
	rts
splitpt	move.w	(a5),d4
	or.w	2(a5),d4
	or.w	4(a5),d4
	or.w	6(a5),d4
	or.w	160(a5),d4
	or.w	162(a5),d4
	or.w	164(a5),d4
	or.w	166(a5),d4
	move.w	8(a5),d5
	or.w	10(a5),d5
	or.w	12(a5),d5
	or.w	14(a5),d5
	or.w	168(a5),d5
	or.w	170(a5),d5
	or.w	172(a5),d5
	or.w	174(a5),d5
	and.w	#1,d4
	and.w	#32768,d5
	or.w	d5,d4
	rts
lastloc	dc.l	0
lastrot	dc.w	0

*******************************

fingame	move.w	#0,restrt		* finish game effect
	bsr	slowcls
	bsr	swap
	bsr	slowcls
	bsr	swap
	bsr	slowcls
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240
	lea	fys,a0
	move.w	score,d0
	bsr	digit5
	lea	fcb,a0
	move.w	creds,d0
	add.w	d0,score
	bsr	digit3
	lea	flb1,a0
	move.w	lives,d0
	add.w	#1,d0
	bsr	digit2
	lea	flb2,a0
	move.w	lives,d0
	add.w	#1,d0
	mulu.w	#50,d0
	add.w	d0,score
	bsr	digit5
	move.w	score,d0
	lea	ffs,a0
	bsr	digit5
	lea	fintext,a5
	bsr	dotext
	bsr	swap
	lea	tvpath,a0
	lea	muzexx,a6
	bsr	reopen2
	lea	lastlev,a0
	lea	levdat,a6
	bsr	reopen2
	bsr	samstop			* I don't know offhand what
	bsr	playsam			* I did this for
	
	lea	levdat+12,a0
	lea	scrlbuf,a1
	moveq	#13,d5
stup2	bsr	prinrow
	dbra.w	d5,stup2
	lea	levdat,a0
	move.w	8(a0),d0
	move.w	10(a0),d1
	move.w	d0,youx
	sub.w	#32*32,d1
	move.w	d1,youy
	move.w	#0,youxs
	move.w	#16*4,youys
	move.w	#0,youtc
	move.w	#0,youfs
	move.w	#0,yougr
	move.w	#8,youts
	move.w	#0,turn
	move.w	#0,level
	lea	endscrl,a1
	move.l	a1,yfuel
	move.w	#0,youbulr
	move.w	#16,youthrt
	move.b	#0,lastkey
wait20	btst	#7,flags
	beq	wait20
	bclr	#7,flags
	add.w	#1,level
	cmp.w	#25,level
	ble	wait20
	cmp.b	#0,lastkey
	bne	stopwat
	btst	#7,joy1
	bne	stopwat
	cmp.w	#500,level
	blt	wait20

stopwat	moveq	#0,d0
	moveq	#7,d1
	movea.l	#$ffff8240,a1
clrpal	move.l	d0,(a1)+
	dbra.w	d1,clrpal
	lea	scrlbuf+160*16,a1
	move.l	a1,copfrom
	move.w	(a0),d0
	mulu.w	2(a0),d0
	lea	22(a0,d0.w),a0
	move.l	a0,printto
	moveq	#2,d5
stup3	move.w	d5,-(sp)
	bsr	copbuf
	movea.l	printto,a0
	move.w	4(a0),d2
	move.w	(a0),d0
	move.w	2(a0),d1
	sub.w	#16,d1
	lea	badspr,a5
	lsl.w	#3,d2
	lea	(a5,d2.w),a5
	moveq	#15,d3
	bsr	sprite2
	movea.l	printto,a0
	lea	14(a0),a0
	move.w	4(a0),d2
	move.w	(a0),d0
	move.w	2(a0),d1
	sub.w	#16,d1
	lea	badspr,a5
	lsl.w	#3,d2
	lea	(a5,d2.w),a5
	moveq	#15,d3
	bsr	sprite2
	bsr	swap
	move.w	(sp)+,d5
	dbra.w	d5,stup3
	lea	levdat,a1
	movea.l	back2,a0
	move.l	a0,(a1)+
	movea.l	physic,a0
	move.l	a0,(a1)+
	movea.l	back,a0
	move.l	a0,(a1)
	move.l	a1,dead
	bsr	pryou
	bsr	swap
	
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240
	bsr	samstop
	jsr	init_muzexx
	jsr	play_muzexx
finlp	add.w	#1,turn
	bsr	doyou
	bsr	dodoor
	bsr	doscrl
	bsr	swap
	cmp.w	#1,restrt
	bne	finlp
	jsr	reinstall_interrupts
	lea	sbpath,a0
	lea	muzexx,a6
	bsr	reopen2
	bsr	playsam
	bra	gamover
doyou	move.w	youxs,d4
	move.w	youys,d5
	lsr.w	#2,d4
	lsr.w	#2,d5
	move.w	youx,d6
	add.w	d4,youx
	cmp.w	youx,d6
	move.w	youx,d7
	lsr.w	#5,d7
	lsr.w	#5,d6
	cmp.w	d6,d7
	beq	notmvd
	move.w	#0,youfs
notmvd	add.w	d5,youy
	cmp.w	#fin_you1,turn
	blt	pdoyou
	cmp.w	#fin_you2,turn
	bge	yturn1
	move.w	#0,yougr
	cmp.w	#0,youys
	beq	pdoyou
	sub.w	#2,youys
	move.w	#160*16,yougr
	bra	pdoyou	
yturn1	cmp.w	#fin_you3,turn
	bge	yturn2
	cmp.w	#160*4,yougr
	beq	pdoyou
	move.w	youtc,d4
	add.w	youts,d4
	move.w	d4,youtc
	cmp.w	#32,d4
	bne	pdoyou
	add.w	#160,yougr
	move.w	#0,youtc
	bra	pdoyou
yturn2	cmp.w	#fin_you4,turn
	bge	yturn3
	move.w	#160*4,yougr
	cmp.w	#64,youxs
	beq	pdoyou
	add.w	#2,youxs
	move.w	#160*20,yougr
	bra	pdoyou	
yturn3	cmp.w	#fin_you5,turn
	bge	yturn4
	cmp.w	#160*12,yougr
	beq	pdoyou
	move.w	youtc,d4
	add.w	youts,d4
	move.w	d4,youtc
	cmp.w	#32,d4
	bne	pdoyou
	add.w	#160,yougr
	move.w	#0,youtc
	bra	pdoyou
yturn4	cmp.w	#fin_you6,turn
	bge	yturn5
	move.w	#160*12,yougr
	cmp.w	#0,youxs
	beq	pdoyou
	sub.w	#2,youxs
	move.w	#160*28,yougr
	bra	pdoyou	
yturn5	cmp.w	#fin_you7,turn
	bge	yturn6
	cmp.w	#160*8,yougr
	beq	pdoyou
	move.w	youtc,d4
	add.w	youts,d4
	move.w	d4,youtc
	cmp.w	#32,d4
	bne	pdoyou
	sub.w	#160,yougr
	move.w	#0,youtc
	bra	pdoyou
yturn6	cmp.w	#fin_you8,turn
	bge	yturn7
	move.w	#160*8,yougr
	cmp.w	#32,youys
	beq	pdoyou
	add.w	#2,youys
	move.w	#160*24,yougr
	bra	pdoyou	
yturn7	cmp.w	#ground,youy
	beq	yturn8
	cmp.w	#0,yougr
	beq	pdoyou
	move.w	youtc,d4
	add.w	youts,d4
	move.w	d4,youtc
	cmp.w	#32,d4
	bne	pdoyou
	sub.w	#160,yougr
	move.w	#0,youtc
	bra	pdoyou
yturn8	move.w	#0,youys
	cmp.w	#fin_you9,turn
	bne	pdoyou
	move.w	#3,youfs
	move.w	#7,youxs
pdoyou	bsr	pryou
	cmp.w	#ground,youy
	bne	pyouout
	add.w	#1,youfs
notc1	cmp.w	#3,youfs
	bgt	pyouout
	movea.l	back,a4
	lea	153*160+96(a4),a4
	moveq	#3,d4
bigrlp	moveq	#31,d5
litrlp	ror.w	(a4)+
	dbra.w	d5,litrlp
	lea	96(a4),a4
	dbra.w	d4,bigrlp
pyouout	rts
doscrl	cmp.w	#16,youthrt
	bne	scrtup
	sub.w	#1,youbulr
	bcs	newscrl
	rts
scrtup	movea.l	physic,a4
	movea.l	back,a5
	lea	160(a4),a4
	moveq	#14*5-1,d4
scrlt1	move.w	(a4),(a5)
	move.w	8(a4),8(a5)
	move.w	16(a4),16(a5)
	move.w	24(a4),24(a5)
	lea	32(a5),a5
	lea	32(a4),a4
	dbra.w	d4,scrlt1
	movea.l	fuelcnt,a4
	moveq	#4,d4
scrlt2	move.w	(a4),(a5)
	move.w	8(a4),8(a5)
	move.w	16(a4),16(a5)
	move.w	24(a4),24(a5)
	lea	32(a5),a5
	lea	32(a4),a4
	dbra.w	d4,scrlt2
	move.l	a4,fuelcnt
	add.w	#1,youthrt
	cmp.w	#16,youthrt
	bne	outscr
	movea.l	back,a4
	movea.l	physic,a5
	movea.l	back2,a6
	moveq	#15*5-1,d4
scrlt3	move.w	(a4),(a5)
	move.w	8(a4),8(a5)
	move.w	16(a4),16(a5)
	move.w	24(a4),24(a5)
	move.w	(a4),(a6)
	move.w	8(a4),8(a6)
	move.w	16(a4),16(a6)
	move.w	24(a4),24(a6)
	lea	32(a6),a6
	lea	32(a5),a5
	lea	32(a4),a4
	dbra.w	d4,scrlt3
	move.w	#fin_count,youbulr
outscr	rts
newscrl	movea.l	yfuel,a4
	cmp.b	#0,(a4)
	beq	endscry
	lea	scrlbuf,a5
	move.l	a5,fuelcnt
	moveq	#39,d4
	bsr	linetxt
	moveq	#39,d4
	bsr	linetxt
	move.l	a4,yfuel
	move.w	#0,youthrt
	rts
endscry	move.w	#-1,youbulr
	rts
linetxt	lea	bplfont,a6
nxtpl	move.b	(a4)+,d5
	cmp.b	#2,d5
	blt	leadspc
	bne	oklettr
	move.w	d4,d5
	bra	lead2
oklettr	and.w	#$ff,d5
	sub.w	#32,d5
	lsl.w	#3,d5
	move.l	(a6,d5.w),d6
	move.l	4(a6,d5.w),d7
	move.b	d7,1120(a5)
	lsr.l	#8,d7
	move.b	d7,960(a5)
	lsr.l	#8,d7
	move.b	d7,800(a5)
	lsr.l	#8,d7
	move.b	d7,640(a5)
	move.b	d6,480(a5)
	lsr.l	#8,d6
	move.b	d6,320(a5)
	lsr.l	#8,d6
	move.b	d6,160(a5)
	lsr.l	#8,d6
	move.b	d6,(a5)+
	move.l	a5,d6
	btst	#0,d6
	bne	nxtcros
	addq.l	#6,a5
nxtcros	dbra.w	d4,nxtpl
	lea	160*7(a5),a5
	rts
leadspc	move.b	(a4)+,d5
	and.w	#$ff,d5
lead2	sub.w	d5,d4
lead3	clr.b	1120(a5)
	clr.b	960(a5)
	clr.b	800(a5)
	clr.b	640(a5)
	clr.b	480(a5)
	clr.b	320(a5)
	clr.b	160(a5)
	clr.b	(a5)+
	move.l	a5,d6
	btst	#0,d6
	bne	nxtcr2
	addq.l	#6,a5
nxtcr2	dbra.w	d5,lead3
	dbra.w	d4,nxtpl
	lea	160*7(a5),a5
	rts
	
dodoor	cmp.w	#fin_door,turn
	blt	doorot2
	bne	notsup
	movea.l	printto,a4
	move.w	(a4),d4
	move.w	2(a4),d5
	sub.w	#16,d5
	lsr.w	#1,d4
	mulu.w	#160,d5
	add.w	d4,d5
	move.w	d5,(a4)
notsup	cmp.w	#fin_door+12,turn
	bgt	doorout
	movea.l	printto,a4
	cmp.w	#42*20,18(a4)
	bne	nxtfrm
	move.w	#51*20,4(a4)
	move.w	#51*20,18(a4)
	bra	nxtfrm2
nxtfrm	cmp.w	#51*20,4(a4)
	beq	nxtfrm2
	add.w	#20,18(a4)
	add.w	#20,4(a4)
nxtfrm2	bsr	putdoor
	bra	doorot2
putdoor	move.w	(a4),d4
	move.w	4(a4),d5
	move.w	18(a4),d6
	lsl.w	#3,d5
	lsl.w	#3,d6
	movea.l	back,a4
	lea	(a4,d4.w),a4
	lea	badspr,a5
	lea	(a5,d6.w),a6
	lea	(a5,d5.w),a5
	moveq.w	#15,d4
pdorlp	move.l	2(a5),d5
	move.l	2(a6),d6
	move.l	d5,(a4)
	move.l	d6,-8(a4)
	move.l	6(a5),d5
	move.l	6(a6),d6
	move.l	d5,4(a4)
	move.l	d6,-4(a4)
	lea	160(a4),a4
	lea	10(a5),a5
	lea	10(a6),a6
	dbra.w	d4,pdorlp
	rts
doorout	cmp.w	#fin_door2,turn
	blt	doorot2
	bne	nxtfrm3
	movea.l	printto,a4
	move.w	#42*20,18(a4)
	move.w	#50*20,4(a4)
	bra	nxtfrm4
nxtfrm3	movea.l	printto,a4
	cmp.w	#35*20,18(a4)
	beq	nxtfrm4
	sub.w	#20,4(a4)
	sub.w	#20,18(a4)
nxtfrm4	cmp.w	#fin_door2+12,turn
	bgt	doorot2
	bsr	putdoor
doorot2	rts
pryou	cmp.w	#320*32,youx
	bge	pryout
	movea.l	dead,a4
	movea.l	(a4),a5
	lea	0(a5),a4
	suba.l	back,a5
	move.l	copfrom,a6
	adda.l	a6,a5
	moveq	#15,d4
	move.w	youy,d5
blylp	move.l	(a5)+,(a4)+
	move.l	(a5)+,(a4)+
	move.l	(a5)+,(a4)+
	move.l	(a5)+,(a4)+
	lea	144(a5),a5
	lea	144(a4),a4
	add.w	#32,d5
	cmp.w	#ground+13*32,d5
	bge	nomore
	dbra.w	d4,blylp
nomore	move.w	youx,d4
	lsr.w	#5,d4
	cmp.w	#320,d4
	bge	pryout
	move.w	youy,d5
	lsr.w	#5,d5
	mulu.w	#160,d5
	move.w	d4,d6
	and.w	#15,d4
	and.w	#65535-15,d6
	lsr.w	#1,d6
	add.w	d6,d5
	movea.l	back,a4
	lea	(a4,d5.w),a4
	movea.l	dead,a5
	cmp.w	#304*32,youx
	blt	noka5
	addq.l	#4,a5
	bra	reoka5
noka5	move.l	a4,(a5)+
reoka5	cmp.l	#levdat+12,a5
	blt	oka5
	lea	levdat,a5
oka5	move.l	a5,dead
	moveq	#15,d5
	lea	sprites,a5
	move.w	yougr,d6
	lea	(a5,d6.w),a5
	cmp.w	#304*32,youx
	bge	offedge
psprlp	move.w	(a5)+,d6
	or.l	#$ffff0000,d6
	ror.l	d4,d6
	and.w	d6,(a4)
	and.w	d6,2(a4)
	and.w	d6,4(a4)
	and.w	d6,6(a4)
	swap	d6
	and.w	d6,8(a4)
	and.w	d6,10(a4)
	and.w	d6,12(a4)
	and.w	d6,14(a4)
	move.w	(a5)+,d6
	and.l	#$ffff,d6
	ror.l	d4,d6
	or.w	d6,(a4)
	swap	d6
	or.w	d6,8(a4)
	move.w	(a5)+,d6
	and.l	#$ffff,d6
	ror.l	d4,d6
	or.w	d6,2(a4)
	swap	d6
	or.w	d6,10(a4)
	move.w	(a5)+,d6
	and.l	#$ffff,d6
	ror.l	d4,d6
	or.w	d6,4(a4)
	swap	d6
	or.w	d6,12(a4)
	move.w	(a5)+,d6
	and.l	#$ffff,d6
	ror.l	d4,d6
	or.w	d6,6(a4)
	swap	d6
	or.w	d6,14(a4)
	lea	160(a4),a4
	dbra.w	d5,psprlp
pryout	rts
offedge	move.w	(a5)+,d6
	or.l	#$ffff0000,d6
	ror.l	d4,d6
	and.w	d6,(a4)
	and.w	d6,2(a4)
	and.w	d6,4(a4)
	and.w	d6,6(a4)
	move.w	(a5)+,d6
	and.l	#$ffff,d6
	ror.l	d4,d6
	or.w	d6,(a4)
	move.w	(a5)+,d6
	and.l	#$ffff,d6
	ror.l	d4,d6
	or.w	d6,2(a4)
	move.w	(a5)+,d6
	and.l	#$ffff,d6
	ror.l	d4,d6
	or.w	d6,4(a4)
	move.w	(a5)+,d6
	and.l	#$ffff,d6
	ror.l	d4,d6
	or.w	d6,6(a4)
	lea	160(a4),a4
	dbra.w	d5,offedge
	rts

digit5	and.l	#$ffff,d0
	divu.w	#10000,d0
	add.w	#'0',d0
	move.b	d0,(a0)+
	swap	d0
	and.l	#$ffff,d0
	divu.w	#1000,d0
	add.w	#'0',d0
	move.b	d0,(a0)+
	swap	d0
digit3	and.l	#$ffff,d0
	divu.w	#100,d0
	add.w	#'0',d0
	move.b	d0,(a0)+
	swap	d0
digit2	and.l	#$ffff,d0
	divu.w	#10,d0
	add.w	#'0',d0
	move.b	d0,(a0)+
	swap	d0
	add.w	#'0',d0
	move.b	d0,(a0)+
	rts
reopen2	move.w	#0,-(sp)
	move.l	a0,-(Sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	reopen2
	move.w	d0,youx
	move.l	a6,-(sp)
	move.l	#100000,-(sp)
	move.w	youx,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	move.w	youx,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

*********3d stuff**************

* I was originally going to put a 3d ship on the title screen,
* but this was eventually dropped.

*******************************

swap	movea.l	back,a4		* screen swap using 3 screens
	movea.l	physic,a5
	movea.l	back2,a6
	move.l	a4,physic
	move.l	a5,back2
	move.l	a6,back
	move.w	#$2700,sr
	move.l	a4,d4
	lsr.l	#8,d4
	move.b	d4,d5
	and.w	#$ff,d5
	or.w	d5,d4
	lea	$ffff8201,a4
	movep.w	d4,(a4)
	move.w	#$2300,sr
swapvbl	btst	#7,flags
	beq	swapvbl
	bclr	#7,flags
	rts
swap2	movea.l	back,a4			* screen swap using two screens
	movea.l	physic,a5
	move.l	a4,physic
	move.l	a5,back
	move.w	#$2700,sr
	move.l	a4,d4
	lsr.l	#8,d4
	move.b	d4,d5
	lsr.w	#8,d4
	move.b	d5,$ffff8203
	move.b	d4,$ffff8201
	move.w	#$2300,sr
	bclr	#7,flags
	bra	swapvbl
slowcls	movea.l	back,a4			* exactly what it says
	move.w	#8000-1,d4
cloop	clr.l	(a4)+
	dbra.w	d4,cloop
	rts
install	move.b	#$12,d0		* Install the keyboard routine
	bsr	sendkey
	move.b	#$15,d0
	bsr	sendkey
	move.w	#34,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,vectab
	movea.l	d0,a0
	move.l	32(a0),oldvec1		
	move.l	#fullkey,32(a0)
	rts
remove	movea.l	vectab,a0	* remove the keyboard routine
	move.l	oldvec1,32(a0)
	move.b	#$08,d0
	bsr	sendkey
	rts
fullkey	btst	#7,$fffffc00.w		* the keyboard routine
	beq	nofkey
	move.b	$fffffc02.w,d0
	cmp.b	#0,joypack
	bne	getpack
	btst	#7,d0
	bne	keyneg
	cmp.b	#$3a,d0
	bge	nofkey
	lea	fkeytab,a0
	and.w	#127,d0
	move.b	#1,(a0,d0.w)
	move.b	d0,lastkey
	cmp.b	#$1d,d0
	beq	ctrlon
	cmp.b	#$2a,d0
	beq	lson
	cmp.b	#$36,d0
	beq	rson
	cmp.b	#$38,d0
	bne	nofkey
	bset	#3,sshift
	rts
ctrlon	bset	#2,sshift
	rts
lson	bset	#1,sshift
	rts
rson	bset	#0,sshift
	rts
nofkey	rts
keyneg	cmp.b	#$f5,d0
	bhi	package
	and.w	#127,d0
	cmp.b	#$3a,d0
	bge	nofkey
	lea	fkeytab,a0
	move.b	#0,(a0,d0.w)
	cmp.b	#$1d,d0
	beq	ctrloff
	cmp.b	#$2a,d0
	beq	lsoff
	cmp.b	#$36,d0
	beq	rsoff
	cmp.b	#$38,d0
	bne	nofkey
	bclr	#3,sshift
	rts
ctrloff	bclr	#2,sshift
	rts
lsoff	bclr	#1,sshift
	rts
rsoff	bclr	#0,sshift
	rts
package	move.b	#2,joypack
	rts
getpack	sub.b	#1,joypack
	bne	fout
	move.b	d0,joy1
fout	rts
sendkey	btst	#1,$fffffc00.w
	beq	sendkey
	move.b	d0,$fffffc02.w
	rts
vectab	dc.l	0
oldvec1	dc.l	0
sshift	dc.b	0
joy1	dc.b	0
lastkey	dc.b	0
joypack	dc.b	0
fkeytab	ds.b	$3A
keylist	dc.b	0,0,'1','2','3','4','5','6','7','8','9','0','-','+',2,0
	dc.b	'Q','W','E','R','T','Y','U','I','O','P',0,0,1,0,'A','S'
	dc.b	'D','F','G','H','J','K','L',':',0,0,0,0,'Z','X','C','V'
	dc.b	'B','N','M',',','.','?',0,0,0,' ',0

mkstrz	movea.l	back2,a0		* make the star field
	movea.l	back,a1
	movea.l	physic,a2
	moveq	#99,d0
mkstrlp	bsr	random
	and.w	#1023,d7
	sub.w	#512,d7
	move.w	d7,(a0)
	move.w	d7,d6
	bsr	random
	and.w	#1023,d7
	sub.w	#512,d7
	move.w	d7,2(a0)
	move.w	d7,d5
	muls.w	d5,d5
	muls.w	d6,d6
	add.l	d6,d5
	cmp.l	#50*50,d5
	ble	mkstrlp
	addq.l	#4,a0
getdepf	bsr	random
	and.w	#1023,d7
	cmp.w	#200,d7
	blt	getdepf
	move.w	d7,(a0)+
	move.l	a2,(a0)+
	move.l	a1,(a0)+
	dbra.w	d0,mkstrlp
	rts
stars	movea.l	back2,a4		* do the starfield
	moveq	#99,d4
blstar	move.l	10(a4),a5
	move.l	#0,(a5)
	move.w	#0,4(a5)
	move.l	6(a4),10(a4)
	lea	14(a4),a4
	dbra.w	d4,blstar
	movea.l	back2,a4
	movea.l	back,a5
	moveq	#99,d4
drstar	move.w	(a4)+,d5
	move.w	(a4)+,d6
	move.w	(a4)+,d7
	ext.l	d5
	ext.l	d6
	lsl.l	#8,d5
	lsl.l	#8,d6
	divs.w	d7,d5
	divs.w	d7,d6
	move.w	d7,-(sp)
	sub.w	#10,d7
	cmp.w	#150,d7
	bge	okstar
nokstar	bsr	random
	and.w	#1023,d7
	sub.w	#512,d7
	move.w	d7,-6(a4)
	move.w	d7,d6
	bsr	random
	and.w	#1023,d7
	sub.w	#512,d7
	move.w	d7,-4(a4)
	move.w	d7,d5
	muls.w	d5,d5
	muls.w	d6,d6
	add.l	d6,d5
	cmp.l	#50*50,d5
	ble	nokstar
	move.w	#1023,d7
okstar	move.w	d7,-2(a4)
	add.w	#160,d5
	add.w	#100,d6
	cmp.w	#0,d5
	blt	soffscr
	cmp.w	#319,d5
	bgt	soffscr
	cmp.w	#0,d6
	blt	soffscr
	cmp.w	#199,d6
	bgt	soffscr
	move.w	d6,d7
	add.w	d7,d7
	add.w	d7,d7
	add.w	d6,d7
	lsl.w	#5,d7
	move.w	d5,d6
	and.w	#65535-15,d5
	lsr.w	#1,d5
	add.w	d5,d7
	and.w	#15,d6
	movea.l	a5,a6
	lea	2(a6,d7.w),a6
	move.l	a6,(a4)
	move.w	#32768,d7
	lsr.w	d6,d7
	move.w	(sp)+,d6
	lsr.w	#6,d6
	move.l	a5,-(sp)
	lea	plottab,a5
	and.w	#255-3,d6
	movea.l	(a5,d6.w),a5
	jsr	(a5)
	movea.l	(sp)+,a5
	addq.l	#8,a4
	dbra.w	d4,drstar
	rts
col2	move.w	d7,d5
	not.w	d5
	or.w	d7,(a6)
	and.w	d5,2(a6)
	and.w	d5,4(a6)
	rts
col4	move.w	d7,d5
	not.w	d5
	and.w	d5,(a6)
	or.w	d7,2(a6)
	and.w	d5,4(a6)
	rts
col6	move.w	d7,d5
	not.w	d5
	or.w	d7,(a6)
	or.w	d7,2(a6)
	and.w	d5,4(a6)
	rts
col8	move.w	d7,d5
	not.w	d5
	and.w	d5,(a6)
	and.w	d5,2(a6)
	or.w	d7,4(a6)
	rts	
plottab	dc.l	col2,col4,col6,col8
soffscr	bsr	random
	and.w	#1023,d7
	sub.w	#512,d7
	move.w	d7,-6(a4)
	move.w	d7,d6
	bsr	random
	and.w	#1023,d7
	sub.w	#512,d7
	move.w	d7,-4(a4)
	move.w	d7,d5
	muls.w	d5,d5
	muls.w	d6,d6
	add.l	d6,d5
	cmp.l	#50*50,d5
	ble	soffscr
	move.w	#1023,-2(a4)
	move.l	back,a6
	move.l	a6,(a4)+
	addq.l	#4,a4
	move.w	(sp)+,d7
	dbra.w	d4,drstar
	rts
scrlit	movea.l	back,a4			* scroll the scrolly up a line
	lea	100*160+16(a4),a4
	movea.l	physic,a5
	lea	101*160+16(a5),a5
	moveq	#90,d4
scrlit1	moveq	#15,d5
scrlit2	move.w	(a5)+,(a4)+
	addq.l	#6,a4
	addq.l	#6,a5
	dbra.w	d5,scrlit2
	lea	32(a4),a4
	lea	32(a5),a5
	dbra.w	d4,scrlit1
	movea.l	scrlget,a5
	moveq	#15,d5
scrlit3	move.w	(a5)+,(a4)+
	addq.l	#6,a4
	dbra.w	d5,scrlit3
	move.l	a5,scrlget
	rts

cline	movea.l	savescr,a4		* new line for scrolly
	lea	plfont,a5
	lea	scrlbuf,a6
	move.l	a6,scrlget
	move.w	#7,nolines
	moveq.w	#31,d7
cllinlp	moveq	#0,d4
	move.b	(a4)+,d4
	cmpi.w	#1,d4
	blt	endscrz
	beq	filline
	sub.w	#33,d4
	bcs	space1
	lsl.w	#3,d4
	move.l	(a5,d4.w),d5
	move.l	4(a5,d4.w),d6
	move.b	d6,224(a6)
	lsr.l	#8,d6
	move.b	d6,192(a6)
	lsr.l	#8,d6
	move.b	d6,160(a6)
	lsr.l	#8,d6
	move.b	d6,128(a6)
	move.b	d5,96(a6)
	lsr.l	#8,d5
	move.b	d5,64(a6)
	lsr.l	#8,d5
	move.b	d5,32(a6)
	lsr.l	#8,d5
	move.b	d5,(a6)+
	dbra.w	d7,cllinlp
	move.l	a4,savescr
	rts
space1	moveq.b	#0,d4
	move.b	d4,224(a6)
	move.b	d4,192(a6)
	move.b	d4,160(a6)
	move.b	d4,128(a6)
	move.b	d4,96(a6)
	move.b	d4,64(a6)
	move.b	d4,32(a6)
	move.b	d4,(a6)+
	dbra.w	d7,cllinlp
	move.l	a4,savescr
	rts
filline	moveq.b	#0,d4
	move.b	d4,224(a6)
	move.b	d4,192(a6)
	move.b	d4,160(a6)
	move.b	d4,128(a6)
	move.b	d4,96(a6)
	move.b	d4,64(a6)
	move.b	d4,32(a6)
	move.b	d4,(a6)+
	dbra.w	d7,filline
	move.l	a4,savescr
	rts
endscrz	bsr	filline
	lea	scrltxt,a4
	move.l	a4,savescr
	rts
	
musgen	jsr	reinstall_interrupts	* retgen while music playing
	bra	retgen2
retgen	bsr	samstop			* retgen while sample playing
retgen2	bsr	remove
	move.b	oldkey,$484
	move.w	#1,-(sp)
	move.l	iphysic,-(sp)
	move.l	iphysic,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	pea	pal2
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	move.b	#$8,$fffc02
	move.w	#0,-(sp)
	trap	#1

prn16	and.l	#$ffff,d0
	divu.w	#10000,d0
	add.b	#48,d0
	move.b	d0,(a0)
	swap	d0
	and.l	#$ffff,d0
	divu.w	#1000,d0
	add.b	#48,d0
	move.b	d0,1(a0)
	swap	d0
	and.l	#$ffff,d0
	divu.w	#100,d0
	add.b	#48,d0
	move.b	d0,2(a0)
	swap	d0
	and.l	#$ffff,d0
	divu.w	#10,d0
	add.b	#48,d0
	move.b	d0,3(a0)
	swap	d0
	add.b	#48,d0
	move.b	d0,4(a0)
	rts	
printen	and.l	#$ff,d0
	divu.w	#10,d0
	add.b	#48,d0
	move.b	d0,(a0)
	swap	d0
	add.b	#48,d0
	move.b	d0,1(a0)
	rts
sprite	move.w	d2,d6		*	multiply
	add.w	d2,d2		*	sprite
	add.w	d2,d2		*	number
	add.w	d2,d6		*	by 160
	lsl.l	#5,d6		*
	lea	(a5,d6.w),a5
sprite2	movea.l	back,a6
	move.w	d1,d6
	cmp.w	#0,d1
	ble	notop
	move.w	d1,d7		*	multiply
	add.w	d1,d1		*	line
	add.w	d1,d1		*	numer
	add.w	d1,d7		*	by 160
	lsl.w	#5,d7		*
	lea	(a6,d7.w),a6
notop	moveq	#0,d1
	moveq	#0,d5
	cmp.w	#0,d0
	bge	onlft
	bset	#0,d5
	lea	-8(a6),a6
	bra	onscr
onlft	cmp.w	#304,d0
	ble	onrght
	bset	#1,d5
onrght	move.w	d0,d1
	and.w	#$fff0,d1
	lsr.w	#1,d1
	lea	(a6,d1.w),a6
onscr	add.w	d1,d1
	sub.w	d1,d0
	not.w	d0
	and.w	#$f,d0
	add.w	#1,d0		*d0=no. rots left
rows	cmp.w	#0,d6
	blt	nodo
	cmp.w	#192,d6
	bge	sprret
	move.l	#$ffffffff,d1
	move.w	(a5),d1
	rol.l	d0,d1
	btst	#1,d5
	bne	norght1
	and.w	d1,8(a6)
	and.w	d1,10(a6)
	and.w	d1,12(a6)
	and.w	d1,14(a6)
	btst	#0,d5
	bne	nolft1
norght1	swap	d1
	and.w	d1,(a6)
	and.w	d1,2(a6)
	and.w	d1,4(a6)
	and.w	d1,6(a6)
nolft1	movem.w	2(a5),d1/d2/d4/d7
	and.l	#$ffff,d1
	and.l	#$ffff,d2
	and.l	#$ffff,d4
	and.l	#$ffff,d7
	lsl.l	d0,d1
	lsl.l	d0,d2
	lsl.l	d0,d4
	lsl.l	d0,d7
	btst	#1,d5
	bne	norght2
	or.w	d1,8(a6)
	or.w	d2,10(a6)
	or.w	d4,12(a6)
	or.w	d7,14(a6)
	btst	#0,d5
	bne	nolft2
norght2	swap	d1
	swap	d2
	swap	d4
	swap	d7
	or.w	d1,(a6)
	or.w	d2,2(a6)
	or.w	d4,4(a6)
	or.w	d7,6(a6)
nolft2	lea	160(a6),a6
nodo	addq.w	#1,d6
	lea	10(a5),a5
	dbra.w	d3,rows
sprret	rts
spr32	movea.l	back,a6
	moveq	#0,d6
	move.w	d2,d6		*	multiply
	add.w	d2,d2		*	sprite
	add.w	d2,d2		*	number
	add.w	d2,d6		*	by 640
	lsl.l	#7,d6		*
	adda.l	d6,a5
	move.w	d1,a4
	cmp.w	#0,d1
	ble	notop32
	move.w	d1,d7		*	multiply
	add.w	d1,d1		*	line
	add.w	d1,d1		*	numer
	add.w	d1,d7		*	by 160
	lsl.w	#5,d7		*
	lea	(a6,d7.w),a6
notop32	moveq	#0,d1
	moveq	#0,d5
	cmp.w	#0,d0
	bge	onlft32
	bset	#3,d5
	subq.l	#8,a6
	cmp.w	#-16,d0
	bge	onscr32
	subq.l	#8,a6
	bset	#2,d5
	bra	onscr32
onlft32	cmp.w	#288,d0
	blt	onrght3
	bset	#0,d5
	cmp.w	#304,d0
	blt	onrght3
	bset	#2,d5
onrght3	move.w	d0,d1
	and.w	#$fff0,d1
	lsr.w	#1,d1
	lea	(a6,d1.w),a6
onscr32	not.w	d0
	and.w	#$f,d0
	addq.w	#1,d0
	lea	maskdat,a2
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	(a2,d1.w),a2
	move.w	d0,d7
	move.l	#$ffffffff,d6
	move.w	(a2),d6
	move.w	#32,a3
rows32	cmp.w	#0,a4
	blt	nodo32
	cmp.w	#192,a4
	bge	spret
	movem.l	(a5)+,d0-d4
	rol.l	d7,d0
	rol.l	d7,d1
	rol.l	d7,d2
	rol.l	d7,d3
	rol.l	d7,d4
swapret	movem.l	d0-d4,-(sp)
	btst	#3,d5
	bne	noleft1
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	and.l	d6,d4
	or.w	2(a2),d0
	and.w	d0,(a6)
	and.w	d0,2(a6)
	and.w	d0,4(a6)
	and.w	d0,6(a6)
	or.w	d1,(a6)
	or.w	d2,2(a6)
	or.w	d3,4(a6)
	or.w	d4,6(a6)
noleft1	btst	#2,d5
	bne	nomid1
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	and.w	d0,8(a6)
	and.w	d0,10(a6)
	and.w	d0,12(a6)
	and.w	d0,14(a6)
	or.w	d1,8(a6)
	or.w	d2,10(a6)
	or.w	d3,12(a6)
	or.w	d4,14(a6)
nomid1	movem.l	(sp)+,d0-d4
	btst	#0,d5
	bne	nori1
	not.w	d6
	not.w	2(a2)
	and.l	d6,d0
	and.l	d6,d1
	and.l	d6,d2
	and.l	d6,d3
	and.l	d6,d4
	or.w	2(a2),d0
	and.w	d0,16(a6)
	and.w	d0,18(a6)
	and.w	d0,20(a6)
	and.w	d0,22(a6)
	or.w	d1,16(a6)
	or.w	d2,18(a6)
	or.w	d3,20(a6)
	or.w	d4,22(a6)
	not.w	d6
	not.w	2(a2)
nori1	lea	160(a6),a6
nodo32r	addq.w	#1,a4
	sub.w	#1,a3
	cmp.w	#0,a3
	bne	rows32
spret	rts
nodo32	lea	20(a5),a5
	bra	nodo32r
maskdat	dc.w	0,65535,1,65534,3,65532,7,65528,15,65520,31,65504
	dc.w	63,65472,127,65408,255,65280,511,65024,1023,64512,2047,63488
	dc.w	4095,61440,8191,57344,16383,49152,32767,32768,65535,0

thrtab	dc.w	0,-2,1,-2,1,-1,2,-1,2,0,2,1,1,1,1,2
	dc.w	0,2,-1,2,-1,1,-2,1,-2,0,-2,-1,-1,-1,-1,-2
	dc.w	0,-3,1,-2,2,-2,2,-1,3,0,2,1,2,2,1,2
	dc.w	0,3,-1,2,-2,2,-2,1,-3,0,-2,-1,-2,-2,-1,-2
	dc.w	0,-4,1,-3,2,-2,3,-1,4,0,3,1,2,2,1,3
	dc.w	0,4,-1,3,-2,2,-3,1,-4,0,-3,-1,-2,-2,-1,-3
	dc.w	0,-5,2,-4,3,-3,4,-2,5,0,4,2,3,3,2,4
	dc.w	0,5,-2,4,-3,3,-4,2,-5,0,-4,-2,-3,-3,-2,-4
dirtab	dc.w	0,-16,6,-15,12,-12,15,-6
	dc.w	16,0,15,6,12,12,6,15
	dc.w	0,16,-6,15,-12,12,-15,6
	dc.w	-16,0,-15,-6,-12,-12,-6,-15
coldat	dc.b	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	0,0,0,0,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1	*These 4 are diagonals
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	3,3,3,3,2
	dc.b	1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	3,3,3,0,3,3,3,0,3,3,2
	dc.b	1,1,1,1,1,1,1,1,0,1,1,1,0,0,1,1,0,1,1,0,0
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	1,1,0,1,1,0,1,0,1,1,1,1,1,1,1,1
	dc.b	1,1,1,1,1,1,1,1,0,0,0,0
 even
disttab	dc.l	0,75,100,125,150,175,200
sectab	dc.l	firebmb,deflas,caretro,cloak,timesh
sbd16	include	"a:\grav_2\sbd16tab.s"

	include	"a:\grav_2\samplay.s"
	include	"a:\grav_2\7_reg.s"
	incbin	"a:\grav_2\data\data1.dat"

logo	incbin	"a:\grav_2\data\logo.dat"
font	incbin	"a:\grav_2\data\font.dat"
mpfont	incbin	"a:\grav_2\data\mpfont.dat"
panel	incbin	"a:\grav_2\data\panel.dat"
blocks	incbin	"a:\grav_2\data\blocks.dat"
sprites	incbin	"a:\grav_2\data\rotate.dat"
badspr	incbin	"a:\grav_2\data\sbad16.dat"
expl16	incbin	"a:\grav_2\data\explo16.dat"
expl32	incbin	"a:\grav_2\data\explo32.dat"
coltab	incbin	"a:\grav_2\data\collide.dat"
tanspd	incbin	"a:\grav_2\data\tanspeed.dat"
clckgrf	incbin	"a:\grav_2\data\clock.dat"
bplfont	ds.b	8
plfont	incbin	"a:\grav_2\data\1plfont.dat"
plangrf	incbin	"a:\grav_2\data\planets.dat"

pal2	dc.w	$777,$000,$000,$000
palette	dc.w	$000,$555,$444,$333
	dc.w	$222,$000,$004,$024
	dc.w	$044,$030,$020,$242
	dc.w	$000,$660,$700,$632
pbawpal	dc.w	$000,$555,$444,$333
	dc.w	$222,$000,$222,$333
	dc.w	$444,$333,$222,$444
	dc.w	$000,$555,$333,$444
tpal	dc.w	$000,$555,$777,$555
	dc.w	$555,$555,$333,$555
	dc.w	$222,$555,$000,$555
	dc.w	$222,$333,$444,$555
chpal	dc.w	$000,$555,$035,$046
	dc.w	$023,$444,$333,$222
	dc.w	$131,$141,$000,$000
	dc.w	$740,$770,$500,$000	

back	dc.l	0
physic	dc.l	0
back2	dc.l	0
iphysic	dc.l	0

scrltxt	dc.b	"             GRAV 2",1
	dc.b	1
	dc.b	"               BY",1
	dc.b	"             MARTIN",1
	dc.b	"            BROWNLOW",1
	dc.b	1
	dc.b	"            MUSIC BY",1
	dc.b	"           DAVE GYMER",1
	dc.b	1,1,1
	dc.b	"             HI! TO",1,1
	dc.b	"          STEVE CAMBER",1
	dc.b	"         ADAM  TURNBULL",1
	dc.b	"         MARK  SHILLING",1
	dc.b	"        DUNCAN ROBERTSON",1
	dc.b	"    RICHARD (RINGO) CLEMENTS",1
	dc.b	"DANIEL MARK WITH A C! LITTLEWOOD"
	dc.b	"         AND MY BROTHER",1
	dc.b	1,1,1,1
	dc.b	"      PRESS FIRE TO START.",1	
	dc.b	1,1,1,1
	dc.b	"          HIGH SCORES:",1
	dc.b	1,1
saveloc	dc.b	" 1ST 01000  MEE                 "
	dc.b	" 2ND 00900                      "
	dc.b	" 3RD 00800  VICTOR KRUEGER      "
	dc.b	" 4TH 00700  RUSSELL NASH        "
	dc.b	" 5TH 00600  BRENDA J WYATT      "
	dc.b	" 6TH 00500  RAMIREZ             "
	dc.b	" 7TH 00400                      "
	dc.b	" 8TH 00300    OOPS MRS MIGGINS  "
	dc.b	" 9TH 00200      THERE GO YER    "
hstab	dc.b	"10TH 00100        CHICKENS      "
saveend	dc.b	1,1,1,1
	dc.b	"   THIS PROGRAM IS SHAREWARE:",1,1
	dc.b	"  IT MAY BE FREELY DISTRIBUTED",1
	dc.b	"    ON CONDITION THAT IF YOU",1
	dc.b	"    WISH TO KEEP IT YOU SEND",1
	dc.b	"   A 5 POUND REGISTRATION FEE",1
	dc.b	"      TO THE ADDRESS BELOW",1,1
	dc.b	"   SUPPORT FOR THIS GAME WILL",1
	dc.b	"    ENSURE FURTHER SHAREWARE",1
	dc.b	"           RELEASES!!",1,1
	dc.b	"ANYBODY WHO REGISTERS THEIR COPY"
	dc.b	"     OF GRAV 2 WILL RECEIVE",1
	dc.b	"  A DISK OF GOODIES, INCLUDING",1
	dc.b	" A DEMO OF SPUD WHICH HOPEFULLY",1
	dc.b	"     WILL BE RELEASED NEXT.",1
	dc.b	"   FURTHER DETAILS ARE IN THE",1
	dc.b	"  FILE README.DOC ON THIS DISK",1,1
	dc.b	"   SEND REGISTRATION FEES TO:",1,1
	dc.b	"        MARTIN BROWNLOW",1
	dc.b	"       89 MARPLES AVENUE",1
	dc.b	"      MANSFIELD WOODHOUSE",1
	dc.b	"        NOTTS. NG19 9EZ",1
	dc.b	"           (ENGLAND!)",1,1,1,0
 even
savel2	dc.w	1000,900,800,700,600
	dc.w	500,400,300,200
highs	dc.w	100
savee2	
fintext	dc.b	1,9,2,"CONGRATULATIONS PILOT!"
	dc.b	1,4,4,"YOU HAVE DEFEATED THE RENEGADES'"
	dc.b	1,7,5,"HOME BASE AND THEIR EMPIRE"
	dc.b	1,10,6,"NOW STANDS IN RUINS!"
	dc.b	1,5,9,"YOUR SCORE:",1,30,9
fys	dc.b	"00000"
	dc.b	1,5,11,"CREDITS BONUS:",1,32,11
fcb	dc.b	"000"
	dc.b	1,5,13,"LIVES BONUS:",1,20,13
flb1	dc.b	"00 X 50   "
flb2	dc.b	"00000"
	dc.b	1,5,16,"FINAL SCORE:",1,30,16
ffs	dc.b	"00000"
	dc.b	1,15,19,"WELL DONE."
	dc.b	1,7,20,"YOU HAVE COMPLETED GRAV 2."
	dc.b	1,7,21,"WHY NOT GO BACK AND TRY IT"
	dc.b	1,14,22,"ANOTHER WAY?",0
	
nonetxt	dc.b	1,12,2,"YOU HAVE RUN OUT"
	dc.b	1,10,3,"OF WORLDS TO CONQUER",0
hstext	dc.b	1,15,7,"GAME OVER",1,12,11
	dc.b	"CONGRATULATIONS!",1,9,12
	dc.b	"YOU HAVE A HIGH SCORE!",1,9,16
	dc.b	"PLEASE ENTER YOUR NAME",1,9,17
	dc.b	":",1,30,17,":",0

share	dc.b	1,7,0,"THIS PROGRAM IS SHAREWARE:"
	dc.b	1,6,1,"IT MAY BE FREELY DISTRIBUTED"
	dc.b	1,8,2,"ON CONDITION THAT IF YOU"
	dc.b	1,8,3,"WISH TO KEEP IT YOU SEND"
	dc.b	1,7,4,"A 5 POUND REGISTRATION FEE"
	dc.b	1,9,5,"TO THE ADDRESS BELOW.."
	dc.b	1,7,6,"SUPPORT FOR THIS GAME WILL"
	dc.b	1,8,7,"ENSURE FURTHER SHAREWARE"
	dc.b	1,15,8,"RELEASES!!"
	dc.b	1,4,10,"ANYBODY WHO REGISTERS THEIR COPY"
	dc.b	1,9,11,"OF GRAV 2 WILL RECEIVE"
	dc.b	1,6,12,"A DISK OF GOODIES, INCLUDING"
	dc.b	1,5,13,"A DEMO OF SPUD WHICH HOPEFULLY"
	dc.b	1,9,14,"WILL BE RELEASED NEXT."
	dc.b	1,7,16,"FURTHER DETAILS ARE IN THE"
	dc.b	1,6,17,"FILE README.DOC ON THIS DISK"
	dc.b	1,7,19,"SEND REGISTRATION FEES TO:"
	dc.b	1,4,20,"        MARTIN BROWNLOW"
	dc.b	1,4,21,"       89 MARPLES AVENUE"
	dc.b	1,4,22,"      MANSFIELD WOODHOUSE"
	dc.b	1,4,23,"        NOTTS. NG19 9EZ"
	dc.b	1,4,24,"           (ENGLAND!)",0
endscrl	dc.b	2,2
	dc.b	1,3,"PROGRAM CODE, GRAPHICS, SOUND BY",2 
	dc.b	1,11,"MARTIN BROWNLOW.",2
	dc.b	1,15,"MUSIC BY",2
	dc.b	1,14,"DAVE GYMER",2
	dc.b	2,2
	dc.b	1,13,"PLAYTESTING:",2
	dc.b	1,4,"MICHAEL BROWNLOW, STEVE CAMBER",2
	dc.b	1,13,"PLAYTESTING:",2
	dc.b	1,5,"MARK SHILLING, ADAM TURNBULL",2
	dc.b	1,13,"PLAYTESTING:",2
	dc.b	1,1,"DUNCAN ROBERTSON, DANIEL LITTLEWOOD.",2
	dc.b	2,2
	dc.b	1,14,"THANKS TO:",2
	dc.b	1,1,"QUEEN AND J.M.JARRE FOR THEIR MUSIC.",2
	dc.b	1,14,"THANKS TO:",2
	dc.b	1,6,"MANDARIN SOFTWARE FOR STOS",2
	dc.b	1,14,"THANKS TO:",2
	dc.b	1,9,"HISOFT FOR DEVPAC ST",2
	dc.b	2,2
	dc.b	1,1,"THANKS FOR PLAYING GRAV 2 TO THE END",2
	dc.b	1,8,"I HOPE YOU ENJOYED IT!",2
	dc.b	2,1,10,"THAT'S ALL, FOLKS!",2
	dc.b	2,2
	dc.b	0 

hsname	dc.b	"data\gravhs.dat",0		* note: relative
tvpath	dc.b	"data\data2.dat",0		* filenames!!
sbpath	dc.b	"data\data1.dat",0
lastlev	dc.b	"data\data3.dat",0
filename
	dc.b	"data\"
inshere	dc.b	"            ",0
 even

level_bits
	dc.w	5,0,%110000
	dc.w	5,0,%1010000
	dc.w	10,0,%11100000
	dc.w	10,0,%111010000
	dc.w	10,0,%11100000
	dc.w	10,0,%110000000
	dc.w	15,0,%11110100000
	dc.w	15,0,%101110000
	dc.w	15,0,%111011110000
	dc.w	15,0,%11100000000000
	dc.w	15,0,%111101000000000
	dc.w	20,0,%11011100000000
	dc.w	20,%11,%1000101000000000
	dc.w	20,%1,%1101110000000000
	dc.w	20,%111,%1011000000000000
	dc.w	20,%110,%0100000000000000
	dc.w	25,%100110,%1111000000000000
	dc.w	25,%11101,0
	dc.w	25,%110000,0
	dc.w	25,0,0
	dc.w	30,%100000,0
	dc.w	30,0,0
	dc.w	30,0,0
	dc.w	30,0,0
	dc.w	30,0,0
	dc.w	30,0,0
	
level_names
	dc.b	"STEVENS' WORLD          "
	dc.b	"BARREN      "
	dc.b	2,0,1,"LEVEL9.DAT",0,0,0
	dc.b	"PHAENTUS III            "
	dc.b	"CRYSTALLINE "
	dc.b	2,0,12,"LEVEL2.DAT",0,0,0
	dc.b	"PHAENTUS IV             " 
	dc.b	"BARREN      "
	dc.b	2,0,15,"LEVEL0.DAT",0,0,0
	dc.b	"ARBORIA                 "
	dc.b	"TROPICAL    "
	dc.b	2,0,21,"LEVELG.DAT",0,0,0
	dc.b	"HERACLEUS MAJOR         "
	dc.b	"CRYSTALLINE "
	dc.b	2,0,18,"LEVELC.DAT",0,0,0
	dc.b	"ALDERAAN                "
	dc.b	"CRYSTALLINE "
	dc.b	2,0,22,"LEVELF.DAT",0,0,0
	dc.b	"KING'S BELT - M7        "
	dc.b	"ASTEROID    "
	dc.b	2,0,17,"LEVELB.DAT",0,0,0
	dc.b	"SCROFULUS MINIMUS       "
	dc.b	"CRYSTALLINE "
	dc.b	1,0,0,"LEVEL4.DAT",0,0,0
	dc.b	"DANNEN                  "
	dc.b	"MINE        "
	dc.b	2,1,11,"LEVEL5.DAT",0,0,0
	dc.b	"                        "
	dc.b	"            "
	dc.b	0,0,0,"LEVELX.DAT",0,0,0
	dc.b	"COROLADO                "
	dc.b	"BARREN      "
	dc.b	1,1,24,"LEVELI.DAT",0,0,0
	dc.b	"AMAZONIA                "
	dc.b	"TROPICAL    "
	dc.b	2,1,2,"LEVEL6.DAT",0,0,0
	dc.b	"NOSTROMO SULACO STATION "
	dc.b	"STATION     "
	dc.b	2,1,25,"LEVELJ.DAT",0,0,0
	dc.b	"TROPICA                 "
	dc.b	"TROPICAL    "
	dc.b	2,1,16,"LEVELA.DAT",0,0,0
	dc.b	"BATTLE 1                "
	dc.b	"STARSHIP    "
	dc.b	1,2,14,"LEVEL1.DAT",0,0,0
	dc.b	"ENDEAVOUR STATION       "
	dc.b	"ORBITAL BASE"
	dc.b	2,2,10,"LEVEL7.DAT",0,0,0
	dc.b	"HUNTER'S MOON           "
	dc.b	"BARREN      "
	dc.b	2,2,23,"LEVELH.DAT",0,0,0
	dc.b	"HADLEY'S HOPE STATION   "
	dc.b	"ORBITAL BASE"
	dc.b	0,2,20,"LEVELD.DAT",0,0,0
	dc.b	"FIGHTER COMMAND STATION "
	dc.b	"ORBITAL BASE"
	dc.b	1,2,13,"LEVEL8.DAT",0,0,0
	dc.b	"                        "
	dc.b	"            "
	dc.b	0,0,0,"LEVELX.DAT",0,0,0
	dc.b	"ANDREUS IX              "
	dc.b	"BARREN      "
	dc.b	2,3,19,"LEVEL3.DAT",0,0,0
	dc.b	"HOMEBASE                "
	dc.b	"CRYSTALLINE "
	dc.b	2,3,26,"LEVELE.DAT",0,0,0	

pawstxt	dc.b	1,17,12,"PAUSED",0
gamtxt2	dc.b	1,15,10,"GAME OVER.",1,9,22
	dc.b	"PRESS FIRE TO CONTINUE",0 
load_text
	dc.b	1,9,12,"LOADING, PLEASE WAIT",0
choose_text
	dc.b	1,2
yname	dc.b	3,"                        "
	dc.b	1,2
ytype	dc.b	4,"TYPE:                "
	dc.b	1,2
ygrav	dc.b	5,"GRAVITY:       "
	dc.b	1,2
yrate	dc.b	6,"RATING:          ",0
gravtab	dc.b	"NONE  "
	dc.b	"LOW   "
	dc.b	"NORMAL"
	dc.b	"HIGH  "
rattab	dc.b	"EASY    "
	dc.b	"MEDIUM  "
	dc.b	"HARD    "
	dc.b	"WHIMPER!"

costs	dc.b	2,4,1,6,4,2,50
screen_text
	dc.b	1,3,6," COST    2   4   1   6   4   2  50"
	dc.b	1,3,8,"STORES  "
stores_text
	dc.b	"XX  XX  XX  XX  XX  XX  XX"
	dc.b	1,3,10,"LOADED  "
loaded_text
	dc.b	"XX  XX  XX  XX  XX  XX"
	dc.b	1,12,13,"COMMENCE MISSION"
fstext	dc.b	1,12,15,"FIRE SPEED     0"
	dc.b	1,12,17,"TURN SPEED     0"
	dc.b	1,12,19,"ENGINE THRUST  0"
	dc.b	1,6,23,"SCORE "
score_text
	dc.b	"00000      CREDITS "
cred_text
	dc.b	"000"
	dc.b	0
	
********* 'variables' **************

input	dc.b	0
cmethod	dc.b	0
oldkey	dc.b	0
control	dc.b	2
wep2typ	dc.b	0
wep2act	dc.b	0
turn	dc.w	0
dead	dc.w	0
onyet	dc.w	0
copfrom	dc.l	0
printto	dc.l	0
flags	dc.w	0
topldis	dc.w	0
botldis	dc.w	0
maxtop	dc.w	0
maxlft	dc.w	0
scrrght	dc.w	0
scrlft	dc.w	0
gravstr	dc.w	0
gravcnt	dc.w	0
reward	dc.w	0
fcond1	dc.w	0
fcond2	dc.w	0
fcond3	dc.w	0
score	dc.w	0
creds	dc.w	0
level	dc.w	0
worlds	dc.l	0
wrldone	dc.l	0
clckcnt	dc.w	0	* Current count to inc clock
clckfrm	dc.w	0	* Clock graphic*80
clckdef	dc.w	0	* Clock count from (0=no clock)
wep2cnt	dc.w	0
wep2frm	dc.w	0
wep2def	dc.w	0
baw	dc.w	0

left	dc.w	0
top	dc.w	0
minx	dc.w	0
maxx	dc.w	318
miny	dc.w	16
maxy	dc.w	206
xline	dc.w	0
pixline	dc.w	16
norots	dc.w	16

quotas	ds.b	16

youdat
youx	dc.w	0
youy	dc.w	0
youxs	dc.w	0
youys	dc.w	0
yourx	dc.w	0
youry	dc.w	0
yougr	dc.w	0
youts	dc.w	4
youtc	dc.w	0
youthrt	dc.w	1*64
youbulr	dc.w	0
youfs	dc.w	4
youfc	dc.w	0
yfuel	dc.w	0
yammo	dc.w	0
fuelcnt	dc.b	0
fuelcad	dc.b	4
nobombs	dc.b	4
nodefs	dc.b	0
noretro	dc.b	4
nocloak	dc.b	4
notimer	dc.b	0
nimpact	dc.b	4
stordat	ds.w	6
lives	dc.w	5

savescr
nolines	equ	savescr+4
scrlget	equ	savescr+6

lastnos	ds.b	6
lastsc	dc.w	0
lastful	dc.w	0
lastamm	dc.w	0
lastlen	dc.w	0

**************************************

	section	BSS

levdat	ds.l	3000

rstrt	ds.w	13
buldat	ds.l	3*maxbuls
partdat	ds.w	5*maxprts
expldat	ds.l	2*maxexpl
bombdat	ds.l	3*maxbmbs
sbads	ds.l	8*100
scrlbuf	ds.l	(192+32)*40

xstep	ds.w	1
ystep	ds.w	1
nodef	ds.w	1
defspace	ds.w	50*2

