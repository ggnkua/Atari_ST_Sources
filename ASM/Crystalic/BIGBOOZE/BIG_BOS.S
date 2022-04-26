***************************************************************************
*                       BIGBOOZE BY:
*
*                   ME SO CORNY AND FEAR...  
***************************************************************************
	jsr	setsuper
	jsr	setscreen
	jsr	setpal
	jsr	fixpal
	jsr	setupsprite
	jsr	rotate
	jsr	clearscreen
	jsr	setpic
	move.l	#xtab,xptr
	move.l	#ytab,yptr
 	JSR	STARTMUSIC
	JSR	INIT
***************************************************************************
mainloop:
	jsr 	waitvbl
*	move.w	#$007,$ff8240
	jsr	incpos
	jsr	setsprite
	JSR	READPSG
	JSR	TEXTSCROLL
	JSR	TEXTSCROLL
	JSR	SHOWSCROLL

	CMP.W	#5,COUNT
	BNE	NONEWFONT
	JSR	SETFONT
	MOVE.W	#0,COUNT
NONEWFONT:
	ADD.W	#1,COUNT
	jsr	screenswap
*	move.w	#$000,$ff8240

	jmp 	mainloop
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
INIT:
	MOVE.L	$70.W,OLDVBL
	MOVE.L	$120.W,OLDHBL
	MOVE.B	$FFFFFA07.W,OLD07
	MOVE.B	$FFFFFA09.W,OLD09
	MOVE.B	$FFFFFA13.W,OLD13
	MOVE.B	$FFFFFA1B.W,OLD1B
	
	MOVE.W	 #$2700,SR
	MOVE.L	 #NEWVBL,$70.W
	MOVE.L	 #NEWHBL,$120.W
	CLR.B	 $FFFFFA07.W	
	CLR.B 	 $FFFFFA09.W
	ORI.B 	 #1,$FFFFFA07.W	
	ORI.B 	 #1,$FFFFFA13.W
	CLR.B 	 $FFFFFA1B.W	
	MOVE.W 	 #$2300,SR	
	RTS
RETINIT:
	MOVE.L	OLDVBL,$70.W
	MOVE.L	OLDHBL,$120.W
	MOVE.B	OLD07,$FFFFFA07.W
	MOVE.B	OLD09,$FFFFFA09.W
	MOVE.B	OLD13,$FFFFFA13.W
	MOVE.B	OLD1B,$FFFFFA1B.W
	RTS
***********************************
NEWVBL:
	MOVE.L	#$ff8240,coladd

	MOVE.L	#RASTER,RASTERPTR

	CLR.B 	$FFFFFA1B.W	
	MOVE.B 	#1,$FFFFFA21.W	
	MOVE.B 	#8,$FFFFFA1B.W	

	JSR	MUSIC+8

	move.w	#1,vbiflag
	RTE			
NEWHBL:
	MOVEM.L	A5-A6,-(SP)

	move.l	coladd,a5
	MOVE.L	RASTERPTR,A6
	MOVE.W	(A6)+,(A5)
	MOVE.L	A6,RASTERPTR

	CMP.W	#$001,(A6)
	BEQ	CHANGECOL	
	MOVEM.L	(SP)+,A5-A6
	BCLR 	#0,$FFFFFA0F.W	
	RTE			
CHANGECOL:
	MOVE.L	#$FF8250,coladd
	MOVE.W	#$000,$FF8240
	MOVEM.L	(SP)+,A5-A6
	BCLR 	#0,$FFFFFA0F.W	
	RTE				
***************************************************************************
waitvbl:
	cmpi.w	#1,vbiflag
	bne 	waitvbl
	move.w	#0,vbiflag
	rts
***************************************************************************
STARTMUSIC:
	MOVEQ	#1,D0
	JSR	MUSIC
	RTS
ENDMUSIC:
	MOVE.L	#$08080000,$FF8800
	MOVE.L	#$09090000,$FF8800
	MOVE.L	#$0A0A0000,$FF8800
	RTS
