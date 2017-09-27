*************************************************************************
*                    Yes!! it's Rogprogs crappy programs		*
*************************************************************************
super	MACRO
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	ENDM

unsuper	MACRO
	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

	dc.w	$a000
	MOVEA.L	8(A0),A0
	CLR.W	(A0)
	DC.W	$A00A		;hidemouse

*	*	*	*	*	*	*	*	*	*

sing	move.l	4(a7),a3		; base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		; text len
	add.l	$14(a3),d0		; data len
	add.l	$1c(a3),d0		; BSS len
	add.l	#$100,d0		; basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			; release memory
	add.l	#12,sp

	move.l	#310124,-(sp)		; malloc data area
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,song1_ptr
	add.l	#8512,d0
	move.l	d0,song2_ptr
	add.l	#9304,d0
	move.l	d0,song3_ptr
	add.l	#14452,d0
	move.l	d0,song4_ptr
	add.l	#11716,d0
	move.l	d0,song5_ptr
	add.l	#11092,d0
	move.l	d0,song6_ptr
	add.l	#9652,d0
	move.l	d0,vset1_ptr
	add.l	#113674,d0
	move.l	d0,vset2_ptr
	add.l	#131722,d0

	pea	env_str			; execute singsong
	pea	cmd_str
	pea	prog_nm
	move.w	#3,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#14,sp
	add.l	#256,d0
	move.l	d0,prog_ptr

	super
	movem.l	$ff8240,d0-d7 save palette
	movem.l	d0-d7,palette

* load a degas picture at a specific address

	jsr	clrscr
 
pic1l	MOVE.W	#0,-(A7)
	MOVE.L	#name1,-(A7)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	MOVE.W	D0,handle
	move.l	$44e,d0		load direct to current screen
	sub.l	#34,d0
	MOVE.L	d0,-(sp) 
	MOVE.L	#32066,-(A7)	read it
	MOVE.W	handle,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7
	jsr	fcl

	unsuper
	jsr	tune1			; load tune 1
	bsr	open
	jsr	tune2			; load tune 2
	bsr	open
	jsr	tune3			; load tune 3
	bsr	open
	jsr	tune4			; load tune 4
	bsr	open
	jsr	tune5			; load tune 5
	bsr	open
	jsr	tune6			; load tune 6
	bsr	open
	lea	vset1_nm,a4		; load voiceset1
	move.l	vset1_ptr,a5
	move.l	#113674,a6
	bsr	open
	lea	vset2_nm,a4		; load voiceset2
	move.l	vset2_ptr,a5
	move.l	#131722,a6
	bsr	open

	super

* load a degas picture at a specific address

	jsr	clrscr
 
pic2l	MOVE.W	#0,-(A7)
	MOVE.L	#name2,-(A7)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	MOVE.W	D0,handle
	move.l	$44e,d0		load direct to current screen
	sub.l	#34,d0
	MOVE.L	d0,-(sp) 
	MOVE.L	#32066,-(A7)	read it
	MOVE.W	handle,-(A7)
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7
	jsr	fcl
	move.l	prog_ptr,a6		; play the song
	move.l	song1_ptr,12(a6)
	move.l	vset1_ptr,16(a6)	; use voiceset1 automatically
	jsr	4(a6)

nowgo
.loop2	cmp.b	#$2,(a6)		; check for num 1
	bne	.key2
	beq	load1
.key2	cmp.b	#$3,(a6)		; check for num 2
	bne	.key3
	beq	load2
.key3	cmp.b	#$4,(a6)		; check for num 3
	bne	.key4
	beq	load3
.key4	cmp.b	#$5,(a6)		; check for num 4
	bne	.key5
	beq	load4
.key5	cmp.b	#$6,(a6)		; check for num 5
	bne	.key6
	beq	load5
.key6	cmp.b	#$7,(a6)		; check for num 6
	bne	.quit
	beq	load6
.quit	cmp.b	#$39,(a6)		; check for spacebar
	bne	.loop2
	beq	.stop			; if = then GEM

.stop	move.l	prog_ptr,a6		; stop playing
	jsr	8(a6)

	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240
	unsuper				; user mode

	clr.w	-(sp)			; program terminate
	move.w	#$4c,-(sp)
	trap	#1

*	*	*	*	*	*	*	*	*	*

open	clr.w	-(sp)			; load a file
	move.l	a4,-(sp)		; a4 -> filename
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	diskerr
	move.w	d0,-(sp)		; store file handle

read	move.l	a5,-(sp)		; read file to data area
	move.l	a6,-(sp)
	move.w	d0,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.w	#12,sp
	move.l	d0,d7			; store length

close	move.w	#$3e,-(sp)		; close file
	trap	#1			; handle already on stack
	addq.l	#4,sp
	move.l	d7,d0
	tst.l	d0			; d0=bytes loaded, -ve=err
diskerr	rts

*	*	*	*	*	*	*	*	*

	; tune info starts here

tune1
	lea	song_n1,a4		; load song
