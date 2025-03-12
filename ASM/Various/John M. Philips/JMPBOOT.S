* demo booter for ELIMINATOR
* john m phillips 12/8/88

* loads title screen and game code then runs
* also patches a dummy rte for trap #15

************************************************************
* NOTE: the game assumes supervisor mode with interrupts off
************************************************************

	opt	p+,d-
	output	jmpboot.prg

	bra	boot

load_at	equ	$13000		load address for game code
run_at	equ	load_at+8	call this address to run

screen	equ	$78000		screen for title (game assumes 1/2 MEG)
my_sp	equ	$80000		stack for boot only

title_file dc.b	'ELIMINAT.NEO',0
game_file dc.b	'ELIMINAT.JMP',0
	even

boot	move.l	#my_sp,sp		set stack in safe place
	lea	screen,a0		clear screen
	move.w	#32000/4-1,d0
.wipe	clr.l	(a0)+
	dbra	d0,.wipe
	pea	screen			clear palette
	move.w	#6,-(sp)
	trap	#14
	clr.w	-(sp)			set lo-res, my screen
	pea	screen
	pea	screen
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	lea	title_file(pc),a0	load title file (.NEO format)
	lea	load_at,a1
	bsr	load_file
	pea	load_at+4		set palette
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	lea	load_at+128,a0		copy title to screen
	lea	screen,a1
	move.w	#32000/4-1,d0
.title	move.l	(a0)+,(a1)+
	dbra	d0,.title
	lea	game_file(pc),a0	load game file
	lea	load_at,a1
	bsr	load_file
	pea	.run(pc)		into super mode
	move.w	#38,-(sp)
	trap	#14
.run	or.w	#$0700,sr		irq's off

	move.l	.dummy(pc),$80		put dummy rte in trap #0 vector
	move.l	#$80,$BC		and point trap #15 to it

	jmp	run_at			run game

.dummy	rte

* load a file
* entry	A0=filename term'd by 0
*	A1=load address
* exit	D0 = 0 if load ok else error code
*	D1 = file length

load_address equr d5
file_handle equr d6
file_length equr d7

load_file
	move.l	a1,load_address		attempt to open file
	move.w	#0,-(sp)		READ ONLY
	move.l	a0,-(sp)
	move.w	#$3D,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0			error ?
	bmi	load_exit		exit with D0 -ve
	move.w	d0,file_handle
	move.w	#2,-(sp)		move file pointer to end
	move.w	file_handle,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp			now D0=length of file
	move.l	d0,file_length
	move.w	#0,-(sp)		move file pointer to start
	move.w	file_handle,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp
	move.l	load_address,-(sp)	read file to address
	move.l	file_length,-(sp)
	move.w	file_handle,-(sp)
	move.w	#$3F,-(sp)
	trap	#1
	add.l	#12,sp
	move.w	file_handle,-(sp)	close file
	move.w	#$3E,-(sp)
	trap	#1
	addq.l	#4,sp
load_exit
	move.l	file_length,d1
	rts