*******************************
setscreen:
	move.w	#0,-(sp)
	move.l	#$60000,-(sp)
	move.l	#$68000,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	add.l	#12,sp
	rts
***************************************************************************
setpal:
	lea	pic+2,a0		
	move.l	#$ff8240,a1
	rept	8
		move.l	(a0)+,(a1)+
		endr
	MOVE.W	#$000,$FF8250
	rts
***************************************************************************
fixpal:
*	move.l	#RASTER2,a0
*	rept	191
*	move.w	$ff8248,(a0)+
*	endr
	rts
***************************************************************************
setupsprite:
	lea	pic+34,a0		
	move.l	#$68000,a1
	move.w	#40*74,d0
	setuploop:
		move.l	(a0)+,(a1)+
		dbf.w	d0,setuploop
	rts
***************************************************************************
setpic:
	lea	pic+34+160*150,a0		
	move.l	#$60000+160*33,a1
	move.l	#$68000+160*33,a2
	move.w	#40*38,d0
	setpicloop:
		move.l	(a0)+,d1
		move.l	d1,(a1)+
		move.l	d1,(a2)+
		dbf.w	d0,setpicloop
	rts
***************************************************************************
clearscreen:
	move.l	#$60000,a0
	move.w	#16000,d0
	clearloop:
		move.l	#0,(a0)+
		dbf.w	d0,clearloop
	rts
***************************************************************************
rotate:
	lea	spritebuf+14*4*6,a1
	move.w	#15,d0
	rotateloop:
		jsr	rotatesave
		jsr	rotatescroll
		
	dbf.w	d0,rotateloop	
	rts
***************************************************************************
rotatescroll:
	move.l	#$68000,a0
	move.w	#73,d1
	rotatescrolloop:
		rept	14
		roxr.w	(a0)
		add.w	#8,a0
		endr
		sub.w	#8*14,a0
		rept	14
		roxr.w	2(a0)
		add.w	#8,a0
		endr
		sub.w	#8*14,a0
		rept	14
		roxr.w	4(a0)
		add.w	#8,a0
		endr
		sub.w	#8*14,a0
		rept	14
		roxr.w	6(a0)
		add.w	#8,a0
		endr
		add.w	#160-8*14,a0
	dbf.w	d1,rotatescrolloop	
	rts
***************************************************************************
rotatesave:
	move.l	#$68000,a0
	move.w	#73,d1
	rotatesaveloop:
		rept	14
		move.w	(a0),(a1)
		move.w	2(a0),2(a1)
		move.w	4(a0),4(a1)
		add.w	#8,a0
		add.w	#6,a1
		endr
		add.w	#160-8*14,a0
		dbf.w	d1,rotatesaveloop
	rts
***************************************************************************
setsprite:
	move.l	$44e,a1
	move.w	ypos,d0
	muls	#160,d0
	add.l	d0,a1
	move.w	xpos,d0
	move.w	d0,d1
	and.w	#$fff0,d0
	divu.w	#2,d0
	add.w	d0,a1
	lea	spritebuf,a0
	and.w	#$000f,d1
	muls	#14*74*6,d1
	add.l	d1,a0
	move.w	#76,d0
	setspriteloop:
		rept	14
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		addq.w	#2,a1
		endr
		add.w	#160-8*14,a1
		dbf.w	d0,setspriteloop
	rts
***************************************************************************
incpos:
	move.l	xptr,a0
	move.w	(a0)+,xpos
	move.l	a0,xptr
	cmpi.w	#-1,xpos
	bne	noxwrap
	move.l	#xtab,xptr
	jmp	incpos
noxwrap:
	move.l	yptr,a0
	move.w	(a0)+,ypos
	move.l	a0,yptr
	cmpi.w	#-1,ypos
	bne	noywrap
	move.l	#ytab,yptr
	jmp	noxwrap
