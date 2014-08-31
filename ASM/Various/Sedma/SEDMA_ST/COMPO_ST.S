;*************************************************************************
;* Coded by Sedma on Noise Party 2006 for Realtime Compo
;*************************************************************************

KEYBD    	EQU 	$FFFFFC02	; ACIA ( klavesnicovy ) data register

start:          clr.l   -(A7)
                move.w  #32,-(A7)
                trap    #1
program:		
	        clr.b  $FFFF8260.w
		clr.l $FFFF8240.w 
		not.w $FFFF8242.w

                MOVE.L  $044E.w,A0
		lea.l Table(PC),A6
		moveq.w #5,D6		; 6 stvorcov
		;clr.b D2 ;D2 by mala byt prazdna
NextBar:
		move.b D2,D3
		move.b (A6)+,D2
		clr.w D4
		move.b (A6)+,D4
NextScan:
		move.w #159,D1
		move.w #$C000,D7
DrawPlane:
		cmp.b D2,D1
		bhs.b DontSetPixel
		cmp.b D3,D1
		blo.b DontSetPixel 
		or.w D7,(A0)
DontSetPixel:
		ror.w #2,D7
		bcc.b NoNextPlane
		addq.w #8,A0 
NoNextPlane:
		dbra D1,DrawPlane
		dbra D4,NextScan
		dbra D6,NextBar
TestKey:
		bra.b TestKey
		;cmp.b #$39,KEYBD		; zistuje ci si nestlacil space
		;bne.b TestKey

	        ;MOVE.B  #1,$FFFF8260
		;move.w #$FFFF,$FFFF8240 
		;nop
		;nop
		;clr.w -(A7)
		;trap #1
		DATA
Table:		dc.b 80,99, 120,49, 140,24, 150,11, 155,4, 160,4
