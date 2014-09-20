
;IKBD routines to store joysticks (including extended joysticks), mouse and keypresses
;NOTE - if send commands $80,1,$12,$1A (reset,disable mouse+joystick) the ST will enable both relative
;mouse and joystick packets. When in this mode joystick 1 fire is found at relative mouse button bit 0
;NOTE - the keyboard handler uses MOVE.W #$2500,sr to allow higher priority MFP interrupts
;to run (ie Timer B and D) to prevent any Timer B palette effect glitches

ENABLEEXTJOY = 1							;Set to 1 to enable extended joysticks
ENABLEMOUSE = 0								;Set to 1 to enable mouse

MOUSEBUTTON0 = $1							;Mask for relative mouse buttons
MOUSEBUTTON1 = $2
JOYSTICK0UP = $01							;Mask for joysticks
JOYSTICK0DOWN = $02
JOYSTICK0LEFT = $04
JOYSTICK0RIGHT = $08
JOYSTICK0FIRE = $80
JOYSTICK1UP = $0100
JOYSTICK1DOWN = $0200
JOYSTICK1LEFT = $0400
JOYSTICK1RIGHT = $0800
JOYSTICK1FIRE = $8000

	SECTION	TEXT

;----------------------------------
;Initialise IKBD with new MFP interrupt handler and send starting commands
ikbdinit
	moveq.l	#0,d0
	lea		newkeys,a0						;Clear 128 bits of key states
	lea		keys,a1
	lea		debouncekeys,a2
	moveq.w	#4-1,d1
.loop	
	move.l	d0,(a0)+
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	dbra.w	d1,.loop

	move.b	d0,newmouserelbut				;Clear mouse
	move.b	d0,newmouserelx
	move.b	d0,newmouserely
	move.w	#320/2,mousex
	move.w	#200/2,mousey
	move.b	d0,mousebut
	move.b	d0,debouncemousebut
	move.w	d0,newjoys						;Clear joysticks
	move.w	d0,statejoys
	move.w	d0,debouncejoys
	move.w	d0,stateextjoys
	move.w	d0,debounceextjoys
	move.l	d0,packethandler				;Clear packet handler routine address

	move.w	#$2700,sr						;Disable interrupts
	bclr.b	#6,$fffffa0d.w					;Clear bit 6 (IKBD) in Interrupt Pending B
	move.l	#intikbd,$118.w					;Set new IKBD vector
	move.w	#$2300,sr						;Enable interrupts
	lea		ikbdstartcmds,a0
	bra		ikbdsendcmds					;Set IKBD for our game (does RTS)

;----------------------------------
;Clean up IKBD
ikbdcleanup
	lea		ikbdendcmds,a0
	bra		ikbdsendcmds					;Reset IKBD (does RTS)

;----------------------------------
;Debounce all keys, joysticks and mouse buttons
ikbdupdate
	lea		newkeys,a0						;Read keys modifed by interrupt
	lea		keys,a1							;Copy states to be read by game
	lea		debouncekeys,a2					;And make debounced states

	moveq.w	#4-1,d2							;128 bits
.loop
	move.l	(a0)+,d0						;Keys
	move.l	(a1),d1							;Old Keys
	move.l	d0,(a1)+						;Copy Keys to Old Keys
	eor.l	d0,d1
	and.l	d0,d1							;Debounce Keys = Keys&(Old Keys^Keys)
	move.l	d1,(a2)+						;Store debounced Keys
	dbra.w	d2,.loop
	
	move.w	newjoys,d0						;Joysticks
	move.w	statejoys,d1					;Old Joysticks
	move.w	d0,statejoys					;Copy Joysticks to Old Joysticks
	eor.w	d0,d1
	and.w	d0,d1							;Debounce
	move.w	d1,debouncejoys					;Store debounced Joysticks

	bsr		ikbdreadextjoysticks			;Read Extended Joysticks into d0.w (0 if not supported)
	move.w	stateextjoys,d1					;Old Extended Joysticks
	move.w	d0,stateextjoys					;Copy Extended Joysticks to Old Extended Joysticks
	eor.w	d0,d1
	and.w	d0,d1							;Debounce
	move.w	d1,debounceextjoys				;Store debounced Extended Joysticks

	IFGT ENABLEMOUSE
	move.w	mousex,d0						;Get mouse position
	move.b	newmouserelx,d1
	move.b	#0,newmouserelx					;Reset relative change
	ext.w	d1								;Sign-extend relative change
	add.w	d1,d0							;Add to position
	bge.s	.leftok
	moveq.w	#0,d0							;Clamp 0...320 on X
	bra.s	.rightok
.leftok	
	cmp.w	#320-1,d0
	ble.s	.rightok
	move.w	#320-1,d0
