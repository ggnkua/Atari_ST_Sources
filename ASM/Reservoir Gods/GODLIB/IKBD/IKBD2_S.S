**************************************************************************************
*
* GodLib Keyboard Library
*
* [c] 2000 Reservoir Gods 
*
* thanks to scy/tscc for jaguar teamtap code
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

sIKBD_pUnshiftTable:	ds.l	1
sIKBD_pShiftTable:		ds.l	1
sIKBD_pCapsTable:		ds.l	1

sIKBD_MidiHead:			ds.w	1
sIKBD_MidiTail:			ds.w	1

sIKBD_KbdHead:			ds.w	1
sIKBD_KbdTail:			ds.w	1

sIKBD_KbdOverflowFlag:	ds.b	1
sIKBD_MidiOverflowFlag:	ds.b	1

sIKBD_Joy0Packet:		ds.b	1
sIKBD_Joy1Packet:		ds.b	1
sIKBD_MouseMovedFlag:	ds.b	1
sIKBD_MouseKeys:		ds.b	1

sIKBD_KeyPressedFlag:	ds.b	1
sIKBD_LastKeypress:		ds.b	1

sIKBD_MouseX:			ds.w	1
sIKBD_MouseY:			ds.w	1

sIKBD_TeamTapActiveFlag:	ds.b	1
sIKBD_TeamTapActiveBits:	ds.b	1

sIKBD_Pad0Dir:			ds.b	1
sIKBD_Pad1Dir:			ds.b	1
sIKBD_Pad0Key:			ds.w	1
sIKBD_Pad1Key:			ds.w	1

sIKBD_TeamTapDirs:			ds.b	8
sIKBD_TeamTapKeys:			ds.w	8

sIKBD_KbdPressTable:	ds.b	128
sIKBD_MidiBuffer:		ds.b	2048
sIKBD_KbdBuffer:		ds.b	2048


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
* FUNCTION : void IKBD_KbdPacketHandler( KBD_REG * )
* ACTION   : processes ikbd packet
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_KbdPacketHandler:

kbd_KeyLoop:
	moveq	#0,d0						; clear d0
	move.b	2(a0),d0					; read ikbd data
	tst.w	kbdKeyCounter				; is this first byte?
	beq		kbd_CheckHead				; yes, so check for header
		
	move.l	kbdPacketPtr,a1				; ptr into packet storage area
	move.b	d0,(a1)+					; store keyboard packet data
	move.l	a1,kbdPacketPtr				; update packet ptr
	subq.w	#1,kbdKeyCounter			; decrement packet bytes to get
	bne		kbd_LastKeyCheck			; more data to get

kbd_ProcessPacket:
	lea		kbdPacketBuffer,a1			; start of key storage data
	moveq	#0,d0						; clear d0
	move.b	(a1),d0						; get first byte
	sub.w	#$f6,d0						; minus default packet header value
	cmp.w	#10,d0						; out of range?
	bhs		kbd_LastKeyCheck			; yes, check next packet
	lea		kbdPacketHandlers,a2		; packet handler table
	lsl.w	#2,d0						; make index
	move.l	(a2,d0.w),a2				; read packet handler from table
	jsr 	(a2)						; jump to packet handler
	bra		kbd_LastKeyCheck			; check for more key data

kbd_CheckHead:
	cmp.w	#$f6,d0						; is it a packer header?
	blt.s	kbd_StoreKey				; its just a key, store it

	move.b	d0,kbdPacketBuffer			; store packet header
	move.l	#kbdPacketBuffer+1,kbdPacketPtr	; init packet ptr
	lea		kbdPacketSizes,a1			; packet table
	sub.b	#$f6,d0						; d0 is offset
	add.w	d0,d0
	move.w	(a1,d0.w),kbdKeyCounter		; bytes of data to be read
	bra		kbd_LastKeyCheck			; get data

kbd_StoreKey:
	bra.s	kbd_no_debug				; can be NOPed out for o/s compatibility
	movem.l	d0-d7/a0-a6,-(a7)			; save registers
	sub.l	a5,a5
kbd_TosBuffer:
	lea		$12345678,a0
kbd_TosJump:
	jsr		$12345678
	movem.l	(a7)+,d0-d7/a0-a6			; restore registers
kbd_no_debug:

	bsr		IKBD_KeyHandler				; store keypress

