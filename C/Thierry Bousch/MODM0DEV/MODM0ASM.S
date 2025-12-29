|
| modm0asm.s:
|
| Interrupt routines and low-level functions for the serial driver,
| by T.Bousch
|
| See the file "COPYING" for distribution conditions.
|

yamaha	  = 0xFFFF8800
mfp_gpip  = 0xFFFFFA01
mfp_isra  = mfp_gpip + 14
mfp_isrb  = mfp_gpip + 16
mfp_rsr	  = mfp_gpip + 42
mfp_tsr	  = mfp_gpip + 44
mfp_udr	  = mfp_gpip + 46

.globl _dtr_off, _dtr_on
.globl _rts_off, _rts_on
.globl _old_evt_timer, _carrier_monitor
.globl _txrint, _rcvint, _txerror, _rxerror
.globl _old_txrint, _old_rcvint, _old_txerror, _old_rxerror
.globl _clear_errors, _check_errors
.globl _dont_emit
.globl _setstack

_dont_emit:	.word	0
rts_state:	.word	0
rx_oflow:	.word	0
rx_errs:	.byte	0
tx_errs:	.byte	0

|
| Drop DTR line (hangup); same as Ongibit(4)
|

_dtr_off:
	movew	sr, d1
	oriw	#0x700, sr
	movel	#yamaha, a0	| soundchip register
	moveb	#14, a0@	| no 14: port A
	moveb	a0@, d0
	bset	#4, d0		| set bit 4
	moveb	d0, a0@(2)
	movew	d1, sr
	rts

|
| Assert DTR line; same as Offgibit(4)
|

_dtr_on:
	movew	sr, d1
	oriw	#0x700, sr
	movel	#yamaha, a0
	moveb	#14, a0@	| select port A
	moveb	a0@, d0
	bclr	#4, d0		| clear bit 4
	moveb	d0, a0@(2)
	movew	d1, sr
	rts

|
| Drop RTS line; same as Ongibit(3)
|

_rts_off:
	movew	sr, d1
	oriw	#0x700, sr
	movel	#yamaha, a0
	moveb	#14, a0@	| select port A
	moveb	a0@, d0
	bset	#3, d0		| set bit 3
	moveb	d0, a0@(2)
	movew	#0, rts_state
	movew	d1, sr
	rts
	
|
| Assert RTS line; same as Offgibit(3)
|

_rts_on:
	movew	sr, d1
	oriw	#0x700, sr
	movel	#yamaha, a0
	moveb	#14, a0@	| select port A
	moveb	a0@, d0
	bclr	#3, d0		| clear bit 3
	moveb	d0, a0@(2)
	movew	#1, rts_state
	movew	d1, sr
	rts

|
| The following routine is called periodically to set the hard_carrier
| variable, and to wake processes selecting on a serial device when
| the carrier is dropped. It also checks if there are pending data in
| the transmission buffer, and if the reception buffer is below the
| low water mark (so that it can assert RTS again).
|
| It hooks to the event_timer vector.
|

	.long	0x58425241	| "XBRA"
	.long	0x63756130	| "cua0"
_old_evt_timer:
	.long	0xDEADFACE	| old vector

_carrier_monitor:
	moveml	d0-d1/a0-a1, sp@-
	movew	sr, sp@-
	oriw	#0x700, sr

|
| Get the current carrier status in _hard_carrier
|

	moveb	mfp_gpip, d0		| MFP i/o register
	andw	#2, d0			| keep bit 1
	eorw	#2, d0			| invert it
	lsrw	#1, d0			| and shift
	movew	d0, _hard_carrier

	tstl	_tx_buf_used		| any characters to transmit?
	beq	L10
	tstw	_dont_emit		| transmission blocked?
	bne	L10
	btst	#7, mfp_tsr		| is the MFP free?
	beq	L10
	bsr	transmit_byte		| ok, then transmit a byte
L10:

|
| RTS stuff: we allow reception if our rx_buffer is <= 1/4 full, and
| forbid it if >= 3/4 full
|

	tstw	_rts_cts		| shall we handle RTS ?
	beq	L11

	movel	_rx_buf_used, a0	| how many bytes in the rx buffer?
	tstw	rts_state		| is RTS currently on or off?
	bne	Lrts1
Lrts0:
	cmpl	_rx_lowmark, a0		| rx_buf_used <= rx_lowmark ?
	bgt	L11
	bsr	_rts_on			| raise RTS to allow reception
	bra	L11
Lrts1:
	cmpl	_rx_highmark, a0	| rx_buf_used >= rx_highmark ?
	blt	L11
	bsr	_rts_off		| drop RTS to stop reception
L11:
	movel	_rx_buf_used, a0	| how many bytes in the rx buffer?
	movel	_rx_buf_end, d0
	subl	#_rx_buf_start, d0	| buffer length
	cmpl	d0, a0			| rx_buf_used <= RX_BUF_LENGTH ?
	ble	L12
	movew	#1, rx_oflow		| set the overflow flag
