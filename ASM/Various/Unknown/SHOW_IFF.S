*********************
   SECTION TEXT
*********************

	bsr	set_up

	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp


		move.l	screen_base,a0
		lea	screens,a1
		move.l	#32000/4-1,d0
copyloop	move.l	(a0),(a1)+
		clr.l	(a0)+
		dbf	d0,copyloop

**** write new routine here to get words from plane 1 and make plane 1
;					      plane 2 and make plane 1 + 8
;					      plane 3 and make plane 1 + 16
;					      plane 4 and make plane 1 + 24

		lea	screens,a0
		move.l	screen_base,a1
		move.l	a0,a5
		move.l	a1,a6
		moveq	#0,d3
		moveq	#0,d4

		move.w	#4-1,d7
planeloop	move.l	a5,a0
		move.l	a6,a1
		add.w	d3,a0
		add.w	d4,a1
		move.l	#200-1,d0
fixloop
		rept	20
		move.w	(a0)+,(a1)
		add.w	#8,a1
		endr
		add.w	#120,a0
		dbf	d0,fixloop

		add.w	#40,d3
		add.w	#2,d4
		dbf	d7,planeloop

		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp

		movem.l	oldpal,d0-d7
		movem.l	d0-d7,$ff8240.l


;reset rez back to ST med
;		move.w	#%0000000000101001,-(sp)	;$29
		move.w	original_rez,-(sp)
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp


	bsr	set_user

	clr.w	-(sp)
	trap	#1


set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

set_up		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.w	#-1,-(sp)
		move.w	#$58,-(sp)	;get_original_rez
		trap	#14
		addq.l	#4,sp
		move.w	d0,original_rez

		movem.l	$ff8240.l,d0-d7
		movem.l	d0-d7,oldpal

;Go for LOW ST rez
;
;			  fedcba9876543210
		move.w	#%0000000000100010,-(sp)
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp

		clr.l	$FFFF9800		;256 colour palet starts here


;Where 'mode' looks like this:-
;    bits            meaning
;    0-2             These bits form a value so that 2^X represents the 
;                    number of bits/pixel
;    3               80 coloun flag (if set, 80 columns, otherwise 40)
;    4               VGA Flag (if set, VGA mode, if not TV/RGB mode) 
;    5               PAL Flag (if set, PAL mode, otherwise NTSC)
;    6               Overscan Flag (not valid with VGA)
;    7               ST compatibility flag
;    8               Vertical flag (if set, enables interlace mode on a         
;                    colour monitor or double line mode on a VGA monitor)
;    9-15            Reserved (set 0)                   






;	clr.b	$ffff8260.w
** decode an IFF pic
;********* NOT all IFF pics are in this order.....
		movea.l	screen_base,a1
		lea	pic,a0
		bsr	msd

		movea.l	screen_base,a1
		lea	pic,a0
;		bsr	convertiff
		rts
*--------------------{ Here's the magic routine then: }--------------------*
msd

;		move.l	(a0)+,d0	;'FORM'
;		move.l	(a0)+,d4	;length of file that follows]
;		move.l	(a0)+,d0	;'ILBM'

		lea	pic-2,a0
findbmhd	lea	2(a0),a0
		move.l	(a0),d0
		cmp.l	#"BMHD",d0
		bne.s	 findbmhd

		move.l	(a0)+,d0	;'BMHD'
		move.l	(a0)+,d5	;length of chunk
		move.w	(a0)+,width	;width if pixels
		move.w	(a0)+,height
		move.w	(a0)+,xoffset
		move.w	(a0)+,yoffset
		move.b	(a0)+,nobitplanes
