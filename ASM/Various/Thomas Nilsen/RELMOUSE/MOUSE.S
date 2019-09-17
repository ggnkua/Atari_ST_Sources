;-------------------------------------------------------------------------;
; Relative Mouse Handling routine
; Even works without GEM!!
; Written By Thomas Nilsen (STand Software)
; 06.10.1993
;
; This routine uses only the basic relative mode, so scaling/treshold
; is used as set by system.
;-------------------------------------------------------------------------;
; The routine gives the mouse stauts in the address of 'Packet'.
; The information is : First Byte - $F8 -> No Buttons Pressed
;				    $F9 -> Right Button Pressed
;				    $FA -> Left Button Pressed		
;				    $FB -> Both Buttons Pressed
;
;		       Second Byte: Relative Horisontal Movement
;				    (Examp. $FF (-1) = Mouse moved one pixel Left)
;
;		       Third Byte:  Relative Vertical Movement
;				    (Examp. $02 = Two Pixels Downwards)
; Both x and y are signed values!
;-------------------------------------------------------------------------;
		SECTION TEXT
		OPT O+,OW-,D+,A+

Start:		move.w	#34,-(sp)	; Get IKBD vectors
		trap	#14
		lea	2(sp),sp
		lea	MyHandler,a1
		move.l	d0,a0
		move.l	d0,SaveOldBase
		move.l	16(a0),SaveOldVec ; Get mouse vector
		move.l	a1,16(a0)	; Install new Mouse Vector
		pea	IkbdString	; Relative mode
		move.w	#0,-(sp)	
		; Length of IKBD String -1
		move.w	#25,-(sp)	; Write to IKBD
		trap	#14
		lea	8(sp),sp

		moveq.l	#0,d6
		move.l	#0,XPos
		move.l	#0,YPos
;-------------------------------------------------------------------------;
; Main Loop!
Loop:		moveq.l	#0,d7
		lea	Packet,a4	; Mouse-data recieved in Packet
		move.b	1(a4),d7	; Horisontal Movement
		move.b	#0,1(a4)	; Then Clear The X Packet Byte

; Start Calculationg the new mouse-positions.

		tst.b	d7
		bmi	SubXMouse
		add.w	d7,XPos		; New X Pos
		bra	_SkipX

SubXMouse:	moveq.l	#0,d6
		move.w	#$100,d6
		sub.w	d7,d6
		sub.w	d6,XPos
		
; Now Calc The Y Movements

_SkipX:		moveq.l	#0,d6
		move.b	2(a4),d6	; Vertical Movement Byte
		move.b	#0,2(a4)	; Clear The Y PAcket Byte
		tst.b	d6		; N Bit Set?
		bmi	SubYMouse	; Yes, Subtract
		add.w	d6,YPos
		bra	_SkipY

SubYMouse:	moveq.l	#0,d5
		move.w	#$100,d5
		sub.w	d6,d5
		sub.w	d5,YPos
		
_SkipY:		bsr	CheckPos	; Check pos not to exceed max/min

Next1:		cmp.b	#$f9,(a4)	; Right button pressed
		bne.b	Next2
		;bsr

Next2:		cmpi.b	#$fa,(a4)	; Left button pressed
		bne	Next3
		;bsr	
		
Next3:		cmpi.b	#$fb,(a4)	; Both buttons pressed
		beq	Exit

; The following is just a small extra to get the X or Y coords displayed on-screen.
; This includes convertion from Hex to bin
		moveq.l	#0,d0
		moveq.l	#0,d1
		move.w	XPos,d1		; Display XPos
		moveq.l	#0,d3
		bsr	ConvHex		; Input in d0
		bra	Loop

;-------------------------------------------------------------------------;
Exit:		move.l	SaveOldBase,a0	; Restore old vector data
		move.l	SaveOldVec,d0	;    -""-
		move.l	d0,16(a0)	; And Restore Mouse Vector
		clr.w	-(sp)		; Pterm (0)
		trap	#1

;-------------------------------------------------------------------------;
; This is the new mousehandler we install.
; Is gets the mouse parameter in a0 and copies them to the Packet-buffer
MyHandler:	move.w	#2,d0		; 3 bytes to get
		lea	Packet,a1
.Loop:		move.b	(a0)+,(a1)+	; Store mouse data in Packet
		dbf	d0,.Loop
		rts
;-------------------------------------------------------------------------;
; Simple routine for converting hex to bin
;
ConvHex:	move.l	#Buffer+6,a6
		bsr	Convert
		move.w	#10,d4
		move.l	#Buffer,a2
		bsr	CheckSpaces
		
		move.l	#Text,-(sp)	; Init text (and pos)
		move.w	#9,-(sp)
		trap	#1
		lea	6(sp),sp
				
		move.l	#Buffer,-(sp)	; Write the formated text
		move.w	#9,-(sp)
		trap	#1
		lea	6(sp),sp
		bsr	ClearBuffer
		rts

Convert:	move.l	#10,d2
AnotherNum:	move.w	d1,d3
		clr.w	d1
		swap	d1
		divu	d2,d1
		bvc	Skip
		rts

Skip:		move.w	d1,d4
		move.w	d3,d1
		divu	d2,d1
		swap	d1
		addi.b	#$30,d1
		cmpi.w	#'0',d1
		blt	Here
		cmpi.w	#'9',d1
		bgt	Here
		move.b	d1,-(a6)
Here:		move.w	d4,d1
		swap	d1
		tst.l	d1
		bne	AnotherNum
		rts

;-------------------------------------------------------------------------;
; For use with convertion routine
;
CheckSpaces:	clr.l	d3
CheckAgain:	move.b	(a2)+,d3
		subi.w	#1,d4
		cmpi.w	#0,d4
		beq	CheckFin
		cmpi.b	#48,d3
		blt	PutSpace
		bra	CheckAgain
		
PutSpace:	suba	#1,a2
		move.b	#' ',(a2)+
		bra	CheckAgain
CheckFin:	rts
;-------------------------------------------------------------------------;
; Clears the buffer used by hex-to-bin as text-display
ClearBuffer:	lea	Buffer(pc),a2
		moveq.l	#4,d5
.Loop:		move.b	#' ',(a2)+
		dbf	d5,.Loop
		rts
;-------------------------------------------------------------------------;
; Just to keep the mouse within a given distance. 
; (Set forMedium resolution here)
CheckPos:	cmpi.w	#0,YPos
		bge.b	.N1
		move.w	#0,YPos
.N1:		cmpi.w	#199,YPos
		ble.b	.N2
		move.w	#199,YPos
.N2:		cmpi.w	#0,XPos
		bge.b	.N3
		move.w	#0,XPos
.N3:		cmpi.w	#640,XPos
		ble.b	.N4
		move.w	#640,XPos
.N4:		rts
;-------------------------------------------------------------------------;
		SECTION DATA

IkbdString:	dc.b	$8
Text:		dc.b	27,"Y",33,33,0
		EVEN

;-------------------------------------------------------------------------;
		SECTION BSS

Packet:		ds.b	3
SaveOldVec:	ds.l	1
SaveOldBase:	ds.l	1			
Buffer:		ds.l	4
XPos:		ds.w	1	; Storage for X-possition
YPos:		ds.w	1	; Storage for Y-possition 

		EVEN
		END