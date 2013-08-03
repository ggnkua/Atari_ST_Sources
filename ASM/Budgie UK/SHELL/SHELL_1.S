**   Dec 29 1989       Budgie UK  Shell  1 (commented)   ***
* This is the backbone of most Budgie games written in 68000 
* Virtually all macros in the macro file may be activated
* from this cut down shell.
* The full shell is available to all Budgie UK members
* this shell1.s is the first  in the LINE by LINE comments series
* Another such program is raster1c.s (multi-color interrupt)
* write if required.
* preferred assembler: DEVPAC2  from HiSoft
*--------------------------------------------------------***
	bra	start
; bra means branch. (goto in basic) . Another way is to use jmp.
; bra can branch as far as 32565 bytes either way
; jmp can jump anywhere in the prog.
; we normally use bra because it is more efficient 
	include "a:\includes\macros.s"
; ready-made 'basic-like' macros are an easy way of doing things
; include is a 'directive'. not an instruction as such.
	even
; let's play it safe, and continue with the next instruction...
; ... on an even boundary. 'even' is another 'directive'
start	startup	
; now that the 'macros' are loaded, let's use the first one:
; startup is a collection of about 12 instructions giving to gem
; all the unwanted memory. we'll just retain what we need for
; this program. No more.
; 'start' was a 'label'. Just like labels in basic.
; labels start on the first position of a line.
	jsr	superin		
; from now on, we're in supervisor mode
; jsr means jump to sub-routine  (gosub in basic)
; bsr (branch to sub-routine) would have done the same job as long 
; as superin was not more than 32565 bytes away.
	jsr	phys_base	
; another subroutine (part of include1.s) :get default physbase
	move.l	d0,physbase	
; the sub-routine returns the address of default physbase in d0.l
; as we will need it upon exit, let's store it in a variable.
; The chances are that the address returned is either $78000 or $f8000
	move.l	d0,screen_0	
; we will give this address our video screen: situated right
; at the top of free ram, this address is totally safe
	sub.l	#200*160,d0	
