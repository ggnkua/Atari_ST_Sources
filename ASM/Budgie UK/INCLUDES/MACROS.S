*  B U D G I E  U K         December 13, 1989
*-----------MACROS--- (79) -------------------------------------------
* load		font		mode		show		vsync	
* getkey	waitkey		print		printat 	printatt
* home		ink		pen		border		rawconio
* inkey		replay		bindec
* mfree		take		take_two	sprite		restore
* sprit		restor		draw		save		back	
* on		off		flash		grabr
* grab		grab_two	blank		block		blockk
* pixelread	pixelreadd	pixelplot	pixelplott	startup
* cursor	clear		cls		wait		sound	
* scroll	palette		copyscreen	copybytes	copywords
* copylongs	reserve		readd		writee
* open		create		read		write		close
* bios		xbios		gemdos		string		pushi
* show_mouse	hide_mouse	before		after		getjoy 
* joystick	jiffy		delay		reveall		reveal
* acia		key		silence	

* The vast majority of these macros need the Budgie UK
* include.s files to work.  Some also need the Budgie shell.s itself
* Values are normally immediate (ex: pixelplot $44e,20,20,8)
* Sometimes registers are expected. Such macros usually have
* their LAST letter repeated : (ex:pixelplott $44e,d5,d6,d4)

* anybody sending new routines or macros, or reporting bugs
* will receive the latest version + our thanks

load	macro	\1,\2
	move.l	#\1,a0		say move.l #file,a0
	move.l	#\2,a6		say move.l #file_ptr,a6
	jsr	bload		say bsr bload
	endm
