; FalconScreen
; ============
;
; Copyright 1993 by Markus Gutschke
;
; For detailed information read the README file or the header
; of the C module
;
;
; Export interfaces to system calls
		export	LineA0
		export	Kbshift,Physbase,Setscreen,Vsetmode,Montype
		export	VsetRGB,VgetRGB
		export	Pterm0,Cnecin,Cconws,Cconis,Srealloc,Super,Fopen
		export	Fclose,Fread,Fwrite,Fseek,Malloc,Mfree
; Import some C-function and global variables
		import	main,init,setscreen,vsetmode,vgetsize
		import	settings

		equ		stacksize,$1000	; the programs initial stack size
		equ		ID,$E4465343	; XBRA Id (c.f. C module)

		offset	0				; data structure of the patch
magic:	ds.l	1				; area
size:	ds.w	1
mask:	ds.w	1
value:	ds.w	1
planes:	ds.w	1
n:		ds.w	1
width:	ds.w	1
height:	ds.w	1
		
		text

		bra.b	start			; this instruction has to be 2 bytes long
set:	dc.l	settings		; pointer to patch area
start:	move.l	set,a0			; check integrity of the executable
		cmpi.l	#ID,magic(a0)
		beq		valprg
Pterm0:	clr.w	-(sp)			; terminate
		trap	#1
valprg:	move.l	4(sp),a0		; get address of basepage
		move.l	#256,d0			; calculate program size
		add.l	12(a0),d0
		add.l	20(a0),d0
		add.l	28(a0),d0
		move.l	d0,d1
		add.l	#stacksize,d1	; initialize user stack
		move.l	d1,d2
		add.l	a0,d2
		andi.b	#$FC,d2
		move.l	d2,sp
		clr.w	-(sp)			; set parameters for Ptermres
		move.l	d0,-(sp)
		move.w	#$31,-(sp)
		move.l	d1,-(sp)		; Mshrink
		pea		(a0)
		move.l	#$4a0000,-(sp)
		trap	#1
		lea		$c(sp),sp
		bsr		main			; call C module
		move.w	d0,-(sp)
		pea		vdiinit			; initialize trap handler
		move.w	#$26,-(sp)
		trap	#$e
		addq.l	#6,sp
		tst.w	(sp)+
		beq		done
		move.l	#$00030088,-(sp); force reinitialization of
		pea		0.w				; video mode...
		pea		0.w				; (does not work under MiNT!)
		move.w	#$5,-(sp)
		trap	#$e
		lea		$e(sp),sp

; pour du VGA uniquement

		move.l	#$0003001a,-(sp)
		pea		0.w
		pea		0.w
		move.w	#$5,-(sp)
		trap	#$e
		lea		$e(sp),sp

; pour du RVB uniquement

;		move.l	#$000300a2,-(sp)
;		pea		0.w
;		pea		0.w
;		move.w	#$5,-(sp)
;		trap	#$e
;		lea		$e(sp),sp

done:	trap	#1				; Ptermres

vdiinit:move.l	$88.w,vdivec	; link into trap handler
		move.l	#vdihdl,$88.w
		move.l	$b8.w,xbvec
		move.l	#xbhdl,$b8.w
		rts

		dc.l	'XBRA'
		dc.l	ID
vdivec:	ds.l	1
vdihdl:	cmpi.w	#115,d0			; check for VDI call
		beq		isvdi
doold:	move.l	vdivec,-(sp)
		rts
isvdi:	move.l	d1,a0
		move.l	(a0),a1
		cmpi.w	#1,(a1)			; check for v_opnwk
		bne		doold
		move.l	4(a0),a1
		cmpi.w	#11,(a1)		; check device handle
		bhs		doold
		move.l	a0,-(sp)
		tst.w	$59e.w			; set up fake stack frame
		beq		vshort
		clr.w	-(sp)
vshort:	pea		vcont(pc)
		move.w	sr,-(sp)
		move.l	vdivec,-(sp)
		rts						; call v_opnw
vcont:	move.l	#$58ffff,-(sp)	; check resolution
		trap	#$e
		addq.l	#4,sp
		move.l	set,a0
		and.w	mask(a0),d0
		cmp.w	value(a0),d0
		movem.l	(sp)+,a0
		bne		illres
		move.l	$c(a0),a1		; patch intout array
		move.l	set,a0
		move.w	width(a0),d0
		subq	#1,d0
		move.w	d0,(a1)
		move.w	height(a0),d0
		subq	#1,d0
		move.w	d0,2(a1)
		moveq	#1,d0
		move.w	planes(a0),d1
		lsl.w	d1,d0
		move.w	d0,26(a1)
		movem.l	d0-d2,-(sp)
		moveq	#0,d0
		bsr		init			; initialize without realloc!
		movem.l	(sp)+,d0-d2
illres:	rte


		dc.l	'XBRA'
		dc.l	ID
xbvec:	ds.l	1
xbhdl:	move.l	usp,a0
		btst.b	#5,(sp)
		beq		xbstk
		lea		6(sp),a0
		tst.w	$59e.w
		beq		xbstk
		lea		8(sp),a0
