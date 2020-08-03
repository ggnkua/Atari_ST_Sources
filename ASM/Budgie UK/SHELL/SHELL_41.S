**   Nov 25 1989  **** Budgie UK  Shell 41
*------------------------------------------**
* compiles to 65K
* This is the backbone of many Budgie UK games.
* Two screens are toggled to display the physical picture.
* Sprites are drawn is several different ways.
* See debate regarding the merit of each in a separate file.
* In all cases, several degas screens are held in memory.
* It is from these screens that the backdrops and sprites
* are pulled to create the picture that is actually viewed.
* The Shell and include files are updted SEVERAL times a month
* write for latest update.

* If you want to modify this game shell, the most obvious place
* to start is with the Degas pictures.
* Try changing the title page, then the background picture,
* then substitute your sprites for our sprites. On a dot for dot basis.
* Future versions of the shell.s will include collision detect
* based both on x-y coordinates and pixel read

* Then try changing the sprite coordinate updates, etc..

* Shell updates can be obtained from Budgie UK, free of charge.
* Send disk and stamp to Budgie UK, Rayleigh
* The shell is updated 10 to 20 times a year.
* Your routines and macros welcome!

* Source code to Operation Angelica and Sea King available: 
* send œ3.95 to Budgie UK

sl	equ	$ff8800		sound chip
sd	equ	sl+2
red	equ	$700
green	equ	$070
blue	equ	$007
white	equ	$777
black	equ	$000
yellow	equ	$770
grey	equ	$444

	bra	start
	include "a:\includes\macros.s"

start	startup			memory management
	jsr	superin		supervisor mode is essential

* find default physbase (ie ramtop minus 32000)
* usually $78000 or $f8000
	jsr	phys_base	get physbase
	move.l	d0,physbase	used by exit routine
	divu	#1280,d0	make start of heap...
	mulu	#1280,d0	divisible by both 160 and 256
	add.l	#1280,d0	remove this line if too close to rom
	move.l	d0,screen_0	the one nearest to ROM.
	move.l	d0,$45e		initial screen IMPORTANT
	sub.l	#27*1280,d0	boundary is ok
	move.l	d0,screen_1	we'll toggle between 0 and 1
* these two screens (screen_0 and screen_1) are the screens
* that the viewer will actually see. They are also referred to
* as logical_screen and physical_screen. One v/blank, screen_0
* will be shown, the next, screen_1 will be shown.
* They are right at the top of free memory.
* The program on the other hand, is right at the bottom.
* The free space in the middle is called the heap.
* It is used for storing all those sprites, backdrops,
* music, fonts and workscreens.

* this section merely cleans up memory, so that we may inspect it
* later on, using the cursor keys (debugging only)
	clear	screen_0
	show	screen_0
	reserve	160		one way of finding start of heap
	move.l	d0,a0
	move.l	screen_0,a1
	move.l	#0,d1
.lp	move.l	d1,(a0)+	fill it up with noughts
	cmp.l	a0,a1
	bgt	.lp
	
	mfree	d0		no longer needed		

* we now reserve memory from the vacant area above the program itself
* (ie the heap)  in this case it is for 6 screens of sprites, etc
	move.l 	#1288*160,-(sp)   (6 screens + spare space)  
	move.w 	#$48,-(sp)	
	trap 	#1		malloc 
	addq.l 	#6,a7
	tst.l	d0		error
	bne	mallok
.error	string	<error reserve screens>
	wait	200

* start address of block returned in d0
mallok	
	divu	#1280,d0	make start of heap...
	mulu	#1280,d0	divisible by both...
	add.l	#1280,d0	160 and 256 

* now divide it up (all screens on a 1280 boundary...)
	move.l	d0,utility_screen messages, high scores, etc..
	add.l	#33280,d0	33280 is divis. by 1280
	move.l	d0,spr_screen	sprites  (pi1) or pic
	add.l	#33280,d0
	move.l	d0,back_screen	background (pi1)
	add.l	#33280,d0
	move.l	d0,screen_3	more bits and pieces (pi1)		
	add.l	#33280,d0
	move.l	d0,buffer_screen  mainly work screen for buffers etc..
	add.l	#33280,d0
	move.l	d0,lady_screen	bonus screen (pi1)
	
* now initialize A-line and fonts
	dc.w	$a000		initialize A-line
	move.l	a0,a_line_start
	move.l	(a1)+,d0	6*6 font
	move.l	(a1)+,fontaddress_8
	move.l	(a1),fontaddress_16
	dc.w	$a000
	hide_mouse
	btst	#7,$fffa01	mfp monochrome detect
	beq	no_curs		if on skip

	mode 	0		low res
no_curs	cursor	0

	bclr 	#0,$484		no keyclick
	bclr 	#1,$484		no repeat key

	move.l	#dtaddress,-(sp)	address of 44-byte DTA buffer
	move.w	#$1a,-(sp)	        set DTA address
	trap	#1
	addq.l	#6,sp

	move.w	#-1,-(sp)	read current k/b status	
	move.w	#-1,-(sp)	ie repeat rate, etc..
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	d0,d1		and store it away:
	move.w	d0,d2		we'll modify it when key scrolling...
	lsr	#8,d1		...is needed
	and.w	#%0000000011111111,d1
	and.w	#%0000000011111111,d2
	move.w	d1,k_delay	normally 15
	move.w	d2,k_repeat	normally 2

*  At this point, VB and HB routines
*  have not been set up.
*   Exit must be by calling QUITS.   

* now load our own fonts
	load	a1_font,a1_ptr		font 16 pixels
	load	a2_font,a2_ptr		font  8 pixels

* now a horizontal blank routine: to count each h/line!
* only used for debugging. Counter reset to zero each v/blank
* As long as counter doesn't go above 300, we're within one frame
* This h/blank routine itself takes about 20 lines to execute
* Must be removed when all debugging and testing done.
* It can be toggled on/off by pressing J
* All graphic operations to be calculated, erased, and drawn
* within ONE frame ie 1/50th of a sec, or approx 300 h/lines
* by putting a breakpoint before and after the vsync routine,
* we know exactly how many h/lines have passed to draw all
* the sprites. Just press *, and read value in 'after'
	move.l	#hbl_r2,a0		address of my routine
	bsr	set_horizontal_blank  	skip for now
	bset	#0,h_blank		useful for exit routine.

* now we reset the bombs vectors
	lea	on_error,a0
	move.l	a0,$000008	change error vectors...
	move.l	a0,$00000C	..with our own routine
	move.l	a0,$000010	no more bombs: just a post-mortem

* now install the various v/blank routines if any
 	lea 	music,a5	address of routine
	bsr	enable_vbi	plays a tune providing flag is ok

* next routine security only
	move.l	#check1+22,a0		on file called 'games.s'
	cmp.b	#"B",(a0)		is Budgie still there?
	bne	kwit
	move.l	#check2+10,a0		Budgie interference checks
	cmp.b	#"B",(a0)
	bne	kwit

* this routine checks for virus on boot sector
	jsr	read_sector		read boot sector
	lea	read_buffer,a0		this buffer is 512 bytes long
	clr.l	d0
	move.b	180(a0),d0		virus check
	cmp.b	#"S",d0			S for viruS
	bne	virus			not there? Something's wrong
	bra	passed_test		
virus	home	
	ink	15 	
	string	< VIRUS..?!>
	string	<Q to Quit R Repair>
	getkey
	cmp.b	#$10,d0			Q
	beq	kwit
	cmp.b	#$13,d0			R
	beq	repair
passed_test

*~~~~~~~~~~~~~~~~~~~~~~~~~INTRO~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* now the game proper. First an opening sequence (title screen etc..)
* and some variable initialization
intro1	cls				clear current screen

;;;	jsr	compact		this line only if a degas file needs compacting

	bsr	opening_sequence	load music, sprites etc..

	jsr	initialize_sprites	define their sizes etc...

intro2	bsr	initjoy 		setjoystick

* we come here at the beginning of a game and usually after a level
intro3	nop				do not remove	
	move.b	#%01100000,joystick	my ship (joystick) w 5.3.89
* the above flag is a status flag for sprites (BYTE only)
* this byte is updated when joystick is activated
* the eight bits (7-6-5-4-3-2-1-0) are as follows:
* fire,request,moving,vacant,right,left,down,up

intro4	cls				clear current screen	
	bsr	clearbuf		this line not essential
	bsr	initjoy			needed after a f1 call!
	border	$0			black border
	clr.w	clock_timer		used by certain games...
	move.w	#99,time		store clock start time


	palette	palet			show palette

	vsync				very first time (27/3/89)
	move.l	screen_0,logical_screen
	move.l	screen_1,physical_screen
	bset	#0,video		0/1 from now on, each v/b
	clear	screen_0
	clear	screen_1

