**************************************************************************************
*
* GodLib Keyboard Library
*
* [c] 2000-2002 Reservoir Gods 
*
* thanks to scy/tscc for jaguar teamtap info
**************************************************************************************

	import		gIKBD

	export		IKBD_GetHandler
	export		IKBD_SetHandler

	export		IKBD_GetMidiBytesWaiting
	export		IKBD_GetKbdBytesWaiting
	export		IKBD_PopMidiByte
	export		IKBD_PopKbdByte

	export		IKBD_Flush
	export		IKBD_FlushGemdos
	export		IKBD_SendCmd

	export		IKBD_MainHandler
	export		IKBD_PowerpadHandler
	export		IKBD_ReadPowerpadA
	export		IKBD_ReadPowerpadB

	export		IKBD_InitTosLink


**************************************************************************************
;	STRUCTS
**************************************************************************************

	OFFSET

sIKBD_pUnshiftTable:		ds.l	1
sIKBD_pShiftTable:			ds.l	1
sIKBD_pCapsTable:			ds.l	1

sIKBD_MidiHead:				ds.w	1
sIKBD_MidiTail:				ds.w	1

sIKBD_KbdHead:				ds.w	1
sIKBD_KbdTail:				ds.w	1

sIKBD_KbdOverflowFlag:		ds.b	1
sIKBD_MidiOverflowFlag:		ds.b	1

sIKBD_Joy0Packet:			ds.b	1
sIKBD_Joy1Packet:			ds.b	1
sIKBD_MouseMovedFlag:		ds.b	1
sIKBD_MouseKeys:			ds.b	1

sIKBD_KeyPressedFlag:		ds.b	1
sIKBD_LastKeypress:			ds.b	1

sIKBD_MouseX:				ds.w	1
sIKBD_MouseY:				ds.w	1

sIKBD_TeamTapActiveFlag:	ds.b	1
sIKBD_TeamTapActiveBits:	ds.b	1

sIKBD_Pad0Dir:				ds.b	1
sIKBD_Pad1Dir:				ds.b	1
sIKBD_Pad0Key:				ds.w	1
sIKBD_Pad1Key:				ds.w	1

sIKBD_TeamTapDirs:			ds.b	8
sIKBD_TeamTapKeys:			ds.w	8

sIKBD_KbdPressTable:		ds.b	128
sIKBD_MidiBuffer:			ds.b	2048
sIKBD_KbdBuffer:			ds.b	2048

sIKBD_StatusData:			ds.b	8
sIKBD_TimeOfDay:			ds.b	6
sIKBD_Temp:					ds.b	2


**************************************************************************************
	TEXT
**************************************************************************************


*------------------------------------------------------------------------------------*
* FUNCTION : void (*IKBD_GetHandler())()
* ACTION   : returns pointer to current ikbd handler
* CREATION : 25.03.00 PNK
*------------------------------------------------------------------------------------*

IKBD_GetHandler:
	move.l	$118.w,a0
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_SetHandler( void (*apHandler)() )
* ACTION   : returns pointer to current ikbd handler
* CREATION : 25.03.00 PNK
*------------------------------------------------------------------------------------*

IKBD_SetHandler:
	move.w	sr,-(a7)
	ori.w	#$0700,sr
	move.l	a0,$118.w
	move.w	(a7)+,sr
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : U16 IKBD_GetMidiBytesWaiting()
* ACTION   : gets numbers of MIDI bytes waiting in buffer
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_GetMidiBytesWaiting:

	move.w	gIKBD+sIKBD_MidiTail,d0		; tail position
	sub.w	gIKBD+sIKBD_MidiHead,d0		; -head position = size of queue
	bpl.s	.plus						; no need to cater for cyclic buffer
	add.w	#2048,d0					; absolute queue size
.plus:

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : U8 Kbd_PopMidiByte()
* ACTION   : retrieves byte from MIDI buffer
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_PopMidiByte:
	movem.l	a0/d1,-(a7)					; save registers
	
	move.w	gIKBD+sIKBD_MidiHead,d1		; current head index
	lea		gIKBD+sIKBD_MidiBuffer,a0	; midi buffer
	move.b	(a0,d1.w),d0				; retrieve byte from buffer
	addq.w	#1,d1						; point head to next
	and.w	#2047,d1					; ensure cyclical buffer
	move.w	d1,gIKBD+sIKBD_MidiHead		; update head index

	movem.l	(a7)+,a0/d1					; save registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : U16 IKBD_GetKbdBytesWaiting()
