; Tga library

max_x		=	320	; Maximum size of the
max_y		=	480	; image

; Tga header structure
		rsreset
tga		rs.b	2
tga.imagetype	rs.w	5	; type of image 2=rgb
tga.width	rs.w	1	; Image width in pixels
tga.height	rs.w	1	; Image height in pixels
tga.bits	rs.b	2	; Image bits per pixel
tga.header	=	__RS

	
;==============================
;=
;=  LoadTga
;=
;= Load a a tga file. Check if it's
;= an uncompressed 24bit rgb file
;= and if its size keeps ths range
;= after having loaded the header.
;=
;= TgaFileName->name of the file
;==============================

		section	text
LoadTga		lea.l	.message(pc),a0	; Write message
		bsr.w	writeln

		movea.l	TgaFileName(pc),a0
		bsr.w	writeln


; Load file header

		clr.w	-(sp)		; Open file (read only)
		move.l	TgaFileName(pc),-(sp)
		move.w	#$3d,-(sp)	; Fopen()
		trap	#1
		addq.l	#8,sp

		tst.l	d0
		bpl.s	.ok1		; File not found?

		lea.l	.error1(pc),a0	; Output error message
		bra.w	error		; and exit

.ok1		move.w	d0,.handle

		lea.l	.header(pc),a3
		pea.l	(a3)		; Try to read header
		pea.l	tga.header.w
		move.w	d0,-(sp)
		move.w	#$3f,-(sp)	; Fread()
		trap	#1
		lea.l	12(sp),sp
	
		cmpi.w	#tga.header,d0
		beq.s	.ok2		; File corrupt?

		lea.l	.error2(pc),a0
		bra.w	error


; Check filetype, color depth and image size
; weird but way shorter than a hardcoded version


.ok2		lea.l	.check_table(pc),a4

		moveq.l	#4-1,d6		; 4 points to check

.check		movea.l	(a4)+,a0	; Address to string
		bsr.w	writeln

		movem.l	(a4)+,d0-d1/a0-a1; Index/limit/error string/compare rout
		jsr	(a1)		 ; Compare and branch

.no_error	lea.l	.ok(pc),a0	; Write 'ok.'
		bsr.w	writeln

		dbra	d6,.check


; Everything seems to have gone well, load and convert image data, now
; (slow as hell, but runs on 512k machines)
	
		lea.l	.loadimage(pc),a0
		bsr.w	writeln
	
		lea.l	Tga.picture(pc),a2
		movea.l	(a2)+,a0	; Destination

		move.w	tga.height(a3),d6
		subq.w	#1,d6
				
		move.w	d6,d7
		muls.w	#160,d7
		lea.l	(a0,d7.l),a5	; Pointer to bottom
		lea.l	-199*160(a5),a1	; Lower address limit (bottom-(160*screenheight-1))

		movem.l	a0/a1,(a2)	; Store address limits for
					; hardware scrolling

		
.rows		lea.l	TgaLoadBuffer(pc),a4

		pea.l	(a4)		; Read one row
		movea.w	tga.width(a3),a6
		adda.w	a6,a6
		adda.w	tga.width(a3),a6
		pea.l	(a6)		; Image width*3 (r,g,b)
		
		move.w	.handle(pc),-(sp)
		move.w	#$3f,-(sp)	; Fread()
		trap	#1
		lea.l	12(sp),sp

		tst.l	d0
		bne.s	.ok3		; File corrupt?

		lea.l	.error2(pc),a0
		bra.w	error

.ok3
		moveq.l	#max_x/16-1,d7	; Convert one row
.blocks		lea.l	2(a4),a0	; Red channel
		movea.l	a5,a1
		bsr.w	c2p
		movea.l	a1,a5
		
		lea.l	1(a4),a0	; Green channel
		adda.l	#max_x*max_y/2-8,a1
		bsr.w	c2p
		
		movea.l	a4,a0		; Blue channel
		adda.l	#max_x*max_y/2-8,a1
		bsr.w	c2p
		
		movea.l	a0,a4		; Save current buffer position
		dbra	d7,.blocks	; next block
		
		lea.l	-320(a5),a5	; Walk upwards (vertical flip)
		dbra	d6,.rows


		lea.l	.ok(pc),a0
		bsr.w	writeln
	

; Close file

		move.w	.handle(pc),-(sp)
		move.w	#$3e,-(sp)	; Fclose()
		trap	#1
		addq.l	#4,sp

		lea.l	hitakey(pc),a0
		bsr.w	writeln
		bra.w	waitkey


; Checktable used for header parsing

.check_table	dc.l	.type,tga.imagetype,2,.invalid,.cmp.b_bne.s
		dc.l	.depth,tga.bits,24,.invalid,.cmp.b_bne.s
		dc.l	.width,tga.width,max_x,.invalid,.cmp.w_blt.s
		dc.l	.height,tga.height,max_y,.invalid,.cmp.w_blt.s


.cmp.b_bne.s	cmp.b	(a3,d0.l),d1	; Adaptive comparism and branch
		bne.w	error		; (cache friendly)
		rts
		
.cmp.w_blt.s	move.w	(a3,d0.l),d2
		ror.w	#8,d2		; Force motorola byte order!
		move.w	d2,(a3,d0.l)
		cmp.w	d2,d1
		blt.w	error
		rts
		
;------------------------------------------------------------------------------
		section	data
.message	dc.b	27,'E',27,'p TGA viewer       ¾ by ray//.tSCc. 2002 '
		dc.b	13,10,27,'qLoading: ',0
.type		dc.b	13,10,'File type: ',0
.depth		dc.b	'Color depth: ',0
.width		dc.b	'Width: ',0
.height		dc.b	'Height: ',0
.loadimage	dc.b	'Reading image: ',0
.ok		dc.b	'ok.',13,10,0

.error1		dc.b	13,10,'Bad filename. ',0
.error2		dc.b	13,10,'File is corrupt. ',0
.invalid	dc.b	'invalid.',13,10,0
		even
;------------------------------------------------------------------------------
		section	bss
.header		ds.b	tga.header	; Space for the header
.handle		ds.w	1
TgaFileName	ds.l	1		; Pointer to file name

		section	text
error		bsr.w	writeln		; Write error message and exit
		lea.l	hitakey(pc),a0
		bsr.w	writeln
		bsr.w	waitkey
		
		addq.l	#4,sp		; Kill return address
		bra.w	exit

hitakey		dc.b	'Hit a key.',13,10,0
		even