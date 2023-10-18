* Spectrum Analyser development version
 
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

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp		* Supervisor
		move.l	D0,save_stack

		move.b	#$00,$FF820A

		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	D0,res

		move.w	#$00,-(sp)	* Lo resolution
		move.l	#-1,(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp	

		move.w	#2,-(sp)	* Get screen address
		trap	#14
		addq.l	#2,sp
		move.l	D0,physic

		pea	dta_buf		* SET dta
		move.w	#$1A,-(sp)
		trap	#1
		addq.l	#6,sp
		
		jsr	moff

		jsr	intro		* Call up advert screen

* --> Load and display charlie2.pic
* --> Load sample data charlie.dat

		move.l	#pic_name2,file_ptr
		jsr	getfile		* Load CHARLIE1.PIC
	
		move.l	load_ptr,pic_buf

		move.l	pic_buf,A0
		addq.l	#$02,A0

                move.l  A0,-(sp)   * Set the palette
                move.w  #6,-(sp)
                trap    #14
                addq.l  #6,sp

		move.l	#7999,D0	* Display picture
		move.l	physic,A1
		move.l	pic_buf,A0
		add.l	#34,A0

display:	move.l	(A0)+,(A1)+
		dbf	D0,display

		move.l	pic_buf,-(sp)
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp		* Free buffer

* --> Store LED OFF images

		move.l	physic,A0
		add.l	#16512,A0
		lea	red_led_off,A1
		jsr	store
		add.l	#8,A0
		lea	green_led_off,A1
		jsr	store
		add.l	#8,A0
		lea	blue_led_off,A1
		jsr	store
		add.l	#8,A0
		lea	amber_led_off,A1
		jsr	store

* --> Store LED ON images

		move.l	physic,A0
		add.l	#18112,A0
		lea	red_led_on,A1
		jsr	store
		add.l	#8,A0
		lea	green_led_on,A1
		jsr	store
		add.l	#8,A0
		lea	blue_led_on,A1
		jsr	store
		add.l	#8,A0
		lea	amber_led_on,A1
		jsr	store

* --> Now erase the original image
		move.l	physic,A0
		add.l	#16512,A0

erase:		move.l	#16,D0		* Lines to erase
erase1:		move.l	#9,D1		* Longwords per line
erase2:		clr.l	(A0)+
		dbf	D1,erase2
		add.l	#120,A0		* Down a line
		dbf	D0,erase1
 		jmp	load_dat

* --> Store LED image

store:		move.l	A0,-(sp)
		move.l	#5,D0		* Lines to store

store2:		move.l	(A0)+,(A1)+
		move.l	(A0),(A1)+	* Place in storage
		lea	156(A0),A0	* Next line
		dbf	D0,store2
		move.l	(sp)+,A0
		rts

* --> Now load sample data.

load_dat:       move.l	#sample_dat,file_ptr
		jsr	getfile

		move.l	physic,A0
		add.l	#4816,A0
		move.l	A0,green_leds
		add.l	#16,A0
		move.l	A0,amber_leds
		add.l	#8,A0
		move.l	A0,red_leds

		lea	velvet_table,A0
		move.l	load_ptr,D0

pre_add:	move.l	(A0),D1
		cmp.l	#9999,D1
		beq	pre_add2

		add.l	D0,D1
		move.l	D1,(A0)+
		add.l	#12,A0		* Skip length, speed and number
		jmp	pre_add

pre_add2:	lea	bar1_table,A0
		clr.l	D0
pre_add3:	move.l	(A0),D0
		tst.l	D0
		beq	velvet
		add.l	physic,D0
		move.l	D0,(A0)+
		jmp	pre_add3

* --> Now play some stuff

velvet:		lea	velvet_table,A0

velvet2:	cmp.l	#9999,(A0)
		beq	velvet
		move.l	(A0)+,start_address
		move.l	(A0)+,length_off
		move.l	(A0)+,speed
		move.l	(A0)+,sample_num
		jsr	led_update
		jsr	digiout
		cmp.b	#$39,$FFFC02
		beq	to_gem

		jmp	velvet2

* --> Display number in sample_num on the LED's

led_update:	move.l	sample_num,D0	* Number to display
		move.l	last_sample,D1
		cmp.w	D0,D1
		beq	led_same	* We have a loop, light blue
		blt	led_upto	* Increase light

