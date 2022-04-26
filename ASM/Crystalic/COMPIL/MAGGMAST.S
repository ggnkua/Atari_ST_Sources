*****************************************
*	Name:	Maggot Master		*
*	By:	Corny			*
*	For:	Even Worse		*
*	Date:	1992-09-14		*
*****************************************
 section text
***************************************************************************
	jsr	setsuper
	move.l	#scrollbuf,a0
	move.w	#3026,d0
	clearbufloop:
		move.b	#0,(a0)+
	dbf.w	d0,clearbufloop
	jsr	clear
	jsr	setscreen
	jsr	setinfo
click	bclr 	#0,$484.w
reloc	move.l	#(music+$1af0),(music+$1e)
	move.l 	#(music+$34e0),(music+$a4)
	move.l 	#(music+$8b0),(music+$202)
	move.l 	#(music+$8b0),(music+$87c)
	moveq 	#3,d0
	jsr 	music	
	jsr 	music+8
	jsr	startinter
key:	cmp.b	#185,$fffc02
	bne	key
	sub.w	#8,add1
	sub.w	#8,add2
	sub.w	#10,add3
	sub.w	#36,addrast
	move.w	#1,fadown
fadewait:
	cmp.w	#0,addrast
	bne	fadewait
	jsr	endinter
	move.w	#0,fadown
	jsr	clear
	jsr	setpic
	jsr	setpress
	jsr	initjoy
	moveq 	#2,d0
	jsr 	music	
	jsr 	music+8
	dc.w	$A000
	move.l	d0,linea
	move.l	$70.w,oldvbl
	move.l	#newvbi,$70.w
key2:	jsr	waitvbl
	cmp.b	#57,$fffc02
	bne	key2
***************************************************************************
start:
	lea	pic+2,a0
	jsr	setpal
	jsr	waitvbl
	lea	pic+34+160*25,a0
	jsr	setpic1
	jsr	waitvbl
	lea	pic+34+160*100,a0
	jsr	setpic2
	move.w	#3,dir1
	move.w	#100,xp1
	move.w	#99,yp1
	move.w	#100,xg1
	move.w	#99,yg1
	move.w	#0,pixel1
	move.w	#4,dir2
	move.w	#200,xp2
	move.w	#99,yp2
	move.w	#200,xg2
	move.w	#99,yg2
	move.w	#0,pixel2
	move.w	#0,joy
***************************************************************************
mainloop:
	jsr	waitvbl
	jsr	getkey
	jsr	move1
	jsr	move1
	jsr	getpixel1
	jsr	checkpix1
	jsr	draw1
	jsr	move2
	jsr	move2
	jsr	getpixel2
	jsr	checkpix2
	jsr	draw2
	jmp	mainloop
***************************************************************************
setsuper:
	clr.l	-(sp)	
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,savesuper
	rts
***************************************************************************
endsuper:
	move.l	savesuper,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
***************************************************************************
waitvbl:
	cmp.w	#1,vbiflag
	bne	waitvbl
	move.w	#0,vbiflag
	cmp.b	#97,$fffc02
	beq	exit
	rts
***************************************************************************
waitvbl2:
	cmp.w	#1,vbiflag
	bne	waitvbl
	move.w	#0,vbiflag
	rts
***************************************************************************
fadeup:
	add.w	#1,count
	cmp.w	#4,count
	ble	nofadeup
	move.w	#0,count
	cmp.w	#32*29,addfade
	bge	nofadeup
	add.w	#32,addfade
	move.l	#fadepal,a1
	add.w	addfade,a1
	move.l	(a1)+,$ff8240
	move.l	(a1)+,$ff8244
	move.l	(a1)+,$ff8248
	move.l	(a1)+,$ff824c
	move.l	(a1)+,$ff8250
	move.l	(a1)+,$ff8254
	move.l	(a1)+,$ff8258
	move.l	(a1)+,$ff825c
nofadeup:
	rts
***************************************************************************
fadedown:
	add.w	#1,count
	cmp.w	#4,count
	ble	nofadedown
	move.w	#0,count
	cmp.w	#0,addfade
	ble	nofadedown
	sub.w	#32,addfade
	move.l	#fadepal,a1
	add.w	addfade,a1
	move.l	(a1)+,$ff8240
	move.l	(a1)+,$ff8244
	move.l	(a1)+,$ff8248
	move.l	(a1)+,$ff824c
	move.l	(a1)+,$ff8250
	move.l	(a1)+,$ff8254
	move.l	(a1)+,$ff8258
	move.l	(a1)+,$ff825c
