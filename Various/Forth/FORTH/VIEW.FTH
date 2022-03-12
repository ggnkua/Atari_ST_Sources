( view.fth)
( an example made from the edit.fth (which you don't have). To view a file,
  type 'view'.)

forth definitions also GEM also assembler
decimal

variable VIEWADDR	( holds address of base of file in mem)
variable VIEWLENGTH	( length of file)
variable OldToFrontVec	( holds what is normally executed)
variable VIEWBUFFER	( used to hold filename=window title)
20 vallot
variable REDRAWBUFFER	( used to output all the text)
400 vallot		( that's enough for 200 chars/line)
variable TOPLINEADDR	( addr of first character or preceding cr in view)
variable BOTLINEADDR	( addr of 1st char (cr or 0) in next line outofview)
variable #LINES		( number of lines allowed by cur window size)

variable FONTHEIGHT
variable FONTWIDTH
variable ClipRect
4 vallot


hex
New.Window VIEWW
binary
000111101011 VIEWW ITEMS ( title,close,move,size,up,down,vertSlid)
decimal

1200 1200 Terminal VIEWT

104 user PenLoc
116 user ButtonVec
132 user MenuSelVec	( will zero so no inadvertent printing)
136 user RedrawVec
140 user ToFrontVec	( same as Activate)
144 user CloseVec
152 user ArrowVec
160 user VScrollVec
172 user ToppedVec	( called before ToFront, is Deactivate)
176 user W3
178 user W4

60 user FileID
2 constant R/W
create Path			( initial path displayed)
	DC.B	'A:\*.*'
	DC.B	0		( all strings must be null-terminated)
	DCB.B	20,0

create Selection		( initial selection displayed)
	DC.B	'X.X'
	DC.B	0		( all strings must be null-terminated)
	DCB.B	20,0

: OpenFile2	( use FileSel to open a file. Put handle in FileID)
	Path Selection CALL FSelInput
	IF ( test result code)
	 IF ( non-zero if OK button pushed)
	  Selection R/W CALL fOpen
	   dup 0> IF ( test result code, less than 0 if error. Try to create it)
		FileID w!
	      ELSE
	       drop 0 FileID w!
	      THEN
	  ELSE 0 FileID w! ( cancel button was pushed)
	  THEN
	 ELSE 0 FileID w! ( error on open)
	 THEN
	;

: AllocMem
	Selection 0 CALL fsFirst drop	( put info about file in DTA)
	CALL fGetDTA		( get address for file info)
	26 +			( address of size of file)
	@ VIEWLENGTH !
	ViewLength @ 10 +
	CALL MAlloc
	dup 0> IF 2+ VIEWADDR !	( leave space for a 0D to say 'beginoffile')
		ELSE drop	( not enough memory)
		THEN
	;


CODE CursorOff	( this messes up the A2)
	MOVE.L	A2,-(A7)	( so save it)
	DC.W	$A00A		( turn cursor off)
	MOVE.L	(A7)+,A2	( and restore it)
	RTS
END-CODE MACH
: CursorOn 1 call vShowC ;

: ReadIn			( read the file into memory)
	0 FileID w@ 0 call fSeek drop	( start from beginning)
	13 VIEWADDR @ 2- w!	( put in the begin-of-file mark-dummy CR)
	FileID w@		( handle)
	VIEWLENGTH @		( count)
	VIEWADDR @		( addr)
	CALL fRead drop		( Read in and drop result)
	0 VIEWLENGTH @ VIEWADDR @ + c!	( end-of-file mark)
	;

: GetFontInfo { | addr } ( vqtA... returns two addresses at the moment)
		( 2nd addr is PtsOut array. PO(3) is height,PO(2) is width)
		( THIS SHOULD BE DONE ON EVERY W2FRONT - CLS,too)
	call vqtAttributes drop -> addr
	addr 6 + w@ FontHeight !
	addr 4 + w@ FontWidth !
	;

: HowManyLines	( updates #LINES according to window size)
	VIEWW 26 + w@	( height of work area of window)
	FontHeight @ /	( divided by the fontHeight is the number of lines)
	#LINES !
	;


create CursorForm	( from p.7-19 GEM VDI guide)
	DC.W	6	( x-coord of hot spot rel to top left)
	DC.W	4	( y-coord of hot spot rel to top left)
	DC.W	1	( reserved, always 1)
	DC.W	0	( color to set bits corr.ing to 1's in mask)
	DC.W	2	( color to set bits corr.ing to the 1's in data)

	DC.W	%0000000000000000	( 1st line of 16 lines of mask)
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000

	DC.W	%0000010100000000	( 1st line of 16 lines of data)
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000010100000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000000

: ChangeCursor
	CursorForm call vscForm
	;


CODE ExpandTabs	( for now, just change tabs to spaces)
	MOVE.W	#$20,D1
	RTS
END-CODE

( Given count=#cols in window, and addr of text in VIEW file, fillout
  RedrawBuffer array with word characters and/or spaces. Return next
  addr to draw from)
 
CODE FillArray	( count,addr1--addr2) ( expand out tabs, too)
	MOVE.L	(A6)+,A0	( addr= where to get byte characters)
	LEA	RedrawBuffer,A1	( where to put word characters)
	MOVE.L	(A6)+,D0	( #cols)
	MOVEQ.L	#0,D2		( used by ExpandTabs for correct spacing)
	MOVEQ.L	#0,D1		( for holding the byte=>word characters)
	TST.B	(A0)
	BEQ.S	@5		( fill with all spaces if at end)
				( only accept CR<LF> as a line)
	CMPI.B	#$0D,(A0)	( skip over preceding cr's lf's)
	BNE.S	@1
	ADDQ.L	#1,A0
	CMPI.B	#$0A,(A0)
	BNE.S	@1
	ADDQ.L	#1,A0

@1	MOVE.B	(A0),D1
	BEQ.S	@5		( was a zero=end-of-file, fill out withzer)
	CMPI.B	#$0D,D1		( was start of next line, fill out)
	BEQ.S	@5
	CMPI.B	#$09,D1		( was it a tab?)
	BNE.S	@3		( expand out with spaces)
	BSR.S	ExpandTabs	( and return to here with 20 in D1)
@3	MOVE.W	D1,(A1)+	( move word character into place)
	ADDQ.L	#1,A0		( go to next char in file)
	ADDQ.L	#1,D2		( increment column position)
	SUBQ.L	#1,D0		( decrement number-of-chars-to-write)
	BGT.S	@1		( only do #cols letters)
				( get rid of excess characters)
@2	MOVE.B	(A0),D1		( only in case of a long line)
	BEQ.S	@6		( this zero at the end is real crucial)
	CMPI.B	#$0D,D1
	BEQ.S	@6
	ADDQ.L	#1,A0
	BRA.S	@2
				( fill out rest, if any, of array)
@5	MOVE.W	#$20,(A1)+
	DBF	D0,@5

@6	MOVE.L	A0,-(A6)	( return address )
	RTS
END-CODE

: ClipOn	( turn clipping on to working rect of VIEWW)
	VIEWW 20 + @ ClipRect !		( x,y)
	VIEWW 20 + @ ClipRect 4 + !	( x,y)
	VIEWW 24 + @ ClipRect 4 + +!	( x,y + width,height)
	ClipRect 1 call vsClip		( turn clipping on)
	;

: ClipOff	( turn all clipping off again)
	ClipRect 0 call vsClip
	;

 
: InitPen { | x y -- x y }	( must use absolute coordinates)
	7 -> x			( relative x start)
	FontHeight @ 2+ -> y	( relative y start)
	VIEWW 20 + w@ x + -> x	( absolute of x start)
	VIEWW 22 + w@ y + -> y	( absolute of y start)
	x y
	;



: DoView { | x y count1 addr }	( redraw all the text in the window)
	CursorOff
	GetFontInfo	( in case someone changes it for fun)
	1 call vswrMode drop	( 'cuz scroll vbar will mess up wrMode)
	ClipOn			( will clip the printing, no pause)
	InitPen -> y -> x	( init pseudo-pen)
	#cols 100 min -> count1	( instead of CLS, will space out extras)
	TopLineAddr @ -> addr	( marches thru file)
	#lines @ 1 do
	  count1 addr FillArray -> addr		( fill in for a line)
	  x y count1 RedrawBuffer call vgtext	( print out a line)
	  y FontHeight @ + -> y			( move 'pen' to next line)
	loop
	ClipOff
	CursorOn
	;


code NextRow ( addr--addr) ( given addr of begin (cr) of row, return next)
	MOVE.L	(A6)+,A0
@1	ADDQ.L	#1,A0		( skip first cr. search 'til)
	CMPI.B	#13,(A0)	( carriage return)
	BEQ.S	@2		( or)
	TST.B	(A0)		( end of file)
	BEQ.S	@2
	BRA.S	@1
@2	MOVE.L	A0,-(A6)
	RTS
end-code

code PrevRow ( addr--addr) ( given addr of begin (cr) of row, return prev)
	MOVE.L	(A6)+,A0
@1	SUBQ.L	#1,A0		( search 'til)
	CMPI.B	#13,(A0)	( carriage return)
	BEQ.S	@2		( or)
	TST.B	(A0)		( begin of file)
	BNE.S	@1
	ADDQ.L	#1,A0		( don't stay on a zero)
@2	MOVE.L	A0,-(A6)
	RTS
end-code

: AdjustLines	( given #Lines and TOPLINEADDR, this sets BOTLINEADDR)
	TOPLINEADDR @
	#Lines @ 2
		DO
		 NextRow
		LOOP
	BOTLINEADDR ! ;

: InitVars
	GetFontInfo
	HowManyLines
	VIEWADDR @ TOPLINEADDR !
	AdjustLines
	CLS
	;

: SetTitle { | saddr daddr count2 }
	Selection -> saddr
	VIEWBuffer 1+ -> daddr
	0 -> count2
	BEGIN
	 saddr c@ WHILE
	  saddr c@ daddr c!	( move char into place)
	  saddr 1+ -> saddr	( increment source pointer)
	  daddr 1+ -> daddr	( increment dest pointer)
	  count2 1+ -> count2	( increment count)
	REPEAT
	count2 VIEWBuffer c!	( put count at beginning of string)
	VIEWBuffer VIEWW TITLE	( set the title)
	;
	
: ShowWindow	( if VIEW hasn't been called yet, ADD the window, else
		   SHOW it)
	SetTitle	( using Selection, have the filename as title)
	VIEWADDR @	( zero if VIEW not been used yet)
	 IF		( just diplay VIEWWindow)
	  VIEWW 2+ w@	( window handle)
	  VIEWW 12 + w@	( window's x-coord)
	  VIEWW 14 + w@	( window's y-coord)
	  VIEWW	16 + w@	( window's width)
	  VIEWW 18 + w@ ( window's height)
	  CALL WindOpen drop ( drop result)
	 ELSE		( else actually add it)
	  VIEWW ADD
	 THEN
	  VIEWW 2+ w@ 10 0 0 0 0 CALL WindSet drop ( bring window to front)
	;


: RePositionBox { | newPos }
	TopLineAddr @ VIEWADDR @ -  1000 * ( position)
	VIEWLENGTH @		( total)
	/ -> newPos		( a number from 0-1000)
			( now actually place the box)
	VIEWW 2+ w@	( window handle)
	9		( means 'change vBox position')
	newPos		( has a number from 0-1000 as req position of box)
	0 0 0		( junk. WindSet REQUIRES 6 things on the stack)
	CALL WindSet	( do it)
	drop		( ignore result)
	1 call vswrmode drop
	;


: PageDown
	BOTLINEADDR @ TOPLINEADDR !
	;

: PageUp
	TOPLINEADDR @
	#LINES @ 2
		DO
		 PrevRow
		LOOP
	TOPLINEADDR !
	;

: RowDown
	TOPLINEADDR @ NextRow TOPLINEADDR !
	;

: RowUp
	TOPLINEADDR @ PrevRow TOPLINEADDR !
	;

: HandleArrows	( when the guy clicks in the arrows and all)
	 W4 w@	( code for what happened)
	 CASE	0 OF PageUp ENDOF
		1 OF PageDown ENDOF
		2 OF RowUp ENDOF
		3 OF RowDown ENDOF
	 ENDCASE
	 RePositionBox	( 'cuz a lot of paging should move box)
	 HowManyLines	( because a size could have happened)
	 AdjustLines
	 DoView
	;

: HandleRedraw
	HowManyLines
	AdjustLines
	CLS
	DoView
	;


: DoVScroll	( adjust the view according to where the guy put the box)
( first, actually place the box)
	VIEWW 2+ w@	( window handle)
	9		( means 'change vBox position')
	W4 w@		( has a number from 0-1000 as req position of box)
	0 0 0		( junk. WindSet REQUIRES 6 things on the stack)
	CALL WindSet	( do it)
	drop		( ignore result)

( now, redo the view)
	VIEWLENGTH @	( estimate an address according to the box)
			( and adjust TOPLINEADDR)
	 
	  W4 w@ 999 min 1000 */
	  VIEWADDR @ +
	  PrevRow
	  TOPLINEADDR !
	 		( now adjust BOTTOM)
	AdjustLines
	DoView
	;



: DoClose
	Close-File			( I forget what this does)
	VIEWADDR @ 2- call MFree drop	( de-allocate memory)
	VIEWW 2+ w@ call WindClose drop	( make window go away)
	OldToFrontVec @ ToFrontVec !	( put it back)
	SLEEP STATUS W!			( put task to sleep)
	-1 VIEWADDR !			( if -1, then was open)
	0 VIEWLENGTH !
	PAUSE
	;				( go to next task)

: HandleToFront
	['] HandleRedraw RedrawVec !
	OldToFrontVec @ execute
	ChangeCursor
	;

: HandleTopped		( when put to back, restore cursor adn turn off
			redrawing)
	0 RedrawVec !
	0 0 call grafMouse drop
	;

: InstallVecs
0   MenuSelVec !
['] DoClose CloseVec !
['] HandleArrows ArrowVec !
['] DoVScroll VScrollVec !
['] HandleRedraw RedrawVec !
['] HandleTopped ToppedVec !
ToFrontVec @ OldToFrontVec !
['] HandleToFront ToFrontVec ! ;


: (VIEW)
	OpenFile2
	FileID w@
	IF
	 ShowWindow
	 AllocMem
	 ReadIn
	 InitVars
	 InstallVecs
	 DoView
	 BEGIN 
	  pause
	 AGAIN	( this would be the main loop)
	ELSE
	 sleep status w!
	 pause
	THEN
	;


: WakeTask	( if VIEW hasn't been called yet, BUILD the task/window
		 else just wake it up.)
	VIEWADDR @ 0=	( -1 if already been used this time)
	 IF	( not built yet, so build it.)
	  VIEWW VIEWT BUILD	( if was built, let activate give it)
	 THEN			( something to do again-wakes it up,too)
	VIEWT ACTIVATE (VIEW)	( start VIEWing)
	;

: VIEW
	VIEWADDR @ 1 < IF	( ignore if VIEWADDR is positive)
	 WakeTask
	 then
	 ;

