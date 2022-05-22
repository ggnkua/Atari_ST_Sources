;------------------------;
; 3d demo screen by Russ ;
;------------------------;

demo		equ 0

		opt	o+,ow-

		section TEXT
;
; equates for starfield and stuff
;

numstars	equ	50		;number of stars
randnum 	equ	8192		;size of random lookup table
sxmax		equ	320		;
symax		equ	198		;starfield rectangle
smidx		equ	160-1		;
smidy		equ	100-1		;
;
height		equ	31		;24 lines
width		equ	2		;width in blocks
nextline	equ	160		;line length in bytes
row		equ	200		;scroll row number
nextchar	equ	(width+1)*(height+1)*8
nblocks 	equ	7		;number of 16 pixel blocks
;
stacksize	equ	1024		;1k for stack

;
; OBJECT DEFINITION
;
		rsreset
ob_next 	rs.l	1		;link to next shape
ob_lptr 	rs.l	1		;left and right
ob_rptr 	rs.l	1		;pointers for sort
ob_depth	rs.w	1		;max depth away
ob_wxyz 	rs.l	3		;world position
ob_uxyz 	rs.l	3		;user view position
ob_angxyz	rs.l	3		;object rotation
ob_matrix	rs.w	9		;3x3 rotation matrix
ob_shape	rs.l	1		;pointer to shape
ob_draw 	rs.l	1		;draw routine
ob_cat		rs.w	1		;object category
ob_flags	rs.w	1		;misc flags
i_ptr		rs.l	1
i_size		rs.b	1

		rsreset
ipos.x		rs.l	1
ipos.y		rs.l	1
ipos.z		rs.l	1
ipos.ax		rs.l	1
ipos.ay		rs.l	1
ipos.az		rs.l	1
ipos.size	rs.b	1

		rsreset
movcount	rs.w	1
movdx		rs.l	1
movdy		rs.l	1
movdz		rs.l	1
angcount	rs.w	1
angdx		rs.l	1
angdy		rs.l	1
angdz		rs.l	1
movent.size	rs.b	1

;====================================================================
;
; start of program
;
;====================================================================

start		ifeq demo
		clr -(sp)
		pea $ffffffff.w
		pea $ffffffff.w
		move #5,-(sP)
		trap #14
		lea 12(sp),sp
		clr.l	-(sp)
		move.w	#$20,-(sp)		;must make
		trap	#1			;a system call
		move.l	d0,2(sp)		;to get to super mode
		endc
		
		move #$2700,sr
		move.l sp,oldsp
		lea our_stack,sp
execsuper	move.l	#$80000,d0		;top of RAM
		sub.l	#miscmem+stacksize,d0
		move.l	d0,maxram
		bsr	savesys
		bsr	quiet
		bsr	main			;exec screen
		bsr	restoresys
		bsr	quiet
		ifeq demo
		trap	#1			;back to user mode
		clr.l	(sp)
		trap	#1
		endc
		move.l oldsp(pc),sp
		rts

		ds.l 256
our_stack	ds.l 1


oldsp		dc.l 0
;
; save system
;

savesys		lea	mfp(pc),a0
		lea	$fffffa00.w,a1
		move.b	$07(a1),(a0)+		;iea
		move.b	$09(a1),(a0)+		;ieb
		move.b	$13(a1),(a0)+		;ieb
		move.b	$15(a1),(a0)+		;ieb
		move.b	$03(a1),(a0)+		;aer
		move.b	$17(a1),(a0)+		;vbr
		move.b	$1b(a1),(a0)+		;timer B control
		move.b	$21(a1),(a0)+		;timer B data
		move.l	$14.w,(a0)+		;div by 0
		move.l	$68.w,(a0)+		;spurious
		move.l	$70.w,(a0)+		;vblank
		move.b	$ffff8201.w,(a0)+
		move.b	$ffff8203.w,(a0)+	;screen address
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,(a0)		;colours
		rts
;
; restore system
;
restoresys	move #$2700,sr
		lea	mfp(pc),a0
		lea	$fffffa00.w,a1
		move.b	(a0)+,$07(a1)		;iea
		move.b	(a0)+,$09(a1)		;ieb
		move.b	(a0)+,$13(a1)		;ieb
		move.b	(a0)+,$15(a1)		;ieb
		move.b	(a0)+,$03(a1)		;aer
		move.b	(a0)+,$17(a1)		;vbr
		move.b	(a0)+,$1b(a1)		;timer B control
		move.b	(a0)+,$21(a1)		;timer B data
		move.l	(a0)+,$14.w		;div by 0
		move.l	(a0)+,$68.w		;spurious
		move.l	(a0)+,$70.w		;vblank
		move.b	(a0)+,$ffff8201.w
		move.b	(a0)+,$ffff8203.w	;screen address
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,$ffff8240.w	;colours
		rts

;
; stop any noise
;
quiet		move.l	#$08000000,$ffff8800.w
		move.l	#$09000000,$ffff8800.w
		move.l	#$0a000000,$ffff8800.w
		rts

;
; storage for mfp variables
;

mfp		ds.b	64

;====================================================================
;
; start of main program
;
;====================================================================

main		move.w	#$2700,sr
		clr.b	$fffffa07.w
		clr.b	$fffffa09.w
		clr.b	$fffffa13.w
		clr.b	$fffffa15.w
		lea	anrte(pc),a0
		move.l	a0,$14.w
		move.l	a0,$68.w
		move.l	a0,$70.w
		move.b	#$40,$fffffa17.w	;set mfp vector address
		clr.b	$fffffa1b.w
		bset	#0,$fffffa07.w		;timer B
		bset	#0,$fffffa13.w		;timer B
		bclr	#3,$FFFFFA03.W		;set active edge
		stop	#$2300
		movem.l	miscmem,d0-d7
		movem.l	d0-d7,$ffff8240.w
		jsr	dealloc
		bsr	genscreens
		stop	#$2300
		move.l	screen1,d0
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w		;force display

;
; continue initialization
;
		bsr	genpixtable
		bsr	prerot			;init fast scroll
		bsr	setscroll
		jsr	init3d
		jsr	initstars
		move.l	#vbl,$70.w
		moveq	#1,d0
		jsr	music
		stop	#$2300			;ensure video sync
;
; clear the three workscreens
;
		bsr	clearscreen
		bsr	screenswap
		bsr	clearscreen
		bsr	screenswap
		bsr	clearscreen
		bsr	screenswap
;
; recycle - restart from beginning
;
		move.l	miscmem,imem		;save free mem
		move.l	igdptr,a1
reround		move.l	(a1),d0
roundagain	move.l	a1,igdptr
		move.l	d0,a1
		jsr	set4igd			;init animation
;
; play a single animation
;
mainloop	clr.l	root
		jsr	insert_igd
		move.l	screen1,logbase
		jsr	clearscreen
		jsr	treesort
		jsr	screenswap
		jsr	move_igd
		jsr	remove_igd
		cmp.b	#$39,$FFFFFC02.W	;SPACE pressed?
		beq	exit
		tst.w	igdnumob
		bne	mainloop		;all objects gone?
;
; move to next object in sequence
;
nextone		move.l	igdptr,a1
		addq.l	#4,a1
		move.l	(a1),d0			;another waiting?
		bne	roundagain
		move.l	imem,miscmem		;reset memptr
		move.l	#igdtable,a1
		bra	reround

exit		rts

;
; for exception handler
;

anrte		rte
imem		dc.l	0

;
; generate 3 screens
;

genscreens	move.l	#(40192*3)+256,d0
		jsr	malloc
		move.l	a1,d0
		add.l	#256,d0
		clr.b	d0
		move.l	d0,screen1
		add.l	#40192,d0
		move.l	d0,screen2
		add.l	#40192,d0
		move.l	d0,screen3
		move.l	d0,physbase
		rts

;
; generate a pixel lookup table
;