* --> Unlight LED's from last_sample to sample_num+1

led_downto:	jsr	bloff		* Cancel loop
		mulu.w	#8,D0		* Holds current sample
		move.l	physic,A1
		add.w	#4816,D0
 		add.w	D0,A1		* A1 = address of current LED

* --> Now unlight all LED's up to last_sample

		sub.l	sample_num,D1	* Number to unlight
		subq.b	#$01,D1

led_downto2:	jsr	unlight_led
		addq.w	#$08,A1
		dbf	D1,led_downto2
		jmp	led_end
		
* --> Light LED's from last_sample+1 to sample_num

led_upto:	jsr	bloff		* Cancel loop LED
		mulu.w	#8,D1
		move.l	physic,A1
		add.w	#4816,D1
		add.w	D1,A1		* A1 = screen address of last LED

		sub.l	last_sample,D0	* No of lights to light
		subq.b	#$01,D0

led_upto2:	jsr	light_led
		addq.l	#$08,A1		* Next LED
		dbf	D0,led_upto2
		jmp	led_end

* --> Light LED pointed to by A1.

light_led:	cmp.l	amber_leds,A1
		bge	light_led2
		lea	green_led_on,A5
		jmp	do_light
light_led2:	cmp.l	red_leds,A1
		bge	light_led3
		lea	amber_led_on,A5
		jmp	do_light

light_led3:	lea	red_led_on,A5

do_light:	move.l	A1,A6		* Destination
		move.l	(A5)+,(A6)+
		move.l	(A5)+,(A6)
		lea	156(A6),A6	* Down a line
		move.l	(A5)+,(A6)+
		move.l	(A5)+,(A6)
		lea	156(A6),A6	* Down a line
		move.l	(A5)+,(A6)+
		move.l	(A5)+,(A6)
		lea	156(A6),A6	* Down a line
		move.l	(A5)+,(A6)+
		move.l	(A5)+,(A6)
		lea	156(A6),A6	* Down a line
		move.l	(A5)+,(A6)+
		move.l	(A5)+,(A6)
		lea	156(A6),A6	* Down a line
		move.l	(A5)+,(A6)+
		move.l	(A5)+,(A6)
		rts

* --> Unlight LED pointed to by A1.

unlight_led:	cmp.l	amber_leds,A1
		bge	unlight_led2
		lea	green_led_off,A5
		jmp	do_light
unlight_led2:	cmp.l	red_leds,A1
		bge	unlight_led3
		lea	amber_led_off,A5
		jmp	do_light

unlight_led3:	lea	red_led_off,A5
		jmp	do_light

* --> Light blue LED

blon:		lea	blue_led_on,A5
		move.l	physic,A1
		lea	4936(A1),A1
		jsr	do_light
		rts

* --> Unlight blue LED
bloff:		lea	blue_led_off,A5
		move.l	physic,A1
		lea	4936(A1),A1
		jsr	do_light
		rts

led_same:	jsr	blon		* Light blue LED
led_end:	move.l	sample_num,last_sample
		rts

sample_num:	ds.l	1
last_sample:	dc.l	0 
green_leds:	ds.l	1
amber_leds:	ds.l	1
red_leds:	ds.l	1

* --> Playback routine

start_address:	DC.L 0
length_off:	DC.L 0
speed:		DC.L 0

digiout:	move.l A0,-(SP)
		MOVE.L start_address(PC),A4
		MOVE.L length_off(PC),D6
		MOVE.L speed(PC),D5

		ADD.L A4,D6			* FIND DATA END ADDRS
		LEA TTP(PC),A0

		MOVE.W D5,2(A0)			* SET DELAY LOOP VALUE
		LEA STATUS(PC),A0
		MOVE.W SR,(A0)			* SAVE SR REGISTER
		MOVE.W SR,D3
		MOVE.W #$2700,SR		* KILL 'ALL' INTERUPTS
		MOVEQ #10,D0
SETREGS		MOVE.B D0,$FFF8800		* CLEAR AND SET
		CLR.B $FFF8802			* SOUND AND FREQ.
		DBF D0,SETREGS

		MOVE.B #7,$FFF8800		* REG. 7 OF SND CHIP
		MOVE.B #$F8,$FFF8802		* ALL CHANELS ON

		MOVE.W D3,SR
		ANDI.W #$F8FF,SR
		ORI.W #$500,SR			* DO NOT DISTURB SOUND
		AND.W #$FD,$484
		
		move.l	#920,D7		* Number of numbers per spectrum update

