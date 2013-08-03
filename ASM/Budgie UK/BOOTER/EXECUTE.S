**   December 30, 1989
* makes boot sector executable
*------------------------------------------**
	bra.s	start
	include "a:\includes\macros.s
	even
start	startup
	jsr	superin		go supervisor
	jsr	phys_base	get physbase
	move.l	d0,physbase	used by exit routine

*-------------------------------------------------------
	dc.w	$a000
	move.l	a0,a_line_start
	move.l	(a1)+,d0	6*6 font
	move.l	(a1)+,fontaddress_8
	move.l	(a1),fontaddress_16
	hide_mouse
	btst	#7,$fffa01	mfp monochrome detect
	beq	hide
	mode	0
	
hide	cursor	0

	bclr 	#0,$484		no keyclick
	bclr 	#1,$484		no repeat key

	move.l	#dtaddress,-(sp)	address of 44-byte DTA buffer
	move.w	#$1a,-(sp)	        set DTA address
	trap	#1
	addq.l	#6,sp

start_prog
	load	a1_font,a1_ptr		font 16 pixels
	load	a2_font,a2_ptr		font  8 pixels

	cls
	font	16
	ink	15
	move.w	#$070,$ff825c
	move.w	#$070,$ff825e
	printat	15,0,0,#mess1
	getkey
	jsr	read_sector		read boot sector
	jsr	boot_sector		prepare executionable sector
	jsr	write_sector		and write it to disk
	bra 	quit    restore the palette and official quit

*-----------------------------------------------------------*

mess1	dc.b "    THE BUDGIE UK",10,10,13
	dc.b "   BOOT EXECUTIONER",10,10,10,10,10,13
	dc.b "  Insert Disk",10,13
	dc.b "to be made executable",10,13,0
	even

*~~~~~~~~~~~~~~~~~~~~~~~INCLUDES~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	EVEN
	INCLUDE "a:\includes\include1.s"
	EVEN
	INCLUDE "a:\includes\include2.s"
	EVEN
	INCLUDE "a:\includes\include3.s"
	EVEN
	INCLUDE "a:\includes\include4.s"
	even
	INCLUDE "a:\includes\sounds.s"
	EVEN

*~~~~~~~~~~~~~~~~~VARIABLES AND CONSTANTS~~~~~~~~~~~~~~~~~*

;k_repeat	dc.w 0		normally 2
;k_delay		dc.w 0		normally 15

a1_font		DC.B 	"a:\fonts\a1_fat.fon",0
a2_font		DC.B 	"a:\fonts\a2_elegant.fon",0
		even
a1_ptr		DC.L 1		16*8 font
a2_ptr		DC.L 1		8*8 font

;physbase	dc.l 0
screen_0	dc.l 0
screen_1	dc.l 0
screen_2	dc.l 0
screen_3	dc.l 0
lady_screen 	DC.L 0

utility_screen 	DC.L 0
current_screen	dc.l 0
dtaddress	ds.w 52		needed for disk routines
		

palet		DS.W 16		start up palette 

sbuff     	DS.L 1   this address is the last one on the prog
high_scores	dc.l 0
storel		dc.l 0
store		dc.w 0
prompt		dc.w 0
	EVEN

*~~~~~~~~~~~~~~~~~~~THE STACK~~~~~~~~~~~~~~~~~~~~~~~~~~*

	DS.L	256	about 64 used on average
stack	DC.L	0        


*~~~~~~~THE END~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

