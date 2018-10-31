; The IKBD interrupt handler in Motorola/Jas syntax
;
; PUNSSi (C) 1995, 1997 by Eero Tamminen

.globl	_KeyISR

; these are global (non PC-relative) are for the sake of test.c
.globl	_Pheader
.globl	_Pleft

.data

; packet: header and how many bytes left
_Pheader:
	.byte 0		; set while there's incoming packet
_Pleft:
	.byte 0		; how many bytes of packet left

Plenght:		; packet lenghts minus header (1)
	.byte 7,5,2,2,2,2,6,2,1,1

.text

; IKBD interrupt handler
; ----------------------
; d1 has IKBD data byte
; a1 has input array address

_KeyISR:
	lea	_InputValue,a1		; input array address
	lea	0xFFFFFC00,a0		; IKBD ACIA control register
	move.b	(a0),d0			; ACIA status
	btst	#7,d0			; interrupt bit set?
	beq	done			; no...
	btst	#0,d0			; data buffer register full?
	bne	read			; yes, read...
	; no checks for shift register overrun or such...
done:
	rts

read:
	moveq.l	#0,d1			; ensure `clean' long
	moveq.l	#0,d0
	move.b	2(a0),d1		; data
	move.b	_Pheader,d0
	beq	new			; no header, a new packet...

	cmp.l	#0xFF,d0		; joystick 1 header?
	bne	joy0			; no...
	add.l	#4,a1			; array index 1
	jmp	update	

joy0:
	cmp.l	#0xFE,d0		; joystick 0 header?
	beq	update			; yes
	jmp decrease

update:
	move.l	d1,(a1)			; update input array
decrease:
	subq.b	#1,_Pleft		; decrease packet lenght
	bne	exit
	clr.b	_Pheader		; whole packet received
exit:
	rts

new:
	cmp.l	#0xF6,d1		; first read is header byte
	blt	keys			; a key...
	move.b	d1,_Pheader		; new packet id
	sub.b	#0xF6,d1		; packet lenght index
	lea	Plenght(pc),a0		; lenght array
	move.b	d1(a0),_Pleft		; packet lenght
	rts

keys:
	move.l	d1,d0
	and.l	#0x7f,d0		; scancode without press/release bit
	cmp.l	#0x3B,d0
	blt	mapping			; player 0 keys
	add.l	#4,a1			; player 1 keys (fn, curs, kpad)

mapping:
	lea	_InputMapping,a0
	move.b	d0(a0),d0		; scancode -> joystick flag mapping
	btst	#7,d1			; key released?
	beq	press			; no, pressed...
	not.l	d0			; invert to mask
	and.l	d0,(a1)			; mask joy flag off
	rts

press:
	or.l	d0,(a1)			; set appropiate joy flag in variable
	rts


; ----- old code ----------
;	.text
;	.globl	_JoyISR
;
;_JoyISR:
;	move.l	#_InputValue,a1	; joystick 0 variable address
;	moveq.l	#0,d0
;	move.l	4(sp),a0	; packet address
;	move.b	1(a0),d0	; packet value
;	cmp.b	#0xFF,(a0)	; for joystick 1?
;	bne.s	Joy0		; no, joystick 0...
;	move.b	2(a0),d0
;	addq.l	#4,a1		; joystick 1 variable address
;Joy0:
;	move.l	d0,(a1)
;	rts
