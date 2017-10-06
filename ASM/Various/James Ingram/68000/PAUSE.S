* Program pauser
*  by James Ingram, 1992

trap13	equ	$b4
term	equ	$408
begin:

	bra	do

my_exe:
	bra.s	past_txt

	dc.b	"PAUS"
auto_pause:
	dc.w	0

past_txt:
	movem.l	a0-a2/d0-d2,-(a7)

pause:
	tst.w	auto_pause
	bne.s	auto_yup		; branch if automatically pausing

	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7
	
	btst	#3,d0
	bne.s	pause		; finish if ALTERNATE not held down


do_jump:
	movem.l	(a7)+,a0-a2/d0-d2
old_exe:
	jmp	0

auto_yup:
	move.l	#$00020002,-(a7)
	trap	#13		; always pause at end of program
	addq.l	#4,a7

	bra.s	do_jump

my_13:
* I am in TRAP #13 now!

	tst.w	flag_13
	bne.s	old_13			; branch if I'm in already

	addq.w	#1,flag_13		; set flag to "I'm here"

	movem.l	d0-d2/a0-a2,-(a7)	; store regs

	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13			; test shift keys
	addq.l	#4,a7			; N.B. THIS CALLS TRAP #13 (ie itself!!  That is what the FLAG_13 is for!)

	btst	#0,d0
	beq.s	jump_13
	
	btst	#3,d0
	beq.s	jump_13			; branch if either ALT or RIGHT SHIFT is UP!

* change auto wait flag

	eor.w	#$700,auto_pause

	move.w	$ffff8240.w,d2		; get current colour

	move.w	auto_pause,$ffff8240.w	; put in auto flag ( red means ON, black means OFF )

	moveq	#25-1,d1
sync:
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	
	dbra	d1,sync			; wait for 1/2 a second
	
	move.w	d2,$ffff8240.w		; restore origonal colour

wait_up:
	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13			; test shift keys
	addq.l	#4,a7			; N.B. THIS CALLS TRAP #13 (ie itself!!  That is what the FLAG_13 is for!)

	btst	#0,d0
	beq.s	jump_13
	
	btst	#3,d0
	beq.s	jump_13			; branch if either ALT or RIGHT SHIFT is UP!
	bra.s	wait_up
* ensure keys are no longer depresed

jump_13:
	subq.w	#1,flag_13
	movem.l	(a7)+,d0-d2/a0-a2
old_13:
	jmp	0

flag_13:
	dc.w	0

free_me:

do:

	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,-(a7)	

	move.l	term.w,a0
	cmp.l	#"PAUS",2(a0)
	beq.s	alread


	move.l	a0,old_exe+2
	move.l	#my_exe,term.w

	move.l	trap13.w,old_13+2
	move.l	#my_13,trap13.w

	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	installed(pc),a0
	bsr.s	print_mes

keep_me:
	move.l	#free_me,d0
	sub.l	#begin-$100,d0
	
	clr.w	-(a7)
	move.l	d0,-(a7)
	move.w	#$31,-(a7)
	trap	#1		; keep me!

alread:
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	already(pc),a0
	bsr	print_mes

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	
	clr.w	-(a7)
	trap	#1


print_mes:
	move.l	a0,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts


	section	data

installed:
	dc.b	10,13,10,27,"pProgPaus",27,"q",10,13
	dc.b	"by James Ingram,1992",10,13
	dc.b	"Installed",10,13,10
	dc.b	"Hold down ALTERNATE as a",10,13
	dc.b	"program terminates, and I shall",10,13
	dc.b	"wait until you let go!",10,13
	dc.b	10
	dc.b	"Hold down ALTERNATE and",10,13
	dc.b	"the RIGHT SHIFT to toggle",10,13
	dc.b	"AUTO PAUSE"
	dc.b	0

already:
	dc.b	10,13,10,27,"pProgPaus",27,"q",10,13
	dc.b	"by James Ingram, 1992",10,13,10
	dc.b	"is already",10,13
	dc.b	"installed!",0

	even

