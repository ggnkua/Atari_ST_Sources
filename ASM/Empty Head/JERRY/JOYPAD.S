Up 	equ 8
Down 	equ 9
Left 	equ 10
Right 	equ 11
Fire_0 	equ 1

JOYPAD:
	lea $ffff9202.w,a1	;joypad adress 1
	move.w #$fffe,(a1)
	move.w -2(a1),EXITFIRE ;if set, then out from main loop

	move.w #$fffe,(a1)
	move.w (a1)+,d0
	btst #Up,d0
	bne.s .NO_UP
	subq.w #1,D2Y
.NO_UP:
	btst #Down,d0
	bne.s .NO_DOWN
	addq.w #1,D2Y
.NO_DOWN:
	btst #Left,d0
	bne.s .NO_LEFT
	subq.w #1,D2X
.NO_LEFT:	
	btst #Right,d0
	bne.s .NO_RIGHT
	addq.w #1,D2X
.NO_RIGHT:
	rts

D2Y:	ds.w 1
D2X:	ds.w 1
EXITFIRE:	ds.w 1