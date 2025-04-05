; Altparty 2009 STe demo
; Fullscreen skyline effect
;
; skyline.s

		section	text


;-------------- INIT
skyline_init:	rts
		


;-------------- RUNTIME INIT
skyline_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		;generate colour fade
		move.l	#skyline_fade,.fadeadr	;black->pal
		move.w	#48-1,.count
.fade1:		movem.l	skyline_pal_black,d0-d7
		move.l	.fadeadr,a0
		movem.l	d0-d7,(a0)
		add.l	#32,.fadeadr
		lea.l	skyline_pal_black,a0
		lea.l	skyline_pal,a1
		jsr	component_fade
		subq.w	#1,.count
		bpl.s	.fade1


		;depack skyline datas
		lea.l	skyline_ice,a0	
		lea.l	skyline_data,a1
		bsr.w	ice

		;copy background to double width
		lea.l	skyline_bg,a0
		lea.l	skyline_bgshift,a1
		lea.l	416/8(a1),a2
		move.w	#32-1,d7
.dualy:		move.w	#416/32-1,d6
.dualx:		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		dbra	d6,.dualx
		lea.l	416/8(a1),a1
		lea.l	416/8(a2),a2
		dbra	d7,.dualy

		;shift background 4 steps
		lea.l	skyline_bgshift,a0
		lea.l	832*32/8(a0),a1
		move.w	#8-2,d7 ;first step already done
.shiftnum:	move.w	#32-1,d6
.shifty:	move.w	#832/16-1,d5
.shiftx:	move.l	(a0),d0
		lsl.l	#2,d0
		swap	d0
		move.w	d0,(a1)+
		addq.l	#2,a0
		dbra	d5,.shiftx
		dbra	d6,.shifty
		dbra	d7,.shiftnum


		;fill lower part of the background
		move.l	screen_adr,a0
		move.l	screen_adr2,a1
		ifne	hatari
		add.l	#230*242+6+160,a0
		add.l	#230*242+6+160,a1
		endc
		ifeq	hatari
		add.l	#224*242+6+160,a0
		add.l	#224*242+6+160,a1
		endc
		moveq.l	#-1,d0
		move.w	#31-1,d7
.bgy:		move.w	#26-1,d6
.bgx:		move.w	d0,(a0)
		move.w	d0,(a1)
		addq.l	#8,a0
		addq.l	#8,a1
		dbra	d6,.bgx
		ifne	hatari
		lea.l	230-208(a0),a0
		lea.l	230-208(a1),a1
		endc
		ifeq	hatari
		lea.l	224-208(a0),a0
		lea.l	224-208(a1),a1
		endc
		dbra	d7,.bgy
		

		;overscan code copy
		lea.l	generic_code,a0			;copy overscan code
		move.l	#skyline_code1_end,d0		;top 228 lines
		sub.l	#skyline_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#228-1,d7
.code1a:	move.l	d0,d6
		lea.l	skyline_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#skyline_code2_end,d0		;low border + cleanup line
		sub.l	#skyline_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	skyline_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#skyline_code1_end,d0		;lower 43 lines (uses same code as top lines)
		sub.l	#skyline_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#43-1,d7
.code3a:	move.l	d0,d6
		lea.l	skyline_code1_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a
		move.w	dummy,(a0)+	;rts

		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1
.fadeadr:	dc.l	skyline_fade
.count:		dc.w	48-1

;-------------- VBL
skyline_vbl:
		lea.l	$ffff8203.w,a0			;2
		move.l	screen_adr,d0			;5
		movep.l	d0,0(a0)			;6

		lea.l	skyline_fade,a0
		add.w	skyline_fadepos,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	skyline_bpl,a0
		move.w	(a0),d0
		rept	5
		move.w	2(a0),(a0)+
		endr
		move.w	d0,(a0)+

		cmp.l	#52*53*178,skyline_frame
		blt.s	.add
		clr.l	skyline_frame
		bra.s	.done
.add:		add.l	#52*53,skyline_frame
.done:

		bsr.w	skyline_background
		
		
		rts


skyline_fadein1:
		bsr.w	skyline_vbl
		tst.w	skyline_rastofs
		ble.s	.rastdone
		subq.w	#8,skyline_rastofs
.rastdone:	rts

skyline_fadein2:
		bsr.s	skyline_fadein1
		subq.w	#1,.wait
		bne.s	.done
		move.w	#8,.wait
		cmp.w	#31*48,skyline_fadepos
		bge.s	.done
		add.w	#32,skyline_fadepos
.done:		rts
.wait:		dc.w	1

