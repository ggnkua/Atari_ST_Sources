* Shadow of the Best Intro! GOR(tm) (c)1990

iea		equ		$fffa07 
ieb		equ 		$fffa09 
isra		equ		$fffa0f
isrb		equ		$fffa11
ima		equ		$fffa13  
imb		equ		$fffa15
tbcr		equ		$fffa1b
tbdr		equ		$fffa21 
tacr		equ		$fffa19 
tadr		equ		$fffa1f

		clr.l 	-(sp)
		move	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_ssp
*---------------
		lea	$2000,a7
*---------------
		moveq	#6,d7
fad
		bsr	vsync2
		bsr	vsync2
		sub	#$111,$ffff8240.w
		
		dbf	d7,fad
*---------------
		clr.l	$ffff8240.w
		clr.l	$ffff8250.w
*---------------
		move.l	$44e,old_scr		* for the OS only
		move.b	$ffff8260.w,old_shftmod	; save rez
		move.b	$ffff820a.w,old_frq
		movem.l	$ffff8240.w,d0-d7		; save palette
		movem.l	d0-d7,old_pal
		movem.l	$8,d0-d7		; save exceptions
		movem.l	d0-d7,old_vex		; vectors
		movem.l	new_vex,d0-d7		; point exceptions
		movem.l	d0-d7,$8		; to 'die'
*---------------
		bsr	vsync2
		clr.b	$ffff8260.w
*---------------
		move	#$777,old_pal
*---------------
		lea	$80000,a0		; test for 1 meg
		move.l	(a0),d0
		move.l	#"FUCK",(a0)
		cmp.l	#"FUCK",(a0)
		bne.s	half
		move.l	#$f8000,screen		; set 1 meg
		move.l	#$f0000,screen1		; screen addrs
		move.l	#$f8000,up_scr
		move.l	d0,(a0)
half
		sub.l	#32*160,up_scr
*--------------- check for STE!
		cmp.l	#$e00000,4
		bge.s	not_ste
						; yes, its an STE uuurrggh!
		move	#1,ste_flag		; so set flag!!
not_ste
*--------------- check for cartridges
		cmp.l	#$fa52235f,$fa0000	; diagnostix cart (multiface)
		beq.s	a_cart
		cmp.l	#$abcdef42,$fa0000	; user cart
		beq.s	a_cart
		bra.s	no_cart
a_cart						; cart connected
		move	#1,cart_flag		; so set flag!
no_cart
*--------------- build char tabs

		move.l	#chars,d0
		moveq.l	#0,d1
		lea	chrtab,a0
		
		move	#3,d6
daan
		move.l	d0,d1
		move	#39,d7
widf		move.l	d1,(a0)+
		addq.l	#1,d1
		dbf	d7,widf
		
		add.l	#8*40,d0
		dbf	d6,daan

*---------------
		move.l	up_scr,a0
		bsr	scr_clr
		bsr	scr_clr

		lea	well_cum,a6
		clr	xpos
		move	#80,ypos
		bsr	fader
		
		move.l	up_scr,a0
		bsr	scr_clr
		bsr	scr_clr

		lea	credz,a6
		clr	xpos
		move	#80,ypos
		bsr	fader
*---------------

* shift mounty
		lea	mspc,a1
		move	#15,d6		; shift 1st mountain
all1
		lea	pic+128,a0
		lea	72*160(a0),a0
		move	#74,d7
		bsr	cop2
		
		lea	pic+128,a0
		lea	72*160(a0),a0
		move	#74,d7
		bsr	shift		
		dbf	d6,all1

* shift grounf
		lea	gspc,a1
		move	#15,d6		; shift 1st mountain
all2
		lea	pic+128,a0
		lea	147*160(a0),a0
		move	#29,d7
		bsr	cop2
		
		lea	pic+128,a0
		lea	147*160(a0),a0
		move	#29,d7
		bsr	shift
		
		dbf	d6,all2
*---------------
		moveq	#6,d0			; music init, innit?
		jsr	mux
*---------------
		bsr	int_on			; turn on interupts
*---------------
		moveq	#$12,d1			; mouse off
		bsr	ikbdsend		
*---------------
		move.l	up_scr,d7
		bsr	set_scr
		move.b	#0,$ffff8260.w
*---------------
		move.l	up_scr,a0
		bsr	scr_clr

*--------------- make errors!!
		*divu	#0,d0
		*move.l	#$deadface,4
		*move.l	#$deadface,5
*---------------
		lea	pic+128,a0
		move.l	up_scr,a1
		move	#7999,d7
coop		move.l	(a0)+,(a1)+
		dbf	d7,coop
		
		move.l	up_scr,a1
		move	#(147*20)-1,d7
here2		move	#-1,4(a1)
		addq.l	#8,a1
		dbf	d7,here2
*---------------
		lea	fnt+128+(150*160),a0
		move.l	up_scr,a1
		lea	180*160(a1),a1
		move	#((50*40))/2-1,d7
here3		move.l	(a0)+,(a1)+
		move	(a0)+,(a1)+
		clr	(a1)+
		addq.l	#2,a0
		dbf	d7,here3
		
		lea	pic+128+(180*160),a0
		move.l	up_scr,a1
		lea	161*160(a1),a1
		move	#(16*20)-1,d7
here4		move	2(a0),4(a1)
		addq.l	#8,a0
		addq.l	#8,a1
		dbf	d7,here4

*---------------
		clr	xpos
*--------------- main loop
wait_loop	
*---------------
		bsr	vsync
*---------------
		bsr	do_para

*---------------
		tst	scflag
		bne	dtbs
*--------------- lil scroller #1

		lea	lbuf,a5
		move.l	up_scr,a6
		lea	100*160(a6),a6
		addq.l	#6,a6
		rept	8
		move	(a5),(a6)
		move	8(a5),8(a6)
		move	16(a5),16(a6)
		move	24(a5),24(a6)
		move	32(a5),32(a6)
		move	40(a5),40(a6)
		move	48(a5),48(a6)
		move	56(a5),56(a6)
		move	64(a5),64(a6)
		move	72(a5),72(a6)
		move	80(a5),80(a6)
		move	88(a5),88(a6)
		move	96(a5),96(a6)
		move	104(a5),104(a6)
		move	112(a5),112(a6)
		move	120(a5),120(a6)
		move	128(a5),128(a6)
		move	136(a5),136(a6)
		move	144(a5),144(a6)
		move	152(a5),152(a6)
		lea	168(a5),a5
		lea	160(a6),a6
		endr


		addq	#1,lchrcnt
		cmp	#8,lchrcnt
		blt	.drlcn
		clr	lchrcnt
		
		lea	lbuf+160,a6
		
		move.l	lpnt,a5
		moveq.l	#0,d7
		move.b	(a5)+,d7
		tst.b	d7
		bpl.s	.drm
		move.l	#text,mespnt	; reset big scroll
		lea	ltext,a5
		move.b	(a5)+,d7
.drm
		move.l	a5,lpnt
*
		cmp.b	#"#",d7
		bne.s	.nscc
		move	#1,scflag
		bra	past_scrl
.nscc
*
		
		sub.b	#" ",d7		
		
		lea	chrtab,a5
		lsl	#2,d7		; *8 top get offset
		move.l	(a5,d7.w),a5	; address of data in a1

		move.b	(a5),(a6)
		move.b	40(a5),168(a6)
		move.b	80(a5),168*2(a6)
		move.b	120(a5),168*3(a6)
		move.b	160(a5),168*4(a6)
		move.b	200(a5),168*5(a6)
		move.b	240(a5),168*6(a6)
		move.b	280(a5),168*7(a6)
	
.drlcn

		
		lea	lbuf,a5
		rept	8
		roxl	160(a5)
		roxl	152(a5)
		roxl	144(a5)
		roxl	136(a5)
		roxl	128(a5)
		roxl	120(a5)
		roxl	112(a5)
		roxl	104(a5)
		roxl	96(a5)
		roxl	88(a5)
		roxl	80(a5)
		roxl	72(a5)
		roxl	64(a5)
		roxl	56(a5)
		roxl	48(a5)
		roxl	40(a5)
		roxl	32(a5)
		roxl	24(a5)
		roxl	16(a5)
		roxl	8(a5)
		roxl	(a5)
		lea	168(a5),a5
		endr
		
		bra	past_scrl
