* yet another LINE by LINE commented 68000 source file
* from Budgie UK, based on a routine by MUG
* These LINE by LINE commentaries are for absolute beginners
* to 68000 machine language
* Also available: raster2.s  (multi-color interrupt)
* and shell1.s  (game backbone)
* Budgie UK  December 29, 1989
* 5 Minster Close    Rayleigh Essex  SS6 8SF 
* This routine will work in 50 or 60hz but not in 70hz   
*-------------------------------------------------------
	clr.l	-(sp)	
; decrement stack pointer by FOUR bytes, THEN clear that address
; clr.l means: put a LONG word zero (ie %00000000 00000000 00000000 00000000)

 	move.w	#$20,-(sp)
; once again, we decrement the stack pointer, THEN, we place the
; value $20 in the address pointed by it
; notice the hash
; move.w #$20,d0   means  put $20 in d0
; move.w $20,d0    means  put the CONTENTS of location $20 in d0

	trap	#1
; gem call: go supervisor
	addq.l	#6,sp
; back to our program. We did decrement the stack pointer by 6 bytes,
; (ie one LONG and one WORD). We now increment it by 6 to restore
; it as we found it.   addq.l  means add quick a LONG word
; the above FOUR instructions were one of those many TRAP CALLS
; where ready-made routines in ROM OS are called.
	move.l	d0,super
; the gem call we just made returned us an address in d0 which was
; the user stack. We shall need it again upon exit.
; let's store it for now in a variable called 'super'


	movem.l	$ff8240,d0-d7
; above instruction moves EIGHT consecutive LONG words in one go
; it's called multiple move.
; we take the contents of $ff8240, $ff8244, $ff8248, etc...
; and copy them in d0,d1,d2,d3,d4,d5,d6,d7
; $ff8240 is where the palette is stored
	movem.l	d0-d7,palette
; now we dump all eight registers, in one go, inside an array
; called 'palette'. The idea is to save default palette in a safe
; place so that we can retrieve it later when we exit
; have a look at 'palette' at the end of this prog:
; you'll find a RESERVED space for 16 words (ie 8 LONG words)	

	pea	text(pc)
; this means push effective address of text onto the stack
; text is a message that will be found at the end of this program
; this instruction is (pc) relative. It means it will work accurately
; no matter where in memory this program is loaded.
; (pc) relative coding is fairly rare.  It has been adopted here
; because this program will end up on the boot sector
; move.l #text,-(sp)  does the same job as    pea text(pc)
; so does  lea text,-(sp)
; but of course, they are NOT (pc) relative
	move.w	#9,-(sp)
; the number 9 is now pushed onto the stack
	trap	#1
; another trap call: this time a string output routine
	addq.l	#6,sp
; once again, we adjust stack pointer at the end of it

	pea	off(pc)
; we push effective address of 'off' onto stack
; we intend to ask the ikbd to stop reporting mouse events
	clr.w	-(sp)
; somehow a LONG zero is required, so we push that as well
	move.w	#$19,-(sp)
; now we push function number $19
	trap	#14
; the above trap instruction passes control to appropriate vector
; which in turn points to the right routine
	addq.l	#8,sp
; rectify stack pointer when all done

	move.w	#5,-(sp)	
; disable #5 interrupt on mfp
	move.w	#$1a,-(sp)
; function $1a deals with mfp interrupts
	trap	#14
; trap 14 does it
	addq.l	#4,sp
; correct stack pointer (2 WORDS, hence addq.l FOUR bytes)

	lea	pal_start(pc),a5
; load effective address of pal_start inside a5
	lea	pal_end(pc),a6
; now pal_end in a6
	clr.l	d2
; move a nought in d2 (LONG word)
; d2 will be used as a counter. Sometimes we count backwards.
; In this case, we'll start at zero
	move.w	#$777,$ff8242	
; put value $777 (white) inside $ff8242 (ink color)
	move.l	$70,-(sp)
; $70 is the system vertical blank vector (pointer)
; we've got to perserve it. We can either store it in a variable
; or, like here, store it on the stack
	lea	new_vb(pc),a0
; load effective address of new vertical blank routine in A0
	move.l	a0,$70
; now put the address in A0 inside $70. We now have a new
; vertical blank routine.
; Had we not required (pc) relative coding, the above two instructions
; could have been merged into one: move.l #new_vb,$70
; ie put the ADDRESS of new routine inside $70
	move.l	$68,-(sp)
	lea	new_hb(pc),a0
	move.l	a0,$68
; same thing with the $68 vector (horizontal blank routine)

	andi	#$f8ff,sr
