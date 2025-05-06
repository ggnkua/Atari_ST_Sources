	dc.w	$a00a

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1

program	pea	specload(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

gethead	lea	head(pc),a0
	moveq	#18,d6
	bsr	taplod
	tst.b	ldtyp
	bne.s	gethead

	move.b	head,d0
	tst.b	d0
	beq.s	ldprog
	cmp.b	#3,d0
	beq.s	ldcode

	pea	t_file(pc)
	bra.s	getfile
ldprog	pea	t_prog(pc)
	bra.s	getfile
ldcode	pea	t_code(pc)
getfile	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	lea	head+1(pc),a6
	lea	code(pc),a0
	REPT	10
	move.b	(a6)+,(a0)+
	ENDR
	clr.b	(a0)+
	pea	code(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	lea	code(pc),a0
	moveq	#0,d6
	move.b	12-18(a0),d6
	rol.w	#8,d6
	move.b	11-18(a0),d6
	bsr	taplod

	cmp.w	#-1,d6
	bne.s	taperr
	cmp.w	#-1,d7
	bne.s	taperr
*******************************************************
hitsan	pea	request(pc)
	move.w	#8,-(sp)
	trap	#1
	addq	#6,sp

	pea	input(pc)
	move.w	#10,-(sp)
	trap	#1
	addq	#6,sp

	lea	input+1(pc),a0
	moveq	#0,d0
	move.b	(a0)+,d0
	lea	(a0,d0.w),a0
	move.l	a0,fnam

	move.b	htype,d0
	cmp.b	#3,d0
	beq.s	s_code

******************************************
	nop
******************************************

s_code	move.l	fnam(pc),a0
	move.b	#".",(a0)+
	move.b	#"S",(a0)+
	move.b	#"P",(a0)+
	move.b	#"C",(a0)+
	clr.b	(a0)+

	lea	s_bytes(pc),a5

	lea	head(pc),a6
	moveq	#0,d6
	move.b	12(a6),d6
	rol.w	#8,d6
	move.b	11(a6),d6
	add.w	#18,d6
	bsr	save

*******************************************************

zzz	pea	$4c0000
	trap	#1

taperr	pea	t_err(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	move.w	#8,-(sp)
	trap	#1
	addq	#2,sp
	cmp.b	#" ",d0
	beq	zzz
	cmp.b	#13,d0
	bne	program
	bra	hitsan
	
save	pea	(a5)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	clr.w	-(sp)
	pea	fname(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	tst.w	d0
	blt.s	derr
	move.w	d0,d7

	pea	(a6)
	move.l	d6,-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	tst.l	d0
	blt.s	derr
	lea	12(sp),sp

	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq	#4,sp

	rts

derr	addq	#4,sp
	pea	d_err(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts

* Rutine for innlasting fraa kassett via printerport
*
*	bruk:	a0=innlastingsstad
*		d6=no. of bytes to load
*		bsr	taplod
*		dersom d6=-1 og d7=-1, OK, else Tape Loading Error
*
*******************************************************
* Finne ledetone

taplod	move.w	$ffff8240.w,oldcol
	move.l	sp,oldsp
	move.w	#$2700,sr

	move.l	#$00000000,$ffff8800.w
	move.l	#$01010000,$ffff8800.w
	move.b	#7,$ffff8800.w
	move.b	$ffff8800.w,d0
	bclr	#7,d0
	move.b	d0,$ffff8802.w

	move.w	#$707,d2
gleadd	move.w	#199,d3
glead	bsr.s	gtape
	cmp.w	#$60,d1
	bgt.s	gleadd
	cmp.w	#$30,d1
	blt.s	gleadd
	dbra	d3,glead
	ror.b	#1,d1
	and.w	#$7f,d1
	addq	#8,d1
	move.w	d1,shit+2
*******************************************************
* Foelge ledetone til dataene begynner

	moveq	#0,d4
	move.w	#$077,d2
lead	bsr.s	gtape
	cmp.w	#$30,d1
	blt.s	leade
	cmp.w	#$60,d1
	blt.s	lead
leade	move.w	#$770,d2
*******************************************************
* Laste bitar...

load	moveq.w	#7,d7
loadb	rol.b	#1,d3
	bsr.s	gtape
	cmp.w	#255,d5
	bgt.s	ende
shit	cmp.w	#$28,d1
	blt.s	load0
load1	bset	#0,d3
	bra.s	load00
load0	bclr	#0,d3
load00	dbra	d7,loadb
	tst.b	d4
	beq	eek
	move.b	d3,(a0)+
	dbra	d6,load

ende	move.l	#$08080000,$ffff8800.w
	move.w	#$2300,sr
	move.w	oldcol,$ffff8240.w
	move.l	oldsp,sp
	rts

*******************************************************
* Les boelge

gtape	move.b	$fffffc02.w,d0
	cmp.b	#$39,d0
	beq.s	ende

	moveq	#0,d1
	moveq	#0,d5
	move.l	#$0f0fffff,$ffff8800.w
	move.b	$ffff8800.w,d0
	cmp.b	#-1,d0
	bne.s	gtape

test	move.l	#$0f0fffff,$ffff8800.w
	move.b	$ffff8800.w,d0
	cmp.b	#-1,d0
	bne.s	test001

	addq	#1,d5
	move.w	d2,$ffff8240.w
	move.l	#$08080000,$ffff8800.w
	bra.s	test

test001	not.w	$ffff8240.w
	move.l	#$08080f0f,$ffff8800.w

test00	addq.l	#1,d1
	move.l	#$0f0fffff,$ffff8800.w
	move.b	$ffff8800.w,d0

	cmp.b	#-1,d0
	bne.s	test00

test01	rts

eek	move.b	d3,ldtyp
	moveq	#-1,d4
	dbra	d6,load

	DATA

tast	dc.l	0
cr	dc.b	13,10,0

t_file	dc.b	13,10,"Variable: ",0
t_prog	dc.b	13,10,"Program: ",0
t_code	dc.b	13,10,"Bytes: ",0

t_err	dc.b	13,10,"Tape loading error...Space to quit,",13,10
	dc.b	"RETURN to ignore this, any other key to retry",13,10,0
d_err	dc.b	13,10,10,"Disk error...Saving canceled...",13,10,0

specload
	dc.b	27,"E*** Spectrum Tape Loader",13,10
	dc.b	"(C) 1991, 1992 Gard Eggesb",179," Abrahamsen",13,10
	dc.b	"Insert tape to load from and connect tape to",13,10
	dc.b	"any data pin and any ground pin on the printer",13,10
	dc.b	"port and press play. Options will come when",13,10
	dc.b	"program/code is loaded. Use space-bar as break.",13,10
	dc.b	10,0
	even

request	dc.b	13,10
	dc.b	"Enter 8 letter file name (no extension, as this",13,10
	dc.b	"automatically will be added...",13,10,">",0

input	dc.b	40,40
fname	ds.b	40

s_bytes	dc.b	13,10,".SPC => Header and code",0
s_prog	dc.b	13,10,".BAS => Converted BASIC program",0
s_vars	dc.b	13,10,".VAR => Variables as read/data",0
s_scrn	dc.b	13,10,".PC1 => Screenshot in Degas Elite format",0

	BSS

ldtyp	ds.w	1
oldsp	ds.l	1
oldcol	ds.w	1
fnam	ds.l	1

head			; Header - 18 bytes
htype	ds.b	1		; Program/Code/Variable
hname	ds.b	10		; File Name
hlen	ds.b	2		; Full File Length
hstart	ds.b	2		; Auto start or load address
hprog	ds.b	2		; Length of program
	ds.b	1		; ???
code

