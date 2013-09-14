;+
;	Park heads on ACSI devices 0..7
;
;  11-Sep-1987 lmd	Put in delay so that the bus
;			doesn't lock up on the "hidden" completion byte
;			that John's kludge board swallows.
;
;  11-Sep-1987 lmd	Added C interface, ship().
;
;-
	.include atari

	Super				; get into supervisor mode
	bsr	park_devices		; park everything
	User				; back to user mode
	Pterm0				; and terminate


;+
;  Synopsis:	ship(dev)
;		short int dev;
;
;    Ship the specified device, after a short delay.
;
;    Returns:	0 : successful ship
;		-1: ship failed (timeout, etc.)
;
;    Uses:	D0-D2/A0-A2
;
;-
_ship::
	link	a6,#0			; (get ptr to stack frame)
	movem.l	d3-d7/a3-a5,-(sp)	; save registers
	Super				; get into supervisor mode
;
;  delay a while
;
	moveq	#40,d1			; wait 200 milliseconds
.2:	add.l	_hz_200,d1		;
	cmp.l	_hz_200,d1		;
	bge.s	.2			;
;
;  "ship" the device
;
	move.w	8(a6),d7		; D7 = dev << 5
	lsl.w	#5,d7			;
	bsr	park_dev		; park device D7
	sne	d0			; D0 = 0 or -1
	ext.w	d0			;	depending on return code

	User				; back to user mode
	movem.l	(sp)+,d3-d7/a3-a5	; restore registers
	unlk	a6			; restore frame ptr
	rts				; ... and return


;+
;  Park ACSI devices 0..7
;
;-
park_devices:
	moveq	#0,d7			; start with dev #0
.1:	bsr	park_dev		; park device

	moveq	#40,d1			; wait 200 milliseconds
.2:	add.l	_hz_200,d1		;
	cmp.l	_hz_200,d1		;
	bge.s	.2			;

	add.b	#$20,d7			; next devno
	bne	.1			; (do all eight devs)
	rts


;+
;  park_dev  --  Park device
;    Passed:	d7.b = ddd00000
;		('ddd' is the ACSI device number, 0..7)
;
;    Returns:	NE: park failed;
;		EQ: successful park.
;
;    Preserves:	d7.w
;
;    Uses:	everything else
;
;
;-
park_dev:
	lea	fifo,a4			; a4 -> DMA control register
	lea	diskctl,a5		; a5 -> DMA data register
	st	flock			; lock up DMA against vblank

	move.w	#$088,(a4)		; select dma bus (not SCR)

	move.b	d7,d0			; setup d0.L with devno+command
	or.b	#%00011011,d0		; d0.b = devno<<5 .OR. "PARK" command
	swap	d0			;
	move.w	#$088,d0		;
	bsr	wcbyte			; d0.L = DDD11011xxxxxxx010001010
	bne	.ret			; (punt on timeout)

	moveq	#3,d6			; (count = 4)
.loop:	move.l	#$0000008a,d0		;
	bsr	wcbyte			; write it
	bne	.ret			; (punt on timeout)
	dbra	d6,.loop		; (loop for more bytes)

	move.l	#$0000000a,(a5)		; write byte 5 (controlByte = $00)
	move.w	#120,d1			; timeout = 2.0 sec
	bsr	wwait			; wait for completion
	bne	.ret			; (punt on timeout)

	move.w	#$08a,(a4)		; select status reg
	move.w	(a5),d0			; get return code from DMA device

	moveq	#2,d1			; /* ~ 5 millisecond delay */
	add.l	_hz_200,d1		; /* for slow acsi devices */
.1:	cmp.l	_hz_200,d1		;
	bge.s	.1			;

;--- reset DMA, return NE
.ret:	move.w	#$080,(a4)		; cleanup DMA chip for floppy driver
	sf	flock			; unlock DMA chip
	rts				; return


;+
;  wcbyte - write ACSI command byte, wait for IRQ
;    Passed:	D0.L = command byte and FIFO control
;			bits 16..23 = command byte,
;			bits 0..7 = FIFO control bits
;		a5 -> $ffff8604
;
;    Returns:	NE on failure (timeout)
;		EQ on successful ACK
;
;    Uses:	d1
;
;-
wcbyte:	move.l	d0,(a5)			; write WDC, WDL [due to jwt]

	moveq	#2,d1			; /* ~ 5 millisecond delay */
	add.l	_hz_200,d1		; /* for slow acsi devices */
.1:	cmp.l	_hz_200,d1		;
	bge.s	.1			;

	moveq	#40,d1			; wait 200 milliseconds
wwait:	add.l	_hz_200,d1		; d1 = time to quit at...
.1:	btst.b	#5,gpip			; disk done?
	beq.w	.ret			; (yes, return)
	cmp.l	_hz_200,d1		; timeout?
	bge.s	.1			; (not yet -- wait some more...)
	moveq	#-1,d1			; ensure NE (timeout error) return
.ret:	rts