noywrap:
	rts
***************************************************************************
screenswap:
	cmpi.l	#$68000,$44e
	bne	logphys	
	physlog:
		move.w	#-1,-(sp)
		move.l	#$68000,-(sp)
		move.l	#$60000,-(sp)
		move.w	#$5,-(sp)
		trap	#14
		add.l	#12,sp
		rts
	logphys:
		move.w	#-1,-(sp)
		move.l	#$60000,-(sp)
		move.l	#$68000,-(sp)
		move.w	#$5,-(sp)
		trap	#14
		add.l	#12,sp
	rts
***************************************************************************
TEXTSCROLL:
	MOVE.L	#SCRAREA,A1
	MOVE.W	#7,D1
SCRLOOP:
	ROXL.W	160(A1)
	ROXL.W	152(A1)
	ROXL.W	144(A1)
	ROXL.W	136(A1)
	ROXL.W	128(A1)
 	ROXL.W	120(A1)
	ROXL.W	112(A1)
	ROXL.W	104(A1)
	ROXL.W	96(A1)
	ROXL.W	88(A1)
	ROXL.W	80(A1)
	ROXL.W	72(A1)
	ROXL.W	64(A1)
	ROXL.W	56(A1)
	ROXL.W	48(A1)
	ROXL.W	40(A1)
	ROXL.W	32(A1)
	ROXL.W	24(A1)
	ROXL.W	16(A1)
	ROXL.W	8(A1)
	ROXL.W	(A1)
	ADD.W	#168,A1
	DBF.W	D1,SCRLOOP
	RTS
*******************************
SHOWSCROLL:
	MOVE.L	#SCRAREA,A1
	MOVE.L	$44e,a2
	add.w	#160*192+6,A2
	MOVE.W	#7,D1
SHOWLOOP:
	MOVE.W	(A1),(A2)
	MOVE.W	8(A1),8(A2)
	MOVE.W	16(A1),16(A2)
	MOVE.W	24(A1),24(A2)
	MOVE.W	32(A1),32(A2)
	MOVE.W	40(A1),40(A2)
	MOVE.W	48(A1),48(A2)
	MOVE.W	56(A1),56(A2)
	MOVE.W	64(A1),64(A2)
	MOVE.W	72(A1),72(A2)
	MOVE.W	80(A1),80(A2)
	MOVE.W	88(A1),88(A2)
	MOVE.W	96(A1),96(A2)
	MOVE.W	104(A1),104(A2)
	MOVE.W	112(A1),112(A2)
	MOVE.W	120(A1),120(A2)
	MOVE.W	128(A1),128(A2)
	MOVE.W	136(A1),136(A2)
	MOVE.W	144(A1),144(A2)
	MOVE.W	152(A1),152(A2)
	ADD.W	#168,A1
	ADD.W	#160,A2
	DBF.W	D1,SHOWLOOP
	RTS
*******************************
SETFONT:
	MOVE.L	TEXTPTR,A3
	CLR.W	D1
	MOVE.B	(A3)+,D1
	CMP.W	#$FF,D1
	BEQ	TEXTWRAP

	SUB.W	#32,D1
	MULS	#2,D1

	MOVE.L	#FONTTAB,A1
	ADD.W	D1,A1
	MOVE.W	(A1)+,D1
	MOVE.L	#pic+34+160*100,A1
	ADD.W	D1,A1
	MOVE.L	#SCRAREA+160,A2
	REPT	8
	MOVE.W	(A1),(A2)
	ADD.W	#160,A1
	ADD.W	#168,A2
	ENDR

	MOVE.L	A3,TEXTPTR
	RTS	
TEXTWRAP:
	MOVE.L	#SCROLLTEXT,TEXTPTR
	JMP	SETFONT
