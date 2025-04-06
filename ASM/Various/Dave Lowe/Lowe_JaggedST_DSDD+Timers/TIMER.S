*timer shell 01.11.90 V.7 Glyn Kendall
*Tabs=10. Case independant.

all equ 0 	;me
HOW_MANY	equ 1000	;call test this many times

*Assemble in devpac using assemble to memory option.
*Then press alt/x to run.
*This prog will call the routine at Test HOW_MANY times.
*When done will wait for 'ESC' then returns to devpac.

	bra	start		jump over test
	even
*timed code here
TEST
*this just a demo. Time is 84-86 on my machine
	move.l	scr(a6),a0
	lea	160*16(a0),a0	;down a bit
	lea	square(pc),a1	;data
	moveq	#31,d0		;32 hi
.loop	move.l	(a1)+,(a0)+	;32 pixels wide
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	lea	160-16(a0),a0	;down a scr line
	dbf	d0,.loop
	rts
square
* Hi 32 wide 32
 dc.l $00000000,$00000000,$00010001,$00010001
 dc.l $00000000,$00000000,$00010001,$00010001
 dc.l $00000000,$00000000,$00000001,$00010001
 dc.l $00000000,$00000000,$00000001,$00010001
 dc.l $00000000,$00000000,$00010000,$00010001
 dc.l $00000000,$00000000,$40010000,$7E014001
 dc.l $00000000,$00000000,$BE003E00,$C1018001
 dc.l $00000000,$00000000,$BF003F00,$C0F90001
 dc.l $00F50025,$00EA00DF,$B6F93FF9,$C0000001
 dc.l $019F00FF,$01F0010F,$A3013BF9,$CC000001
 dc.l $030001FF,$0390020F,$A2803B01,$CC780001
 dc.l $061F03FF,$0770040F,$A2783B79,$CC800001
 dc.l $0C000780,$0E800800,$A2413B78,$CC800001
 dc.l $08000700,$0D000800,$AA593B78,$CC800001
 dc.l $08000700,$0D000800,$B6583778,$C8800001
 dc.l $07000000,$08000800,$BE783F78,$C0800001
 dc.l $1D8F0100,$1E8F1008,$80F90001,$FFF90000
 dc.l $091F010F,$1E901010,$FFF9FFF9,$00010000
 dc.l $06B8079F,$18201020,$0018FFF9,$00010000
 dc.l $07300718,$08270000,$00180009,$FFF10000
 dc.l $08330B18,$06270F03,$FFF90008,$FFF1FFE0
 dc.l $08330B18,$06270F03,$FFF90008,$FFF1FFE0
 dc.l $08330B18,$06270F03,$00F9FF08,$FFF1FFE0
 dc.l $08330B18,$06270F03,$01788008,$80F1FFE0
 dc.l $08330B18,$06270F03,$01788008,$80F1C1E0
 dc.l $08330B18,$06270F03,$01788008,$80F1C1E0
 dc.l $08330B18,$06270F03,$01798009,$80F0C1E0
 dc.l $08330B18,$06270F03,$01798009,$80F0C1E0
 dc.l $08330B18,$06270F03,$01798009,$80F0C1E0
 dc.l $08330B18,$06270F03,$01788009,$80F0C1E0
 dc.l $00000000,$00000000,$00000001,$00000000
 dc.l $1C73FC0F,$03FF0000,$33320F0F,$00FEFFFE
*this just a demo end

****************************
Start	move.l	a7,a5
	lea	spdata(pc),a6		Global data pointer
	lea	datae+300(a6),sp	my stack pointer
	move.l	4(a5),a5		base page
	move.l	$c(a5),d0		text
	add.l	$14(a5),d0		data
	add.l	$1c(a5),d0		bss
	add.l	#$100+300,d0		base page length+stack space
	move.l	d0,-(sp)		length to keep
	move.l	a5,-(sp)		start address
	clr.w	-(sp)			filler
	move.w	#$4a,-(sp)
	trap	#1			M_SHRINK
	lea	12(sp),sp
*program here
	bsr	init
	bsr	cls

	bsr	gotime	init timer
	move.w	#how_many-1,d0	call sub this many
tm_lp	move.w	d0,-(sp)
	bsr	test		timed sub
*	bsr	getime
	move.w	(sp)+,d0
	dbf	d0,tm_lp
	bsr	ttime	print result
t_w	bsr	keys	wait esc
	bra.s	t_w


Cls	move.l	scr(a6),a0
	move.w	#7999,d0
.loop	clr.l	(a0)+
	dbf	d0,.loop
	rts

Gotime	lea	ntime(pc),a0
	clr.w	(a0)
	bsr.s	gtime
	lea	stime(pc),a0
	move.w	clk(pc),(a0)
	rts