nofadedown:
	rts
***************************************************************************
setscreen:
	move.w	#0,-(sp)
	move.l	#$78000,-(sp)
	move.l	#$78000,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	add.l	#12,sp
	rts
***************************************************************************
clear:
	move.l	#$ff8240,a0
	rept	8
		move.l	#0,(a0)+
	endr
	move.l	#$70000,a0
	move.l	#$78000,a1
	move.w	#7999,d0
	clearloop:
		move.l	#0,(a0)+
		move.l	#0,(a1)+
	dbf.w	d0,clearloop
	rts
***************************************************************************
startinter:
	move.l	$120.w,oldhbi 
	move.l	$70.w,oldvbi
	move.b	$fffffa07.w,old07
	move.b	$fffffa09.w,old09
	move.b	$fffffa0f.w,old0f
	move.b	$fffffa11.w,old11
	move.b	$fffffa1b.w,old1b
	and.b 	#$df,$fffffa09.w
	and.b 	#$fe,$fffffa07.w
	move.l	#newhbi,$120.w
	move.l	#newvbl,$70.w
	or.b  	#1,$fffffa07.w
	or.b  	#1,$fffffa13.w
	rts
***************************************************************************
endinter:	
	move.l	oldhbi,$120.w 
	move.l	oldvbi,$70.w
	move.b	old07,$fffffa07.w
	move.b	old09,$fffffa09.w
	move.b	old0f,$fffffa0f.w
	move.b	old11,$fffffa11.w
	move.b	old1b,$fffffa1b.w
	rts
***************************************************************************
newvbl:
	movem.l	d0-a6,-(sp)
	jsr	music+4	
	movem.l	(sp)+,d0-a6
	clr.b	$fffffa1b.w
	move.b	#10,$fffffa21.w
	bclr	#0,$fffffa0f.w
	move.b	#8,$fffffa1b.w
	move.l	#rasters,a1
	add.w	addrast,a1
	add.w	#1,count
	cmp.w	#4,count
	bne	endvbl
	move.w	#0,count
	cmp.w	#1,fadown
	beq	fadevbl
	cmp.w	#36*7,addrast
	beq	noaddrast
	add.w	#36,addrast
	bra	endvbl
noaddrast:
	move.l	#infopal1,a2
	add.w	add1,a2
	cmp.w	#8*7,add1
	beq	noadd1
	add.w	#8,add1
	jsr	infoset1
	bra	endvbl
noadd1:
	move.l	#infopal2,a2
	add.w	add2,a2
	cmp.w	#8*5,add2
	beq	noadd2
	add.w	#8,add2
	jsr	infoset2
	bra	endvbl
noadd2:
	move.l	#infopal3,a2
	add.w	add3,a2
	cmp.w	#10*7,add3
	beq	endvbl
	add.w	#10,add3
	jsr	infoset3
	bra	endvbl
fadevbl:
	add.w	#1,waitfade
	move.l	#infopal3,a2
	add.w	add3,a2
	cmp.w	#-10,add3
	beq	nosub3
	sub.w	#10,add3
	jsr	infoset3
	bra	endvbl
nosub3:
	move.l	#infopal2,a2
	add.w	add2,a2
	cmp.w	#-8,add2
	beq	nosub2
	sub.w	#8,add2
	jsr	infoset2
	bra	endvbl
nosub2:
	move.l	#infopal1,a2
	add.w	add1,a2
	cmp.w	#-8,add1
	beq	nosub1
	sub.w	#8,add1
	jsr	infoset1
	bra	endvbl
nosub1:
	cmp.w	#0,addrast
	beq	endvbl
	sub.w	#36,addrast
endvbl:	rte
***************************************************************************
infoset1:
	move.l	(a2)+,$ff8256
	move.l	(a2)+,$ff825a
	rts
***************************************************************************
infoset2:
	move.l	(a2)+,$ff8244
	move.l	(a2)+,$ff8248
	rts
***************************************************************************
infoset3:
	move.l	(a2)+,$ff824c
	move.l	(a2)+,$ff8250
	move.w	(a2)+,$ff8254
	rts
***************************************************************************
newhbi:
	move.w	(a1)+,$ff8242
	move.b	#8,$fffffa21.w
	bclr	#0,$fffffa0f.w
	rte
