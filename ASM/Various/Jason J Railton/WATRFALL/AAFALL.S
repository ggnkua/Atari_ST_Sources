**********************************************************************
* Program to load in the NEOCHROME waterfall,                        *
* display it with cycling colours, wait for [SPACE] to be pressed,   *
* and exit.                                                          *
* If you don't have a copy of the waterfall, AAFALL.NEO, then put the*
* name of any .NEO file at the end of this listing, and the program  *
* will load that and cycle the last eight colours.                   *
*                                                                    *
*A startup/shutdown, joystick and interrupt demonstration by         *
*Jason J. Railton, with lots of extra comments to really make it look*
*untidy.                                                             *
*                                                                    *
*P.S. This is written for Devpac. Set tab spacing to 8.              *
*All information from ST Format/Bullfrog source code examples and two*
*books that are so staggeringly brilliant you can't hope to cope     *
*without them:                                                       *
*                                                                    *
*COMPUTE!'s Technical Reference Guide ATARI ST VOLUME THREE TOS      *
*Sheldon Leemon, COMPUTE! Books, Greensboro, North Carolina, Radnor, *
*Pennsylvania. ISBN 0-87455-149-8, Barcoded 9 780874 551495  90000   *
*(Try Foyle's bookshop, Charing Cross Road, London: from Tottenham   *
*Court Road tube, head south and it's on the right.) $24.95 or œ22.95*
*                                                                    *
*MOTOROLA MC68000 PROGRAMMING POCKET REFERENCE GUIDE                 *
*Book number M68000RGE/AD, available only from MOTOROLA Ltd.         *
*Colvilles Road,Kelvin Estate,East Kilbride,Glasgow,G75 OTG,Scotland.*
**********************************************************************

*Define the amount of memory I want reserving:

WORKSPACE	equ 32000+512		|Enough for screen and 2 page
*					|spacing (2*256 bytes).

*My library routines are normally saved in the subdirectory 'library',
*and brought in with the 'include' command.  Here, I've pasted the two
*library listings in to give you the entire code. 

*	include A:\LIBRARY\STARTUP.I	|Standard startup.
**********************************************************************
start_of_file

*
* Basic start-up code.
*
* WORKSPACE is to be set to the amount of workspace required for the
* program.  The first 32256 bytes of this will be the backup screen.
*
* Program should begin by stating WORKSPACE:
*
*	WORKSPACE equ 32256 or more
*
* and then including this file:
*
*	include a:\library\startup.i
*
* The program should begin with the label 'main' and end with an RTS
* instruction, but a 'BRA exit' will also work.
*
* The subroutine screen_swap is defined, and useful pointers are
* m_block,logic,physic,back,stick_vector
*

*P.S. Note that I set up two screens, bu have three pointers, stored
*at the labels 'logic', 'physic' and 'back'.  'physic' is the physical
*screen that you see, 'back' the hidden back screen, and I use 'logic'
*as a pointer to the screen on which I draw.  Usually this is the same
*as 'back' (to update the hidden screen) but then I can set 'logic' to
*equal 'physic' when debugging, so my program writes to the visible
*screen.  Screen pointer codes 'physic_code' and so on have their 
*mid-lower 8 bits shifted to the low 8 bits.  This is how the system
*takes its screen addresses.  The subroutine 'screen_swap' swaps the
*two screens over, leaving 'logic' pointing to the new back screen.
*You'll see how these are used later...

start
	move.l	sp,old_stack		|Store stack pointer.
	
	clr.l	-(sp)			|Toggle to
	move.w	#$20,-(sp)		|Supervisor Mode.
	trap	#1			|
	addq	#6,sp			|SUPER

*** TRANSFER INITIAL SYSTEM DATA TO STORAGE ***
	
	movem.l	$ffff8240.w,d0-d7	|Store palette.
	movem.l	d0-d7,colour_store
	
	move.w	#2,-(sp)		|PHYSBASE, get screen address.
	trap	#14			|
	addq.l	#2,sp			|PHYSBASE
	move.l	d0,screen_address_store	|Store screen address.
	
	move.w	#4,-(sp)		|Get screen resolution.
	trap	#14			|
	addq.l	#2,sp			|GETREZ
	move.w	d0,resolution_store	|Then store screen resolution.

	move.l	$70,v_blank_store	|Store 50Hz Interrupt Vector.
	
*Here I calculate the size of the program itself, leaving some room
*for requirements such as stack and heap.  This is taken largely from
*COMPUTE!'s TOS Guide...
	move.l	sp,a6			|Copy stack pointer.
	move.l	4(a6),a6		|Get basepage address.
	move.l	12(a6),d0		|Get length of code segment...
	add.l	20(a6),d0		|Add length of data segment...
	add.l	28(a6),d0		|Add length of storage segment...
	add.l	#$4000,d0		|Add size of stack and heap...
	add.l	#$100,d0		|Add size of base page.
*Now to set up the new stack and call MSHRINK, to return unused memory
*to the system....
	move.l	d0,d1			 |
	add.l	a6,d1			 |Add address of basepage to length,
	and.l	#-2,d1			 |then make even, to give 
	move.l	d1,sp			 |new stack pointer.
	move.l	d0,-(sp)		|Push size of program memory.
	move.l	a6,-(sp)		|Push start address.
	clr.w	-(sp)			|Push dummy clear word.
	move.w	#$4a,-(sp)		|Shrink memory required.
	trap	#1			|
	add.w	#12,sp			|MSHRINK

*Now call MALLOC, to allocate some of that free memory back to the
*program.  (It's possible later to return the workspace to the system
*without losing the program itself, since the two are in separate
*memory blocks.)
	move.l	#WORKSPACE,-(sp)	|Allocate a memory block.
	move.w	#$48,-(sp)		|
	trap	#1			|
	addq	#6,sp			|MALLOC
	move.l	d0,m_block		|
	
	move.l	screen_address_store,d0	|Store screen address as
	move.l	d0,physic		|physic.
	lsr.w	#8,d0			|Calculate pointer of
	move.l	d0,physic_code		|physical screen.
	
	move.l	m_block,d0		|Get memory block address
	add.l	#255,d0			|and then
	clr.b	d0			|fit on a page boundary,
	move.l	d0,back			|to get back screen address.
	lsr.w	#8,d0			|Calculate back screen pointer.
	move.l	d0,back_code		|

	move.l	back,logic		|Define logical screen as
	move.l	back_code,logic_code	|back screen.
	
	move.w	#0,-(sp)		|For low resolution.
	move.l	physic,-(sp)		|Current screen address
	move.l	physic,-(sp)		|twice (no change).
	move.w	#5,-(sp)		|For SETSCREEN.
	trap	#14			|
	add.l	#12,sp			|SETSCREEN


*** FIND JOYSTICK VECTOR ***

	move.w	#34,-(sp)		|Get keyboard vector table
	trap	#14			|base address.
	addq.l	#2,sp			|KBDVBASE
	add.l	#24,d0			|Add 24 to get joystick vector.
	move.l	d0,stick_vector		|Store.
	move.l	d0,a0			|Preserve old vector.
	move.l	(a0),stick_handler_store

*** SWITCH MOUSE OFF, AND JOYSTICKS ON ***

wait_mouse_off
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq	wait_mouse_off		|to signal ready to receive.
	move.b	#$12,$fffffc02.w	|Disable mouse.
wait_sticks_on
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq	wait_sticks_on		|to signal ready to receive.
	move.b	#$15,$fffffc02.w	|Joystick interrogation mode.

	move.b	$484,conterm_store	|Store system var. conterm.
	bclr.b	#0,$484			|Keyclick burn in hell.
	bclr.b	#1,$484			|Auto repeat off.
	bclr.b	#2,$484			|Ctrl+G ping off.

*** BRANCH TO MAIN PROGRAM ***
	
	jsr main
	
*** RESTORE INITIAL SYSTEM DATA AND EXIT ***

exit
	move.l	m_block,-(sp)		|Return memory block to
	move.w	#$49,-(sp)		|system.
	trap	#1			|
	addq	#6,sp			|MFREE

	move.l	stick_vector,a0		|Restore old stick vector.
	move.l	stick_handler_store,(a0)

wait_sticks_off
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq	wait_sticks_off		|to signal ready to receive.
	move.b	#$15,$fffffc02.w	|Disable joysticks.
wait_mouse_on
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq	wait_mouse_on		|to signal ready to receive.
	move.b	#$8,$fffffc02.w		|Mouse relative mode (normal).

	move.b	conterm_store,$484	|Restore system var. conterm.

	move.l	v_blank_store,$70	|Restore 50Hz Interrupt Vector.
	
	movem.l	colour_store,d0-d7	|Restore palette.
	movem.l	d0-d7,$ffff8240.w	|

	move.w	resolution_store,-(sp)		|For low resolution.
	move.l	screen_address_store,-(sp)	|Old screen address
	move.l	screen_address_store,-(sp)	|twice.
	move.w	#5,-(sp)			|For SETSCREEN.
	trap	#14				|
	add.l	#12,sp				|SETSCREEN

	clr.l	-(sp)			|Toggle back to
	move.w	#$20,-(sp)		|User Mode.
	trap	#1			|
	addq	#6,sp			|SUPER

	move.l	old_stack,sp		|Restore stack pointer.

	clr.w	-(sp)			|Exit to GEM.
	trap	#1			|PTERM0

*** A SUBROUTINE TO SWAP SCREENS ***

screen_swap
	move.l	physic,logic
	move.l	physic_code,logic_code
	move.l	back,physic
	move.l	back_code,physic_code
	move.l	logic,back
	move.l	logic_code,back_code

	move.l	physic_code,$ffff8200.w
	rts

*** MY SYSTEM VARIABLES ***

m_block
	ds.l	1	Address of allocated memory block.
physic
	ds.l	1 	Address of visible screen.
back
	ds.l	1	Address of backup screen.
logic
	ds.l	1	Address of current drawing screen.
physic_code
	ds.l	1	Screen pointer of visible screen.
back_code
	ds.l	1	Screen pointer of back screen.
logic_code
	ds.l	1	(A temporary store really)
stick_vector
	ds.l	1	The joystick packet pointer.

*** STORAGE OF INITIAL SYSTEM DATA ***

old_stack
	ds.l	1
colour_store
	ds.w	16
resolution_store
	ds.l	1
screen_address_store
	ds.l	1
v_blank_store
	ds.l	1
stick_handler_store
	ds.l	1
conterm_store
	ds.w	1

end_of_file
*****************************************************************

*	include A:\LIBRARY\LOAD.I	|File loading macro & sub.
*****************************************************************
*This is quite a powerful thing to include.  It first defines a macro
*that will set up a0, a1 and d1 and call the subroutine (also included)
*when you type the command line 'LOAD' (read the definition below
*carefully. Note that 'address' is a LABEL at which the load address
*is to be found.  This code should go between STARTUP and MAIN, and
*should not be allowed just to run.  Without a0, a1 and d1 set up
*first, anything could happen.

*** MACRO TO LOAD A FILE ***

*
* Include between STARTUP and MAIN program.
*
* Call with LOAD file_name,address,length
* where: file_name - points to the file name (then a 0b, then 'even').
*        address   - is the address of a _pointer_ to the load address.
*        length    - is the length of the file in bytes.
*
* Alternatively, set up the following:
*	a0 - Address of filename, terminated with a 0 byte.
*	a1 - Address to load file to.
*	d1 - Length of file to load.
*
* And call the main routine with:
*	jsr do_load	
*
* Either way, on return a0,a1 and d1 are as above, and d0 contains
* either a 0 for a successful operation, or -1 for an error.
*

*Here's the macro definition...
LOAD	MACRO
	move.l	#\1,a0
	move.l	\2,a1
	move.l	#\3,d1
	jsr	do_load
	ENDM

*And here's the load subroutine...
do_load
	clr.w	-(sp)			|Read only.
	move.l	a0,-(sp)		|Address of filename, param. 1.
	move.w	#$3d,-(sp)		|For FOPEN.
	trap	#1			|
	addq.l	#8,sp			|FOPEN
	tst.w	d0			|d0 is either the handle
	blt	bad_load		|or a negative error code.
	
	move.l	a1,-(sp)		|Address to load to, param. 2.
	move.l	d1,-(sp)		|File length, param 3.
	 move.l	d0,d1			 |Preserve file handle.
	move.w	d0,-(sp)		|File handle from FOPEN.
	move.w	#$3f,-(sp)		|For FREAD.
	trap	#1			|
	add.l	#12,sp			|FREAD
	tst.w	d0			|d0 is either the number of
	ble	bad_load		|bytes read, 0 or -ve.
	
	move.w	d1,-(sp)		|Why d0 (handle) was preserved.
	 move.l	d0,d1			|Return no bytes loaded to d1.
	move.w	#$3e,-(sp)		|For FCLOSE.
	trap	#1			|
	addq.l	#4,sp			|FCLOSE
	tst.w	d0			|d0 is 0 for success,
	blt	bad_load		|-ve for failure.
	
	clr.l	d0			|Signal OK.
	rts				|Finished.

bad_load
	move.l	#-1,d0			|Signal error.
	rts				|Return.
*****************************************************************

*Now, after those two includes, the program continues.
*The startup routine branches out to the program with the label 'main'.

main	

*A Neochrome file has 128 bytes of data before the main picture data,
*so first I'll move the back screen up a page to allow room.  That way
*the file can be loaded right in place.
	move.l	back,d0			|Get initial backscreen address.
	add.l	#256,d0			|Move up a page.
	move.l	d0,back			|Put new address.
	move.l	d0,logic		|
	lsr.w	#8,d0			|Calculate pointer.
	move.l	d0,back_code		|Put new pointer.
	move.l	d0,logic_code		|

*Now calculate where to load the .NEO file...
	move.l	back,a0			|Get backscreen address.
	sub.w	#128,a0			|Go back 128 bytes.
	move.l	a0,file_dest		|Store result at label.	
	 
*Load in the .NEO file...
	LOAD	file_name,file_dest,32128	|Load file macro.
	tst.b	d0				|Check for a good load.
	blt	exit				|

*Set the palette according to the .NEO file...
	move.l	file_dest,a0		|
	addq.w	#4,a0			|Locate palette in .NEO file.
	movem.l	(a0),d0-d7		|
	movem.l	d0-d7,$ffff8240.w	|Copy in palette.
	
*Swap screens to reveal the picture...
	bsr	screen_swap		|Screen swap subroutine.
	
*Put the address of my VBI routine in the 50Hz vector at $70...
	move.l	#vbi_routine,$70	|Install vbi routine.
	
*Put the address of my joystick routine at the vector found in STARTUP.
	move.l	stick_vector,a0
	move.l	#stick_routine,(a0)	|Install joystick vector
	
*Now count in tens until the limit is reached, shift the colours once,
*then start counting again.  All the while testing the joystick...

	move.l	#100,d0			|Initial delay.
*					|Note that counter goes up in
*					|tens, and d0 is adjusted by
*					| +- 1 by the joystick. This
*					|slows down the stick response.

	clr.w	stick_state		|Clear joystick state.

main_loop
	clr.l	counter			|Reset counter.

wait_count

test_space	
	cmp.b	#$39,$fffffc02.w	|Check for [SPACE] press.
	beq	end_main		|If so, get out.

*'reverse' flags if the colour cycling is to go backwards (when 'fire'
*is pressed).

	clr.b	reverse			|Clear reverse status.
stick_test				
	move.b	stick_state,d1		|Fetch joystick state.
test_fire
	btst.b	#7,d1			|If joystick is FIRE...
	sne.b	reverse			|...set reverse status.
test_right
	btst.b	#3,d1			|If joystick is RIGHT...
	beq	test_left		|
	cmpi.w	#10,d0			|...and d0 > 10...
	ble	test_left		|
	subq.w	#1,d0			|...then decrement delay, d0.
test_left
	btst.b	#2,d1			|If joystick is LEFT... 
	beq	test_done		|
	cmpi.w	#500,d0			|...and d0 < 500...
	bge	test_done		|
	addq.w	#1,d0			|...then increment delay, d0.
test_done
	clr.w	stick_state		|Reset joystick state.
wait_stick
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq.s	wait_stick		|ready.
	move.b	#$16,$fffffc02.w	|Request next joystick packet.

*Joystick packets don't occur immediately, so I request one just after
*checking the previous joystick state, allowing some time for the
*packet to occur before checking it again.

	bsr	wait_vbi		|Wait for next vertical blank.

	move.l	counter,d1		|Wait for counter to reach d0.
	cmp.w	d0,d1			|
	blt	wait_count		|

*When the count has been reached...	
on_count
	tst.b	reverse			|If reverse (fire held down)
	bne	back_shift		|do a different shift.
frwd_shift
	move.l	d0,-(sp)		|Using d0, so preserve...
	movem.w	$ffff8250.w,d1-d7	 |Shift top half of palette,
	move.w	$ffff825e.w,d0		 |upwards.
	movem.w	d0-d7,$ffff8250.w	 |
	move.l	(sp)+,d0		|...and restore d0.

	bra	main_loop		|Do pause loop again.

back_shift
	move.l	d0,-(sp)		|Using d0, so preserve...
	movem.w	$ffff8252.w,d0-d6	 |Shift top half of palette,
	move.w	$ffff8250.w,d7		 |downwards. (Whilst fire
	movem.w	d0-d7,$ffff8250.w	 |button is held down).
	move.l	(sp)+,d0		|...and restore d0.

	bra	main_loop		|Do pause loop again.

end_main
	rts				|Return and exit.

**********************************************************************
*This subroutine will wait for a vertical blank to occur by clearing
*a byte, then waiting until the interrupt routine clears it again.  If
*the interrupt routine is not working correctly, this subroutine will
*wait forever.

wait_vbi
	clr.b	vbi_flag		|Clear vbi flag.
wait_for_vbi_flag
	tst.b	vbi_flag		|Wait for vbi routine to set
	beq	wait_for_vbi_flag	|flag byte, to indicate
	rts				|interrupt has occurred.

**********************************************************************
*This routine is called every vertical blank....

vbi_routine
	move.l	d0,-(sp)		|Using d0, so preserve...
	move.l	counter,d0		 |VBI routine simply
	add.l	#10,d0			 |adds 10 to the counter
	move.l	d0,counter		 |each time it occurs,
	st.b	vbi_flag		 |and flags here.
	move.l	(sp)+,d0		|...and restore d0.
	rte				|End of interrupt.

**********************************************************************
*This routine is called by the system
*when a joystick packet is requested.
*a0 is set by the system to point to
*the joystick information.

stick_routine
	move.w	d0,-(sp)		|Using d0, so preserve...
	clr.w	d0			 |Clear d0 to word length.
	move.b	1(a0),d0		 |Get state of stk 1 (a0 given)
	move.b	d0,stick_state		 |and place at storage.
	move.w	(sp)+,d0		|...and restore d0.
	rts				|End of joystick handler.
*				The byte stored at stick_state uses
*				the bit 7 to signal fire, and bits
*				0-3 for direction:  F...RLDU
*				A similar byte may be obtained from 
*				address (a0) for stick 0.

vbi_flag
	ds.w	1
counter
	ds.l	1
stick_state
	ds.w	1
reverse
	ds.w	1
file_dest
	ds.l	1

file_name
	dc.b	'aafall.neo',0		|File name, terminated with a
*					|0 value, not character '0'.
	even				|Always use 'even' after a byte
*					|definition, just in case an
*					|odd number of bytes are used.
