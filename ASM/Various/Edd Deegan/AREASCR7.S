* This code is TOTALLY ORIGINAL and all my own. It may be 
* distributed freely, so long as it bears my name.
* -- Edd Deegan

* \This version (7) has an optimised copy routine, which copies
*  to a larger area.
* \It also has TWO screens, with different multiplane effects

* \A program allowing a large area of the screen to be scrolled in
*  two planes. The top left 16x16 square is duplicated many times
*  to form a background.

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

load_scrn:	move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	D0,old_rez
		move.w	#2,-(sp)	* Get video RAM
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

		jsr	msoff		* Disable mouse
		move.l	#33000,-(sp)	* Reserve a buffer
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,pic_buf

		move.w	#$00,-(sp)	* Open the file
		move.l	#pic_name,-(sp)
		move.w	#$3D,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	D0,handle
		
		move.l	pic_buf,-(sp)	* Load the file
		move.l	#32032,-(sp)
		move.w	handle,-(sp)
		move.w	#$3F,-(sp)
		trap	#1
		add.l	#12,sp

		move.w	handle,-(sp)	* Close the file
		move.w	#$3E,-(sp)
		trap	#1
		addq.l	#6,sp

* \Load second screen

		move.l	#33000,-(sp)	* Reserve a buffer
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,pic_buf2

		move.w	#$00,-(sp)	* Open the file
		move.l	#pic_name2,-(sp)
		move.w	#$3D,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	D0,handle
		
		move.l	pic_buf2,-(sp)	* Load the file
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

		move.l	#$00,-(sp)	* Super mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,save_stack
		move.w	sr,status
		move.w	#$2700,sr	* Disable interrupts
		
		move.l	#$FF8240,A0	* Store cols
		move.l	#old_pal,A1
		move.w	#15,D0
savecols:	move.w	(A0)+,(A1)+
		dbf	D0,savecols

		move.l	pic_buf,A6	* A6 --> RAW DATA
		adda.l	#32,A6
		move.l	physic,A5	* A5 --> physical RAM
		jsr	put_screen

		move.l	pic_buf,A6
		adda.l	#32,A6
		move.l	logic,A5	* A5 --> logical screen
		jsr	put_screen

		move.l	pic_buf,A1
		move.l	A1,-(sp)	* Set the palette
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp
		move.l	pic_buf,-(sp)	* Release the buffer
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		jmp	master		* And to client program

put_screen:	move.w	#7999,D5	* Counter
put_loop:	move.l	(A6)+,(A5)+	* Place longword
		dbf	D5,put_loop
		rts


* \ A routine to scroll the top left 16x16 area of the logical screen,
*   duplicate it over the logical screen and swap screens.

* \Routines we can call - 1,2 or 4 pixels either L/R/U/D

* \Create offset
master:		move.w	#3,D4
		jsr	one_pd		* Move logic 
		jsr	two_pr
		jsr	copy		* Copy to move area


master_loop:	move.w	#3,D7
master_loop1:	jsr	two_pd		* Step.
		jsr	four_pr
		jsr	copy	
		dbf	D7,master_loop1
		jsr	one_pd
		
		jsr	two_pd
		jsr	four_pr
		jsr	copy
		move.w	#5,D7
m_1:		jsr	four_pd
		jsr	four_pr
		jsr	copy
		dbf	D7,m_1
		jsr	two_pd

		jsr	two_pd
		jsr	one_pd
		jsr	four_pr
		jsr	copy
		move.w	#5,D7
m_2:		jsr	four_pd
		jsr	two_pd
		jsr	four_pr
		jsr	copy
		dbf	D7,m_2
		jsr	two_pd
		jsr	one_pd

		jsr	four_pd
		jsr	four_pr
		jsr	copy
		move.w	#7,D7
m_3:		jsr	four_pd
		jsr	four_pd
		jsr	four_pr
		jsr	copy
		dbf	D7,m_3
		jsr	four_pd
	
		jsr	four_pd
		jsr	two_pd
		jsr	four_pr
		jsr	copy
		move.w	#10,D7
m_x:		jsr	four_pr
		jsr	four_pd
		jsr	four_pd
		jsr	four_pd
		jsr	copy
		dbf	D7,m_x
	