* ex :  load file,file_ptr  (# not necessary in this case), where..
* file  	dc.b "apic.pi1",0
* file_ptr  	dc.l 0
* file_ptr will contain the start address given by gem 
* no need to reserve memory. the routine will do it
*--------------------------
* fonts must be loaded in advance.
* ex: load font_1,a1_ptr    load font_2,a2_ptr
* a1_ptr holds 8*16 fonts (4114 bytes)   a2_ptr holds 8*8 (2066 bytes)
* font format is the one used by Jeremy Hughes in his fontsel.acc
* now font macro may be used. Ex: font 16 (will call large font)
font	macro	\1
	move.w	#\1,d6
	dc.w	$a000		initialize A-line
	move.l	a0,a_line_start
	move.l	(a1)+,d0	6*6 font
	move.l	(a1)+,fontaddress_8
	move.l	(a1),fontaddress_16
	cmp.w	#8,d6
	beq	fnt\@
	move.l	a1_ptr,a1
	jsr	fnt_16
	bra	done\@
fnt\@	move.l	a2_ptr,a1
	jsr	fnt_8
done\@	nop	
	endm
* will switch to user font, either 8*8 or 8*16
* ex:	font 8	(will switch to 8*8 font held in a2_ptr)
*	font 16 (will switch to 8*16 font held in a1_ptr)
* see full example in ALL Budgie games, shell, guardian etc...
*---------------------
mode	macro	\1
	move.l	#\1,d0
	cmp.l	#1,d0
	beq	med\@
	tst.l	d0
	beq	low\@
	bra	v\@		if not 0 or 1, ignore	
low\@	jsr	setlowrez
	bra	v\@
med\@	jsr	setmedrez
v\@	vsync
	endm
* ex:	mode 0    (set low res)
*-------------------------
show	macro	\1
	move.l	\1,$45e
	jsr	vtsync
	endm
* will show a particular screen, or anything else in memory
* at the next vertical blank
* ex	show physbase,    show screen_0,   show $44e+512
*	show work_screen, etc...
*---------------------
vsync	macro
	move.l	$466,d0
waitv\@	cmp.l	$466,d0
	beq	waitv\@
	endm
* will wait for vertical blank
* ex	vsync	
* note: D0 will obviously be corrupted. (save if necessary)
* can be used as a time delay
* ex: vsync vsync vsync will delay things 3/50th of sec
*---------------------------
getkey	macro
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	andi.w	#$df,d0		force upper case
	movem.l	(sp)+,d1-d2/a0-a2
	endm
* waits for a key to be hit (unlike rawconio/inkey which doesn't wait)
* the answer is a byte returned in D0  (ascii)
* to get the scan value: swap d0
* see examples in shell.s etc...
*----------------------
waitkey	macro
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	andi.w	#$df,d0		
	movem.l	(sp)+,d1-d2/a0-a2
	endm
* same as getkey
*-------------
print	macro	\1
	move.l	#\1,a0
	jsr	printline
	endm
* ex: 	print message
* message dc.b "hello",10,13,0
* prints a string at CURRENT cursor position
* if unsure as to where cursor is, use: home  print message
* alternatively, use the more precise 'printat' 
*-----------------------------
home	macro	\1
	move.l	#pr_home,a0
	jsr	printline
	endm
* cursor back to home position
* ex: 	home
pr_home	dc.b 27,"H",0
	even
*------------------------
printat	macro	\1,\2,\3,\4
	move.b	#\1,pr_col+2	the ink
	move.b	#\2,d1
	add.b	#32,d1	
	move.b	d1,pr_loc+2	the row
	move.b	#\3,d2
	add.b	#32,d2
	move.b	d2,pr_loc+3	the column	
	move.l	\4,a0
	move.l	a0,-(sp)
	move.l	#pr_col,a0
	jsr	printline	print ink and pos
	move.l	(sp)+,a0	retrieve the address of message
	jsr	printline	print it
	endm

pr_col	dc.b 27,"b",15		no zero here! ,0
pr_loc	dc.b 27,"Y",32,32,0,0	dynamic variables, liable to change!
null	dc.b 0
	even
* ex:	printat	12,2,8,#message+4      where 
* 12 is the ink (0-15), 2 is row (0-23), 8 is column (0-39)
* and last parameter, with a hash, is an address 
* (the message itself which is terminated with a null)
* note registers will be corrupted by printline
*----------------------------------------------
printatt macro	\1,\2,\3
	move.b	\1,pr_col+2	the ink
	move.b	\2,d1
	add.b	#32,d1	
	move.b	d1,pr_loc+2	the row
	move.b	\3,d2
	add.b	#32,d2
	move.b	d2,pr_loc+3	the column	
	move.l	a0,-(sp)	save from corruption
	move.l	#pr_col,a0
	jsr	printline	print ink and pos
	move.l	(sp)+,a0	retrieve the address of message
	jsr	printline	print it
	endm
* similar to previous macro except that registers are used:
* \1 \2 \3 are data regs (byte size)  address is assumed to be a0
* ex:	bindec d0    (go change value in d0 into a string)
*       move.b	#1,d0  (ink)
*       move.b  #3,d1  (4th row)
*       move.b  #0,d2  (first column)
*       printatt d0,d1,d2  (being understood as string at a0)
*------------------------
ink	macro	\1
	move.b	#\1,pr_ink+2	the ink
	lea	pr_ink,a0
	jsr	printline	print it
	home			necessary to activate it
	endm
* ex:	ink 4	(0-15)		will take the color in palette #4
*				and print with it from now on				
pr_ink	dc.b 27,"b",15,0
	even		
*------------
pen	macro	\1
	move.w	#\1,$ff825e
	ink	15
	endm
border	macro	\1
	move.w	#\1,$ff8240
	endm
* ex:	pen	$777	(white)
* ex:	border	$700	(red)
* ex: show screen_0  pen $700  home  string <hello>
*     will print hello in red on screen zero
* note palette #15 ($ff825e) will become red
* ink uses one of the 16 colors,  pen uses ANY shade in color 15
*----------------------------
rawconio macro
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
* checks whether a key has been hit (answer in D0)
* if D0 is zero, no key: continue with program
* ex: 	rawconio  tst.b d0  ... to get scan code: swap d0
inkey	macro
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	endm
* same as above
* ex:	inkey   swap d0  cmp.b #1,d0   beq escape
*------------------------------
* make sure include5.s is included before calling this macro
replay	macro	\1,\2,\3
	move.l	\1,a5
	move.l	#\2,d5
	move.l	#\3,d4
	jsr	r_eplay
	endm
* replays a sample at a certain location, at a certain speed
* ex replay drum_ptr,7448,2   
* (sample address held in drum_ptr,7448 bytes,speed 2
*-----------------------------
* next macro displays any Long Word in 2, 10 or 16
bindec	macro	\1,\2
	movem.l	d0-d7/a1-a6,-(sp)
	move.l	\1,d0		the number to convert (L)
	move.l	#\2,d1		the base: 2, 10, or 16		
	bsr	printn
	move.l	#\2,d0		base again
	cmp.l	#2,d0		binary
	beq	base2\@
	cmp.l	#10,d0		decimal
	beq	base10\@
	move.l	#num_buff+4,a0	hex
	bra	done\@
base2\@ move.l	#num_buff+4,a0	binary
	bra	done\@
base10\@ move.l	#num_buff+4,a0	decimal
done\@	movem.l	(sp)+,d0-d7/a1-a6
	endm
* ex: bindec d0,16  reveals in hex what is in d0
*     then to actually see the number, use printat c,x,y,a0
* where c is color, x-y is cursor position, a0 is the result
* note. the printed result will take 16 characters no less, like this:
*             4509
*            f8000
* 1111000011110000
* to ignore leading spaces: add.l #x,a0
* ex: expected answer is 4509 (0000000000004509)
* to get it left justified: bindec d0,10  add.l #12,a0   printat 1,0,0,a0
* in this case, the first 12 blank spaces will be ignored
*----------------------------------------------------------------
* next one not tested yet
mfree	macro	\1
	move.l	\1,-(sp)	address in handle onto stack
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bmi	error\@
	bra	ok\@
error\@ string	< MFREE ERROR >
ok\@	nop
	endm
* frees an area of memory (tune, picture..) no longer needed
* ex: mfree welcome_ptr
* same as: move.l #welcome_ptr,a6: bsr m_free	
* ex: reserve 160     mfree d0
* the above line reserved 160 bytes then immediately gave it back  
*------------
take	macro	\1,\2,\3,\4,\5,\6
	move.l	\1,a0		origin screen
	move.l	\2,a1		dest screen	
	move.w	#\3,d0		origin  0 to 32000
	move.w	#\4,d1		to screen	 0 to 32000
	move.w	#\5,d2		height	 1 to 200
	move.w	#\6,d3		width	 1 to 160
	jsr	fromto
	endm
* this is a VERY important macro for graphic movement
* origin and destination screens are first specified, them
* origin & destination locations (0-32000) in multiples of 8,
* and finally the height (1-200) and width of the block (8-160)
* ex:   take 	spr_screen,buffer_screen,504,504,60,48 o-d-o-d-h-w
* use take_two if screen swapping is used
* or use this command TWICE, once for each screen
* NOTE both Final Lap and Moneyspinner use take
* Speculator uses an old macro (graber)
*------------------------------------
take_two	macro	\1,\2,\3,\4,\5	screen+34 expected in A0
	move.l	\1,a0		origin screen
	move.w	#\2,d0		origin on Degas 0 to 32000
	move.w	#\3,d1		to screen	 0 to 32000
	move.w	#\4,d2		height	 1 to 200
	move.w	#\5,d3		width	 1 to 160
	bsr	from_two	draw on both screens at once
	endm
* used to draw a sprite on two screens at once i.e. TWICE
* origin screen needed in a0, destination both logical_screen 
* AND physical_screen
* ex:	take_two spr_screen,0,16000,50,48
* use take if only one screen is active
*--------------------------------------
* now grab (same as take, BUT registers are used)
grab	macro	\1,\2,\3,\4,\5,\6
	move.l	\1,a0		origin screen
	move.l	\2,a1		dest screen	
	move.w	d6,d0		origin  0 to 32000
	move.w	d7,d1		to screen	 0 to 32000
	move.w	#\5,d2		height	 1 to 200
	move.w	#\6,d3		width	 1 to 160
	jsr	fromto
	endm
* uses two registers d6 and d7 to indicate the locations
* ex:	grab spr_screen,current_screen,d6,d7,60,48
* move from sprite screen to current screen, an object at d6,
* to destination d7, size 60*48  (d6 & d7 are 0-32000)
*-----------------------------------------------------
* now grab_two (registers are still used but we print on TWO screens)
grab_two	macro	\1,\2,\3,\4,\5
	move.l	\1,a0		origin screen
	move.w	d6,d0		origin  0 to 32000
	move.w	d7,d1		to screen	 0 to 32000
	move.w	#\4,d2		height	 1 to 200
	move.w	#\5,d3		width	 1 to 160
	jsr	from_two
	endm
* uses two registers d6 and d7 to indicate the locations
* ex:	grab_two spr_screen,d6,d7,60,48
* move from sprite screen to both screens, an object at d6,
* to destination d7, size 60*48  (d6 & d7 are 0-32000)
*------------------------------------------
sprite	macro	\1
	move.l	#\1,d0
	move.l	spr_screen,a0		default origin
	move.l	logical_screen,a1	default destination
	jsr	draw_sprite
	endm
* ex: sprite 0  (go and draw sprite 0)
*     sprite 5  (go and draw sprite 5)
* a sprite parameter-block must have been defined first
* it is held in an array called 'sprites'
* a typical sprite system would be:
* jsr initialize_sprite_0,  then, every v/blank:
* jsr coord_sprite_0    restore 0   sprite 0
* read 'sprites' in shell.s to see what a parameter block is

restore	macro	\1
	move.l	#\1,d0
	move.l	back_screen,a0		default origin
	move.l	logical_screen,a1	default destination
	jsr	rest_sprite
	endm
* see above.  restore always comes before actual draw.
* see example in shell.s

on	macro	\1
	move.l	#\1,d0
	lsl.l	#5,d0		mult by 32
	lea	sprites,a6
	add.l	d0,a6		right sprite slot
	move.b	#1,29(a6)	turn it on		
	endm
off	macro	\1
	move.l	#\1,d0
	lsl.l	#5,d0		mult by 32
	lea	sprites,a6
	add.l	d0,a6		right sprite slot
	clr.b	29(a6)		turn it off
	endm
* ex: on 3	(turn fourth sprite on)
* ex: off 0     (turn first sprite off) (joystick sprite off)
*-----------------------
flash	macro	\2
	move.w	#\1,d7		loop: number of flashes
	sub.w	#1,d7
fl\@	not	$ff8240
	wait	\2		delay inside flash
	not	$ff8240
	wait	\2
	dbra	d7,fl\@
	endm
* ex: flash 2,5    2 flashes each lasting 5 vb's
* or  flash 1,10   1 longer flash
*     flash 0,0    will result in a bomb (nonsense)
*--------------------------------------------------
* with the next macros, origin AND destination to be specified in a0-a1
sprit	macro	\3
	move.l	#\1,d0
	move.l	\2,a0		origin
	move.l	\3,a1		destination
	jsr	draw_sprite
	endm
spritt	macro	\3
	move.l	\2,a0		sprite # expected in d0 (L)
	move.l	\3,a1		destination
	jsr	draw_sprite
	endm

restor	macro	\3
	move.l	#\1,d0
	move.l	\2,a0		origin
	move.l	\3,a1		destination
	jsr	rest_sprite
	endm
*
* ex: sprit 2,screen_2,image_pointer
* means sprite 2  will be pulled from screen_2, and drawn
* not on logical_screen as usual, but on image_pointer
* or anywhere in memory.
* sprite parameters are still found in the usual place (in sprites array)

* ex: restor 2,buffer_screen,image_pointer
* this is still under development
*-----------------------------------------
* Another set still under development is back,save,draw
* these are fairly slow, but easy and logical ways of displaying sprites:
* first way for vsync, then back, then save, then draw
* sprites are once again defined in the usual array
* in this case, because background is SAVED as found, rather than
* replaced as assumed, a buffer is required for storing it.
* see example in shell.s
draw	macro	\3
	move.l	#\1,d0
	move.l	\2,a0		origin
	move.l	\3,a1		destination
	jsr	draw_sprite
	endm
save	macro	\3
	move.l	#\1,d0
	move.l	\2,a0		origin
	move.l	#\3,a1		destination a definite buffer
	jsr	save_sprite
	endm
back	macro	\2
	move.l	#\1,d0
	move.l	#\2,a0		origin (a buffer)
	jsr	back_sprite
	endm
*------------------------
blank	macro	\1,\2,\3,\4\,5	blank part of current screen
	move.l	\1,a1		destination screen
	move.l	#\2,d0		color	0 to 15 
	move.w	#\3,d1		screen	 0 to 32000
	move.w	#\4,d2		height	 1 to 200
	move.w	#\5,d3		width	 16 to 320 (in 16's)
	jsr	blanken
	endm
* ex	blank $44e,12,16000,50,320
* a block 50*320 will be drawn at location 16000, in color 12
* color 0-15/location 0-32000 (mult of 8)/height 1-200/width 16-320 (16's)
*-----------------
* next one very similar to take except that the block being drawn
* is fully ored with the background.
* It is therefore slower, but blends better
* another difference is the use of chunks to indicate the width
* (1 chunk = 16 pixels) this is to be compatible with Lawson's ideas
block	macro	\1,\2,\3,\4,\5,\6
	move.l	\1,a0		origin screen
	move.l	\2,a1		dest screen	
	add.l	#\3,a0		precise location (16 boundary)
	add.lw	#\4,a1		precise location (16 boundary)
	move.w	#\5,d6		chunks (1 to 20)
	move.w	#\6,d7		height (1 to 200 usually)
	jsr	or_block	fully ored with destination
	endm
* ex: block screen_1,$44e,16080,960,3,11
* from screen_1 to current, a block 3 chunks wide, 11 lines deep
* arguments 3 and 4 must be multiples of 8 (16 boundary)
*----------------------------------
blockk	macro	\1,\2,\3,\4,\5,\6
	move.l	\1,a0		origin screen
	move.l	\2,a1		dest screen	
	add.l	\3,a0		precise location (16 boundary)
	add.l	\4,a1		precise location (16 boundary)
	move.w	\5,d6		chunks (1 to 20)
	move.w	\6,d7		height (1 to 200 usually)
	jsr	or_block	fully ored with destination
	endm
* same as previous, except that registers are expected
* ex: blockk screen_1,$44e,d0,d1,d2,d3
* again arguments 3 and 4 must be multiples of 8 
*-------------------
* next one will plot a pixel anywhere, in any color
* takes 1 h/b to execute. Use sparringly.
pixelplot	macro	\1,\2,\3,\4
	move.l	\1,a0		the screen required
	move.w	#\2,d0		x position (horizontal) 0-320
	move.w	#\3,d1		y position (vertical) 0-200
	move.w	#\4,d2		color (0-15)
	jsr	piplot	
	endm
* ex	pixelplot $44e,7,100,1  current screen,x pos 7,y line 100,color 1
*-----------------------
pixelplott	macro	\1,\2,\3,\4
	move.l	\1,a0		the screen required
	move.w	\2,d0		x position (horizontal) 0-320
	move.w	\3,d1		y position (vertical) 0-200
	move.w	\4,d2		color (0-15)
	jsr	piplot		
	endm
* last letter 't' is repeated. Therefore this macro reads
* registers rather than immediate values.
* the registers are not fool-checked. Therefore, attention must
* be paid not to put 350 for instance in argument 2 or a negative value...
* ex	pixelplott $44e,d5,d6,d2  current screen,x pos,y pos,color
*------------------------------------------------------------
* next one is ideal with collision detections
* takes about 1 h/b to execute, ie fast enough, but not to be abused
pixelread	macro	\1,\2,\3
	move.l	\1,a0		the screen required
	move.w	#\2,d0		x position (horizontal) 0-320
	move.w	#\3,d1		y position (vertical) 0-200
	jsr	piread		
	endm
* ex	pixelread $44e,7,100  	current screen, horiz 7, vert 100
*	answer will be returned in d2 (w: 0-15)
*----------------------
pixelreadd	macro	\1,\2,\3
	move.l	\1,a0		the screen required
	move.w	\2,d0		x position (horizontal) 0-320
	move.w	\3,d1		y position (vertical) 0-200
	jsr	piread		
	endm
* ex	pixelreadd $44e,d5,d6  	current screen, x,y
*	answer will be returned in d2 (w: 0-15)
*-------------------------
startup	macro
	movea.l	a7,a5		save stack pointer
	move.l 	#stack,a7	set up local stack
	movea.l	4(a5),a5	standard start up procedure
	move.l	12(a5),d0	
	add.l	20(a5),d0	
	add.l	28(a5),d0	
	addi.l	#256,d0		
	move.l	d0,-(a7)	
 	move.l	a5,-(a7)	
	clr.w	-(a7)		
	move.l	d0,proglength	
	move.w	#$4a,-(a7)
	trap	#1		
	lea	12(a7),a7
	endm
* used at the very begining of a program
* (give back to gem all unwanted memory)
*---------------------------------------
cursor  macro	\1
	move.w	#\1,-(a7)	0=off  1=on  2=flash  3=steady
	move.w	#21,-(a7)
	trap	#14
	addq.l	#4,a7
	endm
* ex: cursor 0     cursor off
*-----------------------------------
* this one clears a particular screen (very quickly!)
* all registers smashed! Save if necessary.
clear	macro	\1
	move.l	\1,a0
	add.l	#$7d00,a0		; end of screen
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,a1
	move.l	a1,a2
	move.l	a2,a3
	move.l	a3,a4
	move.l	a4,a5
	move.l	a5,a6
	moveq.w	#15-1,d7		loop			
clr\@	movem.l	d0-d6/a1-a6,-(a0)	each line clears 52 bytes	
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)	
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)	
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)	
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	dbf	d7,clr\@		41*52*15=31980
	movem.l	d0-d4,-(a0)		add 20=32000
	endm
* ex: clear screen_0   or clear $44E
*-----------------------------------
* this one clears current screen only
* (but not as quickly)
* to clear current screen QUICKLY, type clear $44e
cls	macro	
	movem.l	d0-d1/a0,-(sp)
	move.l	$44e,a0
	move.w	#8000/4-1,d0	
	moveq	#0,d1
erase\@	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbra	d0,erase\@
	movem.l	(sp)+,d0-d1/a0
	endm
* ex:   cls        (ie clear current screen)
*------------
delay	macro	\1
	move.w	#\1,d5
	jsr	delay
	endm
* ex:	delay 8	(waits about 1/2 sec)  previously known as 'wait'
*--------------------------
wait	macro	\1
	movem.l	d5-d6,-(sp)
	move.w	#\1,d6
loop\@	move.l	$466,d5
same\@	cmp.l	$466,d5
	beq	same\@
	dbra	d6,loop\@
	movem.l	(sp)+,d5-d6
	endm
* ex:	wait 50 (wait 1 second, if in 50hz)
*------------------------
jiffy	macro	\1
	move.l	d5,-(sp)
	move.w	#\1,d5
waitj\@	nop			waste 4 cycles
	nop
	nop
	nop
	nop
	dbra	d5,waitj\@	another 10 cycles
	move.l	(sp)+,d5
	endm
* ex:	jiffy 1000		(waits 1000*30 cycles) (1/5th of vb)
* ex	jiffy 10000		(waits 2 v/b) (1/25th sec)
* alternatively, vsync vsync would do the same
* to wait 1/50th sec, just use 'vsync' or 'wait 1'
*----------------------------
sound	macro	\1
	lea	\1,a0
	jsr	dosound
	endm
* ex	sound	snd8
* snd8	dc.b 0,1,0,4,0,8,etc..
*--------------------------
* will scroll a block on itself, x amount of times
scroll	macro	\1,\2,\3,\4
	move.w	#\1,d2		# of times
	move.w	#\2,d3		width         
	move.w	#\3,d4		bottom left pos + margin
	move.w	#\4,d5		the height
	jsr	scrol		
	endm
* ex:	scroll	64,64,10303,64
* see example in shell.s where the Budgie logo is scrolled  
*------------------
palette	macro	1
	move.l	d6,-(sp)
	lea	\1,a0
	move.l	#$ff8240,a1
	move.w	#15,d6		d6 will be corrupted
palt\@	move.w	(a0)+,(a1)+	
	dbra	d6,palt\@
 	move.l	(sp)+,d6
	endm
* will display a palette 
* ex:	palette palet
* or 	palette screen-32
* to save current palette: jsr save_pal
* palette will be stored in a buffer called 'palet'
*------------------
* next macro copies a 32k screen from one place to another
* for ultimate speed, use movem.l technique as described
* in 'clear' macro  or in  shell's  vertical scroll.
copyscreen	macro	1,2		;very useful one
	move.l	\1,a0
	move.l	\2,a1
	move.l	#8000/4-1,d0
csc\@	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,csc\@
	endm
* will copy one screen to another
* ex	copyscreen screen_0,screen_1
* or	copyscreen $44e,screen_1
* or	copyscreen $44e,a1	(use a0 as origin, a1 as dest)
* 
*----------------------------
copybytes	macro	1,2,3		
	move.l	\1,a0	
	move.l	\2,a1
	move.l	#\3,d0		this # precludes the use of registers
copyb\@	move.b	(a0)+,(a1)+	when calling ( must be an actual 
	dbra	d0,copyb\@	number like 32000..)
	endm
* ex:	copybytes spr_screen,$44e,16000  copies half a screen
* or	copybytes #palette,a4,34	from palette to wherever
* note use of # if actual address, but not if pointer (indirect)
*----------------------------
copywords	macro	1,2,3	
	move.l	\1,a0	
	move.l	\2,a1
	move.l	#\3,d0
copyw\@	move.w	(a0)+,(a1)+
	dbra	d0,copyw\@
	endm
*----------------------------
copylongs	macro	1,2,3		
	move.l	\1,a0	
	move.l	\2,a1
	move.l	#\3,d0
copyl\@	move.l	(a0)+,(a1)+
	dbra	d0,copyl\@
	endm
*---------------------
reserve	macro	1		ex: reserve 32100
	move.l	#\1,d0
	jsr	res_mem
	endm
* ex: reserve 32000   move.l d0,buffer_start   open file
*     read buffer_start,29000    close
* buffer_start dc.l 0
* file	       dc.b "jenny.pi1",0
*----------------
* with open, an error check should be made  tst.w d0   bmi exit
open	macro	1
	lea.l	\1,a0
	jsr	openfile
	endm
*-----------
create	macro	1
	lea.l	\1,a0
	jsr	f_create
	endm
*-----------
read	macro	1,2
	move.l	\1,a0
	move.l	#\2,d0
	jsr	readfile
	endm
* ex:	open jenny    tst.w d0    bmi exit
*	read #palete,34    read $44e,32000    close
* jenny  dc.b "jenny.pi1",0
* palete ds.w 17
* again note the use of # when appropriate
* next, same with bytes in a register 
readd	macro	1,2
	move.l	\1,a0
	move.l	\2,d0
	jsr	readfile
	endm
*------------------
write	macro	1,2
	move.l	\1,a0
	move.l	#\2,d0
	jsr	writefile
	endm
* ex:	create fred    write #palete,34    write physbase,24000    close
* fred	   dc.b "dump.pic",0
* palete   ds.w 17
* physbase dc.l 0
* more details & examples on Include #7, and Final Lap
* see how high scores are read and written in Final Lap
* nexT, same with bytes in a register 
writee	macro	1,2
	move.l	\1,a0
	move.l	\2,d0
	jsr	writefile
	endm
*------------
close	macro
	jsr	closefile
	endm
*------------	
bios	macro	\1,\2
	move.w	#\1,-(sp)
	trap	#13
	addq.l	#\2,sp
	endm
xbios	macro	\1,\2
	move.w	#\1,-(sp)
	trap	#14
	add.l	#\2,sp
	endm
gemdos	macro	Call number, stack reset
	pushi.w	\1
	trap	#1
	ifgt	\2-8
	lea	\2(sp),sp
	elseif
	addq.l	#\2,sp
	endc
	endm
*-----------
* the next macros are all related [Booker 1988]
String	macro	String to print.
	Cconwsi string\@
	BRA.S	dstring\@
string\@	DC.B	'\1',13,10,0
dstring\@ 	EVEN
	ENDM

pushi	MACRO	Immediate data.
	IFEQ	\1
	CLR.\0	-(SP)
	ELSEIF
	MOVE.\0	#\1,-(SP)
	ENDC
	ENDM

Cconwsi	MACRO	string addr
	PEA	\1
	gemdos	9,6 C_CONWS,6
	ENDM
*ex :   string <hello>  will print hello at current cursor position
*--------------
show_mouse macro
	dc.a	$a000		initialize
	movea.l	4(A0),A1	Crlin.
	CLR.W	2(A1)
	MOVE.W	#1,6(A1)
	movea.l	8(A0),A0	Ptsin.
	CLR.W	(A0)
	DC.W	$A009
	ENDM
hide_mouse macro
	dc.w	$a000
	movea.l	8(A0),A0
	CLR.W	(A0)
	DC.W	$A00A
	ENDM
make_mouse macro
	dc.w	$a000
	movea.l	8(A0),A0		Intin.
	LEA	6(A0),A0
	move.l	#1,(A0)+		Pen colour=1,mask colour=0.
	MOVEQ	#8-1,D0
	LEA	\1,A1
a\@	move.l	(A1)+,(A0)+
	move.l	(A1)+,(A0)+
	DBRA D0,a\@
	DC.W	$A00B
	ENDM
*------------
grabr	macro	\1,\2,\3,\4,\5,\6
	move.l	\1,a0		origin screen
	move.l	\2,a1		dest screen	
	move.l	d6,d0		origin  0 to 32000
	move.l	d7,d1		to screen	 0 to 32000
	sub.w	#1,d2		adjust height for loop ( 1 to 200) 11/89 
	jsr	fromtoo
	endm
* virtually same as grab, except that height & width are registers
* uses registers throughout
* ex:	grab spr_screen,current_screen,d6,d7,d2,d3
* move from sprite screen to current screen, an object at d6,
* to destination d7, size 60*48  (d6 & d7 are 0-32000)

*--------------
* for time speed only
* first install the hbl routine, see shell.s
* now calling before and after,   before and after a sprite is drawn,
* will reveal how many h/blanks have elapsed during that time
* (there are about 312 blanks at 50hz)
* if a screen is not completely redrawn within 312 h/b,
* a frame will missed.  Missing two frames will cause jerky sprites 
before	macro	\1
	move.w	#\1,d0		say 1
	lsl.w	#1,d0		double for word boundary
	lea	before,a0	array of several 'befores'
	add.w	d0,a0		add offset
	move.w	hbl_ct,(a0)	store h/b counter there
	endm
after	macro	\1
	move.w	#\1,d0		
	lsl.w	#1,d0	
	lea	after,a0	array of several 'afters'
	add.w	d0,a0	
	move.w	hbl_ct,(a0)	
	endm
* ex:   before 1   bsr do_something   after 1
* now these 2 'stopwatches' must be revealed in some way:
* put them in the k_star routine!
* now pressing '*' will reveal the time elapsed in horizontal scanlines
*-----------------
reveall	macro	\1\2\3\4
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	move.l	\1,d0
	move.l	#10,d1		decimal (hex is 16, binary is 2)
	jsr	printn
	move.l	(sp)+,\4
	move.l	(sp)+,\3
	move.l	(sp)+,\2
	printatt \2,\3,\4,#num_buff+14
	endm
* ex: reveall my_score,2,0,12
* will print on screen, in decimal, a L word held in my_score
* in color 2, row 0, line 12
* reveall stands for reveal long
*-----------------
reveal	macro	\1
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d0		clean entry
	move.w	\1,d0		WORD on this occasion
	move.l	#10,d1		decimal 
	jsr	printn
	printat	15,0,0,#num_buff+14
	movem.l	(sp)+,d0-d7/a0-a6
	endm
* ex: reveal d3   or  reveal score    or reveal $44e
* will print on screen, in decimal, a word 
* at position 0,0 in ink 15
*--------------------------
getjoy	macro
	clr.b	joyport1
joy\@	move.b	joyport1,d7
	tst.b	d7	
	beq 	joy\@
	endm
* waits for joystick to be moved & reports result in D7
* does for joystick what 'getkey' does for keyboard
* ex: joystick   btst #7,d7    beq fire
* if bit 7 in d7 is set: fire has been pressed
* other bits: 0 up   1 down   2 left   3 right
* save D7 before calling if necessary
* joystick routine to be set up once with jsr initjoy
*----------------------------------------------------
joystick macro
	move.b	joyport1,d7
	clr.b	joyport1	avoid repetition
	endm
* merely peeks joystick at a given time
* similar to 'rawconio' on the keyboard
* reads information in D7, then moves on
* note: auto repeat on fire button is off with this macro
* to keep it on, don't use this macro, use: btst #7,joyport1  bne fire
*---------------------
* acia reads the keyboard acia. Useful when k/b interrupt disabled
* acia returns k/b mouse and joystick bytes
* this routine is therefore a bit erratic.
* Best not touch the mouse
acia	macro	\1
	move.b	\1,d7
bh\@	cmp.b	$fffc02,d7	read acia direct
	bne	bh\@		
	endm
* ex: acia 57    (wait for space to be hit)
*-------------------------------------------
key	macro
	move.l	d7,-(sp)
	move.b	$fffc02,d7
k\@	cmp.b	$fffc02,d7
	beq	k\@
	move.l	(sp)+,d7
	endm
* ex: key
* this macro is used for debugging
* interrupts program anywhere without affecting a single register
* program will resume if keyboard or joy/ mouse touched
*------------
silence	macro
	movem.l	d0/a0,-(sp)
	lea	$ff8800,a0
	move.b	#0,d0
lp\@	move.b	d0,(a0)
	move.b	#255,2(a0)
	add.b	#1,d0
	cmp.b	#16,d0
	bmi	lp\@
	movem.l	(sp)+,d0/a0
	endm
* ex: silence      (after some sound effect that must not linger on)
*------------
	even
	