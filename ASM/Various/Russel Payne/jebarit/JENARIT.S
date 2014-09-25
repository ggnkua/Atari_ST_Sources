;
; jenarit demo - 29/11/1989
;
; this program is simply for enjoyment and was not intended
; to be changed or seen by anyone else and consequently the
; comments (what there are) might seem very cryptic, but
; normally refer to the number of machine cycles a particular
; piece of code takes to execute
;
; incidentally this program was intended as a menu loader
; and consequently pressing the numeric keys 1 or 2 will
; result in the program attempting to load Bloodwych and
; football respectively
;
; Russell Payne
;
xmax		equ	320+80
nspr		equ	4
sline		equ	170
bottom		equ	200
middle		equ	sline-16-16-16+1
leftover	equ	bottom-sline-16-4-2
;
cycle40 	macro
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		endm
;
; getchar macro (320 cycles!)
;
gcmac		macro
		jsr	getchar 		;278 + 20 = 298
		lea	ws(pc),a2		;8
		lea	bitmap0(pc),a3		;8
		nop				;4
		endm
scroll		macro
		asl.w	(a2)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		roxl.w	(a3)+			;12
		nop
		nop
		endm
map16		macro
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		endm
map9start	macro
		lea	bitmap0(pc),a2			;8
		move.l	rowtable+sline*4,a3		;20
		lea	200-2(a3),a3			;8
		nop
		cycle40
		cycle40 				;308
		nop
		nop
		nop
		lea	2*(160+70)(a3),a3		;8
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3				;188
		endm
map9		macro
		lea	160+70+25*8(a3),a3		;8
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3
		move.w	(a2)+,(a3)
		subq.w	#8,a3			;188
		cycle40
		cycle40
		cycle40 			;308
		nop
		nop
		nop
		endm
;
;
start		move.l	#freemem+256,d0
		clr.b	d0
		move.l	d0,screen1
		pea	getopt(pc)
		move.w	#38,-(sp)
		trap	#14
		addq.w	#6,sp
		moveq	#0,d0
		move.b	key(pc),d0
		lea	proglist(pc),a0
		bsr	loadprog
		clr.l	-(sp)
		trap	#1
loadprog	cmp.w	(a0)+,d0
		beq.s	.doload
		tst.w	(a0)+
		bne.s	loadprog
		rts
.doload 	add.w	(a0)+,a0
		bsr	loadfile
		bra	exec
proglist	dc.w	$82,bloodw-*-4
		dc.w	$83,footb-*-4
		dc.w	0,0
bloodw		dc.b	"bloodw.prg",0
footb		dc.b	"football.prg",0
		even
loadfile	clr.w	-(sp)
		pea	(a0)
		move.w	#$3d,-(sp)
		trap	#1
		addq.w	#8,sp
		move.w	d0,d7
		bmi.s	.error
		pea	pakprog
		pea	512*1024
		move.w	d7,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	d7,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.w	#4,sp
.error		rts
;
; fancy, full width selection
;
getopt		move.w	sr,-(sp)
		move.w	#$2700,sr
		move.b	$fffffa07.w,iea
		move.b	$fffffa09.w,ieb
		clr.b	$fffffa07.w
		clr.b	$fffffa09.w
		move.l	$70.w,vbl
		move.l	#vblank,$70.w
		move.l	$ffff8200.w,vbase
		movem.l $ffff8240.w,d0-d7
		movem.l d0-d7,ospal
		lea	erasetable,a0
		moveq	#-1,d0
		move.w	#nspr-1,d1
.clrera 	move.l	d0,(a0)+
		rept	8
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		endr
		dbra	d1,.clrera
;
; initial sprite positions and directions
;
		lea	sprpos,a0
		lea	random,a2
		lea	deltatab,a3
		move.w	#nspr-1,d7
.getx		jsr	(a2)
		cmp.w	#xmax,d0
		bhi.s	.getx
		move.w	d0,(a0)+		;x,y,dx,dy
