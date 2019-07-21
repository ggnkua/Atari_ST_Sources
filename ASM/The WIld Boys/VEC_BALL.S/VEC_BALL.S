***************************************************************************
* VECTORBALLS SCREEN FOR STATE OF THE ART				  *
* POWERMAN 26/6/91							  *
* (C) THE WILD BOYS, 1991						  *
* NO PART OF THIS CODE MAY BE USED IN ANY COMMERCIAL OR NON COMMERCIAL    *
* PRODCTION WITHOUT THE PERMISSION OF POWERMAN OF THE WILD BOYS!!!!!      *
* DONT LET US CATCH YOU USING OUR CODE IN YOUR INTROS!  USE IT TO LEARN,  *
* THEN GO WRITE YOUR OWN ROUTS!  THE CODE ISN'T OPTIMISED, ESPECIALLY THE *
* CRAP SPRITE ROUT BUT HEY, YOU EXPECT ME TO GIVE AWAY ALL MY SECRETS.... *
* THE 3D IS ALSO NOT OPTIMISED, I'M GONNA GET IT RUNNING EVEN FASTER!     *
*									  *
* IF USING HALF MEG, REMOVE THE +$80000 ON THE SCREEN ADDRESSES BELOW AND *
* ASSEMBLE TO DISK.  ASSEMBLE TO MEMORY AT YOUR OWN RISK!		  *
*									  *
* All the above comments were written when I actually coded this screen,  *
* which is about 11 months ago!  Thats why the code isn't very fast, if   *
* anyone starts complaining about the rubbish sort rout or any other part *
* of this code, remember it was coded almost a year ago, with no help or  *
* ripped code........ 							  *
***************************************************************************

SCREEN1		EQU $80000-((224*160)*2)+$80000
SCREEN2		EQU $80000-((224*160)*1)+$80000
TIME		EQU 50*10
OBJECTS		EQU 13					Number of defined objects (why not make some more yourself?)

		MOVE.L #SCREEN1,SCR1
		MOVE.L #SCREEN2,SCR2
		JSR INIT				Call initialisation rout
		MOVE.W #$2300,SR
		MOVE.L #SCREEN1,PHYSIC			PHYSIC=screen currently display
		MOVE.L #SCREEN2,LOGIC			LOGIC=screen currently being updated (not visable)
		MOVE.L #ERASEIT2,ERASE_IT		ERASEIT2 and ERASEIT1 contain screen address offsets for the balls on both screens
 		MOVEQ.L #1,D0	
		JSR MUSIC
		MOVE.L #VBL3,$70.W
		JSR MAKE_OBJECT_TAB			Create table containing addresses of object definitions
		JSR MAKE_Y_TAB				Make table of screen Y offsets (0,160,320 etc)
		JSR SET_BALLS				Shift balls, make masks etc
		JSR MAKE_STARS				Initialise starfield rout
		JSR A3_SETSCROLL			Initialise scrolltext rout
		MOVE.L #VBL2,$70.W			Main VBL rout
		JSR MAIN				Main loop
		JMP END					Erm, I've forgot what this does.....

		INCLUDE INIT.S

MUSIC		INCBIN FURY.MUS

VBL3		MOVEM.L D0-A6,-(A7)
		JSR MUSIC+8
		MOVEM.L (A7)+,D0-A6
		RTE

VBL2		CLR.B $FFFFFA1B.W			Stop timer b
		MOVE.B #199,$FFFFFA21.W			Occur on last scanline to remove lower border
		MOVE.B #8,$FFFFFA1B.W			Start timer b
		MOVE.L #TB1,$120.W			Address of timer b interrupt rout
		MOVEM.L D0-A6,-(A7)	
		LEA $FFFF8240.W,A0
		LEA COLS,A1
		REPT 8
		MOVE.L (A1)+,(A0)+
		ENDR
		JSR MUSIC+8
		MOVEM.L (A7)+,D0-A6
		ST VBLFLAG
		RTE

TB1		CLR.B $FFFFFA1B.W
		MOVEM.L D0/A0,-(A7)
		MOVE.W #$FA21,A0
		MOVE.B #18,(A0)				This number (18) can be anything as long as its more than 0!				
		MOVE.B #8,$FFFFFA1B.W
		MOVE.B (A0),D0
		MOVE.L #TB2,$120.W
.L1		CMP.B (A0),D0				Wait until current scanline is drawn		
		BEQ .L1
		CLR.B $FFFF820A.W			60HZ
		MOVEQ.W #3-1,D0				Wait a bit
.L2		NOP
		DBF D0,.L2
		MOVE.B #2,$FFFF820A.W			50HZ to remove lower border
		MOVE.W PAL1,$FFFF8242.W
		CLR.B $FFFFFA1B.W
		MOVE.B #2,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVEM.L (A7)+,D0/A0	
		BCLR #0,$FFFFFA0F.W
		RTE

TB2		MOVE.W PAL1+2,$FFFF8242.W		These timer b routs change the colour of the text
		MOVE.L #TB3,$120.W	
		BCLR #0,$FFFFFA0F.W
		RTE
TB3		MOVE.W PAL1+4,$FFFF8242.W
		MOVE.L #TB4,$120.W
		BCLR #0,$FFFFFA0F.W
		RTE
TB4		MOVE.W PAL1+6,$FFFF8242.W
		MOVE.L #TB5,$120.W
		BCLR #0,$FFFFFA0F.W
		RTE
TB5		MOVE.W PAL1+8,$FFFF8242.W
		MOVE.L #TB6,$120.W
		BCLR #0,$FFFFFA0F.W
		RTE
TB6		MOVE.W PAL1+10,$FFFF8242.W
		MOVE.L #TB7,$120.W
		BCLR #0,$FFFFFA0F.W
		RTE
TB7		MOVE.W PAL1+12,$FFFF8242.W
		MOVE.L #TB8,$120.W
		BCLR #0,$FFFFFA0F.W
		RTE
TB8		MOVE.W PAL1+14,$FFFF8242.W
		MOVE.L #TB9,$120.W
		BCLR #0,$FFFFFA0F.W
		RTE

TB9		MOVE.W PAL1+16,$FFFF8242.W
		MOVE.L #TB10,$120.W
		BCLR #0,$FFFFFA0F.W
		RTE

		;scrolltext palette
PAL1		DC.W $770,$760,$750,$740,$730,$720,$710,$700,$600

TB10		CLR.B $FFFFFA1B.W		This rout clears all colours below the scrolltext
		MOVEM.L D0/A0,-(A7)
		LEA $FFFF8240.W,A0
		MOVEQ.L #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		MOVEM.L (A7)+,D0/A0
		BCLR #0,$FFFFFA0F.W
		RTE

TIMER		DS.W 1
XADD		DS.W 1
YADD		DS.W 1
ZADD		DS.W 1

* Bring object onto the screen by using offsets on the X,Y,Z axis. 
* Different combinations allow you to bring the object on from 8 different
* directions
FIND_DIR	CLR.L XADD			Longword clears YADD aswell			
		CLR.W ZADD
		CMPI.W #0,ENTER			0=appear from left
		BEQ .LEFT
		CMPI.W #1,ENTER			1=right etc...
		BEQ .RIGHT
		CMPI.W #2,ENTER
		BEQ .TOP
.BOTTOM		SUB.W #160,YOFFSET		Move object down 160 pixels
		MOVE.W #8,YADD			Y increment=8 to bring object upwards
		RTS
.TOP		ADD.W #160,YOFFSET		Same as bottom, but opposite values
		MOVE.W #-8,YADD
		RTS
.LEFT		SUB.W #160,XOFFSET		Move object left by 160
		MOVE.W #8,XADD			X increment=8
		RTS
.RIGHT		ADD.W #160,XOFFSET		Same as above but opposite
		MOVE.W #-8,XADD	
		RTS

* Same as previous rout, but sets up variables for moving the object
* off the screen.  Same principle as before, but opposite values
* Note that ZADD has not been used, you can try this out for yourself
* to make the object move into the distance and come towards you.....
FIND_DIR2	CLR.L XADD
		CLR.W ZADD
		CMPI.W #0,LEAVE
		BEQ .LEFT
		CMPI.W #1,LEAVE
		BEQ .RIGHT
		CMPI.W #2,LEAVE
		BEQ .TOP