Getime	bsr.s	gtime
	move.w	clk(pc),d0
	lea	ntime(pc),a0
	sub.w	(a0),d0
	add.w	d0,(a0)
	bra	sprint
Ttime	bsr.s	gtime
	move.w	clk(pc),d0
	sub.w	stime(pc),d0
	bra	sprint

Gtime	pea	rtime(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
rtime	lea	clk(pc),a0
	move.w	$4bc.w,(a0)
	rts
clk	ds.w 1
stime	ds.w 1	start time
ntime	ds.w 1	now time



KEYS	moveq	#0,d7
ke_lp	move.l	d0,d7	empty buffer
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)	crawio
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bne.s	ke_lp
	move.l	d7,d0	last valid key
	cmpi.w	#$1b,d0		esc?
	beq	quit
*	cmpi.b	#32,d0	space bar(fire)
*	beq.s	fire
	swap	d0		cursors in high word
	cmpi.w	#$48,d0
	beq.s	uparrow
	cmpi.w	#$50,d0
	beq.s	dnarrow
	cmpi.w	#$4d,d0
	beq.s	rtarrow
	cmpi.w	#$4b,d0
	beq.s	ltarrow
k_ex	rts

UPARROW	subq.w	#1,y(a6)
up_x	rts
DNARROW	addq.w	#1,y(a6)
dn_x	rts
RTARROW	addq.w	#1,x(a6)
rt_x	rts
LTARROW	subq.w	#1,x(a6)
lt_x	rts

INIT	move.l	#32260,-(sp)	32000+enough to ensure 256.b align
	move.w	#$48,-(sp)	malloc
	trap	#1
	addq.l	#6,sp
	tst.l	d0		error?
	beq	quit		must have it
	move.l	d0,ram(a6)	for return to system at end
	add.l	#256,d0		align
	andi.w	#$ff00,d0	long value really
	move.l	d0,scr2(a6)	
	move.w	#2,-(sp)	get_physbase
	trap	#14
	addq.l	#2,sp
	move.l	d0,scr1(a6)
	move.l	d0,scr(a6)	
	move.w	#4,-(sp)	get_rez
	trap	#14
	addq.l	#2,sp
	move.w	d0,rez(a6)
	cmpi.w	#2,d0	is it hi
 	beq.s	in_0
	moveq	#0,d0
	bsr.s	dorez	golow
	bsr	getcol	get system colours
	bsr	putcol	put sprite colours in
in_0	move.w	#-1,-(sp)
	move.w	#-1,-(sp)
	move.w	#35,-(sp)	read keyboard rates
	trap	#14
	addq.l	#6,sp
	move.w	d0,d1
	andi.w	#7,d1
	move.w	d1,rep(a6)
	lsr.w	#8,d0
	move.w	d0,ini(a6)
	move.w	#2,-(sp)	repeat
	move.w	#1,-(sp)	set kbd rate
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	a0,seed(a6)	just put a number in
	pea	stmsg(pc)	do cursor,colors
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

dorez	move.w	d0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	rts

QUIT	move.l	ram(a6),-(sp)	return memory to system
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#-1,-(sp)	don't change rez
	move.l	scr1(a6),-(sp)	physical screen 1
	move.l	scr1(a6),-(sp)	logical screen 1
	move.w	#5,-(sp)	setsceen
	trap	#14
	lea	12(sp),sp
	bsr	outcol		return colours
	cmpi.w	#2,rez(a6)	hi rez?
	beq.s	qu_1		no
	moveq	#1,d0
	bsr.s	dorez	gomed		
qu_1	move.w	rep(a6),-(sp)
	move.w	ini(a6),-(sp)
	move.w	#35,-(sp)
	trap	#14	keyboard rates
	addq.l	#6,sp
	move.w	#27,-(sp)	show cursor (esc e)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	move.w	#'e',-(sp)	show cursor
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
ke	move.w	#$ff,-(sp)	empty keyboard buff
	move.w	#6,-(sp)	crawio
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bne.s	ke

	clr.w	-(sp)		Exit to desktop
	move.w	#$4c,-(sp)
	trap	#1	
*set the screen to scr1 and the logical(system print) to scr2
SSCR1	move.w	#37,-(sp)	vsync
	trap	#14
	addq.l	#2,sp
	move.w	#-1,-(sp)	don't change rez
	move.l	scr1(a6),-(sp)	physical screen 1
	move.l	#-1,-(sp)	scr2(a6),-(sp)	logical screen 2
	move.w	#5,-(sp)	setsceen
	trap	#14
	lea	12(sp),sp
	move.w	#14,wscr(a6)	14=scr1 0=scr2
	move.l	scr2(a6),scr(a6) sprite write
	move.w	#37,-(sp)	vsync
	trap	#14
	addq.l	#2,sp
	rts