get1	move.l	song1_ptr,a5
	move.l	#$8512,a6
	rts

tune2
	lea	song_n2,a4		; load song
get2	move.l	song2_ptr,a5
	move.l	#$9304,a6
	rts

tune3
	lea	song_n3,a4		; load song
get3	move.l	song3_ptr,a5
	move.l	#$14452,a6
	rts

tune4
	lea	song_n4,a4		; load song
get4	move.l	song4_ptr,a5
	move.l	#$11716,a6
	rts

tune5
	lea	song_n5,a4		; load song
get5	move.l	song5_ptr,a5
	move.l	#$11092,a6
	rts

tune6
	lea	song_n6,a4		; load song
get6	move.l	song6_ptr,a5
	move.l	#$9652,a6
	rts

	; key interupt

load1	move.l	prog_ptr,a6		; stop playing
	jsr	8(a6)
	jsr	get1
	jmp	play1

load2	move.l	prog_ptr,a6		; stop playing
	jsr	8(a6)
	jsr	get2
	jmp	play2

load3	move.l	prog_ptr,a6		; stop playing
	jsr	8(a6)
	jsr	get3
	jmp	play3

load4	move.l	prog_ptr,a6		; stop playing
	jsr	8(a6)
	jsr	get4
	jmp	play4

load5	move.l	prog_ptr,a6		; stop playing
	jsr	8(a6)
	jsr	get5
	jmp	play5

load6	move.l	prog_ptr,a6		; stop playing
	jsr	8(a6)
	jsr	get6
	jmp	play6

	; now decide the voiceset

play1	move.l	prog_ptr,a6		; play the song
	move.l	song1_ptr,12(a6)
	move.l	vset1_ptr,16(a6)	; use voiceset1
	jsr	4(a6)
	jmp 	nowgo

play2	move.l	prog_ptr,a6		; play the song
	move.l	song2_ptr,12(a6)
	move.l	vset1_ptr,16(a6)	; use voiceset1
	jsr	4(a6)
	jmp 	nowgo

play3	move.l	prog_ptr,a6		; play the song
	move.l	song3_ptr,12(a6)
	move.l	vset1_ptr,16(a6)	; use voiceset1
	jsr	4(a6)
	jmp 	nowgo

play4	move.l	prog_ptr,a6		; play the song
	move.l	song4_ptr,12(a6)
	move.l	vset2_ptr,16(a6)	; use voiceset2
	jsr	4(a6)
	jmp 	nowgo

play5	move.l	prog_ptr,a6		; play the song
	move.l	song5_ptr,12(a6)
	move.l	vset2_ptr,16(a6)	; use voiceset2
	jsr	4(a6)
	jmp 	nowgo

play6	move.l	prog_ptr,a6		; play the song
	move.l	song6_ptr,12(a6)
	move.l	vset2_ptr,16(a6)	; use voiceset2
	jsr	4(a6)
	jmp 	nowgo

clrscr	movem.l	blanks(pc),d0-d7	; all nulls
	movem.l	d0-d7,$ff8240		; all colors are now black
	rts

fcl	MOVE.W 	handle,-(SP)	close
	MOVE.W 	#$3E,-(SP)
	TRAP 	#1
	ADDQ.L 	#4,SP

	move.l	$44e,a0
	sub.l	#32,a0		palette
	MOVE.L	A0,-(SP)  
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	rts

*	*	*	*	*	*	*	*	*	*

prog_ptr:	dc.l	0
song1_ptr:	dc.l	0
song2_ptr:	dc.l	0
song3_ptr:	dc.l	0
song4_ptr:	dc.l	0
song5_ptr:	dc.l	0
song6_ptr:	dc.l	0

vset1_ptr:	dc.l	0
vset2_ptr:	dc.l	0

prog_nm:	dc.b	'a:\music2\singsong.prg',0	; playback routine name
song_n1:	dc.b	'a:\music2\rtune15.4v',0	; song1 name
song_n2:	dc.b	'a:\music2\rtune16.4v',0	; song2 name
song_n3:	dc.b	'a:\music2\rtune17.4v',0	; song3 name
song_n4:	dc.b	'a:\music2\rtune18.4v',0	; song4 name
song_n5:	dc.b	'a:\music2\rtune19.4v',0	; song5 name
song_n6:	dc.b	'a:\music2\rtune20.4v',0	; song6 name
vset1_nm:	dc.b	'a:\music2\v7.set',0		; voiceset1 name
vset2_nm:	dc.b	'a:\music2\v8.set',0		; voiceset2 name
		even
env_str:	dc.b	0,0
cmd_str:	dc.b	0,0
res		dc.w 	0
palette 	ds.w	16
handle		dc.w 0
name1		dc.b "a:\music2\pic1.pi1",0
name2		dc.b "a:\music2\pic2.pi1",0
blanks	ds.w	16
*

oldsp	dc.l	0

	ds.l	100			stack space
mystack	ds.w	1			(stacks go backwards)

*	*	*	*	*	*	*	*	*	*