skyline_fadeout:
		bsr.w	skyline_vbl

		cmp.w	#57*10*2,skyline_rastofs
		bge.s	.rastdone
		add.w	#20,skyline_rastofs
.rastdone:	
		tst.w	skyline_fadepos
		ble.s	.done
		sub.w	#32,skyline_fadepos
		rts

.done:		
		clr.w	skyline_fadepos		;clamp to 0
		rts


skyline_background:
		;copy scrolling background graphics

		move.l	.bgpos,d0
		move.l	d0,d1
		
		and.l	#$0000000f,d0	;nibble
		lsl.l	#2,d0
		lea.l	.nibbleofs,a0
		move.l	(a0,d0.l),d0
		
		lsr.l	#4,d1		;addr ofs
		lsl.l	#1,d1
		
		lea.l	skyline_bgshift,a0
		add.l	d0,a0
		add.l	d1,a0
		move.l	screen_adr2,a1
		lea.l	160(a1),a1
		ifne	hatari
		add.l	#230*210+6,a1
		endc
		ifeq	hatari
		add.l	#224*210+6,a1
		endc
		move.w	#32-1,d7
.bg:
q:		set	0
		rept	26
		move.w	(a0)+,q(a1)
q:		set	q+8
		endr
		lea.l	416/8(a0),a0

		ifne	hatari
		lea.l	230(a1),a1
		endc
		ifeq	hatari
		lea.l	224(a1),a1
		endc

		dbra	d7,.bg

		cmp.l	#414,.bgpos
		blt.s	.addit
		move.l	#-2,.bgpos
.addit:		addq.l	#2,.bgpos
		rts
.nibbleofs:	dcb.l	2,832*32/8*0
		dcb.l	2,832*32/8*1
		dcb.l	2,832*32/8*2
		dcb.l	2,832*32/8*3
		dcb.l	2,832*32/8*4
		dcb.l	2,832*32/8*5
		dcb.l	2,832*32/8*6
		dcb.l	2,832*32/8*7
.bgpos:		dc.l	0

;-------------- MAIN
skyline_main:
		rts


;-------------- TIMER A
skyline_timer_a:
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-35,$4e71

		moveq.l	#2,d7				;1
		move.l	screen_adr2,a6			;5
		lea.l	160(a6),a6			;2
		add.w	skyline_bpl,a6			;5
		lea.l	skyline_data,a5			;3
		add.l	skyline_frame,a5		;6
		lea.l	skyline_subtab,a4		;3
		lea.l	$ffff8240.w,a3			;2
		lea.l	skyline_rasters,a2		;3
		add.w	skyline_rastofs,a2		;5



		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a0			;2
		moveq.l	#127,d1				;1 = 9 nops wait for top border zap
		move.b	#2,$ffff820a.w


.sync:		tst.b	(a0)				;hardsync
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;


		dcb.w 	66-5,$4e71	

		
		jsr	generic_code			;5

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts

skyline_code1_start:
		;dcb.w	6-3,$4e71
		move.w	(a2)+,(a3)		;3
		move.w	(a5)+,(a6)		;3
		move.b	d7,$ffff8260.w		;3
		move.w	d7,$ffff8260.w		;3
		;dcb.w	90-88,$4e71
		move.w	(a5)+,8*1(a6)		;4
		move.w	(a5)+,8*2(a6)		;4
		move.w	(a5)+,8*3(a6)		;4
		move.w	(a5)+,8*4(a6)		;4
		move.w	(a5)+,8*5(a6)		;4
		move.w	(a5)+,8*6(a6)		;4
		move.w	(a5)+,8*7(a6)		;4
		move.w	(a5)+,8*8(a6)		;4
		move.w	(a5)+,8*9(a6)		;4
		move.w	(a5)+,8*10(a6)		;4
		move.w	(a5)+,8*11(a6)		;4
		move.w	(a5)+,8*12(a6)		;4
		move.w	(a5)+,8*13(a6)		;4
		move.w	(a5)+,8*14(a6)		;4
		move.w	(a5)+,8*15(a6)		;4
		move.w	(a5)+,8*16(a6)		;4
		move.w	(a5)+,8*17(a6)		;4
		move.w	(a5)+,8*18(a6)		;4
		move.w	(a5)+,8*19(a6)		;4
		move.w	(a5)+,8*20(a6)		;4
		move.w	(a5)+,8*21(a6)		;4
		move.w	(a5)+,8*22(a6)		;4 88
		ifne	hatari
		lea.l	230(a6),a6		;2
		endc
		ifeq	hatari
		lea.l	224(a6),a6		;2
		endc
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff820a.w		;3
		dcb.w	20-15,$4e71
		ifne	hatari
		move.w	(a5)+,8*23-230(a6)	;4
		move.w	(a5)+,8*24-230(a6)	;4
		move.w	(a5)+,8*25-230(a6)	;4
		endc
		ifeq	hatari
		move.w	(a5)+,8*23-224(a6)	;4
		move.w	(a5)+,8*24-224(a6)	;4
		move.w	(a5)+,8*25-224(a6)	;4
		endc
		sub.w	(a4)+,a5		;3

