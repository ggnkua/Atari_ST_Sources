* \Routine to fast scroll a 4 plane 32x32 scroller

*  This is a very inefficient routine, and could be much improved.
*  You can use it for anything you want - scrollers are 2 a penny.

*  Distributions of the source must bear my name - Edd Deegan

*  This is a DEVPAC II listing.... it uses the INCBIN directive!!!!


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

		move.l	#$00,-(sp)	* Super mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,save_stack

		move.w	#2,-(sp)	* Get Physbase
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_phys

		move.w	#3,-(sp)	* Get Logbase
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_log

		move.w	#4,-(sp)	* Get rez
		trap	#14
		addq.l	#2,sp
		move.w	D0,old_rez
		jsr	msoff		* Disable rodent

		move.l	#$FF8240,A0	* Store old colours
		move.l	#old_pal,A1
		move.l	#15,D0
store_cols:	move.w	(A0)+,(A1)+
		dbf	D0,store_cols

		
init:		move.l	real_phys,D0
		move.l	D0,physic
		sub.l	#32256,D0
		move.l	D0,logic	* Point to logical screen
		
		move.w	#$00,-(sp)	* Low res
		move.l	physic,-(sp)
		move.l	logic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	#32000,-(sp)	* Reserve buffer
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,b_screen

		move.l	physic,A0	* Clear screen
		move.l	logic,A1
		move.l	b_screen,A2	
		move.l	#7999,D0
clear:		clr.l	(A0)+
		clr.l	(A1)+
		clr.l	(A2)+
		dbf	D0,clear

		move.l	#font_buf,A0	* Set palette
		add.l	#2,A0
		move.l	A0,-(sp)
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp

		move.w	sr,status
		move.w	#$2700,sr	* Disable interrupts

*****************************
		move.l	#fast_text,A6	* Point to text
		move.l	b_screen,D7	* Screen to place them on

* \Scroll routine calls go here

		move.l	b_screen,A3	* Point to character screen
		add.l	#16000,A3	* Point to letter position
		clr.b	even_flag	* Now, A3 --> consecutive words
		jsr	sixteen
		jsr	sixteen		* Clear junk

* \Set up letter parameters here		
		clr.l	D1
		move.b	(A6)+,D1
		clr.l	D2
		move.l	#100,D3		
		jsr	place_letter	* Put letter on
mainloop:	move.l	#5,D4	
test:		jsr	sixteen 	* Scroll screen
		jsr	swap
		dbf	D4,test
		tst.b	(A6)		* End of string?
		beq	reset
		clr.l	D1		* Place letter parameters
		move.b	(A6)+,D1
		move.l	#1,D2		* 8 Pixels into screen
		move.l	#100,D3

after_reset:	jsr	place_letter
		jmp	mainloop

reset:		move.l	#fast_text,A6
		clr.l	D1
		move.b	(A6)+,D1
		clr.l	D2
		move.l	#100,D3
		jmp	after_reset

* --> Main routines to do all the work (poor things!)

* \Move screen left by a word in four planes. Fill right hand edge
*  from left hand edge of b_screen

sixteen:	movem.l	D0-D3/A0-A2,-(sp)	* Save registers
		move.l	logic,D3	* Screen to scroll
		add.l	#16000,D3	* Dont need top 100 lines
		clr.l	D2		* Offset
		move.w	#31,D1		* Line counter
	
six_tn:		move.l	D3,A0		* Point to screen
		add.l	D2,A0		* Add in the offset
		move.l	A0,A1
		add.l	#$08,A1		* Point to second word
		move.w	#39,D0		* Longword counter
six_tn1:	move.l	(A1)+,(A0)+
		dbf	D0,six_tn1	* Repeat for whole line
		add.l	#160,D2		* Increase the offset
		dbf	D1,six_tn	

* \Now grab two bytes from A3, and place on logic in last column

		tst.b	even_flag	* Consecutive?
		beq	column_v2

column_v1:	move.l	A3,A4		* Store old A3 address
		clr.b	even_flag	* Next time - even boundary
		
		move.l	logic,A0	* Point to destination
		add.l	#16152,A0	* Point to last column
		move.w	#31,D0		* Line counter
* \A3 points to an odd byte.
* \Copy to A0