.rightok
	move.w	d0,mousex

	move.w	mousey,d0
	move.b	newmouserely,d1
	move.b	#0,newmouserely
	ext.w	d1
	add.w	d1,d0
	bge.s	.topok
	moveq.w	#0,d0							;Clamp 0...200 on Y
	bra.s	.bottomok
.topok
	cmp.w	#200-1,d0
	ble.s	.bottomok
	move.w	#200-1,d0
.bottomok
	move.w	d0,mousey

	move.b	newmouserelbut,d0				;Mouse Buttons
	move.b	mousebut,d1						;Old Buttons
	move.b	d0,mousebut						;Copy Buttons to Old Buttons
	eor.b	d0,d1
	and.b	d0,d1							;Debounce
	move.b	d1,debouncemousebut				;Store debounced Buttons
	ENDC
	rts

;----------------------------------
;Return Z flag to show if key is pressed or not, pass d0.b as key scancode
ikbdtestkey
	lea		keys,a0							;Access key states (so not modified by interrupt)
ikbdbtstkey
	and.w	#$7f,d0							;Mask key scancode
	move.w	d0,d1							;Get bit 0...7
	and.w	#$7,d1
	lsr.w	#3,d0							;Get byte offset
	btst.b	d1,(a0,d0.w)					;Set Z state from key (0-released, 1-pressed)
	rts

;----------------------------------
;Return Z flag to show if debounced key is pressed or not, pass d0.b as key scancode
ikbdtestdebouncekey
	lea		debouncekeys,a0
	bra		ikbdbtstkey

;----------------------------------
;Read STe/Falcon extended joysticks and return in d0.w (returns 0 if on ST/TT)
;NOTE - on the SainT emulator it incorrectly triggers a bus error when
;addressing $ff9200/$ff9202 if we run as an STe
ikbdreadextjoysticks
	moveq.w	#0,d0							;Clear return value
	IFGT ENABLEEXTJOY
	move.w	machine,d1
	btst	#0,d1							;Test bottom bit of machine which is set for STe/Falcon
	beq.s	.noextjoysticks

	move.w	#$fffe,$ffff9202.w				;Set mask to read joystick 0 fire button 0 in bit 1
	move.w	$ffff9200.w,d1
	btst	#1,d1							;Extended joystick bits are clear if pressed
	bne.s	.nofire0
	or.w	#JOYSTICK0FIRE,d0				;Copy fire button to return value
.nofire0

	move.w	#$ffef,$ffff9202.w				;Set mask to read joystick 1 fire button 0 in bit 3
	move.w	$ffff9200.w,d1
	btst	#3,d1
	bne.s	.nofire1
	or.w	#JOYSTICK1FIRE,d0
.nofire1

	move.w	#$fffe,$ffff9202.w				;Set mask to read joystick 0 directions in bits 8...11
	move.w	$ffff9202.w,d1
	not.w	d1
	lsr.w	#8,d1
	and.w	#$000f,d1						;Shift bit to match JOYSTICKxxx defines
	or.w	d1,d0							;Copy directions

	move.w	#$ffef,$ffff9202.w				;Set mask to read joystick 1 directions in bits 12...15
	move.w	$ffff9202.w,d1
	not.w	d1
	lsr.w	#4,d1
	and.w	#$0f00,d1
	or.w	d1,d0
.noextjoysticks	
	ENDC
	rts

;----------------------------------
;Send byte commands to keyboard, pass a0.l as byte count to send followed by byte commands
ikbdsendcmds
	bsr		ikbdreadysend					;Wait until able to send bytes to keyboard
	moveq.w	#0,d0
	move.b	(a0)+,d0						;Send bytes to send
	subq.w	#1,d0							;-1 for dbra
.loop
	move.b	(a0)+,$fffffc02.w				;Write byte to ACIA Data
	bsr		ikbdreadysend					;Wait until sent
	dbra.w	d0,.loop
	rts
	
;----------------------------------
;Wait until ready to send next byte to keyboard
ikbdreadysend
	move.b	$fffffc00.w,d1					;Read ACIA Status
	btst	#1,d1							;Test bit 1 Tx Data Register Empty
	beq.s	ikbdreadysend					;Byte waiting, check again
	rts

;----------------------------------
;IKBD interrupt handler
intikbd
	move.w	#$2500,sr						;Allow higher priority MFP Timer B/Timer D interrupt this routine
	movem.l	a0/d0-d1,-(sp)
	moveq.l	#0,d0
	move.b	$fffffc00.w,d0					;Read ACIA Status
	btst	#7,d0							;Test bit 7 Interrupt Request
	beq.s	.ignore
	btst	#0,d0							;Test bit 0 Rx Data Register Full
	beq.s	.skipbyte
