; Atari ST/e synclock demosystem
; August 22, 2008
;
; Image converter for 320x273 targa
;
; Input
; 320x273 uncompressed 24-bit Targa file
;
; Output
; Two 320x273 uncompressed 24-bit Targa files, each prepared for Photochrome spectrum 4096 conversion


size:		equ	320*200*3+18

		comment HEAD=%111

		opt	p=68030/68882

		output	.tos

start:
		;generate targa header
		move.w	#320,d0				;big -> little endian
		rol.w	#8,d0				;
		move.w	#200,d1				;
		rol.w	#8,d1				;

		lea.l	tgahead,a0
		clr.w	(a0)+				;0 id field length + colour map type
		move.b	#2,(a0)+			;2 data type 2
		rept	9
		clr.b	(a0)+				;11
		endr
		move.w	d0,(a0)+			;12 width
		move.w	d1,(a0)+			;14 height
		move.b	#24,(a0)+			;16 24 bits
		move.b	#32,(a0)+			;17 origo


		lea.l	tgahead,a0			;targa header copy
		lea.l	buffer1,a1
		lea.l	buffer2,a2
		lea.l	buffer3,a3
		lea.l	buffer4,a4
		move.w	#18/2-1,d7
.header:	move.w	(a0)+,d0
		move.w	d0,(a1)+
		move.w	d0,(a2)+
		move.w	d0,(a3)+
		move.w	d0,(a4)+
		dbra	d7,.header


upper_part:
		lea.l	orggfx+18,a0
		lea.l	buffer1+18,a1
		lea.l	buffer3+18,a2
		move.w	#199-1,d7
.tgay:		swap	d7
		move.w	#320-1,d7
.tgax:
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		move.b	(a0)+,d2
		lsr.b	#3,d0	;b
		lsr.b	#3,d1	;g
		lsr.b	#3,d2	;r

		btst	#0,d0
		beq.s	.same_b
		cmp.b	#31,d0
		bge.s	.same_b
		lsr.b	#1,d0
		move.b	d0,d3
		addq.b	#1,d3
		bra.s	.b_done
.same_b:	lsr.b	#1,d0
		move.b	d0,d3
.b_done:
		btst	#0,d1
		beq.s	.same_g
		cmp.b	#31,d1
		bge.s	.same_g
		lsr.b	#1,d1
		move.b	d1,d4
		addq.b	#1,d4
		bra.s	.g_done
.same_g:	lsr.b	#1,d1
		move.b	d1,d4
.g_done:
		btst	#0,d2
		beq.s	.same_r
		cmp.b	#31,d2
		bge.s	.same_r
		lsr.b	#1,d2
		move.b	d2,d5
		addq.b	#1,d5
		bra.s	.r_done
.same_r:	lsr.b	#1,d2
		move.b	d2,d5
.r_done:

		lsl.w	#4,d0
		lsl.w	#4,d1
		lsl.w	#4,d2
		lsl.w	#4,d3
		lsl.w	#4,d4
		lsl.w	#4,d5


		move.b	d0,(a1)+
		move.b	d1,(a1)+
		move.b	d2,(a1)+
		move.b	d3,(a2)+
		move.b	d4,(a2)+
		move.b	d5,(a2)+

		move.l	a1,d6	;swap which pic should be higher intensity
		move.l	a2,a1
		move.l	d6,a2

		dbra	d7,.tgax
		move.l	a1,d6	;make sure the intensity is uneven on every second line
		move.l	a2,a1
		move.l	d6,a2		
		swap	d7
		dbra	d7,.tgay

lower_part:
		lea.l	orggfx+18+320*3*199,a0
		lea.l	buffer2+18,a1
		lea.l	buffer4+18,a2
		move.w	#199-1,d7
.tgay:		swap	d7
		move.w	#320-1,d7
.tgax:		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		move.b	(a0)+,d2
		lsr.b	#3,d0	;b
		lsr.b	#3,d1	;g
		lsr.b	#3,d2	;r

		btst	#0,d0
		beq.s	.same_b
		cmp.b	#31,d0
		bge.s	.same_b
		lsr.b	#1,d0
		move.b	d0,d3
		addq.b	#1,d3
		bra.s	.b_done