skyline_code1_end:
		
skyline_code2_start: ;(lower border)
		move.w	(a5)+,(a6)		;3
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff8260.w		;3
		move.w	d7,$ffff8260.w		;3
		move.b	d7,$ffff820a.w		;3
		;dcb.w	87-84,$4e71
		move.w	(a5)+,8*1(a6)		;4
		move.w	(a5)+,8*2(a6)		;4
		move.w	(a5)+,8*3(a6)		;4
		move.w	(a5)+,8*4(a6)		;4
		move.w	(a5)+,8*5(a6)		;4
		move.w	(a5)+,8*6(a6)		;4
		move.w	(a5)+,8*7(a6)		;4
		move.w	(a5)+,8*8(a6)		;4
		move.w	(a5)+,8*9(a6)		;4
		move.w	(a5)+,8*10(a6)		;4
		move.w	(a5)+,8*11(a6)		;4
		move.w	(a5)+,8*12(a6)		;4
		move.w	(a5)+,8*13(a6)		;4
		move.w	(a5)+,8*14(a6)		;4
		move.w	(a5)+,8*15(a6)		;4
		move.w	(a5)+,8*16(a6)		;4
		move.w	(a5)+,8*17(a6)		;4
		move.w	(a5)+,8*18(a6)		;4
		move.w	(a5)+,8*19(a6)		;4
		move.w	(a5)+,8*20(a6)		;4
		move.w	(a5)+,8*21(a6)		;4 21*4 = 84
		move.w	(a2)+,(a3)		;3 total 87 nops
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff820a.w		;3
		dcb.w	20-19,$4e71
		move.w	(a5)+,8*22(a6)		;4
		move.w	(a5)+,8*23(a6)		;4
		move.w	(a5)+,8*24(a6)		;4
		move.w	(a5)+,8*25(a6)		;4
		sub.w	(a4)+,a5		;3

		;cleanup line after lower border
		dcb.w	6-5,$4e71
		ifne	hatari
		lea.l	230(a6),a6		;2
		endc
		ifeq	hatari
		lea.l	224(a6),a6		;2
		endc
		move.w	(a5)+,(a6)		;3
		move.b	d7,$ffff8260.w		;3
		move.w	d7,$ffff8260.w		;3
		dcb.w	90-88,$4e71
		move.w	(a5)+,8*1(a6)		;4
		move.w	(a5)+,8*2(a6)		;4
		move.w	(a5)+,8*3(a6)		;4
		move.w	(a5)+,8*4(a6)		;4
		move.w	(a5)+,8*5(a6)		;4
		move.w	(a5)+,8*6(a6)		;4
		move.w	(a5)+,8*7(a6)		;4
		move.w	(a5)+,8*8(a6)		;4
		move.w	(a5)+,8*9(a6)		;4
		move.w	(a5)+,8*10(a6)		;4
		move.w	(a5)+,8*11(a6)		;4
		move.w	(a5)+,8*12(a6)		;4
		move.w	(a5)+,8*13(a6)		;4
		move.w	(a5)+,8*14(a6)		;4
		move.w	(a5)+,8*15(a6)		;4
		move.w	(a5)+,8*16(a6)		;4
		move.w	(a5)+,8*17(a6)		;4
		move.w	(a5)+,8*18(a6)		;4
		move.w	(a5)+,8*19(a6)		;4
		move.w	(a5)+,8*20(a6)		;4
		move.w	(a5)+,8*21(a6)		;4
		move.w	(a5)+,8*22(a6)		;4
		move.w	d7,$ffff820a.w		;3
		move.b	d7,$ffff820a.w		;3
		dcb.w	20-17,$4e71
		move.w	(a5)+,8*23(a6)		;4
		move.w	(a5)+,8*24(a6)		;4
		move.w	(a5)+,8*25(a6)		;4
		sub.w	(a4)+,a5		;3
		ifne	hatari
		lea.l	230(a6),a6		;2
		endc
		ifeq	hatari
		lea.l	224(a6),a6		;2
		endc
skyline_code2_end:




		section	data



skyline_rastofs:	dc.w	58*10*2

skyline_rasters:

; 0  8  1  9  2  a  3  b  4  c  5  d  6  e  7  f
; 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15

