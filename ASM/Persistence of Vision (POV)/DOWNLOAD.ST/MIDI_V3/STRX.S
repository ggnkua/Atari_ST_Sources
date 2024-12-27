*************************************************************************
*			ST Midi port Receiver code			*
*			--------------------------			*
*									*
*									*
*									*
* Written by:	Mac Sys Data of Persistence Of Vision			*
*									*
*									*
* Date:		29-March-1995						*
*									*
*									*
*************************************************************************
;
; Use:
;     This code is intended for Atari assembler programmers who like
;     myself despair at having to reboot their Atari ST/STE/FALCON
;     whenever their code crashes.
;
;     The code supplied, when assembled, will allow the user to connect
;     two ST/STE/FALCON/TT machines together via the midi ports and
;     actively code on one machine, assemble the code and download the
;     executable to a second machine where the code is run. If at anytime
;     the code crashes, the transmitting Atari is left intact with the
;     source code.
;
;     The system is a 'home brew' PDS system designed by Persistence Of
;     Vision to aid program development.
;
;     This version has been revised to use the MIDI ports to be conpatible
;     with the Falcon. The original and faster code is still available
;     that utilises the parallel port BUT it can only be used to link
;     an ST/STE at 8mhz to a like machine.
;
;     Mark
;     Mac Sys Data / Persistence Of Vision (not the ray trace people,
;                                            we were here first)
;     email   mrsd1@bnfl.co.uk
;


		bra.s	over
		dc.b	"    STRX.PRG",0,0
		dc.b	"WIDGET RX PROGRAM (c) MARK SHERDLEY-DAVIES "
		dc.b	"1995       ",0
		even



over
		move.l	#dl_stack,sp
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.w	#6,sp

		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
clr_bss		clr.b	(a0)+
		sub.l	#1,d0
		bne.s	clr_bss

		bsr	calc_ram
		bsr	titles

		lea	dl_code,a0
		lea	$1800,a1
		move.l	#dl_code_length,d0
relocate	move.b	(a0)+,(a1)+
		sub.l	#1,d0
		bne.s	relocate
		jmp	$1800



******************** Print system info and titles ***************
titles		move.l	$44e.w,a0	;clear screen
		move.w	#32000/4-1,d0
clr_scrn	clr.l	(a0)+
		dbf	d0,clr_scrn

		clr.w	$ffff8240.w
		move.w	#-1,$ffff825e.w

		lea	message(pc),a0
		move.l	$44e.w,a1
		lea	font(pc),a2
		move.l	a1,a3
.char		move.b	(a0)+,d0
		bmi.s	.done
		cmp.b	#10,d0
		beq.s	.next_line
		cmp.b	#13,d0
		beq.s	.start_line
		bsr	show_char
		bra.s	.char
.done		rts

.next_line	lea	(8*160)(a3),a3
.start_line	move.l	a3,a1
		bra.s	.char
show_char	sub.b	#32,d0
		and.w	#$00ff,d0
		mulu	#5,d0
		lea	(a2,d0.w),a4
OFF		set	0
		REPT	5
		move.b	(a4)+,OFF(a1)
OFF		set	OFF+160
		ENDR
		addq.w	#1,a1
		move.w	a1,d0
		and.w	#1,d0
		bne.s	.no_bump
		addq.w	#6,a1
.no_bump	rts


message		dc.b	'WIDGET DOWNLOADER',13,10,10
		dc.b	'VERSION 3.0',13,10
		dc.b	'(C) 1992-1995   3-APR-1995',13,10
		dc.b	'MARK SHERDLEY-DAVIES',13,10
		dc.b	'LEO SKIRENKO',13,10
		dc.b	'PHILIP WATTS',13,10
		dc.b	10,10
		dc.b	'RAM = '
ram_txt		dc.b	'     ',13,10,10,10
		dc.b	"DOWNLOAD CODE AT $1800 - $1D60",13,10,10
		dc.b	"DOWNLOAD EXEC TO:    $00000000",13,10,10
		dc.b	"DOWNLOAD EXEC LENGTH:$00000000 ",13,10,10
		dc.b	"DOWNLOAD BYTES TO DO:$00000000",13,10
		dc.b	-1
		even
