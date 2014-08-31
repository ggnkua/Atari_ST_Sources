	
	section 	text

;==============================================================================;
;                                                                              ;
;   Original x86 Assembler Program By Vulture.
;   68k conversion & modifications by Matt'Us Alem.                                              ;
;   
;   3D-system example. Use the following formulas to rotate a point:           ;
;                                                                              ;
;        Rotate around x-axis                                                  ;
;        YT = Y * COS(xang) - Z * SIN(xang) / 256                              ;
;        ZT = Y * SIN(xang) + Z * COS(xang) / 256                              ;
;        Y = YT                                                                ;
;        Z = ZT                                                                ;
;                                                                              ;
;        Rotate around y-axis                                                  ;
;        XT = X * COS(yang) - Z * SIN(yang) / 256                              ;
;        ZT = X * SIN(yang) + Z * COS(yang) / 256                              ;
;        X = XT                                                                ;
;        Z = ZT                                                                ;
;                                                                              ;
;        Rotate around z-axis                                                  ;
;        XT = X * COS(zang) - Y * SIN(zang) / 256                              ;
;        YT = X * SIN(zang) + Y * COS(zang) / 256                              ;
;        X = XT                                                                ;
;        Y = YT                                                                ;
;                                                                              ;
;   Divide by 256 coz we have multiplyd our sin values with 256 too.           ;
;   This example isn't too fast right now but it'll work just fine.            ;
;                                                                              ;
;       Current Date: 6-9-95         Vulture
;       Conversion Date : 20-11-01   Matt'US Alem
;                                                                              ;
;==============================================================================;

init_3Drot:		; Called only one time before main loop 
		; initialize axxis speed rotations

   		move.w  #1,DeltaX          	; Initial speed of rotation
   		move.w  #1,DeltaY          	; Change this and watch what
    		move.w  #1,DeltaZ          	; happens. It's fun!

		; perspective distances

    		move.w   #256,Xoff
    		move.w   #256,Yoff         	; Used for calculating vga-pos
   		move.w   #300,Zoff         	; Distance from viewer

		; initialize to zeros EraseTable (needed ?)
		
    		;clr.w	d7		; initialize Erase table
    		;move.w	MaxPoints,d6
		;lea	EraseTable,a0
;.Fill:		
		;move.l	#0,(a0,d7.w*4)
		;add.w	#1,d7
		
		;dbra	d6,.Fill

		; Create a precalc 320x table (from 0 to 240) 

		clr.w	d7
		move.w	#240,d6
		lea 	Mul320Table,a0

.FillTable:		move.w	d7,d5
		mulu	#320,d5
		move.l	d5,(a0,d7.w*4)
		addq.w	#1,d7

		dbra	d6,.FillTable	

		; Create a precalc 6x table (from 0 to MaxPoints+1)

		clr.w	d7
		move.w	MaxPoints,d6	; 124
		addq.w	#1,d6		; 125 :)
		lea 	Mul6Table,a0

.FillTable2:	move.w	d7,d5
		mulu	#6,d5
		move.w	d5,(a0,d7.w*2)
		addq.w	#1,d7

		dbra	d6,.FillTable2	

		; Calculate first rotation angles

		bsr 	sb3D_UpdateAngles 	; Calculate new angles
    		bsr     	sb3D_SetRotation  	; Find Sine & CoSine of those angles

		rts

; Calculates new x,y,z angles
; to rotate around
sb3D_UpdateAngles:	move.w     XAngle,d0       	; Load current angle
		add.w      DeltaX,d0        	; Add velocity
		andi.w     #%11111111,d0    	; Range from 0..255
		move.w     d0,XAngle        	; Update X
		    
		move.w     YAngle,d0
		add.w      DeltaY,d0        	; Add velocity
		andi.w     #%11111111,d0    	; Range from 0..255
		move.w     d0,YAngle        	; Update Y
		
		move.w     ZAngle,d0
		add.w      DeltaZ,d0        	; Add velocity
		andi.w     #%11111111,d0    	; Range from 0..255
		move.w     d0,ZAngle        	; Update Z
	
		rts

