* GIF-loader (pessimized version)
* by Lars Brinkhoff 910818.
* Original LZW depacking from GIFCOL.C.
		
		bsr	init
		bsr	main
		bra	exit
		
main		lea	gif,a6
		
gif_sign	* The GIF signature.
		cmp.l	#"GIF8",(a6)+		* GIF87a = GIF signature.
		bne	exit
		cmp.w	#"7a",(a6)+
		bne	exit
		
screen_descr	* The screen descriptor.
		bsr	getword			* Screen width.
		move.w	d0,width
		bsr	getword			* Screen height.
		move.w	d0,height
		move.b	(a6)+,d0		* Global color map, color rez, bitplanes.
		btst.l	#7,d0			* Global color map?
		sne	cmap
		move.b	d0,d1			* Color rez.
		lsr.w	#4,d1
		and.b	#7,d1
		addq.b	#1,d1
		move.b	d1,colrez
		move.b	d0,d1			* Bitplanes.
		and.b	#7,d1
		addq.b	#1,d1
		move.b	d1,bitpl
		move.b	(a6)+,d0		* Background color (ignored).
		move.b	(a6)+,d0		* Reserved.
		
		move.w	width,d0
.1		cmp.w	#320,d0
		ble	.2
		addq.w	#1,shift
		lsr.w	#1,d0
		bra	.1
.2		moveq	#0,d1
		move.w	height,d0
.3		cmp.w	#200,d0
		ble	.4
		addq.w	#1,d1
		lsr.w	#1,d0
		bra	.3
.4		cmp.w	shift,d1
		blt	.5
		move.w	d1,shift
.5		
global_cmap	* The global color map.
		tst.b	cmap
		beq	image_descr
		moveq	#1,d0
		moveq	#0,d1
		move.b	bitpl,d1
		lsl.w	d1,d0
		subq.w	#1,d0
		moveq	#15,d2
		move.l	#765,d3
		moveq	#0,d4
		lea	ctab,a0
.loop		moveq	#0,d1
		move.b	(a6)+,d1		* Read R intensity
		move.b	(a6)+,d4
		add.w	d4,d1			* Add G intensity
		move.b	(a6)+,d4
		add.w	d4,d1			* Add B intensity
		mulu	d2,d1
		add.l	#380,d1
		divu	d3,d1
		move.b	d1,(a0)+
		dbra	d0,.loop
		
image_descr	* The image descriptor.
		cmp.b	#",",(a6)+
		bne	exit
		bsr	getword			* Image left (ignored).
		bsr	getword			* Image top (ignored).
		bsr	getword			* Image width (ignored).
		bsr	getword			* Image height (ignored).
		move.b	(a6)+,d0		* Local color map, interlace, bitplanes.
		btst.l	#7,d0			* Local color map?
		bne	exit
		btst.l	#6,d0			* Interlaced?
		bne	exit
		
raster_data	* The raster data.
unblock		* Unblock the raster data.
		lea	1(a6),a0
		lea	1(a6),a1
.loop1		moveq	#0,d0
		move.b	(a0)+,d0
		beq	.finished
		subq.w	#1,d0
.loop2		move.b	(a0)+,(a1)+
		dbra	d0,.loop2
		bra.s	.loop1
.finished	
		
depack		* Depack the LZW codes.
		moveq	#0,d0
		move.b	(a6)+,d0		* Code size - 1.
		move.w	d0,codesize
		addq.w	#1,codesize
		move.w	codesize,initcodesize
		move.w	d0,d1
		
		moveq	#1,d0
		lsl.w	d1,d0			* Clear code.
		move.w	d0,.check_clear+2
		addq.w	#1,d0			* EOF code.
		move.w	d0,.check_eof+2
		addq.w	#1,d0			* First free code.
		move.w	d0,firstfree
		move.w	d0,freecode		* Current free code.
		
		moveq	#1,d0
		move.w	codesize,d1
		lsl.w	d1,d0
		move.w	d0,maxcode		* Max code.
		move.w	d0,initmaxcode
		subq.w	#1,d0
		move.w	d0,codemask		* Code mask.
		
		moveq	#1,d0
		move.b	bitpl,d1
		lsl.w	d1,d0
		subq.w	#1,d0
		move.w	d0,datamask		* Data mask.
		
		move.l	#0,bitbuf
		move.w	#0,blen
		
		lea	outcode,a0
		lea	suffix,a1
		lea	prefix,a2
		moveq	#0,d7
		
.loop		bsr	getcode			* Get the next code.
.check_eof	cmp.w	#0,d7			* Is it an EOF code?
		beq	.finished		* Exit depacking if so.
.check_clear	cmp.w	#0,d7			* Is it a clear code.
		bne	.not_clearcode
		move.w	initcodesize,codesize	* Reset to initial state.
		move.w	initmaxcode,maxcode
		move.w	firstfree,freecode
		move.w	maxcode,codemask
		subq.w	#1,codemask
		bsr	getcode			* Treat next code as raw data.
		move.w	d7,oldcode
		move.w	d7,d0
		and.w	datamask,d0
		move.b	d0,data
		bsr	set_dot
		bra.s	.loop
.not_clearcode	move.w	d7,.newold+2
		cmp.w	freecode,d7		* If greater or equal to freecode,
		blt.s	.1			*  not in the hash table yet; repeat
		move.w	oldcode,d7		*  the last data code decoded.
		move.b	data,(a0)+
.1		cmp.w	datamask,d7		* If greater than datamask, the code
		ble.s	.2			*  points to a chain of data codes
		move.b	0(a1,d7.w),(a0)+	*  to be output in a LIFO queue.
		add.w	d7,d7
		move.w	0(a2,d7.w),d7
		bra.s	.1
