* This is the GigaDist scroller.  Written by Matrixx of the ST-Sqaud 1990.
* Copyright (C) 1990 The ST-Squad.
* This scroller scrolls a 3-plane font up the screen repeating it
* 10 times across the screen with a horizontal distort.

        OPT     O+,OW-,C-

demo		EQU 	0
FontSize	EQU	14400
IEA		EQU	$FFFFFA07	Interrupt enable A.
IEB		EQU	$FFFFFA09	Interrupt enable B.
IMA		EQU	$FFFFFA13	Interrupt mask A.
TBCR		EQU	$FFFFFA1B	Timer B control register.
TBDR		EQU	$FFFFFA21	Timer D control register.
VBL_VEC         EQU     $70	VBL vector.
KEY_VEC         EQU     $118	Keyboard interrupt vector.
HBL_VEC         EQU     $120	MFP HBL vector.
SoundReg	EQU	$FFFF8800

SwapScreens	MACRO		Macro to swap the physical screens.
	SetScreen	ScreenPos(PC)	Set the screen position.
	
	MOVE.L	ScreenPos2(PC),D0	Swap the screen pointers around.
	MOVE.L	ScreenPos(PC),ScreenPos2
	MOVE.L	D0,ScreenPos
	
	WaitVBL			Wait for the next VBL interrupt.
	ENDM			End of macro.

WaitVBL	MACRO		Wait for the next vertical blank interrupt.
.WaitVBL\@
	TST.W	VBLFlag
	BEQ.S	.WaitVBL\@
	CLR.W	VBLFlag

	ENDM			End of macro.

WaitVBL2	MACRO		Wait for the next vertical blank interrupt.
	CLR.W	VBLFlag
.WaitVBL\@
	TST.W	VBLFlag
	BEQ.S	.WaitVBL\@

	ENDM			End of macro.


SetScreen	MACRO		Macro to set the screen position.
	MOVE.L	\1,-(SP)	Put the screen position on the stack.
	MOVE.B	1(SP),$FFFF8201.W	Move middle bytes to the video chip.
	MOVE.B	2(SP),$FFFF8203.W
	ADDQ.W	#4,SP		Tidy stack.
	ENDM			End of macro.

**************
* Plot lines *
**************
* Macros to plot one line of the v-dist scroller.
* Parameters:
* A4 = Position of the screen.
* A5 = Base position of the line of the character.
* A6 = Offset table for the horizontal distort.
*			Clock cycle timings:
PlotLine1	MACRO
        MOVE.L  (A6)+,D0        12	Get offset.
        LEA     0(A5,D0.L),A3   12	Add it onto the character position.
        MOVEQ   #0,D1           4	Clear D1
        MOVEQ   #0,D3           4	Clear D3
        MOVE.L  (A3)+,D0        12	Get 2 bit planes of data.
        MOVE.W  (A3)+,D1        8	Get 1 bit plane of data.
        SWAP    D1              4	Move it to the high word.
        MOVE.L  (A3)+,D2        12	Get 2 bit planes of data.
        MOVE.W  (A3)+,D3        8	Get 1 bit plane of data.
        SWAP    D3              4	Move it to the high word.
        MOVE.L  D0,D4           4	Copy D0.
        MOVE.L  D1,D5           4	Copy D1.
        MOVE.L  D2,D6           4	Copy D2.
        MOVE.L  D3,D7           4	Copy D3.
        MOVE.L  D0,A0           4	And again!
        MOVE.L  D1,A1           4
        MOVE.L  D2,A2           4
        MOVE.L  D3,A3           4
        REPT    3
        MOVEM.L D0-D7/A0-A3,-(A4)       128*38	Move the data to the screen.
        ENDR
        MOVEM.L D0-D3,-(A4)             48
        ENDM

*Plot on other 16 pixel boundary.
PlotLine2	MACRO              
        MOVE.L  (A6)+,D0        12
        LEA     0(A5,D0.L),A3   12
        MOVEQ   #0,D1           4
        MOVEQ   #0,D3           4
        MOVE.L  (A3)+,D2        12	Data registers are the other
        MOVE.W  (A3)+,D3        8	way around this time.
        SWAP    D3              4
        MOVE.L  (A3)+,D0        12	^  see!
        MOVE.W  (A3)+,D1        8	|
        SWAP    D1              4
        MOVE.L  D0,D4           4
        MOVE.L  D1,D5           4
        MOVE.L  D2,D6           4
        MOVE.L  D3,D7           4
        MOVE.L  D0,A0           4
        MOVE.L  D1,A1           4
        MOVE.L  D2,A2           4
        MOVE.L  D3,A3           4
        REPT    3
        MOVEM.L D0-D7/A0-A3,-(A4)       128*38
        ENDR
        MOVEM.L D0-D3,-(A4)             48
        ENDM

PlotByteColumn	MACRO		Macro for plotting each line of the byte bender.
	MOVE.W	(A2)+,D0	Get font offset of column to plot.
	BEQ	EndColumnMacro\@	Skip if column is zero
	LEA	0(A1,D0.W),A4	Calculate actual position.
	MOVE.W	(A3)+,D0	Get distort offset.
	LEA	0(A0,D0.W),A5	Add it to the screen position.
	Plot8by8	0	Plot first 8 pixels.
	Plot8by8	1280	Plot next 8 pixels.
	Plot8by8	1280*2	etc.
	Plot8by8	1280*3
	Plot8by8	1280*4
	Plot8by8	1280*5
	Plot8by8	1280*6
	
EndColumnMacro\@
	ENDM

Plot8by8	MACRO		Plot 8 by 8 block for the byte bender.
	MOVE.B	(A4)+,D0	Get data for block.
	BEQ.S	End8by8Macro\@	Skip it if it is zero.
	MOVE.B	D0,\1(A5)	First line.
	MOVE.B	D0,\1+160(A5)	Second line.
	MOVE.B	D0,\1+320(A5)	etc.
	MOVE.B	D0,\1+480(A5)
	MOVE.B	D0,\1+640(A5)
	MOVE.B	D0,\1+800(A5)
	MOVE.B	D0,\1+960(A5)
	MOVE.B	D0,\1+1120(A5)
End8by8Macro\@
	ENDM


****************
* Main Program *
****************
	BRA	Main
	
Music	INCBIN	GIGADIST.INC\GRRMUS.CZI

*************************************
* Routine to enlarge the tiny font. *
*************************************
ShiftTinyFont:
	LEA	TinyFont,A0		Load source ...
	LEA	ByteFont+64,A1		 .. and destination.
	MOVEQ	#33,D6		The number of characters to work on (-1).
.Loop1
	MOVE.B	(A0)+,D0	Get four bytes in low words.
	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
	MOVE.B	(A0)+,D3
	
	SWAP	D0
	SWAP	D1
	SWAP	D2
	SWAP	D3
	
	MOVE.B	(A0)+,D0	And the other three in the high words.
	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D2
	
	SWAP	D0
	SWAP	D1
	SWAP	D2
	SWAP	D3
	
	MOVEQ	#7,D7	8 pixels across to work on.
.Loop2
	LSL.B	#1,D0	Test bit.
	SCS	(A1)+	Set byte if set.
	LSL.B	#1,D1	etc.
	SCS	(A1)+
	LSL.B	#1,D2
	SCS	(A1)+
	LSL.B	#1,D3
	SCS	(A1)+
	
	SWAP	D0	Next bytes to test.
	SWAP	D1
	SWAP	D2
	
	LSL.B	#1,D0	Test bit.
	SCS	(A1)+	Set byte if set.
	LSL.B	#1,D1	etc.
	SCS	(A1)+
	LSL.B	#1,D2
	SCS	(A1)+
	CLR.B	(A1)+
	
	SWAP	D0	Back to first set of bytes.
	SWAP	D1
	SWAP	D2
	
	DBRA	D7,.Loop2	Next bits.
	DBRA	D6,.Loop1	Next character.
	
	RTS		Bye bye.


