	jmp	main(pc)
save_ints
	move.l	$70.w,oldvbl
	rts
init_ints
	move.l	#vbi,$70.w
	rts
ret_ints
	move.l	oldvbl,$70.w
	rts
oldvbl
	dc.l	0
main
	pea	0			*supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,physbase
	move.l	usp,a0			*save usp
	move.l	a0,save_usp
	move.l	$44e,scrbase

	jsr	save_ints

	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	jsr	scrlinit
	
	jsr	init_ints			*init. interrupts
	clr.w	wfnc

	lea	font+2,a0
	move.l	#$ff8240,a1
	rept	8
	move.l	(A0)+,(a1)+
	endr

demo_loop	cmp.w	#1,wfnc			*wait for video
	bne	demo_loop
	clr.w	wfnc

	move.w	#$700,$ff8240	
	jsr	plane4
	move.w	#$000,$ff8240	
	
*	cmp.b	#185,$fffc02
*	beq	quitfix
	jmp	demo_loop
	
*****************************************************
plane4	move.l	scrbase,a0
	add.l	#160*133,a0
	move.w	#38,d1
nextline	movep.l	1(a0),d0		;byte 1-8 av 39
	movep.l	d0,(a0)
	movep.l	8(a0),d0
	movep.l	d0,1(a0)
	movep.l	9(a0),d0
	movep.l	d0,8(a0)
	movep.l	16(a0),d0
	movep.l	d0,9(a0)
	movep.l	17(a0),d0
	movep.l	d0,16(a0)
	movep.l	24(a0),d0
	movep.l	d0,17(a0)
	movep.l	25(a0),d0
	movep.l	d0,24(a0)
	movep.l	32(a0),d0
	movep.l	d0,25(a0)
	movep.l	33(a0),d0		;byte 9-16 av 39
	movep.l	d0,32(a0)
	movep.l	40(a0),d0
	movep.l	d0,33(a0)
	movep.l	41(a0),d0
	movep.l	d0,40(a0)
	movep.l	48(a0),d0
	movep.l	d0,41(a0)
	movep.l	49(a0),d0
	movep.l	d0,48(a0)
	movep.l	56(a0),d0
	movep.l	d0,49(a0)
	movep.l	57(a0),d0
	movep.l	d0,56(a0)
	movep.l	64(a0),d0
	movep.l	d0,57(a0) 
	movep.l	65(a0),d0		;byte 17-24 av 39
	movep.l	d0,64(a0)
	movep.l	72(a0),d0
	movep.l	d0,65(a0)
	movep.l	73(a0),d0
	movep.l	d0,72(a0)
	movep.l	80(a0),d0
	movep.l	d0,73(a0)
	movep.l	81(a0),d0
	movep.l	d0,80(a0)
	movep.l	88(a0),d0
	movep.l	d0,81(a0)
	movep.l	89(a0),d0
	movep.l	d0,88(a0)
	movep.l	96(a0),d0
	movep.l	d0,89(a0) 
	movep.l	97(a0),d0		;byte 25-32 av 39
	movep.l	d0,96(a0)
	movep.l	104(a0),d0
	movep.l	d0,97(a0)
	movep.l	105(a0),d0
	movep.l	d0,104(a0)
	movep.l	112(a0),d0
	movep.l	d0,105(a0)
	movep.l	113(a0),d0
	movep.l	d0,112(a0)
	movep.l	120(a0),d0
	movep.l	d0,113(a0)
	movep.l	121(a0),d0
	movep.l	d0,120(a0)
	movep.l	128(a0),d0
	movep.l	d0,121(a0)
	movep.l	129(a0),d0		;byte 33-39 av 39
	movep.l	d0,128(a0)
	movep.l	136(a0),d0
	movep.l	d0,129(a0)
	movep.l	137(a0),d0
	movep.l	d0,136(a0)
	movep.l	144(a0),d0
	movep.l	d0,137(a0)
	movep.l	145(a0),d0
	movep.l	d0,144(a0)
	movep.l	152(a0),d0
	movep.l	d0,145(a0)
	movep.l	153(a0),d0
	movep.l	d0,152(a0)
	lea	160(a0),a0
	dbra.w	d1,nextline
	addq.b	#$01,stepcount
	cmp.b	#$04,stepcount
	bne.w	jump1
	jsr	nextchar
	jmp	plup
jump1	cmp.b	#$02,stepcount
	beq.w	blup1
	addq.l	#$1,fontdat
	jmp	plup
blup1	addq.l	#$7,fontdat
plup	move.l	scrbase,a1
	add.l	#160*133+152,a1

	move.l	fontdat,a0
	move.w	#38,d0 
moredat	movep.l	(a0),d1
	movep.l	d1,(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	dbra.w	d0,moredat
	rts
	
scrlinit
	move.l	#font+34,fontstart
	move.l	#scrltxt,txtcount
	move.b	#$03,stepcount
	rts
*******************************	4plane32line-scroll-subs
nextchar	
	clr.b	stepcount
	clr.l	d0
	addq.l	#$1,txtcount
	move.l	txtcount,a0
	move.b	(a0),d0
	sub.b	#32,d0
	cmp.b	#$d0,d0
	bne	jump2
	jsr	scrlwrap
jump2	clr.l	flum
	mulu	#$4,d0
	move.w	d0,flum+2
	move.b	#$00,flum+2
	move.l	flum,d0
	move.l	fontstart,d1
	lea	fontvect,a0
	add.l	d0,a0
	add.l	(a0),d1
	move.l	d1,fontdat
	rts
scrlwrap	lea	txtcount,a0
	lea	scrltxt,a1
	move.l	a1,(a0)
	move.l	(a0),d0
	move.l	d0,a0
	move.l	#$00000000,d0
	move.b	(a0),d0
	sub.b	#32,d0
	rts
**********			4plane32line-scroll-data
scrbase		ds.l	1 
flum		ds.l	1
fontstart	ds.l	1
txtcount	ds.l	1
stepcount	ds.l	1
fontdat		ds.l	1
font
	incbin	a:\cuddly.pi1
fontvect
	dc.l	18800,12592,18800,18800,18800,18800,18800,12608,18800,18800
	dc.l	18800,18800,19360,12624,12576,18800,18800,18800,18800,18800
	dc.l	18800,18800,18800,18800,18800,18800,18800,18800,18800,18800
	dc.l	18800,18800,18800,0,$10,$20,$30,$40,$50,$60
	dc.l	$70,$80,$90,6240,6256,6272,6288,6304,6320,6336
	dc.l	6352,6368,6384,12480,12496,12512,12528,12544,12560,12576
	dc.l	18800,18800,18800,18800,18800,18800,18800,18800,18800,18800
	dc.l	18800,18800,18800,18800,18800,18800,18800,18800,18800,18800
	dc.l	18800,18800,18800,18800,18800,18800,18800,18800,18800,18800

scrltxt
 DC.B	"  AA BB CC DD EE FF GG HH II JJ KK LL MM NN OO PP QQ RR SS TT UU VV WW XX YY ZZ .. !! '' -- ,,      "


	dc.b	$f0
	even
vbi
	movem.l	d0-d5/a0-a1,-(sp)		*save registers
	move.w	#1,wfnc			*set video flag
	movem.l	(sp)+,d0-d5/a0-a1		*pop registers
	rte
save_usp	dc.l	0
physbase	ds.l    1
wfnc		dc.w	0
save_stk	dc.l	0
save_stk	dc.l	0
c.l	0
physb