.BOTTOM		MOVE.W #-8,YADD		-8=move downwards
		RTS
.TOP		MOVE.W #8,YADD
		RTS
.LEFT		MOVE.W #-8,XADD		-8=move left
		RTS
.RIGHT		MOVE.W #8,XADD	
		RTS

* This rout puts the next object onto the screen
ENTER_OBJECT	BSR FIND_DIR			
MOVE_THAT_BODY	MOVEQ.W #(160/8)-1,D0		160 offset, 8 step increment (see FIND_DIR)
.L1		MOVE.W D0,-(A7)
		JSR ROTATE_POINTS
		JSR SORT	
		JSR PERSPECT			
		JSR VECTOR_DRAW16		Display vectorballs
		JSR DO_STARS			Display starfield
		JSR SWAP			Swap screens
		MOVEM.W XANG,D0-D2		D0-D2=rotation angles
		ADD.W D0,XROT			Increment x angle
		ADD.W D1,YROT			Increment y angle
		ADD.W D2,ZROT			Increment z angle
		MOVEM.W XADD,D0-D2		D0-D2=x,y,z increments (to move object onto screen)
		ADD.W D0,XOFFSET		Increment X offset
		ADD.W D1,YOFFSET		Same for y 
		ADD.W D2,ZOFFSET		Same for z (always 0, but I was gonna use Z increments)
		MOVE.W (A7)+,D0	
		DBF D0,.L1
		RTS

LEAVE_OBJECT	BSR FIND_DIR2			Lets get the hell out of here! In other words, remove object from screen
		BRA MOVE_THAT_BODY		I love TECHNOTRONIC

DO_OBJECT	MOVE.W #TIME,TIMER		TIME=time to display object (50=1 second)
.L1		JSR ROTATE_POINTS
		JSR SORT
		JSR PERSPECT
		JSR VECTOR_DRAW16		Display sprites
		JSR DO_STARS	
		JSR SWAP
		MOVEM.W XANG,D0-D2
		ADD.W D0,XROT			}
		ADD.W D1,YROT			}rotation angles
		ADD.W D2,ZROT			}
		SUBQ.W #1,TIMER
		TST.W TIMER
		BLE .L2
		CMPI.B #57,$FFFFFC02.W
		BNE .L1
		ADDQ.L #4,A7
		MOVE.L #END,(A7)
.L2		RTS

MAIN		MOVE.L OBJECT_POS,A0
		TST.L (A0)
		BPL .L1				-1=end of list
		LEA OBJECT_LIST,A0
.L1		MOVE.L (A0)+,A1			A1=address of next object data
		MOVE.L A0,OBJECT_POS		Save position in object table
		JSR MAKE_NEXT_WAVE		Make wave (set colours, rotation angles etc but no pre-calculation!)
		TST.W TYPE			TYPE=type of ball (big or small). This screen didn't end up using this feature, add it yourself!	
		BEQ .L2		
		MOVE.W #160-16,XCENT		Never this (it would have been used for 32x32 balls which I didn't use)
		MOVE.W #100-16,YCENT	
		BRA .L3
.L2		MOVE.W #160-8,XCENT		Always this, XCENT and YCENT=screen x,y centre (0,0=top left)
		MOVE.W #100-8,YCENT	
.L3		BSR ENTER_OBJECT		Put object on screen
		BSR DO_OBJECT			Display it for a while
		BSR LEAVE_OBJECT		Get it off (oooer2r!)
		BRA MAIN			Next object please......

SWAP		MOVE.L LOGIC,A4
		LEA 160*201(A4),A4
		JSR A3_SCROLL			Display scrolltext
		MOVEM.L PHYSIC,D0-D1
		MOVE.L D1,D2
		LSR.W #8,D2			
		MOVE.L D2,$FFFF8200.W		Change screen address
		CLR.B VBLFLAG
.L1		TST.B VBLFLAG
		BEQ .L1				Wait for VBL
		EXG D0,D1			Swap screen addresses
		MOVEM.L D0-D1,PHYSIC		Save screen addresses
		LEA ERASE_IT,A0			Get correct address of ball position data (so the balls are erased on the correct screen!)
		CMPI.L #ERASEIT1,(A0)
		BEQ .L2
		MOVE.L #ERASEIT1,(A0)
		RTS
.L2		MOVE.L #ERASEIT2,(A0)
		RTS

PHYSIC		DS.L 1
LOGIC		DS.L 1

**************************************************************************
*                             STARFIELD ROUTINE                          *
* CALL MAKE_STARS TO INITIALISE, THEN CALL DO_STARS TO DISPLAY STARS     *
* You best not use dis code even though its shit......			 *
**************************************************************************

DO_STARS	MOVE.L LOGIC,A0
		BSR ERASE_STARS
		LEA STARS,A1
		MOVE.W #(180/4)-1,D0		180 stars, 4 taken at a time
		MOVEQ.W #0,D7
.L1		MOVEM.L (A1)+,A2-A5		4 stars
		CMP.L #LINE_DATA_END,A2		End of star data?
		BLT .L3
		MOVE.L #LINE_DATA,-16(A1)
		LEA LINE_DATA,A2
.L3		MOVEM.W (A2),D1-D2		D1=screen offset, D2=value to OR
		TST.W D1
		BMI .L4				negative if off-screen
		OR.W D2,(A0,D1.W)
		MOVE.W D1,(A6)+
		BRA .L5
.L4		MOVE.W D7,(A6)+
* do second star
.L5		CMP.L #LINE_DATA_END,A3
		BLT .L33
		MOVE.L #LINE_DATA,-12(A1)
		LEA LINE_DATA,A3
.L33		MOVEM.W (A3),D1-D2
		TST.W D1
		BMI .L44
		OR.W D2,(A0,D1.W)
		MOVE.W D1,(A6)+
		BRA .L55
.L44		MOVE.W D7,(A6)+
* third
.L55		CMP.L #LINE_DATA_END,A4
		BLT .L333
		MOVE.L #LINE_DATA,-8(A1)
		LEA LINE_DATA,A4
.L333		MOVEM.W (A4),D1-D2
		TST.W D1
		BMI .L444
		OR.W D2,(A0,D1.W)
		MOVE.W D1,(A6)+
		BRA .L555
.L444		MOVE.W D7,(A6)+
* and fourth before reading more data.  
* Not much processor time saved in using 4 routs, but originally I had
* to use 4 routs for irrelevant reasons.......I changed my plans and
* couldn't be bothered to use 1 rout instead of 4.........
.L555		CMP.L #LINE_DATA_END,A5
		BLT .L3333
		MOVE.L #LINE_DATA,-4(A1)
		LEA LINE_DATA,A5
.L3333		MOVEM.W (A5),D1-D2
		TST.W D1
		BMI .L4444
		OR.W D2,(A0,D1.W)
		MOVE.W D1,(A6)+
		BRA .L5555
.L4444		MOVE.W D7,(A6)+
.L5555		DBF D0,.L1
* Dis next bit moves the stars, 4,8,12,16 are the 4 different speeds
* Note that the speed MUST be a multiple of 4!!! Change the speeds if
* you want.....
		LEA STARS,A0
OFFSET		SET 0
		REPT 15
		MOVEM.L OFFSET(A0),D0-D7/A1-A4
		ADDQ.L #4,D0
		ADDQ.L #8,D1
		ADD.L #12,D2
		ADD.L #16,D3
		ADDQ.L #4,D4
		ADDQ.L #8,D5
		ADD.L #12,D6
		ADD.L #16,D7
		ADDQ.L #4,A1
		ADDQ.L #8,A2
		LEA 12(A3),A3
		LEA 16(A4),A4
		MOVEM.L D0-D7/A1-A4,OFFSET(A0)
OFFSET		SET OFFSET+(12*4)
		ENDR
		RTS

ERASE_STARS	CMPA.L #SCREEN1,A0		Which STAR_ERASE shall I use?
		BEQ .L1
		LEA STAR_ERASE2,A1		For SCREEN2
		BRA .L2
