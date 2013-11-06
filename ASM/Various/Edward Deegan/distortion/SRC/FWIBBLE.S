*****************************************************************
*								*
*	MEGA-WIBBLER - routine to do some serious distortion!	*
*								*
*     Written from scratch, started Dec 4th 1991 by Edd Deegan	*
*								*
*****************************************************************


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

		clr.l	-(sp)		* Super mode
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	D0,save_stack
		
* First save all default parameters
		move.w	#2,-(sp)	* Get physical screen
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_phys
		move.l	D0,physic
		sub.l	#32256,D0
		move.l	D0,logic	* Point to logical screen

		move.w	#3,-(sp)	* Get logical screen
		trap	#14
		addq.l	#2,sp
		move.l	D0,real_log

		move.w	#4,-(sp)	* Get resolution
		trap	#14
		addq.l	#2,sp
		move.w	D0,real_res

		cmp.b	#2,D0
		beq	hi_error	* Not Hi-Res - sorry

		pea	dta_buf
		move.w	#$1A,-(sp)	* Set DTA address
		trap	#1
		addq.l	#6,sp

* Now need to load file containing graphic image.
		move.l	#picfilename,file_ptr
		jsr	getfile

		tst.l	D0
		beq	set_screen
		jsr	l_error
		jmp	to_gem

set_screen:	move.w	#$00,-(sp)
		move.l	#-1,-(sp)
		move.l	logic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		
* Set new palette (found at image_ptr + 2)
set_palette:	move.l	image_ptr,A0
		add.l	#2,A0
		move.l	A0,-(sp)
		move.w	#6,-(sp)
		trap	#14		* Change palette
		addq.l	#6,sp

* -----------------------------------------------------------------------
* End of mundane housekeeping. Image loaded, palette saved, screen
* parameters saved, and new parameters installed.
* -----------------------------------------------------------------------

* Now need to do a lot of initialisation.
*
* 4 workscreens (one already in memory - image_ptr)
* Shift image 1 pixel right, copy it to workspace.
* Repeat 15 times, using a list of workspace addresses.
* These addresses then point to each of the actual images in memory

		move.l	#32000*3,-(sp)	* 4 screen-sized workscreens
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	D0
		ble	malloc_error
		move.l	D0,workbase
	
* - Workbase points to a stack of four screens.
* - Set up a list of workspace pointers

		move.l	workbase,A0
		lea	worklist,A1
		move.l	#15,D0		* Number of list items

initlist:	move.l	(A1),D1		* Get offset from list
		add.l	A0,D1		* Add workspace address
		move.l	D1,(A1)+	* Replace in list
		dbf	D0,initlist	* Repeat for whole list

* - List now holds absolute address of each image
* - Fill image spaces with shifted images

		move.l	image_ptr,A6
		add.l	#34,A6		* Point to image itself
		lea	worklist,A5	* Point to address list

		move.l	A6,A0
		move.l	(A5)+,A1
		jsr	scr_copy	* Copy screen to workspace 1

		move.l	#14,D7		* Number of screens left
init_works:	move.l	A6,A0
		jsr	shift		* Shift image
		move.l	A6,A0
		move.l	(A5)+,A1
		jsr	scr_copy	* Copy image to worksrceen
		dbf	D7,init_works	* Repeat for rest of screens

		move.l	image_ptr,-(sp)
		move.w	#$49,-(sp)
		trap	#1		* Free loaded image bank
		addq.l	#6,sp

		move.l	#95,D0
		lea	dist_list2,A0
init2:		clr.w	(A0)+
		dbf	D0,init2

		move.l	#95,D0
		lea	dist_list1,A0
init3:		move.w	#40,(A0)+	* Default distortion lists
		dbf	D0,init3

clear:		move.l	logic,A0
		move.l	physic,A1
		move.l	#7999,D0
clear1:		clr.l	(A0)+
		clr.l	(A1)+
		dbf	D0,clear1

		jsr	initmous

* --> Finished initialisation