***************************************************************************
READPSG:
	MOVEQ.W #0,D0
	MOVEQ.W #0,D1
	MOVEQ.W #0,D2
	MOVE.B 	#8,$FFFF8800.W  
	MOVE.B 	$FFFF8800.W,D0
	MOVE.B 	#9,$FFFF8800.W  
	MOVE.B 	$FFFF8800.W,D1
	MOVE.B 	#10,$FFFF8800.W 
	MOVE.B 	$FFFF8800.W,D2
	BTST 	#4,D0           
	BEQ 	.L1
	MOVE.B 	#10,D0        
.L1	BTST 	#4,D1    	
       	BEQ 	.L2
	MOVE.B 	#10,D1
.L2	BTST	#4,D2		
	BEQ 	.L3
	MOVE.B  #10,D2
.L3	ADD.B   D0,D0		
	ADD.B   D1,D1
	ADD.B	D2,D2

	MOVE.L	$44E,A0
	ADD.W	#160*193+24,A0
	MOVE.W	#-1,D3
	MULS	#2,D0
PUTLOOP:
	MOVE.W	D3,6(A0)
	MOVE.W	D3,14(A0)
	MOVE.W	D3,22(A0)
	MOVE.W	D3,30(A0)
	MOVE.W	D3,166(A0)
	MOVE.W	D3,174(A0)
	MOVE.W	D3,182(A0)
	MOVE.W	D3,190(A0)
	SUB.W	#320,A0
	DBF.W	D0,PUTLOOP

	MOVE.W	#0,D3
	MOVE.L	$44E,A1
	ADD.W	#160*72+24,A1
ERASELOOP:
	MOVE.W	D3,6(A0)
	MOVE.W	D3,14(A0)
	MOVE.W	D3,22(A0)
	MOVE.W	D3,30(A0)
	MOVE.W	D3,166(A0)
	MOVE.W	D3,174(A0)
	MOVE.W	D3,182(A0)
	MOVE.W	D3,190(A0)
	SUB.W	#320,A0
	CMP.L	A1,A0
	BGE	ERASELOOP

	MOVE.L	$44E,A0
	ADD.W	#160*193+64,A0
	MOVE.W	#-1,D3
	MULS	#2,D1
PUTLOOP2:
	MOVE.W	D3,6(A0)
	MOVE.W	D3,14(A0)
	MOVE.W	D3,22(A0)
	MOVE.W	D3,30(A0)
	MOVE.W	D3,166(A0)
	MOVE.W	D3,174(A0)
	MOVE.W	D3,182(A0)
	MOVE.W	D3,190(A0)
	SUB.W	#320,A0
	DBF.W	D1,PUTLOOP2

	MOVE.W	#0,D3
	MOVE.L	$44E,A1
	ADD.W	#160*72+64,A1
ERASELOOP2:
	MOVE.W	D3,6(A0)
	MOVE.W	D3,14(A0)
	MOVE.W	D3,22(A0)
	MOVE.W	D3,30(A0)
	MOVE.W	D3,166(A0)
	MOVE.W	D3,174(A0)
	MOVE.W	D3,182(A0)
	MOVE.W	D3,190(A0)
	SUB.W	#320,A0
	CMP.L	A1,A0
	BGE	ERASELOOP2

	MOVE.L	$44E,A0
	ADD.W	#160*193+104,A0
	MOVE.W	#-1,D3
	MULS	#2,D2
PUTLOOP3:
	MOVE.W	D3,6(A0)
	MOVE.W	D3,14(A0)
	MOVE.W	D3,22(A0)
	MOVE.W	D3,30(A0)
	MOVE.W	D3,166(A0)
	MOVE.W	D3,174(A0)
	MOVE.W	D3,182(A0)
	MOVE.W	D3,190(A0)
	SUB.W	#320,A0
	DBF.W	D2,PUTLOOP3

	MOVE.W	#0,D3
 	MOVE.L	$44E,A1
	ADD.W	#160*72+104,A1
