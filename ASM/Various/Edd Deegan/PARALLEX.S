* This code is original, programmed by Edd Deegan
* All copies of the source must bear my name.
* -- Edd Deegan

* !! IT USES THE DEVPAC II incbin DIRECTIVE !!

* \Header for Assembler programs. It basically puts all the available
*  memory at my disposal....
*

setblock:       movea.l A7,A5           * Save stack pointer
                move.l  #my_stack,A7    * Set up my own stack
                movea.l 4(A5),A5        * A5 now points to BasePage
                move.l  $C(A5),D0       * $C(A5) = program area length
                add.l   $14(A5),D0      * $14(A5) = data area length
                add.l   $1C(A5),D0
                add.l   #$100,D0        * Reserve $100 bytes BasePage
                move.l  D0,-(sp)        * D0 = length to be reserved
                move.l  A5,-(sp)        * A5 = start address to reserve
                move.w  #$00,-(sp)      * No meaning
                move.w  #$4A,-(sp)
                trap    #1
                add.l   #12,sp          * Correct the stack
                jmp     end_set         * Jump over my stack!
                ds.l    200             * Space for my stack
my_stack:       ds.l    2               * Stacks go backwards....
                EVEN
end_set:        nop
*----> Rest of program can now follow.

* \This is a routine to parallex scroll a three-layer scroll, each layer
*  being one bitplane.
* \The area scrolled is a quarter of the screen. (Same as scrolling
*  3/4 of the screen in one plane, datawize).

setups:		move.l	#$00,-(sp)	* Super mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,save_stack

		move.w	#2,-(sp)	* Get PHYS_BASE
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_phys
		move.w	#3,-(sp)
		trap	#14
		addq.l	#2,sp		* Get LOG_BASE
		move.l	D0,real_log

		move.w	#4,-(sp)	* Get rez
		trap	#14
		addq.l	#2,sp
		move.w	D0,old_rez
		cmp.b	#$2,D0		* High?
		beq	sorry


		move.l	real_phys,D0	* Point to current screen
		move.l	D0,physic
		sub.l	#32256,D0	* Point to a logical screen
		move.l	D0,logic

		lea	old_palette,A0
		move.l	#$FF8240,A1	* Point to colors
		move.l	#15,D0		* Counter
save_cols:	move.w	(A1)+,(A0)+	* Save color
		dbf	D0,save_cols	* And repeat 15 times more
		jsr	msoff

		move.w	#$00,-(sp)	* Low rez
		move.l	physic,-(sp)
		move.l	logic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		lea	graphic,A0
		addq.l	#2,A0
		move.l	A0,-(sp)
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp		* Set colors

		lea	graphic,A0	* Pre-calculate image addresses
		lea	34(A0),A0
		move.l	A0,bigdata	* Point to actual data

		lea	2(A0),A0	* Point to 2nd plane
		move.l	A0,image_1	* Which contains image #1
		lea	82(A0),A0	* Point to 3rd plane
		move.l	A0,image_2	* Which contains image #2
		lea	graphic,A0	* Point to 4th plane
		lea	34(A0),A0
		lea	16006(A0),A0	* Containing image #3
		move.l	A0,image_3

		move.l	#32000,-(sp)
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	D0
		bmi	malloc_er
		move.l	D0,workspace
		move.l	D0,A3

		move.l	#7999,D0
		move.l	physic,A0
		move.l	logic,A1	* Clear screens
clear:		clr.l	(A0)+
		clr.l	(A1)+
		clr.l	(A3)+
		dbf	D0,clear