* \Bounce
		jsr	four_pr
		jsr	copy
		
		move.w	#11,D7
m_x2:		jsr	four_pd
		jsr	four_pr
		jsr	copy
		dbf	D7,m_x2
		jsr	four_pu
		jsr	two_pu

		jsr	four_pu
		jsr	four_pr
		jsr	copy
		move.w	#7,D7
m_6:		jsr	four_pu
		jsr	four_pu
		jsr	four_pr
		jsr	copy
		dbf	D7,m_6
		jsr	four_pu

		jsr	one_pu
		jsr	two_pu
		jsr	four_pr
		jsr	copy
		move.w	#3,D7
m_7:		jsr	four_pu
		jsr	two_pu
		jsr	four_pr
		jsr	copy
		dbf	D7,m_7
		jsr	one_pu
		jsr	two_pu

		jsr	four_pr
		jsr	two_pu
		jsr	copy
		move.w	#5,D7
m_8:		jsr	four_pu
		jsr	four_pr
		jsr	copy
		dbf	D7,m_8
		jsr	two_pu

		jsr	one_pu
		jsr	four_pr
		jsr	copy
		move.w	#5,D7
m_9:		jsr	two_pu
		jsr	four_pr
		jsr	copy
		dbf	D7,m_9
		jsr	one_pu
		jsr	four_pr
		jsr	copy

straight:	jsr	four_pr
		jsr	one_pu
		jsr	copy

		jsr	four_pr
		jsr	two_pu
		jsr	copy

		jsr	four_pr
		jsr	one_pu
		jsr	copy

		jsr	four_pr
		jsr	copy
		jsr	one_pu

		dbf	D4,master_loop

		jsr	two_pr
		jsr	copy

* \Now other direction!

		jsr	two_pl
		jsr	copy

master_init2:	move.w	#3,D4

master2_loop:	move.w	#3,D7
master2_loop1:	jsr	two_pd		* Step.
		jsr	four_pl
		jsr	copy	
		dbf	D7,master2_loop1
		jsr	one_pd
		
		jsr	two_pd
		jsr	four_pl
		jsr	copy
		move.w	#5,D7
m2_1:		jsr	four_pd
		jsr	four_pl
		jsr	copy
		dbf	D7,m2_1
		jsr	two_pd

		jsr	two_pd
		jsr	one_pd
		jsr	four_pl
		jsr	copy
		move.w	#5,D7
m2_2:		jsr	four_pd
		jsr	two_pd
		jsr	four_pl
		jsr	copy
		dbf	D7,m2_2
		jsr	two_pd
		jsr	one_pd

		jsr	four_pd
		jsr	four_pl
		jsr	copy
		move.w	#7,D7
m2_3:		jsr	four_pd
		jsr	four_pd
		jsr	four_pl
		jsr	copy
		dbf	D7,m2_3
		jsr	four_pd
	
		jsr	four_pd
		jsr	two_pd
		jsr	four_pl
		jsr	copy
		move.w	#10,D7
m2_x:		jsr	four_pl
		jsr	four_pd
		jsr	four_pd
		jsr	four_pd
		jsr	copy
		dbf	D7,m2_x
	
* \Bounce
		jsr	four_pl
		jsr	copy
		
		move.w	#11,D7
m2_x2:		jsr	four_pd
		jsr	four_pl
		jsr	copy
		dbf	D7,m2_x2
		jsr	four_pu
		jsr	two_pu

		jsr	four_pu
		jsr	four_pl
		jsr	copy
		move.w	#7,D7
m2_6:		jsr	four_pu
		jsr	four_pu
		jsr	four_pl
		jsr	copy
		dbf	D7,m2_6
		jsr	four_pu

		jsr	one_pu
		jsr	two_pu
		jsr	four_pl
		jsr	copy
		move.w	#3,D7
m2_7:		jsr	four_pu
		jsr	two_pu
		jsr	four_pl
		jsr	copy
		dbf	D7,m2_7
		jsr	one_pu
		jsr	two_pu

		jsr	four_pl
		jsr	two_pu
		jsr	copy
		move.w	#5,D7
m2_8:		jsr	four_pu
		jsr	four_pl
		jsr	copy
		dbf	D7,m2_8
		jsr	two_pu

		jsr	one_pu
		jsr	four_pl
		jsr	copy
		move.w	#5,D7