*******************************
* Clear bottom of the screen. *
*******************************
* Simple routine to clear the last 3 lines of the screen.
* Called once at the start of the program.
* Parameter:
* A0 = Position of the screen.
ClearScreenBottom:
	MOVE.L	A0,A1
	MOVEQ	#59,D7		60*8 bytes to clear.
	MOVEQ	#0,D0		Clear D0
.Loop	MOVE.L	D0,(A0)+	Clear 8 bytes.
	MOVE.L	D0,(A0)+
	DBRA	D7,.Loop	Loop.

	LEA	31520(A1),A0	Move to the bottom of the screen. 
	MOVEQ	#59,D7		60*8 bytes to clear.
.Loop2	MOVE.L	D0,(A0)+	Clear 8 bytes.
	MOVE.L	D0,(A0)+
	DBRA	D7,.Loop2	Loop.

	RTS			Bye bye.

********************************
* Routine to shift the sprites *
********************************
ShiftSprites:
	LEA	Sprites,A0		Get source address.
	LEA	ShiftedSprites,A1	Get destination.

	MOVEQ	#15,D0			16 lines.
.Loop1	MOVEQ	#0,D1			Clear top word.
	MOVE.W	(A0)+,D1		Get data.
	SWAP	D1			Move it to top word.
	MOVE.L	D1,(A1)			Put it into memory.
	BSR.S	ShiftLine		Do the shift.
	ADDQ.L	#4,A1			Next 16 pixels.
	DBRA	D0,.Loop1		Loop.
	
	LEA	ShiftedSprites+1024,A1	Do the other sprite now.
	MOVEQ	#15,D0			As before..
.Loop2	MOVEQ	#0,D1
	MOVE.W	(A0)+,D1
	SWAP	D1
	MOVE.L	D1,(A1)
	BSR.S	ShiftLine
	ADDQ.L	#4,A1
	DBRA	D0,.Loop2
	
	RTS
	
* Routine to do the actual shifting.
ShiftLine:
	LSR.L	#1,D1			Shift and store the line
	MOVE.L	D1,64(A1)		 for each sprite.
	LSR.L	#1,D1
	MOVE.L	D1,128(A1)
	LSR.L	#1,D1
	MOVE.L	D1,192(A1)
	LSR.L	#1,D1
	MOVE.L	D1,256(A1)
	LSR.L	#1,D1
	MOVE.L	D1,320(A1)
	LSR.L	#1,D1
	MOVE.L	D1,384(A1)
	LSR.L	#1,D1
	MOVE.L	D1,448(A1)
	LSR.L	#1,D1
	MOVE.L	D1,512(A1)
	LSR.L	#1,D1
	MOVE.L	D1,576(A1)
	LSR.L	#1,D1
	MOVE.L	D1,640(A1)
	LSR.L	#1,D1
	MOVE.L	D1,704(A1)
	LSR.L	#1,D1
	MOVE.L	D1,768(A1)
	LSR.L	#1,D1
	MOVE.L	D1,832(A1)
	LSR.L	#1,D1
	MOVE.L	D1,896(A1)
	LSR.L	#1,D1
	MOVE.L	D1,960(A1)
	RTS
	
**********************************************
* Routine to plot the one bit plane sprites. *
**********************************************
* Parameters:
* D0.W = Fine position.
* D1.W = Course position.
* A1 = Sprite position.
PlotSprites:
	LSL.W	#6,D0		Multiply by 64 to point at shifted sprite.
	MOVE.L	ScreenPos,A0	Get screen position.
	ADDA.W	D0,A1		Get address of sprite.
	ADDA.W	D1,A0		Find screen position.
	
	MOVEM.W	(A1)+,D0-D7	Get data.
	
	OR.W	D0,(A0)		Plot it.
	OR.W	D1,8(A0)
	OR.W	D2,160(A0)
	OR.W	D3,160+8(A0)
	OR.W	D4,320(A0)
	OR.W	D5,320+8(A0)
	OR.W	D6,480(A0)
	OR.W	D7,480+8(A0)
	
	MOVEM.W	(A1)+,D0-D7	Get data.
	
	OR.W	D0,640(A0)	Plot it.
	OR.W	D1,640+8(A0)
	OR.W	D2,640+160(A0)
	OR.W	D3,640+160+8(A0)
	OR.W	D4,640+320(A0)
	OR.W	D5,640+320+8(A0)
	OR.W	D6,640+480(A0)
	OR.W	D7,640+480+8(A0)
	
	MOVEM.W	(A1)+,D0-D7	Get data.
	
	OR.W	D0,1280(A0)	Plot it.
	OR.W	D1,1280+8(A0)
	OR.W	D2,1280+160(A0)
	OR.W	D3,1280+160+8(A0)
	OR.W	D4,1280+320(A0)
	OR.W	D5,1280+320+8(A0)
	OR.W	D6,1280+480(A0)
	OR.W	D7,1280+480+8(A0)
	
	MOVEM.W	(A1)+,D0-D7	Get data.
	
	OR.W	D0,1920(A0)	Plot it.
	OR.W	D1,1920+8(A0)
	OR.W	D2,1920+160(A0)
	OR.W	D3,1920+160+8(A0)
	OR.W	D4,1920+320(A0)
	OR.W	D5,1920+320+8(A0)
	OR.W	D6,1920+480(A0)
	OR.W	D7,1920+480+8(A0)
	
	RTS			Bye bye.

***********************************
* Routine to alter main waveform. *
***********************************
* This is needed as I couldn't get my waveform generator to do words
* and longwords in the same table.
AlterWaveform:
	LEA	HorizontalDistort+2(PC),A0	Load table address.
	MOVE.W	#399,D7			400 poiners to alter.
	MOVE.W	#FontSize,D1		Size of one shift of the font.
.Loop	MOVE.L	(A0),D0			Get the word.
	MULU	D1,D0			Multiply by size.
	MOVE.L	D0,(A0)			Store it again.
	LEA	6(A0),A0		Next pointer.
	DBRA	D7,.Loop		Loop.
	RTS				Bye bye.

	
********************
* Sprite Waveforms *
********************
SpriteWave
	REPT	2
	INCBIN	GIGADIST.INC\SPRWAVE.WAV
	ENDR
SpriteVWave
	REPT	2
	INCBIN	GIGADIST.INC\SPRWAVE2.WAV
	ENDR

*****************
* Main waveform *
*****************

HorizontalDistort:
	REPT	2
	INCBIN	GIGADIST.INC\SINWAVE.WAV
	ENDR
	
******************
* Initialization *
******************

Main:
	IFEQ demo
	CLR -(SP)
	PEA $FFFFFFFF.W
	PEA $FFFFFFFF.W
	MOVE #5,-(SP)
	TRAP #14
	LEA 12(SP),SP
        CLR.L	-(SP)		Use USP as supervisor stack pointer.
        MOVE.W  #$20,-(SP)      Supervisor mode toggle.
        TRAP    #1              GEMDOS - into supervisor mode.
        ADDQ.W  #6,SP           Tidy stack.
	ENDC

	MOVE.W	#$2700,SR
	MOVE.L SP,OldSSP
	LEA	Stack(PC),A7	Load new USP.
	MOVE.B	#$12,$FFFFFC02.W	Kill the mouse!
        LEA     OldPalette(PC),A1   Save the old palette.
        LEA     $FFFF8240.W,A0
        MOVEQ   #7,D0           8 longwords to move.
