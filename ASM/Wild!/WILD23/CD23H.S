


	

;Constant Offsets from start of DRIVER.BIN
_Install equ	$0000		sets up timer A & C vectors & installs
_DeInstall equ	$0004		restores old vectors etc
_Start	equ	$0008		start playing tune (_SongAddr,_VoiceAddr)
_Stop	equ	$000C		stop playing current tune
_Restart equ	$0010		restart playing current tune
_SongAddr equ	$002C	.l	holds address of song
_VoiceAddr equ	$0030	.l	holds address of 20-voice kit
_IRQmask equ	$0038	.w	holds normal IRQ mask to write to MFP
_SoundType equ	$003a	.w	holds low level sound driver type number

;case of _SoundType.w=
	;[0] => internal
	;[1] => Replay 8-bit
	;[2] => Replay 12-bit 
	;[3] => Playbackint
	;[4] => STE sample hardware 

Prog

	move.l	4(a7),a3		base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp

	move.l	#0,-(sp)		supervisor on for colour
	move.w	#$20,-(sp)		swapping
	trap	#1
	lea	6(sp),sp

	dc.w	$a00a			mouse off	

	move.w 	#2,-(sp)
        trap   	#14     
       	addq.l 	#2,a7
       	move.l 	d0,dummy

	move.b	#2,$ff820a
	move.w	#$000,backg

	move.l	#$ff8240,a1
	move.l	#FromScreen+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	move.w	#0,-(sp)
	move.l	#$76000,-(sp)
	move.l	#$76000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#8000,d0
	lea	$44e.w,a0
	move.l	(a0),a0
	lea	FromScreen+34,a1
nextlb	MOVE.L	(a1)+,(a0)+
	dbf	d0,nextlb

again:  move.l	#line,mespt
	jsr	hblon
	jsr	install
	jsr	play
keyprs:
	move.w	#7,-(sp)	read keyboard
	trap	#1
	lea	2(sp),sp

	cmp.b	#'1',d0		do selection
	beq	Run1
	cmp.b	#'2',d0
	beq	Run2
	cmp.b	#'3',d0
	beq	Run3
	cmp.b	#'4',d0
	beq	Run4
	cmp.b	#'0',d0
	beq	zero

FUNKEY	SWAP	D0
	SUB	#$3A,D0

	cmpi.b	#1,d0
	bne	mus2
	jsr	stopsong
	lea	song1_s,a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	jsr	play
	bra	aszdf
mus2	cmpi.b	#2,d0
	bne	mus3
	jsr	stopsong
	lea	song2_s,a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	jsr	play
	bra	aszdf
mus3	cmpi.b	#3,d0
	bne	mus4
	jsr	stopsong
	lea	song3_s,a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	jsr	play
	bra	aszdf
mus4	cmpi.b	#4,d0
	bne	mus5
	jsr	stopsong
	lea	song4_s,a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	jsr	play
	bra	aszdf
mus5	cmpi.b	#5,d0
	bne	mus6
	jsr	stopsong
	lea	song5_s,a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	jsr	play
	bra	aszdf
mus6	cmpi.b	#6,d0
	bne	aszdf
	jsr	stopsong
	lea	song6_s,a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	jsr	play
	
aszdf	jmp	keyprs

RunProg	MACRO	
	jsr	hbloff
	move.w	#0,-(sp)
	move.l	dummy,-(sp)
	move.l	dummy,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	move.l 	#\1,-(sp)
	move.w 	#$3b,-(sp)
	trap 	#1
	addq.l 	#6,a7
	move.l 	#Empty,-(sp)
	move.l 	#Empty,-(sp)
	move.l 	#\2,-(sp)
	move.w 	#0,-(sp)
	move.w 	#$4b,-(sp)
	trap 	#1
	lea 	16(a7),a7
	
	move.l	#16,a0
	move.w	#$777,(a0)+		screen colour
	move.w	#$000,(a0)+		reset normal
	move.w	#$000,(a0)+		screen colour
	move.w	#$000,(a0)+
	move.w	#$000,(a0)+
	
	move.l	#16,-(sp)
	move.w	#6,-(sp)
	trap	#14
	add.l	#6,sp
			
	ENDM

Run1:	jsr	deinstall
	RunProg	Emp,prog_1
Run2:	jsr	deinstall
	RunProg	Emp,prog_2
Run3:	jsr	deinstall
	RunProg	Emp,prog_3
Run4:	jsr	deinstall
	RunProg	Emp,prog_4