;		move.b	(a0)+,d0	;mask 0=no, 1=impl, 2=transparent, 3=lasso)
;		move.b	(a0)+,d3	;compressed(1) not(0)
;		move.b	(a0)+,d0	;unused
;		move.w	(a0)+,d0	;transparent color (for mask=2)
;		move.b	(a0)+,xaspect	;5=640x200 10=320x200/640x400, 20=320x400
;		move.b	(a0)+,yaspect
;		move.w	(a0)+,pagewidth
;		move.w	(a0)+,pageheight
;		move.l	(a0)+,d0	;'CAMG' amiga viewport mode chunk ID
;		move.l	(a0)+,d0
;		move.l	(a0)+,d0	;bit 11=ham  bit 3=interlaced
;		move.l	(a0)+,d0	;'CMAP'
;		move.l	(a0)+,d0	;length of chunk
;		sub.l	#1,d0
;.loop		move.b	(a0)+,d1
;		dbf	d0,.loop
;		move.l	(a0)+,d0	;'CRNG'
;		move.l	(a0)+,d0	;length of chunk
;		move.l	(a0)+,d0
;		move.l	(a0)+,d0


;***** First find the palette *****
		lea	pic,a0
		lea	$ffff8240.w,a5
findcmap	move.l	(a0),d0
		lea	2(a0),a0
		cmp.l	#"CMAP",d0
		bne.s	 findcmap
		clr.l	d0
		move.w	(a0)+,d0
		move.l	(a0)+,d0

		rept	16
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d0	r
		move.b	(a0)+,d1	g
		move.b	(a0)+,d2	b
		lsl.w	#4,d0
		lsr.w	#4,d2
		lsr.w	#1,d0
		lsr.w	#1,d1
		lsr.w	#1,d2
		or.w	d1,d0
		or.w	d2,d0
		move	d0,(a5)+
		endr

		lea	pic,a0
.getbodyloop	add.w	#2,a0
		cmp.l	#"BODY",(a0)
		bne.s	.getbodyloop
		move.l	(a0)+,d0	;'BODY'
		move.l	(a0)+,d2	;length of chunk
;image follows here...
;;;Data compression:
;;; 
;;;   Compression is via a modified run length encoding (RLE) scheme,
;;;similar to DEGAS compressed and Tiny.  The data map is stored as a
;;;sequence of records.  Each record consists of a header byte followed by
;;;one or more data bytes.  The meaning of the header byte is as follows:
 
;;;        For a given header byte, x:
 
;;;           0 <= x <= 127   Use the next x + 1 bytes literally (no repetition)
;;;        -128 <= x <=  -1   Use the next byte -x + 2 times
 
;;;The data appears in the following order:
 
;;;        1. Picture data, bit plane 0, scan lines 1 - 199
;;;        2. Picture data, bit plane 1, scan lines 1 - 199
;;;        3. Picture data, bit plane 2, scan lines 1 - 199
;;;        4. Picture data, bit plane 3, scan lines 1 - 199
 
;;;Decompression of data ends when 31840 data bytes have been used.


decode		movem.l	d0-d7/a0-a6,-(sp)	save all reggies
		move.l	#31999,d2		maximum screen size
		moveq	#0,d3
loop0		moveq	#0,d0		clean d0
		move.b	(a0)+,d0
		btst	#7,d0
		beq.s	not_comp

compressed	not.b	d0		invert d0.b
		addq	#1,d0
		move.b	(a0)+,d1
loop1		move.b	d1,(a1)+
		subq	#1,d2
		bmi.s	exit_comp
		dbra	d0,loop1
		bra.s	loop0
not_comp	move.b	(a0)+,(a1)+
		subq	#1,d2
		bmi.s	exit_comp
		dbra	d0,not_comp
		bra.s	loop0
exit_comp	movem.l	(sp)+,d0-d7/a0-a6
		rts





*******************
   SECTION DATA
*******************
pic	incbin	"h:\iff\magnetic.iff"
	;incbin	"fair2.iff"
	;incbin	pov_mac6.iff


*******************
   SECTION BSS
*******************
pic_pos		ds.l	1
pic_length	ds.l	1
pal_pos1	ds.l	1
pal_pos2	ds.l	1


stack_save	ds.l	1
screen_base	ds.l	1
original_rez	ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1
width		ds.w	1
height		ds.w	1
xoffset		ds.w	1
yoffset		ds.w	1
pagewidth	ds.w	1
pageheight	ds.w	1
nobitplanes	ds.b	1
xaspect		ds.b	1
yaspect		ds.b	1
		even
oldpal		ds.w	16

		ds.b	256
screens		ds.b	32000
		ds.b	32000