ERASELOOP3:
	MOVE.W	D3,6(A0)
	MOVE.W	D3,14(A0)
	MOVE.W	D3,22(A0)
	MOVE.W	D3,30(A0)
	MOVE.W	D3,166(A0)
	MOVE.W	D3,174(A0)
	MOVE.W	D3,182(A0)
	MOVE.W	D3,190(A0)
	SUB.W	#320,A0
	CMP.L	A1,A0
	BGE	ERASELOOP3
	RTS	
***************************************************************************
savesuper:	dc.l	0
vbiflag:	dc.w	0
OLDVBL:		DC.L	0
OLDHBL:		DC.L	0
OLD07:		DC.B	0
OLD09:		DC.B	0
OLD13:		DC.B	0
OLD1B:		DC.B	0
RASTERPTR:	DC.L	0
RASTERPTR2:	DC.L	0
xptr:		dc.l	0
yptr:		dc.l	0
xpos:		dc.w	0
ypos:		dc.w	0
xtab:		include	a:\bigbooze\sprxtab.dat
ytab:		include	a:\bigbooze\sprytab.dat
pic:		incbin	a:\bigbooze\big.pi1
MUSIC:		INCBIN	a:\bigbooze\max_tlb.mus
COUNT:		DC.W	0
coladd:		dc.l	0
TEXTPTR:	DC.L	SCROLLTEXT
FONTTAB:
 * SPACE OCH UPPèT
	DC.W	5152,2632,2648,5152,5152,5152,5152,5152,2608,2616,5152,5152,2656,5152,2624,5152
 * SIFFROR
	DC.W    5136,2664,2672,2680,2688,2696,2704,2712
	DC.W	5120,5128
 * TECKEN OCH UPPèT
 	DC.W	5152,5152,5152,5152,5152,2640,5152	
 * A TILL Z 
	DC.W	0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152
	DC.W	2560,2568,2576,2584,2592,2600
		EVEN
SCROLLTEXT:	
	DC.B	'YO!  FEAR! DONT COME NEAR.... FAN VA BRA VA!!!   ',$FF
		EVEN
SCRAREA:
	DS.B	160*20
RASTER:
	DC.W	$100,$100,$100,$100,$100,$100,$100,$100,$200,$100
	DC.W	$200,$200,$200,$200,$200,$200,$200,$200,$300,$200
	DC.W	$300,$300,$300,$300,$300,$300,$300,$300,$400,$300
	DC.W	$400,$400,$400,$400,$400,$400,$400,$400,$500,$400
	DC.W	$500,$500,$500,$500,$500,$500,$500,$500,$600,$500
	DC.W	$600,$600,$600,$600,$600,$600,$600,$600,$700,$600
	DC.W	$700,$700,$700,$700,$700,$700,$700,$700,$711,$700
	DC.W	$001,$001,$001,$001,$001,$001,$001,$001,$002,$001
	DC.W	$002,$002,$002,$002,$002,$002,$002,$002,$003,$002
	DC.W	$003,$003,$003,$003,$003,$003,$003,$003,$004,$003
	DC.W	$004,$004,$004,$004,$004,$004,$004,$004,$005,$004
	DC.W	$005,$005,$005,$005,$005,$005,$005,$005,$006,$005
	DC.W	$006,$006,$006,$006,$006,$006,$006,$006,$007,$006
	DC.W	$007,$007,$007,$007,$007,$007,$007,$007,$117,$007
	DC.W	$117,$117,$117,$117,$117,$117,$117,$117,$227,$117
	DC.W	$227,$227,$227,$227,$227,$227,$227,$227,$337,$227
	DC.W	$337,$337,$337,$337,$337,$337,$337,$337,$447,$337
	DC.W	$447,$447,$447,$447,$447,$447,$447,$447,$557,$447
	DC.W	$557,$557,$557,$557,$557,$557,$557,$000,$000,$000
	DC.W	$000,$610,$610,$720,$720,$730,$730,$640,$640,$000

	 section bss

spritebuf:	ds.w	16*14*74*6+14*4*6
                