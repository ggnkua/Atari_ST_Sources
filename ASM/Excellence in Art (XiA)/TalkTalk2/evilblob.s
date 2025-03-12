; 2009-07-18
;
; 1 bitplane ST-effect for XiA
;
; Uses about 40% cpu
;
; Anders Eriksson
; ae@dhs.nu

 .68000
		; .text

blob_init:
.sin:		
    bsr.w	blob_singen			; fill up sin values for all scans before the fx begin
		subq.w	#1,.count
		bpl.s	.sin
		rts
.count:
  dc.w	150


blob_main:
    bsr.w	blob_singen
		bsr.w	blob_render
		rts

blob_vbl:
    movem.l	blob_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts
		

blob_render:
;		move.l	screen_adr,a6
	move.l screenaddress,a6
	add.l #(160*25)+6,a6
		lea.l	blob_data+(40*80),a5
		lea.l	blob_data+(40*160)+(40*80),a1
		lea.l	blob_zoomlist,a4
		lea.l	blob_zoomlist2+(200*4),a3
		add.w	blob_listofs,a4
		add.w	blob_listofs,a3
q set 0
		rept 75
		 ;100
		move.l	a5,a2
		add.l	(a4)+,a2
		add.l	-(a3),a2

  if 1=1
    qq set q
    rept 20
		  move.w	(a2)+,qq(a6)
		  qq set qq+8
		endr
  else
		move.w	(a2)+,q+8*0(a6)
		move.w	(a2)+,q+8*1(a6)
		move.w	(a2)+,q+8*2(a6)
		move.w	(a2)+,q+8*3(a6)
		move.w	(a2)+,q+8*4(a6)
		move.w	(a2)+,q+8*5(a6)
		move.w	(a2)+,q+8*6(a6)
		move.w	(a2)+,q+8*7(a6)
		move.w	(a2)+,q+8*8(a6)
		move.w	(a2)+,q+8*9(a6)
		move.w	(a2)+,q+8*10(a6)
		move.w	(a2)+,q+8*11(a6)
		move.w	(a2)+,q+8*12(a6)
		move.w	(a2)+,q+8*13(a6)
		move.w	(a2)+,q+8*14(a6)
		move.w	(a2)+,q+8*15(a6)
		move.w	(a2)+,q+8*16(a6)
		move.w	(a2)+,q+8*17(a6)
		move.w	(a2)+,q+8*18(a6)
		move.w	(a2)+,q+8*19(a6)
  endif

q set q+160
		move.l	a1,a2
		add.l	(a4)+,a2
		add.l	-(a3),a2
  if 1=1
    qq set q
    rept 20
		  move.w	(a2)+,qq(a6)
		  qq set qq+8
    endr
  else
		move.w	(a2)+,q+8*0(a6)
		move.w	(a2)+,q+8*1(a6)
		move.w	(a2)+,q+8*2(a6)
		move.w	(a2)+,q+8*3(a6)
		move.w	(a2)+,q+8*4(a6)
		move.w	(a2)+,q+8*5(a6)
		move.w	(a2)+,q+8*6(a6)
		move.w	(a2)+,q+8*7(a6)
		move.w	(a2)+,q+8*8(a6)
		move.w	(a2)+,q+8*9(a6)
		move.w	(a2)+,q+8*10(a6)
		move.w	(a2)+,q+8*11(a6)
		move.w	(a2)+,q+8*12(a6)
		move.w	(a2)+,q+8*13(a6)
		move.w	(a2)+,q+8*14(a6)
		move.w	(a2)+,q+8*15(a6)
		move.w	(a2)+,q+8*16(a6)
		move.w	(a2)+,q+8*17(a6)
		move.w	(a2)+,q+8*18(a6)
		move.w	(a2)+,q+8*19(a6)
  endif
q set q+160
		endr
		rts


blob_singen:	;first sinlist
		add.l   #34,.sin1
		and.l   #$1fff,.sin1
		lea.l	blob_sincos,a0
		move.l  .sin1,d0
		move.w  (a0,d0.l),d1
		muls.w  #79,d1
		asr.l   #8,d1
		asr.l   #7,d1
		muls.w	#40,d1
		lea.l	blob_zoomlist,a0
		add.w	blob_listofs,a0
		move.l	d1,(a0)
v set 200*4
		move.l	d1,v(a0)

		;second sinlist
		add.l   #80,.sin2
		and.l   #$1fff,.sin2
		lea.l	blob_sincos,a0
		move.l  .sin2,d0
		move.w  (a0,d0.l),d2
		muls.w  #79,d2
		asr.l   #8,d2
		asr.l   #7,d2
		muls.w	#40,d2
		lea.l	blob_zoomlist2,a0
		add.w	blob_listofs,a0
		move.l	d2,(a0)
v set 200*4
		move.l	d2,v(a0)

		cmp.w	#4*199,blob_listofs
		blt.s	.add
		clr.w	blob_listofs
		bra.s	.done
.add:		addq.w	#4,blob_listofs
.done:

		rts

.sin1:
  dc.l	0
.sin2:
  dc.l	0


		; . data

;blob_sincos:	incbin	sin.bin
;blob_sincos equ evilsintable
;		even
;
;blob_data:	incbin	blob.1pl
;blob_data equ evilblobtable
;		even

;blob_listofs:	dc.w	0
;blob_zoomlist:	dcb.l	400,0
;blob_zoomlist2:	dcb.l	400,0
;blob_pal:	dc.w	$0000
;		dcb.w	15,$0fff
		
;		section	text