***************************************************************************
newvbi:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#1,vbiflag
 	jsr	scroll
	jsr	scroll
	jsr	checkfont
	jsr	showscroll
	jsr	music+4
	cmp.w	#1,fadown
	beq	noup
	jsr	fadeup
noup:	movem.l	(sp)+,d0-d7/a0-a6
	rte
***************************************************************************
setpic1:
	move.l	#$78000+25*160,a1
	move.w	#74,d0
	setpicloop1:
	rept	20
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	dbf.w	d0,setpicloop1
	rts	
***************************************************************************
setpic:
	move.l	#pic+34,a0
	move.l	#$78000,a1
	move.w	#199,d0
	setpicloop:
	rept	20
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	dbf.w	d0,setpicloop
	rts	
***************************************************************************
setinfo:
	move.l	#info+34,a0
	move.l	#$78000,a1
	move.w	#199,d0
	setinfoloop:
	rept	20
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	dbf.w	d0,setinfoloop
	rts	
***************************************************************************
setpic2:
	move.l	#$78000+160*100,a1
	move.w	#73,d0
	setpicloop2:
	rept	20
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	dbf.w	d0,setpicloop2
	rts	
***************************************************************************
setred:
	move.l	#gameover,a0
	move.l	#$78000+160*75+40,a1
	move.w	#48,d0
	setredloop:
	rept	9
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	add.w	#160-9*8,a0
	add.w	#160-9*8,a1
	dbf.w	d0,setredloop
	rts	
***************************************************************************
setgreen:
	move.l	#gameover+72,a0
	move.l	#$78000+160*75+40,a1
	move.w	#48,d0
	setgreenloop:
	rept	9
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	add.w	#160-9*8,a0
	add.w	#160-9*8,a1
	dbf.w	d0,setgreenloop
	rts	
***************************************************************************
setpress:
	move.l	#gameover+160*49,a0
	move.l	#$78000+160*75+40,a1
	move.w	#48,d0
	setpressloop:
	rept	9
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	add.w	#160-9*8,a0
	add.w	#160-9*8,a1
	dbf.w	d0,setpressloop
	rts	
***************************************************************************
setpal:
	move.l	#$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	move.w	#$555,$ff825e
	rts
***************************************************************************
getkey:
	cmp.b	#72,$fffc02
	beq	keyup
	cmp.b	#80,$fffc02
	beq	keydown
	cmp.b	#75,$fffc02
	beq	keyleft
	cmp.b	#77,$fffc02
	beq	keyright
	rts
keyup:
	move.w	#1,dir1
	rts
keydown:
	move.w	#2,dir1
	rts
keyright:
	move.w	#3,dir1
	rts
keyleft:
	move.w	#4,dir1
	rts
***************************************************************************
getjoy:
	move.w	joy,d0
	btst	#0,d0
	bne	joyup
	btst	#1,d0
	bne	joydown
	btst	#2,d0
	bne	joyleft
	btst	#3,d0
	bne	joyright
	rts
joyup:
	move.w	#1,dir2
	rts
joydown:
	move.w	#2,dir2
	rts
joyright:
	move.w	#3,dir2
	rts
joyleft:
	move.w	#4,dir2
	rts
***************************************************************************
move1:
	move.w	xp1,xg1
	move.w	yp1,yg1
	cmp.w	#1,dir1
	beq	moveup1
	cmp.w	#2,dir1
	beq	movedown1
	cmp.w	#3,dir1
	beq	moveright1
	cmp.w	#4,dir1
	beq	moveleft1
	rts
moveup1:
	sub.w	#1,yp1
	rts
movedown1:
	add.w	#1,yp1
	rts
moveright1:
	add.w	#1,xp1
	rts
moveleft1:
	sub.w	#1,xp1
	rts
***************************************************************************
move2:
	move.w	xp2,xg2
	move.w	yp2,yg2
	cmp.w	#1,dir2
	beq	moveup2
	cmp.w	#2,dir2
	beq	movedown2
	cmp.w	#3,dir2
	beq	moveright2
	cmp.w	#4,dir2
	beq	moveleft2
	rts
moveup2:
	sub.w	#1,yp2
	rts
movedown2:
	add.w	#1,yp2
	rts
moveright2:
	add.w	#1,xp2
	rts
moveleft2:
	sub.w	#1,xp2
	rts