genpixtable	move.l	#320*4,d0
		jsr	malloc
		move.l	a1,pixtable
		clr.w	d0
.loop		move.w	d0,d1
		asr.w	#4,d1
		asl.w	#3,d1
		move.w	d1,(a1)+	;offset into line
		move.w	d0,d1
		and.w	#15,d1
		move.w	#$8000,d2
		ror.w	d1,d2
		move.w	d2,(a1)+	;bitset for pixel
		addq.w	#1,d0
		cmp.w	#320,d0
		bne.s	.loop
		rts
pixtable	dc.l	0

;
; swap between screens
;

screenswap	tst.w	vblsem
		beq.s	screenswap
		clr.w	vblsem
		movem.l screen1(pc),d0-d2
		exg	d0,d1
		exg	d1,d2
		movem.l d0-d2,screen1
;
; display screen
;
		move.l	d2,physbase
		lsr.w	#8,d2
		move.l	d2,$ffff8200.w
		rts
;
; pointers to screen memory (aligned to 256 byte boundary)
;
screen1 	dc.l	0			;ptrs to screen mem
screen2 	dc.l	0
screen3 	dc.l	0

;
; clear the entire screen
;

clearscreen	move.w	#200/2-1,d0
		move.l	screen1(pc),a0
		lea	32000(a0),a0
		moveq	#0,d1
		moveq	#0,d2
		move.l	d1,d3
		move.l	d2,d4
		move.l	d1,d5
		move.l	d2,d6
		move.l	d1,d7
		move.l	d2,a1
		move.l	d1,a2
		move.l	d2,a3
.loop		movem.l d1-d7/a1-a3,-(a0)
		movem.l d1-d7/a1-a3,-(a0)
		movem.l d1-d7/a1-a3,-(a0)
		movem.l d1-d7/a1-a3,-(a0)
		movem.l d1-d7/a1-a3,-(a0)
		movem.l d1-d7/a1-a3,-(a0)
		movem.l d1-d7/a1-a3,-(a0)
		movem.l d1-d7/a1-a3,-(a0)
		dbra	d0,.loop
		rts

;
; vertical blanking interrupt (50Hz)
;

vbl		movem.l d0-d7/a0-a6,-(sp)
		movem.l igdpalette,d0-d7
		movem.l d0-d7,$ffff8240.w
		clr.b	$fffffa1b.w		;reset timer B
		move.b	#199,$fffffa21.w
		move.b	#8,$fffffa1b.w
		move.l	#hbl,$120.w
		moveq	#0,d0			;read h/w for
		move.b	$ffff8205.w,d0		;actual video address
		swap	d0
		move.b	$ffff8207.w,d0
		asl.w	#8,d0
		move.l	d0,physbase
		bsr	scroll			;draw scrolling msg
		bsr	edges			;and overwrite edges
		lea	fontpal+16*2(pc),a0
		move.w	-(a0),d0
		rept	3
		move.l	-(a0),2(a0)
		endr
		move.w	-(a0),2(a0)
		move.w	d0,(a0)
		jsr	refresh			;play music
		movem.l (sp)+,d0-d7/a0-a6
		st	vblsem
		rte
vblsem		dc.w	0

;
; horizontal blank interrupt routine
;

hbl		movem.l	d0-d7/a0-a6,-(sp)
		clr.b $fffffa1b.w		;stop timer B
		LEA noplist(PC),A0
		MOVE #$8209,A1
.syncb		MOVE.B (A1),D0
		BEQ.S .syncb
		SUBI.B #$60,D0
		AND #$7E,D0
		ADDA.W D0,A0
		JMP (A0)
noplist		DCB.W 65,$4E71
		lea fontpal(pc),a0
		move.w	#$8240,a1
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		nop
		clr.b $FffF820A.w
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		MOVE.B #2,$FffF820A.w
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		jsr	clearstars
		jsr	movestars
		jsr	drawstars
		movem.l	(sp)+,d0-d7/a0-a6
		rte

fontpal		dc.w	$000,$003,$004,$015,$025,$036,$046,$057
		dc.w	$002,$002,$002,$002,$002,$002,$002,$226

;
; draw edges to scroll bar
;

edges		move.l	physbase,a0
		add.w	#row*nextline,a0
		moveq	#height,d0
		moveq	#0,d1
		move.l	d1,-16(a0)
		move.l	d1,-12(a0)
		move.l	d1,-8(a0)
		move.l	d1,-4(a0)
		lea	edgeimg(pc),a1
.loop		move.l	(a1)+,d1
		move.l	(a1)+,d2
		move.l	d1,0(a0)
		move.l	d2,4(a0)
		move.l	d1,152(a0)
		move.l	d2,156(a0)
		lea	160(a0),a0
		dbra	d0,.loop
		moveq	#0,d1
		move.l	d1,(a0)
		move.l	d1,4(a0)
		move.l	d1,8(a0)
		move.l	d1,12(a0)
		rts
edgeimg	 	rept	(height+1)/8
		dc.w	$0000,$0000,$0000,$ffff ;8
		dc.w	$ffff,$0000,$0000,$ffff ;9
		dc.w	$0000,$ffff,$0000,$ffff ;10
		dc.w	$ffff,$ffff,$0000,$ffff ;11
		dc.w	$0000,$0000,$ffff,$ffff ;12
		dc.w	$ffff,$0000,$ffff,$ffff ;13
		dc.w	$0000,$ffff,$ffff,$ffff ;14
		dc.w	$ffff,$ffff,$ffff,$ffff ;15
		endr

;
; pre-rotate characters
;

prerot		move.l	#145000,d0
		jsr	malloc
		move.l	a1,chartab
		lea	charset(pc),a0		;font data
		moveq #45,d7
.loop		move.w d7,-(Sp)
		bsr	clrchar
		bsr	drawchar
		bsr	storechar		;normal
		bsr	rotleft
		bsr	storechar		;4 left
		bsr	rotleft
		bsr	storechar		;8 left
		bsr	rotleft
		bsr	storechar		;12 left
		move.w (sp)+,d7
		dbf d7,.loop
		lea charset,a0
		move #(30720/8)-1,d0
clearc		clr.l (a0)+
		clr.l (a0)+
		DBF D0,clearc
		rts

;
; clear character
;
clrchar 	move.l	physbase,a6
		moveq	#height,d0
		moveq	#0,d1
.clrloop	move.l	a6,a5
		rept	width+2
		move.l	d1,(a5)+
		move.l	d1,(a5)+
		endr
		lea	nextline(a6),a6
		dbra	d0,.clrloop
		rts
;
; draw character
;
drawchar	move.l	physbase,a6
		addq.w	#8,a6			;2nd block
		moveq	#height,d0
.drawloop	move.l	a6,a5
		rept	width
		move.l	(a0)+,(a5)+
		move.l	(a0)+,(a5)+
		endr
		lea	nextline(a6),a6
		dbra	d0,.drawloop
		rts
;
; store character
;
storechar	move.l	physbase,a6
		move.l	a6,a4
		lea	100*nextline(a4),a4
		moveq	#height,d0
.storeloop	move.l	a6,a5
		move.l	a4,a3
		rept	width+1
		movem.w (a5)+,d1-d4
		move.w	d1,d5
		or.w	d2,d5
		or.w	d3,d5
		or.w	d4,d5
		not.w	d5
		move.w	(a3)+,d6
		and.w	d5,d6
		or.w	d1,d6
		move.w	d6,(a1)+		;p0
		move.w	(a3)+,d6
		and.w	d5,d6
		or.w	d2,d6
		move.w	d6,(a1)+		;p1
		move.w	(a3)+,d6
		and.w	d5,d6
		or.w	d3,d6
		move.w	d6,(a1)+		;p2
		move.w	(a3)+,d6
		and.w	d5,d6
		or.w	d4,d6
		move.w	d6,(a1)+		;p3
		endr
		lea	nextline(a4),a4
		lea	nextline(a6),a6
		dbra	d0,.storeloop
		rts