; Needed : d0.w = angle (0..255)
; Returns: d1.w = Sin   d2.w = Cos
; used : d1,d2,a0
;
sb3D_GetSinCos:	lea	SinCos,a0		; load SinCos table
		move.w	d0,d2		; Save angle (use as pointer)
		move.w  	(a0,d2*2),d1	; get Sine
		add.w	#64,d2		; add 64 (-> pi/4)
		and.w	#%11111111,d2	; Range from 0..255
		move.w	(a0,d2*2),d2	; get Cosine
		
		rts

; Set sine & cosine of x,y,z
; used d0,d1,d2
sb3D_SetRotation:	move.w	XAngle,d0		; Grab angle
		bsr	sb3D_GetSinCos	; Get the sine&cosine : d1 & d2
		move.w	d1,XSin		; Save sin
		move.w	d2,XCos		; Save cos
		
		move.w	YAngle,d0		; Grab angle
		bsr	sb3D_GetSinCos	; Get the sine&cosine : d1 & d2
		move.w	d1,YSin		; Save sin
		move.w	d2,YCos		; Save Cos
		
		move.w	ZAngle,d0		; Grab angle
		bsr	sb3D_GetSinCos	; Get the Sine&CoSine : d1 & d2
		move.w	d1,ZSin		; Save Sin
		move.w	d2,ZCos		; Save Cos
		
		rts

; Rotates the point around x,y,z
; Gets original x,y,z values
; This can be done elsewhere
; in : d7.w : offset
;      a5 : 6x precalc table (3 coords * word size)
; used a0 - d0,d1,d2
sb3D_RotatePoint:	lea	Figure,a0
		move.w	(a5,d7.w*2),d1	; use precalc 6x table to replace mulu #3*2,d1 
		;move.w	d7,d1
		;mulu 	#3,d1

		move.w	(a0,d1.w),d0	; get X and move 1 byte 
		adda.l	#2,a0
		move.w	d0,X		; save in current X
		
		move.w	(a0,d1.w),d0	; get Y and move 1 byte 
		move.w	d0,Y		; save in current Y
		adda.l	#2,a0		

		move.w	(a0,d1.w),d0	; get Z
		move.w	d0,Z		; save in current Z
		
; Rotate around x-axis
; YT = Y * Cos(xang) - Z * Sin(xang) / 256
; ZT = Y * Sin(xang) + Z * Cos(xang) / 256
; Y = YT
; Z = ZT

		move.w	Y,d0
		move.w	XCos,d1
		muls.w	d1,d0		; d0 = Y * Cos(xang)

		move.w	Z,d1
		move.w	XSin,d2
		muls.w	d2,d1		; d1 = Z * Sin(xang)
		sub.l	d1,d0		; d0 = Y * Cos(xang) - Z * Sin(xang)
		asr.l	#8,d0		; d0 = Y * Cos(xang) - Z * Sin(xang) / 256
		
		move.w	d0,Yt		
		
		move.w	Y,d0
		move.w	XSin,d1
		muls.w	d1,d0		; d0 = Y * Sin(xang)
		move.w	Z,d1

		move.w	XCos,d2
		muls.w	d2,d1		; d1 = Z * Cos(xang)
		add.l	d0,d1		; d1 = Y * Sin(xang) + Z * Cos(xang)
		asr.l	#8,d1		; d1 = Y * Sin(xang) + Z * Cos(xang) / 256
		move.w	d1,Zt
		
		move.w	Yt,d0		; Switch values Y=Yt,...
		move.w	d0,Y
		move.w	Zt,d0
		move.w	d0,Z

