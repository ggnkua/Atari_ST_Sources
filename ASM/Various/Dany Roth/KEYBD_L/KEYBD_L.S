*	A very simple acc to change keyboard layout
*	developed using devpacTT v3.01 by Dany Roth
*	ZÅrich Switzerland 07.31.1991
*	works on any TOS version (cause it's a simple acc)
*	The code is self explanatory
	
	OUTPUT	.ACC
	include	gemmacro.s
* the program proper
start	move.l	#mystack,a7		must have a stack!
	appl_init
	move.w	d0,ap_id		store the application id

* start by installing me in the Desk menu
	menu_register	ap_id,#mymenu
	lea	startp,a4		initialize path string
	lea	path,a3
	jsr	copy
	lea	filename,a3
	move.b	#0,(a3)
	
	* get actual drive
	move.w	#$19,-(sp)
	trap	#1		Dgetdrv Gemdos 25
	addq.l	#2,sp
	
	lea	path,a3
	add.b	#'A',d0		A=0,B=1.....
	move.b	d0,(a3)		A,C... actual drive


* the main loop of the application
* the only interesting event is ACC_OPEN
waitforevent
	evnt_mesag	#messagebuf
	move.l	#messagebuf,a0
	move.w	(a0),d0			message type
	cmp.w	#40,d0
	beq	open_acc
* check others here
	bra.s	waitforevent

* here when I have to Open
open_acc
	form_alert	#1,#myalert
	cmp.w	#2,int_out		was it Load selected
	beq	load_fnt		yes so jump to load_fnt
System
	move.w	#$18,-(sp)		no, reset to system layout
	trap	#14			Xbios Bioskeys
	addq.l	#2,sp
	bra	waitforevent
load_fnt
	fsel_input	#path,#filename
	cmp.w	#0,int_out		0 in case of error
	beq	waitforevent
	cmp.w	#0,int_out+2		0=cancel 1=ok selected
	beq	waitforevent
	lea	helpname,a3
	lea	path,a4
	jsr	copy	copy path->helpname
	lea	helpname,a3
	jsr	findend
	jsr	findstart
	lea	filename,a4
	jsr	copy		copy name to path
	move.w	#0,-(sp)
	pea	helpname
	move.w	#$3d,-(sp)	Fopen
	trap	#1
	addq.l	#8,sp
	cmp.w	#0,d0		error?
	blt	waitforevent
	move.w	d0,handle	store handle
	
	pea	buffer
	move.l	#384,-(sp)	size of data file
	move.w	handle,-(sp)	file handle
	move.w	#$3f,-(sp)	Fread
	trap	#1
	lea	$c(sp),sp
	cmp.w	#384,d0
	blt	close
	pea	bufC
	pea	bufS
	pea	bufN
	move.w	#$10,-(sp)	set new keybtbl
	trap	#14
	lea	$e(sp),sp

close	move.w	handle,-(sp)
	move.w	#$3e,-(sp)	Fclose
	trap	#1
	addq.l	#4,sp
	bra	waitforevent
*	help routines for string manipulations
copy
	cmp.b	#0,(a4)
	beq	finish
	move.b	(a4)+,(a3)+
	bra	copy
finish
	move.b	#0,(a3)
	rts
findstart		*	find : \ in string
	cmp.b	#'\',(a3)
	beq	finif
	cmp.b	#':',(a3)
	beq	finif
	sub.l	#1,a3
	bra	findstart
finif	add.l	#1,a3
	rts

findend
	cmp.b	#0,(a3)+
	beq	finie
	bra	findend
finie
	sub.l	#1,a3
	rts
	
	SECTION	DATA

	even
startp	dc.b	'A:\*.KBD',0
	even
* all C strings must end in a null !!!!!!
mymenu	dc.b	'  Key Changer',0
	even
myalert dc.b	'[1][     Keyboard Layout Changer       |'
	dc.b	'Dany Roth 1991 ZÅrich Switzerland |'
	dc.b	'Developed with DevpacTT V3.01     |'
	dc.b	'Choose...][ System | Load ]',0
	even
*	Buffer for the new layout
*	use it as example. It contains the German layout
buffer:
bufN:   
            dc.b $00,$1B,$31,$32,$33,$34,$35,$36 * ..123456
            dc.b $37,$38,$39,$30,$9E,$27,$08,$09 * 7890û'..
            dc.b $71,$77,$65,$72,$74,$7A,$75,$69 * qwertzui
            dc.b $6F,$70,$81,$2B,$0D,$00,$61,$73 * opÅ+..as
            dc.b $64,$66,$67,$68,$6A,$6B,$6C,$94 * dfghjklî
            dc.b $84,$23,$00,$7E,$79,$78,$63,$76 * Ñ#.~yxcv
            dc.b $62,$6E,$6D,$2C,$2E,$2D,$00,$00 * bnm,.-..
            dc.b $00,$20,$00,$00,$00,$00,$00,$00 * . ......
            dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........
            dc.b $00,$00,$2D,$00,$00,$00,$2B,$00 * ..-...+.
            dc.b $00,$00,$00,$7F,$00,$00,$00,$00 * .......
            dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........
            dc.b $3C,$00,$00,$28,$29,$2F,$2A,$37 * <..()/*7
            dc.b $38,$39,$34,$35,$36,$31,$32,$33 * 89456123
            dc.b $30,$2E,$0D,$00,$00,$00,$00,$00 * 0.......
            dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........
bufS:    
            dc.b $00,$1B,$21,$22,$DD,$24,$25,$26 * ..!"›$%&
            dc.b $2F,$28,$29,$3D,$3F,$60,$08,$09 * /()=?`..
            dc.b $51,$57,$45,$52,$54,$5A,$55,$49 * QWERTZUI
            dc.b $4F,$50,$9A,$2A,$0D,$00,$41,$53 * OPö*..AS
            dc.b $44,$46,$47,$48,$4A,$4B,$4C,$99 * DFGHJKLô
            dc.b $8E,$5E,$00,$7C,$59,$58,$43,$56 * é^.|YXCV
            dc.b $42,$4E,$4D,$3B,$3A,$5F,$00,$00 * BNM;:_..
            dc.b $00,$20,$00,$00,$00,$00,$00,$00 * . ......
            dc.b $00,$00,$00,$00,$00,$00,$00,$37 * .......7
            dc.b $38,$00,$2D,$34,$00,$36,$2B,$00 * 8.-4.6+.
            dc.b $32,$00,$30,$7F,$00,$00,$00,$00 * 2.0....
            dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........
            dc.b $3E,$00,$00,$28,$29,$2F,$2A,$37 * >..()/*7
            dc.b $38,$39,$34,$35,$36,$31,$32,$33 * 89456123
            dc.b $30,$2E,$0D,$00,$00,$00,$00,$00 * 0.......
            dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........
bufC: 
            dc.b $00,$1B,$31,$32,$33,$34,$35,$36 * ..123456
            dc.b $37,$38,$39,$30,$9E,$27,$08,$09 * 7890û'..
            dc.b $51,$57,$45,$52,$54,$5A,$55,$49 * QWERTZUI
            dc.b $4F,$50,$9A,$2B,$0D,$00,$41,$53 * OPö+..AS
            dc.b $44,$46,$47,$48,$4A,$4B,$4C,$99 * DFGHJKLô
            dc.b $8E,$23,$00,$7E,$59,$58,$43,$56 * é#.~YXCV
            dc.b $42,$4E,$4D,$2C,$2E,$2D,$00,$00 * BNM,.-..
            dc.b $00,$20,$00,$00,$00,$00,$00,$00 * . ......
            dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........
            dc.b $00,$00,$2D,$00,$00,$00,$2B,$00 * ..-...+.
            dc.b $00,$00,$00,$7F,$00,$00,$00,$00 * .......
            dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........
            dc.b $3C,$00,$00,$28,$29,$2F,$2A,$37 * <..()/*7
            dc.b $38,$39,$34,$35,$36,$31,$32,$33 * 89456123
            dc.b $30,$2E,$0D,$00,$00,$00,$00,$00 * 0.......
            dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........
bufend:
	* global constants
	SECTION	BSS
	even
ap_id		ds.w 1
messagebuf	ds.b 16
handle	ds.w	1
path	ds.b	128
filename	ds.b	13
helpname	ds.b	140
	ds.l	100			stack space
mystack	ds.w	1			(stacks go backwards)

	include	aeslib.s
	