StorePaletteLoop:
        MOVE.L  (A0),(A1)+
	CLR.L (A0)+
        DBRA	D0,StorePaletteLoop        
	LEA SecondScreenStore+256,A0
	MOVE #3999,D0
	MOVEQ #0,D1
cls	MOVE.L D1,(A0)+
	MOVE.L D1,(A0)+
	MOVE.L D1,(A0)+
	MOVE.L D1,(A0)+
	DBF D0,cls
        MOVE.L  #SecondScreenStore+256,D0	Load address of second screen.
        CLR.B   D0			Make sure it is on a 256 byte boundary.
	MOVE.L D0,ScreenPos
	ADD.L #32000,D0
        MOVE.L  D0,ScreenPos2
	LSR #8,D0
	MOVE.L D0,$FFFF8200.W 
	LEA	Font(PC),A0		Find font position.
	LEA	ShiftedFont,A1		Find output position.
	BSR	ShiftFont		Shift the font.
	BSR	ShiftTinyFont		Shift the little one bit plane font.
	BSR	ShiftSprites		Shift the one plane sprites.
	BSR	ShiftLogo
	BSR	AlterWaveform		Change waveform offsets.
	MOVE.W	MOD+2,RasterPointer	Store the pc offset into the raster table.
	MOVE.B  (IEB).W,OLD_IEB			Save system registers that will be altered.
        MOVE.B  (IEA).W,OLD_IEA
        MOVE.B  (IMA).W,OLD_IMA
	CLR.B $FFFFFA07.W
	CLR.B $FFFFFA09.W
        BCLR	#3,$FFFFFA17.W			Set MFP automatic end of interrupt mode.
	MOVEQ	#1,D0
	BSR	Music+28				Set up musix.
        MOVE.L  (HBL_VEC).W,OLD_HBL_VEC		Save old HBL routine.
        MOVE.L  #HBL_HANDLER,(HBL_VEC).W	Set up new one.
        OR.B    #1,(IEA).W			Turn H-Blank on.
        OR.B    #1,(IMA).W
        MOVE.L  (VBL_VEC).W,OLD_VBL_VEC		Save old VBL routine.
        MOVE.L  #VBL_HANDLER,(VBL_VEC).W	Set up new one.
	MOVE.L	ScreenPos,A0
	BSR	ClearScreenBottom
	MOVE.L	ScreenPos2,A0
	BSR	ClearScreenBottom
        LEA     Palette(PC),A0      Set the new palette.
        BSR     SetPalette

	MOVE.W  #$2300,SR
        

*Intialization now finished.  The scroller starts here.
	
Scroller:
	MOVEQ	#6,D7		Number of 3-pixel lines to clear between characters.
	MOVE.L	ScreenPos(PC),A6	Screen position.
	LEA	31840(A6),A6	Move to the bottom of the screen.
	
	SUBA.W	LinePos(PC),A6	Move up as the characters scroll.
	BSR	ClearLines	Clear the lines.
	
	LEA	HorizontalDistort(PC),A6	Load position of horizontal distort table.

	MOVE.W	DistortPosition(PC),D0	Load value of offset into the above table.
	ADDQ.W	#6,D0			Increment it.
	CMPI.W	#1200,D0			At the end?
	BMI.S	.Bra1			No, then skip next instruction.
	SUB.W	#1200,D0			Reset offset.
.Bra1	
	MOVE.W	D0,DistortPosition	Store the new offset.
	ADDA.W	D0,A6			Add offset onto position of the table.
	
* Plot bottom character.
	CMPI.W	#4,LinePos2		Position less than 4.
	BMI.S	.Bra2			No need to plot anything then.

	MOVE.L	ScreenPos(PC),A4		Load screen position.
	LEA	28*160*7(A4),A4		Add offset to bottom of the screen.
	LEA	ShiftedFont,A5	Load font position.
	ADDA.W	CharPointers+14(PC),A5	Find character to plot.
	MOVEQ	#28,D0			Base 28 lines to plot.
	SUB.W	LinePos2(PC),D0		Less position of the characters.
	ADD.W	D0,D0		Work out exact position in the font.
	ADD.W	D0,D0
	SUBA.W	D0,A5
	ADD.W	D0,D0
	SUBA.W	D0,A5		And store it in A5.
	MOVE.W	LinePos2(PC),LineCount	Number of lines to plot.
	SUBQ.W	#4,LineCount		subtract lines for spaces.
	BSR	DrawCharacter		Plot the character.
	
.Bra2	
	LEA	HorizontalDistort(PC),A6	Load distort table position...
	ADDA.W	DistortPosition(PC),A6	and add offset into it.

	MOVE.W	LinePos2(PC),D0		Add offset depending on vertical position.
	ADD.W	D0,D0			^
	ADDA.W	D0,A6			|
	ADD.W	D0,D0			|
	ADDA.W	D0,A6			|
	
* Plot the main part of the screen.

	MOVE.L	ScreenPos(PC),A4	Load screen position.
	LEA	28*160*7(A4),A4		Add offset.
	SUBA.W	LinePos,A4		Subtract vertical position.
	LEA	ShiftedFont,A5		Load font position.
	ADDA.W	CharPointers+12(PC),A5	Find character to plot.
	MOVE.W	#24,LineCount		24 lines to plot.
	BSR	DrawCharacter		Plot the character.
	LEA	18(A6),A6		Skip distort of the gap.

	LEA	-480(A4),A4			etc.
	LEA	ShiftedFont,A5
	ADDA.W	CharPointers+10(PC),A5
	MOVE.W	#24,LineCount
	BSR	DrawCharacter
	LEA	18(A6),A6

	LEA	-480(A4),A4
	LEA	ShiftedFont,A5
	ADDA.W	CharPointers+8(PC),A5
	MOVE.W	#24,LineCount
	BSR	DrawCharacter
	LEA	18(A6),A6

	LEA	-480(A4),A4
	LEA	ShiftedFont,A5
	ADDA.W	CharPointers+6(PC),A5
	MOVE.W	#24,LineCount
	BSR	DrawCharacter
	LEA	18(A6),A6

	LEA	-480(A4),A4
	LEA	ShiftedFont,A5
	ADDA.W	CharPointers+4(PC),A5
	MOVE.W	#24,LineCount
	BSR	DrawCharacter
	LEA	18(A6),A6

	LEA	-480(A4),A4
	LEA	ShiftedFont,A5
	ADDA.W	CharPointers+2(PC),A5
	MOVE.W	#24,LineCount
	BSR	DrawCharacter
	LEA	18(A6),A6

* Plot the character at the top of the screen.	
	LEA	-480(A4),A4
	LEA	ShiftedFont,A5
	ADDA.W	CharPointers(PC),A5
	MOVEQ	#24,D0
	SUB.W	LinePos2(PC),D0	Subtract vertical position.
	BMI.S	Wait		Negative number of lines? Then don't plot them!
	MOVE.W	D0,LineCount	Number of lines to plot.
	BSR	DrawCharacter	Plot the character.
	
Wait	
	