v1_loop:	move.b	(A3),(A0)	* Copy odd byte
		addq.l	#$02,A3		* Point to next odd byte in plane
		addq.l	#$02,A0		* Point to next byte in dest plane
		move.b	(A3),(A0)	* Copy that
		addq.l	#$02,A3		* Point to next odd byte in plane
		addq.l	#$02,A0		* Point to next byte in dest plane
		move.b	(A3),(A0)	* Copy odd byte
		addq.l	#$02,A3		* Point to next odd byte in plane
		addq.l	#$02,A0		* Point to next byte in dest plane
		move.b	(A3)+,(A0)	* Copy that
* \Now pointing to right plane
		sub.l	#$05,A0		* Back a bit for second column
		move.b	(A3),(A0)	* Copy even byte
		addq.l	#$02,A3
		addq.l	#$02,A0
		move.b	(A3),(A0)
		addq.l	#$02,A3
		addq.l	#$02,A0
		move.b	(A3),(A0)
		addq.l	#$02,A3
		addq.l	#$02,A0
		move.b	(A3),(A0)
		
		add.l	#147,A3		* Down a line
		add.l	#153,A0		

		dbf	D0,v1_loop
		move.l	A4,A3
		add.l	#$07,A3		* Point to next pair
		movem.l	(sp)+,D0-D3/A0-A2	* Restore 'em
		rts

column_v2:	move.l	A3,A4		* Store A3 address
		move.b	#$01,even_flag	* Next time, spaced bytes
		move.l	logic,A0
		add.l	#16152,A0		* Point to destination
		move.w	#31,D0		* Line counter
v2_loop:	move.l	(A3)+,(A0)+	* Move two planes
		move.l	(A3)+,(A0)+	* and other two planes
		add.l	#152,A3
		add.l	#152,A0		* Down a line
		dbf	D0,v2_loop
		move.l	A4,A3
		add.l	#$01,A3		* Point to next byte
end_column:	movem.l	(sp)+,D0-D3/A0-A2	* Restore 'em
		rts
		
swap:		move.w	physic2,D0

wait_vbl:	move.b	$FF8207,video1
		move.b	$FF8209,video2
		cmp.w	video1,D0
		beq	end_vbl
		jmp	wait_vbl

end_vbl:	move.w	#-1,-(sp)	* Leave rez
		move.l	logic,-(sp)	* Swap screens
		move.l	physic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	physic,temp
		move.l	logic,physic
		move.l	temp,logic	* Swap pointers
		move.w	status,sr
		move.b	$FFFC02,D0	* Look at keyboard
		cmp.b	#$39,D0		* SPACE?
		beq	to_gem
		move.w	#$2700,sr	* Disable interrupts
		rts

video1:		ds.b	1
video2:		ds.b	1
temp:		ds.l	1
count:		ds.w	1
even_flag:	dc.b	0

		EVEN
fast_text:	dc.b	"  WOW    IT IS VERY SLOW AND IDIOSYNCRATIC "
		dc.b	"BUT THIS SCROLLER REALLY WORKS      IT IS "
		dc.b	"NOW FOUR IN THE MORNING BUT WHO CARES     "
		dc.b	"OK                PLEASE NOTE THAT THE LETTERS "
		dc.b	"ARE GENERATED OFF THE SCREEN          THE GAP "
		dc.b	"BETWEEN EACH LETTER IS UNFORTUNATE BUT NECESSARY "
		dc.b	"DUE TO TECHNICAL REASONS              WELL IT "
		dc.b	"IS NOW TWENTY TO SIX IN THE MORNING AND I AM "
		dc.b	"TOO TIRED TO DO ANYTHING MORE SO I WILL PUT "
		dc.b	"MY MACHINE AWAY AND CRASH OUT             "
		dc.b	"SEEYA                              ",0


*******************************

* \Places letter D1 at D2*8,D3

place_letter:   move.l	b_screen,A3	* Reset scroll pointer
		add.l	#16000,A3	* to letter position
		clr.b	even_flag
		move.l  #font_buf,D0
                add.l   #34,D0
                move.l  D0,fontdat      * Point to actual raw font data

check:          cmp.b	#$20,D1		* Space?
		beq	place_space
		cmp.b   #$40,D1         * Ensure character not < A
                ble     a_def
a_ret:          cmp.b   #$5B,D1         * Ensure character not > Z
                bge     z_def