calc_ram	moveq	#0,d7
		lea	ram_txt(pc),a0
		move.l	$42e.w,d0
		moveq	#10,d1
		lsr.l	d1,d0
		divu	#1000,d0
		bsr.s	.digit
		swap	d0
		ext.l	d0
		divu	#100,d0
		bsr.s	.digit
		swap	d0
		ext.l	d0
		divu	#10,d0
		bsr.s	.digit
		swap	d0
		bsr.s	.digit
		move.b	#'K',(a0)
		rts
.digit		tst.b	d7
		bne.s	.show
		tst.w	d0
		beq.s	.zero
.show		st	d7
		add.b	#'0',d0
		move.b	d0,(a0)+
.zero		rts




*************************************************************************
		opt	p+
dl_code		bsr	wait_header
		bsr	get_org
		bsr	get_length
		bsr	get_data
		move.w	#$2700,sr
		lea	ORG(pc),a0
		move.l	(a0),a0
		jmp	(a0)
get_data	lea	ORG(pc),a5
		move.l	(a5),a6
		lea	LENGTH(pc),a5
		move.l	(a5),d3
.write_loop	bsr	get_byte
		move.b	d0,(a6)+
		move.b	d0,$ffff8240.w

		move.l	$44e.w,a0
		lea	160*144+88(a0),a0
		lea	number8+1(pc),a4
		move.l	d3,d2
		rept	4
		move.b	d2,d1
		and.b	#$f,d1
		move.b	d1,-(a4)
		move.b	d2,d1
		lsr.w	#4,d1
		move.b	d1,-(a4)
		lsr.l	#8,d2
		endr
						;cycles
		lea	number1(pc),a4		; 8
		move.w	#4-1,d0			; 8
.digits		move.b	(a4)+,d4		; 8
		and.w	#$f,d4			;12
		cmp.b	#$a,d4			; 8
		blt.s	.ok			;12
		add.w	#7,d4			; 8
.ok		add.w	#16,d4			; 8
		mulu	#5,d4			;40?
		lea	font(pc),a2		; 8
		lea	(a2,d4.w),a2		;16
		move.b	(a2)+,(a0)		;16
		move.b	(a2)+,160(a0)		;16
		move.b	(a2)+,320(a0)		;16
		move.b	(a2)+,480(a0)		;16
		move.b	(a2)+,640(a0)		;16
		move.b	(a4)+,d4		; 8
		and.w	#$f,d4			;12
		cmp.b	#$a,d4			; 8
		blt.s	.ok2			;12
		add.w	#7,d4			; 8
.ok2		add.w	#16,d4			; 8
		mulu	#5,d4			;40?
		lea	font(pc),a2		; 8
		lea	(a2,d4.w),a2		;16
		move.b	(a2)+,1(a0)		;16
		move.b	(a2)+,161(a0)		;16
		move.b	(a2)+,321(a0)		;16
		move.b	(a2)+,481(a0)		;16
		move.b	(a2)+,641(a0)		;16
		add.w	#8,a0			;16
		dbf	d0,.digits		;16+12n

		sub.l	#1,d3
		bne	.write_loop
		rts
wait_header	bsr	get_byte		Wait for 4 byte header.
bad_header	cmp.b	#'M',d0
		bne.s	wait_header
		bsr	get_byte
		cmp.b	#'S',d0
		bne.s	bad_header
		bsr	get_byte
		cmp.b	#'D',d0
		bne.s	bad_header
		bsr	get_byte
		cmp.b	#'!',d0
		bne.s	bad_header
		rts
get_org		lea	ORG(pc),a6
		bsr	get_byte
		move.b	d0,(a6)+
		bsr	get_byte
		move.b	d0,(a6)+
		bsr	get_byte
		move.b	d0,(a6)+
		bsr	get_byte
		move.b	d0,(a6)+
		lea	ORG(pc),a6
		move.l	(a6),d3
		move.l	$44e.w,a0
		lea	160*112+88(a0),a0
		lea	number8+1(pc),a4
		move.l	d3,d2
		rept	4
		move.b	d2,d1
		and.b	#$f,d1
		move.b	d1,-(a4)
		move.b	d2,d1
		lsr.w	#4,d1
		move.b	d1,-(a4)
		lsr.l	#8,d2
		endr
		lea	number1(pc),a4		; 8
		move.w	#4-1,d0			; 8
