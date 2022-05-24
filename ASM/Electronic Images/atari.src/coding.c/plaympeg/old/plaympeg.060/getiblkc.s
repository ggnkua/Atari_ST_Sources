;------------------------------------------------------------------
; Falcon MPEG decoder (Intra-Frame Only)
; By Martin Griffiths, August/September 1994
;------------------------------------------------------------------


			EXPORT	SETVGA,SETTV,ld_rdptr,go,start_time,end_time,frame_count
			IMPORT Log_base,Phy_base,biggie,mb_addr_inc,bitlength
			IMPORT Cconis,init_mb_addr_inc,alloc_display,init_display,init_biggie

PICTURE_START_CODE 	equ	$100
USER_START_CODE		equ $1B2
SEQ_START_CODE     	equ	$1B3
EXT_START_CODE		equ $1B5
SEQ_END_CODE       	equ	$1B7
GOP_START_CODE     	equ	$1B8
SLICE_MIN_STARTCODE equ	$101
SLICE_MAX_STARTCODE equ	$1af

; Falcon video register equates

vhz	        EQU $FFFF820A
voff_nl     EQU $FFFF820E
vwrap       EQU $FFFF8210
_stshift	EQU $FFFF8260
_spshift    EQU $FFFF8266
hht         EQU $FFFF8282
hbb         EQU $FFFF8284
hbe         EQU $FFFF8286
hdb         EQU $FFFF8288
hde         EQU $FFFF828A
hss         EQU $FFFF828C
hfs         EQU $FFFF828E
hee         EQU $FFFF8290
vft         EQU $FFFF82A2
vbb         EQU $FFFF82A4
vbe         EQU $FFFF82A6
vdb         EQU $FFFF82A8
vde         EQU $FFFF82AA
vss         EQU $FFFF82AC
vco_hi      EQU $FFFF82C0
vco         EQU $FFFF82C2

mb_inc_val	equ	0
mb_inc_num	equ	2

dc_size_val	equ	0
dc_size_num	equ	2



			macro	wait_to_send X
.wait:		BTST.B 	#1,X
			BEQ.S 	.wait
			endm

			macro	wait_to_rec X
			BTST.B 	#0,X
			BEQ.S 	*-4
			endm	
						
			macro	getbitsQ X
			bfextu	(a6){d7:X},d0
			addq.l	#X,d7
			endm
		
			macro	getbits	X
			bfextu	(a6){d7:X},d0
			add.l	X,d7
			endm

			macro	getslicehdr
			bfextu	(a6){d7:5},d0
			addq.l	#5,d7				
			move.w	d0,ld_quant_scale
			bsr		ext_bit_info
			endm
			
			macro	getMBA
			showbits 11				
			moveq	#0,d1
			move.w	(mb_addr_inc+2,d0*4),d1
			move.w	(mb_addr_inc,d0*4),d0
			add.l	d1,d7			
			endm

; get Macro Block Type
; 2 bits ( %00 = error %01 = intra %10 = 0 %11 = 0)

			macro	getMBtype
			showbits 2
			cmp.w	#1,d0
			seq		d2
			add.l	(quantTbl,d0*4),d7
.nah:		tst.b	d2
			beq.s	.noq
			getbitsQ	5
			move.w	d0,ld_quant_scale			
.noq:
			endm
quantTbl:	dc.l	0,2,1,1

			macro	getDClum
			showbits 7				; show bits(7);
			move.w	(a3,d0*2),d0
			moveq	#0,d1
			move.b	d0,d1
			add.l	d1,d7			; flushbits
			moveq	#0,d1
			lsr.w	#8,d0			
			beq.s	.DCldone
			bfextu	(a6){d7:d0},d1	; getbits(size)
			bmi.s	.DCldone
			clr		d2
			bset	d0,d2
			subq	#1,d2
			sub.w	d2,d1
.DCldone: 	add.l	d0,d7
			endm

			macro	getDCchrom
			showbits 8				; showbits(8)
			move.w	(a4,d0*2),d0
			moveq	#0,d1
			move.b	d0,d1
			add.l	d1,d7			; flushbits
			moveq	#0,d1
			lsr.w	#8,d0
			beq.s	.DCldone
			bfextu	(a6){d7:d0},d1	; getbits(size)
			bmi.s	.DCldone
			clr		d2
			bset	d0,d2
			subq	#1,d2
			sub.w	d2,d1
