( A-Line.asm)
( just examples of how you can use the assembler)
( Builds a bunch of words for using the A-Line graphics. Tested on med res)
( To use this set, you first set conditions, such as clipping, and
  then execute a function. You could, of course, rewrite the words.)
( Be careful of the A2. A lot of these could change it.)
( REMEMBER, the PutPixel,MoveTo ,etc. routines in Mach1 are window relative
  only. These ones are for full screen stuff)
( .TRAP requires that the number to w, begin w/ $ and be hex. The base
  however, is unaffected. The action of these words is merely W,.)


( See p. 213-233 of Abacus Internals or p. 54-58 July '86 ST Applications)

( words defined in this file:
Init		( - addr)
PutPix		( x,y,color - )
GetPix		( x,y - color)
Line		( x1,y1,x2,y2 - )
HLine		( x1,y1,x2 - )
FillRect	( x1,y1,x2,y2 - )
HideCursor	( - )
ShowCursor	( f - )
DrawSprite	( x,y,sprite,savebuffer-- )
UnDrawSprite	( x,y,savebuffer-- )
setWrMode	( wrMode -  )
ClipOff		( - )
setClip		( left top bottom right -- )
setPattern	( patPtr --  )
TransMouse	( newForm  --  )
fillPolygon	( polygon #vertices --  )
   )

decimal
ALSO ASSEMBLER ( for the DC.W's and the .TRAP's)
.TRAP	_Init		$A000
.TRAP	_PutPixel	$A001
.TRAP	_GetPixel	$A002
.TRAP	_Line		$A003
.TRAP	_HLine		$A004
.TRAP	_FillRect	$A005
.TRAP	_FillPoly	$A006
.TRAP	_BitBlt		$A007
.TRAP	_TextBlt	$A008
.TRAP	_ShowCursor	$A009
.TRAP	_HideCursor	$A00A
.TRAP	_XFormCursor	$A00B
.TRAP	_UnDrawSprite	$A00C
.TRAP	_DrawSprite	$A00D
.TRAP	_CopyRaster	$A00E

4  constant Control
8  constant IntIn
12 constant PtsIn
34 constant LnMask
36 constant wrtMode
38 constant X1
40 constant Y1
42 constant X2
44 constant Y2
46 constant patPtr
50 constant patMask
54 constant clipFlag
56 constant xMinClip
58 constant yMinClip
60 constant xMaxClip
62 constant yMaxClip

: % [COMPILE] \  ; IMMEDIATE 
% note that % or \ is much slower during compile than ( )


% ================= INIT ==================
% ( -- addr) just leaves the A0 on the stack. Never used

CODE INIT _Init
	MOVE.L A0,-(A6)
	RTS
END-CODE

% ========================== PUTPIXEL =================
% See Page 226 GEM Abacus
% ( X,Y,COLOR-- )
CODE PUTPIX	MOVE.L	A2,-(A7)	( save the A2)
		_Init
		MOVE.L	IntIn(A0),A1
		MOVE.L	PtsIn(A0),A2
		MOVE.L	(A6)+,D0
		MOVE.W	D0,(A1)
		MOVE.L	(A6)+,D0
		MOVE.L	(A6)+,D1
		MOVE.W	D1,(A2)+
		MOVE.W	D0,(A2)
		_PutPixel
		MOVE.L	(A7)+,A2
		RTS
END-CODE

% ========================== GETPIXEL=================
% ( X,Y--COLOR)
CODE GETPIX	MOVE.L	A2,-(A7)
		_Init
		MOVE.L	PtsIn(A0),A2
		MOVE.L	(A6)+,D0
		MOVE.L	(A6)+,D1
		MOVE.W	D1,(A2)+
		MOVE.W	D0,(A2)
		_GetPixel
		MOVE.W	D0,-(A6)
		CLR.W	-(A6)
		MOVE.L	(A7)+,A2
		RTS
END-CODE

% =================== LINE =====================
% ( x1,y1,x2,y2-- ) draws line using current attributes and patterns

CODE LINE	_Init
		MOVE.L	(A6)+,D3
		MOVE.L	(A6)+,D2
		MOVE.L	(A6)+,D1
		MOVE.L	(A6)+,D0
		LEA	X1(A0),A0
		MOVEM.W	D0-D3,(A0)
		_Line
		RTS
END-CODE

% =================== HLINE =====================
% ( x1,y1,x2-- ) draws horizontal line using current attributes and patterns

CODE HLINE	_Init
		MOVE.L	(A6)+,D2
		MOVE.L	(A6)+,D1
		MOVE.L	(A6)+,D0
		LEA	X1(A0),A0
		MOVEM.W	D0-D2,(A0)
		_HLine
		RTS
END-CODE

% =================== FILLRECT =====================
% ( x1,y1,x2,y2-- ) draws a rectangle using current attributes and patterns

CODE FILLRECT	_Init
		MOVE.L	(A6)+,D3
		MOVE.L	(A6)+,D2
		MOVE.L	(A6)+,D1
		MOVE.L	(A6)+,D0
		LEA	X1(A0),A0
		MOVEM.W	D0-D3,(A0)
		_FillRect
		RTS
END-CODE

% ================= HIDECURSOR ======================
% ( -- ) hide the cursor. a showC must be executed for every hideC to
% bring the cursor back

CODE HIDECURSOR	_HideCursor
		RTS
END-CODE

% ================= SHOWCURSOR ======================
% ( f-- ) if f is 0, show the cursor. else remove the effects of one HideCurs

CODE SHOWCURSOR	_Init
		MOVE.L	Control(A0),A1	( CONTROL ARRAY)
		MOVE.L	IntIn(A0),A0	( INTIN ARRAY)
		CLR.W	2(A1)		( clear Control(1) )
		MOVE.W	#1,6(A1)	( control(3) = 1 )
		MOVE.W	#-1,(A0)	( IntIn(0) <> 0 )
		_Init			( get the A0 register back)
		_ShowCursor
		RTS
END-CODE

( this is a sprite definition block. It's address is used for drawsprite)
CREATE  MySprite
	DC.W	0,0		( x,y offsets to hot spot)
	DC.W	0		( format flag. 0=VDI format, 1=XOR format)
	DC.W	0		( background color index)
	DC.W	1		( foreground color index)
	DC.W	0		( background pattern of top line in sprite)
	DC.W	0		( foreground pat of top lime in sprite)
	DC.W	0		( background pattern of 2nd line sprite)
	DC.W	0		( foreground of 2nd. See the pattern?)
	DC.W	0,%1111100000011111
	DC.W	0,%1111100000011111
	DC.W	0,%0111110000111110
	DC.W	0,%0111110000111110
	DC.W	0,%0111111001111110
	DC.W	0,%0111111001111110
	DC.W	0,%0111111111111110
	DC.W	0,%0111111111111110
	DC.W	0,%0111101111011110
	DC.W	0,%0111101111011110
	DC.W	0,%0111100110011110
	DC.W	0,%0111100110011110
	DC.W	0,%0111100000011110
	DC.W	0,%0111100000011110
	DC.W	0,%1111100000011111
	DC.W	0,%1111100000011111

variable savebuffer 140 vallot

% =============== DRAWSPRITE ====================
% ( x,y,sprite,savebuffer-- )
% draws the sprite at x,y and saves the background in savebuffer. It
% must be 64 bytes*no.of planes  + 10 bytes large. (138 for medium res)

CODE DrawSprite
	MOVE.L	A2,-(A7)	( save A2)
	MOVE.L	(A6)+,A2	( A2: savebuffer)
	MOVE.L	(A6)+,A0	( A0: spriteaddr)
	MOVE.L	(A6)+,D1	( D1: y)
	MOVE.L	(A6)+,D0	( D0: x)

	MOVE.L	A6,-(A7)	( also clobbers A6!!)
	_DrawSprite
	MOVE.L	(A7)+,A6	( restore the A2, A6)
	MOVE.L	(A7)+,A2
	RTS
END-CODE


% ================= UNDRAWSPRITE =================
% ( x,y,savebuffer-- ) restores whatever what saved in savebuffer.
% The coords were placed in the buffer when the sprite was drawn
% must save the A6!! and also the A2 if locals are being used

CODE unDrawSprite
	MOVE.L	A2,-(A7)
	MOVE.L	(A6)+,A2
	MOVE.L	(A6)+,D1
	MOVE.L	(A6)+,D0
	MOVE.L	A6,-(A7)
	_UnDrawSprite
	MOVE.L	(A7)+,A6
	MOVE.L	(A7)+,A2
	RTS
END-CODE

( sample:
80 80 MySprite savebuffer DrawSprite
savebuffer Undrawsprite)

\ ================= setWrMode ======================
\ ( wrMode -  )  0: replace
\		 1: transparent
\		 2: XOR
\		 3: Inverse transparent

CODE setWrMode
	_Init
	MOVE.L	(A6)+,D0
	MOVE.W	D0,wrtMode(A0)
	RTS
END-CODE

\ =============== ClipOff ===================
( - )

CODE ClipOff
	_Init
	CLR.W	ClipFlag(A0)
	RTS
END-CODE

\ ================ setClip ==================
( left top bottom right -- )

CODE setClip
	MOVEM.L	(A6)+,D0-D3
	_Init
	LEA	Y2(A0),A1
	MOVEM.L	D0-D3,-(A1)
	RTS
END-CODE

\ =============== setPattern ===============
( patPtr --  )

CODE setPattern
	_Init
	MOVE.L	(A6)+,patPtr(A0)
	RTS
END-CODE

CREATE aPattern
	DC.W	%1100110011001100
	DC.W	%0110110110110110
	DC.W	%0011001100110011
	DC.W	%1001100110011001

CREATE Triangle	( polygons are lists of x,y pairs. The first vertex
		  is always repeated as the last entry)
	DC.W	320,100
	DC.W	120,50
	DC.W	90,180
	DC.W	320,100

create NewCursor	( from p.7-19 GEM VDI guide)
	DC.W	6	( x-coord of hot spot rel to top left)
	DC.W	4	( y-coord of hot spot rel to top left)
	DC.W	1	( reserved, always 1)
	DC.W	0	( color to set bits corr.ing to 1's in mask)
	DC.W	1	( color to set bits corr.ing to the 1's in data)

	DC.W	%0000100010000000	( 1st line of 16 lines of mask)
	DC.W	%0000100010000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000010100000000
	DC.W	%0000100010000000
	DC.W	%0000100010000000
	DC.W	%0000000000000000

	DC.W	%0000011100000000	( 1st line of 16 lines of data)
	DC.W	%0000011100000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000001000000000
	DC.W	%0000011100000000
	DC.W	%0000011100000000
	DC.W	%0000000000000000

\ ========= Transform Mouse ===============
\ ex: NewCursor TransMouse
( newForm  --  )

CODE TransMouse
	_Init
	MOVE.L	IntIn(A0),-(A7)		( save)
	MOVE.L	(A6)+,IntIn(A0)
	_XFormCursor
	MOVE.L	(A7)+,IntIn(A0)		( restore)
	RTS
END-CODE

\ ========= fillPolygon ===============
\ ex.  Triangle 3 fillPolygon
\ ( polygon #vertices --  )
\ This is wierd. The basic routine lets you draw one line at a time
\ given a polygon. You must loop to actually fill the polygon.

CODE fillPolygon
	_Init
	MOVE.L	control(A0),A1
	MOVE.L	(A6)+,D0
	MOVE.W	D0,2(A1)	( move #vertices into contrl[1] )
	MOVE.L	PtsIn(A0),-(A7)	( save)
	MOVE.L	(A6)+,PtsIn(A0)	( move address of polygon in place)

	MOVE.W	#199,D3		( draw the lines from y=200 to y=0 on
				  low/med res. It would be more
				  efficient to figure the extent of the
				  polygon and only draw those lines.)
@Loop	MOVE.W	D3,Y1(A0)
	MOVE.L	A0,-(A7)	( save the A0)
	_FillPoly
	MOVE.L	(A7)+,A0	( restore the A0)
	DBF	D3,@Loop
	MOVE.L	(A7)+,PtsIn(A0)	( restore the array)
	RTS
END-CODE

(

Examples:

aPattern setPattern
Triangle 3 fillPolygon
80 80 mySprite savebuffer DrawSprite
80 80 savebuffer UnDrawSprite
NewCursor TransMouse

)