* \ Now. 
*	Move bottom line
*		{
*		Get X_COORDNATE for line
*		Convert to byte offset + workscreen
*			{
*			divide by 16 - remainder is workscreen
*			multiply by 8 - answer = byte offset
*			}
*		place line at bottom of screen
*		shift source address queue along
*		push source address onto queue
*		}
*	Update rest of lines
*		{
*		point to 2nd from bottom line
*		get address from queue
*		display line taking that address as source
*		point up a line
*		}

dist_loop:	move.l	#15200,D2		* Offset to last line
		clr.l	D0
		move.w	mouse_posx,D0		* Get X_COORD

		divu.w	#16,D0		* Get remainder for workscreen number
		move.l	D0,D1
		swap	D1		* Get workspace number
		asl.w	#3,D0		* Get byte offset

		move.l	logic,A0
		add.l	D2,A0		* Vertical offset for image

* D1 = Workspace number
* D0 = Byte offset for the line
* D2 = Offset to (bottom) line of image
* A0 = Destination on logical screen (absolute address)
* A5 = Address of workspace address list

		move.w	D1,workspace_no
		move.w	D0,byte_offset	* Save values

		add.w	D0,A0		* Add horizontal offset

		lea	worklist,A4
		asl.w	#2,D1		* Make an offset
		add.w	D1,A4		* Point to address of source screen
		move.l	(A4),A4		* A4 = address of source screen
		add.l	D2,A4		* Point to current line
		
		move.l	A0,A6
		lea	16000(A6),A6

* Copy line to screen
		clr.l	-16(A0)
		clr.l	-16(A6)
		clr.l	-12(A0)
		clr.l	-12(A6)
		clr.l	-8(A0)
		clr.l	-8(A6)
		clr.l	-4(A0)
		clr.l	-4(A6)
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A0)+
		clr.l	(A0)
		clr.l	(A6)
		clr.l	4(A0)		
		clr.l	4(A6)
		clr.l	8(A0)
		clr.l	8(A6)
		clr.l	12(A0)
		clr.l	12(A6)
		
* --> Place rest of lines, using screen numbers and byte offsets

		lea	dist_list1x,A0
		lea	dist_list2x,A1
		move.l	#94,D0		* Number of items to shift

listshift:	move.w	(A0),2(A0)
		move.w	(A1),2(A1)
		subq.l	#$02,A0
		subq.l	#$02,A1		* Shift list
		dbf	D0,listshift

		move.w	byte_offset,dist_list1	* Add to list
		move.w	workspace_no,dist_list2

* --> Place rest of lines.

		lea	dist_list1,A0	* Byte offsets
		lea	dist_list2,A1	* Workscreen numbers
		addq.l	#$02,A0
		addq.l	#$02,A1		* Skip the bottom line
		move.l	#94,D7		* Number of lines

rest_loop:	move.l	logic,A3	* Dest address
		add.l	D2,A3		* + offset
		move.w	(A0)+,D0	* Get byte offset
		add.w	D0,A3		* Add it to target address

		move.w	(A1)+,D0	* Workscreen
		asl.w	#2,D0		* x 4

		lea	worklist,A4
		add.w	D0,A4
		move.l	(A4),A4		* Source address
		add.l	D2,A4		* Plus offset

		move.l	A3,A6
		lea	16000(A6),A6

		clr.l	-16(A3)
		clr.l	-16(A6)
		clr.l	-12(A3)
		clr.l	-12(A6)
		clr.l	-8(A3)
		clr.l	-8(A6)
		clr.l	-4(A3)
		clr.l	-4(A6)
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+	* Place line
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		move.l	(A4),(A6)+
		move.l	(A4)+,(A3)+
		clr.l	(A3)
		clr.l	(A6)
		clr.l	4(A3)
		clr.l	4(A6)
		clr.l	8(A3)
		clr.l	8(A6)
		clr.l	12(A3)
		clr.l	12(A6)

		sub.l	#160,D2		* Point to previous line

		dbf	D7,rest_loop
		jsr	swap_screen
		jmp	dist_loop

swap_screen:	move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp

		move.w	#-1,-(sp)
		move.l	logic,-(sp)
		move.l	physic,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	logic,-(sp)
		move.l	physic,logic
		move.l	(sp)+,physic
		cmp.b	#248,mse_packet
		bne	to_gem
		rts