.DCldone: 	add.l	d0,d7
			endm

			macro	showbits X
			bfextu	(a6){d7:X},d0
			endm
						
			macro	flushbits
			add.l	d0,d7
			endm

			macro	flushbitsQ X
			add.l	#X,d7
			endm

swap_screens:
			move.l	Log_base(pc),d0
			move.l	Phy_base(pc),d1
			move.l	d0,Phy_base
			move.l	d1,Log_base
			move.b	d0,$ffff820d.w
			lsr.w	#8,d0
			move.l	d0,$ffff8200.w
			rts

go:			move.w	#$2500,sr
			movem.l	d2-d7/a2-a6,-(sp)
			bsr		init_mb_addr_inc
			bsr		init_biggie
			clr.l	frame_count
			bsr		initbits
			bsr		startcode			;	valid mpeg stream?
			showbits	32
			cmp.l 	#SEQ_START_CODE,d0	;
			bne.s	notmpeg				;		

			move.l	$4ba.w,start_time
loop:		bsr		getheader
			addq.l	#1,frame_count
			bsr		Cconis
			tst.l	d0
			beq.s	loop
			
itends:		move.l	$4ba.w,end_time
			movem.l	(sp)+,d2-d7/a2-a6
			move.w	#$2300,sr
			moveq	#0,d0
			rts
notmpeg:	movem.l	(sp)+,d2-d7/a2-a6
			move.w	#$2300,sr
			moveq	#-1,d0
			rts
			
frame_count:dc.l	0
start_time:	dc.l	0
end_time:	dc.l	0
			
initbits:	lea 	$ffffa206.w,a5
			move.l	ld_rdptr(pc),a6
			moveq	#0,d7
			rts

; Search for the next startcode.
			
startcode:	bfextu	d7{29:3},d0
			beq.s	onbyte
			sub.l	d0,d7
search_lp:	addq.l	#8,d7			; flushbits(ld_incnt & 7);
onbyte:		showbits 24				; showbits(24)
			moveq	#1,d1			; == 1??
			cmp.l	d1,d0
			bne.s	search_lp
foundstart:	rts

; Skip Extra Bit Info

extb_lp:	flushbitsQ 8		;		flushbits(8)
ext_bit_info:
			getbitsQ 1			; while (getbits(1))
			tst.w	d0
			bne.s	extb_lp
			rts

; Decode extension and User data

dec_extuse:	moveq	#32,d0
			flushbits
ext_user_data:
			bsr		startcode
ext_user_lp:showbits 32
			cmp.l	#EXT_START_CODE,d0
			beq.s	dec_extuse
			cmp.l	#USER_START_CODE,d0
			beq.s	dec_extuse
			rts

;

parse_slice:moveq	#24,d0
			flushbits					; flushbits(24)
			bfextu	(a6){d7:8},d6		; code = getbits(8)
			addq.l	#8,d7			
			getbitsQ	5
			move.w	d0,ld_quant_scale
			bsr		ext_bit_info
			subq	#1,d6				; (code-1)
			mulu	mb_width(pc),d6		; code *mb_width
			subq.l	#1,d6				; -1 = MBA
			lea		dc_dct_pred(pc),a0
			clr.l	(a0)			
			clr.w	4(a0)
			rts


; Decode Header

getheader:	showbits	32
			cmp.l	#SEQ_END_CODE,d0
			beq.s	seq_end
			move.l	d7,d1
			add.l	#32,d1
			cmp.l	bitlength(pc),d1
			bhs.s	seq_end
			cmp.l	#SEQ_START_CODE,d0
			beq.s	getseqhdr
			cmp.l	#GOP_START_CODE,d0
			beq		getgophdr
			cmp.l	#PICTURE_START_CODE,d0
			beq		getpicturehdr
			cmp.l	#SLICE_MIN_STARTCODE,d0
			blo		getpicture
			cmp.l	#SLICE_MAX_STARTCODE,d0
			bhi		getpicture
	

