;==============================
;=
;=  writeln()
;=
;= Call gemdos to write a string
;= (a0)->string (0-terminated)
;==============================

		section	text
writeln		pea.l	(a0)
		move.w	#9,-(sp)	; Writeln()
		trap	#1
		addq.l	#6,sp
		rts


;==============================
;=
;=  waitkey()
;=
;= Wait for a keypress
;==============================

waitkey		move.w	#8,-(sp)
		trap	#1
		addq.l	#2,sp
		rts
		
		
;==============================
;=
;=  flush
;=
;= Read all data waiting in the
;= IKBD buffer
;==============================

flush		btst.b	#0,$fffffc00.w	; Flush IKBD before leaving
		beq.s	.empty
		move.b	$fffffc02.w,d0
		bra.s	flush		; Read until buffer is empty
.empty		rts
		

;==============================
;=
;=  init
;=
;= Release unneeded memory,
;= reserve screen pages and
;= prepare commandline
;==============================

init		movea.l	(sp)+,a3	; Save return address

		movea.l	sp,a5
		movea.l	4(a5),a5	; Address to basepage

		move.l	$c(a5),d0	; TEXT
		add.l	$14(a5),d0	; DATA
		add.l	$1c(a5),d0	; BSS
		addi.l	#$200,d0	; Stack
		
		move.l	d0,d1
		add.l	a5,d1
		bclr.l	#0,d1		; Even address
		movea.l	d1,sp		; New Stackspace

		move.l	d0,-(sp)
		pea.l	(a5)
		pea.l	$4a0000		; MShrink()
		trap	#1
		lea.l	12(sp),sp

		lea.l	$80(a5),a5	; Command line
		moveq.l	#0,d0
		move.b	(a5)+,d0	; Number of chars
		clr.b	(a5,d0.l)	; Null terminate
		move.l	a5,TgaFileName
		
		
		pea.l	256+max_x*max_y*3/2
		move.w	#$48,-(sp)	; Malloc() space for
		trap	#1		; 3 screens
		addq.l	#6,sp
		
		tst.l	d0		; Error?
		bne.s	.ok

		lea.l	.error(pc),a0
		bra.w	error
		
.ok		addi.l	#256,d0		; Align by a 256 byte boundary
		clr.b	d0
		
		move.l	d0,Tga.picture	; Store pointers screen page

		movea.l	d0,a0		; Clear screen pages
		move.w	#3*max_x*max_y/8-1,d0
.cls		clr.l	(a0)+
		dbra	d0,.cls


		pea.l	(a3)
		rts

		section	data
.error		dc.b	'Could not allocate screens.',13,10,0
		even
		


;==============================
;=
;=  vbl handler
;=
;= Manages the interlacing and
;= scrolling task
;==============================

		section	text
vbl		lea.l	pages(pc),a0		; Get indices to current
		movem.l	(a0)+,a1-a6		; palette & screen page
						
		movem.l	a1-a2,-(a0)		; Cycle pages and gradient
		movem.l	a3-a6,-(a0)

		movem.l	.gradients(pc,a1.l),d0-d7; Validate palette...
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	Tga.picture(pc),a0			
		move.l	(a0)+,d0		; And a new screen page
		movea.l	d0,a3			; for next frame
		add.l	a2,d0
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w


		movea.w	#8*160,a1		; Scrolling
		move.b	$fffffc02.w,d0

		cmpi.b	#$48,d0			; Scroll up?
		bne.s	.notup
		cmpa.l	(a0),a3			; Can we scroll up?
		beq.s	.notup			; Nope
		
		suba.l	a1,a3			; Otherwise do it
		
.notup		cmpi.b	#$50,d0			; Scroll down?
		bne.s	.notdown
		cmpa.l	4(a0),a3		; Touched the bottom?
		bge.s	.notdown		; Yes, get out
		
		adda.l	a1,a3

.notdown	move.l	a3,-(a0)		; Save new page address
		rte
		

.gradients	dc.w	$000,$800,$100,$900	; Gradients optimized
		dc.w	$200,$a00,$300,$b00	; for a 12bit DAC (STE/MSTE/TT)
		dc.w	$400,$c00,$500,$d00
		dc.w	$600,$e00,$700,$f00
		dc.w	$000,$080,$010,$090
		dc.w	$020,$0a0,$030,$0b0
		dc.w	$040,$0c0,$050,$0d0
		dc.w	$060,$0e0,$070,$0f0
		dc.w	$000,$008,$001,$009
		dc.w	$002,$00a,$003,$00b
		dc.w	$004,$00c,$005,$00d
		dc.w	$006,$00e,$007,$00f
		dc.w	$000,$010,$100,$110	; Gradients optimized
		dc.w	$200,$210,$300,$310	; for a 9bit DAC (ST/MST)
		dc.w	$400,$410,$500,$510
		dc.w	$600,$610,$700,$710
		dc.w	$000,$001,$010,$011
		dc.w	$020,$021,$030,$031
		dc.w	$040,$041,$050,$051
		dc.w	$060,$061,$070,$071
		dc.w	$000,$100,$001,$101
		dc.w	$002,$102,$003,$103
		dc.w	$004,$104,$005,$105
		dc.w	$006,$106,$007,$107


		section	data
pages		dc.l	0,max_x*max_y/2	; Current Palette and
		dc.l	32,max_x*max_y	; page to be set for the
		dc.l	64,0		; frame

		section	bss		
Tga.picture	ds.l	1		; Pointer to decoded picture
Tga.upperlimit	ds.l	1		; Address limits (scrolling)
Tga.lowerlimit	ds.l	1		