***************************************************************************
draw1:
	move.l	linea,a0
	move.w	xg1,$26(a0)	x1
	move.w	yg1,$28(a0)	y1
	move.w	xp1,$2A(a0)	x2
	move.w	yp1,$2C(a0)	y2
	move.w	#0,$18(a0)	bitplane 0
	move.w	#1,$1A(a0)	bitplane 1
	move.w	#1,$1C(a0)	bitplane 2
	move.w	#1,$1E(a0)	bitplane 3
	move.w	#$FFFF,$22(a0)	linepattern
	move.w	#0,$24(a0)	writemode, 0=replace
	dc.w	$a003
	rts
***************************************************************************
draw2:
	move.l	linea,a0
	move.w	xg2,$26(a0)	x1
	move.w	yg2,$28(a0)	y1
	move.w	xp2,$2A(a0)	x2
	move.w	yp2,$2C(a0)	y2
	move.w	#1,$18(a0)	bitplane 0
	move.w	#0,$1A(a0)	bitplane 1
	move.w	#1,$1C(a0)	bitplane 2
	move.w	#1,$1E(a0)	bitplane 3
	move.w	#$FFFF,$22(a0)	linepattern
	move.w	#0,$24(a0)	writemode, 0=replace
	dc.w	$a003
	rts
***************************************************************************
getpixel1:
	move.w	#105,contrl
	move.w	#1,contrl+2
	move.w	#0,contrl+4
	move.w	#0,contrl+6
	move.w	#2,contrl+8
	move.w	#1,contrl+12
	move.w	xp1,ptsin
	move.w	yp1,ptsin+2
	jsr	vdi
	move.w	intout+2,pixel1
	rts
***************************************************************************
getpixel2:
	move.w	#105,contrl
	move.w	#1,contrl+2
	move.w	#0,contrl+4
	move.w	#0,contrl+6
	move.w	#2,contrl+8
	move.w	#1,contrl+12
	move.w	xp2,ptsin
	move.w	yp2,ptsin+2
	jsr	vdi
	move.w	intout+2,pixel2
	rts
***************************************************************************
vdi:
	move.l	#vdi_pb,d1
	move.w	#$73,d0
	trap	#2
	rts	
***************************************************************************
checkpix1:
	cmp.w	#12,pixel1
	beq	exit1
	cmp.w	#13,pixel1
	beq	exit1
	cmp.w	#15,pixel1
	beq	exit1
	rts
***************************************************************************
checkpix2:
	cmp.w	#12,pixel2
	beq	exit2
	cmp.w	#13,pixel2
	beq	exit2
	cmp.w	#15,pixel2
	beq	exit2
	rts
***************************************************************************
exit1:
	jsr	waitvbl
	jsr	setred
key1:	jsr	waitvbl
	cmp.b	#57,$fffc02
	bne	key1
	jmp	start
***************************************************************************
exit2:
	jsr	setgreen
keyb:	jsr	waitvbl
	cmp.b	#57,$fffc02
	bne	keyb
	jmp	start
***************************************************************************
exit:
	move.w	#1,fadown
	jsr	waitvbl2
	jsr	fadedown
	cmp.w	#0,addfade
	bne	exit
	move.l	oldvbl,$70.w
	move.l	#$08080000,$ff8800
	move.l	#$09090000,$ff8800
	move.l	#$0a0a0000,$ff8800
	clr.w	-(sp)
	rts
***************************************************************************
initjoy:
	move.w	#34,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,vectab
	move.l	d0,a0
	move.l	24(a0),joyvec
	move.l	#joyread,24(a0)
	move.l	#instr,-(sp)
	move.w	#1,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts
***************************************************************************
joyread:
	move.b 	1(a0),joy
	move.b	2(a0),joy+1
	jsr	getjoy
	rts
***************************************************************************
checkfont:
	add.w	#1,fontcount
	cmpi.w	#4,fontcount
	beq	newchar
	rts
newchar:
	move.w	#0,fontcount
	jsr	char
	jsr	setfont
	rts
***************************************************************************
char:
	move.l	#scrollptr,a0
	move.l 	(a0),a0
	clr.l	d0
	move.b	(a0)+,d0
	move.l	a0,scrollptr
	
	cmpi.b	#$ff,d0
	beq	wrap

	sub.w	#32,d0
	
	cmpi.b	#20,d0
	bge	nexta
	
	muls	#8,d0
	rts
nexta:
	sub.w	#20,d0

	cmpi.b	#20,d0
	bge	nextb

	muls	#8,d0
	add.w	#160*16,d0	
	rts

nextb:
	sub.w	#20,d0
	muls	#8,d0
	add.w	#160*32,d0	
	rts
	
wrap:
	move.l	#scrolltext,scrollptr
	jmp	char