seq_end:	bsr		initbits
			bsr		startcode
			bra		getheader
			
; Decode Sequence header.

getseqhdr:	moveq	#32,d0
			flushbits
			moveq	#12,d1
			getbits d1
			move.w	d0,horizontal_size
			moveq	#12,d1
			getbits	d1
			move.w	d0,vertical_size
			moveq	#27+11,d0
			flushbits 
			move.w	horizontal_size(pc),d0
			add.w	#15,d0
			lsr.w	#4,d0
			move.w	d0,mb_width
			move.w	vertical_size(pc),d1
			add.w	#15,d1
			lsr.w	#4,d1
			move.w	d1,mb_height
			move.w	d0,d2
			mulu	d1,d2
			move.l 	d2,MBAmax		; mb_height*mb_width
			lsl.w	#4,d0
			lsl.w	#4,d1
			move.w	d0,coded_picture_width
			move.w	d1,coded_picture_height

			move.w	last_vert(pc),d0
			cmp.w	vertical_size(pc),d0
			beq.s	no_init
			move.w	vertical_size(pc),last_vert
			move.w	#37,-(sp)
			trap	#14
			addq.l	#2,sp
			bsr		init_display
			move.w	#37,-(sp)
			trap	#14
			addq.l	#2,sp
no_init:
			MOVE.B #$80+20,$FFFFA201.W		; host command 3
			lea		default_intra_matrix(pc),a0
			moveq	#64-1,d5
			getbitsQ 1
			tst.w	d0
			beq.s	def_matrix
			lea		zig_zag_scan(pc),a3
get_mat:	getbitsQ 8
			move.w	(a3)+,d1
			move.w	d0,(a0,d1*2)
			dbf		d5,get_mat
			moveq	#64-1,d5
def_matrix:	moveq	#0,d0
initdefq:	wait_to_send -4(a5)
			move.b	(a0)+,d0
			move.l	d0,-2(a5)
			dbf		d5,initdefq
mat1_done:	getbitsQ 1
			tst		d0
			beq.s	skipcont
skipnonintra:
			add.l	#64*8,d7		;			flushbits
skipcont:	bsr		ext_user_data
	
; Decode group of pictures header 
; dropflag(1)/ hour(5)/minute(6)/(1)/seconds(6)/frame(7)/closed_gop(1)/broken_link(1)

getgophdr:	moveq	#27+32,d0
			flushbits
			bsr		ext_user_data
			
; Decode Picture Header
; 10 bits (Temporal Reference)/3 bits (Picture Type)/ 16 bits (Vbv delay)

getpicturehdr:
			moveq	#32+10,d0
			flushbits
			getbitsQ	3
;			cmp.w	#1,d0
;			beq.s	hmmmm
;.searchpic:	bsr		startcode		;	not i frame
;			bra		getheader
hmmmm:		moveq	#16,d0
			flushbits
			bsr		ext_bit_info
			bsr		ext_user_data

getpicture:	
			move.l	Log_base(pc),a0
			add.w	#320,a0
			sub.w	coded_picture_width(pc),a0
			move.l	a0,this_base
			lea		biggie,a2
			lea		dct_dc_size_luminance,a3			
			lea		dct_dc_size_chrominance,a4
			clr.b	-1(a5)			
			bsr		parse_slice
			moveq	#100-1,d5			
nxt:		showbits 23					; showbits(23)
			beq		dodisplay			; finished
ok_getMBA:	getMBA
			cmp.w	#35,d0
			bne.s	.notesc
			add.l	#33,d6
			bra.s	ok_getMBA
.notesc:	cmp.w	#34,d0
			beq.s	ok_getMBA
			add.l	d0,d6
			cmp.l	MBAmax(pc),d6		; MBA>=MBAmax
			bhs		startcode
			MOVE.B #$80+19,$FFFFA201.W		; host command 2

			getMBtype

			wait_to_send -4(a5)
			move.w	ld_quant_scale(pc),(a5)

			lea		dc_dct_pred(pc),a0
get_lum_b1:	getDClum
			bsr		getintrablock
get_lum_b2:	getDClum
			bsr		getintrablock
get_lum_b3:	getDClum
			bsr		getintrablock