star:	jsr	deinstall
	jsr	hbloff
	clr.w	-(sp)
	trap	#1
zero:	
	eori	#$012,backg
	jmp	aszdf


hblon:	move.l	$120,oldtb
	move.l	$70,old4
	move.l	$70,new4b+2
	move.b	$fffffa07,old07
	move.b	$fffffa09,old09
        move.b 	$fffffa0f,old0f
        move.b 	$fffffa11,old11
        move.b 	$fffffa1b,old1b
	and.b	#$df,$fffa09
	and.b	#$fe,$fffa07
	move.l	#killborder,$120
	move.l	#new4,$70
	or.b	#1,$fffffa07
	or.b	#1,$fffffa13
	rts			; starts the hb interupt

hbloff:	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.b	old07(pc),$fffffa07
	move.b	old09(pc),$fffffa09
        move.b 	old0f(pc),$fffffa0f
        move.b 	old11(pc),$fffffa11
        move.b 	old1b(pc),$fffffa1b
	move.l	oldtb,$120
	move.l	old4,$70
	move.w	(sp)+,sr
	rts			; stops the hb int + clear sound

old4	dc.l	0
oldtb	dc.l	0
old07	dc.b	0
old09	dc.b	0
old0f:  dc.b   	0
old11:  dc.b   	0
old1b:  dc.b   	0


        even

; This is the new VBL handler
new4:	movem.l	d0-d7/a0-a4,-(sp)
	move.l	#$ff8240,a1
	move.l	#FromScreen+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	clr.b   $fffffa1b.w
        move.b  #174,$fffffa21
        move.b  #8,$fffffa1b
        move.l  #killborder,$120	; Timer B vector

morepix:
	move.w	delcon,d0
	subq.w	#2,d0
	beq	mskro
	move.w	d0,delcon
	jmp	endskro
mskro	move.w	_left,d1
	dbf	d1,noneed
	move.l  mespt,a0
        clr.l   d0
	move.b  (a0)+,d0
	cmp.b	#'*',d0
	bne	gstring
	move.b	(a0)+,d0
	move.w	d0,delcon
	move.l	a0,mespt
	jmp	morepix
gstring	cmp.b  	#255,d0
        bne    	trebx
	move.b	#'[',d0
	move.l	#line,a0
trebx:  cmp.b	#' ',d0
	bne	goony1
	move.b	#'\',d0
goony1	cmp.b	#'.',d0
	bne	goony2
	move.b	#'[',d0
goony2	sub.b   #'A',d0
        mulu    #300,d0
        add.l   #ch,d0
	move.l	a0,mespt
        move.l  d0,a0
	move.l	#_blk,a1
	move.w	#74,d2
loup1	move.l	(a0)+,(a1)+
	dbf	d2,loup1
	move.w	#3,d1
noneed:	move.w	d1,_left
	move.l	#_blk+3,a1
	sub.w	d1,a1
	move.l	#$76000+28000,a2
	move.w	#2,d0
nexbp	move.l	a2,a0
	lea	2(a2),a2
	move.w	#24,d1
nexln	move.b	1(a0),(a0)
	move.b	8(a0),1(a0)
	move.b	9(a0),8(a0)
	move.b	16(a0),9(a0)
	move.b	17(a0),16(a0)
	move.b	24(a0),17(a0)
	move.b	25(a0),24(a0)
	move.b	32(a0),25(a0)
	move.b	33(a0),32(a0)
	move.b	40(a0),33(a0)
	move.b	41(a0),40(a0)
	move.b	48(a0),41(a0)
	move.b	49(a0),48(a0)
	move.b	56(a0),49(a0)
	move.b	57(a0),56(a0)
	move.b	64(a0),57(a0)
	move.b	65(a0),64(a0)
	move.b	72(a0),65(a0)
	move.b	73(a0),72(a0)
	move.b	80(a0),73(a0)
	move.b	81(a0),80(a0)
	move.b	88(a0),81(a0)
	move.b	89(a0),88(a0)
	move.b	96(a0),89(a0)
	move.b	97(a0),96(a0)
	move.b	104(a0),97(a0)
	move.b	105(a0),104(a0)
	move.b	112(a0),105(a0)
	move.b	113(a0),112(a0)
	move.b	120(a0),113(a0)
	move.b	121(a0),120(a0)
	move.b	128(a0),121(a0)
	move.b	129(a0),128(a0)
	move.b	136(a0),129(a0)
	move.b	137(a0),136(a0)
	move.b	144(a0),137(a0)
	move.b	145(a0),144(a0)
	move.b	152(a0),145(a0)
	move.b	153(a0),152(a0)
	move.b	(a1),153(a0)
	lea	160(a0),a0
	lea	4(a1),a1
	dbf	d1,nexln	
	dbf	d0,nexbp