debug:		movem.l	A0-A6/D0-D7,-(sp)
		move.w	#$08,-(sp)
		trap	#1
		addq.l	#2,sp
		cmp.b	#" ",D0
		beq	debug_exit
		movem.l	(sp)+,A0-A6/D0-D7
		rts

debug_exit:	movem.l	(sp)+,A0-A6/D0-D7
		addq.l	#$04,sp
		jmp	to_gem

workspace_no:	ds.w	1
byte_offset:	ds.w	1

dist_list1:	ds.w	94	* Byte offsets
dist_list1x:	ds.w	2
dist_list2:	ds.w	94	* Workspace numbers
dist_list2x:	ds.w	2

*************************************************************************
*									*
*	SCR_COPY - Copy 1/4 screen from A0-A1				*
*									*
*************************************************************************

scr_copy:	move.l	#99,D1		* Lines to copy
scr_copy2:	move.l	#19,D0		* Longwords per 1/2 line
scr_copy3:	move.l	(A0)+,(A1)+
		dbf	D0,scr_copy3	* Copy line
		lea	80(A0),A0
		lea	80(A1),A1	* Down a line
		dbf	D1,scr_copy2	* Repeat for rest of lines
		rts

*************************************************************************
*									*
*	SHIFT - shift 1/4 screensized image at A0 1 pixel right		*
*		Right hand pixel is lost.				*
*									*
*************************************************************************

* - Lines to shift: 100
*   Pixels per line: 160 == 40 words

shift:		move.l	#99,D0		* Number of scanlines in image

shift2:		move.l	A0,A1		* Point to line
		jsr	shift_line	* Shift it
		lea	160(A0),A0	* Next line
		dbf	D0,shift2
		rts

*************************************************************************
*									*
*	SHIFT_LINE - shift line of 40 words at A1 1 pixel right,	*
*		     losing right hand pixel				*
*									*
*************************************************************************

* -Start at end of line. Shift last 4 words right.
* -Then go back along line, shifting right. Place carry bit into MSB of
*  word 4 words to the right.
* -Clear the MSB's of 4 leftmost words.

* -A1 points to first word in line

shift_line:	movem.l	A0/D0,-(sp)	* Save important registers
		clr.l	D0
		lea	78(A1),A1	* Point to end of line

		move.l	#3,D1		* Number of init words

shift_line2:	move.w	(A1),D0		* Get word to shift
		asr.w	#1,D0		* Shift one place to right
		move.w	D0,(A1)		* Place back in RAM
		subq.l	#$02,A1		* Point back a word
		dbf	D1,shift_line2

* - Rightmost 4 words are now shifted right. A1 points to word preceding
*   these.

		move.l	#35,D1		* Number of words left in line

shiftline_lp:	move.w	(A1),D0		* Word to shift
		asr.w	#1,D0		* Shift it
		bcs	fill_msb	* If Carry == 1, set MSB of 7(A1)
clear_msb:	bclr	#7,8(A1)	* Else clear MSB
		jmp	after_set
fill_msb:	bset	#7,8(A1)

after_set:	move.w	D0,(A1)		* Replace shifted word
		subq.l	#$02,A1
		dbf	D1,shiftline_lp

* - Now clear MSB of last 4 words
		add.l	#8,A1

		move.l	#3,D1
finish_line:	move.w	(A1),D0
		bclr	#15,D0		* Clear MSB
		move.w	D0,(A1)
		subq.l	#$02,A1
		dbf	D1,finish_line

		movem.l	(sp)+,A0/D0
		rts

*************************************************************************
*									*
*	Here are the actual mouse-interrupt routines themselves. Once	*
*	initmous has been called, the x and y coordinates can be found	*
*	in the two words at mse_coords at any time.			*
*									*
*************************************************************************

initmous: 	move.w	#$08,-(sp)	* IKBD command to send relative mouse
		move.w	#4,-(sp)	* packages from now on
		move.w	#3,-(sp)
		trap	#13
		addq.l	#6,SP
		move.w	#34,-(sp)	* Get address of IKBD vector table
		trap	#14
		addq.l	#2,SP
		movea.l	D0,A0
		adda.l	#16,A0		* Mouse vector address in table
		lea	oldpak(pc),A1
		move.l	(A0),(A1)	* Save original packet handler address
		lea	mouspacket(pc),A1	* address of new packet handler
		move.l	A1,(A0)	
		rts

