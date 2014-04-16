; convert targa to scanline datas

x:		equ	208
y:		equ	273
frames:		equ	100
size:		equ	y*frames

		comment HEAD=%111

		opt	p=68030/68882

		output	.tos

		section	text
start:

		lea.l	buffer,a1

.frame:
		lea.l	filenames,a0
		add.l	filename_pos,a0
		add.l	#14,filename_pos
		move.l	a0,filename
		jsr	loader

		lea.l	tga+18,a0
		move.l	a0,a6
		
		move.w	#y-1,d7
.y:		move.w	#x-1,d6
		clr.w	.xcount
.x:
		moveq.l	#0,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		moveq.l	#0,d4
		moveq.l	#0,d5
	

		;get 24bit pixel
		move.b	(a0)+,d2			;b
		move.b	(a0)+,d1			;g
		move.b	(a0)+,d0			;r

		;if the colour is black (no gfx found), increase counter and goto next pixel
		move.b	d0,d3
		lsl.w	#8,d3
		move.b	d1,d3
		lsl.l	#8,d3
		move.b	d2,d3
		tst.l	d3
		bne.s	.scanline_done
		addq.b	#1,.xcount
		dbra	d6,.x

		;if we get here, all pixels in this scanline was empty
		;force last scanline and goto next scanline
		move.b	#208,.xcount


.scanline_done:
		subq.b	#1,.xcount
		move.b	.xcount,(a1)+			;store scanline number

		lea.l	416*3(a6),a6			;next tga line
		move.l	a6,a0
		dbra	d7,.y

		subq.w	#1,.frames
		bpl.w	.frame


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

.filepos:	dc.l	0
.palpos:	dc.w	0
.xcount:	dc.w	0
.frames:	dc.w	frames-1

tgaload:	move.l	filename,-(sp)
		move.w	#9,-(sp)				;print tos text
		trap	#1					;input: move.l #mytextadr,textadr
		addq.l	#6,sp					;
		pea	.t
		move.w	#9,-(sp)				;print tos text
		trap	#1					;input: move.l #mytextadr,textadr
		addq.l	#6,sp					;
		rts
.t:		dc.b	' loaded',13,10,0
		even
palentry:	pea	.t
		move.w	#9,-(sp)				;print tos text
		trap	#1					;input: move.l #mytextadr,textadr
		addq.l	#6,sp					;
		rts
.t:		dc.b	'Palette entry added',13,10,0
		even

		
loader:
;in filename.l=address to filename
		move.w	#0,-(sp)				;open file read only
		move.l	filename,-(sp)				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,filenumber				;store filenumber
 
		move.l	#tga,-(sp)				;buffer address
		move.l	#416*273*3+18,-(sp)			;length of file
		move.w	filenumber,-(sp)			;filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea.l	12(sp),sp				;

		move.w	filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;

		rts



		section	data


