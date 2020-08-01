;*********************************************************
;
;           decode GEM IMG picture format
;
;        revision  9.2.1996 by Martin Hejral
;
;*********************************************************

		EXPORT img_unpack

;***** header informations *****

HEADLEN	=  2
NPLANES	=  4
PATLEN	=  6
WIDTH	= 12
HEIGHT	= 14

;*********************************************************

img_unpack:

; -> A0 ... unpacked image
; -> A1 ... destination image

		movem.l	d0-a6,-(a7)

		move.l	a1,dest
		bsr  	dec_img

		movem.l	(a7)+,d0-a6
		rts

dec_img:
		move.w	PATLEN(a0),patt_len

		move.w	NPLANES(a0),planes

		clr.l	d0
		move.w	WIDTH(a0),d0
		lsr.l	#3,d0			;/8 = bytes per line
		move.l	d0,bytesperline
		divu.w	NPLANES(a0),d0
		ext.l	d0
		move.l	d0,bperplane	;/NPLANES = bytes per plane
;;		lsl.l	#2,d0			;*planes

		move.w	HEIGHT(a0),lines

		move.w	HEADLEN(a0),d0		;header length in words
		add.w	d0,d0			;header length in bytes
		add.w	d0,a0			;here starts packed data

		move.w	#0,repeat
		move.w	lines,d7
		subq.w	#1,d7	;for DBRA
loop_y:
		;*** for all lines ***
		move.w	repeat,d0
		bne  	do_repeat

		move.w	planes,d6
		subq.w	#1,d6	;for DBRA
loop_plane:
		;*** for all planes ***
		bsr  	plane
		add.l	#2,dest	;move to next plane in dest. memory
		dbra.w	d6,loop_plane

;;		bsr	plane
;;		add.l	#2,dest
;;		bsr	plane
;;		add.l	#2,dest
;;		bsr	plane

		move.l	bytesperline,d0
		sub.l	planes,d0
		sub.l	planes,d0
;;		subq.l	#6,d0
		add.l	d0,dest	;set pointer to next Y-position

		bra	no_repeat
do_repeat:
		subq.w	#1,d0
		move.w	d0,repeat
		move.l	dest,a2
		move.l	a2,a3
		sub.l	bytesperline,a3
		move.l	bytesperline,d0
		lsr.l	#1,d0
		subq.w	#1,d0
loop_rep:
		move.w	(a3)+,(a2)+
		dbra 	d0,loop_rep

		move.l	bytesperline,d0
		add.l	d0,dest
no_repeat:
		dbra 	d7,loop_y

		rts	;from dec_img

;*** decode and convert one plane ***
; -> A0: source data

plane:
		lea  	linebuf,a1	;A1: here place decoded pixels
		bsr  	decode_plane
		;convert to specific format (ST bitplanes)
		move.l	dest,a2   	;destination in ST specific format
		lea  	linebuf,a1	;source = decoded pixels from IMG
		move.w	bperplane,d0	;X-counter
		lsr.w	d0	;X in words
loop_x:
		move.w	(a1)+,(a2)
		add.l	planes,a2
		add.l	planes,a2
		dbra 	d0,loop_x

		rts	;from plane

decode_plane:

; -> A0: point to unpacked data
; -> A1: buffer for decoded bitplane in standard format

		move.b	(a0)+,d0
		bne  	no_null

		move.b	(a0)+,d0
		bne  	pattern

		;*** line replication ***

		move.b	(a0)+,d0	;is 255
		moveq	#0,d0
		move.b	(a0)+,d0
		subq.w	#1,d0
		move.w	d0,repeat
		move.l	a1,d0	;?????
		bra  	decode_plane
no_null:
		cmp.b	#$80,d0
		bne  	solid_run

		;*** bit_string ***

		moveq	#0,d0
		move.b	(a0)+,d0
		subq.w	#1,d0
loop_bs:
		move.b	(a0)+,(a1)+
		dbra 	d0,loop_bs
		bra  	end_rout

		;*** solid_run ***
solid_run:
		move.b	d0,d1
		and.b	#$80,d1
		sne  	d1
		and.w	#$7f,d0
		subq.w	#1,d0
loop_sr:
		move.b	d1,(a1)+
		dbra 	d0,loop_sr
		bra  	end_rout

		;*** pattern_run ***
pattern:
		move.w	patt_len,d1
		subq.w	#1,d1
		and.w	#$ff,d0	;LOW byte is number of patterns
		subq.w	#1,d0
loop_p1:
		move.l	a0,a2
		move.w	d1,d2	;pattern length
loop_p2:
		move.b	(a2)+,(a1)+
		dbra 	d2,loop_p2
		dbra 	d0,loop_p1

		add.w	patt_len,a0	;skip pattern in source data
end_rout:
		;test for end of plane
		move.l	a1,d0
		sub.l	#linebuf,d0
		cmp.l	bperplane,d0
		blt  	decode_plane

		rts	;from decode_plane



;*********************************************************
;*********************************************************
;*********************************************************

		BSS

		EVEN

dest:		ds.l	1

patt_len:		ds.w	1
planes:		ds.w	1
bytesperline:	ds.l	1
bperplane:	ds.l	1
lines:		ds.w	1

repeat:		ds.w	1
linebuf:		ds.b	4096/8	;space for 4096 pixels

		END

;***************** end of IMG_ASM.S **********************