* ACTION   : gets numbers of IKBD bytes waiting in buffer
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_GetKbdBytesWaiting:

	move.w	gIKBD+sIKBD_KbdTail,d0	; tail position
	sub.w	gIKBD+sIKBD_KbdHead,d0	; -head position = size of queue
	bpl.s	.plus					; no need to cater for cyclic buffer
	add.w	#2048,d0				; absolute queue size
.plus:

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : U8 IKBD_PopKbdByte()
* ACTION   : retrieves byte from IKBD buffer
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_PopKbdByte:
	movem.l	a0/d1,-(a7)					; save registers
	
	move.w	gIKBD+sIKBD_KbdHead,d1		; current head index
	lea		gIKBD+sIKBD_KbdBuffer,a0	; midi buffer
	move.b	(a0,d1.w),d0				; retrieve byte from buffer
	addq.w	#1,d1						; point head to next
	and.w	#2047,d1					; ensure cyclical buffer
	move.w	d1,gIKBD+sIKBD_KbdHead		; update head index

	movem.l	(a7)+,a0/d1					; save registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_Flush()
* ACTION   : flushes keyboard by reading all data waiting in keyboard
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_Flush:
	move.l	d0,-(a7)				; save registers

.flush:
	btst    #0,$fffffc00.w			; kbd data waiting?
	beq.s   .empty					; no, buffer empty
	move.b  $fffffc02.w,D0			; read data
	bra.s   .flush					; check for more data

.empty:
	move.l	(a7)+,d0				; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_FlushGemdos()
* ACTION   : flushes gemdos keyboard buffers
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_FlushGemdos:
	movem.l	d0-d2/a0-a2,-(a7)	; save registers

.loop:
	move.w	#$b,-(a7)			; Cconis()
	trap	#1					; call GEMDOS
	addq.l	#2,a7				; fix stack

	tst.w	d0					; characters waiting?
	beq		.empty				; no, empty
	
	move.w	#8,-(a7)			; Cnecin()
	trap	#1					; call GEMDOS
	addq.l	#2,a7				; fix stack
	bra.s	.loop				; loop until buffer empty

.empty:
	movem.l	(a7)+,d0-d2/a0-a2	; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_SendCmd( U8 aCmd )
* ACTION   : sends command byte to keyboard
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_SendCmd:

.wait:
   	btst    #1,$fffffc00.w			; kbd ready to receive data?
	beq.s   .wait					; not yet
	move.b  d0,$fffffc02.w			; send cmd to kbd

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_MainHandler()
* ACTION   : ikbd handler - replaces system 118 routines
* COMMENTS : handles IKBD & MIDI interrupts. calls relevant packet handler
*            loops until no interrupts left
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_MainHandler:

;	move.w	#$2500,sr				; don't interrupt me! was 2500
	movem.l	d0-d2/a0-a3,-(a7)		; save registers

	lea		gIKBD,a3				; ikbd data structure
.int_loop:
	lea		$fffffc04.w,a0			; midi base register
	move.l	kbdMidiHandler,a1		; midi packet process routine
	bsr		IKBD_CheckPacket		; check if any midi packets received
	lea		$fffffc00.w,a0			; kbd base register
	move.l	kbdIkbdHandler,a1		; ikbd packet process routine
	bsr		IKBD_CheckPacket		; check if any ikbd packets received
	btst	#4,$fffffa01.w			; another interrupt to process?
	beq.s	.int_loop				; yes, process it!

	movem.l	(a7)+,d0-d2/a0-a3		; restore registers

	bclr	#6,$fffffa11.w			; signal end of ikbd interrupt
;	move.b	#$bf,$fffffa11.w		; signal end of ikbd interrupt
	rte								; return from exception (& restore status reg)


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_CheckPacket( KBD_REG *, packet_handler * )
* ACTION   : check ikbd command registers to see if packet needs processing
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_CheckPacket:

	move.b	(a0),d1					; read command register
	btst	#7,d1					; interrupt request?
	beq		.no_packet				; no
	btst	#0,d1					; receiver full?
	beq		.full					; no, check for overflow
	move.b	2(a0),d0					; read midi data
	jsr		(a1)					; jump to handler
.full:
	and.b	#$20,d1					; receiver overflow?
	beq.s	.no_packet				; no
	move.b	2(a0),d1				; flush ikbd by reading data