L12:

|
| And finally jump to old vector
|

	movew	sp@+, sr
	moveml	sp@+, d0-d1/a0-a1
	movel	_old_evt_timer, sp@-
	rts

|
| Sends a byte to the MFP; make sure that all interrupts are disabled!!!
|

transmit_byte:
	movel	_tx_buf_tail, a0
	moveb	a0@+, mfp_udr
	cmpl	_tx_buf_end, a0
	bne	L_nowrap
	movel	#_tx_buf_start, a0	| don't forget the #
L_nowrap:
	movel	a0, _tx_buf_tail
	subql	#1, _tx_buf_used
	rts

|
| Gets a byte from the MFP, all interrupts disabled
|

receive_byte:
	movel	_rx_buf_head, a0
	moveb	mfp_udr, a0@+
	cmpl	_rx_buf_end, a0
	bne	L_nowrapr
	movel	#_rx_buf_start, a0	| don't forget the #
L_nowrapr:
	movel	a0, _rx_buf_head
	addql	#1, _rx_buf_used
	rts
	
|
| "Transmitter buffer empty" interrupt routine
|

	.long	0x58425241	| "XBRA"
	.long	0x63756130	| "cua0"
_old_txrint:
	.long	0xDEADFACE	| old vector

_txrint:
	moveml	d0-d1/a0-a1, sp@-
	oriw	#0x700, sr

	tstl	_tx_buf_used	| Any pending characters?
	beq	L2
	tstw	_dont_emit	| transmission blocked?
	bne	L2
	tstw	_rts_cts	| rts/cts mode?
	beq	Lw2
	btst	#2, mfp_gpip	| Clear to send?
	bne	L2
Lw2:
	btst	#7, mfp_tsr	| MFP ready for a new char?
	beq	L2
	bsr	transmit_byte
L2:
	moveml	sp@+, d0-d1/a0-a1
	bclr	#2, mfp_isra
	rte
	
|
| Receiver interrupt routine
|

	.long	0x58425241	| "XBRA"
	.long	0x63756130	| "cua0"
_old_rcvint:
	.long	0xDEADFACE	| old vector

_rcvint:
	moveml	d0-d1/a0-a1, sp@-
	oriw	#0x700, sr

	moveb	mfp_rsr, d0
	andb	#0x78, d0	| keep bits 3, 4, 5, and 6
	orb	d0, rx_errs
	bsr	receive_byte
	
	moveml	sp@+, d0-d1/a0-a1
	bclr	#4, mfp_isra
	rte

|
| Transmission error routine; the only interesting bit of the TSR is:
|
| bit 6: underrun error
|

	.long	0x58425241	| "XBRA"
	.long	0x63756130	| "cua0"
_old_txerror:
	.long	0xDEADFACE	| old vector

_txerror:
	movel	d0, sp@-
	oriw	#0x700, sr

	moveb	mfp_tsr, d0
	andb	#0x40, d0	| keep bit 6
	orb	d0, tx_errs

	movel	sp@+, d0
	bclr	#1, mfp_isra
	rte

|
| Reception error routine; the interesting bits of the RSR are:
|
| bit 3: break detected
| bit 4: frame error
| bit 5: parity error
| bit 6: overrun error
|

	.long	0x58425241	| "XBRA"
	.long	0x63756130	| "cua0"
_old_rxerror:
	.long	0xDEADFACE	| old vector

_rxerror:
	moveml	d0-d1/a0-a1, sp@-
	oriw	#0x700, sr

	moveb	mfp_rsr, d0
	andb	#0x78, d0	| keep bits 3, 4, 5, and 6
	orb	d0, rx_errs
	bsr	receive_byte	| read data (clears RSR)
	
	moveml	sp@+, d0-d1/a0-a1
	bclr	#3, mfp_isra
	rte

|
| User routine, calls the appropriate handlers
|

_check_errors:
	movel	d2, sp@-
	moveb	tx_errs, d2	| any tx errors?
	btst	#6, d2
	beq	L40
	jsr	_Underrun_Error
L40:
	moveb	rx_errs, d2	| any rx errors?
	beq	L44		| no, skip all that
	btst	#6, d2
	beq	L41
	jsr	_Overrun_Error
L41:
	btst	#5, d2
	beq	L42
	jsr	_Parity_Error
L42:
	btst	#4, d2
	beq	L43
	jsr	_Frame_Error
L43:
	btst	#3, d2
	beq	L44
	jsr	_Break_Detected
L44:
	tstw	rx_oflow
	beq	L45
	jsr	_Buffer_Overflow
L45:
	movel	sp@+, d2	| fall through

_clear_errors:
	clrw	rx_oflow
	clrb	rx_errs
	clrb	tx_errs
	rts

|
| Set stack pointer (once again from S.Henson's Minixfs)
|

_setstack:
	movel	sp@+, a0	| return address in a0
	movel	sp@, sp		| new stack pointer
	subql	#4, sp		| because the caller will add 4 again
	jmp	a0@		| and return
