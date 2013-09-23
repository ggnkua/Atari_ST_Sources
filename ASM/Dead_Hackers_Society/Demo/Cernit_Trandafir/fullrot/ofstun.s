; Create ofsmap
;
; Output
; byte:byte ofsmap scrambled order to fit movem ofsmap routine

width:		equ	160
height:		equ	100

size:		equ	104*68*2


		comment HEAD=%111
		opt	p=68040/68882

		output	.tos

start:
		fmove.s	#0,fp5
		fmove.s	#0,fp6
		lea.l	buffer2,a0

		move.w	#height-1,d6	;y
.y:		move.w	#width-1,d7	;x
.x:
		fmove.w	d7,fp0		;x
		fsub.s	#80,fp0	;x/2
		fmove.w	d6,fp1		;y
		fsub.s	#50,fp1	;y/2
		fmove	fp0,fp2		;x
		fmove	fp1,fp3		;y
		fdiv	fp2,fp3		;y/x
		fatan	fp3,fp2		;atan(y/x)

		fmove	fp2,fp4		;
		fmul	fp5,fp4		;
		fsin	fp4,fp4		;sin(v)
		fmul	fp6,fp4		;

		fmul.s	#82,fp2		;v=128*atan(y/x)
		fmove.l	fp2,d0
		move.b	d0,(a0)+
		fmul	fp0,fp0		;x*x
		fmul	fp1,fp1		;y*y
		fadd	fp0,fp1		;x*x+y*y
		fsqrt	fp1,fp1		;r=sqrt(x*x+y*y)

		fadd	fp4,fp1 	;

		fmove.s	#10000,fp0		;#4000,fp0
		fsub.s	#5,fp1
		fdiv	fp1,fp0
		fmove.l	fp0,d0
		move.b	d0,(a0)+
		dbra	d7,.x
		dbra	d6,.y



		lea.l	buffer2,a0
		lea.l	buffer,a1
		lea.l	buffer+52*68*1,a2
		lea.l	buffer+52*68*2,a3
		lea.l	buffer+52*68*3,a4
		move.w	#68-1,d7
.scramble:
		rept	26
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a2)+
		move.w	(a0)+,(a3)+
		move.w	(a0)+,(a4)+
		endr

		lea.l	320-208(a0),a0

		dbra	d7,.scramble


		; fcreate()
		move.w	#0,-(sp)			;Normal file
		move.l	#snap_filename,-(sp)		;Filename address
		move.w	#$3c,-(sp)			;Gemdos #$3c (fcreate)
		trap	#1				;
		addq.l	#8,sp				;
		move.w	d0,snap_filenum

		; fwrite()
		move.l	#buffer,-(sp)
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

		clr.w	-(sp)
		trap	#1


		section	data


snap_filesize:	dc.l	size

snap_filename:	dc.b	'tunnel.ofs',0
		even
 


		section	bss

snap_filenum:	ds.w	1

buffer:		ds.b	size
buffer2:	ds.b	160*50*2
		even

		section	text