.digits		move.b	(a4)+,d4		; 8
		and.w	#$f,d4			;12
		cmp.b	#$a,d4			; 8
		blt.s	.ok			;12
		add.w	#7,d4			; 8
.ok		add.w	#16,d4			; 8
		mulu	#5,d4			;40?
		lea	font(pc),a2		; 8
		lea	(a2,d4.w),a2		;16
		move.b	(a2)+,(a0)		;16
		move.b	(a2)+,160(a0)		;16
		move.b	(a2)+,320(a0)		;16
		move.b	(a2)+,480(a0)		;16
		move.b	(a2)+,640(a0)		;16
		move.b	(a4)+,d4		; 8
		and.w	#$f,d4			;12
		cmp.b	#$a,d4			; 8
		blt.s	.ok2			;12
		add.w	#7,d4			; 8
.ok2		add.w	#16,d4			; 8
		mulu	#5,d4			;40?
		lea	font(pc),a2		; 8
		lea	(a2,d4.w),a2		;16
		move.b	(a2)+,1(a0)		;16
		move.b	(a2)+,161(a0)		;16
		move.b	(a2)+,321(a0)		;16
		move.b	(a2)+,481(a0)		;16
		move.b	(a2)+,641(a0)		;16
		add.w	#8,a0			;16
		dbf	d0,.digits		;16+12n
		rts
get_length	lea	LENGTH(pc),a6
		bsr	get_byte
		move.b	d0,(a6)+
		bsr	get_byte
		move.b	d0,(a6)+
		bsr	get_byte
		move.b	d0,(a6)+
		bsr	get_byte
		move.b	d0,(a6)+
		lea	LENGTH(pc),a6
		move.l	(a6),d3
		move.l	$44e.w,a0
		lea	160*128+88(a0),a0
		lea	number8+1(pc),a4
		move.l	d3,d2
		rept	4
		move.b	d2,d1
		and.b	#$f,d1
		move.b	d1,-(a4)
		move.b	d2,d1
		lsr.w	#4,d1
		move.b	d1,-(a4)
		lsr.l	#8,d2
		endr
		lea	number1(pc),a4		; 8
		move.w	#4-1,d0			; 8
.digits		move.b	(a4)+,d4		; 8
		and.w	#$f,d4			;12
		cmp.b	#$a,d4			; 8
		blt.s	.ok			;12
		add.w	#7,d4			; 8
.ok		add.w	#16,d4			; 8
		mulu	#5,d4			;40?
		lea	font(pc),a2		; 8
		lea	(a2,d4.w),a2		;16
		move.b	(a2)+,(a0)		;16
		move.b	(a2)+,160(a0)		;16
		move.b	(a2)+,320(a0)		;16
		move.b	(a2)+,480(a0)		;16
		move.b	(a2)+,640(a0)		;16
		move.b	(a4)+,d4		; 8
		and.w	#$f,d4			;12
		cmp.b	#$a,d4			; 8
		blt.s	.ok2			;12
		add.w	#7,d4			; 8
.ok2		add.w	#16,d4			; 8
		mulu	#5,d4			;40?
		lea	font(pc),a2		; 8
		lea	(a2,d4.w),a2		;16
		move.b	(a2)+,1(a0)		;16
		move.b	(a2)+,161(a0)		;16
		move.b	(a2)+,321(a0)		;16
		move.b	(a2)+,481(a0)		;16
		move.b	(a2)+,641(a0)		;16
		add.w	#8,a0			;16
		dbf	d0,.digits		;16+12n
		rts
get_byte	;read midi data
		move.w	d0,-(sp)	;char in
		move.w	#3,-(sp)	;midi in
		move.w	#2,-(sp)	;call TOS
		trap	#13
		addq.w	#6,sp
;data is in D0.B
		rts

font		incbin	font.dat

bssstart
ORG		ds.l	1
LENGTH		ds.l	1
number1	ds.b	1
number2	ds.b	1
number3	ds.b	1
number4	ds.b	1
number5	ds.b	1
number6	ds.b	1
number7	ds.b	1
number8	ds.b	1
bssend
		ds.b	256
dl_stack	ds.l	1
dl_code_end
dl_code_length	equ	dl_code_end-dl_code