dtbs						; big scroll goes in here!
* scrolly
*---------------- when does char go on

		addq	#2,chrcnt
		cmp	#32,chrcnt
		blt	dbocy
		
		clr	chrcnt	
		move.l	mespnt,a0
		clr.l	d0
		move.b	(a0)+,d0
		tst.b	d0
		bpl.s	nrmey
		lea	text,a0
		move.b	(a0)+,d0
nrmey
		move.l	a0,mespnt	
*
		cmp.b	#"#",d0
		bne.s	.nscce
		move	#0,scflag
		bra	past_scrl
.nscce
*
		sub.b	#" ",d0
		
		lea	chrtab1,a0
		lsl	#2,d0
		move.l	(a0,d0.w),a2
		*lea	fnt+128,a2

goeey		move.l	a2,a3
		
		lea	chrbuf,a1
		lea	buf0,a0
		rept	24
		move	(a2),2(a1)
		move	8(a2),4(a1)
		addq.l	#6,a1
		lea	160(a2),a2
		endr
dbocy

		addq	#1,bcnt
		and	#7,bcnt
		
		lea	bufs,a0
		moveq.l	#0,d0
		move	bcnt,d0
		lsl	#2,d0
		move.l	(a0,d0.w),a0
		
		move.l	up_scr,a1
		lea	130*160+6(a1),a1
		rept	24
		movem	(a0),d0-d7
		movem	d1-d7,(a0)
		move	d0,(a1)
		move	d1,8(a1)
		move	d2,16(a1)
		move	d3,24(a1)
		move	d4,32(a1)
		move	d5,40(a1)
		move	d6,48(a1)
		move	d7,56(a1)
		
		movem	16(a0),d0-d7
		movem	d0-d7,16-2(a0)
		
		move	d0,64(a1)
		move	d1,72(a1)
		move	d2,80(a1)
		move	d3,88(a1)
		move	d4,96(a1)
		move	d5,104(a1)
		move	d6,112(a1)
		move	d7,120(a1)
		
		movem	32(a0),d0-d5
		movem	d0-d5,32-2(a0)
		move	d0,128(a1)
		move	d1,136(a1)
		move	d2,144(a1)
		move	d3,152(a1)
		
		lea	44(a0),a0
		lea	160(a1),a1
		endr
		
*---------------

		lea	bufs,a0
		moveq.l	#0,d0
		move	bcnt,d0
		lsl	#2,d0
		move.l	(a0,d0.w),a0
		lea	chrbuf,a2
		rept	24
		move	(a2),40(a0)
		move	8(a2),40+2(a0)
		addq.l	#6,a2
		lea	44(a0),a0
		endr
		
		lea	chrbuf,a0
		rept	24
		roxl	4(a0)
		roxl	2(a0)
		roxl	(a0)
		addq.l	#6,a0
		endr
		
		lea	chrbuf,a0
		rept	24
		roxl	4(a0)
		roxl	2(a0)
		roxl	(a0)
		addq.l	#6,a0
		endr

past_scrl
*--------------- top scrolly texty fingy
		
		tst	stflag
		bne.s	dboc

		move.l	txtpnt,a0
		moveq	#0,d0
		move.b	(a0)+,d0
		cmp.b	#-1,d0
		bne.s	.drtp
		lea	txt,a0
		move.b	(a0)+,d0
		clr	xpos
.drtp
		move.l	a0,txtpnt
		
		cmp.b	#13,d0
		bne.s	.dcst
		clr	xpos
		move	#1,stflag
		bra	pastst
.dcst
		
		move.b	d0,print_me
		
		move	#64,ypos		; prin tit(!)
		lea	print_me,a6
		bsr	text_pr
		
		bra	pastst
dboc
		addq	#1,scnt
		cmp	#8,scnt
		ble.s	.drsc
		clr	stflag
		clr	scnt
		bra	pastst
.drsc
		move.l	up_scr,a0
		addq.l	#6,a0
		move	#71,d7
scl		
		move	160(a0),(a0)
		move	160+8(a0),+8(a0)
		move	160+16(a0),+16(a0)
		move	160+24(a0),+24(a0)
		move	160+32(a0),+32(a0)
		move	160+40(a0),+40(a0)
		move	160+48(a0),+48(a0)
		move	160+56(a0),+56(a0)
		move	160+64(a0),+64(a0)
		move	160+72(a0),+72(a0)
		move	160+80(a0),+80(a0)
		move	160+88(a0),+88(a0)
		move	160+96(a0),+96(a0)
		move	160+104(a0),+104(a0)
		move	160+112(a0),+112(a0)
		move	160+120(a0),+120(a0)
		move	160+128(a0),+128(a0)
		move	160+136(a0),+136(a0)
		move	160+144(a0),+144(a0)
		move	160+152(a0),+152(a0)
		
		lea	160(a0),a0
		dbf	d7,scl
pastst

*--------------- lil scroller #2

		lea	lbuf2,a5
		move.l	up_scr,a6
		add.l	#180*160,a6
		addq.l	#6,a6
		rept	8
		move	(a5),(a6)
		move	8(a5),8(a6)
		move	16(a5),16(a6)
		move	24(a5),24(a6)
		move	32(a5),32(a6)
		move	40(a5),40(a6)
		move	48(a5),48(a6)
		move	56(a5),56(a6)
		move	64(a5),64(a6)
		move	72(a5),72(a6)
		move	80(a5),80(a6)
		move	88(a5),88(a6)
		move	96(a5),96(a6)
		move	104(a5),104(a6)
		move	112(a5),112(a6)
		move	120(a5),120(a6)
		move	128(a5),128(a6)
		move	136(a5),136(a6)
		move	144(a5),144(a6)
		move	152(a5),152(a6)
		lea	168(a5),a5
		lea	160(a6),a6
		endr


		addq	#2,lchrcnt2
		cmp	#8,lchrcnt2
		blt.s	.drlcn2
		clr	lchrcnt2
		
		lea	lbuf2+160,a6
		
		move.l	lpnt2,a5
		moveq.l	#0,d7
		move.b	(a5)+,d7
		tst.b	d7
		bpl.s	.drm2
		lea	ltext2,a5
		move.b	(a5)+,d7
.drm2
		move.l	a5,lpnt2
*
		
		sub.b	#" ",d7		
		
		lea	chrtab,a5
		lsl	#2,d7		; *8 top get offset
		move.l	(a5,d7.w),a5	; address of data in a1

		move.b	(a5),(a6)
		move.b	40(a5),168(a6)
		move.b	80(a5),168*2(a6)
		move.b	120(a5),168*3(a6)
		move.b	160(a5),168*4(a6)
		move.b	200(a5),168*5(a6)
		move.b	240(a5),168*6(a6)
		move.b	280(a5),168*7(a6)
	
.drlcn2

		
		lea	lbuf2,a5
		rept	8
		roxl	160(a5)
		roxl	152(a5)
		roxl	144(a5)
		roxl	136(a5)
		roxl	128(a5)
		roxl	120(a5)
		roxl	112(a5)
		roxl	104(a5)
		roxl	96(a5)
		roxl	88(a5)
		roxl	80(a5)
		roxl	72(a5)
		roxl	64(a5)
		roxl	56(a5)
		roxl	48(a5)
		roxl	40(a5)
		roxl	32(a5)
		roxl	24(a5)
		roxl	16(a5)
		roxl	8(a5)
		roxl	(a5)
		lea	168(a5),a5
		endr
		
		lea	lbuf2,a5
		rept	8
		roxl	160(a5)
		roxl	152(a5)
		roxl	144(a5)
		roxl	136(a5)
		roxl	128(a5)
		roxl	120(a5)
		roxl	112(a5)
		roxl	104(a5)
		roxl	96(a5)
		roxl	88(a5)
		roxl	80(a5)
		roxl	72(a5)
		roxl	64(a5)
		roxl	56(a5)
		roxl	48(a5)
		roxl	40(a5)
		roxl	32(a5)
		roxl	24(a5)
		roxl	16(a5)
		roxl	8(a5)
		roxl	(a5)
		lea	168(a5),a5
		endr

*---------------
		*move	#$770,$ffff8240.w
*---------------
		cmp.b	#" ",keybuf
		bne	wait_loop
		