* now, in case we want to scroll a long image: a place to start from
* say spr_screen, or wherever  (in practice, we would store our
* long image, just AFTER the last reserved bank, in a place called
* the free heap (see memory map to see where the heap is)
* the long image mustn't be too long, else it catches up with
* logical and physical screens at the top end of the heap.
	move.l	spr_screen,image_start
	move.w	#200,scroll_index
	move.w	#1,scroll_direction
	move.w	#1,scroll_stepper

* copy background onto log and phys
	copyscreen	back_screen,screen_0
	copyscreen	back_screen,screen_1
	vsync
	 
*~~~~~~~                   MAIN LOOP            ~~~~~~~~~~~~~~~

* this is the main prog: it reads the joystick
* then the keyboard, then waits for the vbi,
* when the vbi sync arrives, we have 1/50th sec to do
* everything (one frame). Take any longer, and you have jerky graphics
* By everything, we mean update & draw all automatic sprites,
* draw joystick sprite, update clock, scores and various checks
* and then we come back right HERE
		
main	
	clr.l	d0
	btst	#7,joystick	has my ship collided
	beq	main1		if 0 he is free from trouble
	wait	200		else, freeze him for 4 seconds
	clr.l	d0
	bclr	#7,joystick	de-freeze our ship
	border	0		black
main1	
	lea	sprites,a6	start of sprites array
	tst.b	29(a6)		29th byte: joysprite active?
	beq	raw		no: no need to update coordinates
	clr.b	joystick	dec 8 1989
	move.b	joyport1(pc),d7	read joystick
	tst.b	d7		any message?
	beq 	raw		no bit activated
	bsr	bittest		a bit is activated.  Which one?	

raw	bsr	random		cut out if not needed (to save time)
	move.l	d0,rnd1		save that random number
	move.l	d0,rnd2

* having read the joystick, we now read the keyboard
raw1	clr.l	d0
	bsr	rawconio   	go read the keyboard
	swap	d0		get scan code rather than ascii

* determine if a key has been hit, and act accordingly
raw2	cmp.b	#$01,d0  	ESC quit
	beq	kwit
	cmp.b 	#$3B,d0		F1 restart
	beq 	k_f1
	cmp.b 	#$3C,d0		F2 credits
	beq 	k_f2
	cmp.b 	#$3D,d0		F3 hints
	beq 	k_f3
	cmp.b 	#$3E,d0		F4 budgie list
	beq 	k_f4
	cmp.b 	#$3f,d0		F5
	beq 	k_f5
	cmp.b 	#$40,d0		F6
	beq 	k_f6
	cmp.b 	#$41,d0		F7
	beq 	k_f7
	cmp.b 	#$42,d0		F8 call message writer.prg
	beq 	k_f8
	cmp.b 	#$43,d0		F9 reset hi-score
	beq 	k_f9
	cmp.b	#$44,d0 	F10 Options
	beq	k_f10
	cmp.b	#$23,d0		H Hertz
	beq	k_h
	cmp.b	#$2C,d0 	Z 
	beq	k_z
	cmp.b	#$2d,d0		X clear screen
	beq	k_x
	cmp.b	#$2e,d0		C single cycle
	beq	k_c
	cmp.b	#$2f,d0		V scroll flag
	beq	k_v
	cmp.b	#$52,d0		INSERT
	beq	k_insert
	cmp.b	#$70,d0		pad 0 (joystick sprite)
	beq	k_pad0
	cmp.b	#$6d,d0		pad 1 other sprites
	beq	k_pad1
	cmp.b	#$6e,d0		pad 2
	beq	k_pad2
	cmp.b	#$6f,d0		pad 3
	beq	k_pad3
	cmp.b	#$6a,d0		pad 4
	beq	k_pad4
	cmp.b	#$6b,d0		pad 5
	beq	k_pad5
	cmp.b	#$6c,d0		pad 6
	beq	k_pad0
	cmp.b	#$72,d0		enter (load help file)
	beq	k_enter
	cmp.b	#$32,d0		M (music toggle)
	beq	k_m
	cmp.b 	#$20,d0 	Dump screen
	beq 	k_d
	cmp.b 	#$19,d0 	Pause
	beq 	k_p
	cmp.b 	#$21,d0 	F Font
	beq 	k_f
	cmp.b 	#$22,d0 	G reset
	beq 	k_g
	cmp.b	#$24,d0		J	toggle H/blank
	beq	k_j
	cmp.b	#$26,d0		Load (pi1)
	beq	k_l
	cmp.b	#$62,d0		Help
	beq	k_help
	cmp.b 	#$39,d0 	space (sound)	
	beq 	k_space
	cmp.b 	#$12,d0 	E
	beq 	k_e 
	cmp.b	#$48,d0 	UP (h/w scroll)
	beq	k_up
	cmp.b	#$50,d0 	DOWN 
	beq	k_down
	cmp.b 	#$2,d0 		1 show various screens in memory
	beq 	k_one
	cmp.b	#$3,d0		2	
	beq	k_two
	cmp.b	#$4,d0 		3	
	beq	k_three
	cmp.b	#$5,d0 		4	
	beq	k_four
	cmp.b	#$6,d0		5	
	beq	k_five
	cmp.b	#$7,d0 		6	
	beq	k_six
	cmp.b	#$66,d0		* debugging
	beq	k_star
	cmp.b	#$4b,d0 	left cursor	
	beq	k_left
	cmp.b	#$4d,d0		right cursor
	beq	k_right
	
	btst	#0,pause		if pause is on skip everything
	bne	main

* video swap: this is the point where we toggle screens
* they will actually be toggled in a split second, when the
* vertical blank arrives. At that point, the main v/b routine
* will ask video shifter to draw the new screen, and by doing so,
* reveal the sprites that were drawn 1/50th sec ago.
	jsr	toggle_screens
	move.l	logical_screen,work_screen
	move.l	physical_screen,current_screen
	move.l	physical_screen,$44e
	bchg	#0,video		change flag

	after	0	the h/b raster right now (below 300 hopefully)

* Now we wait for the vertical blank.	
* this is the START of a frame. We've got to be back here within 1/50 sec!!!
	vsync		<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

	clr.w	hbl_ct		reset h/b counter
	before	0			these lines here: debugging only
	clr.w	bill
	add.w	#1,clock_timer		needed by another routine

* now we update all automatic sprites coordinates
* the only sprite NOT updated here is the joystick one (sprite zero)
* which is updated as soon as joystick has moved. See bittest.
	bsr	coord_sprite_1	update  x coordinate
	bsr	coord_sprite_2	and next one
	bsr	coord_sprite_3

* next section to do with scrolling
	jsr	soft_scroll
* next section to do with time
	bsr	time_update 		or altitude, speed, whatever..	
	tst.w	time			end of game?
	bmi	end_of_level
	btst	#0,game_over
	bne	end_of_game

* now we restore all the old backgrounds if appropriate
* only sprites that are active are 'restored'
* there are TWO kinds of sprites: some store background in a BUFFER
* and retrieve it later. Others, restore a KNOWN scenery.
* First, if scenery scrolls, we never restore anything (no point)
	btst	#0,scroll_flag		scrolling background?
	bne	norest
* here is the standard type of sprite. It follows this pattern:
* vsync - back - save - draw -
* it means wait for vsync, change coordinates if necessary, then
* restore any BACKground from buffer,
* SAVE the background we're about to erase,
* and finally DRAW a sprite on screen.
* Here is an example:
	back	5,buffer_5	(only sprites 5 and 6 OK at the moment)

* Now comes another type of sprite. It follows this pattern:
* restore - sprite   meaning RESTORE a KNOWN scenery onto screen,
* then draw that particular SPRITE.
* There is no need to save anything in a buffer as we KNOW
* what the scenery is (usually a degas.pi1 sleeping in the background)
* this system is ok with static, unchanging scenery.
* here are some examples:
	restore	0		restore background (joysprite)
	restore	1		restore background
	restore	2
	restore	3

* this is the point where the screen is temporarily spriteless
* any check to see whether we are passing over a certain background
* is done here, courtesy of pixelread routine
	jsr	readthepixel	answer returned in d2 (0-15)

* next section is a pixel plot. No relevant to the sprite cycle.skip.	
norest	
	btst	#0,dot		need leave a trace?
	beq	nodot		no
	lea	sprites,a6
	move.w	12(a6),d5	x
	move.w	14(a6),d6	y
	add.w	#16,d5
	add.w	#18,d6
	move.w	#15,d2		ink
	pixelplott	logical_screen,d5,d6,d2
	bclr	#0,dot		reset
nodot	
* now at last, we draw that lot.
* First the sprites where no background was saved in the first place,
* ie the ones with KNOWN backgrounds  (ex background.pi1)
* the sprites themselves are held in a degas.pi1 picture somewhere
* in memory. That picture is usually called 'sprites.pi1'
* It is held in a memory screen called 'spr_screen'
* It is a straight matter of copying the sprites from the 
* spr_screen onto logical_screen.
	sprite	0		joystick sprite
	sprite	1		next sprite in the array
	sprite	2		and so on
	sprite	3
* next follows a variation. The sprite data is not held in
* 'spr_screen' as expected, but somewhere else.
* The destination screen may also be specified.
;	sprit	4,lady_screen,logical_screen   	example only
* Now, we will draw the other type of sprites: the ones with
* SAVEd backgrounds.
* First, prior to drawing, we have to SAVE the background in a buffer
* background 5 will go in buffer 5, 6 in 6, and so on
* make sure these buffers exists in the first place. See very END of prog
* here is the synthax:
	save	5,logical_screen,buffer_5	example only
* now that the background is safely tucked away in its buffer,
* we can at last DRAW that sprite.
* Again, we have to specify origin and destination, which will often
* be 'spr_screen' and 'logical_screen'
	draw	5,spr_screen,logical_screen	

* and that's it! All done. Time to rush home to catch the v/blank.

* follows some unimportant stuff
;	bindec	hbl_ct,10   	one way of revealing a variable
;	printat	6,6,6,a0	but slow!	example only
draw5
	btst	#0,single_step	
	beq	draw9
	bclr	#0,single_step
	jsr	getkey
	swap	d0
	cmp.b	#$2e,d0		C?
	bne	draw9
	bset	#0,single_step
draw9	
	bra	main		end of cycle. go back to start.
*------------------------------------------------------------------

* All done! From here onwards, we have all the subroutines:
* First, subroutines ending with 'bra main'
* These were called from the main 'read keyboard' section
* As we BRAnched to here, we will BRAnch back (no RTS)
* let's find out what is to be done when a key has been hit:

* SPACE reveals some of the sound effects library
* Use in conjunction with M (music)
* Press UP/DOWN key to activate key-repeat 
k_space	bclr	#0,single_step
	add.w	#$102,$ff8240		visual feed back
k_mm	clr.l	d7
	clr.l	d6
	clr.l	d5
	move.l	#snd_ctr,a0
*	add.w	#2,(a0)
	move.w	(a0),d7			0-2-4-6-8 etc..
	move.l	#soundoffset,a1
	add.w	d7,a1			push the pointer one notch
	move.w	(a1),d6			the length of that tune
	cmp.w	#98,d6			end?
	beq	k_m9
	move.l	#snd0,a0
	add.w	d6,a0
	move.l	a0,-(sp)
	bsr	dosound			and start playing there
	move.l	(sp)+,a0
	add.b	#1,1(a0)
	getkey
	swap	d0
	cmp.b	#$39,d0
	beq	k_space
	add.w	#2,snd_ctr
	bra	main
k_m9	move.w	#0,snd_ctr		reset counter
	move.w	#0,snd_inc
	bra	main
snd_inc dc.w	0
snd_ctr	dc.w	0
*----------------
* M toggles music on/off (vertical blank routine)
k_m	bchg	#0,musicon		toggle music 0/1
	silence
	bra	main
*---------
k_insert
	bra	main

*-------------------

* Pressing these keys on the key pad will toggle sprites on/off
* the 29th byte in a sprite parameter block determines on/off
k_pad0	lea	sprites,a6
	bchg	#0,29(a6)
	bra	main
k_pad1	lea	sprites,a6
	add.l	#32,a6			each block is 32 bytes long
	bchg	#0,29(a6)
	bra	main
k_pad2	lea	sprites,a6
	add.l	#64,a6
	bchg	#0,29(a6)
	bra	main
k_pad3	lea	sprites,a6
	add.l	#96,a6
	bchg	#0,29(a6)
	bra	main
k_pad4	lea	sprites,a6
	add.l	#128,a6
	bchg	#0,29(a6)
	bra	main
k_pad5	lea	sprites,a6
	add.l	#160,a6
	bchg	#0,29(a6)
	bra	main
k_pad6	lea	sprites,a6
	add.l	#192,a6
	bchg	#0,29(a6)
	bra	main

*------------------

* At this point, we CHAIN another PRG and pass control to it
chainer
	move.b	#0,musicon		turn music on
	move.l	#hbl_r2,a0	
	bsr	rst_horizontal_blank  	stop h/blank
	bclr	#0,h_blank
	move.l	$44e,save_screen	save current screen
	move.l	lady_screen,a0		point somewhere safe
	sub.l	#256,a0			
	move.l	a0,$45e
	vsync
	cls
	blank	$44e,8,0,28,320		draw 2 small bands at the top..
	blank	$44e,5,4480,24,320	.. for no particular reason

	move.l	#environment,-(sp)	needed by gem
	move.l	#environment,-(sp)
	move.l	chain_prog,-(sp)		m_writer.prg or whatever
	move.w	#0,-(sp)		chain this routine
	move.w	#$4b,-(sp)		execute it
	trap	#1		
	adda.l	#$10,sp

	show	save_screen		recall old screen
	move.l	#hbl_r2,a0		restore interrupt
	bsr	set_horizontal_blank  	
	bset	#0,h_blank

resume	mode	0			back to shell, in low res
	move.l	#palet,a0		retrieve our palette
	bsr	setpal
	bset 	#0,load_address
	move.l	#background,a0		reload some graphics as previous...
	move.l	utility_screen,a3	...prog corrupted them
	add.l 	#-34,a3		
	jsr	bload
	bclr	#0,load_address
	
	move.l	#8000-1,d0		copy them to ...
	move.l	utility_screen,a0
	move.l	screen_0,a1		... screen 0
	move.l	screen_1,a2		... and 1
.cop	move.l	(a0),(a1)+		copy all
	move.l	(a0)+,(a2)+	
	dbra	d0,.cop
	font	8
	move.b	#1,musicon		music off
	silence			clear sound chip
	bra	main

	even
lo0	ds.w	64	

environment
	dc.b	0,0,0,0,0,0 

writer	dc.b	"a:\common\writer.uk",0
scorer	dc.b	"a:\common\high.sco",0
	even
chain_prog	dc.l 0	holds address of ANY prog name above
*-----------

k_undo
	bsr	end_of_game
	bra	intro3
*---------------------

* J toggles the h/b routine on/off
* The h/b routine is used to count the raster position
* Pressing fire will actually reveal it.
* But it is very time consuming.
k_j	btst	#0,h_blank		toggle
	beq	k_jj
	move.l	#hbl_r2,a0		address of my h/b routine
	jsr	rst_horizontal_blank 
	bclr	#0,h_blank
	bra	main	
k_jj	move.l	#hbl_r2,a0		
	jsr	set_horizontal_blank 
	bset	#0,h_blank	
	bra	main
*-------------------

* H toggles between 50 and 60 H
* 60 hertz allows less time to redraw the sprites
k_h	bsr	vtsync	
	bchg	#0,hz		toggle	
	btst	#0,hz
	bne	k_h1
	move.b	#%11111110,$ff820a
	bra	main
k_h1	move.b	#%11111100,$ff820a
	bra	main
hz	dc.w	0
*----------------

* Pressing V will activate a scroll of 120 bytes wide (3/4 screen)
* To work within one frame, all but the smallest sprites must be
* deactivated. H/B interrupt also turned off.
* The scroll is nothing more than a window of the long image
* By pointing the window to a slightly different location (scroll_index)
* each v/b, the screen appears to scroll
* The variable image_start is used to define the top of that image
* The actual scroll routine is held in include file
* and will be executed during the main 'MAIN' loop
k_v	bchg	#0,scroll_flag		toggle scroll on/off
	btst	#0,scroll_flag
	beq	k_vv
	move.l	#hbl_r2,a0		de-activate h/b routine
	bsr	rst_horizontal_blank  
	bclr	#0,h_blank	
	off	1			turn off all sprites,...
	off	2			...except sprite 0
	off	3
	off	5
	bra	main
k_vv	move.l	#hbl_r2,a0	
	bsr	set_horizontal_blank  
	bset	#0,h_blank
	copyscreen	back_screen,physical_screen	
	copyscreen	back_screen,logical_screen	
	bra	main
*-------------------

* F1 usually restarts the game
* several games specific variables have to be reset
k_f1	clr.w	clock_timer
	move.w	#99,time
	move.w	#3,lives
	move.w	#0,score
	silence
	clear	utility_screen
	show	utility_screen
	home
	ink	11
	string  <the heroes so far>
	bsr	show_scores
	getkey
	bra	intro4		skip opening sequence (malloc)
*---------------------

k_f2	move.l	$44e,save_screen	
	show	utility_screen
	cls		
	print	the_credits
	getkey
	show	save_screen
	bra	main
*-------------------

k_f3	move.l	$44e,save_screen	
	show	utility_screen
	cls	
	font	8
	print	source
	getkey
	show	save_screen
	bra	main
*-------------------

k_f4	move.l	$44e,save_screen	
	show	utility_screen
	cls
	printat	7,0,0,#games
	getkey
	cls	
	printat 6,0,0,#games1
	getkey
	print	games2
	getkey
	print	games3
	getkey
	print	games4
	getkey
	print	games5
	getkey
	print	games6
	getkey
	print	games7
	getkey
	print	games8
	getkey
	print	games9
	getkey
	print	games10
	getkey
	print	games11
	getkey
	print	games12
	getkey
	print	games13
	getkey
	print	games14
	getkey
	print	games15
	getkey
	show	save_screen
	bra	main
*--------------------

k_f5	move.l	$44e,save_screen	
	show	utility_screen
	cls
	home
	print	desert_island	
	getkey
	cls
	font	16
	home
	print	desert1
	font	8
	getkey
	show	save_screen
	bra	main
*-------------------
	
k_f6	move.l	$44e,save_screen	
	show	utility_screen
	cls		
	printat 12,10,0,#mess_1
	getkey
	cls	
	printat 12,10,0,#mess_2
	getkey
	cls
	printat 12,6,0,#mess_3
	getkey
	show	save_screen
	bra	main
*-------------------
	
k_f7	lea	writer,a0		name of program
	move.l	a0,chain_prog		to chain
	bra	chainer			go and get it
	cls
	bra	main
*-------------------

k_f8	move.l	$44e,save_screen	
	show	utility_screen
	cls	
	printat 12,0,0,#rules_1
	getkey
	printat 11,0,0,#rules_1
	cls	
	show	save_screen
	bra	main
*-------------------

k_f9	move.l	$44e,save_screen	
	show	utility_screen
	cls	
	jsr	reset_high_scores
	show	save_screen
	bra	main
*-------------------

* F10 is used to display a list of options
k_f10
	font	16
	move.l	$44e,save_screen	remember screen we're on
	show	utility_screen
	cls
	print	options			print message to it
	getkey
	bsr	disap
	show	save_screen
	font	8
	bra	main
*-------------------

* Z will chain another program (in this case pople's message writer)
* and activate it	
k_z	
	lea	writer,a0		name of program
	move.l	a0,chain_prog		to chain
	bra	chainer			go and get it
	cls
	bra	main
*--------------------

* Pressing X clears current screen
k_x	cls
	bra	main
*-------------------
* Pressing C activates single_step execution (one v/b frame at a time)
* Ideal for debugging and following sprites progress
k_c	bset	#0,single_step
	bra	main
single_step dc.w 0
k_p	bchg	#0,pause
	bra	main
*-------------------

* Pressing L will activate the degas_load routine
* First a prompt will be displayed in utility_screen
k_l	move.l	$44e,a6			save target screen
	show	utility_screen
	cls
	font	8
	print	prompt			dc.b 27,"Y", etc needed!
	bsr	degas_load  		load Degas in a6
	bra	main
*-------------------

* This one loads a new 8*8 font from memory
* Their names are defined at the end of this program
k_f	bchg	#0,font_flag		toggle flag
	btst	#0,font_flag
	beq	kf1
	open	a2_font2		elega*.fon
	bmi	kf9			not found?
	bra	kf2
kf1	open	a2_font			squa*.fon
	bmi	kf9
kf2	read	a2_ptr,2066		read 2066 bytes
	close
kf9	bra	main
font_flag dc.w 	0
*----------------
k_g	
	bra	main
	mode	1
	move.l	$0,(sp)	
	move.l	$4,a0
	jmp	(a0)		total reset


*-------------------
* Now we can dump current screen to disk, as a pi1 file
* It will be called 'apic.pi1'
* First, Pause program by pressing P, then choose screen with
* either 1,2,3,4,5,6 or use up/down to scroll through memory,
* then press D (dump)
k_d	move.l	$44e,save_screen this is a DUMP routine
	show	utility_screen
	cls
	home
	font	16
	ink	15
	string	<  DUMP SCREEN to disk>		
	string 	<are you sure?>
	font	8
	getkey
	swap 	d0
	cmp.b 	#$15,d0			Y/y
	bne 	k_d6
	bsr	picdump
k_d6	show	save_screen
	bra	main
message_4 dc.b "dump screen to disk. Are you sure?",0
	even
*------------

* This k_e is not fully implemented.
* It basically describes how a sprites may be QUICKLY put on screen
* with full background masking, but ONLY on a 16 boundary
k_e	before 	1 		13 h/b's only
	move.l	spr_screen,a0	this routine draws a sprite..
	add.l	#174*160-8,a0	..held in spr_screen ...
		
	move.l	logical_screen,a1	onto current screen..
	add.l	#86*160,a1	<86 lines down the screen +...	
	add.l	#144,a1		x coord MUST be a multiple of 8>
	move.l	#26,d7		..with full eoring.  D7 is height
.loop
	movem.l	(a0)+,d2/d3	get all 4 planes in one go
	move.l	d2,d0		combine...
	or.l	d3,d0		...the lot of them.
	move.w	d0,d1		convert result..
	swap	d0		into..
	or.w	d1,d0		..a mask
	not.w	d0		now invert it
	clr.l	d1		not essential?
	move.w	d0,d1		put mask in lower word of D1
	swap	d1		now it's in the high word
	move.w	d0,d1		now it's in both
	and.l	d1,(a1)		merge..
	or.l	d2,(a1)+	..all this lot...
	and.l	d1,(a1)		...with...
	or.l	d3,(a1)+	...the background on actual screen.
	add.w	#160-8,a0	do next line
	add.w	#160-8,a1	
	dbra	d7,.loop
	after	1		stopwatch (13 h/b's elapsed)	
	bra	main
* pressing * shows these various stopwatches
*--------------------

* Next will load a certain file from disk. See k_help for details
k_enter	move.w	#1,degas_file
	bra	k_help
	
* This routine will load a given file from disk (usually help.pi1)
* However, depending on state of 'degas_file' variable, the file
* chosen may vary. For instance, if 'degas_file' is set to 0,
* help_pic may be loaded.  If set to 1, penny_pic may be loaded
k_help	move.l	$44e,save_screen	save current screen
	clear	utility_screen
	show	utility_screen
	move.b	#0,musicon		switch music on

	tst.w	degas_file		1=seaking.pi1  0=budgie.pi1
	beq	kh1
	open	penny_pic
	bra	kh2
kh1	open	help_pic		load from disk
kh2	bmi	kwit			if error, quit
	read	#palet+34,34		store palette somewhere (#)
	palette	palet+36		and now show it
	move.l	utility_screen,a0
	read	a0,32000		read 32000 bytes (ie degas.pi1)
	close
	getkey
	show	save_screen		retrieve official screen
	palette	palet			retrieve official palette
	move.b	#1,musicon		music off
	silence			clear any lingering noise
	move.w	#0,degas_file		default is budgie.pi1
	bra 	main			and carry on
*-------------------

* The next few routines will merely show the main screens held
* in memory.   First, P (Pause) will have to be hit.
* Press P again, to resume normal program
k_one	show	screen_0
	bra	main
k_two	show	screen_1
	bra	main
k_three	show	back_screen
	bra	main
k_four	show	spr_screen
	bra	main
k_five	show	utility_screen
	bra	main
k_six	show	lady_screen
	bra	main	
k_seven	show	screen_3
	bra	main
*-------------------	

* This is vertical hardware scrolling (1280 bytes at a time)
* As there are 160 bytes per lines, this is equivalent to
* scrolling 8 lines, up or down.
* 1280 was chosen because it is divisible by 160 AND 256 !
* this routine also sets the auto-repeat key on
k_up	move.l	$44e,save_screen (preserve where we are)
k_up1
	move.w	#1,-(sp)	shorten  key delay to  make thhings
	move.w	#5,-(sp)	smoother
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp

	bset 	#1,$484			repeat key on
	move.l	$44e,a0			get current screen
	add.l 	incr,a0			raise it a bit (1280 bytes)
	move.l	a0,$45e			for update during next v/blank
	getkey
	swap	d0
	cmp.b	#$48,d0			more up viewing
	beq	k_up1
	cmp.b	#$50,d0			more down viewing
	beq	k_down1
	cmp.b	#$26,d0		load: danger: prog will not come back...
	beq	k_l		here (palette and other settings lost)
	cmp.b	#$2d,d0			clear
	beq	k_x
	cmp.b	#$20,d0			dump
	beq	k_d
	move.w	k_repeat,-(sp)	3
	move.w	k_delay,-(sp)	11
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	save_screen,$45e
	vsync
	bra	main

k_down	move.l	$44e,save_screen	needed
k_down1 move.w	#1,-(sp)		default values
	move.w	#5,-(sp)
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp

	move.b	#0,$a7c			another way of speeding k/b
	move.b	#0,$a7f
	bset 	#1,$484			repeat key on
	move.l 	$44e,a0
	sub.l 	incr,a0	
	move.l 	a0,$45e
	getkey
	swap	d0
	cmp.b	#$50,d0			more viewing
	beq	k_down1
	cmp.b	#$48,d0
	beq	k_up1
	cmp.b	#$26,d0			load
	beq	k_l
	cmp.b	#$2d,d0			clear
	beq	k_x
	cmp.b	#$20,d0			dump
	beq	k_d
	move.w	k_repeat,-(sp)	3
	move.w	k_delay,-(sp)	11
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	save_screen,$45e
	vsync				needed
	bra	main
k_left	bra	main
k_right	bra	main
*-------------------
* This routine is used for debugging.
* It reveals a lot of variables, either specific to this game,
* or systems variables, like physical screen, joystick status, etc..
* An important variable is hbl_ct (the horizontal raster position)
* Also: 'before' and 'after' used to time any given operation
k_star
	movem.l	d0-d7,-(sp)	freeze registers
	movem.l	d0-d7,-(sp)	and again
	move.l	$44e,save_screen save screen
	show	utility_screen
	cls
	printat 1,16,0,#null 	ink 1  line 16   col 0   
	movem.l (sp)+,d0-d7	reveal original regs
	bsr	reveal_regs 	all

	home
	ink	13	sand
	print	reveal_text
	home
	ink	11	red
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	lea	before,a0	stopwatches array
	move.w	(a0),d0
	move.w	2(a0),d2
	move.w	4(a0),d4
	lea	after,a0
	move.w	(a0),d1
	move.w	2(a0),d3
	move.w	4(a0),d5
	move.w	store,d6
	move.w	scroll_index,d7
	bsr	reveal_regs

	ink	15	grey
	printat 7,8,0,#null 	ink 1  line 16   col 0
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	move.w	level,d0		more selected variables..
	move.w	lives,d1		..to be revealed
	move.w	store,d2
	move.w	store,d3
	move.w	score,d4
	move.w	score,d5
	move.w	score,d6
	move.w	score,d7
	bsr	reveal_regs	
	move.l	storel,d0		now reveal current screen..
	move.l	#10,d1		..in hex (16)
	bsr	printn
	printat	11,16,30,#num_buff+14

	move.l	screen_1,d0	reveal original physbase..
	move.l	#16,d1	hex	..in hex
	bsr	printn
	printat	11,17,30,#num_buff+14

	move.l	back_screen,d0	sprites screen
	move.l	#16,d1
	bsr	printn
	printat	11,18,30,#num_buff+14

	move.l	logical_screen,d0
	move.l	#16,d1		hex
	bsr	printn
	printat	11,19,30,#num_buff+14

	move.l	physical_screen,d0	
	move.l	#16,d1		
	bsr	printn
	printat	11,20,30,#num_buff+14

	move.l	utility_screen,d0	
	move.l	#16,d1		
	bsr	printn
	printat	11,21,30,#num_buff+14

	move.b	joystick,d0	(joystick)
	ext.l	d0
	move.l	#2,d1		..in binary (2)
	bsr	printn
	printat	11,22,29,#num_buff+11

	move.l	rnd1,d0		
	move.l	#10,d1
	bsr	printn
	printat	11,23,30,#num_buff+14

	getkey
	move.l	save_screen,$45e
	vsync
	movem.l	(sp)+,d0-d7	final retrieve
	bra	main

reveal_text
	dc.b 27,"H"
	dc.b 27,"Y",32,38," : before 0 (stopwatch)",10,13 d0
	dc.b 27,"Y",33,38," : after 0",10,13 d1
	dc.b 27,"Y",34,38," : before 1",10,13 d2
	dc.b 27,"Y",35,38," : after 1",10,13 d3
	dc.b 27,"Y",36,38," : before 2",10,13 d4
	dc.b 27,"Y",37,38," : after 2",10,13 d5
	dc.b 27,"Y",38,38," : store (w).....",10,13 d6 
	dc.b 27,"Y",39,38," : scroll index..",10,13 d7

	dc.b 27,"Y",40,38," : level",10,13
	dc.b 27,"Y",41,38," : lives",10,13
	dc.b 27,"Y",42,38," : store",10,13
	dc.b 27,"Y",43,38," : store",10,13
	dc.b 27,"Y",44,38," : score",10,13
	dc.b 27,"Y",45,38," : total_score..",10,13
	dc.b 27,"Y",46,38," : detector music delay......",10,13
	dc.b 27,"Y",47,38," : total_rescued..........",10,13

	dc.b 27,"Y",48,37," D0       screen 0",10,13
	dc.b 27,"Y",49,37," D1       screen 1      ",10,13
	dc.b 27,"Y",50,37," D2       screen 2     ",10,13
	dc.b 27,"Y",51,37," D3       logical       ",10,13
	dc.b 27,"Y",52,37," D4       physical      ",10,13
	dc.b 27,"Y",53,37," D5       workscreen ",10,13
	dc.b 27,"Y",54,37," D6       joystick value",10,13
	dc.b 27,"Y",55,37," D7       random ",0
	even
*-----------
* The bomb trap vectors have been re-routed to come here,
* to reveal state of registers and important variables.
* Often, the program will continue, even after bombs!
* But the stack will be corrupted, and exit to desktop not permitted.
on_error
	bra	k_star
	home
	font	16
	string	<  FATAL ERROR! >
	string	<stack  corrupted>
	font	8
	getkey
	bra	kwit	main


*~~~~~~~~~~~~~~~~NOW REAL SUBROUTINES  (with RTS endings)~~~~~~

opening_sequence

* first we load the high scores, exactly inside the array
	bset 	#0,load_address		flag (load at precise location)
	move.l 	#file_6,a0		which file to load
	move.l 	#high_scores,a3		where in program to load it
	bsr	bload			do it
	bclr	#0,load_address		done

	show	screen_0		start somewhere
	font	8
	home
	ink	1
	string	<here we go!>		print 'here we go!'

* another way of loading a file. This time, a truncated degas pic
* (the Budgie logo) which we know is 6434 bytes long
* again, no need to reserve memory: we'll load direct into
* a pre-reserved screen, in this case: 'utility_screen' (workscreen)
	open	budgie_pic
	bmi	kwit
	read	#palet-2,2		palet-2 is the res variable		
	read	#palet,32		must be a # (actual location)
	clear	utility_screen
	move.l	utility_screen,a0
	add.l	#9600,a0		just under half way
	read 	a0,6400			actual data: 6400 bytes long
	close
	palette	palet			on the other hand, no # here
	show	utility_screen

* next thing to load is the Budgie girl (a full degas.pi1)
* we'll load here in a pre-reserved screen, called 'lady_screen'
	bset 	#0,load_address		flag: load direct at A3
	MOVE.L 	#penny_pic,a0		origin: penny.pi1 (on disk)
	MOVE.L 	lady_screen,a3		destination screen	
	sub.l 	#34,a3			deduct palette and res
	jsr	bload			direct load 
	bclr	#0,load_address		done

*	bra	skip_opening

	scroll 34,108,98*160+24,34  scroll BUDGIE logo
	scroll 34,108,15704,34
	scroll 34,108,15704,34
	scroll 34,108,15704,34
	scroll 32,108,15704,32
	scroll 30,108,15704,30
	scroll 28,108,15704,28
	scroll 26,108,15704,26
	scroll 24,108,15704,24
	scroll 22,108,15704,22
	scroll 20,108,15704,20
	scroll 18,108,15704,18
	scroll 16,108,15704,16
	scroll 14,108,15704,14
	scroll 12,108,15704,12
	scroll 10,108,15704,10
	scroll 10,108,15704,10
	scroll 8,108,15704,8
	scroll 8,108,15704,8
	scroll 6,108,15704,6
	scroll 6,108,15704,6
	scroll 6,108,15704,6
	rept	6
	scroll 4,108,15704,4	repeated 6 times
	endr
	rept	6
	scroll 2,108,15704,2	repeated 6 times
	endr

* now, we will show the Budgie girl, by asking lady_screen
* to come to the front
	move.l	lady_screen,a0
	add.l	#-32,a0
	bsr	setpal
	show	lady_screen
	clear	utility_screen

* we now load some digitized music for later use
* this time, we don't specify any precise location where to load to.
* gem will therefore reserve the necessary space for us,
* returning its start address in drum_ptr
* we are not using the 'jsr bload' as with the lady,
* or the 'open/read/close' sequence as with the logo,
* but instead the 'load' macro
	load	drum,drum_ptr		will be used later by ST replay

* now, we load yet another degas.pi1  This time, the title page
* As a precise location has already been reserved (back_screen),
* we use the 'jsr bload' subroutine with the flag set
	bset 	#0,load_address		flag set: precise load
	move.l 	#title_page,a0		name of file to load
	move.l 	back_screen,a3		where to load it	
	sub.l	#34,a3			deduct palette and res
	bsr	bload			direct load 
	bclr	#0,load_address		done

* here's another way we could have done it:
*	open	title_page
*	read	#palet-2,2
*	read	#palet,32		#  it's an actual location
*	read	back_screen,32000	no #, it's a pointer
*	close

* now we set the palette
	move.l	back_screen,a0		
	sub.l	#32,a0	
	bsr	setpal

* At this point, although loaded, the title page still isn't showing
* lady_screen is still showing.
* now a routine to gradually rebuild the title page in back_screen
* into 'utility_screen'
	move.l	#3000,d7
.sploop	move.l	back_screen,a0		back_screen to be ..
	bsr	specify1		..rebuilt in utility_screen
	dbra	d7,.sploop
	show	back_screen		now show all of it

* now, we'll play that digitised music until a key is hit
play_again
	replay	drum_ptr,32343,3	digitised music
	tst.b	keyhit			interrupted?
	beq	play_again
	silence
	cls	

* next is optional
	bsr	enter_your_name
	bsr	show_scores
	silence			cut out sound chip

skip_opening
	wait	50			1 sec  (leave it)

* more loading: this time, sprites, (compacted)
* the routine for compacting a degas picture is further up
* (jsr compact) see include2.s where the actual subroutine is.
* note: the next few lines EXPECT a file called 'sprites.pic'
* ie a compacted file. 
* if sprites.pi1 is not compacted, use the loading technique
* already described with title page
	show	lady_screen		dummy screen
	cls				clear it
	open	sprites1		file name (sprites.pic)
	bmi	kwit			error? if so, get out	
	read	utility_screen,34	read palette first, anywhere
	read	#reference_byte,1
	move.l	file_size,d0		get size
	sub.l	#35,d0			palette already in
	readd	utility_screen,d0	read rest of file
	close
	
	flash	3,1
	move.l	file_size,d7		known number of bytes
	sub.l	#35,d7			less header
	move.l	spr_screen,a1		destination to rebuild into
	jsr	decompact		do it

* more loading: this time background.
* the principle is exactly the same as with the title page
	
	bset 	#0,load_address
	move.l	#background,a0		name of file
	move.l	back_screen,a3		destination screen
	add.l 	#-34,a3			
	jsr	bload
	bclr	#0,load_address

	move.l	back_screen,a0		spr_screen determines the..
	sub.l	#32,a0			..official palette
	move.l	#palet,a1
	copywords a0,a1,16		store palette for later use	
	palette	palet			final, official palette

* some variables can be initialized here, if necessary...
	move.w	#99,time		60 to 0
	move.w	#0,clock_timer		0 to 50 (50 = 1 sec)
	move.w	#0,game_over
	move.w	#1,level
	rts
* end of opening sequence

*------------------------
* this one is called by 'main' each time joystick has moved
* joystick info in d7 is analysed
* where bit 7 is fire,   3,2,1,0 are right/left/down/up
bittest
	lea	sprites,a6
	add.l	#0,a6			add 32 byte offset if necessary
	and.b	#%10001111,d7 		only interested in 5 states	
	btst	#7,d7			was it the fire bit?
	beq	next1
	move.l	d7,-(sp)		save D7
	bsr	fireproc
	move.l	(sp)+,d7

next1	cmp.b	#128,d7			fire only? in which case...
	beq	next5			...just exit (no change of status)
	and.b	#%00001111,d7		fire not needed any more
	move.b	d7,joystick		preserve this record for drawing later

	btst	#0,d7			or was it up?
	beq	next2
	bsr	upcoord
*	bra	next5			to avoid diagonals only
next2	btst	#1,D7			and so on
	beq	next3
	bsr	downcoord
next3	btst	#2,D7
	beq	next4
	bsr	leftcoord
next4	btst	#3,D7
	beq	next5
	bsr	rightcoord
next5	bset	#6,joystick
	rts
*------------
* the following coordinates are updated
* whenever joystick is moved
upcoord 
	sub.w	#1,14(a6)		update y coordinate (1 pixel up)
	sub.l	#160,4(a6)		update absolute y position
	tst.w	14(a6)			top limit
	bgt	return			ok within limits
	add.w	#1,14(a6)		no, too high	
	add.l	#160,4(a6)
	bra return
downcoord 
	add.w	#1,14(a6)		update y coord (1 down)
	add.l	#160,4(a6)		absolute y position: 160 bytes down
	cmp.w	#180,14(a6)		bottom limit
	bmi	return
	sub.w	#1,14(a6)
	sub.l	#160,4(a6)
	bra	return
leftcoord
	sub.w	#1,12(a6)	update x coordinate (1 left) 
	cmp.w	#1,12(a6)	left limit
	bgt	return
	add.w	#1,12(a6)
	bra	return
rightcoord
 	add.w	#1,12(a6) 	update x coord
	cmp.w	#280,12(a6)	right limit
	bmi	return
	sub.w	#1,12(a6)
	bra	return
fireproc

;	bset	#0,dot		if set a dot will be drawn
	not	$ff8240		reverse border
;	wait	1		with this line on, we get a flash...
	not	$ff8240		...otherwise a line showing h/b raster
	sound	snd12
	move.b	#1,musicon	cut out music interrupt
return	rts
	
*------------
* next routine used in Operation Angelica, to detect background color
* in this example, we try to see whether sprite zero (BUDGIE) collides
* with any light blue background (like the word BLOB).
* We're only checking one spot, in this case the middle of BUDGIE sprite.
readthepixel
	lea	sprites,a6	address of Budgie sprite param block
	move.w	12(a6),d5	x
	move.w	14(a6),d6	y
	add.w	#24,d5		centralize test
	add.w	#4,d6
	and.l	#$ffff,d5	word only
	and.l	#$ffff,d6
	
	pixelreadd logical_screen,d5,d6 
	and.l	#%00001111,d2		max 15  (0-15)

;;	reveall	d2	;; debugging only  (color 0 to 15) try it
	
	cmp.w	#6,d2		color 6? (light blue)
	beq	rr5		if so, do a flash
	bra	rr9		if not, get out
rr5	move.w	#1000,d7	
.r11	border	$777		flash border
	dbra	d7,.r11
	move.w	#1000,d7
.r12	border	$0
	dbra	d7,.r12
	move.w	#1000,d7
.r13	border	$777
	dbra	d7,.r13
	border	$0
	bra	rr9
rr6	move.l	$44e,a0		
	add.l	incr,a0		shake screen
	move.l	a0,$45e
	vsync
	move.l	$44e,a0
	sub.l	incr,a0
	move.l	a0,$45e
	vsync
	bra	rr9
rr9	rts
*----------

* In this example, a sprite moves 1 or several pixels at a time
* sideways, left to right and then backwards
* each sprite has a parameter block of 8 long words (32 bytes)
* sprite_0  is the joystick sprite (with its own coordinates)
* sprite_1 onwards are self-propelling sprites (aliens etc..)
* collision detect is another routine, in its own right.
coord_sprite_1
	lea	sprites,a6	the very beginning of the block array
	add.l	#32,a6		offset (sprite 1)
	tst.b	29(a6)		29th byte determines on/off
	beq	.out
	tst.b	28(a6)		28th byte is direction: 0 right/ 1 left
	bne	.left
	add.w	#5,12(a6)	bytes 12-13  is the x coord
	cmp.w	#280,12(a6)	max right reached?
	bmi	.okr
	move.b	#1,28(a6)	reverse direction flag
.okr	rts
.left	sub.w	#5,12(a6)	move 5 pixels to the left on the x coord
	cmp.w	#7,12(a6)	reached pixel 7?
	bgt	.okl
	clr.b	28(a6)		reverse direction flag
.okl	
.out	rts
coord_sprite_2
	lea	sprites,a6	the very beginning of the block array
	add.l	#64,a6		offset (sprite 2)
	tst.b	29(a6)		29th byte determines on/off
	beq	.out
	tst.b	28(a6)		28th is direction: 0 right/ 1 left
	bne	.left
	add.w	#3,12(a6)	
	cmp.w	#280,12(a6)	max right
	bmi	.okr
	move.b	#1,28(a6)	reverse direction flag
.okr	rts
.left	sub.w	#2,12(a6)	move 2 pixels to the left
	cmp.w	#1,12(a6)
	bgt	.okl
	clr.b	28(a6)		reverse direction flag
.okl	
.out	rts

coord_sprite_3
	lea	sprites,a6	the very beginning of the block array
	add.l	#96,a6		add offset for sprite 3	
	tst.b	29(a6)		on/off
	beq	.out
	tst.b	28(a6)		test direction byte
	bne	.left
	add.w	#1,12(a6)	x coord
	cmp.w	#280,12(a6)	max right
	bmi	.okr
	move.b	#1,28(a6)	reverse direction flag
.okr	rts
.left	sub.w	#1,12(a6)	
	cmp.w	#1,12(a6)
	bgt	.okl
	clr.b	28(a6)		reverse direction flag
.okl	
.out	rts
*---------------------------
* Now we RESTORE all the backgrounds *
* restoration of backgound occurs each v/blank just BEFORE
* re-drawing the sprites.
rest_sprite
	lea	sprites,a6	start of sprite array
	lsl.l	#5,d0		multiply a given number by 32
	add.l	d0,a6		add it to array to get precise sprite
	tst.l	24(a6)		if this is zero: no restore needed
	bne	.rest
	rts			if zero, no restore wanted
.rest	
*	move.l	logical_screen,a1
	move.l	24(a6),d0	destination where to restore
	add.l	d0,a1
*	move.l	back_screen,a0
	add.l	d0,a0
	move.w	10(a6),d6	chunks
	lsl.w	#4,d6		* 16
	move.l	#160,d0
	sub.w	d6,d0		this is the offset

	move.w	8(a6),d7	height
	sub.w	#1,d7
.loop	move.w	10(a6),d6	chunks
	sub.w	#1,d6
.chunks	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d6,.chunks
	add.l	d0,a0
	add.l	d0,a1
	dbra	d7,.loop
	tst.b	29(a6)		sprite off by any chance?
	bne	.rest9		no
	move.l	20(a6),24(a6)	push next restore address for shadow screen
	clr.l	20(a6)		and stop any further restoring afterwards
.rest9	rts
*-------------
* sprites are drawn each v/blank whether they move or not,
* First restore, then save, then draw
* save & draw normally done in one pass, but not in this example.
* if sprite is disabled, routine aborts
* origin screen expected in a0 (say spr_screen)
* see DRAW macro
draw_sprite
	lea	sprites,a6	start of sprite parameter array
	lsl.l	#5,d0
	add.l	d0,a6
	tst.b	29(a6)		disabled?
	beq	spr_out
	move.l	20(a6),24(a6)
	move.l	0(a6),d4	origin
	move.l	4(a6),d5	y destination (say 100 * 160)
	move.w	8(a6),d7	height
	move.w	10(a6),d6	chunks
	move.w	12(a6),d1	x
	clr.l	d2		important
	move.w	d1,d2		x again	
	lsr.w	#1,d2		halve (1 pixel is 1/2 byte)
	and.w	#$fff8,d2	16 boundary  (say 49 becomes 48)
	add.l	d2,d5		(say 48+16000)
	move.l	d5,16(a6)	precise location in bytes
	move.l	d5,20(a6)	now, save it for later restore	
	and.l	#15,d1		precise x pixel (0-15)

	lsl.w	#3,d6		chunks * 8
	move.l	#160,d0
	sub.w	d6,d0		this is the offset
	move.l	d0,a4		say 152
	subq.l	#8,d0
	move.l	d0,a5		say 144
	bsr	asprite		inside include3
spr_out	rts

* this routine saves a background before drawing a sprite on it.
* origin (ie current screen itself) expected in a0
* destination (buffer like buffer_5) expected in a1 
* if sprite is inactive, routine aborts
* First L to go in buffer is start address of block to be saved
* see SAVE macro
save_sprite	
	btst	#0,video	either screen_0 or screen_1
	beq	.s
	add.l	#3200,a1	use buffer b instead
.s	lea	sprites,a6	start of sprite parameter array
	lsl.l	#5,d0
	add.l	d0,a6
	tst.b	29(a6)		active?
	beq	spr_out		if not, no need to save
	move.l	4(a6),d5	y destination (say 100 * 160)
	move.w	8(a6),d7	height
	move.w	10(a6),d6	chunks
	move.w	12(a6),d1	x
	clr.l	d2		important
	move.w	d1,d2		x again	
	lsr.w	#1,d2		halve (1 pixel is 1/2 byte)
	and.w	#$fff8,d2	16 boundary  (say 49 becomes 48)
	add.l	d2,d5		(say 48+16000)

	lsl.w	#3,d6		chunks * 8
	move.l	#136,d0
	sub.w	d6,d0		this is the offset
	move.l	d0,a5		say 152
	add.l	d5,a0		total address
	move.l	a0,(a1)+	store address first of all
	sub.w	#1,d7		height loop
.lp	move.w	10(a6),d6	chunks
	sub.w	#1,d6
.loop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
***	move.l	(a0)+,(a1)+
***	move.l	(a0)+,(a1)+
	dbra	d6,.loop
	add.l	a5,a0
	add.l	#8,a0
	dbra	d7,.lp
	rts

* this routine restores a previously saved background,
* just before re-drawing the sprite again.
* Expects buffer address in a0 (like buffer_5)
* First L in buffer is where to restore:
* if zero, routine aborts
* see BACK macro
back_sprite
	btst	#0,video	either screen_0 or screen_1
	beq	.s
	add.l	#3200,a0	use buffer b instead
.s	lea	sprites,a6	start of sprite parameter array
	lsl.l	#5,d0
	add.l	d0,a6
	move.w	8(a6),d7	height
	move.w	10(a6),d6	chunks

	lsl.w	#3,d6		chunks * 8
	move.l	#136,d0
	sub.w	d6,d0		this is the offset
	move.l	d0,a5		say 152
	
	move.l	(a0),a1		retrieve destination
	move.l	a0,a3		save for later
	tst.l	(a0)+
	beq	.rts
	sub.w	#1,d7		height loop
.lp	move.w	10(a6),d6	chunks
	sub.w	#1,d6
.loop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
***	move.l	(a0)+,(a1)+
****	move.l	(a0)+,(a1)+
	dbra	d6,.loop
	add.l	a5,a1
	add.l	#8,a1
	dbra	d7,.lp
	clr.l	(a3)		always 0 as first address
.rts	rts

* the idea of putting a 0 in first buffer location is to prevent
* unnecessary background restoring when sprite is not showing
* the rule is: if background buffer starts with a 0, then
* there is nothing to restore
*-------------------------
* Now an actual vbi ROUTINE 
* vbi music system  Gary Wheaton

Q 	EQU 1       *OCTAVES
Z 	EQU 4
U 	EQU 2

*-------FLAG FOR MUSIC ON OR OFF move.b #1,musicon
*-------TO SILENCE CHANNELS : sound silence (macro)
music	movem.l	d0-d7/a0-a6,-(sp)

	tst.b musicon
	bne	bypass

	MOVE.B #$7,SL
	MOVE.B #%11111000,SD

	CMP.B #1,FL
	BEQ.S PPP
	BSR SSET
PPP
**************
	LEA _NOTE0,A0
	LEA _NOTE1,A1
	LEA _NOTE2,A2
CHAN0    
**************
	MOVE PNT0,D0 
	ADD D0,A0
	MOVE.L (A0),D1       *GET NOTE 0 & DURATION   
	CMP #$FFFF,D1
	BNE.S CON2
	CLR PNT0                *RESET TO START
	MOVE.L _NOTE0,D1
CON2 
	SUB #1,NP0
	BNE.S STILLON
	MOVE.L D1,TMP0          *D1.W IS DURATION
	MOVE TMP0,TMP00
	MOVE.B #15,VOL0
	MOVE D1,NP0             *SET NEW DURATION
	ADD #4,PNT0             *& INC POINTER
STILLON
***VOLUME
	CMP #0,TMP00
	BNE.S RFF 
	MOVE TMP0,TMP00

RFF    *LSR #1,TMP00
       *LSR #1,TMP00
	CMP.B #0,VOL0
	BEQ.S NV0
	SUB.B #1,VOL0+1
	BNE.S NV0
	SUB.B #1,VOL0
	MOVE.B #5,VOL0+1
NV0
	MOVE.B #8,SL
	MOVE.B VOL0,SD
	MOVE.B #0,SL
	MOVE.B TMP00+1,SD
	MOVE.B #1,SL
	MOVE.B TMP00,SD
CHAN1 
***********************
	MOVE PNT1,D0 
	ADD D0,A1
	MOVE.L (A1),D1       *GET NOTE 1 & DURATION   
	CMP #$FFFF,D1
	BNE.S BON3
	CLR PNT1                *RESET TO START
	MOVE.L _NOTE1,D1
BON3 
	SUB #1,NP1
	BNE.S STILL
	MOVE.L D1,TMP1          *D1.W IS DURATION
	MOVE.B #14,VOL1
	MOVE D1,NP1             *SET NEW DURATION
	ADD #4,PNT1             *& INC POINTER
STILL
***VOLUME
	CMP.B #0,VOL1
	BEQ.S NV1
	SUB.B #1,VOL1+1
	BNE.S NV1
	SUB.B #1,VOL1
	MOVE.B #3,VOL1+1
NV1
	MOVE.B #9,SL
	MOVE.B VOL1,SD
	MOVE.B #2,SL
	MOVE.B TMP1+1,SD
	MOVE.B #3,SL
	MOVE.B TMP1,SD
	MOVE.B #6,SL
	MOVE.B TMP1+1,D0
	LSR.B #1,D0
	MOVE.B D0,SD
CHAN2
***********************
	MOVE PNT2,D0 
	ADD D0,A2
	MOVE.L (A2),D1       *GET NOTE 1 & DURATION   
	CMP #$FFFF,D1
	BNE.S CON3
	CLR PNT2                *RESET TO START
	MOVE.L _NOTE2,D1
CON3 
	SUB #1,NP2
	BNE.S STI              
	MOVE.L D1,TMP2          *D1.W IS DURATION
	MOVE.B #15,VOL2
	MOVE D1,NP2             *SET NEW DURATION
	ADD #4,PNT2             *& INC POINTER
STI 
***VOLUME
	CMP.B #0,VOL2
	BEQ.S NNN
	SUB.B #1,VOL2+1
	BNE.S NNN
	SUB.B #1,VOL2
	MOVE.B #11,VOL2+1
NNN
	MOVE VIB2+2,D0
	ADD D0,VIB2
	CMP #2,VIB2
	BNE.S DD
	NEG VIB2+2
DD 	 CMP #-2,VIB2
	BNE.S NV
	NEG VIB2+2
NV 	MOVE TMP2,TMP22
	MOVE VIB2,D0
	ADD D0,TMP22
	MOVE.B #10,SL
	MOVE.B VOL2,SD
	MOVE.B #4,SL
	MOVE.B TMP22+1,SD
	MOVE.B #5,SL
	MOVE.B TMP22,SD
CD
BYPASS
	movem.l (sp)+,d0-d7/a0-a6
	rts
killer	jmp 0
SSV DC.L 0
*----------------------------------------------------------

* insert new data here use 0,1 as first two for each channel

*----------delete from here to..............
**************DATAS***************
***NOTE 1ST WORD. DURATION 2ND WORD 
*START DATA WITH--0,1
*END   DATA WITH-$FFFF,$FFFF,0

_NOTE0                        *lead tune

      DC.W 0,1,108*Z,12,108*Z,6,108*Z,6,108*Z,12,108*Z,6,108*Z,6,108*Z,12
      DC.W 162*Z,12,128*Z,12,108*Z,12

      DC.W 121*Z,12,121*Z,6,121*Z,6,121*Z,12,121*Z,6,121*Z,6,121*Z,12
      DC.W 182*Z,12,144*Z,12,121*Z,12

      DC.W 108*Z,12,108*Z,6,108*Z,6,108*Z,12,108*Z,6,108*Z,6,108*Z,12
      DC.W 96*Z,12,91*Z,12,81*Z,12,91*Z,12,108*Z,12,121*Z,12,144*Z,12,162*Z,24,162*Z,24
********
      DC.W 108*Z,24,108*Z,18,108*Z,6,108*Z,12
      DC.W 162*Z,12,128*Z,12,108*Z,12

      DC.W 121*Z,24,121*Z,18,121*Z,6,121*Z,12
      DC.W 182*Z,12,144*Z,12,121*Z,12

      DC.W 108*Z,24,108*Z,18,108*Z,6,108*Z,12
      DC.W 96*Z,12,91*Z,12,81*Z,12,91*Z,12,108*Z,12,121*Z,12,144*Z,12,162*Z,24,162*Z,24

      DC.W $FFFF,$FFFF,0 *FLAG END

_NOTE2 
      DC.W 0,1,108*8,12,108*16,12,162*8,24
      DC.W 108*8,24,162*8,24

      DC.W 121*8,12,121*16,12,182*8,24
      DC.W 121*8,24,182*8,24


      DC.W 108*8,12,108*16,12,162*8,24
      DC.W 108*8,12,108*8,12,162*8,24

      DC.W 121*8,12,121*8,12,182*8,24,162*8,24,162*8,24
***********

      DC.W 108*8,12,108*16,12,162*8,24
      DC.W 108*8,24,162*8,24

      DC.W 121*8,12,121*16,12,182*8,24
      DC.W 121*8,24,182*8,24


      DC.W 108*8,12,108*16,12,162*8,24
      DC.W 108*8,24,162*8,24

      DC.W 121*8,12,81*8,12,182*8,12,121*8,12,162*8,24,162*8,24

      DC.W $FFFF,$FFFF,0


_NOTE1 
      DC.W 0,1
      DC.W 108*Q,12,96*Q,12,108*Q,12,114*Q,12,108*Q,48
      DC.W 121*Q,12,108*Q,12,121*Q,12,128*Q,12,121*Q,48
      DC.W 108*Q,12,96*Q,12,108*Q,12,114*Q,12,108*Q,48

      DC.W 121*Q,12,144*Q,12,162*Q,12,182*Q,12,162*Q,24,162*Q,24
************
      DC.W 108*U,12,96*U,12,108*U,12,114*U,12,108*U,48
      DC.W 121*U,12,108*U,12,121*U,12,128*U,12,121*U,48
      DC.W 108*U,12,96*U,12,108*U,12,114*U,12,108*U,48

      DC.W 121*U,12,144*U,12,162*U,12,182*U,12,162*U,12,217*U,12,162*U,24

      DC.W $FFFF,$FFFF,0

*------------....here  
SSET
	MOVE _NOTE0+2,NP0
	MOVE _NOTE1+2,NP1
	MOVE _NOTE2+2,NP2
	MOVE.B #1,FL
	RTS

***POINTERS TO NOTES MUST INC BY 4
PNT0       DC.W 0
PNT1       DC.W 0
PNT2       DC.W 0
***TEMP REG
TMP0       DC.L 0
TMP1       DC.L 0
TMP2       DC.L 0

TMP22       DC.W 0
TMP00       DC.W 0
***NOTE IN PROGRESS
NP0       DC.W 0
NP1       DC.W 0
NP2       DC.W 0

FL      DC.B 0   *SE       
	DC.B 0   *GL       
	DC.B 2,0

VOL0       DC.B 15,3
VOL1       DC.B 15,4
VOL2       DC.B 15,2
MUSICON    DC.B  0,0
VIB2       DC.W 0,1

*----------------
soft_scroll
	btst	#0,scroll_flag		scrolling background?
	beq	noscrol
	move.w	#1,scroll_stepper	speed of scroll
	lea	scroll_index,a0		(range 0-1000)
	lea	scroll_direction,a1
	tst.w	(a1)
	bmi.s	scrolup
	bra.s	scroldo
scrolup	sub.w	#1,(a0)
	cmp.w	#2,(a0)
	bmi	reverse
	bra	scrolgo
scroldo	add.w	#1,(a0)
	cmp.w	#999,(a0)
	bmi.s	scrolgo	
reverse neg	(a1)			reverse direction	
scrolgo	
	jsr	jeff_scroll		go to it
noscrol	rts

*-----------------
* this one re-writes the boot sector
repair
	lea	read_buffer,a0
	move.b	#"B",2(a0)	repair byte (B for Budgie)
	move.b	#"S",180(a0)	repair byte (S for viruS)
	jsr	write_sector
	string	<repaired>	
	getkey
	bra	passed_test
*---------
* ok tested  22/4
show_scores
	move.l	$44e,save_screen
	show	utility_screen
	cls
	home
	font	16		font 16 MUST be here...
	ink	11		..before anything else.
	string	<          *          >
hi2a	bset	#0,sor8		sort finished flag (set=not finished)
hi2	btst	#0,sor8
	beq	hi3
	bclr	#0,sor8
	lea	high_scores,a0
	bsr	sort		go and do that sort in include
	bra	hi2
hi3	clr.l	d3		\now let's print that lot
	lea	high_scores,a2 \table starts with high scores
	move.l	a2,a5		\preserve start address
	move.l	a2,a3  		\a3 is for the positioners
	move.l	a2,a4		\a4 is the actual names
	adda.w	#16,a3		\now we point to positioners
	adda.w	#32,a4		\16 words further on, the names
	move.w	#7,d7		loop 8 scores
hi1	move.w	(a2),d0		an actual score
	lea	inbuff,a0
	bsr	bindec		converts scores to readable ascii
	lea	inbuff,a0	
	move.w	#5,d2
	bsr	lead_zeroes
	lea	inbuff,a0
	bsr	printline
	print	space
	print	space
	move.w	(a3),d3		an actual positioner
	mulu	#16,d3
	adda.w	d3,a4		the actual name wanted
	move.l	a4,a0		a4 points to start of string...
	bsr	printline	... which ends with 13,10,0
	adda.w	#2,a2		increment the score pointer
	adda.w	#2,a3		increment the names pointer
	move.l	a5,a4		but..restore the start address!
	adda.l	#32,a4		plus 32 to reach first name
	lea	snd5,a0
	bsr	dosound
	dbra	d7,hi1
	move.w	#$007,$ff8240	blue border  [RGB]
	font	8
*	show	save_screen	separate
hi9	rts

*------------
* newrecord (to precede show_scores   tested 22/4/89
newrecord 
	movem.l	a0-a6/d0-d7,-(sp)
	lea	high_scores,a1
	adda.w	#160,a1			the newcomer in buffer 9 
	lea	high_scores,a0
	adda.w	#14,a0			the lowest record
	move.w	score,(a0)		replace it
	lea	high_scores,a0
	adda.w	#30,a0 
	clr.l	d3
	move.w	(a0),d3  		MUST be a Word 
	mulu	#16,d3			the offset
	lea	high_scores,a0
	adda.w	#32,a0
	lea	0(a0,d3),a4		actual name we want to remove
	move.l	#12,d4			13 byte long entry
nr2	move.b	(a1)+,(a4)+
	dbra	d4,nr2
	lea	high_scores,a0		new: sept 89
	jsr	sort			re-sort the table
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*------------
enter_your_name
	jsr	clearbuf		flush k/board as input is imminent	
	move.l	$44e,save_screen
	show	utility_screen
	cls
	home
	font	16
	ink	15
	move.w	#12,d5
	move.l	#high_scores,a5 
	adda.l	#160,a5
.en7	move.b	#46,(a5)+		put 13 full stops (ascii 46)
	dbra	d5,.en7
	move.l	#keybuff+2,a0
	move.w	#12,d0
.lp	move.b	#32,(a0)+		clean my buffer
	dbra	d0,.lp
	printat	2,4,0,#yourname
	jsr	getlin			input name (buffer is clean)
	move.w	#12,d7			loop     12 to 11   24/4/89
	move.l	#keybuff+2,a0		from input buffer
	move.l	#high_scores,a1 	to hi-score table
	adda.l	#160,a1
.en1	move.b	(a0)+,d0		get a byte from input buffer
	cmp.b	#32,d0		c/r and zeroes cause problems
	beq	.en4			space is OK
	cmp.b	#46,d0
	beq	.en4			dot os OK
	cmp.b	#96,d0			97 is a
	bmi	.en11
	sub.b	#32,d0			try to bring it down to Upper case
	cmp.b	#90,d0			Z
	bgt	.en2			still too high, forget it	
.en11	cmp.b	#65,d0			less than A?
	bmi	.en2
	cmp.b	#90,d0			greater than Z?
	bgt	.en2
	bra	.en4			ok valid character
.en2	move.b	#32,d0			substitute space instead
.en4	
	move.b	d0,(a1)+		should be OK by now
	dbra	d7,.en1
	font	8
	show	save_screen
.en9	rts
yourname dc.b "Your Name...",10,13,0
	even
*------------------
* this is a horizontal blank routine, used for graphic timing
* it should be removed when the game is debugged
* it increments hbl_ct each horizontal line, so that one can always
* tell where the raster is.   Should never exceed 300.
hbl_r2	
	add.w	#1,hbl_ct
	rte
*---------------
reset_high_scores
	print	confirm 
	getkey
	cmp.b	#"Y",d0
	beq	r_h_s2
	rts
r_h_s2	move.l	#7,d3
	lea	high_scores,a0
r_h_s1	move.w	#0,(a0)+
	dbra	d3,r_h_s1
	rts
*------------
* universal mouse coverage detect (Nov 88)
* expects current x-y position of mouse in d1,d2  (L)
* expects address of 4 Long words in A0 ex: fruitpos dc.l 22,28,100,128
* answer in mouseloc (w) 0 or 1  no or yes
* A0 will be corrupted. Save if necessary
* ex: bsr read_the_mouse     bsr mouse_pos     tst.w mouseloc
mouse_pos
	move.l	0(a0),d3
	cmp.l	d3,d1		left
	bmi	.no
	move.l	4(a0),d3
	cmp.l	d3,d1		right
	bgt	.no
	move.l	8(a0),d3
	cmp.l	d3,d2		top
	bmi	.no
	move.l	12(a0),d3
	cmp.l	d3,d2		bottom
	bgt	.no
	move.w	#1,mouseloc	ok to gamble
	rts
.no	move.w	#0,mouseloc
	rts
mouseloc	dc.w	0
*---------------------------
**  toggle the two video screens
toggle_screens	
	lea	logical_screen,a0
	movea.l	(a0),a1		logical and
	movea.l	4(a0),a2	physical pointers
	move.l	a1,4(a0)	now
	move.l	a2,(a0)		switched around
	
	move.l	a1,$45e		somehow this line is needed to tidy up screen records

	move	#-1,-(a7)	set_screen  same res
	move.l	a1,-(a7)	new log
	move.l	a2,-(a7)	new phys
	move	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	rts
*---------------------------------------------
time_update
	cmp.w	#50,clock_timer   50=1 second
	bgt	.timeok
	rts			not yet

.timeok	clr.w	clock_timer
	lea	time,a0
	add.w	#1,(a0)
	move.w	(a0),d0
	lea	inbuff,a0
	jsr	bindec
	lea	inbuff,a0
	lea	inbuff,a6
	clr.l	d0
	move.b  3(a6),d0	tens
	sub.b	#48,d0		48=ascii 0
	lsl.b	#3,d0		mul by 8
	move.l	spr_screen,a0
	add.l	#108*160,a0	make a variable later
	add.l	d0,a0		final pos
	move.l	logical_screen,a1
	move.l	physical_screen,a2
	add.l	#70*160+144,a1
	add.l	#70*160+144,a2
	move.l	0(a0),(a1)		top border black
	move.l	0(a0),(a2)
	move.l	160(a0),160(a1)
	move.l	160(a0),160(a2)
	move.l	320(a0),320(a1)
	move.l	320(a0),320(a2)
	move.l	480(a0),480(a1)
	move.l	480(a0),480(a2)
	move.l	640(a0),640(a1)
	move.l	640(a0),640(a2)
	move.l	800(a0),800(a1)
	move.l	800(a0),800(a2)
	move.l	960(a0),960(a1)
	move.l	960(a0),960(a2)
	move.l	1120(a0),1120(a1)
	move.l	1120(a0),1120(a2)
	move.l	1280(a0),1280(a1)
	move.l	1280(a0),1280(a2)
	move.l	1440(a0),1440(a1)
	move.l	1440(a0),1440(a2)
	move.l	1600(a0),1600(a1)	
	move.l	1600(a0),1600(a2)
	move.l	1760(a0),1760(a1)
	move.l	1760(a0),1760(a2)
	move.l	1920(a0),1920(a1)
	move.l	1920(a0),1920(a2)
	move.l	2080(a0),2080(a1)
	move.l	2080(a0),2080(a2)
	move.l	2240(a0),2240(a1)
	move.l	2240(a0),2240(a2)
	move.l	2400(a0),2400(a1)
	move.l	2400(a0),2400(a2)

	sub.l	d0,a0		reset origin at 0
	clr.l	d0
	move.b  4(a6),d0	units
	sub.b	#48,d0		48=ascii 0
	lsl.b	#3,d0		mul by 8
	add.l	d0,a0		final pos
	add.l	#8,a1		screen: more 1 pos to the right
	add.l	#8,a2		same
	move.l	(a0),(a1)
	move.l	(a0),(a2)
	move.l	160(a0),160(a1)
	move.l	160(a0),160(a2)
	move.l	320(a0),320(a1)
	move.l	320(a0),320(a2)
	move.l	480(a0),480(a1)
	move.l	480(a0),480(a2)
	move.l	640(a0),640(a1)
	move.l	640(a0),640(a2)
	move.l	800(a0),800(a1)
	move.l	800(a0),800(a2)
	move.l	960(a0),960(a1)
	move.l	960(a0),960(a2)
	move.l	1120(a0),1120(a1)
	move.l	1120(a0),1120(a2)
	move.l	1280(a0),1280(a1)
	move.l	1280(a0),1280(a2)
	move.l	1440(a0),1440(a1)
	move.l	1440(a0),1440(a2)
	move.l	1600(a0),1600(a1)
	move.l	1600(a0),1600(a2)
	move.l	1760(a0),1760(a1)
	move.l	1760(a0),1760(a2)
	move.l	1920(a0),1920(a1)
	move.l	1920(a0),1920(a2)
	move.l	2080(a0),2080(a1)
	move.l	2080(a0),2080(a2)
	move.l	2240(a0),2240(a1)
	move.l	2240(a0),2240(a2)
	move.l	2400(a0),2400(a1)
	move.l	2400(a0),2400(a2)
	add.w	#8,bill
	rts
*------------------------
* note: sprites are defined graphically on a degas.pi1
* picture, held in memory. Usually called sprites.pi1. or sprites.pic
* usually held on a screen called spr_screen (see opening sequence)
* Another degas.pi1 is required as a background picture. 
* This picture is then copied TWICE under physical_screen
* and logical_screen  (usually known as screen_0 and screen_1)
* the background picture is needed to RESTORE a background
* after a sprite has left it.
* The information about sprites is held in an array called 'sprites'
* Each sprite need 32 bytes to hold the required information
* Therefore, info about second sprite is held at 'sprites'+32
* next one is at sprites+64  and so on
* Finally, the sort of info stored in that array is
*  origin: its precise location on our degas picture (spr_screen)
*  destination: where we are about to draw it (ex:16000) middle of screen
*  height (anything up to 200 lines)
*  chunks (width) (1 chunk = 16 pixels)
*  initial x  (anything from 0 to 319)
*  initial y  (anything from 0 to 199)
*  restore address  (for restoring background on one screen)
*  restore address  (same thing, but, for the other screen)
*  lateral direction  (left/right)
*  active/ inactive byte
*  last two bytes (30-31) unused

initialize_sprites
*-- 0 -----------------------------------------------------------
	lea	sprites,a6	start of sprite parameters array
	add.l	#0,a6		joystick sprite usually first	
	move.l	#190*160+128,(a6)	origin on Degas	
	move.l	#8000,4(a6)	destination : y * 160
	move.w	#10,8(a6)	height	
	move.w	#3,10(a6)	chunks
	move.w	#0,12(a6)	initial x
	move.w	#50,14(a6)	initial y
	move.l	#8000,16(a6)	y * 160 + x	
	move.l	#0,20(a6)	restore address (2 v/b away)
	move.l	#0,24(a6)	restore address (1 away)
	move.b	#0,28(a6)	going right
	move.b	#1,29(a6)	active
*-- 1 -----------------------------------------------------------
	lea	sprites,a6	start of sprite parameters array
	add.l	#32,a6		second sprite (ie sprite #1)
	move.l	#160,(a6)	origin on degas
	move.l	#3200,4(a6)	destination : y * 160
	move.w	#8,8(a6)	height
	move.w	#1,10(a6)	chunks
	move.w	#0,12(a6)	initial x
	move.w	#20,14(a6)	initial y
	move.l	#3200,16(a6)	y*160 + xbyte
	move.l	#0,20(a6)	restore address (2 away)
	move.l	#0,24(a6)	restore address (1 away)
	move.b	#0,28(a6)	going right
	move.b	#1,29(a6)	active
*-- 2 -----------------------------------------------------------
	lea	sprites,a6	
	add.l	#64,a6		#2
	move.l	#168,(a6)	
	move.l	#8000,4(a6)
	move.w	#18,8(a6)	
	move.w	#1,10(a6)	chunks
	move.w	#0,12(a6)
	move.w	#50,14(a6)
	move.l	#8000,16(a6)	
	move.l	#0,20(a6)
	move.b	#0,28(a6)
	move.b	#1,29(a6)
*-- 3 -----------------------------------------------------------
	lea	sprites,a6	start of sprite parameters array
	add.l	#96,a6		sprite #3
	move.l	#160,(a6)	origin on degas (top of screen, far left)
	move.l	#130*160,4(a6)	initial destination : y * 160
	move.w	#6,8(a6)	height
	move.w	#9,10(a6)	chunks (each chunk is 16 pixels wide)
	move.w	#8,12(a6)	initial x	 (here, far left)
	move.w	#130,14(a6)	initial y	 (half way down)
	move.l	#130*160+80,16(a6)	y*160 + xbyte
	move.l	#0,20(a6)	restore (2 v/b away)	
	move.b	#0,28(a6)	going right
	move.b	#1,29(a6)	active
*-- 4 -----------------------------------------------------------
	lea	sprites,a6	
	add.l	#128,a6		sprite #4
	move.l	#160,(a6)	
	move.l	#8000,4(a6)
	move.w	#18,8(a6)	
	move.w	#1,10(a6)	chunks
	move.w	#0,12(a6)
	move.w	#50,14(a6)
	move.l	#8000,16(a6)	
	move.l	#0,20(a6)
	move.b	#0,28(a6)
	move.b	#1,29(a6)
*-- 5 -----------------------------------------------------------
	lea	sprites,a6	
	add.l	#160,a6		sprite #5
	move.l	#106*160,(a6)	origin	
	move.l	#24000,4(a6)	initial destination
	move.w	#16,8(a6)	h
	move.w	#3,10(a6)	chunks
	move.w	#160,12(a6)	x   ie byte 80
	move.w	#150,14(a6)	y
	move.l	#24080,16(a6)	precise (0-32000)	
	move.l	#0,20(a6)
	move.b	#0,28(a6)
	move.b	#1,29(a6)
*-- 6 -----------------------------------------------------------
	lea	sprites,a6	
	add.l	#192,a6		sprite #6
	move.l	#16000,(a6)	
	move.l	#24000,4(a6)	
	move.w	#38,8(a6)	h
	move.w	#3,10(a6)	ch
	move.w	#160,12(a6)	x   ie byte 80
	move.w	#150,14(a6)	y
	move.l	#24080,16(a6)	precise (0-32000)	
	move.l	#0,20(a6)
	move.b	#0,28(a6)
	move.b	#1,29(a6)

	rts
*------------------------------------
* sprites parameter blocks
*  0 (L) origin		(0-32000) in 8's
*  4 (L) destination y * 160  (0,160,320.....32000)
*  8 (W) height (1-200)
* 10 (W) chunks (1-8)
* 12 (W) x	(0-320)
* 14 (W) y	(0-199)
* 16 (L) full location ie y + x (0-32000)
* 20 (L) restore address (2 v/b away) 
* 24 (L) restore address (next v/b)  (0-32000)
* 28 (B) direction 	(0 right   1 left)
* 29 (B) active flag 	(0 inactive  1 active)

sprites	ds.l	64	room for 8 sprites

* some timings: a sprite 6 chunk wide, 20 lines high, takes 145 h/b to draw
* then, there is saving and restoring....
*---------------------------------------------------------------
kup	move.l	$44e,a0
	add.l 	incr,a0	
	move.l	a0,$45e	
	bsr	vtsync
	rts
kdown	move.l	$44e,a0
	sub.l 	incr,a0	
	move.l	a0,$45e	
	bsr	vtsync
	rts
*-----------
end_of_level
	silence		silence sound chip
	move.w 	#0,clock_timer
	move.w	#99,time	or whatever figure is needed
	lea 	level,a0		
	add.w 	#1,(a0)		move to next level

	show	screen_1	give us a bonus
	move.l	screen_1,a0
	sub.l	#32,a0
	bsr	setpal
	wait	50
	move.l	screen_0,$45e
	bsr	vtsync
	move.l	#palet,a0
	bsr	setpal
	bsr 	initjoy
	bra 	intro4
*-------------------
end_of_game
	move.w	#0,clock_timer
	lea	snd5,a0
	bsr	dosound
	wait	8
	bsr	clearbuf
e_o_g0	
	move.w	score,score
	
	bsr	newrecord
	lea	high_scores,a3
	lea	file_6,a0  (hiscores.asc)
	bsr	f_create
	move.l	#356,d3		was #244,D3
	bsr	f_write
	bsr	f_close	
	bsr	show_scores
	getkey
e_o_g1	
	move.w	#0,score
	move.w	#0,game_over
	move.w	#1,level		ok
	bsr 	clearbuf
	rts
*------------------
* this is the official quit routine  (jsr kwit)
kwit	move.b	#0,$fffa1b	stabilise MFP interrupt
	btst	#0,h_blank	was a h/blk routine active
	beq	kwi1
	move.l	#hbl_r2,a0	if so de-activate it
	bsr	rst_horizontal_blank  
	bclr	#0,h_blank	

kwi1	move.l	#music,a5	  
	bsr	disable_vbi	disable the above v/blk routine
	silence
	bra 	quit		restore the palette and final quit
*---------------------------------
* this one un-scrambles a scrambled code on boot sector
read_meadway_boot
	jsr	read_sector		read boot sector
	lea	read_buffer,a0		this buffer is 512 bytes long
	add.w	#78,a0
	move.w	#$200-80,d0
llpp	move.b	(a0),d1
	eori.b	#$ff,d1
	move.b	d1,(a0)+
	dbra	d0,llpp
	jsr	boot_sector
	getkey
	bsr	write_sector
	bra	kwit
*----------------------
create_boot_uk
	jsr	read_sector		read boot sector
	lea	read_buffer,a0		this buffer is 512 bytes long
	move.b	#$60,0(a0)		"bra $3a bytes.. 
	move.b	#$38,1(a0)		..further away"
	add.w	#$3a,a0			put code here
	lea	new_buffer,a1
	move.w	#200,d7			loop
.lll	move.b	(a1)+,(a0)+		transfer to official buffer
	dbra	d7,.lll
	string	<OK READY TO WRITE>
	string	<PRESS KEY>
	jsr	boot_sector		prepare executionable sector
	getkey
	jsr	write_sector		and write it to disk
	bra	kwit	

*----------------------
* here is an actual code that will be stored on boot sector
* and executed (if disk is made executable)
* It flashes a welcome message.
new_buffer
	lea	budg(pc),a0
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#100,d7
.lpp	addi.w	#$111,$ff8242		flashes
	subi.w	#$111,$ff8240
	bsr	.slow
	dbra	d7,.lpp
	move.w	#30,d7
.lpl	subi.w	#$111,$ff8242		more flashes
	addi.w	#$111,$ff8240
	bsr	.slow
	dbra	d7,.lpl
	rts
.slow	
	move.w	#1000,d6		delay between flashes
.lps	nop
	nop
	dbra	d6,.lps
	rts

budg	dc.b	10,10,10,10,10,10,10,10,7
	dc.b	"      BILL  AVERY  IS   VIRUS  FREE !",10,10,10,10,13
	dc.b	"      ALL   CIRCUITS   OPERATIONAL..",10,13,0
	ds.b	500
	even


*~~~~~~~~~~~~~~~~~~~~~~~INCLUDES~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	even
	include "a:\includes\include1.s"
	even
	include "a:\includes\include2.s"
	even
	include "a:\includes\include3.s"
	even
	include "a:\includes\include4.s"
	even
	include "a:\includes\include5.s"	st replay only
	even
	include "a:\shell\included.s"		custimized routines
	even
	include "a:\includes\sounds.s"
	even
	include "a:\shell\text.s"
	even
	include "a:\common\games.s"
	even

*~~~~~~~~~~~~~~~~~VARIABLES AND CONSTANTS~~~~~~~~~~~~~~~~~*

rnd1        	dc.l	0	these randoms are clearly visible..
rnd2        	dc.l	0	..in action
rnd3        	dc.l	0
		
defender    	dc.b	0	used to be a word, but a word is MUCH
joystick	dc.b	0
		even		better for bit testing
		dc.l	0
pause	  	dc.w	0
status	  	dc.w	0	status flag   
level	  	dc.w	1	initial level
game_over	dc.w	0

k_repeat	dc.w	0	normally 2
k_delay		dc.w	0	normally 15
destroyed	dc.w	0
ambline		dc.l	0	a line number (0-1000++
store		dc.w	0	debugging/ work variable
storel		dc.l	0	same, but Long
records		dc.l	0	
dot		dc.w	0	flag   bset#0 to draw a dot
hbl_ct		dc.w	0	these three here used for debugging only:
before		ds.w	20	this is an ARRAY when various 'stopwatches'
after		ds.w	20	are slotted for revealing through k_star
degas_file	dc.w	0

incr		dc.l	1280	used for hardware scrolling

drum		dc.b "a:\common\drum*.spl",0
penny_pic	dc.b "a:\common\penny.pi1",0
budgie_pic	dc.b "a:\common\budgie.tit",0
title_page 	dc.b "a:\shell\title.pi1",0
sprites1	dc.b "a:\shell\sprites.pic",0  <<<< compacted!
; if not compacted, call it sprites.pi1
; and make sure to load it the proper, uncompacted, way
background	dc.b "a:\shell\blob.pi1",0	change as required
help_pic 	dc.b "a:\shell\help*.pi1",0	" 	  "
a1_font		dc.b "a:\fonts\a1_fat*.fon",0	change as required
a2_font		dc.b "a:\fonts\a2_squa*.fon",0	"         "
a2_font2	dc.b "a:\fonts\a2_elega*.fon",0
file_6    	dc.b "a:\shell\hiscores.asc",0
		even
drum_ptr	dc.l	0
a1_ptr		dc.l	0	16*8 font
a2_ptr		dc.l	0	8*8 font
top_screen	dc.l	0
buffer_screen	dc.l	0	all these are POINTERS
spr_screen	dc.l	0	where degas sprites will go
cur_screen 	dc.l	0
work_screen 	dc.l	0
screen_0	dc.l	0	this one is a video screen
screen_1	dc.l	0	and this is the other
back_screen	dc.l	0
screen_3	dc.l	0
lady_screen 	dc.l	0
utility_screen 	dc.l	0	sort of workscreen, for messages, etc..
current_screen	dc.l	0
spare_screen	dc.l	0
video_screen	dc.l	0
screen_base	dc.l	0	the very first screen, early in ram

score		dc.w	0	needed
clock_timer 	dc.w	0	needed
time		dc.w	0	needed
h_blank		dc.w	0	a flag
new_record 	dc.w	0
new_entry 	dc.w	0
cheat		dc.w	0	
bill		dc.w	0	the time taken in 1 v/b  0 to 300 approx
lives		dc.w	3
freeze_ct 	dc.w	5 	when my ship is hit by damonoid
scroll_flag	dc.w	0	on/off scroll flag
slow		dc.w	0  	flag to slow down things
video	 	dc.w	0	bit 0 clear=screen 0 showing

dtaddress	ds.w	52	needed for disk routines
		
res_word	ds.w	1	these 17 words must stay together
palet		ds.w	16	start up palette 

sbuff     	ds.l	1	this address is the last one on the prog
		even

*~~~~~~~~~~~~~~~~~~~THE STACK~~~~~~~~~~~~~~~~~~~~~~~~~~*

		ds.l	256	about 64 used on average
stack		dc.l	0

buffer_5	ds.w	1600
		ds.w	1600  (buffer_5 + 3200 bytes)
buffer_6	ds.w	1600
		ds.w	1600  (buffer_6 + 3200 bytes)
		dc.b "--------------------------------------------"
		even
* the above buffers and the dotted line are actually visible
* when debugging with cursor keys. They are just before the start
* of the heap, before utility_screen  

*~~~~~~~THE END~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
