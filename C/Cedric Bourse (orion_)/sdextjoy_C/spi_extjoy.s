;
; SPI routines for an SD card plugged
; in the Atari STe/Falcon extended Joystick Port A
;
; by Orion_ 04/2020
;
; Extended Joystick Port: Computer Side
;    _______________________________
;    \   5   4    3    2    1      /
;     \     10   9    8    7   6  /
;      \ 15  14   13  12   11    /
;       \_______________________/
;
; 4 - MOSI
; 3 - SCK
; 2 - CS
; 6 - MISO
; 7 - VCC
; 9 - GND

JOY_ADRS_OUTPUT		equ	$FF9202
JOY_SPI_CS_HIGH		equ	%1111111111111100
JOY_SPI_CS_LOW		equ	%1111111111111000
JOY_SPI_SCK_HIGH	equ	%0000000000000010
JOY_SPI_SCK_LOW		equ	%0000000000000000
JOY_SPI_DATA_1		equ	%0000000000000001
JOY_SPI_DATA_0		equ	%0000000000000000

JOY_ADRS_INPUT_b	equ	$FF9201
JOY_SPI_MISO_BIT	equ	0

	section	text

	public	_spi_cs_low
	public	_spi_cs_high
	public	_spi_initialise
	public	_spi_recv_byte
	public	_spi_fast_recv_nbytes
	public	_spi_send_byte

_spi_cs_low:
	move.w	#JOY_SPI_CS_LOW,d0
	move.w	d0,spi_status
	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_1,d0
	move.w	d0,JOY_ADRS_OUTPUT
	rts

_spi_initialise:
_spi_cs_high:
	move.w	#JOY_SPI_CS_HIGH,d0
	move.w	d0,spi_status
	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_1,d0
	move.w	d0,JOY_ADRS_OUTPUT
	rts

_spi_recv_byte:
	move.w	#$2700,sr	; no Interrupts during transfer
	moveq	#0,d0

	lea	JOY_ADRS_OUTPUT,a0
	lea	JOY_ADRS_INPUT_b,a1

	move.w	spi_status,d1
	move.w	d1,d2
	or.w	#JOY_SPI_SCK_HIGH|JOY_SPI_DATA_1,d1
	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_1,d2

	REPT	8
	move.w	d1,(a0)				; SCK HIGH
	btst.b	#JOY_SPI_MISO_BIT,(a1)		; Get MISO Bit 0
	sne.b	d0				; ph34r
	move.w	d2,(a0)				; SCK LOW
	add.w	d0,d0				; t3h 0pt1m!
	nop		; Slow down to 250khz
	ENDR
	lsr.w	#8,d0				; Final byte in LSB :)

	move.w	#$2300,sr	; restore Interrupts
	rts

_spi_fast_recv_nbytes:		; a0 = buffer, d0 = nbytes
	move.w	#$2700,sr	; no Interrupts during transfer
	move.l	d3,-(a7)

	lea	JOY_ADRS_OUTPUT,a1
	lea	JOY_ADRS_INPUT_b,a2

	move.w	spi_status,d1
	move.w	d1,d2
	or.w	#JOY_SPI_SCK_HIGH|JOY_SPI_DATA_1,d1
	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_1,d2

	subq.w	#1,d0
	bmi.s	.out
.nextbyte:
	moveq	#0,d3
	REPT	8
	move.w	d1,(a1)				; SCK HIGH
	btst.b	#JOY_SPI_MISO_BIT,(a2)		; Get MISO Bit 0
	sne.b	d3				; ph34r
	move.w	d2,(a1)				; SCK LOW
	add.w	d3,d3				; t3h 0pt1m!
	ENDR
	lsr.w	#8,d3				; Final byte in LSB :)
	move.b	d3,(a0)+
	dbra	d0,.nextbyte
.out:
	move.l	(a7)+,d3
	move.w	#$2300,sr	; restore Interrupts
	rts

_spi_send_byte:
	move.w	#$2700,sr	; no Interrupts during transfer

	move.w	d3,-(a7)
	move.w	d4,-(a7)

	lea	JOY_ADRS_OUTPUT,a0

	move.w	spi_status,d1
	move.w	d1,d2
	move.w	d1,d3
	move.w	d1,d4
;	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_0,d1
	or.w	#JOY_SPI_SCK_HIGH|JOY_SPI_DATA_0,d2
	or.w	#JOY_SPI_SCK_LOW|JOY_SPI_DATA_1,d3
	or.w	#JOY_SPI_SCK_HIGH|JOY_SPI_DATA_1,d4

	REPT	8
	add.b	d0,d0		; Test MSB (in carry flag)
	bcs.s	*+10
	move.w	d1,(a0)				; SCK LOW / 0
	nop		; Slow down to 250khz
	nop
	move.w	d2,(a0)				; SCK HIGH / 0
	bra.s	*+8
	move.w	d3,(a0)				; SCK LOW / 1
	nop		; Slow down to 250khz
	nop
	move.w	d4,(a0)				; SCK HIGH / 1
	ENDR

	move.w	(a7)+,d4
	move.w	d3,(a0)				; SCK LOW / 1
	move.w	(a7)+,d3

	move.w	#$2300,sr	; restore Interrupts
	rts

;****************************************>

	section	bss

spi_status:	ds.w	1