m2_9:		jsr	two_pu
		jsr	four_pl
		jsr	copy
		dbf	D7,m2_9
		jsr	one_pu
		jsr	four_pl
		jsr	copy

straight2:	jsr	four_pl
		jsr	one_pu
		jsr	copy

		jsr	four_pl
		jsr	two_pu
		jsr	copy

		jsr	four_pl
		jsr	one_pu
		jsr	copy

		jsr	four_pl
		jsr	copy
		jsr	one_pu

		dbf	D4,master2_loop	
		jsr	two_pl
		jsr	copy
		jsr	one_pu

		jmp	master


* \4 pixels right
four_pr:	move.l	logic,A0	* Screen to scroll
		move.w	#15,D0		* Line counter
four_pr_loop:	move.w	(A0),D1		* Do plane 1
		ror.w	#4,D1
		move.w	D1,(A0)+	* Point to plane 2
		move.w	(A0),D1
		ror.w	#4,D1
		move.w	D1,(A0)		* Do plane 2
		add.l	#158,A0		* Down a line
		dbf	D0,four_pr_loop
		rts

* \4 pixels left
four_pl:	move.l	logic,A0	* Screen to scroll
		move.w	#15,D0		* Line counter
four_pl_loop:	move.w	(A0),D1
		rol.w	#4,D1
		move.w	D1,(A0)+
		move.w	(A0),D1
		rol.w	#4,D1
		move.w	D1,(A0)
		add.l	#158,A0
		dbf	D0,four_pl_loop
		rts

* \Four pixels up
four_pu:	move.l	logic,A0	* Screen to work on
		move.l	#scroll_buf,A1	* Buffer address
		move.w	#3,D0		* Take top 4 lines
four_pu_fill:	move.l	(A0),(A1)+
		add.l	#160,A0
		dbf	D0,four_pu_fill
		
		move.l	logic,A1	* Back to screen
		move.w	#11,D0		* Line counter
four_pu_up:	move.l	(A0),(A1)
		add.l	#160,A0
		add.l	#160,A1
		dbf	D0,four_pu_up

		move.l	#scroll_buf,A0
		move.w	#3,D0		* 'Contents of buffer' counter
four_pu_empt:	move.l	(A0)+,(A1)
		add.l	#160,A1
		dbf	D0,four_pu_empt
		rts

* \Four pixels down
four_pd:	move.l	logic,A0	* Screen to work on
		add.l	#2400,A0	* 15 lines down
		move.w	#3,D0		* Buffer counter
		move.l	#scroll_buf,A1
four_pd_fill:	move.l	(A0),(A1)+
		sub.l	#160,A0
		dbf	D0,four_pd_fill

		move.w	#11,D0		* Rest of lines
		move.l	logic,A1
		add.l	#2400,A1	* Down 15 lines
four_pd_d:	move.l	(A0),(A1)
		sub.l	#160,A0
		sub.l	#160,A1
		dbf	D0,four_pd_d

		move.w	#3,D0		* 'Buffer contents' counter
		move.l	#scroll_buf,A1
		move.l	logic,A0
		add.l	#480,A0		* Down 4 lines
four_pd_empt:	move.l	(A1)+,(A0)
		sub.l	#160,A0
		dbf	D0,four_pd_empt
		rts

* \Routines to handle 2 pixel shifts

* \2 pixels right
two_pr:		move.l	logic,A0	* Screen to scroll
		move.w	#15,D0		* Line counter
two_pr_loop:	move.w	(A0),D1		* Do plane 1
		ror.w	#2,D1
		move.w	D1,(A0)+	* Point to plane 2
		move.w	(A0),D1
		ror.w	#2,D1
		move.w	D1,(A0)		* Do plane 2
		add.l	#158,A0		* Down a line
		dbf	D0,two_pr_loop
		rts

* \2 pixels left
two_pl:		move.l	logic,A0	* Screen to scroll
		move.w	#15,D0		* Line counter
two_pl_loop:	move.w	(A0),D1
		rol.w	#2,D1
		move.w	D1,(A0)+
		move.w	(A0),D1
		rol.w	#2,D1
		move.w	D1,(A0)
		add.l	#158,A0
		dbf	D0,two_pl_loop
		rts