;
; rotate character left 4 pixels
;
rotleft 	move.l	physbase,a6
		moveq	#height,d0
		moveq	#4,d1
.rotloop	move.l	a6,a5
		rept	width+1
		movem.w 8(a5),d2-d5
		swap	d2
		swap	d3
		swap	d4
		swap	d5
		move.w	(a5),d2
		rol.l	d1,d2
		move.w	d2,(a5)+
		move.w	(a5),d3
		rol.l	d1,d3
		move.w	d3,(a5)+
		move.w	(a5),d4
		rol.l	d1,d4
		move.w	d4,(a5)+
		move.w	(a5),d5
		rol.l	d1,d5
		move.w	d5,(a5)+
		endr
		lea	nextline(a6),a6
		dbra	d0,.rotloop
		rts
;
; initialize scroller
;
setscroll	move.l	#row*nextline,d0
		lea	ptrtab,a0
		bsr	.store6
		subq.l	#8,d0
		bsr	.store6
		subq.l	#8,d0
		bsr	.store6
		move.l	#ptrtab,ptrptr
		move.l	chartab,d0
		add.l	#46*nextchar*4,d0
		lea	charptr,a0
		rept	nblocks
		move.l	d0,(a0)+
		endr
		move.w	#4,coffset
		lea	scrolltext,a0
		move.b	(a0),d0
.fixloop	bsr	.convert
		move.b	d0,(a0)+
		move.b	(a0),d0
		bne.s	.fixloop
		move.b	#-1,(a0)
		move.l	#scrolltext,textptr
		rts
.convert	lea	charlookup,a1
.search 	cmp.b	(a1)+,d0
		beq.s	.found
		tst.b	(a1)
		bne.s	.search
.found		sub.l	#charlookup+1,a1
		move.l	a1,d0
		rts
.store6 	move.l	d0,d1
		moveq	#24,d2
		rept	nblocks-1
		move.l	d1,(a0)+
		add.l	d2,d1
		endr
		move.l	d1,(a0)+
		rts
;
; character set
;
charlookup	dc.b	" !'(),-.0123456789:?ABCDEFGHIJKLMNOP"
		dc.b	"QRSTUVWXYZ",0
		even
igdworkspace	
charset 	incbin	"megadeth.ch4"
charsetend	even
;
; main scroller
;

scroll		move.l	ptrptr,a6
xaddr		set	0
		rept	nblocks
		move.l	charptr+xaddr,a0
		move.l	(a6)+,a1
		bsr	.drawchar
xaddr		set	xaddr+4
		endr
		subq.w	#1,coffset
		beq.s	.reload
		lea	charptr,a0
		move.l	#nextchar,d0
		rept	nblocks
		add.l	d0,(a0)+
		endr
		rts
.reload 	move.w	#4,coffset
		lea	charptr,a0
		move.l	#nextchar*3,d0
		rept	nblocks
		sub.l	d0,(a0)+
		endr
		cmp.l	#ptrtabend,a6
		beq.s	.wrap
		move.l	a6,ptrptr
		rts
.wrap		move.l	#ptrtab,ptrptr
		lea	charptr,a0
		rept	nblocks-1
		move.l	4(a0),(a0)+
		endr
		move.l	textptr,a1
		moveq	#0,d0
.redo		move.b	(a1)+,d0
		bmi.s	.endofstring
		move.l	a1,textptr
		mulu	#nextchar*4,d0
		add.l	chartab,d0
		move.l	d0,(a0)
		rts
.endofstring	move.l	#scrolltext,a1
		bra.s	.redo
.drawchar	add.l	physbase,a1
oset		set	0
		rept	(height+1)/2
		movem.l (a0)+,d0-d7/a2-a5
		movem.l d0-d5,oset(a1)
		movem.l d6-d7/a2-a5,oset+160(a1)
oset		set	oset+320
		endr
		rts

;
; initialize starfield
;

initstars	move.l	#numstars*12,d0
		bsr	malloc
		move.l	a1,startab0
		move.l	#numstars*12,d0
		bsr	malloc
		move.l	a1,startab1
		st	(a1)
		move.l	#randnum*6,d0
		bsr	malloc
		move.l	a1,randtab
		move.l	a1,randptr
		move.w	#numstars-1,d7
		move.l	startab0,a0
.newstar	bsr	genstar
		swap	d0
		swap	d1			;startable entry
		swap	d2			;is 12 bytes
		clr.w	d0			; 0  = x coord
		clr.w	d1			; 4  = y coord
		clr.w	d2			; 12 = colour
		move.l	d0,(a0)+
		move.l	d1,(a0)+
		move.l	d2,(a0)+
		dbra	d7,.newstar
		move.w	#randnum-1,d7
		move.l	randtab,a0
.newrand	bsr	genstar 		;d0=x d1=y d2=col
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		move.w	d2,(a0)+
		dbra	d7,.newrand
		rts
startab0	dc.l	0
startab1	dc.l	0
randtab 	dc.l	0	;* must be before randptr *
randptr 	dc.l	0	;* these two must be together *
;
; generate a random star
;
genstar 	jsr	random
		and.w	#255,d0 		;0-255
		cmp.w	#symax,d0
		bge.s	genstar
		cmp.w	#smidy,d0
		beq.s	genstar
		move.w	d0,d1			;y coord
		jsr	random
		move.w	d0,d2			;colour
.genx		jsr	random
		and.w	#511,d0 		;0-511
		cmp.w	#sxmax,d0
		bge.s	.genx
		cmp.w	#smidx,d0
		beq.s	.genx
		and.w	#3,d2
		rts
;
; draw the current starfield
;
drawstars	move.l	startab0,a0
		lea	.ds_x30,a1
		lea	x160(pc),a2
		move.l	pixtable,a3
		lea	.ds_next,a4
		move.l	startab1,a5
		move.l	physbase(pc),d6
		move.w	#numstars-1,d7
.ds_loop	move.w	(a0),d0 		;x
		move.w	4(a0),d1		;y
		move.w	8(a0),d2		;col
		add.w	d0,d0
		add.w	d0,d0			;x * 4
		add.w	d1,d1
		move.l	d6,a6			;top of screen
		add.w	0(a2,d1.w),a6
		add.w	0(a3,d0.w),a6
		move.w	2(a3,d0.w),d0		;bitset for pixel
		move.w	d0,d1
		not.w	d1			;bitmask
		move.w	(a6)+,d3
		or.w	(a6)+,d3
		or.w	(a6)+,d3		;read current pixel
		or.w	(a6)+,d3
		and.w	d1,d3
		bne	.ds_next		;not blank!
		lea	-8(a6),a6
		move.l	a6,(a5)+		;address
		move.w	d1,(a5)+		;bitset for pixel
		add.w	d2,d2
		move.w	0(a1,d2.w),d2		;jmp offset
		jmp	.ds_star0(pc,d2.w)

.ds_star0	or.w	d0,(a6)+		;colour 11
		or.w	d0,(a6)+
		and.w	d1,(a6)+
		or.w	d0,(a6)+
		jmp	(a4)

.ds_star1	and.w	d1,(a6)+		;colour 12
		and.w	d1,(a6)+
		or.w	d0,(a6)+
		or.w	d0,(a6)+
		jmp	(a4)

.ds_star2	or.w	d0,(a6)+		;colour 13
		and.w	d1,(a6)+
		or.w	d0,(a6)+
		or.w	d0,(a6)+
		jmp	(a4)

.ds_star3	and.w	d1,(a6)+		;colour 14
		or.w	d0,(a6)+
		or.w	d0,(a6)+
		or.w	d0,(a6)+
		jmp	(a4)