***************************************************************************
setfont:
	lea	font,a0		
	add.w	d0,a0
	move.l	#scrollbuf+160,a1
	move.w	#15,d0
	setfontloop:
		move.w	(a0),(a1)
		move.w	2(a0),2(a1)
		move.w	4(a0),4(a1)
		move.w	6(a0),6(a1)
		add.w	#160,a0
		add.w	#168,a1
		dbf.w	d0,setfontloop
	rts
***************************************************************************
scroll:	
	jsr	scroll1
	jsr	scroll2
	jsr	scroll3
	jsr	scroll4
	rts
***************************************************************************
scroll1:
	move.l	#scrollbuf+168*8-8,a0
	move.w	#7,d0
	distloop1:
		rept	21
		roxl.w	(a0)
		sub.w	#8,a0
		endr	
	dbf.w	d0,distloop1
	rts
scroll2:
	move.l	#scrollbuf+168*8-8,a0
	move.w	#7,d0
	distloop2:
		rept	21
		roxl.w	2(a0)
		sub.w	#8,a0
		endr	
	dbf.w	d0,distloop2
	rts
scroll3:
	move.l	#scrollbuf+168*8-8,a0
	move.w	#7,d0
	distloop3:
		rept	21
		roxl.w	4(a0)
		sub.w	#8,a0
		endr	
	dbf.w	d0,distloop3
	rts
scroll4:
	move.l	#scrollbuf+168*8-8,a0
	move.w	#7,d0
	distloop4:
		rept	21
		roxl.w	6(a0)
		sub.w	#8,a0
		endr	
	dbf.w	d0,distloop4
	rts
***************************************************************************
showscroll:
	move.l	#scrollbuf,a0
	move.l	#$78000+181*160+8*5,a1
	move.w	#7,d0
	showloop:
		rept	10
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		endr
		add.w	#8+10*8,a0
		add.w	#10*8,a1
	dbf.w	d0,showloop
	rts	
***************************************************************************
 section data
scrollptr:	dc.l	scrolltext
scrolltext:	dc.b 	"   WELCOME WORM WARRIORS OF EARTH...THIS BRUTAL GAME WILL DRIVE YOU INSANE,COZ YOU CAN NOT UNDERSTAND HOW WE CAN DO SUCH A LAME GAME...   ANYWAY THE CREDITS IS AT THE TOP OF THIS SCREEN EXCEPT THE MUSIC "
                dc.b    "THAT IN THIS MINI GAME IS MADE BY JOCHEN HIPPEL.THIS SCROLL WILL PROBABLY NOT BE LONG AT ALL COZ WE DON'T THINK ANYONE WILL BOTHER READING THIS CRAP.THIS MINI GAME IS ALSO PROBABLY THE FIRST PART THAT WE HAVE FIXED "
                dc.b    "TOGETHER AND REMOVED ALL BUGS AND WRITTEN A SCROLL TO.IT WAS PUT TOGETHER AT LORD'S PLACE ONE SUNNY DAY IN AUGUST BY CORNY WHILE FEAR WENT TO A 'DIRE STRAITS' CONCERT AND I MADE SOME MORE GRAPHICS FOR THIS DEMO."
                dc.b    "WE DID THIS GAME ABOUT TWO MONTHS BEFORE M DEMO 3 GOT OUT..AN COOL HAD MADE THE SAME CULT GAME,BUT WE THOUGHT OURS WAS COOLER SO WE RELEASE IT ANYWAY..WHO CARES?... NOW MISS WRAPICUM HAS ARRIVED...                     ",$FF
vdi_pb:		dc.l	contrl,intin,ptsin,intout,ptsout
instr:		dc.b	$12,$14
rasters:	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
		dc.w	$110,$110,$110,$110,$010,$010,$010,$010,$010,$010,$011,$010,$010,$010,$010,$010,$010,$010
		dc.w	$220,$220,$220,$220,$120,$020,$020,$020,$020,$021,$022,$021,$020,$020,$020,$020,$020,$020
		dc.w	$330,$330,$330,$330,$230,$030,$030,$030,$031,$032,$033,$032,$031,$030,$030,$030,$030,$030
		dc.w	$440,$440,$440,$440,$340,$240,$140,$041,$042,$043,$044,$043,$042,$041,$040,$040,$040,$040
		dc.w	$551,$550,$550,$550,$450,$350,$251,$152,$053,$054,$055,$054,$053,$052,$051,$050,$050,$050
		dc.w	$662,$661,$660,$660,$560,$461,$362,$263,$164,$065,$066,$065,$064,$063,$062,$061,$060,$060
		dc.w	$773,$772,$771,$770,$671,$572,$473,$374,$275,$176,$077,$076,$075,$074,$073,$072,$071,$070