; and the status register with $f8ff	
; and.w would also have been ok.  The assembler would change
; and.w into the more accurate andi (and immediate)
; notice the hash (#) (immediate value)
; the effect of this instruction is to set the interrupts level

a	cmp.b	#$73,$fffc02
; a is a label
; $fffc00 is the acia chip control register (the one that reports
; k/board and joystick interrupts from the ikbd)
; $fffc02 is the data register
; any byte received is stored in this register
; the above instruction checks $fffc02 against the value $73
; above instruction NOT recommended in mono 70 hz
	bcc.s	a
; branch if carry clear to a  (the .s means short ie within 128 bytes)
; in doubt don't put the .s  and let the assembler maximize the code
; if carry is clear (ie byte less than $74) we're not interested
; it's probably a mouse value
; the above two intructions will detect a keypress or a fire button

	ori	#$0300,sr	
; we're about to leave, so restore status register as normal

	move.l	(sp)+,$68	restore vectors
	move.l	(sp)+,$70
; retrieve the two vectors saved on stack 
; last first!    notice the synthax, with + AFTER the (sp)

	move.w	#5,-(sp)	enable #5 interrupt
	move.w	#$1b,-(sp)
	trap	#14
	addq.l	#4,sp

	pea	on(pc)		resume mouse reporting
	clr.w	-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp

	movem.l	palette,d0-d7
	movem.l	d0-d7,$ff8240
; retrieve palette from the array at 'palette'
; and multiple move all 16 WORDS in one go!
superout
 	move.l super,-(sp)
; retrieve user stack pointer from our safe variable
 	move.w #$20,-(sp)
 	trap #1
 	addq.l #6,sp
; we're now back in user mode

quit
 	move.w #0,-(sp)
 	move.l #1024*6,-(sp)
 	move.w #$31,-(sp)
 	trap #1
; terminate and stay resident


super	dc.l 	0
; the above long word reserved to store the old user stack address
palette	ds.w	16
; above 16-word array used to use initial palette
	rts
; above rts needed if run from boot sector





new_hb	
	move.w	#28-1,d1
; put 27 in data register d1
; we'll use it as a loop counter (28 times)
.loop	dbra	d1,.loop
; deduct one from d1, check if reached zero, and if not go back to .loop
; the above two lines are a time delay
; equivalent to basic's  for x=1 to 28:next

	addq.w	#1,d3
; add 1 to data register d3
	cmp.w	#150,d3
; compare d3 with number 154
; try changing this number to get different patterns
; but don't try 1 (bombs)
	bcc.s	.a
; branch if carry clear to  .a
	cmpi.w	#$fff,(a5)
; check if the CONTENTS of location pointed to by a5 is $fff
; (our end of palette marker)
	bne.s	.c
; branch if not equal to .c
; try removing above line: top pattern will disappear
	lea	pal_start(pc),a5
; load effective address of pal_start in a5
.c	move.w	(a5)+,$ff8240
; get the word pointed to by a5, (ie the first word in the palette array)
; and put that color in $ff8240, (the border register),
; THEN, increment address register a5 by TWO

	rte
; return from exception (end of horiz blank interrupt routine) 
.a	cmpi.w	#$fff,(a6)
	bne.s	.d
; removing above line will cancel bottom pattern
	lea	pal_start(pc),a6
.d	move.w	(a6)+,$ff8240
	rte
; above 4 lines already described, except that a6 is used



new_vb	
	moveq	#0,d3
; put a zero in d3: starting counter
	lea	pal_start(pc),a5
; try	lea 0,a5   or try  lea $466,a5  for random colors
	lea	pal_end(pc),a6
; don't try anything fancy with a6, as it gets DECREMENTED further down
; should it drop BELOW zero, bombs will appears...
	adda.l	d2,a5
; add d2 to a5  (ie: increment that address with our d2 counter
; which initially was nought) a5 now points somewhat HIGHER in memory
; ie further up the array
; add.l d2,a5  is also acceptable  (adda.l d2,a5 is the proper version)

	suba.l	d2,a6
; subtract d2 from a6 (in other words: get a6 to point somewhat LOWER
; in memory). When adding and subtracting to address registers, use L

	addq.l	#2,d2
; increment our counter
; the q is not indispensible (add.l #2,d2 is also OK)
	cmpi.w	#$fff,2(a5)
; see where a5 points to. ADD TWO BYTES to that location,
; and get that WORD. See whether it is $fff.
; suppose a5 points to $78000. The above instruction checks whether
; locations $78002-78003 contain $fff
; this addressing mode is essential in understanding how ARRAYS
; are accessed. Study it thoroughly. 
	bne.s	.a
; branch if not equal to .a
	moveq.w	#0,d2
; else reset counter
.a	rte
; end of vertical blank interrupt routine

pal_start
	dc.w	$000,$000,$101,$000
	dc.w	$101,$102,$101,$000
	dc.w	$000,$000,$101,$000
	dc.w	$101,$102,$101,$000
	dc.w	$000,$000,$101,$000
	dc.w	$101,$102,$101,$000
	dc.w	$000,$000,$101,$000
	dc.w	$101,$102,$101,$000
	dc.w	$000,$000,$101,$000
	dc.w	$101,$102,$101,$000
	dc.w	$000,$000,$101,$000
	dc.w	$101,$102,$101,$000
	dc.w	$000,$000,$101,$000
	dc.w	$101,$102,$101,$000
	dc.w	$101,$202,$301,$400
	dc.w	$401,$302,$200,$100
	dc.w	$220,$330,$441,$220
	dc.w	$101,$201,$301,$400
	dc.w	$501,$600,$703,$600
	dc.w	$500,$400,$301,$200

; above 80 words are colors used by interrupt routines
; try changing them (range allowed $000 to $777) (R-G-B)
; you may delete some of them, or add more colors (up to a point)





pal_en	dc.w	$0
pal_end	dc.w	$fff
off	dc.b	$12,0,0
on	dc.b	$8,0,0
text	
	dc.b	27,69		clear screen (mouse disappears)
	dc.b	27,98,1		ink color 1  try colors 2,3,stc..
	dc.b	10,10,10,10,10,10,10,10,10,10,10,10,10 line feeds
	dc.b	"       Hello.    Budgie UK   presents",10,13,0
