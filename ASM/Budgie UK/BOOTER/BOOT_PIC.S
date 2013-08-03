**   December 30, 1989


* devpac 2 REQUIRED to assemble this program
* code will be slotted on boot sector AND made executable
*-------------------------------------------------------**
	bra.s	start
	include "a:\includes\macros.s
	even
start	startup
	jsr	superin		go supervisor
	jsr	phys_base	get physbase
	move.l	d0,physbase	used by exit routine

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

	load	a1_font,a1_ptr		font 16 pixels
	load	a2_font,a2_ptr		font  8 pixels

	cls
	font	16
	ink	15
	move.w	#$070,$ff825c
	move.w	#$070,$ff825e
	printat	15,0,0,#mess1
	getkey
	cls
	font	8
	move.w	#$372,$ff825c
	move.w	#$047,$ff825e
	ink	15
	printat	15,0,0,#mess2
	getkey
	cls
	font	8
	move.w	#$070,$ff825c
	move.w	#$007,$ff825e
	ink	15
	printat	15,0,0,#mess5
	getkey
	swap	d0
	cmp.b	#$01,d0
	beq	quit


	jsr	read_sector		read boot sector
	lea	new_buffer,a1
	bsr	copy_code
	jsr	boot_sector		prepare executionable sector
	jsr	write_sector		and write it to disk
	bra	quit

mess1	dc.b "    THE BUDGIE UK",10,10,13
	dc.b "   BOOT     LOADER",10,13,0
mess2	dc.b "  This program contains the ",10,13
	dc.b " necessary code to display a",10,13
	dc.b " message, then load a pi1 picture",10,13
	dc.b " from root directory, if found.",10,10,13,0
	
mess3	dc.b 0
mess4	
mess5	dc.b "Insert Disk",10,13
	dc.b "to be 'automated'",10,13
	dc.b "Use with care: boot sector",10,13
	dc.b "will be written to!",10,10,13
	dc.b "In doubt, insert blank",10,13
	dc.b "formatted disk.",10,10,13
	dc.b "Press ESC to abort.",10,13,0
	even

*~~~~~~~~~~~~~~~~NOW THE SUBROUTINES~~~~~~~~~~~~~~~~~~~~~~~*
copy_code
	lea	read_buffer,a0		this buffer is 512 bytes long
	add.l	#$3a,a0			put code here
	lea	new_buffer,a1
	move.w	#420,d7			loop
.lll	move.b	(a1)+,(a0)+		transfer to official buffer
	dbra	d7,.lll
	rts

**************************************************************
new_buffer


	CLR.W	-(A7)		0=low res
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	

	move.w	#$632,$ff8240
	pea	text(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
* load a degas picture at a specific address 
	MOVE.W	#0,-(A7)
	pea	name(pc)
	MOVE.W	#$3D,-(A7)
	TRAP	#1
	add.l	#8,sp
	tst.l	d0
	bmi	eit
	MOVE.W	D0,d7	handle

	move.l	$44e,d0		load direct to current screen
	sub.l	#34,d0
	MOVE.L	d0,-(sp) 
	MOVE.L	#34,-(A7)	read it
	MOVE.W	d7,-(A7)	handle
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7

	move.l	$44e,a0
	sub.l	#32,a0		palette
	MOVE.L	A0,-(SP)  
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

	move.l	$44e,d0		load direct to current screen
	MOVE.L	d0,-(sp) 
	MOVE.L	#32000,-(A7)	read it
	MOVE.W	d7,-(A7)	handle
	MOVE.W	#$3F,-(A7)
	TRAP	#1
	ADDA.L	#$C,A7


	MOVE.W 	d7,-(SP)	close
	MOVE.W 	#$3E,-(SP)
	TRAP 	#1
	ADDQ.L 	#4,SP

	move.l	$44e,a0
	sub.l	#32,a0		palette
	MOVE.L	A0,-(SP)  
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

eit	rts
	dc.b	250
name	dc.b	"a:*.pi1",0 
	even
text	
	dc.b	27,69		clear screen (mouse disappears)
	dc.b	27,98,2		ink color 1
	dc.b	10,10,10,10,10,10,10,10,10,10,10,10,10 line feeds
	dc.b	"  Budgie   Boot  Sector",10,10,13
	dc.b	"  A U T O   L O A D E R",10,13,0

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

a1_font		DC.B 	"a:\fonts\a1_play*.fon",0
a2_font		DC.B 	"a:\fonts\a2_squ*.fon",0
		even
a1_ptr		DC.L 1		16*8 font
a2_ptr		DC.L 1		8*8 font

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

