start_of_file

start
	move.l	sp,old_stack		|Store stack pointer.
	
	move.w	#4,-(sp)		|Get screen resolution.
	trap	#14			|
	addq.l	#2,sp			|GETREZ
	move.w	d0,resolution_store	|Then store screen resolution.
	cmp.w #2,d0			|
	beq gem_exit			|Quit if hi-res mode.

	dc.w  $A000			|Line A routines...
	dc.w  $A00A			|hide mouse.

	clr.l	-(sp)			|Toggle to
	move.w	#$20,-(sp)		|Supervisor Mode.
	trap	#1			|
	addq	#6,sp			|SUPER

*** TRANSFER INITIAL SYSTEM DATA TO STORAGE ***
	
	movem.l $ffff8240.w,d0-d7	|Store palette.
	movem.l d0-d7,colour_store
	
	move.w	#2,-(sp)		|PHYSBASE, get screen address.
	trap	#14			|
	addq.l	#2,sp			|PHYSBASE
	move.l	d0,screen_address_store |Store screen address.
	
	move.w	sr,status_store 	|Store Status Register.
	move.l	$70,v_blank_store	|Store 50Hz Interrupt Vector.
	move.l	$120.w,h_blank_store	|Store Raster vector.	     
	move.l	$108.w,vector_a_store 	|Store Timer A vector.

	move.b	$fffffa07.w,timer_ab_enable 	|Store MFP data that
	move.b	$fffffa0f.w,timer_ab_inserv 	|is likely to change.
	move.b	$fffffa13.w,timer_ab_mask 	|
	move.b	$fffffa19.w,timer_a_control	|
	move.b	$fffffa1b.w,timer_b_control 	|
	move.b	$fffffa1f.w,timer_a_data	|
	move.b	$fffffa21.w,timer_b_data	|

	move.l	sp,a6			|Copy stack pointer.
	move.l	4(a6),a6		|Get basepage address.
	move.l	12(a6),d0		|Get length of code segment...
	add.l	20(a6),d0		|Add length of data segment...
	add.l	28(a6),d0		|Add length of storage segment...
	add.l	#$4000,d0		|Add size of stack and heap...
	add.l	#$100,d0		|Add size of base page.
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

	move.l	#WORKSPACE,-(sp)	|Allocate a memory block.
	move.w	#$48,-(sp)		|
	trap	#1			|
	addq	#6,sp			|MALLOC
	move.l	d0,m_block		|
	
	move.l	screen_address_store,d0 |Store screen address as
	move.l	d0,physic		|physic.
	lsr.w	#8,d0			|Calculate pointer of
	move.l	d0,physic_code		|physical screen.
	
	move.l	m_block,d0		|Get memory block address
	add.l	#255,d0 		|and then
	clr.b	d0			|fit on a page boundary,
	move.l	d0,back 		|to get back screen address.
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
	add.l	#16,d0			|Add 16 to get mouse vector.
	move.l	d0,mouse_vector 	|Store.
	move.l	d0,a0			|Preserve old vector.
	move.l	(a0),mouse_handler_store
	add.l	#8,d0			|Add 24 to get joystick vector.
	move.l	d0,stick_vector 	|Store.
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
	bclr.b	#0,$484 		|Keyclick burn in hell.
	bclr.b	#1,$484 		|Auto repeat off.
	bclr.b	#2,$484 		|Ctrl+G ping off.

	move.l	$118.w,keyboard_store 	|Store keyboard vector.

	move.w	#5,-(sp)    	|Timer C (system clock).
	move.w	#26,-(sp)   	|Disable it.
	trap  #14     		|
	addq.l	#4,sp	  	|JDISINT

	move.w	#$2300,sr	|Set IPL to 3 (allows VBI at 4).

*** BRANCH TO MAIN PROGRAM ***
	
	jsr main

*** RESTORE INITIAL SYSTEM DATA AND EXIT ***

exit
	move.w	#$2700,sr	|Disable interrupts.

	move.w	#5,-(sp)	|Timer C (system clock).
	move.w	#27,-(sp)	|Enable it.
	trap  #14     		|
	addq.l	#4,sp		|JENABINT

	move.l	m_block,-(sp)		|Return memory block to
	move.w	#$49,-(sp)		|system.
	trap	#1			|
	addq	#6,sp			|MFREE

	move.l	stick_vector,a0 	|Restore old stick vector.
	move.l	stick_handler_store,(a0)
	move.l	mouse_vector,a0 	|Restore old stick vector.
	move.l	mouse_handler_store,(a0)

	move.l	keyboard_store,$118.w 	|Restore keyboard vector.

wait_sticks_off
	btst.b	#1,$fffffc00.w		|Wait for keyboard controller
	beq	wait_sticks_off 	|to signal ready to receive.
	move.b	#$15,$fffffc02.w	|Disable joysticks.

restore_mouse
	pea	relative_mode		|
	move.w	#6,-(a7)		|
	move.w	#25,-(a7)		|
	trap	#14			|
	addq.l	#8,a7			|Return mouse to relative mode.
	
	move.b	conterm_store,$484	|Restore system var. conterm.

	clr.b	$fffffa19.w		|Freeze TIMER A.
	clr.b	$fffffa1b.w		|Freeze TIMER B.
	move.l	v_blank_store,$70	|Restore 50Hz Interrupt Vector.
	move.l	h_blank_store,$120.w	|Restore Raster vector.        
  move.l  vector_a_store,$108.w 	|Restore Timer A vector.

	move.b	timer_ab_enable,$fffffa07.w 	|Restore MFP data that
	move.b	timer_ab_inserv,$fffffa0f.w 	|is likely to have
	move.b	timer_ab_mask,$fffffa13.w 	|changed.
	move.b	timer_a_control,$fffffa19.w 	|
	move.b	timer_b_control,$fffffa1b.w 	|
	move.b	timer_a_data,$fffffa1f.w  	|
	move.b	timer_b_data,$fffffa21.w  	|

	move.w	status_store,sr 	|Restore Status Register.

	movem.l colour_store,d0-d7	|Restore palette.
	movem.l d0-d7,$ffff8240.w	|

	move.w	resolution_store,-(sp)		|For low resolution.
	move.l	screen_address_store,-(sp)	|Old screen address
	move.l	screen_address_store,-(sp)	|twice.
	move.w	#5,-(sp)			|For SETSCREEN.
	trap	#14				|
	add.l	#12,sp				|SETSCREEN

	dc.w  $A000	|Line A routines...
	dc.w  $A009	|Show mouse.

	move.l	old_stack,sp		|Restore stack pointer.

gem_exit
	clr.w  -(sp)			|Exit to GEM.
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
	ds.l	1	Address of visible screen.
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
mouse_vector
	ds.l  1 The mouse handler pointer.
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
h_blank_store
	ds.l	1
vector_a_store
  ds.l	1
status_store
	ds.w	1
mouse_handler_store
	ds.l  1
stick_handler_store
	ds.l	1
conterm_store
	ds.w	1
keyboard_store
	ds.l  1
timer_ab_enable
	ds.b  1
timer_ab_mask
	ds.b  1
timer_ab_inserv
	ds.b  1
timer_a_control
	ds.b  1
timer_b_control
	ds.b  1
timer_a_data
	ds.b  1
timer_b_data
	ds.b  1
  	even

relative_mode	dc.b	$08		|Relative mode.
		dc.b	$10		|Y-origin at top (Down =+ve).
		dc.b	$07,$00 	|Mouse-click reports off.
		dc.b	$0b,$01,$01	|Mouse threshold = 1, in X & Y
		even


end_of_file