*--------------- exit
finish
		move.l	old_scr,d7
		bsr	set_scr
		move.b	old_shftmod,$ffff8260.w
*---------------
		moveq	#8,d1			; mouse back on
		bsr	ikbdsend		
*---------------
		bsr	int_off			; irq's back off
*---------------
		lea	$ffff8800.w,a0
		move.l	#$08080000,(a0)
		move.l	#$09090000,(a0)
		move.l	#$0a0a0000,(a0)
*---------------
		move	#-1,$4ee		* for the OS only
		movem.l	old_vex,d0-d7
		movem.l	d0-d7,$8
		movem.l	old_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		move.b	old_frq,$ffff820a.w
*---------------
		move.l	old_ssp,-(sp)
		move	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
*---------------
bp
		clr	-(sp)			* for the OS only
		trap	#1
*---------------
fader
		bsr	text_pr
		
		moveq	#6,d7
fad2
		bsr	vsync2
		bsr	vsync2
		add	#$111,$ffff8250.w
		
		dbf	d7,fad2
		
		moveq	#49,d7
pauls
		bsr	vsync2
		dbf	d7,pauls
		
		moveq	#6,d7
fad3
		bsr	vsync2
		bsr	vsync2
		sub	#$111,$ffff8250.w
		
		dbf	d7,fad3
		
		moveq	#9,d7
pauls2
		bsr	vsync2
		dbf	d7,pauls2
		
		rts		
do_para

*-------------------- disp mountainous region!

		addq	#1,wsh1
		cmp	#15,wsh1
		ble.s	drws1
		clr	wsh1
		
		addq	#1,wsb1
		cmp	#19,wsb1
		ble.s	drws1
		clr	wsb1
drws1
		*clr	wsb1
		
		clr.l	d0
		move	wsb1,d0		; which boundry & rout
		move.l	d0,d7
		lsl	#2,d0
		lea	crouts,a0
		move.l	(a0,d0.w),a6	; 16 pix bound copy rout addr in a6
		
		lea	mspc,a0
		clr.l	d0
		move	wsh1,d0		; shift amount
		mulu	#75*80,d0
		add.l	d0,a0		; shift addr in a0
		
		move.l	up_scr,a1	; screen in a1
		lsl	#3,d7
		add	d7,a1
		lea	72*160(a1),a1
		move	#74,d6
		jsr	(a6)		; jump to copy rout

*-------------------- disp floorainous region!

		addq	#1,wsh2
		cmp	#15,wsh2
		ble.s	drws2
		clr	wsh2
		
		addq	#1,wsb2
		cmp	#19,wsb2
		ble.s	drws2
		clr	wsb2
drws2
		*clr	wsb2
		
		clr.l	d0
		move	wsb2,d0		; which boundry & rout
		move.l	d0,d7
		lsl	#2,d0
		lea	crouts,a0
		move.l	(a0,d0.w),a6	; 16 pix bound copy rout addr in a6
		
		lea	gspc,a0
		clr.l	d0
		move	wsh2,d0		; shift amount
		mulu	#30*80,d0
		add.l	d0,a0		; shift addr in a0
		
		move.l	up_scr,a1	; screen in a1
		lsl	#3,d7
		add	d7,a1
		lea	147*160(a1),a1
		move	#4,d6
		jsr	(a6)		; jump to copy rout
				
*
		addq	#2,wsh3
		cmp	#15,wsh3
		ble.s	drws3
		clr	wsh3
		
		addq	#1,wsb3
		cmp	#19,wsb3
		ble.s	drws3
		clr	wsb3
drws3
		*clr	wsb3
		
		clr.l	d0
		move	wsb3,d0		; which boundry & rout
		move.l	d0,d7
		lsl	#2,d0
		lea	crouts,a0
		move.l	(a0,d0.w),a6	; 16 pix bound copy rout addr in a6
		
		lea	gspc,a0
		clr.l	d0
		move	wsh3,d0		; shift amount
		mulu	#30*80,d0
		add.l	d0,a0		; shift addr in a0
		add.l	#5*80,a0
		
		move.l	up_scr,a1	; screen in a1
		lsl	#3,d7
		add	d7,a1
		lea	(147+5)*160(a1),a1
		move	#4,d6
		jsr	(a6)		; jump to copy rout
*
		addq	#3,wsh4
		cmp	#15,wsh4
		ble.s	drws4
		*clr	wsh4
		sub	#15,wsh4
		
		addq	#1,wsb4
		cmp	#19,wsb4
		ble.s	drws4
		clr	wsb4
drws4
		*clr	wsb4
		
		clr.l	d0
		move	wsb4,d0		; which boundry & rout
		move.l	d0,d7
		lsl	#2,d0
		lea	crouts,a0
		move.l	(a0,d0.w),a6	; 16 pix bound copy rout addr in a6
		
		lea	gspc,a0
		clr.l	d0
		move	wsh4,d0		; shift amount
		mulu	#30*80,d0
		add.l	d0,a0		; shift addr in a0
		add.l	#10*80,a0
		
		move.l	up_scr,a1	; screen in a1
		lsl	#3,d7
		add	d7,a1
		lea	(147+10)*160(a1),a1
		move	#4,d6
		jsr	(a6)		; jump to copy rout
*
		addq	#4,wsh5
		cmp	#15,wsh5
		ble.s	drws5
		*clr	wsh5
		sub	#15,wsh5
		
		addq	#1,wsb5
		cmp	#19,wsb5
		ble.s	drws5
		clr	wsb5
drws5
		*clr	wsb5
		
		clr.l	d0
		move	wsb5,d0		; which boundry & rout
		move.l	d0,d7
		lsl	#2,d0
		lea	crouts,a0
		move.l	(a0,d0.w),a6	; 16 pix bound copy rout addr in a6
		
		lea	gspc,a0
		clr.l	d0
		move	wsh5,d0		; shift amount
		mulu	#30*80,d0
		add.l	d0,a0		; shift addr in a0
		add.l	#15*80,a0
		
		move.l	up_scr,a1	; screen in a1
		lsl	#3,d7
		add	d7,a1
		lea	(147+15)*160(a1),a1
		move	#4,d6
		jsr	(a6)		; jump to copy rout
*
		addq	#5,wsh6
		cmp	#15,wsh6
		ble.s	drws6
		*clr	wsh6
		sub	#15,wsh6
		
		addq	#1,wsb6
		cmp	#19,wsb6
		ble.s	drws6
		clr	wsb6
drws6
		*clr	wsb6
		
		clr.l	d0
		move	wsb6,d0		; which boundry & rout
		move.l	d0,d7
		lsl	#2,d0
		lea	crouts,a0
		move.l	(a0,d0.w),a6	; 16 pix bound copy rout addr in a6
		
		lea	gspc,a0
		clr.l	d0
		move	wsh6,d0		; shift amount
		mulu	#30*80,d0
		add.l	d0,a0		; shift addr in a0
		add.l	#20*80,a0
		
		move.l	up_scr,a1	; screen in a1
		lsl	#3,d7
		add	d7,a1
		lea	(147+20)*160(a1),a1
		move	#4,d6
		jsr	(a6)		; jump to copy rout
				
*
		addq	#6,wsh7
		cmp	#15,wsh7
		ble.s	drws7
		*clr	wsh7
		sub	#15,wsh7
		
		addq	#1,wsb7
		cmp	#19,wsb7
		ble.s	drws7
		clr	wsb7
drws7
		*clr	wsb7
		
		clr.l	d0
		move	wsb7,d0		; which boundry & rout
		move.l	d0,d7
		lsl	#2,d0
		lea	crouts,a0
		move.l	(a0,d0.w),a6	; 16 pix bound copy rout addr in a6
		
		lea	gspc,a0
		clr.l	d0
		move	wsh7,d0		; shift amount
		mulu	#30*80,d0
		add.l	d0,a0		; shift addr in a0
		add.l	#25*80,a0
		
		move.l	up_scr,a1	; screen in a1
		lsl	#3,d7
		add	d7,a1
		lea	(147+25)*160(a1),a1
		move	#4,d6
		jsr	(a6)		; jump to copy rout
				

		
		rts