endskro
        movem.l (sp)+,d0-d7/a0-a4       

new4b:  jmp	$12345678

killborder
        movem.l	d0-d1/a0-a1,-(sp)
;	move.w	backg,$ffff8240.w
        move.w 	#$fa21,a1
        clr.b	-6(a1)
	move.b	#175,(a1)
        move.b  #8,$fffffa1b.w
	move.b  (a1),d0
wait4:  cmp.b   (a1),d0		; wait last scanline
        beq     wait4		
        ;clr.b   $ffff820a.w     ;60 Hz
        ;moveq   #4,d0
;nopi2:  ;nop			; wait a while
        ;dbf     d0,nopi2
        ;move.b  #2,$ffff820a.w  ;50 Hz
	move.l	#$ff8240,a0
	;move.b	(a1),d0
del	;cmp.b	(a1),d0
	;beq	del
	move.w	backg,(a0)+
	move.w	#$222,(a0)+
	move.w	#$333,(a0)+
	move.w	#$444,(a0)+
	move.w	#$555,(a0)+
	move.w	#$666,(a0)+
	move.w	#$777,(a0)+
	move.w	#$500,(a0)+

        bclr    #0,$fffffa0f.w  ;end of interrupt
        movem.l (sp)+,d0-d1/a0-a1       
        rte




_left	dc.w	0
_blk	ds.w	300            
delcon	dc.w	2
mespt   dc.l	line
dummy   dc.l	0
backg	ds.w	1
hertz	ds.b	1

line	incbin	"23st.doc"
	dc.b	255

	ds.l	100	stack space
pal	ds.w	16
mystack	ds.w	1	(stacks go backwards)
ch	EVEN
	INCBIN	'yyyy.fnt'
FromScreen
	INCBIN	'cd23pica.pi1'

Emp	dc.b	'\',0
Empty	dc.b 	0
prog_1	dc.b	'\rodland.twb',0
prog_2	dc.b	'\cad_pay.twb',0
prog_3	dc.b	'\cad_sup.twb',0
prog_4	dc.b	'\desktop',0
	even

**********************************************************************

*quartet routines

;---------------------------------------------------------------------
install:

	lea	keydat,a0
	move.b	#$12,(a0)
	bsr	keysend

	lea	sing_s,a6		get playback routine start address
	move.w	#$1f64,_IRQmask(a6)	; stick $40 in for keyboard only
	move.w	#0,_SoundType(a6)	default, ie internal sound
	jsr	_Install(a6)

	lea	song6_s,a5		address of song to play ->A5
	move.l	a5,_SongAddr(a6)	inform system of where song is
	lea	voice_s,a5		address of voiceset to use ->A5
	move.l	a5,_VoiceAddr(a6)	...and where current kit is!
	
	rts
;---------------------------------------------------------------------

play:	
	lea	sing_s,a6
	jsr	_Start(a6)		let's go!

	rts

;---------------------------------------------------------------------

deinstall:
		
	lea	sing_s,a6
	jsr	_DeInstall(a6)


* Just turn the mouse back on

	lea	keydat,A0
	move.b	#$8,(a0)
	bsr	keysend

	rts

;---------------------------------------------------------------------

keysend:
	pea	keydat
	move.w	#0,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

keydat	dc.w	0

;----------------------------------------------------------------------


stopsong
	lea	sing_s,a6
	jmp	_Stop(a6)		stop!

	rts

;-------------------------------------------------------------------


restartsong
	;should have started (& stopped) a song before calling this!
	;but the program double-checks anyway
	lea	sing_s,a6
	jmp	_Restart(a6)		restart!

	rts

;-------------------------------------------------------------------

*********************************************************************


* NB -- The following could be loaded into memory by the program
*       I just find it convienient to binary include them


* include the player binary code
sing_s
	incbin	rob5.bin
	even


* include the songs and voiceset

song1_s	incbin	thenight.4v
	even

song2_s	incbin	cool.4v
	even

song3_s	incbin	theend2.4v
	even

song4_s	incbin	paninaro.4v
	even

song5_s	incbin	start.4v
	even

song6_s	incbin	quovadis.4v
	even

voice_s	incbin	mindbomb.set
	even

old_sp	DS.L	1


 
