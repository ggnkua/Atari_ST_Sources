; Wobble
; 256 byte intro for Atari ST
; Released at Outline Online 2020
; code: Solomon of Gash 
;                  ( / Corrosion / Sunshine Productions )
; andreas.sigfridsson@gmail.com
; Copyright (c) 2020 Andreas Sigfridsson
; This software is distributed under GPL (GNU General Public License 2)
; https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
; 
; It is fun to optimize code for size, and 256 bytes is a challenging target.
; A lot of bytes are spent with loop instructions, and I obviously had to save
; on the scrolltext length. Some code is generated to allow for unrolling of loops,
; otherwise I wouldn't be able to dist the whole screen like this.
;
; The binary saves space by not checking for keyboard input, never returning to
; TOS, and not bothering setting the resolution. So start it in low res, and be
; prepared to reset your machine afterwards. :-)
;
; I'm sure one could squeeze a few more bytes out of it, and add double buffering
; or divide the copy code in order to remove the artifacts near the top. Oh, well...
; Any feedback is much appreciated!





; 0 = release (optimized for size, no return), ~0 = debug
release equ 0

NUM_LINES	equ	25

; d0
; d1
; d2 scroll counter
; d3 (1024-1)*2
; d4 dist counter
; d5 loop (init only)
; d6 loop
; d7 loop
; a0
; a1
; a2
; a3 160*8 (init only), font (runtime only)
; a4 sintab
; a5 40 (init only)
; a6 data_buf, vbl-code ptr (init only)
; a7 stack
 


	ifeq	release
        opt X-,D-
	else
        opt X-,D+
	endc