.L1		LEA STAR_ERASE1,A1		For SCREEN1
.L2		MOVEQ.W #0,D0
		MOVE.L A1,A6
		ADDQ.L #6,A0
		REPT 25
		MOVEM.W (A1)+,D1-D7		
		MOVE.W D0,(A0,D1.W)		These MOVE.W's delete the stars
		MOVE.W D0,(A0,D2.W)
		MOVE.W D0,(A0,D3.W)
		MOVE.W D0,(A0,D4.W)
		MOVE.W D0,(A0,D5.W)
		MOVE.W D0,(A0,D6.W)
		MOVE.W D0,(A0,D7.W)
		ENDR
		MOVEM.W (A1)+,D1-D5		Delete last 5 stars
		MOVE.W D0,(A0,D1.W)
		MOVE.W D0,(A0,D2.W)
		MOVE.W D0,(A0,D3.W)
		MOVE.W D0,(A0,D4.W)
		MOVE.W D0,(A0,D5.W)
		RTS

* This routine makes the data for the stars.  Basically, a line going from
* the centre of the screen to the top is created in X,Y coords (MAKE_LINE).
* All 184 points in the line are then stored in memory, as a screen offset
* (a word value) followed by another word - the value to OR (1,2,4,8 etc)
* The line (all 184 points) are rotated about the Z axis and the points
* stored again.  This happens 180 times so the line is rotated right around
* to its starting point.  If you dont understand, imagine a helicopter
* rotor spinning, then imagine you are looking down on the helicopter....
* Note that 180 rotations are used because the z increment is 2 
* (360/2=180!)
MAKE_STARS	MOVE.W #160,XCENT		Screen centre
		MOVE.W #100,YCENT
		JSR MAKE_LINE			Create line
		BSR MAKE_LINE_DATA		Rotate line and store points
		BSR SET_STARS			Set starting points in star data for the 180 stars
		BSR SET_ERASE			Clear STAR_ERASE1 and 2
		RTS

SET_ERASE	LEA STAR_ERASE1,A0	
		MOVE.W #180-1,D0
		MOVEQ.L #0,D1
.L1		MOVE.L D1,(A0)+
		DBF D0,.L1
		RTS

STAR_ERASE1	DS.W 180			180 stars
STAR_ERASE2	DS.W 180

SET_STARS	LEA STARS,A0
		LEA LINE_DATA,A1
		MOVE.W #180-1,D0
.L1		CMP.L #LINE_DATA_END,A1
		BLT .L2
		SUB.L #LINE_DATA_END,A1
		ADD.L #LINE_DATA,A1
		BRA .L1
.L2		MOVE.L A1,(A0)+
		ADDA.L #(184*4)+(4*16),A1
		DBF D0,.L1
		RTS

STARS		DS.L 180			180 STARS
	
MAKE_LINE_DATA	MOVE.W #0,XOFFSET
		MOVE.W #0,YOFFSET
		MOVE.W #0,ZOFFSET
		MOVE.W #0,XROT
		MOVE.W #0,YROT
		MOVE.W #0,ZROT
		LEA LINE_DATA,A0
		MOVE.W #180-1,D0
.L1		MOVEM.L A0/D0,-(A7)
		JSR ROTATE_POINTS
		JSR PERSPECT
		ADDQ.W #2,ZROT			Rotate round z axis
		MOVEM.L (A7)+,A0/D0
		BSR STORE_DATA
		DBF D0,.L1
		RTS

STORE_DATA	MOVE.W #184-1,D1		184 points in line
		LEA SCREEN,A1			A1=place to store screen offset and OR word
.L1		MOVEM.W (A1)+,D2-D3
		TST.W D2			Clipping
		BMI .L2
		TST.W D3
		BMI .L2
		CMPI.W #319,D2
		BGT .L2
		CMPI.W #199,D3
		BGT .L2				
		MULU #160,D3			y*160
		MOVE.W D2,D4
		AND.W #$FFF0,D2			Make multiple of 16
		LSR.W #1,D2			Divide by 2 for screen offset (x offset)
		ADD.W D2,D3			Add y offset
		MOVE.W D3,(A0)+			Store it
		NOT.W D4
		AND.W #15,D4			
		MOVEQ.W #0,D5
		BSET D4,D5			d5=word to OR
		MOVE.W D5,(A0)+			Store it
.L3		DBF D1,.L1
		RTS
.L2		MOVE.L #-1,(A0)+		Point off screen so store -1 (so that point aint drawn)
		BRA .L3

LINE_DATA	DS.L 184*180			.W OFFSET, .W OR
LINE_DATA_END

MAKE_LINE	MOVE.W #184-1,NUM_POINTS	create a line with 184 points (184 makes sure line reaches edge of screen)
		LEA WORLD,A0			A0=address to store points (world coordinate system)
		MOVE.W #184-1,D0
		MOVEQ.W #0,D1			Y
.L1		MOVE.W #0,(A0)+			X is 0
		MOVE.W D1,(A0)+
		MOVE.W #0,(A0)+			Z is 0
		ADD.W #1,D1
		DBF D0,.L1
		RTS

* Create a table of y screen offsets (0,160,320 etc)
MAKE_Y_TAB	LEA Y_TAB,A0			
		MOVE.W #200-1,D0
		MOVE.W #0,D1
.L1		MOVE.W D1,(A0)+
		ADD.W #160,D1
		DBF D0,.L1
		RTS

OBJECT_LIST	DS.L OBJECTS		Contains addresses of all objects
		DC.L -1

OBJECT_POS	DS.L 1

* This creates the object table
MAKE_OBJECT_TAB	LEA OBJECT_LIST,A0
		LEA OBJECT1,A1
		MOVE.W #OBJECTS-1,D0
.L1		MOVE.L A1,(A0)+
		MOVE.W (A1)+,D1
		MULU #6,D1				Each ball=6 bytes in coordinate data (x,y,z)
		LEA (A1,D1.W),A1			
		LEA 28(A1),A1				A1=address of next object (28 bytes used for colours, rotation angles etc)
		DBF D0,.L1
		MOVE.L #OBJECT_LIST,OBJECT_POS
		RTS

TYPE		DS.W 1			Not used, was going to be ball type
ENTER		DS.W 1			Direction to bring object onto screen
LEAVE		DS.W 1			Direction to get rid of object
COLS		DC.W 0			16 colour palette 
		DS.W 5			5 ball cols
		DC.W 0,0
		DC.W $666				STAR COLOUR
COLS2		DS.W 5			5 ball cols (same as before, used to make balls appear infront of stars)
		DC.W 0,0

MAKE_NEXT_WAVE	;A1=OBJECT1,OBJECT2 etc, address of next object data
		LEA WORLD,A0
		MOVE.W (A1)+,D0				D0=NUMBER OF POINTS
		SUBQ.W #1,D0
		MOVE.W D0,D1
		MOVE.W D1,NUM_POINTS			Number of points in next wave
.COPY_X		MOVE.W (A1)+,(A0)			Copy x coords	
		ADDQ.L #6,A0				6 bytes used for each point (x,y,z)
		DBF D0,.COPY_X

		LEA WORLD+2,A0				Copy y coords
		MOVE.W D1,D0
.COPY_Y		MOVE.W (A1)+,(A0)
		ADDQ.L #6,A0
		DBF D0,.COPY_Y

		LEA WORLD+4,A0				Copy z coords
		MOVE.W D1,D0
.COPY_Z		MOVE.W (A1)+,(A0)
		ADDQ.L #6,A0
		DBF D0,.COPY_Z
		
		MOVE.W (A1)+,TYPE			Ball type (not used, as you probably know by now!)
		MOVE.W (A1)+,XANG			X rotation angle increments
		MOVE.W (A1)+,YANG			y    "       "
		MOVE.W (A1)+,ZANG			z    "       "
		MOVE.W (A1)+,ENTER			Direction for object to enter
		MOVE.W (A1)+,LEAVE			Direction for object to leave
		MOVE.W (A1)+,XOFFSET			Offset on x axis
		MOVE.W (A1)+,YOFFSET			   "	  y   "
		MOVE.W (A1)+,ZOFFSET			   "	  z   "
		MOVEM.W (A1)+,D1-D5			5 ball colours
		MOVEM.W D1-D5,COLS+2
		MOVEM.W D1-D5,COLS2
		MOVEQ.L #0,D0
		MOVE.L D0,XROT				Clear rotation angles (rotation angle increments are added to this to rotate object)
		MOVE.W D0,ZROT
		RTS

XANG		DS.W 1					X ANGLE
YANG		DS.W 1					Y   "
ZANG		DS.W 1					Z   "

