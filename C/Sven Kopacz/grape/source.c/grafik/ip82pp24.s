;8Bit Interleaved Bitplane converting to 24 Bit Single PixelPacked
;Byte Planes

;To convert 8Bit Interleaved to 8Bit Pixelpacked:
;Set src to Sourceadress of First Bitplane (=Lowest Bit!)
;Set add_src to Offset (in Byte) to next Bitplane
;Set add_pix to the numbers of NOT TOTALLY USED BYTES per line.
;e.g. if the line ends like this: 0000 0xxx set add_pix to 1
;Set dbuf to start of destination buffer. Line offsets not allowed!
;Set hi to the Height in Pixels
;Set wi to the Width in Pixels
;Set amode to 0 if the following Bitplanes are BEHIND the first
;Set amote to 1 if the following Bitplanes are BEFORE the first
;So if your Interleaved Planes in memory start with the least Bit,
;amode is 0, if they start with the most bit, amode is 1 AND src
;must be the adress of the LAST plane in memory
;For every next Bitplane, add_src will be added/subed from src
;Now call ip82pp24()

;To copy 8Bit pp to 24Bit Byteplane pp:
;Set dbuf to Adress of Source-Buffer
;Set hi to height in Pixels(=Bytes)
;Set wi to width in Pixels(=Bytes)
;Set cpal to the adress of the first cpal-entry. cpal must be stored
;in memory like this: C0 M0 Y0 C1 M1 Y1 ...
;Set cp, mp, yp to the adresses of the destination planes
;Set add_buf to the line offset for the source
;Set add_dest to the line offset for the dest
;Now call pp82pp24()


.MC68020
.EXPORT src, add_src, dbuf, hi, wi, add_pix, cpal, cp, mp, yp, amode
.EXPORT add_buf, add_dest
.EXPORT ip82pp24,pp82pp24

src:
	.DS.L 1
add_src:
	.DS.L 1
add_pix:
	.DS.W 1
dbuf:
	.DS.L 1
hi:
	.DS.W 1
wi:
	.DS.W 1
amode:
	.DS.W 1

;Fields for Copying pp8 to pp24 via pal	
cpal:
	.DS.L 1
cp:
	.DS.L 1
mp:
	.DS.L 1
yp:
	.DS.L 1
add_buf:
	.DS.L	1
add_dest:
	.DS.L 1

ip82pp24:
	movem.l	d0-d7/a0-a6,-(sp)

;Hi und Wi vorbereiten
	move.w	#1,d0
	sub.w		d0,hi
	sub.w		d0,wi
	
;Register vorbereiten
	move.l	src,a0				;Sourceadresse erste Bitplane
	move.l	add_src,a2		;Offset zur n„chsten (Gr”že der Planes)
	move.w	add_pix,d6		;Offset in BYTES zwischen Bitzeilen
												;(=total_wid - used_wid + 7)/8
	ext.l		d6
	moveq.l	#0,d0					;Bitcount
	move.w	wi,d7					;Nicht aus Speicher holen

	moveq.l	#1,d1		;Set-Bit

;{
loop8:
	move.l	dbuf,a1	;Zieladresse
	moveq.l	#0,d2		;Aktueller Pixel
	
	move.w	hi,d3		;Y-Count

;{{
loopy:
	move.w	d7,d4		;X-Count
	moveq.l	#7,d5		;Testbit

;{{{
loopx:
	btst		d5.b,(a0,d2.l)	;Pixel gesetzt?
	beq			not_set
	or.b		d1,(a1)					;Bit im Buffer setzen
not_set:
	addq.l	#1,a1						;Bufferadresse+1
	subq.l	#1,d5						;Testbit nach rechts schieben
	bpl			not_out					;Noch nicht rausgeschoben
	moveq.l	#7,d5						;Sonst wieder oberstes setzen
	addq.l	#1,d2						;Und Bytez„hler erh”hen
not_out:
	dbra		d4,loopx
;}}}
	add.l		d6,d2						;Pixelbyte-Offset auf Bytez„hler addieren
	dbra		d3,loopy
;}}
	tst.w		amode						;Abziehen oder addieren?
	beq			add_it
	suba.l	a2,a0						;Abziehen
	bra.s		next_bit
add_it:
	adda.l	a2,a0
next_bit:
	lsl.b		#1,d1				;Set-Bit
	addq.l	#1,d0
	cmp.w		#8,d0
	bne			loop8
;}

	movem.l	(sp)+,d0-d7/a0-a6
	rts
	
;*******************************************************
	
pp82pp24:
;Copy PixelPacked 8 Bit-Plane via colorpalette to 24Bit PixelPacked
;Byte Planes
	movem.l	d0-d5/a0-a4,-(sp)

;Register vorbereiten
	move.w	#1,d0				;dbar arbeitet mit -1, deshalb hi/wi je -1
	sub.w		d0,hi
	sub.w		d0,wi
	
	move.l	dbuf,a0			;Quelleebene 8Byte pp
	move.l	add_buf,d4	;Zeilenoffset
	move.l	cp,a1				;Zielebenen
	move.l	mp,a2
	move.l	yp,a3
	move.l	add_dest,d5 ;Zeilenoffset

	move.l	cpal,a4	;Colorpalette
	
	move.w	wi,d2		;X-Count	
	move.w	hi,d0		;Y-Count

;{
cloopy:
	move.w	d2,d1		;X-Count
;{{
cloopx:
	moveq.l	#0,d3
	move.b	(a0)+,d3					;Quellbyte holen
	mulu.w	#3,d3							;Palettenindex berechnen
	move.b	(a4,d3.w),(a1)+		;
	move.b	1(a4,d3.w),(a2)+
	move.b	2(a4,d3.w),(a3)+
	dbra		d1,cloopx
;}}
	adda.l	d4,a0
	adda.l	d5,a1
	adda.l	d5,a2
	adda.l	d5,a3
	dbra		d0,cloopy
;}
	
	movem.l	(sp)+,d0-d5/a0-a4
	rts
