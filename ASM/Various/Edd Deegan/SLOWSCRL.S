* This is a routine by Edd Deegan.
* It is mine, all mine and may be freely adapted and used. Re-distributions
* must bear my name.

* \Big scroller with byte waveform
* \This works with 32x32 characters

* \This scroller has no rasters ... just a wave
* \It can be defined to be straight...
* \This version has a wave added to the text using a table...
* \Each step is a byte - 8 pixels

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

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,save_stack	

		jsr	moff		* Disable rodent
	
load_scrn:	move.w	#2,-(sp)	* Get video RAM
		trap	#14
		addq.l	#2,sp
		move.l	D0,physic
		move.l	D0,real_phys	* Remember original address
		sub.l	#32256,D0
		move.l	D0,logic	* Point to screens
		move.w	#3,-(sp)	* Get logical RAM
		trap	#14
		addq.l	#6,sp
		move.l	D0,real_log	* Remember original address		

		move.l	#33000,-(sp)	* Reserve a buffer
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,fnt_buf

		move.w	#$00,-(sp)	* Open the file
		move.l	#pic_name,-(sp)
		move.w	#$3D,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	D0,handle
		
		move.l	fnt_buf,-(sp)	* Load the file
		move.l	#32032,-(sp)
		move.w	handle,-(sp)
		move.w	#$3F,-(sp)
		trap	#1
		add.l	#12,sp

		move.w	handle,-(sp)	* Close the file
		move.w	#$3E,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	#$00,-(sp)	* Set the screens....
		move.l	physic,-(sp)
		move.l	logic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.w	#7999,D7
		move.l	physic,A0
clear:		clr.l	(A0)+
		dbf	D7,clear		
		move.l	fnt_buf,A1
		move.l	A1,-(sp)	* Set the palette
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp

**************************************

		clr.l	D0
		move.l	#text,A6
call_rout:	move.w	#$00,count	* Reset counter
		clr.l	D0
		move.b	(A6)+,D0	* D0 = Character
		cmp.b	#$00,(A6)
		beq	reset
		cmp.b	#$20,D0	
		beq	scroll_loop	* Ingore spaces

call_put:	move.l	#9,D1		* D1 = X-Coord
		move.l	#50,D2		* D2 = Y-Coord	
		jsr	put_char
		jmp	scroll_loop
reset:		lea	text,A6		* Repoint A6 to text
		jmp	call_put

scroll_loop:	move.l	#50,D1		* 50 pixels down
		jsr	scroll
		addq.w	#$01,count
		cmp.w	#33,count
		beq	call_rout	* If 34 scrolls - next character
		jmp	scroll_loop

*\ A routine to scroll a 32 pixel deep section of the screen, in
*  one plane. Distance down the screen in D1

scroll:		movea.l	logic,A1	* Screen to scroll
		mulu.w	#160,D1		* D1 = vertical offset
		add.l	D1,A1		* A1 = Scroll area
		move.l	A1,A2		* A2 points to last byte scrolled
		move.l	A1,A3		* A3 points to last LINE
		lea	1(A2),A2	* Told ya'
		lea	1(A3),A3	* A3 stops overflow off left
		jsr	wait_vbl
		move.w	#31,D1		* D1 now = line counter
		

horiz_loop1:	move.l	A3,A2
		move.w	(A1),D0		* Get 16 pixels
		asl.w	#1,D0		* Shift 'em
		move.w	D0,(A1)		* Put 'em back
		lea	8(A1),A1		* Point to next word in plane

* \19 words left in this line....
* \A2 still pointing to second byte in first word of plane 

		move.w	#18,D2		* D2 = word counter
horiz_loop2:	lsl.w	(A1)		* Shift byte
		bcc	clr_bit		* Do byte

set_bit:	bset	#0,(A2)		* Clear bit
		lea	8(A2),A2	* Point to next affected byte
		jmp	after_set		
clr_bit:	bclr	#0,(A2)		* Set the bit
		lea	8(A2),A2	* Point to next affected byte
		
after_set:	lea	8(A1),A1	* Point to next word in plane
		dbf	D2,horiz_loop2	* Repeat for whole line
		lea	160(A3),A3	* Add line pointer
		dbf	D1,horiz_loop1	* Repeat for 16 lines
		rts			* End of scroll

to_gem:		jsr	mon		* Enable rodent
		move.w	#-1,-(sp)	* Reset screens
		move.l	real_phys,-(sp)
		move.l	real_log,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		clr.l	-(sp)
		trap	#1		* Back to O.S.

* \A routine to extract and place a 1 bitplane font character 
*  (32x32) at x,y on a specified screen...

* \D0.L = ASCII Character
*  D1.W = X pixel/32
*  D2.W = Y pixel
* \Places character on LOGICAL screen, whose address is in logic

* >>>>>>>>> NEEDS TO PUT A 32 x 32 CHARACTER <<<<<<<<<<<<<<

put_char:	cmp.b	#"A",D0
		blt	end_put
		cmp.b	#"Z",D0
		bgt	end_put
		mulu.w	#160,D2		* Calculate vertical offset
		mulu.w	#16,D1		* Calculate horizontal offset
		add.l	D1,D2		* D2 = Offset
		add.l	logic,D2
		move.l	D2,A1		* A1 = dest addr


find_line:	cmp.b	#$49,D0		* Compare to I
		bgt	line_two