.same_b:	lsr.b	#1,d0
		move.b	d0,d3
.b_done:
		btst	#0,d1
		beq.s	.same_g
		cmp.b	#31,d1
		bge.s	.same_g
		lsr.b	#1,d1
		move.b	d1,d4
		addq.b	#1,d4
		bra.s	.g_done
.same_g:	lsr.b	#1,d1
		move.b	d1,d4
.g_done:
		btst	#0,d2
		beq.s	.same_r
		cmp.b	#31,d2
		bge.s	.same_r
		lsr.b	#1,d2
		move.b	d2,d5
		addq.b	#1,d5
		bra.s	.r_done
.same_r:	lsr.b	#1,d2
		move.b	d2,d5
.r_done:

		lsl.w	#4,d0
		lsl.w	#4,d1
		lsl.w	#4,d2
		lsl.w	#4,d3
		lsl.w	#4,d4
		lsl.w	#4,d5


		move.b	d0,(a1)+
		move.b	d1,(a1)+
		move.b	d2,(a1)+
		move.b	d3,(a2)+
		move.b	d4,(a2)+
		move.b	d5,(a2)+

		move.l	a1,d6	;swap which pic should be higher intensity
		move.l	a2,a1
		move.l	d6,a2

		dbra	d7,.tgax
		move.l	a1,d6	;make sure the intensity is uneven on every second line
		move.l	a2,a1
		move.l	d6,a2		
		swap	d7
		dbra	d7,.tgay


; save first upper screen
file1:
		; fcreate()
		move.w	#0,-(sp)			;Normal file
		move.l	#snap_filename,-(sp)		;Filename address
		move.w	#$3c,-(sp)			;Gemdos #$3c (fcreate)
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,snap_filenum

		; fwrite()
		move.l	#buffer1,-(sp)
		move.l	snap_filesize,-(sp)
		move.w	snap_filenum,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea.l	12(sp),sp

		; fclose()
		move.w	snap_filenum,-(sp)		;close
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp

; save second upper screen
file2:
		; fcreate()
		move.w	#0,-(sp)			;Normal file
		move.l	#snap_filename2,-(sp)		;Filename address
		move.w	#$3c,-(sp)			;Gemdos #$3c (fcreate)
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,snap_filenum

		; fwrite()
		move.l	#buffer2,-(sp)
		move.l	snap_filesize,-(sp)
		move.w	snap_filenum,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea.l	12(sp),sp

		; fclose()
		move.w	snap_filenum,-(sp)		;close
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp


; save first lower screen
file3:
		; fcreate()
		move.w	#0,-(sp)			;Normal file
		move.l	#snap_filename3,-(sp)		;Filename address
		move.w	#$3c,-(sp)			;Gemdos #$3c (fcreate)
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,snap_filenum

		; fwrite()
		move.l	#buffer3,-(sp)
		move.l	snap_filesize,-(sp)
		move.w	snap_filenum,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea.l	12(sp),sp

		; fclose()
		move.w	snap_filenum,-(sp)		;close
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp


; save second lower screen
file4:
		; fcreate()
		move.w	#0,-(sp)			;Normal file
		move.l	#snap_filename4,-(sp)		;Filename address
		move.w	#$3c,-(sp)			;Gemdos #$3c (fcreate)
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,snap_filenum

		; fwrite()
		move.l	#buffer4,-(sp)
		move.l	snap_filesize,-(sp)
		move.w	snap_filenum,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea.l	12(sp),sp

		; fclose()
		move.w	snap_filenum,-(sp)		;close
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp

exit:
		clr.w	-(sp)
		trap	#1


		section	data


orggfx:		incbin	'prot.tga'
		even

		
snap_filesize:	dc.l	size

snap_filename:	dc.b	'1up.tga',0
		even

snap_filename2:	dc.b	'1down.tga',0
		even

snap_filename3:	dc.b	'2up.tga',0
		even

snap_filename4:	dc.b	'2down.tga',0
		even
 


		section	bss
		
tgahead:	ds.b	18

snap_filenum:	ds.w	1

		even
buffer1:	ds.b	size
buffer2:	ds.b	size
buffer3:	ds.b	size
buffer4:	ds.b	size


		section	text