MUSICLP		MOVE.B (A4)+,D0			* GET SAMPLED DATA
		and.w	#$FC,D0

		CMPA.L D6,A4			* END OF BUFFER
		BLT.S 	self_modify1

		BRA	EXIT			* DONE, SET FLAG


self_modify1:	jmp	spectrum_on

spectrum_on:	lea	spectrum,A3		* Count the number
		addq.b	#$01,(A3,D0.w)
       		subq.w	#$01,D7
		beq	do_spectrum	* Time to update!

TTP		MOVE.W 	#0,D4			* DELAY LOOP
LOOPME		NOP				* NOT MUCH HERE
		DBF D4,LOOPME
		
spectrum_off:	LEA 	CHANEL_A(PC),A3
		MOVE.L 	#$09000800,D5		* SETUP VALUES
		MOVE.B 	1(A3,D0.W),D5
		SWAP D5
		MOVE.B 	3(A3,D0.W),D5		* READ TABLE AMP.

		LEA 	$FFF8800,A3
		MOVEP.L D5,0(A3)		* OUTPUT SOUND

		BRA.S MUSICLP			* KEEP IT UP

EXIT_TWO	clr.b 	D5
EXIT		lea 	STATUS(PC),A0
		move.w 	(A0),SR			* UP-DATE SR
		ori.b	#3,$484
		move.l 	(SP)+,A0
		rts

* --> We have recorded the frequency of the last 460 bytes. The numbers
*     are stored in 'spectrum'. Update the analyser according to these
*     values, and clear the total for any value we use

do_spectrum:	move.l	A0,-(sp)

		lea	self_modify1,A0
		move.l	#do_spectrum2,2(A0)

		move.l	(sp)+,A0
		jmp	spectrum_off

* --> Here we want to see wether the last peak for this bar was >
*     than, < than or equal to the desired new height
  
do_spectrum2:	movem.l	A0-A1/D0,-(sp)
		clr.w	D0
self_modify2:	lea	last_bar1,A0	* Will want to change bar number

		lea	spectrum,A1	* Address of totals
self_modify3:	add.l	#$00,A1		* Number to scan for

		cmp.b	#30,(A1)
		bls	do_spectrum2b
		move.b	#30,(A1)	* Set max level

do_spectrum2b:	move.b	(A1),D0
		cmp.b	(A0),D0
		beq	done_this_bar	* Bar finished
		blt	do_spectrum4

* --> Set the original JMP to jump to a 'down single barlight' routine
do_spectrum3:	lea	self_modify1,A0
		move.l	#barlight_up,2(A0)
		movem.l	(sp)+,A0-A1/D0
		jmp	spectrum_off

* --> Set the original JMP to jump to a 'up single barlight' routine
do_spectrum4:	lea	self_modify1,A0
		move.l	#barlight_down,2(A0)
		movem.l	(sp)+,A0-A1/D0
		jmp	spectrum_off

* --> Light up next barlight. Called until bar completed.
barlight_up:	movem.l	A0-A1/D0,-(sp)
		clr.w	D0
self_modify4:	lea	last_bar1,A0	* Height of bar
self_modify5:	lea	bar1_table,A1
		move.b	(A0),D0
		asl.w	#2,D0		* MULU.W  #4,D0
		add.w	D0,A1		* Address of address of barlight
		move.l	(A1),regstore1
		
		lea	self_modify1,A0
		move.l	#light_bar,2(A0)	* Next task is light bar

self_modify6:	lea	last_bar1,A0	* Update last_bar
		addq.b	#$01,(A0)
		movem.l	(sp)+,A0-A1/D0
		jmp	spectrum_off
				
* --> Decrease lit barlights. Called until bar completed.
barlight_down:	movem.l	A0-A1/D0,-(sp)
		clr.w	D0
self_modify7:	lea	last_bar1,A0
self_modify8:	lea	bar1_table,A1
		move.b	(A0),D0
		asl.w	#2,D0
		add.w	D0,A1		* Address of address of light to lose
		lea	self_modify1,A0
		move.l	#unlight_bar,2(A0)

		move.l	(A1),regstore1