.ds_star4	or.w	d0,(a6)+		;colour 15
		or.w	d0,(a6)+
		or.w	d0,(a6)+
		or.w	d0,(a6)+

.ds_next	lea	12(a0),a0
		dbra	d7,.ds_loop
		st	(a5)			;terminate list
		rts

.ds_x30 	dc.w	0,10,20,30,40,40,40,40,40,40,40,40,40,40,40,40

;
; remove the current starfield
;
clearstars	move.l	startab1,a0
		move.l	(a0)+,d0
		bmi	.cs_exit
.cs_loop	move.l	d0,a1
		move.w	(a0)+,d0
		and.w	d0,(a1)+
		and.w	d0,(a1)+
		and.w	d0,(a1)+
		and.w	d0,(a1)+
		move.l	(a0)+,d0
		bpl.s	.cs_loop
.cs_exit	rts
;
; move the starfield
;
movestars	sub.l	#32768,.timer
		bpl.s	.same
		move.l	#100<<16,.timer
		move.w	.smcvar,d0
		addq.w	#1,d0
		cmp.w	#16,d0
		bne.s	.nowrap
		moveq	#0,d0
.nowrap 	move.w	d0,.smcvar
		add.w	d0,d0
		add.w	d0,d0
		move.l	.smctab(pc,d0.w),.rotsmc
.same		move.l	startab0,a0
		move.l	randtab,a2
		add.l	#randnum*6,a2
		move.l	randptr,a3
		move.w	#numstars-1,d7
		bsr	.loop			;move stars
		move.l	a3,randptr
		rts
.timer		dc.l	100<<16
.smcvar 	dc.w	0
.smctab 	nop
		nop
		add.l	d3,d0			;splay from center
		nop				;
		nop
		nop
		sub.l	d3,d0			;splay from center
		nop				;
		nop
		nop
		add.l	d2,d0			;out sides from center
		sub.l	d3,d1
		nop
		nop
		sub.l	d2,d0			;out top/bot from center
		add.l	d3,d1
		nop
		nop
		sub.l	d3,d0			;clockwise
		add.l	d2,d1
		nop
		nop
		add.l	d3,d0			;anti-clockwise
		sub.l	d2,d1
		nop
		nop
		sub.l	d3,d0			;?
		sub.l	d2,d1
		nop
		nop
		add.l	d3,d0			;?
		add.l	d2,d1
.loop		move.l	(a0),d0 		;x
		move.l	4(a0),d1		;y
		sub.l	#smidx<<16,d0
		sub.l	#smidy<<16,d1
		move.l	d0,d2
		move.l	d1,d3			;delta
		asr.l	#5,d2
		asr.l	#5,d3
		add.l	d2,d0
		add.l	d3,d1
.rotsmc 	nop
		nop
		add.l	#smidx<<16,d0		;normalize x
		cmp.l	#sxmax<<16,d0
		bcc.s	.newstar
		add.l	#smidy<<16,d1		;normalize y
		cmp.l	#symax<<16,d1
		bcc.s	.newstar
		move.l	8(a0),d2
		add.l	#$800,d2		;brighter
		cmp.l	#15<<16,d2
		ble.s	.next			;force 0-15
		move.l	#15<<16,d2
.next		move.l	d0,(a0)+
		move.l	d1,(a0)+		;save new coords
		move.l	d2,(a0)+
		dbra	d7,.loop
		rts
.newstar	move.w	(a3)+,d0		;x
		move.w	(a3)+,d1		;y
		move.w	(a3)+,d2		;col
		swap	d0
		swap	d1
		swap	d2
		clr.w	d0
		clr.w	d1
		clr.w	d2
		move.l	d0,(a0)+
		move.l	d1,(a0)+		;save new coords
		move.l	d2,(a0)+
		cmp.l	a2,a3
		beq.s	.wrap
		dbra	d7,.loop
		rts
.wrap		move.l	randtab,a3
		dbra	d7,.loop
		rts

;
; initialize the 3d, and move bottom clipping up one line
; to hide the palette swap 'bounce'
;

init3d		lea	xmax,a0
		move.l	a0,a1
		move.w	#(threedend-xmax)/2-1,d0
		moveq	#0,d1
.ggg		add.w	(a0)+,d1
		dbra	d0,.ggg
		sub.w	#$51FC,d1
		jsr	-28(a1)
		move.l	#1024,d0		;1k for selfsort
		bsr	malloc
		move.l	a1,ss_workspace
		move.w	#198,ymax
		rts

;
; free all allocated memory
;

dealloc 	lea	miscmem,a1
		move.l	maxram(pc),d0
		move.l	d0,(a1)+
		moveq	#0,d1
.clrloop	move.l	d1,(a1)+
		move.l	d1,(a1)+
		subq.l	#8,d0
		bpl.s	.clrloop
		rts

;
; allocate memory block
;

malloc		lea	miscmem,a1
		cmp.l	(a1),d0
		bgt.s	.nomem
		sub.l	d0,(a1) 		;work downwards
		add.l	(a1)+,a1
		rts
.nomem		move #$2700,sr
		move #$700,$ffff8240.w
.forever	bra .forever

;
; variables / data
;

maxram		dc.l	$80000
physbase	dc.l	$78000
ptrptr		dc.l	0
ptrtab		ds.l	nblocks*3
ptrtabend
charptr 	ds.l	nblocks
coffset 	dc.w	0
textptr 	dc.l	scrolltext
chartab 	dc.l	0

;
; david whittaker music
;

music		incbin	"blaze.wit"
refresh 	equ	music+$e

;
; lookup table for x160
;

x160
offset		set	0
		rept	200
		dc.w	offset
offset		set	offset+160
		endr