a:		set	$019B
b:		set	$012B
c:		set	$09AB
d:		set	$0234
e:		set	$02B4
f:		set	$0A44
g:		set	$0AC4
h:		set	$03C4
i:		set	$0354
j:		set	$0BD4
k:		set	$0B64
l:		set	$04EC
m:		set	$04EC
n:		set	$047C
o:		set	$0CFC

a1:		set	$0474
b1:		set	$04E4
c1:		set	$0B6B
d1:		set	$0BDB
e1:		set	$0353
f1:		set	$0ACA
g1:		set	$0A4A
h1:		set	$02B2
i1:		set	$0232
j1:		set	$09A9
k1:		set	$0121
l1:		set	$0191
m1:		set	$0818
n1:		set	$0888
o1:		set	$0000


		dcb.w	10,a 
		dc.w	b,a,b,a,b,a,b,a,b,a
		dcb.w	10,b 
		dc.w	c,b,c,b,c,b,c,b,c,b
		dcb.w	10,c
		dc.w	d,c,d,c,d,c,d,c,d,c
		dcb.w	10,d
		dc.w	e,d,e,d,e,d,e,d,e,d
		dcb.w	10,e
		dc.w	f,e,f,e,f,e,f,e,f,e
		dcb.w	10,f
		dc.w	g,f,g,f,g,f,g,f,g,f
		dcb.w	10,g
		dc.w	h,g,h,g,h,g,h,g,h,g
		dcb.w	10,h
		dc.w	i,h,i,h,i,h,i,h,i,h
		dcb.w	10,i
		dc.w	j,i,j,i,j,i,j,i,j,i
		dcb.w	10,j
		dc.w	k,j,k,j,k,j,k,j,k,j
		dcb.w	10,k
		dc.w	l,k,l,k,l,k,l,k,l,k
		dcb.w	10,l
		dc.w	m,l,m,l,m,l,m,l,m,l
		dcb.w	10,m
		dc.w	n,m,n,m,n,m,n,m,n,m
		dcb.w	10,n
		dc.w	o,n,o,n,o,n,o,n,o,n
		dcb.w	10,o

		dc.w	a1,o,a1,o,a1,o,a1,o,a1,o
		dcb.w	10,a1
		dc.w	b1,a1,b1,a1,b1,a1,b1,a1,b1,a1
		dcb.w	10,b1
		dc.w	c1,b1,c1,b1,c1,b1,c1,b1,c1,b1
		dcb.w	10,c1
		dc.w	d1,c1,d1,c1,d1,c1,d1,c1,d1,c1
		dcb.w	10,d1
		dc.w	e1,d1,e1,d1,e1,d1,e1,d1,e1,d1
		dcb.w	10,e1
		dc.w	f1,e1,f1,e1,f1,e1,f1,e1,f1,e1
		dcb.w	10,f1
		dc.w	g1,f1,g1,f1,g1,f1,g1,f1,g1,f1
		dcb.w	10,g1
		dc.w	h1,g1,h1,g1,h1,g1,h1,g1,h1,g1
		dcb.w	10,h1
		dc.w	i1,h1,i1,h1,i1,h1,i1,h1,i1,h1
		dcb.w	10,i1
		dc.w	j1,i1,j1,i1,j1,i1,j1,i1,j1,i1
		dcb.w	10,j1
		dc.w	k1,j1,k1,j1,k1,j1,k1,j1,k1,j1
		dcb.w	10,k1
		dc.w	l1,k1,l1,k1,l1,k1,l1,k1,l1,k1
		dcb.w	10,l1
		dc.w	m1,l1,m1,l1,m1,l1,m1,l1,m1,l1
		dcb.w	10,m1
		dc.w	n1,m1,n1,m1,n1,m1,n1,m1,n1,m1
		dcb.w	10,n1
		dc.w	o1,n1,o1,n1,o1,n1,o1,n1,o1,n1
		dcb.w	10,o1

		dcb.w	273,$000


skyline_fadepos:	dc.w	0
skyline_frame:		dc.l	0
skyline_subtab:		dcb.w	52,0
			dcb.w	231,52

skyline_ice:		incbin	'skyline/skyline.ice'
			even
skyline_bg:		incbin	'skyline/bgpic.1pl'
			even

skyline_bpl:		dc.w	0,0,2,2,4,4
		
x:			set	$0000
y:			set	$0102
z:			set	$0213
skyline_pal:		dc.w	$0000,z,z,y,z,y,y,x
			dc.w	$0000,z,z,y,z,y,y,x

skyline_pal_black:	dcb.w	16,$0000

		section	bss
		
skyline_fade:	ds.w	16*48

		section	text