.gety		jsr	(a2)
		cmp.w	#bottom,d0
		bhi.s	.gety
		move.w	d0,(a0)+
.getdx		jsr	(a2)
		and.w	#3,d0			;0,1,2,3
		add.w	d0,d0			;0,2,4,6
		move.w	0(a3,d0.w),(a0)+
.getdy		jsr	(a2)
		and.w	#3,d0			;0,1,2,3
		add.w	d0,d0			;0,2,4,6
		move.w	0(a3,d0.w),(a0)+
		dbra	d7,.getx
;
; force hardware to display our screen
;
		clr.b	$ffff8260.w		;low-rez
		move.b	#2,$ffff820a.w		;50hz refresh
		move.l	screen1,d0
		lsr.w	#8,d0			;force h/w to
		move.l	d0,$ffff8200.w		;display this screen
;
		movem.l palette(pc),d0-d7
		movem.l d0-d7,$ffff8240.w
;
; clear screen
;
		move.l	screen1,a5
		move.w	#(64000/16),d0
.cls		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		clr.l	(a5)+
		dbra	d0,.cls
;
; draw vertical lines
;
		lea	rowtable,a4
		move.l	screen1,a0
		add.w	#2*160+70+150-8,a0
		move.w	#bottom-2,d0
		move.w	#%0011001100110011,d2
		move.w	#%0000111100001111,d3
		move.w	#%0000000011111111,d4
		move.w	#%0000000000000000,d5
		move.w	#%0011001100110011,d6
		move.w	#%0000111100001111,d7
		move.w	#%0000000011111111,a2
		move.w	#%0000000000000000,a3
.loop		move.l	a0,a1
		move.w	#27/2,d1
.middle 	move.w	d2,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d5,(a1)+
		move.w	d6,(a1)+
		move.w	d7,(a1)+
		move.w	a2,(a1)+
		move.w	a3,(a1)+
		dbra	d1,.middle
		move.l	a0,(a4)+		;save address
		add.w	#160+70,a0
		dbra	d0,.loop
		move.l	a0,(a4)+		;a few more
		move.l	a0,(a4)+		;a few more
		move.l	a0,(a4)+		;a few more
		move.l	a0,(a4)+		;a few more
;
; now draw the Jenarit sprite and start the music playing
;
		lea	jenarit,a0
		move.w	#200,d0 		;middle of screen
		move.w	#bottom/2-16,d1
		jsr	draw4
		moveq	#0,d0
		jsr	sound
;
;================ CAN'T USE REGISTERS ===========
;
		move.w	#$2300,sr
loop		move.b	$fffffc02.w,key
		cmp.b	#$82,key		;"1"
		beq	.gotkey
		cmp.b	#$83,key		;"2"
		beq	.gotkey
.wait		cmp.b	#$81,key
		bne	loop			;"esc"
.gotkey
;
;================================================
;
		move.w	#$2700,sr
		move.b	iea(pc),$fffffa07.w
		move.b	ieb(pc),$fffffa09.w
		move.l	vbl(pc),$70.w
.clrkey 	bclr	#4,$fffffa0d.w
		bne.s	.clrkey
		move.l	vbase(pc),$ffff8200.w
		movem.l ospal(pc),d0-d7
		movem.l d0-d7,$ffff8240.w
		move.b	#7,$ffff8800.w
		move.b	$ffff8800.w,d0
		and.b	#%11000000,d0
		or.b	#%00111111,d0
		move.b	d0,$ffff8802.w
		move.w	(sp)+,sr
		rts

palette 	dc.w	$700,$222,$333,$555,$666,$555,$333,$222
		dc.w	$707,$070,$321,$432,$543,$654,$765,$777

key		dc.w	0
iea		dc.w	0
ieb		dc.w	0
vbl		dc.l	0
ospal		ds.w	16
vbase		dc.l	0