.no_packet:

	rts	


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_MidiPacketHandler( KBD_REG * )
* ACTION   : processes midi packet
* COMMENTS : midi data is saved in 2048 entry cyclical buffer
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_MidiPacketHandler:

	move.b	2(a0),d0					; read midi data

	move.w	sIKBD_MidiTail(a3),d2		; current tail position
	lea		sIKBD_MidiBuffer(a3),a1		; buffer for midi data
	move.b	d0,(a1,d2.w)				; store received byte in buffer
	addq.w	#1,d2						; inc tail
	and.w	#2047,d2					; clip to cyclical buffer (2048 entry)
	cmp.w	sIKBD_MidiHead(a3),d2		; buffer full? ( tail has reached head pos) 
	beq.s	.full						; yes,
	move.w	d2,sIKBD_MidiTail(a3)		; update tail position
	rts
.full:
	st.b	sIKBD_MidiOverflowFlag(a3)	; flag midi buffer as full

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_KbdDeterminePacket
* ACTION   : determines type of keyboard packet
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_KbdDeterminePacket:
	andi.w	#$ff,d0						; mask high byte of word
	moveq	#0,d2						; clear d2
	move.b	d0,d2						; copy input byte
	sub.w	#$f6,d2						; -packet base
	bpl		.findHandler				; it's a valid packet

	lea		sIKBD_KbdBuffer(a3),a2		; buffer for IKBD
	move.w	sIKBD_KbdTail(a3),d2		; current tail position
	lea		(a2,d2.w),a2				; get to position in buffer
	addq.w	#1,d2						; next tail position
	and.w	#2047,d2					; ensure tail in cyclic buffer
	cmp.w	sIKBD_KbdHead(a3),d2		; check for overflow
	seq		sIKBD_KbdOverflowFlag(a3)	; set overflow flag
	beq.s	.overflow					; skip tail update
	move.w	d2,sIKBD_KbdTail(a3)		; store update tail position
.overflow:
	move.b	d0,(a2)						; store key in ikbd buffer	

	lea		sIKBD_KbdPressTable(a3),a2	; keyboard press table
	bclr	#7,d0						; key press?
	beq.s	.setkey						; yes, set it
	clr.b	(a2,d0.w)					; indicate key release
	bra.s	.endkey						; end subroutine

.setkey:
	st.b	(a2,d0.w)					; mark key as pressed
	st.b	sIKBD_KeyPressedFlag(a3)	; indicate keyboard press
	move.b	d0,sIKBD_LastKeypress(a3)	; store last key press

.endkey:
	rts

.findHandler:

	add.w	d2,d2						; packet index*2
	add.w	d2,d2						; packet index*4
	lea		gfIkbdGrabbers,a2			; packet handler function table
	move.l	(a2,d2.w),kbdIkbdHandler	; address of packet handler function

	cmp.w	#2*4,d2						; is this a relative mouse packet?
	blt.s	.notRelMouse				; no, index too low
	cmp.w	#4*4,d2						; is this a relative mouse packet?
	bgt.s	.notRelMouse				; no index too high

	andi.w	#3,d0						; mask all but mouse key bits
	move.b	d0,sIKBD_MouseKeys(a3)		; store mouse keys

.notRelMouse:

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabStatus0
* ACTION   : grabs status packet byte 0
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabStatus0:
	move.b	d0,sIKBD_StatusData+0(a3)					; store first byte of status packet
	move.l	#IKBD_GrabStatus1,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabStatus1
* ACTION   : grabs status packet byte 1
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabStatus1:
	move.b	d0,sIKBD_StatusData+1(a3)					; store second byte of status packet
	move.l	#IKBD_GrabStatus2,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabStatus2
* ACTION   : grabs status packet byte 2
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabStatus2:
	move.b	d0,sIKBD_StatusData+2(a3)					; store third byte of status packet
	move.l	#IKBD_GrabStatus3,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabStatus3
* ACTION   : grabs status packet byte 3
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabStatus3:
	move.b	d0,sIKBD_StatusData+3(a3)					; store fourth byte of status packet
	move.l	#IKBD_GrabStatus4,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabStatus4
* ACTION   : grabs status packet byte 4
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabStatus4:
	move.b	d0,sIKBD_StatusData+4(a3)					; store fourth byte of status packet
	move.l	#IKBD_GrabStatus5,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabStatus5
* ACTION   : grabs status packet byte 5
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabStatus5:
	move.b	d0,sIKBD_StatusData+5(a3)					; store sixth byte of status packet
	move.l	#IKBD_GrabStatus6,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabStatus7
* ACTION   : grabs status packet byte 7
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabStatus6:
	move.b	d0,sIKBD_StatusData+6(a3)					; store sevent byte of status packet
	move.l	#IKBD_KbdDeterminePacket,kbdIkbdHandler		; end of packet, back to main ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabAbsMouse
