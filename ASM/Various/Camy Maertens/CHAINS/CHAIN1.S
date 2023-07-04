* Aug 3 1989  **** Budgie UK
* Basic CHAIN routine     CHAIN1.S
* vertical slot used is $4de
*------------------------------------------**

* reallocate unused memory to Gemdos
m_shrink
	MOVEA.L	A7,A5		save stack pointer
	move.l 	#stack,A7	set up local stack
	MOVEA.L	4(A5),A5	basepage address i.i. program start
	MOVE.L	12(A5),D0	get length of text (the code)
	ADD.L	20(A5),D0	add length of defined data (DC.W...)
	ADD.L	28(A5),D0	add length of BSS reserved space (DS.W...)
	ADDI.L	#256,D0		add basepage length
	MOVE.L	D0,-(A7)		total memory required
 	MOVE.L	A5,-(A7)		program start address
	CLR.W	-(A7)		junk word
	MOVE.W	#$4A,-(A7)	SETBLOCK command
	TRAP	#1		
	LEA	$0C(A7),A7

	bra	over

name1	dc.b	"a:\tunes_1\anth*.prg",0  v/b music


name2	dc.b	"a:\budgie.med\per*.prg",0
	even

over	move.w  #4,-(sp)		get resolution        
	trap    #14
	addq.l  #2,sp
	move.w  d0,oldrez		and save it

	dc.w	$a000
	dc.w	$a00a


* call and execute next program

	move.l	#environment,-(sp)	call program one
	move.l	#environment,-(sp)
	pea	name1		
	move.w	#0,-(sp)	chain this routine
	move.w	#$4b,-(sp)	execute it
	trap	#1		
	adda.l	#$10,sp


getkey	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	andi.w	#$df,d0

* if we ever come back here, call next one!
cont
	move.w  #1,-(sp)	
	move.l  #-1,-(sp)
	move.l  #-1,-(sp)
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp


	move.l	#environment,-(sp)	call program two
	move.l	#environment,-(sp)
	pea	name2
	move.w	#0,-(sp)	chain this routine
	move.w	#$4b,-(sp)	execute it
	trap	#1		
	adda.l	#$10,sp

* if we ever come back here, resume with this loader
quit

	move.w  oldrez,-(sp)	old resolution back
	move.l  #-1,-(sp)
	move.l  #-1,-(sp)
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp
* in this example, just exit...

	move.w	#0,-(sp)	back to desktop
	move.w	#$4c,-(sp)
	trap	#1


	even
lo0	ds.w	64		
environment
	dc.b	0,0,0,0,0,0
	even
text	dc.b	10,10,10,10,10,13,13,13
	dc.b	" Press ESC to quit                ",10,13
 	dc.b	" Any other key to load PERUSER    ",10,13
	dc.b	" HELP to toggle music at any time ",10,13
	dc.b	" UNDO to kill music interrupt     ",10,13,0
	dc.b	" Press ESC to quit                ",10,13
	even
oldrez	dc.w	0
	ds.w 256
stack	dc.l 0