.anotherbyte	
	btst	#4,d0							;Test bit 4 Framing Error
	bne.s	.skipbyte
	btst	#5,d0							;Test bit 5 Rx Overrun
	bne.s	.skipbyte
	btst	#6,d0							;Test bit 6 Parity Error
	bne.s	.skipbyte
	move.b	$fffffc02.w,d0					;Read ACIA Data
	move.l	packethandler,a0				;In middle of a packet?
	cmp.l	#0,a0
	bne.s	.continuepacket					;Continue to read packet
	cmp.w	#$f6,d0							;Check for start of packet
	bge.s	.startpacket					;$f6...$ff is a packet, otherwise key
	lea		newkeys,a0						;Store key state in table
	move.w	d0,d1							;Get bit 0...7 of scancode
	and.w	#$7,d1
	asr.b	#3,d0							;Get byte offset 0...15 and keep top bit of byte
	bmi.s	.keyreleased					;N is bit 7 (0-pressed, 1-released)
	and.w	#$f,d0							;Mask offset
	bset.b	d1,(a0,d0.w)					;Set key as pressed
	bra		.done
.keyreleased
	and.w	#$f,d0							;Mask offset
	bclr.b	d1,(a0,d0.w)					;Set key as released	
.done
	moveq.l	#0,d0
	move.b	$fffffc00.w,d0					;Read ACIA Status
	btst	#0,d0							;Test bit 0 again to see if we have another byte
	bne.s	.anotherbyte	
	bclr.b	#6,$fffffa11.w					;Clear bit 6 (IKBD) in Interrupt In-Service B
.ignore
	movem.l	(sp)+,a0/d0-d1
	rte
.skipbyte
	move.b	$fffffc02.w,d0					;Read ACIA Data to skip byte
	bra		.done

.continuepacket
	jmp		(a0)							;Run routine to store next byte in packet

.startpacket
	cmp.b	#$ff,d0							;$ff is Joystick 0 (mouse port) header
	bne.s	.notff
	move.l	#.ikbdpacketff,packethandler
	bra		.done
.notff
	cmp.b	#$fe,d0							;$fe is Joystick 1 header
	bne.s	.notfe
	move.l	#.ikbdpacketfe,packethandler
	bra		.done
.notfe
	move.b	d0,d1
	and.b	#$f8,d1							;$f8...$fb is Relative Mouse Position header
	cmp.b	#$f8,d1
	bne.s	.notf8
	and.b	#$3,d0							;Mask mouse buttons
	move.b	d0,newmouserelbut				;Store mouse button state 
	move.l	#.ikbdpacketf8,packethandler
	bra		.done
.notf8	
	bra		errorikbdpacket					;Unsupported keyboard packet (ie $f6, $f7 and $fc)

;Packet handlers
.ikbdpacketff								;$ff
	move.b	d0,newjoys						;Store joystick 0 (mouse port) state
	move.l	#0,packethandler				;End of packet
	bra		.done

.ikbdpacketfe								;$fe
	move.b	d0,newjoys+1					;Store joystick 1 state
	move.l	#0,packethandler				;End of packet
	bra		.done

.ikbdpacketf8								;$f8...$fb
	move.b	d0,newmouserelx					;Store relative mouse X
	move.l	#.ikbdpacketf8byte2,packethandler
	bra		.done
.ikbdpacketf8byte2
	move.b	d0,newmouserely					;Store relative mouse Y
	move.l	#0,packethandler				;End of packet
	bra		.done

;----------------------------------

	SECTION	DATA

ikbdstartcmds
	IFGT ENABLEMOUSE
	;The following enables both auto relative mouse+auto joystick reporting
	dc.b	4								;Number of bytes to send
	dc.b	$80,1							;Reset IKBD
	dc.b	$12								;Disable mouse
	dc.b	$1A								;Disable joysticks	
	ENDC
	dc.b	3								;Number of bytes to send
	dc.b	$80,1							;Reset IKBD
	dc.b	$14								;Start auto joystick reporting
ikbdendcmds
	dc.b	2								;Number of bytes to send
	dc.b	$80,1							;Reset IKBD
	EVEN

;----------------------------------

	SECTION	BSS

packethandler			ds.l	1			;Address of routine to handle packet (or 0 if none)
newkeys					ds.l	4			;128 bit state of keys modified by interrupt (0-released, 1-pressed)
newjoys					ds.w	1			;State of Joystick 0 (mouse port) and Joystick 1
newmouserelbut			ds.b	1			;State of relative mouse buttons, X and Y
newmouserelx			ds.b	1
newmouserely			ds.b	1
	EVEN
keys					ds.l	4			;Key states for this frame
debouncekeys			ds.l	4			;Debounce version of above
statejoys				ds.w	1			;State of Joystick 0 and 1 for this frame
debouncejoys			ds.w	1			;Debounce version of above
stateextjoys			ds.w	1			;State of Extended Joystick 0 and 1 for this frame
debounceextjoys			ds.w	1			;Debounce version of above
mousex					ds.w	1			;Mouse X
mousey					ds.w	1			;Mouse Y
mousebut				ds.b	1			;Mouse buttons
debouncemousebut		ds.b	1			;Debounce version of above
