
;нннннннннннннннннннннннннннннннннннннннн
;н     NoisetrackerV2.0 FASTreplay      н
;н  Uses lev6irq - takes 7 rasterlines  н
;н Do not disable Master irq in $dff09a н
;н Used regs: d0-d7/a0-a5/a7 |  =INTENA н
;н   Mahoney & Kaktus - й E.A.S. 1990   н
;нннннннннннннннннннннннннннннннннннннннн
;н     Imported to you by Accession     н
;нннннннннннннннннннннннннннннннннннннннн

mt_data=$58000

mt_init:lea	mt_data,a0
	lea	mt_mulu(pc),a1
	move.l	#mt_data+$c,d0
	moveq	#$1f,d1
	moveq	#$1e,d3
mt_lop4:move.l	d0,(a1)+
	add.l	d3,d0
	dbf	d1,mt_lop4

	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d1
	moveq	#0,d2
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.w	#1,d2

	swap	d2
	lsr.l	#6,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#$2a,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.b	d1,2(a0)
	move.w	(a0),d1
	add.l	d1,d1
	add.l	d1,a2
	add.l	d3,a0
	dbf	d0,mt_lop3

	move.l	$78.w,mt_irq+2-mt_samplestarts-$7c(a1)
	or.b	#2,$bfe001
	move.b	#6,mt_spd+3-mt_samplestarts-$7c(a1)
	moveq	#0,d0
	move.b	d0,mt_song+3-mt_samplestarts-$7c(a1)
	move.b	d0,mt_cou+1-mt_samplestarts-$7c(a1)
	move.w	d0,mt_patt+2-mt_samplestarts-$7c(a1)
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
	rts

mt_end:	moveq	#0,d0
	lea	$dff000,a0
	move.b	d0,$bfde00
	move.b	#$7f,$bfdd00
	move.w	#$2000,$9c(a0)
	move.w	#$2000,$9a(a0)
	move.l	mt_irq+2(pc),$78.w
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	move.w	#$f,$dff096
	rts

mt_nonew:
	lea	$dff0a0,a5
	jsr	mt_com(pc)
	lea	mt_voice2(pc),a4
	lea	$10(a5),a5
	jsr	mt_com(pc)
	lea	mt_voice3(pc),a4
	lea	$10(a5),a5
	jsr	mt_com(pc)
	lea	mt_voice4(pc),a4
	lea	$10(a5),a5
	jsr	mt_com(pc)
	tst.b	mt_brk+3-mt_voice4(a4)
	bne	mt_next
	rts

mt_music:
	move.w	#$fff,d4
	moveq	#$f,d5
	move.w	#$f0,d6
	moveq	#0,d7
	lea	mt_voice1(pc),a4
	addq.b	#1,mt_cou+1-mt_voice1(a4)
	lea	mt_data,a0
mt_cou:	moveq	#0,d0
mt_spd:	cmp.b	#6,d0
	blt.s	mt_nonew
	move.b	d7,mt_cou+1-mt_voice1(a4)
	move.w	d7,mt_dma+2-mt_voice1(a4)
	lea	mt_data,a0
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d1
	moveq	#0,d0
mt_song:move.b	#0,d0
	move.b	(a2,d0.w),d1
	swap	d1
	lsr.l	#6,d1
mt_patt:add.w	#0,d1
	lea	(a0,d1.l),a0
	lea	$dff0a0,a5
	lea	mt_samplestarts-4(pc),a1
	jsr	mt_playvoice(pc)
	lea	$10(a5),a5
	lea	mt_voice2(pc),a4
	jsr	mt_playvoice(pc)
	lea	$10(a5),a5
	lea	mt_voice3(pc),a4
	jsr	mt_playvoice(pc)
	lea	$10(a5),a5
	lea	mt_voice4(pc),a4
	jsr	mt_playvoice(pc)

mt_dma:	move.w	#0,d0
	beq.s	mt_nodma

	lea	$bfd000,a3
	move.b	#$7f,$d00(a3)
	move.w	#$2000,$dff09c
	move.w	#$a000,$dff09a
	move.l	#mt_irq1,$78.w
	move.b	d7,$e00(a3)
	move.b	#$aa,$400(a3)
	move.b	d7,$500(a3)
	or.w	#$8000,mt_dma+2-mt_voice4(a4)
	move.b	#$11,$e00(a3)
	move.b	#$81,$d00(a3)

mt_nodma:
	add.w	#$10,mt_patt+2-mt_voice4(a4)
	cmp.w	#$400,mt_patt+2-mt_voice4(a4)
	bne.s	mt_exit
