/
/ playit.s
/ Plays a sampled sound through DMA sound!
/

SOUND_CONTROL	=	0xFFFF8900	/Repeat, Enable
FRAME_BASE	=	0xFFFF8902	/Frame values are even boundary
FRAME_SIZE	=	0xFFFF8908	/bytes -- 12 bits total.
FRAME_END	=	0xFFFF890E
SOUND_MODE	=	0xFFFF8920	/Stereo, Mono, Sample Rate

REPEAT		=	2
ENABLE		=	1

MONO		=	0x80
_6Khz		=	0
_12Khz		=	1
_25Khz		=	2
_50Khz		=	3

/
/ AVR File format info.
/
AVR_MAGIC	=	0x32424954
AVR_STEREO	=	12
AVR_SPEED	=	22
AVR_LENGTH	=	26

		.shri
		
		.globl playit_,stop_sound_

/
/ playit(char *sample, int length, unsigned char rate, unsigned char repeat)
/
SAMPLE		=	8
LENGTH		=	12
RATE		=	14
REPEAT		=	16

playit_:
	link	a6, $0			/ Create local stack frame
/
	move.l	a0, -(a7)	
	move.l	d0, -(a7)	
	move.l	d1, -(a7)	
	move.l	d2, -(a7)	
	move.l	d3, -(a7)	
/
	clr.l	d1
/
	move.l	SAMPLE(a6), d0		/ d0 is the sample address
	move.w	LENGTH(a6), d1		/ d1 is the sample length
	move.w	RATE(a6), d2		/ d2 is the sample rate
	move.w	REPEAT(a6), d3		/ d3 is the repeat flag
/
	lea	SOUND_CONTROL, a0
	move.w	$0, (a0)
/
	movea.l	SAMPLE(a6), a0		/ see what kind of sample we have
	cmpi.l	$AVR_MAGIC,(a0)
	bne	not_avr
/
	add.l	$0x80, d0		/ start address is +128
	move.l	AVR_LENGTH(a0), d1	/ use the avr length
	move.l	AVR_SPEED(a0), d2	/ use the avr speed
	andi.l	$0x00FFFFFF, d2		/ hz
/
	cmp.l	$9000,d2		/ x<9000 uses 6000 sample rate
	bgt	higher1
/
	move.w	$_6Khz,d2
	bra	avr_mono
/
higher1:
	cmp.l	$18000,d2
	bgt	higher2
/
	move.w	$_12Khz,d2		/ 9000<x<18000 uses 12000 sample rate
	bra	avr_mono
/
higher2:
	cmp.l	$37500,d2
	bgt	higher3
/
	move.w	$_25Khz,d2		/ 18000<x<37500 uses 25000 sample rate
	bra	avr_mono
higher3:
	move.w	$_50Khz,d2		/ x>37500 uses 50000 sample rate
/
avr_mono:
	or.w	$0x80, d2
/
not_avr:
	lea	FRAME_BASE+4, a0	/ store the base
	move.l	d0,-(a7)
	move.w	d0, (a0)		/ store the low byte
	lsr.l	$8, d0			/ shift right to get mid byte
	move.w	d0, -(a0)
	lsr.l	$8, d0			/ store the high byte
	move.w	d0, -(a0)
	move.l	(a7)+,d0
/
	add.l	d1, d0			/ Find the end byte
	andi.l	$0xFFFFFFFE, d0
/
	lea	FRAME_END+4, a0		/ store the end adrs
	move.w	d0, (a0)		/ store the low byte
	lsr.l	$8, d0			/ shift right to get mid byte
	move.w	d0, -(a0)
	lsr.l	$8, d0			/ store the high byte
	move.w	d0, -(a0)
/
	lea	SOUND_MODE, a0
	move.w	d2, (a0)
	lea	SOUND_CONTROL, a0
	ori.w	$1, d3			/ set the enable bit
	move.w	d3, (a0)
/
	move.l	(a7)+, d3
	move.l	(a7)+, d2
	move.l	(a7)+, d1
	move.l	(a7)+, d0
	movea.l	(a7)+, a0
/
	unlk	a6			/ Scrap local stack frame
	rts

stop_sound_:
/
/ Simply turns off the DMA sound.
/
	clr.w	SOUND_CONTROL
	rts

		.shrd

		.even