; Rotate around y-axis
; XT = X * Cos(yang) - Z * Sin(yang) / 256
; ZT = X * Sin(yang) + Z * Cos(yang) / 256
; X = XT
; Z = ZT

		move.w	X,d0
		move.w	YCos,d1
		muls.w	d1,d0		; d0 = X * Cos(xang)
		
		move.w	Z,d1
		move.w	YSin,d2
		muls.w	d2,d1		; d1 = Z * Sin(xang)
		sub.l	d1,d0		; d0 = X * Cos(xang) - Z * Sin(xang)
		asr.l	#8,d0		; d0 = X * Cos(xang) - Z * Sin(xang) / 256
		
		move.w	d0,Xt		
		move.w	X,d0

		move.w	YSin,d1
		muls.w	d1,d0		; d0 = X * Sin(xang)
		move.w	Z,d1
		move.w	YCos,d2
		muls.w	d2,d1		; d1 = Z * Cos(xang)
		add.l	d0,d1		; d1 = X * Sin(xang) + Z * Cos(xang)
		asr.l	#8,d1		; d1 = X * Sin(xang) + Z * Cos(xang) / 256
		move.w	d1,Zt
		
		move.w	Xt,d0		; Switch values X=Xt,...
		move.w	d0,X
		move.w	Zt,d0
		move.w	d0,Z

; Rotate around z-axis
; XT = X * Cos(zang) - Y * Sin(zang) / 256
; YT = X * Sin(zang) + Y * Cos(zang) / 256
; X = XT
; Y = YT
	
		move.w	X,d0
		move.w	ZCos,d1
		muls.w	d1,d0		; d0 = X * Cos(xang)
		
		move.w	Y,d1
		move.w	ZSin,d2
		muls.w	d2,d1		; d1 = Y * Sin(xang)
		sub.l	d1,d0		; d0 = X * Cos(xang) - Y * Sin(xang)
		asr.l	#8,d0		; d0 = X * Cos(xang) - Y * Sin(xang) / 256
		
		move.w	d0,Xt		
		
		move.w	X,d0
		move.w	ZSin,d1
		muls.w	d1,d0		; d0 = X * Sin(xang)
		move.w	Y,d1
		move.w	ZCos,d2
		muls.w	d2,d1		; d1 = Y * Cos(xang)
		add.l	d0,d1		; d1 = X * Sin(xang) + Y * Cos(xang)
		asr.l	#8,d1		; d1 = X * Sin(xang) + Y * Cos(xang) / 256
		move.w	d1,Yt
		
		move.w	Xt,d0		; Switch values X=Xt,...
		move.w	d0,X
		move.w	Yt,d0
		move.w	d0,Y	
	
		rts

; Calculates screenposition and
; plots the point on the screen
; d0,d1,d2		
sb3D_ShowPoint:	move.w	Xoff,d0		; Xoff*X / Z+Zoff = screen x
		move.w	X,d1
		muls.w	d0,d1
		move.w	Z,d0
		add.w	Zoff,d0		; distance
		ext.l	d0
		divs.l	d0,d1		
		move.l	Mx,d0		
		ext.l	d1
		add.l	d0,d1		; Center on screen
		
		move.w	Yoff,d0		; Yoff*Y / Z+Zoff = screen y
		move.w	Y,d2
		muls.w	d0,d2
		move.w	Z,d0
		add.w	Zoff,d0
		ext.l	d0
		divs.l	d0,d2	
		move.l	My,d0
		ext.l	d2
		add.l	d0,d2		; Center on screen
		
		move.l	(a4,d2.w*4),d3	; use precalc 320x table to replace mulu #320,d2 
		add.l	d1,d3		; d2 = (y*320)+x
		
		; manage the color / Z
		
		move.w	Z,d0		; get Z
		add.w	#70,d0		; add 70 to be >0
		clr.w	d1		; get only lower byte  	 	
		move.b	d0,d1
		lsr.w	#4,d1		; divide by 16 to be between 0 and 16
		
		move.w	(a2,d1.w*2),(a1,d3.l*2)	; get & plot this color at this index	
		
		move.l	(a3,d7.w*4),(a6,d7.w*4)	; save older position
		move.l	d3,(a3,d7.w*4)	; Save position to erase
		
		rts
;
; set background
;
sb3D_back:		moveq.w	#0,d0	; trace line(0,50;320,50) color White
		move.w	#50,d1
		move.w	#319,d2
		move.w	#50,d3
		move.w	#%0111101111101111,d4	
		bsr 	tc_line
		moveq.w	#0,d0	; trace line(0,190;320,190) color White
		move.w	#190,d1
		move.w	#319,d2
		move.w	#190,d3
		move.w	#%0111101111101111,d4	
		bsr 	tc_line

		move.l	screen_adr,a0	; screen pointer

		lea	sb3D_text1,a1
		bsr	display_text

		move.l	screen_adr,a0	; screen pointer

		lea	sb3D_text2,a1
		bsr	display_text

		rts

		