mt_next:move.w	d7,mt_patt+2-mt_voice4(a4)
	move.b	d7,mt_brk+3-mt_voice4(a4)
	addq.b	#1,mt_song+3-mt_voice4(a4)
	move.b	-2(a2),d0
	cmp.b	mt_song+3(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_song+3-mt_voice4(a4)
mt_exit:
mt_brk:	move.b	#0,d0
	bne.s	mt_next
	rts

mt_irq1:tst.b	$bfdd00
	move.w	mt_dma+2(pc),$dff096
	move.l	#mt_irq2,$78.w
	move.w	#$2000,$dff09c
	rte

mt_irq2:tst.b	$bfdd00
	movem.l	a3/a4,-(a7)
	lea	mt_voice1(pc),a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.w	$12(a4),$a8(a3)
	move.l	$28(a4),$b0(a3)
	move.w	$2c(a4),$b4(a3)
	move.w	$30(a4),$b8(a3)
	move.l	$46(a4),$c0(a3)
	move.w	$4a(a4),$c4(a3)
	move.w	$4e(a4),$c8(a3)
	move.l	$64(a4),$d0(a3)
	move.w	$68(a4),$d4(a3)
	move.w	$6c(a4),$d8(a3)
	movem.l	(a7)+,a3/a4
	move.b	#0,$bfde00
	move.b	#$7f,$bfdd00
mt_irq:	move.l	#0,$78.w
	move.w	#$2000,$dff09c
	move.w	#$2000,$dff09a
	rte

mt_playvoice:
	move.l	(a0)+,(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	d6,d0
	or.b	d0,d2
	beq	mt_oldinstr
	add.w	d2,d2
	add.w	d2,d2
	move.l	mt_mulu(pc,d2.w),a3
	move.l	(a1,d2.l),4(a4)
	move.w	(a3)+,8(a4)
	move.w	(a3)+,$12(a4)
	move.l	4(a4),d0
	move.w	(a3)+,d3
	beq	mt_noloop
	ext.l	d3
	add.w	d3,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	-2(a3),d0
	add.w	(a3),d0
	move.w	d0,8(a4)
	bra	mt_hejaSverige

mt_mulu:blk.l	$20,0

mt_setport:
	move.w	(a4),d2
	and.w	d4,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	move.b	d7,$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_com2
	move.b	#1,$14(a4)
	bra.s	mt_com2
mt_clrport:
	move.w	d7,$16(a4)
	rts

mt_noloop:
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	(a3),$e(a4)

mt_oldinstr:
	move.w	(a4),d3
	and.w	d4,d3
	beq.s	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	move.b	2(a4),d0
	and.b	d5,d0
	subq.b	#3,d0
	beq.s	mt_setport
	subq.b	#2,d0
	beq.s	mt_setport
	move.w	d3,$10(a4)
	move.w	$1c(a4),$dff096
	move.b	d7,$19(a4)
	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)
	move.w	$1c(a4),d0
	or.w	d0,mt_dma+2-[mt_samplestarts-4](a1)

mt_com2:move.b	2(a4),d0
	and.b	d5,d0
	beq.s	mt_rts2
	sub.b	d5,d0
	beq.s	mt_setspeed
	addq.b	#1,d0
	beq.s	mt_filter
	addq.b	#1,d0
	beq.s	mt_pattbreak
	addq.b	#1,d0
	beq.s	mt_setvol
	addq.b	#1,d0
	beq.s	mt_songjmp
mt_rts2:rts

mt_stopsound:
	move.w	$1c(a4),$dff096
	bra	mt_com2

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	add.b	d0,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_brk+3-[mt_samplestarts-4](a1)
	rts

mt_songjmp:
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	#1,mt_brk+3-[mt_samplestarts-4](a1)
	move.b	d0,mt_song+3-[mt_samplestarts-4](a1)
	rts

mt_setvol:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$40,d0
	bls.s	mt_sv2
	move.b	#$40,d0
mt_sv2:	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_spd+3-[mt_samplestarts-4](a1)
	rts

mt_port:move.b	3(a4),d2
	beq.s	mt_port2
	move.b	d2,$15(a4)
	clr.b	3(a4)
mt_port2:
	moveq	#0,d0
	tst.w	$16(a4)
	beq.s	mt_rts
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	move.w	d7,$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	move.w	d7,$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	move.w	d0,d2
	lsr.w	#2,d0
	and.w	#$1f,d0
	move.b	$18(a4),d1
	and.w	d5,d1
	asl.w	#5,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	mt_sin(pc,d0.w),d1

	tst.b	d2
	bmi.s	mt_vibsub
	move.w	$10(a4),d2
	add.w	d1,d2
	bra.s	mt_vib3
mt_vibsub:
	move.w	$10(a4),d2
	sub.w	d1,d2
mt_vib3:move.w	d2,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts

mt_sin:
dc.l 0,0,0,0,0,0,0,0
dc.l $00000000,$00000101,$01010101,$01010101,$01010101,$01010101
dc.l $01000000,$00000000,$00000001,$01010202,$02030303,$03030303
dc.l $03030303,$03030303,$02020201,$01010000,$00000101,$02020303
dc.l $04040405,$05050505,$05050505,$05050404,$04030302,$02010100
dc.l $00000102,$03030405,$05060607,$07070707,$07070707,$07070606
dc.l $05050403,$03020100,$00000102,$03040506,$07070808,$09090909
dc.l $09090909,$09080807,$07060504,$03020100,$00010203,$04050607
dc.l $0809090a,$0b0b0b0b,$0b0b0b0b,$0b0a0909,$08070605,$04030201
dc.l $00010204,$05060708,$090a0b0c,$0c0d0d0d,$0d0d0d0d,$0c0c0b0a
dc.l $09080706,$05040201,$00010304,$0607080a,$0b0c0d0e,$0e0f0f0f
dc.l $0f0f0f0f,$0e0e0d0c,$0b0a0807,$06040301,$00010305,$0608090b
dc.l $0c0d0e0f,$10111111,$11111111,$100f0e0d,$0c0b0908,$06050301
dc.l $00010305,$07090b0c,$0e0f1011,$12131313,$13131313,$1211100f
dc.l $0e0c0b09,$07050301,$00020406,$080a0c0d,$0f101213,$14141515
dc.l $15151514,$14131210,$0f0d0c0a,$08060402,$00020406,$090b0d0f
dc.l $10121315,$16161717,$17171716,$16151312,$100f0d0b,$09060402
dc.l $00020407,$090c0e10,$12141516,$17181919,$19191918,$17161514
dc.l $12100e0c,$09070402,$00020508,$0a0d0f11,$13151719,$191a1b1b
dc.l $1b1b1b1a,$19181715,$13110f0d,$0a080502,$00020508,$0b0e1012
dc.l $1517181a,$1b1c1d1d,$1d1d1d1c,$1b1a1817,$1512100e,$0b080502

mt_arplist:
dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_cou+1(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq	mt_normper
	subq.b	#2,d0
	beq.s	mt_arp2
mt_arp1:move.b	3(a4),d0
	lsr.w	#4,d0
	bra.s	mt_arpdo
mt_arp2:move.b	3(a4),d0
	and.w	d5,d0
mt_arpdo:
	add.w	d0,d0
	move.w	$10(a4),d1
	lsr.w	#2,d1
	add.b	mt_arp3-$1c(pc,d1.w),d0
	lea	mt_periods(pc),a0
	move.w	(a0,d0.w),6(a5)
	rts

mt_arp3:
dc.l $46004442,$0040003e,$003c0000,$3a003800,$00360034,$00003200
dc.l $00300000,$2e000000,$2c00002a,$00000028,$00000026,$00000024
dc.l $00000000,$22000000,$20000000,$00001e00,$0000001c,$00000000
dc.l $001a0000,$00000018,$00000000,$00160000,$00000000,$14000000
dc.l $00000012,$00000000,$00001000,$00000000,$00000e00,$00000000
dc.l $0000000c,$00000000,$00000000,$0a000000,$00000000,$00080000
dc.l $00000000,$00000000,$06000000,$00000000,$00000400,$00000000
dc.l $00000000,$200,0,0,0

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	d4,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	d5,d0
	beq	mt_arp
	subq.b	#1,d0
	beq.s	mt_portup
	subq.b	#1,d0
	beq.s	mt_portdown
	subq.b	#1,d0
	beq	mt_port
	subq.b	#1,d0
	beq	mt_vib
	subq.b	#1,d0
	beq.s	mt_volport
	subq.b	#1,d0
	beq.s	mt_volvib
	move.w	$10(a4),6(a5)
	subq.b	#4,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	bsr	mt_vib2
	bra.s	mt_volslide
mt_volport:
	bsr	mt_port2

mt_volslide:
	move.b	3(a4),d0
	move.w	d0,d1
	and.b	d5,d0
	beq.s	mt_vol3
	sub.b	d0,$13(a4)
	bpl.s	mt_vol2
	move.b	d7,$13(a4)
mt_vol2:move.w	$12(a4),8(a5)
	rts

mt_vol3:lsr.b	#4,d1
	add.b	d1,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
	move.w	$12(a4),8(a5)
	rts

mt_periods:
dc.w $358,$328,$2fa,$2d0,$2a6,$280,$25c,$23a,$21a,$1fc,$1e0,$1c5,$1ac
dc.w $194,$17d,$168,$153,$140,$12e,$11d,$10d,$fe,$f0,$e2,$d6,$ca,$be
dc.w $b4,$aa,$a0,$97,$8f,$87,$7f,$78,$71,0

mt_samplestarts:blk.l	$1f,0
mt_voice1:	blk.w	14,0
		dc.w	1
mt_voice2:	blk.w	14,0
		dc.w	2
mt_voice3:	blk.w	14,0
		dc.w	4
mt_voice4:	blk.w	14,0
		dc.w	8

