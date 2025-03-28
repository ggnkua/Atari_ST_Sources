*  Budgie UK    - Commented souce codes series -
*  View in medium res *
*  comments (;) always FOLLOW the instructions
*  Devpac 2 required to assemble
*  version 1.2   March 21,1990  
*------------------------------------------**

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

	bra.s	start

name	dc.b	"a:\tunes\crossw*.pi1",0
name1	dc.b	"a:\tunes\anthem*.prg",0
name2	dc.b	"a:\tunes\dream_16.prg",0
	even
; bra.s start means 'branch (short) to start'
; in order to skip the above labels, which are not instructions
; dc.b  means declare bytes

start
	move.l	#environment,-(sp)	call program one
	move.l	#environment,-(sp)
	pea	name1		
	move.w	#0,-(sp)	chain this routine
	move.w	#$4b,-(sp)	execute it
	trap	#1		
	adda.l	#$10,sp
; the above is the standard 'load and execute' routine
; we call it 'chain'
; the first two lines are set and never vary.
; just make sure there is an environment label at the end of this prog
; next line pushes effective address of next program's name onto stack
; next line pushes a nought onto stack
; next line pushes the execute code $4b onto stack
; next line passes control to a routine held in rom, whose address
; in held in a zero page 'vector'
; when all is done, stack pointer has to be adjusted (by 16 bytes)

 	clr.l	-(sp)
 	move.w #$20,-(sp) 	Super.
 	trap #1
 	addq.l #6,SP
 	move.l d0,super
; above is standard routine to go supervisor.
; all Budgie programs run in supervisor. Essential.
; old default stack pointer is stored in a location at the end of
; this prog, called 'super'. It's a long word (L).


	move.w  #4,-(sp)	get res
	trap    #14
	addq.l  #2,sp
	move.w  d0,res		and save it
; standard get res routine. Answer returned (as usual) in d0
; store answer in label 'res' for future use. (ie when we exit)

	movem.l	$ff8240,d0-d7 	save palette
	movem.l	d0-d7,palette
; standard way of copying 32 bytes from one place to another in one go!
; $ff8240 is start of color registers in video chip
; first line copies all 8 long words (32 bytes) into d1,d2,d3 etc...
; second line dumps d1,d2,d3,etc... into a buffer at the end of prog.
; make sure that buffer has been reserved.

setlowrez
	clr.w	-(a7)		0=low res
	move.l	$44e,-(A7)	-1=ignore physbase
	move.l	$44e,-(A7)	-1=ignore logbase
	move.w	#5,-(A7)
	trap	#14		
	lea	12(A7),A7
; the above is the standard way of going into low res (mode 0)
; clr.w  actually means: put a zero in...
; $44e is a systems variable where current physbase address is held
; lea 12(a7),a7 is same as add.l #12,a7
; a7 is same as sp  (stack pointer)	

	dc.w	$a000
	movea.l	8(a0),a0
	clr.w	(a0)
	dc.w	$a00a		hidemouse
; the above hides mouse.  dc.w $a00a  is normally enough

	move.l	$44e,d0
	move.l	d0,physbase	save original 'physbase'
	sub.l	#32768,d0
	move.l	d0,$45e		show blank screen
; first line stores screen address in D0
; next then line puts it in our variable 'physbase'
; move.l $44e,physbase  would have done precisely the same thing
; another way of doing it:
;       lea $44e,a0  lea physbase,a1  move.l (a0),(a1)
; next line subtracts 32768 from value held in d0. Notice the #
; next line puts that value inside $45e
; $45e is a variable read 50 times a second by the operating system.
; whatever we put there will be the START ADDRESS of screen display,
; next vertical blank. We are in effect telling the video chip
; to start displaying an area of memory 32768 bytes below where we are now
; the result will be a blank screen.   

vsync	
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
; above is the standard routine for waiting for v/blank
; we had to wait for it to make sure our last order was carried out.

* load a degas picture at a specific address 
	move.w	#0,-(A7)	0 for open a file
	move.l	#name,-(A7)	crossw_1.pi1
	move.w	#$3D,-(A7)	code for open
	trap	#1		ask o/s to do it
	add.l	#8,sp		adjust stack pointer
	move.w	d0,handle	store 'handle' returned in d0, in a safe place
	tst.w	d0		test if negative by any chance...
	bmi	error		if so: file not found: branch to error
; standard 'open file' routine


	move.l	physbase,d0	load direct to this address
	sub.l	#34,d0		or more precisely, here.
	move.l	d0,-(sp)	pass load address to stack
	move.l	#32066,-(A7)	read 32066 bytes (ie a degas picture)
	move.w	handle,-(A7)	retrieve that handle	
	move.w	#$3F,-(A7)	code for read	
	trap	#1		ask o/s to do it
	adda.l	#$C,A7		adjust stack pointer when all done
; above is the standard 'read' routine

	move.w 	handle,-(SP)	retrieve handle again
	move.w 	#$3E,-(SP)	code for close
	trap 	#1		ok do it
	addq.l 	#4,SP		adjust stack as ususal
; above is standard 'close' routine

	move.l	physbase,a0	put physbase address in a0
	sub.l	#32,a0		deduct 16 words from it
	move.l	A0,-(SP)	that's where the palette starts  
	move.w	#6,-(SP)	call 'change palette' routine
	trap	#14		ok
	addq.l	#6,SP		all done
; above is standard 'change palette' routine

	move.l	physbase,$45e
; now that the picture has been loaded at original physbase,
; and that the palette has been properly defined, we are ready
; to actually DISPLAY it. Above line does just that.

	move.w	#37,-(SP)	vsync routine
	trap	#14		ok do it
	addq.l	#2,SP		adjust stack
; wait for v/b to be certain

	move.w	#$07,-(sp)    	getkey code
	trap	#1		call o/s
	addq.l	#2,sp
; standard routine for waiting for a keypress
; if you want to find out which key has been pressed, check D0 


* if we ever come back here, call next one!
cont
	move.l	#environment,-(sp)	call program two
	move.l	#environment,-(sp)
	pea	name2
	move.w	#0,-(sp)	chain this routine
	move.w	#$4b,-(sp)	execute it
	trap	#1		
	adda.l	#$10,sp

* if we ever come back here, resume with this loader
error
quit
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


	move.w	#0,-(sp)	back to desktop
	move.w	#$4c,-(sp)	notify o/s
	trap	#1		all done. Finished.

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