kbd_LastKeyCheck:	
;	move.b	(a0),d0						; read ikbd control reg
;	btst	#0,d0						; more data to read?
;	bne		kbd_KeyLoop					; yes, so process it

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

	move.l	d0,kbd_TosBuffer+2
	move.l	d1,kbd_TosJump+2
	move.w	#$4E71,kbd_StoreKey

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_KeyHandler( KBD_REG *, PACKET * )
* ACTION   : processes key packet
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_KeyHandler:
	move.w	d1,-(a7)					; save registers

	lea		sIKBD_KbdBuffer(a3),a2		; buffer for IKBD
	move.w	sIKBD_KbdTail(a3),d1			; current tail position
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
* FUNCTION : void IKBD_AbsoluteMouseHandler( KBD_REG *, PACKET * )
* ACTION   : processes absolute mouse packet
* COMMENTS : absolute mouse packets contains absolute xy position & buttons
*              this function not finished - only stores mouse keys 
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_AbsoluteMouseHandler:			

	st.b	sIKBD_MouseMovedFlag(a3)	; indicate mouse moved

	move.b	(a1),d0						; get mouse key info
	and.w	#%11,d0						; isolate l+r buttons
	move.b	d0,sIKBD_MouseKeys(a3)		; save mouse key info

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_TimeOfDayHandler( KBD_REG *, PACKET * )
* ACTION   : processes time of day packet
* COMMENTS : does nothing, is there any point in processing these packets?
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_TimeOfDayHandler:

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_JoystickReportHandler( KBD_REG *, PACKET * )
* ACTION   : processes joystick report
* COMMENTS : joystick report contains both joystick packets
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_JoystickReportHandler:

	move.b	1(a1),sIKBD_Joy0Packet(a3)		; get joystick 0 packet
	move.b	2(a1),sIKBD_Joy1Packet(a3)		; get joystick 1 packet

	rts                             


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_Joystick0Handler( KBD_REG *, PACKET * )
* ACTION   : processes joystick 0 packet
* COMMENTS : saves joystick 0 packet
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_Joystick0Handler:

	move.b	1(a1),sIKBD_Joy0Packet(a3)		; save joystick 0 packet

	rts                             


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_Joystick1Handler( KBD_REG *, PACKET * )
* ACTION   : processes joystick 1 packet
* COMMENTS : saves joystick 1 packet
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*
 
IKBD_Joystick1Handler:

	move.b	1(a1),sIKBD_Joy1Packet(a3)		; save joystick 1 packet

	rts                             


*------------------------------------------------------------------------------------*
* FUNCTION : void IKBD_RelativeMouseHandler( KBD_REG *, PACKET * )
* ACTION   : processes relative mouse handler
* COMMENTS : reads mouse buttons and delta x, delta y
* CREATION : 13.04.99 PNK
*------------------------------------------------------------------------------------*

IKBD_RelativeMouseHandler:

	st.b	sIKBD_MouseMovedFlag(a3)	; indicate mouse moved

	move.b	(a1),d0						; get mouse key info
	and.w	#%11,d0						; isolate l+r buttons
	move.b	d0,sIKBD_MouseKeys(a3)		; save mouse key info

	move.b	1(a1),d0					; mouse x movement
	ext.w	d0							; extend to signed word
	add.w	d0,sIKBD_MouseX(a3)			; update mouse x position

	move.b	2(a1),d0					; mouse y movement
	ext.w	d0							; extend to signed word
	add.w	d0,sIKBD_MouseY(a3)			; update mouse y position

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

	ALIGN 2

kbdPacketSizes:
	dc.w	7	; $f6 - keyboard packet
	dc.w	5	; $f7 - absolute mouse packet
	dc.w	2	; $f8 - relative mouse position / no buttons
	dc.w	2	; $f9 - relative mouse / left button
	dc.w	2	; $fa - relative mouse / right button
	dc.w	2	; $fb - relative mouse / both buttons
	dc.w	6	; $fc - time of day
	dc.w	2	; $fd - joystick report
	dc.w	1	; $fe - joystick 0 event
	dc.w	1	; $ff - joystick 1 event

	dc.w	0,0,0,0,0,0

	ALIGN	4

kbdPacketHandlers:
	dc.l	IKBD_KeyHandler				;$f6
	dc.l	IKBD_AbsoluteMouseHandler	;$f7
	dc.l	IKBD_RelativeMouseHandler	;$f8
	dc.l	IKBD_RelativeMouseHandler	;$f9
	dc.l	IKBD_RelativeMouseHandler	;$fa
	dc.l	IKBD_RelativeMouseHandler	;$fb
	dc.l	IKBD_TimeOfDayHandler		;$fc
	dc.l	IKBD_JoystickReportHandler	;$fd
	dc.l	IKBD_Joystick0Handler		;$fe
	dc.l	IKBD_Joystick1Handler		;$ff


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
kbdIkbdHandler:		dc.l	IKBD_KbdPacketHandler

kbdKeyCounter:		dc.w	0
kbdPacketCounter:	dc.w	0
kbdPacketPtr:		dc.l	kbdPacketBuffer

kbdPacketBuffer:	ds.b	256