* ACTION   : grabs absolute mouse packet keys byte
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabAbsMouse:
	move.b	d0,sIKBD_MouseKeys(a3)						; store mouse keys
	move.l	#IKBD_GrabAbsMouseX0,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabAbsMouseX0
* ACTION   : grabs absolute mouse packet X MSB
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabAbsMouseX0:
	move.b	d0,sIKBD_Temp(a3)							; store mouse x MSB
	move.l	#IKBD_GrabAbsMouseX1,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabAbsMouseX1
* ACTION   : grabs absolute mouse packet X LSB
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabAbsMouseX1:
	move.b	d0,sIKBD_MouseX+1(a3)						; store mouse X LSB
	move.b	sIKBD_Temp,sIKBD_MouseX+0					; copy mouse X MSB to correct place
	move.l	#IKBD_GrabAbsMouseY0,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabAbsMouseY0
* ACTION   : grabs absolute mouse packet Y MSB
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabAbsMouseY0:
	move.b	d0,sIKBD_Temp(a3)							; store mouse Y MSB
	move.l	#IKBD_GrabAbsMouseY1,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabAbsMouseY1
* ACTION   : grabs absolute mouse packet Y LSB
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabAbsMouseY1:
	move.b	d0,sIKBD_MouseY+1(a3)						; store mouse Y LSB
	move.b	sIKBD_Temp,sIKBD_MouseY+0					; copy mouse Y MSB to correct place
	move.l	#IKBD_KbdDeterminePacket,kbdIkbdHandler		; next ikbd handler
	st.b	sIKBD_MouseMovedFlag(a3)					; flag mouse moved
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabRelMouseX
* ACTION   : grabs relative mouse x
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabRelMouseX:
	move.b	d0,d2										; realtive mouse x
	ext.w	d2											; sign extend
	add.w	d2,sIKBD_MouseX(a3)							; move mouse x relatively
	move.l	#IKBD_GrabRelMouseY,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabRelMouseY
* ACTION   : grabs relative mouse Y
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabRelMouseY:
	move.b	d0,d2										; relative mouse y
	ext.w	d2											; sign extend
	add.w	d2,sIKBD_MouseY(a3)							; move mouse y relatively
	move.l	#IKBD_KbdDeterminePacket,kbdIkbdHandler		; next ikbd handler
	st.b	sIKBD_MouseMovedFlag(a3)					; flag mouse moved
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabTimeOfDay0
* ACTION   : grabs time of day byte 0
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabTimeOfDay0:
	move.b	d0,sIKBD_TimeOfDay+0(a3)					; store first byte of time of day
	move.l	#IKBD_GrabTimeOfDay1,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabTimeOfDay1
* ACTION   : grabs time of day byte 1
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabTimeOfDay1:
	move.b	d0,sIKBD_TimeOfDay+1(a3)					; store second byte of time of day
	move.l	#IKBD_GrabTimeOfDay2,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabTimeOfDay2
* ACTION   : grabs time of day byte 2
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabTimeOfDay2:
	move.b	d0,sIKBD_TimeOfDay+2(a3)					; store third byte of time of day
	move.l	#IKBD_GrabTimeOfDay3,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabTimeOfDay3
* ACTION   : grabs time of day byte 3
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabTimeOfDay3:
	move.b	d0,sIKBD_TimeOfDay+3(a3)					; store fourth byte of time of day
	move.l	#IKBD_GrabTimeOfDay4,kbdIkbdHandler			; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabTimeOfDay4
* ACTION   : grabs time of day byte 4
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabTimeOfDay4:
	move.b	d0,sIKBD_TimeOfDay+4(a3)					; store fifth byte of time of day
	move.l	#IKBD_GrabTimeOfDay5,kbdIkbdHandler			; next ikbd handler
	rts						


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabTimeOfDay5
* ACTION   : grabs time of day byte 5
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabTimeOfDay5:
	move.b	d0,sIKBD_TimeOfDay+5(a3)					; store sixth byte of time of day
	move.l	#IKBD_KbdDeterminePacket,kbdIkbdHandler		; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabJoyReport
* ACTION   : grabs joystick packet report
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabJoyReport:
	move.b	d0,sIKBD_Joy0Packet(a3)						; store joystick 0 packet
	move.l	#IKBD_GrabJoy1,kbdIkbdHandler				; next ikbd handler
	rts												


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabJoy0
* ACTION   : grabs joystick 0 packet
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabJoy0:
	move.b	d0,sIKBD_Joy0Packet(a3)						; store joystick 0 packet
	move.l	#IKBD_KbdDeterminePacket,kbdIkbdHandler		; next ikbd handler
	rts		
						
																				
