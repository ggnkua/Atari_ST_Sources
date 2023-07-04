*  Budgie UK    chain_5  (cycling) 
*  
*  a chain program which loads a tune, then a picture,
*  waits for a key. When hit, scrolls screen down,
*  cuts out the music interrupt, but stores it in $210
*  waits for key again. When hit, scrolls screen back up 
*  recalls the interrupt: move.l $210,$4ce+4
*  or, in Basic, Loke $4ce+4,leek($210)
*  Some earlier music by Goth was slotted in $4de.
*  This latest bath (August 1990) uses the V/b slot at $4ce+4
*  (ie $4d2) so please note.

*  View in medium res *
*  comments (;) always FOLLOW the instructions
*  Devpac 2 required to assemble
*  Aug 2 1990   Music by Goth of The Shapeshifters
* (c) Budgie UK , Camy Maertens and Shapeshifters
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

name	dc.b	"a:\chains\wave*.pi1",0  change d to a if necessary
name1	dc.b	"a:\tunes_2\colours.prg",0   this is the tune. 
name2	dc.b	"a:\chains\poir*.prg",0       this is the main prog afterwards
	even
; bra.s start means 'branch (short) to start'
; in order to skip the above labels, which are not instructions
; dc.b  means declare bytes

start	clr.l	-(sp)		Budgie progs ALWAYS run in supervisor
 	move.w #$20,-(sp) 	
 	trap #1
 	addq.l #6,SP
 	move.l d0,super

	move.w  #4,-(sp)	get res
	trap    #14
	addq.l  #2,sp
	move.w  d0,res		and save it

	movem.l	$ff8240,d0-d7 	save palette
	movem.l	d0-d7,palette

	move.l	#environment,-(sp)	call program one ie music
	move.l	#environment,-(sp)  
	pea	name1			whatever it is
	move.w	#0,-(sp)	chain this routine
	move.w	#$4b,-(sp)	execute it
	trap	#1		
	adda.l	#$10,sp
; above 'chained' prog can be anything.

setlowrez
	clr.w	-(a7)		0=low res
	move.l	$44e,-(A7)	-1=ignore physbase
	move.l	$44e,-(A7)	-1=ignore logbase
	move.w	#5,-(A7)
	trap	#14		
	lea	12(A7),A7

	dc.w	$a000
	movea.l	8(a0),a0
	clr.w	(a0)
	dc.w	$a00a		hidemouse

	move.l	$44e,d0
	move.l	d0,physbase	save original 'physbase'
	sub.l	#32768,d0
	move.l	d0,$45e		show blank screen

vsync	
	move.w	#37,-(sp)
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
	move.w	#$007,$ff8240

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

	move.l	physbase,$45e

	move.l	#r_loop,$4de	insert cycling v/b interrupt

	move.w	#37,-(SP)	vsync routine
	trap	#14		ok do it
	addq.l	#2,SP		adjust stack
; wait for v/b to be certain
	bra	over

************************************************************************
*
* 	palette rotator prog
* 	rough & ready!
*
*************************************************************************
* interrupt routine starts here
r_loop	
	sub.w	#1,bill
	tst.w	bill
	beq	ok
	rts

ok	
	move.w	#1,bill			speed of cycling 1=fast
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	move.l	d1,-(sp)

	lea	$ff8240,a0		a0 is hardware palette
	lea	r_palette,a1		a1 is our palette, reserved later

	move.w	$00(a0),$00(a1)		border = same on new palette

	move.w	$1e(a0),$02(a1)		next one is hardware colour #15

	move.w	$02(a0),$04(a1)		the other 14 colours are
	move.w	$04(a0),$06(a1)		shifted one word along
	move.w	$06(a0),$08(a1)
	move.w	$08(a0),$0a(a1)
	move.w	$0a(a0),$0c(a1)
	move.w	$0c(a0),$0e(a1)
	move.w	$0e(a0),$10(a1)
	move.w	$10(a0),$12(a1)
	move.w	$12(a0),$14(a1)
	move.w	$14(a0),$16(a1)
	move.w	$16(a0),$18(a1)
	move.w	$18(a0),$1a(a1)
	move.w	$1a(a0),$1c(a1)
	move.w	$1c(a0),$1e(a1)

	move.l	a1,$45a			present new palette at next vbi

	move.l	(sp)+,d1
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	rts

over	move.w	#$07,-(sp)    	getkey
	trap	#1		
	addq.l	#2,sp
error
next	move.w  #1,-(sp)	MEDIUM res
	move.l  #-1,-(sp)	no change in screen locations
	move.l  #-1,-(sp)	physical or otherwise
	move.w  #5,-(sp)
	trap    #14		call o/s
	add.l   #12,sp		ok screen now back as we found it
	
	clr.l	$4de		cycling off
	move.w	#37,-(sp)	wait for vb to deactivate it
	trap	#14
	addq.l	#2,sp

	movem.l	palette,d0-d7	get those original palette colours again
	movem.l	d0-d7,$ff8240	and pass them to video chip

	move.l	#environment,-(sp)	call program one ie music
	move.l	#environment,-(sp)  
	pea	name2			whatever it is
	move.w	#0,-(sp)	chain this routine
	move.w	#$4b,-(sp)	execute it
	trap	#1		
	adda.l	#$10,sp

	move.l	#0,$4ce+4	music off	
	lea	$ff8800,a0	get sound chip 
	move.b	#7,(a0)
	move.b	#%11111111,2(a0) cut out lingering noise
	move.l #$8000000,$ff8800 
	move.l #$9000000,$ff8800 
	move.l #$a000000,$ff8800 

	move.w  #-1,-(sp)	
	move.l  #-1,-(sp)	no change in screen locations
	move.l  #-1,-(sp)	physical or otherwise
	move.w  #5,-(sp)
	trap    #14		call o/s
	add.l   #12,sp		ok screen now back as we found it
superout
 	move.l 	super,-(SP)	retrieve user stack pointer
 	move.w 	#$20,-(SP)
 	trap 	#1
 	addq.l 	#6,SP		we're now back in user mode

	clr.w	-(sp)		exit to desktop
	trap	#1

*-------------------------------------
bill	dc.w	5
environment
	dc.b	0,0,0,0,0,0 

	even

res	dc.w	0	the original resolution
handle	dc.l	0	needed for opening files
super	dc.l	0	the original stack pointer
physbase	
	dc.l	0	the original screen address at start of prog
;	ds.w	256 
palette	ds.w	18
	ds.w 	256	512 bytes (more than enough) for our stack
stack	dc.l 	0	our private stack
r_palette
;	ds.w	218