********************************** 3D ROUTINES ****************************
* CALL ROTATE_POINTS, SORT (IF VECTORBALLS), PERSPECT			  * 
* SCREEN = SCREEN X,Y COORDS (0,0=TOP LEFT)				  *
***************************************************************************
POINTS		EQU 184			Maximum number of points

DIST		DC.W 256		Perspective
WORLD		DS.W POINTS*3		X,Y,Z coords for each point		
VIEW		DS.W POINTS*4		X,Y,Z coords for each rotated point
;					Extra word for vectorball col etc
SCREEN		DS.W POINTS*2		Screen X,Y coords
NUM_POINTS	DS.W 1			Number of points in current object
MATRIX		DS.W 9
XROT		DS.W 1			X rotation angle
YROT		DS.W 1			Y rotation angle
ZROT		DS.W 1			Z rotation angle
XOFFSET		DS.W 1			Offset on X axis
YOFFSET		DS.W 1			Offset on Y axis
ZOFFSET		DS.W 1			Offset on Z axis
SINCOS		DS.W 6			Space for x,y,z sine/cosine

ROTATE_POINTS	LEA SINTAB,A0
		LEA 90*2(A0),A2		COSINE=SINE+90 DEGREES
		LEA SINCOS,A1
		MOVEM.W XROT,D0-D2	D0=X ANGLE,D1=Y,D2=Z
		MOVE.W #360,D6
		MOVE.W #-360,D7

		CMP.W D7,D0		Make sure angles are in range
		BGT .L2
		ADD.W D6,D0	
		BRA .L3	
.L2		CMP.W D6,D0
		BLT .L3
		SUB.W D6,D0

.L3		CMP.W D7,D1
		BGT .L4
		ADD.W D6,D1
		BRA .L5	
.L4		CMP.W D6,D1
		BLT .L5
		SUB.W D6,D1

.L5		CMP.W D7,D2
		BGT .L6
		ADD.W D6,D2
		BRA .L7
.L6		CMP.W D6,D2
		BLT .L7
		SUB.W D6,D2

.L7		MOVEM.W D0-D2,XROT
		TST.W D0			Get correct + value if -
		BPL .L8
		ADD.W D6,D0
.L8		TST.W D1	
		BPL .L9
		ADD.W D6,D1
.L9		TST.W D2
		BPL .L10
		ADD.W D6,D2

.L10		ADD.W D0,D0
		ADD.W D1,D1
		ADD.W D2,D2
		MOVE.W (A0,D0.W),(A1)+		Sine x   (0)
		MOVE.W (A2,D0.W),(A1)+		Cosine x (2)
		MOVE.W (A0,D1.W),(A1)+		Sine y   (4)
		MOVE.W (A2,D1.W),(A1)+		Cosine y (6)
		MOVE.W (A0,D2.W),(A1)+		Sine z   (8)
		MOVE.W (A2,D2.W),(A1)		Cosine z (10)
		LEA -10(A1),A1

		MOVE.W 4(A1),D0			SIN(Y)
		MOVE.W D0,D1		
		MULS 8(A1),D0			SIN(Z)*SIN(Y)
		LSL.L #2,D0
		SWAP D0				D0=SIN(Z)*SIN(Y)
		 	
		NEG.W D1			-SIN(Y)
		MULS 10(A1),D1			COS(Z)
		LSL.L #2,D1
		SWAP D1				D1=-SIN(Y)*COS(Z)

		LEA MATRIX,A2
;MATRIX(1,1) 	
		MOVE.W 10(A1),D2
		MOVE.W D2,D6
		MULS 6(A1),D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,(A2)+
;MATRIX(1,2)	
		MOVE.W (A1),D2
		MULS D1,D2
		MOVE.W 8(A1),D3
		MOVE.W D3,D4
		MOVE.W D4,D5
		MULS 2(A1),D3
		SUB.L D2,D3
		LSL.L #2,D3
		SWAP D3
		MOVE.W D3,(A2)+		
;MATRIX(1,3)	
		MOVE.W 2(A1),D2
		MULS D1,D2
		MULS (A1),D4
		ADD.L D2,D4
		LSL.L #2,D4
		SWAP D4
		MOVE.W D4,(A2)+		
;MATRIX(2,1)	
		NEG.W D5
		MULS 6(A1),D5
		LSL.L #2,D5
		SWAP D5
		MOVE.W D5,(A2)+
;MATRIX(2,2)	
		MOVE.W D6,D7
		MULS 2(A1),D6
		MOVE.W (A1),D3
		MULS D0,D3
		SUB.L D3,D6
		LSL.L #2,D6
		SWAP D6
		MOVE.W D6,(A2)+
;MATRIX(2,3)	
		MULS (A1),D7
		MOVE.W 2(A1),D3
		MOVE.W D3,D6
		MULS D0,D3
		ADD.L D3,D7
		LSL.L #2,D7
		SWAP D7
		MOVE.W D7,(A2)+
;MATRIX(3,1)	
		MOVE.W 4(A1),(A2)+
;MATRIX(3,2)	
		MOVE.W 6(A1),D2
		MOVE.W D2,D4
		NEG.W D2
		MULS (A1),D2
		LSL.L #2,D2
		SWAP D2
		MOVE.W D2,(A2)+
;MATRIX(3,3)	
		MULS D6,D4
		LSL.L #2,D4
		SWAP D4
		MOVE.W D4,(A2)+

		MOVE.W NUM_POINTS,D7
		LEA WORLD,A0
		LEA VIEW,A1
		LEA MATRIX,A2
		LEA XOFFSET,A4
.L1		MOVE.L A2,A3
		MOVEM.W (A0),D0-D2		D0-D2=x,y,z coords
		ADD.W (A4),D0
		ADD.W 2(A4),D1
		ADD.W 4(A4),D2
		MOVE.W D0,D3
		MOVE.W D1,D4
		MOVE.W D2,D5		
.CALC_X_COORD	MULS (A3)+,D0			
		MULS (A3)+,D1
		MULS (A3)+,D2
		ADD.L D0,D1
		ADD.L D2,D1
		LSL.L #2,D1
		SWAP D1
		MOVE.W D1,(A1)+
.CALC_Y_COORD	MULS (A3)+,D3
		MULS (A3)+,D4
		MULS (A3)+,D5
		ADD.L D3,D4
		ADD.L D5,D4
		LSL.L #2,D4
		SWAP D4 
		MOVE.W D4,(A1)+
.CALC_Z_COORD	MOVEM.W (A0)+,D3-D5
		ADD.W (A4),D3
		ADD.W 2(A4),D4
		ADD.W 4(A4),D5
		MULS (A3)+,D3
		MULS (A3)+,D4
		MULS (A3)+,D5
		ADD.L D3,D4
		ADD.L D5,D4
		LSL.L #2,D4
		SWAP D4
		MOVE.W D4,(A1)+
		ADDQ.L #2,A1
		DBF D7,.L1
		RTS

XCENT		DS.W 1
YCENT		DS.W 1

* This routine gives the object perspective, so the balls closest to
* you are spread out more than the balls further away which are closer
* to each other.......it works by multiplying the x and y coordinates
* of each ball by 256 and dividing by the Z coordinate plus 128
* the 128 in DIST can be changed for different perspectives....
PERSPECT	MOVEM.W XCENT,D0-D1
		LEA VIEW,A0
		LEA SCREEN,A1
		MOVE.W NUM_POINTS,D2
		MOVEQ.W #8,D6				2 to the power of 8=256
		MOVE.W DIST,D7				D7=Perspective
.L11		MOVEM.W (A0)+,D3-D5
		ADDQ.L #2,A0
		EXT.L D3			Must extend or division wont work if bits set in high word
		EXT.L D4
		ASL.L D6,D3			Multiply X and Y by 256		
		ASL.L D6,D4			

		ADD.W D7,D5			Add perspective to Z coord
		DIVS D5,D3			DIVIDE X BY 128+Z
		DIVS D5,D4			DIVIDE Y BY 128+Z
		NEG.W D4			Invert y
		ADD.W D0,D3			Add X and Y centres
		ADD.W D1,D4
			
		MOVEM.W D3-D4,(A1)
		ADDQ.L #4,A1
		DBF D2,.L11		
		RTS