.2		move.w	d7,d0			* The last code is raw data.
		and.w	datamask,d0
		move.b	d0,data
		move.b	d0,(a0)+
		
		lea	outcode,a3		* Now we put the data out
		moveq	#0,d0			*  to the using routine.
.plot		move.b	-(a0),d0
		bsr	set_dot
		cmp.l	a3,a0
		bne.s	.plot
		
		lea	outcode,a0		* Pointer back to start of queue.
		
		move.w	freecode,d0		* Build the hash table on-the-fly.
		move.w	d0,d1			*  No table is stored in the file.
		add.w	d1,d1
		move.b	data,0(a1,d0.w)
		move.w	oldcode,0(a2,d1.w)
.newold		move.w	#0,oldcode
		addq.w	#1,freecode		* Point to the next slot in the
		move.w	freecode,d0		*  table. If we exceed the current
		cmp.w	maxcode,d0		*  maxcode, increment the code size
		bne.s	.no			*  unless it's already 12. If it is,
		move.w	codesize,d0		*  do nothing: the next code decompressed
		cmp.w	#12,d0			*  better be CLEAR.
		beq.s	.no
		addq.w	#1,codesize
		move.w	maxcode,d0
		add.w	d0,d0
		move.w	d0,maxcode
		subq.w	#1,d0
		move.w	d0,codemask
.no		bra	.loop		
.finished		
		rts
		
init		clr.l	-(sp)			* Supervisor mode.
		move.w	#$20,-(sp)
		trap	#1
		addq.w	#6,sp
		move.l	d0,oldsp+2
		
		move.w	#37,-(sp)		* Vsync and lorez.
		trap	#14
		addq.w	#2,sp
		move.w	#0,$ff8260
		
		movem.l	pal,d0-d7		* Install palette.
		movem.l	d0-d7,$ff8240
		
		rts
		
exit		move.w	#1,-(sp)		* Wait for key.
		trap	#1
		addq.w	#2,sp
		
		move.w	#-1,$ff8240		* Restore palette (?).
		move.w	#0,$ff8246
		
oldsp		pea	0			* User mode.
		move.w	#$20,-(sp)
		trap	#1
		addq.w	#6,sp
		
		clr.w	-(sp)
		trap	#1
	
getword		move.w	d1,-(sp)		* Get a Intel-fomat
		move.b	(a6)+,d1		*  word from the file.
		move.b	(a6)+,d0
		lsl.w	#8,d0
		move.b	d1,d0
		move.w	(sp)+,d1
		rts
		
getcode						* Get the next code in
.1		move.w	blen,d0			*  the file.
		cmp.w	codesize,d0
		bge.s	.2
		moveq	#0,d1
		move.b	(a6)+,d1
		lsl.l	d0,d1
		add.l	d1,bitbuf
		addq.w	#8,blen
		bra.s	.1
.2		move.l	bitbuf,d7
		and.w	codemask,d7
		move.l	bitbuf,d0
		move.w	codesize,d1
		lsr.l	d1,d0
		move.l	d0,bitbuf
		sub.w	d1,blen
		rts
		
set_dot		* Set a dot with color d0.
		move.l	a0,-(sp)
		lea	ctab,a0
		move.b	0(a0,d0.w),d2
		
		move.w	shift,d1
		move.l	$44e,a0
		move.w	y,d0
		lsr.w	d1,d0
		cmp.w	#199,d0
		bgt	.8
		muls	#160,d0			* Pessimized...
		add.w	d0,a0
		move.w	x,d0
		lsr.w	d1,d0
		cmp.w	#319,d0
		bgt	.8
		move.w	d0,d1
		and.w	#$fff0,d0
		lsr.w	#1,d0
		add.w	d0,a0
		and.w	#$f,d1
		eor.w	#$f,d1
		moveq	#0,d0
		bset.l	d1,d0
		move.w	d0,d1
		not.w	d1
		
		btst.l	#0,d2
		beq.s	.1
		or.w	d0,(a0)+
		bra.s	.2
.1		and.w	d1,(a0)+
.2		btst.l	#1,d2
		beq.s	.3
		or.w	d0,(a0)+
		bra.s	.4
.3		and.w	d1,(a0)+
.4		btst.l	#2,d2
		beq.s	.5
		or.w	d0,(a0)+
		bra.s	.6
.5		and.w	d1,(a0)+
.6		btst.l	#3,d2
		beq.s	.7
		or.w	d0,(a0)+
		bra.s	.8
.7		and.w	d1,(a0)+
.8		
		addq.w	#1,x
		move.w	width,d0
		cmp.w	x,d0
		bne.s	.9
		clr.w	x
		addq.w	#1,y
.9		
		move.l	(sp)+,a0
		rts
		
pal		dc.w	$000,$888,$111,$999,$222,$aaa,$333,$bbb
		dc.w	$444,$ccc,$555,$ddd,$666,$eee,$777,$fff
width		dc.w	0
height		dc.w	0
cmap		dc.b	0
colrez		dc.b	0
bitpl		dc.b	0,0
ctab		ds.b	256
outcode		ds.b	4096
suffix		ds.b	4096
prefix		ds.w	4096
codesize	ds.w	1
initcodesize	ds.w	1
firstfree	ds.w	1
freecode	ds.w	1
maxcode		ds.w	1
initmaxcode	ds.w	1
oldcode		ds.w	1
codemask	ds.w	1
datamask	ds.w	1
data		ds.w	1
bitbuf		ds.l	1
blen		ds.w	1
x		dc.w	0
y		dc.w	0
shift		dc.w	0
gif		incbin	a:\starwars.gif