self_modify9:	lea	last_bar1,A0
		subq.b	#$01,(A0)
		movem.l	(sp)+,A0-A1/D0
		jmp	spectrum_off

* --> Place bar in A0 at A1
light_bar:	move.l	A1,-(sp)
		move.l	regstore1,A1
		move.l	#$7FF80FFF,(A1)
		lea	self_modify1,A1
		move.l	#do_spectrum2,2(A1)
		move.l	(sp)+,A1
		jmp	spectrum_off

* --> Clear bar at A1
unlight_bar:	move.l	A1,-(sp)
		move.l	regstore1,A1
		clr.l	(A1)
		lea	self_modify1,A1
		move.l	#do_spectrum2,2(A1)
		move.l	(sp)+,A1
		jmp	spectrum_off

* --> Modify necessary parameters to do next bar, and check 
*     wether to reset the bar number to 1

done_this_bar:	lea	spectrum,A0
self_modify10:	add.l	#$00,A0
		clr.b	(A0)		* Reset counter

		lea	self_modify1,A0
		move.l	#nextbar,2(A0)
		movem.l	(sp)+,A0-A1/D0
		jmp	spectrum_off

* --> Modify above code so that next bar is updated. Repeat for 15 bars

nextbar:	move.l	A0,-(sp)

		sub.w	#$01,bar
		beq	reset_bars	* If all done, back to first

		lea	self_modify1,A0
		move.l	#nextbar2,2(A0)

		lea	self_modify2,A0
		addq.l	#$02,2(A0)	* Point to next 'last_bar#'

		lea	self_modify3,A0
		add.l	#16,2(A0)	* Update offset into 'spectrum'

		move.l	(sp)+,A0
		jmp	spectrum_off

nextbar2:	move.l	A0,-(sp)
		lea	self_modify1,A0
		move.l	#nextbar3,2(A0)

		lea	self_modify4,A0
		addq.l	#$02,2(A0)	* As self2

		lea	self_modify5,A0
		add.l	#128,2(A0)	* Next 'bar_table#'

		lea	self_modify6,A0
		addq.l	#$02,2(A0)	* As self2
		move.l	(sp)+,A0
		jmp	spectrum_off

nextbar3:	move.l	A0,-(sp)
		lea	self_modify1,A0
		move.l	#nextbar4,2(A0)

		lea	self_modify7,A0
		addq.l	#$02,2(A0)	* As self2

		lea	self_modify8,A0
		add.l	#128,2(A0)	* As self5
		move.l	(sp)+,A0
		jmp	spectrum_off

nextbar4:	move.l	A0,-(sp)
		lea	self_modify1,A0
		move.l	#do_spectrum2,2(A0)

		lea	self_modify9,A0
		addq.l	#$02,2(A0)	* As self2
	
		lea	self_modify10,A0
		add.l	#16,2(A0)	* As self3

		move.l	(sp)+,A0
		jmp	spectrum_off

* ---> Reset bars - restore default values in modified code

reset_bars:	lea	self_modify2,A0
		move.l	#last_bar1,2(A0)
		lea	self_modify3,A0
		clr.l	2(A0)
		lea	self_modify4,A0
		move.l	#last_bar1,2(A0)
		lea	self_modify5,A0
		move.l	#bar1_table,2(A0)
		lea	self_modify6,A0
		move.l	#last_bar1,2(A0)
		lea	self_modify7,A0
		move.l	#last_bar1,2(A0)
		lea	self_modify8,A0
		move.l	#bar1_table,2(A0)
		lea	self_modify9,A0
		move.l	#last_bar1,2(A0)
		lea	self_modify10,A0
		clr.l	2(A0)
		move.w	#16,bar

		lea	self_modify1,A0
		move.l	#spectrum_on,2(A0)
		move.l	#920,D7
		move.l	(sp)+,A0
unk		jmp	spectrum_on

bar:		dc.w	16

regstore0:	ds.l	1
regstore1:	ds.l	1