get_lum_b4:	getDClum
			bsr		getintrablock
			lea		dc_dct_pred+2(pc),a0
get_cr:		getDCchrom
			bsr		getintrablock
			lea		dc_dct_pred+4(pc),a0
get_cb:		getDCchrom
			bsr		getintrablock
get_block:	
			move.l	this_base(pc),a0
			move.l	d6, d4
			divu	mb_width(pc),d4
			move.l	d4,d3		; by
			swap	d3			; bx
			lsl		#5,d3		; 16*2
			add.w	d3,a0
			mulu	#320*2*16,d4
			add.l	d4,a0
			moveq 	#16,d0
			lea		-4(a5),a1
lpd2:		
			rept	16
			wait_to_rec (a1)
			move.w	(A5),(a0)+
			endm
			lea		(320*2)-32(a0),a0
			subq	#1,d0
			bne		lpd2
			dbf		d5,	nxt
			rts
dodisplay:	bsr		startcode
			bra		swap_screens
						
this_base:	dc.l	0
lastpos:	dc.l	0
    
; Decode an Intra Block
; a0 -> dc dct predictor value

			.ALIGN 16
			
getintrablock:
			lea.l	temp(pc),a1
			add.w	d1,(a0)
			moveq	#1,d2
decode_lp:	showbits 16
			move.l	(a2,d0.l*4),d1	; 
			moveq	#0,d0
			move.b	d1,d0
			flushbits					; flushbits(tab->len)
			lsr.w	#8,d1				; tab->run
			cmp.b	#64,d1
			bhs.s	is_run				;
			add.b	d1,d2				; i+= tab->run;
			swap	d1					; val = tab->level;
			bftst	(a6){d7:1}			; sign = getbits(1)
			beq.s	notneg
			neg		d1
notneg:		addq.l	#1,d7				;
			move.w	d2,(a1)+
			move.w	d1,(a1)+
			addq.b	#1,d2
			bra.s	decode_lp	
is_run:		beq.s	is_end				; if (tab->run==65)
			getbitsQ	6				; i+=getbits(6) 
			add.w	d0,d2
			getbitsQ	8				; val = getbits(8)
			tst.w	d0
			beq.s	val_zero			;
			cmp.w	#128,d0
			bpl.s	val_higher
			bmi.s	val_cont
			getbitsQ 8					; val = getbits(8)
val_higher:	sub.w	#256,d0				; val -=256;
val_cont:	
			move.w	d2,(a1)+
			move.w	d0,(a1)+
			addq.b	#1,d2
			bra.s	decode_lp	
			bra.s	is_end
val_zero:	getbitsQ	8				; val = getbits(8)
			move.w	d2,(a1)+
			move.w	d0,(a1)+
			addq.b	#1,d2
			bra.s	decode_lp	
		
is_end:		sub.l	#temp,a1
			move.l	a1,d0
			lea		temp(pc),a1
			wait_to_send -4(a5)
sen_dc:		move.w	(a0),(a5)
			lsr.l	#2,d0
			beq.s	zap			
lpye:		wait_to_send -4(a5)
			MOVE.L	(A1)+,-2(a5)
			subq	#1,d0
			bne.s	lpye
zap:
			wait_to_send -4(a5)
			clr.l	-2(a5)
			rts								
			
; Set Video Mode to VGA True Colour 320x200.
; (hit the h/ware directly)

SETTV:
			lea	TC320_TV(PC),A0
			clr.w	(_spshift.w)
			LEA (hht).w,A1
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			move.W	#$0271,(vft.w)
			move.w	vertical_size(pc),d1
			add.w	d1,d1				; *4
			move.w	#480,d0
			sub.w	d1,d0
			lsr.w	#1,d0
			add.w	#$3f,d0
			add.w	d0,d1
			move.w	d0,(vbe.w)  ; top border display end (3f)
			move.w	d1,(vbb.w)	; bottom border (3ff)
			move.w	d0,(vdb.w)	; display start (3f)
			move.w	d1,(vde.w)	; display end   (3ff)
			move.w	#$026b,(vss.w)
	    	move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
	        move.w  (a0)+,(vco.w)
	        move.w  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			move.w  (a0),(_spshift)
			rts