infopal1:	dc.w	$000,$000,$000,$000
		dc.w	$000,$000,$100,$100
		dc.w	$000,$100,$200,$200
		dc.w	$100,$200,$300,$310
		dc.w	$200,$300,$410,$420
		dc.w	$300,$410,$520,$530
		dc.w	$410,$520,$631,$641
		dc.w	$520,$630,$742,$752
infopal2:	dc.w	$000,$000,$000,$000
		dc.w	$000,$000,$000,$101
		dc.w	$000,$000,$101,$202
		dc.w	$000,$101,$202,$303
		dc.w	$101,$202,$303,$404
		dc.w	$202,$303,$404,$505
infopal3:	dc.w	$000,$000,$000,$000,$000	
		dc.w	$000,$000,$000,$000,$001	
		dc.w	$000,$000,$000,$001,$002	
		dc.w	$000,$001,$001,$002,$003	
		dc.w	$001,$002,$002,$003,$104	
		dc.w	$002,$003,$003,$104,$205	
		dc.w	$003,$104,$014,$215,$316	
fadepal:	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$010,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$200,$020,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$300,$030,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$400,$040,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$500,$050,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$600,$060,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$700,$070,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$711,$171,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$000,$000,$000,$000,$100,$000,$000,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$000,$000,$000,$100,$210,$000,$000,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$000,$000,$100,$210,$321,$000,$000,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$000,$100,$210,$321,$432,$000,$000,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$100,$210,$321,$432,$543,$000,$000,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$000,$000,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$000,$000,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$001,$000,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$002,$001,$000,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$003,$002,$001,$000,$000,$000,$000,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$004,$003,$002,$001,$000,$000,$000,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$005,$004,$003,$002,$001,$000,$001,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$006,$005,$004,$003,$002,$000,$002,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$006,$005,$004,$003,$002,$000,$002,$722,$272,$000
		dc.w	$000,$210,$321,$432,$543,$654,$006,$005,$004,$003,$002,$000,$002,$722,$272,$111
		dc.w	$000,$210,$321,$432,$543,$654,$006,$005,$004,$003,$002,$000,$002,$722,$272,$222
		dc.w	$000,$210,$321,$432,$543,$654,$006,$005,$004,$003,$002,$000,$002,$722,$272,$333
		dc.w	$000,$210,$321,$432,$543,$654,$006,$005,$004,$003,$002,$000,$002,$722,$272,$444
		dc.w	$000,$210,$321,$432,$543,$654,$006,$005,$004,$003,$002,$000,$002,$722,$272,$555
music		incbin  a:\maggmast\jambala.mus
pic:		incbin	a:\maggmast\maggback.pi1
gameover:	incbin	a:\maggmast\gameover.dat
font:		incbin	a:\maggmast\8x8raves.dat
info:		incbin	a:\maggmast\magginfo.pi1
 section bss
scrollbuf:	ds.b	2688
contrl:		ds.b	24
intin:		ds.b	60
ptsin:		ds.b	60
intout:		ds.b	90
ptsout:		ds.b	24
savesuper:	ds.b	4
oldvbl:		ds.b	4
linea		ds.b	4
vectab:		ds.b	4
joyvec:		ds.b	4
oldvbi:		ds.b	4
oldhbi:		ds.b	4
vbiflag:	ds.b	2
dir1:		ds.b	2
xp1:		ds.b	2
yp1:		ds.b	2
xg1:		ds.b	2
yg1:		ds.b	2
pixel1:		ds.b	2
dir2:		ds.b	2
xp2:		ds.b	2
yp2:		ds.b	2
xg2:		ds.b	2
yg2:		ds.b	2
pixel2:		ds.b	2
joy:		ds.b	2
fontcount:	ds.b	2
count:		ds.b	2
waitfade:	ds.b	2
fadown:		ds.b	2
addrast:	ds.b	2
addfade:	ds.b	2
add1:		ds.b	2
add2:		ds.b	2
add3:		ds.b	2
old1b:		ds.b	1
old21:		ds.b	1
old07:		ds.b	1
old09:		ds.b	1
old0f:		ds.b	1
old11:		ds.b	1
old13:		ds.b	1