SSCR2	move.w	#37,-(sp)	vsync
	trap	#14
	addq.l	#2,sp
	move.w	#-1,-(sp)	don't change rez
	move.l	scr2(a6),-(sp)	physical screen 2
	move.l	#-1,-(sp)	scr1(a6),-(sp)	logical screen 1
	move.w	#5,-(sp)	setsceen
	trap	#14
	lea	12(sp),sp
	move.w	#0,wscr(a6)	save scr num(use other screen)
	move.l	scr1(a6),scr(a6) sprite write to other screen
	move.w	#37,-(sp)	vsync
	trap	#14
	addq.l	#2,sp
	rts
*wait d4+1 interupts
DELAY	move.w	#37,-(sp)	vsync
	trap	#14
	addq.l	#2,sp
	dbf	d4,delay
	rts

PRINT	bsr.s	setlog1
	bsr.s	pr_in
	bsr.s	setlog2
pr_in	move.w	#27,-(sp)	home (esc H)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	move.w	#'H',-(sp)	home
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	pea	msg(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
SETLOG1	move.w	#-1,-(sp)	don't change rez
	move.l	#-1,-(sp)	or physical
	move.l	scr1(a6),-(sp)	logical screen 1
	move.w	#5,-(sp)	setsceen
	trap	#14
	lea	12(sp),sp
	rts
SETLOG2	move.w	#-1,-(sp)	don't change rez
	move.l	#-1,-(sp)	or physical
	move.l	scr2(a6),-(sp)	logical screen 2
	move.w	#5,-(sp)	setsceen
	trap	#14
	lea	12(sp),sp
	rts


;D0.W =VALUE RANGE IS 0 TO 65535 THEN WILL RET VAL - 65535
;WILL PRODUCE LEADING ZEROS FOR ALL VAL<10000 USES D0-D3 A0-A2
sprint	LEA.L   STRING(PC),A0
	LEA.L   TENT(PC),A1
	LEA.L   DIGIT(PC),A2
	MOVEQ   #3,D3  ;4 FOR 10000
AGAIN   MOVEQ   #0,D1
	MOVE.W  D0,D1
	DIVU    (A1)+,D1
	BEQ.S   NOSUB
	MOVE.W  D1,D2
	MULU    -2(A1),D2
	SUB.W   D2,D0
NOSUB	MOVE.B  0(A2,D1.W),(A0)+
	DBF     D3,AGAIN
	SWAP    D1
	MOVE.B  0(A2,D1.W),(A0)+
	sf	(a0)	msg end

	bsr.s	setlog1
	bsr.s	spr_in
	bsr.s	setlog2

spr_in	pea	scmsg(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	RTS
TENT    DC.W    10000,1000,100,10       ;SET UP FOR 10000 MAX
DIGIT   DC.B    '0123456789'
scmsg	dc.b	27,'H'
STRING  DS.W    3



*get the system colours
GETCOL	lea	syscol(pc),a4
	moveq	#0,d4	16.w
sy_lp	move.w	#-1,-(sp)
	move.w	d4,-(sp)	colornum
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	d0,(a4)+
	addq.w	#1,d4
	cmpi.w	#16,d4
	bne.s	sy_lp	
	rts
*either return colors to system or put a new set in
PUTCOL	lea	spcol(pc),a4	set sprite colours
	bra.s	sysin
OUTCOL	lea	syscol(pc),a4
sysin	moveq	#0,d4	16.w
sy_l	move.w	(a4)+,-(sp)
	move.w	d4,-(sp)	colornum
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	addq.w	#1,d4
	cmpi.w	#16,d4
	bne.s	sy_l
	rts
*word rnd in d0
RND	move.w	seed(a6),d0
	mulu	#1509,d0
	add.w	#41,d0
	move.w	d0,seed(a6)
	rts
*
*data
msg	dc.b '      Score',0
	even
stmsg	dc.b 27,'f',27,'b',15,27,'c',6,0 hide cur,foreg,backg color
	even
syscol	ds.w 16	* Colour palette
spcol
	dc.w $0000,$0001,$0776,$0554,$0332,$0221,$0760,$0640
	dc.w $0610,$0400,$0046,$0125,$0223,$0334,$0556,$0007
*
*BSS
*spdata
*global data
	rsreset
x	rs.w 1
y	rs.w 1
backload	rs.l 1
rep	rs.w 1	kbd repeat rate
ini	rs.w 1	kbd initial rate
scr	rs.l 1	current screen address
scr1	rs.l 1	screen1 address
scr2	rs.l 1	screen2 address
wscr	rs.w 1	which scr 1(=0) or 2(4) is current
rez	rs.w 1	scr resolution 0=lo 1=med 2=hi
ram	rs.l 1	scr2 ram from system
seed	rs.w 1	rnd seed
score	rs.w 1	game score
pybit	rs.w 1
ydis	rs.w 1
datae	rs.w 0	end of relative data

spdata	ds.b	__RS	Devpac command to reserve bss storage
	end