;
; SCROLLING MESSAGE
;
; typed and composed by Mark Stafford
;
scrolltext
 DC.B "             "
 DC.B "  PRESENTING"
 DC.B "  AN AUDIO-VISUAL EXPERIENCE "
 DC.B "  BROUGHT TO YOU BY "
 DC.B "  THE RED HERRINGS "
 DC.B "  IN ASSOCIATION WITH "
 DC.B "  THE INNER CIRCLE "
 DC.B "  CREDITS: "
 DC.B "  PROGRAMMING, SHAPES AND POTS OF TEA "
 DC.B "  THE MASKED PROGRAMMER  --  "
 DC.B "  WORDS, ARTY STUFF AND TEA DRINKER "
 DC.B "  MARK STAFFORD "
 DC.B "  THE RED HERRINGS WOULD LIKE TO THANK "
 DC.B "  DEVPAC DEVELOPER "
 DC.B "  ACTIVISIONS MUSIC STUDIO "
 DC.B "  1ST WORD PLUS "
 DC.B "  LEEDS UNITED "
 DC.B "  PEOPLE WHO GIVE THE HERRINGS MONEY "
 DC.B "  HYPED SOFTWARE WHICH DOES NOT DELIVER "
 DC.B "  ATARI STS EVERYWHERE "
 DC.B "  SATELLITE TELEVISION "
 DC.B "  YAMAHA SYNTHESIZERS "
 DC.B "  CASIO SYNTHESIZERS "
 DC.B "  AKAI PROFESSIONAL SAMPLERS "
 DC.B "  TASCAM RECORDING EQUIPMENT "
 DC.B "  PHILIPS AUDIO "
 DC.B "  SPEED AND THRASH METAL "
 DC.B "  AMSTRAD MODEMS "
 DC.B "  FORD FOR MAKING A HEAP CALLED A SIERRA "
 DC.B "  LEICESTER POLY FOR OUR EDEWKAYSHUN "
 DC.B "  DINO DINI FOR PLAYER MANAGER "
 DC.B "  RUSSELLS WORK CAN BE FOUND ON "
 DC.B "  FALCON F16 "
 DC.B "  F29 RETALIATOR "
 DC.B "  MARKS WORK CAN ALSO BE FOUND ON "
 DC.B "  LAVATORY WALLS "
 DC.B "  RUSSELL AND MARK ARE BOTH AVAILABLE FOR"
 DC.B "  ANY COMPUTER GAMES WORK WHICH PAYS GOOD"
 DC.B "  SWEDISH NYMPHOMANIACS "
 DC.B "  PARTYS "
 DC.B "  NOW A WORD TO ANY POTENTIAL SPONSORS "
 DC.B "  WHY NOT RENT SPACE IN THESE SCROLLING "
 DC.B "AREAS TO ADVERTISE YOUR PRODUCT OR EVEN "
 DC.B "HAVE A CUSTOMISED DEMO PRODUCED FOR YOUR "
 DC.B "PRODUCT BY THE RED HERRINGS ? "
 DC.B "  COULD BE USED AS PART OF ANY "
 DC.B "AUDIO-VISUAL PRESENTATION "
 DC.B "  ----  "
 DC.B "  NOW FOR THE TECHNICAL BITS "
 DC.B "  THE STARFIELD HAS 50 STARS IN IT "
 DC.B "  THESE STARS GO THROUGH 4 SHADES "
 DC.B "  THE SCREEN REFRESH RATE IS 50 FRAMES/SEC"
 DC.B "  THIS MEANS MAX SPEED TO YOU AND ME "
 DC.B "  6 POLYS CAN BE DISPLAYED AT THIS RATE "
 DC.B "  THIS MEANS A TOTAL OF 300 POLYS PER SEC!"
 DC.B "  THIS INCLUDES HASH COLOURS "
 DC.B "  THIS STUFF HAS BEEN REWRITTEN MANY TIMES"
 DC.B "  RUSS SAYS HE CAN STILL MAKE IT FASTER "
 DC.B "  TRY THESE AUTHORS TO GET GOOD INFO "
 DC.B "  FOLEY AND VAN DAM "
 DC.B "  HEARN AND BAKER "
 DC.B "  DAVID ROGERS "
 DC.B "  JOHN LANSDOWN "
 DC.B "  ROBERT SEDGEWICK "
 DC.B "  BURGER AND GILLIES "
 DC.B "  NOW A WORD TO ANY POTENTIAL SPONSORS "
 DC.B "  WHY NOT RENT SPACE IN THESE SCROLLING "
 DC.B "AREAS TO ADVERTISE YOUR PRODUCT OR EVEN "
 DC.B "HAVE A CUSTOMISED DEMO PRODUCED FOR YOUR "
 DC.B "PRODUCT BY THE RED HERRINGS ? "
 DC.B "  COULD BE USED AS PART OF ANY "
 DC.B "  AUDIO-VISUAL PRESENTATION "
 DC.B " ---- "
 DC.B "  THE FOLLOWING PEOPLE OWE US A DRINK "
 DC.B "  SEAN (ME BROTHER) "
 DC.B "  ALL THE DAVES "
 DC.B "  TEZZA "
 DC.B "  ROB "
 DC.B "  ARCHIE MICK "
 DC.B "  BIG JACK T (MR ATARI) "
 DC.B "  VIZ COMICS FOR A FREE PLUG "
 DC.B "  IAN "
 DC.B "  DR STEVE "
 DC.B "  DR MARTIN (I WISH SOMEONE WOULD) "
 DC.B "  OUR MUMS AND DADS "
 DC.B "  THE RED HERRINGS ENDORSE AND WOULD LIKE "
 DC.B "  FERRARI TESTAROSSA "
 DC.B "  PORCHE 911 TARGA "
 DC.B "  TOYOTA CELICA GT 4X4 "
 DC.B "  APOLLO DN10000 "
 DC.B "  SUN SPARCSTATION "
 DC.B "  ATARI ATW "
 DC.B "  BRITISH AIRWAYS TRANSATLANTIC FLIGHTS "
 DC.B "  CASIO FZ1 "
 DC.B "  STEINBERG CUBASE "
 DC.B "  QUARTET "
 DC.B "  PHILIPS COLOUR MONITOR "
 DC.B "  AKAI MG1212 "
 DC.B "  ROLAND D50 "
 DC.B "  AKAI S1000 "
 DC.B "  BECKS BEER "
 DC.B "  WALLS CORNETTOS "
 DC.B "  COCA COLA "
 DC.B "  PEPSI "
 DC.B "  BLU TACK "
 DC.B "  APPLE LASERWRITER "
 DC.B "  HP LASERJET III "
 DC.B "  BROOKE SHIELDS (FOR HER MIND) "
 DC.B "  MADONNA (FOR HER MONEY) "
 DC.B "  LEEDS UNITED SEASON TICKETS "
 DC.B "  1945 MGTC "
 DC.B "  NOW A WORD TO ANY POTENTIAL SPONSORS "
 DC.B "  WHY NOT RENT SPACE IN THESE SCROLLING "
 DC.B "AREAS TO ADVERTISE YOUR PRODUCT OR EVEN "
 DC.B "HAVE A CUSTOMISED DEMO PRODUCED FOR YOUR "
 DC.B "PRODUCT BY THE RED HERRINGS ? "
 DC.B "  COULD BE USED AS PART OF ANY "
 DC.B "  AUDIO-VISUAL PRESENTATION "
 DC.B "  ---  "
 DC.B "  NOW TO PROGRAMMING LANGUAGES..... "
 DC.B "  ...AND WHAT THEY SAY ABOUT YOU... "
 DC.B "  BASIC "
 DC.B "  RECENT RESEARCH SHOWS THAT THE AVERAGE "
 DC.B "BASIC PROGRAMMER IS OF LOW INTELLEGENCE "
 DC.B "  THEIR MAIN AIM IN LIFE IS TO GET A FAST "
 DC.B "CAR BUT THEY USUALLY SETTLE FOR A SKODA "
 DC.B "  BASIC PROGRAMMERS HAVE NO SENCE OF FUN "
 DC.B "AND ARE OFTEN ALSO SEEN AT THE END OF "
 DC.B "CREWE STATION LOOKING FOR A DELTIC "
 DC.B "  BASIC PROGRAMMERS TEND TO HAVE NO "
 DC.B "AMBITION AND ARE OFTEN FOUND IN ANORAKS "
 DC.B "LOOKING AT SHOP ASSISTANT ADVERTS IN THE"
 DC.B " LOCAL JOB CENTRE "
 DC.B "  BASIC PROGRAMMERS OFTEN READ THE STAR "
 DC.B "  ARE TONE DEAF "
 DC.B "  EAT BACON BUTTIES "
 DC.B "  LISTEN TO BROS "
 DC.B "  AND MOLEST SHEEP "
 DC.B "  COBOL "
 DC.B "  YOUR AVERAGE COBOL PROGRAMMER IS A "
 DC.B "FRUSTRATED ACCOUNTANT "
 DC.B "  THERE MAIN AIM IN LIFE IS TO BE NOTICED "
 DC.B "WHICH THEY DO SUCCESSFULLY BY WEARING "
 DC.B "PLATFORM SHOES AND FLAIRED JEANS "
 DC.B "  COBOL PROGRAMMERS ARE REFORMED DROPOUTS "
 DC.B "WHOSE MORAL STANCE IN LIFE MAKES THEM "
 DC.B "IDEAL CANDIDATES FOR JEHOVAHS WITNESSES "
 DC.B "  THEY CAN OFTEN BE FOUND IN WH SMITHS "
 DC.B "READING THE PEOPLES FRIEND. "
 DC.B "  COBOL PROGRAMMERS READ THE FT "
 DC.B "  LISTEN TO RADIO 3 "
 DC.B "  DRINK LEMON TEA "
 DC.B "  SUCK TUNES "
 DC.B "  AND USE SHEEP AS A CONTRACEPTIVE "
 DC.B "  PASCAL "
 DC.B "  YOUR PASCAL PROGRAMMER IS ENVIROMENTALLY"
 DC.B " FRIENDLY, BUT OFTEN STINKS "
 DC.B "  THERE MAIN AIM IN LIFE IS TO WRITE A "
 DC.B "BEAUTIFUL CONSTRUCT "
 DC.B "  THESE ARE THE DROPOUTS WHO DIDNT REFORM"
 DC.B "  THEY ARE NOT REAL PROGRAMMERS AND OFTEN"
 DC.B " SPEAK TECHNICAL BULLSHIT TO APPEAR "
 DC.B "INTELLIGENT "
 DC.B "  THEY CAN OFTEN BE FOUND IN VILLAGE PUBS "
 DC.B "LISTENING TO FOLK MUSIC OR "
 DC.B "MORRIS DANCING "
 DC.B "  PASCAL PROGRAMMERS READ THE GUARDIAN "
 DC.B "  DRINK REAL ALE "
 DC.B "  GROW BEARDS "
 DC.B "  AND MOLEST YOUNG BOYS "
 DC.B "  FORTRAN "
 DC.B "  THESE ARE THE REAL PROGRAMMERS "
 DC.B "OFTEN SUFFER FOR THEIR ART AND TEND TO "
 DC.B "BE UGLY, FAT OR BOTH "
 DC.B "  THEIR MAIN AIM IN LIFE IS TO PROGRAM IN"
 DC.B " C WITHOUT USING UNIX AND THEREFORE FAIL"
 DC.B " THEY ARE THE MOST APPROACHABLE OF PEOPLE"
 DC.B " BUT OFTEN HAVE A DARK SIDE AND GET WELL "
 DC.B "DEPRESSED "
 DC.B "  THEY CAN OFTEN BE FOUND AT FOOTBALL "
 DC.B "MATCHES AND ARE OFTEN SKINT "
 DC.B "  FORTRAN PROGRAMMERS READ THE INDEPENDENT"
 DC.B "  DRINK LOTS OF LARGER "
 DC.B "  ARE VERY SCRUFFY "
 DC.B "  LISTEN TO LOUD ROCK MUSIC "
 DC.B "  AND NEVER PULL THE OPPOSITE SEX "
 DC.B "  C "
 DC.B "  THESE ARE FORTRAN PROGRAMMERS WHO DONT "
 DC.B "FIT THE FORTRAN IMAGE "
 DC.B "  THEY GET PAID A LOT FOR FUCK ALL "
 DC.B "AND LOOK GOOD IN ANYTHING "
 DC.B "  THERE MAIN AIM IN LIFE IS TO DO THE "
 DC.B "OFFICE JUNIOR OR THEIR BOSS "
 DC.B "  THERE OFTEN HAVE NO TIME FOR ANYONE "
 DC.B "UNLESS THEY GET PAID DOUBLE TIME "
 DC.B "  THEY CAN OFTEN BE FOUND IN EXPENSIVE "
 DC.B "RESTURANTS WHILE THE FORTRAN PROGRAMMER"
 DC.B " DEBUGS THEIR CODE "
 DC.B "  C PROGRAMMERS READ THE SUNDAY SPORT "
 DC.B "  DRINK ANYTHING IN AN EXPENSIVE BOTTLE "
 DC.B "  BUY THEIR CLOTHS AT NEXT "
 DC.B "  LISTEN TO RADIO 1 "
 DC.B "  AND PULL THE LOWER INTELLEGENT "
 DC.B "  68000 "
 DC.B "  THESE ARE FORTRAN PROGRAMMERS IN DECLINE"
 DC.B " THEY LIKE SUFFERING THE WORLDS ILLS "
 DC.B "  THEY DONT EARN MONEY AND ARE OFTEN THIN "
 DC.B "  THERE MAIN AIM IN LIFE IS TO STEEL A FEW"
 DC.B " MORE CYCLES AND GO EVEN FASTER "
 DC.B "  THEY ARE NOT VERY EASY TO COMMUNICATE "
 DC.B " WITH BECAUSE ITS HARD TO UNDERSTAND WHAT"
 DC.B " THE HELL THEY ARE TALKING ABOUT "
 DC.B "  THEY CAN OFTEN BE FOUND AT HOME AND ONLY"
 DC.B "  WORK WHEN ITS DARK "
 DC.B "  68000 PROGRAMMERS READ JOURNALS "
 DC.B "  DRINK ANYTHING AS LONG AS ITS ALCOHOL "
 DC.B "  EAT RED MEAT "
 DC.B "  PLAY LOTS OF CHESS "
 DC.B "  AND MOLEST COMPUTERS "
 DC.B "  FORTH "
 DC.B "  FORTH PROGRAMMERS ARE A DODGY LOT "
 DC.B "  THEY ARE OFTEN PSYCHOPATHS AND TEND TO "
 DC.B "TWITCH AND HAVE NO SPEECH CONTROL "
 DC.B "  THERE MAIN AIM IN LIFE IN TO WRITE A "
 DC.B "PROGRAM ON A JUPITER ACE WHICH DOES "
 DC.B "SOMETHING REMOTELY USEFUL "
 DC.B "  THEY OFTEN MIX WORDS UP IN A SENTENCE "
 DC.B "AND CAN ONLY SUCCESSFULLY HOLD A "
 DC.B "CONVERSATION WHEN THEY ARE DRUNK "
 DC.B "THEY CAN OFTEN BE FOUND IN LIBRARIES "
 DC.B " COMPLAINING ABOUT THE LACK OF COMPUTER "
 DC.B " REFERENCE BOOKS ALTHOUGH AS EVERYONE "
 DC.B " KNOWS THEY ONLY LOOK AT THE PICTURES "
 DC.B "  FORTH PROGRAMMERS CANT READ "
 DC.B "  EAT ANYTHING THAT GOES IN A MICROWAVE "
 DC.B "  PLAY ANYTHING VIOLENT "
 DC.B "  AND TEND TO BE MASS RAPISTS "
 DC.B "  ADA "
 DC.B "  THESE ARE THE PROGRAMMERS WHO GET IT "
 DC.B " REAL CUSHY HAVING NEVER WORKED HARD IN "
 DC.B " THEIR ENTIRE LIFE "
 DC.B "  THEY HAVE NO REAL IDEA ABOUT BEING "
 DC.B "PRACTICAL AND HENCE TAKE A YEAR TO WRITE"
 DC.B " THE SIMPLIST OF BUBBLE SORTS "
 DC.B "  THEIR MAIN AIM IN LIFE IS TO MAKE A "
 DC.B "DEADLINE AT LEAST ONCE "
 DC.B "  ADA PROGRAMMERS ARE VERY BORING TO TALK"
 DC.B " TO BECAUSE THEY TAKE TOO LONG TO GET "
 DC.B "TO THE POINT "
 DC.B "  THEY CAN OFTEN BE FOUND AT CONFERENCES "
 DC.B "ASKING LOTS OF INANE QUESTIONS "
 DC.B "  ADA PROGRAMMERS READ DICTIONARIES "
 DC.B "  EAT NOVEAUX RICHE "
 DC.B "  REFEREE ANYTHING WITH COMPLEX RULES "
 DC.B "  AND TEND TO PERFORM SEX ALONE "
 DC.B "  NOW A WORD TO ANY POTENTIAL SPONSORS "
 DC.B "  WHY NOT RENT SPACE IN THESE SCROLLING "
 DC.B "AREAS TO ADVERTISE YOUR PRODUCT OR EVEN"
 DC.B " HAVE A CUSTOMISED DEMO PRODUCED FOR YOUR "
 DC.B "PRODUCT BY THE RED HERRINGS ? "
 DC.B "  COULD BE USED AS PART OF ANY "
 DC.B "AUDIO-VISUAL PRESENTATION "
 DC.B " -- "
 DC.B "  NOW A VALUABLE SERVICE FOR SPORTS FANS "
 DC.B "  LEEDS UNITEDS 1989/90 RESULTS "
 DC.B "  WHICH MADE THEM 2ND DIVISION CHAMPIONS "
 DC.B "  AWAY AT NEWCASTLE UNITED LOST 5-2 "
 DC.B "  HOME TO MIDDLESBOROUGH WON 2-1 "
 DC.B "  HOME AT BLACKBURN ROVERS DREW 1-1 "
 DC.B "  AWAY AT STOKE CITY DREW 1-1 "
 DC.B "  HOME TO IPSWICH TOWN DREW 1-1 "
 DC.B "  AWAY AT HULL CITY WON 1-0 "
 DC.B "  HOME TO SWINDON TOWN WON 4-0 "
 DC.B "  HOME TO OXFORD UNITED WON 2-1 "
 DC.B "  AWAY AT PORT VALE DREW 0-0 "
 DC.B "  AWAY AT WEST HAM WON 1-0 "
 DC.B "  HOME TO SUNDERLAND WON 2-0 "
 DC.B "  AWAY AT PORTSMOUTH DREW 3-3 "
 DC.B "  HOME TO WOLVEHAMPTON WANDERERS WON 1-0 "
 DC.B "  AWAY AT BRADFORD CITY WON 1-0 "
 DC.B "  HOME TO PLYMOUTH ARGYLE WON 2-1 "
 DC.B "  HOME TO AFC BOURNEMOUTH WON 3-0 "
 DC.B "  AWAY AT LEICESTER CITY LOST 4-3 "
 DC.B "  HOME TO WATFORD WON 2-1 "
 DC.B "  AWAY AT WEST BROMWICH ALBION LOST 2-1 "
 DC.B "  HOME TO NEWCASTLE UNITED WON 1-0 "
 DC.B "  AWAY AT MIDDLESBOROUGH WON 2-0 "
 DC.B "  HOME TO BRIGHTON + HOVE ALBION WON 3-0 "
 DC.B "  AWAY AT SHEFFIELD UNITED DREW 2-2 "
 DC.B "  AWAY AT BARNSLEY LOST 1-0 "
 DC.B "  HOME TO OLDHAM ATHLETIC DREW 1-1 "
 DC.B "  AWAY AT BLACKBURN ROVERS WON 2-1 "
 DC.B "  HOME TO STOKE CITY WON 2-0 "
 DC.B "  AWAY AT SWINDON TOWN LOST 3-2 "
 DC.B "  HOME TO HULL CITY WON 4-3 "
 DC.B "  AWAY AT IPSWICH TOWN DREW 2-2 "
 DC.B "  HOME TO WEST BROMWICH ALBION DREW 2-2 "
 DC.B "  AWAY AT WATFORD LOST 1-0 "
 DC.B "  HOME TO PORT VALE DREW 0-0 "
 DC.B "  AWAY AT OXFORD UNITED WON 4-2 "
 DC.B "  HOME TO WEST HAM UNITED WON 3-2 "
 DC.B "  AWAY AT SUNDERLAND WON 1-0 "
 DC.B "  HOME TO PORTSMOUTH WON 2-0 "
 DC.B "  AWAY AT WOLVERHAMPTON WANDERERS LOST 1-0"
 DC.B "  HOME TO BRADFORD CITY DREW 1-1 "
 DC.B "  AWAY AT PLYMOUTH ARGYLE DREW 1-1 "
 DC.B "  AWAY AT OLDHAM ATHLETIC LOST 3-1 "
 DC.B "  HOME TO SHEFFIELD UNITED WON 4-0 "
 DC.B "  AWAY AT BRIGHTON + HOVE ALBION DREW 2-2 "
 DC.B "  HOME TO BARNSLEY LOST 2-1 "
 DC.B "  HOME TO LEICESTER CITY WON 2-1 "
 DC.B "  AWAY AT AFC BOURNEMOUTH WON 1-0 "
 DC.B "  FINISHED WITH A RECORD OF "
 DC.B "  WON 24 DREW 13 LOST 9 FOR 78 AGAINST 52 "
 DC.B "  POINTS 85 "
 DC.B "  NOW A WORD TO ANY POTENTIAL SPONSORS "
 DC.B "  WHY NOT RENT SPACE IN THESE SCROLLING "
 DC.B "  AREAS TO ADVERTISE YOUR PRODUCT OR EVEN"
 DC.B " HAVE A CUSTOMISED DEMO PRODUCED FOR YOUR "
 DC.B " PRODUCT BY THE RED HERRINGS ? "
 DC.B "  COULD BE USED AS PART OF ANY "
 DC.B "AUDIO-VISUAL PRESENTATION "
 DC.B "           "
 DC.B "        UH OH .... LOOKS LIKE ITS TIME TO WRAP "
 DC.B "           "
 DC.B 0
		EVEN