z_ret:          mulu    #8,D2          * D2 is bytes across
                mulu    #160,D3         * D3 = No of bytes down
                add.l   D2,D3           * D3 = Start byte
                move.l  D3,dest         * Store it!
                move.l  b_screen,D0	* Target screen
                add.l   dest,D0
                move.l  D0,dest         * Add offset to screen address
                
* \Now check which line of defined font PI1 the letter is on...

                cmp.b   #$49,D1
                ble     line_1          * Letter is in first row
                cmp.b   #$52,D1
                ble     line_2          * Letter is in second row
                jmp     line_3          * Letter is in third row

place_space:	mulu    #8,D2          * D2 is bytes across
                mulu    #160,D3         * D3 = No of bytes down
                add.l   D2,D3           * D3 = Start byte
                move.l  D3,dest         * Store it!
                move.l  b_screen,D0	* Target screen
                add.l   dest,D0
                move.l  D0,dest        
		move.w	#31,D0		* Lines
		move.l	dest,A0

do_space:	move.w	#3,D1		* Longwords per line
space_loop:	clr.l	(A0)+
		dbf	D1,space_loop
		add.l	#144,A0
		dbf	D0,do_space
		rts

* \Now extract and place the current letter......
*  FONTDAT points to raw datascreen
*  DEST points to destination block
                
* \Line 1...ASCII in range 65 - 73 (dec)

line_1:         sub.l   #65,D1          * Now letters represented by 0 - 8
                mulu    #16,D1          * Point to first byte of letter
                add.l   fontdat,D1
                clr.l   D7              * Use as counter
                move.l  dest,A2         * A2 = destination address
                move.l  D1,A1           * A1 = letter start address

* ---> No vertical offset needed, as this is the top line

put_char:       move.l  (A1)+,(A2)+     * Copy line
                move.l  (A1)+,(A2)+        
                move.l  (A1)+,(A2)+
                move.l  (A1)+,(A2)+
                add.l   #144,A1
                add.l   #144,A2         * Point down a line
                addq.l  #1,D7           * Inc counter
                cmp.l   #32,D7          * End of letter?
                beq     end
                jmp     put_char

line_2:         sub.l   #74,D1          * Now letters represented by 0 - 8
                mulu    #16,D1          * Point to first byte of letter
                add.l   fontdat,D1
                clr.l   D7              * Use as counter
                move.l  dest,A2         * A2 = destination address
                move.l  D1,A1           * A1 = letter start address
                adda.l  #5760,A1        * (Offset of 36 lines)
                jmp     put_char

line_3:         sub.l   #83,D1          * Now letters represented by 0 - 8
                mulu    #16,D1          * Point to first byte of letter
                add.l   fontdat,D1
                clr.l   D7              * Use as counter
                move.l  dest,A2         * A2 = destination address
                move.l  D1,A1           * A1 = letter start address
                adda.l  #11680,A1       * (Offset for 3 rows)
                jmp     put_char

a_def:          move.b  #$41,D1         * Default to A
                jmp     a_ret
z_def:          move.b  #$5A,D1         * Default to Z
                jmp     z_ret           
end:            rts

buffer:         ds.l    1
dest:           ds.l    1
fontdat:        ds.l    1
                EVEN

******************************

to_gem:		move.w	status,sr
		move.w	old_rez,-(sp)	* Restore rez
		move.l	real_phys,-(sp)
		move.l	real_log,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		jsr	mson		* Enable mouse

		move.l	b_screen,-(sp)	* Free buffers
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp

		move.l	#$FF8240,A1	* Restore colours
		move.l	#old_pal,A0
		move.l	#15,D0
restore_cols:	move.w	(A0)+,(A1)+
		dbf	D0,restore_cols

		move.l	save_stack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)
		trap	#1		* Exit gracefully


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


save_stack:	ds.l	1
real_phys:	ds.l	1
real_log:	ds.l	1
old_rez:	ds.w	1
old_pal:	ds.w	16
physic:		ds.w	1
physic2:	ds.w	1
logic:		ds.l	1
b_screen:	ds.l	1
s_screen1:	ds.l	1
s_screen2:	ds.l	1
handle:		ds.w	1
status:		ds.w	1
		EVEN

font_buf:	INCBIN	"FONT.PI1",0