* \Two pixels up
two_pu:		move.l	logic,A0	* Screen to work on
		move.l	#scroll_buf,A1	* Buffer address
		move.w	#1,D0		* Take top 2 lines
two_pu_fill:	move.l	(A0),(A1)+
		add.l	#160,A0
		dbf	D0,two_pu_fill
		
		move.l	logic,A1	* Back to screen
		move.w	#13,D0		* Line counter
two_pu_up:	move.l	(A0),(A1)
		add.l	#160,A0
		add.l	#160,A1
		dbf	D0,two_pu_up

		move.l	#scroll_buf,A0
		move.w	#1,D0		* 'Contents of buffer' counter
two_pu_empt:	move.l	(A0)+,(A1)
		add.l	#160,A1
		dbf	D0,two_pu_empt
		rts

* \Two pixels down
two_pd:		move.l	logic,A0	* Screen to work on
		add.l	#2400,A0	* 15 lines down
		move.w	#1,D0		* Buffer counter
		move.l	#scroll_buf,A1
two_pd_fill:	move.l	(A0),(A1)+
		sub.l	#160,A0
		dbf	D0,two_pd_fill

		move.w	#13,D0		* Rest of lines
		move.l	logic,A1
		add.l	#2400,A1	* Down 15 lines
two_pd_d:	move.l	(A0),(A1)
		sub.l	#160,A0
		sub.l	#160,A1
		dbf	D0,two_pd_d

		move.w	#1,D0		* 'Buffer contents' counter
		move.l	#scroll_buf,A1
		move.l	logic,A0
		add.l	#160,A0		* Down 1 lines
two_pd_empt:	move.l	(A1)+,(A0)
		sub.l	#160,A0
		dbf	D0,two_pd_empt
		rts


* \1 pixel right
one_pr:		move.l	logic,A0	* Screen to scroll
		move.w	#15,D0		* Line counter
one_pr_loop:	move.w	(A0),D1		* Do plane 1
		ror.w	#1,D1
		move.w	D1,(A0)+	* Point to plane 2
		move.w	(A0),D1
		ror.w	#1,D1
		move.w	D1,(A0)		* Do plane 2
		add.l	#158,A0		* Down a line
		dbf	D0,one_pr_loop
		rts

* \1 pixel left
one_pl:		move.l	logic,A0	* Screen to scroll
		move.w	#15,D0		* Line counter
one_pl_loop:	move.w	(A0),D1
		rol.w	#1,D1
		move.w	D1,(A0)+
		move.w	(A0),D1
		rol.w	#1,D1
		move.w	D1,(A0)
		add.l	#158,A0
		dbf	D0,one_pl_loop
		rts

* \one pixel up
one_pu:		move.l	logic,A0	* Screen to work on
		move.l	#scroll_buf,A1	* Buffer address
one_pu_fill:	move.l	(A0),(A1)+
		add.l	#160,A0
		
		move.l	logic,A1	* Back to screen
		move.w	#14,D0		* Line counter
one_pu_up:	move.l	(A0),(A1)
		add.l	#160,A0
		add.l	#160,A1
		dbf	D0,one_pu_up

		move.l	#scroll_buf,A0
one_pu_empt:	move.l	(A0)+,(A1)
		add.l	#160,A1
		rts

* \one pixel down
one_pd:		move.l	logic,A0	* Screen to work on
		add.l	#2400,A0	* 15 lines down
		move.l	#scroll_buf,A1
one_pd_fill:	move.l	(A0),(A1)
		sub.l	#160,A0

		move.w	#14,D0		* Rest of lines
		move.l	logic,A1
		add.l	#2400,A1	* Down 15 lines
one_pd_d:	move.l	(A0),(A1)
		sub.l	#160,A0
		sub.l	#160,A1
		dbf	D0,one_pd_d

		move.l	#scroll_buf,A1
		move.l	logic,A0
one_pd_empt:	move.l	(A1),(A0)
		rts
	
* \Copies moved square to top 7 lines of squares...
	
copy:		move.l	logic,A0	* Screen being used
		move.l	A0,A1		* Working copy
		move.w	#19,D0		* Longwords per line (2 planes)
		move.w	#15,D1		* Line counter
