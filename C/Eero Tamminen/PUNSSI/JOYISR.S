| PUNSSi (C) 1995, 1997 by Eero Tamminen
|
| *uck, I had to implement simple `serial comminications' with the 
| keyboard processor + interpret packets IKBD sends...
|
| This could probably be much more efficient, but I haven't got any
| opcode cycle table at hand... ;-)
|
|	- Eero

.globl	_KeyISR

| these are global (-> not PC-relative) for the sake of test.c
.globl	_Pleft
.globl	_Pheader

.data

| packet: header and how many bytes left
_Pheader:
	.byte 0		| set while there's incoming packet
_Pleft:
	.byte 0		| how many bytes of packet left

Plenght:		| packet lenghts minus header (1)
	.byte 7,5,2,2,2,2,6,2,1,1

.text

| IKBD interrupt handler
| ----------------------
| d1 has IKBD data byte
| a1 has input array address

_KeyISR:
	lea	_InputValue,a1		| input array address
	lea	0xFFFFFC00,a0		| IKBD ACIA control register
	moveb	a0@,d0			| ACIA status
	btst	#7,d0			| interrupt bit set?
	beq	done			| no...
	btst	#0,d0			| data buffer register full?
	bne	read			| yes, read...
	| no checks for shift register overrun or such...
done:
	rts

read:
	moveql	#0,d1			| ensure `clean' long
	moveql	#0,d0
	moveb	a0@(2),d1		| data
	moveb	_Pheader,d0
	beq	new			| no header, a new packet...

	cmpl	#0xFF,d0		| joystick 1 header?
	bne	joy0			| no...
	addl	#4,a1			| array index 1
	jmp	update	

joy0:
	cmpl	#0xFE,d0		| joystick 0 header?
	beq	update			| yes
	jmp decrease

update:
	movel	d1,a1@			| update input array
decrease:
	subqb	#1,_Pleft		| decrease packet lenght
	bne	exit
	clrb	_Pheader		| whole packet received
exit:
	rts

new:
	cmpl	#0xF6,d1		| first read is header byte
	blt	keys			| a key...
	moveb	d1,_Pheader		| new packet id
	subb	#0xF6,d1		| packet lenght index
	lea	pc@(Plenght),a0		| lenght array
	moveb	a0@(d1),_Pleft		| packet lenght
	rts

keys:
	movel	d1,d0
	andl	#0x7f,d0		| scancode without press/release bit
	cmpl	#0x3B,d0
	blt	mapping			| player 0 keys
	addl	#4,a1			| player 1 keys (fn, curs, kpad)

mapping:
	lea	_InputMapping,a0
	moveb	a0@(d0),d0		| scancode -> joystick flag mapping
	btst	#7,d1			| key released?
	beq	press			| no, pressed...
	notl	d0			| invert to mask
	andl	d0,a1@			| mask joy flag off
	rts

press:
	orl	d0,a1@			| set appropiate joy flag in variable
	rts


| ----- old version ---------
|	.text
|	.globl	_JoyISR
|
|	movel	#_InputValue,a1
|	moveq	#0,d0
|	movel	sp@(4),a0	| Get joystick packet.
|	moveb	a0@(1),d0
|	cmpb	#0xFF,a0@
|	bne	Joy0
|	moveb	a0@(2),d0
|	addl	#4,a1
|Joy0:
|	movel	d0,a1@
|	rts