* --> The height of each bar last time all updates were finished
last_bar1:	dc.w	0
last_bar2:	dc.w	0
last_bar3:	dc.w	0
last_bar4:	dc.w	0
last_bar5:	dc.w	0
last_bar6:	dc.w	0
last_bar7:	dc.w	0
last_bar8:	dc.w	0
last_bar9:	dc.w	0
last_bar10:	dc.w	0
last_bar11:	dc.w	0
last_bar12:	dc.w	0
last_bar13:	dc.w	0
last_bar14:	dc.w	0
last_bar15:	dc.w	0
last_bar16:	dc.w	0

* --> Address lists of individual lightbars in analyser

bar1_table:	dc.l	24008,23688,23368,23048,22728,22408,22088,21768
		dc.l	21448,21128,20808,20488,20168,19848,19528,19208
		dc.l	18888,18568,18248,17928,17608,17288,16968,16648
		dc.l	16328,16008,15688,15368,15048,14728,14408,14088
bar2_table:	dc.l	24024,23704,23384,23064,22744,22424,22104,21784
		dc.l	21464,21144,20824,20504,20184,19864,19544,19224
		dc.l	18904,18584,18264,17944,17624,17304,16984,16664
		dc.l	16344,16024,15704,15384,15064,14744,14424,14104
bar3_table:	dc.l	24032,23712,23392,23072,22752,22432,22112,21792
		dc.l	21472,21152,20832,20512,20192,19872,19552,19232
		dc.l	18912,18592,18272,17952,17632,17312,16992,16672
		dc.l	16352,16032,15712,15392,15072,14752,14432,14112
bar4_table:	dc.l	24040,23720,23400,23080,22760,22440,22120,21800
		dc.l	21480,21160,20840,20520,20200,19880,19560,19240
		dc.l	18920,18600,18280,17960,17640,17320,17000,16680
		dc.l	16360,16040,15720,15400,15080,14760,14440,14120
bar5_table:	dc.l	24048,23728,23408,23088,22768,22448,22128,21808
		dc.l	21488,21168,20848,20528,20208,19888,19568,19248
		dc.l	18928,18608,18288,17968,17648,17328,17008,16688
		dc.l	16368,16048,15728,15408,15088,14768,14448,14128
bar6_table:	dc.l	24056,23736,23416,23096,22776,22456,22136,21816
		dc.l	21496,21176,20856,20536,20216,19896,19576,19256
		dc.l	18936,18616,18296,17976,17656,17336,17016,16696
		dc.l	16376,16056,15736,15416,15096,14776,14456,14136
bar7_table:	dc.l	24064,23744,23424,23104,22784,22464,22144,21824
		dc.l	21504,21184,20864,20544,20224,19904,19584,19264
		dc.l	18944,18624,18304,17984,17664,17344,17024,16704
		dc.l	16384,16064,15744,15424,15104,14784,14464,14144
bar8_table:	dc.l	24072,23752,23432,23112,22792,22472,22152,21832
		dc.l	21512,21192,20872,20552,20232,19912,19592,19272
		dc.l	18952,18632,18312,17992,17672,17352,17032,16712
		dc.l	16392,16072,15752,15432,15112,14792,14472,14152
bar9_table:	dc.l	24080,23760,23440,23120,22800,22480,22160,21840
		dc.l	21520,21200,20880,20560,20240,19920,19600,19280
		dc.l	18960,18640,18320,18000,17680,17360,17040,16720
		dc.l	16400,16080,15760,15440,15120,14800,14480,14160
bar10_table:	dc.l	24088,23768,23448,23128,22808,22488,22168,21848
		dc.l	21528,21208,20888,20568,20248,19928,19608,19288
		dc.l	18968,18648,18328,18008,17688,17368,17048,16728
		dc.l	16408,16088,15768,15448,15128,14808,14488,14168
bar11_table:	dc.l	24096,23776,23456,23136,22816,22496,22176,21856
		dc.l	21536,21216,20896,20576,20256,19936,19616,19296
		dc.l	18976,18656,18336,18016,17696,17376,17056,16736
		dc.l	16416,16096,15776,15456,15136,14816,14496,14176
bar12_table:	dc.l	24104,23784,23464,23144,22824,22504,22184,21864
		dc.l	21544,21224,20904,20584,20264,19944,19624,19304
		dc.l	18984,18664,18344,18024,17704,17384,17064,16744
		dc.l	16424,16104,15784,15464,15144,14824,14504,14184