;
; relocate to this address
;
exec		lea	pakprog,a0
		cmp.w	#$601a,(a0)
		beq.s	.ok
		clr.l	-(sp)
		trap	#1			;abort if not prog
.ok		lea	start(pc),a2
		bsr	reloc
;
; fill in empty basepage variables for the new program
;
		lea	pakprog+2,a0
		lea	start-256+8(pc),a1
		lea	start(pc),a2
		move.l	a2,(a1)+		;text start address
		move.l	(a0),(a1)+		;text size
		add.l	(a0)+,a2
		move.l	a2,(a1)+		;data start
		move.l	(a0),(a1)+		;data size
		add.l	(a0)+,a2
		move.l	a2,(a1)+		;bss start
		move.l	(a0),(a1)+		;bss size
		move.l	a2,a3
		add.l	(a0),a3
;
; move program to address it's going to be run at
;
		lea	pakprog+$1c,a0
		lea	start(pc),a1
		move.l	a1,a4
		movem.l movmem(pc),d0-d7
		movem.l d0-d7,-256(sp)
		jmp	-256(sp)

movmem: 	move.b	(a0)+,(a1)+		;			(2)
		cmp.l	a2,a1			;copy to run address	(2)
		ble.s	movmem			;			(2)
clrmem: 	clr.b	(a1)+			;clear bss segment	(2)
		cmp.l	a3,a1			;			(2)
		ble.s	clrmem			;			(2)
		jmp	(a4)			;and exec program	(2)

;--------------------------------------------------------------------------
; procedure:		reloc
; description:		relocate program to given address
;
; entry:
;	a0 = address of program
;	a2 = address to be run from
;
; exit:
;
;--------------------------------------------------------------------------

reloc:
		tst.w	$1a(a0) 		;any reloc info?
		bne.s	noreloc
		move.l	2(a0),a1		;text size in bytes
		add.l	6(a0),a1		;data size in bytes
		add.l	14(a0),a1		;symbols size in bytes
		lea	$1c(a0),a0
		add.l	a0,a1
		move.l	a2,d0			;address for relocation
		move.l	(a1)+,d1
		beq.s	noreloc
		add.l	d1,a0
		add.l	d0,(a0) 		;relocate 1st
		moveq.l #0,d1			;this rather
		moveq.l #1,d2			;awkward arrangement
		move.l	#$fe,d3 		;allows for a more
		move.b	(a1)+,d1		;efficient inner
		beq.s	noreloc 		;loop
		bra.s	doanother
bigoffset	add.l	d3,a0			;skip 254 bytes
		move.b	(a1)+,d1
		beq.s	noreloc
doanother	cmp.b	d2,d1
		beq.s	bigoffset
		add.l	d1,a0			;relocate longword
		add.l	d0,(a0) 		;at given offset
getnext 	move.b	(a1)+,d1
		bne.s	doanother
noreloc 	rts

pakprog 	dc.w	0

vblank
		lea	palette(pc),a3
		movem.w (a3),d0-d6/a6
		movem.w d0-d6,2(a3)
		move.w	a6,(a3)
		move.w	#$8240,a4
		movem.w d0-d6,2(a4)
		move.w	#$700,(a4)
		movem.l 8*2(a3),d0-d3
		movem.l d0-d3,2*8(a4)		;set other colours
		move.w	#$8209,a0
		move.w	#$820a,a1
		move.w	#$8260,a2
		moveq	#0,d1
		moveq	#2,d2
		move.b	d2,(a2)
		nop
		move.b	d1,(a2)
		move.b	d1,(a1)
		nop
		move.b	d2,(a1)
		moveq	#0,d0
.sync		move.b	(a0),d0
		beq.s	.sync
		jmp	.jmptab(pc,d0.w)
.jmptab 	rept	242
		nop
		endr
