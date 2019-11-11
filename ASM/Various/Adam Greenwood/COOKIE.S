* Cookie Example Program 
* Display the contents of cookie jar, and the meaning of cookies
* if known
* copyright c.1991 Adam Greenwood
* Written with/for Devpac 2

* constants

* cookie jar pointer (p_cookies)

cookies	equ	$5a0		address of cookie pointer

* The names of the official Atari cookies so far

_cpu	equ	'_CPU'		processor cookie
_vdo	equ	'_VDO'		video cookie
_mch	equ	'_MCH'		machine cookie
_snd	equ	'_SND'		sound chip cookie
_swi	equ	'_SWI'		configuration switch cookie
_frb	equ	'_FRB'		fast RAM buffer cookie	

* start of code

start	move.l	a7,a5
	addq	#4,a7
	move.l	4(a5),a5		get basepage
	move.l	$c(a5),d0		get legth of text segment
	add.l	$14(a5),d0	add length of data segment
	add.l	$1c(a5),d0	add length of uninit BSS
	add.l	#$100,d0		add length of basepage
	move.l	d0,-(a7)		push length to reserve
	move.l	a5,-(a7)		start address to modify
	move.w	#0,-(a7)		zero
	move.w	#$4a,-(a7)	shrink memory
	trap	#1
	add.l	#$c,a7

	clr.l   -(a7)		set supervisor mode
	move.w  #32,-(a7)
	trap    #1
	addq    #6,a7
	move.l  d0,stk		save old value of stack

	move.l	#intr_mess,a1	display intro message
	jsr	prnt_str

	move.l	cookies,a0	address of cookie jar
	beq	.no_jar		if 0 no cookie jar

* now loop round reading each pair of longwords until
* the empty longword is reached

.loop	move.l	(a0)+,d0		cookie name
	move.l	(a0)+,d1		cookie value 
	cmp.l	#0,d0		check for empty longword
	beq	.out		if empty finished

	jsr	prnt_cook		print cookie & value

	cmp.l	#_cpu,d0		check for _cpu cookie
	bne.s	.2	
	jsr	cook_cpu		evaluate cookie
	
.2	cmp.l	#_vdo,d0		check for _vdo cookie
	bne.s	.3
	jsr	cook_vdo		evaluate cookie
	
.3	cmp.l	#_mch,d0		check for _mch cookie
	bne.s	.4
	jsr	cook_mch		evaluate cookie

.4	cmp.l	#_snd,d0		check for _snd cookie
	bne.s	.5
	jsr	cook_snd		evaluate cookie

.5	move.l	#return,a1	leave a line between cookies
	jsr	prnt_str

	bra	.loop		get next cookie
	
.no_jar	move.l	#err_mess,a1	display message
	jsr	prnt_str

.out	jsr	wait_key		wait for key press

	bra	fin		done


* routine to print name and value of cookie
* in : d0.l = name of cookie
*      d1.l = value of cookie

prnt_cook	movem.l	d0-d3/a1,-(a7)
	
	move.l	#cook_mess,a1	print 'cookie: '
	jsr	prnt_str
	
	move.w	#3,d3		4 characters
	move.l	d0,d2		
.loop	rol.l	#8,d2		starting with high byte
	moveq	#0,d0		clear		
	move.b	d2,d0		
	jsr	prnt_char		print character
	dbra	d3,.loop		
	
	move.l	#val_mess,a1	print 'value: '
	jsr	prnt_str	
	
	move.w	#'$',d0		print hex symbol
	jsr	prnt_char
	
	move.w	#7,d3		8 hex characters
	move.l	d1,d2		
.loop2	rol.l	#4,d2		start with high
	move.l	d2,d0
	and.l	#$f,d0		4 bits
	cmp.b	#9,d0		if <=9, number 0-9
	bgt.s	.letter		else letter a-f
	add.b	#48,d0		convert to number
	bra	.print
.letter	add.b	#87,d0		convert to letter
.print	jsr	prnt_char		print character
	dbra	d3,.loop2		next number

	move.l	#return,a1	next line
	jsr	prnt_str
	
	movem.l	(a7)+,d0-d3/a1
	rts

* routine to evaluate _cpu cookie
* in: d1 = value
* _cpu cookie is a decimal number, 00, 10, 20, 30, 40
* so we first divide by 10, then use the resulting no.
* 0-3 to select the correct message
 
cook_cpu	movem.l	d0-d1/a1,-(a7)

	move.l	#cpu_mess0,a1	first message
	divu	#10,d1		divide value by 10
	bra	.test		go to loop
	
.loop	move.b	(a1)+,d0		find end of message
	bne.s	.loop		
