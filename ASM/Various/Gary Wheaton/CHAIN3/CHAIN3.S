*  Budgie UK    chain3.s   last updated June 15, 1991
*  -------------------------------------------------

*  A typical chain program which loads a tune, and plays it
*  then a picture is loaded. When a key is hit,
*  the main prog (in our case, darts.prg) is loaded.

*  The picture will stay on show while the main program is loaded
*  only if no change of res is applied.
*  The tune, on the other hand, will still run under TOS interrupt.
*  The tune can easiliy be switched on or off from your own prog.
*  In this example, Darts does NOT switch the tune off.
*  But it is easy to do so.

*  The program may reside in an auto folder, ONLY if the next prog
*  (ie DARTS) doesn't use any GEM routine.
 
*  In our example, we'll click on chain3.prg

*  The picture is any Degas PI.1 picture
*  The tune may use any of the available v/b slots:
*  in this case $4de

*  If pic, tune and main prog are not in the same directory,
*  the appropriate lines should be modified 
*  to, for instance: name  dc.b "a:\pics\mari*.pi1",0

*  In choosing a tune for your game, try not to use one that has
*  already been used in a previous Budgie game. 

*  Music by Goth of The Shapeshifters
*  (c) Budgie UK , Camy Maertens and Shapeshifters

*  This chain source code must be assembled using DEVPAC2 
*  To assemble to MEMORY on a 520, make sure your text buffer
*  is not excessive. 30K will do. See Preferences under Options menu.
*  Assembling to disk is of course straight forward. 
*  -------------------------------------------------  *

* reallocate unused memory to Gemdos
m_shrink
	movea.l	A7,A5	
	move.l 	#stack,A7	
	movea.l	4(A5),A5	
	move.l	12(A5),D0	
	add.l	20(A5),D0	
	add.l	28(A5),D0	
	addi.l	#256,D0		
	move.l	D0,-(A7)	
 	move.l	A5,-(A7)	
	clr.w	-(A7)		
	move.w	#$4A,-(A7)	
	trap	#1		
	lea	$0C(A7),A7
; the above is the STANDARD gem start. We will only use the ram
; space that is strictly required. The rest may go back to gem.

	bra.s	start			jump to start

name	dc.b	"mar*.pi1",0   		any pi1
name1	dc.b	"clem_4de.prg",0	any tune in $4de.
name3	dc.b	"dart*.prg",0       	this is the main prog afterwards
;					in this case DARTS.PRG
	even
; bra.s start means 'branch (short) to start'
; in order to skip the above data statements
; dc.b  means declare bytes

start	clr.l	-(sp)		Budgie progs ALWAYS run in supervisor
 	move.w #$20,-(sp)	go supervisor 	
 	trap #1
 	addq.l #6,SP
 	move.l d0,super

	move.w  #4,-(sp)	get res
	trap    #14
	addq.l  #2,sp
	move.w  d0,res		and save it

	movem.l	$ff8240,d0-d7 	save palette
	movem.l	d0-d7,palette

	move.l	#environment,-(sp)	call program one 
	move.l	#environment,-(sp)  
	pea	name1		ie our music
	move.w	#0,-(sp)	chain this routine
	move.w	#$4b,-(sp)	execute it
	trap	#1		
	adda.l	#$10,sp

; clear a 64k block from ramtop..downwards (not essential)
	move.l	$44e,a0		get current screen location
	add.l	#32000,a0	go to bottom of screen
	move.l	#4200,d7	loop 4200 times	
	clr.l	d0		put a nought in D0 (L) (ie 4 bytes)
.lp	move.l	d0,-(a0)	clear all that lot..
	move.l	d0,-(a0)	.. to erase any old data
	move.l	d0,-(a0)
	move.l	d0,-(a0)
	dbra	d7,.lp

setlowrez
	clr.w	-(a7)		0=low res
	move.l	$44e,-(A7)	physbase
	move.l	$44e,-(A7)	logbase
	move.w	#5,-(A7)
	trap	#14		low res needed to see Degas pic	
	lea	12(A7),A7