;
; start of 2nd scanline (512 cycles per scanline)
;
		nop
		nop
		gcmac				;320 cycles
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		move.w	a6,(a4) 		;8 (set backgnd colour)
;++++
		rept	16
		nop
		nop
		scroll
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		endr
;++++
		nop
		nop
		map9start
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
;=
		nop
		nop
		map16
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
;?????????????
		rept	15
		nop
		nop
		map9
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
;=
		nop
		nop
		map16
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		endr
;++++
		rept	middle
		nop
		nop
		jsr	cycle320		;waste 320 cycles
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		endr
		rept	17
		nop
		nop
		jsr	priority		;set colours
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		endr
		nop
		nop
		jsr	norm815 		;set colours
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		rept	leftover
		nop
		nop
		jsr	cycle320		;waste 320 cycles
		nop
		nop
		move.b	d1,(a1) 		;8
		move.b	#2,(a1) 		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#2,$ffff8260.w		;16
		move.b	d1,$ffff8260.w		;12
		nop
		nop
		nop
		nop
		nop
		endr
		move.w	#$700,$ffff8240.w
		lea	erasetable+nspr*(16*8+4),a4
		moveq	#nspr-1,d0
		moveq	#-1,d1
.erasesprites	lea	-(16*8+4)(a4),a4
		move.l	(a4)+,a0
		cmp.l	a0,d1
		beq.s	.dontclr
		move.l	a4,a1
		rept	8
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		lea	160+70-16(a0),a0
		endr
.dontclr	move.l	d1,-(a4)
		dbra	d0,.erasesprites
		lea	erasetable,a4
		lea	sprtable,a5
		lea	sprpos,a6
		move.w	#nspr,-(sp)
.dsloop 	movem.w (a6)+,d0-d3
		add.w	d2,d0
		bmi.s	.xneg
		cmp.w	#xmax,d0
		blt.s	.xok
.xneg		neg.w	d2
.xok		add.w	d3,d1
		bmi.s	.yneg
		cmp.w	#bottom,d1
		blt.s	.yok
.yneg		neg.w	d3
.yok		movem.w d0-d3,-8(a6)
		move.l	(a5)+,a0
		jsr	draw_sprite(pc)
		lea	16*8+4(a4),a4
		subq.w	#1,(sp)
		bne	.dsloop
		tst.w	(sp)+
		jsr	sound+$0e
		move.l	colscr(pc),colptr
		subq.w	#1,slowmo
		bne.s	.norsr
		move.w	#3,slowmo
		addq.l	#2,colscr
		subq.w	#1,colcnt
		bne.s	.norsr
		move.l	#coltab,colscr
		move.w	#32,colcnt
.norsr		rte
;
; scrolling stuff
;
getchar 	lea	count(pc),a2			;8
		subq.w	#1,(a2) 			;12
;20
		bne.s	.notyet 			;jump=10 thru=8
		move.w	#8,(a2)+			;12
		move.l	(a2),a0 			;12
		clr.w	d0				;4
		move.b	(a0)+,d0			;8
;64
		beq.s	.eom				;jump=10 thru=8
		move.l	a0,(a2) 			;12
		lea	font(pc),a2			;8
		asl.w	#4,d0				;6+2*4
		add.w	d0,a2				;8
		movem.l (a2),d0/d2/d3/d4		;12+8*4
		lea	ws(pc),a2			;8
		movep.l d0,0(a2)			;24
		movep.l d2,8(a2)			;24
		movep.l d3,16(a2)			;24
		movep.l d4,24(a2)			;24
		rts					;16
;---278

.eom		move.l	#txtstart,(a2)			;20
		jsr	smallwait			;(76)
		jsr	smallwait			;(76)
		nop					;4
		nop					;4
		nop					;4
		nop					;4
		rts					;16
;---110 + 76 + 76 + 16 --> 278

.notyet 	jsr	smallwait			;(76)
		jsr	smallwait			;(76)
		jsr	smallwait			;(76)
		nop					;4
		rts					;16
;---46 + 76 + 76 + 76 + 4 --> 278