* \Ready for the guts of program now....
* \First, just place blocks onto dest address over each other

		move.l	logic,A1	* Want to display a block
		move.l	#2,D0		* In plane 2
		jsr	place_plane	* Do it

		move.l	logic,A1	* Another one...
		move.l	#3,D0		* In plane 3
		jsr	place_plane

		move.l	logic,A1	* A third
		move.l	#4,D0		* Plane 4
		jsr	place_plane
		
		move.l	physic,A1	* Want to display a block
		move.l	#2,D0		* In plane 2
		jsr	place_plane	* Do it

		move.l	physic,A1	* Another one...
		move.l	#3,D0		* In plane 3
		jsr	place_plane

		move.l	physic,A1	* A third
		move.l	#4,D0		* Plane 4
		jsr	place_plane

		pea	text
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp
		jmp	after_text

text:	dc.b	$1B,"Y",45,32			* Set curs position
text2:	dc.b	"  This is a quick 'n dirty parallex",13,10
	dc.b	"scroller. It runs smooth enough, but",13,10
	dc.b	"could be improved. Distributions of",13,10
	dc.b	"the source code must bear my name!!",13,10
	dc.b	"--Edd Deegan",0
		EVEN

after_text:	jsr	wait_vbl	* Swap screens

		pea	text
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp
		jsr	wait_vbl

* \Create offset

scroll:		move.l	#3,D0		* Plane X
		move.l	#2,D1		* X pixel(s) at a time
		move.l	logic,A1	* On logical screen
		jsr	move_plane

		move.w	#4,D0
		move.w	#1,D1
		move.l	logic,A1
		jsr	move_plane

		move.w	#2,D0
		move.w	#3,D1
		move.l	logic,A1
		jsr	move_plane
		jsr	wait_vbl

scroll2:	move.l	#2,D0		* Scroll 2nd plane
		move.l	#6,D1		* 
		move.l	logic,A1	* On new logical screen
		jsr	move_plane

		move.w	#3,D0
		move.w	#4,D1
		move.l	logic,A1
		jsr	move_plane

		move.w	#4,D0
		move.w	#2,D1
		move.l	logic,A1
		jsr	move_plane
		jsr	wait_vbl

		bra.s	scroll2

* \Routines to carry out manipulation of bitplanes... 
*  Need 1) Routine to scroll bitplane in D0, D1 pixels up, at A1.
*       2) Routine to place raw bitplane image D0, at (A1)

place_plane:	move.l	D0,D2		* Save D0
		subq.w	#$01,D0
		asl.w	#$01,D0		* D0 *= 2
		add.l	D0,A1		* Create byte offset...

		lea	dummy,A0
		subq.w	#$01,D2
		asl.w	#$02,D2		* Now D0 = *4
		add.l	D2,A0		* A0 -> Image pointer
		move.l	(A0),A0		* A0 -> Image

* ---> Now place block in ONE plane only.

place_plane1:	move.l	#99,D0		* Line counter
place_plane2:	move.l	#9,D1		* Word counter
place_plane3:	move.w	(A0),(A1)	* Place word
		lea	8(A0),A0	* Point to next word
		lea	8(A1),A1	* Point to next word
		dbf	D1,place_plane3	* Repeat for rest of line
		
		lea	80(A0),A0	* Point to next LINE
		lea	80(A1),A1	* Ditto
		dbf	D0,place_plane2
		rts

* \Plane now placed......

* ----> Move bitplane in D0, D1 pixels UP..... (2,3 or 4)
* ----> Action takes place in address pointed to by A1

move_plane:	subq.w	#$01,D0
		asl.w	#$01,D0		* D0 = D0*2
		add.l	D0,A1		* Point to start of area

* --> Now scroll plane pointed to by A1, up by D1 pixels

move_plane2:	move.l	A1,A4		* Save for later
		lea	workspace,A2	* A2 -> Buffer
		subq.b	#$01,D1		* Create a dbf value
		move.l	D1,D4		* Save for later
		move.l	D1,D5		* And later still

move_plane3:	move.l	#9,D3		* Words per plane per line
move_plane4:	move.w	(A1),(A2)+	* Store line in buffer
		lea	8(A1),A1	* Next word
		dbf	D3,move_plane4