.test	dbra	d1,.loop		skip d1 messages

	jsr	prnt_str		print correct message
	move.l	#return,a1	next line
	jsr	prnt_str
	
	movem.l	(a7)+,d0-d1/a1
	rts

* routine to evaluate _vdo cookie
* in: d1 = cookie value
* The information is in the high byte, so first we swap
* then skip to the correct message.

cook_vdo	movem.l	d0-d1/a1,-(a7)

	move.l	#vdo_mess0,a1	first message
	swap	d1		cookie value
	bra	.test		go to loop
.loop	move.b	(a1)+,d0		find end of message
	bne.s	.loop
.test	dbra	d1,.loop		skip d1 messages

	jsr	prnt_str		print correct message
	move.l	#return,a1	next line
	jsr	prnt_str

	movem.l	(a7)+,d0-d1/a1
	rts

* routine to evaluate _mch cookie
* This works in much the same way as for _VDO

cook_mch	movem.l	d0-d1/a1,-(a7)

	move.l	#mch_mess0,a1	first message
	swap	d1		value of cookie
	bra	.test		go to loop
.loop	move.b	(a1)+,d0		find end of message
	bne.s	.loop		
.test	dbra	d1,.loop		skip d1 messages
	jsr	prnt_str		print correct message
	move.l	#return,a1	next line
	jsr	prnt_str

	movem.l	(a7)+,d0-d1/a1
	rts
	
* routine to evaluate _snd cookie
* In this case the information is in the bits, so we test for them
* in turn

cook_snd	move.l	a1,-(a7)

	btst	#0,d1		test for yamaha chip
	beq.s	.dma		
	move.l	#snd_mess0,a1	print message
	jsr	prnt_str
	move.l	#return,a1	next line
	jsr	prnt_str
.dma	btst	#1,d1		test for DMA chip
	beq.s	.out
	move.l	#snd_mess1,a1	print message
	jsr	prnt_str
	move.l	#return,a1	next line
	jsr	prnt_str

.out	move.l	(a7)+,a1
	rts

* routine to print a null terminated string to screen
* a1 = address of string

prnt_str	movem.l	d0-d4/a0-a4,-(a7)

	move.l	a1,-(a7)		address of string
	move.w	#9,-(a7)		print string
	trap	#1
	addq	#6,a7	
	
	movem.l	(a7)+,d0-d4/a0-a4
	rts

* routine to print a character to the screen
* d0.w = character 
	
prnt_char	movem.l	d0-d4/a0-a4,-(a7)

	move.w	d0,-(a7)		character
	move.w	#2,-(a7)		print character
	trap	#1
	addq	#4,a7
	
	movem.l	(a7)+,d0-d4/a0-a4
	rts

* routine to print message and wait for key press

wait_key	movem.l	d0-d4/a0-a4,-(a7)

	move.l	#key_mess,a1	print message
	jsr	prnt_str

	move.w	#7,-(a7)		wait for key press
	trap	#1
	addq	#2,a7
	
	movem.l	(a7)+,d0-d4/a0-a4
	rts

* Return to user mode and exit

fin	lea	stk,a6		get value of original stack
	move.l	(a6),-(a7)
	move.w	#32,-(a7)
	trap	#1		Return to user mode
	addq	#6,a7
	

	move.w	#0,-(a7)
	trap	#1
	addq	#2,a7


	section	BSS

stk	ds.l	1

	section	DATA
	
intr_mess	dc.b	'Cookie Display Program',13,10
	dc.b	'Copyright ',189,'1991 A Greenwood',13,10,13,10,0
err_mess	dc.b	'No Cookie Jar',13,10,0
cook_mess	dc.b	'Cookie: ',0
val_mess	dc.b	'  Value: ',0

return	dc.b	13,10,0

cpu_mess0	dc.b	'  68000 Processor',0
cpu_mess1	dc.b	'  68010 Processor',0
cpu_mess2	dc.b	'  68020 Processor',0
cpu_mess3	dc.b	'  68030 Processor',0
cpu_mess4	dc.b	'  68040 Processor',0

vdo_mess0	dc.b	'  Standard Video Shifter',0
vdo_mess1	dc.b	'  Improved Video Shifter',0
vdo_mess2	dc.b	'  TT Graphics Chip',0

mch_mess0	dc.b	'  Machine is a Standard ST',0
mch_mess1	dc.b	'  Machine is an STE',0
mch_mess2	dc.b	'  Machine is a Mega ST',0
mch_mess3	dc.b	'  Machine is a TT',0

snd_mess0	dc.b	'  Yamaha Sound Chip Present',0
snd_mess1	dc.b	'  DMA Sound Chip Present',0

key_mess	dc.b	'Press any key',0
	
	end