;
; routine to set colours 8-15 to same value for priority (300 cycles)
;
priority	lea	colptr(pc),a2			;8
		move.l	(a2),a3 			;12
		move.w	(a3)+,d0			;8
		move.l	a3,(a2) 			;12
		move.w	#$8240+8*2,a3			;8
		move.w	d0,(a3)+			;8...0
		move.w	d0,(a3)+			;8...1
		move.w	d0,(a3)+			;8...2
		move.w	d0,(a3)+			;8...3
		move.w	d0,(a3)+			;8...4
		move.w	d0,(a3)+			;8...5
		move.w	d0,(a3)+			;8...6
		move.w	d0,(a3) 			;8...7
		jsr	smallwait			;76
		jsr	smallwait			;76
		nop
		nop
		nop
		nop
		nop
		rts
;
; reset colours 8-15 back to normal (300 cycles)
;
norm815 	lea	palette+8*2(pc),a2		;8
		move.w	#$8240+8*2,a3			;8
		move.l	(a2)+,(a3)+			;20
		move.l	(a2)+,(a3)+			;20
		move.l	(a2)+,(a3)+			;20
		move.l	(a2)+,(a3)+			;20
		jsr	smallwait			;76
		jsr	smallwait			;76
		nop
		nop					;4 * 9 = 36
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		rts					;16

smallwait	cycle40
		rts					;76 cycles

cycle320	cycle40
		cycle40
		cycle40
		cycle40
		cycle40
		cycle40
		cycle40
		nop
		rts

count		dc.w	100
msgptr		dc.l	txtstart
ws		ds.w	16
slowmo		dc.w	3
colscr		dc.l	coltab
colcnt		dc.w	32
colptr		dc.l	coltab
coltab		dc.w	$123		;0
		dc.w	$123		;1
		dc.w	$345		;2
		dc.w	$345		;3
		dc.w	$456		;4
		dc.w	$456		;5
		dc.w	$567		;6
		dc.w	$567		;7
		dc.w	$567		;8
		dc.w	$567		;9
		dc.w	$456		;10
		dc.w	$456		;11
		dc.w	$345		;12
		dc.w	$345		;13
		dc.w	$123		;14
		dc.w	$123		;15
		dc.w	$231		;0
		dc.w	$231		;1
		dc.w	$453		;2
		dc.w	$453		;3
		dc.w	$564		;4
		dc.w	$564		;5
		dc.w	$675		;6
		dc.w	$675		;7
		dc.w	$675		;8
		dc.w	$675		;9
		dc.w	$564		;10
		dc.w	$564		;11
		dc.w	$453		;12
		dc.w	$453		;13
		dc.w	$231		;14
		dc.w	$231		;15
		dc.w	$123		;0
		dc.w	$123		;1
		dc.w	$345		;2
		dc.w	$345		;3
		dc.w	$456		;4
		dc.w	$456		;5
		dc.w	$567		;6
		dc.w	$567		;7
		dc.w	$567		;8
		dc.w	$567		;9
		dc.w	$456		;10
		dc.w	$456		;11
		dc.w	$345		;12
		dc.w	$345		;13
		dc.w	$123		;14
		dc.w	$123		;15
		dc.w	$123		;?

bitmap0 	ds.w	25
bitmap1 	ds.w	25
bitmap2 	ds.w	25
bitmap3 	ds.w	25
bitmap4 	ds.w	25
bitmap5 	ds.w	25
bitmap6 	ds.w	25
bitmap7 	ds.w	25
bitmap8 	ds.w	25
bitmap9 	ds.w	25
bitmapa 	ds.w	25
bitmapb 	ds.w	25
bitmapc 	ds.w	25
bitmapd 	ds.w	25
bitmape 	ds.w	25
bitmapf 	ds.w	25
;
; a0 = ptr to sprite data
; d0 = x
; d1 = y
;
; sprite data:
;		dc.w	half-width	(for center)	(3)
;		dc.w	half-height			(3)
;		dc.w	width				(7)
;		dc.w	height-1			(6)
;
draw_sprite	lea	rowtable(pc),a2
		incbin	"sprite.bin"