line_one:	sub.b	#65,D0		* Now represented by 0,1,2,3,4....
		mulu.w	#16,D0		* Calculate offset
		add.l	fnt_buf,D0
		add.l	#32,D0		* Offset for palette
		move.l	D0,A2		* A2 = Source Addr	
		jsr	do_char		
		jmp	end_put

line_two:	cmp.b	#$52,D0		* Compare to R
		bgt	line_three
		sub.b	#$4A,D0		* Now represtented by 0,1,2,3,4....
		mulu.w	#16,D0
		add.l	#7680,D0	* Add for 48 lines
		add.l	fnt_buf,D0
		add.l	#32,D0
		move.l	D0,A2		* A2 =  Source addr
		jsr	do_char
		jmp	end_put

line_three:	sub.b	#$53,D0		* Now represented by 0,1,2,3,4....
		mulu.w	#16,D0
		add.l	#15360,D0	* Add for 96 lines
		add.l	fnt_buf,D0
		add.l	#32,D0
		move.l	D0,A2		* A2 = Source addr
		jsr	do_char
		
end_put:	rts

do_char:	move.w	#15,D0		* Line counter
do_loop:	move.w	(A2),(A1)
		lea	8(A1),A1
		lea	8(A2),A2
		move.w	(A2),(A1)
		lea	152(A1),A1
		lea	152(A2),A2		* Down a line
		move.w	(A2),(A1)
		lea	8(A1),A1
		lea	8(A2),A2
		move.w	(A2),(A1)
		lea	152(A1),A1
		lea	152(A2),A2		* Down a line

end_do:		dbf	D0,do_loop
		rts


wait_vbl:	move.w	physic2,A5	* To wait for...
wait_vbl2:	move.b	$FF8207,temp	* Construct word
		move.b	$FF8209,temp2	
		cmp.w	temp,A5		* Top of screen?
		beq	debug
		jmp	wait_vbl2
debug:		movem.l	D0-D2/A0-A3,-(sp)
		move.w	#$FF,-(sp)
		move.w	#$06,-(sp)
		trap	#1
		addq.l	#4,sp
		cmp.b	#"q",D0
		beq	to_gem
		movem.l	(sp)+,D0-D2/A0-A3

* \Copy moved area to physical screen

end_vbl:	movem.l	D0-D1/A0-A2,-(sp)
		move.l	logic,A0	
		lea	8000(A0),A0	* 50 lines down....
		move.l	physic,A1
		lea	8000(A1),A1	* 50 lines down....

* \A0 points to start of source block
*  A1 points to start of dest block

		move.w	#16,D0		* Blocks per pass
		move.l	#wave_even,A2	* A2 points to wave table

* \Wave table is a list of addresses..
* \Two passes...one for even bytes and one for odd bytes

wave_block1:	move.l	physic,A1	* Offset from table
		add.l	(A2)+,A1	* Screen targeted..
		move.w	#31,D1		* Lines to copy
do_pass1:	move.b	(A0),(A1)	* Do even byte
		lea	160(A0),A0
		lea	160(A1),A1	* Next line
		dbf	D1,do_pass1	* Finish character
		lea	-5112(A0),A0	* Point to next source
		dbf	D0,wave_block1

		move.l	#wave_odd,A2	* A2 points to wave table
		move.l	logic,A0
		lea	8000(A0),A0
		add.w	#$01,A0		* Odd bytes
		move.w	#16,D0		* Now do odd bytes
wave_block2:	move.l	physic,A1
		add.l	(A2)+,A1	* A1 = target
		move.w	#31,D1		* Lines to copy
do_pass2:   	move.b	(A0),(A1)	* Copy byte
		lea	160(A0),A0
		lea	160(A1),A1	* Next line
		dbf	D1,do_pass2
		sub.l	#5112,A0	* Point to next source
		dbf	D0,wave_block2
end_waver:	movem.l	(sp)+,D0-D1/A0-A2
		rts

wave_even:	dc.l	8000,8328,8656,8984	* 960 OFFSET
		dc.l	9312,9320,9008,8696	*	 
		dc.l	8384,8072,7760,7448	*
		dc.l	7456,7784,8112,8440	*
		dc.l	8768,9096,9424,9752	!
		
wave_odd:	dc.l	8161,8489,8817,9145	* 1120 OFFSET
		dc.l	9473,9161,8849,8537	*	
		dc.l	8225,7913,7601,7289	*
		dc.l	7617,7945,8273,8601	*
		dc.l	8929,9257,9585,9913	! 

moff:           move.l  #moff,-(sp)     * Disable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A00A
		rts

mon:            move.l  #mondata,-(sp)  * Re-enable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A009
		rts

moffdata:	dc.b	$12		* Control data
mondata:	dc.b	$08

**********************************************************************

save_stack:	ds.l	1		* Space for old sp
count:		ds.w	1		* Scroll counter
fnt_buf:	ds.l	1		* Pointer to reserved memory
handle:		ds.w	1		* Storage for filehandle
physic:		ds.w	1
physic2:	ds.w	1
logic:		ds.l	1
real_log:	ds.l	1		* Address of logical screen
real_phys:	ds.l	1		* Address of physical screen
temp:		ds.b	1
temp2:		ds.b	1

		EVEN

text:		dc.b	"SLOW AND OLD I KNOW    BUT YOU MIGHT BE ABLE TO USE IT    ",0

		EVEN

pic_name:	dc.b	"BIGPLANE.FNT",0
	