bar13_table:	dc.l	24112,23792,23472,23152,22832,22512,22192,21872
		dc.l	21552,21232,20912,20592,20272,19952,19632,19312
		dc.l	18992,18672,18352,18032,17712,17392,17072,16752
		dc.l	16432,16112,15792,15472,15152,14832,14512,14192
bar14_table:	dc.l	24120,23800,23480,23160,22840,22520,22200,21880
		dc.l	21560,21240,20920,20600,20280,19960,19640,19320
		dc.l	19000,18680,18360,18040,17720,17400,17080,16760
		dc.l	16440,16120,15800,15480,15160,14840,14520,14200
bar15_table:	dc.l	24128,23808,23488,23168,22848,22528,22208,21888
		dc.l	21568,21248,20928,20608,20288,19968,19648,19328
		dc.l	19008,18688,18368,18048,17728,17408,17088,16768
		dc.l	16448,16128,15808,15488,15168,14848,14528,14208
bar16_table:	dc.l	24136,23816,23496,23176,22856,22536,22216,21896
		dc.l	21576,21256,20936,20616,20296,19976,19656,19336
		dc.l	19016,18696,18376,18056,17736,17416,17096,16776
		dc.l	16456,16136,15816,15496,15176,14856,14536,14216

		dc.l	0
*
* SOUND CHANEL VOLUME DUMP TABLES
*

CHANEL_A 	DC.L $00000000,$00020000,$00020001,$00020002
		DC.L $00030002,$00040001,$00040002,$00050002
		DC.L $00060000,$00060002,$00060003,$00060004
		DC.L $00070002,$00070004,$00070005,$00080002
		DC.L $00080003,$00080004,$00080005,$00090002
		DC.L $00090003,$00090004,$00090005,$00090006
		DC.L $00090007,$000A0003,$000A0004,$000A0005
		DC.L $000A0006,$000A0007,$000B0000,$000B0001
		DC.L $000B0002,$000B0004,$000B0005,$000B0006
		DC.L $000B0007,$000B0008,$000B0008,$000B0009
		DC.L $000B0009,$000C0000,$000C0001,$000C0002
		DC.L $000C0003,$000C0004,$000C0005,$000C0006
		DC.L $000C0008,$000C0008,$000C0009,$000C0009
		DC.L $000C0009,$000C000A,$000D0000,$000D0002
		DC.L $000D0003,$000D0004,$000D0005,$000D0006
		DC.L $000D0007,$000D0008,$000D0008,$000D0009       

		EVEN

*
* SYSTEM VARIABLES FOR ABOVE PROGRAM
*

STATUS		DS.W 1

* --> Area used to count numbers as they flow thorough

spectrum:	ds.b	256

velvet_table:	dc.l	568995,125678,7,2
		dc.l	568995,125678,7,2
		dc.l	568995,125678,7,2

		dc.l	569324,62510,7,3
		dc.l	701911,62181,7,4

		dc.l	568995,125678,7,2
		dc.l	569324,62510,7,3
		dc.l	701911,62181,7,4

		dc.l	0,561792,7,1
		dc.l	568995,125678,7,2
		dc.l	569324,62510,7,3
		dc.l	701911,62181,7,4
		dc.l	0,561792,7,1
		dc.l	0,561792,7,1

		dc.l	9999

intro:          move.w	#$00,$FF8240	* Black
		move.w	#$007,$FF8242	* Blue
		move.w	#$007,$FF825E
		pea	intro_text
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	#$08,-(sp)
		trap	#1
		addq.l	#2,sp
                rts

intro_text:	dc.b	$1B,"E"
		dc.b	"****************************************",13,10
		dc.b	"*					*",13,10
		dc.b	"*       BLACK VELVET -The Sample       *",13,10
		dc.b	"*       ------------------------	*",13,10
		dc.b	"*					*",13,10
		dc.b	"*  Welcome to the Black Velvet Player	*",13,10
		dc.b	"*    Coded entirely by Eddy Deegan.	*",13,10
		dc.b	"*					*",13,10
		dc.b	"* The Spectrum Analyser does actually	*",13,10
		dc.b	"* affect the sound quality a bit, but	*",13,10
		dc.b	"* its better than a simple DEGAS pic!	*",13,10
		dc.b	"* So much work went into it, that I've	*",13,10
		dc.b	"* decided to use it in several demos!!	*",13,10
		dc.b	"*					*",13,10
		dc.b	"* If you like this demo, then look out	*",13,10
		dc.b	"* for other versions of it,  each with	*",13,10
		dc.b	"* a different soundtrack. The best one *",13,10
		dc.b	"* so far is 'Charlie',  which contains *",13,10
		dc.b	"* the whole track.			*",13,10
		dc.b	"* 					*",13,10
		dc.b	"*    This demo is dedicated to Lisa    *",13,10
		dc.b	"****************************************",0