;
; draw a normal four bitplane sprite
;
; A0 = pointer to sprite data
; D0 = x coordinate
; D1 = y coordinate
;
draw4
		move.w	(a0)+,a4
		move.w	(a0)+,d4
		sub.w	(a0)+,d0
		move.w	d0,d2
		move.w	a4,d3
		asl.w	#4,d3			;16 pixels / block
		add.w	d3,d2
		sub.w	(a0)+,d1
		move.w	d1,d3
		add.w	d4,d3
		sub.l	a2,a2
		move.w	d0,d3
		and.w	#$0f,d3
		subq.w	#1,a4
		lea	rowtable,a1
		add.w	d1,d1
		add.w	d1,d1
		move.l	0(a1,d1.w),a1
		sub.w	d3,d0
		asr.w	#1,d0
		add.w	d0,a1

.doline 	move.l	a1,a5
		swap	d4
		move.w	a4,d4
.doblock	movem.w (a0)+,d0-d3
		move.w	d0,d5
		or.w	d1,d5
		or.w	d2,d5
		or.w	d3,d5
		not.w	d5
		and.w	d5,(a5)
		or.w	d0,(a5)+
		and.w	d5,(a5)
		or.w	d1,(a5)+
		and.w	d5,(a5)
		or.w	d2,(a5)+
		and.w	d5,(a5)
		or.w	d3,(a5)+
		dbra	d4,.doblock
		add.w	#160+70,a1
		swap	d4
		dbra	d4,.doline
		rts

;--------------------------------------------------------------------------
;
; pseudo-random number generator returns D0.L
;
;--------------------------------------------------------------------------

random		move.w	d1,-(sp)
		move.w	d2,-(sp)
		move.w	d3,-(sp)
		move.l	seed(pc),d0
		move.w	#$11,d3
.dobit		move.w	#$1f,d1
		move.w	#$18,d2
		btst	d1,d0
		sne	d1
		btst	d2,d0
		sne	d2
		eor.w	d2,d1
		roxr.w	#1,d1
		roxl.l	#1,d0
		dbra	d3,.dobit
		move.l	d0,seed
		move.w	(sp)+,d3
		move.w	(sp)+,d2
		move.w	(sp)+,d1
		rts

seed		dc.l	$31415926
rowtable	ds.l	bottom+8

sprtable	dc.l	r.spr
		dc.l	e.spr
		dc.l	a.spr
		dc.l	p.spr
erasetable	ds.b	nspr*(8*16+4)+4
		even
deltatab	dc.w	-2,-1,+1,+2
sprpos		ds.l	nspr*2
r.spr		incbin	"r.spr"
e.spr		incbin	"e.spr"
a.spr		incbin	"a.spr"
p.spr		incbin	"p.spr"
font		incbin	"daisyw.fnt"
		even
txtstart	dc.b	"Hi There ......."
		dc.b	"......... The "
		dc.b	"creature above is called a JENARIT and was scanned "
		dc.b	"using my Ladbroke IMG scanner, from an old issue of "
		dc.b	"the comic 2000AD .... The music has been stolen from a "
		dc.b	"game called Beyond The Ice Palace .................. "
		dc.b	" If you're "
		dc.b	"interested, there are about 512 machine cycles per scanline and "
		dc.b	"in this demo I've still got around « a raster free ...... "
		dc.b	"Well that's it really ......."
		dc.b	".............."
		dc.b	"............... Long live the Atari ST ................."
		dc.b	".............. the password on the Spreadpoint Demo is really a joke "
		dc.b	"..........................  rule ok ..................."
		dc.b	".......................... Lets start again then ........."
		dc.b	"                    ""
		dc.b	0,0
		even
jenarit 	incbin	"jenarit.sp4"
sound		incbin	"ice.mus"
screen1 	dc.l	0
freemem 	dc.w	0

		end