* >>>>>>  Important note   <<<<<
	dc.w	$a000		this section MUST be removed if chainer...
	movea.l	8(a0),a0	.. is in an auto folder, as GEM hasn't...
	clr.w	(a0)		..been initialized yet
	dc.w	$a00a		hidemouse GEM call
* >>>>>                    <<<<<

	move.l	$44e,d0		system variable (screen location)
	move.l	d0,physbase	save original 'physbase'
	sub.l	#32768,d0	point 32K down
	move.l	d0,$45e		ask $45e to show new (blank) screen

vsync	
	move.w	#37,-(sp)	wait for vertical blank
	trap	#14
	addq.l	#2,sp

* load a degas picture at a specific address 
	move.w	#0,-(A7)	0 for open a file
	move.l	#name,-(A7)	name of picture to be loaded
	move.w	#$3D,-(A7)	code for open
	trap	#1		ask o/s to do it
	add.l	#8,sp		adjust stack pointer
	move.w	d0,handle	store 'handle' returned in d0, in a safe place
	tst.w	d0		test if negative by any chance...
	bmi	error		if so: file not found: branch to error

	move.l	physbase,d0	load direct to this address
	sub.l	#34,d0		or more precisely, here.
	move.l	d0,-(sp)	pass load address to stack
	move.l	#32066,-(A7)	read 32066 bytes (ie a degas picture)
	move.w	handle,-(A7)	retrieve that handle	
	move.w	#$3F,-(A7)	code for read	
	trap	#1		ask o/s to do it
	adda.l	#$C,A7		adjust stack pointer when all done

	move.w 	handle,-(SP)	retrieve handle again
	move.w 	#$3E,-(SP)	code for close
	trap 	#1		ok do it
	addq.l 	#4,SP		adjust stack as ususal

	move.l	physbase,d0	put physbase address in a0
	sub.l	#32,d0		deduct 16 words from it
	move.l	d0,-(SP)	that's where the palette starts  
	move.w	#6,-(SP)	call 'change palette' routine
	trap	#14		ok
	addq.l	#6,SP		all done

	move.l	physbase,$45e	SHOW it

	move.w	#37,-(SP)	vsync routine
	trap	#14		ok do it
	addq.l	#2,SP		adjust stack
; wait for v/b to be certain

	move.w	#$07,-(sp)    	getkey code
	trap	#1		call o/s
	addq.l	#2,sp

	move.l	$4de,$200	store vector in a safe place like $200
; from now on, even if we turn music off by putting a nought (L) in $4de,
; we can still retrieve both tunes by either peeking $200 or $204!

	move.l	#environment,-(sp)	call next program
	move.l	#environment,-(sp)  
	pea	name3			ie DARTS or whatever
	move.w	#0,-(sp)		chain 
	move.w	#$4b,-(sp)		execute
	trap	#1		
	adda.l	#$10,sp

error
quit
	move.l	#0,$4de			stop v/b interrupt: music off	
	lea	$ff8800,a0		get sound chip 
	move.b	#7,(a0)
	move.b	#%11111111,2(a0) 	cut out lingering noises
	move.l #$8000000,$ff8800 
	move.l #$9000000,$ff8800 
	move.l #$a000000,$ff8800 

	move.w  res,-(sp)	old resolution back
	move.l  #-1,-(sp)	no change in screen locations
	move.l  #-1,-(sp)	physical or otherwise
	move.w  #5,-(sp)
	trap    #14		call o/s
	add.l   #12,sp		ok screen now back as we found it

	movem.l	palette,d0-d7	get those original palette colours again
	movem.l	d0-d7,$ff8240	and pass them to video chip
	
superout
 	move.l 	super,-(SP)	retrieve user stack pointer
 	move.w 	#$20,-(SP)
 	trap 	#1
 	addq.l 	#6,SP		we're now back in user mode

	clr.w	-(sp)		exit to desktop
	trap	#1

*-------------------------------------

environment
	dc.b	0,0,0,0,0,0 

	even

res	dc.w	0	the original resolution
handle	dc.l	0	needed for opening files
super	dc.l	0	the original stack pointer
physbase	
	dc.l	0	the original screen address at start of prog
palette	ds.w	18
	ds.w 	256	512 bytes (more than enough) for our stack
stack	dc.l 	0	our private stack