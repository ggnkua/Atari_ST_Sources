*prg de gestion du clavier/joystick
send	macro
	lea	\1(a6),a0
	moveq	#\1len-1,d0
	btst	#1,$fffffc00.w
	beq.s	*-6
	ifeq	'\2'-'+'
	move.b	(a0)+,$fffffc02.w
	dbra	d0,*-12
	endc
	ifeq	'\2'-'-'
	move.b	0(a0,d0),$fffffc02.w
	dbra	d0,*-14
	endc
	endm
print	macro
	move	#$2700,sr
	pea	\1(a6)
	move	#$9,-(a7)
	trap	#1
	lea	6(a7),a7
	move	#$2300,sr
	endm
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	lea	6(a7),a7
	move	#$2700,sr
	lea	dataoffset(pc),a6
	send	boot,+
	send	pauseoutput,+
	send	controllerexecute,+
	send	loader,-
	send	program,-
	lea	vbl(pc),a0
	move.l	a0,$70.w
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move	#$2300,sr
print6301data
	print	home
	lea	data6301(a6),a5
	moveq	#3,d7
read6301data
	move.b	(a5)+,d0
	bsr.s	ascii
	move.b	d1,hexa+1(a6)
	bsr.s	ascii
	move.b	d1,hexa(a6)
	print	hexa
	dbra	d7,read6301data
	bra.s	print6301data
ascii
	move.b	d0,d1
	and.b	#$f,d1
	add.b	#'0',d1
	cmp.b	#'9',d1
	ble.s	decimal
	add.b	#'A'-'0'-10,d1
decimal
	lsr.w	#4,d0
	rts
vbl
	move	#$2700,sr
	movem.l	d0/a0,-(a7)
transmit
	btst	#1,$fffffc00.w
	beq.s	transmit
	move.b	#4,$fffffc02.w
	lea	data6301(a6),a0
	moveq	#3,d0
input6301
	btst	#0,$fffffc00.w
	beq.s	input6301
	move.b	$fffffc02.w,(a0)+
	dbra	d0,input6301
	movem.l	(a7)+,d0/a0
	rte
dataoffset	equ	*
home	equ	(*-dataoffset)
	dc.b	$1b,'H',0
hexa	equ	(*-dataoffset)
	dc.b	0,0,$a,$d,0
data6301	equ	(*-dataoffset)
	ds.b	4
pauseoutput	equ	(*-dataoffset)
	dc.b	$13
pauseoutputlen	equ	(*-dataoffset)-pauseoutput
controllerexecute	equ	(*-dataoffset)
	dc.b	$22,$00,$b1
controllerexecutelen	equ	(*-dataoffset)-controllerexecute
boot	equ	(*-dataoffset)
	dc.b	$20,$00,$b0,$0b
	dc.b	$b9+loaderlen
	dc.b	$0f
	dc.b	$9e,$af
	dc.b	$dc,$11
	dc.b	$2a,$fc
	dc.b	$37
	dc.b	$20,$f9
bootlen	equ	(*-dataoffset)-boot
loader	equ	(*-dataoffset)
	dc.b	$00
	dc.b	$dc,$b4
	dc.b        $dd,$80
	dc.b        $dc,$b6
	dc.b        $dd,$82
	dc.b        $dc,$b8
	dc.b        $dd,$84
	dc.b        $86,$f9
	dc.b        $97,$86
	dc.b        $cc,$00,$01
	dc.b        $dd,$00
	dc.b        $43
	dc.b        $53
	dc.b        $97,$04
	dc.b        $54
	dc.b        $dd,$06
	dc.b        $86,$40
	dc.b        $dd,$0b
	dc.b        $8e,$00,programlen+$85
	dc.b        $7e,$00,$80
loaderlen	equ	(*-dataoffset)-loader
program	equ	(*-dataoffset)
	dc.b        $0d
	dc.b        $ff,$ff,$ff,$ff
	dc.b        $ff,$ff,$ff,$ff
	dc.b        $ff,$ff,$ff,$ff
	dc.b        $ff
	dc.b        $8e,$00,$82
	dc.b        $33
	dc.b        $5a
	dc.b        $2a,$26
	dc.b        $d7,$03
	dc.b        $d7,$05
	dc.b        $dc,$0b
	dc.b        $48
	dc.b        $89,$00
	dc.b        $5c
	dc.b        $2a,$02
	dc.b        $30
	dc.b        $5f
	dc.b        $dd,$0b
	dc.b        $2a,$08
	dc.b        $09
	dc.b        $dc,$06
	dc.b        $05
	dc.b        $c9,$00
	dc.b        $dd,$06
	dc.b        $e6,$10
	dc.b        $d8,$02
	dc.b        $d4,$0b
	dc.b        $27,$06
	dc.b        $e8,$10
	dc.b        $e7,$10
	dc.b        $d6,$0c
	dc.b        $37
	dc.b        $5f
	dc.b        $d7,$03
	dc.b        $d7,$05
	dc.b        $86,$00
	dc.b        $16
	dc.b        $c4,$0a
	dc.b        $10
	dc.b        $48
	dc.b        $54
	dc.b        $1b
	dc.b        $d6,$07
	dc.b        $d7,$ca
	dc.b        $98,$ca
	dc.b        $c4,$f0
	dc.b        $d8,$03
	dc.b        $37
	dc.b        $34
	dc.b        $33
	dc.b        $44
	dc.b        $c2,$00
	dc.b        $44
	dc.b        $c9,$00
	dc.b        $37
	dc.b        $34
	dc.b        $33
	dc.b        $44
	dc.b        $c2,$00
	dc.b        $44
	dc.b        $c9,$00
	dc.b        $37
	dc.b        $dc,$11
	dc.b        $2a,$a1
	dc.b        $7b,$20,$11
	dc.b        $27,$fb
	dc.b        $32
	dc.b        $97,$13
	dc.b        $5a
	dc.b        $26,$f5
	dc.b        $20,$98
programlen	equ	(*-dataoffset)-program
	