*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_GrabJoy1
* ACTION   : grabs joystick 1 packet
* CREATION : 04.12.01 PNK
*------------------------------------------------------------------------------------*

IKBD_GrabJoy1:
	move.b	d0,sIKBD_Joy1Packet(a3)						; store joystick 1 packet
	move.l	#IKBD_KbdDeterminePacket,kbdIkbdHandler		; next ikbd handler
	rts												



*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_InitTosLink
* ACTION   : ensures o/s ikbd handler still functions
* COMMENTS : useful for debugging!
*            may only work on certain TOS versions
* TOS 2.06 : a0=ed8 function=E03044
* TOS 4.04 : a0=f96 function=E0340A
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_InitTosLink:

;	move.l	d0,kbd_TosBuffer+2
;	move.l	d1,kbd_TosJump+2
;	move.w	#$4E71,kbd_StoreKey

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_KeyHandler( KBD_REG *, PACKET * )
* ACTION   : processes key packet
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_KeyHandler:
	move.w	d1,-(a7)					; save registers

	lea		sIKBD_KbdBuffer(a3),a2		; buffer for IKBD
	move.w	sIKBD_KbdTail(a3),d1		; current tail position
	lea		(a2,d1.w),a2				; get to position in buffer
	addq.w	#1,d1						; next tail position
	and.w	#2047,d1					; ensure tail in cyclic buffer
	cmp.w	sIKBD_KbdHead(a3),d1		; check for overflow
	seq		sIKBD_KbdOverflowFlag(a3)	; set overflow flag
	beq.s	.overflow					; skip tail update
	move.w	d1,sIKBD_KbdTail(a3)		; store update tail position
.overflow:
	move.b	d0,(a2)						; store key in ikbd buffer	

	lea		sIKBD_KbdPressTable(a3),a2	; keyboard press table
	bclr	#7,d0						; key press?
	beq.s	.setkey						; yes, set it
	clr.b	(a2,d0.w)					; indicate key release
	bra.s	.endkey						; end subroutine

.setkey:
	st.b	(a2,d0.w)					; mark key as pressed
	st.b	sIKBD_KeyPressedFlag(a3)	; indicate keyboard press
	move.b	d0,sIKBD_LastKeypress(a3)	; store last key press

.endkey:
	move.w	(a7)+,d1					; restore registers
	rts                             


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_PowerpadHandler()
* ACTION   : reads both powerpads
* COMMENTS : this routine should be called immediately after VBL
*            or called on VBL routine
* CREATION : 15.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_PowerpadHandler:
	movem.l	a0-a2/d0-d3,-(a7)			; save registers

.check0:
	moveq	#1,d0
	and.b	gIKBD+sIKBD_TeamTapActiveBits,d0
	beq.s	.noTeamTap0

	moveq	#4-1,d0
	lea		gKbdJagPadMasksA,a0
	lea		gIKBD+sIKBD_TeamTapDirs,a1
	lea		gIKBD+sIKBD_TeamTapKeys,a2
.loop0:		
	bsr		IKBD_ReadPadMatrixA
	addq.l	#4,a0
	addq.l	#1,a1
	addq.l	#2,a2
	dbra	d0,.loop0

	bra.s	.check1
	
.noTeamTap0:

	lea		gKbdJagPadMasksA,a0
	lea		gIKBD+sIKBD_Pad0Dir,a1
	lea		gIKBD+sIKBD_Pad0Key,a2
	bsr		IKBD_ReadPadMatrixA

.check1:
	moveq	#2,d0
	and.b	gIKBD+sIKBD_TeamTapActiveBits,d0
	beq.s	.noTeamTap1

	moveq	#4-1,d0
	lea		gKbdJagPadMasksB,a0
	lea		gIKBD+sIKBD_TeamTapDirs+4,a1
	lea		gIKBD+sIKBD_TeamTapKeys+8,a2
.loop1:
	bsr		IKBD_ReadPadMatrixB
	addq.l	#4,a0
	addq.l	#1,a1
	addq.l	#2,a2
	dbra	d0,.loop1

	bra.s	.done


.noTeamTap1:

	lea		gKbdJagPadMasksB,a0
	lea		gIKBD+sIKBD_Pad1Dir,a1
	lea		gIKBD+sIKBD_Pad1Key,a2
	bsr		IKBD_ReadPadMatrixB

.done:

	movem.l	(a7)+,a0-a2/d0-d3			; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_ReadPowerpadA()
