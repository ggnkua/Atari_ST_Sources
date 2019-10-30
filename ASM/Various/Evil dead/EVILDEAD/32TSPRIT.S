* True color 32x32 sprites
* Coded June 1994 !
* By *** EVIL DEAD ***
* Falcon only !
*
* special version for ST-NEWS
*
* sorry but this source is not commented due to lack of time
* better next time :-))
*
* Source for Devpac
*
* PS: Since i had no time for making a nice sin table i 'took' one 
* from an old TLB demo :-)

offset	equ	12
numspr	equ	6

new_video_mode:	equ	%100010100
palmode:	equ	%000100100

	opt	O-
	
	pea	start
	move	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	

	
	clr	-(a7)
	trap	#1
	
pic:
	incbin	stnews.raw
	even

music:
	incbin	spaceha.mus
	even
start:
	move	#-1,-(a7)
	move	#88,-(a7)
	trap	#14
	addq.l	#4,a7
	move	d0,old_video_mode
	
	move	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,oldscr
	
init_sprites:
	bsr	set_video
	jsr	music
	bsr	set_cache		
	bsr.b	initints
	
	
waitforpic:
	tst	picdone(pc)
	beq.b	waitforpic

	move	#0,which
	bsr	savesprites
	move	#1,which
	bsr	savesprites
	move	#$2700,sr
	move.l	#vbl,$70.w	
	move	#$2300,sr

demo_loop:
	cmp.b	#$39,$fffffc02.w
	bne.b	demo_loop
	
	jsr	music+36
	bsr.b	restints
	bsr	reset_cache
	
	bsr	restore_video

	move.b	#$8,$fffffc02.w
	rts

	
initints:
	move	#$2700,sr
	lea	$fffffa00.w,a0
	lea	space(pc),a1
	move.b	$7(a0),(a1)+
	move.b	$9(a0),(a1)+
	move.b	$13(a0),(a1)+
	move.b	$15(a0),(a1)+
	move.l	$70.w,(a1)+
	move.l	$134.w,(a1)+
	move.b	#$20,$7(a0)
	clr.b	$9(a0)
	move.b	#$20,$13(a0)
	clr.b	$15(a0)
	bclr.b	#3,$17(a0)
	move.b	#204,$1f(a0)
	move.b	#7,$19(a0)
	move.l	#picvbl,$70.w
	move.l	#play,$134.w
	move	#$2300,sr
	rts
	
space:
	ds.l	3
restints:
	move	#$2700,sr
	lea	$fffffa00.w,a1
	lea	space(pc),a0
	move.b	(a0)+,$7(a1)
	move.b	(a0)+,$9(a1)
	move.b	(a0)+,$13(a1)
	move.b	(a0)+,$15(a1)
	move.l	(a0)+,$70.w
	move.l	(a0)+,$134.w
	move	#$2300,sr
	rts
	
vbl:
	movem.l	d0-a6,-(a7)
;	not	$ffff9800.w
	lea	screen(pc),a0
	tst	which(pc)
	beq.b	scrset2
	move.l	screen1(pc),d0
	move.l	screen2(pc),(a0)
	bra.b	setscr
scrset2:
	move.l	screen2(pc),d0
	move.l	screen1(pc),(a0)
setscr:
	eori	#$1,which
	move.b	d0,d1
	extb.l	d1
	lsr.l	#8,d0
	lea	$ffff8200.w,a0
	movep	d0,1(a0)
	move.b	d1,$d(a0)
	bsr.b	restsprites
	bsr.b	savesprites
	bsr	drawsprites
	movem.l	(a7)+,d0-a6
;	not	$ffff9800.w
	rte

picvbl:
	movem.l	d0-a6,-(a7)
	tst	picdone(pc)
	bne.b	exitvbl
	bsr	showpic
exitvbl:
	movem.l	(a7)+,d0-a6
	rte
play:
	movem.l	d0-a6,-(a7)
	jsr	music+40
	movem.l	(a7)+,d0-a6
	rte
	
	
restsprite:	MACRO
	* a1 buffer
	* a2 spritepos
	*
	moveq	#31,d2		
resloop:
	movem.l	(a1)+,d3-d7/a3-a6
	movem.l	d3-d7/a3-a6,(a2)
	movem.l	(a1)+,d3-d7/a3-a4
	movem.l	d3-d7/a3-a4,36(a2)
	lea	640(a2),a2
	dbra	d2,resloop
	ENDM

savesprite:	MACRO
	* a2 buffer
	* a1 spritepos
	moveq	#31,d0		
savloop:
	movem.l	(a1)+,d1/d4-d7/a4-a6
	movem.l	d1/d4-d7/a4-a6,(a2)
	movem.l	(a1)+,d1/d4-d7/a4-a6
	movem.l	d1/d4-d7/a4-a6,32(a2)
	lea	64(a2),a2
	lea	640-64(a1),a1
	dbra	d0,savloop	
	ENDM

drawsprite:	MACRO
	* a0 spritedata
	* a1 spritepos
	move.l	a0,d5
	moveq	#31,d7
nextline:
	moveq	#31,d6
nextpix:
	move	(a0)+,d1
	beq.b	donextpix
	move	d1,(a1)
donextpix:
	addq.l	#2,a1
	dbra	d6,nextpix
	add.l	#640-64,a1
	dbra	d7,nextline
	move.l	d5,a0
	ENDM

restsprites:
	tst	which(pc)
	beq.b	scr1add
	move.l	screen1(pc),d1
	lea	buffer2(pc),a1
	lea	oldpos2(pc),a0
	bra.b	door