; we need another screen to display messages and other things
; let's subtract 32000 bytes from physbase
; that should be a safe place
; addresses are usually long words, hence the sub.l
; notice the hash (#)
	move.l	d0,utility_screen
; now we put d0 in another variable as we will no doubt need it later on.
; the l after move is indispensable
; remember: addresses are always LONG. That's the safe way.
	dc.w	$a000	
; special instruction: will cause an exception (software interrupt)
; program will be interrupted, execution will pass to a special vector
; where an operating system routine will be executed
; in this case:	initialize A-line. Then, program resumes normally.
	move.l	a0,a_line_start		and find where fonts are kept
	move.l	(a1)+,d0		6*6 font
	move.l	(a1)+,fontaddress_8	8*8
	move.l	(a1),fontaddress_16	8*16
; the above four lines are required by the font subroutine
; which is situated in include4.s  We'll take them for granted.
		
	hide_mouse	
; the above line is another 'macro'
	btst	#7,$fffa01	
; above instruction means test bit 7 of register $fffa01
; $fffa01 belongs to the mfp chip
; bit seven tells us whether monochrome is on
; bit 0 checks the centronics port, bit 4 k/board interrupts, etc..

	beq	hide		if on, skip low res 
; if bit seven is clear (0), we skip the low res instruction
; beq means branch if equal (to zero)
	mode	0		macro: low res
; if there is no monochrome, we come here and instruct the
; system to go low res. We use the 'mode' macro
; where 0 is low res and 1 is medium res

hide	cursor	0	
; another macro, this time to turn cursor off
; it is indispensable that all 75 macros currently in the library
; should be learned and understood

	bclr 	#0,$484		no keyclick
	bclr 	#1,$484		no repeat key
; the above two are bit instructions: a bit can be tested (btst),
; cleared (bclr) or set (bset)
; the above were cleared. $484 is a system variable.

	load	a1_font,a1_ptr		macro: font 16 pixels
	load	a2_font,a2_ptr		macro: font  8 pixels
; two more macros, meaning "load the font described in a1_font...
; ...and put its load address in a variable called a1_ptr"
; the load macro takes care of reserving the necessary memory
; required, so that there is no danger of that space being
; overwritten by something else
	
	reserve	512	
; anorther macro. We thought we would reserve 512 bytes
; as a safety buffer. Just a precaution.
	reserve	256*128		(32768 bytes)		
; we will be needing yet another screen, this time to load
; a title page. We could have chosen 32000 bytes BEFORE
; the utility screen we defined earlier.
; Instead, rather than TELLING gem where to put our picture,
; we will do the proper thing and ASK.
; Gem will return the start address in do.l as usual.
	clr.b	d0	
; As all screens should start on a 256 boundary, we make the start address
; divisible by 256, by clearing the last byte. (notice the b)
	move.l	d0,penny_ptr
; we can now store that address (long word), in our pointer
	open	penny	
; another macro. 'penny' is a string variable defined at the end
; of this text. It actually says 'a:\common\penny1.pi1'
; try changing it with your own pi1
; the file should now be duly opened. If it wasn't found, gem
; would report an error, and our routine (ie our macro) would
; automatically abort the load, and carry on.
	read	#palet,2	
; another macro: we read 2 bytes at an address called palet
; if you check the end of prog, you will see that space has been
; reserved for the palet (16 words)
; the two bytes we have just read were the res, and will be ignored
	read	#palet,32	
; so now we actually read the palette (32 bytes)
; the two bytes read earlier are overwritten
	read	penny_ptr,32000	
; we go on on reading, this time 32000 bytes (or whatever)
; these 32000 will be loaded where 'penny_ptr' POINTS to.
; notice the absence of hash. penny_ptr is NOT an actual area,
; it merely is a POINTER to an area.
; the rule is: actual address:hash,  pointer:no hash
; try replacing 32000 with 16000 and see what happens
	close	
; the final macro is this series
	palette	palet
; the above macro is very useful. It displays the palette
; referred to in the argument.
; try palette palet+2,  or palette $78000,  or palette $466 (the vb clock)

	show	penny_ptr	
; yet another macro. We now ask gemdos to display the picture we have
; just loaded. Gem will do it, in a fraction of a second, during
; the NEXT vertical blank interrupt
; All this macro does is: move.l penny_ptr,$45e
; $45e being the target screen NEXT vb
; while $44e is the CURRENT screen address
; If you want to know what screen you're looking at, just peek $44e
; if you want to look at another screen, just poke $45e 
; (or use 'show' macro...)

	font	16
; the above macro switches on the large font we had loaded earlier on
	home	
; this macro is actually needed to activate it
; the cursor is placed at 'home position' 0,0	
	ink	7	
; the 'ink' macro chooses the ink. In this case, the eighth color (0-15)
	string	<    HIT SPACE>
; another handy macro. Prints to screen, at current cursor position,
; whatever string is enclosed in the brackets
	getkey
; macro: wait for key to be hit (answer returned in d0)

 	lea 	vb_routine,a5	
	bsr	enable_vbi	
; load effective address of a routine called 'vb_routine' inside a5
; then branch to another subroutine called 'enable_vbi'
; the 'enable_vbi' routine obviously expected an address in a5.
; this is a very simple vertical blank routine. It merely
; increments a counter 50 times a second

	show	physbase	
; we were showing penny. now we're back to physbase (still blank probably)
	home
	ink	3
	string <hello all ST users>	
	string <This is PHYSBASE>
	font	8
; enough large characters. Now we're back to smaller ones
	pen	$700	
; pen is different from ink: it actually changes the palette color 15
; now we're about to write in red. See macros for full details
	printat	15,5,0,#message	
; a common macro: print in ink color 15, at location 5,0
; a string found under 'message'
; notice the hash (essential). Make sure the message ends with a 0
; forgetting the hash will probably bomb...
	wait	5	
; macro: wait 5 vertical blanks, ie 1/10th sec

	jsr	initjoy		initialize joystick
; jump to subroutine...
	font	16

*-----------------------  main --------------------------------
* this is the actual application: ie the thing you want to do.
* More often than not, all a program does is  read the keyboard
* or the joystick, and if either has been touched, go somewhere
* to a sub-routine or a sub-program, and then come back right here
* and wait, and wait...

* In our case, keyboard is scanned for f1-f10-h-esc
* then joystick is read for fire button only
* then the border value is continuously displayed
* on screen in hex (why not?)
* and then, we start again...

main	
	clr.l	d0	
	clr.l	d7
; d0 and d7 are used by the k/board and joystick routines
; it's a good idea to clean them up
; clr.l d0  means clear d0 (put a long word 0 in d0)
; same as move.l #0,d0    same as moveq.l #0,d0
	inkey	
; the above macro tests if keyboard has been hit
; if hit, answer is found in d0, with ascii value in lower word
; and scan value in upper word. 
; if no key was hit, d0 contains $0 and we just carry on with the program
	swap	d0	
; we're interested in the scan value, so we 'swap' low and high words
	cmp.b	#1,d0
; was the answer 1? If so escape must have been hit
; notice the synthax: compare with 1, register d0
; the reference figure comes first, THEN the register being investigated
	beq	kwit
; branch if equal (to one) to kwit
	cmp.b	#$23,d0		
; compare with 'H'
	beq	k_h
	cmp.b	#$3b,d0	
; compare with 'F1'	
	beq	k_f1
	cmp.b	#$44,d0	
; compare with 'F10'
	beq	k_f10
; if we ever come here, it means none of the above keys were hit
	
	joystick
; macro: read joystick and move on (answer is returned in d7)
	btst	#7,d7	
; test bit 7. If set (ie 1), fire was pressed
; bit 0 is for up, 1 for down, and so on...
; try replacing #7 with #0
	bne	flash_it	
; branch if not equal (to 0)  ie if fire was pressed
	
	move.l	$466,d0
; we need a fairly random number, which will also be ever-changing
; the v/b counter at $466 meets that requirement
; we move (ie copy) the CONTENTS of $466 into d0
; whatever was in d0 is now overwritten
	bindec	d0,16
; macro: convert d0 register from binary to hex ascii
; so that we may be able to read it on the screen
; try bindec d0,10   or bindec d0,2  (decimal and binary ascii respectively)	
; the ascii representation of the above number (in d0) will be stored
; in a workspace whose address is returned in a0
	printat	15,9,2,a0	
; macro: let's see it. Having converted d0 into ascii, we now want to
; display it on screen. The above macro will display on current screen,
; in color 15, at location 9,2, a string pointed to by a0	
; try printat 3,2,2,a0 and see color and position change
; try printat 15,9,2,a1 and see what happens
; try printat 15,9,2,$466 and watch totally random strings
; being printed on screen

	vsync	
; another macro: it waits for the video vertical blank
; its effect is to slow down the program to 50 frames a second
; not too important in this program, but essential in programs
; where sprites are drawn to screen
	bra	main	
; that's it: all done

*-------------- subroutines/ subprograms ----------------
* any routine that ends with 'rts' is a straight sub-routine
* anything that ends will 'bra main' is a mere diversion from main

* we come here if f1 has been hit
k_f1	move.w	color,$ff8240	
; $ff8240 is the first palette register (ie border)
; color is a variable (w), being incremented 50 times a second
; by our vertical blank routine
; we move the CONTENTS of color inside $ff8240
	move.l	$44e,save_screen	
; we're about to display another screen, so first we save the
; current screen. $44e contains its adddress (L)	
	show	utility_screen	
; the above macro display any screen you like, in this case
; utility_screen, whose start address had previously been stored
	font	8
	cls
; macro: clear current screen (ie fill it with 32000 noughts)
; clear $44e  would have done the same job
	printat	7,0,0,#games		ink 7   row 0   pos 0
	getkey	
; macro: unlike 'inkey', 'getkey' actually WAITS for a key to be hit
	cls	
	printat 6,0,0,#games1
; now print text starting at  games1
; in ink 6   location 0,0
	blank	$44e,1,(116*160)+88,41,144		
; above macro draws a rectangle, in color 1, position 116 y  88 x
; 41 pixels high, 144 pixels wide onto current screen

	take	$44e,$44e,(0*160)+48,(120*160)+96,33,56
; now grab a piece of screen from pos 0 y  48 x 
; and duplicate it on same screen, pos 120 y  96 x
; size 33 pixels high, 112 pixels wide	
	getkey
	show	save_screen	
; retrieve previous screen
	border	$777
; another macro: turn border white again
	font	16
	bra	main	
;	back to main loop
*---------------------------------------------------
* we come here if f10 has been hit
k_f10	font	16
	move.l	$44e,save_screen	remember screen we're on
	show	utility_screen
	cls
	home
	print	games			print message to it
	getkey
	bsr	disap
; branch sub routine (venetian blind effect)
	show	save_screen
	border	$777
	bra	main			back to main loop
*-----------------------------------------------
* we come here if 'h' has been hit
* this is how to print 'HELLO' ..... (big deal!)
k_h
	string	<HELLO>
	getkey
	not	$ff8240	
; not is an interesting instruction: all 0 bits become 1
; and all 1's become 0's    In this case, we reverse the color in $ff8240
	wait	5	
; macro wait 5 vertical blanks (otherwise flash will be TOO quick)
	not	$ff8240	
; reverse it again (flash)
	clear	$44e	
; macro: same as cls
	bra	main
*----------------------------------------------------	
* this routine is slotted in the v/b queue 
* and will be executed 50 times a second in 50 hz
vb_routine
	sub.w	#1,color
; subtract 1 from the CONTENTS of color
	tst.w	color
; test if zero
; cmp.w #0,color  would have been the same,  but slower
	bmi	.v
; branch if minus
; once below zero, we've gone too far. Time to adjust it again!
	rts
; return from subroutine (same as 'return' in basic)
.v	move.w	#$777,color
; put the number $777 inside color. Notice the hash (immediate value)
	rts
; labels such as '.v' have a dot in front of them.
; they are known as local labels
*--------------------------------------------------
flash_it
	show	penny_ptr
	not	$ff8240		reverse border
	wait	7
	not	$ff8240		and again
	show	physbase
	bra	main
*--------------------------------------------------
kwit	move.l	#vb_routine,a5	
; put the ADDRESS of vb_routine inside a5  (LONG word for addresses)
; (same as: lea vb_routine,a5)  
	bsr	disable_vbi
; disable the above v/blk routine
	bra 	quit 
; restore palette and official quit

*~~~~~~~~~~~~~~~~~~~~~~~INCLUDES~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* now we will include our libraries of routines, representing
* thousands of hours from many dedicated contributors!
	EVEN
	INCLUDE "a:\includes\include1.s"
	EVEN
	INCLUDE "a:\includes\include2.s"
	EVEN
	INCLUDE "a:\includes\include3.s"
	EVEN
	INCLUDE "a:\includes\include4.s"
	EVEN

*~~~~~~~~~~~~~~~~~VARIABLES AND CONSTANTS~~~~~~~~~~~~~~~~~*
* there now follows a section with variables.
* the things to remember are:
* dc.w  means DECLARE a word  ( or DEFINE CONSTANT)
* fred dc.w 3    means  fred=3  with 2 bytes allocated to the variable fred
* having made fred a word, its maximum value will therefore be 65535
* fred dc.w 3  actually means %00000000 00000011
* so if later you were to (mistakenly) say add.b #1,fred
* fred would become           %00000001 00000011
* the proper way is	: add.w #1,fred
* ie        		      %00000000 00000100

* fred dc.l 3 means  fred=3  with 4 bytes allocated to the variable fred
* if we were to say  move.l #3,fred
* fred would look like this: %00000000 00000000 00000000 00000011

* as a rule, for numeric data variables, use  dc.w
* and for addresses (pointers)    	 use  dc.l

* dc.b 2	means DECLARE a byte as '2'
* dc.b 2,3,4,5  means DECLARE a byte as 2, then another as 3, etc..

* dc.b "hello fred",10,13,0  means DECLARE a byte as h, then another as e,
*    then l,l,o, ,f,r,e,d, than 10 (line feed), then 13 (c/return), then 0


* ds.b 10  means  DEFINE SPACE for 10 bytes
* it's the same as dc.b 0,0,0,0,0,0,0,0,0,0

* ds.w 5  means  DEFINE SPACE for 10 bytes (5 words)
* it's the same as dc.b 0,0,0,0,0,0,0,0,0,0 

* ds.l 1  means  DEFINE SPACE for 4 bytes (1 long word)
* it's the same as dc.b 0,0,0,0




hbl_ct		dc.w 0
before		dc.w 0	position of horiz raster before test,
after		dc.w 0  and after.
color		dc.w 0
store		dc.w 0
storel		dc.l 0
a1_font		dc.b 	"a:\fonts\a1_fat*.fon",0
a2_font		dc.b 	"a:\fonts\a2_squa*.fon",0
		even
a1_ptr		dc.l 1		pointer 16*8 font
a2_ptr		dc.l 1		pointer 8*8 font
screen_0	dc.l 0		pointer	
screen_1	dc.l 0		more pointers
screen_2	dc.l 0
screen_3	dc.l 0
spr_screen	dc.l 0
utility_screen 	dc.l 0
lady_screen	dc.l 0
penny		dc.b "a:\common\penny.pi1",0
		even
penny_ptr	dc.l 0		pointer
prompt		dc.b "hello",0
games		dc.b "This is utility screen",10,13
		dc.b "32000 bytes below physbase",10,10,13	
		dc.b "Handy for messages.",10,13,0
games1		dc.b "Libraries and macros",10,13
		dc.b "are loaded during assembly",10,10,13
		dc.b "On the right is an example of",10,13
		dc.b "BLANK macro   and  TAKE macro",10,13,0
message		dc.b "Notice the two new fonts now active",10,13
		dc.b "They were loaded with LOAD macro",10,13
		dc.b "and activated with FONT macro",10,10,13
		dc.b "A value in hex is being displayed",10,13
		dc.b "using the BINDEC, PRINTAT macros.",10,10,13 
		dc.b "Press  F1    F10    Esc  or Fire",10,13,0
		even

palet		ds.w 16		means reserve 16 words (32 bytes)		

		even

*~~~~~~~~~~~~~~~~~~~THE STACK~~~~~~~~~~~~~~~~~~~~~~~~~~*

		ds.l	256	about 64 used on average
stack		dc.l	0	means declare 1 long word as zero

*----------------------------------------------------------*
* BUDGIE UK . BUDGIE UK . BUDGIE UK . BUDGIE UK . BUDGIE UK .
* 5 MINSTER CLOSE, RAYLEIGH   ESSEX  SS6 8SF   GREAT BRITAIN
*----------------------------------------------------------*