* ACTION   : reads jaguar PowerPad A
* CREATION : 15.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_ReadPowerpadA:
	movem.l	d0-d3/a0-a1,-(a7)	; save registers

	lea		$ffff9200.w,a0		; extended port address (read only)
	lea		2(a0),a1			; extended port address (read/write)
	moveq	#0,d2				; clear d2 - it will contain key information
	move.w	#$fffe,(a1)			; write mask
	move.w	(a1),d0				; read directional data
	move.w	(a0),d3				; read fire_a/pause data
	not.w	d0					; invert bits (0->1)
	move.w	d0,d1				; save directional data
	lsr.w	#8,d1				; shift into low bits (0-3)
	and.w	#%1111,d1			; mask off unwanted data
	lsr.w	#1,d3				; check bit 0 (pause data)
	bcs.s	.no_pause			; if set, pause is not pressed
	bset	#13,d2				; pause is pressed so set pause bit
.no_pause:
	lsr.w	#1,d3				; check bit 1 (fire a data)
	bcs.s	.no_firea			; if set, fire is not pressed
	bset	#7,d1				; fire_a is pressed, so set fire_a bit
.no_firea:
	move.w	#$fffd,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#1,d3				; check fire_b
	bne.s	.no_fireb			; if set, fire_b is not pressed
	bset	#6,d1				; fire_b is pressed, set relevant bit
.no_fireb:
	lsr.w	#8,d0				; shift key data into bits 0-3
	and.w	#%1111,d0			; mask off unwanted data
	or.w	d0,d2				; store in key word

	move.w	#$fffb,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#1,d3				; check for fire_c
	bne.s	.no_firec			; if set, fire_c is not pressed
	bset	#5,d1				; fire_c is pressed, set relevant bit
.no_firec:
	lsr.w	#4,d0				; shift key data into bits 4-7
	and.w	#%11110000,d0		; mask off unwanted data
	or.w	d0,d2				; store in key word

	move.w	#$fff7,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#1,d3				; check for option
	bne.s	.no_option 			; if set, option is not pressed
	bset	#12,d2				; set option bit
.no_option:
	and.w	#%111100000000,d0	; mask off unwanted bits
	or.w	d0,d2				; store key data

	move.b	d1,gIKBD+sIKBD_Pad0Dir		; save directional+fire data in variable
	move.w	d2,gIKBD+sIKBD_Pad0Key		; save key data in variable

	movem.l	(a7)+,d0-d3/a0-a1	; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_ReadPowerpadB()
* ACTION   : reads jaguar PowerPad B
* CREATION : 15.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_ReadPowerpadB:
	movem.l	d0-d3/a0-a1,-(a7)	; save registers

	lea		$ffff9200.w,a0		; extended port address (read only)
	lea		2(a0),a1			; extended port address (read/write)
	moveq	#0,d2				; clear d2 - it will contain key information
	move.w	#$ffef,(a1)			; write mask
	move.w	(a1),d0				; read directional data
	move.w	(a0),d3				; read fire_a/pause data
	not.w	d0					; invert bits (0->1)
	move.w	d0,d1				; save directional data
	lsr.w	#8,d1				; shift directional data down
	lsr.w	#4,d1				; shift into low bits (0-3)
	and.w	#%1111,d1			; mask off unwanted data
	btst	#2,d3				; check bit 2 (pause data)
	bne.s	.no_pause			; if set, pause is not pressed
	bset	#13,d2				; pause is pressed so set pause bit
.no_pause:
	btst	#3,d3				; check bit 3 (fire a data)
	bne.s	.no_firea			; if set, fire is not pressed
	bset	#7,d1				; fire_a is pressed, so set fire_a bit
.no_firea:
	move.w	#$ffdf,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#3,d3				; check fire_b
	bne.s	.no_fireb			; if set, fire_b is not pressed
	bset	#6,d1				; fire_b is pressed, set relevant bit
.no_fireb:	
	lsr.w	#8,d0
	lsr.w	#4,d0				; shift key data into bits 0-3
	and.w	#%1111,d0			; mask off unwanted data
	or.w	d0,d2				; store in key word

	move.w	#$ffbf,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#3,d3				; check for fire_c
	bne.s	.no_firec			; if set, fire_c is not pressed
	bset	#5,d1				; fire_c is pressed, set relevant bit
.no_firec:		
	lsr.w	#8,d0				; shift key data into bits 4-7
	and.w	#%11110000,d0		; mask off unwanted data
	or.w	d0,d2				; store in key word

	move.w	#$ff7f,(a1)			; write mask
	move.w	(a1),d0				; read key data
	move.w	(a0),d3				; read fire data
	not.w	d0					; invert bits (0->1)
	btst	#3,d3				; check for option
	bne.s	.no_option 			; if set, option is not pressed
	bset	#12,d2				; set option bit