SETVGA:		lea	TC320_VGA(PC),A0
			clr.w	(_spshift.w)
			LEA (hht).w,A1
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			MOVE.L (a0)+,(A1)+
			move.W	#$0419,(vft.w)
			move.w	vertical_size(pc),d1
			lsl.w	#2,d1				; *4
			move.w	#960,d0
			sub.w	d1,d0
			lsr.w	#1,d0
			add.w	#$3f,d0
			add.w	d0,d1
			move.w	d0,(vbe.w)  ; top border display end (3f)
			move.w	d1,(vbb.w)	; bottom border (3ff)
			move.w	d0,(vdb.w)	; display start (3f)
			move.w	d1,(vde.w)	; display end   (3ff)
			move.w	#$0415,(vss.w)
		    move.w  (a0)+,(voff_nl.w)
			MOVE.W  (a0)+,(vwrap.w)
    	    move.w  (a0)+,(vco.w)
	        move.w  (a0)+,(vco_hi.w)
			move.w  (a0)+,(vhz.w)
			move.w  (a0),(_spshift)
			RTS

			data	

TC320_VGA:	DC.W	$00C6 ; hht
			DC.W	$008D ; hbb
			DC.W	$0015 ; hbe
			DC.W	$02AC ; hdb
			DC.W	$0091 ; hde (horizontal display end, 0 == middle
			DC.W	$0096 ; hss
			DC.W	$0000 ; hfs
			DC.W	$0000 ; hee
			DC.W	$0000 ; next line offset
			DC.W	$0140 ; vwrap
			DC.W	$0005 ; vco
			DC.W	$0186 ; vco hi
			DC.W	$0000 ; $ffff820a
			DC.W	$0100 ; spshift

TC320_TV:	DC.W	$00FE ; hht
			DC.W	$00CB ; hbb
			DC.W	$0027 ; hbe
			DC.W	$002E ; hdb
			DC.W	$008F ; hde
			DC.W	$00D8 ; hss
			DC.W	$0000 ; hfs
			DC.W	$0000 ; hee
			DC.W	$0000 ; next line offset
			DC.W	$0140 ; vwrap
			DC.W	$0000 ; vco
			DC.W	$0183 ; vco hi
			DC.W	$0200 ; $ffff820a
			DC.W	$0100 ; spshift

			.ALIGN 16

dct_dc_size_luminance:
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3 
	dc.b	0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3, 0, 3 
	dc.b	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.b	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.b	4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3 
	dc.b	4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3 
	dc.b	5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4 
	dc.b	6, 5, 6, 5, 6, 5, 6, 5, 7, 6, 7, 6, 8, 7, -1,0

dct_dc_size_chrominance:
	dc.b	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.b	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.b	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.b	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.b	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.b	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.b	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.b	0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 
	dc.b	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.b	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.b	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.b	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 
	dc.b	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 
	dc.b	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 
	dc.b	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 
	dc.b	6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, -1,0
		
zig_zag_scan:
			dc.w	0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5
			dc.w	12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28
			dc.w	35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51
			dc.w	58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63

default_intra_matrix:
			dc.b	 8, 16, 19, 22, 26, 27, 29, 34
			dc.b	16, 16, 22, 24, 27, 29, 34, 37
			dc.b	19, 22, 26, 27, 29, 34, 34, 38
			dc.b	22, 22, 26, 27, 29, 34, 37, 40
			dc.b	22, 26, 27, 29, 32, 35, 40, 48
			dc.b	26, 27, 29, 32, 35, 40, 48, 58
			dc.b	26, 27, 29, 34, 38, 46, 56, 69
			dc.b	27, 29, 35, 38, 46, 56, 69, 83
last_vert:	dc.w	-1
ld_rdptr:	ds.l	1
ld_quant_scale:
			ds.l	1
MBAmax:		ds.l	1
dc_dct_pred:ds.w 	3
horizontal_size:
			ds.w	1
vertical_size:
			ds.w	1
mb_width:	ds.w	1
mb_height:	ds.w	1
coded_picture_width:
			ds.w	1
coded_picture_height:
			ds.w	1

			.ALIGN 16
			
temp:		ds.l 	128
