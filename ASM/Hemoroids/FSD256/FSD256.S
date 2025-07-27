; +======================================================================+
; | 256B SYNC-LOCKED BACKGROUND, BY DYNO / HEMOROIDS                     |
; +======================================================================+

PALETTE		= $FFFF8240			; Video palette register 0
SCREEN_BASE	= $44E				; _v_bas_ad, logical screen base

MOVE_D0_A6	= $3C80				; move.w d0,(a6)
MOVE_D4_A6	= $3C84				; move.w d4,(a6)
MOVE_D6_A6	= $3C86				; move.w d6,(a6)
MOVE_A2		= $301A				; move.w (a2)+,d0
NOP_X2		= $8080				; or.l d0,d0
REVERT_A2	= $514A				; subq.w #8,a2
RTS		= $4E75				; rts

	OUTPUT	.TOS
	OPT	O+,D-,X-,P+

;#=================#
;# Initializations #
;#=================#

	; Supervisor-mode
	move.w	#32,-(sp)
	trap	#1

	; Disable interruptions
	move.w	#$2700,sr

	; Clear screen
	move.l	SCREEN_BASE.w,a0
	move.w	#8000-1,d0
clear:	clr.l	(a0)+
	dbra	d0,clear

;#=================#
;# Generate buffer #
;#=================#

	lea	sprite(pc),a5
	lea	loop(pc),a6

	moveq	#10-1,d0			; sprite height
lines:	move.w	(a5)+,d5

	moveq	#4*8-1,d1			; sprites pixels are displayed on 4 blocks of 8 lines
row4:
	move.l	#MOVE_D0_A6<<16+MOVE_A2,d7	; move.w d0,(a6) / move.w (a2)+,d0
	moveq	#8-1,d2
newpal:	move.l	d7,(a6)+
	add.l	#$00010200,d7			; move.w d[0..7],(a6) / move.w (a2)+,d[0..7]
	bclr	#18,d7				; move.w d[0..3],(a6)
	dbra	d2,newpal

	moveq	#16-4-1,d2			; sprite width (= 16)
col:
	move.l	#MOVE_D0_A6<<16+NOP_X2,d7	; move.w d0,(a6) / nop x2
	btst	#0,d2
	bne.s	.bgcol
	bset	#17,d7				; move.w d[0->2],(a6) / nop x2
.bgcol:
	rol.w	d5
	bcc.s	.bit0
	move.l	#MOVE_D4_A6<<16+MOVE_D6_A6,d7	; move.w d4,(a6) / move.w d6,(a6)
.bit0:
	move.l	d7,(a6)+			; 2 moves (front) / 1 move + nop (backg)
	add.l	#$00010001,d7
	move.l	d7,(a6)+			; 2 moves (front) / 1 move + nop (backg)
	dbra	d2,col

	rol.w	#4,d5				; pad to sprite width (= 16), see col: init

	move.b	d1,d2
	and.b	#%111,d2
	beq.s	.norev
	move.w	#REVERT_A2,-2(a6)		; subq.w #8,a2 [2]
	move.w	#REVERT_A2,-6(a6)		; subq.w #8,a2 [2]
.norev:
	dbra	d1,row4

	dbra	d0,lines

	lea	-8*128-12(a6),a6		; change direction + speed
	move.w	#RTS,(a6)

;#====================#
;# Initialize palette #
;#====================#
; REPT 64
; dc.w back1,back2,back3,back4,front1,front2,front3,front4

	move.w	#$C3A5,d3

	lea	palette(pc),a2

	moveq	#16*4-1,d0
palout:	moveq	#4-1,d1
palblk:
	move.w	#$7564,d7
	roxl.w	d0,d7
	roxr.w	#1,d3
	addx.w	d3,d7
	roxr.w	d1,d7
	and.w	#%0000011101110111,d7
	move.w	d7,8(a2)			; front palette value

	ror.w	#2,d7
	and.w	#%0000000100010001,d7
	move.w	d7,(a2)+			; back palette value

	dbra	d1,palblk
	addq.w	#8,a2
	dbra	d0,palout

;#==========#
;# Run demo #
;#==========#

	lea	PALETTE.w,a6

demo:	lea	palette(pc),a2
	bsr	loop
	bra.s	demo

;#============#
  SECTION DATA
;#============#

sprite:	dc.w 0
	dc.w %0010000010000000
	dc.w %0001000100000000
	dc.w %0011111110000000
	dc.w %0110111011000000
	dc.w %1111111111100000
	dc.w %1011111110100000
	dc.w %1010000010100000
	dc.w %0011101110000000
	; + 1 empty word in bss

;#===========#
  SECTION BSS
;#===========#

palette:	ds.l 16*4*4

loop:		ds.b 40000