* This is my really shit sort routine, it uses the bubble sort method
* and is pretty slow.  Phantom of Inner Circle said I should get rid of
* this routine and use a tree sort, which I'll do........but it is, quote
* from Phantom 'a bitch to code' (and I can confirm this!)
SORT		LEA VIEW,A1
		MOVE.W NUM_POINTS,D0
		SUBQ.W #1,D0
.L15		MOVE.W D0,D7
		MOVEQ.W #0,D6
		MOVE.L A1,A0
.L12		MOVE.W 4(A0),D1
		CMP.W 12(A0),D1
		BGE .L13			If less, swap values
		MOVEM.L (A0)+,D1-D2		First x,y coords
		MOVEM.L (A0),D3-D4		Second x,y coords
		MOVEM.L D3-D4,-8(A0)		}swap the places of
		MOVEM.L D1-D2,(A0)		}the two x and y coords
		ST D6				D6=flag to tell routine that sort has occured
		DBF D7,.L12
		TST.W D6
		BNE .L15			If d6=0 no sort done, so coordinates are sorted
		RTS	
.L13		ADDQ.L #8,A0
		DBF D7,.L12
.L14		TST.W D6
		BNE .L15
		RTS

SINTAB		DC.W 0,286,572,857,1143,1428,1713,1997,2280
		DC.W 2563,2845,3126,3406,3686,3964,4240,4516
		DC.W 4790,5063,5334,5604,5872,6138,6402,6664
		DC.W 6924,7182,7438,7692,7943,8192,8438,8682
		DC.W 8923,9162,9397,9630,9860,10087,10311,10531
		DC.W 10749,10963,11174,11381,11585,11786,11982,12176
		DC.W 12365,12551,12733,12911,13085,13255,13421,13583
		DC.W 13741,13894,14044,14189,14330,14466,14598,14726
		DC.W 14849,14962,15082,15191,15296,15396,15491,15582
		DC.W 15668,15749,15826,15897,15964,16026,16083,16135
		DC.W 16182,16225,16262,16294,16322,16344,16362,16374
		DC.W 16382,16384
	
		DC.W 16382,16374,16362,16344,16322,16294,16262,16225
		DC.W 16182
		DC.W 16135,16083,16026,15964,15897,15826,15749,15668
		DC.W 15582,15491,15396,15296,15191,15082,14962,14849
		DC.W 14726,14598,14466,14330,14189,14044,13894,13741
		DC.W 13583,13421,13255,13085,12911,12733,12551,12365
		DC.W 12176,11982,11786,11585,11381,11174,10963,10749
		DC.W 10531,10311,10087,9860,9630,9397,9162,8923
		DC.W 8682,8438,8192,7943,7692,7438,7182,6924
		DC.W 6664,6402,6138,5872,5604,5334,5063,4790
		DC.W 4516,4240,3964,3686,3406,3126,2845,2563
		DC.W 2280,1997,1713,1428,1143,857,572,286,0

		DC.W -286,-572,-857,-1143,-1428,-1713,-1997,-2280
		DC.W -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
		DC.W -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
		DC.W -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
		DC.W -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
		DC.W -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
		DC.W -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
		DC.W -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
		DC.W -14849,-14962,-15082,-15191,-15296,-15396,-15491,-15582
		DC.W -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
		DC.W -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
		DC.W -16382,-16384

		DC.W -16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
		DC.W -16182
		DC.W -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
		DC.W -15582,-15491,-15396,-15296,-15191,-15082,-14962,-14849
		DC.W -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
		DC.W -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
		DC.W -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
		DC.W -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
		DC.W -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
		DC.W -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
		DC.W -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
		DC.W -2280,-1997,-1713,-1428,-1143,-857,-572,-286,-0
	
* DUPLICATE FIRST 90 ENTRIES FOR COSINE OVERLAP
		
		DC.W 0,286,572,857,1143,1428,1713,1997,2280
		DC.W 2563,2845,3126,3406,3686,3964,4240,4516
		DC.W 4790,5063,5334,5604,5872,6138,6402,6664
		DC.W 6924,7182,7438,7692,7943,8192,8438,8682
		DC.W 8923,9162,9397,9630,9860,10087,10311,10531
		DC.W 10749,10963,11174,11381,11585,11786,11982,12176
		DC.W 12365,12551,12733,12911,13085,13255,13421,13583
		DC.W 13741,13894,14044,14189,14330,14466,14598,14726
		DC.W 14849,14962,15082,15191,15296,15396,15491,15582
		DC.W 15668,15749,15826,15897,15964,16026,16083,16135
		DC.W 16182,16225,16262,16294,16322,16344,16362,16374
		DC.W 16382,16384

**************************** END OF 3D ROUTINES ***************************

************************ VECTORBALL SPRITE ROUTINES ***********************
 
SET_BALLS	LEA BALLGRAFIX,A0
		LEA 12*16(A0),A1		
		MOVEQ.W #15-1,D0		store 15 shifted versions of vectorball
.L1		MOVEQ.W #16-1,D2		each ball is 16 lines high
		MOVEA.L A1,A2