*****************************************************************
*								*
* --> Getfile. Just load the d**n file.				*
*								*
*****************************************************************

* \Takes a filename in file_ptr. Gets length, mallocs memory, loads
*  file and returns address in load_ptr, and length in file_length.

getfile:	move.w	#$00,-(sp)
		move.l	file_ptr,-(sp)
		move.w	#$4E,-(sp)	* Get file info
		trap	#1
		addq.l	#8,sp
		tst.l	D0
		bmi	getfile_err

		lea	dta_buf,A0
		add.l	#26,A0		* Point to length of file
		move.l	(A0),D7		* D7 = length of file
		move.l	D7,file_length

getfile2:	move.l	D7,-(sp)	* Reserve a buffer
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.l	D0
		ble	mem_error

		move.l	D0,load_ptr

		move.w	#$00,-(sp)	* Open file
		move.l	file_ptr,-(sp)	* Address of filename
		move.w	#$3D,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	D0
		bmi	getfile_err
		move.w	D0,handle

		move.l	load_ptr,-(sp)	* Buffer pointer
		move.l	D7,-(sp)	* File length
		move.w	handle,-(sp)
		move.w	#$3F,-(sp)
		trap	#1
		add.l	#12,sp
		tst.l	D0
		bmi	getfile_err

		move.w	handle,-(sp)	* Close file
		move.w	#$3E,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.l	D0
		bmi	getfile_err
		rts

getfile_err:	pea	file_error	* Exit in user mode.
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp
		jmp	to_gem

mem_error:	pea	mem_errormes
		move.w	#$09,-(sp)
		trap	#1
		addq.l	#6,sp

to_gem:		move.w	#$08,-(sp)
		trap	#1
		addq.l	#2,sp

		move.w	res,-(sp)	* Reset res
		move.l	#-1,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		jsr	mon
		move.l	save_stack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		clr.l	-(sp)
		trap	#1

moff:	        move.l  #msoff,-(sp)     * Disable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A00A
		rts
                
mon:		move.l  #mson,-(sp)      * Re-enable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A009
		rts
mson:            dc.b    $08
msoff:           dc.b    $12

load_ptr:	ds.l	1
file_ptr:	ds.l	1
file_length:	ds.l	1
handle:		ds.w	1
physic:		ds.l	1
res:		ds.w	1
save_stack:	ds.l	1
pic_buf:	ds.l	1
dta_buf:	ds.b	44

temp:		ds.b	1
temp1:		ds.b	1
temp2:		ds.b	1
temp3:		ds.b	1

green_led_off:	ds.b	48
green_led_on:	ds.b	48
amber_led_off:	ds.b	48
amber_led_on:	ds.b	48
red_led_off:	ds.b	48
red_led_on:	ds.b	48
blue_led_off:	ds.b	48
blue_led_on:	ds.b	48

red_bar:	ds.l	8
amber_bar:	ds.l	8
green_bar:	ds.l	8

pic_name2:	dc.b	"VELVET.PI1",0
sample_dat:	dc.b	"VELVET",0

file_error:	dc.b	$1B,"EDisk Error! Something is wrong!!",13,10
		dc.b	"You should have the following files....",13,10
		dc.b	"1) VELVET.PRG",13,10,"2) VELVET",13,10
		dc.b	"3) VELVET.PI1",13,10
		dc.b	"If any of these is missing or corrupted",13,10
		dc.b	"you cannot run this demo. I'm sorry,",13,10
		dc.b	"but there really is nothing I can do",13,10
		dc.b	"about it..... try another copy.",13,10,0

mem_errormes:	dc.b	$1B,"EMemory management error! Sorry but ",13,10
		dc.b	"this demo only runs on machines with ",13,10
		dc.b	"1024k or more!",13,10,0


		EVEN