xbstk:	move.w	(a0),d0
		cmpi.w	#5,d0			; Vsetscreen
		bhi		nosetsc
		blo		oldxb
		lea		xscont(pc),a1
xbfake:	move.l	$c(a0),-(sp)	; copy parameters
		move.l	$8(a0),-(sp)
		move.l	$4(a0),-(sp)
		move.l	(a0),-(sp)
		tst.w	$59e.w			; set up fake stack frame
		beq		xbshort
		clr.w	-(sp)
xbshort:pea		(a1)
		move.w	sr,-(sp)
oldxb:	move.l	xbvec,-(sp)		; call old xbios handler
		rts
nosetsc:cmpi.w	#$58,d0			; Vsetmode
		blo		oldxb
		bhi		novsmd
		lea		xmcont(pc),a1
		bra		xbfake
novsmd:	cmpi.w	#$5b,d0			; Vgetsize
		bne		oldxb
		lea		xzcont(pc),a1
		bra		xbfake
xscont:	move.w	$a(sp),d1
		move.w	$c(sp),d2
		move.l	6(sp),a1
		move.l	2(sp),a0
		bsr		setscreen
		lea		$10(sp),sp
		rte
xmcont:	move.w	2(sp),d1
		bsr		vsetmode
		lea		$10(sp),sp
		rte
xzcont:	move.w	2(sp),d1
		bsr		vgetsize
		lea		$10(sp),sp
		rte

;
; this is a list of binding for OS calls, so we do not need to link
; any libraries...
;

LineA0:	movem.l	d3-d7/a2-a6,-(sp)
		dc.w	$a000
		move.l	d0,a0
		movem.l	(sp)+,d3-d7/a2-a6
		rts

Kbshift:move.l	a2,-(sp)
		move.w	d0,-(sp)
		move.w	#$b,-(sp)
		trap	#$d
		addq.l	#4,sp
		move.l	(sp)+,a2
		rts

Physbase:move.l	a2,-(sp)
		move.w	#2,-(sp)
		trap	#$e
		addq.l	#2,sp
		move.l	d0,a0
		move.l	(sp)+,a2
		rts

Setscreen:move.l a2,-(sp)
		move.w	d1,-(sp)
		move.w	d0,-(sp)
		pea		(a1)
		pea		(a0)
		move.w	#5,-(sp)
		trap	#$e
		lea		$e(sp),sp
		move.l	(sp)+,a2
		rts

Vsetmode:move.l	a2,-(sp)
		move.w	d0,-(sp)
		move.w	#$58,-(sp)
		trap	#$e
		addq.l	#4,sp
		move.l	(sp)+,a2
		rts

Montype:move.l	a2,-(sp)
		move.w	#$59,-(sp)
		trap	#$e
		addq.l	#2,sp
		move.l	(sp)+,a2
		rts

VgetRGB:move.w	#$5e,d2
		bra		VRGB
VsetRGB:move.w	#$5d,d2
VRGB:	move.l	a2,-(sp)
		move.l	a0,-(sp)
		move.w	d1,-(sp)
		move.w	d0,-(sp)
		move.w	d2,-(sp)
		trap	#$e
		lea		$a(sp),sp
		move.l	(sp)+,a2
		rts

Cnecin:	movem.l	d3-d4/a2-a4,-(sp)
		move.w	#8,-(sp)
		trap	#1
		addq.l	#2,sp
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Cconws:	movem.l	d3-d4/a2-a4,-(sp)
		pea		(a0)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Cconis:	movem.l	d3-d4/a2-a4,-(sp)
		move.w	#$b,-(sp)
		trap	#1
		addq.l	#2,sp
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Srealloc:movem.l d3-d4/a2-a4,-(sp)
		move.l	d0,-(sp)
		move.w	#$15,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,a0
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Super:	movem.l d3-d4/a2-a4,-(sp)
		pea		(a0)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,a0
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Fopen:	movem.l d3-d4/a2-a4,-(sp)
		move.w	d0,-(sp)
		pea		(a0)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Fclose:	movem.l d3-d4/a2-a4,-(sp)
		move.w	d0,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Fread:	movem.l d3-d4/a2-a4,-(sp)
		pea		(a0)
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea		$c(sp),sp
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Fwrite:	movem.l d3-d4/a2-a4,-(sp)
		pea		(a0)
		move.l	d1,-(sp)
		move.w	d0,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea		$c(sp),sp
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Fseek:	movem.l d3-d4/a2-a4,-(sp)
		move.w	d2,-(sp)
		move.w	d1,-(sp)
		move.l	d0,-(sp)
		move.w	#$42,-(sp)
		trap	#1
		lea		$a(sp),sp
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Malloc:	movem.l	d3-d4/a2-a4,-(sp)
		move.l	d0,-(sp)
		move.w	#$48,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,a0
		movem.l	(sp)+,d3-d4/a2-a4
		rts

Mfree:	movem.l	d3-d4/a2-a4,-(sp)
		move.l	a0,-(sp)
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d3-d4/a2-a4
		rts

		end