* Now plot the byte bender.

	MOVE.L	ScreenPos(PC),A0	Load screen position.
	MOVE.W	ByteVerticalPosition(PC),D0	Load position of bounce offset.
	LEA	VWaveForm(PC),A1	Load bounce offset table start.
	ADD.W	0(A1,D0.W),A0		Add bounce offset to screen position.
	LEA	ByteFont(PC),A1		Load position of the font.
	MOVE.L	ByteDistPosition(PC),A3	Load position of distort table.
	LEA	ByteFontOffsetTable(PC),A2	Load font offset table. (character pointers)
	BSR	ByteBend		Call the byte bender.
	MOVE.L	ByteDistPosition(PC),D0	Load distort table pointer.
	ADDQ.L	#4,D0			Increment it.
	CMPI.L	#ByteDistEnd,D0		At the end of the table?
	BMI.S	DistOK			No, then branch.
	SUB.W	#ByteDistEnd-ByteDist,D0	Reset pointer.
DistOK:
	MOVE.L	D0,ByteDistPosition	Save distort table pointer.
	MOVE.W	ByteVerticalPosition(PC),D0	Load vertical position pointer.
	ADDQ.W	#2,D0			Increment it.
	MOVE.W	D0,ByteVerticalPosition	Save it.
	CMPI.W	#VWaveformEnd-VWaveForm,D0	At the end of the table?
	BMI.S	VPosOK			No, then branch.
	CLR.W	ByteVerticalPosition	Reset pointer.
VPosOK:
	BSR	ByteBendOffsetScroll	Move the offset table.

	ADD.W	#320,LinePos		Increment vertical position counter.
	ADD.W	#2,LinePos2		Ditto.
	CMPI.W	#160*28,LinePos		At the end?
	BMI.S	.Bra1			No..
	SUB.W	#160*28,LinePos	Reset the two counters...
	SUB.W	#28,LinePos2
	BSR	OffScroll	Move to the next character in the message.
.Bra1	
	BSR	PlotSoundBars	Plot the volume indicators in the corners.

	BSR	PlotLogo	Plot the 3 plane logo.

	LEA	ShiftedSprites,A6
	
	LEA	SpriteWave(PC),A0	Load sprite wave forms and set up parameters.
	ADDA.W	SpriteWavePointer(PC),A0
	MOVE.L	A0,A2
*	MOVE.W	(A0)+,D0
*	MOVE.W	(A0)+,D1
	LEA	SpriteVWave(PC),A0
	ADDA.W	SpriteVWavePointer(PC),A0
	MOVE.L	A0,A3
*	ADD.W	(A0),D1
*	MOVE.L	A6,A1
*	BSR	PlotSprites		Plot the sprite.

	LEA	40(A2),A2		etc.
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	LEA	16(A3),A3
	ADD.W	(A3),D1
	LEA	1024(A6),A1
	BSR	PlotSprites

	LEA	40(A2),A2
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	LEA	16(A3),A3
	ADD.W	(A3),D1
	MOVE.L	A6,A1
	BSR	PlotSprites
*
*	LEA	100(A2),A2
*	MOVE.W	(A2)+,D0
*	MOVE.W	(A2)+,D1
*	LEA	16(A3),A3
*	ADD.W	(A3),D1
*	MOVE.L	A6,A1
*	BSR	PlotSprites

	LEA	140(A2),A2
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	LEA	16(A3),A3
	ADD.W	(A3),D1
	LEA	1024(A6),A1
	BSR	PlotSprites

	LEA	40(A2),A2
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	LEA	16(A3),A3
	ADD.W	(A3),D1
	MOVE.L	A6,A1
	BSR	PlotSprites

*
*	LEA	100(A2),A2
*	MOVE.W	(A2)+,D0
*	MOVE.W	(A2)+,D1
*	LEA	16(A3),A3
*	ADD.W	(A3),D1
*	LEA	ShiftedSprites,A1
*	BSR	PlotSprites

*	LEA	40(A2),A2
*	MOVE.W	(A2)+,D0
*	MOVE.W	(A2)+,D1
*	LEA	16(A3),A3
*	ADD.W	(A3),D1
*	LEA	ShiftedSprites+1024,A1
*	BSR	PlotSprites
*
*	LEA	40(A2),A2
*	MOVE.W	(A2)+,D0
*	MOVE.W	(A2)+,D1
*	LEA	16(A3),A3
*	ADD.W	(A3),D1
*	LEA	ShiftedSprites,A1
*	BSR	PlotSprites
*
*
	LEA	100(A2),A2
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	ADD.W	#13600,D1
	LEA	16(A3),A3
	ADD.W	(A3),D1
	MOVE.L	A6,A1
	BSR	PlotSprites

	LEA	40(A2),A2
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	ADD.W	#13600,D1
	LEA	16(A3),A3
	ADD.W	(A3),D1
	LEA	1024(A6),A1
	BSR	PlotSprites

	LEA	40(A2),A2
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	ADD.W	#13600,D1
	LEA	16(A3),A3
	ADD.W	(A3),D1
	MOVE.L	A6,A1
	BSR	PlotSprites


	ADDQ.W	#4,SpriteWavePointer	Increment the pointer.
	CMPI.W	#800,SpriteWavePointer	Check for end of table.
	BMI.S	.POK
	CLR.W	SpriteWavePointer
.POK	
	ADDQ.W	#2,SpriteVWavePointer	Increment other pointer.
	CMPI.W	#480,SpriteVWavePointer	Check for end of table.
	BMI.S	.POK2
	CLR.W	SpriteVWavePointer
.POK2	


	
*	MOVE.W	#$002,$FFFF8240.W	Timing bars.
	SwapScreens			Swap the screens around.
*	MOVE.W	#$000,$FFFF8240.W	Timing bars.
	btst.b #0,$fffffc00.w
	beq Scroller
	MOVE.B	$FFFFFC02.W,D0		Read keyboard.
	CMPI.B	#$26,D0			L?
	BEQ	Mad			Then show hidden message.
	
	CMPI.B	#185,D0		Space?
	BNE	Scroller	No, then keep scrolling.
	
Exit: 
* Leave the demo.

	MOVE.W	#$2700,SR	Interrupts off.
        LEA     OldPalette(PC),A0
        BSR     SetPalette      Restore the old palette.
        MOVE.B  OLD_IEB,(IEB).W		Put everything back again.
        MOVE.B  OLD_IEA,(IEA).W
        MOVE.B  OLD_IMA,(IMA).W
        MOVE.L  OLD_HBL_VEC,(HBL_VEC).W
        MOVE.L  OLD_VBL_VEC,(VBL_VEC).W
	MOVE.B	#8,(SoundReg).W		Sound off.
	CLR.B (SoundReg+2).W
	MOVE.B	#9,(SoundReg).W
	CLR.B (SoundReg+2).W
	MOVE.B	#10,(SoundReg).W
	CLR.B (SoundReg+2).W
	IFEQ demo
	MOVE.W  #$2300,SR	Interrupts on again.
	MOVE.B	#$8,$FFFFFC02.W	Revive the mouse!
	CLR.W	-(SP)		Bye bye.
	TRAP	#1
	ENDC
	MOVE.L OldSSP,SP
	RTS


Mad:
	MOVE.L	#HiddenText,PositionInText
	BRA	Scroller
	
******************************************
* Routine to pre-shift the 3 plane logo. *
******************************************

ShiftLogo:
	LEA	Logo,A0
	LEA	ShiftedLogo,A1
	MOVE.L	A1,A2
	MOVEQ	#31,D7		32 Lines to copy