.L2		MOVE.L (A0)+,(A1)+		Copy sprite
		MOVE.W (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+		
		MOVE.W (A0)+,(A1)+		
		DBF D2,.L2
		MOVEQ.W #16-1,D2
.L3		AND.W #$FF00,SR
		ROXR.W (A2)			Shift sprite
		ROXR.W 6(A2)
		AND.W #$FF00,SR
		ROXR.W 2(A2)
		ROXR.W 8(A2)
		AND.W #$FF00,SR
		ROXR.W 4(A2)
		ROXR.W 10(A2)
		LEA 12(A2),A2			
		DBF D2,.L3		
		DBF D0,.L1
* Next bit makes the masks for each ball sprite
		LEA BALLGRAFIX,A0		
		LEA BALLMASK,A1
		MOVEQ.W #16-1,D0		16 masks to make
.L4		MOVEQ.W #16-1,D1		each 16 lines high
.L5		MOVE.W (A0)+,D2	
		OR.W (A0)+,D2
		OR.W (A0)+,D2		
		NOT.W D2			D2=mask for current line
		MOVE.W D2,(A1)+			Store twice so MOVE.L, MOVE.W can be used to plot the mask (quicker than 3 MOVE.W's)
		MOVE.W D2,(A1)+
		MOVE.W (A0)+,D2
		OR.W (A0)+,D2
		OR.W (A0)+,D2
		NOT.W D2
		MOVE.W D2,(A1)+
		MOVE.W D2,(A1)+
		DBF D1,.L5	
		DBF D0,.L4
		RTS

BALLGRAFIX	INCBIN VEC1.DAT
		DS.B (12*16)*15
BALLMASK	DS.B (12*16)*16
* This table contains the addresses of each ball (16 total) followed
* by their mask addresses
BALL_ADS	DC.L BALLGRAFIX,BALLMASK,BALLGRAFIX+192,BALLMASK+128
		DC.L BALLGRAFIX+(192*2),BALLMASK+(128*2),BALLGRAFIX+(192*3),BALLMASK+(128*3)
		DC.L BALLGRAFIX+(192*4),BALLMASK+(128*4),BALLGRAFIX+(192*5),BALLMASK+(128*5)
		DC.L BALLGRAFIX+(192*6),BALLMASK+(128*6),BALLGRAFIX+(192*7),BALLMASK+(128*7)
		DC.L BALLGRAFIX+(192*8),BALLMASK+(128*8),BALLGRAFIX+(192*9),BALLMASK+(128*9)
		DC.L BALLGRAFIX+(192*10),BALLMASK+(128*10),BALLGRAFIX+(192*11),BALLMASK+(128*11)
		DC.L BALLGRAFIX+(192*12),BALLMASK+(128*12),BALLGRAFIX+(192*13),BALLMASK+(128*13)
		DC.L BALLGRAFIX+(192*14),BALLMASK+(128*14),BALLGRAFIX+(192*15),BALLMASK+(128*15)

Y_TAB		DS.W 200

* Shit sprite routine, can be much faster but figure it out for yourself,
* I'm not giving away all my best routs so any lamers who say I dont know
* how to make a fast sprite rout should flush themselves down a toilet....
VECTOR_DRAW16	MOVE.L LOGIC,A5
		BSR ERASE_BALLS
		LEA BALL_ADS,A4
		LEA SCREEN,A0
		MOVEA.L ERASE_IT,A6
.L2		MOVEM.W (A0)+,D0-D1
			
* Clipping (or 'is it on the screen or not?')
		TST.W D0
		BMI .L1
		CMPI.W #319-16,D0
		BGT .L1
		TST.W D1
		BMI .L1
		CMPI.W #199-16,D1
		BGT .L1

		LEA Y_TAB,A1
		ADD.W D1,D1
		MOVE.W (A1,D1.W),D1		D1*160
		MOVE.W D0,D2	
		AND.W #$FFF0,D0			Make multiple of 16
		AND.W #$000F,D2
		LSR.W #1,D0			d0=screen offset (x)
		ADD.W D0,D1			Add x offset of y kffset
		LSL.W #3,D2		
		MOVE.L (A4,D2.W),A2		A2=source address of ball gfx
		MOVE.L 4(A4,D2.W),A1		A1=source address of mask data
	
		LEA (A5,D1.W),A3		A3=destination screen address
		MOVE.L A3,(A6)+			Save position so ball can be deleted next time the current logic screen is updated 
		MOVE.W D7,-(A7)
OFFSET		SET 0
* Plot mask (yes I know it can be done much faster so speed the damn
* thing up your damn self and stop complaining!!!!)
		REPT 4
		MOVEM.L (A1)+,D0-D7
		AND.L D0,OFFSET(A3)
		AND.W D0,OFFSET+4(A3)
		AND.L D1,OFFSET+8(A3)
		AND.W D1,OFFSET+12(A3)
OFFSET		SET OFFSET+160
		AND.L D2,OFFSET(A3)
		AND.W D2,OFFSET+4(A3)
		AND.L D3,OFFSET+8(A3)
		AND.W D3,OFFSET+12(A3)
OFFSET		SET OFFSET+160
		AND.L D4,OFFSET(A3)
		AND.W D4,OFFSET+4(A3)
		AND.L D5,OFFSET+8(A3)
		AND.W D5,OFFSET+12(A3)
OFFSET		SET OFFSET+160
		AND.L D6,OFFSET(A3)
		AND.W D6,OFFSET+4(A3)
		AND.L D7,OFFSET+8(A3)
		AND.W D7,OFFSET+12(A3)
OFFSET		SET OFFSET+160
		ENDR
* Plot ball (see above comment)
OFFSET		SET 0
		REPT 5
		MOVEM.L (A2)+,D0-D7
		OR.L D0,OFFSET(A3)
		OR.W D1,OFFSET+8(A3)
		SWAP D1
		OR.W D1,OFFSET+4(A3)
		OR.L D2,OFFSET+10(A3)
OFFSET		SET OFFSET+160
		OR.L D3,OFFSET(A3)
		OR.W D4,OFFSET+8(A3)
		SWAP D4
		OR.W D4,OFFSET+4(A3)
		OR.L D5,OFFSET+10(A3)
OFFSET		SET OFFSET+160
		OR.L D6,OFFSET(A3)
		OR.W D7,OFFSET+8(A3)
		SWAP D7
		OR.W D7,OFFSET+4(A3)
		MOVE.L (A2)+,D2
		OR.L D2,OFFSET+10(A3)
OFFSET		SET OFFSET+160	
		ENDR	
		MOVEM.L (A2)+,D0-D2
		OR.L D0,OFFSET(A3)
		OR.W D1,OFFSET+8(A3)
		SWAP D1
		OR.W D1,OFFSET+4(A3)
		OR.L D2,OFFSET+10(A3)

		MOVE.W (A7)+,D7
.L1		DBF D7,.L2
		RTS	

ERASE_IT	DS.L 1
ERASEIT1 	DCB.L 30,SCREEN1		
ERASEIT2	DCB.L 30,SCREEN2

ERASE_BALLS	MOVE.W NUM_POINTS,D0
		MOVE.W D0,D7
		MOVEQ.L #0,D1
		MOVEA.L ERASE_IT,A0		A0=address of ball positions on current logic screen
.L1		MOVEA.L (A0)+,A1
OFFSET		SET 0
		REPT 16
		MOVE.L D1,OFFSET(A1)
		MOVE.W D1,OFFSET+4(A1)

		MOVE.L D1,OFFSET+8(A1)
		MOVE.W D1,OFFSET+12(A1)

OFFSET		SET OFFSET+160
		ENDR
		DBF D0,.L1
		RTS

**************************************************************************
* 32 X ?, 1 BITPLANE, SPEED 8 PIXELS UNBUFFERED SCROLLINE ROUTINE	 *
* CODED ON 16/2/91 BY POWERMAN OF TWB					 *
* CALL A3_SETSCROLL FIRST,THEN SET A3_CURR TO DESTINATION SCREEN ADDRESS *
* AND CALL A3_SCROLL.							 *
**************************************************************************
A3_Y		EQU 16

A3_TEXT		DC.B "                  "
		DC.B "CHECK DIS, THE VECTORBALLS SCREEN FROM STATE OF THE ART!  YES, I'VE FINALLY DECIDED TO RELEASE SOME (MAYBE ALL) OF THE STATE OF THE ART SOURCE. I WILL CERTAINLY BE GIVING"
		DC.B " AWAY THE 3D SCROLL, BIG SCROLL AND INTRO SOURCES, MAYBE THE FULLSCREEN AND MEGATWISTER ASWELL!  THIS SCROLLTEXT IS OF COURSE DIFFERENT TO THE ONE IN STATE OF THE ART,"
		DC.B " SO WHAT SHALL I TALK ABOUT?????  WELL, AS YOU MAY KNOW I RECENTLY BECAME THE PROUD OWNER OF A BLACK ESCORT XR3I, ITS AN EARLY 21ST BIRTHDAY PRESENT WHICH I GOT THE DAY BEFORE"
		DC.B " GOOD FRIDAY.  ME AND JACK WENT FOR A SPIN IN IT, ITS SO BLOODY FAST JACK ALMOST SHITTED HIMSELF!  I HAVE JUST FINISHED OFF SLAM, AND WAVEFORMS (DIGI-SYNTH 8) WILL BE MY NEXT"
		DC.B " DEMO, IT'LL HAVE SOME REALLY GREAT MUSIC, GET IT WHEN ITS RELEASED.........QUICK GREETS TO MIKEY OF SPI (THANKS FOR THE MODULES!), SWIZZLE (LONG TIME NO WRITE!), FORD (FOR"
		DC.B " MAKING SUCH A FAST CAR), PRONTO, UNT, NATO, ALL THE USUAL GUYS......SEE YA'LL NEXT TIME............OVER AND OUT...........               "
 		DC.B -1
		EVEN
		
A3_SETSCROLL	BSR A3_SHIFT
		JSR A3_CONVERT
		JSR A3_SET_FONT_ADS
		MOVE.L #A3_SCROLL1,A3_SCROLL+2
		JMP A3_FILLBUFFER
A3_CURR		DS.L 1

A3_SHIFT	LEA A3_FONT,A0
		LEA A3_FONT2,A1
		MOVEQ.W #49-1,D0
.L1		MOVEQ.W #A3_Y-1,D1
.L2		MOVE.W (A0)+,D2
		MOVE.W (A0)+,D3
		MOVE.W (A0)+,D4
		MOVEQ.W #8-1,D6
.L3		MOVE.W #$2300,SR
		ROXL.W D4
		ROXL.W D3
		ROXL.W D2
		DBF D6,.L3								
		MOVE.W D2,(A1)+
		MOVE.W D3,(A1)+
		MOVE.W D4,(A1)+
		DBF D1,.L2
		DBF D0,.L1
		RTS	

A3_FONT		INCBIN 32X16.DAT
A3_FONT2	DS.B 49*(6*A3_Y)

* Convert text so that each byte value is the correct offset in the font
* data......ie a ! becomes 0 because ! is the first character in the
* font..... " becomes 1 because " is the second character etc..
A3_CONVERT	LEA A3_TEXT,A0
		LEA A3_CTAB,A1
.A		MOVE.B (A0)+,D0
		MOVEA.L A1,A2
		MOVEQ.W #23-1,D1
.BZ		CMP.B (A2)+,D0 
		BEQ .C
		ADDQ.L #1,A2
		DBF D1,.BZ	
		BRA .D
.C		MOVE.B (A2),-1(A0)
.D		CMPI.B #-1,(A0)
		BNE .A
		LEA A3_TEXT,A0
.L1		CMPI.B #-1,(A0)
		BEQ .EXIT
		SUBI.B #42,(A0)+
		BRA .L1
.EXIT		RTS	

A3_CTAB		DC.B '!',42
		DC.B '"',43
		DC.B "'",44
		DC.B '(',45
		DC.B ')',46
		DC.B '+',47
		DC.B ',',48
		DC.B '-',49
		DC.B '.',50
		DC.B ' ',51,'0',52,'1',53,'2',54,'3',55
		DC.B '4',56,'5',57,'6',58,"7",59,'8',60
		DC.B "9",61,":",62,';',63,'?',64
		DC.B -1
		EVEN

A3_FONT_OFFS	DS.W 49
A3_SET_FONT_ADS	LEA A3_FONT_OFFS,A0
		MOVEQ.W #0,D0
		MOVEQ.W #49-1,D1
.L1		MOVE.W D0,(A0)+
		ADDI.W #6*A3_Y,D0		
		DBF D1,.L1
		RTS	

A3_FILLBUFFER	LEA A3_TEXT,A0
		LEA A3_BUFFER,A1
		LEA A3_FONT_OFFS,A2
		MOVEQ.W #11-1,D0
.L2		MOVEQ.W #0,D1
		MOVE.B (A0)+,D1
		LSL.W #1,D1
		LEA (A2,D1.W),A3
		MOVE.W (A3),(A1)+		
		DBF D0,.L2
		MOVE.L A0,A3_TPOS
		RTS

A3_BUFFER	DS.W 11
A3_TPOS		DS.L 1

A3_SCROLL	JMP A3_SCROLL1

A3_SCROLL1	LEA A3_FONT,A0
		LEA A3_BUFFER,A1
		MOVEQ.W #10-1,D0
.L1		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
		MOVEM.L D0/A1,-(A7)
OFFSET		SET 0
OFFSET2		SET 2
		REPT A3_Y/4
		MOVEM.W (A2)+,D0-D5/D6-D7/A1/A3/A5/A6
		MOVE.W D1,OFFSET(A4)
		MOVE.W D2,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		MOVE.W D4,OFFSET(A4)
		MOVE.W D5,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		MOVE.W D7,OFFSET(A4)
		MOVE.W A1,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		MOVE.W A5,OFFSET(A4)
		MOVE.W A6,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		ENDR 
		MOVEM.L (A7)+,D0/A1
		LEA 16(A4),A4
		DBF D0,.L1
		MOVE.L #A3_SCROLL2,A3_SCROLL+2
		RTS

A3_SCROLL2	LEA A3_FONT2,A0
		LEA A3_BUFFER,A1
		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
OFFSET		SET 0
		REPT A3_Y/2
		MOVEM.W (A2)+,D0-D5
		MOVE.W D1,OFFSET(A4)
		MOVE.W D2,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		MOVE.W D4,OFFSET(A4)
		MOVE.W D5,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		ENDR 
		ADDQ.W #8,A4

		MOVEQ.W #9-1,D7
.L1		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
OFFSET		SET 0
		REPT A3_Y/2
		MOVEM.W (A2)+,D0-D5
		OR.W D0,OFFSET(A4)
		MOVE.W D1,OFFSET+8(A4)
		MOVE.W D2,OFFSET+16(A4)
OFFSET		SET OFFSET+160
		OR.W D3,OFFSET(A4)
		MOVE.W D4,OFFSET+8(A4)
		MOVE.W D5,OFFSET+16(A4)
OFFSET		SET OFFSET+160
		ENDR 
		LEA 16(A4),A4
		DBF D7,.L1

		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
OFFSET		SET 0
OFFSET2		SET 0
		REPT A3_Y
		MOVE.W OFFSET2(A2),D0
		OR.W D0,OFFSET(A4)
OFFSET		SET OFFSET+160
OFFSET2		SET OFFSET2+6
		ENDR 
		MOVE.L #A3_SCROLL3,A3_SCROLL+2	
		RTS

A3_SCROLL3	LEA A3_FONT,A0
		LEA A3_BUFFER,A1
		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
OFFSET		SET 0
		REPT A3_Y/2
		MOVEM.W (A2)+,D0-D5
		MOVE.W D2,OFFSET(A4)
OFFSET		SET OFFSET+160
		MOVE.W D5,OFFSET(A4)
OFFSET		SET OFFSET+160
		ENDR 
		ADDQ.W #8,A4

		MOVEQ.W #9-1,D0
.L1		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
		MOVEM.L D0/A1,-(A7)
OFFSET		SET 0
OFFSET2		SET 2
		REPT A3_Y/4
		MOVEM.W (A2)+,D0-D5/D6-D7/A1/A3/A5/A6
		MOVE.W D1,OFFSET(A4)
		MOVE.W D2,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		MOVE.W D4,OFFSET(A4)
		MOVE.W D5,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		MOVE.W D7,OFFSET(A4)
		MOVE.W A1,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		MOVE.W A5,OFFSET(A4)
		MOVE.W A6,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		ENDR 
		MOVEM.L (A7)+,D0/A1
		LEA 16(A4),A4
		DBF D0,.L1

		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
OFFSET		SET 0
		REPT A3_Y/2
		MOVEM.W (A2)+,D0-D5
		MOVE.W D1,OFFSET(A4)
OFFSET		SET OFFSET+160
		MOVE.W D4,OFFSET(A4)
OFFSET		SET OFFSET+160
		ENDR 
		MOVE.L #A3_SCROLL4,A3_SCROLL+2	
		RTS

A3_SCROLL4	LEA A3_FONT2,A0
		LEA A3_BUFFER,A1
		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
OFFSET		SET 0
		REPT A3_Y/2
		MOVEM.W (A2)+,D0-D5
		MOVE.W D2,OFFSET(A4)
OFFSET		SET OFFSET+160
		MOVE.W D5,OFFSET(A4)
OFFSET		SET OFFSET+160
		ENDR 
		MOVEQ.W #9-1,D0
.L1		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
		MOVE.W D0,-(A7)
OFFSET		SET 0
		REPT A3_Y/2
		MOVEM.W (A2)+,D0-D5
		OR.W D0,OFFSET(A4)
		MOVE.W D1,OFFSET+8(A4)
		MOVE.W D2,OFFSET+16(A4)
OFFSET		SET OFFSET+160
		OR.W D3,OFFSET(A4)
		MOVE.W D4,OFFSET+8(A4)
		MOVE.W D5,OFFSET+16(A4)
OFFSET		SET OFFSET+160
		ENDR 
		LEA 16(A4),A4
		MOVE.W (A7)+,D0
		DBF D0,.L1
		MOVE.W (A1)+,D1
		LEA (A0,D1.W),A2
OFFSET		SET 0
		REPT A3_Y/2
		MOVEM.W (A2)+,D0-D5
		OR.W D0,OFFSET(A4)
		MOVE.W D1,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		OR.W D3,OFFSET(A4)
		MOVE.W D4,OFFSET+8(A4)
OFFSET		SET OFFSET+160
		ENDR 
		MOVEA.L A3_TPOS,A0
		MOVEQ.W #0,D0
		MOVE.B (A0)+,D0
		BPL .L5
		LEA A3_TEXT,A0
		MOVE.B (A0)+,D0
.L5		LEA A3_FONT_OFFS,A2		
		MOVE.L A0,A3_TPOS
		LSL.W #1,D0
		LEA (A2,D0.W),A2
		LEA A3_BUFFER,A0
		REPT 10
		MOVE.W 2(A0),(A0)+
		ENDR
		MOVE.W (A2),(A0)
		MOVE.L #A3_SCROLL1,A3_SCROLL+2
		RTS

******************************** OBJECTS **********************************
* FORMAT - NUMBER OF BALLS, X COORDS, Y COORDS, Z COORDS                  *
*	   TYPE OF BALLS TO USE (0=SMALL,1=BIG)                           *
*          ROTATION ANGLES ON X,Y,Z AXIS                                  *
*          ENTER MODE - 0=LEFT,1=RIGHT,2=TOP,3=BOTTOM                     *
*          LEAVE MODE -                "                                  *
*          X,Y,Z OFFSETS  						  *
*          COLOURS 1-5                                                	  *
***************************************************************************
	
OBJECT1		DC.W 12				Number of balls

		DC.W -50,-20,10,40		X data
		DC.W -50,40,-50,40
		DC.W -50,-20,10,40

		DCB.W 4,50			Y data
		DC.W 20,20,-10,-10
		DCB.W 4,-40

		DCB.W 12,0			Z data

		DC.W 0				SMALL BALLS (?!?!)
		DC.W 2,6,2			ROTATION ANGLES
		DC.W 1,3			ENTER/LEAVE
		DC.W 30,0,10			X,Y,Z OFFSETS	
		DC.W $300,$400,$500,$600,$700	COLOURS

OBJECT2		DC.W 8				Number$of balls

		DC.W -50,50,-50,50,-50,50,-50,50
		DC.W 50,50,-50,-50,50,50,-50,-50
		DC.W 35,35,35,35,-35,-35,-35,-35

		DC.W 0				SMALL BALLS
		DC.W 1,8,3			ROTATION ANGLES
		DC.W 2,0			ENTER/LEAVE
		DC.W 10,2,0			X,Y,Z OFFSETS	
		DC.W $030,$040,$050,$060,$070	COLOURS

OBJECT3		DC.W 12				Number of balls

		DC.W 0,20,37,45,37,20,0,-20,-37,-45,-37,-20
		DC.W 45,37,20,0,-20,-37,-45,-37,-20,0,20,37
		DCB.W 12,0

		DC.W 0				SMALL BALLS
		DC.W 4,2,6			ROTATION ANGLES
		DC.W 0,1			ENTER/LEAVE
		DC.W 0,0,0			X,Y,Z OFFSETS	
		DC.W $330,$440,$550,$660,$770	COLOURS

OBJECT4		DC.W 15				Number of balls

		DC.W 0,-40,0,40,0
		DC.W 0,-40,0,40,0
		DC.W 0,-40,0,40,0
		
		DC.W 40,0,0,0,-40
		DC.W 40,0,0,0,-40
		DC.W 40,0,0,0,-40

		DC.W 40,40,40,40,40,0,0,0,0,0,-40,-40,-40,-40,-40

		DC.W 0				SMALL BALLS
		DC.W 4,6,1			ROTATION ANGLES
		DC.W 0,1			ENTER/LEAVE
		DC.W -10,10,20			X,Y,Z OFFSETS	
		DC.W $033,$044,$055,$066,$077	COLOURS

OBJECT5		DC.W 15				Number of balls

		DC.W -40,0,40,-40,0,40,-40,0,40	
		DC.W -40,0,40,-40,0,40

		DC.W 40,40,40,0,0,0,-40,-40,-40,0,0,0,0,0,0

		DC.W 0,0,0,0,0,0,0,0,0,-30,-30,-30,30,30,30

		DC.W 0				SMALL BALLS
		DC.W 4,6,2			ROTATION ANGLES
		DC.W 2,3			ENTER/LEAVE
		DC.W -22,14,-20			X,Y,Z OFFSETS	
		DC.W $303,$404,$505,$606,$707	COLOURS

OBJECT6		DC.W 13				Number of balls

		DC.W 0,0,-50,-25,0,0,0,0,0,25,50,0,0
		DC.W 50,25,0,0,0,0,0,0,0,0,0,-25,-50
		DC.W 0,0,0,0,-50,-25,0,25,50,0,0,0,0

		DC.W 0				SMALL BALLS
		DC.W 5,2,6			ROTATION ANGLES
		DC.W 0,3			ENTER/LEAVE
		DC.W 20,0,0			X,Y,Z OFFSETS	
		DC.W $003,$004,$005,$006,$007	COLOURS

OBJECT7		DC.W 15				Number of balls

		DC.W -112,-96,-80,-64,-48,-32,-16,0
		DC.W 16,32,48,64,80,96,112
		DCB.W 15,0
		DCB.W 15,0

		DC.W 0				SMALL BALLS
		DC.W 0,8,8			ROTATION ANGLES
		DC.W 2,1			ENTER/LEAVE
		DC.W 0,0,0			X,Y,Z OFFSETS	
		DC.W $333,$444,$555,$666,$777	COLOURS

OBJECT8		DC.W 15				Number of balls

		DC.W -30,0,30,-30,0,30,-30,0,30	
		DC.W 0,0,0,0,0,0
		DC.W 30,30,30,0,0,0,-30,-30,-30
		DC.W 0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0
		DC.W 16,32,48,64,80,96

		DC.W 0				SMALL BALLS
		DC.W 2,8,2			ROTATION ANGLES
		DC.W 1,3			ENTER/LEAVE
		DC.W -15,0,15			X,Y,Z OFFSETS	
		DC.W $730,$740,$750,$760,$770	COLOURS

OBJECT9		DC.W 13				Number of balls

		DC.W 0,20,40,60,40,20,0
		DC.W -20,-40,-60,-40,-20,0
		DC.W 60,40,20,0,-20,-40,-60
		DC.W -40,-20,0,20,40,0
		DCB.W 13,-30

		DC.W 0				SMALL BALLS
		DC.W 4,4,0			ROTATION ANGLES
		DC.W 3,2			ENTER/LEAVE
		DC.W 0,0,0			X,Y,Z OFFSETS	
		DC.W $310,$420,$530,$640,$750	COLOURS

OBJECT10	DC.W 12				Number of balls

		DC.W -40,0,-40,0
		DC.W -40,0,-40,0
		DC.W -40,0,-40,0
				
		DC.W 40,40,0,0
		DC.W 40,40,0,0
		DC.W 40,40,0,0

		DC.W -60,-60,-60,-60,0,0,0,0,60,60,60,60

		DC.W 0				SMALL BALLS
		DC.W 4,4,6			ROTATION ANGLES
		DC.W 2,0			ENTER/LEAVE
		DC.W 14,14,14			X,Y,Z OFFSETS	
		DC.W $040,$050,$060,$070,$171	COLOURS

OBJECT11	DC.W 15				Number of balls
		
		DC.W -60,-30,0,30,60
		DC.W -60,-30,0,30,60
		DC.W -60,-30,0,30,60
		
		DC.W 30,30,30,30,30,0,0,0,0,0,-30,-30,-30,-30,-30
		
		DCB.W 15,0

		DC.W 0				SMALL BALLS
		DC.W 4,4,4			ROTATION ANGLES
		DC.W 1,1			ENTER/LEAVE
		DC.W 20,20,20			X,Y,Z OFFSETS	
		DC.W $037,$047,$057,$067,$077	COLOURS

OBJECT12	DC.W 15				Number of balls
		
		DC.W -30,0,30,-30,0,0,0,0,0,0,0,30,-30,0,30
		DC.W 30,30,30,0,0,0,0,0,0,0,0,0,-30,-30,-30
		DC.W 0,0,0,0,-60,-40,-20,0,20,40,60,0,0,0,0 

		DC.W 0				SMALL BALLS
		DC.W 2,3,4			ROTATION ANGLES
		DC.W 3,1			ENTER/LEAVE
		DC.W -20,0,20			X,Y,Z OFFSETS	
		DC.W $307,$407,$507,$607,$707	COLOURS

OBJECT13	DC.W 12

		DC.W 0,20,40,60,40,20,0,-20,-40,-60,-40,-20
		DC.W 40,20,0,-20,-20,-20,-20,-20,-20,-20,0,20
		DCB.W 12,-40
		
		DC.W 0				SMALL BALLS
		DC.W 2,6,2			ROTATION ANGLES
		DC.W 3,1			ENTER/LEAVE
		DC.W 0,0,0			X,Y,Z OFFSETS	
		DC.W $703,$704,$705,$706,$707	COLOURS

* Well, I hope you've learnt something from this source, I suppose all
* the lame pirate and demo crews (no names!) will start coming out with
* vectorball intros for their menus and demo screens.......if I catch
* anyone using my code without my permission (in writing!) then you will
* be subjected to the various forms of punishment Flashbak Jack has
* devised (Flash being somewhat of an expert in this area!) which include
* (amoung other things) hanging people by their dicks from very tall
* trees while we drop stinging nettles on you and burn your hair!
* You have been warned, and in the words of Stormlord 'Use my code but
* dont abuse it'.......