.no_option:
	lsr.w	#4,d0				; shift key data into bits 8-11
	and.w	#%111100000000,d0	; mask off unwanted bits
	or.w	d0,d2				; store key data

	move.b	d1,gIKBD+sIKBD_Pad1Dir		; save directional+fire data in variable
	move.w	d2,gIKBD+sIKBD_Pad1Key		; save key data in variable

	movem.l	(a7)+,d0-d3/a0-a1	; restore registers
	rts


;-----------------------------------------------
; 9203 : W : E
; 9201 : R :                .[1:FIREA].[0:PAUSE]
; 9203 : R : [3: U ].[2: D ].[1:L    ].[0:R    ]
;-----------------------------------------------
; 9203 : W : D
; 9201 : R :                .[1:FIREB].[0:     ]
; 9203 : R : [3: 1 ].[2: 4 ].[1: 7   ].[0: *   ]
;-----------------------------------------------
; 9203 : W : D
; 9201 : R :                .[1:FIREC].[0:     ]
; 9203 : R : [3: 2 ].[2: 5 ].[1: 8   ].[0: 0   ]
;-----------------------------------------------
; 9203 : W : D
; 9201 : R :                .[1:OPT  ].[0:     ]
; 9203 : R : [3: 3 ].[2: 6 ].[1: 9   ].[0: #   ]
;-----------------------------------------------


; a0->table
; a1->dirs
; a2->keys	

*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_ReadPadMatrixA
* ACTION   : reads teamtap a
* CREATION : 11.11.01 PNK
*------------------------------------------------------------------------------------*

IKBD_ReadPadMatrixA:
	movem.l	d0-d2/a0,-(a7)

	move.b	(a0)+,$ffff9203.w			; select ( [fireA.pause].[rldu] )
	bsr		.pause						; lets wait a while
	moveq	#0,d1						; clear key
	move.b	$ffff9201.w,d2				; [fireA.pause]
	move.b	$ffff9202.w,d0				; read directional data [rldu]
	not.b	d0							; invrt
	and.b	#%1111,d0					; mask out unwanted bits
	move.b	(a0)+,$ffff9203.w			; select ( [fireB.-].[147*] )
	btst	#0,d2						; check bit 0 [pause]
	bne.s	.no_pause					; if set, pause is not pressed
	bset	#13,d1						; pause is pressed so set pause bit
.no_pause:
	btst	#1,d2						; check bit 1 (fire a data)
	bne.s	.no_firea					; if set, fire is not pressed
	bset	#7,d0						; fire_a is pressed, so set fire_a bit
.no_firea:

	move.b	$ffff9201.w,d2				; read fire b
	btst.b	#1,d2						; check fire b
	bne.s	.nofireb					; zero=not pressed
	bset	#6,d0						; set fire b
.nofireb:
	move.b	$ffff9202.w,d2				; read keys
	move.b	(a0)+,$ffff9203.w			; select ( [fireC.-].[2580] )
	not.b	d2							; invert bits
	and.b	#%1111,d2					; mask out unwanted bits
	or.b	d2,d1						; combine keys

	move.b	$ffff9201.w,d2				; read fire c
	btst.b	#1,d2						; is firec pressed?
	bne.s	.nofirec					; zero=not pressed
	bset	#5,d0						; set fire c
.nofirec:
	move.b	$ffff9202.w,d2				; read keys
	move.b	(a0)+,$ffff9203.w			; select ( [opt.-].[369#] )
	not.b	d2							; invert bits
	and.b	#%1111,d2					; mask out unwanted bits
	lsl.w	#4,d2						; shift into bits 4-7
	or.b	d2,d1						; combine keys

	move.b	$ffff9201.w,d2				; read opt
	btst.b	#1,d2						; is option pressed?
	bne.s	.noopt						; not zero=not pressed
	bset	#12,d1						; mark option bit
.noopt:
	move.b	$ffff9202.w,d2				; read keys
	not.b	d2							; invert bits
	and.w	#%1111,d2					; mask out unwanted bits
	lsl.w	#8,d2						; shift into bits 8-11
	or.w	d2,d1						; combine keys

	move.b	d0,(a1)						; store directions+fire
	move.w	d1,(a2)						; store keys

	movem.l	(a7)+,d0-d2/a0
.pause:
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : IKBD_ReadPadMatrixB
* ACTION   : reads teamtap b
* CREATION : 11.11.01 PNK
*------------------------------------------------------------------------------------*

IKBD_ReadPadMatrixB:
	movem.l	d0-d2/a0,-(a7)

	move.b	(a0)+,$ffff9203.w			; select ( [fireA.pause].[rldu] )
	bsr		.pause						; lets wait a while
	moveq	#0,d1						; clear key
	move.b	$ffff9201.w,d2				; [fireA.pause]
	move.b	$ffff9202.w,d0				; read directional data [rldu]
	not.b	d0							; invert
	lsr.w	#4,d0						; shift into bits 3-0
	and.b	#%1111,d0					; mask out unwanted bits
	move.b	(a0)+,$ffff9203.w			; select ( [fireB.-].[147*] )
	btst	#2,d2						; check bit 0 [pause]
	bne.s	.no_pause					; if set, pause is not pressed
	bset	#13,d1						; pause is pressed so set pause bit
.no_pause:
	btst	#3,d2						; check bit 1 (fire a data)
	bne.s	.no_firea					; if set, fire is not pressed
	bset	#7,d0						; fire_a is pressed, so set fire_a bit
.no_firea:

	move.b	$ffff9201.w,d2				; read fire b
	btst.b	#3,d2						; check fire b
	bne.s	.nofireb					; zero=not pressed
	bset	#6,d0						; set fire b
.nofireb:
	move.b	$ffff9202.w,d2				; read keys
	move.b	(a0)+,$ffff9203.w			; select ( [fireC.-].[2580] )
	not.b	d2							; invert bits
	lsr.w	#4,d2
	and.b	#%1111,d2					; mask out unwanted bits
	or.b	d2,d1						; combine keys

	move.b	$ffff9201.w,d2				; read fire c
	btst.b	#3,d2						; is firec pressed?
	bne.s	.nofirec					; zero=not pressed
	bset	#5,d0						; set fire c
.nofirec:
	move.b	$ffff9202.w,d2				; read keys
	move.b	(a0)+,$ffff9203.w			; select ( [opt.-].[369#] )
	not.b	d2							; invert bits
	and.b	#%11110000,d2				; mask out unwanted bits
	or.b	d2,d1						; combine keys

	move.b	$ffff9201.w,d2				; read opt
	btst.b	#3,d2						; is option pressed?
	bne.s	.noopt						; not zero=not pressed
	bset	#12,d1						; mark option bit
.noopt:
	move.b	$ffff9202.w,d2				; read keys
	not.b	d2							; invert bits
	and.w	#%11110000,d2				; mask out unwanted bits
	lsl.w	#4,d2						; shift into bits 8-11
	or.w	d2,d1						; combine keys

	move.b	d0,(a1)						; store directions+fire
	move.w	d1,(a2)						; store keys

	movem.l	(a7)+,d0-d2/a0
.pause:
	rts


teamtaptab:     DC.B $EE,$DD,$BB,$77  ;first 4 bytes are the same for non-teamtap controller
                DC.B $00,$11,$22,$33
                DC.B $44,$55,$66,$88
                DC.B $99,$AA,$CC,$FF
noteamtap:


**************************************************************************************
	DATA
**************************************************************************************


gfIkbdGrabbers:
	dc.l	IKBD_GrabStatus0		;	$f6
	dc.l	IKBD_GrabAbsMouse		;	$f7
	dc.l	IKBD_GrabRelMouseX		;	$f8
	dc.l	IKBD_GrabRelMouseX		;	$f9
	dc.l	IKBD_GrabRelMouseX		;	$fa
	dc.l	IKBD_GrabRelMouseX		;	$fb
	dc.l	IKBD_GrabTimeOfDay0		;	$fc
	dc.l	IKBD_GrabJoyReport		;	$fd
	dc.l	IKBD_GrabJoy0			;	$fe
	dc.l	IKBD_GrabJoy1			;	$ff


gKbdJagPadMasksA:	
	dc.b	$fe,$fd,$fb,$f7
	dc.b	$f0,$f1,$f2,$f3
	dc.b	$f4,$f5,$f6,$f8
	dc.b	$f9,$fa,$fc,$ff

gKbdJagPadMasksB:	
	dc.b	$ef,$df,$bf,$7f
	dc.b	$0f,$1f,$2f,$3f
	dc.b	$4f,$5f,$6f,$8f
	dc.b	$9f,$af,$cf,$ff

	ALIGN	4

kbdMidiHandler:		dc.l	IKBD_MidiPacketHandler
kbdIkbdHandler:		dc.l	IKBD_KbdDeterminePacket

kbdKeyCounter:		dc.w	0
kbdPacketCounter:	dc.w	0
kbdPacketPtr:		dc.l	kbdPacketBuffer

kbdPacketBuffer:	ds.b	256