filenames:
		dc.b	'vec20000.tga',0,0
		dc.b	'vec20001.tga',0,0
		dc.b	'vec20002.tga',0,0
		dc.b	'vec20003.tga',0,0
		dc.b	'vec20004.tga',0,0
		dc.b	'vec20005.tga',0,0
		dc.b	'vec20006.tga',0,0
		dc.b	'vec20007.tga',0,0
		dc.b	'vec20008.tga',0,0
		dc.b	'vec20009.tga',0,0

		dc.b	'vec20010.tga',0,0
		dc.b	'vec20011.tga',0,0
		dc.b	'vec20012.tga',0,0
		dc.b	'vec20013.tga',0,0
		dc.b	'vec20014.tga',0,0
		dc.b	'vec20015.tga',0,0
		dc.b	'vec20016.tga',0,0
		dc.b	'vec20017.tga',0,0
		dc.b	'vec20018.tga',0,0
		dc.b	'vec20019.tga',0,0

		dc.b	'vec20020.tga',0,0
		dc.b	'vec20021.tga',0,0
		dc.b	'vec20022.tga',0,0
		dc.b	'vec20023.tga',0,0
		dc.b	'vec20024.tga',0,0
		dc.b	'vec20025.tga',0,0
		dc.b	'vec20026.tga',0,0
		dc.b	'vec20027.tga',0,0
		dc.b	'vec20028.tga',0,0
		dc.b	'vec20029.tga',0,0

		dc.b	'vec20030.tga',0,0
		dc.b	'vec20031.tga',0,0
		dc.b	'vec20032.tga',0,0
		dc.b	'vec20033.tga',0,0
		dc.b	'vec20034.tga',0,0
		dc.b	'vec20035.tga',0,0
		dc.b	'vec20036.tga',0,0
		dc.b	'vec20037.tga',0,0
		dc.b	'vec20038.tga',0,0
		dc.b	'vec20039.tga',0,0

		dc.b	'vec20040.tga',0,0
		dc.b	'vec20041.tga',0,0
		dc.b	'vec20042.tga',0,0
		dc.b	'vec20043.tga',0,0
		dc.b	'vec20044.tga',0,0
		dc.b	'vec20045.tga',0,0
		dc.b	'vec20046.tga',0,0
		dc.b	'vec20047.tga',0,0
		dc.b	'vec20048.tga',0,0
		dc.b	'vec20049.tga',0,0

		dc.b	'vec20050.tga',0,0
		dc.b	'vec20051.tga',0,0
		dc.b	'vec20052.tga',0,0
		dc.b	'vec20053.tga',0,0
		dc.b	'vec20054.tga',0,0
		dc.b	'vec20055.tga',0,0
		dc.b	'vec20056.tga',0,0
		dc.b	'vec20057.tga',0,0
		dc.b	'vec20058.tga',0,0
		dc.b	'vec20059.tga',0,0

		dc.b	'vec20060.tga',0,0
		dc.b	'vec20061.tga',0,0
		dc.b	'vec20062.tga',0,0
		dc.b	'vec20063.tga',0,0
		dc.b	'vec20064.tga',0,0
		dc.b	'vec20065.tga',0,0
		dc.b	'vec20066.tga',0,0
		dc.b	'vec20067.tga',0,0
		dc.b	'vec20068.tga',0,0
		dc.b	'vec20069.tga',0,0

		dc.b	'vec20070.tga',0,0
		dc.b	'vec20071.tga',0,0
		dc.b	'vec20072.tga',0,0
		dc.b	'vec20073.tga',0,0
		dc.b	'vec20074.tga',0,0
		dc.b	'vec20075.tga',0,0
		dc.b	'vec20076.tga',0,0
		dc.b	'vec20077.tga',0,0
		dc.b	'vec20078.tga',0,0
		dc.b	'vec20079.tga',0,0

		dc.b	'vec20080.tga',0,0
		dc.b	'vec20081.tga',0,0
		dc.b	'vec20082.tga',0,0
		dc.b	'vec20083.tga',0,0
		dc.b	'vec20084.tga',0,0
		dc.b	'vec20085.tga',0,0
		dc.b	'vec20086.tga',0,0
		dc.b	'vec20087.tga',0,0
		dc.b	'vec20088.tga',0,0
		dc.b	'vec20089.tga',0,0

		dc.b	'vec20090.tga',0,0
		dc.b	'vec20091.tga',0,0
		dc.b	'vec20092.tga',0,0
		dc.b	'vec20093.tga',0,0
		dc.b	'vec20094.tga',0,0
		dc.b	'vec20095.tga',0,0
		dc.b	'vec20096.tga',0,0
		dc.b	'vec20097.tga',0,0
		dc.b	'vec20098.tga',0,0
		dc.b	'vec20099.tga',0,0

filename_pos:	dc.l	0
		
snap_filesize:	dc.l	size

snap_filename:	dc.b	'vec2.bin',0
		even
 

		section	bss

filename:	ds.l	1
filenumber:
snap_filenum:	ds.w	1

tga:		ds.b	416*273*3+18
buffer:		ds.b	size

		section	text