;
; 3d incbin library
;

threed		incbin	"3d.img"
threedend

xmax		equ	threed+$1c
ymax		equ	threed+$1c+2
midx		equ	threed+$1c+4
midy		equ	threed+$1c+6
logbase		equ	threed+$1c+8
root		equ	threed+$1c+12
orientation	equ	threed+$1c+16
view_object	equ	threed+$1c+20
treesort	equ	threed+$1c+24
draw_mobile	equ	threed+$1c+28
locate_shape	equ	threed+$1c+32
ss_workspace	equ	threed+$1c+36
random		equ	threed+$1c+40

;
; setup for a IGD format data file
;
; file is madeup as follows:
;
;	    2 bytes of id $1020
;	   32 bytes of palette
;	rept 10 times
;	    2 bytes of header $1234 or $5678
;	    ? bytes of shape data and
;	    ? bytes of movement stuff if $1234
;	end repeat
;	    2 bytes of end marker $9ABC
;

set4igd		lea	igdworkspace,a0
		exg	a0,a1
		bsr	decrunch
		lea	igdworkspace,a1
		cmp.w	#$1020,(a1)+
		beq.s	.okid
		illegal
;
; palette
;
.okid		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,igdpalette
;
; movement & shape tables
;
		moveq	#10-1,d7
		lea	igdmovtab(pc),a2
		lea	igdshapetab(pc),a3
