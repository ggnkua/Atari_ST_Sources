;**********************************************************************
;*  Coded by Sedma on Noise party 2006 Realtime Compo
;**********************************************************************

KEYBD    	EQU 	$FFFFFC02	; ACIA ( klavesnicovy ) data register

begin:		clr.l	-(sp)				; super()
		move.w	#$20,-(sp)			;
		trap	#1				;
		
		movea.l	$44e.w,A6	;-(sp)
		
		move.l	#$00580134,-(sp)			; vsetmode() (320x200/hc VGA)
		trap	#14
		
		lea.l Table(PC),A0
		moveq.w #5,D6		; 6 stvorcov
		;clr.b D2 ;D2 by mal byt cisty
NextBar:
		move.b D2,D3
		move.b (A0)+,D2
		clr.w D4
		move.b (A0)+,D4
NextScan:
		move.w #159,D1
DrawPlane:
		clr.l (A6)+
		cmp.b D2,D1
		bhs.b DontSetPixel
		cmp.b D3,D1
		blo.b DontSetPixel 
		not.l -4(A6)
DontSetPixel:
		dbra D1,DrawPlane
		dbra D4,NextScan
		dbra D6,NextBar
TestKey:
		bra.b TestKey
		DATA
Table:		dc.b 80,99, 120,49, 140,24, 150,11, 155,4, 160,4