* --> Right. We have got one line in the buffer.
* --> Repeat for D1 lines
		lea	80(A1),A1	* Next line
		dbf	D1,move_plane3

* ---> So we have now stored the top D1 lines
* ---> Now shift from A1 onwards, until we hit 100 lines...

		move.l	#98,D1		* Total lines
		sub.w	D4,D1		* Minus the ones taken

move_plane5:	move.l	#9,D3		* Word counter
move_plane6:	move.w	(A1),(A4)	* Copy up
		lea	8(A1),A1	* Next word (source)
		lea	8(A4),A4	* Next word (dest)
		dbf	D3,move_plane6

		lea	80(A1),A1	* Down a line
		lea	80(A4),A4
		dbf	D1,move_plane5	* Repeat for ? lines

* ---> Doesnt get here <-------*

* ---> Now retrieve buffer contents, placing at A4 onwards
* ---> Loops to perform in D5

		lea	workspace,A0	* Point to buffer
move_plane7:	move.w	#9,D3		* Word counter
move_plane8:	move.w	(A0)+,(A4)
		lea	8(A4),A4	* Next word
		dbf	D3,move_plane8

* ---> Now repeat for D5 loops

		lea	80(A4),A4	* Down a line
		dbf	D5,move_plane7
		rts

* /Routine to wait for a VBL interrupt.

wait_vbl:	move.w	physic2,A6
wait_vbl1:	move.b	$FF8207,video
		move.b	$FF8209,video2
		cmp.w	video,A6
		bne	wait_vbl1
	
		move.l	physic,temp
		move.l	logic,physic
		move.l	temp,logic	* Swap pointers

		move.w	#-1,-(sp)
		move.l	physic,-(sp)
		move.l	logic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(A7),A7

		move.b	$FFFC02,D0
		cmp.b	#$39,D0
		beq	exit2
		rts		


	
* ---> Error routines

sorry:		pea	wrong_rez
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp
		jmp	exit
		nop
malloc_er:	pea	malloc_mes
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp
		jmp	exit

exit:		nop
		move.w	#$08,-(sp)
		trap	#1
		addq.l	#2,sp
exit2:		move.l	workspace,-(sp)
		move.w	#$49,-(sp)
		trap	#1		* Free memory
		addq.l	#6,sp

		move.w	old_rez,-(sp)
		move.l	real_phys,-(sp)
		move.l	real_log,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	#15,D0
		lea	old_palette,A0
		move.l	#$FF8240,A1
restore_cols:	move.w	(A0)+,(A1)+
		dbf	D0,restore_cols	
		jsr	mson

		move.l	save_stack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.l	-(sp)
		trap	#1

* ----> Error messages
wrong_rez:	dc.b	"Sorry - LOW/MEDIUM rez only....",13,10,0
malloc_mes:	dc.b	"Sorry - not enough free RAM to work with!",13,10,0

		EVEN

* ----> Storage
old_rez:	ds.w	1
video:		ds.b	1
video2:		ds.b	1
temp:		ds.l	1
old_palette:	ds.w	16
save_stack:	ds.l	1
real_phys:	ds.l	1
real_log:	ds.l	1
physic:		ds.w	1
physic2:	ds.w	1
logic:		ds.l	1
workspace:	ds.l	1	* Pointer to a work screen
dummy:		ds.l	1	* Nothing.... (help calculate 1/2/3)
image_1:	ds.l	1	* -> To plane 2
image_2:	ds.l	1	*    3
image_3:	ds.l	1	*    4
bigdata:	ds.l	1	* Pointer to raw images

graphic:	INCBIN	"PARALLEX.PI1",0

* ----> Mouse handler...

msoff:	        move.l  #moff,-(sp)     * Disable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A00A
		rts
                
mson:		move.l  #mon,-(sp)      * Re-enable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A009
		rts
mon:            dc.b    $08
moff:           dc.b    $12