sb3D_Main:		move.l	screen_adr,a1

		lea	EraseTable,a3
		lea	EraseTable2,a6
		
		; clearing previous plots (t-2)

	    	clr.w	d7		; Starting with point 0
    		move.w	MaxPoints,d6

.Deletion1:		move.l	(a6,d7.w*4),d0	; old point pos
		move.w	#0,(a1,d0.l*2)	; erase it (black)
		addq.w	#1,d7
		
		dbra	d6,.Deletion1		

		; clearing previous plots

	    	clr.w	d7		; Starting with point 0
    		move.w	MaxPoints,d6
		

.Deletion2:		move.l	(a3,d7.w*4),d0	; old point pos
		move.w	#0,(a1,d0.l*2)	; erase it (black)
		addq.w	#1,d7
		
		dbra	d6,.Deletion2

		; Calculate new coords + plot dots		

		lea	ColorTable,a2	; 16 grey color table
		lea	Mul320Table,a4	; 320x precalc table
		lea	Mul6Table,a5	; 6x precalc table
		
		clr.w	d7		; Starting with point 0
		move.w	MaxPoints,d6
		
.Loop:		bsr	sb3D_RotatePoint  	; Rotates the point uSing above formulas
    		bsr    	sb3D_ShowPoint    	; Shows the point
    		addq.w   	#1,d7          	; Next 3d-point
    		
    		dbra	d6,.Loop	

		; Calculate next rotation angles

		bsr 	sb3D_UpdateAngles 	; Calculate new angles
    		bsr     	sb3D_SetRotation  	; Find Sine & CoSine of those angles

   
		rts
;
; DATA
;
;

		section	data

		
Figure:            ; The 3d points : 5x*5y*5z (=125) points : Cube       
	    	dc.w -35,-35,-35
		dc.w -15,-35,-35
		dc.w 5,-35,-35
		dc.w 25,-35,-35
		dc.w 45,-35,-35

		dc.w -35,-15,-35
		dc.w -15,-15,-35
		dc.w 5,-15,-35
		dc.w 25,-15,-35
		dc.w 45,-15,-35

		dc.w -35,5,-35
		dc.w -15,5,-35
		dc.w 5,5,-35
		dc.w 25,5,-35
		dc.w 45,5,-35

		dc.w -35,25,-35
		dc.w -15,25,-35
		dc.w 5,25,-35
		dc.w 25,25,-35
		dc.w 45,25,-35

		dc.w -35,45,-35
		dc.w -15,45,-35
		dc.w 5,45,-35
		dc.w 25,45,-35
		dc.w 45,45,-35

		dc.w -35,-35,-15
		dc.w -15,-35,-15
		dc.w 5,-35,-15
		dc.w 25,-35,-15
		dc.w 45,-35,-15

		dc.w -35,-15,-15
		dc.w -15,-15,-15
		dc.w 5,-15,-15
		dc.w 25,-15,-15
		dc.w 45,-15,-15

		dc.w -35,5,-15
		dc.w -15,5,-15
		dc.w 5,5,-15
		dc.w 25,5,-15
		dc.w 45,5,-15

		dc.w -35,25,-15
		dc.w -15,25,-15
		dc.w 5,25,-15
		dc.w 25,25,-15
		dc.w 45,25,-15

		dc.w -35,45,-15
		dc.w -15,45,-15
		dc.w 5,45,-15
		dc.w 25,45,-15
		dc.w 45,45,-15

		dc.w -35,-35,5
		dc.w -15,-35,5
		dc.w 5,-35,5
		dc.w 25,-35,5
		dc.w 45,-35,5

		dc.w -35,-15,5
		dc.w -15,-15,5
		dc.w 5,-15,5
		dc.w 25,-15,5
		dc.w 45,-15,5

		dc.w -35,5,5
		dc.w -15,5,5
		dc.w 5,5,5
		dc.w 25,5,5
		dc.w 45,5,5

		dc.w -35,25,5
		dc.w -15,25,5
		dc.w 5,25,5
		dc.w 25,25,5
		dc.w 45,25,5

		dc.w -35,45,5
		dc.w -15,45,5
		dc.w 5,45,5
		dc.w 25,45,5
		dc.w 45,45,5  

		dc.w -35,-35,25
		dc.w -15,-35,25
		dc.w 5,-35,25
		dc.w 25,-35,25
		dc.w 45,-35,25

		dc.w -35,-15,25
		dc.w -15,-15,25
		dc.w 5,-15,25
		dc.w 25,-15,25
		dc.w 45,-15,25

		dc.w -35,5,25
		dc.w -15,5,25
		dc.w 5,5,25
		dc.w 25,5,25
		dc.w 45,5,25

		dc.w -35,25,25
		dc.w -15,25,25
		dc.w 5,25,25
		dc.w 25,25,25
		dc.w 45,25,25

		dc.w -35,45,25
		dc.w -15,45,25
		dc.w 5,45,25
		dc.w 25,45,25
		dc.w 45,45,25

		dc.w -35,-35,45
		dc.w -15,-35,45
		dc.w 5,-35,45
		dc.w 25,-35,45
		dc.w 45,-35,45

		dc.w -35,-15,45
		dc.w -15,-15,45
		dc.w 5,-15,45
		dc.w 25,-15,45
		dc.w 45,-15,45

		dc.w -35,5,45
		dc.w -15,5,45
		dc.w 5,5,45
		dc.w 25,5,45
		dc.w 45,5,45

		dc.w -35,25,45
		dc.w -15,25,45
		dc.w 5,25,45
		dc.w 25,25,45
		dc.w 45,25,45

		dc.w -35,45,45
		dc.w -15,45,45
		dc.w 5,45,45
		dc.w 25,45,45
		dc.w 45,45,45    
		EVEN