text

        ifne release
	pea	start(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1
	else
	move.w	#$20,-(sp)
        trap	#1
	endc

start:
	lea	data_buf(pc),a6
	movem.w	(a6)+,d2/d3/d4/d7/a2/a3/a5	; sin_length-1, (1024-1)*2, 256, 160*8*24, rts, 160*8, 40

	ifne	release
	lea	save_pal(pc),a0
	move.l	$ffff8240.w,(a0)
	endc
	move.l	a2,$ffff8240.w

gen_copy:
	lea	copy_code(pc),a0
;	moveq	#0,d0
;	moveq	#NUM_LINES-1,d7
.gen_loop:
	move.w	#$3340,(a0)+		; move.w d0,X(a1)
	move.w	d7,(a0)+
;	add.w	#160*8,d0
	sub.w	a3,d7
	bge.s	.gen_loop

;	dbra	d7,.gen_loop
	move.w	a2,(a0)+		; rts

gen_message:
	ifeq	0
	ifeq	1
	lea	message_data(pc),a2
	move.l	a2,-(sp)
	else
	move.l	a0,-(sp)
	move.l	#$536F6C6F,(a0)+	; "Solo"
	move.l	#$6D6F6E2D,(a0)+	; "mon-", rely on a NUL byte following
	endc
	move.w  #9,-(sp)
        trap    #1
        ifne release
        addq.w  #6,sp
	endc
	
	else
	
;	lea     message(pc),a0
; no need
	move.l	a0,-(sp)
	moveq	#39-1,d7
	moveq	#'A',d0
.charloop:
	move.b	d0,(a0)+
	addq.b	#1,d0
	dbra	d7,.charloop

	move.w  #9,-(sp)
        trap    #1
        ifne release
        addq.w  #6,sp
	endc
	endc


copyfont:
        movea.l $0000044e.w,a1  ;screenbase

; not necessary =
;	lea	font(pc),a0
;	move.l	a0,a3

	moveq	#4-1,d7
.charloop:
	moveq	#16-1,d6

;	moveq	#0,d0		; no need
.rotloop
	moveq	#8-1,d5
	lea	roxl_code(pc),a4
	moveq	#0,d1


.lineloop:
	lsl.w	(a1)	; -> X
	addx.b	d0,d0		; shift in x
	lea	160(a1),a1

	move.l	#$D000E5E9,(a4)+			; add.b d0,d0, roxl X(a1)
	move.w	d1,(a4)+
	add.w	a5,d1


	dbra	d5,.lineloop
;	lea	-8*160(a1),a1
	sub.w	a3,a1


;	move.w	d5,(-NUM_LINES+8)*6(a1)	; rts
	move.w	a2,(a4)+	; rts

	move.b	d0,(a0)+
	dbra	d6,.rotloop

	addq.l	#8,a1
	dbra	d7,.charloop

	sub.w	a5,a1

; moved into sin_gen
cls:
;	move.w	#160/4*8,d0		; 4b
;	move.w	a3,d0
;.loop:	clr.l	(a1)+		; 2b
;	dbra	d0,.loop	; 4b


;==============================
;=
;=  32 bytes sinus table generator
;= for a 16.16 fixedpoint sinus table with 1024 entries
;=
;= by ray//.tSCc.	  2001
;==============================

sin_gen:
;		lea.l	sintab(pc),a4						; 4

;		move.w	#512-1,d2						; 4
; no need
;	move.w	#256,d4
.gen_loop	move.w	d2,d1		; Approximate the sinus curve using a	; 2
	sub.w	d4,d1
;		subi.w	#256,d1		; parabolic graph			; 4
		muls.w	d1,d1							; 2
	asr.l	#8,d1

;		subi.l	#$10000,d1	; -sin d0 ~ (d0 - 1) ^ 2 - 1		; 6
	sub.w	d4,d1
	asr.w	#2,d1
		move.w	d1,512*2(a4)	; 3rd & 4th quadrant			; 4
		sub.w	d1,(a4)+	; 1st & 2nd    "			; 2


	clr.l	(a1)+		; 2b, cls


		dbra	d2,.gen_loop						; 4
										;--
										;32 bytes
; d2 = -1


	ifne release
	lea	save_vbl(pc),a2
	move.l	$70.w,(a2)
	endc

;	lea	vbl(pc),a0
;	move.l	a0,$70.w
	move.l	a6,$70.w		; right after data_buf
	ifeq release
	bra.s	*
	else
.waitkey
	cmpi.b	#57,$fffffc02.w
	bne	.waitkey

	lea	save_vbl(pc),a0
	move.l	(a0),$70.w

	lea	save_pal(pc),a0
	move.l	(a0),$ffff8240.w

	rts
	endc

	ifne release
save_vbl	dc.l	0
save_pal	dc.l	0
	endc
;message_data: 	
;	dc.b	"Solomon- ",0
data_buf	dc.w	512-1, (1024-1)*2, 256, 160*8*24, $4e75, 160*8, 40
; #$536F6C6F6D6F6E20

vbl:

copybuf:
	lea	buf(pc),a0
        movea.l $0000044e.w,a1  ;screenbase

	move.w	#20*8-1,d7
.copyloop:
	move.w	(a0)+,d0
	bsr	copy_code
	addq.w	#8,a1
	dbra	d7,.copyloop

        ifne release
	not.w	$ffff8240.w
	endc


do_scroll:
	lea	font(pc),a3
	lea	buf(pc),a1
	lea	sintab(pc),a4

;	and.w	#(1024-1)*2,d5		; 4b
	and.w	d3,d5			; 2b
	move.w	(a4,d5.w),a6		; 4b
	addq.w	#2*3,d5			; 2b


	moveq	#20-1,d7
.charloop:

	moveq	#16-1,d6
.shiftloop
	addq.w	#1,d2			; first time is -1
	and.w	#$3f,d2
	move.b	(a3,d2.w),d0

	move.w	(a4,d4.w),d1
	asr.w	#1,d1
	add.w	a6,d1			; 2b
	andi.w	#7,d1
	addq.w	#2*2,d4
;	and.w	#(1024-1)*2,d4
	and.w	d3,d4
	rol.b	d1,d0

	bsr	roxl_code

;	moveq	#8-1,d5
;.lineloop	
;CURLINE	set	0
;	rept	8
;	add.b	d0,d0
;	roxl.w	CURLINE*40(a1)
;CURLINE	set	(CURLINE+1)
;	endr
;	ifeq	0
;	roxl.w	(a1)
;	else
;	move.w	(a1),d1
;	addx.w	d1,d1
;	move.w	d1,(a1)
;	endc
;	lea	40(a1),a1
;
;	dbra	d5,.lineloop
;	lea	-8*40(a1),a1
	dbra	d6,.shiftloop
	addq.w	#2,a1
	dbra	d7,.charloop

	sub.w	#20*16-1,d2
	sub.w	#20*16*2*2+2*9,d4


        ifne release
	not.w	$ffff8240.w
	endc

	rte


	bss
bss_start:
copy_code	ds.w	NUM_LINES*2+1
message:	ds.b	8	; "Solomon-"
; piggyback on the next NUL
font:	ds.w	256
;20*8
font_end:
roxl_code	ds.w	8*3+1
sintab		ds.w	1024
buf:	ds.w	20*8
buf_end:
bss_end:
	end