copy_loop1:	move.l	(A0),(A1)	* Copy two planes
		add.l	#$08,A1		* Next position of planes
		dbf	D0,copy_loop1	* Do line
		move.w	#19,D0		* reset longword counter
		add.l	#160,A0		* Next line down
		move.l	A0,A1
		dbf	D1,copy_loop1	* Repeat for 16 lines
* \Now we have a line. Simply duplicate it x 7

		move.l	logic,A0	* Copying from...
		move.l	A0,A1
		move.l	A0,A3		* Copying to...
		add.l	#2560,A1	* Copying to...
		add.l	#12800,A3
		move.w	#1279,D0	* Words..[20 per line]..[16*6 lines]
copy_loop2:	move.l	(A0),(A1)	* Copy two words for two planes
		move.l	(A0),(A3)
		add.l	#$08,A0
		add.l	#$08,A1		* Next words in planes 1+2
		add.l	#$08,A3
		dbf	D0,copy_loop2

swap:		move.w	physic2,D0
vbl_loop:	move.b	$FF8207,video_ptr
		move.b	$FF8209,video_ptr2
		cmp.w	video_ptr,D0
		beq	end_vblwait
		jmp	vbl_loop	* Wait for VBL
end_vblwait:	move.w	#-1,-(sp)	* Leave rez
		move.l	logic,-(sp)	* Swap
		move.l	physic,-(sp)	* Screens
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		move.l	physic,holder	* And pointers
		move.l	logic,physic
		move.l	holder,logic
		move.w	status,sr
		move.b	$FFFC02,D0
		cmp.b	#$39,D0		* Space?
		beq	to_gem
		cmp.b	#$02,D0
		beq	set_pic1
		cmp.b	#$03,D0
		beq	set_pic2
end_vbl:	move.w	#$2700,sr
		rts	

* \Display pic_buf+set cols
	
set_pic1:	move.l	pic_buf,A0
		move.l	A0,-(sp)
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp		* Set palette

		move.l	pic_buf,A0
		add.l	#32,A0
		move.l	physic,A1
		jsr	put_pic
		move.l	pic_buf,A0
		add.l	#32,A0
		move.l	logic,A1
		jsr	put_pic
		move.w	#$2700,sr	* Disable interrupts
		jmp	master

set_pic2:	move.l	pic_buf2,A0
		move.l	A0,-(sp)
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp		* Set palette

		move.l	pic_buf2,A0
		add.l	#32,A0
		move.l	physic,A1
		jsr	put_pic
		move.l	pic_buf2,A0
		add.l	#32,A0
		move.l	logic,A1
		jsr	put_pic
		move.w	#$2700,sr	* Disable interrupts
		jmp	master

put_pic:	move.w	#7999,D0	* Whack out some graphixx
put_pic1:	move.l	(A0)+,(A1)+
		dbf	D0,put_pic1
		rts

to_gem:		move.w	old_rez,-(sp)	* Reset screens
		move.l	real_phys,-(sp)
		move.l	real_log,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		move.l	#old_pal,A0
		move.l	#$FF8240,A1
		move.w	#15,D0
put_cols:	move.w	(A0)+,(A1)+
		dbf	D0,put_cols		* Reset palette
		jsr	mson			* Enable mouse again
		move.w	status,sr
		move.l	save_stack,-(sp)	* User mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.l	-(sp)
		trap	#1		* Back to O.S.

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


scroll_buf:	ds.l	4
save_stack:	ds.l	1
pic_buf:	ds.l	1		* Pointer to reserved memory
pic_buf2:	ds.l	1
handle:		ds.w	1		* Storage for filehandle
physic:		ds.w	1
physic2:	ds.w	1
logic:		ds.l	1
holder:		ds.l	1
real_log:	ds.l	1		* Address of logical screen
status:		ds.w	1
real_phys:	ds.l	1		* Address of physical screen
old_pal:	ds.w	16
old_rez:	ds.w	1
video_ptr:	ds.b	1
video_ptr2:	ds.b	1		* Pointers for vbl routine


pic_name2:	dc.b	"BACKGRND.PIC",0
pic_name:	dc.b	"BACK2.PIC",0