.Loop
	MOVE.W	(A0),(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	CLR.W	(A1)+
	MOVE.W	(A0),(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	CLR.W	(A1)+
	MOVE.W	(A0),(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	CLR.W	(A1)+
	MOVE.L	#-1,(A1)+
	CLR.L	(A1)+
	CLR.L	(A1)+
	DBRA	D7,.Loop

	MOVE.W	#479,D7		512 Lines to shift.
	MOVE.L	A2,A0	
.Loop2
	MOVE.W	(A0),D0		Mask.
	MOVE.W	12(A0),D1
	MOVE.W	24(A0),D2
	MOVE.W	36(A0),D3
	MOVE.W	#$10,ccr 
	ROXR.W	#1,D0
	ROXR.W	#1,D1
	ROXR.W	#1,D2
	ROXR.W	#1,D3
	MOVE.W	D0,(A1)
	MOVE.W	D0,2(A1)
	MOVE.W	D1,12(A1)
	MOVE.W	D1,14(A1)
	MOVE.W	D2,24(A1)
	MOVE.W	D2,26(A1)
	MOVE.W	D3,36(A1)
	MOVE.W	D3,38(A1)
	
	MOVE.W	4(A0),D0		1st plane.
	MOVE.W	16(A0),D1
	MOVE.W	28(A0),D2
	MOVE.W	40(A0),D3
	LSR.W	#1,D0
	ROXR.W	#1,D1
	ROXR.W	#1,D2
	ROXR.W	#1,D3
	MOVE.W	D0,4(A1)
	MOVE.W	D1,16(A1)
	MOVE.W	D2,28(A1)
	MOVE.W	D3,40(A1)

	MOVE.W	6(A0),D0		2nd plane.
	MOVE.W	18(A0),D1
	MOVE.W	30(A0),D2
	MOVE.W	42(A0),D3
	LSR.W	#1,D0
	ROXR.W	#1,D1
	ROXR.W	#1,D2
	ROXR.W	#1,D3
	MOVE.W	D0,6(A1)
	MOVE.W	D1,18(A1)
	MOVE.W	D2,30(A1)
	MOVE.W	D3,42(A1)
	
	MOVE.W	8(A0),D0		3rd plane.
	MOVE.W	20(A0),D1
	MOVE.W	32(A0),D2
	MOVE.W	44(A0),D3
	LSR.W	#1,D0
	ROXR.W	#1,D1
	ROXR.W	#1,D2
	ROXR.W	#1,D3
	MOVE.W	D0,8(A1)
	MOVE.W	D1,20(A1)
	MOVE.W	D2,32(A1)
	MOVE.W	D3,44(A1)
	
	CLR.W	10(A1)
	CLR.W	22(A1)
	CLR.W	34(A1)
	CLR.W	46(A1)
	
	LEA	48(A0),A0
	LEA	48(A1),A1
	DBRA	D7,.Loop2
	
	RTS
	

**********************************
* Routine to draw one character. *
**********************************
* Parameters:
* A4 = Position on screen to draw character. (Start of line below bottom
* line of the character.
* A5 = Pointer to the character.
* A6 = Pointer to horizontal distort table.
* LineCount = number of lines to draw -1

DrawCharacter:	
	TST.W	(A6)+		Which 16 pixel boundary?
	BEQ	.Bra1		Branch if zero.
	PlotLine2		2nd 16-pixel boundary.
	LEA	-12(A5),A5	Move back through character.
	SUBQ.W	#1,LineCount	1 less line to plot.
	BPL.S	DrawCharacter	All done? Keep going if not.
	BRA.S	.Bra2		Bye bye.
.Bra1
	PlotLine1		As above.
	LEA	-12(A5),A5
	SUBQ.W	#1,LineCount
	BPL	DrawCharacter
.Bra2
	RTS			Character finished.

*********************************
* Routine to pre-shift the font *
*********************************

* Copies the font 16 times, with each copy shifted over one pixel
* from the last copy.
* Parameters :
* A0 = Position of the font.
* A1 = Output position.

ShiftFont:
        MOVE.L  A1,A2           Save start of output buffer.
        MOVE.W  #899,D0
.Loop1  MOVE.L  (A0)+,(A2)+     Copy the font into the buffer.
        MOVE.L  (A0)+,(A2)+
        MOVE.L  (A0)+,(A2)+
        MOVE.L  (A0)+,(A2)+
        DBRA    D0,.Loop1	Loop.
        
        MOVE.W  #17999,D7	Lotta stuff to shift! (over 200K)
.Loop2        
        MOVE.W  (A1)+,D0	3 bit planes into data registers.
        MOVE.W  (A1)+,D1	(16 pixels worth)
        MOVE.W  (A1)+,D2
        SWAP    D0		Move them into the high words of the 
        SWAP    D1		data registers.
        SWAP    D2
        MOVE.W  (A1)+,D0	Load 3 bit planes for next 16 pixels.
        MOVE.W  (A1)+,D1
        MOVE.W  (A1)+,D2
        ROR.L   #1,D0		Rotate the pixels around in the registers.
        ROR.L   #1,D1
        ROR.L   #1,D2
        SWAP    D0		Swap high and low words.
        SWAP    D1
        SWAP    D2
        MOVE.W  D0,(A2)+	Store first 16 pixels of data.
        MOVE.W  D1,(A2)+
        MOVE.W  D2,(A2)+
        SWAP    D0		Swap high and low words back again.
        SWAP    D1
        SWAP    D2
        MOVE.W  D0,(A2)+	Store second 16 pixels of data.
        MOVE.W  D1,(A2)+
        MOVE.W  D2,(A2)+
        DBRA    D7,.Loop2	Next line.
        RTS			All done.

***************
* Set palette *
***************
* Routine to set up the palette:
* Parameters:
* A0 = Position of the palette.

SetPalette:
        LEA     $FFFF8240.W,A1	Load the address of the video palette.
        MOVEQ   #7,D0		8 long words to move.
.Loop
        MOVE.L  (A0)+,(A1)+	Copy the palette.
        DBRA    D0,.Loop	Next longword.
        RTS			All done.

*****************
* Offset scroll *
*****************
* Routine to locate the characters in the font and to move the offsets.
OffScroll:
	LEA	CharPointers(PC),A0		Get position of character offsets.
	REPT	5			Shift them all down by one place.
	MOVE.L	2(A0),(A0)+
	ENDR
	MOVE.L	PositionInText(PC),A1	Find current position in message.
	MOVEQ	#0,D0
	MOVE.B	(A1),D0			Get new character from that position.
	LEA	CharTable(PC),A1	Find ascii table.
	MOVE.B	0(A1,D0.W),D0		Get font position of the character.
	MULU	#300,D0			Calculate actual position.
	ADD.W	#288,D0			Point to end for the scroller.
	MOVE.W	D0,-(A0)		Store the position.
	ADDQ.L	#1,PositionInText	Move pointer to next character.
	MOVE.L	#EndText,D0
	CMP.L	PositionInText(PC),D0	At end?
	BNE.S	.Exit			No, then leave routine.
	MOVE.L	#Message,PositionInText	Restart message.
.Exit
	RTS		All finished.

****************
* Clear lines. *
****************
* Routine to clear the spaces between the lines.
* Parameters:
* A6 = position to start clearing (start of the line below)
* D7 = Number to clear - 1.
ClearLines:
	MOVEQ	#0,D0	Clear 12 registers.
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.L	D0,D4
	MOVE.L	D0,D5
	MOVE.L	D0,D6
	MOVE.L	D0,A0
	MOVE.L	D0,A1
	MOVE.L	D0,A2
	MOVE.L	D0,A3
	MOVE.L	D0,A4
.Loop	
	REPT	10
	MOVEM.L	D0-D6/A0-A4,-(A6)	Clear 3 lines.
	ENDR
	LEA	-4000(A6),A6		Next block of lines to clear.
	DBRA	D7,.Loop
	RTS

***********************************************
* Volume bar plotter and associated routines. *
***********************************************

PlotSoundBars:
* Read the volume on all three channels.
	MOVE.B	#8,(SoundReg).W		Select register 8(channel 1 volume)
	MOVEQ	#0,D0			Clear D0.
	MOVE.B	(SoundReg).W,D0		Get volume byte.
	MOVE.B	#9,(SoundReg).W		Channel 2.
	MOVEQ	#0,D1
	MOVE.B	(SoundReg).W,D1
	MOVE.B	#10,(SoundReg).W	Channel 3.
	MOVEQ	#0,D2
	MOVE.B	(SoundReg).W,D2

* Put value of 10 if chip waveform.	(not needed for this music)
	CMPI.B	#15,D0
	BLE.S	.B1
	MOVEQ	#10,D0
.B1
	CMPI.B	#15,D1
	BLE.S	.B2
	MOVEQ	#10,D1
.B2
	CMPI.B	#15,D2
	BLE.S	.B3
	MOVEQ	#10,D2
.B3

	MOVE.W	D1,D7
	LSR.W	#1,D7
	MOVE.W	D7,D6
	LSL.W	#4,D6
	OR.W	D7,D6
	LSL.W	#4,D6
	OR.W	D7,D6
	MOVE.W	D6,$FFFF824E.W


	MOVEQ	#-2,D4	Data for bar. (with 1 pixel gap)

	MOVE.L	ScreenPos,A0	Get position of the screen.

	TST.W	D0		No lines to plot on channel 1?
	BEQ.S	.B4		Then skip.
	LEA	6+128+(160*48)(A0),A1	Get positions of the 2 halves.
	LEA	320(A1),A2
	SUBQ.W	#1,D0		One less for DBRA count.
.Loop1
	MOVE.W	D4,(A1)		Plot bars.
	MOVE.W	D4,-120(A1)
	MOVE.W	D4,(A2)
	MOVE.W	D4,-120(A2)
	
	LEA	-320(A1),A1	Next positions.
	LEA	320(A2),A2
	
	DBRA	D0,.Loop1	Loop.
.B4

	TST.W	D1		Channel 2
	BEQ.S	.B5
	LEA	6+8+128+(160*48)(A0),A1
	LEA	320(A1),A2
	
	SUBQ.W	#1,D1
.Loop2
	MOVE.W	D4,(A1)
	MOVE.W	D4,-120(A1)
	MOVE.W	D4,(A2)
	MOVE.W	D4,-120(A2)
	
	LEA	-320(A1),A1
	LEA	320(A2),A2
	
	DBRA	D1,.Loop2
.B5
	
	TST.W	D2		Channel 3.
	BEQ.S	.B6
	LEA	6+16+128+(160*48)(A0),A1
	LEA	320(A1),A2
	SUBQ.W	#1,D2
.Loop3
	MOVE.W	D4,(A1)
	MOVE.W	D4,-120(A1)
	MOVE.W	D4,(A2)
	MOVE.W	D4,-120(A2)
	
	LEA	-320(A1),A1
	LEA	320(A2),A2
	
	DBRA	D2,.Loop3
.B6
	
	RTS		Bye bye.

***********************************************************************
* The one bit plane byte bender scroller at the bottom of the screen. *
***********************************************************************
* Parameters:
* A0 = Position of the screen.
* A1 = Position of the font.
* A2 = Position of the font offset table.
* A3 = Position of the dist table.
ByteBend:
	ADDA.L	#(125*160)+6,A0	Move to bottom of screen and correct bit plane.
	MOVEQ	#19,D7		20 16-pixel wide blocks to plot.
ByteLoop:
	PlotByteColumn		Plot first 8 pixel column.
	ADDQ.W	#1,A0		Move to next 8 pixels.
	PlotByteColumn		Plot second 8 pixel column.
	ADDQ.W	#7,A0		Move to next block.
	DBRA	D7,ByteLoop	Loop.
	RTS			Bye bye.

*********************************************
* Move the byte bender scrolline in memory. *
*********************************************
ByteBendOffsetScroll:
	LEA	ByteFontOffsetTable,A0	Load table position.
	MOVEM.L	2(A0),D0-D7/A1-A6	Move all the character offsets.
	MOVEM.L	D0-D7/A1-A6,(A0)		"
	MOVEM.L	58(A0),D0-D5			"
	MOVEM.L	D0-D5,56(A0)			"
	MOVE.L	BytePositionInText,A1	Find position in the message.
	MOVE.W	ByteFinePosition,D0	Find position in character.
	MOVEQ	#0,D1			Clear D1.
	CMPI.W	#56,D0
	BEQ.S	LastColumn
	CMPI.W	#64,D0			At the end of a charater?
	BEQ.S	SmallSpace		Yes, then branch.
	MOVE.B	(A1),D1			Get current character.
	LEA	ByteCharTable,A2	/Find position in the font.
	MOVE.B	(A2,D1.W),D1		|
	LSL.W	#6,D1			\
	ADD.W	D0,D1			Add position into the character.
	MOVE.W	D1,78(A0)		Store this offset in the table.
ByteBendReturn:
	ADD.W	#8,D0			Increment position in character...
	MOVE.W	D0,ByteFinePosition	 .. and store it.
	RTS

LastColumn:
	CLR.W	78(A0)
	BRA.S	ByteBendReturn
	
SmallSpace:
	MOVE.W	D1,78(A0)		Clear offset. (Blank space)
	MOVE.W	D1,ByteFinePosition	Clear fine position.
	ADDQ.L	#1,A1			Next character.
	CMPA.L	#ByteMessageEnd,A1	Reached end of message?
	BNE.S	.Exit			No, then branch.
	LEA	ByteMessage,A1		Reset pointer.
.Exit
	MOVE.L	A1,BytePositionInText	Save current position in message.
	RTS				Bye bye.


*******************************************
* Routine to plot the logo on the screen. *
*******************************************
* oops I don't think this is the latest version,
* but I can't find the newer one.
PlotLogo:
	MOVE.L	ScreenPos,A0	Get screen position.
	MOVE.W	LogoOffset,D0	Get offset.
	LEA	VWaveform,A1
	ADDA.W	0(A1,D0.W),A0	Add offset.
	ADDQ.W	#2,LogoOffset
	LEA	ShiftedLogo,A1		Get data position.
	LEA	(160*50)+32(A0),A0
	MOVE.L	A1,A3
	MOVE.L	A0,A4
	LEA	LogoDistort(PC),A2
	ADD.W	LogoDistortPosition(PC),A2

	
* Logo format:
* 1 long word mask
* 2 long words data
	REPT	32	
	MOVE.W	(A2)+,D0
	LEA	0(A4,D0.W),A0
	MOVE.W	(A2)+,D0
	LEA	0(A3,D0.W),A1
	MOVEM.L	(A0),D0-D7
	AND.L	(A1),D0
	AND.L	(A1)+,D1
	OR.L	(A1)+,D0
	OR.L	(A1)+,D1
	AND.L	(A1),D2
	AND.L	(A1)+,D3	
	OR.L	(A1)+,D2
	OR.L	(A1)+,D3
	AND.L	(A1),D4
	AND.L	(A1)+,D5
	OR.L	(A1)+,D4
	OR.L	(A1)+,D5
	AND.L	(A1),D6
	AND.L	(A1)+,D7
	OR.L	(A1)+,D6
	OR.L	(A1)+,D7
	MOVEM.L	D0-D7,(A0)
	LEA	48(A3),A3
	LEA	160(A4),A4
	ENDR
	
	ADDQ.W	#4,LogoOffset	Increment offset.
	CMPI.W	#VWaveformEnd-VWaveform,LogoOffset
	BMI.S	.OffsetOK
	CLR.W	LogoOffset
.OffsetOK

	ADDQ.W	#4,LogoDistortPosition	Increment offset.
	CMPI.W	#2140,LogoDistortPosition
	BMI.S	.LogoDistortOK
	CLR.W	LogoDistortPosition
.LogoDistortOK
	
	RTS			Bye bye.

**********************
* Interrupt Routines *
**********************

* Keyboard handling routine. (Doesn't do anthing much)
**********

HBL_HANDLER
	MOVE.L	A0,USP		Save D0.
MOD	MOVE.L	Rasters(PC),A0	Load new colour.
*		  ^ self modifying code.

	MOVE.L	A0,$FFFF8250.W	Set the palette colours with new colour.
	MOVE.L	A0,$FFFF8254.W
	MOVE.L	A0,$FFFF8258.W
	MOVE.L	A0,$FFFF825C.W
	
	ADDQ.W	#4,MOD+2	Self-modify code to point at next colour.
	
	MOVE.L	USP,A0		Restore D0.
	        
        RTE		All done.


**********

VBL_HANDLER
        MOVEM.L D0-D7/A0-A6,-(SP)	Save all registers.
*	LEA	Rasters-4(PC),A0
*	ADDA.W	RasterOffset,A0
*	MOVE.L	(A0),D0
	
*	MOVE.L	D0,$FFFF8250.W	Set the palette colours with new colour.
*	MOVE.L	D0,$FFFF8254.W
*	MOVE.L	D0,$FFFF8258.W
*	MOVE.L	D0,$FFFF825C.W

        MOVE.B  #0,(TBCR).W		Set up raster routine.
        MOVE.L  #HBL_HANDLER,(HBL_VEC).W
        MOVE.B  #15,(TBDR).W
        MOVE.B  #8,(TBCR).W
        MOVE.W  #$FFFF,VBLFlag
        MOVE.B  #3,(TBDR).W
	MOVE.W	RasterPointer,D0
	ADD.W	RasterOffset,D0
	MOVE.W	D0,MOD+2		Reset self-modifying code.
	ADDQ.W	#4,RasterOffset
	CMPI.W	#85*4,RasterOffset
	BMI.S	RastersOK
	MOVE.W	#0,RasterOffset
RastersOK:

	BSR	Music+30
        MOVEM.L (SP)+,D0-D7/A0-A6	Restore all registers.
	RTE
        
	
****************
* Data section *
****************

SECTION DATA

* Standard palette for the demo.
* Upper 8 colours set to white for the 1 bit plane scroller.
Palette:
        DC.W    $000                                             
        DC.W    $200
        DC.W    $310
        DC.W    $420
        DC.W    $530
        DC.W    $640
        DC.W    $750
        DC.W    $777
        DC.W    $777
        DC.W    $777
        DC.W    $777
        DC.W    $777
        DC.W    $777
        DC.W    $777
        DC.W    $777
        DC.W    $777

	DC.L	$6010601
Rasters:
	REPT	4
	INCBIN	GIGADIST.INC\GIGARAST.PAL
	ENDR
	
	EVEN
* Ascii character table:
CharTable:
	DCB.B	16,0
	DC.B	31,32,33,34,35,36,37,38,39,40
	DCB.B	6,0
	DC.B	0,27,41,45,45,45,45,47,42,43,45,45,44,45,46,45
	DC.B	31,32,33,34,35,36,37,38,39,40
	DC.B	29,30,45,45,45,28,45
	DC.B	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
	DC.B	42,45,43,47,45,47
	DC.B	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
	DC.B	42,45,43,45
	DCB.B	129,0

	
	EVEN

ByteDist	
 DC.W  0 
 DC.W  160 
 DC.W  320 
 DC.W  480 
 DC.W  640 
 DC.W  800 
 DC.W  960 
 DC.W  1120 
 DC.W  1280 
 DC.W  1440 
 DC.W  1600 
 DC.W  1600 
 DC.W  1760 
 DC.W  1920 
 DC.W  1920 
 DC.W  2080 
 DC.W  2080 
 DC.W  2240 
 DC.W  2240 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2240 
 DC.W  2240 
 DC.W  2080 
 DC.W  2080 
 DC.W  1920 
 DC.W  1920 
 DC.W  1760 
 DC.W  1600 
 DC.W  1600 
 DC.W  1440 
 DC.W  1280 
 DC.W  1120 
 DC.W  960 
 DC.W  800 
 DC.W  640 
 DC.W  480 
 DC.W  320 
 DC.W  160 
 DC.W  0 
 DC.W -160 
 DC.W -320 
 DC.W -480 
 DC.W -640 
 DC.W -800 
 DC.W -960 
 DC.W -1120 
 DC.W -1280 
 DC.W -1440 
 DC.W -1600 
 DC.W -1600 
 DC.W -1760 
 DC.W -1920 
 DC.W -1920 
 DC.W -2080 
 DC.W -2080 
 DC.W -2240 
 DC.W -2240 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2240 
 DC.W -2240 
 DC.W -2080 
 DC.W -2080 
 DC.W -1920 
 DC.W -1920 
 DC.W -1760 
 DC.W -1600 
 DC.W -1600 
 DC.W -1440 
 DC.W -1280 
 DC.W -1120 
 DC.W -960 
 DC.W -800 
 DC.W -640 
 DC.W -480 
 DC.W -320 
 DC.W -160 

ByteDistEnd
 DC.W  0 
 DC.W  160 
 DC.W  320 
 DC.W  480 
 DC.W  640 
 DC.W  800 
 DC.W  960 
 DC.W  1120 
 DC.W  1280 
 DC.W  1440 
 DC.W  1600 
 DC.W  1600 
 DC.W  1760 
 DC.W  1920 
 DC.W  1920 
 DC.W  2080 
 DC.W  2080 
 DC.W  2240 
 DC.W  2240 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2400 
 DC.W  2240 
 DC.W  2240 
 DC.W  2080 
 DC.W  2080 
 DC.W  1920 
 DC.W  1920 
 DC.W  1760 
 DC.W  1600 
 DC.W  1600 
 DC.W  1440 
 DC.W  1280 
 DC.W  1120 
 DC.W  960 
 DC.W  800 
 DC.W  640 
 DC.W  480 
 DC.W  320 
 DC.W  160 
 DC.W  0 
 DC.W -160 
 DC.W -320 
 DC.W -480 
 DC.W -640 
 DC.W -800 
 DC.W -960 
 DC.W -1120 
 DC.W -1280 
 DC.W -1440 
 DC.W -1600 
 DC.W -1600 
 DC.W -1760 
 DC.W -1920 
 DC.W -1920 
 DC.W -2080 
 DC.W -2080 
 DC.W -2240 
 DC.W -2240 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2400 
 DC.W -2240 
 DC.W -2240 
 DC.W -2080 
 DC.W -2080 
 DC.W -1920 
 DC.W -1920 
 DC.W -1760 
 DC.W -1600 
 DC.W -1600 
 DC.W -1440 
 DC.W -1280 
 DC.W -1120 
 DC.W -960 
 DC.W -800 
 DC.W -640 
 DC.W -480 
 DC.W -320 
 DC.W -160 

VWaveform:
	
 DC.W  0 
 DC.W -160 
 DC.W -160 
 DC.W -320 
 DC.W -480 
 DC.W -480 
 DC.W -640 
 DC.W -800 
 DC.W -960 
 DC.W -960 
 DC.W -1120 
 DC.W -1120 
 DC.W -1280 
 DC.W -1440 
 DC.W -1440 
 DC.W -1600 
 DC.W -1760 
 DC.W -1760 
 DC.W -1920 
 DC.W -1920 
 DC.W -2080 
 DC.W -2080 
 DC.W -2240 
 DC.W -2240 
 DC.W -2400 
 DC.W -2400 
 DC.W -2560 
 DC.W -2560 
 DC.W -2720 
 DC.W -2720 
 DC.W -2720 
 DC.W -2880 
 DC.W -2880 
 DC.W -2880 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -2880 
 DC.W -2880 
 DC.W -2880 
 DC.W -2720 
 DC.W -2720 
 DC.W -2720 
 DC.W -2560 
 DC.W -2560 
 DC.W -2400 
 DC.W -2400 
 DC.W -2240 
 DC.W -2240 
 DC.W -2080 
 DC.W -2080 
 DC.W -1920 
 DC.W -1920 
 DC.W -1760 
 DC.W -1760 
 DC.W -1600 
 DC.W -1440 
 DC.W -1440 
 DC.W -1280 
 DC.W -1120 
 DC.W -1120 
 DC.W -960 
 DC.W -960 
 DC.W -800 
 DC.W -640 
 DC.W -480 
 DC.W -480 
 DC.W -320 
 DC.W -160 
 DC.W -160 

VWaveFormEnd:
 DC.W  0 
 DC.W -160 
 DC.W -160 
 DC.W -320 
 DC.W -480 
 DC.W -480 
 DC.W -640 
 DC.W -800 
 DC.W -960 
 DC.W -960 
 DC.W -1120 
 DC.W -1120 
 DC.W -1280 
 DC.W -1440 
 DC.W -1440 
 DC.W -1600 
 DC.W -1760 
 DC.W -1760 
 DC.W -1920 
 DC.W -1920 
 DC.W -2080 
 DC.W -2080 
 DC.W -2240 
 DC.W -2240 
 DC.W -2400 
 DC.W -2400 
 DC.W -2560 
 DC.W -2560 
 DC.W -2720 
 DC.W -2720 
 DC.W -2720 
 DC.W -2880 
 DC.W -2880 
 DC.W -2880 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3200 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -3040 
 DC.W -2880 
 DC.W -2880 
 DC.W -2880 
 DC.W -2720 
 DC.W -2720 
 DC.W -2720 
 DC.W -2560 
 DC.W -2560 
 DC.W -2400 
 DC.W -2400 
 DC.W -2240 
 DC.W -2240 
 DC.W -2080 
 DC.W -2080 
 DC.W -1920 
 DC.W -1920 
 DC.W -1760 
 DC.W -1760 
 DC.W -1600 
 DC.W -1440 
 DC.W -1440 
 DC.W -1280 
 DC.W -1120 
 DC.W -1120 
 DC.W -960 
 DC.W -960 
 DC.W -800 
 DC.W -640 
 DC.W -480 
 DC.W -480 
 DC.W -320 
 DC.W -160 
 DC.W -160


LogoDistort:
	INCLUDE	GIGADIST.INC\WAVE1.S
	INCLUDE	GIGADIST.INC\WAVE3.S
	INCLUDE	GIGADIST.INC\WAVE4.S
	INCLUDE	GIGADIST.INC\WAVE2A.S
	INCLUDE	GIGADIST.INC\WAVE5.S
	INCLUDE	GIGADIST.INC\WAVE6.S
	INCLUDE	GIGADIST.INC\WAVE7.S
	INCLUDE	GIGADIST.INC\WAVE2B.S
	INCLUDE	GIGADIST.INC\WAVE1.S
	INCLUDE	GIGADIST.INC\WAVE2A.S
	INCLUDE	GIGADIST.INC\WAVE5.S
	INCLUDE	GIGADIST.INC\WAVE8.S
	INCLUDE	GIGADIST.INC\WAVE2B.S
	INCLUDE	GIGADIST.INC\WAVE1.S
	INCLUDE	GIGADIST.INC\WAVE3.S
	
ByteMessageStart
	INCBIN	GIGADIST.INC\BBSTART.TXT
ByteMessage	
	INCBIN	GIGADIST.INC\NEWTEXT.TXT
ByteMessageEnd

	EVEN
* Ascii character table for the byte bender.
ByteCharTable:
	DCB.B	32,0
	DC.B	0,28,33,0,0,0,0,33,31,32,33,34,29,34,30,0
	DCB.B	10,0
	DC.B	34,34,31,34,32,27,1
	DC.B	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
	DC.B	31,34,32,33,0,33
	DC.B	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
	DC.B	31,34,33,34
	DCB.B	129,0

BytePositionInText	DC.L	ByteMessageStart
ByteFinePosition	DC.W	0
ByteDistPosition	DC.L	ByteDist

* 10 words of offsets into the font showing which characters to plot.
CharPointers	DC.W	288,288,288,288,288,288,288,288,288,288

HiddenText:
	INCBIN	GIGADIST.INC\MAD2.TXT
	
MessageStart:
	DCB.B	70,' '
Message:
* The message that is scrolled with the V-Dist scroller.
	INCBIN	GIGADIST.INC\MAD1.TXT

EndText:
* Marker of the end of the message.

LinePos		DC.W	0	Fine position of the scroller. (0-27*160)
LinePos2	DC.W	0	Fine position of the scroller. (0-27)
DistortPosition	DC.W	0	Position in the distort table.
ByteVerticalPosition	DC.W	0
PositionInText	DC.L	MessageStart	Current position in the message.
RasterOffset	DC.W	0
LogoOffset	DC.W	0
SpriteWavePointer	DC.W	0
SpriteVWavePointer	DC.W	0
LogoDistortPosition	DC.W	0	Offset into the distort table.

ExitFlag	DC.W	0

        EVEN 
* The main font for the background.
Font:
        DCB.B   300,0
        INCBIN  GIGADIST.INC\AMIGFONT.SPR

* The 8 by 8 one bit plane font.
TinyFont:
	INCBIN	GIGADIST.INC\MEDIFONT.SPR

	EVEN
* The three bit plane St-Squad logo.
Logo:
	INCBIN	GIGADIST.INC\LOGO.SPR

* The one bit plane sprites.
Sprites:
	INCBIN	GIGADIST.INC\SPRITES.SPR

***************
* BSS Section *
***************

SECTION BSS

        DS.L    200		Standard stack space.
Stack   DS.W    1

OldSSP  	DS.L    1	Storage for the old supervisor stack pointer.
ScreenPos       DS.L    1	Storage for the pointers to the screen.
ScreenPos2      DS.L    1
TrueScreenPos   DS.L    1	Original position of the screen.
OldPalette      DS.L    8	Storage for the original colour palette.
LineCount	DS.W	1	Counter for number of lines drawn.
OldMode		DS.W	1	Old screen mode.
RasterPointer	DS.W	1	PC Pointer to the Raster table.

OLD_VBL_VEC	DS.L	1
OLD_KEY_VEC	DS.L	1
OLD_HBL_VEC     DS.L    1
OLD_IEB         DS.B    1
OLD_IEA         DS.B    1
OLD_IMA         DS.B    1
VBLFlag         DS.W    1

ByteFontOffsetTable	DS.W	41
ByteFont	DS.B	2300

ShiftedSprites	DS.B	2048

ShiftedFont     DS.W    115200	Storage for the pre-shifted font. (big eh?)

ShiftedLogo	DS.W	12288

SecondScreenStore       DS.B    32600	Storage for the second screen.
			DS.B    32600
