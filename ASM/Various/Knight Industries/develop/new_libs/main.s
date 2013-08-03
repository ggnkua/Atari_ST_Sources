	SECTION	text

events
	move.l	#messageBuffer,addrin
	move.w	#63,intin
	move.w	#$103,intin+2
	move.w	#$3,intin+4
	move.w	#$103,intin+6
	move.w	#1,intin+8
	clr.l	intin+10
	clr.l	intin+14
	move.w	#1,intin+18
	clr.l	intin+20
	clr.l	intin+24
	move.w	#25,intin+28
	move.w	#0,intin+30
	evnt_multi

	move.w	intout,eventType
	move.w	intout+2,mouseX
	move.w	intout+4,mouseY
	move.w	intout+6,mouseClick
	move.w	intout+8,controlKeys
	move.w	intout+10,keyPressed

; check for message
	move.w	eventType,d0
	andi.w	#mu_mesag,d0
	bne	generalMessageHandler

; check for keyboard
	move.w	eventType,d0
	andi.w	#mu_keybd,d0
	bne	generalKeyboardHandler

; check for mouse click
	move.w	eventType,d0
	andi.w	#mu_button,d0
	bne	generalClickHandler

	rts

	SECTION	bss
eventType	ds.b	2
mouseX	ds.b	2
mouseY	ds.b	2
mouseClick	ds.b	2
controlKeys	ds.b	2
keyPressed	ds.b	2

messageBuffer	ds.b	32