*------------------- 20 copy routs (oh, god!)
crouts
		dc.l	mcop0
		dc.l	mcop1
		dc.l	mcop2
		dc.l	mcop3
		dc.l	mcop4
		dc.l	mcop5
		dc.l	mcop6
		dc.l	mcop7
		dc.l	mcop8
		dc.l	mcop9
		dc.l	mcop10
		dc.l	mcop11
		dc.l	mcop12
		dc.l	mcop13
		dc.l	mcop14
		dc.l	mcop15
		dc.l	mcop16
		dc.l	mcop17
		dc.l	mcop18
		dc.l	mcop19
		
		
		
*------------------- actual copy routs (oh, god! twice!)

mcop0
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,104(a1)
		move.l	(a0)+,112(a1)
		move.l	(a0)+,120(a1)
		move.l	(a0)+,128(a1)
		move.l	(a0)+,136(a1)
		move.l	(a0)+,144(a1)
		move.l	(a0)+,152(a1)
		lea	160(a1),a1
		dbf	d6,mcop0
		rts

mcop1
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,104(a1)
		move.l	(a0)+,112(a1)
		move.l	(a0)+,120(a1)
		move.l	(a0)+,128(a1)
		move.l	(a0)+,136(a1)
		move.l	(a0)+,144(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop1
		rts
		
mcop2
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,104(a1)
		move.l	(a0)+,112(a1)
		move.l	(a0)+,120(a1)
		move.l	(a0)+,128(a1)
		move.l	(a0)+,136(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop2
		rts
		
mcop3
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,104(a1)
		move.l	(a0)+,112(a1)
		move.l	(a0)+,120(a1)
		move.l	(a0)+,128(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop3
		rts
		
		
mcop4
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,104(a1)
		move.l	(a0)+,112(a1)
		move.l	(a0)+,120(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop4
		rts
		
mcop5
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,104(a1)
		move.l	(a0)+,112(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop5
		rts
		
mcop6
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,104(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop6
		rts
		
mcop7
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop7
		rts
			
mcop8
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop8
		rts
			
mcop9
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop9
		rts
				
mcop10
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop10
		rts
					
mcop11
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64(a1)
		move.l	(a0)+,72-160(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop11
		rts
					
mcop12
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56(a1)
		move.l	(a0)+,64-160(a1)
		move.l	(a0)+,72-160(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop12
		rts
						
mcop13
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48(a1)
		move.l	(a0)+,56-160(a1)
		move.l	(a0)+,64-160(a1)
		move.l	(a0)+,72-160(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop13
		rts
						
mcop14
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40(a1)
		move.l	(a0)+,48-160(a1)
		move.l	(a0)+,56-160(a1)
		move.l	(a0)+,64-160(a1)
		move.l	(a0)+,72-160(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop14
		rts
							
mcop15
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,40-160(a1)
		move.l	(a0)+,48-160(a1)
		move.l	(a0)+,56-160(a1)
		move.l	(a0)+,64-160(a1)
		move.l	(a0)+,72-160(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop15
		rts
								
mcop16
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,32-160(a1)
		move.l	(a0)+,40-160(a1)
		move.l	(a0)+,48-160(a1)
		move.l	(a0)+,56-160(a1)
		move.l	(a0)+,64-160(a1)
		move.l	(a0)+,72-160(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop16
		rts
					
mcop17
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,24-160(a1)
		move.l	(a0)+,32-160(a1)
		move.l	(a0)+,40-160(a1)
		move.l	(a0)+,48-160(a1)
		move.l	(a0)+,56-160(a1)
		move.l	(a0)+,64-160(a1)
		move.l	(a0)+,72-160(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop17
		rts
						
mcop18
		move.l	(a0)+,(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,16-160(a1)
		move.l	(a0)+,24-160(a1)
		move.l	(a0)+,32-160(a1)
		move.l	(a0)+,40-160(a1)
		move.l	(a0)+,48-160(a1)
		move.l	(a0)+,56-160(a1)
		move.l	(a0)+,64-160(a1)
		move.l	(a0)+,72-160(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop18
		rts
							
mcop19
		move.l	(a0)+,(a1)
		move.l	(a0)+,8-160(a1)
		move.l	(a0)+,16-160(a1)
		move.l	(a0)+,24-160(a1)
		move.l	(a0)+,32-160(a1)
		move.l	(a0)+,40-160(a1)
		move.l	(a0)+,48-160(a1)
		move.l	(a0)+,56-160(a1)
		move.l	(a0)+,64-160(a1)
		move.l	(a0)+,72-160(a1)
		move.l	(a0)+,80-160(a1)
		move.l	(a0)+,88-160(a1)
		move.l	(a0)+,96-160(a1)
		move.l	(a0)+,104-160(a1)
		move.l	(a0)+,112-160(a1)
		move.l	(a0)+,120-160(a1)
		move.l	(a0)+,128-160(a1)
		move.l	(a0)+,136-160(a1)
		move.l	(a0)+,144-160(a1)
		move.l	(a0)+,152-160(a1)
		lea	160(a1),a1
		dbf	d6,mcop19
		rts
*------------------- copy amount in d7 at a0, to a1
cop2
		move.l	(a0),(a1)+
		move.l	8(a0),(a1)+
		move.l	16(a0),(a1)+
		move.l	24(a0),(a1)+
		move.l	32(a0),(a1)+
		move.l	40(a0),(a1)+
		move.l	48(a0),(a1)+
		move.l	56(a0),(a1)+
		move.l	64(a0),(a1)+
		move.l	72(a0),(a1)+
		move.l	80(a0),(a1)+
		move.l	88(a0),(a1)+
		move.l	96(a0),(a1)+
		move.l	104(a0),(a1)+
		move.l	112(a0),(a1)+
		move.l	120(a0),(a1)+
		move.l	128(a0),(a1)+
		move.l	136(a0),(a1)+
		move.l	144(a0),(a1)+
		move.l	152(a0),(a1)+
		
		lea	160(a0),a0
		dbf	d7,cop2
		rts

*------------------- shift amount in d7 at a0
shift
* bp 1
		move	152(a0),d0
		roxr	d0
		
		roxr	(a0)
		roxr	8(a0)
		roxr	16(a0)
		roxr	24(a0)
		roxr	32(a0)
		roxr	40(a0)
		roxr	48(a0)
		roxr	56(a0)
		roxr	64(a0)
		roxr	72(a0)
		roxr	80(a0)
		roxr	88(a0)
		roxr	96(a0)
		roxr	104(a0)
		roxr	112(a0)
		roxr	120(a0)
		roxr	128(a0)
		roxr	136(a0)
		roxr	144(a0)
		roxr	152(a0)
		
* bp 2
		move	152+2(a0),d0
		roxr	d0
		
		roxr	+2(a0)
		roxr	8+2(a0)
		roxr	16+2(a0)
		roxr	24+2(a0)
		roxr	32+2(a0)
		roxr	40+2(a0)
		roxr	48+2(a0)
		roxr	56+2(a0)
		roxr	64+2(a0)
		roxr	72+2(a0)
		roxr	80+2(a0)
		roxr	88+2(a0)
		roxr	96+2(a0)
		roxr	104+2(a0)
		roxr	112+2(a0)
		roxr	120+2(a0)
		roxr	128+2(a0)
		roxr	136+2(a0)
		roxr	144+2(a0)
		roxr	152+2(a0)
		
		lea	160(a0),a0
		
		dbf	d7,shift
		rts

*--------------- print text line xpos,ypos  a6-text string (null term!) 
text_pr
.p_loop		move	xpos,d0
		move	ypos,d1
		moveq.l	#0,d2
		move.b	(a6)+,d2
		and.b	#127,d2
	
		cmp.b	#10,d2
		bne	.nvt	
		clr	xpos
		add	#9,ypos
		bra.s	.nxc
.nvt	
	
		sub.b	#" ",d2
	
		bsr	chr_print1
		addq	#8,xpos
.nxc
		tst.b	(a6)
		bne	.p_loop
		rts	
	
chr_print1
		lea	chrtab,a1
		and.l	#$fff8,d0	; Force x coord to multiple of 8
	
		mulu	#320,d1
		add.l	d0,d1		; Get pixel number
	
		lsr.l	#1,d1
		and.l	#$fff8,d1	; Get screen offset
	
		btst	#3,d0		; See if 0 or 8
		beq	.skip
		addq	#1,d1		; if 8 then use next byte
.skip		add.l	up_scr,d1	
		move.l	d1,a0		; address of screen in a0
	
		lsl	#2,d2		; *8 top get offset
		move.l	(a1,d2.w),a1	; address of data in a1

		move.b	(a1),+6(a0)
		move.b	40(a1),160+6(a0)
		move.b	80(a1),320+6(a0)
		move.b	120(a1),480+6(a0)
		move.b	160(a1),640+6(a0)
		move.b	200(a1),800+6(a0)
		move.b	240(a1),960+6(a0)
		move.b	280(a1),1120+6(a0)
	
		rts

*--------------- convert hex in d0.L to asc -(a3)
hexcon
		lea	nums,a5
		move	#7,d3
		move.l	d0,d7
.conv
		and.l	#$f,d0
		move.b	(a5,d0.w),d0
		move.b	d0,-(a3)
		lsr.l	#4,d7
		move.l	d7,d0
		dbf	d3,.conv
		rts
		
*---------------

		
*--------------- turn on irq's & key handler etc...
int_on
		move	#$2700,sr
		move.b	ieb,old_ieb
		move.b	iea,old_iea
		move.b	ima,old_ima
		clr.b	iea
		clr.b	ieb
		move.l	$118,old_key_vec
		move.l	$120,old_hbl_vec
		move.l	$70,old_vbl_vec
		move.l	$134,old_tima
		move.l	#key_handler,$118
		move.l	#hbl_handler,$120
		move.l	#vbl_handler,$70
		*move.l	#timer_a,$134
		bset	#0,iea			; timer B on
		bset	#0,ima
		*bset	#5,iea			; timer A on
		*bset	#5,ima
		bset	#6,ieb			; keyboard irq on
		bset	#6,imb
		move	#$2300,sr
		rts
			
*--------------- turn irq's back off
int_off
		move	#$2700,sr
		move.b	old_ieb,ieb
		move.b	old_iea,iea
		move.b	old_ima,ima
  		move.l	old_key_vec,$118
		move.l	old_hbl_vec,$120
		move.l	old_vbl_vec,$70
		move.l	old_tima,$134
		move	#$2300,sr
		rts
			 
*--------------- send byte to keyboard 

ikbdsend					; byte to send in d1
		lea	$fffffc00.w,a0
redwait		move.b	(a0),d2
		btst	#1,d2
		beq	redwait
		move.b	d1,2(a0)
		rts

*--------------- screen flip rout

sflip	
		eor	#1,swi
		bne	sflip1
		move.l	screen1,d7		
		move.l	screen,up_scr		
		bra	set_scr
sflip1		move.l	screen,d7
		move.l	screen1,up_scr
set_scr						; sreen start addr in d7.L
		lsr.l	#8,d7	
		move.b	d7,$ffff8203.w
		lsr.l	#8,d7
		move.b	d7,$ffff8201.w
		
*--------------- vsync rout (used by sflip!)
vsync
		move	frclock,d0
.vlop		cmp	frclock,d0
		beq.s	.vlop
		rts
vsync2
		move	$468,d0
.vlop		cmp	$468,d0
		beq.s	.vlop
		rts
		
*--------------- clear screen
scr_clr						; a0 points to screen to clear
		move	#7999,d0
		clr.l	d7
csl		move.l	d7,(a0)+
		dbf	d0,csl
		rts
		
*--------------- keyboard handler
key_handler	
		move	#$2500,sr
		movem.l	d0-d7/a0-a6,-(sp)
		clr.w	keybuf
		clr.w	scancode
		lea	$fffffc00.w,a1
		move.b	(a1),d2
		btst	#7,d2
		beq	.exit
		btst	#0,d2
		beq	.clear
		movem.l	d2/a0-a2,-(a7)
		bsr	.getbyte
		movem.l	(a7)+,d2/a0-a2
.clear		and.b	#$20,d2
		beq	.exit
		move.b	2(a1),d0
.exit
		movem.l	(sp)+,d0-d7/a0-a6
		bclr	#6,isrb
		btst	#4,$fffffa01.w
		beq.s	key_handler
		rte
		
.getbyte
					; shifty type key jobbys
		cmp.b	#$2a,2(a1)	; left shift pressed
		bne.s	.lsnp
		bset	#0,keystat
		rts
.lsnp
		cmp.b	#$aa,2(a1)	; left shift released
		bne.s	.lsip
		bclr	#0,keystat
		rts
.lsip
		cmp.b	#$36,2(a1)	; right shift pressed
		bne.s	.rsnp
		bset	#1,keystat
		rts
.rsnp
		cmp.b	#$b6,2(a1)	; right shift released
		bne.s	.rsip
		bclr	#1,keystat
		rts
.rsip
		cmp.b	#$1d,2(a1)	; ctrl shift pressed
		bne.s	.csnp
		bset	#2,keystat
		rts
.csnp
		cmp.b	#$9d,2(a1)	; ctrl shift released
		bne.s	.csip
		bclr	#2,keystat
		rts
.csip
		cmp.b	#$38,2(a1)	; alt shift pressed
		bne.s	.asnp
		bset	#3,keystat
		rts
.asnp
		cmp.b	#$b8,2(a1)	; alt shift released
		bne.s	.asip
		bclr	#3,keystat
		rts
.asip

		cmp.b	#$3a,2(a1)	; alt shift pressed
		bne.s	.clnp
		bchg	#4,keystat
		rts
.clnp
					; the rest of the key handler
		cmp.w	#1,joy0flg
		beq	.joy0b	
		cmp.w	#1,joy1flg
		beq	.joy1b
		
		cmp.w	#1,mouseflg
		beq	.mouse1b
		cmp.w	#2,mouseflg
		beq	.mouse2b
		
		
		move.b	2(a1),d0
		cmp.b	#$f6,d0
		bcs	.yes
		cmp.b	#$ff,d0
		beq	.joy0
		cmp.b	#$fe,d0
		beq	.joy1
		
		cmp.b	#$f8,d0
		blt	.nomouse
		cmp.b	#$fb,d0
		bgt	.nomouse
		bra	.mouse1
.nomouse
.dun
		rts
		
.mouse1		move.b	2(a1),d0
		move.b	d0,mse_packet
		move.w	#1,mouseflg
		rts
		
.mouse1b	move.b	2(a1),d0
		move.b	d0,mse_packet+1
		move.w	#2,mouseflg
		ext	d0
		add	d0,mousex
		
		cmp	#319,mousex
		blt	.mxntb
		move	#319,mousex
.mxntb		cmp	#0,mousex
		bgt	.mxntb2
		move	#0,mousex
.mxntb2		rts
		
.mouse2b	move.b	2(a1),d0
		move.b	d0,mse_packet+2
		clr.w	mouseflg
		ext	d0
		add	d0,mousey
		cmp	#199,mousey
		blt	.myntb
		move	#199,mousey
.myntb		cmp	#0,mousey
		bgt	.myntb2
		move	#0,mousey
.myntb2		rts
		
.yes		btst	#7,d0
		bne.s	.db
		cmp.w	#1,debounce
		beq.s	.pass
		lea	keycodes,a0
		ext.w	d0
		move	d0,scancode
		move.b	(a0,d0.w),keybuf
		move.w	#1,debounce
.pass		rts
.db		;not.w	$ff8240
		clr.w	debounce
		rts
		
.joy1		move.b	2(a1),d0
		move.w	#1,joy1flg
		rts
		
.joy0		move.b	2(a1),d0
		move.w	#1,joy0flg
		rts
.joy0b		move.b	2(a1),d0
		move.b	d0,direction
.no		clr.w	joy0flg
		rts
		
.joy1b		move.b	2(a1),d0
		move.b	d0,direction+1
.no2		clr.w	joy1flg
		rts
	
			
*--------------- timer B handler (hbl!)

hbl_handler
		clr.b	tbcr
		move	#$764,$ffff824a.w			
		move.l	#$06530542,$ffff824c.w			
		bclr	#0,isra
		move.l	#hbl0,$120
		move.b	#4,tbdr
		move.b	#8,tbcr
		rte
		
hbl0
		clr.b	tbcr
		move.l	a0,-(sp)
		move.l	curcol,a0
		move	(a0)+,$ffff8248.w
		move.l	a0,curcol
		move.l	(sp)+,a0
		addq	#1,scanline
		cmp	#12,scanline
		blt.s	.dsi
		bclr	#0,isra
		move.l	#hbl1,$120
		move.b	#6,tbdr
		move.b	#8,tbcr
		rte
.dsi
		bclr	#0,isra
		move.b	#6,tbdr
		move.b	#8,tbcr
		rte
hbl1
		clr.b	tbcr
		move	#$030,$ffff8242.w
		move.l	#$00400050,$ffff8244.w
		bclr	#0,isra
		move.l	#hbl2,$120
		move.b	#12,tbdr
		move.b	#8,tbcr
		rte
hbl2
		clr.b	tbcr
		move	#$070,$ffff8242.w
		move.l	#$00600050,$ffff8244.w
		
		move	#$730,$ffff824a.w
		move.l	#$06200510,$ffff824c.w
		
		bclr	#0,isra
		move.l	#hbl3,$120
		move.b	#18,tbdr
		move.b	#8,tbcr
		rte
hbl3
		clr.b	tbcr
		movem.l	a0-a1,-(sp)
		lea	fnt+4,a0
		lea	$ffff8240.w,a1
		rept	8
		move.l	(a0)+,(a1)+
		endr
		move	#$777,$ffff8250.w
		movem.l	(sp)+,a0-a1
		bclr	#0,isra
		move.l	#hbl4,$120
		move.b	#22,tbdr
		move.b	#8,tbcr
		rte
		
hbl4
		clr.b	tbcr
		movem.l	a0/d0,-(sp)
		lea	tbdr,a0
		move.b	#200,(a0)
		move.b	#8,tbcr

		move.b	(a0),d0
wfrb		cmp.b	(a0),d0		
		beq	wfrb		
		clr.b	$ffff820a.w     
		moveq	#4-1,d0
nops		nop			
		dbf	d0,nops
                move.b  #2,$ffff820a.w 
		movem.l	(sp)+,a0/d0
		bclr	#0,isra
		clr.b	tbcr
		move.l	#hbl5,$120
		move.b	#28,tbdr
		move.b	#8,tbcr
		rte
		
hbl5
		clr.b	tbcr
		move.l	a0,-(sp)
		lea	$ffff8240.w,a0
		rept	8
		clr.l	(a0)+
		endr
		move.l	(sp)+,a0
		bclr	#0,isra
		rte
*--------------- vbl handler (vbl!!)

vbl_handler
		movem.l	d0-d7/a0-a6,-(sp)
		
		addq	#1,frclock		; inc frame counter

		*clr.b	tacr			; set timer A
		*move.b	#102,tadr		
		*move.b	#4,tacr		
		
		clr.b	tbcr			; set timer B
		move.b	#71,tbdr
		move.l	#hbl_handler,$120
		move.b	#8,tbcr
		clr	scanline
		move.l	#cols,curcol
		
*--------------- bailout check!
		btst	#3,keystat	; alt pressed!
		beq.s	.ahnp
		cmp	#$62,scancode	; help pressed
		bne.s	.ahnp
					; alt+help pressed!
		
		move	#8*4,errno
		move.l	#di2,32+28+6(sp)
.ahnp
*---------------
		
		clr	$ffff8240.w
		move.l	#$03370777,$ffff8248.w			
		move.l	#$06660555,$ffff824c.w			
		lea	$ffff8250.w,a0
		rept	4
		clr.l	(a0)+		
		endr
		
*---------------
		jsr	mux+4
		
		movem.l	(sp)+,d0-d7/a0-a6
		rte	
	
*--------------- timer A handler (dunno!!!)

timer_a
		clr.b	tacr
		clr.b	$ffff820a.w
		rept	80
		nop
		endr
		move.b	#2,$ffff820a.w
		bclr	#5,isra
		rte
*--------------- guru 68000 error vector trap fingy jobby boof jiggo!
die		
		rept	7
		add	#4,errno
		endr
		
di2		movem.l	d0-d7/a0-a6,-(sp)
*--------------- set screen
		move.l	up_scr,d7
		bsr	set_scr
		move.b	#0,$ff8260
*---------------
		move.l	up_scr,a0
		bsr	scr_clr
*---------------
		lea	gurumes,a6
		clr	xpos
		clr	ypos
		bsr	text_pr

*--------------- actually print error message!
		moveq.l	#0,d0
		move	errno,d0
		lea	errs,a0
		move.l	(a0,d0.w),a6

		clr	xpos
		move	#18,ypos
		bsr	text_pr

*--------------- dump those reggies!

*--------------- data regs
		clr	xpos
		add	#18,ypos
		movem.l	(sp),d0-d7/a0-a6
		move.l	#"D0 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	d1,d0
		move.l	#"D1 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	d2,d0
		move.l	#"D2 :",allbuf
		bsr	preg
		add	#9,ypos
		clr	xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	d3,d0
		move.l	#"D3 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	d4,d0
		move.l	#"D4 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	d5,d0
		move.l	#"D5 :",allbuf
		bsr	preg
		add	#9,ypos
		clr	xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	d6,d0
		move.l	#"D6 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	d7,d0
		move.l	#"D7 :",allbuf
		bsr	preg
		
*--------------- addr regs
		clr	xpos
		add	#18,ypos
		movem.l	(sp),d0-d7/a0-a6
		move.l	a0,d0
		move.l	#"A0 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	a1,d0
		move.l	#"A1 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	a2,d0
		move.l	#"A2 :",allbuf
		bsr	preg
		add	#9,ypos
		clr	xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	a3,d0
		move.l	#"A3 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	a4,d0
		move.l	#"A4 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	a5,d0
		move.l	#"A5 :",allbuf
		bsr	preg
		add	#9,ypos
		clr	xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	a6,d0
		move.l	#"A6 :",allbuf
		bsr	preg
		add	#8,xpos
		movem.l	(sp),d0-d7/a0-a6
		move.l	a7,d0
		move.l	#"A7 :",allbuf
		bsr	preg
		
*--------------- RTE jobber
		clr	xpos
		add	#18,ypos
		move.l	32+28+10(sp),d0
		move.l	#"RTE:",allbuf
		bsr	preg
*---------------
		lea	butmes,a6
		clr	xpos
		add	#18,ypos
		bsr	text_pr
*---------------
		move	sr,d7
		move	#$2700,sr
		move.l	#$00000777,$ffff8240.w	
.gwfk		cmp.b	#$39,$fffffc02.w
		bne.s	.gwfk
		move	d7,sr
			
		movem.l	(sp)+,d0-d7/a0-a6
		bra	finish
		
preg
		lea	addrbuf+8,a3
		bsr	hexcon
		lea	allbuf,a6
		bsr	text_pr
		rts
		
*--------------- guru text & shit!
errs
		dc.l	buserr
		dc.l	addrerr
		dc.l	illerr
		dc.l	diverr
		dc.l	chkerr
		dc.l	trpverr
		dc.l	priverr
		dc.l	trcerr
		
		dc.l	blout		; bailout fingy!

gurumes		dc.b	"       Software Failure (Ha,Ha!)",0
butmes		dc.b	"Hey, dude, fump the SPACE bar...",0
buserr		dc.b	"08 :Bus Error",0
addrerr		dc.b	"0C :Address Error",0
illerr		dc.b	"10 :Illegal Instruction",0
diverr		dc.b	"14 :Division by Zero Error",0
chkerr		dc.b	"18 :CHK Instruction",0
trpverr		dc.b	"1C :TRAPV Instruction",0
priverr		dc.b	"20 :Privilege Violation Error",0
trcerr		dc.b	"24 :Trace",0
		even
blout		dc.b	"Bailed Out",0
		even
errno		ds.w		1
allbuf		ds.b		4
addrbuf		ds.b		9
		even
nums		dc.b	"0123456789ABCDEF"
		even
*--------------- boring old variables

frclock		ds.w		1
old_vbl_vec	dc.l		0
old_key_vec	dc.l		0
old_hbl_vec	DC.L		0
old_tima	ds.l		1
old_ieb		DC.B		0
old_iea		DC.B		0
old_ima		DC.B		0
old_shftmod	DC.B		0
old_ssp		DC.L		0
screen		dc.l		$78000
screen1		dc.l		$70000
up_scr		dc.l		$78000
swi		ds.w		1
keybuf		dc.w		0
joy0flg		dc.w		0
joy1flg		dc.w		0
mouseflg	dc.w		0
debounce	dc.w		0
direction	dc.w		0
scancode	ds.w		1	
mse_packet
buttons		ds.b		1
relx		ds.b		1
rely		ds.b		1
		ds.b		1
mousex		dc.w		100
mousey		dc.w		100

keystat		ds.w		1
					; bit   key
					;  0     left shift
					;  1     right shift
					;  2     control
					;  3     alternate
					;  4     caps lock

old_vex		ds.l		8
new_vex
		dc.l		die+56
		dc.l		die+48
		dc.l		die+40
		dc.l		die+32
		dc.l		die+24
		dc.l		die+16
		dc.l		die+8
		dc.l		die
		
old_scr		ds.l		1
old_pal		ds.l		16
old_frq		ds.w		1
ste_flag	dc.w		0	; 0 - ST, 1 - STE
cart_flag	dc.w		0	; 0 - none, 1 - cratridge!
		
*--------------- keyboard table

keycodes	dc.b	0,0,"1","2","3","4","5","6"
		dc.b	"7","8","9","0","-","=",$ff,0
		dc.b	"Q","W","E","R","T","Y","U","I"
		dc.b	"O","P","[","]",13,0,"A","S"
		dc.b	"D","F","G","H","J","K","L",":"
		dc.b	"'","`",0,"#","Z","X","C","V"
		dc.b	"B","N","M",",",".","/",0,0
		dc.b	0," ",0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,"-",0,0,0,"+",0
		dc.b	0,0,0,$ff,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	"<",0,0,"(",")","/","*","7"
		dc.b	"8","9","4","5","6","1","2","3"
		dc.b	"0",".",13,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0

*--------------- charset etc...

xpos	ds.w	1
ypos	ds.w	1

chrtab
	ds.l	40*4

chars			; (alias font!)
	dc.w	$000C,$6C6C,$1862,$7818,$3018,$0000,$0000,$0000
	dc.w	$7C30,$787C,$88FE,$3CFE,$7C7C,$0000,$0C00,$307C
	dc.w	$3C1C,$F87C,$F87C,$7E7E,$001E,$6C6C,$3E66,$CC38
	dc.w	$600C,$6C18,$0000,$0000,$CE78,$CCCE,$D8C4,$66CC
	dc.w	$CECE,$3030,$1800,$1866,$6636,$C6EE,$DCFE,$FCFC
	dc.w	$001E,$6CFE,$600C,$7800,$C006,$3818,$0000,$0000
	dc.w	$9A18,$0606,$D8C0,$C018,$C6C6,$3030,$303C,$0C0E
	dc.w	$6E66,$C6C4,$CEC0,$C080,$000C,$006C,$3C18,$7000
	dc.w	$C006,$FE7E,$0038,$0000,$B618,$7C1C,$7EFC,$FC7C
	dc.w	$7C7E,$0000,$6000,$061C,$6EFE,$CCC0,$C670,$F882
	dc.w	$0000,$00FE,$0630,$CE00,$C006,$3818,$0000,$0000
	dc.w	$E618,$C006,$180E,$CE30,$C606,$3030,$303C,$0C18
	dc.w	$60C6,$C6C0,$C6E0,$F0C6,$000C,$006C,$7C66,$CC00
	dc.w	$600C,$6C18,$3000,$3000,$CE18,$7CC6,$18C6,$E630
	dc.w	$E606,$3060,$1800,$1800,$62C6,$CE62,$FC7E,$C066
	dc.w	$000C,$006C,$1846,$7E00,$3018,$0000,$6000,$3000
	dc.w	$7C08,$3E7C,$087C,$7C10,$7C02,$0000,$0C00,$3018
	dc.w	$3C84,$3C3C,$783C,$803E,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$8438,$1E82,$8044,$843C,$3C3C,$3C3C,$0E42,$8482
	dc.w	$0282,$FC78,$601E,$0000,$3000,$8000,$0400,$0E00
	dc.w	$4000,$0C40,$6000,$0000,$C600,$0EC6,$C0EE,$C66E
	dc.w	$6666,$6666,$FCC6,$C6C6,$CEC6,$7C60,$3006,$0000
	dc.w	$3800,$C000,$0600,$1800,$C018,$00C0,$3000,$0000
	dc.w	$CE38,$06CC,$C0FE,$E6C6,$C6C6,$CCC0,$78C6,$C6C6
	dc.w	$7C6C,$1860,$1806,$0000,$003C,$DC7C,$767C,$183C
	dc.w	$DC00,$0CC6,$30EC,$DC3C,$FE38,$86F8,$C0D6,$F6C6
	dc.w	$FCC6,$F87C,$18C6,$C6D6,$3838,$3060,$1806,$0000
	dc.w	$006C,$F6C6,$DEC6,$3C66,$F618,$0CCC,$30FE,$F66E
	dc.w	$E638,$86FC,$C0C6,$DEC6,$C0DA,$D806,$18C6,$66FE
	dc.w	$7C18,$6060,$1806,$0000,$00CC,$E6C0,$CEFC,$18C6
	dc.w	$E618,$0CF8,$30D6,$E6C6,$C618,$CEC6,$FCC6,$CEEC
	dc.w	$C0EC,$CC8E,$186E,$3CEE,$E618,$FC60,$0C06,$0000
	dc.w	$00CC,$C662,$C660,$187E,$C618,$0CFC,$30C6,$C6EC
	dc.w	$4208,$7C82,$3E82,$4678,$807E,$847C,$083C,$1844
	dc.w	$8008,$7E78,$061E,$003C,$0076,$7C3C,$7C3E,$0806
	dc.w	$C608,$78C6,$1C82,$4278,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007C,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$1800,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$1E00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3C7E,$DC3E,$7884,$8682,$8684,$7E00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$66C6,$E660,$18C6,$CCC6
	dc.w	$6CC6,$0C00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$C6C6,$C03C,$18CE,$D8D6,$38C6,$3000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FC7E,$C00E,$18DE,$70FE
	dc.w	$6C7E,$6000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$C006,$40FC,$0E76,$206C,$C206,$FC00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$8004,$0000,$0000,$0000
	dc.w	$00FC,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	
*--------------- nuffink at all!

pic	incbin	beast.neo
*---------------
mux	incbin	jambala.smf
*--------------- variables
chrcnt		ds.w	1
bufswi		ds.w	1
buf0		ds.b	44*24
buf1		ds.b	44*24
buf2		ds.b	44*24
buf3		ds.b	44*24
buf4		ds.b	44*24
buf5		ds.b	44*24
buf6		ds.b	44*24
buf7		ds.b	44*24
mespnt		dc.l	text
text					; 11 SPACES THEN A '#' !
	dc.b	"-GOR-           #"
	dc.b	"THE ALIEN           #"
	dc.b	"LAWZ           #"
	dc.b	"PP SLEDGEHAMMER           #"
	dc.b	"THE GENIE           #"
	dc.b	-1

		even
*---------------

lchrcnt		ds.w	1
lbuf		ds.b	168*8

lpnt		dc.l	ltext
ltext		
		dc.b	"This kewl intro was coded by           #"
		dc.b	"Goldrunner adjusted by                 #"
		dc.b	"Leathernecks adjusted by               #"
		dc.b	"Supersprint adjusted by                #"
		dc.b	"Bubble Ghost adjusted by               #"
		dc.b	-1
		even
*---------------
		

lchrcnt2	ds.w	1
lbuf2		ds.b	168*8

lpnt2		dc.l	ltext2
ltext2		
		dc.b	"Being sooooo nice, I thought I'd leave some space for "
		dc.b	"Alien to write a scrolltext!!!  "
		dc.b	"The Corporashun rules! Well, it would be better if "
		dc.b	"we changed the name to The GORporation! Just remember "
		dc.b	"who it was that told me to develop my ego (Sledge!)! "
		dc.b	"Medway forever...    Praw...        "
		dc.b	-1
		even
		
chrtab1		

fnttab
	dc.l	fnt+128
	dc.l	fnt+128+16
	dc.l	fnt+128+32
	dc.l	fnt+128+48
	dc.l	fnt+128+64
	dc.l	fnt+128+80
	dc.l	fnt+128+96
	dc.l	fnt+128+112
	dc.l	fnt+128+128
	dc.l	fnt+128+144

	dc.l	fnt+128+(24*160)
	dc.l	fnt+128+(24*160)+16
	dc.l	fnt+128+(24*160)+32
	dc.l	fnt+128+(24*160)+48
	dc.l	fnt+128+(24*160)+64
	dc.l	fnt+128+(24*160)+80
	dc.l	fnt+128+(24*160)+96
	dc.l	fnt+128+(24*160)+112
	dc.l	fnt+128+(24*160)+128
	dc.l	fnt+128+(24*160)+144
	
	dc.l	fnt+128+(48*160)
	dc.l	fnt+128+(48*160)+16
	dc.l	fnt+128+(48*160)+32
	dc.l	fnt+128+(48*160)+48
	dc.l	fnt+128+(48*160)+64
	dc.l	fnt+128+(48*160)+80
	dc.l	fnt+128+(48*160)+96
	dc.l	fnt+128+(48*160)+112
	dc.l	fnt+128+(48*160)+128
	dc.l	fnt+128+(48*160)+144
	
	dc.l	fnt+128+(72*160)
	dc.l	fnt+128+(72*160)+16
	dc.l	fnt+128+(72*160)+32
	dc.l	fnt+128+(72*160)+48
	dc.l	fnt+128+(72*160)+64
	dc.l	fnt+128+(72*160)+80
	dc.l	fnt+128+(72*160)+96
	dc.l	fnt+128+(72*160)+112
	dc.l	fnt+128+(72*160)+128
	dc.l	fnt+128+(72*160)+144
	
	dc.l	fnt+128+(96*160)
	dc.l	fnt+128+(96*160)+16
	dc.l	fnt+128+(96*160)+32
	dc.l	fnt+128+(96*160)+48
	dc.l	fnt+128+(96*160)+64
	dc.l	fnt+128+(96*160)+80
	dc.l	fnt+128+(96*160)+96
	dc.l	fnt+128+(96*160)+112
	dc.l	fnt+128+(96*160)+128
	dc.l	fnt+128+(96*160)+144

	dc.l	fnt+128+(120*160)
	dc.l	fnt+128+(120*160)+16
	dc.l	fnt+128+(120*160)+32
	dc.l	fnt+128+(120*160)+48
	dc.l	fnt+128+(120*160)+64
	dc.l	fnt+128+(120*160)+80
	dc.l	fnt+128+(120*160)+96
	dc.l	fnt+128+(120*160)+112
	dc.l	fnt+128+(120*160)+128
	dc.l	fnt+128+(120*160)+144

fnt	incbin	nicefont.neo

bcnt		ds.w	1
bufs
		dc.l	buf0
		dc.l	buf1
		dc.l	buf2
		dc.l	buf3
		dc.l	buf4
		dc.l	buf5
		dc.l	buf6
		dc.l	buf7
		
chrbuf		ds.b	6*24

*-----------------
txtpnt		dc.l	tit_head
tit_head		
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"Guess who's back...                     ",13
		dc.b	"                                        ",13
txt		
		dc.b	"                                        ",13
		dc.b	"                  The                   ",13
		dc.b	"                                        ",13
		dc.b	"     ***   **  *   * ***  *** *   *     ",13
		dc.b	"     *  * *  * ** ** *  * *    * *      ",13
		dc.b	"     ***  *  * * * * ***  **    *       ",13
		dc.b	"     *    *  * *   * *    *     *       ",13
		dc.b	"     *     **  *   * *    ***   *       ",13
		dc.b	"                                        ",13
		dc.b	"     ***  * ***   **  ***** ***  ***    ",13
		dc.b	"     *  * * *  * *  *   *   *   *       ",13
		dc.b	"     ***  * ***  ****   *   **   **     ",13
		dc.b	"     *    * *  * *  *   *   *      *    ",13
		dc.b	"     *    * *  * *  *   *   *** ***     ",13
		dc.b	"                                        ",13
		dc.b	"            of The Corporation          ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"          Very Proudly Present          ",13
		dc.b	"                                        ",13
		dc.b	"                 MENU 69                ",13
		dc.b	"           (Shadow of the Best)         ",13
		dc.b	"                                        ",13
		dc.b	"           1) Goldrunner                ",13
		dc.b	"           2) Leathernecks              ",13
		dc.b	"           3) Supersprint               ",13
		dc.b	"           4) Bubble Ghost              ",13
		dc.b	"                                        ",13
		dc.b	"         - Space for the dox -          ",13
		dc.b	"                                        ",13
		dc.b	"              Members are               ",13
		dc.b	"                                        ",13
		dc.b	"                The Alien               ",13
		dc.b	"                  Lawz                  ",13
		dc.b	"              PP Sledgehammer           ",13
		dc.b	"                  -GOR-                 ",13
		dc.b	"                   JPM                  ",13
		dc.b	"                   DES                  ",13
		dc.b	"               Richard III              ",13
		dc.b	"                The Genie               ",13
		dc.b	"                  Syd.B                 ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"             ***  ***  ***              ",13
		dc.b	"            *    *   * *  *             ",13
		dc.b	"     *****  * ** *   * *  *  *****      ",13
		dc.b	"            *  * *   * ***              ",13
		dc.b	"             ***  ***  *  *             ",13
		dc.b	"                                        ",13
		dc.b	"       Sez hi to the following...       ",13
		dc.b	"                                        ",13
		dc.b	"      The rest of the Corporation       ",13
		dc.b	"  (Sewer Software and the Medway Boy)   ",13
		dc.b	" ST Amigos (Nice Western music, Sparky!)",13
		dc.b	"              TUF and Keef              ",13
		dc.b	"      Boggy and his Sister (Karen)      ",13
		dc.b	" The 'Megamighty' Frosty of The Source  ",13
		dc.b	"        Trev of the Dream Weavers       ",13
		dc.b	"               Supercrack               ",13
		dc.b	"     The Byg (why you not write me?)    ",13
		dc.b	"     Appollo from Guardians of Logik    ",13
		dc.b	"             RX2 of Teknique            ",13
		dc.b	"         Paul.F from Manchester         ",13
		dc.b	"Alan from Hull (Can wait to see you!(!))",13
		dc.b	"          Rodent and Caroline.T         ",13
		dc.b	"             Gareth the Monk            ",13
		dc.b	"  M.C.Hammer of the Justice Department  ",13
		dc.b	"  The MR Men (Mr Happy and Mr Nameless) ",13
		dc.b	"Slippery Sid and the Slimeballs (Hi ???)",13
		dc.b	"       Simon of the Black Wizards       ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"Special message from -GOR- to J.I.M.M.Y ",13
		dc.b	"             of Mantronix               ",13
		dc.b	"                                        ",13
		dc.b	"   Firstly, what sort of idiot sticks   ",13
		dc.b	" someones full name on a menu scroller? ",13
		dc.b	" Secondly, I don't think speaking to me ",13   
		dc.b	" once on the phone exactly makes you my ",13
		dc.b	" friend, especially when you go and pull",13
		dc.b	"      a dumb ass stunt like that!       ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"             Let us praw...             ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		dc.b	"                                        ",13
		
		dc.b	-1
		even
print_me	dc.w	0
*---------------
scnt		ds.w	1
*---------------
scflag		ds.w	1
stflag		ds.w	1
*---------------
scanline	ds.w	1
*---------------
curcol	dc.l	cols
cols
	dc.w	$337,$427,$517,$607,$707,$717,$727
	dc.w	$737,$747,$757,$767,$777
*---------------
wsb1	ds.w	1
wsh1	ds.w	1
wsb2	ds.w	1
wsh2	ds.w	1
wsb3	ds.w	1
wsh3	ds.w	1
wsb4	ds.w	1
wsh4	ds.w	1
wsb5	ds.w	1
wsh5	ds.w	1
wsb6	ds.w	1
wsh6	ds.w	1
wsb7	ds.w	1
wsh7	ds.w	1
*-----------------
well_cum	dc.b	"     Welcome to Pirates of Pompey",10
		dc.b	"               Menu 69!",0		
credz		
		dc.b	"              Coded by the",10
		dc.b	"              Mega-mighty",10
		dc.b	"                 -GOR-",0
		even
*-----------------
gspc	ds.b	(80*30)*16
mspc	*ds.b	(80*75)*16