scr1add:
	lea	oldpos(pc),a0
	move.l	screen2(pc),d1
	lea	buffer(pc),a1
door:	
	moveq	#numspr-1,d0
restloop:
	move.l	(a0)+,a2
	add.l	d1,a2
	restsprite	
	dbra	d0,restloop
	rts

savesprites:
	lea	posit(pc),a0
	move.l	screen(pc),d2
	tst	which(pc)
	beq.b	scr1do
	lea	buffer2(pc),a2
	lea	oldpos2(pc),a3
	bra.b	door2
scr1do:
	lea	buffer(pc),a2
	lea	oldpos(pc),a3
door2:
	move	#numspr-1,d3
nextsprite:
	move.l	(a0),a1
	moveq	#0,d0
	moveq	#0,d1
	move.l	(a1)+,d0
	bpl.b	notreset
	move.l	4(a0),(a0)
	bra.b	nextsprite
notreset:
	move	d0,d1
	move	#0,d0
	swap	d0
	add	d0,d0
	lsl.l	#2,d1
	add.l	d0,d1
	move.l	d2,a1
	add.l	d1,a1
	move.l	d1,(a3)+
	savesprite
	addq.l	#4,(a0)
	addq.l	#8,a0
	dbra	d3,nextsprite
	rts

drawsprites:
	move	#numspr-1,d0
	lea	sprite(pc),a0
	move.l	screen(pc),d2
	tst	which(pc)
	beq.b	old1do
	lea	oldpos2(pc),a2
	bra.b	drawloop
old1do:
	lea	oldpos(pc),a2
drawloop:
	move.l	(a2)+,a1
	add.l	d2,a1
	drawsprite
	dbra	d0,drawloop
	rts



set_video:
	move	#89,-(a7)
	trap	#14
	addq.l	#2,a7
	move	d0,monitor
	
	move.l	#screenbase,d0
	and.l	#$fffffc,d0
	move.l	d0,screen1
	move	#1,which
	move.l	d0,screen
	add.l	#(640*240),d0
	and.l	#$fffffc,d0
	move.l	d0,screen2
	cmp	#2,monitor
	beq.b	vgaset
	move	#palmode,-(a7)
	bra.b	contset
vgaset:
	move	#new_video_mode,-(a7)
contset:
	move	#3,-(a7)
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move	#5,-(a7)
	trap	#14
	adda	#14,a7

	cmp	#2,monitor
	bne.b	nopatch
	move	#$507,$ffff82a2.w
	move	#99,$ffff82a4.w
	move	#269,$ffff82a6.w
	move	#299,$ffff82a8.w
	move	#299+800,$ffff82aa.w
	move	#$504,$ffff82ac.w
	
nopatch:
	clr.l	$ffff9800.w
	move.l	screen1(pc),a0
	bsr.b	clr_scr
	move.l	screen2(pc),a0
	bsr.b	clr_scr
	rts
	
monitor:	
	dc.w	0

restore_video:
	move	old_video_mode(pc),-(a7)
	move	#3,-(a7)
	move.l	oldscr(pc),-(a7)
	move.l	oldscr(pc),-(a7)
	move	#5,-(a7)
	trap	#14
	adda	#14,a7
	rts
		

set_cache:
	movec	cacr,d0
	move	d0,oldcacr
	move	#$3111,d0
	movec	d0,cacr
	rts
	
reset_cache:
	move	oldcacr(pc),d0
	movec	d0,cacr
	rts
	
oldcacr:
	dc.w	0
clr_scr:
	* screen to clear in a0
	moveq	#0,d0
	move	#200-1,d1
line:
	move	#($180/2)-1,d2
loop:
	move.l	d0,(a0)+
	dbra	d2,loop
	dbra	d1,line
	rts
		
showpic:
	lea	pic,a0
	move.l	screen1(pc),a1
	move.l	screen2(pc),a2
	move.l	add(pc),d2
	cmp.l	#640*199,d2
	bls.b	gopic
	move	#1,picdone
	rts
gopic:	
	add.l	d2,a0
	add.l	d2,a1
	add.l	d2,a2
	move.l	#(320/2)-1,d0
picloop:
	move.l	(a0)+,d1
	move.l	d1,(a1)+
	move.l	d1,(a2)+
	dbra	d0,picloop
	add.l	#640,add
	rts

	
picdone:
	dc.w	0
add:
	dc.l	0	
	
	SECTION	DATA
	
old_video_mode:	
	dc.w	0
	
oldscr:
	dc.l	0
	
screen:
	dc.l	0
	
screen1:
	dc.l	0
screen2:
	dc.l	0
which:
	dc.w	1
sprite:
	incbin	sprite.raw
	even
;i	set	0
;	rept	1024
;	dc.w	i
;i	set	i+64
;	endr
	
	
posit:
i	set	0
	rept	numspr
	dc.l	sinus+i,sinus+i
i	set	i+offset
	endr

sinus:
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	incbin	sinus.dat
	dc.w	$96,$b6*$a0
	dc.w	$97,$b7*$a0
	dc.w	$98,$b7*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dc.w	$96,$b6*$a0
	dcb.l	offset*numspr,-1
	even


	SECTION	BSS
oldpos:
	ds.l	numspr
oldpos2:
	ds.l	numspr

buffer:
	ds.w	numspr*(32*32)
buffer2:
	ds.w	numspr*(32*32)
		
screenbase:
	ds.w	320*240
	ds.w	320*240	