;c equ -35            
;    rept 5
;        b equ -35
;        rept 5
;           a equ -35
;           rept 5
;             dc.w a,b,c
;             a = a + 20
;           endr
;           b = b + 20
;        endr
;       c = c + 20
;    endr

       
XAngle 		dc.w 0      	; Angle to rotate around x
YAngle 		dc.w 0
ZAngle 		dc.w 0
       		
Mx     		dc.l 160            	; Middle of the screen
My     		dc.l 120
		       
MaxPoints		dc.w 124        	; Number of 3d Points

sb3D_text1:		dc.w 0,9,9
		dc.b "OLDSCHOOL",92,0
		EVEN
sb3D_text2:		dc.w 0,199,9
		dc.b "KEEP",94,"COOL",91,0
		EVEN

ColorTable:		dc.w	%1111111111111111
		dc.w	%1111111111111111,%1111111111111111
		dc.w	%0111101111101111,%0111101111101111
		dc.w	%0011100111100111,%0011100111100111
		dc.w	%0001100011100011,%0001100011100011		
		dc.w	%0000100001100001,%0000100001100001
		dc.w	%0000100001100001,%0000000000100000
		dc.w	%0000000000000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000
       
       		section 	bss
       
X      		ds.w 1             	; X variable for formula
Y      		ds.w 1
Z      		ds.w 1
Xt    	 	ds.w 1             	; Temporary variable for x
Yt     		ds.w 1
Zt     		ds.w 1
   
DeltaX 		ds.w 1             	; Amound Xangle is increased each time
DeltaY 		ds.w 1
DeltaZ 		ds.w 1
       
Xoff   		ds.w 1
Yoff   		ds.w 1
Zoff   		ds.w 1             	; Distance from viewer
       
XSin   		ds.w 1             	; Sine and CoSine of angle to rotate around
XCos   		ds.w 1
YSin   		ds.w 1
YCos   		ds.w 1
ZSin   		ds.w 1
ZCos   		ds.w 1
       
EraseTable:		ds.l 125*3     	; Array for deletion screenpoints
EraseTable2:	ds.l 125*3
Mul320Table:	ds.l 241		; Precalc 320x table	
Mul6Table:		ds.w 126		; Precalc 6x table			
		
	section 	text