.movloop	move.w	(a1)+,d0
		cmp.w	#$1234,d0
		beq.s	.movdef
		cmp.w	#$5678,d0
		beq.s	.movnext
		illegal
.movdef		moveq	#0,d0
		move.w	(a1)+,d0
		move.l	a1,(a3)+		;shape pointer
		add.w	d0,a1
		move.l	a1,(a2)+		;initial pos'n
		lea	ipos.size(a1),a1
.findlast	move.w	movcount(a1),d0
		or.w	angcount(a1),d0		;movcount==0 &&
		lea	movent.size(a1),a1	;angcount==0
		bne.s	.findlast
.movnext	dbra	d7,.movloop
		cmp.w	#$9ABC,(a1)+
		beq.s	.eofok
		illegal
.eofok		sub.l	#igdmovtab,a2
		move.l	a2,d0
		lsr.w	#2,d0
		move.w	d0,igdnumob		;number of objects
		bne.s	.gotsome
		rts				;ummm...zero objects!
;
; fix shapes into object and set initial positions
;
.gotsome	move.w	d0,d7
		subq.w	#1,d7			;number of objects
		lea	igdobtab(pc),a2
		lea	igdshapetab(pc),a3
		lea	igdmovtab(pc),a4
;
; allocate new shape
;
.obloop		move.l	#i_size,d0
		jsr	malloc
		move.l	a1,(a2)+		;save address of obj
		move.l	(a3)+,a0
;
; define important bits in object structure
;
		move.l	a0,ob_shape(a1)
		clr.w	ob_flags(a1)
		move.l	draw_mobile,d0
		add.l	#threed+$1c,d0
		move.l	d0,ob_draw(a1)
		movem.l	d7/a1,-(sp)
		jsr	locate_shape
		movem.l	(sp)+,d7/a1