*************************************************************************
* Mouse packet handler   (called by o/s) 				*
*************************************************************************

mouspacket:	movem.l	D0/A0-A1,-(sp)	* A0 points to packet received
		lea	mse_packet(pc),A1
		clr.l	D0
		move.b	(A0),(A1)	* Header (buttons)
		move.b	1(A0),D0	* X movement
		ext	D0
		add.w	D0,2(A1) 	* New x position (lateral 0-320)
		tst.w	2(A1)		* below 0 ?
		bpl	.m1
		clr.w	2(A1)
.m1		cmp.w	#320,2(A1)	* Too large? off screen
		bmi	.m2		* No  ok
		move.w	#320,2(A1)	* Hold it there

.m2		movem.l	(sp)+,D0/A0-A1
		rts
	
**********************************
* Return to normal mouse control *
**********************************

resmous:	move.w	#34,-(sp)	* Address of IKBD vector table
		trap	#14
		addq.l	#2,SP
		movea.l	D0,A0
		adda.l	#16,A0		* mouse vector
		move.l	oldpak(pc),(A0)	* restore original pack hndler
		move.w	#128,-(sp)	* reset keyboard processor to
		move.w	#4,-(sp)	* power up state
		move.w	#3,-(sp)
		trap	#13
		addq.l	#6,SP		* and again
		move.w	#1,-(sp)	* data to write 128 and 1 = reset
		move.w	#4,-(sp)	* 4 is ikbd
		move.w	#3,-(sp)	* 3 is chr out
		trap	#13
		addq.l	#6,SP
		rts
oldpak:		DC.l	0		* storage for old packet handler address

mse_packet:	dc.b	248		* button
		dc.b  	0 		* empty byte (not used)
mouse_posx:	dc.w 	80
		dc.w	0
		dc.b	0,0,0,0,0,0
		EVEN

*************************************************************************
*									*
*	TO_GEM - tidy up and get lost					*
*									*
*************************************************************************

wait_gem:	move.w	#$08,-(sp)
		trap	#1
		addq.l	#2,sp

to_gem:		jsr	resmous
		move.w	real_res,-(sp)
		move.l	real_phys,-(sp)
		move.l	real_log,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp		* Reset screen parameters

* Restore palette

		pea	palette
		move.w	#6,-(sp)
		trap	#14
		addq.l	#6,sp

		move.l	save_stack,-(sp)
		move.w	#$20,-(sp)
		trap	#1		* User mode again
		addq.l	#6,sp

		clr.w	-(sp)
		trap	#1		

		INCLUDE	"\src\files.s",0

hi_error:	pea	sorry
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp
		jmp	to_gem

malloc_error:	pea	file_err2
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp
		jmp	to_gem

l_unid:		dc.b	"Unidentified Load-related error. Exiting Cleanly.",13,10,0
file_err1:	dc.b	"Graphics file not located on current disk!",13,10,0
file_err2:	dc.b	"Sorry! Not enough memory to run Mega-Wibble!",13,10,0
open_err:	dc.b	"Unable to open file!",13,10,0
read_err:	dc.b	"Error during read!",13,10,0
close_err:	dc.b	"Error closing file!",13,10,0
sorry:		dc.b	"Sorry - Low res only!",13,10,0
		EVEN

palette:	dc.w	$777,$700,$070,$770,$007,$707,$077
		dc.w	$555,$333,$733,$373,$773,$337,$737,$377,$000

handle:		ds.w	1

physic:		ds.w	1
physic2:	ds.w	1

logic:		ds.l	1
save_stack:	ds.l	1
real_res:	ds.w	1
real_phys:	ds.l	1
real_log:	ds.l	1
dta_buf:	ds.b	44
video1:		ds.b	1
video2:		ds.b	1
workbase:	ds.l	1

* - Offsets for all the screen quarters from 'workbase'

worklist:	dc.l	0,80,16000,16080
		dc.l	32000,32080,48000,48080
		dc.l	64000,64080,80000,80080
		dc.l	96000,96080,112000,112080

picfilename:	dc.b	"\graphics\wibble.pi1",0
