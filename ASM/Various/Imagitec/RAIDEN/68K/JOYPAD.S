Readpad
;scan for player 1
	move.l	#$f0fffffc,d1		; d1 = Joypad data mask
	moveq.l	#-1,d2			; d2 = Cumulative joypad reading

	move.w	#$81fe,JOYOUT
	move.l	JOYIN,d0			; Read joypad, pause button, A button
	or.l		d1,d0			; Mask off unused bits
	ror.l	#4,d0
	and.l	d0,d2			; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
	move.w	#$81fd,JOYOUT
	move.l	JOYIN,d0			; Read *741 keys, B button
	or.l		d1,d0			; Mask off unused bits
	ror.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
	move.w	#$81fb,JOYOUT
	move.l	JOYIN,d0			; Read 2580 keys, C button
	or.l		d1,d0			; Mask off unused bits
	rol.l	#6,d0
	rol.l	#6,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
	move.w	#$81f7,JOYOUT
	move.l	JOYIN,d0			; Read 369# keys, Option button
	or.l		d1,d0			; Mask off unused bits
	rol.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== inputs active low

	moveq.l	#-1,d1
	eor.l	d2,d1			; d1 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== now inputs active high

	move.l	joycur,d0			; old joycur needed for determining the new joyedge
	move.l	d1,joycur			; Current joypad reading stored into joycur
	eor.l	d1,d0
	and.l	d1,d0
	move.l	d0,joyedge		;joypad, buttons, keys that were just pressed

;scan for player 2
	move.l	#$0ffffff3,d1		; d1 = Joypad data mask
	moveq.l	#-1,d2			; d2 = Cumulative joypad reading

	move.w	#$817f,JOYOUT
	move.l	JOYIN,d0			; Read joypad, pause button, A button
	or.l		d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	ror.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxxx RLDUxxxx xxxxxxxx xxxxxxxx
	move.w	#$81bf,JOYOUT
	move.l	JOYIN,d0			; Read *741 keys, B button
	or.l		d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	ror.l	#8,d0
	ror.l	#4,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxxxxxxx xxxxxxxx
	move.w	#$81df,JOYOUT
	move.l	JOYIN,d0			; Read 2580 keys, C button
	or.l		d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	rol.l	#8,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxxx 2580xxxx
	move.w	#$81ef,JOYOUT
	move.l	JOYIN,d0			; Read 369# keys, Option button
	or.l		d1,d0			; Mask off unused bits
	rol.b	#2,d0			; note the size of rol
	rol.l	#4,d0
	and.l	d0,d2			; d2 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== inputs active low

	moveq.l	#-1,d1
	eor.l	d2,d1			; d1 = xxAPxxBx RLDU741* xxCxxxOx 2580369# <== now inputs active high

	move.l	joycur+4,d0			; old joycur needed for determining the new joyedge
	move.l	d1,joycur+4			; Current joypad reading stored into joycur
	eor.l	d1,d0
	and.l	d1,d0
	move.l	d0,joyedge+4		;joypad, buttons, keys that were just pressed
	rts

Fire_A_Pressed
	Move.l	JoyCur,d0
	Btst	#FIRE_A,d0
	Rts
Fire_B_Pressed
	Move.l	JoyCur,d0
	Btst	#FIRE_B,d0
	Rts
Fire_C_Pressed
	Move.l	JoyCur,d0
	Btst	#FIRE_C,d0
	Rts
Direction_Pressed
	Move.l	JoyCur,d0
	Moveq	#20,d1
	Lsr.l	d1,d0
	And.w	#$f,d0
	Rts
Pause_Pressed
	Move.l	JoyCur,d0
	Btst	#PAUSE,d0
	Rts
Options_Pressed
	Move.l	JoyCur,d0
	Btst	#OPTION,d0
	Rts

Fire_A_Pressed_2
	Move.l	JoyCur+4,d0
	Btst	#FIRE_A,d0
	Rts
Fire_B_Pressed_2
	Move.l	JoyCur+4,d0
	Btst	#FIRE_B,d0
	Rts
Fire_C_Pressed_2
	Move.l	JoyCur+4,d0
	Btst	#FIRE_C,d0
	Rts
Direction_Pressed_2
	Move.l	JoyCur+4,d0
	Moveq	#20,d1
	Lsr.l	d1,d0
	And.w	#$f,d0
	Rts
Pause_Pressed_2
	Move.l	JoyCur+4,d0
	Btst	#PAUSE,d0
	Rts

Hash_Asterisk_Pressed2
	Move.l	JoyCur+4,d0
	Btst	#Key_Star,d0
	Beq.s	.Not_Pressed
	Btst	#Key_Hash,d0
.Not_Pressed	
	Rts

Hash_Asterisk_Pressed1
	Move.l	JoyCur,d0
	Btst	#Key_Star,d0
	Beq.s	.Not_Pressed
	Btst	#Key_Hash,d0
.Not_Pressed	
	Rts