;
; set initial position and angles
;
		move.l	(a4)+,a0
		movem.l	(a0)+,d0-d2		;init pos
		movem.l	d0-d2,ob_wxyz(a1)
		movem.l	(a0)+,d0-d2		;angles
		movem.l	d0-d2,ob_angxyz(a1)
		move.l	a0,i_ptr(a1)		;movement pointer
;
; create initial orientation matrix
;
		movem.l	d7/a1-a5,-(sp)
		move.w	ob_angxyz(a1),d0
		move.w	ob_angxyz+4(a1),d1
		move.w	ob_angxyz+8(a1),d2
		moveq	#4,d7
		lsr.w	d7,d0
		lsr.w	d7,d1
		lsr.w	d7,d2
		neg.w	d7
		and.w	d7,d0
		and.w	d7,d1
		and.w	d7,d2
		lea	ob_matrix(a1),a2
		jsr	orientation
		movem.l	(sp)+,d7/a1-a5
		dbra	d7,.obloop
		rts

;
; insert igd objects into viewtree
;

insert_igd	move.w	igdnumob(pc),d7
		beq	.empty
		subq.w	#1,d7
		lea	igdobtab(pc),a0
.loop		move.l	(a0)+,a1
		movem.l	d7/a0,-(sp)
		jsr	view_object
		movem.l	(sp)+,d7/a0
		dbra	d7,.loop
.empty		rts

;
; move the introgen objects
;

move_igd	lea	igdobtab(pc),a0
		move.w	igdnumob(pc),d7
		bne.s	.movone
		rts
.movone		move.l	(a0)+,a1
		move.l	i_ptr(a1),a2
		move.w	movcount(a2),d0
		or.w	angcount(a2),d0
		beq	.next
;
; object needs moving
;
		move.w	movcount(a2),d0
		beq	.tryang
		subq.w	#1,movcount(a2)
		movem.l	movdx(a2),d0-d2
		add.l	d0,ob_wxyz(a1)
		add.l	d1,ob_wxyz+4(a1)
		add.l	d2,ob_wxyz+8(a1)
.tryang
;
; object needs rotating
;
		move.w	angcount(a2),d0
		beq	.trynext
		subq.w	#1,angcount(a2)
		movem.l	angdx(a2),d0-d2
		add.l	d0,ob_angxyz(a1)
		add.l	d1,ob_angxyz+4(a1)
		add.l	d2,ob_angxyz+8(a1)
.trynext
;
; move to next movent?
;
		move.w	movcount(a2),d0
		or.w	angcount(a2),d0
		bne	.next
		lea	movent.size(a2),a2
		move.l	a2,i_ptr(a1)
;
; done them all?
;
.next		subq.w	#1,d7
		bne	.movone
		rts

;
; remove igd object which have finished there list
;

remove_igd	move.w	igdnumob(pc),d7
		beq	.exit
		lea	igdobtab(pc),a0
.loop		move.l	(a0)+,a1
		move.l	i_ptr(a1),a2
		move.w	movcount(a2),d0
		or.w	angcount(a2),d0
		bne	.next
;
; remove this entry
;
		move.w	d7,d0
		subq.w	#1,d0
		lea	-4(a0),a1
.remove		move.l	4(a1),(a1)+
		dbra	d0,.remove
		lea	-4(a0),a0
		subq.w	#1,igdnumob
;
; move to next entry
;
.next		subq.w	#1,d7
		bne	.loop
.exit		rts

;***************************************************************************
; Unpacking source for Pack-Ice Version 2.1
; a0: Pointer on packed Data
; a1: Pointer on destination of unpacked data
decrunch:	movem.l d0-a6,-(sp)
		cmpi.l	#'Ice!',(a0)+	; Is data packed?
		bne.s	ice_03		; no!
		move.l	(a0)+,d0	; read packed data
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		movea.l a1,a4
		movea.l a1,a6
		adda.l	(sp),a6
		movea.l a6,a3
		bsr.s	ice_08
		bsr.s	ice_04
ice_03:		movem.l (sp)+,d0-a6
		rts
ice_04:		bsr.s	ice_0c
		bcc.s	ice_07
		moveq	#0,d1
		bsr.s	ice_0c
		bcc.s	ice_06
		lea	ice_1a(pc),a1
		moveq	#4,d3
ice_05:		move.l	-(a1),d0
		bsr.s	ice_0f
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice_05
		add.l	20(a1),d1
ice_06:		move.b	-(a5),-(a6)
		dbra	d1,ice_06
ice_07:		cmpa.l	a4,a6
		bgt.s	ice_12
		rts
ice_08:		moveq	#3,d0
ice_09:		move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice_09
		rts
ice_0a:		move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0b
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice_11
ice_0b:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice_11
ice_0c:		add.l	d7,d7
		beq.s	ice_0d
		rts
ice_0d:		move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0e
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice_0e:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice_0f:		moveq	#0,d1
ice_10:		add.l	d7,d7
		beq.s	ice_0a
ice_11:		addx.w	d1,d1
		dbra	d0,ice_10
		rts
ice_12:		lea	ice_1b(pc),a1
		moveq	#3,d2
ice_13:		bsr.s	ice_0c
		dbcc	d2,ice_13
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice_14
		bsr.s	ice_0f
ice_14:		move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice_16
		lea	ice_1c(pc),a1
		moveq	#1,d2
ice_15:		bsr.s	ice_0c
		dbcc	d2,ice_15
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice_0f
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice_18
ice_16:		moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice_0c
		bcc.s	ice_17
		moveq	#8,d0
		moveq	#$40,d2
ice_17:		bsr.s	ice_0f
		add.w	d2,d1
ice_18:		lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice_19:		move.b	-(a1),-(a6)
		dbra	d4,ice_19
		bra	ice_04
		DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
		DC.B $00,$07,$00,$02,$00,$03,$00,$01
		DC.B $00,$03,$00,$01
ice_1a:		DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
		DC.B $00,$00,$00,$07,$00,$00,$00,$04
		DC.B $00,$00,$00,$01
ice_1b:		DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
		DC.B $01,$00
ice_1c:		DC.B $0b,$04,$07,$00,$01,$20,$00,$00
		DC.B $00,$20

;
; Intro Generator Data file pointers
;

igdscreen	dc.l	0
igd_dlt		dc.l	0
igdnumob	dc.w	0
igdmovtab	ds.l	10
igdshapetab	ds.l	10
igdobtab	ds.l	10
igdpalette	ds.w	32
igdfcount	dc.w	0

igdptr		dc.l	igdtable
igdtable	dc.l	igd1
		dc.l	igd2
		dc.l	igd3
		dc.l	igd4
		dc.l	igd5
		dc.l	igd6
		dc.l	igd7
		dc.l	igd8
		dc.l	igd9
		dc.l	igd10
		dc.l	igd11
		dc.l	igd12
		dc.l	igd13
		dc.l	igd14
		dc.l	0
;
; include 3d files
;

igd1		incbin	"OCTO.IGD"
igd2		incbin	"SOCTO.IGD"
igd3		incbin	"BLOCK.IGD"
igd4		incbin	"HOUSE.IGD"
igd5		incbin	"RINGSHIP.IGD"
igd6		incbin	"CIRC.IGD"
igd7		incbin	"SPHERE.IGD"
igd8		incbin	"DISCS.IGD"
igd9		incbin	"KLI.IGD"
igd10		incbin	"HERRING.IGD"
igd11		incbin	"SPIRAL.IGD"
igd12		incbin	"I_C.IGD"
igd13		incbin	"TORUS.IGD"
igd14		incbin	"CUBEROOM.IGD"
		even

		section	BSS


;
; rest of memory is allocated as needed
;
workspace	ds.l	0
miscmem 	ds.l	16
